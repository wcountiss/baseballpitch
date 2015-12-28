jwt = require 'jsonwebtoken'

module.exports = (req,res,next) ->
  if (req.cookies.motus)
    decoded = jwt.verify(req.cookies.motus, process.env.JWT_PASS);
    req.currentUser = decoded
    next()
  else
    res.sendStatus(401)
  


