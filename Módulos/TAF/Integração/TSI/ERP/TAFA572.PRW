#include 'totvs.ch'
#include 'topconn.ch'
#include 'restful.ch'
#include 'fwmvcdef.ch'

Static lNewCtrl := Nil
Static cUltStmp := Nil

/*/-------------------------------------------------------------
{Protheus.doc}TSIPROREF
(Classe principal para integração de processos referenciados)
@author Carlos Eduardo
@since 17/08/2020
@param param_name, param_type, param_descr 
-------------------------------------------------------------/*/
Class TSIPROREF

Data oJObjTSI    as Object

Method New() Constructor
Method LoadQuery()
Method JSon()
Method GetJsn()

EndClass

/*---------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} New
(Método contrutor da classe TSIPROREF )
Fluxo New:
1º Monta-se a query com LoadQuery()
2º Instanciar o preparedStatement com PrepQuery() e alimenta a propriedade cFinalQuery com a query final já com os parâmetros
@author Carlos Eduardo
@since 17/08/2020
@return Nil, nulo, não tem retorno.
----------------------------------------------------------------------------------------------------------------------------*/
Method New(cSourceBr) Class TSIPROREF

If !FwIsInCallStack('RESTGETLISTSERVICE')

    lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
    cUltStmp := iif(lNewCtrl, TsiUltStamp("C1G"),' ')

    Self:LoadQuery(cSourceBr)

Endif

Return Nil

 /*-----------------------------------------------------------------------------------
{Protheus.doc} LoadQuery
(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
nos parâmetros variáveis, e atribui valores a tabela temporaria.
@author Carlos Eduardo
@since 17/08/2020
@return Nil, nulo, não tem retorno.
-------------------------------------------------------------------------------------*/

Method LoadQuery(cSourceBr) Class TSIPROREF

Local cDbType  := Upper(Alltrim(TCGetDB()))
Local cConcat  := " "
Local lRet     := .t.
Local cQuery   := ''
Local aFilTaf  := TafTSIFil(cSourceBr,'C1G')
Local cFilTaf  := ''
Local nLenFil  := len(aFilTaf)
Local cAlias   := GetNextAlias()
Local nI       := 0
Local cConvCpo := ''

//Monta a string com as filiais para somar á query
for nI := 1 to nLenFil
    cFilTaf += "'" + aFilTaf[nI] + "'"
    if nI < nLenFil; cFilTaf += ','; endif
next
if empty( cFilTaf )
    cFilTaf := "'" + xfilial("C1G") + "'"
endif

//Converte o conteúdo do campo conforme o banco de dados usado.
If cDbType $ 'MSSQL/MSSQL7'
    cConvCpo := " convert(varchar(23), CCF.S_T_A_M_P_, 21) "
    cConcat := "+"
Elseif cDbType $ 'ORACLE'
    cConvCpo := " cast(to_char(CCF.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) "
    cConcat := "||"
Elseif cDbType $ 'POSTGRES'
    cConvCpo := " cast(to_char(CCF.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
    cConcat := "||"
Endif

//Sempre que um item for modificado, ira montar o json com todas as suspensoes novamente.
//O motor ira apagar todos os filhos e refazer por completo, devera manter o mesmo ID na
//C1G pois pode ter sido utilizado em outros lancamentos como FK.
cQuery := " SELECT "
cQuery += " CCF.CCF_FILIAL, " 
cQuery += " C1G.C1G_FILIAL, " 
cQuery += " CCF.CCF_NUMERO, " // NUM_PROC
cQuery += " CCF.CCF_TIPO, "   // IND_PROC
cQuery += " CCF.CCF_IDVARA, " // ID_VARA
cQuery += " CCF.CCF_TPCOMP, " // TP_PROC
cQuery += " CCF.CCF_UF, "     // UFVARA
cQuery += " CCF.CCF_CODMUN, " // CODMUNIC
cQuery += " CCF.CCF_DTINI, "  // INIVALID
cQuery += " CCF.CCF_DTFIN, "  // FINVALID
cQuery += " CCF.CCF_INDSUS, " // COD_SUSP
cQuery += " CCF.CCF_SUSEXI, " // IND_SUSP
cQuery += " CASE WHEN CCF.CCF_DTADM = ' ' THEN CCF.CCF_DTADM ELSE CCF.CCF_DTSENT END DTDECISAO, " // DT_DECISAO
cQuery += " CCF.CCF_MONINT DEPOSITO, " // IND_DEPOSITO

/*Contador dos registros ativos na CCF, controle para saber se irá apagar o cabecalho da C1G apos exclusao */
cQuery += " ( SELECT COUNT(CCF_NUMERO) FROM " + RetSqlName("CCF") + " TB1 WHERE TB1.CCF_FILIAL = CCF.CCF_FILIAL "
cQuery += " AND TB1.CCF_NUMERO = CCF.CCF_NUMERO AND TB1.CCF_TIPO = CCF.CCF_TIPO AND TB1.D_E_L_E_T_ = ' ' ) QTDCCF, "

cQuery += " CCF.D_E_L_E_T_ CCFCANCEL, " // CANCEL
cQuery += " C1G.C1G_ID C1GID, "         // C1GID
cQuery += " C1G.C1G_VERSAO C1GVERSAO "  // C1GVERSAO

cQuery += " FROM " + RetSqlName("CCF")  + " CCF "

cQuery += " LEFT JOIN " + RetSqlName('C1G') + " C1G ON C1G.C1G_FILIAL IN (" + cFilTaf + ") "
cQuery += " AND C1G.C1G_NUMPRO = CCF.CCF_NUMERO AND C1G.C1G_INDPRO = CCF.CCF_TIPO AND C1G.D_E_L_E_T_ = ' ' "

If !lNewCtrl .OR. Empty(cUltStmp)
    //Sem RTRIM( C1H.V5R_REGKEY ), no Oracle a query nao entende que os conteudos sao iguais por causa dos espacos do campo V5R_REGKEY
    cQuery += " LEFT JOIN " + RetSqlName('V5R') + " V5R ON V5R.V5R_FILIAL = '" + xFilial( "V5R" ) + "' AND V5R.V5R_CODFIL = '" + cFilAnt + "' AND V5R.V5R_ALIAS = 'C1G' "
    cQuery += " AND RTRIM(V5R.V5R_REGKEY) = RTRIM(CCF.CCF_NUMERO) " + cConcat + " RTRIM(CCF.CCF_TIPO) AND V5R.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " WHERE CCF.CCF_FILIAL = '" + xFilial('CCF') + "' "
//cQuery += " AND CCF.D_E_L_E_T_ = ' ' " //Desabilitado para atualizar o processo no TAF caso o item seja excluido no ERP

If !lNewCtrl .OR. Empty(cUltStmp)
    cQuery += " AND CCF.S_T_A_M_P_ IS NOT NULL "
    if cDbType $ 'ORACLE'
        cQuery += " AND ( "
        cQuery += "         ( V5R.V5R_STAMP IS NOT NULL AND Length(trim(V5R.V5R_STAMP)) > 0 AND (CCF.S_T_A_M_P_ > TO_TIMESTAMP(V5R.V5R_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff'))) "
        cQuery += "     OR "
        cQuery += "     ( 
        cQuery += "         ( C1G.C1G_STAMP IS NULL OR Length(trim(C1G.C1G_STAMP)) = 0 OR Length(trim(C1G.C1G_STAMP)) IS NULL ) OR (Length(trim(C1G.C1G_STAMP)) > 0 AND (CCF.S_T_A_M_P_ > TO_TIMESTAMP(C1G.C1G_STAMP, 'dd.mm.yyyy hh24:mi:ss.ff')))) "
        cQuery += " ) "
    else
        cQuery += " AND ( ( " + cConvCpo + " > C1G.C1G_STAMP ) OR C1G.C1G_STAMP IS NULL ) "
        cQuery += " AND ( ( " + cConvCpo + " > V5R.V5R_STAMP ) OR V5R.V5R_STAMP IS NULL ) "
    endif
Else
    if cDbType $ 'ORACLE'
        cQuery += " AND CCF.S_T_A_M_P_ > to_timestamp('" + cUltStmp + "','dd.mm.yyyy hh24:mi:ss.ff') "
    else
        cQuery += " AND " + cConvCpo + " > '" + Alltrim(cUltStmp) + "' "
    Endif
Endif

//Devera ser ordenado dessa forma para montar o json com as suspensoes corretas no processo (ver método JSon)
cQuery += " ORDER BY CCF.CCF_FILIAL, CCF.CCF_NUMERO, CCF.CCF_TIPO, CCF.CCF_INDSUS "

cQuery := ChangeQuery(cQuery)

DbUseArea(.t., 'topconn', TCGenQry(, , cQuery), cAlias, .f., .t. )

//Crio o JSon
Self:JSon(cAlias)
(cAlias)->(DbCloseArea())

Return lRet

/*/----------------------------------------------------------------------------
{Protheus.doc}JSon
(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI)
@author Carlos Eduardo
@since 17/08/2020
@param cTmpTbl, string, Nome da tabela temporária 
-----------------------------------------------------------------------------/*/
Method JSon(cTmpTbl) Class TSIPROREF
Local nPos      := 0
Local nPos2     := 0
Local cProcesso := ''
Local oJson     := JsonObject():New()
Local cStamp    := ''

Local nTotReg   := 0
Local cOpcCanc  := ""
Local cCancel   := ""
Local cVersaoReg := ""
local cFilC1G    := xFilial("C1G")

oJson['referencedProcesses'] := {}

while (cTmpTbl)->(!eof())
    aAdd( oJson['referencedProcesses'],JsonObject():New())
    nPos := Len(oJson['referencedProcesses'])
    nTotReg := (cTmpTbl)->QTDCCF
    cCancel := "0" //Nao
    cVersaoReg := ""
    //Busca o maior stamp inclusive se tiver sido excluido para atualizar na C1G
    if Empty( cProcesso ) .Or. (cProcesso <> (cTmpTbl)->CCF_FILIAL + (cTmpTbl)->CCF_NUMERO + (cTmpTbl)->CCF_TIPO)
        cProcesso := (cTmpTbl)->CCF_FILIAL + (cTmpTbl)->CCF_NUMERO + (cTmpTbl)->CCF_TIPO
        cStamp := TafStmpCCF( ( cTmpTbl)->CCF_FILIAL, (cTmpTbl)->CCF_NUMERO, (cTmpTbl)->CCF_TIPO )
        if !Empty( (cTmpTbl)->C1GVERSAO )
            cVersaoReg := (cTmpTbl)->C1GVERSAO //se existe mantem a versao da C1G
        endif
    endif

    oJson['referencedProcesses'][nPos]['processNumber'         ] := (cTmpTbl)->CCF_NUMERO
    oJson['referencedProcesses'][nPos]['processOriginIndicator'] := (cTmpTbl)->CCF_TIPO   //'C1G_INDPRO' //0Sefaz 1J.Federal 2J.Est 3Secex 9Outros
    oJson['referencedProcesses'][nPos]['courtIdentification'   ] := (cTmpTbl)->CCF_IDVARA
    oJson['referencedProcesses'][nPos]['processType'           ] := (cTmpTbl)->CCF_TPCOMP //'C1G_TPPROC' //1Jud 2Adm 3DCom,NB 4 FAP
    oJson['referencedProcesses'][nPos]['state'                 ] := (cTmpTbl)->CCF_UF
    oJson['referencedProcesses'][nPos]['cityCode'              ] := (cTmpTbl)->CCF_CODMUN
    oJson['referencedProcesses'][nPos]['proceduralStart'       ] := (substr( (cTmpTbl)->CCF_DTINI , 5 , 2 ) + substr( (cTmpTbl)->CCF_DTINI , 1 , 4 )) //C 6 @R 99/9999
    oJson['referencedProcesses'][nPos]['proceduralEnd'         ] := (substr( (cTmpTbl)->CCF_DTFIN , 5 , 2 ) + substr( (cTmpTbl)->CCF_DTFIN , 1 , 4 )) //C 6 @R 99/9999
    oJson['referencedProcesses'][nPos]['branch'                ] := iif(Empty((cTmpTbl)->C1G_FILIAL), cFilC1G, (cTmpTbl)->C1G_FILIAL)
    oJson['referencedProcesses'][nPos]['id'                    ] := (cTmpTbl)->C1GID //TAG controle extracao, nao necessario na API
    oJson['referencedProcesses'][nPos]['versao'                ] := cVersaoReg //TAG controle extracao, nao necessario na API
    oJson['referencedProcesses'][nPos]['stamp'                 ] := cStamp

    oJson['referencedProcesses'][nPos]['suspension'            ] := {}
    while (cTmpTbl)->(!eof()) .and. cProcesso == ( (cTmpTbl)->CCF_FILIAL + (cTmpTbl)->CCF_NUMERO + (cTmpTbl)->CCF_TIPO )
        cOpcCanc := '0' //Nao
        if (cTmpTbl)->CCFCANCEL == '*'
            cOpcCanc := '5' //exclui item (na suspensao)
        endif
        aadd( oJson['referencedProcesses'][nPos]['suspension'],JsonObject():New() )
        nPos2 := Len(oJson['referencedProcesses'][nPos]['suspension'])
        oJson['referencedProcesses'][nPos]['suspension'][nPos2]['suspensionIndicativeCode'] := (cTmpTbl)->CCF_INDSUS
        oJson['referencedProcesses'][nPos]['suspension'][nPos2]['suspensionIndicativeInfo'] := (cTmpTbl)->CCF_SUSEXI
        oJson['referencedProcesses'][nPos]['suspension'][nPos2]['decisionDate'            ] := STOD( (cTmpTbl)->DTDECISAO ) //D	8
        oJson['referencedProcesses'][nPos]['suspension'][nPos2]['fullAmount'              ] := (cTmpTbl)->DEPOSITO //Pertence(" 12")
        //Tag Generica para saber se atualiza ou deleta a suspensao no TAF
        oJson['referencedProcesses'][nPos]['suspension'][nPos2]['opCancelation'           ] := cOpcCanc //TAG controle extracao, nao necessario na API
        (cTmpTbl)->(DbSkip())
    enddo
    if nTotReg == 0 //Se houver 0 registros ativos, significa que o processo foi excluido por completo
        cCancel := '5' //Sim
    endif
    //Tag Generica para saber se atualiza ou deleta o processo (cabecalho) no TAF
    oJson['referencedProcesses'][nPos]['opCancelation'] := cCancel //TAG controle extracao, nao necessario na API
enddo

self:oJObjTSI := oJson
//Comentado mesmo ao atribuir o oJson no self:oJObjTSI, caso faca um FWFreeObj oJson posteriormente, o array no
//oJObjTSI ficara vazio devido referencia, ou seja nao existira nenhum json para processar com a linha abaixo habilitada.
//FWFreeObj(oJson)

Return Nil

/*-------------------------------------------------------
{Protheus.doc} GetJsn
(Método responsável retornar a propriedade self:oJObjTSI
@author Carlos Eduardo
@since 18/08/2020
@return Nil, nulo, não tem retorno.
--------------------------------------------------------*/
Method GetJsn() Class TSIPROREF
Return self:oJObjTSI

//-------------------------------------------------------------------
/*/{Protheus.doc} TafStmpCCF
Responsavel por retornar maior stamp independente se o registro foi excluido

@param
@author Denis Souza
@since 28/11/2021

/*/
//-------------------------------------------------------------------
Static Function TafStmpCCF(cFil,cNrPro,cTpPro)

Local cStamp    := ''
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local cDbType   := Upper(Alltrim(TCGetDB()))
Local cConvCpo  := ''
Local cSelect   := ''
Local cFrom     := ''
Local cWhere    := ''
Default cFil    := ''
Default cNrPro  := ''
Default cTpPro  := ''

//Converte o conteúdo do campo conforme o banco de dados usado.
If cDbType $ 'MSSQL/MSSQL7'
    cConvCpo := " convert(varchar(23), MAX(CCF.S_T_A_M_P_) , 21) "
Elseif cDbType $ 'ORACLE'
    cConvCpo := " cast(to_char( MAX(CCF.S_T_A_M_P_) ,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) "
Elseif cDbType $ 'POSTGRES'
    cConvCpo := " cast(to_char( MAX(CCF.S_T_A_M_P_) ,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
Endif

cSelect := "% " + cConvCpo + " CCFSTAMP %"
cFrom   := "% " + RetSqlName("CCF") + " CCF %" //Processos refer. no documento

//Importante os itens excluidos tambem deverao ser considerados
cWhere := "% CCF.CCF_FILIAL = '" + cFil + "' AND CCF.CCF_NUMERO = '" + cNrPro + "' AND CCF.CCF_TIPO = '" + cTpPro + "' %"

BeginSql Alias cAliasQry
	SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %Exp:cWhere%
EndSql

if (cAliasQry)->( !Eof() ) ; cStamp := Alltrim( (cAliasQry)->CCFSTAMP ) ; endif

(cAliasQry)->( DbCloseArea() )

RestArea( aArea )

Return cStamp
