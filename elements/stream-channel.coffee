activeSessions = {}

SocketConnection = (socket, api, leagueId, element) ->
  onMessageCallbacks = {}
  query = api.getSocketUrlQuery(leagueId)
  if socket
    socket.io.opts.query = query
    socket.connect()
  else
    socket = io.connect(api.getSocketUrl(), {query: query})
  socket.on 'message', (data) ->
    frameId = data.message?.sessionid
    if frameId
      element.fire("new-stream", frameId) unless activeSessions[frameId]
      activeSessions[frameId] = new Date()

    if onMessageCallbacks[data.channel]
      onMessageCallbacks[data.channel](data.message)

  socket.emit('presence', leagueId)
  socket

Polymer
  is: 'stream-channel'
  properties:
    leagueId:
      type: String,
      observer: '_onLeagueChange'

  createConnection: ->
    SocketConnection(@socket, @$.api, @leagueId, @)

  clearOldSessions: ->
    for frameId, val of activeSessions
      diff = new Date() - val
      if diff > 10000
        delete @activeSessions[frameId]
        @fire('stream-closed', frameId)

  created: ->
    @activeSessions = {}
    @whenReady = new Promise (resolve, reject) =>
      @_resolveReady = resolve
      @_rejectReady = reject

  _onLeagueChange: ->
    @whenReady.then =>
      if @socket
        @socket.disconnect()
      if @leagueId
        unless @socket
          setInterval(@clearOldSessions.bind(@), 10000)
        @socket = SocketConnection(@socket, @$.api, @leagueId, @)

  ready: ->
    @$.api.data.ready.then =>
      @_resolveReady()
