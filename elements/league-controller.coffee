Polymer
  is: 'league-controller'
  properties:
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
    errorsEl = @$.league.querySelector("#errors")
    playerInput = @$.league.querySelector('#playerName')
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

  _onPlayersChange: ->
    if @playerModels
      @splice('playerModels', 0, @playerModels.length)
    @playerModels = _.clone(@players.models)
    @players.on 'add remove change update', (model) =>
      @splice('playerModels', 0, @playerModels.length)
      @players.each (playerModel) =>
        @push('playerModels', playerModel)

  _leagueIdChanged: ->
    if @leagueId
      @$.api.findOrFetchModel(League, @leagueId)
        .then (league) =>
          @league = league
          @leagueAttrs = league.attributes
          @players = league.get('Players')
          @fire('iron-signal', {name: "league", data: league})
        .catch (model, response) =>
          @error = response.status
