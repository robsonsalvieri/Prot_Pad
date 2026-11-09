#INCLUDE "GFEA060.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA060
Cadastro de Componentes de Frete.
Generico.

@sample
GFEA060()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA060()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GV2")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA060")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) // Descrição do browse //"Cadastro de Componentes de Fretes"
	oBrowse:Activate()
Return Nil
//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	// Adiciona botões do browse
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA060" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA060" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA060" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA060" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA060" OPERATION 9 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA060" OPERATION 8 ACCESS 0 //"Imprimir"
Return aRotina
//---------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGV2 := FWFormStruct(1,"GV2")
	
	oStructGV2:RemoveField("GV2_DATCAL")
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA060", /*bPre*/, /*bPost*/  {|oMod|GFEA060PS(oMod)},/*bCommit*/ , /*bCancel*/)
	//oModel:SetVldActivate ({|oMod| GFEA060VL(oMod)})
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA060_GV2", Nil, FWFormStruct(1,"GV2"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GV2_FILIAL", "GV2_CDCOMP"})
Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA060")
	Local oView  := Nil
	Local oStructGV2 := FWFormStruct(2,"GV2")
	oStructGV2:RemoveField("GV2_DATCAL")
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA060_GV2" , oStructGV2, /*cLinkID*/ )	//

	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA060_GV2" , "MASTER" )
Return oView

Function GFEA060PS(oModel)
	Local lRet      := .T.
	Local aAreaAnt  := GetArea()
	Local nOpc      := (oModel:GetOperation())
	Local cAliasQry := Nil
	
	If nOpc != MODEL_OPERATION_DELETE
		If FwFldGet("GV2_ATRCAL") == "11" .AND. FwFldGet("GV2_SERVI") == "2"
			Help( ,, 'HELP',, STR0015, 1, 0) //"Quando o componente utilizar o cálculo sobre a Quantidade de Serviço deverá ser selecionado o campo Serviço"
			lRet := .F.
		EndIf
		If FwFldGet("GV2_PEDAG") == "2".AND.FwFldGet("GV2_CATVAL") == "4"
			Help( ,, 'HELP',, STR0011, 1, 0) //"Quando o campo Pedágio for NÃO, a Categoria do Valor deve ser diferente de Pedágio"
			lRet := .F.
		EndIf
		If FwFldGet("GV2_ATRCAL") <> "8" .And. FwFldGet("GV2_VLDIAR") == "1"
			oModel:LoadValue("GFEA060_GV2","GV2_VLDIAR","2")
		Endif
		If FwFldGet("GV2_PEDAG") == "1".AND.FwFldGet("GV2_CATVAL") != "4"
			Help( ,, 'HELP',, STR0010, 1, 0) //"Quando o campo Pedágio for SIM, a Categoria do Valor deve ser Pedágio"
			lRet := .F.
		EndIf	
			
	Else // validação de relacionamento, devido a problemas de dicionario, a validação é feita no programa
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:GUY% GUY
			WHERE GUY.GUY_CDCOMP = %Exp:GV2->GV2_CDCOMP%
			AND GUY.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			Help( ,, 'HELP',, STR0012, 1, 0) //"Este registro está em uso em tabelas de frete (GUY) e não pode ser excluído."
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())

		If lRet
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:GVB% GVB
				WHERE GVB.GVB_CDCOMP = %Exp:GV2->GV2_CDCOMP%
				AND GVB.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				Help( ,, 'HELP',, STR0013, 1, 0) //"Este registro está em uso como componente de tabelas de vínculo (GVB) e não pode ser excluído."
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf

		If lRet
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:GWI% GWI
				WHERE GWI.GWI_CDCOMP = %Exp:GV2->GV2_CDCOMP%
				AND GWI.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				Help( ,, 'HELP',, STR0014, 1, 0) //"Este registro está em uso como componente do cálculo de frete (GWI) e não pode ser excluído."
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf
	
	/*se o campo Serviço estava com valor Não e foi modificado para Sim, verificar se 
	há tabela de frete com este componente e também com outro componente de serviço. 
	Se existir, exibir mensagem: 
	"Não é possível alterar o campo Serviço para Sim. Nas tabelas de frete só é 
	permitido um componente de serviço, e existem tabelas de frete com este componente 
	e também com outro componente de serviço já definido".*/
	// Não realiza a validação caso o parâmetro "Serviço por tipo de Ocorrência" estiver marcado
	If lRet .And. SuperGetMV("MV_SERVTO",.F.,"2") != "1"  .And. nOpc != 5 .And. FwFldGet("GV2_SERVI") == "1" .And. GV2->GV2_SERVI == "2"
	
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GUY.GUY_CDEMIT,
					GUY.GUY_NRTAB,
					GUY.GUY_NRNEG,
					GUY.GUY_CDCOMP 
			FROM %Table:GUY% GUY
			INNER JOIN %Table:GV2% GV2
			ON GV2_CDCOMP = GUY.GUY_CDCOMP
			AND GV2.GV2_SERVI = '1'
			AND GV2.%NotDel%
			WHERE EXISTS ( SELECT 1 
							FROM %Table:GUY% GUY2
							WHERE GUY2.GUY_FILIAL = GUY.GUY_FILIAL
							AND GUY2.GUY_CDEMIT = GUY.GUY_CDEMIT
							AND GUY2.GUY_NRTAB = GUY.GUY_NRTAB
							AND GUY2.GUY_NRNEG = GUY.GUY_NRNEG
							AND GUY2.GUY_CDCOMP <> %Exp:GV2->GV2_CDCOMP%
							AND GUY2.%NotDel% )
			AND GUY.GUY_NRTAB <> ' '
			AND GUY.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			Help( ,, 'HELP',, STR0016, 1, 0) // "Não é possível alterar o campo Serviço para Sim. Nas tabelas de frete só é permitido um componente de serviço, e existem tabelas de frete com este componente e também com outro componente de serviço já definido. Para permitir mais de um componente de serviço por tabela de frete, altere o paramêtro 'Serviço por Tipo de Ocorrência' para '1=Sim'." 
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	
	If lRet .And. nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		If M->GV2_ATRCAL == '11' .And. M->GV2_CALSER == '2'
			Help( ,, 'HELP',, STR0017, 1, 0) // "Não é possível salvar quando o Cálculo do Serviço é por Romaneio e Cálculo Sobre é por Quantidade de Serviço."
			lRet := .F. 
		EndIf
		
		If M->GV2_ATRCAL != '11' .And. M->GV2_CALSER == '1' .And. SuperGetMV("MV_SERVTO",.F.,"2") == '2' .And. M->GV2_SERVI == '1'
			Help( ,, 'HELP',, STR0018, 1, 0) // "Não é possível salvar quando o Cálculo do Serviço é por Ocorrência, Cálculo Sobre não é por Quantidade de Serviço e o parâmetro MV_SERVTO é igual a 2."
			lRet := .F. 
		EndIf
	EndIf
	
	RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA060DAC
Retorna a informação descritiva do atributo para cálculo
Função utilizada para exibir no browse a descrição do atributo de cálculo.
Uso Geral.

@author Lidiomar Fernando dos S. Machado
@since 29/04/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA060DAC()
	Local aDsCbox  := RetSx3Box(Posicione('SX3',2,'GV2_ATRCAL','X3CBox()'),,,1)
	Local cAtrCalc := GV2->GV2_ATRCAL
	Local cDesCalc := ""
	Local nPos     := 0

	If !Empty(aDsCbox) .And.(nPos := aScan(aDsCbox,{|x| Alltrim(cAtrCalc) $ x[2] })) > 0
		cDesCalc := aDsCbox[nPos,3]
	EndIf
Return cDesCalc
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA060AUT
Rotina para realizar Validações de habilitação do campo GV2_CATVAL, GV2_IDVLRC
Uso Geral.

@author Ana Claudia da Silva
@since 08/10/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA060AUT()
Local lRet := .T.

	// O campo "Agrupa por" deve ficar desabilitado quando Categoria for igual a 4=Pedágio e quando "Valor p/RC" for igual a 2=Não
	If !(M->GV2_CATVAL == "4").AND.(M->GV2_IDVLRC == "1")
		lRet := .T.
	Else
		lRet := .F.
	EndIf
Return lRet
