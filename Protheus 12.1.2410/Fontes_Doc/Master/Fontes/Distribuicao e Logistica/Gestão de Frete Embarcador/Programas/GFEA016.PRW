#INCLUDE "GFEA016.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA016

Geração de Pré-faturas

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA016()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUW")												// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA016")										// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Manutenção de Calendário de Transporte")  	// Descrição do browse //"Calendário"

	oBrowse:AddLegend( "GUW_TPDIA =='1'", "BLUE", STR0001)  // Legenda //"Útil"
	oBrowse:AddLegend( "GUW_TPDIA =='2'", "RED", STR0002 )  // Legenda //"Não-Útil"

	oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	//-------------------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------------------
	ADD OPTION aRotina TITLE STR0003 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA016" OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0005 ACTION "GFEA15CLD"       OPERATION 3  ACCESS 0 //"Gerar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA016" OPERATION 4  ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA016" OPERATION 8  ACCESS 0   //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGUW := FWFormStruct(1,"GUW")

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEA016", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields("GFEA016_GUW", Nil, oStructGUW,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUW_FILIAL", "GUW_DATA"})
	oModel:SetDescription("Calendário de Transporte")

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA016")
	Local oView  := Nil

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "GFEA016_GUW" , FWFormStruct(2,"GUW"), /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA016_GUW" , "MASTER" )

Return oView  

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA016

Função que executa a criação do Calendário do ano

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
         
Function GFEA15PROC()
	Local lGera
	Local dCorrent := CTOD("01/01/" + MV_PAR01)

    DbSelectArea("GUW")
    DbSetOrder(1)

    If DbSeek(xFilial("GUW") + DTOS(dCorrent))
    	msgInfo(STR0008+MV_PAR01+STR0009)       	 //"Calendário referente ao ano de "###" já foi cadastrado."
    Else
    	ProcRegua(365)
    	While Year(dCorrent) = Val(MV_PAR01)
    		IncProc()

			lGera := .F.

			If (MV_PAR02 == 1 .AND. DOW(dCorrent) == 2) .Or. (MV_PAR03 == 1 .AND. DOW(dCorrent) == 3);
														.Or. (MV_PAR04 == 1 .AND. DOW(dCorrent) == 4);
														.Or. (MV_PAR05 == 1 .AND. DOW(dCorrent) == 5);
														.Or. (MV_PAR06 == 1 .AND. DOW(dCorrent) == 6);
														.Or. (MV_PAR07 == 1 .AND. DOW(dCorrent) == 7);
														.Or. (MV_PAR08 == 1 .AND. DOW(dCorrent) == 1)
				lGera := .T.
	        EndIf

			DbSelectArea("GUW")
			RecLock("GUW", .T.)
			GUW->GUW_FILIAL := xFilial("GUW")
			GUW->GUW_DATA   := dCorrent
			GUW->GUW_TPDIA  := Iif(lGera,"1","2")
			GUW->GUW_DSDNU  := DiaExtenso(dCorrent)
			MsUnLocK("GUW")

			dCorrent ++
		EndDo

		msgInfo(STR0010)	 //"Calendário criado com sucesso."
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA15CLD

Função que mostra em tela o procassamento do Calendário

@author Jorge Matos Valcanaia
@since 20/11/09
@version 1.0 
/*/                                        
//-------------------------------------------------------------------

Function GFEA15CLD()

	If Pergunte("GFEA015",.T.)
		Processa({|lEnd| GFEA15PROC()},STR0011,STR0012) //"Gerando Calendário..."###"Aguarde"
	EndIf

Return
