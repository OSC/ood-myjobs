require "yaml"
require "erb"
require "active_support/core_ext/hash/compact"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/object/try"

# job composer app specific configuration
class Configuration
  class << self
    # The app's configuration root directory
    # @return [Pathname] path to configuration root
    def config_root
      Pathname.new(ENV["OOD_CONFIG"] || "/etc/ood/config/apps/myjobs")
    end

    # A hash describing the configuration read in from the app's configuration
    # file
    # @return [Hash{Symbol=>Object}] configuration hash
    def config
      return @config if @config

      yaml = config_root.join("config.yml")
      conf = YAML.load(ERB.new(yaml.read, nil, "-").result) if yaml.exist?
      if conf.is_a?(Hash)
        @config = conf.compact.deep_symbolize_keys
      else
        puts "ERROR: Configuration file '#{yaml}' needs to define a Hash" if conf
        @config = {}
      end
    rescue Psych::SyntaxError => e
      puts "ERROR: YAML syntax error occurred while parsing #{yaml} - #{e.message}"
      @config = {}
    end

    # Version of app
    # @return [String] app version
    def version
      version = `git describe --always --tags 2> /dev/null`.strip
      version.empty? ? "Unknown Version" : version
    end

    # Id describing the OnDemand portal
    # @return [String, nil] portal id
    def portal
      config[:portal].try(:to_s) || ENV["OOD_PORTAL"]
    end

    # Path to the data root for this app
    # @return [String] data root
    def dataroot
      config[:dataroot].try(:to_s) || ENV["OOD_DATAROOT"] ||
        ( ENV["RAILS_ENV"] == "production" ? "#{ENV["HOME"]}/#{portal}/data/sys/myjobs" : "./data" )
    end

    # Path to the production database file for this app
    # @return [String] database path
    def prod_database
      config[:database].try(:to_s) || ENV["DATABASE_PATH"] || "#{dataroot}/production.sqlite3"
    end

    # Title of Dashboard app
    # @return [String, nil] title of dashboard
    def dashboard_title
      config[:dashboard_title].try(:to_s) || ENV["OOD_DASHBOARD_TITLE"]
    end
  end
end

# Set some environment variables to maintain backwards compatibility with
# ood_appkit
ENV["OOD_PORTAL"]          = Configuration.portal
ENV["OOD_DATAROOT"]        = Configuration.dataroot
ENV["DATABASE_PATH"]       = Configuration.prod_database
ENV["OOD_DASHBOARD_TITLE"] = Configuration.dashboard_title
