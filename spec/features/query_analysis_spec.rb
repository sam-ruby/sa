require 'spec_helper'

describe "The signin process", :js => true, :driver => :webkit  do
  it "Login and verify Overview tab" do
    visit '/'
    current_path.should match(/users\/login/)
    within('div.panel-body form') do
      # Change this to a test user ID and Password
      fill_in 'Wire ID', :with => 'svargh1'
      fill_in 'Password', :with => 'xxxx'
      click_button 'Sign in'
    end
    visit '/'
    current_path.should match('/')
    page.should have_link('Overview')
    click_link('Overview')

    # Check for the main 3 sub tabs here
    page.should have_selector('.master-tab')
    within('.master-tab') do
      page.should have_link('KPI')
      page.should have_link('Query Analysis')
      page.should have_link('Poor Performing Intents')
    end

    # Verify KPI
    click_link('KPI')
    page.should have_selector('div#search-kpi')
    within('div#search-kpi') do
      page.should have_content('Paid Traffic')
      page.should have_content('Unpaid Traffic')
    end
    
    # Verify Query Analysis
    click_link('Query Analysis')
    page.should have_selector('div#search-quality')
    within('div#search-quality') do
      page.should have_xpath(
        './/a', :text => 'Query String', :visible => true)
      page.should have_xpath(
        './/a', :text => 'Count', :visible => true)
      page.should have_xpath(
        './/a', :text => 'Rank Metric', :visible => true)
      page.should have_xpath(
        './/a', :text => 'Catalog Overlap', :visible => true)
    end
  
    # Verify Search Sub tabs
    page.should have_selector('div#search-sub-tabs')
    within('div#search-sub-tabs') do
      page.should have_xpath(
        './/a', :text => 'Overview', :visible => true)
      page.should have_xpath(
        './/a', :text => 'Comptetive Analysis', :visible => true)
      page.should have_xpath(
        './/a', :text => 'Relevance Best Seller Analysis', :visible => true)
      page.should have_xpath(
        './/a', :text => 'Walmart Results Analysis', :visible => true)
    end
  end
end
