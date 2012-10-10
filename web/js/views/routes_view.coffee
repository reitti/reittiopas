define ['jquery', 'backbone', 'models/routes', 'views/route_view', 'views/more_routes_button_view'], ($, Backbone, Routes, RouteView, MoreRoutesButtonView) ->
  
  class RoutesView extends Backbone.View
    
    el: $('#routes')
    
    initialize: ->
      @routeViews = []
      Reitti.Event.on 'home', @onGoneHome
      Reitti.Event.on 'routes:change', @onRoutesChanged

    onGoneHome: =>
      @$el.hide()

    onRoutesChanged: (routes, @routeParams) =>
      @$el.show()

      if routes isnt @routes
        @routes?.off 'add', @onRouteAdded
        routes.on 'add', @onRouteAdded
        @routes = routes

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


    _addRouteElement: (routeView, beforeIdx) ->
      # RouteGraphView needs to calculate the width of the bar based on the
      # width of it's parent element, RouteView, so we need to add
      # RouteViewElement to the DOM to the DOM before calling render().
      el = $(document.createElement(RouteView.prototype.tagName)).addClass(RouteView.prototype.className)
      if routeViewAfter = @routeViews[beforeIdx]
        routeViewAfter.$el.before(el)
        routeView.setElement(el).render()
      else if routeViewBefore = _.last(@routeViews)
        routeViewBefore.$el.after(el)
        routeView.setElement(el).render()
      else
        @moreAboveButton.$el.after(el)
        routeView.setElement(el).render()

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
      setTimeout((=> @$el.offsetParent().animate({scrollTop: @$el.offset().top }, 200)), 100)
