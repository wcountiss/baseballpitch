'use strict'
angular.module('d3').directive 'groupedbarchart', [
  'd3'
  '$window'
  '$timeout'
  (d3, $window, $timeout) ->
    {
      restrict: 'E'
      scope:
        width: '@'
        height: '@'
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
            right: 50
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

          xAxis = d3.svg.axis().scale(x0).orient('bottom')
          yAxis = d3.svg.axis().scale(y).orient('left')

          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++
          
          svg = d3.select(element[0]).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom + 50).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
          if scope.bind()
            
            bindData = scope.bind()
            data = _.cloneDeep(bindData)

            #absolute type
            if data.yType == 1
              data.average = Math.abs(data.average)
              _.each data.groups, (group) ->
                _.each data.keys, (tag) ->
                  group[tag] = Math.abs(group[tag])

            #tool tip
            permaTip = d3.tip().attr('class', 'd3-tip d3-timp-perma').html((d) ->
              '<div class="d3-tip-heading">' + _.humanize(data.heading) + '</div><div class="d3-tip-tooltip">' + parseFloat(d.value).toFixed(0) + ' ' + data.units + '</div><div class="d3-tip-label">' + _.humanize(d.name) + '</div><div class="eliteavg">Elite: ' + Math.round(data.average) + ' ' + data.units + '</div>'
            )
            svg.call permaTip

            tip = d3.tip().attr('class', 'd3-tip').html((d) ->
              '<div class="d3-tip-heading">' + _.humanize(data.heading) + '</div><div class="d3-tip-tooltip">' + parseFloat(d.value).toFixed(0) + ' ' + data.units + '</div><div class="d3-tip-label">' + _.humanize(d.name) + '</div><div class="eliteavg">Elite: ' + Math.round(data.average) + ' ' + data.units + '</div>'
            )
            svg.call tip
            
            data.groups.forEach (d) ->
              d.groupData = data.keys.map((key) ->
                value = null
                if d[key]
                  value = +d[key]
                return {
                  name: key
                  value: value
                  group: d.date
                }
              )
              return
            x0.domain data.groups.map((d) -> d.date )
            x1.domain(data.keys).rangeRoundBands [0,x0.rangeBand()]
            
            #set yxis to 0 or min - 1 if under 0 to whichever is higher max value or average 
            ymin = 0
            minValue = d3.min(data.groups, (d) ->
              d3.min d.groupData, (d) ->
                d.value
            )
            if minValue < 0
              ymin = minValue - 1

            if data.average > 0
              ymax = d3.max(data.groups, (d) ->
                d3.max d.groupData, (d) ->
                  d.value
              )
              if data.average > ymax
                ymax = data.average
            else 
               ymax = d3.min(data.groups, (d) ->
                d3.min d.groupData, (d) ->
                  d.value
              )
              if data.average < ymax
                ymax = data.average

            #if passed in
            if data.yMin?
              ymin = data.yMin
            if data.yMax?
              ymax = data.yMax

            y.domain [ymin, ymax]

            #background lines
            svg.append("g")      
            .attr("class", "grid")
            .call(d3.svg.axis().scale(y).orient('left')
              .tickSize(-width, 0, 0)
              .tickFormat("")
            )            

            svg.append('g').attr('class', 'x axis')
              .attr('transform', 'translate(0,' + height + ')')
              .call(xAxis)
              .selectAll("text")
              .attr('transform', 'translate(22,18) rotate(45)')
            
            svg.append('g')
            .attr('class', 'y axis')
            .call(yAxis)
            .append('text')
            .attr('transform', 'rotate(-90)')
            .attr('y', 9).attr('y', '-3.8em')
            .style('text-anchor', 'end')
            .text data.units
            
            date = svg.selectAll('.date')
            .data(data.groups)
            .enter().append('g')
            .attr('class', 'date')
            .attr('transform', (d) -> 'translate(' + x0(d.date) + ',0)')
            
            barHeight = (d) -> 
              if d.value
                  if d.value > ymax
                    d.value = ymax
                  if d.value < ymin
                    d.value = y(ymin)

                  height - y(d.value) 
            barYValue = (d) ->  
              if d.value
                if d.value > ymax
                  d.value = ymax
                if d.value < ymin
                  d.value = y(ymin)
                  
                y(d.value)
            #yType 2 center around 0
            if data.yType == 2
              barHeight = (d) -> 
                if d.value?
                  if d.value > ymax
                    d.value = ymax
                  if d.value < ymin
                    d.value = y(ymin)

                  if d.value == 0
                    y(0) - y(1)
                  else if d.value < 0
                    y(d.value) - y(0)
                  else
                    y(0) - y(d.value)
              barYValue = (d) -> 
                if d.value > ymax
                    d.value = ymax
                if d.value < ymin
                  d.value = ymin

                if d.value?
                  if d.value == 0
                    y(.5)
                  else if d.value < 0
                    y(0)
                  else
                    y(d.value)   

              #bold 0 as it is the center
              svg.append('line')
              .attr('x1', 0)
              .attr('x2', (d) -> width)
              .attr('y1', (d) -> y 0)
              .attr('y2', (d) -> y 0)
              .attr('class', 'zeroLine')
              .attr('stroke-width', 2)
              .attr('stroke', 'black')

            selectedElement = null
            date.selectAll('rect')
            .data((d) -> d.groupData)
            .enter()
            .append('rect')
            .attr('width', x1.rangeBand())
            .attr('x', (d) -> x1 d.name)
            .attr('y', barYValue)
            .attr('height', barHeight)
            .attr('class', (d) ->
              if (data.defaultSelected.date == d.group && data.defaultSelected.name == d.name)
                selectedElement = { target: this, data: d }
                return "rect selected #{d.name}"
              else
                "rect #{d.name}"
            )
            .on('mouseover', (d) -> tip.show(d))
            .on('mouseout', tip.hide)
            .on('click', (d) -> 
              permaTip.show(d, this)
              date.selectAll('rect').attr("class", (d) -> "rect #{d.name}" )
              d3.select(this).attr("class", "rect selected #{d.name}");
              scope.onClick({ element: d })
            )

            if selectedElement
              $timeout () ->
                permaTip.show(selectedElement.data, selectedElement.target)
              , 1

            # elite data
            svg.append('line')
            .attr('x1', 0)
            .attr('x2', (d) -> width)
            .attr('y1', (d) -> y data.average)
            .attr('y2', (d) -> y data.average)
            .attr('class', 'average')
            .attr('stroke-width', 2)
            .attr('stroke', 'black')

            svg.append("text")
            .attr("y", y(data.average))
            .attr("x", (d) -> width+50)
            .attr("dy", ".3em")
            .style("text-anchor", "end")
            .attr('class', 'average average-text')
            .text("MLB average")

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