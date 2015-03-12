class Model extends Backbone.Model
  setApiClient: (client) ->
    @client = client

  sync: (method, model, options) ->
    options = if options
      _.clone(options)
    else
      {}
    options.client = @client
    super(method, model, options)

((scope) ->
  scope.Livesnooker = {} unless scope.Livesnooker
  scope.Livesnooker.Model = Model
)(@)
