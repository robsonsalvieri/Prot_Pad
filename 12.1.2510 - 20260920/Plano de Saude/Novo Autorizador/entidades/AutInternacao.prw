#include "TOTVS.CH"
#include "PLSMGER.CH"

#define __aCdCri187 {"573","Demanda por requerimento"}

Class AutInternacao from AutAbstrata

	Data aTabDup
	Data aProcedimentos
	Data aNegativas
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
	Method getTipInt()
    Method getCarAtend()
    Method getRegInt()
    Method getIndCli()
	Method getQtdDay()
	Method getIndOpm()
	Method getIndQui()
	Method getDatSug()
	Method getcid()



    Method rdaExeCod()
    Method rdaExeLoc()
    Method rdaExeCgc()
    Method rdaExeNome()
    Method rdaExeCnes()
    Method codPrestOpe()
    Method getLocalPrest()

    // Method getTpAtend()
    // Method getIndAcid()
    // Method getTpCons()
    // Method getMotEnc()

    Method getObsJust()

	// Method getTotProc()
	// Method getTotDiar()
	// Method getTotTxAlug()
	// Method getTotMat()
	// Method getTotMed()
	// Method getTotOPME()
	// Method getTotGasMed()
	// Method getTotGeral()

    Method getProcedimentos()
    Method getNegativas()
    Method statusByProc()

    Method getNumGuia()
    Method setNumGuia()
    Method insert()
    Method grvAuditoria()

EndClass

Method New(HMap) Class AutInternacao
	self:hMap := HMap
	self:aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
Return self

Method getRegAns() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.registroANS")

Method getGuiPrest() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.numeroGuiaPrestador")

// Method getVerTiss() Class AutInternacao nao tem no json de internacao
// Return self:get("internacaoSolicitacaoGuia.versaoTiss")

// Method getNumGuiPri() Class AutInternacao // Nao tem no json de internacao
// Return self:get("internacaoSolicitacaoGuia.numeroGuiaPrincipal")

// Method getNumGuiOpe() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.dadosInternacao.numeroGuiaOperadora")

Method getDtAut() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dataSolicitacao")

// Method getSenha() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.dadosInternacao.senha")

// Method getValSenha() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.dadosInternacao.dataValidadeSenha")

Method getNumCarteira() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosBeneficiario.numeroCarteira")

Method getAtendRN() Class AutInternacao
	Local cAtendRN := self:get("internacaoSolicitacaoGuia.dadosBeneficiario.atendimentoRN")
Return iif(cAtendRN == "S", "1", "0")

Method getNumCNS() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosBeneficiario.numeroCNS")

Method getNomeBenef() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosBeneficiario.nomeBeneficiario")

// Method rdaSolCod() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosDoContratado.codigoContratado")

Method rdaSolCgc() Class AutInternacao
    
    Local cCpfCnpj := self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosDoContratado.cpfContratado")
	if empty(cCpfCnpj)
		cCpfCnpj := self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosDoContratado.cnpjContratado")
	endIf

	cCpfCnpj := StrTran(StrTran(StrTran(cCpfCnpj, ".", ""), "-", ""), "/", "")

Return cCpfCnpj

Method rdaSolNome() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosDoContratado.nomeContratado")

Method prfSolNome() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosProfissionalContratado.nomeProfissional")

Method prfSolSigla() Class AutInternacao
    local cConsPrf := self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosProfissionalContratado.conselhoProfissional")
Return alltrim(PLSVARVINC('26', nil, cConsPrf))

Method prfSolNumero() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosProfissionalContratado.numeroConselhoProfissional")

Method prfSolUf() Class AutInternacao
	Local cUfProf := self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosProfissionalContratado.UF")
Return alltrim(PLSVARVINC('59', nil, cUfProf))

Method prfSolCbos() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosProfissionalContratado.CBOS")

Method getEspSol() Class AutInternacao
	Local cCbos		:= self:prfSolCbos()
	//Local cCodEsp	:= Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP') Esta com erro no PLS Victor 
	//Return cCodEsp
	Return cCbos

Method getDtSolic() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dataSolicitacao")

Method getCarAtend() Class AutInternacao
    Local cCarAtend := self:get("internacaoSolicitacaoGuia.dadosInternacao.caraterAtendimento")
Return alltrim(PLSVARVINC('23', nil, cCarAtend)) // esta setando para 0 

Method getRegInt() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosInternacao.regimeInternacao")

Method getTipInt() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosInternacao.tipoInternacao")

Method getQtdDay() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosInternacao.qtDiariasSolicitadas")

Method getIndOpm() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosInternacao.indicaorOPME")

Method getIndQui() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosInternacao.indicadorQuimio")

Method getIndCli() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosInternacao.indicacaoClinica")

Method getDatSug() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosHospitalSolicitado.dataSugeridaInternacao")

Method getcid() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.hipotesesDiagnosticas.diagnosticoCID")


Method rdaExeCod() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosExecutante.contratadoExecutante.codigoContratado")

Method rdaExeLoc() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosExecutante.contratadoExecutante.dadosLocal.local")

Method codPrestOpe() Class AutInternacao
	
	Local cCpfCnpj := self:rdaExeCgc()
	Local aArea   := getArea()
	Local cCodPrest := ""
	BAU->(dbSetOrder(4))
			
	if (BAU->(msSeek(xFilial("BAU")+cCpfCnpj)))

		cCodPrest := BAU->BAU_CODIGO

	endIf

	RestArea(aArea)

Return cCodPrest

Method getLocalPrest() Class AutInternacao
	
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

Method rdaExeCgc() Class AutInternacao
    
    Local cCpfCnpj := self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosDoContratado.cpfContratado")
	if empty(cCpfCnpj)
		cCpfCnpj := self:get("internacaoSolicitacaoGuia.identificacaoSolicitante.dadosDoContratado.cnpjContratado")
	endIf

	cCpfCnpj := StrTran(StrTran(StrTran(cCpfCnpj, ".", ""), "-", ""), "/", "")

Return cCpfCnpj

Method rdaExeNome() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosExecutante.contratadoExecutante.nomeContratado")

Method rdaExeCnes() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.dadosExecutante.cnes")

// Method getTpAtend() Class AutInternacao
//     Local cTpAtend := self:get("internacaoSolicitacaoGuia.dadosAtendimento.tipoAtendimento")
// Return alltrim(PLSVARVINC('50', nil, cTpAtend))

// Method getIndAcid() Class AutInternacao
//     Local cIndAcid := self:get("internacaoSolicitacaoGuia.dadosAtendimento.indicacaoAcidente")
// Return alltrim(PLSVARVINC('36', nil, cIndAcid))

// Method getTpCons() Class AutInternacao
//     Local cTpCons := self:get("internacaoSolicitacaoGuia.dadosAtendimento.tipoConsulta")
// Return alltrim(PLSVARVINC('52', nil, cTpCons))

// Method getMotEnc() Class AutInternacao
//     Local cMotEnc := self:get("internacaoSolicitacaoGuia.dadosAtendimento.motivoEncerramento")
// Return alltrim(PLSVARVINC('39', nil, cMotEnc))

Method getObsJust() Class AutInternacao
Return self:get("internacaoSolicitacaoGuia.observacao")

// Method getTotProc() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorProcedimentos")

// Method getTotDiar() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorDiarias")

// Method getTotTxAlug() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorTaxasAlugueis")

// Method getTotMat() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorMateriais")

// Method getTotMed() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorMedicamentos")

// Method getTotOPME() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorOPME")

// Method getTotGasMed() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorGasesMedicinais")

// Method getTotGeral() Class AutInternacao
// Return self:get("internacaoSolicitacaoGuia.valorTotal.valorTotalGeral")

Method getProcedimentos() Class AutInternacao
		
	Local nProc 			:= 0
	Local nNegativa			:= 0
	Local cCodTab			:= ""
	Local cCodProc			:= ""
	Local cCodTabDePara     := ""
	Local cCodProcDePara    := ""
	Local nQtdSol			:= 0
	Local cCodGlosa			:= ""
	Local cDesGlosa			:= ""
	Local cCodSystem		:= ""
	Local cKeyProc			:= "internacaoSolicitacaoGuia.procedimentosSolicitados"
	Local cKeyNegativas     := ""

	if(ValType(self:aProcedimentos) <> "A")

		self:aProcedimentos := {}
		self:aNegativas := {}
	
		cCodTab  := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimento.codigoTabela")
		cCodProc := self:get(cKeyProc + "["  + allTrim(str(nProc)) + "].procedimento.codigoProcedimento")

		while !empty (cCodTab + cCodProc)

			cCodTab  	:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimento.codigoTabela")
			cCodProc 	:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimento.codigoProcedimento")
            cDescPro    := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimento.descricaoProcedimento")
            nQtdSol     := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].quantidadeSolicitada")

			cCodTabDePara := AllTrim(PLSVARVINC('87','BR4',cCodTab))
			cCodProcDePara := AllTrim(PLSVARVINC(cCodTab,'BR8', cCodProc, cCodTabDePara+cCodProc,,self:aTabDup,@cCodTabDePara))

			if (!empty(cCodTab+cCodProc))
				
				aAdd(self:aProcedimentos, {cCodTabDePara,;
                                           cCodProcDePara,;
                                           nQtdSol,;		
                                           cDescPro})
				
				nNegativa := 0
				cKeyNegativas := cKeyProc + "[" + allTrim(str(nProc)) + "].motivosNegativa"
				
				while !empty(self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoGlosa"))
					
					cCodGlosa := self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoGlosa")
					cDesGlosa := self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.descricaoGlosa")
					cCodSystem := self:get(cKeyNegativas+ "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoNoSistema")
					aAdd(self:aNegativas, {cCodTabDePara, cCodProcDePara, cCodGlosa, cDesGlosa, cCodSystem})
					nNegativa++
				
				enddo 
			
			endIf
			
			nProc++
			
		enddo

	endIf

return self:aProcedimentos

Method getNegativas() Class AutInternacao
	if ValType(self:aNegativas) <> "A"
		self:aNegativas := {}
		// chama o getProcedimentos pois ele já preenche o aCriticas
		self:getProcedimentos()
	endIf
Return self:aNegativas

Method statusByProc() Class AutInternacao
		
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

Method getNumGuia() Class AutInternacao
Return self:cNumGuia

Method setNumGuia(cNumGuia) Class AutInternacao
Return self:cNumGuia := cNumGuia

Method insert() Class AutInternacao

	Local aIndCli		:= PLBreakTxt(self:getIndCli(), {"BE4_INDCLI", "BE4_INDCL2"})
	Local aLocalPrest   := self:getLocalPrest() // RETORNA O CODIGO CADASTRADO NA BB8
	Local aProcedimentos := self:getProcedimentos()
	Local aNegativas    := self:getNegativas()
	Local dDtAut		:= stod(self:getDtAut())
	Local aObs			:= PLBreakTxt(self:getObsJust(), {"BE4_MSG01", "BE4_MSG02"})
	Local cAnoAut       := alltrim(str(YEAR(dDtAut)))
	Local cMesAut       := STRZERO(val(alltrim(str(MONTH(dDtAut)))), 2, 0)
	Local cNumGuia      := ""
	Local cCodEsp       := self:getEspSol()
	Local cCodOpe       := PLSINTPAD()
	Local cOpeRDA       := cCodOpe
	Local cCodRDA		:= self:codPrestOpe() // RETORNA O CODIGO CADASTRADO NA BAU_CODIGO
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
	Local cTipGuia		:= "03"
	Local lCritica      := .F.
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
		cNumero := PLSA500NUM("BE4", cCodOpe, cCodLdp, cCodPeg)
		self:setNumGuia(cCodOpe+cAnoAut+cMesAut+cNumGuia)

			BEA->(RecLock("BEA",.T.))
																			
			BEA->BEA_FILIAL := xFilial("BEA")   
			BEA->BEA_STATUS := cStatus
			BEA->BEA_CANCEL := "0"
			BEA->BEA_AUDITO := iif(lAudito, "1", "0")
			BEA->BEA_TIPGUI := cTipGuia
			BEA->BEA_TIPO   := "3"
			BEA->BEA_TPGRV  := "3"
			BEA->BEA_ORIMOV := "6"											// Autorizador             
			BEA->BEA_GUIPRE := self:getGuiPrest()							
			BEA->BEA_OPEMOV := cCodOpe          			              	
			BEA->BEA_ANOAUT := cAnoAut        
			BEA->BEA_MESAUT := cMesAut       
			BEA->BEA_NUMAUT := cNumGuia

			BEA->BEA_OPEINT := cCodOpe          			              	
			BEA->BEA_ANOINT := cAnoAut
			BEA->BEA_MESINT := cMesAut
			BEA->BEA_NUMINT := cNumGuia

			BEA->BEA_OPEPEG := cCodOpe
			BEA->BEA_CODLDP := cCodLdp
			BEA->BEA_DTDIGI := dDataBase
			BEA->BEA_HHDIGI := StrTran(Time(),":","")
			BEA->BEA_CODPEG := cCodPeg
			BEA->BEA_NUMGUI := cNumero

			BEA->BEA_OPEUSR := cOpeUsr										
			BEA->BEA_CODEMP := cCodEmp
			BEA->BEA_MATRIC := cMatric 
			BEA->BEA_TIPREG := cTipReg
			BEA->BEA_DIGITO := cDigito                   					
																		
			BEA->BEA_ATERNA := self:getAtendRN()			         

			BEA->BEA_OPERDA := cOpeRDA
			BEA->BEA_CODRDA := self:codPrestOpe()      				
			BEA->BEA_CODLOC := aLocalPrest[1]
			BEA->BEA_LOCAL  := aLocalPrest[2]																																				

			BEA->BEA_NOMSOL := self:prfSolNome()  				 		
			BEA->BEA_SIGLA  := self:prfSolSigla()           			
			BEA->BEA_REGSOL := self:prfSolNumero()         			
			BEA->BEA_ESTSOL := self:prfSolUf()              			
			BEA->BEA_ESPSOL := cCodEsp 		                    			
			BEA->BEA_CODESP := cCodEsp      		             			

			BEA->BEA_TIPADM := self:getCarAtend()        				
			BEA->BEA_DATSOL := dDtAut   
			BEA->BEA_INDCLI := aIndCli[1]
			BEA->BEA_INDCL2 := aIndCli[2]               									
			BEA->BEA_MSG01  := aObs[1]	         		
			BEA->BEA_MSG02  := aObs[2]
			BEA->BEA_LIBERA := "1"
		
		BEA->(MsUnLock())

		BE4->(RecLock("BE4",.T.))
																			
			BE4->BE4_FILIAL := xFilial("BE4")   
			BE4->BE4_STATUS := cStatus
			BE4->BE4_CANCEL := "0"
			BE4->BE4_AUDITO := iif(lAudito, "1", "0")
			BE4->BE4_TIPGUI := cTipGuia
			BE4->BE4_TPGRV  := "2"
			BE4->BE4_ORIMOV := "6"				             
			BE4->BE4_GUIPRE := self:getGuiPrest()

			BE4->BE4_ANOINT := cAnoAut
			BE4->BE4_MESINT := cMesAut
			BE4->BE4_NUMINT := cNumGuia

			BE4->BE4_CODLDP := cCodLdp
			BE4->BE4_DTDIGI := dDataBase
			BE4->BE4_HHDIGI := StrTran(Time(),":","")
			BE4->BE4_CODPEG := cCodPeg
			BE4->BE4_NUMERO := cNumero

			BE4->BE4_OPEUSR := cOpeUsr
			BE4->BE4_CODEMP := cCodEmp
			BE4->BE4_MATRIC := cMatric 
			BE4->BE4_TIPREG := cTipReg
			BE4->BE4_DIGITO := cDigito                   					
																		
			BE4->BE4_ATERNA := self:getAtendRN()

			BE4->BE4_NOMSOL := self:prfSolNome()
			BE4->BE4_SIGLA  := self:prfSolSigla()           			
			BE4->BE4_REGSOL := self:prfSolNumero()         			
			BE4->BE4_ESTSOL := self:prfSolUf()              			
			BE4->BE4_ESPSOL := cCodEsp 		                    			
			BE4->BE4_CODESP := cCodEsp

			BE4->BE4_TIPADM := self:getCarAtend()
			BE4->BE4_INDCLI := aIndCli[1]
			BE4->BE4_INDCL2 := aIndCli[2]
			BE4->BE4_MSG01  := aObs[1]
			BE4->BE4_MSG02  := aObs[2]

			BE4->BE4_OPERDA := cOpeRDA
			BE4->BE4_CODRDA := self:codPrestOpe()
			BE4->BE4_CODLOC := aLocalPrest[1]
			BE4->BE4_LOCAL  := aLocalPrest[2]

			BE4->BE4_CODOPE  := cCodOpe
 			BE4->BE4_PRVINT  := stod(self:getDatSug())
 			BE4->BE4_NOMRDA  := self:rdaSolNome()
			BE4->BE4_TIPINT  := self:getTipInt()
 			BE4->BE4_CID     := self:getcid()
 			BE4->BE4_ESTSOL  := self:prfSolUf()
 			BE4->BE4_OPESOL  := cCodOpe
 			BE4->BE4_REGINT  := self:getRegInt()
 			BE4->BE4_DIASSO  := self:getQtdDay()
		
		BE4->(MsUnLock())

		For nI := 1 to len(aProcedimentos)

			nCritica := aScan(aNegativas, { |x| x[1] == aProcedimentos[nI][1] .and. x[2] == aProcedimentos[nI][2] })

			lCritica := nCritica > 0
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
				BE2->BE2_DATPRO := dDtAut
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

			BE2->(MsUnLock())

			BEJ->(RecLock("BEJ",.T.))

				BEJ->BEJ_FILIAL := xFilial("BEJ")          
				BEJ->BEJ_STATUS := iif(lCritica, "0", "1")
				BEJ->BEJ_SEQUEN := StrZero(nI, 3)
				BEJ->BEJ_CODPAD := aProcedimentos[nI][1]
				BEJ->BEJ_CODPRO := aProcedimentos[nI][2]
				BEJ->BEJ_QTDSOL := aProcedimentos[nI][3]   
				BEJ->BEJ_CODOPE := cCodOpe
				BEJ->BEJ_DESPRO := aProcedimentos[nI][4]
				BEJ->BEJ_AUDITO := iif(lAudito, "1", "0")
				BEJ->BEJ_NUMINT := cNumGuia                                                         
				BEJ->BEJ_ANOINT := cAnoAut
				BEJ->BEJ_MESINT := cMesAut
				BEJ->BEJ_ESPSOL := cCodEsp
					       

			BEJ->(MsUnLock())

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

						BEL->(RecLock("BEL",.T.))

							BEL->BEL_FILIAL := xFilial("BEL")
							BEL->BEL_CODOPE := cCodOpe
							BEL->BEL_ANOINT := cAnoAut
							BEL->BEL_MESINT := cMesAut
							BEL->BEL_NUMINT := cNumGuia
							BEL->BEL_SEQUEN := StrZero(nI, 3)
							BEL->BEL_CODGLO := aNegativas[nJ][5]
							BEL->BEL_DESGLO := BCT->BCT_DESCRI
							BEL->BEL_INFGLO := ""
							BEL->BEL_SEQCRI := StrZero(nAux, Len(BEL->BEL_SEQCRI))
							BEL->BEL_TIPO   := BCT->BCT_TIPO

						BEL->(MsUnLock())

					endIf
					nJ++ 
					nAux++

				endDo

			endIf

		Next nI

		if lAudito

			self:grvAuditoria()

		endIf

	End Transaction

	lGravou := .T.

Return lGravou

Method grvAuditoria() Class AutInternacao

	Local o790C			:= nil
	Local aCabCri       := {}
	Local aColsITE      := {}
	Local aDadCri		:= {}
	Local aHeaderITE    := {}
	Local aVetBEL       := {}
	Local aVetITE       := {}

	BEJ->(dbSetOrder(1))
	BEL->(dbSetOrder(1))

	Store Header "BEJ" TO aHeaderITE For .T.
	Store COLS "BEJ" TO aColsITE FROM aHeaderITE VETTRAB aVetITE While; 
	BEJ->(BEJ_FILIAL) == xFilial("BEJ")+self:cNumGuia

	Store Header "BEL" TO aCabCri For .T.
	Store COLS "BEL" TO aDadCri FROM aCabCri VETTRAB aVetBEL While;
	BEL->(BEL_FILIAL) == xFilial("BEL")+self:cNumGuia

	o790C := PLSA790C():New(.T.)
	o790C:SetAuditoria(.T.,.F.,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],"0","BEL",aColsITE,aHeaderITE,"BEJ",.F., .F.)
	o790C:Destroy()


Return

//
