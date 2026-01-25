#include "Protheus.ch"
#INCLUDE "FWCOMMAND.CH"
#include "VEIXX001.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOPCONN.CH'
 
Static nAntMoeda := 0
Static nAntTXMoe := 0
Static lMultMoeda := FGX_MULTMOEDA()

/////// Operacao (VV0_OPEMOV) ////////////
// 0=Venda
// 1=Simulacao
// 2=Transferencia
// 3=Remessa
// 4=Devolucao
// 5=Consignado                                      
// 6=Ret Remessa
// 7=Ret Consignado
// 8=Venda Futura  
// 9=Baixa           // ATENCAO - Movimento tipo 9 foi criado para a CAOA, mas depois da implantaÁ„o verificou-se que este tipo de movimentaÁ„o n„o existe. Se tratava de uma saida por baixa simples sem nota fiscal. Desta forma, este tipo de movimentaÁ„o foi removido do fonte
///////////////////////////////////////////













/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    | VEIXX001   | Autor |  Luis Delorme         | Data | 19/02/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Saida de Veiculos                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VEIXX001(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov,xAutoAux,xMostraMsg,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR,xAutoLoc, cSerieNFAutom)

Local lRet := .f.
Local nTamGru := TamSx3("B1_GRUPO")[1]		// Tamanho da variavel de grupo
Local lManutVV0A := .t. // Manutencao dos campos VV0 na tela e grid de Veiculos VVA
//
Private bRefresh := { || .t. } 				// Variavel necessaria ao MAFISREF
Private aIteParc := { { ctod(""),0 } }	// Vetor contendo os titulos a pagar
//
Private cGruVei  := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1])) // Grupo do Veiculo
Private cGruFor  := "10" // Grupo de FÛrmulas de Sa¥da por TransferÍncia

Private oSayE18 
Private oSayE19 
Private oSayE21 
Private oSayE22 
Private oGetE18
Private oGetE19
Private oGetE21
Private oGetE22

Private cUsaGrVA := GetNewPar("MV_MIL0010","0") // O MÛdulo de VeÌculos trabalhar· com VeÌculos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
//
Private lAbortPrint	:= .f.	// Variavel de Aborto de Operacao
Private cOpeMov := xOpeMov		// Tipo de Operacao de entrada (recebe o valor do parametro)
Private cSerie := ""		// Serie da NF quando formulario proprio
Private cNumero	:= ""		// Numero da NF quando formulario proprio
Private lMudouNum := .f. 		// Indica se houve mudanca da sequencia de nota fiscal
// Variaveis de integracao
Private lMostraMsg := IIF(xMostraMsg==NIL,.t.,xMostraMsg)
Private aAutoCab := {} 			// Cabecalho da NF (VV0)
Private aAutoItens := {}		// Itens da NF (VVA)
Private aAutoIteParc := {}		// Como pagar (SE1)
Private aAutoAux := {}			// Auxiliar (para retornos de remessa/consignado)
If cPaisLoc == "ARG" .and. cOpeMov $ "467" // 4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao
	Private aAutoArg := xAutoLoc // Campos especÌficos Argentina
ElseIf cPaisLoc == "MEX" .and. cOpeMov $ "467" // 4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao
	Private aAutoMex := xAutoLoc // Campos especÌficos Mexico
EndIf
Private cPrefVEI := GetNewPar("MV_PREFVEI","VEI")
// 'lVX001Auto' indica se todos os vetores de integracao foram preenchidos
Private lVX001Auto := ( xAutoCab<>NIL  .and. xAutoItens<> NIL  .and. xAutoCP<>NIL .and. nOpc<>NIL .and. xOpeMov<>NIL )
// VARIAVEIS DE CONTROLE DA TELA (OBJETOS)
Private aTitulo := {STR0002,STR0003}	// Titulo dos folders    - Dados da Nota Fiscal -Como Pagar -Moeda
Private oFnt1 := TFont():New( "System", , 12 )
Private oFnt2 := TFont():New( "Courier New", , 16,.t. )
Private oFnt3 := TFont():New( "Arial", , 14,.t. )
// Variaveis do Folder 2 - Como Pagar
Private dDataIni		:= ctod(" ")
Private nDias1P
Private nParcel
Private nInterv
Private n := 1
Private cCliForA := "" //GetNewPar("MV_CLFRRC","")
Private aOrc := {}
Private aOrcDynHeader := {}
Private aOrcDynFooter := {}
Private nRecVV0 := 0
//
Private lAtuFiscal := .t. // Atualiza Fiscal
Private lLocxAuto  := .F.
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV     := ""
Default cRotOrigem  := ProcName(1)
Default cTpFatR     := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura pelo Remito
Default cSerieNFAutom:= ""

If cPaisLoc $ "ARG,MEX"
	If cOpeMov $ "234567" // 2=Transferencia / 3=Remessa / 4=Devolucao / 5=Consignacao / 6=Retorno Remessa / 7=Retorno Consignacao
		cTpFatR := "2" // Sempre 2=Remito quando o movimento for 2=Transferencia / 3=Remessa / 4=Devolucao / 5=Consignacao / 6=Retorno Remessa / 7=Retorno Consignacao
	EndIf
	If cOpeMov == "0" // 0=Venda
		If	( (cTpFatR == "2" .or. cTpFatR == "4") .and. !Empty(VV0->VV0_NUMNFI) .and. Empty(VV0->VV0_REMITO) ) .or. ; // Fatura gerada ( Aguardando Remito )
			( cTpFatR == "3" .and. Empty(VV0->VV0_NUMNFI) .and. !Empty(VV0->VV0_REMITO) ) // Remito gerado ( Aguardando Fatura )
			nOpc := 4 // Quando 'Remito apÛs Fatura' ou 'Fatura apÛs Remito' n„o deve criar outro VV0. ForÁar 4 = ALTERAR
			lManutVV0A := .f. // N„o deixa realizar manutencao dos campos VV0 na tela e grid de Veiculos VVA
		EndIf
	EndIf
EndIf

if lMultMoeda // MultMoeda
	 aTitulo := {STR0002,STR0003, STR0103}	
else 
	 aTitulo := {STR0002,STR0003}			
Endif
//
If xTIPDOC == "2" // SD3 ( Mov.Internas )
	lAtuFiscal := .f. // NAO atualizar Fiscal quando Mov.Internas
EndIf
//
If !AMIIn(11) .or. !FMX_AMIIn({"VEIVC140", "VEIXA004", "VEIXA008", "VEIXA011", "VEIXA012","VEIXA013", "VEIXA014", "VEIXA015", "VEIXA016", "VEIXA017", "VEIXA020", "VEIXA023", "VEIXA025" ,"VEIXX021","VEIXA018","VEIXA030","VEIXA040","VEIVC210","VEIVC260","VEIA080"})
	Return()
EndIf
//
If !lVX001Auto
	If cCadastro == NIL
		cCadastro := STR0001 //Saida de Veiculos
	EndIf
Endif
// Se for detectado que trata-se de integracao faz os vetores receberemm os parametros
If lVX001Auto
	aAutoItens := xAutoItens
	aAutoCab   := xAutoCab
	aIteParc := xAutoCP
	aAutoAux 	:= IIF(xAutoAux==NIL,{},xAutoAux)
EndIf
// Na integracao as variaveis abaixo nao existirao,
// por isso precisamos carrega-las manualmente
INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5
//#############################################################################
//# Chama a tela contendo os dados do veiculo                                 #
//#############################################################################
DBSelectArea("VV0")
lRet := VX001EXEC(alias(),Recno(),nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR,lManutVV0A, cSerieNFAutom)
If lRet .and. nRecVV0 > 0
	VV0->(DbGoto(nRecVV0))
EndIf
//
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Programa  | VX001EXEC  |Autor  | Luis Delorme          | Data | 19/02/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Saida de Veiculos                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001EXEC(cAlias,nReg,nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR,lManutVV0A, cSerieNFAutom)
Local lRet      := .t.
//
Local nCntFor
Local nCntFor2
Local aObjects 	 := {}
Local aObjects1	 := {}
Local aObjects2	 := {}   
Local nPosCpo    := 0
Local aSizeAut	 := MsAdvSize(.t.)
Local oFilHlp    := DMS_FilialHelper():New()
Local aParamBox  := {}
Local aRet       := {}
Local cMV_PAR02  := ""
Local lMV_FILTRF := GetNewPar("MV_FILTRF", .F.)
Local aCliLjDest
Local aInfo := {}
Local lCondPag := .t.
Local nOldN := 0 // Vari·vel N anterior

Private aCliFor  := X3CBOXAVET("VVF_CLIFOR","0")
Private aIndPre  := X3CBOXAVET("VV0_INDPRE","0")
Private aTipoFre := X3CBOXAVET("VV0_TPFRET","1")
Private aTipoCli := X3CBOXAVET("VV0_TIPOCL","1")
Private cCFWhen  := .t.
Private aAreaSM0 := {}
Private nMoedaCor
Private nTaxaMoeda
//
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV     := ""
Default cTpFatR     := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura pelo Remito
Default lManutVV0A  := .t. // Manutencao dos campos VV0 na tela e grid de Veiculos VVA
Default cSerieNFAutom := ""

// Valida se a nota n„o foi transmitida e se n„o existem tÌtulos baixados.
If nOpc == 5 .and. cPaisLoc $ "ARG"
	
	DbSelectArea("SF2")
	DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	SF2->(DbSeek(FWxFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
	If !Empty(SF2->F2_CAEE) .or. !Empty(SF2->F2_EMCAEE)
		FMX_HELP("VLDVX001TUDOK", STR0107, STR0106)
		lRet := .f.
	EndIf
	DbSelectArea("VV0")

	If lRet 
		lRet := VX0010068_ExistBaixa()
	EndIf

EndIf

If lRet

	/*
	1 -> Linha inicial area trabalho
	2 -> Coluna inicial area trabalho
	3 -> Linha final area trabalho
	4 -> Coluna final area trabalho
	5 -> Coluna final dialog
	6 -> Linha final dialog
	7 -> Linha inicial dialog
	*/
	//Local bCampo	  := { |nCPO| Field(nCPO) }
	//
	// MONTA ESPACAMENTO DAS TELAS
	//
	nResAltura := GetScreenRes()[2]
	// TELA SUPERIOR (ENCHOICE) 	- TAMANHO VERTICAL VARIAVEL
	AAdd( aObjects, { 0, iif(nResAltura <= 600 , 60 , iif( nResAltura <= 768 , 80 , 170 )) , .T., .F. } )
	// TELA CENTRAL (GETDADOS) 	- TAMANHO VERTICAL FIXO
	AAdd( aObjects, { 0,	20, .T., .T. } )
	// TELA INFERIOR (FOLDER) 		- TAMANHO VERTICAL FIXO
	AAdd( aObjects, { 0,	iif( nResAltura <= 768 , 75, 80 ), .T., .F. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	// ESPACAMENTO DA TELA DE FOLDER - QUATRO LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 10, .T., .f. } )
	AAdd( aObjects1, { 0, 0, .T., .T. } )
	aAbaInt := { 0, 0, aPosObj[3,4]-aPosObj[3,2], aPosObj[3,3]-aPosObj[3,1]-14, 3, 3}
	aPosAba1 := MsObjSize( aAbaInt, aObjects1 )
	// ESPACAMENTO DA TELA DE CABECALHO - DOZE LINHAS DE TAMANHO FIXO + FINAL VARIAVEL
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 08, .T., .f. } )
	AAdd( aObjects2, { 0, 0, .T., .T. } )
	aAbaCab := { aPosObj[1,2], aPosObj[1,1], aPosObj[1,4], aPosObj[1,3] , 3, 3 }
	aPosAbaCab := MsObjSize( aAbaCab, aObjects2 )
	//
	// Zera variaveis de controle dos objetos
	//
	aIteParc := { { ctod(""),0 } }
	dDataIni 	:= ctod(" ")
	nDias1P 		:= 0
	nParcel 		:= 0
	nInterv 		:= 0
	nMoedaCor       := 0
	nTaxaMoeda      := 0

	//##########################################
	//# Cria variaveis M->????? da Enchoice    #
	//##########################################
	dbSelectArea("VV0")
	dbSetOrder(1)
	//
	// FILTRA OS CAMPOS DA ENCHOICE (VV0) E GETDADOS (VVA) DEPENDENDO DO TIPO DE NOTA DE ENTRADA
	//
	cFiltrVVA := "VVA_FILIAL#VVA_DESMAR#VVA_DESMOD#VVA_NUMTRA#VVA_DESCOR#"
	cFiltrVVA += "VVA_SIMVDA#VVA_PLAVEI#VVA_CMFPGC#VVA_COMPGC#VVA_FILENT#VVA_TRACPA#"
	cFiltrVVA += "VVA_CODIND#VVA_FATTOT#VVA_FMFTOT#VVA_VMFMOV#VVA_VMFVDA#VVA_VALCVD#"
	cFiltrVVA += "VVA_VMFCVD#VVA_COMCOT#VVA_CMFCOT#VVA_COMCTP#VVA_CMFCTP#VVA_RECTEC#"
	cFiltrVVA += "VVA_RMFTEC#VVA_DATRTC#VVA_INPICO#VVA_INPCRT#VVA_INPCBF#VVA_INISRT#"
	cFiltrVVA += "VVA_INISBF#VVA_BMFFAB#VVA_DATBFB#VVA_TOTIMP#VVA_TMFIMP#VVA_IMFVEN#"
	cFiltrVVA += "VVA_ISSCVD#VVA_IMFCVD#VVA_PMFVEN#VVA_CMFVEN#VVA_ISSRTE#VVA_ISSBFB#"
	cFiltrVVA += "VVA_IMFRTE#VVA_IMFBFB#VVA_PISRTE#VVA_PISBFB#VVA_PMFRTE#VVA_PMFBFB#"
	cFiltrVVA += "VVA_TOTCUS#VVA_TMFCUS#VVA_VCAVEI#VVA_VMFVEI#VVA_ICMCOM#VVA_IMFCOM#"
	cFiltrVVA += "VVA_PISENT#VVA_PMFENT#VVA_COFENT#VVA_CMFENT#VVA_JUREST#VVA_JMFEST#"
	cFiltrVVA += "VVA_REDCUS#VVA_RMFCUS#VVA_DATRCU#VVA_ACESSO#VVA_AMFSSO#VVA_VDESCO#"
	cFiltrVVA += "VVA_VMFSCO#VVA_LUCBRU#VVA_LMFBRU#VVA_TMFDES#VVA_DMFCLI#VVA_SMFVIA#"
	cFiltrVVA += "VVA_VMFASS#VVA_VMFREV#VVA_VMFFRE#VVA_DMFVEI#VVA_RMFVEI#VVA_AMFIMP#"
	cFiltrVVA += "VVA_LUCLQ1#VVA_LMFLQ1#VVA_DESFIX#VVA_DMFFIX#VVA_VALIRF#VVA_VMFIRF#"
	cFiltrVVA += "VVA_COMVDE#VVA_CMFVDE#VVA_COMGER#VVA_CMFGER#VVA_COMPAT#VVA_CMFPAT#"
	cFiltrVVA += "VVA_DSPFIN#VVA_DMFFIN#VVA_LUCLQ2#VVA_LMFLQ2#VVA_EMINVD#VVA_USUARI#"
	cFiltrVVA += "VVA_PERDES#VVA_PERCVD#VVA_VRENET#VVA_DATVAL#"
	cFiltrVVA += "VVA_BONFAB#VVA_BONCON#VVA_BONREG#VVA_BMFREG#VVA_BMFCON#"
	cFiltrVVA += "VVA_VALASS#VVA_VALREV#VVA_UTROCO#VVA_PERDVD#VVA_VALDVD#VVA_RECVEI#"
	cFiltrVVA += "VVA_ASSIMP#VVA_BONUS#VVA_REBATE#VVA_ENTMEM#VVA_OBSENT#VVA_DTLIBF#"
	cFiltrVVA += "VVA_DTLIBE#VVA_DTESUG#VVA_DTEREA#"
	cFiltrVVA += "VVA_DTEPRV#VVA_HREPRV#VVA_FIEPRV#VVA_BOEPRV#VVA_USEPRV#"
	cFiltrVVA += "VVA_ITETRA#VVA_CODMAR#VVA_GRUMOD#VVA_MODVEI#VVA_CORVEI#VVA_DATENT#VVA_SEGMOD#"
	cFiltrVVA += "VVA_HORVAL#VVA_VALTAB#VVA_DESVEI#VVA_SEGVIA#VVA_VALFRE#"
	cFiltrVVA += "VVA_CAMPAN#" + iif(cOpeMov != "2", "VVA_FORMUL#", "")
	If cOpeMov $ "01234567"
		cFiltrVV0S := "VV0_OPEMOV#VV0_NUMTRA#VV0_VALMOV#VV0_CHASSI#VV0_CLIFTD#VV0_LOJFTD#"
		cFiltrVV0S += "VV0_CATVEN#VV0_TIPVEN#VV0_LOJAAV#VV0_LOJALI#VV0_IMPOST#VV0_VALTOT#"
		cFiltrVV0S += "VV0_TIPMOV#VV0_FCICOD#VV0_GERFIN#VV0_TIPDOC#VV0_CAMPAN#"
	EndIf
	If !(cPaisLoc == "BRA")
		cFiltrVVA += "VVA_VBAICM#VVA_ALIICM#VVA_PISVEN#VVA_COFVEN#VVA_ALIIPI#VVA_ALIPIC#VVA_ICMVEN#"
	endif
	//
	// CAMPOS DE VISUALIZACAO DO FOLDER 1
	//
	aOrc := {}
	If lAtuFiscal // Atualiza Fiscal
		aAdd(aOrc,{'MaFisRet(,"NF_VALMERC")',STR0069,0,"SF2->F2_VALMERC"})
		aAdd(aOrc,{'MaFisRet(,"NF_DESCONTO")',STR0070,0,"SF2->F2_DESCONT"})
		aAdd(aOrc,{'MaFisRet(,"NF_SEGURO")',STR0071,0,"SF2->F2_SEGURO"})
		aAdd(aOrc,{'MaFisRet(,"NF_DESPESA")',STR0072,0,"SF2->F2_DESPESA"})
		aAdd(aOrc,{'MaFisRet(,"NF_FRETE")',STR0073,0,"SF2->F2_FRETE"})
		If (cPaisLoc == "BRA")
			aAdd(aOrc,{'MaFisRet(,"NF_VALICM")',STR0074,0,"SF2->F2_VALICM"})
			aAdd(aOrc,{'MaFisRet(,"NF_VALSOL")',STR0075,0,"SF2->F2_ICMSRET"})
		endif
		aAdd(aOrc,{'MaFisRet(,"NF_TOTAL")',STR0076,0,"SF2->F2_VALBRUT"})

		if cPaisLoc $ "ARG,MEX"
			aAdd(aOrcDynHeader,{'MaFisRet(,"NF_VALMERC")',STR0069,0,"SF2->F2_VALMERC"})

			aAdd(aOrcDynFooter,{'MaFisRet(,"NF_DESCONTO")',STR0070,0,"SF2->F2_DESCONT"})
			aAdd(aOrcDynFooter,{'MaFisRet(,"NF_SEGURO")'  ,STR0071,0,"SF2->F2_SEGURO"})
			aAdd(aOrcDynFooter,{'MaFisRet(,"NF_DESPESA")' ,STR0072,0,"SF2->F2_DESPESA"})
			aAdd(aOrcDynFooter,{'MaFisRet(,"NF_FRETE")'   ,STR0073,0,"SF2->F2_FRETE"})
			aAdd(aOrcDynFooter,{'MaFisRet(,"NF_TOTAL")'   ,STR0076,0,"SF2->F2_VALBRUT"})
		endif
	EndIf
	//
	// PONTO DE ENTRADA PARA ALTERACAO DOS VETORERS ( aOrc ou aAutoCab )
	//
	If ExistBlock("VX001MF1")
		ExecBlock("VX001MF1",.f.,.f.)
	EndIf
	//
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VV0")
	aCpoEncS := {} // ARRAY DE CAMPOS DA ENCHOICE
	While !Eof().and.(x3_arquivo=="VV0")
		If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(alltrim(x3_Campo) $ cFiltrVV0S)
			AADD(acpoEncS,x3_campo)
		EndIf
		If Inclui
			&("M->"+x3_campo):= CriaVar(x3_campo)
		Else
			If x3_context == "V"
				&("M->"+x3_campo):= &(X3_RELACAO)
			Else
				&("M->"+x3_campo):= &("VV0->"+x3_campo)
			EndIf
		EndIf
		DbSkip()
	EndDo
	M->VV0_OPEMOV := cOpeMov
	M->VV0_TPFATR := If(cTpFatR == "4","2",cTpFatR) // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura pelo Remito
	If cPaisLoc $ "ARG,MEX" .and. cOpeMov $ "234567" // ARGENTINA OU MEXICO e È 2=Transferencia / 3=Remessa / 4=Devolucao / 5=Consignacao / 6=Retorno Remessa / 7=Retorno Consignacao
		lCondPag := .f. // N„o tem FINANCEIRO
		M->VV0_FORPAG := RetCondVei() 

		//Ajusta o array com a vari·vel de memÛria
		If Ascan(aAutoCab,{|x|x[1]=="VV0_FORPAG"}) > 0
			aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_FORPAG"}),2] := M->VV0_FORPAG
		EndIf
	EndIf

	//#####################################
	//# Cria aHeader e aCols da GetDados  #
	//#####################################
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VVA")
	aHeaderV := {}
	nUsadoV  := 0
	While !Eof().And.(x3_arquivo=="VVA")
		If ( X3USO(x3_usado).And.cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrVVA);
			.or. ( alltrim(x3_Campo) == "VVA_CHAINT" )

			nUsadoV:=nUsadoV+1
			Aadd(aHeaderV,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )

		EndIf
		If Inclui
			&("M->"+x3_campo) := CriaVar(x3_campo)
		EndIf
		DbSkip()
	EndDo
	//  CRIA ACOLS
	If INCLUI
		aColsV := { Array(nUsadoV+1) }
		aColsV[1,nUsadoV+1] := .F.
		For nCntFor:=1 to nUsadoV
			aColsV[1,nCntFor]:=CriaVar(aHeaderV[nCntFor,2])
		Next
	Else
		aColsV:={}
		aRecsVVA := {}
		cQryAl001 := GetNextAlias()
		cQuery := "SELECT VVA.R_E_C_N_O_ RECVVA FROM "+RetSqlName("VVA")+" VVA, "+RetSqlName("VV0")+" VV0"
		cQuery += " WHERE VVA_FILIAL ='"+xFilial("VVA")+"' AND"
		cQuery += " VV0_FILIAL ='"+xFilial("VV0")+"' AND"
		If VV0->VV0_TIPDOC == "2" .or. cPaisLoc <> "BRA" // 1 = NF / 2 = Mov.Internas (SD3) / LigaÁ„o fora do BRASIL deve ser sempre pelo NUMTRA
			cQuery += " VV0_NUMTRA ='"+VV0->VV0_NUMTRA+"' AND "
		Else
			cQuery += " VV0_NUMNFI ='"+VV0->VV0_NUMNFI+"' AND VV0_SERNFI ='"+VV0->VV0_SERNFI + "' AND "
		EndIf
		cQuery += " VV0_NUMTRA = VVA_NUMTRA AND "
		cQuery += " VVA.D_E_L_E_T_=' ' AND "
		cQuery += " VV0.D_E_L_E_T_=' '"

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
		//
		while !(cQryAl001)->(eof())
			aAdd(aRecsVVA,(cQryAl001)->(RECVVA))
			(cQryAl001)->(DBSkip())
		enddo
		(cQryAl001)->(dbCloseArea())
		//
		dbSelectArea("VVA")
		dbSetOrder(1)
		//
		for nCntFor2 := 1 to Len(aRecsVVA)
			VVA->(DBGoTo(aRecsVVA[nCntFor2]))
			AADD(aColsV,Array(nUsadoV+1))
			For nCntFor:=1 to nUsadoV
				aColsV[Len(aColsV),nCntFor] := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
				If aHeaderV[nCntFor,2]  <> "V"
					&("M->"+aHeaderV[nCntFor,2]) := FieldGet(FieldPos(aHeaderV[nCntFor,2]))
				EndIf
			Next
			aColsV[Len(aColsV),nUsadoV+1]:=.F.
		next
	EndIf
	// ZERA A PILHA FISCAL
	If lAtuFiscal // Atualiza Fiscal
		MaFisEnd()
	EndIf
	//

	If lMV_FILTRF .and. cOpeMov $ "2"
		aAreaSM0 := SM0->(GetArea())

		aAdd(aParamBox, {1, STR0096, cFilAnt, "@!", "", "SM0", ".F.", 0, .T.})  // Filial Origem 
		aAdd(aParamBox, {1, STR0091, Space(TamSX3("VV0_FILIAL")[1]), "@!", "VX001003B_ValidaFilial(MV_PAR01, MV_PAR02, aAreaSM0)", "SM0", "", 0, .T.})  // Filial Destino
		If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
			cMV_PAR02 := aRet[02]
		Else
			Return
		EndIf
	EndIf
	//
	If !lVX001Auto
		//####################################################
		//# Monta condicao de pagamento e dados da NF        #
		//####################################################
		If !INCLUI
			VX001LOADCP()
			VX001LOADNF()

			If lMultMoeda
				VX0010016_LoadMoeda()
			EndIf		
		EndIf
		// FUNCOES DE TECLA
		SETKEY(VK_F4,{||VX001KEYF4()})
		// FUNCOES DE CONTROLE DE EVENTOS DA GETDADOS
		// VERIfICA A LINHA INTEIRA DA ACOLS (CHAMADA NA TROCA ENTRE LINHAS)
		cLinOk        :="VX001LINOK('"+xTIPDOC+"')"
		// VERIfICA CADA UM DOS CAMPOS (CHAMADA NA TROCA ENTRE CAMPOS)
		cFieldOk      :="VX001FIELDOK()"
		// VERIfICA TODA A ACOLS
		cTudoOk		  :="VX001TUDOK("+strzero(nOpc,1)+",'"+xTIPDOC+"')"
		If cPaisLoc $ "ARG,MEX" .and. nOpc == 4 // Alterar
			cTudoOk   += " .and. VX0010101_Valida_TES_ARG('"+cTpFatR+"',4)"		
		EndIf
		// COPIA VETORES DA ACOLS MONTADA PARA AS VARIAVEIS PADRAO DA ACOLS
		aCols	:= aClone(aColsV)
		aHeader	:= aClone(aHeaderV)
		// MONTAGEM DA TELA
		// VARIAVEIS PARA DIVISAO DAS LINHAS NA ABA UM DO FOLDER
		dy5 := (aPosAba1[1,4] - aPosAba1[1,2])/5	// STEP DA POSICAO INICIAL
		sl5 := (aPosAba1[2,4] - aPosAba1[2,2])/5	// LARGURA DA CELULA
		sc5 :=  aPosAba1[2,3] - aPosAba1[2,1]		// COMPRIMENTO DA CELULA
		//#############################################################################
		//# Monta a tela da nota fiscal de entrada enchoice + acols + folders         #
		//#############################################################################
		DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (cCadastro) Of oMainWnd PIXEL //Documento de Saida
		oDlg:lEscClose := .F.
		//#############
		//# ENCHOICE  #
		//#############
		dData := ddatabase
		dyc7 := (aPosAbaCab[1,4] - aPosAbaCab[1,2]) / 7	// STEP DA POSICAO INICIAL
		scc7 := aPosAbaCab[2,3] - aPosAbaCab[2,1]		// COMPRIMENTO DA CELULA
		spc := 45
		// L I N H A  1
		// FSX_POSCPO("VVF_FORPRO","oSayE11",aPosAbaCab[1,1],aPosAbaCab[1,2],spc,"aCombo")
		// FSX_POSCPO("VVF_DATMOV","oSayE12",aPosAbaCab[1,1],aPosAbaCab[1,2]+2.5*dyc7,spc)
		// FSX_POSCPO("VVF_DATEMI","oSayE13",aPosAbaCab[1,1],aPosAbaCab[1,2]+5*dyc7,spc)
		// L I N H A  2

		If nOpc == 3 // Somente INCLUIR
			If cOpeMov $ "02"
				M->VV0_CLIFOR := "C"    
				cCFWhen := .f.
				If lMV_FILTRF .and. !Empty(cMV_PAR02)
					aCliLjDest := oFilHlp:GetCodCli(cMV_PAR02, .T.) //  Busca Codigo e Loja de Cliente da Filial Destino
					M->VV0_CODCLI := aCliLjDest[1]
					M->VV0_LOJA	  := aCliLjDest[2]
				EndIf
			Else
				if cOpeMov $ "4"
					M->VV0_CLIFOR := "F"
				EndIf
				cCFWhen := "(Empty(M->VV0_CODCLI) .or. Empty(M->VV0_LOJA))"
			Endif
		EndIf

		oTSCEnch := TScrollBox():New(oDlg ,aPosObj[1,1] , aPosObj[1,2] , aPosObj[1,3] - aPosObj[1,1], aPosObj[1,4] - aPosObj[1,2], .t. , , .t. )
		nAJLinha := 4 - aPosAbaCab[1,1]
		For nCntFor := 1 to Len(aPosAbaCab)
			aPosAbaCab[nCntFor,1] += nAJLinha
		Next nCntFor

		nPosCpo := 1
		nPosLin := 2
		FSX_POSCPO("VV0_CLIFOR","oSayE20",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,"aCliFor",,,,"oTSCEnch","oGetE20",cCFWhen)
		FSX_POSCPO("VV0_NUMPED","oSayE33",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE33")

		++nPosCpo
		++nPosLin
		// L I N H A  3
		If ! Empty(M->VV0_CLIFOR)
			cCliForA := M->VV0_CLIFOR
		Endif
		If cOpeMov $ "01"
			FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,,STR0004,"SA1",,"oTSCEnch","oGetE21")//Cliente
			FSX_POSCPO("VV0_LOJA",	"oSayE22",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,"VX001VALCLI()","oTSCEnch","oGetE22")
		ElseIf cOpeMov $ "2" // TRANSFERENCIA
			If cPaisLoc $ "ARG,MEX"
				FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,,STR0004,"A1VXTA","VXA014VALCLI()","oTSCEnch","oGetE21")//Cliente
			Else
				FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,,STR0004,"A1VXTR","VXA014VALCLI()","oTSCEnch","oGetE21")//Cliente
			EndIf
			FSX_POSCPO("VV0_LOJA",	"oSayE22",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,"VXA014VALCLI() .AND. VX001VALCLI()","oTSCEnch","oGetE22")
		Else
			if nOpc <> 2
				FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,,STR0004,"SA1",,"oTSCEnch","oGetE21")//Cliente
				FSX_POSCPO("VV0_CODCLI","oSayE18",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,,STR0005,"FOR",,"oTSCEnch","oGetE21")//Fornecedor
				oSayE18:lVisible := .f.
			Else 
				if cCliForA == "C"
					FSX_POSCPO("VV0_CODCLI","oSayE21",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,,STR0004,"SA1",,"oTSCEnch","oGetE21")//Cliente
				Else
					FSX_POSCPO("VV0_CODCLI","oSayE18",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2],spc,,STR0005,"FOR",,"oTSCEnch","oGetE21")//Fornecedor
				Endif
			Endif	
			FSX_POSCPO("VV0_LOJA",	"oSayE22",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE22")
		EndIf
		FSX_POSCPO("VV0_NOMCLI","oSayE23",aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,STR0006,,,"oTSCEnch","oGetE23")//Nome
		// L I N H A  4
		++nPosCpo
		++nPosLin
		FSX_POSCPO("VV0_CODBCO","oSayE41",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE41")
		FSX_POSCPO("VV0_CODAGE","oSayE42",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE42")
		FSX_POSCPO("VV0_INDPRE","oSayE43",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,"aIndPre",,,,"oTSCEnch","oGetE43")
		// L I N H A  5
		If lCondPag
			++nPosCpo
			++nPosLin
			FSX_POSCPO("VV0_FORPAG","oSayE51",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE51")
			FSX_POSCPO("VV0_DESFPG","oSayE52",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE52")
			FSX_POSCPO("VV0_NATFIN","oSayE53",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE53")
		EndIf
		// L I N H A  6
		++nPosCpo
		++nPosLin
		FSX_POSCPO("VV0_CODVEN","oSayE61",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE61")
		FSX_POSCPO("VV0_NOMVEN","oSayE62",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE62")
		FSX_POSCPO("VV0_CODTRA","oSayE53",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE63")
		// L I N H A  7
		++nPosCpo
		++nPosLin
		FSX_POSCPO("VV0_PESOL", "oSayE71",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE71")
		FSX_POSCPO("VV0_PBRUTO","oSayE72",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE72")
		FSX_POSCPO("VV0_VOLUME","oSayE73",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE73")
		// L I N H A  8
		++nPosCpo
		++nPosLin
		FSX_POSCPO("VV0_ESPECI","oSayE81",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE81")
		FSX_POSCPO("VV0_VEICUL","oSayE82",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE82")
		FSX_POSCPO("VV0_SEGURO","oSayE83",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE83")
		// L I N H A  9
		++nPosCpo
		++nPosLin
		FSX_POSCPO("VV0_DESACE","oSayE91",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE91")
		FSX_POSCPO("VV0_VALFRE","oSayE92",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE92")
		FSX_POSCPO("VV0_TPFRET","oSayE93",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,"aTipoFre",,,,"oTSCEnch","oGetE93")

		// L I N H A  Adicinada
		If cCliForA == "C"
			++nPosCpo
			++nPosLin
			FSX_POSCPO("VV0_TIPOCL","oSayE100",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,"aTipoCli",,,"VX001VLDENC()","oTSCEnch","oGetE100")
		Endif 

		// L I N H A  10
		++nPosCpo
		++nPosLin
		FSX_POSCPO("VV0_CLIENT","oSayE94",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE94")
		FSX_POSCPO("VV0_LOJENT","oSayE95",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE95")
		FSX_POSCPO("VV0_CODA1U","oSayE96",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE96")

		If VV0->(FieldPos("VV0_CLIREM") > 0) .AND. VV0->(FieldPos("VV0_LOJREM") > 0)
			++nPosCpo
			++nPosLin
			FSX_POSCPO("VV0_CLIREM","oSayE95",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE95")
			FSX_POSCPO("VV0_LOJREM","oSayE96",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE96")
		EndIf

		// L I N H A  11
		++nPosCpo
		++nPosLin
		FSX_POSCPO("VV0_MENPAD","oSayE101",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE101")
		FSX_POSCPO("VV0_MENNOT","oSayE102",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+2.5*dyc7,spc,,,,,"oTSCEnch","oGetE102")		
		if cPaisLoc == "ARG"
			FSX_POSCPO("VV0_PROVEN","oSayE103",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE103")
		ElseIf cPaisLoc == "MEX"
			FSX_POSCPO("VV0_USOCFD","oSayE103",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2]+5*dyc7,spc,,,,,"oTSCEnch","oGetE103")
			++nPosCpo
			++nPosLin
			FSX_POSCPO("VV0_TPDOC","oSayE104",aPosAbaCab[ nPosCpo ,1],aPosAbaCab[nPosLin,2],spc,,,,,"oTSCEnch","oGetE104")
		endif

		// L I N H A  12
		++nPosCpo
		oSayE101 := TSay():New(aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2],	{|| RetTitle("VV0_OBSERV") },oTSCEnch,,oFnt3,,,,.t.,IIf(X3Obrigat("VV0_OBSMEM"),CLR_HBLUE,CLR_BLACK),,spc,8)
		If INCLUI
			@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc GET oVV0ObsMem VAR M->VV0_OBSERV OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 	PIXEL MEMO
		Else
			@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc GET oVV0ObsMem VAR M->VV0_OBSERV OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 	PIXEL READONLY MEMO
		EndIf
		//
		oSayE102 := TSay():New(aPosAbaCab[nPosCpo,1],aPosAbaCab[10,2]+2.5*dyc7,{|| RetTitle("VV0_OBSENF") },oTSCEnch,,oFnt3,,,,.t.,IIf(X3Obrigat("VV0_OBSMNF"),CLR_HBLUE,CLR_BLACK),,spc,8)
		If INCLUI
			@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc+(2.5*dyc7) GET oVV0ObsMem VAR M->VV0_OBSENF OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 PIXEL MEMO
		Else
			@ aPosAbaCab[nPosCpo,1],aPosAbaCab[nPosCpo,2]+spc+(2.5*dyc7) GET oVV0ObsMem VAR M->VV0_OBSENF OF oTSCEnch MEMO SIZE (aPosAbaCab[5,2]+2.5*dyc7)-(aPosAbaCab[nPosCpo,2]+spc+5),050 PIXEL READONLY MEMO
		EndIf

		//#############################################################################
		//# GETDADOS                                                                  #
		//#############################################################################
		oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],;
			aPosObj[2,4],nOpc,cLinOK,cTudoOk,"";
			,.t.,,,,,cFieldOk,,,,oDlg)
		//
		If (INCLUI .Or. ALTERA) .and. lManutVV0A
			oGetDados:oBrowse:bDelete := {|| VX001DLIN(),oGetDados:oBrowse:Refresh() }
		Else // NAO DEIXA ALTERAR
			oGetDados:disable() // Nao deixa alterar os Dados
		EndIf
		//
		oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitulo,{},;
			oDlg,,,,.t.,.f.,aPosObj[3,4] - aPosObj[3,2],(aPosObj[3,3]-aPosObj[3,1]))
			cChave1 :=cChave2 :=cChave3 :=cChave4 :=""
		//#############################################################################
		//# FOLDER                                                                    #
		//#############################################################################
		// A B A  1
		@ aPosAba1[1,1],aPosAba1[1,2] LISTBOX olBox FIELDS HEADER ;
			OemToAnsi(STR0015), OemToAnsi(STR0014) COLSIZES sl5*2, sl5*2 ;
			SIZE aPosAba1[5,4] - aPosAba1[1,2], (aPosAba1[5,3] - aPosAba1[1,1] - 20)/0.65;
			OF oFolder:aDialogs[1] PIXEL   //Descricao # valor
		//
		olBox:SetArray(aOrc)
		//
		olBox:bLine := { || {  aOrc[olBox:nAt,2] , FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}

		// A B A  2
		If lCondPag

			oSay21 := TSay():New(aPosAba1[1,1],aPosAba1[1,2],{|| STR0007 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Data Inicial
			oDatIni:= TGet():New(aPosAba1[1,1],aPosAba1[1,2]+dy5,{|u| If(PCount()>0,dDataIni:=u,dDataIni)}, oFolder:aDialogs[2],sl5,sc5,"@D",,,,,,,.T.,,,,,,,,,,"dDataIni")
			//
			oSay22 := TSay():New(aPosAba1[2,1],aPosAba1[2,2],{|| STR0008 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Dias 1a.Parc
			oDias1P:= TGet():New(aPosAba1[2,1],aPosAba1[2,2]+dy5,{|u| If(PCount()>0,nDias1P:=u,nDias1P)}, oFolder:aDialogs[2],sl5,sc5,"@E 9999",,,,,,,.T.,,,,,,,,,,"nDias1P")
			//
			oSay23 := TSay():New(aPosAba1[3,1],aPosAba1[3,2],{|| STR0009 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Parcelas
			oParcel:= TGet():New(aPosAba1[3,1],aPosAba1[3,2]+dy5,{|u| If(PCount()>0,nParcel:=u,nParcel)}, oFolder:aDialogs[2],sl5,sc5,"@E 9999",,,,,,,.T.,,,,,,,,,,"nParcel")
			//
			oSay24 := TSay():New(aPosAba1[4,1],aPosAba1[4,2],{|| STR0010 },oFolder:aDialogs[2],,oFnt1,,,,.t.,CLR_BLUE,,sl5,sc5)//Intervalo
			oInterv:= TGet():New(aPosAba1[4,1],aPosAba1[4,2]+dy5,{|u| If(PCount()>0,nInterv:=u,nInterv)}, oFolder:aDialogs[2],sl5,sc5,"@E 9999",,,,,,,.T.,,,,,,,,,,"nInterv")//nInterv
		
			oDatIni:disable()
			oDias1P:disable()
			oParcel:disable()
			oInterv:disable()

			// BOTOES DO COMO PAGAR
			oBtnCalc:=tButton():New(aPosAba1[1,1],aPosAba1[1,2]+2*dy5,STR0011,oFolder:aDialogs[2],{||VX001CANPAR(1),VX001ATUCP()},sl5,sc5,,,,.T.)//Calcular
			oBtnDesf:=tButton():New(aPosAba1[2,1],aPosAba1[2,2]+2*dy5,STR0012,oFolder:aDialogs[2],{||VX001CANPAR(0)},sl5,sc5,,,,.T.)//Desfazer
			// LISTBOX DO COMO PAGAR
			@ aPosAba1[1,1],aPosAba1[1,2]+3*dy5 LISTBOX oLbParc FIELDS HEADER STR0013,STR0014 COLSIZES 40,50 SIZE 2*dy5 , aPosAba1[5,3]-aPosAba1[1,1] OF oFolder:aDialogs[2] PIXEL ON DBLCLICK IIf( (INCLUI .Or. ALTERA) .and. lManutVV0A , VX001ALTFIN(oLbParc:nAt) , .t. ) //Data ### Valor - Somente permite alterar se for 1=Fatura ou 2=Remito
			//
			oLbParc:SetArray(aIteParc)
			//
			oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}

			oBtnCalc:disable()
			oBtnDesf:disable()

		EndIf

		// A B A 3
		If lMultMoeda
			// A B A  3
			oSay31 := TSay():New(aPosAba1[1,1], aPosAba1[1,2],;
					{|| RetTitle("VV0_MOEDA") }, oFolder:aDialogs[3],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Moeda

			oMoeda := TGet():New(aPosAba1[1,1], aPosAba1[1,2] + dy5,;
					{|u| If(PCount() > 0, nMoedaCor := u, nMoedaCor)}, oFolder:aDialogs[3], sl5, sc5,;
					X3Picture("VV0_MOEDA"), {|| nMoedaCor <= MoedFin() .And. nMoedaCor <> 0 .And. VX0010026_AtualizaTaxa(oMoeda, oTaxa, oSay31) };
					,,,,,, .T.,,,,,,,,,, "nMoedaCor")
					If lManutVV0A
						oMoeda:lReadOnly := IIF((INCLUI .Or. ALTERA), .f., .t.)
					Else // NAO ALTERAR
						oMoeda:lReadOnly := .t.
					EndIf

			oSay32 := TSay():New(aPosAba1[2,1], aPosAba1[2,2],;
					{|| RetTitle("VV0_TXMOED") }, oFolder:aDialogs[3],, oFnt1,,,, .t., CLR_BLUE,, sl5, sc5) // Taxa Moeda

			oTaxa := TGet():New(aPosAba1[2,1], aPosAba1[2,2] + dy5,;
					{|u| If(PCount() > 0, nTaxaMoeda := u, nTaxaMoeda)}, oFolder:aDialogs[3], sl5, sc5,;
					X3Picture("VV0_TXMOED"), {|| VX001ATUCP()},,,,,, .T.,,,,,,,,,, "nTaxaMoeda")
					If lManutVV0A
						oTaxa:lReadOnly := IIF((INCLUI .Or. ALTERA), .f., .t.)
					Else // NAO ALTERAR
						oTaxa:lReadOnly := .t.
					EndIf
		EndIf	

		// INICIALMENTE APENAS O CABECALHO DA TELA ESTARA HABILITADA QUANDO FOR INCLUSAO
		If INCLUI
			oGetDados:disable()
			oFolder:disable()
		EndIf
		//

		//CALCULA OS IMPOSTOS DA ARGENTINA OU MEXICO NA OP«√O 3=FATURA PELO REMITO OU 4=GERA REMITO DE ENTREGA FUTURA
		If (cPaisLoc == "ARG" .and. (cTpFatR == "3" .or. cTpFatR == "4" .or. nOpc == 2)).Or.(cPaisLoc == "MEX" .and. (cTpFatR == "3" .or. nOpc == 2)) // 3=Fatura pelo Remito / 4=Gera Remito de Entrega Futura
			nOldN := N // Vari·vel N anterior
			__ReadVar := "M->VV0_CODCLI"
			VX001VLDENC()
			VX0010101_Valida_TES_ARG(cTpFatR,If(nOpc == 2, 4, nOpc),.t.)						
			N := nOldN // Vari·vel N anterior
			aOrc := VX0010093_ResumoImpostosArgentina()
			olBox:SetArray(aOrc)
			olBox:bLine := { || {  aOrc[olBox:nAt,2] , FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
		EndIf

		lRet := .f.
		ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg,{|| IIf(&(cTudoOk),lRet := VX001GRV(nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR),IIf(ALTERA,oDlg:End(),.f.))},{||nOpca:=0,oDlg:End()})
		//
	Else
		lRet := .t.
		//################################################################
		//# Monta Enchoice e GetDados automaticamente para a integracao  #
		//################################################################
		aCols	:= {}
		aHeader := aClone(aHeaderV)
		// Cancelamento
		If nOpc == 5
			nRecVV0 := VX0010041_POSVV0(aAutoCab)
			If nRecVV0 <> 0

				lRet := .f.

				VV0->(dbGoTo(nRecVV0))

				aCols := {}
				dbSelectArea("VVA")
				dbSetOrder(1)
				dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
				While !eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VV0->VV0_NUMTRA == VVA->VVA_NUMTRA
					AADD(aCols,Array(nUsadoV+1))

					For nCntFor:=1 to len(aHeader)
						aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
						If aHeader[nCntFor,10]  <> "V"
							&("M->"+aHeader[nCntFor,2]) := FieldGet(FieldPos(aHeader[nCntFor,2]))
						EndIf
					Next

					aCols[Len(aCols),nUsadoV+1]:=.F.
					DbSkip()
				EndDo

				If Len(aCols) > 0
					lRet := VX001GRV(nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR)
				EndIf

			Else
				FMX_HELP(STR0127)
				lRet := .F.
			EndIf
		Else
			If EnchAuto("VV0",aAutoCab)    
				MsGetDAuto(aAutoItens,"VX001LINOK('"+xTIPDOC+"')",	{|| (lRet := VX001TUDOK(nOpc,xTIPDOC)).and.(lRet := VX001GRV(nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR, cSerieNFAutom)) },aAutoCab,nOpc)
			EndIf
		EndIf
	EndIf

EndIf
//
SET KEY VK_F4 TO
Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÖo    |VX001LOADNF | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÖo | Traz dados do folder 1 (dados da nf)                         |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001LOADNF()
Local nCntFor
If VV0->VV0_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	Return
EndIf
//
If VV0->VV0_SITNFI == "0"
	set delete off
EndIf
// INICIALIZA FOLDER 1 (INFORMACOES DA NF)
// COM A MACRO DE VISUALIZACAO (POSICAO 4 DO aOrc)
DBSelectArea("SF2")
DBSetOrder(1)
If cPaisLoc $ "ARG,MEX" .and. Empty(VV0->VV0_NUMNFI) // Argentina ou Mexico e NAO possui Fatura, somente Remito
	DBSeek(xFilial("SF2")+VV0->VV0_REMITO+VV0->VV0_SERREM)
Else
	DBSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
EndIf
for nCntFor := 1 to Len(aOrc)
	aOrc[nCntFor,3] := &(aOrc[nCntFor,4])
next
//
If VV0->VV0_SITNFI == "0"
	set delete on
EndIf
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÖo    |VX001LOADCP | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÖo | Traz dados do folder 2 (dados do como pagar)                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001LOADCP()
//
aIteParc := {}
//
If VV0->VV0_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	aAdd(aIteParc,{ ctod(""), 0 })
	Return
EndIf
//
If !Empty(VV0->VV0_NUMNFI)
	If VV0->VV0_SITNFI == "0"
		set delete off
	EndIf
	DBSelectArea("SF2")
	DBSetOrder(1)
	If DBSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
		//
		If !Empty(SF2->F2_DUPL)
			cAlSE1 := "SQLSE1"
			cQuery := "SELECT SE1.E1_VENCREA, SE1.E1_VALOR "
			cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
			cQuery += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
			cQuery += "SE1.E1_PREFIXO = '"+SF2->F2_PREFIXO+"' AND "
			cQuery += "SE1.E1_NUM = '"+SF2->F2_DUPL+"' "
			cQuery += IIf(VV0->VV0_SITNFI =="0"," AND SE1.D_E_L_E_T_ = '*' "," AND SE1.D_E_L_E_T_=' ' ")
			cQuery += "ORDER BY SE1.E1_VENCREA"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlSE1, .F., .T. )
			While !( cAlSE1 )->( Eof() )
				aAdd(aIteParc,{ stod( (cAlSE1)->( E1_VENCREA )), (cAlSE1)->( E1_VALOR ) } )
				( cAlSE1 )->( DBSkip() )
			EndDo
			( cAlSE1 )->( dbCloseArea() )
		EndIf
		//
	EndIf
	If VV0->VV0_SITNFI == "0"
		set delete on
	EndIf
Else
	aIteParc := VX0010081_Parcelas_VS9() // Levanta o VS9
EndIf
If Empty(aIteParc)
	aAdd(aIteParc,{ ctod(""), 0 })
EndIf
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÖo    |VX001VLDENC | Autor | Luis Delorme          | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÖo | Rotina de validacao da ENCHOICE                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001VLDENC()
//
Local oCliente  := DMS_Cliente():New()
Local oFornece  := OFFornecedor():New()
Local lForn 	:= .f.
Local lVldCGC 	:= .f. //Transferencia ou Agrega e Desagrega
Local nInd := ASCAN(FWLoadSM0(), {|i| i[1] == cEmpAnt .AND. i[2] == cFilant })
Local cM0Cgc := FWLoadSM0()[nInd][18]
Local lAtualParc  := .f. // Atualiza parcela automaticamente?

//
If IsInCallStack("VEIXX002") // Retornar .T. quando for Atendimento de Veiculos
	if ReadVar() $ "M->VV0_PROVEN/"
		return VX002VLDENC()
	endif
	Return .t.
EndIf
//
// INICIALIZA CODIGO DO FORNECEDOR 
If cOpeMov $ "67" .or. FM_PILHA("VEIXA040")
	nnPosCF := ascan(aAutoCab,{|x| x[1] == "VV0_CLIFOR" })
	If nnPosCF > 0
		cCliForA := aAutoCab[nnPosCF,2]
	EndIf
Endif	

If ReadVar() == "M->VV0_CODCLI"
	lVldCGC 	:= cOpeMov == "2" .or. FM_PILHA("VEIXA040") //Transferencia ou Agrega e Desagrega
	lForn := VX00101_ClienteValido(M->VV0_CODCLI, M->VV0_LOJA, cCliForA, cM0Cgc,lVldCGC)
	If lForn .and. !Empty(M->VV0_CODCLI) .and. !Empty(M->VV0_LOJA)
		If cCliForA == "C"
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
		Else
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
		EndIf
	EndIf
	if Empty(M->VV0_LOJA)
		return lForn // se a loja est· em branco retorno e deixo o cara digitar sen„o deixa entrar abaixo que inicia fiscal etc...
	endif
EndIf

// INICIALIZA-SE A FUNCAO FISCAL ASSIM QUE O FORNECEDOR EH ESCOLHIDO
If ReadVar() == "M->VV0_LOJA" .or. lForn
	If Empty(M->VV0_LOJA)
		Return .t.
	EndIf
	If cCliForA == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA)
			Return .f.
		Else
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
		EndIf
		if Empty(M->VV0_NATFIN)
			if !Empty(GetNewPar("MV_NATVEIS",""))
				M->VV0_NATFIN := Left(GetNewPar("MV_NATVEIS","")+space(20),TamSX3("VV0_NATFIN")[1])
			elseif !Empty(SA1->A1_NATUREZ)
				M->VV0_NATFIN := SA1->A1_NATUREZ
			endif
		endif
		If Empty(M->VV0_FORPAG) .and. !Empty(SA1->A1_COND)
			M->VV0_FORPAG := SA1->A1_COND
			lAtualParc := .t.
		EndIf

		IF cPaisLoc $ "ARG,MEX"
			IF EMPTY(M->VV0_PROVEN) .And. cPaisLoc == "ARG"
				M->VV0_PROVEN := SA1->A1_EST
			ENDIF
			IF EMPTY(M->VV0_SERNFI)
				M->VV0_SERNFI :=LocXTipSer('SA1',MVNOTAFIS)							
			ENDIF
		endif

	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		If !DbSeek(xFilial("SA2")+M->VV0_CODCLI+M->VV0_LOJA)
			Return .f.
		Else
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
		EndIf
		if Empty(M->VV0_NATFIN)
			if !Empty(GetNewPar("MV_NATVEIS",""))
				M->VV0_NATFIN := Left(GetNewPar("MV_NATVEIS","")+space(20),TamSX3("VV0_NATFIN")[1])
			elseif !Empty(SA2->A2_NATUREZ)
				M->VV0_NATFIN := SA2->A2_NATUREZ
			endif
		endif
		If Empty(M->VV0_FORPAG) .and. !Empty(SA2->A2_COND)
			M->VV0_FORPAG := SA2->A2_COND
			lAtualParc := .t.
		EndIf

		IF cPaisLoc $ "ARG,MEX"
			if EMPTY(M->VV0_PROVEN) .And. cPaisLoc == "ARG"
				M->VV0_PROVEN := SA2->A2_EST
			endif
			IF EMPTY(M->VV0_SERNFI)
				M->VV0_SERNFI :=LocXTipSer('SA2',MVNOTAFIS)
			ENDIF
		ENDIF

	EndIf
	M->VV0_NOMCLI := IIf(cCliForA == "C",SA1->A1_NOME,SA2->A2_NOME)
	IF empty(M->VV0_TIPOCL)
	   M->VV0_TIPOCL := IIf(cCliForA == "C",SA1->A1_TIPO,'')
	Endif    
	If lAtuFiscal // Atualiza Fiscal
		If !MaFisFound('NF')
			if cCliforA == "C" .and. ( cOpeMov <> "4" .or. ( cOpeMov == "2" .and. Len(aAutoAux) == 0) )
				IF !empty(M->VV0_TIPOCL)
				    MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'C','N',M->VV0_TIPOCL, MaFisRelImp("VEIXX001",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos GenÈricos*/)
				Else
				    MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'C','N',, MaFisRelImp("VEIXX001",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos GenÈricos*/)
				Endif	
			Elseif cCliforA == "F" .and. ( cOpeMov <> "4" .or. ( cOpeMov == "2" .and. Len(aAutoAux) == 0) )
				if cOpeMov$"3567"
					MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'F','B',, MaFisRelImp("VEIXX001",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos GenÈricos*/)
				Else
					MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'F','N',, MaFisRelImp("VEIXX001",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos GenÈricos*/)
				Endif	
			ElseIf cOpeMov $ "4" .or. ( cOpeMov == "2" .and. Len(aAutoAux) > 0) 	//  Devolucao
				MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'F','D',, MaFisRelImp("VEIXX001",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos GenÈricos*/)
			EndIf
			// HABILITA DIGITACAO DOS ITENS CASO A ROTINA NAO SEJA AUTOMATICA
			If !lVX001Auto
				oGetDados:Enable()
				oFolder:Enable()
			EndIf
		Else
			MaFisRef("NF_CODCLIFOR","VX001",M->VV0_CODCLI)
			MaFisRef("NF_LOJA","VX001",M->VV0_LOJA)
			// CHAMAMOS A FUNCAO FIELDOK CADA VEZ QUE ALGUM
			// CAMPO QUE INTREFIRA NO FISCAL FOR ALTERADO
			VX001RECALC()
		EndIf

		if cPaisLoc $ "ARG,MEX"
			MaFisRef('NF_SERIENF',"VX001",M->VV0_SERNFI)
			MaFisRef("NF_UFDEST","VX001",M->VV0_PROVEN)
			MaFisRef("NF_PROVENT","VX001",M->VV0_PROVEN)
		EndIf
	EndIf
	if !Empty(M->VV0_CODAGE)
		FG_Seek("SA6","M->VV0_CODBCO",1,.f.)
		M->VV0_CODAGE := SA6->A6_AGENCIA
	endif
	If !lAtualParc // Se nao atualiza a parcela, deve dar return .t.
		Return .t.
	EndIf
EndIf

If ReadVar() == "M->VV0_TIPOCL" 
	If Empty(M->VV0_TIPOCL)
		Return .t.
	EndIf
	If lAtuFiscal
		if cCliforA == "C" .and. cOpeMov <> "4" 
	    	If !MaFisFound('NF') // Atualiza Fiscal
		    	MaFisIni(M->VV0_CODCLI,M->VV0_LOJA,'C','N',M->VV0_TIPOCL, MaFisRelImp("VEIXX001",{"VV0","VVA"}),,,,,,,,,,,,,,,,,,,,,,,,,,,.T./*Tributos GenÈricos*/)
			Else
				MaFisRef("NF_TPCLIFOR","VX001",SA1->A1_TIPO) 
				VX001RECALC()
			Endif 	
		Endif 	 		
	Endif
Endif 
// QUANDO DIGITAR A FORMA DE PAGAMENTO DEVEMOS ATUALIZAR
// O COMO PAGAR CASO A INTEGRACAO FISCAL EXISTA
If lAtuFiscal .and. ( ReadVar() == "M->VV0_FORPAG" .or. lAtualParc ) // Atualiza Fiscal
	If !MaFisFound('NF')
		If ReadVar() == "M->VV0_FORPAG"
			Return .t.
		EndIf
	Else
		VX001ATUCP()
		If SE4->(FieldPos("E4_MSBLQL")) > 0 .and. SE4->E4_MSBLQL == "1"
			If ReadVar() == "M->VV0_FORPAG"
				HELP(" ",1,"REGBLOQ")
				Return .F.
			Else // lAtualParc
				M->VV0_FORPAG := space(TamSx3("VV0_FORPAG")[1])
			EndIf
		Endif
	EndIf
EndIf

// SE INFORMAR OS CAMPOS VV0_CLIENT E VV0_LOJENT, DEVE CALCULAR OS IMPOSTOS
// PARA O "CLIENTE ENTREGA"
If ReadVar() == "M->VV0_CLIENT"
	lForn := VX00101_ClienteValido(M->VV0_CLIENT, M->VV0_LOJENT, cCliForA, cM0Cgc,lVldCGC)
	If lForn .and. !Empty(M->VV0_CLIENT) .and. !Empty(M->VV0_LOJENT)
		If cCliForA == "C"
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
		Else
			If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
				Return .f.
			EndIf
		EndIf
	EndIf
	if Empty(M->VV0_LOJENT)
		return lForn // se a loja est· em branco retorno e deixo o cara digitar sen„o deixa entrar abaixo que inicia fiscal etc...
	endif
EndIf

//ATUALIZA IMPOSTOS UTILIZANDO O "CLIENTE ENTREGA" COMO REFERENCIA
If lAtuFiscal .and. ReadVar() == "M->VV0_LOJENT" // Atualiza Fiscal
	If MaFisFound('NF')
		MaFisRef("NF_CODCLIFOR","VX001",M->VV0_CLIENT)
		MaFisRef("NF_LOJA","VX001",M->VV0_LOJENT)

		VX001RECALC()
	EndIf
EndIf

//If ReadVar() == "M->VV0_SERNFI"
//	If cPaisLoc == "ARG"
//		MaFisRef('NF_SERIENF',"VX001",M->VV0_SERNFI)
//	EndIf
//endif

If ReadVar() == "M->VV0_PROVEN"
	If !ExistCpo("SX5","12"+M->VV0_PROVEN)
		Return .f.
	EndIf
	If cPaisLoc == "ARG"
		MaFisRef("NF_UFDEST","VX001",M->VV0_PROVEN)
		MaFisRef("NF_PROVENT","VX001",M->VV0_PROVEN)
	EndIf
endif


Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÖo    |VX001CHASSI | Autor | Andre/Manoel          | Data | 19/07/99 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÖo | Funcao de Inclusao de Veiculos atraves da Entrada            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CHASSI()
Local nCntFor
Local cQuery     := ""
Local lAtivoImob := .f.
Local oVeiculos  := DMS_Veiculo():New()
//
If Empty(M->VVA_CHASSI)
	FMX_HELP(STR0125)
	Return .f.
EndIf

// TENTA PROCURAR O CHASSI NO CADASTRO
VV1->(DBSetOrder(2))
lAchou := ( VV1->(DBSeek(xFilial("VV1")+M->VVA_CHASSI)) )
If !lAchou
	FMX_HELP(STR0126)
	Return .f.
Else
	// Chassi Bloqueado
	If oVeiculos:Bloqueado("", M->VVA_CHASSI)
		Return .f. // A mensagem j· È exibida dentro da funÁ„o Bloqueado()
	EndIf
EndIf

cGruVei  := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VV1->VV1_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))

lAtivoImob := VV1->VV1_IMOBI == "1"	

// Verifica se ja houve entrada do VeÌculo
if !lAtivoImob .and. Empty(VV1->VV1_SITVEI) // n„o Ativo OU Ativo e n„o SaÌda por Venda
	FMX_HELP(STR0084,STR0027)
	return .f.
endif

FGX_AMOVVEI(xFilial("VV1"),M->VVA_CHASSI,"VX001CHASSI")

// ##########################################################
// # VERIFICA RESTRICOES DE MOVIMENTACAO PARA VALIDAR       #
// # SE O VEICULO PODE REALIZAR A SAIDA                     #
// ##########################################################
////	SE A ULTIMA MOVIMENTACAO FOR DE SAIDA NAO PODEMOS REALIZAR NENHUMA OUTRA SAIDA
If VV1->VV1_ULTMOV = "S" .AND. !(FM_PILHA("VEIXA040")) //VEIXA040 = Agrega/Desagrega
	DBSelectArea("VV0")
	DBSetOrder(1)
	DBSeek(VV1->VV1_FILSAI+VV1->VV1_NUMTRA)
	cOpeTxt := ""
	Do Case
		Case VV0->VV0_OPEMOV=="0"
			cOpeTxt := STR0016   //VENDA
		Case VV0->VV0_OPEMOV=="2"
			cOpeTxt := STR0017	//TRANSFERENCIA
		Case VV0->VV0_OPEMOV=="3"
			cOpeTxt := STR0018	//REMESSA
		Case VV0->VV0_OPEMOV=="4"
			cOpeTxt := STR0019	//DEVOLUCAO
		Case VV0->VV0_OPEMOV=="5"
			cOpeTxt := STR0020	//CONSIGNACAO
		Case VV0->VV0_OPEMOV=="6"
			cOpeTxt := STR0021	//RETORNO DE REMESSA
		Case VV0->VV0_OPEMOV=="7"
			cOpeTxt := STR0022	//RETORNO DE CONSIGNACAO
		//Case VV0->VV0_OPEMOV=="9"
		//	cOpeTxt := "BAIXA"
	EndCase
	
	if !(VV0->VV0_OPEMOV == "0" .and. cOpemov == "3") .or. (GetNewPar("MV_MIL0007","1") == "0" .and. cOpemov == "3") // Permitida a Saida por Remessa de VeÌculos (0=N„o permitida;1=Permitida)

		FMX_HELP(STR0023 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
				STR0024+" "+cOpeTxt+"." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0025+": " + VV0->VV0_FILIAL +;
				" "+STR0026+":"+Alltrim(VV0->VV0_NUMNFI)+"-"+Alltrim(VV0->VV0_SERNFI),STR0027)//Impossivel continuar. ### A ultima movimentacao do veiculo foi uma SAIDA por ### Filial ### NF ### Atencao
		//
		Return .f.
	endif
EndIf

// VERIFICA SE A FILIAL EH A MESMA DO VEICULO
if !Empty(VV1->VV1_FILENT) .and. Alltrim(VV1->VV1_FILENT) != Alltrim(cFilAnt)
	FMX_HELP(STR0083 + chr(13) + chr(10) + STR0097, STR0027) // " A filial origem do bem n„o condiz com a atual"
	return .f.
endif

If cPaisLoc $ "ARG,MEX" .and. !cOpeMov $ "467" // Argentina ou Mexico e n„o È 4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao
	If VV1->VV1_ULTMOV == "E" // Ultima MovimentaÁ„o foi uma Entrada
		cQuery := "SELECT R_E_C_N_O_ AS RECVVF "
		cQuery += "  FROM "+RetSqlName("VVF")
		cQuery += " WHERE VVF_FILIAL = '"+VV1->VV1_FILENT+"'"
		cQuery += "   AND VVF_TRACPA = '"+VV1->VV1_TRACPA+"'"
		cQuery += "   AND VVF_OPEMOV = '0'" // Entrada por Compra
		cQuery += "   AND VVF_SITNFI = '1'" // Valida
		cQuery += "   AND VVF_TPFATR = '2'" // 2=Remito
		cQuery += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQuery) > 0 // Ultima MovimentaÁ„o: Entrada por Compra Valida e ainda no tem Fatura
			FMX_HELP("VX001CHASSI_ERR001",;
				STR0117,; // A ultima movimentaÁ„o desse VeÌculo/M·quina gerou apenas Remito.
				STR0118) // Necess·rio efetivar a Fatura de Entrada do Remito antes de realizar a SaÌda do VeÌculo/M·quina.
			Return .f.
		EndIf
	EndIf
EndIf

// SE A ULTIMA ENTRADA FOR UMA REMESSA/CONSIGNACAO >DE< TERCEIROS NAO REALIZAR
// NENHUMA SAIDA A NAO SER O RETORNO DESSA REMESSA/CONSIGNACAO
// EXISTEM CASOS EM QUE EH POSSIVEL REALIZAR UMA SAIDA POR REMESSA PARA OUTRA FILIAL ENT√O
// … POSSIVEL FAZER SAÕDA POR REMESSA QUANDO A ULTIMA MOVIMENTA«√O FOR UMA ENTRADA POR REMESSA
VVF->(DBSetOrder(1))
VVF->(DBSeek(VV1->VV1_FILENT+VV1->VV1_TRACPA))
VV1->(DBSeek(xFilial("VV1")+M->VVA_CHASSI))
If VVF->VVF_OPEMOV $ "24"
	If VVF->VVF_OPEMOV=="2"
		cOpeTxt := STR0018	//REMESSA
	Else // VVF->VVF_OPEMOV=="4"
		cOpeTxt := STR0020	//CONSIGNACAO
	EndIf
	// ABAIXO VERIfICAMOS SE TRATA-SE DE UMA MOVIMENTACAO DE
	// SAIDA/ENTRADA PARA REMESSA OU CONSIGNADO (RESPECTIVAMENTE)
	If !((VVF->VVF_OPEMOV = "2" .AND. cOpeMov $ "36") .or. (VVF->VVF_OPEMOV = "4" .AND. cOpeMov $ "57") )

		FMX_HELP(STR0023 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
			STR0029+" " + cOpeTxt + "." +;
			CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0025+": " + VV0->VV0_FILIAL +;
			" "+STR0026+":"+Alltrim(VVF->VVF_NUMNFI)+"-"+Alltrim(VVF->VVF_SERNFI),STR0027)//Impossivel continuar ### A ultima movimentacao do veiculo foi uma ENTRADA por ### Filial ### NF ### Atencao
		Return .f.
	EndIf
EndIf

// VERIfICA SE O CHASSI JA FOI DIGITADO EM UMA LINHA ANTERIOR
For nCntFor := 1 to Len(aCols)
	If nCntFor # n .and. aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] == M->VVA_CHASSI
		FMX_HELP(STR0028)  //Chassi ja digitado
		M->VVA_CHAINT := ""
		aCols[n,FG_POSVAR("VVA_CHAINT")] := ""
		M->VVA_CODTES := ""
		aCols[n,FG_POSVAR("VVA_CODTES")] := ""
		Return .f.
	EndIf
Next

// #######################################################
// # FIM DAS VERIFICACOES DE RESTRICOES DE MOVIMENTACAO  #
// # PARA VALIDAR SE O VEICULO PODE REALIZAR A SAIDA     #
// #######################################################
Do Case
	Case cOpeMov $ "067"
		cTipoMov := "N"
	Case cOpeMov $ "35"
		cTipoMov := "R"
	Case cOpeMov == "2"
		cTipoMov := "T"
	Case cOpeMov == "4"
		cTipoMov := "C"
EndCase
//

FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )

// SETA VARIAVEL FISCAL
If lAtuFiscal // Atualiza Fiscal
	if ! MaFisFound("IT",n) .or. MaFisRet(n,"IT_PRODUTO") <> SB1->B1_COD
		MaFisRef("IT_PRODUTO","VX001",SB1->B1_COD)
		FMX_FISITEMI(n, "VX001", .F.)
		if cPaisLoc == "ARG" .and. MaFisRet(n,"IT_PROVENT") <> M->VV0_PROVEN
			MaFisRef("IT_PROVENT","VX001",M->VV0_PROVEN)
		endif
	EndIf
EndIf

// PREENCHE OS CAMPOS LIGADOS AO VEICULO
M->VVA_CHASSI := aCols[n,FG_POSVAR("VVA_CHASSI")] := VV1->VV1_CHASSI
M->VVA_CHAINT := aCols[n,FG_POSVAR("VVA_CHAINT")] := VV1->VV1_CHAINT
M->VVA_ESTVEI := acols[n,FG_POSVAR("VVA_ESTVEI")] := VV1->VV1_ESTVEI
M->VVA_CODORI := acols[n,FG_POSVAR("VVA_CODORI")] := VV1->VV1_CODORI
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001FIELDOK| Autor |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | FieldOK do aCols - Atualiza os campos com o fiscal.          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001FIELDOK()
Local nCntFor  
Local ni := 0
Local aUltMov := {}
Local nValMerc   := 0
Local cFormTransf:= GetNewPar("MV_CUSTRFV","")

// Ponto de Entrada para o usu·rio fazer a validaÁ„o dos campos.
if ExistBlock("VXX01FOK")
	if !ExecBlock("VXX01FOK",.f.,.f.)
		Return .f.
	Endif
Endif

// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
If lAtuFiscal .and. MaFisFound("IT",n) // Atualiza Fiscal
	if lVX001Auto

		MaFisRef("NF_TPFRETE","VX001"," ")   
		MaFisRef("NF_TPFRETE","VX001",M->VV0_TPFRET)

		If M->VV0_OPEMOV == "6" // Saida por Retorno Remessa
			aUltMov := FM_VEIMOVS( M->VVA_CHASSI , "E" , "2" ) // Posiciona na Entrada por Remessa
			If Len(aUltMov) > 0
				VVF->(DbSetOrder(1))
				If VVF->(MsSeek(aUltMov[1,2]+aUltMov[1,3]))
					SD1->(DbSetOrder(1))
					cProdSB1 := MaFisRet(n,"IT_PRODUTO")
					If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+cProdSB1))
						MaFisRef("IT_NFORI","VX001",SD1->D1_DOC) 
						MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
						MaFisRef("IT_RECORI","VX001",SD1->(RECNO()))
						MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
						MaFisRef("IT_BASEICM","VX001",SD1->D1_BASEICM)
					Endif
				EndIf
			Endif
		EndIf

	Endif
		
	if ReadVar() == "M->VVA_CODTES"              
		
		MaFisRef("NF_TPFRETE","VX001"," ")   
		MaFisRef("NF_TPFRETE","VX001",M->VV0_TPFRET)
	
		if !MaAvalTes("S",M->VVA_CODTES)
			return .f.
		endif
	endif
	//
	if ReadVar() == "M->VVA_CHASSI"      
		If (M->VV0_OPEMOV $ "2.3") .and. VV1->VV1_ESTVEI == "1"  //  2-transferencia de usado ; 3-Remessa de usado
			aUltMov := FM_VEIMOVS( M->VVA_CHASSI , "E"  )
			For ni := 1 to Len(aUltMov)                     
				If aUltMov[ni,5] == "0" // Entrada por Compra
					VVF->(DbSetOrder(1))
					If VVF->(MsSeek(aUltMov[ni,2]+aUltMov[ni,3]))
						SD1->(DbSetOrder(1))
						cProdSB1 := MaFisRet(n,"IT_PRODUTO")				
						If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+cProdSB1))
							MaFisRef("IT_NFORI","VX001",SD1->D1_DOC) 
							MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
							If M->VV0_OPEMOV <> "2" // Diferente de Transferencia, pois Transferencia nao pode pegar a Base da Entrada conforme orientaÁ„o https://tdn.totvs.com/pages/releaseview.action?pageId=567761617
								MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
							EndIf
						Endif
					EndIf
					Exit
				Endif
			Next
		Endif
		//                                     
		If M->VV0_OPEMOV == "2"// 2=TRANSFERENCIA
			if !Empty(cFormTransf)
				nValMerc := FG_FORMULA(cFormTransf)
				If VVA->(FieldPos("VVA_FORMUL")) <> 0 //.and. nValMerc > 0
					M->VVA_FORMUL := cFormTransf
					aCols[n,FG_POSVAR("VVA_FORMUL")] := M->VVA_FORMUL
				Endif
			Endif
			If nValMerc == 0
				iF VV1->VV1_ESTVEI == "1"  //  2-transferencia de usado
					nValMerc := MaFisRet(n,"IT_BASVEIC")
				Else
					nValMerc := M->VVA_VALVDA
				Endif
			Endif
			MaFisRef("IT_VALMERC","VX001",nValMerc)
		ElseIf M->VV0_OPEMOV $ "35"	// 3=REMESSA / 5=CONSIGNADO
			nValMerc := 0
			//
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			//
			cQryAlias := GetNextAlias()
			cQuery := "SELECT B2_CM1 FROM "+RetSqlName("SB2")
			cQuery += " WHERE B2_FILIAL ='"+xFilial("SB2")+"'"
			cQuery += " AND B2_QATU > 0 "
			cQuery += " AND B2_COD ='"+SB1->B1_COD+"'"
			cQuery += " AND D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
			//
			(cQryAlias)->(dbGoTop())
			if !(cQryAlias)->(eof())
				nValMerc := (cQryAlias)->(B2_CM1)
			endif
			(cQryAlias)->(dbCloseArea())
			//
			MaFisRef("IT_VALMERC","VX001",nValMerc)
			//
		endif
		//
		M->VVA_CENCUS := aCols[n,FG_POSVAR("VVA_CENCUS")] := VV1->VV1_CC
		M->VVA_CONTA  := aCols[n,FG_POSVAR("VVA_CONTA")]  := VV1->VV1_CONTA
		M->VVA_CLVL   := aCols[n,FG_POSVAR("VVA_CLVL")]   := VV1->VV1_CLVL
		M->VVA_ITEMCT := aCols[n,FG_POSVAR("VVA_ITEMCT")] := VV1->VV1_ITEMCC
		
	endif
	//
	If ReadVar() == "M->VVA_VALMOV"
		If M->VV0_OPEMOV == "2"// 2=TRANSFERENCIA
			If VVA->(FieldPos("VVA_FORMUL")) <> 0
				if !Empty(M->VVA_FORMUL)
					If M->VVA_VALMOV <> FG_FORMULA(M->VVA_FORMUL)
						M->VVA_FORMUL := aCols[n,FG_POSVAR("VVA_FORMUL")] := Space(TamSx3("VVA_VALMOV")[1])
					Endif
				Endif
			Endif
		Endif
	Endif
	//
	If ReadVar() == "M->VVA_FORMUL"
		If M->VV0_OPEMOV == "2"// 2=TRANSFERENCIA
			nValMerc := M->VVA_VALMOV := FG_FORMULA(M->VVA_FORMUL)
			MaFisRef("IT_VALMERC","VX001",nValMerc)
		Endif
	Endif
	//
	If ReadVar() == "M->VVA_OPER"
		cTESSai := MaTesInt(2,M->VVA_OPER,M->VV0_CODCLI,M->VV0_LOJA,iif(cCliForA == "C","C","F"),SB1->B1_COD)
		MaFisRef("IT_TES","VX001",cTESSai)
		MaFisRef("NF_TPFRETE","VX001"," ")   
		MaFisRef("NF_TPFRETE","VX001",M->VV0_TPFRET)
	Endif
	// PROBLEMA DO TES NA ROTINA AUTOMATICA
	if lVX001Auto
		cTesTemp := MaFisRet(n,"IT_TES")
		if !Empty(M->VVA_CODTES)  .and. Empty(cTesTemp)
			MaFisRef("IT_TES","VX001",M->VVA_CODTES)
		endif
	endif
	M->VVA_CODTES := aCols[n,FG_POSVAR("VVA_CODTES")] := MaFisRet(n,"IT_TES")
	M->VVA_VALUNI := M->VVA_VALMOV := MaFisRet(n,"IT_VALMERC")
	MaFisRef("IT_QUANT","VX001",1)
	MaFisRef("IT_PRCUNI","VX001",M->VVA_VALMOV)
	MaFisRef("IT_DESCONTO","VX001",M->VVA_VALDES) 
	aCols[n,FG_POSVAR("VVA_VALMOV")] := M->VVA_VALMOV
	M->VVA_VALDES := aCols[n,FG_POSVAR("VVA_VALDES")] := MaFisRet(n,"IT_DESCONTO")
	If (cPaisLoc == "BRA")
		MaFisRecal("",n)
		M->VVA_ALIIPI := acols[n,FG_POSVAR("VVA_ALIIPI")] := MaFisRet(n,"IT_ALIQIPI")
		M->VVA_VBAICM := aCols[n,FG_POSVAR("VVA_VBAICM")] := MaFisRet(n,"IT_BASEICM")
		M->VVA_ALIICM := aCols[n,FG_POSVAR("VVA_ALIICM")] := MaFisRet(n,"IT_ALIQICM")
		M->VVA_ICMVEN := aCols[n,FG_POSVAR("VVA_ICMVEN")] := MaFisRet(n,"IT_VALICM")
		M->VVA_PISVEN := aCols[n,FG_POSVAR("VVA_PISVEN")] := MaFisRet(n,"IT_VALPS3")
		M->VVA_COFVEN := aCols[n,FG_POSVAR("VVA_COFVEN")] := MaFisRet(n,"IT_VALCF3")
	endif
	//
	// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
	//
	if cPaisLoc $ "ARG,MEX"
		aOrc := VX0010093_ResumoImpostosArgentina()	
	else
		for nCntFor := 1 to Len(aOrc)
			aOrc[nCntFor,3] := &(aOrc[nCntFor,1])
		next
	endif
	if !lVX001Auto
		olBox:nAt := 1
		olBox:SetArray(aOrc)
		olBox:bLine := { || {  aOrc[olBox:nAt,2],;
		FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
		olBox:SetFocus()
		olBox:Refresh()
	endif
	//
	// ATUALIZA COMO PAGAR
	VX001ATUCP()
	//
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001LINOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Validacao da Linha do aCols                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001LINOK(xTIPDOC)
Local nCntFor   := 0
Local cCposObr  := ""
Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )
//
if ExistBlock("VXX01LOK")
	if !ExecBlock("VXX01LOK",.f.,.f.)
		Return .f.
	Endif
Endif
//
// pula registros deletados
If aCols[n,len(aHeader)+1]
	Return .t.
EndIf

// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cCposObr := "VVA_CODTES/"
EndIf
For nCntFor:=1 to Len(aHeader)
	If ( aHeader[nCntFor,2] $ cCposObr .or. X3Obrigat(aHeader[nCntFor,2]) ) .and. Empty(aCols[n,nCntFor])
		Help(" ",1,"OBRIGAT2",,RetTitle(aHeader[nCntFor,2]),4,1)
		Return .f.
	EndIf
Next

DBSelectArea("VV1")
DBSetOrder(2)
If DBSeek(xFilial("VV1")+aCols[n,FG_POSVAR("VVA_CHASSI")])
	If VV1->VV1_ULTMOV = "S"
		DBSelectArea("VV0")
		DBSetOrder(1)
		DBSeek(VV1->VV1_FILSAI+VV1->VV1_NUMTRA)
		if VV0->VV0_OPEMOV == "0" .and. cOpemov == "3"
			DBSelectArea("SF4")
			DBSetOrder(1)
			if dbSeek(xFilial("SF4")+aCols[n,FG_POSVAR("VVA_CODTES")])
				if SF4->F4_ESTOQUE == "S"
					FMX_Help(STR0060,STR0061)
					return .f.
				endif
			endif
		endif
	endif
	If !VX001VLDESTQ( n , .t. ) // Validar Estoque quando o TES movimentar Estoque
		Return .f.
	EndIf
EndIf

// CASO ESTEJA NA ROTINA AUTOMATICA DEVEMOS CHAMAR O FIELDOK
// UMA VEZ PARA INICIALIZAR AS VARIAVEIS FISCAIS
If lVX001Auto
	VX001FIELDOK()
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001TUDOK  | Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Verificacao Final                                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function VX001TUDOK(nOpc,xTIPDOC)
Local nCntFor   := 0
Local cCposObr  := ""
Local nValor    := MaFisRet(,"NF_BASEDUP")
Local oVeiculos := DMS_Veiculo():New()
Default xTIPDOC := "1" // Gerar ? ( 1 = NF / 2 = Mov.Interna (SD3) )

If FindFunction('FGX_ValidRequiredFieds')
	For nCntFor := 1 To Len(aCols)
		VV1->(DBSetOrder(1))
		If VV1->(DBSeek(xFilial("VV1") + aCols[nCntFor][2])) // Posicionar na VV1 com o CHAINT do aCols
			If !FGX_ValidRequiredFieds(VV1->(Recno()), "VV1", /*lShowMessage*/)
				VA0700113_AlteracaoChassi()
				Return (.F.)
			Endif
		Endif
	Next
Endif

If nOpc == 4 .or. nOpc == 2 .or. nOpc == 5
	Return .t.
EndIf

If xTIPDOC == "2" // 2 = Mov.Interna (SD3)
	Return .t.
EndIf
//
if ExistBlock("VXX01TOK")
	if !ExecBlock("VXX01TOK",.f.,.f.)
		Return .f.
	Endif
Endif
//
// SE DER OK NA JANELA DIRETO DO ACOLS NAO PASSA PELO LINOK. CHAMA-SE A FUNCAO AQUI
If !VX001LINOK(xTIPDOC) .and. !lVX001Auto
	Return .f.
EndIf
//
// Campos Obrigatorios quando NF, mesmo quando nao estao marcados como Obrigatorio no SX3 //
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
	cCposObr := "VV0_CODVEN/VV0_FORPAG/"
EndIf
// VERIFICACOES DOS CAMPOS OBRIGATORIOS DA ENCHOICE
For nCntFor:=1 to Len(acpoEncS)
	If ( acpoEncS[nCntFor] $ cCposObr .or. X3Obrigat(acpoEncS[nCntFor]) ) .and. Empty(&("M->"+acpoEncS[nCntFor]))
		Help(" ",1,"OBRIGAT2",,acpoEncS[nCntFor],4,1)
		Return .f.
	EndIf
Next
// Validar ESTOQUE de TODAS as linhas da aCols
If !VX001VLDESTQ( 0 , .t. ) // Validar Estoque quando o TES movimentar Estoque
	Return .f.
EndIf

If lAtuFiscal // Atualiza Fiscal
	If !MaFisFound('NF')
		// TRANSFORMAR EM HELP
		HELP(" ",1,"NVAZIO",,STR0030,4,0) //Favor preencher os dados da nota fiscal
		Return .f.
	EndIf
	If nValor # MaFisRet(,"NF_BASEDUP") 
		if !M->VV0_OPEMOV$"467"
			// TRANSFORMAR EM HELP
			HELP(" ",1,"NVAZIO",,STR0031,4,0) //Valor dos tutulos diverge do valor da nota fiscal
			Return .f.
		Else                            
			nValor := MaFisRet(,"NF_BASEDUP") 
		Endif
	EndIf
EndIf

// Validar Data da Movimentacao de cada Veiculo
For nCntFor := 1 to len(acols)
	If !aCols[nCntFor,len(aHeader)+1]
		If oVeiculos:DtUltimaMovimentacao(aCols[nCntFor,FG_POSVAR("VVA_CHASSI")]) > M->VV0_DATMOV // Valida referente a Data do Movimento
			FMX_HELP("VX001TUDOK",STR0090 + CRLF + CRLF + aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] ) // Chassi com movimentacao posterior a data deste movimento.
			Return .f.
		EndIf
	EndIf	
next

// COMPATIBILIZA«√O COM O VEIVM030
if ExistBlock("VM030ANF") .and. M->VV0_OPEMOV$"57"
	if !ExecBlock("VM030ANF",.f.,.f.)
		Return(.f.)
	Endif
Endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001ALTFIN  |Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Permite alteracao das datas dos titulos                      |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001ALTFIN(nCel)
//
Local nOpca := 0
Local nPar1  := 0
Local nSoma1 := nSoma2 := nSoma3 := 0
Local dNovaData := aIteParc[nCel,1]
Local nNovoValor:= aIteParc[nCel,2]
Local valorMax := 0
Local nCntFor
//
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VV0_FORPAG)
//
For nCntFor :=1 to Len(aIteParc)
	nSoma1 += aIteParc[nCntFor,2]
Next
//
For nCntFor := 1 to nCel - 1
	valorMax += aIteParc[nCntFor,2]
Next
//
valorMax := nSoma1 - valorMax - (Len(aIteParc)-nCel)
//
If Empty(dNovaData) .and. (nNovoValor = 0)
	Return
EndIf

DEFINE MSDIALOG oDlgFin TITLE STR0009 From 18,43 to 25,76 of oMainWnd //Parcelas

@ 010, 025 SAY STR0013 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE//data
@ 010, 048 MSGET oNovaData  VAR dNovaData  PICTURE "@D" VALID !EMPTY(dNovaData) ;
SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_HBLUE WHEN (Alltrim(SE4->E4_TIPO)$"A/9")
@ 021, 025 SAY   STR0014 SIZE 40,08 OF oDlgFin PIXEL COLOR CLR_BLUE //valor
@ 021, 048 MSGET oNovoValor VAR nNovoValor PICTURE "@E 999,999,999.99" ;
VALID (nNovoValor > 0 .AND. nNovoValor<=valorMax )  SIZE 58,08 OF oDlgFin ;
PIXEL COLOR CLR_HBLUE WHEN (nCel # Len(aIteParc).and.Alltrim(SE4->E4_TIPO)$"A/9")
//
DEFINE SBUTTON FROM 38,60 TYPE 1 ACTION (nOpca := 1,oDlgFin:End()) ENABLE OF oDlgFin 
DEFINE SBUTTON FROM 38,95 TYPE 2 ACTION (nOpca := 2,oDlgFin:End()) ENABLE OF oDlgFin 
ACTIVATE MSDIALOG oDlgFin CENTER

If nOpca == 1
	aIteParc[nCel,1] := dNovaData
	aIteParc[nCel,2] := nNovoValor
	For nCntFor:=1 to nCel
		nSoma2 := nSoma2 + aIteParc[nCntFor,2]
	Next
	nPar1:= (Len(aIteParc)-nCel)
	nSoma3 := Round( (nSoma1 - nSoma2) / nPar1 ,2)
	nResto := nSoma2
	For nCntFor:=nCel+1 to Len(aIteParc)
		nResto += nSoma3
		aIteParc[nCntFor,2] := nSoma3
	Next
	nResto := nSoma1 - nResto
	If nCel+1 <= Len(aIteParc)
		aIteParc[nCel+1,2] += nResto
	EndIf
	//
	oLbParc:Refresh()
EndIf
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001ATUCP  |Autor  |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Atualiza como pagar                                          |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001ATUCP()
//
If cPaisLoc $ "ARG,MEX" .and. M->VV0_TPFATR == "2" // 2=Remito
	Return
EndIf
//
DBSelectArea("SE4")
DBSetOrder(1)
DBSeek(xFilial("SE4")+M->VV0_FORPAG)
//
If lAtuFiscal // Atualiza Fiscal
	If lVX001Auto
		If !Alltrim(SE4->E4_TIPO) $ "A/9"
			aIteParc := Condicao(MaFisRet(,"NF_BASEDUP"),M->VV0_FORPAG,,M->VV0_DATEMI)
		EndIf
		//
		Return
	EndIf
	If !Alltrim(SE4->E4_TIPO) $ "A/9"
		dDataIni := ctod(" ")
		nDias1P := 0
		nParcel := 0
		nInterv := 0
		aIteParc := Condicao(MaFisRet(,"NF_BASEDUP"),M->VV0_FORPAG,,M->VV0_DATEMI)
		oDatIni:disable()
		oDias1P:disable()
		oParcel:disable()
		oInterv:disable()
		oBtnCalc:disable()
		oBtnDesf:disable()
	Else
		If dDataIni == ctod(" ") .and. nDias1P==0 .and. nParcel==0 .and. nInterv==0
			dDataIni := ddatabase
			oDatIni:enable()
			oDias1P:enable()
			oParcel:enable()
			oInterv:enable()
			oBtnCalc:enable()
			oBtnDesf:enable()
			nParcel := 1
			If Len(aIteParc)<=1
				VX001CALPAR()
			Endif
		Else
			If Len(aIteParc)<=1
				VX001CALPAR()
			Endif
		EndIf
	EndIf
EndIf
If Empty(aIteParc)
	aIteParc := { { ctod(""),0 } }
EndIf
oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:refresh()
oDatIni:refresh()
oDias1P:refresh()
oParcel:refresh()
oInterv:refresh()
oGetDados:oBrowse:Refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-------------
----------+------+----------+##
##|FunáÑo    |VX001CALPAR  |Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Calcula as parcelas do como pagar                            |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CALPAR()
Local nCntFor := 0
Local nValor  := 0
If lAtuFiscal // Atualiza Fiscal
	nValor := MaFisRet(,"NF_BASEDUP")
EndIf
if nValor == 0
	aIteParc := {}
	return .t.
endif
//
If Empty(M->VV0_FORPAG)
	MsgStop(STR0032,STR0027)//A forma de pagamento nao foi preenchida.","Atencao
	Return
EndIf
If (nParcel < 1) .or. (dDataIni < ddatabase) .or. (nParcel > nValor)
	MsgStop(STR0033,STR0027)//Os dados para calculo das percelas nao foram preenchidos corretamente.","Atencao
	Return
EndIf

aIteParc := {}
nValBase := Round(nValor / nParcel ,2)

For nCntFor := 1 to nParcel
	aAdd(aIteParc, {(dDataIni + nDias1P) + ((nCntFor - 1)*nInterv ) , nValBase} )
Next
//
nResto := nValor - (nValBase * nParcel)
//
aIteParc[1,2] += nResto
//
oLbParc:nAt := 1
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:refresh()
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001CANPAR  |Autor |  Manoel               | Data | 14/11/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Cancela como pagar                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CANPAR(nTp)
Default nTp := 0
aIteParc := { { ctod(""),0 } }
If nTp == 0
	dDataIni := ctod(" ")
	nDias1P := 0
	nParcel := 0
	nInterv := 0
Endif
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:refresh()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001GRV    |Autor  |  Luis Delorme         | Data | 20/12/08 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Gravacao da nota fiscal de saida                             |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001GRV(nOpc,xSX5NumNota,xTIPDOC,xCodVDV,cRotOrigem,cTpFatR, cSerieNFAutom)
Local lRet := .f.
Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV     := ""
Default cTpFatR     := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura pelo Remito
Default cSerieNFAutom := ""
//
lMsErroAuto := .f.
//
If nOpc == 5 .and. cPaisLoc $ "BRA|ARG|MEX"
	//#############################################################################
	//# CANCELAMENTO DA NOTA FISCAL                                               #
	//#############################################################################
	lRet := VX001CANCEL(cRotOrigem)
	If !lRet
		If lMsErroAuto
			MostraErro()
		EndIf
		Return .f.
	EndIf
ElseIf nOpc == 3 .or. nOpc == 4
	//#############################################################################
	//# EMISSAO DA NOTA FISCAL                                                    #
	//#############################################################################
	// SE A ROTINA FISCAL SE PERDEU POR ALGUM MOTIVO O PROCESSO DEVE SER REINICIADO
	If lAtuFiscal .and. !MaFisFound('NF') .and. cTpFatR $ "1/2" // Atualiza Fiscal | 1=Fatura / 2=Remito
		MsgStop(STR0027+;
		" "+STR0078)
		Return .f.
	EndIf
	// Ponto de Entrada Antes da Gravacao da Nota Fiscal
	If ExistBlock("VX001ANF")
		If !ExecBlock("VX001ANF",.f.,.f.)
			Return .f.
		Endif
	EndIf
	//
	lRet := VX001EMINF(xSX5NumNota,xTIPDOC,xCodVDV,nOpc,cRotOrigem,cTpFatR, cSerieNFAutom)
	If !lRet
		If !lVX001Auto
			MostraErro()
		EndIf
		Return .f.
	EndIf
	//
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	If ExistBlock("VX001DNF")
		ExecBlock("VX001DNF",.f.,.f.)
	EndIf
EndIf
//
If !lVX001Auto
	oDlg:End()
EndIf
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001EMINF  | Autor |  Luis Delorme         | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo |Gravacao e Integracao de Veiculos Normais                     |##
##+----------+--------------------------------------------------------------+##
##|Uso       |Veiculos  (Modelo3)                                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001EMINF(xSX5NumNota,xTIPDOC,xCodVDV,nOpc,cRotOrigem,cTpFatR, cSerieNFAutom)
Local nCntFor, nCntFor2, x_

Local aVetAtuSD2    := {}

Local nProdAgrup    := 0

Local aUltMov       := {}
                            
Local ni            := 0 
Local nCustoVeiculo := 0

Local aSB1SD3       := {}
Local nModBkp
Local cModBkp

Local lOkTit        := .t.
Local nRecSF2       := 0
Local nX            := 0

Local cFilDest := "" // Filial de Destino ( Filial da Entrada )
Local cObs     := ""
Local lErro    := .F.
Local cVs9Numid := ""
Local aPvlNfs   := {}
Local aBloqueio := {}
Local aReg      := {}

Local cMV01
Local cMV02
Local cMV03
Local cMV04
Local cMV05
Local cMV06
Local cMV07
Local cMV08
Local cMV09
Local cMV10
Local cMV11
Local cMV14
Local nTpFatura     := 0
Local lCriaVV0A  := .t.
Local cQuery        := ""
// Vari·veis Remito Argentina
Local cF2TIPO    := ""
Local cF2FORMUL  := ""
Local cF2DOC     := ""
Local cF2SERIE   := ""
Local cF2CLIENTE := ""
Local cF2LOJA    := ""
Local cF2TIPOCLI := ""
Local cF2ESPECIE := ""
Local nF2DESCONT := 0
Local nF2VALBRUT := 0
Local nF2VALFAT  := 0
Local nF2FRETE   := 0
Local nF2SEGURO  := 0
Local nF2DESPESA := 0
Local cF2PREFIXO := ""
Local dF2EMISSAO := CtoD("")
Local cF2HORA    := ""
Local cF2CLIENT  := ""
Local cF2LOJENT  := ""
Local cF2NFORI   := ""
Local cF2SERIORI := ""
Local nF2MOEDA   := 0
Local nF2TXMOEDA := 0
Local cF2COND    := ""
Local cF2VEND1   := ""
Local cF2NATUREZ := ""
Local cF2PV      := ""
Local cF2TIPODOC := ""
Local cD2ITEM    := ""
Local cD2COD     := ""
Local nD2QUANT   := 0
Local nD2PRCVEN  := 0
Local nD2TOTAL   := 0
Local cD2TES     := ""
Local cD2NFORI   := ""
Local cD2SERIORI := ""
Local cD2ITEMORI := ""
Local cPergFat   := ""
Local nVerParFat := 1 // Mostrar Parametros do Faturamento no momento da geracao da NF
//
Local nTipMoed   := 1 // 1 = Moeda do Pedido / 2 = Moeda Informada (troca)
Local nMoedSC5   := 0 
Local nMoedFat   := 0
Local cParcela   := ""
//
// Vari·veis Remito Argentina
Local aCabSF2       := {}
Local aItemSD2      := {}
Local aItensSD2     := {}
Local nTipoX        := 0
Local aPergX        := {}
Local aPergsX       := {}
Local aNumeroX      := {}
If cPaisLoc $ "ARG,MEX" .and. cOpeMov $ "467" // 4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao
	Private cEspecie    := "RCD" // Vari·vel Private utilizada na funÁ„o LocXSx5NF
	Private lGerarCFD   := .F.   // Vari·vel Private utilizada na funÁ„o LocXSx5NF
EndIf

Default xSX5NumNota := {.t.,"",""}
Default xTIPDOC     := "1" // 1=NF / 2=SD3 (Mov.Internas)
Default xCodVDV     := ""
Default nOpc        := 3
Default cTpFatR     := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura pelo Remito
Default	cSerieNFAutom:= ""

Private cGruVei     := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VV1->VV1_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1])) // Grupo do Veiculo
Private cDebugMIL   := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
Private lVVA_SEGMOD := VVA->(ColumnPos("VVA_SEGMOD")) > 0 
Private cLocxNFPV   := ""
Private cIdPV     := ""
Private cIdPVArg  := "" // variavel utilizada dentro do A462ANGera
Private dDEmissao   := dDatabase
Private cPV410 := ""
Private aRemTots  := {} // variavel utilizada dentro do a468nFreRem ( Frete - Mercado Internacional )

If Empty(aIteParc)
	aAdd(aIteParc,{ ctod(""), 0 })
EndIf

If !lVX001Auto
	If nOpc == 3 .and. cPaisLoc $ "ARG,MEX" // Inclusao Manual na Argentina ou Mexico
		If cOpeMov == "0" // 0=Venda						
			If cPaisLoc == "MEX"
				nTpFatura := Aviso(STR0109,STR0110,{STR0112,STR0113},2) // Saida de VeÌculos/M·quinas / Deseja gerar? / Remito / Cancela
				If nTpFatura > 0
					nTpFatura += 1
				EndIF				
			Else
				nTpFatura := Aviso(STR0109,STR0110,{STR0119,STR0112,STR0113},2) // Saida de VeÌculos/M·quinas / Deseja gerar? / Fatura com Entrega Futura / Remito / Cancela
			EndIf
			If nTpFatura == 0 .or. nTpFatura == 3 // Cancelou
				Return .f.
			EndIf			
			cTpFatR := strzero(nTpFatura,1) // Tipo: 1=Fatura (default) / 2=Remito			
			If !VX0010101_Valida_TES_ARG(cTpFatR,3)
				Return .f.
			EndIf			
			
		ElseIf cOpeMov $ "234567" // 2=Transferencia / 3=Remessa / 4=Devolucao / 5=Consignacao / 6=Retorno Remessa / 7=Retorno Consignacao
			cTpFatR := "2" // Sempre 2=Remito quando o movimento for 2=Transferencia / 3=Remessa / 4=Devolucao / 5=Consignacao / 6=Retorno Remessa / 7=Retorno Consignacao
		EndIf
	EndIf
EndIf


// TODAS AS VERIfICACOES JA FORAM REALIZADAS
// AS ROTINAS FISCAIS ESTAO CARREGADAS E DISPONIVEIS
// RESTA AGORA GRAVAR AS TABELAS VV0,VVA,SB1,VV1 e INTEGRAR
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")], cRotOrigem + " - " + "VX001EMINF_1")
next
//
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	If !lVX001Auto // N„o È EXECAUTO
		Pergunte("VXA018",.f.) // Utilizar o mesmo parametro do Atendimento de Veiculos - MV_PAR11
		nVerParFat := MV_PAR11 // Mostrar Parametros do Faturamento no momento da geracao da NF
		If nVerParFat == 1 // NAO mostrar os Parametros do Faturamento no momento da geracao da NF
			If lMultMoeda .and. FindFunction("FGX_MOEDAFAT") // Mercado Internacional
				If cTpFatR $ "1/3" // 1 = Fatura (default)  / 3 = Fatura com Remito
					If !VX0010111_SE4_Tipo_A( M->VV0_FORPAG ) // Pode alterar a MOEDA somente se a CondiÁ„o n„o for do Tipo A
						nMoedFat := FGX_MOEDAFAT( M->VV0_MOEDA ) // Seleciona a Moeda para Faturar
					EndIf
				EndIf
			EndIf
		Else // nVerParFat == 2 // Mostrar os Parametros do Faturamento no momento da geracao da NF / Remito
			cPergFat := "MT460A" // BRASIL
			If cPaisLoc <> "BRA" // Mercado Internacional
				// Default cTpFatR == "1" - 1 = Fatura (default) 
				cPergFat := "MTA410FAT"
				If cTpFatR == "3" // 3 = Fatura com Remito
					cPergFat := "MT468A"
				ElseIf cTpFatR $ "2/4" // 2=Remito / 4=Gera Fatura de Remito de Entrega Futura
					cPergFat := "MT462A"
				EndIf
			EndIf
			While .t.
				If PERGUNTE(cPergFat,.t.)
					Exit
				EndIf
			EndDo
			If lMultMoeda // Mercado Internacional
				If !VX0010111_SE4_Tipo_A( M->VV0_FORPAG ) // Pode alterar a MOEDA somente se a CondiÁ„o n„o for do Tipo A
					If cPergFat == "MTA410FAT" // Fatura / Entrega Futura
						If MV_PAR12 == 2 // Selecionar Moeda ?
							nMoedFat := MV_PAR13 // Moeda Selecionada para Faturar
						EndIf
					ElseIf cPergFat == "MT468A" // Fatura pelos Remitos
						If MV_PAR22 == 2 // Selecionar Moeda ?
							nMoedFat := MV_PAR23 // Moeda Selecionada para Faturar
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cPaisLoc <> "BRA" 
	    Pergunte("MTA410FAT",.f.)
		cMV01 := MV_PAR01
		cMV02 := MV_PAR02
		cMV03 := MV_PAR03
		cMV04 := MV_PAR04
		cMV05 := MV_PAR05
		cMV06 := MV_PAR06
		cMV07 := MV_PAR07
		cMV08 := MV_PAR08
		cMV09 := MV_PAR09
		cMV10 := MV_PAR10
		cMV11 := MV_PAR11
		cMV14 := MV_PAR14

		If (cPaisLoc == "ARG")
			cLocxNFPV := ""
			If FindFunction("OA5300051_Retorna_Ponto_de_Venda")
				Do Case
					Case cOpeMov == "0" // Saida por Venda
						If cTpFatR $ "2/4" // Remito / Remito da Entrega Futura
							cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_SAIVENDA") // Remito
						Else // Faturas
							cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_FAT_SAIVENDA") // Fatura
						EndIf
					Case cOpeMov == "2" // Saida de Veiculos por TransferÍncia
						cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_TRANSFER") // Remito
					Case cOpeMov == "3" // Saida de Veiculos por Remessa
						cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_REMESSA") // Remito
					Case cOpeMov == "4" // Saida por Devolucao de Compra
						cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_DEVCOMPRA") // Remito
					Case cOpeMov == "5" // Saida de Veiculos por ConsignaÁ„o
						cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_CONSIG") // Remito
					Case cOpeMov == "6" // Saida por Retorno de Remessa
						cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_RETREMESSA") // Remito
					Case cOpeMov == "7" // Saida por Retorno ConsignaÁ„o
						cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_RETCONSIG") // Remito
				EndCase
			EndIf
			lRet := .t.
			If Empty(cLocxNFPV)
				If lVX001Auto // Via EXECAUTO
					Pergunte("PVXARG",.f.)
					cLocxNFPV := MV_PAR01
				Else // N„o È via EXECAUTO
					If Pergunte("PVXARG",.T.) .and. !Empty(MV_PAR01)
						cLocxNFPV := MV_PAR01
					Else
						lRet := .f.
					EndIf
				EndIf
			EndIf
			If !Empty(cLocxNFPV)
				cPV410    := cLocxNFPV // Variavel Private utilizada no a468nFatura
				lLocxAuto  := .F.
				cIdPVArg := cIdPV := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
				lRet := F083ExtSFP(cLocxNFPV, .T.)
			Endif
			If !lRet
				Return .f.
			EndIf
		ENDIF 

	Endif
	
	If Empty(cSerieNFAutom) // Permitir que o MaPvlNfs gere a NF no processo automatico
		If cPaisLoc == "BRA"
			If xSX5NumNota[1]
				lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
			Else
				lRet := .t.
				cNumero := xSX5NumNota[2]
				cSerie  := xSX5NumNota[3]
			EndIf
			If !lRet
				Return .f.
			EndIf
		EndIf
	Else
		cSerie := cSerieNFAutom
	Endif

	// Busca o n˙mero da nota fiscal da Argentina ou Mexico
	If cPaisLoc $ "ARG,MEX" .and. cOpeMov $ "467" // 4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao
		If cTpFatR == "2" .or. (cPaisLoc!="MEX" .And. cTpFatR == "4")// 2=Remito // 4=Gera Fatura de Remito de Entrega Futura
			aPergX  := {'MATXNF',.T.}
			aPergsX := {} //Array com o conteudo das perguntas feitas na tela de NF
			nTipoX  := 61 // 61=Remito de devolucao

			// Remito Argentina ou Mexico
			Pergunte(aPergX[1],.F.)
			LoadPergs(aPergX,@aPergsX)

			//≥Monta array de configuracao da NF ≥
			aCfgNF := MontaCfgNf(nTipoX,aPergsX,.T.) // Vari·vel Private utilizada na funÁ„o LocXSx5NF
			If Empty(aCfgNF)
				Return .F.
			EndIf

			//          LocXSx5NF(oDlgPae,lLocxAuto,aAutoCab,lNumNCC,lTransf, cFunName   )
			aNumeroX := LocXSx5NF(Nil    ,.f.      ,Nil     ,Nil    ,Nil    , "MATA102DN")
			If Len(aNumeroX) < 2 // Deve retornar N˙mero e SÈrie
				FMX_HELP("VEIXX001ERR09", STR0123) // N„o foi possÌvel gerar Remito.
				Return .F.
			EndIf
			cNumero  := PadR(aNumeroX[1],GetSX3Cache("F2_DOC"  ,"X3_TAMANHO"))
			cSerie   := PadR(aNumeroX[2],GetSX3Cache("F2_SERIE","X3_TAMANHO"))
		EndIf
	EndIf

endif

// Se for Argentina ou Mexico, tipo 2=Remito e DevoluÁ„o/Retorno (4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao)
// Obs.: DevoluÁ„o/Retorno da Argentina ou Mexico precisa gerar o remito fora da transaÁ„o para n„o dar erro de MSRUNLOCK
If (cPaisLoc == "ARG" .and. (cTpFatR == "2" .or. cTpFatR == "4") .and. cOpeMov $ "467") .or. (cPaisLoc == "MEX" .and. (cTpFatR == "2") .and. cOpeMov $ "467")
	cF2TIPO    := "D"
	cF2FORMUL  := "S"
	cF2DOC     := cNumero
	cF2SERIE   := cSerie
	cF2CLIENTE := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_CODCLI"}),2]
	cF2LOJA    := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_LOJA"  }),2]
	cF2TIPOCLI := " "
	cF2ESPECIE := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_ESPECI"}),2]
	nF2DESCONT := 0
	nF2VALBRUT := aAutoItens[1,Ascan(aAutoItens[1],{|x|x[1]=="VVA_VALMOV"}),2]
	nF2VALFAT  := aAutoItens[1,Ascan(aAutoItens[1],{|x|x[1]=="VVA_VALMOV"}),2]
	nF2FRETE   := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_VALFRE"}),2]
	nF2SEGURO  := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_SEGURO"}),2]
	nF2DESPESA := 0
	cF2PREFIXO := Space(TamSX3("F2_PREFIXO")[1])
	dF2EMISSAO := dDataBase
	cF2HORA    := SubStr(Time(),1,5)
	cF2CLIENT  := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_CODCLI"}),2]
	cF2LOJENT  := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_LOJA"  }),2]
	cF2NFORI   := aAutoAux[1,Ascan(aAutoAux[1],{|x|x[1]=="C6_NFORI"  }),2]
	cF2SERIORI := aAutoAux[1,Ascan(aAutoAux[1],{|x|x[1]=="C6_SERIORI"}),2]
	If cPaisLoc == "ARG"
		nF2MOEDA   := aAutoArg[1,Ascan(aAutoArg[1],{|x|x[1]=="VVF_MOEDA" }),2] // Campos especÌficos Argentina
		nF2TXMOEDA := aAutoArg[1,Ascan(aAutoArg[1],{|x|x[1]=="VVF_TXMOED"}),2] // Campos especÌficos Argentina
	ElseIf cPaisLoc == "MEX"
		nF2MOEDA   := aAutoMex[1,Ascan(aAutoMex[1],{|x|x[1]=="VVF_MOEDA" }),2] // Campos especÌficos Mexico
		nF2TXMOEDA := aAutoMex[1,Ascan(aAutoMex[1],{|x|x[1]=="VVF_TXMOED"}),2] // Campos especÌficos Mexico				
	EndIf
	cF2COND    := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_FORPAG"}),2]
	cF2VEND1   := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_CODVEN"}),2]
	cF2NATUREZ := aAutoCab[Ascan(aAutoCab,{|x|x[1]=="VV0_NATFIN"}),2]
	cF2PV      := cLocxNFPV
	cF2TIPODOC := "61" // 61=Remito de devolucao

	aCabSF2 := {}
	aAdd(aCabSF2,{"F2_TIPO"    ,cF2TIPO   ,Nil})
	aAdd(aCabSF2,{"F2_FORMUL"  ,cF2FORMUL ,Nil})
	aAdd(aCabSF2,{"F2_DOC"     ,cF2DOC    ,Nil})
	aAdd(aCabSF2,{"F2_SERIE"   ,cF2SERIE  ,Nil})
	aAdd(aCabSF2,{"F2_CLIENTE" ,cF2CLIENTE,Nil})
	aAdd(aCabSF2,{"F2_LOJA"    ,cF2LOJA   ,Nil})
	aAdd(aCabSF2,{"F2_TIPOCLI" ,cF2TIPOCLI,Nil})
	aAdd(aCabSF2,{"F2_ESPECIE" ,cF2ESPECIE,Nil})
	aAdd(aCabSF2,{"F2_DESCONT" ,nF2DESCONT,Nil})
	aAdd(aCabSF2,{"F2_VALBRUT" ,nF2VALBRUT,Nil})
	aAdd(aCabSF2,{"F2_VALFAT"  ,nF2VALFAT ,Nil})
	aAdd(aCabSF2,{"F2_FRETE"   ,nF2FRETE  ,Nil})
	aAdd(aCabSF2,{"F2_SEGURO"  ,nF2SEGURO ,Nil})
	aAdd(aCabSF2,{"F2_DESPESA" ,nF2DESPESA,Nil})
	aAdd(aCabSF2,{"F2_PREFIXO" ,cF2PREFIXO,Nil})
	aAdd(aCabSF2,{"F2_EMISSAO" ,dF2EMISSAO,Nil})
	aAdd(aCabSF2,{"F2_HORA"    ,cF2HORA   ,Nil})
	aAdd(aCabSF2,{"F2_CLIENT"  ,cF2CLIENT ,Nil})
	aAdd(aCabSF2,{"F2_LOJENT"  ,cF2LOJENT ,Nil})
	aAdd(aCabSF2,{"F2_NFORI"   ,cF2NFORI  ,Nil})
	aAdd(aCabSF2,{"F2_SERIORI" ,cF2SERIORI,Nil})
	aAdd(aCabSF2,{"F2_MOEDA"   ,nF2MOEDA  ,Nil})
	aAdd(aCabSF2,{"F2_TXMOEDA" ,nF2TXMOEDA,Nil})
	aAdd(aCabSF2,{"F2_COND"    ,cF2COND   ,Nil})
	aAdd(aCabSF2,{"F2_VEND1"   ,cF2VEND1  ,Nil})
	aAdd(aCabSF2,{"F2_NATUREZ" ,cF2NATUREZ,Nil})
	aAdd(aCabSF2,{"F2_PV"      ,cF2PV     ,Nil}) 
	aAdd(aCabSF2,{"F2_TIPODOC" ,cF2TIPODOC,Nil})
	
	cD2ITEM    := StrZero(1,Len(SD2->D2_ITEM))
	If cPaisLoc == "ARG"
		cD2COD     := aAutoArg[1,Ascan(aAutoArg[1],{|x|x[1]=="B1_COD"    }),2] // Campos especÌficos Argentina
	ElseIf cPaisLoc == "MEX"
		cD2COD     := aAutoMex[1,Ascan(aAutoMex[1],{|x|x[1]=="B1_COD"    }),2] // Campos especÌficos Mexico
	EndIf
	nD2QUANT   := 1
	nD2PRCVEN  := nF2VALBRUT
	nD2TOTAL   := nF2VALBRUT
	cD2TES     := aAutoItens[1,Ascan(aAutoItens[1],{|x|x[1]=="VVA_CODTES"}),2]
	cD2NFORI   := cF2NFORI
	cD2SERIORI := cF2SERIORI
	cD2ITEMORI := aAutoAux[1,Ascan(aAutoAux[1],{|x|x[1]=="C6_ITEMORI"}),2]

	aItemSD2  := {}
	aItensSD2 := {}
	aAdd(aItemSD2,{"D2_ITEM"   ,cD2ITEM   ,Nil})
	aAdd(aItemSD2,{"D2_COD"    ,cD2COD    ,Nil})
	aAdd(aItemSD2,{"D2_QUANT"  ,nD2QUANT  ,Nil})
	aAdd(aItemSD2,{"D2_PRCVEN" ,nD2PRCVEN ,Nil})
	aAdd(aItemSD2,{"D2_TOTAL"  ,nD2TOTAL  ,Nil})
	aAdd(aItemSD2,{"D2_TES"    ,cD2TES    ,Nil})
	aAdd(aItemSD2,{"D2_NFORI"  ,cD2NFORI  ,Nil})
	aAdd(aItemSD2,{"D2_SERIORI",cD2SERIORI,Nil})
	aAdd(aItemSD2,{"D2_ITEMORI",cD2ITEMORI,Nil})
	aAdd(aItensSD2,aItemSD2)

	lMsErroAuto := .F.
	cFunNameA := FunName()  // Guarda a rotina anterior
	cFunName := "MATA102DN" // Vari·vel Private utilizada na funÁ„o LOCXNF
	SetFunName(cFunName)
	MSExecAuto({|x,y,z| MATA102DN(x,y,z)}, aCabSF2, aItensSD2, 3) // Chamada da Remito de devolucao  (Compras)
	cFunName := cFunNameA   // Retorna a rotina anterior
	SetFunName(cFunName)
	if lMsErroAuto
		Return .f.
	EndIf
EndIf

dbSelectArea("VV0")
If cTpFatR $ "1/2/4" // 1=Fatura / 2=Remito
	M->VV0_NUMTRA := GetSxENum("VV0","VV0_NUMTRA")
EndIf

//#############################################################################
//# INICIO DO CONTROLE DE TRANSACAO                                           #
//#############################################################################
BEGIN TRANSACTION
//
//#######################
//# Gravacao do VV0     #
//#######################
dbSelectArea("VV0")

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	cNumero := padr(cNumero,GetSX3Cache("F2_DOC","X3_TAMANHO"))
	cSerie  := padr(cSerie,GetSX3Cache("F2_SERIE","X3_TAMANHO"))
	if cPaisLoc == "BRA"
		DBSelectArea("SF2")
		DBSetOrder(1)
		while DBSeek(xFilial("SF2")+cNumero+cSerie)
			cNumero := padr( soma1( alltrim(cNumero) ),GetSX3Cache("F2_DOC","X3_TAMANHO"))
		endDo
	endif
	If cTpFatR == "1" // 1=Fatura
		M->VV0_NUMNFI := cNumero
		M->VV0_SERNFI := cSerie 
	ElseIf cTpFatR == "2" .or. cTpFatR == "4" // 2=Remito
		M->VV0_NUMNFI := ""
		M->VV0_SERNFI := ""
		M->VV0_REMITO := cNumero
		M->VV0_SERREM := cSerie 
	EndIf

	// Se for Argentina ou Mexico, tipo 2=Remito e DevoluÁ„o/Retorno (4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao)
	// Obs.: DevoluÁ„o/Retorno da Argentina gerou o remito fora da transaÁ„o para n„o dar erro de MSRUNLOCK
	If cPaisLoc $ "ARG,MEX" .and. cTpFatR == "2" .and. cOpeMov $ "467"
		// Argentina ou Mexico
	Else
		// SE FOI ENCONTRADA NF PARA ESSA TRANSACAO HOUVE UM ERRO INESPERADO
		//set delete off
		DBSelectArea("SF2")
		DBSetOrder(1)
		If DBSeek(xFilial("SF2")+cNumero+cSerie)
			DisarmTransaction()
			RollBackSxE()
			MsgStop(STR0041,STR0027)//Ja existe documento com a numeracao escolhida. ### Atencao
			lErro := .T.
			break
		EndIf
		MaFisRef("NF_FRETE"  ,"VX001",M->VV0_VALFRE) // Valor digitado na Tela
		MaFisRef("NF_DESPESA","VX001",M->VV0_DESACE) // Valor digitado na Tela

		MaFisRef("NF_SEGURO","VX001",M->VV0_SEGURO) // Valor digitado na Tela - SEGURO
	EndIf
EndIf
//

If cPaisLoc $ "ARG,MEX" .and. nOpc == 4
	lCriaVV0A := .f. // NAO cria VV0 e VVA - mantem o mesmo registro
EndIf

If lCriaVV0A // Cria VV0 e VVA

	// MONTA OS CAMPOS DO VV0 DEPENDENTES DE FISCAL
	If lAtuFiscal // Atualiza Fiscal
		// Se for Argentina ou Mexico, tipo 2=Remito e DevoluÁ„o/Retorno (4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao)
		// Obs.: DevoluÁ„o/Retorno da Argentina ou Mexico n„o atualiza as vari·veis de memÛria com MAFISREF
		If (cPaisLoc == "ARG" .and. ( cTpFatR == "2" .or. cTpFatR == "4" ) .and. cOpeMov $ "467").Or.(cPaisLoc == "MEX" .and. ( cTpFatR == "2") .and. cOpeMov $ "467")
			// Argentina ou Mexico
		Else
			DBSelectArea("SX3")
			DBSetOrder(1)
			DBSeek("VV0")
			while SX3->X3_ARQUIVO=="VV0"
				cValid	:= AllTrim(UPPER(SX3->X3_VALID))
				If "MAFISREF"$cValid
					nPosRef := AT('MAFISREF("',cValid) + 10
					cRefCols:=Substr(cValid,nPosRef,AT('","VX001",',cValid)-nPosRef )
					&("M->"+X3_CAMPO):= MaFisRet(,cRefCols)
				EndIf
				DbSkip()
			enddo
		EndIf
	EndIf

	// DA RECLOCK NA TABELA PARA INCLUIR REGISTRO
	RecLock("VV0",.t.)

	// GRAVA TODOS OS CAMPOS QUE ESTAO NA MEMORIA
	FG_GRAVAR("VV0")
	//
	VV0->VV0_FILIAL := xFilial("VV0")      
	VV0->VV0_SITNFI := "1" && Valida
	VV0->VV0_DTHEMI := FGX_DTHEMI() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo GMT
	VV0->VV0_OPEMOV := cOpeMov
	If Empty(VV0->VV0_TIPMOV)
		VV0->VV0_TIPMOV := "0" // 0 = Normal
	EndIf
	VV0->VV0_TIPDOC := xTIPDOC // 1=NF / 2=SD3 (Mov.Internas)
	If lMultMoeda
		VV0->VV0_MOEDA  := nMoedaCor
		VV0->VV0_TXMOED := nTaxaMoeda
	EndIf
	VV0->VV0_STATUS := "F"
	if cPaisLoc == "BRA"
		VV0->VV0_ALIICM := 0
	endif
	//
	cObs := "***  " + Left(Alltrim(UsrRetName(__CUSERID)), 15) + "  " + Transform(dDataBase,"@D")
	cObs += " - " + Transform(Time(), "@R 99:99") + "  ***" + Chr(13) + Chr(10)
	cObs += VV0_OBSERV
	MSMM(VV0->VV0_OBSMEM, TamSx3("VV0_OBSERV")[1],, cObs, 1,,, "VV0", "VV0_OBSMEM")
	ConfirmSx8()

	MSMM(VV0->VV0_OBSMNF, TamSx3("VV0_OBSENF")[1],, VV0_OBSENF, 1,,, "VV0", "VV0_OBSMNF")
	ConfirmSx8()

	MsUnlock()

EndIf

SA1->(DbSetOrder(1))
SA1->(DbSeek( xFilial("SA1") + VV0->VV0_CODCLI + VV0->VV0_LOJA ))

//#############################
//# Fim da Gravacao do VV0    #
//#############################
nRecVV0 := VV0->(Recno())
nSlv := n			// Salva a variavel n do acols
aItePv :={}
aItemRm := {}
nSeqPed := 0
dDemissao := VV0->VV0_DATMOV
For nCntFor = 1 to len(acols)
	// JANELA DE ABORTO
	If VX001ABORT()
		lErro := .T.
		break
	EndIf
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	nSeqPed ++
	//
	lGrCodInd := .f.
	//
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])

	If lCriaVV0A // Cria VV0 e VVA

		FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)

		//	
		nCustoVeiculo := FGX_CUSVEI( VV1->VV1_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_SEGMOD , VV1->VV1_CORVEI , dDataBase ) // B2_CM1 + Indice
		//
		if 	cOpeMov $ "35" // Remessa / Consignado
			aMovsRem := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] , "E")
			if Len(aMovsRem) > 0
				DBSelectArea("VVG")
				DBSetOrder(1)
				DBSeek(aMovsRem[1,2]+aMovsRem[1,3]+aCols[nCntFor,FG_POSVAR("VVA_CHAINT")])

				FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVA_CHAINT")] , /* cMVMIL0010 */ , cGruVei )

				DBSelectArea("SB2")
				DBSetOrder(1)
				DBSeek(aMovsRem[1,2]+SB1->B1_COD+VV1->VV1_LOCPAD)

				nCustoVeiculo := SB2->B2_CM1
				cCodIndRem :=  VVG->VVG_CODIND
				lGrCodInd := .t.
			endif
		Elseif 	cOpeMov $ "2" // transferencia
			aMovsTrf := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] , "E")
			if Len(aMovsTrf) > 0
				DBSelectArea("VVG")
				DBSetOrder(1)
				DBSeek(aMovsTrf[1,2]+aMovsTrf[1,3]+aCols[nCntFor,FG_POSVAR("VVA_CHAINT")])

				FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVA_CHAINT")] , /* cMVMIL0010 */ , cGruVei )

				DBSelectArea("SB2")
				DBSetOrder(1)
				DBSeek(aMovsTrf[1,2]+SB1->B1_COD+VV1->VV1_LOCPAD)  
				
				nCustoVeiculo := SB2->B2_CM1
				cCodIndRem :=  VVG->VVG_CODIND
				lGrCodInd := .t.
			endif
		endif
		
		//################################################################
		//# Gravacao do VVA                                              #
		//################################################################
		DBSelectArea("VV1")
		DBSetOrder(2)
		If !(DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")]))
			MsgStop(STR0079+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0082+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")],STR0061)
			DisarmTransaction()
			RollBackSxE()
			lErro := .T.
			break
		EndIf
		dbSelectArea("VVA")
		RecLock("VVA",.t.)
		FG_GRAVAR("VVA",aCols,aHeader,nCntFor)
		VVA->VVA_FILIAL := xFilial("VVA")
		VVA->VVA_NUMTRA := VV0->VV0_NUMTRA
		VVA->VVA_CHAINT := VV1->VV1_CHAINT
		VVA->VVA_ESTVEI := VV1->VV1_ESTVEI
		if lGrCodInd
			VVA->VVA_CODIND := cCodIndRem
		endif
		VVA->VVA_VCAVEI := nCustoVeiculo
		//
		VVA->VVA_VALFRE := VV0->VV0_VALFRE // Replica a informaÁ„o do VV0 para VVA - igual ao Atendimento de Veiculos
		VVA->VVA_FATTOT := VVA->VVA_VALMOV+VVA->VVA_COMCOT+VVA->VVA_COMCTP+VVA->VVA_RECTEC+VVA->VVA_BONFAB
		VVA->VVA_LUCBRU := VVA->VVA_FATTOT-VVA->VVA_VCAVEI - ( iif( cPaisLoc == "BRA" , VVA->VVA_TOTIMP , 0 ))
		VVA->VVA_LUCLQ1 := VVA->VVA_LUCBRU-VVA->VVA_JUREST-VVA->VVA_ACESSO-VVA->VVA_VDESCO-VVA->VVA_DESCLI-VVA->VVA_SEGVIA-VVA->VVA_VALASS-VVA->VVA_VALREV-VVA->VVA_DESVEI-VVA->VVA_ASSIMP-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT //LUCRO MARGINAL
		VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_DESFIX+(VVA->VVA_REDCUS+VVA->VVA_RECVEI-VVA->VVA_DSPFIN)      //LAIR
		//
		VX001MFORTE(VV1->VV1_CHAINT)
		//
		If VVA->(FieldPos("VVA_ITETRA")) <> 0
			VVA->VVA_CODMAR := VV1->VV1_CODMAR
			//VVA->VVA_GRUMOD := FM_SQL("SELECT VV2_GRUMOD FROM " + RetSQLName("VV2") + " VV2 WHERE VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2_CODMAR = '" + VV1->VV1_CODMAR + "' AND VV2_MODVEI = '" + VV1->VV1_MODVEI + "' AND D_E_L_E_T_ = ' '")
			VVA->VVA_GRUMOD := VV2->VV2_GRUMOD
			VVA->VVA_MODVEI := VV1->VV1_MODVEI
			If lVVA_SEGMOD
				VVA->VVA_SEGMOD := VV1->VV1_SEGMOD
			EndIf
			VVA->VVA_CORVEI := VV1->VV1_CORVEI
			VVA->VVA_VALTAB := VVA->VVA_VALMOV
		EndIf
		//
		MsUnlock()
		//################################################################
		//# Gravacao do VV1                                              #
		//################################################################
		//
		VX0010013_AtualizaVV1()

		dbSelectArea("SB1")
		If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , cUsaGrVA , cGruVei )
		

			if GetNewPar("MV_MIL0024","S")=="S" // Atualiza SB1 nas movimentaÁıes de saÌda? S/N
				RecLock("SB1",.f.)
				if cPaisLoc == "BRA"
					SB1->B1_PICM   := VVA->VVA_ALIICM
					SB1->B1_IPI    := VVA->VVA_ALIIPI
				endif
				SB1->B1_PRV1   := VVA->VVA_VALVDA
				MsUnlock()
			endif

			//
			// Grava localizaÁ„o
			//
			if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
				DBSelectArea("SB5")
				DBSetOrder(1)
				if DBSeek(xFilial("SB5")+SB1->B1_COD)
					DBSelectArea("VZL")
					DBSetOrder(1)
					if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
						if VZL->VZL_QTDATU > 0
							reclock("VZL",.f.)
							VZL->VZL_QTDATU := VZL->VZL_QTDATU - 1
							msunlock()
						endif
					endif
				endif
			endif

		Else
			FMX_HELP("VEIXX001ERR01",STR0050) // "O veÌculo n„o est· corretamente cadastrado na tabela de peÁas (SB1)."
			DisarmTransaction()
			RollBackSxE()
			lErro := .T.
			break
		EndIf
		dbSelectArea("SB1")
		dbSetOrder(1)
	Else
		dbSelectArea("SB1")
		If FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , cUsaGrVA , cGruVei )
		Else
			FMX_HELP("VEIXX001ERR01",STR0050) // "O veÌculo n„o est· corretamente cadastrado na tabela de peÁas (SB1)."
			DisarmTransaction()
			RollBackSxE()
			lErro := .T.
			break
		EndIf
		dbSelectArea("SB1")
		dbSetOrder(1)
	EndIf

	// Se for tipo 1=NF e n„o for DevoluÁ„o/Retorno da Argentina ou Mexico (4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao)
	// Obs.: DevoluÁ„o/Retorno da Argentina ou Mexico n„o gera pedido de venda
	If xTIPDOC == "1" .and. !(cPaisLoc $ "ARG,MEX" .and. cOpeMov $ "467")
		//
		//################################################################
		//# Gravacao do Pedido de Venda                                  #
		//################################################################
		lLiberaPed := .f.
		DBSelectArea("SF4")
		DBSetOrder(1)
		dbSeek(xFilial("SF4")+VVA->VVA_CODTES)
		aIteTempPV := {}
		If cUsaGrVA == "1" .and. nProdAgrup > 0 // Usa Veiculos de forma Agrupada por Modelo no SB1
			SB1->(dbGoto(nProdAgrup))
		Endif
		//
		aAdd(aIteTempPV,{"C6_NUM"    ,VV0->VV0_NUMPED						,Nil})
		aAdd(aIteTempPV,{"C6_ITEM"   ,STRZERO(nSeqPed,2)					,Nil})
		aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD  							,Nil})
		aAdd(aIteTempPV,{"C6_ENTREG" ,VV0->VV0_DATMOV  						,Nil})
		aAdd(aIteTempPV,{"C6_UM"     ,"UN"           						,Nil})
		aAdd(aIteTempPV,{"C6_TES"    ,VVA->VVA_CODTES  						,Nil})
		aAdd(aIteTempPV,{"C6_LOCAL"  ,SB1->B1_LOCPAD   						,Nil})
		//aAdd(aIteTempPV,{"C6_CLASFIS",SB1->B1_ORIGEM+SF4->F4_SITTRIB		,Nil})
		aAdd(aIteTempPV,{"C6_DESCRI" ,SB1->B1_DESC  						,Nil})
		aAdd(aIteTempPV,{"C6_CLI"    ,VV0->VV0_CODCLI      					,Nil})
		aAdd(aIteTempPV,{"C6_LOJA"   ,VV0->VV0_LOJA         				,Nil})
		DBSelectArea("SF4")
		DBSetOrder(1)
		dbSeek(xFilial("SF4")+VVA->VVA_CODTES)
		if SF4->F4_ESTOQUE == "S" .or. cOpeMov != "3"
			//		aAdd(aIteTempPV,{"C6_QTDLIB" ,1              						,Nil})
			aAdd(aIteTempPV,{"C6_QTDVEN" ,1            							,Nil})
			aAdd(aIteTempPV,{"C6_PRUNIT" ,VVA->VVA_VALMOV						,Nil})
			aAdd(aIteTempPV,{"C6_PRCVEN" ,VVA->VVA_VALMOV						,Nil})
			aAdd(aIteTempPV,{"C6_VALOR"  ,VVA->VVA_VALMOV						,Nil})
			aAdd(aIteTempPV,{"C6_VALDESC",VVA->VVA_VALDES  						,Nil})
		else
			lLiberaPed := .t.
			aAdd(aIteTempPV,{"C6_QTDLIB" ,0              						,Nil})
			aAdd(aIteTempPV,{"C6_QTDVEN" ,1            							,Nil})
			aAdd(aIteTempPV,{"C6_PRCVEN" ,VVA->VVA_VALMOV						,Nil})
			aAdd(aIteTempPV,{"C6_VALOR"  ,VVA->VVA_VALMOV						,Nil})
			aAdd(aIteTempPV,{"C6_PRUNIT" ,VVA->VVA_VALMOV						,Nil})
			aAdd(aIteTempPV,{"C6_VALDESC",VVA->VVA_VALDES  						,Nil})
		endif

		// Ticket: 2353361
		// ISSUE: MMIL-2867
		// O TES est· sendo enviado novamente pois na base do cliente ocorria uma falha. O conte˙do do TES
		//   na aCols (MATA410) ficava com conte˙do VAZIO.
		// O problema n„o foi reproduzido em base teste, mas verificamos que passando o TES novamente
		//   a falha n„o ocorria novamente.
		// A mensagem de HELP disparada era A410VZ.
		aAdd(aIteTempPV,{"C6_TES"    ,VVA->VVA_CODTES  						,Nil})

		If SC6->(FieldPos("C6_CHASSI")) > 0
			aAdd(aIteTempPV,{"C6_CHASSI" ,VV1->VV1_CHASSI,Nil}) // Chassi do Veiculo -  Descricao do Produto
		Endif

		If SC6->(FieldPos("C6_CC"))>0 .and. VVA->(FieldPos("VVA_CENCUS"))>0
			aAdd(aIteTempPV,{"C6_CC" , VVA->VVA_CENCUS , Nil})
		Endif
		If SC6->(FieldPos("C6_CONTA"))>0 .and. VVA->(FieldPos("VVA_CONTA"))>0
			aAdd(aIteTempPV,{"C6_CONTA" , VVA->VVA_CONTA , Nil})
		Endif
		If SC6->(FieldPos("C6_ITEMCTA"))>0 .and. VVA->(FieldPos("VVA_ITEMCT"))>0
			aAdd(aIteTempPV,{"C6_ITEMCTA" , VVA->VVA_ITEMCT , Nil})
		Endif
		If SC6->(FieldPos("C6_CLVL"))>0 .and. VVA->(FieldPos("VVA_CLVL"))>0
			aAdd(aIteTempPV,{"C6_CLVL" , VVA->VVA_CLVL , Nil})
		Endif
		If SC6->(FieldPos("C6_FCICOD"))>0 .and. (VVA->(FieldPos("VVA_FCICOD"))>0 .and. !Empty(VVA->VVA_FCICOD) )
			aAdd(aIteTempPV,{"C6_FCICOD" , VVA->VVA_FCICOD , Nil})
		Endif

		// NT 2021.004 v1.21 - Alecsandre Ferreira
		if SC6->(FieldPos("C6_OBSCONT")) > 0 .AND. (VVA->(FieldPos("VVA_OBSCON")) > 0 .and. !Empty(VVA->VVA_OBSCON) )
			aAdd(aIteTempPV,{"C6_OBSCONT", VVA->VVA_OBSCON, Nil})
		endif          

		if SC6->(FieldPos("C6_OBSCCMP")) > 0 .AND. (VVA->(FieldPos("VVA_OBSCCM")) > 0 .and. !Empty(VVA->VVA_OBSCCM) )
			aAdd(aIteTempPV,{"C6_OBSCCMP", VVA->VVA_OBSCCM, Nil})
		endif         

		if SC6->(FieldPos("C6_OBSFISC")) > 0 .AND. (VVA->(FieldPos("VVA_OBSFIS")) > 0 .and. !Empty(VVA->VVA_OBSFIS) )
			aAdd(aIteTempPV,{"C6_OBSFISC", VVA->VVA_OBSFIS, Nil})
		endif         

		if SC6->(FieldPos("C6_OBSFCMP")) > 0 .AND. (VVA->(FieldPos("VVA_OBSFCP")) > 0 .and. !Empty(VVA->VVA_OBSFCP) )
			aAdd(aIteTempPV,{"C6_OBSFCMP", VVA->VVA_OBSFCP, Nil})
		endif
		// NT 2021.004 v1.21    

		If VV0->VV0_OPEMOV $ "0.2" .and. VV0->VV0_TIPFAT == "1" // Venda ou transferÍncia  de Usado
			aUltMov := FM_VEIMOVS( VV1->VV1_CHASSI , "E"  )
			For ni := 1 to Len(aUltMov)                     
				If aUltMov[ni,5] == "0" // Entrada por Compra
					Dbselectarea("VVF")
					DbSetOrder(1)
					If DbSeek(aUltMov[ni,2]+aUltMov[ni,3])
						Dbselectarea("SD1")
						DbSetOrder(1)  
						If DbSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
							aAdd(aIteTempPV,{"C6_NFORI" ,SD1->D1_DOC,Nil})
							aAdd(aIteTempPV,{"C6_SERIORI" ,SD1->D1_SERIE,Nil})
							aAdd(aIteTempPV,{"C6_ITEMORI" ,SD1->D1_ITEM,Nil})
							If VV0->VV0_OPEMOV <> "2" // Diferente de Transferencia, pois Transferencia nao pode pegar a Base da Entrada conforme orientaÁ„o https://tdn.totvs.com/pages/releaseview.action?pageId=567761617
								aAdd(aIteTempPV,{"C6_BASVEIC" ,SD1->D1_TOTAL,Nil})
							EndIf
						Endif
					EndIf
					Exit
				Endif
			Next
		
		Endif
		
		if cOpeMov $ "467" .or. ( cOpeMov == "2" .and. Len(aAutoAux) > 0)
			for nCntFor2 := 1 to Len(aAutoAux[nCntFor])
				aAdd(aIteTempPV,aAutoAux[nCntFor,nCntFor2])
			next
		endif
		//
		aAdd(aItePv,aClone(aIteTempPV))
		
	EndIf

	If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)
		If SD2->(FieldPos("D2_CHASSI")) > 0 
			aadd(aVetAtuSD2,{SB1->B1_COD,STRZERO(nSeqPed,2),VVA->VVA_CHASSI}) // ReferÍncia dos Elementos no SD2: D2_COD, D2_ITEM, D2_CHASSI
		Endif
	EndIf
Next

// VV0_OPEMOV: 0=Venda;1=Simulacao;2=Transferencia;3=Remessa;4=Devolucao;5=Consignado;6=Ret Remessa;7=Ret Consignado;8=Venda Futura;9=Baixa
cC5Tipo := "N"
Do Case
	Case cOpeMov $ "35" // Saida por Remessa/Consignado
		If cCliForA == "F" // utiliza Fornecedor
			cC5Tipo := "B" // Beneficiamento
		EndIf

	Case cOpeMov $ "4" .or. (cOpeMov == "2" .and. Len(aAutoAux) > 0 )// Devolucao
		cC5Tipo := "D" // D-Devolucao

	Case cOpeMov $ "67" // Saida por Retorno Remessa/Consignado
		If cCliForA == "F" // utiliza Fornecedor
			cC5Tipo := "D" // D-Devolucao
		EndIf
EndCase

dbSelectArea("VV0")
RecLock("VV0",.f.)
VV0->VV0_TIPO := cC5Tipo
If lVX001Auto .And. cPaisLoc == "MEX" .And. !Empty(aAutoMex)
	If Ascan(aAutoMex[1],{|x|x[1]=="VV0_TPDOC"})>0 .And. Ascan(aAutoMex[1],{|x|x[1]=="VV0_USOCFD"})>0
		VV0->VV0_TPDOC := aAutoMex[1,Ascan(aAutoMex[1],{|x|x[1]=="VV0_TPDOC"}),2] // Campos especÌficos Mexico
		VV0->VV0_USOCFD := aAutoMex[1,Ascan(aAutoMex[1],{|x|x[1]=="VV0_USOCFD"}),2] // Campos especÌficos Mexico	
	EndIf
EndIf
MsUnlock()

// Se for tipo 1=NF e n„o for DevoluÁ„o/Retorno da Argentina ou Mexico (4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao)
// Obs.: DevoluÁ„o/Retorno da Argentina ou Mexico n„o gera pedido de venda
If xTIPDOC == "1" .and. !(cPaisLoc $ "ARG,MEX" .and. cOpeMov $ "467") .and. cTpFatR <> "3"

	aCabPV := {}
	//	aAdd(aCabPV,{"C5_NUM"    ,VV0->VV0_NUMPED  										,Nil})
	aAdd(aCabPV,{"C5_TIPO"   ,cC5Tipo												,Nil})
	aAdd(aCabPV,{"C5_CLIENTE",VV0->VV0_CODCLI  										,Nil})
	aAdd(aCabPV,{"C5_LOJAENT",VV0->VV0_LOJA   	  									,Nil})
	aAdd(aCabPV,{"C5_LOJACLI",VV0->VV0_LOJA  	   									,Nil})
	aAdd(aCabPV,{"C5_CONDPAG",VV0->VV0_FORPAG										,Nil})
	aAdd(aCabPV,{"C5_VEND1"  ,VV0->VV0_CODVEN	 									,Nil})
	aAdd(aCabPV,{"C5_EMISSAO",VV0->VV0_DATMOV										,Nil})
	aAdd(aCabPV,{"C5_TIPOCLI",IIf(cCliForA == "C",SA1->A1_TIPO,"R")				    ,Nil})
	aAdd(aCabPV,{"C5_BANCO"  ,VV0->VV0_CODBCO  										,Nil})
	aAdd(aCabPV,{"C5_INCISS" ,"N"            	  									,Nil})
	aAdd(aCabPV,{"C5_TIPLIB" ,"2"            	  									,Nil})
	If lMultMoeda
		aAdd(aCabPV,{"C5_MOEDA"  ,IIf(nMoedaCor>0.and.nMoedaCor<=MoedFin(),nMoedaCor,1),Nil}) // Moeda
		aAdd(aCabPV,{"C5_TXMOEDA",nTaxaMoeda,Nil}) // Taxa Moeda
	Else
		aAdd(aCabPV,{"C5_MOEDA"  ,1	,Nil})				// Moeda
	EndIf
	aAdd(aCabPV,{"C5_LIBEROK","S"            										,Nil})
	aAdd(aCabPV,{"C5_COMIS1" ,0              		 								,Nil})
	aAdd(aCabPV,{"C5_DESPESA",VV0->VV0_DESACE  	 								    ,Nil})
	aAdd(aCabPV,{"C5_FRETE" ,VV0->VV0_VALFRE 		 								,Nil})
	// Testar a existencia do campo C5_PAISENT (existe em ARG e BOL)
	IF SC5->(FieldPos("C5_PAISENT")) > 0 .and. cPaisLoc != "BRA"
		if !Empty(SA1->A1_PAIS) .And. cPaisLoc != 'MEX'// Caso o paÌs de entrega esteja preenchido È necess·rio informar o paÌs no pedido
			aAdd(aCabPV,{"C5_PAISENT" ,SA1->A1_PAIS 		 								,Nil})
		endIf
	Endif
	If VV0->(FieldPos("VV0_SEGURO")) > 0 .and. VV0->VV0_SEGURO > 0
		aAdd(aCabPV,{"C5_SEGURO" ,VV0->VV0_SEGURO 		 								,Nil})		
	EndIf
	if SC5->(FieldPos("C5_NATUREZ")) > 0
		aAdd(aCabPV,{"C5_NATUREZ" ,VV0->VV0_NATFIN							   		,Nil})
	endif
	if SC5->(FieldPos("C5_TRANSP")) > 0
		aAdd(aCabPV,{"C5_TRANSP" ,VV0->VV0_CODTRA  									,Nil})
	Endif
	If !Empty(VV0->VV0_TPFRET)
		aAdd(aCabPV,{"C5_TPFRETE",Alltrim(VV0->VV0_TPFRET)							,NIL})	// Tipo do Frete
	EndIf
	If VV0->(FieldPos("VV0_PESOL")) > 0 .and. VV0->VV0_PESOL > 0
		aAdd(aCabPV,{"C5_PESOL",VV0->VV0_PESOL										,Nil})	// Peso Liquido
	EndIf
	If VV0->(FieldPos("VV0_PBRUTO")) > 0 .and. VV0->VV0_PBRUTO > 0
		aAdd(aCabPV,{"C5_PBRUTO",VV0->VV0_PBRUTO									,Nil})	// Peso Bruto
	EndIf
	If VV0->(FieldPos("VV0_VOLUME")) > 0 .and. VV0->VV0_VOLUME > 0
		aAdd(aCabPV,{"C5_VOLUME1",VV0->VV0_VOLUME									,Nil})	// Volume
	EndIf
	If VV0->(FieldPos("VV0_ESPECI")) > 0 .and. !Empty(VV0->VV0_ESPECI)
		aAdd(aCabPV,{"C5_ESPECI1",VV0->VV0_ESPECI									,Nil})	// Especie
	EndIf
	If VV0->(FieldPos("VV0_VEICUL")) > 0 .and. !Empty(VV0->VV0_VEICUL)
		aAdd(aCabPV,{"C5_VEICULO",VV0->VV0_VEICUL									,Nil})	// Veiculo
	EndIf
	If SC5->(FieldPos("C5_INDPRES")) > 0 .and. ( VV0->(FieldPos("VV0_INDPRE")) > 0 .and. !Empty(VV0->VV0_INDPRE) )
		aAdd(aCabPV,{"C5_INDPRES"  ,VV0->VV0_INDPRE   								,Nil}) 	// Presenca do Comprador
	Endif
	If SC5->(FieldPos("C5_CLIENT")) > 0 .and. ( VV0->(FieldPos("VV0_CLIENT")) > 0 .and. !Empty(VV0->VV0_CLIENT) )
		aAdd(aCabPV,{"C5_CLIENT"  ,VV0->VV0_CLIENT   								,Nil}) 	// Cliente Entrega
	Endif
	If SC5->(FieldPos("C5_LOJAENT")) > 0 .and. ( VV0->(FieldPos("VV0_LOJENT")) > 0 .and. !Empty(VV0->VV0_LOJENT) )
		aAdd(aCabPV,{"C5_LOJAENT"  ,VV0->VV0_LOJENT   								,Nil}) 	// Loja do cliente de entrega
	Endif
	If SC5->(FieldPos("C5_CODA1U")) > 0 .and. ( VV0->(FieldPos("VV0_CODA1U")) > 0 .and. !Empty(VV0->VV0_CODA1U) )
		aAdd(aCabPV,{"C5_CODA1U"  ,VV0->VV0_CODA1U   								,Nil})
	Endif
	If VV0->(FieldPos("VV0_CLIREM") > 0) .and. !Empty(VV0->VV0_CLIREM)
		aAdd(aCabPV,{"C5_CLIREM"   ,VV0->VV0_CLIREM   								,Nil})
	Endif
	If VV0->(FieldPos("VV0_LOJREM") > 0) .and. !Empty(VV0->VV0_LOJREM)
		aAdd(aCabPV,{"C5_LOJAREM"  ,VV0->VV0_LOJREM   								,Nil})
	EndIf
	If ! Empty(VV0->VV0_MENNOT)
		aAdd(aCabPV,{"C5_MENNOTA",VV0->VV0_MENNOT ,Nil}) // Mensagem da NF
	EndIf
	If ! Empty(VV0->VV0_MENPAD)
		aAdd(aCabPV,{"C5_MENPAD" ,VV0->VV0_MENPAD ,Nil}) // Mensagem Padrao NF
	EndIf                
	If cPaisLoc == "ARG" .and. ( VV0->(FieldPos("VV0_PROVEN")) > 0 .and. !Empty(VV0->VV0_PROVEN) )
		aAdd(aCabPV,{"C5_PROVENT"  ,VV0->VV0_PROVEN , Nil}) 	// Loja do cliente de entrega
	Endif
	If cPaisLoc $ "ARG,MEX"
		If cTpFatR $ "1/3" // 1=Fatura (default) / 3=Fatura com Remito
			aAdd(aCabPV,{"C5_DOCGER" , "1" , Nil } ) // Tipo de Documento ( 1 = Fatura / 2 = Remito )
		Else // 2=Remito
			aAdd(aCabPV,{"C5_DOCGER" , "2" , Nil } ) // Tipo de Documento ( 1 = Fatura / 2 = Remito  )
		EndIf
		If cPaisLoc == "MEX"
			If VV0->(FieldPos("VV0_TPDOC")) > 0 .and. !Empty(VV0->VV0_TPDOC)
				aAdd(aCabPV,{"C5_TPDOC" ,VV0->VV0_TPDOC,Nil}) // Forma de Pagam SAT
			EndIf
			If VV0->(FieldPos("VV0_USOCFD")) > 0 .and. !Empty(VV0->VV0_USOCFD)
				aAdd(aCabPV,{"C5_USOCFDI" ,VV0->VV0_USOCFDI,Nil}) // Chave de uso CFDI
			EndIf
		EndIf
	EndIf
	if SA1->(FieldPos("A1_DESC")) > 0 // Tratativa diferenÁa entre VV0 e SF2
		aAdd(aCabPV,{"C5_DESC1 " ,0,Nil})
	endif 

	SE4->(dbSetOrder(1))
	SE4->(MsSeek( xFilial("SE4") + VV0->VV0_FORPAG ))
	// Condicao negociada
	If SE4->E4_TIPO == "9"
		cParcela := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0" // cParcela igual ao MATA410A, funcao A410Tipo9()
		For nCntFor := 1 to len(aIteParc)
			aAdd(aCabPV,{"C5_DATA" + substr(cParcela,nCntFor,1) , aIteParc[nCntFor,1] , Nil }) // Data da Parcela
			aAdd(aCabPV,{"C5_PARC" + substr(cParcela,nCntFor,1) , aIteParc[nCntFor,2] , Nil }) // Valor da Parcela
		Next
	EndIf
	
	//dbSelectArea("SX3")
	//dbSetOrder(1)
	//dbSeek("SC5")
	//While !Eof().and.(x3_arquivo=="SC5")
	//	If Alltrim(x3_campo) != "C5_NUM"
	//		wVar := "M->"+x3_campo
	//		&wVar:= CriaVar(x3_campo)
	//	Endif
	//	dbSkip()
	//EndDo

		RegToMemory("SC5",.t.)
	
	For x_:=1 to Len(aCabPV)
		&("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
	Next
	nAnt    := MAFISSAVE()
	MAFISEND()

	// CHAMADA DO MATA410 COM OS DADOS DA INTEGRACAO
	lMsErroAuto := .f.
	//
	// Ponto de Entrada antes do Pedido de Venda
	//
	if ExistBlock("VX001APV")
		ExecBlock("VX001APV",.f.,.f.)
	Endif
	//
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3)
	//
	MAFISRESTORE(nAnt)
	//
	If lMsErroAuto
		DisarmTransaction()
		RollBackSxE()
		lErro := .T.
		break
	EndIf
	// JANELA DE ABORTO
	If VX000ABORT()
		lErro := .T.
		break
	EndIf

	cPedSC5 := SC5->C5_NUM
	dbSelectArea("VV0")
	RecLock("VV0",.f.)
	If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura com Remito
		VV0->VV0_NUMPED := cPedSC5
	ElseIf cTpFatR == "2" .or. cTpFatR == "4" // 2=Remito
		VV0->VV0_PEDREM := cPedSC5
	EndIf
	MsUnlock()

	//################################################################
	//# Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade      #
	//################################################################
	SC5->(dbSetOrder(1))
	SC5->(MsSeek(xFilial("SC5")+cPedSC5))
	//
	SC6->(dbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
		
	SC9->(DbSetOrder(1))
	if !(SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))) //FILIAL+NUMERO+ITEM
			
		lCredito := .t.
		lEstoque := .t.
		lLiber   := .t.
		lTransf  := .f.
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+SC5->C5_NUM+"01")
		While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM
			dbSelectArea("SC9")
			if !dbSeek(xFilial("SC9")+SC5->C5_NUM+SC6->C6_ITEM)
				nQtdLib := SC6->C6_QTDVEN
				nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
			Endif
			dbSelectArea("SC6")
			dbSkip()
		Enddo
		If !lEstoque .or. cDebugMIL == "VEIXX001EST"
			MsgStop(STR0077,STR0027)
			DisarmTransaction()
			RollBackSxE()
			lErro := .T.
			break
		Endif
	
	endif

EndIf

If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	// Se for Argentina ou Mexico, tipo 2=Remito e DevoluÁ„o/Retorno (4=Devolucao / 6=Retorno Remessa / 7=Retorno Consignacao)
	// Obs.: DevoluÁ„o/Retorno da Argentina ou Mexico gerou o remito fora da transaÁ„o para n„o dar erro de MSRUNLOCK
	//       Somente atualizar a VV0
	If (cPaisLoc == "ARG" .and. (cTpFatR == "2" .or. cTpFatR == "4") .and. cOpeMov $ "467") .or. (cPaisLoc == "MEX" .and. (cTpFatR == "2") .and. cOpeMov $ "467")

		lErro := .T.
		SF2->(DbSetOrder(1))
		SF2->(DbSeek(xFilial("SF2")+cNumero+cSerie)) // Posiciona no SF2
		If SF2->(!Eof())
			cNota  := cNumero
			cPreTit := SF2->F2_PREFIXO
			DbSelectArea("VV0")
			DbGoTo(nRecVV0)
			reclock("VV0",.f.)
			VV0->VV0_TPFATR := "2" // 2=Remito
			VV0->VV0_REMITO := cNota
			VV0->VV0_SERREM := cSerie
			msunlock()
			lErro := .F.
		EndIf

	ElseIf cPaisLoc <> "BRA"

		aPvlNfs := {} // Limpar para ser utilizado nas funÁıes abaixo

		If cTpFatR <> "3"

			SC5->(dbSetOrder(1))
			SC5->(MsSeek(xFilial("SC5")+cPedSC5))
			// Garante a liberaÁ„o da SC6
			Ma410LbNfs(2,@aPvlNfs,@aBloqueio) // verificar o abloqueio antes de chamar novamente  funÁ„o para liberar o C9
			// Garante a liberaÁ„o da SC9
			Ma410LbNfs(1,@aPvlNfs,@aBloqueio)

		Else

			cQuery := "SELECT SD2.R_E_C_N_O_ AS RECSD2 "
			cQuery += "  FROM "+RetSqlName("VV0")+" VV0 "
			cQuery += "  JOIN "+RetSqlName("SD2")+" SD2 "
			cQuery += "    ON SD2.D2_FILIAL  = '"+xFilial("SD2")+"'"
			cQuery += "   AND SD2.D2_DOC     = VV0.VV0_REMITO"
			cQuery += "   AND SD2.D2_SERIE   = VV0.VV0_SERREM"
			cQuery += "   AND SD2.D2_CLIENTE = VV0.VV0_CODCLI"
			cQuery += "   AND SD2.D2_LOJA    = VV0.VV0_LOJA"
			cQuery += "   AND SD2.D_E_L_E_T_ = ' '"
			cQuery += " WHERE VV0.VV0_FILIAL = '"+xFilial("VV0")+"'"
			cQuery += "   AND VV0.VV0_NUMTRA = '" + VV0->VV0_NUMTRA + "'"
			cQuery += "   AND VV0.D_E_L_E_T_ = ' '"

			TcQuery cQuery New Alias "TMPSD2"

			While TMPSD2->(!Eof())
				aadd(aPvlNfs,{,,,,,,, TMPSD2->RECSD2 })
				TMPSD2->(DbSkip())
			Enddo

			TMPSD2->( dbCloseArea() )

		EndIf

		cNota := ""

		if !Empty(aPvlNfs) .And. Empty(aBloqueio) // Registra os itens bloqueados para serem mostrados apÛs a transaÁ„o
			
			aReg:={}
			For nX:=1 To Len(aPvlNfs)
				Aadd(aReg,aPvlNfs[nX][8])
			Next

			private lMSAuto := .T. // Para n„o mostrar a tela com os n˙meros das notas a serem geradas
			If cTpFatR $ "1/3" // 1 = Fatura sem Remito / 3 = Fatura com Remito
				If cTpFatR == "3"
					DbSelectArea("SC5")
					DBSetOrder(1)
					DBSeek(xFilial("SC5")+VV0->VV0_PEDREM)
					Pergunte("MT468A",.f.)
					nMoedSC5 := SC5->C5_MOEDA
					If nMoedFat <> 0 .and. nMoedFat <> nMoedSC5 // Caso selecionou uma Moeda para Faturar e È diferente do SC5
						nTipMoed := 2 // Selecionada uma Moeda para Faturar
					Else		
						nMoedFat := nMoedSC5
					EndIf
					aParams	:=	{"000000000001","ZZZZZZZZZZZZ",;	//Remito de - ate
								SC5->C5_CLIENTE,SC5->C5_CLIENTE,; 	//Cliente de - ate
								SC5->C5_LOJACLI,SC5->C5_LOJACLI,; 	//Loja de - ate
								mv_par07,mv_par08,; 				//Grupo de - ate
								mv_par09,mv_par10,; 				//Agregador de - ate
								mv_par11,mv_par12,mv_par13,; 		//lDigita # lAglutina # lGeraLanc
								mv_par14,mv_par15,4,; 				//lInverte# lAtuaSA7  # nSepara
								mv_par17,mv_par18,; 				//nValorMin# # lConsig
								mv_par19,mv_par20,; 				//Transportadora de - ate
								mv_par21,nTipMoed,;					//Reajusta na mesma nota  # Fatura pela Moeda
								nMoedFat,mv_par24,; 				//Selecione moeda para faturamento
								mv_par25,""} 						//Tipo de Pedido # Di·rio Portugal

					lPedidos := .F. // variavel utilizada no MATA468N
					lConsig  := .F. // variavel utilizada no MATA468N
					cTab := "SD2"
				Else
					nMoedSC5 := SC5->C5_MOEDA
					If nMoedFat <> 0 .and. nMoedFat <> nMoedSC5 // Caso selecionou uma Moeda para Faturar e È diferente do SC5
						nTipMoed := 2 // Selecionada uma Moeda para Faturar
					Else		
						nMoedFat := nMoedSC5
					EndIf
					aParams :=	{SC5->C5_NUM,SC5->C5_NUM,; //Pedido de - ate
								SC5->C5_CLIENTE,SC5->C5_CLIENTE,; //Cliente de - ate
								SC5->C5_LOJACLI,SC5->C5_LOJACLI,; //Loja de - ate
								cMV01,cMV02,; //Grupo de - ate
								cMV03,cMV04,; //Agregador de - ate
								cMV05,cMV06,cMV07,; //lDigita # lAglutina # lGeraLanc
								2       ,cMV08,cMV09,; //lInverte# lAtuaSA7  # nSepara
								cMV10, 2,; //nValorMin# proforma
								"",'zzzzzzzzzzz',;//Trasnportadora de - ate
								cMV11,nTipMoed,;//Reajusta na mesma nota  # Fatura Ped. Pela
								nMoedFat,cMV14,; // Moeda para Faturamento			
								If(SC5->C5_TIPO<>"N",2,1)} // Tipo de Pedido
					cTab := "SC9"
				EndIf

				cFunName := FunName()
				SetFunName("MATA468N")
				aFaturas := a468NFatura(cTab,aParams,aReg,Nil)
				SetFunName(cFunName)
				if OFXFA0053_FaturasForamGeradas("VEIXX001ERR03",aFaturas,SC5->C5_CLIENTE,SC5->C5_LOJACLI, @cNota , @cSerie)
					cPreTit := SF2->F2_PREFIXO
					DbSelectArea("VV0")
					DbGoTo(nRecVV0)
					reclock("VV0",.f.)
					VV0->VV0_TPFATR := cTpFatR // 1=Fatura sem Remito / 3=Fatura com Remito
					VV0->VV0_NUMNFI := SF2->F2_DOC
					VV0->VV0_SERNFI := SF2->F2_SERIE
					msunlock()
				Endif
			ElseIf (cTpFatR == "2") .or. (cPaisLoc!="MEX".And.cTpFatR == "4") // 2 = Remito
				Pergunte("MT462A",.F.)
				mv_par09 := 2 // Garante que n„o aparecer· a tela de lanÁamentos padr„o
				aParams := {;
						MV_PAR09,;     // Mostra LanÁamentos
						MV_PAR10,;     // Aglutina LnaÁamentos
						MV_PAR11,;     // LanÁamento On-Line
						MV_PAR12,;     // Aglutina Pedidos
						01,;           // Fatura pedido pela (1) Moeda do Pedido; (2) Moeda Selecionas
						SC5->C5_MOEDA} // Fatura pela 1-Moeda 1; 2-Moeda 2; 3-Moeda 3; ...
				cMarcaSC9 := cMarca := GetMark(,'SC9','C9_OK')
				For nX := 1 To Len(aReg)
					SC9->(DbGoTo(aReg[nX]))
					RecLock("SC9",.F.)
					SC9->C9_OK := cMarca
					SC9->(MsUnLock())
				Next
				SetInvert(.F.)
				if !Empty(aRetMS := A462ANGera(Nil,cMarca,.T.,aReg,.F.,aParams))
					cSerie := aRetMS[1][1]
					cNota  := aRetMS[1][2]
					SF2->(DbSetOrder(1))
					SF2->(DbSeek(xFilial("SF2")+cNota+cSerie))
					cPreTit := SF2->F2_PREFIXO
					DbSelectArea("VV0")
					DbGoTo(nRecVV0)
					reclock("VV0",.f.)
					VV0->VV0_REMITO := cNota
					VV0->VV0_SERREM := cSerie
					If Empty(VV0->VV0_NUMNFI)
						VV0->VV0_TPFATR := "2" // 2=Remito
					Else
						VV0->VV0_TPFATR := "3" // 3=Fatura com Remito
					EndIf
					msunlock()
				EndIf
			EndIf
		else // Se houver bloqueio, n„o gera a nota fiscal
			FMX_HELP("VEIXX001ERR02", STR0105, STR0106) // "Ocorreu um bloqueio na liberaÁ„o dos Ìtens durante a geraÁ„o da nota fiscal."###"Por favor, verifique!"
			DisarmTransaction()
			lErro := .T.
		EndIf
		If Empty(cNota)
			DisarmTransaction()
			lErro := .T.
		EndIf
		
	ELSE
		
		aPvlNfs := {}
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+cPedSC5))
		//
		SC6->(dbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
		
		While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM
			
			SC9->(DbSetOrder(1))
			SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM
			
			SE4->(DbSetOrder(1))
			SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO
			
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO
			
			SB2->(DbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL
			
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES
			
			nPrcVen := SC9->C9_PRCVEN
			If ( SC5->C5_MOEDA <> 1 )
				nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
			EndIf
			
			Aadd(aPvlNfs,{ SC9->C9_PEDIDO,;
			SC9->C9_ITEM,;
			SC9->C9_SEQUEN,;
			SC9->C9_QTDLIB,;
			nPrcVen,;
			SC9->C9_PRODUTO,;
			.f.,;
			SC9->(RecNo()),;
			SC5->(RecNo()),;
			SC6->(RecNo()),;
			SE4->(RecNo()),;
			SB1->(RecNo()),;
			SB2->(RecNo()),;
			SF4->(RecNo())})
			SC6->(DbSkip())
		EndDo
		//
		If ( len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cPedSC5,.t.) ) .or. cDebugMIL == "VEIXX001SC5"
			DisarmTransaction()
			RollBackSxE()
			lErro := .T.
			break
		EndIf
		//
		If Len(aPvlNfs) > 0
			PERGUNTE("MT460A",.f.)
			nModBkp := nModulo
			cModBkp := cModulo
			nModulo := 5
			cModulo := "FAT"
			cNota := MaPvlNfs(aPvlNfs,cSerie,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
			nModulo := nModBkp
			cModulo := cModBkp		
		EndIf

	endif
		
	if !lErro
		// Atualiza SF2
		If cOpeMov == "2" // transferencia
			cFilDest := FWLoadSM0()[aScan(FWLoadSM0(),{|i| i[18] == If(cCliForA == "C", SA1->A1_CGC, SA2->A2_CGC)}),2]  // Filial de Destino do Veiculo que est· sendo Transferido
		Endif
		DBSelectArea("SF2")
		reclock("SF2",.f.)
		cPrefAnt := SF2->F2_PREFIXO
		SF2->F2_PREFORI := cPrefVEI
		If !Empty(cFilDest)
			SF2->F2_FILDEST := cFilDest
		Endif
		cPrefNF := &(GetNewPar("MV_1DUPREF","cSerie"))
		SF2->F2_PREFIXO := cPrefNF
		msunlock()
		//
		nRecSF2 := SF2->(RecNo())
		//
		If SD2->(FieldPos("D2_CHASSI")) > 0 
			// Atualiza SD2
			DbSelectArea("SD2")
			DbSetOrder(3)
			For nCntFor = 1 to len(aVetAtuSD2)
				If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+aVetAtuSD2[nCntFor,1]+aVetAtuSD2[nCntFor,2])
					RecLock("SD2",.f.)
					SD2->D2_CHASSI := aVetAtuSD2[nCntFor,3]
					msUnlock()
				Endif
			Next
		Endif
		DbSelectArea("VV0")
		DbGoTo(nRecVV0)
		If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura pelo Remito
			reclock("VV0",.f.)
			VV0->VV0_NUMNFI := SF2->F2_DOC
			VV0->VV0_SERNFI := SF2->F2_SERIE
			msunlock()
		EndIf

		DbSelectArea("SE1")
		DbSetorder(1)
		If !Empty(SF2->F2_DUPL)
			cAliasSE1 := GetNextAlias()
			cQuery    := "SELECT SE1.R_E_C_N_O_ RECSE1 "
			cQuery    += "FROM "+RetSqlName("SE1")+" SE1 "
			cQuery    += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND SE1.E1_PREFIXO = '"+cPrefAnt+"' AND SE1.E1_NUM = '"+SF2->F2_DUPL+"' AND  "
			cQuery    += "SE1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasSE1, .F., .T. )
			While ( cAliasSE1 )->(!Eof())
				DbSelectArea("SE1")
				DbGoto(( cAliasSE1 )->RECSE1)
				RecLock("SE1",.f.)
					SE1->E1_PREFIXO := SF2->F2_PREFIXO
					SE1->E1_PREFORI := SF2->F2_PREFORI
				msunlock()
				( cAliasSE1 )->(DbSkip())
			Enddo
			( cAliasSE1 )->( dbCloseArea() )
		EndIf
		
		DBSelectArea("SF2")
		//################################################################
		//# Fim da Emissao da Nota Fiscal de Saida                       #
		//################################################################
		If cTpFatR $ "1/2/4" // 1=Fatura / 2=Remito
			//#############################################################################
			//# Gravacao dos Titulos a receber                                            #
			//#############################################################################
			nParcelas := 0
			//
			for nCntFor := 1 to Len(aIteParc)
				nParcelas++
				if TamSx3("E1_PARCELA")[1] = 1
					cParcela := ConvPN2PC(nParcelas)
				Else
					cParcela := Soma1( strzero(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
				Endif
				//
				DBSelectArea("VS9")
				DBSetOrder(2)
				cVs9Numid := FM_SQL(" SELECT VS9.VS9_NUMIDE FROM "+RetSQLName("VS9")+" VS9 WHERE VS9.VS9_FILIAL = '"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE = '"+VV0->VV0_NUMTRA+"' AND VS9.VS9_TIPOPE = 'V' AND VS9.VS9_VALPAG > 0 AND VS9.VS9_SEQUEN = '"+strzero(nCntFor,2)+"' AND VS9.D_E_L_E_T_ = ' ' ")

				RecLock("VS9",empty(cVs9Numid))
				VS9->VS9_FILIAL := xFilial("VS9")
				VS9->VS9_NUMIDE :=  VV0->VV0_NUMTRA
				VS9->VS9_TIPOPE :=  "V"
				VS9->VS9_TIPPAG := "DP"
				VS9->VS9_DATPAG := aIteParc[nCntFor,1]
				VS9->VS9_VALPAG := aIteParc[nCntFor,2]
				VS9->VS9_REFPAG := cParcela
				VS9->VS9_SEQUEN := strzero(nCntFor,2)
				VS9->(MSUnlock())
			next
		EndIf
		
		if Alltrim(SE4->E4_TIPO)=="A"  .and. aIteParc[1,1] != ctod("")
			DbSelectArea("SF2")
			DbGoTo(nRecSF2)
			RecLock("SF2",.f.)
				SF2->F2_DUPL := cNota // Nro Titulo = Nro NF
			MsUnLock()
		endif
		
		//################################################################
		//# Fim da Emissao da Nota Fiscal de Saida                       #
		//################################################################
		MAFISEND()
		// JANELA DE ABORTO
		If VX001ABORT() .or. cDebugMIL == "VEIXX001SF2"
			DisarmTransaction()
			RollBackSxE()
			lErro := .T.
			break
		EndIf	
	
	EndIf
	//
Else // xTIPDOC == "2" // 1=NF / 2=SD3 (Mov.Internas) - Agrega/Desagrega

	aSB1SD3    := {}
	SB1->(DbSetOrder(7))
	For nCntFor := 1 to len(aCols)
		//
		FGX_VV1SB1("CHAINT", aCols[nCntFor,FG_POSVAR("VVA_CHAINT")] , /* cMVMIL0010 */ , cGruVei )
		// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
		aAdd(aSB1SD3,{	SB1->B1_COD ,;
						1 ,;
						aCols[nCntFor,FG_POSVAR("VVA_VALMOV")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_CENCUS")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_CONTA")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_ITEMCT")] ,;
						aCols[nCntFor,FG_POSVAR("VVA_CLVL")] })
	Next
	SB1->(DbSetOrder(1))
	If !VA3300071_Movimentacoes_Internas( "2" , "1" , xCodVDV , GetNewPar("MV_MIL0115","") , aSB1SD3 ) // Mov.Interna PeÁa ( 2=Saida , 1=Tp.Normal , Codigo VDV , D3_TM , aSB1 )
		DisarmTransaction()
		RollBackSxE()
		lErro := .T.
		break
	EndIf

EndIf
//
END TRANSACTION

DbSelectArea("VV0")
DbGoTo(nRecVV0)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
dbSelectArea("SX6")
MsRUnLock()

if lErro
	return .F.
endif

If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura pelo Remito
	lOkTit := VXX001TIT() // Gerar Financeiro
	If !lOkTit .and. lMostraMsg
		MsgAlert(STR0085,STR0027) // A MovimentaÁ„o de Saida foi Finalizada gerando NF, porÈm existe(m) inconsistÍncia(s) na GeraÁ„o dos Titulos. Favor corrigir a(s) pendÍncia(s) e solicitar novamente a GeraÁ„o dos Titulos. / AtenÁ„o!
	EndIf
EndIf

// ###############################################
// ATUALIZA O STATUS DO VEICULO                  #
// ###############################################
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// ALTERA STATUS DOS VEICULOS
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")],cRotOrigem + " - " + "VX001EMINF_2")
Next
//
If xTIPDOC == "1" // 1=NF / 2=SD3 (Mov.Internas)

	if cOpeMov == "4" .or. ( cOpeMov == "2" .and. Len(aAutoAux) > 0) // DEVOLUCAO
		
		// ATUALIZA O STATUS DA NF PARA DEVOLVIDA OU DEVOLVIDA PARCIALMENTE
		cChave := ""
		if Len(aAutoAux) > 0
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_NFORI" })
			if nPos != 0
				cChave := aAutoAux[1,nPos,2]
			endif
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_SERIORI" })
			if nPos != 0
				cChave += aAutoAux[1,nPos,2]
			endif
			
			cSitNF := "2"
			DBSelectArea("VVF")
			DBSetOrder(6)
			if DBSeek(xFilial("VVF")+cChave)
				DBSelectArea("VVG")
				DbSetOrder(1)
				if !DBSeek(xFilial("VVG")+VVF->VVF_TRACPA)
					Help(" ",1,"ARQITEINCO")
				Endif
				while !eof() .and. xFilial("VVG")+VVF->VVF_TRACPA == VVG->VVG_FILIAL + VVG->VVG_TRACPA
					
					if !FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
						Help(" ",1,"VEINFNEXCD")
						nOpca := 0
						Return (.f.)
					Endif
					
					//					if  VV1->VV1_ULTMOV != "S" .and. VV1->VV1_FILENT == VVF->VVF_FILIAL .and. VV1->VV1_TRACPA == VVF->VVF_TRACPA
					if  VV1->VV1_ULTMOV == "E" .and. VV1->VV1_FILENT == VVF->VVF_FILIAL .and. VV1->VV1_TRACPA == VVF->VVF_TRACPA
						cSitNF := "3"
						exit
					Endif
					
					DBSelectArea("VVG")
					DBSkip()
				enddo
				
				DBSelectArea("VVF")
				reclock("VVF",.f.)
				VVF->VVF_SITNFI := cSitNF//"2"
				msunlock()
				
			Endif
			
		endif
	endif
	//
	dbSelectArea("VV0")
	DbGoTo(nRecVV0)
	//
	if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S" 
		cNroFat := VV0->VV0_NUMNFI
		cSerFat := VV0->VV0_SERNFI
		If cTpFatR == "2" .or. cTpFatR == "4" // 2=Remito
			cNroFat := VV0->VV0_REMITO
			cSerFat := VV0->VV0_SERREM
		EndIf
		//	PE para Impressao da NF de veiculos
		If ExistBlock("NFSAIVEI")
			ExecBlock("NFSAIVEI",.f.,.f.,{cNroFat,cSerFat})
		Endif
	EndIF
	//
	if lMostraMsg
		If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura pelo Remito
			FMX_TELAINF( "1" , { { Alltrim(VV0->VV0_SERNFI) , Alltrim(VV0->VV0_NUMNFI) , If( cPaisLoc == "BRA" , STR0042, STR0124 ) } } ) // "EMITIDO" # GENERADA
		ElseIf cTpFatR == "2" .or. cTpFatR == "4" // 2=Remito
			FMX_TELAINF( "1" , { { Alltrim(VV0->VV0_SERREM) , Alltrim(VV0->VV0_REMITO) , If( cPaisLoc == "BRA" , STR0042, STR0124 ) } } ) // "EMITIDO"
		EndIf
	endif

	if cOpeMov $ "6/7" // RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
		// ATUALIZA O STATUS DA NF PARA DEVOLVIDA
		cChave := ""
		if Len(aAutoAux) > 0
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_NFORI" })
			if nPos != 0
				cChave := aAutoAux[1,nPos,2]
			endif
			nPos := ascan(aAutoAux[1],{|x| x[1] == "C6_SERIORI" })
			if nPos != 0
				cChave += aAutoAux[1,nPos,2]
			endif
			DBSelectArea("VVF")
			dbClearFilter()
			DBSetOrder(6)
			if DBSeek(xFilial("VVF")+cChave)
				RecLock("VVF",.F.)		    
				VVF->VVF_SITNFI := "2"
				MsUnlock()
			endif
			FilBrowse('VVF',{},'VVF->VVF_OPEMOV=="4" .AND. VVF->VVF_SITNFI=="1" .AND. !Empty(VVF->VVF_NUMNFI) .AND. xFilial("VVF")==VVF->VVF_FILIAL .AND. VXA017FIL()')
		endif
	Endif

Else // xTIPDOC == "2" // 1=NF / 2=SD3 (Mov.Internas)

	if lMostraMsg
		FMX_TELAINF( "4" , { { STR0087 , If( cPaisLoc == "BRA" , STR0042, STR0124 ) } } ) // Mov.Interna / EMITIDO
	EndIf

EndIf
//
Return(.t.)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001CANCEL  | Autor |  Luis Delorme        | Data | 31/07/00 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo |Cancelamento de Nota Fiscal - Veiculos Normais                |##
##+----------+--------------------------------------------------------------+##
##|Uso       |Veiculos  (Modelo3)                                           |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001CANCEL(cRotOrigem)
Local nCntFor, cont2
Local aUltMov := {}
Local lNFeCancel  := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(FieldPos("F2_STATUS")) > 0
local cQVW0 := "TVW0"
Local lErro := .F.
Local lTestaRemito := cPaisLoc $ "ARG,MEX"
Local aInfo

If VV0->VV0_TIPDOC == "2" // 1 = NF / 2 = Mov.Internas (SD3)
	FMX_HELP(STR0086,STR0027) // Esta Saida se trata de Mov.Interna. Impossivel continuar! / Atencao
	Return .f.
EndIf

// VERIfICA SE A NF ESTA CANCELADA OU DEVOLVIDA
If VV0->VV0_SITNFI # "1"   // NF nao-valida
	FMX_HELP(STR0044 ,STR0027) //Nota Fiscal esta cancelada ou devolvida./### atencao
	Return(.f.)
EndIf
//
DBSelectArea("SF2")
DBSetOrder(1)

If !dbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI) .and. (!cPaisLoc $ "ARG,MEX" .or. !dbSeek(xFilial("SF2")+VV0->VV0_REMITO+VV0->VV0_SERREM))
	FMX_HELP(STR0080+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0081+VV0->VV0_NUMNFI+" / "+VV0->VV0_SERNFI,STR0061)
	Return(.f.)
EndIf
//
dbSelectArea("SD2")
dbSetOrder(3)
If !dbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI) .and. (!cPaisLoc $ "ARG,MEX" .or. !dbSeek(xFilial("SD2")+VV0->VV0_REMITO+VV0->VV0_SERREM))
	FMX_HELP(STR0080+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0081+VV0->VV0_NUMNFI+" / "+VV0->VV0_SERNFI,STR0061)
	Return(.f.)
EndIf
//
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//| Ponto de Entrada para validacao do Cancelamento de NF |
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If ExistBlock("VX001CNF")
	lRet := ExecBlock("VX001CNF",.f.,.f.)
	If !lRet
		Return.f.
	EndIf
EndIf
//
// ARMAZENA A NF DE ORIGEM PARA ALTERAR STATUS CASO HAJA CANCELAMENTO (cOpeMov = "4")
cChaveOri := SD2->D2_NFORI+SD2->D2_SERIORI
//
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	//
	// VERIFICAR SE A MOVIMENTACAO SELECIONADA EH A ULTIMA
	//
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")], cRotOrigem + " - " + "VX001CANCEL")
	DBSelectArea("VV1")
	DBSetOrder(2)
	DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
	If !(FM_PILHA("VEIXA040")) 
		aUltMov := FGX_VEIMOVS( aCols[nCntFor,FG_POSVAR("VVA_CHASSI")] , , )
		If len(aUltMov) > 0
			If aUltMov[1,1] == "E" .or. aUltMov[1,2] <> VV0->VV0_FILIAL .or. aUltMov[1,3] <> VV0->VV0_NUMTRA
				FMX_HELP(STR0023+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0045+" "+STR0046+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0047+": "+Alltrim(VV1->VV1_CHASSI),STR0027)//Impossivel Continuar ### Um dos veiculos constantes da nota fiscal sofreu movimentacao # posterior a sua emissao. # chassi             ### atencao
				Return .f.
			EndIf
		EndIf
	EndIf
Next
//################################################################
//# Cancela o documento de saida                                 #
//################################################################
aRegSD2 := {}
aRegSE1 := {}
aRegSE2 := {}

aLocaliz := {}
if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
	For nCntFor = 1 to len(acols)
		n = nCntFor
		// pula registros deletados
		If aCols[nCntFor,len(aHeader)+1]
			loop
		EndIf
		//
		// VERIFICAR SE A MOVIMENTACAO SELECIONADA EH A ULTIMA
		//
		DBSelectArea("VV1")
		DBSetOrder(2)
		DBSeek(xFilial("VV1")+aCols[nCntFor,FG_POSVAR("VVA_CHASSI")])
		//
		FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
		//
		if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
			if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
				msunlock()
				aAdd(aLocaliz,{SB1->B1_COD,SB1->B1_LOCPAD,SB5->B5_LOCALI2})
			else
				aRet := {}
				aParamBox := {}
				MsgInfo(STR0062,STR0061)
				VZL->(DBSetOrder(1))
				aAdd(aParamBox,{1,STR0063,Space(2),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01))","NNR","",0,.F.})
				aAdd(aParamBox,{1,STR0064,Space(15),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01+MV_PAR02))","VZL","",0,.F.})
				lContinua := .f.
				while !lContinua
					If !(ParamBox(aParamBox,STR0065+Alltrim(VV1->VV1_CHASSI),@aRet))
						if MsgYesNo(STR0066,STR0061)
							aAdd(aLocaliz,{SB1->B1_COD,"",""})
							lContinua := .t.
						endif
					else
						DBSelectArea("VZL")
						DBSetOrder(1)
						if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
							if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
								aAdd(aLocaliz,{SB1->B1_COD,aRet[1],aRet[2]})
								lContinua := .t.
							endif
						endif
					Endif
				enddo
			endif
		endif
	next
endif

if GetNewPar("MV_LOCVZL","N")=="S" .and. Len(aLocaliz) > 0  // USA LOCALIZACAO DE VEICULOS    TODO: LOCALIZACAO
	nIndLocali := 0
	For nCntFor = 1 to len(acols)
		n = nCntFor
		// pula registros deletados
		If aCols[nCntFor,len(aHeader)+1]
			loop
		EndIf
		nIndLocali++
		DBSelectArea("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+aLocaliz[nIndLocali,1])
		//
		DBSelectArea("SB5")
		DBSetOrder(1)
		DBSeek(xFilial("SB5")+SB1->B1_COD)
		//
		DBSelectArea("VZL")
		DBSetOrder(1)
		if DBSeek(xFilial("VZL")+aLocaliz[nIndLocali,2]+aLocaliz[nIndLocali,3])
			if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
				reclock("VZL",.f.)
				VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
				msunlock()
			else
				MsgStop(STR0067+aLocaliz[nIndLocali,2]+"/"+aLocaliz[nIndLocali,3]+STR0068,STR0061)
				return .f.
			endif
		endif
	next
endif

lMsErroAuto := .f.

dbSelectArea("SF2")
dbSetOrder(1)
dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
//
cNumTit := SF2->F2_DUPL
cPrefNF := SF2->F2_PREFIXO

// Transmite o Cancelamento para o SEFAZ automaticamente
conout("VEIXX001 - ENTROU NO PROCESSO DE CANCELAMENTO:  "+Dtoc(dDataBase)+" - "+Time())
If lNFeCancel
	If !FGX_STATF2("D",VV0->VV0_SERNFI,VV0->VV0_NUMNFI,VV0->VV0_CODCLI,VV0->VV0_LOJA,"S") // verifica se NF foi Deletada
		//################################################################
		//# VerIfica se o estorno do documento de saÌda pode ser feito   #
		//################################################################
		If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
			// Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2,
			// Array com os registro do SE1, Array com os registro do SE2 )
			//
			//################################################################
			//# Estorna o documento de saida                                 #
			//################################################################
			PERGUNTE("MTA521",.f.)
			conout("VEIXX001 - CHAMOU O MADELNFS:  "+Dtoc(dDataBase)+" - "+Time())
			If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1),(mv_par03 == 1), (mv_par04 == 1)))
				Return(.f.)
			Endif
			conout("VEIXX001 - RETONO POSITIVO DO MADELNFS:  "+Dtoc(dDataBase)+" - "+Time())
		Else
			//Nao pode ser excluida.
			Return(.f.)
		EndIf          
		If !FGX_STATF2("V",VV0->VV0_SERNFI,VV0->VV0_NUMNFI,VV0->VV0_CODCLI,VV0->VV0_LOJA,"S") /// Verifica STATUS da NF no SEFAZ
			Return(.f.)
		Endif
	Endif
Endif

// TODO - Cancelamento da argentina ou Mexico est· fora da transaÁ„o devido a um problema no execauto da Mata467n (MSRUNLOCK dentro de transaÁ„o). Ajustar quando for corrigido.
If !lNFeCancel .and. cPaisLoc $ "ARG,MEX"
	If !Empty(VV0->VV0_NUMNFI) .and. !VX0010058_CancNFArg(VV0->VV0_NUMNFI, VV0->VV0_SERNFI, "1")
		lErro := .T.
	Endif
	If !lErro .and. !Empty(VV0->VV0_REMITO) .and. !VX0010058_CancNFArg(VV0->VV0_REMITO, VV0->VV0_SERREM , "2" )
		lErro := .T.
	Endif
EndIf

if !lErro

	BEGIN TRANSACTION

	If !lNFeCancel .and. cPaisLoc == "BRA"

		//################################################################
		//# VerIfica se o estorno do documento de saÌda pode ser feito   #
		//################################################################
		If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
			// Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2,
			// Array com os registro do SE1, Array com os registro do SE2 )
			//
			//################################################################
			//# Estorna o documento de saida                                 #
			//################################################################
			PERGUNTE("MTA521",.f.)
			SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,;
			(mv_par01 == 1), (mv_par02 == 1),;
			(mv_par03 == 1), (mv_par04 == 1)))
		Else
			//Nao pode ser excluida.
			lMsErroAuto:= .T.
			lErro := .T.
			break
		EndIf

	Endif
	
	// conout("VEIXX001 - INICIOU O PROCESSO DE EXCLUS√O DO PEDIDO DE VENDAS:  "+Dtoc(dDataBase)+" - "+Time())
	dbSelectArea("SC5")
	dbSetOrder(1)
	
	for nCntFor := 1 to Iif(lTestaRemito, 2, 1)
		If dbSeek(xFilial("SC5") + Iif(nCntFor == 1, VV0->VV0_NUMPED, VV0->VV0_PEDREM))

			aMata410Cab   := {{"C5_NUM", SC5->C5_NUM, nil}}   //Numero do pedido SC5
			aMata410Itens := {{"C6_NUM", SC5->C5_NUM, nil}}   //Numero do Pedido SC6

			//Exclui Pedido
			SC9->(dbSetOrder(1))
			SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM))
			While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. SC5->C5_NUM == SC9->C9_PEDIDO
				SC9->(a460Estorna())
				SC9->(dbSkip())
			EndDo

			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| Mata410(x,y,z)}, aMata410Cab, { aMata410Itens }, 5)

			If lMsErroAuto
				DisarmTransaction()
				lErro := .T.
				break
			EndIf
		EndIf
	next

	//
	If !Empty(cNumTit)
		dbSelectArea("SE1")
		dbSetOrder(1)
		If dbSeek(xFilial("SE1")+cPrefNF+cNumTit)
			aParcelas := {}
			while !Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO == cPrefNF .and. SE1->E1_NUM == cNumTit
				AADD(aParcelas,{;
				{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
				{"E1_NUM"     ,E1_NUM     ,nil},;
				{"E1_PARCELA" ,E1_PARCELA ,nil},;
				{"E1_TIPO"    ,E1_TIPO    ,nil},;
				{"E1_NATUREZA",E1_NATUREZA,nil},;
				{"E1_CLIENTE" ,E1_CLIENTE ,nil},;
				{"E1_LOJA"    ,E1_LOJA    ,nil},;
				{"E1_EMISSAO" ,E1_EMISSAO ,nil},;
				{"E1_VENCTO"  ,E1_VENCTO  ,nil},;
				{"E1_VENCREA" ,E1_VENCREA ,nil},;
				{"E1_VALOR"   ,E1_VALOR   ,nil},;
				{"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
				{"E1_DATABOR" ,E1_DATABOR ,Nil},;
				{"E1_PORTADO" ,E1_PORTADO ,Nil},;
				{"E1_SITUACA" ,E1_SITUACA ,Nil}})
				dbSelectArea("SE1")
				dbSkip()
			Enddo
			//
			pergunte("FIN040",.F.)
			For cont2 := 1 to len(aParcelas)
				lMsErroAuto := .f.
				MSExecAuto({|x,y| FINA040(x,y)},aParcelas[cont2],5)
				If lMsErroAuto
					DisarmTransaction()
					lErro := .T.
					break
				EndIf
			Next
		EndIf
		//	
		dbSelectArea("SA1")
		dbSetOrder(1)
		DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		//
		dbSelectArea("SA2")
		dbSetOrder(3)
		If DbSeek(xFilial("SA2")+SA1->A1_CGC)
			//
			dbSelectArea("SA2")
			dbSetOrder(1)
			//
			dbSelectArea("SE2")
			dbSetOrder(6)
			If dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefNF+cNumTit)           
				//
				aParcelas := {}
				while ! Eof() .and. SE2->E2_FILIAL == xFilial('SE2') .and. SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == SA2->A2_COD+SA2->A2_LOJA+cPrefNF+cNumTit
			
						AADD(aParcelas,{{"E2_PREFIXO" ,E2_PREFIXO ,nil},;
						{"E2_NUM"     ,E2_NUM     ,nil},;
						{"E2_PARCELA" ,E2_PARCELA ,nil},;
						{"E2_TIPO"    ,E2_TIPO    ,nil},;
						{"E2_NATUREZA",E2_NATUREZA,nil},;
						{"E2_FORNECE" ,E2_FORNECE ,nil},;
						{"E2_LOJA"    ,E2_LOJA    ,nil},;
						{"E2_EMISSAO" ,E2_EMISSAO ,nil},;
						{"E2_VENCTO"  ,E2_VENCTO  ,nil},;
						{"E2_VENCREA" ,E2_VENCREA ,nil},;
						{"E2_VALOR"   ,E2_VALOR   ,nil},;
						{"E2_NUMBOR"  ,E2_NUMBOR  ,Nil} })
					
					dbSelectArea("SE2")
					dbSkip()
				Enddo
	
				dbSelectArea("SE2")
				dbSetOrder(1)
				//
				pergunte("FIN050",.F.)
				For cont2 := 1 to len(aParcelas)
					lMsErroAuto := .f.
					MSExecAuto({|x,y,z| FINA050(x,y,z)},aParcelas[cont2],,5)
					If lMsErroAuto
						DisarmTransaction()
						lErro := .T.
						break
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	//
	// SINALIZA O CANCELAMENTO NO VV0
	//
	DBSelectArea("VV0")
	reclock("VV0",.f.)
	VV0->VV0_SITNFI := "0"
	VV0->VV0_STATUS := "C"
	conout("VEIXX001 - VOLTOU STATUS DO VEICULO:  "+Dtoc(dDataBase)+" - "+Time())
	if cOpeMov $ "6/7"  // RETORNO DE REMESSA/ RETORNO DE CONSIGNADO
		// ATUALIZA O STATUS DA NF PARA DEVOLVIDA
		DBSelectArea("VVF")
		dbClearFilter()
		DBSetOrder(6)
		if DBSeek(xFilial("VVF")+cChaveOri)
		    RecLock("VVF",.F.)		    
			VVF->VVF_SITNFI := "1"
			MsUnlock()
		Endif
		FilBrowse('VVF',{},'VVF->VVF_OPEMOV=="4" .AND. VVF->VVF_SITNFI=="1" .AND. !Empty(VVF->VVF_NUMNFI) .AND. xFilial("VVF")==VVF->VVF_FILIAL .AND. VXA017FIL()')
	Endif
	msunlock()
	
if FWAliasInDic("VW0")
	cQuery := "SELECT R_E_C_N_O_ VW0RECNO FROM " + RetSQLName("VW0") + " VW0 WHERE VW0.VW0_FILSAI = '" + VV0->VV0_FILIAL + "' AND VW0.VW0_NUMTRA = '" + VV0->VV0_NUMTRA + "' AND VW0.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQVW0, .F., .T. )
	While ! (cQVW0)->(Eof())

		VW0->(dbGoTo( (cQVW0)->VW0RECNO ) )
		reclock("VW0",.f.)
		VW0->VW0_STSAI := "0"
		VW0->(MsUnlock())
		(cQVW0)->(dbSkip())
	end

	(cQVW0)->(dbCloseArea())
endif
//
	END TRANSACTION

endif
if lErro
	return .F.
endif
//
// ###############################################
// ATUALIZA O STATUS DO VEICULO                  #
// ###############################################
For nCntFor = 1 to len(acols)
	n = nCntFor
	// pula registros deletados
	If aCols[nCntFor,len(aHeader)+1]
		loop
	EndIf
	// ALTERA STATUS DOS VEICULOS
	FGX_AMOVVEI(xFilial("VV1"),aCols[nCntFor,FG_POSVAR("VVA_CHASSI")], cRotOrigem + " - " + "VX001CANCEL")
Next
//
if cOpeMov == "4" // DEVOLUCAO
	// ATUALIZA O STATUS DA NF DE "DEVOLVIDA" PARA "VALIDA"
	cSitNF := "1"
	nContVVG := 0
	nContVV1 := 0
	DBSelectArea("VVF")
	DBSetOrder(6)
	if DBSeek(xFilial("VVF")+cChaveOri)
		if !FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
			Help(" ",1,"ARQITEINCO")
		Endif
		while !eof() .and. xFilial("VVG")+VVF->VVF_TRACPA == VVG->VVG_FILIAL + VVG->VVG_TRACPA
			nContVVG++
			if !FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
				Help(" ",1,"VEINFNEXCD")
				nOpca := 0
				Return (.f.)
			Endif
			
			if VV1->VV1_ULTMOV == "E" .and. VV1->VV1_FILENT == VVF->VVF_FILIAL .and. VV1->VV1_TRACPA == VVF->VVF_TRACPA
				nContVV1++
			Endif
			
			DBSelectArea("VVG")
			DBSkip()
		enddo
		If nContVV1 == nContVVG
			cSitNF := "1"
		Else
			cSitNF := "3"
		Endif
		
		reclock("VVF",.f.)
		VVF->VVF_SITNFI := cSitNF
		msunlock()
	endif
endif
//
dbSelectArea("VV0")
//
if lMostraMsg
	aInfo := {}
	if cPaisLoc $ "ARG,MEX" .and. !Empty(VV0->VV0_REMITO) // Com Remito
		AAdd(aInfo, { Alltrim(VV0->VV0_SERREM) , Alltrim(VV0->VV0_REMITO) , STR0048} ) // "CANCELADO"
	endif
	if !Empty(VV0->VV0_NUMNFI) // Com Fatura
		AAdd(aInfo, { Alltrim(VV0->VV0_SERNFI) , Alltrim(VV0->VV0_NUMNFI) , STR0048 } ) // "CANCELADO"
	endif
	FMX_TELAINF( "1" , aInfo )
endif
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001DLIN   | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Atualiza informacoes quando a linha da acols e deletada      |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001DLIN()
//
If aCols[n,Len(aCols[n])]
	aCols[n,Len(aCols[n])] := .f.
Else
	aCols[n,Len(aCols[n])] := .t.
EndIf
If lAtuFiscal // Atualiza Fiscal
	MaFisDel(n,aCols[n,Len(aCols[n])])
EndIf
//
VX001FIELDOK()
//
oGetDados:obrowse:SetFocus()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001KEYF4  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Chamada da tecla de atalho <F4>. Executa comandos dependen-  |##
##|          | do do campo selecionado ( ReadVar() ).                       |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001KEYF4()
If ReadVar() == "M->VVA_CHASSI"
	DBSelectArea("VV1")
	DBSetOrder(2)
	If DBSeek(xFilial("VV1")+M->VVA_CHASSI)
		//VXA010A("VV1",RecNo(),3)
		VA0700113_AlteracaoChassi()
	EndIf
EndIf
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001ABORT  | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Janela de aborto. Podera ser chamada apenas dentro de tran-  |##
##|          | sacoes. Exibe uma mensagem e seta o lMsErroAuto para .t.     |##
##|          | caso o usuario tenha optado por abortar a operacao           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001ABORT()
//
If lAbortPrint
	
	If MsgYesNo(STR0049,STR0027)	//Tem certeza que deseja abortar esta operacao ?"###"Atencao
		Help("  ",1,"M160PROABO")
		DisarmTransaction()
		Return .t.
	Else
		lAbortPrint := .F.
	EndIf
EndIf

Return .f.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001BRWNOME| Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Browse do Nome do Cliente/Fornecedor - Depependendo do tipo  |##
##|          | de operacao a funcao retorna o cliente ou o fornecedor.      |##
##|          | As operacoes de remessa, consignacao e devolucao tomam o     |##
##|          | fornecedor ao inves do cliente. As demais utilizam o cliente |##
##|          | (padrao).                                                    |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001BRWNOME()
Local cAlias := Alias()
Local nRecSA1 := SA1->(RecNo())
Local nRecSA2 := SA2->(RecNo())
Local cNome
//
If VV0->VV0_OPEMOV == "4"  .or. (cCliForA <> "C")
	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cNome :=  SA2->A2_NREDUZ
Else
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cNome :=  SA1->A1_NREDUZ
EndIf
//
SA1->(DBGoTo(nRecSA1))
SA1->(DBGoTo(nRecSA2))
//
DBSelectArea(cAlias)
//
Return cNome


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001RECALC | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Recalculo das Variaveis Fiscais                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001RECALC()
Local nCntAcols
Local nCntAcorc
//
If FM_PILHA("VEIXX002") // Retornar .T. quando for Atendimento de Veiculos
	Return .t.
EndIf
//
If lAtuFiscal // Atualiza Fiscal
	// A ROTINA ATUALIZA OS CAMPOS DA INTEGRACAO FISCAL
	For nCntAcols = 1 to len(acols)
		n = nCntAcols
		If MaFisFound("IT",n)
			/*CI 010134 - NESSA FUN«√O, DEVE ATUALIZAR APENAS OS VALORES DE IMPOSTOS*/
			If (cPaisLoc == "BRA")
				M->VVA_ALIIPI := acols[n,FG_POSVAR("VVA_ALIIPI")] := MaFisRet(n,"IT_ALIQIPI")
				M->VVA_VBAICM := aCols[n,FG_POSVAR("VVA_VBAICM")] := MaFisRet(n,"IT_BASEICM")
				M->VVA_ALIICM := aCols[n,FG_POSVAR("VVA_ALIICM")] := MaFisRet(n,"IT_ALIQICM")
				M->VVA_ICMVEN := aCols[n,FG_POSVAR("VVA_ICMVEN")] := MaFisRet(n,"IT_VALICM")
				M->VVA_PISVEN := aCols[n,FG_POSVAR("VVA_PISVEN")] := MaFisRet(n,"IT_VALPS3") // est· gravando o ST no campo.... ok...
				M->VVA_COFVEN := aCols[n,FG_POSVAR("VVA_COFVEN")] := MaFisRet(n,"IT_VALCF3") // est· gravando o ST no campo.... ok...
			endif
			//
			// ATUALIZA O FOLDER 1 (INFORMACOES DA NF)
			//
			for nCntAcorc := 1 to Len(aOrc)
				aOrc[nCntAcorc,3] := &(aOrc[nCntAcorc,1])
			next
			if !lVX001Auto
				olBox:nAt := 1
				olBox:SetArray(aOrc)
				olBox:bLine := { || {  aOrc[olBox:nAt,2],;
				FG_AlinVlrs(Transform(aOrc[olBox:nAt,3],"@E 999,999,999.99")) }}
				olBox:SetFocus()
				olBox:Refresh()
			endif
			//
			// ATUALIZA COMO PAGAR
			VX001ATUCP()
			//
		EndIf
		//
	next
EndIf
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |VX001TES    | Autor |  Luis Delorme         | Data | 27/01/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Verificacao de passagem do TES para MAFISREF                 |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001VTES()
Local lRet := .t.
If lAtuFiscal // Atualiza Fiscal
	lRet := .f.
	DBSelectArea("SF4")
	DBSetOrder(1)
	if dbSeek(xFilial("SF4")+M->VVA_CODTES)
		lRet := MaFisRef("IT_TES","VX001",M->VVA_CODTES)
	EndIf
endif
return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |  VX001VNFE | Autor |  BOBY-Antonio         | Data | 31/08/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Preenchiento automatico de valores trazidos da NF de entrada.|##
##|          | FNC 18966                                                    |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001VNFE()

Local aArea := GetArea()
Local lRet  := .T.

DBSelectArea("VVG")
DBSetOrder(2)
If DBSeek(xFilial("VVG")+aCols[n,FG_POSVAR("VVA_CHAINT")])
	aCols[n,FG_POSVAR("VVA_VALVDA")] := M->VVA_VALVDA:= VVG->VVG_VALUNI
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|FunáÑo    |  VX001RB1  | Autor |  Luis Delorme         | Data | 12/11/10 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|DescriáÑo | Funcao para trigeer do tes inteligente (ver sx7)             |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function VX001RB1()
	FGX_VV1SB1("CHAINT", M->VVA_CHAINT , /* cMVMIL0010 */ , /* cGruVei */ )
return SB1->B1_COD
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ VX001MFORTE  ∫Autor  ≥ Rubens         ∫ Data ≥  21/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Calcula Valores em Moeda Forte                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VX001MFORTE(cChaInt)

if cPaisLoc <> "BRA"
	return
endif

// Posiciona no Veiculo para Procurar a Transacao de Entrada
VV1->(dbSetOrder(1))
VV1->(dbSeek(xFilial("VV1") + cChaInt ))

VVA->VVA_VMFMOV := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALMOV}} )
VVA->VVA_CMFVDE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_COMVDE}} )
VVA->VVA_CMFGER := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_COMGER}} )
VVA->VVA_SMFVIA := FG_CalcMF({ {FG_RtDtCV("SGV",VV1->VV1_CODMAR,M->VV0_DATMOV),VVA->VVA_SEGVIA} })
VVA->VVA_VMFASS := FG_CalcMF({ {FG_RtDtCV("ASS",VV1->VV1_CODMAR,M->VV0_DATMOV),VVA->VVA_VALASS} })
VVA->VVA_RMFTEC := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_RECTEC}} )
VVA->VVA_BMFFAB := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_BONFAB}} )
If VVA->(FieldPos("VVA_BMFREG"))>0 .and. VVA->(FieldPos("VVA_BONREG"))>0
	VVA->VVA_BMFREG := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_BONREG}} )
EndIf
If VVA->(FieldPos("VVA_BMFCON"))>0 .and. VVA->(FieldPos("VVA_BONCON"))>0
	VVA->VVA_BMFCON := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_BONCON}} )
EndIf
VVA->VVA_VMFVDA := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALVDA}} )
VVA->VVA_RMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_RECVEI}} )
VVA->VVA_IMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ICMVEN}} )
VVA->VVA_PMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_PISVEN}} )
VVA->VVA_CMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_COFVEN}} )
VVA->VVA_IMFRTE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ISSRTE}} )
VVA->VVA_PMFRTE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_PISRTE}} )
VVA->VVA_PMFBFB := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_PISBFB}} )
VVA->VVA_IMFBFB := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ISSBFB}} )
VVA->VVA_VMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VCAVEI}} )
VVA->VVA_RMFCUS := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_REDCUS}} )
VVA->VVA_VMFFRE := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALFRE}} )
VVA->VVA_AMFSSO := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_ACESSO}} )
VVA->VVA_DMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_DESVEI}} )
VVA->VVA_DMFCLI := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_DESCLI}} )
VVA->VVA_VMFREV := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_VALREV}} )
VVA->VVA_JMFEST := FG_CalcMF(  {{M->VV0_DATMOV,VVA->VVA_JUREST}} )
VVA->VVA_FMFTOT := VVA->VVA_VMFMOV+VVA->VVA_CMFCOT+VVA->VVA_CMFCTP+VVA->VVA_RMFTEC+VVA->VVA_BMFFAB
VVA->VVA_TMFCUS := FG_FORMULA(GetNewPar("MV_TMFCUFN","VVA->VVA_VMFVEI-VVA->VVA_RMFCUS+VVA->VVA_JMFEST+VVA->VVA_VMFFRE+VVA->VVA_AMFSSO+VVA->VVA_VMFSCO+VVA->VVA_PMFENT+VVA->VVA_CMFENT"))
VVA->VVA_TMFIMP := VVA->VVA_IMFVEN+VVA->VVA_IMFCVD+VVA->VVA_PMFVEN+VVA->VVA_CMFVEN+VVA->VVA_IMFRTE+VVA->VVA_PMFRTE+VVA->VVA_IMFBFB+VVA->VVA_PMFBFB
VVA->VVA_LMFBRU := VVA->VVA_FMFTOT-VVA->VVA_TMFIMP-VVA->VVA_VMFVEI-VVA->VVA_VMFFRE
VVA->VVA_LMFLQ1 := VVA->VVA_LMFBRU-VVA->VVA_JMFEST-VVA->VVA_AMFSSO-VVA->VVA_VMFSCO-VVA->VVA_DMFCLI-VVA->VVA_SMFVIA-VVA->VVA_VMFASS-VVA->VVA_VMFREV-VVA->VVA_DMFVEI-VVA->VVA_AMFIMP-VVA->VVA_CMFVDE-VVA->VVA_CMFGER-VVA->VVA_CMFPAT //LUCRO MARGINAL
VVA->VVA_LMFLQ2 := VVA->VVA_LMFLQ1-VVA->VVA_DMFFIX+(VVA->VVA_RMFCUS+VVA->VVA_RMFVEI-VVA->VVA_DMFFIN) //LAIR

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ VX001CLIFOR  ∫Autor  ≥ Thiago         ∫ Data ≥  10/04/15   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao do campo VV0_CLIFOR.                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VX001CLIFOR()
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Saida por Venda   ou   Saida por Remessa   ou   Saida por Transferencia   ou   Saida por Consignacao //
//////////////////////////////////////////////////////////////////////////////////////////////////////////
If ReadVar() == "M->VV0_CLIFOR"
	If !Empty(M->VV0_CLIFOR)
		cCliForA := M->VV0_CLIFOR
	Endif              
Endif

If FM_PILHA("VEIXA011") .or. FM_PILHA("VEIXA013") .or. FM_PILHA("VEIXA014") .or. FM_PILHA("VEIXA015")
	
	if cCliForA == "C" //cOpeMov $ "35" .and. cCliForA == "C"
		oSayE18:lVisible := .f.
		oSayE21:lVisible := .t.
		oGetE21:cf3 := "SA1"
	Else
		oSayE21:lVisible := .f.
		oSayE18:lVisible := .t.
		oGetE21:cf3 := "FOR"
	Endif        
Endif
Return(.t.)
           
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ VX001VALCLI  ∫Autor  ≥ Thiago         ∫ Data ≥  14/03/17   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao do campo Loja do cliente.                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VX001VALCLI()
if Empty(M->VV0_CLIENT) .or. Empty(M->VV0_LOJENT)    
	M->VV0_CLIENT := M->VV0_CODCLI
	M->VV0_LOJENT := M->VV0_LOJA 
Endif
Return(.t.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ VXX001TIT  ∫Autor  ≥ Andre Luis Almeida ∫ Data ≥  14/03/17 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Validacao do campo Loja do cliente.                        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VXX001TIT() // Gerar Financeiro
Local lRet      := .t.
Local _nRecSA1  := 0
Local cSQLAlias := "SQLVS9"
Local cQuery    := ""
Local cNumBord  := ""
Local dDatBord  := cTod("")
Local cPrefVEI  := GetNewPar("MV_PREFVEI","VEI")
Local aTitulo   := {}
Local nPerJur   := SuperGetMv("MV_TXPER")
//
// COMECAR NOVA TRANSACAO PARA O FINANCEIRO
BEGIN TRANSACTION
//
SF2->( DbSetOrder(1) )
SF2->( DbSeek( xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI ) )
//
If VX0010111_SE4_Tipo_A( SF2->F2_COND ) // Negociada
//
	SA6->( DbSetOrder(1) )
	SA6->( DbSeek( xFilial("SA6") + VV0->VV0_CODBCO ) )
	If SA6->A6_BORD == "0"
		cNumBord := "BCO"+SA6->A6_COD
		dDatBord := dDataBase
	EndIf
	//
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
	_nRecSA1 := SA1->( Recno() )//salva posicao SA1
	//
	SA3->( DbSetOrder(1) )
	SA3->( MsSeek( xFilial("SA3") + VV0->VV0_CODVEN ) )
	//
	cQuery := "SELECT VS9.VS9_TIPPAG , VS9.VS9_DATPAG , VS9.VS9_VALPAG , VS9.VS9_REFPAG "
	cQuery += "  FROM "+RetSQLName("VS9")+" VS9 "
	cQuery += " WHERE VS9.VS9_FILIAL = '"+xFilial("VS9")+"'"
	cQuery += "   AND VS9.VS9_NUMIDE = '"+VV0->VV0_NUMTRA+"'"
	cQuery += "   AND VS9.VS9_TIPOPE = 'V'"
	cQuery += "   AND VS9.VS9_VALPAG > 0 "
	cQuery += "   AND VS9.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->( Eof() )
		aTitulo := {{"E1_PREFIXO" ,SF2->F2_PREFIXO									,Nil},;
					{"E1_NUM"     ,SF2->F2_DOC 										,Nil},;
					{"E1_PARCELA" ,Alltrim((cSQLAlias)->( VS9_REFPAG ))				,Nil},;
					{"E1_TIPO"    ,(cSQLAlias)->( VS9_TIPPAG )						,Nil},;
					{"E1_NATUREZ" ,VV0->VV0_NATFIN									,Nil},;
					{"E1_SITUACA" ,IIf(!Empty(VV0->VV0_CODBCO),"1","0")				,Nil},;
					{"E1_CLIENTE" ,SA1->A1_COD										,Nil},;
					{"E1_LOJA"    ,SA1->A1_LOJA										,Nil},;
					{"E1_EMISSAO" ,dDataBase										,Nil},;
					{"E1_VENCTO"  ,stod((cSQLAlias)->( VS9_DATPAG ))				,Nil},;
					{"E1_VENCREA" ,DataValida(stod((cSQLAlias)->( VS9_DATPAG )))	,Nil},;
					{"E1_VALOR"   ,(cSQLAlias)->( VS9_VALPAG )						,Nil},;
					{"E1_NUMBOR"  ,cNumBord											,Nil},;
					{"E1_DATABOR" ,dDatBord											,Nil},;
					{"E1_PORTADO" ,VV0->VV0_CODBCO									,Nil},;
					{"E1_PREFORI" ,cPrefVEI 										,Nil},;
					{"E1_VEND1"  , SA3->A3_COD										,nil},;
					{"E1_COMIS1" , SA3->A3_COMIS									,nil},;
					{"E1_BASCOM1", (cSQLAlias)->( VS9_VALPAG )						,nil},;
					{"E1_PEDIDO" , VV0->VV0_NUMPED									,nil},;
					{"E1_NUMNOTA", SF2->F2_DOC										,nil},;
					{"E1_ORIGEM" , "MATA460"										,nil},;
					{"E1_SERIE"  , SF2->F2_SERIE									,nil},;
					{"E1_PORCJUR", nPerJur											,nil},;
					{"E1_VALJUR" , Round((cSQLAlias)->( VS9_VALPAG ) * (nPerJur / 100),2)				,nil},;
					{"E1_LA"     , "S"											    ,nil}}
		If lMultMoeda
			aAdd(aTitulo[1],{"E1_MOEDA"  ,SF2->F2_MOEDA  ,nil}) // Moeda
			aAdd(aTitulo[1],{"E1_TXMOEDA",SF2->F2_TXMOEDA,nil}) // Taxa Moeda
		EndIf
		//
		lMsErroAuto := .f.
		//
		pergunte("FIN040",.F.)
		MSExecAuto({|x| FINA040(x)},aTitulo)
		SA1->( Dbgoto( _nRecSA1 ) )	//volta posicao SA1
		//
		If lMsErroAuto
			DisarmTransaction()
			RollBackSxE()
			MostraErro()
			lRet := .f.
			Exit
		EndIf
		//
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VV0")
//
EndIf
//
END TRANSACTION
//

If lRet // Gerou Financeiro
	DbSelectArea("VV0")
	RecLock("VV0",.f.)
		VV0->VV0_GERFIN := "1"
	MsUnLock()
EndIf
//
Return lRet

/*/{Protheus.doc} VX00101_ClienteValido
	Valida se o destino È do grupo de empresas usando o documento cpf/cnpj

	@type function
	@author Vinicius Gati
	@since 05/12/2017
/*/
Function VX00101_ClienteValido(cCodCli, cLoja, cTipo, cM0CGC, lVldCGC)
Default lVldCGC := .f.
	if lVldCGC .and. Empty(cM0CGC)
		return .f.
	endif
	If cTipo == "C"
		DBSelectArea("SA1")
		DBSetOrder(1)
		If DbSeek(xFilial("SA1")+cCodCli+Alltrim(cLoja))
			If lVldCGC
				If FM_PILHA("VEIXA040") // Agrega e Desagrega
					If Empty(cLoja)
						return .t.
					EndIf
					If Alltrim(SA1->A1_CGC) == Alltrim(cM0CGC) // Precisa ser o mesmo CNPJ da Filial Logada
						return .t.
					EndIf
				Else
					If cPaisLoc $ "ARG,MEX"
						If SA1->A1_CGC == cM0CGC // Precisa ser o mesmo CNPJ da Filial Logada
							If SA1->A1_COD + SA1->A1_LOJA <> FGX_SM0SA1(cFilAnt,"C") // Cliente e Loja da Filial informada
								return .t.
							EndIf
						EndIf
					Else
						DbSelectArea("SA1")
						DBSetOrder(3)
						DbSeek(xFilial("SA1")+LEFT(SA1->A1_CGC, 8))
						while ! EOF()  .AND. LEFT(SA1->A1_CGC, 8) == LEFT(cM0CGC, 8)
							if Alltrim(SA1->A1_CGC) != Alltrim(cM0CGC) .AND. SA1->A1_COD == cCodCli
								SA1->(DBSetOrder(1))
								return .t.
							endif
							dbskip()
						enddo
						SA1->(DBSetOrder(1))
					EndIf
				EndIf
			Else
				return .t.
			EndIF
		else
			Return .f.
		EndIf
	Else
		DBSelectArea("SA2")
		DBSetOrder(1)
		If DbSeek(xFilial("SA2")+cCodCli+Alltrim(cLoja))
			If lVldCGC
				If FM_PILHA("VEIXA040") // Agrega e Desagrega
					If Empty(cLoja)
						return .t.
					EndIf
					If Alltrim(SA2->A2_CGC) == Alltrim(cM0CGC) // Precisa ser o mesmo CNPJ da Filial Logada
						return .t.
					EndIf
				Else
					If cPaisLoc $ "ARG,MEX"
						If SA2->A2_CGC == cM0CGC // Precisa ser o mesmo CNPJ da Filial Logada
							If SA2->A2_CLIENTE + SA2->A2_LOJCLI <> FGX_SM0SA1(cFilAnt,"C") // Cliente e Loja da Filial informada
								return .t.
							EndIf
						EndIf
					Else
						DbSelectArea("SA2")
						DBSetOrder(3)
						DbSeek(xFilial("SA2")+LEFT(SA2->A2_CGC, 8))
						while ! EOF() .AND. LEFT(SA2->A2_CGC, 8) == LEFT(cM0CGC, 8)
							if Alltrim(SA2->A2_CGC) != Alltrim(cM0CGC) .AND. SA2->A2_COD == cCodCli
								SA2->(DBSetOrder(1))
								return .t.
							endif
							dbskip()
						enddo
						SA2->(DBSetOrder(1))
					EndIf
				EndIf
			Else
				return .t.
			EndIf
		else
			Return .f.
		EndIf
	EndIf
Return .F.

/*/{Protheus.doc} VX001VLDESTQ
	Valida Estoque dos Veiculos na aCols quando o TES movimentar Estoque

	@type function
	@author Andre Luis Almeida
	@since 16/04/2018
/*/
Static Function VX001VLDESTQ(nLinha,lMsg)
Local lRet        := .t.
Local ni          := 0
Local nTotal      := 0
Local nPVVACHASSI := FG_POSVAR("VVA_CHASSI")
Local nPVVACODTES := FG_POSVAR("VVA_CODTES")
Default nLinha    := 0
Default lMsg      := .t.
If nLinha <> 0 // Validar linha especifica da aCols
	nTotal := nLinha
Else // Validar TODAS as linhas da aCols
	nLinha := 1
	nTotal := len(aCols)
EndIf
If FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_ESTNEG","<>","1") // nao Permite Faturar sem Estoque
	VV1->(DBSetOrder(2))
	SB1->(DBSetOrder(7))
	SB2->(DbSetOrder(1))
	SF4->(DBSetOrder(1))
	For ni := nLinha to nTotal
		If !aCols[ni,len(aHeader)+1]
			SF4->(MsSeek(xFilial("SF4")+aCols[ni,nPVVACODTES]))
			If SF4->F4_ESTOQUE == "S"
				VV1->(MsSeek(xFilial("VV1")+aCols[ni,nPVVACHASSI]))
				FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
				If !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)) .or. SB2->B2_QATU <= 0 //FILIAL+PRODUTO+LOCAL
					If lMsg // Mostra Mensagem ?
						// STR0088 - Veiculo/M·quina n„o esta no estoque ou pertence a outra filial!
						// STR0089 - Verifique o estoque do mesmo ou utilize um TES que n„o movimenta estoque.
						FMX_Help("VX001VLDESTQ", STR0088+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV1->VV1_CHASSI, STR0089)
					EndIf
					lRet := .f.
				EndIf
			EndIf
		EndIf
	Next
	SB1->(DBSetOrder(1))
EndIf
Return lRet

/*/{Protheus.doc} VX00102_SelecionaValidEnchoic
	Seleciona qual validaÁ„o dever· usar, de acordo com a rotina que est· chamando
	Utilizado no valid dos campos VV0_CLIENT e VV0_LOJENT
	@type function
	@author Matheus Teixeira Silva
	@since 30/11/2020
/*/
Function VX00102_SelecionaValidEnchoic()

If FM_PILHA("VEIXX001")
	VX001VLDENC()
ElseIf FM_PILHA("VEIXX002") 
	VX002VLDENC()
EndIf

Return .T.

/*
	Valida Filial selecionada quando infroma a filial de destino durante a
	inclus„o de saÌda por TransferÍncia para que n„o seja a mesma de origem.
	@type function
	@author Alecsandre Aparecido Fabiano Santana Ferreira
	@since 18/10/2022
*/
Function VX001003B_ValidaFilial(cFilOri, cFilDest, aAreaM0)
	Local lRet := .T.
	Default cFilDest := SM0->M0_CODFIL

	cFilAnt := cFilOri
	SM0->(RestArea(aAreaM0))

	If !Empty(cFilDest)
		If cFilDest == Alltrim(SM0->M0_CODFIL)
			FMX_HELP(STR0092, STR0093) // "FILORIDEST" // "A filial de destino È a mesma de origem. Selecione outra filial para a transferÍncia."
			lRet := .F.
		Elseif !FwFilExist(cEmpAnt, cFilDest)
			FMX_HELP(STR0094, STR0095) // "FILIALNAOEXISTE" // "Filial N„o Cadastrada."
			lRet := .F.
		Endif
	Endif
Return lRet


/*/{Protheus.doc} VX0010013_AtualizaVV1
	

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Static Function VX0010013_AtualizaVV1()
	local aFldVV1 := {}
	local oVV1_AtVeiAMov

	local aAreaSA1 := SA1->(getArea())

	// 0=Venda
	// 2=Transferencia
	If cOpeMov $ "02"

		//if VV1->VV1_PROATU == SA1->A1_COD
		//else
		//	AADD( aFldVV1 , { "VV1_PROATU" , SA1->A1_COD } )
		//endif
		//
		//if VV1->VV1_LJPATU == SA1->A1_LOJA
		//else
		//	AADD( aFldVV1 , { "VV1_LJPATU" , SA1->A1_LOJA } )
		//endif
		//
		//if VV1->VV1_DOCIND == SA1->A1_CGC
		//else
		//	AADD( aFldVV1 , { "VV1_DOCIND" , SA1->A1_CGC } )
		//endif
		
		if VV1->VV1_VEND == VV0->VV0_CODVEN
		else
			AADD( aFldVV1 , { "VV1_VEND" , VV0->VV0_CODVEN } )
		endif
		
	// 4=Devolucao de Compra
	ElseIf cOpemov $ "4" .or. (cPaisLoc $ "ARG,MEX" .and. cOpeMov $ "67") // DEVOLUCAO DE COMPRA Argentina ou Mexico: 6=Retorno Remessa / 7=Retorno Consignacao

		if ! empty(VV1->VV1_PROATU)
		else
			AADD( aFldVV1 , { "VV1_PROATU" , " " } )
		endif

		if ! empty(VV1->VV1_LJPATU)
		else
			AADD( aFldVV1 , { "VV1_LJPATU" , " " } )
		endif

		if ! empty(VV1->VV1_DOCIND)
		else
			AADD( aFldVV1 , { "VV1_DOCIND" , " " } )
		endif

	EndIf

	if len(aFldVV1) == 0
		return .t.
	endif

	If Type("aRotina") == "U"
		aRotina := {}
	endif

	oVV1_AtVeiAMov := FWLoadModel( 'VEIA070' )
	lRetMVCAuto := FwMvcRotAuto(oVV1_AtVeiAMov, "VV1", 4, { {"MODEL_VV1",aFldVV1} },/*lSeek*/ .f. ,.f.)
	if ! lRetMVCAuto
		MostraErro()
		Return
	endif
	oVV1_AtVeiAMov:DeActivate()

	restArea(aAreaSA1)

Return

/*/{Protheus.doc} VX0010041_POSVV0
	Posiciona no VV0 correspondente 

	@type function
	@author Andre Luis Almeida
	@since 10/05/2023
/*/
Static Function VX0010041_POSVV0(aAutoCab)
Local nRecRet := 0
Local nPosNUMTRA := aScan(aAutoCab, { |x| x[1] == "VV0_NUMTRA"})
If nPosNUMTRA <> 0
	VV0->(dbSetOrder(1))
	If VV0->(dbSeek(xFilial("VV0") + aAutoCab[nPosNUMTRA,2]))
		nRecRet := VV0->(Recno())
	EndIf
EndIf
Return nRecRet

/*/{Protheus.doc} VX0010016_LoadMoeda
Rotina para Carregamento da Moeda
@type function
@author Valdemir Rabelo
@since 25/04/2024
@return variant, Nil
/*/
Static Function VX0010016_LoadMoeda()
	nMoedaCor  := VV0->VV0_MOEDA
	nTaxaMoeda := VV0->VV0_TXMOED
	if nAntTXMoe <> nTaxaMoeda
	   nAntTXMoe := nTaxaMoeda
	endif 
Return


/*/{Protheus.doc} VX0010026_AtualizaTaxa
Atualiza taxa da moeda
@type function
@author Valdemir Rabelo
@since 26/04/2024
@param oMoeda, object, Objeto moeda
@param oTaxaMoeda, object, Objeto Taxa Moeda
@param oSayMoeda, object, Objeto Label
@return variant, Nil
/*/
Static Function VX0010026_AtualizaTaxa(oMoeda, oTaxaMoeda, oSayMoeda)
	Local cMoeda := ""
	Local cCampo := ReadVar()

	cMoeda := SuperGetMv("MV_MOEDA" + AllTrim(Str(nMoedaCor, 2)))

	If nMoedaCor <> 1
		If !"NTAXA" $ Upper(cCampo)
			If nTaxaMoeda <> 0
				MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
			EndIf

			If nTaxaMoeda == 0
				nTaxaMoeda := MaFisRet(, "NF_TXMOEDA")
			EndIf

			If nTaxaMoeda == 0
				nTaxaMoeda := xMoeda(1, nMoedaCor, MaFisRet(, "NF_MOEDA"), M->VV0_DATEMI, TamSx3("VVF_TXMOED")[2])
				MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
			EndIf

			If ("NMOEDA"$Upper(cCampo))
				//nTaxaMoeda := RecMoeda(M->VV0_DATEMI, nMoedaCor)
				MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
			EndIf
		EndIf
	Else
		nTaxaMoeda := 0
		MaFisAlt("NF_TXMOEDA", nTaxaMoeda)
	EndIf
    if nAntTXMoe <> nTaxaMoeda
	   nAntTXMoe := nTaxaMoeda
	endif 
	// Atualiza Grid 

	If oMoeda <> Nil
		oMoeda:Refresh()
	EndIf

	If oTaxaMoeda <> Nil
		oTaxaMoeda:lReadOnly := IIF((INCLUI .Or. ALTERA), .f., .t.)
		oTaxaMoeda:Refresh()
	EndIf

	If oSayMoeda <> Nil
		If nMoedaCor == 1
			cMoeda := RetTitle("VV0_MOEDA")
		EndIf
		oSayMoeda:SetText(cMoeda)
	EndIf

Return


/*/{Protheus.doc} VX0010038_CancNFArg
Cancela Nota Fiscal de acordo com os argumentos passados
@type function
@author AndrÈ LuÌs Guimar„es Cruz
@since 28/06/2024
@param cDoc, character, Numero da nota fiscal a ser excluÌda
@param cSerie, character, SÈrie da nota fiscal a ser excluÌda
@param cTipoNF, character, Tipo da nota fiscal: 1=Nota Normal / 2=Nota do Remito
@return logical, retorna falso quando o execauto da rotina mata467n, mata462n ou mata102dn retorna erro
/*/
Function VX0010058_CancNFArg(cDoc, cSerie, cTipoNF)
	Local lRet := .t.
	Local aArea := GetArea()
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local aCabSF2 := {}
	Local aItem := {}
	Local aItensSD2 := {}
	Local cFunNameA // Guarda a rotina anterior

	If Type("lMSErroAuto") == "U"
		Private lMSErroAuto := .F.
	EndIf

	Default cDoc := SF2->F2_DOC
	Default cSerie := SF2->F2_SERIE
	Default cTipoNF := "1" // 1=Nota Normal / 2=Nota do Remito

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	if SF2->F2_DOC != cDoc .or. SF2->F2_SERIE != cSerie
		SF2->(DbSeek(FWxFilial("SF2")+cDoc+cSerie))
	endif

	AADD(aCabSF2, {"F2_DOC"    , SF2->F2_DOC    , Nil})
	AADD(aCabSF2, {"F2_SERIE"  , SF2->F2_SERIE  , Nil})
	AADD(aCabSF2, {"F2_CLIENTE", SF2->F2_CLIENTE, Nil})
	AADD(aCabSF2, {"F2_LOJA"   , SF2->F2_LOJA   , Nil})
	AADD(aCabSF2, {"F2_TIPODOC", SF2->F2_TIPODOC, Nil})

	DbSelectArea("SD2")
	SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	SD2->(DbSeek(FWxFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

	while !SD2->(Eof()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == FWxFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		aItem := {}
		AAdd(aItem, {"D2_DOC"    , SD2->D2_DOC    , Nil})
		AAdd(aItem, {"D2_SERIE"  , SD2->D2_SERIE  , Nil})
		AAdd(aItem, {"D2_CLIENTE", SD2->D2_CLIENTE, Nil})
		AAdd(aItem, {"D2_LOJA"   , SD2->D2_LOJA   , Nil})
		AAdd(aItensSD2, AClone(aItem))
		SD2->(DbSkip())
	end

	lMSErroAuto := .F.
	If cTipoNF == "1" // 1=Nota Normal / 2=Nota do Remito
		MSExecAuto( { |x,y,z| Mata467n(x,y,z) }, aCabSF2, aItensSD2, 5) // Chamada da Nota de Saida Manual e de Benefiamento a Cliente
	Else
		If SF2->F2_TIPODOC == "61" // 61=DevoluÁ„o
			cFunNameA := FunName() // Guarda a rotina anterior
			SetFunName("MATA102DN")
			MSExecAuto({|x,y,z| MATA102DN(x,y,z)}, aCabSF2, aItensSD2, 5) // Chamada da Remito de devolucao  (Compras)
			SetFunName(cFunNameA) // Retorna a rotina anterior
		Else
			MSExecAuto( { |x,y,z| MATA462N(x,y,z) }, aCabSF2, aItensSD2, 5) // Chamada da Remito Saida Manual e de Beneficiamento a Cliente
		EndIf
	EndIf
	if lMSErroAuto
		If __lSX8
			RollBackSX8()
		EndIf

		lRet := .F.
		// DisarmTransaction() // TODO - Cancelamento da argentina ou Mexico est· fora da transaÁ„o devido a um problema no execauto da Mata467n (MSRUNLOCK dentro de transaÁ„o). Voltar quando for corrigido.
	endif

	if !Empty(aAreaSD2)
		RestArea(aAreaSD2)
	endif
	if !Empty(aAreaSF2)
		RestArea(aAreaSF2)
	endif
	if !Empty(aArea)
		RestArea(aArea)
	endif
return lRet

/*/{Protheus.doc} VX0010068_ExistBaixa
	Valida se existem tÌtulos baixados
@type function
@author AndrÈ LuÌs Guimar„es Cruz
@since 28/06/2024
@return logical, retorna falso quando existem tÌtulos baixados referentes a SaÌdas de VeÌculos
/*/
Function VX0010068_ExistBaixa(cDoc, cSerie)
local aArea := GetArea()
local lRet := .t.

BeginSql Alias 'TMPSE1'

	select count(E1_FILIAL) QTDREGS
	 from %table:SF2% SF2
	 join %table:SE1% SE1
	   on SE1.E1_FILIAL  = %xfilial:SE1%
	  and SE1.E1_PREFIXO = SF2.F2_PREFIXO
	  and SE1.E1_NUM     = SF2.F2_DUPL
	  and SE1.E1_VALOR   <> SE1.E1_SALDO
	  and SE1.%notDel%
	where SF2.F2_FILIAL  = %xfilial:SF2%
	  and SF2.F2_DOC     = %exp:VV0->VV0_NUMNFI% 
	  and SF2.F2_SERIE   = %exp:VV0->VV0_SERNFI%
	  and SF2.%notDel%

EndSql

If TMPSE1->QTDREGS > 0
	FMX_HELP("EXISTBAIXA", STR0108, STR0106)
	lRet := .f.
EndIf

TMPSE1->(DbCloseArea())

if !Empty(aArea)
	RestArea(aArea)
endif
return lRet

/*/{Protheus.doc} VX0010093_ResumoImpostosArgentina
	Resumo impostos Argentina ou Mexico

@type function
@author Rubens Takahashi
@since 13/08/2024
/*/
Function VX0010093_ResumoImpostosArgentina()
	Local aRelImpostos
	Local nCntFor
	local xValor
	Local aRetResImp

	aRelImpostos := MaFisRodape(;
		1 /* nTipo */   , /* oJanela */   , /* aImpostos */ , /* aPosicao */  , /* bValidPrg */ , /* lVisual */   , /* cFornIss */  ,;
		/* cLojaIss */  , /* aRecSE2 */   , /* cDirf */     , /* cCodRet */   , /* oCodRet */   , /* nCombo */    , /* oCombo */    ,;
		/* dVencIss */  , /* aCodR */     , /* cRecIss */   , /* oRecIss */   , /* lEditImp */  , /* cDescri */   , .t. /* lAPI */  )

	aRetResImp := {}
	for nCntFor := 1 to Len(aOrcDynHeader)
		xValor := &(aOrcDynHeader[nCntFor,1])
		AAdd(aRetResImp, {'', aOrcDynHeader[nCntFor,2], xValor, '' })
	next

	for nCntFor := 1 to Len(aRelImpostos)
		if ! empty(aRelImpostos[nCntFor,6])
			xValor := &('MaFisRet(,"NF_VAL' + aRelImpostos[nCntFor,6] + '")')
			AAdd(aRetResImp, {'', aRelImpostos[nCntFor,2], xValor, '' })
		endif
	next nCntFor

	for nCntFor := 1 to Len(aOrcDynFooter)
		xValor := &(aOrcDynFooter[nCntFor,1])
		AAdd(aRetResImp, {'', aOrcDynFooter[nCntFor,2], xValor, '' })
	next

return aClone(aRetResImp)

/*/{Protheus.doc} VX0010071_Fatura_Remito
	Fatura com Remito (ARGENTINA OU MEXICO)

@type function
@author Andre Luis Almeida
@since 15/07/2024
/*/
Function VX0010071_Fatura_Remito()
If VV0->VV0_TIPDOC == "1" // 1=NF
	If VV0->VV0_SITNFI == "1" // VV0 Valido
		If Empty(VV0->VV0_NUMNFI) .and. !Empty(VV0->VV0_REMITO)
			VEIXX001(,,,4,VV0->VV0_OPEMOV,,,,,,,"3") // Gera Fatura apÛs Remito j· efetivado relativo ao VV0 posicionado no browse
		Else
			FMX_HELP("VEIXX001ERR05", STR0114 ) // Fatura j· foi Efetivada. Impossivel continuar!
		EndIf
	Else // NAO esta valido o VV0
		FMX_HELP("VEIXX001ERR06", STR0115 ) // A SaÌda de VeÌculos/M·quinas n„o esta Valida. Impossivel continuar!
	EndIf
Else // 2=SD3 (Mov.Internas)
	FMX_HELP("VEIXX001ERR07", STR0116 ) // Tipo de SaÌda de VeÌculos/M·quinas È uma MovimentaÁ„o Interna. Impossivel continuar!
EndIf
Return

/*/{Protheus.doc} VX0010081_Parcelas_VS9
	Levanta Parcelas do VS9

@type function
@author Andre Luis Almeida
@since 17/07/2024
/*/
Static Function VX0010081_Parcelas_VS9()
Local aParcVS9  := {}
Local cQuery    := ""
Local cSQLAlias := "SQLVS9"
// Trazer os Registros gravados no VS9 do Remito
cQuery := "SELECT VS9_DATPAG , VS9_VALPAG "
cQuery += "  FROM "+RetSQLName("VS9")
cQuery += " WHERE VS9_FILIAL = '"+xFilial("VS9")+"'"
cQuery += "   AND VS9_NUMIDE = '"+VV0->VV0_NUMTRA+"'"
cQuery += "   AND VS9_TIPOPE = 'V'"
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY VS9_SEQUEN "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->( Eof() )
	aAdd(aParcVS9,{ stod((cSQLAlias)->( VS9_DATPAG )) , (cSQLAlias)->( VS9_VALPAG ) })
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
Return aParcVS9

/*/{Protheus.doc} VX0010091_Gerar_Remito
	Gerar Remito de Entrega Futura (ARGENTINA)

@type function
@author Andre Luis Almeida
@since 06/09/2024
/*/
Function VX0010091_Gerar_Remito()
If VV0->VV0_TIPDOC == "1" // 1=NF
	If VV0->VV0_SITNFI == "1" // VV0 Valido
		If !Empty(VV0->VV0_NUMNFI) .and. Empty(VV0->VV0_REMITO)
			VEIXX001(,,,4,VV0->VV0_OPEMOV,,,,,,,"4") // Gera Remito de Entrega Futura relativo ao VV0 posicionado no browse
		Else
			FMX_HELP("VEIXX001ERR08", STR0120 ) // Remito j· gerado. Impossivel continuar!
		EndIf
	Else // NAO esta valido o VV0
		FMX_HELP("VEIXX001ERR06", STR0115 ) // A SaÌda de VeÌculos/M·quinas n„o esta Valida. Impossivel continuar!
	EndIf
Else // 2=SD3 (Mov.Internas)
	FMX_HELP("VEIXX001ERR07", STR0116 ) // Tipo de SaÌda de VeÌculos/M·quinas È uma MovimentaÁ„o Interna. Impossivel continuar!
EndIf
Return

/*/{Protheus.doc} VX0010101_Valida_TES_ARG
	Valida TES de Remito e Fatura (ARGENTINA OU MEXICO)

@type function
@author Andre Luis Almeida
@since 07/09/2024
/*/
Function VX0010101_Valida_TES_ARG(cTpFatR,nOpc,lResumo)
Local cTp       := "1"
Local aParamBox := {}
Local aRet      := {}
Local nCntFor   := 0
Local cCodTES   := space(TamSx3("VVA_CODTES")[1])
Local aVVARec   := {}
Local lTelaTES  := .t.
Default lResumo := .f.
If nOpc == 3 // Incluir
	For nCntFor := 1 to len(aCols)
		If !aCols[nCntFor,len(aHeader)+1]
			cCodTES := aCols[nCntFor,FG_POSVAR("VVA_CODTES")]
			Exit
		EndIf
	Next
ElseIf nOpc == 4 // Alterar
	//
	If lAtuFiscal // Atualiza Fiscal
		__ReadVar := "M->VV0_LOJA"
		VX001VLDENC() // Disparar o Inicio do Fiscal
		If cPaisLoc == 'ARG'
			MaFisRef("NF_UFDEST" ,"VX001",VV0->VV0_PROVEN)
			MaFisRef("NF_PROVENT","VX001",VV0->VV0_PROVEN)
		EndIf
		MaFisRef("NF_TPFRETE","VX001",VV0->VV0_TPFRET)
		MaFisRef("NF_FRETE"  ,"VX001",VV0->VV0_VALFRE)
		MaFisRef("NF_DESPESA","VX001",VV0->VV0_DESACE)
		MaFisRef("NF_SEGURO" ,"VX001",VV0->VV0_SEGURO)
		n := 1
	EndIf
	//
	dbSelectArea("VVA")
	dbSetOrder(1)
	dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	While !eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VV0->VV0_NUMTRA == VVA->VVA_NUMTRA
		aAdd(aVVARec,VVA->(RecNo()))
		cCodTES := VVA->VVA_CODTES
		// SETA VARIAVEL FISCAL
		If lAtuFiscal // Atualiza Fiscal
			VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
			MaFisRef("IT_PRODUTO" ,"VX001",SB1->B1_COD)
			MaFisRef("IT_QUANT"   ,"VX001",1)
			MaFisRef("IT_VALMERC" ,"VX001",If(lResumo, VVA->VVA_VALMOV, VVA->VVA_VALVDA))
			MaFisRef("IT_TES"     ,"VX001",VVA->VVA_CODTES)
			MaFisRef("IT_PRCUNI"  ,"VX001",VVA->VVA_VALMOV)
			MaFisRef("IT_DESCONTO","VX001",VVA->VVA_VALDES) 
			FMX_FISITEMI(n, "VX001", .f.)
			n++
		EndIf
		DbSelectArea("VVA")
		DbSkip()
	EndDo
EndIf

cTp := cTpFatR

If !Empty(cTp) .and. !lResumo
	If ExistBlock("VXX01TEA") // Ponto de Entrada para manipular o TES Argentina 
		aRet := ExecBlock("VXX01TEA", .f., .f., { cTp , M->VV0_FILIAL , M->VV0_NUMTRA })
		cCodTES  := aRet[1]
		lTelaTES := aRet[2]
		aRet := {}
	EndIf
	If lTelaTES
		AADD(aParamBox,{1,STR0121,cCodTES,"@!","VX0020101_Valida_TES_ARG('"+cTp+"',MV_PAR01)","SF4",".T.",50,.T.}) // TES Fatura
		If ParamBox(aParamBox,"",@aRet,,,,,,,,.f.)
			cCodTES := aRet[1] // TES
		Else
			Return .f.
		EndIf
	Else
		If !VX0020101_Valida_TES_ARG(cTp,cCodTES)
			Return .f.
		EndIf
	EndIf
	For nCntFor := 1 to len(aCols)
		If !aCols[nCntFor,len(aHeader)+1]
			aCols[nCntFor,FG_POSVAR("VVA_CODTES")] := M->VVA_CODTES := cCodTES
			n := nCntFor
			MaFisRef("IT_TES","VX001",M->VVA_CODTES)
		EndIf
	Next
	// Necess·rio ajustar o VVA (se existir) pq j· passou pela GravaÁ„o //
	For nCntFor := 1 to len(aVVARec)
		DbSelectArea("VVA")
		DbGoTo(aVVARec[nCntFor])
		RecLock("VVA",.f.)
			VVA->VVA_CODTES := cCodTES
		MsUnLock()
	Next
EndIf
Return .t.

/*/{Protheus.doc} VX0010111_SE4_Tipo_A
	Veifica se È CondiÁ„o do Tipo A

	@type function
	@author Andre Luis Almeida
	@since 24/07/2025
/*/
Static Function VX0010111_SE4_Tipo_A( cCond )
SE4->( DBSetOrder(1) )
SE4->( dbSeek( xFilial("SE4") + cCond ) )
Return( SE4->E4_TIPO == "A" )