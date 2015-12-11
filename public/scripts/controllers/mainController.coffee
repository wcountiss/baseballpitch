angular.module('georgeT').controller('mainController', 
['$scope','$mobileCheck',
  ($scope, $mobileCheck) ->

    $scope.isMobile = $mobileCheck.isMobile()
    
])
      
     