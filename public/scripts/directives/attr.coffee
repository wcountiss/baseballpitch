angular.module('georgeT').directive 'ngAttr', ->
  scope: list: '=ngAttr'
  link: (scope, elem, attrs) ->
    for attr of scope.list
      elem.attr scope.list[attr].attr, scope.list[attr].value