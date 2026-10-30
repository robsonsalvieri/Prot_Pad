#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'VEIA144.CH'
#INCLUDE 'TOPCONN.CH'

CLASS VEIA144EVF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD GridLinePreVld()

ENDCLASS


METHOD New() CLASS VEIA144EVF

RETURN .T.

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA144EVF

	Local lRet := .t.
	Local aVetCb	:= {}
	Local aVetIt	:= {}
	Local oMGridBonus := oModel:GetModel("BONUSLIBERADO")
	Local oMGridArq := oModel:GetModel("ARQUIVORETORNO")
	Local nQtdLines  := oMGridBonus:Length()
	Local nX
	Local lRetSel := .F.

	Local cPrefOri:= GetNewPar("MV_PREFVEI","VEI")
	Local cFilSE1 := xFilial("SE1")
	Local cNamSE1 := RetSQLName("SE1")
	Local cPreTit := Alltrim(GetNewPar("MV_MIL0200","")) // Prefixo dos Titulos quando gerar somente TITULOS
	Local cTipTit := Alltrim(GetNewPar("MV_MIL0201","")) // Tipo dos Titulos quando gerar somente TITULOS
	Local aVetTit := {}
	Local ni      := 0
	Local cVQ1NUM := ""
	Local cVQ1SER := ""
	Local cCodVBS := ""
	Local aVetVBS := {}

	Local lC5INDPRES := SC5->(FieldPos("C5_INDPRES")) > 0
	Local lC5MUNPRES := SC5->(FieldPos("C5_MUNPRES")) > 0
	Local lC6NATREN  := SC6->(FieldPos("C6_NATREN"))  > 0

	If oModel:GetValue("CAMPOSTOTAL","CPOTOTBON") == 0 .or. oModel:GetValue("CAMPOSTOTAL","CPOTOTRET") == 0 // Nao selecionou o Bonus
		MsgInfo( STR0017 , STR0018 ) //"Necessario selecionar os registros!" / "Atenção"
		lRet := .f.
	Else
		lRet := .f.
		If oModel:GetValue("CAMPOSTOTAL","CPOTOTDIV") == 0 // Nao ha divergencia
			lRet := .t.
		Else // com divergencia entre Retorno e Bonus selecionados
			If MsgYesNo( STR0019 , STR0018 ) // Ha divergencia entre o Retorno e os Bonus selecionados. NF sera gerada no valor total dos Bonus selecionados. Deseja continuar? / Atencao
				lRet := .t.
			EndIf
		EndIf
	EndIf

	If lRet

		If oModel:GetValue("INFORMACAONF","CPOTPGER") == "1" // Geração da Nota Fiscal + Titulo

			aVetCb := {	oModel:GetValue("INFORMACAONF","C5CLIENTE"),;
						oModel:GetValue("INFORMACAONF","C5LOJACLI"),;
						oModel:GetValue("INFORMACAONF","C5VEND1"),;
						oModel:GetValue("INFORMACAONF","C5CONDPAG"),;
						oModel:GetValue("INFORMACAONF","C5NATUREZ"),;
						oModel:GetValue("INFORMACAONF","C5BANCO"),;
						oModel:GetValue("INFORMACAONF","PAROBSNF"),;
						oModel:GetValue("INFORMACAONF","C5MENNOTA"),;
						oModel:GetValue("INFORMACAONF","C5MENPAD") }

			If cPaisLoc == "MEX"
				aAdd(aVetCb, oModel:GetValue("INFORMACAONF","C5USOCFDI")) // 10=C5_USOCFDI
				aAdd(aVetCb, oModel:GetValue("INFORMACAONF","C5TPDOC"  )) // 11=C5_TPDOC
			EndIf

			aAdd( aVetIt ,{ oModel:GetValue("INFORMACAONF","CPOCODPRD"),;
							oModel:GetValue("INFORMACAONF","PARVALOR"),;
							If(lC6NATREN,oModel:GetValue("INFORMACAONF","C6NATREN"),"")})

			aNF := FMX_GERNFS(	aVetCb,;
								aVetIt,;
								.t.,;
								GetNewPar("MV_PREFVEI","VEI"),;
								,;
								oModel:GetValue("INFORMACAONF","C5TIPOCLI"),;
								If(lC5INDPRES,oModel:GetValue("INFORMACAONF","C5INDPRES"),""),;
								oModel:GetValue("INFORMACAONF","C5ESTPRES"),;
								If(lC5MUNPRES,oModel:GetValue("INFORMACAONF","C5MUNPRES"),""))

			cVQ1NUM := aNF[1]
			cVQ1SER := aNF[2]

			If Empty(cVQ1NUM)
				Return .f.
			EndIf

		Else // Geração do Titulo

			DBSelectArea("SE4")
			DBSetOrder(1)
			DBSeek(xFilial("SE4")+oModel:GetValue("INFORMACAONF","C5CONDPAG"))
			aAuxParc := Condicao(oModel:GetValue("INFORMACAONF","PARVALOR"),SE4->E4_CODIGO,,dDataBase)

			cNumTit := Alltrim(FM_SQL("SELECT MAX(SE1.E1_NUM) FROM "+cNamSE1+" SE1 WHERE SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO='"+cPreTit+"' AND SE1.E1_TIPO = '"+cTipTit+"' AND SE1.E1_NUM LIKE '"+cTipTit+"%'"))
			If Empty(cNumTit)
				cNumTit := cTipTit+strzero(1,TamSX3("E1_NUM")[1]-3)
			Else
				cNumTit := cTipTit+strzero(val(right(cNumTit,TamSX3("E1_NUM")[1]-3))+1,TamSX3("E1_NUM")[1]-3)
			EndIf

			Begin Transaction

				For ni := 1 to Len(aAuxParc)

					cParc := Alltrim(FM_SQL("SELECT MAX(SE1.E1_PARCELA) FROM "+cNamSE1+" SE1 WHERE SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_PREFIXO='"+cPreTit+"' AND SE1.E1_NUM='"+cNumTit+"'"))
					If Empty(cParc)
						cParc := strzero(0,TamSX3("E1_PARCELA")[1])
					EndIf
					cParc := Soma1(cParc)
					//
					aVetTit := {}
					aAdd(aVetTit,{"E1_PREFIXO",cPreTit        ,nil})
					aAdd(aVetTit,{"E1_NUM"    ,cNumTit        ,nil})
					aAdd(aVetTit,{"E1_PARCELA",cParc          ,nil})
					If !Empty(oModel:GetValue("INFORMACAONF","C5NATUREZ"))
						aAdd(aVetTit,{"E1_NATUREZ",oModel:GetValue("INFORMACAONF","C5NATUREZ") ,nil})
					EndIf
					aAdd(aVetTit,{"E1_CLIENTE",oModel:GetValue("INFORMACAONF","C5CLIENTE")     ,nil})
					aAdd(aVetTit,{"E1_LOJA"   ,oModel:GetValue("INFORMACAONF","C5LOJACLI")     ,nil})
					aAdd(aVetTit,{"E1_TIPO"   ,cTipTit        ,nil})
					aAdd(aVetTit,{"E1_PREFORI",cPrefOri       ,nil})
					aAdd(aVetTit,{"E1_EMISSAO",dDataBase      ,nil})
					aAdd(aVetTit,{"E1_VENCTO" ,aAuxParc[ni,01],nil})
					aAdd(aVetTit,{"E1_VENCREA",DataValida(aAuxParc[ni,01]),nil})
					aAdd(aVetTit,{"E1_VALOR"  ,aAuxParc[ni,02],nil})
					aAdd(aVetTit,{"E1_ORIGEM" ,"FINA040"      ,nil})
					aAdd(aVetTit,{"E1_VEND1"  ,oModel:GetValue("INFORMACAONF","C5VEND1") ,nil})
					If !Empty(oModel:GetValue("INFORMACAONF","C5BANCO"))
						aAdd(aVetTit,{"E1_PORTADO",oModel:GetValue("INFORMACAONF","C5BANCO") ,nil})
					EndIf
					aAdd(aVetTit,{"E1_LA", "S" ,nil})

					If len(aVetTit) > 0
						Pergunte("FIN040",.f.)
						lMsErroAuto := .f.
						MSExecAuto({|x| FINA040(x)},aVetTit)
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
							break
						EndIf

						aAdd(aVetVBS,{cNumTit,cPreTit,cTipTit,cParc})

					EndIf

				Next

			End Transaction

			If lMsErroAuto
				Return .f.
			Endif

			If VQ1->(FieldPos("VQ1_CODVBS")) > 0

				oModelVBS := FWLoadModel( 'VEIA147' )

				oModelVBS:SetOperation( MODEL_OPERATION_INSERT )

				lRet := oModelVBS:Activate()

				If lRet

					If Empty(cCodVBS)
						cCodVBS := GetSXENum("VBS","VBS_CODIGO")
						ConfirmSX8()
						oModelVBS:SetValue( "VBSMASTER", "VBS_CODIGO", cCodVBS )
						oModelVBS:SetValue( "VBSMASTER", "VBS_CREDNT", oModel:GetValue("ARQUIVORETORNO","VQ4CREDNT") )
					EndIf
					
					oModelDet := oModelVBS:GetModel("VBSDETAIL")

					For ni := 1 to Len(aVetVBS)
							
						oModelDet:AddLine()

						oModelDet:SetValue( "VBS_CODIGO", cCodVBS )
						oModelDet:SetValue( "VBS_SEQUEN", StrZero(nI,GetSX3Cache("VBS_SEQUEN","X3_TAMANHO")) )
						oModelDet:SetValue( "VBS_CREDNT", oModel:GetValue("ARQUIVORETORNO","VQ4CREDNT") )
						oModelDet:SetValue( "VBS_NUMTIT", aVetVBS[nI,1] )
						oModelDet:SetValue( "VBS_PRETIT", aVetVBS[nI,2] )
						oModelDet:SetValue( "VBS_TIPTIT", aVetVBS[nI,3] )
						oModelDet:SetValue( "VBS_PARTIT", aVetVBS[nI,4] )

					Next

					If ( oModelVBS:VldData() )
						if ( oModelVBS:CommitData() )
						EndIf
					EndIf

				EndIf

				oModelVBS:DeActivate()

			EndIf

		EndIf

		For nX := 1 to nQtdLines

			oMGridBonus:GoLine(nX)

			If oMGridBonus:GetValue("CPOSELBON")

				DbSelectArea("VQ1")
				VQ1->(DbGoTo(oMGridBonus:GetValue("RECNOVQ1")))

				RecLock("VQ1",.f.)

					VQ1->VQ1_STATUS := "3" // NF Gerada

					If !Empty(cCodVBS)
						VQ1->VQ1_CODVBS := cCodVBS
					ElseIf !Empty(cVQ1NUM)
						VQ1->VQ1_FILNFI := xFilial("SF2")
						VQ1->VQ1_NUMNFI := cVQ1NUM
						VQ1->VQ1_SERNFI := cVQ1SER
						VQ1->VQ1_DATNFI := dDataBase
						if FieldPos("VQ1_SDOC") > 0
							VQ1->VQ1_SDOC := FGX_UFSNF(cVQ1SER)
						Endif
					EndIf

					lRetSel := oMGridArq:SeekLine({{"CPOSELRET", .T.}})
					if lRetSel
						If VQ1->(FieldPos("VQ1_CREDNT")) > 0
							VQ1->VQ1_CREDNT := oModel:GetValue("ARQUIVORETORNO","VQ4CREDNT")
						Else
							VQ1->VQ1_RETUID := oModel:GetValue("ARQUIVORETORNO","VQ4RETUID")
						EndIf
					Endif

					MSMM(VQ1->VQ1_OBSNFC,TamSx3("VQ1_OBSNFM")[1],,oModel:GetValue("INFORMACAONF","PAROBSNF"),1,,,"VQ1","VQ1_OBSNFC")

				MsUnLock()

				cQuery := "SELECT VQ0.VQ0_NUMPED , VV1.VV1_CHASSI "
				cQuery += " FROM "+ RetSqlName("VQ0") + " VQ0 "
				cQuery += " LEFT JOIN " + RetSqlName("VV1") + " VV1 "
				cQuery += 	" ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VQ0.VQ0_CHAINT AND VV1.D_E_L_E_T_=' ' "
				cQuery += " WHERE VQ0.VQ0_FILIAL = '" +xFilial("VQ0")+ "' AND VQ0.VQ0_CODIGO = '" + VQ1->VQ1_CODIGO + "' AND VQ0.D_E_L_E_T_=' ' "
				cQuery += " GROUP BY VQ0.VQ0_NUMPED , VV1.VV1_CHASSI "
				TcQuery cQuery New ALias "TMPVQ0"

				While !TMPVQ0->(Eof())
					cPedVQ0 := TMPVQ0->VQ0_NUMPED
					cChaVV1 := TMPVQ0->VV1_CHASSI
					TMPVQ0->(DbSkip())
				EndDo

				TMPVQ0->(DbCloseArea())

				cCodVQ4 := GetSXENum("VQ4","VQ4_CODIGO",,2) // Utiliza Funcao PADRAO
				ConfirmSX8()

				DbSelectArea("VQ4")
				RecLock("VQ4",.t.)
					VQ4->VQ4_FILIAL := xFilial("VQ4")
					VQ4->VQ4_CODIGO := cCodVQ4
					VQ4->VQ4_DATREG := dDataBase
					VQ4->VQ4_NUMPED := cPedVQ0
					VQ4->VQ4_TIPREG := "1"
					VQ4->VQ4_TIPNFI := "2"
					VQ4->VQ4_FILNFI := VQ1->VQ1_FILNFI
					VQ4->VQ4_NUMNFI := VQ1->VQ1_NUMNFI
					VQ4->VQ4_SERNFI := VQ1->VQ1_SERNFI
					VQ4->VQ4_VLRTOT := oModel:GetValue("INFORMACAONF","PARVALOR")
					VQ4->VQ4_CHASSI := cChaVV1
					VQ4->VQ4_RETUID := VQ1->VQ1_RETUID
					VQ4->VQ4_VLRLIQ := oModel:GetValue("INFORMACAONF","PARVALOR")
					If VQ4->(FieldPos("VQ4_CREDNT")) > 0
						VQ4->VQ4_CREDNT := VQ1->VQ1_CREDNT
						VQ4->VQ4_CODVBS := VQ1->VQ1_CODVBS
					EndIf
				MsUnLock()

			EndIf

		Next nX

	EndIf

RETURN lRet

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA144EVF

	Local oModel:= FWModelActive()
	Local oView := FWViewActive()

	If cAction == "SETVALUE"
		If cModelID == "BONUSLIBERADO"

			If cId == "CPOSELBON"
				If xValue
					nValBon += oModel:GetModel("BONUSLIBERADO" ):GetValue("VQ1VLRTOT")
				Else
					nValBon -= oModel:GetModel("BONUSLIBERADO" ):GetValue("VQ1VLRTOT")
				EndIF
				oModel:SetValue("CAMPOSTOTAL","CPOTOTBON",nValBon)
			EndIf
			oModel:SetValue("INFORMACAONF","PARVALOR",nValBon)

		ElseIf cModelID == "ARQUIVORETORNO"

			If cId == "CPOSELRET"
				If xValue
					lSeek := oSubModel:SeekLine({;
										{ "CPOSELRET" , .t. };
									})
					If lSeek
						oSubModel:LoadValue("CPOSELRET", .f. )
					EndIF

					oSubModel:GoLine(nLine)

					nValRet := oModel:GetModel("ARQUIVORETORNO"):GetValue("VQ4VLRTOT")
				Else
					nValRet := 0
				EndIf

				oModel:SetValue("CAMPOSTOTAL","CPOTOTRET",nValRet)

				SA1->(DbSetOrder(3))
				If SA1->(DbSeek(xFilial("SA1")+oModel:GetValue("ARQUIVORETORNO","VQ4CIACGC")))
					oModel:SetValue("INFORMACAONF","C5CLIENTE",SA1->A1_COD)
					oModel:SetValue("INFORMACAONF","C5LOJACLI",SA1->A1_LOJA)
				EndIf
				SA1->(DbSetOrder(1))

			EndIf

		EndIf

		oModel:SetValue("CAMPOSTOTAL","CPOTOTDIV", nValRet - nValBon )

	EndIf

	oView:Refresh()

RETURN .t.
