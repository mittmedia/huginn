# Översätt parsat datum till svenska (juni, måndag etc.)
module Agents::SMHI::Datumsv
    MONTHS = {
        1 => "januari",
        2 => "februari",
        3 => "mars",
        4 => "april",
        5 => "maj",
        6 => "juni",
        7 => "juli",
        8 => "augusti",
        9 => "september",
        10 => "oktober",
        11 => "november",
        12 => "december"
    }
    DAGAR = {
        1 => "måndagen",
        2 => "tisdagen",
        3 => "onsdagen",
        4 => "torsdagen",
        5 => "fredagen",
        6 => "lördagen",
        7 => "söndagen"
    }
    GANGS = {
        1 => "första",
        2 => "andra",
        3 => "tredje",
        4 => "fjärde",
        5 => "femte",
        6 => "sjätte",
        7 => "sjunde",
        8 => "åttonde",
        9 => "nionde",
        10 => "tionde"
    }
end
