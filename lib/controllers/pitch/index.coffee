express = require 'express'
controller = require './controller'

router = express.Router()
#get all pitches you have access to
router.post '/', controller.find

#find pitches you have access to
router.post '/find', controller.find

#find pitches with timing data
router.post '/findPitchTimingByAtheleteProfileId', controller.findPitchTimingByAtheleteProfileId 

module.exports = router