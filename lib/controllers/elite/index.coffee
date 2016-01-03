express = require 'express'
controller = require './controller'

router = express.Router()
router.get '/all', controller.all

module.exports = router