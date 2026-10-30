#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDESNF

Esta rotina tem como objetivo a geração das informações em relação ao
registro 'N' e 'I' fiscais de serviço da DES - Contagem MG

@Param
 aWizard - Informações da Wizard
 nCodMun - Código Município 
 
@Author gustavo.pereira
@Since 08/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFDESNF(aWizard, nCodMun )

	Local cTxtSys    as char
	Local nHandle    as Numeric
	Local cReg       as char
	Local cReg2      as char  
	Local lFound     := ""
	Local aTotais    := {}
	
	Local cStrTxt    := ""		
	
	Local cLayout    as char
	Local cRegistro1 as char
	Local cRegistro2 as char	
	Local cDocSerie  as char
	Local cTipoNf    as char
	Local cDocTipo   as char
	Local cDocNum    as char
	Local cDtEmissNF as char
	Local cCNPJCPF   as char
	Local nValDocNF  as Numeric
	Local cTipRecol  as char
	Local cRazaoSoc  as char
	Local cCidade    as char
	Local cEstado    as char
	Local cCodServ   as char
	Local nValBase   as Numeric
	Local nAliqISSQN as Numeric
	Local nAliqServ  as Numeric
	Local nValISSQN  as Numeric
	Local dDatIni    as date
	Local dDatFim    as date
	Local cNota      as char
	Local cAuxNota   as char
	Local cItem      as char
	Local cAuxItem   as char
	Local nVlTotNF   as Numeric	
	Local nContNfE   as Numeric 
	Local nContRegN  as Numeric
	Local nVlTotImp  as Numeric
	Local nSomaImp   as Numeric 
    Local nContNfR   as Numeric
	Local nVlTotRe   as Numeric	
	Local nVlTotImpR as Numeric 	
	Local nNfAnt     as char		
				
	cAliasDoc  := GetNextAlias()
	cAliasRec  := GetNextAlias()	
	cLayout    := "3"
	cRegistro1 := "N"
	cDocSerie  := ""
	cTipoNf    := ""
	cDocTipo   := ""
	cDocNum    := ""
	cDtEmissNF := ""	 
	cCNPJCPF   := ""
	nValDocNF  := 0
	cTipRecol  := ""
	cRazaoSoc  := ""
	cCidade    := ""
	cEstado    := ""	
	cTxtSys    := CriaTrab( , .F. ) + ".txt"
	nHandle    := MsFCreate( cTxtSys )
	cReg       := "DES_N"	
	// Registro I
	cReg2      := "DES_I"		
	cLayout    := "3"
	cRegistro2 := "I"
	cCodServ   := ""
	nValBase   := 0
	nAliqISSQN := 0
	nAliqServ  := 0	
	nValISSQN  := 0		
	dDatIni    := aWizard[1][1]  
	dDatFim    := aWizard[1][2]  	
	cNota      := ""	
	cItem      := ""		
	nVlTotNF   := 0
	nContNfE   := 0
	nContRegN  := 0
	nVlTotImp  := 0
	nSomaImp   := 0
	nContNfR   := 0
	nVlTotRe   := 0
	nVlTotImpR := 0
		
	Begin Sequence		
	
		BeginSql  Alias cAliasDoc
		
		   SELECT C20.C20_NUMDOC  C20_NUMDOC, 
		          C20.C20_SERIE   C20_SERIE, 
		          C20.C20_DTDOC   C20_DTDOC,
		          C20.C20_VLDOC   C20_VLDOC,
		          C20.C20_INDOPE  C20_INDOPE,
		          C1H.C1H_CNPJ    C1H_CNPJ,
		          C1H.C1H_CPF     C1H_CPF,
		          C09.C09_UF      C09_UF,
		          C07.C07_DESCRI  C07_DESCRI,
		          C07.C07_CODIGO  C07_CODIGO,
		          C1H.C1H_NOME    C1H_NOME,
		          C1L.C1L_SRVMUN  C1L_SRVMUN,		          
		          C1H.C1H_SIMPLS  C1H_SIMPLS,
		          C35.C35_BASE    C35_BASE,
		          C35.C35_ALIQ    C35_ALIQ,
		          C35.C35_VALOR   C35_VALOR,
		          C30.C30_CODITE  C30_CODITE,
		          C1H.C1H_CODMUN  C1H_CODMUN,
		          C02.C02_CODIGO  C02_CODIGO,
		          C35.C35_VLISEN  C35_VLISEN,
		          C3S.C3S_CODIGO  C3S_CODIGO		 	          		                          		                    
		   	 FROM %table:C20% C20 
			   	 INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID     AND C1H.%NotDel%  	  
			   	 INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xFilial:C0U%  AND C20.C20_TPDOC  = C0U.C0U_ID     AND C0U.%NotDel%  
			   	 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF  AND C30.%NotDel%       
			   	 INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF  AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.%NotDel% 
			   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID     AND C3S.%NotDel% 
			   	 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C1H.C1H_UF     AND C09.%NotDel% 
			   	 INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel% 	
			   	 INNER JOIN %table:C02% C02 ON C02.C02_FILIAL =  %xFilial:C02% AND C20.C20_CODSIT = C02.C02_ID     AND C02.%NotDel% 	
			   	 INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL =  %xFilial:C1L% AND C1L.C1L_ID     = C30.C30_CODITE AND C1L.%NotDel%	   	   	   	  		   	 
	        WHERE C20.C20_FILIAL = %xFilial:C20%
			  AND C20_DTDOC BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%			  
			  AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido
			  AND C1L.C1L_SRVMUN <> ""
			  AND C20.%NotDel%			  		  
			GROUP BY C20.C20_NUMDOC, 
					 C20.C20_SERIE, 
					 C20.C20_DTDOC, 
					 C20.C20_VLDOC,
					 C20.C20_INDOPE,
					 C1H.C1H_CNPJ,
					 C1H.C1H_CPF,
		             C09.C09_UF,
		             C07.C07_DESCRI,
		             C07.C07_CODIGO,
		             C1H.C1H_NOME,
		             C1L.C1L_SRVMUN,  		          
		             C1H.C1H_SIMPLS,  
		             C35.C35_BASE,    
		             C35.C35_ALIQ,    
		             C35.C35_VALOR,
		             C30.C30_CODITE,
		             C1H.C1H_CODMUN,
		             C02.C02_CODIGO,
		             C35.C35_VLISEN,
		             C3S.C3S_CODIGO               
		     ORDER BY C20.C20_NUMDOC		 					 			 
		EndSql
				
	    While (cAliasDoc)->(!Eof())
	         
	       cAuxNota    =   (cAliasDoc)->C20_NUMDOC
	       
	       nNfAnt := cNota 
	       
	       if (Alltrim(cNota) != Alltrim(cAuxNota))	       	
	         
	     	 cCNPJCPF   := Iif ( !Empty((cAliasDoc)->C1H_CNPJ),  (cAliasDoc)->C1H_CNPJ, (cAliasDoc)->C1H_CPF )
	    	 cDocSerie  := (cAliasDoc)->C20_SERIE
	    	 cTipoNf    := Iif ( (cAliasDoc)->C20_INDOPE == '0', 'R', 'E' )
	    	 cDocTipo   := "N"
	    	 cDocNum    := (cAliasDoc)->C20_NUMDOC
	    	 cDtEmissNF := (cAliasDoc)->C20_DTDOC
	    	 nValDocNF  := (cAliasDoc)->C20_VLDOC
	    	 cRazaoSoc  := (cAliasDoc)->C1H_NOME
	    	 cCidade    := (cAliasDoc)->C07_DESCRI
	    	 cEstado    := (cAliasDoc)->C09_UF  
	    	 cAuxMun    := (cAliasDoc)->C07_CODIGO
	    	  	
	    	 If ( (cAuxMun != Alltrim(nCodMun) .And.  (cAliasDoc)->C20_INDOPE == "1" .And. (cAliasDoc)->C3S_CODIGO == "16") .OR. (cAuxMun != Alltrim(nCodMun) .And. (cAliasDoc)->C3S_CODIGO == "16" .And. (cAliasDoc)->C20_INDOPE == "0") )	    	 	
	    	 	cTipRecol := "F"	    	 	  
	    	 Endif
	    	 
	    	 If ( (cAliasDoc)->C3S_CODIGO == "01" .And. (cAliasDoc)->C20_INDOPE == "1" .And. (cAliasDoc)->C35_VALOR > 0 )
	    	    cTipRecol := "P"	    	    
	    	 Endif
	    	 
	    	 If ( (cAliasDoc)->C3S_CODIGO == "01" .And. (cAliasDoc)->C20_INDOPE == "0" .And. (cAliasDoc)->C35_VALOR > 0 )
	    	    cTipRecol := "O"
	    	 Endif
	    	 
	    	 If ( (cAuxMun == Alltrim(nCodMun) .And. (cAliasDoc)->C20_INDOPE == "1" .And. (cAliasDoc)->C3S_CODIGO == "16") .OR. (cAuxMun == Alltrim(nCodMun) .And. (cAliasDoc)->C3S_CODIGO == "16" .And. (cAliasDoc)->C20_INDOPE == "0") )
	    	    cTipRecol := "S"
	    	 endif
	    	 
	    	 If ( (cAliasDoc)->C02_CODIGO == "02")
	    	    cTipRecol := "C"
	    	 Endif
	    	 
	    	  If ( (cAliasDoc)->C35_VLISEN > 0)
	    	    cTipRecol := "I"
	    	 Endif  	 	   	  	    
	    	 	    	 
	    	 
			 //Carrega a varíavel cStrTxt para geração do registro N 
			 cStrTxt := Alltrim("'" + cLayout    + "'") 					+ ","	// Indicador do Tipo do Layout
			 cStrTxt += Alltrim("'" + cRegistro1	+ "'") 					+ ","	// Identificação pro Registros
			 cStrTxt += Alltrim("'" + RTrim(cDocSerie)  + "'")   		    + ","	// Série da nota fiscal
			 cStrTxt += Alltrim("'" + cTipoNf    + "'")        	 		    + ","	// Tipo da Nota Fiscal 
			 cStrTxt += Alltrim("'" + cDocTipo   + "'")          			+ ","	// Tipo de documento fiscal
			 cStrTxt += Alltrim(cDocNum)		  	                        + ","	// Número da Nota Fiscal 		
			 cStrTxt += Alltrim(cDtEmissNF)                                 + ","	// Data da emissão da nota fiscal
			 cStrTxt += Alltrim("'" + Alltrim(cCNPJCPF)   + "'")                     + ","	// CNPJ/CPF do tomador ou prestador 
			 cStrTxt += cValToChar(nValDocNF)  	                     	    + ","	// Valor Bruto do Documento 
			 cStrTxt += Alltrim("'" + cTipRecol  + "'")  					+ ","	// Tipo de recolhimento
			 cStrTxt += Alltrim("'" + Rtrim(cRazaoSoc)	+ "'")				+ ","	// Razão social do tomador/prestador
			 cStrTxt += Alltrim("'" + Rtrim(cCidade)     + "'")				+ ","	// Cidade do tomador/prestador
			 cStrTxt += Alltrim("'" + cEstado    + "'")       	     			// Estado do tomador/prestador
	
		     cStrTxt += CRLF	    
    	    
    	     WrtStrTxt( nHandle, cStrTxt )  

             cNota     := cAuxNota
             
             If ( (cAliasDoc)->C20_INDOPE == '1' )
                nContNfE   := nContNfE + 1 
             	nVlTotNF   := nVlTotNF +  nValDocNF
    	     Else
    	        nContNfR   := nContNfR + 1
    	        nVlTotRe   := nVlTotRe +  nValDocNF
    	     Endif 	      
    	     
    	     nContRegN := nContRegN + 1
    	     
		  EndIf			  
		  
		     If ( (cAliasDoc)->C1H_SIMPLS == "1")
		        nAliqISSQN = (cAliasDoc)->C35_ALIQ
		        nAliqServ  = 0
		     Else
			    nAliqServ  = (cAliasDoc)->C35_ALIQ
			    nAliqISSQN = 0
			 EndIf	
			  
		     cCodServ  := (cAliasDoc)->C1L_SRVMUN 	   
			 nValBase  := (cAliasDoc)->C35_BASE
			 nValISSQN := (cAliasDoc)->C35_VALOR
		      	  
		     cAuxItem  := Alltrim((cAliasDoc)->C30_CODITE)
		     
		      
			 //Carrega a varíavel cStrTxt para geração do registro I 
			 cStrTxt := Alltrim("'" + cLayout + "'")   						+ ","	// Indicador do Tipo do Layout
			 cStrTxt += Alltrim("'" + cRegistro2	+ "'") 					+ ","	// Identificação pro Registros
			 cStrTxt += Rtrim(cCodServ)     				        + ","	// Código do serviço
			 cStrTxt += cValToChar(nValBase)            	+ ","	// Valor base de cálculo ISSQN			 
			 cStrTxt += cValToChar(nAliqISSQN)              + ","	// Aliquota para empresas do Simples Nacional
			 cStrTxt += cValToChar(nAliqServ)       		+ ","	// Alíquota do serviço 		
			 cStrTxt += cValToChar(nValISSQN)           	    	// Valor do tributo ISSQN
				
			 cStrTxt += CRLF 
		
	    	 WrtStrTxt( nHandle, cStrTxt )	       
	         
	         //Valor bruto e do Imposto nota de entrada
	         If ( (cAliasDoc)->C20_INDOPE == '1' )
	         	nVlTotImp  := nVlTotImp + nValISSQN
	         Else 
	            nVlTotImpR := nVlTotImpR + nValISSQN 		         	         	
         	 Endif             	
         	
         	 If ((cTipRecol == "F"  .or. cTipRecol == "S") .And. (cAliasDoc)->C20_INDOPE == '1')
         	  	nSomaImp := nSomaImp + nValISSQN
	         endif 		           	    
	    	    
	    	 (cAliasDoc)->(DbSkip())    	    	    
		   
    	EndDo
    	
    	/* SELECT dos Recibos*/
    	
    	BeginSql Alias cAliasRec
    	
    		SELECT LEM.LEM_NUMERO  LEM_NUMERO,
		           LEM.LEM_DTEMIS  LEM_DTEMIS,
		           LEM.LEM_VLBRUT  LEM_VLBRUT,
		           LEM.LEM_NATTIT  LEM_NATTIT,		           
		           C1H.C1H_NOME    C1H_NOME,
		           C1H.C1H_CNPJ    C1H_CNPJ,
		           C1H.C1H_CPF     C1H_CPF,
		           C1H.C1H_CODMUN  C1H_CODMUN,
		           C1H.C1H_SIMPLS  C1H_SIMPLS,
		           C3S.C3S_CODIGO  C3S_CODIGO,
		           C09.C09_UF      C09_UF,
		           C07.C07_DESCRI  C07_DESCRI,
		           C07.C07_CODIGO  C07_CODIGO,
		           T52.T52_VLTRIB  T52_VLTRIB,
		           LEM.LEM_SRVMUN  LEM_SRVMUN,		           
		           T52.T52_BASECA  T52_BASECA,
		           T52.T52_ALIQ    T52_ALIQ		           	 		
		      FROM %table:LEM% LEM
		      	  INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = LEM.LEM_FILIAL AND LEM.LEM_IDPART = C1H.C1H_ID     AND C1H.%NotDel%           
		          INNER JOIN %table:T5M% T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID     = LEM.LEM_ID     AND T5M.%NotDel%			        
			      INNER JOIN %table:T52% T52 ON T52.T52_FILIAL = T52.T52_FILIAL AND T52.T52_ID	  = T5M.T5M_ID     AND T52.T52_IDTSER = T5M.T5M_IDTSER AND T52.%NotDel%
			      INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND T52.T52_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%     
			      INNER JOIN %table:C8C% C8C ON C8C.C8C_FILIAL =  %xFilial:C8C% AND C8C.C8C_ID     = T5M.T5M_IDTSER AND C8C.%NotDel%
		          INNER JOIN %table:C09% C09 ON C09.C09_FILIAL =  %xFilial:C09% AND C09.C09_ID     = C1H.C1H_UF     AND C09.%NotDel% 
			      INNER JOIN %table:C07% C07 ON C07.C07_FILIAL =  %xFilial:C07% AND C07.C07_ID     = C1H.C1H_CODMUN AND C07.%NotDel%     
	         WHERE LEM.LEM_FILIAL = %xFilial:LEM%
		 	   AND LEM_DTEMIS BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%	
		 	   AND LEM_NATTIT = '0'
		 	   AND LEM_TIPDOC = '0'  
		 	   AND LEM_SRVMUN <> ""
		 	   AND LEM.%NotDel%
	 		   AND C3S.C3S_CODIGO IN ( %Exp:'01'%, %Exp:'16'% )							//ISSQN / ISSQN Retido	     
    	  GROUP BY LEM.LEM_NUMERO,
		           LEM.LEM_DTEMIS,
		           LEM.LEM_VLBRUT,
		           LEM.LEM_NATTIT,		           
		           C1H.C1H_NOME,
		           C1H.C1H_CNPJ,
		           C1H.C1H_CPF,
		           C1H.C1H_CODMUN,
		           C1H.C1H_SIMPLS,
		           C3S.C3S_CODIGO,
		           C09.C09_UF,
		           C07.C07_DESCRI,
		           C07.C07_CODIGO,
		           T52.T52_VLTRIB,
		           LEM.LEM_SRVMUN,
		           T52.T52_BASECA,  
		           T52.T52_ALIQ		              
		  ORDER BY LEM.LEM_NUMERO	
		 EndSql
		 
		nAliqISSQN = 0		
		cCNPJCPF   := ""
        cDocSerie  := ""
	    cTipoNf    := ""
	    cDocTipo   := ""
	    cDocNum    := ""
	    cDtEmissNF := ""
	    nValDocNF  := 0
	    cRazaoSoc  := ""
	    cCidade    := ""
	    cEstado    := "" 
	    cAuxMun    := ""	   
					
		While (cAliasRec)->(!Eof())			 
		
	       cAuxNota    =   (cAliasRec)->LEM_NUMERO
	       
	       nNfAnt := cNota 
	       
	       If (Alltrim(cNota) != Alltrim(cAuxNota))	       	
	         
	     	 cCNPJCPF   := Iif ( !Empty((cAliasRec)->C1H_CNPJ),  (cAliasRec)->C1H_CNPJ, (cAliasRec)->C1H_CPF )
	    	 cDocSerie  := "RPA"
	    	 cTipoNf    := "R"
	    	 cDocTipo   := "R"
	    	 cDocNum    := (cAliasRec)->LEM_NUMERO
	    	 cDtEmissNF := (cAliasRec)->LEM_DTEMIS
	    	 nValDocNF  := (cAliasRec)->LEM_VLBRUT
	    	 cRazaoSoc  := (cAliasRec)->C1H_NOME
	    	 cCidade    := (cAliasRec)->C07_DESCRI
	    	 cEstado    := (cAliasRec)->C09_UF  
	    	 cAuxMun    := (cAliasRec)->C07_CODIGO
	 	    	 
	      	 If ( cAuxMun != Alltrim(nCodMun)     .And. (cAliasRec)->C3S_CODIGO == "16") 	    	 	
	    	 	cTipRecol := "F"	    	 	  
	    	 Endif
	    	 
	    	 If ( (cAliasRec)->C3S_CODIGO == "01" .And. (cAliasRec)->T52_VLTRIB > 0 )
	    	    cTipRecol := "O"	    	    
	    	 Endif
	    	  	 
	    	 If ( cAuxMun == Alltrim(nCodMun)     .And. (cAliasRec)->C3S_CODIGO == "16") 
	    	    cTipRecol := "S"
	    	 endif
	    	 
	    	 //Carrega a varíavel cStrTxt para geração do registro N 
			 cStrTxt := Alltrim("'" + cLayout    + "'") 					+ ","	// Indicador do Tipo do Layout
			 cStrTxt += Alltrim("'" + cRegistro1	+ "'") 					+ ","	// Identificação pro Registros
			 cStrTxt += Alltrim("'" + RTrim(cDocSerie)  + "'")   		    + ","	// Série da nota fiscal
			 cStrTxt += Alltrim("'" + cTipoNf    + "'")        	 		    + ","	// Tipo do Recibo
			 cStrTxt += Alltrim("'" + cDocTipo   + "'")          			+ ","	// Tipo de documento fiscal
			 cStrTxt += Alltrim(cDocNum)		  	                        + ","	// Número do Recibo		
			 cStrTxt += Alltrim(cDtEmissNF)                                 + ","	// Data da emissão da nota fiscal
			 cStrTxt += Alltrim("'" + Alltrim(cCNPJCPF)   + "'")                     + ","	// CNPJ/CPF do tomador ou prestador 
			 cStrTxt += cValToChar(nValDocNF)  	                     	    + ","	// Valor Bruto do Documento 
			 cStrTxt += Alltrim("'" + cTipRecol  + "'")  					+ ","	// Tipo de recolhimento
			 cStrTxt += Alltrim("'" + Rtrim(cRazaoSoc)	+ "'")				+ ","	// Razão social do tomador/prestador
			 cStrTxt += Alltrim("'" + Rtrim(cCidade)     + "'")				+ ","	// Cidade do tomador/prestador
			 cStrTxt += Alltrim("'" + cEstado    + "'")       	     			// Estado do tomador/prestador
	
			 cStrTxt += CRLF	    
    	    
    	     WrtStrTxt( nHandle, cStrTxt )  

             cNota     := cAuxNota	    
             
             nVlTotRe  := nVlTotRe + nValDocNF	 		
             
             nContNfR  := nContNfR + 1 
	    	     		 
	       Endif 	       
	       
		   nAliqServ  = (cAliasRec)->T52_ALIQ
		   nAliqISSQN = 0			  
		   cCodServ  := (cAliasRec)->LEM_SRVMUN 	   
		   nValBase  := (cAliasRec)->T52_BASECA
		   nValISSQN := (cAliasRec)->T52_VLTRIB	     
		      
		   //Carrega a varíavel cStrTxt para geração do registro I 
		   cStrTxt := Alltrim("'" + cLayout + "'")   						+ ","	// Indicador do Tipo do Layout
		   cStrTxt += Alltrim("'" + cRegistro2	+ "'") 				     	+ ","	// Identificação pro Registros
		   cStrTxt += Alltrim(cCodServ)                                     + ","	// Código do serviço
		   cStrTxt += cValToChar(nValBase)            	                    + ","	// Valor base de cálculo ISSQN			 
		   cStrTxt += cValToChar(nAliqISSQN)                                + ","	// Aliquota para empresas do Simples Nacional
		   cStrTxt += cValToChar(nAliqServ)       		                    + ","	// Alíquota do serviço 		
		   cStrTxt += cValToChar(nValISSQN)           	    	                    // Valor do tributo ISSQN
				
		   cStrTxt += CRLF 
		
	       WrtStrTxt( nHandle, cStrTxt )	   
	       
	       nVlTotImpR  := nVlTotImpR + nValISSQN		     
    	
	       (cAliasRec)->(DbSkip())
    	
    	EndDo
    	
    	 GerTxtDES( nHandle, cTxtSys, cReg )   	 	  
	    
	     aAdd(aTotais, nContRegN  ) 
	     aAdd(aTotais, nContNfE   )
	     aAdd(aTotais, nVlTotNF   )
	     aAdd(aTotais, nVlTotImp  )
	     aAdd(aTotais, nSomaImp   )
	     aAdd(aTotais, nContNfR   )
	     aAdd(aTotais, nVlTotRe   )
	     aAdd(aTotais, nVlTotImpR )  
	     
    	 Recover
	
    	 lFound := .F.		
    	    
	End Sequence		
				
				
Return aTotais		







 

 
 