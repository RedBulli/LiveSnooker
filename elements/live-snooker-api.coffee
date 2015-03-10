data =
  authentication: null
  user: null
  host: null

Polymer
  created: ->
    this.data = data

  setAutentication: (auth) ->
    data.authentication = auth
    this.maybeFetchUser()
    this.asyncFire('core-signal', {name: "authenticated"})

  maybeFetchUser: ->
    this.fetchUser() if data.host && data.authentication

  fetchUser: ->
    _this = this
    this.ajax('/account').then (response) ->
      _this.setUser(response.user)

  setUser: (user) ->
    data.user = user
    this.asyncFire('core-signal', {name: "account", data: user})
    this.user = data.user

  ajax: (path, settings) ->
    _this = this
    if data.authentication
      this.ajaxPromise(path, settings)
    else
      new Promise (resolve, reject) ->
        _this.addEventListener "api-ready", ->
          _this.ajaxPromise(path, settings).then(resolve, reject)

  ajaxPromise: (path, settings) ->
    settings = settings || {}
    settings["headers"] = settings["headers"] || {}
    _.extend(settings.headers, {
      "X-AUTH-GOOGLE-ID-TOKEN": data.authentication["id_token"]
    })
    Promise.resolve($.ajax(data.host + path, settings))

  onAccount: ->
    this.user = data.user

  onAuth: ->
    this.fire('authenticated')
    this.asyncFire('core-signal', {name: "api-ready"}) if data.host

  onHost: ->
    this.asyncFire('core-signal', {name: "api-ready"}) if data.authentication

  onApiReady: ->
    this.fire('api-ready')

  ready: ->
    if this.host
      data.host = this.host if this.host
      this.asyncFire('core-signal', {name: "host-set"})
    this.user = data.user
    _this = this
    this.addEventListener "google-auth", (auth) ->
      _this.setAutentication(auth.detail)
