angular.module('motus').controller('forgotPasswordController', 
['$scope','$http', '$state'
  ($scope, $http, $state) ->
    $scope.forgotPassword = () ->
      $http.post("auth/forgotPassword",  { email: $scope.email })
      .success (result) ->
        $state.go('login')
      .error (error) ->
        console.log error
])      
     