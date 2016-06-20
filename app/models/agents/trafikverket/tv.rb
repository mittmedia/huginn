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
        25 => "Norrbotten"
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
        "blackIce" => :asfalt
    }
# =begin
    RUBRIKER = {
        PRIONIV[4] => {
          :belagg => "Stora störningar i trafiken på grund av vägarbete",
          :djurpv => "Djur på vägen orsakade störningar i trafiken",
          :fordonshaveri => "Trasigt fordon skapade störningar i trafiken",
          :farja => "Stora störningar i färjeförbindelsen",
          :ickefung => "Trafikverket varnar – stora trafikstörningar",
          :langsamtr => "Just nu: långa köer i trafiken",
          :lgf => "Långsamt fordon på vägen kan störa trafiken",
          :olycka => "Olycka orsakar störningar i trafiken",
          :sprangarb => "Störningar i trafiken på grund av sprängarbeten",
          :stortevent => "Evenemang skapar stora trafikstörningar",
          :underhall => "Underhållsarbete skapar stora trafikstörningar",
          :vagarb => "Vägarbete skapar stora trafikstörningar",
          :avstangdvag => "Passage avstängd – orsakar trafikstörningar",
          :vagskada => "Skadat vägparti skapar störningar i trafiken",
          :olja => "Olja på vägen skapar störningar för trafiken",
          :oversv => "Översvämning skapar problem i trafiken",
          :oskyddat => "Just nu: område ännu inte avspärrat efter olycka",
          :omledning => "Stora störningar på vägarna – trafiken leds om",
          :farapavag => "Föremål på vägbanan – Trafikverket varnar trafikanter",
          :hinderpavag => "Hinder på vägbanan – Trafikverket varnar trafikanter",
          :brinnande => "Brinnande fordon på vägen – Trafikverket varnar trafikanter",
          :koer => "Köer på vägen – Trafikverket varnar trafikanter",
          :bro => "Broöppning skapar tillfälligt stopp i trafiken",
          :foremal => "Föremål på vägen är fara för trafikanter",
          :filer => "Körfält avstängda – skapar stora störningar i trafiken",
          :diverse => "Störningar i trafiken – Trafikverket varnar",
          :dubbelriktad => "Trafiken tillfälligt dubbelriktad – varning utfärdad",
          :anvisning => "Trafiken leds om – Trafikverket manar till försiktighet",
          :brand => "Allvarlig brand påverkar trafiken",
          :lastbil => "Lastbilsolycka ger stora trafikstörningar",
          :eftersok => "Jägare söker efter skadat djur",
          :fallnatrad => "Fallna träd skapar problem för trafiken",
          :asfalt => '"Blödande" asfalt stör trafiken'
        },
        PRIONIV[5] => {
          :belagg => "Stora störningar i trafiken på grund av vägarbete",
          :djurpv => "Djur på vägen orsakade störningar i trafiken",
          :fordonshaveri => "Trasigt fordon skapar störningar i trafiken",
          :farja => "Färjeförbindelsen helt ur spel – stora störningar väntas",
          :ickefung => "Trafikverket varnar – mycket stora trafikstörningar",
          :langsamtr => "Just nu: långa köer i trafiken",
          :lgf => "Långsamt fordon på vägen skapar trafikstörningar",
          :olycka => "Olycka orsakar störningar i trafiken",
          :sprangarb => "Sprängarbeten skapar stora trafikstörningar",
          :stortevent => "Evenemang skapar stora störningar i trafiken",
          :underhall => "Underhållsarbete skapar stora störningar i trafiken",
          :vagarb => "Stora trafikstörningar på grund av vägarbete",
          :avstangdvag => "Väg avstängd – ställer till störnignar i trafiken",
          :vagskada => "Vägskada orsakar stora trafikstörningar",
          :olja => "Olja på vägen skapar stora störningar för trafiken",
          :oversv => "Stora problem i trafiken på grund av översvämning",
          :oskyddat => "Just nu: område ännu inte avspärrat efter olycka",
          :omledning => "Stora störningar på vägarna – trafiken leds om",
          :farapavag => "Föremål på vägen – Trafikverket varnar trafikanter",
          :hinderpavag => "Hinder på vagbanan – Trafikverket varnar trafikanter",
          :brinnande => "Brinnande fordon på vägen – Trafikverket varnar trafikanter",
          :koer => "Köer på vägen – Trafikverket varnar trafikanter",
          :bro => "Broöppning skapar tillfälligt stopp i trafiken",
          :foremal => "Föremål på vägen är fara för trafikanter",
          :filer => "Körfält avstängda – skapar stora störningar i trafiken",
          :diverse => "Störningar i trafiken – Trafikverket varnar",
          :dubbelriktad => "Trafiken tillfälligt dubbelriktad – varning utfärdad",
          :anvisning => "Trafiken leds om – Trafikverket manar till försiktighet",
          :brand => "Brand påverkar trafiken",
          :lastbil => "Lastbilsolycka ger stora trafikstörningar",
          :eftersok => "Jägare söker efter skadat djur",
          :fallnatrad => "Fallna träd skapar problem för trafiken",
          :asfalt => '"Blödande" asfalt ger stora störningar i trafiken'
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
        "unprotectedAccidentArea" => "En olycka där man ännu inte har kunnat spärra av vägen",
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
        "blackIce" => '"Blödande" asfalt'

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
    "Västernorrland" => ["#larm_vasternorrland"],
    "Jämtland" => ["#larm_jamtland"],
    "Västerbotten" => ["#larm_ovriga_landet"],
    "Norrbotten" => ["#larm_ovriga_landet"]
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
    "Norrbotten" => ["#robottest"]
    }

    ENETT = {
        "Begränsad" => "att det råder b",
        "Dieselutsläpp" => "ett d",
        "I" => "att i",
        "Rådjur" => "ett r",
        "Glas" => "att det ligger g",
        "En" => "att e",
        "Vid" => "att v",
        "Lastbil" => "en l",
        "Däcksrester" => "att det på vägen finns d",
        "Utsläpp" => "ett u",
        "Död" => "en d",
        "Personbil" => "en p",
        "Motorcykel" => "en m",
        "Singelolycka" => "en s",
        "Arbete" => "ett a",
        "Byte" => "ett b",
        "Två" => "att t",
        "Tre" => "att t",
        "Fyra" => "att f",
        "Fem" => "att f",
        "Sex" => "att s",
        "Sju" => "att s",
        "Åtta" => "att å",
        "Nio" => "att n",
        "Tio" => "att t",
        "Trafiken" => "att t",
        "Älg" => "en ä",
        "Risk" => "en r",
        "Nedfallet" => "ett n",
        "Påkört" => "ett p",
        "Påkörd" => "en p",
        "Nedfallna" => "ett antal n",
        "Träskiva" => "en t",
        "Slitbana" => "en s",
        "Flertalet" => "att f",
        "Buss" => "en b",
        "Dött" => "ett d",
        "Bil" => "en b",
        "Trafikolycka" => "en t",
        "Traktordäck" => "att t",
        "Blomkruka" => "en b",
        "Tankbil" => "en t",
        "Det" => "att d",
        "Kor" => "att k",
        "Plåtbit" => "en p"
    }

end
