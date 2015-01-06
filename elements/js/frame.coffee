class Frame extends Backbone.Model
  initialize: (options) ->
    @set('shotGroups', new ShotGroups([], frame: @))
    @set('currentPlayer', @get('players').first())

  getNonCurrentPlayer: ->
    @get('players').getOtherPlayer(@get('currentPlayer').id)

  currentPlayerIndex: ->
    @get('players').indexOf(@get('currentPlayer'))

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

  getScores: ->
    rawTotals = @get('shotGroups').calculateTotalScores()
    firstTotal = rawTotals[@get('players').models[0].id] || { points: 0, fouls: 0 }
    secondTotal = rawTotals[@get('players').models[1].id] || { points: 0, fouls: 0 }
    [firstTotal.points + secondTotal.fouls, secondTotal.points + firstTotal.fouls]

  getPlayer: (id) ->
    @get('players').get(id)

((scope) -> scope.Frame = Frame)(@)
