class Players extends Backbone.Collection
  model: Player

  getOtherPlayer: (playerId) ->
    if @length != 2
      throw new Error('getOtherPlayer is only defined to Players collection with 2 players')
    else
      @find((player) -> player.id != playerId)

((scope) -> scope.Players = Players)(@)
