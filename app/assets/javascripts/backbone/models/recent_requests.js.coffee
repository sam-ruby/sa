#= require backbone/models/conv_cor
Searchad.Models.PolarisComp = {}
Searchad.Collections.PolarisComp = {}

class Searchad.Models.PolarisComp.RecentRequest extends Backbone.Model
class Searchad.Collections.PolarisComp.RecentRequests extends Searchad.Collections.ConvCorrelation
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.PolarisComp.RecentRequest
  url: =>
    @controller.svc_base_url + '/engine_stats/get_job_list'

  state:
    pageSize: 10

  mode: 'client'
  queryParams:
    user_id: ->
      @controller.user_id

  get_items: (data)=>
    @fetch(
      reset: true
      data: data
      headers:
        'If-None-Match': "")
