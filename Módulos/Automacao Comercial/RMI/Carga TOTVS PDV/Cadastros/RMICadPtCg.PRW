#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RMICADPTCG.CH'

/*/{Protheus.doc} RMICadPtCg
Cadastro de Ponto de Integração
@author joao.marcos
@since 21/02/2024
@version V12
/*/
Function RMICadPtCg()
Local oBrowse

Private aRotina := MenuDef()

If FWModeAccess("MIQ",1) == "C" .AND. FWModeAccess("MIQ",2) == "C" .And. FWModeAccess("MIQ",3) == "C"
    If AmIIn(12) // Acesso apenas para modulo e licença do Varejo

        oBrowse := FWmBrowse():New()
        oBrowse:SetAlias( "MIQ" )
        oBrowse:SetDescription( STR0003 ) // "Ponto de Integração"

        // Legenda
        oBrowse:AddLegend( "AllTrim(MIQ->MIQ_ATIVO) == '1'", "GREEN", STR0001, "1" ) // "Ponto de Integração Ativo"
        oBrowse:AddLegend( "AllTrim(MIQ->MIQ_ATIVO) == '2'", "RED",   STR0002, "1" )    // "Ponto de Integração não Ativo"

        oBrowse:Activate()
    Else
        MsgAlert(STR0004) // "Esta rotina só pode ser utilizada pelo módulo Controle de Lojas (SIGALOJA)"        
    EndIf
Else
    MSgAlert(STR0005) // "A Empres, Unidade de Negócio e Filial da tabela MIQ devem estar em modo compartilhado"
EndIf

Return NIL

/*/{Protheus.doc} MenuDef
Menu
@type  Static Function
@author joao.marcos
@since 21/02/2024
@version V12
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title "Visualizar"  Action "VIEWDEF.RMICadPtCg" OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"     Action "VIEWDEF.RMICadPtCg" OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"     Action "VIEWDEF.RMICadPtCg" OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"     Action "VIEWDEF.RMICadPtCg" OPERATION 5 ACCESS 0
ADD OPTION aRotina Title "Copiar"      Action "VIEWDEF.RMICadPtCg" OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} ViewDef
Estrutura a View da Tela
@type  Static Function
@author joao.marcos
@since 21/02/2024
@version V12
/*/
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( "RMICadPtCg" )
Local oView
Local oStruMIQ := FWFormStruct( 2, "MIQ" )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "VIEW_MIQ", oStruMIQ, "MIQMASTER" )
oView:CreateHorizontalBox( "GRUPO", 30 )
oView:CreateHorizontalBox( "TABELAS", 70 )
oView:SetOwnerView( "VIEW_MIQ", "GRUPO" )

oStruMIQ:RemoveField('MIQ_FILIAL')

Return oView

/*/{Protheus.doc} ModelDef
Estrutura o Model
@type  Static Function
@author joao.marcos
@since 21/02/2024
@version V12
/*/
Static Function ModelDef()
Local oStruMIQ  := FWFormStruct( 1, "MIQ", /*bAvalCampo*/, /*lViewUsado*/ )
Local bPosValid := {|| RMIVldPtCg() }
Local oModel    :=  MPFormModel():New( "RMICadPtCg_M", /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ ) 

oModel:SetDescription( STR0003 ) // "Ponto de Integração"
oModel:AddFields( "MIQMASTER", /*cOwner*/, oStruMIQ )
oModel:SetPrimaryKey({"MIQ_FILIAL", "MIQ_COD"})
oStruMIQ:SetProperty( "MIQ_EMPPC"   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."))
oStruMIQ:SetProperty( "MIQ_EMPPC"   , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, "FWGrpCompany()"))
oStruMIQ:SetProperty('MIQ_FILPC'    ,MODEL_FIELD_VALID, {|| ValidFilPc(oModel)} )

oModel:GetModel( 'MIQMASTER' ):SetDescription( STR0003 ) // 'Ponto de Integração'

Return oModel

/*/{Protheus.doc} RMIVldPtCg
Valida os dados digitados
@type  Function
@author joao.marcos
@since 21/02/2024
@version V12
@return lRet, logico, permite ou nao a inclusao
/*/
Function RMIVldPtCg()
Local lRet          := .T.
Local oModel        := FWModelActive()
Local nOperation    := oModel:GetOperation()    // Operaçao em andamento (Inclusão/Alteracçao/Exclusao)
Local cCodPC        := oModel:GetValue("MIQMASTER","MIQ_COD")
Local cGrupoPC      := oModel:GetValue("MIQMASTER","MIQ_EMPPC")
Local cFilialPC     := oModel:GetValue("MIQMASTER","MIQ_FILPC")

If nOperation == MODEL_OPERATION_INSERT .OR. ( nOperation == MODEL_OPERATION_UPDATE .AND. ( AllTrim(oModel:GetValue("MIQMASTER","MIQ_COD")) <> AllTrim(MIQ->MIQ_COD) ) )

    If MIQ->(dbSeek(xFilial("MIQ") + PadR(cCodPC,TamSx3("MIQ_COD")[1]) + PadR(cGrupoPC,TamSx3("MIQ_EMPPC")[1]) + PadR(cFilialPC,TamSx3("MIQ_FILPC")[1])))
        lRet := .F.
        MsgAlert(STR0006) // "Codigo de Ponto de Integração já existe para esta Empresa e Filial."
    EndIf

EndIf
    
Return lRet

/*/{Protheus.doc} ValidFilPc
Valida a Filial Digitada no campo MIQ_FILPC
@type  Function
@author joao.marcos
@since 13/03/2024
@version 1.0
@return lRet, logico, retorno da validaçao
/*/
Function ValidFilPc(oModel)
Local lRet          := .F.
Local aFiliais      := FWAllFilial(,,cEmpAnt,.F.)   // Filiais do ambiente
Local cFilCarDig    := ""
Local nY            := 0

cFilCarDig := oModel:GetValue("MIQMASTER","MIQ_FILPC")

For nY := 1 To Len(aFiliais)
    If AllTrim(cFilCarDig) == AllTrim(aFiliais[nY])
        lRet := .T.
        Exit
    EndIf
Next

If !lRet
    MSGAlert(STR0007) // "Filial informada para o Ponto de Integração está incorreta."
EndIf

return lRet
