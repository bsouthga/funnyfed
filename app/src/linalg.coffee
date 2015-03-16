

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

  det = -> @a*@d - @b*@c

