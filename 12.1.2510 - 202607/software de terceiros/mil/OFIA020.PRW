#INCLUDE "totvs.ch"
#INCLUDE "fileio.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "OFIA020.CH"

/*/{Protheus.doc} OFIA020
	Tela de Reprocessamento dos dados do DSM Scania

	@author Andre Luis Almeida
	@since  06/09/2018
/*/
Function OFIA020()
Local   oInterfHelper  := DMS_InterfaceHelper():New()
Local   aObjects       := {}
Local   aInfo          := {}
Local   aPos           := {}
Local   aSizeHalf      := MsAdvSize(.t.)
Local   aBotOFIA020    := {}
Local   oDSMParametros := OFDSMParametros():New()
Local 	lVPJCodigo 	   := VPJ->(FieldPos("VPJ_CODIGO")) > 0
Private aExecucoes     := {}
Private aDadosFil      := {}
Private aXMLs          := {}
Private aCposFiltro    := OA0200021_CamposFiltro()
Private cCadastro      := STR0001 	// DSM Execuções/Reprocessamento
Private M->TMP_DATINI  := dDataBase-7
Private M->TMP_DATFIN  := dDataBase
Private M->TMP_TIPEXE  := " "
Private cDirXML        := oDSMParametros:diretorio_XML()
Private cPerg := "OFIA030"

	AADD(aBotOFIA020, {"BMPGROUP" ,{|| FWMsgRun(, {|| OA0200051_CargaInicialXML() }           , STR0002, "") }, STR0002 } ) // Processa Carga Inicial
	AADD(aBotOFIA020, {"BMPGROUP" ,{|| FWMsgRun(, {|| OA0200061_PrecosXML() }                 , STR0003, "") }, STR0003 } ) // Processa Price Updates
	AADD(aBotOFIA020, {"BMPGROUP" ,{|| FWMsgRun(, {|| OA0200041_RefazXML( oLBExecucoes:nAt ) }, STR0004, "") }, STR0004 } ) // Reprocessa execução selecionada

	oInterfHelper:nOpc := 2 
	oInterfHelper:SetOwnerPvt("OFIA020")

	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 }
	aAdd( aObjects, { 100 , 100 , .T. , .T. } )
	aPos := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oOFIA020 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oOFIA020:lEscClose := .F.

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oOFIA020,.t.)

	oFWLayer:AddLine('WIN_TOP',45,.F.)
	oFWLayer:addCollumn('WIN_TOPE',20,.F.,"WIN_TOP")
	oFWLayer:addCollumn('WIN_TOPD',80,.F.,"WIN_TOP")

	oFWLayer:AddLine('WIN_DOW',45,.F.)
	oFWLayer:addCollumn('WIN_DOWE',70,.F.,"WIN_DOW") 
	oFWLayer:addCollumn('WIN_DOWD',30,.F.,"WIN_DOW") 

	oFWLayer:AddWindow('WIN_TOPE','WIN_TOPGERAL', STR0005 ,100,.F.,.F.,,'WIN_TOP',) // Filtros
	oFWLayer:AddWindow('WIN_TOPD','WIN_TOPGERAL', STR0006 ,100,.F.,.F.,,'WIN_TOP',) // Execuções
	oFWLayer:AddWindow('WIN_DOWE','WIN_DOWGERAL', STR0007 ,100,.F.,.F.,,'WIN_DOW',) // Parametrizações por Filiais
	oFWLayer:AddWindow('WIN_DOWD','WIN_DOWGERAL', STR0008 ,100,.F.,.F.,,'WIN_DOW',) // Arquivos Gerados

	oWIN_TOPE := oFWLayer:GetWinPanel('WIN_TOPE','WIN_TOPGERAL', 'WIN_TOP')
	oWIN_TOPD := oFWLayer:GetWinPanel('WIN_TOPD','WIN_TOPGERAL', 'WIN_TOP')
	oWIN_DOWE := oFWLayer:GetWinPanel('WIN_DOWE','WIN_DOWGERAL', 'WIN_DOW')
	oWIN_DOWD := oFWLayer:GetWinPanel('WIN_DOWD','WIN_DOWGERAL', 'WIN_DOW')

	OA0200011_LevantaDados( 0 , .f. )

	oCposFiltro := MsmGet():New(,,4,/*aCRA*/,/*cLetras*/,/*cTexto*/,/*aCpoEnch*/,{000,000,100,100},/*aAlterEnch*/,/*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oWIN_TOPE,/*lF3*/,/*lMemoria*/,/*lColumn*/,/*caTela*/,;
	/*lNoFolder*/,/*lProperty*/,aCposFiltro,/*aFolder*/,/*lCreate*/,/*lNoMDIStretch*/,/*cTela*/)
	oCposFiltro:oBox:align := CONTROL_ALIGN_ALLCLIENT

	oLBExecucoes := TWBrowse():New( 1, 1, 1, 1,;
								,,,oWIN_TOPD,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLBExecucoes:SetArray(aExecucoes)
	oLBExecucoes:addColumn( TCColumn():New( STR0009 , { || Transform(aExecucoes[oLBExecucoes:nAt,03],"@D"      )    } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )		// "Data Execução"
	oLBExecucoes:addColumn( TCColumn():New( STR0010 , { || Transform(aExecucoes[oLBExecucoes:nAt,04],"@R 99:99")    } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )		// "Hora Execução"
	oLBExecucoes:addColumn( TCColumn():New( STR0011 , { || IIf(!Empty(aExecucoes[oLBExecucoes:nAt,05]),X3CBOXDESC("VBJ_TIPEXE",aExecucoes[oLBExecucoes:nAt,05]),"") } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )		// "Tipo Execução"
	oLBExecucoes:addColumn( TCColumn():New( STR0012 , { || Transform(aExecucoes[oLBExecucoes:nAt,06],"@D"      )    } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )		// "Data Inicial"
	oLBExecucoes:addColumn( TCColumn():New( STR0013 , { || Transform(aExecucoes[oLBExecucoes:nAt,07],"@R 99:99")    } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )		// "Hora Inicial"
	oLBExecucoes:addColumn( TCColumn():New( STR0014 , { || Transform(aExecucoes[oLBExecucoes:nAt,08],"@D"      )    } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )		// "Data Final"
	oLBExecucoes:addColumn( TCColumn():New( STR0015 , { || Transform(aExecucoes[oLBExecucoes:nAt,09],"@R 99:99")    } ,,,, "LEFT" ,  50 ,.F.,.F.,,,,.F.,) )		// "Hora Final"
	oLBExecucoes:bChange := { || OA0200011_LevantaDados( oLBExecucoes:nAt , .t. ) }
	oLBExecucoes:bLDblClick := { || OA0200041_RefazXML( oLBExecucoes:nAt ) }
	oLBExecucoes:Align := CONTROL_ALIGN_ALLCLIENT

	oLBDadosFil := TWBrowse():New( 1, 1, 1, 1,;
								,,,oWIN_DOWE,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLBDadosFil:SetArray(aDadosFil)
	oLBDadosFil:addColumn( TCColumn():New( STR0016 , { || aDadosFil[oLBDadosFil:nAt,01] } ,,,, "LEFT" ,  70 ,.F.,.F.,,,,.F.,) )		// "Filial"
	oLBDadosFil:addColumn( TCColumn():New( STR0017 , { || aDadosFil[oLBDadosFil:nAt,02] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "SD1 Inicial"
	oLBDadosFil:addColumn( TCColumn():New( STR0018 , { || aDadosFil[oLBDadosFil:nAt,03] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "SD1 Final"
	oLBDadosFil:addColumn( TCColumn():New( STR0019 , { || aDadosFil[oLBDadosFil:nAt,04] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "SD2 Inicial"
	oLBDadosFil:addColumn( TCColumn():New( STR0020 , { || aDadosFil[oLBDadosFil:nAt,05] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "SD2 Final"
	oLBDadosFil:addColumn( TCColumn():New( STR0021 , { || aDadosFil[oLBDadosFil:nAt,06] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "SD3 Inicial"
	oLBDadosFil:addColumn( TCColumn():New( STR0022 , { || aDadosFil[oLBDadosFil:nAt,07] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "SD3 Final"
	oLBDadosFil:addColumn( TCColumn():New( STR0023 , { || aDadosFil[oLBDadosFil:nAt,08] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "VE9 Inicial"
	oLBDadosFil:addColumn( TCColumn():New( STR0024 , { || aDadosFil[oLBDadosFil:nAt,09] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) )		// "VE9 Final"
	If lVPJCodigo
		oLBDadosFil:addColumn( TCColumn():New( STR0041 , { || aDadosFil[oLBDadosFil:nAt,10] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) ) // "VPJ Inicial"
		oLBDadosFil:addColumn( TCColumn():New( STR0042 , { || aDadosFil[oLBDadosFil:nAt,11] } ,,,, "LEFT" ,  38 ,.F.,.F.,,,,.F.,) ) // "VPJ Final"
	Endif
	oLBDadosFil:Align := CONTROL_ALIGN_ALLCLIENT

	oLBXMLs := TWBrowse():New( 1, 1, 1, 1,;
								,,,oWIN_DOWD,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLBXMLs:SetArray(aXMLs)
	oLBXMLs:addColumn( TCColumn():New( STR0025 , { || aXMLs[oLBXMLs:nAt,01] } ,,,, "LEFT" , 150 ,.F.,.F.,,,,.F.,) )		// "XML's"
	oLBXMLs:Align := CONTROL_ALIGN_ALLCLIENT
	oLBXMLs:bLDblClick := { || OA0200031_VisualizaXML(oLBXMLs:nAt) }

	ACTIVATE MSDIALOG oOFIA020 ON INIT EnchoiceBar(oOFIA020,{ || oOFIA020:End() }, { || oOFIA020:End() },,aBotOFIA020)
return .T.


/*/{Protheus.doc} OA0200011_LevantaDados
	Levanta dados da tela

	@author Andre Luis Almeida
	@since  10/09/2018
/*/
Static Function OA0200011_LevantaDados( nLinha , lRefresh )
Local nCntFor := 0
Local cQuery  := ""
Local cQAlSQL := "SQLVBJ"
Local cNomXML := ""
Local oStatement
Local lVPJCodigo := VPJ->(FieldPos("VPJ_CODIGO")) > 0
Default lRefresh := .f.

	If nLinha == 0
		aExecucoes := {}

		cQuery	:= "SELECT DISTINCT VBJ_FILIAL ," + CRLF
		cQuery	+= "                VBJ_CODIGO ," + CRLF
		cQuery	+= "                VBJ_DATEXE ," + CRLF
		cQuery	+= "                VBJ_HOREXE ," + CRLF
		cQuery	+= "                VBJ_TIPEXE ," + CRLF
		cQuery	+= "                VBJ_DATINI ," + CRLF
		cQuery	+= "                VBJ_HORINI ," + CRLF
		cQuery	+= "                VBJ_DATFIN ," + CRLF
		cQuery	+= "                VBJ_HORFIN ," + CRLF
		cQuery	+= "                VBJ_CODFIL " + CRLF
		cQuery	+= "  FROM "+RetSqlName("VBJ")+" VBJ " + CRLF
		cQuery	+= " WHERE VBJ_FILIAL = ?" + CRLF
		cQuery	+= "   AND VBJ_DATEXE >= ?" + CRLF
		cQuery	+= "   AND VBJ_DATEXE <= ?" + CRLF
		cQuery	+= "   AND VBJ.D_E_L_E_T_ = ?" + CRLF
		if ! empty( M->TMP_TIPEXE )
			cQuery	+= "   AND VBJ_TIPEXE = ?" + CRLF // 0=Carga Inicial;1=Manual;2=Schedule;3=Reproc.Manual;4=Price Updates
		endif
		cQuery	+= " ORDER BY VBJ_DATEXE, VBJ_HOREXE" + CRLF

		oStatement := FwExecStatement():new( cQuery )
		oStatement:setString( 1, xFilial("VBJ") )
		oStatement:setString( 2, DtoS(M->TMP_DATINI) )
		oStatement:setString( 3, DtoS(M->TMP_DATFIN) )
		oStatement:setString( 4, " " )

		if ! empty( M->TMP_TIPEXE )
			oStatement:setString( 5, M->TMP_TIPEXE )
		endif

		cQuery := oStatement:getFixQuery()
		oStatement:OpenAlias( cQAlSQL )

		while !( cQAlSQL )->( Eof() )
			aAdd(aExecucoes,{	( cQAlSQL )->( VBJ_FILIAL ),;
								( cQAlSQL )->( VBJ_CODIGO ),;
								stod(( cQAlSQL )->( VBJ_DATEXE )),;
								( cQAlSQL )->( VBJ_HOREXE ),;
								( cQAlSQL )->( VBJ_TIPEXE ),;
								stod(( cQAlSQL )->( VBJ_DATINI )),;
								( cQAlSQL )->( VBJ_HORINI ),;
								stod(( cQAlSQL )->( VBJ_DATFIN )),;
								( cQAlSQL )->( VBJ_HORFIN ),;
								( cQAlSQL )->( VBJ_CODFIL )})
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )

		DbSelectArea("VBJ")
		If len(aExecucoes) == 0
			aAdd(aExecucoes,{"","",ctod(""),"","",ctod(""),"",ctod(""),""})
		EndIf
		If lRefresh
			oLBExecucoes:nAt := 1
			oLBExecucoes:SetArray(aExecucoes)
			oLBExecucoes:Refresh()
			OA0200011_LevantaDados( oLBExecucoes:nAt , .t. )
		EndIf
	Else
		aDadosFil := {}
		aXMLs     := {}
		cQuery	:= "SELECT VBJ_CODFIL ," + CRLF
		cQuery	+= "       VBJ_SQSD1I ," + CRLF
		cQuery	+= "       VBJ_SQSD1F ," + CRLF
		cQuery	+= "       VBJ_SQSD2I ," + CRLF
		cQuery	+= "       VBJ_SQSD2F ," + CRLF
		cQuery	+= "       VBJ_SQSD3I ," + CRLF
		cQuery	+= "       VBJ_SQSD3F ," + CRLF
		cQuery	+= "       VBJ_SQVE9I ," + CRLF
		cQuery	+= "       VBJ_SQVE9F ," + CRLF
		cQuery	+= "       VBJ_NOMXML ," + CRLF
		cQuery	+= "       VBJ_QTDXML  " + CRLF
		If lVPJCodigo
			cQuery	+= "	, VBJ_SQVPJI ," + CRLF
			cQuery	+= "	  VBJ_SQVPJF  " + CRLF
		Endif
		cQuery	+= "  FROM "+RetSqlName("VBJ")+" VBJ " + CRLF
		cQuery	+= " WHERE VBJ_FILIAL = ?" + CRLF
		cQuery	+= "   AND VBJ_CODIGO = ?" + CRLF
		cQuery	+= "   AND D_E_L_E_T_ = ?" + CRLF

		oStatement := FwExecStatement():new( cQuery )
		oStatement:setString( 1, aExecucoes[nLinha,1] )
		oStatement:setString( 2, aExecucoes[nLinha,2] )
		oStatement:setString( 3, " " )

		cQuery := oStatement:getFixQuery()
		oStatement:OpenAlias( cQAlSQL )

		While !( cQAlSQL )->( Eof() )
			aAdd(aDadosFil,{	( cQAlSQL )->( VBJ_CODFIL ),;
								( cQAlSQL )->( VBJ_SQSD1I ),;
								( cQAlSQL )->( VBJ_SQSD1F ),;
								( cQAlSQL )->( VBJ_SQSD2I ),;
								( cQAlSQL )->( VBJ_SQSD2F ),;
								( cQAlSQL )->( VBJ_SQSD3I ),;
								( cQAlSQL )->( VBJ_SQSD3F ),;
								( cQAlSQL )->( VBJ_SQVE9I ),;
								( cQAlSQL )->( VBJ_SQVE9F )})
			If lVPJCodigo // Apresentar os novos campos de sequencial da Venda Perdida em tela
				aAdd( aDadosFil[Len(aDadosFil)] ,( cQAlSQL )->( VBJ_SQVPJI ))
				aAdd( aDadosFil[Len(aDadosFil)] ,( cQAlSQL )->( VBJ_SQVPJF ))
			Endif

			If len(aXMLs) == 0 .and. ! empty( cDirXML )
				For nCntFor := 1 to ( cQAlSQL )->( VBJ_QTDXML )
					cNomXML := Alltrim(( cQAlSQL )->( VBJ_NOMXML ))+"_"+strzero(nCntFor,5)+".XML"
					If File(cDirXML+"/"+cNomXML)
						aAdd(aXMLs,{ cNomXML })
					Else
						cNomXML := Alltrim(( cQAlSQL )->( VBJ_NOMXML ))+"_"+strzero(nCntFor,5)+".ERRO"
						If File(cDirXML+"/"+cNomXML)
							aAdd(aXMLs,{ cNomXML })
						EndIf
					EndIf
				Next
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )

		If len(aDadosFil) == 0
			aAdd(aDadosFil,{"","","","","","","","",""})
			If lVPJCodigo // Apresentar os novos campos de sequencial da Venda Perdida em tela
				aAdd( aDadosFil[Len(aDadosFil)] , "")
				aAdd( aDadosFil[Len(aDadosFil)] , "")
			Endif
		EndIf
		If len(aXMLs) == 0
			aAdd(aXMLs,{""})
		EndIf
		If lRefresh
			oLBDadosFil:SetArray(aDadosFil)
			oLBDadosFil:Refresh()
			oLBXMLs:SetArray(aXMLs)
			oLBXMLs:Refresh()
		EndIf
	EndIf

	oStatement:destroy()
	FwFreeObj(oStatement)
return nil


/*/{Protheus.doc} OA0200021_CamposFiltro
	Campos a serem utilizados na Enchoice da aba Outros (aCposFiltro)

	@author Andre Luis Almeida
	@since  10/09/2018
/*/
Static Function OA0200021_CamposFiltro()
Local aRet := {}
	Aadd(aRet,{ STR0026 ,"TMP_DATINI","D", 8,0,""  ,&('{ || OA0200011_LevantaDados( 0 , .t. ) }'),.F.,1,"","","",.F.,.F.,"",Val(""),.F.,"",""}) // Data Execução Inicial
	Aadd(aRet,{ STR0027 ,"TMP_DATFIN","D", 8,0,""  ,&('{ || OA0200011_LevantaDados( 0 , .t. ) }'),.F.,1,"","","",.F.,.F.,"",Val(""),.F.,"",""}) // Data Execução Final
	Aadd(aRet,{ STR0028 ,"TMP_TIPEXE","C", 1,0,""  ,&('{ || OA0200011_LevantaDados( 0 , .t. ) }'),.F.,1,"","","",.F.,.F.,"0="+STR0029+";1="+STR0030+";2="+STR0031,Val(""),.F.,"",""}) // Tipo de Execucao ( via 0-Carga Inicial / 1-Manual / 2-Schedule )
return aClone(aRet)


/*/{Protheus.doc} OA0200031_VisualizaXML
	Visualiza XML selecionado

	@author Andre Luis Almeida
	@since  10/09/2018
/*/
Static Function OA0200031_VisualizaXML( nLinha )
Local oFile
Local cTexto  := ""
Local aSizeHalf := MsAdvSize(.t.)
	If !Empty(aXMLs[nLinha,1]) .and. ! empty( cDirXML )
		oFile := FWFileReader():New(cDirXML+"/"+aXMLs[nLinha,1])
		If (oFile:Open())
			while (oFile:hasLine())
				cTexto += oFile:GetLine()+CRLF
			end
			oFile:Close()

			// Formata o XML antes de exibir
    		cTexto := OA020007K_FormatXML( cTexto )

			cCadastro := aXMLs[nLinha,1]
			DEFINE MSDIALOG oDlgXML FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
			@ 1,1 GET oMEMOXML VAR cTexto OF oDlgXML MEMO SIZE 200,100 PIXEL ReadOnly MEMO
			oMEMOXML:Align := CONTROL_ALIGN_ALLCLIENT
			ACTIVATE MSDIALOG oDlgXML ON INIT EnchoiceBar(oDlgXML,{ || oDlgXML:End() }, { || oDlgXML:End() },,)
		EndIf
	EndIf
return nil


/*/{Protheus.doc} OA0200041_RefazXML
	Refaz XML da execução selecionada

	@author Andre Luis Almeida
	@since  10/09/2018
/*/
Static Function OA0200041_RefazXML( nLinha )
Local cMsg := ""
	If aExecucoes[nLinha,5] == "0"
		OA0200051_CargaInicialXML()
	ElseIf aExecucoes[nLinha,5] == "4"
		OA0200061_PrecosXML()
	Else
		If !Empty(aExecucoes[nLinha,2])
			cMsg :=	STR0032 +CRLF+CRLF+;		// "Reprocessar o(s) XML(s)?"
					STR0033 +Transform(aExecucoes[nLinha,6],"@D")+" - "+Transform(aExecucoes[nLinha,7],"@R 99:99")+CRLF+;		// "Data/Hora Inicial: "
					STR0034 +Transform(aExecucoes[nLinha,8],"@D")+" - "+Transform(aExecucoes[nLinha,9],"@R 99:99")		// "Data/Hora Final: "
			If FWAlertYesNo(cMsg, STR0035 )		// "Atenção"
				SetMVValue(cPerg, "MV_PAR01", 3)
				SetMVValue(cPerg, "MV_PAR02", aExecucoes[nLinha,10])
				SetMVValue(cPerg, "MV_PAR03", aExecucoes[nLinha,2])
				Pergunte(cPerg, .F.)
				OFIA030()
				OA0200011_LevantaDados( 0 , .t. )
			EndIf
		EndIf
	EndIf
return nil


/*/{Protheus.doc} OA0200051_CargaInicialXML
	Gera XML de Carga Inicial

	@author Andre Luis Almeida
	@since  10/09/2018
/*/
Static Function OA0200051_CargaInicialXML()
Local cMsg := ""
	cMsg :=	STR0036 +CRLF+CRLF+;		// "Deseja gerar o(s) XML(s) de Carga Inicial?"
			STR0037 +CRLF+;		// "Observação:"
			STR0038		// "A geração da Carga Inicial pode demandar muito tempo."
	If FWAlertYesNo(cMsg, STR0035 )		// "Atenção"
		SetMVValue(cPerg, "MV_PAR01", 1)
		SetMVValue(cPerg, "MV_PAR02", "")
		SetMVValue(cPerg, "MV_PAR03", "")
		Pergunte(cPerg, .F.)
		OFIA030()
		OA0200011_LevantaDados( 0 , .t. )
	EndIf
return nil


/*/{Protheus.doc} OA0200061_PrecosXML
	Gera XML do Price Updates

	@author Andre Luis Almeida
	@since  01/10/2021
/*/
Static Function OA0200061_PrecosXML()
Local cMsg := ""
	cMsg :=	STR0039 +CRLF+CRLF+;		// "Deseja gerar o(s) XML(s) de Price Updates?"
			STR0037 +CRLF+;		// "Observação:"
			STR0040		// "A geração de Price Updates pode demandar muito tempo."
	If FWAlertYesNo(cMsg, STR0035 )		// "Atenção"
		SetMVValue(cPerg, "MV_PAR01", 4)
		SetMVValue(cPerg, "MV_PAR02", "")
		SetMVValue(cPerg, "MV_PAR03", "")
		Pergunte(cPerg, .F.)
		OFIA030()
		OA0200011_LevantaDados( 0 , .t. )
	EndIf
return nil

/*/{Protheus.doc} OA020007K_FormatXML
    Formata string XML com indentação para melhor visualização

    @author Lucas Oliveira
    @since  09/04/2026
/*/
Static Function OA020007K_FormatXML( cXML )
	Local cFormatado  := ""
	Local cIndent     := ""
	Local nIndent     := 0
	Local cChar       := ""
	Local cTag        := ""
	Local nPos        := 1
	Local lFechando   := .F.
	Local lAutoFecha  := .F.
	Local lCabecalho  := .F.
	Local nLen        := Len(cXML)

    While nPos <= nLen
        cChar := SubStr(cXML, nPos, 1)

        If cChar == "<"
            // Captura a tag completa
            cTag := ""
            While nPos <= nLen .and. SubStr(cXML, nPos, 1) != ">"
                cTag += SubStr(cXML, nPos, 1)
                nPos++
            End
            cTag += ">"
            nPos++

            lFechando  := ( SubStr(cTag, 2, 1) == "/" )             // </tag>
            lAutoFecha := ( SubStr(cTag, Len(cTag)-1, 1) == "/" )   // <tag/>
            lCabecalho := ( SubStr(cTag, 2, 1) == "?" )             // <?xml?>

            If lFechando
                // Reduz indentação antes de escrever tag de fechamento
                nIndent--
                If nIndent < 0
                    nIndent := 0
                EndIf
                cIndent := Replicate( Chr(9), nIndent )
                cFormatado += cIndent + AllTrim(cTag) + CRLF
            ElseIf lAutoFecha .or. lCabecalho
                // Tag que abre e fecha sozinha, não altera nível
                cFormatado += cIndent + AllTrim(cTag) + CRLF
            Else
                // Tag de abertura, escreve e aumenta indentação
                cFormatado += cIndent + AllTrim(cTag) + CRLF
                nIndent++
                cIndent := Replicate( Chr(9), nIndent )
            EndIf

        ElseIf !( cChar == Chr(13) .or. cChar == Chr(10) .or. cChar == Chr(9) .or. cChar == " " )
            // Captura conteúdo de texto entre tags (ignorando espaços/quebras soltos)
            cTag := ""
            While nPos <= nLen .and. SubStr(cXML, nPos, 1) != "<"
                cTag += SubStr(cXML, nPos, 1)
                nPos++
            End
            cTag := AllTrim(cChar + cTag)
            If !Empty(cTag)
                cFormatado += cIndent + cTag + CRLF
            EndIf
            Loop // nPos já está no próximo "<", não incrementa

        EndIf

        nPos++
    End

Return cFormatado