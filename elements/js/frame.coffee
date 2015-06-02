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
    },
    {
      type: Backbone.HasMany,
      key: 'Shots',
      relatedModel: 'Shot',
      collectionType: 'Shots'
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
    shotGroups = new ShotGroups([], { frame: @ })
    shots.each (shot) -> shotGroups.addShot(shot)
    @set('shotGroups', shotGroups)

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

  createShot: ({attempt, result, points}) ->
    shot = @newShot({
      attempt: attempt,
      result: result,
      points: parseInt(points),
      Player: @getCurrentPlayer(),
      shotNumber: @get('Shots').length + 1
    })
    shot.setApiClient(@client)
    shot.save(shot.attributes)
    shot

  newShot: (data) ->
    _.extend(data, {
      Frame: @
    })
    if not data.Player && data.PlayerId
      data.Player = @getPlayer(data.PlayerId)
    shot = new Shot(data)
    if shot.validate(shot.attributes)
      throw shot.validate(shot.attributes)
    @get('Shots').add(shot)
    @get('shotGroups').addShot(shot)
    @trigger('updateView')
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
