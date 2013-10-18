Searchad.Views.CompAnalysis.AmazonItems||= {}

class Searchad.Views.CompAnalysis.AmazonItems.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('ca:content-cleanup', @unrender)
    @data = {}
    @chart_container = $(options.chart_container)
  
  active: false

  initChart: (series) =>
    @$el.highcharts(
      chart:
        alignTicks: false
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
      title:
        text: null
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
      colors: ['rgb(47,126,216)', '#b84949'],
      series: [
          type: 'pie'
          name: 'Assortment'
          data: [{
            name: 'Walmart Items Shown in Top 32',
            y: series['in_top_32'],
            events:
              click: (e) =>
                @controller.trigger('ca:amazon-items:in-top-32')
            },{
              name: 'Walmart Items Not Shown in Top 32',
              y: series['not_in_top_32'],
              events:
                click: (e) =>
                  @controller.trigger('ca:amazon-items:not-in-top-32')
            }]
      ])
    
  unrender: =>
    @active = false
    @$el.highcharts().destroy() if @$el.highcharts()
    @$el.children().remove()
    @chart_container.hide()

  render: (data) ->
    @chart_container.show()
    @chart_container.find('em.placeholder').text(data.query)
    @$el.children().remove()
    collection = data.collection
    if collection and collection.length > 0
      @initChart(
        in_top_32: collection.at(0).get('in_top_32').length
        not_in_top_32: collection.at(0).get('not_in_top_32').length
      )
    else
      @$el.prepend(
        "<div><h1>No Walmart items found in Amazon Top 32.</h1></div>")
    return this
