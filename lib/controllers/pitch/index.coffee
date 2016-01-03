express = require 'express'
controller = require './controller'

router = express.Router()
router.post '/', controller.find
router.post '/find', controller.find

module.exports = router