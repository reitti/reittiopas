define ['backbone', 'hbs!template/more_routes_button', 'i18n!nls/strings'], (Backbone, template, strings) ->

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
      icon = if @loc is 'above' then 'arrow-up' else 'arrow-down'
      label = if @loc is 'above'
        if @routes.isBasedOnArrivalTime() then strings.laterArrivals else strings.earlierDepartures
      else
        if @routes.isBasedOnArrivalTime() then strings.earlierArrivals else strings.laterDepartures
      @$el.html(template(icon: icon, label: label, strings: strings))
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
