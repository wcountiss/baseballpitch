database = require '../../services/database'

module.exports.find = (req, res) -> 
  #get all Elite data
  database.find('Elite')
  .then (results) ->
    res.send(results)
  .catch (error) ->
    console.log error
    res.sendStatus(500)


 