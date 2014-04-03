#= require backbone/models/conv_cor
class Searchad.Models.SummaryMetric extends Backbone.Model

class Searchad.Collections.SummaryMetric extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.SummaryMetric
  url: '/get_daily_change'
