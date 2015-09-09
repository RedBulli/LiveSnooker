data =
  authentication: null
  user: null
  host: null

apiIsReady = ->
  data.authentication && data.host

Polymer
  is: 'livesnooker-api'

  properties:
    host: String
    user: Object
    onAccount: Object

  findOrFetchModel: (klass, id) ->
    model = klass.findModel({id: id})
    if model
      Promise.resolve(model)
    else
      model = new klass({id: id})
      model.setApiClient(@)
      new Promise (resolve, reject) ->
        model.fetch
          success: ->
            resolve(model)
          error: reject

  created: ->
    @data = data

  setAuthentication: (auth) ->
    data.authentication = auth
    @maybeFetchUser()
    @fire('iron-signal', {name: "api-ready"}) if data.authentication # Prev async

  maybeFetchUser: ->
    @fetchUser() if data.host && data.authentication

  fetchUser: ->
    @ajax('/account').then (response) =>
      @setUser(response.user)

  setUser: (user) ->
    data.user = user
    this.fire('iron-signal', {name: "account", data: user}) # Prev async
    this.user = data.user

  ajax: (path, settings) ->
    _this = this
    if apiIsReady()
      this.ajaxPromise(path, settings)
    else
      new Promise (resolve, reject) ->
        _this.queue = true
        _this.addEventListener "api-ready", ->
          _this.ajaxPromise(path, settings).then(resolve, reject)

  ajaxPromise: (path, settings) ->
    Promise.resolve(this.ajaxCall(path, settings))

  callbackAjax: (path, settings) ->
    _this = this
    if apiIsReady()
      _this.ajaxCall(path, settings)
    else
      _this.addEventListener "api-ready", ->
        _this.ajaxCall(path, settings)

  ajaxCall: (path, settings) ->
    settings = settings || {}
    settings["headers"] = settings["headers"] || {}
    _.extend(settings.headers, {
      "X-AUTH-GOOGLE-ID-TOKEN": data.authentication["id_token"]
    })
    $.ajax(data.host + path, settings)

  onAccount: ->
    this.user = data.user

  onApiReady: ->
    this.fire('api-ready') # Prev async
    this.fire('api')

  ready: ->
    if this.host
      data.host = this.host
      this.fire('iron-signal', {name: "api-ready"}) if data.authentication # Prev async
    else if data.host
      this.host = data.host
    this.user = data.user
