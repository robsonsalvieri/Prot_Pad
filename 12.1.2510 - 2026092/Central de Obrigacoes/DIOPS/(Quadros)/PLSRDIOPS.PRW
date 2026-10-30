#Include 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fwlibversion.ch"

#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25
#Define __NTAM5  38
#Define __NTAM6  15
#Define __NTAM7  5
#Define __NTAM8  9
#Define __NTAM9  7
#Define __NTAM10 30
#Define __NTAM11 8
#Define Moeda "@E 999,999,999.99"

STATIC oFnt10C 		:= TFont():New("Arial",12,12,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)
STATIC oFnt09C 		:= TFont():New("Arial",9,9,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDIOPS

IMPRESSÃO DOS RELATÓRIOS DIOPS DA CENTRAL DE OBRIGAÇÕES

@author Roger C
@since 09/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDIOPS(lAuto)

	Local aCampos		:= {}
	Local cTabTemp		:= GetNextAlias()		// "RDIOPS"
	Local oTabTemp		:= Nil
	Local oTimer		:= Nil
	Local nTimer		:= 10000//10 segungos
	Local bTimer		:= { || Alert(Time()) }
	Local oMark
	Default lAuto		:= .F.
	Private cMark		:= GetMark()
	Private cPerg		:= "DIOPSINT"
	PRIVATE cTitulo 	:= "DIOPS - Impressão dos Quadros"
	PRIVATE oReport     := nil
	PRIVATE cFileName	:= "DIOPS_Impressao_dos_Quadros_"+CriaTrab(NIL,.F.)
	PRIVATE nPagina		:= 0
	Private aDados		:= {}

	aCampos	:= RetornaCampos()
	aDados	:= RetornaDados()

	oTabTemp	:= CriaTabelaTemp(aCampos,cTabTemp,oTabTemp)
	CarregaTemp(cTabTemp,aDados)
	CriaMarkBrowse(oMark,cTabTemp,oTabTemp,aCampos,lAuto)

	If oMark <> Nil
		oTimer := TTimer():New(nTimer, bTimer, oMark)
	EndIf

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("Imprime Quadros", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If Select(cTabTemp) > 0
		(cTabTemp)->(dbCloseArea())
	EndIf

Return

// Retorna os campos do arquivo temporários que será utilizado no browse para seleção
Static Function RetornaCampos()

	Local aCampos	:= {}
	aAdd(aCampos,{"ENVDDESCRI"	,"C",070,0,"Descrição"})//Descricao Balancete, Idade dos Saldos
	aAdd(aCampos,{"ENVDOK"		,"C",002,0,""})//Marca/Desmarca

Return aCampos

// Retorna dados referente ao código do quadro e descrição
Static Function RetornaDados()

	Local aDados		:= {}
	Local nQuadros		:= 0
	Local aQuadros		:= getQuadrosDiops()
	Local cTipo         := GetAdvFVal("B8M","B8M_MODALI",xFilial("B8M")+B3A->B3A_CODOPE,1,"Erro")

	If "COOP" $ cTipo
		cTipo := '2'
	Elseif "ADMIN" $ cTipo
		cTipo := '1'
	else
		cTipo := '3'
	EndIf

	For nQuadros := 1 TO Len(aQuadros)
		// Implementação futura destes quadros abaixo
		If aQuadros[nQuadros,1] == '2'
			Loop
		EndIf
		If cTipo $ aQuadros[nQuadros][5]
			aAdd(aDados,{AllTrim(aQuadros[nQuadros,1]),aQuadros[nQuadros,2],"",aQuadros[nQuadros,4]})	//cTrimestre,cAno,"0","",aQuadros[nQuadros,3]})
		EndIf
	Next nQuadros

Return aDados

// Cria tabela temporária para seleção
Static Function CriaTabelaTemp(aCampos,cTabTemp,oTabTemp)

	Default oTabTemp	:= Nil
	Default aCampos	:= {}
	Default cTabTemp	:= GetNextAlias()

	oTabTemp := FWTemporaryTable():New( cTabTemp )
	oTabTemp:SetFields( aCampos )
	oTabTemp:Create()

Return oTabTemp

// Transfere os dados para o temporário
Static Function CarregaTemp(cTabTemp,aDados)

	Local nFor	:= 0
	Default cTabTemp	:= GetNextAlias()
	Default aDados	:= {"",""}

	ASORT(aDados, , , { | x,y | x[2] < y[2] } )

	For nFor := 1 TO Len(aDados)
		RecLock(cTabTemp,.T.)
		(cTabTemp)->ENVDDESCRI	:= aDados[nFor,2]
		(cTabTemp)->ENVDOK		:= ""
		msUnLock()
	Next nFor

Return

// Cria a markbrowse para seleção
Static Function CriaMarkBrowse(oMark,cTabTemp,oTabTemp,aCampos,lAuto)

	Default oMark			:= Nil
	Default cTabTemp		:= GetNextAlias()
	Default oTabTemp		:= Nil
	Default aCampos			:= {}
	Default lAuto			:= .F.

	If cTabTemp <> "" .And. oTabTemp <> Nil .And. Len(aCampos) > 0

		oMark	:= FWMarkBrowse():New()
		oMark:SetDescription('Relatórios DIOPS - Central de Obrigações ')
		oMark:SetAlias(cTabTemp)
		oMark:SetFieldMark("ENVDOK")
		oMark:oBrowse:SetDBFFilter(.F.)
		oMark:oBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
		oMark:oBrowse:SetFixedBrowse(.T.)
		oMark:SetWalkThru(.F.)
		oMark:SetAmbiente(.T.)
		oMark:SetTemporary()
		oMark:oBrowse:SetFilterDefault("")
		oMark:SetAllMark({ || .F. })
		oMark:ForceQuitButton()
		oMark:SetProfileID('0')
		oMark:AddButton("Marca/Desmarca"	, { || MarcDiops(@oMark,cTabTemp) },,,, .F., 2 )
		oMark:AddButton("Imprimir Quadros"	, { || ChamaImpr(@oMark,cTabTemp) },,,, .F., 2 )

		CarregaCampos(oMark,aCampos)

		If !lAuto
			oMark:Activate()
		EndIf

	EndIf

Return

// Faz a marcação de itens que não estão selecionados e desmarca os itens selecionados (Marca/Desmarca)
Static Function MarcDiops(oMark,cTabTemp)

	Default oMark 	:= GetMarkBrow()
	Default cTabTemp:= GetNextAlias()

	DbSelectArea(cTabTemp)
	DbGotop()
	While !Eof()
		If RecLock( cTabTemp, .F. )
			(cTabTemp)->ENVDOK := IIf(Empty((cTabTemp)->ENVDOK), oMark:cMark, Space(2) )
			MsUnLock()
		EndIf
		dbSkip()
	Enddo

	// força o posicionamento do browse no primeiro registro e faz refresh de tela
	oMark:oBrowse:Gotop()
	oMark:Refresh( )

return

// Carrega dados dos campos que ficarão em tela
Static Function CarregaCampos(oMark,aCampos)

	Local nCampos		:= 1
	Local cCampo		:= ""
	Local cTitulo		:= ""
	Local nArrData		:= 0
	Local cPicture		:= ""
	Local nAlign		:= 0
	Local nSize			:= 0
	Local nDecimal		:= 0

	cCampo		:= aCampos[nCampos,1]
	cTitulo		:= aCampos[nCampos,5]
	nArrData	:= nCampos + 1
	cPicture	:= "@!"
	nAlign		:= 1
	nSize		:= aCampos[nCampos,3]
	nDecimal	:= aCampos[nCampos,4]

	aColuna := GetColuna(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	oMark:SetColumns(aColuna)

Return

// Carrega coluna dos campos em tela
Static Function GetColuna(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

	Local aColuna		:= {}
	Local bData			:= {||}
	Default nAlign    	:= 1
	Default nSize		:= 20
	Default nDecimal	:= 0
	Default nArrData	:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

	aColuna := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColuna}

// Chama impressão dos quadros
Static Function ChamaImpr(oMark,cTabTemp)

	Local cQuadro	:= ''
	Default oMark 	:= GetMarkBrow()
	Default cTabTemp:= GetNextAlias()
	Private oReport

	// Inicio de impressão igual para todos os quadros
	oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.t.,nil,@oReport,nil,nil,.f.,.f.,.t.)
	oReport:setDevice(IMP_PDF)
	oReport:setResolution(72)
	oReport:SetLandscape()
	oReport:SetPaperSize(9)
	oReport:setMargin(10,10,10,10)

	DbSelectArea(cTabTemp)
	DbGotop()
	While !(cTabTemp)->(Eof())
		If !Empty((cTabTemp)->ENVDDESCRI)

			cQuadro	:= aScan(aDados, { |x| x[2] == AllTrim((cTabTemp)->ENVDDESCRI)} )
			&(aDados[cQuadro][4])

		EndIf

		If !Empty(cQuadro)
			oReport:EndPage()
		EndIf
		(cTabTemp)->(dbSkip())

	Enddo

	// Finaliza a impressão para todos os quadros
	oReport:Print()

	// força o posicionamento do browse no primeiro registro e faz o refresh de tela
	oMark:oBrowse:Gotop()
	oMark:Refresh( )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsRDCab(cTitulo)

Faz controle de execucao do semaforo

@author Roger C
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PlsRDCab(cTitulo,nTamCab)

	Local cCNPJ         := ""
	Local cNomOp        := ""
	Local cSql          := ""
	local cNAlias 	    := getNextAlias()

	Default cTitulo 	:= 'DIOPS'
	Default nTamCab     := 300
	Default cTipDiops := "1"

	nPagina ++		// variavel Private proveniente do programa principal

	oReport:StartPage()

	//Logotipo ANS
	cBMP	:= "lgdiopsidr.bmp"

	If File("lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp")
		cBMP :=  "lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp"
	ElseIf File("lgdiopsidr" + FWGrpCompany() + ".bmp")
		cBMP :=  "lgdiopsidr" + FWGrpCompany() + ".bmp"
	EndIf

	cSql := " SELECT B8M_CNPJOP,B8M_NOMFAN "
	cSql += " FROM " + RetSqlName("B8M") + " "
	cSql += " WHERE "
	cSql += "  B8M_FILIAL = '" + xFilial("B8M") + "' "
	cSql += "  AND B8M_CODOPE = '" + B3D->B3D_CODOPE + "' "
	cSql += "  AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	If !(cNAlias)->(Eof())

		cNomOp:=(cNAlias)->B8M_NOMFAN
		cCNPJ :=(cNAlias)->B8M_CNPJOP

	EndIf

	(cNAlias)->(dbCloseArea())

	oReport:box(030, 020, 090, 805)	//Box Titulo
	oReport:Say(045, IIF(nTamCab==300,300,160), cTitulo, IIF(nTamCab==300,oFnt14N,oFnt12N))

	oReport:SayBitmap(040, 025, cBMP, , 050, 150)

	oReport:Say(045, 025, "TOTVS Central de Obrigações", oFnt10C)
	oReport:Say(045, 700, Dtoc(dDataBase)+" "+Time(), oFnt10C)

	oReport:Say(060, 300, cNomOp, oFnt10C)
	oReport:Say(060, 700, "Página:"+Str(nPagina,4,0), oFnt10C)

	oReport:Say(075, 025, "Registro ANS:"+Transform(B3D->B3D_CODOPE,"@R 99999-9"), oFnt10C)
	oReport:Say(075, 300, "CNPJ:"+Transform(cCNPJ,StrTran(PicCpfCnpj("","J"),"%C","")), oFnt10C)

	If cTipDiops == "1"
		oReport:Say(075, 700, "Referência:"+B3D->B3D_REFERE, oFnt10C)
	Else 
		oReport:Say(075, 700, "Referência:"+ MesExtenso(cMesDiops) + "/" + SUBSTR(B3D->B3D_ANO,3,2), oFnt10C)
	EndIf

Return
