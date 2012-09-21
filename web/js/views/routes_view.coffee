define ['jquery', 'underscore', 'backbone', 'models/routes', 'views/route_view'], ($, _, Backbone, Routes, RouteView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      @routeViews = []
      Reitti.Event.on 'routes:find', @findRoutes
      Reitti.Event.on 'routes:change', @onRoutesChanged
      
    findRoutes: (params) ->
      Routes.find params.from, params.to, params.date, params.arrivalOrDeparture, params.transportTypes, params

    onRoutesChanged: (routes, routeParams) =>
      if routes isnt @routes
        @routes = routes
        routeView.dispose() for routeView in @routeViews
        @routeViews = (new RouteView(routes: @routes, index: idx, routeParams: routeParams) for idx in [0..@routes.size() - 1])
        @render()
        _.invoke @routeViews, 'onRoutesChanged', routes, routeParams
      
    render: ->
      @$el.empty()
      for routeView in @routeViews
        @$el.append(routeView.render().el)
      this
