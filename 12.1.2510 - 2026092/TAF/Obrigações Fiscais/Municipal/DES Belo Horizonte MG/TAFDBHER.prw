#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDBHER 

Esta rotina tem como objetivo a geração dos documentos fiscais de serviço da
DES - Belo Horizonte MG

@Author joao.spieker
@Since 19/09/2017
@Version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFDBHE(aWizard)

	Local cTxtSys    as char
	Local nHandle    as Numeric
	Local cStrTxt    as char	
	Local cReg		 as char
	Local cIdentific as char
	Local dDatEmis   as date
	Local nTribut    as numeric
	Local cSubitem   as char
	Local cModDoc    as char
	Local cCodMod    as char
	Local nSerieDoc  as numeric
	Local nSubsDoc   as numeric
	Local nTipNeg    as numeric
	Local nExigISSQN as numeric
	Local nLocIncid  as numeric
	Local nRegEspTrb as numeric
	Local nTRecISSQN as numeric
	Local nNumDoc	 as numeric
	Local cNumFin	 as char
	Local nValBruto  as numeric
	Local nValServ	 as numeric
	Local nAliq		 as numeric
	Local nSitDoc	 as numeric
	Local nSimpNac	 as numeric
	Local nInsMunTom as numeric
	Local nCNPJTom	 as numeric
	Local nCPFTom	 as numeric
	Local cNomeTom 	 as char
	Local cLogradTom as char
	Local nNumImoTom as numeric
	Local cComplTom	 as char
	Local cBairroTom as char
	Local nCidadeTom as numeric
	Local nPaisTom 	 as numeric
	Local nCEPTom	 as numeric
	Local nTelTom 	 as numeric
	Local cEmailTom	 as char
	Local nCNPJTer	 as numeric
	Local nCPFTer	 as numeric
	Local cNomeTer 	 as char
	Local cLogradTer as char
	Local nNumImoTer as numeric
	Local cComplTer	 as char
	Local cBairroTer as char
	Local nCidadeTer as numeric
	Local nPaisTer 	 as numeric
	Local nCEPTer	 as numeric
	Local nTelTer 	 as numeric
	Local cEmailTer	 as char
	Local nInsMunTer as numeric
	Local nLocPrest	 as numeric
	Local nPaisPrest as numeric
	Local cDescEvent as char
	Local dDatEvent  as date
	Local dDatCompet as date
	Local dDatCancel as date
	Local nMotCancel as numeric
	Local cOutMot	 as char
	Local nNotSubs	 as numeric	
	Local nAuxCid    as numeric
	Local nAuxEst    as numeric
	Local nIdUf      as numeric


	
     cAliasDoc  := GetNextAlias()
	 cReg		:= "DBH_E"
	 cIdentific	:= "E"
	 dDatEmis   := "" 
	 nTribut    := 0
	 cSubitem   := ""
	 cModDoc    := ""
	 nSerieDoc  := 0
	 nSubsDoc   := 0
	 nTipNeg    := 0
	 nExigISSQN := 0
	 nLocIncid  := 0
	 nRegEspTrb := 0
	 nTRecISSQN := 0
	 nNumDoc	:= 0
	 cNumFin	:= ""
	 nValBruto  := 0
	 nValServ	:= 0
	 nAliq		:= 0
	 nSitDoc	:= 0
	 nSimpNac	:= 0
	 nInsMunTom := 0
	 nCNPJTom	:= 0
	 nCPFTom	:= 0
	 cNomeTom 	:= ""
	 cLogradTom := ""
	 nNumImoTom := 0
	 cComplTom	:= ""
	 cBairroTom := ""
	 nCidadeTom := 0
	 nPaisTom 	:= 1058
	 nCEPTom	:= 0
	 nTelTom 	:= 0
	 cEmailTom	:= ""
	 nCNPJTer	:= 0
	 nCPFTer	:= 0
	 cNomeTer 	:= ""
	 cLogradTer := ""
	 nNumImoTer := 0
	 cComplTer	:= ""
	 cBairroTer := ""
	 nCidadeTer := 0
	 nPaisTer 	:= 0
	 nCEPTer	:= 0
	 nTelTer 	:= 0
	 cEmailTer	:= ""
	 nInsMunTer := 0
	 nLocPrest	:= 0
	 nPaisPrest := 1058
	 cDescEvent := ""
	 dDatEvent  := ""
	 dDatCompet := ""
	 dDatCancel := ""
	 nMotCancel := 0
	 cOutMot	:= ""
	 nNotSubs	:= 0
	 cTxtSys    := CriaTrab( , .F. ) + ".txt"
	 nHandle    := MsFCreate( cTxtSys )
	 dDatIni    := aWizard[1][1]  
	 dDatFim    := aWizard[1][2] 	 
	 
	 Begin Sequence
	 
		BeginSql  Alias cAliasDoc
		
		   SELECT C20.C20_NUMDOC  C20_NUMDOC,
		          C20.C20_SERIE   C20_SERIE, 
		          C20.C20_SUBSER  C20_SUBSER,
		          C20.C20_DTDOC   C20_DTDOC,
		          C01.C01_CODIGO  C01_CODIGO,
		          C20.C20_VLDOC   C20_VLDOC,
		          C20.C20_CODLOC  C20_CODLOC,
		          C20.C20_DTCANC  C20_DTCANC,		          	
		          C1H.C1H_CTISS   C1H_CTISS,          
		          C3S.C3S_CODIGO  C3S_CODIGO,		          
		          C35.C35_VALOR   C35_VALOR,
		          C35.C35_ALIQ    C35_ALIQ,
		          C02.C02_CODIGO  C02_CODIGO,
		          C1H.C1H_SIMPLS  C1H_SIMPLS,
		          C1H.C1H_IM      C1H_IM,
		          C1H.C1H_CNPJ    C1H_CNPJ,		          
		          C1H.C1H_CPF     C1H_CPF,
		          C1H.C1H_NOME    C1H_NOME,
		          C1H.C1H_END     C1H_END,
		          C1H.C1H_NUM     C1H_NUM,
		          C1H.C1H_COMPL   C1H_COMPL,
		          C1H.C1H_BAIRRO  C1H_BAIRRO,
		          C1H.C1H_CODMUN  C1H_CODMUN,
		          C1H.C1H_CEP     C1H_CEP,
		          C1H.C1H_DDD     C1H_DDD,
		          C1H.C1H_FONE    C1H_FONE,  
		          C1H.C1H_EMAIL   C1H_EMAIL,
		          C0B.C0B_CODIGO  C0B_CODIGO,
		          C1L.C1L_CODSER  C1L_CODSER,
		          C1N.C1N_IDREG   C1N_IDREG,
		          C1N.C1N_IDTIPO  C1N_IDTIPO,
		          C1N.C1N_IDEXIG  C1N_IDEXIG,
		          C07.C07_CODIGO  C07_CODIGO,
		          C09.C09_CODUF   C09_CODUF   		             		                    		 	          		                          		                    
		   	 FROM %table:C20% C20 
			   	 INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID     AND C1H.%NotDel%  	  
			   	 INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%  AND C20.C20_TPDOC  = C0U.C0U_ID     AND C0U.%NotDel%  
			   	 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
			   	 INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel% 
			   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%			   	 	   	  	
			   	 INNER JOIN %table:C02% C02 ON C02.C02_FILIAL =  %xFilial:C02% AND C20.C20_CODSIT = C02.C02_ID     AND C02.%NotDel% 	
			   	 INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL =  %xFilial:C1L% AND C1L.C1L_ID     = C30.C30_CODITE AND C1L.%NotDel%	   	
			   	 INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL =  %xFilial:C1N% AND C1N.C1N_ID     = C30.C30_NATOPE AND C1N.C1N_IDTIPO != "" AND C1N.C1N_IDEXIG != "" AND C1N.C1N_IDREG != "" AND C1N.C1N_CTISS != "" AND C1N.%NotDel%   			   	 
			   	 INNER JOIN %table:C01% C01 ON C01.C01_FILIAL =  %xFilial:C01% AND C01.C01_ID     = C20.C20_CODMOD AND C01.%NotDel%
			   	 INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%
			   	 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C07_UF         AND C09.%NotDel%
			   	 LEFT JOIN  %table:C0B%  C0B ON C0B.C0B_FILIAL =  %xFilial:C0B% AND C0B.C0B_ID     = C30.C30_CODSER AND C0B.%NotDel%			   	 		   	     	    	   	  		   	 
	        WHERE C20.C20_FILIAL = %xFilial:C20%
	          AND C20.C20_INDOPE = '1'
			  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
			  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido			  
			  AND C20.%NotDel%			  		  
			GROUP BY C20.C20_NUMDOC, 
					 C20.C20_SERIE , 
					 C20.C20_SUBSER, 
					 C20.C20_DTDOC , 
					 C01.C01_CODIGO, 
					 C20.C20_VLDOC , 
					 C20.C20_CODLOC, 
					 C20.C20_DTCANC,
					 C1H.C1H_CTISS ,					 				 
					 C3S.C3S_CODIGO, 
					 C35.C35_VALOR , 
					 C35.C35_ALIQ  , 
					 C02.C02_CODIGO, 
					 C1H.C1H_SIMPLS, 
					 C1H.C1H_IM    , 
					 C1H.C1H_CNPJ  , 
					 C1H.C1H_CPF   , 
					 C1H.C1H_NOME  , 
					 C1H.C1H_END   , 
					 C1H.C1H_NUM   , 
					 C1H.C1H_COMPL , 
					 C1H.C1H_BAIRRO, 
					 C1H.C1H_CODMUN, 
					 C1H.C1H_CEP   , 
					 C1H.C1H_DDD   , 
					 C1H.C1H_FONE  , 
					 C1H.C1H_EMAIL ,
					 C0B.C0B_CODIGO,
		             C1L.C1L_CODSER,
		             C1N.C1N_IDREG ,
		             C1N.C1N_IDTIPO,
		             C1N.C1N_IDEXIG,
		             C07.C07_CODIGO,
		             C09.C09_CODUF   					             
		     ORDER BY C20.C20_NUMDOC		 					 			 
		EndSql			
			
        While (cAliasDoc)->(!Eof())	 
	  		
	  		dDatEmis   := (cAliasDoc)->C20_DTDOC  
			cModDoc    := (cAliasDoc)->C01_CODIGO  
			nSubsDoc   := (cAliasDoc)->C20_SUBSER			 
			nLocIncid  := (cAliasDoc)->C09_CODUF + Substr((cAliasDoc)->C07_CODIGO,2,5)
			nTRecISSQN := (cAliasDoc)->C3S_CODIGO 
			nNumDoc	   := (cAliasDoc)->C20_NUMDOC 
			nValBruto  := (cAliasDoc)->C20_VLDOC  
			nValServ   := (cAliasDoc)->C35_VALOR  
			nAliq	   := (cAliasDoc)->C35_ALIQ
			nInsMunTom := (cAliasDoc)->C1H_IM     
			nCNPJTom   := (cAliasDoc)->C1H_CNPJ   
			nCPFTom	   := (cAliasDoc)->C1H_CPF    
			cNomeTom   := (cAliasDoc)->C1H_NOME   
			cLogradTom := (cAliasDoc)->C1H_END    
			nNumImoTom := (cAliasDoc)->C1H_NUM    
			cComplTom  := (cAliasDoc)->C1H_COMPL  
			cBairroTom := (cAliasDoc)->C1H_BAIRRO 
			nCidadeTom := (cAliasDoc)->C1H_CODMUN	
			nCEPTom	   := (cAliasDoc)->C1H_CEP			          
			cEmailTom  := (cAliasDoc)->C1H_EMAIL		
			nLocPrest  := (cAliasDoc)->C20_CODLOC			           
			dDatCompet := (cAliasDoc)->C20_DTDOC  
			dDatCancel := (cAliasDoc)->C20_DTCANC		
			nTribut    := (cAliasDoc)->C1H_CTISS	
			cSubitem   := (cAliasDoc)->C0B_CODIGO 
			
			
			nTelTom    := Alltrim((cAliasDoc)->C1H_DDD) + (cAliasDoc)->C1H_FONE 
			
			//Modelo do Documento Fiscal
			If(cModDoc == "1A")
			   cCodMod := "9"
			Elseif(cModDoc == "07")
			   cCodMod := "11"
			Elseif(cModDoc == "22")
			   cCodMod := "26"
			Elseif(cModDoc == "55")
			   cCodMod := "14"
			Elseif(cModDoc == "67")
			   cCodMod := "5"
			Elseif(cModDoc == "57")
			   cCodMod := "25"
			Else
			   cCodMod := "1"			           
	  		EndIf	  		
	  		
	  		// Tipo de Recolhimento
	  		If((cAliasDoc)->C3S_CODIGO == "01")
	  		   nTRecISSQN := 2
	  		Else
	  		   nTRecISSQN := 1	  		   
	  		EndIf
	  		
	  		// Situação do Documento	  		
	  		If((cAliasDoc)->C02_CODIGO == "00")  
	  		   nSitDoc := 1
	  		Elseif((cAliasDoc)->C02_CODIGO == "02")
	  		   nSitDoc := 2
	  		Elseif((cAliasDoc)->C02_CODIGO == "01")
	  		   nSitDoc := 4    	 
	  		EndIf
	  		
	  		If((cAliasDoc)->C1H_SIMPLS == "1")
	  		   nSimpNac   := 3
	  		Else
	  		   nSimpNac   := 2
	  		EndIf
	  		
	  		If(Empty(cSubitem))
	  		    cSubitem := POSICIONE("C0B",3,xFilial("C0B")+(cAliasDoc)->C1L_CODSER,"C0B_CODIGO") 
	  		Endif
	  		
	  		nTipNeg    := POSICIONE("T83",1,xFilial("T83")+(cAliasDoc)->C1N_IDTIPO,"T83_CODIGO")
	  		nExigISSQN := POSICIONE("T85",1,xFilial("T85")+(cAliasDoc)->C1N_IDEXIG,"T85_CODIGO")
	  		nRegEspTrb := POSICIONE("T82",1,xFilial("T82")+(cAliasDoc)->C1N_IDREG,"T82_CODIGO")
	  		
	  		if(Alltrim((cAliasDoc)->C20_SERIE) != "")
	  			nSerieDoc := DESSerie((cAliasDoc)->C20_SERIE)
	  	    endif
	  	    
	  	    nAuxCid := POSICIONE("C07",3,xFilial("C07")+(cAliasDoc)->C20_CODLOC,"C07_CODIGO")    
	  	    nIdUf   := POSICIONE("C07",3,xFilial("C07")+(cAliasDoc)->C20_CODLOC,"C07_UF")
	        nAuxEst := POSICIONE("C09",3,xFilial("C09")+nIdUf,"C09_CODUF")
	        
	        nLocPrest := nAuxEst + Substr(nAuxCid,2,5)
	  	    	
			//Carrega a varíavel cStrTxt para geração do arquivo 
			cStrTxt := Alltrim(cIdentific)  + "|"  	// Indicador do Tipo do Layout
			cStrTxt += Alltrim(dDatEmis)	+ "|"	// Data de Emissão
			cStrTxt += Alltrim(nTribut)		+ "|"	// Codigo de Tributação no Muinicípio
			cStrTxt += Alltrim(cSubitem)    + "|"	// Código Subitem da Lista de Serviço
			cStrTxt += Alltrim(cCodMod)		+ "|"	// Modelo do Documento
			cStrTxt += cValToChar(nSerieDoc)	+ "|"	// Série do Documento
			cStrTxt += Alltrim(nSubsDoc)	+ "|"	// Subsérie do Documento
			cStrTxt += Alltrim(cValToChar(nTipNeg))		+ "|"	// Tipo de Negócio
			cStrTxt += Alltrim(cValToChar(nExigISSQN))	+ "|"	// Exigibilidade do ISSQN
			cStrTxt += cValToChar(nLocIncid)	+ "|"	// Local de Incidência
			cStrTxt += Alltrim(cValToChar(nRegEspTrb))	+ "|"	// Regime Especial de Tributação
			cStrTxt += cValToChar(nTRecISSQN)	+ "|"	// Tipo de Recolhimento do ISSQN
			cStrTxt += Alltrim(cValToChar(nNumDoc))		+ "|"	// Número do Documento
			cStrTxt += Alltrim(cNumFin)		+ "|"	// Número Final
			cStrTxt += Alltrim(cValToChar(nValBruto))	+ "|"	// Valor Bruto
			cStrTxt += Alltrim(cValToChar(nValServ))	+ "|"	// Valor do Serviço
			cStrTxt += Alltrim(cValToChar(nAliq))		+ "|"	// Alíquota
			cStrTxt += Alltrim(cValToChar(nSitDoc))		+ "|"	// Situação do Documento
			cStrTxt += Alltrim(cValToChar(nSimpNac))	+ "|"	// Simples Nacional
			cStrTxt += Alltrim(cValToChar(nInsMunTom))	+ "|"	// Inscrição Municipal do tomador
			cStrTxt += Alltrim(cValToChar(nCNPJTom))	+ "|"	// CNPJ do tomador
			cStrTxt += Alltrim(cValToChar(nCPFTom))		+ "|"	// CPF do tomador
			cStrTxt += Alltrim(cNomeTom)	+ "|"	// Nome do tomador
			cStrTxt += Alltrim(cLogradTom)	+ "|"	// Logradouro do tomador
			cStrTxt += Alltrim(cValToChar(nNumImoTom))	+ "|"	// Número do Imóvel do tomador
			cStrTxt += Alltrim(cComplTom)	+ "|"	// Complemento do tomador
			cStrTxt += Alltrim(cBairroTom)	+ "|"	// Bairro do tomador
			cStrTxt += Alltrim(cValToChar(nLocIncid))	+ "|"	// Cidade do tomador
			cStrTxt += Alltrim(cValToChar(nPaisTom))	+ "|"	// País do tomador
			cStrTxt += Alltrim(cValToChar(nCEPTom))		+ "|"	// CEP do tomador
			cStrTxt += Alltrim(cValToChar(nTelTom))		+ "|"	// Telefone do tomador
			cStrTxt += Alltrim(cEmailTom)	+ "|"	// E-mail do tomador
			cStrTxt += Alltrim(nInsMunTer)	+ "|"	// Inscrição Municipal do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(nCNPJTer)	+ "|"	// CNPJ do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(nCPFTer)		+ "|"	// CPF do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(cNomeTer)	+ "|"	// Nome do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(cLogradTer)	+ "|"	// Logradouro do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(nNumImoTer)	+ "|"	// Número do Imóvel do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(cComplTer)	+ "|"	// Complemento do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(cBairroTer)	+ "|"	// Bairro do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(nCidadeTer)	+ "|"	// Cidade do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(nPaisTer)	+ "|"	// País do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(nCEPTer)		+ "|"	// CEP do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(nTelTer)		+ "|"	// Telefone do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(cEmailTer)	+ "|"	// E-mail do Terceiro vinculado/Intermediário
			cStrTxt += Alltrim(cValToChar(nLocPrest))	+ "|"	// Local de Prestação
			cStrTxt += Alltrim(cValToChar(nPaisPrest))	+ "|"	// País da prestação dos serviços
			cStrTxt += Alltrim(cDescEvent)	+ "|"	// Descrição do Evento
			cStrTxt += Alltrim(dDatEvent)	+ "|"	// Data do Evento
			cStrTxt += Alltrim(dDatCompet)	+ "|"	// Data de Competência
			cStrTxt += Alltrim(dDatCancel)	+ "|"	// Data de Cancelamento
			cStrTxt += Alltrim(nMotCancel)	+ "|"	// Motivo de Cancelamento
			cStrTxt += Alltrim(cOutMot)		+ "|"	// Outro Motivo de Cancelamento
			cStrTxt += Alltrim(nNotSubs)			// Número da Nota Substituidora			
			
			cStrTxt += CRLF 
		        
    	    WrtStrTxt( nHandle, cStrTxt )
    	     	    	
	    
	        (cAliasDoc)->(DbSkip()) 
	    EndDO
	    
    	    GerTxtDBH( nHandle, cTxtSys, cReg )
	 
    	    Recover
	
    	    lFound := .F.
    	    
 	End Sequence	
					
Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDBHR 

Esta rotina tem como objetivo a geração dos documentos fiscais de serviço da
DES - Belo Horizonte MG


@Author joao.spieker
@Since 11/10/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------

Function TAFDBHR(aWizard)

	Local cTxtSys    as char
	Local nHandle    as Numeric
	Local cStrTxt   as char
	
	Local cReg		 as char
	Local cIdentific as char
	Local dDatPgto 	 as date
	Local dDatEmis   as date
	Local nModDoc    as numeric
	Local nSerieDoc  as numeric
	Local nSubsDoc   as numeric
	Local nSitEspRsp as numeric
	Local nMotNaoRet as numeric
	Local nLocIncid  as numeric
	Local nTRecISSQN as numeric
	Local nNumDoc	 as numeric
	Local nValBruto  as numeric
	Local nValServ	 as numeric
	Local nAliq		 as numeric
	Local nSimpNac	 as numeric
	Local nInsMunPre as numeric
	Local nCNPJPre	 as numeric
	Local nCPFPre	 as numeric
	Local cNomePre 	 as char
	Local cLogradPre as char
	Local nNumImoPre as numeric
	Local cComplPre	 as char
	Local cBairroPre as char
	Local nCidadePre as numeric
	Local nPaisPre 	 as numeric
	Local nCEPPre	 as numeric
	Local nTelPre 	 as numeric
	Local cEmailPre	 as char
	Local nInsMunTom as numeric
	Local nCNPJTom	 as numeric
	Local nCPFTom	 as numeric
	Local cNomeTom 	 as char
	Local cLogradTom as char
	Local nNumImoTom as numeric
	Local cComplTom	 as char
	Local cBairroTom as char
	Local nCidadeTom as numeric
	Local nPaisTom 	 as numeric
	Local nCEPTom	 as numeric
	Local nTelTom 	 as numeric
	Local cEmailTom	 as char
	Local nLocPrest	 as numeric
	Local nPaisPrest as numeric
	Local cDescEvent as char
	Local dDatEvent  as date
	Local nAuxCid    as numeric
	Local nAuxEst    as numeric
	Local nIdUf      as numeric

     cAliasRec  := GetNextAlias()
	 cReg		:= "DBH_R"
	 cIdentific := "R"
	 dDatPgto 	:= ""
	 dDatEmis   := ""
	 nModDoc    := 0
	 nSerieDoc  := 0
	 nSubsDoc   := 0
	 nSitEspRsp := 0
	 nMotNaoRet := 0
	 nLocIncid  := 0
	 nTRecISSQN := 0
	 nNumDoc	:= 0
	 nValBruto  := 0
	 nValServ	:= 0
	 nAliq		:= 0
	 nSimpNac	:= 0
	 nInsMunPre := 0
	 nCNPJPre	:= 0
	 nCPFPre	:= 0
	 cNomePre 	:= ""
	 cLogradPre := ""
	 nNumImoPre := 0
	 cComplPre	:= ""
	 cBairroPre := ""
	 nCidadePre := 0
	 nPaisPre 	:= 1058
	 nCEPPre	:= 0
	 nTelPre 	:= 0
	 cEmailPre	:= "" 
	 cEmailTom	:= ""
	 nLocPrest	:= 0
	 nPaisPrest := 1058
	 cDescEvent := ""
	 dDatEvent  := ""
	 cTxtSys    := CriaTrab( , .F. ) + ".txt"
	 nHandle    := MsFCreate( cTxtSys )
	 dDatIni    := aWizard[1][1]  
	 dDatFim    := aWizard[1][2] 
   
	 Begin Sequence 
	 
	 BeginSql  Alias cAliasRec
		
		   SELECT C20.C20_NUMDOC  C20_NUMDOC,
		          C20.C20_SERIE   C20_SERIE, 
		          C20.C20_SUBSER  C20_SUBSER,
		          C20.C20_DTDOC   C20_DTDOC,
		          C01.C01_CODIGO  C01_CODIGO,
		          C20.C20_VLDOC   C20_VLDOC,
		          C20.C20_CODLOC  C20_CODLOC,
		          C20.C20_DTCANC  C20_DTCANC,                  
		          C3S.C3S_CODIGO  C3S_CODIGO,		          
		          C35.C35_VALOR   C35_VALOR,
		          C35.C35_ALIQ    C35_ALIQ,
		          C02.C02_CODIGO  C02_CODIGO,
		          C1H.C1H_SIMPLS  C1H_SIMPLS,
		          C1H.C1H_IM      C1H_IM,
		          C1H.C1H_CNPJ    C1H_CNPJ,		          
		          C1H.C1H_CPF     C1H_CPF,
		          C1H.C1H_NOME    C1H_NOME,
		          C1H.C1H_END     C1H_END,
		          C1H.C1H_NUM     C1H_NUM,
		          C1H.C1H_COMPL   C1H_COMPL,
		          C1H.C1H_BAIRRO  C1H_BAIRRO,
		          C1H.C1H_CODMUN  C1H_CODMUN,
		          C1H.C1H_CEP     C1H_CEP,
		          C1H.C1H_DDD     C1H_DDD,
		          C1H.C1H_FONE    C1H_FONE,  
		          C1H.C1H_EMAIL   C1H_EMAIL,
		          C0B.C0B_CODIGO  C0B_CODIGO,		          
		          C1N.C1N_IDSIT   C1N_IDSIT,
		          C1N.C1N_IDMOT  C1N_IDMOT,		          
		          C07.C07_CODIGO  C07_CODIGO,
		          C09.C09_CODUF   C09_CODUF   		             		                    		 	          		                          		                    
		   	 FROM %table:C20% C20 
			   	 INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID     AND C1H.%NotDel%  	  
			   	 INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%  AND C20.C20_TPDOC  = C0U.C0U_ID     AND C0U.%NotDel%  
			   	 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
			   	 INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel% 
			   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%			   	 	   	  	
			   	 INNER JOIN %table:C02% C02 ON C02.C02_FILIAL =  %xFilial:C02% AND C20.C20_CODSIT = C02.C02_ID     AND C02.%NotDel%	   	 	   	
			   	 INNER JOIN %table:C1N% C1N ON C1N.C1N_FILIAL =  %xFilial:C1N% AND C1N.C1N_ID     = C30.C30_NATOPE AND C1N.C1N_IDSIT != ""  AND C1N.C1N_IDMOT != "" AND C1N.%NotDel%
			   	 INNER JOIN %table:C01% C01 ON C01.C01_FILIAL =  %xFilial:C01% AND C01.C01_ID     = C20.C20_CODMOD AND C01.%NotDel%
			   	 INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%
			   	 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C07_UF         AND C09.%NotDel%
			   	 LEFT JOIN  %table:C0B%  C0B ON C0B.C0B_FILIAL =  %xFilial:C0B% AND C0B.C0B_ID     = C30.C30_CODSER AND C0B.%NotDel%			   	 		   	     	    	   	  		   	 
	        WHERE C20.C20_FILIAL = %xFilial:C20%
	          AND C20.C20_INDOPE = '0'
			  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
			  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido			  
			  AND C20.%NotDel%			  		  
			GROUP BY C20.C20_NUMDOC, 
					 C20.C20_SERIE , 
					 C20.C20_SUBSER, 
					 C20.C20_DTDOC , 
					 C01.C01_CODIGO, 
					 C20.C20_VLDOC , 
					 C20.C20_CODLOC, 
					 C20.C20_DTCANC,					 					 				 
					 C3S.C3S_CODIGO, 
					 C35.C35_VALOR , 
					 C35.C35_ALIQ  , 
					 C02.C02_CODIGO, 
					 C1H.C1H_SIMPLS, 
					 C1H.C1H_IM    , 
					 C1H.C1H_CNPJ  , 
					 C1H.C1H_CPF   , 
					 C1H.C1H_NOME  , 
					 C1H.C1H_END   , 
					 C1H.C1H_NUM   , 
					 C1H.C1H_COMPL , 
					 C1H.C1H_BAIRRO, 
					 C1H.C1H_CODMUN, 
					 C1H.C1H_CEP   , 
					 C1H.C1H_DDD   , 
					 C1H.C1H_FONE  , 
					 C1H.C1H_EMAIL ,
					 C0B.C0B_CODIGO,		             
		             C1N.C1N_IDSIT ,
		             C1N.C1N_IDMOT ,
		             C07.C07_CODIGO,
		             C09.C09_CODUF   					             
		     ORDER BY C20.C20_NUMDOC		 					 			 
		EndSql			
			
        While (cAliasRec)->(!Eof())	 
	  		
	  		dDatEmis   := (cAliasRec)->C20_DTDOC  
	  		dDatPgto   := (cAliasRec)->C20_DTDOC
			cModDoc    := (cAliasRec)->C01_CODIGO  
			nSubsDoc   := (cAliasRec)->C20_SUBSER			 
			nLocIncid  := (cAliasRec)->C09_CODUF + Substr((cAliasRec)->C07_CODIGO,2,5)
			nInsMunPre := (cAliasRec)->C1H_IM  
			nTRecISSQN := (cAliasRec)->C3S_CODIGO 
			nNumDoc	   := (cAliasRec)->C20_NUMDOC 
			nValBruto  := (cAliasRec)->C20_VLDOC  
			nValServ   := (cAliasRec)->C35_VALOR  
			nAliq	   := (cAliasRec)->C35_ALIQ			     
			nCNPJPre   := (cAliasRec)->C1H_CNPJ   
			nCPFPre	   := (cAliasRec)->C1H_CPF    
			cNomePre   := (cAliasRec)->C1H_NOME   
			cLogradPre := (cAliasRec)->C1H_END    
			nNumImoPre := (cAliasRec)->C1H_NUM    
			cComplPre  := (cAliasRec)->C1H_COMPL  
			cBairroPre := (cAliasRec)->C1H_BAIRRO 
			nCidadePre := (cAliasRec)->C1H_CODMUN	
			nCEPPre	   := (cAliasRec)->C1H_CEP			          
			cEmailPre  := (cAliasRec)->C1H_EMAIL		
			nLocPrest  := (cAliasRec)->C20_CODLOC			           
			dDatCompet := (cAliasRec)->C20_DTDOC  
			dDatCancel := (cAliasRec)->C20_DTCANC		
			cSubitem   := (cAliasRec)->C0B_CODIGO			
			
			nTelPre    := Alltrim((cAliasRec)->C1H_DDD) + (cAliasRec)->C1H_FONE 
			
			//Modelo do Documento Fiscal
			If(cModDoc == "1A")
			   cCodMod := "9"
			Elseif(cModDoc == "07")
			   cCodMod := "11"
			Elseif(cModDoc == "22")
			   cCodMod := "26"
			Elseif(cModDoc == "55")
			   cCodMod := "14"
			Elseif(cModDoc == "67")
			   cCodMod := "5"
			Elseif(cModDoc == "57")
			   cCodMod := "25"
			Else
			   cCodMod := "1"			           
	  		EndIf	  		
	  		
	  		// Tipo de Recolhimento
	  		If((cAliasRec)->C3S_CODIGO == "01")
	  		   nTRecISSQN := 2
	  		Else
	  		   nTRecISSQN := 1	  		   
	  		EndIf
	  		
	  		If((cAliasRec)->C1H_SIMPLS == "1")
	  		   nSimpNac   := 3
	  		Else
	  		   nSimpNac   := 2
	  		EndIf
	  		 		
	  		nMotNaoRet := POSICIONE("T81",1,xFilial("T81")+(cAliasRec)->C1N_IDMOT,"T81_CODIGO")
	  		nSitEspRsp := POSICIONE("T84",1,xFilial("T84")+(cAliasRec)->C1N_IDSIT,"T84_CODIGO")	  		
	  		
	  		if(Alltrim((cAliasRec)->C20_SERIE) != "")
	  			nSerieDoc := DESSerie((cAliasRec)->C20_SERIE)
	  	    endif
	  	    
	  	    nAuxCid := POSICIONE("C07",3,xFilial("C07")+(cAliasRec)->C20_CODLOC,"C07_CODIGO")    
	  	    nIdUf   := POSICIONE("C07",3,xFilial("C07")+(cAliasRec)->C20_CODLOC,"C07_UF")
	        nAuxEst := POSICIONE("C09",3,xFilial("C09")+nIdUf,"C09_CODUF")
	        
	        nLocPrest := nAuxEst + Substr(nAuxCid,2,5)
			
			//Carrega a varíavel cStrTxt para geração do arquivo 
			cStrTxt := Alltrim(cIdentific)    	+ "|"	// Indicador do Tipo do Layout
			cStrTxt += Alltrim(dDatPgto)    	+ "|"	// Data de Pagamento ou Reconhecimento do crédito
			cStrTxt += Alltrim(dDatEmis)    	+ "|"	// Data de Emissão
			cStrTxt += Alltrim(cCodMod)    		+ "|"	// Modelo do Documento
			cStrTxt += Alltrim(cValToChar(nSerieDoc))    	+ "|"	// Série do Documento
			cStrTxt += Alltrim(cValToChar(nSubsDoc))    	+ "|"	// Subsérie do Documento
			cStrTxt += Alltrim(cValToChar(nSitEspRsp))    	+ "|"	// Situação Especial de Responsabilidade
			cStrTxt += Alltrim(cValToChar(nMotNaoRet))    	+ "|"	// Motivo de não Retenção
			cStrTxt += Alltrim(cValToChar(nLocIncid))    	+ "|"	// Local de Incidência
			cStrTxt += Alltrim(cValToChar(nTRecISSQN))    	+ "|"	// Tipo de Recolhimento do ISSQN
			cStrTxt += Alltrim(cValToChar(nNumDoc))    		+ "|"	// Número do Documento
			cStrTxt += Alltrim(cValToChar(nValBruto))    	+ "|"	// Valor Bruto
			cStrTxt += Alltrim(cValToChar(nValServ))    	+ "|"	// Valor do Serviço
			cStrTxt += Alltrim(cValToChar(nAliq))    		+ "|"	// Alíquota
			cStrTxt += Alltrim(cValToChar(nSimpNac))    	+ "|"	// Simples Nacional
			cStrTxt += Alltrim(cValToChar(nInsMunPre))    	+ "|"	// Inscrição Municipal do prestador
			cStrTxt += Alltrim(cValToChar(nCNPJPre))    	+ "|"	// CNPJ do prestador
			cStrTxt += Alltrim(cValToChar(nCPFPre))    		+ "|"	// CPF do prestador
			cStrTxt += Alltrim(cNomePre)    	+ "|"	// Nome do prestador
			cStrTxt += Alltrim(cLogradPre)    	+ "|"	// Logradouro do prestador
			cStrTxt += Alltrim(cValToChar(nNumImoPre))    	+ "|"	// Número do Imóvel do prestador
			cStrTxt += Alltrim(cComplPre)    	+ "|"	// Complemento do prestador
			cStrTxt += Alltrim(cBairroPre)    	+ "|"	// Bairro do prestador
			cStrTxt += Alltrim(cValToChar(nLocIncid))     	+ "|"	//Cidade do prestador
			cStrTxt += Alltrim(cValToChar(nPaisPre))    	+ "|"	// País do prestador
			cStrTxt += Alltrim(cValToChar(nCEPPre))    		+ "|"	// CEP do prestador
			cStrTxt += Alltrim(cValToChar(nTelPre))    		+ "|"	// Telefone do prestador
			cStrTxt += Alltrim(cEmailPre)    	+ "|"	// E-mail do prestador
			cStrTxt += Alltrim(nInsMunTom)   	+ "|"	// Inscrição Municipal do tomador
			cStrTxt += Alltrim(nCNPJTom)    	+ "|"	// CNPJ do tomador
			cStrTxt += Alltrim(nCPFTom)    		+ "|"	// CPF do tomador
			cStrTxt += Alltrim(cNomeTom)    	+ "|"	// Nome do tomador
			cStrTxt += Alltrim(cLogradTom)    	+ "|"	// Logradouro do tomador
			cStrTxt += Alltrim(nNumImoTom)    	+ "|"	// Número do Imóvel do tomador
			cStrTxt += Alltrim(cComplTom)    	+ "|"	// Complemento do tomador
			cStrTxt += Alltrim(cBairroTom)    	+ "|"	// Bairro do tomador
			cStrTxt += Alltrim(nCidadeTom)    	+ "|"	// Cidade do tomador
			cStrTxt += Alltrim(nPaisTom)    	+ "|"	// País do tomador
			cStrTxt += Alltrim(nCEPTom)    		+ "|"	// CEP do tomador
			cStrTxt += Alltrim(nTelTom)    		+ "|"	// Telefone do tomador
			cStrTxt += Alltrim(cEmailTom)    	+ "|"	// E-mail do tomador
			cStrTxt += Alltrim(cValToChar(nLocPrest))    	+ "|"	// Local de Prestação
			cStrTxt += Alltrim(cValToChar(nPaisPrest))    	+ "|"	// País da prestação dos serviços
			cStrTxt += Alltrim(cDescEvent)    	+ "|"	// Descrição do Evento
			cStrTxt += Alltrim(dDatEvent)   			// Data do Evento			
											
			cStrTxt += CRLF 
	
    	    WrtStrTxt( nHandle, cStrTxt )
    	    
    	    (cAliasRec)->(DbSkip())
	  
	   EndDo
	   
    	    GerTxtDBH( nHandle, cTxtSys, cReg )
	 
    	    Recover
	
    	    lFound := .F.
    	    
  	End Sequence	
					
Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDBHER 

Essa função tem como objetivo retornar as séries correspondentes a
Tabela 13.2 da DES BH.


@Author gustavo.pereira
@Since 11/10/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------

Function DESSerie(cSerie as char)

Local nPos as numeric
Local cRetorno as char

    aSerie := {}    
	
	aAdd(aSerie,{"U", "1"})
	aAdd(aSerie,{"A", "2"})
	aAdd(aSerie,{"AA","3"})
	aAdd(aSerie,{"B", "4"})
	aAdd(aSerie,{"C", "5"}) 
	aAdd(aSerie,{"D", "6"}) 
	aAdd(aSerie,{"E", "7"}) 
	aAdd(aSerie,{"F", "8"}) 
	aAdd(aSerie,{"G", "9"}) 
	aAdd(aSerie,{"H", "10"})
	aAdd(aSerie,{"I", "11"}) 
	aAdd(aSerie,{"J", "12"}) 
	aAdd(aSerie,{"K", "13"}) 
	aAdd(aSerie,{"L", "14"}) 
	aAdd(aSerie,{"M", "15"}) 
	aAdd(aSerie,{"N", "16"})
	aAdd(aSerie,{"O", "17"}) 
	aAdd(aSerie,{"P", "18"}) 
	aAdd(aSerie,{"Q", "19"}) 
	aAdd(aSerie,{"R", "20"})  
	aAdd(aSerie,{"S", "21"})
	aAdd(aSerie,{"T", "22"})
	aAdd(aSerie,{"U", "23"})
	aAdd(aSerie,{"V", "24"})
	aAdd(aSerie,{"W", "25"})
	aAdd(aSerie,{"X", "26"})
	aAdd(aSerie,{"X", "27"})
	aAdd(aSerie,{"X", "28"})

    nPos := 0
    cRetorno := ""
    
    If(VAL(cSerie) >= 1 .And. VAL(cSerie) <= 999)
      cRetorno := VAL(cSerie) + 28
    Else
      If(cSerie != "" .And. cSerie != nil)
        nPos := aScan(aSerie, { |x| x[1] == Alltrim(cSerie)})      
      	cRetorno := aSerie[nPos][2]
      Endif
    Endif   

return cRetorno
