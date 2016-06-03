require 'yaml'
require 'open-uri'
require 'nokogiri'
require 'sidekiq'
require 'redis'

class Job
  include Sidekiq::Worker

  attr_accessor :redis
  attr_accessor :config

  def initialize
    @config = YAML::load_file('config.yml')
    @redis = Redis.new 
  end

  def pull_posts_folders_list
    news_sources = []
    last_fetched = @redis.get('last_fetched')

    page = Nokogiri::HTML(open(@config['news_host']).read)
    page.xpath('//table/tr/td/a/@href').drop(1).each { |row| news_sources << row.value }
    
    #cutting the array to start with fresh folders
    if last_fetched
      last_fetched_index = news_sources.index(last_fetched) + 1
      news_sources = news_sources[last_fetched_index..-1]
    end

    news_sources
  end

  def perform(posts_folder_name)
    folder_name = posts_folder_name.partition('.').first #remove .zip

    system("wget #{@config['news_host'] + posts_folder_name} -O #{@config['TMP_DIR'] + posts_folder_name} && unzip #{@config['TMP_DIR'] + posts_folder_name} -d #{@config['DATA_DIR'] + folder_name} && rm #{@config['TMP_DIR'] + posts_folder_name}")
    
    Dir.foreach("#{@config['DATA_DIR'] + folder_name}") do |file|
      next if file == '.' || file == '..'
      @redis.lpush('NEWS_LIST', open(file).read)
    end

    @redis.set('last_fetched', posts_folder_name)
  end
end