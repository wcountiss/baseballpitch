express = require 'express'
auth = require './lib/middleware/auth'

module.exports = (app) ->
  app.use(express.static('public/build', { maxAge: 3600000 })) #compiled files
  app.use(express.static('public', { maxAge: 3600000 })) #views/images/fonts
  app.use(express.static('bower_components', { maxAge: 3600000 })) #bower
  #Dev build for livereload, prod uses views
  app.use(express.static('public/build/views', { maxAge: 3600000 })) #compiled views
  app.use(express.static('public/views', { maxAge: 3600000 })) #views

  app.use('/auth', require('./lib/controllers/auth'))

  app.use(auth)

  app.use('/player', require('./lib/controllers/player'))

