require 'optparse'
require 'faraday'
require 'nokogiri'
require './dsl.rb'
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

    opts.on("install","install by bundler file") do |v|
         #find bundler.file
         OfxBundler::Dsl.evalute("OfxFile")
    end
end.parse!
