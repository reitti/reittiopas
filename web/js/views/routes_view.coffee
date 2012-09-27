define ['jquery', 'backbone', 'models/routes', 'views/route_view', 'views/more_routes_button_view'], ($, Backbone, Routes, RouteView, MoreRoutesButtonView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      @routeViews = []
      Reitti.Event.on 'routes:change', @onRoutesChanged

    onRoutesChanged: (routes, @routeParams) =>
      if routes isnt @routes
        @routes?.off 'add', @onRouteAdded
        routes.on 'add', @onRouteAdded
        @routes = routes

        routeView.dispose() for routeView in @routeViews
        @routeViews = []
        @$el.empty()

        @_addMoreAboveButton()
        for route in @routes.models
          @onRouteAdded(route)
        @_addMoreBelowButton()
        @_scrollToRoutes()

    onRouteAdded: (route) =>
      idx = @routes.indexOf(route)
      routeView = new RouteView(routes: @routes, routeParams: @routeParams, index: idx)

      idxOnScreen = @_getIndexForRouteView(routeView)
      @_addRouteElement(routeView, idxOnScreen)
      @routeViews.splice idxOnScreen, 0, routeView

      routeView.onRoutesChanged(@routes, @routeParams)

    _addRouteElement: (routeView, beforeIdx) ->
      if routeViewAfter = @routeViews[beforeIdx]
        routeViewAfter.$el.before(routeView.render().el)
      else if routeViewBefore = _.last(@routeViews)
        routeViewBefore.$el.after(routeView.render().el)
      else
        @moreAboveButton.$el.after(routeView.render().el)

    _getIndexForRouteView: (routeView) ->
      comparator = if @routes.isBasedOnArrivalTime() then ((a,b) -> a < b) else ((a,b) -> a > b)
      for existingView, idx in @routeViews
        if comparator(existingView.route.getArrivalTime(), routeView.route.getArrivalTime())
          return idx
      @routeViews.length

    _addMoreAboveButton: ->
      @moreAboveButton?.dispose()
      @moreAboveButton = new MoreRoutesButtonView(routes: @routes, loc: 'above')
      @$el.append(@moreAboveButton.render().el)

    _addMoreBelowButton: ->
      @moreBelowButton?.dispose()
      @moreBelowButton = new MoreRoutesButtonView(routes: @routes, loc: 'below')
      @$el.append(@moreBelowButton.render().el)

    _scrollToRoutes: ->
      setTimeout((=> $('#controls').animate({scrollTop: @$el.offset().top }, 200)), 100)
