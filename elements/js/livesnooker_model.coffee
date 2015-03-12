class Model extends Backbone.Model
  setApiClient: (client) ->
    @client = client    

((scope) ->
  scope.Livesnooker = {} unless scope.Livesnooker
  scope.Livesnooker.Model = Model
)(@)
