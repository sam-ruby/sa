Searchad.Views.SearchComparison||= {}

class Searchad.Views.SearchComparison.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @collection = new Searchad.Collections.QueryCatMetricsDailyCollection()
    @recent_searches_collection =
      new Searchad.Collections.RecentSearchesCollection()

    @collection.bind('reset', @render_query_results)
    @recent_searches_collection.bind('reset', @render_recent_searches)
    
    @query_form = @$el.find(options.form_selector)
    @before = @$el.find(options.before_selector)
    @after = @$el.find(options.after_selector)
    @comparison = @$el.find(options.comparison_selector)
    @recent_searches = @$el.find(options.recent_searches_selector)

  events:
    'click button.search': 'handle_search'

  form_template: JST['backbone/templates/query_comparison/form']

  active: false

  seriesTypes: [{
    column: "query_pvr"
    name: I18n.t('perf_monitor.product_view_rate_l')},
    {column: "query_atc"
    name: I18n.t('perf_monitor.add_to_cart_rate_l')},
    {column: "query_con"
    name: I18n.t('perf_monitor.conversion_rate_l')}]

  initRecentSearchesTable: =>
    that = this
    class SearchCell extends Backgrid.Cell
      events:
        'click': 'handleSearchClick'
      
      handleSearchClick: (e) =>
        e.preventDefault()
        that.do_search(
          query: @model.get(@column.get('name'))
          query_date: @model.get('query_date')
          selected_week: @model.get('weeks_apart'))
        
      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="search" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this

    columns = [{name: 'query_word',
    label: 'Search Word',
    editable: false
    cell: SearchCell},
    {name: 'query_date',
    label: 'Query Date',
    editable: false,
    cell: 'string'},
    {name: 'weeks_apart',
    label: 'Weeks Apart',
    editable: false,
    cell: 'string'}]

    grid = new Backgrid.Grid(
      className: 'backgrid bg-grid'
      columns: columns
      collection: @recent_searches_collection
    )
    paginator = new Backgrid.Extension.Paginator(
      collection: @recent_searches_collection
    )
    [grid, paginator]

  initRevQueryTable: (data) ->
    columns = [{name: 'query_revenue',
    label: I18n.t('search_analytics.revenue'),
    editable: false,
    cell: 'number',
    formatter: Utils.CurrencyFormatter},
    {name: 'query_count',
    label: I18n.t('search_analytics.queries'),
    editable: false,
    cell: 'integer'}]

    grid = new Backgrid.Grid(
      columns: columns
      collection: new Backbone.Collection(data)
    )
    grid

  initComparisonTable: (data) ->
   class DiffCell extends Backgrid.NumberCell
      render: =>
        @$el.empty()
        diff = @model.get("difference")
        if @model.get('metric') == 'query_revenue'
          diff_str = Utils.CurrencyFormatter.prototype.fromRaw(Math.abs(diff))
        else if @model.get('metric') == 'query_count'
          diff_str = @formatter.fromRaw(Math.abs(diff))
        else
          diff_str = Utils.PercentFormatter.prototype.fromRaw(Math.abs(diff))

        if diff <= 0
          cell = '-' + diff_str
          @$el.addClass('cad-error')
        else
          @$el.addClass('cad-success')
          cell = diff_str

        @$el.html(cell)
        this.delegateEvents()
        return this

    class MetricCell extends Backgrid.NumberCell
      render: =>
        @$el.empty()
        metric = @model.get("metric")
        value = @model.get(@column.attributes.name)
        if metric == 'query_revenue'
          cell_value = Utils.CurrencyFormatter.prototype.fromRaw(value)
        else if metric == 'query_count'
          cell_value = @formatter.fromRaw(value)
        else
          cell_value = Utils.PercentFormatter.prototype.fromRaw(value)

        @$el.html(cell_value)
        this.delegateEvents()
        return this

    columns = [{name: 'title',
    label: 'Metric',
    editable: false,
    cell: 'string'},
    {name: 'before',
    label: 'Before',
    editable: false,
    cell: MetricCell},
    {name: 'after',
    label: 'After',
    editable: false,
    cell: MetricCell},
    {name: 'difference',
    label: 'Difference',
    editable: false,
    cell: DiffCell}]

    grid = new Backgrid.Grid(
      columns: columns
      collection: new Backbone.Collection(data)
    )
    grid

  generateChart: (title, series, dom) ->
    dom.highcharts(
      chart:
        type: 'funnel'
      credits:
        enabled: false
      title:
        text: title
        useHTML: true
        align: "center"
      plotOptions:
        funnel:
          dataLabels:
            color: 'black'
            distance: 2
            format: '<b>{point.name}</b> ({point.y:,.2f}%)'
        series:
          neckWidth: '30%'
          neckHeight: '25%'
      legend:
        enabled: false
      series: series)
 
  do_search: (data) =>
    if data.query
      new_path = 'query_perf_comparison/query/' +
        encodeURIComponent(data.query) + '/wks_apart/' +
        data.selected_week + '/query_date/' +
        encodeURIComponent(data.query_date)
      
      @router.update_path(new_path)
      @get_items(data, false)
  
  handle_search: =>
    data =
      query: @query_form.find('input.search-query').val()
      selected_week: @query_form.find('select').val()
      query_date: @query_form.find('input.datepicker').val()
    @do_search(data)
   
  get_items: (data, refresh_form=true) ->
    @clean_query_results()
    @recent_searches.children().remove()
    if data and data.query
      data.query = decodeURIComponent(data.query)
      data.query_date = decodeURIComponent(data.query_date)
      data.selected_week = parseInt(data.selected_week)
    else
      data =
        query: ''
        selected_week: 1
        query_date: ''
       
    if refresh_form
      $(@query_form).html(@form_template(data))
      @query_form.find('input.datepicker').datepicker()
      @active = true

    if data and data.query
      @query = data.query
      image =$('<img>').addClass('ajax-loader').attr(
        'src', '/assets/ajax_loader.gif').css('display', 'block')
      @before.find('.chart').append(image)
      @after.find('.chart').append(image.clone())
      @recent_searches_collection.fetch(reset: true)
      @collection.get_items(data)
  
  render_query_results: =>
    before_data = @collection.first().get('before_week')
    after_data = @collection.first().get('after_week')
   
    if before_data.error == 1
      @render_error(@before.find('.chart'))
    else
      data = @process_data(before_data.data)
      dom = @before.find('.chart-title')
      dom.append($('<i>').addClass('icon-backward'))
      dom.append($("<span class='h4 lpadding-one-em'>" +
        before_data.title + '</span>'))
      @render_chart(@query, data, @before.find('.chart'))
      #@render_table(before_data.data, @before.find('.table'))

    if after_data.error == 1
      @render_error(@after.find('.chart'))
    else
      data = @process_data(after_data.data)
      dom = @after.find('.chart-title')
      dom.append($("<span class='h4 rpadding-one-em'>" +
        after_data.title + '</div>'))
      dom.append($('<i>').addClass('icon-forward'))
      @render_chart(@query, data, @after.find('.chart'))
      #@render_table(after_data.data, @after.find('.table'))

    if before_data.error == 0 and after_data.error == 0
      comparison_data = []
      col_key_map =
        query_pvr: 'Product View Rate'
        query_con: 'Conversion Rate'
        query_atc: 'Add To Cart Rate'
        query_revenue: 'Revenue'
        query_count: 'Query Count'
      
      for metric, title of col_key_map
        data =
          metric: metric
          title: title
          before: before_data.data[metric]
          after: after_data.data[metric]
          difference: after_data.data[metric] - before_data.data[metric]
        comparison_data.push(data)

      @comparison.append($('<p class="title"> Week over Week comparison </p>'))
      grid = @initComparisonTable(comparison_data)
      @comparison.append(grid.render().$el)

  process_data: (data) ->
    [{data: [
      {name: 'Product View Rate'
      y: data.query_pvr
      dataLabels:
        format: '<b>PVR</b> ({point.y:,.2f}%)'
      },
      {name: 'Add to Cart Rate'
      y: data.query_atc
      },
      {name: 'Conversion Rate'
      y: data.query_con
      }]}]

  render_error: (dom) ->
    dom.children().remove()
    dom.append($('<div class="alert alert-error">No Data available</div>'))

  render_title: (title, css_class, dom) ->
    dom.append($('<i>').addClass(css_class))
    dom.append($("<div class='h4'>" + title + '</div>'))

  render_chart: (title, data, dom) ->
    @generateChart(title, data, dom)
  
  render_table: (data, dom) =>
    grid = @initRevQueryTable(data)
    dom.append(grid.render().$el)

  render_recent_searches: =>
    return if @recent_searches_collection.length is 0
    
    @recent_searches.children().not('p.title').remove()
    [grid, paginator] = @initRecentSearchesTable()
    if @recent_searches.find('p.title').length == 0
      @recent_searches.append($('<p class="title">Recent Searches</p>'))
    @recent_searches.append(grid.render().$el)
    @recent_searches.append(paginator.render().$el)
 
  unrender: =>
    @query_form.children().remove()
    @recent_searches.children().remove()
    @clean_query_results()
    @active = false

  clean_query_results: =>
    @before.highcharts().destroy() if @before.highcharts()
    @after.highcharts().destroy() if @after.highcharts()
    @comparison.children().remove()

    for el in [@before, @after]
      for sub_el in ['.chart-title', '.chart', '.table']
        el.find(sub_el).children().remove()

