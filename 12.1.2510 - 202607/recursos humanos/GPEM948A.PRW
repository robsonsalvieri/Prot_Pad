#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "GPEM948A.CH"

Static aParamRot := {}
Static cCpf      := ""
Static cNome     := ""

/*/{Protheus.doc} GPEM948A
Tela para exibir detalhes.
@author martins.marcio
@since 01/06/2026
@version 1.0
@param aDetInfo, Array, Dados a exibir na tela de detalhes (ex: { { cDet, cCpf, cNome } })
@return NIL
/*/
Function GPEM948A( aDetInfo )
    Local cTitle := OemToAnsi(STR0001) //"Funcionário"
    Default aDetInfo := {}

    aParamRot := aDetInfo
    cCpf      := ""
    cNome     := ""

    If ValType(aParamRot) == "A" .And. Len(aParamRot) >= 1 .And. ValType(aParamRot[1]) == "A" .And. Len(aParamRot[1]) >= 3
        cCpf  := aParamRot[1][2]
        cNome := aParamRot[1][3]
    EndIf

    FWExecView( cTitle, "GPEM948A", MODEL_OPERATION_VIEW, , {|| .T. }, NIL, 1 )
Return NIL

/*/{Protheus.doc} ModelDef
Definição do modelo MVC com grid de dados.
@author martins.marcio
@since 01/06/2026
@version 1.0
/*/
Static Function ModelDef()
    Local oModel     := MPFormModel():New("GPEM948A", NIL, NIL, {|oMdl| .T. })
    Local oStructCab := StruCab()

    oModel:SetDescription( OemToAnsi(STR0002) ) //"Detalhes do Funcionário"

    oModel:AddFields("GP948A_MCAB", NIL, oStructCab, NIL, NIL, {|oMdl| CargaCab(oMdl) })
    oModel:GetModel("GP948A_MCAB"):SetDescription( OemToAnsi(STR0003) ) //"Identificação"
    oModel:GetModel("GP948A_MCAB"):SetOnlyView(.T.)

    oModel:SetPrimaryKey({})

Return oModel

Static Function StruCab()
    Local oStru  := FWFormModelStruct():New()
    Local bVazio := {|| .T.}

    oStru:AddField("CPF", "CPF", "DET_CPF", "C", 11, 0, bVazio, bVazio, {}, .F., {|| "" }, NIL, NIL, .F.)
    oStru:AddField(OemToAnsi(STR0004), OemToAnsi(STR0004), "DET_NOME", "C", 40, 0, bVazio, bVazio, {}, .F., {|| "" }, NIL, NIL, .F.) //"NOME"

Return oStru

Static Function ViewCab()
    Local oStru := FWFormViewStruct():New()

    oStru:AddField("DET_CPF", "01", "CPF", "CPF", NIL, "C", "@R 999.999.999-99", NIL, "", .F., "", "", {}, 0, "", .F.)
    oStru:AddField("DET_NOME", "02", OemToAnsi(STR0005), OemToAnsi(STR0005), NIL, "C", "", NIL, "", .F., "", "", {}, 0, "", .F.) // "Nome"
    
Return oStru

Static Function CargaCab(oModel)
    Local cValue1 := IIf(ValType(cCpf) == "C", AllTrim(cCpf), "")
    Local cValue2 := IIf(ValType(cNome) == "C", AllTrim(cNome), "")

Return { cValue1, cValue2 }

/*/{Protheus.doc} ViewDef
Definição da view MVC (grid simples).
@author martins.marcio
@since 01/06/2026
@version 1.0
/*/
Static Function ViewDef()
    Local oView    := FWFormView():New()
    Local oModel   := FWLoadModel("GPEM948A")
    Local oCabView := ViewCab()

    oView:SetModel(oModel)
    oView:AddField("GP948A_VCAB", oCabView, "GP948A_MCAB")
    oView:AddOtherObject("GP948A_VDET", {|oPanel| ShowText(oPanel) })

    oView:CreateHorizontalBox("BOX_TOP", 15)
    oView:CreateHorizontalBox("BOX_GRID", 85)

    oView:SetOwnerView("GP948A_VCAB", "BOX_TOP")
    oView:SetOwnerView("GP948A_VDET", "BOX_GRID")

    oView:EnableTitleView("GP948A_VDET", OemToAnsi(STR0006)) //"Detalhes da Análise"
    oView:SetCloseOnOk({ || .T. })

Return oView

/*/{Protheus.doc} ShowText
Renderiza os detalhes em modo livre (labels) dentro do painel da view.
@param oPanel, Object, painel da view
@return NIL
/*/
Static Function ShowText(oPanel)
    Local cMemo := OemToAnsi(STR0007) // "Sem informações"

    Default oPanel := NIL

    If ValType(aParamRot) == "A" .And. Len(aParamRot) >= 1 .And. ValType(aParamRot[1]) == "A" .And. Len(aParamRot[1]) >= 1 .And. ValType(aParamRot[1][1]) == "C" .And. !Empty(AllTrim(aParamRot[1][1]))
        cMemo := aParamRot[1][1]
    EndIf

    // Width 300 x Height 220
    @ 02, 01 GET oMemo VAR cMemo MEMO SIZE 300, 220 READONLY HSCROLL CENTERED OF oPanel

Return NIL
