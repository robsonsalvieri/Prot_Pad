#INCLUDE "PROTHEUS.CH"
#INCLUDE "LJBXTITAPI.CH"

Static lBxTit      := .F.
Static cMsgErroRT  := ""    //Variável para armazenar a mensagem de erro na baixa de títulos realizada via API (PDV Omni - PSH)

//-------------------------------------------------------------------
/*/{Protheus.doc} LjBxTitAPI
Realiza a baixa de titulos a receber (SE1) recebidos via payload JSON do
PDV Omni (PSH), reaproveitando a funcao de retaguarda STDropTitles
(mesma utilizada pelo TOTVS PDV fisico).

@type    Function
@author  Bruno Almeida
@since   29/08/2026
@version 12.1.2410

@param   jBody         , Json  , Payload recebido (tags "titulos" e "vendaPagamentos")
@param   aMensagTitulo , Array , (por referencia) mensagens de erro por titulo: { idRetaguardaTitulo, mensagem }
@return  lRetorno      , Logico, .T. quando todos os titulos foram baixados / .F. em caso de falha (tudo-ou-nada)
/*/
//-------------------------------------------------------------------
Function LjBxTitAPI(jBody, aMensagTitulo)

Local lRetorno		:= .F.
Local cCashier		:= ""
Local nInd			:= 0
Local nForm			:= 0
Local aListTitles	:= {}	//Linhas TIT_* (26 posicoes por titulo) para Self:aListTitles[4]
Local aTitRow		:= {}
Local oModel		:= Nil	//Simula grid SL4 (LjMdlSL4) para o parametro oMdlGrd de DropTitles
Local oReceipt		:= Nil	//Instancia OO STWReceiptTitle
Local aDtHr			:= {}
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local cOperador     := ""
Local lContinua     := .T.
Local aRet          := {}
Local jDescEncar    := JsonObject():New()
Local cFormaPg      := ""
Local cCliente      := ""
Local cLoja         := ""
Local aNCC          := {}
Local aDetPgto   	:= {}
Local nValParc 		:= 0
Local nDataParc 	:= 0
Local cFormaId		:= "0"
Local aDtHoraTEF	:= {}
Local aDadosComp	:= {}
Local cAdminis      := ""
Local cDataTef      := ""
Local cHoraTef      := ""
Local oDadoCompl 	:= Nil

Private cEstacao	:= ""	//DropTitles referencia cEstacao sem Type() guard (aParamSE1/cRequisicao/log) - contexto API nao possui estacao

Default aMensagTitulo := {}

cCashier := LjAuxPosic("OPERADOR DE LOJA", "MIH_ID", jBody["vendaPagamentos"][1]["idOperadorRetaguarda"], "banco")

If !Empty(cCashier)

    lBxTit      := .T.
    cMsgErroRT  := ""

    SA6->(DbSetOrder(1))
    If SA6->(DbSeek(xFilial("SA6") + padR(cCashier, tamSx3("A6_COD")[1]) ))
        cCashier := allTrim(SA6->A6_NOME)
    EndIf

    SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
    For nInd := 1 To Len(jBody["titulos"])
        If SE1->(dbSeek(jBody["titulos"][nInd]["idRetaguardaTitulo"]))

            If Empty(cCliente)
                cCliente := SE1->E1_CLIENTE
                cLoja    := SE1->E1_LOJA
            EndIf

            jDescEncar := getDescEnc(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)

            aTitRow := {}
            Aadd(aTitRow, .T.)												//01-TIT_SELE
            Aadd(aTitRow, SE1->E1_PREFIXO)									//02-TIT_PREF
            Aadd(aTitRow, SE1->E1_NUM)										//03-TIT_NUME
            Aadd(aTitRow, SE1->E1_PARCELA)									//04-TIT_PARC
            Aadd(aTitRow, SE1->E1_VENCREA)									//05-TIT_VREA
            Aadd(aTitRow, jBody["titulos"][nInd]["valorTitulo"])			//06-TIT_VALO
            Aadd(aTitRow, jDescEncar["multa"])								//07-TIT_MULT
            Aadd(aTitRow, jDescEncar["juros"])								//08-TIT_JURO
            Aadd(aTitRow, jDescEncar["desconto"])							//09-TIT_DESC
            Aadd(aTitRow, jBody["titulos"][nInd]["valorTitulo"]+jDescEncar["juros"]+jDescEncar["multa"]-jDescEncar["desconto"])			//10-TIT_RECE
            Aadd(aTitRow, SE1->E1_TIPO)										//11-TIT_TIPO
            Aadd(aTitRow, "")												//12-TIT_CONT
            Aadd(aTitRow, SE1->E1_CLIENTE)									//13-TIT_CLIE
            Aadd(aTitRow, SE1->E1_LOJA)										//14-TIT_LOJA
            Aadd(aTitRow, SE1->E1_FILIAL)									//15-TIT_FILI
            Aadd(aTitRow, SE1->(RecNo()))									//16-TIT_RECN
            Aadd(aTitRow, 0)												//17-TIT_ACRS
            Aadd(aTitRow, .F.)												//18-TIT_CACR
            Aadd(aTitRow, 0)												//19-TIT_ABAT
            Aadd(aTitRow, SE1->E1_VENCTO)									//20-TIT_VENC
            Aadd(aTitRow, "")												//21-TIT_LOCK
            Aadd(aTitRow, SE1->E1_MOEDA)									//22-TIT_MOED
            Aadd(aTitRow, Nil)												//23-TIT_INTE
			Aadd(aTitRow, LFrmDtTime(jBody["titulos"][nInd]["dataPagamento"])[1])	//24-TIT_DTBX
            Aadd(aTitRow, SE1->E1_SALDO)									//25-TIT_SALD
            Aadd(aTitRow, jBody["titulos"][nInd]["valorLiquido"])			//26-TIT_VLIQ

            Aadd(aListTitles, aTitRow)

        EndIf
    Next nInd

    If lContinua
        oModel := LjMdlSL4():New()

        For nForm := 1 To Len(jBody["vendaPagamentos"])

            cFormaPg 	:= AllTrim(LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', jBody["vendaPagamentos"][nForm]["pagamentoForma"]["idRetaguarda"], 'forma'))
			If Empty(cFormaPg)
				Aadd(aMensagTitulo, { "", STR0001}) //"Forma de Pagamento não localizada! Por favor, verifique se os cadastro auxiliares de pagamento estão devidamente cadastrados."
			EndIf

			cAdminis	:= ""
			aDtHoraTEF	:= {}
			aDadosComp 	:= {}
			cDataTef    := ""
			cHoraTef    := ""
			
            If AllTrim(cFormaPg) == "CR"
                lContinua := LjAcumNCC(cCliente, cLoja, jBody["vendaPagamentos"][nForm]["valorPago"], @aNCC)
                If lContinua
                    STDSetNCCs("1",aNCC)
                Else
                    Aadd(aMensagTitulo, { "", STR0006}) //"Valor do saldo disponivel em crédito é insuficiente para o pagamento do titulo, recebimento do titulo não efetuado!"
                    Exit
                EndIf
            Else
				//Data e Hora do Pagamento
				aDtHr := LFrmDtTime(jBody["titulos"][1]["dataPagamento"])
				
                oModel:AddLine()

                oModel:SetValue("L4_FORMA"	, cFormaPg)
				oModel:SetValue("L4_VALOR"	, jBody["vendaPagamentos"][nForm]["valorPago"])
				oModel:SetValue("L4_DATA"	, aDtHr[1])
				oModel:SetValue("L4_PARC"	, Iif(jBody["vendaPagamentos"][nForm]["quantidadeParcelas"] == 0, 1, jBody["vendaPagamentos"][nForm]["quantidadeParcelas"]))
				oModel:SetValue("L4_FORMAID", "")
				oModel:SetValue("L4_DATATEF", "")
                oModel:SetValue("L4_HORATEF", "")
                oModel:SetValue("L4_DOCTEF"	, "")
                oModel:SetValue("L4_AUTORIZ", "")
                oModel:SetValue("L4_INSTITU", "")
                oModel:SetValue("L4_NSUTEF"	, "")
                oModel:SetValue("L4_TIPCART", "")
                oModel:SetValue("L4_BANDEIR", "")
                oModel:SetValue("L4_REDEAUT", "")
                oModel:SetValue("L4_TRNID"	, "")
                oModel:SetValue("L4_TRNPCID", "")
                oModel:SetValue("L4_TRNEXID", "")
                oModel:SetValue("L4_NUMCART", "")
                oModel:SetValue("L4_ADMINIS", "")

				If cFormaPg $ "CD|CC|PX|PD" //CC=Cartao de Credito ; CD=Cartao de Debito ; PX=Pix ; PD=Pagamento Digital
					
					cAdminis := LjGetAdmFi(jBody["vendaPagamentos"][nForm], cFormaPg)
					If Empty(cAdminis)
						Aadd(aMensagTitulo, { "", STR0002 + cMsgErroRT }) //"Inconsistencia ao tentar processar a baixa de titulo: "
                        Exit
					EndIf

					cFormaId := Soma1(cFormaId)

					oModel:SetValue("L4_ADMINIS", cAdminis)
					oModel:SetValue("L4_FORMAID", cFormaId)

					oDadoCompl := jBody["vendaPagamentos"][nForm]["vendaPagamentoDadoComplementares"]

					//Verifica se tem informações caso existam pagamentos TEF
					If Len(jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"]) > 0

						If Len(jBody["vendaPagamentos"][nForm]["vendaPagamentoItems"]) > 0
							aDtHoraTEF := LFrmDtTime(jBody["vendaPagamentos"][nForm]["vendaPagamentoItems"][1]["dataVencimento"])

							If Len(aDtHoraTEF) > 1
								cDataTef := DtoS(aDtHoraTEF[1])
								cHoraTef := Replace(aDtHoraTEF[2],":","")
							EndIf
						EndIf

						oModel:SetValue("L4_DATATEF", cDataTef)
						oModel:SetValue("L4_HORATEF", cHoraTef)
						oModel:SetValue("L4_DOCTEF"	, jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"][1]["nsuHost"])
						oModel:SetValue("L4_AUTORIZ", jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"][1]["numeroAutorizacao"])
						oModel:SetValue("L4_NSUTEF"	, jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"][1]["nsuTef"])
						oModel:SetValue("L4_BANDEIR", jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"][1]["bandeira"])
						oModel:SetValue("L4_REDEAUT", jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"][1]["codigoRede"])

						If cFormaPg $ "PX|PD" //PX=Pix ; PD=Pagamento Digital
                            oModel:SetValue("L4_TRNPCID", jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"][1]["numeroAutorizacao"])
                            oModel:SetValue("L4_TRNEXID", jBody["vendaPagamentos"][nForm]["vendaPagamentoTefs"][1]["nsuHost"])
                        EndIf

					ElseIf Len(oDadoCompl) > 0 //Caso tenha dados complementares do pagamento
						
						For nInd:=1 To Len(oDadoCompl)
							If oDadoCompl[nInd]:HasProperty("pagamentoDadoComplementar")
								Aadd( aDadosComp, { AllTrim( LjAuxPosic("COMPLEM PAGAMENTO", "MIH_ID", oDadoCompl[nInd]["pagamentoDadoComplementar"]["idRetaguarda"], "campoProtheus") ), oDadoCompl[nInd]["conteudo"] } )
							EndIf
						Next nInd

						For nInd:=1 To Len(aDadosComp)
							If !Empty(aDadosComp[nInd][1])
								oModel:SetValue(aDadosComp[nInd][1], aDadosComp[nInd][2])
							EndIf
						Next nInd

					EndIf
					
					//Percorre os itens de pagamento (Parcelas)
					For nInd := 1 To Len(jBody["vendaPagamentos"][nForm]["vendaPagamentoItems"])
						nValParc	:= jBody["vendaPagamentos"][nForm]["vendaPagamentoItems"][nInd]["valorParcela"]
						nDataParc 	:= LFrmDtTime(jBody["vendaPagamentos"][nForm]["vendaPagamentoItems"][nInd]["dataVencimento"])[1]

						aAdd( aDetPgto, { 	cFormaPg	,;	//01 - Forma de pagamento
											cFormaId	,;	//02 - ID da forma de pagamento
											nValParc	,;	//03 - Valor da parcela
											nDataParc 	} ) //04 - Data de vencimento da parcela
					Next nInd

				ElseIf cFormaPg == "CH" .And. Len(jBody["vendaPagamentos"][nForm]["vendaPagamentoDadoComplementares"]) > 0 //Pagamento com Cheques
                
                    aRet := SetArrChek(jBody["vendaPagamentos"][nForm]["vendaPagamentoDadoComplementares"], jBody["vendaPagamentos"][nForm]["vendaPagamentoItems"])

                    STWSetCkRet(aRet)
                EndIf
            EndIf

        Next nForm

        //Abre a tabela SL4 (Condicao Negociada) - DropTitles verifica ColumnPos("L4_TRNID"/"L4_TRNPCID"/"L4_TRNEXID")
        //direto no alias fisico SL4, alem de ler o parametro oMdlGrd. Em uma sessao PDV normal SL4 ja esta aberta por
        //outro componente (STDFinishSale); no contexto headless da API precisa ser aberta explicitamente aqui.
        If Select("SL4") == 0
            DbSelectArea("SL4")
        EndIf

		 If Len(aMensagTitulo) == 0
			lRetorno := .T.
		EndIf

		If lRetorno
			oReceipt := STWReceiptTitle():STWReceiptTitle("", "", "", "", "", "", "", "", "", cCashier)
			oReceipt:aListTitles := { 0, "", "", aListTitles }

			lRetorno := oReceipt:DropTitles(oModel, .F., aDetPgto)
			STDSetNCCs("1", Nil)
		EndIf

        If !lRetorno
            If !Empty(cMsgErroRT)
                Aadd(aMensagTitulo, { "", STR0002 + cMsgErroRT }) //"Inconsistencia ao tentar processar a baixa de titulo: "
            EndIf
            For nInd := 1 To Len(jBody["titulos"])
                Aadd(aMensagTitulo, { jBody["titulos"][nInd]["idRetaguardaTitulo"], STR0003 }) //"Não foi possível concluir a baixa do título na Retaguarda"
            Next nInd
        EndIf
    EndIf
    
    lBxTit := .F.
    SE1->(RestArea(aAreaSE1))
    SA1->(RestArea(aAreaSA1))

    lBxTit      := .F.
    cMsgErroRT  := ""

Else
    If jBody["vendaPagamentos"][1]["idOperadorRetaguarda"] == Nil
        cOperador := "null"
    Else
        cOperador := jBody["vendaPagamentos"][1]["idOperadorRetaguarda"]
    EndIf
    Aadd(aMensagTitulo, { "", STR0004 + cOperador }) //"Operador de caixa não localizado no cadastro auxiliar, operador: "
    lRetorno := .F.
EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjGetBxTi
Retorna o conteúdo da variável estática lBxTit, que indica se a função LjBxTitAPI está em execução.

@type    Function
@author  Bruno Almeida
@since   29/08/2026
@version 12.1.2410
@return  lBxTit, Logico, Retorna .T. quando a função LjBxTitAPI está em execução / .F. quando não está em execução.
/*/
//-------------------------------------------------------------------
Function LjGetBxTi()
Return lBxTit

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAcumNCC
Busca as NCC/RA em aberto (saldo > 0) de um cliente/loja, ordenadas da mais
antiga para a mais nova (E1_VENCTO, R_E_C_N_O_), e acumula os RECNOs da SE1
em aRecnoNCC ate que a soma dos saldos (nSaldoAcu) seja suficiente para
cobrir o valor informado em nValBx. Funcao somente leitura, sem transacao.

@type    Static Function
@author  Bruno Almeida
@since   11/09/2026
@version 12.1.2410

@param   cCliente , Caractere, Codigo do cliente (A1_COD/E1_CLIENTE)
@param   cLoja    , Caractere, Loja do cliente (A1_LOJA/E1_LOJA)
@param   nValBx   , Numerico, Valor que se pretende baixar (criterio de parada do acumulo)
@param   aNCC     , Array (por referencia), Recnos da SE1 acumulados, do mais antigo para o mais novo
@param   nSaldoAcu, Numerico (por referencia), Soma dos saldos (E1_SALDO) dos titulos acumulados

@return  lSuficien, Logico, Retorna .T. quando nSaldoAcu >= nValBx (saldo suficiente) e .F. caso contrario
/*/
//-------------------------------------------------------------------
Static Function LjAcumNCC(cCliente, cLoja, nValBx, aNCC, nSaldoAcu)

Local cQuery     := ""
Local oQuery     := Nil
Local cAlias     := ""
Local cMoeda     := SuperGetMV("MV_MOEDA1")

Default aNCC := {}
Default nSaldoAcu := 0

cQuery := " SELECT E1_SALDO, E1_NUM, E1_EMISSAO, E1_MOEDA, E1_PREFIXO, E1_PARCELA, E1_TIPO, E1_FILIAL, R_E_C_N_O_ RECNOSE1 "
cQuery += " FROM " + RetSqlName("SE1")
cQuery += " WHERE D_E_L_E_T_  = ? "
cQuery += "   AND E1_FILIAL   = ? "
cQuery += "   AND E1_CLIENTE  = ? "
cQuery += "   AND E1_LOJA     = ? "
cQuery += "   AND E1_TIPO IN ('NCC','RA') "
cQuery += "   AND E1_SALDO > 0 "
cQuery += " ORDER BY E1_VENCTO, R_E_C_N_O_ "

oQuery := FwExecStatement():New( ChangeQuery(cQuery) )
oQuery:SetString(1, ' ')
oQuery:SetString(2, xFilial("SE1"))
oQuery:SetString(3, cCliente)
oQuery:SetString(4, cLoja)

cAlias := oQuery:OpenAlias()

While !(cAlias)->( Eof() ) .And. nSaldoAcu < nValBx
    aAdd(aNCC, {.T.,;
               (cAlias)->E1_SALDO,;
               (cAlias)->E1_NUM,;
               (cAlias)->E1_EMISSAO,;
               (cAlias)->RECNOSE1,;
               (cAlias)->E1_SALDO,;
               cMoeda,;
               (cAlias)->E1_MOEDA,;
               (cAlias)->E1_PREFIXO,;
               (cAlias)->E1_PARCELA,;
               (cAlias)->E1_TIPO,;
               (cAlias)->E1_FILIAL})
    nSaldoAcu += (cAlias)->E1_SALDO
    (cAlias)->( DbSkip() )
EndDo

(cAlias)->( DbCloseArea() )
oQuery:Destroy()

Return (nSaldoAcu >= nValBx)

/*/{Protheus.doc} LjSRTMsgEr
Atribui mensagem de erro na variável estática cMsgErroRT na execução do recebimento de titulos via API.

@type    Function
@author  Alberto Deviciente
@since   09/09/2026
@version 12
@param   cMsg   , Caractere, Mensagem de erro a ser atribuida na variável estática cMsgErroRT.
@return  Nil    , Nulo
/*/
//-----------------------------------------------------------------------------------
Function LjSRTMsgEr(cMsgErr)
    cMsgErroRT += cMsgErr
Return Nil

/*/{Protheus.doc} SetArrChek
    função que recebe os dados complementares do pagamento e os itens de pagamento, processa essas informações e retorna um array com os valores extraídos.
    @type  Static Function
    @author eduardo.Flima
    @since 08/09/2026
    @version P12
    @param jDadosCom, Json, Dados complementares do pagamento
    @param jPgtoItens, Json, Itens de pagamento
    @return aRet, Array, Array contendo os valores extraídos dos dados complementares e itens de pagamento
    @example
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³Estrutura do array aRet ³
        //³1 - Banco do Cheque     ³			
        //³2 - Numero do Cheque    ³						
        //³3 - Agencia do Cheque   ³			
        //³4 - Conta do Cheque     ³									
        //³5 - Compensacao         ³			
        //³6 - Emitente            ³						
        //³7 - Telefone            ³									
        //³8 - RG                  ³
        //³9 - Checkbox Emitente   ³
        //³10- Data                ³					
        //³11- Valor               ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
/*/
Static Function SetArrChek(jDadosCom as Json, jPgtoItens as Json)
    Local aRet          := {}
    Local nComp       := 0
    Local cCampoProth := ""
    Local oComplement := Nil
    Local cGetBan := ""
    Local cGetNum := ""
    Local cGetAge := ""
    Local cGetCon := ""
    Local cGetCom := ""
    Local cGetEmi := ""
    Local cGetTel := ""
    Local cGetRg := ""
    Local lEmi := .F.
    Local nGetVal := 0
    Local dGetDt := Ctod("")
    Local dDtmp := Ctod("")

    For nComp := 1 To Len(jDadosCom)

        oComplement := jDadosCom[nComp]

        cCampoProth := AllTrim(LjAuxPosic(;
            "COMPLEM PAGAMENTO",;
            "MIH_ID",;
            oComplement["pagamentoDadoComplementar"]["idRetaguarda"],;
            "campoProtheus"))

        Do Case
        Case cCampoProth == "L4_ADMINIS"
            cGetBan := oComplement["conteudo"]

        Case cCampoProth == "L4_NUMCART"
            cGetNum := oComplement["conteudo"]

        Case cCampoProth == "L4_AGENCIA"
            cGetAge := oComplement["conteudo"]

        Case cCampoProth == "L4_CONTA"
            cGetCon := oComplement["conteudo"]

        Case cCampoProth == "L4_COMP"
            cGetCom := oComplement["conteudo"]

        Case cCampoProth == "L4_NOMECLI"
            cGetEmi := oComplement["conteudo"]

        Case cCampoProth == "L4_TELEFON"
            cGetTel := oComplement["conteudo"]

        Case cCampoProth == "L4_RG"
            cGetRg := oComplement["conteudo"]
        Case cCampoProth == "L4_TERCEIR"
            lEmi := oComplement["conteudo"] == "True"
        EndCase

    Next nComp

    for nComp := 1 To Len(jPgtoItens)
        nGetVal += jPgtoItens[nComp]["valorParcela"]
        dDtmp :=  stod(left(strtran(strtran(jPgtoItens[nComp]["dataVencimento"],"-",""),"/",""),8))
        if !Empty(dDtmp) .and. dDtmp >  dGetDt
            dGetDt := dDtmp
        Endif 
    Next nComp
     
    Aadd(aRet, {{cGetBan, cGetNum, cGetAge, cGetCon, cGetCom, cGetEmi, cGetTel, cGetRg, lEmi, dGetDt, nGetVal}})
Return aRet

/*/{Protheus.doc} getDescEnc
    Recupera descontos  encargos de um título específico baseado no prefixo, número do título, parcela e tipo de documento.
    @type  Static Function
    @author user
    @since 11/09/2026
    @version P12
    @param cPrefixo, character, Prefixo do título
    @param cNumtit, character, Número do título
    @param cParcela, character, Parcela do título
    @param cTpDoc, character, Tipo de documento do título
    @return jRet, JsonObject, Objeto JSON contendo os valores de saldo original, multa, juros, desconto e saldo agregado do título.
/*/
Static Function getDescEnc(cPrefixo as Character, cNumtit as Character, cParcela as Character, cTpDoc as Character)
	Local aParams  := Array(13)
	Local aTitulos := {}
	Local cTipo    := "1" //Enviar 1 para titulos em aberto ou 2 para titulos já fechados
    Local jRet     := JsonObject():New()
    lOCAL cCgc := ""
    Local aArea := GetArea()
    Local aAreaSE1		:= SE1->(GetArea())
    Local aAreaSA1		:= SA1->(GetArea())
    Local nAtit := 0

    DbSelectArea("SE1") 
    DbSetOrder(1)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

    jRet["saldo_orig"]      := 0
    jRet["multa"]           := 0
    jRet["juros"]           := 0
    jRet["desconto"]        := 0
    jRet["saldo_agregado"]  := 0

    SE1->(dbGoTop())
    If SE1->(DbSeek(xFilial("SE1") ;
        +padr(cPrefixo,tamSx3("E1_PREFIXO")[1]) ;
        +padr(cNumtit,tamSx3("E1_NUM")[1]) ;
        +padr(cParcela,tamSx3("E1_PARCELA")[1]) ;
        +padr(cTpDoc,tamSx3("E1_TIPO")[1]) ;
        ))
        If SA1->(DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA ))
            cCgc := SA1->A1_CGC
        EndIf

        aParams[1] := SuperGetMV("MV_LJRECEB")
        aParams[2] := padR(SE1->E1_CLIENTE, tamSx3("A1_COD")[1]) //Codigo do cliente A1_COD
        aParams[3] := padR(SE1->E1_LOJA, tamSx3("A1_LOJA")[1]) //Loja do cliente A1_LOJA
        aParams[4] := padR(cCgc, tamSx3("A1_CGC")[1]) //CPF ou CNPJ do cliente
        aParams[5] := ""//cCartao
        aParams[6] := ""//cNumRA
        aParams[7] := padR(cPrefixo, tamSx3("E1_PREFIXO")[1]) //cPrefixo
        aParams[8] := padR(cNumtit, tamSx3("E1_NUM")[1]) //cNum
        aParams[9] := padR(cParcela, tamSx3("E1_PARCELA")[1]) //cParcela
        aParams[10] := Nil
        aParams[11] := Nil
        aParams[12] := ""
        aParams[13] := ""
        aAreaSe1 := SE1->(GetArea())
        aTitulos := STRecLoad( cTipo, aParams )
        RestArea(aAreaSe1)
        SE1->(DbSkip())
        if !Empty(aTitulos) .and. !Empty(aTitulos[4])
            nAtit := aScan(aTitulos[4] , {|x| padr(x[10],tamSx3("E1_TIPO")[1]) == padr(cTpDoc,tamSx3("E1_TIPO")[1]) } ) //Defino o tipo certo caso retorne mais de um titulo com o mesmo numero e parcela
            if nAtit >= 0
                jRet["saldo_orig"]:= aTitulos[4][nAtit][5]
                jRet["multa"]:= aTitulos[4][nAtit][6]
                jRet["juros"]:= aTitulos[4][nAtit][7]
                jRet["desconto"]:= aTitulos[4][nAtit][8]
                jRet["saldo_agregado"]:= aTitulos[4][nAtit][9]
            EndIf
        EndIf
    Endif 
    SE1->(RestArea(aAreaSE1))
    SA1->(RestArea(aAreaSA1))
    RestArea(aArea)
Return jRet

/*/{Protheus.doc} LFrmDtTime
Formata DateTime (AAAA-MM-DDTHH:MM:SS) para o formato local standard (DD/MM/YYYY HH:MM:SS).

@type    Function
@author  Alberto Deviciente
@since   09/09/2026
@version 12
@param   cDataHora  , Caractere , Data e hora a ser transformada para o formato local standard.
@return  aRet       , Array     , Array contendo a data e hora local standard.
/*/
//-----------------------------------------------------------------------------------
Function LFrmDtTime(cDataHora)
	Local aRet := {}
	aRet := { SToD(StrTran(SubStr(cDataHora,1,10),"-","")) , SubStr(cDataHora,12,8) }
Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} LjGetAdmFI
Retorna a administradora Financeira

@type    Function
@param   oDadosCompl, Objeto, Nó de dados complementares do Json de pagamento
@param   cFormaPg   , Caractere, Forma de pagamento utilizada
@return  cRetorno	, Caractere, Código da Administradora Financeira
@author  Alberto Deviciente
@version P12
@since   14/09/2026   
/*/
//--------------------------------------------------------
Static Function LjGetAdmFI(oDadosCompl, cFormaPg)

Local cRetorno  := ""
Local oQueryQry	:= Nil
Local cQry		:= ""
Local nSeq		:= 1
Local cAliasQry := ""

//Só pega a administradora pelo TEF quando o codigoRede vier preenchido
If oDadosCompl:HasProperty("vendaPagamentoTefs") .And. Len(oDadosCompl["vendaPagamentoTefs"]) > 0 .And.;
	!Empty(oDadosCompl["vendaPagamentoTefs"][1]["codigoRede"]) .And. !( AllTrim(oDadosCompl["vendaPagamentoTefs"][1]["codigoRede"]) == "0" )

	cQry    := " SELECT AE_COD ,AE_DESC"
	cQry    += " FROM " + RetSqlName("SAE") + " AE INNER JOIN " + RetSqlName("MDE") + " MDE_1 ON"
	cQry    += " MDE_1.MDE_FILIAL = ? "
	cQry    += " AND MDE_1.MDE_CODIGO = AE_ADMCART"
	cQry    += " AND MDE_1.MDE_TIPO = ? "
	cQry    += " AND MDE_1.MDE_CODSIT = ? "
	cQry    += " AND MDE_1.D_E_L_E_T_ = ' '"
	cQry    += " INNER JOIN " + RetSqlName("MDE") + " MDE_2 ON"
	cQry    += " MDE_2.MDE_FILIAL = ? "
	cQry    += " AND MDE_2.MDE_CODIGO = AE_REDEAUT"
	cQry    += " AND MDE_2.MDE_TIPO = 'RD'"
	cQry    += " AND MDE_2.MDE_CODSIT = ? "
	cQry    += " AND MDE_2.D_E_L_E_T_ = ' '"
	cQry    += " WHERE AE_FILIAL = ? " 
	cQry    += " AND AE.D_E_L_E_T_ = ? "

	cQry 	:= ChangeQuery(cQry)
	oQueryQry := FwExecStatement():New(cQry)
    oQueryQry:SetString(nSeq++,		xFilial("MDE"))
	oQueryQry:SetString(nSeq++,		cFormaPg)
	oQueryQry:SetString(nSeq++,		oDadosCompl["vendaPagamentoTefs"][1]["bandeira"])
    oQueryQry:SetString(nSeq++,		xFilial("MDE"))
	oQueryQry:SetString(nSeq++,		oDadosCompl["vendaPagamentoTefs"][1]["codigoRede"])
    oQueryQry:SetString(nSeq++,		xFilial("SAE"))
	oQueryQry:SetString(nSeq++,		Space(1))
	
	cAliasQry := oQueryQry:OpenAlias(GetNextAlias())

	If (cAliasQry)->( !EOF() )
        cRetorno:= (cAliasQry)->AE_COD
	EndIf

	(cAliasQry)->(dbCloseArea())
    oQueryQry:Destroy()
    oQueryQry := Nil

EndIf

If Empty(cRetorno)
	cRetorno := LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', oDadosCompl['pagamentoForma']['idRetaguarda'], 'operadora')    
EndIf

If Empty(cRetorno)
	cMsgErroRT := STR0005 + "(" + cQry + ")" //"Administradora Financeira não localizada! Por favor, verifique as tabelas SAE e MDE do Protheus e certifique-se que nos dados de pagamento, ao menos uma das seguintes tags estão preenchidas : 'vendaPagamentoTefs','pagamentoOperadora' ou 'pagamentoCondicao'. "
EndIf

Return cRetorno
