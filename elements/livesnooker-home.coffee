Polymer
  is: 'livesnooker-home'

  properties:
    league: Object,
    unfinishedFrames: Array
    finishedFrames: Array
    isAdmin: Boolean

  frameUrl: (frame) ->
    "/frame.html?leagueId=#{frame.get('LeagueId')}&frameId=#{frame.id}"

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
