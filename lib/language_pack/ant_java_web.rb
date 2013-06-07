require "language_pack/java"
require "language_pack/database_helpers"
require "fileutils"

# TODO logging
module LanguagePack
	class AntJavaWeb < JavaWeb
		include LanguagePack::PackageFetcher
		include LanguagePack::DatabaseHelpers

		ANT_PACKAGE = "apache-ant-1.8.2-ivy-2.2.0-outfox.tar.gz".freeze
		RESIN_PACKAGE = "resin-3.0.21.tar.gz".freeze
		FIXED_WAR_NAME = "ROOT.war".freeze

		def self.use?
			File.exists?("build.xml")
		end

		def name
			"Ant Java Web"
		end

		def compile
			Dir.chdir(build_path) do
				install_java
				install_ant
				build_webapp_via_ant
				install_resin
				remove_resin_files
				copy_webapp_war_to_resin
				generate_resin_conf
			#	move_tomcat_to_root
			#	install_database_drivers
				#install_insight
				setup_profiled
				copy_resources
			end
		end

def generate_resin_conf
	fetch_package "generate_server_xml", "http://10.168.3.189/static"
run_with_err_output("chmod a+x generate_server_xml")
end

def remove_resin_files 
	FileUtils.rm_rf("#{RESIN_PACKAGE}")
end
		def install_resin
		        puts "Downloading resin"
                        fetch_package RESIN_PACKAGE, "http://10.168.3.189/static"
			run_with_err_output("tar xzf #{RESIN_PACKAGE}")

		end
		def install_ant
			FileUtils.mkdir_p ant_dir
			ant_tarball="#{ant_dir}/ant.tar.gz"

			download_ant ant_tarball

			puts "Unpacking Ant to #{ant_dir}"
			run_with_err_output("tar xzf #{ant_tarball} -C #{ant_dir} && mv #{ant_dir}/apache-ant*/* #{ant_dir} && " +
															"rm -rf #{ant_dir}/apache-ant*")
			FileUtils.rm_rf ant_tarball
			unless File.exists?("#{ant_dir}/bin/ant")
				puts "Unable to retrieve Ant"
				exit 1
			end
		end

		def build_webapp_via_ant
			run_with_err_output("JAVA_HOME=#{build_path}/#{jdk_dir} #{ant_dir}/bin/ant all")
			unless File.exists?("build/#{FIXED_WAR_NAME}")
				puts "Unable to build webapp via ant"
				exit 1
			end
		end

    def default_process_types
      {
        "web" => "/home/vcap/.rvm/rubies/ruby-1.9.3-p392/bin/ruby generate_server_xml  &&./resin-3.0.21/bin/httpd.sh -conf resin.conf"
      }
    end

def resin_dir
	"./resin-3.0.21"
end
		def ant_dir
			".ant"
		end

		def download_ant(ant_tarball)
			puts "Downloading Ant: #{ANT_PACKAGE}"
			fetch_package ANT_PACKAGE, "http://10.168.3.189/static"
			FileUtils.mv ANT_PACKAGE, ant_tarball
		end

		def copy_webapp_war_to_resin
			run_with_err_output("mv build/#{FIXED_WAR_NAME} #{resin_dir}/webapps/#{FIXED_WAR_NAME}")
			unless File.exists?("#{resin_dir}/webapps/#{FIXED_WAR_NAME}")
				puts "Unable copy webapp war to tomcat via ant"
				exit 1
			end
		end

	end
end
