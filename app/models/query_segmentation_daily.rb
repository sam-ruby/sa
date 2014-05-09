class QuerySegmentationDaily < BaseModel
  self.table_name = 'query_segmentation_daily'

  def self.get_segment_metadata(cat_id, date)
    cols = %q{a.segmentation, count(distinct a.query) seg_query_count, 
      sum(b.uniq_count) uniq_count, 
      sum(b.uniq_pvr)/sum(b.uniq_count) p_v_r, 
      sum(b.uniq_atc)/sum(b.uniq_count) a_t_c, 
      sum(b.uniq_con)/sum(b.uniq_count) c_o_n, 
      sum(b.revenue) seg_revenue}
    join_str = %q{as a, query_cat_metrics_daily b}
    where_str = %q{a.data_date = b.data_date and 
      a.query = b.query and 
      b.cat_id = 0 and 
      b.page_type = 'SEARCH' and
      b.channel in ('ORGANIC_USER', 'ORANIC_AUTO_COMPLETE') and 
      a.cat_id = ? and a.data_date = ?}
    select(cols).joins(join_str).where(
      [where_str, cat_id, date]).group(
        'a.data_date, a.segmentation')
  end

end
