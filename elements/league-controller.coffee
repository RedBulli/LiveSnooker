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
    playerInput = Polymer.dom(this).node.querySelector("#player-name")
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

  newAdmin: ->
    event.preventDefault()
    league = @league
    emailInput = Polymer.dom(this).node.querySelector("#admin-email")
    opts =
      UserEmail: emailInput.value
      League: league
      LeagueId: league.id
    admin = new Admin(opts)
    admin.setApiClient(@$.api)
    admin.save admin.attributes,
      success: (model) ->
        league.get('Admins').add(model)
        emailInput.value = ""

  playerRemoveClick: (event) ->
    event.preventDefault()
    player = event.target.player
    if window.confirm("Deleting player #{player.get('name')}. Are you sure?")
      player.setApiClient(@$.api)
      player.destroy(wait: true)

  adminRemoveClick: (event) ->
    event.preventDefault()
    admin = event.target.admin
    if window.confirm("Deleting admin #{admin.get('UserEmail')}. Are you sure?")
      admin.setApiClient(@$.api)
      admin.destroy wait: true

  onPlayerEdit: (editEvent) ->
    player = editEvent.target.object
    player.setApiClient(@$.api)
    onError = ->
      editEvent.target.setContent(player.get('name'))
    player.save({name: editEvent.detail}, {
      wait: true,
      error: onError
    })

  _leagueIdChanged: ->
    if @leagueId
      @$.api.findOrFetchModel(League, @leagueId)
        .then (league) =>
          @league = league
          @fire('iron-signal', {name: "league", data: league})
