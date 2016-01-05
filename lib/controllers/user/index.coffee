express = require 'express'
controller = require './controller'

router = express.Router()
#get current user set in cookie
router.get '/', controller.currentUser

module.exports = router