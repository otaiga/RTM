require 'rubygems'
require 'rexml/document'
require 'net/http'
require 'net/https'
require 'uri'
require 'open-uri'
require 'digest/md5'
require 'sinatra'

#removed keys

include REXML

apikey=""
secret=""
$frob=""
$token=""
$Authurl=""

class Frob
        def get_Frob(secret, apikey)
        auth_url ="https://api.rememberthemilk.com/services/rest/"
        newapi= "api_key#{apikey}"
        method = "methodrtm.auth.getFrob"
        frob =  secret + newapi + method
        api_sig=Digest::MD5.hexdigest(frob)
#The web request
        method_url = '?method=rtm.auth.getFrob'
        api_url = "&api_key=#{apikey}"
        api_sig_url = "&api_sig=#{api_sig}"
        request = auth_url+method_url+api_url+api_sig_url

# get the XML data as a string
		xml_data = open(request) {|http| http.read}
        #xml_data = Net::HTTP.get_response(URI.parse(request)).body
        doc = Document.new(xml_data)
        entry = doc.elements.to_a("//frob")
        entry1 = entry[0].to_s
        frob1=entry1.gsub!('<frob>','')
        frob2=frob1.gsub!('</frob>','')
        $frob =frob2
        "Job done frob is stored as #{$frob}"
        end
end


#The AuthDesk didn't work
class AuthDesk
        def get_auth(secret, apikey)
        auth_url = "http://www.rememberthemilk.com/services/auth/"
        parameter = '&perms=delete'
        puts $frob

#web request
        api_url="?&api_key=#{apikey}"
        frob_url ="&frob=#{$frob}"
        newapi = "api_key#{apikey}"
        newfrob = "frob#{$frob}"
        newparam = "permsdelete"
        api_sig_before = secret + newapi + newfrob + newparam
        puts "api sig before hash: #{api_sig_before}"
        api_sig = Digest::MD5.hexdigest(api_sig_before)
        api_sig_url = "&api_sig=#{api_sig}"
        request = auth_url+api_url+frob_url+parameter+api_sig_url
        puts "below is the request"
        puts request
        end
end

#This seems to be ok
class AuthWeb
        def get_auth(secret, apikey)
        auth_url = "http://www.rememberthemilk.com/services/auth/"
        api_url="?&api_key=#{apikey}"
        parameter = '&perms=delete'
        newapi = "api_key#{apikey}"
        newparam = "permsdelete"
        api_sig_before = secret + newapi + newparam
        api_sig = Digest::MD5.hexdigest(api_sig_before)
        api_sig_url = "&api_sig=#{api_sig}"
        request = auth_url+api_url+parameter+api_sig_url
        $Authurl=request

# get the XML data as a string
        #xml_data = Net::HTTP.get_response(URI.parse(request)).body
	#the below works but need to redirect?
       # xml_data = open(request) {|http| http.readlines}
        #puts xml_data
        #doc = Document.new(xml_data)
        #"#{xml_data}"
        #entry = doc.elements.to_a("//frob")
        #wonder if I can remove the tags by using scan
        #entry1 = entry.to_s
        #frob2 ="daf515c899103c5c7901901ed42199bc6a7b890b"

        #puts "Below is the frob:"
        #puts frob2
        
        #frob1=entry1.gsub!('<frob>','')
        #frob2=frob1.gsub!('</frob>','')
        #$frob =frob2
        end
end


class Token
        def get_Token(secret, apikey)
        newapi = "api_key#{apikey}"
        newfrob = "frob#{$frob}"
        url = "http://www.rememberthemilk.com/services/rest/?method=rtm.auth.getToken"
        api_url="&api_key=#{apikey}"
        frob_url ="&frob=#{$frob}"
        method = 'methodrtm.auth.getToken'
        api_sig_before = secret + newapi + newfrob + method

        api_sig = Digest::MD5.hexdigest(api_sig_before)
        api_sig_url = "&api_sig=#{api_sig}"
        request = url + api_url + frob_url + api_sig_url
        puts request
        
    	xml_data = open(request) {|http| http.read}
    	#xml_data = <<END_XML 
#    	<?xml version="1.0" encoding="UTF-8"?>
#<rsp stat="ok"><auth><token>95c563711e0bd8762c43b08389bfc6c6f458e3c1</token><perms>delete</perms><user id="2334334" username="karl.turner" fullname="Karl Turner"/></auth></rsp>
#END_XML
        doc = Document.new(xml_data)
        entry = doc.elements.to_a("//token")
        entry1 = entry[0].to_s
        tok=entry1.gsub!('<token>','')
        en=tok.gsub!('</token>','')
        $token = en
        puts "Job done frob is stored as #{$token}"
        
        end
end


class AddTask
        def add_task(apikey, secret, taska)
        #puts "please enter task name:"
        #task = gets.chomp
        #task = "Test with sinatra"
        task = taska
        timeline_url = "&timeline=10021"
        token = "95c563711e0bd8762c43b08389bfc6c6f458e3c1"
        url = "http://www.rememberthemilk.com/services/rest/?method=rtm.tasks.add"
        newapi = "api_key#{apikey}"
    	#name_url = "&name=test1fromrubysinatra"
        name_url = "&name=#{task}"

        api_url="&api_key=#{apikey}"
        token_url = "&auth_token=95c563711e0bd8762c43b08389bfc6c6f458e3c1"

        timeline ="timeline10021"
        tokenkey = "auth_token#{token}"
        name = "name#{task}"
        method = "methodrtm.tasks.add"
        api_sig_before = secret + newapi + tokenkey + method + name + timeline 
        
        api_sig = Digest::MD5.hexdigest(api_sig_before)
        api_sig_url = "&api_sig=#{api_sig}"
		request = url + api_url + name_url + timeline_url + token_url +api_sig_url
        open(URI.encode(request)) {|http| http.read} #Encode to send task with titles
        "Task named --#{task}-- added to RTM"
        end
end

#examples


#getfrob = Frob.new
#getfrob.get_Frob(secret, apikey)

# -  hard part as need the redirect!
#getauth = AuthWeb.new
#getauth.get_auth(secret, apikey)
# -

#getToken = Token.new
#getToken.get_Token(secret, apikey)


get '/' do 
    <<-HTML
     <form action='/addcred' method="POST">
        ApiKey <input type="text" name="apikey" />
        Secret <input type="text" name="secret" />
        <input type="submit" value="Add Credentials" />
      </form>
      <form action='/addtask' method="POST">
        Task <input type="text" name="name" />
        <input type="submit" value="Add Task" />
      </form>
        <form action='/authcert' method="POST">
        <input type="submit" value="Get Auth!" />
      </form>
     	<form action='/frobcert' method="POST">
        <input type="submit" value="Get Frob!" />
      </form>
    HTML
  end


post '/addtask' do
    taska = "#{params[:name]}"
	add_Task = AddTask.new
	add_Task.add_task(apikey, secret, taska)
	"Added #{params[:name] || 'No task to add?'}"
  end

post '/addcred' do
    apikey = "#{params[:apikey]}"
    secret = "#{params[:secret]}"
    "added!"
    end
    
post '/authcert' do
	getauth = AuthWeb.new
	getauth.get_auth(secret, apikey)
	redirect $Authurl
end

post '/frobcert' do
	getfrob = Frob.new
	getfrob.get_Frob(secret, apikey)
end
	
#add_Task = AddTask.new
#add_Task.add_task(apikey, secret)


#add_Task = AddTask.new
#add_Task.add_task(apikey, secret)
