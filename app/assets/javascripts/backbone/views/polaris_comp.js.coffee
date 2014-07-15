#= require backbone/views/base
class Searchad.Views.PolarisComparison extends Searchad.Views.Base
  initialize: (feature) ->
    @collection = new Searchad.Collections.PolarisComparisonJobs()
    @template = JST["backbone/templates/pol_comp"]
    @navBar = JST["backbone/templates/mini_navbar"]
    super()
    #@listenTo(@collection, 'request', @prepare_for_render)
    
    @listenTo(@router, 'route:search', (path, filter) =>
      if path.search == 'polaris_comp'
        @get_items(user_id: @controller.user_id)
        @controller.send_event('Polaris Comparison', 'Form Display')
        @render()
    )
    @container = $("<div>")
    @init_render()
  
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
    $(e.target.form).find('input.error, select.error').removeClass('error')
    $(e.target.form).find('select option[value="select_engine"]').attr(
      'selected', true)
    @container.find('form.engine-comp input').val('')

  submit_request: (form)->
    that = this
    switch_1 = $(form).find('input.switch')[0].value
    switch_2 = $(form).find('input.switch')[1].value
    email = @controller.user_email_address
    email = email.split('@')[0] if email?
    data =
      user: email
      engine_1:
        'http://' + $(form).find('input.engine')[0].value + '/search?' + switch_1
      engine_2: 'http://' + $(form).find('input.engine')[1].value + '/search?' + switch_2
    
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
    $(form).find('input.error, select.error').removeClass('error')
    $(form).find('input[type="text"].engine').each(->
      if this.value == ''
        flag = false
        $(this).parents('.controls').find('select').addClass('error')
        $(this).addClass('error')
    )
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
    @container.append(@navBar(title: 'Submit Request for Polaris Comparison'))
    @container.append(@template())

    cols = @grid_cols()
    @grid = new Backgrid.Grid(
      columns: cols
      collection: @collection
      emptyText: 'No Data'
      className: 'winners-grid'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
    @container.append(@navBar(title: 'Recent Requests'))
    @container.append( @grid.render().$el )
    @container.append( @paginator.render().$el )
    this

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
    @collection.get_items(data)
    @collection.getFirstPage()

  prepare_for_render: =>
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').css('display', 'block')