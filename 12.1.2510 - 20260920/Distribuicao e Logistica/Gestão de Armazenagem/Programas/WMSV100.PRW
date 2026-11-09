#INCLUDE "WMSV100.ch"  
#INCLUDE "PROTHEUS.ch" 
#INCLUDE "APVT100.ch"

#DEFINE WMSV10001 "WMSV10001"
#DEFINE WMSV10002 "WMSV10002"
#DEFINE WMSV10003 "WMSV10003"
#DEFINE WMSV10004 "WMSV10004"
#DEFINE WMSV10005 "WMSV10005"
#DEFINE WMSV10006 "WMSV10006"
#DEFINE WMSV10007 "WMSV10007"
#DEFINE WMSV10008 "WMSV10008"
#DEFINE WMSV10009 "WMSV10009"
#DEFINE WMSV10010 "WMSV10010"
#DEFINE WMSV10011 "WMSV10011"
#DEFINE WMSV10012 "WMSV10012"
#DEFINE WMSV10013 "WMSV10013"
#DEFINE WMSV10014 "WMSV10014"
#DEFINE WMSV10015 "WMSV10015"
#DEFINE WMSV10016 "WMSV10016"
#DEFINE WMSV10017 "WMSV10017"
#DEFINE WMSV10018 "WMSV10018"
#DEFINE WMSV10019 "WMSV10019"
#DEFINE WMSV10020 "WMSV10020"
#DEFINE WMSV10021 "WMSV10021"
#DEFINE WMSV10022 "WMSV10022"
#DEFINE WMSV10023 "WMSV10023"
//----------------------------------------------------------
/*/{Protheus.doc} WMSV100 - Endereçamento de Expedição
Permite que um pedido de venda ou carga possa ser 
endereçado antes do embarque.  

@author  Evaldo Cevinscki Jr.
@version	P11
@since   03/07/12 - revisão 01/10/14
/*/
//----------------------------------------------------------
Function WMSV100()
Local cKey09 := VtDescKey(09)
Local cKey22 := VtDescKey(22)
Local cKey24 := VtDescKey(24)
Local bkey09 := VTSetKey(09)          
Local bkey22 := VTSetKey(22)
Local bkey24 := VTSetKey(24)
Local aTela  := {}
Local lRet   := .T.  
Local nOpc   := 0
Local lWmsNew := SuperGetMV("MV_WMSNEW",.F.,.F.)

Private cCodOpe	  := __cUserID
Private cCarga	  := Space(TamSx3("DAK_COD")[1])
Private cPedido	  := Space(TamSx3("DAI_PEDIDO")[1])
Private cEndereco := Space(TamSx3("BE_LOCALIZ")[1])
Private cVolume	  := Space(TamSx3("DCU_CODVOL")[1])
Private aPedidos  := {} // carrega pedidos do volume
Private lWMSAltDca:= SuperGetMV('MV_WMSALDC', .F., .F.) //Permite alterar DOCA
Private lD00Local := D00->( ColumnPos( "D00_LOCEND" ) ) > 0
Private cLocal	  := IIF(lD00Local, Space(TamSx3("D00_LOCEND")[1]), "") 

	If lRet
		If Empty(cCodOpe)
			WmsMessage(STR0001,WMSV10001) // Operador nao cadastrado
			lRet := .F.
		EndIf
		If lRet	
			aTela := VtSave()
			VTCLear()        
			
			If IsInCallStack("WMSV100")
				@ 0,0 VTSay STR0003 // Selecione:
				If lWmsNew
					nOpc := VTaChoice(2,0,4,VTMaxCol(),{STR0004,STR0005,STR0044}) // Endereca Carga // Endereca Pedido // Endereca Volume
				Else
					nOpc := VTaChoice(2,0,4,VTMaxCol(),{STR0004,STR0005}) // Endereca Carga // Endereca Pedido
				EndIf
			ElseIf IsInCallStack("WMSV100A")
				nOpc := 1 // Endereca Carga/Pedido
			ElseIf IsInCallStack("WMSV100B")
				nOpc := 2 // Endereca Pedido
			EndIf	
			VtClearBuffer()			
			// Tela de endereçamento
			If nOpc <> 0
				WMSV1001(nOpc)
			EndIf	  
			
			If VtLastKey() == 27			
				lRet := .F.
			EndIf			
			// Restaura teclas
			VTSetKey(09,bkey09,cKey09)
			VTSetKey(22,bkey22,cKey22)
			VTSetKey(24,bkey24,cKey24)   
			VtRestore(,,,,aTela)
		Else
			VtKeyboard(Chr(20))  
		EndIf	
	EndIf	
Return ( lRet )
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Endereçamento de Carga/Pedido      
//----------------------------------------------------------
Function WMSV100A()
	WMSV100()
Return Nil 
//----------------------------------------------------------
// Função para ser chamada direto do menu para para ir direto
// a tela de Endereçamento de Pedido														    
//----------------------------------------------------------
Function WMSV100B()
	WMSV100()
Return Nil 
//----------------------------------------------------------
/*/{Protheus.doc} WMSV1001
Tela de Enderecamento de Expedição

@param   nTipo    Tipo de endereçamento: 
						1 - Carga/Pedido
						2 - Pedido

@author  Evaldo Cevinscki Jr.
@version	P11
@since   04/07/12 - revisão 01/10/14
/*/
//----------------------------------------------------------
Function WMSV1001(nTipo)        
Local aTela    := VTSave()
Local cKey15   := VtDescKey(15)
Local bkey15   := VTSetKey(15)
Local cKey24   := VtDescKey(24)
Local bkey24   := VTSetKey(24)
Local nLin     := 1
Local lVolume  := .F.
Local dDtIni   := CtoD('  /  /  ')
Local cHrIni   := ''
Local aVolumes := {}
Local nPos     := 0
Local lLevaEnd := .F.
Local lContinua:= .F.
Local lAbandona:= .F.
Local aLocEnd  := {}

	While .T.
		VTCLear()
		
		VTSetKey(24,{|| GerEstorno(nTipo,lVolume)}, STR0038) // Ctrl+X // Estorno
		VTSetKey(15,{|| MontaCons(nTipo)}, STR0039) // Ctrl+O // Enderecamentos
		
		nLin     := 1
		cCarga   := Space(TamSx3("DAK_COD")[1])
		cPedido  := Space(TamSx3("DAI_PEDIDO")[1])
		cEndereco:= Space(TamSx3("BE_LOCALIZ")[1])

		If lD00Local
			cLocal := Space(TamSx3("D00_LOCEND")[1])
		EndIf
		aPedidos := {}
		
		WMSVTCabec(IIf(nTipo == 1,STR0006,If(nTipo == 2,STR0007,STR0045)), .F., .F., .T.) // Enderecamento Carga // Enderecamento Pedido // Enderecamento Volume
		If nTipo == 1
			@ ++nLin,00 VTSay PadR(STR0008, VTMaxCol()) // Carga
			@ ++nLin,00 VTGet cCarga Valid ValidCarga(cCarga)
		EndIf
		If nTipo == 1 .Or. nTipo == 2
			@ ++nLin,00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
			@ ++nLin,00 VTGet cPedido Valid WMSV100PED(nTipo,@cCarga,cPedido) .And. WMSV100VOL(2,@lVolume,cCarga,cPedido)
			VTRead()
			If VTLastKey() == 27
				Exit
			EndIf
		EndIf
		
		If lVolume .Or. nTipo == 3
			VTSetKey(22,{|| MntVolume(aVolumes)}, STR0041) // Ctrl+V // Volume
			VTSetKey(21,{|| EstVolume(@aVolumes,nTipo)}, STR0046) // Ctrl+U // Estorno Volume
			aVolumes := {}
			While .T.
				VTClear()
				WMSVTCabec(IIf(nTipo == 1,STR0006,If(nTipo == 2,STR0007,STR0045)), .F., .F., .T.) // Enderecamento Carga // Enderecamento Pedido // Enderecamento Volume
				nLin := 1
				cVolume := Space(TamSx3("DCU_CODVOL")[1])
				If nTipo == 1
					@ ++nLin,00 VTSay PadR(STR0010+cCarga, VTMaxCol()) // Carga.:
				EndIf
				If nTipo == 1 .Or. nTipo == 2
					@ ++nLin,00 VTSay PadR(STR0011+cPedido, VTMaxCol()) // Pedido:
					@ ++nLin,00 VTSay PadR(STR0041, VTMaxCol()) // Volume
					@ ++nLin,00 VTGet cVolume Valid WMSV100VOL(1,,cCarga,cPedido,cVolume) .And. VldVol(cVolume)
					VTRead()
				Else
					@ ++nLin,00 VTSay PadR(STR0041, VTMaxCol()) // Volume
					@ ++nLin,00 VTGet cVolume Valid WMSV100VOL(3,,,,cVolume) .And. VldVol(cVolume)
					VTRead()
				EndIf
				If VTLastKey() == 27
					nLin := 1
					nPos := VTaBrowse(++nLin,0,VTMaxRow(),VTMaxCol(),{Padr(STR0003,VTMaxCol())},IIf(!Empty(aVolumes),{{STR0047},{STR0048},{STR0049}},{{STR0048},{STR0049}}),{VTMaxCol()},,1) // Selecione: // Levar p/ Endereco // Continuar // Abandonar
					If !Empty(aVolumes)						
						lLevaEnd  := (nPos == 1)
						lContinua := (nPos == 2)
						lAbandona := (nPos == 3)
					Else
						lLevaEnd  := .F.
						lContinua := (nPos == 1)
						lAbandona := (nPos == 2)
						
					EndIf
					If lLevaEnd .Or. lAbandona// Levar p/ Endereço // Abandonar
						Exit
					EndIf
				Else
					If !Empty(cVolume) .And. aScan(aVolumes, {|x| x == cVolume }) == 0
						aAdd(aVolumes, cVolume)
					ElseIf !Empty(cVolume) .And. aScan(aVolumes, {|x| x == cVolume }) > 0
						WmsMessage(STR0073,WMSV10021) // Volume ja selecionado para o endereçamento! 
						VtKeyboard(Chr(20))
						Loop						
					EndIf
				EndIf
			EndDo
			
			If lAbandona // Abandonar
				Exit
			EndIf
		EndIf
		
		dDtIni := dDataBase
		cHrIni := 	Time()
		
		VTCLear()
		WMSVTCabec(IIf(nTipo == 1,STR0006,If(nTipo == 2,STR0007,STR0045)), .F., .F., .T.) // Enderecamento Carga // Enderecamento Pedido // Enderecamento Volume
		nLin := 1
		If nTipo == 1
			@ ++nLin,00 VTSay PadR(STR0010+cCarga, VTMaxCol()) // Carga.:
		EndIf
		If nTipo == 1 .Or. nTipo == 2
			@ ++nLin,00 VTSay PadR(STR0011+cPedido, VTMaxCol()) // Pedido:
			If !Empty(cVolume)
				@ ++nLin,00 VTSay PadR(STR0041+": "+cVolume, VTMaxCol()) // Volume:
			EndIf
		Else
			@ ++nLin,00 VTSay PadR(STR0041+": "+cVolume, VTMaxCol()) // Volumes:
			nLin := 1
		EndIf	

		@ ++nLin,00 VTSay PadR(STR0012, VTMaxCol()) // Endereco
		@ ++nLin,00 VTGet cEndereco Picture "@!" Valid ValidEnder(.F.,nTipo,cEndereco,cCarga,cPedido,,aVolumes)
		VTRead()

		If lD00Local .And. lWMSAltDca .And. !Empty(cEndereco)
			aLocEnd := WmsLocEnd(cEndereco)
			If Len(aLocEnd) = 1
				cLocal := aLocEnd[1][2]
			ElseIf Len(aLocEnd) > 1
				@ ++nLin,00 VTSay PadR(STR0075,VTMaxCol()) // "Informe o armazem:"
				@ ++nLin,00 VTGet cLocal Pict "@!" Valid WmsVldArm(cLocal,cEndereco) F3 'NNR'
				VTRead()
			EndIf
		EndIf

		If VTLastKey() == 27
			Exit
		EndIf  
		
		// Grava endereçamento
		GravaDados(nTipo,dDtIni,cHrIni,aVolumes)
		
		If lVolume
			VTSetKey(22)
			VTSetKey(21)
		EndIf
	EndDo
	// Restaura teclas
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil
//----------------------------------------------------------
// ValidCarga
// Valida se a carga informa é válida
// 
// cCarga   Código da carga
//----------------------------------------------------------
Static Function ValidCarga(cCarg)
Local lRet      := .T.    
Local cQuery    := "" 
Local cAliasSC9 := ""          

	If Empty(cCarg)
		lRet := .F.
	Else
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=  " INNER JOIN "+RetSqlName('DCF')+" DCF"
		cQuery +=     " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=    " AND DCF.DCF_ID     = SC9.C9_IDDCF"
		cQuery +=    " AND DCF.DCF_CARGA  = SC9.C9_CARGA"
		cQuery +=    " AND DCF.DCF_DOCTO  = SC9.C9_PEDIDO"
		cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
		cQuery +=    " AND SC9.C9_CARGA   = '"+cCarg+"'"
		cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSC9 := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSC9,.F.,.T.)
		If (cAliasSC9)->(EoF())
			WmsMessage(STR0014,WMSV10002) // Carga inválida!
			lRet := .F.
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSV100PED
Valida se o pedido informado é válido

@param   nTipo       Tipo de endereçamento: 
							1 - Carga/Pedido
							2 - Pedido
@param   cCarga      Código da carga
@param   cPedido     Código do pedido

@return  lRet        Indica se o pedido informado é válido 
@author  Guilherme Alexandre Metzger
@version	P11
@since   01/10/14
/*/
//----------------------------------------------------------
Function WMSV100PED(nTipo,cCarg,cPed)
Local aTela     := VTSave()
Local lRet      := .T.    
Local cQuery    := ''
Local aCarga    := {}
Local cAliasQry := GetNextAlias()   
Local nPos      := 1 

	If Empty(cPed)
		Return .F. 
	EndIf
	
	SC5->(DbSetOrder(1))
	If !SC5->(DbSeek(xFilial('SC5')+cPed))
		WmsMessage(STR0050,WMSV10003) // Pedido invalido!
		lRet := .F.
	EndIf
	
	If nTipo == 1 // Por carga
		If lRet
			cQuery := "SELECT R_E_C_N_O_ AS RECNODAI"
			cQuery +=  " FROM "+RetSqlName('DAI')+" DAI"
			cQuery += " WHERE DAI_FILIAL = '"+xFilial('DAI')+"'"
			cQuery +=   " AND DAI_COD = '"+cCarg+"'"
			cQuery +=   " AND DAI_PEDIDO = '"+cPed+"'"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(Eof())
				WmsMessage(WmsFmtMsg(STR0051,{{"[VAR01]",AllTrim(cPed)},{"[VAR02]",AllTrim(cCarga)}}),WMSV10004) // O pedido [VAR01] não pertence à carga [VAR02]. 
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
		
		If lRet
			cQuery := "SELECT SC9.C9_BLEST,"
			cQuery +=       " SC9.C9_BLCRED,"
			cQuery +=       " SC9.C9_BLWMS,"
			cQuery +=       " SC9.C9_CARGA,"
			cQuery +=       " DCF.DCF_CARGA"
			cQuery +=  " FROM "+RetSqlName('SC9')+" SC9"
			cQuery += " INNER JOIN "+RetSqlName('DCF')+" DCF"
			cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
			cQuery +=   " AND DCF.DCF_ID     = SC9.C9_IDDCF"
			cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
			cQuery +=   " AND SC9.C9_PEDIDO  = '"+cPed+"'"
			cQuery +=   " AND SC9.C9_CARGA   = '"+cCarg+"'"
			cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			While (cAliasQry)->(!Eof()) 
				If !Empty((cAliasQry)->C9_BLEST) .And. (cAliasQry)->C9_BLEST  != "10" 
					WmsMessage(STR0052,WMSV10005) // Pedido com bloqueio de estoque! 
					lRet := .F.
					Exit
				ElseIf !Empty((cAliasQry)->C9_BLCRED) .And. (cAliasQry)->C9_BLCRED != "10"
					WmsMessage(STR0053,WMSV10006) // Pedido com bloqueio de credito! 
					lRet := .F.
					Exit
				ElseIf Empty((cAliasQry)->DCF_CARGA) .And. !Empty((cAliasQry)->C9_CARGA)
					WmsMessage(STR0074,WMSV10022) // Carga não controlada pelo WMS.
					lRet := .F.
					Exit
				EndIf 
				(cAliasQry)->(DbSkip())
			EndDo	 
			(cAliasQry)->(DbCloseArea())
		EndIf
			
	Else // Por pedido
		cQuery := " SELECT SC9.C9_BLEST," 
		cQuery +=        " SC9.C9_BLCRED," 
		cQuery +=        " SC9.C9_BLWMS," 
		cQuery +=        " DCF.DCF_CARGA"
		cQuery +=   " FROM "+RetSqlName('SC9')+" SC9"
		cQuery +=  " INNER JOIN "+RetSqlName('DCF')+" DCF"
		cQuery +=     " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=    " AND DCF.DCF_ID     = SC9.C9_IDDCF"
		cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
		cQuery +=    " AND SC9.C9_PEDIDO  = '"+cPed+"'"
		cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!Eof())
			If !Empty((cAliasQry)->C9_BLEST) .And. (cAliasQry)->C9_BLEST  != "10" 
				WmsMessage(STR0052,WMSV10007) // Pedido com bloqueio de estoque! 
				lRet := .F.
				Exit
			ElseIf !Empty((cAliasQry)->C9_BLCRED) .And. (cAliasQry)->C9_BLCRED != "10"
				WmsMessage(STR0053,WMSV10008) // Pedido com bloqueio de credito! 
				lRet := .F.
				Exit
			ElseIf nTipo == 2 .And. !Empty((cAliasQry)->DCF_CARGA) .And. ( Ascan( aCarga, { |x| x[ 1 ] == (cAliasQry)->DCF_CARGA} ) == 0 ) 
				aAdd(aCarga,{(cAliasQry)->DCF_CARGA} )
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo	 
		(cAliasQry)->(DbCloseArea())
	EndIf		 
	
	If Len(aCarga) > 0
		If Len(aCarga) = 1
			cCarga := aCarga[1][1]
		Else
			// monta browse para selecionar a carga correta
			WMSVTCabec(STR0054, .F., .F., .T.) // Selecione a Carga 
			nPos := VTaBrowse(2,,,,{STR0008},aCarga,{6}) // Carga 
			If !Empty(nPos)
				cCarga := aCarga[nPos][1]
			EndIf	
			VtRestore(,,,,aTela)
		EndIf
	EndIf
	
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
// ValidEnder
// Valida se o endereço informado pode receber o pedido
// 
// lEstorno    Indica se a função foi chamada pelo processo de estorno
// nTipo       Tipo de endereçamento: 
// 				1 - Carga/Pedido
// 				2 - Pedido
// cCarga      Código da carga
// cPedido     Código do pedido
//----------------------------------------------------------
Static Function ValidEnder(lEstorno,nTipo,cEnd,cCarg,cPed,cVol,aVolumes)
Local lRet  := .T.   
Local cSeek := ''
Local nI    := 0
	
	If Empty(cEnd)
		Return .F.
	EndIf

	SBE->(DbSetOrder(9))
	If SBE->(DbSeek(xFilial('SBE')+cEnd))
		DC8->(DbSetOrder(1))
		DC8->(DbSeek(xFilial('DC8')+SBE->BE_ESTFIS))
		If DC8->DC8_TPESTR != "5"
			WmsMessage(STR0055,WMSV10009) // Informe um endereco de estrutura fisica do tipo DOCA!
			lRet := .F.
		EndIf 
	Else
		WmsMessage(STR0023,WMSV10010) // Endereco invalido!
		lRet := .F.
	EndIf 

	If lRet
		If Empty(aVolumes)
			If nTipo == 1 .Or. nTipo == 2
				cSeek := cCarg+cPed+cEnd+AllTrim(cVol)
				nInd  := 1
			Else
				cSeek := cEnd+cVol
				nInd  := 4
			EndIf

			D00->(DbSetOrder(nInd))
			If D00->(DbSeek(xFilial('D00')+cSeek))
				If !lEstorno
					WmsMessage(STR0020,WMSV10011) // Pedido ja enderecado!
					lRet := .F.	
				Else
					If !Empty(D00->D00_CODDOC)
						WmsMessage(STR0056,WMSV10012) // Nao e possivel realizar o estorno. Embarque ja foi efetuado!
						lRet := .F.
					EndIf
				EndIf
			Else
				If lEstorno
					WmsMessage(STR0057,WMSV10013) // Enderecamento do pedido nao encontrado!
					lRet := .F.			
				EndIf	
			EndIf
		Else
			For nI := 1 To Len(aVolumes)
				If nTipo == 1 .Or. nTipo == 2
					cSeek := cCarg+cPed+cEnd+AllTrim(aVolumes[nI])
					nInd  := 1
				Else
					cSeek := cEnd+aVolumes[nI]
					nInd  := 4
				EndIf
				D00->(DbSetOrder(nInd))
				If D00->(DbSeek(xFilial('D00')+cSeek))
					WmsMessage(WmsFmtMsg(STR0058,{{"[VAR01]",AllTrim(aVolumes[nI])}}),WMSV10014) // Volume [VAR01] ja esta enderecado!
					lRet := .F.
					Exit
				EndIf
			Next nI
		EndIf
	EndIf
	
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
// MontaCons
// Monta consulta de endereços da carga/pedido
// 
// nTipo       Tipo de endereçamento: 
//             1 - Carga/Pedido
// 			   2 - Pedido
//----------------------------------------------------------
Static Function MontaCons(nTipo)
Local cKey15    := VtDescKey(15)
Local cKey24    := VtDescKey(24)
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)
Local aTela     := VTSave()
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local aEnds     := {} 
Local nPos      := 1
Local lVolume   := .F.  
Local nLin      := 0

	cConCarga   := Space(TamSx3("DAK_COD")[1])
	cConPedido  := Space(TamSx3("DAI_PEDIDO")[1])
	cConVolume  := Space(TamSx3("DCU_CODVOL")[1])
	
	WMSVTCabec(STR0059, .F., .F., .T.) // Consulta Enderec. 
	If nTipo == 1 .And. Empty(cCarga) // Verifica se cCarga está preenchido para não solicitar novamente
		@ 02, 00 VTSay PadR(STR0008, VTMaxCol()) // Carga
		@ 03, 00 VTGet cConCarga Valid ValidCarga(cConCarga)
		nLin := 3
	EndIf
	If (nTipo == 1 .Or. nTipo == 2) .And. Empty(cPedido) // Verifica se cPedido está preenchido para não solicitar novamente
		@ 01+nLin, 00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
		@ 02+nLin, 00 VTGet cConPedido Valid WMSV100PED(nTipo,cConCarga,cConPedido) .And. WMSV100VOL(2,@lVolume,cConCarga,cConPedido)
		VTRead()
		If VTLastKey() == 27
			VtRestore(,,,,aTela)
			// Restaura Tecla
			VTSetKey(15,bKey15, STR0039)
			VTSetKey(24,bKey24, STR0038)
			Return Nil
		EndIf 
		If lVolume
			@ 03+nLin, 00 VTSay PadR(STR0041, VTMaxCol())	  // Volume
			@ 04+nLin, 00 VTGet cConVolume Valid If(Empty(cConVolume),.T.,WMSV100VOL(1,,cConCarga,cConPedido,cConVolume))
			VTRead()
		EndIf
	ElseIf nTipo == 4 .And. Empty(cVolume) // Verifica se cVolume está preenchido para não solicitar novamente
		@ 02+nLin, 00 VTSay PadR(STR0041, VTMaxCol())	 // Volume
		@ 03+nLin, 00 VTGet cConVolume Valid WMSV100VOL(3,,,,cConVolume)
		VTRead()
	EndIf
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0039)
		VTSetKey(24,bKey24, STR0038)
		Return Nil
	EndIf 
	
	cQuery := "SELECT DISTINCT D00.D00_PEDIDO, D00.D00_CODEND, D00.D00_OPEEND, D00.D00_DATEND, D00.D00_HOREND"
	cQuery +=     " , D00.D00_CODVOL" 	
	cQuery +=  " FROM "+RetSqlName('D00')+" D00"
	// Não considerar os pedidos que já foram faturados.
	cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9"
	cQuery +=    " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=   " AND SC9.C9_PEDIDO = D00.D00_PEDIDO"
	cQuery +=   " AND SC9.C9_NFISCAL = ' '"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
	If Empty(cConVolume)
		If nTipo == 1
			If Empty(cConCarga)
				cConCarga := cCarga
			EndIf
			cQuery += " AND D00.D00_CARGA  = '"+cConCarga+"'"
		EndIf
		If Empty(cConPedido)
			cConPedido := cPedido
		EndIf
		cQuery +=   " AND D00.D00_PEDIDO = '"+cConPedido+"'"
	Else
		If Empty(cConVolume)
			cConVolume := cVolume
		EndIf
		cQuery +=   " AND D00.D00_CODVOL = '"+cConVolume+"'"
	EndIf	
	cQuery +=   " AND D00.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	While (cAliasQry)->(!Eof()) 
		Aadd(aEnds,{(cAliasQry)->D00_PEDIDO,(cAliasQry)->D00_CODEND,(cAliasQry)->D00_OPEEND,(cAliasQry)->D00_DATEND,(cAliasQry)->D00_HOREND,(cAliasQry)->D00_CODVOL})
		(cAliasQry)->(DbSkip())			
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	If Len(aEnds) > 0
		WMSVTCabec(STR0059, .F., .F., .T.)  // Consulta Enderec.
		If nTipo == 1
			@ 1,0 VtSay STR0025+cConCarga+STR0026+cConPedido // C.: // P.:
		EndIf	
		nPos := VTaBrowse(2,,,,{STR0009,STR0012,STR0027,STR0028,STR0029,STR0041},aEnds,{6,15,6,10,5,10}) // Endereco // Operador // Data // Hora // Pedido // Volume
	Else
		If nTipo == 1
			WmsMessage(WmsFmtMsg(STR0060,{{"[VAR01]",AllTrim(cConCarga)},{"[VAR02]",AllTrim(cConPedido)}}),WMSV10015) // Enderecamento para a carga/pedido: [VAR01]/[VAR02] nao encontrado!
		ElseIf nTipo == 2
			WmsMessage(WmsFmtMsg(STR0061,{{"[VAR01]",AllTrim(cConPedido)}}),WMSV10016) // Enderecamento para o pedido: [VAR01] nao encontrado!
		ElseIf nTipo == 3
			WmsMessage(WmsFmtMsg(STR0062,{{"[VAR01]",AllTrim(cConVolume)}}),WMSV10017) // Enderecamento para o Volume: [VAR01] nao encontrado!
		EndIf
		VtKeyboard(Chr(20))  
	EndIf
	VtRestore(,,,,aTela)
	// Restaura Tecla
	VTSetKey(15,bKey15, cKey15)
	VTSetKey(24,bKey24, cKey24)
Return .T.
//----------------------------------------------------------
// GerEstorno
// Realiza o estorno de um endereçamento                              	 			 		    
// 
// nTipo       Tipo de endereçamento: 
// 				1 - Carga/Pedido
// 				2 - Pedido
//----------------------------------------------------------
Static Function GerEstorno(nTipo,lVolume)
Local cKey15  := VtDescKey(15)
Local cKey24  := VtDescKey(24)
Local bkey15  := VTSetKey(15)
Local bkey24  := VTSetKey(24)
Local aTela	:= VTSave()
Local nLin    :=	0
Local cQuery  := ''
Local cAliasQry := GetNextAlias()    
Local cPedidos := ''
Local cEstLocal	:= IIF(D00->( ColumnPos( "D00_LOCEND" ) ) > 0,Space(TamSx3("D00_LOCEND")[1]),"") 
Local aLocEnd := {}

Default lVolume := .F.

	cEstCarga   := Space(TamSx3("DAK_COD")[1])
	cEstPedido  := Space(TamSx3("DAI_PEDIDO")[1])
	cEstEnder   := Space(TamSx3("BE_LOCALIZ")[1])
	cEstVol     := Space(TamSx3("DCU_CODVOL")[1])
	
	WMSVTCabec(STR0030, .F., .F., .T.)   // Estorna Enderecam.
	nLin := 1
	If nTipo == 1 .And. Empty(cCarga)
		@ ++nLin, 00 VTSay PadR(STR0008, VTMaxCol()) // Carga
		@ ++nLin, 00 VTGet cEstCarga Valid ValidCarga(cEstCarga)
	EndIf	
	If (nTipo == 1 .Or. nTipo == 2) .And. Empty(cPedido)
		@ ++nLin, 00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
		@ ++nLin, 00 VTGet cEstPedido Valid WMSV100PED(nTipo,@cEstCarga,cEstPedido) .And. WMSV100VOL(2,@lVolume,cEstCarga,cEstPedido)
		VTRead()
		If VTLastKey() == 27
			VtRestore(,,,,aTela)
			// Restaura Tecla
			VTSetKey(15,bKey15, STR0039)
			VTSetKey(24,bKey24, STR0038)
			Return Nil
		EndIf
	EndIf

	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0039)
		VTSetKey(24,bKey24, STR0038)
		Return Nil
	EndIf

	VtClear()
	nLin := 1
	WMSVTCabec(STR0030, .F., .F., .T.) // Estorna Enderecam.
	If nTipo == 1
		If Empty(cEstCarga)
			cEstCarga := cCarga
		EndIf
		@ ++nLin, 00 VTSay PadR(STR0010+cEstCarga, VTMaxCol())	 // Carga.:
	EndIf	
	If nTipo == 1 .Or. nTipo == 2
		If Empty(cEstPedido)
			cEstPedido := cPedido
		EndIf
		@ ++nLin, 00 VTSay PadR(STR0011+cEstPedido, VTMaxCol()) // Pedido:
	EndIf

	If nTipo == 1 .Or. nTipo == 2
		If lVolume
			@ ++nLin, 00 VTSay PadR(STR0041, VTMaxCol())	  // Volume
			@ ++nLin, 00 VTGet cEstVol Valid WMSV100VOL(1,,cEstCarga,cEstPedido,cEstVol)
			VTRead()
		EndIf
	ElseIf nTipo == 3
		@ ++nLin, 00 VTSay PadR(STR0041, VTMaxCol())	 // Volume
		@ ++nLin, 00 VTGet cEstVol Valid WMSV100VOL(3,,,,cEstVol)
		VTRead()
	EndIf
	
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0039)
		VTSetKey(24,bKey24, STR0038)	
		Return Nil
	EndIf 
	
	VtClear()
	If Empty(cEndereco)
		nLin := 1
		WMSVTCabec(STR0030, .F., .F., .T.) // Estorna Enderecam.
		@ ++nLin, 00 VTSay PadR(STR0012, VTMaxCol()) // Endereco
		@ ++nLin, 00 VTGet cEstEnder Picture "@!" Valid ValidEnder(.T.,nTipo,cEstEnder,cEstCarga,cEstPedido,cEstVol)
		VTRead()

		If !Empty(cEstEnder)
			aLocEnd := WmsLocEnd(cEstEnder)
			If Len(aLocEnd) = 1
				cEstLocal := aLocEnd[1][2]
			ElseIf Len(aLocEnd) > 1
				@ ++nLin,00 VTSay PadR(STR0075,VTMaxCol()) //"Informe o armazem:"
				@ ++nLin,00 VTGet cEstLocal Pict "@!" Valid WmsVldArm(cEstLocal,cEstEnder) F3 'NNR'
				VTRead()
			EndIf
		EndIf
	EndIf
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0039)
		VTSetKey(24,bKey24, STR0038)
		Return Nil
	EndIf
	
	If Empty(cEstEnder)
		cEstEnder := cEndereco
	EndIf

	If nTipo == 1
		cMsg := WmsFmtMsg(STR0063,{{"[VAR01]",AllTrim(cEstCarga)},{"[VAR02]",AllTrim(cEstPedido)},{"[VAR03]",AllTrim(cEstEnder)}}) // Confirma o estorno do enderecamento da Carga: [VAR01] / Pedido: [VAR02] no endereço: [VAR03]		
	ElseIf nTipo == 2
		cMsg := WmsFmtMsg(STR0064,{{"[VAR01]",AllTrim(cEstPedido)},{"[VAR02]",AllTrim(cEstEnder)}}) // Confirma o estorno do enderecamento do Pedido: [VAR01] no endereço: [VAR02]
	Else
		cMsg := WmsFmtMsg(STR0065,{{"[VAR01]",AllTrim(cEstVol)},{"[VAR02]",AllTrim(cEstEnder)}}) // Confirma o estorno do enderecamento do Volume: [VAR01] no endereço: [VAR02]				
	EndIf	

	WMSVTCabec(STR0035, .F., .F., .T.) // Atenção
	If VtYesNo(AllTrim(cMsg),STR0035) // Atenção
		// query para filtrar pelo codigo do volume quando for informando, fazendo um While para deletar todos os pedidos do volume
		cQuery := "SELECT D00_PEDIDO, D00_CODEND, D00_OPEEND, D00_DATEND, D00_HOREND, R_E_C_N_O_ nRec"
		cQuery +=      ", D00_CODVOL"   	
		cQuery +=  " FROM "+RetSqlName('D00')+" D00"
		cQuery += " WHERE D00_FILIAL = '"+xFilial('D00')+"'"
		If Empty(cEstVol)
			If nTipo == 1
				cQuery += " AND D00_CARGA  = '"+cEstCarga+"'"
			EndIf
			cQuery +=   " AND D00_PEDIDO = '"+cEstPedido+"'"
		Else
			cQuery +=   " AND D00_CODVOL = '"+cEstVol+"'"
		EndIf	
		cQuery +=   " AND D00_CODEND = '"+cEstEnder+"'"
		If lD00Local .And. lWMSAltDca
			cQuery +=   " AND D00_LOCEND = '"+cEstLocal+"'"
		EndIf
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		
		While (cAliasQry)->(!Eof()) 
			D00->(dbGoTo((cAliasQry)->nRec))   	
			If (D00->D00_TIPEMB == "1")
				WmsMessage(STR0040,WMSV10018) // Não foi possivel realizar o estorno!
				VtKeyboard(Chr(20))  
				Exit
			Else
				cPedidos += If(Empty(cPedidos),'',', ') + D00->D00_PEDIDO 	
				RecLock("D00",.F.)
				D00->(DbDelete())
				D00->(MsUnlock())
			EndIf	
			(cAliasQry)->(DbSkip())
		EndDo	 
		If lVolume
			WmsMessage(STR0066+cPedidos,WMSV10019) // Estornado o enderecamento do volume com os Pedidos:
			VtKeyboard(Chr(20))	
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	VtRestore(,,,,aTela)
	// Restaura Tecla
	VTSetKey(15,bKey15, STR0039)
	VTSetKey(24,bKey24, STR0038)
Return Nil
//----------------------------------------------------------
// GravaDados
// Gravação das informações do endereçamento na tabela D00                          	 			 		    
// 
// nTipo       Tipo de endereçamento: 
// 				1 - Carga/Pedido
// 				2 - Pedido
//----------------------------------------------------------
Static Function GravaDados(nTipo,dDtIni,cHrIni,aVolumes)
Local aTela := VTSave()
Local cMsg  := "" 
Local cSeek := ""
Local nInd  := 0
Local i     := 0

	If nTipo == 1
		cMsg	:= WmsFmtMsg(STR0067,{{"[VAR01]",AllTrim(cCarga)},{"[VAR02]",AllTrim(cPedido)},{"[VAR03]",AllTrim(cEndereco)}}) // Confirma o enderecamento da Carga: [VAR01] / Pedido: [VAR02] no endereco: [VAR03]
		cSeek	:= cCarga+cPedido+cEndereco
		nInd	:= 1
	ElseIf nTipo == 2
		cMsg	:= WmsFmtMsg(STR0068,{{"[VAR01]",AllTrim(cPedido)},{"[VAR02]",AllTrim(cEndereco)}}) // Confirma o enderecamento do Pedido: [VAR01] no endereço: [VAR02]
		cSeek	:= cPedido+cEndereco
		nInd	:= 3
	ElseIf nTipo == 3
		cMsg	:= WmsFmtMsg(STR0069,{{"[VAR01]",AllTrim(cEndereco)}}) // Confirma o enderecamento do Volumes no endereco: [VAR01]
	EndIf
	If Len(aPedidos) == 0
		For i := 1 to Len(aVolumes)
			aAdd(aPedidos,{cCarga,cPedido,aVolumes[i]})
		Next i
		If Len(aVolumes) == 0
			aAdd(aPedidos,{cCarga,cPedido,""})
		EndIf
	EndIf	
	
	WMSVTCabec(STR0035, .F., .F., .T.) // Atenção
	If VtYesNo(AllTrim(cMsg),STR0035) // Atenção      
		Begin Transaction
			For i:= 1 to Len(aPedidos)
				dbSelectArea("D00")
				dbSetOrder(1)
				If !dbSeek(xFilial("D00")+aPedidos[i][1]+aPedidos[i][2]+cEndereco+AllTrim(aPedidos[i][3]))
					RecLock("D00",.T.)
					D00->D00_FILIAL	:= xFilial("D00")
					D00->D00_CARGA	:= aPedidos[i][1] // cCarga
					D00->D00_PEDIDO	:= aPedidos[i][2] // cPedido
					D00->D00_CODEND	:= cEndereco
					D00->D00_OPEEND	:= cCodOpe
					D00->D00_DATEND	:= dDtIni
					D00->D00_HOREND	:= cHrIni
					D00->D00_CODVOL := aPedidos[i][3] // cVolume
					D00->D00_DTENDF := dDataBase
					D00->D00_HRENDF := Time()
					D00->D00_TIPEMB := "0"
					D00->D00_LIBEST := "2"
					If lD00Local
						D00->D00_LOCEND := cLocal
					EndIf
					D00->(MsUnLock())
				EndIf	
			Next i		
		End Transaction 	
	EndIf 
	
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		Return Nil
	EndIf     
	
	VtRestore(,,,,aTela)
Return Nil
//--------------------------------------------------------------------------
/*/{Protheus.doc} WMSV100VOL
Verifica se um pedido esta contido em um volume e monta array com os pedidos.
Também checa se o volume informado é válido.
@author evaldo.cevinscki
@since 11/11/2014
@version 1.0
@param nAcao, numérico, (1=Valida Volume; 2=Valida pedido)
@param cSeek, character, (chave da consulta)
@param lVolume, (retorna .T. quando o pedido tem volume)
/*/
//--------------------------------------------------------------------------
Function WMSV100VOL(nAcao,lVolume,cCarga,cPedido,cVolume)
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lRet      := .T.
Local cVolUsado := ""
Local oMntVol   := Nil

Default lVolume := .F.
Default cCarga  := Space(TamSx3("C9_CARGA")[1])
Default cPedido := Space(TamSx3("C9_PEDIDO")[1])
Default cVolume := Space(TamSx3("DCU_CODVOL")[1])

	If !lWmsNew
		Return .T.
	EndIf

	If nAcao == 1 .Or. nAcao == 3
		nIndDCU := 1 // DCU_FILIAL+DCU_CODVOL+DCU_CODMNT
		cSeek := cVolume
	Else
		nIndDCU := 2 // DCU_FILIAL+DCU_CARGA+DCU_PEDIDO+DCU_CODMNT+DCU_CODVOL
		cSeek := cCarga+cPedido
	EndIf
	
	If Empty(cSeek)
		Return .F.
	EndIf
	
	//Verifica se o pedido monta volume e se o volume já encontra-se montado.
	oMntVol := WMSDTCMontagemVolume():New()
	oMntVol:SetCarga(cCarga)
	oMntVol:SetPedido(cPedido)
	oMntVol:SetCodMnt(oMntVol:FindCodMnt())
	If oMntVol:LoadData()
		lVolume := .T.
	EndIf	

	dbSelectArea("DCU")
	DCU->(dbSetOrder(nIndDCU))
	If MsSeek(xFilial("DCU")+cSeek)
		lVolume := .T.
		If nAcao == 1 .Or. nAcao == 3
			// se o volume possuir mais de um pedido irá gravar o endereçamento para cada um dos pedidos além do que esta sendo informado.
			If lRet
				If nAcao == 1
					cVolUsado := DCU->DCU_CODVOL
					lRet := .F.
				EndIf
				While !Eof() .And. DCU->DCU_FILIAL == xFilial("DCU") .And. DCU->(DCU_CODVOL) == cSeek
					If nAcao == 1 .And. DCU->(DCU_CARGA+DCU_PEDIDO) == cCarga+cPedido
						lRet := .T.
					EndIf
					
					aAdd(aPedidos,{DCU->DCU_CARGA, DCU->DCU_PEDIDO, DCU->DCU_CODVOL})
					DCU->(dbSkip())
				End
				If !lRet
					VtAlert(STR0042,STR0002,.T.,4000,3) // Volume não pertence a carga/pedido!
					VtKeyboard(Chr(20))
					
					If aScan(aPedidos, {|x| x[3] == cVolUsado}) > 0
						aPedidos := {}
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf nAcao == 1 .Or. nAcao == 3
		VtAlert(STR0043,STR0002,.T.,4000,3)  // Volume não identificado!
		VtKeyboard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
//-------------------------------------------------------------------------
// query para filtrar pelo codigo do volume quando for informando
//-------------------------------------------------------------------------
Static Function VldVol(cVolume)
Local lRet := .T.
Local cAliasQry := GetNextAlias()

	cQuery := "SELECT D00_PEDIDO, D00_CODEND, D00_OPEEND, D00_DATEND, D00_HOREND, R_E_C_N_O_ nRec"
	cQuery +=  " FROM "+RetSqlName('D00')+" D00"
	cQuery += " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
	cQuery +=   " AND D00.D00_CODVOL = '"+cVolume+"'"
	cQuery +=   " AND D00.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	If (cAliasQry)->(!Eof()) 
		WmsMessage(WmsFmtMsg(STR0070,{{"[VAR01]",AllTrim((cAliasQry)->D00_CODEND)}}),WMSV10020) // Enderecamento do volume ja realizado no endereço [VAR01]! 
		VtKeyboard(Chr(20))
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())	
Return lRet
/*--------------------------------------------------------------------------
---MntVolume
---Visualiza os todos os volumes informados para a carga/pedido corrente
---felipe.m 03/06/2015
---Esta opção só é habilitada quando o usuário está informando os volumes
--------------------------------------------------------------------------*/
Static Function MntVolume(aVolumes)
Local cKey15 := VtDescKey(15)
Local cKey24 := VtDescKey(24)
Local cKey22 := VtDescKey(22)
Local cKey21 := VtDescKey(21)
Local bkey15 := VTSetKey(15)
Local bkey24 := VTSetKey(24)
Local bkey22 := VTSetKey(22)
Local bkey21 := VTSetKey(21)
Local aTela  := VTSave()
Local nI     := 0
Local aItens := {}

	For nI := 1 To Len(aVolumes)
		aAdd(aItens,{aVolumes[nI]})
	Next nI
	
	VTaBrowse(2,0,VTMaxRow(),VTMaxCol(),{Padr(STR0071,VTMaxCol())},aItens,{VTMaxCol()},,1) // Consulta Volumes
		
	VTSetKey(15,bKey15, cKey15)
	VTSetKey(24,bKey24, cKey24)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(21,bKey21, cKey21)
	// Restaura Tecla
	VtRestore(,,,,aTela)
Return .T.
/*--------------------------------------------------------------------------
---EstVolume
---Estorna o volume informado
---felipe.m 03/06/2015
---Esta opção só é habilitada quando o usuário está informando os volumes
--------------------------------------------------------------------------*/
Static Function EstVolume(aVolumes,nTipo)
Local cKey15 := VtDescKey(15)
Local cKey24 := VtDescKey(24)
Local cKey22 := VtDescKey(22)
Local cKey21 := VtDescKey(21)
Local bkey15 := VTSetKey(15)
Local bkey24 := VTSetKey(24)
Local bkey22 := VTSetKey(22)
Local bkey21 := VTSetKey(21)
Local aTela  := VTSave()
Local nLin   := 1
Local nPos   := 1
	
	cVolume := Space(TamSx3("DCU_CODVOL")[1])
	WMSVTCabec(STR0046, .F., .F., .T.) // Estorno Volume
	If nTipo == 1
		@ ++nLin,00 VTSay PadR(STR0010+cCarga, VTMaxCol()) // Carga.:
	EndIf
	If nTipo == 1 .Or. nTipo == 2
		@ ++nLin,00 VTSay PadR(STR0011+cPedido, VTMaxCol()) // Pedido:
		@ ++nLin,00 VTSay PadR(STR0041, VTMaxCol()) // Volume
		@ ++nLin,00 VTGet cVolume Valid ValidVol(aVolumes,cVolume,@nPos) 
		VTRead()
	Else
		@ ++nLin,00 VTSay PadR(STR0041, VTMaxCol()) // Volume
		@ ++nLin,00 VTGet cVolume Valid ValidVol(aVolumes,cVolume,@nPos)
		VTRead()
	EndIf
	
	If VtLastKey() != 27
		If nPos > 0
			aDel(aVolumes,nPos)
			aSize(aVolumes,Len(aVolumes)-1)
		EndIf
	EndIf

	VTSetKey(15,bKey15, cKey15)
	VTSetKey(24,bKey24, cKey24)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(21,bKey21, cKey21)
	// Restaura Tecla
	VtRestore(,,,,aTela)
Return .T.

Static Function ValidVol(aVolumes,cVolume,nPos)
Local lRet := .T.
	If !Empty(cVolume) .And. (nPos := aScan(aVolumes,{|x| x == cVolume})) == 0
		VtAlert(STR0072,STR0002,.T.,4000,3) // Volume invalido!
		VtKeyboard(Chr(20))
		lRet := .F.
	EndIf
Return lRet


Function WmsVldArm(cArmazem, cEnd)
Local lRet := .T.
Local aArea := GetArea()

	If Empty(cArmazem)
		Return .F.
	EndIf

	SBE->(DbSetOrder(1))
	If !SBE->(DbSeek(FwXFilial("SBE")+cArmazem+cEnd))
		WMSVTAviso(WMSV10023,STR0076) // Armazem invalido!
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet

//----------------------------------------------------------
// Função para buscar todos locais de estoque de um endereco
//----------------------------------------------------------
Function WmsLocEnd(cEndereco)
	Local aEnd := {}
	Local cQuery := ""
	Local cAliasQry := GetNextAlias()   

	cQuery := " SELECT BE_FILIAL ,BE_LOCAL,BE_LOCALIZ" 
	cQuery += 	" FROM "+RetSqlName('SBE')+" SBE"
	cQuery += 		" INNER JOIN "+RetSqlName("DC8")+" DC8"
	cQuery += 			" ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery += 			" AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery += 			" AND DC8.DC8_TPESTR = '5'"
	cQuery += 			" AND DC8.D_E_L_E_T_ = ' '"
	cQuery += 		" WHERE SBE.BE_FILIAL  = '"+xFilial('SBE')+"'"
	cQuery += 			" AND SBE.BE_LOCALIZ  = '"+cEndereco+"'"
	cQuery += 			" AND SBE.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		aAdd(aEnd,{(cAliasQry)->BE_FILIAL,(cAliasQry)->BE_LOCAL,(cAliasQry)->BE_LOCALIZ} )
		(cAliasQry)->(DbSkip())
	EndDo	 
	(cAliasQry)->(DbCloseArea())

Return aEnd
