class Player extends Livesnooker.Model
  urlRoot: ->
    leagueId = @get('League')?.id || @get('LeagueId')
    "/leagues/" + leagueId + "/players"

  populateAssociations: ->
    @set('League', League.findModel(@get('LeagueId')))

Player.setup()

class Players extends Livesnooker.Collection
  model: Player
  url: ->
    "/leagues/" + @leagueId + "/players"
  comparator: 'name'

((scope) ->
  scope.Player = Player
  scope.Players = Players
)(@)
