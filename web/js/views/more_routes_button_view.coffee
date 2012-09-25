define ['backbone', 'hbs!template/more_routes_button'], (Backbone, template) ->

  class MoreRoutesButtonView extends Backbone.View

    tagName: 'li'
    className: 'more'

    events:
      'click a': 'onClicked'

    initialize: (routes: routes, loc: loc) ->
      @routes = routes
      @loc = loc
      routes.on 'add', @backToNormal
      Reitti.Event.on 'routes:more:error', @backToNormal

    dispose: ->
      @routes.off 'add', @backToNormal
      Reitti.Event.off 'routes:more:error', @backToNormal

    render: ->
      icon = if @loc is 'above' then 'chevron-up' else 'chevron-down'
      label = if @loc is 'above'
        if @routes.isBasedOnArrivalTime() then 'Myöhemmin perillä' else 'Aikaisemmat lähdöt'
      else
        if @routes.isBasedOnArrivalTime() then 'Aikaisemmin perillä' else 'Myöhemmät lähdöt'
      @$el.html(template(icon: icon, label: label))
      this

    onClicked: =>
      @$el.find('.normal').hide()
      @$el.find('.refreshing').show()
      if @loc is 'above' then @onClickedAbove() else @onClickedBelow()
      false

    backToNormal: =>
      @$el.find('.refreshing').hide()
      @$el.find('.normal').show()

    onClickedAbove: ->
      if @routes.isBasedOnArrivalTime()
        @routes.loadMoreLater()
      else
        @routes.loadMoreEarlier()

    onClickedBelow: ->
      if @routes.isBasedOnArrivalTime()
        @routes.loadMoreEarlier()
      else
        @routes.loadMoreLater()
