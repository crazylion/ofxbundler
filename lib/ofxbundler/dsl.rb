require 'faraday'
require 'nokogiri'
require 'net/http'
require 'zip/zip'
module OfxBundler
    class Dsl
        attr_accessor :_version
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
            :linux=>{
                "007" =>{
                "file"=> "http://www.openframeworks.cc/versions/preRelease_v0.07/of_preRelease_v007_linux.tar.gz",
                "filename"=>"of_preRelease_v007_linux.tar.gz",
                "dirname" => "of_preRelease_v007_linux"
                },
                "007_64" => {
                    "file"=> "http://www.openframeworks.cc/versions/preRelease_v0.07/of_preRelease_v007_linux64.tar.gz",
                    "filename" => "of_preRelease_v007_linux64.tar.gz",
                    "dirname"=> "of_preRelease_v007_linux64"
                }

            }    
        
        }



        def initialize
            self._version = @@latest_version
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
            self._version=version
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
                        open config["filename"], 'w' do |io|
                            response.read_body do |chunk|
                                io.write chunk
                            end
                        end
                    end
                end

                if File.exists?(config["dirname"])
                   puts "openframewors dir #{config['dirname']} exists. pass.." 
                else

                    if RUBY_PLATFORM.downcase.include?("darwin")
                        puts "unzip dir.."
                        destination="."
                        Zip::ZipFile.open(config["filename"]) {|file|

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
                    elsif RUBY_PLATFORM.downcase.include?("linux")
                        p "tar file... #{config['filename']}"
                        `tar vzxf #{config["filename"]}`
                    end
                end

            end

        end


        # install or update the addon
        def addon name,version=@@latest_version
            config = get_config(self._version)
            addon_author,addon_name = name.split("/")
            if File.exists?("#{config["dirname"]}/addons/#{addon_name}")
                puts "update #{name}"
                `cd #{config["dirname"]}/addons/#{addon_name} && git pull` 
            else
                puts "clone #{name}"
                `cd #{config["dirname"]}/addons && git clone https://github.com/#{name}.git` 
            end
        end
    end
end
