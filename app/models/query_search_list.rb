class QuerySearchList < RedisBase
  Query_Words_List = Redis::SortedSet.new(:query_words_list)
  
  def self.store_query_words(
    user_id, query_word=nil, query_date=nil, weeks_apart=nil)
    user_query_words = get_query_words(user_id)
    if user_query_words.size >= 15
      user_query_words.sort!{|a,b| a[:created_time] <=> b[:created_time] }
      value_id = user_query_words.first[:id]
      Query_Words_List.delete(value_id)
      Query_Words_List.redis.del(QuerySearch.get_key_name(value_id))
    end
    value = QuerySearch.new
    value.set_values(query_word, query_date, weeks_apart)
    Query_Words_List[value.id] = user_id
  end


  def self.get_query_words(user_id)
    Query_Words_List.rangebyscore(user_id, user_id).map do |value_id|
      Hash[Redis::HashKey.new(QuerySearch.get_key_name(value_id)).to_a + 
        [[:id, value_id]]]
    end
  end
end
