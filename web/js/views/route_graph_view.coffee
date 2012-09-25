define ['underscore', 'backbone', 'utils', 'handlebars', 'hbs!template/route_graph'], (_, Backbone, Utils, Handlebars, template) ->

  EXPANDED_HEIGHT = 150
  MINIMUM_LEG_HEIGHT = 12

  # ToDo: Legs really deserve their own view class at this point.

  class RouteGraphView extends Backbone.View

    events:
      'click .leg-info': 'selectLeg'

    initialize: (routes: routes, routeParams: routeParams, index: index) ->
      @routes = routes
      @routeParams = routeParams
      @index = index
      @route = routes.at(@index)
      @expanded = false

    render: ->
      @$el.html template(legs: @_legData())
      this

    selectLeg: (e) =>
      idx = $(e.target).closest('[data-leg]').data('leg')
      Reitti.Router.navigateToRoutes _.extend(@routeParams, legIndex: idx)
      false

    onRoutesChanged: (routes, routeParams) =>
      isThis = routes is @routes and routeParams.routeIndex is @index
      @expandOrCollapse isThis
      @$el.find('[data-leg]').removeClass 'selected'
      if isThis and routeParams.legIndex?
        @$el.find("[data-leg=#{routeParams.legIndex}]").addClass 'selected'

    expandOrCollapse: (expanded) =>
      if @expanded isnt expanded
        @expanded = expanded
        @$el.toggleClass 'expanded', @expanded
        if @expanded then @_expand() else @_collapse()

    _expand: () ->
      widths = ($(leg).width() for leg in @$el.find '.leg')
      totalWidth = _.reduce widths, (t,w) -> t + w
      heightRatio = EXPANDED_HEIGHT / totalWidth
      heights = (Math.floor(_.max [width * heightRatio, MINIMUM_LEG_HEIGHT]) for width in widths)
      totalHeight = _.reduce heights, (t,h) -> t + h

      @$el.css 'height', totalHeight
      @_moveLegsToTheSide heights
      @_showLegInfos heights

    _collapse: () ->
      @$el.css height: ''
      @_moveLegsToTheTop()
      @_hideLegInfos()

    _moveLegsToTheSide: (legHeights) ->
      cumulativeHeight = 0
      for leg, index in @$el.find('.leg[data-leg]')
        height = legHeights[index]
        $(leg).data
          collapsedLeft: $(leg).css 'left'
          collapsedWidth: $(leg).css 'width'
        $(leg).css
          top: cumulativeHeight
          height: height - 1 # Leave one pixel for the "gutter"
          left: 0
          width: '25px'
        $('.leg-bar', leg).css 'height', height - 5 # gutter + 2 x padding (ToDO: this isn't the place for this sort of thing)      
        cumulativeHeight += height  

    _moveLegsToTheTop: () ->
      for leg in @$el.find('.leg[data-leg]')
        $(leg).css
          top: '0'
          left: $(leg).data 'collapsedLeft'
          width: $(leg).data 'collapsedWidth'
          height: ''
        $('.leg-bar', leg).css height: ''

    _showLegInfos: (legHeights) ->
      cumulativeHeight = 0
      for legInfo, index in @$el.find('.leg-info[data-leg]')
        height = legHeights[index]
        $(legInfo).show().css top: Math.floor(cumulativeHeight), height: "#{height-1}px"
        $('*', legInfo).css 'lineHeight', "#{height-1}px"
        cumulativeHeight += height

    _hideLegInfos: () ->
      @$el.find('.leg-info').hide()

    _legData: () ->
      cumulativePercentage = 0
      for leg,legIdx in @route.get('legs')
        percentage = @routes.getLegDurationPercentage(@index, legIdx)
        percentageBefore = cumulativePercentage
        cumulativePercentage += percentage

        {
          type: leg.get('type')
          indicator: @_legIndicator(leg)
          times: @_timeLabel(leg, legIdx)
          transport: @_transportLabel(leg)
          destination: @_destinationLabel(leg, legIdx)
          firstArrivalTime: Utils.formatTimeForHumans(leg.firstArrivalTime())
          destinationName: @_destinationLabel(leg, legIdx)
          color: Utils.transportColors[leg.get('type')]
          percentage: percentage
          percentageBefore: percentageBefore
          iconVisible: percentage > 5
        }

    _legIndicator: (leg) ->
      switch leg.get('type')
        when 'walk' then ''
        else leg.lineName()


    _timeLabel: (leg) ->
      "#{Utils.formatTimeForHumans(leg.firstArrivalTime())} - #{Utils.formatTimeForHumans(leg.lastArrivalTime())}"

    _destinationLabel: (leg, legIdx) ->
      if leg is @route.lastLeg()
          to = @routes.toName
          cityIdx = to.lastIndexOf(',')
          if cityIdx < 0 then to else to.substring(0, cityIdx)
       else
         leg.destinationName()

    _transportLabel: (leg) ->
      type = leg.get('type')
      content = switch type
        when 'walk' then "#{@_transportTypeLabel(type)}, #{Utils.formatDistance(leg.get('length'))}"
        when '6','7' then "<strong>#{@_transportTypeLabel(type)}</strong>"
        when '12' then "<strong>#{leg.lineName()}-#{@_transportTypeLabel(type)}</strong>"
        else  "<strong>#{leg.lineName()}</strong>"
      new Handlebars.SafeString content

    # TODO: This should be somewhere in i18n
    _transportTypeLabel: (type) ->
      switch type
        when 'walk' then 'kävely'
        when '2' then "ratikka"
        when '6' then "metro"
        when '7' then "lautta"
        when '12' then "juna"
        else "bussi"

