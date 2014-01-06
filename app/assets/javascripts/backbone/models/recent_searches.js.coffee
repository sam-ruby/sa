# deprecated
class Searchad.Models.RecentSearch extends Backbone.Model
  
  defaults:
    query: null
    query_date: null
    weeks_apart: null

class Searchad.Collections.RecentSearchesCollection extends Backbone.PageableCollection
  initialize: ->
    @controller = SearchQualityApp.Controller
  
  model: Searchad.Models.RecentSearch
  url: '/search/get_recent_searches.json'
  mode: 'client'
  state:
    pageSize: 5
