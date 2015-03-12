class Leagues extends Livesnooker.Collection
  model: League
  url: '/leagues'

((scope) -> scope.Leagues = Leagues)(@)
