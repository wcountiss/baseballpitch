express = require 'express'
controller = require './controller'

router = express.Router()
router.get '/', controller.find
router.get '/find', controller.find


module.exports = router