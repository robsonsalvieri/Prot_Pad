#Include "RU34S10B.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

/* START MODEL F61 */
STATIC aUserGroups

PUBLISH MODEL REST NAME RU34S10B RESOURCE OBJECT oModelF61

//FUNCTION RU34S10()
     //FWCALLAPP('RU34S10',/*@oMainDlg*/)
//Return
function RU34S10B()
	Local aArea := F61->(GetArea())

       /*Declarando as vari?veis que ser?o utilizadas*/
	Private oBrowse
	Private cChaveAux := ""

        //Iniciamos a constru??o b?sica de um Browse.
	oBrowse := FWMBrowse():New()

        //Definimos a tabela que ser? exibida na Browse utilizando o m?todo SetAlias
	oBrowse:SetAlias("F61")

        //Definimos o t?tulo que ser? exibido como m?todo SetDescription
	oBrowse:SetDescription('')
	
        //Ativamos a classe
	oBrowse:Activate()
        RestArea(aArea)
Return


//-------------------------------------------------------------------
// Montar o menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0001  	ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0002 	ACTION "VIEWDEF.RU34S10B" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003    	ACTION "VIEWDEF.RU34S10B" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004    	ACTION "VIEWDEF.RU34S10B" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005    	ACTION "VIEWDEF.RU34S10B" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.RU34S10B" OPERATION 8 ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE STR0007 		ACTION "VIEWDEF.RU34S10B" OPERATION 9 ACCESS 0 //"Copiar"
Return aRotina



Class oModelF61 From FwRestModel
//DATA CORDER as string
Method Activate()

EndClass
Method Activate() Class oModelF61
local lRet as logical
Local cIn as Character
Local cFixedFilter as Character
Local nX
If aUserGroups == Nil
    aUserGroups  := UsrRetGrp(,__cUserID)
Endif
If _Super:Activate()
    If .F.
        _Super:setfilter("1=2") 
        lRet := .F.
        self:SetStatusResponse(403, STR0008)  //"Forbidden access to routine "
    Else
        cIn := "'      '"
        cFixedFilter := "F61_FILIAL='"+xFilial('F61')+"' AND (F61_USER = '' OR F61_USER = '"+__cUserID+"') "
        If Len(aUserGroups) > 0
            For nX:=1 to Len(aUserGroups)
                cIn += ",'"+aUserGroups[nX]+"'"
            Next
            cFixedFilter += " AND (F61_GROUP ='' OR F61_GROUP IN ("+cIn+") )"
        Endif
       // Set standard filter for model
        If cFixedFilter <> ""
            If(self:cFilter) <> ""
                self:setfilter(self:cFilter + " AND ("+cFixedFilter+")")
            Else
                self:setfilter("("+cFixedFilter+")")
            Endif    
        Endif
        lRet := .T.      
   EndIf   
Else
   lRet := .F.
EndIf
Return lRet


Static Function ModelDef() 
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruF61
Local oModel // Modelo de dados que ser? constru?do
//Local oRestModel:= oModelF61():New()
oModel := MPFormModel():New('RU34S10B')
oStruF61 := FWFormStruct( 1, 'F61' )


oModel:AddFields( 'F61MASTER', /*cOwner*/, oStruF61)

oModel:SetDescription(STR0009) //"Generic Parameters'"
oModel:GetModel('F61MASTER'):SetDescription(STR0009) //'Generic Parameters'

oModel:SetPrimaryKey({'F61_UUID'})

Return oModel

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'RU34S10B' )
// Cria a estrutura a ser usada na View
Local oStruF61 := FWFormStruct( 2, 'F61' )
// Interface de visualiza??o constru?da
Local oView := FWFormView():New()

oStruF61:SetNoFolder()
// Cria o objeto de View
// Define qual o Modelo de dados ser? utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul?rio
// (antiga Enchoice)
oView:AddField( 'VIEW_F61', oStruF61, 'F61MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'HEADER' , 100 )
// Relaciona o identificador (ID) da View com o "box" para exibi??o
oView:SetOwnerView( 'VIEW_F61', 'HEADER' )


// Retorna o objeto de View criado
Return oView

/* FINISH MODEL F61 */



                   
//Merge Russia R14 
                   
