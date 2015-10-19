class User extends Livesnooker.Model
  urlRoot: '/users'

class Users extends Livesnooker.Collection
  url: '/users'

class Admin extends Livesnooker.Model
  urlRoot: '/users'
  relations: [
    {
      type: Backbone.HasOne
      key: 'User'
      relatedModel: 'User'
      keyDestination: 'UserId'
      includeInJSON: 'id'
    }
  ]

class Admins extends Livesnooker.Collection
  url: '/users'

((scope) ->
  scope.User = User
  scope.Users = Users
  scope.Admin = Admin
  scope.Admins = Admins
)(@)
