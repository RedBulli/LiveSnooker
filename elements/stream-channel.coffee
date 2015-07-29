RTCConnection = (leagueId) ->
  connection = new RTCMultiConnection(leagueId)
  onMessageCallbacks = {}
  socket = io.connect('http://localhost:5555/')

  socket.on 'message', (data) ->
    return if data.sender == connection.userid
    frameId = data.message?.sessionid
    extra = connection.sessionDescriptions[frameId]?.extra
    extra.lastMessage = new Date() if extra

    if onMessageCallbacks[data.channel]
      onMessageCallbacks[data.channel](data.message)

  socket.on 'presence', (isChannelPresent) ->
      console.log('is channel present', isChannelPresent)
      #if !isChannelPresent playRoleOfSessionInitiator()
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

clearOldSessions = (connection) ->
  for frameId of connection.sessionDescriptions
    if connection.sessionDescriptions[frameId].extra.lastMessage
      diff = new Date() - connection.sessionDescriptions[frameId].extra.lastMessage
      delete connection.sessionDescriptions[frameId] if diff > 10000
      this.fire('stream-closed', frameId)
    else
      connection.sessionDescriptions[frameId].extra.lastMessage = new Date()

Polymer
  is: 'stream-channel',
  properties: {
    leagueId: String
  },
  ready: ->
    connection = RTCConnection(this.leagueId)
    _this = @
    connection.onNewSession = (e) ->
      _this.fire("new-stream", e.sessionid)
    setInterval(clearOldSessions.bind(@, connection), 10000)
