angular.module('motus').controller('loginController', 
['$scope','$http','$cookies'
  ($scope, $http,$cookies) ->
    $scope.signUp = () ->
      $http.post("auth/signUp",  { email: $scope.email, password: $scope.password })
      .success (result) ->
        console.log result


    $scope.login = () ->
      $http.post("auth/login",  { email: $scope.email, password: $scope.password })
      .success (result) ->
        console.log result
])      
     