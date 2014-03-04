require 'spec_helper'

describe SearchRelController do
  context "Verify the view and template for #index" do
    it 'responds with 200 status code' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'Renders the cad layout file' do
      get :index
      response.should render_template(:layout => :cad)
      response.should render_template(:index)
    end
  end

  describe "validate controller methods" do
    let(:default_params) { 
      {:format => :json, :date => '1-27-2014',
       :per_page => 10, :page => 1} }
    
    it "Test get search words for a query " do
      get :get_search_words, {:query => 'printers'}.merge(default_params)

      response.status.should == 200
      result = JSON.parse(response.body)
      result.size.should == 2
      result[1].first.keys.should include(
        'cat_rate', 'query_atc', 'query_con', 'query_count', 
        'query_pvr', 'query_revenue', 'query_str', 'rank_metric', 
        'rel_score', 'search_rev_rank_correlation', 'show_rate')

      record = result.last.first
      record['cat_rate'].should == 62.5
      record['query_atc'].round(2).should == 4.64
      record['query_con'].round(2).should == 1.79
      record['query_count'].should == 1789
      record['query_pvr'].round(2).should == 42.43
      record['query_revenue'].round(2).should == 2841.89
      record['query_str'].should == 'printers'
      record['rank_metric'].round(2).should == 2206.81
      record['rel_score'].round(2).should == 0.11
      record['search_rev_rank_correlation'].round(2).should == 0.30
      record['show_rate'].round(2).should == 9.38
    end
    
    it "Test get search words " do
      get :get_search_words, default_params
      
      response.status.should == 200
      result = JSON.parse(response.body)
      result.size.should == 2
      result.last.size.should == 10
      result.last.first.keys.should include(
        'cat_rate', 'query_atc', 'query_con', 'query_count', 
        'query_pvr', 'query_revenue', 'query_str', 'rank_metric', 
        'rel_score', 'search_rev_rank_correlation', 'show_rate')
    end
  end
end
