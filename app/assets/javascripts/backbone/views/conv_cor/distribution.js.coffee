#= require backbone/views/conv_cor/index

class Searchad.Views.ConvCorrelation.Distribution extends Searchad.Views.ConvCorrelation.Index
  initialize: (options) ->
    active: false
    @navBar = JST["backbone/templates/conv_cor_navbar"]
    super(options)
    $(document).scroll((e) =>
      return unless @active
      return unless @navBarDiv?
      topPosition = @$el.position().top
      navBarWidth = @navBarDiv.width()
      if window.pageYOffset >= topPosition
        @navBarDiv.addClass('fixed-navbar')
        @navBarDiv.css('width', navBarWidth)
      else if window.pageYOffset < topPosition and @navBarDiv.hasClass('fixed-navbar')
        @navBarDiv.removeClass('fixed-navbar')
        @navBarDiv.css('width', '')
    )

  events: =>
    'click a.distribution': (e) =>
      e.preventDefault()
      $('html, body').animate({scrollTop: @$el.offset().top}, 1000)
    'click a.brand': (e) =>
      e.preventDefault()
      window.scrollTo(0, 0)
    'click a.winners': (e) =>
      e.preventDefault()
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      div = @$el.parents('#conv-cor-distribution').children('div.winners')
      $('html, body').animate({scrollTop: div.offset().top}, 1000)
    'click a.timeline': (e) =>
      e.preventDefault()
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      div = @$el.parents('#conv-cor-distribution').children('div.timeline')
      $('html, body').animate({scrollTop: div.offset().top}, 1000)

  initChart: (cat_data, series_data) ->
    @$el.highcharts(
      chart:
        type: 'column'
        height: 400
        width: 700
      credits:
        enabled: false
      xAxis:
        categories: cat_data
      yAxis:
        title:
          text: 'Query Count'
      title:
        text: 'Query Distribution'
        useHTML: true
        align: "center"
        floating: true
      plotOptions:
        series:
          marker:
            enabled: false
            states:
              hover:
                enabled: true
      legend:
        enabled: true
        layout: 'horizontal'
        align: 'center'
        verticalAlign: 'bottom'
        borderWidth: 0
      series: [{
        name: 'Conversion Relevance Correlation Score'
        data: series_data}]
    )
    @$el.prepend('<div class="metrics-summary-head">Query Distribution</div>')
    @$el.prepend( @navBar() )
    @navBarDiv = @$el.find('.second-navbar')
    
  unrender: =>
    @active = false
    @$el.highcharts().destroy() if @$el and @$el.highcharts()
  
  get_items: (query_segment) ->
    @active = true
    data = {}
    data.query_segment = query_segment
    for k, v of @controller.get_filter_params()
      continue unless v
      data[k] = v
    $.ajax(
      url: '/conv_cor/get_distribution.json'
      data: data
      success: (json, status) =>
        if json.length > 0
          [cat_data, series_data] = @process_data(json)
          @render(cat_data, series_data)
        else
          @render_error(data.query)
    )

  process_data: (data) ->
    cat_data = []
    series_data = []
    for k in data
      cat_data.push(k.ndcg_cat)
      series_data.push(k.query_vol)

    [cat_data, series_data]

  render_error: ->
    return unless @active
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available") )

  render: (cat_data, series_data) ->
    return unless @active
    @initChart(cat_data, series_data)
