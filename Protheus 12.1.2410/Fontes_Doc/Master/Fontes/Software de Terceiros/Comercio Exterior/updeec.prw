#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*/{Protheus.doc} UPD_EEC
      Função para atualização de tabelas do módulo SIGAEEC

   @type  Function
   @author bruno kubagawa
   @since 31/05/2023
   @version version
   @param cRelease, caractere, release do sistema
   @return nenhum
   @example
   (examples)
   @see (links_or_references)
/*/
function UPD_EEC( cRelease )
   local oUpd       := nil
   local cRelFinish := ""

   default cRelease := GetRPORelease()

   cRelFinish := SubSTR(cRelease,Rat(".",cRelease)+1)

   oUpd := AVUpdate01():New()
   oUpd:lSimula := .F.
   oUpd:aChamados := {}
   aAdd(oUpd:aChamados,  {nModulo, {|o| cargaELO(o)}} )
   aAdd(oUpd:aChamados,  {nModulo, {|o| cargaEVN(o)}} ) 
   aAdd(oUpd:aChamados,  {nModulo, {|o| EDadosEEA(o)}} )
   oUpd:cTitulo := "Update para o modulo carga padrão da tabela EEA."

   if existfunc("TELinkDado")
      aAdd(oUpd:aChamados,  {nModulo, {|o| TELinkDado(o)}} )
      oUpd:cTitulo := "Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil."
   endif

   aAdd(oUpd:aChamados,  {nModulo, {|o| cargaEC6(o)}} )
   oUpd:cTitulo := "Verifica a carga inicial da tabela EC6 quando a mesma estiver exclusiva no sistema"

   aAdd(oUpd:aChamados,  {nModulo, {|o| EEDadosEJ0(o)}} )
   aAdd(oUpd:aChamados,  {nModulo, {|o| CargEC6Adt(o)}} )

   oUpd:Init(,.T.) 

   if cRelFinish > "027" .and. EEA->(ColumnPos("EEA_TIPMOD")) > 0
      AtuDoc()
      AtuModeloAPH()
   endif

return nil

static function cargaELO(o)

   if AvFlags("DU-E") .And. !ELO->(DBSeek(xFilial("ELO") + PadR("AD", len(ELO->ELO_COD))))

      o:TableStruct("ELO",{"ELO_COD" ,"ELO_DESC"  },1)
      o:TableData( 'ELO',{ 'AD','ANDORRA'})
      o:TableData( 'ELO',{ 'AE','UNITED ARAB EMIRATES'})
      o:TableData( 'ELO',{ 'AF','AFGHANISTAN'})
      o:TableData( 'ELO',{ 'AG','ANTIGA AND BARBUDA'})
      o:TableData( 'ELO',{ 'AI','ANGUILLA'})
      o:TableData( 'ELO',{ 'AL','ALBANIA'})
      o:TableData( 'ELO',{ 'AM','ARMENIA'})
      o:TableData( 'ELO',{ 'AN','NETHERLANDS ANTILLES'})
      o:TableData( 'ELO',{ 'AO','ANGOLA'})
      o:TableData( 'ELO',{ 'AQ','ANTARCTICA'})
      o:TableData( 'ELO',{ 'AR','ARGENTINA'})
      o:TableData( 'ELO',{ 'AS','AMERICAN SAMOA'})
      o:TableData( 'ELO',{ 'AT','AUSTRIA'})
      o:TableData( 'ELO',{ 'AU','AUSTRALIA'})
      o:TableData( 'ELO',{ 'AW','ARUBA'})
      o:TableData( 'ELO',{ 'AX','ÅLAND ISLANDS'})
      o:TableData( 'ELO',{ 'AZ','AZERBAIJAN'})
      o:TableData( 'ELO',{ 'BA','BOSNIA AND HERZEGOVINA'})
      o:TableData( 'ELO',{ 'BB','BARBADOS'})
      o:TableData( 'ELO',{ 'BD','BANGLADESH'})
      o:TableData( 'ELO',{ 'BE','BELGIUM'})
      o:TableData( 'ELO',{ 'BF','BURKINA FASO'})
      o:TableData( 'ELO',{ 'BG','BULGARIA'})
      o:TableData( 'ELO',{ 'BH','BAHRAIN'})
      o:TableData( 'ELO',{ 'BI','BURUNDI'})
      o:TableData( 'ELO',{ 'BJ','BENIN'})
      o:TableData( 'ELO',{ 'BL','SAINT BARTH'})
      o:TableData( 'ELO',{ 'BM','BERMUDA'})
      o:TableData( 'ELO',{ 'BN','BRUNEI DARUSSALAM'})
      o:TableData( 'ELO',{ 'BO','BOLIVIA'})
      o:TableData( 'ELO',{ 'BQ','BONAIRE, SINT EUSTATIUS AND SABA'})
      o:TableData( 'ELO',{ 'BR','BRAZIL'})
      o:TableData( 'ELO',{ 'BS','BAHAMAS'})
      o:TableData( 'ELO',{ 'BT','BHUTAN'})
      o:TableData( 'ELO',{ 'BV','BOUVET ISLAND'})
      o:TableData( 'ELO',{ 'BW','BOTSWANA'})
      o:TableData( 'ELO',{ 'BY','BELARUS'})
      o:TableData( 'ELO',{ 'BZ','BELIZE'})
      o:TableData( 'ELO',{ 'CA','CANADA'})
      o:TableData( 'ELO',{ 'CC','COCOS {KEELING) ISLANDS'})
      o:TableData( 'ELO',{ 'CD','CONGO, THE DEMOCRATIC REPUBLIC OF THE'})
      o:TableData( 'ELO',{ 'CF','CENTRAL AFRICAN REPUBLIC'})
      o:TableData( 'ELO',{ 'CG','CONGO'})
      o:TableData( 'ELO',{ 'CH','SWITZERLAND'})
      o:TableData( 'ELO',{ 'CI',"CÈTE D'IVOIRE"})
      o:TableData( 'ELO',{ 'CK','COOK ISLANDS'})
      o:TableData( 'ELO',{ 'CL','CHILE'})
      o:TableData( 'ELO',{ 'CM','CAMEROON'})
      o:TableData( 'ELO',{ 'CN','CHINA'})
      o:TableData( 'ELO',{ 'CO','COLOMBIA'})
      o:TableData( 'ELO',{ 'CR','COSTA RICA'})
      o:TableData( 'ELO',{ 'CS','SERBIA AND MONTENEGRO'})
      o:TableData( 'ELO',{ 'CU','CUBA'})
      o:TableData( 'ELO',{ 'CV','CAPE VERDE'})
      o:TableData( 'ELO',{ 'CX','CHRISTMAS ISLAND'})
      o:TableData( 'ELO',{ 'CW','CURAÇAO'})
      o:TableData( 'ELO',{ 'CY','CYPRUS'})
      o:TableData( 'ELO',{ 'CZ','CZECH REPUBLIC'})
      o:TableData( 'ELO',{ 'DE','GERMANY'})
      o:TableData( 'ELO',{ 'DJ','DJIBOUTI'})
      o:TableData( 'ELO',{ 'DK','DENMARK'})
      o:TableData( 'ELO',{ 'DM','DOMINICA'})
      o:TableData( 'ELO',{ 'DO','DOMINICAN REPUBLIC'})
      o:TableData( 'ELO',{ 'DZ','ALGERIA'})
      o:TableData( 'ELO',{ 'EC','ECUADOR'})
      o:TableData( 'ELO',{ 'EE','ESTONIA'})
      o:TableData( 'ELO',{ 'EG','EGYPT'})
      o:TableData( 'ELO',{ 'EH','WESTERN SAHARA'})
      o:TableData( 'ELO',{ 'ER','ERITREA'})
      o:TableData( 'ELO',{ 'ES','SPAIN'})
      o:TableData( 'ELO',{ 'ET','ETHIOPIA'})
      o:TableData( 'ELO',{ 'FI','FINLAND'})
      o:TableData( 'ELO',{ 'FJ','FIJI'})
      o:TableData( 'ELO',{ 'FK','FALKLAND ISLANDS {MALVINAS)'})
      o:TableData( 'ELO',{ 'FM','MICRONESIA, FEDERATED STATES OF'})
      o:TableData( 'ELO',{ 'FO','FAROE ISLANDS'})
      o:TableData( 'ELO',{ 'FR','FRANCE'})
      o:TableData( 'ELO',{ 'GA','GABON'})
      o:TableData( 'ELO',{ 'GB','UNITED KINGDOM'})
      o:TableData( 'ELO',{ 'GD','GRENADA'})
      o:TableData( 'ELO',{ 'GE','GEORGIA'})
      o:TableData( 'ELO',{ 'GF','FRENCH GUIANA'})
      o:TableData( 'ELO',{ 'GG','GUERNSEY'})
      o:TableData( 'ELO',{ 'GH','GHANA'})
      o:TableData( 'ELO',{ 'GI','GIBRALTAR'})
      o:TableData( 'ELO',{ 'GL','GREENLAND'})
      o:TableData( 'ELO',{ 'GM','GAMBIA'})
      o:TableData( 'ELO',{ 'GN','GUINEA'})
      o:TableData( 'ELO',{ 'GP','GUADELOUPE'})
      o:TableData( 'ELO',{ 'GQ','EQUATORIAL GUINEA'})
      o:TableData( 'ELO',{ 'GR','GREECE'})
      o:TableData( 'ELO',{ 'GS','SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS'})
      o:TableData( 'ELO',{ 'GT','GUATEMALA'})
      o:TableData( 'ELO',{ 'GU','GUAM'})
      o:TableData( 'ELO',{ 'GW','GUINEA-BISSAU'})
      o:TableData( 'ELO',{ 'GY','GUYANA'})
      o:TableData( 'ELO',{ 'HK','HONG KONG'})
      o:TableData( 'ELO',{ 'HM','HEARD ISLAND AND MCDONALD ISLANDS'})
      o:TableData( 'ELO',{ 'HN','HONDURAS'})
      o:TableData( 'ELO',{ 'HR','CROATIA'})
      o:TableData( 'ELO',{ 'HT','HAITI'})
      o:TableData( 'ELO',{ 'HU','HUNGARY'})
      o:TableData( 'ELO',{ 'ID','INDONESIA'})
      o:TableData( 'ELO',{ 'IE','IRELAND'})
      o:TableData( 'ELO',{ 'IL','ISRAEL'})
      o:TableData( 'ELO',{ 'IM','ISLE OF MAN'})
      o:TableData( 'ELO',{ 'IN','INDIA'})
      o:TableData( 'ELO',{ 'IO','BRITISH INDIAN OCEAN TERRITORY'})
      o:TableData( 'ELO',{ 'IQ','IRAQ'})
      o:TableData( 'ELO',{ 'IR','IRAN, ISLAMIC REPUBLIC OF'})
      o:TableData( 'ELO',{ 'IS','ICELAND'})
      o:TableData( 'ELO',{ 'IT','ITALY'})
      o:TableData( 'ELO',{ 'JE','JERSEY'})
      o:TableData( 'ELO',{ 'JM','JAMAICA'})
      o:TableData( 'ELO',{ 'JO','JORDAN'})
      o:TableData( 'ELO',{ 'JP','JAPAN'})
      o:TableData( 'ELO',{ 'KE','KENYA'})
      o:TableData( 'ELO',{ 'KG','KYRGYZSTAN'})
      o:TableData( 'ELO',{ 'KH','CAMBODIA'})
      o:TableData( 'ELO',{ 'KI','KIRIBATI'})
      o:TableData( 'ELO',{ 'KM','COMOROS'})
      o:TableData( 'ELO',{ 'KN','SAINT KITTS AND NEVIS'})
      o:TableData( 'ELO',{ 'KP',"KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF"})
      o:TableData( 'ELO',{ 'KR','KOREA, REPUBLIC OF'})
      o:TableData( 'ELO',{ 'KW','KUWAIT'})
      o:TableData( 'ELO',{ 'KY','CAYMAN ISLANDS'})
      o:TableData( 'ELO',{ 'KZ','KAZAKHSTAN'})
      o:TableData( 'ELO',{ 'LA',"LAO PEOPLE'S DEMOCRATIC REPUBLIC"})
      o:TableData( 'ELO',{ 'LB','LEBANON'})
      o:TableData( 'ELO',{ 'LC','SAINT LUCIA'})
      o:TableData( 'ELO',{ 'LI','LIECHTENSTEIN'})
      o:TableData( 'ELO',{ 'LK','SRI LANKA'})
      o:TableData( 'ELO',{ 'LR','LIBERIA'})
      o:TableData( 'ELO',{ 'LS','LESOTHO'})
      o:TableData( 'ELO',{ 'LT','LITHUANIA'})
      o:TableData( 'ELO',{ 'LU','LUXEMBOURG'})
      o:TableData( 'ELO',{ 'LV','LATVIA'})
      o:TableData( 'ELO',{ 'LY','LIBYAN ARAB JAMAHIRIYA'})
      o:TableData( 'ELO',{ 'MA','MOROCCO'})
      o:TableData( 'ELO',{ 'MC','MONACO'})
      o:TableData( 'ELO',{ 'MD','MOLDOVA, REPUBLIC OF'})
      o:TableData( 'ELO',{ 'ME','MONTENEGRO'})
      o:TableData( 'ELO',{ 'MF','SAINT MARTIN'})
      o:TableData( 'ELO',{ 'MG','MADAGASCAR'})
      o:TableData( 'ELO',{ 'MH','MARSHALL ISLANDS'})
      o:TableData( 'ELO',{ 'MK','MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF'})
      o:TableData( 'ELO',{ 'ML','MALI'})
      o:TableData( 'ELO',{ 'MM','MYANMAR'})
      o:TableData( 'ELO',{ 'MN','MONGOLIA'})
      o:TableData( 'ELO',{ 'MO','MACAO'})
      o:TableData( 'ELO',{ 'MP','NORTHERN MARIANA ISLANDS'})
      o:TableData( 'ELO',{ 'MQ','MARTINIQUE'})
      o:TableData( 'ELO',{ 'MR','MAURITANIA'})
      o:TableData( 'ELO',{ 'MS','MONTSERRAT'})
      o:TableData( 'ELO',{ 'MT','MALTA'})
      o:TableData( 'ELO',{ 'MU','MAURITIUS'})
      o:TableData( 'ELO',{ 'MV','MALDIVES'})
      o:TableData( 'ELO',{ 'MW','MALAWI'})
      o:TableData( 'ELO',{ 'MX','MEXICO'})
      o:TableData( 'ELO',{ 'MY','MALAYSIA'})
      o:TableData( 'ELO',{ 'MZ','MOZAMBIQUE'})
      o:TableData( 'ELO',{ 'NA','NAMIBIA'})
      o:TableData( 'ELO',{ 'NC','NEW CALEDONIA'})
      o:TableData( 'ELO',{ 'NE','NIGER'})
      o:TableData( 'ELO',{ 'NF','NORFOLK ISLAND'})
      o:TableData( 'ELO',{ 'NG','NIGERIA'})
      o:TableData( 'ELO',{ 'NI','NICARAGUA'})
      o:TableData( 'ELO',{ 'NL','NETHERLANDS'})
      o:TableData( 'ELO',{ 'NO','NORWAY'})
      o:TableData( 'ELO',{ 'NP','NEPAL'})
      o:TableData( 'ELO',{ 'NR','NAURU'})
      o:TableData( 'ELO',{ 'NU','NIUE'})
      o:TableData( 'ELO',{ 'NZ','NEW ZEALAND'})
      o:TableData( 'ELO',{ 'OM','OMAN'})
      o:TableData( 'ELO',{ 'PA','PANAMA'})
      o:TableData( 'ELO',{ 'PE','PERU'})
      o:TableData( 'ELO',{ 'PF','FRENCH POLYNESIA'})
      o:TableData( 'ELO',{ 'PG','PAPUA NEW GUINEA'})
      o:TableData( 'ELO',{ 'PH','PHILIPPINES'})
      o:TableData( 'ELO',{ 'PK','PAKISTAN'})
      o:TableData( 'ELO',{ 'PL','POLAND'})
      o:TableData( 'ELO',{ 'PM','SAINT PIERRE AND MIQUELON'})
      o:TableData( 'ELO',{ 'PN','PITCAIRN'})
      o:TableData( 'ELO',{ 'PR','PUERTO RICO'})
      o:TableData( 'ELO',{ 'PS','PALESTINE'})
      o:TableData( 'ELO',{ 'PT','PORTUGAL'})
      o:TableData( 'ELO',{ 'PW','PALAU'})
      o:TableData( 'ELO',{ 'PY','PARAGUAY'})
      o:TableData( 'ELO',{ 'QA','QATAR'})
      o:TableData( 'ELO',{ 'RE','R UNION'})
      o:TableData( 'ELO',{ 'RO','ROMANIA'})
      o:TableData( 'ELO',{ 'RS','SERBIA'})
      o:TableData( 'ELO',{ 'RU','RUSSIAN FEDERATION'})
      o:TableData( 'ELO',{ 'RW','RWANDA'})
      o:TableData( 'ELO',{ 'SA','SAUDI ARABIA'})
      o:TableData( 'ELO',{ 'SB','SOLOMON ISLANDS'})
      o:TableData( 'ELO',{ 'SC','SEYCHELLES'})
      o:TableData( 'ELO',{ 'SD','SUDAN'})
      o:TableData( 'ELO',{ 'SE','SWEDEN'})
      o:TableData( 'ELO',{ 'SG','SINGAPORE'})
      o:TableData( 'ELO',{ 'SH','SAINT HELENA'})
      o:TableData( 'ELO',{ 'SI','SLOVENIA'})
      o:TableData( 'ELO',{ 'SJ','SVALBARD AND JAN MAYEN'})
      o:TableData( 'ELO',{ 'SK','SLOVAKIA'})
      o:TableData( 'ELO',{ 'SL','SIERRA LEONE'})
      o:TableData( 'ELO',{ 'SM','SAN MARINO'})
      o:TableData( 'ELO',{ 'SN','SENEGAL'})
      o:TableData( 'ELO',{ 'SO','SOMALIA'})
      o:TableData( 'ELO',{ 'SR','SURINAME'})
      o:TableData( 'ELO',{ 'SS','SOUTH SUDAN'})
      o:TableData( 'ELO',{ 'ST','SAO TOME AND PRINCIPE'})
      o:TableData( 'ELO',{ 'SV','EL SALVADOR'})
      o:TableData( 'ELO',{ 'SX','SINT MAARTEN'})
      o:TableData( 'ELO',{ 'SY','SYRIAN ARAB REPUBLIC'})
      o:TableData( 'ELO',{ 'SZ','SWAZILAND'})
      o:TableData( 'ELO',{ 'TC','TURKS AND CAICOS ISLANDS'})
      o:TableData( 'ELO',{ 'TD','CHAD'})
      o:TableData( 'ELO',{ 'TG','TOGO'})
      o:TableData( 'ELO',{ 'TH','THAILAND'})
      o:TableData( 'ELO',{ 'TJ','TAJIKISTAN'})
      o:TableData( 'ELO',{ 'TK','TOKELAU'})
      o:TableData( 'ELO',{ 'TL','TIMOR-LESTE'})
      o:TableData( 'ELO',{ 'TM','TURKMENISTAN'})
      o:TableData( 'ELO',{ 'TN','TUNISIA'})
      o:TableData( 'ELO',{ 'TO','TONGA'})
      o:TableData( 'ELO',{ 'TR','TURKEY'})
      o:TableData( 'ELO',{ 'TT','TRINIDAD AND TOBAGO'})
      o:TableData( 'ELO',{ 'TV','TUVALU'})
      o:TableData( 'ELO',{ 'TW','TAIWAN, PROVINCE OF CHINA'})
      o:TableData( 'ELO',{ 'TZ','TANZANIA, UNITED REPUBLIC OF'})
      o:TableData( 'ELO',{ 'UA','UKRAINE'})
      o:TableData( 'ELO',{ 'UG','UGANDA'})
      o:TableData( 'ELO',{ 'UM','UNITED STATES MINOR OUTLYING ISLANDS'})
      o:TableData( 'ELO',{ 'US','UNITED STATES'})
      o:TableData( 'ELO',{ 'UY','URUGUAY'})
      o:TableData( 'ELO',{ 'UZ','UZBEKISTAN'})
      o:TableData( 'ELO',{ 'VA','HOLY SEE {VATICAN CITY STATE)'})
      o:TableData( 'ELO',{ 'VC','SAINT VINCENT AND THE GRENADINES'})
      o:TableData( 'ELO',{ 'VE','VENEZUELA'})
      o:TableData( 'ELO',{ 'VG','VIRGIN ISLANDS, BRITISH'})
      o:TableData( 'ELO',{ 'VI','VIRGIN ISLANDS, US'})
      o:TableData( 'ELO',{ 'VN','VIET NAM'})
      o:TableData( 'ELO',{ 'VU','VANUATU'})
      o:TableData( 'ELO',{ 'WF','WALLIS AND FUTUNA'})
      o:TableData( 'ELO',{ 'WS','SAMOA'})
      o:TableData( 'ELO',{ 'XZ','INSTALLATIONS IN INTERNATIONAL WATERS'})
      o:TableData( 'ELO',{ 'YE','YEMEN'})
      o:TableData( 'ELO',{ 'YT','MAYOTTE'})
      o:TableData( 'ELO',{ 'ZA','SOUTH AFRICA'})
      o:TableData( 'ELO',{ 'ZM','ZAMBIA'})
      o:TableData( 'ELO',{ 'ZW','ZIMBABWE'})
      o:TableData( 'ELO',{ 'TF','FRENCH SOUTHERN TERRITORIES'})

   endif

return nil

static function cargaEVN(o)

   if AvFlags("DU-E2") .And. !EVN->(DBSeek(xFilial("EVN") + PadR("1001", len(EVN->EVN_CODIGO)) + PadR("CUS", len(EVN->EVN_GRUPO))))
      o:TableStruct("EVN",{"EVN_CODIGO","EVN_GRUPO","EVN_DESCRI"},1)
      o:TableData( 'EVN',{ '1001'      ,'CUS'      ,'Por conta própria'})
      o:TableData( 'EVN',{ '1002'      ,'CUS'      ,'Por conta e ordem de terceiros'})
      o:TableData( 'EVN',{ '1003'      ,'CUS'      ,'Por operador de remessa postal ou expressa'})
      o:TableData( 'EVN',{ '2001'      ,'AHZ'      ,'DU-E a posteriori'})
      o:TableData( 'EVN',{ '2002'      ,'AHZ'      ,'Embarque antecipado'})
      o:TableData( 'EVN',{ '2003'      ,'AHZ'      ,'Exportação sem saída da mercadoria do país'})
      o:TableData( 'EVN',{ '4001'      ,'TRA'      ,'Meios próprios ou por reboque'})
      o:TableData( 'EVN',{ '4002'      ,'TRA'      ,'Dutos'})
      o:TableData( 'EVN',{ '4003'      ,'TRA'      ,'Linhas de transmissão'})
      o:TableData( 'EVN',{ '4004'      ,'TRA'      ,'Em mãos'})
      o:TableData( 'EVN',{ '3001'      ,'ACG'      ,'Bagagem desacompanhada'})
      o:TableData( 'EVN',{ '3002'      ,'ACG'      ,'Bens de viajante não incluídos no conceito de bagagem'})
      o:TableData( 'EVN',{ '3003'      ,'ACG'      ,'Retorno de mercadoria ao exterior antes do registro da DI'})
      o:TableData( 'EVN',{ '3004'      ,'ACG'      ,'Embarque antecipado'})
      o:TableData( 'EVN',{ '5001'      ,'PRI'      ,'Carga viva'})
      o:TableData( 'EVN',{ '5002'      ,'PRI'      ,'Carga perecível'})
      o:TableData( 'EVN',{ '5003'      ,'PRI'      ,'Carga perigosa'})
      o:TableData( 'EVN',{ '5006'      ,'PRI'      ,'Partes/peças de aeronave'})
   endif

return nil

static function cargaEC6(o)
   local nInc   := 0
   local cAlias := "EC6"
   local nTotal := 0

   if( select(cAlias) == 0, ChkFile(cAlias),nil)

   if Select(cAlias) > 0
      (cAlias)->(DbSetOrder(1))
      If !(cAlias)->(DbSeek(xFilial()))
         If xFilial(cAlias) <> Space(FWSizeFilial()) .And. (cAlias)->(DbSeek(Space(FWSizeFilial())))
            nTotal := (cAlias)->(FCount())
            While (cAlias)->EC6_FILIAL == Space(FWSizeFilial())
               nPos := (cAlias)->(Recno())
               For nInc := 1 to nTotal
                  M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
               Next nInc
               M->EC6_FILIAL := xFilial(cAlias)
               (cAlias)->(RecLock(cAlias, .T.))
               AvReplace("M", cAlias)
               (cAlias)->(MsUnlock())
               (cAlias)->(DbGoTo(nPos))
               (cAlias)->(DbSkip())
            EndDo
         EndIf
      EndIf
   endif

return nil

static function EEDadosEJ0(o)

   if ChkFile("EJ0") .And. ChkFile("EJ1") .And. ChkFile("EJ2")
      o:TableStruct('EJ0',{'EJ0_FILIAL','EJ0_COD','EJ0_DESC'                            ,'EJ0_ENTR','EJ0_CHITEM','EJ0_TIPO','EJ0_CONSLD','EJ0_CHUSLD','EJ0_RE','EJ0_ADICAO','EJ0_CRITER','EJ0_MNTOBX'                                         ,'EJ0_CONDBX'          ,'EJ0_VALID'},1)
      o:TableData("EJ0",{xFilial("EJ0"),"01","Admissão Temporária de Embalagem","SW3",""          ,"E"       ,"2"         ,""          ,"1"     ,"1"         ,""          ,"BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT","                    ","                    "},,.F.) //STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{xFilial("EJ0"),"01","Admissão Temporária de Embalagem","SW5","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.)//STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{xFilial("EJ0"),"01","Admissão Temporária de Embalagem","SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","E","1","EJ3_DI+EJ3_ADICAO+ EJ3_COD_I                                                                                                                                                                            ","1","1","                    ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)//STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{xFilial("EJ0"),"02","Reexportação de embalagem admitida temporariamente","EE8","xFilial('EE8')+#EE8#->EE8_PEDIDO+#EE8#->EE8_SEQUEN+#EE8#->EE8_COD_I                                                                                                                                     ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.)//STR0200 "Reexportação de embalagem admitida temporariamente"
      o:TableData("EJ0",{xFilial("EJ0"),"02","Reexportação de embalagem admitida temporariamente","EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)//STR0200 "Reexportação de embalagem admitida temporariamente"
      o:TableData("EJ0",{xFilial("EJ0"),"03",If( cPaisLoc $ "ANG|PTG", "Exportação temporária de embalagem", "Exportação Temporária de Embalagem" ),"EE8","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.)//STR0201 "Exportação Temporária de Embalagem"
      o:TableData("EJ0",{xFilial("EJ0"),"03",If( cPaisLoc $ "ANG|PTG", "Exportação temporária de embalagem", "Exportação Temporária de Embalagem" ),"EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","E","1","EJ3_PREEMB+EJ3_COD_I                                                                                                                                                                                        ","1","1","                    ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)//STR0201 "Exportação Temporária de Embalagem"
      o:TableData("EJ0",{xFilial("EJ0"),"04","Reimportação de embalagem admitida temporariamente","SW3","xFilial('SW3')+#SW3#->W3_PO_NUM+#SW3#->W3_POSICAO                                                                                                                                                       ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT                                                 ","                    ","                    "},,.F.) //STR0202 "Reimportação de embalagem admitida temporariamente          "
      o:TableData("EJ0",{xFilial("EJ0"),"04","Reimportação de embalagem admitida temporariamente","SW5","                                                                                                                                                                                                        ","S","2","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.) //STR0202 "Reimportação de embalagem admitida temporariamente          "
      o:TableData("EJ0",{xFilial("EJ0"),"04","Reimportação de embalagem admitida temporariamente","SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)//STR0202 "Reimportação de embalagem admitida temporariamente          "

      o:TableStruct('EJ1',{'EJ1_FILIAL','EJ1_CODE','EJ1_ENTR','EJ1_CODS','EJ1_SAIDA'},1)
      o:TableData('EJ1',{xFilial("EJ1"),'01','SW8','02','EE8'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'01','SW8','02','EE9'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'03','EE9','04','SW3'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'03','EE9','04','SW8'},,.F.)

      o:TableStruct('EJ2',{'EJ2_FILIAL','EJ2_CODE','EJ2_ENTR','EJ2_DE'          ,'EJ2_PARA'},1)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_DI_NUM","EJ3_DI"  },,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_DTREG_D","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8",'BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja("#SW8#", "W8_FABLOJ"), EICRetLoja("#SW8#", "W8_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_PSLQUN * #EE8#->EE8_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","IIf( EEC->(FieldPos('EEC_NRODUE')) == 0 .Or. !Empty(#EE9#->EE9_RE), #EE9#->EE9_RE , #EEC#->EEC_NRODUE )                                                                                                  ","EJ3_RE                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","IIf( EEC->(FieldPos('EEC_DTDUE')) > 0 .And. !Empty(#EEC#->EEC_DTDUE), #EEC#->EEC_DTDUE, IIF(Empty(#EE9#->EE9_DTRE),IIF(Empty(#EEC#->EEC_DTEMBA),#EEC#->EEC_DTPROC,#EEC#->EEC_DTEMBA),#EE9#->EE9_DTRE))  ","EJ3_DATA                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","IIf( EEC->(FieldPos('EEC_NRODUE')) == 0 .Or. !Empty(#EE9#->EE9_RE), #EE9#->EE9_RE , #EEC#->EEC_NRODUE )                                                                                                  ","EJ3_RE                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","IIf( EEC->(FieldPos('EEC_DTDUE')) > 0 .And. !Empty(#EEC#->EEC_DTDUE), #EEC#->EEC_DTDUE, IIF(Empty(#EE9#->EE9_DTRE),IIF(Empty(#EEC#->EEC_DTEMBA),#EEC#->EEC_DTPROC,#EEC#->EEC_DTEMBA),#EE9#->EE9_DTRE))          ","EJ3_DATA                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3",'BUSCA_UM(#SW3#->W3_COD_I+#SW3#->W3_FABR +#SW3#->W3_FORN,#SW3#->W3_CC+#SW3#->W3_SI_NUM,EICRetLoja("#SW3#", "W3_FABLOJ"), EICRetLoja("#SW3#", "W3_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_PESOL * #SW3#->W3_QTDE                                                                                                                                                                        ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_DTREG_D                                                                                                                                                                                       ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_DI_NUM                                                                                                                                                                                        ","EJ3_DI                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8",'BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja("#SW8#", "W8_FABLOJ"), EICRetLoja("#SW8#", "W8_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)

   endif

return nil

static function CargEC6Adt(o)

   if !AvFlags("EEC_LOGIX")
      o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_TPTIT"}, 1)
      o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"605"          ,""          ,"1"	         , "RA"      },,.T.)

      o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_DESC"            , "EC6_TPTIT"}, 1)
      o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"606"          ,""          ,"1"	         ,"NOTA CRED. - CLIENTE", "NCC"      },,.F.)

      o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_DESC"            , "EC6_TPTIT"}, 1)
      o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"603"          ,""          ,"1"	         ,"ADIANT. PÓS EMBARQUE", ""      },,.F.)
   endif

return nil

static function EDadosEEA(o)
   local aIdioma    := FWGetSX5( "ID" )
   local cIdiomPort := ""
   local cIdiomIng  := ""
   local cIdiomEsp  := ""
   local cIdiomFra  := ""
   local lPosTipMod := EEA->(ColumnPos("EEA_TIPMOD")) > 0
   local ne         := 0
   local ns         := 0
   local aTableStruct := {}
   local aTableData   := {}
   local nPosCod
   local nPosArq

   cIdiomPort := retIdioma(aIdioma,"PORT. ")
   cIdiomIng := retIdioma(aIdioma,"INGLES")
   cIdiomEsp := retIdioma(aIdioma,"ESP.  ")
   cIdiomFra := retIdioma(aIdioma,"FRANCE")

   aadd(aTableStruct,{"EEA" ,{"EEA_FILIAL"   , "EEA_COD" , "EEA_FASE" , "EEA_TIPDOC" , "EEA_TITULO"                                                      , "EEA_CLADOC"             , "EEA_IDIOMA"                       , "EEA_ARQUIV"    , "EEA_FILTRO" , "EEA_RDMAKE"                                        ,"EEA_CNTLIM" , "EEA_CODMEM" , "EEA_ATIVO"  , "EEA_DOCAUT" , "EEA_DOCBAS" , "EEA_PE"  , "EEA_TABCAP" , "EEA_TABDET" , "EEA_INDICE" , "EEA_CHAVE"  , "EEA_IMPINV" , "EEA_MARCA"     },1})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "01"      , "2"        , "1-Carta"    , "ORDER ACKNOWLEDGMENT"                                            , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "AVGLTT.RPT"    , ""           , "EXECBLOCK('EECPPE01',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "02"      , "2"        , "1-Carta"    , "ORDER CONFIRMATION"                                              , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "PEDRECi.RPT"   , ""           , "EXECBLOCK('EECPPE02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "03"      , "2"        , "1-Carta"    , "COMMERCIAL PROFORM"                                              , "1-Proforma"             , /*"INGLES-INGLES"   */ cIdiomIng   , "PROFING.RPT"   , ""           , "EXECBLOCK('EECPPE05',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "04"      , "3"        , "2-Documento", "SAQUE / CAMBIAL"                                                 , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "SAC00001.RPT"  , ""           , "EXECBLOCK('EECPEM01',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "13"      , "3"        , "2-Documento", "PACKING LIST"                                                    , "3-Packing List"         , /*"INGLES-INGLES"   */ cIdiomIng   , "PAC00002.RPT"  , ""           , "EXECBLOCK('EECPEM10',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "14"      , "3"        , "2-Documento", "PACKING LIST"                                                    , "3-Packing List"         , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "PAC00003.RPT"  , ""           , "EXECBLOCK('EECPEM10',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "16"      , "3"        , "2-Documento", "C.O. ALADI (FIESP)"                                              , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "20"      , "3"        , "1-Carta"    , "RESERVA DE PRAÇA"                                                , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "AVGLTT.RPT"    , ""           , "EXECBLOCK('EECPEM17',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "23"      , "3"        , "2-Documento", "C.O. NORMAL (FIESP)"                                             , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "25"      , "3"        , "2-Documento", "C.O. MERCOSUL (FIESP)"                                           , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "26"      , "3"        , "2-Documento", "MEMORANDO DE EXPORTAÇÃO"                                         , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "MEMEXP.RPT"    , ""           , "EXECBLOCK('EECPEM26',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "28"      , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM28',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "33"      , "3"        , "2-Documento", "SOLICITACAO PARA EMISSAO DE NOTA FISCAL PARA EXPORTACAO"         , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "EMNFEXP.RPT"   , ""           , "EXECBLOCK('EECPEM32',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "35"      , "2"        , "1-Carta"    , "PEDIDO CLIENTE"                                                  , "6-Outros"               , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "PEDREC.RPT"    , ""           , "EXECBLOCK('EECPPE02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "36"      , "2"        , "1-Carta"    , "FACTURA PROFORMA"                                                , "1-Proforma"             , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "PROFESP.RPT"   , ""           , "EXECBLOCK('EECPPE05',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "37"      , "3"        , "2-Documento", "COMMERCIAL INVOICE"                                              , "2-Fatura"               , /*"INGLES-INGLES"   */ cIdiomIng   , "FATING.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "38"      , "3"        , "2-Documento", "FACTURA COMERCIAL"                                               , "2-Fatura"               , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "FATESP.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "39"      , "3"        , "2-Documento", "C.O. BOLIVIA (FIESP)"                                            , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "40"      , "3"        , "2-Documento", "C.O. CHILE (FIESP)"                                              , "4-Certificado de Origem", /*"INGLES-INGLES"   */ cIdiomIng   , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "41"      , "3"        , "2-Documento", "AMOSTRA - INGLES"                                                , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "FATAMI.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "42"      , "3"        , "2-Documento", "AMOSTRA - ESPANHOL"                                              , "6-Outros"               , /*"ESP.  -ESPANHOL" */ cIdiomEsp   , "FATAME.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "50"      , "3"        , "3-Relatorio", "MEMORANDO DE EXPORTAÇÃO"                                         , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "MEMEXP.RPT"    , ""           , "EXECBLOCK('EECPEM26',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "51"      , "3"        , "3-Relatorio", "STATUS DO PROCESSO"                                              , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL01.RPT"     , ""           , "EXECBLOCK('EECPRL01',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "52"      , "2"        , "3-Relatorio", "OPEN ORDERS"                                                     , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "REL02.RPT"     , ""           , "EXECBLOCK('EECPRL02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "53"      , "3"        , "3-Relatorio", "PROGRAMAÇÃO DE EMBARQUES"                                        , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL03.RPT"     , ""           , "EXECBLOCK('EECPRL03',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "54"      , "3"        , "3-Relatorio", "PROCESSOS POR VIA DE TRANSPORTE"                                 , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL04.RPT"     , ""           , "EXECBLOCK('EECPRL04',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "56"      , "3"        , "3-Relatorio", "PROCESSOS POR DATA DE ATRACAÇÃO"                                 , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL06.RPT"     , ""           , "EXECBLOCK('EECPRL06',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "57"      , "3"        , "3-Relatorio", "COMISSÕES PENDENTES"                                             , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL07.RPT"     , ""           , "EXECBLOCK('EECPRL07',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "58"      , "3"        , "3-Relatorio", "SHIPPED ORDERS"                                                  , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "REL08.RPT"     , ""           , "EXECBLOCK('EECPRL08',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "59"      , "3"        , "3-Relatorio", "EXPORT REPORT"                                                   , "6-Outros"               , /*"INGLES-INGLES"   */ cIdiomIng   , "REL09.RPT"     , ""           , "EXECBLOCK('EECPRL09',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "60"      , "3"        , "2-Documento", "CONTROLE DE EMBARQUE"                                            , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL11.RPT"     , ""           , "EXECBLOCK('EECPRL10',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "61"      , "3"        , "3-Relatorio", "DEMONSTRATIVOS DE MERCADORIAS FATURADAS POREM NÃO EMBARCADAS"    , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL12.RPT"     , ""           , "EXECBLOCK('EECPRL12',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "62"      , "2"        , "3-Relatorio", "CARTEIRA DE PEDIDOS"                                             , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL13.RPT"     , ""           , "EXECBLOCK('EECPRL13',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "63"      , "3"        , "3-Relatorio", "RELATÓRIO DE EMBARQUES"                                          , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL14.RPT"     , ""           , "EXECBLOCK('EECPRL14',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "65"      , "3"        , "3-Relatorio", "VARIAÇÃO CAMBIAL"                                                , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL16.RPT"     , ""           , "EXECBLOCK('EECPRL16',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "66"      , "3"        , "3-Relatorio", "INTERNATIONAL RECEIVABLE ACCOUNT STATEMENT"                      , "6-Outros"               , /*"PORT. -PORTUGUES"*/ cIdiomPort  , "REL17.RPT"     , ""           , "EXECBLOCK('EECPRL17',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "67"      , "3"        , "2-Documento", "C.O. NORMAL (CEARA)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "68"      , "3"        , "2-Documento", "C.O. NORMAL (RIO GRANDE DO SUL)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "69"      , "3"        , "2-Documento", "C.O. NORMAL (ASSOCIACAO COMERCIAL DE SANTOS)"                    , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "70"      , "3"        , "2-Documento", "C.O. ALADI (CEARA)"                                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "71"      , "3"        , "2-Documento", "C.O. ALADI (RIO GRANDE DO SUL)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "72"      , "3"        , "2-Documento", "C.O. ALADI (ASSOCIACAO COMERCIAL DE SANTOS)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "73"      , "3"        , "2-Documento", "C.O. MERCOSUL (CEARA)"                                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "74"      , "3"        , "2-Documento", "C.O. MERCOSUL (RIO GRANDE DO SUL)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "75"      , "3"        , "2-Documento", "C.O. MERCOSUL (ASSOCIACAO COMERCIAL DE SANTOS)"                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "76"      , "3"        , "2-Documento", "C.O. BOLIVIA (CEARA)"                                            , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "77"      , "3"        , "2-Documento", "C.O. BOLIVIA (RIO GRANDE DO SUL)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "78"      , "3"        , "2-Documento", "C.O. BOLIVIA (ASSOCIACAO COMERCIAL DE SANTOS)"                   , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "79"      , "3"        , "2-Documento", "C.O. CHILE (CEARA)"                                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "80"      , "3"        , "2-Documento", "C.O. CHILE (RIO GRANDE DO SUL)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "81"      , "3"        , "2-Documento", "C.O. CHILE (ASSOCIACAO COMERCIAL DE SANTOS)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "82"      , "3"        , "3-Relatorio", "CUSTO REALIZADO"                                                 , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL18.RPT"     , ""           , "EXECBLOCK('EECAF155',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "83"      , "3"        , "1-Carta"    , "CARTA REMESSA DE DOCUMENTOS"                                     , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "PEM56.RPT"     , ""           , "EXECBLOCK('EECPEM56',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "84"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 4)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM52I.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "85"      , "3"        , "2-Documento", "FACTURA COMERCIAL (MODELO 4)"                                    , "2-Fatura"                , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM52E.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "86"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 4)"                                   , "2-Fatura"                , /*"FRANCE-FRANCES"  */ cIdiomFra  , "PEM52F.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "87"      , "3"        , "2-Documento", "PACKING LIST (MODELO 3)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM55I.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "88"      , "3"        , "2-Documento", "LISTA DE EMPAQUE (MODELO 4)"                                     , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM55E.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "89"      , "3"        , "2-Documento", "PACKING LIST (MODELO 3)"                                         , "3-Packing List"          , /*"FRANCE-FRANCES"  */ cIdiomFra  , "PEM55F.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "90"      , "3"        , "2-Documento", "SAQUE (MODELO 2)"                                                , "6-Outros"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM57.RPT"     , ""           , "EXECBLOCK('EECPEM57',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "91"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 3)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM51.RPT"     , ""           , "EXECBLOCK('EECPEM51',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "92"      , "3"        , "2-Documento", "PACKING LIST (MODELO 2)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM54.RPT"     , ""           , "EXECBLOCK('EECPEM54',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "93"      , "3"        , "2-Documento", "CERTIFICADO ORIGEM OIC"                                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM58',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "94"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 2)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM50.RPT"     , ""           , "EXECBLOCK('EECPEM50',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "95"      , "2"        , "2-Documento", "PROFORMA INVOICE (MODELO 2)"                                     , "1-Proforma"              , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM49.RPT"     , ""           , "EXECBLOCK('EECPEM49',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "96"      , "3"        , "2-Documento", "C.O. ARABIA"                                                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "COARABIA.RPT"  , ""           , "EXECBLOCK('EECPEM45',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "97"      , "3"        , "2-Documento", "C.O. NORMAL (FIRJAN)"                                            , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "98"      , "3"        , "2-Documento", "C.O. ALADI (FIRJAN)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "99"      , "3"        , "2-Documento", "C.O. MERCOSUL (FIRJAN)"                                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "100"     , "1"        , "3-Relatorio", "RELATÓRIO DE ADIANTAMENTO"                                       , "6-Outros"                , /*"INGLES-INGLES"   */ cIdiomIng  , "REL23.RPT"     , ""           , "EXECBLOCK('EECPRL23',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-100"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIRJAN)"                                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'RJ-B')"              , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-101"   , "3"        , "2-Documento", "C.O. CHILE (FIRJAN)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'RJ-C')"              , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-102"   , "3"        , "2-Documento", "C.O. CHILE (FIEB) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIEB'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-103"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIEB) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIEB'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-104"   , "3"        , "2-Documento", "C.O. CHILE (FIESP) (COM LAYOUT)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIESP'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-105"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIESP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIESP'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-106"   , "3"        , "2-Documento", "C.O. CHILE (FEDERASUL) (COM LAYOUT)"                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FEDERASUL'})"   , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-107"   , "3"        , "2-Documento", "C.O. BOLIVIA (FEDERASUL) (COM LAYOUT)"                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM61.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FEDERASUL'})"   , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-108"   , "3"        , "2-Documento", "C.O. MERCOSUL - APENDICE I AO ANEXO IV (FIESP)"                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM61',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-109"   , "3"        , "2-Documento", "C.O. MERCOSUL - APENDICE I AO ANEXO IV (ASSOC. COM. DE SANTOS)"  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM61',.F.,.F.,{'SANTOS'})"          , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-110"   , "3"        , "2-Documento", "C.O. CHILE (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIEP'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-111"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIEP) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIEP'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-112"   , "3"        , "2-Documento", "C.O. ALADI (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIEP'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-113"   , "3"        , "2-Documento", "C.O. ALADI (FIESP) (COM LAYOUT)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-114"   , "3"        , "2-Documento", "C.O. ALADI (FIEB) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIEB'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-115"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIESP) (COM LAYOUT)"                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-116"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIEP'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-117"   , "3"        , "2-Documento", "C.O. MERCOSUL (FEDERASUL) (COM LAYOUT)"                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FEDERASUL'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-118"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEB) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIEB'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-119"   , "3"        , "2-Documento", "C.O. NORMAL (FIESP) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM20.RPT"     , ""           , "EXECBLOCK('EECPEM35',.F.,.F.,{'LAYOUT'})"          , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-120"   , "3"        , "3-Relatorio", "CONTROLE DE CAMBIAIS"                                            , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL20.RPT"     , ""           , "EXECBLOCK('EECPRL20',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-121"   , "1"        , "3-Relatorio", "CONTRATOS DE CÂMBIO NO PERÍODO"                                  , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL21.RPT"     , ""           , "EXECBLOCK('EECPRL21',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-130"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM70.RPT"     , ""           , "EXECBLOCK('EECPEM70',.F.,.F.,{'FIEP'})"            , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-131"   , "3"        , "2-Documento", "C.O. MERCOSUL - CHILE (FIEP) (COM LAYOUT)"                       , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM71.RPT"     , ""           , "EXECBLOCK('EECPEM71',.F.,.F.,{'C','FIEP'})"        , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-132"   , "3"        , "2-Documento", "C.O. MERCOSUL - BOLIVIA (FIEP) (COM LAYOUT)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM71.RPT"     , ""           , "EXECBLOCK('EECPEM71',.F.,.F.,{'B','FIEP'})"        , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-133"   , "3"        , "2-Documento", "C.O. ALADI (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM72.RPT"     , ""           , "EXECBLOCK('EECPEM72',.F.,.F.,{'FIEP'})"            , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-134"   , "3"        , "2-Documento", "C.O. ACORDO MERCOSUL- COLOMBIA, EQUADOR E VENEZUELA (COM LAYOUT)", "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM73.RPT"     , ""           , "EXECBLOCK('EECPEM73',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-135"   , "3"        , "2-Documento", "C.O. COMUM - FIEP (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM74.RPT"     , ""           , "EXECBLOCK('EECPEM74',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-136"   , "3"        , "2-Documento", "C.O. GSTP (FIEP) (COM LAYOUT)"                                   , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM75.RPT"     , ""           , "EXECBLOCK('EECPEM75',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-137"   , "3"        , "3-Relatorio", "RELATÓRIO DE PRÉ-CALCULO"                                        , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL22.RPT"     , ""           , "U_EECPRL22()"                                      , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-139"   , "1"        , "3-Relatorio", "RELAÇÃO DE DESPESAS NACIONAIS"                                   , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL25.RPT"     , ""           , "EXECBLOCK('EECPRL25',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-140"   , "3"        , "2-Documento", "PACKING LIST (MODELO 4)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ cIdiomIng  , "PEM76.RPT"     , ""           , "EXECBLOCK('EECPEM76',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-138"   , "2"        , "2-Documento", "PRÉ CUSTO"                                                       , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "PC150.RPT"     , ""           , "EECPC150()"                                        , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "R-001"   , "1"        , "3-Relatorio", "EMBALAGENS ESPECIAIS"                                            , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , ""              , ""           , "EXECBLOCK('EASYADM100',.F.,.F.)"                   , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-146"   , "3"        , "2-Documento", "LISTA DE EMPAQUE (MODELO 2)"                                     , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM55E.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , "0"          , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-147"   , "3"        , "2-Documento", "FACTURA COMERCIAL (MODELO 2)"                                    , "2-Fatura"                , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM52E.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , "0"          , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-141"   , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM83',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-142"   , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"                , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM84',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-143"   , "3"        , "2-Documento", "PACKING LIST (MODELO 4)"                                         , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ cIdiomEsp  , "PEM85.RPT"     , ""           , "EXECBLOCK('EECPEM85',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "3-RELATORIO" , "1"    , "3-Relatorio", "TABELA DE PREÇOS"                                                , "6-Outros"                , /*"PORT. -PORTUGUES"*/ cIdiomPort , "REL24.RPT"     , ""           , "EXECBLOCK('EECPRL24',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
   aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "F-001"   , "3"        , "2-Documento", "CERTIFICADO DE ORIGEM - FIERGS"                                  , "4-Certificado de origem" , /*"PORT. -PORTUGUES"*/ cIdiomPort , ""              , ""           , "AE108FIERGS()"                                     , ""           , ""           , "2"          , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})

   for ns:=1 to len(aTableStruct)
      if aTableStruct[ns][1] == "EEA" .and. lPosTipMod
         aadd(aTableStruct[ns][2],"EEA_TIPMOD")
      endif
      //                tabelas        -     campos        -      indice
      o:TableStruct(aTableStruct[ns][1],aTableStruct[ns][2],aTableStruct[ns][3])
   next

   If ValType(aTableStruct[1][2]) == "A"
      nPosCod := aScan(aTableStruct[1][2],{ |x| x == "EEA_COD" })
      nPosArq := aScan(aTableStruct[1][2],{ |x| x == "EEA_ARQUIV" })
   EndIf

   for ne := 1 to len(aTableData)
      aadd(aTableData[ne][2], if( aTableData[ne][1] == "EEA" .and. lPosTipMod .And. (aTableData[ne][2][nPosCod] == "37" .Or. "AVGLTT" $ aTableData[ne][2][nPosArq]), "1", "2"))
      //             tabela        ,   dados         ,   nil           ,   atualiza ?
      o:TableData(aTableData[ne][1],aTableData[ne][2],aTableData[ne][3],aTableData[ne][4])
   next

   o:TableStruct("EEA",{"EEA_FILIAL"   , "EEA_COD" , "EEA_TIPDOC" , "EEA_IDIOMA" },1)
   o:DelTableData('EEA'  ,{xFilial('EEA') , "14"    , "2-Documento" , "ESP."   })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "60"    , "2-Documento" , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-130" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-131" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-132" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-133" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-134" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-135" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-136" , "2-Documento" , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-137" , "3-Relatorio" , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "100"   , "3"           , "INGLES" })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-138" , "2"           , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-139" , "3"           , "PORT."  })
   o:DelTableData('EEA'  ,{xFilial('EEA') , "A-140" , "2"           , "INGLES" })

return nil

static function retIdioma(aIdioma,cChave)
   Local cRet := ""
   Local nPos := 0

   if ( nPos :=  ascan( aIdioma, {|x| x[3] == AVKEY( cChave, "X5_CHAVE" ) }) ) > 0
      cRet := aIdioma[nPos][3] + "-" + aIdioma[nPos][4]
   endif

return cRet

static function AtuDoc()
   Local cQryUpd
   Local cFilSYA := xFilial("SY0")
   Local cFilEEA := xFilial("EEA")
   Local dDataLimite := MonthSub(dDataBase,6)
   Local cTableEEA := RetSqlName("EEA")
   Local cTableSY0 := RetSqlName("SY0")
   Local cListArq := "(", cListNotIn := "("
   Local i:=0
   Local aListArq := {}
   Local cQryEEA


   aadd(aListArq,'34')
   aadd(aListArq,'10')
   aadd(aListArq,'17')
   aadd(aListArq,'7')
   aadd(aListArq,'19')
   aadd(aListArq,'22')
   aadd(aListArq,'21')
   aadd(aListArq,'55')
   aadd(aListArq,'18')
   aadd(aListArq,'15')
   aadd(aListArq,'6')
   aadd(aListArq,'27')
   aadd(aListArq,'11')
   aadd(aListArq,'9')
   aadd(aListArq,'8')
   aadd(aListArq,'4')
   aadd(aListArq,'33')
   aadd(aListArq,'30')
   aadd(aListArq,'29')
   aadd(aListArq,'93')
   aadd(aListArq,'F-001')
   aadd(aListArq,'12')
   aadd(aListArq,'31')
   aadd(aListArq,'32')
   aadd(aListArq,'68')
   aadd(aListArq,'97')
   aadd(aListArq,'A-119')
   aadd(aListArq,'23')
   aadd(aListArq,'67')
   aadd(aListArq,'69')
   aadd(aListArq,'74')
   aadd(aListArq,'99')
   aadd(aListArq,'A-115')
   aadd(aListArq,'25')
   aadd(aListArq,'A-116')
   aadd(aListArq,'A-130')
   aadd(aListArq,'A-118')
   aadd(aListArq,'A-117')
   aadd(aListArq,'73')
   aadd(aListArq,'75')
   aadd(aListArq,'A-131')
   aadd(aListArq,'A-132')
   aadd(aListArq,'A-108')
   aadd(aListArq,'A-109')
   aadd(aListArq,'A-136')
   aadd(aListArq,'A-135')
   aadd(aListArq,'80')
   aadd(aListArq,'A-101')
   aadd(aListArq,'A-104')
   aadd(aListArq,'40')
   aadd(aListArq,'A-110')
   aadd(aListArq,'A-102')
   aadd(aListArq,'A-106')
   aadd(aListArq,'79')
   aadd(aListArq,'81')
   aadd(aListArq,'77')
   aadd(aListArq,'A-100')
   aadd(aListArq,'A-105')
   aadd(aListArq,'39')
   aadd(aListArq,'A-111')
   aadd(aListArq,'A-103')
   aadd(aListArq,'A-107')
   aadd(aListArq,'76')
   aadd(aListArq,'78')
   aadd(aListArq,'96')
   aadd(aListArq,'71')
   aadd(aListArq,'98')
   aadd(aListArq,'A-113')
   aadd(aListArq,'16')
   aadd(aListArq,'A-112')
   aadd(aListArq,'A-133')
   aadd(aListArq,'A-114')
   aadd(aListArq,'70')
   aadd(aListArq,'72')
   aadd(aListArq,'A-134')
   aadd(aListArq,'24')
   aadd(aListArq,'5')

   //******************************************************************************************************
   //*
   //*                       Atenção não inverter a ordem da execução dessas operações
   //*  1o. Desativa os registros tipo Fax desde que tenha outro com mesmo código do tipo Carta
   //*  2O. Desativa os documentos não utilizados a mais de 6 meses respeitando a lista
   //*  3O. Atualiza os campos modelo padrao, modelo customizado e tipo modelo padrão conforme critérios no jira
   //******************************************************************************************************


   //1o. Desativa os registros tipo Fax desde que tenha outro com mesmo código do tipo Carta
   // script validado nos três bancos pelo query analyzer da Totvs
   cQryEEA := "SELECT EEA1.EEA_COD,EEA1.EEA_TIPDOC,EEA1.R_E_C_N_O_ FROM " + cTableEEA + " EEA1 WHERE EEA1.EEA_TIPDOC = '1-Fax' "
   cQryEEA += " AND EEA1.EEA_COD  = (SELECT EEA2.EEA_COD FROM " + cTableEEA + " EEA2 WHERE EEA2.EEA_COD=EEA1.EEA_COD AND EEA2.EEA_TIPDOC = '1-Carta' and D_E_L_E_T_ = ' ' and EEA1.EEA_FILIAL = EEA2.EEA_FILIAL) "
   cQryEEA += " AND EEA1.EEA_ATIVO <>'2' AND EEA1.D_E_L_E_T_ = ' ' "
   TcQuery cQryEEA Alias "TMPEEA" New

   TMPEEA->(DBGoTop())
   EEA->(DbSetOrder(1))
   While TMPEEA->(!Eof())
      IF EEA->(DBSEEK(cFilEEA + TMPEEA->EEA_COD + TMPEEA->EEA_TIPDOC))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_ATIVO := '2'
         EEA->(MsUnlock())
      EndIf
      TMPEEA->(DBSkip())
   Enddo

   TMPEEA->(DBCloseArea())

   //2o. Desativa os documentos não utilizados a mais de 6 meses respeitando a lista
   for i:=1 to len(aListArq)
      cListArq += "'" + aListArq[i] + "',"
   next

   cListArq := substr(cListArq,1,len(cListArq)-1)
   cListArq += ")"

   cQryEEA:= "SELECT Y0_CODRPT FROM " + cTableSY0
   cQryEEA += " WHERE D_E_L_E_T_ = ' ' AND Y0_FILIAL = '" + cFilSYA + "' AND Y0_DATA <= '" + dtos(dDataLimite) + "'"
   cQryEEA += " AND Y0_CODRPT IN" + cListArq
   cQryEEA:= ChangeQuery(cQryEEA)
   TcQuery cQryEEA Alias "TMPSY0" New
   TMPSY0->(DBGoTop())

   While TMPSY0->(!Eof())
      IF EEA->(DBSEEK(cFilSYA+TMPSY0->Y0_CODRPT))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_ATIVO := '2'
         EEA->(MsUnlock())
      EndIf
      TMPSY0->(DBSkip())
   EndDO
   TMPSY0->(DBCloseArea())

   cQryEEA := "SELECT DISTINCT Y0_CODRPT FROM " + cTableSY0 + " WHERE D_E_L_E_T_ = ' ' AND Y0_FILIAL = '" + cFilSYA + "'"
   cQryEEA:= ChangeQuery(cQryEEA)
   TcQuery cQryEEA Alias "TMPNOTIN" New
   TMPNOTIN->(DBGoTop())
   While TMPNOTIN->(!Eof())
      cListNotIn += "'" + RTRIM(TMPNOTIN->Y0_CODRPT) + "',"
      TMPNOTIN->(DBSkip())
   EndDo
   TMPNOTIN->(DBCloseArea())
   cListNotIn := substr(cListNotIn,1,len(cListNotIn)-1)
   cListNotIn += ")"

   if len(cListNotIn) > 1
      cQryUpd := "UPDATE " + cTableEEA + " SET EEA_ATIVO = '2' WHERE EEA_COD IN " + cListArq + " AND EEA_COD NOT IN " + cListNotIn

      if( TCSQLEXEC(cQryUpd) < 0 , MsgAlert("Erro na atualização dos documentos na tabela EEA. Erro: " +  TCSqlError(),"Atenção"), )
   EndIf

   // 3o. Atualiza os campos modelo padrao, modelo customizado e tipo modelo padrão conforme critérios no jira
   // script validado nos três bancos pelo query analyzer da Totvs
   // EEA_MODELO = Modelo padrão
   // EEA_ARQUIV = Modelo customizado
   cQryEEA := "SELECT EEA.EEA_COD, EEA.EEA_TIPDOC FROM " + cTableEEA + " EEA WHERE EEA.EEA_MODELO=' ' AND EEA.EEA_ARQUIV='AVGLTT.RPT' AND EEA.D_E_L_E_T_ = ' ' "

   TcQuery cQryEEA Alias "TMPEEAUPD" New

   TMPEEAUPD->(DBGoTop())

   While TMPEEAUPD->(!Eof())
      IF EEA->(DBSEEK(cFilEEA + TMPEEAUPD->EEA_COD + TMPEEAUPD->EEA_TIPDOC))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_MODELO := 'AVGLTT'
         EEA->EEA_ARQUIV = ''
         EEA->EEA_TIPMOD = '1'
         EEA->EEA_EDICAO = '1'
         EEA->(MsUnlock())
      EndIf
      TMPEEAUPD->(DBSkip())
   Enddo
   TMPEEAUPD->(DBCloseArea())

return nil

static function AtuModeloAPH()
   Local aDocs := {}
   Local nx, nw

   aadd(aDocs,{{"chaveEEA", avkey("37","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","FATING"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})
   aadd(aDocs,{{"chaveEEA", avkey("38","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","FATESP"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})
   aadd(aDocs,{{"chaveEEA", avkey("92","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","PACKING"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})
   aadd(aDocs,{{"chaveEEA", avkey("95","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","PROFING"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""},{"EEA_EDICAO","1"}})

   for nx := 1 to len(aDocs)
      IF EEA->(DBSEEK(xfilial("EEA") + aDocs[nx][1][2] ))
         for nw := 2 to len(aDocs[nx])
            EEA->(RecLock("EEA", .F.))
            EEA->&(aDocs[nx][nw][1]) := aDocs[nx][nw][2]
            EEA->(MsUnlock())
         next
      EndIf
   next

return


/*
Funcao                     : UPDEEC033
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Maurício Frison
Data/Hora   			      : 18/03/2021
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC033(o)
/* Débitos Técnicos Release 12.25.10 (19/03/2025) - 015277 - User Story 1535898: Substituição do RUP e RBE para o release 12.1.2510
    o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
    o:TableData  ("SX3",{"EEA_TIPCUS" ,"08"       })
*/
Return nil
