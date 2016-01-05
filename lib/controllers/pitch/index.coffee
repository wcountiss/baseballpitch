express = require 'express'
controller = require './controller'

router = express.Router()
#get all pitches you have access to
router.post '/', controller.find

#find pitches you have access to
router.post '/find', controller.find

module.exports = router