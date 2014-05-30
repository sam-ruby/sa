#= require backbone/models/conv_cor

class Searchad.Models.OosWinner extends Backbone.Model
class Searchad.Models.OosDistribution extends Backbone.Model
class Searchad.Models.OosStats extends Backbone.Model

class Searchad.Collections.OosWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.OosWinner
  url: '/oos/get_trending'
  
class Searchad.Collections.OosDistribution extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.OosDistribution
  url: '/oos/get_distribution.json'
  
class Searchad.Collections.OosStats extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.OosStats
  url: '/oos/get_stats.json'
