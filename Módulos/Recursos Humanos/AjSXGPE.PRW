#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AJSXGPE.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWLIBVERSION.CH"

Main function GPELoad()

	Local cFunExec  := "GetSrvVersion"
    Local lRet		:= .T.

    If cPaisLoc == "BRA" .And. !IsBlind() .And. FwLibVersion() >= "20200727" .And. FindClass( "FWCustomMetrics" ) .And. FindFunction( cFunExec ) .And. &cFunExec.() >= "19.3.0.6"
        fGPEMetrics()
    EndIf

	lRet := fChkConv12()
	If !lRet
		Return
	Endif

	fVldTamSindic()

Return .T.

/*/{Protheus.doc} fChkConv12
Checa preenchimento de campos P12 pelo GPECONV.
/*/
Function fChkConv12()
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local lTemSRA	:= .T.
	Local lTemSRD	:= .T.
	Local lRhConv := SuperGetMV("MV_RHCONV",,.F.)
	Local cOrder:= ''

	if(lRhConv)
		cOrder:= 'RA_FILIAL+RA_PROCES+RA_TNOTRAB+RA_SEQTURN+RA_REGRA+RA_MAT'		
		SRA->(dbSetOrder(RetOrder("SRA",cOrder)))	
		SRA->(dbGoTop())
		lTemSRA := (!SRA->(Eof()) .AND. Empty(SRA->RA_PROCES))	

		cOrder:= 'RD_FILIAL+RD_PROCES+RD_PERIODO+RD_SEMANA+RD_ROTEIR+RD_CC+RD_MAT'		
		SRD->(dbSetOrder(RetOrder("SRD",cOrder)))
		SRD->(dbGoTop())	
		lTemSRD := (!SRD->(Eof()) .AND. Empty(SRD->RD_PERIODO))

		if(lTemSRA .Or. lTemSRD)
			lRet := .F.
			Final("A base deve ser convertida para atender a P12. Verificar a documentação"," referente ao GPECONV disponivel no TDN no link: http://tdn.totvs.com/x/XMJhE")
		Endif
	endIf

	RestArea(aArea)
Return (lRet)

/*/{Protheus.doc} fGPEMetrics
Captura e envia métricas adicionais do módulo SIGAGPE
@author Allyson Luiz Mesashi
@since 27/04/2023
/*/
Static Function fGPEMetrics()

Local cAPIPEM1      := Iif( !Empty( SuperGetMV("MV_APIPEM1", Nil, "") ), "1", "0" )
Local cAPISWI1      := Iif( !Empty( SuperGetMV("MV_APISWI1", Nil, "") ), "1", "0" )
Local cMDTGPE       := Iif( SuperGetMV("MV_MDTGPE", Nil, "N") == "S" , "1", "0" )
Local cRHNG         := Iif( SuperGetMV("MV_RHNG", Nil, .F.), "1", "0" )
Local cRHTAEUS      := Iif( !Empty( SuperGetMV("MV_RHTAEUS", Nil, "") ), "1", "0" )
Local cSEGFALT      := Iif( SuperGetMV("MV_SEGFALT", Nil, .F.), "1", "0" )
Local cSIGAPON      := Iif( SP9->( !Eof() ) .And. SPA->( !Eof() ) .And. SPJ->( !Eof() ), "1", "0" )
Local cTECXRH       := Iif( SuperGetMV("MV_TECXRH", Nil, .F.), "1", "0" )
Local cUSACPER      := Iif( SuperGetMV("MV_USACPER", Nil, .F.), "1", "0" )
Local cTmpAlias     := GetNextAlias()

BeginSql alias cTmpAlias
    SELECT RA_SITFOLH, RA_CATEFD, COUNT(*) AS CONT
    FROM %table:SRA%
    WHERE RA_CATEFD != '   ' AND D_E_L_E_T_= ' ' 
    GROUP BY RA_SITFOLH, RA_CATEFD
    ORDER BY RA_SITFOLH, RA_CATEFD
EndSql

While (cTmpAlias)->( !EoF() )
    If (cTmpAlias)->RA_SITFOLH == "A"
        FwCustomMetrics():setUniqueMetric( (cTmpAlias)->RA_CATEFD, "totvs-rh-protheus_quantidade-funcionarios-afastados_total", cValToChar( (cTmpAlias)->CONT ) )
    ElseIf (cTmpAlias)->RA_SITFOLH == "D"
        FwCustomMetrics():setUniqueMetric( (cTmpAlias)->RA_CATEFD, "totvs-rh-protheus_quantidade-funcionarios-desligados_total", cValToChar( (cTmpAlias)->CONT ) )
    ElseIf (cTmpAlias)->RA_SITFOLH == "F"
        FwCustomMetrics():setUniqueMetric( (cTmpAlias)->RA_CATEFD, "totvs-rh-protheus_quantidade-funcionarios-ferias_total", cValToChar( (cTmpAlias)->CONT ) )
    Else
        FwCustomMetrics():setUniqueMetric( (cTmpAlias)->RA_CATEFD, "totvs-rh-protheus_quantidade-funcionarios-ativos_total ", cValToChar( (cTmpAlias)->CONT ) )
    EndIf
    (cTmpAlias)->( dbSkip() )
End

(cTmpAlias)->( dbCloseArea() )

FwCustomMetrics():setUniqueMetric( "MV_APIPEM1", "totvs-rh-protheus_configuracao-parametros_info", cAPIPEM1 )
FwCustomMetrics():setUniqueMetric( "MV_APISWI1", "totvs-rh-protheus_configuracao-parametros_info", cAPISWI1 )
FwCustomMetrics():setUniqueMetric( "MV_MDTGPE", "totvs-rh-protheus_configuracao-parametros_info", cMDTGPE )
FwCustomMetrics():setUniqueMetric( "MV_RHNG", "totvs-rh-protheus_configuracao-parametros_info", cRHNG )
FwCustomMetrics():setUniqueMetric( "MV_RHTAEUS", "totvs-rh-protheus_configuracao-parametros_info", cRHTAEUS )
FwCustomMetrics():setUniqueMetric( "MV_SEGFALT", "totvs-rh-protheus_configuracao-parametros_info", cSEGFALT )
FwCustomMetrics():setUniqueMetric( "MV_TECXRH", "totvs-rh-protheus_configuracao-parametros_info", cTECXRH )
FwCustomMetrics():setUniqueMetric( "MV_USACPER", "totvs-rh-protheus_configuracao-parametros_info", cUSACPER )
FwCustomMetrics():setUniqueMetric( "GPELOAD", "totvs-rh-protheus_utilizacao-sigapon_info", cSIGAPON )

Return

/*/{Protheus.doc} fVldTamSindic
Valida se houve alteração do tamanho do campo SINDICATO e atualiza tabelas da RCB/RCC
@author Leandro Drumond
@since 24/04/2024
/*/
Static Function fVldTamSindic()
Local aArea 	:= GetArea()
Local aDados    := {}
Local aTabRCC   := {}
Local aAux      := {}
Local aTabAux   := {"S015","S039","S040","S042","S061","S065","S106","S109","S126","S127","S143","S147","S148","S149","S151"}
Local aCpoAux   := {"CODSIND","Sindicato","Sindicato","Sindicato","SINDICATO","SINDICATO","BR1_S10612","BRA_S01501","SINDICATO","BRA_S12704","SINDICATO","SINDICATO","SINDICATO","SINDICATO","SINDICATO"}
Local cFilRCB   := xFilial("RCB")
Local cFilRCC 	:= xFilial("RCC")
Local cConteudo := ""
Local nTamSind	:= TamSX3("RCE_CODIGO")[1]
Local nPos 		:= 0
Local nPos2		:= 0
Local nX        := 0
Local nY 		:= 0
Local lTemDados := .F.

RCB->(DbSetOrder(3)) //RCB_FILIAL + RCB_CAMPOS + RCB_CODIGO

If RCB->(DbSeek(cFilRCB+PADR("CODSIND",TamSX3("RCB_CAMPOS")[1])+"S015"))

	If nTamSind <> RCB->RCB_TAMAN
		Begin Transaction

			RCB->(DbSetOrder(1)) ///RCB_FILIAL + RCB_CODIGO

			For nPos := 1 to Len(aTabAux)
				
				aAux := {}
				fCarrTab( @aAux,aTabAux[nPos],,.T.)

				lTemDados := .F.

				If Len(aAux) > 0
					aAdd(aDados, aAux)
					lTemDados := .T.
				EndIf 

				aAux := {}
					
				If RCB->(DbSeek(cFilRCB + aTabAux[nPos]))
					While RCB->(!Eof() .and. RCB_FILIAL + RCB_CODIGO == cFilRCB + aTabAux[nPos])
						If AllTrim(RCB->RCB_CAMPOS) == aCpoAux[nPos]
							RecLock("RCB",.F.)
							RCB->RCB_TAMAN := nTamSind
							RCB->RCB_PICTUR:= "@!"
							MsUnLock() 
						EndIf
						If !(RCB->RCB_CODIGO == "S042" .And. AllTrim(RCB->RCB_CAMPOS) == "Sequencia")
							RCB->(aAdd(aAux, {RCB_CODIGO, RCB_ORDEM, RCB_TIPO, RCB_TAMAN, RCB_DECIMA, RCB_PICTUR}))
						EndIf
						RCB->(DbSkip())
					EndDo
					If lTemDados
						aSort(aAux,,,{ |x,y|  x[2] < y[2] })
						aAdd(aTabRCC, aAux)
					EndIf
				EndIf
			Next nPos

			DbSelectArea( "RCC" )
			DbSetOrder( 1 )  //RCC_FILIAL + RCC_CODIGO + RCC_FIL + RCC_CHAVE  + RCC_SEQUEN

			For nPos := 1 to Len(aTabRCC)
				For nX := 1 to Len(aDados[nPos])
					If RCC->(DbSeek(cFilRCC + aDados[nPos,nX,1] + aDados[nPos,nX,2] + aDados[nPos,nX,3] + aDados[nPos,nX,4]))
						RecLock("RCC",.F.)
						cConteudo := ""
						nPos2     := 5
						For nY := 1 to Len(aTabRCC[nPos])
							If aTabRCC[nPos,nY,3] == "C"
								cConteudo += Padr(aDados[nPos,nX,nPos2],aTabRCC[nPos,nY,4])
							ElseIf aTabRCC[nPos,nY,3] == "D"
								cConteudo += DtoS(aDados[nPos,nX,nPos2])
							ElseIf aTabRCC[nPos,nY,5] > 0
								cConteudo += PadR(StrTran(StrTran(Transform(aDados[nPos,nX,nPos2], aTabRCC[nPos,nY,6]),".",""),",","."),aTabRCC[nPos,nY,4])
							Else 
								cConteudo += PadL(AllTrim(Str(aDados[nPos,nX,nPos2])),aTabRCC[nPos,nY,4])
							EndIf
							nPos2++
						Next nY
						RCC_CONTEU := cConteudo 
						MsUnLock()
					EndIf
				Next nX
			Next nPos
			
		End Transaction
	EndIf 
EndIf 

RestArea(aArea)

Return Nil
