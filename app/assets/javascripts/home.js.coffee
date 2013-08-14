do ->
  $ = jQuery
  app = $.sammy '#data-container', ->
    @use('Session')

    @get(/\#\/cat|\#\/$/, Dod.RoutesHome.routes)
    @get '#/query', Dod.RoutesQuery.routes
    @get '#/item', Dod.RoutesItem.routes

    @bind 'changed.cat_id.dod', (e, data) ->
      return if not data or not data.cat_ids
      selector = 'div.cat-breadcrumb-field'
      $(selector).empty()
      cat_ids = data.cat_ids
      @load("/utils/get_cat_map?cat_id=#{cat_ids}").then (js_data) ->
        content = JST['bread_crumb_cats'](
          src_cat_ids: cat_ids
          cat_map: JSON.parse(js_data)
        )
        $(selector).html(content)

  $ ->
    app.run('#/')
