frame =
  id: 2
  currentPlayer: currentPlayer
  actions: []
  pushAction: (action) ->
    this.actions.push(action)

currentPlayer =
  id: 1

createShot = (attempt, result, points) ->
  frame_id: frame.id,
  player_id: currentPlayer.id,
  attempt: attempt,
  result: result,
  points: points

sendAction = (url, data) ->
  $.ajax
    type: "POST"
    url: url
    data: data
    headers:
      "Content-Type": "application/json"

Polymer
  attributeChanged: (event) ->
    console.log "Frame attribute changed", event

  onAction: (data) ->
    sendAction(@actionURL, createShot(data.details))

  ready: ->
    @model = frame
    @actions = (action) ->
      console.log action
