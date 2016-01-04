angular.module('motus').controller('forgotPasswordController', 
['$scope','$http'
  ($scope, $http) ->
    $scope.forgotPassword = () ->
      $http.post("auth/forgotPassword",  { email: $scope.email })
      .success (result) ->
        console.log result
      .error (error) ->
        console.log error
])      
     