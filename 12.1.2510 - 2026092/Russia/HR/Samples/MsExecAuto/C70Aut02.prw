#INCLUDE "Protheus.CH"

User Function C70Aut02(cType as Character,cArea as Character)
Local aAutoCab   		:= {}     
Local aAutoItens   		:= {}   
Local aAtLvl0101		:= {}
Local aAtLvl0102		:= {}    
Local aAtLvl0201		:= {} 
Local aAtLvl0202		:= {} 
                                      		
Private lMsErroAuto 	:= .F.

BEGIN TRANSACTION

	aadd(aAutoCab,  {"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAutoCab,  {"RBR_TABELA" 		,cArea+"2"						,Nil		})
	aadd(aAutoCab,  {"RBR_DESCTA" 		,cArea+" - Тариф02"				,Nil		})
	aadd(aAutoCab,  {"RBR_USAPOT" 		,2								,Nil		})
	aadd(aAutoCab,  {"RBR_TIPOVL" 		,1								,Nil		})
	aadd(aAutoCab,  {"RBR_DTSTAR" 		,Stod('20180101')				,Nil		})
	aadd(aAutoCab,  {"RBR_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAutoCab,  {"RBR_CDTYP" 		,cType							,Nil		})
	aadd(aAutoCab,  {"RBR_CDARE" 		,cArea							,Nil		})
	
	// LEVEL 01
	aadd(aAtLvl0101,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0101,{"RB6_TABELA" 		,cArea+"2"						,Nil		})
	aadd(aAtLvl0101,{"RB6_DESCTA" 		,cArea+" - Тариф02"				,Nil		})
	aadd(aAtLvl0101,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0101,{"RB6_NIVEL" 		,"01"							,Nil		})
	aadd(aAtLvl0101,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0101,{"RB6_VALOR" 		,10415							,Nil		})
	aadd(aAtLvl0101,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0101,{"RB6_AVGVL" 		,11562.50						,Nil		})
	aadd(aAtLvl0101,{"RB6_CLASSE" 		,"001"							,Nil		})
	
	
	aadd(aAtLvl0102,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0102,{"RB6_TABELA" 		,cArea+"2"						,Nil		})
	aadd(aAtLvl0102,{"RB6_DESCTA" 		,cArea+" - Тариф02"				,Nil		})
	aadd(aAtLvl0102,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0102,{"RB6_NIVEL" 		,"01"							,Nil		})
	aadd(aAtLvl0102,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0102,{"RB6_VALOR" 		,6140							,Nil		})
	aadd(aAtLvl0102,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0102,{"RB6_AVGVL" 		,11562.50						,Nil		})
	aadd(aAtLvl0102,{"RB6_CLASSE" 		,"001"							,Nil		})
	
	// LEVEL 02
	aadd(aAtLvl0201,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0201,{"RB6_TABELA" 		,cArea+"2"						,Nil		})
	aadd(aAtLvl0201,{"RB6_DESCTA" 		,cArea+" - Тариф02"				,Nil		})
	aadd(aAtLvl0201,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0201,{"RB6_NIVEL" 		,"02"							,Nil		})
	aadd(aAtLvl0201,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0201,{"RB6_VALOR" 		,11375							,Nil		})
	aadd(aAtLvl0201,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0201,{"RB6_AVGVL" 		,12470							,Nil		})
	aadd(aAtLvl0201,{"RB6_CLASSE" 		,"002"							,Nil		})
	
	aadd(aAtLvl0202,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0202,{"RB6_TABELA" 		,cArea+"2"						,Nil		})
	aadd(aAtLvl0202,{"RB6_DESCTA" 		,cArea+" - Тариф02"				,Nil		})
	aadd(aAtLvl0202,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0202,{"RB6_NIVEL" 		,"02"							,Nil		})
	aadd(aAtLvl0202,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0202,{"RB6_VALOR" 		,13565							,Nil		})
	aadd(aAtLvl0202,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0202,{"RB6_AVGVL" 		,12470							,Nil		})
	aadd(aAtLvl0202,{"RB6_CLASSE" 		,"002"							,Nil		})
	
	
	aadd(aAutoItens,aAtLvl0101)
	aadd(aAutoItens,aAtLvl0102)
	aadd(aAutoItens,aAtLvl0201)
	aadd(aAutoItens,aAtLvl0202)
	
	// Call routine Contract Data with operation 3 (Insert)
	MSExecAuto({|x,y,k,w| CSAA070(x,y,k,w)},aAutoCab,aAutoItens,3,NIL)  
	
	If lMsErroAuto
		DisarmTransaction()
		break
	EndIf

END TRANSACTION

If !lMsErroAuto
    ConOut("**** Included with Success ****")
Else
    MostraErro()
    ConOut("Error on Include!")
EndIf

Return lMsErroAuto