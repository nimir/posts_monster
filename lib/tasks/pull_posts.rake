require_relative '../utils/job.rb'

desc "pull folders list and if there are new ones pull posts to the redis list"

task :default do
  @job = Job.new
  folders = @job.pull_posts_folders_list
  puts "Found: #{folders.size} folders online - last folder is #{folders.last.to_s}"

  puts ".........................................."
  puts "............ Pulling Posts ..............."
  puts ".........................................."

  folders.each_with_index do |folder, index|
    puts "[#{index+1}] -----stored background job to pull folder: #{folder}"
    Job.perform_async(folder)
  end
end