express = require 'express'
controller = require './controller'

router = express.Router()
router.post '/signUp', controller.signUp
router.post '/logIn', controller.logIn

module.exports = router