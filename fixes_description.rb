def fix_description(description)
  description.gsub(
    /Acadamy/          , "Academy").gsub(
    /accomodate/       , "accommodate").gsub(
    /accomodation/     , "accommodation").gsub(
    /accordnace/       , "accordance").gsub(
    /additiosn/        , "additions").gsub(
    /addtions/         , "addi1tions").gsub(
    /contioning/       , "conditioning").gsub(
    /Alerations/       , "Alterations").gsub(
    /alteratin/        , "alteration").gsub(
    /Alterating/       , "Altering").gsub(
    /alteratiosn/      , "alterations").gsub(
    /alterion/         , "alteration").gsub(
    /ancilliary/       , "ancillary").gsub(
    /ancillory/        , "ancillary").gsub(
    /adouble/          , "a double").gsub(
    /and and/          , "and").gsub(
    /cratt/            , "craft").gsub(
    /assciated/        , "associated").gsub(
    /assiciated/       , "associated").gsub(
    /assocation/       , "association").gsub(
    /assocoated/       , "associated").gsub(
    /Buildinga/        , "Building").gsub(
    /buildng/          , "building").gsub(
    /builidng/         , "building").gsub(
    /Catergory/        , "Category").gsub(
    /consdiered/       , "considered").gsub(
    /consrtruct/       , "construct").gsub(
    /Consstruction/    , "Construction").gsub(
    /construciton/     , "construction").gsub(
    /Construciton/     , "Construction").gsub(
    /constructa/       , "construct").gsub(
    /constuct/         , "construct").gsub(
    /Constuction/      , "Construction").gsub(
    /contruct/         , "construct").gsub(
    /Contruction/      , "Construction").gsub(
    /creaed/           , "created").gsub(
    /ddouble/          , "double").gsub(
    /demolititon/      , "demolition").gsub(
    /Demoliton/        , "Demolition").gsub(
    /Developmet/       , "Development").gsub(
    /Develpment/       , "Development").gsub(
    /dewllings/        , "dwellings").gsub(
    /diametre/         , "diameter").gsub(
    /doduble/          , "double").gsub(
    /dtorey/           , "storey").gsub(
    /dweling/          , "dwelling").gsub(
    /dwelings/         , "dwellings").gsub(
    /dwelligs/         , "dwellings").gsub(
    /dwellilng/        , "dwelling").gsub(
    /dwellilngs/       , "dwellings").gsub(
    /t rear/           , " to rear").gsub(
    /dwellins/         , "dwellings").gsub(
    /dwellling/        , "dwellings").gsub(
    /dwelllings/       , "dwellings").gsub(
    /dwllings/         , "dwellings").gsub(
    /eixisting/        , "existing").gsub(
    /exisiting/        , "existing").gsub(
    /exisitng/         , "existing").gsub(
    /existinf/         , "existing").gsub(
    /existng/          , "existing").gsub(
    /extention/        , "extension").gsub(
    /Extention/        , "Extension").gsub(
    /facilties/        , "facilities").gsub(
    /foru/             , "for").gsub(
    / fo the/          , " of the").gsub(
    /fourty/           , "forty").gsub(
    /t the/            , "the").gsub(
    /hte/              , "the").gsub(
    /includion/        , "inclusion").gsub(
    /indentification/  , "identification").gsub(
    /instull/          , "install").gsub(
    /levls/            , "levels").gsub(
    /masonary/         , "masonry").gsub(
    /songle/           , "single").gsub(
    /ninteen/          , "nineteen").gsub(
    /nto/              , "onto").gsub(
    /ocnstruct/        , "construct").gsub(
    /of7/              , "off").gsub(
    /ot the/           , " on the").gsub(
    /Parial/           , "Partial").gsub(
    /pavillion/        , "pavilion").gsub(
    /plazza/           , "plaza").gsub(
    /pourpose/         , "purpose").gsub(
    /p remises/        , "premises").gsub(
    /reconfiguraton/   , "reconfiguration").gsub(
    /refusbishment/    , "refurbishment").gsub(
    /Rehersal/         , "Rehearsal").gsub(
    /requirment/       , "requirement").gsub(
    /requirments/      , "requirements").gsub(
    /requriements/     , "requirements").gsub(
    /rerar/            , "rear").gsub(
    /residental/       , "residential").gsub(
    /residnece/        , "residence").gsub(
    /Resturant/        , "Restaurant").gsub(
    /spac/             , "space").gsub(
    /rrear/            , "rear").gsub(
    /shoop/            , "shop").gsub(
    /signle/           , "single").gsub(
    /singley/          , "single").gsub(
    /sotrey/           , "storey").gsub(
    /sq mts/           , " sqm").gsub(
    /storet/           , "storey").gsub(
    /strorey/          , "storey").gsub(
    /Subdiviaion/      , "Subdivision").gsub(
    /Subdivison/       , "Subdivision").gsub(
    /tha/              , "the").gsub(
    /thrity/           , "thirty").gsub(
    /t the rear/       , " to the rear").gsub(
    /verandha/         , "verandah") unless description.nil?
end
