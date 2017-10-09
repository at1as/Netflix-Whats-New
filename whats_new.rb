require 'byebug'
require 'date'
require 'net/http'
require 'nokogiri'

netflix_content_uri = "https://en.wikipedia.org/wiki/List_of_original_programs_distributed_by_Netflix"

original_series = {
  "Drama"             => '//*[@id="mw-content-text"]/div/table[1]/tr',
  "Marvel Series"     => '//*[@id="mw-content-text"]/div/table[2]/tr',
  "Comedy"            => '//*[@id="mw-content-text"]/div/table[3]/tr',
  "Miniseries"        => '//*[@id="mw-content-text"]/div/table[4]/tr',
  "Adult animation"   => '//*[@id="mw-content-text"]/div/table[5]/tr',
  #"Kids/Teens/Family" => {
  #                          "Animated"    => '//*[@id="mw-content-text"]/div/table[6]/tr',
  #                          "Live-Action" => '//*[@id="mw-content-text"]/div/table[7]/tr',
  #},
  "Foreign language"  => '//*[@id="mw-content-text"]/div/table[8]/tr',
  "Co-productions"    => '//*[@id="mw-content-text"]/div/table[9]/tr',
  "Continuations"     => '//*[@id="mw-content-text"]/div/table[10]/tr',
  "Docu-series"       => '//*[@id="mw-content-text"]/div/table[11]/tr',
  "Reality"           => '//*[@id="mw-content-text"]/div/table[12]/tr',
  "Talk shows"        => '//*[@id="mw-content-text"]/div/table[13]/tr',
  "Specials"          => '//*[@id="mw-content-text"]/div/table[14]/tr',
  "Stand-up comedy"   => '//*[@id="mw-content-text"]/div/table[15]/tr',
}

original_films = {
  "Drama"             => '//*[@id="mw-content-text"]/div/table[16]/tr',
  "Comedy"            => '//*[@id="mw-content-text"]/div/table[17]/tr',
  "Documentaries"     => '//*[@id="mw-content-text"]/div/table[18]/tr',
}



def get_columns(table_header)
  table_header.first.text.split("\n")
end

def get_new_shows(table_rows)
  upcoming = table_rows.drop_while { |x| x.text.strip.downcase != "upcoming" }.drop(1)
  upcoming.map { |show| show.text.split("\n") }
end

def get_new_show_details(xml_table)
  fields = get_columns(xml_table)
  shows  = get_new_shows(xml_table)
  shows.map { |show| fields.zip(show) }.first.to_h.reject { |x, y| x.empty? }
end

def sanatize_references(show_details_hash)
  # "Status"=>"Renewed[18]"  =>  "Status"=>"Renewed"
  show_details_hash.inject({}) do |hash, (k, v)|
    hash.merge(
      k => v.gsub(/\[[0-9]*\]/, "")
    )
  end
end

def fix_datestamp(show_details_hash)
  # "Premiere"=>"000000002017-10-20-0000October 20, 2017"  =>  "Premiere"=>"October 20, 2017"
  show_details_hash.inject({}) do |hash, (k, v)|
    hash.merge(
      (k.downcase == "premiere" \
        ? { k => v.rpartition(/[A-Z].*\Z/).reject { |x| x.empty? }.last } \
        : { k => v }
      )
    )
  end
end

def sanatize_data(show_details_hash)
  removed_references = sanatize_references(show_details_hash)
  fix_datestamp(removed_references)
end

def print_row(show_details_hash)
  if show_details_hash != {}
    puts "#{show_details_hash["Premiere"]} : #{show_details_hash["Title"]}" +
         "\n\t#{show_details_hash.reject {|x| ["title", "premiere"].include? x.downcase}}"
  else
    puts "None"
  end
end



site     = Net::HTTP.get(URI(netflix_content_uri))
xml_site = Nokogiri::XML(site)


original_series.each_pair do |genre, xpath|
  table = xml_site.xpath(xpath)
  
  puts "\n### Upcoming #{genre} Series ###\n"
  new_shows = get_new_show_details(table)

  print_row(sanatize_data(new_shows))
end

original_films.each_pair do |genre, xpath|
  table = xml_site.xpath(xpath)

  puts "\n### Upcoming #{genre} Series ###\n"
  new_movies = get_new_show_details(table)
  
  print_row(sanatize_data(new_movies))
end

