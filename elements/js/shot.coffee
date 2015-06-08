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

  isPot: ->
    @get('result') == 'pot'

  validate: (attrs) ->
    if attrs.result == "pot" && attrs.points == 0
      "Shot result cannot be a pot with 0 points"

  populateAssociations: ->
    @set('Player', Player.findModel(@get('PlayerId')))
    @set('Frame', Frame.findModel(@get('FrameId')))

((scope) -> scope.Shot = Shot)(@)
