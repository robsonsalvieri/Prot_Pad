#include 'protheus.ch'
#include 'restful.ch'
#include "wstafgetxml.ch"

#define N_TAFKEY		01
#define N_TAFTICKET		02
#define N_DET_ERR		03
#define N_TAF_STATUS	04
#define N_XML			05
#define N_TAF_RECNO		06
#define N_XML_APP		07
#define N_TAM_RESPONSE 	07

static MAXSIZE_FILE := 850000 //bytes
static aRotinas		:= TAFRotinas( , , .T. , 2 )

//----------------------------------------------------------------------------
/*/{Protheus.doc} WSTAFGetXML

@author Luccas Curcio
@since 29/05/2017
@version 1.0
@link http://tdn.totvs.com.br/display/TAF/Web+Service+REST+-+Retorno+de+XML
/*/
//---------------------------------------------------------------------------
function WSTAFGetXML()
return
//----------------------------------------------------------------------------
/*/{Protheus.doc} WSTAFGetXML

@author Luccas Curcio
@since 29/05/2017
@version 1.0
@link http://tdn.totvs.com.br/display/TAF/Web+Service+REST+-+Retorno+de+XML

/*/
//---------------------------------------------------------------------------
wsrestful WSTAFGetXML description STR0002 //'Serviço de consulta e retorno de arquivo XML do TAF'

	wsdata ticketCode 	as	string
	wsdata registryKey 	as	string
	wsdata startRecNo	as	integer
	wsdata searchMode 	as	integer
	wsdata sourceBranch	as	string

	wsmethod get description STR0003 produces application_json //'Método para capturar arquivo XML de registros desejados'

end wsrestful

//----------------------------------------------------------------------------
/*/{Protheus.doc} GET
Método de consulta principal do Serviço WSTAFST2.

@ticketCode	- Parâmetro para retorno das informações filtrando o resultado
pelo TAFTICKET, obrigatório caso registryKey não seja informado

@registryKey	- Parâmetro para retorno das informações filtrando o resultado
pelo TAFKEY, obrigatório caso ticketCode não seja informado.

@startRecNo	- RecNo Inicial que a consulta deve considerar para o filtro dos
Registros.

@author Luccas Curcio
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
wsmethod get queryParam ticketCode, registryKey, startRecNo, sourceBranch  wsrest  WSTAFGetXML

local aQryParam		as array
local lRet 			as logical
local nI			as numeric
local cUId			as character
local aRetorno 		as array
local cFuncIPC		as character
local cFuncREST		as character
local cChave		as character
local cValorR		as character

cFuncIPC	:= ""
cFuncREST	:= "TAFWSXmlGet"
cUId		:= "HTTPTAF_" + allTrim( str( randomize( 1 , 999 ) ) )
cChave		:= "GET"
cValorR		:= "respGET"

lRet := varSetUID( cUId , .T. )

aQryParam	:= {}
aRetorno	:= {}

::SetContentType( "application/json" )

aAdd( aQryParam , ::ticketCode )
aAdd( aQryParam , ::registryKey )
aAdd( aQryParam , ::startRecNo )
aAdd( aQryParam , ::searchMode )
aAdd( aQryParam , ::sourceBranch )

::sourceBranch := IIf (ValType(::sourceBranch) == "U","",::sourceBranch)

If WSST2ValFil(::sourceBranch,@cFuncIPC)
	TAFConOut( "[WSTAFGETXML][GET] Calling TAFCALLIPC() - " + cFuncREST )
	TAFCallIPC( cFuncIPC , cFuncREST , cUId , cChave , cValorR , aQryParam )
	TAFConOut( "[WSTAFGETXML][GET] Finished TAFCALLIPC() - " + cFuncREST )

	lRet2 := varGetAD( cUId , cValorR , @aRetorno )

	if aRetorno[ 1 ]
		for nI := 1 to len( aRetorno[ 2 ] )
			::Self:SetResponse( aRetorno[ 2 , nI ] )
		next nI
	else
		SetRestFault( aRetorno[ 3 ] , aRetorno[ 4 ] )
	endif
Else
	SetRestFault(803,"O valor do campo " + "sourceBranch (TAFFIL) " + " não está cadastro no complemento de empresas.") ////"O valor do campo "#" não está cadastro no complemento de empresas."
EndIf

return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFWSXmlGet

Função encapsulada que executa o processamento do método GET

@cUId	- Parâmetro para retorno das informações filtrando o resultado
pelo TAFTICKET, obrigatório caso registryKey não seja informado

@cChave	- Parâmetro para retorno das informações filtrando o resultado
pelo TAFKEY, obrigatório caso ticketCode não seja informado.

@cValorR	- RecNo Inicial que a consulta deve considerar para o filtro dos
Registros.

@aQryParam	- RecNo Inicial que a consulta deve considerar para o filtro dos
Registros.

@author Luccas Curcio
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
function TAFWSXmlGet( cUId , cChave , cValorR , aQryParam )

local cTabST2		as character
local cTabXErp		as character
local cMod			as character
local cMsgErr		as character
local cAliasTaf		as character
local cAliasSt2		as character
local cAliasTrb		as character
local cAliasXErp	as character
local aErros		as array
local aResponse		as array
local aAuxRegs		as array
local nLastRecNo	as numeric
local nMaxRecNo		as numeric
local nSizeFile		as numeric
local nPosRot		as numeric
local lLastReg		as logical //variável não utilizada, mas mantida para caso seja necessário implementar um controle de último registro da chave de integração solicitada
local lValido		as logical //variável não utilizada, mas mantida para caso seja necessário implementar um controle de registro válido da chave de integração solicitada
local lVirgula		as logical
local oErrorBlock	as logical
local lOk			as logical
local ticketCode 	as character
local registryKey	as character
local sourceBranch 	as character
local startRecNo	as numeric
local nCodErr		as numeric

cTabST2		:= 'TAFST2'
cTabXErp	:= 'TAFXERP'
cMod		:= ''
cMsgErr		:= ''
cAliasTaf	:= ''
cAliasSt2	:= getNextAlias()
cAliasTrb	:= getNextAlias()
cAliasXErp	:= getNextAlias()
aErros		:= {}
aResponse	:= {}
aAuxRegs	:= {}
nLastRecNo	:= 0
nMaxRecNo	:= 0
nSizeFile	:= 0
nPosRot		:= 0
lLastReg	:= .F.
lValido		:= .F.
lVirgula	:= .F.
lOk			:= .T.
aRetorno	:= Array(4)
ticketCode 	 := aQryParam[1]
registryKey  := aQryParam[2]
startRecNo 	 := aQryParam[3]
sourceBranch := aQryParam[5]
nCodErr		:= 0

oErrorBlock	:= ErrorBlock( { |Obj| TAFWsXmlError( Obj , @aRetorno ) , TAFFinishWS( cChave , cUId , cValorR , aRetorno , 9 ) } )

cMsgErr := noAcento( STR0004 ) //'Não foram localizados registros válidos para a chave de busca desejada.'

do case

	case valType( startRecNo ) == "U"
		nCodErr := 101
		cMsgErr := STR0001 //"É obrigatório o envio do parâmetro startRecNo"
		lOk := .F.

	case empty( allTrim( ticketCode ) ) .and. empty( allTrim( registryKey ) )
		nCodErr := 101
		cMsgErr := STR0005 //"É obrigatório o envio do parâmetro ticketCode ou registryKey"
		lOk := .F.
endcase

if lOk
	xTAFCriaTB( , , cTabST2 , cAliasST2 , , , , , , , , @aErros , )

	if len( aErros ) > 0
		nCodErr := 102
		cMsgErr := STR0006 //"Erro na Criacao/Abertura da tabela TAFST2."
		lOk := .F.
	else
		xTAFCriaTB( , , cTabXErp , cAliasXErp , , , , , , , , @aErros , )
		if Len( aErros ) > 0
			nCodErr := 102
			cMsgErr := STR0007 //"Erro na Criacao/Abertura da tabela TAFXERP."
			lOk := .F.
		endif
	endif

	( cAliasSt2 )->( dbCloseArea() )
endif

if lOk

	nMaxRecNo	:=	TAFGetLastRcn( ticketCode , registryKey , lValido , startRecNo )
	cMod		:=	TAFxSelMod( ticketCode , registryKey )

	setResponse( @aResponse ,'{',@nSizeFile)

	if cMod == "key"
		setResponse( @aResponse ,' "type" : "registryKey"'				,@nSizeFile)
		setResponse( @aResponse ,',"code" : "' + registryKey + '"'		,@nSizeFile)
	else
		setResponse( @aResponse ,' "type" : "ticketCode"'				,@nSizeFile)
		setResponse( @aResponse ,',"code" : "' + ticketCode 	+ '"'	,@nSizeFile)
	endif

	setResponse( @aResponse ,',"items" : [',@nSizeFile)

	if nMaxRecNo > 0 .And. consultaRegs( ticketCode , registryKey , @cAliasTrb , lLastReg , lValido , startRecNo )

		while ( cAliasTrb)->( !eof() )

			if nSizeFile <= MAXSIZE_FILE

				aAuxRegs := Array(N_TAM_RESPONSE)
				aAuxRegs[N_TAFKEY] 		:= ( cAliasTrb )->TAFKEY
				aAuxRegs[N_TAFTICKET] 	:= ( cAliasTrb )->TAFTICKET
				aAuxRegs[N_TAF_RECNO]	:= ( cAliasTrb )->RECNO_TAF

				if !empty( ( cAliasTrb )->RECNO_TAF )

					TAFSeek( ( cAliasTrb )->ALIAS_TAF , @cAliasTaf , ( cAliasTrb )->RECNO_TAF )

					aAuxRegs[N_TAF_STATUS] 	:= ( cAliasTaf )->&( cAliasTaf + "_STATUS" )

					if aAuxRegs[N_TAF_STATUS] == '4'
						//CONSULTA TSS PARA PEGAR XML DE RETORNO DO RET
						begin sequence

							aAuxRegs[N_XML] := GetXmlTss(( cAliasTrb )->TAFTPREG,( cAliasTrb )->RECNO_TAF,)[12]

							if !empty( aAuxRegs[N_XML] )
								aAuxRegs[N_XML] := encode64( aAuxRegs[N_XML] )
								aAuxRegs[ N_XML_APP ] := 'TSS'
							else
								aAuxRegs[N_XML]	:=	''
								aAuxRegs[N_DET_ERR] := noAcento( 'Não foi possível encontrar o XML de retorno. Por favor verifique o arquivo de log (console.log) do TOTVS Automação Fiscal.' ) //'Não foi possível encontrar o XML de retorno. Por favor verifique o arquivo de log (console.log) do TOTVS Automação Fiscal.'
							endif

						recover

							aAuxRegs[N_XML]	:=	''
							aAuxRegs[N_DET_ERR] := noAcento( STR0008 ) //'Ocorreu um erro fatal durante a geração do XML deste registro. Por favor verifique o arquivo de log (console.log) do TOTVS Automação Fiscal.'

						end sequence

						//Tratamento para quando ocorrer erros durante o processamento
						errorBlock( oErrorBlock )

					elseif ( nPosRot := aScan( aRotinas , { |x| x[ 3 ] == cAliasTaf } ) )

						begin sequence

							aAuxRegs[N_XML] 	:= &( aRotinas[ nPosRot , 8 ] + '( , , , .T. )' )

							if !empty( aAuxRegs[N_XML] )
								aAuxRegs[N_XML] := encode64( aAuxRegs[N_XML] )
								aAuxRegs[ N_XML_APP ] := 'TAF'
							endif

						recover

							aAuxRegs[N_XML]	:=	''
							aAuxRegs[N_DET_ERR] := noAcento( STR0008 ) //'Ocorreu um erro fatal durante a geração do XML deste registro. Por favor verifique o arquivo de log (console.log) do TOTVS Automação Fiscal.'

						end sequence

						//Tratamento para quando ocorrer erros durante o processamento
						errorBlock( oErrorBlock )

					else
						aAuxRegs[N_XML] 	:= ''
						aAuxRegs[N_DET_ERR] 	:= noAcento( STR0009 ) //'O Evento deste registro não foi localizado na lista de eventos do TOTVS Automação Fiscal.'
					endif
				else
					aAuxRegs[N_XML] 	:= ''
					aAuxRegs[N_DET_ERR] 	:= noAcento( STR0010 ) //'Registro não integrado ao TOTVS Automação Fiscal.'
					aAuxRegs[N_TAF_STATUS] 		:= '-1'
				endif

				iif( lVirgula , setResponse( aResponse , ',' , @nSizeFile ) , lVirgula := .T. )

				setItensResponse( aResponse , aClone( aAuxRegs ) , cMod , ticketCode , registryKey , @nSizeFile )

				aSize( aAuxRegs , 0 )

				nLastRecNo := ( cAliasTrb )->RECST2

				//Flag de Segurança, no BD Progress não consigo utilizar o SELECT TOP
				//por esse motivo tenho que abortar o laço quando é requisitado somente
				//o ultimo registro. (quando é enviado o parâmetro searchMode)
				If lLastReg
					Exit
				EndIf
			Else
				Exit
			EndIf

			(cAliasTrb)->(dbSkip())
		EndDo

		nLastRecNo := IIf (nLastRecNo == 0,nLastRecNo := nMaxRecNo,nLastRecNo)

	Else

		aAuxRegs := array( N_TAM_RESPONSE )
		aAuxRegs[ N_TAFKEY ] 		:= registryKey
		aAuxRegs[ N_TAFTICKET ] 	:= ticketCode
		aAuxRegs[ N_DET_ERR ] 		:= cMsgErr

		setItensResponse( @aResponse , aClone( aAuxRegs ) , cMod , ticketCode , registryKey , @nSizeFile , .F. )

		aSize( aAuxRegs , 0 )

	EndIf

	setResponse( @aResponse , ']'												,@nSizeFile )
	setResponse( @aResponse , ',"lastRecNo" : ' + allTrim( str( nLastRecNo ) )	,@nSizeFile)
	setResponse( @aResponse , ',"maxRecNo" : ' 	+ allTrim( str( nMaxRecNo ) )	,@nSizeFile )
	setResponse( @aResponse , '}'												,@nSizeFile )

endif

if select( cAliasTrb ) > 0
	( cAliasTrb )->( dbCloseArea() )
endif

( cAliasXErp )->( dbCloseArea() )

aRetorno[ 1 ] := lOk
aRetorno[ 2 ] := aResponse
aRetorno[ 3 ] := nCodErr
aRetorno[ 4 ] := cMsgErr

TAFFinishWS( cChave , cUId , cValorR , aRetorno , 3 )

return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} setItensResponse
Função responsavel por criar os itens do response de acordo com o status
dos mesmos nas tabelas TAFST2, TAFXERP e Status do TAF.

@param oClass 		- Objeto da Classe (::Self)
@param aResponse	- Array com as informações para o Response
@param cMod		- Determina se chave do GET é por TafKey, TafTiket ou Ambos
@param cTicket		- TafTicket enviado na requisição
@param cKey		- TafKey enviado na requisição
@param nSizeFile	- Variavel para controle de paginação

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function setItensResponse( aResponse , aAuxRegs , cMod , cTicket , cKey , nSizeFile , lFoundKey )

default lFoundKey	:=	.T.

setResponse( aResponse ,'{',@nSizeFile)

if lFoundKey
	If cMod == "key"
		setResponse(  aResponse , '"ticketCode" : "'  	+ allTrim( aAuxRegs[N_TAFTICKET] ) 	+ '"'	,@nSizeFile)
	Else
		setResponse( aResponse , '"registryKey" : "' 	+ allTrim( aAuxRegs[N_TAFKEY] ) 	+ '"'	,@nSizeFile)
	EndIf

	setResponse( aResponse , ',"status" : "' 			+ aAuxRegs[N_TAF_STATUS] + '"'				,@nSizeFile)

	if !empty( aAuxRegs[N_XML] )
		setResponse( aResponse , ',"xml" : "' 			+ aAuxRegs[N_XML] + '"'					,@nSizeFile)
		setResponse( aResponse , ',"messageApp" : "' 	+ aAuxRegs[N_XML_APP] + '"'				,@nSizeFile)
	else
		setResponse( aResponse , ',"error" : "' 		+ aAuxRegs[N_DET_ERR] + '"'				,@nSizeFile)
	endif
else
	If cMod == "ticket"
		setResponse(  aResponse , '"ticketCode" : "'  	+ allTrim( aAuxRegs[N_TAFTICKET]) 	+ '"'	,@nSizeFile)
	Else
		setResponse( aResponse , '"registryKey" : "' + allTrim(aAuxRegs[N_TAFKEY]) 	+ '"'		,@nSizeFile)
	EndIf

	setResponse( aResponse , ',"error" : "' 			+ aAuxRegs[N_DET_ERR] + '"'				,@nSizeFile)
endif

setResponse( aResponse ,'}',@nSizeFile)

return nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} setResponse
Realiza a atribuição do Response e soma o tamanho do conteúdo do atributo
para controle da paginação prevenindo assim erros de estouro de memória.

@param oClass 		- Objeto da Classe (::Self)
@param cContent		- Conteudo do Response
@param nSizeFile	- Variavel para soma do conteudo (bytes)

@return Nil

@author Evandro dos Santos O. Teixeira
@since 09/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function setResponse(aResponse,cContent,nSizeFile)
	nSizeFile += Len(cContent)
	aAdd(aResponse,cContent)
Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} consultaRegs
Realiza a consulta dos registros para retorno do método GET.

@param cTicket 		- tafTicket enviado na requisição
@param cKey	 		- tafKey enviado na requisição
@param cAliasTrb 		- Alias que a consulta deve utilizar para retorno das informações
@param lLast			- Filtro para retorno somente do ultimo item.
@param lValido			- Filtro para retorno somente dos registros válidos.
@param nStartRecNo	- RecNo Inicial para a consulta

@return lRet		- Informa se a consulta retorno dados.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function consultaRegs(cTicket,cKey,cAliasTrb,lLast,lValido,nStartRecNo)

	Local cQry 		as character
	Local cTafTicket 	as character
	Local cTafKey		as character
	Local cWhere		as character
	Local cJoin		as character
	Local cBanco		as character
	Local aRecs		as array
	Local lRet			as logical

	cQry 		:= ""
	cTafTicket	:= ""
	cTafKey	:= ""
	cWhere		:= ""
	cJoin		:= ""
	cBanco		:= ""
	aRecs		:= {}
	lRet		:= .F.

	Default lLast		:= .F.
	Default lValido	:= .F.
	Default cTicket 	:= ""
	Default cKey 	  	:= ""

	cTafTicket	:= AllTrim(cTicket)
	cTafKey 	:= AllTrim(cKey)
	cBanco		:= Upper(AllTrim(TcGetDB()))

	If !Empty(cTafTicket) .And.  !Empty(cTafKey)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
		cWhere += " AND ST2.TAFKEY = '" + cTafKey + "'"
		cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	ElseIf !Empty(cTafTicket)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
		cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	Else

		cWhere := " ST2.TAFKEY = '" + cTafKey + "'"
		cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	EndIf

	If lValido
		cWhere += " AND ST2.TAFSTATUS = '3' AND XERP.TAFSTATUS = '1' "
	EndIf

	cWhere += " AND ST2.R_E_C_N_O_ >= " + AllTrim(Str(nStartRecNo))

	cJoin := " LEFT JOIN TAFXERP XERP ON  ST2.TAFKEY = XERP.TAFKEY "
	cJoin += " AND ST2.TAFTICKET = XERP.TAFTICKET "
	cJoin += " AND XERP.D_E_L_E_T_ <> '*' "

	If lLast
		If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|MYSQL|POSTGRES" ) )
			cQry := " SELECT TOP 1 ST2.TAFFIL TAFFIL "
		ElseIf cBanco == "INFORMIX"
			cQry := " SELECT FIRST 1 ST2.TAFFIL TAFFIL "
		Else
			cQry := " SELECT ST2.TAFFIL TAFFIL "
		EndIf
	Else
		cQry := " SELECT ST2.TAFFIL TAFFIL "
	EndIf

	cQry += ", ST2.R_E_C_N_O_ 	RECST2 "
	cQry += ", XERP.R_E_C_N_O_ 	RECXERP "
	cQry += ", ST2.TAFSTATUS 	ST2_STATUS "
	cQry += ", ST2.TAFSEQ 		ST2_SEQ "
	cQry += ", ST2.TAFKEY 		TAFKEY "
	cQry += ", ST2.TAFTICKET 	TAFTICKET "
	cQry += ", ST2.TAFTPREG 	TAFTPREG "
	cQry += ", XERP.TAFSTATUS 	XERP_STATUS "
	cQry += ", XERP.TAFALIAS  	ALIAS_TAF "
	cQry += ", XERP.TAFRECNO	 	RECNO_TAF "

	cQry += " FROM TAFST2 ST2 "
	cQry += cJoin
 	cQry += " WHERE "
 	cQry += cWhere

 	If lLast .And. cBanco == "ORACLE"
		cQry += " AND ROWNUM <= 1"
	EndIf

	cQry += " GROUP BY ST2.R_E_C_N_O_ "
	cQry += " , ST2.TAFFIL "
	cQry += ", XERP.R_E_C_N_O_ "
	cQry += ", ST2.TAFSTATUS "
	cQry += ", ST2.TAFSEQ "
	cQry += ", ST2.TAFKEY "
	cQry += ", ST2.TAFTICKET "
	cQry += ", ST2.TAFTPREG "
	cQry += ", XERP.TAFSTATUS "
	cQry += ", XERP.TAFALIAS "
	cQry += ", XERP.TAFRECNO "

	If lLast
		If cBanco == "DB2"
			cQry += " ORDER BY ST2.R_E_C_N_O_ DESC "
			cQry += " FETCH FIRST 1 ROWS ONLY "
		Elseif cBanco $ "POSTGRES|MYSQL"
			cQry += " ORDER BY ST2.R_E_C_N_O_ DESC LIMIT 1 "
		Else
			cQry += " ORDER BY ST2.R_E_C_N_O_ DESC "
		Endif
	Else
		cQry += " ORDER BY ST2.R_E_C_N_O_
	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) ,cAliasTrb)

	lRet := !Empty((cAliasTrb)->RECST2)

Return (lRet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} seekTAF
Realiza o posicionamento do registro no TAF.
Essa função é executada dentro de um laço que percorre a tabela TAFXERP,
por esse motivo é solicitado o TAFALIAS da TAFXERP e o alias a ser posicionado
evitando o uso desnecessário do dbSelectArea já que os registros costumam
a estar em ordem de alias.

@param cAliasXErp 	- Alias da tabela no campo TAFALIAS na tabela TAFXERP
@param cAliasTaf	 	- Alias do registro a ser posicionado
@param nRecno		 	- RecNo do Registro a ser posicionado

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function seekTAF(cAliasXErp,cAliasTaf,nRecno)

	//Evito ficar abrindo a área desnecessariamente
	If cAliasTaf != cAliasXErp
		cAliasTaf := cAliasXErp
		dbSelectArea(cAliasTaf)
		dbSetOrder(1)
	EndIf
	(cAliasTaf)->(dbGoTo(nRecno))

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} GetXmlTSS
Realiza a consulta do evento no TSS.

@param cEvento	 	- Evento para consulta
@param nRecno		- RecNo do Registro a ser posicionado
@param cFilTAF		- Filial do TAF

@author Leonardo Kichitaro
@since 05/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Function GetXmlTSS( cEvento as character, nRecno as numeric, cFilTaf as character,;
					lCosultTrans as logical, cIdEntidade as character,;
					lRetResponse as logical )

Local aRetTSS     as array
Local aEventos    as array
Local aParamFil   as array
Local cRecnos     as character
Local cStsConsult as character
Local lCallApi    as logical

Private aGetTSS   as array

Default lRetResponse := .F.

aEventos     := {}
aGetTSS      := {}
aRetTSS      := Array(12)
aParamFil    := Array(6)
cStsConsult  := ""
lCallApi     := .T.
aParamFil[1] := .T.
aParamFil[2] := cFilTaf
aParamFil[3] := AllTrim(SM0->M0_FILIAL)
aParamFil[4] := AllTrim(SM0->M0_CGC)
aParamFil[5] := AllTrim(SM0->M0_INSC)
aParamFil[6] := ""

cRecnos := IIf(nRecno > 0, AllTrim(Str(nRecno)), '')

//Carrega os eventos
aAdd( aEventos, TAFRotinas( AllTrim(cEvento), 4, .F., 2 ) )

If lCosultTrans
	cStsConsult := "'2','3'"
	If lRetResponse
		cStsConsult += ",'4'"
	EndIf
Else
	If lRetResponse
		cStsConsult += "'3','4'"
	Else 
		cStsConsult := "3" //Status unicos posso passar sem aspas
	EndIf
EndIf

//Realiza a consulta no TSS
aGetTSS := TAFProc5Tss(.T.,aEventos,cStsConsult,,cRecnos,.F.,,{aParamFil},,,,.F.,@cIdEntidade,,,,,,,,lRetResponse, lCallApi)

If Len(aGetTSS) > 0
	If Len(aGetTSS[1]) > 0
		aRetTSS[01] := aGetTSS[1][1]:cAMBIENTE
		aRetTSS[02] := aGetTSS[1][1]:cCHAVE
		aRetTSS[03] := aGetTSS[1][1]:cCODIGO
		aRetTSS[04] := aGetTSS[1][1]:cCODRECEITA
		aRetTSS[05] := aGetTSS[1][1]:cDETSTATUS
		aRetTSS[06] := aGetTSS[1][1]:cDSCRECEITA
		aRetTSS[07] := aGetTSS[1][1]:cPROTOCOLO
		aRetTSS[08] := IIF(TYPE("aGetTSS[1][1]:cRECIBO") <> "U",  aGetTSS[1][1]:cRECIBO, "")
		aRetTSS[09] := IIF(TYPE("aGetTSS[1][1]:cSTATUS") <> "U",  aGetTSS[1][1]:cSTATUS, "")
		aRetTSS[10] := IIF(TYPE("aGetTSS[1][1]:cVERSAO") <> "U",  aGetTSS[1][1]:cVERSAO, "")
		aRetTSS[11] := IIF(TYPE("aGetTSS[1][1]:cXMLERRORET") <> "U" ,  aGetTSS[1][1]:cXMLERRORET, "")

		If TYPE("aGetTSS[1][1]:cXMLBASE64") <> "U" 
			aRetTSS[12] :=   aGetTSS[1][1]:cXMLBASE64
		Else
			aRetTSS[12] := IIF(TYPE("aGetTSS[1][1]:cXMLEVENTO") <> "U"  ,   aGetTSS[1][1]:cXMLEVENTO, "")
		EndIf 
	EndIf
EndIf

Return aRetTSS

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFWsXmlError

Função utilizada para tratamento de erros ocorridos no processamento

@Obj	- Objeto de errorBlock

@cChave	- array de retorno do método

@author Luccas Curcio
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
function TAFWsXmlError( Obj , aRetorno )

TAFConOut( "[WSTAFGETXML][ERROR] " + Obj:Description + Chr(10)+ Obj:ErrorStack )

aRetorno[ 1 ] := .F.
aRetorno[ 2 ] := {}
aRetorno[ 3 ] := 103
aRetorno[ 4 ] := STR0008 //'Ocorreu um erro fatal durante a geração do XML deste registro. Por favor verifique o arquivo de log (console.log) do TOTVS Automação Fiscal.'

return
