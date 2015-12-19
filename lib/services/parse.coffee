Parse = require('parse/node');
Promise = require 'bluebird'

Parse.initialize("7GO2ljMX3ZAogcE2hnEjggwRDnFPrs2uVtDDEaBM", "OcWFRuUQxR8Oq5kR48tUjPQ1jk81v9RBGMy2f9AR");

# promise = (config) ->  
#   return new Promise (resolve, reject) ->
#     request config, (err, res, body) ->
#         if err
#           reject err
#         else
#           resolve body

save = (collectionName, data) ->
  ParseObject = Parse.Object.extend(collectionName);
  parseObject = new ParseObject();
  parseObject.save(data, {
    success: (object) ->
      console.log 'success'
    ,
    error: (model, error) ->
      console.log 'error'
  })

module.exports = () ->
  return {
    save
    
  }


