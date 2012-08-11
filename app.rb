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
  f = File.open('data/' << file, 'r')
  doc = Nokogiri::HTML(f.read())
 
  rinklinks = Array.new

  doc.css('a').each do |node|
   node['href'].each do |link|
     rinklinks.push(link)
   end
  end

  rinklinks.each do |rink|
    #cast the string as a URI 
    uri = URI(rink) 
    #load the URI contents into a nokogiri html doc
    doc = Nokogiri::HTML(Net::HTTP.get(uri))
    puts doc.css("#locationBasicInfo")
  end

end
