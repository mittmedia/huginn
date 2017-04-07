module Agents::WRAPPERS::POSTREQUESTS
  
  def self.ferry_situations(api_key)
    "<REQUEST>
      <LOGIN authenticationkey='#{api_key}' />
        <QUERY objecttype='Situation' lastmodified='true'>
        <FILTER>
        <OR>
          <ELEMENTMATCH>
            <EQ name='Deviation.MessageType' value='Färjor' />
            <EQ name='Deviation.IconId' value='ferryServiceNotOperating' />
          </ELEMENTMATCH>
          </OR>
        </FILTER>
      </QUERY>
    </REQUEST>"
  end

  def self.ferry_announcements(api_key, id)
    "<REQUEST>
      <LOGIN authenticationkey='#{api_key}' />
      <QUERY objecttype='FerryAnnouncement' lastmodified='true'>
        <FILTER>
          <EQ name ='DeviationId' value='#{id}' />
        </FILTER>
      </QUERY>
    </REQUEST>"
  end

  def self.situations(api_key)
    "<REQUEST>
      <LOGIN authenticationkey='#{api_key}' />
      <QUERY objecttype='Situation'>
      <FILTER>
        <OR>
          <ELEMENTMATCH>
            <EQ name='Deviation.ManagedCause' value='true' />
            <IN name='Deviation.MessageType' value='Trafikmeddelande,Olycka' />
          </ELEMENTMATCH>
          <ELEMENTMATCH>
            <EQ name='Deviation.MessageType' value='Färjor' />
            <EQ name='Deviation.IconId' value='ferryServiceNotOperating' />
          </ELEMENTMATCH>
          <ELEMENTMATCH>
            <EQ name='Deviation.MessageType' value='Restriktion' />
            <EQ name='Deviation.MessageCode' value='Väg avstängd' />
          </ELEMENTMATCH>
        </OR>
      </FILTER>
      </QUERY>
    </REQUEST>"
  end
end 