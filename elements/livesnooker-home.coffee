Polymer
  is: 'livesnooker-home'

  properties:
    leagueId: String
    league: Object,
    unfinishedFrames: Array
    finishedFrames: Array
    user: Object

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

  showFrame: (event) ->
    event.preventDefault()
    window.open(event.currentTarget.href, "", "width=1050, height=600")

  controlFrame: (event) ->
    event.preventDefault()
    window.open(event.currentTarget.href, "", "width=1050, height=600")

  computeShowBreaks: (frame) ->
    "/#/leagues/#{frame.get('LeagueId')}/frames/#{frame.id}"
