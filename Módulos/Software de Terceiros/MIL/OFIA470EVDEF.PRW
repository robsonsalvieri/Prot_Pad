#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA470.CH"

CLASS OFIA470EVDEF FROM FWModelEvent

	DATA lGeraNF // Gera NF ?
	DATA lEstoq  // Atualiza Estoque ?
	DATA cNroNFI // Numero da NF
	DATA cSerNFI // Serie da NF

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
METHOD New() CLASS OFIA470EVDEF
	::lGeraNF := .f. // NAO gerar NF
	::lEstoq  := .f. // NAO atualizar Estoque
	::cNroNFI := ""  // Numero da NF
	::cSerNFI := ""  // Serie da NF
RETURN .T.


// Abertura TELA //
METHOD Activate(oModel, lCopy) CLASS OFIA470EVDEF
	Local nOpcMod := oModel:GetOperation()
	Local oVRRMod := oModel:GetModel("VRRMASTER")
	Local oVRSMod := oModel:GetModel("VRSDETAIL")
	Local oVS9Mod := oModel:GetModel("VS9DETAIL")
	Local cCondic := ""
	//
	::lGeraNF := .f. // NAO gerar NF
	::lEstoq  := .f. // NAO atualizar Estoque
	::cNroNFI := ""  // Numero da NF
	::cSerNFI := ""  // Serie da NF
	//
	If nOpcMod == MODEL_OPERATION_INSERT .or. nOpcMod == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
		oVRSMod:SetNoInsertLine(.F.) // Deixa INCLUIR as linhas do VRS
		oVRSMod:SetNoUpdateLine(.F.) // Deixa ALTERAR as linhas do VRS
		oVRSMod:SetNoDeleteLine(.F.) // Deixa DELETAR as linhas do VRS
		oVS9Mod:SetNoInsertLine(.F.) // Deixa INCLUIR as linhas do VS9
		oVS9Mod:SetNoUpdateLine(.F.) // Deixa ALTERAR as linhas do VS9
		oVS9Mod:SetNoDeleteLine(.F.) // Deixa DELETAR as linhas do VS9
	EndIf
	//
	If nOpcMod == MODEL_OPERATION_UPDATE // Alteração
		oVRRMod:SetValue( "VRR_CODIGO", VRR->VRR_CODIGO ) // Necessario para possibilitar dar OK sem precisar alterar os dados na Alteração
		If oVRRMod:GetValue( "VRR_STATUS" ) == "4" // Status: Liberado para Efetivar Saida
			oVRSMod:SetNoInsertLine(.T.) // Nao deixa INCLUIR as linhas do VRS
			oVRSMod:SetNoUpdateLine(.T.) // Nao deixa ALTERAR as linhas do VRS
			oVRSMod:SetNoDeleteLine(.T.) // Nao deixa DELETAR as linhas do VRS
			oVS9Mod:SetNoInsertLine(.T.) // Nao deixa INCLUIR as linhas do VS9
			oVS9Mod:SetNoUpdateLine(.T.) // Nao deixa ALTERAR as linhas do VS9
			oVS9Mod:SetNoDeleteLine(.T.) // Nao deixa DELETAR as linhas do VS9
		ElseIf oVRRMod:GetValue( "VRR_STATUS" ) == "5" // Status: Liberação de Pendências Reprovada
			oVRRMod:SetValue( "VRR_STATUS", "0" ) // Volta o Status para 0=Saida Digitada para possibilitar manutenção
		EndIf
		If oVRRMod:GetValue( "VRR_STATUS" ) == "0" // Status: Saida Digitada
			cCondic := oVRRMod:GetValue( "VRR_FORPAG" )
			If !Empty(cCondic)
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+cCondic))
				If !(SE4->E4_TIPO $ "A.9") // Se NAO for Negociada, nao deixa inserir/deletar as parcelas
					oVS9Mod:SetNoInsertLine(.T.) // Nao deixa INCLUIR as linhas do VS9
					oVS9Mod:SetNoDeleteLine(.T.) // Nao deixa DELETAR as linhas do VS9
				EndIf
			EndIf
		EndIf
	EndIf
	//
	SetKey(VK_F4,{|| OA4700101_VerEstoque() })
	//
RETURN .T.


// Campos Cabeçalho VRR //
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA470EVDEF
Local lRet      := .t.
Local cTpFix    := ""
If cModelID == "VRRMASTER"
	If cAction == "SETVALUE" // Valid do campo
		// Controla para NÃO deixar alterar os Dados do cabeçalho VRR quando estiver com o Status 4 - Liberado para Efetivar Saida
		If oSubModel:GetValue( "VRR_STATUS" ) == "4" // 4 - Liberado para Efetivar Saida
			If cId <> "VRR_CODIGO" .and. oSubModel:GetValue( cId ) <> xValue
				Help("",1,"FIELDPREVLD "+cId,,STR0057+": "+STR0058+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0059,1,0) // Status / Liberado para Efetivar Saida / Impossível alterar os Dados.
				Return .f.
			Else
				Return .t.
			EndIf
		EndIf
		Do Case
			Case cId $ "VRR_CODCLI/VRR_LOJCLI/"
				oSubModel:LoadValue( "VRR_NOMCLI" , "" )
				cCodCli := IIf( cId == "VRR_CODCLI" .and. xValue <> NIL , xValue , oSubModel:GetValue( "VRR_CODCLI" ))
				cLojCli := IIf( cId == "VRR_LOJCLI" .and. xValue <> NIL , xValue , oSubModel:GetValue( "VRR_LOJCLI" ))
				If !Empty(cCodCli)
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA1")+cCodCli+IIf(!Empty(cLojCli),cLojCli,"")))
						oSubModel:LoadValue( "VRR_LOJCLI" , SA1->A1_LOJA )
						oSubModel:LoadValue( "VRR_NOMCLI" , padr(SA1->A1_NOME,GeTSX3Cache("VRR_NOMCLI","X3_TAMANHO")) )
						If VRR->(Fieldpos("VRR_RECISS")) > 0
							oSubModel:LoadValue( "VRR_RECISS" , SA1->A1_RECISS )
						EndIf
					Else
						Help("",1,"FIELDPREVLD "+cId,,STR0060,1,0) // Cliente não existente!
						lRet := .f.
					EndIf
				EndIf

			Case cId == "VRR_FORPAG"
				If !Empty(xValue)
					oSubModel:LoadValue( "VRR_DESFPG" , "" )
					DbSelectArea("SE4")
					DbSetOrder(1)
					If DbSeek(xFilial("SE4")+xValue)
						cTpFix  := IIf(!Empty(SE4->E4_FORMA),SE4->E4_FORMA,"DP")
						VSA->(dbSetOrder(1))
						If !VSA->(dbSeek(xFilial("VSA")+cTpFix))
							Help("",1,"FIELDPREVLD VRR_FORPAG",,STR0061+CHR(13)+CHR(10)+cTpFix,1,0) // Forma de Pagamento possui um Tipo de Pagamento fixo não existente!
							lRet := .f.
						EndIf
						If lRet
							oSubModel:LoadValue( "VRR_DESFPG" , padr(SE4->E4_DESCRI,GeTSX3Cache("VRR_DESFPG","X3_TAMANHO")) )
							OA4700081_CalculaParcelas( xValue )
						EndIf
					Else
						Help("",1,"FIELDPREVLD VRR_FORPAG",,STR0062,1,0) // Forma de Pagamento não existente!
						lRet := .f.
					EndIf
				EndIf

			Case cId == "VRR_NATURE"
				If !Empty(xValue)
					DbSelectArea("SED")
					DbSetOrder(1)
					If !DbSeek(xFilial("SED")+xValue)
						Help("",1,"FIELDPREVLD VRR_NATURE",,STR0063,1,0) // Natureza não existente!
						lRet := .f.
					EndIf
				EndIf

			Case cId == "VRR_CODVEN"
				oSubModel:LoadValue( "VRR_NOMVEN" , "" )
				If !Empty(xValue)
					DbSelectArea("SA3")
					DbSetOrder(1)
					If DbSeek(xFilial("SA3")+xValue)
						oSubModel:LoadValue( "VRR_NOMVEN" , padr(SA3->A3_NOME,GeTSX3Cache("VRR_NOMVEN","X3_TAMANHO")) )
					Else
						Help("",1,"FIELDPREVLD VRR_CODVEN",,STR0064,1,0) // Vendedor não existente!
						lRet := .f.
					EndIf
				EndIf

			Case cId == "VRR_ESTPRE"
				If !Empty(xValue) .and. !ExistCpo("SX5","12"+xValue)
					Help("",1,"FIELDPREVLD VRR_ESTPRE",,STR0087,1,0) // UF não existente!
					lRet := .f.
				EndIf
				M->C5_ESTPRES := xValue // Utilizado na consulta padrão CC2SC5

			Case cId == "VRR_MUNPRE"
				If !Empty(xValue) .and. !ExistCpo("CC2",oSubModel:GetValue( "VRR_ESTPRE" )+xValue)
					Help("",1,"FIELDPREVLD VRR_MUNPRE",,STR0088,1,0) // Municipio não existente!
					lRet := .f.
				EndIf

		EndCase
	EndIf
EndIf
RETURN lRet


// Campos Itens VRS e Campos Parcelas VS9 //
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA470EVDEF
Local lRet    := .t.
Local cForPag := ""
Local cTESInt := ""
Local nVlrTot := 0
Local cCodCli := ""
Local cLojCli := ""
Local oModel  := FWModelActive()
If cModelId == "VS9DETAIL"
	If cAction == "CANSETVALUE" // Pode Alterar?
		If cId $ "VS9_TIPPAG/VS9_VALPAG/VS9_DATPAG/"
			cForPag := oModel:GetValue( "VRRMASTER" , "VRR_FORPAG" )
			DbSelectArea("SE4")
			DbSetOrder(1)
			lRet := ( !Empty(cForPag) .and. DbSeek(xFilial("SE4")+cForPag) .and. (SE4->E4_TIPO $ "A.9") )
		EndIf
	ElseIf cAction == "SETVALUE" // Valid do Campo
		If cId == "VS9_TIPPAG"
			DbSelectArea("VSA")
			DbSetOrder(1)
			If !DbSeek( xFilial("VSA") + xValue )
				Help("",1,"GRIDLINEPREVLD VS9_TIPPAG",,STR0065,1,0) // Tipo de Pagamento inválido.
				lRet := .f.
			Else
				If Empty(oSubModel:GetValue("VS9_SEQUEN"))
					oSubModel:LoadValue( "VS9_SEQUEN" , strzero(nLine,GeTSX3Cache("VS9_SEQUEN","X3_TAMANHO")) )
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf cModelId == "VRSDETAIL"
	If cAction == "CANSETVALUE" // Pode Alterar?
		Do Case
			Case cId $ "VRS_DTIVIG/VRS_DTFVIG"
				lRet := .f.
				If !Empty(oSubModel:GetValue( "VRS_TIPSER" ))
					DbSelectArea("VPV")
					DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
					lRet := IIf( DbSeek( xFilial("VPV") + oSubModel:GetValue( "VRS_TIPSER" ) ) .and. VPV->VPV_DATVIG == "0" , .f. , .t. ) // Não permite informar a Data de Vigencia
				EndIf
			Case cId == "VRS_NROSER"
				lRet := .f.
				If !Empty(oSubModel:GetValue( "VRS_TIPSER" ))
					DbSelectArea("VPV")
					DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
					lRet := IIf( DbSeek( xFilial("VPV") + oSubModel:GetValue( "VRS_TIPSER" ) ) .and. VPV->VPV_NROSER == "0" , .f. , .t. ) // Não permite informar o Nro.Serie
				EndIf
			Case cId == "VRS_CHASSI"
				lRet := .f.
				If !Empty(oSubModel:GetValue( "VRS_TIPSER" ))
					DbSelectArea("VPV")
					DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
					lRet := IIf( DbSeek( xFilial("VPV") + oSubModel:GetValue( "VRS_TIPSER" ) ) .and. VPV->VPV_VINCCP == "0" , .f. , .t. ) // Não permite informar o CHASSI/PIN
				EndIf
		EndCase
	ElseIf cAction == "SETVALUE" // Valid do campo
		Do Case
			Case cId == "VRS_SERINT"
				oSubModel:LoadValue( "VRS_GRUSER" , '' )
				oSubModel:LoadValue( "VRS_CODSER" , '' )
				oSubModel:LoadValue( "VRS_DESSER" , '' )
				oSubModel:LoadValue( "VRS_TIPSER" , '' )
				oSubModel:LoadValue( "VRS_CODTES" , space(GeTSX3Cache("VRS_CODTES","X3_TAMANHO")) )
				oSubModel:LoadValue( "VRS_QTDSER" ,  0 )
				oSubModel:LoadValue( "VRS_VLRUNI" ,  0 )
				oSubModel:LoadValue( "VRS_PERDES" ,  0 )
				oSubModel:LoadValue( "VRS_VALDES" ,  0 )
				oSubModel:LoadValue( "VRS_VLRTOT" ,  0 )
				oSubModel:LoadValue( "VRS_DTIVIG" , ctod("") )
				oSubModel:LoadValue( "VRS_DTFVIG" , ctod("") )
				oSubModel:LoadValue( "VRS_NROSER" , space(GeTSX3Cache("VRS_NROSER","X3_TAMANHO")) )
				oSubModel:LoadValue( "VRS_CHASSI" , space(GeTSX3Cache("VRS_CHASSI","X3_TAMANHO")) )
				If !Empty( xValue )
					lRet := OA4700091_ValidaEstoque( xValue , 1 ) // Posiciona no VPX/VPV e valida Estoque
					If lRet
						cCodCli := oModel:GetValue( "VRRMASTER" , "VRR_CODCLI" )
						cLojCli := oModel:GetValue( "VRRMASTER" , "VRR_LOJCLI" )
						nVlrTot := IIf( VPX->VPX_SUGVDA > 0 , VPX->VPX_SUGVDA , OA3800041_Valor( "1" , VPX->VPX_SERINT , VPX->VPX_TIPSER , VPX->VPX_GRUSER , cCodCli , cLojCli , VPX->VPX_CUSMED ) ) // Retorna o Valor Sugerido de Venda do Serviço
						DbSelectArea("SB1")
						DbSetOrder(1) // B1_FILIAL + B1_COD
						DbSeek( xFilial("SB1") + VPV->VPV_CODSB1 )
						oSubModel:LoadValue( "VRS_GRUSER" , VPX->VPX_GRUSER )
						oSubModel:LoadValue( "VRS_CODSER" , VPX->VPX_CODSER )
						oSubModel:LoadValue( "VRS_DESSER" , padr(VPX->VPX_DESSER,GeTSX3Cache("VRS_DESSER","X3_TAMANHO")) )
						oSubModel:LoadValue( "VRS_TIPSER" , VPX->VPX_TIPSER )
						oSubModel:LoadValue( "VRS_CODTES" , FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS") )
						oSubModel:LoadValue( "VRS_VLRUNI" , nVlrTot )
						If VPV->VPV_DATVIG == "1" .and. VPV->(FieldPos("VPV_DIASVG")) > 0 .and. VPV->VPV_DIASVG > 0 // Com validação de Data de Vigencia e possui a qtde de dias para preenchimento automatico
							oSubModel:LoadValue( "VRS_DTIVIG" , dDataBase )
							oSubModel:LoadValue( "VRS_DTFVIG" , dDataBase + VPV->VPV_DIASVG )
						EndIf
					EndIf
				EndIf

			Case cId $ "VRS_QTDSER/VRS_VLRUNI/"
				If cId == "VRS_QTDSER"
					lRet := OA4700091_ValidaEstoque( oSubModel:GetValue( "VRS_SERINT" ) , xValue )
					If lRet
						nVlrTot := ( xValue * oSubModel:GetValue( "VRS_VLRUNI" ) )
					EndIf
				Else // cId == "VRS_VLRUNI"
					nVlrTot := ( oSubModel:GetValue( "VRS_QTDSER" ) * xValue )
				EndIf
				If lRet
					If oSubModel:GetValue( "VRS_PERDES" ) > 0
						nVlrTot := nVlrTot - ( nVlrTot * ( oSubModel:GetValue( "VRS_PERDES" ) / 100 ) )
					ElseIf oSubModel:GetValue( "VRS_VALDES" ) > 0
						If nVlrTot >= oSubModel:GetValue( "VRS_VALDES" )
							nVlrTot := nVlrTot - oSubModel:GetValue( "VRS_VALDES" )
						Else
							Help("",1,"GRIDLINEPREVLD VRS_VALDES",,STR0066,1,0) // Desconto maior que o Valor Total do Serviço.
							lRet := .f.
						EndIf
					EndIf
					If lRet
						oSubModel:LoadValue( "VRS_VLRTOT" , nVlrTot )
						oModel := FWModelActive()
						OA4700081_CalculaParcelas( oModel:GetValue( "VRRMASTER" , "VRR_FORPAG" ) )
					EndIf
				EndIf

			Case cId $ "VRS_PERDES/VRS_VALDES/"
				nVlrTot := ( oSubModel:GetValue( "VRS_QTDSER" ) * oSubModel:GetValue( "VRS_VLRUNI" ) )
				If cId == "VRS_PERDES"
					nVlrTot := nVlrTot - ( nVlrTot * ( xValue / 100 ) )
					oSubModel:LoadValue( "VRS_VALDES" , 0 )
				Else // cId == "VRS_VALDES"
					If nVlrTot >= xValue
						nVlrTot := nVlrTot - xValue
						oSubModel:LoadValue( "VRS_PERDES" , 0 )
					Else
						Help("",1,"GRIDLINEPREVLD VRS_VALDES",,STR0066,1,0) // Desconto maior que o Valor Total do Serviço.
						lRet := .f.
					EndIf
				EndIf
				If lRet
					oSubModel:LoadValue( "VRS_VLRTOT" , nVlrTot )
					oModel := FWModelActive()
					OA4700081_CalculaParcelas( oModel:GetValue( "VRRMASTER" , "VRR_FORPAG" ) )
				EndIf

			Case cId == "VRS_TIPOPE"
				If !Empty(xValue)
					DbSelectArea("SX5")
					DbSetOrder(1)
					If DbSeek( xFilial("SX5") + "DJ" + xValue )
						DbSelectArea("VPX")
						DbSetOrder(1)
						DbSeek( xFilial("VPX") + oSubModel:GetValue( "VRS_SERINT" ) )
						DbSelectArea("VPV")
						DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
						DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
						DbSelectArea("SB1")
						DbSetOrder(1) // B1_FILIAL + B1_COD
						DbSeek( xFilial("SB1") + VPV->VPV_CODSB1 )
						cTESInt := MaTesInt( 2 , xValue , oModel:GetValue( "VRRMASTER" , "VRR_CODCLI" ) , oModel:GetValue( "VRRMASTER" , "VRR_LOJCLI" ) , "C" , SB1->B1_COD )
						lRet := oSubModel:SetValue( "VRS_CODTES" , cTESInt )
					Else
						Help("",1,"GRIDLINEPREVLD VRS_TIPOPE",,STR0067,1,0) // Tipo de Operação não existente!
						lRet := .f.
					EndIf
				EndIf

			Case cId == "VRS_CODTES"
				If !Empty(xValue)
					DbSelectArea("SF4")
					DbSetOrder(1)
					If DbSeek( xFilial("SF4") + xValue )
						If SF4->F4_ESTOQUE # "N" // Necessário ser TES que NAO movimenta Estoque
							Help("",1,"GRIDLINEPREVLD VRS_CODTES",,STR0068,1,0) // Utilize um TES de Saida que NÃO movimenta Estoque!
							lRet := .f.
						Else
						 	If SF4->F4_TIPO # "S" // Necessário ser TES de Saida
								Help("",1,"GRIDLINEPREVLD VRS_CODTES",,STR0069,1,0) // Utilize um TES de Saida!
								lRet := .f.
							EndIf
						EndIf
					Else
						Help("",1,"GRIDLINEPREVLD VRS_CODTES",,STR0070,1,0) // TES inválido! Impossível continuar.
						lRet := .f.
					EndIf
				EndIf
				If lRet
					oSubModel:LoadValue( "VRS_TIPOPE" , space(GeTSX3Cache("VRS_TIPOPE","X3_TAMANHO")) )
				EndIf

			Case cId == "VRS_DTIVIG"
				If Empty(xValue)
					oSubModel:LoadValue( "VRS_DTFVIG" , xValue )
				EndIf
				If oSubModel:GetValue( "VRS_DTFVIG" ) < xValue
					oSubModel:LoadValue( "VRS_DTFVIG" , xValue )
				EndIf

			Case cId == "VRS_DTFVIG"
				If Empty(xValue)
					oSubModel:LoadValue( "VRS_DTIVIG" , xValue )
				EndIf
				If xValue < oSubModel:GetValue( "VRS_DTIVIG" )
					Help("",1,"GRIDLINEPREVLD VRS_DTFVIG",,STR0071,1,0) // Impossível informar Data Final menor que a Data Inicial da Vigência.
					lRet := .f.
				EndIf

		EndCase
	EndIf
EndIf
RETURN lRet


// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS OFIA470EVDEF
	Local oVRRMod
	Local oVRSMod
	Local lRet       := .t.
	Local nOperModel := oModel:GetOperation()
	Local cMsgAvi    := ""
	Local nOpcAvi    := 0
	Local nCntFor    := 0
	Local nTotSrv    := 0
	Local nTotPar    := 0
	Local lContinua  := .t.
	Private cSerie   := "" // Serie da NF
	Private cNumero  := "" // Numero da NF
	Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
	//
	::lGeraNF := .f. // NAO gerar NF
	::lEstoq  := .f. // NAO atualizar Estoque
	//
	If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
		If nOperModel == MODEL_OPERATION_UPDATE // Alteração
			lRet := ::VldActivate(oModel, cId)
		EndIf
		If lRet
			oVRRMod := oModel:GetModel("VRRMASTER")
			If ( "C5_NATUREZ" $ Upper(SuperGetMv("MV_1DUPNAT",.F.,"")) ) .and. SC5->(FieldPos("C5_NATUREZ")) <> 0 .and. Empty(oVRRMod:GetValue( "VRR_NATURE" )) .or. cDebugMIL == "OFIA470001"
				Help("",1,"OFIA470EVDEF_ModelPosVld_VRR_NATURE",,STR0072,1,0) // Necessário informar a Natureza. Impossível continuar.
				lRet := .f.
			EndIf
			If lRet
				oVRSMod := oModel:GetModel("VRSDETAIL")
				For nCntFor := 1 to oVRSMod:Length()
					oVRSMod:GoLine(nCntFor)
					If !oVRSMod:IsDeleted()
						lRet := OA4700091_ValidaEstoque( oVRSMod:GetValue( "VRS_SERINT" ) , oVRSMod:GetValue( "VRS_QTDSER" ) )
						If !lRet
							Exit
						EndIf
						lRet := OA4700121_ValidaCamposObrigatorios( oVRSMod:GetValue( "VRS_SERINT" ) , oVRSMod:GetValue( "VRS_TIPSER" ) , oVRSMod:GetValue( "VRS_DTIVIG" ) , oVRSMod:GetValue( "VRS_DTFVIG" ) , oVRSMod:GetValue( "VRS_NROSER" ) , oVRSMod:GetValue( "VRS_CHASSI" ) )
						If !lRet
							Exit
						EndIf
						If oVRSMod:GetValue( "VRS_VLRTOT" ) > 0
							nTotSrv += oVRSMod:GetValue( "VRS_VLRTOT" ) // Totalizar os Servicos
						EndIf
					EndIf
				Next
			EndIf
			If lRet
				oVS9Mod := oModel:GetModel("VS9DETAIL")
				oVS9Mod:SetNoUpdateLine(.F.) // Deixa ALTERAR as linhas do VS9
				For nCntFor := 1 to oVS9Mod:Length()
					oVS9Mod:GoLine(nCntFor)
					If !oVS9Mod:IsDeleted()
						nTotPar += oVS9Mod:GetValue( "VS9_VALPAG" ) // Totalizar as Parcelas
						If oVS9Mod:GetValue( "VS9_DATPAG" ) < dDataBase
							oVS9Mod:SetValue( "VS9_DATPAG" , dDataBase ) // Preencher com dDataBase a Data da Parcela que estiver vencida 
						EndIf
					EndIf
				Next
				oVS9Mod:SetNoUpdateLine(.T.) // Nao deixa ALTERAR as linhas do VS9
				If nTotSrv <> nTotPar
					Help("",1,"OFIA470EVDEF_ModelPosVld_VS9_VALPAG",,STR0074,1,0) // Existe divergência entre o Total dos Serviços e das Parcelas. Impossível continuar.
					lRet := .f.
				EndIf
			EndIf
			If lRet
				::cNroNFI := cNumero
				::cSerNFI := cSerie
				cMsgAvi += CHR(13)+CHR(10)
				If oVRRMod:GetValue( "VRR_STATUS" ) == "0" // 0=Saida Digitada
					cMsgAvi += STR0075+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Avançar Fase
					cMsgAvi += STR0076 // Salvar Digitação
					nOpcAvi := Aviso(STR0001,cMsgAvi,{STR0075,STR0076},3) // Saida de Serviços Especializados / Avançar Fase / Salvar Digitação
					If nOpcAvi == 1 // Avançar Fase
						lContinua := OA4700111_AvancaFaseSaida() // Avança Saida - se necessário, abre tela de Solicitação de Aprovação das Pendencias
					EndIf
				EndIf
				If lContinua .and. oVRRMod:GetValue( "VRR_STATUS" ) == "4" // Liberado para Efetivar
					If MsgYesNo(STR0077,STR0023) // Deseja Efetivar a Saida dos Serviços Especializados? / Atenção
						lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
						If lRet
							::lGeraNF := .t. // Gerar NF
							::lEstoq  := .t. // Atualizar Estoque
							::cNroNFI := cNumero
							::cSerNFI := cSerie
						EndIf
						lRet := .t. // Voltar sempre .t. para não estourar help no MVC
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
RETURN lRet


// Validação antes da Abertura da Tela //
METHOD VldActivate(oModel, cModelId) CLASS OFIA470EVDEF
	Local lRet := .T.
	Local nOperModel := oModel:GetOperation()
	If nOperModel == MODEL_OPERATION_UPDATE
		Do Case
			Case VRR->VRR_STATUS == "1" // 1=Saida Efetivada
				Help("",1,"VLDACTIVATE",,STR0078,1,0) // Saida já Efetivada. Impossível alterar.
				lRet := .f.
			Case VRR->VRR_STATUS == "2" // 2=Saida Cancelada
				Help("",1,"VLDACTIVATE",,STR0079,1,0) // Saida já Cancelada. Impossível alterar.
				lRet := .f.
			Case VRR->VRR_STATUS == "3" // 3=Pendências - Aguardando Liberação
				Help("",1,"VLDACTIVATE",,STR0080,1,0) // Existem Pendências. Aguarde a Liberação.
				lRet := .f.
		EndCase
	EndIf
RETURN lRet


// Chamado apos a Gravação padrão //
METHOD AfterTTS(oModel, cModelId) CLASS OFIA470EVDEF
Local lRet    := .t.
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	If ::lGeraNF .or. ::lEstoq // Gerar NF ou Atualizar Estoque
		oProcSaida := MsNewProcess():New({ |lEnd| lRet := OA4700021_IncluirSaida( ::cNroNFI , ::cSerNFI , ::lGeraNF , ::lEstoq ) }," ","",.f.)
		oProcSaida:Activate()
		::lGeraNF := .f. // Volta para NAO gerar NF
		::lEstoq  := .f. // Volta para NAO atualizar Estoque
	EndIf
EndIf
RETURN lRet


// Fechar Tela
METHOD DeActivate(oModel) CLASS OFIA470EVDEF
	SetKey(VK_F4, Nil )
RETURN .T.
