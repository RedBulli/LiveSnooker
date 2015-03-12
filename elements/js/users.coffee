class User extends Livesnooker.Model
  urlRoot: '/users'

class Users extends Livesnooker.Collection
  url: '/users'

((scope) ->
  scope.User = User
  scope.Users = Users
)(@)
