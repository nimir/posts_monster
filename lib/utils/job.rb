require 'yaml'
require 'sidekiq'
require 'redis'

CONFIG = YAML::load_file('config.yml').simbolize_keys!

class Job
  include Sidekiq::Worker

  @redis = Redis.new

  def pull_posts(source)
    system("wget  -O #{TMP_DIR}/#{source}.zip && unzip #{TMP_DIR}/#{source}.zip -d #{DATA_DIR}/#{source} && rm #{TMP_DIR}/#{source}.zip")
    
    Dir.foreach("#{DATA_DIR}/#{source}") do |file|
      next if file == '.' || file == '..'
      @redis.lpush CONFIG[:redis][:list_name], open(file).read
    end
  end
end