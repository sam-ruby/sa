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
        @inited_from_router = true
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
            cat_ids.push(cat_id)
          @collection.fetch(
            reset: true
            data:
              cat_id: cat_ids)
    )

    @collection.bind('reset', @render)
    @collection.bind('error', @render)
    @collection.bind('request', @prepare_for_render)
    @cat_parents = []
    @max_drop_down = 2
    @cat_path = 'not_inited'
    @inited_from_click = false
    @cat_list_holder = $('<ul class="cat-list">')

  events: =>
    'click i.cat-link-child': 'get_sub_cats'
    'click a.cat-click-go-up': 'get_parent_siblings'
    'click a.cat-click': 'set_sub_cat'

  render_cat_path: (cat_map)=>
    return unless cat_map.length
    cat_map.unshift(
      cat_id: 0
      cat_name: 'All Departments')
    cat_paths = []
    for cat in cat_map
      cat_paths.push(
        "<a href='#' class='cat-path' " +
        "data-cat_id='#{cat.cat_id}' data-cat_name='#{cat.cat_name}'>" +
        "#{cat.cat_name} &nbsp;/&nbsp;</a>")

    @$el.find('span.cat-path').html(cat_paths.join(''))

  set_sub_cat: (e)=>
    @$el.find('span.cat-selected').text(
      $(e.target).text())
    cat_id = $(e.target).data('cat_id')
    cat_path = []

    for path in @cat_parents
      cat_path.push path.cat_id
    cat_path.push cat_id
    
    current_path = window.location.hash.replace('#', '')
    new_path = Utils.UpdateURLParam(
      current_path, 'cat_path', cat_path.join('_'), true)
    @router.navigate(new_path)
  
  get_parent_siblings: (e) =>
    e.preventDefault()
    e.stopPropagation()
    @inited_from_click = false
    @$el.find('.carousel').carousel('prev')
    @$el.find('.carousel').carousel('pause')
    data =
      cat_id: $(e.target).data('cat_id')
      cat_name: $(e.target).data('cat_name')
    @cat_parents.pop()
    @collection.fetch(
      reset: true
      data:
        cat_id: data.cat_id)
    @render_cat_path()
  
  get_sub_cats: (e) =>
    e.preventDefault()
    e.stopPropagation()
    @inited_from_router = false
    return if @cat_parents.length > @max_drop_down
    @$el.find('.carousel').carousel('next')
    @$el.find('.carousel').carousel('pause')
    data =
      cat_id: $(e.target).data('cat_id')
      cat_name: $(e.target).data('cat_name')
    @cat_parents.push(data)
    @collection.fetch(
      reset: true
      data:
        cat_id: data.cat_id)

  post_render: =>

  render: =>
    cat_map = @collection.toJSON()[0].cats

    # Stop showing the sub cats if it is 2 levels deep
    if cat_map.length >= @max_drop_down
      sub_cats = []
    else
      sub_cats = JSON.parse(@collection.at(0).attributes.sub_categories)
    
    for cat in cat_map
      @cat_parents.push(cat)

    if @inited_from_router
      selected_cat = cat_map.pop()
      selected_cat = {cat_id: 0, cat_name: 'All Departments'} unless selected_cat
      @$el.find('span.cat-selected').text(selected_cat.cat_name)
    
    if (cat_map.length)
      @render_cat_path(cat_map)
      parent_cat = cat_map[cat_map.length -1]
      top_cat_id = parent_cat.cat_id
      top_cat_name = parent_cat.cat_name
    else
      top_cat_id = 0
      top_cat_name = 'All Departments'
    
    @cat_list_holder.empty()
    @cat_list_holder.append(
      @cat_template(
        show_nav: (cat_map.length < @max_drop_down - 1)
        top_cat_id: selected_cat.cat_id
        top_cat_name: selected_cat.cat_name
        sub_categories: sub_cats)
    )

  prepare_for_render: =>
    @cat_list_holder.detach()
    @cat_list_holder.empty()
    @$el.find('div.carousel-inner .item.active').append(@cat_list_holder)
    @cat_list_holder.append(
      '<li class="cat-link-parent"><span class="outer">' +
      'Getting Sub Categories...</span></li>')
    #@$el.toggleClass('open') if @in_flight

