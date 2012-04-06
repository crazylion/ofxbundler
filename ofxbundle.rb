require 'optparse'
require 'faraday'
require 'nokogiri'
options={}
OptionParser.new do |opts|
    opts.banner = "Usage: example.rb [options]"
    opts.on("-l","list current openframeworks version") do |v| 
       response = Faraday.get do |req| 
           req.url "http://www.openframeworks.cc/download/"
       end
       doc = Nokogiri::HTML(response.body)
       version = doc.css("#download-latest-header h2")
       puts "Openframeworks current version is "+ version.text
    end 
end.parse!
