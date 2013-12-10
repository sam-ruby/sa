Searchad.Views.WeekPicker ||= {}

class Searchad.Views.WeekPicker.IndexView extends Backbone.View
  events:
    "click": "datePickerOpened"
 
  initialize: (options) =>
    @weekly = false
    @controller = SearchQualityApp.Controller
    
    @initCalendar()

    @listenTo(@controller, "set_latest_week_day", @setLatestWeekDay)
    @listenTo(@controller, "update_date", (date) =>
      @setDate(date)
      @showDateInfo())
    @listenTo(@controller, 'view-change', @setView)
    @available_weeks = new Searchad.Collections.WeeksCollection(Available_weeks)
    
    @end_date = Date.parse(@available_weeks.at(0).get('end_date'))
    @start_date = Date.parse(
      @available_weeks.at(@available_weeks.length - 1).get('start_date'))
   
    filter_params = @controller.get_filter_params()
    week = @available_weeks.where(week: parseInt(filter_params.week))
    if week.length > 0
      @week_date = Date.parse(week[0].get('end_date'))
    
    if @weekly
      @$el.datepicker('setStartDate', @start_date)
      @$el.datepicker('setEndDate', @end_date)
      @setDate(@week_date)
      @showWeekInfo()
    else
      @daily_date = Date.parse(filter_params.date)
      @$el.datepicker('setStartDate', Min_date)
      @$el.datepicker('setEndDate', Max_date)
      @setDate(@daily_date)
  
    @week = filter_params.week if filter_params.week
    @year = filter_params.year if filter_params.year

  setView: (data) ->
    f_params = @controller.get_filter_params()
    if data.view == 'weekly'
      @weekly = true
      @$el.datepicker('setStartDate', @start_date) if @start_date
      @$el.datepicker('setEndDate', @end_date) if @end_date
      week = @available_weeks.where(week: parseInt(f_params.week))
      if week.length > 0
        @week_date = Date.parse(week[0].get('end_date'))
        @setDate(@week_date)
      @showWeekInfo()
    else
      @weekly = false
      @$el.datepicker('setStartDate', Min_date)
      @$el.datepicker('setEndDate', Max_date)
      @daily_date = Date.parse(f_params.date)
      @setDate(@daily_date)
      @showDateInfo()

  setDate: (date) ->
    @$el.datepicker('update', date)

  datePickerOpened: ->
    if @weekly
      $(".datepicker .active").first().parent().children().addClass("active")

  showWeekInfo: () =>
    f_params = @controller.get_filter_params()
    week = parseInt(f_params.week)
    year = parseInt(f_params.year)
    @available_weeks.each( (w) ->
      curr_start_date = Date.parse(w.get("start_date"))
      curr_end_date = Date.parse(w.get("end_date"))
      curr_fiscal_week = w.get("fiscal_week")
      curr_dod_week = w.get("week")
      curr_dod_year = w.get("year")
      if week == curr_dod_week and year == curr_dod_year
        @$el.parents('ul').find('.date-week-holder').text(
          'Week of ' + curr_start_date.toString('MMM d, yyyy') + " to " +
          curr_end_date.toString('MMM d, yyyy'))
    , this)

  showDateInfo:  =>
    my_date = @$el.datepicker('getDate')
    @$el.parents('ul').find('.date-week-holder').text(
      my_date.toString('MMM d, yyyy'))
  
  setWeekNumberFromDate: (pick_date) =>
    @available_weeks.each( (week) ->
      curr_start_date = Date.parse(week.get("start_date"))
      curr_end_date = Date.parse(week.get("end_date"))
      curr_fiscal_week = week.get("fiscal_week")
      curr_dod_week = week.get("week")
      curr_dod_year = week.get("year")
      curr_picked_date = pick_date
      if curr_picked_date.between(curr_start_date, curr_end_date)
        @week = curr_dod_week
        @year = curr_dod_year
        currentPath = window.location.hash.replace('#', '')
        newPath = Utils.UpdateURLParam(currentPath, 'year', @year, true)
        newPath = Utils.UpdateURLParam(newPath, 'week', @week, true)
        SearchQualityApp.Router.navigate(newPath)
        SearchQualityApp.Controller.set_year(@year)
        SearchQualityApp.Controller.set_week(@week)
        SearchQualityApp.Controller.trigger('year-week-changed')
    , this)

  initCalendar: =>
    @$el.datepicker(
      autoclose: false
      weekStart: 6
      date: date).on(
        'changeDate', (e) =>
          if @weekly
            @datePickerOpened()
            @week_date = e.date
            @setWeekNumberFromDate(e.date)
            @showWeekInfo()
          else
            @daily_date = e.date
            @showDateInfo()
            dateStr = e.date.getMonth() + 1 + '-' + e.date.getDate() +
              '-' + e.date.getFullYear()
            currentPath = window.location.hash.replace('#', '')
            newPath = Utils.UpdateURLParam(currentPath, 'date', dateStr, true)
            SearchQualityApp.Router.navigate(newPath)
            SearchQualityApp.Controller.set_date(dateStr)
            SearchQualityApp.Controller.trigger('date-changed')
      )
