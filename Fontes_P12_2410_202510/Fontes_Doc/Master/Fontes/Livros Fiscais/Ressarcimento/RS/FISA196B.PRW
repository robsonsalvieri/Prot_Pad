#Include "FISA196B.CH"
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA196B()

Rotina de Regras para Movimentos da ADRC-ST - ARQUIVO DIGITAL DA RECUPERAÇÃO, DO RESSARCIMENTO E DA 
COMPLEMENTAÇÃO DO ICMS ST, do Estado do Rio Grande do Sul.

@author Yuri Fortunato Palacio
@since 23/11/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------
Function FISA196B()
    Local oBrowse
    Local aFields := {'F2W_FILIAL','F2W_CFOP','F2W_DECFOP'}

    If AliasIndic("F2W") .And. AliasIndic("F3M")
		DbSelectArea ("F2W")
		DbSelectArea ("F3M")

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F2W")
        oBrowse:SetDescription(STR0001) //---Cadastro de Regras para Movimentos - Ressarcimento ICMS-ST---//
        oBrowse:SetFilterDefault("F2W_FILIAL == " + ValToSql(xFilial("F2W")))
        oBrowse:SetOnlyFields(aFields)
        oBrowse:Activate()
    Else
        MsgStop(STR0002) //---Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias.---//
    EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Yuri Fortunato Palacio
@since 23/11/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA196B")

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Yuri Fortunato Palacio
@since 23/11/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStructF2W := FWFormStruct(1,"F2W")
    Local oStructF3M := FWFormStruct(1,"F3M")

    oStructF2W:SetProperty('F2W_IDTAB', MODEL_FIELD_INIT ,{||FWUUID("F2W")})
    oStructF3M:SetProperty('F3M_IDF2W', MODEL_FIELD_INIT ,{||oModel:GetValue('F2WMASTER','F2W_IDTAB')})

    oModel := MPFormModel():New("FISA196B",,)
    oModel:AddFields("F2WMASTER",,oStructF2W)
    oModel:AddGrid("F3MDETAIL","F2WMASTER",oStructF3M)
    oModel:SetRelation("F3MDETAIL",{{'F3M_FILIAL','xFilial("F3M")'},{'F3M_IDF2W' ,'F2W_IDTAB' }},F3M->(IndexKey(1)))
    oModel:SetDescription(STR0001)                       //---Cadastro de Regras para Movimentos---//
    oModel:GetModel("F2WMASTER"):SetDescription(STR0003) //---Ress.ICMSST-Regras Apuracao---//
    oModel:GetModel("F3MDETAIL"):SetDescription(STR0004) //---Ress.ICMSST-Det. Regra---//
    oModel:GetModel("F3MDETAIL"):SetUniqueLine({'F3M_CSTICM'})
    oModel:GetModel("F3MDETAIL"):SetUseOldGrid()
Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Yuri Fortunato Palacio
@since 23/11/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel     := FWLoadModel("FISA196B")
    Local oStructF2W := FWFormStruct(2,"F2W")
    Local oStructF3M := FWFormStruct(2,"F3M")
    Local oView      := Nil
    Local cVersao    := GetVersao(.F.)

    oStructF2W:RemoveField("F2W_IDTAB")
    oStructF2W:RemoveField("F2W_FATGER")
    oStructF3M:RemoveField("F3M_IDF2W")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_F2W",oStructF2W,"F2WMASTER")
    oView:AddGrid("VIEW_F3M",oStructF3M,"F3MDETAIL")
    oView:CreateHorizontalBox("HEADER",20)
    oView:CreateHorizontalBox("DETAIL",80)
    oView:EnableTitleView('VIEW_F2W',STR0005) //---CFOP - Código Fiscal de Operações e de Prestações---//
    oView:EnableTitleView('VIEW_F3M',STR0006) //---CST - Código da Situação Tributária - ICMS---//
    oView:SetOwnerView("VIEW_F2W","HEADER")
    oView:SetOwnerView("VIEW_F3M","DETAIL") 

    If cVersao == '12'
        oView:SetViewProperty("*","ENABLENEWGRID")
        oView:SetViewProperty("*","GRIDNOORDER" )
    EndIf
Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA196BC
Funcao responsável por realizar a carga inicial dos registros.

@author Yuri Fortunato Palacio
@since 23/11/2020
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA196BC()
    Local aArea    := GetArea()
    Local aCst     := {"00","10","20","30","40","41","50","51","60","70","90"}
    Local cAlias   := ''
    Local cChave   := ''
    Local cIdTab   := ''
    Local nCount   := 0

    F2W->(DbSetOrder(1))
    F2W->(DbGoTop())
    If !F2W->(DbSeek(xFilial("F2W")))
        cAlias   := GetNextAlias()

        BeginSql Alias cAlias
            SELECT X5_CHAVE
            FROM   %TABLE:SX5% SX5
            WHERE  SX5.X5_FILIAL = %XFILIAL:SX5% AND SX5.X5_TABELA = %EXP:"13"% AND SX5.%NOTDEL%
        EndSql

        DbSelectArea(cAlias)
        While !(cAlias)->(Eof())

            cChave := AllTrim((cAlias)->X5_CHAVE)

            If Len(cChave) == 4
                cIdTab := FWUUID("F2W")

                RecLock("F2W",.T.)
                F2W->F2W_FILIAL := xFilial("F2W")
                F2W->F2W_IDTAB  := cIdTab
                F2W->F2W_CFOP   := cChave
                F2W->F2W_FATGER := "2"
                MsUnLock()

                For nCount := 1 To Len(aCst)
                    RecLock("F3M",.T.)
                    F3M->F3M_FILIAL := xFilial("F3M")
                    F3M->F3M_CSTICM := aCst[nCount]
                    F3M->F3M_IDF2W  := cIdTab
                    MsUnLock()
                Next
            EndIf

            (cAlias)->(DbSkip())        
        EndDo
        (cAlias)->(DbCloseArea()) 

    EndIf

    RestArea(aArea)
Return
