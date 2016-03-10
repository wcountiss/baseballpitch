database = require '../../services/database'
NodeCache = require( "node-cache" );
cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });
_ = require 'lodash'

#clear elite metric cache
module.exports.clearCache = (req, res) -> 
  cache.flushAll()
  res.sendStatus(200)

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
    results = _.filter results, (result) ->
      result.metric != 'footAngle' && result.metric != 'peakForearmSpeedTime' && result.metric != 'peakBicepSpeedTime'
    #cache
    cache.set( "elite", results)

    res.send(results)
  .catch (error) ->
    console.log error
    res.sendStatus(500)


 