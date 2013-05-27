require "language_pack/java"
require "language_pack/database_helpers"
require "fileutils"

# TODO logging
module LanguagePack
	class AntJavaWeb < JavaWeb
		include LanguagePack::PackageFetcher
		include LanguagePack::DatabaseHelpers

		ANT_PACKAGE = "apache-ant-1.9.1-bin.tar.gz".freeze
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
				install_tomcat
				remove_tomcat_files
				copy_webapp_war_to_tomcat
				move_tomcat_to_root
				install_database_drivers
				#install_insight
				copy_resources
				setup_profiled
			end
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
			set_env_override "PATH", "$HOME/#{ant_dir}/bin:$PATH"
		end

		def build_webapp_via_ant
			run_with_err_output("ant all")
			unless File.exists?("build/#{FIXED_WAR_NAME}")
				puts "Unable build webapp via ant"
				exit 1
			end
		end

		def ant_dir
			".ant"
		end

		def download_ant(ant_tarball)
			puts "Downloading Tomcat: #{ANT_PACKAGE}"
			fetch_package ANT_PACKAGE, "http://10.168.3.189/static/#{ANT_PACKAGE}"
			FileUtils.mv ANT_PACKAGE, ant_tarball
		end

		def copy_webapp_war_to_tomcat
			run_with_err_output("mv build/#{FIXED_WAR_NAME} #{tomcat_dir}/webapps/#{FIXED_WAR_NAME}")
			unless File.exists?("#{tomcat_dir}/webapps/#{FIXED_WAR_NAME}")
				puts "Unable copy webapp war to tomcat via ant"
				exit 1
			end
		end

	end
end
