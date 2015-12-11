angular.module('georgeT').controller('IndexController', 
['$scope','$document'
  ($scope, $document) ->
    
    $scope.showNav = () ->
      $scope.showNavigation = !$scope.showNavigation;

    $scope.goTo = (anchor) ->
      $scope.showNavigation = false;
      $document.scrollToElement(angular.element(document.getElementById(anchor)), 200, 300);
])      
     