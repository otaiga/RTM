require 'rexml/document'
require 'net/http'
require 'uri'
require 'digest/md5'

include REXML

apikey="eec6c424a7c955d10ff39766842475f7"
secret="bbf27ca673d33706"
$frob=""

class Frob
        def get_Frob(secret, apikey)
        auth_url ="https://api.rememberthemilk.com/services/rest/"
        newapi= "api_key#{apikey}"
        method = "methodrtm.auth.getFrob"
        frob =  secret + newapi + method
        api_sig=Digest::MD5.hexdigest(frob)
        #puts "api_sig = #{api_sig }"

#The web request
        method_url = '?method=rtm.auth.getFrob'
        api_url = "&api_key=#{apikey}"
        api_sig_url = "&api_sig=#{api_sig}"
        request = auth_url+method_url+api_url+api_sig_url
        #puts "Below is the request required to get frob number:"
        #puts request
        testrequest="http://gibbon/testrtm.xml"

# get the XML data as a string
        xml_data = Net::HTTP.get_response(URI.parse(testrequest)).body
        #puts xml_data
        doc = Document.new(xml_data)
        #puts doc
        entry = doc.elements.to_a("//frob")
        #wonder if I can remove the tags by using scan
        entry1 = entry.to_s
        #puts "Below is the frob:"
        #puts entry1
        frob1=entry1.gsub!('<frob>','')
        frob2=frob1.gsub!('</frob>','')
        $frob =frob2
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
        #puts "api sig before hash: #{api_sig_before}"
        api_sig = Digest::MD5.hexdigest(api_sig_before)
        api_sig_url = "&api_sig=#{api_sig}"
        request = auth_url+api_url+parameter+api_sig_url
        #puts "below is the request"
        #puts request


# get the XML data as a string
        #xml_data = Net::HTTP.get_response(URI.parse(request)).body
        #puts xml_data
        #doc = Document.new(xml_data)
        #puts doc
        #entry = doc.elements.to_a("//frob")
        #wonder if I can remove the tags by using scan
        #entry1 = entry.to_s
        frob2 ="aee607d1df7646033e5d11e993a9cd23f0981e0c"

        #puts "Below is the frob:"
        #puts frob2
        
        #frob1=entry1.gsub!('<frob>','')
        #frob2=frob1.gsub!('</frob>','')
        $frob =frob2
        end
end


class Token
        def get_Token(secret, apikey)
        newapi = "api_key#{apikey}"
        newfrob = "frob#{$frob}"
        url = "https://api.rememberthemilk.com/services/rest/?method=rtm.auth.getToken"
        api_url="&api_key=#{apikey}"
        frob_url ="&frob=#{$frob}"
        method = 'methodrtm.auth.getToken'
        api_sig_before = secret + newapi + newfrob + method

        api_sig = Digest::MD5.hexdigest(api_sig_before)
        api_sig_url = "&api_sig=#{api_sig}"
        request = url + api_url + frob_url + api_sig_url
        #puts request
        end
end


class AddTask
        def add_task(apikey, secret)
        puts "please enter task name:"
        task = gets.chomp
        timeline_url = "&timeline=10021"
        token = "95c563711e0bd8762c43b08389bfc6c6f458e3c1"
        url = "https://api.rememberthemilk.com/services/rest/?method=rtm.tasks.add"
        newapi = "api_key#{apikey}"
        # - original: name_url = "&name=test1fromruby"
        name_url = "&name=#{task}"

        api_url="&api_key=#{apikey}"
        token_url = "&auth_token=95c563711e0bd8762c43b08389bfc6c6f458e3c1"

        #still needs a signature!!
        timeline ="timeline10021"
        tokenkey = "auth_token#{token}"
        name = "name#{task}"
        method = "methodrtm.tasks.add"
        api_sig_before = secret + newapi + tokenkey + method + name + timeline 
        
        api_sig = Digest::MD5.hexdigest(api_sig_before)
        api_sig_url = "&api_sig=#{api_sig}"
		request = url + api_url + name_url + timeline_url + token_url +api_sig_url
        puts api_sig_before
        puts ""
        puts request
        end
end


#getfrob = Frob.new
#getfrob.get_Frob(secret, apikey)
getauth = AuthWeb.new
getauth.get_auth(secret, apikey)
getToken = Token.new
getToken.get_Token(secret, apikey)
add_Task = AddTask.new
add_Task.add_task(apikey, secret)