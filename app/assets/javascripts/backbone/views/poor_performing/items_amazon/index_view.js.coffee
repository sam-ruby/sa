Searchad.Views.PoorPerforming.AmazonItems ||= {}

class Searchad.Views.PoorPerforming.AmazonItems.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection = new Searchad.Collections.CAAmazonItemsCollection()
    @collection.bind('reset', @render_all_items)
    @query = ''
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    if options and options.top_32_tab
      @top_32_tab = $(options.top_32_tab)
      @top_32_tab.on('click', 'li.all-items', (e) =>
        e.preventDefault()
        @controller.trigger('ca:amazon-items:all-items'))
      @top_32_tab.on('click', 'li.in-top-32', (e) =>
        e.preventDefault()
        @controller.trigger('ca:amazon-items:in-top-32'))
      @top_32_tab.on('click', 'li.not-in-top-32', (e) =>
        e.preventDefault()
        @controller.trigger('ca:amazon-items:not-in-top-32'))

  active: false

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
    
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @top_32_tab.hide() if @top_32_tab

  get_items: (data) =>
    @query = data.query if data
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)

  processData: (data) =>
    @amazonCollection =
      new Searchad.Collections.PoorPerfAmazonItemsCollection(data)
    @initTable()
    @amazonCollection.bind('reset', @render)
    @render()

  render: =>
    @active = true
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @top_32_tab.show()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    return this

  render_all_items: =>
    @top_32_tab.find('li.active').removeClass('active')
    @top_32_tab.find('li.all-items').addClass('active')
    data = @collection.at(0).get('all_items')
    if data.length > 0
      @processData(_.clone(data))
    else
      @$el.prepend(
        "<div><h1>No Walmart items available for this search term.</h1></div>")

  render_in_top_32: =>
    @top_32_tab.find('li.active').removeClass('active')
    @top_32_tab.find('li.in-top-32').addClass('active')
    data = @collection.at(0).get('in_top_32')
    if data.length > 0
      @processData(_.clone(data))
    else
      @$el.prepend("<div><h1>No Walmart items found.</h1></div>")

  render_not_in_top_32: =>
    @top_32_tab.find('li.active').removeClass('active')
    @top_32_tab.find('li.not-in-top-32').addClass('active')
    data = @collection.at(0).get('not_in_top_32')
    if data.length > 0
      @processData(_.clone(data))
    else
      @$el.prepend("<div><h1>No Walmart items found.</h1></div>")

