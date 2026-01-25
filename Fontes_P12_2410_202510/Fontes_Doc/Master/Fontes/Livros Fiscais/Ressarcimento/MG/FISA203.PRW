#Include "FISA203.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA203
  
Rotina de Apuração do Ressarcimento ou Complemento do ICMS Retido por Substituição Tributária.
Para o Estado de Minas Gerais, o método de apuração é determinado pelo decreto 47.547/2018.

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA203()
Local aArea     := GetArea()
Local cIdApur   := ''
Local cPerApur  := ''
Local lProcess  := .T.

If Pergunte("FISA202",.T.)
    cPerApur := MV_PAR01

    //---Verifica a existência de apuração no período selecionado---//
    If CheckApur(cPerApur)
        If (ApMsgNoYes(STR0001 + CHR(10) + CHR(13) + STR0002 ) ) //STR0001 STR0002 //"Apuração já realizada no período selecionado." //"Deseja fazer o reprocessamento?"
            DeletApur(cPerApur)
        Else
            lProcess := .F.
        EndIf
    EndIf

    If lProcess
        FwMsgRun(,{|oSay| F203Apur(oSay,cPerApur)},STR0003,"") //STR0003 //"Apuração do Ressarcimento do ICMS Retido por ST"
    EndIf

EndIf

RestArea(aArea)
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
  
Rotina de Processamento da Apuração.

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function F203Apur(oSay,cPerApur)
Local cAlias      := GetNextAlias()
Local dDataDe     := CtoD('  /  /    ')
Local dDataAte    := CtoD('  /  /    ')
Local cProduto    := ''
Local nMVICMPAD   := SuperGetMV('MV_ICMPAD')
Local nAliqInt    := 0
Local oApuracao   := Nil
Local cSGBD       := TCGetDB()
Local cSubStrBD   := ''
Local cSelect     := ''
Local lCposTag    := SFT->(FieldPos("FT_BSTANT")) > 0 .And. SFT->(FieldPos("FT_BICEFET")) > 0
Local nVstAnt     := 0
Local nVicEfet    := 0
Local aDocOriApu  := {}

Private lAutomato := Iif(IsBlind(),.T.,.F.)

AtualizaMsg(oSay,STR0004) //STR0004 //"Iniciando processamento..."

dDataDe   := StoD(SubStr(cPerApur,3,4)+SubStr(cPerApur,1,2)+'01')
dDataAte  := LastDay(dDataDe)

//---Classe responsável pela apuração do movimento---//
oApuracao := FISA203APURACAO():New(cPerApur)

AtualizaMsg(oSay,STR0005) //STR0005 //"Verificando movimento no período..."

//---Query Principal---//
If cSGBD = 'ORACLE'
    cSubStrBD := "SUBSTR(SFT.FT_CLASFIS,2,2) = '60' AND SUBSTR(SFT.FT_CFOP,1,1) = '5'"
Else
    cSubStrBD := "RIGHT(SFT.FT_CLASFIS,2) = '60' AND LEFT(SFT.FT_CFOP,1) = '5'"
EndIf
cSubStrBD := "%" + cSubStrBD + "%"

cSelect :=  "SFT.FT_PRODUTO             FT_PRODUTO,"
cSelect +=  "SB1.B1_CRICMS              B1_CRICMS,"
cSelect +=  "SB1.B1_PICM                B1_PICM,"
cSelect +=  "SFT.FT_ENTRADA             FT_DATAMOV,"
cSelect +=  "SFT.FT_TIPOMOV             FT_TIPOMOV,"
cSelect +=  "SFT.FT_TIPO                FT_TIPO,"
cSelect +=  "SFT.FT_NFISCAL             FT_NFISCAL,"
cSelect +=  "SFT.FT_SERIE               FT_SERIE,"
cSelect +=  "SFT.FT_ITEM                FT_ITEM,"
cSelect +=  "SFT.FT_CLIEFOR             FT_CLIEFOR,"
cSelect +=  "SFT.FT_LOJA                FT_LOJA,"
cSelect +=  "SFT.FT_QUANT               FT_QUANT,"
cSelect +=  "SFT.FT_TOTAL               FT_TOTAL,"
cSelect +=  "SFT.FT_FRETE               FT_FRETE,"
cSelect +=  "SFT.FT_SEGURO              FT_SEGURO,"
cSelect +=  "SFT.FT_DESPESA             FT_DESPESA,"
cSelect +=  "SFT.FT_DESCONT             FT_DESCONT,"
cSelect +=  "SFT.FT_PAUTST              FT_PAUTST,"
cSelect +=  "SFT.FT_NFORI               FT_NFORI," 
cSelect +=  "SFT.FT_SERORI              FT_SERORI," 
cSelect +=  "SFT.FT_ITEMORI             FT_ITEMORI,"
cSelect +=  "SD2.D2_NUMLOTE             D2_NUMLOTE,"
cSelect +=  "SD2.D2_LOTECTL             D2_LOTECTL"

If lCposTag
    cSelect += ",SFT.FT_VSTANT FT_VSTANT, SFT.FT_VICEFET FT_VICEFET, SFT.FT_VICPRST FT_VICPRST"
EndIf

cSelect := "%" + cSelect + "%"

BeginSql Alias cAlias
    COLUMN FT_EMISSAO AS DATE
    COLUMN FT_ENTRADA AS DATE
    COLUMN FT_DATAMOV AS DATE

    SELECT  %Exp:cSelect%
             
    FROM       %table:SFT% SFT 
    INNER JOIN %table:SB1% SB1 ON(SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.%NotDel%)
    INNER JOIN %table:SA1% SA1 ON(SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SA1.%NotDel%)
    LEFT JOIN  %table:SD2% SD2 ON(SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.%NotDel%)
    WHERE SFT.FT_FILIAL    = %xFilial:SFT%  
    AND   SFT.FT_ENTRADA   >= %Exp:dDataDe%  
    AND   SFT.FT_ENTRADA   <= %Exp:dDataAte% 
    AND   ((SFT.FT_TIPOMOV = 'S' AND   %Exp:cSubStrBD%) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO = 'D'))
    AND   SFT.FT_DTCANC    = ''             
    AND   SFT.%NOTDEL%
    AND   SA1.A1_TIPO      = 'F'
    AND   SB1.B1_CRICMST   = '1'
    ORDER BY SFT.FT_PRODUTO, FT_DATAMOV
EndSql

Begin Transaction

    //---Grava registro cabeçalho da apuração (Tabela F3X)---//        
    GravaF3X(oApuracao,1)

    AtualizaMsg(oSay,STR0006) //STR0006 //"Processando movimento..."

    DbSelectArea(cAlias)
    While !(cAlias)->(Eof())
    
        If cProduto != (cAlias)->FT_PRODUTO
            //---Define a alíquota interna do ICMS para o produto---//
            nAliqInt := Iif((cAlias)->B1_PICM>0, (cAlias)->B1_PICM, nMVICMPAD)
        EndIf

        nVstAnt  := 0
        nVicEfet := 0

        If lCposTag
            nVstAnt  := (cAlias)->FT_VSTANT + (cAlias)->FT_VICPRST
            nVicEfet := (cAlias)->FT_VICEFET
        EndIf

         //---Valores apurados para o Documento Fiscal Original, em casos de movimentos de devolução---//
        aDocOriApu := aSize(aDocOriApu,0)
        If (cAlias)->FT_TIPOMOV == 'E' .And. (cAlias)->FT_TIPO == 'D'
            aDocOriApu := PesqApur((cAlias)->FT_NFORI, (cAlias)->FT_SERORI, (cAlias)->FT_ITEMORI, (cAlias)->FT_CLIEFOR, (cAlias)->FT_LOJA, (cAlias)->FT_PRODUTO)
        EndIf

        //---Método SetaMovim: Carrega os dados do movimento para que seja feita sua apuração---//
        oApuracao:SetaMovim((cAlias)->FT_DATAMOV,;           //---dDataMov   - Data do Movimento
                            (cAlias)->FT_TIPOMOV,;           //---cTipoMov   - Tipo do Movimento (E-Entrada / S-Saída)
                            (cAlias)->FT_NFISCAL,;           //---cNumDoc    - Número do Documento Fiscal
                            (cAlias)->FT_ITEM,;              //---cItemDoc   - Item do Documento Fiscal
                            (cAlias)->FT_SERIE,;             //---cSerieDoc  - Série do Documento Fiscal
                            (cAlias)->FT_TIPO,;              //---cTipoDoc   - Tipo do Documento (Normal / Devolução / Complemento)
                            (cAlias)->FT_PRODUTO,;           //---cCodProd   - Código do Produto
                            (cAlias)->FT_CLIEFOR,;           //---cCodPart   - Código do Participante
                            (cAlias)->FT_LOJA,;              //---cLojaPart  - Loja do Participante
                            nAliqInt,;                       //---nAliqInt   - Alíquota Interna do Produto
                            (cAlias)->FT_QUANT,;             //---nQtdade    - Quantidade
                            (cAlias)->FT_TOTAL,;             //---nVlrTotPrd - Valor Total do Produto
                            (cAlias)->FT_FRETE,;             //---nVlrFrete  - Valor do Frete
                            (cAlias)->FT_SEGURO,;            //---nVlrSeguro - Valor do Seguro
                            (cAlias)->FT_DESPESA,;           //---nVlrDesp   - Valor das Despesas
                            (cAlias)->FT_DESCONT,;           //---nVlrDesc   - Valor do Desconto
                            (cAlias)->FT_PAUTST,;            //---nVlrPauta  - Valor da pauta informado no cadastro do produto no campo B1_VLR_ICM
                            nVstAnt,;                        //---nVstAnt    - Valor do ICMS ST referente a entrada
                            nVicEfet,;                       //---nVicEfet   - Valor do ICMS Próprio da nota fiscal de saída
                            D2_NUMLOTE,;                     //---cNumLote   - Número do sublote
                            D2_LOTECTL,;                     //---cLoteCtl   - Número do lote
                            aDocOriApu)                      //---aDocOriApu - Array com as informarções do documento original
            //Apuração do movimento
            oApuracao:ApuraMovim()

            //Grava a tabela de Itens - F3Y
            GravaF3Y(oApuracao)

            cProduto := (cAlias)->FT_PRODUTO

            (cAlias)->(DbSkip())

    EndDo
    (cAlias)->(DbCloseArea())

    AtualizaMsg(oSay,STR0007) //STR0007 //"Gravando apuração..."

    //---Grava totalizadores da apuração Tabela F3X---//        
    GravaF3X(oApuracao,2)

    End Transaction
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckApur
  
Função que verifica a existência de apuração no período selecionado.

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function CheckApur(cPerApur)
Local lRet := .F.

F3X->(DbSetOrder(1))
If F3X->(DbSeek(xFilial("F3X")+cPerApur))
    lRet := .T.
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletApur
  
Função de exclusão da apuração.

@author Ulisses P. Oliveira
@since 21/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function DeletApur(cPerApur)
Local cQuery     := ''

//---Tabela F3X [Apuração]---//
F3X->(DbSetOrder(1))
If F3X->(DbSeek(xFilial("F3X")+cPerApur))
    RecLock('F3X',.F.)
    F3X->(DbDelete())
    MsUnLock()
EndIf

//---Tabela F2U [Apuração Detalhada por Movimento]---//
cQuery := "DELETE FROM " +  RetSqlName('F3Y')  + " WHERE F3Y_FILIAL = " + ValToSql(xFilial('F3Y')) + " AND F3Y_PERIOD = " + ValToSql(cPerApur)
If !Empty(AllTrim(cQuery))
    TcSqlExec(cQuery)
EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF3X
  
Função que grava, na tabela F3X totalizadores da apuração.

@author Eduardo Vicente da Silva
@since 25/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF3X(oApuracao,cTipoGrv)

If cTipoGrv = 1     //--- Parâmetro cTipoGrv = 1 -> Chamada no início do processamento. Insere registro na tabala F3X ---//
    RecLock('F3X',.T.)
    F3X->F3X_FILIAL := xFilial("F3X")      
    F3X->F3X_PERIOD := oApuracao:GetPerApur()
    F3X->(MsUnlock())
ElseIf cTipoGrv = 2 //--- Parâmetro cTipoGrv = 2 -> Chamada ao fim do processamento. Insere registros na tabala F3X ---//
    
    F3X->(DbSetOrder(1))
    If F3X->(DbSeek(xFilial("F3X")+oApuracao:GetPerApur()))
        RecLock('F3X',.F.)
        F3X->F3X_VLRCOM := oApuracao:nTotCom
        F3X->F3X_VLRRES := oApuracao:nTotRes
        MsUnLock()
    EndIf
EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GravaF3Y
  
Função que insere, na tabela F3Y, os dados do movimento apurado.

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaF3Y(oApuracao)

RecLock('F3Y',.T.)
F3Y->F3Y_FILIAL := xFilial("F3Y")
F3Y->F3Y_PERIOD := oApuracao:GetPerApur()
F3Y->F3Y_PRODUT := oApuracao:oMovimento:GetCodProd()
F3Y->F3Y_DTMOVT := oApuracao:oMovimento:GetDataMov()
F3Y->F3Y_TIPOMO := oApuracao:oMovimento:GetTipoMov()
F3Y->F3Y_SERIE  := oApuracao:oMovimento:GetSerDoc()
F3Y->F3Y_NFISCA := oApuracao:oMovimento:GetNumDoc()
F3Y->F3Y_CODPAR := oApuracao:oMovimento:GetCodPart()
F3Y->F3Y_LOJPAR := oApuracao:oMovimento:GetLojaPart()
F3Y->F3Y_ITEM   := oApuracao:oMovimento:GetItemDoc()
F3Y->F3Y_QUANT  := oApuracao:oMovimento:GetQuant()
F3Y->F3Y_VLRUNI := oApuracao:oMovimento:GetVlrUni()
F3Y->F3Y_VLRTOT := oApuracao:oMovimento:GetVlrTot()
F3Y->F3Y_ALIQIC := oApuracao:oMovimento:GetAliqInt()

F3Y->F3Y_VLRCOM := oApuracao:oMovimApur:GetVlrCompl()
F3Y->F3Y_VLRRES := oApuracao:oMovimApur:GetVlrRest()
F3Y->F3Y_VLRPRE := oApuracao:oMovimApur:GetVlrPre()

F3Y->(MsUnlock())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqApur
  
Função que pesquisa, no movimento já apurado (tabela F3Y), o movimento de saída original, em casos de devoluções de saídas.
Retorna um vetor contendo os seguintes valores:

[1]-Quantidade do movimento original
[2]-Valor do Ressarcimento do movimento original
[3]-Valor do Complemento do movimento original

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function PesqApur(cDocOri, cSerOri, cItemOri, cCliOri, cLojaOri, cProdOri)
Local aArea    := GetArea()
Local cAlias   := GetNextAlias()
Local aRetorno := {0,0,0}

//--Localiza saída original apurada na tabela F2U, para utilizar os valores informados anteriormente---//
BeginSql Alias cAlias
    SELECT F3Y_QUANT, F3Y_VLRCOM, F3Y_VLRRES
    FROM  %TABLE:F3Y% F3Y
    WHERE F3Y.F3Y_FILIAL = %XFILIAL:F3Y%  
    AND   F3Y.F3Y_TIPOMO = 'S'            
    AND   F3Y.F3Y_SERIE  = %EXP:cSerOri%  
    AND   F3Y.F3Y_NFISCA = %EXP:cDocOri%  
    AND   F3Y.F3Y_CODPAR = %EXP:cCliOri%  
    AND   F3Y.F3Y_LOJPAR = %EXP:cLojaOri% 
    AND   F3Y.F3Y_ITEM   = %EXP:cItemOri% 
    AND   F3Y.F3Y_PRODUT = %EXP:cProdOri% 
    AND   F3Y.%NOTDEL%	
EndSql

DbSelectArea(cAlias)
If !(cAlias)->(Eof())
    aRetorno := {(cAlias)->F3Y_QUANT, (cAlias)->F3Y_VLRCOM, (cAlias)->F3Y_VLRRES}
EndIf
(cAlias)->(DbCloseArea())

RestArea(aArea)
Return aRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA203EXC
Função de exclusão da apuração selecionada, a partir da rotina FISA204.

@author Eduardo Vicente da Silva
@since 07/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA203EXC()
    FWExecView(STR0008,"FISA204",MODEL_OPERATION_DELETE,,{|| DeletApur(F3X->F3X_PERIOD) },,,) //STR0008 //"Exclusão"
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
    If !lAutomato
        oSay:cCaption := (cMsg)
        ProcessMessages()
    EndIf
Return
