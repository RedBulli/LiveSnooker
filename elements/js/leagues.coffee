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
    },
    {
      type: Backbone.HasMany,
      key: 'Admins',
      relatedModel: 'Admin',
      collectionType: 'Admins',
      reverseRelation:
        key: 'League'
        includeInJSON: 'LeagueId'
    }
  ]

  hasWriteAccess: (user) ->
    @get('Admins').find (admin) ->
      admin.get('UserEmail') == user.email && admin.get('write')

League.setup()

class Leagues extends Livesnooker.Collection
  model: League
  url: '/leagues'
  comparator: 'name'

((scope) ->
  scope.League = League
  scope.Leagues = Leagues
)(@)
