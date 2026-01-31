#INCLUDE "GFEA116.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA116

EDI - Importação da Fatura de Frete

@author Felipe rafael mendes
@since 23/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA116()
	Private oBrowse116
	
	oBrowse116 := FWMarkBrowse():New()
	oBrowse116:SetAlias("GXI")							// Alias da tabela utilizada
	oBrowse116:SetMenuDef("GFEA116")					// Nome do fonte onde esta a função MenuDef
	oBrowse116:SetFieldMark("GXI_MARKBR")
	oBrowse116:SetDescription(STR0001)      	// Descrição do browse      //"Recebimento de Fatura de Frete"
	oBrowse116:SetAllMark({|| GFEA116MARK()})
	
	oBrowse116:AddLegend("GXI_EDISIT == '1'", "BLUE"  , STR0002 ) //Legenda do Browser //"Importado"
	oBrowse116:AddLegend("GXI_EDISIT == '2'", "YELLOW", "Importado com erro") //"Criado"
	oBrowse116:AddLegend("GXI_EDISIT == '3'", "RED"   , STR0004 ) //"Rejeitado"
	oBrowse116:AddLegend("GXI_EDISIT == '4'", "GREEN" , "Processado")
	
	oBrowse116:Activate()                                       

Return(Nil)

//-------------------------------------------------------
//	MenuDef
//-------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 			// "Pesquisar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA116" OPERATION 2 ACCESS 0 			// "Visualizar"
	ADD OPTION aRotina TITLE "Importar" ACTION "GFEA116IMP()" OPERATION 3 ACCESS 0 	// "Importar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA116" OPERATION 4 ACCESS 0 			// "Alterar"
	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA116PRO()"    OPERATION 6 ACCESS 0 	// "Processar"
	// ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.GFEA116" OPERATION 5 ACCESS 0 			// "Excluir"
	ADD OPTION aRotina TITLE "Excluir Sel." ACTION "GFEA116EXC()" 	OPERATION 5 ACCESS 0 	// "Excluir Todos"
	ADD OPTION aRotina TITLE "Selecionar Todos" ACTION "GFEA116MKT()" 	OPERATION 5 ACCESS 0 	// "Selecionar Todos"
	ADD OPTION aRotina TITLE STR0011 ACTION "VIEWDEF.GFEA116" OPERATION 8 ACCESS 0 			// "Imprimir"
Return aRotina

//-------------------------------------------------------
//Função ModelDef
//-------------------------------------------------------
Static Function ModelDef()
	Local oModel 
	Local oStructGXI := FWFormStruct(1,"GXI")
	Local oStructGXJ := FWFormStruct(1,"GXJ")
	
	oModel := MPFormModel():New("GFEA116", /*bPre*/,{ |oX| GFEA116PS( oX ) }/*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields("GFEA116_GXI", Nil, oStructGXI,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("GFEA116_GXJ","GFEA116_GXI",oStructGXJ,/*bLinePre*/,/*{ | oX | GFE103BW( oX ) }*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA116_GXJ",{{"GXJ_FILIAL",'xFilial("GXJ")'},{"GXJ_NRIMP","GXI_NRIMP"}},"GXJ_NRIMP+GXJ_SEQ")     
	oModel:GetModel("GFEA116_GXJ"):SetDelAllLine(.T.) 
	oModel:SetOptional("GFEA116_GXJ", .T. )

Return oModel

//-------------------------------------------------------
//Função viewDef
//-------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA116")
	Local oView 
	Local oStructGXI := FWFormStruct(2,"GXI")
	Local oStructGXJ := FWFormStruct(2,"GXJ")
	
	oStructGXI:RemoveField("GXI_MARKBR")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("GFEA116_GXI", oStructGXI) 
	oView:AddGrid( "GFEA116_GXJ", oStructGXJ)
	
	oView:CreateHorizontalBox( "MASTER" , 55 )
	oView:CreateHorizontalBox( "DETAIL" , 45 )
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0012) //"Documento de Frete"
	
	oView:CreateHorizontalBox( "DETAILFAI"  , 100,,,"IDFOLDER","IDSHEET01" )
	oStructGXJ:RemoveField("GXJ_NRIMP") 
	
	oView:SetOwnerView( "GFEA116_GXI" , "MASTER" )
	oView:SetOwnerView( "GFEA116_GXJ" , "DETAILFAI" )      
	
	// oView:SetCloseOnOk({|| GFEA116PS(oModel, oView)})
Return oView   


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA116EXC
Eliminação dos registros importados selecionados

@author Israel A. Possoli
@since 16/07/12
@version 1.0
/*/
//-------------------------------------------------------------------  
Function GFEA116EXC()
	If !MsgYesNo("Excluir os registros importados selecionados?")
		Return Nil
	EndIf
	
	dbSelectArea("GXI")
	dbGoTop()
	While !GXI->( EOF() )
		If oBrowse116:IsMark(oBrowse116:Mark())
			dbSelectArea("GXJ")
			dbSeek(GXI->GXI_FILIAL + GXI->GXI_NRIMP)
			While !GXJ->( EOF() ) 							.AND.;
				   		  GXJ->GXJ_FILIAL = GXI->GXI_FILIAL .AND. ;
				   		  GXJ->GXJ_NRIMP  = GXI->GXI_NRIMP
				RecLock("GXJ", .F.)
				dbDelete()
				MsUnlock("GXJ")
								
				GXJ->( dbSkip() )
			EndDo
			
			dbSelectArea("GXI")
			RecLock("GXI", .F.)
			dbDelete()
			MsUnlock()	
		EndIf
		GXI->( dbSkip() )
	EndDo
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA116PS
Rotina de Pos validação
Uso Geral.

@author Felipe Rafael Mendes
@since 22/06/10
@version 1.0
/*/
//-------------------------------------------------------------------   
Static Function GFEA116PS(oModel, oView)
Local nOpc := (oModel:GetOperation())  

If nOpc == MODEL_OPERATION_UPDATE
	RecLock("GXI",.F.)
		GXI->GXI_ALTER := "1"
	MsUnlock("GXI")
EndIf 

Return .T.

//------------------------------------------------------------------

Function GFEA116MARK()

	Local aAreaGXI  := GetArea()
	
	dbSelectArea("GXI")
	dbGoTop() 
	
	While !Eof()
		If (GXI_MARKBR <> oBrowse116:Mark())
			RecLock("GXI", .F.)
				GXI->GXI_MARKBR := oBrowse116:Mark()
			MSUnlock()
		ElseIf (GXI_MARKBR == oBrowse116:Mark())
			RecLock("GXI", .F.)
				GXI->GXI_MARKBR := "  "
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aAreaGXI)
	
	oBrowse116:Refresh()
	oBrowse116:GoTop()
	
Return Nil


//-------------------------------/*//*/--------------------------------//

/*-------------------------------------------------------------------
{Protheus.doc} GFEA116MKT
Selecionar Todos

@author Ana Claudia da Silva
@since 22/02/2016
@version 1.0
-------------------------------------------------------------------  */
Function GFEA116MKT()

	Local aAreaGXI  := GetArea()
	
	dbSelectArea("GXI")
	dbGoTop() 
	
	While !Eof()
		If (GXI_MARKBR <> oBrowse116:Mark())
			RecLock("GXI", .F.)
				GXI->GXI_MARKBR := oBrowse116:Mark()
			MSUnlock()
		EndIf
		dbSkip() 
	EndDo
	RestArea(aAreaGXI)
	
	oBrowse116:Refresh()
	oBrowse116:GoTop()
	
Return Nil