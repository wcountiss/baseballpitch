express = require 'express'
controller = require './controller'

router = express.Router()
router.get '/find', controller.find

module.exports = router