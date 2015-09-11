class Frame extends Livesnooker.Model
  urlRoot: "/frames"
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
    @undoManager = new Backbone.UndoManager
      register: [@get('shotGroups')],
      track: true

  calculateShotGroups: ->
    shots = @get('Shots')
    shots.sort()
    shots.each (shot) => @get('shotGroups').addShot(shot)

  lastShot: ->
    @get('shotGroups').last()?.lastShot()

  getCurrentPlayer: ->
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
    _.extend(data, {
      Frame: @
    })
    if not data.Player && data.PlayerId
      data.Player = @getPlayer(data.PlayerId)
    shot = new Shot(data)
    if shot.validate(shot.attributes)
      throw shot.validate(shot.attributes)
    shot

  createShot: ({attempt, result, points}) ->
    shot = @initializeShot
      attempt: attempt,
      result: result,
      points: parseInt(points),
      Player: @getCurrentPlayer(),
      shotNumber: @get('Shots').length + 1

    shot.setApiClient(@client)
    shot.save(shot.attributes, {
      success: =>
        @addShot(shot)
      error: =>
        shot.destroy()
    })
    shot

  addShot: (shot) ->
    @get('Shots').add(shot)
    @get('shotGroups').addShot(shot)
    @trigger("update")
    shot

  undoShot: ->
    @undoManager.undo()
    @trigger("update")

  redoShot: ->
    @undoManager.redo()
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

Frame.setup()

class Frames extends Livesnooker.Collection
  model: Frame
  url: ->
    if @leagueId
      "/leagues/#{@leagueId}/frames"
    else
      "/frames"

((scope) ->
  scope.Frame = Frame
  scope.Frames = Frames
)(@)
