#= require backbone/models/conv_cor

class Searchad.Models.PolarisComparisonJob extends Backbone.Model
class Searchad.Collections.PolarisComparisonJobs extends Searchad.Collections.ConvCorrelation
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.PolarisComparisonJob
  url: =>
    @controller.svc_base_url + '/engine_stats/get_job_list'
