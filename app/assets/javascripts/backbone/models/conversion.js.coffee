#= require backbone/models/conv_cor

class Searchad.Models.ConversionWinner extends Backbone.Model
class Searchad.Models.ConversionDistribution extends Backbone.Model
class Searchad.Models.ConversionStats extends Backbone.Model

class Searchad.Collections.ConversionWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ConversionWinner
  url: '/conversion/get_trending'
  
class Searchad.Collections.ConversionDistribution extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ConversionDistribution
  url: '/conversion/get_distribution.json'
  
class Searchad.Collections.ConversionStats extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.ConversionStats
  url: '/conversion/get_stats.json'
