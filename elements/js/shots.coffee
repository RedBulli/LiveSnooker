sendAction = (url, data) ->
  $.ajax
    type: "POST"
    url: url
    data: data
    headers:
      "Content-Type": "application/json"

class Shots extends Livesnooker.Collection
  model: Shot
  url: '/shots'

  initialize: ->
    @on 'add', (shot) ->
      sendAction('http://localhost:5000/action', JSON.stringify(shot.toJSON()))

    @on 'remove', (shot) ->
      $.ajax
        type: "DELETE"
        url: 'http://localhost:5000/action'
        data: JSON.stringify(shot.toJSON())
        headers:
          "Content-Type": "application/json"

  calculateTotals: (totals) ->
    totals = totals || {}
    @each (shot) ->
      if !totals[shot.get('Player').id]?
        totals[shot.get('Player').id] = {points: 0, fouls: 0}
      if shot.get('result') == "pot"
        totals[shot.get('Player').id].points += parseInt(shot.get('points'))
      else if shot.get('result') == "foul"
        totals[shot.get('Player').id].fouls += parseInt(shot.get('points'))
    totals

class ShotGroup extends Livesnooker.Model
  belongsTo: (shot) ->
    !shot.isPot()

  totals: ->
    pots: false
    shots: @get('shots').length

class Break extends ShotGroup
  lastShot: ->
    @get('shots').last()

  belongsTo: (shot) ->
    shot.isPot() && @lastShot().get('Player') == shot.get('Player')

  totals: ->
    pots: true
    player: @lastShot().get('Player')
    points: @get('shots').calculateTotals()[@lastShot().get('Player').id]

class ShotGroups extends Livesnooker.Collection
  model: ShotGroup

  initialize: (models, options) ->
    @frame = options.frame
    @on 'add', (shotGroup) =>
      @frame.undoManager.register(shotGroup.get('shots'))

  addShot: (shot) ->
    if !@last() || !@last().belongsTo(shot)
      @add @newGroup(shot)
    else
      @last().get('shots').add(shot)
    @trigger 'update'

  newGroup: (shot) ->
    shots = new Shots([shot])
    if shot.isPot()
      new Break(frame: @frame, shots: shots)
    else
      new ShotGroup(frame: @frame, shots: shots)

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
