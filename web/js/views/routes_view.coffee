define ['jquery', 'backbone', 'models/routes', 'views/route_view'], ($, Backbone, Routes, RouteView) ->
  
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
        @routeViews = (new RouteView(routes: @routes, routeParams: routeParams, index: idx) for idx in [0...@routes.size()])
        @render()
        # Invoke event handlers explicitly since the newly constructed views won't receive this event.
        routeView.onRoutesChanged(routes, routeParams) for routeView in @routeViews
      
    render: ->
      @$el.empty()
      for routeView in @routeViews
        @$el.append(routeView.render().el)
      this
