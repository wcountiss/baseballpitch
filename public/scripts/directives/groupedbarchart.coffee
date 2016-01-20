'use strict'
angular.module('d3').directive 'groupedbarchart', [
  'd3'
  '$window'
  (d3, $window) ->
    {
      restrict: 'E'
      scope:
        width: '@'
        height: '@'
        windowWidth: '@'
        text: '@'
        fontFamily: '@'
        fontSize: '@'
        bind: '&'
        onClick: '&'
        onHover: '&'
      link: (scope, element, attrs) ->
        updateChart = ->
          width = 960
          height = 500
          if angular.isDefined(attrs.width)
            if attrs.width.indexOf('%') > -1
              width = attrs.width.split('%')[0] / 100 * $window.innerWidth
            else
              width = attrs.width
          
          if angular.isDefined(attrs.height)
            height = attrs.height
          
          margin = 
            top: 20
            right: 20
            bottom: 30
            left: 50
          
          width = width - (margin.left) - (margin.right)
          height = height - (margin.top) - (margin.bottom)
          
          x0 = d3.scale.ordinal().rangeRoundBands([
            0
            width
          ], .1)
          x1 = d3.scale.ordinal()
          y = d3.scale.linear().range([
            height
            0
          ])

          color = d3.scale.ordinal().range([
            '#98abc5'
            '#8a89a6'
            '#7b6888'
            '#6b486b'
            '#a05d56'
            '#d0743c'
            '#ff8c00'
          ])
          xAxis = d3.svg.axis().scale(x0).orient('bottom')
          yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format('.2s'))

          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++
          
          svg = d3.select(element[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
          if angular.isDefined(scope.bind())
            
            bindData = scope.bind()
            data = _.cloneDeep(bindData)
            
            #tool tip
            tip = d3.tip().attr('class', 'd3-tip').html((d) ->
              '<div class="d3-tip-heading">' + _.humanize(data.heading) + '</div><div class="d3-tip-tooltip">' + parseFloat(d.value).toFixed(1) + ' ' + data.units + '</div><div class="d3-tip-label">' + _.humanize(d.name) + '</div>'
            )
            svg.call tip
            
            data.groups.forEach (d) ->
              d.groupData = data.keys.map((key) ->
                value = 0
                if d[key]
                  value = +d[key]
                {
                  name: key
                  value: value
                }
              )
              return
            x0.domain data.groups.map((d) ->
              d.date
            )
            x1.domain(data.keys).rangeRoundBands [
              0
              x0.rangeBand()
            ]
            ymin = d3.min(data.groups, (d) ->
              d3.min d.groupData, (d) ->
                d.value
            )
            if data.average < ymin
              ymin = data.average
            ymax = d3.max(data.groups, (d) ->
              d3.max d.groupData, (d) ->
                d.value
            )
            if data.average > ymax
              ymax = data.average
            y.domain [ymin, ymax]

            svg.append('g').attr('class', 'x axis').attr('transform', 'translate(0,' + height + ')').call xAxis
            svg.append('g').attr('class', 'y axis').call(yAxis).append('text').attr('transform', 'rotate(-90)').attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end').text data.units
            date = svg.selectAll('.date').data(data.groups).enter().append('g').attr('class', 'date').attr('transform', (d) ->
              'translate(' + x0(d.date) + ',0)'
            )
            
            date.selectAll('rect').data((d) ->
              d.groupData
            ).enter().append('rect').attr('width', x1.rangeBand()).attr('x', (d) ->
              x1 d.name
            ).attr('y', (d) ->
              y d.value
            ).attr('height', (d) ->
              height - y(d.value)
            )
            .attr('class', (d) -> d.name )
            .on('mouseover', (d) ->
              tip.show d
              return
            ).on 'mouseout', tip.hide
            
            # elite data
            svg.append('line').attr('x1', 0).attr('x2', d3.max(data.groups, (d) ->
              width
            )).attr('y1', (d) ->
              y data.average
            ).attr('y2', (d) ->
              y data.average
            ).attr('class', 'average').attr('stroke-width', 2).attr 'stroke', 'black'
          return

        scope.$watch 'bind()', (->
          updateChart()
          return
        ), false
        angular.element($window).bind 'resize', ->
          updateChart()
          return
        return

    }
]