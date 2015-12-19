express = require 'express'
controller = require './controller'

router = express.Router()
router.get '/save', controller.save
router.get '/find', controller.find

module.exports = router