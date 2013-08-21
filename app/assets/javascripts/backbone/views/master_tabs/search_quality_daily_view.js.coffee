Searchad.Views.SearchQualityDailies ||= {}

class Searchad.Views.SearchQualityDailies.SearchQualityDailyView extends Backbone.View
  template: JST["backbone/templates/search_quality_dailies/search_quality_daily"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
