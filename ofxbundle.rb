require 'optparse'
require 'faraday'
require 'nokogiri'
require './dsl.rb'
options={}

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end
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
    opts.on("-s w","--search w","search the addons") do  |w|
        response = Faraday.get do |req| 
            req.url "http://ofxaddons.com/"
        end
        doc = Nokogiri::HTML(response.body)
        doc.css("div.repo").each do |repo|
            is_found=false;
            repo_name=''
            repo.css("p.name a").each do |item|
                text = item.text()
                if text.downcase.include?(w.downcase)
                    is_found=true
                    repo_name=text
                end
            end
            if is_found
                repo_author = repo.css("p.author").first.text()
                puts " "+colorize(repo_name,31)+" - #{repo_author}"
                repo_desc = repo.css("p.description em").first.text()
                github_link = (repo.css("p.description em a.github_link").first)["href"]
                puts "  "+colorize(repo_desc,32)
                puts "  github:"+github_link
            end
        end
    end
end.parse!
