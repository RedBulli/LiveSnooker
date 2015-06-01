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
      collectionType: 'Frames'
    }
  ]

League.setup()

((scope) -> scope.League = League)(@)
