#
# plots of laughing at FOMC meetings
# @bsouthga
# 03/07/15
#

barplot = require './barplot.coffee'
timeplot = require './timeplot.coffee'
joke_data = require '../json/people.json'


joke_arr = ({
    name: n
    jokes: j.length
  } for n, j of joke_data)


joke_arr.sort (a, b) ->
  (a.jokes < b.jokes) - (b.jokes < a.jokes)

console.log(joke_data)

times = {}
for n, joke_list of joke_data
  for j in joke_list
    date = "#{j.year}-#{j.month}-#{j.day}"
    if times[date]
      times[date] += 1
    else
      times[date] = 1


time_data = ({ value : n, date : new Date d } for d, n of times).sort (a, b) ->
  (a.date < b.date) - (a.date > b.date)

timeplot time_data
barplot joke_arr

resize_timeout = null

d3.select window
  .on 'resize', ->
    clearTimeout resize_timeout
    resize_timeout = setTimeout ->
      timeplot time_data
      barplot joke_arr
    , 100
