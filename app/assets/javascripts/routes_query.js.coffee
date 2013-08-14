window.Dod ||= {}
window.Dod.RoutesQuery = do =>
  routes = (context, view='weekly') ->
    cat_id = @session('cat_id', -> 0)

    # First load the template from Server hiding the exiting one
    $('div#middle-content').hide()
    container = $('div#middle-content').parent()
    $('div.query-item-content').remove()

    # Load the template
    @load('/query').then((html_template) =>
      $(container).append(html_template)
    ).then( =>
        url_parts = []
        query_str = @params['query_str']
        @session('query_str', query_str)
        url_parts.push("query=#{query_str}") if query_str
        url_parts.push("year=#{@session['year']}") if @session['year']
        url_parts.push("week=#{@session['week']}") if @session['week']
        url_parts.push("cat_id=#{@session['cat_id']}") if @session['cat_id']
        url_str = url_parts.join('&')
       
        # Load the chart data
        do =>
          content_els = $('div.query-chart-container', @$element())
          Dod.Utils.set_content('Loading ....', content_els)
          @load("/query/get_metrics?#{url_str}")
            .then (js_data) ->
              js_data = JSON.parse(js_data)
              data = js_data.chart_data
              title = js_data.chart_title
              props = js_data.props
              Dod.PerfMon.initChart(
                'query_date', 'weekly', title, data, props, content_els[0])
     
        do =>
          content_els = $('div#query_items div.table-module')
          Dod.Utils.set_content('Loading ....', content_els)
          @load("/query/get_items?#{url_str}").then (html_data) ->
            Dod.Utils.set_content(html_data, content_els)
          
        do =>
          content_els = $('div#amazon_comparison div.table-module')
          Dod.Utils.set_content('Loading ....', content_els)
          @load("/query/get_amazon_items?#{url_str}").then (html_data) ->
            Dod.Utils.set_content(html_data, content_els)
          )
  
  routes: routes
