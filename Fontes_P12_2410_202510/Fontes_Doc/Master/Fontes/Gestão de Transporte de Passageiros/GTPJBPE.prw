#include 'totvs.ch'
#include 'FILEIO.CH'
#INCLUDE "GTPJBPE.CH"

#DEFINE FILIAL  1
#DEFINE NOTA    2
#DEFINE SERIE   3
#DEFINE CLIENTE 4
#DEFINE LOJA    5

Static aFilRef	:= {}
Static aIcmPad	:= {}
Static aSM0		:= {}

Function GTPJBPE(ljob, cTpStatus, cDtini, cDtFim, cAgencia, cChvBpeOri, l2ndVez)
Local cAliasJob	 	:= GetNextAlias()
Local aLog		 	:= ''
Local aItensNF	 	:= {}
Local cProdTar		:= GTPGetRules('PRODTAR')
Local cProdTax		:= GTPGetRules('PRODTAX')
Local cProdPED		:= GTPGetRules('PRODPED')
Local cProSGFACU	:= GTPGetRules('PROSGFACU')
Local cProUtTot		:= GTPGetRules('PROUTTOT')
Local cChvNF		:= ''
Local cEstOri		:= ''
Local cEstCal		:= ''
Local cEstDev		:= ''
Local cRet			:= STR0001 //'Rotina finalizada com sucesso!!!'
Local cFilOri		:= cFilAnt
Local cTpBil		:= ''
Local dDtVend		:= dDatabase
Local cMunOr		:= ''
Local cMunDe		:= '' 
Local cTpLinha		:= ""
Local cMsgErro      := ""
Local cQuery		:= ""
Local cDtIniGNF		:= GTPGetRules("GERNFDTINI", ,'' )		//Data de corte inicial
Local cDtFinGNF		:= GTPGetRules("GERNFDTFIM", ,'' )		//Data de corte Final
Local aAgenGNF		:= GTPGetRules("GERNFAGENC",.T.,,{})	//Lista de Agencias para geração da nota
Local cMsgErrLog 	:= ""
Local cSerie		:= ""
Local cNumBil		:= ""
Local aCampos       := {"GZR_UF","GZR_FILREF","GZR_CLIENT","GZR_LOJA"}
Local aDadosDev     := {}
Local lSkip         := .F.
Local aRegSD2		:= {}
Local aRegSE1		:= {}
Local aRegSE2		:= {}
Local lGerGrat		:= .F.
Local cCodCateg 	:= ""
Local lCatego		:= .F.
Local nTotal		:= 0
Local cLoteGTP		:= "8888"
Local lLctPG01 		:= VerPadrao("G01")
Local lLctPG02 		:= VerPadrao("G02")
Local nDescCalc     := 0
Local nGIC_VLRDSC   := 0
Local lCtbOk := .F.
Local cChvSF3 := ""
Local cChvSFT := ""
Local lSubsGrat		:= .F.
Local lCtbBilOn		:= GTPGetRules('HABCTBON',,,.T.) 
Local nSaldo 		:= 0
Local nCalcDesc		:= 0
Local aSeqDesc		:= {}
Local _nx			:= 1
Local cProdItem		:= ""
Local lIntBilOri	:= GTPGetRules('HABINTBORI',,,.F.) 
Local lNFDupl		:= .F.
Local lHasH60       := AliasInDic("H60")
Local oFile         := Nil

Static lH60_GERFIS   := H60->(FieldPos("H60_GERFIS")) > 0
Static lGIC_EMPRJI   := GIC->(FieldPos("GIC_EMPRJI")) > 0
Static lGYC_GEREST   := GYC->(FieldPos("GYC_GEREST")) > 0

Default ljob			:= .F.
Default cTpStatus		:= '0'
Default cAgencia		:= ""
Default cChvBpeOri		:= ""
Default l2ndVez			:= .F.

PRIVATE cArquivo  // Nome do arquivo contra prova
PRIVATE nHdlPrv // Endereco do arquivo de contra prova dos lanctos cont.

InitStatic()
PutProcessado(cAgencia, aAgenGNF, cDtIni, cDtFim, cDtIniGNF, cDtFinGNF)
aSM0 := FwLoadSM0()

If GTPxVldDic('GZR', aCampos, .T., .T.)
	LoadFilRef()
Endif

If Empty(cChvBpeOri) .And. !Empty(cDtIni) .And. !Empty(cDtFim)
	cQuery	+= " AND GIC_DTVEND BETWEEN '" + cDtini + "' AND '" + cDtFim + "' "
ElseIf Empty(cChvBpeOri) .And. !Empty(cDtIniGNF) .And. !Empty(cDtFinGNF)
	cQuery	+= " AND GIC_DTVEND BETWEEN '" + cDtIniGNF + "' AND '" + cDtFinGNF + "' "
Endif

If !Empty(cChvBpeOri)
	cQuery += " AND GIC_CHVBPE = '" + ALLTRIM(cChvBpeOri) + "' "
	cQuery += " AND GIC_STATUS <> 'C' "
Endif

If !Empty(cAgencia)

	cQuery += " AND GIC_AGENCI = '" + cAgencia + "' "

ElseIf Empty(cChvBpeOri) .AND. Len(aAgenGNF) > 0
	If Len(aAgenGNF) == 1
		cQuery	+= " and GIC_AGENCI = '"+aAgenGNF[1]+"' "
	Else
		cQuery	+= " and GIC_AGENCI in ("
		aEval(aAgenGNF,{|x| cQuery+="'"+x+"'," })
		cQuery	:= SubStr(cQuery,1,len(cQuery)-1)
		cQuery	+= ") "
	Endif
Endif
cQuery := "%"+cQuery+"%"

BeginSql Alias cAliasJob

	SELECT GIC.GIC_CODIGO,
	       GIC.R_E_C_N_O_ AS RECGIC,
	       GI6.GI6_FILRES,
	       GI1ORI.GI1_UF AS UFORI,
	       GI1ORI.GI1_CDMUNI AS CDMUNIORI,
	       GI1DES.GI1_UF AS UFDES,
	       GI1DES.GI1_CDMUNI AS CDMUNIDES,
	       CASE WHEN ((GIC.GIC_STATUS IN ('V','I')
	                 	AND GIC_VALTOT > 0)
					  OR (
						GIC.GIC_STATUS = 'T' AND GIC.GIC_CHVSUB = ''
					  )) THEN 1
               WHEN (GIC.GIC_VENDRJ In ('BCA','IVP') OR (GIC_STATUS = 'T' AND GIC_TIPO IN ('I','T','P') ) ) THEN 2
	           WHEN (GIC.GIC_STATUS IN ('C','D')) THEN 3
	           WHEN (GIC.GIC_STATUS IN ('V')
	                 AND GIC.GIC_VALTOT = 0) THEN 4
	           ELSE 5
	       END ORDEMREG
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GI6% GI6 ON GI6.GI6_FILIAL = %xFilial:GI6%
	AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
	AND GI6.%NotDel%
	INNER JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
	AND GI1ORI.GI1_COD = GIC.GIC_LOCORI
	AND GI1ORI.%NotDel%
	INNER JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%	
	AND GI1DES.GI1_COD = GIC.GIC_LOCDES
	AND GI1DES.%NotDel%
	WHERE GIC_FILIAL = %xFilial:GIC%
	  %Exp:cQuery%
	  AND GIC_STAPRO IN ('0','2')
	  AND GIC.GIC_CHVBPE <> ' '
	  AND (GIC_STATUS IN ('V','C','D','T') OR GIC_STATUS = 'E' AND GIC_VENDRJ = 'IVP')
	  AND GIC_NUMPRO <> '000000000000000'
	  AND GIC.%NotDel%
	ORDER BY ORDEMREG, GI6.GI6_FILRES, GIC.GIC_CODIGO

EndSql

GIC->(DbSetOrder(1)) //GIC_FILIAL+GIC_CODIGO
GI2->(DbSetOrder(1)) //GI2_FILIAL+GI2_COD+GI2_VIA
GQC->(DbSetOrder(1)) //GQC_FILIAL+GQC_CODIGO
GZW->(DbSetOrder(1)) //GZW_FILIAL+GZW_CODGQC+GZW_EST
G9O->(DbSetOrder(2)) //GG9O_FILIAL+G9O_ORIGEM+G9O_TIPO+G9O_STATUS+G9O_GQCCOD+G9O_CODIGO                                                                                                 

If lHasH60
	lCatego := H60->(FieldPos("H60_CATEGO")) > 0 .And. H60->(FieldPos("H60_PRDGRT")) > 0 
	H60->(DbSetOrder(1)) //H60_FILIAL+H60_CODG9O+H60_UF
Endif

While (cAliasJob)->(!Eof())

	GIC->(dbGoto((cAliasJob)->RECGIC))

	If !GTPLockBPE( @oFile, GIC->GIC_CODIGO,  .T. ) //Efetuar o lock
		(cAliasJob)->(dbSkip())
		Loop
	EndIf

	cMsgErro 	:= ""
	lSkip    	:= .F.
	lGerGrat 	:= .F.
	lCtbOk 	 	:= .F.
	aDadosDev   := {}
	lSubsGrat   := .F.

	// Alterar conforme Filial Responsável
	If !Empty((cAliasJob)->GI6_FILRES) .AND. cfilAnt <> (cAliasJob)->GI6_FILRES
		cfilAnt := (cAliasJob)->GI6_FILRES
	Endif

	cTpBil  	:= GIC->GIC_TIPO
	cEstOri 	:= (cAliasJob)->UFORI
	cMunOr 		:= (cAliasJob)->CDMUNIORI
	cEstCal 	:= (cAliasJob)->UFDES
	cMunDe 		:= (cAliasJob)->CDMUNIDES
	dDtVend 	:= GIC->GIC_DTVEND
	cCnpjEmi	:= Substr(GIC->GIC_CHVBPE,7,14)
	cCodCateg 	:= Alltrim(GIC->GIC_CODG9B)

	// Buscar o Tipo de Linha na Tabela de Linhas para verificar a exceção
	cTpLinha := Posicione('GI2',4,xFilial('GI2')+GIC->GIC_LINHA+'2','GI2_TIPLIN')

	If G9O->(DbSeek(xFilial("G9O") + GIC->GIC_ORIGEM + cTpBil + GIC->GIC_STATUS + cTpLinha)) //Procura primeiramente a chave exata (com o tipo de linha)

		cProdTar	:= G9O->G9O_PRDTAR
		cProdTax	:= G9O->G9O_PRDTAX
		cProdPED	:= G9O->G9O_PRDPED
		cProSGFACU	:= G9O->G9O_PRDSEG
		cProUtTot	:= G9O->G9O_PRDOUT

		If lHasH60 .And. ( GIC->GIC_VLRPGT > 0 .And. ;
									H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+cEstOri)) .OR. ;
									H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+cEstOri+cCodCateg)) .Or. ;
									H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+Space(TamSx3("H60_UF")[1])+cCodCateg)) .Or.;
									H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+cEstCal+cCodCateg)) )

			If (lH60_GERFIS .And. H60->H60_GERFIS == '1') .Or. !lH60_GERFIS
				cProdTar	:= H60->H60_PRDTAR
				cProdTax	:= H60->H60_PRDTAX
				cProdPED	:= H60->H60_PRDPED
				cProSGFACU	:= H60->H60_PRDSEG
				cProUtTot	:= H60->H60_PRDOUT
				
				If lCatego 
					cProdGrt := H60->H60_PRDGRT
					If !Empty(H60->H60_CATEGO) .And. H60->H60_CATEGO == cCodCateg
						lGerGrat := .T.
					Endif
				Endif
			Else
				cMsgErrLog := STR0022 // 'UF de origem do BP-e possui regra para não gerar o documento fiscal para o tipo e status deste BP-e' 
				lSkip := .T.
			Endif

		Endif

	Elseif G9O->(DbSeek(xFilial("G9O")+ GIC->GIC_ORIGEM + cTpBil + GIC->GIC_STATUS+ Space(TamSx3('G9O_GQCCOD')[1]) ))//Caso não encontrar, procura a chave sem o tipo de linha
		cProdTar	:= G9O->G9O_PRDTAR
		cProdTax	:= G9O->G9O_PRDTAX
		cProdPED	:= G9O->G9O_PRDPED
		cProSGFACU	:= G9O->G9O_PRDSEG
		cProUtTot	:= G9O->G9O_PRDOUT

		If lHasH60 .And. ( H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+cEstOri+cCodCateg)) .Or. H60->(dbSeek(xFilial("H60")+G9O->G9O_CODIGO+Space(TamSx3("H60_UF")[1])+cCodCateg)) )

			If (lH60_GERFIS .And. H60->H60_GERFIS == '1') .Or. !lH60_GERFIS	
				cProdTar	:= H60->H60_PRDTAR
				cProdTax	:= H60->H60_PRDTAX
				cProdPED	:= H60->H60_PRDPED
				cProSGFACU	:= H60->H60_PRDSEG
				cProUtTot	:= H60->H60_PRDOUT

				If lCatego 
					cProdGrt := H60->H60_PRDGRT
					If !Empty(H60->H60_CATEGO) .And. H60->H60_CATEGO == cCodCateg
						lGerGrat := .T.
					Endif
				Endif
			Else 
				cMsgErrLog := STR0022 // 'UF de origem do BP-e possui regra para não gerar o documento fiscal para o tipo e status deste BP-e' 
				lSkip := .T.
			Endif

		Endif

	ElseIf cTpBil == 'T' .And. !(G9O->(DbSeek(xFilial("G9O")+ GIC->GIC_ORIGEM + cTpBil + GIC->GIC_STATUS+ Space(TamSx3('G9O_GQCCOD')[1]))))
		cMsgErrLog := STR0023 // "Regra para BPe de Substituição  não cadastrada na tabela G9O"
		lSkip := .T.
	Endif

	If lSkip 
		GrvErro((cAliasJob)->GIC_CODIGO, '2', cMsgErrLog)
		GTPLockBPE(oFile) //Liberar o lock
		(cAliasJob)->(dbSkip())
		Loop
	Endif

	If (cAliasJob)->ORDEMREG == 1 .Or. (cAliasJob)->ORDEMREG == 2 .Or. ((cAliasJob)->ORDEMREG == 4 .And. lGerGrat)
		aItensNF	 := {}
		nGIC_VLRDSC:= GIC->GIC_VLRDSC

		// Buscar Produto Tarif
		If GI2->(DbSeek(xFilial("GI2")+ GIC->GIC_LINHA))
			If GQC->(DbSeek(xFilial("GQC")+ GI2->GI2_TIPLIN))
				If GZW->(DbSeek(xFilial("GZW")+ GI2->GI2_TIPLIN + cEstOri))
					If !Empty(GZW->GZW_PROTAR)
						cProdTar  := GZW->GZW_PROTAR
					Endif
				Endif
			Endif
		Endif

		If (cAliasJob)->ORDEMREG == 2 .AND. lGerGrat .AND. GIC->GIC_VALTOT == 0
			lSubsGrat := .T.
		Endif

		If (cAliasJob)->ORDEMREG == 1 .AND. GIC->GIC_STATUS = 'T' .AND. Empty(GIC->GIC_CHVSUB) .AND. GIC->GIC_VALTOT == 0 .AND. lGerGrat 
			lSubsGrat := .T.
		Endif

		If ((cAliasJob)->ORDEMREG == 4 .And. lGerGrat) .OR. lSubsGrat
			nDescCalc := 0
			If GIC->GIC_VLRBPE > 0
				aAdd(aItensNF,{cProdGrt,GIC->GIC_VLRBPE,nDescCalc})
			Endif
		Else
			aSeqDesc := {}

			If GIC->GIC_TAR > 0
				aAdd(aItensNF,{cProdTar,GIC->GIC_TAR+nGIC_VLRDSC,nGIC_VLRDSC})
			Else
				//aAdd(aItensNF,{cProdTar,nGIC_VLRDSC+(cAliasJob)->GIC_TAR,nGIC_VLRDSC+(cAliasJob)->GIC_TAR})
				nSaldo := GIC->GIC_TAR * (-1)
				aSeqDesc := GetSeqDesc(nSaldo)
			Endif

			//Rateio de desconto
			if Len(aSeqDesc) > 0
				for _nx := 1 to Len(aSeqDesc)
					If GIC->&(aSeqDesc[_nx]) > 0

						Do Case
							Case aSeqDesc[_nx] == "GIC_TAX"
								cProdItem := cProdTax
							Case aSeqDesc[_nx] == "GIC_PED"
								cProdItem := cProdPED
							Case aSeqDesc[_nx] == "GIC_SGFACU"
								cProdItem := cProSGFACU
							Case aSeqDesc[_nx] == "GIC_OUTTOT"
								cProdItem := cProUtTot
						EndCase

						nCalcDesc := GIC->&(aSeqDesc[_nx]) - nSaldo
						if nCalcDesc > 0
							aAdd(aItensNF,{cProdItem,GIC->&(aSeqDesc[_nx]),nSaldo})
							nSaldo := 0
						elseif nCalcDesc < 0
							nSaldo -= GIC->&(aSeqDesc[_nx])
							//aAdd(aItensNF,{cProdItem,(cAliasJob)->&(aSeqDesc[_nx]),(cAliasJob)->&(aSeqDesc[_nx])})
						else
							nSaldo := 0
							//aAdd(aItensNF,{cProdItem,(cAliasJob)->&(aSeqDesc[_nx]),(cAliasJob)->&(aSeqDesc[_nx])})
						endif
					Endif
				Next

			Else
				// Taxa de Embarque
				If GIC->GIC_TAX > 0
					aAdd(aItensNF,{cProdTax,GIC->GIC_TAX,0})
				Endif
				// Pedagio
				If GIC->GIC_PED > 0
					aAdd(aItensNF,{cProdPED,GIC->GIC_PED,0})
				Endif
				// Seguro Facultativo
				If GIC->GIC_SGFACU > 0
					aAdd(aItensNF,{cProSGFACU,GIC->GIC_SGFACU,0})
				Endif
				// Outros Totais
				If GIC->GIC_OUTTOT > 0
					aAdd(aItensNF,{cProUtTot,GIC->GIC_OUTTOT,0})
				Endif

			endif

		Endif

		If !(VldBilhete(aItensNF))
			GTPLockBPE(oFile) //Liberar o lock
			(cAliasJob)->(dbSkip())
			Loop
		Endif

		If (cAliasJob)->ORDEMREG == 2 .AND. !(GIC->GIC_VENDRJ $ 'VDN|IVP')

			If !(VldBilSub(cTpBil, GIC->GIC_CHVSUB, @aDadosDev)) .OR. gtpRecnoSD2(aDadosDev[2],aDadosDev[3],aDadosDev[4],aDadosDev[5]) == 0

				lSkip := .T.

				//Tenta integrar somente o bilhete de origem
				If lIntBilOri .AND. lGIC_EMPRJI
					FWMsgRun(,{|| lSkip := intProcTroca(GIC->GIC_CHVSUB, GIC->GIC_AGENCI, GIC->GIC_EMPRJI)}, STR0027, STR0028+ALLTRIM(GIC->GIC_CHVSUB)+"...")  //"Aguarde" "Integrando BPE: "

					GIC->(DBGoTo((cAliasJob)->RECGIC))

					If lSkip
						lSkip := !(VldBilSub(cTpBil, GIC->GIC_CHVSUB, @aDadosDev))
					Else
						lSkip := .T.
					Endif
				
				Endif

				If lSkip
					GrvErro((cAliasJob)->GIC_CODIGO, "2", STR0024 + GIC->GIC_CHVSUB + STR0025) //"Bpe de origem "##" não encontrado ou não faturado"
					GTPLockBPE(oFile) //Liberar o lock
					(cAliasJob)->(dbSkip())
					Loop
				Endif
			Endif
		Endif
										
		cSerie	:=  AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,23,3))))
		cNumBil	:=  AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,26,9))))

		cChvNF := ''
		cChvNF := GerDocNf(GIC->GIC_AGENCI, aItensNF, cEstOri, cEstCal, cEstDev, aLog, cTpBil, dDtVend, cMunOr, cMunDe, cSerie, cNumBil, ((cAliasJob)->ORDEMREG == 4 .And. lGerGrat) .OR. lSubsGrat, aDadosDev, Nil, Nil,(cAliasJob)->GIC_CODIGO, @lNFDupl)	


		SF2->(DbSetOrder(1))

		If SF2->(DbSeek(xFilial("SF2")+cChvNF)) //nota foi gerado com sucesso

			If !lNFDupl .AND. ((cAliasJob)->ORDEMREG == 1 .Or. (cAliasJob)->ORDEMREG == 2)
				//Ponto para chamada contabilização da NF de venda e troca
				If lLctPG02 .AND. lCtbBilOn .And. CtbValiDt(3,GIC->GIC_DTVEND,.f.)
					nHdlPrv := HeadProva(cLoteGTP,"GTPJBPE", __cUserID,@cArquivo)
					If ( nHdlPrv <> 0 )
						nTotal+=DetProva(nHdlPrv,'G02',"GTPJBPE",cLoteGTP)
						RodaProva(nHdlPrv,nTotal)
						lCtbOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteGTP,.F.,.F.,'',GIC->GIC_DTVEND)
						IF lCtbOk 
							RecLock('GIC',.F.)
								GIC->GIC_LA	:= 'S'
							MsUnlock()
						ENDIF
					EndIf
				Endif
			Endif

			GrvNfGIC(cChvNF, (cAliasJob)->GIC_CODIGO, cTpBil, IIF(lNFDupl,'X','V'), cProdTar, '1', @aDadosDev,lCtbOk)
		Endif

	ElseIf (cAliasJob)->ORDEMREG == 3 .And. lGYC_GEREST

		GYC->( dbSetOrder(1) ) //GYC_FILIAL+GYC_CODIGO
        If GYC->(DbSeek(xFilial("GYC")+ GIC->GIC_TIPCAN)) .And. GYC->GYC_GEREST == '1' // Gerar Fiscal? 1=Sim;2=Não

			aDadosDev := {}

			GetBilDev((cAliasJob)->GIC_CODIGO, cTpBil, GIC->GIC_CHVBPE, GIC->GIC_CHVSUB, @aDadosDev)

			//Tenta integrar somente o bilhete de origem
			If lIntBilOri .AND. Len(aDadosDev) == 0 .AND. lGIC_EMPRJI

				FWMsgRun(,{|| lSkip := intProcTroca(GIC->GIC_CHVBPE, GIC->GIC_AGENCI, GIC->GIC_EMPRJI)}, STR0027, STR0028+ALLTRIM(GIC->GIC_CHVBPE)+"...")  //"Aguarde" "Integrando BPE: "

				GIC->(DBGoTo((cAliasJob)->RECGIC))

				If lSkip
					GetBilDev((cAliasJob)->GIC_CODIGO, cTpBil, GIC->GIC_CHVBPE, GIC->GIC_CHVSUB, @aDadosDev)
				Endif

			Endif

			If Len(aDadosDev) > 0

				If !Empty(aDadosDev[FILIAL]) .And. aDadosDev[FILIAL] <> cFilAnt

					cFilAnt := aDadosDev[FILIAL]

				Endif

				If (VldBilhete())

					cChvNF := aDadosDev[NOTA]+aDadosDev[SERIE]+aDadosDev[CLIENTE]+aDadosDev[LOJA]

					SF2->(DbSetOrder(1))
					If !Empty(aDadosDev[NOTA]) 

						If SF2->(DbSeek(xFilial("SF2")+ cChvNF))

							cChvSF3 := SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)
							cChvSFT := SF2->(F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA)

							If GIC->GIC_VENDRJ == 'CAN' .OR. (Empty(GIC->GIC_VENDRJ) .AND. GIC->GIC_TIPO = 'W') //Quando for cancelamento sem substituição
								// Adiciona Recno da nota a ser cancelada no array SD2 para exclusão da nota como um todo.
								aRegSD2 := {}
								GetRecnoSD2(cChvNF,@aRegSD2)
								SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.T.,.F.))
							Endif

							//ContabilizaçãO da NF cancelamento SIGAGTP
							If lLctPG01 .and. lCtbBilOn .AND. Len(aDadosDev) > 0 .And. CtbValiDt(3,GIC->GIC_DTVEND,.f.)
								//Posiciona recno bilhete de venda
								GIC->(dbGoto(aDadosDev[7]))
								nHdlPrv := HeadProva(cLoteGTP,"GTPJBPE", __cUserID,@cArquivo)
								If ( nHdlPrv <> 0 )
									nTotal+=DetProva(nHdlPrv,'G01',"GTPJBPE",cLoteGTP)
									RodaProva(nHdlPrv,nTotal)
									lCtbOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteGTP,.F.,.F.,'',GIC->GIC_DTVEND)
								EndIf
								GIC->(dbGoto((cAliasJob)->RECGIC))

								IF lCtbOk 
									RecLock('GIC',.F.)
										GIC->GIC_LA	:= 'S'
									MsUnlock()
								ENDIF
							ENDIF

						EndIf
						GrvNfGIC(cChvNF, (cAliasJob)->GIC_CODIGO, cTpBil, 'C', cProdTar, '1',,lCtbOk,cChvSF3,cChvSFT)
					EndIf

				Endif
			Else
				cMsgErrLog := STR0010 // "Bilhete de referência não faturado"
				GrvErro((cAliasJob)->GIC_CODIGO, '2', cMsgErrLog)
			Endif
		EndIf

	ElseIf	(cAliasJob)->ORDEMREG == 4

		cMsgErrLog := STR0015 // "Passagem sem valor fiscal"
		GrvErro((cAliasJob)->GIC_CODIGO, '3', cMsgErrLog)

	Endif

	GTPLockBPE(oFile) //Liberar o lock
	(cAliasJob)->(DbSkip())
End

If Select(cAliasJob) > 0
	(cAliasJob)->(dbCloseArea())
Endif

If !l2ndVez
	If Len(aFilRef) > 0
		FreeObj(aFilRef)
	Endif

	If Len(aSM0) > 0
		FreeObj(aSM0)
	Endif

	If Len(aIcmPad) > 0
		FreeObj(aIcmPad)
	Endif
EndIf

If !lJob
	Aviso(STR0002, cRet, {STR0003}, 2)// //"Job Doc Saida bilhetes" //'OK'
	cFilAnt := cFilOri
Endif

return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerDocNf

Gera SF2 e SD2 do bilhete.
 
@sample	GerDocNf()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		15/12/2017
@version	P12
/*/
Static Function GerDocNf(cAgenci, aItensNF, cEstOri, cEstCal, cEstDev, aLog, cTpBil, dDtVend, cMunOr, cMunDe, cSerie, cNumBil, lGerGrat, aDadosDev, cEspecie, cCodTES, cLocOrigem, lNFDupl )
	Local aCabs      	:= {}
	Local aItens     	:= {}
	Local aStruSF2   	:= {}
	Local aStruSD2   	:= {}
	Local cNumero		:= ''
	Local cItem 		:= "00"
	Local nX        	:= 1
	Local nJ 			:= 0
	Local cCond			:= '001'
	Local nF2FILIAL		:= 0
	Local nF2TIPO		:= 0
	Local nF2DOC		:= 0
	Local nF2SERIE		:= 0
	Local nF2EMISSAO	:= 0
	Local nF2CLIENTE	:= 0
	Local nF2LOJA		:= 0
	Local nF2ESPECIE	:= 0
	Local nF2COND		:= 0
	Local nF2DTDIGIT	:= 0
	Local nF2EST		:= 0
	Local nF2VALMERC	:= 0
	Local nF2TIPOCLI	:= 0
	Local nF2MOEDA		:= 0
	Local nD2FILIAL  	:= 0
	Local nD2DOC     	:= 0
	Local nD2SERIE   	:= 0
	Local nD2CLIENTE 	:= 0
	Local nD2LOJA    	:= 0
	Local nD2EMISSAO 	:= 0
	Local nD2TIPO    	:= 0
	Local nD2ITEM    	:= 0
	Local nD2CF      	:= 0
	Local nD2COD     	:= 0
	Local nD2UM      	:= 0
	Local nD2QUANT   	:= 0
	Local nD2PRCVEN  	:= 0
	Local nD2TOTAL   	:= 0
	Local nD2LOCAL   	:= 0
	Local nD2TES     	:= 0
	Local nD2BASEIPI 	:= 0
	Local nD2ALIQIPI 	:= 0
	Local nD2VALIPI  	:= 0
	Local nD2BASEICM 	:= 0
	Local nD2ALIQICM 	:= 0
	Local nD2VALICM  	:= 0
	Local nD2TP			:= 0
	Local nD2CODISS  	:= 0
	Local nD2ESTOQUE 	:= 0
	Local nD2CONTA		:= 0
	Local nD2SITTRIB	:= 0
	Local nD2ESPECIE	:= 0	
	Local nD2DESC		:= 0 
	Local nD2DESCON		:= 0
	Local nD2NFORI		:= 0
	Local nD2SERIORI 	:= 0
	Local nD2ITEMORI	:= 0
	Local cTextoSF2   	:= ""
	Local bFiscalSF2  	:= { || .T. }
	Local cTipoCli		:= ''
	Local cSitTrib		:= ''
	Local nVlrDesconto  := 0
	Local aDocOri		:= {}
	Local lGtpSub 		:= .F.
	Local cTpOp1		:= SuperGetMv("MV_GTPOP1",.F.,"")			
	Local cTpOp2		:= SuperGetMv("MV_GTPOP2",.F.,"")
	Local cTpOper		:= ""
	Local lSubsMes		:= .T.
	Local dDataAux 		:= dDataBase	
	Local cChaveSF2		:= ""

	dDatabase := dDtVend

	DEFAULT aLog		:= {}
	DEFAULT lGerGrat	:= .F.
	DEFAULT aDadosDev	:= {}
	DEFAULT cEspecie	:= 'BPE' 
	DEFAULT cCodTES  	:= '' 
	DEFAULT cLocOrigem  := ''
	DEFAULT lNFDupl		:= .T.
	//Estrutura do dicionario utilizado pela rotina automatica
	aStruSF2    :=  SF2->(dbStruct())

	//Montagem da capa do documento fiscal
	nF2FILIAL   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_FILIAL"})
	nF2TIPO     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPO"})
	nF2DOC      := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DOC"})
	nF2SERIE    := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_SERIE"})
	nF2EMISSAO  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EMISSAO"})
	nF2CLIENTE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CLIENTE"})
	nF2LOJA     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_LOJA"})
	nF2ESPECIE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_ESPECIE"})
	nF2COND     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_COND"})
	nF2DTDIGIT  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DTDIGIT"})
	nF2EST      := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EST"})
	nF2VALMERC  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALMERC"})
	nF2TIPOCLI	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPOCLI"})
	nF2MOEDA	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_MOEDA"})
	nF2UFORIG	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFORIG"})
	nF2UFDEST	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFDEST"})
	nF2CMUNOR  	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CMUNOR"})
	nF2CMUNDE  	:= Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CMUNDE"})

	For nX := 1 To Len(aStruSF2)
		If aStruSF2[nX][2] $ "C/M"
			Aadd(aCabs,"")
		ElseIf aStruSF2[nX][2] == "N"
			Aadd(aCabs,0)
		ElseIf aStruSF2[nX][2] == "D"
			Aadd(aCabs,CtoD("  /  /  "))
		ElseIf aStruSF2[nX][2] == "L"
			Aadd(aCabs,.F.)
		EndIf
	Next

	aCabs[nF2FILIAL]    	:=  xFilial("SF2")
	aCabs[nF2TIPO]      	:= "N"
	aCabs[nF2DOC]       	:= cNumero
	aCabs[nF2SERIE]     	:= cSerie
	aCabs[nF2EMISSAO]   	:= dDtVend
	aCabs[nF2CLIENTE]   	:= SA1->A1_COD
	aCabs[nF2LOJA]      	:= SA1->A1_LOJA
	aCabs[nF2ESPECIE]   	:= cEspecie
	aCabs[nF2COND]      	:= cCond
	aCabs[nF2DTDIGIT]   	:= dDtVend
	aCabs[nF2EST]      		:= cEstCal
	aCabs[nF2TIPOCLI]	   	:= SA1->A1_TIPO
	aCabs[nF2MOEDA]			:= Iif(FindFunction('GTP905MOEDA'),GTP905MOEDA(cLocOrigem) ,CriaVar( 'F2_MOEDA' ))
	If nF2UFORIG > 0 
		aCabs[nF2UFORIG]     	:= cEstOri
	EndIf
	If nF2UFDEST > 0 
		aCabs[nF2UFDEST]      	:= cEstCal
	EndIf
	If nF2CMUNOR > 0
		aCabs[nF2CMUNOR]     	:= cMunOr
	EndIf
	If nF2CMUNDE > 0 
		aCabs[nF2CMUNDE]      	:= cMunDe
	EndIf
	
	cEstDev					:= SA1->A1_EST
	cTipoCli				:= SA1->A1_TIPO

	cChaveSF2 := aCabs[nF2FILIAL]+Padr(cNumBil,Tamsx3("F2_DOC")[1])+Padr(cSerie,Tamsx3("F2_SERIE")[1])+aCabs[nF2CLIENTE]+aCabs[nF2LOJA]
	
	//Estrutura do dicionario utilizado pela rotina automatica
	aStruSD2    :=  SD2->(dbStruct())

	//Montagem dos itens do documento fiscal
	nD2FILIAL   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_FILIAL"})
	nD2DOC      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DOC"	})
	nD2SERIE    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SERIE"	})
	nD2CLIENTE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CLIENTE"})
	nD2LOJA     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOJA"	})
	nD2EMISSAO  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EMISSAO"})
	nD2TIPO     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TIPO"	})
	nD2ITEM     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEM"	})
	nD2CF       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CF"		})
	nD2COD      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_COD"	})
	nD2UM       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_UM"		})
	nD2QUANT    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_QUANT"	})
	nD2PRUNIT	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRUNIT"	})
	nD2PRCVEN   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRCVEN"	})
	nD2TOTAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TOTAL"	})
	nD2LOCAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOCAL"	})
	nD2TES      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TES"	})
	nD2BASEIPI  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASEIPI"})
	nD2ALIQIPI  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_IPI"	})
	nD2VALIPI   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALIPI"	})
	nD2BASEICM  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASEICM"})
	nD2ALIQICM  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PICM"	})
	nD2VALICM   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALICM"	})
	nD2TP		:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TP"		})
	nD2CODISS   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CODISS"	})
	nD2ESTOQUE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ESTOQUE"})
	nD2EST  	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EST"	})
	nD2CONTA  	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CONTA"	})
	nD2SITTRIB	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SITTRIB"	})
	nD2ESPECIE	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ESPECIE"})
	nD2DESC		:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DESC"})
	nD2DESCON 	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DESCON"})

	nD2NFORI 	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_NFORI"})
	nD2SERIORI 	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SERIORI"})
	nD2ITEMORI 	:= Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEMORI"})
	
	SF4->( dbSetOrder(1) )
	SB1->( dbSetOrder(1) )
	SBZ->( dbSetOrder(1) )

	For nX := 1 to len( aItensNF )
		aCabs[nF2VALMERC]   += aItensNF[nX][2]

		aAdd(aItens, {})
		AADD(aDocOri,0)
		
		nPos := Len(aItens)

		For nJ := 1 To Len(aStruSD2)
			If  aStruSD2[nJ][2]$"C/M"
				aAdd(aItens[nPos],"")
			ElseIf aStruSD2[nJ][2]=="D"
				aAdd(aItens[nPos],CToD(""))
			ElseIf aStruSD2[nJ][2]=="N"
				aAdd(aItens[nPos],0)
			ElseIf aStruSD2[nJ][2]=="L"
				aAdd(aItens[nPos],.T.)
			EndIf
		Next

		aItens[Len(aItens),nD2FILIAL]  	:=  xFilial("SF2")
		cItem := Soma1( cItem )
		aItens[Len(aItens),nD2ITEM]    	:=  cItem
		aItens[Len(aItens),nD2DOC]     	:=  cNumero
		aItens[Len(aItens),nD2SERIE]   	:=  cSerie
		aItens[Len(aItens),nD2CLIENTE]	:=  SA1->A1_COD
		aItens[Len(aItens),nD2LOJA]    	:=  SA1->A1_LOJA
		aItens[Len(aItens),nD2EMISSAO] 	:=  dDtVend
		aItens[Len(aItens),nD2TIPO]    	:=  "N"
		aItens[Len(aItens),nD2UM]     	:=  "UN"
		aItens[Len(aItens),nD2QUANT]  	:=  1
		aItens[Len(aItens),nD2PRUNIT] 	:=  aItensNF[nX][2]
		aItens[Len(aItens),nD2PRCVEN] 	:=  aItensNF[nX][2]
		aItens[Len(aItens),nD2TOTAL]  	:=  aItensNF[nX][2]
		aItens[Len(aItens),nD2EST]		:= 	cEstCal
		aItens[Len(aItens),nD2ESPECIE]	:=  cEspecie
		nVlrDesconto := aItensNF[nX][3]
		If lGerGrat
			aItens[Len(aItens),nD2DESC]		:=  100
			aItens[Len(aItens),nD2DESCON]	:=  aItensNF[nX][2]
		Else 
			If nVlrDesconto > 0 
				aItens[Len(aItens),nD2DESCON]	:=  nVlrDesconto
			EndIf 	
		Endif
		SB1->(dbSeek(xFilial("SB1") + aItensNF[nX][1]))
		If !Empty(cCodTES)
			SF4->(dbSeek(xFilial("SF4") + cCodTES))
		Else 
			SF4->(dbSeek(xFilial("SF4") + SB1->B1_TS))
		EndIf 			

		aItens[Len(aItens),nD2LOCAL]  	:= SB1->B1_LOCPAD
		aItens[Len(aItens),nD2COD]     	:= SB1->B1_COD
		aItens[Len(aItens),nD2TP]     	:= SB1->B1_TIPO
		aItens[Len(aItens),nD2CONTA]   	:= SB1->B1_CONTA

		If !Empty( SB1->B1_CODISS )
			aItens[Len(aItens),ND2CODISS]	:= SB1->B1_CODISS
		ElseIf SBZ->( dbSeek( xFilial("SBZ") + aItensNF[nX][1] ) ) .And. !Empty( SBZ->BZ_CODISS )
			aItens[Len(aItens),ND2CODISS]	:= SBZ->BZ_CODISS
		EndIf

		DbSelectArea( "SB0" )
		SB0->(DbSetOrder(1))
		SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD))
		
		//Executa funções padrões do LOJA para retornar a situação tributária a ser gravada na SD2
		Lj7Strib(@cSitTrib ) 
		Lj7AjustSt(@cSitTrib)

		aItens[Len(aItens),nD2TES]    	:= SF4->F4_CODIGO
		aItens[Len(aItens),nD2CF]		:= SF4->F4_CF
		aItens[Len(aItens),nD2ESTOQUE]	:= SF4->F4_ESTOQUE
		
		aItens[Len(aItens),nD2SITTRIB]	:= cSitTrib

		If Len(aDadosDev) > 0
			aItens[Len(aItens),nD2NFORI]	:= aDadosDev[NOTA]
			aItens[Len(aItens),nD2SERIORI]	:= aDadosDev[SERIE]
			aItens[Len(aItens),nD2ITEMORI]	:= cItem
			lGtpSub := .T.
		Endif

	Next

	cTextoSF2  += 'MaFisAlt( "NF_UFORIGEM", "'+IIF(Valtype(cEstOri)<>'C','',cEstOri)+'", , , , , , .F./*lRecal*/ ),'
	cTextoSF2  += 'MaFisAlt( "NF_UFDEST", "'+IIF(ValType(cEstCal)<>'C','',cEstCal)+'", , , , , , .F./*lRecal*/ ),'
	cTextoSF2  += 'MaFisAlt( "NF_PNF_UF", "'+IIF(ValType(cEstDev)<>'C','',cEstDev)+'", , , , , , .F./*lRecal*/),'
	cTextoSF2  += 'MaFisAlt( "NF_ESPECIE","'+IIF(ValType(cEspecie)<>'C','',cEspecie)+'", , , , , , .F./*lRecal*/ ),'	
	cTextoSF2  += 'MaFisAlt( "NF_PNF_TPCLIFOR", "'+IIF(ValType(cTipoCli)<>'C','',cTipoCli)+'" )'

	bFiscalSF2 := &( '{||' + cTextoSF2 + '}' )

	cTpOper := ""
	
	If Len(aDadosDev) > 0 //.AND. !EMPTY(cTpOp1) .AND. !EMPTY(cTpOp2)
		
		If AnoMes(aCabs[nF2EMISSAO]) <> AnoMes(STOD(aDadosDev[6]))		
			lSubsMes := .F.
		Endif

		cTpOp1 := IIF( !EMPTY(cTpOp1) .AND. Len(FWGetSX5("DJ",cTpOp1)) > 0 , cTpOp1 , "" )
		cTpOp2 := IIF( !EMPTY(cTpOp2) .AND. Len(FWGetSX5("DJ",cTpOp2)) > 0 , cTpOp2 , "" )
		cTpOper := IIF(lSubsMes,cTpOp1,cTpOp2)	
		
	Endif
	
	//MaNfs2Nfs(cSerOri,cNumORI,cClieFor,cLoja,cSerieNFS,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajusta,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,bFilSD2,bSD2,bSF2,bTTS,aDocOri,aItemOri,aSF2,lNoFiscal,bFiscalSF2,bFiscalSD2,bFatSE1,cNumNFS,lVerSE1)	
	lNFDupl	:= .T.	
	cNumero := cNumBil
	SF2->(DBSetOrder(1))
	If !SF2->(DBSeek(cChaveSF2))
		lNFDupl := .F.
		cNumero := ""
		
		cNumero := MaNfs2Nfs(	"",; 		//Serie do Documento de Origem
		"",; 		//Numero do Documento de Origem
		"",; 		//Cliente/Fornecedor do documento do origem
		"",; 		//Loja do Documento de origem
		cSerie,; 	//Serie do Documento a ser gerado
		,;			//Mostra Lct.Contabil (OPC)
		,;			//Aglutina Lct.Contabil (OPC)
		,;			//Contabiliza On-Line (OPC)
		,;			//Contabiliza Custo On-Line (OPC)
		,;			//Reajuste de preco na nota fiscal (OPC)
		,;			//Tipo de Acrescimo Financeiro (OPC)
		,;			//Tipo de Arredondamento (OPC)
		,;			//Atualiza Amarracao Cliente x Produto (OPC)
		.T.,;			//Cupom Fiscal (OPC)
		,;			//CodeBlock de Selecao do SD2 (OPC)
		,;			//CodeBlock a ser executado para o SD2 (OPC)
		,;			//CodeBlock a ser executado para o SF2 (OPC)
		,;			//CodeBlock a ser executado no final da transacao (OPC)
		aDocOri,;	//Array com os Recnos do SF2 (OPC)
		aItens,;	//Array com os itens do SD2 (OPC)
		aCabs,;	//Array com os dados do SF2 (OPC)
		,;		//Calculo Fiscal - Desabilita o calculo fiscal pois as informacoes ja foram passadas nos campos do SD2 e SF2 (OPC)
		bFiscalSF2,;			//code block para tratamento do fiscal - SF2 (OPC)
		/*bFiscalSD2*/,;			//code block para tratamento do fiscal - SD2 (OPC)
		,;			//code block para tratamento do fiscal - SE1 (OPC)
		cNumBil,; 			//Numero do documento fiscal (OPC)
		,;
		lGtpSub,;
		cTpOper)

	Endif

	dDatabase := dDataAux

	aSize(aCabs,0) 
	aSize(aItens,0) 
	aSize(aStruSF2,0) 
	aSize(aStruSD2,0) 
	
Return PadR(cNumero,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_Serie')[1])+SA1->A1_COD+SA1->A1_LOJA


//------------------------------------------------------------------------------
/*/{Protheus.doc} GRVNFGIC

Função que realiza update na tabela GIC com o numero da nf gerada

@sample 	GRVNFGIC

@param		Nenhum

@return   	Nenhum

@author	Fernando Amorim(Cafu)
@since		18/12/2017
@version	P12.1.7
/*/
//------------------------------------------------------------------------------
Static Function GrvNfGIC(cChvNF, cCodGIC, cTpBil, cTp, cProdTar, cStaPro, aDadosDev, lCtbOk, cChvSF3, cChvSFT )
Local lRet  	:= .F.
Local aAreaAT	:= GetArea()
Local aAreaD2	:= SD2->(GetArea())
Local aAreaF2	:= SF2->(GetArea())
Local aAreaCDA	:= CDA->(GetArea())
Local aAreaGIC  := {}
Local cEspecie	:= 'BPE' 
Local cChvSub	:= ""
Local aBilCanc := {}
Default aDadosDev 	:= {}
Default lCtbOk 		:= .F.
Default cChvSF3 	:= "" 
Default cChvSFT 	:= ""

GIC->(DbSetOrder(1))
If GIC->(DbSeek(xFilial("GIC")+ cCodGIC))

	If cTp == 'V'
		
			Reclock("GIC", .F.)
				GIC->GIC_FILNF	:= IIF(cStaPro == '1', SF2->F2_FILIAL , '') 
				GIC->GIC_NOTA	:= IIF(cStaPro == '1', SF2->F2_DOC    , '')
				GIC->GIC_SERINF	:= IIF(cStaPro == '1', SF2->F2_SERIE  , '')	
				GIC->GIC_CLIENT	:= IIF(cStaPro == '1', SF2->F2_CLIENTE, '')
				GIC->GIC_LOJA	:= IIF(cStaPro == '1', SF2->F2_LOJA   , '')
				/*
				GIC->GIC_VLBICM	:= IIF(cStaPro == '1', SF2->F2_BASEICM, 0)
				GIC->GIC_VLICMS	:= IIF(cStaPro == '1', SF2->F2_VALICM , 0)
				GIC->GIC_VLPIS	:= IIF(cStaPro == '1', SF2->F2_VALIMP6, 0)
				GIC->GIC_VLCOF	:= IIF(cStaPro == '1', SF2->F2_VALIMP5, 0)
				*/
				GIC->GIC_STAPRO	:= cStaPro
			GIC->(MsUnlock())
			//Quando for troca de passagem grava o chave do bpe substituto no bilhete de cancelamento
			If GIC->GIC_STATUS == 'T' .And. !Empty(GIC->GIC_CHVSUB)
				cChvSub := GIC->GIC_CHVBPE
				RetDadosDev( cTpBil , GIC->GIC_CHVSUB, @aBilCanc, "C", .F.)
				If Len(aBilCanc) > 0
					aAreaGIC := GIC->(GetArea())
						GIC->(dbGoto(aBilCanc[7]))
						Reclock("GIC", .F.)
							GIC->GIC_CHVSUB := cChvSub
						GIC->(MsUnlock())
					RestArea(aAreaGIC)
				Endif
			Endif
			
			Reclock("SF2",.F.)	
				SF2->F2_ESPECIE := cEspecie
				SF2->F2_EMISSAO	:= GIC->GIC_DTVEND
				SF2->F2_CHVNFE	:= GIC->GIC_CHVBPE
				If lCtbOk
					SF2->F2_DTLANC := GIC->GIC_DTVEND
				Endif
				SD2->(DbSetOrder(3))
				SB1->(DbSetOrder(1))
				If SD2->(DbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ))
					While !SD2->( EOF() ) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
						SB1->( dbSeek( xFilial("SB1") + SD2->D2_COD ) )
						SD2->(RecLock("SD2", .F.))
						SD2->D2_EMISSAO	:= GIC->GIC_DTVEND
						SD2->D2_ESPECIE	:= cEspecie
						
						If SD2->D2_CONTA <> SB1->B1_CONTA
							SD2->D2_CONTA := SB1->B1_CONTA
						Endif

						If GIC->GIC_STATUS == 'T' .And. Len(aDadosDev) > 0
							SD2->D2_NFORI  	:= aDadosDev[NOTA]
							SD2->D2_SERIORI	:= aDadosDev[SERIE]
							SD2->D2_ITEMORI	:= SD2->D2_ITEM
						Endif

						SD2->(MSUNLOCK())
						
						SD2->(DbSkip())
					End
				Endif
					
				SF3->(DbSetOrder(4))
				If SF3->(DbSeek(xFilial("SFT") + SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)))
					While !SF3->( EOF() ) .AND. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3") + SF2->(F2_CLIENTE + F2_LOJA +  F2_DOC + F2_SERIE )
						SF3->(RecLock("SF3", .F.))
						SF3->F3_ESPECIE := cEspecie
						SF3->F3_EMISSAO	:= GIC->GIC_DTVEND
						SF3->F3_ENTRADA	:= GIC->GIC_DTVEND
						SF3->F3_CHVNFE	:= GIC->GIC_CHVBPE

						SF3->(MSUNLOCK())
						SF3->(DbSkip())
					End
				Endif
					
				SFT->(DbSetOrder(1))
				If SFT->(DbSeek(xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA) ))
					While !SFT->( EOF() ) .AND. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == xFilial("SFT") + "S" + SF2->(F2_SERIE + F2_DOC + F2_CLIENTE + F2_LOJA)
						SB1->( dbSeek( xFilial("SB1") + SFT->FT_PRODUTO ) )
						SFT->(RecLock("SFT", .F.))
						SFT->FT_ESPECIE := cEspecie
						SFT->FT_EMISSAO	:= GIC->GIC_DTVEND
						SFT->FT_ENTRADA	:= GIC->GIC_DTVEND
						SFT->FT_CHVNFE	:= GIC->GIC_CHVBPE

						If SFT->FT_CONTA <> SB1->B1_CONTA
							SFT->FT_CONTA := SB1->B1_CONTA
						Endif

						If GIC->GIC_STATUS == 'T' .And. Len(aDadosDev) > 0
							SFT->FT_NFORI  	:= aDadosDev[NOTA]
							SFT->FT_SERORI	:= aDadosDev[SERIE]
							SFT->FT_ITEMORI	:= SFT->FT_ITEM
						Endif

						SFT->(MSUNLOCK())
						SFT->(DbSkip())
					End
				Endif
				
				CDA->(DbSetOrder(3))
				If CDA->(DbSeek(xFilial("CDA") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
					While !CDA->(Eof()) .And. CDA->(CDA_FILIAL + CDA_NUMERO + CDA_SERIE + CDA_CLIFOR + CDA_LOJA) == xFilial("CDA") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
						CDA->(RecLock("CDA", .F.))
							CDA->CDA_ESPECI := cEspecie
						CDA->(MsUnlock())

						CDA->(DbSkip())
					EndDo
				EndIf

			SF2->(MsUnlock())	
					
	ElseIf cTp == 'C'
		Reclock("GIC", .F.)
			GIC->GIC_STAPRO	:= cStaPro
		GIC->(MsUnlock())
		SF2->(DbSetOrder(1))
		If !SF2->(DbSeek(xFilial("SF2") + cChvNF))
			SF3->(DbSetOrder(4))
			If SF3->(DbSeek(xFilial("SFT") + cChvSF3))
				While !SF3->( EOF() ) .AND. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3") + cChvSF3
					SF3->(RecLock("SF3", .F.))
					SF3->F3_DTCANC := GIC->GIC_DTVEND
					SF3->(MSUNLOCK())
					SF3->(DbSkip())
				End
			Endif
				
			SFT->(DbSetOrder(1))
			If SFT->(DbSeek(xFilial("SFT") + "S" + cChvSFT ))
				While !SFT->( EOF() ) .AND. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == xFilial("SFT") + "S" + cChvSFT
					SFT->(RecLock("SFT", .F.))
					SFT->FT_DTCANC := GIC->GIC_DTVEND
					SFT->(MSUNLOCK())
					SFT->(DbSkip())
				End
			Endif
		Endif

	ElseIf cTp == "D"
		SF1->(DbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1")+ cChvNF))			
			Reclock("GIC", .F.)
				GIC->GIC_FILNF	:= SF1->F1_FILIAL
				GIC->GIC_NOTA	:= SF1->F1_DOC
				GIC->GIC_SERINF	:= SF1->F1_SERIE
				GIC->GIC_CLIENT	:= SF1->F1_FORNECE
				GIC->GIC_LOJA	:= SF1->F1_LOJA
				GIC->GIC_VLBICM	:= SF1->F1_BASEICM
				GIC->GIC_VLICMS	:= SF1->F1_VALICM
				GIC->GIC_VLPIS	:= SF1->F1_VALIMP6
				GIC->GIC_VLCOF	:= SF1->F1_VALIMP5
				GIC->GIC_STAPRO	:= cStaPro

				Reclock("SF1",.F.)	
					SF1->F1_EMISSAO		:= GIC->GIC_DTVEND
						
					SD1->(DbSetOrder(1))//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
					If SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) ))
						While !SD1->( EOF() ) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
							SD1->(RecLock("SD1", .F.))
								SD1->D1_EMISSAO	:= GIC->GIC_DTVEND
							SD1->(MSUNLOCK())
								
							If SD1->D1_COD == cProdTar 
								GIC->GIC_ALICMS := SD1->D1_PICM
							Endif
								
							SD1->(DbSkip())
						End
					Endif
						
					SF3->(DbSetOrder(4))
					If SF3->(DbSeek(xFilial("SFT") + SF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)))
						While !SF3->( EOF() ) .AND. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3") + SF1->(F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)
							SF3->(RecLock("SF3", .F.))
								SF3->F3_ESPECIE := cEspecie
								SF3->F3_EMISSAO	:= GIC->GIC_DTVEND
								SF3->F3_ENTRADA	:= GIC->GIC_DTVEND
							SF3->(MSUNLOCK())
							SF3->(DbSkip())
						End
					Endif
						
					SFT->(DbSetOrder(1))
					If SFT->(DbSeek(xFilial("SFT") + "E" + SF1->(F1_SERIE + F1_DOC + F1_FORNECE + F1_LOJA) ))
						While !SFT->( EOF() ) .AND. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == xFilial("SFT") + "E" + SF1->(F1_SERIE + F1_DOC + F1_FORNECE + F1_LOJA)
							SFT->(RecLock("SFT", .F.))
								SFT->FT_ESPECIE := cEspecie
								SFT->FT_EMISSAO	:= GIC->GIC_DTVEND
								SFT->FT_ENTRADA	:= GIC->GIC_DTVEND
							SFT->(MSUNLOCK())
							SFT->(DbSkip())
						End
					Endif				

				SF1->(MsUnlock())	
			GIC->(MsUnlock())
		Else
			GrvErro(cCodGIC, '2', STR0004) // 'Erro na geração da nota de entrada'
		Endif
	ElseIf cTp == "X"
		Reclock("GIC", .F.)			
			GIC->GIC_FILNF	:= SF2->F2_FILIAL
			GIC->GIC_NOTA	:= SF2->F2_DOC  
			GIC->GIC_SERINF	:= SF2->F2_SERIE 
			GIC->GIC_CLIENT	:= SF2->F2_CLIENTE
			GIC->GIC_LOJA	:= SF2->F2_LOJA  
			GIC->GIC_STAPRO	:= cStaPro
		GIC->(MsUnlock())
	Endif
EndIf

RestArea(aAreaAT)	
RestArea(aAreaD2)
RestArea(aAreaF2)
RestArea(aAreaCDA)

Return lRet

/*/{Protheus.doc} GrvNfDev
Função responsavel para gravação da Nota Fiscal de Entrada de tipo Devolução
@type function
@author jacomo.fernandes
@since 19/09/2018
@version 1.0
@param cAliasJob, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvNfDev(cAliasJob, cMsgErro, lAut)
Local aCab		:= {}
Local aItens	:= {}
Local aItem		:= {}
Local cChvRet	:= ""	
Local cEspecie  :=  "BPE"
Local nX        := 0	
Local cSerie	:= GTPGetRules('GERNFSERDV') 
Local cNota 	:= NxtSX5Nota( cSerie ) //SEQUENCIAL DA NOTA FISCAL

Default lAut := .F.
Private lAutoErrNoFile := .T.
Private lMsErroAuto	:= .F.
	
//Variaveis do Cabecalho da Nota
aAdd(aCab,{"F1_TIPO"     	,'D'      						,NIL})
aAdd(aCab,{"F1_FORMUL"    	,"S"  							,NIL})
aAdd(aCab,{"F1_DOC"   	 	,cNota  						,NIL})
aAdd(aCab,{"F1_SERIE"    	,cSerie   						,NIL})
aAdd(aCab,{"F1_EMISSAO"    	,iif(!lAut, StoD((cAliasJob)->GIC_DTVEND), StoD(''))	,NIL})
aAdd(aCab,{"F1_FORNECE"    	,SF2->F2_CLIENTE				,NIL})
aAdd(aCab,{"F1_LOJA"       	,SF2->F2_LOJA					,NIL})
aAdd(aCab,{"F1_ESPECIE"    	,cEspecie						,NIL})

DbSelectArea('SD2')
SD2->(DbSetOrder(3)) // D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_

SA1->(dbSetOrder(1))

If SA1->( dbSeek( xFilial( "SA1" ) + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

	If !(RegistroOk('SA1'))
		// Static msg 
		cMsgErro := STR0005 + SF2->F2_CLIENTE + "/" + SF2->F2_LOJA + STR0006  // "Cliente ", "inativo" 
		Return .F.

	Endif
	
EndIf

If SD2->(DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) ))
	While SD2->(!EOF()) .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
		
		aItem := {}
		aAdd(aItem,{"D1_ITEM"  		,StrZero(Val(SD2->D2_ITEM),TamSx3('D1_ITEM')[1])			,NIL})
		aAdd(aItem,{"D1_COD"   		,AllTrim(SD2->D2_COD)										,NIL})
		aAdd(aItem,{"D1_UM"   		,SD2->D2_UM													,NIL})
		aAdd(aItem,{"D1_QUANT"   	,SD2->D2_QUANT 												,NIL})
		aAdd(aItem,{"D1_VUNIT"  	,SD2->D2_PRCVEN												,NIL})
		aAdd(aItem,{"D1_TOTAL"  	,SD2->D2_TOTAL												,NIL})
		aAdd(aItem,{"D1_TES"  		,Posicione('SF4',1,xFilial('SF4')+SD2->D2_TES,'F4_TESDV')	,NIL})
		aAdd(aItem,{"D1_FORNECE" 	,SF2->F2_CLIENTE											,NIL})
		aAdd(aItem,{"D1_LOJA"  		,SF2->F2_LOJA												,NIL})
		aAdd(aItem,{"D1_LOCAL"  	,SD2->D2_LOCAL												,NIL})
		aAdd(aItem,{"D1_EMISSAO"	,iif(!lAut, StoD((cAliasJob)->GIC_DTVEND), StoD(''))		,NIL})
		aAdd(aItem,{"D1_DTDIGIT" 	,iif(!lAut, StoD((cAliasJob)->GIC_DTVEND), StoD(''))		,NIL})
		aAdd(aItem,{"D1_GRUPO"   	,SD2->D2_GRUPO												,NIL})
		aAdd(aItem,{"D1_TIPO"  		,"D"														,NIL})
		aAdd(aItem,{"D1_NFORI"		,SF2->F2_DOC												,NIL})
		aAdd(aItem,{"D1_SERIORI"	,SF2->F2_SERIE    											,NIL})
		aAdd(aItem,{"D1_ITEMORI"	,SD2->D2_ITEM	    										,NIL})
					
		AAdd( aItens, aItem )
			
		SD2->(DbSkip())
	End
EndIf

lMsErroAuto := .F.
MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,3)

If !lMsErroAuto
	cChvRet	:= PadR(SF1->F1_DOC,TamSx3('F1_DOC')[1])+PadR(cSerie,TamSx3('F1_SERIE')[1])+SA1->A1_COD+SA1->A1_LOJA
Else
	cMsgErro := STR0007  + CHR(13)+CHR(10) // "Falha ao gerar NF de Devolução... "
	aLog := GetAutoGRLog()
	For nX := 1 To Len(aLog)
		cMsgErro += aLog[nX]+CHR(13)+CHR(10)			
	Next nX
	Return .F.	
EndIf

Return cChvRet

/*/{Protheus.doc} GrvErro
Função para gravaçao do erro na tabela GIC
@type function
@author Flavio Martins	
@since 19/04/2019
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvErro(cCodGIC, cStatus, cMsgErrLog)
Local aAreaGIC	:= GIC->(GetArea())

	GIC->(DbSetOrder(1))

	If GIC->(DbSeek(xFilial("GIC")+ cCodGIC))

		Reclock("GIC", .F.)
		
		GIC->GIC_STAPRO	:= cStatus
		GIC->GIC_MOTIVO	:= cMsgErrLog
		GIC->GIC_DTERRO	:= dDataBase
		
		GIC->(MsUnlock())
		
	Endif

	RestArea(aAreaGIC)

Return .T.

/*/{Protheus.doc} VldBilhete
Função para validação do bilhete
@type function
@author Flavio Martins	
@since 12/08/2019
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldBilhete(aItensNF)
Local lRet 		:= .T.
Local cAliasGIC	:= ""
Local cStatus	:= GIC->GIC_STATUS
Local cAgencia	:= GIC->GIC_AGENCI
Local cCnpjEmi	:= Substr(GIC->GIC_CHVBPE,7,14)
Local cNumBil	:= AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,26,9))))
Local cSerie	:= AllTrim(Str(Val(Substr(GIC->GIC_CHVBPE,23,3))))
Local cMsg		:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local cFilOri	:= cFilAnt
Local nX		:= 0
Local nP 		:= 0 
Local nIcmPad	:= 0
Local cQryDev   := ""
Local lCliEst	:= .F.

Default aItensNF := {}

	nP :=  aScan(aSM0,{|x| x[1] == cEmpAnt .And. x[2] == cFilAnt})
	
	If nP > 0 .And. aSM0[nP][18] <> cCnpjEmi

		If Len(aFilRef) > 0 .And. (nP := aScan(aFilRef,{|x| x[6] == cCnpjEmi})) > 0
			cFilAnt  := aFilRef[nP][3]
			cCliente := aFilRef[nP][4]
			cLoja	 := aFilRef[nP][5]
		Else
			cMsg := STR0018 + cCnpjEmi + STR0019 // "CNPJ: " " do emitente do BP-e não encontrado nas filiais"
			lRet := .F.
		Endif
		
	Endif

	If lRet

		nP := aScan(aIcmPad,{|x| x[1] == cFilAnt})

		If nP > 0 
			nIcmPad := aIcmPad[nP][2]
		Else
			nIcmPad	:= SuperGetMv("MV_ICMPAD",.F.,0, cFilAnt)	
			Aadd(aIcmPad, {cFilAnt, nIcmPad})
		Endif
		
		If nIcmPad == 0
			cMsg := STR0020 + cFilAnt // "Parâmetro MV_ICMPAD não cadastrado para a filial " 
			lRet := .F.
		Endif

	Endif
	
	If lRet 

		If Empty(cCliente)

			IF GI6->(FieldPos("GI6_CLIEST")) > 0 .AND. !EMPTY(GIC->GIC_LOCDES)
				lCliEst := (GetAdvFVal("GI1","GI1_UF",xFilial("GI1")+GIC->GIC_LOCDES,1,"") == "EX") 
			ENDIF
			
			GI6->(DbSetOrder(1))
			GI6->(dbSeek(xFilial("GI6")+cAgencia))
			cCliente := IIF(!lCliEst,GI6->GI6_CLIBIL,GI6->GI6_CLIEST)
			cLoja	 := IIF(!lCliEst,GI6->GI6_LJBIL,GI6->GI6_LJEST)
		Endif

		SA1->(dbSetOrder(1))
		
		If !SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
			If lCliEst
				cMsg := STR0026  // "Cliente estrangeiro não informado ou não encontrado"
				lRet := .F.
			else
				cMsg := STR0008  // "Cliente/Loja não existente na base"
				lRet := .F.
			EndIf
		ElseIf !(RegistroOk('SA1',.F.))	
			cMsg := STR0005 + cCliente + "/" + cLoja + STR0006  // "Cliente ", " inativo"
			lRet := .F.
		EndIf
		
	Endif
	
	If lRet .And. cStatus $ 'C|D' 
	
		cQryDev := "% AND GIC.GIC_CHVBPE = '" + GIC->GIC_CHVBPE + "' %"

		cAliasGIC	:= GetNextAlias()

		BeginSql Alias cAliasGIC

			SELECT GIC_STAPRO FROM %Table:GIC% GIC
			WHERE
			GIC.GIC_FILIAL =  %xFilial:GIC%
			AND GIC.GIC_TIPO IN ('I','T','W','P')
			AND GIC.GIC_STATUS IN ('V','T','E')
			%Exp:cQryDev%
			AND GIC.%NotDel%
			
		EndSql
		
		If (cAliasGIC)->(!Eof())
		
			If (cAliasGIC)->GIC_STAPRO == '0'
				cMsg := STR0010 // "Bilhete de referência não faturado"
				lRet := .F.
			ElseIf (cAliasGIC)->GIC_STAPRO == '2'
				cMsg := STR0011 // "Bilhete de referência com erro de faturamento"
				lRet := .F.
			Endif
		
		Else
			cMsg := STR0012 // "Bilhete de referência não encontrado"
			lRet := .F.
		Endif

		If Select(cAliasGIC) > 0
			(cAliasGIC)->(dbCloseArea())
		Endif

	Endif
	
	If lRet
	
		SF4->( dbSetOrder(1))
		SB1->( dbSetOrder(1))
		
		For nX := 1 To Len(aItensNF)
		
			SB1->(dbSeek(xFilial("SB1") + aItensNF[nX][1]))
			If Empty(SB1->B1_TS) .Or. !(SF4->( dbSeek( xFilial("SF4") + SB1->B1_TS)))	
				cMsg := STR0013 // "Error: TES de Saida padrao não preenchido ou Tipo de saida "
				lRet := .F.
				Exit
			Endif

		Next
	
	Endif
	
	
	If !(lRet)
		cFilAnt	:= cFilOri
		GrvErro(GIC->GIC_CODIGO, '2', cMsg)
	Endif

	If lRet .And. !(cStatus $ 'C|D')
	
		SF2->(DbSetOrder(1))

		If SF2->(DbSeek(xFilial("SF2")+ PadR(cNumBil,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_Serie')[1])+SA1->A1_COD+SA1->A1_LOJA))
			If !(SF2->F2_ESPECIE == 'CTE')
				GrvNfGIC("", GIC->GIC_CODIGO, "", "X", "", "1", {},.T.)
				lRet := .F.
			EndIf
		EndIf
				
	Endif
		
Return lRet

/*/{Protheus.doc} LoadFilRef
Função carregar as filiais de referencia por UF
@type function
@author Flavio Martins	
@since 17/02/2020
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadFilRef()
Local cAliasGZR	:= GetNextAlias()
Local nPos		:= 0

BeginSql Alias cAliasGZR

	SELECT  GZR_FILIAL,
			GZR_UF, 
			GZR_FILREF, 
			GZR_CLIENT, 
			GZR_LOJA
	FROM %Table:GZR% GZR
	WHERE
	GZR_FILIAL = %xFilial:GZR% 
	AND GZR.%NotDel%

EndSql

While (cAliasGZR)->(!Eof())

	nPos :=  aScan(aSM0,{|x| x[1] == cEmpAnt .And. x[2] == (cAliasGZR)->GZR_FILREF})

	Aadd(aFilRef, 	{;
						(cAliasGZR)->GZR_FILIAL,;
						(cAliasGZR)->GZR_UF,;
						(cAliasGZR)->GZR_FILREF,;
						(cAliasGZR)->GZR_CLIENT,;
						(cAliasGZR)->GZR_LOJA,;
						aSM0[nPos][18];
					};
		)

	(cAliasGZR)->(dbSkip())

End

If Select(cAliasGZR) > 0
	(cAliasGZR)->(dbCloseArea())
Endif

Return

/*/{Protheus.doc} GetBilDev
Procura e valida o bilhete de origem do bilhete devolvido
@type function
@author Flavio Martins	
@since 20/02/2023
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetBilDev(cCodBil, cTpBil, cChvBpe, cChvSub, aDadosDev )
Local lNFDev    := .F.
Local cChaveDev := ''
Local cFilSD2   := ''
Default cChvBpe := ''
Default cChvSub := ''
Default cCodBil := ''

RetDadosDev(cTpBil, cChvBpe, @aDadosDev, Nil, .F. )

If Len(aDadosDev) > 0

	SD2->(dbSetOrder(3))

	If !Empty(aDadosDev[FILIAL])
		cFilSD2 := aDadosDev[FILIAL]
	Else 
		cFilSD2 := cFilAnt 			
	EndIf 
	
	If SD2->(dbSeek(cFilSD2 + (aDadosDev[NOTA]+aDadosDev[SERIE]+aDadosDev[CLIENTE]+aDadosDev[LOJA])))
		If SD2->D2_QTDEDEV > 0
			cChaveDev := cChvBpe
			lNFDev := .T.
		Endif
	Endif

	If lNFDev 
		GrvErro(cCodBil, "2", STR0021 + cChaveDev) // "Já existe uma devolução para o BPe de origem "
	Endif

Endif

Return

/*/{Protheus.doc} RetDadosDev
Retorna os dados do bilhete de origem a ser devolvido
@type function
@author Flavio Martins	
@since 20/02/2023
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function RetDadosDev(cTpBil, cChave, aDadosDev, cStatus, lGTPA840)
Local cAliasTmp := GetNextAlias()
Local cQuery := ''
Local cCnpjEmi	:= Substr(cChave,7,14)
Local nP        := 0
Default cStatus := ""
Default lGTPA840 := IsInCallStack("GTPA840")

If cTpBil != 'T' .AND. !lGTPA840
	cQuery += " AND GIC.GIC_TIPO IN ('" + cTpBil + "','T') "
Endif

If cStatus == "C"
	cQuery += " AND GIC.GIC_STATUS = 'C' "
Else
	cQuery += " AND GIC.GIC_STATUS IN ('V','T','E') "
	cQuery += " AND GIC.GIC_STAPRO = '1' "
Endif

cQuery := "%"+cQuery+"%"

BeginSql Alias cAliasTmp

	SELECT GIC_NOTA,GIC_SERINF,GIC_CLIENT,GIC_LOJA,GIC_DTVEND,GIC.R_E_C_N_O_,GI6_FILRES 
	FROM %Table:GIC% GIC
	INNER JOIN %Table:GI6% GI6 ON
		GI6.GI6_FILIAL = GIC.GIC_FILIAL
		AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
		AND GI6.%NotDel%
	WHERE GIC.GIC_FILIAL = %xFilial:GIC%
	%Exp:cQuery% 
	AND GIC.GIC_CHVBPE = %Exp:cChave%
	AND GIC.%NotDel%
EndSql

If !Empty((cAliasTmp)->GIC_NOTA) .Or. ( cStatus == "C" .And. !Empty((cAliasTmp)->R_E_C_N_O_) )
	nP :=  aScan(aSM0,{|x| x[1] == cEmpAnt .And. x[2] == cFilAnt})
	If Len(aFilRef) > 0 .And. (nP := aScan(aFilRef,{|x| x[6] == cCnpjEmi})) > 0
		AADD(aDadosDev, aFilRef[nP][3])
	Else	
		AADD(aDadosDev, (cAliasTmp)->GI6_FILRES)
	EndIf 	
	AADD(aDadosDev, (cAliasTmp)->GIC_NOTA)
	AADD(aDadosDev, (cAliasTmp)->GIC_SERINF)
	AADD(aDadosDev, (cAliasTmp)->GIC_CLIENT)
	AADD(aDadosDev, (cAliasTmp)->GIC_LOJA)
	AADD(aDadosDev, (cAliasTmp)->GIC_DTVEND)
	AADD(aDadosDev, (cAliasTmp)->R_E_C_N_O_)
Endif

(cAliasTmp)->(dbCloseArea())

Return

/*/{Protheus.doc} VldBilSub
Retorna os dados do bilhete de origem do Bpe Substituto
@type function
@author Flavio Martins	
@since 06/11/2023
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldBilSub(cTpBil, cChvSub, aDadosDev)
Local lRet := .T.

aDadosDev := {}

RetDadosDev(cTpBil, cChvSub, @aDadosDev, Nil, .F.)

If Len(aDadosDev) > 0 

	If !Empty(aDadosDev[FILIAL]) .And. aDadosDev[FILIAL] <> cFilAnt

		cFilAnt := aDadosDev[FILIAL]

	Endif			

Else
	lRet := .F.
Endif
	
Return lRet

/*/{Protheus.doc} gtpRecnoSD2
Retorna os recnos do bilhete de origem do bpe substituto 
@type function
@author kaique.olivero	
@since 27/05/2024
/*/
Function gtpRecnoSD2(cDoc,cSerie,cClient,cLoja,cItemOri)
Local nRecnoRet := 0
Local aAreaSd2 := SD2->(GetArea())
Local cAliasSD2	:= ""

Default cDoc := ""
Default cSerie := "" 
Default cClient := ""
Default cLoja := ""
Default cItemOri := Padl('1',TamSx3("D2_ITEM")[1],'0')

If !Empty(cDoc) .And. !Empty(cSerie) .And. !Empty(cItemOri)
	//Seleciona o recno da nota original
	cAliasSD2	:= GetNextAlias()
	BeginSql Alias cAliasSD2
		SELECT SD2.R_E_C_N_O_ D2RECNO
		FROM %Table:SD2% SD2
		WHERE
			SD2.D2_FILIAL = %xFilial:SD2% 
			AND SD2.D2_DOC = %Exp:cDoc%
			AND SD2.D2_SERIE = %Exp:cSerie%
			AND SD2.D2_CLIENTE = %Exp:cClient%
			AND SD2.D2_LOJA = %Exp:cLoja%
			AND SD2.D2_ITEM = %Exp:cItemOri%
			AND SD2.%NotDel%
	EndSql

	If (cAliasSD2)->(!Eof())
		nRecnoRet := (cAliasSD2)->(D2RECNO)
	Endif
	(cAliasSD2)->(dbCloseArea())
Endif

RestArea(aAreaSd2)

Return nRecnoRet

/*/{Protheus.doc} InitStatic
Estancia variaveis estaticas casos não existam em tempo de execução
@type function
@author José Carlos	
@since 24/06/2024
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function InitStatic()

	If ValType(aFilRef) == "U"
		aFilRef := {}
	EndIF
	If ValType(aIcmPad) == "U"
		aIcmPad := {}
	EndIf
	If ValType(aSM0) == "U"
		aSM0    := {}
	EndIf

Return 

/*/{Protheus.doc} GetRecnoSD2
	Retorna os recnos dos itens da nota de venda a ser cancelada
	@type  Function
	@author João Pires
	@since 17/09/2024
	@version 1.0
	@param cChave, Character, Chave do documento
	@param aRegSD2, Array, Array para armazenar os recnos
/*/
Static Function GetRecnoSD2(cChave, aRegSD2)

	Local cQuerySD2 := ""
	Local cAliasSD2	:= ""
	Local oQuerySD2 := Nil

	cQuerySD2 := " SELECT SD2.R_E_C_N_O_ D2RECNO "
	cQuerySD2 += " FROM ? SD2 "
	cQuerySD2 += " WHERE SD2.D2_FILIAL = ? "
	cQuerySD2 += 	" AND CONCAT(CONCAT(CONCAT(D2_DOC, D2_SERIE), D2_CLIENTE),D2_LOJA) = ? "
	cQuerySD2 += 	" AND SD2.D_E_L_E_T_ = ' ' "	

	cQuerySD2 := ChangeQuery(cQuerySD2)
    oQuerySD2 := FWPreparedStatement():New(cQuerySD2)
	oQuerySD2:SetUnsafe(1, RetSqlName("SD2"))
    oQuerySD2:SetString(2, xFilial("SD2"))
    oQuerySD2:SetString(3, cChave)
	cQuerySD2  := oQuerySD2:GetFixQuery()
	cAliasSD2  := MPSysOpenQuery( cQuerySD2 )

	While (cAliasSD2)->(!Eof())
		AADD(aRegSD2,(cAliasSD2)->D2RECNO)
		(cAliasSD2)->(DBSkip())
	Enddo
	
	(cAliasSD2)->(dbCloseArea())

Return 

/*/{Protheus.doc} GTPT001NFS
	Função de geração de nota fiscal de saída - Inicialmente utilizada na rotina de emissão de NF-Substitutiva GTPT001
	Compatibilização de chamada de Static Function para Function
	@type  Function
	@author José Carlos
	@since 03/10/2024
	@version 1.0
	@param cChave, Character, Chave do documento
	@param aRegSD2, Array, Array para armazenar os recnos
/*/
Function GTPT001NFS(cAgenci, aItensNF, cEstOri, cEstCal, cEstDev, aLog, cTpBil, dDtVend, cMunOr, cMunDe, cSerie, cNumBil, lGerGrat, aDadosDev, cEspecie, cCodTES )
Return GerDocNf(cAgenci, aItensNF, cEstOri, cEstCal, cEstDev, aLog, cTpBil, dDtVend, cMunOr, cMunDe, cSerie, cNumBil, lGerGrat, aDadosDev, cEspecie, cCodTES, Nil )


/*/{Protheus.doc} GetSeqDesc
	Retorna a sequência dos itens para aplicar o desconto na nota
	@type  Function
	@author João Pires
	@since 29/10/2024
	@version 1.0
	@param nSaldp, Numeric, Valor do saldo a distibuir
/*/
Static Function GetSeqDesc(nSaldo)
	Local aRet 	  := {}
	Local aSeq	  := {}
	Local cSeqPad := "TAX|PED|SEG|OUT"
	Local cSeq 	  := GTPGetRules('SEQDESCON',,,cSeqPad) 
	Local lOk	  := .T.
	Local nX   	  := 1

	If nSaldo > 0
		aSeq := strtokarr(cSeq, "|")		
		for nX := 1 to Len(aSeq)
			If !(aSeq[nX] $ cSeqPad)				
				lOk := .F.
				Exit
			endif
		Next 	

		If !lOk	
			aSeq := {}		
			aSeq := strtokarr(cSeqPad, "|")		
		Endif

		For nX := 1 to len(aSeq)
			Do Case
				Case aSeq[nX] == "TAX"
					aAdd(aRet,"GIC_TAX")
				Case aSeq[nX] == "PED"
					aAdd(aRet,"GIC_PED")
				Case aSeq[nX] == "SEG"
					aAdd(aRet,"GIC_SGFACU")
				Case aSeq[nX] == "OUT"
					aAdd(aRet,"GIC_OUTTOT")
			EndCase
		Next

	Endif

Return aRet

/*/{Protheus.doc} intProcTroca
	Integra e processa bilhete de origem
	@type  Static Function
	@author João Pires
	@since 13/06/2025
	@version 1.0
	@param cChave, Caractere, número da chave BPE de origem
	@return lRet, Logical, retorno ok	
/*/
Static Function intProcTroca(cChave,cAgencia,cEmpRj)
	Local lRet 	  := .T.
	Local lIntegr := .F.
	Local aParams := {}		
	Local cAlias  := GetNextAlias()
	Local cData   := ""
	Local dDataI  := Nil
	Local dDataF  := Nil

	BeginSQL Alias cAlias
		
		SELECT GIC_CHVBPE FROM %Table:GIC% GIC 
		WHERE 
			GIC_FILIAL = %xFilial:GIC% 
			AND GIC_CHVBPE = %Exp:cChave%
			AND GIC_STATUS <> 'C'
			AND GIC_STAPRO = '0'
			AND GIC.%NotDel%
			
	EndSql

	lIntegr := !Empty(cChave) .AND. (cAlias)->(Eof())
	
	(cAlias)->(DBCloseArea())

	If lIntegr	   	

		cData := '01/'+SUBSTR(cChave,5,2)+'/2'+Padl(SUBSTR(cChave,3,2),3,'0')

		dDataI := CTOD(cData)
		dDataF := LastDate(dDataI)	
		
		aParams := {cEmprj,dDataI,"00:00",dDataF,"23:59",/*cAgenc*/ "",/*cAgenc*/ ""}
		
		lRet := !Empty(cEmpRj) 

		If lRet
			lRet := GTPIRJ115(.T.,aParams,.F.,.F.,"","",cChave,"V")

			If !lRet
				lRet := GTPIRJ115(.T.,aParams,.F.,.F.,"","",cChave,"T")
			Endif
		Endif
				
	Endif

	lRet := IIF(lRet .AND.  !Empty(cChave),.T.,.F.)

	If lRet 
		GTPJBPE(.T., Nil, Nil, Nil, Nil, cChave, .T.)	
	Endif

Return lRet

/*/{Protheus.doc} PutProcessado()
Marcar como processado para os casos de venda VIP e sem número da Chave BPE
@type function
@author José Carlos	
@since 28/07/2024
@version 1.0
@param
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PutProcessado(cAgencia, aAgenGNF, cDataIni, cDataFim, cDtIniGNF, cDtFinGNF)
	Local aAreaAtu  := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cExpres1  := ''
	Local cExpres2  := ''
	Local cQuery    := ''

	Default cDataIni := ''
	Default cDataFim := ''
	Default cDtIniGNF:= ''
	Default cDtFinGNF:= ''

	cDataIni := Iif(!Empty(cDataIni),cDataIni,cDtIniGNF)
	cDataFim := Iif(!Empty(cDataFim),cDataFim,cDtFinGNF)

	If !Empty(cAgencia)
		cExpres2 := " and GIC_AGENCI = '"+cAgencia+"' "
	Else
		If Len(aAgenGNF) == 1
			cExpres2 := " and GIC_AGENCI = '"+aAgenGNF[1]+"' "
		ElseIf Len(aAgenGNF) > 1 
			cExpres2 := " and GIC_AGENCI in ("
			aEval(aAgenGNF,{|x| cQuery+="'"+x+"'," })
			cQuery	:= SubStr(cQuery,1,len(cQuery)-1)
			cQuery	+= ") "
			cExpres2 += cQuery
		EndIf
	EndIf 

	cExpres1 := '%'
	If !Empty(cDataIni) .And. !Empty(cDataFim) 
		cExpres1 += " AND GIC_DTVEND BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "	
	EndIf
	cExpres1 += cExpres2
	cExpres1 += '%'

	BeginSql Alias cAliasQry
		SELECT R_E_C_N_O_ AS RECGIC
		FROM %table:GIC%
		WHERE GIC_FILIAL = %xFilial:GIC%
		AND GIC_CHVBPE = ' '
		AND GIC_STAPRO = '0' 
		AND GIC_VENDRJ = 'VIP'
		%Exp:cExpres1%
		AND %NotDel%			
	EndSql

	While (cAliasQry)->(!Eof())
		GIC->(dbGoto((cAliasQry)->RECGIC))
		Reclock("GIC", .F.)
			GIC->GIC_STAPRO := '1'
		GIC->(MsUnlock())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	RestArea( aAreaAtu )
Return

/*/{Protheus.doc} GTPLockBPE()
Efetuar e retirar lock no processo de geração do BPE
@type function
@author flavio.vicco
@since 19/09/2025
@version 1.0
/*/
Static Function GTPLockBPE( oFile, cFileLck,  lRunning )

	Local cPath := GetPathSemaforo()
	Local lRet  := .F.

	Default cFileLck := "GTPJBPE"
	Default oFile    := Nil
	Default lRunning := .F.

	If lRunning
		oFile := FWFileWriter():New( cPath + "GTPJBE" + cFileLck + ".LCK")
		If oFile:Exists()
			lRet := oFile:Open( FO_WRITE + FO_EXCLUSIVE )
		Else
			lRet := oFile:Create()
		EndIf
	Else
		If oFile:Exists()
			oFile:Close()
			oFile:Erase()
		EndIf
		FwFreeObj( oFile )
	EndIf

Return lRet
