sendAction = (url, data) ->
  $.ajax
    type: "POST"
    url: url
    data: data
    headers:
      "Content-Type": "application/json"

class Shots extends Livesnooker.Collection
  model: Shot
  url: '/shots'
  comparator: 'shotNumber'

  calculateTotals: (totals) ->
    totals = totals || {}
    @each (shot) ->
      if !totals[shot.get('Player').id]?
        totals[shot.get('Player').id] = {points: 0, fouls: 0}
      if shot.get('result') == "pot"
        totals[shot.get('Player').id].points += parseInt(shot.get('points'))
      else if shot.get('result') == "foul"
        totals[shot.get('Player').id].fouls += parseInt(shot.get('points'))
    totals

  populateAssociations: ->
    @each (shot) -> shot.populateAssociations()

class ShotGroup extends Livesnooker.Model
  lastShot: ->
    @get('shots').last()

  belongsTo: (shot) ->
    !shot.isPot()

  totals: ->
    pots: false
    shots: @get('shots').length

class Break extends ShotGroup
  belongsTo: (shot) ->
    shot.isPot() && @lastShot().get('Player').id == shot.get('Player').id

  totals: ->
    pots: true
    player: @lastShot().get('Player')
    points: @get('shots').calculateTotals()[@lastShot().get('Player').id]

class ShotGroups extends Livesnooker.Collection
  model: ShotGroup

  initialize: (models, options) ->
    if options?.frame
      @frame = options.frame
      @on 'add', (shotGroup) =>
        @frame.undoManager.register(shotGroup.get('shots'))

  addShot: (shot) ->
    if !@last() || !@last().belongsTo(shot)
      @add @newGroup(shot)
    else
      @last().get('shots').add(shot)
    @trigger 'update'

  newGroup: (shot) ->
    shots = new Shots([shot])
    if shot.isPot()
      new Break(frame: @frame, shots: shots)
    else
      new ShotGroup(frame: @frame, shots: shots)

  calculateTotalScores: ->
    calc = (memo, group) ->
      group.get('shots').calculateTotals(memo)
    @reduce(calc, {})

((scope) ->
  scope.Shots = Shots
  scope.ShotGroup = ShotGroup
  scope.ShotGroups = ShotGroups
  scope.Break = Break
)(@)
