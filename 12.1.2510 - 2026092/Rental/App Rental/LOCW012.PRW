#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} UltProjBem 
ITUP BUSINESS - TOTVS RENTAL
Retorna com o último projeto do Bem
Cod Review 30/09/2025 - Dennis Calabres
O objetivo desta API é:
Retornar onde está o movimento, no caso do bem não estar disponível.
Se ele estiver disponível retornar a AS em branco
/*/
WSRESTFUL UltProjBem DESCRIPTION "Metodo retorna o ultimo projeto e cliente do bem"

	WSMETHOD POST DESCRIPTION "<h2>Metodo retorna o ultimo projeto e cliente do bem.</h2>" WSSYNTAX "/UltProjBem"

END WSRESTFUL

/*/{PROTHEUS.DOC} UltProjBem 
ITUP BUSINESS - TOTVS RENTAL
Retorna com o último projeto do Bem
Cod Review 30/09/2025 - Frank Z Fuga
/*/
WSMETHOD POST WSSERVICE UltProjBem 
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local cDados	    := ""
Local cRet			:= ""
Local cFilContrato  := ""
Local cProjeto      := ""
Local cObra         := ""
Local cNrAS         := ""
Local cCentroCusto  := ""
Local cNrProposta   := ""
Local cCodCliente   := ""
Local cLojaCliente  := ""
Local cNomeCliente  := ""
Local cEmailCliente := ""
Local cStatusBem    := ""
Local aUltProjBem   := {}
Local lReserva      := .F.
Local cContador     := ""
Local cTemCont      := ""
Local cTpMes        := ""
Local cCliOri       := ""
Local cLojOri       := ""
Local cNomOri       := ""
Local cTemVis       := ""
Local dDtVis        := ctod("")
Local cHrVis        := ""
Local cNomRes       := ""
Local cResPon       := ""
Local cCcgOri       := ""
Local cInsOri       := ""
Local cCeiOri       := ""
Local cBaiOri       := ""
Local cMunOri       := ""
Local cEndOri       := ""
Local cEstOri       := ""
Local cCepOri       := ""
Local cConOri       := ""
Local cRg           := ""
Local cDepOri       := ""
Local cEmaOri       := ""
Local cDddOri       := ""
Local cTelOri       := ""
Local cRamal        := ""
Local cCelula       := ""
Local dProxMan      := Ctod("")
Local cContGar      := ""
Local cDataGar      := ""

Private oJson		:= Nil

	::SetContentType("application/json; charset=iso-8859-1")
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
        //   aEmp :={ "" ,"",  "Empresa já existente." }//  xVerEmp(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
		//	If (aEmp[3] == "Empresa já existente.")
                cRet := "" // xAbreEnv2(aEmp[1],aEmp[2])
                If Empty(cRet)
                    ST9->(DbSetOrder(1))
                    If ST9->(DbSeek(xFilial("ST9")+Alltrim(oJson:cCodBem)))

                        cStatusBem := ST9->T9_STATUS
                        cContGar   := Alltrim(Str(ST9->T9_CONTGAR))
                        cDataGar   := Dtoc(ST9->T9_DTGARAN)
                        aUltProjBem := LOCW012A(oJson:cCodBem,cStatusBem,IIf(Type("oJson:CodForm") == "C",oJson:CodForm,NIL))
                        dProxMan   := Locw012C( oJson:cCodBem )

                        cRet            := aUltProjBem[1]
                        cFilContrato    := aUltProjBem[2]
                        cProjeto        := aUltProjBem[3]
                        cObra           := aUltProjBem[4]
                        cNrAS           := aUltProjBem[5]
                        cCentroCusto    := aUltProjBem[6]
                        cNrProposta     := aUltProjBem[7]
                        cCodCliente     := aUltProjBem[8]
                        cLojaCliente    := aUltProjBem[9]
                        cNomeCliente    := aUltProjBem[10]
                        cEmailCliente   := aUltProjBem[11]
                        lReserva        := aUltProjBem[12]
                        cContador       := aUltProjBem[13]
                        cTemCont        := aUltProjBem[14]
                        cTpMes          := aUltProjBem[15]
                        cCliOri         := aUltProjBem[16]
                        cLojOri         := aUltProjBem[17]
                        cNomOri         := aUltProjBem[18]
                        cTemVis         := aUltProjBem[19]
                        dDtVis          := aUltProjBem[20]
                        cHrVis          := aUltProjBem[21]
                        cNomRes         := aUltProjBem[22]
                        cResPon         := aUltProjBem[23]
                        cCcgOri         := aUltProjBem[24]
                        cInsOri         := aUltProjBem[25]
                        cCeiOri         := aUltProjBem[26]
                        cBaiOri         := aUltProjBem[27]
                        cMunOri         := aUltProjBem[28]
                        cEndOri         := aUltProjBem[29]
                        cEstOri         := aUltProjBem[30]
                        cCepOri         := aUltProjBem[31]
                        cConOri         := aUltProjBem[32]
                        cRg             := aUltProjBem[33]
                        cDepOri         := aUltProjBem[34]
                        cEmaOri         := aUltProjBem[35]
                        cDddOri         := aUltProjBem[36]
                        cTelOri         := aUltProjBem[37]
                        cRamal          := aUltProjBem[38]
                        cCelula         := aUltProjBem[39]
                        cRegiao         := aUltProjBem[40]

                        If Empty(cRet)
                            cDados := ', "Dados": {'
                            cDados += ' "Filial": "'+cFilContrato+'",'
                            cDados += ' "Projeto": "'+cProjeto+'",'
                            cDados += ' "Obra": "'+cObra+'",'
                            cDados += ' "NrAS": "'+cNrAS+'",'
                            cDados += ' "CentroCusto": "'+cCentroCusto+'",'
                            cDados += ' "NrProposta": "'+cNrProposta+'",'
                            cDados += ' "CodCliente": "'+cCodCliente+'",'
                            cDados += ' "LojaCliente": "'+cLojaCliente+'",'
                            cDados += ' "NomeCliente": "'+cNomeCliente+'",'
                            cDados += ' "EmailCliente": "'+cEmailCliente+'",'
                            cDados += ' "StatusBem": "'+cStatusBem+'",'
                            cDados += ' "Contador": "'+cContador+'",'
                            cDados += ' "TemContador": "'+cTemCont+'",'
                            cDados += ' "Reserva": '+Iif(lReserva,"true","false")+', '
                            cDados += ' "TipoMes": "'+if(cTpMes=="0","Mes fechado",if(cTpMes=="1","Dias corridos","Valor fixo"))+'", '
                            cDados += ' "ClienteObra": "'+cCliOri+'",'
                            cDados += ' "LojaObra": "'+cLojOri+'",'
                            cDados += ' "NomeObra": "'+cNomOri+'",'
                            cDados += ' "TemVistoria": "'+cTemVis+'",'
                            cDados += ' "DatVistoria": "'+dDtVis+'",'
                            cDados += ' "HorVistoria": "'+cHrVis+'",'
                            cDados += ' "NomeResponsa": "'+cNomRes+'",'
                            cDados += ' "EmailReponsa": "'+cResPon+'",'
                            cDados += ' "CNPJ": "'+cCcgOri+'",'
                            cDados += ' "InsEstadual": "'+cInsOri+'",'
                            cDados += ' "CEI": "'+cCeiOri+'",'
                            cDados += ' "Bairro": "'+cBaiOri+'",'
                            cDados += ' "Cidade": "'+cMunOri+'",'
                            cDados += ' "Endereco": "'+cEndOri+'",'
                            cDados += ' "Estado": "'+cEstOri+'",'
                            cDados += ' "CEP": "'+cCepOri+'",'
                            cDados += ' "Contato": "'+cConOri+'",'
                            cDados += ' "RG": "'+cRg+'",'
                            cDados += ' "Departamento": "'+cDepOri+'",'
                            cDados += ' "Email": "'+cEmaOri+'",'
                            cDados += ' "DDD": "'+cDddOri+'",'
                            cDados += ' "Telefone": "'+cTelOri+'",'
                            cDados += ' "Ramal": "'+cRamal+'",'
                            cDados += ' "maxstringsize ": "'+LOCW012B()+'",' 
                            cDados += ' "Celular": "'+cCelula+'",'
                            cDados += ' "SitBem": "'+ST9->T9_SITBEM+'",'
                            cDados += ' "ProxManut": "'+ Dtoc(dProxMan)+'" ,'
                            cDados += ' "Regiao": "'+ cRegiao+'" ,'
                            cDados += ' "ContadorGarantia" : "'+cContGar+'", '
                            cDados += ' "DataGarantia" : "'+cDataGar+'", '
                            cDados += ' "DataSolRetira" : "'+ Dtoc(FPA->FPA_DTSCRT)+'", '
                            cDados += ' "SerieRemessa" : "'+FPA->FPA_SERREM+'", '
                            cDados += ' "NotaFiscalRemessa" : "'+FPA->FPA_NFREM+'",'
                            cDados += ' "DataRemessa" : "'+Dtoc(FPA->FPA_DNFREM)+'"'
                            cDados += '}'
                        EndIf
                    Else
                        cRet := "ERRO-Bem não encontrado."
                    EndIf
                EndIf
            //endif

		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"'+cDados+'}')) )
	
Return .T.

/*/{PROTHEUS.DOC} LOCW012A 
ITUP BUSINESS - TOTVS RENTAL
Função que busca o ultimo projeto que o bem está alocado
Cod Review 30/09/2025 - Frank Z Fuga
xUltProjBem - era o nome antigo desta função
/*/
Function LOCW012A(cCodBem,cStatusBem,cCodForm)
Local cRet          := ""
Local cQuery        := ""
Local cFilContrato  := ""
Local cProjeto      := ""
Local cObra         := ""
Local cNrAS         := ""
Local cCentroCusto  := ""
Local cNrProposta   := ""
Local cCodCliente   := ""
Local cLojaCliente  := ""
Local cNomeCliente  := ""
Local cEmailCliente := ""
Local lReserva      := .F.
Local cStatOld      := ""
Local cContador     := ""
Local cTemCont      := ""
Local cTpMes        := ""
Local cCliOri       := ""
Local cLojOri       := ""
Local cNomOri       := ""
Local cTemVis       := ""
Local dDtVis        := ctod("")
Local cHrVis        := ""
Local cNomRes       := ""
Local cResPon       := ""
Local cCcgOri       := ""
Local cInsOri       := ""
Local cCeiOri       := ""
Local cBaiOri       := ""
Local cMunOri       := ""
Local cEndOri       := ""
Local cEstOri       := ""
Local cCepOri       := ""
Local cConOri       := ""
Local cRg           := ""
Local cDepOri       := ""
Local cEmaOri       := ""
Local cDddOri       := ""
Local cTelOri       := ""
Local cRamal        := ""
Local cCelula       := ""
Local cProjPesq     := ""
Local cRegiao       := ""

Default cCodForm    := NIL

    cContador := AllTrim(Str(ST9->T9_POSCONT))
    cTemCont  := Alltrim(ST9->T9_TEMCONT)

    LOCACLOSE("TRBTQY")
    
    cQuery := " SELECT FQD_STATQY, FQD_STAREN "
    cQuery += " FROM " + RETSQLNAME("FQD") + " FQD "
    cQuery += " WHERE FQD_STATQY = ? AND FQD.D_E_L_E_T_ = ''"
    cQuery := CHANGEQUERY(cQuery)
    aBindParam := {cStatusBem}
    MPSysOpenQuery(cQuery,"TRBTQY",,,aBindParam)
    If TRBTQY->(EOF())
        cRet := "ERRO-Status do bem não localizado na tabela relacional FQD."
    Else
        cStatusBem := TRBTQY->FQD_STATQY
        cStatOld   := TRBTQY->FQD_STAREN
    EndIf

    TRBTQY->(dbCloseArea())

    If empty(cRet)

        // Se o Bem estiver como disponível retornar tudo em branco
        If cStatusBem == "00" .or. cStatusBem == "  "
            // O bem estará como livre para uso.
        Else
            // Em qualquer outo status vamos verificar se o último movimento é da FPA, ou da FPF
            // e retornaremos a AS correspondente.

            LOCACLOSE("TRBFQ4")

            cQuery := "SELECT FQ4_FILIAL, FQ4_PROJET, FQ4_AS, FQ4_LOG, FQ4_OBRA"
            cQuery += "FROM "+RetSqlName("FQ4")+" FQ4 "
            cQuery += "WHERE "
            cQuery += "FQ4_FILIAL = '"+xFilial("FQ4")+"' "
            cQuery += "AND FQ4.D_E_L_E_T_ = ' ' "
            cQuery += "AND FQ4_CODBEM = ? "
            cQuery += "ORDER BY FQ4.R_E_C_N_O_ DESC "
            cQuery := CHANGEQUERY(cQuery)
            aBindParam := {Alltrim(cCodBem)}
            MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)   
            
            If !TRBFQ4->(EoF())

                FPA->(dbSetOrder(3))
                FPA->(dbSeek(xFilial("FPA")+TRBFQ4->FQ4_AS))
                FP0->(dbSetOrder(1))
                FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))

                cFilContrato    := xFilial("FQ4")
                cProjeto        := Alltrim(TRBFQ4->FQ4_PROJET)
                cProjPesq       := TRBFQ4->FQ4_PROJET
                cObra           := Alltrim(TRBFQ4->FQ4_OBRA)
                cNrAS           := Alltrim(TRBFQ4->FQ4_AS)
                cCentroCusto    := Alltrim(FPA->FPA_CUSTO)
                cNrProposta     := Alltrim(FP0->FP0_PROJET)
                cCodCliente     := Alltrim(FP0->FP0_CLI)
                cLojaCliente    := Alltrim(FP0->FP0_LOJA)
                cNomeCliente    := Alltrim(FP0->FP0_CLINOM)
                cEmailCliente   := Lower(Alltrim(FP0->FP0_CLIEMA))

                lReserva := .F.
                If !empty(cCodBem) .and. !empty(cProjeto) .and. !empty(cNrAs)
                
                    LOCACLOSE("TRBZ03")

                    cQuery := "SELECT FQF_FILIAL, FQF_PROJET, FQF_AS FROM "+RetSqlName("FQF")+" FQF "
                    cQuery += "WHERE FQF.D_E_L_E_T_ = ' ' "
                    cQuery += "AND FQF_CODBEM = ? "
                    cQuery += "AND FQF_PROJET = ? "
                    cQuery += "AND FQF_AS = ? "
                    cQuery += "ORDER BY FQF.R_E_C_N_O_ DESC"
                    cQuery := CHANGEQUERY(cQuery)
                    aBindParam := {Alltrim(cCodBem), cProjeto, cNrAS}
                    MPSysOpenQuery(cQuery,"TRBZ03",,,aBindParam)

                    If !TRBZ03->(EoF())
                        lReserva := .T.
                    EndIf

                    LOCACLOSE("TRBZ03")

                EndIf

            EndIF
        EndIf

        // Buscar as informações da FP1.

        If !empty(cProjeto) .and. !empty(cObra)
            FP1->(dbSetOrder(1))
            If FP1->(dbSeek(xFilial("FP1")+cProjPesq+cObra))
                cTpMes  := FP1->FP1_TPMES
                cCliOri := FP1->FP1_CLIORI
                cLojOri := FP1->FP1_LOJORI
                cNomOri := FP1->FP1_NOMORI
                cTemVis := FP1->FP1_TEMVIS
                dDtVis  := FP1->FP1_DTVIS
                cHrVis  := FP1->FP1_HRVIS
                cNomRes := FP1->FP1_NOMRES
                cResPon := FP1->FP1_RESPON
                cCcgOri := FP1->FP1_CGCORI
                cInsOri := FP1->FP1_INSORI
                cCeiOri := FP1->FP1_CEIORI
                cBaiOri := FP1->FP1_BAIORI
                cMunOri := FP1->FP1_MUNORI
                cEndOri := FP1->FP1_ENDORI
                cEstOri := FP1->FP1_ESTORI
                cCepOri := FP1->FP1_CEPORI
                cConOri := FP1->FP1_CONORI
                cRg     := FP1->FP1_RG
                cDepOri := FP1->FP1_DEPORI
                cEmaOri := FP1->FP1_EMAORI
                cDddOri := FP1->FP1_DDDORI
                cTelOri := FP1->FP1_TELORI
                cRamal  := FP1->FP1_RAMAL
                cCelula := FP1->FP1_CELULA
                if FP1->(FIELDPOS("FP1_REGIAO"))
                    cRegiao := FP1->FP1_REGIAO
                else 
                    cRegiao := ''
                endif
            EndIf
        EndIf

    EndIf

Return ({cRet,;
    PadR(cFilContrato,TamSx3("FPA_FILIAL")[1]),;
    PadR(cProjeto,TamSx3("FPA_PROJET")[1]),;
    PadR(cObra,TamSx3("FPA_OBRA")[1]),;
    PadR(cNrAS,TamSx3("FPA_AS")[1]),;
    PadR(cCentroCusto,TamSx3("FPA_CUSTO")[1]),;
    PadR(cNrProposta,TamSx3("FP0_PROJET")[1]),;
    PadR(cCodCliente,TamSx3("FP0_CLI")[1]),;
    PadR(cLojaCliente,TamSx3("FP0_LOJA")[1]),;
    PadR(cNomeCliente,TamSx3("FP0_CLINOM")[1]),;
    PadR(cEmailCliente,TamSx3("FP0_CLIEMA")[1]),;
    lReserva,;
    PadR(cContador,TamSx3("T9_POSCONT")[1]),;
    PadR(cTemCont,TamSx3("T9_TEMCONT")[1]),;
    PadR(cTpMes,TamSx3("FP1_TPMES")[1]),;
    PadR(cCliOri,TamSx3("FP1_CLIORI")[1]),;
    PadR(cLojOri,TamSx3("FP1_LOJORI")[1]),;
    PadR(cNomOri,TamSx3("FP1_NOMORI")[1]),;
    PadR(cTemVis,TamSx3("FP1_TEMVIS")[1]),;
    PadR(dDtVis,TamSx3("FP1_DTVIS")[1]),;
    PadR(cHrVis,TamSx3("FP1_HRVIS")[1]),;
    PadR(cNomRes,TamSx3("FP1_NOMRES")[1]),;
    PadR(cResPon,TamSx3("FP1_RESPON")[1]),;
    PadR(cCcgOri,TamSx3("FP1_CGCORI")[1]),;
    PadR(cInsOri,TamSx3("FP1_INSORI")[1]),;
    PadR(cCeiOri,TamSx3("FP1_CEIORI")[1]),;
    PadR(cBaiOri,TamSx3("FP1_BAIORI")[1]),;
    PadR(cMunOri,TamSx3("FP1_MUNORI")[1]),;
    PadR(cEndOri,TamSx3("FP1_ENDORI")[1]),;
    PadR(cEstOri,TamSx3("FP1_ESTORI")[1]),;
    PadR(cCepOri,TamSx3("FP1_CEPORI")[1]),;
    PadR(cConOri,TamSx3("FP1_CONORI")[1]),;
    PadR(cRg,TamSx3("FP1_RG")[1]),;
    PadR(cDepOri,TamSx3("FP1_DEPORI")[1]),;
    PadR(cEmaOri,TamSx3("FP1_EMAORI")[1]),;
    PadR(cDddOri,TamSx3("FP1_DDDORI")[1]),;
    PadR(cTelOri,TamSx3("FP1_TELORI")[1]),;
    PadR(cRamal,TamSx3("FP1_RAMAL")[1]),;
    PadR(cCelula,TamSx3("FP1_CELULA")[1]),;
    If( Empty( cRegiao), cRegiao, Padr( cRegiao ,TamSx3("FP1_REGIAO")[1] ));
})
 
 /*/{PROTHEUS.DOC} LOCW012B
ITUP BUSINESS - TOTVS RENTAL
Busca MaxStringSize na Seção GENERAL no appserver.ini
Dennis Calabrez
21/11/2025
/*/
Function LOCW012B()
Local nMaxSize := 0
    
    // Lê o valor do MaxStringSize do INI
    nMaxSize := Val(GetPvProfString("GENERAL", "MaxStringSize", "0", GetAdv97()))
    
Return(cValToChar(nMaxSize))

/*/{Protheus.doc} LOCW012C
Retorna a data do proximo atendimento
@type function
@version 25.10
@author Alexandre Circenis
@since 01/06/2026
@param cBem, character, Codigo do bem 
@return variant, Data da proxima manutenção 
/*/
Function LOCW012C(cBem)
Local dProxMan := Ctod("//")
Local dAux     := Ctod("//")
Local aArea    := GetArea()
Local aAreaSTF := STF->(GetArea())

    DbSelectArea("STF")
    dbSetOrder(1)
 	if Dbseek(xFilial("STF")+cBem)

    	While !STF->(Eof()) .And. STF->TF_FILIAL = (xFilial("STF")) .and. STF->TF_CODBEM = cBem

	    	If STF->TF_ATIVO <> "N" .And. STF->TF_PERIODO <> "E"
		    	If stf->tf_tipacom <> "S"

			    	dAux := NGXPROXMAN(cBem)

	    			If Empty(dProxMan) .Or. dProxMan > dAux
		    			dProxMan := dAux
		    		Endif
			    Else
				
                 If NGIFDBSEEK('TPE',cVCODB,1)
				    	dAux := NGPROXMAN(tpe->tpe_dtulta,STF->TF_TIPACOM,;
				    	STF->TF_TEENMAN,STF->TF_UNENMAN,;
				    	STF->TF_CONMANU,STF->TF_INENMAN,;
					    tpe->tpe_contac,tpe->tpe_vardia)

					    If Empty(dProxMan) .Or. dAux < dProxMan
						    dProxMan := dAux
				    	Endif
				    Endif
			    Endif
	    	EndIf
		    STF->(dbSkip())
    	End
    else
        dProxMan := NGXPROXMAN(cBem) 
    endif
    RestArea(aAreaStf)
    RestArea(aArea)

return dProxMan
