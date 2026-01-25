#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA022
Cadastro de Distância entre Cidades
Uso Geral.

@author Jefferson Hita
@since 12/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA022() 
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUN")
	oBrowse:SetMenuDef("GFEA022")
	oBrowse:SetDescription("Cadastro de Distância entre Cidades")
	oBrowse:SetFilterDefault("GUN_TPTAB == '2'")
	oBrowse:SetOnlyFields( { 'GUN_CODTAB', 'GUN_TPTAB', 'GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP', 'GUN_CDTPVC', 'GUN_CDGRP', 'GUN_CDTRP', 'GUN_MODAL', 'GUN_CDCLFR','GUN_DMEST'} )
  
	oBrowse:Activate()
Return(Nil)

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "AxPesqui"        	OPERATION 1  ACCESS 0  	// "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.GFEA022" 	OPERATION 2  ACCESS 0  	// "Visualizar"
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.GFEA022" 	OPERATION 3  ACCESS 0  	// "Incluir"
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.GFEA022" 	OPERATION 4  ACCESS 0  	// "Alterar"
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.GFEA022" 	OPERATION 5  ACCESS 0  	// "Excluir"
	ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.GFEA022"	OPERATION 9  ACCESS 0  	// "Copiar"
	ADD OPTION aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.GFEA022" 	OPERATION 8  ACCESS 0   // "Imprimir"
Return aRotina

Static Function ModelDef()
	Local oModel

	oModel := MPFormModel():New("GFEA022", /* */, { |oX| GFEA022VAL( oX ) }, /**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEA022_GUN", Nil, FWFormStruct(1,"GUN"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUN_FILIAL", "GUN_CODTAB"})
	oModel:SetDescription("Distância entre Cidades")
	oModel:SetActivate( {|oMod| GFEA22ACT(oMod)} )
Return oModel

Static Function ViewDef()
	Local nX	  	:= 0
	Local oView   	:= Nil
	Local oModel  	:= FWLoadModel("GFEA022")
	Local oStruct 	:= FWFormStruct(2,"GUN")
	// Array responsável por identificar os campos que serão exibidos em tela
	Local aCmpKM := {'GUN_CODTAB', 'GUN_TPTAB' , 'GUN_DUPSEN', 'GUN_DATDE' , 'GUN_DATATE', 'GUN_PRIOR' , 'GUN_NRCIOR',;
					    'GUN_NRCIDS', 'GUN_INFRTO', 'GUN_INFRTD', 'GUN_CDTPOP', 'GUN_DSTPOP', 'GUN_CDTPVC', 'GUN_DSTPVC',;
						'GUN_CDGRP' , 'GUN_DSGRP' , 'GUN_CDTRP' , 'GUN_NMTRP' , 'GUN_MODAL' , 'GUN_CDCLFR', 'GUN_DSCLFR',;
						'GUN_DMEST'}
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField( "GFEA022_GUN" , oStruct, /*cLinkID*/ )	//

	// Realiza a leitura da estrutura do model e retira os campos que não estão definidos no array base
	For nX := Len(oStruct:aFields) To 1 STEP -1
		If ASCAN(aCmpKM,oStruct:aFields[nX][1]) == 0
			oStruct:RemoveField(oStruct:aFields[nX][1])
		EndIf		
	Next	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA022VAL
Validação do Formulário

@author Jefferson Hita
@since 12/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA022VAL(oModel)
	Local nOpc     	  := oModel:GetOperation()
	Local oValDist  := GFEValidaPrazos():New()

	// Valida se a operação é de inclusão ou alteração
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		// "Seta" os dados necessários para execução do método de validação
		oValDist:setDataDe(FwFldGet('GUN_DATDE'))
		oValDist:setDataAte(FwFldGet('GUN_DATATE'))
		oValDist:setCdRem(FwFldGet('GUN_CDREM'))
		oValDist:setNrCiOr(FwFldGet('GUN_NRCIOR'))
		oValDist:setNrReOr(FwFldGet('GUN_NRREOR'))
		oValDist:setCdDest(FwFldGet('GUN_CDDEST'))
		oValDist:setNrCiDs(FwFldGet('GUN_NRCIDS'))
		oValDist:setNrReDs(FwFldGet('GUN_NRREDS'))

		// Executa o método de validação
		oValDist:Validar()

		// Verificado a situação após a execução
		If oValDist:getStatus() == .F.
			// Busca o retorno da execução do método
			Help( ,, 'HELP',, oValDist:getMensagem(), 1, 0,)
			oValDist:Destroy(oValDist)
			Return
		EndIf

		oValDist:Destroy(oValDist)
	EndIf

Return(.T.)

//-------------------------------------------------------------------
Function GFEA22ACT(oModel)
	Local nOp := oModel:GetOperation()

	If nOp == MODEL_OPERATION_INSERT
		oModel:SetValue("GFEA022_GUN", "GUN_TPTAB", "2")
	EndIf
Return
