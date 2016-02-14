angular.module('motus').filter 'rounded', ->
  (text) ->
    if text == undefined
      return ""
    else
      Math.round text
