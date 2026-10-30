#include 'totvs.ch'
#include 'topconn.ch'
#include 'restful.ch'
#include 'fwmvcdef.ch'

Static lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Static cUltStmp := iif(lNewCtrl, TsiUltStamp("C1O"),' ')

/*/-------------------------------------------------------------
{Protheus.doc}TSICONTAC
(Classe principal para integração das contas contabeis)
@author Carlos Eduardo
@since 17/06/2020
@param param_name, param_type, param_descr 
-------------------------------------------------------------/*/
Class TSICONTAC

Data oJObjTSI    as Object

Method New() Constructor
Method LoadQuery()
Method JSon()
Method GetJsn()

EndClass

/*---------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} New
(Método contrutor da classe TSICONTAC )
Fluxo New:
1º Monta-se a query com LoadQuery()
2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade cFinalQuery com a query final já com os parâmetros
@author Carlos Eduardo
@since 22/06/2020
@return Nil, nulo, não tem retorno.
----------------------------------------------------------------------------------------------------------------------------*/
Method New(cSourceBr) Class TSICONTAC

Self:LoadQuery(cSourceBr)

Return Nil

 /*-----------------------------------------------------------------------------------
{Protheus.doc} PrepQuery
(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
nos parâmetros variáveis, e atribui valores a tabela temporaria.
@author Carlos Eduardo
@since 08/06/2020
@return Nil, nulo, não tem retorno.
-------------------------------------------------------------------------------------*/

Method LoadQuery(cSourceBr) Class TSICONTAC

Local cDbType := Upper(Alltrim(TCGetDB()))
Local lRet    := .t.
Local cQuery  := ''
Local cNivel  := ''
Local aFilTaf := TafTSIFil(cSourceBr,'C1O')
Local cFilTaf := ''
Local nLenFil := len(aFilTaf)
Local cAlias  := GetNextAlias()
Local cTmpTbl := GetNextAlias()
Local oStGrv  := FWPreparedStatement():New()
Local oStRet  := FWPreparedStatement():New()
Local cTabCT1 := RetSqlName('CT1')
Local nI      := 0
Local cConvCpo:= ''
Local cQueryGrv  := ''
Local cQueryRet  := ''
Local lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
Local aStruct := {{'C1O_STAMP' , 'C' , 30 , 0 },;
    		      {'CT1_STAMP' , 'C' , 30 , 0 },;
                  {'CT1_DTEXIS', GetSx3Cache('CT1_DTEXIS','X3_TIPO'),GetSx3Cache('CT1_DTEXIS','X3_TAMANHO'),GetSx3Cache('CT1_DTEXIS','X3_DECIMAL')},;			      
                  {'CT1_NTSPED', GetSx3Cache('CT1_NTSPED','X3_TIPO'),GetSx3Cache('CT1_NTSPED','X3_TAMANHO'),GetSx3Cache('CT1_NTSPED','X3_DECIMAL')},;
                  {'CT1_CONTA' , GetSx3Cache('CT1_CONTA' ,'X3_TIPO'),GetSx3Cache('CT1_CONTA' ,'X3_TAMANHO'),GetSx3Cache('CT1_CONTA' ,'X3_DECIMAL')},;
			      {'CT1_DESC01', GetSx3Cache('CT1_DESC01','X3_TIPO'),GetSx3Cache('CT1_DESC01','X3_TAMANHO'),GetSx3Cache('CT1_DESC01','X3_DECIMAL')},;
                  {'CT1_CTASUP', GetSx3Cache('CT1_CTASUP','X3_TIPO'),GetSx3Cache('CT1_CTASUP','X3_TAMANHO'),GetSx3Cache('CT1_CTASUP','X3_DECIMAL')},;
                  {'C1O_NIVEL' , GetSx3Cache('C1O_NIVEL' ,'X3_TIPO'),GetSx3Cache('C1O_NIVEL' ,'X3_TAMANHO'),GetSx3Cache('C1O_NIVEL' ,'X3_DECIMAL')},;
                  {'CT1_CLASSE', GetSx3Cache('CT1_CLASSE','X3_TIPO'),GetSx3Cache('CT1_CLASSE','X3_TAMANHO'),GetSx3Cache('CT1_CLASSE','X3_DECIMAL')} }              
Private aTree   := {}
Private oQryTmp := Nil  

//Monta a string com as filiais para somar á query
for nI := 1 to nLenFil
    cFilTaf += "'" + aFilTaf[nI] + "'"
    if nI < nLenFil; cFilTaf += ','; endif
next
If empty(cFilTaf) .And. cDbType $ 'ORACLE'
    cFilTaf += "'" + Space(1) + "'"
Endif

//Converte o conteúdo do campo conforme o banco de dados usado.
If cDbType $ 'MSSQL/MSSQL7'
    cConvCpo := " convert(varchar(23), CT1.S_T_A_M_P_, 21) "
Elseif cDbType $ 'ORACLE'
    cConvCpo := " cast(to_char(CT1.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) "
Elseif cDbType $ 'POSTGRES'
    cConvCpo := " cast(to_char(CT1.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
Endif

//Preparo a query para executar o update na CT1 conforme parametros passados
cQueryGrv  := " UPDATE " + cTabCT1 + " SET D_E_L_E_T_ = ' ' WHERE CT1_FILIAL =? AND CT1_CONTA =? "
cQueryRet  := " SELECT " + cConvCpo + " STAMP FROM " + cTabCT1 + " CT1 WHERE CT1.CT1_FILIAL =? AND CT1.CT1_CONTA =? AND CT1.D_E_L_E_T_ = ' ' "

oStGrv:SetQuery(cQueryGrv)
oStRet:SetQuery(cQueryRet)

//Crio tabela temporaria
oQryTmp := FWTemporaryTable():New(cTmpTbl, aStruct)
oQryTmp:AddIndex('1', {'CT1_CONTA'} )
oQryTmp:AddIndex('2', {'C1O_NIVEL','CT1_CONTA'} )
oQryTmp:Create()

//Monto a query que servirá como base para integração.
cQuery := " SELECT "
cQuery += cConvCpo + " CT1_STAMP, " 
cQuery += "     CT1.CT1_DTEXIS, "
cQuery += "     CT1.CT1_NTSPED, "
cQuery += " 	CASE WHEN CT1.CT1_CLASSE = '1' THEN '0' ELSE '1' END CT1_CLASSE, "
cQuery += " 	'NIVEL' NIVEL, "
cQuery += " 	CT1.CT1_CONTA, "
cQuery += " 	CT1.CT1_DESC01, "
cQuery += " 	CT1.CT1_CTASUP "
cQuery += " FROM " + cTabCT1 + " CT1 "

If !lNewCtrl .OR. Empty(cUltStmp)
    cQuery += " 	LEFT JOIN " + RetSqlName('C1O') + " C1O ON C1O.C1O_FILIAL IN (" + cFilTaf + ") AND C1O.C1O_CODIGO = CT1.CT1_CONTA AND C1O.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " WHERE CT1.D_E_L_E_T_ = ' ' "
cQuery += " 	AND CT1.CT1_FILIAL = '" + xFilial('CT1') + "' "
cQuery += " 	AND CT1.CT1_BLOQ != '1' "

If !lNewCtrl .OR. Empty(cUltStmp)
    If cDbType $ "ORACLE"
        cQuery +=  		  " AND (( CT1.S_T_A_M_P_ IS NOT NULL AND ( ( CT1.S_T_A_M_P_ > TO_TIMESTAMP(C1O.C1O_STAMP,'dd.mm.yyyy hh24:mi:ss.ff') ) OR (C1O.C1O_STAMP IS NULL Length(trim(C1O.C1O_STAMP)) = 0 OR Length(trim(C1O.C1O_STAMP)) IS NULL ) ) ) "
        cQuery +=  		  " OR CT1.S_T_A_M_P_ IS NULL  AND C1O.C1O_STAMP IS NULL AND CT1.CT1_CLASSE = '2') "
    else
        cQuery +=  		  " AND (( CT1.S_T_A_M_P_ IS NOT NULL AND ( ( " + cConvCpo + " > C1O.C1O_STAMP ) OR C1O.C1O_STAMP IS NULL ) ) "
        cQuery +=  		  " OR CT1.S_T_A_M_P_ IS NULL  AND C1O.C1O_STAMP IS NULL AND CT1.CT1_CLASSE = '2') "
    endif

Else
    If cDbType $ "ORACLE"
        cQuery += " AND CT1.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff')  "
    else
        cQuery += " AND "  + cConvCpo + " > '" + Alltrim(cUltStmp) + "' "
    endif
Endif

cQuery := ChangeQuery(cQuery)
DbUseArea(.t., 'topconn', TCGenQry(, , cQuery), cAlias, .f., .t. )

while (cAlias)->(!Eof())
    cNivel := AllTrim(Str(CtbNivCta((cAlias)->CT1_CONTA)))
    if  (cTmpTbl)->(RecLock((cTmpTbl), .t. ))
        if empty((cAlias)->CT1_STAMP)
            (cTmpTbl)->CT1_STAMP := GrvStamp(xFilial('CT1'),(cAlias)->CT1_CONTA,oStGrv,oStRet)
        else     
            (cTmpTbl)->CT1_STAMP := (cAlias)->CT1_STAMP
        endif
        (cTmpTbl)->C1O_STAMP  := (cTmpTbl)->CT1_STAMP
        (cTmpTbl)->CT1_DTEXIS := stod((cAlias)->CT1_DTEXIS)
        (cTmpTbl)->CT1_NTSPED := (cAlias)->CT1_NTSPED
        (cTmpTbl)->CT1_CONTA  := (cAlias)->CT1_CONTA
        (cTmpTbl)->CT1_DESC01 := (cAlias)->CT1_DESC01
        (cTmpTbl)->CT1_CTASUP := (cAlias)->CT1_CTASUP
        (cTmpTbl)->C1O_NIVEL  := cNivel
        (cTmpTbl)->CT1_CLASSE := (cAlias)->CT1_CLASSE
        (cTmpTbl)->(DbUnLock())

        //Se ha conta de nivel superior cadastrado e se for carga(Primeira execução)
        if !empty((cAlias)->CT1_CTASUP) .and. empty((cAlias)->CT1_STAMP)
            TreeCta( (cAlias)->CT1_CONTA, cTmpTbl, val(cNivel),oStGrv,oStRet )
        endif    
    endif    
    (cAlias)->(DbSkip()) 
enddo

//Fecha tabela principal
(cAlias)->(DbCloseArea())

//Crio o JSon
Self:JSon(cTmpTbl)

//Destroi os objetos FWPreparedStatement e FWTemporaryTable 
oStGrv:Destroy()
oStRet:Destroy()
oQryTmp:Delete()

Return lRet

/*/----------------------------------------------------------------------------
{Protheus.doc}JSon
(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI)
@author Carlos Eduardo
@since 17/06/2020
@param cTmpTbl, string, Nome da tabela temporária 
-----------------------------------------------------------------------------/*/
Method JSon(cTmpTbl) Class TSICONTAC
Local nPos := 0
Local oJson := JsonObject():New()

oJson['accountsPlan'] := {}

(cTmpTbl)->(DbSetOrder(2))
(cTmpTbl)->(DbGoTop())
while (cTmpTbl)->(!eof())

    aAdd( oJson['accountsPlan'],JsonObject():New())                                 
    nPos := Len(oJson['accountsPlan']) 
    oJson['accountsPlan'][nPos]['dateInclusionChange'] := (cTmpTbl)->CT1_DTEXIS
    oJson['accountsPlan'][nPos]['spedAccountClass'   ] := (cTmpTbl)->CT1_NTSPED
    oJson['accountsPlan'][nPos]['accountCategory'    ] := (cTmpTbl)->CT1_CLASSE
    oJson['accountsPlan'][nPos]['accountLevel'       ] := (cTmpTbl)->C1O_NIVEL
    oJson['accountsPlan'][nPos]['accountCode'        ] := (cTmpTbl)->CT1_CONTA
    oJson['accountsPlan'][nPos]['currencyDescription'] := (cTmpTbl)->CT1_DESC01
    oJson['accountsPlan'][nPos]['superiorAccount'    ] := (cTmpTbl)->CT1_CTASUP
    oJson['accountsPlan'][nPos]['creationDate'       ] := (cTmpTbl)->CT1_DTEXIS
    oJson['accountsPlan'][nPos]['stamp'              ] := (cTmpTbl)->CT1_STAMP

    (cTmpTbl)->(DbSkip())
enddo

self:oJObjTSI := oJson
FWFreeObj(oJson)

return 

/*-------------------------------------------------------
{Protheus.doc} GetJsn
(Método responsável retornar a propriedade self:oJObjTSI
@author Carlos Eduardo
@since 22/06/2020
@return Nil, nulo, não tem retorno.
--------------------------------------------------------*/
Method GetJsn() Class TSICONTAC
Return self:oJObjTSI


/*/-------------------------------------------------------------------------------------------
{Protheus.doc}TreeCta
(Monta a arvore da conta contabil buscando as contas superiores e atribui a tabela temporaria)
@author Carlos Eduardo
@since 17/06/2020
@param param_name, param_type, param_descr 
--------------------------------------------------------------------------------------------*/
Static Function TreeCta(cConta,cTmpTbl,nNivel,oStGrv,oStRet)
Local lRet := .t.

CT1->(DbSetOrder(1))
if CT1->(DbSeek(xFilial('CT1')+cConta))    
    while CT1->(!Eof()) .And. CT1->CT1_FILIAL == xFilial('CT1') .And. !Empty(CT1->CT1_CTASUP)
        if CT1->(DbSeek(xFilial('CT1')+CT1->CT1_CTASUP))
            nNivel--
            if !(cTmpTbl)->(DbSeek( CT1->CT1_CONTA ))
                (cTmpTbl)->(RecLock((cTmpTbl), .t. ))
                (cTmpTbl)->CT1_STAMP  := GrvStamp(CT1->CT1_FILIAL,CT1->CT1_CONTA,oStGrv,oStRet)
                (cTmpTbl)->C1O_STAMP  := (cTmpTbl)->CT1_STAMP
                (cTmpTbl)->CT1_DTEXIS := CT1->CT1_DTEXIS
                (cTmpTbl)->CT1_NTSPED := CT1->CT1_NTSPED                
                (cTmpTbl)->CT1_CONTA  := CT1->CT1_CONTA
                (cTmpTbl)->CT1_DESC01 := CT1->CT1_DESC01
                (cTmpTbl)->CT1_CTASUP := CT1->CT1_CTASUP
                (cTmpTbl)->C1O_NIVEL  := alltrim(str(nNivel)) 
                (cTmpTbl)->CT1_CLASSE := CT1->CT1_CLASSE
                (cTmpTbl)->(DbUnLock())
            endif    
        else
            CT1->(DbSkip())
        endIf    
    Enddo
endIf

Return lRet

/*/----------------------------------------------------------------------------------------
{Protheus.doc}GrvStamp(cFilCT1,cConta,oStGrv,oStRet)
(Força a gracação no campo STAMP do ERP e recupera esse valor para que seja gravado no TAF)
@author Carlos Eduardo
@since 17/06/2020
@param param_name, param_type, param_descr 
-----------------------------------------------------------------------------------------*/
Static Function GrvStamp(cFilCT1,cConta,oStGrv,oStRet)
Local cRet := ''
Local cAlias := GetNextAlias()

//Passo os parametros para execução do update(Grava o Stamp)
oStGrv:SetString(1,cFilCT1)
oStGrv:SetString(2,cConta)
TcSqlExec(oStGrv:GetFixQuery())

//Passo os parametros para execução da query(retorna o Stamp)
oStRet:SetString(1,cFilCT1)
oStRet:SetString(2,cConta)
DBUseArea( .t.,'topconn', TCGenQry(, , oStRet:GetFixQuery()) , cAlias , .f., .t. )
cRet := (cAlias)->STAMP
(cAlias)->(DbCloseArea())

return cRet
