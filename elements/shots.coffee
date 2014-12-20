sendAction = (url, data) ->
  $.ajax
    type: "POST"
    url: url
    data: data
    headers:
      "Content-Type": "application/json"

class Shots extends Backbone.Collection
  model: Shot

  initialize: ->
    @on 'add', (shot) ->
      sendAction('http://localhost:5000/action', JSON.stringify(shot.toJSON()))

  calculateTotals: ->
    totals = {}
    @each (shot) ->
      if !totals[shot.get('player_id')]?
        totals[shot.get('player_id')] = {points: 0, fouls: 0}
      if shot.get('result') == "pot"
        totals[shot.get('player_id')].points += parseInt(shot.get('points'))
      else if shot.get('result') == "foul"
        totals[shot.get('player_id')].fouls += parseInt(shot.get('points'))
    totals

((scope) -> scope.Shots = Shots)(@)
