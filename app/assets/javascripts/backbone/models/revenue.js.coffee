#= require backbone/models/conv_cor

class Searchad.Models.RevenueWinner extends Backbone.Model
class Searchad.Models.RevenueDistribution extends Backbone.Model
class Searchad.Models.RevenueStats extends Backbone.Model

class Searchad.Collections.RevenueWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.RevenueWinner
  url: '/revenue/get_trending'
  
class Searchad.Collections.RevenueDistribution extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.RevenueDistribution
  url: '/revenue/get_distribution.json'
  
class Searchad.Collections.RevenueStats extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.RevenueStats
  url: '/revenue/get_stats.json'
