express = require 'express'
controller = require './controller'

router = express.Router()
router.post '/findByAthleteProfiles', controller.findByAthleteProfiles

module.exports = router