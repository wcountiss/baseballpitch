_ = require 'lodash'
Promise = require 'bluebird'
Parse = require('parse/node')

Parse.initialize("7GO2ljMX3ZAogcE2hnEjggwRDnFPrs2uVtDDEaBM", "OcWFRuUQxR8Oq5kR48tUjPQ1jk81v9RBGMy2f9AR");

module.exports.logIn = (email, password) ->
  return new Promise (resolve, reject) ->
    Parse.User.logIn(email, password, {
      success: (user) -> resolve user.attributes,
      error: (user, error) -> 
        console.log("Error: " + error.code + " " + error.message); 
        reject(new Error('user not found'))
    });
