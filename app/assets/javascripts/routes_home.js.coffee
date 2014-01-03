# window.Dod ||= {}
# window.Dod.RoutesHome = do =>
#   routes = (context, view='weekly') ->
#     cat_id = @params['cat_id'] || '0'
#     if cat_id isnt @session['cat_id']
#       @trigger('changed.cat_id.dod', {cat_ids: cat_id})
#       @session('cat_id', cat_id)

#     $('div#middle-content').show()
#     $('div.query-item-content').remove()

#     # Load the chart data
#     do ->
#       content_els = $('div.chart-container', context.$element())
#       Dod.Utils.set_content('Loading ....', content_els)
#       context.load("/home/cat.json?cat_id=#{cat_id}&data_type=cat_metrics")
#         .then (js_data) ->
#           js_data = JSON.parse(js_data)
#           data = js_data.chart_data
#           title = js_data.chart_title
#           props = js_data.props
#           Dod.PerfMon.initChart(
#             'date', 'weekly', title, data, props, content_els[0])
          
    
#     # Load the sub category_data
#     do ->
#       content_els = $('div#sub_cats div.table-module', context.$element())
#       Dod.Utils.set_content('Loading ....', content_els)
#       context.load("/home/cat?cat_id=#{cat_id}&data_type=sub_cat_metrics")
#         .then (html_data) ->
#           Dod.Utils.set_content(html_data, content_els)
        
#     # Load the up trending items
#     do ->
#       content_els = $('div#top_items div.table-module', context.$element())
#       Dod.Utils.set_content('Loading ....', content_els)
#       context.load("/item/get_up_trending_items?cat_id=#{cat_id}
#         &data_type=sub_cat_metrics")
#         .then (html_data) ->
#           Dod.Utils.set_content(html_data, content_els)
    
#     # Load the down trending items
#     do ->
#       content_els = $('div#down_items div.table-module', context.$element())
#       Dod.Utils.set_content('Loading ....', content_els)
#       context.load("/item/get_down_trending_items?cat_id=#{cat_id}
#         &data_type=sub_cat_metrics")
#         .then (html_data) ->
#           Dod.Utils.set_content(html_data, content_els)

#     # Load the up trending queries
#     do ->
#       content_els = $('div#top_queries div.table-module', context.$element())
#       Dod.Utils.set_content('Loading ....', content_els)
#       context.load("/query/get_up_trending_data?cat_id=#{cat_id}&
#         data_type=sub_cat_metrics")
#         .then (html_data) ->
#           Dod.Utils.set_content(html_data, content_els)

#     # Load the down trending queries
#     do ->
#       content_els = $('div#bad_queries div.table-module', context.$element())
#       Dod.Utils.set_content('Loading ....', content_els)
#       context.load("/query/get_down_trending_data?cat_id=#{cat_id}&
#         data_type=sub_cat_metrics")
#         .then (html_data) ->
#           Dod.Utils.set_content(html_data, content_els)

#     # Load the top sellers
#     do ->
#       content_els = $('div#top_sell div.table-module', context.$element())
#       Dod.Utils.set_content('Loading ....', content_els)
#       context.load("/item/get_top_sellers?cat_id=#{cat_id}
#       &data_type=sub_cat_metrics")
#         .then (html_data) ->
#           Dod.Utils.set_content(html_data, content_els)

#   routes: routes
