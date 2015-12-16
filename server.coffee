express = require 'express'
compression = require('compression')

app = express()

app.use(compression({threshold: 0;}))

require('./routes')(app)

port = process.env['PORT'] || 1979
app.listen port

console.log "George Toretta server listening on port #{port}"
