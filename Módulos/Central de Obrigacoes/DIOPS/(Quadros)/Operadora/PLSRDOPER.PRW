#Include 'Protheus.ch'
#Include 'PLSRDIP.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 999,999,999.99"

STATIC oFnt08C 		:= TFont():New("Arial",08,08,,.F., , , , .T., .F.)
STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.F., , , , .T., .F.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .T., .F.)
STATIC oFnt10L 		:= TFont():New("MS LineDraw Regular",10,10,,.F., , , , .T., .F.)
STATIC oFnt12C 		:= TFont():New("Arial",12,12,,.F., , , , .T., .F.)
STATIC oFnt12N 		:= TFont():New("Arial",12,12,,.T., , , , .T., .F.)
STATIC oFnt12L 		:= TFont():New("MS LineDraw Regular",12,12,,.F., , , , .T., .F.)
STATIC oFnt12T 		:= TFont():New("MS LineDraw Regular",12,12,,.T., , , , .T., .F.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8BDescri

Relatório de operadoras

@author Roger C
@since 14/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDOPER(lTodosQuadros,lAuto)

	Local aSays			:= {}
	Local aButtons		:= {}
	Local cCadastro		:= "Cadastro de Operadoras de Planos de Saúde"
	Local aResult		:= {}

	DEFAULT lTodosQuadros := .F.
	DEFAULT lAuto		  := .F.

	If !lTodosQuadros

		Private cPerg     := "DIOPSINT"
		PRIVATE cTitulo   := cCadastro
		PRIVATE oReport   := nil
		PRIVATE cFileName := "Cadastro_de_Operadoras_"+CriaTrab(NIL,.F.)
		PRIVATE nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros

		If !lAuto
			Pergunte(cPerg,.F.)
		EndIf

		oReport := FWMSPrinter():New(cFileName,IMP_PDF,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
		oReport:setDevice(IMP_PDF)
		oReport:setResolution(72)
		oReport:SetLandscape()
		oReport:SetPaperSize(9)
		oReport:setMargin(10,10,10,10)
		If lAuto
			oReport:CFILENAME := cFileName
			oReport:CFILEPRINT := oReport:CPATHPRINT + oReport:CFILENAME
		Else
			oReport:Setup()  //Tela de configurações
			If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
				Return ()
			EndIf

		EndIf

	Else
		nPagina	:= 0	// Já declarada PRIVATE na chamada de todos os quadros, necessário resetar a cada quadro
	EndIf

	Processa( {|| aResult := PLSDOPER() }, "Cadastro de Operadoras de Planos de Saúde")

	// Se não há dados a apresentar
	If !aResult[1]
		If !lAuto
			MsgAlert('Não há dados a apresentar referente a Operadoras de Planos de Saúde')
		EndIf	
		Return
	EndIf 

	cTitulo := "Cadastro de Operadoras de Planos de Saúde"
	PlsRDCab(cTitulo)		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.

	lRet := PRINTOPER(aResult[2]) //Recebe Resultado da Query e Monta Relatório 

	If !lTodosQuadros .and. lRet
		oReport:EndPage()
		oReport:Print()
	EndIf

Return


Static Function PRINTOPER(aValores)

	Local lRet		:= .T.
	Local nI		:= 1
	Local nLinha	:= 105
	Local nCol1		:= 023
	Local nCol2		:= 060
	Local nCol3		:= 153
	Local nCol4		:= 453
	Local nCol5		:= 683 

	oReport:Say(nLinha, nCol1, 'Reg.ANS', oFnt10N)		 
	oReport:Say(nLinha, nCol2, 'CNPJ', oFnt10N)		 
	oReport:Say(nLinha, nCol3, 'Razão Social', oFnt10N)		 
	oReport:Say(nLinha, nCol4, 'Nome Fantasia', oFnt10N)		 
	oReport:Say(nLinha, nCol5, 'Modalidade', oFnt10N)		 
	nLinha += 15

	For nI := 1 to Len( aValores )

		If nLinha >= 580
			oReport:EndPage()
			PlsRDCab("Cadastro de Operadoras de Planos de Saúde")		// Chama função genérica que imprime cabeçalho e numera páginas, está no fonte PLSRDIOPS.PRW.
			nLinha	:= 105
		EndIf

		oReport:Say(nLinha, nCol1, aValores[nI,1], oFnt10C)		 
		oReport:Say(nLinha, nCol2, Transform(aValores[nI,2],StrTran(PicCpfCnpj("","J"),"%C","")), oFnt08C)	
		oReport:Say(nLinha, nCol3, Subs(aValores[nI,3],1,50), oFnt10C)		 
		oReport:Say(nLinha, nCol4, Subs(aValores[nI,4],1,35), oFnt10C)		 
		oReport:Say(nLinha, nCol5, IIf(aValores[nI,5] =='ADMIN', 'administradora', IIf(aValores[nI,5] $ 'COOPM/COOPO', 'cooperativa', 'padrao' ) ), oFnt10C)
		nLinha += 15	

	Next

Return lRet


Static Function PLSDOPER()

	Local nCount	:= 0
	Local aRetOPER	:= 	{}
	Local cSql 		:= ""
	Local lRet 		:= .T.
	
	cSql := " SELECT B8M_CODOPE, B8M_CNPJOP, B8M_RAZSOC, B8M_NOMFAN, B8M_MODALI "
	cSql += " FROM " + RetSqlName("B8M") + " B8M "
	cSql += " WHERE B8M_FILIAL = '" + xFilial("B8M") + "' " 
	cSql += " AND B8M.D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8M_CODOPE "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBOPE",.F.,.T.)
	
	If !TRBOPE->(Eof())
		TRBOPE->(dbGoTop())
		Do While !TRBOPE->(Eof())
			nCount++
			aAdd( aRetOPER, { TRBOPE->B8M_CODOPE, TRBOPE->B8M_CNPJOP, TRBOPE->B8M_RAZSOC, TRBOPE->B8M_NOMFAN, TRBOPE->B8M_MODALI } )
			TRBOPE->(DbSkip())		
		EndDo
	EndIf
	TRBOPE->(DbCloseArea())

Return( { nCount>0 , aRetOPER } )
