class Frame extends Backbone.Model
  initialize: (options) ->
    @set('actions', new Shots())
    @set('currentPlayer', @get('players').first())

  getNonCurrentPlayer: ->
    @get('players').getOtherPlayer(@get('currentPlayer').id)

  pushAction: (action) ->
    @get('actions').add(action)
    if !action.isPot()
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
    rawTotals = @get('actions').calculateTotals()
    firstTotal = rawTotals[@get('players').models[0].id] || { points: 0, fouls: 0 }
    secondTotal = rawTotals[@get('players').models[1].id] || { points: 0, fouls: 0 }
    [firstTotal.points + secondTotal.fouls, secondTotal.points + firstTotal.fouls]

((scope) -> scope.Frame = Frame)(@)
