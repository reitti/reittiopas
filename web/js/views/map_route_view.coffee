define ['underscore', 'utils', 'leaflet', 'views/map_route_leg_view'], (_, Utils, L, MapRouteLegView) ->

  class MapRouteView
    
    constructor: (@route, @map) ->
      @legViews = (new MapRouteLegView(leg, @map) for leg in @route.get('legs') when !leg.isFiller())

    remove: ->
      legView.remove() for legView in @legViews
      this
      
    render: ->
      legView.render() for legView in @legViews
      this

    getBounds: () ->
      bounds = @legViews[0].getBounds()
      bounds.extend(legView.getBounds()) for legView in @legViews[1..]
      bounds
      
    getBoundsForLeg: (leg) ->
      @findLegView(leg).getBounds()

    findLegView: (leg) ->
      for legView in @legViews
        return legView if legView.leg is leg
      null
