_ = require 'lodash'
Promise = require 'bluebird'
Parse = require('parse/node')

Parse.initialize("7GO2ljMX3ZAogcE2hnEjggwRDnFPrs2uVtDDEaBM", "OcWFRuUQxR8Oq5kR48tUjPQ1jk81v9RBGMy2f9AR");

find = (collectionName, query) ->
  ParseObject = Parse.Object.extend(collectionName)
  parseQuery = new Parse.Query(ParseObject)
  _.each _.keys(query), (key) ->
    parseQuery.equalTo(key, query[key])
  return parseQuery.find()

save = (collectionName, data) ->
  ParseObject = Parse.Object.extend(collectionName)
  parseObject = new ParseObject()
  return new Promise (resolve, reject) ->
    parseObject.save(data)
    .then((success) -> resolve success, (error) -> reject error)

module.exports = () ->
  return {
    find,
    save
  }


