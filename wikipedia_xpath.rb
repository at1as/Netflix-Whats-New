module XPath

  ORIGINAL_SERIES = {
    "Drama"             => '//*[@id="mw-content-text"]/div/table[1]/tr',
    "Marvel Series"     => '//*[@id="mw-content-text"]/div/table[2]/tr',
    "Comedy"            => '//*[@id="mw-content-text"]/div/table[3]/tr',
    "Miniseries"        => '//*[@id="mw-content-text"]/div/table[4]/tr',
    "Adult animation"   => '//*[@id="mw-content-text"]/div/table[5]/tr',
    "Kids/Teens/Family" => {
                              "Animated"    => '//*[@id="mw-content-text"]/div/table[6]/tr',
                              "Live-Action" => '//*[@id="mw-content-text"]/div/table[7]/tr',
    },
    "Foreign language"  => '//*[@id="mw-content-text"]/div/table[8]/tr',
    "Co-productions"    => '//*[@id="mw-content-text"]/div/table[9]/tr',
    "Continuations"     => '//*[@id="mw-content-text"]/div/table[10]/tr',
    "Docu-series"       => '//*[@id="mw-content-text"]/div/table[11]/tr',
    "Reality"           => '//*[@id="mw-content-text"]/div/table[12]/tr',
    "Talk shows"        => '//*[@id="mw-content-text"]/div/table[13]/tr',
    "Specials"          => '//*[@id="mw-content-text"]/div/table[14]/tr',
    "Stand-up comedy"   => '//*[@id="mw-content-text"]/div/table[15]/tr',
  }

  ORIGINAL_FILMS = {
    "Drama"             => '//*[@id="mw-content-text"]/div/table[16]/tr',
    "Comedy"            => '//*[@id="mw-content-text"]/div/table[17]/tr',
    "Documentaries"     => '//*[@id="mw-content-text"]/div/table[18]/tr',
  }

end
