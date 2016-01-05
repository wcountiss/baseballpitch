angular.module('motus').controller('playerController',
  ['$scope', '$http', 'currentPlayerFactory', '$state', '$player'
    ($scope, $http, currentPlayerFactory, $state, $player) ->
#Grab data from the factory service
      cpf = currentPlayerFactory
      randomNumber = (min, max) ->
        Math.floor(Math.random() * max + min)

      # Random number to generate boolean for Roster list icon colors
      colorOptions = [ '#f90b1c', '#ffaa22', '#00be76' ]
      toolTipOptions = [ 'Bad', 'Ok', 'Good' ]

      #random stats
      statNames = ['arm','throwShoulder','otherShoulder','hip','foot']
      statSlices = [10,10,9,8,6]
      _.each statNames, (stat, i) ->
        scores = [
          { order: 1, score: 100, weight: 1, label: "Rotation" }
          { order: 1, score: 100, weight: 1, label: "Movement" }
          { order: 1, score: 100, weight: 1, label: "Force" }
          { order: 1, score: 100, weight: 1, label: "Acceleration" }
          { order: 1, score: 100, weight: 1, label: "Timing" }
          { order: 1, score: 100, weight: 1, label: "Deceleration" }
          { order: 1, score: 100, weight: 1, label: "Velocity" }
          { order: 1, score: 100, weight: 1, label: "Momentum" }
          { order: 1, score: 100, weight: 1, label: "Distance" }
          { order: 1, score: 100, weight: 1, label: "Rate" }
        ]
        _.each scores, (score) ->
          randomNum = randomNumber(0,3)
          score.color = colorOptions[randomNum]
          score.tooltip = toolTipOptions[randomNum]
        #Number of slices
        score = _.slice(scores, 0, statSlices[i])
        $scope[stat] = score

      getPlayers = () ->
        $player.getPlayers()
        .then (players) ->
          console.log players
          pitches = ['right', 'left']
          position = ['starter', 'relief', 'closer']

          #loop through team and add roster booleans
          _.each (players), (player) ->
            #hardcoded stats, change to parse later
            player = _.extend(player, { age: _.random(20,40), height: _.random(65,80), weight: _.random(150,180), birthPlace: "USA", position: position[_.random(2)], level: 'mlb', pitches: pitches[_.random(1)], imgUrl: '../images/matt-harvey.png', alt: 'Matt Harvey'})

            player
          $scope.playerRoster = players
          #makes the first player in the list the selected player when the pages loads
          cpf.currentPlayer = players[0]
          $scope.currentPlayer = cpf.currentPlayer

      #Page Load
      getPlayers()
      $scope.selectedPlayer = (selected) ->
        cpf.currentPlayer = selected
        $scope.currentPlayer = cpf.currentPlayer
        myState = $state.current.name
        $state.reload(myState)

      # Icons for the Overview
      # Will highlight which one is active, and will eventually change the nested view here
      $scope.overviewActiveEyeIcon = true
      $scope.overviewActiveTrendsIcon = false

      # Sets the Eye as Active icon
      $scope.overviewActiveEye = () ->
        $scope.overviewActiveEyeIcon = true
        $scope.overviewActiveTrendsIcon = false

      # Sets the Trend chart as active
      $scope.overviewActiveTrend = () ->
        $scope.overviewActiveEyeIcon = false
        $scope.overviewActiveTrendsIcon = true

      # Side Buttons Initial State
      $scope.homeSideButtonActive = true
      $scope.trendsSideButtonActive = false
      $scope.kineticSideButtonActive = false
      $scope.ballreleaseSideButtonActive = false
      $scope.footcontactSideButtonActive = false
      $scope.maxexcursionSideButtonActive = false
      $scope.jointkineticsSideButtonActive = false

      # Side Button Functions
      # These functions change one button boolean to true, and others to false.

      # Set all Icons to false
      setAlltoFalse = ->
        $scope.homeSideButtonActive = false
        $scope.trendsSideButtonActive = false
        $scope.kineticSideButtonActive = false
        $scope.ballreleaseSideButtonActive = false
        $scope.footcontactSideButtonActive = false
        $scope.maxexcursionSideButtonActive = false
        $scope.jointkineticsSideButtonActive = false

      # Side button Home Active
      $scope.homeIsActive = () ->
        setAlltoFalse()
        $scope.homeSideButtonActive = true

      # Side button Trends Active
      $scope.trendsIsActive = () ->
        setAlltoFalse()
        $scope.trendsSideButtonActive = true

      # Side button Kinetic Chain Active
      $scope.kineticIsActive = () ->
        setAlltoFalse()
        $scope.kineticSideButtonActive = true

      # Side button Ballrelease Active
      $scope.ballreleaseIsActive = () ->
        setAlltoFalse()
        $scope.ballreleaseSideButtonActive = true

      # Side button Foot contact Active
      $scope.footcontactIsActive = () ->
        setAlltoFalse()
        $scope.footcontactSideButtonActive = true

      # Side button Max excursion Active
      $scope.maxexcursionIsActive = () ->
        setAlltoFalse()
        $scope.maxexcursionSideButtonActive = true

      # Side button Joint kinetics Active
      $scope.jointkineticsIsActive = () ->
        setAlltoFalse()
        $scope.jointkineticsSideButtonActive = true
  ])
