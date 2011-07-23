#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'active_record'
require 'uri'
require 'haml'
require 'will_paginate'
require 'sinatra/content_for'
require 'sinatra/ratpack'

require 'aws/s3'



Dir["lib/*.rb"].each { |x| load x }

configure do
  set :sessions, true
  set :haml, { :format => :html5 }
end

before do
  if request.path_info =~ /admin/ and !logged_in?
    session['forward'] = request.path_info + (request.query_string.blank? ? '' : '?' + request.query_string)
    redirect '/login'
  end
  @blog = Blog.find(:first)
end

AWS::S3::Base.establish_connection!(
  :access_key_id     => 'AKIAIKUOI7P6PBPKMUYA',
  :secret_access_key => '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'
)

S3_BASE_URL = 'http://s3.amazonaws.com/wfp-portfolio/'


helpers do
  include Helpers
end

# Main Blog action
['/', '/blog/?'].each do | path | 
  get path do 
    @entries = @blog.entries.is_live.paginate :page => params[:page], :per_page => 3  
    if request.xhr?
      haml :blog, :layout => false
    else
      haml :blog
    end  
  end
end

# Permalink Entry action
get '/perm/:id' do
  @entry = @blog.entries.find(params[:id])
  haml :blog_post
end

# Permalink Slug Entry action
get '/blog/:slug' do
  @entry = @blog.entries.find_by_slug(params[:slug])
  @on_slug = true
  if @entry == nil || !@entry.is_live && !logged_in?
    redirect '/'
  else
    haml :blog_post
  end
end

get '/login' do
  haml :login, :layout => :layout_admin
end

post '/login' do
  # TODO: store the hashed password on the blog model
  if params[:username] == 'admin' and params['password'] == 'admin'
    session[:user] = true
    redirect session['forward'] || '/'
  else
    redirect '/login'
  end
end

get '/logout' do
  session[:user] = nil
  redirect '/'
end

# -- Admin actions (require login)

get '/admin/?' do
  @entries = @blog.entries.paginate :page => params[:page], :per_page => 5
  
  if request.xhr?
    haml :_admin_post_row, :layout => false
  else
    haml :admin, :layout => :layout_admin
  end  
  
end

get '/admin/new' do
  @entry = Entry.new
  haml :blog_new_post, :layout => :layout_admin
end

get '/admin/update/:id' do
  @entry = @blog.entries.find(params[:id])
  haml :blog_update_post, :layout => :layout_admin
end

post '/admin/update/:id' do
  entry = @blog.entries.find(params[:id])
  slug = params[:slug]
  
  if slug.blank?
    slug = sluggify(params[:title])
  elsif
    slug = sluggify(slug)
  end
  
  entry.update_attributes(:title => params[:title], :slug => slug, :text => params[:text], :is_live => params[:is_live])
  
  redirect "/blog/#{entry.slug}"
end

get '/admin/destroy/:id' do
  @blog.entries.find(params[:id]).destroy
  redirect '/admin'
end

post '/admin/create' do
  
  slug = params[:slug]
  
  if slug.blank?
    slug = sluggify(params[:title])
  end
  
  entry = @blog.entries.create(
    :title => params[:title],
    :slug => slug,
    :text => params[:text],
    :is_live => params[:is_live]
  )
  redirect "/blog/#{entry.slug}"
end

# For use by the bookmarklet
# http://blog/admin/bookmark?url=http://somewhere.com/
get '/admin/bookmark' do
  url = params[:url]
  title = scrape_page_title(url)
  @blog.entries.create(
    :title => title, 
    :url => url
  )
  redirect url
end
