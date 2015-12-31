express = require 'express'
controller = require './controller'

router = express.Router()
router.post '/logIn', controller.logIn
router.post '/forgotPassword', controller.forgotPassword


module.exports = router