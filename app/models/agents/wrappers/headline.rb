module Agents::WRAPPERS::Headline

  HEADER = {
    "Vattenläcka" => "Vattenläcka ",
    "Ombyggnadsarbete" => "Ombyggnadsarbete  ",
    "Läcksökning" => "Larm om vattenläcka ",
    "Driftstörning" => "Driftstörning "
  }

  CONTEXT = {
   "Vattenläcka" => "Läckan gör att påverkade hushåll kan vara utan vatten eller uppleva sämre tryck i kranarna.",
   "Ombyggnadsarbete" => "",
   "Läcksökning" => "Berörda hushåll kan uppleva sämre tryck i kranar eller till och med bli utan vatten under en kortare period.",
   "Driftstörning" => "" 
  }

  ENETT = {
    "Vattenläcka" => "MIVA rapporterar att man jobbar med att åtgärda en vättenläcka vid",
    "Ombyggnadsarbete" => "MIVA genomför nu ett planerat ombyggnadsarbete vid",
    "Läcksökning" => "MIVA söker efter en vattenläcka vid",
    "Driftstörning" => "MIVA rapporterar om en driftstörning"
  }

end