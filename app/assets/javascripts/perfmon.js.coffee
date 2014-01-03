# window.Dod ||= {}
# window.Dod.PerfMon = do ->
#   $ = jQuery
#   timeZoneOffset = new Date().getTimezoneOffset()*60000
#   minToLocalMillisec = (minutes) ->
#     return minutes * 60000 - timeZoneOffset

#   dateToLocalMillisec = (date_str) ->
#     Date.parse(date_str) - timeZoneOffset

#   plotOptions =
#     series:
#       marker:
#         enabled: false,
#         states:
#           hover:
#             enabled: true
      
#   credits =
#     enabled: false

#   sharedTooltip =
#     shared: true
#     crosshairs: true

#   lineColor = "#DEB887"
#   revenueColor = "#C0C0C0"

#   tooltip = (view) ->
#     shared: true,
#     crosshairs: true,
#     formatter: ->
#       s = Highcharts.dateFormat('%A, %b %e, %Y', @x)
#       if view == "weekly"
#         s = "Week from " + s
#       colors = ["#7796BF", "#985B61", "#8F914D", lineColor, revenueColor]
#       for point, i in @points
#         s += "<br/><span style='color:#{colors[i]}'>
#           #{point.series.name}</span>: <b>"
#         if i < 3
#           s += Highcharts.numberFormat(point.y, 2) + '%'
#         else
#           s += Highcharts.numberFormat(point.y, 0)
#       s += "</b>"
#       s
      
#   xAxisLabelFormatter = ->
#     Highcharts.dateFormat('%b %e', @value)

#   getDateFromMilliSec = (millisec) ->
#     new Date(millisec + (new Date(millisec)).getTimezoneOffset() * 60000)

#   getYearWeekFromMilliSec = (millisec) ->
#     date = getDateFromMilliSec(millisec)
#     year = date.getFullYear()
#     newYear = new Date(year, 0, 1);  #local time
#     newYear_milli = newYear.getTime()
    
#     if (millisec == newYear_milli)
#       return [year, 0]
#     week = Math.floor((millisec - newYear_milli)/(7*24*3600*1000))
    
#     if newYear.getDay() != 6
#       week += 1
#     [year, week]

#   change_time = (view, data) ->
#     yr_wk = getYearWeekFromMilliSec(data.x)
#     old_url = window.location.search.split('&')
#     new_url = []
#     if view == 'weekly'
#       new_url = (name_val for name_val in old_url when \
#       name_val.match(/(week|year)=/) is null)
#       new_url.push('week=' + yr_wk[1])
#       new_url.push('year=' + yr_wk[0])
#     else if (view == 'daily')
#       chartDate = getDateFromMilliSec(data.x)
#       chartDate = chartDate.getFullYear() + '-' +
#         (chartDate.getMonth() + 1) + '-' + chartDate.getDate()
#       new_url = (name_val for name_val in old_url when \
#       name_val.match(/date=/) is null)
#       new_url.push('date=' + chartDate)
#     window.location.search = new_url.join('&')

#   initChart = (dateFieldName, view, title, json, props, content_el) ->
#     #if type == 'category'
#     #  dateFieldName = 'date'
#     #else if type == 'query'
#     #  dateFieldName = 'query_date'
#     #else if type == 'item'
#     #  dateFieldName = 'query_date'
#     xAxis =
#       type: 'datetime',
#       labels:
#         formatter: xAxisLabelFormatter
    
#     form = $("#drill-form")
#     point =
#       events:
#         click: -> change_time(view, this)
     
#     arr = []
#     arr.push([]) for prop in props
#     for data in json
#       for prop, i in props
#         arr[i].push(
#           x: Date.parse(data[dateFieldName])
#           y: parseFloat(data[prop.column])
#         )

#     series = []
#     for prop, i in props
#       series.push(
#         name: prop.name
#         data: arr[i]
#         cursor: "pointer"
#         point: point
#       )
#       series[i].type = if i < 3 then 'area' else 'line'
#       series[i].yAxis = 1 if i >= 3
    
#     series[3].color = lineColor
#     series[4].color = revenueColor
    
#     yAxis = [{title: {text: 'percent'},
#     max: 100,
#     showLastLabel: false,
#     gridLineWidth: 0},
#     {title: 'count',
#     opposite: true,
#     type: 'linear',
#     gridLineWidth: 0}]
    
#     chart1 = new Highcharts.Chart(
#       chart:
#         renderTo: content_el
#         alignTicks: false
#        title:
#          text: title
#        credits: credits
#        xAxis: xAxis
#        yAxis: yAxis
#        plotOptions: plotOptions
#        tooltip: tooltip(view)
#        series: series
#     )

#   initChart: initChart

