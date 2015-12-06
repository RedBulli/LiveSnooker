data =
  authentication: null
  user: null
  host: null
  anonymous: false

apiIsReady = ->
  (data.authentication || data.anonymous) && data.host

authIsReady = ->
  data.host && data.authentication

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

  onGoogleSignIn: (event, auth) ->
    if data.authentication != auth
      @setAuthentication(auth)
      @maybeFetchUser()
      @fire('iron-signal', {name: "api-ready"}) if apiIsReady()

  maybeFetchUser: ->
    @fetchUser() if authIsReady()

  fetchUser: ->
    @ajax('/account').then (response) =>
      @setUser(response.user)

  setUser: (user) ->
    data.user = user
    @fire('iron-signal', {name: "account", data: user})
    @user = data.user

  setHost: (host) ->
    @host = host
    data.host = host

  setAuthentication: (authentication) ->
    data.authentication = authentication

  ajax: (path, settings) ->
    if apiIsReady()
      @ajaxPromise(path, settings)
    else
      new Promise (resolve, reject) =>
        @queue = true
        @addEventListener "api-ready", =>
          @ajaxPromise(path, settings).then(resolve, reject)

  ajaxPromise: (path, settings) ->
    Promise.resolve(@ajaxCall(path, settings))

  callbackAjax: (path, settings) ->
    if apiIsReady()
      @ajaxCall(path, settings)
    else
      @addEventListener "api-ready", =>
        @ajaxCall(path, settings)

  ajaxCall: (path, settings) ->
    settings = settings || {}
    settings["headers"] = settings["headers"] || {}
    if data.authentication
      _.extend settings.headers,
        "X-AUTH-GOOGLE-ID-TOKEN": data.authentication["id_token"]
    $.ajax(data.host + path, settings)

  onAccount: ->
    @user = data.user

  onApiReady: ->
    @fire('api-ready')
    @fire('api')

  useAnonymously: ->
    data.anonymous = true
    @fire('iron-signal', {name: "api-ready"}) if apiIsReady()

  ready: ->
    if @host
      @setHost(@host)
      @fire('iron-signal', {name: "api-ready"}) if apiIsReady()
    else if data.host
      @host = data.host
    @user = data.user
