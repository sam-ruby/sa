#= require backbone/models/conv_cor

class Searchad.Models.P1OosWinner extends Backbone.Model

class Searchad.Collections.P1OosWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.P1OosWinner
  url: '/p1_oos/get_trending'
