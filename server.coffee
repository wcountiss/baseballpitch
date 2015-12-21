express = require 'express'
compression = require('compression')
bodyParser = require('body-parser')

#express app
app = express()

#Parse Body for posts
app.use(bodyParser.json())
#Compress any static files under 1k
app.use(compression())

#load up routers
require('./routes')(app)

#listen on port
port = process.env['PORT'] || 2001
app.listen port

console.log "Motus server listening on port #{port}"
