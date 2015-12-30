(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var app;

app = angular.module('motus', ['ui.router', 'ngCookies', 'd3', 'ngAnimate'], function($stateProvider, $urlRouterProvider, $sceDelegateProvider) {
  $sceDelegateProvider.resourceUrlWhitelist(["self"]);
  $stateProvider.state('login', {
    url: "/login",
    templateUrl: "views/login.html",
    controller: 'loginController',
    authenticate: false
  }).state('player', {
    url: "/player",
    templateUrl: "views/player.html",
    controller: 'playerController',
    authenticate: true
  }).state('admin', {
    url: "/admin",
    templateUrl: "views/admin.html",
    controller: 'adminController',
    authenticate: true
  });
  return $urlRouterProvider.otherwise("/player");
});

app.run(function($rootScope, $state, $cookies) {
  return $rootScope.$on("$stateChangeStart", function(event, toState, toParams, fromState, fromParams) {
    if (toState.authenticate && !$cookies.get('motus')) {
      $state.go("login");
      return event.preventDefault();
    }
  });
});

require('./controllers/indexController.coffee');

require('./controllers/playerController.coffee');

require('./controllers/loginController.coffee');

require('./controllers/adminController.coffee');



},{"./controllers/adminController.coffee":2,"./controllers/indexController.coffee":3,"./controllers/loginController.coffee":4,"./controllers/playerController.coffee":5}],2:[function(require,module,exports){
angular.module('motus').controller('adminController', [
  '$scope', '$http', function($scope, $http) {
    return $scope.savePlayer = function() {
      return $http.post("player/save", {
        teamId: $scope.teamId,
        playerName: $scope.playerName
      }).then(function(result) {
        return console.log(result);
      });
    };
  }
]);



},{}],3:[function(require,module,exports){
angular.module('motus').controller('indexController', [
  '$scope', '$state', '$cookies', function($scope, $state, $cookies) {
    $scope.state = $state;
    return $scope.logOut = function() {
      $cookies.remove('motus');
      return $state.go('login');
    };
  }
]);



},{}],4:[function(require,module,exports){
angular.module('motus').controller('loginController', [
  '$scope', '$http', '$cookies', '$state', function($scope, $http, $cookies, $state) {
    $scope.signUp = function() {
      return $http.post("auth/signUp", {
        email: $scope.email,
        password: $scope.password
      }).success(function(result) {
        return console.log(result);
      });
    };
    return $scope.login = function() {
      return $http.post("auth/login", {
        email: $scope.email,
        password: $scope.password
      }).success(function(result) {
        return $state.go('player');
      });
    };
  }
]);



},{}],5:[function(require,module,exports){
angular.module('motus').controller('playerController', [
  '$scope', '$http', function($scope, $http) {
    var colorOptions, getPlayers, randomBoolean, randomNumber, setAlltoFalse, statNames, statSlices, toolTipOptions;
    randomBoolean = function() {
      return !(Math.random() + .5 | 0);
    };
    randomNumber = function(min, max) {
      return Math.floor(Math.random() * max + min);
    };
    colorOptions = ['#e35746', '#ffe966', '#00a339'];
    toolTipOptions = ['Bad', 'Ok', 'Good'];
    $scope.teamId = 1;
    statNames = ['arm', 'throwShoulder', 'otherShoulder', 'hip', 'foot'];
    statSlices = [10, 10, 9, 8, 6];
    _.each(statNames, function(stat, i) {
      var score, scores;
      scores = [
        {
          order: 1,
          score: 100,
          weight: 1,
          label: "Rotation"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Movement"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Force"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Acceleration"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Timing"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Deceleration"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Velocity"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Momentum"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Distance"
        }, {
          order: 1,
          score: 100,
          weight: 1,
          label: "Rate"
        }
      ];
      _.each(scores, function(score) {
        var randomNum;
        randomNum = randomNumber(0, 3);
        score.color = colorOptions[randomNum];
        return score.tooltip = toolTipOptions[randomNum];
      });
      score = _.slice(scores, 0, statSlices[i]);
      return $scope[stat] = score;
    });
    getPlayers = function() {
      return $http.post("player/find", {
        teamId: $scope.teamId
      }).success(function(players) {
        var pitches, position;
        pitches = ['right', 'left'];
        position = ['starter', 'relief', 'closer'];
        _.each(players, function(player) {
          player.longThrow = randomBoolean();
          player.bullPen = randomBoolean();
          player.base = randomBoolean();
          player = _.extend(player, {
            age: _.random(20, 40),
            height: _.random(65, 80),
            weight: _.random(150, 180),
            birthPlace: "USA",
            position: position[_.random(2)],
            level: 'mlb',
            pitches: pitches[_.random(1)],
            imgUrl: '../images/matt-harvey.png',
            alt: 'Matt Harvey'
          });
          return player;
        });
        $scope.playerRoster = players;
        return $scope.currentPlayer = players[0];
      });
    };
    getPlayers();
    $scope.selectedPlayer = function(selected) {
      console.log("clicked");
      return $scope.currentPlayer = selected;
    };
    $scope.overviewActiveEyeIcon = true;
    $scope.overviewActiveTrendsIcon = false;
    $scope.overviewActiveEye = function() {
      $scope.overviewActiveEyeIcon = true;
      return $scope.overviewActiveTrendsIcon = false;
    };
    $scope.overviewActiveTrend = function() {
      $scope.overviewActiveEyeIcon = false;
      return $scope.overviewActiveTrendsIcon = true;
    };
    $scope.homeSideButtonActive = true;
    $scope.trendsSideButtonActive = false;
    $scope.kineticSideButtonActive = false;
    $scope.ballreleaseSideButtonActive = false;
    $scope.footcontactSideButtonActive = false;
    $scope.maxexcursionSideButtonActive = false;
    $scope.jointkineticsSideButtonActive = false;
    setAlltoFalse = function() {
      $scope.homeSideButtonActive = false;
      $scope.trendsSideButtonActive = false;
      $scope.kineticSideButtonActive = false;
      $scope.ballreleaseSideButtonActive = false;
      $scope.footcontactSideButtonActive = false;
      $scope.maxexcursionSideButtonActive = false;
      return $scope.jointkineticsSideButtonActive = false;
    };
    $scope.homeIsActive = function() {
      setAlltoFalse();
      return $scope.homeSideButtonActive = true;
    };
    $scope.trendsIsActive = function() {
      setAlltoFalse();
      return $scope.trendsSideButtonActive = true;
    };
    $scope.kineticIsActive = function() {
      setAlltoFalse();
      return $scope.kineticSideButtonActive = true;
    };
    $scope.ballreleaseIsActive = function() {
      setAlltoFalse();
      return $scope.ballreleaseSideButtonActive = true;
    };
    $scope.footcontactIsActive = function() {
      setAlltoFalse();
      return $scope.footcontactSideButtonActive = true;
    };
    $scope.maxexcursionIsActive = function() {
      setAlltoFalse();
      return $scope.maxexcursionSideButtonActive = true;
    };
    return $scope.jointkineticsIsActive = function() {
      setAlltoFalse();
      return $scope.jointkineticsSideButtonActive = true;
    };
  }
]);



},{}]},{},[1])