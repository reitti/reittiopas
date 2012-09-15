define ['jquery', 'underscore', 'backbone', 'views/route_view'], ($, _, Backbone, RouteView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      @routeViews = []
      Reitti.Event.on 'routes:change', @showNewRoutes
      
    showNewRoutes: (@routes) =>
      routeView.dispose() for routeView in @routeViews
      @routeViews = (new RouteView(routes: @routes, index: idx) for idx in [0..@routes.size() - 1])
      @render()
      _.delay (=> Reitti.Event.trigger 'route:change', @routeViews[0].route), 50
      
    render: ->
      @$el.empty()
      for routeView in @routeViews
        @$el.append(routeView.render().el)
      this
