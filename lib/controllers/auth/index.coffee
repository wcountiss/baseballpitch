express = require 'express'
controller = require './controller'

router = express.Router()
router.post '/logIn', controller.logIn

module.exports = router