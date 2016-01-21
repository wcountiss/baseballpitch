angular.module 'motus', [
  'ngAnimate'
  'ui.bootstrap'
]
angular.module('motus').controller 'ComparisonModalCtrl', ($scope, $uibModal, $log) ->
  
  $scope.items = [
    'item1'
    'item2'
    'item3'
  ]
  $scope.animationsEnabled = true

  $scope.open = (size) ->
    modalInstance = $uibModal.open(
      animation: $scope.animationsEnabled
      templateUrl: 'myModalContent.html'
      controller: 'ModalInstanceCtrl'
      size: size
      resolve: items: ->
        $scope.items
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.selected = selectedItem
      return
    ), ->
      $log.info 'Modal dismissed at: ' + new Date
      return
    return

  $scope.toggleAnimation = ->
    $scope.animationsEnabled = !$scope.animationsEnabled
    return

  return
# Please note that $modalInstance represents a modal window (instance) dependency.
# It is not the same as the $uibModal service used above.
angular.module('ui.bootstrap.demo').controller 'ModalInstanceCtrl', ($scope, $uibModalInstance, items) ->
  $scope.items = items
  $scope.selected = item: $scope.items[0]

  $scope.ok = ->
    $uibModalInstance.close $scope.selected.item
    return

  $scope.cancel = ->
    $uibModalInstance.dismiss 'cancel'
    return

  return