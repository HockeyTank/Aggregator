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


