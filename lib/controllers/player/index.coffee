express = require 'express'
controller = require './controller'

router = express.Router()
router.post '/all', controller.all

module.exports = router