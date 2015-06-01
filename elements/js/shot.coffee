sequences = {}
sequence = (name) ->
  current = sequences[name] || 0
  sequences[name] = current + 1

class Shot extends Livesnooker.Model
  urlRoot: "/shots"
  relations: [
    {
      type: Backbone.HasOne,
      key: 'Player',
      relatedModel: 'Player',
      keyDestination: 'PlayerId',
      includeInJSON: 'id'
    },
    {
      type: Backbone.HasOne,
      key: 'Frame',
      relatedModel: 'Frame',
      keyDestination: 'FrameId',
      includeInJSON: 'id'
    }
  ]

  initialize: ->
    @set('id', sequence('shot'))

  isPot: ->
    @get('result') == 'pot'

  validate: (attrs) ->
    if attrs.result == "pot" && attrs.points == 0
      "Shot result cannot be a pot with 0 points"

((scope) -> scope.Shot = Shot)(@)
