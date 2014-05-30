#= require backbone/models/conv_cor

class Searchad.Models.ONdcgWinner extends Backbone.Model

class Searchad.Collections.ONdcgWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ONdcgWinner
  url: '/o_ndcg/get_trending'
