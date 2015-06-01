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
      type: Backbone.HasOne,
      key: 'League',
      relatedModel: 'League',
      keyDestination: 'LeagueId',
      includeInJSON: 'id'
    }
  ]

  initialize: (options) ->
    @set('shotGroups', new ShotGroups([], frame: @))
    @undoManager = new Backbone.UndoManager
      register: [@get('shotGroups')],
      track: true

  lastShot: ->
    @get('shotGroups').last()?.lastShot()

  getCurrentPlayer: ->
    if @lastShot()?.isPot()
      @lastShot().get('Player')
    else
      @get('Player1')

  getNonCurrentPlayer: ->
    if @getCurrentPlayer() == @get('Player1')
      @get('Player2')
    else
      @get('Player1')

  currentPlayerIndex: ->
    if @getCurrentPlayer() == @get('Player1')
      0
    else
      1

  addShot: (shot) ->
    @get('shotGroups').addShot(shot)
    @trigger('updateView')

  createShot: ({attempt, result, points}) ->
    shot = new Shot
      Frame: @,
      Player: @getCurrentPlayer(),
      attempt: attempt,
      result: result,
      points: parseInt(points)
    if shot.validate(shot.attributes)
      throw shot.validate(shot.attributes)
    shot

  undoShot: ->
    @undoManager.undo()
    @trigger('updateView')

  redoShot: ->
    @undoManager.redo()
    @trigger('updateView')

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

Frame.setup()

((scope) -> scope.Frame = Frame)(@)
