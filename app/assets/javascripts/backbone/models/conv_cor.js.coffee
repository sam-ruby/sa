class Searchad.Models.ConvCorWinner extends Backbone.Model
class Searchad.Models.ConvCorDistribution extends Backbone.Model
class Searchad.Models.ConvCorStats extends Backbone.Model

class Searchad.Collections.ConvCorrelation extends Backbone.PageableCollection
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  state:
    pageSize:20

  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @controller.get_filter_params().date
    query_segment: ->
      @controller.get_filter_params().query_segment
    cat_id: ->
      @controller.get_filter_params().cat_id
    winning: ->
      @winning
    metrics_name: ->
      @controller.get_filter_params().metrics_name
    user_id: ->
      @controller.user_id

  mode: 'server'

  get_items: (data) =>
    @state.totalRecords = null
    @state.currentPage = 1
    @fetch(
      reset: true
      data: data
    )

class Searchad.Collections.ConvCorWinners extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ConvCorWinner
  url: '/conv_cor/get_trending'

class Searchad.Collections.ConvCorDistribution extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ConvCorDistribution
  url: '/conv_cor/get_distribution.json'
  
class Searchad.Collections.ConvCorStats extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ConvCorStats
  url: '/conv_cor/get_stats.json'
