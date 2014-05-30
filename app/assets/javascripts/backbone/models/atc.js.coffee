#= require backbone/models/conv_cor

class Searchad.Models.AtcWinner extends Backbone.Model
class Searchad.Models.AtcDistribution extends Backbone.Model
class Searchad.Models.AtcStats extends Backbone.Model

class Searchad.Collections.AtcWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.AtcWinner
  url: '/atc/get_trending'
  
class Searchad.Collections.AtcDistribution extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.AtcDistribution
  url: '/atc/get_distribution.json'
  
class Searchad.Collections.AtcStats extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.AtcStats
  url: '/atc/get_stats.json'
