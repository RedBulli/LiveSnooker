RTCConnection = (leagueId) ->
  connection = new RTCMultiConnection(leagueId)
  onMessageCallbacks = {}
  socket = io.connect('http://localhost:5000/')

  socket.on 'message', (data) ->
    return if data.sender == connection.userid

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

Polymer
  domReady: ->
    connection = RTCConnection(this.leagueId)
    _this = @
    connection.onNewSession = (e) ->
      _this.fire("new-stream", e.sessionid)
