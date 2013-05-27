module LanguagePack::DatabaseHelpers

  SERVICE_DRIVER_HASH = {
    "*mysql-connector-java-*.jar" =>
        "http://10.168.3.189/static/mysql-connector-java-5.1.12.jar",
    "*postgresql-*.jdbc*.jar" =>
        "http://10.168.3.189/static/mysql-connector-java-5.1.12.jar"
  }.freeze

  def install_database_drivers
    added_jars = []
    Dir.chdir("lib") do
      SERVICE_DRIVER_HASH.each_pair do |search_pattern, url|
         unless !Dir.glob(search_pattern).empty?
           fetch_package(File.basename(url), File.dirname(url))
           added_jars << File.basename(url)
         end
      end
    end
    added_jars
  end
end
