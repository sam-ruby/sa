Searchad.Views.Posts ||= {}

class Searchad.Views.Posts.IndexView extends Backbone.View
  template: JST["backbone/templates/posts/index"]

  initialize: () ->
    @options.posts.bind('reset', @addAll)

  addAll: () =>
    @options.posts.each(@addOne)

  addOne: (post) =>
    view = new Searchad.Views.Posts.PostView(
      model : post
    )
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template())
    @addAll()

    return this
