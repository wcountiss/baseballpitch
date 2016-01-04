express = require 'express'
controller = require './controller'

router = express.Router()
router.get '/', controller.currentUser

module.exports = router