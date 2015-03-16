#
# position label so it doesn't overlap with line
#


class Vector

  constructor : (@x, @y) ->

  add : (alt) -> new Vector @x + alt.x, @y + alt.y

  sub : (alt) -> new Vector @x - alt.x, @y - alt.y


class Matrix

  constructor : (col1, col2) ->
    #
    # [ a  b ]
    # [ c  d ]
    #
    @a = col1.x
    @b = col2.x
    @c = col1.y
    @d = col2.y

  det : -> @a*@d - @b*@c


class Line

  constructor : (@a, @b) ->

  intersects : (alt) ->

    # find intersection using cramers rule

    c = @a.sub(alt.a)
    D = (new Matrix(@b, alt.b)).det()

    if D == 0
      return false

    D1 = (new Matrix(c, alt.b)).det()
    D2 = (new Matrix(@b, c)).det()

    # since the lines are defined by their end points
    # "t" must be between 0 and 1
    t1 = (D1/D)
    t2 = (D2/D)
    return (0 <= t1 <= 1) and (0 <= t2 <= 1)



module.exports = ->

  config = {}


  seriesLines = (series_data) ->

    # scaling functions
    x = config.x
    y = config.y

    plot_lines = []
    while series_data.length >= 2
      d1 = series_data.shift()
      d2 = series_data[0]
      p1 = new Vector x(d1), y(d1)
      p2 = new Vector x(d2), y(d2)
      plot_lines.push new Line p1, p2
    return plot_lines


  boundingRectLines = (bbox, pos) ->

    # points defining the bounding box
    x1 = pos.x
    y1 = pos.y
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
    a = new Vector x1, y1
    b = new Vector x2, y1
    c = new Vector x1, y2
    d = new Vector x2, y2

    return [
      new Line a, b
      new Line b, d
      new Line c, d
      new Line a, c
    ]


  applyPosition = (selection, p) ->
    selection
      .attr 'x', p.x
      .attr 'y', p.y


  position = (selection, line_data) ->

    point_data = selection.data()[0]

    x = config.x
    y = config.y

    bb = selection.node().getBBox()

    series_lines = seriesLines line_data

    w = bb.width
    h = bb.height

    start = new Vector x(point_data), y(point_data)

    possibilities = [
      # x   ,  y
      [-w/2 , 0  ],    # top centered
      [ 0   , h/2],  # right centered
      [-w/2 , h  ]      # bottom centered
      [-w   , h/2]   # left centered
      [-w   , 0  ]     # left top corner
      [ 0   , 0  ]     # right top corner
      [ 0   , h  ]     # right bottom corner
      [-w   , h  ]     # left bottom corner
    ].map (c) -> new Vector c[0], c[1]

    for p, i in possibilities
      potential = start.add(p)
      bound_lines = boundingRectLines bb, potential
      for s in series_lines
        intersects = false
        for b, j in bound_lines
          if s.intersects(b)
            intersects = true
            break
        if not intersects
          return applyPosition(selection, potential)

    applyPosition selection, start.add(possibilities[0])


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
