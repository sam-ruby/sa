Searchad.helpInfo =
  # shared
  rank_metric:
    name:"Rank Metric"
    description:"Sorted by Larger Query Count,
    Smaller Conversion Rate,
    Lager difference between catalog overlap and result shown in search
    Formula: Sqrt(query_cout)(100-conversion_rate)(cat_overlap - show_rate)
    "

  query_score:
    name: "Query Score"
    description:"Square root of Query Count * (1 - Query Conv) * (diff between Query count and Alarm Threshold)"

  query_count:
    name: "Number of Queries"
    description: "number of times that customers search for this term at Walmart.com"

  query_con:
    name: "Conversion Rate"
    description: "percentage of queries that are converted"

  query_atc:
    name: "Add to Cart Rate"
    description: "percentage of queries that customers add items to cart"

  query_pvr:
    name: "Product View Rate"
    description: "percentage of queries that customers clicked items recalled for a query"

 # non-shared
  conversion_rate_dropped_query:
    query_score: "Ranked by most current traffic and most significant conversion drop. 
      Formula: sqrt(count_after)* con_diff"

    expected_revenue_diff: "If the conversion did not change, by using current traffic, what is the difference between the expected revenue and actual revenue roughly.
       Formula: converion_difference/converion_after * revenue_after"




