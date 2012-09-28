define ['underscore', 'utils', 'views/map_route_leg_view'], (_, Utils, MapRouteLegView) ->

  class MapRouteView
    
    constructor: ({routes, routeParams, @index, map}) ->
      @legViews = for leg, legIndex in routes.at(@index).get('legs')
        new MapRouteLegView(routes: routes, routeParams: routeParams, routeIndex: @index, index: legIndex, map: map)
 
    dispose: ->
      legView.dispose() for legView in @legViews
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
