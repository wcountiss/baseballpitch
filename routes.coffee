express = require 'express'

module.exports = (app) ->
  app.use(express.static('public/views')) #views
  app.use(express.static('public')) #views/images/fonts
  app.use(express.static('public/build')) #minfied files
  app.use(express.static('bower_components')) #bower
