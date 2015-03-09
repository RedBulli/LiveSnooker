_this = null
data =
  authentication: null
  user: null
  host: null

Polymer
  created: ->
    _this = this
    this.data = data

  setAutentication: (auth) ->
    data.authentication = auth
    this.maybeFetchUser()

  maybeFetchUser: ->
    this.fetchUser() if data.host && data.authentication

  fetchUser: ->
    this.ajax '/account',
      success: (response) ->
        _this.setUser(response.user)

  setUser: (user) ->
    data.user = user
    this.asyncFire('core-signal', {name: "authenticated", data: user})
    this.user = data.user

  ajax: (path, settings) ->
    settings = settings || {}
    settings["headers"] = settings["headers"] || {}
    _.extend(settings.headers, {
      "X-AUTH-GOOGLE-ID-TOKEN": data.authentication["id_token"]
    })
    $.ajax(data.host + path, settings)

  onAuth: ->
    this.user = data.user

  ready: ->
    data.host = this.host if this.host
    this.user = data.user
    this.addEventListener "google-auth", (auth) ->
      _this.setAutentication(auth.detail)
