#= require backbone/views/base
class Searchad.Views.QuerySample extends Searchad.Views.Base
  initialize: (feature) ->
    @query_labels = new Searchad.Collections.QueryLabel.Labels()
    @query_label_upload_template =
      JST["backbone/templates/query_label"]
    @navBar = JST["backbone/templates/mini_navbar"]
    super()
    
    @listenTo(@router, 'route:eval', (path, filter) =>
      view = this
      if @router.date_changed or @router.cat_changed or @router.eval_inited
        @dirty = true
      
      if path.eval== 'query_samp'
        @render()
        @get_items(user_id: @controller.user_id) if  @dirty
        @controller.send_event('Query Set')
    )
    @container = $("<div>")
    @init_render()
    @listenTo(@query_labels, 'request', @prepare_for_render)
  
  events: =>
    'click form.query-label button.upload': (e)=>
      e.preventDefault()
      form_data = new FormData(e.target.form)
      if @validate_inputs(e.target.form)
        @submit_query_set(e.target.form, form_data)
    'click form.query-label button.reset': (e)->
      e.preventDefault()
      @reset_form(e.target.form)
    'click a.close': (e)=>
      e.stopPropagation()
      e.preventDefault()
      $(e.target).parents('.alert').removeClass(
        'alert-success').removeClass('alert-error')
      $(e.target).parents('.alert').toggle('slideup')

  validate_inputs: (form)->
    flag = true
    that = this
    $(form).find('.control-group.error').removeClass('error')
    $(form).find('input.file, input.name').each(->
      if this.value == ''
        flag = false
        $(this).parents('.control-group').addClass('error')
    )
    flag

  reset_form: (form)=>
    $(form).find('.control-group.error').removeClass('error')
    $(form).find('input[type=text], input[type=file]').val('')
    @container.find('.form-submission-query-label').hide()

  submit_query_set: (form, form_data)->
    label = $(form).find('input.name').val()
    that = this
    $.ajax(
      url: @controller.svc_base_url + '/labels/upload_label'
      data: form_data
      cache: false
      contentType: false
      processData: false
      type: 'POST'
      success: (data, status)->
        that.get_items()
        that.query_label_success(label)
      error: (jqXhr, status) ->
        that.query_label_error(label, jqXhr.responseText)
    )

  query_label_success: (label)->
    form = @container.find('div.form-submission-query-label')
    form.removeClass('alert-error')
    form.find('.error-div').hide()
    form.find('span.label-text').text(label)
    form.find('.success-div').show()
    if !form.hasClass('alert-success')
      form.addClass('alert-success')
    form.show()
  
  query_label_error: (label, error) ->
    form = @container.find('div.form-submission-query-label')
    form.removeClass('alert-success')
    form.find('.success-div').hide()
    form.find('span.label-text').text(label)
    form.find('.error-div span.error').text(error)
    form.find('.error-div').show()
    if !form.hasClass('alert-error')
      form.addClass('alert-error')
    form.show()

  init_render: =>
    @container.append(@navBar(
      title: 'Upload a Query Set'))
    @container.append(
        @query_label_upload_template(user: @controller.user_id))
    
    @container.append(@navBar(
      title: 'Query Sets'))
    @grid = new Backgrid.Grid(
      columns: @grid_cols()
      collection: @query_labels
      emptyText: 'No Data'
      className: 'winners-grid'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @query_labels
    )
    @container.append( @grid.render().$el )
    @container.append( @paginator.render().$el )

  render: =>
    that = this
    @$el.append( @container )
    @reset_form()
    @delegateEvents()

  grid_cols: =>
    view = this
    class QueryLabelCell extends Backgrid.UriCell
      render: =>
        label = @model.get('label')
        date = view.controller.date
        @model.set(
          @column.get('name'), view.controller.svc_base_url + "/labels/download_query_set?date=#{date}&query_mix=#{label}")
        super()
        @$el.find('a').empty()
        @$el.find('a').attr('download', "Query_Segment_#{label}.csv}")
        @$el.find('a').append('<i class="icon-download-alt"> Download</i>')
        this

    [{name: 'created',
    label: 'Created On',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'date'},
    {name: 'label',
    label: 'Label',
    editable: false,
    cell: 'string'},
    {name: 'label_size',
    label: 'Label Size',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer'},
    {name: 'user',
    label: 'User ID',
    editable: false,
    cell: 'string'},
    {name: 'download_link',
    label: 'Download Query Set',
    editable: false,
    cell: QueryLabelCell}]

  get_items: (data) ->
    @query_labels.get_items(data)

  prepare_for_render: =>
    @container.find('table tbody tr:first-child').empty()
    td = document.createElement("td")
    td.setAttribute("colspan", @grid.columns.length)
    $(td).append($('<img class="ajax-loader-table" src="/assets/ajax_loader.gif"/>'))
    @container.find('table tbody tr:first-child').append(td)
