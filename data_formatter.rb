module DataFormatter

  def flatten_hash(genre_xpath_hash)
    # {"A" => { "B" => "C" , "D" => "E"}, "F" => "G"}  ==>  {"A B" => "C" , "A D" => "E", "F" => "G"}
    genre_xpath_hash.map do |k, v|
      (v.is_a?(String) \
        ? [k, v] \
        : v.map { |inner_k, inner_v| ["#{k} #{inner_k}", inner_v] }
      )
    end.flatten.each_slice(2).to_h
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

end
