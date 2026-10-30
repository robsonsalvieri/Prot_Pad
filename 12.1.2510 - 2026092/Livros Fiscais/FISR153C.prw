#INCLUDE 'TOTVS.CH'


/*/{Protheus.doc} FISR153C
    Função responsável por inicializar o processamento do relatório.
    @type  Function
    @author anedino.santos
    @since 20/10/2022
/*/
Function FISR153C()
    Local oReport
	Local dPeriodo
	Local aCodFils := {}
	Local nSelFil
    Local cPergunte := "FSR153C"

	if !Pergunte(cPergunte, .T.)
		return
	endif

	nSelFil := MV_PAR02
	dPeriodo := FSA200DataApur(MV_PAR01)

	if nSelFil == 1
		aCodFils := retCodFils( .T. )
	else // nesse ponto não abro a tela de seleção. Irá trazer só a filial corrente
		aCodFils := retCodFils( .F. )
	endif

    if Empty(aCodFils)
        return
    endif

	oReport := ReportDef(cPergunte, dPeriodo, aCodFils)
	oReport:PrintDialog()
return


/*/{Protheus.doc} ReportDef
    Definição dos componentes visuais do relatório
    @type  Function
    @author anedino.santos
    @since 20/10/2022
    @param cPergunte, character, nome do pergunte cadastrado no SX1
    @param dPeriodo, date, período do processamento
    @param aCodFils, Array com filiais selecionadas
    @return oReport, object, objeto do relatório
/*/
Static function ReportDef(cPergunte,dPeriodo, aCodFils)
    Local oReport    := Nil
    Local oSection1  := Nil
    Local oSection1a := Nil
    Local oBreak1    := Nil
    Local oBreak2    := Nil
    Local oTotaliz1  := Nil
    Local oTotaliz2  := Nil
    Local cAlias     := GetNextAlias()
    Local cTitulo    := "Regime de caixa - titulos baixados"
    Local bPrint     := {|oReport| ReportPrint(oReport, dPeriodo, aCodFils, cAlias)}

    oReport := TReport():New("FISR153C", cTitulo, cPergunte, bPrint)
    oReport:SetLandScape()
    oReport:HideParamPage()
    oReport:SetLineHeight(40)

    oSection1 := TRSection():New(oReport, "Registros por filial", cAlias)

    TRCell():New(oSection1, "E5_FILIAL", , FWX3Titulo("E5_FILIAL"), X3PIcture("E5_FILIAL") , TamSx3("E5_FILIAL")[1],,, ,, "RIGHT" )

    // Definição da seção de detalhes
    oSection1a := TRSection():New(oReport, "Detalhes dos registros", cAlias,,,,,,,,,,,,,.T.)
    //oSection1a:SetHeaderPage(.T.)
    oSection1a:SetHeaderBreak(.T.)

    TRCell():New(oSection1a, "E5_FILIAL"        , , FWX3Titulo("E5_FILIAL") , X3PIcture("E5_FILIAL") , TamSx3("E5_FILIAL")[1] , , ,        , , "RIGHT")
    TRCell():New(oSection1a, "E5_DATA"          , , FWX3Titulo("E5_DATA")   , X3PIcture("E5_DATA")   , TamSx3("E5_DATA")[1]   , , ,        , , "RIGHT")
    TRCell():New(oSection1a, "E5_TIPO"          , , FWX3Titulo("E5_TIPO")   , X3PIcture("E5_TIPO")   , TamSx3("E5_TIPO")[1]   , , ,        , , "RIGHT")
	TRCell():New(oSection1a, "E5_NUMERO"        , , FWX3Titulo("E5_NUMERO") , X3PIcture("E5_NUMERO") , TamSx3("E5_NUMERO")[1] , , , "RIGHT", , "RIGHT")
    TRCell():New(oSection1a, "D2_ITEM"          , , FWX3Titulo("D2_ITEM")   , X3PIcture("D2_ITEM")   , TamSx3("D2_ITEM")[1]   , , , "RIGHT", , "RIGHT")
    TRCell():New(oSection1a, "E5_PREFIXO"       , , FWX3Titulo("E5_PREFIXO"), X3PIcture("E5_PREFIXO"), TamSx3("E5_PREFIXO")[1], , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_PARCELA"       , , FWX3Titulo("E5_PARCELA"), X3PIcture("E5_PARCELA"), TamSx3("E5_PARCELA")[1], , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_CLIFOR"        , , FWX3Titulo("E5_CLIFOR") , X3PIcture("E5_CLIFOR") , TamSx3("E5_CLIFOR")[1] , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_LOJA"          , , FWX3Titulo("E5_LOJA")   , X3PIcture("E5_LOJA")   , TamSx3("E5_LOJA")[1]   , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_TIPODOC"       , , FWX3Titulo("E5_TIPODOC"), X3PIcture("E5_TIPODOC"), TamSx3("E5_TIPODOC")[1], , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_MOTBX"         , , FWX3Titulo("E5_MOTBX")  , X3PIcture("E5_MOTBX")  , TamSx3("E5_MOTBX")[1]  , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "D2_CF"            , , FWX3Titulo("D2_CF")     , X3PIcture("D2_CF")     , TamSx3("D2_CF")[1]     , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "D2_CSOSN"         , , FWX3Titulo("D2_CSOSN")  , X3PIcture("D2_CSOSN")  , TamSx3("D2_CSOSN")[1]  , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "VAL_BAIXA"        , , "V. Baixa"              , X3PIcture("E1_VALOR")  , TamSx3("E5_VALOR")[1]  , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "VAL_REC_SEM_ARRED", , "V. Receita"            , X3PIcture("E1_VALOR")  , TamSx3("E5_VALOR")[1]  , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_VALOR"         , , FWX3Titulo("E5_VALOR")  , X3PIcture("E5_VALOR")  , TamSx3("E5_VALOR")[1]  , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "D2_ICMSRET"       , , "ICMS ST"               , X3PIcture("D2_ICMSRET"), TamSx3("D2_ICMSRET")[1], , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "D2_VALIPI"        , , "IPI"                   , X3PIcture("D2_VALIPI") , TamSx3("D2_VALIPI")[1] , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E1_VALOR"         , , FWX3Titulo("E1_VALOR")  , X3PIcture("E1_VALOR")  , TamSx3("E1_VALOR")[1]  , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E1_SERIE"         , , FWX3Titulo("E1_SERIE")  , X3PIcture("E1_SERIE")  , TamSx3("E1_SERIE")[1]  , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E1_DESDOBR"       , , FWX3Titulo("E1_DESDOBR"), X3PIcture("E1_DESDOBR"), TamSx3("E1_DESDOBR")[1], , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E1_EMISSAO"       , , FWX3Titulo("E1_EMISSAO"), X3PIcture("E1_EMISSAO"), TamSx3("E1_EMISSAO")[1], , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E1_PEDIDO"        , , FWX3Titulo("E1_PEDIDO") , X3PIcture("E1_PEDIDO") , TamSx3("E1_PEDIDO")[1] , , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_VLMULTA"       , , FWX3Titulo("E5_VLMULTA"), X3PIcture("E5_VLMULTA"), TamSx3("E5_VLMULTA")[1], , , "RIGHT", , "RIGHT")
	TRCell():New(oSection1a, "E5_VLJUROS"       , , FWX3Titulo("E5_VLJUROS"), X3PIcture("E5_VLJUROS"), TamSx3("E5_VLJUROS")[1], , , "RIGHT", , "RIGHT")
    TRCell():New(oSection1a, "E5_VLDESCO"       , , FWX3Titulo("E5_VLDESCO"), X3PIcture("E5_VLDESCO"), TamSx3("E5_VLDESCO")[1], , , "RIGHT", , "RIGHT")
    TRCell():New(oSection1a, "F13_IDATV"        , , FWX3Titulo("F13_IDATV") , X3PIcture("F13_IDATV") , TamSx3("F13_IDATV")[1] , , , "RIGHT", , "RIGHT")
    TRCell():New(oSection1a, "ENQUADR"          , , "Enquadr."              , "!@"                   , 6                      , , , "RIGHT", , "RIGHT")

    // células desabilitadas
    // o cliente poderá usar esses campos se quiser criar um novo leiaute
    oSection1a:Cell("E5_FILIAL"):Disable()
    oSection1a:Cell("E5_VLDESCO"):Disable()
    oSection1a:Cell("E5_VLJUROS"):Disable()
    oSection1a:Cell("E5_VLMULTA"):Disable()
    oSection1a:Cell("E1_DESDOBR"):Disable()
    oSection1a:Cell("E1_SERIE"):Disable()
    oSection1a:Cell("D2_VALIPI"):Disable()
    oSection1a:Cell("D2_ICMSRET"):Disable()
    oSection1a:Cell("E5_PARCELA"):Disable()
    oSection1a:Cell("E1_VALOR"):Disable()
    oSection1a:Cell("E1_PEDIDO"):Disable()
    oSection1a:Cell("E5_VALOR"):Disable()
    oSection1a:Cell("E5_DATA"):Disable()
    oSection1a:Cell("E5_TIPO"):Disable()
    oSection1a:Cell("F13_IDATV"):Disable()
    oSection1a:Cell("ENQUADR"):Disable()

    // Definindo quebra
	oBreak1 := TRBreak():New(oSection1, {||oSection1:Cell("E5_FILIAL")}, {|| "Total por filial"},,,.T.)
    // Definindo quebra
	oBreak2 := TRBreak():New(oSection1a, {||oSection1:Cell("E5_FILIAL")})

    oTotaliz1 := TRFunction():new(oSection1a:Cell("VAL_REC_SEM_ARRED"),,"SUM", oBreak1,"Total das Receitas",X3PIcture("E1_VALOR"))
    oTotaliz2 := TRFunction():new(oSection1a:Cell("VAL_BAIXA"),,"SUM", oBreak1,"Total das Baixas",X3PIcture("E1_VALOR"))

return oReport


/*/{Protheus.doc} ReportPrint
    Impressão do relatório.
    @type  Function
    @author anedino.santos
    @since 27/10/2022
    @param oReport, object, objeto do relatório
    @param dPeriodo, date, período do processamento
    @param aCodFils, character, códigos das filiais a serem processadas no formato -> "'COD01', 'COD02'"
    @param cAlias, character, alias da tabela temporária
    @return Nil
/*/
Static function ReportPrint(oReport, dPeriodo, aCodFils, cAlias)
    Local oSection1 := oReport:Section(1)
    Local oSection1a:= oReport:Section(2)
    Local aAreaSM0 	:= SM0->(GetArea())
    //Criando o Objeto da Apuração para usar as classes de apuração
    Local oApuracao	:= CriaObjApur( cFilAnt , SuperGetMv("MV_ESTADO" ,.F., "" )  , FSA200DataApur ( mv_par01 ) , LastDay(FSA200DataApur ( mv_par01 ) ) )
    Local oJsonRel  := JsonObject():new()
    Local nLenJson  := 0
    Local nF        := 0
    Local nX        := 0
    Local nCont     := 1
    Local cFil      := ""//Filial do Registro
    oJsonRel["Registros"] := {}

    For nF := 1 to Len(aCodFils)
        SM0->(DbGoTop ())
		SM0->(MsSeek (aCodFils[nF][1]+aCodFils[nF][2], .T.))
		cFilAnt := FWGETCODFILIAL

        //Realiza query para trazer as notas fiscais com receita conforme definição com os cadastros das atividades e sub atividades
        cAliasQry   := oApuracao:execQuery( "RECEITA_CAIXA", { "" , FSA200DataApur ( mv_par01 ) } )
        Do While !(cAliasQry)->(Eof ())
            RecNfCaixa( cAliasQry, NIL, NIL, '1', .T., @oJsonRel, @nCont )//Receitas Internas

            RecNfCaixa( cAliasQry, NIL, NIL, '2', .T., @oJsonRel, @nCont )//Receitas Externas

            (cAliasQry)->(DbSkip ())
        EndDo
        DbSelectArea (cAliasQry)
        (cAliasQry)->(DbCloseArea())
    Next
    nLenJson := len(oJsonRel['Registros'])//Tamanho do Json
 
    oReport:SetMeter(nLenJson)
	//While !(cAlias)->(Eof()) .and. !oReport:Cancel()
    For nX := 1 to nLenJson
        If cFil <> oJsonRel['Registros'][nX]["FILIAL"]
            oSection1:Init()
            oReport:SetMSgPrint("Imprimindo registros...")
		    oReport:IncMeter()
		    oSection1:Cell("E5_FILIAL"):SetValue(oJsonRel['Registros'][nX]["E5_FILIAL"])
		    // impressão da linha atual
		    oSection1:PrintLine()
		    oSection1a:Init()
            cFil := oJsonRel['Registros'][nX]["FILIAL"]
        EndIf
    		
        oSection1a:Cell("E5_FILIAL"        ):SetValue(oJsonRel['Registros'][nX]["FILIAL"          	])
        oSection1a:Cell("E5_DATA"          ):SetValue(oJsonRel['Registros'][nX]["E5_DATA"         	])
        oSection1a:Cell("E5_TIPO"          ):SetValue(oJsonRel['Registros'][nX]["E5_TIPO"         	])
        oSection1a:Cell("E5_NUMERO"        ):SetValue(oJsonRel['Registros'][nX]["E5_NUMERO"       	])
        oSection1a:Cell("D2_ITEM"          ):SetValue(oJsonRel['Registros'][nX]["D2_ITEM"         	])
        oSection1a:Cell("E5_PREFIXO"       ):SetValue(oJsonRel['Registros'][nX]["E5_PREFIXO"      	])
        oSection1a:Cell("E5_PARCELA"       ):SetValue(oJsonRel['Registros'][nX]["E5_PARCELA"      	])
        oSection1a:Cell("E5_CLIFOR"        ):SetValue(oJsonRel['Registros'][nX]["E5_CLIFOR"       	])
        oSection1a:Cell("E5_LOJA"          ):SetValue(oJsonRel['Registros'][nX]["E5_LOJA"         	])
        oSection1a:Cell("E5_TIPODOC"       ):SetValue(oJsonRel['Registros'][nX]["E5_TIPODOC"      	])
        oSection1a:Cell("E5_MOTBX"         ):SetValue(oJsonRel['Registros'][nX]["E5_MOTBX"        	])
        oSection1a:Cell("D2_CF"            ):SetValue(oJsonRel['Registros'][nX]["D2_CF"           	])
        oSection1a:Cell("D2_CSOSN"         ):SetValue(oJsonRel['Registros'][nX]["D2_CSOSN"        	])
        oSection1a:Cell("VAL_BAIXA"        ):SetValue(oJsonRel['Registros'][nX]["VAL_BAIXA"       	])
        oSection1a:Cell("VAL_REC_SEM_ARRED"):SetValue(oJsonRel['Registros'][nX]["VAL_REC_SEM_ARRED"  ])
        oSection1a:Cell("E5_VALOR"         ):SetValue(oJsonRel['Registros'][nX]["E5_VALOR"        	])
        oSection1a:Cell("D2_ICMSRET"       ):SetValue(oJsonRel['Registros'][nX]["D2_ICMSRET"      	])
        oSection1a:Cell("D2_VALIPI"        ):SetValue(oJsonRel['Registros'][nX]["D2_VALIPI"       	])
        oSection1a:Cell("E1_VALOR"         ):SetValue(oJsonRel['Registros'][nX]["E1_VALOR"        	])
        oSection1a:Cell("E1_SERIE"         ):SetValue(oJsonRel['Registros'][nX]["E1_SERIE"        	])
        oSection1a:Cell("E1_DESDOBR"       ):SetValue(oJsonRel['Registros'][nX]["E1_DESDOBR"      	])
        oSection1a:Cell("E1_EMISSAO"       ):SetValue(oJsonRel['Registros'][nX]["E1_EMISSAO"      	])
        oSection1a:Cell("E1_PEDIDO"        ):SetValue(oJsonRel['Registros'][nX]["E1_PEDIDO"       	])
        oSection1a:Cell("E5_VLMULTA"       ):SetValue(oJsonRel['Registros'][nX]["E5_VLMULTA"      	])
        oSection1a:Cell("E5_VLJUROS"       ):SetValue(oJsonRel['Registros'][nX]["E5_VLJUROS"      	])
        oSection1a:Cell("E5_VLDESCO"       ):SetValue(oJsonRel['Registros'][nX]["E5_VLDESCO"      	])
        oSection1a:Cell("F13_IDATV"        ):SetValue(oJsonRel['Registros'][nX]["F13_IDATV"       	])
        oSection1a:Cell("ENQUADR"          ):SetValue(oJsonRel['Registros'][nX]["ENQUADR"         	])
    	oSection1a:PrintLine()//imprime os valores atribuidos
		oReport:IncMeter()
    Next

	oSection1:Finish()
	oSection1a:Finish()
    aSize(oJsonRel["Registros"], 0)
	FreeObj(oJsonRel)
	oJsonRel    := Nil

    RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL
return

Static function execQuery(cAlias, cQuery, aArray)
    default aArray := {}
    DBUseArea(.T., "TOPCONN", TCGenQry2(NIL,NIL,cQuery, aArray), (cAlias) , .F., .T. )
return


/*/{Protheus.doc} retCodFils
    Retorna os nomes das filiais do array definido pela função MatFilCalc
    Filtra o array definido pela função MatFilCalc retornando apenas os códigos
    das filiais em uma string no seguinte formato - "'COD01', 'COD02'"
    @type  Static Function
    @author anedino.santos
    @since 20/10/2022
    @param lPergunt se a função  MatFilCalc vai mostrar a tela
    @return aCodFilsArray de Filiais Selecionadas
/*/
Static function retCodFils(lPergunta)
Local aFil	:= {}
Local aSM0	:= {}
Local aAreaSM0	:= {}
Local nFil	:= 0


//lpergunrta indica se deverá ser exibda a tela para o usuário selecionar quais filiais deverão ser processadas
//Se lPergunta estiver .F., a função retornará todas as filiais da empresa sem exibir a tela para usuário.
If lPergunta
    aFil:= MatFilCalc( .T. )  //chama função para usuário escolher filial
    If len(aFil) == 0
        MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
    EndiF
Else
    AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF

IF  Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente
	//--------------------------------------------------------

	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. (aFil[nFil][1] .OR. !lPergunta) .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf

	SM0->(RestArea(aAreaSM0))
EndIF
return aSM0

Static Function CriaObjApur(cFil, cUf, dDtIni, dDtFim)

Local oApuracao	:= nil
oApuracao := FISA153APURACAO():new()
//Popula objeto
oApuracao:setUF( cUf )
oApuracao:setDataIni( dDtIni )
oApuracao:setDataFim( dDtFim )

Return oApuracao
