#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Searchad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  
window.SearchQualityApp = do ->
  controller = _.extend({}, Backbone.Events)
  controller.set_view = (@view) =>
  controller.get_view = => @view
  controller.set_date = (@date) =>
  # controller.set_week = (@week) =>
  # controller.set_year = (@year) =>
  controller.set_cat_id = (@cat_id) =>

  controller.get_filter_params = =>
    date: @date
    week: @week
    year: @year
    cat_id: @cat_id

  Controller: controller
