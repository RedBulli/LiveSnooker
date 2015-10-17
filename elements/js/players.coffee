class Player extends Livesnooker.Model
  urlRoot: "/players"

Player.setup()

class Players extends Livesnooker.Collection
  model: Player
  url: '/players'
  comparator: 'name'

((scope) ->
  scope.Player = Player
  scope.Players = Players
)(@)
