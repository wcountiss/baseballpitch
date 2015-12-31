login = require '../../services/login'
jwt = require 'jsonwebtoken'

module.exports.logIn = (req, res) ->
  #simple validation, replace with parseModel later
  if !req.body.email || !req.body.password
    res.sendStatus(500)

  #logIn
  login.logIn(req.body.email, req.body.password)
  .then (user) ->
    if (user)
      token = jwt.sign(user, process.env.JWT_PASS)
      res.cookie('motus', token, { maxAge: 90*24*60*60*1000, signed: true })
      res.status(200).send(user)
    else
      res.sendStatus(401)
  .catch (error) ->
    console.log error
    res.status(500).send('user not found')

module.exports.forgotPassword = (req, res) ->
  #forgotPassword
  login.forgotPassword(req.body.email)
  .then () ->
    res.sendStatus(200)
  .catch (error) ->
    console.log error
    res.status(500).send('error requesting password reset')
