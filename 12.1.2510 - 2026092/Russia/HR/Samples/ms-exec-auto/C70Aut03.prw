#INCLUDE "Protheus.CH"
#INCLUDE "CSAA070.CH"


User Function C70Aut03(cType as Character,cArea as Character)
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
Local aAtLvl0601		:= {}
Local aAtLvl0602		:= {}    
Local aAtLvl0701		:= {} 
Local aAtLvl0702		:= {} 
Local aAtLvl0801		:= {} 
Local aAtLvl0802		:= {}  
Local aAtLvl0901		:= {} 
Local aAtLvl0902		:= {}
Local aAtLvl1001		:= {} 
Local aAtLvl1002		:= {}
                                      		
Private lMsErroAuto 	:= .F.

BEGIN TRANSACTION

	aadd(aAutoCab,  {"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAutoCab,  {"RBR_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAutoCab,  {"RBR_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAutoCab,  {"RBR_USAPOT" 		,2								,Nil		})
	aadd(aAutoCab,  {"RBR_TIPOVL" 		,1								,Nil		})
	aadd(aAutoCab,  {"RBR_DTSTAR" 		,Stod('20180101')				,Nil		})
	aadd(aAutoCab,  {"RBR_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAutoCab,  {"RBR_CDTYP" 		,cType							,Nil		})
	aadd(aAutoCab,  {"RBR_CDARE" 		,cArea							,Nil		})
	
	// LEVEL 01
	aadd(aAtLvl0101,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0101,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0101,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0101,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0101,{"RB6_NIVEL" 		,"01"							,Nil		})
	aadd(aAtLvl0101,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0101,{"RB6_VALOR" 		,12710							,Nil		})
	aadd(aAtLvl0101,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0101,{"RB6_AVGVL" 		,13750							,Nil		})
	aadd(aAtLvl0101,{"RB6_CLASSE" 		,"001"							,Nil		})
	
	
	aadd(aAtLvl0102,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0102,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0102,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0102,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0102,{"RB6_NIVEL" 		,"01"							,Nil		})
	aadd(aAtLvl0102,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0102,{"RB6_VALOR" 		,14790							,Nil		})
	aadd(aAtLvl0102,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0102,{"RB6_AVGVL" 		,13750							,Nil		})
	aadd(aAtLvl0102,{"RB6_CLASSE" 		,"001"							,Nil		})
	
	// LEVEL 02
	aadd(aAtLvl0201,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0201,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0201,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0201,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0201,{"RB6_NIVEL" 		,"02"							,Nil		})
	aadd(aAtLvl0201,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0201,{"RB6_VALOR" 		,13565							,Nil		})
	aadd(aAtLvl0201,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0201,{"RB6_AVGVL" 		,14847.50						,Nil		})
	aadd(aAtLvl0201,{"RB6_CLASSE" 		,"002"							,Nil		})
	
	aadd(aAtLvl0202,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0202,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0202,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0202,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0202,{"RB6_NIVEL" 		,"02"							,Nil		})
	aadd(aAtLvl0202,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0202,{"RB6_VALOR" 		,16130							,Nil		})
	aadd(aAtLvl0202,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0202,{"RB6_AVGVL" 		,14847.50						,Nil		})
	aadd(aAtLvl0202,{"RB6_CLASSE" 		,"002"							,Nil		})
	
	// LEVEL 03
	aadd(aAtLvl0301,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0301,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0301,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0301,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0301,{"RB6_NIVEL" 		,"03"							,Nil		})
	aadd(aAtLvl0301,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0301,{"RB6_VALOR" 		,14790							,Nil		})
	aadd(aAtLvl0301,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0301,{"RB6_AVGVL" 		,16250							,Nil		})
	aadd(aAtLvl0301,{"RB6_CLASSE" 		,"003"							,Nil		})
	
	aadd(aAtLvl0302,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0302,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0302,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"				,Nil		})
	aadd(aAtLvl0302,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0302,{"RB6_NIVEL" 		,"03"							,Nil		})
	aadd(aAtLvl0302,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0302,{"RB6_VALOR" 		,17730							,Nil		})
	aadd(aAtLvl0302,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0302,{"RB6_AVGVL" 		,16250							,Nil		})
	aadd(aAtLvl0302,{"RB6_CLASSE" 		,"003"							,Nil		})
	
	// LEVEL 04
	aadd(aAtLvl0401,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0401,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0401,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0401,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0401,{"RB6_NIVEL" 		,"04"							,Nil		})
	aadd(aAtLvl0401,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0401,{"RB6_VALOR" 		,16130							,Nil		})
	aadd(aAtLvl0401,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0401,{"RB6_AVGVL" 		,17997.50						,Nil		})
	aadd(aAtLvl0401,{"RB6_CLASSE" 		,"004"							,Nil		})
	
	aadd(aAtLvl0402,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0402,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0402,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0402,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0402,{"RB6_NIVEL" 		,"04"							,Nil		})
	aadd(aAtLvl0402,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0402,{"RB6_VALOR" 		,19865							,Nil		})
	aadd(aAtLvl0402,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0402,{"RB6_AVGVL" 		,17997.50						,Nil		})
	aadd(aAtLvl0402,{"RB6_CLASSE" 		,"004"							,Nil		})	
	
	// LEVEL 05
	aadd(aAtLvl0501,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0501,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0501,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0501,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0501,{"RB6_NIVEL" 		,"05"							,Nil		})
	aadd(aAtLvl0501,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0501,{"RB6_VALOR" 		,17730							,Nil		})
	aadd(aAtLvl0501,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0501,{"RB6_AVGVL" 		,20000							,Nil		})
	aadd(aAtLvl0501,{"RB6_CLASSE" 		,"005"							,Nil		})
	
	aadd(aAtLvl0502,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0502,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0502,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0502,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0502,{"RB6_NIVEL" 		,"05"							,Nil		})
	aadd(aAtLvl0502,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0502,{"RB6_VALOR" 		,22270							,Nil		})
	aadd(aAtLvl0502,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0502,{"RB6_AVGVL" 		,20000							,Nil		})
	aadd(aAtLvl0502,{"RB6_CLASSE" 		,"005"							,Nil		})
	
	// LEVEL 06
	aadd(aAtLvl0601,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0601,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0601,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0601,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0601,{"RB6_NIVEL" 		,"06"							,Nil		})
	aadd(aAtLvl0601,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0601,{"RB6_VALOR" 		,19865							,Nil		})
	aadd(aAtLvl0601,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0601,{"RB6_AVGVL" 		,22402.50						,Nil		})
	aadd(aAtLvl0601,{"RB6_CLASSE" 		,"006"							,Nil		})
	
	aadd(aAtLvl0602,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0602,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0602,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0602,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0602,{"RB6_NIVEL" 		,"06"							,Nil		})
	aadd(aAtLvl0602,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0602,{"RB6_VALOR" 		,24940							,Nil		})
	aadd(aAtLvl0602,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0602,{"RB6_AVGVL" 		,22402.50						,Nil		})
	aadd(aAtLvl0602,{"RB6_CLASSE" 		,"006"							,Nil		})
	
	// LEVEL 07
	aadd(aAtLvl0701,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0701,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0701,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0701,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0701,{"RB6_NIVEL" 		,"07"							,Nil		})
	aadd(aAtLvl0701,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0701,{"RB6_VALOR" 		,22270							,Nil		})
	aadd(aAtLvl0701,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0701,{"RB6_AVGVL" 		,25100							,Nil		})
	aadd(aAtLvl0701,{"RB6_CLASSE" 		,"007"							,Nil		})
	
	aadd(aAtLvl0702,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0702,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0702,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0702,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0702,{"RB6_NIVEL" 		,"07"							,Nil		})
	aadd(aAtLvl0702,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0702,{"RB6_VALOR" 		,27930							,Nil		})
	aadd(aAtLvl0702,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0702,{"RB6_AVGVL" 		,25100							,Nil		})
	aadd(aAtLvl0702,{"RB6_CLASSE" 		,"007"							,Nil		})
	
	// LEVEL 08
	aadd(aAtLvl0801,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0801,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0801,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0801,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0801,{"RB6_NIVEL" 		,"08"							,Nil		})
	aadd(aAtLvl0801,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0801,{"RB6_VALOR" 		,24940							,Nil		})
	aadd(aAtLvl0801,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0801,{"RB6_AVGVL" 		,28115							,Nil		})
	aadd(aAtLvl0801,{"RB6_CLASSE" 		,"008"							,Nil		})
	
	aadd(aAtLvl0802,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0802,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0802,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0802,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0802,{"RB6_NIVEL" 		,"08"							,Nil		})
	aadd(aAtLvl0802,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0802,{"RB6_VALOR" 		,31290							,Nil		})
	aadd(aAtLvl0802,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0802,{"RB6_AVGVL" 		,25100							,Nil		})
	aadd(aAtLvl0802,{"RB6_CLASSE" 		,"008"							,Nil		})
	
	// LEVEL 09
	aadd(aAtLvl0901,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0901,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0901,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0901,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0901,{"RB6_NIVEL" 		,"09"							,Nil		})
	aadd(aAtLvl0901,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl0901,{"RB6_VALOR" 		,27930							,Nil		})
	aadd(aAtLvl0901,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0901,{"RB6_AVGVL" 		,31480							,Nil		})
	aadd(aAtLvl0901,{"RB6_CLASSE" 		,"009"							,Nil		})
	
	aadd(aAtLvl0902,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl0902,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl0902,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl0902,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl0902,{"RB6_NIVEL" 		,"09"							,Nil		})
	aadd(aAtLvl0902,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl0902,{"RB6_VALOR" 		,35030							,Nil		})
	aadd(aAtLvl0902,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl0902,{"RB6_AVGVL" 		,31480							,Nil		})
	aadd(aAtLvl0902,{"RB6_CLASSE" 		,"009"							,Nil		})
	
	// LEVEL 10
	aadd(aAtLvl1001,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl1001,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl1001,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl1001,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl1001,{"RB6_NIVEL" 		,"10"							,Nil		})
	aadd(aAtLvl1001,{"RB6_FAIXA" 		,"01"							,Nil		})
	aadd(aAtLvl1001,{"RB6_VALOR" 		,31290							,Nil		})
	aadd(aAtLvl1001,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl1001,{"RB6_AVGVL" 		,35270							,Nil		})
	aadd(aAtLvl1001,{"RB6_CLASSE" 		,"010"							,Nil		})
	
	aadd(aAtLvl1002,{"RBR_FILIAL" 		,xFilial("RBR")					,Nil		})
	aadd(aAtLvl1002,{"RB6_TABELA" 		,cArea+"3"						,Nil		})
	aadd(aAtLvl1002,{"RB6_DESCTA" 		,cArea+" - " + STR0110 + "03"	,Nil		})
	aadd(aAtLvl1002,{"RB6_TIPOVL" 		,1  							,Nil		})
	aadd(aAtLvl1002,{"RB6_NIVEL" 		,"10"							,Nil		})
	aadd(aAtLvl1002,{"RB6_FAIXA" 		,"02"							,Nil		})
	aadd(aAtLvl1002,{"RB6_VALOR" 		,39250							,Nil		})
	aadd(aAtLvl1002,{"RB6_DTREF" 		,Stod('99991231')				,Nil		})
	aadd(aAtLvl1002,{"RB6_AVGVL" 		,35270							,Nil		})
	aadd(aAtLvl1002,{"RB6_CLASSE" 		,"010"							,Nil		})
	
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
	aadd(aAutoItens,aAtLvl0601)
	aadd(aAutoItens,aAtLvl0602)
	aadd(aAutoItens,aAtLvl0701)
	aadd(aAutoItens,aAtLvl0702)
	aadd(aAutoItens,aAtLvl0801)
	aadd(aAutoItens,aAtLvl0802)
	aadd(aAutoItens,aAtLvl0901)
	aadd(aAutoItens,aAtLvl0902)
	aadd(aAutoItens,aAtLvl1001)
	aadd(aAutoItens,aAtLvl1002)
	
	// Call routine Contract Data with operation 3 (Insert)
	MSExecAuto({|x,y,k,w| CSAA070(x,y,k,w)},aAutoCab,aAutoItens,3,NIL)  
	
	If lMsErroAuto
		DisarmTransaction()
		break
	EndIf

END TRANSACTION

If !lMsErroAuto
    ConOut("**** "+STR0111+"  ****") //Included with Success
Else
    MostraErro()
    ConOut(STR0112) //Error on Include!
EndIf

Return lMsErroAuto