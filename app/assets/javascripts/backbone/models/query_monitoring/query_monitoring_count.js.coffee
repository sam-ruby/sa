class Searchad.Models.QueryMonitoringCount extends Backbone.Model
  paramRoot: 'query'

  defaults:
    query_str: null
    query_score: null
    query_count: null
    query_con: null
    days_alarmed: null
    days_abovemean: null
    z_score: null

class Searchad.Collections.QueryMonitoringCountCollection extends Backbone.PageableCollection
  initialize: (options) ->
    @data = {
      query:null
      date:null
    }
    super(options)

  model: Searchad.Models.QueryMonitoringCount
  url: '/monitoring/count/get_words.json'
  state:
    pageSize: 10
  mode: 'server'
  queryParams:
    currentPage: 'page'
    pageSize: 'per_page'
    date: ->
      @data.date
    query: ->
      @data.query

  get_items: (data) =>
    @state.currentPage = 1
    @fetch(
      reset: true
      data: @data)

