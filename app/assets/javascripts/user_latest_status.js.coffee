###
User Latest Status Manager
@author Linghua Jin
@since Jan, 2014

This is store some user selected data. 
Like currently on certain tabs, for a range of view, what data of dates did the user select, etc. 

In future, this might be associate with local storage depends on when user restart
the app they need them selected or not

###

Searchad.UserLatest =
  # for sub tabs
  sub_tabs:
    # rel-rev-analysis, cvr-dropped-item-comparison, amazon, walmart, stats
    current_tab: 'walmart'
	walmart_items: 
	  start_date: null
	  end_date: null
  