express = require 'express'

module.exports = (app) ->
  app.use(express.static('public/views', { maxAge: 86400000 })) #views
  app.use(express.static('public', { maxAge: 86400000 })) #views/images/fonts
  app.use(express.static('public/build', { maxAge: 86400000 })) #minfied files
  app.use(express.static('bower_components', { maxAge: 86400000 })) #bower
