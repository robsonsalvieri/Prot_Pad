#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTAF001.CH"
#INCLUDE "FwLibVersion.CH"

#DEFINE SOURCEBRANCH 		1
#DEFINE PERIOD				2
#DEFINE STATUS				3	
#DEFINE	EVENTS 				4
#DEFINE EVENTTYPE			5
#DEFINE GROUPTYPE			6
#DEFINE PAGE				7
#DEFINE PAGESIZE			8
#DEFINE EMPPROC				9
#DEFINE FILPROC  			10  

Static __oTRBC20 := NIL
Static __oTRBC30 := NIL
Static __oTRBC35 := NIL
Static __aEstC20 := {}
Static __aEstC30 := {}
Static __aEstC35 := {}
Static nTamPrID  := NIL
Static nT5MRepa  := NIL
Static nT5MTSer	 := NIL
Static __cAlsC20 := NIL
Static __cAlsC30 := NIL
Static __cAlsC35 := NIL
Static __lV3UPerApu := nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF001
WS para retorno das informações referente ao estado dos eventos da reinf no TAF

Retorna o estado dos eventos no "legado", ou seja, a visualização de apuração, o que está apurado ou não. 
Retorna o estado dos eventos no "espelho", ou seja, a visualização do monitor de transmissão, se o determinado
evento está transmitido, bem como o retorno do governo para o evento.

@author Henrique Fabiano Pateno Pereira
@since 29/03/20198
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF001 DESCRIPTION STR0001

	WSDATA companyId	AS STRING
	WSDATA period		AS STRING
	WSDATA events		AS Array
	WSDATA status		AS STRING
	WSDATA eventType	AS Array
	WSDATA groupType	AS INTEGER
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL

	WSMETHOD GET DESCRIPTION STR0002 PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Método responsável pela consulta ao programa nativo da reinf e montagem da mensagem de resposta para camada THF.

@author Henrique Fabiano Pateno Pereira
@since 29/03/20198
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, period, status, events, eventType, groupType, page, pageSize WSREST WSTAF001

Local aRet			as array
Local aQryParam		as array
Local aRotinas		as array
Local aStatPer		as array
Local aFiliais		as array
Local aCompany		as array
Local cResponse		as character
Local cTag			as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nStatus		as numeric
Local nStatusCode	as numeric
Local nApiX			as numeric
Local nApiY			as numeric
Local nApiZ			as numeric
Local nTotal		as numeric
Local nStart		as numeric
Local nQtdRegRet	as numeric
Local nQtdRegTot	as numeric
Local nLenMonit		as numeric
Local nLenEvtRe		as numeric
Local lGeraTotal	as logical
Local lTotalizer	as logical
Local lBildMinit	as logical
Local lRet			as logical
Local oResponse		as object

//-----------------------------------------------
// Inicialização variáveis do tipo array
//-----------------------------------------------
aRet		:=	{}
aQryParam	:=	{}
aRotinas	:=	{}
aStatPer	:=	{}
aFiliais 	:=	{}
aCompany	:=	{}

//-----------------------------------------------
// Inicialização variáveis do tipo string
//-----------------------------------------------
cResponse	:=	""
cTag		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""

//-----------------------------------------------
// Inicialização variáveis do tipo numérico
//-----------------------------------------------
nStatus		:=	6
nStatusCode	:=	0
nApiX		:=	0
nApiY		:=	0
nApiZ		:=	0
nTotal		:=	0
nStart		:=	1
nQtdRegRet	:=	0 //Quantidade máxima do retorno
nQtdRegTot	:=	0
nLenMonit	:=	0
nLenEvtRe	:=	0

//-----------------------------------------------
// Inicialização variáveis booleanas
//-----------------------------------------------
lGeraTotal	:=	.F.
lTotalizer	:=	.F.
lBildMinit	:=	.T.
lRet		:=	.T.

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
elseif self:groupType == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Tipo do Grupo não informado no parâmetro 'groupType'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			aFiliais := WSLoadFil()

			aRotinas := TAFRotinas( ,, .T., 5,,,cValToChar(self:groupType ))

			aQryParam := TAFAdQryPar( self )
			aStatPer := TAFGetPerS( aQryParam[PERIOD] )

			//-------------------------------------------------------------------
			// Executa a consulta ao REINF TAFxReinf.PRW
			//-------------------------------------------------------------------
			aRet := TAFGetReinf( aQryParam, aRotinas, aFiliais )

			//-------------------------------------------------------------------
			// Alimenta as variáveis com o controle de paginação (hasNext)
			//-------------------------------------------------------------------
			TAFGetPage( @nStart, @nQtdRegRet, @nQtdRegTot, aQryParam, aRet )

			oResponse["eventsReinf"] := {}
			oResponse["eventsReinfTotalizers"] := {}
			oResponse["eventsReinfNotPeriodics"] := {}

			//---------------------------------------------------------------------------
			// O For abaixo é executado com base nas variáveis de controle de paginação alimentadas em TAFGetPage()
			//---------------------------------------------------------------------------
			For nApiX := nStart to nQtdRegRet
				cTagEvents := "eventsReinf"
				lTotalizer := .F.
				lBildMinit := .T.

				//-------------------------------------------------------------------
				// É um Totalizador
				//-------------------------------------------------------------------
				If aRet[nApiX][1] == "T"
					cTagEvents := "eventsReinfTotalizers"
					lTotalizer := .T.

				//------------------------------------------------------------------
				// É um Evento Não Periódico, sem apuração
				//-------------------------------------------------------------------
				ElseIf aRet[nApiX][1] == "E" .and. aRet[nApiX][2] $ "R-9000"
					cTagEvents := "eventsReinfNotPeriodics"
					lTotalizer := .F.
				EndIf

				aAdd( oResponse[cTagEvents], JsonObject():New() )
				nLenEvtRe := Len( oResponse[cTagEvents] )

				//-------------------------------------------------------------------
				// Não é um Totalizador
				//-------------------------------------------------------------------
				If !( aRet[nApiX][1] == "T" )
					//Retorna o nome do Tipo de Evento para os Cards do PO UI
					oResponse[cTagEvents][nLenEvtRe]["metrics"] := WS001Name( aRet[nApiX][2] )
				EndIf

				//--------------------------------------------------------------------------------
				// Início nApiY := 2 o índice 1 é apenas para saber se é um Totalizador ou não
				//--------------------------------------------------------------------------------
				For nApiY := 2 to Len( aRet[nApiX] )
					cTag := TAFRetTag( nApiY, aRet[nApiX][2] )

					//-------------------------------------------------------------------------------------------------------
					// Não gero todas as tags de TAFRetTag() quando for Totalizadores, apenas o nome do evento e a descrição
					//-------------------------------------------------------------------------------------------------------
					If !Empty( cTag ) .and. ( !lTotalizer .or. lTotalizer .and. ( nApiY == 2 .or. nApiY == 3 ) )
						oResponse[cTagEvents][nLenEvtRe][cTag] := aRet[nApiX][nApiY]
					EndIf

					If lBildMinit
						oResponse[cTagEvents][nLenEvtRe]["monitoring"] := {}
						lBildMinit := .F.
					EndIf

					If ValType( aRet[nApiX][nApiY] ) == "A" .and. Len( aRet[nApiX][nApiY] ) > 0
						lBildMinit := .T.
						lGeraTotal := .F.

						For nApiZ := 1 to Len( aRet[nApiX][nApiY] )
							lGeraTotal := .T.
							nStatusCode := Iif( Empty( aRet[nApiX][nApiY][nApiZ][2] ) .or. aRet[nApiX][nApiY][nApiZ][2] == "1", 0, Val( aRet[nApiX][nApiY][nApiZ][2] ) )

							aAdd( oResponse[cTagEvents][nLenEvtRe]["monitoring"], JsonObject():New() )

							nLenMonit := Len( oResponse[cTagEvents][nLenEvtRe]["monitoring"] )
							nTotal += aRet[nApiX][nApiY][nApiZ][1]

							oResponse[cTagEvents][nLenEvtRe]["monitoring"][nLenMonit]["quantity"] := aRet[nApiX][nApiY][nApiZ][1]
							oResponse[cTagEvents][nLenEvtRe]["monitoring"][nLenMonit]["statusCode"] := nStatusCode

							If nStatusCode < nStatus
								nStatus := nStatusCode
							EndIf
						Next nApiZ

						If lGeraTotal
							oResponse[cTagEvents][nLenEvtRe]["totalMonitoring"] := nTotal
						EndIf

						oResponse[cTagEvents][nLenEvtRe]["statusMonitoring"] := nStatus

						nTotal := 0
						nStatus := 6
					EndIf
				Next nApiY
			Next nApiX

			//------------------------------------------------------------------------------
			// Retorna o status atual do período e o protocolo de fechamento caso exista.
			//------------------------------------------------------------------------------
			If Len( aStatPer ) > 1
				oResponse['statusPeriod2099'] := aStatPer[1][1]
				oResponse['protocol2099'] := aStatPer[1][2]

				oResponse['statusPeriod4099'] := aStatPer[2][1]
				oResponse['protocol4099'] := aStatPer[2][2]
			EndIf

			//-------------------------------------------------------------------
			// Valida a existência de mais páginas
			//-------------------------------------------------------------------
			If nQtdRegRet < nQtdRegTot
				oResponse['hasNext'] := .T.
			Else
				oResponse['hasNext'] := .F.
			EndIf

			lRet := .T.
			cResponse := FWJsonSerialize( oResponse, .T., .T.,, .F. )
			self:SetResponse( cResponse )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafGetReinf
Executa a consulta ao programa nativo da Reinf e retora o aRet com os eventos encontrados bem como seus status
de apuração e transmissão, de acordo com os parâmetros passados na chamada do WS

@author Henrique Fabiano Pateno Pereira
@since 29/03/20198
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafGetReinf(aQryParam as array, aRotinas as array, aFiliais as array) as array
local aRet				as array
local aRetAux			as array
local aFilToReinf		as array
local nEventFor			as numeric
local nPosEvento		as numeric
local nQtdApur			as numeric
local nQtdNApur			as numeric
local nTotFor			as numeric
local cDescriEv	 		as numeric
local nX				as numeric
Local nT				as numeric
local nVisao			as numeric
local nTotDocOk			as numeric
local nTotDocNo			as numeric
local cEventType		as character
local cStatPCons		as character
local cStatMonit		as character
local cStat				as character
local cEventAnt			as character
local lExstMonit		as logical
local lApur				as logical
local lGetStatus		as logical
local cCNPJFil			as character
local lRetTRB			as logical
local cErroTRB			as character
local aSelFil 			as array
local cEvtTot			as character
local cEvtTotContrib	as character

//-----------------------------------------------
// inicialização variaveis do tipo array
//-----------------------------------------------
aRet			:=	{}
aRetAux			:= 	{}
aFilToReinf		:= 	{}
aSelFil			:=  {}

//-----------------------------------------------
// inicialização variaveis do tipo numeric
//-----------------------------------------------
nEventFor		:=	0
nPosEvento		:=	0
nQtdApur		:=	0
nQtdNApur		:=	0
nTotFor         :=  0
nX				:=	0
nT				:=  0
nVisao			:=	0
nTotDocOk		:= 	0 
nTotDocNo		:= 	0
lRetTRB			:= .T.
//-----------------------------------------------
// inicialização variaveis do tpo caracter
//-----------------------------------------------
cStatPCons		:=	'' // status a ser considerado referente ao legado Pendente Apuração/ Apurados
cStatMonit		:=	'' // status a ser considerado referente as transmissões
cStat			:=	'5'
cEventType		:=	''
cEventAnt		:=	''
cDescriEv	 	:=	0
cErroTRB		:=  ''
cEvtTot			:= GetTotalizerEventCode("evtTot")
cEvtTotContrib	:= GetTotalizerEventCode("evtTotContrib")
//-----------------------------------------------
// inicialização variaveis do tipo lógico
//-----------------------------------------------
lExstMonit	:=	.t. // nocaso de ter sido escolhido status referente a transmissão, valido a geração ou não do evento
lApur		:=	.f.
lGetStatus	:=	.f.
nTamPrID	:= TamSx3("C20_PROCID")[1]
nT5MRepa  	:= TamSx3("T5M_TPREPA")[1]
nT5MTSer	:= TamSx3("T5M_IDTSER")[1]

For nX:=1 To Len(aFiliais)
	aAdd(aFilToReinf,aFiliais[nX])
Next nX
DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( DbSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		cCNPJFil:= AllTrim(Posicione("SM0",1,cEmpAnt+C1E->C1E_FILTAF, "M0_CGC"))
	EndIf
//----------------------------------------------------------------------------
// Com base em self:status retorna o tipo de filtro que deve ser considerado 
//----------------------------------------------------------------------------
TAFVisFilt(@nVisao, @cStatMonit, @cStatPCons, aQryParam)


aSelFil		:= ValidFils( aClone(aFilToReinf) )
lRetTRB := CriaTRBCards(aSelFil,aQryParam[PERIOD], @cErroTRB)
if !lRetTRB;TAFCONOUT(cErroTRB,2,.T.,"REINF"); endif

for nEventFor := 1 to len(aRotinas) 
	cEvento		:= aRotinas[nEventFor][4]
	cEventType	:= TafConvTypeEv(aRotinas[nEventFor][12])
	nTotDocOk	:= 0
	nTotDocNo	:= 0
	nQtdApur    := 0
	nQtdNApur   := 0 
	nTotFor     := 0
	
	//-------------------------------------------------------------------------------------------------------------------------
	// Descarta os eventos que não foram passados em sel:events ou processa todos eventos se self:events for TODOS == '1'
	//--------------------------------------------------------------------------------------------------------------------------
	if 	(cEvento $ aQryParam[EVENTS] .or. "TODOS" $ aQryParam[EVENTS]) .and. (cEventType $ aQryParam[EVENTTYPE] .or. '|0|' $ aQryParam[EVENTTYPE] )
		If (!cEvento $ "R-2020|R-2030|R-2040|R-2050|R-2060|R-3010" .and. Len(cCNPJFil) == 11) .Or. Len(cCNPJFil) == 14

			cDescriEv := EncodeUTF8(TafRetDescr(cEvento))

			cStat := '5'

			if  "R-2050" $ cEvento .or. ;
				"R-2055" $ cEvento .or. ;
				"R-2010" $ cEvento .or. ;
				"R-2020" $ cEvento
				lApur := .t.
				lGetStatus := .t.
			endif
			//-------------------------------------------------------------
			// não executo TafRStatEv para:
			// Totalizadores R-9001 2 R-9011 ( cEventType == 4 )
			// Para o evento de exclusão R-9000
			// e para a posição vazia de aRotinas[16][4], que deixa cEvento igual a "" ( vazio )
			//-------------------------------------------------------------
			
			//--------------------------------------------------------------------------------------------//
			//Para eventos do BLOCO 40, criar novas funções/queries para retornar os contadores dos cards.//
			//--------------------------------------------------------------------------------------------//
			If !Empty(cEvento) .and. !( cEvento $ cEvtTot + "|" + cEvtTotContrib + "|R-9000|R-9005|R-9015" )
				If (lRetTRB .and. cEvento $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2055") .Or. cEvento $ "R-4010|R-4020|R-4040|R-4080"
					cStat := TafRGetCard(aQryParam[PERIOD],cEvento,aSelFil, nVisao, @nQtdApur, @nQtdNApur, @nTotDocOk,@nTotDocNo, @nTotFor)
				Else
			    	cStat := TafRStatEv(aQryParam[PERIOD],,,cEvento,aFilToReinf, nVisao, @nQtdApur, @nQtdNApur, lApur, lGetStatus,/*cCNPJC1H*/ ,@nTotDocOk,@nTotDocNo, .T., @nTotFor)
				EndIf
			Endif

			lApur := .f.
			//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
			// cStat <> '5' .and. cStat == cStatPCons = Apenas se existe o determinado evento na base e cStat <> '5' e estão condizente com o filtro escolhido cStat == cStatPCons
			// cStat == '5' .and.	cEventType == 4	Totalizadores não existe na base então considero cStat == 5 desde que seja um totalizador cEventType == 4
			// cStat == '5' .and.   cEventType == '3' .and. cEvento $ "R-9000|" -> condição para o evento R-9000
			//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
			if (cStat <> '5' .and. cEventType <> '4') .or. (cStat == '5' .and.   cEventType == '4') .or. (cStat == '5' .and.   cEventType == '3' .and. cEvento $ "R-9000|")

				aRetAux	:= TafEvRStat(aFilToReinf,aQryParam[PERIOD], cEvento, nil, cStatMonit, "R-1000|" + cEvtTotContrib + "|" + cEvtTot + "|R-9000|R-9005|R-9015", .T.)
				lExstMonit := .t.

				if (cStat <> '5' .and. cEventType <> '4' .and. !(cStat $ cStatPCons .or. '|99|'$ cStatPCons)) .and. nVisao == 2
					lExstMonit := .f.
				endif

				//-----------------------------------------------------------------------------------------------------------------------------------------------------------
				// se for evento de tabela, ao menos um dos status escolhidos deve ser de transmissão ou todos, caso contrário não escrituro totalizadores cEventType == 4
				//-----------------------------------------------------------------------------------------------------------------------------------------------------------
				if cEventType == '4' .and. !('|1|' $ aQryParam[STATUS])
					lExstMonit := .f.
				endif
				if  '9' == aQryParam[STATUS]
					if (cStat <> '3') .or. ((aScan(aRetAux,{|x|x[2] $ ' |2|3|6'})) > 0)
						lExstMonit := .f.
					endif
				endif

				//--------------------------------------------------------------------------------------------------------
				// Se o status escolhido é referente a transmissão, só gero o evento se houver retorno de TafEvrStat()
				// filtro referente a transmissão
				//--------------------------------------------------------------------------------------------------------
				if 	!('2'$aQryParam[STATUS]) .and. !('3'$aQryParam[STATUS]) .or. cEventType == '4'
					if 	len(aRetAux) == 0 .and. cStat <> '1' .and.;
						!('1'$aQryParam[STATUS] .and. cEventType == '2' .and. cStat == '2') //Nessa situacao, Status=1(todos) deve trazer o Card mesmo sem existir o registro de apuracao.
						lExstMonit := .f.
					endif
				endif

				if lExstMonit .and. cEventAnt <> cEvento
					cEventAnt := cEvento
					aadd(aRet,{aRotinas[nEventFor][12],cEvento,cDescriEv,val(cEventType)})
					nPosEvento := len(aRet)

					if cEvento $ 'R-9000'
						for nT := 1 to len (aRetAux)
							/* 
								Utilizamos as mesmas variavéis de contador dos eventos periodicos ( nQtdApur e nQtdNApur ) para o evento de exclusão, 
								para manter o padrão de retorno do Array aRet ( array responsavel pela montagem do json de response ) 
								e evitar de fazer um "if" desnecessariamente.
								Pois o evento R-9000 não tem apuração, apenas transmissão.
								Então será apresentado a quantidade de registros "pendentes de transmissão" ( nQtdNApur ) e "Transmitidos" ( nQtdApur )
								Se for status de transmitido, marco como Apurado ( nQtdApur ), senão marco como não apurado ( nQtdNApur )
							*/
							if aRetAux[nT][2] $ "2/3/4"
								nQtdApur += aRetAux[nT][1] // Transmitidos
							else
								nQtdNApur += aRetAux[nT][1] //Não Transmitidos
							Endif

						Next nT
					Endif

					If cEvento $ 'R-2010|R-2020|R-2055|R-4010|R-4020|R-4080'
						aadd(aRet[nPosEvento],nTotFor) 	// Total fornecedor
					ElseIf cEvento $ 'R-4040'
						aadd(aRet[nPosEvento],nTotDocOk+nTotDocNo) 	// Total de pagamentos
					Else
						aadd(aRet[nPosEvento],nQtdApur+nQtdNApur) // Total fornecedor
					EndIf
					aadd(aRet[nPosEvento],nTotDocOk+nTotDocNo) 	// Total documento
					aadd(aRet[nPosEvento],nQtdApur			 )	// Qtd apurado / Transmitidos R-9000
					aadd(aRet[nPosEvento],nQtdNApur			 )  // Qtd Não apurado / Não Transmitidos R- 9000
					aadd(aRet[nPosEvento],aRetAux			 ) 	// Array status transmissão
				endif		
			endif
		endif
	endif 
next nEventFor


return aRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafRetTag
Identifica a TAG que deve ser escriturada na a montagem da mensagem de retorno

@author Henrique Fabiano Pateno Pereira
@since 29/03/20198
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

static function TafRetTag(nIndice, cEvento) 
local cTag	as character

default nIndice		:=	0
default cEvento	:=	''
//-----------------------------------------------
// Inicialização variaveis do tipo caracter
//-----------------------------------------------
cTag	:= ''

	Do Case
		Case nIndice == 2
			cTag	:=	"event"
		Case nIndice == 3
			cTag	:=	"descriptionEvent" 
		Case nIndice == 4
			cTag	:=	"typeEvent"
		Case nIndice == 5
			cTag	:=	"total"
		Case nIndice == 6 .and. (cEvento $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-4010|R-4020|R-4080")
			cTag	:=	"totalInvoice"
		Case nIndice == 7
			cTag	:=	"totalValidation"
		Case nIndice == 8
			cTag	:=	"totalNotValidation"
	endCase

return cTag

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafConvTypeEv
Converte de caracter para numérico o tipo do evento que está sendo processado
Tipos:
C-Carga Inicial  ( Tabelas R-1000, R-1070) retorno retorno => 2
M-Mensal (Periódicos R-2010, R-2020, R-2030, R-2040, R2050, R-2060) retorno => 3
E-Eventual (Não Periódicos R-3010, R-9000) retorno => retorno 4
T-Totalizador (Tabelas R-9001, R-9011) retorno=> 5

@author Henrique Fabiano Pateno Pereira
@since 29/03/20198
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

static function TafConvTypeEv(cTypeEvent)
local 	cEventType	as character

default	cTypeEvent	:=	""

//-----------------------------------------------
// Inicialização variaveis do tipo STRING
//-----------------------------------------------
cEventType	:=	''

	do case 
		case cTypeEvent == "C"
				cEventType	:=	'1' // Tabelas R-1000, R-1070
		case cTypeEvent == "M"
				cEventType	:=	'2' // Periódicos R-2010, R-2020, R-2030, R-2040, R2050, R-2055, R-2060
		case cTypeEvent == "E"
				cEventType	:=	'3' // Não Periódicos R-3010, R-9000
		case cTypeEvent == "T"
				cEventType	:=	'4' // Tabelas R-9001, R-9011
	endCase			

return cEventType

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TAFVisFilt
Alimenta as variaveis de controle do tipo de consulta que deve ser executada a Reinf de acordo
com o filtro recebido na requisição

==================================================================
||STATUS											||	NUMERO	||
||================================================================
||Todos												||		1	||
||Pendentes apuração								||		2	||
||Apurados											||		3	||
||Pendentes transmissão								||		4	||
||Retorno com erros (Transmitidos Inconsistente)	||		5	||
||Transmitidos (Transmitidos Consistente)			||		6	||
||Aguardando Retorno (Transmitido Aguardando)		||		7	||
||Reajustados										||		8	||
||Sem pendencia										||		9	||
==================================================================

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

static function TAFVisFilt(nVisao, cStatMonit, cStatPCons, aQryParam)

	default nVisao 		:= 	0
	default cStatMonit 	:= 	''
	default cStatPCons	:=	'|'
	default aQryParam	:=	{}

	if '|1|' == aQryParam[STATUS] // Todos 
		nVisao		:= 2
		cStatPCons	+=	'|99|' 
	endif
	if '|2|' $ aQryParam[STATUS] // Pendente apuração
		nVisao		:= 2
		cStatPCons	+=	'|1|2|'// Não apurado|apurado parcialmente
	endif
	if  '|3|' $ aQryParam[STATUS] // Apurados
		nVisao		:= 2
		cStatPCons	+=	'|3|'
	endif
	if '|4|' $ aQryParam[STATUS] // Pendentes Transmissão
		nVisao		:= 3
		cStatPCons	+=	'|3|'
		if at(cStatMonit,"'0'") == 0
			cStatMonit	+=	"'0',"
		endif
	endif
	if '|5|' $ aQryParam[STATUS] // Retorno com erros (Transmitidos Inconsistente)
		nVisao		:= 3
		cStatPCons	+=	'|3|'
		if at(cStatMonit,"'3'") == 0
			cStatMonit	+=	"'3',"
		endif
	endif
	if '|6|' $ aQryParam[STATUS] // Transmitidos (Transmitidos Consistente/ com erro, transmitido aguardando)
		nVisao		:= 3
		cStatPCons	+=	'|3|'
		if at(cStatMonit,	"'4','3','2','6','7',") == 0
			cStatMonit	+=	"'4','3','2','6','7',"
		endif
	endif
	if '|7|' $ aQryParam[STATUS] // Aguardando Retorno (Transmitido Aguardando)
		nVisao		:= 3
		cStatPCons	+=	'|3|'
		if at(cStatMonit,"'2'") == 0
			cStatMonit	+=	"'2',"
		endif
	endif

	/*case aQryParam[STATUS] == 8 // Reajustados até o momento ainda não temos essa inteligencia na Reinf, quando for implementado esse seria o código
			nVisao		:=	1
			cStatPCons	:=	'3'
			cStatMonit	:=	'2'*/

	if '|9|' $ aQryParam[STATUS] // Sem pendencia
		nVisao		:= 2
		cStatPCons	+=	'3|'
		if at(cStatMonit,"'4'") == 0
			cStatMonit	+=	"'4',"
		endif
	endif 
	cStatMonit := substr(cStatMonit,1,len(cStatMonit)-1)

return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafAdQryPar
Alimenta o array aQryParam para controle das consultas a reinf com base nos parâmetros da requisição

@author Henrique Fabiano Pateno Pereira
@since 29/03/20198
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafAdQryPar(self)

local aQryParam	as array
local cPeriod 	as character

//-----------------------------------------------
// inicialização variaveis do tipo array
//-----------------------------------------------
aQryParam	:=	{} 

//-----------------------------------------------
// inicialização variaveis do tipo caracter
//-----------------------------------------------
cPeriod := if(empty(self:period),strzero(month(dDatabase),2)+cValToChar(Year(dDataBase)),self:period)

aAdd(aQryParam,	self:companyId			 )
aAdd(aQryParam,	cPeriod						 )
aAdd(aQryParam,	TafConvAtS(self, "STATUS") 	 )
aAdd(aQryParam,	TafConvAtS(self, "EVENTS") 	 )
aAdd(aQryParam,	TafConvAtS(self, "EVENTTYPE"))
aAdd(aQryParam,	TafConvAtS(self, "GROUPTYPE"))
aAdd(aQryParam,	self:page					 )
aAdd(aQryParam,	self:pageSize				 )
aAdd(aQryParam,	cEmpAnt						 )
aAdd(aQryParam,	cFilAnt						 )

return aQryParam

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafGetPage
Alimenta as variaveis de controle de paginação com base nos parâmetros page e pageSize passados na requisição

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafGetPage(nStart, nQtdRegRet, nQtdRegTot, aQryParam, aRet)

if (aQryParam[PAGESIZE] <> nil .and. aQryParam[PAGESIZE] > 0) .and. (aQryParam[PAGE] <> nil .and. aQryParam[PAGE] > 0)
	nQtdRegRet := (aQryParam[PAGESIZE] * aQryParam[PAGE])
	if aQryParam[PAGE] > 1
		nStart := ( ( aQryParam[PAGE] - 1 ) * aQryParam[PAGESIZE] ) + 1
	endif
else
	nQtdRegRet := len(aRet)
	nStart := 1
endif

if nQtdRegRet > len(aRet)
	nQtdRegRet := len(aRet)
endif
nQtdRegTot := len(aRet)

return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafConvAtS
Converte os parametros enviados como array para string

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafConvAtS(self, cIdConv)

local cRet as character
local nx   as numeric

default	cIdConv := ''

//-----------------------------------------------
// inicialização variaveis do tipo string
//-----------------------------------------------
cRet := ''

//----------------------------------------------- 
// inicialização variaveis do tipo numericas
//-----------------------------------------------
nx := 0

for nx := 1 to len(self:aQueryString)
	if self:aQueryString[nx][1] == cIdConv
		if empty(cRet)
			cRet := '|'
		endif
		cRet += UPPER(cValToChar(self:aQueryString[nx][2] )) + '|'
	endif
next nx

if empty(cRet)
	do case
		case cIdConv $ 'STATUS'
			cRet	:= '|1|'
		case cIdConv $ 'EVENTTYPE'
			cRet	:= '|0|'
		case cIdConv == 'EVENTS'
			cRet	:= 'TODOS'
	endCase
elseif ('|0|' $ cRet .and. len(cRet)>3)
	cRet := STRTRAN(cRet,'|0','')
elseif ('|TODOS|'$cRet .and. len(cRet)>7)
	cRet := STRTRAN(cRet,'|TODOS','')
endif

return cRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática Ws001Name
Retorna o nome de tela dos eventos para os cards da primeiratela do Reinf - THF
 
@author Henrique Fabiano Pateno Pereira
@since 08/05/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function Ws001Name(cEvent)

local cDisplName	:=	''

default cEvent		:=	''

do case
	case cEvent == "R-1000"
		cDisplName :=  EncodeUTF8("contribuintes")
	case cEvent == "R-1050"
		cDisplName :=  EncodeUTF8("entidades ligadas")
	case cEvent == "R-1070"
		cDisplName :=  EncodeUTF8("processos")
	case cEvent == "R-2010"
		cDisplName :=  EncodeUTF8("fornecedores")
	case cEvent == "R-2020"
		cDisplName :=  EncodeUTF8("clientes")
	case cEvent == "R-2030"
		cDisplName :=  EncodeUTF8("Filiais")
	case cEvent == "R-2040"
		cDisplName :=  EncodeUTF8("clientes")
	case cEvent == "R-2050"
		cDisplName :=  EncodeUTF8("clientes")
	case cEvent == "R-2055"
		cDisplName :=  EncodeUTF8("fornecedores")
	case cEvent == "R-2060"
		cDisplName :=  EncodeUTF8("CPRB")
	case cEvent == "R-3010"
		cDisplName :=  EncodeUTF8("boletins")
	case cEvent == "R-4010"
		cDisplName :=  EncodeUTF8("fornecedores")
	case cEvent == "R-4020"
		cDisplName :=  EncodeUTF8("fornecedores")
	case cEvent == "R-4040"
		cDisplName :=  EncodeUTF8("pagamentos")
		case cEvent == "R-4080"
		cDisplName :=  EncodeUTF8("clientes")		
	case cEvent == "R-9000"
		cDisplName :=  EncodeUTF8("Exclusões")
endcase

return(cDisplName)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafGetPerS
Retorna um array com o status do período informado e o número do protocolo

@author Bruno Cremaschi
@since 12/06/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafGetPerS(cPeriodo)

local cStatus 	 := "open"
local cProtul 	 := ""
local aRet 		 := {}
local lV1A		 := .F. //reabertura 2098
local lV0B		 := .F. //fechamento 2099
Local lV3W		 := .F. //fechamento 4099
local nQtdReab   := 0
local nQtdFech   := 0

default cPeriodo := ""

DBSelectArea( "V1A" )  //V1A - Reabertura Periodo ( R-2098 )
V1A->( DbSetOrder(2) ) //V1A_FILIAL, V1A_PERAPU, V1A_ATIVO

DBSelectArea( "V0B" )  //V0B - Fechamento do Periodo ( R-2099 )
V0B->( DbSetOrder(2) ) //V0B_FILIAL, V0B_PERAPU, V0B_ATIVO

If TAFAlsInDic( "V3W" )
	DBSelectArea( "V3W" ) //V3W Fechamento do período ( R-4099 )
	V3W->( DbSetOrder(2) ) //V3W_FILIAL, V3W_PERAPU, V3W_ATIVO
	lV3W := V3W->( DbSeek( xFilial("V3W") + SubStr(cPeriodo,1,2) + SubStr(cPeriodo,3,4) + "1") )
Endif

lV1A := V1A->( DbSeek(xFilial("V1A") + cPeriodo + "1") )
lV0B := V0B->( DbSeek( xFilial("V0B") + cPeriodo + "1") )
/* 
Se a última transmissão do fechamento e da reabertura ocorrer com êxito, 
significa que o ambiente esta apto a um novo fechamento,
sem vínculo com protocolo e status, conforme inicialização das variáveis (cProtul e cStatus).
Caso a quantidade de fechamento transmitido com êxito exceda as reaberturas transmitidas com êxito
para o período em questão, é necessário trazer o último protocolo válido do fechamento 
e habilitar o botão apenas para reabertura.
*/
if !( lV1A .And. V1A->V1A_STATUS == "4" .And. lV0B .And. V0B->V0B_STATUS == "4" )
	TafR209X( @nQtdReab, @nQtdFech, cPeriodo )
	//Se houver alguma inconsistencia e a mesma quantidade de fechamento e reaberturas transmitidas e
	//protocolados verifica a ultima acao valida no controle de periodos (V1O)
	if ( V1A->V1A_STATUS == "3" .Or. V0B->V0B_STATUS == "3" ) .And. nQtdFech == nQtdReab
		TafChkV1O( cPeriodo, @cStatus, @cProtul )
	else
		TafSitPro( lV1A, lV0B, @cStatus, @cProtul, cPeriodo )
	endif
elseif lV1A .And. V1A->V1A_STATUS == "4" .And. lV0B .And. V0B->V0B_STATUS == "4"
	TafR209X( @nQtdReab, @nQtdFech, cPeriodo )
	if nQtdFech > nQtdReab
		cStatus := "closed"
		cProtul := V0B->V0B_PROTUL		
	//Se houver a mesma quantidade de fechamento e reaberturas transmitidas e protocolados
	//verifica a ultima acao valida no controle de periodos (V1O)		
	elseif nQtdFech == nQtdReab
		TafChkV1O( cPeriodo, @cStatus, @cProtul )
	endif
endif
Aadd(aRet, {cStatus, cProtul } )

cStatus	:= "open"
cProtul := ""

If lV3W
	Do Case
	Case V3W->V3W_SITPER == "0" 
		If V3W->V3W_STATUS == "4"
			cStatus := "closed"
			cProtul := V3W->V3W_PROTUL	
		ElseIf V3W->V3W_STATUS == "2"
			cStatus := "waitingClosing"
			cProtul := ""
		EndIf
	Case V3W->V3W_SITPER == "1" 
		If V3W->V3W_STATUS == "4"
			cStatus := "open"
			cProtul := V3W->V3W_PROTUL
		ElseIf V3W->V3W_STATUS == "2"
			cStatus := "waitingReopening"
			cProtul := ""
		EndIf			
	EndCase
EndIf

Aadd(aRet, {cStatus, cProtul } )

V0B->(DbCloseArea())
V1A->(DbCloseArea())

If TAFAlsInDic( "V3W" )
	V3W->(DbCloseArea())
EndIf 

Return(aRet)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafSitPro
Verifica situação dos status e do protocolo.

@author Denis Souza
@since 24/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafSitPro( lV1A, lV0B, cStatus, cProtul, cPeriodo )

default lV1A 	 := .F.
default lV0B     := .F.
default cStatus  := ""
default cProtul  := ""
default cPeriodo := ""

if lV1A //Caso exista uma reabertura ativa, verifica se esta aguardando retorno.
	TafChk2098( lV1A, lV0B, @cStatus, @cProtul, cPeriodo )
else //Caso nao exista uma reabertura ativa, verifica se existe um fechamento ativo.
	If lV0B
		TafChk2099( @cStatus, @cProtul, cPeriodo )
	endif
endif

return Nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafChk2098
Verifica Status da V1A ( Reabertura R2098 )

@author Denis Souza
@since 24/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafChk2098( lV1A, lV0B, cStatus, cProtul, cPeriodo )

default lV1A 	 := .F.
default lV0B     := .F.
default cStatus  := ""
default cProtul  := ""
default cPeriodo := ""

If V1A->V1A_STATUS == "2"
	cStatus := "waitingReopening" //Se existir reabertura pendente, habilita o botão "Consultar Reabertura".
	If lV0B
		cProtul := V0B->V0B_PROTUL //Obtem último protocolo válido antes de reabrir.
	endif
else
	If lV0B //Caso exista um fechamento ativo, verifica se esta aguardando retorno
		TafChk2099( @cStatus, @cProtul, cPeriodo )
	endif
endif

return Nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafChk2099
Verifica Status da V0B ( Fechamento R2099 )

@author Denis Souza
@since 24/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafChk2099( cStatus, cProtul, cPeriodo )
local aEvents   as array
local aRegRec   as array
local cMsgRet   as character
local cFilProc  as character
local cAliasTmp as character
local dDataIni  as date
local dDataFim  as date
Private aRetProc10  as array

default cStatus  := ""
default cProtul  := ""
default cPeriodo := ""

aRetProc10  := {}
aEvents   := {}
aRegRec   := {}
cMsgRet   := ""
cFilProc  := ""
cAliasTmp := ""
dDataIni  := CtoD("//")
dDataFim  := CtoD("//")

If V0B->V0B_STATUS == "2" //AGUARDANDO - Se o fechamento aguarda retorno, habilita o botao de consultar.
	cStatus := "waitingClosing"

Elseif V0B->V0B_STATUS == "3" //REJEITADO - Possui exceção, pois pode estar com a Tag 2 - Aguardando Processamento

	/* Caso o evento apresente status 3(incosistência) e contenha descrição 2 - Aguardando Processamento
	ou status 3(incosistência) e tss indisponível no momento do carregamento da interface no po-ui,
	por segurança, deverá ficar habilitado apenas o botão de consultar fechamento, pois se deixar o
	botão de fechamento apto, será enviado um outro fechamento com um já em andamento,
	perdendo o rastro do primeiro fechamento enviado e a possibilidade de consultá-lo no po-ui. */

	/* Caso apresente status 3(incosistencia), o tss esteja ligado e não contenha aguardando processamento,
	deverá manter o botao como 'enviar fechamento' (cStatus open), pois é entendido que foi enviado um fechamento e
	voltou uma consulta com rejeição diferente de processamento e o próximo passso é enviar um fechamento com a correção. */

	cFilProc  := cFilAnt
	aEvents   := TAFRotinas("R-2099",4,.F.,5)
    cAliasTmp := WS005Stat(aEvents, cPeriodo,,,cFilProc)
    dDataIni  := ctod("01/"+SUBSTR(cPeriodo,1,2)+"/"+substr(cPeriodo,3,4))
    dDataFim  := lastday(Ctod("01/"+SUBSTR(cPeriodo,1,2)+"/"+substr(cPeriodo,3,4)))
	aRegRec   := WsTafRecno(cAliasTmp)

	//Consulta Status do Fechamento
    aRetProc10  := TAFProc10Tss(.f., aEvents, /*cStatus*/, /*aIdTrab*/, /*cRecNos*/, /*lEnd*/, @cMsgRet,/*aFiliais*/,dDataIni,dDataFim,/*lEvtInicial*/,/*lCommit*/,aRegRec,/*cIdEnt*/)
	if !Empty(cMsgRet) //inconsistencias de conexao no tss
		cStatus := "waitingClosing" //Consultar Fechamento

	else //sem inconsistencias de conexao com tss
		if len(aRetProc10) >= 1 .and. Type("aRetProc10[1][1]") == "O" .And. type( "aRetProc10[1][1]:CXMLRETEVEN" ) == "C"
			if Upper( Alltrim('<cdRetorno>2</cdRetorno><descRetorno>EM PROCESSAMENTO</descRetorno>')) $ Upper( Alltrim( aRetProc10[1][1]:CXMLRETEVEN ) )
				cStatus := "waitingClosing" //Consultar Fechamento
			endif
		endif
	endif
	(cAliasTmp)->(DbCloseArea())

Elseif V0B->V0B_STATUS == "4" //EVENTO AUTORIZADO - Se ocorrer a transmissao com exito, bloqueio o fechamento e exibo o protocolo.
	cStatus := "closed"
	cProtul := V0B->V0B_PROTUL
endif

return Nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafR209X
Contagem de Fechamento e Reabertura para determinado período com status de transmissão protocolado.

@author Denis Souza
@since 24/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafR209X( nQtdReab, nQtdFech, cPeriodo )

	local cAliasV1A  := GetNextAlias()
	local cAliasV0B  := GetNextAlias()

	Default nQtdReab := 0
	Default nQtdFech := 0
	Default cPeriodo := ""

	BeginSql ALIAS cAliasV1A
		SELECT
			count(*) QTDREAB
		FROM
			%TABLE:V1A% V1A1
		WHERE
			V1A1.V1A_FILIAL= %xFilial:V1A% AND
			V1A1.V1A_PERAPU = %exp:cPeriodo% AND		
			V1A1.%NOTDEL% AND			
			V1A1.V1A_STATUS = '4' AND
			V1A1.V1A_PROTUL <> ' '
	EndSql
	nQtdReab := (cAliasV1A)->QTDREAB

	BeginSql ALIAS cAliasV0B
		SELECT
			count(*) QTDFECH
		FROM
			%TABLE:V0B% V0B1
		WHERE
			V0B1.V0B_FILIAL= %xFilial:V0B% AND
			V0B1.V0B_PERAPU = %exp:cPeriodo% AND
			V0B1.%NOTDEL% AND
			V0B1.V0B_STATUS = '4' AND
			V0B1.V0B_PROTUL <> ' '
	EndSql
	nQtdFech := (cAliasV0B)->QTDFECH

	(cAliasV1A)->(DbCloseArea())
	(cAliasV0B)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} função estática TafChkV1O

@author Denis Souza
@since 05/11/2021
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafChkV1O( cPeriodo, cStatus, cProtul )

Local cQry 		as character
Local cAliasTrb as character
Local cBanco	as character

Default cPeriodo := ""
Default cStatus  := "open"
Default cProtul  := ""

cAliasTrb := GetNextAlias()

cBanco 	  := Upper(AllTrim(TcGetDB()))

DBSelectArea( "V1O" )  //V1O CONTROLE DE PERIODOS REINF
V1O->( DbSetOrder(5) ) //V1O_FILIAL, V1O_NOMEVE, V1O_PERAPU, V1O_ATIVO

cQry := ""

If cBanco == "ORACLE"
	cQry += " SELECT V1O.V1O_NOMEVE, V1O.V1O_STATUS, V1O.V1O_PROTUL FROM ( "
EndIf

If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|MYSQL|POSTGRES" ) )
	cQry += " SELECT TOP 1 V1O.V1O_NOMEVE, V1O.V1O_STATUS, V1O.V1O_PROTUL "
ElseIf cBanco == "INFORMIX"
	cQry += " SELECT FIRST 1 V1O.V1O_NOMEVE, V1O.V1O_STATUS, V1O.V1O_PROTUL "
Else
	cQry += " SELECT V1O.V1O_NOMEVE, V1O.V1O_STATUS, V1O.V1O_PROTUL "
EndIf

cQry += " FROM " + RetSqlName("V1O") + " V1O "

cQry += " WHERE "
cQry += " V1O.V1O_FILIAL = '" + xFilial("V1O") + "' "
cQry += " AND V1O.V1O_PERAPU = '" + cPeriodo + "'"
cQry += " AND V1O.V1O_ATIVO = '1' "		
cQry += " AND V1O.D_E_L_E_T_ = ' ' "

If cBanco == "DB2"
	cQry += " ORDER BY V1O.V1O_DATA DESC, V1O.V1O_HORA DESC, V1O.V1O_SEQUEN DESC "
	cQry += " FETCH FIRST 1 ROWS ONLY "
Elseif cBanco $ "POSTGRES|MYSQL"
	cQry += " ORDER BY V1O.V1O_DATA DESC, V1O.V1O_HORA DESC, V1O.V1O_SEQUEN DESC LIMIT 1 "
Else
	cQry += " ORDER BY V1O.V1O_DATA DESC, V1O.V1O_HORA DESC, V1O.V1O_SEQUEN DESC "
Endif

If cBanco == "ORACLE"
	cQry += " ) V1O WHERE ROWNUM <= 1 "
EndIf

if cBanco <> "INFORMIX"
	cQry := ChangeQuery(cQry)	
endif


dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) ,cAliasTrb )

if (cAliasTrb)->(!EOF())
	if (cAliasTrb)->V1O_NOMEVE == "R-2099" //fechamento
		if (cAliasTrb)->V1O_STATUS == "4" .And. !Empty( (cAliasTrb)->V1O_PROTUL ) //transmitido
			cStatus := "closed"
			cProtul := (cAliasTrb)->V1O_PROTUL
		elseif (cAliasTrb)->V1O_STATUS == "2" //aguardando
			cStatus := "waitingClosing"
			cProtul := " "
		else
			cStatus := "open"
			cProtul := " "
		endif

	elseif (cAliasTrb)->V1O_NOMEVE == "R-2098" //reabertura
		if (cAliasTrb)->V1O_STATUS == "4" .And. !Empty( (cAliasTrb)->V1O_PROTUL ) //transmitido
			cStatus := "open"
			cProtul := " "
		elseif (cAliasTrb)->V1O_STATUS == "2" //aguardando
			cStatus := "waitingReopening"
			if V1O->(DbSeek(xFilial("V1O") + "R-2099" + cPeriodo + "1") )
				cProtul := V1O->V1O_PROTUL
			else
				cProtul := " "
			endif
		else
			cStatus := "open"
			cProtul := " "
		endif		
	endif
endif

(cAliasTrb)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTRBCards
função estática para criar a tabela temporaria que irá armazenar o resultado da query da C20/LEM para 
contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CriaTRBCards(aSelFil, cPeriodo, cErroTRB)

Local lRet 		as logical
 
Local cFilsC20  as character
Local cBanco	as character
Local cLibVers  as character 

Default aSelFil := {}
Default cPeriodo := ""
Default cErroTRB := ""

cBanco 	  := Upper(AllTrim(TcGetDB()))
cLibVers  := FwLibVersion()

lRet := .T.
If Empty(__aEstC20)
	AADD(__aEstC20,{"FILIAL","C",Len(cFilAnt),0})
	AADD(__aEstC20,{"CHVNF" ,"C",MAX(TamSX3( "C20_CHVNF" )[1],TamSX3( "LEM_ID" )[1]),0})
	AADD(__aEstC20,{"NUMERO" ,"C",MAX(TamSX3( "C20_NUMDOC" )[1],TamSX3( "LEM_NUMERO" )[1]),0})
	AADD(__aEstC20,{"INDOPE","C",1,0})
	AADD(__aEstC20,{"PROCID","C",TamSX3( "C20_PROCID" )[1],0})
	AADD(__aEstC20,{"TPDOC" ,"C",TamSX3( "C20_TPDOC" )[1],0})
	AADD(__aEstC20,{"CODPAR" ,"C",TamSX3( "C1H_ID" )[1],0})
	AADD(__aEstC20,{"IDOBRA" ,"C",TamSX3( "T9C_ID" )[1],0})
	
EndIf
If Empty(__aEstC30)
	AADD(__aEstC30,{"FILIAL" ,"C",Len(cFilAnt),0})
	AADD(__aEstC30,{"CHVNF"  ,"C",TamSX3( "C30_CHVNF" )[1],0})
	AADD(__aEstC30,{"NUMITE" ,"C",TamSX3( "C30_NUMITE" )[1],0})
	AADD(__aEstC30,{"CODITE" ,"C",TamSX3( "C30_CODITE" )[1],0})
	AADD(__aEstC30,{"TPREPA","C",1,0})
	AADD(__aEstC30,{"IDTSER","C",TamSX3( "C30_IDTSER" )[1],0})
	AADD(__aEstC30,{"SRVMUN","C",TamSX3( "C30_SRVMUN" )[1],0})
	AADD(__aEstC30,{"CODSER","C",TamSX3( "C30_CODSER" )[1],0})
EndIf

If Empty(__aEstC35)
	AADD(__aEstC35,{"FILIAL" ,"C",Len(cFilAnt),0})
	AADD(__aEstC35,{"CHVNF"  ,"C",TamSX3( "C35_CHVNF" )[1],0})
	AADD(__aEstC35,{"NUMITE" ,"C",TamSX3( "C35_NUMITE" )[1],0})
	AADD(__aEstC35,{"CODITE" ,"C",TamSX3( "C35_CODITE" )[1],0})
	AADD(__aEstC35,{"CODTRI" ,"C",TamSX3( "C35_CODTRI" )[1],0})
EndIf

cFilsC20	:= TafRetFilC("C20",  aSelFil ) 

//-----------------------------------------------------------
// Criação da Tabela Temporaria C20
//-----------------------------------------------------------
If __oTRBC20 == Nil
	__cAlsC20 := GetNextAlias()

	__oTRBC20 := FWTemporaryTable():New( __cAlsC20 )
	__oTRBC20:SetFields( __aEstC20 )
	__oTRBC20:AddIndex("1",{"FILIAL", "CHVNF", "CODPAR"})
	__oTRBC20:Create()
Else
	If cLibVers >= "20220321"
		__oTRBC20:Zap()
	EndIf	
Endif
		
//-----------------------------------------------------------
// Criação da Tabela Temporaria C30
//-----------------------------------------------------------
If __oTRBC30 == Nil
	__cAlsC30 := GetNextAlias()

	__oTRBC30 := FWTemporaryTable():New( __cAlsC30 )
	__oTRBC30:SetFields( __aEstC30 )
	__oTRBC30:AddIndex("1",{"FILIAL", "CHVNF", "NUMITE", "CODITE"})
	__oTRBC30:Create()
Else	
	If cLibVers >= "20220321"
		__oTRBC30:Zap()
	EndIf	
EndIf	

//-----------------------------------------------------------
// Criação da Tabela Temporaria C35
//-----------------------------------------------------------
If __oTRBC35 == Nil
	__cAlsC35 := GetNextAlias()

	__oTRBC35 := FWTemporaryTable():New( __cAlsC35 )
	__oTRBC35:SetFields( __aEstC35 )
	__oTRBC35:AddIndex("1",{"FILIAL", "CHVNF", "NUMITE", "CODITE", "CODTRI"})
	__oTRBC35:Create()
Else	
	If cLibVers >= "20220321"
		__oTRBC35:Zap()
	EndIf	
EndIf
lRet := InsC20Cards(__oTRBC20:GetRealName(),cFilsC20, cPeriodo, @cErroTRB, cBanco)

If lRet 
	lRet := InsC30Cards(__oTRBC30:GetRealName(),__oTRBC20:GetRealName(),cFilsC20, @cErroTRB, cBanco)
	
	If lRet
		lRet := InsC35Cards(__oTRBC35:GetRealName(),__oTRBC20:GetRealName(),cFilsC20, @cErroTRB, cBanco) 
	EndIf
	If lRet
		(__cAlsC20)->( DBGotop())
		(__cAlsC30)->( DBGotop())
		(__cAlsC35)->( DBGotop())
	EndIf	

EndIf
Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsC20Cards
função estática para alimentar a tabela temporaria com o resultado da query da C20 para 
contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function InsC20Cards(cRealName,cFilsC20,cPeriodo, cErroTRB, cBanco)
Local cQuery 	as character
Local cSelect 	as character
Local lRet 		as logical
Local cCampos	as character

Default cRealName := ""
Default cFilsC20  := ""

Default cPeriodo  := ""
Default cErroTRB  := ""
Default cBanco    := ""

lRet := .T.
cCampos := ""
cQuery := " INSERT "
AEval( __aEstC20, { |e,i| cCampos += If( i == 1, e[1], "," + e[1] ) } )
cQuery += " INTO " + cRealName + " (" + cCampos + " ) " 
cSelect := QryC20Cards(cFilsC20, cPeriodo, cBanco)

cQuery += cSelect
nTcSql := TcSQLExec(cQuery)

If nTcSql < 0
	lRet := .F.
	cErroTRB :=  STR0003 + "C20: " + TcSQLError() //"Não foi possível criar a tabela temporária "
Endif
Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsC30Cards
função estática para alimentar a tabela temporaria com o resultado da query da C30 para 
contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function InsC30Cards(cRealName,cTrBC20,cFilsC20, cErroTRB, cBanco)
Local cQuery 	as character
Local cSelect 	as character
Local lRet 		as logical
Local cCampos	as character

Default cRealName := ""
Default cTrBC20   := ""
Default cFilsC20  := ""
Default cErroTRB  := ""
Default cBanco	  := ""	

lRet := .T.
cCampos := ""
cQuery := " INSERT "
AEval( __aEstC30, { |e,i| cCampos += If( i == 1, e[1], "," + e[1] ) } )
cQuery += " INTO " + cRealName + " (" + cCampos + " ) " 
cSelect := QryC30Cards(cFilsC20, cTrBC20, cBanco)
cQuery += cSelect
nTcSql := TcSQLExec(cQuery)

If nTcSql < 0
	lRet := .F.
	cErroTRB :=  STR0003 + "C30: " + TcSQLError() //"Não foi possível criar a tabela temporária "
Endif

Return lRet
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsC35Cards
função estática para alimentar a tabela temporaria com o resultado da query da C35 para 
contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function InsC35Cards(cRealName,cTrBC20,cFilsC20, cErroTRB, cBanco)
Local cQuery 	as character
Local cSelect 	as character
Local lRet 		as logical
Local cCampos	as character

Default cRealName := ""
Default cTrBC20   := ""
Default cFilsC20  := ""
Default cErroTRB  := ""
Default cBanco    := ""

lRet := .T.
cCampos := ""

cQuery := " INSERT "
AEval( __aEstC35, { |e,i| cCampos += If( i == 1, e[1], "," + e[1] ) } )
cQuery += " INTO " + cRealName + " (" + cCampos + " ) " 
cSelect := QryC35Cards(cFilsC20, cTrBC20, cBanco)
cQuery += cSelect
nTcSql := TcSQLExec(cQuery)

If nTcSql < 0
	lRet := .F.
	cErroTRB := STR0003 + "C35: " + TcSQLError() //"Não foi possível criar a tabela temporária "
Endif

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryTRBCards
função estática para retornar a query para contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055
utilizando como C20 e LEM a tabela temporaria

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function QryTRBCards(cEvento, cPeriodo, aFiliais, cBanco)
Local cQuery 		as character
Local cCompC1H 		as character
Local cJoinC1HNf 	as character
Local cJoinC1HFt 	as character
Local aInfoEUF  	as array
Local cTRBC20     	as character
Local cTRBC30     	as character
Local cTRBC35     	as character
Local lApurBx 	  	as logical	
Local cDataIni  	as character
Local cDataFim  	as character
Local cFilsLem 		as character
Local cJoinT9CNf	as character
Local cJoinT9Cft	as character
Local cCompT9C		as character

Default cEvento := ""
Default cPeriodo := ""
Default aFiliais := {}
Default cBanco  := ""

cQuery 	  	:= ""
cJoinC1HNf	:= ""
cJoinC1HFt	:= ""
aInfoEUF	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cCompT9C	:= Upper(AllTrim(FWModeAccess("T9C",1)+FWModeAccess("T9C",2)+FWModeAccess("T9C",3)))
cTRBC20 := __oTRBC20:GetRealName()
cTRBC30 := __oTRBC30:GetRealName()
cTRBC35 := __oTRBC35:GetRealName()
cPeriodo 	:= Right(cPeriodo,4)+Left(cPeriodo,2)
cDataIni 	:= cPeriodo + "01" //ex: 20220201
cDataFim 	:= DtoS( LastDay( StoD( cDataIni ) ) )
cFilsLem	:= TafRetFilC("LEM",  aFiliais ) 
cJoinT9CNf	:= ""
cJoinT9Cft	:= ""

If cEvento $ "R-2030|R-2040" 
	lApurBx := SuperGetMv('MV_TAFRECD',.F.,"1") == "2" .and. TAFColumnPos("T5P_PROCID")// "1"- Emissão ; "2" - Baixa 
Else
	lApurBx := .F.
EndIf	

If cCompC1H == "EEE"
	cJoinC1HNf += " C1H.C1H_FILIAL = C20.FILIAL "			
	cJoinC1HFt += " C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoinC1HNf += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + " = SUBSTRING(C20.FILIAL, 1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
		cJoinC1HFt += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + " = SUBSTRING(LEM.LEM_FILIAL, 1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoinC1HNf += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + " = SUBSTRING(C20.FILIAL, 1," +  cValToChar(aInfoEUF[1]) + ") " 
		cJoinC1HFt += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + " = SUBSTRING(LEM.LEM_FILIAL, 1," +  cValToChar(aInfoEUF[1]) + ") " 
	Else
		cJoinC1HNf += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
		cJoinC1HFt += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf

If cCompT9C == "EEE"
	cJoinT9CNf += " T9C.T9C_FILIAL = C20.FILIAL "			
	cJoinT9CFt += " T9C.T9C_FILIAL = LEM.LEM_FILIAL "			
Else
	If cCompT9C == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoinT9CNf += " SUBSTRING(T9C.T9C_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + " = SUBSTRING(C20.FILIAL, 1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
		cJoinT9CFt += " SUBSTRING(T9C.T9C_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ")" + " = SUBSTRING(LEM.LEM_FILIAL, 1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
	ElseIf cCompT9C == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
		cJoinT9CNf += " SUBSTRING(T9C.T9C_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + " = SUBSTRING(C20.FILIAL, 1," +  cValToChar(aInfoEUF[1]) + ") " 
		cJoinT9CFt += " SUBSTRING(T9C.T9C_FILIAL,1," + cValToChar(aInfoEUF[1]) + ")" + " = SUBSTRING(LEM.LEM_FILIAL, 1," +  cValToChar(aInfoEUF[1]) + ") " 
	Else
		cJoinT9CNf += " T9C.T9C_FILIAL = '" + xFilial("T9C") + "' "
		cJoinT9CFt += " T9C.T9C_FILIAL = '" + xFilial("T9C") + "' "
	EndIf
EndIf

If !lApurBx
	cQuery := "SELECT DISTINCT "
	cQuery += "C20.FILIAL FILIAL, "
	cQuery += "CASE WHEN (T9C.T9C_TPINSC IS NULL OR T9C.T9C_INDOBR = '0' OR (T9C.T9C_INDOBR IN ('1','2') AND T9C.T9C_NRINSC LIKE '%SEM CODIGO%' )) THEN C1H.C1H_CNPJ || C1H.C1H_CPF ELSE T9C.T9C_NRINSC END  CNPJ, "
	cQuery += "C20.CHVNF CHVNF, "
	cQuery += "C1H.C1H_INDDES INDDES, "
	cQuery += "C20.INDOPE INDOPE, "
	cQuery += "C20.PROCID PROCID, "
	cQuery += "C20.TPDOC  TPDOC, "
	cQuery += "C1H.C1H_RAMO RAMO, "
	cQuery += "C1H.C1H_PPES PPES, "
	cQuery += "'NFS' TIPO "
	cQuery += "FROM " +  cTRBC20 + " C20 "
	cQuery += "INNER JOIN " + cTRBC30 + " C30 ON "
	cQuery += "C20.CHVNF = C30.CHVNF "
	cQuery += "AND C20.FILIAL = C30.FILIAL "
	cQuery += "INNER JOIN " + cTRBC35 + " C35 "
	cQuery += "ON C30.CHVNF = C35.CHVNF "
	cQuery += "AND C30.FILIAL = C35.FILIAL "
	cQuery += "AND C30.NUMITE = C35.NUMITE "
	cQuery += "AND C30.CODITE = C35.CODITE "
	cQuery += "AND C35.CODTRI IN ('000013','000024','000025') "
	cQuery += "INNER JOIN " + RetSqlName("C1H") + " C1H ON "
	cQuery += cJoinC1HNf
	cQuery += "AND C1H.C1H_ID = C20.CODPAR "
	cQuery += "AND C1H.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN " + RetSqlName("T9C") +" T9C ON "
	cQuery += cJoinT9CNf
	cQuery += "AND T9C.T9C_ID = C20.IDOBRA "
	cQuery += "AND T9C.D_E_L_E_T_= ' ' "
	cQuery += "WHERE "

	If cEvento $ "R-2010|R-2020"
		cWhere := "C30.IDTSER != ' ' "
		cWhere += "AND C30.TPREPA = ' ' " 
		cWhere += "AND C1H.C1H_PPES = '2' "
		cWhere += "AND C1H.C1H_CNPJ != ' ' "
		cWhere += "AND C1H.C1H_INDDES != '1' "
		If cEvento == "R-2010"
			cWhere += "AND C20.INDOPE = '0' "
		Else
			cWhere += "AND C20.INDOPE = '1' "
		EndIf
	ElseIf 	cEvento $ "R-2030|R-2040"
		cWhere := "C30.TPREPA != ' ' " 
		If cEvento == "R-2030"
			cWhere += "AND C1H.C1H_PPES IN ('2','3') "
			cWhere += "AND (C1H.C1H_CNPJ != ' ' OR (C1H.C1H_CNPJ = ' ' AND C1H.C1H_PAISEX != ' ' AND C1H.C1H_PEEXTE = '2' )) "
			cWhere += "AND C20.INDOPE = '1' "
		Else
			cWhere += "AND C1H.C1H_PPES = '2' "
			cWhere += "AND C1H.C1H_CNPJ != ' ' "
			cWhere += "AND C20.INDOPE = '0' "
			cWhere += "AND C1H.C1H_INDDES = '1' "
		EndIf

	ElseIf 	cEvento $ "R-2050"
		cWhere := "C1H.C1H_INDDES != '1' "
		cWhere += "AND C30.IDTSER = ' ' "
		cWhere += "AND C30.SRVMUN = ' ' "
		cWhere += "AND C30.CODSER = ' ' "
		cWhere += "AND C30.TPREPA = ' ' "
		cWhere += "AND C20.INDOPE = '1' "

	ElseIf 	cEvento $ "R-2055"
		cWhere := "C1H.C1H_RAMO = '4' "
		cWhere += "AND C20.TPDOC <> '000002' "
		cWhere += "AND C30.IDTSER = ' ' "
		cWhere += "AND C30.SRVMUN = ' ' "
		cWhere += "AND C30.CODSER = ' ' "
		cWhere += "AND C30.TPREPA = ' ' "
		cWhere += "AND C20.INDOPE = '0' "

	EndIf
	cQuery += cWhere

	cQuery += "UNION ALL "
EndIf
cQuery += "SELECT DISTINCT "
cQuery += "LEM.LEM_FILIAL FILIAL, "
cQuery += "CASE WHEN (T9C.T9C_TPINSC IS NULL OR T9C.T9C_INDOBR = '0' OR (T9C.T9C_INDOBR IN ('1','2') AND T9C.T9C_NRINSC LIKE '%SEM CODIGO%' )) THEN C1H.C1H_CNPJ || C1H.C1H_CPF ELSE T9C.T9C_NRINSC END  CNPJ, "
cQuery += "LEM.LEM_ID CHVNF, "
cQuery += "C1H.C1H_INDDES INDDES, "
cQuery += "LEM.LEM_NATTIT INDOPE, "
If lApurBx
	cQuery += "T5P.T5P_PROCID PROCID, "
Else
	cQuery += "LEM.LEM_PROCID PROCID, "
EndIf	
cQuery += "' ' TPDOC, "
cQuery += "C1H.C1H_RAMO RAMO, "
cQuery += "C1H.C1H_PPES PPES, "
cQuery += "'FAT' TIPO "
cQuery += "FROM " + RetSqlName("LEM") + " LEM "
cQuery += "INNER JOIN " + RetSqlName("C1H") + " C1H ON " 
cQuery += cJoinC1HFt
cQuery += "AND C1H.C1H_ID = LEM.LEM_IDPART "
cQuery += "AND C1H.D_E_L_E_T_ = ' ' "
If lApurBx 
	cQuery	+= "INNER JOIN " + RetSqlName("T5P") + " T5P ON T5P.T5P_FILIAL = LEM.LEM_FILIAL AND T5P.T5P_ID = LEM.LEM_ID AND "
	cQuery	+= "T5P.T5P_IDPART = LEM.LEM_IDPART AND T5P.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "LEFT JOIN " + RetSqlName("T5M") + " T5M ON "
cQuery += "T5M.T5M_FILIAL = LEM.LEM_FILIAL "
cQuery += "AND T5M.T5M_ID = LEM.LEM_ID "
cQuery += "AND T5M.T5M_IDPART = LEM.LEM_IDPART "
cQuery += "AND T5M.T5M_NUMFAT = LEM.LEM_NUMERO "
cQuery += "AND T5M.D_E_L_E_T_ = ' ' "
cQuery += "LEFT JOIN " + RetSqlName("T9C") + " T9C ON "
cQuery += cJoinT9CFt
cQuery += "AND T9C.T9C_ID = LEM.LEM_IDOBRA "
cQuery += "AND T9C.D_E_L_E_T_= ' ' "
cQuery += "WHERE "
If !Empty( xFilial("LEM") )
	cQuery += " LEM.LEM_FILIAL IN " + cFilsLem + " "
Else
	cQuery += " LEM.LEM_FILIAL = '" + xFilial("LEM") + "' "
EndIf
cQuery += "AND LEM.LEM_DOCORI = ' ' "
If lApurBx
	cQuery += "AND T5P.T5P_DTPGTO BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Else
	cQuery += "AND LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
EndIf
cQuery += "AND LEM.D_E_L_E_T_ = ' ' "
If cEvento $ "R-2010|R-2020"
	cWhere := "AND T5M.T5M_IDTSER != ' ' "
	cWhere += "AND T5M.T5M_TPREPA = '" + space(nT5MRepa) + "' " 
	cWhere += "AND T5M.T5M_BSINSS > 0 "
	cWhere += "AND C1H.C1H_PPES = '2' "
	cWhere += "AND C1H.C1H_CNPJ != ' ' "
	cWhere += "AND C1H.C1H_INDDES != '1' "
	If cEvento == "R-2010"
		cWhere += "AND LEM.LEM_NATTIT = '0' "
	Else
		cWhere += "AND LEM.LEM_NATTIT = '1' "
	EndIf
ElseIf 	cEvento $ "R-2030|R-2040"
	cWhere := "AND T5M.T5M_TPREPA != ' ' "
	
	If cEvento == "R-2030"
		cWhere += "AND C1H.C1H_PPES IN ('2','3') "
		cWhere += "AND (C1H.C1H_CNPJ != ' ' OR (C1H.C1H_CNPJ = ' ' AND C1H.C1H_PAISEX != ' ' AND C1H.C1H_PEEXTE = '2')) "
		cWhere += "AND LEM.LEM_NATTIT = '1' "
	Else
		cWhere += "AND C1H.C1H_PPES = '2' "
		cWhere += "AND C1H.C1H_CNPJ != ' ' "
		cWhere += "AND LEM.LEM_NATTIT = '0' "
		cWhere += "AND C1H.C1H_INDDES = '1' "
	EndIf

ElseIf 	cEvento $ "R-2050"
	cWhere := "AND C1H.C1H_INDDES != '1' "
	cWhere += "AND T5M.T5M_IDTSER = '" + space(nT5MTSer) + "' "
	cWhere += "AND T5M.T5M_TPREPA = '" + space(nT5MRepa) + "' "
	cWhere += "AND LEM.LEM_NATTIT = '1' "

ElseIf 	cEvento $ "R-2055"
	cWhere := "AND C1H.C1H_RAMO = '4' "
	cWhere += "AND (T5M.T5M_IDTSER = '" + space(nT5MTSer) + "' OR T5M.T5M_IDTSER IS NULL) "
	cWhere += "AND (T5M.T5M_TPREPA = '" + space(nT5MRepa) + "' OR T5M.T5M_TPREPA IS NULL) "
	cWhere += "AND LEM.LEM_NATTIT = '0' AND (LEM.LEM_VLRGIL > 0 OR LEM.LEM_VLRSEN > 0 OR LEM.LEM_VLRCP > 0) "
	cWhere += "AND LEM.D_E_L_E_T_= ' ' "
EndIf

cQuery += cWhere

If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
	cQuery := changeQuery(cQuery)
EndIf

Return cQuery

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryC20Cards
função estática para retornar a query para alimentar a tabela temporaria que irá armazenar o resultado da query da C20/LEM para 
contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function QryC20Cards(cFilsC20, cPeriodo, cBanco)
	Local cQuery 		as character
	Local cDataIni  	as character
	Local cDataFim  	as character
	Local oPrepare	 	as object

	Default cFilsC20 := ""
	Default cPeriodo := ""
	Default cBanco := ""

	cQuery 	  	:= ""
	cPeriodo 	:= Right(cPeriodo,4)+Left(cPeriodo,2)
	cDataIni 	:= cPeriodo + "01" //ex: 20220201
	cDataFim 	:= DtoS( LastDay( StoD( cDataIni ) ) )
	oPrepare 	:= FWPreparedStatement():New()

	cQuery := "SELECT "
	cQuery += "C20.C20_FILIAL FILIAL, "
	cQuery += "C20.C20_CHVNF CHVNF, "
	cQuery += "C20.C20_NUMDOC NUMERO, "
	cQuery += "C20.C20_INDOPE INDOPE, "
	cQuery += "C20.C20_PROCID PROCID, "
	cQuery += "C20.C20_TPDOC  TPDOC, "
	cQuery += "C20.C20_CODPAR CODPAR, "
	cQuery += "C20.C20_IDOBR IDOBRA "
	cQuery += "FROM " + RetSqlName("C20") + " C20 "
	cQuery += "WHERE "
	If !Empty( xFilial("C20") )
		cQuery += "C20.C20_FILIAL IN ? "
	Else
		cQuery += "C20.C20_FILIAL = '" + xFilial("C20") + "' "	
	EndIf
	cQuery += "AND C20.C20_DTDOC BETWEEN  ? AND ? "
	cQuery += "AND C20.C20_CODSIT IN (?) "
	cQuery += "AND C20.C20_TPDOC <> ? "
	cQuery += "AND C20.D_E_L_E_T_ = ? "
	If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
		cQuery := ChangeQuery(cQuery)
	EndIf	

	oPrepare:SetQuery(cQuery)
	oPrepare:SetUnsafe(1,cFilsC20)
	oPrepare:SetString(2,cDataIni)
	oPrepare:SetString(3,cDataFim)
	oPrepare:SetIn(4,{'000001','000002','000007','000008','000009'})
	oPrepare:SetString(5,"000002")
	oPrepare:SetString(6,space(1))

	cQuery := oPrepare:GetFixQuery()
	oPrepare:Destroy()

Return cQuery

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryC30Cards
função estática para retornar a query para alimentar a tabela temporaria que irá armazenar o resultado da query da C30 para 
contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function QryC30Cards(cFils, cTrBC20, cBanco)
Local cQuery 		as character

Default cFils := ""
Default cTrBC20 := ""
Default cBanco := ""

cQuery := "SELECT "
cQuery += "C30.C30_FILIAL FILIAL, "
cQuery += "C30.C30_CHVNF CHVNF, "
cQuery += "C30.C30_NUMITE NUMITE, "
cQuery += "C30.C30_CODITE CODITE, "
cQuery += "C30.C30_TPREPA TPREPA, "
cQuery += "C30.C30_IDTSER IDTSER, "
cQuery += "C30.C30_SRVMUN SRVMUN, "
cQuery += "C30.C30_CODSER CODSER "
cQuery += "FROM " + cTrBC20 +" C20 "
cQuery += "INNER JOIN " + RetSqlName("C30") + " C30 ON "
cQuery += "C30.C30_FILIAL = C20.FILIAL "
cQuery += "AND C30.C30_CHVNF = C20.CHVNF "
cQuery += "AND C30.D_E_L_E_T_ = ' ' "

If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
	cQuery := ChangeQuery(cQuery)
EndIf

Return cQuery

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryC35Cards
função estática para retornar a query para alimentar a tabela temporaria que irá armazenar o resultado da query da C35 para 
contabilizar todos os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function QryC35Cards(cFils, cTrBC20, cBanco)
Local cQuery 		as character

Default cFils := ""
Default cTrBC20 := ""
Default cBanco := ""
cQuery 	  	:= ""
cQuery := "SELECT "
cQuery += "C35.C35_FILIAL, "
cQuery += "C35.C35_CHVNF, "
cQuery += "C35.C35_NUMITE, "
cQuery += "C35.C35_CODITE, "
cQuery += "C35.C35_CODTRI "
cQuery += "FROM " + cTrBC20 +" C20 " 
cQuery += "INNER JOIN " + RetSqlName("C35") + " C35 ON "
cQuery += "C35.C35_FILIAL = C20.FILIAL "
cQuery += "AND C35.C35_CHVNF = C20.CHVNF "
cQuery += "AND C35.C35_CODTRI IN ('000013','000024','000025') "
cQuery += "AND C35.D_E_L_E_T_ = ' ' "

If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
	cQuery := ChangeQuery(cQuery)
EndIf

Return cQuery
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafRGetCard
função estática para retornar os contadores dos cards R2010/R2020/R2030/R2040/R2050/R2055 utilziando a
tabela temporária

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafRGetCard(cPeriodo, cEvento, aFiliais, nOpc, nQtdApur, nQtdNApur, nTotDocOk, nTotDocNo, nTotFor)
				
Local cRet 		as character
Local nRetOk	as numeric
Local nRetNo	as numeric
Local nCont 	as numeric
Local nForPls   as numeric
Local aFilCont  as array 
Local aRetDoc	as array

Default	nQtdApur	:= 0
Default	nQtdNApur	:= 0
Default nTotDocOk	:= 0 
Default nTotDocNo	:= 0

cRet 	 := "5" // Default Black
nRetOk	 := 0
nRetNo	 := 0
nCont	 := 0
nForPls  := 0

aFilCont := {}
aRetDoc	 := {}

cPeriodo := StrTran(cPeriodo,"-","")

If cEvento $ "R-4010|R-4020|R-4040|R-4080"
	aRetDoc := TafSt40XX(cEvento, cPeriodo, aFiliais, @nTotFor )
Else
	aRetDoc := QryEvtTRB(cEvento, cPeriodo, aFiliais)
EndIf

nTotDocOk := aRetDoc[1]
nTotDocNo := aRetDoc[2]
nRetOk    := aRetDoc[3]
nRetNo    := aRetDoc[4] 

If !cEvento $ "R-4010|R-4020|R-4080"
	nTotFor   := aRetDoc[3] + aRetDoc[4]
EndIf

If (nOpc == 2 .Or. nOpc == 3) .And. nRetOk == 0 .And. nRetNo == 0 // Sem Movimento
	cRet := "5"
ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo > 0 //Apurado Parcial
	cRet := "2"
ElseIf nOpc == 2 .And. nRetOk > 0 .And. nRetNo == 0 //Apurado Total
	cRet := "3"
ElseIf nOpc == 2 .And. nRetOk == 0 .And. nRetNo > 0 //Não Apurado
	cRet := "1"
ElseIf nOpc == 3 .And. (nRetOk > 0 .Or. nRetNo > 0) // Não transmitido
	cRet := "3"									
EndIf

nQtdApur	:=	nRetOk
nQtdNApur	:=	nRetNo

Return( cRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryEvtTRB
função estática que realiza a query na tabela temporario para contabilizar os cards R2010/R2020/R2030/R2040/R2050/R2055

@author Karen
@since 07/07/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function QryEvtTRB(cEvento, cPeriodo, aFiliais)
Local cQuery as character
Local cWhere as character

Local aRet as array
Local cBanco as character

Default cEvento := ""
Default cPeriodo := ""
Default aFiliais := {}

aRet := {0, 0, 0, 0} // 1-nRetOk 2-nRetNo 3-nTotForOK 4-nTotForNOK
cQuery := ""
cWhere := ""
cBanco := Upper(AllTrim(TcGetDB()))
cQuery := " SELECT "
If cEvento $ "R-2030|R-2040"
	cQuery += " FILIAL,"
Else
	cQuery += " CNPJ,"
EndIf		
cQuery += " SUM(CASE WHEN PROCID = '" + space(nTamPrID) + "' THEN 1 ELSE 0 END ) PROCIDNOK,"
cQuery += " SUM(CASE WHEN PROCID = '" + space(nTamPrID) + "' THEN 0 ELSE 1 END ) PROCIDOK "
cQuery += " FROM (" 
cQuery += QryTRBCards(cEvento, cPeriodo, aFiliais, cBanco)
cQuery += " ) TRB "

cQuery += "GROUP BY "
If cEvento $ "R-2030|R-2040"
	cQuery += "FILIAL "
Else
	cQuery += "CNPJ "
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TAFTOT",.F.,.T.)
While ("TAFTOT")->(!Eof())
	aRet[1] += ("TAFTOT")->PROCIDOK // por NF1/FAT
	aRet[2] += ("TAFTOT")->PROCIDNOK //por NF1/FAT
	If ("TAFTOT")->PROCIDNOK == 0
		aRet[3]++ // nForOK
	Else	
		aRet[4]++ // nForNOK
	EndIf

	("TAFTOT")->( DBSkip() )
EndDo
("TAFTOT")->(dbCloseArea())

Return aRet


/*/{Protheus.doc} TafSt40XX
	Função responsável por retornar os contatores dos cards R-4010|R-4020
	@type  Function
	@author Rafael de Paula Leme
	@since 20/10/2022
/*/
Static Function TafSt40XX(cEvento, cPeriodo, aFiliais, nTotFor)

	Local cQuery     as Character
	Local cAlias     as Character
	Local cDOCAnt    as Character
	Local nForNOk    as Numeric
	Local nTamPRID40 as Numeric
	Local nI         as Numeric
	Local lConta     as Logical
	Local aRet       as Array
	Local aInfEUF 	 as Array
	Local aBind      as Character
	Local cBanco     as Character
	Local cDtConta   as Character
	Local oPrepare   as Object
	
	Default cEvento  := ""
	Default cPeriodo := ""
	Default aFiliais := {}
	Default nTotFor  := 0

	aInfEUF   := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	cQuery     := ""
	cAlias     := GetNextAlias()
	cDocAnt    := ""
	nForNOk    := 0
	nTamPRID40 := FWSX3Util():GetFieldStruct('C20_PROCID')[3]
	nI         := 0
	lConta     := .T.
	aRet       := {0, 0, 0, 0} // 1-nRetOk 2-nRetNo 3-nTotForOK 4-nTotForNOK
	cBanco 	   := Upper(AllTrim(TcGetDB()))
	cDtConta   := SuperGetMv('MV_TAFDT40',.F.,'2')
	oPrepare   := Nil
	aBind      := {}

	cQuery += " SELECT "

	If cEvento $ 'R-4040'
		cQuery += " TB1.FILIAL FILIAL, "
	ElseIf cEvento $ 'R-4010'
		cQuery += " TB2.FILIAL FILIAL, TB2.DOCPAR DOCPAR,TB2.NIF NIF,TB2.CODPAR CODPAR, TB2.MOVIMENTO MOVIMENTO, TB2.PROCIDNOK, TB2.PROCIDOK "
		cQuery += " FROM ( SELECT "
		cQuery += " TB1.FILIAL FILIAL, TB1.DOCPAR DOCPAR,TB1.NIF NIF,TB1.CODPAR CODPAR, SUM(TB1.MOVIMENTO) MOVIMENTO, "
	ElseIf cEvento $ 'R-4020'
		cQuery += " TB1.FILIAL FILIAL, TB1.DOCPAR DOCPAR, TB1.NIF NIF,TB1.CODPAR CODPAR, "
	ElseIf cEvento $ 'R-4080'
		cQuery += " TB1.FILIAL FILIAL, TB1.DOCPAR DOCPAR, "
	EndIf

	If cEvento $ 'R-4010'
		cQuery += " SUM(CASE WHEN TB1.PROCID = ? THEN ? ELSE ? END ) PROCIDNOK, "
		cQuery += " SUM(CASE WHEN TB1.PROCID = ? THEN ? ELSE ? END ) PROCIDOK "
		aadd(aBind, space(nTamPRID40))
		aadd(aBind, 1)
		aadd(aBind, 0)
		aadd(aBind, space(nTamPRID40))
		aadd(aBind, 0)
		aadd(aBind, 1)
	Else
		cQuery += " SUM(CASE WHEN TB1.PROCID = '" + space(nTamPRID40) + "' THEN 1 ELSE 0 END ) PROCIDNOK, "
		cQuery += " SUM(CASE WHEN TB1.PROCID = '" + space(nTamPRID40) + "' THEN 0 ELSE 1 END ) PROCIDOK "
	EndIf
	
	cQuery += " FROM ( " 

	If cEvento $ 'R-4010'
		cQuery += QrySt4010(cEvento, cPeriodo, aFiliais, aInfEUF,cBanco,cDtConta,@aBind)
	ElseIf cEvento $ 'R-4020'
		cQuery += QrySt4020(cEvento, cPeriodo, aFiliais, aInfEUF, cBanco,cDtConta)
	ElseIf cEvento $ 'R-4040'
		cQuery += QrySt4040(cEvento, cPeriodo, aFiliais, cBanco)
	ElseIf cEvento $ 'R-4080'
		cQuery += QrySt4080(cEvento, cPeriodo, aFiliais, aInfEUF, cBanco)		
	EndIf

	cQuery += " ) TB1 "	
	
	If cEvento $ 'R-4040'
		cQuery += " GROUP BY "
		cQuery += " TB1.FILIAL "
	ElseIf cEvento $ 'R-4010'
		cQuery += " GROUP BY "
		cQuery += " TB1.FILIAL, TB1.DOCPAR, TB1.NIF, TB1.CODPAR ) TB2 "
		cQuery += " ORDER BY "
		cQuery += " TB2.DOCPAR,TB2.NIF, TB2.CODPAR, TB2.MOVIMENTO DESC "
	ElseIf cEvento $ 'R-4020'
		cQuery += " GROUP BY "
		cQuery += " TB1.FILIAL, TB1.DOCPAR, TB1.NIF, TB1.CODPAR "
		cQuery += " ORDER BY "
		cQuery += " TB1.DOCPAR, TB1.NIF, TB1.CODPAR "
	ElseIf cEvento $ 'R-4080'
		cQuery += " GROUP BY "
		cQuery += " TB1.FILIAL, TB1.DOCPAR "
		cQuery += " ORDER BY "
		cQuery += " TB1.DOCPAR "
	EndIf

	If cEvento != 'R-4010'
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)
	Else
		oPrepare := FwExecStatement():New(cQuery)
		For nI := 1 To Len(aBind)
			If Valtype(aBind[nI]) == 'C'
				oPrepare:setString( nI, aBind[nI] )
			ElseIf Valtype(aBind[nI]) == 'N'
				oPrepare:setNumeric( nI, aBind[nI] )
			ElseIf Valtype(aBind[nI]) == 'A'
				oPrepare:setIn( nI, aBind[nI] )
			Endif
		Next nI

		oPrepare:cbasequery := oPrepare:getfixquery()
		oPrepare:OpenAlias(cAlias)

		aSize(aBind,0)
	EndIf

	While (cAlias)->(!Eof())
		
		If cEvento $ 'R-4010|R-4020|R-4080' .and. cDOCAnt <> (cAlias)->DOCPAR + Iif(cEvento $ 'R-4010|R-4020',(cAlias)->(NIF+CODPAR), "")
			If cEvento == 'R-4010'
				lConta := (cAlias)->MOVIMENTO > 0
			EndIF
			If lConta
				nTotFor++
			EndIf
		EndIf

		If lConta
			aRet[1] += (cAlias)->PROCIDOK  //APURADO
			aRet[2] += (cAlias)->PROCIDNOK //PENDENTE APURAÇÃO
			
			nForNOk := (cAlias)->PROCIDNOK //PENDENTE APURAÇÃO
			If nForNOk == 0
				aRet[3]++ // nForOK
			Else	
				aRet[4]++ // nForNOK
			EndIf
		EndIf

		If !cEvento $ 'R-4040'
			cDOCAnt := (cAlias)->DOCPAR + Iif(cEvento $ 'R-4010|R-4020',(cAlias)->(NIF+CODPAR), "")
		EndIf

		(cAlias)->( DBSkip() )
	EndDo
	
	(cAlias)->(dbCloseArea())
	If oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := Nil
	EndIf

Return aRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QrySt4010
Função com a query para retorno dos registros a serem apurados no evento R-4010 das rotinas NFS, FAT e PAG

@author Rafael Leme
@since 20/10/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function QrySt4010(cEvento, cPeriodo, aFiliais, aInfEUF, cBanco, cDtConta, aBind)

	Local cQuery     as Character
	Local cCompC1H   as Character
	Local cDataIni   as Character
	Local cDataFim   as Character
	Local cQryV3O    as Character
	Local nC1HCPF    as Numeric
	Local nC30CNATRE as Numeric
	Local nV3SIDNATR as Numeric
	Local nV3VCNATRE as Numeric
	Local lApuSTri   as Logical
	Local nTmPrId40  as Numeric
	Local aFilsC20   as Array
	Local aFilsLEM   as Array
	Local aFilsV3U   as Array
	Local aFilsV4B   as Array
	Local aFilsV4Q   as Array

	Default cEvento  := ""
	Default cPeriodo := ""
	Default aFiliais := {}
	Default aInfEUF  := {}
	Default cBanco	 := ""
	Default cDtConta := '2'
	Default aBind    := Nil

	cQuery     := ""
	cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1) + FWModeAccess("C1H",2) + FWModeAccess("C1H",3)))
	cDataIni   := Substr(cPeriodo,3,4) + Substr(cPeriodo,1,2) + "01" //ex: 20220201
	cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
	nC1HCPF    := TamSX3("C1H_CPF")[1]
	nC30CNATRE := TamSX3("C30_CNATRE")[1]
	nV3SIDNATR := TamSX3("V3S_IDNATR")[1]
	nV3VCNATRE := TamSX3("V3V_CNATRE")[1]
	lApuSTri   := SuperGetMv('MV_TAFSTRI',.F.,.F.)
	nTmPrId40  := TamSx3("V3U_PRID40")[1]
	aFilsC20   := Separa(StrTran(StrTran(StrTran(TafRetFilC("C20", aFiliais ),"(",""),")",""),"'",""),",")
	aFilsLEM   := Separa(StrTran(StrTran(StrTran(TafRetFilC("LEM", aFiliais ),"(",""),")",""),"'",""),",")
	aFilsV3U   := Separa(StrTran(StrTran(StrTran(TafRetFilC("V3U", aFiliais ),"(",""),")",""),"'",""),",")
	aFilsV4B   := Separa(StrTran(StrTran(StrTran(TafRetFilC("V4B", aFiliais ),"(",""),")",""),"'",""),",")
	aFilsV4Q   := Separa(StrTran(StrTran(StrTran(TafRetFilC("V4Q", aFiliais ),"(",""),")",""),"'",""),",")

	IniVarStat()

	cQryV3O := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.V3O_TRIB <> ? AND V3O.D_E_L_E_T_ = ?) "
	//--------------------------------NFS----------------------------------
	cQuery += " SELECT "
	cQuery += "	1 				MOVIMENTO, "
	cQuery += " C20.C20_FILIAL  FILIAL , "
	cQuery += " C20.C20_NUMDOC NUMERO, "
	cQuery += " C20.C20_SERIE SERIE, "
	cQuery += " C1H.C1H_CPF     DOCPAR , "
	cQuery += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
	cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? ) THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
	cQuery += " C20.C20_PRID40  PROCID   "
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))

    cQuery += " FROM " + RetSqlName("C20") + " C20 "
    
	cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "

	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = C20.C20_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		Else
			cQuery += " C1H.C1H_FILIAL = ? "
			aadd(aBind,xFilial("C1H"))
		EndIf
	EndIf

	cQuery += " AND C1H.C1H_ID = C20.C20_CODPAR "
	cQuery += " AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?) OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?)) "
    cQuery += " AND C1H.D_E_L_E_T_ = ? "
	aadd(aBind, space(nC1HCPF))
	aadd(aBind, '1')
	aadd(aBind, '1')
	aadd(aBind, Space(1))
	aadd(aBind, Space(1))
	
	cQuery += " INNER JOIN " + RetSqlName("C30") + " C30 ON "
    cQuery += "	C30.C30_FILIAL     = C20.C20_FILIAL "
    cQuery += "	AND C30.C30_CHVNF  = C20.C20_CHVNF "
    cQuery += " AND C30.C30_CNATRE <> ? "
    cQuery += " AND C30.D_E_L_E_T_ = ? "
	aadd(aBind, Space(nC30CNATRE))
	aadd(aBind, Space(1))
	
	cQuery += " LEFT JOIN " + RetSqlName("C35") + " C35 ON "
    cQuery += " C35.C35_FILIAL     = C30.C30_FILIAL "
    cQuery += " AND C35.C35_CHVNF  = C30.C30_CHVNF "
    cQuery += " AND C35.C35_NUMITE = C30.C30_NUMITE "
    cQuery += " AND C35.C35_CODITE = C30.C30_CODITE "
    cQuery += " AND C35.C35_CODTRI = ? " //IR
    cQuery += " AND C35.D_E_L_E_T_ = ? "
	aadd(aBind, '000012')
	aadd(aBind, Space(1))
	
	cQuery += " LEFT JOIN " + RetSqlName("LEM") + " LEM ON "
    cQuery += " LEM.LEM_FILIAL     = C20.C20_FILIAL "
    cQuery += " AND LEM.LEM_DOCORI = C20.C20_CHVNF "
    cQuery += " AND LEM.D_E_L_E_T_ = ? "
	aadd(aBind, Space(1))
	
	cQuery += " WHERE "
	
	If "TMPFIL" $ aFilsC20[1]
		cQuery += " C20.C20_FILIAL IN (" + aFilsC20[1] + ") "
	Else
		cQuery += " C20.C20_FILIAL IN (?) "
		aadd(aBind,aFilsC20)
	EndIf
	
	cQuery += " AND C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+" BETWEEN  ? AND ? "
    cQuery += " AND C20.C20_INDOPE = ? "
    cQuery += " AND LEM.LEM_DOCORI IS NULL "
	aadd(aBind,cDataIni)
	aadd(aBind,cDataFim)
	aadd(aBind, '0')
	
	If lApuSTri
		cQuery += " AND C30.C30_CNATRE IN " + cQryV3O
		aadd(aBind,'8')
		aadd(aBind,Space(1))
	Else
		cQuery += " AND C35.C35_CODTRI IS NOT NULL "
	EndIf
	cQuery += " AND C20.D_E_L_E_T_ = ? "
	aadd(aBind,space(1))

	cQuery += " GROUP BY C20.C20_FILIAL, C20.C20_CHVNF, C20.C20_NUMDOC, C20.C20_SERIE,C1H.C1H_CPF, C1H.C1H_PAISEX,C1H.C1H_NIF, C1H.C1H_CODPAR, C20.C20_PRID40 "

	cQuery += " UNION ALL "

	//--------------------------------FAT----------------------------------
	cQuery += " SELECT "
	cQuery += "	1            MOVIMENTO, "
	cQuery += " LEM.LEM_FILIAL FILIAL , "
    cQuery += " LEM.LEM_NUMERO NUMERO, "
	cQuery += " LEM.LEM_PREFIX SERIE, "	
	cQuery += " C1H.C1H_CPF    DOCPAR , "
	cQuery += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
	cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? ) THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
	cQuery += "	MIN(LEM.LEM_PRID40) PROCID "  
    cQuery += " FROM " + RetSqlName("LEM") + " LEM "
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))

    cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "

	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = LEM.LEM_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		Else
			cQuery += " C1H.C1H_FILIAL = ? "
			aadd(aBind,xFilial("C1H"))
		EndIf
	EndIf
    cQuery += " AND C1H.C1H_ID     = LEM.LEM_IDPART "
	cQuery += " AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?) OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?)) "
    cQuery += " AND C1H.D_E_L_E_T_ = ? "
	aadd(aBind,Space(nC1HCPF))
	aadd(aBind,'1')
	aadd(aBind,'1')
	aadd(aBind,space(1))
	aadd(aBind,space(1))
    
	cQuery += " INNER JOIN " + RetSqlName("V3S") + " V3S ON "
    cQuery += "	V3S.V3S_FILIAL      = LEM.LEM_FILIAL "
    cQuery += " AND V3S.V3S_ID      = LEM.LEM_ID "
    cQuery += " AND V3S.V3S_IDPART  = LEM.LEM_IDPART "
    cQuery += " AND V3S.V3S_NUMFAT  = LEM.LEM_NUMERO "
    cQuery += " AND V3S.V3S_IDNATR <> ? "
    cQuery += " AND V3S.D_E_L_E_T_  = ? "
	aadd(aBind,Space(nV3SIDNATR))
	aadd(aBind,space(1))
    
	cQuery += " LEFT JOIN " + RetSqlName("V47") + " V47 ON "
    cQuery += " V47.V47_FILIAL     = V3S.V3S_FILIAL "
    cQuery += " AND V47.V47_ID     = V3S.V3S_ID "
    cQuery += " AND V47.V47_IDPART = V3S.V3S_IDPART "
    cQuery += " AND V47.V47_NUMFAT = V3S.V3S_NUMFAT "
    cQuery += " AND V47.V47_IDNATR = V3S.V3S_IDNATR "
    cQuery += " AND V47.V47_DECTER = V3S.V3S_DECTER "
    cQuery += " AND V47.V47_IDTRIB = ? " //IR
    cQuery += " AND V47.D_E_L_E_T_ = ? "
	aadd(aBind,'000012')
	aadd(aBind,space(1))

	cQuery += " WHERE "
    
	If "TMPFIL" $ aFilsLEM[1]
		cQuery += " LEM.LEM_FILIAL IN (" + aFilsLEM[1] + ") "
	Else
		cQuery += " LEM.LEM_FILIAL IN (?) "
		aadd(aBind,aFilsLEM)
	EndIf

	cQuery += " AND LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+" BETWEEN  ? AND ? "
    cQuery += " AND LEM.LEM_NATTIT = ? "
	aadd(aBind,cDataIni)
	aadd(aBind,cDataFim)
	aadd(aBind,'0')

	If lApuSTri
		cQuery += " AND V3S.V3S_IDNATR IN " + cQryV3O
		aadd(aBind,'8')
		aadd(aBind,Space(1))
	Else
		cQuery += " AND V47.V47_IDTRIB IS NOT NULL "
	EndIf
    cQuery += " AND LEM.D_E_L_E_T_ = ? "
	aadd(aBind,space(1))

	cQuery += "GROUP BY LEM.LEM_FILIAL, LEM.LEM_NUMERO, LEM.LEM_PREFIX, C1H.C1H_CPF, C1H.C1H_PAISEX, C1H.C1H_NIF, C1H.C1H_CODPAR"
	
	cQuery += " UNION ALL "

	//--------------------------------PAG----------------------------------           
    cQuery += " SELECT "
	cQuery += "	1               MOVIMENTO, "
	cQuery += " V3U.V3U_FILIAL  FILIAL , "
    cQuery += " V3U.V3U_NUMERO NUMERO, "
	cQuery += " V3U.V3U_SERIE SERIE, "	
	cQuery += " C1H.C1H_CPF     DOCPAR , "
	cQuery += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
	cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? ) THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
	cQuery += "	MIN(V3U.V3U_PRID40) PROCID "
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))
	aadd(aBind, space(1))

    cQuery += " FROM " + RetSqlName("V3U") + " V3U "

    cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
    
	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = V3U.V3U_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3U.V3U_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3U.V3U_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		Else
			cQuery += " C1H.C1H_FILIAL = ? "
			aadd(aBind,xFilial("C1H"))
		EndIf
	EndIf
	
	cQuery += " AND C1H.C1H_ID     = V3U.V3U_IDPART "
	cQuery += " AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?) OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?)) "	
    cQuery += " AND C1H.D_E_L_E_T_ = ? "
	aadd(aBind,Space(nC1HCPF))
	aadd(aBind,'1')
	aadd(aBind,'1')
	aadd(aBind,space(1))
	aadd(aBind,space(1))
    
	cQuery += " INNER JOIN " + RetSqlName("V3V") + " V3V ON "
    cQuery += " V3V.V3V_FILIAL     = V3U.V3U_FILIAL "
    cQuery += " AND V3V.V3V_ID     = V3U.V3U_ID "
    cQuery += " AND V3V.V3V_CNATRE <> ? "
    cQuery += " AND V3V.D_E_L_E_T_ = ? "
	aadd(aBind,Space(nV3VCNATRE))
	aadd(aBind,space(1))

	cQuery += " INNER JOIN " + RetSqlName("V3O")  + " V3O ON "
	cQuery += " V3O.V3O_FILIAL = ? "
	cQuery += " AND V3O.V3O_ID = V3V.V3V_CNATRE "
	cQuery += " AND V3O.D_E_L_E_T_ = ? "
	aadd(aBind,xFilial("V3O"))
	aadd(aBind,space(1))

    cQuery += " LEFT JOIN " + RetSqlName("V46") + " V46 ON "
    cQuery += "	V46.V46_FILIAL     = V3V.V3V_FILIAL "
    cQuery += "	AND V46.V46_ID     = V3V.V3V_ID "
    cQuery += "	AND V46.V46_IDNAT  = V3V.V3V_CNATRE "
	cQuery += "	AND V46.V46_IDTRIB = ? " //IR
	cQuery += "	AND V46.D_E_L_E_T_ = ? " 
	aadd(aBind,'000028')
	aadd(aBind,space(1))
    
	cQuery += " WHERE "
	
	If "TMPFIL" $ aFilsV3U[1]
		cQuery += " V3U.V3U_FILIAL IN (" + aFilsV3U[1] + ") "
	Else
		cQuery += " V3U.V3U_FILIAL IN (?) "
		aadd(aBind,aFilsV3U)
	EndIf

	cQuery += " AND V3U.V3U_NATTIT = ? "
    cQuery += " AND (( V3U.V3U_DTPAGT BETWEEN ? AND ? "
	aadd(aBind,'0')
	aadd(aBind,cDataIni)
	aadd(aBind,cDataFim)
	
	If lApuSTri
		cQuery += " AND V3V.V3V_CNATRE IS NOT NULL "
		If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
			cQuery += " AND V3O.V3O_CODIGO <> ? "
			aadd(aBind,'12001')
		EndIf	
	Else
		cQuery += " AND (V46.V46_IDTRIB IS NOT NULL OR (V3O.V3O_TRIB = ? "
		aadd(aBind,'8')
		If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
			cQuery += " AND V3O.V3O_CODIGO <> ? "
			aadd(aBind,'12001')
		EndIf	
		cQuery += " ) ) "	
	EndIf
	cQuery += " ) "
	If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
		cQuery += " OR (V3U.V3U_DTPAGT BETWEEN ? AND ? "
		cQuery += " AND (( V3U.V3U_PRID40 = ? "
		cQuery += " AND ( V3U.V3U_PERAPU = ? OR V3U.V3U_PERAPU = ?)) " 
		cQuery += " OR ( V3U.V3U_PRID40 != ? AND V3U.V3U_PERAPU = ? ) " 
		cQuery += " )) "	
		cQuery += " AND V3O.V3O_CODIGO = ? "
		aadd(aBind,DtoS(DtIniLucDiv(SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4))))
		aadd(aBind,cDataFim)
		aadd(aBind,Space(nTmPrId40))
		aadd(aBind,Space(6))
		aadd(aBind,SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4))
		aadd(aBind,Space(nTmPrId40))
		aadd(aBind,SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4))
		aadd(aBind,'12001')
	EndIf
	cQuery += " )"	
	cQuery += " AND V3U.D_E_L_E_T_ = ?"
	aadd(aBind, space(1))
	
	cQuery += " GROUP BY V3U.V3U_FILIAL, V3U.V3U_NUMERO, V3U.V3U_SERIE, C1H.C1H_CPF, C1H.C1H_PAISEX, C1H.C1H_NIF, C1H.C1H_CODPAR "

	If TAFColumnPos("V4Q_ORIGEM")
		cQuery += " UNION ALL "	
		//------------------------- IMP -----------------------
		cQuery += " SELECT 						"
		cQuery += "	1              MOVIMENTO, 	"
		cQuery += " V4Q.V4Q_FILIAL    FILIAL,  	"
		cQuery += " ' '               NUMERO ,	"	
		cQuery += " ' '               SERIE ,	"
		cQuery += " V4Q.V4Q_CPF       CPFPAR, 	"
		cQuery += " ' ' 			  NIF, 		"
		cQuery += " ' ' 			  CODPAR, 	"
   		cQuery += " V4Q.V4Q_PROCID    PROCID 	"	
		cQuery += " FROM " + RetSqlName("V4Q") + " V4Q "
		cQuery += " WHERE "
		
		If "TMPFIL" $ aFilsV4Q[1]
			cQuery += " V4Q.V4Q_FILIAL IN (" + aFilsV4Q[1] + ") "
		Else
			cQuery += " V4Q.V4Q_FILIAL IN (?) "
			aadd(aBind,aFilsV4Q)
		EndIf

		cQuery += " AND V4Q.V4Q_ORIGEM = ? "
		cQuery += " AND V4Q.V4Q_ATIVO = ? "
		cQuery += " AND V4Q.V4Q_EVENTO  <> ? "
		cQuery += " AND V4Q.V4Q_PERAPU = ? "
		cQuery += " AND V4Q.D_E_L_E_T_ = ? "
		aadd(aBind,'I')
		aadd(aBind,'1')
		aadd(aBind,'E')
		aadd(aBind,cPeriodo)
		aadd(aBind,space(1))
	EndIf

	cQuery += " UNION ALL "
	
	//------------------------- PLS -----------------------
	cQuery += " SELECT "
	cQuery += "	1              MOVIMENTO, "
	cQuery += " V4B.V4B_FILIAL    FILIAL, "
	cQuery += " ' '               NUMERO, "
	cQuery += " ' '				  SERIE,  "
	cQuery += " C1H.C1H_CPF       CPFPAR, "

	cQuery += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
	cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? ) THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
    cQuery += " V4B.V4B_PRID40    PROCID "
	aadd(aBind,space(1))
	aadd(aBind,space(1))
	aadd(aBind,space(1))
	aadd(aBind,space(1))
	aadd(aBind,space(1))

	cQuery += " FROM " + RetSqlName("V4B") + " V4B "

	cQuery += "	INNER JOIN " + RetSqlName("C1H") + " C1H ON "
	cQuery += TafJoinC1H( cCompC1H , aInfEUF, "V4B.V4B_FILIAL" )
	cQuery += "	AND C1H.C1H_ID = V4B.V4B_IDPART "
	cQuery += " AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?) OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?)) "
	cQuery += " AND C1H.D_E_L_E_T_ = ? "
	aadd(aBind,Space(nC1HCPF))
	aadd(aBind,'1')
	aadd(aBind,'1')
	aadd(aBind,space(1))
	aadd(aBind,space(1))

	cQuery += " WHERE "
	
	If "TMPFIL" $ aFilsV4B[1]
		cQuery += " V4B.V4B_FILIAL IN (" + aFilsV4B[1] + ") "
	Else
		cQuery += " V4B.V4B_FILIAL IN (?) "
		aadd(aBind,aFilsV4B)
	EndIf

	cQuery += " AND V4B.V4B_DTPGTO BETWEEN ? AND ? "
	cQuery += " AND V4B.D_E_L_E_T_ = ? " 
	aadd(aBind,cDataIni)
	aadd(aBind,cDataFim)
	aadd(aBind,space(1))

	If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
		cQuery := ChangeQuery(cQuery)
	EndIf	
	
Return cQuery

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QrySt4020
Função com a query para retorno dos registros a serem apurados no evento R-4020 das rotinas NFS, FAT e PAG

@author Rafael Leme
@since 20/10/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function QrySt4020(cEvento, cPeriodo, aFiliais, aInfEUF, cBanco, cDtConta)

	Local cQuery   as Character
	Local cCompC1H as Character
	Local cFilsC20 as Character
	Local cFilsLEM as Character
	Local cFilsV3U as Character
	Local cDataIni 	 as Character
	Local cDataFim 	 as Character
	Local cQryV3O  	 as Character
	Local lApuSTri 	 as Logical
	Local lApuC20 	 as Logical
	Local nTmPrId40  as Numeric

	Default cEvento  := ""
	Default cPeriodo := ""
	Default aFiliais := {}
	Default aInfEUF  := {}
	Default cBanco   := ""
	Default cDtConta := "2"

	cQuery   := ""
	cCompC1H := Upper(AllTrim(FWModeAccess("C1H",1) + FWModeAccess("C1H",2) + FWModeAccess("C1H",3)))
	cFilsC20 := TafRetFilC("C20", aFiliais )
	cFilsLEM := TafRetFilC("LEM", aFiliais )
	cFilsV3U := TafRetFilC("V3U", aFiliais )
	cFilsV5C := TafRetFilC("V5C", aFiliais )
	cDataIni := Substr(cPeriodo,3,4) + Substr(cPeriodo,1,2) + "01" //ex: 20220201
	cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )
	nC1HCNPJ   := TamSX3("C1H_CNPJ")[1]
	nC30CNATRE := TamSX3("C30_CNATRE")[1]
	nV3SIDNATR := TamSX3("V3S_IDNATR")[1]
	nV3VCNATRE := TamSX3("V3V_CNATRE")[1]
    lApuSTri   := SuperGetMv('MV_TAFSTRI',.F.,.F.)
	lApuC20	   := SuperGetMv('MV_TAFAC20',.F.,.F.)
	nTmPrId40  := TamSx3("V3U_PRID40")[1]
	
	IniVarStat()

	If lApuSTri
		cQryV3O := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.V3O_TRIB <> '8' AND V3O.D_E_L_E_T_ = ' ') "
	Else
		cQryV3O := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.D_E_L_E_T_ = ' ' AND V3O.V3O_CODIGO LIKE '20%') "
	EndIf
	
	cQuery += " SELECT TBA.FILIAL, TBA.DOCPAR, TBA.NIF, TBA.CODPAR, MIN(TBA.PROCID) PROCID, TBA.NUMERO, TBA.SERIE FROM ( "
	//--------------------------------NFS----------------------------------
	If !lApuC20
		cQuery += " SELECT DISTINCT "
		cQuery += "	C20.C20_FILIAL FILIAL, "
		cQuery += " C1H.C1H_CNPJ   DOCPAR, "
		cQuery += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
		cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
		cQuery += " C20.C20_PRID40 PROCID, "
		cQuery += "	C20.C20_CHVNF  NUMERO, "
		cQuery += "	C20.C20_SERIE  SERIE "

    	cQuery += " FROM " + RetSqlName("C20") + " C20 "
	
		cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "

		If cCompC1H == "EEE"
			cQuery += " C1H.C1H_FILIAL = C20.C20_FILIAL "
		Else
			If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
				cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
			ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
				cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
			Else
				cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
			EndIf
		EndIf

		cQuery += " AND C1H.C1H_ID     = C20.C20_CODPAR "
		cQuery += " AND ((C1H.C1H_CNPJ <> '" + Space(nC1HCNPJ) + "' AND C1H.C1H_PPES = '2') OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ')) "
    	cQuery += " AND C1H.D_E_L_E_T_ = ' ' "

		cQuery += " INNER JOIN " + RetSqlName("C30") + " C30 ON "
    	cQuery += "	C30.C30_FILIAL     = C20.C20_FILIAL "
    	cQuery += "	AND C30.C30_CHVNF  = C20.C20_CHVNF "
    	cQuery += " AND C30.C30_CNATRE <> '" + Space(nC30CNATRE) + "' "
    	cQuery += " AND C30.D_E_L_E_T_ = ' ' "

		cQuery += " LEFT JOIN " + RetSqlName("C35") + " C35 ON "
    	cQuery += " C35.C35_FILIAL     = C30.C30_FILIAL "
    	cQuery += " AND C35.C35_CHVNF  = C30.C30_CHVNF "
    	cQuery += " AND C35.C35_NUMITE = C30.C30_NUMITE "
    	cQuery += " AND C35.C35_CODITE = C30.C30_CODITE "
    	cQuery += " AND C35.C35_CODTRI = '000012' " //IR
    	cQuery += " AND C35.D_E_L_E_T_ = ' ' "

		cQuery += " LEFT JOIN " + RetSqlName("LEM") + " LEM ON "
    	cQuery += " LEM.LEM_FILIAL         = C20.C20_FILIAL "
    	cQuery += " AND     LEM.LEM_DOCORI = C20.C20_CHVNF "
    	cQuery += " AND     LEM.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE "
    	cQuery += " C20.C20_FILIAL IN " + cFilsC20
		cQuery += " AND C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+" BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "
    	cQuery += " AND C20.C20_INDOPE = '0' "
    	cQuery += " AND LEM.LEM_DOCORI IS NULL "

		If lApuSTri
			cQuery += " AND C30.C30_CNATRE IN " + cQryV3O
		Else
			cQuery += " AND (C35.C35_BASE > 0 OR (C35.C35_CODTRI IS NULL AND C30.C30_CNATRE IN " + cQryV3O + " ))"
		EndIf

		cQuery += " AND C20.D_E_L_E_T_ = ' ' "

		cQuery += " UNION ALL "

	EndIf

	//--------------------------------FAT----------------------------------
	cQuery += " Select Distinct"
	cQuery += " LEM.LEM_FILIAL FILIAL, "
	cQuery += " C1H.C1H_CNPJ   DOCPAR, "
	cQuery += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
	cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
	cQuery += "	LEM.LEM_PRID40 PROCID, "  
	cQuery += "	LEM.LEM_NUMERO NUMERO, "
	cQuery += "	LEM.LEM_PREFIX  SERIE "

    cQuery += " FROM " + RetSqlName("LEM") + " LEM "

    cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "

	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = LEM.LEM_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		Else
			cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
		EndIf
	EndIf

    cQuery += " AND C1H.C1H_ID     = LEM.LEM_IDPART "
	cQuery += " AND ((C1H.C1H_CNPJ <> '" + Space(nC1HCNPJ) + "' AND C1H.C1H_PPES = '2') OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ')) "
    cQuery += " AND C1H.D_E_L_E_T_ = ' ' "
	
	cQuery += " INNER JOIN " + RetSqlName("V3S") + " V3S ON "
    cQuery += "	V3S.V3S_FILIAL      = LEM.LEM_FILIAL "
    cQuery += " AND V3S.V3S_ID      = LEM.LEM_ID "
    cQuery += " AND V3S.V3S_IDPART  = LEM.LEM_IDPART "
    cQuery += " AND V3S.V3S_NUMFAT  = LEM.LEM_NUMERO "
    cQuery += " AND V3S.V3S_IDNATR <> '" + Space(nV3SIDNATR) + "' "
    cQuery += " AND V3S.D_E_L_E_T_  = ' ' "
	
	cQuery += " LEFT JOIN " + RetSqlName("V47") + " V47 ON "
    cQuery += " V47.V47_FILIAL     = V3S.V3S_FILIAL "
    cQuery += " AND V47.V47_ID     = V3S.V3S_ID "
    cQuery += " AND V47.V47_IDPART = V3S.V3S_IDPART "
    cQuery += " AND V47.V47_NUMFAT = V3S.V3S_NUMFAT "
    cQuery += " AND V47.V47_IDNATR = V3S.V3S_IDNATR "
    cQuery += " AND V47.V47_DECTER = V3S.V3S_DECTER "
    cQuery += " AND V47.V47_IDTRIB = '000012' " //IR
    cQuery += " AND V47.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE "
    cQuery += " LEM.LEM_FILIAL IN " + cFilsLEM
	cQuery += " AND LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+" BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
    cQuery += " AND LEM.LEM_NATTIT = '0' "

	If lApuSTri
		cQuery += " AND V3S.V3S_IDNATR IN " + cQryV3O
	Else
		cQuery += " AND (V47.V47_BASECA > 0 OR (V47.V47_IDTRIB IS NULL AND V3S.V3S_IDNATR IN " + cQryV3O + " ))"
	EndIf

    cQuery += " AND LEM.D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "
	

	//--------------------------------PAG---------------------------------- 
    cQuery += " SELECT DISTINCT"
	cQuery += " V3U.V3U_FILIAL FILIAL, "
	cQuery += " C1H.C1H_CNPJ   DOCPAR, "
	cQuery += " CASE WHEN C1H.C1H_PAISEX <> ' ' THEN C1H.C1H_NIF ELSE ' ' END NIF, "
	cQuery += " CASE WHEN (C1H.C1H_PAISEX <> ' ' AND C1H.C1H_NIF = ' ' ) THEN C1H.C1H_CODPAR ELSE ' ' END CODPAR, "
	cQuery += "	V3U.V3U_PRID40 PROCID, "
	cQuery += "	V3U.V3U_NUMERO NUMERO, "
	cQuery += "	V3U.V3U_SERIE SERIE " 
    cQuery += " FROM " + RetSqlName("V3U") + " V3U "

    cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
    
	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = V3U.V3U_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3U.V3U_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3U.V3U_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		Else
			cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
		EndIf
	EndIf
	
	cQuery += " AND C1H.C1H_ID     = V3U.V3U_IDPART "
	cQuery += " AND ((C1H.C1H_CNPJ <> '" + Space(nC1HCNPJ) + "' AND C1H.C1H_PPES = '2') OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ')) "
    cQuery += " AND C1H.D_E_L_E_T_ = ' ' "
    
	cQuery += " INNER JOIN " + RetSqlName("V3V") + " V3V ON "
    cQuery += " V3V.V3V_FILIAL     = V3U.V3U_FILIAL "
    cQuery += " AND V3V.V3V_ID     = V3U.V3U_ID "
    cQuery += " AND V3V.V3V_CNATRE <> '" + Space(nV3VCNATRE) + "' "
    cQuery += " AND V3V.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName("V3O")  + " V3O ON "
	cQuery += " V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
	cQuery += " AND V3O.V3O_ID = V3V.V3V_CNATRE "
	cQuery += " AND V3O.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("V46") + " V46 ON "
    cQuery += " V46.V46_FILIAL     = V3V.V3V_FILIAL "
    cQuery += " AND V46.V46_ID     = V3V.V3V_ID "
    cQuery += " AND V46.V46_IDNAT  = V3V.V3V_CNATRE "
	cQuery += "	AND V46.V46_IDTRIB IN ('000010', '000011', '000018', '000028', '000029', '000030' ) "
    cQuery += " AND V46.D_E_L_E_T_ = ' ' " 
    
	cQuery += " WHERE "
    cQuery += " V3U.V3U_FILIAL     IN " + cFilsV3U
	cQuery += " AND V3U.V3U_NATTIT = '0' "
    cQuery += " AND (( V3U.V3U_DTPAGT BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "

	If lApuSTri
		cQuery += " AND V3V.V3V_CNATRE IS NOT NULL "
		If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
			cQuery += " AND V3O.V3O_CODIGO <> '12001' "
		EndIf		
	Else
		cQuery += " AND (V46.V46_BASE > 0 OR (V46.V46_IDTRIB IS NULL AND (V3O.V3O_CODIGO LIKE '20%' OR (V3O.V3O_TRIB = '8' "
		If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
			cQuery += " AND V3O.V3O_CODIGO <> '12001' "
		EndIf	
		cQuery += " )))) "
	EndIf
	cQuery += " ) "

	If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
		cQuery += " OR (V3U.V3U_DTPAGT BETWEEN '" + DtoS( DtIniLucDiv( SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4)) ) + "' AND '" + cDataFim + "' "
		cQuery += " AND (( V3U.V3U_PRID40 = '" + Space(nTmPrId40) + "' "
		cQuery += " AND ( V3U.V3U_PERAPU = '" + Space(6) + "' OR V3U.V3U_PERAPU = '" + SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4)  + "')) " 
		cQuery += " OR ( V3U.V3U_PRID40 != '" + Space(nTmPrId40) + "' AND V3U.V3U_PERAPU = '" + SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4)  + "' ) " 
		cQuery += " )) "	
		cQuery += " AND V3O.V3O_CODIGO = '12001' "
	EndIf
	cQuery += " ) "
    cQuery += " AND V3U.D_E_L_E_T_ = ' ' "
	
	If TAFColumnPos("V5C_ORIGEM")
		cQuery += " UNION ALL "

		//--------------------------------IMP----------------------------------           
    	cQuery += " SELECT DISTINCT				"
		cQuery += " V5C.V5C_FILIAL FILIAL, 		"
		cQuery += " V5C.V5C_CNPJBN   DOCPAR, 	"
		cQuery += " ' '  NIF, 					"
		cQuery += " ' '  CODPAR, 				"
		cQuery += "	V5C.V5C_PROCID PROCID, 		"
		cQuery += " ' '  NUMERO, 				"
		cQuery += " ' '  SERIE 					"
    	cQuery += " FROM " + RetSqlName("V5C") + " V5C "
		cQuery += " WHERE "
    	cQuery += " V5C.V5C_FILIAL    IN " + cFilsV5C
		cQuery += " AND V5C.V5C_ORIGEM = 'I' 	 "
		cQuery += " AND V5C.V5C_ATIVO = '1' "
		cQuery += " AND V5C.V5C_EVENTO <> 'E' 	 "
    	cQuery += " AND V5C.V5C_PERAPU BETWEEN  '" + cPeriodo + "' AND '" + cPeriodo + "' "
		cQuery += " AND V5C.D_E_L_E_T_ = ' ' "
	
	EndIf

	cQuery += " ) TBA GROUP BY TBA.FILIAL, TBA.DOCPAR, TBA.NIF, TBA.CODPAR, TBA.PROCID, TBA.NUMERO, TBA.SERIE "

	If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
		cQuery := ChangeQuery(cQuery)
	EndIf	
	
Return cQuery

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QrySt4040
Função com a query para retorno dos registros a serem apurados no evento R-4040 das rotinas NFS, FAT e PAG

@author Rafael Leme
@since 08/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function QrySt4040(cEvento, cPeriodo, aFiliais, cBanco)

	Local cQuery   as Character
	Local cCompC1H as Character
	Local cFilsV4K as Character
	Local cDataIni as Character
	Local cDataFim as Character

	Default cEvento  := ""
	Default cPeriodo := ""
	Default aFiliais := {}
	Default cBanco   := ""
	

	cQuery   := ""
	cCompC1H := Upper(AllTrim(FWModeAccess("C1H",1) + FWModeAccess("C1H",2) + FWModeAccess("C1H",3)))
	cFilsV4K := TafRetFilC("V4K", aFiliais )
	cDataIni := Substr(cPeriodo,3,4) + Substr(cPeriodo,1,2) + "01" //ex: 20220201
	cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )
	
	cQuery += " SELECT "
	cQuery += " 	V4K.V4K_FILIAL FILIAL, "
	cQuery += " 	V4K.V4K_PRID40 AS PROCID  "
    cQuery += " FROM " + RetSqlName("V4K") + " V4K "
   	
	cQuery += " WHERE "
    cQuery += " 	V4K.V4K_FILIAL IN " + cFilsV4K
    cQuery += "		AND V4K.V4K_DTPAG BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "
	cQuery += "		AND V4K.V4K_INDNAT = '0' "
    cQuery += " 	AND V4K.D_E_L_E_T_ = ' ' "

	If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
		cQuery := ChangeQuery(cQuery)
	EndIf
	
Return cQuery

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QrySt4080
Função com a query para retorno dos registros a serem apurados no evento R-4080 das rotinas NFS, FAT e PAG

@author Rafael Leme
@since 08/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function QrySt4080(cEvento, cPeriodo, aFiliais, aInfEUF, cBanco)

	Local cQuery   as Character
	Local cCompC1H as Character
	Local cFilsV4K as Character
	Local cDataIni as Character
	Local cDataFim as Character

	Default cEvento  := ""
	Default cPeriodo := ""
	Default aFiliais := {}
	Default aInfEUF  := {}
	Default cBanco	 := ""

	cQuery   := ""
	cCompC1H := Upper(AllTrim(FWModeAccess("C1H",1) + FWModeAccess("C1H",2) + FWModeAccess("C1H",3)))
	cFilsV4K := TafRetFilC("V4K", aFiliais )
	cDataIni := Substr(cPeriodo,3,4) + Substr(cPeriodo,1,2) + "01" //ex: 20220201
	cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )
	nC1HCNPJ := TamSX3("C1H_CNPJ")[1]
	
	cQuery += " SELECT "
	cQuery += " 	V4K.V4K_FILIAL AS FILIAL, "
	cQuery += " 	C1H.C1H_CNPJ   AS DOCPAR, "
	cQuery += " 	V4K.V4K_PRID40 AS PROCID  "
    cQuery += " FROM " + RetSqlName("V4K") + " V4K "
    
	cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "

	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = V4K.V4K_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		Else
			cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
		EndIf
	EndIf

	cQuery += " 	AND C1H.C1H_ID     = V4K.V4K_IDPART "
	cQuery += " 	AND C1H.C1H_CNPJ   <> '" + Space(nC1HCNPJ) + "' "
	cQuery += " 	AND C1H.C1H_PPES   = '2' "
    cQuery += " 	AND C1H.D_E_L_E_T_ = ' ' "
	
	cQuery += " WHERE "
    cQuery += " 	V4K.V4K_FILIAL IN " + cFilsV4K
    cQuery += "		AND V4K.V4K_DTPAG BETWEEN  '" + cDataIni + "' AND '" + cDataFim + "' "
	cQuery += "		AND V4K.V4K_INDNAT = '1' "
    cQuery += " 	AND V4K.D_E_L_E_T_ = ' ' "

	If ! ("DB2" $ cBanco) // não chamar changequery para DB2 pois ele adiciona o read for only na query causando erro
		cQuery := ChangeQuery(cQuery)
	EndIf
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} IniVarStat        
Inicializa as variaveis statics

@Return nil 

@author Karen Honda
@since  17/11/2023
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function IniVarStat()
If __lV3UPerApu == nil
	__lV3UPerApu := TafColumnPos("V3U_PERAPU")
EndIf
Return
