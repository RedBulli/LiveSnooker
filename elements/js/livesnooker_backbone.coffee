Backbone.ajax = (options) ->
  options.client.callbackAjax(options.url, _.omit(options, ['client', 'url']))

((scope) -> scope.Backbone = Backbone)(@)
