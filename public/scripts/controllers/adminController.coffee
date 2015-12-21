angular.module('motus').controller('adminController', 
['$scope', '$http'
  ($scope, $http) ->
    $scope.savePlayer = () ->
      $http.post("player/save",  { teamId: $scope.teamId, playerName: $scope.playerName })
      .then (result) ->
        console.log result
      
])      
     