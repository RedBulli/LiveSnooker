class Frame extends Livesnooker.Model
  initialize: (options) ->
    @set('shotGroups', new ShotGroups([], frame: @))
    @set('currentPlayer', @get('Player1'))
    @undoManager = new Backbone.UndoManager
      register: [@get('shotGroups')],
      track: true

  getNonCurrentPlayer: ->
    if @get('currentPlayer') == @get('Player1')
      @get('Player2')
    else
      @get('Player1')

  currentPlayerIndex: ->
    if @get('currentPlayer') == @get('Player1')
      0
    else
      1

  addShot: (shot) ->
    @get('shotGroups').addShot(shot)
    if !shot.isPot()
      @set 'currentPlayer', @getNonCurrentPlayer()
    @trigger('updateView')

  createShot: ({attempt, result, points}) ->
    shot = new Shot
      frame_id: @id,
      player_id: @get('currentPlayer').id,
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

((scope) -> scope.Frame = Frame)(@)
