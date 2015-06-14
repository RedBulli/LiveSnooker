class Frames extends Livesnooker.Collection
  model: Frame
  url: ->
    if @leagueId
      "/leagues/#{@leagueId}/frames"
    else
      "/frames"

((scope) -> scope.Frames = Frames)(@)
