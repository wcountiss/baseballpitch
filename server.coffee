express = require 'express'
compression = require('compression')
bodyParser = require('body-parser')
cookieParser = require('cookie-parser')

#express app
app = express()

#Compress any static files over 1k
app.use(compression())
#parse cookies
app.use(cookieParser(process.env.COOKIE_PASS))
#Parse Body for posts
app.use(bodyParser.json())

#load up routers
require('./routes')(app)

#listen on port
port = process.env['PORT'] || 2001
app.listen port

console.log "Motus server listening on port #{port}"
