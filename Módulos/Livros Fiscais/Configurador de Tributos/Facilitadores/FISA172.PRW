#INCLUDE "FISA172.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC oFont18 := TFont():New("Arial",,18,,.F.,,,,,.F.,.F.)

// Proteção pois em binários 32 bits o objeto TSay não possui o método SetTextAlign.
STATIC oSayCheck  := IIf(!IsBlind(), TSay():New(), NIL)
STATIC cMethIsMemberOf := "MethIsMemberOf"
STATIC lMethAlign := IIF(!IsBlind(), &cMethIsMemberOf.(oSayCheck,"SetTextAlign"), .F.)

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA172FAC

Função principal do facilitador fiscal

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FSA172FAC(aDadosFac)

Local cTpFac := aDadosFac[1]
Local lContinua := .F.
Local cTpPerfil := ""
Local cMsg := STR0003 + Chr(13) + Chr(10) + STR0001 + cTpFac + STR0002 //"Existem perfis tributários cadastrados nesta filial." //"Deseja vincular este " //" a um ou mais perfis?" 

dbSelectArea("F20")
F20->(dbSetOrder(2))

Do Case
    Case cTpFac $ "FORNECEDOR|CLIENTE"
        cTpPerfil := "02"
    Case cTpFac == "PRODUTO"
        cTpPerfil := "04" 
EndCase

lContinua := F20->(MsSeek(xFilial("F20") + cTpPerfil)) .And. MsgYesNo(cMsg)

If lContinua
    x172Wizard(cTpFac, aDadosFac)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA172VLD

Função responsável por validar se o facilitador deve ou não ser executado.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FSA172VLD()

Local lRet := .F.
Local lFacAuto := SuperGetMV("MV_FACAUTO", .F., .F.)

lRet := cPaisLoc == "BRA" .And. !IsBlind() .And. lFacAuto .And. AliasInDic("F20")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA172VIEW

Função responsável por exibir o browse listando os perfis nos quais
a entidade em questão (produto, fornecedor ou cliente) está vinculada.

@author joao.pellegrini
@since 19/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FSA172VIEW(aDadosView)

Local cQryBrw := ""
Local cAlsBrw := GetNextAlias()
Local aSize := MsAdvSize()
Local oDialog := NIL
Local oBrowse := NIL
Local oLayer := FWLayer():New()
Local oPanel1 := NIL
Local oPanel2 := NIL
Local oSayTitulo := NIL
Local cTpQry := ""
Local aParamQry := {}
Local cTpFac := aDadosView[1]
Local aIndex := {}
Local aSeek := {}

// Definindo parâmetros para a query conforme o tipo de perfil
Do Case
    Case cTpFac == "FORNECEDOR"
        cTpQry := "F20_VIEW_F22"
        aParamQry := {"02", "1", aDadosView[2], aDadosView[3]}
    Case cTpFac == "CLIENTE"
         cTpQry := "F20_VIEW_F22"
        aParamQry := {"02", "2", aDadosView[2], aDadosView[3]}
    Case cTpFac == "PRODUTO"
        cTpQry := "F20_VIEW_F24"
        aParamQry := {"04", aDadosView[2]}   
EndCase

// Retorna a query para o browse conforme o tipo de perfil
cQryBrw := x172Query(cTpQry, aParamQry, .F.)

// Criando dialog...
oDialog := FWDialogModal():New()
oDialog:SetBackground(.T.) // .T. -> escurece o fundo da janela 
oDialog:SetTitle(STR0004)//"Perfis Tributários"
oDialog:SetEscClose(.F.)//permite fechar a tela com o ESC
oDialog:SetSize(aSize[4] * 0.8, aSize[3] * 0.8) // chamar sempre antes do CreateDialog
oDialog:EnableFormBar(.T.) 
oDialog:CreateDialog() //cria a janela (cria os paineis)
oDialog:addCloseButton()
oDialog:CreateFormBar()//cria barra de botoes

//Cria Layer
oLayer:Init(oDialog:GetPanelMain(),.F.)

// Adicionando linhas
oLayer:AddLine("L1",10,.F.)
oLayer:AddLine("L2",90,.F.)
oLayer:AddCollumn("L2C1", 0.25, .T., "L2")
oLayer:AddCollumn("L2C2", 99.5, .F., "L2")
oLayer:AddCollumn("L2C3", 0.25, .T., "L2")
oPanel1 := oLayer:getLinePanel("L1")
oPanel2 := oLayer:getColPanel("L2C2", "L2")

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0006 + cTpFac + STR0005},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //"Este " //" está vinculado ao(s) seguinte(s) perfil(is):"
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

// Defino os índices da query que serão disponibilizados na busca do browse.
aIndex := {"PERFIL", "DESCRICAO"}

// Defino os campos que serão disponibilizados na busca do browse.
aAdd(aSeek,{"Cód. Perfil",{{"","C",TamSX3("F20_CODIGO")[1],0,"PERFIL","@!"}}})
aAdd(aSeek,{"Descrição",{{"","C",TamSX3("F20_DESC")[1],0,"DESCRICAO","@!"}}})

// Browse para exibição dos perfis
oBrowse := FWFormBrowse():New()
oBrowse:SetAlias(cAlsBrw)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cQryBrw)
oBrowse:SetOwner(oPanel2)
oBrowse:SetMenuDef("")
oBrowse:DisableDetails()
oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek(,aSeek)

ADD COLUMN oColumn DATA { ||  PERFIL       } TITLE RetTitle("F20_CODIGO") SIZE TamSX3("F20_CODIGO")[1] OF oBrowse
ADD COLUMN oColumn DATA { ||  DESCRICAO    } TITLE RetTitle("F20_DESC")   SIZE TamSX3("F20_DESC")[1]   OF oBrowse

oBrowse:AddButton(STR0007, {|| x172Wizard(cTpFac, aDadosView), oBrowse:Refresh(.T.), oBrowse:Refresh(,.T.), oBrowse:SetFocus()},, 2) //"Vincular a Outro(s) Perfil(is)"
oBrowse:AddButton(STR0017, {|| IIf(x172VldDesv(cTpFac, oBrowse), x172GrvPer(cTpFac, "EXCLUI", oBrowse, aDadosView), NIL), oBrowse:Refresh(.T.), oBrowse:Refresh(,.T.), oBrowse:SetFocus()},, 2) //"Desvincular do Perfil Selecionado"

oBrowse:Activate()
oDialog:Activate()

// Fechando os alias abertos
If Select(cQryBrw) > 0
    (cQryBrw)->(dbCloseArea())
EndIf

If Select(cAlsBrw) > 0
    (cAlsBrw)->(dbCloseArea())
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x172Wizard

Função responsável por montar o wizard utilizado no processamento do
facilitador.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172Wizard(cTpFac, aDadosFac)

Local oPnlTop     := NIL
Local oPnlMid     := NIL
Local oStepWiz    := NIL
Local nSteps      := 0
Local oMarkPerfil := NIL
Local oBrwPerfil  := NIL
Local oTmpTbl     := NIL
Local aCoords     := FWGetDialogSize()
Local oPagIni     := NIL
Local oPagRes     := NIL
Local cAlsDados   := ""

// Executa a query na F20 conforme o tipo de facilitador
Do Case

    Case cTpFac == "FORNECEDOR"
        cAlsDados := x172Query("F20_MARK_CLIFOR", {'02', "1", aDadosFac[2], aDadosFac[3]})
    Case cTpFac == "CLIENTE"
        cAlsDados := x172Query("F20_MARK_CLIFOR", {'02', "2", aDadosFac[2], aDadosFac[3]})
    Case cTpFac == "PRODUTO"
        cAlsDados := x172Query("F20_MARK_PROD", {'04', aDadosFac[2]})
          
EndCase

// Se a query não retornou dados não chamo a wizard e apresento uma mensagem para o usuario
If (cAlsDados)->(Eof())

    MsgInfo(STR0014 + cTpFac + STR0015, STR0016) //"Este já foi vinculado a todos os perfis tributários cadastrados." // "Não há perfis disponíveis".

Else

    // Cria e popula a tabela temporária
    oTmpTbl := x172TRB(cAlsDados)

    // Cria a wizard
    oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.8, aCoords[4] * 0.8})
    oStepWiz:ActiveUISteps()

    nSteps +=1

    oPagIni := oStepWiz:AddStep(cValToChar(nSteps))
    //Altera a descrição do step
    oPagIni:SetStepDescription(STR0008) //"Seleção dos Perfis"
    //Define o bloco de construção
    oPagIni:SetConstruction({|Panel|x172Mark(Panel, cTpFac, @oMarkPerfil, oTmpTbl)})
    //Define o bloco ao clicar no botão Próximo
    oPagIni:SetNextAction({|| x172VlMark(oMarkPerfil) .And. x172Resumo(NIL, @oBrwPerfil, oTmpTbl, .T.)})

    nSteps +=1

    oPagRes := oStepWiz:AddStep(cValToChar(nSteps))
    //Altera a descrição do step
    oPagRes:SetStepDescription(STR0009) //"Resumo"
    //Define o bloco de construção
    oPagRes:SetConstruction({|Panel|x172Resumo(Panel, @oBrwPerfil, oTmpTbl, .F., cTpFac)})
    //Define o bloco ao clicar no botão Próximo
    oPagRes:SetNextAction({|| FwMsgRun(,{|oSay| x172GrvPer(cTpFac, "INCLUI", oBrwPerfil, aDadosFac) }, STR0010, "") .OR. .T. }) //"Processando Informações..."

    oStepWiz:Activate()
    oStepWiz:Destroy()

    // Exclui a tabela temporária do MarkBrowse
    oTmpTbl:Delete()

    // Fechando o alias do resumo...
    If Select("FSA172RES") > 0
        ("FSA172RES")->(dbCloseArea())
    EndIf

EndIf

// Fecha o alias da query
If Select(cAlsDados) > 0
    (cAlsDados)->(dbCloseArea())
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} x172GrvPer

Função responsável por efetuar a gravação dos dados nos perfis.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172GrvPer(cTpFac, cOper, oBrwPerfil, aDadosFac)

Local cAlsBrw := oBrwPerfil:Alias()
Local lAchou := .F.
Local bFound := {||}
Local lGravou := .F.
Local nPerfis := 0

If cOper == "INCLUI"

    BEGIN TRANSACTION

        // Definindo a ordenação conforme o perfil e o codeblock de validação.
        Do Case
            Case cTpFac == "FORNECEDOR"
                dbSelectArea("F22")
                F22->(dbSetOrder(1))
                bFound := {|| F22->( MsSeek ( xFilial("F22") + (cAlsBrw)->PERFIL + "1" + aDadosFac[2] + aDadosFac[3] ) )}
            Case cTpFac == "CLIENTE"
                dbSelectArea("F22")
                F22->(dbSetOrder(1))
                bFound := {|| F22->( MsSeek ( xFilial("F22") + (cAlsBrw)->PERFIL + "2" + aDadosFac[2] + aDadosFac[3] ) )}
            Case cTpFac == "PRODUTO"
                dbSelectArea("F24")
                F24->(dbSetOrder(1))
                bFound := {|| F24->( MsSeek ( xFilial("F24") + (cAlsBrw)->PERFIL + aDadosFac[2] ) )}
        EndCase

        (cAlsBrw)->(dbGoTop())

        While (cAlsBrw)->(!Eof())

            lAchou := Eval(bFound) // <-- Não deveria existir já que o registro está sendo cadastrado agora, mas deixei por precaução apenas.

            If !lAchou
                lGravou := x172AtuPer(cTpFac, cOper, (cAlsBrw)->PERFIL, aDadosFac)
                // Se der erro em alguma gravação faz o disarm da transação e para o laço.
                // Ou grava em todos os perfis ou não grava em nenhum.
                If !lGravou
                    DisarmTransaction()
                    Break
                EndIf
            EndIf

            (cAlsBrw)->(dbSkip())

        EndDo

    END TRANSACTION

    // Exibe mensagem de status de processamento.
    x172Msg(cTpFac, "INCLUI", lGravou)

ElseIf (cAlsBrw)->(!Eof())

    BEGIN TRANSACTION

        lGravou := x172AtuPer(cTpFac, cOper, (cAlsBrw)->PERFIL, aDadosFac)
        // Se der erro faz o disarm da transação.
        If !lGravou
            DisarmTransaction()
        EndIf

    END TRANSACTION
    
    // Exibe mensagem de status de processamento.
    x172Msg(cTpFac, "EXCLUI", lGravou)

EndIf

Return lGravou

//-------------------------------------------------------------------
/*/{Protheus.doc} x172AtuPer

Função responsável por centralizar as chamadas das funções que interagem
com os modelos conforme o tipo de perfil.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172AtuPer(cTpFac, cOper, cCodPerfil, aDadosFac)

Local lRet := .F.

Do Case
    Case cTpFac == "FORNECEDOR"
        lRet := FSA164GF22(cCodPerfil, cOper, "1", aDadosFac[2], aDadosFac[3])
    Case cTpFac == "CLIENTE"
        lRet := FSA164GF22(cCodPerfil, cOper, "2", aDadosFac[2], aDadosFac[3])
    Case cTpFac == "PRODUTO"
        lRet := FSA166GF24(cCodPerfil, cOper, aDadosFac[2])
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x172Mark()

Função responsável por montar o markbrowse dos perfis que poderão ser
selecionados pelo usuário conforme o cadastro que acionou o facilitador.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172Mark(oPanel, cTpFac, oMarkBr, oTmpTbl)

Local cTpPerfil := ""
Local cAlsMark := ""
Local oPanel1 := NIL
Local oPanel2 := NIL
Local oSayTitulo := NIL
Local oLayer := NIL
Local aColumns := {}
Local aSeek := {}
Local aFieldFilter := {}

// Alias que será utilizado no MarkBrowse - Recupera o alias da tabela temporária.
cAlsMark := oTmpTbl:GetAlias()

// Cria as colunas do MarkBrowse conforme a estrutura da tabela temporária.
aColumns := x172Str2Col(oTmpTbl:GetStruct():aFields) 

//Cria Layer
oLayer := FWLayer():New()
oLayer:Init(oPanel,.F.)

// Adicionando linhas
oLayer:AddLine("L1",10,.F.)
oLayer:AddLine("L2",90,.F.)
oPanel1 := oLayer:getLinePanel("L1")
oPanel2 := oLayer:getLinePanel("L2")

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0011 + cTpFac},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //"Selecione o(s) perfil(is) ao(s) qual(is) deseja vincular este "
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

// Defino os detalhes da busca do browse
Aadd(aSeek,{"Cód. Perfil", {{"","C",TamSX3("F20_CODIGO")[1],0,"F20_CODIGO","@!"}}, 1, .T.})
Aadd(aSeek,{"Descrição", {{"","C",TamSX3("F20_DESC")[1],0,"F20_DESC","@!"}}, 2, .T.})

// Adicionando os campos da tabela temporária que ficarão disponíveis para utilização nos filtros (com excecao do campo de mark).
aEval(oTmpTbl:GetStruct():aFields, {|x| Iif(x[1] <> "TRB_OK", Aadd(aFieldFilter, {x[1], x[1], x[2], x[3], x[4], NIL}),)})

// Criação do MarkBrowse
oMarkBr:= FWMarkBrowse():New()
oMarkBr:SetOwner(oPanel2)
oMarkBr:SetDataTable(.T.)
oMarkBr:SetAlias(cAlsMark) //Indica o alias da tabela que será utilizada no Browse
oMarkBr:SetColumns(aColumns)
oMarkBr:SetFieldMark("TRB_OK") //Indica o campo que deverá ser atualizado com a marca no registro
oMarkBr:SetMark("OK", cAlsMark, "TRB_OK")
oMarkBr:SetAllMark({||x172MarkAll(oMarkBr)})
oMarkBr:SetMenuDef("")
oMarkBr:SetIgnoreARotina(.T.)
oMarkBr:SetAmbiente(.F.)
oMarkBr:SetWalkThru(.F.)
oMarkBr:DisableReport()
oMarkBr:DisableDetails()
oMarkBr:oBrowse:SetDBFFilter(.T.)
oMarkBr:oBrowse:SetUseFilter() //Habilita a utilização do filtro no Browse
oMarkBr:oBrowse:SetFieldFilter(aFieldFilter)
oMarkBr:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
oMarkBr:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
oMarkBr:Activate()
oMarkBr:oBrowse:Setfocus()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x172Resumo()

Função responsável por montar o browse de resumo dos perfis baseado
na seleção feita pelo usuário.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172Resumo(oPanel, oResumoPerfil, oTmpTbl, lRefresh, cTpFac)

Local cQueryBrw := ""
Local cAliasTmp := "FSA172RES"
Local aColsBrw := {}
Local oPanel1 := NIL
Local oPanel2 := NIL
Local oSayTitulo := NIL
Local oLayer := FWLayer():New()

DEFAULT lRefresh := .F.
DEFAULT cTpFac := ""

If lRefresh
    If ValType(oResumoPerfil) == "O"
        oResumoPerfil:Refresh(.T.)
    EndIf
Else    
    // Executando query para montagem do Browse
    cQueryBrw := x172Query("F20_MARK_TEMP",,.F.,oTmpTbl)

    //Cria Layer
    oLayer:Init(oPanel,.F.)

    // Adicionando linhas
    oLayer:AddLine("L1",10,.F.)
    oLayer:AddLine("L2",90,.F.)
    oPanel1 := oLayer:getLinePanel("L1")
    oPanel2 := oLayer:getLinePanel("L2")

    //Crio o TSay na primeira linha da Layer
    oSayTitulo := TSay():New(5,5,{|| STR0030 + cTpFac + STR0012},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //"O será vinculado ao(s) perfil(is) listado(s) abaixo. Clique em CONCLUIR para efetivar a operação."
    If lMethAlign
        oSayTitulo:SetTextAlign(2,2)
    EndIf

    // Criação do Browse
    oResumoPerfil := FWFormBrowse():New()
    oResumoPerfil:SetOwner(oPanel2)
    oResumoPerfil:SetDataQuery(.T.)
    oResumoPerfil:SetAlias(cAliasTmp)
    oResumoPerfil:SetQuery(cQueryBrw)
    oResumoPerfil:SetMenuDef("")
    oResumoPerfil:DisableDetails()
    oResumoPerfil:DisableReport()
    oResumoPerfil:DisableConfig()

    ADD COLUMN oColumn DATA { ||  PERFIL       } TITLE RetTitle("F20_CODIGO") SIZE TamSX3("F20_CODIGO")[1] OF oResumoPerfil
    ADD COLUMN oColumn DATA { ||  DESCRICAO    } TITLE RetTitle("F20_DESC")   SIZE TamSX3("F20_DESC")[1]   OF oResumoPerfil

    oResumoPerfil:Activate() 
    oResumoPerfil:SetFocus()
    oResumoPerfil:Refresh(.T.)
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} x172VlMark()

Função que faz validação da seleção dos perfis, é necessário ter ao menos 
um perfil selecionado para prosseguir.

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172VlMark(oObjMark) 

Local cAlsMark := oObjMark:Alias()
Local cMark    := oObjMark:Mark()
Local lRet     := .F.

// Percorre as linhas verificando se alguma foi marcada.

(cAlsMark)->( DbGoTop() )
While (cAlsMark)->( !EOF() ) 
    If oObjMark:IsMark(cMark)
        lRet    := .T.
        Exit
    EndIF
    (cAlsMark)->( DbSkip() )
EndDo

//Retorno para a primeira linha
(cAlsMark)->( DbGoTop() )
oObjMark:Refresh(.T.)

If !lRet
    Alert(STR0013) //"Deverá ser selecionado ao menos um perfil para prosseguir!"
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x172TRB()

Função responsável por criar e fazer a carga da tabela temporária que
será utilizada na montagem do MarkBrowse dos perfis.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172TRB(cAlsDados)

Local oTmpTbl := NIL
Local cAlsTmp := GetNextAlias()
Local aCampos := {}

// Campos
aAdd(aCampos, {"TRB_OK", "C", 2, 0})
aAdd(aCampos, {"F20_CODIGO", "C", TamSX3("F20_CODIGO")[1], TamSX3("F20_CODIGO")[2]}) 
aAdd(aCampos, {"F20_DESC", "C", TamSX3("F20_DESC")[1], TamSX3("F20_DESC")[2]}) 

// Criação da tabela temporária
oTmpTbl := FWTemporaryTable():New(cAlsTmp, aCampos)

// Adicionando índices
oTmpTbl:AddIndex("1", {"F20_CODIGO"})
oTmpTbl:AddIndex("2", {"F20_DESC"})

// Cria a tabela
oTmpTbl:Create()

// Populando a tabela temporária com o conteúdo do alias passado por parâmetro...
While !(cAlsDados)->(EoF())

    RecLock(cAlsTmp, .T.)
        (cAlsTmp)->TRB_OK := (cAlsDados)->TRB_OK
        (cAlsTmp)->F20_CODIGO := (cAlsDados)->F20_CODIGO
        (cAlsTmp)->F20_DESC := (cAlsDados)->F20_DESC
    (cAlsTmp)->(MsUnlock())

    (cAlsDados)->(dbSkip())

EndDo

Return oTmpTbl

//-------------------------------------------------------------------
/*/{Protheus.doc} x172Str2Col()

Função responsável por "converter" a estrutura da tabela passada em 
um array de FWBrwColumn que serão utilizadas na montagem do markbrowse
e também do browse de resumo dos perfis.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172Str2Col(aCampos)

Local aRet := {}
Local nX := 0
Local nPosRet := 0

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
/*/{Protheus.doc} x172MarkAll()

Função responsável por marcar/desmarcar todos os registros.

@author joao.pellegrini
@since 18/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172MarkAll(oObjMark)

Local cAlsMark := oObjMark:Alias()
Local cMark    := oObjMark:Mark()

(cAlsMark)->( DbGoTop() )
While (cAlsMark)->( !EOF() ) 
    RecLock(cAlsMark, .F.)
    If oObjMark:IsMark(cMark)
        (cAlsMark)->TRB_OK := "  "
    Else
        (cAlsMark)->TRB_OK := cMark
    EndIF
    MsUnlock()
    (cAlsMark)->( DbSkip() )
EndDo

//Retorno para a primeira linha
(cAlsMark)->( DbGoTop() )
oObjMark:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} x172Query()

Função responsável por centralizar as queries utilizadas no processamento.

@author joao.pellegrini
@since 20/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x172Query(cTpQry, aParamQry, lExecQry, oTmpTbl)

Local cRet := ""
Local cAlsQry := ""
Local cQuery := ""

DEFAULT aParamQry := {}
DEFAULT lExecQry := .T.

Do Case

    Case cTpQry == "F20_MARK_PROD"

        cQuery := "SELECT '  ' TRB_OK, F20.F20_CODIGO, F20.F20_DESC "
        cQuery += "FROM " + RetSQLName("F20") + " F20 "
        cQuery += "WHERE F20.F20_FILIAL = " + ValToSql(xFilial("F20")) + " AND "
        cQuery += "F20.F20_TIPO = " + ValToSql(aParamQry[1]) + " AND "
        cQuery += "F20.D_E_L_E_T_ = ' ' AND " 
        cQuery += "F20.F20_CODIGO NOT IN ( "
        cQuery +=   "SELECT F20.F20_CODIGO " 
        cQuery +=   "FROM " + RetSQLName("F24") + " F24 "
        cQuery +=   "JOIN " + RetSQLName("F20") + " F20 ON ("
        cQuery +=       "F20.F20_FILIAL = " + ValToSql(xFilial("F20")) + " AND "
        cQuery +=       "F20.F20_TIPO = " + ValToSql(aParamQry[1])     + " AND "
        cQuery +=       "F20.F20_CODIGO = F24.F24_CODIGO AND "
        cQuery +=       "F20.D_E_L_E_T_ = ' ') "
        cQuery +=   "WHERE F24.F24_FILIAL = " + ValToSql(xFilial("F24")) + " AND "
        cQuery +=   "F24.F24_CDPROD = " + ValToSql(aParamQry[2])   + " AND "
        cQuery +=   "F24.D_E_L_E_T_ = ' ' ) "        
        cQuery += "ORDER BY F20.F20_CODIGO"

    Case cTpQry == "F20_MARK_CLIFOR"

        cQuery := "SELECT '  ' TRB_OK, F20.F20_CODIGO, F20.F20_DESC "
        cQuery += "FROM " + RetSQLName("F20") + " F20 " 
        cQuery += "WHERE F20.F20_FILIAL = " + ValToSql(xFilial("F20")) + " AND "
        cQuery += "F20.F20_TIPO = " + ValToSql(aParamQry[1]) + " AND "
        cQuery += "F20.D_E_L_E_T_ = ' '  AND "
        cQuery += "F20.F20_CODIGO NOT IN ( "
        cQuery +=   "SELECT F20.F20_CODIGO " 
        cQuery +=   "FROM " + RetSQLName("F22") + " F22 "
        cQuery +=   "JOIN " + RetSQLName("F20") + " F20 ON ("
        cQuery +=       "F20.F20_FILIAL = " + ValToSql(xFilial("F20")) + " AND "
        cQuery +=       "F20.F20_TIPO = " + ValToSql(aParamQry[1])     + " AND "
        cQuery +=       "F20.F20_CODIGO = F22.F22_CODIGO AND "
        cQuery +=       "F20.D_E_L_E_T_ = ' ') "
        cQuery +=   "WHERE F22.F22_FILIAL = " + ValToSql(xFilial("F22")) + " AND "
        cQuery +=   "F22.F22_TPPART = " + ValToSql(aParamQry[2]) + " AND "
        cQuery +=   "F22.F22_CLIFOR = " + ValToSql(aParamQry[3])   + " AND "
        cQuery +=   "F22.F22_LOJA = " + ValToSql(aParamQry[4])   + " AND "
        cQuery +=   "F22.D_E_L_E_T_ = ' ' ) "
        cQuery += "ORDER BY F20.F20_CODIGO"

    Case cTpQry == "F20_VIEW_F22"

        cQuery := "SELECT F20.F20_CODIGO PERFIL, F20.F20_DESC DESCRICAO " 
        cQuery += "FROM " + RetSQLName("F22") + " F22 "
        cQuery += "JOIN " + RetSQLName("F20") + " F20 ON ("
        cQuery +=   "F20.F20_FILIAL = " + ValToSql(xFilial("F20")) + " AND "
        cQuery +=   "F20.F20_TIPO = " + ValToSql(aParamQry[1])     + " AND "
        cQuery +=   "F20.F20_CODIGO = F22.F22_CODIGO AND "
        cQuery +=   "F20.D_E_L_E_T_ = ' ') "
        cQuery += "WHERE F22.F22_FILIAL = " + ValToSql(xFilial("F22")) + " AND "
        cQuery += "F22.F22_TPPART = " + ValToSql(aParamQry[2]) + " AND "
        cQuery += "F22.F22_CLIFOR = " + ValToSql(aParamQry[3])   + " AND "
        cQuery += "F22.F22_LOJA = " + ValToSql(aParamQry[4])   + " AND "
        cQuery += "F22.D_E_L_E_T_ = ' ' "
        cQuery += "ORDER BY F20.F20_CODIGO"

    Case cTpQry == "F20_VIEW_F24"

        cQuery := "SELECT F20.F20_CODIGO PERFIL, F20.F20_DESC DESCRICAO " 
        cQuery += "FROM " + RetSQLName("F24") + " F24 "
        cQuery += "JOIN " + RetSQLName("F20") + " F20 ON ("
        cQuery +=   "F20.F20_FILIAL = " + ValToSql(xFilial("F20")) + " AND "
        cQuery +=   "F20.F20_TIPO = " + ValToSql(aParamQry[1])     + " AND "
        cQuery +=   "F20.F20_CODIGO = F24.F24_CODIGO AND "
        cQuery +=   "F20.D_E_L_E_T_ = ' ') "
        cQuery += "WHERE F24.F24_FILIAL = " + ValToSql(xFilial("F24")) + " AND "
        cQuery += "F24.F24_CDPROD = " + ValToSql(aParamQry[2])   + " AND "
        cQuery += "F24.D_E_L_E_T_ = ' ' "
        cQuery += "ORDER BY F20.F20_CODIGO"
    
    Case cTpQry == "F20_MARK_TEMP"

         cQuery := "SELECT TRB.F20_CODIGO PERFIL, TRB.F20_DESC DESCRICAO "
         cQuery += "FROM " + oTmpTbl:GetRealName() + " TRB "
         cQuery += "WHERE TRB_OK = 'OK'"

EndCase

cQuery := ChangeQuery(cQuery)

If lExecQry

    cAlsQry := GetNextAlias()
    MPSysOpenQuery(cQuery, cAlsQry)
    (cAlsQry)->(dbGoTop())
    
    cRet := cAlsQry

Else

    cRet := cQuery

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x172Msg()

Função responsável por exibir a mensagem após o processamento do 
facilitador.

@author joao.pellegrini
@since 21/09/2018
@version 12.1.17
/*/ 
//-------------------------------------------------------------------
Static Function x172Msg(cTpFac, cOper, lSucesso)

If lSucesso
    MsgInfo(cTpFac +  IIf(cOper == "INCLUI", STR0020, STR0021) + STR0022, STR0023) // "Vinculado/desvinculado com sucesso // Sucesso
Else
    MsgAlert(STR0024 + cTpFac + STR0025 + IIf(cOper == "INCLUI", STR0026, STR0027) + STR0028, STR0029) // Não foi vinculado a/desvinculado de nenhum perfil // Erro
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x172VldDesv()

Função responsável por validar se foi selecionado um registro ao
clicar no botao "desvincular do perfil selecionado".

@author joao.pellegrini
@since 21/09/2018
@version 12.1.17
/*/ 
//-------------------------------------------------------------------
Static Function x172VldDesv(cTpFac, oBrowse)

Local lRet := .T.
Local cAlsBrw := oBrowse:Alias()

If (cAlsBrw)->(Eof())
    MsgAlert(STR0031, STR0029) //"Nenhum perfil selecionado para desvincular." //Erro
    lRet := .F.
Else
    lRet := MsgYesNo(STR0018 + cTpFac + STR0019)
EndIf

Return lRet
