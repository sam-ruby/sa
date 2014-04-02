Searchad.Views.TopQuery ||= {}

class Searchad.Views.TopQuery extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    # @collection = new Searchad.Collections.SummaryMetric()
    # @listenTo(@collection, 'reset', @render)
    # @listenTo(@collection, 'request', @prepare_for_render)
    @controller.bind('content-cleanup', @unrender)
    @overview_template = JST["backbone/templates/overview"]
    
    @listenTo(@router, 'route', (route, params) =>
      @$el.children().not('.ajax-loader').remove() if @active
      if route == 'search' and @router.task == 'top'
        @$el.children().not('.ajax-loader').remove()
        @render()
      else
        @active = false
    )
  active: false
  render: =>
    metrics_data = [
      {name: 'Traffic',
      id: 'traffic'},
      {name: 'PVR',
      id: 'pvr'},
      {name: 'ATC',
      id: 'atc'},
      {name: 'Conversion',
      id: 'conversion'},
      #{name: 'Revenue',
      #id: 'revenue'},
      #{name: 'NDCG',
      #id: 'ndcg'},
      {name: 'Rev Relevance Correlation',
      id: 'conv_rel_corr'}]
    
    @$el.append(@overview_template(metrics: metrics_data))
    filter_params = @controller.get_filter_params()
    that = this
    setTimeout(->
      for k in metrics_data
        $.ajax(
          url: '/get_daily_change'
          data:
            metric_id: k.id
            date: filter_params.date
            query_segment: filter_params.query_segment
            cat_id: filter_params.cat_id
          success: (json, status) =>
            if json?
              metric_id = json.metric_id
              score = json.score
              change = json.change
              queries = json.queries
              that.renderMetrics(metric_id, score, change, queries)
        )
    , 500)

  renderMetrics: (metric_id, score, change, queries) =>
    @$el.find("tr.#{metric_id} td").not('.metric-name').remove()
    @$el.find("tr.#{metric_id}").append(
      JST['backbone/templates/daily_metric'](
        score: score
        change: change
        queries: queries) )
