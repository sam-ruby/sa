Searchad.Views.Categories ||= {}

class Searchad.Views.Categories.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection =
      new Searchad.Collections.Categories()
    @current_template = @getAjaxSpinner()
    @cat_template = JST["backbone/templates/categories"]
    
    @listenTo(@router, 'route', (route, params) =>
      if !@cat_id or @cat_id != @router.cat_id
        @collection.fetch(@router.cat_id)
      @cat_id = @router.cat_id
    )

    @collection.bind('reset', @render)
    @collection.bind('request', @prepare_for_render)
  
  getAjaxSpinner: ->
    "<img src='/assets/ajax_spinner.gif' style='height:20px;width:20px;'/>"

  render: =>
    @$el.find('ul.cat-list').empty()
    @$el.find('ul.cat-list').first().append(
      @cat_template(
        top_cat_id: @collection.cat_id
        top_cat_name: @collection.cat_name
        sub_categories: @collection)
    )

