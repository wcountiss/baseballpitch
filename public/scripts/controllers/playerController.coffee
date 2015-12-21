angular.module('motus').controller('playerController',
['$scope', '$http'
  ($scope, $http) ->
    #hardcoded change to by login later
    $scope.teamId = 1

    #hardcoded stats, change to parse later
    $scope.playerDetail = {playerName: "Dario Alvarez", playerDob: "Jan 15, 1970", playerAge: 45, playerHeight: 72, playerWeight: 150, playerBirthPlace: "USA"}

    $scope.foot = [
      { id: "FIS", order: 1.1, score: 59, weight: 1, color: "#9E0041", label: "Fisheries" }
      { id: "MAR", order: 1.3, score: 24, weight: 1, color: "#C32F4B", label: "Mariculture" }
      { id: "AO", order: 2, score: 98, weight: 1, color: "#E1514B", label: "Artisanal Fishing Opportunities" }
      { id: "NP", order: 3, score: 60, weight: 1, color: "#F47245", label: "Natural Products" }
    ]

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
      .success (result) ->
        console.log result
        $scope.playerRoster = result


    #Page Load
    getPlayers()


])
