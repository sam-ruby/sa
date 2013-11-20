Searchad.Views.Search ||= {}
Searchad.Views.Search.AmazonItems ||= {}

class Searchad.Views.Search.AmazonItems.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection = new Searchad.Collections.CAAmazonItemsCollection()
    @collection.bind('reset', @render_all_items)
    @collection.bind('reset', (collection) =>
      that = this
      if collection.at(0).get('all_items').length > 0
        that.controller.trigger('search:amazon-items:stats',
          query: that.query
          collection: collection)
    )
    @query = ''
    
    @controller.bind('search:amazon-items:in-top-32', @render_in_top_32)
    @controller.bind('search:amazon-items:not-in-top-32', @render_not_in_top_32)
    @controller.bind('date-changed', =>
      @get_items() if @active)

    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    @$el.find('li.export-csv').addClass('active')
    @active = false
  
  events: =>
    that = this
    'click li.all-items': (e) ->
      e.preventDefault()
      that.render_all_items()
    'click li.in-top-32': (e) ->
      e.preventDefault()
      that.render_in_top_32()
    'click li.not-in-top-32': (e) ->
      e.preventDefault()
      that.render_not_in_top_32()
    'click li.export-csv': (e) ->
      that.export_csv($(e.target))

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
        walmart_price = @model.get("curr_item_price")
        price_string = ""
      
        if walmart_price == null
          price_string =
            "<div class='walmart_price not_carried'>Not Carried</div>"
        else if walmart_price > amazon_price
          price_string = "<div class='walmart_price more_expensive'>$" +
            walmart_price+' (More Expensive)'+"</div>"
        else
          price_string = "<div class='walmart_price less_expensive'>$" +
            walmart_price+"</div>"

        @$el.html(price_string)
        this.delegateEvents()
        return this

    columns = [{
    name: 'position',
    label: I18n.t('rank'),
    editable: false,
    cell: 'integer'},
    {name: 'name',
    label: I18n.t('dashboard.item'),
    editable: false,
    cell: ItemCell},
    {name: 'brand',
    label: I18n.t('dashboard2.brand'),
    editable: false,
    cell: 'string'},
    {name: "newprice",
    label: "Amazon Price",
    editable: false,
    cell: "number",
    formatter: Utils.CurrencyFormatter},
    {name: "curr_item_price",
    editable: false,
    label: "Walmart Price",
    cell: WalmartPriceCell}]
    
    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @amazonCollection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @amazonCollection
    )
   
  export_csv: (el) =>
    url = "/poor_performing/get_amazon_items.csv"
    query = @query.replace(/\s+/g, '_')
    query = query.replace(/"|'/, '')
    fileName = "amazon_compare_items_" + query + ".csv"
    data =
      query: @query
      view: 'daily'
      date: @date
    MDW.CSVExport.genDownloadCSVFromUrl(el, fileName, url, data)

  unrender: =>
    @active = false
    @$el.children().not('ul').remove()
    @$el.hide()
    @controller.trigger('search:sub-content:hide-spin')

  get_items: (data) =>
    @query = data.query if data
    @controller.trigger('search:sub-content:show-spin')
    @collection.get_items(data)

  processData: (data) =>
    @amazonCollection =
      new Searchad.Collections.PoorPerfAmazonItemsCollection(data)
    @initTable()
    @amazonCollection.bind('reset', @render)
    @render()

  render: =>
    @active = true
    @$el.children().not('ul').remove()
    @controller.trigger('search:sub-content:hide-spin')
    @$el.show()
    @$el.children('ul').show()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    return this

  render_error: (query) ->
    @$el.children().not('ul').remove()
    @controller.trigger('search:sub-content:hide-spin')
    @$el.show()
    @$el.children('ul').hide()
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render_all_items: =>
    @controller.trigger('search:sub-content:hide-spin')
    @$el.find('li.active').not('li.export-csv').removeClass('active')
    @$el.find('li.all-items').addClass('active')
    data = @collection.at(0).get('all_items')
    if data.length > 0
      @processData(_.clone(data))
    else
      @render_error(@query)

  render_in_top_32: =>
    @$el.find('li.active').not('li.export-csv').removeClass('active')
    @$el.find('li.in-top-32').addClass('active')
    data = @collection.at(0).get('in_top_32')
    if data.length > 0
      @processData(_.clone(data))
    else
      @render_error(@query)

  render_not_in_top_32: =>
    @$el.find('li.active').not('li.export-csv').removeClass('active')
    @$el.find('li.not-in-top-32').addClass('active')
    data = @collection.at(0).get('not_in_top_32')
    if data.length > 0
      @processData(_.clone(data))
    else
      @render_error(@query)
