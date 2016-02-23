database = require '../../services/database'
login = require '../../services/login'
invitationKeyService = require '../../services/invitationKey'
jwt = require 'jsonwebtoken'
encrypt = require '../../services/encrypt'

#login sets cookie
module.exports.logIn = (req, res) ->
  #simple validation, replace with parseModel later
  if !req.body.email || !req.body.password
    res.sendStatus(500)

  #logIn
  login.logIn(req.body.email, req.body.password)
  .then (user) ->
    if (user)
      invitationKeyService.checkKey(user)
      .then (invitationKeyError) ->
        #errors if invitation Key is not right
        if invitationKeyError
          res.status(401).send(invitationKeyError)
          return 

        #all is good, make a login cookie
        encryptedUser = encrypt.encrypt(JSON.stringify(user))
        token = jwt.sign(encryptedUser, process.env.JWT_PASS)
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

module.exports.assignInvitationKey = (req, res) ->
  if !req.body.email || !req.body.password || !req.body.invitationKey
    res.sendStatus(500)

  #get who we are assigning the key to
  login.logIn(req.body.email, req.body.password)
  .then (user) ->
    if (user)
      invitationKeyService.assignInvitationKey(user, req.body.invitationKey)
      .then (invitationKeyError) ->
        console.log invitationKeyError
        #errors if invitation Key is not right
        if invitationKeyError
          res.status(401).send(invitationKeyError)
          return 

        res.sendStatus(200)
      .catch (error) ->
        console.log error
        res.sendStatus(500)
    else
      res.sendStatus(401)
  .catch (error) ->
    console.log error
    res.status(500).send('user not found')






