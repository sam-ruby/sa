class Searchad.Models.ConvCorWinner extends Backbone.Model

class Searchad.Collections.ConvCorrelation extends Backbone.PageableCollection
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

class Searchad.Collections.ConvCorWinners extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ConvCorWinner
  url: '/conv_cor/get_winners'
