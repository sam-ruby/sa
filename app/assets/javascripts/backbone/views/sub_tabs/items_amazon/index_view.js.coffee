#= require backbone/views/base

Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.AmazonItems ||= {}

class Searchad.Views.SubTabs.AmazonItems.IndexView extends Searchad.Views.Base
  initialize: (options) =>
    @collection = new Searchad.Collections.CAAmazonItemsCollection()
    super()
    @collection.bind('reset', @render_all_items)
    @collection.bind('reset', (collection) =>
      that = this
      if collection.at(0).get('all_items').length > 0
        that.controller.trigger('search:amazon-items:stats',
          query: that.query
          collection: collection)
    )
    @collection.bind('request', =>
      @$el.children().not('ul').remove()
      @$el.hide()
      @controller.trigger('search:sub-content:show-spin')
      @undelegateEvents()
    )

    @query = ''
    
    @controller.bind('search:amazon-items:in-top-32', @render_in_top_32)
    @controller.bind(
      'search:amazon-items:not-in-top-32', @render_not_in_top_32)
    @controller.bind('date-changed', =>
      @get_items() if @active)

    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    Utils.InitExportCsv(this, "/comp_analysis/get_amazon_items.csv")
    @undelegateEvents()
    @active = false
 
  events: =>
    'click li.all-items': (e) ->
      e.preventDefault()
      @render_all_items()
    'click li.in-top-32': (e) ->
      e.preventDefault()
      @render_in_top_32()
    'click li.not-in-top-32': (e) ->
      e.preventDefault()
      @render_not_in_top_32()
    'click .export-csv a': (e) ->
      query = @query.replace(/\s+/g, '_')
      query = query.replace(/"|'/, '')
      fileName = "competitive_analysis_" + query + ".csv"
      data =
        query: @query
        view: 'daily'
        date: @controller.get_filter_params().date
      @export_csv($(e.target), fileName, data)

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
        walmart_price = walmart_price.toFixed(2) if walmart_price
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
    label: 'Amazon Position'
    editable: false,
    formatter: @CadIntFormatter,
    cell: 'integer'},
    {name: 'name',
    label: I18n.t('dashboard.item'),
    editable: false,
    cell: ItemCell},
    {name: 'walmart_position',
    label: 'Walmart Position'
    editable: false,
    formatter: @CadIntFormatter,
    cell: 'integer'},
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
      emptyText: 'No Data'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @amazonCollection
    )
   
  unrender: =>
    @active = false
    @$el.children().not('ul').remove()
    @$el.hide()
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()

  get_items: (data) =>
    @active = true
    @query = data.query if data
    @controller.trigger('search:sub-content:show-spin')
    @collection.get_items(data)

  processData: (data) =>
    @amazonCollection =
      new Searchad.Collections.PoorPerfAmazonItemsCollection(data)
    @initTable()
    @amazonCollection.bind('reset', @render)
    @$el.children().not('ul').remove()
    @controller.trigger('search:sub-content:hide-spin')
    @render()

  render: =>
    return unless @active
    @$el.show()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    this

  render_all_items: =>
    @controller.trigger('search:sub-content:hide-spin')
    @$el.find('li.active').removeClass('active')
    @$el.find('li.all-items').addClass('active')
    data = @collection.at(0).get('all_items')
    @processData(_.clone(data))

  render_in_top_32: =>
    @$el.find('li.active').removeClass('active')
    @$el.find('li.in-top-32').addClass('active')
    data = @collection.at(0).get('in_top_32')
    @processData(_.clone(data))

  render_not_in_top_32: =>
    @$el.find('li.active').removeClass('active')
    @$el.find('li.not-in-top-32').addClass('active')
    data = @collection.at(0).get('not_in_top_32')
    @processData(_.clone(data))
