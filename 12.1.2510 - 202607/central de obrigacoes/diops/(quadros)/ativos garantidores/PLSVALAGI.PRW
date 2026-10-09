#Include 'totvs.ch'

FUNCTION PLSVALAGI(lAuto)
Local aRetorno		:= {}
Local cMsg			:= 'Não existe regras de validação para este quadro!'
Default lAuto       := .F.

If !lAuto
	Help( ,, 'HELP',,  cMsg, 1, 0)
	aAdd(aRetorno,{.T.,cMsg})
Else
	aAdd(aRetorno,{.T.,cMsg,lAuto})
EndIf	
	
Return aRetorno

//--------------------------------------------------------------------------------------------------
/*/
Função para validar se foi informada alguma letra no campo.
O campo de RGI tem tamanho 50  e só comporta números, porém não foi possível 
implementá-lo como numérico. Por isso a necessidade desta função 

@Data: 26/07/2019
/*/
//--------------------------------------------------------------------------------------------------

FUNCTION CHKVLRGI(cCodRGI,lAuto)   
    Local lRet     := .T.             
    Default cCodRGI:= ""
 	Default lAuto  :=.F.          
 	
    If !Empty(cCodRGI)
		cCodRGI:= UPPER(cCodRGI)
		
		If  "A" $ cCodRGI  
            lRet:=.F.	        
	    ElseIf "B" $ cCodRGI  
            lRet:=.F.
	    ElseIf "C" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "D" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "E" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "F" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "G" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "H" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "I" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "J" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "L" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "M" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "N" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "O" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "P" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "Q" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "R" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "S" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "T" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "U" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "V" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "X" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "Y" $ cCodRGI  
            lRet:=.F.	
	    ElseIf "W" $ cCodRGI  
            lRet:=.F.
	    ElseIf "Z" $ cCodRGI  
            lRet:=.F.   
        EndIf         
    EndIf
    
	If !lRet .And. !lAuto
        HELP( ,, 'HELP',,"O campo Reg. Geral I está com conteúdo inválido.", 1,0,NIL,NIL,NIL,NIL,NIL,{"Favor alterar o conteúdo do campo para apenas números."})    
    EndIf

Return lRet