#INCLUDE "GFEC061F.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC061F
Consulta da Tarifa da tabela de frete.
Uso Generico.

@param  lFiltGV9        Inicia com filtro default

@sample
GFEC061F(lFiltGV9)

@author Jorge Matos Valcanaia
@since 04/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC061F( lFiltGV9 )
	Local oBrowse

	Default lFiltGV9 := .F.

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GV6")						 // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC061F")				 // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	 // Descrição do browse     //"Tarifa da tabela de frete"

	If lFiltGV9    
		oBrowse:SetFilterDefault( "GV6_FILIAL == '" + GV9->GV9_FILIAL + "' .And. GV6_CDEMIT == '" + GV9->GV9_CDEMIT + "' .And. GV6_NRTAB == '" + GV9->GV9_NRTAB + "' .And. GV6_NRNEG == '" + GV9->GV9_NRNEG + "'")
	EndIf

	oBrowse:Activate()

Return(Nil)

//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
// Adiciona botões do browse
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEC061F" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEC061F" OPERATION 8 ACCESS 0 //"Imprimir"
//ADD OPTION aRotina TITLE STR0009 ACTION "GFEC061G"         OPERATION 9 ACCESS 0 //"Componentes"
//ADD OPTION aRotina TITLE STR0010 ACTION "GFEC061H"         OPERATION 9 ACCESS 0 //"Emitentes"

Return aRotina

//---------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEC061F", /*bPre*/, /*bPost*/,/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEC061F_GV6", Nil, FWFormStruct(1,"GV6"),/*bPre*/,/*bPost*/,/*bLoad*/)  

//Componente da Tarifa da tabela.
oModel:AddGrid( 'DETAIL_GV1', 'GFEC061F_GV6', FWFormStruct(1,"GV1"), /*bLinePre*/,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/,/*BLoad*/ ) 
//Componente da Tarifa X Emitente
oModel:AddGrid( 'DETAIL_GUC', 'GFEC061F_GV6', FWFormStruct(1,"GUC"), /*bLinePre*/,/*bLinePos*/, /*bPreVal*/ , /*bPosVal*/,/*BLoad*/ ) 

oModel:SetRelation('DETAIL_GV1',{{'GV1_FILIAL','xFilial( "GV1" )'},{'GV1_CDEMIT','GV6_CDEMIT'},{'GV1_NRTAB','GV6_NRTAB'},{'GV1_NRNEG','GV6_NRNEG'},{'GV1_CDFXTV','GV6_CDFXTV'},{'GV1_NRROTA','GV6_NRROTA'}},'GV1_CDCOMP') 
oModel:SetRelation('DETAIL_GUC',{{'GUC_FILIAL','xFilial( "GUC" )'},{'GUC_CDEMIT','GV6_CDEMIT'},{'GUC_NRTAB','GV6_NRTAB'},{'GUC_NRNEG','GV6_NRNEG'},{'GUC_CDFXTV','GV6_CDFXTV'},{'GUC_NRROTA','GV6_NRROTA'}},'GUC_CDCOMP+GUC_EMICOM') 

oModel:SetPrimaryKey({"GV6_FILIAL", "GV6_CDEMIT", "GV6_NRTAB", "GV6_NRNEG", "GV6_CDFXTV", "GV6_NRROTA"}) 
                                     
Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEC061F")
Local oView  := Nil
Local oStructGV1 := FWFormStruct(2, "GV1")
Local oStructGUC := FWFormStruct(2, "GUC")

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEC061F_GV6" , FWFormStruct(2,"GV6"), /*cLinkID*/ )	//

oView:AddGrid('VIEW_GV1',oStructGV1,'DETAIL_GV1')
oView:AddGrid('VIEW_GUC',oStructGUC,'DETAIL_GUC')

// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

oStructGV1:RemoveField("GV1_CDEMIT")
oStructGV1:RemoveField("GV1_NMEMIT")                               	
oStructGV1:RemoveField("GV1_NRTAB") 
oStructGV1:RemoveField("GV1_DSTAB") 
oStructGV1:RemoveField("GV1_NRNEG")   
oStructGV1:RemoveField("GV1_CDFXTV")   
oStructGV1:RemoveField("GV1_NRROTA")    

oStructGUC:RemoveField("GUC_CDEMIT")
oStructGUC:RemoveField("GUC_NMEMIT")                               	
oStructGUC:RemoveField("GUC_NRTAB") 
oStructGUC:RemoveField("GUC_DSTAB") 
oStructGUC:RemoveField("GUC_NRNEG")   
oStructGUC:RemoveField("GUC_CDFXTV")   
oStructGUC:RemoveField("GUC_NRROTA") 

oView:CreateHorizontalBox( "MASTER" , 55,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
oView:CreateHorizontalBox( "DETAIL" , 45,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ ) 
oView:CreateHorizontalBox( "DETAILTAR" , 100,,,"IDFOLDER","IDSHEET01" ) 
oView:CreateHorizontalBox( "DETAILEMI" , 100,,,"IDFOLDER","IDSHEET02" )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0012) //'Componente da Tarifa'
oView:AddSheet("IDFOLDER","IDSHEET02",STR0013) //'Componente da Tarifa X Emitente'

// Associa um View a um box
oView:SetOwnerView( "GFEC061F_GV6" , "MASTER" )
oView:SetOwnerView("VIEW_GV1","DETAILTAR")
oView:SetOwnerView("VIEW_GUC","DETAILEMI")

Return oView