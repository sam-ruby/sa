###
CAD Customize backgrid(same as DOD)
@author Linghua Jin
@class Backgrid.CustomHeaderCell
@extend Backgrid HeaderCell
This extension generate a class for header called 'custom'. When specify headerCell: "custom" in backgrid columns, this
will add a question button, and hover show a tool tip for inline help information
###
Backgrid.CustomHeaderCell = Backgrid.HeaderCell.extend(
  className: "custom-header-cell"
  events:
    "click a": "onClick"
    "mouseenter .info": "showDetails"
    "mouseleave .info": "hideDetails"

  initialize: (options) ->
    
    # call standard HeaderCell's initialize
    Backgrid.HeaderCell.prototype.initialize.call(this, options)

  render: ->
    Backgrid.HeaderCell.prototype.render.call(this)
    # if defined in column, use that. else find in general CAD help Info
    if @column.get("helpInfo")
      @$el.append "<i class=\"icon-question-sign icon-large info pull-right\" style=\"color:#49afcd\"/>"
    else if Searchad.helpInfo.hasOwnProperty(@column.get("name"))
      @$el.append "<i class=\"icon-question-sign icon-large info pull-right\" style=\"color:#49afcd\"/>"  
    this

  showDetails: (e) ->
    # that = this
    if @column.get("helpInfo")
      helpText = @column.get("helpInfo")
    else
      columnName = @column.get("name")
      helpText = Searchad.helpInfo["" + columnName]["description"]
    @$(".info").tooltip
      title: helpText
      placement: "right"
      html: true

    @$(".info").tooltip "show"

  hideDetails: (e) ->
    @$(".info").tooltip "hide"
    
)


Backgrid.CADQueryCell = Backgrid.Cell.extend(
  initialize: (options) ->
    Backgrid.Cell.prototype.initialize.call(this, options)
  controller: SearchQualityApp.Controller
  router: SearchQualityApp.Router
  events:
    'click': 'handleQueryClick'
  handleQueryClick: (e) =>
    e.preventDefault()
    $(e.target).parents('table').find('tr.selected').removeClass('selected')
    $(e.target).parents('tr').addClass('selected')
    # trigger controller function
    # update path
  render: ->
    value = @model.get(@column.get('name'))
    formatted_value = '<a class="query" href="#">' + value + '</a>'
    @$el.html(formatted_value)
    @delegateEvents()
    return this
)
