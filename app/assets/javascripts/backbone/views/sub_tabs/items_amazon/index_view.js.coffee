#= require backbone/views/base

Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.AmazonItems ||= {}

class Searchad.Views.SubTabs.AmazonItems.IndexView extends Searchad.Views.Base
  initialize: (options) =>
    @$el.hide()
    @collection = new Searchad.Collections.CAAmazonItemsCollection()
    class @AmazonCollection extends Backbone.PageableCollection
      mode: 'client'
      state:
        pageSize: 10
    @amazonCollection = new @AmazonCollection()
    super()
    @collection.bind('reset', @process_all_items)
    @collection.bind('reset', (collection) =>
      that = this
      that.controller.trigger('search:sub-content:hide-spin')
      if collection.at(0).get('all_items').length > 0
        that.controller.trigger('search:amazon-items:stats',
          query: that.query
          collection: collection)
    )

    @collection.bind('request', =>
      @$el.show()
      @delegateEvents()
      @controller.trigger('search:sub-content:show-spin')
    )

    @query = ''
    
    @controller.bind('search:amazon-items:in-top-32', @process_in_top_32)
    @controller.bind(
      'search:amazon-items:not-in-top-32', @process_not_in_top_32)
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    
    Utils.InitExportCsv(this, "/comp_analysis/get_amazon_items.csv")
    @init_table()
    @undelegateEvents()
    @active = false
 
  events: =>
    'click li.all-items': (e) ->
      e.preventDefault()
      @process_all_items()
    'click li.in-top-32': (e) ->
      e.preventDefault()
      @process_in_top_32()
    'click li.not-in-top-32': (e) ->
      e.preventDefault()
      @process_not_in_top_32()
    'click .export-csv a': (e) =>
      query = @query.replace(/\s+/g, '_')
      query = query.replace(/"|'/, '')
      fileName = "competitive_analysis_" + query + ".csv"
      data =
        query: @query
        view: 'daily'
        date: @controller.get_filter_params().date
      @export_csv($(e.target), data)

  gridColumns: =>
    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/poor_performing/amazon_item/item"]
      
      render: =>
        url = @model.get('url')
        unless url.match(/www.amazon.com/i)
          if url.indexOf('/') == 0
            url = 'http://www.amazon.com' + url
          else
            url = 'http://www.amazon.com/' + url
        item =
          image_url: @model.get('img_url')
          url: url
          name: @model.get('name')
        
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this
      
    class WalmartPriceCell extends Backgrid.Cell
      render: =>
        @$el.empty()
        amazon_price = @model.get("newprice")
        walmart_item_id = @model.get('item_id')
        walmart_price = @model.get("curr_item_price")
        walmart_price = walmart_price.toFixed(2) if walmart_price
        price_string = ""
      
        walmart_item_link = '<span class="pull-right">' +
          '<a href="http://www.walmart.com/ip/' +
          walmart_item_id + '" target="_blank">' +
          '<img src="/assets/walmart-transparent.png" class="walmart-icon"></a>' +
          '</span>'

        if walmart_price == null
          price_string =
            "<span class='walmart_price not_carried'>Not Carried</span>"
        else if walmart_price > amazon_price
          price_string = walmart_item_link +
            "<span class='walmart_price more_expensive'>$" +
            walmart_price+' (More Expensive)'+"</span>"
        else
          price_string = walmart_item_link +
            "<span class='walmart_price less_expensive'>$" +
            walmart_price+"</span>"

        @$el.html(price_string)
        this.delegateEvents()
        return this

    class WalmartPosition extends Backgrid.IntegerCell
      render: =>
        @$el.empty()
        position = @model.get(@column.get('name'))
        if !position?
          @$el.append('<span class="walmart-position">Not in Top 32</span>')
        else super()
        this

    columns = [{
    name: 'position',
    label: 'Amazon Position'
    editable: false,
    cell: 'integer'},
    {name: 'name',
    label: 'Amazon Item',
    editable: false,
    cell: ItemCell},
    {name: "newprice",
    label: "Amazon Price",
    editable: false,
    cell: "number",
    formatter: Utils.CurrencyFormatter},
    {name: 'brand',
    label: I18n.t('dashboard2.brand'),
    editable: false,
    cell: 'string'},
    {name: 'walmart_position',
    label: 'Walmart Position'
    editable: false,
    cell: WalmartPosition},
    {name: "curr_item_price",
    editable: false,
    label: "Walmart Price",
    cell: WalmartPriceCell}]
    
    columns

  init_table: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @amazonCollection
      emptyText: 'No Data'
    )
    @$el.append( @grid.render().$el)
    @$el.append( @export_csv_button() )

  unrender: =>
    @active = false
    @$el.hide()
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()

  get_items: (data) =>
    @active = true
    @query = data.query if data
    @controller.trigger('search:sub-content:show-spin')
    @collection.get_items(data)

  process_all_items: =>
    @controller.trigger('search:sub-content:hide-spin')
    @$el.find('li.active').removeClass('active')
    @$el.find('li.all-items').addClass('active')
    data = @collection.at(0).get('all_items')
    @amazonCollection.reset(_.clone(data))

  process_in_top_32: =>
    @$el.find('li.active').removeClass('active')
    @$el.find('li.in-top-32').addClass('active')
    data = @collection.at(0).get('in_top_32')
    @amazonCollection.reset(_.clone(data))

  process_not_in_top_32: =>
    @$el.find('li.active').removeClass('active')
    @$el.find('li.not-in-top-32').addClass('active')
    data = @collection.at(0).get('not_in_top_32')
    @amazonCollection.reset(_.clone(data))
