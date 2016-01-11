activeSessions = {}

SocketConnection = (api, leagueId, element) ->
  onMessageCallbacks = {}
  socket = io.connect(api.getSocketUrl(), {query: api.getSocketUrlQuery(leagueId)})
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
    socketUrl: String

  createConnection: ->
    SocketConnection(@$.api, @leagueId, @)

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
      if @connection
        @connection.close()
        clearInterval(@intervalId)
        @connection = null
      if @leagueId
        @connection = @createConnection()
        if @connection
          @intervalId = setInterval(@clearOldSessions.bind(@, @connection), 10000)

  ready: ->
    @$.api.data.ready.then =>
      @_resolveReady()
