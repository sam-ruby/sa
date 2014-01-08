/*
User Latest Status Manager
@author Linghua Jin
@since Jan, 2014

This is store some user selected data. 
Like currently on certain tabs, for a range of view, what data of dates did the user select, etc. 

In future, this might be associate with local storage depends on when user restart
the app they need them selected or not
*/
Searchad.UserLatest = {}
Searchad.UserLatest.SubTab = {
  current_tab: 'walmart',
  cvr_item_tab_selected: true,
  walmart: {
    start_date: null,
    end_date: null
  },
  update_selected_tab: function(tab_name) {
    if (tab_name === "cvr-dropped-item-comparison") {
      this.cvr_item_tab_selected = true;
    } else {
      this.cvr_item_tab_selected = false;
      this.current_tab = tab_name;
    }
    return true;
  }
}