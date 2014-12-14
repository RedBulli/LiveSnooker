sequences = {}
sequence = (name) ->
  current = sequences[name] || 0
  sequences[name] = current + 1

sendAction = (url, data) ->
  $.ajax
    type: "POST"
    url: url
    data: data
    headers:
      "Content-Type": "application/json"

class Shot extends Backbone.Model
  initialize: ->
    @set('id', sequence('shot'))

class Shots extends Backbone.Collection
  model: Shot

  initialize: ->
    @on 'add', (shot) ->
      sendAction('http://localhost:5000/action', JSON.stringify(shot.toJSON()))

class Player extends Backbone.Model

class Frame extends Backbone.Model
  initialize: (options) ->
    @set('actions', new Shots())
    @set('currentPlayer', @get('players')[0])

  pushAction: (action) ->
    @get('actions').add(action)

  createShot: ({attempt, result, points}) ->
    new Shot
      frame_id: @id,
      player_id: @get('currentPlayer').id,
      attempt: attempt,
      result: result,
      points: points

Polymer
  attributeChanged: (event) ->
    console.log "Frame attribute changed", event

  onAction: (data) ->
    sendAction(@actionURL, createShot(data.details))

  ready: ->
    @model = new Frame
      id: 1
      players: [new Player(id: 1, name: "Sampo"), new Player(id: 2, name: "Pekka")]
    @actions = (action) ->
      console.log action

