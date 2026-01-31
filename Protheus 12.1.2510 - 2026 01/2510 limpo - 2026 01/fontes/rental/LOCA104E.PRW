#Include "LOCA104E.CH"
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

ADD OPTION aRotina TITLE STR0001   ACTION 'VIEWDEF.LOCA104E' OPERATION MODEL_OPERATION_VIEW ACCESS 0  // //'Visualizar'
ADD OPTION aRotina TITLE STR0002  ACTION 'VIEWDEF.LOCA104E' OPERATION MODEL_OPERATION_DELETE ACCESS 0  // //"Desvincular"

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
Local oStruFQX := FWFormStruct( 1, 'FQX', /*bAvalCampo*/,/*lViewUsado*/ )

oModel := MPFormModel():New( 'LOCA104E', /*bPreValidacao*/, /*bPosValidacao*/, {|oModel| CommitMdl(oModel)} /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FQXMASTER', /*cOwner*/, oStruFQX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0003 )  //"Item Romaneio Expedicao" //"Item Romaneio de Devolucao"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FQXMASTER' ):SetDescription(STR0004)  //"Item Romaneio Expedicao" //"Item Romaneio de Devolução"

// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActive( { | oModel | LOCA104EAC( oModel ) })

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
Local oModel   := FWLoadModel( 'LOCA104E' )
Local oStruFQX := FWFormStruct( 2, 'FQX', /*bAvalCampo*/,/*lViewUsado*/ )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQX', oStruFQX, 'FQXMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQX', 'TELA' )
oView:SetCloseOnOk({|| .T.})

Return oView

/*/{Protheus.doc} LOCA104EAC
Validação para varifica se podemos realizar as operações sobre o model
@type function
@version 25.10 
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model do ITem do Romaneio
@return variant, .T. se a operação puder ser realizada
/*/
Function LOCA104EAC( oModel )
Local lRet := .T.
Local nOpc:=oModel:GetOperation()

if nOpc <> MODEL_OPERATION_VIEW

    if nOpc == MODEL_OPERATION_DELETE
        if !Empty(FQX->FQX_NFRET)
            Help(" ",1,"LOCA104E_02",, STR0005,1,0)  // //"Operação invalida! O item já tem documento de entrada gerado."
    	    lRet := .F.
        endif
    else
        Help(" ",1,"LOCA104E_01",, STR0006,1,0)  // //"Operação invalida para esse Model, só usar Exclusão"
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
		lRet := FwFormCommit(oModel,,,{|oModel| Loca104ETS(oModel)})
	EndIf
    
Return lRet

/*/{Protheus.doc} Loca104ETS
Função a ser executa dento da Transação do Commit
@type function
@version 25.10
@author Alexandre Circenis
@since 5/6/2025
@param oModel, object, Model que esta sendo comitado
@return variant, Sucesso
/*/
Static Function Loca104ETS(oModel)
Local cRomaneio := oModel:GetModel("FQXMASTER"):GetValue("FQX_NUM")
Local aArea := GetArea()
Local cQuery := "" 
Local aBindParam := {}
Local cStatus := '1'

If oModel:GetOperation() = MODEL_OPERATION_DELETE // Só atualizar a FQU na Deleção

    // Verificar se o Romaneio está vazio
    cQuery += "SELECT FQX_STATUS"
    cQuery += " FROM "+RetSqlName("FQX")
    cQuery += " WHERE FQX_FILIAL = '"+xFilial("FQX")+"'"
    cQuery += " AND FQX_NUM =  ?"
    Aadd(aBindParam, cRomaneio)
    cQuery += " AND D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,"FQXTRB",,,aBindParam)

    if (FQXTRB->(EOF())) // Romaneio Vazio
        cStatus  := '1'
    else 
        cQuery := ''
        aBindParam := {}
        cQuery += "SELECT FQX_STATUS, Count(*) QTD"
        cQuery += " FROM "+RetSqlName("FQX")
        cQuery += " WHERE FQX_FILIAL = '"+xFilial("FQX")+"'"
        cQuery += " AND FQX_NUM =  ?"
        Aadd(aBindParam, cRomaneio)
        cQuery += " AND D_E_L_E_T_ = ' '"
        cQuery += " GROUP BY FQX_STATUS"

        cQuery := ChangeQuery(cQuery)
        MPSysOpenQuery(cQuery,"FQXTRB",,,aBindParam)

        
        while !FQXTRB->(EOF())
            if FQXTRB->FQX_STATUS = '4'
			    cStatus := '4' // Há Divergencia entre primeira contagem e segunda contagem
                exit
            elseif FQXTRB->FQX_STATUS = '3'
	            cStatus := '3'
	    	elseif FQXTRB->FQX_STATUS = '2' // Tem itens só com primeira contagem
		    	cStatus := '2'
            endif
		    FQXTRB->(dbSkip())
    	enddo

    endif

endif

RecLock("FQW",.F.)
FQW->FQW_STATUS := cStatus
if cStatus = '1'
    FQW->FQW_FILREM := ''
endif
MsUnlock() 

oBrowseUp:Refresh()

RestArea(aArea)

Return .T. 
