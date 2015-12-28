_ = require 'lodash'
Promise = require 'bluebird'
Parse = require('parse/node')

Parse.initialize(process.env.PARSE_APP_ID, process.env.PARSE_JS_KEY);

module.exports.find = (collectionName, query) ->
  ParseObject = Parse.Object.extend(collectionName)
  parseQuery = new Parse.Query(ParseObject)
  _.each _.keys(query), (key) ->
    parseQuery.equalTo(key, query[key])
  return new Promise (resolve, reject) ->
    parseQuery.find()
    .then((success) -> resolve success, (error) ->  eject error) 


module.exports.save = (collectionName, data) ->
  ParseObject = Parse.Object.extend(collectionName)
  parseObject = new ParseObject()
  return new Promise (resolve, reject) ->
    parseObject.save(data)
    .then((success) -> resolve success, (error) -> reject error)

