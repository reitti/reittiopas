define ['jquery'], ($) ->

  class Route

    @find: (from, to, cb) ->
      params = $.param {from: from, to: to}
      $.getJSON "/routes?#{params}", cb
