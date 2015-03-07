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

times = {}
for n, joke_list of joke_data
  for j in joke_list
    date = j.year
    if times[date]
      times[date] += 1
    else
      times[date] = 1

time_data = ({value : n, date : +y} for y, n of times)

console.log(time_data)

timeplot time_data
barplot joke_arr