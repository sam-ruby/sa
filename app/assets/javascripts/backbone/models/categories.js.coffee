class Searchad.Models.Category extends Backbone.Model

class Searchad.Collections.Categories extends Backbone.Collection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.Category
  url: '/category/get_children.json'
  mode: 'client'

  what: (cat_id) =>
    cat_id = 0 unless cat_id?
    @cat_id = cat_id
    @cat_name = 'All Departments'
    super(
      reset: true
      data:
        cat_id: cat_id)
