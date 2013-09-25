class QuerySearch < RedisBase
  hash_key :query_values

  def initialize
    super()
    query_values[:created_at] = Time.now.to_i
  end

  def set_values(query_word, query_date, weeks_apart)
    query_values[:query] = query_word
    query_values[:query_date] = query_date
    query_values[:weeks_apart] = weeks_apart
  end

  def self.get_key_name(id)
    'query_search:' + id.to_s + ':' + 'query_values'
  end
end
