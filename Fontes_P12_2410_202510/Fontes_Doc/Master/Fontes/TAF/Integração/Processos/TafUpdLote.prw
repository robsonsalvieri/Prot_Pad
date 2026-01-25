#include 'protheus.ch'

//-------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafUpdLote
Realiza update em lote (from\join ou subquery), para reduzir gargalo no processamento do TAF em MultThread.

Dessa forma sempre apagara os filhos antes do processammento, nao sera mais necessario realizar update a cada registro processado.

Apos a execucao do TafUpdLote sera realizado a chamada do processo de inclusao. A principio vem para resolver o gargalo das 
movimentacoes nas notas fiscais e nao onerar o processamento com a funcao tafdelchild.

//#todo verificar questao de gerar gia com mais de 1 filial ( aglutinacao )

Importante:
https://tdn.totvs.com/display/framework/FWTemporaryTable
1) Devido as características do TempDB, uma tabela temporária só é visível para a thread que realizou a sua criação, 
não sendo possível compartilhar a mesma tabela entre vários processos.

https://devforum.totvs.com.br/651-fwtemporarytable-inclusao-de-dados
2) A tabela temporária funciona como uma workarea padrão do sistema, a tabela temporária é vinculada a thread, 
somente a thread que criou a tabela consegue ver a mesma, se você criar a tabela na thread XXXXX,
a thread YYYYY não vai conseguir ver (nem mesmo em programas específicos para visualização do banco de dados).
Obs.: Existe uma exceção no Oracle, que você consegue ver a tabela, mas não seu conteúdo.

@author  Denis Naves / Carlos Boy
@since   01/07/2021
@version 1
/*/
//-------------------------------------------------------------------------------------------------------------------------------
Function TafUpdLote( cTbMov , aChild, cNmTmp )

local lOK     := .F.
local nlA     := 0
local cTbAtu  := ""
local cTbDel  := "TMPDEL"
local cScript := ""
local cBd     := Upper(Alltrim(TcGetDb()))
local lSql    := if("MSSQL" $ cBd, .T., .F.)

//Tabelas filhas da C20 que possuem filial + chvnf em seus indices
local cC20Child  := 'C21|C22|C23|C24|C25|C26|C27|C28|C29|C2A|C2B|C2C|C2D|C2E|C2F|C2G|C2H|C2I|C30|C31|C32|C33|C34|C35|C36|C37|C38|C39|C3A|C3F|C3G|C3H|C3I|C6W|C9H|CW7|T9L|T9M|T9Q'

Default cTbMov := "C20"
Default aChild := strtokarr(cC20Child,'|')    //{"C30","C35","C39","C2F",'C25'} 
Default cNmTmp := ""

/*------------------------------------------------------------------------------------------
|Atualiza a tabela temporaria com os campos de ID do TAF, pois no momento de preenchimento |
|da tabela temporaria no extrator fiscal, ainda nao possuimos os ids das tabelas de legado |
|ou auto contidas do TAF, apenas os códigos do lado do módulo fiscal.                      |
------------------------------------------------------------------------------------------*/
if lSql
    cScript := "UPDATE " + cNmTmp + " SET "
    cScript += " CODMOD = C01.C01_ID,"
    cScript += " TPDOC  = C0U.C0U_ID,"
    cScript += " CODPAR = C1H.C1H_ID,"
    cScript += " CODSIT = C02.C02_ID"
    cScript += " FROM " + cNmTmp + " TMPDEL"
    //Modelos dos Documentos Fiscais 
    cScript += " INNER JOIN " + RetSqlName('C01') +" C01 ON C01.C01_FILIAL = '" + xFilial('C01') + "' AND C01.C01_CODIGO = TMPDEL.CODMOD AND C01.D_E_L_E_T_ = ' '"
    //Situação Documentos Fiscais
    cScript += " INNER JOIN " + RetSqlName('C02') +" C02 ON C02.C02_FILIAL = '" + xFilial('C02') + "' AND C02.C02_CODIGO = TMPDEL.CODSIT AND C02.D_E_L_E_T_ = ' '"
    //Finalidades Documento Fiscal
    cScript += " INNER JOIN " + RetSqlName('C0U') +" C0U ON C0U.C0U_FILIAL = '" + xFilial('C0U') + "' AND C0U.C0U_CODIGO = TMPDEL.TPDOC  AND C0U.D_E_L_E_T_ = ' '"
    //Cadastro de Participantes
    cScript += " INNER JOIN " + RetSqlName('C1H') +" C1H ON C1H.C1H_FILIAL = '" + xFilial('C1H') + "' AND C1H.C1H_CODPAR = TMPDEL.CODPAR AND C1H.D_E_L_E_T_ = ' '"
/*
else
    cScript := "UPDATE " + cNmTmp + " TMPDEL SET "
    cScript += " CODMOD = ( SELECT C01.C01_ID FROM " + RetSqlName('C01') + " C01" //Modelos dos Documentos Fiscais
    cScript += " WHERE C01.C01_FILIAL = '" + xFilial('C01') + "' AND C01.C01_CODIGO = TMPDEL.CODMOD AND C01.D_E_L_E_T_ = ' ' ) "
    
    cScript += " ,TPDOC = ( SELECT C0U.C0U_ID FROM " + RetSqlName('C0U') + " C0U" //Situação Documentos Fiscais
    cScript += " WHERE C0U.C0U_FILIAL = '" + xFilial('C0U') + "' AND C0U.C0U_CODIGO = TMPDEL.TPDOC  AND C0U.D_E_L_E_T_ = ' ' ) "

    cScript += " ,CODPAR = ( SELECT C1H.C1H_ID FROM " + RetSqlName('C1H') + " C1H" //Finalidades Documento Fiscal
    cScript += " WHERE C1H.C1H_FILIAL = '" + xFilial('C1H') + "' AND C1H.C1H_CODPAR = TMPDEL.CODPAR AND C1H.D_E_L_E_T_ = ' ' ) "

    cScript += " ,CODSIT = ( SELECT C02.C02_ID FROM " + RetSqlName('C02') + " C02" //Cadastro de Participantes
    cScript += " WHERE C02.C02_FILIAL = '" + xFilial('C02') + "' AND C02.C02_CODIGO = TMPDEL.CODSIT AND C02.D_E_L_E_T_ = ' ' ) "
*/
endif

lOk := TcSQLExec( cScript ) >= 0
If !lOk 
    TAFConout("Script executado: " + cScript ,3,.T.,"GIA") 
    TAFConout( "Erro...:" + AllTrim(TCSQLError()) ,3,.T.,"GIA") 
    TAFConout("Separador--------------------------------------------------------------------------",3,.T.,"GIA") 
endif


/*---------------------------------------------------------------
|Atualiza os registros vindos do extrator no TAF como apagados, |
|dessa forma o processamento no TafInteg será apenas de INSERT. |
---------------------------------------------------------------*/
for nlA := 1 to len( aChild )
    
    cTbAtu := aChild[nlA]

    //VerResult(cTbAtu)

    if lSql
        cScript := "UPDATE " + cTbAtu //C30
        cScript += " SET " + cTbAtu + ".D_E_L_E_T_ = '*', " + cTbAtu + ".R_E_C_D_E_L_ = " + cTbAtu + ".R_E_C_N_O_" //C30
        cScript += " FROM " + RetSqlName( cTbAtu ) + " " + cTbAtu //C30
        
        cScript += " INNER JOIN " + RetSqlName( cTbMov ) + " " + cTbMov //C20

        cScript += " ON " + cTbMov + "." + cTbMov + "_FILIAL = " + cTbAtu + "." + cTbAtu + "_FILIAL" //C20 x C30
        cScript += " AND " + cTbMov + "." + cTbMov + "_CHVNF = " + cTbAtu + "." + cTbAtu + "_CHVNF"
        cScript += " AND " + cTbMov + ".D_E_L_E_T_ = ' '" //C20

        if !Empty( cNmTmp )
            cScript += " INNER JOIN " + cNmTmp + " " + cTbDel //TMPDEL
            cScript += " ON " + cTbDel + ".FILIAL = " + cTbMov + "." + cTbMov + "_FILIAL" //TMPDEL  X C20
            cScript += " AND " + cTbDel + ".CODMOD = " + cTbMov + "." + cTbMov + "_CODMOD"
            cScript += " AND " + cTbDel + ".INDOPE = " + cTbMov + "." + cTbMov + "_INDOPE"
            cScript += " AND " + cTbDel + ".TPDOC = " + cTbMov + "." + cTbMov + "_TPDOC"
            cScript += " AND " + cTbDel + ".INDEMI = " + cTbMov + "." + cTbMov + "_INDEMI"
            cScript += " AND " + cTbDel + ".CODPAR = " + cTbMov + "." + cTbMov + "_CODPAR"
            cScript += " AND " + cTbDel + ".CODSIT = " + cTbMov + "." + cTbMov + "_CODSIT"
            cScript += " AND " + cTbDel + ".SERIE = " + cTbMov + "." + cTbMov + "_SERIE"
            cScript += " AND " + cTbDel + ".SUBSER = " + cTbMov + "." + cTbMov + "_SUBSER"
            cScript += " AND " + cTbDel + ".NUMDOC = " + cTbMov + "." + cTbMov + "_NUMDOC"
            cScript += " AND " + cTbDel + ".DTDOC = " + cTbMov + "." + cTbMov + "_DTDOC"
            cScript += " AND " + cTbDel + ".DTES = " + cTbMov + "." + cTbMov + "_DTES"
        endif

        cScript += " WHERE " + cTbAtu + ".D_E_L_E_T_ = ' '" //C30
    /*
    else
        cScript := "UPDATE " + RetSqlName( cTbAtu ) //C30
        cScript += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = " + cTbAtu + ".R_E_C_N_O_" //C30
        cScript += " FROM " + RetSqlName( cTbAtu ) + " " + cTbAtu //C30

        cScript += "WHERE " + cTbAtu + ".D_E_L_E_T_ = ' ' AND " + cTbAtu + "." + cTbAtu + "_FILIAL || " + cTbAtu + "." + cTbAtu + "_CHVNF = " //C30

        cScript += " ( "
        cScript += " SELECT " + cTbMov + "." + cTbMov + "_FILIAL || " + cTbMov + "." + cTbMov + "_CHVNF "
        cScript += " FROM " + RetSqlName( cTbMov ) + " " + cTbMov //C20

        if !Empty( cNmTmp )
            cScript += " INNER JOIN " + cNmTmp + " " + cTbDel //TMPDEL
            cScript += " ON " + cTbDel + ".FILIAL = " + cTbMov + "." + cTbMov + "_FILIAL" //TMPDEL  X C20
            cScript += " AND " + cTbDel + ".CODMOD = " + cTbMov + "." + cTbMov + "_CODMOD"
            cScript += " AND " + cTbDel + ".INDOPE = " + cTbMov + "." + cTbMov + "_INDOPE"
            cScript += " AND " + cTbDel + ".TPDOC = " + cTbMov + "." + cTbMov + "_TPDOC"
            cScript += " AND " + cTbDel + ".INDEMI = " + cTbMov + "." + cTbMov + "_INDEMI"
            cScript += " AND " + cTbDel + ".CODPAR = " + cTbMov + "." + cTbMov + "_CODPAR"
            cScript += " AND " + cTbDel + ".CODSIT = " + cTbMov + "." + cTbMov + "_CODSIT"
            cScript += " AND " + cTbDel + ".SERIE = " + cTbMov + "." + cTbMov + "_SERIE"
            cScript += " AND " + cTbDel + ".SUBSER = " + cTbMov + "." + cTbMov + "_SUBSER"
            cScript += " AND " + cTbDel + ".NUMDOC = " + cTbMov + "." + cTbMov + "_NUMDOC"
            cScript += " AND " + cTbDel + ".DTDOC = " + cTbMov + "." + cTbMov + "_DTDOC"
            cScript += " AND " + cTbDel + ".DTES = " + cTbMov + "." + cTbMov + "_DTES"
        endif
        cScript += " ) "
    */
    endif

    lOk := TcSQLExec( cScript ) >= 0
    if !lOk
        TAFConout("Script executado: " + cScript ,3,.T.,"GIA") 
        TAFConout( "Erro...:" + AllTrim(TCSQLError()) ,3,.T.,"GIA") 
        TAFConout("Separador--------------------------------------------------------------------------",3,.T.,"GIA") 
    endif

    //Foto com cenario antes do processamento.
    //VerResult(cTbAtu) //#todo subir comentado.

next nlA

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} VerResult
Foto das tabelas a cada update em lote.
//#todo subir comentado.
@author  Denis Naves
@since   01/07/2021
@version 1
/*/
//-------------------------------------------------------------------------------
Static Function VerResult(cAlias)

Local cQry    := GetNextAlias()
Local cQtdDel := 0

cSelect := "COUNT(*) QTDDEL FROM " + RetSqlName(cAlias) + " WHERE D_E_L_E_T_ = '*'"
cSelect := "%" + cSelect + "%"

BeginSql Alias cQry
    SELECT
    %Exp:cSelect%
EndSql

If !(cQry)->(Eof())
    cQtdDel := (cQry)->QTDDEL
EndIf

(cQry)->(dbCloseArea())

TafConout("--> VerResult.............. " +  RetSqlName(cAlias) + " Qtd Registros apagados: " + cvaltochar( cQtdDel ) )

TafConout("Separador--------------------------------------------------------------------------")

Return Nil
