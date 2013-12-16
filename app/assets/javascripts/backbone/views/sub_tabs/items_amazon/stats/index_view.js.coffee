Searchad.Views.Search ||= {}
Searchad.Views.Search.AmazonItems ||= {}
Searchad.Views.Search.AmazonItems.Stats ||= {}

class Searchad.Views.Search.AmazonItems.Stats.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    @data = {}
  
  active: false

  initChart: (series) =>
    @$el.highcharts(
      chart:
        alignTicks: false
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
      title:
        text: "Amazon Top 32 Items Comparison for \"#{series.query}\""
        useHTML: true
        style:
          '-moz-user-select': 'text'
          '-webkit-user-select': 'text'
          '-ms-user-select': 'text'
      tooltip:
        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
      plotOptions:
        pie:
          allowPointSelect: true
          cursor: 'pointer'
          dataLabels:
            enabled: true
            color: '#000000'
            connectColor: '#000000'
            format: '<b>{point.name}</b>: {point.percentage:.1f} %'
      colors: ['rgba(139,188,33,.95)', 'rgba(160,0,0,.75)'],
      series: [
          type: 'pie'
          name: 'Assortment'
          data: [{
            name: 'Walmart Items Shown in Top 32',
            y: series['in_top_32'],
            events:
              click: (e) =>
                @controller.trigger('search:amazon-items:in-top-32')
            },{
              name: 'Walmart Items Not Shown in Top 32',
              y: series['not_in_top_32'],
              events:
                click: (e) =>
                  @controller.trigger('search:amazon-items:not-in-top-32')
            }]
      ])
    
  unrender: =>
    @active = false
    @$el.highcharts().destroy() if @$el.highcharts()
    @$el.children().remove()

  render: (data) ->
    @$el.children().remove()
    collection = data.collection
    if collection and collection.length > 0
      @initChart(
        query: data.query
        in_top_32: collection.at(0).get('in_top_32').length
        not_in_top_32: collection.at(0).get('not_in_top_32').length
      )
    else
      @$el.prepend(
        "<div><h1>No Walmart items found in Amazon Top 32.</h1></div>")
    return this
