#INCLUDE "GFEA015.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA010
Rotina para o cadastro de Contato de Emitentes.
Uso Geral. 

@author Leonardo Ribas Jimenez Hernandez
@since 28/02/19
@version 1.0
/*/

//-------------------------------------------------------------------

Function GFEA010()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GU2")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA010")					// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription("Cadastro Contato de Emitentes")	// Descrição do browse //"Cadastro Contato de Emitentes"

// Inclusão das opções de visão
oBrowse:SetAttach(.T.)

oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------------------
	// Adiciona botões do browse                                                               
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0001	ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.GFEA010" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.GFEA010" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.GFEA010" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.GFEA010" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.GFEA010" OPERATION 9 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0007	ACTION "VIEWDEF.GFEA010" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()                       
Local oModel
Local oStructGU2 := FWFormStruct(1,"GU2")

oStructGU2:RemoveField( "GU2_FILIAL" )

oModel := MPFormModel():New("GFEA010",  /*bPre*/, {|oX|GFEA010VAL(oX)}  /*bPost*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields("GFEA010_GU2", Nil,oStructGU2,/*bPre*/,/*bPost*/,/*bLoad*/) 

oModel:SetPrimaryKey({"GU2_FILIAL", "GU2_CDEMIT", "GU2_SEQ"})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel     := FWLoadModel("GFEA010")
	Local oView      := Nil
	Local oStruct := FWFormStruct(2,"GU2")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA010_GU2" , oStruct, /*cLinkID*/ )

Return oView                         

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA010VAL
Rotina para realizar as validacoes.
Uso Geral.

@param 	oModel	    Model principal

@author Leonardo Ribas Jimenez Hernandez
@since 28/02/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA010VAL(oModel)
Local lRet      := .T.
Local nOp := oModel:GetOperation()
	
	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE
		//Validação do campo nome do contato
		If Empty(M->GU2_NOME)
			Help( ,, 'Help',, STR0020, 1, 0 )  //"É necessário informar o nome do contato."
			lRet := .F. 
		EndIf
		//Validação no campo de e-mail para que não se cadastre um contato com email em branco ou invalido
		If lRet .And. Empty(M->GU2_EMAIL)
			Help( ,, 'Help',, STR0021, 1, 0 )  //"É necessário informar um e-mail."
			lRet := .F. 
		ElseIf lRet .And. (!('@' $ M->GU2_EMAIL) .Or. !( '.' $ M->GU2_EMAIL))
			Help( ,, 'Help',, STR0022, 1, 0 )  //"O e-mail informado não é válido, favor informar um e-mail válido. Exemplo: abc@xyz.com"
			lRet := .F.
		EndIf
		//Validação no campo de telefone
		If lRet .And. Empty(M->GU2_FONE1) .And. Empty(M->GU2_FONE2)
			Help( ,, 'Help',, STR0023, 1, 0 )  //"É necessário informar um telefone de contato"
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA010SEQ
Função gatilho do campo GU2_CDEMIT para busca do número de sequência
Uso Geral.

@param 	cCdEmit	    Código do Emitente

@author Leonardo Ribas Jimenez Hernandez
@since 28/02/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA010SEQ(cCdEmit)

Local nSeq := 0
Local cSeq := ""
	
	GU2->( dbSetOrder(1) )
	If GU2->( dbSeek(xFilial("GU2") + FwFldGet("GU2_CDEMIT")) )
		While !GU2->( Eof() ) .And. xFilial("GU2") + GU2->GU2_CDEMIT == GU2->GU2_FILIAL + FwFldGet("GU2_CDEMIT")
			nSeq := val(GU2->GU2_SEQ)
			GU2->( dbSkip() )
		EndDo
	Else 
		nSeq := 001
	EndIf

	nSeq++
	cSeq := cValToChar(nSeq)

Return cSeq