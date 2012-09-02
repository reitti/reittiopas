define ['jquery', 'backbone', 'views/route_view'], ($, Backbone, RouteView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      @routeViews = []
      Reitti.Event.on 'routes:change', @showNewRoutes
      Reitti.Event.on 'route:select', @selectRoute
      
    showNewRoutes: (@routes) =>
      routeView.dispose() for routeView in @routeViews
      @routeViews = (new RouteView(route[0], idx) for route, idx in @routes)
      @render()
      Reitti.Event.trigger 'route:select', 0
      
    selectRoute: (n) =>
      Reitti.Event.trigger 'route:change', @routes[n][0]
      
    render: ->
      @$el.empty()
      for routeView in @routeViews
        @$el.append(routeView.render().el)
      this
