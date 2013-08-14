class Searchad.Models.Post extends Backbone.Model
  defaults:
    title: null
    content: null

class Searchad.Collections.PostsCollection extends Backbone.Collection
  model: Searchad.Models.Post
  url: '#/'
