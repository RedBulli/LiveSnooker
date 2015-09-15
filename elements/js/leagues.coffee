class League extends Livesnooker.Model
  urlRoot: "/leagues"
  relations: [
    {
      type: Backbone.HasMany,
      key: 'Players',
      relatedModel: 'Player',
      collectionType: 'Players',
      reverseRelation: {
        key: 'League',
        includeInJSON: 'LeagueId'
      }
    },
    {
      type: Backbone.HasMany,
      key: 'Frames',
      relatedModel: 'Frame',
      collectionType: 'Frames',
      reverseRelation:
        key: 'League'
        includeInJSON: 'id'
        keyDestination: 'LeagueId'
    }
  ]

League.setup()

class Leagues extends Livesnooker.Collection
  model: League
  url: '/leagues'

((scope) ->
  scope.League = League
  scope.Leagues = Leagues
)(@)
