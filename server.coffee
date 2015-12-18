express = require 'express'
compression = require('compression')

#express app
app = express()

#Compress any static files under 1k
app.use(compression())

#load up routers
require('./routes')(app)

#listen on port
port = process.env['PORT'] || 2001
app.listen port

console.log "Motus server listening on port #{port}"
