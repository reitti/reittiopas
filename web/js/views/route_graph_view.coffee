define ['underscore', 'backbone', 'utils', 'handlebars', 'hbs!template/route_graph'], (_, Backbone, Utils, Handlebars, template) ->

  EXPANDED_HEIGHT = 230
  MINIMUM_LEG_HEIGHT = 12

  class RouteGraphView extends Backbone.View

    events:
      'click .leg-info': 'selectLeg'

    initialize: (routes: routes, index: index) ->
      @routes = routes
      @index = index
      @route = routes.at(@index)
      @expanded = false

    render: ->
      @$el.html template(legs: @_legData())
      this

    selectLeg: (e) =>
      idx = $(e.target).closest('[data-leg]').data('leg')
      Reitti.Event.trigger 'leg:change', @route.getLeg(idx)
      false

    expandOrCollapse: (expanded) =>
      if @expanded isnt expanded
        @expanded = expanded
        @$el.toggleClass 'expanded', @expanded
        if @expanded then @_expand() else @_collapse()

    _expand: () ->
      widths = ($(leg).width() for leg in @$el.find '.leg[data-type!=pre_departure][data-type!=post_arrival]')
      totalWidth = _.reduce widths, (t,w) -> t + w
      heightRatio = EXPANDED_HEIGHT / totalWidth
      heights = (Math.floor(_.max [width * heightRatio, MINIMUM_LEG_HEIGHT]) for width in widths)
      totalHeight = _.reduce heights, (t,h) -> t + h

      @$el.css 'height', totalHeight
      @_hidePreAndPostLegs()
      @_moveLegsToTheSide heights
      @_showLegInfos heights

    _collapse: () ->
      @$el.css height: ''
      @_showPreAndPostLegs()
      @_moveLegsToTheTop()
      @_hideLegInfos()

    _hidePreAndPostLegs: () ->
      @$el.find('.leg[data-type=pre_departure], .leg[data-type=post_arrival]').addClass 'hidden'

    _showPreAndPostLegs: () ->
      @$el.find('.leg[data-type=pre_departure], .leg[data-type=post_arrival]').removeClass 'hidden'

    _moveLegsToTheSide: (legHeights) ->
      cumulativeHeight = 0
      for leg, index in @$el.find('.leg[data-leg][data-type!=pre_departure][data-type!=post_arrival]')
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
      for leg in @$el.find('.leg[data-leg][data-type!=pre_departure][data-type!=post_arrival]')
        $(leg).css
          top: '0'
          left: $(leg).data 'collapsedLeft'
          width: $(leg).data 'collapsedWidth'
          height: ''
        $('.leg-bar', leg).css height: ''

    _showLegInfos: (legHeights) ->
      cumulativeHeight = 0
      for legInfo, index in @$el.find('.leg-info[data-leg][data-type!=pre_departure][data-type!=post_arrival]')
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
          firstArrivalTime: Utils.formatTime(leg.firstArrivalTime())
          destinationName: @_destinationLabel(leg, legIdx)
          color: Utils.transportColors[leg.get('type')]
          percentage: percentage
          percentageBefore: percentageBefore
          iconVisible: percentage > 5
        }

    _legIndicator: (leg) ->
      switch leg.get('type')
        when 'walk' then ''
        when 'pre_departure' then (if @routes.isBasedOnArrivalTime() then '' else leg.preDepartureTime())
        when 'post_arrival' then (if @routes.isBasedOnArrivalTime() then leg.postArrivalTime() else '')
        else leg.lineName()


    _timeLabel: (leg) ->
      "#{Utils.formatTime(leg.firstArrivalTime())} - #{Utils.formatTime(leg.lastArrivalTime())}"

    _destinationLabel: (leg, legIdx) ->
      if leg is @route.getLastLegBeforeArrival()
          to = @routes.to
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
        when 'pre_departure', 'post_arrival' then ''
        when '2' then "ratikka"
        when '6' then "metro"
        when '7' then "lautta"
        when '12' then "juna"
        else "bussi"

