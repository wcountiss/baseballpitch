angular.module('motus').factory('unauthorizedInterceptor', ($q) ->
  return {
   'responseError': (rejection) ->
      if rejection?.status == 401
        return window.location = '/'
      else
        return $q.reject(rejection);
  }
)