#include "TOTVS.CH"
#include "PLSMGER.CH"

#define __aCdCri187 {"573","Demanda por requerimento"}

Class AutExecucao from AutAbstrata

	Data aTabDup
	Data aProcedimentos
	Data aNegativas
    Data aPartic
	Data cNumGuia

	Method New(hMap) Constructor

	Method getRegAns()
	Method getGuiPrest()
	Method getVerTiss()
	Method getNumGuiPri()
	Method getNumGuiOpe()
    Method getDtAut()
    Method getSenha()
    Method getValSenha()

	Method getNumCarteira()
	Method getAtendRN()
	Method getNumCNS()
    Method getNomeBenef()

    Method rdaSolCod()
    Method rdaSolLoc()
    Method rdaSolCgc()
    Method rdaSolNome()

    Method prfSolNome()
    Method prfSolSigla()
    Method prfSolNumero()
    Method prfSolUf()
    Method prfSolCbos()
    Method getEspSol()

    Method getDtSolic()
    Method getCarAtend()
    Method getIndCli()

    Method rdaExeCod()
    Method rdaExeLoc()
    Method rdaExeCgc()
    Method rdaExeNome()
    Method rdaExeCnes()
    Method codPrestOpe()
    Method getLocalPrest()

    Method getTpAtend()
    Method getIndAcid()
    Method getTpCons()
    Method getMotEnc()

    Method getObsJust()

	Method getTotProc()
	Method getTotDiar()
	Method getTotTxAlug()
	Method getTotMat()
	Method getTotMed()
	Method getTotOPME()
	Method getTotGasMed()
	Method getTotGeral()

    Method getProcedimentos()
    Method getNegativas()
    Method getPartic()
    Method statusByProc()

    Method getNumGuia()
    Method setNumGuia()
    Method insert()
    Method grvAuditoria()

EndClass

Method New(HMap) Class AutExecucao
	self:hMap := HMap
	self:aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
Return self

Method getRegAns() Class AutExecucao
Return self:get("guiaSP-SADT.cabecalhoGuia.registroANS")

Method getGuiPrest() Class AutExecucao
Return self:get("guiaSP-SADT.cabecalhoGuia.numeroGuiaPrestador")

Method getVerTiss() Class AutExecucao
Return self:get("guiaSP-SADT.cabecalhoGuia.versaoTiss")

Method getNumGuiPri() Class AutExecucao
Return self:get("guiaSP-SADT.cabecalhoGuia.numeroGuiaPrincipal")

Method getNumGuiOpe() Class AutExecucao
Return self:get("guiaSP-SADT.dadosAutorizacao.numeroGuiaOperadora")

Method getDtAut() Class AutExecucao
Return self:get("guiaSP-SADT.dadosAutorizacao.dataAutorizacao")

Method getSenha() Class AutExecucao
Return self:get("guiaSP-SADT.dadosAutorizacao.senha")

Method getValSenha() Class AutExecucao
Return self:get("guiaSP-SADT.dadosAutorizacao.dataValidadeSenha")

Method getNumCarteira() Class AutExecucao
Return self:get("guiaSP-SADT.dadosBeneficiario.numeroCarteira")

Method getAtendRN() Class AutExecucao
	Local cAtendRN := self:get("guiaSP-SADT.dadosBeneficiario.atendimentoRN")
Return iif(cAtendRN == "S", "1", "0")

Method getNumCNS() Class AutExecucao
Return self:get("guiaSP-SADT.dadosBeneficiario.numeroCNS")

Method getNomeBenef() Class AutExecucao
Return self:get("guiaSP-SADT.dadosBeneficiario.nomeBeneficiario")

Method rdaSolCod() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitante.contratadoSolicitante.codigoContratado")

Method rdaSolLoc() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitante.contratadoSolicitante.dadosLocal.local")

Method rdaSolCgc() Class AutExecucao
    
    Local cCpfCnpj := self:get("guiaSP-SADT.dadosSolicitante.contratadoSolicitante.cpfContratado")
	if empty(cCpfCnpj)
		cCpfCnpj := self:get("guiaSP-SADT.dadosSolicitante.contratadoSolicitante.cnpjContratado")
	endIf

	cCpfCnpj := StrTran(StrTran(StrTran(cCpfCnpj, ".", ""), "-", ""), "/", "")

Return cCpfCnpj

Method rdaSolNome() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitante.contratadoSolicitante.nomeContratado")

Method prfSolNome() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitante.profissionalSolicitante.nomeProfissional")

Method prfSolSigla() Class AutExecucao
    local cConsPrf := self:get("guiaSP-SADT.dadosSolicitante.profissionalSolicitante.conselhoProfissional")
Return alltrim(PLSVARVINC('26', nil, cConsPrf))

Method prfSolNumero() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitante.profissionalSolicitante.numeroConselhoProfissional")

Method prfSolUf() Class AutExecucao
	Local cUfProf := self:get("guiaSP-SADT.dadosSolicitante.profissionalSolicitante.UF")
Return alltrim(PLSVARVINC('59', nil, cUfProf))

Method prfSolCbos() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitante.profissionalSolicitante.CBOS")

Method getEspSol() Class AutExecucao
	Local cCbos		:= self:prfSolCbos()
	Local cCodEsp	:= Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP')
Return cCodEsp

Method getDtSolic() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitacao.dataSolicitacao")

Method getCarAtend() Class AutExecucao
    Local cCarAtend := self:get("guiaSP-SADT.dadosSolicitacao.caraterAtendimento")
Return alltrim(PLSVARVINC('23', nil, cCarAtend))

Method getIndCli() Class AutExecucao
Return self:get("guiaSP-SADT.dadosSolicitacao.indicacaoClinica")

Method rdaExeCod() Class AutExecucao
Return self:get("guiaSP-SADT.dadosExecutante.contratadoExecutante.codigoContratado")

Method rdaExeLoc() Class AutExecucao
Return self:get("guiaSP-SADT.dadosExecutante.contratadoExecutante.dadosLocal.local")

Method codPrestOpe() Class AutExecucao
	
	Local cCpfCnpj := self:rdaExeCgc()
	Local aArea   := getArea()
	Local cCodPrest := ""
	BAU->(dbSetOrder(4))
			
	if (BAU->(msSeek(xFilial("BAU")+cCpfCnpj)))

		cCodPrest := BAU->BAU_CODIGO

	endIf

	RestArea(aArea)

Return cCodPrest

Method getLocalPrest() Class AutExecucao
	
	Local cCodLoc := ""
	Local cLocal  := ""
	Local cCodPrest := self:codPrestOpe()
	Local aArea   := getArea()

	BAU->(dbSetOrder(1))
			
	if (BAU->(msSeek(xFilial("BAU")+cCodPrest)))

		BB8->(dbSetOrder(1))
		if (BB8->(msSeek(xFilial("BB8")+BAU->BAU_CODIGO)))
			cCodLoc := BB8->BB8_CODLOC
			cLocal  := BB8->BB8_LOCAL
		endIf

	endIf
		

	RestArea(aArea)

Return { cCodLoc, cLocal }

Method rdaExeCgc() Class AutExecucao
    
    Local cCpfCnpj := self:get("guiaSP-SADT.dadosExecutante.contratadoExecutante.cpfContratado")
	if empty(cCpfCnpj)
		cCpfCnpj := self:get("guiaSP-SADT.dadosExecutante.contratadoExecutante.cnpjContratado")
	endIf

	cCpfCnpj := StrTran(StrTran(StrTran(cCpfCnpj, ".", ""), "-", ""), "/", "")

Return cCpfCnpj

Method rdaExeNome() Class AutExecucao
Return self:get("guiaSP-SADT.dadosExecutante.contratadoExecutante.nomeContratado")

Method rdaExeCnes() Class AutExecucao
Return self:get("guiaSP-SADT.dadosExecutante.cnes")

Method getTpAtend() Class AutExecucao
    Local cTpAtend := self:get("guiaSP-SADT.dadosAtendimento.tipoAtendimento")
Return alltrim(PLSVARVINC('50', nil, cTpAtend))

Method getIndAcid() Class AutExecucao
    Local cIndAcid := self:get("guiaSP-SADT.dadosAtendimento.indicacaoAcidente")
Return alltrim(PLSVARVINC('36', nil, cIndAcid))

Method getTpCons() Class AutExecucao
    Local cTpCons := self:get("guiaSP-SADT.dadosAtendimento.tipoConsulta")
Return alltrim(PLSVARVINC('52', nil, cTpCons))

Method getMotEnc() Class AutExecucao
    Local cMotEnc := self:get("guiaSP-SADT.dadosAtendimento.motivoEncerramento")
Return alltrim(PLSVARVINC('39', nil, cMotEnc))

Method getObsJust() Class AutExecucao
Return self:get("guiaSP-SADT.observacao")

Method getTotProc() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorProcedimentos")

Method getTotDiar() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorDiarias")

Method getTotTxAlug() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorTaxasAlugueis")

Method getTotMat() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorMateriais")

Method getTotMed() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorMedicamentos")

Method getTotOPME() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorOPME")

Method getTotGasMed() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorGasesMedicinais")

Method getTotGeral() Class AutExecucao
Return self:get("guiaSP-SADT.valorTotal.valorTotalGeral")

Method getProcedimentos() Class AutExecucao
		
	Local nProc 			:= 0
	Local nNegativa			:= 0
	Local cCodTab			:= ""
	Local cCodProc			:= ""
	Local cCodTabDePara     := ""
	Local cCodProcDePara    := ""
	Local nQtdSol			:= 0
	Local nQtdAut           := 0
	Local cCodGlosa			:= ""
	Local cDesGlosa			:= ""
	Local cCodSystem		:= ""
	Local cKeyProc			:= "guiaSP-SADT.procedimentosExecutados"
	Local cKeyNegativas     := ""

    Local dDtExec := ctod("")
    Local cHorIni := ""
    Local cHorFim := ""
    Local cVia := ""
    Local cTecUti := ""
    Local nRedAcres := 1
    Local nVlrUni := 0
    Local nVlrTot := 0
    Local cGrauPart := ""
    Local cCodPrf := ""
    Local cCpfPrf := ""
    Local cNomePrf := ""
    Local cConsPrf := ""
    Local cNumConsPrf := ""
    Local cUfPrf := ""
    Local cCbosPrf := ""
    Local nPartic := 0
    Local cKeyPartic := ""

	if(ValType(self:aProcedimentos) <> "A")

		self:aProcedimentos := {}
		self:aNegativas := {}
        self:aPartic    := {}
	
		cCodTab  := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.procedimento.codigoTabela")
		cCodProc := self:get(cKeyProc + "["  + allTrim(str(nProc)) + "].procedimentoExecutado.procedimento.codigoProcedimento")

		while !empty (cCodTab + cCodProc)

			cCodTab  	:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.procedimento.codigoTabela")
			cCodProc 	:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.procedimento.codigoProcedimento")
            dDtExec     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.dataExecucao")
            cHorIni     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.horaInicial")
            cHorFim     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.horaFinal")
            nQtdSol     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.quantidadeSolicitada")
            nQtdAut     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.quantidadeAutorizada")
            cVia        := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.viaAcesso")
            cTecUti     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.tecnicaUtilizada")
            nRedAcres   := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.reducaoAcrescimo")
            nVlrUni     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.valorUnitario")
            nVlrTot     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.valorTotal")

			cCodTabDePara := AllTrim(PLSVARVINC('87','BR4',cCodTab))
			cCodProcDePara := AllTrim(PLSVARVINC(cCodTab,'BR8', cCodProc, cCodTabDePara+cCodProc,,self:aTabDup,@cCodTabDePara))

			if (!empty(cCodTab+cCodProc))
				
				aAdd(self:aProcedimentos, {cCodTabDePara,;
                                           cCodProcDePara,;
                                           nQtdSol,;
                                           nQtdAut,;
                                           dDtExec,;
                                           cHorIni,;
                                           cHorFim,;
                                           cVia,;
                                           cTecUti,;
                                           nRedAcres,;
                                           nVlrUni,;
                                           nVlrTot})		
				
				nNegativa := 0
				cKeyNegativas := cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.motivosNegativa"
				
				while !empty(self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoGlosa"))
					
					cCodGlosa := self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoGlosa")
					cDesGlosa := self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.descricaoGlosa")
					cCodSystem := self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoNoSistema")
					aAdd(self:aNegativas, {cCodTabDePara, cCodProcDePara, cCodGlosa, cDesGlosa, cCodSystem})
					nNegativa++
				
				enddo 

                nPartic := 0
				cKeyPartic := cKeyProc + "[" + allTrim(str(nProc)) + "].procedimentoExecutado.equipeSadt"
				
				while !empty(self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].numeroConselhoProfissional"))

                    cGrauPart   := self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].grauPart")
                    cCodPrf     := self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].codigoContratado")
                    cCpfPrf     := self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].cpfContratado")
                    cNomePrf    := self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].nomeProf")
                    cConsPrf    := alltrim(PLSVARVINC('26', nil, self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].conselho")))
                    cNumConsPrf := self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].numeroConselhoProfissional")
                    cUfPrf      := alltrim(PLSVARVINC('59', nil, self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].UF")))
                    cCbosPrf    := self:get(cKeyPartic+ "[" + allTrim(str(nPartic)) + "].CBOS") 
                    cCodEsp     := Posicione('BAQ', 6, xFilial('BAQ')+alltrim(cCbosPrf),'BAQ_CODESP')
					
					aAdd(self:aPartic, {cCodTabDePara,;
                                        cCodProcDePara,;
                                        cGrauPart,;
                                        cCodPrf,;
                                        cCpfPrf,;
                                        cNomePrf,;
                                        cConsPrf,;
                                        cNumConsPrf,;
                                        cUfPrf,;
                                        cCodEsp})
					nPartic++
				
				enddo 
			
			endIf
			
			nProc++
			
		enddo

	endIf

return self:aProcedimentos

Method getNegativas() Class AutExecucao
	if ValType(self:aNegativas) <> "A"
		self:aNegativas := {}
		// chama o getProcedimentos pois ele já preenche o aCriticas
		self:getProcedimentos()
	endIf
Return self:aNegativas

Method getPartic() Class AutExecucao
	if ValType(self:aPartic) <> "A"
		self:aPartic := {}
		// chama o getProcedimentos pois ele já preenche o aPartic
		self:getProcedimentos()
	endIf
Return self:aPartic

Method statusByProc() Class AutExecucao
		
	Local aProcedimentos := self:getProcedimentos()
	Local aNegativas := self:getNegativas()
	Local lAudito := aScan(aNegativas, { |x| x[3] == "025" }) > 0
	Local cStatus := ""
	Local nI := 1
	Local nAut := 0
	Local nNeg := 0

	if lAudito	
		cStatus := "6"
	elseif len(aNegativas) == 0
		cStatus := "1"
	else
		For nI := 1 to len(aProcedimentos)
			if aScan(aNegativas, { |x| x[1] == aProcedimentos[nI][1] .and. x[2] == aProcedimentos[nI][2] }) > 0
				nNeg++
			else
				nAut++
			endIf
		Next nI

		if nNeg == len(aProcedimentos)
			cStatus := "3"
		else
			cStatus := "2"
		endif
	endIf

Return cStatus

Method getNumGuia() Class AutExecucao
Return self:cNumGuia

Method setNumGuia(cNumGuia) Class AutExecucao
Return self:cNumGuia := cNumGuia

Method insert() Class AutExecucao

	Local aIndCli		:= PLBreakTxt(self:getIndCli(), {"BEA_INDCLI", "BEA_INDCL2"})
	Local aLocalPrest   := self:getLocalPrest()
	Local aProcedimentos := self:getProcedimentos()
	Local aNegativas    := self:getNegativas()
    Local aPartic       := self:getPartic()
	Local dDtAut		:= stod(self:getDtAut())
	Local aObs			:= PLBreakTxt(self:getObsJust(), {"BEA_MSG01", "BEA_MSG02"})
	Local cAnoAut       := alltrim(str(YEAR(dDtAut)))
	Local cMesAut       := STRZERO(val(alltrim(str(MONTH(dDtAut)))), 2, 0)
	Local cNumGuia      := ""
	Local cCodEsp       := self:getEspSol()
	Local cCodOpe       := PLSINTPAD()
	Local cOpeRDA       := cCodOpe
	Local cCodRDA		:= self:codPrestOpe()
	Local cMatricAux    := self:getNumCarteira()
	Local cOpeUsr       := substr(cMatricAux, 1,4)
	Local cCodEmp       := substr(cMatricAux, 5,4)
	Local cMatric       := substr(cMatricAux, 9,6)
	Local cTipReg       := substr(cMatricAux, 15,2)
	Local cDigito       := substr(cMatricAux, 17)
	Local cStatus       := self:statusByProc()
	Local lAudito       := cStatus == "6"
	Local lAudPro       := .F.
	Local cNumero       := ""
	Local cTipGuia		:= "02"
	Local lCritica      := .F.
    Local lPartic       := .F.
	Local lGravou       := .F.
	Local nAux          := 1
	Local nCritica      := 0
    Local nPartic       := 0
	Local nI 			:= 1
	Local nJ			:= 1

	Begin Transaction

		cCodLdp := PlsRetLdp(5)
		cCodPeg := PLSVRPEGOF(cCodOpe, cOpeRDA, cCodRDA,  cAnoAut, cMesAut,;
				   cTipGuia, "1", "1", "1", cCodLdp, "1","2", , dDtAut, dDataBase,1 ,1 ,0, .F.)[1]

		cNumGuia := PLNUMAUT(cCodOpe,cAnoAut, cMesAut)
		cNumero := ""// PLSA500NUM("BEA", cCodOpe, cCodLdp, cCodPeg)
		self:setNumGuia(cCodOpe+cAnoAut+cMesAut+cNumGuia)

		BEA->(RecLock("BEA",.T.))
																			
			BEA->BEA_FILIAL := xFilial("BEA")   
			BEA->BEA_STATUS := cStatus
			BEA->BEA_CANCEL := "0"
			BEA->BEA_AUDITO := iif(lAudito, "1", "0")
			BEA->BEA_TIPGUI := cTipGuia
			BEA->BEA_TIPO   := "2"
			BEA->BEA_TPGRV  := "2"
			BEA->BEA_ORIMOV := "6"				             
			BEA->BEA_GUIPRE := self:getGuiPrest()	// 2 - Numero da guia no prestador	
            BEA->BEA_GUIPRI := self:getNumGuiPri()  // 3 - Numero da guia principal
            BEA->BEA_DATPRO := stod(self:getDtAut()) // 4 - Data da autorização
                                                    // 5 - Senha
                                                    // 6 - Validade da senha					
			BEA->BEA_OPEMOV := cCodOpe              // 7 - Numero da guia na operadora           			              	
			BEA->BEA_ANOAUT := cAnoAut              //     .   
			BEA->BEA_MESAUT := cMesAut              //     .
			BEA->BEA_NUMAUT := cNumGuia             //     .
																			
			BEA->BEA_OPEPEG := cCodOpe
			BEA->BEA_CODLDP := cCodLdp
			BEA->BEA_DTDIGI := dDataBase
			BEA->BEA_HHDIGI := StrTran(Time(),":","")
			BEA->BEA_CODPEG := cCodPeg
			BEA->BEA_NUMGUI := cNumero

			BEA->BEA_OPEUSR := cOpeUsr		        // 8 - Numero carteira Benef								
			BEA->BEA_CODEMP := cCodEmp
			BEA->BEA_MATRIC := cMatric 
			BEA->BEA_TIPREG := cTipReg
			BEA->BEA_DIGITO := cDigito                   					
																		
			BEA->BEA_ATERNA := self:getAtendRN()    // 12 - Atendimento a RN			         

			BEA->BEA_NOMSOL := self:prfSolNome()  	// 15 a 20 - Dados do profissional solicitante		 		
			BEA->BEA_SIGLA  := self:prfSolSigla()           			
			BEA->BEA_REGSOL := self:prfSolNumero()         			
			BEA->BEA_ESTSOL := self:prfSolUf()              			
			BEA->BEA_ESPSOL := cCodEsp 		                    			
			BEA->BEA_CODESP := cCodEsp

            BEA->BEA_NOMEXE := self:prfSolNome()
            BEA->BEA_SIGEXE := self:prfSolSigla()
            BEA->BEA_REGEXE := self:prfSolNumero()
            BEA->BEA_ESTEXE := self:prfSolUf()
            BEA->BEA_ESPEXE := cCodEsp
            BEA->BEA_CODESP := cCodEsp	             			

			BEA->BEA_TIPADM := self:getCarAtend()  // 21 - Caráter de atendimento 				
			BEA->BEA_DATSOL := stod(self:getDtSolic())   // 22 - Data da solicitação
			BEA->BEA_INDCLI := aIndCli[1]          // 23 - Indicação clinica
			BEA->BEA_INDCL2 := aIndCli[2]          // .    									
			BEA->BEA_MSG01  := aObs[1]	           // 58 - Observação/Justificativa	
			BEA->BEA_MSG02  := aObs[2]

			BEA->BEA_OPERDA := cOpeRDA              // 29 a 31 Dados do contratado executante
			BEA->BEA_CODRDA := self:codPrestOpe()      				
			BEA->BEA_CODLOC := aLocalPrest[1]
			BEA->BEA_LOCAL  := aLocalPrest[2]	

            BEA->BEA_TIPATE := self:getTpAtend() // 32 - Tipo de atendimento
            BEA->BEA_INDACI := self:getIndAcid() // 33 - Indicação de acidente
            BEA->BEA_TIPCON := self:getTpCons()  // 34 - Tipo de consulta
            BEA->BEA_TIPSAI := self:getMotEnc()  // 35 - Motivo de encerramento

			BEA->BEA_LIBERA := "0"
		
		BEA->(MsUnLock())

		For nI := 1 to len(aProcedimentos)

			nCritica := aScan(aNegativas, { |x| x[1] == aProcedimentos[nI][1] .and. x[2] == aProcedimentos[nI][2] })
			nPartic := aScan(aPartic, { |x| x[1] == aProcedimentos[nI][1] .and. x[2] == aProcedimentos[nI][2] })
			lCritica := nCritica > 0
			lPartic := nPartic > 0
			lAudPro  := aScan(aNegativas, { |x| x[1] == aProcedimentos[nI][1] .and. x[2] == aProcedimentos[nI][2] .and. x[3] == "025" })

			BE2->(RecLock("BE2",.T.))

				BE2->BE2_FILIAL := xFilial("BE2")          
				BE2->BE2_STATUS := iif(lCritica, "0", "1")
				BE2->BE2_OPEMOV := cCodOpe
				BE2->BE2_ANOAUT := cAnoAut
				BE2->BE2_MESAUT := cMesAut
				BE2->BE2_NUMAUT := cNumGuia
				BE2->BE2_SEQUEN := StrZero(nI, 3)
				BE2->BE2_TIPGUI := cTipGuia
				BE2->BE2_TIPO   := "2"
				BE2->BE2_TPGRV  := "2"
				BE2->BE2_DATPRO := stod(aProcedimentos[nI][5])
				BE2->BE2_OPERDA	:= cOpeRDA
				BE2->BE2_CODRDA := self:codPrestOpe() 
				BE2->BE2_CODLOC := aLocalPrest[1]
				BE2->BE2_LOCAL  := aLocalPrest[2]
				BE2->BE2_CODESP := cCodEsp
				BE2->BE2_OPEUSR := cOpeUsr        
				BE2->BE2_CODEMP := cCodEmp            
				BE2->BE2_MATRIC := cMatric            
				BE2->BE2_TIPREG := cTipReg            
				BE2->BE2_DIGITO := cDigito            
				BE2->BE2_CODPAD := aProcedimentos[nI][1]           	// 20 TABELA DO PROCEDIMENTO       
				BE2->BE2_CODPRO := aProcedimentos[nI][2]  			// 21 CODIGO DO PROCEDIMENTO
				BE2->BE2_QTDSOL := aProcedimentos[nI][3]         
				BE2->BE2_QTDPRO := iif(lCritica, 0, aProcedimentos[nI][4])
				BE2->BE2_AUDITO := iif(lAudPro, '1', '0')
				BE2->BE2_CODLDP := cCodLdp
				BE2->BE2_CODPEG := cCodPeg
				BE2->BE2_NUMERO := cNumero                                                         
				BE2->BE2_LIBERA := "0" 
                BE2->BE2_HORPRO := aProcedimentos[nI][6]
                BE2->BE2_HORFIM := aProcedimentos[nI][7]
                BE2->BE2_VIA := aProcedimentos[nI][8]
                BE2->BE2_TECUTI := aProcedimentos[nI][9]
                BE2->BE2_PRPRRL := aProcedimentos[nI][10]
                BE2->BE2_VLRAPR := aProcedimentos[nI][11]

			BE2->(MsUnLock())

			if lCritica
				
				BCT->(dbSetOrder(1))
				nJ := nCritica
				nAux := 1
				
				while nJ <= Len(aNegativas) .and.;
						aNegativas[nJ][1] == aProcedimentos[nI][1] .and.;
						aNegativas[nJ][2] == aProcedimentos[nI][2]
					
					BCT->(dbGoTop())
					
					if BCT->(msSeek(xFilial('BCT')+cCodOpe+aNegativas[nJ][5]))
						
						BEG->(RecLock("BEG",.T.))

							BEG->BEG_FILIAL := xFilial("BEG")
							BEG->BEG_OPEMOV := cCodOpe
							BEG->BEG_ANOAUT := cAnoAut
							BEG->BEG_MESAUT := cMesAut
							BEG->BEG_NUMAUT := cNumGuia
							BEG->BEG_SEQUEN := StrZero(nI, 3)
							BEG->BEG_CODGLO := aNegativas[nJ][5]
							BEG->BEG_DESGLO := BCT->BCT_DESCRI
							BEG->BEG_INFGLO := ""
							BEG->BEG_SEQCRI := StrZero(nAux, Len(BEG->BEG_SEQCRI))
							BEG->BEG_TIPO   := BCT->BCT_TIPO

						BEG->(MsUnLock())

						BEG->(RecLock("BEG",.T.))

							BEG->BEG_FILIAL := xFilial("BEG")
							BEG->BEG_OPEMOV := cCodOpe
							BEG->BEG_ANOAUT := cAnoAut
							BEG->BEG_MESAUT := cMesAut
							BEG->BEG_NUMAUT := cNumGuia
							BEG->BEG_SEQUEN := StrZero(nI, 3)
							BEG->BEG_CODGLO := ""
							BEG->BEG_DESGLO := "Novo Autorizador"
							BEG->BEG_INFGLO := "Novo Autorizador"
							BEG->BEG_SEQCRI := StrZero(nAux++, Len(BEG->BEG_SEQCRI))
							BEG->BEG_TIPO   := BCT->BCT_TIPO

						BEG->(MsUnLock())

					endIf
					nJ++ 
					nAux++

				endDo

			endIf

            if lPartic
				
				B4B->(dbSetOrder(1))
				nJ := nPartic
				
				while nJ <= Len(aPartic) .and.;
                        aPartic[nJ][1] == aProcedimentos[nI][1] .and.;
						aPartic[nJ][2] == aProcedimentos[nI][2]
											
						B4B->(RecLock("B4B",.T.))

                            B4B->B4B_FILIAL := xFilial("BEG")
                            B4B->B4B_SEQUEN :=  StrZero(nI,3)
                            B4B->B4B_OPEMOV :=  cCodOpe
                            B4B->B4B_ANOAUT :=  cAnoAut
                            B4B->B4B_MESAUT :=  cMesAut
                            B4B->B4B_NUMAUT :=  cNumGuia
                            B4B->B4B_GRAUPA :=  aPartic[nJ][3]
                            B4B->B4B_CDPFPR :=  aPartic[nJ][4]
                            B4B->B4B_CGC    :=  aPartic[nJ][5]
                            B4B->B4B_SICONS :=  aPartic[nJ][7]
                            B4B->B4B_NUCONS :=  aPartic[nJ][8]
                            B4B->B4B_UFCONS :=  aPartic[nJ][9]
                            B4B->B4B_CODESP :=  aPartic[nJ][10]

						B4B->(MsUnLock())

					nJ++ 
				endDo

			endIf

		Next nI

		if lAudito

			self:grvAuditoria()

		endIf

	End Transaction

	lGravou := .T.

Return lGravou

Method grvAuditoria() Class AutExecucao

	Local o790C			:= nil
	Local aCabCri       := {}
	Local aColsITE      := {}
	Local aDadCri		:= {}
	Local aHeaderITE    := {}
	Local aVetBEG       := {}
	Local aVetITE       := {}

	BE2->(dbSetOrder(1))
	BEG->(dbSetOrder(1))

	Store Header "BE2" TO aHeaderITE For .T.
	Store COLS "BE2" TO aColsITE FROM aHeaderITE VETTRAB aVetITE While; 
	BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2")+self:cNumGuia

	Store Header "BEG" TO aCabCri For .T.
	Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aVetBEG While;
	BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT) == xFilial("BEG")+self:cNumGuia

	o790C := PLSA790C():New(.T.)
	o790C:SetAuditoria(.T.,.F.,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],"0","BEG",aColsITE,aHeaderITE,"BE2",.F., .F.)
	o790C:Destroy()


Return
//
