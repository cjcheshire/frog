#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'

Dir["lib/*.rb"].each { |x| load x }

configure do
  set :sessions, true
end

before do
  if request.path_info =~ /admin/ and !logged_in?
    session['forward'] = request.path_info + (request.query_string.blank? ? '' : '?' + request.query_string)
    redirect '/login'
  end
  @blog = Blog.find(:first)
end

helpers do
  include Helpers
end

# Main Blog action
get '/' do
  @entries = @blog.entries
  erb :blog
end

# Permalink Entry action
get '/perm/:id' do
  @entry = @blog.entries.find(params[:id])
  erb :entry
end

# Permalink Slug Entry action
get '/slug/:slug' do
  @entry = @blog.entries.find_by_slug(params[:slug])
  erb :entry
end

get '/login' do
  erb :login
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

get '/admin' do
  @entries = @blog.entries
  erb :admin
end

get '/admin/new' do
  @entry = Entry.new
  erb :new
end

get '/admin/update/:id' do
  @entry = @blog.entries.find(params[:id])
  erb :update
end

post '/admin/update/:id' do
  entry = @blog.entries.find(params[:id])
  slug = params[:slug]
  
  if params[:slug].blank?
    slug = sluggify(params[:title])
  end
  
  # TODO => helper: query for exisiting slug, append url OR add id before slug??
  
  entry.update_attributes(:title => params[:title], :url => params[:url], :slug => slug, :text => params[:text])
  
  redirect "/slug/#{entry.slug}"
end

get '/admin/destroy/:id' do
  @blog.entries.find(params[:id]).destroy
  redirect '/admin'
end

post '/admin/create' do
  
  slug = params[:slug]
  
  if params[:slug].blank?
    slug = sluggify(params[:title])
  end
  
  entry = @blog.entries.create(
    :title => params[:title],
    :url => params[:url],
    :slug => slug,
    :text => params[:text]
  )
  redirect "/slug/#{entry.slug}"
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
