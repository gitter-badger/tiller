require 'yaml'
# File datasource for Tiller. This works the same way as the default behaviour
# in Runner.rb - it loads your <environment>.yaml file and pulls data from it.
# See examples/etc/tiller/environments/production.yaml to see what this file
# looks like.
#
# We also don't provide any global values, just ones specific to a template.
class FileDataSource < Tiller::DataSource
  # Open and parse the environment file. Tries from v2 format common.yaml first, if that
  # failes, then it looks for separate environment files.
  def setup
    if @config.has_key?('environments')
      # Try and load from v2 format common.yaml
      if @config['environments'].has_key?(@config[:environment])
        @log.debug("#{self} : Using values from v2 format common.yaml")
        @config_hash = @config['environments'][@config[:environment]]
      else
        abort("Error : Could not load environment #{@config[:environment]} from common.yaml")
      end
    else
      # Try and load from v1 format files
      begin
        env_file = File.join(@config[:tiller_base], 'environments',
                             "#{@config[:environment]}.yaml")
        @config_hash = YAML.load(open(env_file))
      rescue
        abort("Error : Could not load environment file #{env_file}")
      end
    end
  end

  def common
    @config_hash.key?('common') ? @config_hash['common'] : {}
  end

  def values(template_name)
    @config_hash.key?(template_name) ? @config_hash[template_name]['config'] : {}
  end

  def target_values(template_name)
    # The config element is redundant (not a target value)
    @config_hash.key?(template_name) ? @config_hash[template_name] : {}
  end
end
