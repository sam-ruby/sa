class Searchad.Models.Week extends Backbone.Model

class Searchad.Collections.WeeksCollection extends Backbone.PageableCollection
  model: Searchad.Models.Week
  url: '/search_rel/available_weeks.json'
