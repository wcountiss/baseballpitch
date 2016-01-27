_ = require 'lodash'
Promise = require 'bluebird'
Parse = require('parse/node')

Parse.initialize(process.env.PARSE_APP_ID, process.env.PARSE_JS_KEY);


parseObjecttoObject = (parseObject) ->
  parseObject = JSON.stringify(parseObject)
  return JSON.parse(parseObject)

#generic finder method for database objects
#if performance is needed in future make new method that takes in a parsequery and runs it
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

    #Array of selected columns to return
    if query.select
      parseQuery.select(query.select.join(','))

    #paging
    if query.page
      parseQuery.skip(query.page)

    #what to include
    if query.include
      _.each query.include, (includeItem) ->
        parseQuery.include(includeItem)
  
  return new Promise (resolve, reject) ->
    parseQuery.find()
    .then(
      (results) ->
        if !options?.noParse
          results = parseObjecttoObject(results) 
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

