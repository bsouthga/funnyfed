#
# time series plot
#

Tooltip = require './tooltip.coffee'

tooltip = new Tooltip()

module.exports = (time_data) ->

  container = d3.select('#time-series')

  bb = container.node().getBoundingClientRect()

  margin = {top: 40, right: 30, bottom: 30, left: 50}
  width = bb.width - margin.left - margin.right
  height = 300 - margin.top - margin.bottom

  x = d3.time.scale()
      .range([0, width])

  y = d3.scale.linear()
      .range([height, 0])

  numberOfTicks = 10

  xAxis = d3.svg.axis()
      .scale(x)
      .ticks(numberOfTicks)
      .orient("bottom")

  line = d3.svg.line()
      .x (d) -> x d.date
      .y (d) -> y d.value
      .interpolate 'cardinal'

  svg = container.html('').append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(#{margin.left},#{margin.top})")

  x.domain d3.extent time_data, (d) -> d.date
  y.domain [0, d3.max(time_data, (d) -> d.value)*1.1]

  xAxisGrid = d3.svg.axis().scale(x)
    .ticks(numberOfTicks)
    .tickSize(-height, 0)
    .tickFormat("")
    .orient("top")

  svg.append("g")
    .classed('x', true)
    .classed('grid', true)
    .call(xAxisGrid)

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,#{height})")
      .call(xAxis)

  svg.append("path")
    .datum(time_data)
    .attr("class", "line")
    .attr("d", line)

  circles = svg.append("g")
    .selectAll('circle')
    .data(time_data)
    .enter().append('circle')
    .attr('r', 5)
    .attr 'cx', (d) -> x(d.date)
    .attr 'cy', (d) -> y(d.value)

  circles_dists = []
  circles.each ->
    n = d3.select(@)
    circles_dists.push
      node : n
      x : parseFloat n.attr('cx')


  dformat = d3.time.format('%x')

  d3.select('#plexiglass')
    .on 'mouseout', ->
      circles.style('opacity', 0)
      tooltip.position()
    .on 'mousemove', ->
      circles.style('opacity', 0)
      mx = d3.mouse(svg.node())[0]
      min = null
      min_dist = Infinity
      for c in circles_dists
        d = Math.abs(mx - c.x)
        if d < min_dist
          min_dist = d
          min = c.node
      data = min.data()[0]
      min.style('opacity', 1)
      tooltip
        .text("#{dformat data.date} &mdash; #{data.value} laughs")
        .position(min.node(), svg.node(), true)





