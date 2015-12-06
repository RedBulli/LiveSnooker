EMAIL_REGEX = /// ^ (
  [^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+
  |\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+
  |\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22))*\x40([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+
  |\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+
  |\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d))*$
  ///

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
    if EMAIL_REGEX.test(emailInput.value)
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
        error: ->
          admin.destroy()

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

  adminWriteChange: (event) ->
    updateAdminWriteAccess = =>
      admin.setApiClient(@$.api)
      admin.save({write: event.target.checked}, {
        patch: true,
        wait: true
      }).always ->
        event.target.checked = admin.get('write')

    event.preventDefault()
    admin = event.target.admin
    if !event.target.checked
      if window.confirm("Removing write access from #{admin.get('UserEmail')}. Are you sure?")
        updateAdminWriteAccess()
    else
      updateAdminWriteAccess()

  publicChange: (event) ->
    event.preventDefault()
    @league.save(public: event.target.checked, {
      patch: true,
      wait: true
    }).always =>
      event.target.checked = @league.get('public')

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
