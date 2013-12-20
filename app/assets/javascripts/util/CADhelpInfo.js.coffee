Searchad.helpInfo =
  rank_metric:
    id:"rand_metric"
    name:"Rank Metric"
    description:"Sorted by Larger Query Count,
    Smaller Conversion Rate,
    Lager difference between catalog overlap and result shown in search
    Formula: Sqrt(query_cout)(100-conversion_rate)(cat_overlap - show_rate)
    "
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

  #conversionrate dropped query
  expected_revenue_diff:
    id:"expected_revenue_diff"
    name:"Revenue Difference compare with expected Revenue"
    description:"If the conversion did not change, what is the difference between the roughly expected revenue and actual revenue.  "
    
  site_revenue:
    id: 'site_revenue'
    name: 'Site Revenue'
    description: 'Average daily Site revenue for the item in last 14 days'
    
  revenue:
    id: 'revenue'
    name: 'Revenue'
    description: 'Average daily revenue for the item in last 14 days'
