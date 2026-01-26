#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF003
WS para retorno das informções genéricas

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF003 DESCRIPTION "API Reinf - Funções genéricas"

WSDATA companyId	AS STRING
WSDATA eventDesc	AS STRING
WSDATA code			AS STRING

WSMETHOD GET eventDescription;
	DESCRIPTION "Retorna a descrição dos eventos";
	WSSYNTAX "/eventDescription";
	PATH "eventDescription";
	PRODUCES APPLICATION_JSON

WSMETHOD GET serviceCode;
	DESCRIPTION "Retorna a descrição dos serviços";
	WSSYNTAX "/serviceCode";
	PATH "serviceCode";
	PRODUCES APPLICATION_JSON

WSMETHOD GET statusEnvironment;
	DESCRIPTION "Retorna a descrição do ambiente do TAF, parametrizado no Protheus e as informações do TSS";
	WSSYNTAX "/statusEnvironment";
	PATH "statusEnvironment";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF003
METODO GET eventdescription para retorno da descrição do evento

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/ 
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET eventDescription QUERYPARAM eventDesc WSREST WSTAF003

Local cResponse	as character
Local lRet		as logical
Local oResponse	as object

cResponse	:=	""
lRet		:=	.T.
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:eventDesc == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'eventDesc'." ) )
Else
	oResponse["description"] := EncodeUTF8( TAFRetDescr( self:eventDesc ) )

	lRet := .T.
	cResponse := FWJsonSerialize( oResponse, .T., .T.,, .F. )
	self:SetResponse( cResponse )
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF003
METODO GET serviceCode para retorno da descrição do código de serviço

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET serviceCode QUERYPARAM companyId, code WSREST WSTAF003

Local aCompany		as character
Local cResponse		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local lRet			as logical
Local oResponse		as object

aCompany	:=	{}
cResponse	:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
lRet		:=	.T.
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:code == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Código do Serviço não informado no parâmetro 'code'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			oResponse["description"] := WSDService( self:code )

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

WSMETHOD GET statusEnvironment QUERYPARAM companyId WSREST WSTAF003

Local aCompany		as character
Local cResponse		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local lRet			as logical
Local oResponse		as object
Local cIdEnt	    as character
Local aInfoTSS		as array

aCompany	:=	{}
cResponse	:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
lRet		:=	.T.
oResponse	:=	JsonObject():New()
cIdEnt      := ""
aInfoTSS	:= {}

self:SetContentType("application/json")

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			//--------------------------------------
			// Busca Entidade no TSS
			//--------------------------------------

			aInfoTSS := GetInfoTSS()

			cIdEnt  := TAFRIdEnt()
			oResponse["statusEnvironment"] := Iif( GetMV( "MV_TAFAMBR" ) == "1", "production", "restrictedProduction" )
			oResponse["entidadeTSS"]	   := cIdEnt
			oResponse["layoutReinf"] 	   := AllTrim( SuperGetMV( "MV_TAFVLRE", .F., "" ) )
			oResponse["versionTSS"]		   := EncodeUTF8(aInfoTSS[2])


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
/*/{Protheus.doc} função stática TafRetDescr
Retorna a descrição de cada evento.
Descrição oficial formalizada no manual da Reinf

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

function TafRetDescr(cEvent as character) as character

local cRetDescr			as character

default	cEvent 	:=	"" 
cRetDescr		:=	""

	do case
		case cEvent == "R-1000"
			cRetDescr	:=	"Informações do contribuinte"
		case cEvent == "R-1070" 
			cRetDescr	:=	"Tabela de processos administrativos/judiciais"
		case cEvent == "R-1050" 
			cRetDescr	:=	"Tabela de entidades ligadas"
		case cEvent == "R-2010"
			cRetDescr	:=	"Retenção contribuição previdenciária - serviços tomados"
		case cEvent == "R-2020"
			cRetDescr	:=	"Retenção contribuição previdenciária - serviços prestados"                                                                                                                                                                   
		case cEvent == "R-2030"	
			cRetDescr	:=	"Recursos recebidos por associação desportiva"                                                                                                                                                                                
		case cEvent == "R-2040"
			cRetDescr	:=	"Recursos repassados para associação desportiva"                                                                                                                                                                              
		case cEvent == "R-2050"	
			cRetDescr	:=	"Comercialização da produção por produtor rural PJ/agroindústria"
		case cEvent == "R-2055"
			cRetDescr	:=	"Aquisição de produção rural"
		case cEvent == "R-2060"
			cRetDescr	:=	"Contribuição previdenciária sobre a receita bruta - CPRB"                                                                                                                                                                    
		case cEvent == "R-2070"	
			cRetDescr	:=	"Retenções na fonte - IR, CSLL, COFINS, PIS/PASEP"                                                                                                                                                                            
		case cEvent == "R-2098"	
			cRetDescr	:=	"Reabertura dos eventos periódicos"                                                                                                                                                                                           
		case cEvent == "R-2099"	
			cRetDescr	:=	"Fechamento dos eventos periódicos"                                                                                                                                                                                           
		case cEvent == "R-3010"	
			cRetDescr	:=	"Receita de espetáculo desportivo"                                                                                                                                                                                            
		case cEvent == "R-4010"
			cRetDescr	:=	"Pagamentos/créditos a beneficiário pessoa física"
		case cEvent == "R-4020"
			cRetDescr	:=	"Pagamentos/créditos a beneficiário pessoa jurídica"
		case cEvent == "R-4040"
			cRetDescr	:=	"Pagamentos/créditos a beneficiários não identificados"
		case cEvent == "R-4080"
			cRetDescr	:=	"Retenção no Recebimento"
		case cEvent == "R-4099"
			cRetDescr	:=	"Fechamento Reabertura Série R-4000"
		case cEvent $ "R-5001|R-9001"
			cRetDescr	:=	"Informações de bases e tributos por evento"                                                                                                                                                                                  
		case cEvent $ "R-5011|R-9011"
			cRetDescr	:=	"Informações de bases e tributos consolidadas por período de apuração"
		case cEvent == "R-9000"	
			cRetDescr	:=	"Exclusão de eventos"
		case cEvent == "R-9005"
			cRetDescr	:= "Bases e tributos - retenções na fonte"
		case cEvent == "R-9015"
			cRetDescr	:= "Consolidação das retenções na fonte"
	endCase

return	cRetDescr

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function WsPagination
Executa o controle de paginação

@author Henrique Fabiano Pateno Pereira
@since 23/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

function WsPagination(nPageOrig, nSizeOrig, nPage, nPageSize)

		if (nPageOrig <> nil .and. nSizeOrig > 0 .and. nSizeOrig <> nil .and. nSizeOrig > 0)
			nPage 		:= 	nPageOrig
			nPageSize	:=	nSizeOrig
		else
			nPage 		:= 1
			nPageSize	:= 0	 
		endif

return 

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function WsRetId
Executa o tratamento dos CNPjs enviados para execução na clausu IN dentro de TAFAAPRCP 

@author Henrique Fabiano Pateno Pereira
@since 23/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

function WsRetId(aQueryString)
local cRet 	as character
local nX	as numeric

cRet	:=	''
nX		:=	0

	for nX := 1 to len(aQueryString)

		if 'ID' == upper(aQueryString[nX][1])  
			cRet	+=		"'" + alltrim(aQueryString[nX][2])  + "', "
		endif	
	next	
	if !empty(cRet)
		cRet := substr(cRet,1,len(cRet)-2)
	endif

return (cRet)
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function WsDService
Retorna a descrição do serviço 

@author Henrique Fabiano Pateno Pereira
@since 23/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
function WsDService(cCode)
local cDescript	as character

cDescript	:= ''

	dbselectarea("C8C")
	C8C->(DbSetOrder(4))
	C8C->(DbSeek(xFilial("C8C")+cCode))

	cDescript := EncodeUTF8(alltrim(C8C->C8C_DESCRI))

return cDescript
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function GetEvenTyp
Retorna um numerico identificando o tipo de evento

@author Henrique Fabiano Pateno Pereira
@since 23/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
function GetEvenTyp(cEvento)
local nTpTab	:= 0

default	cEvento := ''   

Do Case
	case cEvento $ "R-1000|R-1070" 
		 nTpTab := 1 
	case cEvento $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2060|R-2099"
		nTpTab := 2
	case cEvento $ "R-2098|R-3010|R-9000"
		nTpTab := 3
End

return nTpTab

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function WSPrepFil
Retorna um array com o numero de recno de um alias

@author Henrique Fabiano Pateno Pereira
@since 06/05/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

function WsTafRecno(cAlias)
local aRecno	as array	
aRecno	:=	{}

  (cAlias)->(DbGoTop())

  while (cAlias)->(!EOF())
	if ascan( aRecno, (cAlias)->RECNO ) == 0
		aadd(aRecno,(cAlias)->RECNO)
	endif
	(cAlias)->(dbSkip())
  enddo

return(aRecno)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function WSPrepFil
Verifica se o ambiente já está inicializado e posicionado na filial correta, caso negativo, inicializa

@author Henrique Fabiano Pateno Pereira
@since 06/05/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

function WSPrepFil(cSourceBr, cFuncIPC, cCodErr, cDescription, cFilProc, cEmpProc)
local lRet	as	logical

default cSourceBr 		:= ''  
default cFuncIPC  		:= ''
default cCodErr  		:= ''
default cDescription  	:= '' 
default cFilProc  		:= ''
default cEmpProc  		:= ''

lRet := .f.

	// verifica o cadastro de estabelecimento
	if WSST2ValFil(cSourceBr,@cFuncIPC ,@cCodErr, @cDescription, .T., @cFilProc, @cEmpProc ) 
   	
		if (type("cEmpAnt") == "U" .and. type("cFilAnt") == "U")
			RPCClearEnv()
			RPCSetType( 3 )
			RPCSetEnv(cEmpProc, cFilProc,,,'TAF',"WSXTAF")
			
		elseif (cEmpAnt <> cEmpProc) .or. (cFilAnt <> cFilProc)
			RPCClearEnv()
			RPCSetType( 3 )
			RPCSetEnv(cEmpProc, cFilProc,,,"TAF","WSXTAF" )  
		endif
		lRet := .t.
	else  
		lRet := .f.
	endif

return (lRet)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function WsProviders
Parseia os CNPJs ou CNOs enviados no corpo do post

@author Henrique Fabiano Pateno Pereira
@since 06/05/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
function WsProviders(aProviders)
local nX			as numeric
local cQryIns 		as numeric
local cTmpTbl   	as character
local aStructTmp	as array
local oTableTemp     as object

default aProviders	:= {}

//Pega um Alias para tabela temporaria.
cTmpTbl      := GetNextAlias()

//Monta a estrutura para tabela temporaria, que nesse caso terá apenas um campo.
aStructTmp   := { {'IDCHECKED', GetSx3Cache('V5S_ID','X3_TIPO'), GetSx3Cache('V5S_ID','X3_TAMANHO'), GetSx3Cache('V5S_ID','X3_DECIMAL') } }

//Crio tabela temporaria
oTableTemp := FWTemporaryTable():New(cTmpTbl, aStructTmp)
oTableTemp:Create()

for nX := 1 to len(aProviders)
	cQryIns := 'insert into ' + oTableTemp:GetRealName() + " (IDCHECKED) values " + "('" + aProviders[nX]["id"] + "')"
	TCSQLExec( cQryIns )    
next

return oTableTemp

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFil
CArrega as filiais para processamento da REINF
@author Roberto Souza
@since 21/02/2018
@version 1.0 

@aParam	

@return lRet
/*/
//-------------------------------------------------------------------
Function wsLoadFil( cFilterFil , lJob )

Local aFils		 as array
Local aTafFilGlb as array

Local cKeyEmp    as character
Local lValid	 as logical
Local lMark		 as logical
Local lCanCheck  as logical

Local nRecnoSM0	 as numeric
Local cCNPJMat	 as character
Local cTpInscr 	 as character
Local lEvAdic	 as logical

Default cFilterFil 	:= ".T."
Default lJob    	:= .F.

lShowAllFil	:= Iif( Type( "lShowAllFil" ) == "U", .F., lShowAllFil )

aFils		:= {}
aTafFilGlb  := {}
cKeyEmp   	:= cEmpAnt+cFilAnt
lValid		:= .T.
lCanCheck 	:= .T.
lMark       := .T.
nRecnoSM0	:= SM0->( Recno() )
cCNPJMat	:= AllTrim(Posicione("SM0",1,cEmpAnt+cFilAnt, "M0_CGC"))
cTpInscr 	:= Iif( Len( cCNPJMat ) == 14, "1", "2" )
lEvAdic		:= TAFColumnPos( "C1E_EVADIC" )

//Controle global para nao entrar toda vez no mecanismo abaixo, uma vez carregado as filiais em cache, havera melhor desempenho nas proximas requisicoes
GetGlbVars( ( 'aGlbTafFil' + cEmpAnt + cFilAnt ) , @aTafFilGlb )

if len( aTafFilGlb ) == 0

	If !lJob

		DbSelectArea("C1E")
		C1E->(DbSetOrder( 1 ))
		DbGoTop()

		While C1E->( !Eof() )

			If C1E->C1E_ATIVO == "1" .And. &cFilterFil
				lValid 	:= .T.
				cCNPJFil:= AllTrim(Posicione("SM0",1,cEmpAnt+C1E->C1E_FILTAF, "M0_CGC"))

				If cTpInscr == "1"
					lCanCheck := Left( cCNPJMat, 8 ) == Left( cCNPJFil, 8 ) 
				Else
					lCanCheck := cCNPJMat == AllTrim( cCNPJFil )
				EndIf

				If lCanCheck .Or. lShowAllFil
					
					//A oitava posicação se repete pois eh utilizada no TafxReinf para distinguir o marcado F_MARK
					//e se pode marcar F_CANCHECK por esse motivo nao sera removido essa posicao na insercao desse array
					lMark := lCanCheck

					/*01*/ AADD( aFils ,{lMark,;
					/*02*/ 				 C1E->C1E_ID,; 
					/*03*/ 				 AllTrim(C1E->C1E_FILTAF),; 
					/*04*/ 				 AllTrim(C1E->C1E_CODFIL),; 
					/*05*/ 				 AllTrim(C1E->C1E_NOME),; 
					/*06*/ 				 AllTrim(cCNPJFil),; 
					/*07*/ 				 AllTrim(Capital(TAF421Sts(C1E->C1E_STATUS))),;
					/*08*/				 lCanCheck,;
					/*09*/				 C1E->C1E_MATRIZ,;
					/*10*/				 Iif(lEvAdic, C1E->C1E_EVADIC, "")})
				EndIf
			EndIf	
			C1E->( DbSkip() )
		EndDo
	EndIf

	// Caso não haja filiais ativas, preenche com uma linha
	If Empty( aFils)
		AADD( aFils ,{	.F.,;
						"------",;
						"--",;
						"--",;
						"------------------------------",;
						"-------------------------","---",""})	
	else //se aFils estiver populado
		aTafFilGlb := aclone( aFils )
		if FindFunction('IsMatrizC1E')
			//Para evitar sobrecarga do serviço, só gravo em variável global se filial acessada é matriz
			if IsMatrizC1E(1)
				PutGlbVars( ( "aGlbTafFil" + cEmpAnt + cFilAnt ) , aTafFilGlb ) //inseri conteudo apenas na primeira vez na global		
			endif
		endif
		
	EndIf
Else
	if len( aFils ) == 0
		aFils := aclone( aTafFilGlb ) //apenas clona da global no aFils para ficar performatico
	endif
Endif

DbSelectArea("SM0")
SM0->(DbSeek(cKeyEmp)) /*cEmpAnt+cFilAnt*/

Return( aFils )

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFil
Pesquisa filial pelo cnpj
@author Flavio Lopes Rasta
@since 19/11/2019
@version 1.0 
/*/
//-------------------------------------------------------------------
Function WsFindFil(cCnpj)
Local aFilInfo 	as array
Local aLoadSm0	as array
Local nPosFil	as numeric

aLoadSm0 	:= FWLoadSM0()
aFilInfo	:= {}
nPosFil 	:= 0

nPosFil := aScan(aLoadSm0,{|x| x[18] == cCnpj})

if nPosFil > 0
	aFilInfo := aLoadSm0[nPosFil]
endif

Return aFilInfo

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function WsPartEx
Retorna o conteúdo do array aQueryString conforme tag enviada no cParam.

@author Rafael de Paula Leme
@since 03/05/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Function WsPartEx(aQueryString, cParam)

	Local nX        as Numeric
	Local cConteudo as Character

	Default cParam := ''

	nX       := 0
	cConteudo := ""

	For nX := 1 to Len(aQueryString)
		If cParam == Upper(aQueryString[nX][1])  
			cConteudo := AllTrim(aQueryString[nX][2])
		EndIf
	Next	

Return (cConteudo)
