#include "TOTVS.CH"
#include "PLSMGER.CH"

#define __aCdCri187 {"573","Demanda por requerimento"}

Class AutConsulta from AutAbstrata

	Data aTabDup
	Data aNegativas
	Data cNumGuia

	Method New(hMap) Constructor

	Method getRegAns()
    Method getGuiPrest()
	Method getNumGuiOpe()

	Method getNumCarteira()
	Method getAtendRN()
	Method nomeBenef()
	Method getNumCNS()

	Method codPrestOpe()
	Method getLocalPrest()
	Method getCpfCnpjPrest()
	Method getCnes()

	Method getConsProf()
	Method getNumConsProf()
	Method getNomeProf()
	Method getUfProf()
	Method getCbos()
	Method getCodEsp()

	Method getIndAcid()

	Method getDataAtend()
	Method getTpConsulta()
	Method procCodTab(lDePara)
	Method procCodPro(lDePara)
	Method procValPro()
	Method getNegativas()
	Method getObservacao()
	Method statusByProc()

	Method getNumGuia()
	Method setNumGuia(cNumGuia)

	Method insert()
	Method grvAuditoria()

EndClass

Method New(HMap) Class AutConsulta
	self:hMap := HMap
	self:aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
Return self

Method getRegAns() Class AutConsulta
Return self:get("consultaGuia.cabecalhoConsulta.registroANS")

Method getGuiPrest() Class AutConsulta
Return self:get("consultaGuia.cabecalhoConsulta.numeroGuiaPrestador")

Method getNumGuiOpe() Class AutConsulta
Return self:get("consultaGuia.numeroGuiaOperadora")

Method getNumCarteira() Class AutConsulta
Return self:get("consultaGuia.dadosBeneficiario.numeroCarteira")

Method getAtendRN() Class AutConsulta
	Local cAtendRN := self:get("consultaGuia.dadosBeneficiario.atendimentoRN")
Return iif(cAtendRN == "S", "1", "0")

Method getNumCNS() Class AutConsulta
Return self:get("consultaGuia.dadosBeneficiario.numeroCNS")

Method codPrestOpe() Class AutConsulta
	
	Local cCpfCnpj := self:getCpfCnpjPrest()
	Local aArea   := getArea()
	Local cCodPrest := ""
	BAU->(dbSetOrder(4))
			
	if (BAU->(msSeek(xFilial("BAU")+cCpfCnpj)))

		cCodPrest := BAU->BAU_CODIGO

	endIf

	RestArea(aArea)
Return cCodPrest

Method getLocalPrest() Class AutConsulta
	Local cCodLoc := ""
	Local cLocal  := ""
	Local cCodPrest := self:codPrestOpe()
	Local cCnes   := self:getCnes()
	Local aArea   := getArea()

		BB8->(dbSetOrder(7))

		if(cCnes == "999999" .or. !BB8->(msSeek(xFilial("BB8")+cCnes)))
		
			BAU->(dbSetOrder(1))
			
			if (BAU->(msSeek(xFilial("BAU")+cCodPrest)))

				BB8->(dbSetOrder(1))
				if (BB8->(msSeek(xFilial("BB8")+BAU->BAU_CODIGO)))
					cCodLoc := BB8->BB8_CODLOC
					cLocal  := BB8->BB8_LOCAL
				endIf

			endIf
		
		else 
			cCodLoc := BB8->BB8_CODLOC
			cLocal  := BB8->BB8_LOCAL
		endIf

	RestArea(aArea)

Return { cCodLoc, cLocal }

Method getCpfCnpjPrest() Class AutConsulta
	
	Local cCpfCnpj := self:get("consultaGuia.contratadoExecutante.cpfContratado")
	if empty(cCpfCnpj)
		cCpfCnpj := self:get("consultaGuia.contratadoExecutante.cnpjContratado")
	endIf

	cCpfCnpj := StrTran(StrTran(StrTran(cCpfCnpj, ".", ""), "-", ""), "/", "")
		
Return cCpfCnpj

Method getCnes() Class AutConsulta
Return self:get("consultaGuia.contratadoExecutante.CNES")

Method getConsProf() Class AutConsulta
	Local cConsProf := self:get("consultaGuia.profissionalExecutante.conselhoProfissional")
Return alltrim(PLSVARVINC('26', nil, cConsProf))

Method getNumConsProf() Class AutConsulta
Return self:get("consultaGuia.profissionalExecutante.numeroConselhoProfissional")

Method getNomeProf() Class AutConsulta
Return self:get("consultaGuia.profissionalExecutante.nomeProfissional")

Method getUfProf() Class AutConsulta
	Local cUfProf := self:get("consultaGuia.profissionalExecutante.UF")
Return alltrim(PLSVARVINC('59', nil, cUfProf))

Method getCbos() Class AutConsulta
Return self:get("consultaGuia.profissionalExecutante.CBOS")

Method getCodEsp() Class AutConsulta
	Local cCbos		:= self:getCbos()
	Local cCodEsp	:= Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP')
Return cCodEsp

Method getIndAcid() Class AutConsulta
	Local cIndAcid := self:get("consultaGuia.indicacaoAcidente")
Return alltrim(PLSVARVINC('36', nil, cIndAcid))

Method getDataAtend() Class AutConsulta
	Local cDataAtend := self:get("consultaGuia.dadosAtendimento.dataAtendimento")
	Local dAtend := STOD(StrTran( cDataAtend, "-", "" ))
Return dAtend

Method getTpConsulta() Class AutConsulta
	Local cTpCons := self:get("consultaGuia.dadosAtendimento.tipoConsulta")
Return alltrim(PLSVARVINC('52', nil, cTpCons))

Method procCodTab(lDePara) Class AutConsulta
	Local cCodTab := self:get("consultaGuia.dadosAtendimento.procedimento.codigoTabela")
	Default lDePara := .T.
	if lDePara
		cCodTab := AllTrim(PLSVARVINC('87','BR4',cCodTab))
	endIf
Return cCodTab

Method procCodPro(lDePara) Class AutConsulta
	Local cCodPro := self:get("consultaGuia.dadosAtendimento.procedimento.codigoProcedimento")
	Local cCodTab := ""
	Default lDePara := .T.
	if lDePara
		cCodTab := self:procCodTab(.T.)
		cCodPro := AllTrim(PLSVARVINC(self:procCodTab(.F.),'BR8', cCodPro, cCodTab+cCodPro,,self:aTabDup,@cCodTab))
	endIf
Return cCodPro

Method procValPro() Class AutConsulta
	Local nValor := self:get("consultaGuia.dadosAtendimento.procedimento.valorProcedimento", "N")
Return nValor

Method getNegativas() Class AutConsulta
	
	Local nNegativa  := 0
	Local cHMapProp  := "consultaGuia.dadosAtendimento.procedimento.motivosNegativa"
	Local cCodGlosa  := ""
	Local cDesGlosa  := ""
	Local cCodSystem := ""

	if valtype(self:aNegativas) <> "A"

		self:aNegativas := {}

		while !empty(self:get(cHMapProp + "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoGlosa"))

			cCodGlosa  := self:get(cHMapProp + "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoGlosa")
			cDesGlosa  := self:get(cHMapProp + "[" + allTrim(str(nNegativa)) + "].motivoNegativa.descricaoGlosa")
			cCodSystem := self:get(cHMapProp + "[" + allTrim(str(nNegativa)) + "].motivoNegativa.codigoNoSistema")

			aAdd(self:aNegativas, {cCodGlosa, cDesGlosa, cCodSystem})
			nNegativa++

		enddo

	endIf

Return self:aNegativas

Method getObservacao() Class AutConsulta
Return self:get("consultaGuia.observacao")

Method statusByProc() Class AutConsulta
	
	Local cStatus := ""
	Local aNegativas := self:getNegativas()
	Local lAudito := aScan(aNegativas, { |x|  x[3] == "025" }) > 0

	if lAudito
		cStatus := "6"
	elseif len(aNegativas) > 0
		cStatus := "3"
	else
		cStatus := "1"
	endIf

Return cStatus

Method getNumGuia() Class AutConsulta
Return self:cNumGuia

Method setNumGuia(cNumGuia) Class AutConsulta
	self:cNumGuia := cNumGuia
Return

Method insert() Class AutConsulta

	Local lGravou       := .F.
	Local dAtend		:= self:getDataAtend()
	Local cAnoAut       := alltrim(str(YEAR(dAtend)))
	Local cMesAut       := STRZERO(val(alltrim(str(MONTH(dAtend)))), 2, 0)
	Local cNumGuia      := ""
	Local cCodOpe       := PLSINTPAD()
	Local cCodRDA		:= self:codPrestOpe()
	Local aLocalPrest   := self:getLocalPrest()
	Local cTipGuia		:= "01"
	Local nVlrTot		:= self:procValPro()
	Local cOpeRDA       := cCodOpe
	Local cMatricAux    := self:getNumCarteira()
	Local cOpeUsr       := substr(cMatricAux, 1,4) 
	Local cCodEmp       := substr(cMatricAux, 5,4)
	Local cMatric       := substr(cMatricAux, 9,6)
	Local cTipReg       := substr(cMatricAux, 15,2)
	Local cDigito       := substr(cMatricAux, 17)
	Local cStatus       := self:statusByProc()
	Local lAudito       := cStatus == "6"
	Local aNegativas    := self:getNegativas()
	Local cCodEsp       := self:getCodEsp()
	Local cNumero       := ""
	Local nI 			:= 1
	Local nAux          := 1
	Local aObs			:= PLBreakTxt(self:getObservacao(), {"BEA_MSG01", "BEA_MSG02"})

	Begin Transaction

		cCodLdp := PlsRetLdp(5)
		cCodPeg := PLSVRPEGOF(cCodOpe, cOpeRDA, cCodRDA,  cAnoAut, cMesAut,;
				   cTipGuia, "1", "1", "1", cCodLdp, "1","2", , dAtend, dDataBase,1 ,1 ,nVlrTot, .F.)[1]

		cNumGuia := PLNUMAUT(cCodOpe,cAnoAut, cMesAut)
		cNumero := ""//PLSA500NUM("BEA", cCodOpe, cCodLdp, cCodPeg)
		self:setNumGuia(cCodOpe+cAnoAut+cMesAut+cNumGuia)

		BEA->(RecLock("BEA",.T.))
																			// REGISTRO ANS
			BEA->BEA_FILIAL := xFilial("BEA")   
			BEA->BEA_STATUS := cStatus
			BEA->BEA_CANCEL := "0"
			BEA->BEA_AUDITO := iif(lAudito, "1", "0")
			BEA->BEA_TIPGUI := cTipGuia
			BEA->BEA_TIPO   := "1"
			BEA->BEA_TPGRV  := "2"
			BEA->BEA_ORIMOV := "6"											// Autorizador             
			BEA->BEA_GUIPRE := self:getGuiPrest()							// 2 NRO. GUIA NO PRESTADOR
			BEA->BEA_OPEMOV := cCodOpe          			              	
			BEA->BEA_ANOAUT := cAnoAut        
			BEA->BEA_MESAUT := cMesAut       
			BEA->BEA_NUMAUT := cNumGuia
																			// 3 NRO. GUIA NA OPERADORA 
			BEA->BEA_OPEPEG := cCodOpe
			BEA->BEA_CODLDP := cCodLdp
			BEA->BEA_DTDIGI := dDataBase
			BEA->BEA_HHDIGI := StrTran(Time(),":","")
			BEA->BEA_CODPEG := cCodPeg
			BEA->BEA_NUMGUI := cNumero

			BEA->BEA_OPEUSR := cOpeUsr										// 4 MATRICULA DO BENEFICIARIO
			BEA->BEA_CODEMP := cCodEmp
			BEA->BEA_MATRIC := cMatric 
			BEA->BEA_TIPREG := cTipReg
			BEA->BEA_DIGITO := cDigito                   					
																			// 5 VALIDADE DA CARTEIRINHA
			BEA->BEA_ATERNA := self:getAtendRN()			         	// 6 ATENDIMENTO A RN?
																			// 7 NOME DO BENEFICIARIO
																			// 8 CNS DO BENEFICIARIO

			BEA->BEA_OPERDA := cOpeRDA
			BEA->BEA_CODRDA := self:codPrestOpe()      				// 9 CODIGO DO CONTRATADO EXECUTANTE
			BEA->BEA_CODLOC := aLocalPrest[1]
			BEA->BEA_LOCAL  := aLocalPrest[2]
																			// 10 NOME DO CONTRATADO EXECUTANTE
																			// 11 CNES DO CONTRATADO EXECUTANTE

			BEA->BEA_NOMEXE := self:getNomeProf()  						// 12 NOME DO PROFISSIONAL EXECUTANTE
			BEA->BEA_SIGEXE := self:getConsProf()           			// 13 SIGLA DO CONSELHO DO PROFISSIONAL EXECUTANTE
			BEA->BEA_REGEXE := self:getNumConsProf()         			// 14 NUMERO DO CONSELHO DO PROFISSIONAL EXECUTANTE
			BEA->BEA_ESTEXE := self:getUfProf()              			// 15 UF DO CONSELHO DO PROFISSIONAL EXECUTANTE
			BEA->BEA_ESPEXE := cCodEsp 		                    			// 16 CBOS DO PROFISSIONAL EXECUTANTE
			BEA->BEA_CODESP := cCodEsp      		             			// 16 COD. CBOS

			BEA->BEA_INDACI := self:getIndAcid()        				// 17 INDICACAO DE ACIDENTE
			BEA->BEA_DATPRO := dAtend                    					// 18 DATA DE ATENDIMENTO
			BEA->BEA_TIPCON := self:getTpConsulta()					// 19 TIPO DE CONSULTA

			BEA->BEA_MSG01 := aObs[1]	         			// 23 OBSERVACAO/JUSTIFICATIVA
			BEA->BEA_MSG02 := aObs[2]			  	// 23 OBSERVACAO/JUSTIFICATIVA
			BEA->BEA_LIBERA := "0"
		
		BEA->(MsUnLock())

		BE2->(RecLock("BE2",.T.))
		
			BE2->BE2_FILIAL := xFilial("BE2")          
			BE2->BE2_STATUS := iif(len(aNegativas) > 0, "0", "1")
			BE2->BE2_OPEMOV := cCodOpe
			BE2->BE2_ANOAUT := cAnoAut
			BE2->BE2_MESAUT := cMesAut
			BE2->BE2_NUMAUT := cNumGuia
			BE2->BE2_SEQUEN := "001"
			BE2->BE2_TIPGUI := cTipGuia
			BE2->BE2_TIPO   := "1"
			BE2->BE2_TPGRV  := "2"
			BE2->BE2_DATPRO := dAtend
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
			BE2->BE2_CODPAD := self:procCodTab()           	// 20 TABELA DO PROCEDIMENTO       
			BE2->BE2_CODPRO := self:procCodPro() 			// 21 CODIGO DO PROCEDIMENTO
			BE2->BE2_QTDSOL := 1        
			BE2->BE2_QTDPRO := iif(len(aNegativas) > 0, 0, 1)
			BE2->BE2_AUDITO := BEA->BEA_AUDITO
			BE2->BE2_CODLDP := cCodLdp
			BE2->BE2_CODPEG := cCodPeg
			BE2->BE2_NUMERO := cNumero
			BE2->BE2_TIPCON := self:getTpConsulta()
			BE2->BE2_VLRAPR := self:procValPro()  // 22 VALOR DO PROCEDIMENTO                                                                    
			BE2->BE2_LIBERA := "0" 

		BE2->(MsUnLock())

		BCT->(dbSetOrder(1))
		
		nAux := 1

		For nI := 1 to len(aNegativas)
			
			BCT->(dbGoTop())
			BCT->(msSeek(xFilial('BCT')+cCodOpe+aNegativas[nI][3]))
			
			BEG->(RecLock("BEG",.T.))

				BEG->BEG_FILIAL := xFilial("BEG")
				BEG->BEG_OPEMOV := cCodOpe
				BEG->BEG_ANOAUT := cAnoAut
				BEG->BEG_MESAUT := cMesAut
				BEG->BEG_NUMAUT := cNumGuia
				BEG->BEG_SEQUEN := "001"
				BEG->BEG_CODGLO := aNegativas[nI][3]
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
				BEG->BEG_SEQUEN := "001"
				BEG->BEG_CODGLO := ""
				BEG->BEG_DESGLO := "Novo Autorizador"
				BEG->BEG_INFGLO := "Novo Autorizador"
				BEG->BEG_SEQCRI := StrZero(nAux++, Len(BEG->BEG_SEQCRI))
				BEG->BEG_TIPO   := BCT->BCT_TIPO

			BEG->(MsUnLock())

			nAux++

		Next nI

		if lAudito

			self:grvAuditoria()

		endIf

	End Transaction

	lGravou := .T.

Return lGravou

Method grvAuditoria() Class AutConsulta

	Local o790C			:= nil
	Local aCabCri       := {}
	Local aDadCri		:= {}
	Local aVetBEG       := {}
	Local aHeaderITE    := {}
	Local aColsITE      := {}
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
