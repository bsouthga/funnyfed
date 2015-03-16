

class Vector

  constructor : (@x, @y) ->
    @m = Math.sqrt(@x**2 + @y**2)
    if @m != 0
      @x = @x/@m
      @y = @y/@m

  add : (alt) -> new Vector @x + alt.x, @y + alt.y
  sub : (alt) -> new Vector @x - alt.x, @y - alt.y
  scale : (a) ->
    @x *= a
    @y *= a
    @


module.exports = (time_data) ->

  margin = {top: 40, right: 30, bottom: 30, left: 50}
  width = 960 - margin.left - margin.right
  height = 300 - margin.top - margin.bottom

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

  svg.append("g")
    .selectAll('text')
    .data(time_data)
    .enter().append('text')
    .text (d) -> d.value
    .each (d, i) ->

      bb = @getBBox()

      points = time_data[(if i > 0 then i-1 else 0)..i+1].map (d) ->
        {x : x(d.date), y : y(d.value)}

      if points.length == 3
        [p0, p1, p2] = points
        p1.x += bb.width/2
        p1.y += bb.height
        v1 = new Vector p0.x-p1.x, p0.y-p1.y
        v2 = new Vector p2.x-p1.x, p2.y-p1.y
        p = v1.sub(v2).scale(25)
        console.log(p)
        d3.select @
          .attr 'x', p.x + p1.x
          .attr 'y', p.y + p1.y
      else
        p = if i then points[1] else points[0]
        d3.select @
          .attr 'x', p.x - bb.width/2
          .attr 'y', p.y - bb.height





