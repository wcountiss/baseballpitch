angular.module('motus').controller('forgotPasswordController', 
['$http', '$state'
  ($http, $state) ->
    ctrl = this
    #forget password
    ctrl.forgotPassword = () ->
      $http.post("auth/forgotPassword",  { email: ctrl.email })
      .success (result) ->
        $state.go('login')
      .error (error) ->
        console.log error
        $state.go('error')

    return ctrl
])      
     