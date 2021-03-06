module Agents::TRAFIKVERKET::Tv
    LANSNUMMER = {
        0 => "alla län",
        1 => "Stockholms län",
        3 => "Uppsala län",
        4 => "Södermanland",
        5 => "Östergötland",
        6 => "Jönköpings län",
        7 => "Kronoberg",
        8 => "Kalmar län",
        9 => "Gotland",
        10 => "Blekinge",
        12 => "Skåne",
        13 => "Halland",
        14 => "Västra Götaland",
        17 => "Värmland",
        18 => "Örebro län",
        19 => "Västmanland",
        20 => "Dalarna",
        21 => "Gävleborg",
        22 => "Västernorrland",
        23 => "Jämtland",
        24 => "Västerbotten",
        25 => "Norrbotten",
        26 => "#robot_trafikinfo",
        27 => "#robot_farjeinfo"
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
    MANAD = {
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

    MONTH = {
        "januari" => "january",
        "februari" => "february",
        "mars" => "mars",
        "april" => "april",
        "maj" => "may",
        "juni" => "june",
        "juli" => "july",
        "augusti" => "august",
        "september" => "september",
        "oktober" => "october",
        "november" => "november",
        "december" => "december",
        "jan" => "january",
        "feb" => "february",
        "mar" => "mars",
        "apr" => "april",
        "jun" => "june",
        "jul" => "july",
        "aug" => "august",
        "sep" => "september",
        "okt" => "october",
        "nov" => "november",
        "dec" => "december",
  }

    PRIONIV = {
        "Ingen påverkan" => 1,
        "Liten påverkan" => 2,
        "Stor påverkan" => 3,
        "Mycket stor påverkan" => 4
    }
    LEVEL = {
        "resurfacingWork" => :belagg,
        "animalsOnTheRoad" => :djurpv,
        "brokenDownVehicle" => :fordonshaveri,
        "ferry" => :farja,
        "notWorking" => :ickefung,
        "slowTraffic" => :langsamtr,
        "slowVehicle" => :lgf,
        "accident" => :olycka,
        "blastingWork" => :sprangarb,
        "majorEvent" => :stortevent,
        "maintenanceWork" => :underhall,
        "roadworks" => :vagarb,
        "roadClosed" => :avstangdvag,
        "roadSurfaceInPoorCondition" => :vagskada,
        "oilOnRoad" => :olja,
        "flooding" => :oversv,
        "unprotectedAccidentArea" => :oskyddat,
        "followDiversionSigns" => :omledning,
        "hazardsOnTheRoad" => :farapavag,
        "obstructionOnTheRoad" => :hinderpavag,
        "vehicleOnFire" => :brinnande,
        "queuingTraffic" => :koer,
        "bridgeSwingInOperation" => :bro,
        "objectOnTheRoad" => :foremal,
        "laneClosures" => :filer,
        "hardShoulder" => :diverse,
        "contraflow" => :dubbelriktad,
        "stationaryTraffic" => :diverse,
        "followLocalDiversion" => :anvisning,
        "vehicleRecovery" => :fordonshaveri,
        "seriousFire" => :brand,
        "InfrastructureDamageObstruction" => :vagskada,
        "accidentInvolvingHeavyLorries" => :lastbil,
        "peopleOnRoadway" => :eftersok,
        "fallenTrees" => :fallnatrad,
        "blackIceHalt" => :asfalt,
        "blackIce" => :asfalt,
        "vehicleOnWrongCarriageway" => :felsida,
        "accidentInvolvingHazardousMaterials" => :olycka,
        "strongWinds" => :starkavindar
    }
# =begin
    RUBRIKER = {
        PRIONIV[4] => {
          :belagg => "Stora störningar i trafiken på grund av vägarbete",
          :djurpv => "JUST NU: Djur på vägen",
          :fordonshaveri => "JUST NU: Trasigt fordon stör trafiken",
          :farja => "Stora störningar i färjeförbindelsen",
          :ickefung => "JUST NU: Stora störningar i trafiken",
          :langsamtr => "JUST NU: långa köer i trafiken",
          :lgf => "Långsamt fordon på vägen stör trafiken",
          :olycka => "JUST NU: Trafikolyckaskapar köer",
          :sprangarb => "Sprängarbeten stör trafiken",
          :stortevent => "JUST NU: Stora trafikstörningar",
          :underhall => "JUST NU: Stora trafikstörningar",
          :vagarb => "Vägarbete skapar stora trafikstörningar",
          :avstangdvag => "Passage avstängd – orsakar trafikstörningar",
          :vagskada => "Skadat vägparti skapar störningar i trafiken",
          :olja => "JUST NU: Olja på vägen stör trafiken",
          :oversv => "JUST NU: Översvämning stör trafiken",
          :oskyddat => "JUST NU: Trafikolycka skapar köer",
          :omledning => "Stora störningar på vägarna – trafiken leds om",
          :farapavag => "JUST NU: Föremål på vägbanan",
          :hinderpavag => "JUST NU: Hinder på vägbanan",
          :brinnande => "JUST NU: Brinnande fordon stoppar trafiken",
          :koer => "Köer på vägen – Trafikverket varnar trafikanter",
          :bro => "JUST NU: Broöppning ger stopp i trafiken",
          :foremal => "JUST NU: Föremål på vägen",
          :filer => "Körfält avstängda – skapar stora störningar i trafiken",
          :diverse => "JUST NU: Störningar i biltrafiken",
          :dubbelriktad => "Trafiken tillfälligt dubbelriktad – varning utfärdad",
          :anvisning => "JUST NU: Trafiken måste ledas om",
          :brand => "JUST NU: Allvarlig brand påverkar trafiken",
          :lastbil => "JUST NU: Trafikolycka med lastbil",
          :eftersok => "Människor kan finnas längs vägen – trafikanter varnas",
          :fallnatrad => "Fallna träd skapar problem i trafiken",
          :asfalt => '"Blödande" asfalt stör trafiken',
          :felsida => 'JUST NU: Trafikanter varnas för bil på fel sida',
          :starkavindar => "JUST NU: Starka vindar stör trafiken"
        },
        PRIONIV[5] => {
                  :belagg => "Stora störningar i trafiken på grund av vägarbete",
          :djurpv => "JUST NU: Djur på vägen",
          :fordonshaveri => "JUST NU: Trasigt fordon stör trafiken",
          :farja => "Stora störningar i färjeförbindelsen",
          :ickefung => "JUST NU: Stora störningar i trafiken",
          :langsamtr => "JUST NU: långa köer i trafiken",
          :lgf => "Långsamt fordon på vägen stör trafiken",
          :olycka => "JUST NU: Trafikolycka skapar köer",
          :sprangarb => "Sprängarbeten stör trafiken",
          :stortevent => "JUST NU: Stora trafikstörningar",
          :underhall => "JUST NU: Stora trafikstörningar",
          :vagarb => "Vägarbete skapar stora trafikstörningar",
          :avstangdvag => "Passage avstängd – orsakar trafikstörningar",
          :vagskada => "Skadat vägparti skapar störningar i trafiken",
          :olja => "JUST NU: Olja på vägen stör trafiken",
          :oversv => "JUST NU: Översvämning stör trafiken",
          :oskyddat => "JUST NU: Trafikolycka skapar köer",
          :omledning => "Stora störningar på vägarna – trafiken leds om",
          :farapavag => "JUST NU: Föremål på vägbanan",
          :hinderpavag => "JUST NU: Hinder på vägbanan",
          :brinnande => "JUST NU: Brinnande fordon stoppar trafiken",
          :koer => "Köer på vägen – Trafikverket varnar trafikanter",
          :bro => "JUST NU: Broöppning ger stopp i trafiken",
          :foremal => "JUST NU: Föremål på vägen",
          :filer => "Körfält avstängda – skapar stora störningar i trafiken",
          :diverse => "JUST NU: Störningar i biltrafiken",
          :dubbelriktad => "Trafiken tillfälligt dubbelriktad – varning utfärdad",
          :anvisning => "JUST NU: Trafiken måste ledas om",
          :brand => "JUST NU: Allvarlig brand påverkar trafiken",
          :lastbil => "JUST NU: Trafikolycka med lastbil",
          :eftersok => "Människor kan finnas längs vägen – trafikanter varnas",
          :fallnatrad => "Fallna träd skapar problem i trafiken",
          :asfalt => '"Blödande" asfalt stör trafiken',
          :felsida => 'JUST NU: Trafikanter varnas för bil på fel sida',
          :starkavindar => "JUST NU: Starka vindar stör trafiken"
        }
    }

    BESKR = {
        "resurfacingWork" => "Ett beläggningsarbete",
        "animalsOnTheRoad" => "Djur har kommit upp på vägen och",
        "brokenDownVehicle" => "Ett trasigt fordon",
        "ferry" => "Ett problem med en färja",
        "notWorking" => "Stora trafikstörningar",
        "slowTraffic" => "Trafiken går mycket långsamt och",
        "slowVehicle" => "Ett långsamtgående fordon",
        "accident" => "En olycka",
        "blastingWork" => "Sprängningsarbeten",
        "majorEvent" => "Evenemanget",
        "maintenanceWork" => "Underhållsarbete",
        "roadworks" => "Ett större vägarbete",
        "roadClosed" => "En avstängd väg",
        "roadSurfaceInPoorCondition" => "Det dåliga skicket på vägbanan",
        "oilOnRoad" => "Olja på vägen",
        "flooding" => "En översvämmad väg",
        "unprotectedAccidentArea" => "En trafikolycka",
        "followDiversionSigns" => "En avstängd väg gör att trafiken måste ledas om och det",
        "hazardsOnTheRoad" => "Ett farligt föremål på vägen",
        "obstructionOnTheRoad" => "Ett hinder på vägbanan",
        "vehicleOnFire" => "Ett brinnande fordon",
        "queuingTraffic" => "Långa bilköer",
        "bridgeSwingInOperation" => "En broöppning",
        "objectOnTheRoad" => "Föremål på vägen",
        "laneClosures" => "Stängda körfält",
        "hardShoulder" => "En störning",
        "contraflow" => "Tillfälligt dubbelriktad trafik",
        "stationaryTraffic" => "En störning",
        "followLocalDiversion" => "En tillfällig omledning av trafiken",
        "vehicleRecovery" => "Ett omhändertagande av ett fordon",
        "seriousFire" => "En brand",
        "InfrastructureDamageObstruction" => "En vägskada",
        "fallenTrees" => "Nerfallna träd",
        "accidentInvolvingHeavyLorries" => "En lastbilsolycka",
        "peopleOnRoadway" => "Människor på vägbanan",
        "blackIce" => 'Svart is på vägbanan',
        "vehicleOnWrongCarriageway" => "Ett fordon på fel sida av vägbanan",
        "strongWinds" => "Starka vindar"

    }

    BESKR2 = {
    "resurfacingWork" => "beläggninsarbete",
    "animalsOnTheRoad" => "djur har kommit upp på vägen",
    "brokenDownVehicle" => "ett trasigt fordon",
    "ferry" => "ett problem med en färja",
    "notWorking" => "stora trafikstörningar",
    "slowTraffic" => "trafiken går mycket långsamt",
    "slowVehicle" => "ett långsamtgående fordon",
    "accident" => "en olycka",
    "blastingWork" => "sprängningsarbeten",
    "majorEvent" => "evenemang",
    "maintenanceWork" => "underhållsarbete",
    "roadworks" => "ett större vägarbete",
    "roadClosed" => "en avstängd väg",
    "roadSurfaceInPoorCondition" => "det dåliga skicket på vägbanan",
    "oilOnRoad" => "olja på vägen",
    "flooding" => "en översvämmad väg",
    "unprotectedAccidentArea" => "en olycka där man ännu inte har kunnat spärra av vägen",
    "followDiversionSigns" => "en avstängd väg gör att trafiken måste ledas om",
    "hazardsOnTheRoad" => "ett farligt föremål på vägen",
    "obstructionOnTheRoad" => "ett hinder på vägbanan",
    "vehicleOnFire" => "ett brinnande fordon",
    "queuingTraffic" => "långa bilköer",
    "bridgeSwingInOperation" => "en broöppning",
    "objectOnTheRoad" => "föremål på vägen",
    "laneClosures" => "stängda körfält",
    "hardShoulder" => "en störning",
    "contraflow" => "tillfälligt dubbelriktad trafik",
    "stationaryTraffic" => "en störning",
    "followLocalDiversion" => "en tillfällig omledning av trafiken",
    "vehicleRecovery" => "ett omhändertagande av ett fordon",
    "seriousFire" => "en brand",
    "InfrastructureDamageObstruction" => "en vägskada",
    "fallenTrees" => "nerfallna träd",
    "accidentInvolvingHeavyLorries" => "en lastbilsolycka",
    "peopleOnRoadway" => "människor på vägbanan",
    "blackIce" => '"blödande" asfalt',
    "vehicleOnWrongCarriageway" => "ett fordon som färdas på fel sida av vägen",
    "strongWinds" => "starka vindar"
  }

    MEDDELANDETYP = {
        "Vägarbete" => "Ett vägarbete",
        "Viktig trafikinformation" => "Trafikverket går ut och informerar om en händelse som",
        "Färjor" => "Ett problem med en färja",
        "Hinder" => "Ett trafikhinder",
        "Olycka" => "En olycka",
        "Restriktion" => "Trafiken har begränsats och",
        "Trafikmeddelande" => "Trafikverket går ut med ett meddelande om en händelse som",
        "Väglag" => "Det jobbiga väglaget",
        "Väglagsöversikt" => "En översikt av väglaget"
    }

    CHANNEL = {
    "alla län" => ["#larm_ovriga_landet", "#larm_gavleborg", "#larm_orebro", "#larm_vasternorrland", "#larm_dalarna", "#larm_jamtland", "#larm_vastmanland", "#larm_stockholm"],
    "Stockholms län" => ["#larm_stockholm"],
    "Uppsala län" => ["#larm_ovriga_landet"],
    "Södermanland" => ["#larm_ovriga_landet"],
    "Östergötland" => ["#larm_ovriga_landet"],
    "Jönköpings län" => ["#larm_ovriga_landet"],
    "Kronoberg" => ["#larm_ovriga_landet"],
    "Kalmar län" => ["#larm_ovriga_landet"],
    "Gotland" => ["#larm_ovriga_landet"],
    "Blekinge" => ["#larm_ovriga_landet"],
    "Skåne" => ["#larm_ovriga_landet"],
    "Halland" => ["#larm_ovriga_landet"],
    "Västra Götaland" => ["#larm_ovriga_landet"],
    "Värmland" => ["#larm_ovriga_landet"],
    "Örebro län" => ["#larm_orebro"],
    "Västmanland" => ["#larm_vastmanland"],
    "Dalarna" => ["#larm_dalarna"],
    "Gävleborg" => ["#larm_gavleborg"],
    "Västernorrland" => ["#larm_vasternorrland", "#allehanda-larm", "#st-larm"],
    "Jämtland" => ["#larm_jamtland"],
    "Västerbotten" => ["#larm_ovriga_landet"],
    "Norrbotten" => ["#larm_ovriga_landet"],
    "#robot_trafikinfo" => ["#robot_trafikinfo"],
    "#robot_farjeinfo" => ["#robot_farjeinfo"]
    }

    CHANNEL2 = {
    "alla län" => ["#robottest"],
    "Stockholms län" => ["#robottest"],
    "Uppsala län" => ["#robottest"],
    "Södermanland" => ["#robottest"],
    "Östergötland" => ["#robottest"],
    "Jönköpings län" => ["#robottest"],
    "Kronoberg" => ["#robottest"],
    "Kalmar län" => ["#robottest"],
    "Gotland" => ["#robottest"],
    "Blekinge" => ["#robottest"],
    "Skåne" => ["#robottest"],
    "Halland" => ["#robottest"],
    "Västra Götaland" => ["#robottest"],
    "Värmland" => ["#robottest"],
    "Örebro län" => ["#robottest"],
    "Västmanland" => ["#robottest"],
    "Dalarna" => ["#robottest"],
    "Gävleborg" => ["#robottest"],
    "Västernorrland" => ["#robottest"],
    "Jämtland" => ["#robottest"],
    "Västerbotten" => ["#robottest"],
    "Norrbotten" => ["#robottest"],
    "#robot_trafikinfo" => ["#robot_trafikinfo"]
    }

    LANSKANAL = {
    "Stockholms län" => "#larm_stockholm",
    "Uppsala län" => "#larm_ovriga_landet",
    "Södermanlands län" => "#larm_ovriga_landet",
    "Östergötlands län" => "#larm_ovriga_landet",
    "Jönköpings län" => "#larm_ovriga_landet",
    "Kronobergs län" => "#larm_ovriga_landet",
    "Kalmar län" => "#larm_ovriga_landet",
    "Gotlands län" => "#larm_ovriga_landet",
    "Blekinge län" => "#larm_ovriga_landet",
    "Skåne län" => "#larm_ovriga_landet",
    "Hallands län" => "#larm_ovriga_landet",
    "Västra Götalands län" => "#larm_ovriga_landet",
    "Värmlands län" => "#larm_ovriga_landet",
    "Örebro län" => "#larm_orebro",
    "Västmanlands län" => "#larm_vastmanland",
    "Dalarnas län" => "#larm_dalarna",
    "Gävleborgs län" => "#larm_gavleborg",
    "Västernorrlands län" => "#larm_vasternorrland",
    "Jämtlands län" => "#larm_jamtland",
    "Västerbottens län" => "#larm_ovriga_landet",
    "Norrbottens län" => "#larm_ovriga_landet"
    }


    LANSKANAL2 = {
    "Stockholms län" => "#robottest",
    "Uppsala län" => "#robottest",
    "Södermanlands län" => "#robottest",
    "Östergötlands län" => "#robottest",
    "Jönköpings län" => "#robottest",
    "Kronobergs län" => "#robottest",
    "Kalmar län" => "#robottest",
    "Gotlands län" => "#robottest",
    "Blekinge län" => "#robottest",
    "Skåne län" => "#robottest",
    "Hallands län" => "#robottest",
    "Västra Götalands län" => "#robottest",
    "Värmlands län" => "#robottest",
    "Örebro län" => "#robottest",
    "Västmanlands län" => "#robottest",
    "Dalarnas län" => "#robottest",
    "Gävleborgs län" => "#robottest",
    "Västernorrlands län" => "#robottest",
    "Jämtlands län" => "#robottest",
    "Västerbottens län" => "#robottest",
    "Norrbottens län" => "#robottest"
  }

    ENETT = {
        "begränsad" => "att det råder b",
        "dieselutsläpp" => "ett d",
        "i" => "att i",
        "rådjur" => "ett r",
        "glas" => "att det ligger g",
        "vid" => "att v",
        "lastbil" => "en l",
        "däcksrester" => "att det på vägen finns d",
        "utsläpp" => "ett u",
        "död" => "en d",
        "personbil" => "en p",
        "motorcykel" => "en m",
        "singelolycka" => "en s",
        "arbete" => "ett a",
        "byte" => "ett b",
        "två" => "att t",
        "tre" => "att t",
        "fyra" => "att f",
        "fem" => "att f",
        "sex" => "att s",
        "sju" => "att s",
        "åtta" => "att å",
        "nio" => "att n",
        "tio" => "att t",
        "trafiken" => "att t",
        "älg" => "en ä",
        "risk" => "en r",
        "slitbana" => "en s",
        "flertalet" => "att f",
        "nedfallet" => "ett n",
        "påkört" => "ett p",
        "påkörd" => "en p",
        "nedfallna" => "ett antal n",
        "träskiva" => "en t",
        "buss" => "en b",
        "dött" => "ett d",
        "bil" => "en b",
        "trafikolycka" => "en t",
        "traktordäck" => "att t",
        "blomkruka" => "en b",
        "tankbil" => "en t",
        "det" => "att d",
        "kor" => "att k",
        "plåtbit" => "en p",
        "stort" => "ett s",
        "häst" => "en h",
        "Älgar" => "ä",
        "tappad" => "en t"
    }

end
