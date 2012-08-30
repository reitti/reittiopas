define(['jquery', 'underscore', 'backbone'], function ($, _, Backbone) {

  return Backbone.View.extend({

    el: $('#search'),

    events: {
      'submit form': 'searchRoute'
    },

    initialize: function () {
      this.$from = this.$el.find('#from');
      this.$to = this.$el.find('#to');

      var that = this;
      EventBus.on('position:updated', _.once(function (position) {
        that.populateFromBox(position, function () {
          that.$to.focus();
        });
      }));
    },

    render: function () {
      this.$from.focus();
      return this;
    },

    searchRoute: function (event) {
      event.preventDefault();

      // TODO: Move this logic somewhere else
      $.getJSON('/routes?from=' + this.$from.val() + '&to=' + this.$to.val(), function (data) {
        EventBus.trigger('route:change', data[0]);
      });
    },

    populateFromBox: function (position, callback) {
      var that = this;
      // TODO: Move this logic somewhere else
      $.getJSON('/address?coords=' + position.coords.longitude + ',' + position.coords.latitude, function (location) {
        that.$el.find('#from').val(location.name);
        callback();
      });
    }
  });
});