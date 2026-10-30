#include "TOTVS.CH"
#include "PLSMGER.CH"

#define __aCdCri187 {"573","Demanda por requerimento"}

Class AutExame from AutAbstrata

	Data aTabDup
	Data aProcedimentos
	Data aNegativas
	Data cNumGuia

	Method New(hMap) Constructor

	Method getRegAns()
	Method getGuiPrest()
	Method getNumGuiPri()
	Method getNumGuiOpe()

	Method getNumCarteira()
	Method getAtendRN()
	Method getNumCNS()

	Method codPrestOpe()
	Method getLocalPrest()
	Method getCpfCnpjPrest()

	Method getNomeProf()
	Method getConsProf()
	Method getNumConsProf()
	Method getUfProf()
	Method getCbos()
	Method getCodEsp()

	Method getCarAtend()
	Method getDataSol()
	Method getIndCli()

	Method getProcedimentos()

	Method getNegativas()

	Method statusByProc()

	Method getObservacao()

	Method getNumGuia()
	Method setNumGuia(cNumGuia)

	Method insert()
	Method grvAuditoria()

EndClass

Method New(HMap) Class AutExame
	self:hMap := HMap
	self:aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
Return self

Method getRegAns() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.cabecalhoSolicitacao.registroANS")

Method getGuiPrest() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.cabecalhoSolicitacao.numeroGuiaPrestador")

Method getNumGuiPri() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.numeroGuiaPrincipal")

Method getNumGuiOpe() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.numeroGuiaOperadora")

Method getNumCarteira() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.dadosBeneficiario.numeroCarteira")

Method getAtendRN() Class AutExame
	Local cAtendRN := self:get("sp-sadtSolicitacaoGuia.dadosBeneficiario.atendimentoRN")
Return iif(cAtendRN == "S", "1", "0")

Method getNumCNS() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.dadosBeneficiario.numeroCNS")

Method codPrestOpe() Class AutExame
	
	Local cCpfCnpj := self:getCpfCnpjPrest()
	Local aArea   := getArea()
	Local cCodPrest := ""
	BAU->(dbSetOrder(4))
			
	if (BAU->(msSeek(xFilial("BAU")+cCpfCnpj)))

		cCodPrest := BAU->BAU_CODIGO

	endIf

	RestArea(aArea)

Return cCodPrest

Method getLocalPrest() Class AutExame
	
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

Method getCpfCnpjPrest() Class AutExame

	Local cCpfCnpj := self:get("sp-sadtSolicitacaoGuia.dadosSolicitante.contratadoSolicitante.cpfContratado")
	if empty(cCpfCnpj)
		cCpfCnpj := self:get("sp-sadtSolicitacaoGuia.dadosSolicitante.contratadoSolicitante.cnpjContratado")
	endIf

	cCpfCnpj := StrTran(StrTran(StrTran(cCpfCnpj, ".", ""), "-", ""), "/", "")

Return cCpfCnpj

Method getNomeProf() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.dadosSolicitante.profissionalSolicitante.nomeProfissional")

Method getConsProf() Class AutExame
	Local cConsProf := self:get("sp-sadtSolicitacaoGuia.dadosSolicitante.profissionalSolicitante.conselhoProfissional")
Return alltrim(PLSVARVINC('26', nil, cConsProf))

Method getNumConsProf() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.dadosSolicitante.profissionalSolicitante.numeroConselhoProfissional")

Method getUfProf() Class AutExame
	Local cUfProf := self:get("sp-sadtSolicitacaoGuia.dadosSolicitante.profissionalSolicitante.UF")
Return alltrim(PLSVARVINC('59', nil, cUfProf))

Method getCbos() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.dadosSolicitante.profissionalSolicitante.CBOS")

Method getCodEsp() Class AutExame
	Local cCbos		:= self:getCbos()
	Local cCodEsp	:= Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP')
Return cCodEsp

Method getCarAtend() Class AutExame
	Local cCarAtend := self:get("sp-sadtSolicitacaoGuia.caraterAtendimento")
Return alltrim(PLSVARVINC('23', nil, cCarAtend))

Method getDataSol() Class AutExame
	Local cDataSol := self:get("sp-sadtSolicitacaoGuia.dataSolicitacao")
	Local dSolic := STOD(StrTran( cDataSol, "-", "" ))
Return dSolic

Method getIndCli() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.indicacaoClinica")

Method getProcedimentos() Class AutExame
		
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
	Local cKeyProc			:= "sp-sadtSolicitacaoGuia.procedimentosSolicitados"
	Local cKeyNegativas     := ""

	if(ValType(self:aProcedimentos) <> "A")

		self:aProcedimentos := {}
		self:aNegativas := {}
	
		cCodTab  := self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimento.codigoTabela")
		cCodProc := self:get(cKeyProc + "["  + allTrim(str(nProc)) + "].procedimento.codigoProcedimento")

		while !empty (cCodTab + cCodProc)

			cCodTab  	:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimento.codigoTabela")
			cCodProc 	:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].procedimento.codigoProcedimento")
			nQtdSol		:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].quantidadeSolicitada", "N")
			nQtdAut 	:= self:get(cKeyProc + "[" + allTrim(str(nProc)) + "].quantidadeAutorizada", "N")

			cCodTabDePara := AllTrim(PLSVARVINC('87','BR4',cCodTab))
			cCodProcDePara := AllTrim(PLSVARVINC(cCodTab,'BR8', cCodProc, cCodTabDePara+cCodProc,,self:aTabDup,@cCodTabDePara))

			if (!empty(cCodTab+cCodProc))
				
				aAdd(self:aProcedimentos, {cCodTabDePara, cCodProcDePara, nQtdSol, nQtdAut})		
				
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

Method getNegativas() Class AutExame
	if ValType(self:aNegativas) <> "A"
		self:aNegativas := {}
		// chama o getProcedimentos pois ele já preenche o aCriticas
		self:getProcedimentos()
	endIf
Return self:aNegativas

Method statusByProc() Class AutExame
		
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

Method getObservacao() Class AutExame
Return self:get("sp-sadtSolicitacaoGuia.observacao")

Method getNumGuia() Class AutExame
Return self:cNumGuia

Method setNumGuia(cNumGuia) Class AutExame
Return self:cNumGuia := cNumGuia

Method insert() Class AutExame

	Local aIndCli		:= PLBreakTxt(self:getIndCli(), {"BEA_INDCLI", "BEA_INDCL2"})
	Local aLocalPrest   := self:getLocalPrest()
	Local aNegativas    := self:getNegativas()
	Local aProcedimentos := self:getProcedimentos()
	Local dSolic		:= self:getDataSol()
	Local aObs			:= PLBreakTxt(self:getObservacao(), {"BEA_MSG01", "BEA_MSG02"})
	Local cAnoAut       := alltrim(str(YEAR(dSolic)))
	Local cMesAut       := STRZERO(val(alltrim(str(MONTH(dSolic)))), 2, 0)
	Local cNumGuia      := ""
	Local cCodEsp       := self:getCodEsp()
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
	Local lGravou       := .F.
	Local nAux          := 1
	Local nCritica      := 0
	Local nI 			:= 1
	Local nJ			:= 1

	Begin Transaction

		cCodLdp := PlsRetLdp(5)
		cCodPeg := PLSVRPEGOF(cCodOpe, cOpeRDA, cCodRDA,  cAnoAut, cMesAut,;
				   cTipGuia, "1", "1", "1", cCodLdp, "1","2", , dSolic, dDataBase,1 ,1 ,0, .F.)[1]

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
			BEA->BEA_ORIMOV := "6"											// Autorizador             
			BEA->BEA_GUIPRE := self:getGuiPrest()							
			BEA->BEA_OPEMOV := cCodOpe          			              	
			BEA->BEA_ANOAUT := cAnoAut        
			BEA->BEA_MESAUT := cMesAut       
			BEA->BEA_NUMAUT := cNumGuia
																			
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

			BEA->BEA_NOMSOL := self:getNomeProf()  				 		
			BEA->BEA_SIGLA  := self:getConsProf()           			
			BEA->BEA_REGSOL := self:getNumConsProf()         			
			BEA->BEA_ESTSOL := self:getUfProf()              			
			BEA->BEA_ESPSOL := cCodEsp 		                    			
			BEA->BEA_CODESP := cCodEsp      		             			

			BEA->BEA_TIPADM := self:getCarAtend()        				
			BEA->BEA_DATSOL := dSolic   
			BEA->BEA_INDCLI := aIndCli[1]
			BEA->BEA_INDCL2 := aIndCli[2]               									
			BEA->BEA_MSG01  := aObs[1]	         		
			BEA->BEA_MSG02  := aObs[2]
			BEA->BEA_LIBERA := "1"
		
		BEA->(MsUnLock())

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
				BE2->BE2_DATPRO := dSolic
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

		Next nI

		if lAudito

			self:grvAuditoria()

		endIf

	End Transaction

	lGravou := .T.

Return lGravou

Method grvAuditoria() Class AutExame

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

/*/{Protheus.doc} contadorCmp()
    @type  Function
    @author Renato Alves
    @since 12/2017
    @version 1.0
    /*/
Function PLBreakTxt(cTexto, aCmps)

	Local cAux := ""
	Local aAux := {}
	Local nI := 1
	Local nCount := 0

	for nI := 1 to len(aCmps)
		
		if nI == 1
			nCount += tamSX3(aCmps[nI])[1]
			cAux := substr(cTexto, 1, nCount)
		else
			cAux := substr(cTexto, nCount+1, tamSX3(aCmps[nI])[1])
			nCount += tamSX3(aCmps[nI])[1]
		endIf

		aAdd(aAux, cAux)

	next nI

Return aAux	
//
