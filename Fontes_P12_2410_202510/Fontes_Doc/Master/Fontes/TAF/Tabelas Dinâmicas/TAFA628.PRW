#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA628.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA628
Cadastro MVC de Tipos de Arquivo da e-Social 
Tabela 09

@author Alexandre de Lima
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA628()

	Local oBrw := FWmBrowse():New()

	oBrw:SetDescription( STR0001 ) //Instituições Financeiras.
	oBrw:SetAlias( 'T8D')
	oBrw:SetMenuDef( 'TAFA628' )
	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Alexandre de Lima
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()

Return XFUNMnuTAF( "TAFA628" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Alexandre de Lima
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()

	Local oStruT8D as obejct 
	Local oModel   as object

	oStruT8D := FWFormStruct( 1, 'T8D' ) // Cria a estrutura a ser usada no Modelo de Dados
	oModel   := MPFormModel():New('TAFA628',, {|oModel| ValidModel(oModel)},{|oModel| SaveModel(oModel)} )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'MODEL_T8D', /*cOwner*/, oStruT8D)
	oModel:GetModel( 'MODEL_T8D' ):SetPrimaryKey( { 'T8D_FILIAL' , 'T8D_ID' } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Alexandre de Lima
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'TAFA628' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStruT8D	:= FWFormStruct( 2, 'T8D' )// Cria a estrutura a ser usada na View
	Local oView		:= FWFormView():New()

	oView:SetModel( oModel )

	oStruT8D:RemoveField( "T8D_FILIAL" )
	oStruT8D:RemoveField( "T8D_ID" )

	oView:AddField( 'VIEW_T8D', oStruT8D, 'MODEL_T8D' )

	oView:EnableTitleView( 'VIEW_T8D',  STR0001 ) ////Instituições Financeiras.

	oView:CreateHorizontalBox( 'FIELDST8D', 100 )

	oView:SetOwnerView( 'VIEW_T8D', 'FIELDST8D' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@author Alexandre de Lima Santos
@since 09/05/2025
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel as object )

	Local nOperation as  Numeric 
	Local lRetorno   as  Logical
	LocaL cId        as  Logical

	Default oModel := Nil
	
	nOperation := oModel:GetOperation()
	lRetorno   := .T.

	Begin Transaction
	
		
		If nOperation == MODEL_OPERATION_INSERT
			
			cId := TAFAGetId()

			oModel:LoadValue( 'MODEL_T8D', 'T8D_ID', cId )
	
			FwFormCommit(oModel)
				
		ElseIf nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE
		                                                                                      
			FwFormCommit(oModel)
	
		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Alexandre de Lima S.
@Since		15/07/2024
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont(nVerEmp as numeric, nVerAtu as numeric)

	Local aHeader 	as array
	Local aBody   	as array
	Local aRet    	as array

	Default nVerEmp := 0
	Default nVerAtu := 0

	aHeader	:= {}
	aBody   := {}
	aRet    := {}
	nVerAtu := 1033.75

	If (nVerEmp < nVerAtu) .AND. TafAtualizado(.F.)

		aAdd( aHeader, "T8D_FILIAL" )
		aAdd( aHeader, "T8D_ID" )
		aAdd( aHeader, "T8D_CODIGO" )
		aAdd( aHeader, "T8D_CNPJ" )
		aAdd( aHeader, "T8D_DESCRI" )
		aAdd( aHeader, "T8D_VALIDA" )

		aAdd( aBody, { "", "000001","001",	"00 000 000",	"BANCO DO BRASIL S.A."										, "" 								 } )	
		aAdd( aBody, { "", "000002","003",	"04 902 979",	"BANCO DA AMAZONIA S.A."									, "" 								 } )
		aAdd( aBody, { "", "000003","004",	"07 237 373",	"BANCO DO NORDESTE DO BRASIL S.A."							, "" 								 } )
		aAdd( aBody, { "", "000004","012",	"04 866 275",	"BANCO INBURSA S.A."					                	, "" 								 } )
		aAdd( aBody, { "", "000005","014",	"09 274 232",	"STATE STREET BR S.A. BCO COMERCIAL"						, "" 								 } )
		aAdd( aBody, { "", "000006","019",	"09 391 857",	"BANCO AZTECA DO BRASIL S.A."								, "" 								 } )
		aAdd( aBody, { "", "000007","021",	"28 127 603",	"BANESTES S.A. BANCO DO ESTADO DO ESPIRITO SANTO"			, "" 								 } )
		aAdd( aBody, { "", "000008","024",	"10 866 788",	"BANCO DE PERNAMBUCO S.A. - BANDEPE"						, "" 								 } )
		aAdd( aBody, { "", "000009","025",	"03 323 840",	"BANCO ALFA S.A."											, "" 								 } )
		aAdd( aBody, { "", "000010","029",	"33 885 724",	"BANCO ITAÚ CONSIGNADO S.A."								, "" 								 } )
		aAdd( aBody, { "", "000011","031",	"01 540 541",	"BANCO BEG S.A."											, "" 								 } )
		aAdd( aBody, { "", "000012","033",	"90 400 888",	"BANCO SANTANDER (BRASIL) S.A."								, "" 								 } )
		aAdd( aBody, { "", "000013","036",	"06 271 464",	"BANCO BRADESCO BBI S.A."									, "" 								 } )
		aAdd( aBody, { "", "000014","037",	"04 913 711",	"BANCO DO ESTADO DO PARÁ S.A."								, "" 								 } )
		aAdd( aBody, { "", "000015","040",	"03 609 817",	"BANCO CARGILL S.A."										, "" 								 } )
		aAdd( aBody, { "", "000016","041",	"92 702 067",	"BANCO DO ESTADO DO RIO GRANDE DO SUL S.A."					, "" 								 } )
		aAdd( aBody, { "", "000017","044",	"32 254 138",	"BANCO BVA S.A."											, "" 								 } )
		aAdd( aBody, { "", "000018","045",	"33 857 830",	"BANCO OPPORTUNITY S.A."									, "" 								 } )
		aAdd( aBody, { "", "000019","047",	"13 009 717",	"BANCO DO ESTADO DE SERGIPE S.A."							, "" 								 } )
		aAdd( aBody, { "", "000020","062",	"03 012 230",	"HIPERCARD BANCO MÚLTIPLO S.A."								, "" 								 } )
		aAdd( aBody, { "", "000021","063",	"04 184 779",	"BANCO BRADESCARD S.A."         							, "" 								 } )
		aAdd( aBody, { "", "000022","065",	"48 795 256",	"BCO ANDBANK S.A."											, "" 								 } )
		aAdd( aBody, { "", "000023","066",	"02 801 938",	"BANCO MORGAN STANLEY S.A."									, "" 								 } )
		aAdd( aBody, { "", "000024","069",	"61 033 106",	"BCO CREFISA S.A."											, "" 								 } )
		aAdd( aBody, { "", "000025","070",	"00 000 208",	"BRB - BANCO DE BRASILIA S.A."								, "" 								 } )
		aAdd( aBody, { "", "000026","072",	"33 074 683",	"BANCO RURAL MAIS S.A."										, "" 								 } )
		aAdd( aBody, { "", "000027","073",	"06 043 056",	"BB BANCO POPULAR DO BRASIL S.A."							, "" 								 } )
		aAdd( aBody, { "", "000028","074",	"03 017 677",	"BANCO J. SAFRA S.A."										, "" 								 } )
		aAdd( aBody, { "", "000029","075",	"03 532 415",	"BANCO ABN AMRO CLEARING S.A."  							, "" 								 } )
		aAdd( aBody, { "", "000030","076",	"07 656 500",	"BANCO KDB DO BRASIL S.A."									, "" 								 } )
		aAdd( aBody, { "", "000031","077",	"00 416 968",	"BANCO INTER S.A."	  									    , "" 								 } )
		aAdd( aBody, { "", "000032","078",	"34 111 187",	"HAITONG BI DO BRASIL S.A."									, "" 								 } )	
		aAdd( aBody, { "", "000033","079",	"09 516 419",	"PICPAY BANK - BANCO MÚLTIPLO S.A"							, "" 								 } )	
		aAdd( aBody, { "", "000034","081",	"10 264 663",	"BANCOSEGURO S.A."											, "" 								 } )
		aAdd( aBody, { "", "000035","082",	"07 679 404",	"BANCO TOPÁZIO S.A."										, "" 								 } )
		aAdd( aBody, { "", "000036","083",	"10 690 848",	"BANCO DA CHINA BRASIL S.A"									, "" 								 } )
		aAdd( aBody, { "", "000037","096",	"00 997 185",	"BANCO B3 S.A."	    										, "" 								 } )
		aAdd( aBody, { "", "000038","104",	"00 360 305",	"CAIXA ECONOMICA FEDERAL"									, "" 								 } )
		aAdd( aBody, { "", "000039","107",	"15 114 366",	"BANCO BBM S/A"												, "" 								 } )
		aAdd( aBody, { "", "000040","151",	"43 073 394",	"BANCO NOSSA CAIXA S.A."									, "" 								 } )
		aAdd( aBody, { "", "000041","184",	"17 298 092",	"BANCO ITAÚ BBA S.A."										, "" 								 } )
		aAdd( aBody, { "", "000042","204",	"59 438 325",	"BANCO BRADESCO CARTÕES S.A."								, "" 								 } )
		aAdd( aBody, { "", "000043","208",	"30 306 294",	"BANCO BTG PACTUAL S.A."									, "" 								 } )
		aAdd( aBody, { "", "000044","212",	"92 894 922",	"BANCO ORIGINAL S.A."										, "" 								 } )
		aAdd( aBody, { "", "000045","213",	"54 403 563",	"BANCO ARBI S.A."											, "" 								 } )
		aAdd( aBody, { "", "000046","214",	"61 199 881",	"BANCO DIBENS S.A."											, "" 								 } )
		aAdd( aBody, { "", "000047","215",	"61 230 165",	"BANCO COMERCIAL E DE INVESTIMENTO SUDAMERIS S.A."			, "" 								 } )
		aAdd( aBody, { "", "000048","217",	"91 884 981",	"BANCO JOHN DEERE S.A."										, "" 								 } )
		aAdd( aBody, { "", "000049","218",	"71 027 866",	"Banco BS2 S.A."											, "" 								 } )
		aAdd( aBody, { "", "000050","222",	"75 647 891",	"BCO CRÉDIT AGRICOLE BR S.A."								, "" 								 } )
		aAdd( aBody, { "", "000051","224",	"58 616 418",	"BANCO FIBRA S.A."											, "" 								 } )
		aAdd( aBody, { "", "000052","225",	"33 923 111",	"BANCO BRASCAN S.A."										, "" 								 } )
		aAdd( aBody, { "", "000053","229",	"62 136 254",	"BANCO CRUZEIRO DO SUL S.A."								, "" 								 } )	
		aAdd( aBody, { "", "000054","230",	"61 071 387",	"UNICARD BANCO MÚLTIPLO S.A."								, "" 								 } )	
		aAdd( aBody, { "", "000055","233",	"62 421 979",	"Banco Cifra S.A."											, "" 								 } )	
		aAdd( aBody, { "", "000056","237",	"60 746 948",	"BANCO BRADESCO S.A."										, "" 								 } )
		aAdd( aBody, { "", "000057","241",	"31 597 552",	"BANCO CLASSICO S.A."										, "" 								 } )
		aAdd( aBody, { "", "000058","243",	"33 923 798",	"BANCO MASTER S/A"											, "" 								 } )
		aAdd( aBody, { "", "000059","246",	"28 195 667",	"BANCO ABC BRASIL S.A."										, "" 								 } )
		aAdd( aBody, { "", "000060","248",	"33 485 541",	"BANCO BOAVISTA INTERATLANTICO S.A."						, "" 								 } )
		aAdd( aBody, { "", "000061","249",	"61 182 408",	"BANCO INVESTCRED UNIBANCO S.A."							, "" 								 } )
		aAdd( aBody, { "", "000062","250",	"50 585 090",	"BANCO BMG CONSIGNADO S.A."									, "" 								 } )
		aAdd( aBody, { "", "000063","254",	"14 388 334",	"PARANÁ BANCO S.A."											, "" 								 } )
		aAdd( aBody, { "", "000064","263",	"33 349 358",	"BANCO CACIQUE S.A."										, "" 								 } )
		aAdd( aBody, { "", "000065","265",	"33 644 196",	"BANCO FATOR S.A."										    , "" 								 } )
		aAdd( aBody, { "", "000066","266",	"33 132 044",	"BANCO CEDULA S.A."											, "" 								 } )
		aAdd( aBody, { "", "000067","300",	"33 042 151",	"BANCO DE LA NACION ARGENTINA"								, "" 								 } )
		aAdd( aBody, { "", "000068","318",	"61 186 680",	"BANCO BMG S.A."											, "" 								 } )
		aAdd( aBody, { "", "000069","320",	"07 450 604",	"BOC BRASIL"	 											, "" 								 } )
		aAdd( aBody, { "", "000070","341",	"60 701 190",	"ITAÚ UNIBANCO S.A."										, "" 								 } )
		aAdd( aBody, { "", "000071","366",	"61 533 584",	"BANCO SOCIETE GENERALE BRASIL S.A."						, "" 								 } )
		aAdd( aBody, { "", "000072","370",	"61 088 183",	"BCO MIZUHO S.A."											, "" 								 } )
		aAdd( aBody, { "", "000073","376",	"33 172 537",	"BANCO J.P. MORGAN S.A."									, "" 								 } )
		aAdd( aBody, { "", "000074","389",	"17 184 037",	"BANCO MERCANTIL DO BRASIL S.A."							, "" 								 } )
		aAdd( aBody, { "", "000075","394",	"07 207 996",	"Banco Bradesco Financiamentos S.A."						, "" 								 } )
		aAdd( aBody, { "", "000076","399",	"01 701 201",	"KIRTON BANK S.A. - Banco Múltiplo"					        , "" 								 } )
		aAdd( aBody, { "", "000077","409",	"33 700 394",	"UNIBANCO-UNIAO DE BANCOS BRASILEIROS S.A."					, "" 								 } )
		aAdd( aBody, { "", "000078","412",	"15 173 776",	"SOCIAL BANK S/A"		 									, "" 								 } )
		aAdd( aBody, { "", "000079","422",	"58 160 789",	"BANCO SAFRA S.A."										    , "" 								 } )
		aAdd( aBody, { "", "000080","453",	"33 124 959",	"BANCO RURAL S.A."											, "" 								 } )
		aAdd( aBody, { "", "000081","456",	"60 498 557",	"BCO MUFG BRASIL S.A."										, "" 								 } )
		aAdd( aBody, { "", "000082","464",	"60 518 222",	"BANCO SUMITOMO MITSUI BRASILEIRO S.A."						, "" 								 } )
		aAdd( aBody, { "", "000083","473",	"33 466 988",	"BANCO CAIXA GERAL - BRASIL S.A."							, "" 								 } )
		aAdd( aBody, { "", "000084","477",	"33 042 953",	"CITIBANK N.A."												, "" 								 } )
		aAdd( aBody, { "", "000085","479",	"60 394 079",	"BANCO ITAUBANK S.A."										, "" 								 } )
		aAdd( aBody, { "", "000086","487",	"62 331 228",	"DEUTSCHE BANK S.A. - BANCO ALEMAO"							, "" 								 } )
		aAdd( aBody, { "", "000087","488",	"46 518 205",	"JPMORGAN CHASE BANK, NATIONAL ASSOCIATION"					, "" 								 } )
		aAdd( aBody, { "", "000088","492",	"49 336 860",	"ING BANK N.V."												, "" 								 } )
		aAdd( aBody, { "", "000089","494",	"51 938 876",	"BANCO DE LA REPUBLICA ORIENTAL DEL URUGUAY"				, "" 								 } )
		aAdd( aBody, { "", "000090","495",	"44 189 447",	"BANCO DE LA PROVINCIA DE BUENOS AIRES"						, "" 								 } )
		aAdd( aBody, { "", "000091","505",	"32 062 580",	"BANCO CREDIT SUISSE (BRASIL) S.A."							, "" 								 } )
		aAdd( aBody, { "", "000092","600",	"59 118 133",	"BANCO LUSO BRASILEIRO S.A."								, "" 								 } )
		aAdd( aBody, { "", "000093","604",	"31 895 683",	"BANCO INDUSTRIAL DO BRASIL S.A."							, "" 								 } )
		aAdd( aBody, { "", "000094","610",	"78 626 983",	"BANCO VR S.A."												, "" 								 } )
		aAdd( aBody, { "", "000095","611",	"61 820 817",	"BANCO PAULISTA S.A."										, "" 								 } )
		aAdd( aBody, { "", "000096","612",	"31 880 826",	"BANCO GUANABARA S.A."										, "" 								 } )
		aAdd( aBody, { "", "000097","613",	"60 850 229",	"OMNI BANCO S.A."											, "" 								 } )
		aAdd( aBody, { "", "000098","623",	"59 285 411",	"BANCO PANAMERICANO S.A."									, "" 								 } )
		aAdd( aBody, { "", "000099","626",	"61 348 538",	"BANCO C6 CONSIGNADO S.A."									, "" 								 } )
		aAdd( aBody, { "", "000100","630",	"58 497 702",	"BCO LETSBANK S.A."											, "" 								 } )
		aAdd( aBody, { "", "000101","633",	"68 900 810",	"BANCO RENDIMENTO S.A."										, "" 								 } )
		aAdd( aBody, { "", "000102","634",	"17 351 180",	"BANCO TRIANGULO S.A."										, "" 								 } )
		aAdd( aBody, { "", "000103","637",	"60 889 128",	"BANCO SOFISA S.A."											, "" 								 } )
		aAdd( aBody, { "", "000104","638",	"33 876 475",	"BANCO PROSPER S.A."										, "" 								 } )
		aAdd( aBody, { "", "000105","641",	"33 870 163",	"BANCO ALVORADA S.A."										, "" 								 } )
		aAdd( aBody, { "", "000106","643",	"62 144 175",	"BANCO PINE S.A."											, "" 								 } )
		aAdd( aBody, { "", "000107","652",	"60 872 504",	"ITAÚ UNIBANCO BANCO MÚLTIPLO S.A."							, "" 								 } )
		aAdd( aBody, { "", "000108","653",	"61 024 352",	"BANCO VOITER"												, "" 								 } )
		aAdd( aBody, { "", "000109","654",	"92 874 270",	"BCO DIGIMAIS S.A."											, "" 								 } )
		aAdd( aBody, { "", "000110","655",	"59 588 111",	"BANCO VOTORANTIM S.A."										, "" 								 } )
		aAdd( aBody, { "", "000111","707",	"62 232 889",	"BANCO DAYCOVAL S.A."										, "" 								 } )
		aAdd( aBody, { "", "000112","719",	"33 884 941",	"BANCO MASTER MÚLTIPLO"										, "" 								 } )
		aAdd( aBody, { "", "000113","721",	"69 141 539",	"BANCO CREDIBEL S.A."										, "" 								 } )
		aAdd( aBody, { "", "000114","734",	"00 183 938",	"BANCO GERDAU S.A"											, "" 								 } )
		aAdd( aBody, { "", "000115","735",	"00 253 448",	"BANCO POTTENCIAL S.A."										, "" 								 } )
		aAdd( aBody, { "", "000116","738",	"43 717 511",	"BANCO MORADA S.A"											, "" 								 } )
		aAdd( aBody, { "", "000117","739",	"00 558 456",	"BANCO BGN S.A."											, "" 								 } )
		aAdd( aBody, { "", "000118","740",	"61 146 577",	"BANCO BARCLAYS S.A."										, "" 								 } )
		aAdd( aBody, { "", "000119","741",	"00 517 645",	"BANCO RIBEIRAO PRETO S.A."									, "" 								 } )
		aAdd( aBody, { "", "000120","743",	"00 795 423",	"BANCO SEMEAR S.A."											, "" 								 } )
		aAdd( aBody, { "", "000121","745",	"33 479 023",	"BANCO CITIBANK S.A."										, "" 								 } )
		aAdd( aBody, { "", "000122","746",	"30 723 886",	"BANCO MODAL S.A."											, "" 								 } )
		aAdd( aBody, { "", "000123","747",	"01 023 570",	"BANCO RABOBANK INTERNATIONAL BRASIL S.A."					, "" 								 } )
		aAdd( aBody, { "", "000124","748",	"01 181 521",	"BANCO COOPERATIVO SICREDI S.A."							, "" 								 } )
		aAdd( aBody, { "", "000125","749",	"10 995 587",	"BANCO SIMPLES S.A."										, "" 								 } )
		aAdd( aBody, { "", "000126","751",	"29 030 467",	"Scotiabank Brasil"											, "" 								 } )
		aAdd( aBody, { "", "000127","752",	"01 522 368",	"BANCO BNP PARIBAS BRASIL S.A."								, "" 								 } )
		aAdd( aBody, { "", "000128","753",	"74 828 799",	"NOVO BCO CONTINENTAL S.A. - BM"							, "" 								 } )
		aAdd( aBody, { "", "000129","756",	"02 038 232",	"BANCO COOPERATIVO SICOOB S.A. - BANCO SICOOB"				, "" 								 } )
		aAdd( aBody, { "", "000130","757",	"02 318 507",	"BANCO KEB HANA DO BRASIL S.A."								, "" 								 } )
		aAdd( aBody, { "", "000131","539",  "00 000 000",   "SANTINVEST S.A. - CFI"										, ""								 } )
  		aAdd( aBody, { "", "000132","430",  "00 000 000",   "CCR SEARA" 												, ""								 } )
		aAdd( aBody, { "", "000133","272",  "00 000 000",   "AGK CC S.A." 												, ""								 } )
		aAdd( aBody, { "", "000134","136",  "00 000 000",   "CONF NAC COOP CENTRAIS UNICRED" 							, ""								 } )
		aAdd( aBody, { "", "000135","407",  "00 000 000",   "SEFER INVESTIMENTOS DTVM LTDA" 							, ""								 } )
		aAdd( aBody, { "", "000136","423",  "00 000 000",   "COLUNA S.A. DTVM" 											, ""								 } )
		aAdd( aBody, { "", "000137","330",  "00 000 000",   "BANCO BARI S.A."											, ""								 } )					
		aAdd( aBody, { "", "000138","534",  "00 000 000",   "EWALLY IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000139","100",  "00 000 000",   "PLANNER CV S.A."											, ""								 } )
		aAdd( aBody, { "", "000140","541",  "00 000 000",   "FDO GARANTIDOR CRÉDITOS" 									, ""								 } )
		aAdd( aBody, { "", "000141","362",  "00 000 000",   "CIELO IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000142","322",  "00 000 000",   "CCR DE ABELARDO LUZ" 										, ""								 } )
		aAdd( aBody, { "", "000143","578",  "00 000 000",   "SICRES"													, ""								 } )
		aAdd( aBody, { "", "000144","350",  "00 000 000",   "COOP DE AGRICULTORES E AEROPORTUÁRIOS DO BRASIL" 			, ""								 } )
		aAdd( aBody, { "", "000145","379",  "00 000 000",   "CECM COOPERFORTE" 											, ""								 } )
		aAdd( aBody, { "", "000146","378",  "00 000 000",   "BCO BRASILEIRO DE CRÉDITO S.A." 							, ""								 } )
		aAdd( aBody, { "", "000147","413",  "00 000 000",   "BCO BV S.A." 												, ""								 } )
		aAdd( aBody, { "", "000148","360",  "00 000 000",   "TRINUS CAPITAL DTVM"										, ""								 } )
		aAdd( aBody, { "", "000149","102",  "00 000 000",   "XP INVESTIMENTOS CCTVM S/A"								, ""								 } )
		aAdd( aBody, { "", "000150","084",  "00 000 000",   "SISPRIME DO BRASIL - COOP" 								, ""								 } )
		aAdd( aBody, { "", "000151","591",  "00 000 000",   "BANVOX DTVM" 												, ""								 } )
		aAdd( aBody, { "", "000152","555",  "00 000 000",   "PAN CFI" 													, ""								 } )
		aAdd( aBody, { "", "000153","180",  "00 000 000",   "CM CAPITAL MARKETS CCTVM LTDA" 							, ""								 } )
		aAdd( aBody, { "", "000154","015",  "00 000 000",   "UBS BB CCTVM S.A." 										, ""								 } )
		aAdd( aBody, { "", "000155","143",  "00 000 000",   "TREVISO CC S.A." 											, ""								 } )
		aAdd( aBody, { "", "000156","099",  "00 000 000",   "UNIPRIME COOPCENTRAL LTDA." 								, ""								 } )
		aAdd( aBody, { "", "000157","387",  "00 000 000",   "BCO TOYOTA DO BRASIL S.A." 								, ""								 } )
		aAdd( aBody, { "", "000158","326",  "00 000 000",   "PARATI - CFI S.A." 										, ""								 } )
		aAdd( aBody, { "", "000159","307",  "00 000 000",   "TERRA INVESTIMENTOS DTVM" 									, ""								 } )
		aAdd( aBody, { "", "000160","385",  "00 000 000",   "CECM DOS TRAB.PORT. DA G.VITOR" 							, ""								 } )
		aAdd( aBody, { "", "000161","425",  "00 000 000",   "SOCINAL S.A. CFI" 											, ""								 } )
		aAdd( aBody, { "", "000162","190",  "00 000 000",   "SERVICOOP" 												, ""								 } )
		aAdd( aBody, { "", "000163","296",  "00 000 000",   "OZ CORRETORA DE CÂMBIO S.A." 								, ""								 } )
		aAdd( aBody, { "", "000164","191",  "00 000 000",   "NOVA FUTURA CTVM LTDA." 									, ""								 } )
		aAdd( aBody, { "", "000165","382",  "00 000 000",   "FIDUCIA SCMEPP LTDA"										, ""								 } )
		aAdd( aBody, { "", "000166","064",  "00 000 000",   "GOLDMAN SACHS DO BRASIL BM S.A" 							, ""								 } )
		aAdd( aBody, { "", "000167","097",  "00 000 000",   "CREDISIS - CENTRAL DE COOPERATIVAS DE CRÉDITO LTDA." 		, ""								 } )
		aAdd( aBody, { "", "000168","016",  "00 000 000",   "CCM DESP TRÂNS SC E RS" 									, ""								 } )
		aAdd( aBody, { "", "000169","299",  "00 000 000",   "BCO AFINZ S.A. - BM" 										, ""								 } )
		aAdd( aBody, { "", "000170","471",  "00 000 000",   "CECM SERV PUBL PINHÃO" 									, ""								 } )
		aAdd( aBody, { "", "000171","540",  "00 000 000",   "HBI SCD" 													, ""								 } )
		aAdd( aBody, { "", "000172","060",  "00 000 000",   "CONFIDENCE CC S.A." 										, ""								 } )
		aAdd( aBody, { "", "000173","359",  "00 000 000",   "ZEMA CFI S/A" 												, ""								 } )
		aAdd( aBody, { "", "000174","159",  "00 000 000",   "CASA CREDITO S.A. SCM"										, ""								 } )
		aAdd( aBody, { "", "000175","085",  "00 000 000",   "COOPCENTRAL AILOS" 										, ""								 } )
		aAdd( aBody, { "", "000176","400",  "00 000 000",   "COOP CREDITAG" 											, ""								 } )
		aAdd( aBody, { "", "000177","429",  "00 000 000",   "CREDIARE CFI S.A." 										, ""								 } )
		aAdd( aBody, { "", "000178","410",  "00 000 000",   "PLANNER SOCIEDADE DE CRÉDITO DIRETO"						, ""								 } )
		aAdd( aBody, { "", "000179","328",  "00 000 000",   "CECM FABRIC CALÇADOS SAPIRANGA" 							, ""								 } )
		aAdd( aBody, { "", "000180","548",  "00 000 000",   "RPW S.A. SCFI" 											, ""								 } )
		aAdd( aBody, { "", "000181","469",  "00 000 000",   "PICPAY INVEST" 											, ""								 } )
		aAdd( aBody, { "", "000182","458",  "00 000 000",   "HEDGE INVESTMENTS DTVM LTDA."								, ""								 } )
		aAdd( aBody, { "", "000183","189",  "00 000 000",    "HS FINANCEIRA" 											, ""								 } )
		aAdd( aBody, { "", "000184","105",  "00 000 000",   "LECCA CFI S.A." 											, ""								 } )
		aAdd( aBody, { "", "000185","312",  "00 000 000",   "HSCM SCMEPP LTDA." 										, ""								 } )
		aAdd( aBody, { "", "000186","195",  "00 000 000",   "VALOR S/A SCFI"											, ""								 } )
		aAdd( aBody, { "", "000187","093",  "00 000 000",   "POLOCRED SCMEPP LTDA." 									, ""								 } )
		aAdd( aBody, { "", "000188","391",  "00 000 000",   "CCR DE IBIAM"											    , ""								 } )
		aAdd( aBody, { "", "000189","273",  "00 000 000",   "CCR DE SÃO MIGUEL DO OESTE" 								, ""								 } )
		aAdd( aBody, { "", "000190","368",  "00 000 000",   "BCO CSF S.A."												, ""								 } )
		aAdd( aBody, { "", "000191","290",  "00 000 000",   "MONEYCORP BCO DE CÂMBIO S.A."								, ""								 } )
		aAdd( aBody, { "", "000193","395",  "00 000 000",   "F D GOLD DTVM LTDA" 										, ""								 } )
		aAdd( aBody, { "", "000194","364",  "00 000 000",   "EFÍ S.A. - IP" 											, ""								 } )
		aAdd( aBody, { "", "000195","157",  "00 000 000",   "ICAP DO BRASIL CTVM LTDA." 								, ""								 } )
		aAdd( aBody, { "", "000196","183",  "00 000 000",   "SOCRED SA - SCMEPP" 										, ""								 } )
		aAdd( aBody, { "", "000197","130",  "00 000 000",   "CARUANA SCFI"												, ""								 } )
		aAdd( aBody, { "", "000198","358",  "00 000 000",   "MIDWAY S.A. - SCFI" 										, ""								 } )
		aAdd( aBody, { "", "000199","127",  "00 000 000",   "CODEPE CVC S.A." 											, ""								 } )
		aAdd( aBody, { "", "000200","141",  "00 000 000",   "MASTER BI S.A." 											, ""								 } )
		aAdd( aBody, { "", "000201","340",  "00 000 000",   "SUPERDIGITAL I.P. S.A." 									, ""								 } )
		aAdd( aBody, { "", "000202","475",  "00 000 000",   "BCO YAMAHA MOTOR S.A." 									, ""								 } )
		aAdd( aBody, { "", "000203","133",  "00 000 000",   "CRESOL CONFEDERAÇÃO" 										, ""								 } )
		aAdd( aBody, { "", "000204","323",  "00 000 000",   "MERCADO PAGO IP LTDA." 									, ""								 } )
		aAdd( aBody, { "", "000205","577",  "00 000 000",   "AF DESENVOLVE SP S.A." 									, ""								 } )
		aAdd( aBody, { "", "000206","121",  "00 000 000",   "BCO AGIBANK S.A." 											, ""								 } )
		aAdd( aBody, { "", "000207","138",  "00 000 000",   "GET MONEY CC LTDA" 										, ""								 } )
		aAdd( aBody, { "", "000208","384",  "00 000 000",   "GLOBAL SCM LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000209","426",  "00 000 000",   "NEON FINANCEIRA - CFI S.A."								, ""								 } )
		aAdd( aBody, { "", "000210","576",  "00 000 000",   "MERCADO BITCOIN IP LTDA" 									, ""								 } )
		aAdd( aBody, { "", "000211","664",  "00 000 000",   "EAGLE IP LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000212","088",  "00 000 000",   "BANCO RANDON S.A." 										, ""								 } )
		aAdd( aBody, { "", "000213","319",  "00 000 000",   "OM DTVM LTDA" 												, ""								 } )
		aAdd( aBody, { "", "000214","274",  "00 000 000",   "BMP SCMEPP LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000215","095",  "00 000 000",   "TRAVELEX BANCO DE CÂMBIO S.A." 							, ""								 } )
		aAdd( aBody, { "", "000217","478",  "00 000 000",   "GAZINCRED S.A. SCFI" 									    , ""								 } )
		aAdd( aBody, { "", "000218","276",  "00 000 000",   "BCO SENFF S.A." 											, ""								 } )
		aAdd( aBody, { "", "000219","447",  "00 000 000",   "MIRAE ASSET (BRASIL) CCTVM LTDA." 							, ""								 } )
		aAdd( aBody, { "", "000220","569",  "00 000 000",   "CONTA PRONTA IP" 											, ""								 } )
		aAdd( aBody, { "", "000221","144",  "00 000 000",   "EBURY BCO DE CÂMBIO S.A." 									, ""								 } )
		aAdd( aBody, { "", "000222","332",  "00 000 000",   "ACESSO SOLUÇÕES DE PAGAMENTO S.A.-INSTITUI. DE PAGAMENTO"  , ""								 } )
		aAdd( aBody, { "", "000223","450",  "00 000 000",   "FITBANK IP" 												, ""								 } )
		aAdd( aBody, { "", "000224","126",  "00 000 000",   "BR PARTNERS BI" 											, ""								 } )
		aAdd( aBody, { "", "000225","325",  "00 000 000",   "ÓRAMA DTVM S.A." 											, ""								 } )
		aAdd( aBody, { "", "000226","301",  "00 000 000",   "DOCK IP S.A." 											 	, ""								 } )
		aAdd( aBody, { "", "000227","173",  "00 000 000",   "BRL TRUST DTVM SA" 										, ""								 } )
		aAdd( aBody, { "", "000228","331",  "00 000 000",   "OSLO CAPITAL DTVM SA" 										, ""								 } )
		aAdd( aBody, { "", "000229","119",  "00 000 000",   "BCO WESTERN UNION" 										, ""								 } )
		aAdd( aBody, { "", "000230","396",  "00 000 000",   "HUB IP S.A." 												, ""								 } )
		aAdd( aBody, { "", "000231","509",  "00 000 000",   "CELCOIN IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000232","268",  "00 000 000",   "BARI CIA HIPOTECÁRIA" 										, ""								 } )
		aAdd( aBody, { "", "000233","401",  "00 000 000",   "IUGU IP S.A." 												, ""								 } )
		aAdd( aBody, { "", "000234","334",  "00 000 000",   "BANCO BESA S.A." 											, ""								 } )
		aAdd( aBody, { "", "000235","124",  "00 000 000",   "BCO WOORI BANK DO BRASIL S.A."								, ""								 } )
		aAdd( aBody, { "", "000236","549",  "00 000 000",   "INTRA DTVM" 												, ""								 } )
		aAdd( aBody, { "", "000237","149",  "00 000 000",   "FACTA S.A. CFI" 											, ""								 } )
		aAdd( aBody, { "", "000238","197",  "00 000 000",   "STONE IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000239","439",  "00 000 000",   "ID CTVM" 													, ""								 } )
		aAdd( aBody, { "", "000240","142",  "00 000 000",   "BROKER BRASIL CC LTDA." 									, ""								 } )
		aAdd( aBody, { "", "000241","529",  "00 000 000",   "PINBANK IP" 												, ""								 } )
		aAdd( aBody, { "", "000242","415",  "00 000 000",   "BCO NACIONAL" 												, ""								 } )
		aAdd( aBody, { "", "000243","545",  "00 000 000",   "SENSO CCVM S.A." 											, ""								 } )
		aAdd( aBody, { "", "000244","132",  "00 000 000",   "ICBC DO BRASIL BM S.A." 									, ""								 } )
		aAdd( aBody, { "", "000245","298",  "00 000 000",   "VIPS CC LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000246","377",  "00 000 000",   "BMS SCD S.A." 												, ""								 } )
		aAdd( aBody, { "", "000247","321",  "00 000 000",   "CREFAZ SCMEPP SA" 											, ""								 } )
		aAdd( aBody, { "", "000248","542",  "00 000 000",   "CLOUDWALK IP LTDA"											, ""								 } )
		aAdd( aBody, { "", "000249","260",  "00 000 000",   "NU PAGAMENTOS - IP" 										, ""								 } )
		aAdd( aBody, { "", "000250","470",  "00 000 000",   "CDC SCD S.A." 												, ""								 } )
		aAdd( aBody, { "", "000251","129",  "00 000 000",   "UBS BB BI S.A." 											, ""								 } )
		aAdd( aBody, { "", "000252","562",  "00 000 000",   "AZIMUT BRASIL DTVM LTDA" 									, ""								 } )
		aAdd( aBody, { "", "000253","128",  "00 000 000",   "BRAZA BANK S.A. BCO DE CÂMBIO"								, ""								 } )
		aAdd( aBody, { "", "000254","416",  "00 000 000",   "LAMARA SCD S.A."											, ""								 } )
		aAdd( aBody, { "", "000255","595",  "00 000 000",   "ZOOP MEIOS DE PAGAMENTO" 									, ""								 } )
		aAdd( aBody, { "", "000256","461",  "00 000 000",   "ASAAS IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000257","194",  "00 000 000",   "UNIDA DTVM LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000258","538",  "00 000 000",   "SUDACRED SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000259","588",  "00 000 000",   "PROVER PROMOCAO DE VENDAS IP LTDA." 						, ""								 } )
		aAdd( aBody, { "", "000260","561",  "00 000 000",   "PAY4FUN IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000261","536",  "00 000 000",   "NEON PAGAMENTOS S.A. IP" 									, ""								 } )
		aAdd( aBody, { "", "000262","383",  "00 000 000",   "EBANX IP LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000263","324",  "00 000 000",   "CARTOS SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000264","560",  "00 000 000",   "MAG IP LTDA."												, ""								 } )
		aAdd( aBody, { "", "000265","533",  "00 000 000",   "SRM BANK" 													, ""								 } )
		aAdd( aBody, { "", "000266","310",  "00 000 000",   "VORTX DTVM LTDA."											, ""								 } )
		aAdd( aBody, { "", "000267","380",  "00 000 000",   "PICPAY" 													, ""								 } )
		aAdd( aBody, { "", "000268","566",  "00 000 000",   "FLAGSHIP IP LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000269","280",  "00 000 000",   "WILL FINANCEIRA S.A.CFI" 									, ""								 } )
		aAdd( aBody, { "", "000270","146",  "00 000 000",   " GUITTA CC LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000271","343",  "00 000 000",   "FFA SCMEPP LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000272","651",  "00 000 000",   "PAGARE IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000273","593",  "00 000 000",   "TRANSFEERA IP S.A." 										, ""								 } )
		aAdd( aBody, { "", "000274","335",  "00 000 000",   "BANCO DIGIO" 												, ""								 } )
		aAdd( aBody, { "", "000275","349",  "00 000 000",   "AL5 S.A. CFI" 												, ""								 } )
		aAdd( aBody, { "", "000276","427",  "00 000 000",   "CRED-UFES" 												, ""								 } )
		aAdd( aBody, { "", "000277","374",  "00 000 000",   "REALIZE CFI S.A." 											, ""								 } )
		aAdd( aBody, { "", "000278","278",  "00 000 000",   "GENIAL INVESTIMENTOS CVM S.A." 							, ""								 } )
		aAdd( aBody, { "", "000279","271",  "00 000 000",   "IB CCTVM S.A." 											, ""								 } )
		aAdd( aBody, { "", "000280","292",  "00 000 000",   "GALAPAGOS DTVM S.A." 										, ""								 } )
		aAdd( aBody, { "", "000281","554",  "00 000 000",   "STONEX BANCO DE CÂMBIO S.A." 								, ""								 } )
		aAdd( aBody, { "", "000282","352",  "00 000 000",   "TORO CTVM S.A." 											, ""								 } )
		aAdd( aBody, { "", "000283","386",  "00 000 000",   "NU FINANCEIRA S.A. CFI" 									, ""								 } )
		aAdd( aBody, { "", "000284","557",  "00 000 000",   "PAGPRIME IP" 												, ""								 } )
		aAdd( aBody, { "", "000285","546",  "00 000 000",   "U4C INSTITUIÇÃO DE PAGAMENTO S.A." 						, ""								 } )
		aAdd( aBody, { "", "000286","398",  "00 000 000",   "IDEAL CTVM S.A." 											, ""								 } )
		aAdd( aBody, { "", "000287","336",  "00 000 000",   "BCO C6 S.A." 												, ""								 } )
		aAdd( aBody, { "", "000288","550",  "00 000 000",   "BEETELLER" 												, ""								 } )
		aAdd( aBody, { "", "000289","552",  "00 000 000",   "UZZIPAY IP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000290","329",  "00 000 000",   "QI SCD S.A." 												, ""								 } )
		aAdd( aBody, { "", "000291","196",  "00 000 000",   "FAIR CC S.A." 												, ""								 } )
		aAdd( aBody, { "", "000292","342",  "00 000 000",   "CREDITAS SCD" 												, ""								 } )
		aAdd( aBody, { "", "000293","567",  "00 000 000",   "MERCANTIL FINANCEIRA" 										, ""								 } )
		aAdd( aBody, { "", "000294","122",  "00 000 000",   "BCO BRADESCO BERJ S.A."									, ""								 } )
		aAdd( aBody, { "", "000295","348",  "00 000 000",   "BCO XP S.A." 												, ""								 } )
		aAdd( aBody, { "", "000296","120",  "00 000 000",   "BCO RODOBENS S.A." 										, ""								 } )
		aAdd( aBody, { "", "000297","007",  "00 000 000",   "BNDES" 													, ""								 } )
		aAdd( aBody, { "", "000298","583",  "00 000 000",   "CCC POUP INV DO CENTRO NORTE DO BRASIL" 					, ""								 } )
		aAdd( aBody, { "", "000299","582",  "00 000 000",   "CCC POUP INV DE MS, GO, DF E TO" 							, ""								 } )
		aAdd( aBody, { "", "000300","188",  "00 000 000",   "ATIVA S.A. INVESTIMENTOS CCTVM" 							, ""								 } )
		aAdd( aBody, { "", "000301","134",  "00 000 000",   "BGC LIQUIDEZ DTVM LTDA" 									, ""								 } )
		aAdd( aBody, { "", "000302","467",  "00 000 000",   "MASTER S/A CCTVM" 											, ""								 } )
		aAdd( aBody, { "", "000303","397",  "00 000 000",   "LISTO SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000304","525",  "00 000 000",   "INTERCAM CC LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000305","355",  "00 000 000",   "ÓTIMO SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000306","531",  "00 000 000",   "BMP SCD S.A." 												, ""								 } )
		aAdd( aBody, { "", "000307","660",  "00 000 000",   "PAGME IP LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000308","597",  "00 000 000",   "ISSUER IP LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000309","528",  "00 000 000",   "REAG TRUST DTVM" 											, ""								 } )
		aAdd( aBody, { "", "000310","659",  "00 000 000",   "ONEKEY PAYMENTS IP S.A." 									, ""								 } )
		aAdd( aBody, { "", "000311","445",  "00 000 000",   "PLANTAE CFI" 												, ""								 } )
		aAdd( aBody, { "", "000312","586",  "00 000 000",   "Z1 IP LTDA." 												, ""								 } )
		aAdd( aBody, { "", "000313","373",  "00 000 000",   "UP.P SEP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000314","111",  "00 000 000",   "OLIVEIRA TRUST DTVM S.A." 									, ""								 } )
		aAdd( aBody, { "", "000315","512",  "00 000 000",   "FINVEST DTVM" 												, ""								 } )
		aAdd( aBody, { "", "000316","599",  "00 000 000",   "AGORACRED S/A SCFI" 										, ""								 } )
		aAdd( aBody, { "", "000317","516",  "00 000 000",   "QISTA S.A. CFI" 											, ""								 } )
		aAdd( aBody, { "", "000318","408",  "00 000 000",   "BONUSPAGO SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000319","484",  "00 000 000",   "MAF DTVM SA" 												, ""								 } )
		aAdd( aBody, { "", "000320","402",  "00 000 000",   "COBUCCIO S.A. SCFI" 									    , ""								 } )
		aAdd( aBody, { "", "000321","507",  "00 000 000",   "SCFI EFÍ S.A." 											, ""								 } )
		aAdd( aBody, { "", "000322","404",  "00 000 000",   "SUMUP SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000323","418",  "00 000 000",   "ZIPDIN SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000324","615",  "00 000 000",   "SMART SOLUTIONS GROUP IP LTDA" 							, ""								 } )
		aAdd( aBody, { "", "000325","414",  "00 000 000",   "LEND SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000326","449",  "00 000 000",   "DM" 														, ""								 } )
		aAdd( aBody, { "", "000327","587",  "00 000 000",   "FIDD DTVM LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000328","518",  "00 000 000",   "MERCADO CRÉDITO SCFI S.A." 								, ""								 } )
		aAdd( aBody, { "", "000329","406",  "00 000 000",   "ACCREDITO SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000330","403",  "00 000 000",   "CORA SCFI" 												, ""								 } )
		aAdd( aBody, { "", "000331","419",  "00 000 000",   "NUMBRS SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000332","435",  "00 000 000",   "DELCRED SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000333","455",  "00 000 000",   "FÊNIX DTVM LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000334","544",  "00 000 000",   "MULTICRED SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000335","421",  "00 000 000",   "CC LAR CREDI" 												, ""								 } )
		aAdd( aBody, { "", "000336","443",  "00 000 000",   "CREDIHOME SCD" 											, ""								 } )
		aAdd( aBody, { "", "000337","535",  "00 000 000",   "OPEA SCD" 													, ""								 } )
		aAdd( aBody, { "", "000338","457",  "00 000 000",   "UY3 SCD S/A" 												, ""								 } )
		aAdd( aBody, { "", "000339","428",  "00 000 000",   "CREDSYSTEM SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000340","448",  "00 000 000",   "HEMERA DTVM LTDA." 										, ""								 } )
		aAdd( aBody, { "", "000341","452",  "00 000 000",   "CREDIFIT SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000342","510",  "00 000 000",   "FFCRED SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000343","462",  "00 000 000",   "STARK SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000344","465",  "00 000 000",   "CAPITAL CONSIG SCD S.A." 									, ""								 } )
		aAdd( aBody, { "", "000345","636",  "00 000 000",   "GIRO - SCD S/A" 											, ""								 } )
		aAdd( aBody, { "", "000346","563",  "00 000 000",   "PROTEGE PAY CASH IP S.A." 									, ""								 } )
		aAdd( aBody, { "", "000347","306",  "00 000 000",   "PORTOPAR DTVM LTDA" 										, ""								 } )
		aAdd( aBody, { "", "000348","556",  "00 000 000",   "SAYGO CÂMBIO" 												, ""								 } )
		aAdd( aBody, { "", "000349","305",  "00 000 000",   "FOURTRADE COR. DE CAMBIO LTDA" 							, ""								 } )
		aAdd( aBody, { "", "000350","463",  "00 000 000",   "AZUMI DTVM" 												, ""								 } )
		aAdd( aBody, { "", "000351","590",  "00 000 000",   "REPASSES FINANCEIROS E SOLUCOES TECNOLOGICAS IP S.A." 		, ""								 } )
		aAdd( aBody, { "", "000352","451",  "00 000 000",   "J17 - SCD S/A" 											, ""								 } )
		aAdd( aBody, { "", "000353","444",  "00 000 000",   "TRINUS SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000354","519",  "00 000 000",   "LIONS TRUST DTVM" 											, ""								 } )
		aAdd( aBody, { "", "000355","454",  "00 000 000",   "MÉRITO DTVM LTDA." 										, ""								 } )
		aAdd( aBody, { "", "000356","460",  "00 000 000",   "UNAVANTI SCD S/A" 											, ""								 } )
		aAdd( aBody, { "", "000357","506",  "00 000 000",   "RJI" 														, ""								 } )
		aAdd( aBody, { "", "000358","482",  "00 000 000",   "SBCASH SCD" 												, ""								 } )
		aAdd( aBody, { "", "000359","017",  "00 000 000",   "BNY MELLON BCO S.A." 										, ""								 } )
		aAdd( aBody, { "", "000360","174",  "00 000 000",   "PEFISA S.A. - C.F.I." 										, ""								 } )
		aAdd( aBody, { "", "000361","481",  "00 000 000",   "SUPERLÓGICA SCD S.A."										, ""								 } )
		aAdd( aBody, { "", "000362","521",  "00 000 000",   "PEAK SEP S.A." 											, ""								 } )
		aAdd( aBody, { "", "000363","433",  "00 000 000",   "BR-CAPITAL DTVM S.A." 										, ""								 } )
		aAdd( aBody, { "", "000364","523",  "00 000 000",   "HR DIGITAL SCD" 											, ""								 } )
		aAdd( aBody, { "", "000365","527",  "00 000 000",   "ATICCA SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000366","511",  "00 000 000",   "MAGNUM SCD" 												, ""								 } )
		aAdd( aBody, { "", "000367","520",  "00 000 000",   "SOMAPAY SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000368","513",  "00 000 000",   "ATF SCD S.A." 												, ""								 } )
		aAdd( aBody, { "", "000369","125",  "00 000 000",   "BANCO GENIAL"												, ""								 } )
		aAdd( aBody, { "", "000370","547",  "00 000 000",   "BNK DIGITAL SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000371","592",  "00 000 000",   "MAPS IP LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000372","532",  "00 000 000",   "EAGLE SCD S.A."											, ""								 } )
		aAdd( aBody, { "", "000373","537",  "00 000 000",   "MICROCASH SCMEPP LTDA."									, ""								 } )
		aAdd( aBody, { "", "000374","524",  "00 000 000",   "WNT CAPITAL DTVM" 											, ""								 } )
		aAdd( aBody, { "", "000375","526",  "00 000 000",   "MONETARIE SCD" 											, ""								 } )
		aAdd( aBody, { "", "000376","558",  "00 000 000",   "QI DTVM LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000377","522",  "00 000 000",   "RED SCD S.A." 												, ""								 } )
		aAdd( aBody, { "", "000378","530",  "00 000 000",   "SER FINANCE SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000379","575",  "00 000 000",   "DGBK CREDIT S.A. - SOCIEDADE DE CRÉDITO DIRETO." 			, ""								 } )
		aAdd( aBody, { "", "000380","594",  "00 000 000",   "ASA SOCIEDADE DE CRÉDITO DIRETO S.A." 						, ""								 } )
		aAdd( aBody, { "", "000381","553",  "00 000 000",   "PERCAPITAL SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000382","551",  "00 000 000",   "VERT DTVM LTDA."											, ""								 } )
		aAdd( aBody, { "", "000383","559",  "00 000 000",   "KANASTRA SCD" 												, ""								 } )
		aAdd( aBody, { "", "000384","579",  "00 000 000",   "QUADRA SCD" 												, ""								 } )
		aAdd( aBody, { "", "000385","619",  "00 000 000",   "TRIO IP LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000386","568",  "00 000 000",   "BRCONDOS SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000387","145",  "00 000 000",   "LEVYCAM CCV LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000388","585",  "00 000 000",   "SETHI SCD SA" 												, ""								 } )
		aAdd( aBody, { "", "000389","589",  "00 000 000",   "G5 SCD SA" 												, ""								 } )
		aAdd( aBody, { "", "000390","620",  "00 000 000",   "REVOLUT SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000391","572",  "00 000 000",   "ALL IN CRED SCD S.A." 										, ""								 } )
		aAdd( aBody, { "", "000392","614",  "00 000 000",   "NITRO SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000393","632",  "00 000 000",   "Z-ON SCD S.A." 											, ""								 } )
		aAdd( aBody, { "", "000394","269",  "00 000 000",   "BCO HSBC S.A." 											, ""								 } )
		aAdd( aBody, { "", "000395","644",  "00 000 000",   "321 SCD S.A." 												, ""								 } )
		aAdd( aBody, { "", "000396","139",  "00 000 000",   "INTESA SANPAOLO BRASIL S.A. BM" 							, ""								 } )
		aAdd( aBody, { "", "000397","661",  "00 000 000",   "FREEX CC S.A." 											, ""								 } )
		aAdd( aBody, { "", "000398","018",  "00 000 000",   "BCO TRICURY S.A." 											, ""								 } )
		aAdd( aBody, { "", "000399","393",  "00 000 000",   "BCO VOLKSWAGEN S.A" 										, ""								 } )
		aAdd( aBody, { "", "000400","390",  "00 000 000",   "BCO GM S.A." 												, ""								 } )
		aAdd( aBody, { "", "000401","381",  "00 000 000",   "BCO MERCEDES-BENZ S.A."									, ""								 } )
		aAdd( aBody, { "", "000402","508",  "00 000 000",   "AVENUE SECURITIES DTVM LTDA." 								, ""								 } )
		aAdd( aBody, { "", "000403","113",  "00 000 000",   "NEON CTVM S.A." 											, ""								 } )
		aAdd( aBody, { "", "000404","131",  "00 000 000",   "TULLETT PREBON BRASIL CVC LTDA" 							, ""								 } )
		aAdd( aBody, { "", "000405","011",  "00 000 000",   "C.SUISSE HEDGING-GRIFFO CV S/A" 							, ""								 } )
		aAdd( aBody, { "", "000406","755",  "00 000 000",   "BOFA MERRILL LYNCH BM S.A." 								, ""								 } )
		aAdd( aBody, { "", "000407","089",  "00 000 000",   "CREDISAN CC" 												, ""								 } )
		aAdd( aBody, { "", "000408","140",  "00 000 000",   "NU INVEST CORRETORA DE VALORES S.A." 						, ""								 } )
		aAdd( aBody, { "", "000409","288",  "00 000 000",   "CAROL DTVM LTDA." 											, ""								 } )
		aAdd( aBody, { "", "000410","363",  "00 000 000",   "SINGULARE CTVM S.A."										, ""								 } )
		aAdd( aBody, { "", "000411","101",  "00 000 000",   "RENASCENCA DTVM LTDA" 										, ""								 } )
		aAdd( aBody, { "", "000412","177",  "00 000 000",   "GUIDE" 													, ""								 } )
		aAdd( aBody, { "", "000413","438",  "00 000 000",   "TRUSTEE DTVM LTDA." 										, ""								 } )
		aAdd( aBody, { "", "000414","365",  "00 000 000",   "SIMPAUL" 													, ""								 } )
		aAdd( aBody, { "", "000415","581",  "00 000 000",   "CENTRAL NORDESTE" 											, ""								 } )
		aAdd( aBody, { "", "000416","293",  "00 000 000",   "LASTRO RDV DTVM LTDA" 										, ""								 } )
		aAdd( aBody, { "", "000417","285",  "00 000 000",   "FRENTE CC S.A." 											, ""								 } )
		aAdd( aBody, { "", "000418","514",  "00 000 000",   "EXIM CC LTDA" 												, ""								 } )
		aAdd( aBody, { "", "000419","080",  "00 000 000",   "B&T CC LTDA" 												, ""								 } )
		aAdd( aBody, { "", "000420","565",  "00 000 000",   "ÁGORA CTVM S.A." 											, ""								 } )
		aAdd( aBody, { "", "000421","281",  "00 000 000",   "CCR COOPAVEL" 												, ""								 } )
		aAdd( aBody, { "", "000422","754",  "00 000 000",   "BANCO SISTEMA" 											, ""								 } )
		aAdd( aBody, { "", "000423","098",  "00 000 000",   "CREDIALIANÇA CCR" 											, ""								 } )
		aAdd( aBody, { "", "000424","712",  "00 000 000",   "OURIBANK S.A." 											, ""								 } )
		aAdd( aBody, { "", "000425","584",  "00 000 000",   "CCC POUP E INV DOS ESTADOS DO PR, SP E RJ" 				, ""								 } )
		aAdd( aBody, { "", "000426","720",  "00 000 000",   "BCO RNX S.A." 												, ""								 } )
		aAdd( aBody, { "", "000427","010",  "00 000 000",   "CREDICOAMO" 												, ""								 } )
		aAdd( aBody, { "", "000428","440",  "00 000 000",   "CREDIBRF COOP"												, ""								 } )
		aAdd( aBody, { "", "000429","580",  "00 000 000",   "CCCPOUPINV SUL E SUDESTE - CENTRAL SUL/SUDESTE" 			, ""								 } )
		aAdd( aBody, { "", "000430","283",  "00 000 000",   "RB INVESTIMENTOS DTVM LTDA." 								, ""								 } )
		aAdd( aBody, { "", "000431","646",  "00 000 000",   "DM SA CFI" 												, ""								 } )
		aAdd( aBody, { "", "000432","543",  "00 000 000",   "COOPCRECE"													, ""								 } )
		aAdd( aBody, { "", "000433","117",  "00 000 000",   "ADVANCED CC LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000434","371",  "00 000 000",   "WARREN CVMC LTDA" 											, ""								 } )
		aAdd( aBody, { "", "000435","289",  "00 000 000",   "EFX CC LTDA."												, ""								 } )
		aAdd( aBody, { "", "000436","668",  "48632754000190", "VIA CAPITAL"												, ""								 } )
		aAdd( aBody, { "", "000437","676",  "35479592000150", "Dufrio Financeira"										, ""								 } )
		aAdd( aBody, { "", "000438","680",  "55823094000190", "Delta Global Bank"										, ""								 } )
		aAdd( aBody, { "", "000439","888",  "34028316000103", "ECT"														, ""								 } )
		aAdd( aBody, { "", "000440","901",  "92764489000196", "Sul Financeira"										    , ""								 } )
		aAdd( aBody, { "", "000441","902",  "60779196000196", "Crefisa"										            , ""								 } )
		aAdd( aBody, { "", "000442","903",  "00416968000101", "Banco Inter"										        , ""								 } )
		aAdd( aBody, { "", "000443","905",  "17167412000113", "Alfa"										            , ""								 } )
		aAdd( aBody, { "", "000444","908",  "03311443000191", "Parati"										            , ""								 } )
		aAdd( aBody, { "", "000445","910",  "00122327000136", "SANTINVEST S A"										    , ""								 } )
		aAdd( aBody, { "", "000446","917",  "05289612000160", "Socicred"										        , ""								 } )
		aAdd( aBody, { "", "000447","921",  "05676026000178", "Crediare"										        , ""								 } )
		aAdd( aBody, { "", "000448","922",  "07652226000116", "Lecca"										            , ""								 } )
		aAdd( aBody, { "", "000449","925",  "33136888000143", "BRB Credito e Financiamento S A"							, ""								 } )
		aAdd( aBody, { "", "000450","926",  "33040601000187", "Mercantil Financeira Merc do Brasil Fin"				    , ""								 } )
		aAdd( aBody, { "", "000451","927",  "09313766000109", "Caruana"				                                    , ""								 } )
		aAdd( aBody, { "", "000452","932",  "11760553000169", "Gazincred"				                                , ""								 } )
		aAdd( aBody, { "", "000453","934",  "13660104000174", "AGIBANK FINANCEIRA S.A."				                    , ""								 } )
		aAdd( aBody, { "", "000454","935",  "15581638000130", "FACTA FINANCEIRA S A"				                    , ""								 } )
		aAdd( aBody, { "", "000455","936",  "16564240000159", "Sicoob Coopernapi"				                        , ""								 } )
		aAdd( aBody, { "", "000456","954",  "27098060000145", "DIGIO"				                                    , ""								 } )
		aAdd( aBody, { "", "000457","957",  "05192316000146", "Via Certa"				                                , ""								 } )
		aAdd( aBody, { "", "000458","961",  "07799277000175", "VALOR SCM"				                                , ""								 } )
		aAdd( aBody, { "", "000459","964",  "20443996000117", "FINANC   BECKER"				                            , ""								 } )
		aAdd( aBody, { "", "000460","965",  "45691128000187", "COOPER JOHNSON"				                            , ""								 } )
		aAdd( aBody, { "", "000461","966",  "87163234000138", "SABEMI SEGURADORA"				                        , ""								 } )
		aAdd( aBody, { "", "000462","968",  "95611141000157", "UNIAO SEGURADORA S A   VIDA PREVIDENCIA"				    , ""								 } )
		aAdd( aBody, { "", "000463","970",  "09464032000112", "MIDWAY"				                                    , ""								 } )
		aAdd( aBody, { "", "000464","971",  "35274306000110", "PINCRED"				                                    , ""								 } )
		aAdd( aBody, { "", "000465","973",  "46241852000171", "COMPREVFI"				                                , ""								 } )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGetId

Rotina para carga e atualização da tabela autocontida.
Retorna próximo ID a ser utilizado.

@Return		cRet - ID disponível para utilização

@Author		Alexandre de lima
@Since		08/05/2025
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFAGetId( )

	Local cRet			:= ''
	Local aAreaT8D		:= T8D->(GetArea())  
	Local lContinua		:= .T.
	
	T8D->(DbSetOrder(1))	//T8D_FILIAL+T8D_ID
	
	While lContinua
		cRet	:= GetSX8Num('T8D','T8D_ID')
	
		lContinua := ( T8D->(MsSeek(xFilial('T8D') + cRet)) )
		ConfirmSX8()
	EndDo
	
	RestArea(aAreaT8D)

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGetId

Rotina para carga e atualização da tabela autocontida.
Retorna próximo ID a ser utilizado.

@param      oModel   - Object
@Return		lRetorno - True para inserção positiva dos dados

@Author		Alexandre de lima
@Since		08/05/2025
@Version	1.0
/*/
//-------------------------------------------------------------------

Static Function ValidModel( oModel )

	Local nOperation as  Numeric 
	Local lRetorno   as  Logical

	Default oModel := Nil
	
	nOperation := oModel:GetOperation()
	lRetorno   := .T.

	If nOperation == MODEL_OPERATION_INSERT
		
		If !xFunVldUni("T8D",2, FwFldGet("T8D_CODIGO")+DTOS(FWFLDGET('T8D_VALIDA')))                                                                                                                                                                                                
			lRetorno := .F.
		EndIf

	ElseIf nOperation == MODEL_OPERATION_UPDATE 
	
		If !xFunVldUni("T8D",2, FwFldGet("T8D_CODIGO")+DTOS(FWFLDGET('T8D_VALIDA')))                                                                                      
			lRetorno := .F.
		EndIf

	EndIf

	
Return ( lRetorno )
