#= require backbone/views/base
class Searchad.Views.PolarisComparison extends Searchad.Views.Base
  initialize: (feature) ->
    @collection = new Searchad.Collections.PolarisComparisonJobs()
    @template = JST["backbone/templates/pol_comp"]
    @navBar = JST["backbone/templates/mini_navbar"]
    super()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    
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
    'click button.submit': (e)=>
      e.preventDefault()
      @submit_request(e.target.form) if @validate_inputs(e.target.form)
    'click button.reset': (e)->
      e.preventDefault()
      $(e.target.form).find('input.error, select.error').removeClass('error')
      $(e.target.form).find('select option[value="select_engine"]').attr(
        'selected', true)
      @container.find('form.engine-comp input').val('')
    'click a.go-back-sm': (e) =>
      query_segment = @router.path.search
      @router.update_path(
        "search/#{query_segment}/page/overview", trigger: true)

  submit_request: (form)->
    that = this
    data =
      user: @controller.user_email_id
      engine_1: $(form).find('input.engine')[0].value
      engine_2: $(form).find('input.engine')[1].value
      switch_1: $(form).find('input.switch')[0].value
      switch_2: $(form).find('input.switch')[1].value
      
    $.ajax(
      @controller.svc_base_url + 'engine_stats/post_request',
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
    @container.find('div.form-engine-comp').toggle('slideup')
    @container.find('div.form-submission-results .error-div').hide()
    @container.find('div.form-submission-results span.job-id').text(job_id)
    @container.find('div.form-submission-results .success-div').show()
    @container.find('div.form-submission-results').show()
  
  show_job_error: (error) ->
    @container.find('div.form-submission-results .success-div').hide()
    @container.find('div.form-submission-results div.error').text(error)
    @container.find('div.form-submission-results .error-div').show()
    @container.find('div.form-submission-results').show()

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
    [{name: 'instance_1',
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
    cell: 'uri'}]

  get_items: (data) ->
    @collection.get_items(data)

  prepare_for_render: =>
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').css('display', 'block')
