#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA033
Cadastro de Tabelas de Prazos 
Uso Geral.

@since 20/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA033()
	Local 	oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUN")
	oBrowse:SetMenuDef("GFEA033")
	oBrowse:SetDescription("Tabela de Tolerâncias de Peso")
	oBrowse:SetFilterDefault("GUN_TPTAB == '3'")	
	oBrowse:SetOnlyFields( { 'GUN_CODTAB', 'GUN_TPTAB', 'GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP', 'GUN_CDTPVC', 'GUN_CDGRP', 'GUN_CDTRP', 'GUN_MODAL', 'GUN_CDCLFR', 'GUN_MAXQBR'} )
	oBrowse:Activate()
Return(Nil)


Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "AxPesqui"        	OPERATION 1  ACCESS 0  	// "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.GFEA033" 	OPERATION 2  ACCESS 0  	// "Visualizar"
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.GFEA033" 	OPERATION 3  ACCESS 0  	// "Incluir"
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.GFEA033" 	OPERATION 4  ACCESS 0  	// "Alterar"
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.GFEA033" 	OPERATION 5  ACCESS 0  	// "Excluir"
	ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.GFEA033"	OPERATION 9  ACCESS 0  	// "Copiar"
	ADD OPTION aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.GFEA033" 	OPERATION 8  ACCESS 0   // "Imprimir"
Return aRotina


Static Function ModelDef()
	Local oModel

	oModel := MPFormModel():New("GFEA033", /* */, { |oX| GFEA033VAL( oX ) }, /**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEA033_GUN", Nil, FWFormStruct(1,"GUN"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUN_FILIAL", "GUN_CODTAB"})
	oModel:SetDescription("Tolerâncias de Peso")	
	oModel:SetActivate( {|oMod| GFEA33ACT(oMod)} )
Return oModel


Static Function ViewDef()
	Local oModel  	 := FWLoadModel("GFEA033")
	Local oStruct 	 := FWFormStruct(2,"GUN")
	Local oView   	 := Nil
	Local nX	     := 0
	// Array responsável por identificar os campos que serão exibidos em tela
	Local aCmpQuebra := {'GUN_CODTAB', 'GUN_TPTAB', 'GUN_DUPSEN', 'GUN_DATDE', 'GUN_DATATE', 'GUN_PRIOR', 'GUN_NRCIOR', 'GUN_NRREOR',;
						 'GUN_CDREM', 'GUN_NRCIDS', 'GUN_NRREDS', 'GUN_CDDEST', 'GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP',;
						 'GUN_DSTPOP', 'GUN_CDTPVC', 'GUN_DSTPVC', 'GUN_CDGRP', 'GUN_DSGRP', 'GUN_CDTRP', 'GUN_NMTRP',;
						 'GUN_MODAL', 'GUN_CDCLFR', 'GUN_DSCLFR', 'GUN_MAXQBR'}
	
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField( "GFEA033_GUN" , oStruct, /*cLinkID*/ )	//

	// Realiza a leitura da estrutura do model e retira os campos que não estão definidos no array base
	For nX := Len(oStruct:aFields) To 1 STEP -1
		If ASCAN(aCmpQuebra,oStruct:aFields[nX][1]) == 0
			oStruct:RemoveField(oStruct:aFields[nX][1])
		EndIf		
	Next
Return oView

//-------------------------------------------------------------------
Function GFEA33ACT(oModel)
	Local nOp := oModel:GetOperation()
	
	If nOp == MODEL_OPERATION_INSERT 
		oModel:SetValue("GFEA033_GUN", "GUN_TPTAB", "3")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA033POS
POSICIONE alternativo, desconsiderando campos em branco e buscando sempre a descrição
Uso Geral.

@since 20/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA033POS(cTabela, cValor)
	Local cRet := ""
		
	If Empty(cValor)
		Return ""
	EndIf
	
	If cTabela == "GU3" 
		cRet := POSICIONE("GU3",1,XFILIAL("GU3")+cValor,"GU3_NMEMIT")
	EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA033VAL
Validação do Formulário

@since 20/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA033VAL(oModel)
	Local oValPrazos  := GFEValidaPrazos():New()
	Local nOpc        := (oModel:GetOperation())

	// Valida se a operação é de inclusão ou alteração
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		// "Seta" os dados necessários para execução do método de validação
		oValPrazos:setDataDe(FwFldGet('GUN_DATDE'))
		oValPrazos:setDataAte(FwFldGet('GUN_DATATE'))
		oValPrazos:setCdRem(FwFldGet('GUN_CDREM'))
		oValPrazos:setNrCiOr(FwFldGet('GUN_NRCIOR'))
		oValPrazos:setNrReOr(FwFldGet('GUN_NRREOR'))
		oValPrazos:setCdDest(FwFldGet('GUN_CDDEST'))
		oValPrazos:setNrCiDs(FwFldGet('GUN_NRCIDS'))
		oValPrazos:setNrReDs(FwFldGet('GUN_NRREDS'))
		
		// Executa o método de validação
		oValPrazos:Validar()
		
		// Verificado a situação após a execução
		If oValPrazos:getStatus() == .F.
			// Busca o retorno da execução do método
			Help( ,, 'HELP',, oValPrazos:getMensagem(), 1, 0,)
			oValPrazos:Destroy(oValPrazos)
			Return
		EndIf
		
		oValPrazos:Destroy(oValPrazos)
	EndIf 
Return(.T.)
	