'use strict'
angular.module('d3').directive 'kinetic', [
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
          keyframeCompression = 5
          totalTicks = 1000/keyframeCompression

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
            top: 25
            right: 20
            bottom: 30
            left: 50
          width = width - (margin.left) - (margin.right)
          height = height - (margin.top) - (margin.bottom)          
          x = d3.scale.linear().range([0,width])
          y = d3.scale.linear().range([height,0])

          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++

          svg = d3.select(element[0])
          .append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          #tool tip
          speedTip = d3.tip()
          .attr('class', 'd3-tip')
          .html((d) ->
            '<div class="d3-tip-heading">Hips</div><div class="d3-tip-tooltip">' + parseFloat(d.Hips.score).toFixed(1) + ' Degrees/Second</div>' \
            + '<div class="d3-tip-heading">Trunk</div><div class="d3-tip-tooltip">' + parseFloat(d.Trunk.score).toFixed(1) + ' Degrees/Second</div>' \ 
            + '<div class="d3-tip-heading">Forearm</div><div class="d3-tip-tooltip">' + parseFloat(d.Forearm.score).toFixed(1) + ' Degrees/Second</div>'
          )
          svg.call speedTip

          timingTip = d3.tip()
          .attr('class', 'd3-tip')
          .html((d) ->
            '<div class="d3-tip-heading">' + _.humanize(d.heading.replace('keyframe','')) + '</div><div class="d3-tip-tooltip">' + parseFloat(d.value).toFixed(1) + ' MS</div>'
          )
          svg.call timingTip

          if angular.isDefined(scope.bind())
            bindData = scope.bind()            
            data = _.cloneDeep(bindData)

            color = d3.scale.category10();

            xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom")
            .ticks(totalTicks)

            yAxis = d3.svg.axis()
            .scale(y)
            .orient("left")

            lineFunction = d3.svg.line()
            .interpolate("basis")
            .x((d) -> return x(d.index))
            .y((d) -> return y(d.score));

            bisectIndex = d3.bisector((d) -> return d.index;).left
            mousemove = () ->
              x0 = x.invert(d3.mouse(this)[0])
              d3.selectAll(".selector").remove();

              tipData = {}
              data.speeds.forEach (s) ->
                speeds = s.scores.map((d, i) -> return {index: i, score: +d})
                i = bisectIndex(speeds, x0, 1)
                d0 = speeds[i - 1]
                d1 = speeds[i]
                d = if x0 - d0.index > d1.index - x0 then d1 else d0
              
                d3.selectAll(".selector").remove();
                
                svg.append('line')
                .attr('x1', x(d.index))
                .attr('y1', 0)
                .attr('x2', x(d.index) )
                .attr('y2', height)
                .attr('class', 'selector')
                .attr('stroke-width', 2)
                .attr('stroke', 'black')

                tipData[s.key] = d

              speedTip.show(tipData)
              .style("top", (event.pageY-150)+"px")
              .style("left",(event.pageX-60)+"px")

            color.domain(_.pluck(data.speeds, 'key'))

            #speed lines
            lines = data.speeds.map((d) ->
              maxScore = d3.max(d.scores) 
              return {
                key: d.key,
                values: d.scores.map (d, i) -> return {index: i, score: +d}
                peakIndex: _.findIndex d.scores, (score) -> score == maxScore
              })

            x.domain([
              d3.min(_.pluck(_.flatten(_.pluck(lines, 'values')),'index')),
              d3.max(_.pluck(_.flatten(_.pluck(lines, 'values')),'index'))
            ])

            y.domain([
              d3.min(_.pluck(_.flatten(_.pluck(lines, 'values')),'score')),
              d3.max(_.pluck(_.flatten(_.pluck(lines, 'values')),'score'))
            ])

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
                .text("degrees/sec")

            #peak line
            svg.selectAll("peak")
                .data(lines)
              .enter()
                .append("line")
                .attr('x1', (d) -> x(d.peakIndex))
                .attr('x2', (d) -> x(d.peakIndex))
                .attr('y1', (d) -> y(d.values[d.peakIndex].score))
                .attr('y2', (d) -> height)
                .attr('class', 'peak')
                .attr('stroke-width', 2)
                .attr('stroke', 'black')

            #rect to capture mouse
            svg.append("rect")
              .attr("width", width)
              .attr("height", height)
              .style("fill", "none")
              .style("pointer-events", "all") 
              .on("mouseout", (d) ->  d3.selectAll(".selector").remove(); speedTip.hide())
              .on("mousemove", mousemove)

            #circles for timing
            _.each _.keys(data.timings), (key) ->
              svg.append('circle')
              .datum(data.timings[key])
              .attr('r', 3)
              .attr('cx', (d) -> x d/keyframeCompression)
              .attr('cy', (d) -> height)
              .attr('class', 'circle')
              .attr('fill', 'black')
              .attr 'stroke', 'black'
              .on('mouseover', (d) -> timingTip.show({ heading: key, value: d}))
              .on('mouseout', timingTip.hide)

            #circles for averages
            _.each _.keys(data.averages), (key) ->
              svg.append('circle')
              .datum(data.averages[key])
              .attr('r', 4)
              .attr('cx', (d) -> x(totalTicks + (d.avg/keyframeCompression)))
              .attr('cy', (d) -> height+10)
              .attr('class', 'average')
              .attr('fill', 'black')
              .attr('stroke', 'black')
              .on('mouseover', (d) -> timingTip.show({ heading: key, value: d.avg}))
              .on('mouseout', timingTip.hide)

            #speed lines
            line = svg.selectAll(".line")
                .data(lines)
              .enter().append("g")
                .attr("class", "line")

            line.append("path")
                .attr("class", "line")
                .attr("d", (d) -> return lineFunction(d.values))
                .style("stroke", (d) -> return color(d.key))

        scope.$watch 'bind()', (-> updateChart()), false
        angular.element($window).bind 'resize', -> updateChart()
    }
]