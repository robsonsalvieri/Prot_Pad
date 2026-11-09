#INCLUDE "FISA323.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE DTNICIO  1
#DEFINE DTFINAL  2
#DEFINE FIL_CENTRALIZADORA   7

// Proteção pois em binários 32 bits o objeto TSay não possui o método SetTextAlign.

STATIC oSayCheck  := Nil
STATIC lMethAlign := Nil
STATIC oFont18    := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA323()

Função principal para execução da Wizard de parâmetros para apuração do IPM

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISA323()

Local aParams as array

aParams := {}

aParams := x323Wizard()

Return aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} x323Wizard()

Função responsável pela montagem da wizard de parametrização da
apuração.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323Wizard()

Local oPagIni  as object
Local oStepWiz as object
Local oMarkBr  as object
Local aCoords  as array
Local aParams  as array

oPagIni  := NIL
oStepWiz := NIL
oMarkBr  := NIL
aCoords  := FWGetDialogSize()
aParams  := {}

// Tabela temporária para utilizar no MarkBrowse de seleção dos tributos...
oTmpTbl := x323WTRB()

oStepWiz := FWWizardControl():New(, {aCoords[3] * 0.8, aCoords[4] * 0.8})
oStepWiz:ActiveUISteps()

oPagIni := oStepWiz:AddStep(cValToChar(1))
oPagIni:SetStepDescription(STR0001) //"Parâmetros"
oPagIni:SetConstruction({|Panel|x323WParam(Panel, oTmpTbl, @oMarkBr)})
oPagIni:SetNextAction({|| x323WValid(oMarkBr) .and. x323GetPar(@aParams, oMarkBr) })
oPagIni:SetCancelAction({|| .T.})

oStepWiz:Activate()
oStepWiz:Destroy()

oTmpTbl:Delete()

Return aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} x323WParam()

Função responsável por retornar a estrutura dos campos utilizados nas
MGMGET's dos filtros.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323WParam(oPanel, oTmpTbl, oMarkBr)

Local oLayer   as object
Local oPanel0  as object
Local oPanel1  as object
Local oPanel2  as object
Local aFields  as array
Local aEstrut  as array
Local aColumns as array
Local cAlsMark as character

PRIVATE oGetsProd := NIL

Default oPanel  := Nil
Default oTmpTbl := Nil
Default oMarkBr := Nil

oLayer   := NIL
oPanel0  := NIL
oPanel1  := NIL
oPanel2  := NIL
aFields  := {}
aEstrut  := {}
aColumns := {}
cAlsMark := " "

oSayCheck  := TSay():New()
lMethAlign := MethIsMemberOf(oSayCheck, "SetTextAlign")
oFont18    := TFont():New("Arial",,18,,.F.,,,,,.F.,.F.)

oLayer := FWLayer():New()
oLayer:Init(oPanel,.F.)
oLayer:AddLine('LIN0', 10, .F.)
oLayer:AddLine('LIN1', 30, .F.)
oLayer:addCollumn('LIN1_COL1', 100, .F., 'LIN1')
oLayer:AddLine('LIN2', 60, .F.)
oLayer:addCollumn('LIN2_COL1', 100, .F., 'LIN2')
oLayer:AddWindow('LIN2_COL1', 'W1', STR0003, 100, .F., .F.,,'LIN2') //"Tributos"

oPanel0 := oLayer:getLinePanel('LIN0')
oPanel1 := oLayer:getColPanel('LIN1_COL1', 'LIN1')
oPanel2 := oLayer:getWinPanel('LIN2_COL1', 'W1', 'LIN2')

oSayTitulo := TSay():New(5,5,{||STR0002},oPanel0,,oFont18,,,,.T.,,,(oPanel0:nWidth / 2) - 5,(oPanel0:nHeight / 2) - 5) //"Informe os parâmetros para execução da apuração..."                                                                                                                                                                                                                                                                                                                                                                                                                                                                
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

aEstrut := x323WEstru()
aEval(aEstrut, {|x| aAdd(aFields, x[2])})
oGetsProd := MsmGet():New(,,3,,,,aFields,{0,3,((oPanel1:nClientHeight/2)-5),((oPanel1:nClientWidth/2)-5)},,,,,,oPanel1,,,.T.,,,.T.,aEstrut,,,,,.T.)

cAlsMark := oTmpTbl:GetAlias()

aColumns := x323StrCol(oTmpTbl:GetStruct():aFields) 

oMarkBr:= FWMarkBrowse():New()
oMarkBr:SetOwner(oPanel2)
oMarkBr:SetDataTable(.T.)
oMarkBr:SetAlias(cAlsMark)
oMarkBr:SetColumns(aColumns)
oMarkBr:SetFieldMark("TRB_OK")
oMarkBr:SetMark("OK", cAlsMark, "TRB_OK")
oMarkBr:SetMenuDef("")
oMarkBr:SetIgnoreARotina(.T.)
oMarkBr:SetAmbiente(.F.)
oMarkBr:oBrowse:SetDBFFilter(.F.)
oMarkBr:oBrowse:SetUseFilter(.F.)
oMarkBr:SetWalkThru(.F.)
oMarkBr:DisableReport()
oMarkBr:DisableDetails()
oMarkBr:Activate()

oGetsProd:SetFocus()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x323StrCol()

Função responsável por "converter" a estrutura da tabela passada em 
um array de FWBrwColumn que serão utilizadas na montagem do markbrowse
e também do browse de resumo dos perfis.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323StrCol(aCampos)

Local aRet    as array
Local nX      as numeric
Local nPosRet as numeric

Default aCampos := {}

aRet    := {}
nX      := 0
nPosRet := 0

For nX := 1 to Len(aCampos)
     If aCampos[nX][1] <> "TRB_OK"
        AAdd(aRet,FWBrwColumn():New())
        nPosRet := Len(aRet)
        aRet[nPosRet]:SetData( &("{||"+aCampos[nX][1]+"}") )
        aRet[nPosRet]:SetTitle(RetTitle(aCampos[nX][1])) 
        aRet[nPosRet]:SetSize(aCampos[nX][3])
        aRet[nPosRet]:SetDecimal(aCampos[nX][4])
        aRet[nPosRet]:SetPicture("@!")
    EndIf
Next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x323WEstru()

Função responsável por retornar a estrutura dos campos utilizados nas
MGMGET's dos filtros.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323WEstru()

Local aRet as array
Local nPos as numeric

nPos := 0
aRet := {}

nPos := x323AddStr(@aRet)

aRet[nPos][01] := "Data Inicial"
aRet[nPos][02] := 'dDataIni'
aRet[nPos][03] := 'D'
aRet[nPos][04] := 8
_SetNamedPrvt( "dDataIni" , cToD("//"), 'FISA323')

nPos := x323AddStr(@aRet)

aRet[nPos][01] := "Data Final"
aRet[nPos][02] := 'dDataFim'
aRet[nPos][03] := 'D'
aRet[nPos][04] := 8
_SetNamedPrvt( "dDataFim" , cToD("//"), 'FISA323')

nPos := x323AddStr(@aRet)

aRet[nPos][01] := "Seleciona Filiais"
aRet[nPos][02] := 'cSelFil'
aRet[nPos][03] := 'C'
aRet[nPos][04] := 1
aRet[nPos][15] := "1=Sim;2=Não"
aRet[nPos][07] := {||Pertence("12")}
_SetNamedPrvt( "cSelFil" , "2", 'FISA323')

nPos := x323AddStr(@aRet)

aRet[nPos][01] := "Agrupa CNPJ + IE"
aRet[nPos][02] := 'cCNPJIE'
aRet[nPos][03] := 'C'
aRet[nPos][04] := 1
aRet[nPos][15] := "1=Sim;2=Não"
aRet[nPos][07] := {||Pertence("12")}
_SetNamedPrvt( "cCNPJIE" , "2", 'FISA323')

nPos := x323AddStr(@aRet)

aRet[nPos][01] := "Tipo de Periodo"
aRet[nPos][02] := 'cTPPeriod'
aRet[nPos][03] := 'C'
aRet[nPos][04] := 1
aRet[nPos][15] := "1=Mensal;2=Anual"
aRet[nPos][07] := {||Pertence("12")}
_SetNamedPrvt( "cTPPeriod" , "2", 'FISA323')

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x323GetPar()

Função responsável por retornar os parametros configurados na wizard.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323GetPar(aParams, oMark)

Local cAlsMark  as character
Local cMark     as character
Local cTributos as character
Local aInfApu   as array
Local cFil      as character

Default oMark   := Nil
Default aParams := {}

cAlsMark   := oMark:Alias()
cMark      := oMark:Mark()
cTributos  := ""
aInfApu    := {}
cFil	   := FWCodFil()

aAdd(aParams, dDataIni)
aAdd(aParams, dDataFim)
aAdd(aParams, cSelFil)
aAdd(aParams, cCNPJIE)
aAdd(aParams, cTPPeriod)

(cAlsMark)->( DbGoTop() )
While (cAlsMark)->( !EOF() ) 
    If oMark:IsMark(cMark)
        cTributos += (cAlsMark)->F2B_TRIB + "|"
    EndIf
    (cAlsMark)->( DbSkip() )
EndDo

// Tratamento p/ retirar o último pipe para que a formatação fique correta na query.
// Se a string terminar com pipe a função FormatIn retorna a ultima posição em branco.
aAdd(aParams, SubStr(cTributos, 1, Len(cTributos) - 1))

//Filial selecionada antes de abrir a wizard, pode ser diferente da logada.
aAdd(aParams, cFil)

//Array contendo o ID e o OK de processamento/reprocessamento
aInfApu     := Fisa323CKG(aParams)

aAdd(aParams, aInfApu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} x323AddStr()

Função responsável por adicionar um item de estrutura com os valores
DEFAULT. Este item será utilizado pela função x175Estrut para composição
das MGMGET's utilizadas nos steps de filtro.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323AddStr(aEstruct)

Local nPosicao as numeric

Default aEstruct := {}

nPosicao := 0

Aadd(aEstruct,{})
nPosicao := Len(aEstruct)

Aadd(aEstruct[nPosicao],'')			// 01 - Titulo
Aadd(aEstruct[nPosicao],'')			// 02 - Campo
Aadd(aEstruct[nPosicao],'')			// 03 - Tipo
Aadd(aEstruct[nPosicao],0)			// 04 - Tamanho
Aadd(aEstruct[nPosicao],0)			// 05 - Decimal
Aadd(aEstruct[nPosicao],'')			// 06 - Picture
Aadd(aEstruct[nPosicao],{|| .T. })	// 07 - Valid
Aadd(aEstruct[nPosicao],.F.)		// 08 - Obrigat
Aadd(aEstruct[nPosicao],1)			// 09 - Nivel
Aadd(aEstruct[nPosicao],'')			// 10 - Inicializador Padrão
Aadd(aEstruct[nPosicao],'')			// 11 - F3
Aadd(aEstruct[nPosicao],{|| })		// 12 - When
Aadd(aEstruct[nPosicao],.F.)		// 13 - Visual
Aadd(aEstruct[nPosicao],.F.)		// 14 - Chave
Aadd(aEstruct[nPosicao],'')			// 15 - Box - Opção do combo
Aadd(aEstruct[nPosicao],0)			// 16 - Folder
Aadd(aEstruct[nPosicao],.F.)		// 17 - Não Alterável
Aadd(aEstruct[nPosicao],'')			// 18 - PictVar
Aadd(aEstruct[nPosicao],'N')		// 19 - Gatilho

Return nPosicao

//-------------------------------------------------------------------
/*/{Protheus.doc} x323WTRB()

Função responsável por criar e fazer a carga da tabela temporária que
será utilizada na montagem do MarkBrowse dos perfis.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323WTRB(cAlsDados)

Local oTmpTbl  as object
Local oPrepare as object
Local aCampos  as array
Local cAlsQry  as character
Local cAlsTmp  as character
Local cQuery   as character

Default cAlsDados := " "

oTmpTbl  := Nil
oPrepare := Nil
aCampos  := {}
cAlsQry  := GetNextAlias()
cAlsTmp  := GetNextAlias()
cQuery   := " "

// Campos
aAdd(aCampos, {"TRB_OK", "C", 2, 0})
aAdd(aCampos, {"F2B_TRIB", "C", TamSX3("F2B_TRIB")[1], TamSX3("F2B_TRIB")[2]}) 
aAdd(aCampos, {"F2E_DESC", "C", TamSX3("F2E_DESC")[1], TamSX3("F2E_DESC")[2]}) 

// Criação da tabela temporária
oTmpTbl := FWTemporaryTable():New(cAlsTmp, aCampos)

// Adicionando índices
oTmpTbl:AddIndex("1", {"F2B_TRIB"})

// Cria a tabela
oTmpTbl:Create()

cQuery := " SELECT DISTINCT F2B.F2B_TRIB, F2E.F2E_DESC "
cQuery += " FROM " + RetSQLName("CKD") + " CKD "

cQuery += " INNER JOIN " + RetSQLName("CKE") + " CKE ON "
cQuery += " CKE.CKE_FILIAL = CKD.CKD_FILIAL AND "
cQuery += " CKE.CKE_ID = CKD.CKD_ID AND "
cQuery += " CKE.D_E_L_E_T_ = ? "

//Tabela F2B pode ser compartilhada.
cQuery += " LEFT JOIN " + RetSQLName("F2B") + " F2B ON "
cQuery += " F2B.F2B_FILIAL = ? AND "
cQuery += " F2B.F2B_REGRA = CKE.CKE_REGCAL AND "
cQuery += " F2B.D_E_L_E_T_ = ? "

cQuery += " LEFT JOIN " + RetSQLName("F2E") + " F2E ON "
cQuery += " F2E.F2E_FILIAL = ? AND "
cQuery += " F2E.F2E_TRIB = F2B.F2B_TRIB AND "
cQuery += " F2E.D_E_L_E_T_ = ? "

cQuery += " WHERE CKD.CKD_FILIAL = ? AND "
cQuery += " CKD.D_E_L_E_T_ = ? "

cQuery += " ORDER BY F2B.F2B_TRIB "

cQuery := ChangeQuery(cQuery)

oPrepare := FwExecStatement():New(cQuery)

oPrepare:SetString(1, space(1))
oPrepare:SetString(2, FWxFilial("F2B"))
oPrepare:SetString(3, space(1)) 
oPrepare:SetString(4, FWxFilial("F2E"))
oPrepare:SetString(5, space(1)) 
oPrepare:SetString(6, FWxFilial("CKD"))
oPrepare:SetString(7, space(1))

oPrepare:cbasequery := oPrepare:getfixquery()
oPrepare:OpenAlias(cAlsQry)

// Populando a tabela temporária com o conteúdo do alias passado por parâmetro...
While !(cAlsQry)->(EoF())

    RecLock(cAlsTmp, .T.)
        (cAlsTmp)->TRB_OK := Space(2)
        (cAlsTmp)->F2B_TRIB := (cAlsQry)->F2B_TRIB
        (cAlsTmp)->F2E_DESC := (cAlsQry)->F2E_DESC
    (cAlsTmp)->(MsUnlock())

    (cAlsQry)->(dbSkip())
EndDo

// Fechando o alias da query
(cAlsQry)->(dbCloseArea())

If oPrepare != Nil
    oPrepare:Destroy()
	freeobj(oPrepare)
	oPrepare := Nil
EndIf

Return oTmpTbl

//-------------------------------------------------------------------
/*/{Protheus.doc} x323WValid()

Função que faz validação da seleção dos perfis, é necessário ter ao menos 
um perfil selecionado para prosseguir.

@author Wesley Matos / Denis Naves / Rafael Leme
@since 11/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function x323WValid(oObjMark) 

Local lRet     as logical
Local nSel     as numeric
Local cAlsMark as character
Local cMark    as character

Default oObjMark := Nil

lRet     := .T.
nSel     := 0
cAlsMark := oObjMark:Alias()
cMark    := oObjMark:Mark()

If Empty(dDataIni) .Or. Empty(dDataFim)
    lRet := .F.
    Alert(STR0004) //"Os campos de data inicial e data final devem ser preenchidos."
EndIf

// Verifica se ao menos um tributo foi selecionado.
If lRet 
    // Percorre as linhas verificando se alguma foi marcada.
    (cAlsMark)->( DbGoTop() )
    While (cAlsMark)->( !EOF() ) 
        If oObjMark:IsMark(cMark)
            nSel++
        EndIF
        (cAlsMark)->( DbSkip() )
    EndDo

    (cAlsMark)->( DbGoTop() )
    oObjMark:Refresh(.T.)

    If nSel == 0
        lRet := .F.
        Alert(STR0005) //"Deverá ser selecionado ao menos um tributo para apurar."
    EndIF
EndIf

If lRet
    If dDataFim < dDataIni
        lRet := .F.
        Alert(STR0006) //"A data final deve ser maior ou igual à data inicial."
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa323CKG()
Função responsável por efetuar a gravação\reprocessamento na tabela CKG.

@param aParams - Array - Parametros selecionados na tela de Wizard.

@Return Array {cId, lRet}
@author Denis Souza / Carlos Pister / Wesley Matos
@since 21/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function Fisa323CKG( aParams )

Local lRet     as logical
Local cIdApur  as character
Local lIncNew  as logical
Local cQuery   as character
Local oPrepDel as object
Local aInfApur as array

Local cFilCentr as character
Local dDataIni  as date
Local dDataFim  as date
Local cStatus  as character

lRet     := .T.
cIdApur  := ""
lIncNew  := .F.
cQuery   := ""
oPrepDel := Nil
aInfApur := {}
cStatus  := ""

cFilCentr := aParams[FIL_CENTRALIZADORA]
dDataIni  := aParams[DTNICIO]
dDataFim  := aParams[DTFINAL]

DbSelectArea('CKG')
('CKG')->(Dbsetorder(2))

DbSelectArea('CKH')
('CKH')->(Dbsetorder(1))

DbSelectArea('CKI')
('CKI')->(Dbsetorder(1))

If !CKG->(DbSeek(cFilCentr + dToS(dDataIni) + dToS(dDataFim) ) )
    lIncNew := .T.
Else
    cIdApur := CKG->CKG_ID //Recupera o ID para apagar os filhos
    cStatus := CKG->CKG_CONAPU

    If !cStatus == '1'
        if MsgYesNo( STR0009 + CRLF + STR0010 ) //"Atenção, já existe uma apuração realizada, deseja reprocessar? "##"Importante: Se confirmado, essa ação irá apagar permanentemente os registros apurados e gerar uma nova apuração."

            if CKH->(DbSeek(cFilCentr + cIdApur ) )

                oPrepDel := FWPreparedStatement():New()

                cQuery := ''
                cQuery += " DELETE FROM " + RetSqlName("CKH") + " WHERE "
                cQuery += " CKH_FILIAL = ? "
                cQuery += " AND CKH_IDAPUR = ? "

                oPrepDel:SetQuery(cQuery)
                oPrepDel:SetString(1,cFilCentr)
                oPrepDel:SetString(2,cIdApur)

                cQuery := oPrepDel:getFixQuery()

                TCSQLExec(cQuery)
    
                oPrepDel:Destroy()

            endif

            if CKI->(DbSeek(cFilCentr + cIdApur ) ) //Embora seja filha do CKG nao consta no relation do MVC.

                oPrepDel := FWPreparedStatement():New()

                cQuery := ''
                cQuery += " DELETE FROM " + RetSqlName("CKI") + " WHERE "
                cQuery += " CKI_FILIAL = ? "
                cQuery += " AND CKI_IDDETA = ? "

                oPrepDel:SetQuery(cQuery)
                oPrepDel:SetString(1,cFilCentr)
                oPrepDel:SetString(2,cIdApur)

                cQuery := oPrepDel:getFixQuery()

                TCSQLExec(cQuery)
    
                oPrepDel:Destroy()

            endif
        else
            lRet := .F.
        endif
    else
        lRet := .F.
        MsgInfo(STR0007,STR0008)//Há um processamento em andamento para o período informado. Solicitamos, por gentileza, que aguarde a finalização. ## "Importante"
    endIf

EndIf

if lIncNew
    cIdApur := FWUUID("CKG") //Senao encontrar cria uma nova.
    Reclock("CKG", .T.)
        CKG->CKG_FILIAL := cFilCentr
        CKG->CKG_ID     := cIdApur
        CKG->CKG_DTINI  := dDataIni
        CKG->CKG_DTFIM  := dDataFim
    CKG->(MsUnlock())
endif

aAdd(aInfApur, cIdApur)
aAdd(aInfApur, lRet)

Return aInfApur
