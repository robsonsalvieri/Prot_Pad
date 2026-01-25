#INCLUDE "GFEA115.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115

EDI - Importação do Documento de Frete 

@author Felipe rafael mendes
@since 23/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA115()
	Private oBrowse115
	
	oBrowse115 := FWMarkBrowse():New()
	oBrowse115:SetAlias("GXG")
	oBrowse115:SetMenuDef("GFEA115")
	oBrowse115:SetFieldMark("GXG_MARKBR")
	oBrowse115:SetDescription(STR0001)		// "Recebimento de Documento de Frete"
	oBrowse115:SetAllMark({|| GFEA115MARK()})
	
	oBrowse115:SetFilterDefault("GXG_ORIGEM == '1'")
	
	oBrowse115:AddLegend("GXG_EDISIT == '1'", "BLUE"  , STR0002 ) 	// "Importado"
	oBrowse115:AddLegend("GXG_EDISIT == '2'", "YELLOW", "Importado com erro")
	oBrowse115:AddLegend("GXG_EDISIT == '3'", "RED"   , STR0004 ) 	// "Rejeitado"
	oBrowse115:AddLegend("GXG_EDISIT == '4'", "GREEN" , "Processado")
	
	oBrowse115:Activate()

Return(Nil)

//-------------------------------------------------------
//	MenuDef
//-------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        		OPERATION 1 ACCESS 0 	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA115" 		OPERATION 2 ACCESS 0 	// "Visualizar"
	ADD OPTION aRotina TITLE "Importar" ACTION "GFEA115IMP()"    	OPERATION 3 ACCESS 0 	// "Importar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA115" 		OPERATION 4 ACCESS 0 	// "Alterar"
	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA115PRO()"    		OPERATION 4 ACCESS 0 	// "Processar"
	// ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.GFEA115" 		OPERATION 5 ACCESS 0 	// "Excluir"
	ADD OPTION aRotina TITLE "Excluir Sel." ACTION "GFEA115PrE()" 	OPERATION 5 ACCESS 0 	// "Excluir Todos"
	ADD OPTION aRotina TITLE "Selecionar Todos" ACTION "GFEA115MKT()" 	OPERATION 5 ACCESS 0 	// "Selecionar Todos"	
	ADD OPTION aRotina TITLE STR0011 ACTION "VIEWDEF.GFEA115" 		OPERATION 8 ACCESS 0	// "Imprimir"
Return aRotina

//-------------------------------------------------------
//Função ModelDef
//-------------------------------------------------------
Static Function ModelDef()
	Local oModel 
	Local oStructGXG := FWFormStruct(1,"GXG")
	Local oStructGXH := FWFormStruct(1,"GXH")

	oStructGXH:SetProperty("GXH_NRIMP", MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= GXG->GXG_NRIMP,FWCloseCpo(a,b,c,.t.),lRetorno } )
	oModel := MPFormModel():New("GFEA115", /*bPre*/,/*{ |oX| GFEA115PS( oX ) }*//*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields("GFEA115_GXG", Nil, oStructGXG,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("GFEA115_GXH","GFEA115_GXG",oStructGXH,/*bLinePre*/,/*{ | oX | GFE103BW( oX ) }*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA115_GXH",{{"GXH_FILIAL",'xFilial("GXG")'},{"GXH_NRIMP","GXG_NRIMP"}},"GXH_NRIMP+GXH_SEQ")     
	oModel:GetModel("GFEA115_GXH"):SetDelAllLine(.T.) 
	oModel:SetOptional("GFEA115_GXH", .T. )
	oModel:SetActivate({|oMod| })
Return oModel

//-------------------------------------------------------
//Função ViewDef
//-------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA115")
	Local oView 
	Local oStructGXG := FWFormStruct(2,"GXG")
	Local oStructGXH := FWFormStruct(2,"GXH")
	
	oStructGXG:RemoveField("GXG_MARKBR")

	// Campos não utilizados no CONEMB
	If GFXCP12131("GXG_MUNINI")
		oStructGXG:RemoveField("GXG_MUNINI")
		oStructGXG:RemoveField("GXG_UFINI")
		oStructGXG:RemoveField("GXG_MUNFIM")
		oStructGXG:RemoveField("GXG_UFFIM")
	EndIf

	If GFXCP2510("GXG_XMLTRB")
		oStructGXG:RemoveField("GXG_XMLTRB")
	EndIf
	
	oStructGXH:RemoveField("GXH_CNPJEM")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA115_GXG" , oStructGXG ) 
	oView:AddGrid( "GFEA115_GXH" , oStructGXH )
	
	
	oView:CreateHorizontalBox( "MASTER" , 55 )
	oView:CreateHorizontalBox( "DETAIL" , 45 )
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0012) //"Doc Carga"
	
	oView:CreateHorizontalBox( "DETAILFAI"  , 100,,,"IDFOLDER","IDSHEET01" )
	oStructGXH:RemoveField("GXH_NRIMP") 
	
	oView:AddIncrementField("GFEA115_GXH","GXH_SEQ")
	
	oView:SetOwnerView( "GFEA115_GXG" , "MASTER" )
	oView:SetOwnerView( "GFEA115_GXH" , "DETAILFAI" )      
	
	oView:SetCloseOnOk({|| GFEA115PS(oModel, oView)})
Return oView   


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115PS
Rotina de Pos validação
Uso Geral.

@author Felipe Rafael Mendes
@since 22/06/10
@version 1.0
/*/
//-------------------------------------------------------------------   
Static Function GFEA115PS(oModel, oView)
	Local nOpc := (oModel:GetOperation())  
	
	If nOpc == MODEL_OPERATION_UPDATE .And. oView:lModify
		RecLock("GXG",.F.)
			GXG->GXG_ALTER := "1"
		MsUnlock("GXG")
	EndIf 
Return .F. 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115PrE
Processa Exclusão dos registros

@author Fabio Marchiori Sampaio
@since 19/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------  
Function GFEA115PrE()
	
	If MsgYesNo("Excluir os registros importados selecionados?")
		FwMsgRun( , { || lRet := GFEA115EXC() }  , ,  'Excluindo registros selecionados...' )
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115EXC
Eliminação dos registros importados selecionados

@author Israel A. Possoli
@since 26/06/12
@version 1.0
/*/
//-------------------------------------------------------------------  
Static Function GFEA115EXC()
	Local cAliasGXG := GetNextAlias()
	Local cAliasGXH := GetNextAlias()
	
	// Busca registro do doc de frete
	BeginSql Alias cAliasGXG
		SELECT GXG.R_E_C_N_O_ RECNOGXG,
			   GXG.GXG_FILIAL,
			   GXG.GXG_NRIMP
		FROM %Table:GXG% GXG
		WHERE GXG.GXG_FILIAL = %xFilial:GXG%
		AND   GXG.GXG_MARKBR = %Exp:oBrowse115:Mark()%
		AND   GXG.%NotDel%
	EndSql	

	//  Busca doc de carga relacionado ao doc de frete
	BeginSql Alias cAliasGXH
		SELECT GXG.GXG_FILIAL,
			GXG.GXG_NRIMP,
			GXH.GXH_FILIAL,
			GXH.GXH_NRIMP,
			GXH.GXH_SEQ
		FROM %Table:GXG% GXG
		INNER JOIN %Table:GXH% GXH
		ON    GXH.GXH_FILIAL = GXG.GXG_FILIAL
		AND   GXH.GXH_NRIMP  = GXG.GXG_NRIMP
		AND   GXH.%NotDel%
		WHERE GXG.GXG_FILIAL = %xFilial:GXG%
		AND   GXG.GXG_MARKBR = %Exp:oBrowse115:Mark()%
		AND   GXG.%NotDel%
	EndSql	

	Do While (cAliasGXG)->(!Eof())

		// Remove o Documento de carga
		While (cAliasGXH)->(!Eof()) 
			GXH->(dbSetOrder(1))
			GXH->(dbSeek((cAliasGXH)->GXH_FILIAL + (cAliasGXH)->GXH_NRIMP + (cAliasGXH)->GXH_SEQ))
			RecLock("GXH", .F.)
				GXH->(dbDelete())
			GXH->(MsUnlock())
		(cAliasGXH)->(dbSkip())
		EndDo
		
		// Remove o documento de frete
		GXG->(dbGoTo((cAliasGXG)->RECNOGXG))
			RecLock("GXG", .F.)
				GXG->(dbDelete())
			GXG->(MsUnlock())					
		(cAliasGXG)->(dbSkip())
	EndDo
	(cAliasGXH)->(dbCloseArea())
	(cAliasGXG)->(dbCloseArea())
	
	oBrowse115:Refresh()
	oBrowse115:GoTop(.T.)
Return

/*-------------------------------------------------------------------
{Protheus.doc} GFEA115VL
Rotina para exclusão dos relacionamentos do documento de frete com documento de carga
Uso Geral.

@author Octávio Augusto Felippe de Macedo
@since 23/02/2011
@version 1.0
-------------------------------------------------------------------  */
Static Function GFEA115VL(oModel)
Local nOpc := (oModel:GetOperation())  

If nOpc == MODEL_OPERATION_DELETE

	dbSelectArea("GXH")
	GXH->( dbSetOrder(1) )
	GXH->( dbSeek(xFilial("GXH") + GXG->GXG_NRIMP) )
	While !GXH->( Eof() ) .And. GXH->GXH_FILIAL == xFilial("GXH") .And. GXH->GXH_NRIMP == GXG->GXG_NRIMP
		RecLock("GXH",.F.)
			dbDelete()
		MsUnlock("GXH")  
		dbSelectArea("GXH")
		GXH->( dbSkip() )
	EndDo
EndIf 

Return .F. 

//------------------------------------------------------------------

Function GFEA115MARK()

	Local aAreaGXG  := GetArea()
	
	dbSelectArea("GXG")
	dbGoTop() 
	
	While !Eof()
		If (GXG_MARKBR <> oBrowse115:Mark())
			RecLock("GXG", .F.)
				GXG->GXG_MARKBR := oBrowse115:Mark()
			MSUnlock()
		ElseIf (GXG_MARKBR == oBrowse115:Mark())
			RecLock("GXG", .F.)
				GXG->GXG_MARKBR := "  "
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aAreaGXG)
	
	oBrowse115:Refresh()
	oBrowse115:GoTop()
	
Return Nil


//-------------------------------/*//*/--------------------------------//

/*-------------------------------------------------------------------
{Protheus.doc} GFEA115MKT
Selecionar Todos

@author Ana Claudia da Silva
@since 22/02/2016
@version 1.0
-------------------------------------------------------------------  */
Function GFEA115MKT()

	Local aAreaGXG  := GetArea()


	dbSelectArea("GXG")
	dbGoTop() 
	
	While !Eof()
		If (GXG_MARKBR <> oBrowse115:Mark())
			RecLock("GXG", .F.)
				GXG->GXG_MARKBR := oBrowse115:Mark()
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aAreaGXG)
	
	oBrowse115:Refresh()
	oBrowse115:GoTop()
	
Return Nil
