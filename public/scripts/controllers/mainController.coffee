angular.module('georgeT').controller('mainController', 
['$scope','$mobileCheck',
  ($scope, $mobileCheck) ->
    $scope.wordcloud = {}

    $scope.isMobile = $mobileCheck.isMobile()
    $scope.wordcloud.width = if $scope.isMobile then 300 else 500
    
])
      
     