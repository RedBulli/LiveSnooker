routeToLeague = (router) ->
  if localStorage.leagueId
    router.go('/' + localStorage.leagueId)
  else
    router.go('/leagues/')

Polymer
  frameFinished: (frames, finished) ->
    if frames
      _.filter frames, (frame) ->
        (frame.get('endedAt') != null) == finished

  framesChanged: ->
    debugger

  onStreamEvent: (event) ->
    if event.detail.event == 'frameStart'
      frame = new Frame(event.frame)
      frame.populateAssociations()
      @league.get('Frames').add(frame)
      @frames = []
      @frames = @league.get('Frames').models
    else if event.detail.event == 'frameEnd'
      @frames = []
      frame = @league.get('Frames').get(event.detail.frame.id)
      frame.set(event.detail.frame)
      frame.populateAssociations()
      @frames = @league.get('Frames').models
    else if event.detail.event == 'frameDelete'
      1
    else if event.detail.event == 'newPlayer'
      1
      #Add frame

  getVideoStatusElement: (frameId) ->
    $(@$.framelist.querySelector('li[data-id="' + frameId + '"] > .video-status'))

  showFrame: ->
    event.preventDefault()
    window.open(event.currentTarget.href, "", "width=1050, height=600")

  controlFrame: (event) ->
    event.preventDefault()
    window.open(event.currentTarget.href, "", "width=1050, height=600")

  newStream: (event) ->
    @getVideoStatusElement(event.detail).show()

  streamClosed: (event) ->
    @getVideoStatusElement(event.detail).hide()

  showBreaks: (event) ->
    event.preventDefault()
    console.log("Not implemented yet")

  domReady: ->
    @frames = []
    if @leagueId
      localStorage.leagueId = @leagueId
    else
      routeToLeague @router
      return

    @noleague = "Loading!"
    _this = @
    if !@league
      @streamUrl = @$.api.host + "/framestream"
      @$.api.findOrFetchModel(League, @leagueId)
        .then (league) ->
          _this.league = league
          _this.frames = league.attributes.Frames.models
          _this.router.templateInstance.model.league = league
        .catch (model, response) ->
          _this.noleague = response.responseJSON.error.message
