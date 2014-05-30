#= require backbone/models/conv_cor

class Searchad.Models.PvrWinner extends Backbone.Model
class Searchad.Models.PvrDistribution extends Backbone.Model
class Searchad.Models.PvrStats extends Backbone.Model

class Searchad.Collections.PvrWinner extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.PvrWinner
  url: '/pvr/get_trending'
  
class Searchad.Collections.PvrDistribution extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.PvrDistribution
  url: '/pvr/get_distribution.json'
  
class Searchad.Collections.PvrStats extends Searchad.Collections.ConvCorrelation
  model: Searchad.Models.PvrStats
  url: '/pvr/get_stats.json'
