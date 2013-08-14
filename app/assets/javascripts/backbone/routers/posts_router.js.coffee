class Searchad.Routers.PostsRouter extends Backbone.Router
  initialize: (options) ->
    @posts = new Searchad.Collections.PostsCollection()
    @posts.reset options.posts

  routes:
    "new"      : "newPost"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newPost: ->
    @view = new Searchad.Views.Posts.NewView(collection: @posts)
    $("#posts").html(@view.render().el)

  index: ->
    console.log('this wud be awesome')
    @view = new Searchad.Views.Posts.IndexView(posts: @posts)
    $("#example-app").html(@view.render().el)

  show: (id) ->
    console.log('here is the show')
    post = @posts.get(id)

    @view = new Searchad.Views.Posts.ShowView(model: post)
    $("#example-app").html(@view.render().el)

  edit: (id) ->
    post = @posts.get(id)

    @view = new Searchad.Views.Posts.EditView(model: post)
    $("#example-app").html(@view.render().el)
