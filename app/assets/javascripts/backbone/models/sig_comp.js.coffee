#= require backbone/models/conv_cor

class Searchad.Models.SignalComparison extends Backbone.Model
class Searchad.Collections.SignalComparison extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.SignalComparison
  url: '/signal_comparison/get_signals'

 
