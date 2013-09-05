Searchad.Views.PoorPerforming.AmazonItems ||= {}

class Searchad.Views.PoorPerforming.AmazonItems.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render')
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.PoorPerfAmazonItemsCollection()
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @collection.bind('reset', @render)
    @controller.bind('content-cleanup', @unrender)

  active: false

  gridColumns: =>
    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/poor_performing/amazon_item/item"]
      
      render: =>
        item =
          image_url: @model.get('img_url')
          url: @model.get('url')
          name: @model.get('name')
        
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this
      
    class WalmartPriceCell extends Backgrid.Cell
      render: =>
        @$el.empty()
        amazon_price = @model.get("newprice")
        walmart_price = @model.get("walmart_price")
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
    {name: "walmart_price",
    editable: false,
    label: "Walmart Price",
    cell: WalmartPriceCell}]
    
    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)

  render: =>
    @active = true
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    return this
