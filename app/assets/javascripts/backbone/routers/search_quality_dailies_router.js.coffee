class Searchad.Routers.SearchQualityDailiesRouter extends Backbone.Router
  initialize: (options) ->
    @controller = options.controller

  routes:
    "(filters/date/(:date))"        : "index"
    ".*"        : "index"

  newSearchQualityDaily: ->
    @view = new Searchad.Views.SearchQualityDailies.NewView(collection: @search_quality_dailies)
    $("#search_quality_dailies").html(@view.render().el)

  index: (params) =>
    @controller.trigger('search_quality_dailies:index', date: params)

  show: (id) ->
    search_quality_daily = @search_quality_dailies.get(id)

    @view = new Searchad.Views.SearchQualityDailies.ShowView(model: search_quality_daily)
    $("#search_quality_dailies").html(@view.render().el)

  edit: (id) ->
    search_quality_daily = @search_quality_dailies.get(id)

    @view = new Searchad.Views.SearchQualityDailies.EditView(model: search_quality_daily)
    $("#search_quality_dailies").html(@view.render().el)
