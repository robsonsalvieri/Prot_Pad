#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"

Static _lCompSA1 := Nil
Static _lCompSA2 := Nil
Static _lCompC1H := Nil 
Static _lCompSB1 := Nil
Static _lCompC1L := Nil
Static _lCompSAH := Nil
Static _lCompC1J := Nil
Static _lCompSF4 := Nil
Static _lCompC1N := Nil
Static _lCompSYD := Nil
Static _lCompC0A := Nil

/*/{Protheus.doc} FilC1H
	(Função responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno. 
/*/
function TafTSIFil(cSourceBr,cTlb) 
 Local cSql := ''  
 Local cFils   := getNextAlias()
 Local cCompTlb		:= Upper(AllTrim(FWModeAccess(cTlb,1)+FWModeAccess(cTlb,2)+FWModeAccess(cTlb,3)))
 Local aInfoEUF 	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
 Local nControl := 0
 Local aRetFil := {}

Default cSourceBr := cEmpAnt+cFilAnt

    	cSql := " SELECT DISTINCT C1E.C1E_FILTAF FROM " + RetSqlName("C1E") + " C1E "
		cSql += " LEFT JOIN " + RetSqlName("CR9") + " CR9 "
		cSql += " ON C1E.C1E_ID = CR9.CR9_ID AND C1E.C1E_VERSAO = CR9.CR9_VERSAO AND CR9.D_E_L_E_T_ = ' ' "
        cSql += " AND CR9.CR9_CODFIL = '" + cSourceBr + "'"
		cSql += " WHERE C1E.C1E_CODFIL = '" + cSourceBr + "'" 
		cSql += " AND C1E.C1E_ATIVO = '1' "
		cSql += " AND C1E.C1E_CODFIL != '<NPI>' " 
		cSql += " AND C1E.D_E_L_E_T_ = ' ' " 

		cSql := ChangeQuery(cSql) 

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cFils,.F.,.T.)
 
		If (cFils)->(!Eof())
			While (cFils)->(!Eof()) 
            nControl++

                if cCompTlb == "EEE"  
					aadd(aRetFil,AllTrim( ( cFils )->C1E_FILTAF ))
                else    
                    If cCompTlb == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
  						aadd(aRetFil,SUBSTR( AllTrim( ( cFils )->C1E_FILTAF ), 1, aInfoEUF[1] + aInfoEUF[2]) )
                    ElseIf cCompTlb == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
                       aadd(aRetFil,SUBSTR( AllTrim( ( cFils )->C1E_FILTAF ), 1, aInfoEUF[1]) )
						
                    EndIf
                endif

			(cFils)->(dbSkip())
			End
		EndIf
		( cFils )->( dbCloseArea( ) )
        
Return(aRetFil)
//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function TamEUF(cLayout)

	Local aTam 	As Array 
	Local nAte 	As Numeric
	Local nlA 	As Numeric
	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

	aTam := {0,0,0}
	nAte := Len(cLayout)
	nlA	 := 0

	For nlA := 1 to nAte
		if Upper(substring(cLayout,nlA,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nlA,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nlA ,1)) == "F" 
			++aTam[3]
		endif
	Next nlA

Return aTam
//-------------------------------------------------------------------
/*/{Protheus.doc} GetTafId()

Rertorna o _ID de cada consulta F3

/*/ 
//-------------------------------------------------------------------
function GetTafId( cAlias, cChave, nIndex )

    Local cRet := '' 

    Default cAlias := ''
    Default cChave := ''
    Default nIndex := 0

    if !empty(cAlias) .and. !empty(cChave) .and. nIndex > 0
        DbSelectArea( cAlias )
        cRet := GetAdvFval( cAlias, cAlias + '_ID', XFilial( cAlias ) + cChave, nIndex, 'NOTFOUND', .t. )
    endif
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVerProc()

Rertorna o _VERSAO

/*/ 
//-------------------------------------------------------------------
function GetVerProc( cAlias, cChave, nIndex )

Local cRet     := ''
Local aArea    := {}

Default cAlias := ''
Default cChave := ''
Default nIndex := 0

aArea := GetArea( cAlias )

if !empty(cAlias) .and. !empty(cChave) .and. nIndex > 0
    (cAlias)->( DbSetorder( nIndex ) )
    if (cAlias)->( DbSeek( XFilial( cAlias ) + cChave ) )
        cRet := (cAlias)->&(cAlias + '_VERSAO')
    endif
endif

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTafId2()

Funcão utilizada para retornar id de registro a partir de chave composta

@author Wesley Pinheiro, Denis Souza
@since 07/07/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
function GetTafId2( cAlias1, cChave1, nIndex1, cAlias2, cChave2, nIndex2 )

    Local cRet := ''

    DbSelectArea( cAlias1 )
    DBSelectArea( cAlias2 )

    cRet := GetAdvFval( cAlias1, cAlias1 + '_ID', XFilial( cAlias1 ) + cChave1, nIndex1, 'NOTFOUND', .t. )

    If cRet != "NOTFOUND"
        cRet := GetAdvFval( cAlias2, cAlias2 + '_ID', XFilial( cAlias2 ) + cRet + cChave2, nIndex2, 'NOTFOUND', .t. )
    EndIf

Return cRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} SetHashKey

Metodo responsável por montar HashMap de Cadastros

@param oHash - Objeto Hash a ser montado com as propriedades json e campos TAF
@param cKey  - Chave a ser configurada no objeto Hash
@param xVal  - Valor a ser atribuído para a chave configurada no objeto Hash 
@return oHas - Objeto Hash montado com o de-para entre propriedades json e campos TAF

@author Wesley Pinheiro
@since 03/07/2020
@version 1.0 

@Obs:
HashMap foi montado para termos um de-para das propriedades do Json com os campos do TAF.

O 1o HMSet representa o De-Para entre propriedades do Json com o TAF -> será utilizado no Model do MVC
    Ex: ( oHash, "itemId"      , "C1L_CODIGO"  )

O 2o HMSet com  representa o De-Para entre o TAF e o Json -> será utilizado para as Msg's de erro na integração
    Ex: ( oHash, "C1L_CODIGO"  , "itemId"      )

*/ 
Function SetHashKey( oHash, cKey, xVal ) 

    HMSet( oHash, cKey, xVal )

    If "#" $ xVal .and. !( "#DT#" $ xVal ) 
        xVal := SubStr( xVal, 1, Len( xVal ) - 4 ) 
    EndIf

    HMSet( oHash, xVal, cKey )

Return oHash

/*/{Protheus.doc} RetErroTaf
Metodo responsável por montar msg de error na integração

@param aError - Array com erros de commit MVC
@param oHash  - Objeto Hash com as propriedades json e campos TAF
@param aJson  - Objeto Json que foi persistido no MVC
@return       - Mensagem otimizada para auxiliar na identificação do erro que não permitiu o commit 

@author Wesley Pinheiro
@author Denis Naves
@author Carlos Nonato
@since 03/07/2020
@version 1.0 
*/ 
Function RetErroTaf( cProperty, aJson, cField, cCodError, cKey, aErroVld )

    Local cErroMsg      := ""
    Local cTipo         := ""
    Local cTitulo       := ""

    Default cField      := ""
    Default cCodError   := ""
    Default cKey        := ""
    Default aErroVld    := {}

    cTipo     := GetSx3Cache( cField, "X3_TIPO" )
    cTitulo   := AllTrim( GetSx3Cache( cField, "X3_DESCRIC" ) )
    cTamField := cValToChar( GetSx3Cache( cField, "X3_TAMANHO" ) )

    If cTipo == "D"
        cTipo := "data"
    ElseIf cTipo == "N"
        cTipo := "númerico"
    ElseIf cTipo == "L"
        cTipo := "lógico"
    Else
        cTipo := "caracter"
    EndIf

    If cCodError == "FWNOSTRUCT"

        cErroMsg := "O conteúdo informado no campo '" + cTitulo + "' ( " + cField + " ) do TAF deve ser do tipo " + cTipo + "." 

    ElseIf cCodError == "OBRIGAT"

        cErroMsg := "O campo '" + cTitulo + "' não foi preenchido no sistema de origem, "
        cErroMsg += "o preenchimento do campo ( " + cField + " ) é obrigatório no TAF."
 
    ElseIf cCodError == "NOTFOUND"
 
        cErroMsg := "Não foi encontrado o conteúdo '" + cValToChar(aJson[cProperty]) + "' informado no sistema de origem, "
        cErroMsg += "esse conteúdo corresponde ao campo '" + cTitulo + "' ( " + cField + " ) do TAF."

    ElseIf cCodError == "FWNOWIDTH"

        cErroMsg := "O conteúdo '" + cValToChar(aJson[cProperty]) + "' possui tamanho superior ao esperado pelo TAF. "
        cErroMsg += "O conteúdo informado corresponde ao campo '" + cTitulo + "' ( " + cField + " ) do TAF, o tamanho esperado para este campo é de " + cTamField + " caractere(s)."
    
    ElseIf cCodError == "FWNOLIST"

        cErroMsg := "O conteúdo '" + cValToChar(aJson[cProperty]) + "' informado no sistema de origem, não é uma opção válida "
        cErroMsg += "para o preenchimento do campo '" + cTitulo + "' ( " + cField + " ) do TAF."
    
    ElseIf cCodError == "NOTEXIST"

        cErroMsg := 'O registro '+ cKey + " informado no sistema de origem, não existe na base de dados "

    ElseIf cCodError == "FWWHEN"

        cErroMsg := "O campo '" + cTitulo + "' possui restrição 'when' no seu preenchimento."
        cErroMsg += "O preenchimento do campo ( " + cField + " ) possui restrições no TAF, verifique a condicional do campo."

    ElseIf cCodError == "TAFHLPNF017" //help tafa062

        cErroMsg := "Para esse modelo, a nota necessita de no mínimo 1 ou mais itens."

    Elseif cCodError == "UNIQUELINE"

        cErroMsg := "A estrutura enviada fere a chave única da tabela. Verique os códigos repetidos."
        if len(aErroVld) > 0
            cErroMsg += CRLF + 'Model..: ' + aErroVld[3]
            cErroMsg += CRLF + 'Erro...: ' + aErroVld[6]
            cErroMsg += CRLF + 'Solução: ' + aErroVld[7]
        endif

    Elseif cCodError == "DATE"

        cErroMsg := "Formato indevido para data no campo '" + cTitulo + "'. "
    
    Elseif cCodError == "FWFORMCANCEL"

        cErroMsg := "Violação de Integridade. Este registro é chave estrangeira em outra tabela do TAF."

    Elseif cCodError == "FWFORMBEFORE"

        cErroMsg := "Violação de integridade ao tentar excluir o registro. Para apagar o registro é necessário excluir o(s) vínculo(s) em outra(s) tabela(s)."

    Elseif cCodError == "LOADVALUE" .Or. Empty( cCodError )

        cErroMsg := "Falha ao carregar o conteúdo '" + cValToChar(aJson[cProperty]) + "' no campo '" + cTitulo + "'."

    Elseif cCodError == "INVALID"

        cErroMsg := "Conteúdo do campo '" + cProperty + "' inválido. "
    EndIf

Return cErroMsg

/*
Função responsável por validar os daados de empresa e filial para requisição
@author Henrique Fabiano Pateno Pereira
@since 03/07/2020
@version 1.0 
*/ 

function VldExecute( cSource, oJsonResp, cFilProc  )  
Local cFuncIPC		:= 	"" 
Local cCodErr		:=	""
Local cDescription	:=	"" 
Local cEmpProc 		:= 	""
Local lRet          :=  .f.

Default cFilProc 	:= 	"" 

    if valtype( cSource ) <> 'U' .and. !empty(cSource) .and. WSPrepFil( cSource,@cFuncIPC ,@cCodErr, @cDescription, @cFilProc, @cEmpProc ) 
       lRet := .t.     
   
    else  
        
        lRet  :=  .f.
        oJsonResp['success']    := .f.     
         
        if valtype( cSource ) == 'U' 
            oJsonResp['errorcode'] := '401'  
            oJsonResp['message'] := EncodeUTF8( "Não autenticado - Parâmetro <sourceBranch> ausente na requisição. Verifique o cabeçalho (header)" )
        ElseIf empty(cSource)
            oJsonResp['errorcode'] := '401'
            oJsonResp['message'] := EncodeUTF8( "Não autenticado - Parâmetro <sourceBranch> vazio na requisição. Verifique o cabeçalho (header)" )
        else 
            
            oJsonResp['errorcode']  := cCodErr
            oJsonResp['message']    := EncodeUTF8(cDescription)  
        endif

    endif 

return lRet 

/*
Metodo responsável por retornar os erros no JSon de integracao
@author Henrique Pereira
cSeekPut > quando setErroJs é invocada do método PUT, para garantir que o id da requisiçãoé o id da url.
envia-se a chave unica recebida por url. Este caso acontece quando o corpo do PUT tem id diferente do enviado na URL
@since 22/07/2020
@version 1.0 
*/
function SetErroJs( oJsonResp, cTag, aRetJs, cUrl, cErro, cSeekPut, cTagid, aTags,lBody )  
Local nJson     := 0
Local nLenObjJs :=  0

default cUrl        := 'https://tdn.totvs.com/display/TAF/TSI+-+TAF+Service+Integration#TSI-TAFServiceIntegration-Objetivo'
default cTag        := ''
default cSeekPut    := ''
default aRetJs      := {}
default cTagid      := cTag
default aTags       :=  {}
default lBody       := .T.

do case 
     
    case cErro == '400'

        oJsonResp['success'] := .f.
        oJsonResp['errorcode'] := '400'
        
        If lBody
            oJsonResp['message'] := EncodeUTF8( "Requisição mal-formada - a requisição não está de acordo com o formato esperado. Verifique o JSON (body) que está sendo enviado" )    
        Else
            oJsonResp['message'] := EncodeUTF8( "Requisição mal-formada - a requisição não está de acordo com o formato esperado. Verifique os parametros informados na requisição" )    
        EndIf
    case cErro == '401'

        oJsonResp["code"] := "401"
        oJsonResp["message"]:= EncodeUTF8("Não autenticado")
        oJsonResp["detailedMessage"]:= EncodeUTF8("O parâmetro {id} vazio ou ausente. Verifique a URL .../api/v1/tsiCostCenter/{id}")
        oJsonResp["helpUrl"]:= EncodeUTF8("https://api.totvs.com.br/")

    case cErro == '403'

        for nJson := 1 to len(aRetJs)

            if cTag == "invoice" .And. valtype( oJsonResp[cTag] ) == "U"
                oJsonResp[cTag] := {}
            endif

            aadd(oJsonResp[cTag], JsonObject():New() )
            nLenObjJs := len(oJsonResp[cTag])  
            // se foi passado aTAgs, eu uso a tag do array
            if len(aTags) > 0
                oJsonResp[cTag][nLenObjJs][aTags[1][1]] := iif(empty(cSeekPut),aRetJs[nJson][2],cSeekPut)
                oJsonResp[cTag][nLenObjJs][aTags[1][2]] := iif(empty(cSeekPut),aRetJs[nJson][3],cSeekPut)
            else 
                oJsonResp[cTag][nLenObjJs][cTagid] := iif(empty(cSeekPut),aRetJs[nJson][2],cSeekPut)
            endif

            ///Verifico se foi sucess a gravação
            if !aRetJs[nJson][1]  
                oJsonResp[cTag][nLenObjJs]["errorDescription"] := EncodeUTF8( aRetJs[nJson][3] )
                oJsonResp[cTag][nLenObjJs]["code"] := '403'
                oJsonResp[cTag][nLenObjJs]["messager"] := EncodeUTF8(aRetJs[nJson][4]) 
                oJsonResp[cTag][nLenObjJs]['success'] := .f.
                oJsonResp[cTag][nLenObjJs]['help'] := cUrl       
                //Tafconout('SetErroJS aRetJs'+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
                //Tafconout(oJsonResp:toJson()+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")      
            endif
            oJsonResp[cTag][nLenObjJs]['success'] := aRetJs[nJson][1]

        next nJson

        

    otherwise 
        oJsonResp['code']            := '404'
        oJsonResp['message']         := EncodeUTF8('Itens não Encontrados')
        oJsonResp['detailedMessage'] := EncodeUTF8('Não encontrado Itens para os parâmetros enviados')
        oJsonResp['helpUrl']         := EncodeUTF8( cUrl )    

endcase

return

/*----------------------------------------------------------------------
{Protheus.doc} TsiQryPar
Função responsável por ajustar os parametros que serão utilizados na query de consulta da entidade

Métodos GET das API's REST, basicamente contem os mesmos parametros de consulta:
idFrom   - De
IdTo     - Ate
Page     - Página
PageSize - itens por página

@author     Wesley Pinheiro
@since      10/09/2020
@version 1.0 
//----------------------------------------------------------------------*/
Function TsiQryPar( oRest, nQtdReg )

    Local cDe       := " "
    Local cAte      := 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
    Local nPage     := 1
    Local nPageSize := 10
    Default nQtdReg := 0
    
    If valtype( oRest:lGetId ) == "L" .and. oRest:lGetId

        If valtype( oRest:Id ) == "U" .or. Empty( oRest:Id )
            oRest:Id := cDe
        EndIf

        // A variavel recebe o valor 2 para não ser barrado pela validação nPageAux < ( nQtdReg )
        nQtdReg := 2 

    Else

        If valtype( oRest:idFrom ) == 'U' .or. Empty( oRest:idFrom )
            oRest:idFrom := cDe
        endif

        If valtype( oRest:idTo ) == 'U' .or. Empty( oRest:idTo )
            oRest:idTo := cAte
        endif
        
        If valtype( oRest:page ) == 'U' .or. oRest:page <= 0
            oRest:page := nPage
        endif

        if valtype( oRest:pageSize ) == 'U' .or. oRest:pageSize <= 0
            oRest:pageSize := nPageSize
        endif

        nQtdReg := oRest:pageSize + 1
    
    EndIf
    
Return


/*----------------------------------------------------------------------
{Protheus.doc} TsiLstResp
Função responsável pelo Response de métodos Gets da API
@author     Wesley Pinheiro
@since      10/09/2020
@version 1.0 
//----------------------------------------------------------------------*/
Function TsiLstResp( oRest, oJsonResp, lHasNext )

    Local lOK      := .F.
    Local cTag     := ""
    Local nCodHTTP := 0
    Local cMessage := ""
    Local cDetail  := ""
    Local cUrl     := ""

    If ( valtype( oJsonResp:GetNames( ) ) <> Nil )  .and. ( Len( oJsonResp:GetNames( ) ) > 0 )
        cTag :=  oJsonResp:GetNames( )[1]
    EndIf

    If valtype( oJsonResp[ctag] ) <> "U" .and. len( oJsonResp[ cTag ] ) > 0

        If valtype( oRest:lGetId ) == "L" .and. !( oRest:lGetId )
            oJsonResp["hasnext"] := lHasNext
        EndIf

        oRest:SetResponse( FwJsonSerialize( oJsonResp ) )
        lOK := .T.

    Else

        nCodHTTP := 404
        cMessage := EncodeUTF8( "Itens não encontrados" )
        cDetail  := EncodeUTF8( "Não encontrado itens para os parâmetros enviados" )
        cUrl     := "https://api.totvs.com.br/"

        SetRestFault( nCodHTTP, cMessage, .T.,, cDetail, cUrl )

    EndIf

    FreeObj( oJsonResp )

Return lOK

/*----------------------------------------------------------------------
{Protheus.doc} ClearV5R
Apaga Registro V5R caso o nota seja incluída com sucesso
@author Denis Souza / Wesley Pinheiro
@since 06/01/2021
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Function ClearV5R( cAlias, cKey )

Default cKey   := ''
Default cAlias := ''

// V5R_CODFIL -> Filial responsavel pelo registro, por isso utilizamos cFilAnt
if V5R->(DbSeek( xFilial("V5R") + xFilial( cAlias ) + cAlias + cKey ) ) //V5R_FILIAL, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY
	V5R->(RecLock("V5R"),.F.)
	V5R->(DbDelete())
    V5R->(MsUnlock())
endif

Return Nil


/*--------------------------------------------------------------------------------
{Protheus.doc} ValTsiData()
Função para tratar o conteudo tipo data, retornando a data no formato SQL AAAAMMDD
@author Karen Honda
@since 13/07/2021
@param xData, recebe o conteudo data, seja caracter ou tipo data
@return cDtConv, caracter, retorna a data no formato SQL AAAAMMDD.
//------------------------------------------------------------------------------*/
Function ValTsiData(xData)
Local cDtConv := ""

If valtype(xData) == 'C' .And. Len(StrTokArr(xData,"/"))==3 //15/10/2020 ou 15/10/20
    cDtConv := 'Dtos(CtoD(xData))'
Elseif valtype(xData) == 'C' .And. Len(StrTokArr(xData,"/"))==1 //20201015
    cDtConv := 'DtoS(StoD(xData))'
Elseif valtype(xData) == 'D' //integracao direta protheus
    cDtConv := 'DtoS(xData)'
EndIf

cDtConv := &(cDtConv)
If Empty(cDtConv)
    TAFConOut("TSILOG00016 Erro tipo Data " +time()+ ": Erro na conversão da data recebida." )
EndIf    
Return cDtConv


/*----------------------------------------------------------------------
{Protheus.doc} TsiGetJson()
Motor que realiza de para de campo com hash para parsear registros em json.
Monta o objeto json de forma automatizada.
@type  Static Function
@author Henrique Pereira / Denis Souza
@since 11/11/2020
//----------------------------------------------------------------------*/
Function TsiGetJson(oJsonResp, oHash, aStruct, oMdl, cTag, nPageAux, cTagsModel)
Local nAte       := 0
Local nStruct    := 0
Local nPos       := 0
Local cPosition  := ''
Local cTagJson   := ''
Local xCnt       := Nil
Default nPageAux := 0
Default cTagsModel := ""

If nPageAux == 1
    oJsonResp[cTag] := {}
EndIf
If cTag $ cTagsModel //argument #0 error, expected A->U    
    If valtype( oJsonResp[cTag] ) == 'U'
        oJsonResp[cTag] := {}
    EndIf
EndIf
aAdd( oJsonResp[cTag],JsonObject():New())
nAte := Len(aStruct)
for nStruct := 1 to nAte
    If hmget( oHash, alltrim(aStruct[nStruct][1]) + "#DT#", @cTagJson )
        nPos := Len(oJsonResp[cTag])
        xCnt := &('oMdl:GetValue(aStruct[nStruct][1])')
        If valtype( xCnt ) == 'C'
            oJsonResp[cTag][nPos][cTagJson] := dtoc(stod( xCnt ))
        Else //Tipo Data
            oJsonResp[cTag][nPos][cTagJson] := dtoc( xCnt )
        EndIf
    Elseif hmget( oHash, alltrim(aStruct[nStruct][1]), @cTagJson ) //Busca Demais Campos
        nPos := Len(oJsonResp[cTag])
        If WsTSIVldGet(@oJsonResp, aStruct[nStruct][1], @oMdl, cTag, nPos, cTagJson )                
            If hmget( oHash, alltrim(aStruct[nStruct][1]) + "#POSIC#", @cPosition ) //Executa o posicione para não retornar o ID e sim o código
                xCnt := &cPosition
                If valtype( xCnt ) == 'N'
                    oJsonResp[cTag][nPos][cTagJson] := xCnt
                Else
                    oJsonResp[cTag][nPos][cTagJson] := Alltrim( xCnt )
                EndIf
            Else
                xCnt := &('oMdl:GetValue(aStruct[nStruct][1])')
                If valtype( xCnt ) == 'N'
                    oJsonResp[cTag][nPos][cTagJson] := xCnt
                Else
                    oJsonResp[cTag][nPos][cTagJson] := AllTrim( xCnt )
                EndIf
            EndIf
        EndIf
    EndIf
Next nStruct

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} WsTSIVldGet()
No caso de conteúdo vazio para retorno ao get, retorna com 0 se for campo 
numerico e '' se for outro tipo de dado.
@author Henrique Pereira / Denis Souza
@since 12/11/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static Function WsTSIVldGet( oJsonResp, cField, oMdl, cTag, nPos, cTagJson )

    Local lRet      As Logical
    Local cTypeUtil As Character
    Local xCont     

    cTypeUtil := FWSX3Util():GetFieldType( cField )
    lRet      := .F.
    xCont     := &('alltrim(cValToChar(oMdl:GetValue("'+cField+'")))')

    If Empty(xCont) .Or. (cTypeUtil == "N" .And. xCont == "0")
        lRet := .F.
        Do Case
        Case cTypeUtil == 'N'
            oJsonResp[cTag][nPos][cTagJson] := 0
        Otherwise
            oJsonResp[cTag][nPos][cTagJson] := ''
        EndCase
    Else
        lRet := .t.
    EndIf

Return lRet

/*----------------------------------------------------------------------
{Protheus.doc} TsiUltStamp()
Retorna Ultimo Stamp Válido
@author Denis Souza
@since 20/09/2021
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Function TsiUltStamp( cAlias, lSubtrai, cAliERP, lAliErp, lCompar, cBranch )

    Local cUltStamp  As Character
    Local cNewTime   As Character
    Local cChav      As Character
    Local cNextAlias As Character
	Local cWhere     As Character
    Local aArea      As Array

    Local cSelect    As Character
    Local cFrom      As Character
    Local cOrderBy   As Character

    Default cAlias   := ''
    Default lSubtrai := .T.
    Default cAliERP  := ''
    Default lAliErp  := .F.
    Default lCompar  := .F.
    Default cBranch  := ''

    cUltStamp  := ''
    cNewTime   := ''
    cChav	   := ''
    cNextAlias := ''
	cWhere	   := ''
    aArea	   := GetArea()
    cSelect    := ''
    cFrom      := ''
    cOrderBy   := ''

    //Forca criacao
    if AliasInDic("V80") .And. Select("V80") == 0
        DbSelectArea("V80")
        V80->(DbSetOrder(1))
    endif

    if !Empty(cAlias) .And. TafColumnPos("V80_STAMP")
        if cAlias $ 'C1H|C1L|C1J|C1N|C0A' .And. lCompar
            cNextAlias := GetNextAlias()
            cWhere := "%"
            cWhere += "V80.V80_ALIAS = '" + cAlias + "' AND V80.V80_COMPAR = '1' " //Compartilhado? 1=Sim
            if lAliERP
                cWhere += "AND V80.V80_ALIERP = '" + cAliERP + "' "
            endif
            cWhere += "AND V80.D_E_L_E_T_ = ' ' "
            cWhere += "%"
            BeginSql Alias cNextAlias
                SELECT V80.V80_STAMP V80STAMP FROM %table:V80% V80 WHERE %exp:cWhere%
            EndSql
            (cNextAlias)->(DBGoTop())
            if (cNextAlias)->(!Eof())
                cUltStamp := (cNextAlias)->V80STAMP
            endif
            (cNextAlias)->(DBCloseArea())
        
        else
            if Alltrim(cBranch) == 'Todas'
                cNextAlias := GetNextAlias()
                
                cSelect := " V80.V80_FILIAL V80FILIAL "
                cFrom   := RetSqlName( "V80" ) + " V80 "
                cWhere  := " V80.D_E_L_E_T_ = ' ' AND V80.V80_ALIAS = 'C20'"
                cOrderBy:= " V80.V80_STAMP DESC "

                cSelect  := "%" + cSelect  + "%"
                cFrom    := "%" + cFrom    + "%"
                cWhere   := "%" + cWhere   + "%"
                cOrderBy := "%" + cOrderBy + "%"

                BeginSql Alias cNextAlias
                    SELECT
                        %Exp:cSelect% 
                    FROM 
                        %Exp:cFrom%
                    WHERE
                        %Exp:cWhere%
                    ORDER BY
                        %Exp:cOrderBy%
                EndSql
                
                (cNextAlias)->(DBGoTop())
                cChav := (cNextAlias)->V80FILIAL + cAlias
                (cNextAlias)->(DBCloseArea())
            else
			    cChav := xFilial("V80")  + cAlias
            endIf

			if lAliERP
				cChav += cAliERP
			endif
			DbSelectArea("V80")
			V80->(dbSetOrder(1)) //V80_FILIAL+V80_ALIAS+V80_ALIERP
			If V80->(dbSeek(cChav))
				//Não utilizo Posione porque está fazendo cache desnecessário
				cUltStamp := V80->V80_STAMP 
			Endif
        endif
		//Apenas subtrair o tempo no stamp, quando for processamento do TAFA573 e tabela C20. Não voltar o tempo quando for update fake
        If cAlias == "C20" .and. lSubtrai
            cUltStamp := TSISubStamp(cUltStamp,30,"SS") //Diminuo 30 segundos do stamp da V80
        Endif
		//Tratamento inserido para nao fazer join pela primeira vez com as tabelas do TAF e V5R,
		//no caso da jadlog, a primeira execucao faria esse join e a query ficaria travada, não executa mesmo após 5 horas
		//caso necessite fazer carga, retroagir o stamp na V80 manualmente, atraves da rotina TAFA599.
        if cAlias $ 'C1H|C1L|C1J|C1N|C0A'
            if Empty(cUltStamp) //se nao encontrar data de corte assume a data de hoje a partir das 00:00:01.001
                cUltStamp := TsiFmtDate(SUBSTR(FWTimeStamp(3),1,10)) + " 00:00:01.001"
            endif
        endif
    endif

    RestArea(aArea)

Return cUltStamp

/*----------------------------------------------------------------------
{Protheus.doc} TSIAtuStamp()
Atualiza ultimo stamp por Alias

@author Denis Souza
@since 20/09/2021
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Function TSIAtuStamp(cAlias,cUltStamp,aREGxV80,cBranch)
    
local cAliErp     := ''
local lAliERP     := .F.
local lStamp      := .F.
local lCompar     := .F.
local nAte        := 0
local nlA         := 0

Default cAlias    := ''
Default cUltStamp := ''
Default aREGxV80  := {}
Default cBranch   := ''

//Forca criacao
if AliasInDic("V80") .And. Select("V80") == 0    
    DbSelectArea("V80")
    V80->(DbSetOrder(1))
endif

lAliERP := TafColumnPos("V80_ALIERP")
lStamp  := TafColumnPos("V80_STAMP")
if _lCompSA1 == Nil
    _lCompSA1 := iif(Upper(AllTrim(FWModeAccess("SA1",1)+FWModeAccess("SA1",2)+FWModeAccess("SA1",3))) == 'CCC',.T.,.F.)
endif
if _lCompSA2 == Nil
    _lCompSA2 := iif(Upper(AllTrim(FWModeAccess("SA2",1)+FWModeAccess("SA2",2)+FWModeAccess("SA2",3))) == 'CCC',.T.,.F.)
endif
if _lCompC1H == Nil
    _lCompC1H := iif(Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3))) == 'CCC',.T.,.F.)
endif
if _lCompSB1 == Nil
    _lCompSB1 := iif(Upper(AllTrim(FWModeAccess("SB1",1)+FWModeAccess("SB1",2)+FWModeAccess("SB1",3))) == 'CCC',.T.,.F.)
endif
if _lCompC1L == Nil
    _lCompC1L := iif(Upper(AllTrim(FWModeAccess("C1L",1)+FWModeAccess("C1L",2)+FWModeAccess("C1L",3))) == 'CCC',.T.,.F.)
endif
if _lCompSAH == Nil
    _lCompSAH := iif(Upper(AllTrim(FWModeAccess("SAH",1)+FWModeAccess("SAH",2)+FWModeAccess("SAH",3))) == 'CCC',.T.,.F.)
endif
if _lCompC1J == Nil
    _lCompC1J := iif(Upper(AllTrim(FWModeAccess("C1J",1)+FWModeAccess("C1J",2)+FWModeAccess("C1J",3))) == 'CCC',.T.,.F.)
endif
if _lCompSF4 == Nil
    _lCompSF4 := iif(Upper(AllTrim(FWModeAccess("SF4",1)+FWModeAccess("SF4",2)+FWModeAccess("SF4",3))) == 'CCC',.T.,.F.)
endif
if _lCompC1N == Nil
    _lCompC1N := iif(Upper(AllTrim(FWModeAccess("C1N",1)+FWModeAccess("C1N",2)+FWModeAccess("C1N",3))) == 'CCC',.T.,.F.)
endif
if _lCompSYD == Nil
    _lCompSYD := iif(Upper(AllTrim(FWModeAccess("SYD",1)+FWModeAccess("SYD",2)+FWModeAccess("SYD",3))) == 'CCC',.T.,.F.)
endif
if _lCompC0A == Nil
    _lCompC0A := iif(Upper(AllTrim(FWModeAccess("C0A",1)+FWModeAccess("C0A",2)+FWModeAccess("C0A",3))) == 'CCC',.T.,.F.)
endif

If cAlias == "C1H"
    lCompar := TafColumnPos("V80_COMPAR") .And. _lCompSA1 .And. _lCompSA2 .And. _lCompC1H
Elseif cAlias == "C1L"
    lCompar := TafColumnPos("V80_COMPAR") .And. _lCompSB1 .And. _lCompC1L
Elseif cAlias == "C1J"
    lCompar := TafColumnPos("V80_COMPAR") .And. _lCompSAH .And. _lCompC1J
Elseif cAlias == "C1N"
    lCompar := TafColumnPos("V80_COMPAR") .And. _lCompSF4 .And. _lCompC1N
Elseif cAlias == "C0A"
    lCompar := TafColumnPos("V80_COMPAR") .And. _lCompSYD .And. _lCompC0A
Else 
    lCompar := .F.
Endif

nAte    := len( aREGxV80 )

if lAliERP .And. nAte > 0 //tratamento para participantes ou entidades que possuem mais de uma origem
    for nlA := 1 to nAte
        cAliErp   := Separa(aREGxV80[nlA][1],"|")[2]
        cUltStamp := aREGxV80[nlA][2]
        TafV80Grv( cAlias, cUltStamp, lStamp, lAliERP, cAliErp, lCompar )
    next nlA
else //mantem funcionamento do legado
    TafV80Grv( cAlias, cUltStamp, lStamp,,, lCompar, cBranch )
endif

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} TafV80Grv()
Gravacao da V80 (Quebrado em funcao para nao repetir codigo).

@author Denis Souza
@since 22/06/2022
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Static Function TafV80Grv( cAlias, cUltStamp, lStamp, lAliERP, cAliErp, lCompar, cBranch )

local lInclui     := .F.
local cChav       := ''
local cWhere      := ''
local cReg        := ''
local cNextAlias  := ''
Local cSql        := ''
Local nStatus     := ''

Default cAlias    := ''
Default cUltStamp := ''
Default lStamp    := .F.
Default lAliERP   := .F.
Default cAliErp   := ''
Default lCompar   := .F.
Default cBranch   := ''

if !Empty( cUltStamp ) .And. lStamp
    if cAlias $ 'C1H|C1L|C1J|C1N|C0A' .And. lCompar
        cNextAlias := GetNextAlias()
        cWhere := "%"
        cWhere += "V80.V80_ALIAS = '" + cAlias + "' AND V80.V80_COMPAR = '1' " //Compartilhado? 1=Sim
        if lAliERP .And. cAlias == 'C1H'
            cWhere += "AND V80.V80_ALIERP = '" + cAliErp + "' "
        endif
        cWhere += "AND V80.D_E_L_E_T_ = ' ' "
        cWhere += "%"
        BeginSql Alias cNextAlias
            SELECT V80.R_E_C_N_O_ V80REG FROM %table:V80% V80 WHERE %exp:cWhere%
        EndSql
        (cNextAlias)->(DBGoTop())
        if (cNextAlias)->(!Eof())
            cReg := (cNextAlias)->V80REG
        endif
        (cNextAlias)->(DBCloseArea())
        if Empty( cReg )
            lInclui := .T.
        else
            V80->( DbGoTo( cReg ) ) //default lInclui := .F.
        endif
    else
		V80->(DbSetOrder(1))
		cChav := xFilial("V80") + cAlias
		if lAliERP .And. !Empty(cAliErp); cChav += cAliErp; endif
		lInclui := !V80->( dbseek( cChav ) )
    endif
    Reclock( "V80", lInclui )
        if lInclui
            V80->V80_FILIAL := xFilial("V80") 
            V80->V80_ALIAS := cAlias
            if lAliERP; V80->V80_ALIERP := cAliErp; endif
            if cAlias $ 'C1H|C1L|C1J|C1N|C0A' .And. lCompar
                V80->V80_COMPAR := '1' //Compartilhado? 1=Sim
            endif
            V80->V80_STAMP := cUltStamp
        ElseIf !lInclui
            if TsiCompStamp(cUltStamp,V80->V80_STAMP) .and. !cBranch == 'Todas'  //Se for alteração e o cUltStamp for maior que a V80, gravo cUltStamp
                V80->V80_STAMP := cUltStamp
            Else
                If cBranch == 'Todas'
                    cSql := "UPDATE " +RetSqlName( "V80" )+ " SET V80_STAMP ='" + cUltStamp + "' WHERE V80_ALIAS = 'C20' AND D_E_L_E_T_=' '"
                    nStatus := tcsqlexec( cSql )
                    If nStatus < 0; V80->V80_STAMP := cUltStamp; EndIf
                EndIf
            Endif
        Endif
    V80->( msunlock() )
endif

Return Nil

/*----------------------------------------------------------------------
{Protheus.doc} GetListTsi()
Retorna a relacao das tabelas de acordo com o filtro
@Params alist pode ser enviado por referencia
@author Denis Souza
@since 20/09/2021

@return cTabs
//----------------------------------------------------------------------*/
Function GetListTsi(cType,aRet)

Local nlA   As Numeric
Local nAte  As Numeric
Local cTabs As Char

Default cType := 'Todos'
Default aRet  := {}

nlA   := 1
nAte  := 0
cTabs := ''

if cType == 'Cadastros' .Or. cType == 'Todos'
    //         Alias  Tipo  Titulo                      Abreviacao 
    aadd(aRet,{'C1H', 'C'   ,'Participante'           ,'Part.'   })
    aadd(aRet,{'C1J', 'C'   ,'Unidade Medida'	      ,'Un.Md'   })
    aadd(aRet,{'C1L', 'C'   ,'produto'		          ,'Prod.'   })
    aadd(aRet,{'C1N', 'C'   ,'Natureza\TES'	          ,'Nat.Tes' })
    aadd(aRet,{'C1P', 'C'   ,'Centro de Custo'	      ,'C.C'     })
    aadd(aRet,{'C1O', 'C'   ,'Conta Contábil'	      ,'Ct.Ctb'  })
    aadd(aRet,{'C1F', 'C'   ,'Insc Estad Estab Subst' ,'Ins.Est' })
    aadd(aRet,{'C1G', 'C'   ,'Processos'              ,'Proces.' })
    aadd(aRet,{'C3Q', 'C'   ,'Info Complem'           ,'Inf.Cmp' })
    aadd(aRet,{'C0A', 'C'   ,'NCM'	                  ,'NCM'     })
    aadd(aRet,{'T9C', 'C'   ,'Cadastro de Obras'	  ,'Obras'   })
endif
if cType == 'Movimentos' .Or. cType == 'Sem Cadastros'.Or. cType == 'Todos'
    aadd(aRet,{'C20', 'M'   ,'Nota Fiscal'	          ,'Nt.Fis.' })
endif
if cType == 'Apurações' .Or. cType == 'Sem Cadastros' .Or. cType == 'Todos'
    aadd(aRet,{'C2S', 'A'   ,'Apuração ICMS'          ,'A.Icms'   })
    aadd(aRet,{'C3J', 'A'   ,'Apuração ICMS ST'       ,'A.Icms.ST'})
    aadd(aRet,{'C5M', 'A'   ,'CPRB'	                  ,'CPRB'     })
endif

nAte := len( aRet )
for nlA := 1 to nAte
    if nlA > 1
        cTabs += ","
    endif
    cTabs += "'" + aRet[nlA][1] + "'"
next nlA

if nAte == 1 //sera por igualdade nao deve constar no IN
    cTabs := strtran(cTabs,"'","" )
endif

Return cTabs

/*----------------------------------------------------------------------
{Protheus.doc} TSISubStamp()
Subtrai o tempo passado por parâmetro ao timestamp

@author Renan Gomes
@since 03/06/2022
@return cStamp
//----------------------------------------------------------------------*/
Function TSISubStamp(cStamp,nSubTime,cType)
    Local dData      := dDatabase
    Local cHora      := Time()
    Local cNewStamp  := ""
    Local aTimeStamp := {}
    Local cDataStamp := ''
    Local cHoraStamp := ''
    Local cMinStamp  := ''
    Local cSegStamp  := ''
    Local cMSegStamp := ''

    Default cStamp   := FWTimeStamp(3 ,dData ,cHora ) //2022-06-02 19:46:58.190 
    Default nSubTime := 10
    Default cType    := "SS"
    
    //Proteção para evitar problemas nas funções StrTokArr
    If Len(cStamp) == 23 .and. At( " ", cStamp ) > 0  .and. At( ":", cStamp ) > 0  .and. At( ".", cStamp ) > 0 
        aTimeStamp       := StrTokArr(cStamp, " ")
        aTimeStamp[2]    := StrTokArr(aTimeStamp[2], ":")    //19:46:58.190 --> aRet[1] := '19', aRet[2] := '46', aRet[3] := '58.190'
        aTimeStamp[2][3] := StrTokArr(aTimeStamp[2][3], ".") //58.190       --> aRet[1] := '58', aRet[2] := '190'
        
        //Coloco em variável para facilitar a leitura
        cDataStamp       := aTimeStamp[1]           //== '2022-06-02' (Data)
        cHoraStamp       := aTimeStamp[2][1]        //== '19'         (Hora)
        cMinStamp        := aTimeStamp[2][2]        //== '46'         (Minutos)
        cSegStamp        := aTimeStamp[2][3][1]     //== '58'         (Segundos)
        cMSegStamp       := aTimeStamp[2][3][2]     //== '190'        (Milesecondos)

        If cType == "MM"
            cMinStamp :=  StrZero(val(cMinStamp)-nSubTime,3) //Subtraio o valor passado nos minutos, //Subtraio o valor passado nos segundos, tem q ser tamanho de 3 para posibilitar ficar mais que 9 minutos negativos
            if Val( cMinStamp) < 0 //Se MM ficou negativo, diminuo -1 no HH
                cHoraStamp :=  StrZero(val(cHoraStamp)-1,2)
                IF  Val(cHoraStamp) < 0   //Se HH ficou negativo, zero valor
                    cHoraStamp := "00"
                Endif
                cMinStamp := StrZero(60 - abs(val( cMinStamp)),2) //Subtraio o valor negativo de 60
            else
                cMinStamp := StrZero(val( cMinStamp),2) //volto para tamanho 2
            endif
        ElseIf cType == "SS"
            cSegStamp :=  StrZero(val(cSegStamp)-nSubTime,3) //Subtraio o valor passado nos segundos, tem q ser tamanho de 3 para posibilitar ficar mais que 9 segundos negativos
            if Val( cSegStamp) < 0 //Se SS ficou negativo, diminuo -1 no MM
                cMinStamp :=  StrZero(val(cMinStamp)-1,2)
                IF  Val(cMinStamp) < 0     //Se MM ficou negativo, zero valor
                    cHoraStamp :=  StrZero(val(cHoraStamp)-1,2)
                    IF  Val(cHoraStamp) < 0   //Se HH ficou negativo, zero valor
                        cHoraStamp := "00"
                    Endif
                    cMinStamp := StrZero(60 - abs(val( cMinStamp)),2) //Subtraio o valor negativo de 60
                Endif
                cSegStamp := StrZero(60 - abs(val(cSegStamp)),2) //Subtraio o valor negativo de 60
            else
                cSegStamp := StrZero(val( cSegStamp),2) //volto para tamanho 2
            endif
        Endif

        //Monto novo stamp com base nas variável ajustadas
        cNewStamp := cDataStamp + " " + cHoraStamp+":"+cMinStamp+":"+cSegStamp+"."+cMSegStamp

        //Proteção para não deixar o stamp novo ser maior que o stamp antigo (casos onde a hora é 00:00)
        cNewStamp := IIf(cNewStamp > cStamp,cStamp,cNewStamp)

    Endif

Return cNewStamp

/*{Protheus.doc} TsiCompStamp()
Faço a comparação entre os dois stamp pra saber se stamp1 é maior que stamp 2
@author Renan Gomes
@since 03/06/2022
@return logico.*/

Function TsiCompStamp(cStamp1,cStamp2,cDbType)
Local lRet    := .f.

Default cStamp1 := ""
Default cStamp2 := ""
Default cDbType := Upper(Alltrim(TCGetDB()))

if !Empty(cStamp1) .and. !Empty(cStamp2)

    If "ORACLE" $ cDbType  // "03.06.2022 18:36:36.893"
        aStamp1    := StrTokArr(cStamp1, " ")
        aStamp1[1] := CTOD(strTran(aStamp1[1],".","/"))
        aStamp2    := StrTokArr(cStamp2, " ")
        aStamp2[1] := CTOD(strTran(aStamp2[1],".","/"))
        
        lRet := dtos(aStamp1[1])+aStamp1[2] >  dtos(aStamp2[1])+aStamp2[2] //Não preciso deixar o stamp igual o SQL, apenas deixar o campo data como AAAAMMDD
    else
        
        lRet := cStamp1 > cStamp2

    Endif
Elseif  !Empty(cStamp1) .and. Empty(cStamp2) //Proteção para casos de V80_STAMP em branco
    lRet := .t.
Endif

Return lRet

/*{Protheus.doc} TsiFmtStamp()
Formatacao de data
Formato esperado enviado da api cData = "2022-07-31"
ORACLE
    SFT.S_T_A_M_P_  EX: 2022-07-27 18:39:17
    V80_STAMP       EX: 27.07.2022 18:39:17.460
Postgres
    SFT.S_T_A_M_P_  EX: 2022-07-27 03:21:16.917277
    V80_STAMP       EX: 2022-07-27 03:21:16.917
SQL
    SFT.S_T_A_M_P_  EX: 2022-07-27 14:41:47.550
    V80_STAMP       EX: 2022-07-27 14:41:47.550

@author Denis Souza
@since 28/07/2022
@return logico.*/
Function TsiFmtDate(cData,cDbType)

Local cDtFormat := ''

Default cData := ''
Default cDbType := Upper(Alltrim(TCGetDB()))

If "ORACLE" $ cDbType //"2022-07-27" -> "27.07.2022"
    cDtFormat := PadL(StrTokArr(cData,"-")[3],2,"0")+"."+PadL(StrTokArr(cData,"-")[2],2,"0")+"."+PadR(StrTokArr(cData,"-")[1],4,"0")
ElseIf cDbType $ "MSSQL|POSTGRES" //"2022-07-27" -> "2022-07-27"
    cDtFormat := cData
Endif

Return cDtFormat

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSetPrepare
Realiza atribuicao dos filtros, seja string ou array para
utilizacao do bind nas queries com FwExecStatement e OpenAlias

@parametro
oPrepare nil
aBind {}

@author Denis Souza
@since 28/11/2024
@version 1.0
/*/ 
//-------------------------------------------------------------------- 
Function TafSetPrepare(oObj,aBind)

Local nA := 0
Local nAte := 0

Default oObj := Nil
Default aBind := {}

nAte := len(aBind)

for nA := 1 to nAte
    if aBind[nA,2]
		oObj:SetUnsafe(nA, aBind[nA,1] )
	else
		if ValType( aBind[nA,1] ) == 'C'
        	oObj:setString( nA, aBind[nA,1] )
    	elseif Valtype(aBind[nA,1]) == 'A'
        	oObj:setIn( nA, aBind[nA,1] )
    	elseif Valtype(aBind[nA,1]) == 'N'
        	oObj:setNumeric( nA, aBind[nA,1] )
		endif
    endif
next nA

aSize(aBind,0)
aBind := {}

Return Nil
