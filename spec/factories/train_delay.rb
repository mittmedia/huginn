FactoryGirl.define do
    factory :train_delay, class:Hash do
      defaults = {
        :LastUpdateDateTime => "2016-07-07T09:52:33", 
        :StartDateTime => "2016-08-24T07:17:00",
        :sentence => "Förseningar kan förekomma mellan Älvsjö - Stockholm Södra på grund av arbeten med Citybanan måndag till natt mot fredag mellan klockan 00.00 - 05.00.\n\nDet påverkar SL pendeltåg på sträckorna Södertälje - Märsta/Arlanda C/Uppsala samt Nynäshamn - Bålsta samt fjärrtåg mellan Stockholm C - Uppsala, i båda riktningar.",
        :location => [[59.5204849532,17.8992338732],[57.8603598849,14.1282336593],[61.3050265372,17.1111503736],[62.5241547757,15.6099308778],[63.3127059485,18.8901705831],[62.7500039077,15.4176180654],[65.4957351163,19.3040155265],[55.6002314035,12.7001284379]]
      }
      initialize_with{ defaults.merge(attributes) }
    end
  end 