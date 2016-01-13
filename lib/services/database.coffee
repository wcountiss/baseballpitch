_ = require 'lodash'
Promise = require 'bluebird'
Parse = require('parse/node')

Parse.initialize(process.env.PARSE_APP_ID, process.env.PARSE_JS_KEY);

removeNotUsedFields = (results) ->
  _.each results, (result) -> 
    delete result.sampleData
    delete result.compressionData
    delete result.timeSeriesForearmSpeed
    delete result.timeSeriesHipSpeed
    delete result.timeSeriesTrunkSpeed
    


parseObjecttoObject = (parseObject) ->
  parseObject = JSON.stringify(parseObject)
  return JSON.parse(parseObject)

#generic finder method
module.exports.find = (collectionName, query, options) ->
  ParseObject = Parse.Object.extend(collectionName)
  parseQuery = new Parse.Query(ParseObject)
  #set limit to max
  parseQuery.limit(1000)
  #query params
  #equal to
  if query
    _.each _.keys(query.equal), (key) ->
      if Array.isArray(query.equal[key])
        parseQuery.containedIn(key, query.equal[key])
      else
        parseQuery.equalTo(key, query.equal[key])

    #greater than
    _.each _.keys(query.greater), (key) ->
      parseQuery.greaterThanOrEqualTo(key, query.greater[key])

  #what to include
  if options?.include
    _.each options.include, (includeItem) ->
      parseQuery.include(includeItem)
  return new Promise (resolve, reject) ->
    parseQuery.find()
    .then(
      (results) ->
        if !options?.noParse
          results = parseObjecttoObject(results) 
        removeNotUsedFields(results)
        resolve results, 
      (error) -> 
        console.log error
        reject new Error(error.message)
    ) 

#generic save method
module.exports.save = (collectionName, data) ->
  ParseObject = Parse.Object.extend(collectionName)
  parseObject = new ParseObject()
  return new Promise (resolve, reject) ->
    parseObject.save(data)
    .then (
      (success) -> 
        resolve success, 
      (error) -> 
        reject new Error(error.message)
    )

