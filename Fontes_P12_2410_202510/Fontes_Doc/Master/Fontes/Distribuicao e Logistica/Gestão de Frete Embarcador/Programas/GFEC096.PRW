#INCLUDE "GFEC096.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEC096
Rotina para consulta de Lote Contábil
Uso Geral.

@param 	oModel	    Recebi o oModel principal

@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEC096()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GXE")							// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC096")					// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse //"Lote Contábil"

	oBrowse:AddLegend("GXE_SIT=='1'", "WHITE", STR0002) //"Não Enviado"
	oBrowse:AddLegend("GXE_SIT=='2'", "YELLOW", STR0003) //"Enviado"
	oBrowse:AddLegend("GXE_SIT=='3'", "GRAY", STR0004) //"Rejeitado"
	oBrowse:AddLegend("GXE_SIT=='4'", "BLUE", STR0005) //"Atualizado"

	oBrowse:Activate()                                       
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0006  	ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0007	ACTION "VIEWDEF.GFEC096" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0008   	ACTION "VIEWDEF.GFEC096" OPERATION 8 ACCESS 0 //"Imprimir"
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGXF := FWFormStruct(1, "GXF")

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEC096", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEC096_GXE", Nil, FWFormStruct(1,"GXE"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GXE_FILIAL", "GXE_CDGREM"})

	oModel:AddGrid("GFEC096_GXF","GFEC096_GXE", oStructGXF,/*bLinePre*/,/* Pos*/,,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEC096_GXF",{{"GXF_FILIAL","xFilial('GXF')"},{"GXF_CODLOT","GXE_CODLOT"}},"GXF_FILIAL+GXF_CODLOT")
	
	oModel:AddCalc('CALCGXF_VLR', 'GFEC096_GXE', 'GFEC096_GXF', 'GXF_VALOR', 'TOTVALOR', 'SUM',,,'Valor Lote' )
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 		:= FWLoadModel("GFEC096")
	Local oView  		:= Nil
	Local oStructGXF 	:= FWFormStruct(2, "GXF")
	Local oCalcGXF 		:= FWCalcStruct( oModel:GetModel( 'CALCGXF_VLR') )

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEC096_GXE" , FWFormStruct(2,"GXE"), /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

	oView:AddGrid( "GFEC096_GXF" , oStructGXF)
	
	oView:AddField( 'VIEWCALC_GXF', oCalcGXF, 'CALCGXF_VLR' )
	
	oView:CreateHorizontalBox( "MASTER" , 45)
	oView:CreateHorizontalBox( "DETAIL" , 45)
	oView:CreateHorizontalBox("DETAIL_GXFCALC" , 10)
	// Associa um View a um box
	oView:SetOwnerView( "GFEC096_GXE" , "MASTER" )
	oView:SetOwnerView( "GFEC096_GXF" , "DETAIL" )
	
	oView:SetOwnerView("VIEWCALC_GXF","DETAIL_GXFCALC" )
	
	oView:EnableTitleView('GFEC096_GXF','Movimentos Contábeis')

Return oView         

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC096XML()
Função utilizada pela integração via XML
Altera a situação do campo GXE_SIT conforme o valor vindo do XML, 
é necessário utilzar este método para evitar as validações do model que só devem ser executadas quando o usuário alterar o registro

@sample
GFEC096XML( cXML )

@author Israel Possoli
@since 10/11/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEC096XML( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local aAreaGWA := GWA->( GetArea() )

	If !Empty( cError )
		Return NIL
	EndIf

	cCodLot := PadR( oXML:_GFEC096:_GFEC096_GXE:_GXE_CODLOT:_VALUE:TEXT, TamSX3("GXE_CODLOT")[1] )
	cSit 	:= PadR( oXML:_GFEC096:_GFEC096_GXE:_GXE_SIT:_VALUE:TEXT   , TamSX3("GXE_SIT")[1]    )
            
    dbSelectArea("GWA")
	GWA->( dbSetOrder(4) )
	GWA->( dbSeek(xFilial("GWA") + cCodLot) )
	While !GWA->( Eof() ) .And. GWA->GWA_CODLOT == cCodLot
		RecLock("GWA",.F.)
			GWA->GWA_SITCTB := cSit
		MsUnLock()		
		dbSelectArea("GWA")
		GWA->( dbSkip() )	
	EndDo
    
	dbSelectArea("GXE")
	GXE->( dbSetOrder(1) )
	If GXE->( dbSeek(xFilial("GXE") + cCodLot) )
		RecLock("GXE",.F.)
			GXE->GXE_SIT := cSit
		MsUnLock()
	EndIf
	
	RestArea(aAreaGWA)
	
Return NIL
