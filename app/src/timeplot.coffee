
position = require('./position.coffee')

module.exports = (time_data) ->

  margin = {top: 30, right: 30, bottom: 30, left: 50}
  width = 960 - margin.left - margin.right
  height = 500 - margin.top - margin.bottom

  x = d3.scale.linear()
      .range([0, width])

  y = d3.scale.linear()
      .range([height, 0])

  numberOfTicks = 10

  xAxis = d3.svg.axis()
      .scale(x)
      .ticks(numberOfTicks)
      .tickFormat (d) -> d
      .orient("bottom")

  line = d3.svg.line()
      .x (d) -> x d.date
      .y (d) -> y d.value

  svg = d3.select("body").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(#{margin.left},#{margin.top})")

  x.domain d3.extent time_data, (d) -> d.date
  y.domain d3.extent time_data, (d) -> d.value

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

  svg.append("g")
    .selectAll('circle')
    .data(time_data)
    .enter().append('circle')
    .attr('r', 5)
    .attr 'cx', (d) -> x(d.date)
    .attr 'cy', (d) -> y(d.value)

  textPos = position()
    .x (d) -> x(d.date)
    .y (d) -> y(d.value) - 10

  svg.append("g")
    .selectAll('text')
    .data(time_data)
    .enter().append('text')
    .text (d) -> d.value
    .each (d, i) ->
      textPos d3.select(@), time_data[(if i > 0 then i-1 else 0)..i+1]



