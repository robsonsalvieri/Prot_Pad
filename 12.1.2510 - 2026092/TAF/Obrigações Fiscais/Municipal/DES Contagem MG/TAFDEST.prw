#Include 'Protheus.ch'

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFDESNI

Esta rotina tem como objetivo a geração das informações em relação ao
registro 'T' fiscais de serviço da DES - Contagem MG

@Param
 aTotais - Informações da Nota
 
@Author gustavo.pereira
@Since 07/08/2017
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFDEST(aTotais)

	Local cTxtSys    as char
	Local nHandle    as Numeric
	
    Local cReg       := "DES_T"
    
	Local cLayout    as char
	Local cIdentific as char
	Local nQtdNotas  as Numeric
	Local nQtdNFS    as Numeric
	Local nSomaNF    as Numeric
	Local nSomaImp1  as Numeric // Soma do imposto das notas ou recibos emitidos
	Local nSomaImp2  as Numeric // Soma do imposto das notas ou recibos emitidos que foi retido por outras empresas
	Local nQtdRegN   as Numeric
	Local nSomVlBrt  as Numeric 
	Local nSomaImp3  as Numeric	
	
	cAliasImp  := GetNextAlias()	
	cLayout    := "3"
	cIdentific := "T"
	nQtdNotas  := aTotais[1]
	nQtdNFS    := aTotais[2]
	nSomaNF    := aTotais[3]
	nSomaImp1  := aTotais[4]
	nSomaImp2  := aTotais[5]
	nQtdRegN   := aTotais[6]	
	nSomVlBrt  := aTotais[7]		
	nSomaImp3  := aTotais[8]		
	
	cTxtSys    := CriaTrab( , .F. ) + ".txt"
	nHandle    := MsFCreate( cTxtSys )			
			
	Begin Sequence		
	
			//Carrega a varíavel cStrTxt para geração do registro N 
			cStrTxt := Alltrim("'" + cLayout     + "'") + ","	// Indicador do Tipo do Layout
			cStrTxt += Alltrim("'" + cIdentific	 + "'")	+ ","	// Identificação pro Registros
			cStrTxt += cValToChar(nQtdNotas)   		    + ","	// Quantidade total de notas no arquivo
			cStrTxt += cValToChar(nQtdNFS)               	+ ","	// Quantidade de notas (documento de saída) 
			cStrTxt += cValToChar(nSomaNF)             	+ ","	// Somatório do valor bruto das notas de saída
			cStrTxt += cValToChar(nSomaImp1)       		+ ","	// Somatório do valor do impostoso de Doc de saída
			cStrTxt += cValToChar(nSomaImp2)       		+ ","	// Somatório do valor dos impostos de doc de saída retido por outras empresas			
			cStrTxt += cValToChar(nQtdRegN)               	+ ","	// Quantidade total de documentos de entrada
			cStrTxt += cValToChar(nSomVlBrt)              	+ ","	// Somatório do valor bruto das notas de entrada
			cStrTxt += cValToChar(nSomaImp3)              	     	// Somatório do valor do imposto de doc de entrada	
			
			cStrTxt += CRLF 
	
    	    WrtStrTxt( nHandle, cStrTxt )
	
    	    GerTxtDES( nHandle, cTxtSys, cReg )
	 
    	    Recover
	
    	    lFound := .F.
    	    
	End Sequence
	
Return 



