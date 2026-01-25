#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*---------------------------------------------------------
/{Protheus.doc} WSQry1050()
Retorna os registros para apuração do evento R-1050

@author Carlos Eduardo Boy
@since 18/11/2022
@version 1.0
@return
---------------------------------------------------------*/
Function WSQry1050(aFil, nPage, nSize, lAll)
//Declara as variaveis
Local lHasNext  as logical
Local cQuery    as character
Local cFiliais  as character
Local cAliasRet as character
Local cAliasTot as character
Local cFields   as character
Local cWhere    as character
Local cOrder    as character
Local cQryPag   as character
Local cVersion  as character
Local cDb       as character
Local nTotReg   as numeric
Local nTmPrID  as numeric
Local lRowNum  as logical

//Inicializa as variaveis
lHasNext    := .f.
cQuery      := ''
cFiliais    := RetFil(aFil)
cAliasRet   := GetNextAlias()
cAliasTot   := GetNextAlias()
cFields     := ''
cWhere      := ''
cOrder      := ''
cQryPag     := ''
cVersion    := ''
cDb         := Alltrim(Upper(TCGetDB()))
nTotReg     := 0
nTmPrID     := TamSX3("V3X_PROCID")[1]
lRowNum     := TafBdVers( )

//Select
cFields += " V3X_FILIAL FILIAL, "
cFields += " case when V3X_PROCID = '"+ Space(nTmPrID) + "' then 'notValidated' else 'validated' end STATUS, "
cFields += " V3X_TPENTL TPENT, "
cFields += " V3X_CNPJ CNPJ "

//From
cWhere += " FROM " + RetSqlName('V3X')

//Where
cWhere += " WHERE D_E_L_E_T_ = ' ' "
cWhere += " 	AND V3X_ATIVO IN (' ', '1') "
If !empty(xFilial('V3X')) //Se tabela for exclusiva
    cWhere += " AND V3X_FILIAL IN (" + cFiliais + ") "
EndIf
if lAll //Apurar todos
    cWhere += " AND V3X_PROCID = ' ' "
endif    

//Order by
cOrder += ' ORDER BY 2, 1, 3 '

//Paginacao
if !lRowNum .And. !lAll .And. nPage > 0 .And. nSize > 0
	cQryPag += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nSize) + " ) ROWS "
	cQryPag += " FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY "
EndIf

//Monta a query completa e abre a tabela
if !lRowNum .Or. lAll
    cQuery := " SELECT " + cFields + cWhere + cOrder + cQryPag
elseif lRowNum
    cQuery := "SELECT * FROM ( "
    cQuery += "SELECT ROW_NUMBER() OVER( ORDER BY V3X_PROCID,V3X_FILIAL,V3X_TPENTL,V3X_CNPJ ) LINE_NUMBER, "
    cQuery += cFields + cWhere + " ) TAB "
    cQuery += "WHERE LINE_NUMBER BETWEEN " + cValToChar(((nPage-1)*nSize) +1) + " AND " + cValToChar(nSize*nPage)
endif

DbUseArea( .t., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasRet, .f., .t. )

//Só faz o trtamento abaixo caso não tenha clicado em [Apurar todos].
if !lRowNum .And. !lAll
    //Monta a query para somar total de registros na tabela
    cQuery := " SELECT COUNT(V3X_CNPJ) TOTREG "
    cQuery += cWhere
    DbUseArea( .t., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasTot, .f., .t. )
    nTotReg := (cAliasTot)->TOTREG
    (cAliasTot)->(DBCloseArea())

    //Habilita o botão carregar mais
    lHasNext := !(nPage * nSize) >= nTotReg
elseif lRowNum .And. !lAll
    lHasNext := WS1050HasNext( cFiliais, (nPage * nSize) )
endif

return {cAliasRet, lHasNext}

/*---------------------------------------------------------------
{Protheus.doc} WS0021050()
Monta e retorna um Json populado com os registros d evento R-1050

@author Carlos Eduardo Boy
@since 18/11/2022
@version 1.0
@return
---------------------------------------------------------------*/
Function WS0021050( aApurac, oEstruct, oValidationError )
Local lRet      as logical
Local lHasNext  as logical
Local cAlias    as character
Local cTpEnt    as character
Local nItemResp as numeric
Local nPosEnt      as numeric
Local aFieldCB  as array

Default oValidationError["registryKey"] := {}

lRet        := .t.
lHasNext    := aApurac[2]
cAlias      := aApurac[1]
cTpEnt      := ''
nItemResp   := 0
nPosEnt     := 0
aFieldCB    := StrTokArr(GetSx3Cache('V3X_TPENTL','X3_CBOX'),';')// Monta o array com os itens do combobox do campo

//Formata o tipo de entidade ligada.
aEval(aFieldCB, {|x,y| aFieldCB[y] := strtran(x ,'=',' - ') } )

while (cAlias)->(!eof())
    //Adiciona um objeto json na propriedade eventDetail
    aadd( oEstruct["eventDetail"], JsonObject():New() )
    
    //Pega o ultimo item da propriedade
    nItemResp := Len( oEstruct["eventDetail"] )

    //Guarda o tipo da entidade ligada
    nPosEnt := aScan(aFieldCB, {|x| left(x,1) == (cAlias)->(TPENT)})
    cTpEnt  := iif(nPosEnt > 0, aFieldCB[nPosEnt], '')

    //Insere os dados no Json
    oEstruct['eventDetail'][nItemResp]['status']   := alltrim((cAlias)->(STATUS))  //Status do registro.
    oEstruct['eventDetail'][nItemResp]['tpEntLig'] := EncodeUTF8(cTpEnt) //Tipo de entidade ligada.
    oEstruct['eventDetail'][nItemResp]['cnpj']     := (cAlias)->(CNPJ) //CNPJ da entidade ligada.
    oEstruct['eventDetail'][nItemResp]['key']      := (cAlias)->(CNPJ)
    oEstruct['eventDetail'][nItemResp]['branchId'] := (cAlias)->(FILIAL)
    oEstruct['eventDetail'][nItemResp]['errors']   := 'errors' //Propriedade errors que habilita o icone no frontend

    If Len(oValidationError['registryKey']) > 0
        // Chave de busca do erro da apuração
        oEstruct['eventDetail'][nItemResp]['keyValidationErrors']  := KeyError(oEstruct['eventDetail'][nItemResp], oValidationError)
    EndIf    

    (cAlias)->(dbSkip())
enddo
(cAlias)->(DbCloseArea())

oEstruct['hasNext'] := lHasNext

return lRet

/*-------------------------------------------------------------------
{Protheus.doc} RetFil()
Trata o array de filiais passado pela tela da apuracao para que fique 
no formato de execucao do IN no SQL

@return
-------------------------------------------------------------------*/
Static Function RetFil(aFil)
Local i		as Numeric
Local cRetFils	as Character

i			:= 0
cRetFils	:= ''

if !empty(xFilial('V3X')) .and. len(aFil) > 0
    for i := 1 to Len(aFil)
        if i > 1; cRetFils += " , "; endif
        cRetFils += "'" + xFilial("V3X", aFil[i][2]) + "'"
    next
else
    cRetFils := "'" + xFilial("V3X") + "'"
endIf

Return cRetFils

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author 
@since 
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)
Local cKeyError as character
Local i         as numeric
 
cKeyError       := ""
i               := 1

for i := 1 to Len(oValidationError['registryKey'])
    if alltrim(oValidationError['registryKey'][i]['id']) == alltrim(oEstruct['key'])
        cKeyError := oValidationError['registryKey'][i]['error']
    endif
next 

return ( cKeyError )

//---------------------------------------------------------------------
/*/{Protheus.doc} WS1050HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			Denis Souza
@since			08/03/2023
@param			cInFiliais	-	Cláusula IN com as filiais do grupo de empresas logado
@param			nRegFim		-	Identificador do último registro retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Function WS1050HasNext( cInFiliais, nRegFim )

Local cAliasMax	:= GetNextAlias()
Local lHasNext	:= .F.
Local cBanco    := TcGetDb()
Local cAtivo    := ''

Default cInFiliais := ''
Default nRegFim := 0

cInFiliais  := "%" + "(" + cInFiliais + ")" + "%"
cAtivo      :=  "%" + "(' ', '1')" + "%"

If cBanco != "OPENEDGE"
	BeginSQL Alias cAliasMax
        SELECT MAX( LINE_NUMBER ) MAX_LINE FROM (
            SELECT ROW_NUMBER() OVER( ORDER BY V3X_PROCID,V3X_FILIAL,V3X_TPENTL,V3X_CNPJ ) LINE_NUMBER
            FROM %table:V3X% V3X
            WHERE V3X.V3X_FILIAL IN %exp:cInFiliais%
            AND V3X.V3X_ATIVO IN %exp:cAtivo% AND V3X.%notdel% 
        ) TAB
	EndSQL
ENDIF

( cAliasMax )->( DBGoTop() )

If ( cAliasMax )->( !Eof() )
	If ( cAliasMax )->MAX_LINE > nRegFim
		lHasNext := .T.
	EndIf
EndIf

( cAliasMax )->( DBCloseArea() )

Return( lHasNext )
