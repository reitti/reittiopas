define ['jquery', 'backbone', 'views/route_view'], ($, Backbone, RouteView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      Reitti.Event.on 'routes:change', @showNewRoutes
      Reitti.Event.on 'route:select', @selectRoute
      
    showNewRoutes: (@routes) =>
      @routeViews = (new RouteView(route, idx) for route, idx in @routes)
      @render()
      @selectRoute 0
      
    selectRoute: (n) =>
      Reitti.Event.trigger 'route:change', @routes[n]
      
    render: ->
      @$el.empty()
      for routeView in @routeViews
        @$el.append(routeView.render().el)
      this
