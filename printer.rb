module Printer

  def pretty_print_hash(hash)
    max_key_length = hash.keys.sort.last.length
    padding        = " " * max_key_length

    hash.each do |k, v|
      key = "#{k}#{padding}"[0..max_key_length]

      puts "\t\t#{key} : #{v}"
    end
  end

  def print_row(show_details_hash)
    if show_details_hash != {}
      
      puts "\n#{show_details_hash["Premiere"]} :\n\n"
      puts "\t- #{show_details_hash["Title"]}\n"
      
      fields = show_details_hash.reject {|x| ["title", "premiere"].include? x.downcase}
      pretty_print_hash(fields)
    else
      puts "None"
    end
  end

  def print_heading(genre, media_type, character_width=40)
    #  ==>  ##### Upcoming Drama Series #####
    title   = "Upcoming #{genre.split.map(&:capitalize).join(" ")} #{media_type.capitalize}"
    title   = title.split.uniq.join(" ")

    padding = "#" * (character_width - title.length / 2 - 1)
    heading = "#{padding} #{title} #{padding}"

    puts
    puts (heading.length % 2 == 0 ? "#{heading}#" : heading )
    puts
  end

  def print_new_listings(new_listings) 
    new_listings.each do |listing|
      print_row(sanatize_data(listing))
    end
    
    puts ?\n
  end

end
