module Agents::WRAPPERS::Headline

  HEADER = {
    "Vattenläcka" => "Vattenläcka ",
    "Ombyggnadsarbete" => "Vattenledningar byggs om ",
    "Läcksökning" => "Larm om vattenläcka ",
    "Driftstörning" => "Störning i vattentillgången "
  },

  CONTEXT = {
   "Vattenläcka" => "Läckan gör att påverkade hushåll kan vara utan vatten eller uppleva sämre tryck i kranarna.",
   "Ombyggnadsarbete" => "",
   "Läcksökning" => "Berörda hushåll kan uppleva sämre tryck i kranar eller till och med bli utan vatten under en kortare period.",
   "Driftstörning" => "" 
  }

  ENETT = {
    "Vattenläcka" => "MIVA rapporterar att man jobbar med att åtgärda en vattenläcka vid",
    "Ombyggnadsarbete" => "MIVA genomför nu ett planerat ombyggnadsarbete vid",
    "Läcksökning" => "MIVA söker efter en vattenläcka vid",
    "Driftstörning" => "MIVA rapporterar om en driftstörning som kan påverka vattentillgången vid"  
  }

  CHANNELS = {
    "Deskarna" => ["#robottest", "#plus-och-iuteamet"]
  }

end