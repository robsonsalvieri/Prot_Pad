#Include "loca229k.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} MODELDEF
Definicão do modelo para Rotina Automatica de Romaneio
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo de Demanda
/*/
STATIC FUNCTION MODELDEF()
Local oModel := FwLoadModel("LOCA229A")
Local oStruFQV := FWFormStruct( 1, 'FQV', /*bAvalCampo*/,/*lViewUsado*/ )

//oModel := MPFormModel():New( 'LOCA259K', /*bPreValidacao*/, {|oMod| LOCA229KTO(oMod)},{|oMod| LOCA229KGR(oMod)}, /*bCancel*/ )
oModel:bPost :=  {|oMod| LOCA229KTO(oMod)}
oModel:bCommit := {|oMod| LOCA229KGR(oMod)} 
oSTruFQV:SetProperty("FQV_AS",MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'LOCA229KAS()'))

// Adiciona ao modelo uma estrutura de formulário de edição por Grid
oModel:AddGrid( 'GRID', "FQUMASTER", oStruFQV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:GetModel( 'GRID' ):SetDescription(STR0001) //'Demanda' //"Itens do Romaneio" //"ITENS DO ROMANEIO"
//Setando a chave primária da rotina
oModel:SetRelation( 'GRID', { { 'FQV_FILIAL', 'xFilial("FQV")' } ,{"FQV_NUM","FQU_NUM"}}, FQV->( IndexKey( 1 ) ) )
    
oModel:SetOnlyQuery("GRID", .T.)
oModel:GetModel( 'GRID' ):SetUniqueLine({"FQV_AS"})
oModel:GetModel( 'GRID' ):SetMaxLine(9000)

Return oModel

/*/{Protheus.doc} ViewDef
Define a View da rotina automatica do Romaneio
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA229K' )
Local oStruFQV := FWFormStruct( 2, 'FQV', /*bAvalCampo*/,/*lViewUsado*/ )
Local oViewPad := FwLoadView("LOCA229A")
Local oStruFQU  := oViewPad:GetViewStruct("VIEW_FQU")

oStruFQV:SetProperty("FQV_AS", MVC_VIEW_CANCHANGE, .T.)
//oStruFQU:RemoveField("FQU_STATUS")
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQU', oStruFQU, 'FQUMASTER' )
// Adiciona a Grid de itens do Romaneio
oView:AddGrid( 'VIEW_FQV', oStruFQV, 'GRID' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABEC' , 50 )
oView:CreateHorizontalBox( 'ITENS' , 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQU', 'CABEC' )
oView:SetOwnerView( 'VIEW_FQV', 'ITENS' )

Return oView

/*/{Protheus.doc} LOCA229KAS
Valida o codigo da AS informada
@type function
@version 25.10
@author Alexandre Circenis
@since 22/07/2026
@return variant, Retorna .T. se o codigo for valido
/*/
FUNCTION LOCA229KAS()
Local lRet := .T.
Local aArea := {GetArea()}
Local oModel   := FWModelActive()
Local nX

    FQ5->(dbSetOrder(9))
    if !FQ5->(dbSeek(xFilial("FQ5")+M->FQV_AS))
        oModel:SetErrorMessage("","","","","LOCA229K_01",STR0002,)  //"A.S. não encontrada, confira os itens do contrato."
	    lRet := .F.
    elseif FQ5->(FQ5_SOT+FQ5_OBRA) <> M->FQU_PROJET+M->FQU_OBRA
        oModel:SetErrorMessage("","","","","LOCA229K_02",STR0003,)  //"A.S. informada inválida, não está definida para o projeto e obra informados."
	    lRet := .F.
    elseif Empty(FQ5->FQ5_DEMAND)
        oModel:SetErrorMessage("","","","","LOCA229K_03",STR0004,)  //"A.S. informada não se encontra em uma demanda."
	    lRet := .F.
    else
        Aadd(aArea, FPA->(GetArea()))
        FPA->(dbSetOrder(2))
        FPA->(dbSeek(xFilial("FPA")+M->FQU_PROJET+M->FQU_OBRA+FQ5->FQ5_AS))
        if !Empty(FPA->FPA_NFREM) 
            oModel:SetErrorMessage("","","","","LOCA229K_04",STR0005,)  //"A.S. informada já tem nota de remessa."
	        lRet := .F.
        endif

        if lRet 
            Aadd(aArea, FQ3->(GetArea()))
            FQ3->(dbSetOrder(3))
            if FQ3->(dbSeek(xFilial("FQ3")+FQ5->FQ5_AS))
                oModel:SetErrorMessage("","","","","LOCA229K_05",STR0006,)  //"A.S. informada já foi informada no romaneio antigo."
	            lRet := .F.
            endif
        endif
    endif

    for nX := Len(aArea) to 1 step -1
        RestArea(aArea[nX])
    next

Return lRet
/*/{Protheus.doc} LOCA229KGR
Grava os dados que não estão no model 
@type function
@version 25.10
@author Alexandre Circenis
@since 22/07/2026
@param oModel, object, Objeto model que será gravado
@return variant, Se ca gravação for bem sucessida retorna .T.
/*/
Static Function LOCA229KGR(oModel)
Local lRet          := .T.
Local oGrid         := oModel:GetModel("GRID")
Local oMaster       := oModel:GetModel("FQUMASTER")
Local cRomaneio     := oMaster:GetValue("FQU_NUM")
Local nX            := 0
Local cItem         := CriaVar("FQV_ITEM")
Local nIncluidas    := 0
Local cStatus       := '3' // Iniciar o Status como Separado

if oModel:VldData()

    Begin TRANSACTION 
        // 1. Gravação padrão da tabela Master (FQT) usando o comando interno do MVC

        lRet := FWFormCommit(oModel)

        if lRet

            For nX := 1 to oGrid:Length()

                oGrid:GoLine(nX)
                
                // Ignora linhas deletadas visualmente pelo usuário se houver
                If oGrid:IsDeleted()
                    Loop
                EndIf

                FQ5->(dbSetOrder(9))
                FQ5->(dbSeek(xFilial("FQ5")+oGrid:GetValue("FQV_AS")))
                RecLock("FQ5",.F.)
                FQ5->FQ5_XROMAN := cRomaneio
                FQ5->(msUnLock())

                // Incluir o item marcado no Romaneio
                dbSelectArea("ST9")
                cItem := Soma1(cItem)
                RecLock("FQV", .T.)
                FQV->FQV_FILIAL := xFilial("FQV")
                FQV->FQV_NUM    := cRomaneio
                FQV->FQV_ITEM   := cItem
                FQV->FQV_PROD   := FQ5->FQ5_XPROD
                FQV->FQV_QTD    := FQ5->FQ5_XQTD
                FQV->FQV_CODBEM := FQ5->FQ5_GUINDA
                FQV->FQV_FAMBEM := Posicione("ST9",1,xFilial("ST9")+FQ5->FQ5_GUINDA, "T9_CODFAMI")
                FQV->FQV_AS     := FQ5->FQ5_AS
                FQV->FQV_STATUS := FQ5->FQ5_STATUS
                msUnLock()

                nIncluidas++

                // Se tiver FH2 passar para o romaneio
                dbSelectArea("FH2")
                dbSetOrder(1)
                if dbSeek(xFilial("FH2")+FQ5->FQ5_AS)
                    while !Eof() .and. FH2->(FH2_FILIAL+FH2_AS) = xFilial("FH2")+FQ5->FQ5_AS
                        RecLock("FH2", .F.)
                        FH2->FH2_ROMREM := cRomaneio
                        msUnLock()
                        dbSkip()
                    enddo
                endif

                if FQ5->FQ5_STATUS 	<> '6' // Não está separado
                    cStatus := '2' // Colocaremos o Romaneio como em Separação
                endif
            
            next

            if nIncluidas > 0
                RecLock("FQU", .F.)
                FQU->FQU_STATUS := cStatus
                MsUnlock()
            endif           
        endif

    END TRANSACTION

endif

Return lRet

/*/{Protheus.doc} LOCA229KTO
Validação de "tudo Ok" do model
@type function
@version 25.10
@author Alexandre Circenis
@since 22/07/2026
@param oModel, object, Objeto model que será avaliado pela função
@return variant, Retorna .t. se o model estivar valido
/*/
Function LOCA229KTO(oModel)
Local lRet         := .T.

Return lRet

/*/
**** Exemplo para testar a rotina automatica

Function ExeLoca229()
Local oModel := FWLoadModel("LOCA229K") // Ex: MATA020, MATA010
Local aErros := {}
Local cRet := ''
    
    // Define a operação (ex: Inclusão)
    oModel:SetOperation(MODEL_OPERATION_INSERT) // MODEL_OPERATION_UPDATE para alterar
    
    // Ativa o model para iniciar a carga de dados
    oModel:Activate()
    
    // Preenche o Master (Cabeçalho)
    oModel:SetValue("FQUMASTER", "FQU_PROJET", "202600339")
    oModel:SetValue("FQUMASTER", "FQU_OBRA", "001")
    oModel:SetValue("FQUMASTER", "FQU_ASF" , "3100339001001D MG 01")
    
    // Se a rotina tiver itens, preenche o Detail

    oModel:SetValue("GRID", "FQV_AS", "3000339001009D MG 01       ")

    // Executa a validação e gravação
    If oModel:VldData()
        oModel:CommitData()
        cRet += "Registro gravado com sucesso!"
    Else
        // A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior
        aErros := oModel:GetErrorMessage()
        if !Empty(aErros[4]) .or. !Empty(aErros[8]) // Erro em um campo
            cRet += "Campo: " + aErros[4]+" Valor: "+aErros[8]
        endif
        cRet += "erro "+aErros[5]+" - "+aErros[6]

    EndIf
    
    oModel:Destroy()
    
Return cRet
/*/
