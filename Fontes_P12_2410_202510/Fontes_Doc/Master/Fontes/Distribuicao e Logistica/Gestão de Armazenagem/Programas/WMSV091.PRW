#INCLUDE "WMSV091.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

#DEFINE WMSV09101 "WMSV09101"
#DEFINE WMSV09102 "WMSV09102"
#DEFINE WMSV09103 "WMSV09103"
#DEFINE WMSV09104 "WMSV09104"
#DEFINE WMSV09105 "WMSV09105"
#DEFINE WMSV09106 "WMSV09106"
#DEFINE WMSV09107 "WMSV09107"
#DEFINE WMSV09108 "WMSV09108"
//------------------------------------------------------------
/*/{Protheus.doc} WMSV091
Conferencia de volumes no recebimento
@author Reinaldo Dias
@since 30/08/2015
@version 1.0
/*/
//------------------------------------------------------------
Function WMSV091()
Local bkey09    := VTSetKey(09) //CTRL+I
Local bkey24    := VTSetKey(24) //CTRL+X 
Local cKey09    := VtDescKey(09)
Local cKey24    := VtDescKey(24)
Local cDocto    := Space(Len(DCZ->DCZ_EMBARQ))

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	
	Do While .T.
		cDocto := Space(Len(DCZ->DCZ_EMBARQ))

		WMSVTCabec(STR0001,'',.F.,.F.,.T.) // Conferencia Volumes
		@ 01,00  VtSay STR0018 // Informe o Documento:
		@ 02,00  VTGet cDocto Picture "@!"  Valid ValidDocto(@cDocto)
		VtRead
		If VTLastKey() == 27
			Exit
		EndIf
		// Atribui tecla de atalho para estorno - CTRL+X
		VTSetKey(24,{|| ConfVol(cDocto,.T.)}, STR0004) // Estorno
		// Efetua a conferencia dos volumes deste documento de conferencia
		ConfVol(cDocto)
	Enddo
	// Restaura as teclas de talhao
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(24,bkey24,cKey24)
Return
/*--------------------------------------------------------------------------------
---ValidDocto
---Funcao para validar o documento de conferencia
---Reinaldo Dias - 30/08/2015
---cDocto, character, (cDocto do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function ValidDocto(cDocto)
Local aTelaAnt := VTSave()
Local aDocto   := {}

	If Empty(cDocto)
	
		LoadCofRec(@aDocto)
	
		If Empty(aDocto)
			WMSVTAviso(WMSV09101,STR0002) // "Nao existem conferências de volumes pendentes para execução."
			VtKeyboard(Chr(20))
			VtRestore(,,,,aTelaAnt)
			Return(.F.)
		Else
			VtClearBuffer()
			WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferencia Volumes
			nPos:=VTaBrowse(1,,,,{STR0003,STR0013},aDocto,{09,15}) // Documento // Situacao
			If VTLastKey() == 27
				VtRestore(,,,,aTelaAnt)
				Return(.F.)
			EndIf
		EndIf
		cDocto:= aDocto[nPos,1]
	Endif
	If Empty(cDocto)
		Return(.F.)
	EndIf
	DCW->(DBSetOrder(1)) //DCW_FILIAL+DCW_EMBARQ
	If !DCW->(DBseek(xFilial("DCW")+cDocto))
		WMSVTAviso(WMSV09102,STR0019) //Documento de conferencia nao encontrado!!! 
		VtKeyboard(Chr(20))
		Return(.F.)
	EndIf
	If DCW->DCW_SITEMB $ "3|4"
		If WMSVTAviso(WMSV09103,STR0020,{STR0021,STR0022}) == 1 // A conferencia de volumes ja foi finalizada. Deseja Reinicar? // Sim // Nao
			RecLock("DCW",.F.)
			DCW->DCW_QTCONF := 0
			DCW->DCW_SITEMB := "2" //Volume em andamento
			DCW->DCW_CODUSU := __cUserID
			DCW->(MsUnlock())
		Else
			VtKeyboard(Chr(20))
			Return(.F.)
		Endif
	EndIf
Return(.T.)
/*--------------------------------------------------------------------------------
---LoadCofRec
---Monta documentos disponíveis para conferencia de volumes
---Reinaldo Dias - 30/08/2015
---aDocto, Array (aDocto - codigo embarque, Caracter
                               - data geraçã0, Data)
----------------------------------------------------------------------------------*/
Static Function LoadCofRec(aDocto)
Local cAliasDCW := GetNextAlias()
Local aBoxDCW   := RetSx3Box(Posicione('SX3',2,'DCW_SITEMB','X3CBox()'),,,1)

	aDocto := {}
	
	BeginSql Alias cAliasDCW
		SELECT DCW.DCW_EMBARQ,
				DCW.DCW_SITEMB
		FROM %Table:DCW% DCW
		WHERE DCW.DCW_FILIAL = %xFilial:DCW%
		AND (DCW.DCW_SITEMB = '1'
			AND DCW.DCW_CODUSU = '  '
			OR DCW.DCW_SITEMB = '2'
			AND DCW.DCW_CODUSU = %Exp:__cUserID% )
		AND DCW.%NotDel%
		ORDER BY DCW.DCW_SITEMB DESC
	EndSql
	Do While (cAliasDCW)->(!Eof())
		Aadd(aDocto,{(cAliasDCW)->DCW_EMBARQ,aBoxDCW[Val((cAliasDCW)->DCW_SITEMB) , 3 ]})
		(cAliasDCW)->(dbSkip())
	EndDo
	(cAliasDCW)->(dbCloseArea())
Return .T.
/*--------------------------------------------------------------------------------
---ConfVol
---Permite efetuar a conferência dos produtos de um processo
---até que o usuário escolha a opção de finalizar a conferência.
---Reinaldo Dias - 11/09/2015
---cDocto, character, (cDocto do conferencia de recebimento)
---lEstorno, Logico, (Indica se é estorno)
----------------------------------------------------------------------------------*/
Static Function ConfVol(cDocto,lEstorno)
Local aTelaAnt  := VTSave()
Local nQtVolum   := 0.00
Local cPictQt   := PesqPict('DCW','DCW_QTCONF')
Local lEncerra  := .F.
Local lAbandona := .F.
Local nAviso    := 0
Local cKey09    := VtDescKey(09)

// Ativa teclas de atalho de informacoes - CTRL+I
Local bkey09    := VTSetKey(9, {|| ShowPrdCof(cDocto)}, STR0009) // Informacoes
Local aGets     := {}
Local nGet      := 0
Local nPos      := 0
Local nLin      := 0
Local aTela     := {}

Default lEstorno := .F.

	Do While !lEncerra .And. !lAbandona
		nQtVolum   := 0.00
		//   01234567890123456789
		// 0 Conferência Volumes_
		// 1 Documento: 000000
		// 2                    
		// 3 Informe Qtd.Volume:  
		// 4 10                
		// 5               
		// 6                   
		// 7                     
		WMSVTCabec(STR0001+Iif(lEstorno,' '+STR0004,''),.F.,.F.,.T.) // Conferencia Volumes
		@ 01,00  VtSay STR0003 + ': ' + cDocto // Documento
		@ 03,00  VTSay STR0005 // Informe Qtd.Volume:
		@ 04,00  VTGet nQtVolum Picture cPictQt When Empty(nQtVolum) Valid ValidQtd(cDocto,@nQtVolum,lEstorno)
		VtRead
		
		If VTLastKey()==27
			nAviso := WMSVTAviso(WMSV09104,STR0006,{STR0007,STR0008}) // Deseja encerrar a conferencia? // Encerrar // Interromper
			If nAviso == 1
				lEncerra := .T.
			ElseIf nAviso == 2
				lAbandona  := .T.
			Else
				Loop
			EndIf
		EndIf
		// Se o usuário optou por encerrar, deve verificar se pode ser finalizado a conferência
		If lEncerra
			lEncerra := FinCofRec(cDocto)
		EndIf
		// Se for estorno, sai ao executar a primeira vez
		If lEstorno
			Exit
		EndIf
	EndDo
	// Restaura teclas
	VTSetKey(09,bkey09,cKey09)
	VtRestore(,,,,aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ShowPrdCof
---Apresenta produtos da conferencia
---Reinaldo Dias - 11/08/2015
---cDocto, character, (cDocto do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function ShowPrdCof(cDocto)
Local lRet      := .T.
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cAliasDCW := GetNextAlias()

	BeginSql Alias cAliasDCW
		SELECT DCW.DCW_QTCONF,
				DCW.DCW_QTVOLU
		FROM %Table:DCW% DCW
		WHERE DCW.DCW_FILIAL = %xFilial:DCW%
		AND DCW.DCW_EMBARQ = %Exp:cDocto%
		AND DCW.%NotDel%
	EndSql
	If (cAliasDCW)->(!Eof())
		WMSVTAviso(STR0001,; // Conferencia Volumes
			Padr(STR0014+Alltrim(Str((cAliasDCW)->DCW_QTCONF)),VTMaxCol())+; // "Qtde.Volumes: "
			Padr(STR0015+If(QtdComp((cAliasDCW)->DCW_QTVOLU)==QtdComp((cAliasDCW)->DCW_QTCONF),STR0016,STR0017),VTMaxCol())) // Status Conf.:  // OK // Divergencia
	EndIf
	VtRestore(,,,,aTelaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidQtd
---Valida a digitação da quantidade
---Reinaldo Dias - 11/08/2015
---cDocto, character, (Embarque do conferencia de recebimento)
---nQtVolum, numérico, (Quantidade conferida)
---lEstorno, Lógico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function ValidQtd(cDocto,nQtVolum,lEstorno)

	If QtdComp(nQtVolum) <= 0
		Return(.F.)
	EndIf
	
	If lEstorno .And. WMSVTAviso(WMSV09108,STR0023,{STR0021,STR0022}) == 2 // Confirma o Estorno? // Sim // Nao
		VtKeyboard(Chr(20))
		Return(.F.)
	EndIf	
	DCW->(DBSetOrder(1)) //DCW_FILIAL+DCW_EMBARQ
	If DCW->(DBseek(xFilial("DCW")+cDocto))
		RecLock("DCW",.F.)
		DCW->DCW_QTCONF += IIF(lEstorno,nQtVolum*-1,nQtVolum)
		DCW->DCW_SITEMB := "2" //Em andamento
		DCW->DCW_CODUSU := __cUserID
		If DCW->DCW_QTCONF < 0
			DCW->DCW_QTCONF := 0
		EndIf
		DCW->(MsUnlock())
	Endif
Return(.T.)
/*--------------------------------------------------------------------------------
---FinCofRec
---Verifica/Finaliza conferencia de embarque
---Alexsander.Correa - 01/04/2015
---cDocto, character, (Embarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
Static Function FinCofRec(cDocto)
Local lRet      := .T.
Local aAreaDCW  := DCW->( GetArea() )
Local aBoxDCW   := RetSx3Box(Posicione('SX3',2,'DCW_SITEMB','X3CBox()'),,,1)
	DCW->( dbSetOrder(1) ) //DCW_FILIAL+DCW_EMBARQ
	If DCW->( dbSeek(xFilial('DCW')+cDocto) )
		If DCW->DCW_SITEMB $ '3|4'
			WMSVTAviso(WMSV09105,STR0010) // Conferencia já finalizada por outro processo!
			lRet := .F.
		Else
			RecLock("DCW",.F.)
			DCW->DCW_SITEMB := IIF(QtdComp(DCW->DCW_QTVOLU) == QtdComp(DCW->DCW_QTCONF),"3","4")
			DCW->(MsUnlock())
		Endif
		If lRet
			//   01234567890123456789
			// 0 Conferencia Volumes_
			// 1 Documento: 000000  
			// 2 --------------------
			// 3 Conferido
			// 4 --------------------
			VtClear()
			WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferencia Volumes
			//Mostra Dados
			@ 01,00  VTSay STR0003 + ': ' + cDocto // Documento 
			@ 03,00  VTSay Replicate('-',VTMaxCol())
			@ 04,00  VtSay aBoxDCW[Val(DCW->DCW_SITEMB) , 3 ]
			@ 05,00  VTSay Replicate('-',VTMaxCol())
			WMSVTRodPe()
		Else
			WMSVTAviso(WMSV09106,STR0012) // Não foi possível finalizar a conferência.
		EndIf
	Else
		WMSVTAviso(WMSV09107,STR0011) // Número recebimento informado não cadastrado.
		lRet := .F.
	EndIf
	RestArea(aAreaDCW)
Return lRet