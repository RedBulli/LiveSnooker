class League extends Livesnooker.Model
  urlRoot: "/leagues"

  initialize: ->
    if not @get('players')
      @set('players', new Players([]))

((scope) -> scope.League = League)(@)
