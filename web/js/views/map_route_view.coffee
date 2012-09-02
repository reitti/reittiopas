define ['underscore', 'utils', 'views/map_route_leg_view'], (_, Utils, MapRouteLegView) ->

  class MapRouteView
    
    constructor: (@route, @map) ->
      @legViews = (new MapRouteLegView(leg, @map) for leg in route.legs)
        
    remove: ->
      legView.remove() for legView in @legViews
      this
      
    render: ->
      legView.render() for legView in @legViews
      this

    getBounds: () ->
      bounds = new google.maps.LatLngBounds()
      bounds.union(legView.getBounds()) for legView in @legViews 
      bounds
      
    getBoundsForLeg: (leg) ->
      @findLegView(leg).getBounds()

    findLegView: (leg) ->
      for legView in @legViews
        return legView if legView.leg is leg
      null
