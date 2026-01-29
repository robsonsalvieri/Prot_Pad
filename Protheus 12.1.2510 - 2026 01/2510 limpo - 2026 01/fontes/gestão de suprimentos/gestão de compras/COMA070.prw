#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "COMA070.CH"

PUBLISH MODEL REST NAME COMA070 SOURCE COMA070

//-------------------------------------------------------------------
/*/{Protheus.doc} COMA070()
Cadastro de contatos x fornecedores

Inicialmente utilizado no Novo Fluxo de Compras

@author Leandro Fini
@since 04/2024
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Leandro Fini
@since 04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   

Local aRotina := {}

ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.COMA070' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.COMA070' OPERATION 4 ACCESS 0 //Manutenção
ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.COMA070' OPERATION 8 ACCESS 0 //Imprimir

Return(aRotina) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Estrutura do Modelo de Dados

@author Leandro Fini
@since 04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef() 

Local oStrSA2     := FWFormStruct( 1, 'SA2' )
Local oStrDKI     := FWFormStruct( 1, 'DKI' )
Local oModel      := Nil
Local bLinPreDKI  := { |oModelGrid, nLine, cAction, cField, xValue, xOldValue| PreVldDKI(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }

oModel := MPFormModel():New('COMA070',/*bPreVld*/, /*bPosVld*/,{|oModel| COMA070Cmt(oModel)}) 

oModel:AddFields( 'SA2MASTER', /*cOwner*/ , oStrSA2) 
oModel:AddGrid  ( 'DKIDETAIL', 'SA2MASTER', oStrDKI, bLinPreDKI,,,, )
oModel:SetRelation('DKIDETAIL', { { 'DKI_FILIAL', 'FWxFilial("SA2")' }, { 'DKI_FORNEC', 'A2_COD' }, { 'DKI_LOJA', 'A2_LOJA' } }, DKI->(IndexKey(1)) )

oModel:SetDescription(STR0001)// 'Contatos x Fornecedor' 
oModel:GetModel( 'SA2MASTER' ):SetDescription(STR0002)// "Fornecedor" 
oModel:GetModel( 'DKIDETAIL' ):SetDescription(STR0003)// "Contatos" 

oModel:GetModel('DKIDETAIL'):SetOptional(.T.)

oStrSA2:SetProperty('A2_EMAIL', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "COM070Email('SA2', M->A2_EMAIL)"))

oModel:SetVldActivate( {|| .T. } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Estrutura de Visualização

@author Leandro Fini
@since 04/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef() 

Local oModel 	:= FWLoadModel('COMA070')
Local oStrSA2 	:= FWFormStruct( 2, 'SA2', {|cCampo| AllTrim(cCampo)$ "A2_COD|A2_LOJA|A2_NOME|A2_EMAIL|A2_DDD|A2_TEL"} )  
Local cCpoExcl	:= "DKI_FILIAL|DKI_FORNEC|DKI_LOJA" // -- Campos da DKI que deverão ser ocultados da view
Local oStrDKI 	:= nil
Private oView := Nil

oStrDKI := FWFormStruct( 2, 'DKI' , {|cCampo| !AllTrim(cCampo)$ cCpoExcl} )

oStrSA2:SetProperty("*"       ,MVC_VIEW_CANCHANGE, .F.)
oStrSA2:SetProperty("A2_EMAIL",MVC_VIEW_CANCHANGE, .T.)
oStrSA2:SetProperty("A2_DDD"  ,MVC_VIEW_CANCHANGE, .T.)
oStrSA2:SetProperty("A2_TEL"  ,MVC_VIEW_CANCHANGE, .T.)

oView:= FWFormView():New() 

oView:SetModel( oModel )

oStrSA2:SetNoFolder()

oView:AddField( 'VIEW_SA2' , oStrSA2, 'SA2MASTER' ) 
oView:AddGrid ( 'VIEW_DKI' , oStrDKI, 'DKIDETAIL' )  

oView:AddIncrementField('VIEW_DKI' , 'DKI_ITEM' )

oView:CreateHorizontalBox	( 'SUPERIOR'   , 020 )   
oView:CreateHorizontalBox	( 'INFERIOR1'  , 080 )

oView:SetOwnerView( 'VIEW_SA2', 'SUPERIOR'	)
oView:SetOwnerView( 'VIEW_DKI', 'INFERIOR1'	)    

oView:EnableTitleView('VIEW_DKI','Contatos'	)

oView:SetUpdateMessage('',STR0004)//"Contato(s) salvo(s) com sucesso."

Return oView

/*/{Protheus.doc} COMA070Cmt
	Bloco de commit
@author Leandro Fini
@since 04/2024
/*/
Static Function COMA070Cmt(oModel)

lRet := FwFormCommit( oModel )

If lRet //-- Envia informações do fornecedor para atualização da tela do PO-UI
	PG010Saved(.T.)
EndIf

Return lRet

/*/{Protheus.doc} COMA070A
	Execview de vinculo de contato x fornecedor.
	Chamado no botão outras ações no cadastro de fornecedores.
@author Leandro Fini
@since 04/2024
/*/
Function COMA070A()

Local aButtons     := { {.F., Nil},;            //- Copiar
                        {.F., Nil},;            //- Recortar
                        {.F., Nil},;            //- Colar
                        {.t., Nil},;            //- Calculadora
                        {.t., Nil},;            //- Spool
                        {.t., Nil},;            //- Imprimir
                        {.t., STR0005},;        //- "Confirmar"
                        {.t., STR0006},;        //- "Cancelar"
                        {.t., Nil},;            //- WalkThrough
                        {.F., Nil},;            //- Ambiente
                        {.t., Nil},;            //- Mashup
                        {.t., Nil},;            //- Help
                        {.F., Nil},;            //- Formulário HTML
                        {.F., Nil},;            // - ECM
                        {.f., nil}}             // - Desabilitar o botão Salvar e Criar Novo

	FWMsgRun(, {|| FWExecView (STR0001, "COMA070", MODEL_OPERATION_UPDATE, , , , , aButtons) }, STR0007, STR0008) //-- Aguarde... | Carregando...

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PreVldDKI
    Pré-valid do grid de Contatos x Fornecedores (DKI).
@author juan.felipe
@since 14/05/2024
@version 1.0
@return lRet, logical, fornecedor válido.
/*/
//-------------------------------------------------------------------
Static Function PreVldDKI(oModelDKI, nLine, cAction, cField, xValue, xOldValue)
    Local lRet   := .T.
    Local oModel := oModelDKI:GetModel()

    DO CASE
        CASE cAction == 'SETVALUE' .And. cField == "DKI_EMAIL" //-- Valida campo de e-mail
            lRet := COM070Email('DKI', xValue, oModel)
    END CASE
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COM070Email
    Valida campo e-mail.
@author juan.felipe
@since 15/05/2024
@version 1.0
@return lRet, logical, e-mail válido.
/*/
//-------------------------------------------------------------------
Function COM070Email(cTable, cEmail, oModel)
    Local lRet       := .T.
    Local lDKI       := .F.
    Local nX         := 0
    Local aSaveLines := {}
    Local cMessage   := ''
    Local cSolution  := ''
    Local oModelDKI  := Nil
    Default cTable   := ''
    Default cEmail   := ''
    Default oModel   := FwModelActive()

    lDKI := cTable == 'DKI'

    If !Empty(cEmail)
        If !NFCVldEmail(cEmail, @cMessage, @cSolution, lDKI)
            oModel:SetErrorMessage(,,,, 'COM070EMAIL1', cMessage, cSolution)
            lRet := .F.
        EndIf

        If lRet .And. lDKI
            oModelDKI := oModel:GetModel('DKIDETAIL')

            If oModelDKI:Length() > 1
                aSaveLines	:= FWSaveRows()

                For nX := 1 To oModelDKI:Length()
                    oModelDKI:GoLine(nX)

                    If AllTrim(oModelDKI:GetValue('DKI_EMAIL')) == AllTrim(cEmail)
                        oModel:SetErrorMessage(,,,, 'COM070EMAIL2', STR0012, STR0013) //-- Não é permitido inserir e-mails duplicados. Digite outro e-mail.
                        lRet := .F.
                    EndIf
                Next nX

                FWRestRows(aSaveLines)
            EndIf

        EndIf
    EndIf

    FwFreeArray(aSaveLines)
Return lRet
