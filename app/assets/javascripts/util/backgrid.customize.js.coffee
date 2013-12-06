


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
    Backgrid.HeaderCell::initialize.call this, options

  render: ->
    @$el.empty()
    column = @column
    columnName = column.get("name")
    $label = $("<a id=" + column.get("name") + "</a>").text(column.get("label"))
    
    # var sortable = Backgrid.callByNeed(column.sortable(), column, this.collection);
    # if (sortable) $label.append("<b class='sort-caret'></b>");
    @$el.append $label
    @$el.addClass columnName
    @delegateEvents()
    @direction column.get("direction")
    @$el.append "<i class=\"icon-question-sign icon-large info pull-right\" style=\"color:#49afcd\"/>"  if Searchad.helpInfo.hasOwnProperty(columnName)
    this

  showDetails: (e) ->
    that = this
    columnName = that.column.get("name")
    helpText = Searchad.helpInfo["" + columnName]["description"]
    @$(".info").tooltip
      title: helpText
      placement: "right"
      html: true

    @$(".info").tooltip "show"

  hideDetails: (e) ->
    @$(".info").tooltip "hide"
)
