class Players extends Livesnooker.Collection
  model: Player
  url: '/players'

((scope) -> scope.Players = Players)(@)
