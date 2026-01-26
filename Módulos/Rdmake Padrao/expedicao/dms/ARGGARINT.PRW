#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OFIXDEF.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ARGGARINT ³ Autor ³ João Carlos da Silva  ³ Data ³ 20/01/25 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressão Interna Garantia                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ARGGARINT() // Impressão Interna Garantia
Local cTitJan  := "Impressão Interna Garantia"
Local cTitBot  := "Imprimir"
Local cFiltro  := ""
Local oBrowse

cFiltro += "@ EXISTS ("
cFiltro += " SELECT VO3_NUMOSV FROM " + RetSqlName("VO3") + " VO3"
cFiltro += " JOIN " + RetSqlName("VOI") + " VOI ON VOI.D_E_L_E_T_=' ' AND VOI_FILIAL='" + xFilial("VOI") + "' AND VOI_TIPTEM=VO3_TIPTEM AND VOI_SITTPO='2'"
cFiltro += " WHERE VO3.D_E_L_E_T_=' ' AND VO3_FILIAL=VO1_FILIAL AND VO3_NUMOSV=VO1_NUMOSV AND VO3_DATFEC<>' ' AND VO3_DATCAN=' '"
cFiltro += " UNION ALL"
cFiltro += " SELECT VO4_NUMOSV FROM " + RetSqlName("VO4") + " VO4"
cFiltro += " JOIN " + RetSqlName("VOI") + " VOI ON VOI.D_E_L_E_T_=' ' AND VOI_FILIAL='" + xFilial("VOI") + "' AND VOI_TIPTEM=VO4_TIPTEM AND VOI_SITTPO='2'"
cFiltro += " WHERE VO4.D_E_L_E_T_=' ' AND VO4_FILIAL=VO1_FILIAL AND VO4_NUMOSV=VO1_NUMOSV AND VO4_DATFEC<>' ' AND VO4_DATCAN=' '"
cFiltro += " )"

oBrowse := FwMBrowse():New()
oBrowse:SetDescription( cTitJan ) // Impressão Interna Garantia
oBrowse:SetAlias('VO1')
oBrowse:SetMenuDef( '' )
oBrowse:AddButton(cTitBot , {|| fArgGarInt( VO1->VO1_NUMOSV ) },,2,2) // Imprimir
oBrowse:SetFilterDefault( cFiltro )
oBrowse:DisableDetails()
oBrowse:ForceQuitButton(.T.)
oBrowse:DisableReport()
oBrowse:lOptionReport := .F.
oBrowse:Activate()

Return
//-----------------------------------------------------------------------------

/*/{Protheus.doc} fARGGARINT
Imprime o relatório Impressão Interna Garantia (Argentina)
@type function
@version 1.0
@author João Carlos da Silva
@since 20/01/2025
@param cNumOSV, character, Número da Ordem de Serviço
/*/
Static Function fARGGARINT( cNumOSV ) // Impressão Interna Garantia
	Local oReport
	Local cTitulo  := "Impressão Interna Garantia - " + cNumOSV
	Local cNomeRel := "ARGGARINT_" + cNumOSV + "_" + __cUserId
	Local cDesc1   := "Esta rotina imprimirá o relatório Impressão Interna Garantia (Argentina)."
	Local cPerg    := ""

	oReport := RptDefOrc(oReport,cNumOSV,cTitulo,cNomeRel,cDesc1,cPerg)
	oReport:nFontBody := 10
	oReport:oPage:nPaperSize := 9
	oReport:SetRightAlignPrinter(.T.)
	oReport:PrintDialog()
Return
//-----------------------------------------------------------------------------

/*/{Protheus.doc} RptDefOrc
Cria o relatório
@type function
@version 1.0
@author João Carlos da Silva
@since 20/01/2025
@param oReport, object, Objeto do relatório
@param cNumOSV, character, Número da Ordem de Serviço
@param cTitulo, character, Título do relatório
@param cNomeRel, character, Nome do relatório
@param cDesc1, character, Descrição do relatório
@param cPerg, character, Pergunte do relatório
@return object, Objeto do relatório criado
/*/
Static Function RptDefOrc(oReport,cNumOSV,cTitulo,cNomeRel,cDesc1,cPerg)
	Local oSection1

	Pergunte(cPerg, .F.)

	oReport := TReport():New(cNomeRel,cTitulo,cPerg,{|oReport| RunRptOrc(oReport,cNumOSV)},cDesc1)

	oReport:SetLineHeight(45)

	oSection1 := TRSection():New(oReport)

Return oReport
//-----------------------------------------------------------------------------

/*/{Protheus.doc} RunRptOrc
Imprime o relatório
@type function
@version 1.0
@author João Carlos da Silva
@since 20/01/2025
@param oReport, object, Objeto do relatório
@param cNumOSV, character, Número da Ordem de Serviço
/*/
Static Function RunRptOrc(oReport,cNumOSV)
	Local oSection1  := oReport:Section(1)
	Local nLin       := 0260
	Local nCol       := 0060

	Local aOSTTPC    := FMX_CALPEC(cNumOSV,"",,,, .T.,,,,,,,,, .F.) // Cálculo de piezas
	Local aOSTTSC    := FMX_CALSER(cNumOSV,"",,, .T., .T.) // Cálculo de servicios

	Local cCondP     := ""
	Local cDescP     := ""

	Local cCodTra    := ""
	Local cNomTra    := ""
	Local cTelTra    := ""

	Local aObsMem    := {}
	Local cObsMem    := ""

	// Ajusta a margem no PDF
	If oReport:nDevice == 6 // 1-Arquivo, 2-Impressora, 3-Email, 4-Planilha, 5-Html, 6-PDF, 7-ODF, 8-PDF por Email, 9-N/A, 10-Json
		nCol := 0010 
	EndIf

	DBSelectArea("VO1")
	DbSetOrder(1)
	DbSeek(FWxFilial("VO1")+cNumOSV)

	DbSelectArea("VAI")
	DBSetOrder(1)
	DbSeek(FWxFilial("VAI")+VO1->VO1_FUNABE)

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(FWxFilial("SA3")+VAI->VAI_CODVEN)

	VOO->(dbSetOrder(1)) // VOO_FILIAL+VOO_NUMOSV+VOO_TIPTEM+VOO_LIBVOO
	VOO->(dbSeek(FWxFilial("VOO")+cNumOSV)) // Posiciona no VOO
	While VOO->(!Eof() .and. VOO_FILIAL+VOO_NUMOSV == FWxFilial("VOO")+cNumOSV)

		If Empty(cCondP)
			SE4->(dbSetOrder(1)) // E4_FILIAL+E4_CODIGO
			SE4->(dbSeek(FWxFilial("SE4")+VOO->VOO_CONDPG)) // Posiciona no SE4
			cCondP := SE4->E4_CODIGO
			cDescP := SE4->E4_DESCRI
		EndIf

		If VOO->(FieldPos("VOO_TRANSP")) > 0 .and. !Empty(VOO->VOO_TRANSP)
			If Empty(cCodTra)
				SA4->(dbSetOrder(1)) // A4_FILIAL+A4_COD
				SA4->(dbSeek(FWxFilial("SA4")+VOO->VOO_TRANSP)) // Posiciona no SA4
				cCodTra := SA4->A4_COD
				cNomTra := SA4->A4_NOME
				cTelTra := SA4->A4_TEL
			EndIf
		EndIf

		cObsMem := ""
		If VOO->(FieldPos("VOO_OBSENF")) > 0
			cObsMem := MSMM(VOO->VOO_OBSENF,,,,3,,,"VOO") // Obs. da NF
			If Empty(cObsMem)
				If VOO->(FieldPos("VOO_OBSENS")) > 0
					cObsMem := MSMM(VOO->VOO_OBSENS,,,,3,,,"VOO") // Obs. da NS
				EndIf
			EndIf
		EndIf
		If !Empty(cObsMem)
			AAdd(aObsMem,cObsMem)
		EndIf

		VOO->(dbSkip())
	End

	DbSelectArea("SA1")
	DBSetOrder(1)
	If !SA1->(DBSeek(FWxFilial("SA1")+VO1->VO1_FATPAR+VO1->VO1_LOJA))
		SA1->(DbSeek(FWxFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO))
	EndIf

	oSection1:Init()
	nLin := fImpEmpre(oReport,nLin,nCol,aOSTTPC,aOSTTSC)
	nLin := fImpClien(oReport,nLin,nCol,cNumOSV,cDescP)
	nLin := fImpItens(oReport,nLin,nCol,cNumOSV,aOSTTPC,aOSTTSC,cNomTra,cTelTra,aObsMem)
	oSection1:Finish()

Return
//-----------------------------------------------------------------------------

/*/{Protheus.doc} fImpEmpre
Imprime os dados da empresa
@type function
@version 1.0
@author João Carlos da Silva
@since 20/01/2025
@param oReport, object, Objeto do relatório
@param nLin, numeric, Número da linha inicial do relatório
@param nCol, numeric, Número da coluna inicial do relatório
@param aOSTTPC, array, Array com as peças da Ordem de Serviço
@param aOSTTSC, array, Array com os serviços da Ordem de Serviço
@return numeric, Número da linha atual do relatório
/*/
Static Function fImpEmpre(oReport,nLin,nCol,aOSTTPC,aOSTTSC)
//                  TFont():New(cName        ,uPar2,nHeight,uPar4,lBold,uPar6,uPar7,uPar8,uPar9,lUnderline,lItalic)
Local oFont12n   := TFont():New("Courier New",9    ,12     ,.T.  ,.F.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )

Local cNomEmp    := SM0->M0_NOMECOM
Local cEndEmp    := SM0->M0_ENDENT
Local cCidEmp    := SM0->M0_CIDENT
//Local cBaiEmp    := SM0->M0_BAIRENT
//Local cEstEmp    := SM0->M0_ESTENT
Local cCepEmp    := SM0->M0_CEPENT
Local cTelEmp    := SM0->M0_TEL
Local cCgcEmp    := SM0->M0_CGC
Local cTipEmp    := ""

Local cMaskCgc   := PesqPict("SA1","A1_CGC")
Local nLinAnt    := 0 // Primeira linha do bloco

Local aComboTipo := RetSX3Box(GetSX3Cache("A1_TIPO","X3_CBOXSPA"),Nil,1,1,Nil)
Local nComboTipo := 0
Local cComboTipo := ""

Local aCliFil    := {}
Local aAreaSA1   := SA1->(GetArea())

Local cNroPed    := ""
Local cIngBru    := ""
Local cNroJub    := ""

Local cNumNFI    := ""
Local cSerNFI    := ""
Local dDatNFI    := CtoD("")
Local cDatNFI    := ""

Local nPos       := 0

aCliFil := FGX_SM0SA1(cFilAnt,"A") // Cliente por Filial Mercado Internacional
cTipEmp := Posicione("SA1",1,xFilial("SA1") + aCliFil[1] + aCliFil[2],"A1_TIPO") // Posiciona no SA1
RestArea(aAreaSA1)

// Tipo da Empresa
nComboTipo := Ascan(aComboTipo,{|x| x[2] == cTipEmp})
If nComboTipo > 0
	cComboTipo := aComboTipo[nComboTipo,3]
Else
	cComboTipo := "N/D"
EndIf
cTipEmp := AllTrim(cComboTipo) // Tipo da Empresa

cNroPed := ""
cIngBru := ""
cNroJub := ""

cNumNFI := ""
cSerNFI := ""
dDatNFI := CtoD("")
cDatNFI := ""

If Len(aOSTTPC) > 0
	For nPos := 1 to 1 // Len(aOSTTPC)
		If Empty(cNumNFI)
			cNumNFI += If(Empty(cNumNFI),"","/") + aOSTTPC[nPos,PECA_NUMNFI]
			cSerNFI += If(Empty(cSerNFI),"","/") + aOSTTPC[nPos,PECA_SERNFI]
			dDatNFI := aOSTTPC[nPos,PECA_DATFEC]
			cDatNFI += If(Empty(cDatNFI),"","/") + DtoC(dDatNFI)
		EndIf
	Next
EndIf
If Len(aOSTTSC) > 0
	For nPos := 1 to 1 // Len(aOSTTSC)
		If Empty(cNumNFI)
			cNumNFI += If(Empty(cNumNFI),"","/") + aOSTTSC[nPos,SRVC_NUMNFI]
			cSerNFI += If(Empty(cSerNFI),"","/") + aOSTTSC[nPos,SRVC_SERNFI]
			dDatNFI := aOSTTSC[nPos,SRVC_DATFEC]
			cDatNFI += If(Empty(cDatNFI),"","/") + DtoC(dDatNFI)
		EndIf
	Next
EndIf

nLinAnt := nLin // Primeira linha do bloco

oReport:Say(nLin,nCol+0000,"Empresa.....: "+cNomEmp   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Domicilio...: "+cEndEmp   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Complemento.: "+cCidEmp   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Teléfono....: "+cTelEmp   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"IVA.........: "+cTipEmp   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,                 cCepEmp   ,oFont12n)
nLin+=0060

nLin := nLinAnt // Primeira linha do bloco

oReport:Say(nLin,nCol+1400,"INTERNA GARANTIA Nro........: "+cNumNFI   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"Fecha.......................: "+cDatNFI   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"Nro. pedido.................: "+cNroPed   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"CUIT/CUIL...................: "+Transform(cCgcEmp,cMaskCgc)   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"Ing. brutos.................: "+cIngBru   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"Nro. jubilación.............: "+cNroJub   ,oFont12n)
nLin+=0060

nLin+=0010
oReport:SetRow(nLin)
oReport:FatLine()
nLin+=0010

Return(nLin)
//-----------------------------------------------------------------------------

/*/{Protheus.doc} fImpClien
Imprime os dados do cliente
@type function
@version 1.0
@author João Carlos da Silva
@since 20/01/2025
@param oReport, object, Objeto do relatório
@param nLin, numeric, Número da linha inicial do relatório
@param nCol, numeric, Número da coluna inicial do relatório
@param cNumOSV, character, Número da Ordem de Serviço
@return numeric, Número da linha atual do relatório
/*/
Static Function fImpClien(oReport,nLin,nCol,cNumOSV,cDescP)
//                  TFont():New(cName        ,uPar2,nHeight,uPar4,lBold,uPar6,uPar7,uPar8,uPar9,lUnderline,lItalic)
Local oFont12n   := TFont():New("Courier New",9    ,12     ,.T.  ,.F.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )

Local cCodCli    := SA1->A1_COD
Local cLojCli    := SA1->A1_LOJA
Local cNomCli    := SA1->A1_NOME
Local cEndCli    := SA1->A1_END
Local cCidCli    := SA1->A1_MUN
//Local cBaiCli    := SA1->A1_BAIRRO
//Local cEstCli    := SA1->A1_EST
//Local cCepCli    := SA1->A1_CEP
//Local cTelCli    := SA1->A1_TEL
Local cCgcCli    := SA1->A1_CGC
Local cTipCli    := SA1->A1_TIPO

Local cMaskCgc   := PesqPict("SA1","A1_CGC")
Local nLinAnt    := 0 // Primeira linha do bloco

Local aComboTipo := RetSX3Box(GetSX3Cache("A1_TIPO","X3_CBOXSPA"),Nil,1,1,Nil)
Local nComboTipo := 0
Local cComboTipo := ""

// Tipo do Cliente
nComboTipo := Ascan(aComboTipo,{|x| x[2] == cTipCli})
If nComboTipo > 0
	cComboTipo := aComboTipo[nComboTipo,3]
Else
	cComboTipo := "N/D"
EndIf
cTipCli := AllTrim(cComboTipo) // Tipo do Cliente

nLinAnt := nLin // Primeira linha do bloco

oReport:Say(nLin,nCol+0000,"Nome Cliente: "+cNomCli   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Domicilio...: "+cEndCli   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Complemento.: "+cCidCli  ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"IVA.........: "+cTipCli  ,oFont12n)
nLin+=0060

nLin := nLinAnt // Primeira linha do bloco

oReport:Say(nLin,nCol+1400,"Código Cliente..............: "+cCodCli+"/"+cLojCli   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"Orden reparación relacionada: "+cNumOSV   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"CUIT........................: "+Transform(cCgcCli,cMaskCgc)   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+1400,"NETO........................: "+cDescP   ,oFont12n)
nLin+=0060

nLin+=0010
oReport:SetRow(nLin)
oReport:FatLine()
nLin+=0010

Return(nLin)
//-----------------------------------------------------------------------------

/*/{Protheus.doc} fImpItens
Imprime os itens do orçamento
@type function
@version 1.0
@author João Carlos da Silva
@since 20/01/2025
@param oReport, object, Objeto do relatório
@param nLin, numeric, Número da linha inicial do relatório
@param nCol, numeric, Número da coluna inicial do relatório
@param cNumOSV, character, Número da Ordem de Serviço
@param aOSTTPC, array, Array com as peças da Ordem de Serviço
@param aOSTTSC, array, Array com os serviços da Ordem de Serviço
@param cNomTra, character, Nome da Transportadora
@param cTelTra, character, Telefone da Transportadora
@param aObsMem, array, Array com as observações da Ordem de Serviço
@return numeric, Número da linha atual do relatório
/*/
Static Function fImpItens(oReport,nLin,nCol,cNumOSV,aOSTTPC,aOSTTSC,cNomTra,cTelTra,aObsMem)
//                  TFont():New(cName        ,uPar2,nHeight,uPar4,lBold,uPar6,uPar7,uPar8,uPar9,lUnderline,lItalic)
Local oFont12n   := TFont():New("Courier New",9    ,12     ,.T.  ,.F.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )
Local oFont08n   := TFont():New("Courier New",9    ,08     ,.T.  ,.T.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )

Local cNomEmp    := SM0->M0_NOMECOM
Local cCodVen    := SA3->A3_COD
Local cNomVen    := SA3->A3_NOME

Local nPos       := 0
Local cLinha     := ""

Local cObsMem    := ""
Local nObsMem    := 0
Local nObs       := 0

Local cCodIte    := ""
Local cDesIte    := ""
Local cCargo     := ""
Local cLote      := ""

Local nQuant     := 0
Local nValBas    := 0
Local nValDes    := 0
Local nValAcr    := 0
Local nValPec    := 0
Local nValIva    := 0
Local nValTot    := 0

Local nValSubT   := 0
Local nValDesT   := 0
Local nValAcrT   := 0
Local nValLiqT   := 0

Local nLinhas    := 0

Local aGarantia  := fGarantia() // Tipos de tempo de garantia
Local cTipTem    := ""

Local cMaskQtd   := "@E 999,999,999.99"
Local cMaskVal   := "@E 999,999,999.99"
Local cMaskIva   := "@E 999,999,999.99"
Local cMaskTot   := "@E 999,999,999.99"
Local cSpace124  := Space(124)
Local cCabItens  := "CODIGO          Descripción                     A cargo de   Ubicación         Cantidad   Precio base     Descuento       Recargo        Precio           IVA         Total"
//                  "aaaaaaaaaa12345 aaaaaaaaaabbbbbbbbbbcccccccccc1 aaaaaaaaaa   aaaaaaaaaa1 111.222.333,00111.222.333,00111.222.333,00111.222.333,00111.222.333,00111.222.333,00111.222.333,00"
//                  "                                                                                                                            SUBTOTAL                         111.222.333,00"

// Ajusta as colunas dos itens no PDF
If oReport:nDevice == 6 // 1-Arquivo, 2-Impressora, 3-Email, 4-Planilha, 5-Html, 6-PDF, 7-ODF, 8-PDF por Email, 9-N/A, 10-Json
	cMaskQtd   := "@E 9999,999.99"
	cMaskVal   := "@E 999999,999.99"
	cMaskIva   := "@E 99999,999.99"
	cMaskTot   := "@E 999,999,999.99"
	cSpace124  := Space(115)
	cCabItens  := "CODIGO          Descripción                     A cargo de   Ubicación      Cantidad  Precio base    Descuento      Recargo       Precio         IVA         Total"
	//            "aaaaaaaaaa12345 aaaaaaaaaabbbbbbbbbbcccccccccc1 aaaaaaaaaa   aaaaaaaaaa1 1222.333,00111222.333,00111222.333,00111222.333,00111222.333,0011222.333,00111.222.333,00"
	//            "                                                                                                                   SUBTOTAL                         111.222.333,00"
EndIf

nLin+=0060

oReport:Say(nLin,nCol+0000,cCabItens,oFont08n)

nLin+=0030

nLin+=0010
oReport:SetRow(nLin)
oReport:FatLine()
nLin+=0010

nLin+=0020

For nPos := 1 to Len(aOSTTPC)
	cTipTem := aOSTTPC[nPos,PECA_TIPTEM]
	If Ascan( aGarantia, {|x| x == cTipTem} ) == 0 // Validação do tipo de tempo garantia
		Loop
	EndIf

	cCodIte := aOSTTPC[nPos,PECA_CODITE]
	cDesIte := aOSTTPC[nPos,PECA_DESCRICAO]
	cCargo  := ""
	cLote   := ""

	nQuant   := aOSTTPC[nPos,PECA_QTDREQ]
	nValBas  := aOSTTPC[nPos,PECA_VALVO3]
	nValDes  := aOSTTPC[nPos,PECA_VALDES]
	nValAcr  := aOSTTPC[nPos,PECA_ACRESC]
	nValPec  := nValBas - nValDes + nValAcr
	nValIva  := 0
	nValTot  := nValPec - nValIva

	nValSubT += nValTot
	nValDesT += nValDes
	nValAcrT += nValAcr
	nValLiqT := nValSubT - nValDesT + nValAcrT

	cLinha := ""
	cLinha += PadR(cCodIte,15) + " "
	cLinha += PadR(cDesIte,31) + " "
	cLinha += PadR(cCargo ,10) + "   "
	cLinha += PadR(cLote  ,11) + " "
	cLinha += Transform(nQuant ,cMaskQtd)
	cLinha += Transform(nValBas,cMaskVal)
	cLinha += Transform(nValDes,cMaskVal)
	cLinha += Transform(nValAcr,cMaskVal)
	cLinha += Transform(nValPec,cMaskVal)
	cLinha += Transform(nValIva,cMaskIva)
	cLinha += Transform(nValTot,cMaskTot)

	oReport:Say(nLin,nCol+0000,cLinha,oFont08n)
	nLin+=0060

	nLinhas++
Next

For nPos := 1 to Len(aOSTTSC)
	cTipTem := aOSTTSC[nPos,SRVC_TIPTEM]
	If Ascan( aGarantia, {|x| x == cTipTem} ) == 0 // Validação do tipo de tempo garantia
		Loop
	EndIf

	If nLinhas > 0 .and. nPos == 1 // Pula uma linha para separar peças e serviços
		nLin+=0060
	EndIf

	cCodIte := aOSTTSC[nPos,SRVC_CODSER]
	cDesIte := aOSTTSC[nPos,SRVC_DESCRICAO]
	cCargo  := ""
	cLote   := ""

	nQuant   := aOSTTSC[nPos,SRVC_TEMCOB]
	nValBas  := aOSTTSC[nPos,SRVC_VALBRU]
	nValDes  := aOSTTSC[nPos,SRVC_VALDES]
	nValAcr  := 0
	nValPec  := nValBas - nValDes + nValAcr
	nValIva  := 0
	nValTot  := nValPec - nValIva

	nValSubT += nValTot
	nValDesT += nValDes
	nValAcrT += nValAcr
	nValLiqT := nValSubT - nValDesT + nValAcrT

	cLinha := ""
	cLinha += PadR(cCodIte,15) + " "
	cLinha += PadR(cDesIte,31) + " "
	cLinha += PadR(cCargo ,10) + "   "
	cLinha += PadR(cLote  ,11) + " "
	cLinha += Transform(nQuant ,cMaskQtd)
	cLinha += Transform(nValBas,cMaskVal)
	cLinha += Transform(nValDes,cMaskVal)
	cLinha += Transform(nValAcr,cMaskVal)
	cLinha += Transform(nValPec,cMaskVal)
	cLinha += Transform(nValIva,cMaskIva)
	cLinha += Transform(nValTot,cMaskTot)

	oReport:Say(nLin,nCol+0000,cLinha,oFont08n)
	nLin+=0060

	nLinhas++
Next

nLin+=0010
oReport:SetRow(nLin)
oReport:FatLine()
nLin+=0010

oReport:Say(nLin,nCol+0000, cSpace124 + PadR("SUBTOTAL" , 33) + Transform(nValSubT,cMaskTot)   ,oFont08n)
nLin+=0060
oReport:Say(nLin,nCol+0000, cSpace124 + PadR("Descuento", 33) + Transform(nValDesT,cMaskTot)   ,oFont08n)
nLin+=0060
oReport:Say(nLin,nCol+0000, cSpace124 + PadR("Recargo"  , 33) + Transform(nValAcrT,cMaskTot)   ,oFont08n)
nLin+=0060
oReport:Say(nLin,nCol+0000, cSpace124 + PadR("NETO"     , 33) + Transform(nValLiqT,cMaskTot)   ,oFont08n)
nLin+=0030

nLin+=0010
oReport:SetRow(nLin)
oReport:FatLine()
nLin+=0010

oReport:Say(nLin,nCol+0000,"Comprobante impreso por: "+cNomEmp   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"TOTAL LINEAS...........: "+PadR(AllTrim(Str(nLinhas)),10)+"            TOTAL UNID.:            ORIGINAL"   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Transporte.............: "+cNomTra   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Teléfono...............: "+cTelTra   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Total..................:"   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"CAI Nº.................:                      Vencimiento:"   ,oFont12n)
nLin+=0060
oReport:Say(nLin,nCol+0000,"Vendedor...............: "+cCodVen+"-"+cNomVen   ,oFont12n)
nLin+=0060

nLin+=0010
oReport:SetRow(nLin)
oReport:FatLine()
nLin+=0010

oReport:Say(nLin,nCol+0000,"Observaciones..........: "   ,oFont12n)
nLin+=0060

For nPos := 1 to Len(aObsMem)
	cObsMem := aObsMem[nPos]
	nObsMem := MlCount(cObsMem,100,,.T.)
	For nObs := 1 to nObsMem
		oReport:Say(nLin,nCol+0000,MemoLine(cObsMem,100,nObs,,.T.),oFont12n)
		nLin+=0060
	Next
Next

nLin+=0060
nLin+=0060
nLin+=0060

oReport:Say(nLin,nCol+0400,"Firma del cliente......: __________________________________________________"   ,oFont12n)
nLin+=0060
nLin+=0060
nLin+=0060
oReport:Say(nLin,nCol+0400,"Representante de ventas: __________________________________________________"   ,oFont12n)
nLin+=0060

Return(nLin)
//-----------------------------------------------------------------------------

/*/{Protheus.doc} fGarantia
Retorna array com os tipos de tempo de garantia
@type function
@version 1.0
@author João Carlos da Silva
@since 20/01/2025
@return array, Array com os tipos de tempo de garantia
/*/
Static Function fGarantia()
Local cAliasQry := "TIPTEMGAR"
Local aArea     := GetArea()
Local aRet      := {}

BeginSQL Alias cAliasQry
	SELECT VOI_TIPTEM
	FROM %table:VOI% VOI
	WHERE VOI.%notDel%
	AND VOI.VOI_FILIAL = %xFilial:VOI%
	AND VOI_SITTPO = '2'
EndSQL

While (cAliasQry)->(!Eof())
	(cAliasQry)->(AAdd(aRet,VOI_TIPTEM))
	(cAliasQry)->(dbSkip())
End
(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return(aRet)
//-----------------------------------------------------------------------------
