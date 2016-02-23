express = require 'express'
controller = require './controller'

router = express.Router()
#get players you have access to
router.post '/', controller.find
#find players you have access to
router.post '/find', controller.find
#assign invitation key
router.post '/assignInvitationKey', controller.assignInvitationKey


module.exports = router