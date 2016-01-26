angular.module('motus').filter 'rounded', ->
  (text) ->
    if text == undefined
      return "Calculating.."
    else
    Math.round text
