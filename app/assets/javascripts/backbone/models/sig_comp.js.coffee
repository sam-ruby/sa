#= require backbone/models/conv_cor

class Searchad.Models.SignalComparison extends Backbone.Model
class Searchad.Collections.SignalComparison extends Searchad.Collections.ConvCorrelation
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    super(options)

  model: Searchad.Models.SignalComparison
  url: =>
    @controller.svc_base_url + '/signals/get_item_signals'
  comparator: (a, b) ->
    val_a = parseInt(a.get('in_top_16')) * 100 + parseInt(a.get('position'))
    val_b = parseInt(b.get('in_top_16')) * 100 + parseInt(b.get('position'))
    if val_a >= val_b
      1
    else if val_a < val_b
      -1
    else
      0
