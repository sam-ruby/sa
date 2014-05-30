#= require backbone/models/conv_cor
class Searchad.Models.OverallMetric extends Backbone.Model

class Searchad.Collections.OverallMetric extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.OverallMetric
  url: '/get_overall_change'
