require 'sinatra'
require 'json'
require "net/http"
require "uri"

KEYMASTER_URI = 'http://localhost:9081/api/auth/service/v1/account_master_token.json'

post '/' do
  $stderr.write "accountservice #{request.url}\n"
  service = request['service']
  username = request['username']
  password = request['password']

  uri = URI.parse(KEYMASTER_URI)
  params = {'s'=> service, 'e' => username, 'p' => password}
  response = Net::HTTP.post_form(uri, params)
  $stderr.write "keymaster status was: #{response.code} response body was #{response.body}\n"
  if response.code == '200'
    $stderr.write "account service returning: #{response.body}\n"
    content_type :json
    response.body
  else
    $stderr.write "Unable to Authorize user!\n"
    halt 401, 'Unable to Authorize user!'
  end
end

get '/' do
  $stderr.write "accountservice #{request.url}\n"
  haml :login, :content_type => 'text/html'
end

get '/password' do
  $stderr.write "accountservice #{request.url}\n"
  haml :password, :content_type => 'text/html'
end

get '/settings' do
  $stderr.write "accountservice #{request.url}\n"
  token = request.env['HTTP_AUTH_TOKEN']
  $stderr.write "accountservice #{request.url} token = #{token}\n"

  if token != 'LIVEKALECHECKPOINT'
    halt 401, 'Ooops, request not authenticated. Did you login?'
  else
    haml :settings, :content_type => 'text/html'
  end
end

get '/forbidden' do
  halt(403, haml(:forbidden))
end

get '/not_found' do
  halt(404, haml(:not_found))
end

__END__

@@ layout
%html
  %head
  %title
    Account Service
  %body{:style => 'text-align: center'}
    = yield

@@ index
%h1 Welcome to the Account Service!
%a{:href => '//logout?destination=/b/'}
  logout

@@ loggedout
%h1 Oops, You are not logged in.
%a{:href => '//b/login'}
  login

@@ login
%h1
  ACCOUNT SERVICE LOGIN

%form{:action => "/account/login", :method => 'post'}
  %label
    Username
    %input{:name => "username", :type => "text", :value => "user@example.com"}
  %br/
  %label
    Password
    %input{:name => "password", :type => "password", :value => "password"}
  %br/
  %input{:type => "submit", :name => "login", :value => "login"}

@@ password
%h1
  THIS IS THE ACCOUNT MANAGEMENT PAGE

%form{:action => "/", :method => 'post'}
  %label
    Username
    %input{:name => "username", :type => "text", :value => "user@example.com"}
  %br/
  %label
    Password
    %input{:name => "password", :type => "password", :value => "password"}
  %br/
  %input{:type => "submit", :name => "login", :value => "login"}

@@ settings
%h1
  THIS IS THE ACCOUNT SETTINGS PAGE

@@ forbidden
%h1
  403 FORBIDDEN

@@ not_found
%h1
  404 NOT FOUND
