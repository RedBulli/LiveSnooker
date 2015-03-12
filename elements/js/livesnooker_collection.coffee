class Collection extends Backbone.Collection
  setApiClient: (client) ->
    @client = client    

((scope) ->
  scope.Livesnooker = {} unless scope.Livesnooker
  scope.Livesnooker.Collection = Collection
)(@)
