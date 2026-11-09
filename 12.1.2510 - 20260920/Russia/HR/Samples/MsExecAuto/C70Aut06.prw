#INCLUDE "Protheus.CH"

User Function C70Aut06()
Local aAutoCab   		:= {}     
Local aAutoItens   		:= {}   
Local aAtLvl0101		:= {}
Local aAtLvl0102		:= {}    
Local aAtLvl0201		:= {} 
Local aAtLvl0202		:= {} 
Local aAtLvl0301		:= {} 
Local aAtLvl0302		:= {}  
Local aAtLvl0401		:= {} 
Local aAtLvl0402		:= {}
Local aAtLvl0501		:= {} 
Local aAtLvl0502		:= {}
                                      		
Private lMsErroAuto 	:= .F.

BEGIN TRANSACTION

	aadd(aAutoCab,  {"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAutoCab,  {"RBR_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAutoCab,  {"RBR_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAutoCab,  {"RBR_USAPOT" 		,2								,Nil		})
	aadd(aAutoCab,  {"RBR_TIPOVL" 		,1								,Nil		})
	aadd(aAutoCab,  {"RBR_DTSTAR" 		,Stod('20180101')				,Nil		})
	aadd(aAutoCab,  {"RBR_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAutoCab,  {"RBR_CDTYP" 		,cType							,Nil		})
	aadd(aAutoCab,  {"RBR_CDARE" 		,cArea							,Nil		})
	
	// LEVEL 01
	aadd(aAtLvl0101,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0101,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0101,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0101,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0101,{"RB6_NIVEL" 		,"01"							,Nil		})
	aadd(aAtLvl0101,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0101,{"RB6_VALOR" 		,8597							,Nil		})
	aadd(aAtLvl0101,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0101,{"RB6_AVGVL" 		,9156							,Nil		})
	aadd(aAtLvl0101,{"RB6_CLASSE" 		,"001"							,Nil		})
	
	
	aadd(aAtLvl0102,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0102,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0102,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0102,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0102,{"RB6_NIVEL" 		,"01"							,Nil		})
	aadd(aAtLvl0102,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0102,{"RB6_VALOR" 		,9715							,Nil		})
	aadd(aAtLvl0102,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0102,{"RB6_AVGVL" 		,9156							,Nil		})
	aadd(aAtLvl0102,{"RB6_CLASSE" 		,"001"							,Nil		})
	
	// LEVEL 02
	aadd(aAtLvl0201,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0201,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0201,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0201,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0201,{"RB6_NIVEL" 		,"02"							,Nil		})
	aadd(aAtLvl0201,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0201,{"RB6_VALOR" 		,9345							,Nil		})
	aadd(aAtLvl0201,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0201,{"RB6_AVGVL" 		,9952.50						,Nil		})
	aadd(aAtLvl0201,{"RB6_CLASSE" 		,"002"							,Nil		})
	
	aadd(aAtLvl0202,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0202,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0202,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0202,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0202,{"RB6_NIVEL" 		,"02"							,Nil		})
	aadd(aAtLvl0202,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0202,{"RB6_VALOR" 		,10560							,Nil		})
	aadd(aAtLvl0202,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0202,{"RB6_AVGVL" 		,9952.50						,Nil		})
	aadd(aAtLvl0202,{"RB6_CLASSE" 		,"002"							,Nil		})
	
	// LEVEL 03
	aadd(aAtLvl0301,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0301,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0301,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0301,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0301,{"RB6_NIVEL" 		,"03"							,Nil		})
	aadd(aAtLvl0301,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0301,{"RB6_VALOR" 		,10039							,Nil		})
	aadd(aAtLvl0301,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0301,{"RB6_AVGVL" 		,10691.50						,Nil		})
	aadd(aAtLvl0301,{"RB6_CLASSE" 		,"003"							,Nil		})
	
	aadd(aAtLvl0302,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0302,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0302,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0302,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0302,{"RB6_NIVEL" 		,"03"							,Nil		})
	aadd(aAtLvl0302,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0302,{"RB6_VALOR" 		,11344							,Nil		})
	aadd(aAtLvl0302,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0302,{"RB6_AVGVL" 		,10691.50						,Nil		})
	aadd(aAtLvl0302,{"RB6_CLASSE" 		,"003"							,Nil		})
	
	// LEVEL 04
	aadd(aAtLvl0401,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0401,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0401,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0401,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0401,{"RB6_NIVEL" 		,"04"							,Nil		})
	aadd(aAtLvl0401,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0401,{"RB6_VALOR" 		,11107							,Nil		})
	aadd(aAtLvl0401,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0401,{"RB6_AVGVL" 		,11829							,Nil		})
	aadd(aAtLvl0401,{"RB6_CLASSE" 		,"004"							,Nil		})
	
	aadd(aAtLvl0402,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0402,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0402,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0402,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0402,{"RB6_NIVEL" 		,"04"							,Nil		})
	aadd(aAtLvl0402,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0402,{"RB6_VALOR" 		,12551							,Nil		})
	aadd(aAtLvl0402,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0402,{"RB6_AVGVL" 		,11829							,Nil		})
	aadd(aAtLvl0402,{"RB6_CLASSE" 		,"004"							,Nil		})
	
	// LEVEL 05
	aadd(aAtLvl0501,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0501,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0501,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0501,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0501,{"RB6_NIVEL" 		,"05"							,Nil		})
	aadd(aAtLvl0501,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0501,{"RB6_VALOR" 		,12335							,Nil		})
	aadd(aAtLvl0501,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0501,{"RB6_AVGVL" 		,13137							,Nil		})
	aadd(aAtLvl0501,{"RB6_CLASSE" 		,"005"							,Nil		})
	
	aadd(aAtLvl0502,{"RB6_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0502,{"RB6_TABELA" 		,cArea+"6"						,Nil		})
	aadd(aAtLvl0502,{"RB6_DESCTA" 		,cArea+" - Тариф06"				,Nil		})
	aadd(aAtLvl0502,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0502,{"RB6_NIVEL" 		,"05"							,Nil		})
	aadd(aAtLvl0502,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0502,{"RB6_VALOR" 		,13939							,Nil		})
	aadd(aAtLvl0502,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0502,{"RB6_AVGVL" 		,13137							,Nil		})
	aadd(aAtLvl0502,{"RB6_CLASSE" 		,"005"							,Nil		})
	
	
	aadd(aAutoItens,aAtLvl0101)
	aadd(aAutoItens,aAtLvl0102)
	aadd(aAutoItens,aAtLvl0201)
	aadd(aAutoItens,aAtLvl0202)
	aadd(aAutoItens,aAtLvl0301)
	aadd(aAutoItens,aAtLvl0302)
	aadd(aAutoItens,aAtLvl0401)
	aadd(aAutoItens,aAtLvl0402)
	aadd(aAutoItens,aAtLvl0501)
	aadd(aAutoItens,aAtLvl0502)
	
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

Return Nil