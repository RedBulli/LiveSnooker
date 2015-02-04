class User extends Backbone.Model
  urlRoot: '/users'

class Users extends Backbone.Collection
  url: '/users'

((scope) ->
  scope.User = User
  scope.Users = Users
)(@)
