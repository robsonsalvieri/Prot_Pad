#INCLUDE "GFEA117.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA117 
EDI - Ocorrencia     

@author Felipe rafael mendes 
@since 23/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
 
Function GFEA117()
	Private oBrowse117 

	/*****************************************************************/  
	oBrowse117 := FWMarkBrowse():New()
	oBrowse117:SetAlias("GXL")					// Alias da tabela utilizada
	oBrowse117:SetMenuDef("GFEA117")			// Nome do fonte onde esta a função MenuDef
	oBrowse117:SetDescription(STR0001)      	// Descrição do browse      //"Recebimento de Ocorrencia"
	oBrowse117:SetFieldMark("GXL_MARKBR")
	oBrowse117:SetAllMark({|| GFEA117MARK()})
	
	oBrowse117:AddLegend("GXL_EDISIT == '1'", "BLUE"  , STR0002 ) //Legenda do Browser //"Importado"
	oBrowse117:AddLegend("GXL_EDISIT == '2'", "YELLOW", "Importado com erro")
	oBrowse117:AddLegend("GXL_EDISIT == '3'", "RED"   , STR0004 ) //"Rejeitado"
	oBrowse117:AddLegend("GXL_EDISIT == '4'", "GREEN" , "Processado") //"Modificado"*/
	
	oBrowse117:Activate()                                       
Return(Nil)

//-------------------------------------------------------
//	MenuDef
//-------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0006 		 ACTION "AxPesqui"         	OPERATION 1 ACCESS 0	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0007 		 ACTION "VIEWDEF.GFEA117"   OPERATION 2 ACCESS 0 	// "Visualizar"
	ADD OPTION aRotina TITLE "Importar" 	 ACTION "GFEA117IMP()"    	OPERATION 3 ACCESS 0 	// "Importar"
	ADD OPTION aRotina TITLE STR0009 		 ACTION "GFEA117PRO()" 		OPERATION 4 ACCESS 0 	// "Processar"
	ADD OPTION aRotina TITLE STR0008 		 ACTION "VIEWDEF.GFEA117"   OPERATION 4 ACCESS 0 	// "Alterar"
	ADD OPTION aRotina TITLE STR0010 		 ACTION "VIEWDEF.GFEA117"   OPERATION 5 ACCESS 0 	// "Excluir"
	ADD OPTION aRotina TITLE "Excluir Sel."  ACTION "GFEA117EXC()" 		OPERATION 5 ACCESS 0 	// "Excluir Todos"
	ADD OPTION aRotina TITLE "Selecionar Todos"  ACTION "GFEA117MKT()" 	OPERATION 5 ACCESS 0 	// "Selecionar Todos"
	ADD OPTION aRotina TITLE STR0011 		 ACTION "VIEWDEF.GFEA117"   OPERATION 8 ACCESS 0 	// "Imprimir"
Return aRotina

//-------------------------------------------------------
//	ModelDef
//-------------------------------------------------------
Static Function ModelDef()
	Local oModel 
	Local oStructGXL := FWFormStruct(1,"GXL")

	oModel := MPFormModel():New("GFEA117", /*bPre*/,/*{ |oX| GFEA117PS( oX ) }*//*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields("GFEA117_GXL", Nil, oStructGXL,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GXL_NRIMP"}) 
Return oModel

//-------------------------------------------------------
//Função viewDef
//-------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA117")
	Local oStructGXL := FWFormStruct(2,"GXL")
	Local oView
	
	oStructGXL:RemoveField("GXL_MARKBR")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA117_GXL" , oStructGXL ) 

	oView:CreateHorizontalBox( "MASTER" , 100 )
	oView:SetOwnerView( "GFEA117_GXL" , "MASTER" )
	oView:SetCloseOnOk({|| GFEA117PS(oModel, oView)})
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115EXC
Eliminação de todos os movimentos importados

@author Israel A. Possoli
@since 11/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA117EXC()
	Local cMarca := oBrowse117:Mark()
	
	If !MsgYesNo("Excluir os registros importados selecionados?")
		Return Nil
	EndIf
	
	dbSelectArea("GXL")
	dbGoTop()
	oBrowse117:ExecuteFilter(.T.)
	While !GXL->( EOF() )
		If oBrowse117:IsMark(cMarca)
			RecLock("GXL", .F.)
			dbDelete()
			MsUnlock("GXL")
		EndIf
		GXL->(dbSkip())
	EndDo
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA117PS
Rotina de Pos validação
Uso Geral.

@author Felipe Rafael Mendes
@since 22/06/10
@version 1.0
/*/
//-------------------------------------------------------------------   
Static Function GFEA117PS(oModel, oView)
Local nOpc := (oModel:GetOperation())  

If nOpc == MODEL_OPERATION_UPDATE .And. oView:lModify
	RecLock("GXL",.F.)
		GXL->GXL_ALTER := "1"
	MsUnlock("GXL")
EndIf 
Return .F.
     
//------------------------------------------------------------------

Function GFEA117MARK()

	Local aAreaGXL  := GetArea()
	
	dbSelectArea("GXL")
	dbGoTop() 
	
	While !Eof()
		If (GXL_MARKBR <> oBrowse117:Mark())
			RecLock("GXL", .F.)
				GXL->GXL_MARKBR := oBrowse117:Mark()
			MSUnlock()
		ElseIf (GXL_MARKBR == oBrowse117:Mark())
			RecLock("GXL", .F.)
				GXL->GXL_MARKBR := "  "
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aAreaGXL)
	
	oBrowse117:Refresh()
	oBrowse117:GoTop()
	
Return Nil


//-------------------------------/*//*/--------------------------------//
/*-------------------------------------------------------------------
{Protheus.doc} GFEA117MKT
Selecionar Todos

@author Ana Claudia da Silva
@since 22/02/2016
@version 1.0
-------------------------------------------------------------------  */
Function GFEA117MKT()
	Local aAreaGXL  := GetArea()
	Local cAliasGXL := oBrowse117:Alias()
	Local cFiltro	:= oBrowse117:oBrowse:CESPFILTER

	If !Empty(cFiltro) // SELECIONA TODOS COM BASE NO FILTRO DO INDICE DA TABELA
		cFiltro := "%" + cFiltro + "%"
		cAliasFilter := GetNextAlias()
		BeginSql Alias cAliasFilter
			SELECT GXL.R_E_C_N_O_ RECNOGXL
			FROM %Table:GXL% GXL
			WHERE %Exp:cFiltro%
			AND GXL.%NotDel%
		EndSql
		Do While (cAliasFilter)->(!Eof())
			GXL->(dbGoTo((cAliasFilter)->RECNOGXL))
			If (GXL->GXL_MARKBR <> oBrowse117:Mark())
				RecLock("GXL", .F.)
					GXL->GXL_MARKBR := oBrowse117:Mark()
				GXL->(MsUnlock())
			EndIf
			(cAliasFilter)->(dbSkip())
		EndDo
		(cAliasFilter)->(dbCloseArea())
	Else 
		oBrowse117:ExecuteFilter(.T.) // SELECIONA TODOS COM BASE NO FILTRO PADRÃO
		(cAliasGXL)->(dbGoTop())
		Do While (cAliasGXL)->(!Eof())
			If (GXL->GXL_MARKBR <> oBrowse117:Mark())
				RecLock("GXL", .F.)
					GXL->GXL_MARKBR := oBrowse117:Mark()
				GXL->(MsUnlock())
			EndIf
			(cAliasGXL)->(dbSkip())
		EndDo
	EndIf 
	RestArea(aAreaGXL)
	oBrowse117:Refresh(.T.)
	oBrowse117:GoTop()
Return Nil
