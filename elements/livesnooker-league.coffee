Polymer
  is: 'livesnooker-league'

  properties:
    leagueId:
      type: String,
      observer: '_leagueIdChanged'
    league:
      type: Object
      notify: true
    unfinishedFrames:
      type: Array
      value: -> []
      notify: true
    finishedFrames:
      type: Array
      value: -> []
      notify: true
    streamUrl: String
    socketUrl: String
    user:
      type: Object
      notify: true
    writeAdmin:
      type: Boolean
      notify: true

  created: ->
    @whenAttached = new Promise (resolve, reject) =>
      @_resolveAttached = resolve
      @_rejectAttached = reject

    @leagueResolved = new Promise (resolve, reject) =>
      @_resolveLeague = resolve
      @_rejectLeague = reject

  attached: ->
    @_resolveAttached()

  accountSignal: (signal) ->
    @set('user', signal.detail)
    @leagueResolved.then => @updateWriteAdmin()

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

  newStream: (event) ->
    index = _.indexOf(@unfinishedFrames, @league.get('Frames').get(event.detail))
    if index >= 0
      @set("unfinishedFrames.#{index}.video", true)

  streamClosed: (event) ->
    index = _.indexOf(@unfinishedFrames, @league.get('Frames').get(event.detail))
    if index >= 0
      @set("unfinishedFrames.#{index}.video", false)

  computeShowBreaks: (frame) ->
    "/#/leagues/#{frame.get('LeagueId')}/frames/#{frame.id}"

  setLeague: (league) ->
    @set('league', league)
    @set('streamUrl', @$.api.getStreamUrl(@league))
    @league.get('Frames').on 'add remove change', =>
      @updateFrames()
    @fire('iron-signal', {name: "league", data: league})
    @_resolveLeague()
    @updateFrames()
    @updateWriteAdmin()

  _isRTCSupported: ->
    window.isRTCSupported()

  updateFrames: ->
    @set('unfinishedFrames', @league.get('Frames').filter((frame) -> !frame.get('endedAt')))
    @set('finishedFrames', @league.get('Frames').filter((frame) -> !!frame.get('endedAt')))

  updateWriteAdmin: ->
    @set('writeAdmin', @league.hasWriteAccess(@user))

  _leagueIdChanged: ->
    @whenAttached.then =>
      if @leagueId
        League.fetchWithRelations(@$.api, @leagueId)
          .then (league) =>
            @$.api.data.ready.then =>
              @setLeague(league)
      else
        @set('league', null)
