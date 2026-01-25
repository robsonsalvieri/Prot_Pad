#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEC510.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEC510

Cadastro de Restrições

@author Jorge Matos Valcanaia
@since 07/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEC510()
	Local oBrowse          

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GX3")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC510")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Ponto de Controle"
	
	oBrowse:AddLegend( "GX3_SIT =='1'", "WHITE"  , STR0002 ) //"Aberto"
	oBrowse:AddLegend( "GX3_SIT =='2'", "GREEN"  , STR0003 ) //"Movimentação"
	oBrowse:AddLegend( "GX3_SIT =='3'", "YELLOW" , STR0004 ) //"Em Fila"
	oBrowse:AddLegend( "GX3_SIT =='4'", "GRAY"   , STR0005 ) //"Endereçado"
	oBrowse:AddLegend( "GX3_SIT =='5'", "RED"    , STR0006 ) //"Cancelado" 
	oBrowse:AddLegend( "GX3_SIT =='6'", "BLUE"   , STR0007 ) //"Concluido" 
									
	oBrowse:Activate()
Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0008 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.GFEC510" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0011 ACTION "VIEWDEF.GFEC510" OPERATION 8 ACCESS 0 //"Imprimir"
	
Return aRotina

//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel                      	
Local oStructGX3 := FWFormStruct(1,"GX3")
Local oStructGX4 := FWFormStruct(1,"GX4")
Local oStructGXA := FWFormStruct(1,"GXA") 
Local oStructGXB := FWFormStruct(1,"GXB") 
Local oStructGX5 := FWFormStruct(1,"GX5")
Local oStructGWD := FWFormStruct(1,"GWD")
Local oStructGWV := FWFormStruct(1,"GWV")
Local oStructGX6 := FWFormStruct(1,"GX6")
Local oStructGX8 := FWFormStruct(1,"GX8")
Local oStructGX7 := FWFormStruct(1,"GX7")

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEC510", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEC510_GX3", Nil, oStructGX3,/*bPre*/,,/*bLoad*/)
	
oModel:AddGrid("GFEC510_GX4","GFEC510_GX3",oStructGX4,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GX4",{{"GX4_FILIAL",'xFilial("GX4")'},{"GX4_NRMOV","GX3_NRMOV"}},"GX4_FILIAL+GX4_NRMOV+GX4_SEQ")

oModel:AddGrid("GFEC510_GXA","GFEC510_GX4",oStructGXA,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GXA",{{"GXA_FILIAL",'xFilial("GXA")'},{"GXA_NRMOV","GX4_NRMOV"}},"GXA_FILIAL+GXA_NRMOV+GXA_SEQ")
 
oModel:AddGrid("GFEC510_GXB","GFEC510_GX4",oStructGXB,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GXB",{{"GXB_FILIAL",'xFilial("GXB")'},{"GXB_NRMOV","GX4_NRMOV"}},"GXB_FILIAL+GXB_NRMOV+GXB_SEQ")

oModel:AddGrid("GFEC510_GX5","GFEC510_GX4",oStructGX5,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GX5",{{"GX5_FILIAL",'xFilial("GX5")'},{"GX5_NRMOV","GX4_NRMOV"}},"GX5_FILIAL+GX5_NRMOV+GX5_SEQ")

oModel:AddGrid("GFEC510_GWD","GFEC510_GX4",oStructGWD,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GWD",{{"GWD_FILIAL",'xFilial("GWD")'},{"GWD_NRMOV","GX4_NRMOV"}},"GWD_FILIAL+GWD_NRMOV")

oModel:AddGrid("GFEC510_GWV","GFEC510_GX3",oStructGWV,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GWV",{{"GWV_FILIAL",'xFilial("GWV")'},{"GWV_NRMOV","GX3_NRMOV"}},"GWV_FILIAL+GWV_NRMOV")

oModel:AddGrid("GFEC510_GX6","GFEC510_GX3",oStructGX6,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GX6",{{"GX6_FILIAL",'xFilial("GX6")'},{"GX6_NRMOV","GX3_NRMOV"}},"GX6_FILIAL+GX6_NRMOV")

oModel:AddGrid("GFEC510_GX8","GFEC510_GX3",oStructGX8,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GX8",{{"GX8_FILIAL",'xFilial("GX8")'},{"GX8_NRMOV","GX3_NRMOV"}},"GX8_FILIAL+GX8_NRMOV")

oModel:AddGrid("GFEC510_GX7","GFEC510_GX3",oStructGX7,/*bLinePre*/,,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEC510_GX7",{{"GX7_FILIAL",'xFilial("GX7")'},{"GX7_NRMOV","GX3_NRMOV"}},"GX7_FILIAL+GX7_NRMOV")

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEC510")
//	Local oView  := Nil
	
	Local oStructGX3 := FWFormStruct(2,"GX3")
	Local oStructGX4 := FWFormStruct(2,"GX4") 
	Local oStructGXA := FWFormStruct(2,"GXA")
	Local oStructGXB := FWFormStruct(2,"GXB")
	Local oStructGX5 := FWFormStruct(2,"GX5")
	Local oStructGWD := FWFormStruct(2,"GWD")			
	Local oStructGWV := FWFormStruct(2,"GWV")	
	Local oStructGX6 := FWFormStruct(2,"GX6")
	Local oStructGX8 := FWFormStruct(2,"GX8")
	Local oStructGX7 := FWFormStruct(2,"GX7")

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEC510_GX3" , oStructGX3 )
	
	oView:AddGrid(  "GFEC510_GX4" , oStructGX4 )		
	oStructGX4:RemoveField("GX4_USUSAI")
	oStructGX4:RemoveField("GX4_QTPESO")
	oStructGX4:RemoveField("GX4_USUPES")
	oStructGX4:RemoveField("GX4_IDPEDI")
	oStructGX4:RemoveField("GX4_VLHODO")
	oStructGX4:RemoveField("GX4_QTDC"  ) 
	oStructGX4:RemoveField("GX4_DTCHEN") 
	oStructGX4:RemoveField("GX4_HRCHEN")
	oStructGX4:RemoveField("GX4_DTSAEN")
	oStructGX4:RemoveField("GX4_HRSAEN")
	oStructGX4:RemoveField("GX4_DTINCA") 
	oStructGX4:RemoveField("GX4_HRINCA")
	oStructGX4:RemoveField("GX4_DTFICA")
	oStructGX4:RemoveField("GX4_HRFICA")
	oStructGX4:RemoveField("GX4_DTLIEN")
	oStructGX4:RemoveField("GX4_HRLIEN")
	oStructGX4:RemoveField("GX4_QTPEEN")
	oStructGX4:RemoveField("GX4_QTVEEN")               
	
	oView:AddGrid(  "GFEC510_GXA" , oStructGXA )
	oView:AddGrid(  "GFEC510_GXB" , oStructGXB )
	oView:AddGrid(  "GFEC510_GX5" , oStructGX5 )
	oView:AddGrid(  "GFEC510_GWD" , oStructGWD )
	oView:AddGrid(  "GFEC510_GWV" , oStructGWV )
	oView:AddGrid(  "GFEC510_GX6" , oStructGX6 )
	oView:AddGrid(  "GFEC510_GX8" , oStructGX8 )   
	oView:AddGrid(  "GFEC510_GX7" , oStructGX7 )    
			
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	
	oView:CreateHorizontalBox( "MASTER"   , 30 )
	oView:CreateHorizontalBox( "DETAIL"   , 70 )
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0012) //"Perguntas"
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0013) //"Agendamento"
	oView:AddSheet("IDFOLDER","IDSHEET03",STR0014) //"Veículos"
	oView:AddSheet("IDFOLDER","IDSHEET04",STR0015) //"Motoristas"
	oView:AddSheet("IDFOLDER","IDSHEET05",STR0016) //"Visitantes"
	oView:CreateHorizontalBox( "DETAIL_01"  , 50 ,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_02"  , 50 ,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_07"  , 100,,,"IDFOLDER","IDSHEET02" )
	oView:CreateHorizontalBox( "DETAIL_08"  , 100,,,"IDFOLDER","IDSHEET03" )
	oView:CreateHorizontalBox( "DETAIL_09"  , 100,,,"IDFOLDER","IDSHEET04" )
	oView:CreateHorizontalBox( "DETAIL_10"  , 100,,,"IDFOLDER","IDSHEET05" )
	
	oView:CreateFolder("IDFOLDER1","DETAIL_02")
  	oView:AddSheet("IDFOLDER1","IDSHEET02",STR0017) //"Doc. Carga"
	oView:AddSheet("IDFOLDER1","IDSHEET03",STR0018) //"Chamado"
	oView:AddSheet("IDFOLDER1","IDSHEET04",STR0019) //"Perguntas"
	oView:AddSheet("IDFOLDER1","IDSHEET05",STR0020) //"Ocorrencias"
	
 	oView:CreateHorizontalBox( "DETAIL_03"  , 100,,,"IDFOLDER1","IDSHEET02" )
 	oView:CreateHorizontalBox( "DETAIL_04"  , 100,,,"IDFOLDER1","IDSHEET03" )
 	oView:CreateHorizontalBox( "DETAIL_05"  , 100,,,"IDFOLDER1","IDSHEET04" )
 	oView:CreateHorizontalBox( "DETAIL_06"  , 100,,,"IDFOLDER1","IDSHEET05" )
	
	// Associa um View a um box
	oView:SetOwnerView( "GFEC510_GX3" , "MASTER"    )    
	oView:SetOwnerView( "GFEC510_GX4" , "DETAIL_01" ) 
	oView:SetOwnerView( "GFEC510_GXA" , "DETAIL_03" )
	oView:SetOwnerView( "GFEC510_GXB" , "DETAIL_04" )
	oView:SetOwnerView( "GFEC510_GX5" , "DETAIL_05" )
	oView:SetOwnerView( "GFEC510_GWD" , "DETAIL_06" )
	oView:SetOwnerView( "GFEC510_GWV" , "DETAIL_07" )
	oView:SetOwnerView( "GFEC510_GX6" , "DETAIL_08" )
	oView:SetOwnerView( "GFEC510_GX8" , "DETAIL_09" )
	oView:SetOwnerView( "GFEC510_GX7" , "DETAIL_10" )		
Return oView   

