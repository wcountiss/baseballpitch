login = require '../services/login'

module.exports = (req,res,next) ->
  if (req.cookies.motus)
    login.logIn(req.cookies.motus.email, req.cookies.motus.password)
    .then (user) ->
      req.currentUser = user
      next()
  else
    res.sendStatus(401)
  


