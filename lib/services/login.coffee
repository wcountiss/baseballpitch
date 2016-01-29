_ = require 'lodash'
Promise = require 'bluebird'
Parse = require('parse/node')
database = require './database'
NodeCache = require( "node-cache" );

cache = new NodeCache({ stdTTL: 60 * 60 * 24 * 90 });


Parse.initialize(process.env.PARSE_APP_ID, process.env.PARSE_JS_KEY)

#gets the current user
module.exports.getUser = (userObjectId) ->
  return new Promise (resolve, reject) ->
   #try cache
    try
      user = cache.get("user#{userObjectId}", true)
      resolve user
      return

    userQuery = new Parse.Query(Parse.User);
    userQuery.equalTo("objectId", userObjectId);
    userQuery.first({
      success: (user) ->
        #cache
        cache.set( "user#{userObjectId}", user)
        resolve user
      ,
      error: (error) ->
        console.log error
        reject error
    })

#logs user in by email/password
module.exports.logIn = (email, password) ->
  return new Promise (resolve, reject) ->
    Parse.User.logIn(email, password, {
      success: (user) ->
        user.fetch()
        .then((user) ->
          resolve user
        ,(error) ->
          console.log error
        )
      error: (user, error) -> 
        console.log("Error: " + error.code + " " + error.message); 
        reject(new Error('user not found'))
    });

#forgot password sends link to reset password from Parse
module.exports.forgotPassword = (email) ->
  return new Promise (resolve, reject) ->
    Parse.User.requestPasswordReset(email, {
      success: () -> resolve(),
      error: (error) -> 
        console.log("Error: " + error.code + " " + error.message); 
        reject(new Error('Error requesting password reset'))
    });
