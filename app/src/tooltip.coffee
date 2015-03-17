
d3 = require 'd3'


windowScrollTop = ->
  window?.pageYOffset or (document.documentElement or
                          document.body.parentNode or
                          document.body).scrollTop


module.exports = class Tooltip


  constructor : (id="#tooltip")->
    @tt = d3.select(id)


  hide : ->
    # move off screen otherwise
    tt_bb = @tt.node().getBoundingClientRect()
    x = -tt_bb.width - 200
    y = -tt_bb.height - 200
    return {
      top : "#{Math.round(y)}px"
      left : "#{Math.round(x)}px"
    }


  # center tooltip above svg node
  position : (node, svg, no_transition) ->

    if node
      @tt.style @hide()
      scrollTop = windowScrollTop()
      node_bb = if node.getBBox then node.getBBox() else node.getBoundingClientRect()
      tt_bb = @tt.node().getBoundingClientRect()
      ctm = if node.getScreenCTM then node.getScreenCTM() else {e : 0, f : 0}
      c_X = ctm.e
      c_Y = ctm.f
      svg_bb = if svg
                svg.getBoundingClientRect()
               else
                width : Infinity
                height: Infinity
      nw = node_bb.width
      nx = if node_bb.x != undefined then node_bb.x else node_bb.left
      ny = if node_bb.y != undefined then node_bb.y else node_bb.top
      svgw = svg_bb.width
      svgh = svg_bb.height
      # bound node width by width of container
      # svg element. Used to prevent bar tooltips
      # from appearing off screen for long bars
      if (nx >= 0) and (nw > svgw/2)
        node_width = svgw/2
      else if (nx <= 0) and (nw > svgw/2)
        # if the node x coordinate is negative,
        # we need to add it into the width
        node_width = Math.abs(nx)*2 + svgw/2
      else if (nx == 0) and (nw > svgw)
        node_width = svgw
      else
        node_width = nw
      # cap node height
      node_height = Math.max(-5, Math.min(ny, svgh))
      # c_X = svg X offset relative to window
      # node_bb.x || node_bb.left = node X offset relative to svg
      # node_width = width of svg node
      # tt_bb.width = width of tooltip div
      x = c_X + nx + node_width/2 - tt_bb.width/2
      # c_Y = svg Y offset relative to window
      # node_bb.y = node Y offset relative to svg
      # tt_bb.height = height of tooltip div
      # scrollTop = current offset of window top
      # extra 10 pixels to padd for tooltip arrow
      y = c_Y + node_height - tt_bb.height + scrollTop - 15
      # set position object
      pos =
        top: "#{Math.round(y)}px"
        left: "#{Math.round(x)}px"
    else
      pos = @hide()

    # if hiding / showing transition must
    # come before / after style
    if no_transition
      @tt.style(pos).style('opacity', if node then 1 else 0)
    else
      if node
        @tt.style(pos)
          .style('opacity', 0)
          .transition()
          .duration(100)
          .style('opacity', 1)
      else
        @tt.transition()
          .duration(100)
          .style('opacity', 0)
          .each 'end', (d, i) => i or @tt.style(pos)

    return @

  text : (data) ->
    @tt.html data
    @
