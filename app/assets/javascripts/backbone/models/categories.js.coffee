class Searchad.Models.Category extends Backbone.Model

class Searchad.Collections.Categories extends Backbone.Collection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.Category
  url: '/category/get_children.json'
  mode: 'client'

  parse: (response) ->
    if response? and response.cat_name? and response.cat_id?
      @cat_name = response.cat_name
      @cat_id = parseInt(response.cat_id)
    JSON.parse(response.sub_categories)

  fetch: (cat_id) =>
    cat_id = 0 unless cat_id?
    @cat_id = cat_id
    @cat_name = 'All Departments'
    super(
      reset: true
      data:
        cat_id: cat_id)
