define [
  'jquery'
  'backbone'
  'models/bookmark'
  'views/bookmark_view'
  'views/search_input_view'
  'utils'
  'hbs!template/bookmarks'
  'i18n!nls/strings'
], ($, Backbone, Bookmark, BookmarkView, SearchInputView, Utils, template, strings) ->
  class BookmarksView extends Backbone.View

    @FULL: 0
    @FIT_TO_ANCHOR: 1

    @ROW_HEIGHT = 45

    el: $('#bookmarks')

    events:
      'click #add-bookmark-button': 'onAddNewBookmark'
      'click #edit-bookmarks-button': 'onEditBookmarks'
      'click #close-bookmarks-button': 'onCloseBookmarks'
      'submit form': 'onCreateBookmark'

    initialize: ({@collection, @anchor, @size}) ->
      @bookmarkViews = []
      @collection.fetch()
      @collection.on 'add', @onBookmarkAdded
      @collection.on 'remove', @onBookmarkRemoved
      Reitti.Event.on 'bookmark:selected', @onCloseBookmarks

    render: =>
      @$el.html template
        strings: strings
        maxContentHeight: @_maxContentHeight()
      for bookmark, idx in @collection.models
        @onBookmarkAdded(bookmark, @collection, {index: idx})
      if !@collection.isEmpty()
        @$el.find('.placeholder').addClass('hidden')
      @_placeWindow()
      @_placeArrow()
      @initTooltips()
      @initTypeahead()
      this

    toggle: ->
      if @$el.is(':hidden')
        @show()
      else
        @hide()
      this

    show: ->
      @$el.show()
      $('html').on 'click', (event) =>
        if @$el.has($(event.target)).length == 0 # If click didn't originate within the popover itself
          @hide()
      this

    hide: ->
      $('html').off 'click'
      @$el.hide()
      this

    onAddNewBookmark: ->
      unless @isAddMode
        @isAddMode = true
        @$el.find('.placeholder').addClass('hidden')
        @$el.find('#new-bookmark').removeClass('hidden')
        @$el.find('#add-bookmark-button').addClass('active')
        @newBookmarkSearchInputView.focus()
      else
        delete @isAddMode
        @newBookmarkSearchInputView.blur()
        @$el.find('#add-bookmark-button').removeClass('active')
        @$el.find('#new-bookmark').addClass('hidden')
        if @bookmarkViews.length is 0
          @$el.find('.placeholder').addClass('hidden')

    onBookmarkAdded: (bookmark, collection, {index}) =>
      el = $(document.createElement('li')).data('index', index)
      bookmarkView = @bookmarkViews[index] = new BookmarkView(el: el, model: bookmark).render()
      @$el.find('#bookmarks-list').prepend(bookmarkView.el)
      @$el.find('#edit-bookmarks-button').removeClass('hidden')

    onBookmarkRemoved: (bookmark, collection, {index}) =>
      @bookmarkViews.splice(index, 1)
      if @bookmarkViews.length is 0
        @$el.find('.placeholder').removeClass('hidden')
        @$el.find('#edit-bookmarks-button').addClass('hidden')

    onEditBookmarks: ->
      unless @isEditMode
        @isEditMode = true
        for bookmarkView in @bookmarkViews
          bookmarkView.editMode()
        @$el.find('#edit-bookmarks-button').addClass('active')
      else
        delete @isEditMode
        for bookmarkView in @bookmarkViews
          bookmarkView.stopEditMode()
        @$el.find('#edit-bookmarks-button').removeClass('active')

    onCreateBookmark: (event) ->
      event.preventDefault()
      name = @$el.find('#new-bookmark-name').val()
      id = @collection.nextId()
      if @collection.create({name, id})
        @newBookmarkSearchInputView.clearError().val('')
        @onAddNewBookmark()
      else
        @newBookmarkSearchInputView.indicateError()

    onCloseBookmarks: =>
      @hide()

    _offset: ->
      left: @anchor.offset().left
      top: if @size is BookmarksView.FULL then @anchor.offset().left else 20

    _placeWindow: ->
      @$el.offset(@_offset()).css(@_width())

    _width: ->
      width: if @size is BookmarksView.FIT_TO_ANCHOR
        @anchor.width()
      else
        $(window).width() - @anchor.offset().left * 2

    _maxContentHeight: ->
      maxNumberOfRows = Math.floor($(window).height() / BookmarksView.ROW_HEIGHT)
      otherRowCount = 2
      "#{(maxNumberOfRows - otherRowCount) * BookmarksView.ROW_HEIGHT - 2}px"

    _placeArrow: ->
      @$el.find('.arrow').css('top', @anchor.offset().top - @$el.offset().top + @anchor.outerHeight() / 2 - 2)

    initTooltips: ->
      unless Modernizr.touch
        @$el.find('a[rel="tooltip"], button[rel="tooltip"]').tooltip()

    initTypeahead: ->
      @newBookmarkSearchInputView = new SearchInputView(el: @$el.find('#new-bookmark-name'))