activeSessions = {}

SocketConnection = (socketUrl, leagueId, element, authentication) ->
  onMessageCallbacks = {}
  query = "league_id=#{leagueId}"
  if authentication
    query += "&id_token=#{authentication.id_token}"
  socket = io.connect(socketUrl, {query: query})

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
    if @socketUrl && @leagueId
      SocketConnection(@socketUrl, @leagueId, @, @$.api.data.authentication)

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
