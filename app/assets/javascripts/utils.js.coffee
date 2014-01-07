# window.Dod ||= {}
# window.Dod.Utils = do ->
  
#   update_URL_param = (location_str, pName, pValue) ->
#     old_url = location_str.split('&')
#     new_url = (name_value_pair for name_value_pair in old_url \
#       when name_value_pair.indexOf(pName + '=') == -1)
#     new_url.push(pName + '=' + pValue)
#     new_url_str = new_url.join('&')
#     if new_url_str.indexOf('?') != 0
#       new_url_str = '?' + new_url_str
#     new_url_str
    
#   set_content = (data, element) ->
#     element.empty()
#     if !data or !$.trim(data)
#       element.html('No data available')
#     else
#       element.html(data)


#   update_URL_param: update_URL_param
#   set_content: set_content
