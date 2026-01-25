#Include "loca229d.ch"
#Include "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} MENUDEF
Menu dos Itens do Romaneio
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Array com as opçoes do menu
/*/
STATIC FUNCTION MENUDEF()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0001   ACTION 'VIEWDEF.LOCA229D' OPERATION MODEL_OPERATION_VIEW ACCESS 0  //'Visualizar'
ADD OPTION aRotina TITLE STR0002   ACTION 'VIEWDEF.LOCA229D' OPERATION MODEL_OPERATION_UPDATE ACCESS 0  //'Alterar'
ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.LOCA229D' OPERATION MODEL_OPERATION_DELETE ACCESS 0  //"Desvincular"

Return aRotina

/*/{Protheus.doc} MODELDEF
Definicão do modelo de Edição do iTem do romaneio
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Modelo de Cabeçalho de Demanda
/*/
STATIC FUNCTION MODELDEF()
Local oStruFQV := FWFormStruct( 1, 'FQV', /*bAvalCampo*/,/*lViewUsado*/ )

oModel := MPFormModel():New( 'LOCA229D', /*bPreValidacao*/, /*bPosValidacao*/, {|oModel| CommitMdl(oModel)} /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQVMASTER', /*cOwner*/, oStruFQV, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0004 )  //"Item Romaneio Expedicao"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FQVMASTER' ):SetDescription(STR0004)  //"Item Romaneio Expedicao"

// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActive( { | oModel | Loca229DAC( oModel ) })

Return oModel


/*/{Protheus.doc} ViewDef
Define a View da Demanda
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, Retorna a view da demanda
/*///-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA229D' )
Local oStruFQV := FWFormStruct( 2, 'FQV', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQV', oStruFQV, 'FQVMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQV', 'TELA' )
oView:SetCloseOnOk({|| .T.})

Return oView

/*/{Protheus.doc} Loca229DAC
Validação para varifica se podemos realizar as operações sobre o model
@type function
@version 25.10 
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model do ITem do Romaneio
@return variant, .T. se a operação puder ser realizada
/*/
Function Loca229DAC( oModel )
Local lRet := .T.
Local nOpc:=oModel:GetOperation()

if nOpc <> MODEL_OPERATION_VIEW


    if nOpc == MODEL_OPERATION_DELETE .or. nOpc == MODEL_OPERATION_UPDATE
        if !Empty(FQV->FQV_PEDIDO)
            Help(" ",1,"LOCA229D_02",, STR0005,1,0)  //"Operação invalida! O item já tem pedido de venda gerado."
    	    lRet := .F.//
        elseif nOpc == MODEL_OPERATION_DELETE .and. FQU->FQU_FCHEMB = '1'
            Help(" ",1,"LOCA229D_03",, STR0007,1,0)   //"Operação invalida! O romaneio já teve o Embarque Fechado."
    	    lRet := .F.//
        endif

    else
        Help(" ",1,"LOCA229D_01",, STR0006,1,0)  //"Operação invalida para esse Model, só usar Alteração ou Exclusão"
	    lRet := .F.
    endif
endif
return lRet

/*/{Protheus.doc} CommitMdl
Commit do modelo de dados
@type function
@version 25.10 
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model a ser comitado
@return variant, REtorno o Suceeso ou Fracasso do Commit
/*/
Static Function CommitMdl(oModel)
Local lRet := .T.

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		lRet := FwFormCommit(oModel,,,{|oModel| Loca229DTS(oModel)})
    else
       lRet := FwFormCommit(oModel)
	EndIf
Return lRet

/*/{Protheus.doc} Loca229DTS
Função a ser executa dento da Transação do Commit
@type function
@version 25.10
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model que esta sendo comitado
@return variant, Sucesso
/*/
Static Function Loca229DTS(oModel)
Local cRomaneio := oModel:GetModel("FQVMASTER"):GetValue("FQV_NUM")
Local aArea := GetArea()
Local cQuery := "" 
Local aBindParam := {}
Local nSep := 0
Local nOut := 0
Local cStatus := ''

If oModel:GetOperation() = MODEL_OPERATION_DELETE // Só atualizar a FQU na Deleção

    // Ajustar a FQ5 liberando o item do Romaneio
    dbSelectArea("FQ5")
    dbSetOrder(9) // Por AS
    dbSeek(xFilial("FQ5")+FQV->FQV_AS)
    RecLock("FQ5",.F.)
    FQ5->FQ5_XROMAN := " "
    MsUnlock()

    // Verificar se o Romaneio está vazio
    cQuery += "SELECT FQ5_STATUS"
    cQuery += " FROM "+RetSqlName("FQ5")
    cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'"
    cQuery += " AND FQ5_XROMAN =  ?"
    Aadd(aBindParam, cRomaneio)
    cQuery += " AND D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,"FQ5TRB",,,aBindParam)

    if (FQ5TRB->(EOF())) // Romaneio Vazio
        cStatus  := '1'
    else 
        cQuery := ''
        aBindParam := {}
        cQuery += "SELECT FQ5_STATUS, Count(*) QTD"
        cQuery += " FROM "+RetSqlName("FQ5")
        cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'"
        cQuery += " AND FQ5_XROMAN =  ?"
        Aadd(aBindParam, cRomaneio)
        cQuery += " AND D_E_L_E_T_ = ' '"
        cQuery += " GROUP BY FQ5_STATUS"

        cQuery := ChangeQuery(cQuery)
        MPSysOpenQuery(cQuery,"FQ5TRB",,,aBindParam)

        
        while !FQ5TRB->(EOF())
		    if FQ5TRB->FQ5_STATUS = '6'
			    nSep := FQ5TRB->QTD 
	    	else
		    	nOut += FQ5TRB->QTD
		    endif
		    FQ5TRB->(dbSkip())
    	enddo

	    if nSep > 0 .and. nOut = 0
            cStatus := '3'
        else
            cStatus := '2'
        endif    
    endif

endif

RecLock("FQU",.F.)
FQU->FQU_STATUS := cStatus
MsUnlock() 

oBrowseUp:Refresh()

RestArea(aArea)

Return .T. 
