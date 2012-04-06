require 'faraday'
require 'nokogiri'
require 'net/http'
require 'zip/zip'
module OfxBundler
    class Dsl
        @@download_href={
            :osx=>{
            "007"=>"http://www.openframeworks.cc/versions/preRelease_v0.07/of_preRelease_v007_osx.zip",
            "filename"=>'of_preRelease_v007_osx.zip"',
            "dirname"=>'of_preRelease_v007_osx'
            }
        
        }
        def initialize
        end

        def self.evalute(filename)
            begin
            bundler = new
            bundler.eval_ofxfile(filename)
            rescue
                "OfxFile error"
            end
        end

        def eval_ofxfile(filename)
            instance_eval(File.read(filename))
        end

        def get_config
            config=nil
            if RUBY_PLATFORM.downcase.include?("darwin")
                config= @@download_href[:osx]
            elsif RUBY_PLATFORM.downcase.include?("mswin")
            elsif RUBY_PLATFORM.downcase.include?("linux")
            end
            config
        end

        #install latest version
        def ofx(version="latest")
            response = Faraday.get do |req| 
                req.url "http://www.openframeworks.cc/download/"
            end
            doc = Nokogiri::HTML(response.body)
            version = doc.css("#download-latest-header h2")
            puts "Openframeworks current version is "+ version.text+"\n"
            puts "your os is "+RUBY_PLATFORM.downcase
            href=""
            if RUBY_PLATFORM.downcase.include?("darwin")
                href = @@download_href[:osx]["007"]
            elsif RUBY_PLATFORM.downcase.include?("mswin")
            elsif RUBY_PLATFORM.downcase.include?("linux")
            end

            if href!=""
                p "downing "+href
                uri = URI(href)
                Net::HTTP.start(uri.host,uri.port) do |http|
                    request = Net::HTTP::Get.new uri.request_uri

                    http.request request do |response|
                        open 'ofx.zip', 'w' do |io|
                            response.read_body do |chunk|
                                io.write chunk
                            end
                        end
                    end
                end

                destination="."
                Zip::ZipFile.open("ofx.zip") {|file|
                
                    file.each do |f| 
                        f_path = File.join(destination, f.name)
                        FileUtils.mkdir_p(File.dirname(f_path))
                        file.extract(f,f_path)
                    end
                } 

            end

        end


        def addon name
            config = get_config
            addon_author,addon_name = name.split("/")
            if Dir.exists?("#{config["dirname"]}/addons/#{addon_name}")
                puts "update #{name}"
                `cd #{config["dirname"]}/addons/#{addon_name} && git pull` 
            else
                puts "clone #{name}"
               `cd #{config["dirname"]}/addons && git clone https://github.com/#{name}.git` 
            end
        end
    end
end