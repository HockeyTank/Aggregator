require 'nokogiri'
require 'net/http'

f = File.open(ARGV[0]) or die "Unable to open file..."

#generate container
contentsArray=[]

#add each line of file if its not blank
f.each_line do |line| 
    contentsArray.push line
end

#Iterate through the array
i = 0
contentsArray.each do |link|
  #cast the string as a URI 
  uri = URI(link) 
  #load the URI contents into a nokogiri html doc
  doc = Nokogiri::HTML(Net::HTTP.get(uri))
  
  #assign the content we want to a variable
  locs =  doc.css('#LocationContainer')

  #for simplicity sake, name each file incrementally
  #the output will contain links to sub-navigation
  #where we can pull the specific location information
  w = File.open('data/' << i.to_s, 'w') 
  w.write(locs)
    
  i = i + 1
end

#Grab the file, and fetch each rink's markup, distill to only the rink info, and save it
files = Dir.entries('data/')

files.each do |file|
  unless File.directory?(file) then
    f = File.open('data/' << file, 'r')
    doc = Nokogiri::HTML(f.read())
   
    rinklinks = Array.new

    doc.css('a').each do |node|
     #node['href'].each do |link|
     node['href'].split('\n').each do |link|
       link = "http://www.rinktime.com/" << link
       rinklinks.push(link)
     end
    end
    
    addressbook = File.open('rinks.csv', 'a+')
    rinklinks.each do |rink|
      #cast the string as a URI 
      uri = URI(rink) 
      #load the URI contents into a nokogiri html doc
      doc = Nokogiri::HTML(Net::HTTP.get(uri))
        if (doc.css("#LocationAddress1") != nil and 
           doc.css("#LocationName") != nil and 
           doc.css("#LocationCityStateZip") != nil) then
        
          begin
          addressbook.write(doc.css("#locationName").inner_text << "|") 
          addressbook.write(doc.css("#LocationAddress1").inner_text << "|")
          #captured data is in the following format:  Phoenix, AZ 85050
          #we need to split city, state and zip - the following block accomplishes that
          location =  doc.css("#LocationCityStateZip").inner_text.split(',')
          loc2 = location[1].split(' ')
          addressbook.write(location[0] << "|" << loc2[0] << "|" << loc2[1] << "|")
          addressbook.write(doc.css("#LocationPhone").inner_text << "\r\n")
          rescue
          #nothing to do here
          end

        end
     end
    end
  end

