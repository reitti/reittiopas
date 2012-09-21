define ['underscore', 'utils', 'views/map_route_leg_view'], (_, Utils, MapRouteLegView) ->

  class MapRouteView
    
    constructor: (@route, routeIndex, routes, @map) ->
      @legViews = (new MapRouteLegView(leg, index, routeIndex, routes, @map) for leg, index in @route.get('legs') when !leg.isFiller())
 
    remove: ->
      legView.remove() for legView in @legViews
      this
      
    render: ->
      legView.render() for legView in @legViews
      this

    getBounds: () ->
      bounds = @legViews[0].getBounds()
      bounds.union(legView.getBounds()) for legView in @legViews[1..]
      bounds
      
    getBoundsForLeg: (leg) ->
      @findLegView(leg).getBounds()

    findLegView: (leg) ->
      for legView in @legViews
        return legView if legView.leg is leg
      null
