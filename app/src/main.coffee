
joke_data = require('../json/jokes.json')
d3 = require('d3')

joke_arr = ({name: n, jokes: j.length} for n, j of joke_data)

margin = { top: 10, right: 10, bottom: 10, left: 150 }
width = 500 - margin.left - margin.right
height = 640 - margin.top - margin.bottom

svg = d3.select('body').append('svg')
    .attr('class', 'chart')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
  .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

barHeight = height / joke_arr.length

x = d3.scale.linear()
      .domain([0, d3.max(joke_arr, (d) -> d.jokes)])
      .range([0, width])

bars = svg.append('g')
  .selectAll('bar')
  .data(joke_arr)
  .enter().append('g')
  .attr('class', 'bar')
  .attr 'transform', (d, i) -> "translate(0, #{i*barHeight})"

bars.append('text')
  .attr 'class', 'name'
  .text (d) -> d.name
  .attr 'x', -> -@getBBox().width - 10
  .attr 'y', -> barHeight/2 + @getBBox().height/2

bars.append('rect')
  .attr 'height', barHeight - 1
  .attr 'width', (d) -> x(d.jokes)

bars.append('text')
  .attr 'class', 'label'
  .text (d) -> d.jokes
  .attr 'x', (d) ->
    pad = 5
    v = x(d.jokes)
    w = @getBBox().width
    if ((v - pad) > w)
      v - w - pad
    else
      d3.select(@).classed('small', true)
      (v + pad)
  .attr 'y', -> barHeight/2 + @getBBox().height/2