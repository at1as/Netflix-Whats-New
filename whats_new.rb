require 'byebug'
require 'date'
require 'net/http'
require 'nokogiri'
require_relative './data_formatter'
require_relative './printer'
require_relative './wikipedia_xpath'
require_relative './xml_parser'



class WhatsNew

  include DataFormatter
  include Printer
  include XMLParser


  NETFLIX_CONTENT_URI = "https://en.wikipedia.org/wiki/List_of_original_programs_distributed_by_Netflix"

  def initialize(date = nil)
    @site         = Net::HTTP.get(URI(NETFLIX_CONTENT_URI))
    @xml_site     = Nokogiri::XML(@site)
    @target_date  = DateTime.parse(date) rescue DateTime.now
  end


  def new_media(xpath_hash, media_type)
    flatten_hash(xpath_hash).each_pair do |genre, xpath|
      
      table = @xml_site.xpath(xpath)
      
      new_listings = get_new_show_details(table)

      print_heading(genre, media_type)
      print_new_listings(new_listings)
    end
  end

end


fetch_entries = WhatsNew.new
fetch_entries.new_media(XPath::ORIGINAL_SERIES, "series")
fetch_entries.new_media(XPath::ORIGINAL_FILMS,  "movie")

