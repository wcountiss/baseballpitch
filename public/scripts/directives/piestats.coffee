'use strict'
angular.module('d3').directive 'piestats', [
  'd3'
  (d3) ->
    {
      restrict: 'E'
      scope:
        width: '@'
        height: '@'
        fontFamily: '@'
        fontSize: '@'
        slices: '@'
        bind: '&'
        onClick: '&'
        onHover: '&'
      link: (scope, element, attrs) ->

        updateChart = ->
          width = 100
          height = 100
          scale = 1
          radius = Math.min(width, height) / 2
          innerRadius = 0.2 * radius
          if angular.isDefined(attrs.width)
            width = attrs.width
          if angular.isDefined(attrs.height)
            height = attrs.height
          tip = d3.tip()
          .attr('class', 'd3-tip pie-tip')
          .html((d) ->
            '<div ng-if="!d.data.tooltip" class="tip-rating ' + d.data.tooltip + '">' + d.data.tooltip + '</div><div class="tip-rating ' + d.data.tooltip + '">' + d.data.label + '</div><br><div class="d3-tip-player">Player: ' + Math.round(d.data.playerscore) + '<span> ' + d.data.unitmeasure + '</span></div><br><div class="d3-tip-label">Elite: ' + Math.round(d.data.eliteval) + '<span> ' + d.data.unitmeasure + '</span></div>'
          )
          pie = d3.layout.pie().sort(null).value((d) ->
            d.width
          )
          arc = d3.svg.arc().innerRadius(innerRadius).outerRadius((d) ->
            `var i`
            (radius - innerRadius) * d.data.score / 100.0 + innerRadius
          )
          
          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++
          svg = d3.select(element[0]).append('svg')
          .attr('width', width)
          .attr('height', height)
          .append('g')
          .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')
          svg.call tip
          
          if angular.isDefined(scope.bind())
            slices = scope.bind().length
            
            # Pass in number of slices
            if angular.isDefined(attrs.slices)
              slices = +attrs.slices
            data = scope.bind()
            
            # add empty slices
            numberOfSlices = data.length
            i = 0
            while i < slices - numberOfSlices
              data.push
                'order': 0
                'weight': 1
                'score': 100
                'label': ''
                'filler': true
              i++
            data.forEach (d) ->
              d.order = +d.order
              d.color = d.color
              d.weight = +d.weight
              d.score = +d.score
              d.width = +d.weight
              d.label = d.label
              return
            
            path = svg.selectAll('.solidArc')
            .data(pie(data))
            .enter()
            .append('path')
            .attr('fill', (d) -> d.data.color)
            .attr('class', 'solidArc')
            .style('opacity', (d) -> '0' if d.data.filler )
            .attr('d', arc).on('mouseover', (d) ->
              # do not show tip if there is no slice
              if d.data.opacity != 0
                tip.show d
              return
            ).on('mouseout', tip.hide)
            
            svg.append('circle')
            .attr('class', 'circle')
            .attr('fill', 'white')
            .attr('cx', 0)
            .attr('cy', 0)
            .attr 'r', 7
          return

        scope.$watch 'bind()', (->
          updateChart()
          return
        ), false
        return

    }
]