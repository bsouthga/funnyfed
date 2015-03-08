#
# position label so it doesn't overlap with line
#

module.exports = ->

  config = {}

  point = (x, y) -> {x:x, y:y}
  line = (a, b) -> {a:a, b:b}

  seriesLines = (series_data) ->

    x = config.x
    y = config.y

    plot_lines = []
    while series_data.length >= 2
      d1 = series_data.shift()
      d2 = series_data[0]
      p1 = point x(d1), y(d1)
      p2 = point x(d2), y(d2)
      plot_lines.push line p1, p2
    return plot_lines


  intersection = (l1, l2) ->
    #
    # Cramer's rule, for lines l1, l2
    #
    # |c1|   |l2.a.x − l1.a.x|   |l1.b.x -l2.b.x| |t|
    # |  | = |               | = |              |*| |
    # |c2|   |l2.a.y − l1.a.y|   |l1.b.y -l2.b.y| |s|
    #            (vector)            (matrix)
    #

    c1 = (l2.a.x) + (-l1.a.x)
    c2 = (l2.a.y) + (-l1.a.y)
    detA = l1.b.x*( -l2.b.y ) - l1.b.y*( -l2.b.x )
    detA_t = c1*( -l2.b.y ) - c2*( -l2.b.x )
    detA_s = c1*( l1.b.y ) - c2*( l1.b.x )

    if detA == 0
      return false

    # return computed s and t values for intersection
    return [
      detA_t / detA, # value of t
      detA_s / detA  # value of s
    ]


  boundingRectLines = (bbox) ->

    # points defining the bounding box
    x1 = bbox.x
    y1 = bbox.y
    x2 = x1 + bbox.width
    y2 = y1 + bbox.height

    #
    #
    # (x1,y1)
    #   a -------- b
    #   |   bbox   |
    #   |          |
    #   c -------- d
    #           (x2, y2)
    #
    a = point x1, y1
    b = point x2, y1
    c = point x1, y2
    d = point x2, y2

  position = (selection, line_data) ->

    console.log selection.data()

    x = config.x
    y = config.y

    bb = selection.node().getBBox()

    series_lines = seriesLines line_data
    bound_lines = boundingRectLines bb

    selection
      .attr 'x', (d) -> x(d) - bb.width/2
      .attr 'y', (d) -> y(d)

  #
  # define getters / setters
  #
  methods = ['x', 'y']
  for m in methods
    do (m) ->
      config[m] = null
      position[m] = (value) ->
        if value != undefined
          config[m] = value
          return @
        else
          return config[m]

  return position
