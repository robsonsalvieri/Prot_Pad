#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSINCGFAM
Função genérica para gerar o grupo familiar
@author Karine Riquena Limp
@since 04/12/2015
@version P12
@history 
	17/09/2019, Vinicius Queiros - Inicializador padrão ao gravar grupo familiar (DSAUBE-9418)
	Alteração feita para quando incluir um novo beneficiario, atraves dos dados da memoria,
	chamando a função PLUPTENC para considerar os inicializador padrão do sx3
/*/
//-------------------------------------------------------------------
Function PLSINCGFAM(aDados, nRecnoBa1, cCodFam, lOriInc, aDadosFam)
	//Formato do adados
	//[X][Y]
	//[X]			= Posição	
	//[X][Y][1]	= Campo 
	//[X][Y][2]	= Valor 
	local cTipReg     := ""
	local cCodInt     := PLSINTPAD()
	local nI 		  := 0
	local nJ 		  := 0
	local nY 		  := 0
	local cMsg 		  := ""
	local nPosTit     := 0
	local nPosCodInt  := 0
	local nPosCodEmp  := 0
	local nPosConemp  := 0
	local nPosVerCon  := 0
	local nPosSubCon  := 0
	local nPosVersub  := 0 
	local nPosCodPla  := 0 
	local nPosVersao  := 0 
	local nPosGraupa  := 0
	local nPosCPF     := 0
	local nPosTipusu  := 0
	local nPosCodCli  := 0
	local nPosLoja    := 0
	local nPosDatInc  := 0
	local cMatTit     := ""
	local lRec 		  := .T.
	local lRet 		  := .T.
	local aArea 	  := {}
	local aRet        := {}
	local aMatrics 	  := {} //armazena a matricula dos beneficiarios incluidos
	local cCpf        := ""
	local aRetProRata := {}
	local lCriaCli    := .F.
	local cCriaCli    := GetNewPar("MV_PLSFMCL","1")
	local nQtdADados  := len(aDados)
	local oJRetGrfm   := NIL
	local oJObjRet    := NIL
	local oSecRec     := NIL 
	local aRetOpc     := {}

	default cCodFam := ""
	default nRecnoBa1 := 0
	default lOriInc := .F.
	default aDadosFam := {}
	private lJuridico := .F.

	lRec := nRecnoBa1 == 0

	nJ := 1
	while nJ <= nQtdADados .AND. nPosTit == 0
		nPosTit    := aScan(aDados[nJ], { |x| x[1] == "BA1_TIPUSU" .AND. x[2] ==  "T" })
		nJ := iif(nPosTit > 0, nJ , nJ+1) 
	endDo

   Begin Transaction 
      
   //SE INCLUI TITULAR
   if(nPosTit > 0 .AND. lRec)
   
		nPosCodInt := aScan(aDados[nJ], { |x| x[1] == "BA1_CODINT" }) 
   		nPosCodEmp := aScan(aDados[nJ], { |x| x[1] == "BA1_CODEMP" }) 
		nPosConemp := aScan(aDados[nJ], { |x| x[1] == "BA1_CONEMP" }) 
		nPosVerCon := aScan(aDados[nJ], { |x| x[1] == "BA1_VERCON" }) 
		nPosSubCon := aScan(aDados[nJ], { |x| x[1] == "BA1_SUBCON" }) 
		nPosVersub := aScan(aDados[nJ], { |x| x[1] == "BA1_VERSUB" }) 
		nPosCodPla := aScan(aDados[nJ], { |x| x[1] == "BA1_CODPLA" }) 
		nPosVersao := aScan(aDados[nJ], { |x| x[1] == "BA1_VERSAO" })
		nPosDatInc := aScan(aDados[nJ], { |x| x[1] == "BA1_DATINC" })

		nPosCodCli := aScan(aDadosFam, { |x| x[1] == "BA3_CODCLI" })
		nPosLoja := aScan(aDadosFam, { |x| x[1] == "BA3_LOJA" })

		cCodInt := aDados[nJ][nPosCodInt][2] 
     
   		if(nPosCodEmp > 0 .and. nPosCodPla > 0)
   		
   			cMatric := PLPROXMAT(cCodInt,aDados[nJ][nPosCodEmp][2])

			//Armazeno em memoria as tabelas utilizadas
			BG9->(DbSetOrder(1))
			If(BG9->(MsSeek(xFilial("BG9")+cCodInt+aDados[nJ][nPosCodEmp][2])))
				RegToMemory("BG9",.F.,.T.,.F.) // Aloca a tabela para memoria 
			EndIf

			//BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
			BQC->(DbSetOrder(1))
			If(BQC->(msSeek(xFilial("BQC")+cCodInt+aDados[nJ][nPosCodEmp][2]+iif(nPosConemp > 0, aDados[nJ][nPosConemp][2], "")+;
				iif(nPosVerCon > 0, aDados[nJ][nPosVerCon][2], "")+iif(nPosSubCon > 0, aDados[nJ][nPosSubCon][2], "")+;
				iif(nPosVersub > 0, aDados[nJ][nPosVersub][2], ""))))
				RegToMemory("BQC",.F.,.T.,.F.) // Aloca a tabela para memoria 
   			EndIf

			//BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON
			BT5->(DbSetOrder(1))
			If(BT5->(msSeek(xFilial("BT5")+cCodInt+aDados[nJ][nPosCodEmp][2]+iif(nPosConemp > 0, aDados[nJ][nPosConemp][2], "")+;
				iif(nPosVerCon > 0, aDados[nJ][nPosVerCon][2], ""))))
				RegToMemory("BT5",.F.,.T.,.F.) // Aloca a tabela para memoria 
			EndIf

			RegToMemory( "BA3", .T., .F., .T.  ) // Cria a tabela BA3 na memoria 
			M->BA3_FILIAL := xFilial("BA3")
   			M->BA3_CODINT := cCodInt
   			M->BA3_CODEMP := aDados[nJ][nPosCodEmp][2]
   			M->BA3_CONEMP := iif(nPosConemp > 0, aDados[nJ][nPosConemp][2], "")
   			M->BA3_VERCON := iif(nPosVerCon > 0, aDados[nJ][nPosVerCon][2], "")
   			M->BA3_SUBCON := iif(nPosSubCon > 0, aDados[nJ][nPosSubCon][2], "")
   			M->BA3_VERSUB := iif(nPosVersub > 0, aDados[nJ][nPosVersub][2], "")
   			M->BA3_CODPLA := iif(nPosCodPla > 0, aDados[nJ][nPosCodPla][2], "")
   			M->BA3_VERSAO := iif(nPosVersao > 0, iIf(Empty(aDados[nJ][nPosVersao][2]), "001", aDados[nJ][nPosVersao][2]), "") 
   			M->BA3_MATRIC := cMatric
   			M->BA3_HORACN := SubStr(Time(),1,5)
   			M->BA3_VENCTO := iif(!empty(GetNewPar("MV_DATVENP", 1)), GetNewPar("MV_DATVENP", 1) ,1)
   			M->BA3_DATBAS := dDataBase 
   			M->BA3_DATCIV := dDataBase
   			M->BA3_USUOPE := BA3->(RETCODUSR())
   			M->BA3_DATCON := ddatabase
   			M->BA3_HORCON := SubStr(Time(),1,5)

			if B2N->(fieldPos("B2N_DATINC")) > 0 .and. nPosDatInc > 0 .and. !empty(aDados[nJ][nPosDatInc][2])
				M->BA3_DATBAS := aDados[nJ][nPosDatInc][2]
   				M->BA3_DATCIV := aDados[nJ][nPosDatInc][2]
			endif

			if nPosCodCli > 0 .And. nPosLoja > 0
				M->BA3_COBNIV := "1"
				M->BA3_CODCLI := aDadosFam[nPosCodCli][2]
				M->BA3_LOJA := aDadosFam[nPosLoja][2]
			endif
			
			BG9->(DbSetOrder(1))
			If(BG9->(MsSeek(xFilial("BG9")+cCodInt+aDados[nJ][nPosCodEmp][2])))
   				M->BA3_TIPOUS := BG9->BG9_TIPO
   				//pessoa fisica ou juridica
   				if(M->BA3_TIPOUS == "1")
   					aRet := PLFORPAGPF(M->BA3_CODPLA, M->BA3_VERSAO, , , .T.)
					
					aRetProRata := GetDadProRata("1", cCodInt, M->BA3_CODPLA, M->BA3_VERSAO)

					If Len(aRetProRata) == 1
						M->BA3_COBRAT := aRetProRata[1]
					EndIf

					If Empty(M->BA3_CODCLI)
						M->BA3_COBNIV := "1"
						lCriaCli := .T.
					eNDIF
   				else
   					aRet := PLFORPAGPJ(M->BA3_CODPLA, M->BA3_VERSAO, , , .T., M->BA3_CODEMP, M->BA3_CONEMP, M->BA3_VERCON, M->BA3_SUBCON, M->BA3_VERSUB)

					aRetProRata := GetDadProRata("2", cCodInt,,,M->BA3_CODEMP, M->BA3_CONEMP, M->BA3_VERCON, M->BA3_SUBCON, M->BA3_VERSUB)

					If Len(aRetProRata) == 3
						M->BA3_COBRAT := aRetProRata[1]
						M->BA3_COBRET := aRetProRata[2]
						M->BA3_DIARET := aRetProRata[3]
					EndIf
					If Empty(M->BA3_CODCLI)
						lCriaCli := PLConCli(.T., M->BA3_SUBCON, M->BA3_VERSUB)
						Iif(lCriaCli, M->BA3_COBNIV := "1", Nil)
					EndIf
   				endIf
	
				M->BA3_FORPAG := aRet[1]
				M->BA3_ROTINA := aRet[2]
				M->BA3_FORCTX := aRet[3]
				M->BA3_MODPAG := aRet[4]
				M->BA3_RATSAI := aRet[5]
   			endIf

   			BG9->(dbCloseArea())
			PLUPTENC("BA3",3)
			// Grava a forma de cobrança automatica da familia
			If !Empty(BA3->BA3_CODPLA) .AND. !Empty(BA3->BA3_VERSAO) .AND. !Empty(BA3->BA3_FORPAG)
				PL169FOR(BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC,IIF(BA3->BA3_TIPOUS == "2",.T.,.F.),.T.,.F.,"")
				  
			EndIf
			// Grava a taxão de adessão automatica da familia
			If !Empty(BA3->BA3_CODPLA) .AND. !Empty(BA3->BA3_VERSAO) .AND. !Empty(BA3->BA3_FORCTX)
				PL169TXA(BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC,IIF(BA3->BA3_TIPOUS == "2",.T.,.F.),.T.,"")
			EndIf
   		else 
   			lRet := .F.
   			cMsg := "Para incluir uma familia no sistema é necessário informar o código da empresa, o codigo do plano"
   		endIf
   	else

		nPosCodInt := aScan(aDados[1], { |x| x[1] == "BA1_CODINT" }) 
   		nPosCodEmp := aScan(aDados[1], { |x| x[1] == "BA1_CODEMP" }) 
		nPosConemp := aScan(aDados[1], { |x| x[1] == "BA1_CONEMP" }) 
		nPosVerCon := aScan(aDados[1], { |x| x[1] == "BA1_VERCON" }) 
		nPosSubCon := aScan(aDados[1], { |x| x[1] == "BA1_SUBCON" }) 
		nPosVersub := aScan(aDados[1], { |x| x[1] == "BA1_VERSUB" }) 
		nPosCodPla := aScan(aDados[1], { |x| x[1] == "BA1_CODPLA" }) 
		nPosVersao := aScan(aDados[1], { |x| x[1] == "BA1_VERSAO" })
        nPosCPF    := aScan(aDados[1], { |x| x[1] == "BA1_CPFUSR" })
		nPosDatInc := aScan(aDados[1], { |x| x[1] == "BA1_DATINC" })

		cCodInt := aDados[1][nPosCodInt][2] 
        cCpf := Alltrim(aDados[1][nPosCPF][2])
		//Armazeno em memoria as tabelas utilizadas
		BG9->(DbSetOrder(1))
		If(BG9->(MsSeek(xFilial("BG9")+cCodInt+aDados[1][nPosCodEmp][2])))
			RegToMemory("BG9",.F.,.T.,.F.) // Aloca a tabela para memoria 
		EndIf

		//BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
		BQC->(DbSetOrder(1))
		If(BQC->(msSeek(xFilial("BQC")+cCodInt+aDados[1][nPosCodEmp][2]+iif(nPosConemp > 0, aDados[1][nPosConemp][2], "")+;
			iif(nPosVerCon > 0, aDados[1][nPosVerCon][2], "")+iif(nPosSubCon > 0, aDados[1][nPosSubCon][2], "")+;
			iif(nPosVersub > 0, aDados[1][nPosVersub][2], ""))))
			RegToMemory("BQC",.F.,.T.,.F.) // Aloca a tabela para memoria 
   		EndIf

		//BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON
		BT5->(DbSetOrder(1))
		If(BT5->(msSeek(xFilial("BT5")+cCodInt+aDados[1][nPosCodEmp][2]+iif(nPosConemp > 0, aDados[1][nPosConemp][2], "")+;
			iif(nPosVerCon > 0, aDados[1][nPosVerCon][2], ""))))
			RegToMemory("BT5",.F.,.T.,.F.) // Aloca a tabela para memoria 
   		EndIf
	
   		//BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, R_E_C_N_O_, D_E_L_E_T_
   		BA3->(DbSetOrder(1))
   		if(BA3->(msSeek(xFilial("BA3")+cCodFam)))
   			cMatric := BA3->BA3_MATRIC
   			BA1->(dbSetOrder(1))
			If BA1->(MsSeek(xFilial("BA1")+cCodInt+aDados[1][nPosCodEmp][2]+cMatric + "T"))
				cMatTit := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO
			EndIf
			BA1->(dbCloseArea())
			RegToMemory("BA3",.F.,.T.,.F.) // Aloca tabela na memoria
   		else
   			lRet := .F.
   		endIf
   		
   	endIf
   
   //------------------------------------------------------------------------
   // Agora inclui o usuario...                                                
   //------------------------------------------------------------------------
   if lRet
   		//ordeno o array para que o titular seja o primeiro a ser incluido
   		if nPosTit > 0
   			aDados := aSort(aDados, , , { |x, y| x[nPosTit][2] > y[nPosTit][2]})
   		endIf
   		
   		for nI := 1 to len(aDados)
   		    
   		    //campos que não dependem do aDados
   			nPosGraupa := aScan(aDados[nI], { |x| x[1] == "BA1_GRAUPA" }) 
			nPosTipusu := aScan(aDados[nI], { |x| x[1] == "BA1_TIPUSU" })
			nPosCodEmp := aScan(aDados[nI], { |x| x[1] == "BA1_CODEMP" }) 
			nPosDatNas := aScan(aDados[nI], { |x| x[1] == "BA1_DATNAS" })            
            
   		    aArea := GetArea()
   			cTipReg := xLSTipReg(cCodInt, aDados[nI][nPosCodEmp][2], cMatric, aDados[nI][nPosGraupa][2], aDados[nI][nPosTipUsu][2] )
   			RestArea(aArea)
   					
   		    if !lRec
   		    	BA1->(dbGoTo(nRecnoBa1))
   		    endIf
			
   			if(lRec) // se RECLOCK true, ou seja se é uma inclusao
   				if(nPosGraupa > 0 .and. nPosTipusu > 0)
					
					RegToMemory("BA1", .T., .F., .T. )
					M->BA1_FILIAL := xFilial("BA1")
   					M->BA1_CODINT := cCodInt
                    M->BA1_CODEMP := BA3->BA3_CODEMP
					M->BA1_CONEMP := BA3->BA3_CONEMP
					M->BA1_VERCON := BA3->BA3_VERCON
					M->BA1_SUBCON := BA3->BA3_SUBCON
					M->BA1_VERSUB := BA3->BA3_VERSUB

					If nI == 1 .And. nPosTit > 0
						M->BA1_CODPLA := BA3->BA3_CODPLA
						M->BA1_VERSAO := BA3->BA3_VERSAO
					Else
						M->BA1_CODPLA := IIF(nPosCodPla > 0, aDados[nI][nPosCodPla][2], BA3->BA3_CODPLA)
   						M->BA1_VERSAO := IIF(nPosVersao > 0, IIF(Empty(aDados[nI][nPosVersao][2]), "001", aDados[nI][nPosVersao][2]), BA3->BA3_VERSAO)
					EndIf

   					M->BA1_MATRIC := cMatric
   					M->BA1_IMAGE  := "ENABLE"
   					M->BA1_TIPREG := cTipReg[1]
  					M->BA1_DIGITO := IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(cCodInt + aDados[nI][nPosCodEmp][2] + cMatric + cTipReg[1])),Modulo11(cCodInt + aDados[nI][nPosCodEmp][2] + cMatric + cTipReg[1]))
   					M->BA1_DATINC := dDataBase
   					M->BA1_DATCAR := dDataBase
   					M->BA1_OPEORI := cCodInt
   					M->BA1_OPEDES := cCodInt
   					M->BA1_OPERES := cCodInt
                    M->BA1_CPFUSR := cCpf 					
   					//BA1->BA1_ORIEND := 
   					M->BA1_LOJFOR := "01" 
   					M->BA1_LOJA   := "01"
   					M->BA1_COBNIV := "0"
   					if(BA3->BA3_TIPOUS == "2")
   						lJuridico := .T.
   						M->BA1_STAEDI := "1"
   						if(BQC->(msSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB))))
   							M->BA1_INFANS := BQC->BQC_INFANS
   							//preciso colocar no if e no else por causa da BQC em pessoa juridica
   							M->BA1_DTVLCR := PL260VLD() 
   						endIf
   					else
   						M->BA1_STAEDI := "4"
   						M->BA1_INFANS := "1"
   						M->BA1_DTVLCR := PL260VLD()
   					endIf
   					M->BA1_FXCOB  := 0  					
   					M->BA1_INFSIB := "1" 
   					M->BA1_USRVIP := "0"
   					M->BA1_INFPRE := "0"
   					M->BA1_INSALU := "0"
   					M->BA1_INTERD := "0"
   					M->BA1_MUDFAI := "1"
   					M->BA1_10ANOS := "0"
					M->BA1_RECNAS := iif(nPosDatNas > 0 .and. dDataBase - aDados[nI][nPosDatNas][2] <= 28, "1", "0")				
					If BA1->(FieldPos("BA1_ORIINC")) > 0
						If lOriInc
							M->BA1_ORIINC := "IncAutoBen"
						Else
							M->BA1_ORIINC := "PLSA977AB" // Origem:Analise de beneficiário 
						EndIf
					EndIf

					for nY := 1 to len(aDados[nI])        		        
						if aDados[nI][nY][1] == "BA1_DATINC"
							if !empty(aDados[nI][nY][2])
								M->BA1_DATINC := aDados[nI][nY][2]
								M->BA1_DATCAR := aDados[nI][nY][2]
							endif
						else
							&("M->" + aDados[nI][nY][1]) :=  aDados[nI][nY][2]
						endif
					next nY

					// Verifica se o cod.municio esta preenchido e o nome do municipio esta em branco
					If !Empty(M->BA1_CODMUN) .AND. Empty(M->BA1_MUNICI)
						BID->(DbSetOrder(1))
						If BID->(MsSeek(xFilial("BID")+M->BA1_CODMUN))
							M->BA1_MUNICI := BID->BID_DESCRI
						EndIf
					EndIf
					
					PLUPTENC("BA1",3)
					
					//classe que pode ser utilizada para gravar as tabelas secundarias do beneficiario
					If FindClass("totvs.protheus.health.plans.beneficiary.secundary.recording.SecondaryTable")
						If !EMPTY(BA1->BA1_CODPLA)
							oSecRec  := totvs.protheus.health.plans.beneficiary.secundary.recording.SecondaryTable():New()

							oSecRec:setParamBeneficiary(BA1->BA1_CODINT,; 
														BA1->BA1_CODPLA,; 
														BA1->BA1_VERSAO,; 
														BA1->BA1_CODEMP,; 
														BA1->BA1_CONEMP,;
														BA1->BA1_VERCON,;
														BA1->BA1_SUBCON,;
														BA1->BA1_VERSUB,; 
														BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),;
														BA1->BA1_DATINC)
						
							//gravacao dos opcionais e tabelas relacionadas aos opcionais no nivel do beneficiario
							oJRetGrfm := oSecRec:recordOptionalCoverages(BA1->BA1_TIPUSU, BA1->BA1_GRAUPA, BA1->BA1_ESTCIV, BA1->BA1_SEXO , BA1->BA1_DATNAS)
							
							oJObjRet  := JsonObject():new()
							oJObjRet["beneficiaryRegister"] := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO
							oJObjRet["resultOptionalAdditions"] := oJRetGrfm
							AADD(aRetOpc, oJObjRet)
						EndIf
					EndIf
				else
   					cMsg := "Para incluir um beneficiário no sistema é necessário informar o código da empresa, o grau de parentesco e o tipo do usuário!"
   				endIf
			else
				BA1->(RecLock("BA1",lRec)) 

				for nY := 1 to len(aDados[nI])                
					&("BA1->" + aDados[nI][nY][1]) :=  aDados[nI][nY][2]                
				next nY
				
				BA1->(MsUnLock())  
			endIf	
   			
   			if(lRec)
   				aadd(aMatrics, BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO)
   				//------------------------------------------------------------------------
   				// Esta funcao analisa a criacao de uma nova vida ou nao...                 
  				//------------------------------------------------------------------------
				If lOriInc
   					PLSA766ANV(.T., Nil)
				Else
					PLSA766ANV()
				endIf
   				//------------------------------------------------------------------------
   				// Grava no usuario a vida criada ou a ja existente...                      
   				//------------------------------------------------------------------------
   				BA1->(RecLock("BA1",.F.))
   					BA1->BA1_MATVID := BTS->BTS_MATVID 
   				BA1->(MsUnLock())
   	   			
   				//como ordenei o array, o titular sera o primeiro a ser inserido
   				if(nI == 1 .AND. nPosTit > 0)
   					cMatTit := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO
   				endIf
   			endIf

   		next nI
   		If lCriaCli
			PlIncCli(cCriaCli, cMatTit)
		EndIf
	endIf

   End Transaction
   
   BA1->(dbCloseArea())
   
Return {lRet, cMatTit, cMsg, aMatrics, aRetOpc} 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadProRata
Retorna os campos de Pro-rata do subcontrato ou produto saúde de acordo 
com o tipo da pessoa (Fisica ou Juridica)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 13/07/2021
/*/
//------------------------------------------------------------------- 
Static Function GetDadProRata(cTipoPessoa, cOperadora, cCodPlano, cVersaoPlano, cCodEmpresa,;
							  cContrato, cVersaoContrato, cSubContrato, cVerSubContrato)

	Local aRetorno := {}
	Local cQuery := ""
	Local cAliasTemp := ""

	Default cOperadora := PlsIntPad()
	Default cCodPlano := ""
	Default cVersaoPlano := ""
	Default cCodEmpresa := ""
	Default cContrato := ""
	Default cVersaoContrato := ""
	Default cSubContrato := ""
	Default cVerSubContrato := ""

	Do Case
		Case cTipoPessoa == "1" // Pessoa Fisica

			cQuery := "SELECT BI3.BI3_COBRAT FROM "+RetSQLName("BI3")+" BI3 "
			cQuery += " WHERE BI3.BI3_FILIAL = '"+xFilial("BI3")+"' "
			cQuery += "   AND BI3.BI3_CODINT = '"+cOperadora+"' "
			cQuery += "   AND BI3.BI3_CODIGO = '"+cCodPlano+"' "
			cQuery += "   AND BI3.BI3_VERSAO = '"+cVersaoPlano+"' "
			cQuery += "   AND BI3.D_E_L_E_T_ = ' ' "
			
			cAliasTemp := GetNextAlias()
			dbUseArea(.T.,"TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

			If !(cAliasTemp)->(Eof())
				aAdd(aRetorno, (cAliasTemp)->BI3_COBRAT)
			EndIf

			(cAliasTemp)->(DbCloseArea())

		Case cTipoPessoa == "2" // Pessoa Juridica

			cQuery := "SELECT BQC.BQC_COBRAT,BQC.BQC_COBRET,BQC.BQC_DIARET FROM "+RetSQLName("BQC")+" BQC "
			cQuery += "	WHERE BQC.BQC_FILIAL = '"+xFilial("BQC")+"' "
			cQuery += "   AND BQC.BQC_CODIGO = '"+cOperadora+cCodEmpresa+"' "
			cQuery += "   AND BQC.BQC_NUMCON = '"+cContrato+"' "
			cQuery += "   AND BQC.BQC_VERCON = '"+cVersaoContrato+"' "
			cQuery += "   AND BQC.BQC_SUBCON = '"+cSubContrato+"' "
			cQuery += "   AND BQC.BQC_VERSUB = '"+cVerSubContrato+"' "
			cQuery += "   AND BQC.D_E_L_E_T_ = ' ' "

			cAliasTemp := GetNextAlias()
			dbUseArea(.T.,"TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

			If !(cAliasTemp)->(Eof())
				aAdd(aRetorno, (cAliasTemp)->BQC_COBRAT)
				aAdd(aRetorno, (cAliasTemp)->BQC_COBRET)
				aAdd(aRetorno, (cAliasTemp)->BQC_DIARET)
			EndIf

			(cAliasTemp)->(DbCloseArea())
	EndCase
		
Return aRetorno

/*/{Protheus.doc} PLConCli
Consulta se existe em algum nivel cliente cadastrado - Empresa/Contrato/Subcontrato
@type  Static Function
@author gabriela.cattin
@since 15/04/2025
@version 12.1.2410
@param lPesJur - Pessoa Juridica, cSubCon - Numero do Subcontrato, aVerSub - Numero da versão do subcontrato 
@return se tem registros conforme a query
/*/
Static Function PLConCli(lPesJur, cSubCon, cVerSub)
Local lRet := .F.
local nTotal := 0 
local cQuery 
local oExecStmt 
local nOrder := 1

Default lPesJur := .F.
Default cSubCon := ""
Default cVerSub := ""

cQuery := " SELECT COUNT(?) TOTAL "
cQuery += " FROM ? BG9 "
cQuery += " INNER JOIN ? BT5 "
cQuery += " ON BG9.BG9_FILIAL = ? "
cQuery += " AND BT5.BT5_FILIAL = ? "
cQuery += " AND BT5.BT5_CODINT = BG9.BG9_CODINT "
cQuery += " AND BT5.BT5_CODIGO = BG9.BG9_CODIGO "
cQuery += " INNER JOIN ? BQC "
cQuery += " ON BQC.BQC_FILIAL = ? "
cQuery += " AND BQC.BQC_CODINT = ? "
cQuery += " AND BQC.BQC_CODEMP = ? "
cQuery += " AND BQC.BQC_NUMCON = ? "
cQuery += " AND BQC.BQC_VERCON = ? "
cQuery += " AND BQC.BQC_SUBCON = ? "
cQuery += " AND BQC.BQC_VERSUB = ? "
cQuery += " WHERE "
cQuery += " BQC.BQC_COBNIV <> ? "
cQuery += " AND BT5.BT5_COBNIV <> ? "
cQuery += " AND BG9.BG9_CODCLI <> ? "
cQuery += " AND BG9.D_E_L_E_T_ = ? "
cQuery += " AND BT5.D_E_L_E_T_ = ? "
cQuery += " AND BQC.D_E_L_E_T_ = ? "

oExecStmt := FwExecStatement():new(cQuery)

oExecStmt:setUnsafe(nOrder++,'*')
oExecStmt:setUnsafe(nOrder++, retSqlName("BG9"))
oExecStmt:setUnsafe(nOrder++, retSqlName("BT5"))
oExecStmt:setString(nOrder++, xFilial("BG9"))
oExecStmt:setString(nOrder++, xFilial("BT5"))
oExecStmt:setUnsafe(nOrder++, retSqlName("BQC"))
oExecStmt:setString(nOrder++, xFilial("BQC"))
oExecStmt:setUnsafe(nOrder++, "BT5.BT5_CODINT")
oExecStmt:setUnsafe(nOrder++, "BT5.BT5_CODIGO")
oExecStmt:setUnsafe(nOrder++, "BT5.BT5_NUMCON")
oExecStmt:setUnsafe(nOrder++, "BT5.BT5_VERSAO")
oExecStmt:setString(nOrder++, cSubCon)
oExecStmt:setString(nOrder++, cVerSub)
oExecStmt:setString(nOrder++, "1")
oExecStmt:setString(nOrder++, "1")
oExecStmt:setString(nOrder++, " ")
oExecStmt:setString(nOrder++, " ")
oExecStmt:setString(nOrder++, " ")
oExecStmt:setString(nOrder++, " ")

nTotal := oExecStmt:execScalar("TOTAL")

freeObj(oExecStmt)

lRet := nTotal == 0	

Return lRet


/*/{Protheus.doc} PLIncCli
Inclusão de um Cliente na SA1
@type  Function
@author gabriela.cattin
@since 15/04/2025
@version 12.1.2410
/*/
Static Function PLIncCli(cCriaCli,cMatTit)
Local cCpf := ""
Local cVlCod := ""
Local cVlLoj := ""
Local cCodSa1 := ""
Local cLojSa1 := ""

Default cCriaCli := "0"
Default cMatTit := ""

If cCriaCli == "1"
	BA1->(dbSetorder(2))
	BBL->(dbSetorder(2))
	If BA1->(MsSeek(xFilial("BA1")+cMatTit))
		if BBL->(MsSeek(xFilial("BBL")+"PLSA260   "+"BA1"+"SA1"))

			BA1->(dbGoto(BA1->(Recno())))

			SA1->(dbSetorder(03) )
			if !SA1->( MsSeek(xFilial("SA1")+BA1->BA1_CPFUSR) )
				SA1->(RecLock("SA1",.T.))
				SA1->A1_FILIAL := xFilial("SA1")
				cVlCod         := CriaVar("A1_COD")
				cVlLoj         := CriaVar("A1_LOJA")
				cCodSa1        := If(!Empty(cVlCod),cVlCod,GetSX8Num("SA1","A1_COD"))
				cLojSa1        := If(!Empty(cVlLoj),cVlLoj,StrZero(1,TamSx3("A1_LOJA")[1]))
				SA1->A1_COD    := cCodSA1
				SA1->A1_LOJA   := cLojSA1
				SA1->A1_TIPO   := "F"

				PlsSinc("PLSA260","BA1","SA1",NIL,.T.,BA1->(RECNO()),NIL,NIL,SA1->(RECNO()))
				SA1->(MsUnLock())
				ConfirmSX8()

			else
				cCodSa1 := SA1->A1_COD
				cLojSa1 := SA1->A1_LOJA
			endIf

			BA3->(RecLock("BA3",.F.))
			BA3->BA3_CODCLI := cCodSA1
			BA3->BA3_LOJA := cLojSA1
			BA3->(MsUnlock())
		EndIf
	EndIf
EndIf

Return 
