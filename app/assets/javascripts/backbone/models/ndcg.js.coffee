#= require backbone/models/conv_cor

class Searchad.Models.NdcgWinner extends Backbone.Model

class Searchad.Collections.NdcgWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.NdcgWinner
  url: =>
    @controller.svc_base_url + '/opportunities'
