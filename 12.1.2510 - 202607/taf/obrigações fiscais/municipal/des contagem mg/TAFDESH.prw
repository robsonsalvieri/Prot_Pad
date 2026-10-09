#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDESH

Esta rotina tem como objetivo a geração dos documentos fiscais de serviço da
DES - Contagem MG

@Param
 aWizard - Informações da Wizard
 cCnpj	 - CNPJ da empresa
 cInsc   - Inscrição Municipal da empresa
 
@Author gustavo.pereira
@Since 08/08/2018
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFDESH(aWizard , cCnpj , cInsc )

	Local cTxtSys    as char
	Local nHandle    as Numeric
	
	Local cStrTxt   := ""
	Local cReg      := "DES_H" 
	Local cLayout    as char
	Local cIdentific as char
	Local cCNPJ      as char
	Local dMesRefer  as date
	Local dAnoRefer  as date
	Local cIndicador as char
	Local cCodAcesso as Numeric
	Local cCPFCNPJ   as char
	Local cInscMunic as char
	Local cAliasDoc as char
	Local cAliasImp as char	
	Local cAliasRec as char
	Local cAuxCPF   as char
	Local cAuxCNPJ  as char
	
	cAliasImp  := GetNextAlias()	
	cLayout    := "3"
	cIdentific := "H"
	cCNPJ      := cCnpj
	cIndicador := "0"
	cCodAcesso := aWizard[1][5]
	cCPFCNPJ   := ""
	cInscMunic := cInsc	
	dMesRefer  := aWizard[1][1]  // Mês Referência
	dAnoRefer  := aWizard[1][2]  // Ano Referência	
	cTxtSys    := CriaTrab( , .F. ) + ".txt"
	nHandle    := MsFCreate( cTxtSys )
	cAuxCPF    := ""
	cAuxCNPJ   := ""
	cAux       := aWizard[1][7]
	
	Begin Sequence
	 	    
	        cAuxCPF  := POSICIONE('C2J',5,cFilAnt +  cAux, "C2J_CPF")
	        cAuxCNPJ := POSICIONE("C2J",5,cFilAnt +  cAux, "C2J_CNPJ")
	        
	        If (cAuxCNPJ == "")
			   cCPFCNPJ := cAuxCNPJ
			Else
			   cCPFCNPJ := cAuxCNPJ
			endif
			
			//Carrega a varíavel cStrTxt para geração do arquivo 
			cStrTxt := Alltrim("'" + cLayout                          + "'")    + ","	// Indicador do Tipo do Layout
			cStrTxt += Alltrim("'" + cIdentific	                      + "'") 	+ ","	// Identificação pro Registros
			cStrTxt += Alltrim("'" + cCNPJ                            + "'")    + ","	// CNPJ do declarante
			cStrTxt += cValToChar(YEAR(dAnoRefer))                              + ","	// Ano referência
			cStrTxt += cValToChar(Month2Str(dMesRefer))                         + ","	// Mês referência			
			cStrTxt += cIndicador                                               + ","	// Indicação se a declaração é original/inicial (zero)			
			cStrTxt += cValToChar(RTrim(Substr(cCodAcesso,1,14)))                         + ","	// Código de acesso ao sistema
			cStrTxt += Alltrim("'" + cCPFCNPJ                         + "'")	+ ","	// CNPJ ou CPF da contabilidade/Contador
			cStrTxt += Alltrim(cInscMunic)                              	        	// Cadastro Municipal
								
			cStrTxt += CRLF 
	
    	    WrtStrTxt( nHandle, cStrTxt )
	
    	    GerTxtDES( nHandle, cTxtSys, cReg )
	 
    	    Recover
	
    	    lFound := .F.
    	    
	End Sequence
 		
					
Return
