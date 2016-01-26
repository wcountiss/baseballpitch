angular.module('motus').filter 'rounded', ->
  (text) ->
    Math.round text
