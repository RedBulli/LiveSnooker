class Shots extends Livesnooker.Collection
  model: Shot
  comparator: 'shotNumber'
  url: ->
    @frame.url() + "/shots"

  calculateTotals: (totals) ->
    totals = totals || {}
    @each (shot) ->
      if !totals[shot.get('Player').id]?
        totals[shot.get('Player').id] = {points: 0, fouls: 0}
      if shot.isPot()
        totals[shot.get('Player').id].points += parseInt(shot.get('points'))
      else if shot.isFoul()
        totals[shot.get('Player').id].fouls += parseInt(shot.get('points'))
    totals

  calculateSafeties: ->
    calc = (memo, shot) ->
      safetyPlayer = memo['prevSafetyPlayer']
      if safetyPlayer
        if !memo[safetyPlayer.id]
          memo[safetyPlayer.id] =
            successes: 0
            failures: 0
        if shot.get('Player') != safetyPlayer
          if shot.isPot()
            memo[safetyPlayer.id].failures++
          else
            memo[safetyPlayer.id].successes++
      if shot.isSafetyAttempt() && !shot.isPot()
        memo['prevSafetyPlayer'] = shot.get('Player')
      else
        memo['prevSafetyPlayer'] = null
      memo

    totals = @reduce(calc, {})
    delete totals['prevSafetyPlayer']
    _.each totals, (playerStats) ->
      playerStats.safetyPct = playerStats.successes * 100 / ((playerStats.successes + playerStats.failures) || 1)
    totals

  calculateStats: (totals) ->
    totals = totals || {}
    @each (shot) ->
      if !totals[shot.get('Player').id]?
        totals[shot.get('Player').id] =
          player: shot.get('Player')
          potAttempts: 0
          pots: 0
          safetyPots: 0
          safetyAttempts: 0
          foulPointsGiven: 0
          points: 0
      totalObj = totals[shot.get('Player').id]
      totalObj.pots++ if shot.isPot()
      totalObj.potAttempts++ if shot.isPotAttempt()
      if shot.isSafetyAttempt()
        totalObj.safetyAttempts++
        if shot.isPot()
          totalObj.safetyPots++
      if shot.isFoul()
        totalObj.foulPointsGiven += shot.get('points')
      else
        totalObj.points += shot.get('points')
    totals

  populateAssociations: ->
    @each (shot) -> shot.populateAssociations()

class ShotGroup extends Livesnooker.Model
  initialize: (opts) ->
    opts.shots.on "remove", =>
      shots = @get('shots')
      if shots.length == 0
        @stopListening()
        @trigger 'destroy', @

  lastShot: ->
    @get('shots').last()

  belongsTo: (shot) ->
    !shot.isPot()

  totals: ->
    pots: false
    fouls: false
    misses: true
    shots: @get('shots').length

class Break extends ShotGroup
  belongsTo: (shot) ->
    shot.isPot() && @lastShot().get('Player').id == shot.get('Player').id

  totals: ->
    pots: true
    fouls: false
    misses: false
    player: @lastShot().get('Player')
    points: @get('shots').calculateTotals()[@lastShot().get('Player').id]

class Fouls extends ShotGroup
  belongsTo: (shot) ->
    shot.isFoul() && @lastShot().get('Player').id == shot.get('Player').id

  totals: ->
    pots: false
    fouls: true
    misses: false
    player: @lastShot().get('Player')
    points: @get('shots').calculateTotals()[@lastShot().get('Player').id]

class ShotGroups extends Livesnooker.Collection
  model: ShotGroup

  initialize: (models, options) ->
    if options?.frame
      @frame = options.frame

  addShot: (shot) ->
    if !@last() || !@last().belongsTo(shot)
      @add @newGroup(shot)
    else
      @last().get('shots').add(shot)

  newGroup: (shot) ->
    shots = new Shots([shot])
    if shot.isPot()
      new Break(frame: @frame, shots: shots)
    else if shot.isFoul()
      new Fouls(frame: @frame, shots: shots)
    else
      new ShotGroup(frame: @frame, shots: shots)

  calculateTotalScores: ->
    calc = (memo, group) ->
      group.get('shots').calculateTotals(memo)
    @reduce(calc, {})

  calculateStats: ->
    calc = (memo, group) ->
      stats = group.get('shots').calculateStats(memo)
      if group instanceof Break
        breakTotals = group.totals()
        playerMemo = stats[breakTotals.player.id]
        playerMemo['breaks'] = playerMemo['breaks'] || []
        playerMemo['highestBreak'] = playerMemo['highestBreak'] || 0
        playerMemo['breaks'].push breakTotals.points.points
        if breakTotals.points.points > playerMemo['highestBreak']
          playerMemo['highestBreak'] = breakTotals.points.points
      stats

    totals = @reduce(calc, {})
    _.each totals, (playerStats) ->
      playerStats.potPct = playerStats.pots * 100 / (playerStats.potAttempts || 1)
    totals

((scope) ->
  scope.Shots = Shots
  scope.ShotGroup = ShotGroup
  scope.ShotGroups = ShotGroups
  scope.Break = Break
)(@)
