#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "FWLIBVERSION.CH"

Static lFindClass 	:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools
Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//------------------------------------------------------------------
/*/{Protheus.doc} TAFFILESOC
Fonte genérico para filtros personalizados do eSocial

@author Eduardo Sukeda
@since 12/02/2019
@version 1.0 
/*/
//------------------------------------------------------------------

//--------------------------------------------------------------------
/*/{Protheus.doc} FilCpfNome
Função responsavel por filtrar os eventos por CPF

@param oBrowse  , Objeto  , Objeto do Browse onde será aplicado o filtro.
@param cAlias   , Caracter, Alias do browse onde será executado o filtro.
@param cEvento  , Caracter, Evento relacionado ao browse.
@param nTpData  , Numerico, Indica o formato do campo data: 1 = AAAA/MM, 2 = DD/MM/AAAA; 3 = MM/AAAA
@param cCpoData1, Caracter, Indica o campo correspondente à data/período que será utilizado no filtro por período.
@param cCpoData2, Caracter, Indica o campo correspondente à data/período final (se houver) que será utilizado no filtro por período.

@author Eduardo Sukeda
@since 12/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Function FilCpfNome(oBrowse, cAlias, cEvento, nTpData, cCpoData1, cCpoData2 )

	Local cPerApu     := Space(6)
	Local dPerIni     := SToD( "  /  /    " )
	Local dPerFim     := SToD( "  /  /    " )
	Local cCpf        := Space(11)
	Local cNome       := Space(70)
	Local cNrProc     := Space(20)
	Local aItems      := {}
	Local oDlg        := Nil
	Local nRadio      := 1
	Local nHeightBox  := 0
	Local nWidthBox   := 0
	Local nTop        := 0
	Local nHeight     := 290
	Local nWidth      := 590
	Local nPosIni     := 0
	Local cDtIni      := ""
	Local cDtFim      := ""
	Local bVldCpf     := {||TafVldCpf(cCpf)}
	Local bVldNom     := {||IIF(!Empty(cNome) .And. !Empty(cCpf),Alert("Por gentileza preencha somente o CPF ou o Nome para realizar o filtro."),IIF(!Empty(cNome) .And. Len(AllTrim(cNome)) <= 2,;
		Alert("Quantidade mínima de caracteres para a busca é de 3, por gentileza refine melhor seu filtro."),))}
	Local lHtml       := Iif(lFindClass,FWCSSTools():GetInterfaceCSSType() == 5,.F.)

	Default nTpData   := 1
	Default cCpoData1 := cAlias + "_PERAPU"
	Default cCpoData2 := ""

	If !TAFArqVazio(cAlias)

		If cAlias $ "V7C"
			oBrowse:DeleteFilter("NRPFilter")
		Else
			oBrowse:DeleteFilter("CPFFilter")
		EndIf

		If cAlias $ "V75"
			oDlg := MsDialog():New( 0, 0, nHeight, nWidth, "Filtro CPF",,,,,,,,, .T. )
		ElseIf cAlias $ "V7C|V9U"
			oDlg := MsDialog():New( 0, 0, nHeight, nWidth, "Filtro de Processo",,,,,,,,, .T. )
		Else
			oDlg := MsDialog():New( 0, 0, nHeight, nWidth, "Filtro CPF/Nome",,,,,,,,, .T. )
		EndIf

		nHeightBox := ( nHeight - 60 ) / 2
		nWidthBox := ( nWidth - 20 ) / 2

		@10,10 To nHeightBox,nWidthBox of oDlg Pixel

		nTop := 20

		If cAlias $ "V75"
			TSay():New( nTop, 20, { || '<font size="' + IIF(lHtml,'2','3') + '" color="#000000"><b>Informe o CPF ou Período para realizar o filtro:</b></font><br/>' }, oDlg,,,,,, .T.,,, 250, 020,,,,,, .T. )
		ElseIf cAlias $ "V7C"
			TSay():New( nTop, 20, { || '<font size="' + IIF(lHtml,'2','3') + '" color="#000000"><b>Informe o número de processo ou Período para realizar o filtro:</b></font><br/>' }, oDlg,,,,,, .T.,,, 250, 020,,,,,, .T. )
		ElseIf cAlias $ "V9U"
			TSay():New( nTop, 20, { || '<font size="' + IIF(lHtml,'2','3') + '" color="#000000"><b>Informe o número de processo ou CPF para realizar o filtro:</b></font><br/>' }, oDlg,,,,,, .T.,,, 250, 020,,,,,, .T. )
		Else	
			TSay():New( nTop, 20, { || '<font size="' + IIF(lHtml,'2','3') + '" color="#000000"><b>Informe o CPF, Período ou Nome do funcionário para realizar o filtro:</b></font><br/>' }, oDlg,,,,,, .T.,,, 250, 020,,,,,, .T. )
		EndIf

		If cAlias $ "V7C"
			nTop += 30
			TGet():New( nTop, 20  ,{ |x| If( PCount() == 0,  cNrProc, cNrProc := x ) }      , oDlg, 65 , 10, ,,,,,,, .T.,,,,,,,,,"V7CNRP",,,,,.T.,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>Número de processo</b></font><br/>'    , 1 )	
		
		ElseIf cAlias $ "V9U"
			nTop += 30
			TGet():New( nTop, 100  ,{ |x| If( PCount() == 0,  cNrProc, cNrProc := x ) }, oDlg, 65 , 10, ,,,,,,, .T.,,,,,,,,,"V9UB",,,,,.T.,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>Número de processo</b></font><br/>'    , 1 )
					
		Else
			nTop += 30
			TGet():New( nTop, 20  ,{ |x| If( PCount() == 0,  cCpf, cCpf := x ) }      , oDlg, 65 , 10, "@R 999.999.999-99",bVldCpf,,,,,, .T.,,,,,,,,,Iif( cAlias == "V75", "V73A" ,"C9VE" ),,,,,.T.,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>CPF</b></font><br/>'    , 1 )
		EndIf	

		If cAlias == 'CM6' .Or. nTpData == 2

			If !cAlias $ "V75"
				TGet():New( nTop, 100,{|x| If( PCount() == 0,  cNome, cNome := x ) }    , oDlg, 160, 10,                    ,bVldNom,,,,,, .T.,,,,,,,,,      ,,,,,   ,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>Nome</b></font><br/>', 1 )
			EndIf

			If cAlias $ "CM6|V72|V75"

				cDtIni := 'Data Início'
				cDtFim := 'Data Término'

			Else

				cDtIni := 'Data De'
				cDtFim := 'Data Até'

			EndIf

			TGet():New( 80, 20  ,{ |x| If( PCount() == 0,  dPerIni, dPerIni := x ) }, oDlg, 65 , 10, "@D"        ,,,,,,, .T.,,,,,,,,,,,,,,.T.,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>' + cDtIni + '</b></font><br/>', 1 )
			TGet():New( 80, 100 ,{ |x| If( PCount() == 0,  dPerFim, dPerFim := x ) }, oDlg, 65 , 10, "@D"        ,,,,,,, .T.,,,,,,,,,,,,,,.T.,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>' + cDtFim + '</b></font><br/>', 1 )

			If cAlias $ "CM6|V72|V75"

				aItems := {'Pesquisar Intervalo','Pesquisar Data Exata'}
				oRadio := TRadMenu():New (80,180,aItems,,oDlg,,,,,,,,100,12,,,,.T.)
				oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

			EndIf

		ElseIf cAlias $ "V9U"			
			TGet():New( nTop, 20  ,{ |x| If( PCount() == 0,  cCpf, cCpf := x ) }      , oDlg, 65 , 10, "@R 999.999.999-99",bVldCpf,,,,,, .T.,,,,,,,,,"V9UA",,,,,.T.,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>CPF</b></font><br/>'    , 1 )
		Else

			nTop += 30
			TGet():New( 50, 120 ,{ |x| If( PCount() == 0,  cPerApu, cPerApu := x ) }, oDlg, 65 , 10, "@R 99/9999",,,,,,, .T.,,,,,,,,,,,,,,   ,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>Período</b></font><br/>', 1 )
			
			If !(cAlias $ "V7C")
				TGet():New( 80,   20  ,{ |x| If( PCount() == 0,  cNome, cNome := x ) }    , oDlg, 200, 10,,bVldNom,,,,,, .T.,,,,,,,,,      ,,,,,   ,,, '<font size="' + IIF(lHtml,'2','3') + '" color="#0c9abe"><b>Nome</b></font><br/>', 1 )
			EndIf

		EndIf

		nTop += 20

		nPosIni := ( ( nWidth - 20 ) / 2 ) - 64
		SButton():New( nHeightBox + 10, nPosIni, 1, { ||IIF(TafBtnFil(oBrowse, cCpf, cPerApu, cNome, cAlias, dPerIni, dPerFim, cEvento, nRadio, nTpData, cCpoData1, cCpoData2, cNrProc ),oDlg:End(),) }, oDlg )
		nPosIni += 32
		SButton():New( nHeightBox + 10, nPosIni, 2, { || oDlg:End() }, oDlg )

		oDlg:Activate( ,,,.T. )

	EndIf

Return()

//--------------------------------------------------------------------
/*/{Protheus.doc} TafFilter
Função responsável por filtrar os eventos por CPF

@author Eduardo Sukeda
@since 12/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Function TafFilter(oBrowse, cCpf, cPerApu, cNome, cAlias, dPerIni, dPerFim, cEvento, nRadio, nTpData, cCpoData1, cCpoData2, cNrProc)

	Local cNomeFil  := ""
	Local cFiltro   := ""
	Local cCpoTrab  := ""
	Local cFilSql   := ""
	Local cPerIni   := ""
	Local cPerFim   := ""
	Local cTpEvt    := ""
	Local cIdFilter := "CPFFilter"
	Local cIdNrPr   := "NRPFilter"
	Local nQtdReg   := 0
	Local nX        := 0
	Local nPosFil   := 0
	Local aFunc     := {}
	Local aEvento   := {}
	Local lRet      := .T.
	Local lUseCPF   := (!Empty(cCpf) .AND. cAlias $ "C91|T3P") // Apenas esses eventos possuem a possibilidade de gravação direta de CPF, por conta do cenário de múltiplos vínculos.
	Local cFieldIni := ''
	Local cFieldFin := ''

	Default cEvento := ""

	// Trecho implementado para garantir que não haja impacto no filtro pro TAFA250, TAFA261 e TAFA407, pois no momento eles ainda não informam o evento para a função de filtro.
	If ValType(cEvento) == "U" .Or. Empty(cEvento)

		Do Case
			Case cAlias == "C91"
				cEvento := "S-1200"
			Case cAlias == "T3P"
				cEvento := "S-1210"
		EndCase

	EndIf

	aEvento  := TAFRotinas( cEvento, 4, .F., 2 )
	cCpoTrab := aEvento[11]
	cTpEvt   := aEvento[12]

	aFunc	 := FilIdFunc(cCpf,cAlias,cCpoTrab,cTpEvt)

	If Empty(cCpoData1)
		cCpoData1   := cAlias + "_PERAPU"
	EndIf

	If nTpData == 1
		cPerApu  := Substr(cPerApu, 3)    + Substr(cPerApu, 1, 2)
	EndIf

	cPerIni  := DtoS(dPerIni)
	cPerFim  := DtoS(dPerFim)
	cNome    := AllTrim( cNome )

	If !Empty(cNome)
		nQtdReg  := CountNm(cNome,cAlias,cCpoTrab,cPerApu,cPerIni,cPerFim,nTpData,cCpoData1,cCpoData2,nRadio,cTpEvt)
	EndIf

	If !Empty(cNome) .AND. nQtdReg >= 1
		cNomeFil := TafFilNm(cNome, cAlias, cCpoTrab, cPerIni, cPerFim, nRadio,cTpEvt, cPerApu)
	EndIf

	If !Empty(cCpf)

		cFiltro += "( "
	
		// Filtro por CPF
		If lUseCPF
			cFiltro += "(" + cAlias + "_CPF == '" + cCpf + "')"
		EndIf

		If !Empty(aFunc) .AND. AllTrim(aFunc[1][1]) <> ""
			
			If lUseCPF
				cFiltro += " .OR. "
			EndIf

			For nX := 1 To Len( aFunc )
				
				If nX >= 2
					cFiltro += " .OR. "
				EndIf

				If cTpEvt == "T"
					If cAlias == 'T2M'
						cFiltro	+= " T2M_CPFTRB == '" + aFunc[nX][3] + "' "
					ELSeIf cAlias == 'T2G'
						cFiltro	+= " T2G_CPFTRA == '" + aFunc[nX][3] + "' "
						cFiltro	+= " .OR. T2G_CPFBEN == '" + aFunc[nX][3] + "' "
					Else
						cFiltro += "(" + cAlias + "_FILIAL == '"+ aFunc[nX][1] + "' .AND. " + cAlias + "_CPF == '" + aFunc[nX][3] + "')"
					EndIf
				ElseIf cAlias == 'V9U'
					cFiltro += "(" + cAlias + "_FILIAL == '"+ aFunc[nX][1] + "' .AND. " + cAlias + "_CPFTRA == '"   + aFunc[nX][3] + "')"
				Else
					cFiltro += "(" + cAlias + "_FILIAL == '"+ aFunc[nX][1] + "' .AND. " + cCpoTrab + " == '"   + aFunc[nX][2] + "')"
				EndIf			

			Next nX

		EndIf

		cFiltro += ")"

	EndIf

	If !Empty(cPerApu) .OR. !Empty(cPerIni) .OR. !Empty(cPerFim)

		If !Empty(cCpf) .And. AllTrim(aFunc[1][1]) <> "" .And. Empty(cNomeFil)
			cFiltro += " .AND. "
		ElseIf !Empty(cCpf) .And. AllTrim(aFunc[1][1]) <> "" .And. !Empty(cNomeFil)
			cFiltro += " .AND. "
		ElseIf Empty(cCpf) .And. AllTrim(aFunc[1][1]) == "" .And. !Empty(cNomeFil)
			cFiltro += ""
		ElseIf !Empty(cCpf) .And. AllTrim(aFunc[1][1]) <> "" .And. Empty(cNomeFil)
			cFiltro += " .OR. "
		ElseIf !Empty(cCpf) .And. AllTrim(aFunc[1][1]) == "" .And. !Empty(cNomeFil)
			cFiltro += ""
		ElseIf !Empty(cCpf) .And. AllTrim(aFunc[1][1]) == "" .And. Empty(cNomeFil) 
			cFiltro += " .AND. "
		ElseIf Empty(cCpf) .And. AllTrim(aFunc[1][1]) <> "" .And. Empty(cNomeFil) .AND. AllTrim(aFunc[1][1]) != "000"
			cFiltro += " .AND. "
		ElseIf Empty(cCpf) .And. AllTrim(aFunc[1][1]) <> "" .And. !Empty(cNomeFil)
			cFiltro += ""
		EndIf

		If !Empty(cPerApu)

			If Empty(cCpoData1)
				cCpoData1   := cAlias + "_PERAPU"
			EndIf

			cFiltro += "(" + cCpoData1 + " == '" + cPerApu + "')"

		EndIf

		If cAlias $ 'CM6|V72'

			If cAlias == "CM6"
				cFieldIni := 'CM6_DTAFAS'
				cFieldFin := 'CM6_DTFAFA'
			ElseIf cAlias == "V72"
				cFieldIni := 'V72_DTINIC'
				cFieldFin := 'V72_DTTERM'
			EndIf

			If (!Empty(cNome) .AND. nQtdReg >= 1) .OR. Empty(cNome)

				If nRadio == 1

					If !Empty(cPerIni) .AND. Empty(cPerFim)
						cFiltro += "(" + cFieldIni + " >= '" + cPerIni + "') .AND. (" + cFieldIni + " <> '')"
					ElseIf Empty(cPerIni) .AND. !Empty(cPerFim)
						cFiltro += "(" + cFieldFin + " <= '" + cPerFim + "') .AND. (" + cFieldFin + " <> '')"
					ElseIf !Empty(cPerIni) .AND. !Empty(cPerFim)
						cFiltro += "((" + cFieldIni + " >= '" + cPerIni + "' .AND. (" + cFieldFin + " <= '" + cPerFim + "' .OR. " + cFieldFin + " = ' ' )) .OR. ((" + cFieldIni + " >= '" + cPerIni + "' .OR. " + cFieldIni + " = ' ' ) .AND. " + cFieldFin + " <= '" + cPerFim + "')) "
					EndIf

				ElseIf nRadio == 2

					If !Empty(cPerIni) .AND. Empty(cPerFim)
						cFiltro += "(" + cFieldIni + " == '" + cPerIni + "')"
					ElseIf Empty(cPerIni) .AND. !Empty(cPerFim)
						cFiltro += "(" + cFieldFin + " == '" + cPerFim + "')"
					ElseIf !Empty(cPerIni) .AND. !Empty(cPerFim)
						cFiltro += "(" + cFieldIni + " == '" + cPerIni + "') .AND. (" + cFieldFin + " == '" + cPerFim + "')"
					EndIf

				EndIf

			EndIf

		ElseIf nTpData == 2

			If !Empty(cPerIni) .AND. Empty(cPerFim)
				cFiltro += "(" + cCpoData1 + " >= '" + cPerIni + "')"
			ElseIf Empty(cPerIni) .AND. !Empty(cPerFim)
				cFiltro += "(" + cCpoData1 + " <= '" + cPerFim + "')"
			ElseIf !Empty(cPerIni) .AND. !Empty(cPerFim)
				cFiltro += "(" + cCpoData1 + " >= '" + cPerIni + "' .AND. " + cCpoData1 + " <= '" + cPerFim + "')"
			EndIf

		EndIf

	EndIf

	If !Empty(cNrProc)

		If !Empty(cFiltro)
			cFiltro += " .AND. "
		EndIf

		cFiltro += "(" + cAlias + "_NRPROC == '" + cNrProc + "')"

	EndIf

	If !Empty(cNomeFil) .And. Empty(cCpf) 

		If !Empty(cFiltro) .AND. AllTrim(aFunc[1][1]) != "000"
			cFiltro += " .AND. "
		EndIf

		cFiltro += (cNomeFil)

	EndIf

	If  Empty(cCpf) .And. !Empty(cNome) .And. nQtdReg >= 30

		MsgAlert("A sua busca retornou uma quantidade muito grande de registros, por gentileza refine seu filtro.", "Muitos registros")
		lRet := .F.

	ElseIf Empty(cFiltro)

		MsgAlert("O filtro utilizado para realizar a busca por trabalhador não retornou nenhum resultado. Por gentileza, refaça utilizando novos parâmetros.","Busca sem retorno")
		lRet := .F.

	ElseIf !Empty(cFiltro) .And. AllTrim(cFiltro) <> "( )"

		If cAlias $ "V7C"
			oBrowse:AddFilter("Filtro por Numero de processo",cFiltro,,.T.,,,,cIdNrPr)
		Else
			oBrowse:AddFilter("Filtro por CPF",cFiltro,,.T.,,,,cIdFilter)
		EndIf

		If cAlias $ "V7C"
			nPosFil := aScan(oBrowse:oFWFilter:aFilter,{|x| x[9] == cIdNrPr })
		Else
			nPosFil := aScan(oBrowse:oFWFilter:aFilter,{|x| x[9] == cIdFilter })
		EndIf

		cFilSql := cFiltro
		cFilSql := StrTran( Upper(cFilSql), ".OR." , "OR"  )
		cFilSql := StrTran( Upper(cFilSql), ".AND.", "AND" )
		cFilSql := StrTran( Upper(cFilSql), "=="   , "="   )

		//Essa posição do array é preenchida para que ao utilizar a geração de XML em lote, o sistema consiga utilizar o filtro aplicado ao Browse para filtrar os XMLs a serem gerados.

		oBrowse:oFWFilter:aFilter[nPosFil,3] := cFilSql
		
		If cAlias $ "V7C"
			FWMsgRun(, {|| oBrowse:ExecuteFilter( .T. ) }, "Filtro por Numero de processo", "Aplicando Filtro...")
		Else
			FWMsgRun(, {|| oBrowse:ExecuteFilter( .T. ) }, "Filtro CPF/Nome", "Aplicando Filtro...")	
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafGetCPF
Função responsável por posicionar o CPF do funcionário a partir do ID do mesmo

@author Eduardo Sukeda
@since 13/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Function TafGetCPF(cFil as character, cIdTrab as character, cCPF as character,; 
			cAlias as character, cOrigem as character)

	Local aArea     as array
    Local cRet      as character
	Local cOriEve	as character

    Default cFil    := cFilAnt
    Default cIdTrab := ""
    Default cCPF    := ""
    Default cAlias  := ""
	Default cOrigem	:= ""

	aArea	:= GetArea()
	cRet    := cCPF
	cOriEve	:= ""

	If !Empty(cIdTrab)
		If Empty(cOrigem)
			cOriEve := cAlias + IIf(cAlias $ "C91|T3P", "_ORIEVE", "_NOMEVE")

			If TafColumnPos(cOriEve)
				cOrigem := (cAlias)->&(cOriEve)
			EndIf
		EndIf

		If cOrigem == "S2400"
			V73->(DbSetOrder(4))

			If V73->(MsSeek(xFilial("V73", cFil) + cIdTrab + "1"))
				cRet := V73->V73_CPFBEN
			EndIf
		ElseIf cOrigem == "S2190"
			T3A->(DbSetOrder(3))

			If T3A->(MsSeek(xFilial("T3A", cFil) + cIdTrab + "1"))
				cRet := T3A->T3A_CPF
			EndIf
		Else
			C9V->(DbSetOrder(2))

			If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrab + "1"))
				cRet := C9V->C9V_CPF
			EndIf
		EndIf
	EndIf
    
    RestArea(aArea)

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafGetNIS
Função responsável por posicionar o NIS do funcionário a partir do ID do mesmo

@author Eduardo Sukeda
@since 13/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Function TafGetNIS(cFil as character, cIdTrab as character, cAlias as character, cCPFTrab as character)

	Local aArea      	as array
	Local cNisC9V    	as character
	Local cRet       	as character

	Default cFil 		:= cFilAnt
	Default cIdTrab		:= ""
	Default cAlias		:= ""
	Default cCPFTrab 	:= ""

	aArea      	:= GetArea()
	cNisC9V		:= ""
	cRet       	:= ""

	If cAlias == "C9V" .And. Empty(cCPFTrab)
		cCPFTrab	:= C9V->C9V_CPF
		cNisC9V		:= C9V->C9V_NIS
	EndIf

	If cAlias != "C9V" .And. !Empty(cIdTrab)
		C9V->(DbSetOrder(2))

		If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrab + "1"))
			cNisC9V	:= C9V->C9V_NIS
		EndIf
	EndIf

	If Empty(cIdTrab) .And. !Empty(cCPFTrab)
		C9V->(DbSetOrder(3))

		If C9V->(MsSeek(xFilial("C9V", cFil) + cCPFTrab + "1"))
			cIdTrab	:= C9V->C9V_ID
			cNisC9V	:= C9V->C9V_NIS
		EndIf
	EndIf

	cRet := TAF250Nis(cFil , cIdTrab, cNisC9V)

	RestArea(aArea)

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafGetNome
Função responsável por posicionar o NIS do funcionário a partir do ID do mesmo

@author Eduardo Sukeda
@since 13/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Function TafGetNome(cFil as character, cIdTrab as character, cNome as character,; 
			cAliEve as character, cCPFTrab as character, cEvent as character)

	Local aRotinas		as array
	Local aArea      	as array
	Local cOriEve		as character
	Local cRet       	as character
	Local cT3A			as character

	Default cFil		:= cFilAnt
	Default cIdTrab  	:= ""
	Default cNome    	:= ""
	Default cAliEve		:= ""
	Default cCPFTrab 	:= ""
	Default cEvent   	:= ""

	aRotinas	:= {}
	aArea		:= GetArea()
	cOriEve		:= ""
	cRet 		:= cNome
	cT3A		:= GetNextAlias()

	If Empty(cNome)
		If Empty(cIdTrab) .And. !Empty(cCPFTrab)
			If !Empty(cAliEve)
				cAliEve := AllTrim(cAliEve)
				cEvent	:= cAliEve + IIf(cAliEve $ "C91|T3P", "_ORIEVE", "_NOMEVE")

				If TAFColumnPos(cEvent)
					cOriEve := (cAliEve)->&(cAliEve + IIf(cAliEve $ "C91|T3P", "_ORIEVE", "_NOMEVE"))
				EndIf

				If cOriEve == "S2190"
					BeginSQL Alias cT3A

						SELECT T3A.T3A_ID
							FROM %Table:T3A% T3A
							WHERE T3A.%NotDel%
								AND T3A.T3A_FILIAL = %Exp:xFilial("T3A", cFil)%
								AND T3A.T3A_CPF = %Exp:cCPFTrab%
								AND T3A.T3A_ATIVO = '1'

					EndSQL

					If !(cT3A)->(EOF())
						cIdTrab := (cT3A)->T3A_ID
					EndIf

					(cT3A)->(DBCloseArea())
				ElseIf cOriEve == "S2400"
					V73->(DbSetOrder(3))

					If V73->(MsSeek(xFilial("V73", cFil) + cCPFTrab + cOriEve + "1"))
						cIdTrab := V73->V73_ID
					EndIf
				Else
					C9V->(DbSetOrder(3))

					If C9V->(MsSeek(xFilial("C9V", cFil) + cCPFTrab + "1"))
						cIdTrab := C9V->C9V_ID
					EndIf
				EndIf
			EndIf

			C9V->(DbSetOrder(3))

			If C9V->(MsSeek(xFilial("C9V", cFil) + cCPFTrab + "1"))
				cIdTrab := C9V->C9V_ID
			Else
				T3A->(DbSetOrder(3))

				If T3A->(MsSeek(xFilial("T3A", cFil) + cIdTrab + "1"))
					cIdTrab := T3A->T3A_ID
				EndIf
			EndIf
		EndIf

		aRotinas := TAFRotinas(AllTrim(cAliEve), 3, .F., 2)

		If !Empty(aRotinas)
			cRet := TAFNmTrab(cFil, cIdTrab, aRotinas[4])
		EndIf
	EndIf

	RestArea(aArea)

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafGetMatr
Função responsável por posicionar a(as) Matricula(as) do(s) funcionário(s) 
a partir do ID do trabalhador/Id da C91 e Versão da C91

@author Eduardo Sukeda
@since 13/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Function TafGetMatr(cFil as character, cIdTrab as character, cIdTab as character,;
			cVerTab as character, cCpf as character, cAlias as character, cCPFTrab as character)

	Local aArea    		as array
	Local cRet     		as character
	Local cMatric  		as character
	Local cAux     		as character
	Local cSelect  		as character
	Local cFrom    		as character
	Local cWhere   		as character
	Local cEvtAtu		as character
	Local cAliasQry		as character
	Local nX        	as numeric

	Default cFil    	:= cFilAnt
	Default cIdTrab 	:= ""
	Default cIdTab  	:= ""
	Default cVerTab  	:= ""
	Default cCpf     	:= ""
	Default cAlias   	:= ""
	Default cCPFTrab	:= ""

	aArea    	:= GetArea()
	cRet     	:= ""
	cMatric  	:= ""
	cAux     	:= ""
	cSelect  	:= ""
	cFrom    	:= ""
	cWhere   	:= ""
	cEvtAtu		:= ""
	cAliasQry	:= GetNextAlias()
	nX       	:= 1

	If cAlias == "C91"
		If !Empty(cIdTrab)
			If TAfColumnPos("C91_ORIEVE")
				cEvtAtu := AllTrim(C91->C91_ORIEVE)
			EndIf

			If Empty(cEvtAtu) .and. FwIsInCallStack('TAFA421')
				cEvtAtu := AllTrim(C9V->C9V_NOMEVE)
			EndIf 
			
			If cEvtAtu == "S2190"
				T3A->(DbSetOrder(3))
				
				If T3A->(MsSeek(xFilial("T3A", cFil) + cIdTrab + "1"))
					cRet := IIf(lLaySimplif, T3A->T3A_MATRIC, "TRABALHADOR PRELIMINAR")
				EndIf
			ElseIf cEvtAtu $ "S2200|S2300|TAUTO"
				C9V->(DbSetOrder(2))

				If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrab + "1"))
					If C9V->C9V_NOMEVE == "S2200"
						cRet := C9V->C9V_MATRIC
					ElseIf C9V->C9V_NOMEVE == "S2300" .and. !Empty(C9V->C9V_MATTSV)
						cRet := C9V->C9V_MATTSV
					ElseIf !lLaySimplif .And. C9V->C9V_NOMEVE == "S2300"
						cRet := "TRABALHADOR SEM VÍNCULO"
					ElseIf C9V->C9V_NOMEVE == "TAUTO"
						cRet := "TRABALHADOR AUTÔNOMO"
					EndIf
				EndIf 
			EndIf
		Else

			cSelect := "DISTINCT T14.T14_IDEDMD, T14.T14_CODCAT, C9L.C9L_DTRABA "

			cFrom   := RetSqlName( "T14" ) + " T14 "
			cFrom   += "LEFT JOIN "
			cFrom   += "    " + RetSqlName( "C9K" ) + " C9K  "
			cFrom   += "    ON  T14.T14_FILIAL = C9K.C9K_FILIAL "
			cFrom   += "    AND T14.T14_ID = C9K.C9K_ID  "
			cFrom   += "    AND T14.T14_VERSAO = C9K.C9K_VERSAO  "
			cFrom   += "    AND T14.T14_IDEDMD = C9K.C9K_RECIBO  "
			cFrom   += "    AND C9K.D_E_L_E_T_ = ' ' "
			cFrom   += "LEFT JOIN "
			cFrom   += "    " + RetSqlName( "C9L" ) + " C9L  "
			cFrom   += "    ON C9K.C9K_FILIAL = C9L.C9L_FILIAL "
			cFrom   += "    AND C9K.C9K_ID = C9L.C9L_ID "
			cFrom   += "    AND C9K.C9K_VERSAO = C9L.C9L_VERSAO "
			cFrom   += "    AND C9K.C9K_ESTABE = C9L.C9L_ESTABE "
			cFrom   += "    AND C9K.C9K_LOTACA = C9L.C9L_LOTACA "
			cFrom   += "    AND C9K.C9K_CODLOT = C9L.C9L_CODLOT "
			cFrom   += "    AND C9K.C9K_RECIBO = C9L.C9L_RECIBO "
			cFrom   += "    AND C9L.D_E_L_E_T_ = ' ' "

			cWhere  := "C9L.C9L_ID = '" + cIdTab + "' "
			cWhere  += "AND C9L.C9L_VERSAO = '" + cVerTab + "' "
			cWhere  += "AND T14.D_E_L_E_T_ = ' ' "

			cSelect := "%" + cSelect + "%"
			cFrom   := "%" + cFrom + "%"
			cWhere  := "%" + cWhere + "%"

			BeginSql Alias cAliasQry

				SELECT %Exp:cSelect%
				FROM %Exp:cFrom%
				WHERE %Exp:cWhere%

			EndSql

			While ( cAliasQry )->(!Eof())

				If !(AllTrim(( cAliasQry )->T14_CODCAT) $ ('000001|000002|000003|000004|000005|000006|000049'))

					If nX == 1
						cAux := "TRABALHADOR SEM VÍNCULO "
					Else
						cAux := "| TRABALHADOR SEM VÍNCULO"
					EndIf

				Else

					If nX == 1
						cAux := AllTrim(( cAliasQry )->C9L_DTRABA) + " "
					Else
						cAux := "| " + AllTrim(( cAliasQry )->C9L_DTRABA)
					EndIf

				EndIf

				cMatric := AllTrim(cMatric) + Space(1) + cAux

				( cAliasQry )->(DbSkip())

				nX++

			EndDo

			( cAliasQry )->( DbCloseArea() )

			cRet := cMatric

		EndIf
	ElseIf cAlias == "T3P"
		If !Empty(cIdTrab)
			If TAfColumnPos("T3P_ORIEVE")
				cEvtAtu := AllTrim(T3P->T3P_ORIEVE)
			EndIf
			
			If cEvtAtu == "S2190"
				T3A->(DbSetOrder(3))
				
				If T3A->(MsSeek(xFilial("T3A", cFil) + cIdTrab + "1"))
					cRet := IIf(lLaySimplif, T3A->T3A_MATRIC, "TRABALHADOR PRELIMINAR")
				EndIf
			ElseIf cEvtAtu $ "S2200|S2300|TAUTO"
				C9V->(DbSetOrder(2))

				If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrab + "1"))
					If C9V->C9V_NOMEVE == "S2200"
						cRet := C9V->C9V_MATRIC
					ElseIf lLaySimplif .And. C9V->C9V_NOMEVE == "S2300"
						cRet := C9V->C9V_MATTSV
					ElseIf !lLaySimplif .And. C9V->C9V_NOMEVE == "S2300"
						cRet := "TRABALHADOR SEM VÍNCULO"
					ElseIf C9V->C9V_NOMEVE == "TAUTO"
						cRet := "TRABALHADOR AUTÔNOMO"
					EndIf
				EndIf 
			EndIf
		Else

			cSelect := "DISTINCT T14.T14_IDEDMD, T14.T14_CODCAT, C9L.C9L_DTRABA "

			cFrom   := RetSqlName( "T3P" ) + " T3P "
			cFrom   += " LEFT JOIN "
			cFrom   += "     " + RetSqlName( "C91" ) + " C91  "
			cFrom   += "     ON T3P.T3P_FILIAL = C91.C91_FILIAL "
			cFrom   += "     AND T3P.T3P_BENEFI = C91.C91_TRABAL  "
			cFrom   += "     AND T3P.T3P_INDAPU = C91.C91_INDAPU  "
			cFrom   += "     AND T3P.T3P_PERAPU = C91.C91_PERAPU  "
			cFrom   += "     AND T3P.T3P_CPF = C91.C91_CPF  "
			cFrom   += "     AND T3P.T3P_ATIVO = C91.C91_ATIVO  "
			cFrom   += "     AND C91.D_E_L_E_T_ = ' ' "
			cFrom   += "     LEFT JOIN "
			cFrom   += "         " + RetSqlName( "T14" ) + " T14 "
			cFrom   += "         ON C91.C91_FILIAL = T14.T14_FILIAL "
			cFrom   += "         AND C91.C91_ID = T14.T14_ID "
			cFrom   += "         AND C91.C91_VERSAO = T14.T14_VERSAO "
			cFrom   += "         AND T14.D_E_L_E_T_ = ' ' "
			cFrom   += "     LEFT JOIN "
			cFrom   += "         " + RetSqlName( "C9K" ) + " C9K "
			cFrom   += "         ON  T14.T14_FILIAL = C9K.C9K_FILIAL "
			cFrom   += "         AND T14.T14_ID = C9K.C9K_ID "
			cFrom   += "         AND T14.T14_VERSAO = C9K.C9K_VERSAO "
			cFrom   += "         AND T14.T14_IDEDMD = C9K.C9K_RECIBO "
			cFrom   += "         AND C9K.D_E_L_E_T_ = ' ' "
			cFrom   += "     LEFT JOIN "
			cFrom   += "         " + RetSqlName( "C9L" ) + " C9L "
			cFrom   += "         ON C9K.C9K_FILIAL = C9L.C9L_FILIAL "
			cFrom   += "         AND C9K.C9K_ID = C9L.C9L_ID "
			cFrom   += "         AND C9K.C9K_VERSAO = C9L.C9L_VERSAO "
			cFrom   += "         AND C9K.C9K_ESTABE = C9L.C9L_ESTABE "
			cFrom   += "         AND C9K.C9K_LOTACA = C9L.C9L_LOTACA "
			cFrom   += "         AND C9K.C9K_CODLOT = C9L.C9L_CODLOT "
			cFrom   += "         AND C9K.C9K_RECIBO = C9L.C9L_RECIBO "
			cFrom   += "        AND C9L.D_E_L_E_T_ = ' ' "

			cWhere  := "T3P.T3P_CPF = '" + cCpf + "' "
			cWhere  += "AND T3P.D_E_L_E_T_ = ' ' "

			cSelect := "%" + cSelect + "%"
			cFrom   := "%" + cFrom + "%"
			cWhere  := "%" + cWhere + "%"

			BeginSql Alias cAliasQry

				SELECT %Exp:cSelect%
				FROM %Exp:cFrom%
				WHERE %Exp:cWhere%

			EndSql

			While ( cAliasQry )->(!Eof())

				If !Empty(AllTrim(( cAliasQry )->T14_CODCAT)) .And. !(AllTrim(( cAliasQry )->T14_CODCAT) $ ('000001|000002|000003|000004|000005|000006|000049'))

					If nX == 1
						cAux := "TRABALHADOR SEM VÍNCULO "
					Else
						cAux := "| TRABALHADOR SEM VÍNCULO"
					EndIf

				Else

					If !Empty(AllTrim(( cAliasQry )->C9L_DTRABA)) .And. nX == 1

						cAux := AllTrim(( cAliasQry )->C9L_DTRABA) + " "

					Else

						If !Empty(AllTrim(( cAliasQry )->C9L_DTRABA))
							cAux := "| " + AllTrim(( cAliasQry )->C9L_DTRABA)
						EndIf

					EndIf

				EndIf

				cMatric := AllTrim(cMatric) + Space(1) + cAux

				( cAliasQry )->(DbSkip())

				nX++

			EndDo

			( cAliasQry )->( DbCloseArea() )

			cRet := cMatric

		EndIf
	ElseIf cAlias $ "T2M|T2G|V2P"

		BeginSql alias cAliasQry
			SELECT 	 DISTINCT C9V_MATRIC
					,C9V_NOMEVE
			FROM %Table:C9V% C9V
			WHERE	C9V_CPF = %Exp:cCPFTrab%
				AND C9V.%NotDel%
		EndSql

		cRet := ""

		While (cAliasQry)->(!EOF())

			cRet += IIF(!Empty(cRet),' | ','')

			If !Empty( (cAliasQry)->C9V_MATRIC )
				cRet += AllTrim( (cAliasQry)->C9V_MATRIC )
			ElseIf (cAliasQry)->C9V_NOMEVE == 'S2300'
				cRet += "TRABALHADOR SEM VÍNCULO"
			ElseIf (cAliasQry)->C9V_NOMEVE == "TAUTO"
				cRet += "TRABALHADOR AUTÔNOMO"
			EndIf

			(cAliasQry)->(DbSkip())

		EndDo

		(cAliasQry)->(DbCloseArea())

	ElseIf cAlias == "T0F"
		If lLaySimplif
			C9V->(DbSetOrder(2))

			If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrab + "1"))
				cRet := C9V->C9V_MATTSV
			EndIf 
		Else
			cRet := "TRABALHADOR SEM VÍNCULO"
		EndIf
	Else
		If !Empty(cIdTrab)
			C9V->(DbSetOrder(2))

			If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrab + "1"))
				If C9V->C9V_NOMEVE == "S2200"
					cRet := C9V->C9V_MATRIC
				ElseIf C9V->C9V_NOMEVE == "S2300"
					If lLaySimplif .AND. cAlias $ "T92" 
						cRet := C9V->C9V_MATTSV
					Else
						cRet := "TRABALHADOR SEM VÍNCULO"
					EndIf
				ElseIf C9V->C9V_NOMEVE == "TAUTO"
					cRet := "TRABALHADOR AUTÔNOMO"
				EndIf
			EndIf 
		EndIf
	EndIf

	RestArea(aArea)

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafFilNm
Função responsável por retornar todos os id's com o nome inserido na dialog

@author Eduardo Sukeda
@since 06/03/2019
@version 1
/*/
//--------------------------------------------------------------------
Function TafFilNm(cNome, cAlias, cCpoTrab, cPerIni, cPerFim, nRadio, cTpEvt, cPerApu)

	Local cRet      := ""
	Local cSelect   := ""
	Local cFrom     := ""
	Local cWhere    := ""
	Local cAliasQry := GetNextAlias()
	Local cCpoNome  := ""
	Local cFieldIni := ''
	Local cFieldFin := ''
	Local nTotReg   := 0
	Local nX        := 1
	Local lAdd      := .T.

	Default cTpEvt  := ""

	If cAlias == "T3P"
		cCpoNome := "T3P_NOMER"
	ElseIf cAlias $ "C91"
		cCpoNome := cAlias + "_NOME"
	EndIf

	cSelect := " DISTINCT C9V.C9V_FILIAL, C9V.C9V_ID, C9V.C9V_CPF, T1U.T1U_NOME, T1U.T1U_DTALT  "

	cFrom   := RetSqlName( "C9V" ) + " C9V "
	cFrom   += " INNER JOIN "
	cFrom   += RetSqlName( cAlias ) + " " + cAlias + " "

	If cTpEvt == "T"

		If cAlias == "T2M"
			cFrom   += " ON  C9V.C9V_CPF     = " + cAlias + "." + cAlias + "_CPFTRB "
		ElseIf cAlias == "T2G"
			cFrom   += " ON  ( C9V.C9V_CPF     = " + cAlias + "." + cAlias + "_CPFTRA "
			cFrom   += " OR  C9V.C9V_CPF     = " + cAlias + "." + cAlias + "_CPFBEN )"
		Else
			cFrom   += " ON  C9V.C9V_CPF     = " + cAlias + "." + cAlias + "_CPF "
		EndIf

		cFrom   += " AND C9V.C9V_FILIAL = " + cAlias + "." + cAlias + "_FILIAL "
		cFrom   += " AND C9V.D_E_L_E_T_ = '' "

	Else

		If !(cCpoTrab == "C91_TRABAL")
			cFrom   += " ON  C9V.C9V_ID     = " + cAlias + "." + cCpoTrab + " "	
		Else 
			cFrom   += " ON  (C9V.C9V_ID     = " + cAlias + "." + cCpoTrab + " "	
			cFrom   += " OR C9V.C9V_CPF = " + cAlias + ".C91_CPF ) "
		EndIf

		cFrom   += " AND C9V.C9V_FILIAL = " + cAlias + "." + cAlias + "_FILIAL "
		cFrom   += " AND C9V.C9V_ATIVO  = '1' "
		cFrom   += " AND C9V.D_E_L_E_T_ = '' "

	EndIf

	cFrom   += " FULL JOIN " + RetSqlName( "T1U" ) + " T1U "
	cFrom   += " ON  T1U.T1U_ID     = C9V.C9V_ID "
	cFrom   += " AND T1U.T1U_FILIAL = C9V.C9V_FILIAL "
	cFrom   += " AND T1U.T1U_ATIVO  = '1' "
	cFrom   += " AND T1U.D_E_L_E_T_ = '' "

	cWhere  := " (( C9V.C9V_NOME LIKE '%" + AllTrim(Upper( cNome )) + "%' OR C9V.C9V_NOME LIKE '%" + AllTrim(LOWER( cNome )) + "%' )"
	cWhere  += " OR ( T1U.T1U_NOME LIKE '%" + AllTrim(Upper( cNome )) + "%' OR T1U.T1U_NOME LIKE '%" + AllTrim(LOWER( cNome )) + "%' ))"
	cWhere  += " AND C9V.D_E_L_E_T_ = ' ' "

	If cAlias $ "C91|T3P"

		If !Empty(cPerApu)
			cWhere	+= " AND " + cAlias + "." + cAlias + "_PERAPU = '"+cPerApu+"' "
		EndIf

		cWhere	+= " AND ( " + cAlias + "." + cAlias + "_ATIVO = '1' OR " + cAlias + "." + cAlias + "_ATIVO = '2' ) "
		cWhere	+= " AND " + cAlias + "." + "D_E_L_E_T_ = ' ' "

	EndIf

	If cAlias $ 'CM6|V72'

		If cAlias == "CM6"
			cFieldIni := 'CM6.CM6_DTAFAS'
			cFieldFin := 'CM6.CM6_DTFAFA'
		ElseIf cAlias == "V72"
			cFieldIni := 'V72.V72_DTINIC'
			cFieldFin := 'V72.V72_DTTERM'
		EndIf

		If nRadio == 1

			If !Empty(cPerIni) .AND. Empty(cPerFim)
				cWhere += " AND (("  + cFieldIni + " >= '" + cPerIni + "') AND ("  + cFieldIni + " <> '')) "
			ElseIf Empty(cPerIni) .AND. !Empty(cPerFim)
				cWhere += " AND (("  + cFieldFin + " <= '" + cPerFim + "') AND ("  + cFieldFin + " <> '')) "
			ElseIf !Empty(cPerIni) .AND. !Empty(cPerFim)
				cWhere += " AND (("  + cFieldIni + " >= '" + cPerIni + "' AND "  + cFieldIni + " <= '" + cPerFim + "') AND ("  + cFieldFin + " >= '" + cPerIni + "' AND "  + cFieldFin + " <= '" + cPerFim + "')) "
			EndIf

		ElseIf nRadio == 2

			If !Empty(cPerIni) .AND. Empty(cPerFim)
				cWhere += " AND ("  + cFieldIni + " = '" + cPerIni + "') "
			ElseIf Empty(cPerIni) .AND. !Empty(cPerFim)
				cWhere += " AND ("  + cFieldFin + " = '" + cPerFim + "') "
			ElseIf !Empty(cPerIni) .AND. !Empty(cPerFim)
				cWhere += " AND (("  + cFieldIni + " = '" + cPerIni + "') AND ("  + cFieldFin + " = '" + cPerFim + "')) "
			EndIf

		EndIf

	EndIf

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom + "%"
	cWhere  := "%" + cWhere + "%"

	BeginSql Alias cAliasQry

		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		WHERE %Exp:cWhere%

	EndSql

	(cAliasQry)->( DbEVal({|| nTotReg++},,{|| !Eof()}) )
	(cAliasQry)->( DbGoTop() )

	If nTotReg >= 1 .And. ( cAliasQry )->(!Eof())
		
		cRet += "("

		While ( cAliasQry )->(!Eof())
			
			T1U->( DBSetOrder( 3 ) )
			If T1U->( DBSeek( xFilial( "T1U" ,( cAliasQry )->C9V_FILIAL ) + AllTrim(( cAliasQry )->C9V_CPF) + '1' ) )
			
				RetUltAtivo('T1U', AllTrim(( cAliasQry )->C9V_CPF) + "1",3)
					
				If Upper(cNome) $ T1U->T1U_NOME .OR. Lower(cNome) $ T1U->T1U_NOME
					lAdd := .T.
				Else
					lAdd := .F.
				EndIf
			Else
				lAdd := .T.
			EndIf

			If lAdd
				cRet += "(" + cAlias + "_FILIAL == '" + AllTrim(( cAliasQry )->C9V_FILIAL) + "' .AND. "

				If cTpEvt == "T"

					If cAlias == "T2M"
						cRet += cAlias + "_CPFTRB == '" + AllTrim(( cAliasQry )->C9V_CPF) +"')
					ELseIf cAlias == "T2G"
						cRet += "(" + cAlias + "_CPFTRA == '" + AllTrim(( cAliasQry )->C9V_CPF) + "'
						cRet += " .OR. " + cAlias + "_CPFBEN == '" + AllTrim(( cAliasQry )->C9V_CPF) + "'))
					Else
						cRet += cAlias + "_CPF == '" + AllTrim(( cAliasQry )->C9V_CPF) +"')
					EndIf

				Else

					If cAlias == 'C91'
						cRet += cAlias + "_CPF == '" + AllTrim(( cAliasQry )->C9V_CPF) +"')
					Else
						cRet += cCpoTrab + " == '" + AllTrim(( cAliasQry )->C9V_ID) +"') "

					EndIf

				EndIf

				If nTotReg > nX
					cRet += " .OR. "
				EndIf

			EndIf

			( cAliasQry )->(DbSkip())

			nX++

		EndDo

		cRet += ")"

		If nTotReg == nX
			cRet += " .OR. "
		EndIf

	EndIf

	( cAliasQry )->( DbCloseArea() )

	If cAlias $ "C91|T3P" .AND. FilNomeTab(cAlias,  cCpoNome, cNome)
		If nTotReg >= 1
			cRet += ".OR. ('" + Upper(cNome) + "' $ " + cCpoNome + ") .OR. ('" + Lower(cNome) + "' $ " + cCpoNome + ")"
		Else
			cRet += " ('" + Upper(cNome) + "' $ " + cCpoNome + ") .OR. ('"+ Lower(cNome) + "' $ " + cCpoNome + ")"
		EndIf
	EndIf

	If cRet $ "()"
		cRet := ""
	EndIf

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} CountNm
Função responsável por retornar o valor de pesquisa inserida

@author Eduardo Sukeda
@since 08/03/2019
@version 1
/*/
//--------------------------------------------------------------------
Function CountNm(cNome, cAlias, cCpoTrab, cPerApu, cPerIni, cPerFim, nTpData, cCpoData1, cCpoData2, nRadio, cTpEvt)

	Local cSelect     := ""
	Local cFrom       := ""
	Local cCpoNome    := ""
	Local cFieldIni   := ''
	Local cFieldFin   := ''
	Local cAliasQry   := GetNextAlias()
	Local nQtd        := 0

	Default cCpoData2 := ""

	If (cAlias $ "C91|T3P")
		cSelect := " QTD1 + QTD2 + QTD3 QTD "
	Else
		cSelect := " QTD1 QTD "
	EndIf

	cFrom   := " (SELECT COUNT (C9V.C9V_ID) AS QTD1 "
	cFrom   += " FROM " + RetSqlName( "C9V" ) + " C9V "
	cFrom   += " INNER JOIN " + RetSqlName( cAlias ) + " "

	If cTpEvt == "T"

		If cAlias == "T2M"
			cFrom   += cAlias + " ON C9V.C9V_CPF = " + cAlias + "." + cAlias + "_CPFTRB "
		ELseIf cAlias == "T2G"
			cFrom   += cAlias + " ON ( C9V.C9V_CPF = " + cAlias + "." + cAlias + "_CPFTRA "
			cFrom   += " OR C9V.C9V_CPF = " + cAlias + "." + cAlias + "_CPFBEN ) "
		Else
			cFrom   += cAlias + " ON C9V.C9V_CPF = " + cAlias + "." + cAlias + "_CPF "
		EndIf

		cFrom   += " FULL JOIN " + RetSqlName( "T1U" ) + " T1U "
		cFrom   += " ON T1U.T1U_ID = C9V.C9V_ID "
		cFrom   += " AND T1U.T1U_FILIAL = C9V.C9V_FILIAL "
		cFrom   += " AND T1U.T1U_ATIVO = '1' "
		cFrom   += " AND T1U.D_E_L_E_T_ = '' "
		cFrom   += " WHERE (( C9V.C9V_NOME LIKE '%" + AllTrim(Upper( cNome )) + "%' OR C9V.C9V_NOME LIKE '%" + AllTrim(LOWER( cNome )) + "%' ) "
		cFrom   += " OR ( T1U.T1U_NOME LIKE '%" + AllTrim(Upper( cNome )) + "%' OR T1U.T1U_NOME LIKE '%" + AllTrim(LOWER( cNome )) + "%' ))"
		cFrom   += " AND C9V.D_E_L_E_T_ = '' "
		cFrom   += " AND " + cAlias + ".D_E_L_E_T_ = ' ' "
		cFrom   += " AND " + cAlias + "." + cAlias + "_ATIVO = '1' "

	Else

		If!(cCpoTrab == "C91_TRABAL")
			cFrom   += cAlias + " ON C9V.C9V_ID = " + cAlias + "." + cCpoTrab + " "
		Else
			cFrom   += cAlias + " ON C9V.C9V_CPF = " + cAlias + ".C91_CPF  "
		EndIf 


		cFrom   += " AND C9V.C9V_FILIAL = " + cAlias + "." + cAlias + "_FILIAL "
		cFrom   += " FULL JOIN " + RetSqlName( "T1U" ) + " T1U ON T1U.T1U_ID = C9V.C9V_ID "
		cFrom   += " AND T1U.T1U_FILIAL = C9V.C9V_FILIAL "
		cFrom   += " AND T1U.T1U_ATIVO = '1' "
		cFrom   += " AND T1U.D_E_L_E_T_ = '' "
		cFrom   += " WHERE (( C9V.C9V_NOME LIKE '%" + AllTrim(Upper( cNome )) + "%' OR C9V.C9V_NOME LIKE '%" + AllTrim(LOWER( cNome )) + "%' ) "
		cFrom   += " OR ( T1U.T1U_NOME LIKE '%" + AllTrim(Upper( cNome )) + "%' OR T1U.T1U_NOME LIKE '%" + AllTrim(LOWER( cNome )) + "%' ))"
		cFrom   += " AND C9V.C9V_ATIVO = '1' "
		cFrom   += " AND C9V.D_E_L_E_T_ = ' ' "
		
		If cCpoTrab == "C91_TRABAL"
			cFrom   += " AND C91.C91_ORIEVE <> 'S2190' "
		EndIf 

		cFrom   += " AND " + cAlias + ".D_E_L_E_T_ = ' ' "
		cFrom   += " AND (" + cAlias + "." + cAlias + "_ATIVO = '1' "
		cFrom   += " OR " + cAlias + "." + cAlias + "_ATIVO = '2' ) "

	EndIf

	If nTpData <> 2

		If !Empty(cPerApu)
			cFrom   += " AND " + cAlias + "." + cCpoData1 + " = '" + cPerApu + "' "
		EndIf

	Else

		If cAlias $ 'CM6|V72'
			If cAlias == "CM6"
				cFieldIni := 'CM6.CM6_DTAFAS'
				cFieldFin := 'CM6.CM6_DTFAFA'
			ElseIf cAlias == "V72"
				cFieldIni := 'V72.V72_DTINIC'
				cFieldFin := 'V72.V72_DTTERM'
			EndIf

			If nRadio == 1

				If !Empty(cPerIni) .AND. Empty(cPerFim)
					cFrom += " AND (("  + cFieldIni + " >= '" + cPerIni + "') AND ("  + cFieldIni + " <> '')) "
				ElseIf Empty(cPerIni) .AND. !Empty(cPerFim)
					cFrom += " AND (("  + cFieldFin + " <= '" + cPerFim + "') AND ("  + cFieldFin + " <> '')) "
				ElseIf !Empty(cPerIni) .AND. !Empty(cPerFim)
					cFrom += " AND (("  + cFieldIni + " >= '" + cPerIni + "' AND "  + cFieldIni + " <= '" + cPerFim + "') AND ("  + cFieldFin + " >= '" + cPerIni + "' AND "  + cFieldFin + " <= '" + cPerFim + "')) "
				EndIf

			ElseIf nRadio == 2

				If !Empty(cPerIni) .AND. Empty(cPerFim)
					cFrom += " AND ("  + cFieldIni + " = '" + cPerIni + "') "
				ElseIf Empty(cPerIni) .AND. !Empty(cPerFim)
					cFrom += " AND ("  + cFieldFin + " = '" + cPerFim + "') "
				ElseIf !Empty(cPerIni) .AND. !Empty(cPerFim)
					cFrom += " AND (("  + cFieldIni + " = '" + cPerIni + "') AND ("  + cFieldFin + " = '" + cPerFim + "')) "
				EndIf

			EndIf

		Else

			If !Empty(cPerIni)
				cFrom   += " AND " + cAlias + "." + cCpoData1 + " >= '" + cPerIni + "' "
			EndIf

			If !Empty(cPerFim)
				cFrom   += " AND " + cAlias + "." + IIF(!Empty(cCpoData2),cCpoData2,cCpoData1) + " <= '" + cPerFim + "' "
			EndIf

		EndIf

	EndIf

	cFrom   += ") QTD1 "

	If (cAlias $ "C91|T3P")

		If cAlias == "T3P"
			cCpoNome := "T3P_NOMER"
		ElseIf cAlias == "C91"
			cCpoNome := cAlias + "_NOME"
		EndIf

		cFrom   += " ,(SELECT COUNT (" + cAlias + "." + cAlias + "_ID) AS QTD2 "
		cFrom   += " FROM " + RetSqlName( cAlias ) + " " + cAlias + " "
		cFrom   += " WHERE "

		If !Empty(cCpoNome) .And. !Empty(cNome)
			cFrom   += "( " + cAlias + "." + cCpoNome + " LIKE '%" + AllTrim(Upper( cNome )) + "%' OR "+ cAlias + "." + cCpoNome + " LIKE '%" + AllTrim(LOWER( cNome )) + "%' ) "
		EndIf
		
		cFrom   += " AND (" + cAlias + "." + cAlias + "_ATIVO = '1' "
		cFrom   += " OR " + cAlias + "." + cAlias + "_ATIVO = '2' )"
		cFrom   += " AND " + cAlias + ".D_E_L_E_T_ = ' ' "

		If !Empty(cPerApu)
			cFrom   += " AND " + cAlias + "." + cCpoData1 + " = '" + cPerApu + "' "
		EndIf
		
		cFrom   += " ) QTD2 "
		cFrom   += ",(SELECT COUNT (T1U.T1U_ID) AS QTD3 "
		cFrom   += " FROM " + RetSqlName( "T1U" ) + " T1U "
		cFrom   += " INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cFrom   += " ON T1U.T1U_ID = C9V.C9V_ID "
		cFrom   += " AND T1U.T1U_FILIAL = C9V.C9V_FILIAL "
		cFrom   += " WHERE ( T1U.T1U_NOME LIKE '%" + AllTrim(Upper( cNome )) + "%' OR T1U.T1U_NOME LIKE '%" + AllTrim(LOWER( cNome )) + "%' )"
		cFrom   += " AND T1U.T1U_ATIVO = '1' "
		cFrom   += " AND T1U.D_E_L_E_T_ = ' ' "
		cFrom   += " AND C9V.D_E_L_E_T_ = ' ' "
		cFrom   += " AND (C9V.C9V_ATIVO = '1' "
		cFrom   += " OR C9V.C9V_ATIVO = '2' )"
		cFrom   += " ) QTD3 "
	EndIf

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom + "%"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
	EndSql

	nQtd := (( cAliasQry )->QTD)

	( cAliasQry )->( DbCloseArea() )

Return nQtd

//-------------------------------------------------------------------
/*/{Protheus.doc} FilIdFunc
Posiciona no ID do funcionário

@author  Eduardo Sukeda
@since   14/03/2019
@version 1
/*/
//-------------------------------------------------------------------
Function FilIdFunc(cCpf, cAlias, cCpoTrab,cTpEvt)

	Local aRet      := {}
	Local cSelect   := ""
	Local cFrom     := ""
	Local cWhere    := ""
	Local cAliasQry := GetNextAlias()
	Local nTotReg   := 0
	Local lAlias    := .F.

	Default cTpEvt  := ""

	If cAlias $ "V75"

		cSelect := " DISTINCT V73.V73_FILIAL, V73.V73_ID, V73.V73_CPFBEN "
		cFrom   := RetSqlName("V73") + " V73 "
		cWhere  := " V73.V73_CPFBEN = '" + cCpf + "' "
		cWhere  += " AND V73.D_E_L_E_T_ = '' " 

	Else

		cSelect := " DISTINCT C9V.C9V_FILIAL, C9V.C9V_ID, C9V.C9V_CPF "

		cFrom   := RetSqlName( "C9V" ) + " C9V "
		cFrom   += "  INNER JOIN "
		cFrom   += RetSqlName( cAlias ) + " " + cAlias + " "

		If cTpEvt == "T"

			If cAlias == 'T2M'
				cFrom   += " ON  C9V.C9V_CPF    = " + cAlias + "." + cAlias + "_CPFTRB "
			ElseIf cAlias == 'T2G'
				cFrom   += " ON  C9V.C9V_CPF    = " + cAlias + "." + cAlias + "_CPFTRA "
			Else
				cFrom   += " ON  C9V.C9V_CPF    = " + cAlias + "." + cAlias + "_CPF "
			EndIf
			cFrom   += " AND C9V.C9V_FILIAL = " + cAlias + "." + cAlias + "_FILIAL "
			cFrom   += " AND C9V.D_E_L_E_T_ = '' "

		Else

			cFrom   += " ON  C9V.C9V_ID     = " + cAlias + "." + cCpoTrab + " "
			cFrom   += " AND C9V.C9V_FILIAL = " + cAlias + "." + cAlias + "_FILIAL "
			cFrom   += " AND C9V.C9V_ATIVO  = '1' "
			cFrom   += " AND C9V.D_E_L_E_T_ = '' "
			
		EndIf

		cWhere  := " C9V.C9V_CPF = '" + cCpf + "' "
		cWhere  += " AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom + "%"
	cWhere  := "%" + cWhere + "%"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql

	If (cAliasQry)->(!Eof())

		(cAliasQry)->( DbEVal({|| nTotReg++},,{|| !Eof()}) )
		(cAliasQry)->( DbGoTop() )

		If nTotReg > 1

			While (cAliasQry)->(!Eof())
				If lAlias := .T.
					aAdd(aRet,{(cAliasQry)->(C9V_FILIAL),(cAliasQry)->(C9V_ID),(cAliasQry)->C9V_CPF})
				EndIf
				( cAliasQry )->(DbSkip())

			EndDo

		EndIf

	EndIf

	If lAlias == .F.
		If cAlias $ "V75"
			aAdd(aRet, {(cAliasQry)->(V73_FILIAL), (cAliasQry)->(V73_CPFBEN) })
		ElseIf cAlias $ "T2G" .AND. Empty((cAliasQry)->(C9V_ID))
			aAdd(aRet, { "000","00",cCpf })
		Else
			aAdd(aRet,{(cAliasQry)->(C9V_FILIAL),(cAliasQry)->(C9V_ID),(cAliasQry)->C9V_CPF})
		EndIf
	EndIf

	( cAliasQry )->( DbCloseArea() )

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafVldCpf
Função responsavel por filtrar os eventos por CPF

@author Eduardo Sukeda
@since 25/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Static Function TafVldCpf(cCpf)

	Local lRet := .T.

	If !Empty(cCpf)
		If !CGC(cCpf,,.F.)
			Alert("Por gentileza digite um CPF válido para realizar o filtro.")
			lRet := .F.
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafBtnFil
Função responsavel por filtrar os eventos por CPF

@author Eduardo Sukeda
@since 25/02/2019
@version 1
/*/
//--------------------------------------------------------------------
Static Function TafBtnFil(oBrowse, cCpf, cPerApu, cNome, cAlias, dPerIni, dPerFim, cEvento, nRadio, nTpData, cCpoData1, cCpoData2, cNrProc)

	Local lRet := .T.

	If !Empty(cNome) .And. !Empty(cCpf)

		Alert("Por gentileza preencha somente o CPF ou o Nome para realizar o filtro.")
		lRet := .F.

	ElseIf !Empty(cNome) .And. Len(AllTrim(cNome)) <= 2

		Alert("Quantidade mínima de caracteres para a busca é de 3, por gentileza refine melhor seu filtro.")
		lRet := .F.
	
	ElseIf !Empty(cNrProc) .And. Len(AllTrim(cNrProc)) <= 14

		Alert("O numero do processo deve conter 15 ou 20 caracteres, por gentileza refine melhor seu filtro.")
		lRet := .F.

	ElseIf !Empty(cCpf)

		TafVldCpf(cCpf)

	EndIf

	If lRet
		lRet := TafFilter(oBrowse, cCpf, cPerApu, cNome, cAlias, dPerIni, dPerFim, cEvento, nRadio, nTpData, cCpoData1, cCpoData2, cNrProc)
	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafNewBrowse
Função responsavel por criar o formato mais novo do Browse, com os botões do filtro por CPF/nome/período.

@param cEvento    , Caracter, Evento relacionado ao browse.
@param cCpoData1  , Caracter, Indica o campo correspondente à data/período que será utilizado no filtro por período.
@param cCpoData2  , Caracter, Indica o campo correspondente à data/período final (se houver) que será utilizado no filtro por período.
@param nTpData    , Numerico, Indica o formato do campo data: 1 = AAAA/MM, 2 = DD/MM/AAAA; 3 = MM/AAAA.
@param cTitulo    , Caracter, Titulo a ser apresentado pelo browse.
@param aOnlyFields, Array   , Relação de campos que serão exibidos no browse.
@param nIndLeg    , Numerico, Seta o indice utilizado pela funcao TafLegend().
@param nOrder     , Numerico, Seta o indice utilizado pelo método do browse SetIniWindow().
@param aLegend    , Array   , Relação de dados para montagem da legenda do browse, caso as legendas sejam apresentadas num padrão diferente do TafLegend().
@param cFilterDef , Caracter, Informa o filtro desejado para execução no objeto do browse. 

@author Leandro Dourado
@since 17/04/2019
@version 1
/*/
//--------------------------------------------------------------------
Function TafNewBrowse( cEvento, cCpoData1, cCpoData2, nTpData, cTitulo, aOnlyFields, nIndLeg, nOrder, aLegend, cFilterDef )

	Local aEvento       := TAFRotinas( cEvento, 4, .F., 2 )
	Local aSize         := FWGetDialogSize()
	Local bAjuRec       := Nil
	Local bClose        := Nil
	Local bDesExc       := Nil
	Local bExcReg       := Nil
	Local bFiltro       := Nil
	Local bGerXml       := Nil
	Local bHistAlt      := Nil
	Local bVisExc       := Nil
	Local bVldReg       := Nil
	Local bXmlLote      := Nil
	Local cAlias        := ""
	Local cFonte        := ""
	Local cFuncVld      := ""
	Local cFuncXML      := ""
	Local cLayout       := ""
	Local cTagEvt       := ""
	Local lFreeze       := .T.
	Local nHeight       := 0
	Local nTop          := 0
	Local nWidth        := 0
	Local nX            := 0
	Local oBtFil        := Nil
	Local oDialog       := Nil
	Local oLayer        := Nil
	Local oPanel01      := Nil
	Local oPanel02      := Nil

	Default aLegend     := {}
	Default aOnlyFields := {}
	Default cCpoData1   := ""
	Default cCpoData2   := ""
	Default cFilterDef  := ""
	Default cTitulo     := ""
	Default nIndLeg     := 2
	Default nOrder      := 1
	Default nTpData     := 1

	If Len(aEvento) > 0 .And. FindFunction("TAFSetFilter")

		cFonte   := aEvento[1]
		cFuncVld := aEvento[2]
		cAlias   := aEvento[3]
		cFuncXML := Iif( aEvento[8] == "TAF592Xml", "TAF591Xml", aEvento[8])
		cTagEvt  := aEvento[9]
		cLayout  :=  StrTran(aEvento[4],"S-","",,)

		bFiltro  := {|| FilCpfNome(oBrw, cAlias, cEvento, nTpData, cCpoData1, cCpoData2  ) }
		bExcReg  := {|| xTafVExc(cAlias,(cAlias)->(Recno()),1), oBrw:Refresh(.T.) }
		bDesExc  := {|| xTafVExc(cAlias,(cAlias)->(Recno()),2 , IIF(Type ("oBrw") == "U", Nil, oBrw))}
		bVisExc  := {|| xTafVExc(cAlias,(cAlias)->(Recno()),3) }
		bGerXml  := {|| IIF(FindFunction("TAFXMLRET"),TAFXMLRET(cFuncXML,cLayout,cAlias),&(cFuncXML+ "()"))}
		If !Empty(AllTrim(cFuncVld)) .And. FindFunction(cFuncVld)
			bVldReg  := {|| &(cFuncVld+ "()") }
		EndIf 
		bAjuRec  := {|| xFunAltRec( cAlias )}
		bHistAlt := Iif( cAlias $ "V75", {|| TAF591CarrHis()}, {|| xNewHisAlt( cAlias, cFonte, , , , IIF(Type ("oBrw") == "U", Nil, oBrw), cEvento,cLayout, cFuncXML)} )
		bXmlLote := IiF( cAlias $ "V75", {|| TAF591XmlLt()}, {|| TAFXmlLote( cAlias, cEvento , cTagEvt , cFuncXML, ,oBrw )} )
		bClose   := {|| oDialog:End() }
		bXmlErp  := Iif( cAlias $ "V75", {|| TAF591XmlErp()}, {|| IIF(IIf(FindFunction("PROTDATA"),PROTDATA(),.T.),XmlErpxTaf( cAlias, cFuncXML, cEvento, &((cAlias)+"->"+(cAlias + "_FILIAL"))),.F.) } )

		/*----------------------------
		Construção do Painel Principal
		----------------------------*/
		
		oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitulo,,,,,,,,, .T.,,,, .F. ) 
		
		oLayer := FWLayer():New()
		
		oLayer:Init( oDialog, .F. )
		
		oLayer:AddLine( "LINE01", 100 )
		
		oLayer:AddCollumn( "BOX01",88,, "LINE01" )
		oLayer:AddCollumn( "BOX02",12,, "LINE01" )
		
		oLayer:AddWindow( "BOX01", "PANEL01", cTitulo, 100, .F.,,, "LINE01" )
		oLayer:AddWindow( "BOX02", "PANEL02", "Outras Ações", 100, .F.,,, "LINE01" )
		
		oPanel01 := oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )
		oPanel02 := oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE01" )
		
		/*----------------------------------------------------------------
		Construção do Painel 01 - Browse do Cadastro de Folha de Pagamento
		----------------------------------------------------------------*/
	
		If TafAtualizado()
	
			oBrw:SetDescription(cTitulo)
			oBrw:SetOwner( oPanel01 )
			oBrw:SetAlias(cAlias)
			oBrw:SetIniWindow(DbSetOrder(nOrder))
		
			If Empty(cFilterDef)
				oBrw:SetFilterDefault(TAFBrwSetFilter(cAlias,cFonte,cEvento))
			Else
				oBrw:SetFilterDefault(cFilterDef)
			EndIf
		
			aOnlyFields := GetBrwFields( cAlias, aOnlyFields )

			If Len(aOnlyFields) > 0
				oBrw:SetOnlyFields( aOnlyFields )
			EndIf
		
			If Len(aLegend) > 0
				For nX := 1 To Len(aLegend)
					oBrw:AddLegend( aLegend[nX,1], aLegend[nX,2], aLegend[nX,3] )
				Next nX
			Else
				TafLegend(nIndLeg,cAlias,@oBrw)
			EndIf
	
		EndIf
	
		/*------------------------------------
		Construção do Painel 02 - Outras Ações
		------------------------------------*/
		
		nWidth := ( oPanel02:nClientWidth / 2 ) - 3
		nHeight := Int( ( oPanel02:nClientHeight / 2 ) / 10 ) - 5
		
		nTop := 5

		If cAlias $ "V75"
			oBtFil := TButton():New( 005, 002, "Filtro CPF", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		ElseIf cAlias $ "V7C"
			oBtFil := TButton():New( 005, 002, "Filtro de Processo/Periodo", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		ElseIf cAlias $ "V9U"
			oBtFil := TButton():New( 005, 002, "Filtro de Processo/CPF", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		Else	
			oBtFil := TButton():New( 005, 002, "Filtro CPF/Nome", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		EndIf

		oBtFil:SetCSS(SetCssButton("11","#FFFFFF","#1DA2C3","#1DA2C3"))

		nTop += nHeight + 5
		TButton():New( nTop, 002, "Xml ERP x TAF", oPanel02, bXmlErp, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		
		nTop += nHeight + 5
		TButton():New( nTop, 002, "Excluir Registro", oPanel02, bExcReg, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		
		nTop += nHeight + 5
		TButton():New( nTop, 002, "Desfazer Exclusão", oPanel02, bDesExc, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		
		nTop += nHeight + 5
		TButton():New( nTop, 002, "Visualizar Reg.Excl.", oPanel02, bVisExc, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		
		nTop += nHeight + 5
		TButton():New( nTop, 002, "Gerar Xml e-Social", oPanel02, bGerXml, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

		If bVldReg != Nil 
			nTop += nHeight + 5	
			TButton():New( nTop, 002, "Validar Registro", oPanel02, bVldReg, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )	
		EndIf 
		
		nTop += nHeight + 5\
		TButton():New( nTop, 002, "Ajuste de Recibo", oPanel02, bAjuRec, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		
		nTop += nHeight + 5
		TButton():New( nTop, 002, "Exibir Hist.Alt.", oPanel02, bHistAlt, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		
		nTop += nHeight + 5
		TButton():New( nTop, 002, "Gerar XML em Lote", oPanel02, bXmlLote, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
		
		/*-------------------
		Ativação da Interface
		-------------------*/
		oBrw:Activate()
		oDialog:Activate()

	EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 22/03/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

	Local cCSS := ""

	cCSS := "QPushButton{ background-color: " + cBackColor + "; "
	cCSS += "border: none; "
	cCSS += "font: bold; "
	cCSS += "color: " + cFontColor + ";"
	cCSS += "padding: 2px 5px;"
	cCSS += "text-align: center; "
	cCSS += "text-decoration: none; "
	cCSS += "display: inline-block; "
	cCSS += "font-size: " + cTamFonte + "px; "
	cCSS += "border: 1px solid " + cBorderColor + "; "
	cCSS += "border-radius: 3px "
	cCSS += "}"

Return cCSS

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFNmTrab

Retorna o nome do funcionário

@author Totvs
@since 02/08/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFNmTrab(cFil as character, cIdTrab as character, cNomEve as character)

	Local aRotinas	as array
    Local aArea     as array
	Local cQryAlias	as character
    Local cNome     as character
    Local cCPF      as character
    Local cRet      as character
	Local cEvento 	as character
	Local cQry 		as character
	Local cLibVer	as character
	Local cQuery	as character
	Local cEveAtu	as character
	Local cCampoEvt	as character
	Local lTAFA587	as logical	
	
	Default cFil	:= ""
	Default cIdTrab	:= ""
	Default cNomEve := ""
	
	aRotinas	:= {}
    aArea     	:= GetArea()
	cQryAlias	:= ""
    cNome     	:= ""
    cCPF      	:= ""
    cRet      	:= ""
	cEvento 	:= ""
	cQry 		:= ""
	cLibVer		:= ""
	cQuery		:= ""
	cEveAtu		:= ""
	cCampoEvt	:= ""
	lTAFA587	:= .F.

    If !Empty(cIdTrab)
		lTAFA587 := FwIsInCallStack("TAFA587") .Or. cNomEve == "S2231"

		If Type("cEvtPosic") == "U" .Or. ValType(cEvtPosic) == "U"
			cEvtPosic := ""
		EndIf

		If Empty(cEvtPosic) .And. Type("__cEvtPos") != "U" .And. ValType(__cEvtPos) != "U"
			cEvtPosic := __cEvtPos
		EndIf
		
		cEveAtu := cEvtPosic

		If !lTAFA587
			aRotinas := TAFRotinas(Left(AllTrim(cNomEve), 1) + "-" + Right(AllTrim(cNomEve), 4), 4, .F., 2)

			If !Empty(aRotinas)
				cCampoEvt := aRotinas[3] + IIf(aRotinas[3] $ "C91|T3P", "_ORIEVE", "_NOMEVE")
				
				If Empty(cEveAtu) .And. TAFColumnPos(cCampoEvt)
					cEveAtu	:= (aRotinas[3])->&(cCampoEvt)
				EndIf
			EndIf
		Else
			cEveAtu := "S2200"
		EndIf

		If cEveAtu == "S2190"
			T3A->(DBSetOrder(3))

			If T3A->(MsSeek(xFilial("T3A", cFil) + cIdTrab + "1"))
				cNome 	:= "TRABALHADOR PRELIMINAR"
				cCPF  	:= AllTrim(T3A->T3A_CPF)
				cRet  	:= cCPF + " - " + cNome
				cEvento := "S2190"
			EndIf
		ElseIf cEveAtu == "S2400"
			V73->(DBSetOrder(4))

			If V73->(MsSeek(xFilial("V73", cFil) + cIdTrab + "1"))
				cNome 	:= V73->V73_NOMEB
				cCPF  	:= V73->V73_CPFBEN
				cRet  	:= AllTrim(cCPF) + " - " + AllTrim(cNome)
				cEvento := "S2400"

				V73->(DBSetOrder(3))

				If V73->(MsSeek(xFilial("V73", cFil) + cCPF + "S2405" + "1"))
					cNome 	:= V73->V73_NOMEB
					cRet  	:= AllTrim(cCPF) + " - " + AllTrim(cNome)
				EndIf	
			EndIf	
		Else
			C9V->(DBSetOrder(2))

			If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrab + "1"))
				cEvento := AllTrim(C9V->C9V_NOMEVE)
				cCPF  	:= AllTrim(C9V->C9V_CPF)
				cNome	:= TAFGetNT1U(cCPF,, cFil)
				
				If Empty(cNome)
					cNome := AllTrim(C9V->C9V_NOME)
				EndIf

				cRet := cCPF + " - " + cNome
			EndIf
		EndIf
		
		If !FwIsInCallStack("TAFGETNOME") .And. !lTAFA587 .And. !Empty(cEvento)
			If !Empty(cCampoEvt)
				If TAFColumnPos(cCampoEvt)
					If Type("INCLUI") == "L" .And. Type("ALTERA") == "L"
						If INCLUI .Or. ALTERA
							FWFldPut(cCampoEvt, cEvento)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If FwIsInCallStack("TAFGATPROC")
			cRet  := cNome
		EndIf

		cEvtPosic := ""
		__cEvtPos := ""
    EndIf

    RestArea(aArea)

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetBrwFields

Busca campos marcados para exibição no browse. 
Inicialmente cada rotina passava os campos a serem exibidos, porém foi aberta issue por conta da impossibilidade de editar os campos a serem exibidos no browse.
Portanto, foi criada essa função.

@author Leandro Dourado \ Ricardo Lovrenovic
@since 07/08/2019
@version 1.0

@param cAlias      , Caracter, Alias a ser exibido no Browse.
@param aOnlyFields , Array   , Relação dos campos já indicados para serem exibidos no Browse. 

@return aRet       , Array   , Relação dos campos a serem exibidos no Browse.
/*/
//--------------------------------------------------------------------
Static Function GetBrwFields( cAlias, aOnlyFields )

	Local aRet          := aClone(aOnlyFields)
	Local nX            := 0

	Default cAlias      := ""
	Default aOnlyFields := {}

	If !Empty(cAlias)

		If Len(aOnlyFields) > 0

			aRet := {}

			For nX := 1 to Len(aOnlyFields)

				If GetSx3Cache(aOnlyFields[nx],"X3_BROWSE") == "S"
					aAdd(aRet,ALLTRIM(GetSx3Cache(aOnlyFields[nx],"X3_CAMPO")))
				EndIf

			Next nX

		EndIf

	EndIf

Return aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFArqVazio

Função que verifica se o arquivo está vazio.
Retorna .T. caso esteja e exibe mensagem para o usuário.

@author totvs
@since 04/08/2020
@version 1.0

@param cAlias      , Caracter	, Alias utilizado
@return lRet       , Boolean   	, .T. caso o arquivo esteja vazio
/*/
//--------------------------------------------------------------------
Static Function TAFArqVazio(cAlias)

	Local lRet 	:= .F.
	Local aArea	:= {}

	If !Empty(cAlias)

		aArea := (cAlias)->(GetArea())

		If (lRet := &(cAlias + '->(EOF())'))
			HELP(" ",1,"ARQVAZIO")
		EndIf

		RestArea(aArea)

	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FilNomeTab

Função que verifica se o arquivo está vazio.
Retorna .T. se encontrar registros com o campo do nome preenchido na tabela principal.

@author Alexandre de L.
@since 09/01/2023
@version 1.0

@param  cAlias     , Caracter	, Alias utilizado
@param  cCpoNome   , cCpoNome	, campo de nome na tabela
@param  cNome      , Nome pedido para ser filtrado , Alias utilizado
@return lRet       , Boolean   	, .T. caso o arquivo tenha registros.
@version 1
/*/
//--------------------------------------------------------------------
Function FilNomeTab(cAlias as character, cCpoNome as character ,cNome as character)

	Local cQuery    	as character
	Local cAliasQry 	as character
	Local nCount		as numeric  
	Local lRet          as logical

	cQuery    	:= ""
	cAliasQry 	:= GetNextAlias()
	nCount		:= 0  
	lRet        := .T.

	If cAlias == "T3P"
		cCpoNome := "T3P_NOMER"
	ElseIf cAlias $ "C91"
		cCpoNome := cAlias + "_NOME"
	EndIf

	cQuery +=   " SELECT COUNT(" + cAlias + "."+ cAlias + "_ID) AS REGISTROS "
	cQuery +=   " FROM   " + RetSQLName( cAlias ) + " " + cAlias +" "  
	cQuery +=   " WHERE ( " + cAlias + "." + cCpoNome + " LIKE '%" + Upper( cNome ) + "%' OR " + cAlias + "." + cCpoNome + " LIKE '%"+ Lower( cNome ) + "%')" 
	cQuery +=   " AND (" + cAlias + "." + cAlias +"_ATIVO = '1' OR " + cAlias + "." + cAlias +"_ATIVO = '2')"
	cQuery +=   " AND " + cAlias + ".D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias &cAliasQry
	( cAliasQry )->( DbGoTop() )

	nCount := (cAliasQry)->(REGISTROS)
	(cAliasQry)->(DbCloseArea())
	
	If nCount > 0
		lRet := .T.
	Else  
		lRet := .F.
	EndIf

Return lRet
