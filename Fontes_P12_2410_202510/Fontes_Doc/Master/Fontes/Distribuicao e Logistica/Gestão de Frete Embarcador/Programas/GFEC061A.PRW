#INCLUDE "GFEC061A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC061A
Consulta da Negociação da tabela de frete.
Uso Generico.

@sample
GFEC061A()

@author Jorge Matos Valcanaia
@since 04/11/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC061A()
Local oBrowse
Local aArea := GetAreA()
Local aAreaGVA := GVA->( GetAreA() )
                
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GV9")						 			 // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEC061A")				 			 // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	 // Descrição do browse //"Negociação da tabela de frete"

oBrowse:SetFilterDefault( "GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB == '"  + xFilial("GV9")+GVA->(GVA_CDEMIT+GVA_NRTAB)+ "'")
	
oBrowse:AddLegend("GV9_SIT == '1'", "RED"  , STR0021 ) // Legenda do Browser  //"Em Negociação"
oBrowse:AddLegend("GV9_SIT == '2'", "GREEN", STR0022 ) //"Liberado"

oBrowse:Activate()

RESTAREA( aAreaGVA )
RESTAREA( aArea )

Return(Nil)

//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

// Adiciona botões do browse
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEC061A" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEC061A" OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0012 ACTION "GFEC061F(.T.)"    OPERATION 9 ACCESS 0 //"Tarifas"

Return aRotina

//---------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEC061A", /*bPre*/,/*bCommit*/, /*bCancel*/)

// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEC061A_GV9", Nil, FWFormStruct(1,"GV9"),/*bPre*/,/*bPost*/,/*bLoad*/)

//Faixas
oModel:AddGrid( 'DETAIL_GUZ', 'GFEC061A_GV9', FWFormStruct(1,"GUZ"),/*bLinePre*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
//Componentes
oModel:AddGrid( 'DETAIL_GUY', 'GFEC061A_GV9', FWFormStruct(1,"GUY"),/*bLinePre*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
//Rotas 
oModel:AddGrid( 'DETAIL_GV8', 'GFEC061A_GV9', FWFormStruct(1,"GV8"),/*bLinePre*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 
//Faixa/Tipo Veiculo
oModel:AddGrid( 'DETAIL_GV7', 'GFEC061A_GV9', FWFormStruct(1,"GV7"),/*bLinePre*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/ ) 

oModel:SetRelation('DETAIL_GUZ',{{'GUZ_FILIAL','xFilial( "GUZ" )'},{'GUZ_CDEMIT','GV9_CDEMIT'},{'GUZ_NRTAB','GV9_NRTAB'},{'GUZ_NRNEG','GV9_NRNEG'}},'GUZ_SEQFAI') 
oModel:SetRelation('DETAIL_GUY',{{'GUY_FILIAL','xFilial( "GUY" )'},{'GUY_CDEMIT','GV9_CDEMIT'},{'GUY_NRTAB','GV9_NRTAB'},{'GUY_NRNEG','GV9_NRNEG'}},'GUY_CDCOMP') 
oModel:SetRelation('DETAIL_GV8',{{'GV8_FILIAL','xFilial( "GV8" )'},{'GV8_CDEMIT','GV9_CDEMIT'},{'GV8_NRTAB','GV9_NRTAB'},{'GV8_NRNEG','GV9_NRNEG'}},'GV8_NRROTA') 
oModel:SetRelation('DETAIL_GV7',{{'GV7_FILIAL','xFilial( "GV7" )'},{'GV7_CDEMIT','GV9_CDEMIT'},{'GV7_NRTAB','GV9_NRTAB'},{'GV7_NRNEG','GV9_NRNEG'}},'GV7_CDFXTV') 

oModel:GetModel( 'DETAIL_GUZ' ):SetUniqueLine( { 'GUZ_SEQFAI' } ) 
oModel:GetModel( 'DETAIL_GUY' ):SetUniqueLine( { 'GUY_CDCOMP' } )
oModel:GetModel( 'DETAIL_GV8' ):SetUniqueLine( { 'GV8_NRROTA' } )
oModel:GetModel( 'DETAIL_GV7' ):SetUniqueLine( { 'GV7_CDFXTV' } )

oModel:GetModel('GFEC061A_GV9'):SetDescription(STR0015) //'Negociação da tabela de frete'
oModel:GetModel('DETAIL_GUZ'):SetDescription(STR0016) //'Faixa Entrega Tab. Frete'
oModel:GetModel('DETAIL_GUY'):SetDescription(STR0023) //'Componentes Tab. Frete'
oModel:GetModel('DETAIL_GV8'):SetDescription(STR0024)  //'Rotas Tab. Frete'
oModel:GetModel('DETAIL_GV7'):SetDescription(STR0025)  //'Faixa/Tipo Veiculo'

Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEC061A")
Local oView  := Nil
Local oStructGUY := FWFormStruct(2, "GUY")
Local oStructGV8 := FWFormStruct(2, "GV8")
Local oStructGV7 := FWFormStruct(2, "GV7")

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField('GFEC061A_GV9',FWFormStruct(2,'GV9'),'GFEC061A_GV9')
oView:AddGrid('VIEW_GUZ',FWFormStruct(2,'GUZ'),'DETAIL_GUZ')
oView:AddGrid('VIEW_GUY',oStructGUY,'DETAIL_GUY') 
oView:AddGrid('VIEW_GV8',oStructGV8,'DETAIL_GV8') 
oView:AddGrid('VIEW_GV7',oStructGV7,'DETAIL_GV7')
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

oStructGUY:RemoveField("GUY_CDEMIT")
oStructGUY:RemoveField("GUY_NMEMIT")                               	
oStructGUY:RemoveField("GUY_NRTAB") 
oStructGUY:RemoveField("GUY_DSTAB") 
oStructGUY:RemoveField("GUY_NRNEG") 
                                  
oStructGV8:RemoveField("GV8_CDEMIT")
oStructGV8:RemoveField("GV8_NMEMIT")                               	
oStructGV8:RemoveField("GV8_NRTAB") 
oStructGV8:RemoveField("GV8_DSTAB") 
oStructGV8:RemoveField("GV8_NRNEG") 

oStructGV7:RemoveField("GV7_CDEMIT")
oStructGV7:RemoveField("GV7_NMEMIT")                               	
oStructGV7:RemoveField("GV7_NRTAB") 
oStructGV7:RemoveField("GV7_DSTAB") 
oStructGV7:RemoveField("GV7_NRNEG")   

oView:CreateHorizontalBox( "MASTER" , 55,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
oView:CreateHorizontalBox( "DETAIL" , 45,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ ) 
oView:CreateHorizontalBox( "DETAILCOM" , 100,,,"IDFOLDER","IDSHEET01" ) 
oView:CreateHorizontalBox( "DETAILROT" , 100,,,"IDFOLDER","IDSHEET02" ) 
oView:CreateHorizontalBox( "DETAILFTV" , 100,,,"IDFOLDER","IDSHEET03" ) 
oView:CreateHorizontalBox( "DETAILFAI" , 100,,,"IDFOLDER","IDSHEET04" ) 


oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0026)  //"Componente de Frete"
oView:AddSheet("IDFOLDER","IDSHEET02",STR0010) //"Rotas"
oView:AddSheet("IDFOLDER","IDSHEET03",STR0027) //"Faixa/Tipo Veiculo"
oView:AddSheet("IDFOLDER","IDSHEET04",STR0017) //"Faixa de Entrega"

// Associa um View a um box
oView:SetOwnerView("GFEC061A_GV9","MASTER")
oView:SetOwnerView("VIEW_GUZ","DETAILFAI")
oView:SetOwnerView("VIEW_GUY","DETAILCOM")
oView:SetOwnerView("VIEW_GV8","DETAILROT")
oView:SetOwnerView("VIEW_GV7","DETAILFTV")

oView:AddIncrementField('VIEW_GUZ','GUZ_SEQFAI')
oView:AddIncrementField('VIEW_GV8','GV8_NRROTA')
oView:AddIncrementField('VIEW_GV7','GV7_CDFXTV')

Return oView