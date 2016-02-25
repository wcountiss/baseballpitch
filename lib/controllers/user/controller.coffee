login = require '../../services/login'
jwt = require 'jsonwebtoken'

#get logged in user
module.exports.currentUser = (req, res) ->
  #get who you are logged in as coming from the auth middleware
  res.status(200).send(req.currentUser)
