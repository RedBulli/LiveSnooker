_this = host = authentication = null
onAuthListeners = []

Polymer
  setAuthentication: (auth) ->
    authentication = auth
    _.each(onAuthListeners, (cb) -> cb(authentication))
    onAuthListeners = []

  ajax: (path, settings) ->
    settings = settings || {}
    settings["headers"] = settings["headers"] || {}
    _.extend(settings.headers, {
      "X-AUTH-GOOGLE-ID-TOKEN": authentication["id_token"]
    })
    $.ajax(host + path, settings)

  onAuth: (callback) ->
    unless authentication
      onAuthListeners.push(callback)
    else
      callback(authentication)

  ready: ->
    host = this.host if this.host 
    _this = this
