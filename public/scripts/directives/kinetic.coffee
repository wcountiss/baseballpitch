'use strict'
angular.module('d3').directive 'kinetic', [
  'd3'
  '$window'
  '$timeout'
  (d3, $window,$timeout) ->
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
            bottom: 100
            left: 50
          width = width - (margin.left) - (margin.right)
          height = height - (margin.top) - (margin.bottom)          

          x = d3.scale.linear().range([0, width]);
          y = d3.scale.linear().range([height,0])

          # remove the last version and recreate 
          elementChildren = element[0].children
          i = 0
          while i < elementChildren.length
            element[0].removeChild elementChildren[i]
            i++
          d3.selectAll(".d3-tip").remove()

          svg = d3.select(element[0])
          .append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

          if angular.isDefined(scope.bind())
            bindData = scope.bind()
            data = _.cloneDeep(bindData)

            timeWarp = parseInt(data.timeWarp/keyframeCompression)

            xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom")
            .ticks(totalTicks);

            yAxis = d3.svg.axis()
            .scale(y)
            .orient("left")

            xPlot = (index) ->
              return x(index)

            lineFunction = d3.svg.line()
            .interpolate("cardinal")
            .x((d) -> return xPlot(d.index))
            .y((d) -> return y(d.score));

            #speed lines
            lines = data.speeds.map((d) ->
              maxScore = d3.max(d.scores) 
              return {
                mlbavg: data.peakSpeeds[d.key].eliteavg.avg,
                key: d.key,
                values: d.scores.map (d, i) -> return {index: i, score: +d}
                peak: { index: _.findIndex(d.scores, (score) -> score == maxScore), score: data.peakSpeeds[d.key].score, color: data.peakSpeeds[d.key].color, rating: data.peakSpeeds[d.key].rating }
              })

            x.domain([
              0,
              totalTicks
            ])

            x1 = d3.scale.linear().range([0, x(timeWarp)]);
            xAxis1 = d3.svg.axis()
            .scale(x1)
            .orient("bottom")
            .ticks(timeWarp*2);

            x1.domain([
              0,
              timeWarp
            ])

            y.domain([
              d3.min(_.pluck(_.flatten(_.pluck(lines, 'values')),'score')),
              d3.max(_.pluck(_.flatten(_.pluck(lines, 'values')),'score'))
            ])

            #border right line
            svg.append("line")
              .attr('x1', (d) -> width)
              .attr('x2', (d) -> width)
              .attr('y1', (d) -> 0)
              .attr('y2', (d) -> height)
              .attr('class', 'border-right')
              .attr('stroke-width', 1)
              
            svg.append("rect")
              .attr("width", (d) -> width)
              .attr("height", "7em")
              .attr("fill", "#414042")
              .attr("transform", "translate(0," + height + ")")

            svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis)

            #Hide the xaxis on squashed section
            svg.append("rect")
              .attr("width", (d) -> x(timeWarp))
              .attr("height", "7em")
              .attr("fill", "#414042")
              .attr("transform", "translate(0," + height + ")")

            svg.append("g")
                .attr("class", "x axis squash")
                .attr("transform", "translate(0," + height + ")")
                .call(xAxis1)

            svg.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                .attr("transform", "rotate(-90)")
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text("")
                .attr("y", -48);

            #background lines
            svg.append("g")      
            .attr("class", "grid")
            .call(yAxis
              .tickSize(-width, 0, 0)
              .tickFormat("")
            ) 

            #circles for timing
            # static keyframe images
            svg.append("svg:image")
              .attr("xlink:href", "/images/kc-FirstMovement.svg")
              .attr("width", 30)
              .attr("height", 30)
              .attr("x", (d) -> x1(0))
              .attr("y",height+40);

            svg.append("svg:image")
              .attr("xlink:href", "/images/kc-BallRelease.svg")
              .attr("width", 30)
              .attr("height", 30)
              .attr("x", (d) -> x(totalTicks)-32)
              .attr("y",height+40)

            svg.append("text")
              .attr("width", 30)
              .attr("height", 30)
              .attr("x", (d) -> x(totalTicks)-55)
              .attr("y",height+90)
              .text("Ball Release")

            #Player Timing Markers
            _.each _.keys(data.timings), (key) ->
              #Circles 
              svg.append('circle')
              .datum(data.timings[key])
              .attr('r', 3)
              .attr('cx', (d) -> xPlot(d.keyframe/keyframeCompression))
              .attr('cy', (d) -> height + 10)
              .attr('class', 'circle timing-marker')
              .attr('fill', 'black')
              .attr 'stroke', 'black'

              svg.append('line')
              .datum(data.timings[key])
              .attr('x1', (d) -> xPlot(d.keyframe/keyframeCompression))
              .attr('x2', (d) -> xPlot(d.keyframe/keyframeCompression))
              .attr('y1', (d) -> height+10)
              .attr('y2', (d) -> height+25)
              .attr('class', 'timing-marker-line')
              .attr('stroke-width', 2)
              .style("stroke", "white")
              
              svg.append("text")
              .datum(data.timings[key])
                .attr("y", height+32)
                .attr("x", (d) -> xPlot(d.keyframe/keyframeCompression)+20)
                .attr("dy", ".3em")
                .style("text-anchor", "end")
                .attr('class', 'timing-marker-text')
                .text((d) -> "#{parseFloat(data.timings[key].timing).toFixed(1)} MS")


              #Player Kinetic Chain Images
              svg.append("svg:image")
              .datum(data.timings[key])
              .attr("xlink:href", "/images/kc-#{key}.svg")
              .attr("width", 33)
              .attr("height", 33)
              .attr("x", (d) -> xPlot(d.keyframe/keyframeCompression)-16.5)
              .attr("y",height+38)

              textConfig = { 
                "LegKick": { xOffset: 20, text: "Leg Kick" } 
                "FootContact": { xOffset: 30, text: "Toe Touch" } 
              }
              svg.append("text")
              .datum(data.timings[key])
                .attr("y", height+82)
                .attr("x", (d) -> xPlot(d.keyframe/keyframeCompression)+textConfig[key].xOffset)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .text(textConfig[key].text)
                

            #lines for averages
            _.each _.keys(data.averages), (key) ->
              svg.append('line')
              .datum(data.averages[key])
              .attr('x1', (d) -> x(totalTicks + (d.avg/keyframeCompression)))
              .attr('x2', (d) -> x(totalTicks + (d.avg/keyframeCompression)))
              .attr('y1', (d) -> height)
              .attr('y2', (d) -> height+25)
              .attr('class', 'average')
              .attr('stroke-width', 1)

              svg.append("text")
              .datum(data.averages[key])
                .attr("y", height+30)
                .attr("x", (d) -> x(totalTicks + (d.avg/keyframeCompression))+20)
                .attr("dy", ".3em")
                .style("text-anchor", "end")
                .attr('class', 'average average-text')
                .text("MLB average")

            #speed lines
            line = svg.selectAll(".line")
                .data(lines)
              .enter().append("g")
                .attr("class", "line")

            line.append("path")
                .attr("class", (d) -> "line #{d.key}")
                .attr("d", (d) -> 
                  return lineFunction(d.values))

            #peak line
            svg.selectAll("peak")
                .data(lines)
              .enter()
                .append("line")
                .attr('x1', (d) -> x(d.peak.index))
                .attr('x2', (d) -> x(d.peak.index))
                .attr('y1', (d) -> y(d.values[d.peak.index].score))
                .attr('y2', (d) -> height+10)
                .attr('class', 'peak')
                .attr('stroke-width', 2)
                .style("stroke", (d) -> d.peak.color)
            
            #peak circles
            #tool tip
            timingTip = {}
            _.each lines, (line) ->
              timingTip[line.key] = d3.tip()
              .attr('class', 'd3-tip')
              .attr("transform", "translate(0,#{-height})")
              .html((d) -> 
               '<div class="tip-rating '+ d.value.rating+'">' + d.value.rating + " " + _.humanize(d.key.replace('keyframe',''))+'</div><div class="d3-tip-tooltip">Player: ' + parseFloat(d.value.score).toFixed(0) + ' MS</div><div class="eliteavg">Elite: ' + Math.round(d.elite) + ' MS</div>'
              )
              svg.call timingTip[line.key]

            svg.selectAll("peak")
                .data(lines)
              .enter()
                .append("circle")
                .attr('r', 3)
                .attr('cx', (d) -> x(d.peak.index))
                .attr('cy', (d) -> y(d.values[d.peak.index].score))
                .attr('class', 'peak-circle peak-circle-upper')
                .attr('fill', (d) -> d.peak.color)
                .attr('stroke', 'black')
                $timeout () ->
                  d3.selectAll(".peak-circle-upper")
                  .each (d) ->
                    timingTip[d.key].show({ key: d.key, value: d.peak, elite: d.mlbavg}, this)
                , 1

            svg.selectAll("peak")
              .data(lines)
            .enter()
              .append("circle")
                .attr('r', 2)
                .attr('cx', (d) -> x(d.peak.index))
                .attr('cy', (d) -> height+10)
                .attr('class', 'peak-circle peak-circle-lower')
                .attr('fill', (d) -> d.peak.color)
                .attr('stroke', 'black')


        scope.$watch 'bind()', (-> updateChart()), false
        angular.element($window).bind 'resize', -> updateChart()
    }
]