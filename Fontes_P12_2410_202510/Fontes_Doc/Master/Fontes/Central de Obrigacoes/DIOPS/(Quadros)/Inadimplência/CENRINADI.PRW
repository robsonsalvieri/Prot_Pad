#Include "PROTHEUS.Ch"
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

STATIC oFnt12N := TFont():New("Arial",14,14,,.f., , , , .t., .f.)
STATIC oFnt09C := TFont():New("Arial",09,09,,.f., , , , .t., .f.)
STATIC oFnt14N := TFont():New("Arial",18,18,,.t., , , , .t., .f.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ Inadimplência Administradora Benefícios - Inicio do processo³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CENRINADI(lTodosQuadros,lAuto)

	Local aSays      := {}
	Local aButtons   := {}
	Local cCadastro  := "                                 Inadimplência Administradora de Benefícios"
	Local aResult    := {}
	Local cDesc1      := FunDesc()
	Local cDesc2      := ""
	Local cDesc3      := ""
	Local cAlias      := "B7W"
	Local cRel        := "CENRINADI"
	Local aOrdens     := { "Operadora+Obrigação+Ano+Código Compromisso+Referência", "Operadora+Obrigação+Ano+Código Compromisso+Referência" }
	Local lDicion     := .F.
	Local lCompres    := .F.
	Local lCrystal    := .F.
	Local lFiltro     := .T.
	Default lTodosQuadros := .F.
	Default lAuto := .F.
	Private cTitulo   := cCadastro
	Private nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

	If !lTodosQuadros

		Private oReport   := nil
		Private cRelName := "DIOPS_Inadimplencia_"+CriaTrab(NIL,.F.)
		Private aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }

		oReport := FWMSPrinter():New(cRelName,6,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
		oReport:setDevice(6)
		oReport:setResolution(72)
		oReport:SetLandscape(.T.)
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)

		IIf(lAuto,oReport:CFILENAME := cRelName,"")
		IIf(lAuto,oReport:CFILEPRINT:= oReport:CPATHPRINT + oReport:CFILENAME,"")
		IIf(lAuto,.t.,oReport:Setup())
		If !lAuto .aND. oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return ()
		EndIf

	EndIf

	Processa( {|| aResult := CENDINADI() }, cCadastro)

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Inadimplência Administradora de Benefícios')
		EndIf
		Return
	EndIf

	lRet := PRINTINAD(aResult[2]) //Recebe Resultado da Query e Monta Relatório

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return
//------------------------------------------------------------------
/*/{Protheus.doc} PRINTINAD

@description Imprime Inadimplência Administradora Benefícios
@author jose.paulo
@since 15/03/2022
@version P12
@return Logico - Imprimiu ou não.

/*/
//------------------------------------------------------------------
Static Function PRINTINAD(aValores)

	LOCAL lRet		:= .T.

	PlsRDCab(cTitulo,160)

	oReport:box(140, 020, 100, 805)
	oReport:Say(125, 250, "Inadimplência - Administradora de Benefícios ", oFnt14N)
	oReport:box(200, 020, 150, 620)
	oReport:Say(180, 250, "Possui Metodologia Própria Autorizada?  ", oFnt12N)
	oReport:box(200, 620, 150, 805)
	oReport:Say(180, 700, IIF(aValores[1]=="1",'Sim','Não'), oFnt12N)
	oReport:box(260, 020, 200, 620)
	oReport:Say(235, 250, "Se possui, Informe o % apurado (*)", oFnt12N)
	oReport:box(260, 620, 200, 805)
	oReport:Say(235, 700, cValtoChar(aValores[2]) +"%", oFnt12N)
	oReport:Say(290, 30, "(*) Percentual válido para o último trimestre de acordo com a metodologia autorizada ", oFnt12N)

Return lRet


Static Function CENDINADI()

	Local cSql 		:= ""
	Local lRet 		:= .F.
	Local aResult	:= {}

	cSql := " SELECT B7W_PMPAUT, B7W_PERCAP "
	cSql += " FROM " + RetSqlName("B7W")
	cSql += " WHERE B7W_FILIAL = '" + xFilial("B7W") + "' "
	cSql += " AND B7W_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += " AND B7W_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " AND B7W_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " AND B7W_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBINA",.F.,.T.)

	TRBINA->(dbGoTop())
	If !TRBINA->(Eof())
		lRet := .T.
		While !TRBINA->(Eof())
			aAdd(aResult,{TRBINA->B7W_PMPAUT,TRBINA->B7W_PERCAP})
			TRBINA->(dbSkip())
		EndDo
	Else
		aResult	:= {0,0}
	EndIf
	TRBINA->(DbCloseArea())

Return( { lRet, aResult[1] } )

