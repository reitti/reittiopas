define ['underscore', 'utils', 'views/map_route_leg_view'], (_, Utils, MapRouteLegView) ->

  class MapRouteView
    
    constructor: ({@routes, routeParams, @index, map}) ->
      @legViews = for leg, legIndex in @routes.at(@index).get('legs')
        new MapRouteLegView(routes: @routes, routeParams: routeParams, routeIndex: @index, index: legIndex, map: map)
      Reitti.Event.on 'routes:change', @onRoutesChanged

    dispose: ->
      legView.dispose() for legView in @legViews
      Reitti.Event.off 'routes:change', @onRoutesChanged
      this
      
    render: ->
      legView.render() for legView in @legViews
      this

    getBounds: () ->
      bounds = @legViews[0].getBounds()
      bounds.union(legView.getBounds()) for legView in @legViews[1..]
      bounds
      
    getBoundsForLeg: (legIndex) ->
      @legViews[legIndex].getBounds()

    getLegEndCoordinates: (legIndex, originOrDestination) ->
      @legViews[legIndex]?.getEndCoordinates(originOrDestination)
      
    onRoutesChanged: (routes, routeParams) =>
      if routes is @routes and routeParams.routeIndex is @index and !routeParams.legIndex?
        _.first(@legViews)?.showOriginMarker()
        _.last(@legViews)?.showDestinationMarker()
