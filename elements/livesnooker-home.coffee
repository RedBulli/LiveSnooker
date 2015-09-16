# routeToLeague = (router) ->
#   if localStorage.leagueId
#     router.go('/' + localStorage.leagueId)
#   else
#     router.go('/leagues/')

Polymer
  is: 'livesnooker-home'

  properties:
    leagueId:
      type: String,
      observer: '_leagueIdChanged'
    league: Object
    frames:
      type: Array
      value: -> []
    streamUrl: String
    socketUrl: String

  unfinishedFrame: (frame) ->
    if !frame.get('endedAt')
      true
    else
      false

  finishedFrame: (frame) ->
    if frame.get('endedAt')
      true
    else
      false

  computeControlLink: (frame) ->
    "/frame.html?frameId=" + frame.id + "&input=true"

  computeViewLink: (frame) ->
    "/frame.html?frameId=" + frame.id + "&input=false"

  computeWinnerClass: (frame, player) ->
    if frame.attributes.Winner == player
      "winner"

  onStreamEvent: (event) ->
    if event.detail.event == 'frameStart'
      frame = Frame.findModel(event.detail.frame.id)
      if !frame
        frame = new Frame(event.detail.frame)
        frame.populateAssociations()
        @league.get('Frames').add(frame)
    else if event.detail.event == 'frameEnd'
      frame = @league.get('Frames').get(event.detail.frame.id)
      frame.set(event.detail.frame)
      frame.populateAssociations()
      this.querySelector("#unfinished").render()
      this.querySelector("#finished").render()
    else if event.detail.event == 'frameDelete'
      1
    else if event.detail.event == 'newPlayer'
      1
      #Add frame

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

  showBreaks: (event) ->
    event.preventDefault()
    console.log("Not implemented yet")

  updateFrames: ->
    @splice('frames', 0, @frames.length)
    @league.get('Frames').each (frame) =>
      this.push 'frames', frame if frame.id

  _leagueIdChanged: ->
    if @leagueId
      @streamUrl = @$.api.host + "/framestream/" + @leagueId
      @$.api.findOrFetchModel(League, @leagueId)
        .then (league) =>
          league.setApiClient(@$.api) if not league.client
          @league = league
          @league.get('Frames').on 'add remove change', =>
            @updateFrames()
          league.get('Frames').leagueId = league.id
          league.get('Frames').setApiClient(league.client)
          league.get('Frames').fetch({
            success: @updateFrames.bind(@)
          })
          @fire('iron-signal', {name: "league", data: league})
        .catch (model, response) =>
          @noleague = response.responseJSON.error.message
