#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ORCSRVE Autor ³ João Victor Silva     ³ Data ³ 16/04/25 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao Orçamento Saidas de Servico Especializado.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ORCSRVE()
	Local oReport
	Local cNumOrc  := ParamIXB[1]
	Local cTitulo  := "Saida de Serviços Especializados"
	Local cNomRel  := "Código " + cNumOrc
	Local cDesc    := "Será impresso o Orçamento de Venda da Saida de Serviços Especializados."
	Local cPerg    := "ORCAMT"
 
	oReport := RptDefOrc(oReport,cNumOrc,cTitulo,cNomRel,cDesc,cPerg)
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
@author João Victor Silva
@since 16/04/2025
@param oReport, object, Objeto do relatório
@param cNumOrc, character, Número do orçamento
@param cTitulo, character, Título do relatório
@param cNomRel, character, Nome do relatório
@param cDesc, character, Descrição do relatório
@return object, Objeto do relatório criado
/*/
Static Function RptDefOrc(oReport,cNumOrc,cTitulo,cNomRel,cDesc,cPerg)
	Local oSection1
 
	oReport := TReport():New(cNomRel,cTitulo,cPerg,{|oReport| RunRptOrc(oReport,cNumOrc)},cDesc)
 
	oReport:SetLineHeight(45)
 
	oSection1 := TRSection():New(oReport)
 
Return oReport
//-----------------------------------------------------------------------------
 
/*/{Protheus.doc} RunRptOrc
Imprime o relatório
@type function
@version 1.0
@author João Victor Silva
@since 16/04/2025
@param oReport, object, Objeto do relatório
@param cNumOrc, character, Número do orçamento
/*/
Static Function RunRptOrc(oReport,cNumOrc)
	Local oSection1 := oReport:Section(1)
	Local nLin      := 0260
	Local nCol      := 0060
 
	oSection1:Init()
	nLin := fImpOrcam(oReport,nLin,nCol)
	nLin := fImpCliente(oReport,nLin,nCol)
	nLin := fImpServicos(oReport,nLin,nCol)
	oSection1:Finish()
 
Return
 
//-----------------------------------------------------------------------------
 
/*/{Protheus.doc} fImpOrcam
Imprime os dados do Orçamento
@type function
@version 1.0
@author João Victor Silva
@since 16/04/2025
/*/
Static Function fImpOrcam(oReport,nLin,nCol)
	Local oFont12n   := TFont():New("Courier New",9    ,12     ,.T.  ,.F.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )
	Local oFont12b   := TFont():New("Courier New",9    ,12     ,.T.  ,.T.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )

	Local cNumOrc := VRR->VRR_CODIGO
	Local dDatOrc := VRR->VRR_DATINC
	Local cCodVen := VRR->VRR_CODVEN
	Local cNomVen := Posicione("SA3",1,xFilial("SA3")+VRR->VRR_CODVEN,"A3_NOME")

	Local cMaskDat   := PesqPict("VRR","VRR_DATINC")

	nLin+=0030

	oReport:Say(nLin,nCol+0000,"Número    :"          		,oFont12n)
	oReport:Say(nLin,nCol+0320,cNumOrc                      ,oFont12b)
	oReport:Say(nLin,nCol+1700,"Data de Emissão   :"        ,oFont12n)
	oReport:Say(nLin,nCol+2100,Transform(dDatOrc,cMaskDat)  ,oFont12b)
	nLin+=0060
	oReport:Say(nLin,nCol+0000,"Vendedor  :"         		,oFont12n)
	oReport:Say(nLin,nCol+0320,cCodVen + " - " + cNomVen    ,oFont12b)
	nLin+=0060

	nLin+=0010
	oReport:SetRow(nLin)
	oReport:FatLine()
	nLin+=0010

	nLin+=0020
 
 
Return (nLin)
//-----------------------------------------------------------------------------
 
/*/{Protheus.doc} fImpCliente
Imprime os dados do cliente
@type function
@version 1.0
@author João Carlos da Silva
@since 16/04/2025
/*/
Static Function fImpCliente(oReport,nLin,nCol)
	Local oFont12n   := TFont():New("Courier New",9    ,12     ,.T.  ,.F.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )

	Local cNomCli    := SA1->A1_COD + "-" + SA1->A1_LOJA + " " + SA1->A1_NOME
	Local cEndCli    := SA1->A1_END
	Local cCidCli    := SA1->A1_MUN
	Local cCepCli    := SA1->A1_CEP
	Local cTelCli    := SA1->A1_TEL
	Local cCgcCli    := SA1->A1_CGC
 
	Local cMaskCgc   := PesqPict("SA1","A1_CGC")
	local cMaskCep   := PesqPict("SA1","A1_CEP")
	local cMaskTel   := PesqPict("SA1","A1_TEL")

	nLin+=0030

	oReport:Say(nLin,nCol+0000,"Cliente   :"       			,oFont12n)
	oReport:Say(nLin,nCol+0320,cNomCli                     	,oFont12n)
	oReport:Say(nLin,nCol+1700,"CNPJ/CPF  :"                ,oFont12n)
	oReport:Say(nLin,nCol+1960,Transform(cCgcCli, cMaskCgc)	,oFont12n)
	nLin+=0060
	oReport:Say(nLin,nCol+0000,"Endereco  :"     	        ,oFont12n)
	oReport:Say(nLin,nCol+0320,cEndCli                      ,oFont12n)
	oReport:Say(nLin,nCol+1700,"CEP       :"    			,oFont12n)
	oReport:Say(nLin,nCol+1960,Transform(cCepCli,cMaskCep)	,oFont12n)
	nLin+=0060
	oReport:Say(nLin,nCol+0000,"Municipio :"    			,oFont12n)
	oReport:Say(nLin,nCol+0320,cCidCli                  	,oFont12n)
	oReport:Say(nLin,nCol+1700,"Telefone  :"               	,oFont12n)
	oReport:Say(nLin,nCol+1960,Transform(cTelCli,cMaskTel)  ,oFont12n)
	nLin+=0060

Return(nLin)
//-----------------------------------------------------------------------------
 
/*/{Protheus.doc} fImpServicos
Puxer as informações do Serviços Especializados do relatorio
@type function
@version 1.0
@author João Victor Silva
@since 16/04/2025
@param oReport, object, Objeto do relatório
@param nLin, numeric, Número da linha inicial do relatório
@param nCol, numeric, Número da coluna inicial do relatório
@return numeric, Número da linha atual do relatório
/*/
Static Function fImpServicos(oReport,nLin,nCol)
	Local oFont12n   := TFont():New("Courier New",9    ,12     ,.T.  ,.F.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )
	Local oFont12b   := TFont():New("Courier New",9    ,12     ,.T.  ,.T.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )
	Local nDadSer  := 0
	Local nValTot    := 0

	cMaskQts   := PesqPict("VRS","VRS_QTDSER")
	cMaskVlu   := PesqPict("VRS","VRS_VLRUNI")
	cMaskVtl   := PesqPict("VRS","VRS_VLRTOT")

	nLin+=0010
	oReport:SetRow(nLin)
	oReport:FatLine()
	nLin+=0010

	nLin+=0020
	oReport:Say(nLin,nCol+0000,"Codigo"        			,oFont12n)
	oReport:Say(nLin,nCol+0320,"Descricao"     			,oFont12n)
	oReport:Say(nLin,nCol+0800,"Chassi"        			,oFont12n)
	oReport:Say(nLin,nCol+1200,"Série"         			,oFont12n)
	oReport:Say(nLin,nCol+1500,Padl("Qtde",5)  			,oFont12n)
	oReport:Say(nLin,nCol+1800,Padl("Vlr. Uni",10) 		,oFont12n)
	oReport:Say(nLin,nCol+2100,Padl("Vlr. Total",10)    ,oFont12n)
	nLin+=0060

	aDadSer := fDadosSer(VRR->VRR_CODIGO)
	If Len(aDadSer) > 0
		nPosCha := Ascan(aDadSer[1],{|x| x[1] == "VRS_CHASSI"})
		nPosQts := Ascan(aDadSer[1],{|x| x[1] == "VRS_QTDSER"})
		nPosNrs := Ascan(aDadSer[1],{|x| x[1] == "VRS_NROSER"})
		nPosVlu := Ascan(aDadSer[1],{|x| x[1] == "VRS_VLRUNI"})
		nPosVlt := Ascan(aDadSer[1],{|x| x[1] == "VRS_VLRTOT"})
		nPosCod := Ascan(aDadSer[1],{|x| x[1] == "VPX_CODSER"})
		nPosDes := Ascan(aDadSer[1],{|x| x[1] == "VPX_DESSER"})

		For nDadSer := 1 to Len(aDadSer)
			oReport:Say(nLin,nCol+0000,aDadSer[nDadSer,nPosCod,2],oFont12n)
			oReport:Say(nLin,nCol+0320,aDadSer[nDadSer,nPosDes,2],oFont12n)
			oReport:Say(nLin,nCol+0800,aDadSer[nDadSer,nPosCha,2],oFont12n)
			oReport:Say(nLin,nCol+1200,aDadSer[nDadSer,nPosNrs,2],oFont12n)
			oReport:Say(nLin,nCol+1500,PadL(AllTrim(Transform(aDadSer[nDadSer,nPosQts,2],cMaskQts)),5)	,oFont12n)
			oReport:Say(nLin,nCol+1800,Padl(AllTrim(Transform(aDadSer[nDadSer,nPosVlu,2],cMaskVlu)),10)	,oFont12n)
			oReport:Say(nLin,nCol+2100,PadL(AllTrim(Transform(aDadSer[nDadSer,nPosVlt,2],cMaskVtl)),10)	,oFont12n)
			nLin+=0060
 
			nValTot += aDadSer[nDadSer,nPosVlt,2]
 
		Next
 
	Endif
 
	nLin+=0010
	oReport:SetRow(nLin)
	oReport:FatLine()
	nLin+=0010

	nLin+=0220
	oReport:Say(nLin,nCol+1700,"Valor Total:", oFont12b)
	oReport:Say(nLin,nCol+2100,PadL(AllTrim(Transform(nValTot, cMaskVtl)),10)  ,oFont12b)
	nLin+=0260

	nLin+=0010
	oReport:SetRow(nLin)
	oReport:FatLine()
	nLin+=0010

	nLin+=0320
	oReport:Say(nLin,nCol+0000,"Ass. Cliente"  				,oFont12n)
	oReport:Say(nLin,nCol+0420,"________________________"	,oFont12b)
	oReport:Say(nLin,nCol+1300,"Ass. Vendedor"    			,oFont12n)
	oReport:Say(nLin,nCol+1720,"________________________"	,oFont12b)
	nLin+=0060
 
Return(nLin)
//-----------------------------------------------------------------------------
 
/*/{Protheus.doc} fDadosSer
Monta o array com os dados das saida de serviços especializados
@type function
@version 1.0
@author João Victor Silva
@since 16/04/2025
/*/
Static Function fDadosSer(cNumOrc) // Serviços
	Local aDados    := {}
	Local aDados0   := {}
	Local cAliasQry := "PECORC"

	BeginSql Alias cAliasQry
		SELECT VRS_CHASSI, VRS_QTDSER, VRS_NROSER, VRS_VLRUNI, VRS_VLRTOT, VPX_CODSER,VPX_DESSER
		FROM %Table:VRS% VRS
 
		JOIN %Table:VPX% VPX
		ON VPX.%NotDel%
		AND VRS_SERINT = VPX_SERINT

		WHERE VRS.%NotDel%
		AND VRS_FILIAL = %xFilial:VRS%
		AND VRS_CODVRR = %Exp:cNumOrc%
		AND VRS_QTDSER > 0"
	EndSql

	While (cAliasQry)->(!Eof())
		aDados0 := {}
		AAdd(aDados0,{"VRS_CHASSI",(cAliasQry)->VRS_CHASSI})
		AAdd(aDados0,{"VRS_QTDSER",(cAliasQry)->VRS_QTDSER})
		AAdd(aDados0,{"VRS_NROSER",(cAliasQry)->VRS_NROSER})
		AAdd(aDados0,{"VRS_VLRUNI",(cAliasQry)->VRS_VLRUNI})
		AAdd(aDados0,{"VRS_VLRTOT",(cAliasQry)->VRS_VLRTOT})
		AAdd(aDados0,{"VPX_CODSER",(cAliasQry)->VPX_CODSER})
		AAdd(aDados0,{"VPX_DESSER",(cAliasQry)->VPX_DESSER})
		AAdd(aDados,aDados0)

		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())

Return(aDados)