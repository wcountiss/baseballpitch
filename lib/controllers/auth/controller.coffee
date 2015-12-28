login = require '../../services/login'
jwt = require 'jsonwebtoken'

module.exports.signUp = (req, res) ->
  #simple validation, replace with parseModel later
  if !req.body.email || !req.body.password
    res.sendStatus(500)

  #Sign the user Up
  login.signUp(req.body.email, req.body.password)
  .then (object) ->
    res.sendStatus(200)
  .error (error) ->
    console.log error
    res.sendStatus(500)

module.exports.logIn = (req, res) ->
  #simple validation, replace with parseModel later
  if !req.body.email || !req.body.password
    res.sendStatus(500)

  #logIn
  login.logIn(req.body.email, req.body.password)
  .then (user) ->
    if (user)
      token = jwt.sign(user, process.env.JWT_PASS)
      res.cookie('motus', token, { maxAge: 90*24*60*60*1000, httpOnly: false })
      res.status(200).send(user)
    else
      res.sendStatus(401)
  .error (user,error) ->
    console.log error
    res.sendStatus(500)
