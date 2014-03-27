class Searchad.Models.NDCGWinners extends Backbone.Model
class Searchad.Models.NDCGLoosers extends Backbone.Model

class Searchad.Collections.NDCG extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  state:
    pageSize: 10

  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date
    query_segment: ->
      @controller.get_filter_params().query_segment
    cat_id: ->
      @controller.get_filter_params().cat_id

  mode: 'server'

  get_items: (data) =>
    @fetch(
      reset: true
      data: data
    )

class Searchad.Collections.NDCGWinners extends Searchad.Collections.NDCG
  model: Searchad.Models.NDCGWinners
  url: '/ndcg/get_winners'

class Searchad.Collections.NDCGLoosers extends Searchad.Collections.NDCG
  model: Searchad.Models.NDCGLoosers
  url: '/ndcg/get_loosers'
