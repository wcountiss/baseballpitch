app = angular.module 'georgeT', ['ngRoute','ngCookies','d3', 'ngAnimate','duScroll','angular-carousel','scroll-animate-directive'],
  ($routeProvider, $locationProvider, $sceDelegateProvider) ->
    $sceDelegateProvider.resourceUrlWhitelist(["self"])
    $routeProvider
    .when "/",
      templateUrl: "/views/main.html",
      controller: 'mainController'
    .otherwise
      redirectTo: "/"

require './controllers/indexController.coffee'    
require './controllers/mainController.coffee'
