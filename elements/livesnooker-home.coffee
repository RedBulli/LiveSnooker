promisify = (fn) ->
  new Promise (resolve, reject) ->
    fn({
      success: resolve,
      error: reject
    })

Polymer
  is: 'livesnooker-home'

  properties:
    leagueId:
      type: String,
      observer: '_leagueIdChanged'
    league: Object
    unfinishedFrames:
      type: Array
      value: -> []
    finishedFrames:
      type: Array
      value: -> []
    streamUrl: String
    socketUrl: String
    user: Object

  _isRTCSupported: ->
    window.isRTCSupported()

  _hasWriteAccess: (user, league) ->
    league.hasWriteAccess(user)

  accountSignal: (signal) ->
    this.user = signal.detail

  frameUrl: (frame) ->
    "/frame.html?leagueId=" + @leagueId + "&frameId=" + frame.id

  computeControlLink: (frame) ->
    @frameUrl(frame) + "&input=true"

  computeViewLink: (frame) ->
    @frameUrl(frame) + "&input=false"

  computeWinnerClass: (frame, player) ->
    if frame.attributes.Winner == player
      "winner"

  computeStartDate: (frame) ->
    new Date(frame.get('createdAt')).toLocaleString()

  computeEndDate: (frame) ->
    new Date(frame.get('endedAt')).toLocaleString()

  onStreamEvent: (event) ->
    if event.detail.event == 'frameStart'
      if !Frame.findModel(event.detail.frame.id)
        frame = new Frame(event.detail.frame)
        frame.populateAssociations()
        @league.get('Frames').add(frame)
    else if event.detail.event == 'frameEnd'
      frame = @league.get('Frames').get(event.detail.frame.id)
      frame.set(event.detail.frame)
      frame.populateAssociations()
    else if event.detail.event == 'frameDelete'
      frame = @league.get('Frames').get(event.detail.frame.id)
      frame.set(event.detail.frame)
      frame.trigger('destroy', frame);
      frame = null
    else if event.detail.event == 'newPlayer'
      if !Player.findModel(event.detail.player.id)
        player = new Player(event.detail.player)
        @league.get('Players').add(player)

  getVideoStatusElement: (frameId) ->
    $(Polymer.dom(this).node.querySelector('li[data-id="' + frameId + '"] > .video-status'))

  showFrame: (event) ->
    event.preventDefault()
    window.open(event.currentTarget.href, "", "width=1050, height=600")

  controlFrame: (event) ->
    event.preventDefault()
    window.open(event.currentTarget.href, "", "width=1050, height=600")

  newStream: (event) ->
    @getVideoStatusElement(event.detail).show()

  streamClosed: (event) ->
    @getVideoStatusElement(event.detail).hide()

  computeShowBreaks: (frame) ->
    "/#/leagues/#{frame.get('LeagueId')}/frames/#{frame.id}"

  updateFrames: ->
    @splice('unfinishedFrames', 0, @unfinishedFrames.length)
    @splice('finishedFrames', 0, @finishedFrames.length)
    @league.get('Frames').each (frame) =>
      if frame.get('endedAt')
        this.push 'finishedFrames', frame if frame.id
      else
        this.push 'unfinishedFrames', frame if frame.id

  initFrames: ->
    @league.get('Frames').on 'add remove change', =>
      @updateFrames()
    @updateFrames()

  _leagueIdChanged: ->
    if @leagueId
      @$.api.findOrFetchModel(League, @leagueId)
        .then (league) =>
          @$.api.data.ready.then =>
            streamUrl = "#{@$.api.host}/leagues/#{@leagueId}/stream"
            if @$.api.data.authentication
              streamUrl += "?id_token=#{@$.api.data.authentication.id_token}"
            @streamUrl = streamUrl
          league.setApiClient(@$.api) if not league.client
          @league = league
          league.get('Frames').leagueId = league.id
          league.get('Frames').setApiClient(league.client)
          league.get('Players').leagueId = league.id
          league.get('Players').setApiClient(league.client)
          _this = @
          Promise.all([
            promisify(league.get('Frames').fetch.bind(league.get('Frames'))),
            promisify(league.get('Players').fetch.bind(league.get('Players')))
          ]).then ->
            _this.initFrames.call(_this)
          @fire('iron-signal', {name: "league", data: league})
        .catch (model, response) =>
          @noleague = response.responseJSON.error.message
