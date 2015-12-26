express = require 'express'
auth = require './lib/middleware/auth'

module.exports = (app) ->
  app.use(express.static('public/views', { maxAge: 3600000 })) #views
  app.use(express.static('public/build', { maxAge: 3600000 })) #minfied files
  app.use(express.static('public', { maxAge: 3600000 })) #views/images/fonts
  app.use(express.static('bower_components', { maxAge: 3600000 })) #bower

  app.use('/auth', require('./lib/controllers/auth'))

  app.use(auth)

  app.use('/player', require('./lib/controllers/player'))

