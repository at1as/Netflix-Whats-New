module XMLParser
  
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

end
