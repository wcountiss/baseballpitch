express = require 'express'
controller = require './controller'

router = express.Router()
#get all Elite Data
router.get '/', controller.find

#find particular Elite Data
router.get '/find', controller.find


module.exports = router