'use strict'
angular.module('d3').directive 'barchart', [
  'd3'
  '$window'
  (d3, $window) ->
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
            right: 20
            bottom: 30
            left: 50
          width = width - (margin.left) - (margin.right)
          height = height - (margin.top) - (margin.bottom)

          x = d3.scale.ordinal()
              .rangeRoundBands([0, width], .1);

          y = d3.scale.linear()
              .range([height, 0]);

          xAxis = d3.svg.axis()
              .scale(x)
              .orient("bottom");

          yAxis = d3.svg.axis()
              .scale(y)
              .orient("left")

          #tooltip
          tip = d3.tip()
            .attr('class', 'd3-tip')
            .offset([-10, 0])
            .html (d) ->
              return "<strong>Frequency:</strong> <span style='color:red'>" + d.frequency + "</span>";

          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++

          svg = d3.select(element[0]).append('svg')
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
            .append("g")
              .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          
          #add tooltip
          svg.call(tip);

          if angular.isDefined(scope.bind())
            bindData = scope.bind()
            data = _.cloneDeep(bindData)

           #set yxis to 0 or min - 1 if under 0 to whichever is higher max value or average 
            ymin = 0
            minValue = d3.min(data, (d) -> d.value)
            # minAverage = d3.min(data, (d) -> d.average)
            # if minValue < minAverage then ymin = minValue else ymin = minAverage
            ymin = minValue #remove when averages come in 
            ymin = minValue - 1 if minValue < 0

            maxValue = d3.max(data, (d) -> d.value)
            # maxAverage = d3.max(data, (d) -> d.average)
            # if maxValue > minAverage then ymax = minValue else ymax = minAverage
            ymax = maxValue #remove when averages come in 

            x.domain(data.map((d) -> d.bar ))
            y.domain [ymin, ymax]

            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis)

            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                .attr("transform", "rotate(-90)")
                .attr("y", 6)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text("Frequency")

            svg.selectAll(".bar")
                .data(data)
              .enter()
                .append("rect")
                .attr("class", "bar")
                .attr("x", (d) -> x(d.bar))
                .attr("width", x.rangeBand())
                .attr("y", (d) -> y(d.value))
                .attr("height", (d) -> height - y(d.value))
                .on('mouseover', tip.show)
                .on('mouseout', tip.hide)

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