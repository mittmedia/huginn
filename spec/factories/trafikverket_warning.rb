FactoryGirl.define do
    factory :trafikverket_warning, class:Hash do
      defaults = {
      	:MessageCodeValue => 4, 
      	:SeverityCode => 5,
      	:VersionTime => "2016-06-10T09:13:33", 
      	:LocationDescriptor => "E6.20 vid Gnistängstunneln i riktning mot Frölunda i Västra Götalands län (O)", 
      	:Message => "Gnistängstunneln, södergående tunnelrör mot Frölunda avstängt. Trafiken överleds.\nMötande trafik i norrgående rör.\n", 
      	:CountyNo => [2, 1], 
      	:Geometry => {"SWEREF99TM" => "POINT (693904.97 6584473.9)", "WGS84" => "POINT (18.4111271 59.35431)"}, 
      	:MessageType => "Färjor", 
      	:ManagedCause => true, 
      	:Id => "111111111111111111111111111",
        :CreationTime => "2016-06-10T09:12:49",
        :StartTime => "2016-06-10T09:11:00"
      }
      initialize_with{ defaults.merge(attributes) }
    end
  end 