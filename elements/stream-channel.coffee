activeSessions = {}

RTCConnection = (socketUrl, leagueId, element, authentication) ->
  connection = new RTCMultiConnection(leagueId)
  unless connection.DetectRTC.isWebRTCSupported
    connection = null
    return
  onMessageCallbacks = {}
  query = "league_id=#{leagueId}"
  if authentication
    query += "&id_token=#{authentication.id_token}"
  socket = io.connect(socketUrl, {query: query})

  socket.on 'message', (data) ->
    return if data.sender == connection.userid
    frameId = data.message?.sessionid
    if frameId
      element.fire("new-stream", frameId) unless activeSessions[frameId]
      activeSessions[frameId] = new Date()

    if onMessageCallbacks[data.channel]
      onMessageCallbacks[data.channel](data.message)

  socket.emit('presence', leagueId)

  connection.openSignalingChannel = (config) ->
    channel = config.channel || leagueId
    onMessageCallbacks[channel] = config.onmessage

    setTimeout(config.onopen, 1000) if config.onopen
    {
      send: (message) ->
        socket.emit('message', {
          sender: connection.userid
          channel: channel
          message: message
        });
      channel: channel
    }

  connection.ondisconnected = (e) ->
    console.error("Someone disconnected the whole channel. This shouldn't happen.")

  connection.connect()

Polymer
  is: 'stream-channel'
  properties:
    leagueId:
      type: String,
      observer: '_onLeagueChange'
    socketUrl: String

  createConnection: ->
    if @socketUrl && @leagueId
      RTCConnection(@socketUrl, @leagueId, @, @$.api.data.authentication)

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
        @connection.leave()
        clearInterval(@intervalId)
        @connection = null
      if @leagueId
        @connection = @createConnection()
        if @connection
          @intervalId = setInterval(@clearOldSessions.bind(@, @connection), 10000)

  ready: ->
    @$.api.data.ready.then =>
      @_resolveReady()
