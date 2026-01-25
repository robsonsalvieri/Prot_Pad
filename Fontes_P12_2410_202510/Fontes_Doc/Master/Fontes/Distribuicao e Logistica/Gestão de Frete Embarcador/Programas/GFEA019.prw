#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA019
Cadastro de Tabelas de Prazos 
Uso Geral.

@author Israel A. Possoli
@since 06/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA019() 
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUN")
	oBrowse:SetMenuDef("GFEA019")
	oBrowse:SetDescription("Cadastro de Prazos de Entrega")
	oBrowse:SetFilterDefault("GUN_TPTAB == '1'")
	oBrowse:SetOnlyFields( { 'GUN_CODTAB', 'GUN_TPTAB','GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP', 'GUN_CDTPVC', 'GUN_CDGRP', 'GUN_CDTRP', 'GUN_MODAL', 'GUN_CDCLFR', 'GUN_TPPRAZ', 'GUN_PRAZO','GUN_NMTRP'} )
  
	oBrowse:Activate()
Return(Nil)


Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "AxPesqui"        	OPERATION 1  ACCESS 0  	// "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.GFEA019" 	OPERATION 2  ACCESS 0  	// "Visualizar"
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.GFEA019" 	OPERATION 3  ACCESS 0  	// "Incluir"
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.GFEA019" 	OPERATION 4  ACCESS 0  	// "Alterar"
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.GFEA019" 	OPERATION 5  ACCESS 0  	// "Excluir"
	ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.GFEA019"	OPERATION 9  ACCESS 0  	// "Copiar"
	ADD OPTION aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.GFEA019" 	OPERATION 8  ACCESS 0   // "Imprimir"
Return aRotina


Static Function ModelDef()
	Local oModel

	oModel := MPFormModel():New("GFEA019", /* */, { |oX| GFEA019VAL( oX ) }, /**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEA019_GUN", Nil, FWFormStruct(1,"GUN"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUN_FILIAL", "GUN_CODTAB"})
	oModel:SetDescription("Prazos de Entrega")	
Return oModel


Static Function ViewDef()
	Local oModel  	:= FWLoadModel("GFEA019")
	Local oStruct 	:= FWFormStruct(2,"GUN")
	Local oView   	:= Nil
	Local nX	  	:= 0
	// Array responsável por identificar os campos que serão exibidos em tela
	Local aCmpPrazo := {'GUN_CODTAB', 'GUN_TPTAB', 'GUN_DUPSEN', 'GUN_DATDE', 'GUN_DATATE', 'GUN_PRIOR', 'GUN_NRCIOR', 'GUN_NRREOR',;
					    'GUN_CDREM', 'GUN_NRCIDS', 'GUN_NRREDS', 'GUN_CDDEST', 'GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP',;
						'GUN_DSTPOP', 'GUN_CDTPVC', 'GUN_DSTPVC', 'GUN_CDGRP', 'GUN_DSGRP', 'GUN_CDTRP', 'GUN_NMTRP',;
						'GUN_MODAL', 'GUN_CDCLFR', 'GUN_DSCLFR', 'GUN_TPPRAZ', 'GUN_PRAZO'}

	Private lGFEA019 := ExistBlock("GFEA0191")

	If lGFEA019
		aRetPE := ExecBlock("GFEA0191",.f.,.f.,{aCmpPrazo})
		If ValType(aRetPE) == "A"
			aCmpPrazo := aRetPE
		EndIf
	EndIf	
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField( "GFEA019_GUN" , oStruct, /*cLinkID*/ )	//

	// Realiza a leitura da estrutura do model e retira os campos que não estão definidos no array base
	For nX := Len(oStruct:aFields) To 1 STEP -1
		If ASCAN(aCmpPrazo,oStruct:aFields[nX][1]) == 0
			oStruct:RemoveField(oStruct:aFields[nX][1])
		EndIf		
	Next	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA19BIRO
Retorna a informação descritiva da rota de origem
Uso Geral.

@author Israel A. Possoli
@since 07/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA19BIRO()
	Local cRet := ""
	
	If !Empty(GUN->GUN_CDREM)
		cRet += "Remetente: " + POSICIONE("GU3",1,XFILIAL("GU3")+GUN->GUN_CDREM,"GU3_NMEMIT") 
	ElseIf !Empty(GUN->GUN_NRCIOR)
		cRet += "Cidade: " + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GUN->GUN_NRCIOR,"GU7_NMCID")) + "/" + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GUN->GUN_NRCIOR,"GU7_CDUF"))
	ElseIf !Empty(GUN->GUN_NRREOR)
		cRet += "Região: " + POSICIONE("GU9",1,XFILIAL("GU9")+GUN->GUN_NRREOR,"GU9_NMREG")
	Else
		cRet := ""
	EndIf

Return cRet

Function GFEA019IRO()
	GFEA19IRO()
Return

Function GFEA019IRD()
	GFEA19IRD()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA19IRO
Retorna a informação descritiva da rota de origem
Uso Geral.

@author Israel A. Possoli
@since 07/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA19IRO()
	Local cRet := ""
	
	If !Empty(M->GUN_CDREM)
		cRet += "Remetente: " + POSICIONE("GU3",1,XFILIAL("GU3")+M->GUN_CDREM,"GU3_NMEMIT") 
	ElseIf !Empty(M->GUN_NRCIOR)
		cRet += "Cidade: " + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+M->GUN_NRCIOR,"GU7_NMCID")) + "/" + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+M->GUN_NRCIOR,"GU7_CDUF"))
	ElseIf !Empty(M->GUN_NRREOR)
		cRet += "Região: " + POSICIONE("GU9",1,XFILIAL("GU9")+M->GUN_NRREOR,"GU9_NMREG")
	Else
		cRet := ""
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA19BIRD
Retorna a informação descritiva da rota de destino
Uso Geral.

@author Israel A. Possoli
@since 07/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA19BIRD()
	Local cRet := ""
	
	If !Empty(GUN->GUN_CDDEST)
		cRet += "Destinatário: " + POSICIONE("GU3",1,XFILIAL("GU3")+GUN->GUN_CDDEST,"GU3_NMEMIT")
	ElseIF !Empty(GUN->GUN_NRCIDS)
		cRet += "Cidade: " + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GUN->GUN_NRCIDS,"GU7_NMCID")) + "/" + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GUN->GUN_NRCIDS,"GU7_CDUF"))
	ElseIf !Empty(GUN->GUN_NRREDS)
		cRet += "Região: " + POSICIONE("GU9",1,XFILIAL("GU9")+GUN->GUN_NRREDS,"GU9_NMREG")
	Else
		cRet := ""
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA19IRD
Retorna a informação descritiva da rota de destino
Uso Geral.

@author Israel A. Possoli
@since 07/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA19IRD()
	Local cRet := ""
	
	If !Empty(M->GUN_CDDEST)
		cRet += "Destinatário: " + POSICIONE("GU3",1,XFILIAL("GU3")+M->GUN_CDDEST,"GU3_NMEMIT")
	ElseIF !Empty(M->GUN_NRCIDS)
		cRet += "Cidade: " + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+M->GUN_NRCIDS,"GU7_NMCID")) + "/" + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+M->GUN_NRCIDS,"GU7_CDUF"))
	ElseIf !Empty(M->GUN_NRREDS)
		cRet += "Região: " + POSICIONE("GU9",1,XFILIAL("GU9")+M->GUN_NRREDS,"GU9_NMREG")
	Else
		cRet := ""
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA019POS
POSICIONE alternativo, desconsiderando campos em branco e buscando sempre a descrição
Uso Geral.

@author Israel A. Possoli
@since 07/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA019POS(cTabela, cValor)
	Local cRet := ""
	
	If Empty(cValor)
		Return ""
	EndIf
	
	If cTabela == "GU3" 
		cRet := POSICIONE("GU3",1,XFILIAL("GU3")+cValor,"GU3_NMEMIT")
	EndIf

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA019VAL
Validação do Formulário

@author Israel A. Possoli
@since 14/02/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA019VAL(oModel)
	Local oValPrazos  := GFEValidaPrazos():New()
	Local nOpc     	  := (oModel:GetOperation())
	
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
	