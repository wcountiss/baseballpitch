express = require 'express'
controller = require './controller'

router = express.Router()
#login to app 
#req.body.email req.body.password
router.post '/logIn', controller.logIn

#forgot Password
#req.body.email
router.post '/forgotPassword', controller.forgotPassword

module.exports = router