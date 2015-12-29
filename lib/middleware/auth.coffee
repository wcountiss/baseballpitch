jwt = require 'jsonwebtoken'

module.exports = (req,res,next) ->
  if (req.signedCookies?.motus)
    decoded = jwt.verify(req.signedCookies.motus, process.env.JWT_PASS);
    req.currentUser = decoded
    next()
  else
    res.sendStatus(401)
  


