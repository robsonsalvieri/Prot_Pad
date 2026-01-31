#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA460.CH"

CLASS OFIA460EVDEF FROM FWModelEvent

	DATA lEfetEnt // Efetivar Entrada ?

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD FieldPreVld()
	METHOD ModelPosVld()
	METHOD VldActivate()
	METHOD GridLinePreVld()
	METHOD AfterTTS()
	METHOD DeActivate()

ENDCLASS


// New //
METHOD New() CLASS OFIA460EVDEF
	::lEfetEnt := .f. // NAO Efetivar Entrada
RETURN .T.


// Abertura TELA //
METHOD Activate(oModel, lCopy) CLASS OFIA460EVDEF
	::lEfetEnt := .f. // NAO Efetivar Entrada
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE // Alteração
		oModel:SetValue( "VRPMASTER", "VRP_CODIGO", VRP->VRP_CODIGO ) // Necessario para possibilitar dar OK sem precisar alterar os dados na Alteração
	EndIf
RETURN .T.


// Campos Cabeçalho VRP //
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA460EVDEF
Local lRet    := .t.
Local cQuery  := ""
Local cNroNFI := ""
Local cSerNFI := ""
Local cCodFor := ""
Local cLojFor := ""
If cModelId == "VRPMASTER"
	If cAction == "SETVALUE" // Valid do campo
		Do Case
			Case cId $ "VRP_NUMNFI/VRP_SERNFI/VRP_CODFOR/VRP_LOJFOR/"
				If !Empty(xValue)
					cNroNFI := IIf( cId == "VRP_NUMNFI" .and. xValue <> NIL , xValue , oSubModel:GetValue( "VRP_NUMNFI" ))
					cSerNFI := IIf( cId == "VRP_SERNFI" .and. xValue <> NIL , xValue , oSubModel:GetValue( "VRP_SERNFI" ))
					cCodFor := IIf( cId == "VRP_CODFOR" .and. xValue <> NIL , xValue , oSubModel:GetValue( "VRP_CODFOR" ))
					cLojFor := IIf( cId == "VRP_LOJFOR" .and. xValue <> NIL , xValue , oSubModel:GetValue( "VRP_LOJFOR" ))
					If cId $ "VRP_CODFOR/VRP_LOJFOR/"
						oSubModel:LoadValue( "VRP_NOMFOR" , "" )
						SA2->(DbSetOrder(1))
						If SA2->(DbSeek(xFilial("SA2")+cCodFor+IIf(!Empty(cLojFor),cLojFor,"")))
							oSubModel:LoadValue( "VRP_NOMFOR" , padr(SA2->A2_NOME,GeTSX3Cache("VRP_NOMFOR","X3_TAMANHO")) )
						Else
							Help("",1,"FIELDPREVLD "+cId,,STR0040,1,0) // Fornecedor não existente!
							lRet := .f.
						EndIf
					EndIf
					If lRet
						cNroNFI := STRTRAN(cNroNFI,"'"," ")
						cSerNFI := STRTRAN(cSerNFI,"'"," ")
						cQuery := "SELECT R_E_C_N_O_"
						cQuery += "  FROM " + RetSqlName("VRP")
						cQuery += " WHERE VRP_FILIAL='"+xFilial("VRP")+"'"
						cQuery += "   AND VRP_NUMNFI='"+cNroNFI+"'"
						cQuery += "   AND VRP_SERNFI='"+cSerNFI+"'"
						cQuery += "   AND VRP_CODFOR='"+cCodFor+"'"
						cQuery += "   AND VRP_LOJFOR='"+cLojFor+"'"
						If oSubModel:GetOperation() == MODEL_OPERATION_UPDATE // Alteração
							cQuery += " AND R_E_C_N_O_ <> "+Alltrim(str(VRP->(RecNo())))
						EndIf
						cQuery += "   AND VRP_STATUS <> '2'"
						cQuery += "   AND D_E_L_E_T_= ' '"
						If FM_SQL(cQuery) > 0
							Help("",1,"FIELDPREVLD "+cId,,STR0041,1,0) // Nota Fiscal já existente para este Fornecedor.
							lRet := .f.
						EndIf
					EndIf
				EndIf

			Case cId == "VRP_FORPAG"
				If !Empty(xValue)
					oSubModel:LoadValue( "VRP_DESFPG" , "" )
					DbSelectArea("SE4")
					DbSetOrder(1)
					If DbSeek(xFilial("SE4")+xValue)
						oSubModel:LoadValue( "VRP_DESFPG" , padr(SE4->E4_DESCRI,GeTSX3Cache("VRP_DESFPG","X3_TAMANHO")) )
						If SE4->E4_TIPO $ "A.9"
							Help("",1,"FIELDPREVLD VRP_FORPAG",,STR0042,1,0) // Impossível selecionar uma Forma de Pagamento do tipo Negociada! Altere para uma Forma de Pagamento padrão.
							lRet := .f.
						EndIf
					Else
						Help("",1,"FIELDPREVLD VRP_FORPAG",,STR0043,1,0) // Forma de Pagamento não existente!
						lRet := .f.
					EndIf
				EndIf

		EndCase
	EndIf
EndIf
RETURN lRet


// Campos Itens VRQ //
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA460EVDEF
Local lRet    := .t.
Local cFilSD2 := ""
Local cFilMov := ""
Local cTESInt := ""
Local nVlrTot := 0
Local oModel  := FWModelActive()
If cModelId == "VRQDETAIL"
	If cAction == "CANSETVALUE" // Pode Alterar?
		If cId == "VRQ_QTDSER"
			If !Empty(oSubModel:GetValue( "VRQ_CODVRS" ))
				lRet := .f. // Não deixa alterar a Quantidade, quando é necessario relacionar com Saida
			EndIf
		EndIf
	ElseIf cAction == "SETVALUE" // Valid do campo
		Do Case
			Case cId == "VRQ_SERINT"
				oSubModel:LoadValue( "VRQ_GRUSER" , '' )
				oSubModel:LoadValue( "VRQ_CODSER" , '' )
				oSubModel:LoadValue( "VRQ_DESSER" , '' )
				oSubModel:LoadValue( "VRQ_TIPSER" , '' )
				oSubModel:LoadValue( "VRQ_CODTES" , space(GeTSX3Cache("VRQ_CODTES","X3_TAMANHO")) )
				oSubModel:LoadValue( "VRQ_QTDSER" ,  0 )
				oSubModel:LoadValue( "VRQ_VLRUNI" ,  0 )
				oSubModel:LoadValue( "VRQ_VLRTOT" ,  0 )
				oSubModel:LoadValue( "VRQ_FILVRS" , '' )
				oSubModel:LoadValue( "VRQ_CODVRS" , '' )
				If !Empty( xValue )
					DbSelectArea("VPX")
					DbSetOrder(1)
					If DbSeek( xFilial("VPX") + xValue )
						DbSelectArea("VPV")
						DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
						DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
						cFilSD2 := xFilial("SD2")
						cFilMov := IIf(!Empty(VPV->VPV_FILCEN),VPV->VPV_FILCEN,cFilSD2) // Filial Centralizadora
						If cFilMov <> cFilSD2
							Help("",1,"GRIDLINEPREVLD VRQ_SERINT",,STR0044,1,0) // Este Serviço Especializado possui uma Filial Centralizadora de Estoque diferente da Filial logada! Impossível continuar.
							lRet := .f.
						Else
							If VPV->VPV_CTRSLD == "1" // Tipo de Serviço Especializado controla SALDO de ESTOQUE UNITARIO
								DbSelectArea("VPY")
								DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
								If DbSeek( xFilial("VPY") + VPX->VPX_SERINT + cFilMov ) .and. VPY->VPY_QTDEST > 0 // Já possui Estoque
									Help("",1,"GRIDLINEPREVLD VRQ_SERINT",,STR0045,1,0) // Este Serviço Especializado controla Saldo Unitário e já possui em Estoque! Impossível continuar.
									lRet := .f.
								EndIf
							EndIf
							If lRet
								DbSelectArea("SB1")
								DbSetOrder(1) // B1_FILIAL + B1_COD
								DbSeek( xFilial("SB1") + VPV->VPV_CODSB1 )
								oSubModel:LoadValue( "VRQ_GRUSER" , VPX->VPX_GRUSER )
								oSubModel:LoadValue( "VRQ_CODSER" , VPX->VPX_CODSER )
								oSubModel:LoadValue( "VRQ_DESSER" , padr(VPX->VPX_DESSER,GeTSX3Cache("VRQ_DESSER","X3_TAMANHO")) )
								oSubModel:LoadValue( "VRQ_TIPSER" , VPX->VPX_TIPSER )
								oSubModel:LoadValue( "VRQ_CODTES" , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TE") )
								If VPV->VPV_RELSAI == "1"
									oSubModel:LoadValue( "VRQ_CODVRS" , '<F7>' ) // Necessario relacionar a Entrada com a Saida
								EndIf
							EndIf
						EndIf
					Else
						Help("",1,"GRIDLINEPREVLD VRQ_SERINT",,STR0046,1,0) // Serviço Especializado não encontrado! Impossível continuar.
						lRet := .f.
					EndIf
				EndIf
			Case cId $ "VRQ_QTDSER/VRQ_VLRUNI/"
				If cId == "VRQ_QTDSER"
					nVlrTot := ( xValue * oSubModel:GetValue( "VRQ_VLRUNI" ) )
				Else // cId == "VRQ_VLRUNI"
					nVlrTot := ( oSubModel:GetValue( "VRQ_QTDSER" ) * xValue )
				EndIf
				oSubModel:LoadValue( "VRQ_VLRTOT" , nVlrTot )
			Case cId == "VRQ_TIPOPE"
				If !Empty(xValue)
					DbSelectArea("SX5")
					DbSetOrder(1)
					If DbSeek( xFilial("SX5") + "DJ" + xValue )
						DbSelectArea("VPX")
						DbSetOrder(1)
						DbSeek( xFilial("VPX") + oSubModel:GetValue( "VRQ_SERINT" ) )
						DbSelectArea("VPV")
						DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
						DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
						DbSelectArea("SB1")
						DbSetOrder(1) // B1_FILIAL + B1_COD
						DbSeek( xFilial("SB1") + VPV->VPV_CODSB1 )
						cTESInt := MaTesInt( 1 , xValue , oModel:GetValue( "VRPMASTER" , "VRP_CODFOR" ) , oModel:GetValue( "VRPMASTER" , "VRP_LOJFOR" ) , "F" , SB1->B1_COD )
						lRet := oSubModel:SetValue( "VRQ_CODTES" , cTESInt )
					Else
						Help("",1,"GRIDLINEPREVLD VRQ_TIPOPE",,STR0047,1,0) // Tipo de Operação não existente!
						lRet := .f.
					EndIf
				EndIf
			Case cId == "VRQ_CODTES"
				If !Empty(xValue)
					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek( xFilial("SF4") + xValue )
						If SF4->F4_ESTOQUE # "N" // Necessário ser TES que NAO movimenta Estoque
							Help("",1,"GRIDLINEPREVLD VRQ_CODTES",,STR0048,1,0) // Utilize um TES de Entrada que NÃO movimenta Estoque!
							lRet := .f.
						Else
						 	If SF4->F4_TIPO # "E" // Necessário ser TES de Entrada
								Help("",1,"GRIDLINEPREVLD VRQ_CODTES",,STR0049,1,0) // Utilize um TES de Entrada!
								lRet := .f.
							EndIf
						EndIf
					Else
						Help("",1,"GRIDLINEPREVLD VRQ_CODTES",,STR0050,1,0) // TES inválido! Impossível continuar.
						lRet := .f.
					EndIf
				EndIf
				If lRet
					oSubModel:LoadValue( "VRQ_TIPOPE" , space(GeTSX3Cache("VRQ_TIPOPE","X3_TAMANHO")) )
				EndIf
		EndCase
	EndIf
EndIf
RETURN lRet


// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS OFIA460EVDEF
	Local lRet       := .t.
	Local nOperModel := oModel:GetOperation()
	Local cMsgAvi    := ""
	Local nOpcAvi    := 0
	Local nQtdEst    := 0
	Local nQtdSrv    := 0
	Local cSrvAux    := ""
	Local cFilMov    := ""
	Local cQuery     := ""
	Local oVRQMod    := oModel:GetModel("VRQDETAIL")
	Local nCntFor    := 0
	Local nLinItem   := 0
	Local nPosRateio := 0
	Local nPosItem   := 0
	Local cLinItem   := ""
	Local cNroNFI    := oModel:GetValue("VRPMASTER","VRP_NUMNFI")
	Local cSerNFI    := oModel:GetValue("VRPMASTER","VRP_SERNFI")
	Local cCodFor    := oModel:GetValue("VRPMASTER","VRP_CODFOR")
	Local cLojFor    := oModel:GetValue("VRPMASTER","VRP_LOJFOR")
	Local cNomFor    := oModel:GetValue("VRPMASTER","VRP_NOMFOR")
	Local aSaidas    := {}
	Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
	//
	::lEfetEnt := .f. // NAO Efetivar Entrada
	//
	If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
		If nOperModel == MODEL_OPERATION_UPDATE // Alteração
			lRet := ::VldActivate(oModel, cId)
		EndIf
		If lRet
			cNroNFI := STRTRAN(cNroNFI,"'"," ")
			cSerNFI := STRTRAN(cSerNFI,"'"," ")
			cQuery := "SELECT R_E_C_N_O_"
			cQuery += "  FROM " + RetSqlName("VRP")
			cQuery += " WHERE VRP_FILIAL='"+xFilial("VRP")+"'"
			cQuery += "   AND VRP_NUMNFI='"+cNroNFI+"'"
			cQuery += "   AND VRP_SERNFI='"+cSerNFI+"'"
			cQuery += "   AND VRP_CODFOR='"+cCodFor+"'"
			cQuery += "   AND VRP_LOJFOR='"+cLojFor+"'"
			If nOperModel == MODEL_OPERATION_UPDATE // Alteração
				cQuery += " AND R_E_C_N_O_ <> "+Alltrim(str(VRP->(RecNo())))
			EndIf
			cQuery += "   AND VRP_STATUS <> '2'"
			cQuery += "   AND D_E_L_E_T_= ' '"
			If FM_SQL(cQuery) > 0
				Help("",1,"MODELPOSVLD",,STR0051,1,0) // Nota Fiscal já existente para este Fornecedor. Impossível continuar.
				lRet := .f.
			Else
				lRet := .f.
				For nCntFor := 1 to oVRQMod:Length()
					oVRQMod:GoLine(nCntFor)
					If !oVRQMod:IsDeleted() // Se NAO estiver DELETADA a linha, soma na variavel
						nLinItem++
					EndIf
					nPosRateio := aScan(aColsRATCC, {|x| x[1] == strzero(nCntFor,GeTSX3Cache("DE_ITEMNF","X3_TAMANHO")) })
					If nPosRateio > 0 
						If oVRQMod:IsDeleted() .or. len(aColsRATCC[nPosRateio,2]) == 0 // Se tiver DELETADA ou não tem Rateio, excluir linha do vetor do Rateio
							aDel(aColsRATCC,nPosRateio)
							aSize(aColsRATCC,Len(aColsRATCC)-1)
						Else
							cLinItem := strzero(nLinItem,GeTSX3Cache("DE_ITEMNF","X3_TAMANHO"))
							nPosItem := aScan(aColsRATCC[nPosRateio,2,1], {|x| x[1] == 'DE_ITEMNF' })
							aColsRATCC[nPosRateio,1] := cLinItem
							aColsRATCC[nPosRateio,2,1,nPosItem,2] := cLinItem
						EndIf
					EndIf

					If !oVRQMod:IsDeleted()
						lRet := .t.
						nQtdSrv++
						DbSelectArea("VPX")
						DbSetOrder(1) // VPX_FILIAL + VPX_SERINT
						If DbSeek( xFilial("VPX") + oVRQMod:GetValue("VRQ_SERINT") )
							cSrvAux := CHR(13)+CHR(10)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_GRUSER)+" "+Alltrim(VPX->VPX_CODSER)+CHR(13)+CHR(10)+Alltrim(VPX->VPX_DESSER)+" ("+Alltrim(VPX->VPX_TIPSER)+")"
							If oVRQMod:GetValue("VRQ_CODVRS") == "<F7>" .or. cDebugMIL == "OFIA460001" // Falta relacionar a Saida com a Entrada
								Help("",1,"MODELPOSVLD",,STR0052+cSrvAux,1,0) // Tipo de Serviço com necessidade de relacionar a Entrada com a Saida. Impossivel Continuar.
								lRet := .f.
								nQtdSrv := -1 // -1 para não apresentar outro Help abaixo
								Exit
							ElseIf !Empty(oVRQMod:GetValue("VRQ_CODVRS"))
								If aScan( aSaidas , { |x| x[1]+x[2] == oVRQMod:GetValue("VRQ_FILVRS")+oVRQMod:GetValue("VRQ_CODVRS") }) > 0 // ja existe relacionamento
									Help("",1,"MODELPOSVLD",,STR0053+cSrvAux,1,0) // Duplicidade de relacionamento com a Saida. Impossivel continuar.
									lRet := .f.
									nQtdSrv := -1 // -1 para não apresentar outro Help abaixo
									Exit
								Else
									aadd(aSaidas,{ oVRQMod:GetValue("VRQ_FILVRS") , oVRQMod:GetValue("VRQ_CODVRS") }) // adiciona relacionamento
									cQuery := " SELECT VRQ.R_E_C_N_O_ "
									cQuery += "   FROM " + RetSqlName("VRQ") + " VRQ "
									cQuery += "   JOIN " + RetSqlName("VRP") + " VRP ON VRP.VRP_FILIAL=VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO=VRQ.VRQ_CODVRP AND VRP.VRP_STATUS<>'2' AND VRP.D_E_L_E_T_=' ' "
									cQuery += "  WHERE VRQ.VRQ_FILVRS = '"+oVRQMod:GetValue("VRQ_FILVRS")+"' "
									cQuery += "    AND VRQ.VRQ_CODVRS = '"+oVRQMod:GetValue("VRQ_CODVRS")+"'"
									If nOperModel == MODEL_OPERATION_UPDATE // Alteração
										cQuery += "  AND ( VRQ.VRQ_FILIAL <> '"+VRP->VRP_FILIAL+"' OR VRQ.VRQ_CODVRP <> '"+VRP->VRP_CODIGO+"' )"
									EndIf
									cQuery += "    AND VRQ.D_E_L_E_T_ = ' '"
									If FM_SQL(cQuery) > 0
										Help("",1,"MODELPOSVLD",,STR0054+cSrvAux,1,0) // Outra Entrada com o mesmo relacionamento com a Saida. Impossivel continuar.
										lRet := .f.
										nQtdSrv := -1 // -1 para não apresentar outro Help abaixo
										Exit
									EndIf
								EndIf
							EndIf
							// Cadastro de Tipos de Servicos Especializados
							DbSelectArea("VPV")
							DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
							DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
							If VPV->VPV_CTRSLD == "1" // Controla SALDO de ESTOQUE: UNITARIO
								cFilMov := xFilial("SD2") // Filial da Movimentação
								// Estoque do Servico Especializado
								DbSelectArea("VPY")
								DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
								If DbSeek( xFilial("VPY") + oVRQMod:GetValue("VRQ_SERINT") + cFilMov )
									nQtdEst  := VPY->VPY_QTDEST
								EndIf
								If !OA4520011_ValidaSaldo( "0" , VPV->VPV_CTRSLD , oVRQMod:GetValue("VRQ_QTDSER") , nQtdEst , cSrvAux )
									lRet := .f.
									nQtdSrv := -1 // -1 para não apresentar outro Help abaixo, Help correto aprensentado na funcao OA4520011_ValidaSaldo
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
				Next
				If nQtdSrv == 0 .or. cDebugMIL == "OFIA460002"
					Help("",1,"MODELPOSVLD",,STR0055,1,0) // Nenhum Serviço informado. Impossível continuar.
				EndIf
			EndIf
			If lRet
				cMsgAvi += CHR(13)+CHR(10)
				cMsgAvi += STR0025+": "+cNroNFI+"-"+cSerNFI+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Nota Fiscal
				cMsgAvi += STR0056+": "+cCodFor+"-"+cLojFor+" "+cNomFor // Fornecedor
				nOpcAvi := Aviso(STR0001,cMsgAvi,{STR0057,STR0058},3) // Entrada de Serviços Especializados / Efetivar Entrada / Salvar Digitação
				If nOpcAvi == 1 // Efetivar Entrada
					::lEfetEnt := .t. // Efetivar Entrada
				EndIf
			EndIf
		EndIf
	EndIf
RETURN lRet


// Validação antes da Abertura da Tela //
METHOD VldActivate(oModel, cModelId) CLASS OFIA460EVDEF
	Local lRet := .T.
	Local nOperModel := oModel:GetOperation()
	If nOperModel == MODEL_OPERATION_UPDATE
		If VRP->VRP_STATUS == "1" // 1=Entrada Efetivada
			Help("",1,"VLDACTIVATE",,STR0059,1,0) // Entrada já Efetivada. Impossível alterar.
			lRet := .f.
		ElseIf VRP->VRP_STATUS == "2" // 2=Entrada Cancelada
			Help("",1,"VLDACTIVATE",,STR0060,1,0) // Entrada já Cancelada. Impossível alterar.
			lRet := .f.
		EndIf
	EndIf
	//
	SetKey(VK_F4,{|| OA4600051_VerEstoque() })
	If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
		SetKey(VK_F7,{|| OA4600071_RelacionaSaida() })
	EndIf
	//
RETURN lRet


// Chamado apos a Gravação padrão //
METHOD AfterTTS(oModel, cModelId) CLASS OFIA460EVDEF
Local lRet    := .t.
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	If ::lEfetEnt // Efetivar Entrada
		oProcEntr := MsNewProcess():New({ |lEnd| lRet := OA4600021_IncluirEntrada( ::lEfetEnt ) }," ","",.f.)
		oProcEntr:Activate()
		::lEfetEnt := .f. // Volta para NAO Efetivar Entrada
	EndIf
EndIf
RETURN lRet


// Fechar Tela
METHOD DeActivate(oModel) CLASS OFIA460EVDEF
	Local nOperModel := oModel:GetOperation()
	SetKey(VK_F4, Nil )
	If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
		SetKey(VK_F7, Nil )
	EndIf
	aColsRATCC := {} // Limpar vetor de Rateio - variavel Private
RETURN .T.