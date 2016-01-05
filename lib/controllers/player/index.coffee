express = require 'express'
controller = require './controller'

router = express.Router()
#get players you have access to
router.post '/', controller.find
#find players you have access to
router.post '/find', controller.find

module.exports = router