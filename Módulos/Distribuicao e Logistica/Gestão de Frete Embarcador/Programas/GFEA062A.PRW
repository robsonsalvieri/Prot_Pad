#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA062CTB
Copia a Tabela de Frete, necessário GVA posicionada

@author Israel A. Possoli
@since 18/03/2014
@version 1.0 
-------------------------------------------------------------------*/
Function GFECPYTBFR()
	Local aAreaGVA := GVA->(getArea())
	Local oDlg
	Local oCdTab
	Local oCdTransp
	Local oDsTab
	Local cDsTab := GVA->GVA_DSTAB
	Local oDsTransp
	Local cDsTransp := POSICIONE("GU3",1,XFILIAL("GU3")+GVA->GVA_CDEMIT,"GU3_NMEMIT")
	Local oFolder1
	Local oGroup1
	Local oGroup2
	Local oNovCdTransp
	Local oPanel1
	Local oPanel2
	Local oPanel3

	Private oNovDsTransp
	Private cNovDsTransp := Space(TamSX3("GU3_NMEMIT")[1])
	Private oNovTabDes
	Private cNovTabDes := PadR(GVA->GVA_DSTAB, TamSX3("GVA_DSTAB")[1])
	Private oChkTarifas
	Private oChkZerar
	Private lCopyRotas   := .T.
	Private lCopyFaixas  := .T.
	Private lCopyTarifas := .T.
	Private lCopyZerar   := .F.
	Private cCdTransp 	 := GVA->GVA_CDEMIT
	Private cCdTab 		 := GVA->GVA_NRTAB
	Private cNovCdTab 	 := Space(TamSX3("GVA_NRTAB")[1])
	Private cNovCdTransp := Space(TamSX3("GVA_CDEMIT")[1])
	Private oGetNeg
	Private aHeadNeg := {} 
	
	If GVA->GVA_TPTAB == "2"
		Help( ,, 'Help' ,, "Não é possível copiar uma tabela do tipo 'Vínculo'.", 1, 0 )
		Return .F.
	EndIf
	
	
	aHeadNeg := DefTabNeg()
	
  	DEFINE MSDIALOG oDlg TITLE "Cópia da Tabela de Frete" FROM 000, 000  TO 520, 700 PIXEL
  		CursorWait()
  		
		@ 000, 000 MSPANEL oPanel1 SIZE 350, 045 OF oDlg  RAISED
		@ 040, 000 MSPANEL oPanel2 SIZE 350, 065 OF oDlg  RAISED    
		@ 080, 000 MSPANEL oPanel3 SIZE 350, 120 OF oDlg  RAISED
		    
		@ 000, 000 GROUP oGroup1 TO 039, 349 PROMPT "Tabela de Frete Base " OF oPanel1 PIXEL
		@ 000, 000 GROUP oGroup2 TO 039, 349 PROMPT "Nova Tabela de Frete " OF oPanel2 PIXEL
			
		@ 010, 004 SAY oSay3 PROMPT "Transportador:" SIZE 037, 007 OF oGroup1 PIXEL
		@ 009, 046 MSGET oCdTransp VAR cCdTransp SIZE 055, 010 OF oGroup1 WHEN .F. PIXEL
		@ 009, 115 MSGET oDsTransp VAR cDsTransp SIZE 135, 010 OF oGroup1 WHEN .F. PIXEL
	    @ 025, 004 SAY oSay4 PROMPT "Tabela:" SIZE 025, 007 OF oGroup1 PIXEL
	    @ 023, 046 MSGET oCdTab VAR cCdTab SIZE 055, 010 OF oGroup1 WHEN .F. PIXEL
	    @ 023, 115 MSGET oDsTab VAR cDsTab SIZE 135, 010 OF oGroup1 WHEN .F. PIXEL
	    
	    @ 010, 004 SAY oSay5 PROMPT "Transportador:" SIZE 037, 007 OF oGroup2 PIXEL
	    @ 009, 046 MSGET oNovCdTransp VAR cNovCdTransp SIZE 055, 010 OF oGroup2 F3 "GU3TRP" VALID ValidTransp(cNovCdTransp) PIXEL
	    @ 009, 115 MSGET oNovDsTransp VAR cNovDsTransp SIZE 135, 010 OF oGroup2 WHEN .F. PIXEL
	    @ 025, 004 SAY oSay6 PROMPT "Tabela:" SIZE 025, 007 OF oGroup2 PIXEL
	    @ 023, 046 MSGET oNovCdTab VAR cNovCdTab SIZE 055, 010 OF oGroup2 PIXEL
	    
	    @ 040, 004 SAY oSay7 PROMPT "Descrição:" SIZE 037, 007 OF oGroup2 PIXEL
	    @ 038, 046 MSGET oNovTabDes VAR cNovTabDes SIZE 204, 010 PICTURE "@!" OF oGroup2  PIXEL
	    
	    @ 053, 046 CHECKBOX oCheckBo1   VAR lCopyRotas   PROMPT "Rotas" SIZE 048, 012 OF oGroup2 COLORS 0, 16777215 PIXEL ON CLICK(ChkOpCopy()) 
	    @ 053, 086 CHECKBOX oCheckBo2   VAR lCopyFaixas  PROMPT "Faixas" SIZE 048, 012 OF oGroup2 COLORS 0, 16777215 PIXEL ON CLICK(ChkOpCopy()) 
	    @ 053, 126 CHECKBOX oChkTarifas VAR lCopyTarifas PROMPT "Tarifas" SIZE 048, 012 OF oGroup2 COLORS 0, 16777215 PIXEL
	    @ 053, 166 CHECKBOX oChkZerar   VAR lCopyZerar   PROMPT "Zerar Tarifas" SIZE 048, 012 OF oGroup2 PIXEL
	    
	    
	    @ 000, 000 FOLDER oFolder1 SIZE 300, 119 OF oPanel3 ITEMS "Negociações" COLORS 0, 14215660 PIXEL
	    
	   	oGetNeg := MsNewGetDados():New(05, 05, 60, 160, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",/*[ cIniCpos]*/, {"NDTVALI", "NDTVALF"}	,/* [ nFreeze]*/,/*[ nMax]*/,"AllwaysTrue",/*[ cSuperDel]*/,/*[ cDelOk]*/, oFolder1:ADialogs[1], aHeadNeg, /* aColsFil*/,,/*[ cTela]*/)
	   	oGetNeg:oBrowse:blDblClick 	:= { |x,nCol| IIf( nCol == 1, MrkLinha(), oGetNeg:EditCell()) }
	
	    oPanel1:Align  := CONTROL_ALIGN_TOP
	    oPanel2:Align  := CONTROL_ALIGN_TOP
	    oGroup1:Align  := CONTROL_ALIGN_ALLCLIENT
	    oGroup2:Align  := CONTROL_ALIGN_ALLCLIENT
	    oPanel3:Align  := CONTROL_ALIGN_ALLCLIENT
	    oFolder1:Align := CONTROL_ALIGN_ALLCLIENT
	    oGetNeg:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	    
	    CarregaDados(cCdTransp, cCdTab)
	    oGetNeg:oBrowse:GoBottom()
	    oGetNeg:oBrowse:GoTop()
	    oGetNeg:oBrowse:Refresh()
	    CursorArrow()
	    
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||btOK()}, {||ODlg:End()}) CENTERED

Return

/*-------------------------------------------------------------------                                                                           
ValidTransp
Validação do campo Novo Transportador

@author Israel A. Possoli
@since 24/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function ValidTransp(cNovCdTransp)
	Local lRet
	lRet := ExistCpo("GU3",cNovCdTransp)
	
	If lRet
		cNovDsTransp := POSICIONE("GU3",1,XFILIAL("GU3")+cNovCdTransp,"GU3_NMEMIT")
		oNovDsTransp:CtrlRefresh()
	Else
		cNovDsTransp := ""
		oNovDsTransp:CtrlRefresh()
	EndIf
	
Return (lRet)

/*-------------------------------------------------------------------                                                                           
ChkOpCopy
Validação dos CheckBoxs de Rota e Faixas

@author Israel A. Possoli
@since 24/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function ChkOpCopy()
	If lCopyRotas == .F. .OR. lCopyFaixas == .F.
		lCopyTarifas := .F.
		lCopyZerar   := .F.
		
		oChkTarifas:Disable()
		oChkZerar:Disable()
		
		oChkTarifas:CtrlRefresh()
		oChkZerar:CtrlRefresh()
	Else
		lCopyTarifas := .T.
		lCopyZerar   := .F.
		
		oChkTarifas:SetColor(0, 16777215)
		oChkTarifas:Enable()
		oChkZerar:Enable()
		
		oChkTarifas:CtrlRefresh()
		oChkZerar:CtrlRefresh()	
	EndIf
Return


/*-------------------------------------------------------------------                                                                           
MrkLinha
Evento de duplo clique

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function MrkLinha()
	// Local nId := Val(AllTrim(oGet:aCols[oGet:nAt, Len(oGet:aCols[oGet:nAt]) - 1]))
		
	If GDFieldGet( 'MRK', oGetNeg:nAt,, oGetNeg:aHeader, oGetNeg:aCols ) == 'LBNO'
		GDFieldPut( 'MRK', 'LBOK', oGetNeg:nAt, oGetNeg:aHeader, oGetNeg:aCols )
	Else
		GDFieldPut( 'MRK'       , 'LBNO' , oGetNeg:nAt , oGetNeg:aHeader , oGetNeg:aCols )
	EndIf
Return

/*-------------------------------------------------------------------                                                                           
CarregaDados
Carre dados

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function CarregaDados(cCdTransp, cCdTab)
	Local aCols := {}
	
	GV9->(dbSetOrder(1))
	GV9->(dbSeek(xFilial("GV9") + cCdTransp + cCdTab))
	While !GV9->(Eof())						 .AND. ;
		   GV9->GV9_FILIAL == xFilial("GV9") .AND. ;
		   GV9->GV9_CDEMIT == cCdTransp		 .AND. ;
		   GV9->GV9_NRTAB  == cCdTab
		   
		AAdd(aCols, Array(Len(aHeadNeg)+2))
		
		aCols[Len(aCols), 1] := "LBOK"
		aCols[Len(aCols), 2] := GV9->GV9_NRNEG
		aCols[Len(aCols), 3] := GV9->GV9_CDCLFR
		aCols[Len(aCols), 4] := Posicione("GUB",1,xFilial("GUB")+GV9->GV9_CDCLFR,"GUB_DSCLFR")
		aCols[Len(aCols), 5] := GV9->GV9_CDTPOP
		aCols[Len(aCols), 6] := Posicione("GV4",1,xFilial("GV4")+GV9->GV9_CDTPOP,"GV4_DSTPOP")
		aCols[Len(aCols), 7] := DToC(GV9->GV9_DTVALI)
		aCols[Len(aCols), 8] := DToC(GV9->GV9_DTVALF)
		aCols[Len(aCols), 9] := GV9->GV9_DTVALI
		aCols[Len(aCols),10] := GV9->GV9_DTVALF
		aCols[Len(aCols),Len(aHeadNeg)+2] := .F.
		
		GV9->(dbSkip())	   
	EndDo

	
	oGetNeg:SetArray(aCols, .T.)
	
	oGetNeg:oBrowse:Refresh()
Return


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} btOK
Ação do botão Confirmar da Janela

@author Israel A. Possoli
@since 24/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function btOK()
	Local aAreaGVA
	Local aAreaGV9
	Private cErros := ""
	
	If Empty(cNovCdTransp) .OR. Empty(cNovCdTab)
		Help( ,, 'Help' ,, "Informe o Transportador e o Código da tabela para a cópia.", 1, 0 )
		Return .F.
	EndIf
	
	GVA->(dbSetOrder(1))
	If GVA->(dbSeek(xFilial("GVA") + PadR(cNovCdTransp, TamSX3("GVA_CDEMIT")[1]) + PadR(alltrim(cNovCdTab), TamSX3("GVA_NRTAB")[1])))
		Help( ,, 'Help' ,, "Já existe uma tabela cadastrada com este Transportador e Código.", 1, 0 )
		Return .F.
	EndIf
	
	aAreaGVA  := GVA->(getArea())
	aAreaGV9 := GV9->(getArea())
	
	Processa({|| CopyTabFrete()}, "Cópia")
	
	RestArea(aAreaGVA)
	RestArea(aAreaGV9)
	
	If Empty(cErros)
		MsgInfo("Tabela copiada", "Cópia")
	Else
		Alert("Processo concluído, porém ocorreram os seguintes erros: " + CHR(10) + CHR(13) + cErros, "Erros")
	EndIf
	
Return		

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA062CTB
Efetiva a cópia da tabela de frete

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function CopyTabFrete()
	Local cNrNeg
	Local dNDTVALI
	Local dNDTVALF
	Local nI
	Local nCnt
	Local cAliasGV1  := Nil
	Local cAliasGV6  := Nil
	Local cAliasGV7	 := Nil
	Local cAliasGV8	 := Nil
	Local cAliasGUY  := Nil
	Local cAliasGUZ  := Nil
	Local cAliasGUC  := Nil
	Local aCopyG	 := {}
	Local aHeaderGV1 := {}
	Local aHeaderGV6 := {}
	Local aHeaderGV7 := {}
	Local aHeaderGV8 := {}
	Local aHeaderGUY := {}
	Local aHeaderGUZ := {}
	Local aHeaderGUC := {}
	Local cHora      := ""



	ProcRegua(0)
	GVA->( dbSetOrder(1) )
	If GVA->(dbSeek(xFilial("GVA") + cCdTransp + cCdTab))
		IncProc("Copiando Tabela de Frete...")
		
		aCopyG	:= {}
		For nCnt := 1 To GVA->(FCount())
			IF GFXRL12123("GVA",GVA->(Field(nCnt)))
				AAdd(aCopyG, GVA->(FieldGet(nCnt)))
			EndIf
		Next nCnt

		RecLock("GVA", .T.)
			For nCnt := 1 To Len(aCopyG)
				FieldPut(nCnt, aCopyG[nCnt])
			Next nCnt
			GVA->GVA_FILIAL	:= 	xFilial("GVA")
			GVA->GVA_CDEMIT	:= 	cNovCdTransp
			GVA->GVA_NRTAB	:= 	alltrim(cNovCdTab)
			GVA->GVA_DSTAB  	:= 	cNovTabDes
			GVA->GVA_DTCRIA	:= 	Date()
			GVA->GVA_HRCRIA	:= 	Time()
			GVA->GVA_USUCRI 	:= 	cUserName
			GVA->GVA_DTATU	:= 	Date()
			GVA->GVA_HRATU	:= 	Time()
			GVA->GVA_USUATU 	:= 	cUserName
			GVA->GVA_DTAPR  	:= 	Stod("  /  /  ")
			GVA->GVA_HRAPR  	:= 	""
			GVA->GVA_USUAPR 	:= 	""
			GVA->GVA_DTNEG  	:= 	DDATABASE
			GVA->GVA_SITVIN	:= 	"1"
			GVA->GVA_ENVAPR 	:= 	"2"
			GVA->GVA_MTVRPR 	:= 	""
			GVA->GVA_OBS    	:= 	"Cópia da tabela de frete pelo usuário '" + cUserName+ "'. Tabela base: Emitente: " + cCdTransp + ", Tabela: " + cCdTab
			If GFE61EXCPL()
				GVA->GVA_CPLSIT	:= "1" //Não enviada
			EndIf
		GVA->(MsUnLock())

		//Atualiza situação de integração do cockpit logístico
		GFE61ATDP(cNovCdTransp + alltrim(cNovCdTab))
		For nI := 1 To Len(oGetNeg:aCols)
			IncProc("Copiando Tabela de Frete...")
			If GDFieldGet( 'MRK', nI,, oGetNeg:aHeader, oGetNeg:aCols ) == 'LBOK'
				cNrNeg		:= GDFieldGet( 'NRNEG', nI,, oGetNeg:aHeader, oGetNeg:aCols )
				dNDTVALI 	:= GDFieldGet( 'NDTVALI', nI,, oGetNeg:aHeader, oGetNeg:aCols )
				dNDTVALF 	:= GDFieldGet( 'NDTVALF', nI,, oGetNeg:aHeader, oGetNeg:aCols )

					GV9->( dbSetOrder(1) )
					If GV9->(dbSeek(xFilial("GV9") + cCdTransp + cCdTab + cNrNeg))
						// -- Copia da Negociação -----------------------------------

						aCopyG	:= {}
						For nCnt := 1 To GV9->(FCount())
							IF GFXRL12123("GV9",GV9->(Field(nCnt)))
								AAdd(aCopyG, GV9->(FieldGet(nCnt)))
							EndIf
						Next nCnt
				
						RecLock("GV9", .T.)
							For nCnt := 1 To Len(aCopyG)
								FieldPut(nCnt, aCopyG[nCnt])
							Next nCnt

							GV9->GV9_FILIAL 	:= 	xFilial("GV9")
							GV9->GV9_CDEMIT 	:= 	cNovCdTransp
							GV9->GV9_NRTAB	    := 	alltrim(cNovCdTab)
							GV9->GV9_DTCRIA 	:= 	DDATABASE
							GV9->GV9_HRCRIA 	:= 	SubStr(TIME(), 1, 5)
							GV9->GV9_USUCRI 	:= 	cUserName
							GV9->GV9_ENVAPR 	:= 	"2"
							GV9->GV9_DTAPR  	:= 	Stod("  /  /  ")
							GV9->GV9_HRAPR  	:= 	""
							GV9->GV9_USUAPR 	:= 	""
							GV9->GV9_MTVRPR 	:= 	""
							GV9->GV9_SIT		:= 	"1"
							GV9->GV9_DTVALI 	:= 	dNDTVALI
							GV9->GV9_DTVALF 	:= 	dNDTVALF
							GV9->GV9_CODCOT     := ""
							GV9->GV9_SEQCOT     := ""
							GV9->GV9_SITMLA     := "1"
							GV9->GV9_MOTMLA     := ""
						GV9->(MsUnLock())
						
						// -- Copia dos Componentes ---------------------------------
						aHeaderGUY := { {"GUY_FILIAL"   ,xFilial("GUY")},;
										{"GUY_CDEMIT"   ,cNovCdTransp  },;
										{"GUY_NRTAB"    ,cNovCdTab     },;
										{"GUY_NRNEG"    ,""            },;
										{"GUY_CDCOMP"   ,""            },;
										{"GUY_TOTFRE"   ,""            },;
										{"GUY_BASIMP"   ,""            },;
										{"GUY_BAPICO"   ,""            },;
										{"GUY_FREMIN"   ,""            },;
										{"GUY_REENT"    ,""            },;
										{"GUY_CPLPFR"   ,""            },;
										{"GUY_DEVOL"    ,""            }}

						cAliasGUY := GetNextAlias()
						BeginSql Alias cAliasGUY
							SELECT GUY_FILIAL,
								GUY_CDEMIT,
								GUY_NRTAB,
								GUY_NRNEG,
								GUY_CDCOMP,
								GUY_TOTFRE,
								GUY_BASIMP,
								GUY_BAPICO,
								GUY_FREMIN,
								GUY_REENT,
								GUY_CPLPFR,
								GUY_DEVOL
							FROM %Table:GUY% GUY
							WHERE GUY.GUY_FILIAL = %xFilial:GUY%
							AND GUY.GUY_CDEMIT   = %Exp:cCdTransp%
							AND GUY.GUY_NRTAB    = %Exp:cCdTab%
							AND GUY.GUY_NRNEG    = %Exp:cNrNeg%
							AND GUY.%NotDel%
						EndSql
						(cAliasGUY)->(dbGoTop())
						While (cAliasGUY)->(!Eof())
							RecLock("GUY", .T.)
								For nCnt := 1 To Len(aHeaderGUY) // campos da tabela
									If !Empty(aHeaderGUY[nCnt][2])
										&(aHeaderGUY[nCnt][1]) := aHeaderGUY[nCnt][2]
									Else
										&(aHeaderGUY[nCnt][1]) := &("(cAliasGUY)->" + aHeaderGUY[nCnt][1])
									EndIf
								Next nCnt
							GUY->(MsUnLock())
							(cAliasGUY)->(dbSkip())
						EndDo
						
						// -- Copia das Rotas ---------------------------------------
						If lCopyRotas
							aHeaderGV8 := { {"GV8_FILIAL"   ,xFilial("GV8")},;
											{"GV8_CDEMIT"   ,cNovCdTransp  },;
											{"GV8_NRTAB"    ,cNovCdTab     },;
											{"GV8_NRNEG"    ,""            },;
											{"GV8_NRROTA"   ,""            },;
											{"GV8_PRIROT"   ,""            },;
											{"GV8_TPORIG"   ,""            },;
											{"GV8_NRCIOR"   ,""            },;
											{"GV8_DSTORI"   ,""            },;
											{"GV8_DSTORF"   ,""            },;
											{"GV8_NRREOR"   ,""            },;
											{"GV8_CDPAOR"   ,""            },;
											{"GV8_CDUFOR"   ,""            },;
											{"GV8_CDFIOR"   ,""            },;
											{"GV8_TPDEST"   ,""            },;
											{"GV8_NRCIDS"   ,""            },;
											{"GV8_DSTDEI"   ,""            },;
											{"GV8_DSTDEF"   ,""            },;
											{"GV8_NRREDS"   ,""            },;
											{"GV8_CDPADS"   ,""            },;
											{"GV8_CDUFDS"   ,""            },;
											{"GV8_CDFIDS"   ,""            },;
											{"GV8_DUPSEN"   ,""            },;
											{"GV8_PCDEV"    ,""            },;
											{"GV8_PCREEN"   ,""            },;
											{"GV8_VLMXRE"   ,""            },;
											{"GV8_CDREM"    ,""            },;
											{"GV8_CDDEST"   ,""            },;
											{"GV8_VLMINR"   ,""            },;
											{"GV8_TRPREE"   ,""            }}

							cAliasGV8 := GetNextAlias()
							BeginSql Alias cAliasGV8
								SELECT GV8_FILIAL,
									GV8_CDEMIT,
									GV8_NRTAB,
									GV8_NRNEG,
									GV8_NRROTA,
									GV8_PRIROT,
									GV8_TPORIG,
									GV8_NRCIOR,
									GV8_DSTORI,
									GV8_DSTORF,
									GV8_NRREOR,
									GV8_CDPAOR,
									GV8_CDUFOR,
									GV8_CDFIOR,
									GV8_TPDEST,
									GV8_NRCIDS,
									GV8_DSTDEI,
									GV8_DSTDEF,
									GV8_NRREDS,
									GV8_CDPADS,
									GV8_CDUFDS,
									GV8_CDFIDS,
									GV8_DUPSEN,
									GV8_PCDEV,
									GV8_PCREEN,
									GV8_VLMXRE,
									GV8_CDREM,
									GV8_CDDEST,
									GV8_VLMINR,
									GV8_TRPREE
								FROM %Table:GV8% GV8
								WHERE GV8.GV8_FILIAL = %xFilial:GV8%
								AND GV8.GV8_CDEMIT   = %Exp:cCdTransp%
								AND GV8.GV8_NRTAB    = %Exp:cCdTab%
								AND GV8.GV8_NRNEG    = %Exp:cNrNeg%
								AND GV8.%NotDel%
							EndSql
							(cAliasGV8)->(dbGoTop())
							While !(cAliasGV8)->(Eof())
								RecLock("GV8", .T.)
									For nCnt := 1 To Len(aHeaderGV8) // campos da tabela
										If !Empty(aHeaderGV8[nCnt][2])
											&(aHeaderGV8[nCnt][1]) := aHeaderGV8[nCnt][2]
										Else
											&(aHeaderGV8[nCnt][1]) := &("(cAliasGV8)->" + aHeaderGV8[nCnt][1])
										EndIf
									Next nCnt
								GV8->(MsUnLock())
								(cAliasGV8)->(dbSkip())
							EndDo
						EndIf

						// -- Copia das Faixas---------------------------------------
						If lCopyFaixas 
							aHeaderGV7 := { {"GV7_FILIAL"   ,xFilial("GV7")},;
											{"GV7_CDEMIT"   ,cNovCdTransp  },;
											{"GV7_NRTAB"    ,cNovCdTab     },;
											{"GV7_NRNEG"    ,""            },;
											{"GV7_CDFXTV"   ,""            },;
											{"GV7_CDTPVC"   ,""            },;
											{"GV7_QTFXFI"   ,""            },;
											{"GV7_UNICAL"   ,""            },;
											{"GV7_FXSOMA"   ,""            },;
											{"GV7_QTCOTA"   ,""            },;
											{"GV7_VLALUG"   ,""            },;
											{"GV7_FRQKM"    ,""            },;
											{"GV7_VLKMEX"   ,""            },;
											{"GV7_QTCDED"   ,""            },;
											{"GV7_ESCOKM"   ,""            }}

							cAliasGV7 := GetNextAlias()
							BeginSql Alias cAliasGV7
								SELECT GV7_FILIAL,
									GV7_CDEMIT,
									GV7_NRTAB,
									GV7_NRNEG,
									GV7_CDFXTV,
									GV7_CDTPVC,
									GV7_QTFXFI,
									GV7_UNICAL,
									GV7_FXSOMA,
									GV7_QTCOTA,
									GV7_VLALUG,
									GV7_FRQKM,
									GV7_VLKMEX,
									GV7_QTCDED,
									GV7_ESCOKM
								FROM %Table:GV7% GV7
								WHERE GV7.GV7_FILIAL = %xFilial:GV7%
								AND GV7.GV7_CDEMIT   = %Exp:cCdTransp%
								AND GV7.GV7_NRTAB    = %Exp:cCdTab%
								AND GV7.GV7_NRNEG    = %Exp:cNrNeg%
								AND GV7.%NotDel%
							EndSql
							(cAliasGV7)->(dbGoTop())
							While !(cAliasGV7)->(Eof())
								RecLock("GV7", .T.)
									For nCnt := 1 To Len(aHeaderGV7) // campos da tabela
										If !Empty(aHeaderGV7[nCnt][2])
											&(aHeaderGV7[nCnt][1]) := aHeaderGV7[nCnt][2]
										Else
											&(aHeaderGV7[nCnt][1]) := &("(cAliasGV7)->" + aHeaderGV7[nCnt][1])
										EndIf
									Next nCnt
								GV7->(MsUnLock())
								(cAliasGV7)->(dbSkip())
							EndDo
						EndIf
											
						// -- Copia das Faixas e Entrega ----------------------------
						aHeaderGUZ := { {"GUZ_FILIAL"   ,xFilial("GUZ")},;
										{"GUZ_CDEMIT"   ,cNovCdTransp  },;
										{"GUZ_NRTAB"    ,cNovCdTab     },;
										{"GUZ_NRNEG"    ,""            },;
										{"GUZ_SEQFAI"   ,""            },;
										{"GUZ_VLFXFI"   ,""            },;
										{"GUZ_PCENTR"   ,""            },;
										{"GUZ_VLENTR"   ,""            }}

						cAliasGUZ := GetNextAlias()
						BeginSql Alias cAliasGUZ
							SELECT GUZ_FILIAL,
								GUZ_CDEMIT,
								GUZ_NRTAB,
								GUZ_NRNEG,
								GUZ_SEQFAI,
								GUZ_VLFXFI,
								GUZ_PCENTR,
								GUZ_VLENTR
							FROM %Table:GUZ% GUZ
							WHERE GUZ.GUZ_FILIAL = %xFilial:GUZ%
							AND GUZ.GUZ_CDEMIT   = %Exp:cCdTransp%
							AND GUZ.GUZ_NRTAB    = %Exp:cCdTab%
							AND GUZ.GUZ_NRNEG    = %Exp:cNrNeg%
							AND GUZ.%NotDel%
						EndSql
						(cAliasGUZ)->(dbGoTop())
						While (cAliasGUZ)->(!Eof())
							RecLock("GUZ", .T.)
								For nCnt := 1 To Len(aHeaderGUZ) // campos da tabela
									If !Empty(aHeaderGUZ[nCnt][2])
										&(aHeaderGUZ[nCnt][1]) := aHeaderGUZ[nCnt][2]
									Else
										&(aHeaderGUZ[nCnt][1]) := &("(cAliasGUZ)->" + aHeaderGUZ[nCnt][1])
									EndIf
								Next nCnt
							GUZ->(MsUnLock())
							(cAliasGUZ)->(dbSkip())
						EndDo
						
						// -- Copia das Tarifas -------------------------------------
						If lCopyTarifas .AND. lCopyRotas .AND. lCopyFaixas	
							cHora      := cValToChar(Time())       
							aHeaderGV6 := { {"GV6_FILIAL"   ,xFilial("GV6") },;
											{"GV6_CDEMIT"   ,cNovCdTransp   },;
											{"GV6_NRTAB"    ,cNovCdTab      },;
											{"GV6_NRNEG"    ,""             },;
											{"GV6_CDFXTV"   ,""             },;
											{"GV6_NRROTA"   ,""             },;
											{"GV6_QTMIN"    ,""             },;
											{"GV6_FRMIN"    ,""             },;
											{"GV6_COMFRG"   ,""             },;
											{"GV6_CONSPZ"   ,""             },;
											{"GV6_TPPRAZ"   ,""             },;
											{"GV6_QTPRAZ"   ,""             },;
											{"GV6_CONTPZ"   ,""             },;
											{"GV6_DTATU"    ,DDATABASE      },;
											{"GV6_HRATU"    ,cHora          },;
											{"GV6_USUATU"   ,cUserName      }}

							cAliasGV6  := GetNextAlias()
							BeginSQL Alias cAliasGV6
								SELECT GV6_FILIAL,
									GV6_CDEMIT,
									GV6_NRTAB,
									GV6_NRNEG,
									GV6_CDFXTV, 
									GV6_NRROTA,
									GV6_QTMIN,
									GV6_FRMIN,
									GV6_COMFRG,
									GV6_CONSPZ,
									GV6_TPPRAZ,
									GV6_QTPRAZ,
									GV6_CONTPZ,
									GV6_DTATU,
									GV6_HRATU,
									GV6_USUATU
								FROM %Table:GV6% GV6
								WHERE GV6.GV6_FILIAL = %xFilial:GV6%
								AND GV6.GV6_CDEMIT   = %Exp:cCdTransp%
								AND GV6.GV6_NRTAB    = %Exp:cCdTab%
								AND GV6.GV6_NRNEG    = %Exp:cNrNeg%
								AND GV6.%NotDel%
							EndSQL	       
							(cAliasGV6)->(dbGoTop())	
							While !(cAliasGV6)->(Eof())
								RecLock("GV6", .T.)
									For nCnt := 1 To Len(aHeaderGV6) // campos da tabela
										If !Empty(aHeaderGV6[nCnt][2])
											&(aHeaderGV6[nCnt][1]) := aHeaderGV6[nCnt][2]
										Else
											&(aHeaderGV6[nCnt][1]) := &("(cAliasGV6)->" + aHeaderGV6[nCnt][1])
										EndIf
									Next nCnt
								GV6->(MsUnLock())
								(cAliasGV6)->(dbSkip())
							EndDo
							
							// -- Copia dos Componentes das Tarifas ---------------------
							aHeaderGV1 := { {"GV1_FILIAL"   ,xFilial("GV1") },;
											{"GV1_CDEMIT"   ,cNovCdTransp   },;
											{"GV1_NRTAB"    ,cNovCdTab      },;
											{"GV1_NRNEG"    ,""             },;
											{"GV1_CDFXTV"   ,""             },;
											{"GV1_NRROTA"   ,""             },;
											{"GV1_CDCOMP"   ,""             },;
											{"GV1_VLFIXN"   ,""             },;
											{"GV1_PCNORM"   ,""             },;
											{"GV1_VLUNIN"   ,""             },;
											{"GV1_VLFRAC"   ,""             },;
											{"GV1_VLMINN"   ,""             },;
											{"GV1_VLLIM"    ,""             },;
											{"GV1_VLFIXE"   ,""             },;
											{"GV1_PCEXTR"   ,""             },;
											{"GV1_VLUNIE"   ,""             },;
											{"GV1_CALCEX"   ,""             }}

							cAliasGV1  := GetNextAlias()
							BeginSQL Alias cAliasGV1
								SELECT GV1_FILIAL,
									GV1_CDEMIT,
									GV1_NRTAB,
									GV1_NRNEG,
									GV1_CDFXTV, 
									GV1_NRROTA,
									GV1_CDCOMP,
									GV1_VLFIXN,
									GV1_PCNORM,
									GV1_VLUNIN,
									GV1_VLFRAC,
									GV1_VLMINN,
									GV1_VLLIM,
									GV1_VLFIXE,
									GV1_PCEXTR,
									GV1_VLUNIE,
									GV1_CALCEX
								FROM %Table:GV1% GV1
								WHERE GV1.GV1_FILIAL = %xFilial:GV1%
								AND GV1.GV1_CDEMIT   = %Exp:cCdTransp%
								AND GV1.GV1_NRTAB    = %Exp:cCdTab%
								AND GV1.GV1_NRNEG    = %Exp:cNrNeg%
								AND GV1.%NotDel%
								EndSQL	       
							(cAliasGV1)->(dbGoTop())	
							While !(cAliasGV1)->(Eof())
								RecLock("GV1", .T.)
									For nCnt := 1 To Len(aHeaderGV1) // campos da tabela
										If !Empty(aHeaderGV1[nCnt][2])
											&(aHeaderGV1[nCnt][1]) := aHeaderGV1[nCnt][2]
										Else
											&(aHeaderGV1[nCnt][1]) := &("(cAliasGV1)->" + aHeaderGV1[nCnt][1])
										EndIf
										If lCopyZerar
											GV1->GV1_VLFIXN := 0
											GV1->GV1_PCNORM := 0
											GV1->GV1_VLUNIN := 0
											GV1->GV1_VLFRAC := 0
											GV1->GV1_VLMINN := 0
											GV1->GV1_VLLIM  := 0
											GV1->GV1_VLFIXE := 0
											GV1->GV1_PCEXTR := 0
											GV1->GV1_VLUNIE := 0
										EndIf
									Next nCnt
								GV1->(MsUnLock())
								(cAliasGV1)->(dbSkip())
							EndDo

							// -- Copia dos Componentes Adicionais das Tarifas ----------
							aHeaderGUC := { {"GUC_FILIAL"   ,xFilial("GUC")},;
											{"GUC_CDEMIT"   ,cNovCdTransp  },;
											{"GUC_NRTAB"    ,cNovCdTab     },;
											{"GUC_NRNEG"    ,""            },;
											{"GUC_CDFXTV"   ,""            },;
											{"GUC_NRROTA"   ,""            },;
											{"GUC_CDCOMP"   ,""            },;
											{"GUC_EMICOM"   ,""            },;
											{"GUC_VLFIXN"   ,""            },;
											{"GUC_PCNORM"   ,""            },;
											{"GUC_VLUNIN"   ,""            },;
											{"GUC_VLFRAC"   ,""            },;
											{"GUC_VLMINN"   ,""            },;
											{"GUC_PCLIM"    ,""            },;
											{"GUC_VLLIM"    ,""            },;
											{"GUC_VLFIXE"   ,""            },;
											{"GUC_PCEXTR"   ,""            },;
											{"GUC_VLUNIE"   ,""            },;
											{"GUC_CALCEX"   ,""            }}

							cAliasGUC := GetNextAlias()
							BeginSql Alias cAliasGUC
								SELECT GUC_FILIAL,
									GUC_CDEMIT,
									GUC_NRTAB,
									GUC_NRNEG,
									GUC_CDFXTV,
									GUC_NRROTA,
									GUC_CDCOMP,
									GUC_EMICOM,
									GUC_VLFIXN,
									GUC_PCNORM,
									GUC_VLUNIN,
									GUC_VLFRAC,
									GUC_VLMINN,
									GUC_PCLIM,
									GUC_VLLIM,
									GUC_VLFIXE,
									GUC_PCEXTR,
									GUC_VLUNIE,
									GUC_CALCEX
								FROM %Table:GUC% GUC
								WHERE GUC.GUC_FILIAL = %xFilial:GUC%
								AND GUC.GUC_CDEMIT   = %Exp:cCdTransp%
								AND GUC.GUC_NRTAB    = %Exp:cCdTab%
								AND GUC.GUC_NRNEG    = %Exp:cNrNeg%
								AND GUC.%NotDel%
							EndSql
							(cAliasGUC)->(dbGoTop())
							While (cAliasGUC)->(!Eof())
								RecLock("GUC", .T.)
									For nCnt := 1 To Len(aHeaderGUC) // campos da tabela
										If !Empty(aHeaderGUC[nCnt][2])
											&(aHeaderGUC[nCnt][1]) := aHeaderGUC[nCnt][2]
										Else
											&(aHeaderGUC[nCnt][1]) := &("(cAliasGUC)->" + aHeaderGUC[nCnt][1])
										EndIf
										If lCopyZerar
											GUC->GUC_VLFIXN := 0
											GUC->GUC_PCNORM := 0
											GUC->GUC_VLUNIN := 0
											GUC->GUC_VLFRAC := 0
											GUC->GUC_VLMINN := 0
											GUC->GUC_PCLIM  := 0
											GUC->GUC_VLLIM  := 0
											GUC->GUC_VLFIXE := 0
											GUC->GUC_PCEXTR := 0
											GUC->GUC_VLUNIE := 0
										EndIf
									Next nCnt
								GUC->(MsUnLock())
								(cAliasGUC)->(dbSkip())
							EndDo
						EndIf
					Else
						cErros := cErros + "** Negociação não encontrada. Emitente: " + cCdTransp + ", Tabela: " + cCdTab + ", Negociação: " + cNrNeg + CHR(10) + CHR(13) + CHR(10) + CHR(13)
					EndIf
			EndIf
		Next
	Else
		cErros := cErros + "** Tabela não encontrada. Emitente: " + cCdTransp + ", Tabela: " + cCdTab + CHR(10) + CHR(13) + CHR(10) + CHR(13)
		Return .F.
	EndIf
	
Return

/*-------------------------------------------------------------------                                                                           
DefTabNeg
Definição do Grid de Negociações

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function DefTabNeg()

	Local aHead    := {}	// Campos da temp-table de Tabela de Frete
	
	aAdd( aHead, { ;
		''                 , ;    // 01 - Titulo
		'MRK'            , ;    // 02 - Campo
		'@BMP'             , ;    // 03 - Picture
		10                 , ;    // 04 - Tamanho
		0                  , ;    // 05 - Decimal
		''                 , ;    // 06 - Valid
		''                 , ;    // 07 - Usado
		'C'                , ;    // 08 - Tipo
		''                 , ;    // 09 - F3
		'R'                , ;    // 10 - Contexto
		''                 , ;    // 11 - ComboBox
		''             , ;    // 12 - Relacao
		''                 , ;    // 13 - Alterar
		'V'                , ;    // 14 - Visual
		''                 } )    // 15 - Valid Usuario
		
	AddTabHead(@aHead, "Negociação"   ,	"NRNEG"  , "C", TamSX3("GV9_NRNEG")[1] , 0, "@!")
	AddTabHead(@aHead, "Class.Frete"  , "CDCLFR" , "C", TamSX3("GV9_CDCLFR")[1], 0, "@!")
	AddTabHead(@aHead, "Descrição"    , "DSCLFR" , "C", 30, 0, "@!")
	AddTabHead(@aHead, "Tipo Oper."	  , "CDTPOP" , "C", TamSX3("GV9_CDTPOP")[1], 0, "@!")
	AddTabHead(@aHead, "Descrição"    , "DSOPER" , "C", 30, 0, "@!")
	AddTabHead(@aHead, "Vigencia De"  , "DTVALI" , "D", 08, 0, "")
	AddTabHead(@aHead, "Vigencia Ate" , "DTVALF" , "D", 08, 0, "")
	AddTabHead(@aHead, "Nova Vigencia De"  , "NDTVALI" , "D", 08, 0, "")
	AddTabHead(@aHead, "Nova Vigencia Ate" , "NDTVALF" , "D", 08, 0, "")

Return aHead


/*-------------------------------------------------------------------                                                                           
AddTabHead
Função para auxiliar a criação do Array de cabeçalho do Grid

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function AddTabHead(aHead, Titulo, Nome, TipoDado, Tamanho, Decimal, Mascara,cValid,cUsado,cF3)
	Default cValid := ''
	Default cUsado := ''
	Default cF3     := ''
	
	aAdd( aHead, { ;	
	Titulo			, ;    // 01 - Titulo
	Nome    		, ;    // 02 - Campo
	Mascara        	, ;    // 03 - Picture
	Tamanho        	, ;    // 04 - Tamanho
	Decimal        	, ;    // 05 - Decimal
	cValid         	, ;    // 06 - Valid
	cUsado          	, ;    // 07 - Usado
	TipoDado       	, ;    // 08 - Tipo
	cF3          	, ;    // 09 - F3
	'R'         	, ;    // 10 - Contexto
	''          	, ;    // 11 - ComboBox
	''      		, ;    // 12 - Relacao
	'.T.'          	, ;    // 13 - Alterar
	''         		, ;    // 14 - Visual
	''          	} )    // 15 - Valid Usuario
Return


