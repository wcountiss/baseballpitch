database = require '../../services/database'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });

#get elite metrics
module.exports.find = (req, res) -> 
  #try cache
  try
    results = cache.get("elite", true)
    res.send(results)
    return

  #get all Elite data
  database.find('Elite')
  .then (results) ->
    #cache
    cache.set( "elite", results)

    res.send(results)
  .catch (error) ->
    console.log error
    res.sendStatus(500)


 