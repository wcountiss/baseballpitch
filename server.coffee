express = require 'express'
compression = require('compression')
bodyParser = require('body-parser')
cookieParser = require('cookie-parser')
sessions = require("client-sessions")

#express app
app = express()

#Compress any static files over 1k
app.use(compression())
#parse cookies
app.use(cookieParser(process.env.COOKIE_PASS))
#Parse Body for posts
app.use(bodyParser.json())

#sessions setup for invitationKey invalidation
app.use(sessions({
  cookieName: 'motusSession',
  secret: process.env.SESSION_COOKIE_PASS, 
  duration: 24 * 60 * 60 * 1000, 
  activeDuration: 1000 * 60 * 5 
  cookie: {
    ephemeral: false,
    httpOnly: true
  }
}))

#load up routers
require('./routes')(app)

#listen on port
port = process.env['PORT'] || 2001
app.listen port

console.log "Motus server listening on port #{port}"
