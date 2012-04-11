require 'faraday'
require 'nokogiri'
require 'net/http'
require 'zip/zip'
module OfxBundler
    class Dsl
        @@latest_version = "007"
        @@configs={
            :osx=>{
                "007"=>
                {
                    "file"=>"http://www.openframeworks.cc/versions/preRelease_v0.07/of_preRelease_v007_osx.zip",
                    "filename"=>'of_preRelease_v007_osx.zip"',
                    "dirname"=>'of_preRelease_v007_osx'

                }
            },
            "linux"=>{
                "007" =>{
                "file"=> "http://www.openframeworks.cc/versions/preRelease_v0.07/of_preRelease_v007_linux.tar.gz",
                "filename"=>"of_preRelease_v007_linux.tar.gz",
                "dirname" => "of_preRelease_v007_linux"
                },
                "007_64" => {
                    "file"=> "http://www.openframeworks.cc/versions/preRelease_v0.07/of_preRelease_v007_linux64.tar.gz",
                    "filename" => "of_preRelease_v007_linux64",
                    "dirname"=> "of_preRelease_v007_linux64"
                }

            }    
        
        }

        def initialize
        end

        def self.evalute(filename)
            begin
            bundler = new
            bundler.eval_ofxfile(filename)
            rescue =>e
               p  "OfxFile error"
               p e.message
            end
        end

        def eval_ofxfile(filename)
            instance_eval(File.read(filename))
        end

        def get_config version
            config=nil
            if RUBY_PLATFORM.downcase.include?("darwin")
                config= @@configs[:osx][version]
            elsif RUBY_PLATFORM.downcase.include?("mswin")
            elsif RUBY_PLATFORM.downcase.include?("linux")
                config= @@configs[:linux][version]
            end
            config
        end

        #install latest version
        def ofx version=@@latest_version
            response = Faraday.get do |req| 
                req.url "http://www.openframeworks.cc/download/"
            end
            doc = Nokogiri::HTML(response.body)
            latest_version = doc.css("#download-latest-header h2")
            puts "Openframeworks current version is "+ latest_version.text+"\n"
            puts "your os is "+RUBY_PLATFORM.downcase
            config = get_config(version)
            href=config["file"]
            
            if href and href!=""
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

                if Dir.exists?(config["dirname"])
                   puts "openframewors dir exists. pass.." 
                else
                    puts "unzip dir.."
                    destination="."
                    Zip::ZipFile.open("ofx.zip") {|file|
                    
                        file.each do |f| 
                            f_path = File.join(destination, f.name)
                            FileUtils.mkdir_p(File.dirname(f_path))
                            file.extract(f,f_path)
                        end
                    } 
                    #cleanup
                    p "cleanup..."
                    `rm -rf __MACOSX`
                    `rm -rf ofx.zip`
                end

            end

        end


        # install or update the addon
        def addon name,version=@@latest_version
            config = get_config(version)
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
