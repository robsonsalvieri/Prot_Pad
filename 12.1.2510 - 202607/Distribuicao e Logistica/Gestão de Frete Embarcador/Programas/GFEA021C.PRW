#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA021C()
Cadastro de Regioes


@author siegklenes.beulke
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA021C()

Local oBrowse 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GU9")      // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA021C") // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Consulta de regiões")

oBrowse:Activate()                

Return(Nil)

//------------------------------------------------------------------------------------//
//----------------------------FUNCAO MENUDef()----------------------------------------//
//------------------------------------------------------------------------------------//
Static Function MenuDef()

Local aRotina := {}                                           
//-------------------------------------------------------

// Adiciona botões do browse

//-------------------------------------------------------

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.GFEA021C" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.GFEA021C" OPERATION 8 ACCESS 0

Return aRotina 

//------------------------------------------------------------------------------------//
//----------------------------FUNCAO ModelDef()---------------------------------------//
//------------------------------------------------------------------------------------//
Static Function ModelDef() 

Local oModel
Local oStrucGVRA := FWFormStruct(1,"GVR")
Local oStrucGVRB := FWFormStruct(1,"GVR")

// cID     Identificador do modelo
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA021C", /*bPre*/,/*bPost*/,/*bPost*/,/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA021C_GU9", Nil, FWFormStruct(1,"GU9"),/*bPre*/,/*bPost*/,/*bLoad*/)    
oModel:AddGrid("GFEA021C_GUA","GFEA021C_GU9",FWFormStruct(1,"GUA"),/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEA021C_GUA",{{"GUA_FILIAL",'xFilial("GU9")'},{"GUA_NRREG","GU9_NRREG"}},"GUA_FILIAL+GUA_NRREG")
oModel:SetPrimaryKey({"GU9_FILIAL", "GU9_NRREG"})

oModel:AddGrid("GFEA021C_GUL","GFEA021C_GU9",FWFormStruct(1,"GUL"),/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEA021C_GUL",{{"GUL_FILIAL",'xFilial("GU9")'},{"GUL_NRREG","GU9_NRREG"}},"GUL_FILIAL+GUL_NRREG")

oModel:AddGrid("GFEA021C_GVRA","GFEA021C_GU9",oStrucGVRA,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEA021C_GVRA",{{"GVR_FILIAL",'xFilial("GU9")'},{"GVR_NRREG","GU9_NRREG"}},GVR->(IndexKey(1)))
oModel:AddGrid("GFEA021C_GVRB","GFEA021C_GU9",oStrucGVRB,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("GFEA021C_GVRB",{{"GVR_FILIAL",'xFilial("GU9")'},{"GVR_NRREGR","GU9_NRREG"}},GVR->(IndexKey(2)))

Return(oModel)

//------------------------------------------------------------------------------------//
//----------------------------FUNCAO ViewDef()----------------------------------------//
//------------------------------------------------------------------------------------//

Static Function ViewDef()
Local oModel := FWLoadModel("GFEA021C")
Local oView 
Local oStructGUA := FWFormStruct(2,"GUA")
Local oStructGUL := FWFormStruct(2,"GUL")
Local oStrucGVRA := FWFormStruct(2,"GVR")
Local oStrucGVRB := FWFormStruct(2,"GVR")
Local nOpc := oModel:GetOperation()
 
oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField( "GFEA021C_GU9" , FWFormStruct(2,"GU9") )

oStructGUA:RemoveField("GUA_NRREG")
oStructGUL:RemoveField("GUL_NRREG")
oStrucGVRA:RemoveField("GVR_NRREG")
oStrucGVRA:RemoveField("GVR_NMREG")
oStrucGVRB:RemoveField("GVR_NRREGR")
oStrucGVRB:RemoveField("GVR_NMREGR")

oView:AddGrid( "GFEA021C_GUA" , oStructGUA )
oView:AddGrid( "GFEA021C_GUL" , oStructGUL )
oView:AddGrid( "GFEA021C_GVRA" , oStrucGVRA )
oView:AddGrid( "GFEA021C_GVRB" , oStrucGVRB )

oView:CreateHorizontalBox( "MASTER" , 20 )
oView:CreateHorizontalBox( "DETAIL" , 80 )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01","Cidades")
oView:AddSheet("IDFOLDER","IDSHEET02","Faixas de CEP")
oView:AddSheet("IDFOLDER","IDSHEET03","Regiões")
oView:AddSheet("IDFOLDER","IDSHEET04","Regiões Superiores")

oView:CreateHorizontalBox( "DETAILCID"  , 100,,,"IDFOLDER","IDSHEET01" )
oView:CreateHorizontalBox( "DETAILCEP"  , 100,,,"IDFOLDER","IDSHEET02" )
oView:CreateHorizontalBox( "DETAILREGA" , 100,,,"IDFOLDER","IDSHEET03" )
oView:CreateHorizontalBox( "DETAILREGB" , 100,,,"IDFOLDER","IDSHEET04" )

oView:SetOwnerView( "GFEA021C_GU9" , "MASTER" )
oView:SetOwnerView( "GFEA021C_GUA" , "DETAILCID" )
oView:SetOwnerView( "GFEA021C_GUL" , "DETAILCEP" )
oView:SetOwnerView( "GFEA021C_GVRA" , "DETAILREGA" )
oView:SetOwnerView( "GFEA021C_GVRB" , "DETAILREGB" )

oView:AddUserButton( 'Consultar Cidade'           , 'MAGIC_BMP', {|oModel| GFEA021CID(oModel,"GFEA021C_GUA" )})
oView:AddUserButton( 'Consultar Região'           , 'MAGIC_BMP', {|oModel| GFEA021REG(oModel,"GFEA021C_GVRA","GVR_NRREGR")})
oView:AddUserButton( 'Consultar Região Superior'  , 'MAGIC_BMP', {|oModel| GFEA021REG(oModel,"GFEA021C_GVRB","GVR_NRREG")}) 
 
Return oView