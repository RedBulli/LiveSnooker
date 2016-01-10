promisify = (fn) ->
  new Promise (resolve, reject) ->
    fn({
      success: resolve,
      error: reject
    })

class League extends Livesnooker.Model
  @fetchWithRelations: (api, leagueId) ->
    api.findOrFetchModel(@, leagueId).then (league) ->
      league.setApiClient(api)
      league.get('Frames').leagueId = league.id
      league.get('Frames').setApiClient(api)
      league.get('Players').leagueId = league.id
      league.get('Players').setApiClient(api)
      league.get('Admins').leagueId = league.id
      league.get('Admins').setApiClient(api)
      Promise.all([
        promisify(league.get('Frames').fetch.bind(league.get('Frames'))),
        promisify(league.get('Players').fetch.bind(league.get('Players'))),
        promisify(league.get('Admins').fetch.bind(league.get('Admins')))
      ]).then ->
        league

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
