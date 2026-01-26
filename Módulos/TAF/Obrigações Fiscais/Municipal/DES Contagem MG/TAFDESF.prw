#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDESNF

Esta rotina tem como objetivo a geração das informações em relação ao
registro 'F' fiscais de serviço da DES - Contagem MG

@Param
 aWizard - Informações da Wizard
 
@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFDESF(aWizard)

 	Local cTxtSys := CriaTrab( , .F. ) + ".TXT"
	Local nHandle := MsFCreate( cTxtSys )
	Local lFound     := ""

    
    Local cReg       := "DES_F"
	Local cLayout    as char
	Local dDatIni    as date
	Local dDatFim    as date
	Local cIdentific as char
	Local cTipReceit as char
	Local nValFatura as Numeric
	Local cNota      as char
	Local cAuxNota   as char
	Local nTotRecC   as Numeric
	Local nTotRecI   as Numeric
	Local nTotRecO   as Numeric
	
	cAliasRec  := GetNextAlias()	
	dDatIni    := aWizard[1][1]  
	dDatFim    := aWizard[1][2] 
	cLayout    := "3"
	cIdentific := "F"
	cTipReceit := ""
	nValFatura := 0
	cNota      := ""
	cAuxNota   := ""
	nTotRecO   := 0
	nTotRecI   := 0
	nTotRecC   := 0
	       
     Begin Sequence		
	
		BeginSql  Alias cAliasRec
        
        SELECT LEM.LEM_NUMERO LEM_NUMERO,
               LEM.LEM_VLBRUT LEM_VLBRUT,               
               C1H.C1H_RAMO   C1H_RAMO
          FROM %table:LEM% LEM
          	  INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = LEM.LEM_FILIAL AND LEM.LEM_IDPART = C1H.C1H_ID     AND C1H.%NotDel%
          	  INNER JOIN %table:T5M% T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID     = LEM.LEM_ID     AND T5M.%NotDel%			        
			  INNER JOIN %table:T52% T52 ON T52.T52_FILIAL = T52.T52_FILIAL AND T52.T52_ID	  = T5M.T5M_ID     AND T52.T52_IDTSER = T5M.T5M_IDTSER AND T52.%NotDel%
			  INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL =  %xFilial:C3S% AND T52.T52_CODTRI = C3S.C3S_ID     AND C3S.%NotDel%               
          WHERE LEM.LEM_FILIAL = %xFilial:LEM%
		    AND LEM_DTEMIS BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%	
		    AND LEM_NATTIT = '1'
		    AND C3S.C3S_CODIGO NOT IN ( %Exp:'01'%, %Exp:'16'% ) 				//ISSQN / ISSQN Retido
		    AND LEM.%NotDel%	
		GROUP BY LEM.LEM_NUMERO,
				 LEM.LEM_VLBRUT,
				 C1H.C1H_RAMO
	    ORDER BY LEM.LEM_NUMERO
		EndSql
		    
		While (cAliasRec)->(!Eof())  
		
		    nValFatura := (cAliasRec)->LEM_VLBRUT   
		    cAuxNota   := (cAliasRec)->LEM_NUMERO
		    
		    If (Alltrim(cNota) != Alltrim(cAuxNota))	       
			 
			    If ((cAliasRec)->C1H_RAMO == '1')
			        nTotRecC = nTotRecC +  nValFatura
			    Endif
			   
			    If ((cAliasRec)->C1H_RAMO == '5')
			        nTotRecI = nTotRecI +  nValFatura
			    Endif
			    
			    if ((cAliasRec)->C1H_RAMO != '5' .And. (cAliasRec)->C1H_RAMO != '1')				    
			        nTotRecO = nTotRecO +  nValFatura
			    Endif
		    
		        cNota     := cAuxNota
		        
		    Endif
 
            (cAliasRec)->(DbSkip())
        EndDo   
        
         If (nTotRecC > 0)
		    
			    cTipReceit := "C"
				//Carrega a varíavel cStrTxt para geração do registro N 
				cStrTxt := Alltrim("'" + cLayout    + "'") 	+ ","	// Indicador do Tipo do Layout
				cStrTxt += Alltrim("'" + cIdentific	+ "'") 	+ ","	// Identificação pro Registros
				cStrTxt += Alltrim("'" + cTipReceit + "'")  + ","	// Tipo de receita 
				cStrTxt += cValToChar(nTotRecC)            	     	// Valor do faturamento : 'I' para indústria; 'C' para comércio; 'O' para outros.
				
				cStrTxt += CRLF
				WrtStrTxt( nHandle, cStrTxt )
	     Endif
	        
	     If (nTotRecI > 0)
		        
		        cTipReceit := "I"
				//Carrega a varíavel cStrTxt para geração do registro N 
				cStrTxt := Alltrim("'" + cLayout    + "'") 	+ ","	// Indicador do Tipo do Layout
				cStrTxt += Alltrim("'" + cIdentific	+ "'") 	+ ","	// Identificação pro Registros
				cStrTxt += Alltrim("'" + cTipReceit + "'")  + ","	// Tipo de receita 
				cStrTxt += cValToChar(nTotRecI)            	     	// Valor do faturamento : 'I' para indústria; 'C' para comércio; 'O' para outros.
				
				cStrTxt += CRLF
				WrtStrTxt( nHandle, cStrTxt )
		 Endif		
		 
		 If (nTotRecO > 0)
		 
		       	cTipReceit := "O"
				//Carrega a varíavel cStrTxt para geração do registro N 
				cStrTxt := Alltrim("'" + cLayout    + "'") 	+ ","	// Indicador do Tipo do Layout
				cStrTxt += Alltrim("'" + cIdentific	+ "'") 	+ ","	// Identificação pro Registros
				cStrTxt += Alltrim("'" + cTipReceit + "'")  + ","	// Tipo de receita 
				cStrTxt += cValToChar(nTotRecO)            	     	// Valor do faturamento : 'I' para indústria; 'C' para comércio; 'O' para outros.
				
				cStrTxt += CRLF
				WrtStrTxt( nHandle, cStrTxt )	
		
	     Endif
    
	    GerTxtDES( nHandle, cTxtSys, cReg )
	    
	    Recover
	
    	lFound := .F.		
 
     End Sequence
    
Return
