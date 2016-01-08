express = require 'express'
auth = require './lib/middleware/auth'

module.exports = (app) ->
  app.use(express.static('public/build', { maxAge: 0 })) #compiled files
  app.use(express.static('public', { maxAge: 0 })) #views/images/fonts
  app.use(express.static('bower_components', { maxAge: 0 })) #bower
  #Dev build for livereload, prod uses views
  app.use(express.static('public/build/views', { maxAge: 0 })) #compiled views
  app.use(express.static('public/views', { maxAge: 0 })) #views

  app.use('/auth', require('./lib/controllers/auth'))

  app.use(auth)

  app.use('/user', require('./lib/controllers/user'))
  app.use('/pitch', require('./lib/controllers/pitch'))
  app.use('/player', require('./lib/controllers/player'))
  app.use('/elite', require('./lib/controllers/elite'))

