Polymer
  is: 'league-controller'
  properties:
    league: Object
    leagueId:
      type: String,
      observer: '_leagueIdChanged'
    leagueAttrs: Object
    players:
      type: Object
      observer: '_onPlayersChange'
    playerModels: Array

  newPlayer: ->
    event.preventDefault()
    league = @league
    errorsEl = Polymer.dom(this).node.querySelector("#errors")
    playerInput = Polymer.dom(this).node.querySelector("#playerName")
    opts =
      name: playerInput.value
      LeagueId: league.id
    player = new Player(opts)
    player.setApiClient(@$.api)
    player.save player.attributes,
      success: (model) ->
        league.get('Players').add(model)
        playerInput.value = ""
        errorsEl.errors = []
      error: (data, response) ->
        errorsEl.errors = [response.responseJSON.error.errors[0]]

  playerEditClick: (event) ->
    event.preventDefault()
    console.log "TODO"

  playerRemoveClick: (event) ->
    event.preventDefault()
    playerId = event.target.getAttribute("data-player")
    player = @league.get('Players').get(playerId)
    player.setApiClient(@$.api)
    player.destroy(wait: true)

  _leagueIdChanged: ->
    if @leagueId
      @$.api.findOrFetchModel(League, @leagueId)
        .then (league) =>
          @league = league
          @fire('iron-signal', {name: "league", data: league})
