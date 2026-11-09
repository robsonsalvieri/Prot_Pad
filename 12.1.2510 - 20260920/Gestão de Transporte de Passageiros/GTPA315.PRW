#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA315.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA315
'Cadastro de Tipos de Documentos Operacionais'
@type Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return nil, retorna nulo

Historico de alteracoes:
  11/09/2026 - Adicionado campo G6U_RELGYG para amarrar campo da tabela GYG
               que fornece a data de inicio/fim do documento na integracao RH.
/*/
//------------------------------------------------------------------------------
Function GTPA315()

Local oBrowse   := Nil

If ( !FindFunction("GTPHASACCESS") .Or.; 
    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    oBrowse       := FWMBrowse():New()
    oBrowse:SetAlias('G6U')
    oBrowse:SetMenuDef('GTPA315')

    oBrowse:AddLegend("G6U_MSBLQL == '1'" , "RED"   , STR0002   )// "Inativo" 
    oBrowse:AddLegend("G6U_MSBLQL <> '1'" , "GREEN" , STR0003   )// "Ativo"

    oBrowse:SetDescription(STR0001)// 'Cadastro de Tipos de Documentos Operacionais'

    oBrowse:Activate()
    oBrowse:Destroy()

    GTPDestroy(oBrowse)

EndIf

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA315' OPERATION OP_VISUALIZAR   ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA315' OPERATION OP_INCLUIR       ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA315' OPERATION OP_ALTERAR       ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.GTPA315' OPERATION OP_EXCLUIR       ACCESS 0 // "Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author Cleiton Genuino
@since 04/07/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrG6U   := FWFormStruct(1,'G6U')

SetModelStruct(oStrG6U)

oModel := MPFormModel():New('GTPA315', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G6UMASTER',/*cOwner*/,oStrG6U)

oModel:SetDescription(STR0001)// 'Cadastro de Tipos de Documentos Operacionais'

oModel:GetModel('G6UMASTER'):SetDescription(STR0001) // 'Cadastro de Tipos de Documentos Operacionais'

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
Inclui o campo G6U_RELGYG: combo com os campos Data/Caracter da tabela GYG
que podem ser usados como origem de data inicial do documento na integracao RH.
@type Static Function
@author jacomo.fernandes / Cleiton Genuino
@since 04/07/2019 / 11/09/2026
@version 1.1
@param oStrG6U, object, Estrutura do formulario G6U
@return nil, retorno nulo
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrG6U)
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig     := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

If ValType(oStrG6U) == "O"
    oStrG6U:SetProperty('G6U_TPVIGE'    ,MODEL_FIELD_VALUES ,GetComboBox('G6U_TPVIGE'))
    oStrG6U:SetProperty('G6U_TPTOLE'    ,MODEL_FIELD_VALUES ,GetComboBox('G6U_TPTOLE'))
    oStrG6U:SetProperty('G6U_MSBLQL'    ,MODEL_FIELD_VALUES ,GetComboBox('G6U_MSBLQL'))

    // Combo dinamico com os campos Date/Character da GYG disponiveis para amarracao
    If G6U->(FieldPos('G6U_RELGYG')) > 0
        oStrG6U:SetProperty('G6U_RELGYG', MODEL_FIELD_VALUES, GetComboBox('G6U_RELGYG'))
    EndIf
    If G6U->(FieldPos('G6U_DATGYG')) > 0
        oStrG6U:SetProperty('G6U_DATGYG', MODEL_FIELD_VALUES, GetComboBox('G6U_DATGYG'))
    EndIf

    oStrG6U:AddTrigger('G6U_TPVIGE'    ,'G6U_TPVIGE'       ,{||.T.}, bTrig)
    oStrG6U:AddTrigger('G6U_TPTOLE'    ,'G6U_TPTOLE'        ,{||.T.}, bTrig)

    oStrG6U:SetProperty('G6U_TEMPVI'   , MODEL_FIELD_VALID , bFldVld)
    oStrG6U:SetProperty('G6U_TEMPTO'   , MODEL_FIELD_VALID , bFldVld)

    oStrG6U:SetProperty('G6U_TRECUR'   , MODEL_FIELD_INIT  , {||"1"})
    oStrG6U:SetProperty('G6U_TPVIGE'   , MODEL_FIELD_INIT  , {||"1"})
    oStrG6U:SetProperty('G6U_TPTOLE'   , MODEL_FIELD_INIT  , {||"1"})
    oStrG6U:SetProperty('G6U_MSBLQL'   , MODEL_FIELD_INIT  , {||"2"})
    oStrG6U:SetProperty('G6U_RELGYG'  , MODEL_FIELD_INIT   , {||" "})
    oStrG6U:SetProperty('G6U_DATGYG'  , MODEL_FIELD_INIT   , {||" "})

    oStrG6U:SetProperty('G6U_TEMPVI'   , MODEL_FIELD_WHEN  , {|oMdl|FwIsInCallStack('FIELDTRIGGER') .or. oMdl:GetValue('G6U_TPVIGE') <= "3" })
    oStrG6U:SetProperty('G6U_TEMPTO'   , MODEL_FIELD_WHEN  , {|oMdl|FwIsInCallStack('FIELDTRIGGER') .or. oMdl:GetValue('G6U_TPTOLE') <= "3" })

    // G6U_RELGYG so aparece habilitado quando o tipo de recurso for "1=Colaborador"
    If G6U->(FieldPos('G6U_RELGYG')) > 0 .And.  G6U->(FieldPos('G6U_DATGYG')) > 0 
        oStrG6U:SetProperty('G6U_RELGYG', MODEL_FIELD_WHEN , {|oMdl| oMdl:GetValue('G6U_TRECUR') == "1" })
        oStrG6U:SetProperty('G6U_DATGYG', MODEL_FIELD_WHEN , {|oMdl| oMdl:GetValue('G6U_TRECUR') == "1" })
    EndIf

Endif

Return nil
/*/{Protheus.doc} GYGCombo
    Monta combo dinamico com os campos da tabela GYG que sao do tipo Data (D)
    ou Caracter (C) e podem representar uma data do documento do colaborador.
    Apenas campos com X3_CONTEXT = "R" (Reais) sao listados.
    @type Function Static
    @author Cleiton Genuino
    @since 11/09/2026
    @version 1.0
    @return array , aCombo array no formato {"CAMPO=Titulo - Descricao", ...}
/*/
Static Function GYGCombo(aTipos)
Local aAreaSX3 := {}    as array
Local aCombo   := {}    as array
Local cTabGYG  := "GYG" as character
Default aTipos := {"D"}

// Tipos aceitos para data de vigencia: Data (D) ou Caracter (C) que represente data
aAreaSX3 := SX3->(FwGetArea())
cTabGYG  := "GYG"
DbSelectArea("SX3")
SX3->(DbSetOrder(1)) // X3_ARQUIVO + X3_CAMPO

    aAdd(aCombo, Space(10) + "=" + Space(10))

If SX3->(DbSeek(cTabGYG))
    While SX3->(!EoF()) .And. AllTrim(SX3->X3_ARQUIVO) == cTabGYG
        // Filtra: somente campos Reais, do tipo Data, nao deletados
        If !SX3->(Deleted()) ;
            .And. AllTrim(SX3->X3_CONTEXT) == "R" ;
            .And. AScan(aTipos, {|t| t == SubStr(SX3->X3_TIPO,1,1)}) > 0 ;
            .And. !Empty(AllTrim(SX3->X3_CAMPO))
            // Formato do combo: "GYG_CNHEMS=Emissao CNH"
            aAdd(aCombo, AllTrim(SX3->X3_CAMPO) + "=" + AllTrim(SX3->X3_TITULO))
        EndIf
        SX3->(DbSkip())
    End
EndIf

FwRestArea(aAreaSX3)

Return aCombo

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oMdl, object
@param cField, character
@param uNewValue, character
@param uOldValue, character
@return lRet, retorno logico
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet      := .T.
Local oModel    := oMdl:GetModel()
Local cMdlId    := oMdl:GetId()
Local cMsgErro  := ""
Local cMsgSol   := ""

Do Case
    Case Empty(uNewValue)
        lRet := .T.
    Case cField == "G6U_TEMPVI" .or. cField == "G6U_TEMPTO"
        If uNewValue < 0
            lRet        := .F.
            cMsgErro    := STR0008// "Não pode informar um valor menor que zero"
            cMsgSol     := STR0009// "Necessário informar um valor positivo"
        Endif
EndCase

If !lRet .and. !Empty(cMsgErro)
    oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelos gatilhos dos campos
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oMdl, object , Objeto do modelo avaliado no gatilho
@param cField, character, Campo a ser validado na gatilho
@param uVal, character , Deve retornar o set valor do gatilho
@return uVal, retorna o mesmo valor que recebeu
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
    Case cField == "G6U_TPVIGE"
        oMdl:SetValue('G6U_TEMPVI',0)
    Case cField == "G6U_TPTOLE"
        oMdl:SetValue('G6U_TEMPTO',0)
EndCase

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Cleiton Genuino
@since 04/07/2019
@version 1.1
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView     := FWFormView():New()
Local oModel    := FwLoadModel('GTPA315')
Local oStrG6U   := FWFormStruct(2, 'G6U')

SetViewStruct(oStrG6U)

oView:SetModel(oModel)

oView:AddField('VIEW_G6U' ,oStrG6U,'G6UMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_G6U','TELA')

oView:SetDescription(STR0001) // 'Cadastro de Tipos de Documentos Operacionais'

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da View
Adicionado grupo GRP003 com o campo G6U_RELGYG para amarracao do campo GYG.
@type Static Function
@author Cleiton Genuino
@since 11/09/2026
@version 1.1
@param oStrG6U, object, Estrutura de view da G6U
@return nil, retorno nulo
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrG6U)

If ValType(oStrG6U) == "O"
    oStrG6U:SetProperty('G6U_TPVIGE',MVC_VIEW_COMBOBOX,GetComboBox('G6U_TPVIGE'))
    oStrG6U:SetProperty('G6U_TPTOLE',MVC_VIEW_COMBOBOX,GetComboBox('G6U_TPTOLE'))
    oStrG6U:SetProperty('G6U_MSBLQL',MVC_VIEW_COMBOBOX,GetComboBox('G6U_MSBLQL'))

    // Combo dinamico para o campo de amarracao GYG
    If G6U->(FieldPos('G6U_RELGYG')) > 0
        oStrG6U:SetProperty('G6U_RELGYG', MVC_VIEW_COMBOBOX, GetComboBox('G6U_RELGYG'))
    EndIf
    If G6U->(FieldPos('G6U_DATGYG')) > 0
        oStrG6U:SetProperty('G6U_DATGYG', MVC_VIEW_COMBOBOX, GetComboBox('G6U_DATGYG'))
    EndIf

    // Grupo 1 - Identificacao do tipo de documento
    oStrG6U:AddGroup('GRP001', '','', 2)
    oStrG6U:SetProperty( 'G6U_CODIGO', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    oStrG6U:SetProperty( 'G6U_DESCRI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    oStrG6U:SetProperty( 'G6U_TRECUR', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    oStrG6U:SetProperty( 'G6U_MSBLQL', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    If G6U->(FieldPos('G6U_RELGYG')) > 0
        oStrG6U:SetProperty( 'G6U_RELGYG', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    EndIf
    If G6U->(FieldPos('G6U_DATGYG')) > 0
        oStrG6U:SetProperty( 'G6U_DATGYG', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    EndIf

    // Grupo 2 - Vigencia / Tolerancia
    oStrG6U:AddGroup('GRP002', STR0010,'', 2) // "Vigencia/Tolerancia"
    oStrG6U:SetProperty( 'G6U_TPVIGE', MVC_VIEW_GROUP_NUMBER, 'GRP002')
    oStrG6U:SetProperty( 'G6U_TEMPVI', MVC_VIEW_GROUP_NUMBER, 'GRP002')
    oStrG6U:SetProperty( 'G6U_TPTOLE', MVC_VIEW_GROUP_NUMBER, 'GRP002')
    oStrG6U:SetProperty( 'G6U_TEMPTO', MVC_VIEW_GROUP_NUMBER, 'GRP002')

Endif

Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetComboBox
Função Responsavel para retornar o array contendo os valores do ComboBox
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param cField, character, Campo a ser verificado para carregar o combobox
@return aRetCBox, array contendo os valores do ComboBox
/*/
//------------------------------------------------------------------------------
Static Function GetComboBox(cField)
Local aRetCBox   := {}
Do Case
    Case cField == "G6U_TPVIGE"
        aadd(aRetCBox, STR0011) // "1=Dia"
        aadd(aRetCBox, STR0012) // "2=Mes"
        aadd(aRetCBox, STR0013) // "3=Ano"
        aadd(aRetCBox, STR0014) // "4=Indeterminado"
    Case cField == "G6U_TPTOLE"
        aadd(aRetCBox, STR0015) // "5=Não Possui"
    Case cField == 'G6U_MSBLQL'
        aadd(aRetCBox, "1="+STR0002) // Inativo
        aadd(aRetCBox, "2="+STR0003) // Ativo
    Case cField == 'G6U_RELGYG'
        aRetCBox := GYGCombo({"C"})//Vai listar somente os campos caracter
    Case cField == 'G6U_DATGYG'
        aRetCBox := GYGCombo({"D"})//Vai listar somente os campos do tipo data
EndCase

Return aRetCBox
