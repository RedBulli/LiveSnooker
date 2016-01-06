class Frame extends Livesnooker.Model
  urlRoot: ->
    leagueId = @get('League')?.id || @get('LeagueId')
    "/leagues/" + leagueId + "/frames"

  relations: [
    {
      type: Backbone.HasOne,
      key: 'Player1',
      relatedModel: 'Player',
      keyDestination: 'Player1Id',
      includeInJSON: 'id'
    },
    {
      type: Backbone.HasOne,
      key: 'Player2',
      relatedModel: 'Player',
      keyDestination: 'Player2Id',
      includeInJSON: 'id'
    },
    {
      type: Backbone.HasMany
      key: 'Shots'
      relatedModel: 'Shot'
      collectionType: 'Shots'
      reverseRelation:
        key: 'Frame'
        keyDestination: 'FrameId'
        includeInJSON: 'id'
    },
    {
      type: Backbone.HasOne,
      key: 'Winner',
      relatedModel: 'Player',
      keyDestination: 'WinnerId',
      includeInJSON: 'id'
    }
  ]

  initialize: (options) ->
    @set('shotGroups', new ShotGroups([], frame: @))

  calculateShotGroups: ->
    @get('shotGroups').reset()
    shots = @get('Shots')
    shots.sort()
    shots.each (shot) => @get('shotGroups').addShot(shot)

  lastShot: ->
    @get('shotGroups').last()?.lastShot()

  getCurrentPlayer: ->
    if @get('currentPlayer')
      @get('currentPlayer')
    else
      lastShot = @lastShot()
      if lastShot
        if lastShot.isPot()
          lastShot.get('Player')
        else
          @getOtherPlayer(lastShot.get('Player'))
      else
        @get('Player1')

  getNonCurrentPlayer: ->
    @getOtherPlayer(@getCurrentPlayer())

  getOtherPlayer: (player) ->
    if @get('Player1') == player
      @get('Player2')
    else if @get('Player2') == player
      @get('Player1')

  currentPlayerIndex: ->
    if @getCurrentPlayer() == @get('Player1')
      0
    else
      1

  initializeShot: (data) ->
    return if @get('Shots').find((shot) -> shot.get('shotNumber') == data.shotNumber)
    _.extend(data, {
      Frame: @
    })
    if not data.Player && data.PlayerId
      data.Player = @getPlayer(data.PlayerId)
    shot = new Shot(data)
    if shot.validate(shot.attributes)
      throw shot.validate(shot.attributes)
    shot

  getResultFromShot: ({points, foul}) ->
    if foul
      "foul"
    else if parseInt(points) == 0
      "nothing"
    else
      "pot"

  createShot: ({attempt, points, foul}) ->
    shot = @initializeShot
      attempt: attempt,
      result: @getResultFromShot({foul: foul, points: points}),
      points: parseInt(points),
      Player: @getCurrentPlayer(),
      shotNumber: @get('Shots').length + 1

    if shot
      shot.setApiClient(@client)
      shot.save(shot.attributes, {
        success: =>
          @addShot(shot)
        error: ->
          shot.destroy()
      })
      shot

  addShot: (shot) ->
    @get('Shots').add(shot)
    @get('shotGroups').addShot(shot)
    @trigger("update")
    shot

  deleteShot: (shotId) ->
    model = @get('Shots').get shotId
    model.stopListening()
    model.trigger 'destroy', model, model.collection
    Backbone.Relational.store.unregister(model)
    @get('Shots').trigger "update"
    @trigger("update")

  undoShot: ->
    model = @get('Shots').last()
    model.setApiClient @client
    model.destroy
      wait: true
      success: =>
        Backbone.Relational.store.unregister(model)
        @trigger("update")

  getState: ->
    scores = @getScores()
    currentPlayer = @getCurrentPlayer()
    [
      {
        player: @get('Player1'),
        score: scores[0],
        currentPlayer: currentPlayer == @get('Player1')
      },
      {
        player: @get('Player2'),
        score: scores[1],
        currentPlayer: currentPlayer == @get('Player2')
      },
    ]

  calculateStats: ->
    stats = @get('shotGroups').calculateStats()
    safeties = @get('Shots').calculateSafeties()
    stats[@get('Player1').id]?['safeties'] = safeties[@get('Player1').id]
    stats[@get('Player2').id]?['safeties'] = safeties[@get('Player2').id]
    [stats[@get('Player1').id], stats[@get('Player2').id]]

  getScores: ->
    rawTotals = @get('shotGroups').calculateTotalScores()
    firstTotal = rawTotals[@get('Player1').id] || { points: 0, fouls: 0 }
    secondTotal = rawTotals[@get('Player2').id] || { points: 0, fouls: 0 }
    [firstTotal.points + secondTotal.fouls, secondTotal.points + firstTotal.fouls]

  getPlayer: (id) ->
    if @get('Player1').id == id
      @get('Player1')
    else if @get('Player2').id == id
      @get('Player2')

  getLeader: ->
    scores = @getScores()
    if scores[0] > scores[1]
      @get('Player1')
    else if scores[1] > scores[0]
      @get('Player2')
    else
      "tie"

  populateAssociations: ->
    @set('Player1', Player.findModel(@get('Player1Id')))
    @set('Player2', Player.findModel(@get('Player2Id')))
    @set('League', League.findModel(@get('LeagueId')))
    @set('Winner', Player.findModel(@get('WinnerId')))

  changePlayerAllowed: ->
    !@get('Shots').last() || @get('Shots').last().isFoul()


  setPlayerInTurn: (playerId) ->
    @set('currentPlayer', @getPlayer(playerId))
    @trigger("update")

  changePlayer: ->
    if @changePlayerAllowed()
      @save({currentPlayer: @getNonCurrentPlayer()}, {patch: true, url: @url() + "/playerchange"})
      @trigger("update")

Frame.setup()

class Frames extends Livesnooker.Collection
  model: Frame
  url: ->
    "/leagues/#{@leagueId}/frames"
  comparator: (frame) ->
    if frame.get('endedAt')
      1 / new Date(frame.get('endedAt')).getTime()
    else
      - new Date(frame.get('createdAt')).getTime()

((scope) ->
  scope.Frame = Frame
  scope.Frames = Frames
)(@)
