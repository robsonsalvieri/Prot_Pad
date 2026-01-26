#Include "Protheus.ch"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FWBROWSE.CH"
#Include "OFIA520.CH"

Static oMdCab
Static oMdGrid


//-------------------------------------------------------------------
/*/{Protheus.doc} OFIA520
	MVC - Atualização da escala dos produtivos

	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Function OFIA520()

	oExecView := FWViewExec():New()
	oExecView:setSource("OFIA520")
	oExecView:setOK({|oModel| OA520005D_Processa(oModel)})
	oExecView:setCancel({|| .T.})
	
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da tela principal
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := Modeldef()
	Local oStrCab  := oMdCab:GetView()
	Local oStrGrid := oMdGrid:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox("BOXCAB", 40)
	oView:CreateHorizontalBox("BOXGRID", 60)

	oStrCab:AddGroup("GRUPO1", "", "", 2)
    oStrCab:SetProperty('*', MVC_VIEW_GROUP_NUMBER, "GRUPO1")
 
	oStrCab:AddGroup( "GRUPO2", STR0001, "", 2) //"Escala"

	oStrCab:SetProperty("ESCALA_01", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )
	oStrCab:SetProperty("ESCALA_02", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )
	oStrCab:SetProperty("ESCALA_03", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )
	oStrCab:SetProperty("ESCALA_04", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )
	oStrCab:SetProperty("ESCALA_05", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )
	oStrCab:SetProperty("ESCALA_06", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )
	oStrCab:SetProperty("ESCALA_07", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )
	oStrCab:SetProperty("ESCALA_08", MVC_VIEW_GROUP_NUMBER, "GRUPO2" )

	oView:AddField("FORM1", oStrCab, "MASTER")
	oView:AddGrid("GRID1", oStrGrid, "PROD")

	oView:SetNoInsertLine("GRID1")
	oView:SetNoDeleteLine("GRID1")

	oView:AddUserButton(STR0002,"",{|| OFIOA380()}) //"Manut. Feriados"

	oView:SetOwnerView("FORM1","BOXCAB")
	oView:SetOwnerView("GRID1","BOXGRID")

	oView:EnableTitleView("GRID1", STR0003) //"Produtivos" 

	oView:SetAfterViewActivate({|oView| OA520009D_Btn_Checkbox(oView)})

	oView:SetCloseOnOk({|| .T.})

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do Modelo
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel
	Local oCab
	Local oGrid

	If oMdCab == NIL
		oMdCab  := OA520001D_GetModel_Cab()
		oMdGrid := OA520002D_GetModel_Grid()	
	Endif

	oCab := oMdCab:GetModel()
	oGrid := oMdGrid:GetModel()

	oModel := MPFormModel():New("OFIA520")
	oModel:SetDescription(STR0004) //"Atualização da escala dos produtivos"

	oModel:AddFields("MASTER",,oCab,,,{|| {}})
	oModel:AddGrid("PROD" , "MASTER", oGrid,,,,, {|| OA520003D_LoadDados_Grid()})

	oModel:getModel("MASTER"):SetDescription(STR0001) //"Escala"
	oModel:getModel("PROD"):SetDescription(STR0003)	//"Produtivos"

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("OFIA520EVDEF", /*cOwner*/, OFIA520EVDEF():New())

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520001D_GetModel_Cab
	Campos do Cabeçalho
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520001D_GetModel_Cab()

	Local oMd1 := OFDMSStruct():New()

	oMd1:AddField({;
		{"cTitulo"     , STR0005        },; //"Filial da Escala"
		{"nTamanho"    , FWSizeFilial() },;
		{"cIdField"    , "FILIAL_ID"    },;
		{"cTipo"       , "C"            },;
		{"lObrigat"    , .F.            },;
		{"cLookUp"     , "SM0_01"       },;
		{'bValid'      , FWBuildFeature(STRUCT_FEATURE_VALID, "OA520011D_ValidFilial()") },;
		{"cTooltip"    , STR0006        } ; //"Informe o código da Filial."
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0007   },; //"Data Inicial" 
		{"nTamanho"    , 8         },;
		{"cIdField"    , "DAT_INI" },;
		{"cTipo"       , "D"       },;
		{"lObrigat"    , .T.       },;
		{"cTooltip"    , STR0008   } ; //"Informe a data inicial da Escala." 
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0009   },; //"Data Final" 
		{"nTamanho"    , 8         },;
		{"cIdField"    , "DAT_FIM" },;
		{"cTipo"       , "D"       },;
		{"lObrigat"    , .T.       },;
		{"cTooltip"    , STR0010   } ; //"Informe a data final da Escala." 
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0011    },;	//"Domingo"
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_01"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0012    } ; //"Informe a Escala de Domingo." 
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0013    },;	//"Segunda-Feira" 
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_02"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0014    } ; //"Informe a Escala de Segunda-Feira." 
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0015    },;	//"Terça-Feira" 
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_03"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0016	} ; //"Informe a Escala de Terça-Feira." 
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0017    },;	//"Quarta-Feira" 
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_04"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0018    } ; //"Informe a Escala de Quarta-Feira." 
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0019    },;	//"Quinta-Feira" 
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_05"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0020    } ; //"Informe a Escala de Quinta-Feira." 
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0021    },; //"Sexta-Feira" 	
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_06"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0022    } ; //"Informe a Escala de Quinta-Feira."
		})
	oMd1:AddField({;
		{"cTitulo"     , STR0023    },;	//"Sabado"
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_07"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0024    } ; //"Informe a Escala de Sabado."  
		})						
	oMd1:AddField({;
		{"cTitulo"     , STR0025    },;	//"Feriados"
		{"nTamanho"    , 6          },;
		{"cIdField"    , "ESCALA_08"},;
		{"cTipo"       , "C"        },;
		{"lObrigat"    , .T.        },;
		{"cLookUp"     , "VOH"      },;
		{"cTooltip"    , STR0026    } ; //"Informe a Escala de Feriados."
		})	

Return oMd1


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520002D_GetModel_Grid
	Campos do Grid
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520002D_GetModel_Grid()

	Local oMd2 := OFDMSStruct():New()

	oMd2:AddField({;
		{"cTitulo"     , ""       },;
		{"nTamanho"    , 1        },;	
		{"cIdField"    , "L_MARK" },;
		{"cTipo"       , "L"      };
		})	
	oMd2:AddField({;
		{"cTitulo"     , STR0027      },; //"Produtivo" 
		{"nTamanho"    , 6            },;
		{"cIdField"    , "VAI_CODTEC" },;
		{"cTipo"       , "C"          },;
		{"lCanChange"  , .F.          };
		})
	oMd2:AddField({;
		{"cTitulo"     , STR0028      },; //"Nome" 
		{"nTamanho"    , 30           },;
		{"cIdField"    , "VAI_NOMTEC" },;
		{"cTipo"       , "C"          },;
		{"lCanChange"  , .F.          };
		})
	oMd2:AddField({;
		{"cTitulo"     , STR0029        },; //"Filial Produtivo"
		{"nTamanho"    , FWSizeFilial() },;
		{"cIdField"    , "FIL_PROD"     },;
		{"cTipo"       , "C"            },;
		{"lCanChange"  , .F.            };
		})	
	oMd2:AddField({;
		{"cTitulo"     , STR0030   },; //"Data Ultima Escala"
		{"nTamanho"    , 8         },;
		{"cIdField"    , "ULT_ESC" },;
		{"cTipo"       , "D"       },; 
		{"lCanChange"  , .F.       };
		})
	oMd2:AddField({;
		{"cTitulo"     , STR0031   },; //"Periodo Ultima Escala"
		{"nTamanho"    , 6         },;
		{"cIdField"    , "COD_PER" },;
		{"cTipo"       , "C"       },; 
		{"lCanChange"  , .F.       };
		})			

Return oMd2


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520003D_LoadDados_Grid
	Carrega os produtivos para preenchimento do Grid
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520003D_LoadDados_Grid()

	Local aRet    := {}
	Local aAux    := NIL
	Local cQuery  := " "
	Local cQAlSQL := "ALPROD"
	
	cQuery += "SELECT VAI.VAI_CODTEC, VAI.VAI_NOMTEC, VAI.VAI_FILPRO, "
	cQuery += "COALESCE(( SELECT MAX(VOE.VOE_DATESC)"
	cQuery += "				FROM " + RetSQLName("VOE") + " VOE"
	cQuery += "			   WHERE VOE.VOE_FILIAL = '" + xFilial('VOE') + "'"
	cQuery += "				 AND VOE.VOE_CODPRO = VAI.VAI_CODTEC"
	cQuery += "				 AND VOE.D_E_L_E_T_ = ' '"
	cQuery += "			), '') AS ULT_ESC, "
	cQuery += "COALESCE(( SELECT TOP 1 VOE.VOE_CODPER"
	cQuery += "		        FROM " + RetSQLName("VOE") + " VOE"
	cQuery += "			   WHERE VOE.VOE_FILIAL = '" + xFilial('VOE') + "'"
	cQuery += "			     AND VOE.VOE_CODPRO = VAI.VAI_CODTEC"
	cQuery += "				 AND VOE.D_E_L_E_T_ = ' '"
	cQuery += "			   ORDER BY VOE.VOE_DATESC DESC"
	cQuery += "			), '') AS CODPER"
	cQuery += "  FROM " + RetSQLName("VAI") + " VAI"
	cQuery += " WHERE VAI.VAI_FILIAL = '" + xFilial("VAI") + "'"
	cQuery += "   AND VAI.VAI_FUNPRO = '1' "
	cQuery += "   AND (VAI.VAI_DATDEM = ' ' OR VAI.VAI_DATDEM > '" + dTos(dDataBase + 1) + "')"
	cQuery += "   AND VAI.D_E_L_E_T_ = ' '"

	dbUseArea(.T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T.)

	While !(cQAlSQL)->(Eof())

		aAux    := Array(6)
		aAux[1] := .F.
		aAux[2] := (cQAlSQL)->VAI_CODTEC
		aAux[3] := (cQAlSQL)->VAI_NOMTEC
		aAux[4] := (cQAlSQL)->VAI_FILPRO
		aAux[5] := sTod((cQAlSQL)->ULT_ESC)
		aAux[6] := (cQAlSQL)->CODPER

		aadd(aRet, {0, aClone(aAux)})

		(cQAlSQL)->(DbSkip())
	EndDo
	(cQAlSQL)->(DbCloseArea())

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520004D_Valida_Escala
	Validação da Escala
	
	@type Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Function OA520004D_Valida_Escala(cEscala)

	Local lRet := .T.
	Local lVOH_MSBLQL := VOH->(FieldPos("VOH_MSBLQL")) > 0

	If !Empty(cEscala)
		DbSelectArea("VOH")
		DbSetOrder(1)
		If !DbSeek( xFilial("VOH") + cEscala )
			Help("", 1, STR0040, , STR0032, 1, 0) //"Período de Escala não Cadastrado."
			lRet := .F.
		Else
			// Período Bloqueado
			If lVOH_MSBLQL
				If OFA0800016_PeriodoBloqueado(cEscala)
					lRet := .F. // A mensagem já é exibida dentro da função OFA0800016_PeriodoBloqueado()
				Endif
			Endif
		Endif
	Endif

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520005D_Processa
	Processa os registros selecionados
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520005D_Processa(oModel)

	Local oCab     := oModel:GetModel("MASTER")
	Local oGrid    := oModel:GetModel("PROD")
    Local nI       := 0
	Local dDataIni
	Local dDataFim 

    For nI := 1 To oGrid:Length()
		dDataIni := oCab:GetValue("DAT_INI")
		dDataFim := oCab:GetValue("DAT_FIM")

        oGrid:GoLine(nI)
        If oGrid:GetValue("L_MARK")
			If oGrid:GetValue("ULT_ESC") >= oCab:GetValue("DAT_INI")
				dDataIni := oGrid:GetValue("ULT_ESC") + 1
            Endif
			DbSelectArea("VAI")
			DbSetOrder(1)
			DbSeek(xFilial("VAI") + oGrid:GetValue("VAI_CODTEC"))
			If !Empty(VAI->VAI_DATDEM)
				dDataFim := VAI->VAI_DATDEM - 1
			Endif
			If dDataFim >= dDataIni	
				OA520006D_Gravar(dDataIni, dDataFim, VAI->VAI_CODTEC, oGrid:GetValue("COD_PER"), oModel)
			Endif
        Endif
    Next nI

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520006D_Gravar
	Gravação dos Dados
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520006D_Gravar(dDataIni, dDataFim, cProd, cPerVOE, oModel)

	Local nDias     := 0
	Local nDia      := 0 
	Local nI        := 0
	Local cCPer     := ""
	Local cEscAux   := ""
	Local aFeriados := {}
	Local oModelVOE := FWLoadModel("OFIA521")
	Local lGrava    := .F.
	Local cPerAux   := cPerVOE

	// Montagem dos Feriados
	aFeriados := OA520007D_Montagem_Feriados(oModel)
	nDias     := ((dDataFim - dDataIni) + 1)

	For nI := 1 to nDias
		lGrava  := .F.
		cEscAux := ""

		If OA520008D_Verifica_Feriados(aFeriados, dDataIni + (nI - 1)) // Feriados
			cEscAux := oModel:GetValue("MASTER", "ESCALA_08")
			If !Empty(cEscAux)
				lGrava := .T.
				cCPer := cEscAux
			Endif
		Else // Dia Normal
			nDia := Dow(dDataIni + (nI - 1))
			Do Case
				Case nDia == 1 // Domingo
					cEscAux := oModel:GetValue("MASTER", "ESCALA_01")
					If !Empty(cEscAux)
						lGrava := .T.
						cCPer := cEscAux
					Endif	
				Case nDia == 2 // Segunda-Feira
					cEscAux := oModel:GetValue("MASTER", "ESCALA_02")
					If !Empty(cEscAux)
						lGrava := .T.
						cCPer := cEscAux
					Endif		
				Case nDia == 3 // Terca-Feira
					cEscAux := oModel:GetValue("MASTER", "ESCALA_03")
					If !Empty(cEscAux)
						lGrava := .T.
						cCPer := cEscAux
					Endif		
				Case nDia == 4 // Quarta-Feira
					cEscAux := oModel:GetValue("MASTER", "ESCALA_04")
					If !Empty(cEscAux)
						lGrava := .T.
						cCPer := cEscAux
					Endif	
				Case nDia == 5 // Quinta-Feira
					cEscAux := oModel:GetValue("MASTER", "ESCALA_05")
					If !Empty(cEscAux)
						lGrava := .T.
						cCPer := cEscAux
					Endif		
				Case nDia == 6 // Sexta-Feira
					cEscAux := oModel:GetValue("MASTER", "ESCALA_06")
					If !Empty(cEscAux)
						lGrava := .T.
						cCPer := cEscAux
					Endif		
				Case nDia == 7 // Sabado
					cEscAux := oModel:GetValue("MASTER", "ESCALA_07")
					If !Empty(cEscAux)
						lGrava := .T.
						cCPer := cEscAux
					Endif		
			EndCase
		Endif
		If lGrava .and. (cPerAux != cCPer)

			oModelVOE:SetOperation(MODEL_OPERATION_INSERT)

			If oModelVOE:Activate()

				oModelVOE:SetValue("VOEMASTER", "VOE_FILIAL", xFilial("VOE"))
				oModelVOE:SetValue("VOEMASTER", "VOE_CODPRO", cProd)
				oModelVOE:SetValue("VOEMASTER", "VOE_DATESC", dDataIni + (nI - 1))
				oModelVOE:SetValue("VOEMASTER", "VOE_CODPER", cCPer)
				oModelVOE:SetValue("VOEMASTER", "VOE_FILPRO", oModel:GetValue("MASTER", "FILIAL_ID"))

				If oModelVOE:VldData()
					oModelVOE:CommitData()
					cPerAux := cCper
				Endif

				oModelVOE:DeActivate()
			Endif
		Endif
	Next nI

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520007D_Montagem_Feriados
	Montagem do Array de Feriados
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520007D_Montagem_Feriados(oModel)

	Local cSql      := ""
	Local cAliasSX5 := "TSX5"
	Local aRet      := {}
	Local cFil      := oModel:GetValue("MASTER", "FILIAL_ID")
	Local dDtIn     := oModel:GetValue("MASTER", "DAT_INI")
	Local dDtFi     := oModel:GetValue("MASTER", "DAT_FIM")

	If Empty(cFil)
		cFil := VAI->VAI_FILPROD
	Endif

	cSQL := "SELECT X5_DESCRI "
	cSQL += "FROM " + RetSQLName("SX5") + " "
	cSQL += "WHERE X5_FILIAL IN('" + xFilial("SX5") + "', '" + cFil + "') "
	cSQL += "  AND X5_TABELA = '63' "
	cSQL += "  AND D_E_L_E_T_ = ' '"

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), cAliasSX5, .T., .T.)

	While !(cAliasSX5)->(Eof())
		If Empty(Alltrim(Substr((cAliasSX5)->(X5_DESCRI), 7, 2))) .Or.;
			((Substr((cAliasSX5)->(X5_DESCRI), 7, 2) >= StrZero(Val(Right(Dtoc(dDtIn), 2)), 2)) .And. (Substr((cAliasSX5)->(X5_DESCRI), 7, 2) <= StrZero(Val(Right(Dtoc(dDtFi), 2)), 2)))
				aAdd(aRet, Alltrim(Left((cAliasSX5)->(X5_DESCRI), 8)))
		Endif
		(cAliasSX5)->(dbSkip())
	EndDo
	(cAliasSX5)->(dbCloseArea())
	DbSelectArea("SX5")

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520008D_Verifica_Feriados
	Verificação dos Feriados
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520008D_Verifica_Feriados(aFeriados, dDataVer)

	Local lRet := .f.

	If AScan(aFeriados, { |x| x == StrZero(Day(dDataVer), 2) + "/" + StrZero(Month(dDataVer), 2);
		.Or. x == StrZero(Day(dDataVer), 2) + "/" + StrZero(Month(dDataVer), 2) + "/" + StrZero(Val(Right(Dtoc(dDataVer), 2)), 2) }) > 0
		lRet := .t.
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520009D_Btn_Checkbox
	Criando o Botão para Marcar/Desmarcar
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520009D_Btn_Checkbox(oView)

	Local oBrow := Nil

	oBrow := oView:GetViewObj("PROD")[3]
	
	oBrow:oBrowse:aColumns[1]:SetHeaderImage("")
	oBrow:oBrowse:aColumns[1]:SetHeaderClick({|| OA520010D_Marca_Desmarca()})

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520010D_Marca_Desmarca
	Criando o Botão para Marcar/Desmarcar
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Static Function OA520010D_Marca_Desmarca()

    Local oModel  := FwModelActive()
    Local oView   := FwViewActive()
    Local oGrid   := oModel:GetModel("PROD") 
    Local nI      := 0
    Local lMarked := .T.

    // Verifica se todos já estão marcados
    For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
        If !oGrid:GetValue("L_MARK", nI) 
            lMarked:= .F.
            Exit
        Endif
    Next

    // Marca ou desmarca todos
    For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
        oGrid:SetValue("L_MARK", !lMarked)
    Next

	oGrid:GoLine(1)
    oView:Refresh("PROD")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} OA520011D_ValidFilial
	Validação do campo de Filial
	
	@type Static Function
	@author Francisco Carvalho	
	@since 18/08/2025
/*/
//-------------------------------------------------------------------
Function OA520011D_ValidFilial()
Return (Vazio() .or. ExistCpo("SM0", cEmpAnt + FWFldGet('FILIAL_ID',,,.T.)))