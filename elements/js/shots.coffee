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

  calculateTotals: (totals) ->
    totals = totals || {}
    @each (shot) ->
      if !totals[shot.get('player_id')]?
        totals[shot.get('player_id')] = {points: 0, fouls: 0}
      if shot.get('result') == "pot"
        totals[shot.get('player_id')].points += parseInt(shot.get('points'))
      else if shot.get('result') == "foul"
        totals[shot.get('player_id')].fouls += parseInt(shot.get('points'))
    totals

class ShotGroup extends Backbone.Model
  initialize: (options) ->
    @set('shots', new Shots(options.shots))

  belongsTo: (shot) ->
    !shot.isPot()

class Break extends ShotGroup
  lastShot: ->
    @get('shots').last()

  belongsTo: (shot) ->
    shot.isPot() && @lastShot().get('player_id') == shot.get('player_id')

class ShotGroups extends Backbone.Collection
  model: ShotGroup

  addShot: (shot) ->
    if !@last() || !@last().belongsTo(shot)
      @add @newGroup(shot)
    else
      @last().get('shots').add(shot)

  newGroup: (shot) ->
    if shot.isPot()
      new Break(shots: [shot])
    else
      new ShotGroup(shots: [shot])

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
