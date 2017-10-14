require 'byebug'
require 'date'
require 'net/http'
require 'nokogiri'
require_relative './wikipedia_xpath'

NETFLIX_CONTENT_URI = "https://en.wikipedia.org/wiki/List_of_original_programs_distributed_by_Netflix"


def flatten_hash(genre_xpath_hash)
  # {"A" => { "B" => "C" , "D" => "E"}, "F" => "G"}  ==>  {"A B" => "C" , "A D" => "E", "F" => "G"}
  genre_xpath_hash.map do |k, v|
    (v.is_a?(String) \
      ? [k, v] \
      : v.map { |inner_k, inner_v| ["#{k} #{inner_k}", inner_v] }
    )
  end.flatten.each_slice(2).to_h
end

def get_column_names(table_rows)
  # <xml table rows>  ==> 
  #       ["Title", "Genre", "Premiere", "Seasons", "Length", "Status"]
  table_rows.first.children.map { |x| x.text }.reject { |x| x == "\n" }
end

def get_formatted_shows(table_rows)
  # <xml table rows>  ==>
  #       [["Mindhunter", "Drama", "October 13, 2017", "1 Season, 10 episodes", "50-80 mins", "Renewed"], [...]]
  upcoming = table_rows.drop_while { |x| x.text.strip.downcase != "upcoming" }.drop(1)

  upcoming.map do |show_row|
    show_row.children.map { |x| x.text.gsub("\n", "") }.reject { |x| x.empty? }
  end
end

def get_new_show_details(xml_table)
  # <xml table>  ==>  
  #       [{"Title": "Mindhunter", "Genre": "Drama", "Premiere": "October 13, 2017", ...} , {...}]
  fields = get_column_names(xml_table)
  shows  = get_formatted_shows(xml_table)
 
  shows.map { |show| fields.zip(show) }.map { |x| x.to_h }
end

def sanatize_references(show_details_hash)
  # Removes superscript references
  #   "Status"=>"Renewed[18]"  =>  "Status"=>"Renewed"
  show_details_hash.inject({}) do |hash, (k, v)|
    hash.merge(
      k => v.gsub(/\[[0-9]*\]/, "")
    )
  end
end

def fix_datestamp(show_details_hash)
  # Removes trailing date characters (these come from a hidden <span>)
  #   "Premiere"=>"000000002017-10-20-0000October 20, 2017"  =>  "Premiere"=>"October 20, 2017"
  show_details_hash.inject({}) do |hash, (k, v)|
    hash.merge(
      (k.downcase == "premiere" \
        ? { k => v.rpartition(/[A-Z].*\Z/).reject { |x| x.empty? }.last } \
        : { k => v }
      )
    )
  end
end

def fix_season_list(show_details_hash)
  # "010 !1 season, 10 episodes"  =>  "1 season, 10 episodes"
  show_details_hash.inject({}) do |hash, (k, v)|
    hash.merge(
      { k => v.split(/^[0-9]* !/).last }
    )
  end
end

def sanatize_data(show_details_hash)
  removed_references = sanatize_references(show_details_hash)
  fixed_seasons      = fix_season_list(removed_references)

  fix_datestamp(fixed_seasons)
end

def pretty_print_hash(hash)
  max_key_length = hash.keys.sort.last.length
  padding        = " " * max_key_length

  hash.each do |k, v|
    key = "#{k}#{padding}"[0..max_key_length]

    puts "\t\t#{key} : #{v}"
  end
end

def print_row(show_details_hash)
  return if show_details_hash == {}
    
  puts "\n#{show_details_hash["Premiere"]} :\n\n"
  puts "\t- #{show_details_hash["Title"]}\n"
  
  fields = show_details_hash.reject {|x| ["title", "premiere"].include? x.downcase}
  pretty_print_hash(fields)
end

def print_heading(genre, media_type, character_width=50)
  #  ==>  ##### Upcoming Drama Series #####
  title   = "Upcoming #{genre.split.map(&:capitalize).join(" ")} #{media_type.capitalize}"
  title   = title.split.uniq.join(" ")

  padding = "#" * (character_width - title.length / 2 - 1)
  heading = "#{padding} #{title} #{padding}"

  puts
  puts (heading.length % 2 == 0 ? "#{heading}#" : heading )
  puts
end


target_date = DateTime.parse(ARGV.first) rescue DateTime.now

site     = Net::HTTP.get(URI(NETFLIX_CONTENT_URI))
xml_site = Nokogiri::XML(site)


flatten_hash(XPath::ORIGINAL_SERIES).each_pair do |genre, xpath|
  table = xml_site.xpath(xpath)
  
  print_heading(genre, "series")
  new_shows = get_new_show_details(table)

  new_shows.each do |show|
    print_row(sanatize_data(show))
  end
end


flatten_hash(XPath::ORIGINAL_FILMS).each_pair do |genre, xpath|
  table = xml_site.xpath(xpath)

  print_heading(genre, "movies")
  new_movies = get_new_show_details(table)

  new_movies.each do |movie|
    print_row(sanatize_data(movie))
  end
end

