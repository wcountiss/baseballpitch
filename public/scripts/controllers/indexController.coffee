angular.module('georgeT').controller('IndexController', 
['$scope','$document'
  ($scope, $document) ->
    
    $scope.goTo = (anchor) ->
      $document.scrollToElement(angular.element(document.getElementById(anchor)), 0, 300);
])      
     