angular.module('motus').controller('playerController', 
['$scope'
  ($scope) ->
    $scope.foot = [
      { id: "FIS", order: 1.1, score: 59, weight: 1, color: "#9E0041", label: "Fisheries" }
      { id: "MAR", order: 1.3, score: 24, weight: 1, color: "#C32F4B", label: "Mariculture" }
      { id: "AO", order: 2, score: 98, weight: 1, color: "#E1514B", label: "Artisanal Fishing Opportunities" }
      { id: "NP", order: 3, score: 60, weight: 1, color: "#F47245", label: "Natural Products" }
    ]

])      
     