#Include 'Protheus.ch' 
 
//-------------------------------------------------------------------
/*{Protheus.doc} RUP_GFE 
Função de compatibilização do release incremental.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
Ex: para o módulo SIGACTB criar a função RUP_CTB

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Wander
@since 03/07/2015
@version P12
*/ 
//-------------------------------------------------------------------
Function RUP_GFE( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Static cSeverity      := "INFO"
	Static cTransactionId := FWUUIDV1()
	Static cGroup         := "RUP_GFE"
	Static cCategory      := ProcName(0)
	Static cStep          := "01"
	Static cMsgId         := "01"
	Static cMessage       := ""
	Static nMensure       := 0
	Static nElapseTime    := 0
	Static aMessage       := {}

	cMessage := 'Verificando necessidade de atualizacao...'
	FWLogMsg(cSeverity, cTransactionId, cGroup, cCategory , cStep, cMsgId, cMessage, nMensure, nElapseTime, aMessage)
	
	cMessage := 'Versao: ' + cVersion + ' / Modo: ' + cMode + ' / Release Inicial: ' + cRelStart + ' Release Final:  ' + cRelFinish
	FWLogMsg(cSeverity, cTransactionId, cGroup, cCategory , cStep, cMsgId, cMessage, nMensure, nElapseTime, aMessage)

	If AllTrim(cLocaliz) == 'BRA'
		GFE12121( cVersion, cMode, cRelStart, cRelFinish, cLocaliz ) // Alterações realizadas na 12.1.21
		
		// Necessidade de alteração única por grupo de empresas
		// Efetuada na função principal, para uma mudança futura no RUP_GFE
		If cMode == "1"
			GFE12117( cVersion, cMode, cRelStart, cRelFinish, cLocaliz ) // Alterações realizadas na 12.1.17
			GFE12120( cVersion, cMode, cRelStart, cRelFinish, cLocaliz ) // Alterações realizadas na 12.1.20
			GFE12123( cVersion, cMode, cRelStart, cRelFinish, cLocaliz ) // Alterações realizadas na 12.1.23
			GFE12127( cVersion, cMode, cRelStart, cRelFinish, cLocaliz ) // Alterações realizadas na 12.1.27
			GFE12133( cVersion, cMode, cRelStart, cRelFinish, cLocaliz ) // Alterações realizadas na 12.1.33
		EndIf
	EndIf
Return Nil

Static Function GFE12133( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	//Exclusão dos relacionamentos.
	SX9->( dbSetOrder(2))
	SX9->( dbSeek('GXR'+'GU3'))
		Do While SX9->(!Eof()) .And. SX9->X9_CDOM == 'GXR' .And. SX9->X9_DOM == 'GU3'
		If Alltrim(SX9->X9_EXPCDOM) == 'GXR_CODUSU' .Or. Alltrim(SX9->X9_EXPCDOM) == 'GXR_USUPER' .Or. Alltrim(SX9->X9_EXPCDOM) == 'GXR_USUEXE'
			If RecLock("SX9",.F.)
				SX9->( dbDelete() )
			EndIf
		EndIf
		SX9->( dbSkip() )
	EndDo

	SX9->( dbSetOrder(2))
	SX9->( dbSeek('GV1'+'GUY'))
	Do While SX9->(!Eof()) .And. SX9->X9_CDOM == 'GV1' .And.  SX9->X9_DOM == 'GUY'
		If Alltrim(SX9->X9_EXPDOM) == 'GUY_CDCOMP' 
			If RecLock("SX9",.F.)
				SX9->( dbDelete() )
			EndIf
		EndIf
		SX9->( dbSkip() )
	EndDo

	SX9->( dbSetOrder(2))
	SX9->( dbSeek('GUC'+'GUY'))
	Do While SX9->(!Eof()) .And. SX9->X9_CDOM == 'GUC' .And.  SX9->X9_DOM == 'GUY'
		If Alltrim(SX9->X9_EXPDOM) == 'GUY_CDCOMP' 
			If RecLock("SX9",.F.)
				SX9->( dbDelete() )
			EndIf
		EndIf
		SX9->( dbSkip() )
	EndDo

	SX9->( dbSetOrder(2))
	SX9->( dbSeek('GV6'+'GV9'))
	Do While SX9->(!Eof()) .And. SX9->X9_CDOM == 'GV6' .And.  SX9->X9_DOM == 'GV9'
		If Alltrim(SX9->X9_EXPDOM) == 'GV9_CDEMIT'
			If RecLock("SX9",.F.)
				SX9->( dbDelete() )
			EndIf
		EndIf
		SX9->( dbSkip() )
	EndDo

	SX9->( dbSetOrder(2))
	SX9->( dbSeek('GV6'+'GVA'))
	Do While SX9->(!Eof()) .And. SX9->X9_CDOM == 'GV6' .And.  SX9->X9_DOM == 'GVA'
		If Alltrim(SX9->X9_EXPDOM) == 'GVA_CDEMIT'
			If RecLock("SX9",.F.)
				SX9->( dbDelete() )
			EndIf
		EndIf
		SX9->( dbSkip() )
	EndDo
Return

Static Function GFE12127( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local aDadosSX3   := {}

	If cVersion == '12'
		aAdd( aDadosSX3, { 'GV6_HRATU'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GV9_HRCRIA' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GV9_HRAPR'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVA_HRCRIA' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVA_HRATU'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVA_HRAPR'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVD_HRSIT'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HR1'    ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HR2'    ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HR3'    ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HR4'    ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HR5'    ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HRSEG'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HRTER'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HRQUA'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HRQUI'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HRSEX'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HRSAB'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GVL_HRDOM'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW1_HRIMPL' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW1_HRLIB'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW1_HRPSAI' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW1_HRSAI'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW1_HRPENT' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW1_HRALT'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW1_HRCAN'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW2_HRFIN'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW2_HRRH'   ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW2_HRREC'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW6_HRBLOQ' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW6_HRAPR ' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GW6_HRFIN ' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWD_HROCOR' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWD_HRCRIA' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWD_HRBAI ' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWF_HRCRIA' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWF_HRPREN' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWJ_HRIMPL' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWJ_HRAPR'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWJ_HRENV'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWJ_HRCAN'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWN_HRIMPL' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWN_HRCALC' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWN_HRSAI ' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWO_HRAJUS' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWO_HRAPRP' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWV_HRAGEN' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWV_HRENVI' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWV_HRCONF' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GWV_HRCRIA' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GX3_HRCRIA' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GX6_HRENTR' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GX6_HRSAI'  ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GXB_HRCHAM' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GXL_HROCOR' ,'X3_PICTURE', '99:99' })
		aAdd( aDadosSX3, { 'GV6_USUATU' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GV9_USUAPR' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GV9_USUCRI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GVA_USUAPR' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GVA_USUATU' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GVA_USUCRI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GVL_USUAR'  ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW1_USUALT' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW1_USUCAN' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW1_USUIMP' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW2_USUCAN' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW2_USUCRI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW2_USUFIN' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW2_USUREC' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW2_USURH'  ,'X3_PICTURE', ' ' }) 
		aAdd( aDadosSX3, { 'GW3_USUAPR' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW3_USUBLQ' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW3_USUIMP' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW6_USUAPR' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW6_USUBLO' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW6_USUFIN' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GW6_USUIMP' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWD_USUBAI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWF_USUCRI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWJ_USUAPR' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWJ_USUCAN' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWJ_USUENV' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWJ_USUIMP' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWN_USUIMP' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWV_USUCAN' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GWV_USUCRI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GX3_USUCRI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GX4_REPUSU' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GX4_USUENT' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GX4_USUPES' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GX4_USUSAI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GXN_USUCRI' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GXR_NOMUSU' ,'X3_PICTURE', ' ' })
		aAdd( aDadosSX3, { 'GXT_USUAR'  ,'X3_PICTURE', ' ' })
	EndIf
	GFEEngSx3(aDadosSX3) //Função que executa a macro para atualizar dados no dicionário (SX3).
Return

Static Function GFE12123( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local cModoGXS    := ''
	Local cModoUnGXS  := ''
	Local cModoEmpGXS := ''
	Local cFilAux     := PadR(cfilAnt, TamSX3("GW0_FILIAL")[1])
	Local aDadosSX3   := {}

	If cVersion == '12' .And. cRelStart <= '017'
		aAdd( aDadosSX3, { 'GVP_DESGRP' ,'X3_ORDEM', '07' })
		aAdd( aDadosSX3, { 'GVP_EDITDT' ,'X3_ORDEM', '08' })
	

		aAdd( aDadosSX3, { 'GU8_PLACA'  ,'X3_PICTURE', '@!' })
		aAdd( aDadosSX3, { 'GW2_PLACA1' ,'X3_PICTURE', '@!' })
		aAdd( aDadosSX3, { 'GW2_PLACA2' ,'X3_PICTURE', '@!' })
		aAdd( aDadosSX3, { 'GW2_PLACA3' ,'X3_PICTURE', '@!' })
		aAdd( aDadosSX3, { 'GWN_PLACAD' ,'X3_PICTURE', '@!' })
		aAdd( aDadosSX3, { 'GWN_PLACAT' ,'X3_PICTURE', '@!' })
		aAdd( aDadosSX3, { 'GWN_PLACAM' ,'X3_PICTURE', '@!' })
		aAdd( aDadosSX3, { 'GX6_PLACA'  ,'X3_PICTURE', '@!' })
	
		GFEEngSx3(aDadosSX3) //Função que executa a macro para atualizar dados no dicionário (SX3).

		SX6->(dbSetOrder(1)) //X6_FIL+X6_VAR
		If SX6->(dbSeek(cFilAux + "MV_INTFRE"))
			If RecLock("SX6",.F.)
				SX6->X6_VALID := "AllTrim(X6_CONTEUD) == '1' .Or. IIf(SuperGetMV('MV_ERPGFE',.F.,'1') == '1',.T.,MsgAlert('Funcionalidade do ERP Datasul')!=Nil)"
				SX6->(MsUnlock())
			EndIf
		ElseIf SX6->(dbSeek(Space(Len(cFilAux)) + "MV_INTFRE"))
			If RecLock("SX6",.F.)
				SX6->X6_VALID := "AllTrim(X6_CONTEUD) == '1' .Or. IIf(SuperGetMV('MV_ERPGFE',.F.,'1') == '1',.T.,MsgAlert('Funcionalidade do ERP Datasul')!=Nil)"
				SX6->( MSUnlock())
			EndIf
		EndIf
			
		SX6->(dbSetOrder(1)) //X6_FIL+X6_VAR
		If SX6->(dbSeek(cFilAux + "MV_GFEPP01"))
			Do While SX6->(!Eof()) .And. Alltrim(SX6->X6_VAR) == "MV_GFEPP01"
				If SX6->X6_TIPO == "C"
					If RecLock("SX6",.F.)
						SX6->( dbDelete() )
					EndIf
				EndIf
				SX6->( dbSkip() )
			EndDo
		ElseIf SX6->(dbSeek(space(len(cFilAux)) + "MV_GFEPP01"))
			Do While SX6->(!Eof()) .And. Alltrim(SX6->X6_VAR) == "MV_GFEPP01"
				If SX6->X6_TIPO == "C"
					If RecLock("SX6",.F.)
						SX6->( dbDelete() )
					EndIf
				EndIf
				SX6->( dbSkip() )
			EndDo
		EndIf
			
		If SX6->(dbSeek(cFilAux + "MV_GFEPP02"))
			Do While SX6->(!Eof()) .And. Alltrim(SX6->X6_VAR) == "MV_GFEPP02"
				If SX6->X6_TIPO == "C"
					If RecLock("SX6",.F.)
						SX6->( dbDelete() )
					EndIf
				EndIf
				SX6->( dbSkip() )
			EndDo
		ElseIf SX6->(dbSeek(space(len(cFilAux)) + "MV_GFEPP02"))
			Do While SX6->(!Eof()) .And. Alltrim(SX6->X6_VAR) == "MV_GFEPP02"
				If SX6->X6_TIPO == "C"
					If RecLock("SX6",.F.)
						SX6->( dbDelete() )
					EndIf
				EndIf
				SX6->( dbSkip() )
			EndDo
		EndIf
			
		If SX6->(dbSeek(cFilAux + "MV_GFEPP03"))
			Do While SX6->(!Eof() ) .And. Alltrim(SX6->X6_VAR) == "MV_GFEPP03"
				If SX6->X6_TIPO == "C"
					If RecLock("SX6",.F.)
						SX6->( dbDelete() )
					EndIf
				EndIf
				SX6->( dbSkip() )
			EndDo
		ElseIF SX6->(dbSeek(Space(Len(cFilAux)) + "MV_GFEPP03"))
			Do While SX6->(!Eof() ) .And. Alltrim(SX6->X6_VAR) == "MV_GFEPP03"
				If SX6->X6_TIPO == "C"
					If RecLock("SX6",.F.)
						SX6->( dbDelete() )
					EndIf
				EndIf
				SX6->( dbSkip() )
			EndDo
		EndIf
			
		//Exclusão dos relacionamentos.
		SX9->( dbSetOrder(2))
		SX9->( dbSeek('GXR'+'GU3'))
		Do While SX9->(!Eof()) .And. SX9->X9_CDOM == 'GXR' .And. SX9->X9_DOM == 'GU3'
			If SX9->X9_IDENT == '004' .Or. SX9->X9_IDENT == '005'
				If RecLock("SX9",.F.)
					SX9->( dbDelete() )
				EndIf
			EndIf
			SX9->( dbSkip() )
		EndDo
	EndIf

	#IFDEF TOP
		If cVersion == '12' .And. cRelStart <= '017'
			SX2->(dbSetOrder(1))
			If SX2->(dbSeek('GXS')) .And. TcCanOpen (RetSQLName('GXS'))
				cModoGXS    := SX2->X2_MODO
				cModoUnGXS  := SX2->X2_MODOUN
				cModoEmpGXS := SX2->X2_MODOEMP
			EndIf
			If SX2->(dbSeek('GXT')) .And. TcCanOpen (RetSQLName('GXT'))
				If (cModoGXS != SX2->X2_MODO) .OR. (cModoUnGXS != SX2->X2_MODOUN) .OR. (cModoEmpGXS != SX2->X2_MODOEMP)
					RecLock("SX2",.F.)
						SX2->X2_MODO    := cModoGXS
						SX2->X2_MODOUN  := cModoUnGXS
						SX2->X2_MODOEMP := cModoEmpGXS
					SX2->(MSUnlock() )
				EndIf
			EndIf
		EndIf
	#ENDIF
	
Return

Static Function GFE12121( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local cGrupo    := ""
	Local cOrdem    := ""
	Local aDadosSX3 := {}
	Local cFilAux   := Padr(cfilAnt, TamSX3("GW0_FILIAL")[1])
	Local nCount    := 0

	If cVersion == '12' .And. cMode = '2' .And. cRelStart <= '017'

		dbSelectArea("GW0")
		GW0->(dbSetOrder(1))//GW0_FILIAL+GW0_TABELA+GW0_CHAVE
			
		//Verifica se existe uma atualização feita para a filail especifica
		If GW0->(!dbSeek(cFilAux + Padr("SX6", TamSX3("GW0_TABELA")[1]) + Padr('RUPGFE_MV_ITEMTRP_MV_GFE002', TamSX3("GW0_CHAVE")[1])))
			AlterItemTrp(cFilAux/*Filial*/)
		EndIf

		//Verifica se existe uma atualização  feita para a todas filail
		If GW0->(!dbSeek(Space(Len(cFilAux)) + Padr("SX6", TamSX3("GW0_TABELA")[1]) + Padr('RUPGFE_MV_ITEMTRP_MV_GFE002', TamSX3("GW0_CHAVE")[1])))
			AlterItemTrp(Space(Len(cFilAux))/*Filial*/)
		EndIf
	EndIf

	If cVersion == '12' .And. cMode = '1' .And. cRelStart <= '017'
		aAdd( aDadosSX3, { 'GUN_TPTAB' ,'X3_VISUAL', 'V'  })

		GFEEngSx3( aDadosSX3 ) //Função que executa a macro para atualizar dados no dicionário (SX3).
		
		//Elimina campos duplicados do pergunte GFER063
		SX1->(DBSetOrder(1)) 
		cGrupo := PadR('GFER063', Len(SX1->X1_GRUPO), ' ')
		cOrdem := PadR('1', Len(SX1->X1_ORDEM), ' ')
		If SX1->(dbSeek(cGrupo + cOrdem))
			For nCount := 1 To 9
				cOrdem := PADR(nCount, LEN(SX1->X1_ORDEM))
				If SX1->(dbSeek(cGrupo + cOrdem))
					RecLock('SX1',.F.)
						SX1->(dbDelete())
					SX1->( MSUnlock() )
				EndIf
			Next nCount
		EndIf
	EndIf
Return Nil

Static Function GFE12120( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local cAliasQry := Nil
	Local aDadosSX3 := {}

	If cVersion == '12' .And. cRelStart <= '017'
		aAdd( aDadosSX3, { 'GWR_ORDEM' ,'X3_VISUAL', 'A' })
		aAdd( aDadosSX3, { 'GUN_TPTAB' ,'X3_VISUAL', 'V' })

		GFEEngSx3( aDadosSX3 ) //Função que executa a macro para atualizar dados no dicionário (SX3).
		// Quando vazio, o parametro existe e não tem nada informado
		If SuperGetMv("MV_GFEGUL",.F.,"X") == " "
			PutMV("MV_GFEGUL",IIf(GUL->(LastRec()) > 0,"1","2"))
		EndIf

		// Quando vazio, o parametro existe e não tem nada informado
		If SuperGetMv("MV_GFEGVR",.F.,"X") == " "
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek('GVR_NRREG'))
				PutMV("MV_GFEGVR",IIf(GVR->(LastRec()) > 0,"1","2"))
			Else
				PutMV("MV_GFEGVR","2")
			EndIf
		EndIf
	EndIf

	#IFDEF TOP
		If cVersion == '12' .And. cRelStart <= '017'
			// Quando vazio, o parametro existe e não tem nada informado
			If SuperGetMv("MV_GFEVIN",.F.,"X") == " "
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:GVA% GVA
					WHERE GVA.GVA_TPTAB = '2'
					AND GVA.%NotDel%
				EndSql
				PutMV("MV_GFEVIN",IIf((cAliasQry)->(!Eof()),"1","2"))
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	#ENDIF
Return

Static Function GFE12117( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local cQuery := ""

	#IFDEF TOP
		If cVersion == '12' .And. cRelStart <= '017'		
			dbSelectArea("SX3")
			SX3->(dbSetOrder(2))
			If SX3->(dbSeek('GUY_REENT'))
				cQuery := "UPDATE " + RetSqlName('GUY')
				cQuery +=   " SET GUY_REENT  = '1' "
				cQuery += " WHERE GUY_REENT  = ' ' "
				cQuery +=   " AND D_E_L_E_T_ = ' '"
				TcSQLExec(cQuery)
			EndIf
	
			If SX3->(dbSeek('GV9_SITCON'))
				cQuery := "UPDATE " + RetSqlName('GV9')
				cQuery +=   " SET GV9_SITCON  = '1' "
				cQuery += " WHERE GV9_SITCON  = ' ' "
				cQuery +=   " AND D_E_L_E_T_ = ' '"
				TcSQLExec(cQuery)
			EndIf
		EndIf
	#ENDIF
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} GFEEngSx3()
Função que executa a macro de ajuste de conteúdo de campos do dicionário
referente ao arquivo SX3.

@author  Elynton Fellipe Bazzo
@since   15/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEEngSx3(aDados)
	Local nF     := 0
	Local nI     := 0
	Local cCampo := ""
	Local cAtrib := ""
	Local xValue := ""

	Default aDados := {}

	If !Empty(aDados)
		SX3->(DbSetOrder(2))
		nF := Len(aDados)
		For nI := 1 To nF
			cCampo := AllTrim(aDados[nI,1])
			cAtrib := AllTrim(aDados[nI,2])
			xValue := AllTrim(aDados[nI,3])
			If (cAtrib == 'X3_TAMANHO' .Or. cAtrib == 'X3_DECIMAL')
				xValue := aDados[nI,3]
			EndIf
			If SX3->(dbSeek(cCampo))
				If RecLock("SX3",.F.)
					&("SX3->"+cAtrib) := xValue
					SX3->(MsUnLock())
				EndIf
			EndIf
		Next nI
	EndIf
Return

Static Function AlterItemTrp( cFilAux )
	Local cX6_Tipo    := ""
	Local cX6_Descric := ""
	Local cX6_Dscspa  := ""
	Local cX6_Dsceng  := ""
	Local cX6_Desc1   := ""
	Local cX6_Dscspa1 := ""
	Local cX6_Dsceng1 := ""
	Local cX6_Desc2   := ""
	Local cX6_Dscspa2 := ""
	Local cX6_Dsceng2 := ""
	Local cX6_Conteud := ""
	Local cX6_Contspa := ""
	Local cX6_Conteng := ""
	Local cX6_Propri  := ""
	Local cX6_Pyme    := ""
	Local cX6_Valid   := ""
	Local cX6_Init    := ""
	Local cX6_Defpor  := ""
	Local cX6_Defspa  := ""
	Local cX6_Defeng  := ""

	dbSelectArea("SX6")
	SX6->(dbSetOrder(1)) //X6_FIL+X6_VAR

	If SX6->(dbSeek(cFilAux + "MV_ITEMTRP"))
		cX6_Tipo    := X6_TIPO
		cX6_Descric := X6_DESCRIC
		cX6_Dscspa  := X6_DSCSPA
		cX6_Dsceng  := X6_DSCENG
		cX6_Desc1   := X6_DESC1
		cX6_Dscspa1 := X6_DSCSPA1
		cX6_Dsceng1 := X6_DSCENG1
		cX6_Desc2   := X6_DESC2
		cX6_Dscspa2 := X6_DSCSPA2
		cX6_Dsceng2 := X6_DSCENG2
		cX6_Conteud := X6_CONTEUD
		cX6_Contspa := X6_CONTSPA
		cX6_Conteng := X6_CONTENG
		cX6_Propri  := X6_PROPRI
		cX6_Pyme    := X6_PYME
		cX6_Valid   := X6_VALID
		cX6_Init    := X6_INIT
		cX6_Defpor  := X6_DEFPOR
		cX6_Defspa  := X6_DEFSPA
		cX6_Defeng  := X6_DEFENG
			
		If SX6->(DBSeek(cFilAux + "MV_GFE002"))
			If RecLock("SX6",.F.)
				SX6->X6_TIPO	:= cX6_Tipo
				SX6->X6_DESCRIC	:= cX6_Descric
				SX6->X6_DSCSPA	:= cX6_Dscspa
				SX6->X6_DSCENG	:= cX6_Dsceng
				SX6->X6_DESC1	:= cX6_Desc1
				SX6->X6_DSCSPA1	:= cX6_Dscspa1
				SX6->X6_DSCENG1	:= cX6_Dsceng1
				SX6->X6_DESC2	:= cX6_Desc2
				SX6->X6_DSCSPA2	:= cX6_Dscspa2
				SX6->X6_DSCENG2	:= cX6_Dsceng2
				SX6->X6_CONTEUD	:= cX6_Conteud
				SX6->X6_CONTSPA	:= cX6_Contspa
				SX6->X6_CONTENG	:= cX6_Conteng
				SX6->X6_PROPRI	:= cX6_Propri
				SX6->X6_PYME	:= cX6_Pyme
				SX6->X6_VALID	:= cX6_Valid
				SX6->X6_INIT	:= cX6_Init
				SX6->X6_DEFPOR	:= cX6_Defpor
				SX6->X6_DEFSPA	:= cX6_Defspa
				SX6->X6_DEFENG	:= cX6_Defeng

				SX6->( MSUnlock() )
			EndIf
		Else
			If RecLock("SX6",.T.)
				SX6->X6_FIL		:= cFilAux
				SX6->X6_VAR		:= 'MV_GFE002'
				SX6->X6_TIPO	:= cX6_Tipo
				SX6->X6_DESCRIC	:= cX6_Descric
				SX6->X6_DSCSPA	:= cX6_Dscspa
				SX6->X6_DSCENG	:= cX6_Dsceng
				SX6->X6_DESC1	:= cX6_Desc1
				SX6->X6_DSCSPA1	:= cX6_Dscspa1
				SX6->X6_DSCENG1	:= cX6_Dsceng1
				SX6->X6_DESC2	:= cX6_Desc2
				SX6->X6_DSCSPA2	:= cX6_Dscspa2
				SX6->X6_DSCENG2	:= cX6_Dsceng2
				SX6->X6_CONTEUD	:= cX6_Conteud
				SX6->X6_CONTSPA	:= cX6_Contspa
				SX6->X6_CONTENG	:= cX6_Conteng
				SX6->X6_PROPRI	:= cX6_Propri
				SX6->X6_PYME	:= cX6_Pyme
				SX6->X6_VALID	:= cX6_Valid
				SX6->X6_INIT	:= cX6_Init
				SX6->X6_DEFPOR	:= cX6_Defpor
				SX6->X6_DEFSPA	:= cX6_Defspa
				SX6->X6_DEFENG	:= cX6_Defeng	

				SX6->( MSUnlock() )
			EndIf
		EndIf
	EndIf

	If RecLock("GW0",.T.)
		GW0->GW0_FILIAL := cFilAux
		GW0->GW0_TABELA := Padr("SX6", TamSX3("GW0_TABELA")[1])
		GW0->GW0_CHAVE  := Padr('RUPGFE_MV_ITEMTRP_MV_GFE002', TamSX3("GW0_CHAVE")[1])
		GW0->GW0_CHAR01 := GetComputerName()
		GW0->GW0_DATA01 := Date()

		GW0->( MSUnlock() )
	EndIf
Return .T.
