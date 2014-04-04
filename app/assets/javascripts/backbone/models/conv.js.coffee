#= require backbone/models/conv_cor

class Searchad.Models.TrafficWinner extends Backbone.Model
class Searchad.Models.TrafficDistribution extends Backbone.Model
class Searchad.Models.TrafficStats extends Backbone.Model

class Searchad.Collections.TrafficWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.TrafficWinner
  url: '/traffic/get_trending'
  
class Searchad.Collections.TrafficDistribution extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.TrafficDistribution
  url: '/traffic/get_distribution.json'
  
class Searchad.Collections.TrafficStats extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.TrafficStats
  url: '/traffic/get_stats.json'
