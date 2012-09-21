define ['jquery', 'underscore', 'backbone', 'models/routes', 'views/route_view'], ($, _, Backbone, Routes, RouteView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      @routeViews = []
      Reitti.Event.on 'routes:find', @findRoutes
      Reitti.Event.on 'routes:change', @showNewRoutes
      
    findRoutes: (params) ->
      Routes.find params.from, params.to, params.date, params.arrivalOrDeparture, params.transportTypes

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
