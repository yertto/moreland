$line_cache = []
def cache(line)
  $line_cache << line
  $line_cache = $line_cache[1..-1] if $line_cache.size > 8
  line
end

def fix_line(line)
  cache _fix_line(line)
end
def _fix_line(line)
  #p line if ENV["DEBUG"]
  case line
# 1003  
  when "MPS/2009/519             Use of Land as a Place of Assembly and Waiver of 154 Bell Street COBURG VIC 3058                     23/02/2010"
       "MPS/2009/519             Use of Land as a Place of Assembly and Waiver of      154 Bell Street COBURG VIC 3058                23/02/2010"
  when "MPS/2009/798             Construction of seven dwellings (four double storey 5 Flannery Court OAK PARK VIC 3046                                18/02/2010"
       "MPS/2009/798             Construction of seven dwellings (four double storey     5 Flannery Court OAK PARK VIC 3046                                18/02/2010"
  when "MPS/2009/850             Development of land for two dwellings (one double- 198 Hilton Street GLENROY VIC 3046                                  1/03/2010"
       "MPS/2009/850             Development of land for two dwellings (one double-      198 Hilton Street GLENROY VIC 3046                             1/03/2010"
  when "MPS/2010/33              Use of the land as an industry (micro brewery) and 130 Barkly Street BRUNSWICK VIC 3056                               11/03/2010"
       "MPS/2010/33              Use of the land as an industry (micro brewery) and      130 Barkly Street BRUNSWICK VIC 3056                          11/03/2010"
  when "MPS/2009/649           Development of land for six double storey dwellings 12 Bellevue Terrace PASCOE VALE VIC 3044                            22/01/2010"
       "MPS/2009/649           Development of land for six double storey dwellings     12 Bellevue Terrace PASCOE VALE VIC 3044                            22/01/2010"
  when "MPS/2009/709             Development of the land for two dwellings (a single 86 Essex Street PASCOE VALE VIC 3044                               27/01/2010"
       "MPS/2009/709             Development of the land for two dwellings (a single     86 Essex Street PASCOE VALE VIC 3044                           27/01/2010"
  when "MPS/2009/798             Construction of seven dwellings (four double storey 5 Flannery Court OAK PARK VIC 3046                                 18/02/2010"
       "MPS/2009/798             Construction of seven dwellings (four double storey     5 Flannery Court OAK PARK VIC 3046                             18/02/2010"
# 100329
  when "MPS/2009/519             Use of Land as a Place of Assembly and Waiver of 154 Bell Street COBURG VIC 3058                       23/02/2010"
       "MPS/2009/519             Use of Land as a Place of Assembly and Waiver of        154 Bell Street COBURG VIC 3058                23/02/2010"
  when "MPS/2009/708             Construction of a double storey dwelling to the rear 67 Moore Street COBURG VIC 3058                   22/02/2010"
       "MPS/2009/708             Construction of a double storey dwelling to the rear    67 Moore Street COBURG VIC 3058                22/02/2010"
  when "MPS/2010/4               Development of land for two dwellings (new double- 43 Loongana Avenue GLENROY VIC 3046                                 2/03/2010"
        "MPS/2010/4               Development of land for two dwellings (new double-      43 Loongana Avenue GLENROY VIC 3046                            2/03/2010"
  when "MPS/2009/774             Part demolition of boundary wall and                 40 Devon Avenue COBURG VIC 3058                                  23/02/2010"
        "MPS/2009/774             Part demolition of boundary wall and                    40 Devon Avenue COBURG VIC 3058                               23/02/2010"
  when "MPS/2010/22              Development of the land for two dwellings              5 Edith Street OAK PARK VIC 3046                         10/03/2010"
       "MPS/2010/22              Development of the land for two dwellings               5 Edith Street OAK PARK VIC 3046                        10/03/2010"
  when "MPS/2009/738             Development of the land to construct three          58 Augustine Terrace GLENROY VIC 3046                       23/02/2010"
       "MPS/2009/738             Development of the land to construct three              58 Augustine Terrace GLENROY VIC 3046                   23/02/2010"
  when "MPS/2009/850             Development of land for two dwellings (one double- 198 Hilton Street GLENROY VIC 3046                                   1/03/2010"
       "MPS/2009/850             Development of land for two dwellings (one double-    198 Hilton Street GLENROY VIC 3046                                1/03/2010"
  when "MPS/2010/33              Use of the land as an industry (micro brewery) and 130 Barkly Street BRUNSWICK VIC 3056                                11/03/2010"
       "MPS/2010/33              Use of the land as an industry (micro brewery) and    130 Barkly Street BRUNSWICK VIC 3056                                11/03/2010"
# ...
  when "MPS/2010/33              Use of the land as an industry (micro brewery) and 130 Barkly Street BRUNSWICK VIC 3056                              11/03/2010"
       "MPS/2010/33              Use of the land as an industry (micro brewery) and     130 Barkly Street BRUNSWICK VIC 3056                          11/03/2010"
  when "MPS/2010/101            Development of land for three dwellings consisting 47 Bindi Street GLENROY VIC 3046                  12/03/2010"
       "MPS/2010/101            Development of land for three dwellings consisting     47 Bindi Street GLENROY VIC 3046              12/03/2010"
  when "MPS/2010/216             Construction of a double storey dwelling to the rear 8 Sunshine Street PASCOE VALE VIC 3044              9/04/2010"
       "MPS/2010/216             Construction of a double storey dwelling to the rear    8 Sunshine Street PASCOE VALE VIC 3044              9/04/2010"
  when "MPS/2010/101             Development of land for three dwellings consisting 47 Bindi Street GLENROY VIC 3046                     12/03/2010"
       "MPS/2010/101             Development of land for three dwellings consisting    47 Bindi Street GLENROY VIC 3046                     12/03/2010"
  when "MPS/2009/771             Development of the land for two dwellings (a single 28 Connell Street GLENROY VIC 3046                9/04/2010"
       "MPS/2009/771             Development of the land for two dwellings (a single    28 Connell Street GLENROY VIC 3046             9/04/2010"
  when "MPS/2009/771             Development of the land for two dwellings (a single 28 Connell Street GLENROY VIC 3046                                 9/04/2010"
       "MPS/2009/771             Development of the land for two dwellings (a single    28 Connell Street GLENROY VIC 3046                              9/04/2010"
  when "MPS/2009/850             Development of land for two dwellings (one double- 198 Hilton Street GLENROY VIC 3046                                    1/03/2010"
       "MPS/2009/850             Development of land for two dwellings (one double-     198 Hilton Street GLENROY VIC 3046                                1/03/2010"
  when "MPS/2009/771             Development of the land for two dwellings (a single 28 Connell Street GLENROY VIC 3046                      9/04/2010"
       "MPS/2009/771             Development of the land for two dwellings (a single    28 Connell Street GLENROY VIC 3046                   9/04/2010"
  when "MPS/2009/303             Development of land for two single storey dwellings 88 Hilda Street GLENROY VIC 3046                       23/04/2010"
       "MPS/2009/303             Development of land for two single storey dwellings    88 Hilda Street GLENROY VIC 3046                    23/04/2010"
  when "MPS/2010/216             Construction of a double storey dwelling to the rear 8 Sunshine Street PASCOE VALE VIC 3044                              9/04/2010"
       "MPS/2010/216             Construction of a double storey dwelling to the rear   8 Sunshine Street PASCOE VALE VIC 3044                            9/04/2010"
  when "MPS/2004/501/A           Use of the land for a Restricted Retail Premises   1359 Sydney Road FAWKNER VIC 3060                                   17/05/2010"
       "MPS/2004/501/A           Use of the land for a Restricted Retail Premises       1359 Sydney Road FAWKNER VIC 3060                               17/05/2010"
  when "MPS/2010/288             Construction of a double storey dwelling to the rear 7 Edgar Street HADFIELD VIC 3046                                  13/05/2010"
       "MPS/2010/288             Construction of a double storey dwelling to the rear    7 Edgar Street HADFIELD VIC 3046                               13/05/2010"
  when "MPS/2009/849             Development of land for two dwellings (a single     112 Brunswick Road BRUNSWICK VIC 3056                            17/05/2010"
       "MPS/2009/849             Development of land for two dwellings (a single         112 Brunswick Road BRUNSWICK VIC 3056                        17/05/2010"
  when "MPS/2009/856            Use and development of the land for two           160 Gaffney Street COBURG VIC 3058                                   9/06/2010"
       "MPS/2009/856            Use and development of the land for two                160 Gaffney Street COBURG VIC 3058                              9/06/2010"
  when "MPS/2004/501/A          Use of the land for a Restricted Retail Premises   1359 Sydney Road FAWKNER VIC 3060                                  17/05/2010"
       "MPS/2004/501/A          Use of the land for a Restricted Retail Premises        1359 Sydney Road FAWKNER VIC 3060                             17/05/2010"
  when "MPS/2009/849            Development of land for two dwellings (a single     112 Brunswick Road BRUNSWICK VIC 3056                            17/05/2010"
       "MPS/2009/849            Development of land for two dwellings (a single         112 Brunswick Road BRUNSWICK VIC 3056                        17/05/2010"
  when "MPS/2009/856            Use and development of the land for two           160 Gaffney Street COBURG VIC 3058                                    9/06/2010"
       "MPS/2009/856            Use and development of the land for two                160 Gaffney Street COBURG VIC 3058                               9/06/2010"
  else
    line
  end
end

def fix_address(address_str)
  case address_str
  when "8S Stockade Avenue COBURG VIC 3058"
       "85 Stockade Avenue COBURG VIC 3058"
  when "6S Stockade Avenue COBURG VIC 3058"
       "65 Stockade Avenue COBURG VIC 3058"
  when "2S Wardens Walk COBURG VIC 3058"
       "25 Wardens Walk COBURG VIC 3058"
  when "13S Wardens Walk COBURG VIC 3058"
       "135 Wardens Walk COBURG VIC 3058"
  else
    address_str
  end
end
