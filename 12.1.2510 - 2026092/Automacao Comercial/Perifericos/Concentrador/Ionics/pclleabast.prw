#Include "Protheus.Ch"
              
Template Function PCLLeAbast()       
Local cRetorno    := "" //ESx|BCx|VAx|PUx|VLx|ECx
Local cCodigo     := 1  
Local aDadosTMP   := {}                                                               	
 
   	IF _nControl == 0    
                                                                                      
	    oTotvsApi := LJCTotvsAPI():New() 
	                                                                     
    	If oTotvsApi:AbrirCom() <> -1                                            

	    	oAPET	  := Ionics():New(oTotvsApi)                                
		
			cRetorno := oAPET:AbrirPorta(cPorta)   
	   		cRetorno :=	oAPET:IniciaDll(cPath)  //onde o log sera gravado
//	   		cRetorno :=	oAPET:ConfigLaco(2,0,4) //remover o comentario para realizar testes
	   		
			_nControl := 1                                                                 

		else                                           

			alert("NAO abriu comunicação com TotvsAPI")	                     
			_nControl := 0
	
		EndIf
		
	Else  
	    cRetorno :=	oAPET:LeSTAbast(2)   
		aDadosTMP  	:= strtokarr(cRetorno, "|") 
        
		If Len(aDadosTMP) > 0
			IF substr(aDadosTMP[1], 3) == "2"      
	
				DbSelectArea("LEG")
				LEG->(DbSetOrder(1))  
				
					//Gero um novo codigo para o abastecimento
						If Dbseek(xFilial("LEG") + Strzero(cCodigo,10,0))
							DbSetOrder(1)
							DbGoBottom()
							cCodigo := val(LEG->LEG_CODIGO) + 1            
						Endif
	
						RecLock("LEG",.T.)    
						LEG->LEG_CODIGO  := Strzero(cCodigo,10,0) 					//Codigo sequencial dos abastecimentos
						LEG->LEG_TOTAPA := strtran(substr(aDadosTMP[3], 3), ",",".")//Total a Pagar do abastecimento
						LEG->LEG_LITABA := substr(aDadosTMP[5], 3)                	//Total de litros abastecidos
						LEG->LEG_PREPLI := strtran(substr(aDadosTMP[4], 3), ",",".")//Preco por litro
						LEG->LEG_CODBIA := StrZero(val(substr(aDadosTMP[2], 3)),2,0)//Codigo do bico de abastecimento
						LEG->LEG_DIATER := StrZero(day(DDATABASE),2,0)   	  		//Dia que terminou o abastecimento
						LEG->LEG_HORTER := SubStr(TIME(), 1, 2)   					//Hora que terminou o abastecimento
						LEG->LEG_MINTER := Substr(TIME(),4,2)   					//Minuto que terminou o abastecimento
						LEG->LEG_ENCERR := substr(aDadosTMP[6], 3)			  		//Encerrante
						LEG->LEG_DATACO := DDATABASE 			  					//Data completa
						LEG->LEG_HORACO := TIME()  				  					//Hora completa                
			   			MsUnlock()                                  
	                                                                               
	
			EndIF 
		EndIf
	
	EndIF   
                                                                  
Return

                                                                                       
