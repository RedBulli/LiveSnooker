class League extends Livesnooker.Model
  urlRoot: "/leagues"
  relations: [{
    type: Backbone.HasMany,
    key: 'Players',
    relatedModel: 'Player',
    collectionType: 'Players',
    reverseRelation: {
      key: 'league',
      includeInJSON: 'id'
    }
  }]

League.setup()

((scope) -> scope.League = League)(@)
