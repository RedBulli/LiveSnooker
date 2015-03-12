class Frame extends Livesnooker.Model
  initialize: (options) ->
    @set('shotGroups', new ShotGroups([], frame: @))
    @set('currentPlayer', @get('player1'))
    @undoManager = new Backbone.UndoManager
      register: [@get('shotGroups')],
      track: true

  getNonCurrentPlayer: ->
    if @get('currentPlayer') == @get('player1')
      @get('player2')
    else
      @get('player1')

  currentPlayerIndex: ->
    if @get('currentPlayer') == @get('player1')
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
    firstTotal = rawTotals[@get('player1').id] || { points: 0, fouls: 0 }
    secondTotal = rawTotals[@get('player2').id] || { points: 0, fouls: 0 }
    [firstTotal.points + secondTotal.fouls, secondTotal.points + firstTotal.fouls]

  getPlayer: (id) ->
    if @get('player1').id == id
      @get('player1')
    else if @get('player2').id == id
      @get('player2')

((scope) -> scope.Frame = Frame)(@)
