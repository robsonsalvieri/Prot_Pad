#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "APWEBEX.CH"  
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

Static lOMSTOL01 := ExistBlock("OMSTOL01")

//Programa responsável por agrupar as estruturas de dados dos webservices
Function TMSXWS()
Return
/*/{Protheus.doc} deliveryUnit
	Contém os itens da viagem
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct deliveryUnit
	wsdata identifier as string
	wsdata viagem as string
	wsdata RegionalSourceId as string
	wsdata orderSourceId as string
	wsdata orderTypeSourceId as string
	wsdata orderItemSourceId as string
	wsdata productSourceId as string
	wsdata sequenceComposition as integer OPTIONAL
	wsdata quantity as float
	wsdata price as float OPTIONAL
	wsdata deliveryDate as Date
	wsdata integrationSource as string
	wsdata classifications as array of classification OPTIONAL
	wsdata deliveryUnitAttributes as array of tripAttribute OPTIONAL 
	wsmethod new
endwsstruct

wsmethod new wsclient deliveryUnit
	::classifications  := {}
	::deliveryUnitAttributes := {}
Return Self
/*/{Protheus.doc} shipmentUnit
	Dados quantitativos das unidades enviadas/recebidas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct shipmentUnit
	wsdata identifier as integer
	wsdata shipmentUnitCategoryId as integer
	wsdata shipmentUnitDescription as string OPTIONAL
	wsdata shipmentUnitQty as float
	wsdata weight as float OPTIONAL
	wsdata volume as float OPTIONAL
	wsdata length as float OPTIONAL
	wsdata width as float OPTIONAL
	wsdata height as float OPTIONAL
	wsdata palletHeightTotal as float OPTIONAL
	wsdata deliveryUnitList as array of deliveryUnit
	wsmethod new
endwsstruct

wsmethod new wsclient shipmentUnit
	::deliveryUnitList := {}
Return Self
/*/{Protheus.doc} subStop
	Representa uma operação dentro de um conjunto de paradas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct subStop
	wsdata identifier as integer
	wsdata arrivalTime as Date
	wsdata startServiceTime as Date OPTIONAL
	wsdata endServiceTime as Date OPTIONAL
	wsdata departureTime as Date
	wsdata dockId as string OPTIONAL
	wsdata dockDescription as string OPTIONAL
	wsdata loadedShipmentUnits as array of shipmentUnit OPTIONAL
	wsdata unloadedShipmentUnits as array of shipmentUnit OPTIONAL
	wsmethod new
endwsstruct

wsmethod new wsclient subStop
	::loadedShipmentUnits := {}
	::unloadedShipmentUnits := {}
Return Self
/*/{Protheus.doc} stop
	Agrupa as paradas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct stop
	wsdata identifier as integer
	wsdata localitySourceId as string
	wsdata transportZoneId as string
	wsdata transportZoneDescription as string optional
	wsdata sequenceOnLoad as integer
	wsdata subStops as array of subStop
	wsmethod new
endwsstruct

wsmethod new wsclient stop
	::subStops := {}
Return Self
/*/{Protheus.doc} load
	Classifica a operação de carregamento/descarregamento para as paradas relacionadas
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct load
	wsdata identifier as integer
	wsdata serviceTypeId as integer
	wsdata serviceDescriptionType as string
	wsdata loadMode as integer
	wsdata modal as integer
	wsdata distance as float
	wsdata freight as float
	wsdata dispatchLimitTime as Date OPTIONAL
	wsdata stops as array of stop
	wsdata stopsLoads as array of stop //Controla o carregamento
	wsdata loadid as integer
	wsdata loadSourceId as STRING optional
	wsmethod new
endwsstruct

wsmethod new wsclient load
	::stops := {}
	::stopsLoads := {}
Return Self
/*/{Protheus.doc} classification
	Classe genérica para guardar atributos genéricos
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct classification
	wsdata type  AS string
	wsdata value AS string
	wsmethod new
endwsstruct

wsmethod new wsclient classification
Return Self
/*/{Protheus.doc} tripAttribute
	Classe genérica para guardar atributos genéricos
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct tripAttribute
	wsdata name  AS string
	wsdata value AS string
	wsmethod new
endwsstruct

wsmethod new wsclient tripAttribute
Return Self
/*/{Protheus.doc} orderBreakPart
	Identifica as quebras de um pedido
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct orderBreakPart
	wsdata regionSourceId AS string 	
	wsdata orderBreakPartId AS integer 	
	wsdata orderSourceId AS string 		
	wsdata orderTypeSourceId AS string 	
	wsdata orderItemSourceId AS string 	
	wsdata loadId AS integer 			
	wsdata shipmentUnitId AS integer 	
	wsdata quantShipmUnits AS float 	
	wsdata quantProdUnits AS float 		
	wsdata orderBreakPartAttributes AS ARRAY OF tripAttribute OPTIONAL
	wsmethod new
endwsstruct

wsmethod new wsclient orderBreakPart
	::orderBreakPartAttributes := {}
Return Self
/*/{Protheus.doc} tripReleaseRequest
	Solicitação de liberação de viagem, possui todos os dados da viagem
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct tripReleaseRequest
	wsdata regionSourceId AS string 	
	wsdata basketSourceId AS string OPTIONAL
	wsdata identifier AS integer 		
	wsdata freightValue AS float 	
	wsdata carrierId AS string 	
	wsdata vehicleId AS string 			
	wsdata vehicleDescription as string
	wsdata truckLicensePlate as string
	wsdata truckStateLicensePlate as string
	wsdata truckStatusId as string
	wsdata truckDescriptionStatus as string
	wsdata truckAxlesQuantity as integer
	wsdata tripClassificationSourceId as string
	wsdata classifications as array of classification
	wsdata tripReleaseRequestAttributes as array of tripAttribute
	wsdata comments as string
 	wsdata loads as array of load
	wsmethod new
endwsstruct

wsmethod new wsclient tripReleaseRequest
	::classifications := {}
	::tripReleaseRequestAttributes := {}
	::loads := {}
Return Self
/*/{Protheus.doc} trip
	Classe que representa uma viagem do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct trip
	wsdata tripId AS integer
	wsdata loads as array of load
	wsmethod new
	wsmethod newload
endwsstruct

wsmethod new wsclient trip
	::loads := {}
Return Self

wsmethod newload wsclient trip
	Local oLoad := load():New()
	oLoad:loadid := 0
	oLoad:loadSourceId := ""
	aAdd(::loads,oLoad)
Return oLoad
/*/{Protheus.doc} ServiceReprogram
	Classe que representa a entrada das solicitações de cancelamento e reprogramação do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct ServiceReprogram
	wsdata basketSourceId as String
	wsdata regionSourceId as String
	wsdata trips as array of trip
	wsmethod new
	wsmethod newtrip
endwsstruct

wsmethod new wsclient ServiceReprogram
	::trips := {}
Return Self

wsmethod newtrip wsclient ServiceReprogram
	Local oTrip := trip():New()
	oTrip:tripId := 0
	aAdd(::trips,oTrip)
Return oTrip
/*/{Protheus.doc} ReprogramResponse
	Classe que representa a resposta das solicitações de cancelamento e reprogramação do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct ReprogramResponse
	wsdata Result as ReprogramResponse_Result
	wsmethod new
	WSMETHOD SOAPSEND
endwsstruct

wsmethod new WSCLIENT ReprogramResponse
	::Result := ReprogramResponse_Result():New()
Return Self 

WSMETHOD SOAPSEND WSCLIENT ReprogramResponse
	Local cSoap := ""
	cSoap += WSSoapValue("Result", ::Result, Result , "ReprogramResponse_Result", .F. , .F., 0 , NIL, .F.)
Return cSoap

wsstruct ReprogramResponse_Result
	wsData items as array of ReprogramResponse_item
	WSMETHOD SOAPSEND
	wsmethod new
	wsmethod newitem
endwsstruct

WSMETHOD new WSCLIENT ReprogramResponse_Result
	::items := {}
Return Self

WSMETHOD newitem WSCLIENT ReprogramResponse_Result
	Local oItem := ReprogramResponse_item():New()
	aAdd(::items,oItem)
Return oItem

WSMETHOD SOAPSEND WSCLIENT ReprogramResponse_Result
	Local cSoap := ""
	aEval( ::items , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "item", .F. , .F., 0 , NIL, .F.)  } )
Return cSoap
/*/{Protheus.doc} ReprogramResponse_item
	Classe que representa os itens das respostas das solicitações de cancelamento e reprogramação do cockpit logístico
@author siegklenes.beulke
@since 01/09/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
wsstruct ReprogramResponse_item
	wsdata Tripid as INTEGER
	wsdata Regionsourceid as String 
	WSDATA Status AS INTEGER
	WSDATA Errormessage AS ARRAY OF String OPTIONAL
	WSMETHOD SOAPSEND
	wsmethod new
	wsmethod newErrormessage
endwsstruct

WSMETHOD new WSCLIENT ReprogramResponse_item
	::Errormessage := {}
Return Self

WSMETHOD newErrormessage WSSEND cMsg WSCLIENT ReprogramResponse_item
	aAdd(::Errormessage,NoAcento(cMsg))
Return Len(::Errormessage)

WSMETHOD SOAPSEND WSCLIENT ReprogramResponse_item
	Local cSoap := ""
	cSoap += WSSoapValue("Tripid", ::Tripid, Tripid , "INTEGER", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("Regionsourceid", ::Regionsourceid, Regionsourceid , "STRING", .F. , .F., 0 , NIL, .F.)
	cSoap += WSSoapValue("Status", ::Status, Status , "INTEGER", .F. , .F., 0 , NIL, .F.)
	If !Empty(::Errormessage)
		aEval( ::Errormessage , {|x| cSoap := cSoap  +  WSSoapValue("Errormessage", x , x , "STRING", .F. , .F., 0 , NIL, .F.)  } )
	EndIf
Return cSoap
//Rotina chamada na criação de um nova thread para recebimento de informações.
//Enquanto a thread persistir, serão mantidos as informações de conexão com o ambiente/banco de dados

Static __aWsMethod := {}
Static __aWsWsdl   := {}
Static __TmsSoapFault := {"","",""}
Static __cStrEnv := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body>'
Static __cEndEnv := '</soapenv:Body></soapenv:Envelope>'
Static __XmlDef := '<?xml version="1.0" encoding="UTF-8"?>'

Function WsdlReprogramService(lAutom)
	Local cRet := ""
	Default lAutom := .F.
	cRet := GetWsdl("publishReprogrammingService")
	
	If Empty(cRet) //xml sem linhas, utilizando base64encode
		cRet += "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48d3NkbDpkZWZp"
		cRet += "bml0aW9ucyBuYW1lPSJwdWJsaXNoUmVwcm9ncmFtbWluZ1NlcnZpY2VSZXF1ZXN0"
		cRet += "IiB0YXJnZXROYW1lc3BhY2U9InVybjpuZW9sb2c6Y29ja3BpdDpUcmlwUmVwcm9n"
		cRet += "cmFtbWluZ1JlcXVlc3RTZXJ2aWNlIiB4bWxuczpwMT0idXJuOm5lb2xvZzpjb2Nr"
		cRet += "cGl0OlRyaXBSZXByb2dyYW1taW5nUmVxdWVzdFNlcnZpY2UiIHhtbG5zOndzZGw9"
		cRet += "Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvIiB4bWxuczp4c2Q9Imh0"
		cRet += "dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hIj48d3NkbDp0eXBlcz48eHNk"
		cRet += "OnNjaGVtYSB0YXJnZXROYW1lc3BhY2U9InVybjpuZW9sb2c6Y29ja3BpdDpUcmlw"
		cRet += "UmVwcm9ncmFtbWluZ1JlcXVlc3RTZXJ2aWNlIiB4bWxucz0idXJuOm5lb2xvZzpj"
		cRet += "b2NrcGl0OlRyaXBSZXByb2dyYW1taW5nUmVxdWVzdFNlcnZpY2UiPjwhLS0gUmVz"
		cRet += "dHJpw6fDtWVzIGRlIGlkcyBJbnRlZ2VyIC0tPjx4c2Q6c2ltcGxlVHlwZSBuYW1l"
		cRet += "PSJpZEludFR5cGUiPjx4c2Q6cmVzdHJpY3Rpb24gYmFzZT0ieHNkOmludGVnZXIi"
		cRet += "Pjx4c2Q6bWluRXhjbHVzaXZlIHZhbHVlPSIwIiAvPjx4c2Q6bWF4RXhjbHVzaXZl"
		cRet += "IHZhbHVlPSIxMDAwMDAwMDAwMCIgLz48L3hzZDpyZXN0cmljdGlvbj48L3hzZDpz"
		cRet += "aW1wbGVUeXBlPjwhLS0gUmVzdHJpw6fDtWVzIGRlIGlkcyBTdHJpbmcgLS0+PHhz"
		cRet += "ZDpzaW1wbGVUeXBlIG5hbWU9InNvdXJjZUlkVHlwZSI+PHhzZDpyZXN0cmljdGlv"
		cRet += "biBiYXNlPSJ4c2Q6c3RyaW5nIj48eHNkOndoaXRlU3BhY2UgdmFsdWU9ImNvbGxh"
		cRet += "cHNlIiAvPjx4c2Q6bWluTGVuZ3RoIHZhbHVlPSIxIiAvPjx4c2Q6bWF4TGVuZ3Ro"
		cRet += "IHZhbHVlPSIzMCIgLz48L3hzZDpyZXN0cmljdGlvbj48L3hzZDpzaW1wbGVUeXBl"
		cRet += "PjwhLS0gUmVzdHJpw6fDtWVzIGRlIHN0YXR1cyBkZSByZXByb2dyYW1hw6fDo28g"
		cRet += "KGVudW0pIC0tPjx4c2Q6c2ltcGxlVHlwZSBuYW1lPSJyZXByb2dyYW1taW5nU3Rh"
		cRet += "dHVzRW51bSI+PHhzZDpyZXN0cmljdGlvbiBiYXNlPSJ4c2Q6aW50ZWdlciI+PHhz"
		cRet += "ZDptaW5JbmNsdXNpdmUgdmFsdWU9IjAiIC8+PHhzZDptYXhJbmNsdXNpdmUgdmFs"
		cRet += "dWU9IjMiIC8+PC94c2Q6cmVzdHJpY3Rpb24+PC94c2Q6c2ltcGxlVHlwZT48IS0t"
		cRet += "IERlZmluacOnw6NvIGRvIGVsZW1lbnRvIExvYWQgLS0+PHhzZDpjb21wbGV4VHlw"
		cRet += "ZSBuYW1lPSJsb2FkIj48eHNkOnNlcXVlbmNlPjx4c2Q6ZWxlbWVudCBuYW1lPSJs"
		cRet += "b2FkSWQiIHR5cGU9ImlkSW50VHlwZSIJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9"
		cRet += "IjEiIG5pbGxhYmxlPSJmYWxzZSIgLz48eHNkOmVsZW1lbnQgbmFtZT0ibG9hZFNv"
		cRet += "dXJjZUlkIiB0eXBlPSJzb3VyY2VJZFR5cGUiCW1pbk9jY3Vycz0iMCIgbWF4T2Nj"
		cRet += "dXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiIC8+PC94c2Q6c2VxdWVuY2U+PC94c2Q6"
		cRet += "Y29tcGxleFR5cGU+PCEtLSBEZWZpbmnDp8OjbyBkbyBlbGVtZW50byBUcmlwIC0t"
		cRet += "Pjx4c2Q6Y29tcGxleFR5cGUgbmFtZT0idHJpcCI+PHhzZDpzZXF1ZW5jZT48eHNk"
		cRet += "OmVsZW1lbnQgbmFtZT0idHJpcElkIiB0eXBlPSJpZEludFR5cGUiCW1pbk9jY3Vy"
		cRet += "cz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPjx4c2Q6YW5ub3Rh"
		cRet += "dGlvbj48eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0"
		cRet += "SUQiPjhmMjZmMTMwNDQzZTExZTBiYTcxNTQ0YjdjNWQ0ODEwPC94c2Q6YXBwaW5m"
		cRet += "bz48L3hzZDphbm5vdGF0aW9uPjwveHNkOmVsZW1lbnQ+PHhzZDplbGVtZW50IG5h"
		cRet += "bWU9ImxvYWRzIiBtaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIJbmlsbGFibGU9"
		cRet += "ImZhbHNlIj48eHNkOmNvbXBsZXhUeXBlPjx4c2Q6c2VxdWVuY2U+PHhzZDplbGVt"
		cRet += "ZW50IG5hbWU9ImxvYWQiIHR5cGU9ImxvYWQiCW1pbk9jY3Vycz0iMSIgbWF4T2Nj"
		cRet += "dXJzPSJ1bmJvdW5kZWQiIG5pbGxhYmxlPSJmYWxzZSIvPjwveHNkOnNlcXVlbmNl"
		cRet += "PjwveHNkOmNvbXBsZXhUeXBlPjwveHNkOmVsZW1lbnQ+PC94c2Q6c2VxdWVuY2U+"
		cRet += "PC94c2Q6Y29tcGxleFR5cGU+PCEtLSBSZXByb2dyYW1taW5nIFJlcXVlc3QgLS0+"
		cRet += "PHhzZDplbGVtZW50IG5hbWU9InB1Ymxpc2hSZXByb2dyYW1taW5nU2VydmljZSI+"
		cRet += "PHhzZDphbm5vdGF0aW9uPjx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAu"
		cRet += "Y29tL3hpL1RleHRJRCI+Y2QzOTc3ZTAyZWM3MTFlMDg5Njg1NDFmNTE5MmE2MTU8"
		cRet += "L3hzZDphcHBpbmZvPjwveHNkOmFubm90YXRpb24+PHhzZDpjb21wbGV4VHlwZT48"
		cRet += "eHNkOnNlcXVlbmNlPjx4c2Q6ZWxlbWVudCBuYW1lPSJyZWdpb25Tb3VyY2VJZCIg"
		cRet += "dHlwZT0ic291cmNlSWRUeXBlIgltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIg"
		cRet += "bmlsbGFibGU9ImZhbHNlIj48eHNkOmFubm90YXRpb24+PHhzZDphcHBpbmZvIHNv"
		cRet += "dXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4NTJlYzAxMWUw"
		cRet += "Yzk5ZTU0MWY1MTkyYTYxNTwveHNkOmFwcGluZm8+PC94c2Q6YW5ub3RhdGlvbj48"
		cRet += "L3hzZDplbGVtZW50Pjx4c2Q6ZWxlbWVudCBuYW1lPSJiYXNrZXRTb3VyY2VJZCIg"
		cRet += "dHlwZT0ic291cmNlSWRUeXBlIgltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSIg"
		cRet += "bmlsbGFibGU9ImZhbHNlIj48eHNkOmFubm90YXRpb24+PHhzZDphcHBpbmZvIHNv"
		cRet += "dXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj44ZjI2ZjEzMDQ0M2UxMWUw"
		cRet += "YmE3MTU0NGI3YzVkNDgxMDwveHNkOmFwcGluZm8+PC94c2Q6YW5ub3RhdGlvbj48"
		cRet += "L3hzZDplbGVtZW50Pjx4c2Q6ZWxlbWVudCBuYW1lPSJ0cmlwcyIgbWluT2NjdXJz"
		cRet += "PSIxIiBtYXhPY2N1cnM9IjEiCW5pbGxhYmxlPSJmYWxzZSI+PHhzZDphbm5vdGF0"
		cRet += "aW9uPjx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJ"
		cRet += "RCI+Y2QzOTc3ZTEyZWM3MTFlMDkxM2E1NDFmNTE5MmE2MTU8L3hzZDphcHBpbmZv"
		cRet += "PjwveHNkOmFubm90YXRpb24+PHhzZDpjb21wbGV4VHlwZT48eHNkOnNlcXVlbmNl"
		cRet += "Pjx4c2Q6ZWxlbWVudCBuYW1lPSJ0cmlwIiB0eXBlPSJ0cmlwIgltaW5PY2N1cnM9"
		cRet += "IjEiIG1heE9jY3Vycz0idW5ib3VuZGVkIiBuaWxsYWJsZT0iZmFsc2UiPjx4c2Q6"
		cRet += "YW5ub3RhdGlvbj48eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94"
		cRet += "aS9UZXh0SUQiPjhmMjZmMTMwNDQzZTExZTBiYTcxNTQ0YjdjNWQ0ODEwPC94c2Q6"
		cRet += "YXBwaW5mbz48L3hzZDphbm5vdGF0aW9uPjwveHNkOmVsZW1lbnQ+PC94c2Q6c2Vx"
		cRet += "dWVuY2U+PC94c2Q6Y29tcGxleFR5cGU+PC94c2Q6ZWxlbWVudD48L3hzZDpzZXF1"
		cRet += "ZW5jZT48L3hzZDpjb21wbGV4VHlwZT48L3hzZDplbGVtZW50PjwhLS0gUmVwcm9n"
		cRet += "cmFtbWluZyBSZXNwb25zZSAtLT48eHNkOmVsZW1lbnQgbmFtZT0icHVibGlzaFJl"
		cRet += "cHJvZ3JhbW1pbmdTZXJ2aWNlUmVzcG9uc2UiPjx4c2Q6YW5ub3RhdGlvbj48eHNk"
		cRet += "OmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmNkYmFi"
		cRet += "ZDk2NDUwNzExZTBiM2IwMDA1MDU2OTU3NGIwPC94c2Q6YXBwaW5mbz48L3hzZDph"
		cRet += "bm5vdGF0aW9uPjx4c2Q6Y29tcGxleFR5cGU+PHhzZDpzZXF1ZW5jZT48eHNkOmVs"
		cRet += "ZW1lbnQgbmFtZT0iUmVzdWx0IiBtaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIJ"
		cRet += "bmlsbGFibGU9ImZhbHNlIj48eHNkOmFubm90YXRpb24+PHhzZDphcHBpbmZvIHNv"
		cRet += "dXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj4zMGM4MzM1MTQ0M2YxMWUw"
		cRet += "YmVjZDU0NGI3YzVkNDgxMDwveHNkOmFwcGluZm8+PC94c2Q6YW5ub3RhdGlvbj48"
		cRet += "eHNkOmNvbXBsZXhUeXBlPjx4c2Q6c2VxdWVuY2U+PHhzZDplbGVtZW50IG5hbWU9"
		cRet += "Iml0ZW0iIG1heE9jY3Vycz0idW5ib3VuZGVkIiBtaW5PY2N1cnM9IjEiPjx4c2Q6"
		cRet += "Y29tcGxleFR5cGU+PHhzZDpzZXF1ZW5jZT48eHNkOmVsZW1lbnQgbmFtZT0iUmVn"
		cRet += "aW9uc291cmNlaWQiIHR5cGU9InNvdXJjZUlkVHlwZSIgbWF4T2NjdXJzPSIxIiBt"
		cRet += "aW5PY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSIvPjx4c2Q6ZWxlbWVudCBuYW1l"
		cRet += "PSJUcmlwaWQiIHR5cGU9ImlkSW50VHlwZSIgbWF4T2NjdXJzPSIxIiBtaW5PY2N1"
		cRet += "cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSIvPjx4c2Q6ZWxlbWVudCBuYW1lPSJTdGF0"
		cRet += "dXMiIHR5cGU9InJlcHJvZ3JhbW1pbmdTdGF0dXNFbnVtIiBtYXhPY2N1cnM9IjEi"
		cRet += "IG1pbk9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIi8+PC94c2Q6c2VxdWVuY2U+"
		cRet += "PC94c2Q6Y29tcGxleFR5cGU+PC94c2Q6ZWxlbWVudD48L3hzZDpzZXF1ZW5jZT48"
		cRet += "L3hzZDpjb21wbGV4VHlwZT48L3hzZDplbGVtZW50PjwveHNkOnNlcXVlbmNlPjwv"
		cRet += "eHNkOmNvbXBsZXhUeXBlPjwveHNkOmVsZW1lbnQ+PC94c2Q6c2NoZW1hPjwvd3Nk"
		cRet += "bDp0eXBlcz48d3NkbDptZXNzYWdlIG5hbWU9InB1Ymxpc2hSZXByb2dyYW1taW5n"
		cRet += "U2VydmljZSI+PHdzZGw6cGFydCBuYW1lPSJwdWJsaXNoUmVwcm9ncmFtbWluZ1Nl"
		cRet += "cnZpY2UiCWVsZW1lbnQ9InAxOnB1Ymxpc2hSZXByb2dyYW1taW5nU2VydmljZSIg"
		cRet += "eG1sbnM6d3NkbD0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3NkbC8iIC8+"
		cRet += "PC93c2RsOm1lc3NhZ2U+PHdzZGw6bWVzc2FnZSBuYW1lPSJwdWJsaXNoUmVwcm9n"
		cRet += "cmFtbWluZ1NlcnZpY2VSZXNwb25zZSI+PHdzZGw6cGFydCBuYW1lPSJwdWJsaXNo"
		cRet += "UmVwcm9ncmFtbWluZ1NlcnZpY2VSZXNwb25zZSIJZWxlbWVudD0icDE6cHVibGlz"
		cRet += "aFJlcHJvZ3JhbW1pbmdTZXJ2aWNlUmVzcG9uc2UiIHhtbG5zOndzZGw9Imh0dHA6"
		cRet += "Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvIiAvPjwvd3NkbDptZXNzYWdlPjx3"
		cRet += "c2RsOnBvcnRUeXBlIG5hbWU9InB1Ymxpc2hSZXByb2dyYW1taW5nU2VydmljZVJl"
		cRet += "cXVlc3QiPjx3c2RsOm9wZXJhdGlvbiBuYW1lPSJwdWJsaXNoUmVwcm9ncmFtbWlu"
		cRet += "Z1NlcnZpY2VSZXF1ZXN0Ij48d3NkbDppbnB1dCBtZXNzYWdlPSJwMTpwdWJsaXNo"
		cRet += "UmVwcm9ncmFtbWluZ1NlcnZpY2UiIC8+PHdzZGw6b3V0cHV0IG1lc3NhZ2U9InAx"
		cRet += "OnB1Ymxpc2hSZXByb2dyYW1taW5nU2VydmljZVJlc3BvbnNlIiAvPjwvd3NkbDpv"
		cRet += "cGVyYXRpb24+PC93c2RsOnBvcnRUeXBlPjx3c2RsOmJpbmRpbmcgbmFtZT0icHVi"
		cRet += "bGlzaFJlcHJvZ3JhbW1pbmdTZXJ2aWNlUmVxdWVzdEJpbmRpbmciCXR5cGU9InAx"
		cRet += "OnB1Ymxpc2hSZXByb2dyYW1taW5nU2VydmljZVJlcXVlc3QiIHhtbG5zOndzZGw9"
		cRet += "Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvIj48c29hcDpiaW5kaW5n"
		cRet += "IHN0eWxlPSJkb2N1bWVudCIJdHJhbnNwb3J0PSJodHRwOi8vc2NoZW1hcy54bWxz"
		cRet += "b2FwLm9yZy9zb2FwL2h0dHAiIHhtbG5zOnNvYXA9Imh0dHA6Ly9zY2hlbWFzLnht"
		cRet += "bHNvYXAub3JnL3dzZGwvc29hcC8iIC8+PHdzZGw6b3BlcmF0aW9uIG5hbWU9InB1"
		cRet += "Ymxpc2hSZXByb2dyYW1taW5nU2VydmljZVJlcXVlc3QiPjxzb2FwOm9wZXJhdGlv"
		cRet += "biBzb2FwQWN0aW9uPSJodHRwOi8vc2FwLmNvbS94aS9XZWJTZXJ2aWNlL3NvYXAx"
		cRet += "LjEiCXhtbG5zOnNvYXA9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwv"
		cRet += "c29hcC8iIC8+PHdzZGw6aW5wdXQ+PHNvYXA6Ym9keSB1c2U9ImxpdGVyYWwiIHht"
		cRet += "bG5zOnNvYXA9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvc29hcC8i"
		cRet += "IC8+PC93c2RsOmlucHV0Pjx3c2RsOm91dHB1dD48c29hcDpib2R5IHVzZT0ibGl0"
		cRet += "ZXJhbCIgeG1sbnM6c29hcD0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3Nk"
		cRet += "bC9zb2FwLyIgLz48L3dzZGw6b3V0cHV0Pjwvd3NkbDpvcGVyYXRpb24+PC93c2Rs"
		cRet += "OmJpbmRpbmc+PHdzZGw6c2VydmljZSBuYW1lPSJwdWJsaXNoUmVwcm9ncmFtbWlu"
		cRet += "Z1NlcnZpY2VSZXF1ZXN0U2VydmljZSI+PHdzZGw6cG9ydCBuYW1lPSJwdWJsaXNo"
		cRet += "UmVwcm9ncmFtbWluZ1NlcnZpY2VSZXF1ZXN0UG9ydCIJYmluZGluZz0icDE6cHVi"
		cRet += "bGlzaFJlcHJvZ3JhbW1pbmdTZXJ2aWNlUmVxdWVzdEJpbmRpbmciIHhtbG5zOndz"
		cRet += "ZGw9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvIj48c29hcDphZGRy"
		cRet += "ZXNzCWxvY2F0aW9uPSJbTE9DQVRJT05dIgl4bWxuczpzb2FwPSJodHRwOi8vc2No"
		cRet += "ZW1hcy54bWxzb2FwLm9yZy93c2RsL3NvYXAvIiAvPjwvd3NkbDpwb3J0Pjwvd3Nk"
		cRet += "bDpzZXJ2aWNlPjwvd3NkbDpkZWZpbml0aW9ucz4="
		cRet := Decode64(cRet)
	EndIf
	
	//Alteração da informação location para o endereço informado na requisição
	If !Empty(cRet) .And. !lAutom
		cRet := LocWsdl(cRet)
	EndIf
Return cRet

Function ReprogramService(oXmlBody,cConteudo, lAutom)
	Local cRet		:= ""
	Local aRet		:= {}
	Local oRet		:= Nil
	Local lRet		:= .F.
	Local lRetTol	:= .F.
	Local lExecNode	:= .F.
	Local bErrorF	:= Errorblock({|e| TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + e:DESCRIPTION + CHR(13) + CHR(10) + e:ERRORSTACK + CHR(13) + CHR(10) + e:ERRORENV  ),SetFaultTMS('Falha ambiente',e:DESCRIPTION)})
	Default lAutom	:= .F. //Nao permite execucao de envio soap com automacao

	OsLogCpl("TMSXWS -> ReprogramService -> Validação no Ambiente","INFO" )
	
	Begin Sequence
	If nModulo == 39 .And. ExistFunc("OmsRepTrip")
		If lOMSTOL01
			OsLogCpl("TMSXWS -> ReprogramService -> Inicio execução do Ponto de entrada OMSTOL01.","INFO")
			aRet		:= ExecBlock("OMSTOL01",.F.,.F.,{ @oXmlBody, @cConteudo, "ReprogramService" }) // aRet[1], Logico / aRet[2], Caracter / aRet[3] Logico, indica se executa ou não o Nó XML
			lRet		:= aRet[1] // .T. os processos relacionados a liberação de viagem no Protheus não serão processados -- .F. o processamento da viagem ocorrerá de forma padrão.
			lExecNode	:= aRet[2] // Indica se executa ou não o Nó XML
			oRet		:= aRet[3] // Objeto de Retorno
			lRetTol		:= aRet[4] // Indica para o TOL, se a Viagem será .T. recebida e liberada ou .F. não recebida.
			OsLogCpl("TMSXWS -> ReprogramService -> Retorno da execução do Ponto de entrada OMSTOL01." + cValToChar(lRet),"INFO")
		EndIf
		If !lRet
			oRet := OmsRepTrip(oXmlBody,@cConteudo)
		EndIf
	EndIf
	End Sequence
	Errorblock(bErrorF)
	
	If lOMSTOL01 .AND. lExecNode .AND. lRet
		cRet += StrTran(__cStrEnv,'/"><', '/" xmlns:ns1="urn:neolog:cockpit:TripReprogrammingRequestService">'+ If( lRetTol, "S", "N" ) + '<')
		cRet += WSSoapValue("ns1:publishReprogrammingServiceResponse", oRet, oRet , "publishReprogrammingService", .F. , .F., 0 , NIL, .F.)
	ElseIf !lAutom .And. !lRet
		cRet += StrTran(__cStrEnv,'/"><', '/" xmlns:ns1="urn:neolog:cockpit:TripReprogrammingRequestService">'+ If(lRet,"S","N") +'<')
		cRet += WSSoapValue("ns1:publishReprogrammingServiceResponse", oRet, oRet , "publishReprogrammingService", .F. , .F., 0 , NIL, .F.)
	EndIf

	cRet += __cEndEnv

	OsLogCpl("TMSXWS -> ReprogramService -> Fim do processo.","INFO")
	
Return cRet

Function WsdlCancelService(lAutom)
	Local cRet := ""
	Default lAutom := .F.
	cRet := GetWsdl("publishCancelService")
	
	
	If Empty(cRet) //xml sem linhas, utilizando base64encode
		cRet += "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48d3NkbDpkZWZp"
		cRet += "bml0aW9ucyBuYW1lPSJwdWJsaXNoQ2FuY2VsU2VydmljZVJlcXVlc3QiIHRhcmdl"
		cRet += "dE5hbWVzcGFjZT0idXJuOm5lb2xvZzpjb2NrcGl0OlRyaXBDYW5jZWxSZXF1ZXN0"
		cRet += "U2VydmljZSIgeG1sbnM6cDE9InVybjpuZW9sb2c6Y29ja3BpdDpUcmlwQ2FuY2Vs"
		cRet += "UmVxdWVzdFNlcnZpY2UiIHhtbG5zOndzZGw9Imh0dHA6Ly9zY2hlbWFzLnhtbHNv"
		cRet += "YXAub3JnL3dzZGwvIiB4bWxuczp4c2Q9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEv"
		cRet += "WE1MU2NoZW1hIj48d3NkbDp0eXBlcz48eHNkOnNjaGVtYSB0YXJnZXROYW1lc3Bh"
		cRet += "Y2U9InVybjpuZW9sb2c6Y29ja3BpdDpUcmlwQ2FuY2VsUmVxdWVzdFNlcnZpY2Ui"
		cRet += "IHhtbG5zPSJ1cm46bmVvbG9nOmNvY2twaXQ6VHJpcENhbmNlbFJlcXVlc3RTZXJ2"
		cRet += "aWNlIj48IS0tIFJlc3RyacOnw7VlcyBkZSBpZHMgSW50ZWdlciAtLT48eHNkOnNp"
		cRet += "bXBsZVR5cGUgbmFtZT0iaWRJbnRUeXBlIj48eHNkOnJlc3RyaWN0aW9uIGJhc2U9"
		cRet += "InhzZDppbnRlZ2VyIj48eHNkOm1pbkV4Y2x1c2l2ZSB2YWx1ZT0iMCIgLz48eHNk"
		cRet += "Om1heEV4Y2x1c2l2ZSB2YWx1ZT0iMTAwMDAwMDAwMDAiIC8+PC94c2Q6cmVzdHJp"
		cRet += "Y3Rpb24+PC94c2Q6c2ltcGxlVHlwZT48IS0tIFJlc3RyacOnw7VlcyBkZSBpZHMg"
		cRet += "U3RyaW5nIC0tPjx4c2Q6c2ltcGxlVHlwZSBuYW1lPSJzb3VyY2VJZFR5cGUiPjx4"
		cRet += "c2Q6cmVzdHJpY3Rpb24gYmFzZT0ieHNkOnN0cmluZyI+PHhzZDp3aGl0ZVNwYWNl"
		cRet += "IHZhbHVlPSJjb2xsYXBzZSIgLz48eHNkOm1pbkxlbmd0aCB2YWx1ZT0iMSIgLz48"
		cRet += "eHNkOm1heExlbmd0aCB2YWx1ZT0iMzAiIC8+PC94c2Q6cmVzdHJpY3Rpb24+PC94"
		cRet += "c2Q6c2ltcGxlVHlwZT48IS0tIFJlc3RyacOnw7VlcyBkZSBzdGF0dXMgZGUgY2Fu"
		cRet += "Y2VsYW1lbnRvIChlbnVtKSAtLT48eHNkOnNpbXBsZVR5cGUgbmFtZT0iY2FuY2Vs"
		cRet += "U3RhdHVzRW51bSI+PHhzZDpyZXN0cmljdGlvbiBiYXNlPSJ4c2Q6aW50ZWdlciI+"
		cRet += "PHhzZDptaW5JbmNsdXNpdmUgdmFsdWU9IjAiIC8+PHhzZDptYXhJbmNsdXNpdmUg"
		cRet += "dmFsdWU9IjMiIC8+PC94c2Q6cmVzdHJpY3Rpb24+PC94c2Q6c2ltcGxlVHlwZT48"
		cRet += "IS0tIERlZmluacOnw6NvIGRvIGVsZW1lbnRvIExvYWQgLS0+PHhzZDpjb21wbGV4"
		cRet += "VHlwZSBuYW1lPSJsb2FkIj48eHNkOnNlcXVlbmNlPjx4c2Q6ZWxlbWVudCBuYW1l"
		cRet += "PSJsb2FkSWQiIHR5cGU9ImlkSW50VHlwZSIJbWluT2NjdXJzPSIxIiBtYXhPY2N1"
		cRet += "cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSIgLz48eHNkOmVsZW1lbnQgbmFtZT0ibG9h"
		cRet += "ZFNvdXJjZUlkIiB0eXBlPSJzb3VyY2VJZFR5cGUiCW1pbk9jY3Vycz0iMCIgbWF4"
		cRet += "T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiIC8+CQkJCQkJPC94c2Q6c2VxdWVu"
		cRet += "Y2U+PC94c2Q6Y29tcGxleFR5cGU+PCEtLSBEZWZpbmnDp8OjbyBkbyBlbGVtZW50"
		cRet += "byBUcmlwIC0tPjx4c2Q6Y29tcGxleFR5cGUgbmFtZT0idHJpcCI+PHhzZDpzZXF1"
		cRet += "ZW5jZT48eHNkOmVsZW1lbnQgbmFtZT0idHJpcElkIiB0eXBlPSJpZEludFR5cGUi"
		cRet += "CW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiIC8+"
		cRet += "PHhzZDplbGVtZW50IG5hbWU9ImxvYWRzIiBtaW5PY2N1cnM9IjEiIG1heE9jY3Vy"
		cRet += "cz0iMSIJbmlsbGFibGU9ImZhbHNlIj48eHNkOmNvbXBsZXhUeXBlPjx4c2Q6c2Vx"
		cRet += "dWVuY2U+PHhzZDplbGVtZW50IG5hbWU9ImxvYWQiIHR5cGU9ImxvYWQiCW1pbk9j"
		cRet += "Y3Vycz0iMSIgbWF4T2NjdXJzPSJ1bmJvdW5kZWQiIG5pbGxhYmxlPSJmYWxzZSI+"
		cRet += "PC94c2Q6ZWxlbWVudD48L3hzZDpzZXF1ZW5jZT48L3hzZDpjb21wbGV4VHlwZT48"
		cRet += "L3hzZDplbGVtZW50Pgk8L3hzZDpzZXF1ZW5jZT48L3hzZDpjb21wbGV4VHlwZT48"
		cRet += "IS0tIENhbmNlbCBSZXF1ZXN0IC0tPjx4c2Q6ZWxlbWVudCBuYW1lPSJwdWJsaXNo"
		cRet += "Q2FuY2VsU2VydmljZSI+PHhzZDpjb21wbGV4VHlwZT48eHNkOnNlcXVlbmNlPjx4"
		cRet += "c2Q6ZWxlbWVudCBuYW1lPSJiYXNrZXRTb3VyY2VJZCIgdHlwZT0ic291cmNlSWRU"
		cRet += "eXBlIgltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNl"
		cRet += "IiAvPjx4c2Q6ZWxlbWVudCBuYW1lPSJyZWdpb25Tb3VyY2VJZCIgdHlwZT0ic291"
		cRet += "cmNlSWRUeXBlIgltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9"
		cRet += "ImZhbHNlIiAvPjx4c2Q6ZWxlbWVudCBuYW1lPSJ0cmlwcyIgbWluT2NjdXJzPSIx"
		cRet += "IiBtYXhPY2N1cnM9IjEiCW5pbGxhYmxlPSJmYWxzZSI+PHhzZDpjb21wbGV4VHlw"
		cRet += "ZT48eHNkOnNlcXVlbmNlPjx4c2Q6ZWxlbWVudCBuYW1lPSJ0cmlwIiB0eXBlPSJ0"
		cRet += "cmlwIgltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0idW5ib3VuZGVkIiBuaWxsYWJs"
		cRet += "ZT0iZmFsc2UiPjwveHNkOmVsZW1lbnQ+PC94c2Q6c2VxdWVuY2U+PC94c2Q6Y29t"
		cRet += "cGxleFR5cGU+PC94c2Q6ZWxlbWVudD48L3hzZDpzZXF1ZW5jZT48L3hzZDpjb21w"
		cRet += "bGV4VHlwZT48L3hzZDplbGVtZW50PjwhLS0gQ2FuY2VsIFJlc3BvbnNlIC0tPjx4"
		cRet += "c2Q6ZWxlbWVudCBuYW1lPSJwdWJsaXNoQ2FuY2VsU2VydmljZVJlc3BvbnNlIj48"
		cRet += "eHNkOmNvbXBsZXhUeXBlPjx4c2Q6c2VxdWVuY2U+PHhzZDplbGVtZW50IG5hbWU9"
		cRet += "IlJlc3VsdCIgbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiCW5pbGxhYmxlPSJm"
		cRet += "YWxzZSI+PHhzZDpjb21wbGV4VHlwZT48eHNkOnNlcXVlbmNlPjx4c2Q6ZWxlbWVu"
		cRet += "dCBuYW1lPSJpdGVtIiBtYXhPY2N1cnM9InVuYm91bmRlZCIgbWluT2NjdXJzPSIx"
		cRet += "Ij48eHNkOmNvbXBsZXhUeXBlPjx4c2Q6c2VxdWVuY2U+PHhzZDplbGVtZW50CW5h"
		cRet += "bWU9IlRyaXBpZCIgdHlwZT0iaWRJbnRUeXBlIiBtYXhPY2N1cnM9IjEiIG1pbk9j"
		cRet += "Y3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj48L3hzZDplbGVtZW50Pjx4c2Q6ZWxl"
		cRet += "bWVudAluYW1lPSJSZWdpb25zb3VyY2VpZCIgdHlwZT0ic291cmNlSWRUeXBlIiBt"
		cRet += "YXhPY2N1cnM9IjEiCW1pbk9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj48L3hz"
		cRet += "ZDplbGVtZW50Pjx4c2Q6ZWxlbWVudAluYW1lPSJTdGF0dXMiIHR5cGU9ImNhbmNl"
		cRet += "bFN0YXR1c0VudW0iIG1heE9jY3Vycz0iMSIJbWluT2NjdXJzPSIxIiBuaWxsYWJs"
		cRet += "ZT0iZmFsc2UiPjwveHNkOmVsZW1lbnQ+PCEtLSBPcGNpb25hbCwgcG9kZSB0ZXIg"
		cRet += "dsOhcmlhcyAtLT48eHNkOmVsZW1lbnQJbmFtZT0iRXJyb3JtZXNzYWdlIiB0eXBl"
		cRet += "PSJ4c2Q6c3RyaW5nIiBtYXhPY2N1cnM9InVuYm91bmRlZCIgbWluT2NjdXJzPSIw"
		cRet += "Ij48L3hzZDplbGVtZW50PjwveHNkOnNlcXVlbmNlPjwveHNkOmNvbXBsZXhUeXBl"
		cRet += "PjwveHNkOmVsZW1lbnQ+PC94c2Q6c2VxdWVuY2U+PC94c2Q6Y29tcGxleFR5cGU+"
		cRet += "PC94c2Q6ZWxlbWVudD48L3hzZDpzZXF1ZW5jZT48L3hzZDpjb21wbGV4VHlwZT48"
		cRet += "L3hzZDplbGVtZW50PjwveHNkOnNjaGVtYT48L3dzZGw6dHlwZXM+PHdzZGw6bWVz"
		cRet += "c2FnZSBuYW1lPSJwdWJsaXNoQ2FuY2VsU2VydmljZSI+PHdzZGw6cGFydCBuYW1l"
		cRet += "PSJwdWJsaXNoQ2FuY2VsU2VydmljZSIJZWxlbWVudD0icDE6cHVibGlzaENhbmNl"
		cRet += "bFNlcnZpY2UiIHhtbG5zOndzZGw9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3Jn"
		cRet += "L3dzZGwvIiAvPjwvd3NkbDptZXNzYWdlPjx3c2RsOm1lc3NhZ2UgbmFtZT0icHVi"
		cRet += "bGlzaENhbmNlbFNlcnZpY2VSZXNwb25zZSI+PHdzZGw6cGFydCBuYW1lPSJwdWJs"
		cRet += "aXNoQ2FuY2VsU2VydmljZVJlc3BvbnNlIgllbGVtZW50PSJwMTpwdWJsaXNoQ2Fu"
		cRet += "Y2VsU2VydmljZVJlc3BvbnNlIiB4bWxuczp3c2RsPSJodHRwOi8vc2NoZW1hcy54"
		cRet += "bWxzb2FwLm9yZy93c2RsLyIgLz48L3dzZGw6bWVzc2FnZT48d3NkbDpwb3J0VHlw"
		cRet += "ZSBuYW1lPSJwdWJsaXNoQ2FuY2VsU2VydmljZVJlcXVlc3QiPjx3c2RsOm9wZXJh"
		cRet += "dGlvbiBuYW1lPSJwdWJsaXNoQ2FuY2VsU2VydmljZVJlcXVlc3QiPjx3c2RsOmlu"
		cRet += "cHV0IG1lc3NhZ2U9InAxOnB1Ymxpc2hDYW5jZWxTZXJ2aWNlIiAvPjx3c2RsOm91"
		cRet += "dHB1dCBtZXNzYWdlPSJwMTpwdWJsaXNoQ2FuY2VsU2VydmljZVJlc3BvbnNlIiAv"
		cRet += "Pjwvd3NkbDpvcGVyYXRpb24+PC93c2RsOnBvcnRUeXBlPjx3c2RsOmJpbmRpbmcg"
		cRet += "bmFtZT0icHVibGlzaENhbmNlbFNlcnZpY2VSZXF1ZXN0QmluZGluZyIJdHlwZT0i"
		cRet += "cDE6cHVibGlzaENhbmNlbFNlcnZpY2VSZXF1ZXN0IiB4bWxuczp3c2RsPSJodHRw"
		cRet += "Oi8vc2NoZW1hcy54bWxzb2FwLm9yZy93c2RsLyI+PHNvYXA6YmluZGluZyBzdHls"
		cRet += "ZT0iZG9jdW1lbnQiCXRyYW5zcG9ydD0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5v"
		cRet += "cmcvc29hcC9odHRwIiB4bWxuczpzb2FwPSJodHRwOi8vc2NoZW1hcy54bWxzb2Fw"
		cRet += "Lm9yZy93c2RsL3NvYXAvIiAvPjx3c2RsOm9wZXJhdGlvbiBuYW1lPSJwdWJsaXNo"
		cRet += "Q2FuY2VsU2VydmljZVJlcXVlc3QiPjxzb2FwOm9wZXJhdGlvbiBzb2FwQWN0aW9u"
		cRet += "PSJodHRwOi8vd3d3Lm5lb2xvZy5jb20uYnIvY3BsL3B1Ymxpc2hpbmcvcmVsZWFz"
		cRet += "ZVRyaXAiCXhtbG5zOnNvYXA9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dz"
		cRet += "ZGwvc29hcC8iIC8+PHdzZGw6aW5wdXQ+PHNvYXA6Ym9keSB1c2U9ImxpdGVyYWwi"
		cRet += "IHhtbG5zOnNvYXA9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvc29h"
		cRet += "cC8iIC8+PC93c2RsOmlucHV0Pjx3c2RsOm91dHB1dD48c29hcDpib2R5IHVzZT0i"
		cRet += "bGl0ZXJhbCIgeG1sbnM6c29hcD0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcv"
		cRet += "d3NkbC9zb2FwLyIgLz48L3dzZGw6b3V0cHV0Pjwvd3NkbDpvcGVyYXRpb24+PC93"
		cRet += "c2RsOmJpbmRpbmc+PHdzZGw6c2VydmljZSBuYW1lPSJwdWJsaXNoQ2FuY2VsU2Vy"
		cRet += "dmljZVJlcXVlc3RTZXJ2aWNlIj48d3NkbDpwb3J0IG5hbWU9InB1Ymxpc2hDYW5j"
		cRet += "ZWxTZXJ2aWNlUmVxdWVzdFBvcnQiCWJpbmRpbmc9InAxOnB1Ymxpc2hDYW5jZWxT"
		cRet += "ZXJ2aWNlUmVxdWVzdEJpbmRpbmciIHhtbG5zOndzZGw9Imh0dHA6Ly9zY2hlbWFz"
		cRet += "LnhtbHNvYXAub3JnL3dzZGwvIj48c29hcDphZGRyZXNzCWxvY2F0aW9uPSJbTE9D"
		cRet += "QVRJT05dIgl4bWxuczpzb2FwPSJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93"
		cRet += "c2RsL3NvYXAvIiAvPjwvd3NkbDpwb3J0Pjwvd3NkbDpzZXJ2aWNlPjwvd3NkbDpk"
		cRet += "ZWZpbml0aW9ucz4="
		cRet := Decode64(cRet)
	EndIf
	
	//Alteração da informação location para o endereço informado na requisição
	If !Empty(cRet) .And. !lAutom
		cRet := LocWsdl(cRet)
	EndIf
Return cRet

Function CancelService(oXmlBody,cConteudo,lAutom)
	Local cRet		:= ""
	Local aRet		:= {}
	Local oRet		:= Nil
	Local lRet		:= .F.
	Local lExecNode := .F.
	Local lRetTol	:= .F.
	Local bErrorF	:= Errorblock({|e| TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + e:DESCRIPTION + CHR(13) + CHR(10) + e:ERRORSTACK + CHR(13) + CHR(10) + e:ERRORENV  ),SetFaultTMS('Falha ambiente',e:DESCRIPTION)})
	Default lAutom	:= .F. //Nao permite execucao de envio soap com automacao

	OsLogCpl("TMSXWS -> CancelService -> Validação no Ambiente","INFO" )

	Begin Sequence
		If nModulo == 39 .And. ExistFunc("OmsCanTrip")
			If lOMSTOL01
				OsLogCpl("TMSXWS -> CancelService -> Inicio execução do Ponto de entrada OMSTOL01.","INFO")
				aRet := ExecBlock("OMSTOL01",.F.,.F.,{@oXmlBody, @cConteudo, "CancelService" } )
				lRet		:= aRet[1] // .T. os processos relacionados a liberação de viagem no Protheus não serão processados -- .F. o processamento da viagem ocorrerá de forma padrão.
				lExecNode	:= aRet[2] // Indica se executa ou não o Nó XML
				oRet		:= aRet[3] // Objeto de Retorno
				lRetTol		:= aRet[4] // Indica para o TOL, se a Viagem será .T. recebida e liberada ou .F. não recebida.
				OsLogCpl("TMSXWS -> CancelService -> Retorno da execução do Ponto de entrada OMSTOL01." + cValToChar(lRet),"INFO")
			EndIf
			If !lRet
				oRet := OmsCanTrip(oXmlBody,@cConteudo)
			EndIf
		EndIf
	End Sequence
	Errorblock(bErrorF)
	
	If lOMSTOL01 .AND. lExecNode .AND. lRet
		cRet += StrTran(__cStrEnv,'/"><', '/" xmlns:ns1="urn:neolog:cockpit:TripCancelRequestService">'+ If( lRetTol, "S", "N" ) + '<')
		cRet += WSSoapValue("ns1:publishCancelServiceResponse", oRet, oRet , "publishCancelServiceResponse", .F. , .F., 0 , NIL, .F.)
	ElseIf !lAutom .And. !lRet
		cRet += StrTran(__cStrEnv,'/"><', '/" xmlns:ns1="urn:neolog:cockpit:TripCancelRequestService">'+ If(lRet,"S","N") + '<')
		cRet += WSSoapValue("ns1:publishCancelServiceResponse", oRet, oRet , "publishCancelServiceResponse", .F. , .F., 0 , NIL, .F.)
	EndIf
	
	cRet += __cEndEnv

	OsLogCpl("TMSXWS -> CancelService -> Fim do processo.","INFO")
	
Return cRet

Function PublishReleasedTrip(oXmlBody,cConteudo)
	Local cRet	:= ""
	Local bErrorF := Errorblock({|e| lRet := .F.,TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + e:DESCRIPTION + CHR(13) + CHR(10) + e:ERRORSTACK + CHR(13) + CHR(10) + e:ERRORENV  ),SetFaultTMS('Falha ambiente',e:DESCRIPTION)})
	Local lRet	:= .F.
	Local aRet	:= {}

	Begin Sequence
		If nModulo == 39 .And. ExistFunc("OmsRecTrip")
			If lOMSTOL01
				OsLogCpl("TMSXWS -> PublishReleasedTrip -> Inicio execução do Ponto de entrada OMSTOL01.","INFO")
				aRet	:= ExecBlock("OMSTOL01",.F.,.F.,{@oXmlBody, @cConteudo, "PublishReleasedTrip"})// aRet[1], Logico / aRet[2], Caracter / aRet[3] Logico, indica se executa ou não o Nó XML
				lRet	:= aRet[1] // .T. os processos relacionados a liberação de viagem no Protheus não serão processados -- .F. o processamento da viagem ocorrerá de forma padrão.
				OsLogCpl("TMSXWS -> PublishReleasedTrip -> Retorno da execução do Ponto de entrada OMSTOL01." + cValToChar(lRet),"INFO")
			EndIf
			If !lRet
				lRet := OmsRecTrip(oXmlBody,@cConteudo)
			EndIf
		EndIf
	End Sequence
	Errorblock(bErrorF)

	cRet += __cStrEnv
	cRet += '<ns1:publishReleasedTripResponse xmlns:ns1="urn:neolog:cockpit:TripReleaseRequestPublishingService">' + If(lRet,"S","N") + '</ns1:publishReleasedTripResponse>'
	cRet += __cEndEnv
Return cRet

Function WsdlPublishReleasedTrip(lAutom)
	Local cRet := ""
	Default lAutom := .F.
	cRet := GetWsdl("publishReleasedTripRequestService")
	If Empty(cRet)
		cRet += "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjx3c2RsOmRlZmluaXRpb25z"
		cRet += "IG5hbWU9InB1Ymxpc2hSZWxlYXNlZFRyaXBSZXF1ZXN0Ig0KICAgIHRhcmdldE5hbWVzcGFjZT0i"
		cRet += "dXJuOm5lb2xvZzpjb2NrcGl0OlRyaXBSZWxlYXNlUmVxdWVzdFB1Ymxpc2hpbmdTZXJ2aWNlIg0K"
		cRet += "ICAgIHhtbG5zOnAxPSJ1cm46bmVvbG9nOmNvY2twaXQ6VHJpcFJlbGVhc2VSZXF1ZXN0UHVibGlz"
		cRet += "aGluZ1NlcnZpY2UiDQogICAgeG1sbnM6d3NkbD0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcv"
		cRet += "d3NkbC8iIHhtbG5zOnhzZD0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEiPg0KICAg"
		cRet += "IDx3c2RsOnR5cGVzPg0KICAgICAgICA8eHNkOnNjaGVtYSB0YXJnZXROYW1lc3BhY2U9InVybjpu"
		cRet += "ZW9sb2c6Y29ja3BpdDpUcmlwUmVsZWFzZVJlcXVlc3RQdWJsaXNoaW5nU2VydmljZSINCiAgICAg"
		cRet += "ICAgICAgIHhtbG5zPSJ1cm46bmVvbG9nOmNvY2twaXQ6VHJpcFJlbGVhc2VSZXF1ZXN0UHVibGlz"
		cRet += "aGluZ1NlcnZpY2UiPiAgICAgICAgICAgIA0KDQoJCQk8IS0tIFJlc3RyacOnw7VlcyBkZSBpZHMg"
		cRet += "U3RyaW5nIC0tPg0KCQkJPHhzZDpzaW1wbGVUeXBlIG5hbWU9InNvdXJjZUlkVHlwZSI+DQoJCQkJ"
		cRet += "PHhzZDpyZXN0cmljdGlvbiBiYXNlPSJ4c2Q6c3RyaW5nIj4NCgkJCQkJPHhzZDp3aGl0ZVNwYWNl"
		cRet += "IHZhbHVlPSJjb2xsYXBzZSIgLz4NCgkJCQkJPHhzZDptaW5MZW5ndGggdmFsdWU9IjEiIC8+DQoJ"
		cRet += "CQkJCTx4c2Q6bWF4TGVuZ3RoIHZhbHVlPSIzMCIgLz4NCgkJCQk8L3hzZDpyZXN0cmljdGlvbj4N"
		cRet += "CgkJCTwveHNkOnNpbXBsZVR5cGU+DQoNCgkJCTwhLS0gUmVzdHJpw6fDtWVzIGRlIGRlc2NyacOn"
		cRet += "w6NvIGNvbSAyNTUgY2hhcnMgLS0+DQoJCQk8eHNkOnNpbXBsZVR5cGUgbmFtZT0iZGVzY3JpcHRp"
		cRet += "b24yNTVUeXBlIj4NCgkJCQk8eHNkOnJlc3RyaWN0aW9uIGJhc2U9InhzZDpzdHJpbmciPg0KCQkJ"
		cRet += "CQk8eHNkOm1heExlbmd0aCB2YWx1ZT0iMjU1IiAvPg0KCQkJCTwveHNkOnJlc3RyaWN0aW9uPg0K"
		cRet += "CQkJPC94c2Q6c2ltcGxlVHlwZT4NCg0KCQkJPCEtLSBSZXN0cmnDp8O1ZXMgZGUgZGVzY3Jpw6fD"
		cRet += "o28gY29tIDUwIGNoYXJzIC0tPg0KCQkJPHhzZDpzaW1wbGVUeXBlIG5hbWU9ImRlc2NyaXB0aW9u"
		cRet += "NTBUeXBlIj4NCgkJCQk8eHNkOnJlc3RyaWN0aW9uIGJhc2U9InhzZDpzdHJpbmciPg0KCQkJCQk8"
		cRet += "eHNkOm1heExlbmd0aCB2YWx1ZT0iNTAiIC8+DQoJCQkJPC94c2Q6cmVzdHJpY3Rpb24+DQoJCQk8"
		cRet += "L3hzZDpzaW1wbGVUeXBlPg0KCQkJDQoJCQk8IS0tIFJlc3RyacOnw7VlcyBkZSBzdHJpbmcgY29t"
		cRet += "IDIgY2hhcnMgLS0+DQoJCQk8eHNkOnNpbXBsZVR5cGUgbmFtZT0ic3RyaW5nMlR5cGUiPg0KCQkJ"
		cRet += "CTx4c2Q6cmVzdHJpY3Rpb24gYmFzZT0ieHNkOnN0cmluZyI+DQoJCQkJCTx4c2Q6bWF4TGVuZ3Ro"
		cRet += "IHZhbHVlPSIyIiAvPg0KCQkJCTwveHNkOnJlc3RyaWN0aW9uPg0KCQkJPC94c2Q6c2ltcGxlVHlw"
		cRet += "ZT4NCgkJCQ0KCQkJPCEtLSBSZXN0cmnDp8O1ZXMgZGUgc3RyaW5nIGNvbSAxMCBjaGFycyAtLT4N"
		cRet += "CgkJCTx4c2Q6c2ltcGxlVHlwZSBuYW1lPSJzdHJpbmcxMFR5cGUiPg0KCQkJCTx4c2Q6cmVzdHJp"
		cRet += "Y3Rpb24gYmFzZT0ieHNkOnN0cmluZyI+DQoJCQkJCTx4c2Q6bWF4TGVuZ3RoIHZhbHVlPSIxMCIg"
		cRet += "Lz4NCgkJCQk8L3hzZDpyZXN0cmljdGlvbj4NCgkJCTwveHNkOnNpbXBsZVR5cGU+DQoNCgkJCTwh"
		cRet += "LS0gUmVzdHJpw6fDtWVzIGRlIGlkcyBJbnRlZ2VyIC0tPg0KCQkJPHhzZDpzaW1wbGVUeXBlIG5h"
		cRet += "bWU9ImlkSW50VHlwZSI+DQoJCQkJPHhzZDpyZXN0cmljdGlvbiBiYXNlPSJ4c2Q6aW50ZWdlciI+"
		cRet += "DQoJCQkJCTx4c2Q6bWluRXhjbHVzaXZlIHZhbHVlPSIwIiAvPg0KCQkJCQk8eHNkOm1heEV4Y2x1"
		cRet += "c2l2ZSB2YWx1ZT0iMTAwMDAwMDAwMDAiIC8+DQoJCQkJPC94c2Q6cmVzdHJpY3Rpb24+DQoJCQk8"
		cRet += "L3hzZDpzaW1wbGVUeXBlPg0KDQoJCQk8IS0tIFJlc3RyacOnw7VlcyBkZSB2YWxvcmVzIGludGVp"
		cRet += "cm9zIHBvc2l0aXZvcyAtLT4NCgkJCTx4c2Q6c2ltcGxlVHlwZSBuYW1lPSJwb3NpdGl2ZUludFR5"
		cRet += "cGUiPg0KCQkJCTx4c2Q6cmVzdHJpY3Rpb24gYmFzZT0ieHNkOmludGVnZXIiPg0KCQkJCQk8eHNk"
		cRet += "Om1pbkV4Y2x1c2l2ZSB2YWx1ZT0iMCIgLz4NCgkJCQkJPHhzZDptYXhFeGNsdXNpdmUgdmFsdWU9"
		cRet += "IjEwMDAwMDAwMDAwIiAvPg0KCQkJCTwveHNkOnJlc3RyaWN0aW9uPg0KCQkJPC94c2Q6c2ltcGxl"
		cRet += "VHlwZT4NCg0KCQkJPCEtLSBSZXN0cmnDp8O1ZXMgZGUgcXVhbnRpZGFkZXMgRmxvYXQgLS0+DQoJ"
		cRet += "CQk8eHNkOnNpbXBsZVR5cGUgbmFtZT0icG9zaXRpdmVGbG9hdFR5cGUiPg0KCQkJCTx4c2Q6cmVz"
		cRet += "dHJpY3Rpb24gYmFzZT0ieHNkOmZsb2F0Ij4NCgkJCQkJPHhzZDptaW5JbmNsdXNpdmUgdmFsdWU9"
		cRet += "IjAiIC8+DQoJCQkJPC94c2Q6cmVzdHJpY3Rpb24+DQoJCQk8L3hzZDpzaW1wbGVUeXBlPg0KDQoJ"
		cRet += "CQk8IS0tIFJlc3RyacOnw6NvIGRlIG1vZG8gZGUgY2FycmVnYW1lbnRvIChlbnVtKSAtLT4NCgkJ"
		cRet += "CTx4c2Q6c2ltcGxlVHlwZSBuYW1lPSJsb2FkTW9kZUVudW0iPg0KCQkJCTx4c2Q6cmVzdHJpY3Rp"
		cRet += "b24gYmFzZT0ieHNkOmludGVnZXIiPg0KCQkJCQk8eHNkOm1pbkluY2x1c2l2ZSB2YWx1ZT0iMSIg"
		cRet += "Lz4NCgkJCQkJPHhzZDptYXhJbmNsdXNpdmUgdmFsdWU9IjMiIC8+DQoJCQkJPC94c2Q6cmVzdHJp"
		cRet += "Y3Rpb24+DQoJCQk8L3hzZDpzaW1wbGVUeXBlPg0KDQoJCQk8IS0tIFJlc3RyacOnw6NvIGRlIG1v"
		cRet += "ZGFpcyAoZW51bSkgLS0+DQoJCQk8eHNkOnNpbXBsZVR5cGUgbmFtZT0ibW9kYWxFbnVtIj4NCgkJ"
		cRet += "CQk8eHNkOnJlc3RyaWN0aW9uIGJhc2U9InhzZDppbnRlZ2VyIj4NCgkJCQkJPHhzZDptaW5JbmNs"
		cRet += "dXNpdmUgdmFsdWU9IjEiIC8+DQoJCQkJCTx4c2Q6bWF4SW5jbHVzaXZlIHZhbHVlPSI0IiAvPg0K"
		cRet += "CQkJCTwveHNkOnJlc3RyaWN0aW9uPg0KCQkJPC94c2Q6c2ltcGxlVHlwZT4NCg0KCQkJPCEtLSBE"
		cRet += "ZWZpbmnDp8OjbyBkbyB0aXBvIFNoaXBtZW50VW5pdCAtLT4NCgkJCTx4c2Q6Y29tcGxleFR5cGUg"
		cRet += "bmFtZT0ic2hpcG1lbnRVbml0Ij4NCgkJCQk8eHNkOnNlcXVlbmNlPg0KCQkJCQk8eHNkOmVsZW1l"
		cRet += "bnQgbmFtZT0iaWRlbnRpZmllciIgdHlwZT0iaWRJbnRUeXBlIg0KCQkJCQkJbWluT2NjdXJzPSIx"
		cRet += "IiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+"
		cRet += "DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5i"
		cRet += "MDA5Njg5ODJlYzAxMWUwY2NlODU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJ"
		cRet += "CQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVs"
		cRet += "ZW1lbnQgbmFtZT0ic2hpcG1lbnRVbml0Q2F0ZWdvcnlJZCIgdHlwZT0iaWRJbnRUeXBlIg0KCQkJ"
		cRet += "CQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8"
		cRet += "eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5j"
		cRet += "b20veGkvVGV4dElEIj5iMDA5Njg5ODJlYzAxMWUwY2NlODU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwv"
		cRet += "eHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50"
		cRet += "Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0ic2hpcG1lbnRVbml0RGVzY3JpcHRpb24iIHR5cGU9"
		cRet += "ImRlc2NyaXB0aW9uMjU1VHlwZSINCgkJCQkJCW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSIxIj4N"
		cRet += "CgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRw"
		cRet += "Oi8vc2FwLmNvbS94aS9UZXh0SUQiPjE5YTAwNTYwNTk3ODExZTBhMDA2NTQ0YjdjNWQ0ODEwDQoJ"
		cRet += "CQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNk"
		cRet += "OmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJzaGlwbWVudFVuaXRRdHkiIHR5cGU9"
		cRet += "InBvc2l0aXZlRmxvYXRUeXBlIg0KCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5p"
		cRet += "bGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBp"
		cRet += "bmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj4xOWEwMDU2MDU5NzgxMWUwYTAw"
		cRet += "NjU0NGI3YzVkNDgxMA0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0"
		cRet += "aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0id2VpZ2h0"
		cRet += "IiB0eXBlPSJwb3NpdGl2ZUZsb2F0VHlwZSINCgkJCQkJCW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJz"
		cRet += "PSIxIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNl"
		cRet += "PSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk4Zjk2MmVjMDExZTA5MWRmNTQxZjUxOTJh"
		cRet += "NjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJ"
		cRet += "CTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJ2b2x1bWUiIHR5cGU9InBv"
		cRet += "c2l0aXZlRmxvYXRUeXBlIg0KCQkJCQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiPg0KCQkJ"
		cRet += "CQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9z"
		cRet += "YXAuY29tL3hpL1RleHRJRCI+YjAwOThmOTYyZWMwMTFlMDkxZGY1NDFmNTE5MmE2MTUNCgkJCQkJ"
		cRet += "CQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxl"
		cRet += "bWVudD4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9Imxlbmd0aCIgdHlwZT0icG9zaXRpdmVGbG9h"
		cRet += "dFR5cGUiDQoJCQkJCQltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSI+DQoJCQkJCQk8eHNkOmFu"
		cRet += "bm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkv"
		cRet += "VGV4dElEIj5iMDA5Njg5NTJlYzAxMWUwOTNkNTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFw"
		cRet += "cGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJ"
		cRet += "CQk8eHNkOmVsZW1lbnQgbmFtZT0id2lkdGgiIHR5cGU9InBvc2l0aXZlRmxvYXRUeXBlIg0KCQkJ"
		cRet += "CQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0K"
		cRet += "CQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAw"
		cRet += "OTY4OTUyZWMwMTFlMDkzZDU1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJ"
		cRet += "CQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVt"
		cRet += "ZW50IG5hbWU9ImhlaWdodCIgdHlwZT0icG9zaXRpdmVGbG9hdFR5cGUiDQoJCQkJCQltaW5PY2N1"
		cRet += "cnM9IjAiIG1heE9jY3Vycz0iMSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhz"
		cRet += "ZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg5NTJlYzAx"
		cRet += "MWUwOTNkNTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDph"
		cRet += "bm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0i"
		cRet += "cGFsbGV0SGVpZ2h0VG90YWwiIHR5cGU9InBvc2l0aXZlRmxvYXRUeXBlIg0KCQkJCQkJbWluT2Nj"
		cRet += "dXJzPSIwIiBtYXhPY2N1cnM9IjEiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4"
		cRet += "c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOThmOTYyZWMw"
		cRet += "MTFlMDkxZGY1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6"
		cRet += "YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9"
		cRet += "ImRlbGl2ZXJ5VW5pdExpc3QiIG1pbk9jY3Vycz0iMSINCgkJCQkJCW1heE9jY3Vycz0iMSIgbmls"
		cRet += "bGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGlu"
		cRet += "Zm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2ODk1MmVjMDExZTA5M2Q1"
		cRet += "NTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRp"
		cRet += "b24+DQoJCQkJCQk8eHNkOmNvbXBsZXhUeXBlPg0KCQkJCQkJCTx4c2Q6c2VxdWVuY2U+DQoJCQkJ"
		cRet += "CQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJkZWxpdmVyeVVuaXQiIHR5cGU9ImRlbGl2ZXJ5VW5pdCIN"
		cRet += "CgkJCQkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSJ1bmJvdW5kZWQiIG5pbGxhYmxlPSJm"
		cRet += "YWxzZSIgLz4NCgkJCQkJCQk8L3hzZDpzZXF1ZW5jZT4NCgkJCQkJCTwveHNkOmNvbXBsZXhUeXBl"
		cRet += "Pg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCTwveHNkOnNlcXVlbmNlPg0KCQkJPC94c2Q6Y29t"
		cRet += "cGxleFR5cGU+DQoJCQkNCgkJCTwhLS0gRGVmaW5pw6fDo28gZG8gdGlwbyBjbGFzc2lmaWNhdGlv"
		cRet += "bnMgLS0+DQoJCQk8eHNkOmNvbXBsZXhUeXBlIG5hbWU9ImNsYXNzaWZpY2F0aW9ucyI+DQoJCQkJ"
		cRet += "PHhzZDpzZXF1ZW5jZT4NCgkJCQkJPHhzZDplbGVtZW50IG1heE9jY3Vycz0idW5ib3VuZGVkIiBt"
		cRet += "aW5PY2N1cnM9IjEiIG5hbWU9ImNsYXNzaWZpY2F0aW9uIj4NCgkJCQkJCTx4c2Q6Y29tcGxleFR5"
		cRet += "cGU+DQoJCQkJCQkJPHhzZDpzZXF1ZW5jZT4JCQkNCgkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9"
		cRet += "InR5cGUiIHR5cGU9ImRlc2NyaXB0aW9uMjU1VHlwZSINCgkJCQkJCQkJCW1pbk9jY3Vycz0iMSIg"
		cRet += "bWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9u"
		cRet += "Pg0KCQkJCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJ"
		cRet += "RCI+YjAwOTY4OTgyZWMwMTFlMGNjZTg1NDFmNTE5MmE2MTUNCgkJCQkJCQkJCQk8L3hzZDphcHBp"
		cRet += "bmZvPg0KCQkJCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJPC94c2Q6ZWxlbWVudD4J"
		cRet += "DQoJCQkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJ2YWx1ZSIgdHlwZT0iZGVzY3JpcHRpb24yNTVU"
		cRet += "eXBlIg0KCQkJCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxz"
		cRet += "ZSI+DQoJCQkJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJPHhzZDphcHBpbmZvIHNv"
		cRet += "dXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg5ODJlYzAxMWUwY2NlODU0MWY1"
		cRet += "MTkyYTYxNQ0KCQkJCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQkJCQk8L3hzZDphbm5vdGF0"
		cRet += "aW9uPg0KCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCTwveHNkOnNlcXVlbmNlPg0KCQkJ"
		cRet += "CQkJPC94c2Q6Y29tcGxleFR5cGU+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJPC94c2Q6c2Vx"
		cRet += "dWVuY2U+DQoJCQk8L3hzZDpjb21wbGV4VHlwZT4NCgkJCQ0KCQkJPCEtLSBEZWZpbmnDp8OjbyBk"
		cRet += "byB0aXBvIGF0dHJpYnV0ZXMgLS0+DQoJCQk8eHNkOmNvbXBsZXhUeXBlIG5hbWU9ImF0dHJpYnV0"
		cRet += "ZXMiPg0KCQkJCTx4c2Q6c2VxdWVuY2U+DQoJCQkJCTx4c2Q6ZWxlbWVudCBtYXhPY2N1cnM9InVu"
		cRet += "Ym91bmRlZCIgbWluT2NjdXJzPSIxIiBuYW1lPSJhdHRyaWJ1dGUiPg0KCQkJCQkJPHhzZDpjb21w"
		cRet += "bGV4VHlwZT4NCgkJCQkJCQk8eHNkOnNlcXVlbmNlPgkJCQ0KCQkJCQkJCQk8eHNkOmVsZW1lbnQg"
		cRet += "bmFtZT0ibmFtZSIgdHlwZT0iZGVzY3JpcHRpb24yNTVUeXBlIg0KCQkJCQkJCQkJbWluT2NjdXJz"
		cRet += "PSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQkJCQk8eHNkOmFubm90"
		cRet += "YXRpb24+DQoJCQkJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkv"
		cRet += "VGV4dElEIj5iMDA5Njg5ODJlYzAxMWUwY2NlODU0MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCTwveHNk"
		cRet += "OmFwcGluZm8+DQoJCQkJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQk8L3hzZDplbGVt"
		cRet += "ZW50PgkNCgkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9InZhbHVlIiB0eXBlPSJkZXNjcmlwdGlv"
		cRet += "bjI1NVR5cGUiDQoJCQkJCQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9"
		cRet += "ImZhbHNlIj4NCgkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQk8eHNkOmFwcGlu"
		cRet += "Zm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2ODk4MmVjMDExZTBjY2U4"
		cRet += "NTQxZjUxOTJhNjE1DQoJCQkJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCQkJCTwveHNkOmFu"
		cRet += "bm90YXRpb24+DQoJCQkJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCQkJPC94c2Q6c2VxdWVuY2U+"
		cRet += "DQoJCQkJCQk8L3hzZDpjb21wbGV4VHlwZT4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQk8L3hz"
		cRet += "ZDpzZXF1ZW5jZT4NCgkJCTwveHNkOmNvbXBsZXhUeXBlPgkNCgkJCQkJCQkJCQkJDQoNCgkJCTwh"
		cRet += "LS0gRGVmaW5pw6fDo28gZG8gdGlwbyBEZWxpdmVyeVVuaXQgLS0+DQoJCQk8eHNkOmNvbXBsZXhU"
		cRet += "eXBlIG5hbWU9ImRlbGl2ZXJ5VW5pdCI+DQoJCQkJPHhzZDpzZXF1ZW5jZT4NCgkJCQkJPHhzZDpl"
		cRet += "bGVtZW50IG5hbWU9ImlkZW50aWZpZXIiIHR5cGU9InNvdXJjZUlkVHlwZSINCgkJCQkJCW1pbk9j"
		cRet += "Y3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhzZDphbm5v"
		cRet += "dGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1Rl"
		cRet += "eHRJRCI+YjAwOTY4OTgyZWMwMTFlMGNjZTg1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBp"
		cRet += "bmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJ"
		cRet += "PHhzZDplbGVtZW50IG5hbWU9Im9yZGVyU291cmNlSWQiIHR5cGU9InNvdXJjZUlkVHlwZSINCgkJ"
		cRet += "CQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJ"
		cRet += "PHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAu"
		cRet += "Y29tL3hpL1RleHRJRCI+YjAwOThmOTAyZWMwMTFlMDkyNTU1NDFmNTE5MmE2MTUNCgkJCQkJCQk8"
		cRet += "L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVu"
		cRet += "dD4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9Im9yZGVyVHlwZVNvdXJjZUlkIiB0eXBlPSJzb3Vy"
		cRet += "Y2VJZFR5cGUiDQoJCQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZh"
		cRet += "bHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNl"
		cRet += "PSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk4ZjkwMmVjMDExZTA5MjU1NTQxZjUxOTJh"
		cRet += "NjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJ"
		cRet += "CTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJvcmRlckl0ZW1Tb3VyY2VJ"
		cRet += "ZCIgdHlwZT0ic291cmNlSWRUeXBlIg0KCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEi"
		cRet += "IG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDph"
		cRet += "cHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5OGY5MTJlYzAxMWUw"
		cRet += "ODQ4MTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5v"
		cRet += "dGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0icHJv"
		cRet += "ZHVjdFNvdXJjZUlkIiB0eXBlPSJzb3VyY2VJZFR5cGUiDQoJCQkJCQltaW5PY2N1cnM9IjEiIG1h"
		cRet += "eE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJ"
		cRet += "CQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk4"
		cRet += "ZjkzMmVjMDExZTA4MjVjNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJ"
		cRet += "CTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVu"
		cRet += "dCBuYW1lPSJzZXF1ZW5jZUNvbXBvc2l0aW9uIiB0eXBlPSJwb3NpdGl2ZUludFR5cGUiDQoJCQkJ"
		cRet += "CQltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJ"
		cRet += "CQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5"
		cRet += "OGY5MzJlYzAxMWUwODI1YzU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJ"
		cRet += "CQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50PgkJCQkJDQoJCQkJCTx4c2Q6"
		cRet += "ZWxlbWVudCBuYW1lPSJxdWFudGl0eSIgdHlwZT0icG9zaXRpdmVGbG9hdFR5cGUiDQoJCQkJCQlt"
		cRet += "aW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6"
		cRet += "YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94"
		cRet += "aS9UZXh0SUQiPmIwMDk4Zjk0MmVjMDExZTA5MGYzNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6"
		cRet += "YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJ"
		cRet += "CQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJwcmljZSIgdHlwZT0icG9zaXRpdmVGbG9hdFR5cGUiDQoJ"
		cRet += "CQkJCQltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+"
		cRet += "DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5i"
		cRet += "MDA5OGY5MjJlYzAxMWUwYzNkNDU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJ"
		cRet += "CQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVs"
		cRet += "ZW1lbnQgbmFtZT0iZGVsaXZlcnlEYXRlIiB0eXBlPSJ4c2Q6ZGF0ZVRpbWUiDQoJCQkJCQltaW5P"
		cRet += "Y2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5u"
		cRet += "b3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9U"
		cRet += "ZXh0SUQiPmIwMDk2ODk3MmVjMDExZTA5YjA0NTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBw"
		cRet += "aW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJ"
		cRet += "CTx4c2Q6ZWxlbWVudCBuYW1lPSJpbnRlZ3JhdGlvblNvdXJjZSIgdHlwZT0ic291cmNlSWRUeXBl"
		cRet += "Ig0KCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJ"
		cRet += "CQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDov"
		cRet += "L3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg5OTJlYzAxMWUwOTVjMDU0MWY1MTkyYTYxNQ0KCQkJ"
		cRet += "CQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDpl"
		cRet += "bGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0iY2xhc3NpZmljYXRpb25zIiB0eXBlPSJj"
		cRet += "bGFzc2lmaWNhdGlvbnMiDQoJCQkJCQltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSIgbmlsbGFi"
		cRet += "bGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8g"
		cRet += "c291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk0MTc3MmVjMDExZTBhOGNlNTQx"
		cRet += "ZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+"
		cRet += "DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJhdHRyaWJ1dGVz"
		cRet += "IiB0eXBlPSJhdHRyaWJ1dGVzIg0KCQkJCQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiIG5p"
		cRet += "bGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBp"
		cRet += "bmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5NDE3NzJlYzAxMWUwYThj"
		cRet += "ZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0"
		cRet += "aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50PgkNCgkJCQk8L3hzZDpzZXF1ZW5jZT4NCgkJCTwveHNk"
		cRet += "OmNvbXBsZXhUeXBlPg0KDQoJCQk8IS0tIERlZmluacOnw6NvIGRvIHRpcG8gU3RvcCAtLT4NCgkJ"
		cRet += "CTx4c2Q6Y29tcGxleFR5cGUgbmFtZT0ic3RvcCI+DQoJCQkJPHhzZDpzZXF1ZW5jZT4NCgkJCQkJ"
		cRet += "PHhzZDplbGVtZW50IG5hbWU9ImlkZW50aWZpZXIiIHR5cGU9ImlkSW50VHlwZSINCgkJCQkJCW1p"
		cRet += "bk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhzZDph"
		cRet += "bm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hp"
		cRet += "L1RleHRJRCI+YjAwOTY4OTQyZWMwMTFlMGJjODc1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDph"
		cRet += "cHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJ"
		cRet += "CQkJPHhzZDplbGVtZW50IG5hbWU9ImxvY2FsaXR5U291cmNlSWQiIHR5cGU9InNvdXJjZUlkVHlw"
		cRet += "ZSINCgkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0K"
		cRet += "CQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6"
		cRet += "Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOThmOTcyZWMwMTFlMGExZWU1NDFmNTE5MmE2MTUNCgkJ"
		cRet += "CQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6"
		cRet += "ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9InRyYW5zcG9ydFpvbmVJZCIgdHlwZT0i"
		cRet += "c291cmNlSWRUeXBlIg0KCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxl"
		cRet += "PSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNv"
		cRet += "dXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5OGY5NzJlYzAxMWUwYTFlZTU0MWY1"
		cRet += "MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0K"
		cRet += "CQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0idHJhbnNwb3J0Wm9u"
		cRet += "ZURlc2NyaXB0aW9uIiB0eXBlPSJkZXNjcmlwdGlvbjUwVHlwZSINCgkJCQkJCW1pbk9jY3Vycz0i"
		cRet += "MCIgbWF4T2NjdXJzPSIxIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFw"
		cRet += "cGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk4Zjk3MmVjMDExZTBh"
		cRet += "MWVlNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90"
		cRet += "YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJzZXF1"
		cRet += "ZW5jZU9uTG9hZCIgdHlwZT0icG9zaXRpdmVJbnRUeXBlIg0KCQkJCQkJbWluT2NjdXJzPSIxIiBt"
		cRet += "YXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJ"
		cRet += "CQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5"
		cRet += "OGY5ODJlYzAxMWUwY2E5ZDU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJ"
		cRet += "CQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1l"
		cRet += "bnQgbmFtZT0iY2xhc3NpZmljYXRpb25zIiB0eXBlPSJjbGFzc2lmaWNhdGlvbnMiDQoJCQkJCQlt"
		cRet += "aW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6"
		cRet += "YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94"
		cRet += "aS9UZXh0SUQiPmIwMDk0MTc3MmVjMDExZTBhOGNlNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6"
		cRet += "YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJ"
		cRet += "CQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJhdHRyaWJ1dGVzIiB0eXBlPSJhdHRyaWJ1dGVzIg0KCQkJ"
		cRet += "CQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8"
		cRet += "eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5j"
		cRet += "b20veGkvVGV4dElEIj5iMDA5NDE3NzJlYzAxMWUwYThjZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwv"
		cRet += "eHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50"
		cRet += "Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0ic3ViU3RvcHMiPg0KCQkJCQkJPHhzZDpjb21wbGV4"
		cRet += "VHlwZT4NCgkJCQkJCQk8eHNkOnNlcXVlbmNlPg0KCQkJCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0i"
		cRet += "c3ViU3RvcCIgdHlwZT0ic3ViU3RvcCINCgkJCQkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJz"
		cRet += "PSJ1bmJvdW5kZWQiIG5pbGxhYmxlPSJmYWxzZSIgPg0KCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9u"
		cRet += "Pg0KCQkJCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJ"
		cRet += "RCI+YjAwOThmOTgyZWMwMTFlMGNhOWQ1NDFmNTE5MmE2MTUNCgkJCQkJCQkJCQk8L3hzZDphcHBp"
		cRet += "bmZvPg0KCQkJCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJPC94c2Q6ZWxlbWVudD4N"
		cRet += "CgkJCQkJCQk8L3hzZDpzZXF1ZW5jZT4NCgkJCQkJCTwveHNkOmNvbXBsZXhUeXBlPg0KCQkJCQk8"
		cRet += "L3hzZDplbGVtZW50Pg0KCQkJCTwveHNkOnNlcXVlbmNlPg0KCQkJPC94c2Q6Y29tcGxleFR5cGU+"
		cRet += "DQoJCQkNCgkJCTwhLS0gRGVmaW5pw6fDo28gZG8gdGlwbyBTdWJTdG9wIC0tPg0KCQkJPHhzZDpj"
		cRet += "b21wbGV4VHlwZSBuYW1lPSJzdWJTdG9wIj4NCgkJCQk8eHNkOnNlcXVlbmNlPg0KCQkJCQk8eHNk"
		cRet += "OmVsZW1lbnQgbmFtZT0iaWRlbnRpZmllciIgdHlwZT0iaWRJbnRUeXBlIg0KCQkJCQkJbWluT2Nj"
		cRet += "dXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90"
		cRet += "YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4"
		cRet += "dElEIj5iMDA5Njg5NDJlYzAxMWUwYmM4NzU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGlu"
		cRet += "Zm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8"
		cRet += "eHNkOmVsZW1lbnQgbmFtZT0iYXJyaXZhbFRpbWUiIHR5cGU9InhzZDpkYXRlVGltZSINCgkJCQkJ"
		cRet += "CW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhz"
		cRet += "ZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29t"
		cRet += "L3hpL1RleHRJRCI+YjAwOTY4OTIyZWMwMTFlMDkzZGI1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hz"
		cRet += "ZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4N"
		cRet += "CgkJCQkJPHhzZDplbGVtZW50IG5hbWU9InN0YXJ0U2VydmljZVRpbWUiIHR5cGU9InhzZDpkYXRl"
		cRet += "VGltZSINCgkJCQkJCW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSIxIj4NCgkJCQkJCTx4c2Q6YW5u"
		cRet += "b3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9U"
		cRet += "ZXh0SUQiPmIwMDk4Zjk5MmVjMDExZTA5NmU5NTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBw"
		cRet += "aW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJ"
		cRet += "CTx4c2Q6ZWxlbWVudCBuYW1lPSJlbmRTZXJ2aWNlVGltZSIgdHlwZT0ieHNkOmRhdGVUaW1lIg0K"
		cRet += "CQkJCQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9u"
		cRet += "Pg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+"
		cRet += "YjAwOThmOTkyZWMwMTFlMDk2ZTk1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0K"
		cRet += "CQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDpl"
		cRet += "bGVtZW50IG5hbWU9ImRlcGFydHVyZVRpbWUiIHR5cGU9InhzZDpkYXRlVGltZSINCgkJCQkJCW1p"
		cRet += "bk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhzZDph"
		cRet += "bm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hp"
		cRet += "L1RleHRJRCI+YjAwOTY4OTMyZWMwMTFlMDk5MTU1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDph"
		cRet += "cHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJ"
		cRet += "CQkJPHhzZDplbGVtZW50IG5hbWU9ImRvY2tJZCIgdHlwZT0ic291cmNlSWRUeXBlIg0KCQkJCQkJ"
		cRet += "bWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJ"
		cRet += "CQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOThm"
		cRet += "OTkyZWMwMTFlMDk2ZTk1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJ"
		cRet += "PC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVtZW50"
		cRet += "IG5hbWU9ImRvY2tEZXNjcmlwdGlvbiIgdHlwZT0iZGVzY3JpcHRpb24yNTVUeXBlIg0KCQkJCQkJ"
		cRet += "bWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJ"
		cRet += "CQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOThm"
		cRet += "OTkyZWMwMTFlMDk2ZTk1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJ"
		cRet += "PC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVtZW50"
		cRet += "IG5hbWU9ImNsYXNzaWZpY2F0aW9ucyIgdHlwZT0iY2xhc3NpZmljYXRpb25zIg0KCQkJCQkJbWlu"
		cRet += "T2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFu"
		cRet += "bm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkv"
		cRet += "VGV4dElEIj5iMDA5NDE3NzJlYzAxMWUwYThjZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFw"
		cRet += "cGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJ"
		cRet += "CQk8eHNkOmVsZW1lbnQgbmFtZT0iYXR0cmlidXRlcyIgdHlwZT0iYXR0cmlidXRlcyINCgkJCQkJ"
		cRet += "CW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhz"
		cRet += "ZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29t"
		cRet += "L3hpL1RleHRJRCI+YjAwOTQxNzcyZWMwMTFlMGE4Y2U1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hz"
		cRet += "ZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4N"
		cRet += "CgkJCQkJPHhzZDplbGVtZW50IG5hbWU9ImxvYWRlZFNoaXBtZW50VW5pdHMiIG1pbk9jY3Vycz0i"
		cRet += "MCINCgkJCQkJCW1heE9jY3Vycz0iMSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJ"
		cRet += "PHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg5NTJl"
		cRet += "YzAxMWUwOTNkNTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hz"
		cRet += "ZDphbm5vdGF0aW9uPg0KCQkJCQkJPHhzZDpjb21wbGV4VHlwZT4NCgkJCQkJCQk8eHNkOnNlcXVl"
		cRet += "bmNlPg0KCQkJCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0ic2hpcG1lbnRVbml0IiB0eXBlPSJzaGlw"
		cRet += "bWVudFVuaXQiDQoJCQkJCQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0idW5ib3VuZGVkIiBu"
		cRet += "aWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQkJCTx4"
		cRet += "c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOThmOWEyZWMw"
		cRet += "MTFlMGIxNjQ1NDFmNTE5MmE2MTUNCgkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJ"
		cRet += "PC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJCQk8L3hzZDpz"
		cRet += "ZXF1ZW5jZT4NCgkJCQkJCTwveHNkOmNvbXBsZXhUeXBlPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0K"
		cRet += "CQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0idW5sb2FkZWRTaGlwbWVudFVuaXRzIiBtaW5PY2N1cnM9"
		cRet += "IjAiDQoJCQkJCQltYXhPY2N1cnM9IjEiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJ"
		cRet += "CTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOThmOWEy"
		cRet += "ZWMwMTFlMGIxNjQ1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94"
		cRet += "c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCTx4c2Q6Y29tcGxleFR5cGU+DQoJCQkJCQkJPHhzZDpzZXF1"
		cRet += "ZW5jZT4NCgkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9InNoaXBtZW50VW5pdCIgdHlwZT0ic2hp"
		cRet += "cG1lbnRVbml0Ig0KCQkJCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9InVuYm91bmRlZCIg"
		cRet += "bmlsbGFibGU9ImZhbHNlIiAvPg0KCQkJCQkJCTwveHNkOnNlcXVlbmNlPg0KCQkJCQkJPC94c2Q6"
		cRet += "Y29tcGxleFR5cGU+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJPC94c2Q6c2VxdWVuY2U+DQoJ"
		cRet += "CQk8L3hzZDpjb21wbGV4VHlwZT4NCg0KCQkJPCEtLSBEZWZpbmnDp8OjbyBkbyB0aXBvIExvYWQg"
		cRet += "LS0+DQoJCQk8eHNkOmNvbXBsZXhUeXBlIG5hbWU9ImxvYWQiPg0KCQkJCTx4c2Q6c2VxdWVuY2U+"
		cRet += "DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJpZGVudGlmaWVyIiB0eXBlPSJpZEludFR5cGUiDQoJ"
		cRet += "CQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJ"
		cRet += "CTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2Fw"
		cRet += "LmNvbS94aS9UZXh0SUQiPmIwMDk2ODhiMmVjMDExZTBhN2FiNTQxZjUxOTJhNjE1DQoJCQkJCQkJ"
		cRet += "PC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1l"
		cRet += "bnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJzZXJ2aWNlVHlwZUlkIiB0eXBlPSJpZEludFR5"
		cRet += "cGUiDQoJCQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4N"
		cRet += "CgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRw"
		cRet += "Oi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2ODhmMmVjMDExZTA4YzczNTQxZjUxOTJhNjE1DQoJ"
		cRet += "CQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNk"
		cRet += "OmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJzZXJ2aWNlVHlwZURlc2NyaXB0aW9u"
		cRet += "IiB0eXBlPSJkZXNjcmlwdGlvbjI1NVR5cGUiDQoJCQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vy"
		cRet += "cz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8"
		cRet += "eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2ODhlMmVj"
		cRet += "MDExZTA4MjEwNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNk"
		cRet += "OmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1l"
		cRet += "PSJsb2FkTW9kZSIgdHlwZT0ibG9hZE1vZGVFbnVtIg0KCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhP"
		cRet += "Y2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJ"
		cRet += "CQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4"
		cRet += "YzJlYzAxMWUwYzRlYzU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8"
		cRet += "L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQg"
		cRet += "bmFtZT0ibW9kYWwiIHR5cGU9Im1vZGFsRW51bSIgbWluT2NjdXJzPSIxIg0KCQkJCQkJbWF4T2Nj"
		cRet += "dXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJ"
		cRet += "CTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOTY4OGQy"
		cRet += "ZWMwMTFlMGE1N2I1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94"
		cRet += "c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVtZW50IG5h"
		cRet += "bWU9ImRpc3RhbmNlIiB0eXBlPSJwb3NpdGl2ZUZsb2F0VHlwZSINCgkJCQkJCW1pbk9jY3Vycz0i"
		cRet += "MSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9u"
		cRet += "Pg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+"
		cRet += "YjAwOTY4ODkyZWMwMTFlMGIxMDM1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0K"
		cRet += "CQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDpl"
		cRet += "bGVtZW50IG5hbWU9ImZyZWlnaHQiIHR5cGU9InBvc2l0aXZlRmxvYXRUeXBlIg0KCQkJCQkJbWlu"
		cRet += "T2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQk8eHNkOmFu"
		cRet += "bm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkv"
		cRet += "VGV4dElEIj5iMDA5Njg5MzJlYzAxMWUwOTkxNTU0MWY1MTkyYTYxNQ0KCQkJCQkJCTwveHNkOmFw"
		cRet += "cGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJ"
		cRet += "CQk8eHNkOmVsZW1lbnQgbmFtZT0iZGlzcGF0Y2hMaW1pdFRpbWUiIHR5cGU9InhzZDpkYXRlVGlt"
		cRet += "ZSINCgkJCQkJCW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSIxIj4NCgkJCQkJCTx4c2Q6YW5ub3Rh"
		cRet += "dGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0"
		cRet += "SUQiPmIwMDk2ODkzMmVjMDExZTA5OTE1NTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5m"
		cRet += "bz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4"
		cRet += "c2Q6ZWxlbWVudCBuYW1lPSJzdG9wcyIgbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiDQoJCQkJ"
		cRet += "CQluaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6"
		cRet += "YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOTY4OTAyZWMwMTFl"
		cRet += "MGIzNWI1NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5u"
		cRet += "b3RhdGlvbj4NCgkJCQkJCTx4c2Q6Y29tcGxleFR5cGU+DQoJCQkJCQkJPHhzZDpzZXF1ZW5jZT4N"
		cRet += "CgkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9InN0b3AiIHR5cGU9InN0b3AiIG1pbk9jY3Vycz0i"
		cRet += "MiINCgkJCQkJCQkJCW1heE9jY3Vycz0idW5ib3VuZGVkIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJ"
		cRet += "CQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCTwveHNkOnNlcXVlbmNlPg0KCQkJCQkJPC94c2Q6"
		cRet += "Y29tcGxleFR5cGU+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJPC94c2Q6c2VxdWVuY2U+DQoJ"
		cRet += "CQk8L3hzZDpjb21wbGV4VHlwZT4NCg0KCQkJPCEtLSBEZWZpbmnDp8OjbyBkbyB0aXBvIE9yZGVy"
		cRet += "QnJlYWtQYXJ0IC0tPg0KCQkJPHhzZDpjb21wbGV4VHlwZSBuYW1lPSJvcmRlckJyZWFrUGFydCI+"
		cRet += "DQoJCQkJPHhzZDpzZXF1ZW5jZT4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9InJlZ2lvblNvdXJj"
		cRet += "ZUlkIiB0eXBlPSJzb3VyY2VJZFR5cGUiDQoJCQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0i"
		cRet += "MSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNk"
		cRet += "OmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2ODg1MmVjMDEx"
		cRet += "ZTBjOTllNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFu"
		cRet += "bm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJv"
		cRet += "cmRlckJyZWFrUGFydElkIiB0eXBlPSJpZEludFR5cGUiDQoJCQkJCQltaW5PY2N1cnM9IjEiIG1h"
		cRet += "eE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJ"
		cRet += "CQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk0"
		cRet += "MTc0MmVjMDExZTBhODkzNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJ"
		cRet += "CTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4c2Q6ZWxlbWVu"
		cRet += "dCBuYW1lPSJvcmRlclNvdXJjZUlkIiB0eXBlPSJzb3VyY2VJZFR5cGUiDQoJCQkJCQltaW5PY2N1"
		cRet += "cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3Rh"
		cRet += "dGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0"
		cRet += "SUQiPmIwMDk0MTc2MmVjMDExZTBiZDVhNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5m"
		cRet += "bz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCTx4"
		cRet += "c2Q6ZWxlbWVudCBuYW1lPSJvcmRlclR5cGVTb3VyY2VJZCIgdHlwZT0ic291cmNlSWRUeXBlIg0K"
		cRet += "CQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJ"
		cRet += "CQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3Nh"
		cRet += "cC5jb20veGkvVGV4dElEIj5iMDA5NDE3NjJlYzAxMWUwYmQ1YTU0MWY1MTkyYTYxNQ0KCQkJCQkJ"
		cRet += "CTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQk8L3hzZDplbGVt"
		cRet += "ZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0ib3JkZXJJdGVtU291cmNlSWQiIHR5cGU9InNv"
		cRet += "dXJjZUlkVHlwZSINCgkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0i"
		cRet += "ZmFsc2UiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3Vy"
		cRet += "Y2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOTQxNzUyZWMwMTFlMDgzZTA1NDFmNTE5"
		cRet += "MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJ"
		cRet += "CQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9ImxvYWRJZCIgdHlwZT0i"
		cRet += "aWRJbnRUeXBlIiBtaW5PY2N1cnM9IjEiDQoJCQkJCQltYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJm"
		cRet += "YWxzZSI+DQoJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJj"
		cRet += "ZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4MjJlYzAxMWUwOTQ4ODU0MWY1MTky"
		cRet += "YTYxNQ0KCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJ"
		cRet += "CQk8L3hzZDplbGVtZW50Pg0KCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0ic2hpcG1lbnRVbml0SWQi"
		cRet += "IHR5cGU9ImlkSW50VHlwZSINCgkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxs"
		cRet += "YWJsZT0iZmFsc2UiPg0KCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5m"
		cRet += "byBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOTY4ODEyZWMwMTFlMGMyN2M1"
		cRet += "NDFmNTE5MmE2MTUNCgkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlv"
		cRet += "bj4NCgkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9InF1YW50U2hp"
		cRet += "cG1Vbml0cyIgdHlwZT0icG9zaXRpdmVGbG9hdFR5cGUiDQoJCQkJCQltaW5PY2N1cnM9IjEiIG1h"
		cRet += "eE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJ"
		cRet += "CQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2"
		cRet += "ODgwMmVjMDExZTBjN2JlNTQxZjUxOTJhNjE1DQoJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJ"
		cRet += "CTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVsZW1lbnQ+CQkJCQkNCgkJCQkJPHhzZDpl"
		cRet += "bGVtZW50IG5hbWU9InF1YW50UHJvZFVuaXRzIiB0eXBlPSJwb3NpdGl2ZUZsb2F0VHlwZSINCgkJ"
		cRet += "CQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJ"
		cRet += "PHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAu"
		cRet += "Y29tL3hpL1RleHRJRCI+YjAwOTQxNzcyZWMwMTFlMGE4Y2U1NDFmNTE5MmE2MTUNCgkJCQkJCQk8"
		cRet += "L3hzZDphcHBpbmZvPg0KCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJPC94c2Q6ZWxlbWVu"
		cRet += "dD4NCgkJCQkJPHhzZDplbGVtZW50IG5hbWU9ImF0dHJpYnV0ZXMiIHR5cGU9ImF0dHJpYnV0ZXMi"
		cRet += "DQoJCQkJCQltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJ"
		cRet += "CQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8v"
		cRet += "c2FwLmNvbS94aS9UZXh0SUQiPmIwMDk0MTc3MmVjMDExZTBhOGNlNTQxZjUxOTJhNjE1DQoJCQkJ"
		cRet += "CQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCTwveHNkOmVs"
		cRet += "ZW1lbnQ+DQoJCQkJPC94c2Q6c2VxdWVuY2U+DQoJCQk8L3hzZDpjb21wbGV4VHlwZT4NCg0KCQkJ"
		cRet += "PCEtLSBSZWxlYXNlIFJlcXVlc3QgLS0+DQoJCQk8eHNkOmVsZW1lbnQgbmFtZT0icHVibGlzaFJl"
		cRet += "bGVhc2VkVHJpcCI+DQoJCQkJPHhzZDpjb21wbGV4VHlwZT4NCgkJCQkJPHhzZDpzZXF1ZW5jZT4N"
		cRet += "CgkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJtZXNzYWdlSWQiIHR5cGU9ImlkSW50VHlwZSINCgkJ"
		cRet += "CQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJ"
		cRet += "CQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9z"
		cRet += "YXAuY29tL3hpL1RleHRJRCI+YjAwOTQxNzEyZWMwMTFlMGI3Y2M1NDFmNTE5MmE2MTUNCgkJCQkJ"
		cRet += "CQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQkJPC94c2Q6"
		cRet += "ZWxlbWVudD4NCgkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJvcmRlckJyZWFrUGFydHMiIG1pbk9j"
		cRet += "Y3Vycz0iMCINCgkJCQkJCQltYXhPY2N1cnM9IjEiPg0KCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4N"
		cRet += "CgkJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5i"
		cRet += "MDA5NDE3MjJlYzAxMWUwY2MyYTU0MWY1MTkyYTYxNQ0KCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0K"
		cRet += "CQkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCQkJPHhzZDpjb21wbGV4VHlwZT4NCgkJCQkJ"
		cRet += "CQkJPHhzZDpzZXF1ZW5jZT4NCgkJCQkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJvcmRlckJyZWFr"
		cRet += "UGFydCIgdHlwZT0ib3JkZXJCcmVha1BhcnQiDQoJCQkJCQkJCQkJbWluT2NjdXJzPSIxIiBtYXhP"
		cRet += "Y2N1cnM9InVuYm91bmRlZCIgbmlsbGFibGU9ImZhbHNlIj4NCgkJCQkJCQkJCQk8eHNkOmFubm90"
		cRet += "YXRpb24+DQoJCQkJCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hp"
		cRet += "L1RleHRJRCI+YjAwOTQxNzMyZWMwMTFlMGM2Zjc1NDFmNTE5MmE2MTUNCgkJCQkJCQkJCQkJPC94"
		cRet += "c2Q6YXBwaW5mbz4NCgkJCQkJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQkJPC94c2Q6"
		cRet += "ZWxlbWVudD4NCgkJCQkJCQkJPC94c2Q6c2VxdWVuY2U+DQoJCQkJCQkJPC94c2Q6Y29tcGxleFR5"
		cRet += "cGU+DQoJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9InRyaXBS"
		cRet += "ZWxlYXNlUmVxdWVzdHMiIG1pbk9jY3Vycz0iMSINCgkJCQkJCQltYXhPY2N1cnM9IjEiIG5pbGxh"
		cRet += "YmxlPSJmYWxzZSI+DQoJCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQk8eHNkOmFwcGlu"
		cRet += "Zm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2ODgzMmVjMDExZTA5NTM2"
		cRet += "NTQxZjUxOTJhNjE1DQoJCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQkJPC94c2Q6YW5ub3Rh"
		cRet += "dGlvbj4NCgkJCQkJCQk8eHNkOmNvbXBsZXhUeXBlPg0KCQkJCQkJCQk8eHNkOnNlcXVlbmNlPg0K"
		cRet += "CQkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9InRyaXBSZWxlYXNlUmVxdWVzdCIgbWluT2NjdXJz"
		cRet += "PSIxIg0KCQkJCQkJCQkJCW1heE9jY3Vycz0idW5ib3VuZGVkIiBuaWxsYWJsZT0iZmFsc2UiPg0K"
		cRet += "CQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJPHhzZDphcHBpbmZvIHNvdXJj"
		cRet += "ZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4NDJlYzAxMWUwOWExYTU0MWY1MTky"
		cRet += "YTYxNQ0KCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJCTwveHNkOmFubm90YXRp"
		cRet += "b24+DQoJCQkJCQkJCQkJPHhzZDpjb21wbGV4VHlwZT4NCgkJCQkJCQkJCQkJPHhzZDpzZXF1ZW5j"
		cRet += "ZT4NCgkJCQkJCQkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJyZWdpb25Tb3VyY2VJZCIgdHlwZT0i"
		cRet += "c291cmNlSWRUeXBlIg0KCQkJCQkJCQkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBu"
		cRet += "aWxsYWJsZT0iZmFsc2UiPg0KCQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJ"
		cRet += "CQkJCQkJPHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5"
		cRet += "Njg4NTJlYzAxMWUwYzk5ZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZv"
		cRet += "Pg0KCQkJCQkJCQkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVt"
		cRet += "ZW50Pg0KCQkJCQkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9ImJhc2tldFNvdXJjZUlkIiB0eXBl"
		cRet += "PSJzb3VyY2VJZFR5cGUiDQoJCQkJCQkJCQkJCQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEi"
		cRet += "Pg0KCQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJPHhzZDphcHBp"
		cRet += "bmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4NTJlYzAxMWUwYzk5"
		cRet += "ZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJCQkJ"
		cRet += "CTwveHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCQkJ"
		cRet += "CQkJPHhzZDplbGVtZW50IG5hbWU9ImlkZW50aWZpZXIiIHR5cGU9ImlkSW50VHlwZSINCgkJCQkJ"
		cRet += "CQkJCQkJCQltaW5PY2N1cnM9IjEiIG1heE9jY3Vycz0iMSIgbmlsbGFibGU9ImZhbHNlIj4NCgkJ"
		cRet += "CQkJCQkJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQkJCTx4c2Q6YXBwaW5mbyBz"
		cRet += "b3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOTY4ODYyZWMwMTFlMDk4Mzk1NDFm"
		cRet += "NTE5MmE2MTUNCgkJCQkJCQkJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCQkJCQkJCQk8L3hz"
		cRet += "ZDphbm5vdGF0aW9uPg0KCQkJCQkJCQkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJCQkJCQkJCTx4"
		cRet += "c2Q6ZWxlbWVudCBuYW1lPSJmcmVpZ2h0VmFsdWUiIHR5cGU9InBvc2l0aXZlRmxvYXRUeXBlIg0K"
		cRet += "CQkJCQkJCQkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2Ui"
		cRet += "Pg0KCQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJPHhzZDphcHBp"
		cRet += "bmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj42MDViNmVhMDU5NzcxMWUwOGUx"
		cRet += "MzU0NGI3YzVkNDgxMA0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJCQkJ"
		cRet += "CTwveHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCQkJ"
		cRet += "CQkJPHhzZDplbGVtZW50IG5hbWU9ImNhcnJpZXJJZCIgdHlwZT0ic291cmNlSWRUeXBlIg0KCQkJ"
		cRet += "CQkJCQkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0K"
		cRet += "CQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJPHhzZDphcHBpbmZv"
		cRet += "IHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4NTJlYzAxMWUwYzk5ZTU0"
		cRet += "MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJCQkJCTwv"
		cRet += "eHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCQkJCQkJ"
		cRet += "PHhzZDplbGVtZW50IG5hbWU9InZlaGljbGVJZCIgdHlwZT0ic291cmNlSWRUeXBlIg0KCQkJCQkJ"
		cRet += "CQkJCQkJCW1pbk9jY3Vycz0iMSIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFsc2UiPg0KCQkJ"
		cRet += "CQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJPHhzZDphcHBpbmZvIHNv"
		cRet += "dXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5YjZhMTJlYzAxMWUwOWRmOTU0MWY1"
		cRet += "MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJCQkJCTwveHNk"
		cRet += "OmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCQkJCQkJPHhz"
		cRet += "ZDplbGVtZW50IG5hbWU9InZlaGljbGVEZXNjcmlwdGlvbiIgdHlwZT0iZGVzY3JpcHRpb24yNTVU"
		cRet += "eXBlIg0KCQkJCQkJCQkJCQkJCW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSIxIj4NCgkJCQkJCQkJ"
		cRet += "CQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9"
		cRet += "Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOWI2YTAyZWMwMTFlMDliOTI1NDFmNTE5MmE2"
		cRet += "MTUNCgkJCQkJCQkJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCQkJCQkJCQk8L3hzZDphbm5v"
		cRet += "dGF0aW9uPg0KCQkJCQkJCQkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJCQkJCQkJCTx4c2Q6ZWxl"
		cRet += "bWVudCBuYW1lPSJ0cnVja0xpY2Vuc2VQbGF0ZSIgdHlwZT0ic3RyaW5nMTBUeXBlIg0KCQkJCQkJ"
		cRet += "CQkJCQkJCW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSIxIj4NCgkJCQkJCQkJCQkJCQk8eHNkOmFu"
		cRet += "bm90YXRpb24+DQoJCQkJCQkJCQkJCQkJCTx4c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAu"
		cRet += "Y29tL3hpL1RleHRJRCI+YjAwOTY4ODUyZWMwMTFlMGM5OWU1NDFmNTE5MmE2MTUNCgkJCQkJCQkJ"
		cRet += "CQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJCQkJCQkJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJ"
		cRet += "CQkJCQkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJCQkJCQkJCTx4c2Q6ZWxlbWVudCBuYW1lPSJ0"
		cRet += "cnVja0xpY2Vuc2VQbGF0ZVN0YXRlIiB0eXBlPSJzdHJpbmcyVHlwZSINCgkJCQkJCQkJCQkJCQlt"
		cRet += "aW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSI+DQoJCQkJCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9u"
		cRet += "Pg0KCQkJCQkJCQkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9U"
		cRet += "ZXh0SUQiPmIwMDk2ODg1MmVjMDExZTBjOTllNTQxZjUxOTJhNjE1DQoJCQkJCQkJCQkJCQkJCTwv"
		cRet += "eHNkOmFwcGluZm8+DQoJCQkJCQkJCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJ"
		cRet += "CTwveHNkOmVsZW1lbnQ+DQoJCQkJCQkJCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0idHJ1Y2tTdGF0"
		cRet += "dXNJZCIgdHlwZT0ic3RyaW5nMlR5cGUiDQoJCQkJCQkJCQkJCQkJbWluT2NjdXJzPSIwIiBtYXhP"
		cRet += "Y2N1cnM9IjEiPg0KCQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJ"
		cRet += "PHhzZDphcHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4NTJl"
		cRet += "YzAxMWUwYzk5ZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJ"
		cRet += "CQkJCQkJCQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0K"
		cRet += "CQkJCQkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9InRydWNrU3RhdHVzRGVzY3JpcHRpb24iIHR5"
		cRet += "cGU9ImRlc2NyaXB0aW9uMjU1VHlwZSINCgkJCQkJCQkJCQkJCQltaW5PY2N1cnM9IjAiIG1heE9j"
		cRet += "Y3Vycz0iMSI+DQoJCQkJCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQkJCQkJCQk8"
		cRet += "eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk2ODg1MmVj"
		cRet += "MDExZTBjOTllNTQxZjUxOTJhNjE1DQoJCQkJCQkJCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJ"
		cRet += "CQkJCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCTwveHNkOmVsZW1lbnQ+DQoJ"
		cRet += "CQkJCQkJCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0idHJ1Y2tBeGxlc1F1YW50aXR5IiB0eXBlPSJw"
		cRet += "b3NpdGl2ZUludFR5cGUiDQoJCQkJCQkJCQkJCQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEi"
		cRet += "Pg0KCQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJPHhzZDphcHBp"
		cRet += "bmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4NTJlYzAxMWUwYzk5"
		cRet += "ZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJCQkJ"
		cRet += "CTwveHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCQkJ"
		cRet += "CQkJPHhzZDplbGVtZW50IG5hbWU9InRyaXBDbGFzc2lmaWNhdGlvblNvdXJjZUlkIiB0eXBlPSJz"
		cRet += "b3VyY2VJZFR5cGUiDQoJCQkJCQkJCQkJCQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiPg0K"
		cRet += "CQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJPHhzZDphcHBpbmZv"
		cRet += "IHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5Njg4NTJlYzAxMWUwYzk5ZTU0"
		cRet += "MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJCQkJCTwv"
		cRet += "eHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCQkJCQkJ"
		cRet += "PHhzZDplbGVtZW50IG5hbWU9ImNsYXNzaWZpY2F0aW9ucyIgdHlwZT0iY2xhc3NpZmljYXRpb25z"
		cRet += "Ig0KCQkJCQkJCQkJCQkJCW1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSIxIiBuaWxsYWJsZT0iZmFs"
		cRet += "c2UiPg0KCQkJCQkJCQkJCQkJCTx4c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCQkJPHhzZDph"
		cRet += "cHBpbmZvIHNvdXJjZT0iaHR0cDovL3NhcC5jb20veGkvVGV4dElEIj5iMDA5NDE3NzJlYzAxMWUw"
		cRet += "YThjZTU0MWY1MTkyYTYxNQ0KCQkJCQkJCQkJCQkJCQk8L3hzZDphcHBpbmZvPg0KCQkJCQkJCQkJ"
		cRet += "CQkJCTwveHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJ"
		cRet += "CQkJCQkJPHhzZDplbGVtZW50IG5hbWU9ImF0dHJpYnV0ZXMiIHR5cGU9ImF0dHJpYnV0ZXMiDQoJ"
		cRet += "CQkJCQkJCQkJCQkJbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+"
		cRet += "DQoJCQkJCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQkJCQkJCQk8eHNkOmFwcGlu"
		cRet += "Zm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDk0MTc3MmVjMDExZTBhOGNl"
		cRet += "NTQxZjUxOTJhNjE1DQoJCQkJCQkJCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQkJCQkJCQkJ"
		cRet += "PC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCTwveHNkOmVsZW1lbnQ+CQkJCQkJCQkJCQkJ"
		cRet += "DQoJCQkJCQkJCQkJCQk8eHNkOmVsZW1lbnQgbmFtZT0iY29tbWVudHMiIHR5cGU9ImRlc2NyaXB0"
		cRet += "aW9uMjU1VHlwZSINCgkJCQkJCQkJCQkJCQltaW5PY2N1cnM9IjAiIG1heE9jY3Vycz0iMSI+DQoJ"
		cRet += "CQkJCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQkJCQkJCQk8eHNkOmFwcGluZm8g"
		cRet += "c291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9UZXh0SUQiPmIwMDliNmEwMmVjMDExZTA5YjkyNTQx"
		cRet += "ZjUxOTJhNjE1DQoJCQkJCQkJCQkJCQkJCTwveHNkOmFwcGluZm8+DQoJCQkJCQkJCQkJCQkJPC94"
		cRet += "c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJCTwveHNkOmVsZW1lbnQ+DQoJCQkJCQkJCQkJCQk8"
		cRet += "eHNkOmVsZW1lbnQgbmFtZT0ibG9hZHMiIG1pbk9jY3Vycz0iMSINCgkJCQkJCQkJCQkJCQltYXhP"
		cRet += "Y2N1cnM9IjEiIG5pbGxhYmxlPSJmYWxzZSI+DQoJCQkJCQkJCQkJCQkJPHhzZDphbm5vdGF0aW9u"
		cRet += "Pg0KCQkJCQkJCQkJCQkJCQk8eHNkOmFwcGluZm8gc291cmNlPSJodHRwOi8vc2FwLmNvbS94aS9U"
		cRet += "ZXh0SUQiPmIwMDk2ODg3MmVjMDExZTA5YWJlNTQxZjUxOTJhNjE1DQoJCQkJCQkJCQkJCQkJCTwv"
		cRet += "eHNkOmFwcGluZm8+DQoJCQkJCQkJCQkJCQkJPC94c2Q6YW5ub3RhdGlvbj4NCgkJCQkJCQkJCQkJ"
		cRet += "CQk8eHNkOmNvbXBsZXhUeXBlPg0KCQkJCQkJCQkJCQkJCQk8eHNkOnNlcXVlbmNlPg0KCQkJCQkJ"
		cRet += "CQkJCQkJCQkJPHhzZDplbGVtZW50IG5hbWU9ImxvYWQiIHR5cGU9ImxvYWQiDQoJCQkJCQkJCQkJ"
		cRet += "CQkJCQkJbWluT2NjdXJzPSIxIiBtYXhPY2N1cnM9InVuYm91bmRlZCIgbmlsbGFibGU9ImZhbHNl"
		cRet += "Ij4NCgkJCQkJCQkJCQkJCQkJCQk8eHNkOmFubm90YXRpb24+DQoJCQkJCQkJCQkJCQkJCQkJCTx4"
		cRet += "c2Q6YXBwaW5mbyBzb3VyY2U9Imh0dHA6Ly9zYXAuY29tL3hpL1RleHRJRCI+YjAwOTY4ODgyZWMw"
		cRet += "MTFlMGFiY2Q1NDFmNTE5MmE2MTUNCgkJCQkJCQkJCQkJCQkJCQkJPC94c2Q6YXBwaW5mbz4NCgkJ"
		cRet += "CQkJCQkJCQkJCQkJCQk8L3hzZDphbm5vdGF0aW9uPg0KCQkJCQkJCQkJCQkJCQkJPC94c2Q6ZWxl"
		cRet += "bWVudD4NCgkJCQkJCQkJCQkJCQkJPC94c2Q6c2VxdWVuY2U+DQoJCQkJCQkJCQkJCQkJPC94c2Q6"
		cRet += "Y29tcGxleFR5cGU+DQoJCQkJCQkJCQkJCQk8L3hzZDplbGVtZW50Pg0KCQkJCQkJCQkJCQk8L3hz"
		cRet += "ZDpzZXF1ZW5jZT4NCgkJCQkJCQkJCQk8L3hzZDpjb21wbGV4VHlwZT4NCgkJCQkJCQkJCTwveHNk"
		cRet += "OmVsZW1lbnQ+DQoJCQkJCQkJCTwveHNkOnNlcXVlbmNlPg0KCQkJCQkJCTwveHNkOmNvbXBsZXhU"
		cRet += "eXBlPg0KCQkJCQkJPC94c2Q6ZWxlbWVudD4NCgkJCQkJPC94c2Q6c2VxdWVuY2U+DQoJCQkJPC94"
		cRet += "c2Q6Y29tcGxleFR5cGU+DQoJCQk8L3hzZDplbGVtZW50Pg0KDQoJCQk8IS0tIFJlbGVhc2UgUmVz"
		cRet += "cG9uc2UgLS0+DQoJCQk8eHNkOmVsZW1lbnQgbmFtZT0icHVibGlzaFJlbGVhc2VkVHJpcFJlc3Bv"
		cRet += "bnNlIiB0eXBlPSJwdWJsaXNoUmVsZWFzZWRUcmlwUmVzcG9uc2UiIC8+DQoJCQk8eHNkOnNpbXBs"
		cRet += "ZVR5cGUgbmFtZT0icHVibGlzaFJlbGVhc2VkVHJpcFJlc3BvbnNlIj4NCgkJCQk8eHNkOnJlc3Ry"
		cRet += "aWN0aW9uIGJhc2U9InhzZDpzdHJpbmciIC8+DQoJCQk8L3hzZDpzaW1wbGVUeXBlPg0KDQoJCTwv"
		cRet += "eHNkOnNjaGVtYT4NCgk8L3dzZGw6dHlwZXM+DQoJPHdzZGw6bWVzc2FnZSBuYW1lPSJwdWJsaXNo"
		cRet += "UmVsZWFzZWRUcmlwIj4NCgkJPHdzZGw6cGFydCBuYW1lPSJwdWJsaXNoUmVsZWFzZWRUcmlwIiBl"
		cRet += "bGVtZW50PSJwMTpwdWJsaXNoUmVsZWFzZWRUcmlwIg0KCQkJeG1sbnM6d3NkbD0iaHR0cDovL3Nj"
		cRet += "aGVtYXMueG1sc29hcC5vcmcvd3NkbC8iIC8+DQoJPC93c2RsOm1lc3NhZ2U+DQoJPHdzZGw6bWVz"
		cRet += "c2FnZSBuYW1lPSJwdWJsaXNoUmVsZWFzZWRUcmlwUmVzcG9uc2UiPg0KCQk8d3NkbDpwYXJ0IG5h"
		cRet += "bWU9InB1Ymxpc2hSZWxlYXNlZFRyaXBSZXNwb25zZSIgZWxlbWVudD0icDE6cHVibGlzaFJlbGVh"
		cRet += "c2VkVHJpcFJlc3BvbnNlIg0KCQkJeG1sbnM6d3NkbD0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5v"
		cRet += "cmcvd3NkbC8iIC8+DQoJPC93c2RsOm1lc3NhZ2U+DQoJPHdzZGw6cG9ydFR5cGUgbmFtZT0icHVi"
		cRet += "bGlzaFJlbGVhc2VkVHJpcFJlcXVlc3QiPg0KCQk8d3NkbDpvcGVyYXRpb24gbmFtZT0icHVibGlz"
		cRet += "aFJlbGVhc2VkVHJpcFJlcXVlc3QiPg0KCQkJPHdzZGw6aW5wdXQgbWVzc2FnZT0icDE6cHVibGlz"
		cRet += "aFJlbGVhc2VkVHJpcCIgLz4NCgkJCTx3c2RsOm91dHB1dCBtZXNzYWdlPSJwMTpwdWJsaXNoUmVs"
		cRet += "ZWFzZWRUcmlwUmVzcG9uc2UiIC8+DQoJCTwvd3NkbDpvcGVyYXRpb24+DQoJPC93c2RsOnBvcnRU"
		cRet += "eXBlPg0KCTx3c2RsOmJpbmRpbmcgbmFtZT0icHVibGlzaFJlbGVhc2VkVHJpcFJlcXVlc3RCaW5k"
		cRet += "aW5nIg0KCQl0eXBlPSJwMTpwdWJsaXNoUmVsZWFzZWRUcmlwUmVxdWVzdCIgeG1sbnM6d3NkbD0i"
		cRet += "aHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3NkbC8iPg0KCQk8c29hcDpiaW5kaW5nIHN0eWxl"
		cRet += "PSJkb2N1bWVudCINCgkJCXRyYW5zcG9ydD0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvc29h"
		cRet += "cC9odHRwIiB4bWxuczpzb2FwPSJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93c2RsL3NvYXAv"
		cRet += "IiAvPg0KCQk8d3NkbDpvcGVyYXRpb24gbmFtZT0icHVibGlzaFJlbGVhc2VkVHJpcFJlcXVlc3Qi"
		cRet += "Pg0KCQkJPHNvYXA6b3BlcmF0aW9uIHNvYXBBY3Rpb249Imh0dHA6Ly9zYXAuY29tL3hpL1dlYlNl"
		cRet += "cnZpY2Uvc29hcDEuMSINCgkJCQl4bWxuczpzb2FwPSJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9y"
		cRet += "Zy93c2RsL3NvYXAvIiAvPg0KCQkJPHdzZGw6aW5wdXQ+DQoJCQkJPHNvYXA6Ym9keSB1c2U9Imxp"
		cRet += "dGVyYWwiIHhtbG5zOnNvYXA9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvc29hcC8i"
		cRet += "IC8+DQoJCQk8L3dzZGw6aW5wdXQ+DQoJCQk8d3NkbDpvdXRwdXQ+DQoJCQkJPHNvYXA6Ym9keSB1"
		cRet += "c2U9ImxpdGVyYWwiIHhtbG5zOnNvYXA9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwv"
		cRet += "c29hcC8iIC8+DQoJCQk8L3dzZGw6b3V0cHV0Pg0KCQk8L3dzZGw6b3BlcmF0aW9uPg0KCTwvd3Nk"
		cRet += "bDpiaW5kaW5nPg0KCTx3c2RsOnNlcnZpY2UgbmFtZT0icHVibGlzaFJlbGVhc2VkVHJpcFJlcXVl"
		cRet += "c3RTZXJ2aWNlIj4NCgkJPHdzZGw6cG9ydCBuYW1lPSJwdWJsaXNoUmVsZWFzZWRUcmlwUmVxdWVz"
		cRet += "dFBvcnQiIGJpbmRpbmc9InAxOnB1Ymxpc2hSZWxlYXNlZFRyaXBSZXF1ZXN0QmluZGluZyINCgkJ"
		cRet += "CXhtbG5zOndzZGw9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzZGwvIj4NCgkJCTxzb2Fw"
		cRet += "OmFkZHJlc3MNCgkJCQlsb2NhdGlvbj0iaHR0cDovL2xvY2FsaG9zdDo4MDg4L21vY2twdWJsaXNo"
		cRet += "UmVsZWFzZWRUcmlwUmVxdWVzdEJpbmRpbmciDQoJCQkJeG1sbnM6c29hcD0iaHR0cDovL3NjaGVt"
		cRet += "YXMueG1sc29hcC5vcmcvd3NkbC9zb2FwLyIgLz4NCgkJPC93c2RsOnBvcnQ+DQoJPC93c2RsOnNl"
		cRet += "cnZpY2U+DQo8L3dzZGw6ZGVmaW5pdGlvbnM+"

		cRet := Decode64(cRet)
	EndIf
	//Alteração da informação location para o endereço informado na requisição
	If !Empty(cRet) .And. !lAutom
		cRet := LocWsdl(cRet)
	EndIf
	
Return cRet

/*/{Protheus.doc} TMSXStart
	
@author siegklenes.beulke
@since 01/09/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function TMSXStart()
	Local lRet := TMSWSInit(,"TMSWS")
Return lRet

Function TMSXConnect()
 	Local cHtml := ""
 	Local cContent := HttpOtherContent()
 	Local cError
	Local cWarning
	Local oXmlSoap
	Local nX
	Local cScan
	Local cFault
	Local cStr
	Local bError := Errorblock({|e|})
	Private XMLREC
	If HTTPHEADIN->MAIN == "TMSXCONNECT"
		//TODO Listar os webservices de recepção disponíveis
		Return ""
	EndIf
	// Inicializa o objeto de falha, para desconsiderar falhas de chamadas anteriores
	__TmsSoapFault := {"","",""}
 	httpHeadOut->CONTENT_TYPE := "application/xml"
 	If "WSDL" $ UPPER(HTTPHEADIN->AHEADERS[1]) .And. Empty(cContent)
 		//Requisição de WSDL
 		cScan := "WSDL" + HTTPHEADIN->MAIN
 		nX := aScan(__aWsWsdl, {|x| x == cScan})
 		
 		If nX == 0
 			If FindFunction(cScan)
 				aAdd(__aWsWsdl,cScan)
 				nX := Len(__aWsWsdl)
 			Else
 				SetFaultTMS('Falha ambiente',"Metodo " + cScan + " não encontrado")
 			EndIf
 		EndIf
 		
 		If nX != 0
 			cHtml := &cScan.()
 		EndIf
 	
	Else
		cScan := HTTPHEADIN->MAIN
 		nX := aScan(__aWsMethod, {|x| x == cScan})
 		
 		If nX == 0
 			If FindFunction(cScan)
 				aAdd(__aWsMethod,cScan)
 				nX := Len(__aWsMethod)
 			Else
 				SetFaultTMS('Falha ambiente',"Metodo " + cScan + " não encontrado")
 			EndIf
 		EndIf
 		
 		If nX != 0
				
			cError := ""
			cWarning := ""
			oXmlSoap := XmlParser(cContent, "NS1", @cError,  @cWarning )
			
			If !Empty(cWarning)
				TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] Aviso ' + cWarning)
			EndIf
			
			If Empty(cError)
				XMLREC := oXmlSoap
 				cHtml := &cScan.(TMSXGetItens("Envelope:Body","O"),@cContent)
 			Else
 				Begin Sequence
				OMSXGRVLOG("TMSXWS",@cContent,"DJZ")
				End Sequence
				ErrorBlock(bError)
				SetFaultTMS('Erro ao interpretar o xml recebido',cError)
			EndIf
		EndIf
		
	EndIf

	cFault := GetFaultTMS()
	If !Empty(cFault)
		cHtml := cFault
		TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] ' + cHtml)
	EndIf
	
Return cHtml

Function SetFaultTMS(cCod,cMsg,cTipo)
	Default cTipo := "Server"
	If !Empty(cTipo) .And. LOWER(cTipo) != "client" .And. LOWER(cTipo) != "server"
		TmsLogMsg("WARN",'[Thread ' + cValToChar(ThreadId()) + '] SetFaultTMS:Tipo de mensagem pode nao ser suportado ' + cTipo)
	Else
		If LOWER(cTipo) == "client"
			cTipo := "Client"
		Else
			cTipo := "Server"
		EndIf
	EndIf
	__TmsSoapFault := {EncodeUtf8(cCod),EncodeUtf8(cMsg),cTipo}
Return

Function GetFaultTMS()
	Local cRet := ""
	If !Empty(__TmsSoapFault[1]) .And. !Empty(__TmsSoapFault[2]) .And. !Empty(__TmsSoapFault[3])
		cRet += __XmlDef
		cRet += __cStrEnv
		cRet += "<soapenv:Fault>"
		cRet += "<faultcode>" + __TmsSoapFault[1] + ":" + __TmsSoapFault[3] + "</faultcode>"
		cRet += "<faultstring>" + __TmsSoapFault[2] + "</faultstring>"
		cRet += "</soapenv:Fault>"
		cRet += __cEndEnv
	EndIf
Return cRet

Static Function GetWsdl(cNome)
	Local cRet 		:= ""
	Local cDirWsdl 	:= Iif(IsSrvUnix(), "/system/TMSXWSDL/" + cNome + ".wsdl", "\system\TMSXWSDL\" + cNome + ".wsdl")

	If File(cDirWsdl)
		cRet := MemoRead(cDirWsdl)
		cRet := IIF(Ferror() != 0, "", cRet)
	EndIf
	
Return cRet

Static Function LocWsdl(cRet)
	
	Local cEnd := ""
	Local cStr := ""
	Local nRat
	
	cStr := StrToKarr(HTTPHEADIN->AHEADERS[1]," ")[2]
	nRat :=  Rat("?",cStr)
	If nRat > 0
		cStr := SubStr(cStr,1,nRat-1)
	EndIf
	cEnd := "http://" + httpHeadIn->HOST + cStr	
	cRet := StrTran(cRet,"[LOCATION]",cEnd)
	
Return cRet
