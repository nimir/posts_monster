require 'open-uri'
require 'nokogiri'

include Sidekiq::Worker

desc "Task description"
task :default do

  page = Nokogiri::HTML(open('http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/').read)
  links = page.xpath('//table/tr/td/a/@href').collect(&:value).drop(1)


end