#include "protheus.ch"
#include "fisr4123.ch"


/*/{Protheus.doc} FISR4123
	Conferencia Antecipação x Adjudicação IN 41/2023 ICMS/RS 
	@type  Function
	@author Ricardo Henrique de Mello Lima
	@since 29/12/2023
	@version 1.0
	/*/

Function FISR4123(nAno,nMes,nSelFil,nConFil,cFilDe,cFilAte,aLisFil,lConFil)

	Local lIn4123 := FindClass("backoffice.fiscal.arquivos.spedfiscalutil.SpedFiscalUtil")
	Local cRotina := "FISR4123"
	Local oReport := nil
	Local oIN4123 := nil
	Local aParam  := {}
	Local cAlias := ""
	Local lRetorno := .F.

	if lIn4123

		// Chama o Metodo para retornar o Alias do detalhamento dos ajustes
		oIn4123 := backoffice.fiscal.arquivos.spedfiscalutil.SpedFiscalUtil():NEW()
		lRetorno := oIN4123:INITIN4123(nAno,nMes,nSelFil,nConFil,cFilDe,cFilAte,aLisFil,lConFil)
		if lRetorno
			aParam := oIN4123:LoadRelatorioConferencia()
			cAlias := aParam[2]
		endif
		FREEOBJ(oIN4123)

		if lRetorno
			If TRepInUse() //Verifica se relatorios personalizaveis esta disponivel
				oReport := ReportDef(cRotina,cAlias)
				oReport:PrintDialog()
			Else
				Alert(STR0013)   //"Rotina disponível apenas em TReport (Relatório Personalizável)."
			Endif
		else
			Alert(STR0014) // não existe dados a serem listados
		endif	
	endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

	Impressao do relatorio
	@author Ricardo Henrique de Mello Lima
	@since 29/12/2023
	@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ReportDef(cRotina,cAlias)
	Local oReport
	Local oSection
	Local oBreak
	Local cTitRel := STR0001   //"Conferencia Antecipação x Adjudicação IN 41/2023 ICMS/RS "

	oReport := TReport():New(cRotina,cTitRel,cRotina,{|oReport| PrintReport(oReport,cAlias,cRotina)},cTitRel)
	oReport:SetTotalInLine(.F.)
	oReport:SetLandScape(.T.)

	oSection := TRSection():New(oReport,cTitRel,{cAlias})
	oSection:lHeaderVisible := .F.
	oSection:SetHeaderSection(.T.)
	oSection:SetHeaderPage(.T.)
	oSection:SetLinesBefore(2)

	TRCell():New(oSection,"CDA_CODLAN"	,cAlias,STR0002	,PesqPict("CDA","CDA_CODLAN")	,FWSX3Util():GetFieldStruct("CDA_CODLAN")[3]) 	// Código Lançamento
	TRCell():New(oSection,"FT_CLIEFOR"	,cAlias,STR0003	,PesqPict("SFT","FT_CLIEFOR")	,FWSX3Util():GetFieldStruct("FT_CLIEFOR")[3])   // Cod.Fornecedor
	TRCell():New(oSection,"FT_LOJA"	    ,cAlias,STR0004	,PesqPict("SFT","FT_LOJA")		,FWSX3Util():GetFieldStruct("FT_LOJA")[3]) 		// Loja
	TRCell():New(oSection,"FT_EMISSAO"  ,cAlias,STR0015	,PesqPict("SFT","FT_EMISSAO")	,FWSX3Util():GetFieldStruct("FT_EMISSAO")[3])	// Data Emissao
	TRCell():New(oSection,"FT_ENTRADA"  ,cAlias,STR0016	,PesqPict("SFT","FT_ENTRADA")	,FWSX3Util():GetFieldStruct("FT_ENTRADA")[3])	// Data Entrada
	TRCell():New(oSection,"FT_NFISCAL"  ,cAlias,STR0005	,PesqPict("SFT","FT_NFISCAL")	,FWSX3Util():GetFieldStruct("FT_NFISCAL")[3]) 	// Nota Fiscal
	TRCell():New(oSection,"FT_SERIE"    ,cAlias,STR0006	,PesqPict("SFT","FT_SERIE")		,FWSX3Util():GetFieldStruct("FT_SERIE")[3]) 	// Série
	TRCell():New(oSection,"FT_PRODUTO"  ,cAlias,STR0007	,PesqPict("SFT","FT_PRODUTO")	,FWSX3Util():GetFieldStruct("FT_PRODUTO")[3]) 	// Cod.Produto
	TRCell():New(oSection,"B1_DESC"     ,cAlias,STR0008	,PesqPict("SB1","B1_DESC")		,FWSX3Util():GetFieldStruct("B1_DESC")[3]) 		// Descrição
	TRCell():New(oSection,"CDA_BASE"    ,cAlias,STR0009	,PesqPict("CDA","CDA_BASE")		,FWSX3Util():GetFieldStruct("CDA_BASE")[3]) 	// Base
	TRCell():New(oSection,"CDA_ALIQ"    ,cAlias,STR0010	,PesqPict("CDA","CDA_ALIQ")		,FWSX3Util():GetFieldStruct("CDA_ALIQ")[3]) 	// Aliquota %
	TRCell():New(oSection,"CDA_VALOR"   ,cAlias,STR0011	,PesqPict("CDA","CDA_VALOR")	,FWSX3Util():GetFieldStruct("CDA_VALOR")[3]) 	// Valor

	oBreak := TRBreak():New(oSection,{ || oSection:Cell("CDA_CODLAN"):uPrint },STR0012,.F.) // Sub-Total

	TRFunction():New(oSection:Cell("CDA_BASE"),NIL,"SUM",oBreak,,,,.F.,.T.)
	TRFunction():New(oSection:Cell("CDA_VALOR"),NIL,"SUM",oBreak,,,,.F.,.T.)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

	Impressao do relatorio
	@return Nil

	@author Ricardo Henrique de Mello Lima
	@since 29/12/2023
	@version 1.0

/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport,cAlias,cRotina)

	Local oSection := oReport:Section(1)

	oReport:SetMeter((cAlias)->(RecCount()))
	oSection:Init()

	(cAlias)->(DBGOTOP())

	While !oReport:Cancel()  .and. (cAlias)->(!Eof())
		oSection:PrintLine()
		(cAlias)->(dbSkip())
		oReport:IncMeter()
	EndDo
	oSection:Finish()
	(cAlias)->(dbCloseArea())
Return
