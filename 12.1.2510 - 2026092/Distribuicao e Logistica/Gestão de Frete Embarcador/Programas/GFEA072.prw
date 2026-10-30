#INCLUDE "GFEA070.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

 
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA072
Digitação de Faturas de Frete  
Generico

@sample
GFEA072()

/*///------------------------------------------------------------------------------------------------
Function GFEA072()
	Private oBrowse
	Private lCopy := .F.

	// Função indisponível para ajuste de usabilidade
	//DLOGGFE-11383 - removida trava

	oBrowse := FWMarkBrowse():New()	

	oBrowse:SetAlias("GW6")							             // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA072")					             // Nome do fonte onde esta a função MenuDef
	oBrowse:SetFieldMark("GW6_MARKBR")
	oBrowse:SetDescription(STR0001)	 // Descrição do browse      //"Faturas de Frete"
	oBrowse:SetAllMark({|| GFEA72MARK()})
	
	GFEA72LIB()

	oBrowse:AddLegend("GW6_SITAPR == '1'", "BLACK" , STR0002) //Legenda do Browser //"Recebida"
	oBrowse:AddLegend("GW6_SITAPR == '2'", "RED"   , STR0003) //"Bloqueado"
	oBrowse:AddLegend("GW6_SITAPR == '3'", "GREEN" , STR0004) //"Aprovada Sistema"
	oBrowse:AddLegend("GW6_SITAPR == '4'", "BLUE"  , STR0005) //"Aprovada Usuario"
	
	oBrowse:Activate()
Return(Nil)

Static Function MenuDef()
	Local aRotina := {}
	Local aArea := GetArea()

	ADD OPTION aRotina TITLE STR0007 ACTION "GFEA070CC()"     OPERATION 2  ACCESS 0	// "Visualizar"
	ADD OPTION aRotina TITLE "Atualizar Financeiro ERP"	ACTION "GFEA072AT()" OPERATION 6 ACCESS 0 // "Atualizar Financeiro ERP"
	ADD OPTION aRotina TITLE "Desatualiz Financeiro ERP" ACTION "GFEA072DE()" OPERATION 7 ACCESS 0 // "Desatualiz Financeiro ERP"
	ADD OPTION aRotina TITLE "Atualizar Doc Frete Fiscal ERP" ACTION "GFEA072AD()" OPERATION 8 ACCESS 0 // "Atualizar Doc Frete Fiscal ERP"
	
	RestArea(aArea)
Return aRotina

//-------------------------------------------------------------------------------------------------
Static Function GFEA72MARK()
	Local aAreaGW6  := GetArea()
	
	GW6->(dbGoTop())
	While !GW6->(EoF())
		If (GW6->GW6_MARKBR <> oBrowse:Mark())				
			RecLock("GW6", .F.)
				GW6->GW6_MARKBR := oBrowse:Mark()
			GW6->( MsUnlock() )
		ElseIf (GW6->GW6_MARKBR == oBrowse:Mark())		
			RecLock("GW6", .F.)
				GW6->GW6_MARKBR := " "
			GW6->( MsUnlock() )
		EndIf
		GW6->(dbSkip())
	EndDo
	RestArea(aAreaGW6)
	
	oBrowse:Refresh()
	oBrowse:GoTop()
Return Nil

Function GFEA072AT()
	Local dDtVen	:= NIL
	Local cTxtAP	:= ""
	Local aRet		:= {}
	Local cGW6Pro	:= GetNextAlias()
	local dData		:= DDatabase
	Local lDatasul 	:= SuperGetMV('MV_ERPGFE',,'') == "1"
	
	dDtVen := GFEA072DT()
	If dDtVen == NIL
		Alert("Data de vencimento não informada")
		GFEA072MK()
		Return
	EndIf
		
	cQuery := "SELECT R_E_C_N_O_, GW6.GW6_NRFAT FROM " + RetSQLName("GW6") + " GW6 "
	cQuery += " WHERE GW6.D_E_L_E_T_ = ' ' "
	cQuery += "   AND (GW6.GW6_MARKBR = '" + oBrowse:Mark() + "' )"
	cQuery += " ORDER BY R_E_C_N_O_ "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW6Pro, .F., .T.)

	(cGW6Pro)->( dbGoTop() )

	GW6->( dbSetOrder(1) )
	GW6->( dBGoTop() )
	
	While !(cGW6Pro)->( Eof() )
		GW6->(DBGoTo((cGW6Pro)->R_E_C_N_O_) )						

        If GW6->GW6_DTEMIS > dDtVen .And. !Empty(dDtVen)
        	Alert( "Data de vencimento da fatura " + GW6->GW6_NRFAT + " deve ser maior que a data de emissão")
        Else
        	RecLock("GW6", .F.)  
        		GW6->GW6_DTVENC := dDtVen 
        	GW6->( MsUnlock() )
	        	
			aRet := GFEA070X(.F.,.F.)
			
			If lDatasul
				If aRet[1]
					cTxtAP += "Fatura " + GW6->GW6_NRFAT + " enviada para atualização no Financeiro." + CRLF	    
			    Else
			    	cTxtAP += "Fatura " + GW6->GW6_NRFAT + " não foi enviada para atualização no Financeiro por causa do seguinte erro: " + aRet[2][6] + CRLF
			    EndIf		
		    EndIf 		        	
        EndIf 		
	
	    (cGW6Pro)->( dbSkip() )
	EndDo
	(cGW6Pro)->( dbCloseArea() )		
	//DLOGGFE-11383 mensagem só é apresentada se for integrado com datasul
	If !Empty(cTxtAP) .and. lDatasul
		MsgInfo(cTxtAP)
	EndIf
	
	GFEA072MK()
Return

//Os registros que estiverem com checkbox marcado chamarão as funções de desatualização
Function GFEA072DE()
	Local cTxtAP	:= ""
	Local cGW6Pro	:= GetNextAlias()
	Local aRetVld	:= {}
	Local aRetDes	:= {}
	Local cERPGFE	:= SuperGetMV("MV_ERPGFE",,"1")
	
	If !MsgNoYes("Deseja desatualizar a Fatura no Financeiro?", "Aviso")
		Return
	EndIf	
	
	cQuery := "SELECT R_E_C_N_O_, GW6.GW6_NRFAT FROM " + RetSQLName("GW6") + " GW6 "
	cQuery += " WHERE GW6.D_E_L_E_T_ = ' ' "
	cQuery += "   AND (GW6.GW6_MARKBR = '" + oBrowse:Mark() + "' )"
	cQuery += " ORDER BY R_E_C_N_O_ "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW6Pro, .F., .T.)

	(cGW6Pro)->( dbGoTop() )

	GW6->( dbSetOrder(1) )
	GW6->( dBGoTop() )
	
	While !(cGW6Pro)->( Eof() )
		GW6->(DBGoTo((cGW6Pro)->R_E_C_N_O_) )	

		aRetVld := VldDesAtuFatura()

		If aRetVld[1] == .T.
			RecLock("GW6",.F.)
				GW6->GW6_SITFIN := "5" // Pendente Desatualização
				GW6->GW6_USUFIN := cUserName
			GW6->(MsUnLock())

			If cERPGFE == "1"
				cTxtAP += "Fatura " + GW6->GW6_NRFAT + " enviada para desatualização no Financeiro." + CRLF
			ElseIf cERPGFE == "2"
				aRetDes := DesAtuFatura()
				If aRetDes[1] //Desatualização da Fatura no Financeiro
					//Manipular fatura após Desatualização no Financeiro
					If ExistBlock("GFEA0703")
						ExecBlock("GFEA0703",.F.,.F.,{})
					EndIf

					RecLock("GW6", .F.)
						GW6->GW6_SITFIN := "1"
						GW6->GW6_MOTFIN := ""
					GW6->( MsUnlock() )

					cTxtAP += "Fatura " + AllTrim(GW6->GW6_NRFAT) + " desatualizada no Financeiro." + CRLF
				Else
					RecLock("GW6", .F.)
						GW6->GW6_SITFIN := "4"
						GW6->GW6_MOTFIN := aRetDes[2]
					GW6->( MsUnlock() )

					cTxtAP += "Fatura " + AllTrim(GW6->GW6_NRFAT) + " não foi desatualizada no Financeiro. Motivo: " + aRetDes[2] + CRLF 
				EndIf
			EndIf
		Else
			cTxtAP += "Fatura " + AllTrim(GW6->GW6_NRFAT) + " não foi enviada para desatualização no Financeiro por causa do seguinte erro: " + aRetVld[2] + CRLF 
		EndIf

	    (cGW6Pro)->( dbSkip() )
	EndDo

	(cGW6Pro)->( dbCloseArea() )	
	
	If !Empty(cTxtAP)
		MsgInfo(cTxtAP)
	EndIf	
	
	GFEA072MK()
Return

//Os registros que estiverem com checkbox marcado chamarão a função GFEA070ADF
Function GFEA072AD()
	Local cTxOF1 := ""
	Local cTexto := ""
	Local dDtOf  := Nil
	Local cGW6Pro := GetNextAlias()
	
	// abre tela para informar a data de integração com fiscal
	// grava informação em variável global
	dDtOF := GFEA065DT()	
	
	cQuery := "SELECT R_E_C_N_O_, GW6.GW6_NRFAT FROM " + RetSQLName("GW6") + " GW6 "
	cQuery += " WHERE GW6.D_E_L_E_T_ = ' ' "
	cQuery += "   AND (GW6.GW6_MARKBR = '" + oBrowse:Mark() + "' )"
	cQuery += " ORDER BY R_E_C_N_O_ "
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGW6Pro, .F., .T.)

	(cGW6Pro)->( dbGoTop() )

	GW6->( dbSetOrder(1) )
	GW6->( dBGoTop() )
	
	While !(cGW6Pro)->( Eof() )	
		GW6->(DBGoTo((cGW6Pro)->R_E_C_N_O_) )				
		
		cTexto := GFEA070ADF(.F.,dDtOF)
			
		If ValType(cTexto) == "C"
			cTxOF1 += cTexto
		EndIf
	    (cGW6Pro)->( dbSkip() )
	EndDo
	
	dDtOF := Nil
	
	If !Empty(cTxOF1)	
		// abre tela para informar todos os documentos enviados
		// verIfica variável global
		DEFINE MSDIALOG oDlg TITLE "Atualização no fiscal" From 0,0 To 18,70 OF oMainWnd
			@ 4, 006 SAY "Resumo: " SIZE 130,7 PIXEL OF oDlg
	
			 oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTxOF1:=u,cTxOF1)},;
											oDlg,265,105,,,,,,.T.,,,,,,.T.)
	
			oButtonOK   := tButton():New(125,5,'OK',oDlg,{|| oDlg:End()},25,10,,,,.T.)
	
		ACTIVATE MSDIALOG oDlg CENTER	
	EndIf
	
	GFEA072MK()
Return

//-------------------------------/*//*/--------------------------------//
/*-------------------------------------------------------------------
{Protheus.doc} GFEA072MK
Deselecionar Todos

@author Iuri Bruning Negherbon
@since 05/03/2018
@version 1.0
-------------------------------------------------------------------  */
Function GFEA072MK()
	Local aAreaGW6  := GetArea()
	
	cQuery := "SELECT R_E_C_N_O_, GW6.GW6_NRFAT FROM " + RetSQLName("GW6") + " GW6 "
	cQuery += " WHERE GW6.D_E_L_E_T_ = ' ' "
	cQuery += "   AND (GW6.GW6_MARKBR = '" + oBrowse:Mark() + "' )"
	cQuery += " ORDER BY R_E_C_N_O_ "
	cQuery := ChangeQuery(cQuery)
	cAliasGW6 := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW6, .F., .T.)

	(cAliasGW6)->( dbGoTop() )

	GW6->( dbSetOrder(1) )
	GW6->( dBGoTop() )
	While !(cAliasGW6)->( Eof() )
		GW6->(DBGoTo((cAliasGW6)->R_E_C_N_O_) )	
		If (GW6->GW6_MARKBR == oBrowse:Mark())
				RecLock("GW6", .F.)
					GW6->GW6_MARKBR := ''
				GW6->( MsUnlock() )
		EndIf				
		(cAliasGW6)->(dbSkip())
	EndDo	
	(cAliasGW6)->(dbCloseArea())

	RestArea(aAreaGW6)
	
	oBrowse:Refresh()
	oBrowse:GoTop()
Return Nil

Static Function GFEA072DT()
	Local dData := Date()
	Local lOk := .F.

	DEFINE DIALOG oDlg TITLE "Selecione a data de vencimento financeiro" FROM 180,180 TO 350,460 PIXEL //"Seleciona a Data"
	    // Cria objeto
		oMsCalend := MsCalend():New(01,01,oDlg,.F.)
	    // Define o dia a ser exibido no calendário
	    oMsCalend:dDiaAtu := dData
	    // Code-Block para mudança de Dia
	    oMsCalend:bChange := {|| dData := oMsCalend:dDiaAtu}
		oTButton1 := TButton():New( 070, 30, "OK",oDlg,{||lOk := .T.,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTButton1 := TButton():New( 070, 75, "Cancelar",oDlg,{||oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 

	ACTIVATE DIALOG oDlg CENTERED

	If !lOk
        dData := nil
	EndIf

Return dData

Static Function GFEA72LIB()

	Local aAreaGW6  := GetArea()
	
	cQuery := 'SELECT * FROM '+RetSqlName('GW6')+" GW6"
	cQuery += " WHERE GW6.GW6_MARKBR <> '' "
	cQuery += " AND GW6.D_E_L_E_T_ = ' '"	
	cQuery := ChangeQuery(cQuery)
	cAliasGW6 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW6, .F., .T.)
	
	(cAliasGW6)->( dbGoTop() )
	While !(cAliasGW6)->(Eof())
		GW6->( dbSetOrder(1) )
		If GW3->(dbSeek((cAliasGW6)->GW6_FILIAL+(cAliasGW6)->GW6_EMIfAT+(cAliasGW6)->GW6_SERFAT+(cAliasGW6)->GW6_NRFAT))
			If !Empty(GW6->GW6_MARKBR)
				RecLock("GW6", .F.)
					GW6->GW6_MARKBR := ''
				GW6->( MsUnlock() )
			EndIf				
		EndIf
		(cAliasGW6)->(dbSkip())
	EndDo	
	(cAliasGW6)->(dbCloseArea())

	RestArea(aAreaGW6)
	
Return NIl
