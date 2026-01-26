#INCLUDE "TOTVS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "ESTXFUN.CH"

/*/{Protheus.doc} OrigemLote
    Essa função tem como objetivo informar a Origem do Produto de um dado Lote e Sublote (caso se aplique).
    Será considerado a Nota de Entrada classificada com maior Data de Digitação, usando o maior Recnumber da SD1 como fator de desempate.
    Parte-se do pressuposto que os parâmetros da função já foram previamente validados antes de sua chamada.
    @type  Function
    @author SQUAD Entradas
    @since 14/05/2019
    @version 1.1
    @param cProduto, Caracter, Código do Produto a ser consultado.
    @param cLote, Caracter, Lote a ser consultado.
    @param cNumLote, Caracter, Sublote a ser consultado.
    @return cOrigem, Caracter, Origem do produto composto pelo primeiro caracter do campo D1_CLASFIS
/*/
Function OrigemLote(cProduto, cLote, cNumLote)

Local cOrigem := ""
Local cBkpAlias := Alias()
Local cAlias := GetNextAlias()

Default cProduto := Space(TamSX3("D1_COD")[1])
Default cLote := Space(TamSX3("D1_LOTECTL")[1])
Default cNumLote := Space(TamSX3("D1_NUMLOTE")[1])

BeginSql Alias cAlias

    SELECT D1_CLASFIS
    FROM %table:SD1%
    WHERE R_E_C_N_O_ = (
        SELECT MAX(SD1.R_E_C_N_O_)
        FROM %table:SD1% SD1
        INNER JOIN %table:SD5% SD5
        ON SD5.D5_FILIAL = %xFilial:SD5% AND
        SD1.D1_FILIAL = %xFilial:SD1% AND
        SD5.D5_NUMSEQ = SD1.D1_NUMSEQ
        WHERE   D5_PRODUTO = %Exp:cProduto% AND
                D5_LOTECTL = %Exp:cLote% AND
                D5_NUMLOTE = %Exp:cNumLote% AND
                SD5.%NotDel% AND
                D1_DTDIGIT = (
                    SELECT MAX(D1_DTDIGIT)
                    FROM %table:SD1% SD1
                    INNER JOIN %table:SD5% SD5
                    ON SD5.D5_FILIAL = %xFilial:SD5% AND
                    SD1.D1_FILIAL = %xFilial:SD1% AND
                    SD5.D5_NUMSEQ = SD1.D1_NUMSEQ
                    WHERE D5_PRODUTO = %Exp:cProduto% AND
                        D5_LOTECTL = %Exp:cLote% AND
                        D5_NUMLOTE =  %Exp:cNumLote% AND
                        SD5.%NotDel%
                )
    )

EndSql

If !(cAlias)->(EoF())
    cOrigem := If(Len((cAlias)->D1_CLASFIS) > 0, SubStr((cAlias)->D1_CLASFIS, 1, 1), "")
EndIf

(cAlias)->(dbCloseArea())

If !Empty(cBkpAlias)
    DbSelectArea(cBkpAlias)
EndIf

Return (cOrigem)


/*/{Protheus.doc} ESTMetrics
    Tem como objeto coletar metricas ao acessar o modulo de estoque para envio a license server.
    @type  Function
    @author reynaldo
    @since 31/05/2021
    @version 1.0
    @return cOrigem, Caracter, Origem do produto composto pelo primeiro caracter do campo D1_CLASFIS
/*/
Function ESTMetrics()
Local cRastro
Local cQuery
Local cCusFil
Local cMP_SUBROT

//????????????????????????????????????????????????????????????????
// Telemetria - Uso da classe FwCustomMetrics                   //
// Metrica - setAverageMetric                                   //
//????????????????????????????????????????????????????????????????
If FWLibVersion() >= "20210628"

	cRastro := SuperGetMv('MV_RASTRO', .F., 'N')

	If cRastro == "S"
		// produto com rastrealibilidade por lote
		cQuery := "SELECT COUNT(R_E_C_N_O_) NREC FROM " + RetSqlName("SB1")
		cQuery += " WHERE B1_RASTRO = 'L' AND D_E_L_E_T_ = ' '"
		nCount := MpSysExecScalar(cQuery,"NREC")
		If nCount >0
			FWCustomMetrics():setAverageMetric(	"LOTE"/*cSubRoutine*/,;
											"estoque-protheus_controle-rastreabilidade_total" /*cIdMetric*/,;
											1/*nValue*/,;
                                /*dDateSend*/,;
                                /*nLapTime*/,;
                                "MATA010"/*cRotina*/)
		EndIf

		// produto com rastreabilidade por lote
		cQuery := "SELECT COUNT(R_E_C_N_O_) NREC FROM " + RetSqlName("SB1")
		cQuery += " WHERE B1_RASTRO = 'S' AND D_E_L_E_T_ = ' '"
		nCount := MpSysExecScalar(cQuery,"NREC")
		If nCount >0
			FWCustomMetrics():setAverageMetric(	"SUBLOTE"/*cSubRoutine*/,;
												"estoque-protheus_controle-rastreabilidade_total" /*cIdMetric*/,;
												1/*nValue*/,;
                                    /*dDateSend*/,;
                                    /*nLapTime*/,;
                                    "MATA010"/*cRotina*/)
		EndIf

    EndIf

    // etiqueta com rastreabilidade forte (CB0)
    If !Empty(SuperGetMv("MV_ACDCB0",.F.," "))
        FWCustomMetrics():setAverageMetric(	"ACDXFUN"/*cSubRoutine*/,;
                                            "estoque-protheus_rastreabilidade-etiqueta_count" /*cIdMetric*/,;
                                            1/*nValue*/,;
                                            /*dDateSend*/,;
                                            /*nLapTime*/,;
                                            "ACDXFUN"/*cRotina*/)
    EndIf

    cCusFil := SuperGetMV('MV_CUSFIL',.F.,"A")

    IF cCusFil == "E"
        cMP_SUBROT := "EMPRESA"
    ELSEIF cCusFil == "F"
        cMP_SUBROT := "FILIAL"
    ELSE
        cMP_SUBROT := "ARMAZEM"
    EndIf

    FWCustomMetrics():setAverageMetric(	cMP_SUBROT/*cSubRoutine*/,;
                                        "estoque-protheus_aglutinacao-custo_total" /*cIdMetric*/,;
                                        1/*nValue*/,;
                                        /*dDateSend*/,;
                                        /*nLapTime*/,;
                                        "MATA330"/*cRotina*/)

	If SuperGetMv('MV_FFONLIN', .F., .F.)
        FWCustomMetrics():setAverageMetric(	"SIGACUSB"/*cSubRoutine*/,;
                                        "estoque-protheus_custo-fifo-on-line_count" /*cIdMetric*/,;
                                        1/*nValue*/,;
                                        /*dDateSend*/,;
                                        /*nLapTime*/,;
                                        "SIGACUSB"/*cRotina*/)
    EndIf

EndIf

Return

/*/{Protheus.doc} CV8LogView
Função genérica responsável pela aprasentação dos logs de execução(CV8) na tNewProcess

@author Leonardo Kichitaro
@since 27/05/2024
/*/
Function CV8LogView(cProc, oCenterPanel)

	Local aAreaAnt  := GetArea()
	Local cFilterIni:= ""
	Local cFilterFin:= ""   
	Local cChave	:= ""

	Local oBrowse	:= Nil

	Local aButton	:= {}

	Default cProc 		:= ""  
	Default oCenterPanel:= Nil

    If Type("cCadastro") != "C"
        cCadastro := ""
    EndIf

	aAdd(aButton,{OemToAnsi(STR0002) ,OemToAnsi(STR0002),{|| ProcLogDet("CV8", CV8->(Recno()), 2, oBrowse)}}) //"Detalhes"

	//Criado parametro para filtro
	dbSelectArea("CV8")

	dbSetOrder(1) //CV8_FILIAL+CV8_PROC+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni :='xFilial("CV8")+"'+cProc+'"'
	cFilterFin :='xFilial("CV8")+"'+cProc+'zzzzzzzzzzz"'                    
	cChave := xFilial("CV8")+cProc

	MaWndBrowse(0,;											//01
				0,;											//02
				500,;										//03
				700,;										//04
				OemToAnsi(STR0001)+" - "+cCadastro,;	    //05 - "Log de Execução"
				"CV8",;										//06
				Nil,;										//07
				Nil,;										//08
				"CV8->CV8_INFO=='4'",;						//09
				cFilterIni,;								//10
				cFilterFin,;								//11
				.T.,;										//12
				{{"OK",""},{"CANCEL",""}},;					//13
				4,;											//14
				{{"Data+Hora",1},{"Usuario+Data+Hora",2}},;	//15
				cChave,;									//16
				Nil,;										//17
				Nil,;										//18
				Nil,;										//19
				Nil,;										//20
				Nil,;										//21
				@oBrowse,;									//22
				Nil,;										//23
				Nil,;										//24
				Nil,;										//25
				oCenterPanel,;								//26
				aButton,;									//27
				Nil,;										//28
				Nil,;										//29
				.F.,;										//30
				Nil,;										//31
				".F." )										//32

	RestArea(aAreaAnt)

Return

/*/{Protheus.doc} SD3Estorno
Função genérica para gerar o estorno na SD3
@param nRecORI, Numerico, Recno a ser estornado.
@param aCposCHG, Array, array com os campos Pos 1 e conteudo pos 2 que serão gerados no registro destino.
@param lInTran, Logico, indicativo em transação.
@return nRecDES, Numerico, Recno do registro destino. 
/*/
Function SD3Estorno (nRecORI, aCposCHG, lUnlOri, lUnlDes)
Local nRecDES    := 0
Local i          := 0
Default nRecORI  := 0
Default aCposCHG := {}
Default lUnlOri  := .F.
Default lUnlDes  := .F.

If nRecORI > 0 
    dbSelectArea("SD3")
    dbgoto(nRecORI)
    RecLock("SD3",.F.)
    Replace D3_ESTORNO With "S"
    If lUnlOri
        MsUnLock()
    EndIf
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Salva a integridade dos campos de Bancos de Dados            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For i := 1 To FCount() 
        If aScan(aCposCHG,{|x| alltrim(x[1]) == alltrim(Field(i))}) == 0
            aadd (aCposCHG,{Field(i) ,FieldGet(i)})
        EndIf 
    Next i
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cria o registro de estorno com mesmos dados do original      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    RecLock("SD3",.T.)
    For i := 1 TO FCount()
        If !('D3_MSUID' $ Field(i))
            nCPO := aScan(aCposCHG,{|x| alltrim(x[1]) == alltrim(Field(i))}) 
            If nCPO > 0
                FieldPut(i,aCposCHG[nCPO,2])
            EndIf
        EndIf
    Next i
    Replace D3_USUARIO With CUSERNAME
    If lUnlDes
        MsUnLock()
    EndIf
    nRecDES := Recno()
EndIf
Return nRecDES
