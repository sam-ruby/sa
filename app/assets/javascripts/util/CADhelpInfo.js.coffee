Searchad.helpInfo =
  rank_metric:
    id:"rand_metric"
    name:"Rank Metric"
    description:"Sqrt(query_cout)(1-conversion_rate)(cat_overlap - show_rate)"
  # query_revenue:
  #   id: "query_revenue"
  #   name: "Query Revenue"
  #   description: "weekly revenue from organic query"
  query_score:
    id: "query_score"
    name: "Query Score"
    description:"Square root of Query Count * (1 - Query Conv) * (diff between Query count and Alarm Threshold)"

  query_count:
    id: "query_count"
    name: "Number of Queries"
    description: "number of times that customers search for this term at Walmart.com"

  query_con:
    id: "query_con"
    name: "Conversion Rate"
    description: "percentage of queries that are converted"

  query_atc:
    id: "query_atc"
    name: "Add to Cart Rate"
    description: "percentage of queries that customers add items to cart"

  query_pvr:
    id: "query_pvr"
    name: "Product View Rate"
    description: "percentage of queries that customers clicked items recalled for a query"
