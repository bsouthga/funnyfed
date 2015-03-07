
module.exports = (time_data) ->

  margin = {top: 20, right: 20, bottom: 30, left: 50}
  width = 960 - margin.left - margin.right
  height = 500 - margin.top - margin.bottom

  x = d3.scale.linear()
      .range([0, width])

  y = d3.scale.linear()
      .range([height, 0])

  xAxis = d3.svg.axis()
      .scale(x)
      .tickFormat (d) -> d
      .orient("bottom")

  yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")

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

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0,#{height})")
      .call(xAxis)

  svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Incidents of Laughter")

  svg.append("path")
      .datum(time_data)
      .attr("class", "line")
      .attr("d", line)
