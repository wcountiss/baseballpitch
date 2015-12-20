(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var app;

app = angular.module('motus', ['ui.router', 'ngCookies', 'd3', 'ngAnimate'], function($stateProvider, $urlRouterProvider, $sceDelegateProvider) {
  $sceDelegateProvider.resourceUrlWhitelist(["self"]);
  $urlRouterProvider.otherwise("/player");
  return $stateProvider.state('player', {
    url: "/player",
    templateUrl: "views/player.html",
    controller: 'playerController'
  });
});

require('./controllers/indexController.coffee');

require('./controllers/playerController.coffee');



},{"./controllers/indexController.coffee":2,"./controllers/playerController.coffee":3}],2:[function(require,module,exports){
angular.module('motus').controller('indexController', ['$scope', function($scope) {}]);



},{}],3:[function(require,module,exports){
angular.module('motus').controller('playerController', [
  '$scope', function($scope) {
    $scope.foot = [
      {
        id: "FIS",
        order: 1.1,
        score: 59,
        weight: 1,
        color: "#9E0041",
        label: "Fisheries"
      }, {
        id: "MAR",
        order: 1.3,
        score: 24,
        weight: 1,
        color: "#C32F4B",
        label: "Mariculture"
      }, {
        id: "AO",
        order: 2,
        score: 98,
        weight: 1,
        color: "#E1514B",
        label: "Artisanal Fishing Opportunities"
      }, {
        id: "NP",
        order: 3,
        score: 60,
        weight: 1,
        color: "#F47245",
        label: "Natural Products"
      }
    ];
    return $scope.overview = [
      {
        date: '1-May-12',
        close: 100.13
      }, {
        date: '30-Apr-12',
        close: 150.98
      }, {
        date: '27-Apr-12',
        close: 130.00
      }, {
        date: '26-Apr-12',
        close: 140.70
      }, {
        date: '25-Apr-12',
        close: 180.00
      }, {
        date: '24-Apr-12',
        close: 75.28
      }
    ];
  }
]);



},{}]},{},[1])