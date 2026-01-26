#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE "OFAGCA09.CH"

Static nQtdBloco := 200 // Quantidade de VB6 por Bloco de Envios

/*/{Protheus.doc} OFAGCA09
	Tela para envios do VMI (Pendencias)

	@author Andre Luis Almeida
	@since  01/11/2021
/*/
Function OFAGCA09()
	Local cBkpFilAnt  := cFilAnt
	Local aSize       := FWGetDialogSize( oMainWnd )
	Private cCadastro := STR0001 // Pendencias de Envio VMI
	Private aEnvios   := {}
	Private oVmi      := OFAGVmi():New()
	Private oSqlHlp   := DMS_SqlHelper():New()
	Private cVB6_ORIGEM := ""
	Private cDesc_Filt  := STR0007  // Total
	//
	AGCA0901_Levanta_Pendencias(.f.,"")
	//
	SetKey(VK_F12,{ || AGCA0904_Filtro_F12() })
	oDlgOFAGCA09 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
		oLBEnvios := TWBrowse():New(1,1,100,100,,,,oDlgOFAGCA09,,,,,{ || AGCA0902_Processa() },,,,,,,.F.,,.T.,,.F.,,,)
		oLBEnvios:AddColumn( TCColumn():New( STR0002 , { || aEnvios[oLBEnvios:nAt,1] } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) ) // Filial
		oLBEnvios:AddColumn( TCColumn():New( STR0003 , { || aEnvios[oLBEnvios:nAt,2] } ,,,,"LEFT" ,200,.F.,.F.,,,,.F.,) ) // Nome
		oLBEnvios:AddColumn( TCColumn():New( STR0006 , { || aEnvios[oLBEnvios:nAt,5] } ,,,,"LEFT" ,80,.F.,.F.,,,,.F.,) ) // Filtro
		oLBEnvios:AddColumn( TCColumn():New( STR0004 , { || Transform(aEnvios[oLBEnvios:nAt,3],"@E 999,999,999,999,999") } ,,,,"RIGHT" ,100,.F.,.F.,,,,.F.,) ) // Envios Pendentes
		oLBEnvios:setArray( aEnvios )
		oLBEnvios:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlgOFAGCA09 ON INIT EnchoiceBar(oDlgOFAGCA09,{|| oDlgOFAGCA09:End() },{|| oDlgOFAGCA09:End() },,)
	cFilAnt := cBkpFilAnt
	SetKey(VK_F12,Nil)
	//
Return .T.

/*/{Protheus.doc} AGCA0901_Levanta_Pendencias
	Levanta Pendencias de envios do VMI

	@author Andre Luis Almeida
	@since  01/11/2021
/*/
Static Function AGCA0901_Levanta_Pendencias(lRefresh,cFilPos)
Local oVMIPars := OFAGVmiParametros():New()
Local aFilAtu  := FWArrFilAtu()
Local aSM0     := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local nCntFor  := 0
Local nRecs    := 0
Local cNamVB6  := oSqlHlp:NoLock('VB6')
Local cFilVB6  := ""
//
aEnvios := {}
//
For nCntFor := 1 to len(aSM0)
	cFilAnt := aSM0[nCntFor]
	If oVMIPars:FilialValida(cFilAnt)  // só executa para filiais AGCO configuradas
		cFilVB6 := xFilial("VB6")
		cQuery := "SELECT COUNT(*) "
		cQuery += "  FROM " + cNamVB6
		cQuery += " WHERE VB6_FILIAL = '"+cFilVB6+"' "
		cQuery += "   AND VB6_FLGENV = '0' "
		cQuery += "   AND VB6_IMPEDI = '0' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		cQuery += cVB6_ORIGEM
		nRecs := FM_SQL(cQuery)
		If nRecs > 0
			aAdd(aEnvios,{ cFilAnt , FWFilialName() , nRecs , cFilVB6 , cDesc_Filt })
		EndIf
	EndIf
Next
//
If len(aEnvios) == 0
	aAdd(aEnvios,{ "" , "" , 0 , "" , "" })
EndIf
//
If lRefresh
	nCntFor := ascan(aEnvios,{|x| x[1] == cFilPos })
	nCntFor := IIf(nCntFor==0,1,nCntFor)
	oLBEnvios:nAt := nCntFor
	oLBEnvios:SetArray(aEnvios)
	oLBEnvios:refresh()
EndIf
//
Return

/*/{Protheus.doc} AGCA0902_Processa
	Processa envios do VMI ( Pendencias )

	@author Andre Luis Almeida
	@since  01/11/2021
/*/
Static Function AGCA0902_Processa()
Local oProcess // incluído o parâmetro lEnd para controlar o cancelamento da janela
oProcess := MsNewProcess():New({|lEnd| AGCA0903_EnviarVMI(@oProcess, @lEnd) },STR0002+": "+aEnvios[oLBEnvios:nAt,1]+" - "+aEnvios[oLBEnvios:nAt,2],"",.T.) // Filial
oProcess:Activate()
Return

/*/{Protheus.doc} AGCA0903_EnviarVMI
	Envios do VMI ( Pendencias )

	@author Andre Luis Almeida
	@since  01/11/2021
/*/
Static Function AGCA0903_EnviarVMI(oProcess, lEnd)
	Local cQtd    := ""
	Local cQuery  := ""
	Local cAl     := "SQLVB6"
	Local nVezes  := 0
	Local nCntFor := 0
	Default lEnd  := .f.
	SetKey(VK_F12,Nil)
	If len(aEnvios) > 0 .and. !Empty(aEnvios[oLBEnvios:nAt,1]) // Se existe registro para a Filial, executou o botao Envio e nao esta enviando

		cFilAnt := aEnvios[oLBEnvios:nAt,1]

		cQuery := "SELECT R_E_C_N_O_ AS RECNO "
		cQuery += "  FROM " + oSqlHlp:NoLock('VB6')
		cQuery += " WHERE VB6_FILIAL = '"+aEnvios[oLBEnvios:nAt,4]+"' "
		cQuery += "   AND VB6_FLGENV = '0' "
		cQuery += "   AND VB6_IMPEDI = '0' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		cQuery += cVB6_ORIGEM
		cQuery := oSqlHlp:TopFunc(cQuery, nQtdBloco )

		cQtd := Alltrim(Transform(aEnvios[oLBEnvios:nAt,3],"@E 999,999,999,999,999"))+" "+STR0005 // registros

		nVezes := int((aEnvios[oLBEnvios:nAt,3]/nQtdBloco))+1
		oProcess:SetRegua1(0)
		oProcess:IncRegua1(STR0002+": "+aEnvios[oLBEnvios:nAt,1]+" - "+aEnvios[oLBEnvios:nAt,2]) // Filial
		oProcess:SetRegua2(nVezes)
		For nCntFor := 1 to nVezes
			//
			oProcess:IncRegua2(cQtd+Transform((nCntFor/nVezes)*100,"@E 99999.99")+" % ( "+cDesc_Filt+" )")
			//
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
			while !(cAl)->(eof())
				oVmi:Enviar((cAl)->RECNO,.f.)
				(cAl)->(DBSkip())
			EndDo
			(cAl)->(dbCloseArea())
			//
		Next
		dbSelectArea("VB6")
		AGCA0901_Levanta_Pendencias(.t.,aEnvios[oLBEnvios:nAt,1])
	EndIf
	SetKey(VK_F12,{ || AGCA0904_Filtro_F12() })
Return

/*/{Protheus.doc} AGCA0904_Filtro_F12
	Filtro Tela dos Registros do VMI ( Pendencias )

	@author Andre Luis Almeida
	@since  18/07/2024
/*/
Static Function AGCA0904_Filtro_F12()
Local cQuery  := ""
Local nFiltro := 1
Local aFiltro := {}
Local aBotFil := {}
Local cMsgFil := ""
Local lFiltra := .t.
Local cPulaLin := CHR(13)+CHR(10)
//
SetKey(VK_F12,Nil)
//
aAdd(aFiltro,"") // Todos os registros do VB6 ( Carga Inicial + Diário )
aAdd(aBotFil,STR0007 ) // Total
//
aAdd(aFiltro,"*") // * = será necessário selecionar qual DMS deseja ou se sera todos os registros da Carga Inicial
aAdd(aBotFil,STR0008) // Carga Inicial
//
aAdd(aFiltro," AND VB6_ORIGEM NOT LIKE 'OFAGCA11_%'") // Registros referente ao Diário
aAdd(aBotFil,STR0009) // Diário
//
aAdd(aFiltro,"X") // X = Sair da Tela de Filtro
aAdd(aBotFil,STR0010) // Cancelar
//
cMsgFil += cPulaLin
cMsgFil += "- "+STR0012+cPulaLin+cPulaLin // Total ( Carga Inicial + Diário )
cMsgFil += "- "+STR0008+cPulaLin+cPulaLin // Carga Inicial
cMsgFil += "- "+STR0009+cPulaLin+cPulaLin // Diário
//
nFiltro := Aviso(STR0006 ,cMsgFil,aBotFil,3) // Filtro
If nFiltro > 0
	If aFiltro[nFiltro] == "X"
		lFiltra := .f.
	ElseIf aFiltro[nFiltro] == "*"
		nFiltro := 1
		aFiltro := {}
		aBotFil := {}
		cMsgFil := cPulaLin
		cMsgFil += STR0007 +" ( DMS2 + DMS1 + DMS3 + DMS4 )"+cPulaLin+cPulaLin // Total
		cMsgFil += STR0011+cPulaLin // Individual
		cQuery := "SELECT COUNT(*) "
		cQuery += "  FROM " + oSqlHlp:NoLock('VB6')
		cQuery += " WHERE VB6_FLGENV = '0' "
		cQuery += "   AND VB6_IMPEDI = '0' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If FM_SQL(cQuery+" AND VB6_ORIGEM = 'OFAGCA11_IniDMS2'") > 0
			aAdd(aFiltro," AND VB6_ORIGEM = 'OFAGCA11_IniDMS2'")
			aAdd(aBotFil,"DMS2")
			cMsgFil += "- "+"DMS2"+cPulaLin
		EndIf
		If FM_SQL(cQuery+" AND VB6_ORIGEM = 'OFAGCA11_IniDMS1'") > 0
			aAdd(aFiltro," AND VB6_ORIGEM = 'OFAGCA11_IniDMS1'")
			aAdd(aBotFil,"DMS1")
			cMsgFil += "- "+"DMS1"+cPulaLin
		EndIf
		If FM_SQL(cQuery+" AND VB6_ORIGEM = 'OFAGCA11_IniDMS3'") > 0
			aAdd(aFiltro," AND VB6_ORIGEM = 'OFAGCA11_IniDMS3'")
			aAdd(aBotFil,"DMS3")
			cMsgFil += "- "+"DMS3"+cPulaLin
		EndIf
		If FM_SQL(cQuery+" AND VB6_ORIGEM = 'OFAGCA11_IniDMS4'") > 0
			aAdd(aFiltro," AND VB6_ORIGEM = 'OFAGCA11_IniDMS4'")
			aAdd(aBotFil,"DMS4")
			cMsgFil += "- "+"DMS4"+cPulaLin
		EndIf
		aAdd(aFiltro," AND VB6_ORIGEM LIKE 'OFAGCA11_%'")
		aAdd(aBotFil,STR0007 ) 
		nFiltro := Aviso(STR0008,cMsgFil,aBotFil,3) // Carga Inicial
		If nFiltro > 0
			cVB6_ORIGEM := aFiltro[nFiltro]
			cDesc_Filt := STR0008+" "+aBotFil[nFiltro] // Carga Inicial
		EndIf
	Else
		cVB6_ORIGEM := aFiltro[nFiltro]
		cDesc_Filt := aBotFil[nFiltro]
	EndIf
EndIf
If lFiltra
	AGCA0901_Levanta_Pendencias(.t.,"")
EndIf
SetKey(VK_F12,{ || AGCA0904_Filtro_F12() })
Return