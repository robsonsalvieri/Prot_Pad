#INCLUDE "GFEA061B.ch" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061B
Componente da tabela de frete
Generico

@sample
GFEA061B()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA061B( lFiltGV9 )
Local oBrowse

Default lFiltGV9 := .F.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUY")						 // Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA061B")				 // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	 // Descrição do browse //"Componente da tabela de frete"

If lFiltGV9    	
	oBrowse:SetFilterDefault("GUY_FILIAL == '" + GV9->(GV9_FILIAL) + "'" + " .And. GUY_CDEMIT == '" + GV9->(GV9_CDEMIT) + "'" + " .And. GUY_NRTAB == '" + GV9->(GV9_NRTAB) + "'" + " .And. GUY_NRNEG == '" + GV9->(GV9_NRNEG) + "'")
Endif

oBrowse:Activate()

Return(Nil)

//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
// Adiciona botões do browse
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA061B" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA061B" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA061B" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA061B" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA061B" OPERATION 7 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA061B" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//---------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
// bPost   Code-Block de validação do formulário de edição
// bCommit Code-Block de persistência do formulário de edição
// bCancel Code-Block de cancelamento do formulário de edição
oModel := MPFormModel():New("GFEA061B", /*bPre*/, {|oX| GFEA61BPS(oX)},/*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
// bPost        Code-Block de validação do formulário de edição
// bLoad        Code-Block de carga dos dados do formulário de edição
oModel:AddFields("GFEA061B_GUY", Nil, FWFormStruct(1,"GUY"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUY_FILIAL", "GUY_CDEMIT", "GUY_NRTAB", "GUY_NRNEG", "GUY_CDCOMP"}) 
oModel:SetVldActivate ( { |oX| GFEA61BDL( oX ) } )

Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA061B")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
oView:AddField( "GFEA061B_GUY" , FWFormStruct(2,"GUY"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA061B_GUY" , "MASTER" )

Return oView


/*/----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61BPS
Validacao de Inclusao e Alteracao.
Uso GFEA061B.

@param oModel        Objeto modelo

@sample
GFEA61BPS()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA61BPS(oModel)
Local lRet := .T.  
Local nOp := (oModel:getOperation())  
Local cPedagGV2  
Local cPedagGUY

If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE // Se for inclusão ou alteração
	
	If oModel:GetValue('GFEA061B_GUY','GUY_TOTFRE') == '2' .And. (oModel:GetValue('GFEA061B_GUY','GUY_BASIMP') == '1' .Or.;
	   oModel:GetValue('GFEA061B_GUY','GUY_BAPICO') == '1' .Or. oModel:GetValue('GFEA061B_GUY','GUY_FREMIN') == '1')
  		Help( ,, 'Help',, STR0009+STR0011, 1, 0 ) //"Registro não será utilizado para o total de frete."##" Os campos 'Base Imposto', 'Base PIS/COF' e 'Frete Minimo' devem estar como 'Não'."
		lRet := .F.                                                        	
	EndIf                                                                                       
EndIf				

If nOp == MODEL_OPERATION_INSERT

	dbSelectArea("GUY")
	dbSetOrder(1)
	dbSeek(xFilial('GUY')+oModel:GetValue('GFEA061B_GUY','GUY_CDEMIT')+oModel:GetValue('GFEA061B_GUY','GUY_NRTAB')+oModel:GetValue('GFEA061B_GUY','GUY_NRNEG'))
	
	While !Eof() .and. xFilial('GUY')+oModel:GetValue('GFEA061B_GUY','GUY_CDEMIT')+oModel:GetValue('GFEA061B_GUY','GUY_NRTAB')+oModel:GetValue('GFEA061B_GUY','GUY_NRNEG') == ;
	  GUY->GUY_FILIAL + GUY->GUY_CDEMIT + GUY->GUY_NRTAB + GUY->GUY_NRNEG
	
		cPedagGV2 := Posicione("Gv2",1,xFilial("Gv2")+M->GUY_CDCOMP,"GV2_CATVAL")
		cPedagGUY := Posicione("Gv2",1,xFilial("Gv2")+GUY->GUY_CDCOMP,"GV2_CATVAL")		
		       
		If cPedagGV2 == "4" .AND. cPedagGUY == "4"
			Help( ,, 'Help',, STR0012, 1, 0 )  //"Já existe campo com Pedágio ativo."
			lRet := .F.
		EndIf
	
		dbSelectArea("GUY")
		dbSkip()
	EndDo	                      
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA61BDL
Rotina para realizar as validacoes no momento da exclusao.
Uso Geral.

@param 	oModel	    Recebe o oModel principal

@author Felipe Nathan Welter
@since 18/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA61BDL(oModel)
Local lRet    := .T.
local nOpc    := (oModel:GetOperation())

If nOpc == MODEL_OPERATION_DELETE 
	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) AS QTD FROM "+RetSQLName("GV1")
	cQuery += " WHERE GV1_CDEMIT = '"+GUY->GUY_CDEMIT+"'"
	cQuery += " AND GV1_NRTAB = '"+GUY->GUY_NRTAB+"'"
	cQuery += " AND GV1_NRNEG = '"+GUY->GUY_NRNEG+"'"
	cQuery += " AND GV1_CDCOMP = '"+GUY->GUY_CDCOMP+"'"
	cQuery += " AND D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If (cAliasQry)->QTD > 0
		Help(,,'HELP',,STR0010,1,0)  //"O componente selecionado está em uso como componente da tarifa de frete."
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf

Return(lRet) 
