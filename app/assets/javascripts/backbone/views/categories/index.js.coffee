Searchad.Views.Categories ||= {}

class Searchad.Views.Categories.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection =
      new Searchad.Collections.Categories()
    @cat_template = JST["backbone/templates/categories"]
    
    @listenTo(@router, 'route', (route, params) =>
      if (@router.cat_path != @cat_path)
        if !@inited
          if !@router.cat_path?
            @cat_path = @router.cat_path
            @collection.fetch(
              reset: true
              data:
                cat_id: 0)
          else
            @cat_path = @router.cat_path
            cat_ids = []
            for cat_id in @cat_path.split('_')
              found = false
              for p_cat_id in @cat_parents
                found = true if p_cat_id.cat_id == parseInt(cat_id)
              cat_ids.push(cat_id) unless found
            @collection.fetch(
              reset: true
              data:
                cat_id: cat_ids)
        else
          @post_render()
    )

    @collection.bind('reset', @render)
    @collection.bind('error', @render)
    @collection.bind('request', @prepare_for_render)
    @cat_parents = []
    @max_drop_down = 2
    @cat_path = 'not_inited'
    @inited = false
    @cat_list_holder = $('<ul class="cat-list">')

  post_render: =>
    @inited = true
    @render_cat_path()
    @render_selected_cat()
 
  render_selected_cat: =>
    selected_cat = @cat_parents[@cat_parents.length - 1]
    @$el.find('span.cat-selected').text(selected_cat.cat_name)

  events: =>
    'click i.cat-link-child': 'get_sub_cats'
    'click i.cat-go-up': 'get_parent_siblings'
    'click a.cat-click': 'set_cat'
    'click a.cat-path': 'set_cat'

  render_cat_path: ()=>
    cat_path = ''
    for cat, i in @cat_parents when i < (@cat_parents.length - 1)
      cat_path += "<a href='#' class='cat-path' " +
        "data-cat_id='#{cat.cat_id}' data-cat_name='#{cat.cat_name}'>" +
        "#{cat.cat_name}</a><span class='divider'>/</span>"
    @$el.find('span.cat-path').html(cat_path)

  set_cat: (e)=>
    cat_id = parseInt($(e.target).data('cat_id'))
    console.log @cat_parents
    cat_path = []
    sIndex = 0
    for cat, i in @cat_parents
      if cat.cat_id == cat_id
        sIndex = i + 1
        break
    console.log 'S index is ', sIndex, @cat_parents
    if sIndex > 0
      @cat_parents = @cat_parents.slice(0, sIndex)
      cat_path.push(cat.cat_id) for cat in @cat_parents
    else
      cat_path.push(cat.cat_id) for cat in @cat_parents
      cat_path.push(cat_id)

    console.log 'Cat parents ar e' , @cat_parents, cat_path

    current_path = window.location.hash.replace('#', '')
    new_path = Utils.UpdateURLParam(
      current_path, 'cat_path', cat_path.join('_'), true)
    @inited = false
    @router.navigate(new_path, trigger: true)
  
  get_parent_siblings: (e) =>
    e.preventDefault()
    e.stopPropagation()
    @$el.find('.carousel').carousel('prev')
    @$el.find('.carousel').carousel('pause')
    cat_id = $(e.target).data('grant_parent_cat_id')
    sIndex = 0
    for cat, i in @cat_parents
      if cat.cat_id == parseInt(cat_id)
        sInex = i
        break
    @cat_parents = @cat_parents.slice(0, sIndex)
    @collection.fetch(
      reset: true
      data:
        cat_id: cat_id)
  
  get_sub_cats: (e) =>
    e.preventDefault()
    e.stopPropagation()
    return if @cat_parents.length > @max_drop_down
    @$el.find('.carousel').carousel('next')
    @$el.find('.carousel').carousel('pause')
    data =
      cat_id: $(e.target).data('cat_id')
      cat_name: $(e.target).data('cat_name')
    @collection.fetch(
      reset: true
      data:
        cat_id: data.cat_id)

  render: =>
    unless @cat_parents.length
      @cat_parents.unshift(
        cat_id: 0
        cat_name: 'All Departments')
    cat_map = @collection.toJSON()[0].cats
    for cat in cat_map
      @cat_parents.push(cat)

    # Stop showing the sub cats if it is 2 levels deep
    if @cat_parents.length > @max_drop_down
      sub_cats = []
    else
      sub_cats = JSON.parse(@collection.at(0).attributes.sub_categories)
    
    if (@cat_parents.length >= 2)
      grant_parent_cat = @cat_parents[@cat_parents.length - 2]
      parent_cat = @cat_parents[@cat_parents.length - 1]
    else
      grant_parent_cat = parent_cat =
        cat_id: 0
        cat_name: 'All Departments'
    
    @cat_list_holder.empty()
    @cat_list_holder.append(
      @cat_template(
        show_nav: (@cat_parents.length < @max_drop_down)
        parent_cat: parent_cat
        grant_parent_cat: grant_parent_cat
        sub_categories: sub_cats)
    )
    @post_render() unless @inited

  prepare_for_render: =>
    @cat_list_holder.detach()
    @cat_list_holder.empty()
    @$el.find('div.carousel-inner .item.active').append(@cat_list_holder)
    @cat_list_holder.append(
      '<li class="cat-link-parent"><span class="outer">' +
      'Getting Sub Categories...</span></li>')
    #@$el.toggleClass('open') if @in_flight

