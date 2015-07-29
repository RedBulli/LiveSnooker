activeSessions = {}

RTCConnection = (leagueId, element) ->
  connection = new RTCMultiConnection(leagueId)
  onMessageCallbacks = {}
  socket = io.connect('http://localhost:5555/')

  socket.on 'message', (data) ->
    return if data.sender == connection.userid
    frameId = data.message?.sessionid
    if frameId
      element.fire("new-stream", frameId) unless activeSessions[frameId]
      activeSessions[frameId] = new Date()

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
  for frameId, val of activeSessions
    diff = new Date() - val
    if diff > 10000
      delete activeSessions[frameId]
      this.fire('stream-closed', frameId)

Polymer
  is: 'stream-channel',
  properties: {
    leagueId: String
  },
  ready: ->
    connection = RTCConnection(this.leagueId, @)
    connection.onNewSession = (e) ->
    setInterval(clearOldSessions.bind(@, connection), 10000)
