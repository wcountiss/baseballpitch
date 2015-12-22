angular.module('motus').controller('playerController',
['$scope', '$http'
  ($scope, $http) ->
    # Random number to generate boolean for Roster list icon colors
    randomBoolean = () ->
      !(Math.random()+.5|0)
    randomNumber = (min, max) ->
      Math.floor(Math.random() * max+1 + min)

    colorOptions = [ '#FF0000', '#F6FB5E', '#29CE18' ]

    #hardcoded change to by login later
    $scope.teamId = 1

    #hardcoded stats, change to parse later
    $scope.playerDetail = {playerName: "Dario Alvarez", playerDob: "Jan 15, 1970", playerAge: 45, playerHeight: 72, playerWeight: 150, playerBirthPlace: "USA"}

    #random stats
    footScores = [
      { id: "FIS", order: 1, score: 100, weight: 1, label: "plant" }
      { id: "MAR", order: 2, score: 100, weight: 1, label: "movement" }
      { id: "AO", order: 3, score: 100, weight: 1, color: "#E1514B", label: "force" }
      { id: "NP", order: 4, score: 100, weight: 1, color: "#F47245", label: "push" }
    ]
    _.each footScores, (score) -> score.color = colorOptions[randomNumber(0,2)]
    $scope.foot = footScores

    $scope.overview = [
      { date: '1-May-12', close: 100.13 }
      { date: '30-Apr-12', close: 150.98 }
      { date: '27-Apr-12', close: 130.00 }
      { date: '26-Apr-12', close: 140.70 }
      { date: '25-Apr-12', close: 180.00 }
      { date: '24-Apr-12', close: 75.28 }
    ]

    getPlayers = () ->
      $http.post("player/find",  { teamId: $scope.teamId })
      .success (players) ->
        #loop through team and add roster booleans
        _.each (players), (player) ->
          player.longThrow = randomBoolean()            
          player.bullPen = randomBoolean()            
          player.base = randomBoolean()   
          player                 
        $scope.playerRoster = players

    #Page Load
    getPlayers()


])
