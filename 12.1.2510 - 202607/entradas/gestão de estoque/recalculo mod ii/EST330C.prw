#include "totvs.ch"
#include "fwmvcdef.ch"
#include "fwmbrowse.ch"
#include "est330c.ch"

PUBLISH MODEL REST NAME EST330C

/*/{Protheus.doc} ModelDef
    Modelo de dados do cadastro
    @type  Static Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    /*/
Static Function ModelDef()
    Local oStruSB9
    Local oStruD4I
    Local oModel
    Local cCamposD4I
    Local cVldRev
    Local cVldPar
    Local cVldMoe
    Local lD4IManual := D4I->(FieldPos("D4I_MANUAL")) > 0
    Local bPreValid  := {|oModelGrid, nLine, cAction, cField, xValue| EST330CPre(cAction, cField, xValue)}
    Local bPosValid  := {|oModel| EST330CPos(oModel)}
    Local bVldRev
    Local bVldPar
    Local bVldMoe
    Local aTrigger   := {}

    oStruSB9 := FWFormStruct(1, "SB9", {|x| AllTrim(x) $ "B9_COD|B9_LOCAL|B9_DATA|B9_QINI|B9_VINI1|B9_VINI2|B9_VINI3|B9_VINI4|B9_VINI5"})
    oStruSB9:AddField(STR0002,;     // [01] Titulo do campo
	STR0003,;			            // [02] ToolTip do campo
	"B9_DATA",; 					// [03] Id do Field
	"D",;							// [04] Tipo do campo
	8,;								// [05] Tamanho do campo
	0,;								// [06] Decimal do campo
	Nil,;							// [07] Code-block de validacao do campo
	Nil,;							// [08] Code-block de validacao When do campo
	Nil,;						    // [09] Lista de valores permitido do campo
	.F.,;						    // [10] Indica se o campo tem preenchimento obrigatorio
	{|| FWFldGet("B9_DATA")},;      // [11] Code-block de inicializacao do campo
	Nil,;						    // [12] Indica se trata-se de um campo chave
	.F.,;						    // [13] Indica se o campo pode receber valor em uma operacao de update
	.F.)						    // [14] Indica se o campo e virtual
    cCamposD4I := "D4I_COD|D4I_LOCAL|D4I_DATA|D4I_REVISA|D4I_PARTE|D4I_MOEDA|D4I_UNITAR|D4I_TOTAL"
    If lD4IManual
        cCamposD4I += "|D4I_MANUAL"
    EndIf
    oStruD4I := FWFormStruct(1, "D4I", {|x| AllTrim(x) $ cCamposD4I})
    oModel := MPFormModel():New("EST330C", , bPosValid)
    oModel:AddFields("SB9MASTER", , oStruSB9)
    oModel:AddGrid("D4IDETAIL", "SB9MASTER", oStruD4I, bPreValid)
    oModel:SetRelation("D4IDETAIL",{{"D4I_FILIAL", "FWxFilial('D4I')"},;
                                    {"D4I_COD",    "B9_COD"},;
                                    {"D4I_LOCAL",  "B9_LOCAL"},;
                                    {"D4I_DATA",   "B9_DATA"}},;
                                    D4I->(IndexKey(1)))

    oModel:GetModel("SB9MASTER"):SetDescription(STR0004) // Dados de saldos iniciais
    oModel:GetModel("SB9MASTER"):SetOnlyView(.T.)
    oModel:GetModel("SB9MASTER"):SetOnlyQuery(.T.)
    oModel:GetModel("SB9MASTER"):SetPrimaryKey({"B9_COD","B9_LOCAL","B9_DATA"})
    oModel:GetModel("D4IDETAIL"):SetDescription(STR0005) // Dados de saldos iniciais em partes
    oModel:GetModel("D4IDETAIL"):SetUniqueLine({"D4I_REVISA", "D4I_PARTE", "D4I_MOEDA"})
    oModel:GetModel("D4IDETAIL"):SetOptional(.T.)
    // Adiciona validacao para o campo de revisao
    cVldRev := "EST330CRev(FWFldGet('D4I_REVISA'))"
    bVldRev := FWBuildFeature(STRUCT_FEATURE_VALID, cVldRev)
    oStruD4I:SetProperty("D4I_REVISA", MODEL_FIELD_VALID, bVldRev)
    // Adiciona validacao para o campo de parte
    cVldPar := "EST330CPar(FWFldGet('D4I_REVISA'), FWFldGet('D4I_PARTE'))"
    bVldPar := FWBuildFeature(STRUCT_FEATURE_VALID, cVldPar)
    oStruD4I:SetProperty("D4I_PARTE", MODEL_FIELD_VALID, bVldPar)
    // Adiciona validacao para o campo de moeda
    cVldMoe := "EST330CMoe(FWFldGet('D4I_MOEDA'))"
    bVldMoe := FWBuildFeature(STRUCT_FEATURE_VALID, cVldMoe)
    oStruD4I:SetProperty("D4I_MOEDA", MODEL_FIELD_VALID, bVldMoe)
    // Adiciona trigger para completar os campos D4I_PARTE e D4I_MOEDA com zero a esquerda
    aTrigger := FwStruTrigger("D4I_PARTE", "D4I_PARTE", "EST330CTrg('D4I_PARTE', FWFldGet('D4I_PARTE'))")
    oStruD4I:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
    aTrigger := FwStruTrigger("D4I_MOEDA", "D4I_MOEDA", "EST330CTrg('D4I_MOEDA', FWFldGet('D4I_MOEDA'))")
    oStruD4I:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
    // Adiciona trigger para gravar o campo D4I_MANUAL com S
    If lD4IManual
        aTrigger := FwStruTrigger("D4I_REVISA", "D4I_MANUAL", "'S'")
        oStruD4I:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
    EndIf
    // Adiciona trigger para calculo automatico do custo unitario a partir do total
    aTrigger := FwStruTrigger("D4I_TOTAL", "D4I_UNITAR", "EST330CTru(FWFldGet('D4I_TOTAL'), FWFldGet('B9_QINI'))")
    oStruD4I:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])
    // Define campos obrigatorios da grid
    oStruD4I:SetProperty("D4I_REVISA", MODEL_FIELD_OBRIGAT, .T.)
    oStruD4I:SetProperty("D4I_PARTE", MODEL_FIELD_OBRIGAT, .T.)
    oStruD4I:SetProperty("D4I_MOEDA", MODEL_FIELD_OBRIGAT, .T.)
    // Validacao executada na ativacao do modelo
    oModel:SetActivate({|oModel| EST330CAct(oModel)})

Return oModel

/*/{Protheus.doc} ViewDef
    Interface do cadastro
    @type  Static Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    /*/
Static Function ViewDef()
    Local oStruSB9
    Local oStruD4I
    Local oModel
    Local oView

    oStruSB9 := FWFormStruct(2, "SB9", {|x| AllTrim(x) $ "B9_COD|B9_LOCAL|B9_DATA|B9_QINI|B9_VINI1|B9_VINI2|B9_VINI3|B9_VINI4|B9_VINI5"})
    oStruSB9:AddField("B9_DATA",;   // [01] Nome do Campo
	"04",;                          // [02] Ordem
	STR0002,;                       // [03] Titulo do campo
	STR0003,;                       // [04] Descricao do campo
	Nil,;                           // [05] Array com Help
	"D",;                           // [06] Tipo do campo
	Nil,;                           // [07] Picture
	Nil,;                           // [08] Bloco de Picture Var
	Nil,;                           // [09] Consulta F3
	.F.,;                           // [10] Indica se o campo e alteravel
	Nil,;                           // [11] Pasta do campo
	Nil,;                           // [12] Agrupamento do campo
	Nil,;                           // [13] Lista de valores permitido do campo (Combo)
	Nil,;                           // [14] Tamanho maximo da maior opcao do combo
	Nil,;                           // [15] Inicializador de Browse
	.F.,;                           // [16] Indica se o campo e virtual
	Nil,;                           // [17] Picture Variavel
	Nil)                            // [18] Indica pulo de linha apos o campo
    oStruD4I := FWFormStruct(2, "D4I", {|x| AllTrim(x) $ "D4I_REVISA|D4I_PARTE|D4I_MOEDA|D4I_UNITAR|D4I_TOTAL"})
    oModel := FWLoadModel("EST330C")
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_SB9", oStruSB9, "SB9MASTER")
    oView:AddGrid("VIEW_D4I", oStruD4I, "D4IDETAIL")
    oView:CreateHorizontalBox("CABECALHO", 30)
    oView:CreateHorizontalBox("ITENS", 70)
    oView:SetOwnerView("VIEW_SB9", "CABECALHO")
    oView:SetOwnerView("VIEW_D4I", "ITENS")
    // Remove botao Salvar e Criar Novo
    oView:SetCloseOnOk({|| .T.})
    // Altera picture do campo
    oStruD4I:SetProperty("D4I_PARTE", MVC_VIEW_PICT, "@ 99")
    oStruD4I:SetProperty("D4I_MOEDA", MVC_VIEW_PICT, "@ 99")
    // Define uma acao chamada depois do Activate do View
    oView:SetAfterViewActivate({|| EST330CAft(oModel)})

Return oView

/*/{Protheus.doc} E330Upsert
    Apresenta janela com a view do programa
    @type  Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    /*/
Function E330Upsert()

Return FWExecView(STR0001, "EST330C", MODEL_OPERATION_UPDATE) // Saldo inicial em partes

/*/{Protheus.doc} EST330CPre
    Funcao de pre validacao
    @type  Static Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    @param oModel, object, Modelo de dados
    @return lRet, logical, retorno
    /*/
Static Function EST330CPre(cAction, cField, xValue)
    Local aSaveLines := FWSaveRows()
    Local nValue := 0
    Local lRet   := .T.

    If cAction == "SETVALUE" .And. cField $ "D4I_PARTE|D4I_MOEDA"
        nValue := Val(AllTrim(xValue))
        If nValue <= 0
            Help(, 1, "VALZERO", , STR0006, 1, 0, , , , , , {STR0007}) // O conteúdo informado deve ser maior que zero. - Informe um valor maior que zero.
            lRet := .F.
        EndIf
    EndIf

    FWRestRows(aSaveLines)
Return lRet

/*/{Protheus.doc} EST330CPos
    Funcao de pos validacao
    @type  Static Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    @param oModel, object, Modelo de dados
    @return lRet, logical, retorno
/*/
Function EST330CPos(oModel)
    Local oModelSB9  := oModel:GetModel("SB9MASTER")
    Local oModelD4I  := oModel:GetModel("D4IDETAIL")
    Local nX         := 0
    Local nTot01     := 0
    Local nTot02     := 0
    Local nTot03     := 0
    Local nTot04     := 0
    Local nTot05     := 0
    Local lHasItems  := .F.
    Local lRet       := .T.
    Local aSaveLines := FWSaveRows()

    For nX := 1 To oModelD4I:Length()
        oModelD4I:GoLine(nX)
        If !oModelD4I:IsDeleted()
            lHasItems := .T.
            If oModelD4I:GetValue("D4I_MOEDA") == "01"
                nTot01 += oModelD4I:GetValue("D4I_TOTAL")
            ElseIf oModelD4I:GetValue("D4I_MOEDA") == "02"
                nTot02 += oModelD4I:GetValue("D4I_TOTAL")
            ElseIf oModelD4I:GetValue("D4I_MOEDA") == "03"
                nTot03 += oModelD4I:GetValue("D4I_TOTAL")
            ElseIf oModelD4I:GetValue("D4I_MOEDA") == "04"
                nTot04 += oModelD4I:GetValue("D4I_TOTAL")
            ElseIf oModelD4I:GetValue("D4I_MOEDA") == "05"
                nTot05 += oModelD4I:GetValue("D4I_TOTAL")
            EndIf
        EndIf
    Next nX

    If lHasItems
        If  nTot01 <> oModelSB9:GetValue("B9_VINI1") .Or.;
            nTot02 <> oModelSB9:GetValue("B9_VINI2") .Or.;
            nTot03 <> oModelSB9:GetValue("B9_VINI3") .Or.;
            nTot04 <> oModelSB9:GetValue("B9_VINI4") .Or.;
            nTot05 <> oModelSB9:GetValue("B9_VINI5")
            Help(, 1, "TOTPARTES", , STR0008, 1, 0, , , , , , {STR0009}) // O custo total do saldo em partes deve ser igual ao saldo inicial em valor do mês. - Verifique a distribuição do saldo entre as partes/moedas.
            lRet := .F.
        EndIf
    EndIf

    FWRestRows(aSaveLines)
Return lRet

/*/{Protheus.doc} EST330CTrg
    Completa os campos D4I_PARTE e D4I_MOEDA com zero a esquerda
    @type  Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    @param cField, caracter, Campo que recebera atualizacao
            xValue, caracter, Conteudo preenchido no campo
    @return xRet, caracter, Conteudo completado com zero a esquerda
    /*/
Function EST330CTrg(cField, xValue)
    Local nValue := 0
    Local xRet

    nValue := Val(AllTrim(xValue))
    xRet   := StrZero(nValue, 2)

    FWFldPut(cField, xRet)

Return xRet

/*/{Protheus.doc} EST330CTru
    Calculo automatico do custo unitario a partir do total
    @type  Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    @param cField, caracter, Campo que recebera atualizacao
            xValue, caracter, Conteudo preenchido no campo
    @return xRet, caracter, Conteudo completado com zero a esquerda
    /*/
Function EST330CTru(xValueTot, xValueQtd)
    Local nValUnit := 0

    If xValueQtd > 0
        nValUnit := xValueTot / xValueQtd
    EndIf

Return nValUnit

/*/{Protheus.doc} EST330CAct
    Funcao executada na ativacao do modelo
    @type  Static Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    @param oModel, object, Modelo de dados
    /*/
Static Function EST330CAct(oModel)

    If EST330CBlE(oModel)
        oModel:GetModel("D4IDETAIL"):SetNoDeleteLine(.T.)
        oModel:GetModel("D4IDETAIL"):SetNoInsertLine(.T.)
        oModel:GetModel("D4IDETAIL"):SetNoUpdateLine(.T.)
    EndIf

Return

/*/{Protheus.doc} EST330CBlE
    Valida se bloqueia edicao da grid
    @type  Static Function
    @author Squad.Entradas
    @since 29/07/2025
    @version 1.0
    @param oModel, object, Modelo de dados
    /*/
Static Function EST330CBlE(oModel)
    Local oModelD4I
    Local aSaveLines := FWSaveRows()
    Local nX         := 0
    Local lBloqEdit  := .F.

    oModelD4I := oModel:GetModel("D4IDETAIL")

    If D4I->(FieldPos("D4I_MANUAL")) > 0
        For nX := 1 To oModelD4I:Length()
            oModelD4I:GoLine(nX)
            If oModelD4I:GetValue("D4I_MANUAL") $ "NI" // So permite edicao da grid para itens inseridos manualmente
                lBloqEdit := .T.
                Exit
            EndIf
        Next nX
    EndIf

    FWRestRows(aSaveLines)

Return lBloqEdit

/*/{Protheus.doc} EST330CAft
    Mensagem informativa sobre a edicao da grid
    @type  Static Function
    @author Squad.Entradas
    @since 07/08/2025
    @version 1.0
    /*/
Static Function EST330CAft(oModel)

    If !IsBlind()
        If EST330CBlE(oModel)
            Aviso(STR0010, STR0011 + CHR(13)+CHR(10) + STR0012, {STR0013}) // "Edicao bloqueada / Saldo gerado pelo fechamento ou importação. / Só é possível editar saldos inseridos manualmente / Ok.
        EndIf
    EndIf

Return

/*/{Protheus.doc} EST330CRev
    Validacao da revisao informada
    @type  Function
    @author Squad.Entradas
    @since 12/08/2025
    @version 1.0
    @param cRevis, character, revisao
    @return lRet, logical, lRet
    /*/
Function EST330CRev(cRevis)
    Local cRevAtu := ""
    Local lRet := .T.

    If !Empty(cRevis)
        If FindFunction("E330RevAti")
            cRevAtu := E330RevAti()
            If cRevis <> cRevAtu
                Help(, 1, "INVALIDREV", , STR0014, 1, 0, , , , , , {STR0015}) // A revisão informada é inválida. - Informe uma revisão ativa.
                lRet := .F.
            EndIf
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} EST330CPar
    Validacao da parte informada
    @type  Function
    @author Squad.Entradas
    @since 12/08/2025
    @version 1.0
    @param  cRevis, character, revisao
            cParte, character, parte
    @return lRet, logical, lRet
    /*/
Function EST330CPar(cRevis, cParte)
    Local cParteStr := ""
    Local lRet      := .T.

    If !Empty(cRevis)
        If !Empty(cParte)
            cParteStr := StrZero(Val(AllTrim(cParte)), 2)
            If cParteStr <> Posicione("D4F", 1, FWXFilial("D4F")+cRevis+cParteStr, "D4F_CODPAR")
                Help(, 1, "INVALIDPAR", , STR0016, 1, 0, , , , , , {STR0016}) // A parte informada é inválida. - Informe uma parte válida.
                lRet := .F.
            EndIf
        EndIf
    Else
        Help(, 1, "INVALIDREV", , STR0014, 1, 0, , , , , , {STR0015}) // A revisão informada é inválida. - Informe uma revisão ativa.
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} EST330CMoe
    Validacao da moeda informada
    @type  Function
    @author Squad.Entradas
    @since 12/08/2025
    @version 1.0
    @param  cMoeda, character, moeda
    @return lRet, logical, lRet
    /*/
Function EST330CMoe(cMoeda)
    Local lRet := .T.

    If !Empty(cMoeda)
        If Val(cMoeda) < 1 .Or. Val(cMoeda) > 5
            Help(, 1, "INVALIDMOE", , STR0018, 1, 0, , , , , , {STR0019}) // A moeda informada é inválida. - Informe uma moeda válida.
            lRet := .F.
        EndIf
    EndIf

Return lRet
