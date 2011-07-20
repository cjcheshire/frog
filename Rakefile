require 'rubygems'
require 'sinatra'
require 'active_record'
require 'uri'

Dir["lib/*.rb"].each { |x| load x }

task :default do
  puts 'rake frog:init           to get started'
  puts 'rake frog:reset          to reload the db schema (loses all data!)'
end

namespace :frog do
  
  task :db_up do
    Schema.up
  end
  
  task :db_down do
    Schema.down
  end
  
  task :init => :db_up do
    if Blog.count == 0
      blog = Blog.create!(:title => 'My Blog')
      blog.entries.create(
        :title => 'Welcome to Frog!',
        :text => '!http://www1.istockphoto.com/file_thumbview_approve/1073907/2/istockphoto_1073907-main-cartoon.jpg!',
        :slug => 'welcome-to-main',
        :is_live => true
      )
      blog.entries.create(
        :title => 'Code Sample',
        :text => "[code]def main\n  puts 'Welcome to Frog'\nend[/code]",
        :slug => 'code-sample'
      )
      blog.entries.create(
        :title => 'moomerman\'s main at master - GitHub',
        :slug => 'test',
        :is_live => true
      )
    end
  end
  
  task :reset => [:db_down, :init]
  
end