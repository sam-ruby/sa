#= require backbone/views/base
class Searchad.Views.PolarisComparison extends Searchad.Views.Base
  initialize: (feature) ->
    @recent_requests = new Searchad.Collections.PolarisComp.RecentRequests()
    @template = JST["backbone/templates/pol_comp"]
    @navBar = JST["backbone/templates/mini_navbar"]
    super()
    
    @carousel = @$el.parents('.carousel.slide')
    @listenTo(@router, 'route:eval', (path, filter) =>
      view = this
      if @router.date_changed or @router.cat_changed or @router.eval_inited
        @dirty = true

      if path.eval == 'pol_eng_comp'
        @controller.set_flight_status(true)
        @carousel.carousel(0).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
        @controller.send_event('Polaris Engine Comparison', 'Form Display')
        
        window.scrollTo(0, 0)
        @render()
        @get_items(user_id: @controller.user_id) if @dirty
      else if path.eval = 'query_samp'
        @controller.set_flight_status(true)
        @carousel.carousel(1).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
    )
    @container = $("<div>")
    @init_render()
    @listenTo(@recent_requests, 'request', @prepare_for_render)
  
  events: =>
    'change select.engine-names': (e) =>
      $(e.target).find('option:selected').each(->
        url = this.value
        $(e.target).parents('.controls').find('input.engine').val(url)
      )
    'click form.engine-comp button.submit': (e)=>
      e.preventDefault()
      if @validate_inputs(e.target.form)
        @submit_request(e.target.form)
        @get_items()
        @reset_form(e)
    'click form.engine-comp button.reset': (e)->
      e.preventDefault()
      @reset_form(e)
    'click a.close': (e)=>
      e.stopPropagation()
      e.preventDefault()
      $(e.target).parents('.alert').removeClass(
        'alert-success').removeClass('alert-error')
      $(e.target).parents('.alert').toggle('slideup')

  reset_form: (e)=>
    $(e.target.form).find(
      '.control-group.error, input.error, select.error').removeClass('error')
    $(e.target.form).find('select option[value="select_engine"]').attr(
      'selected', true)
    $(e.target.form).find('select.query-sample option:selected').attr(
      'selected', false)
    @container.find('form.engine-comp input').val('')

  submit_request: (form)->
    that = this
    switch_1 = $(form).find('input.switch')[0].value
    switch_2 = $(form).find('input.switch')[1].value
    label = $(form).find('select.query-sample').val()
    label = label.join(';') if label
    email = @controller.user_email_address
    email = email.split('@')[0] if email?
    data =
      user: email
      engine_1:
        'http://' + $(form).find('input.engine')[0].value + '/search?' + switch_1
      engine_2:
        'http://' + $(form).find('input.engine')[1].value + '/search?' + switch_2
      query_mix: label

    $.ajax(
      @controller.svc_base_url + '/engine_stats/post_request',
      data: data
      dataType: 'json'
      success: (data, status)->
       results = data
       if (results && results.job_id)
        that.show_job_id(results.job_id)
      error: (jqXhr, status) ->
       that.show_job_error(status)
    )
    
  validate_inputs: (form)->
    flag = true
    that = this
    $(form).find('.control-group.error, input.error, select.error').removeClass('error')
    $(form).find('input[type="text"].engine').each(->
      if this.value == ''
        flag = false
        $(this).parents('.controls').find('select').addClass('error')
        $(this).addClass('error')
    )
    query_sample_select = $(form).find('select.query-sample')
    if query_sample_select.val() and query_sample_select.val().length > 3
      query_sample_select.parents('.control-group').addClass('error')
      flag = false
    flag
  
  show_job_id: (job_id) ->
    form = @container.find('div.form-submission-results')
    form.find('.error-div').hide()
    form.find('span.job-id').text(job_id)
    form.find('.success-div').show()
    if !form.hasClass('alert-success')
      form.addClass('alert-success')
    form.show()
  
  show_job_error: (error) ->
    form = @container.find('div.form-submission-results')
    form.find('.success-div').hide()
    form.find('span.error').text(error)
    form.find('.error-div').show()
    if !form.hasClass('alert-error')
      form.addClass('alert-error')
    form.show()
    
  init_render: =>
    @container.append(@navBar(
      title: 'Submit Request for Polaris Comparison'))
    @container.append(@template())

    @container.append(@navBar(
      title: 'Recent Requests'))
    cols = @grid_cols()
    @grid = new Backgrid.Grid(
      columns: cols
      collection: @recent_requests
      emptyText: 'No Data'
      className: 'winners-grid'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @recent_requests
    )
    @container.append( @grid.render().$el )
    @container.append( @paginator.render().$el )

  render: =>
    that = this
    $.ajax(
      dataType: 'json'
      url: @controller.svc_base_url + '/engine_stats/get_engines'
      success: (data) =>
        that.container.find('select.engine-names').empty()
        @container.find('select.engine-names').append(
          $("<option value='select_engine'>Select One</option>"))
        for name, url of data
          @container.find('select.engine-names').append(
            $("<option value='#{url}'>#{name}</option>"))
      error: =>
        that.container.find('select.engine-names').empty()
        @container.find('select.engine-names').append(
          $("<option value='select_engine'>Error! List Not Available</option>"))

    )
    
    $.ajax(
      dataType: 'json'
      data:
        date: @controller.date
      url: @controller.svc_base_url + '/labels/get_query_sets'
      success: (data) =>
        that.container.find('select.query-sample').empty()
        for label in data
          @container.find('select.query-sample').append(
            $("<option value='#{label.segmentation}'>#{label.segmentation}</option>"))
      error: =>
        that.container.find('select.query-sample').empty()
        @container.find('select.query-sample').append(
          $("<option value='select_query_sample'>Error! List Not Available</option>"))

    )

    @$el.append( @container )
    @delegateEvents()

  grid_cols: =>
    class PolarisJobCell extends Backgrid.UriCell
      render: =>
        super()
        return this if !@model.get(@column.get('name'))?
        @$el.find('a').empty()
        job_id = @model.get('job_id')
        @$el.find('a').attr('download', "Job_Results_#{job_id}.csv}")
        @$el.find('a').append('<i class="icon-download-alt"> Results</i>')
        this

    [{name: 'created',
    label: 'Created On',
    editable: false,
    cell: 'date'},
    {name: 'job_id',
    label: 'Job ID',
    editable: false,
    cell: 'integer'},
    {name: 'instance_1',
    label: 'Polaris 1',
    editable: false,
    headerCell: @QueryHeaderCell,
    cell: 'uri'},
    {name: 'instance_2',
    label: 'Polaris 2',
    editable: false,
    cell: 'uri'},
    {name: 'status',
    label: 'Status',
    editable: false,
    cell: 'string'},
    {name: 'user',
    label: 'User ID',
    editable: false,
    cell: 'string'},
    {name: 'result',
    label: 'Results',
    editable: false,
    cell: PolarisJobCell}]

  get_items: (data) ->
    @recent_requests.get_items(data)

  prepare_for_render: =>
    @container.find('table tbody tr:first-child').empty()
    td = document.createElement("td")
    td.setAttribute("colspan", @grid.columns.length)
    $(td).append($('<img class="ajax-loader-table" src="/assets/ajax_loader.gif"/>'))
    @container.find('table tbody tr:first-child').append(td)

