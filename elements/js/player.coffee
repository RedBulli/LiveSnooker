class Player extends Livesnooker.Model
  urlRoot: "/players"

Player.setup()

((scope) -> scope.Player = Player)(@)
