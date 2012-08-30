define(['jquery', 'underscore', 'backbone', 'text!templates/search.handlebars'], function ($, _, Backbone, template) {

  return Backbone.View.extend({

    el: $('#search'),

    initialize: function () {
      var that = this;
      EventBus.on('position:updated', _.once(function (position) {
        that.populateFromBox(position, function () {
          that.$el.find('#to').focus();
        });
      }));
    },

    render: function () {
      this.$el.find('#from').focus();
      return this;
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