#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Searchad =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  
window.SearchQualityApp = do ->
  class Controller
    set_view: (@view) =>
    get_view: => @view
    set_date: (@date) =>
    set_cat_id: (@cat_id) =>
    set_metrics_name: (metric_name) =>
      metrics = Searchad.Views.SummaryMetrics.prototype.metrics_name
      for key, value of metrics when value.id == metric_name
        @metrics_name = key
    set_query_segment: (@query_segment) =>
    get_filter_params: =>
      date: @date
      week: @week
      year: @year
      cat_id: @cat_id
      query_segment: @query_segment
      metrics_name: @metrics_name
  controller = new Controller()
  _.extend(controller, Backbone.Events)
  
  Controller: controller
  
window.Utils = do ->
  updateParam = (str, pName, pValue) ->
    if str is ''
      parts = []
    else
      parts = str.split('/')
    partsCopy = parts.slice(0)

    for name, i in parts when name is pName
      partsCopy.splice(i, 2)
    partsCopy.push(pName, pValue)
    partsCopy.join('/')

  updateURLParam = (location, fName, fValue, filter=false) ->
    if location.indexOf('filters') >=0
      parts = location.split('filters/')
      filterURL = parts[1]
      pathURL = parts[0]
    else
      filterURL = ''
      pathURL = location
    pathURL += '/' if pathURL.lastIndexOf('/') != (pathURL.length - 1)

    if filter
      newFilter = updateParam(filterURL, fName, fValue)
      return pathURL + 'filters/' + newFilter
    else
      newPath = updateParam(pathURL, fName, fValue)
      return newPath + 'filters/' + filterURL

  init_csv_export_feature = (view, url) ->
    view.export_csv_button = _.template('<span class="label label-info export-csv pull-right"><a href="#" id="download-csv-btn"><i class="icon icon-download-alt">&nbsp;</i>Download</a></span>')
    view.export_csv = view.export_csv || (el, fileName, data) =>
      MDW.CSVExport.genDownloadCSVFromUrl(el, fileName, url, data)
   
  class PercentFormatter extends Backgrid.NumberFormatter
    decimals: 2
    decimalSeparator: '.'
    orderSeparator: ','
    fromRaw: (rawValue) ->
      return '-' if !rawValue?
      if !isNaN(parseFloat(rawValue))
        try
          "#{super(parseFloat(rawValue))}%"
        catch error
          "#{parseFloat(rawValue)}%"
      else
        '-'
 
  class CustomNumberFormatterNoDecimals extends Backgrid.NumberFormatter
    decimals: 0
    decimalSeparator: '.'
    orderSeparator: ','

    fromRaw: (rawValue) ->
      return '-' unless rawValue?
      if !isNaN(parseFloat(rawValue))
        try
          super(parseFloat(rawValue))
        catch error
          parseFloat(rawValue)
      else
        '-'
  
  class CurrencyFormatter extends Backgrid.NumberFormatter
    decimals: 2
    orderSeparator: ','

    fromRaw: (rawValue) ->
      rawValue = parseFloat(rawValue)
      try
        if rawValue == 0
          '$' + rawValue.toFixed(0)
        else if rawValue < 0
          '- $' + super(Math.abs(rawValue))
        else if rawValue > 0
          '$' + super(rawValue)
        else
          '-'
      catch error
        rawValue
  
  class CustomNumberFormatter extends Backgrid.NumberFormatter
    decimals: 2
    decimalSeparator: '.'
    orderSeparator: ','

    fromRaw: (rawValue) ->
      return '-' if !rawValue?
      if !isNaN(parseFloat(rawValue))
        try
          super(parseFloat(rawValue))
        catch error
          parseFloat(rawValue)
      else
        '-'

  UpdateURLParam: updateURLParam
  PercentFormatter: PercentFormatter
  CurrencyFormatter: CurrencyFormatter
  CustomNumberFormatter: CustomNumberFormatter
  CustomNumberFormatterNoDecimals: CustomNumberFormatterNoDecimals
  InitExportCsv: init_csv_export_feature
