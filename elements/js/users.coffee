class User extends Livesnooker.Model
  idAttribute: "email"

User.setup()

class Users extends Livesnooker.Collection
  model: User

class Admin extends Livesnooker.Model
  urlRoot: ->
    "/leagues/#{@get('LeagueId')}/admins"

Admin.setup()

class Admins extends Livesnooker.Collection
  model: Admin
  url: ->
    "/leagues/#{@get('LeagueId')}/admins"

((scope) ->
  scope.User = User
  scope.Users = Users
  scope.Admin = Admin
  scope.Admins = Admins
)(@)
