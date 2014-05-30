class Searchad.Models.SignalMapping extends Backbone.Model

class Searchad.Collections.SignalMapping extends Backbone.Collection
  model: Searchad.Models.SignalMapping
  url: '/signal_comparison/get_signal_mapping'
