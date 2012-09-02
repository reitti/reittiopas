define ['jquery', 'backbone', 'views/route_view'], ($, Backbone, RouteView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      @routeViews = []
      Reitti.Event.on 'routes:change', @showNewRoutes
      
    showNewRoutes: (@routes) =>
      routeView.dispose() for routeView in @routeViews
      @routeViews = (new RouteView(route[0]) for route in @routes)
      @render()
      Reitti.Event.trigger 'route:change', @routeViews[0].route
      
    render: ->
      @$el.empty()
      for routeView in @routeViews
        @$el.append(routeView.render().el)
      this
