#= require backbone/models/conv_cor
Searchad.Models.QueryLabel = {}
Searchad.Collections.QueryLabel = {}

class Searchad.Models.QueryLabel.Label extends Backbone.Model
class Searchad.Collections.QueryLabel.Labels extends Searchad.Collections.ConvCorrelation
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.QueryLabel.Label
  url: =>
    @controller.svc_base_url + '/labels/get_label_list'

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
