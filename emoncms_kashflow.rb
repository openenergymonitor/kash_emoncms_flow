#!/usr/bin/ruby
require 'kashflow'
require "http"
require 'date'

# Pull profit and loss data from KashFlow accounting and post to http://emoncms.org for better graphing :-)
# Part of the OpenEnergyMonitor.org project
# GNU GPL

# Ruby Setup

# sudo apt-get install ruby
# sudo apt-get install ruby-dev
# sudo gem install kashflow         # https://github.com/pogodan/kashflow
# sudo gem install activesupport
# sudo gem install http             # https://github.com/httprb/http


p 'Starting Kash_Emoncms_Flow: ' + Time.now.to_s

k = Kashflow.client('kashflow_user', 'kashflow_API_password')

# Emoncms server e.g 'localhost/emoncms' or 'emoncms.org'
emoncms_host = 'emoncms.org'
emoncms_api  = 'xxxxxxxxxxxxxxxxxxxxxxxxxx'
emoncms_feed_id = '1'

# Set start date, by defaut script will pull monthly P&L values each month untill current date
start_date = 'YYYY-MM-DD'

# Kashflow API retun array of openStruct
monthly = k.get_monthly_profit_and_loss(:start_date=> start_date, :end_date=>Date.today.to_s)

# Alt API, get daily figures 
#daily= k.get_profit_and_loss(:start_date=> '2016-01-01', :end_date=>'2016-01-02')

# Loor for each element in the array (one per month)
monthly.each do |x|
    
    # Create unix timestamp using time period end (last day of the month)
    p x.period_end.to_s(:long)
    timestamp =  x.period_end.to_i
    
    # Debug Output 
    p 'Timestamp: ' + timestamp.to_s
    p 'Turnover: ' + x.turnover
    p 'Gross profit: ' + x.gross_profit
    p 'Net_profit: ' + x.net_profit
    
    # Create CSV ready to send to Emoncms 
    data_csv = x.turnover + ',' + x.gross_profit + ',' + x.net_profit
    
    # Post to Emoncms and display responce
    puts 'Emoncms responce: ' + HTTP.get('http://' + emoncms_host + '/input/post.json', :params => {:time => timestamp.to_s, :csv => data_csv, :node => emoncms_host, :apikey => emoncms_api}).to_s
    
    p '--------------------------'
end

puts 'Done ' + Date.today.to_s + ' ' + Time.now.to_s