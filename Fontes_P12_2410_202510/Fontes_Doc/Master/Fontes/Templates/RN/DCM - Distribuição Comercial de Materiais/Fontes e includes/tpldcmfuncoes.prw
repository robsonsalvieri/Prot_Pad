#INCLUDE "PROTHEUS.CH"
#INCLUDE "TPLDCMFUNCOES.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"  

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ Cria_SX1 ∫Autor  ≥Vendas Clientes     ∫ Data ≥  11.07.03   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Cria Grupo de Perguntas                                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Sintaxe   ≥ Cria_SX1() 									    		  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Parametros≥ Grupo de Perguntas,Array com Novas Perguntas	    		  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/  

Template Function Cria_SX1( PcPerg, PaRegs )
Local aAreaAnt	:= GetArea()
Local aRegs		:= PaRegs
Local cPerg		:= PadR(PcPerg,Len(SX1->X1_GRUPO))
Local nI		:= 0		//Controle de loop
Local nJ		:= 0		//Controle de loop
CHKTEMPLATE("DCM")

DbSelectArea("SX1")
DbSetorder(1)

/*Exemplo de Array ARegs para Versao 6.09
AADD(aRegs,{cPerg	,"01","Produto de?"	        ,"","","mv_ch1"	,"C", 15	,0	,1	,"G",""	,"mv_par01"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"SB1"	,"","",""})
AADD(aRegs,{cPerg	,"02","Produto Ate?"		,"","","mv_ch2"	,"C", 15	,0	,1	,"G",""	,"mv_par02"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"SB1"	,"","",""})
AADD(aRegs,{cPerg	,"03","Fornecedor de?" 		,"","","mv_ch3"	,"C", 06	,0	,1	,"G",""	,"mv_par03"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"SA2"	,"","",""})
AADD(aRegs,{cPerg	,"04","Fornecedor ate?"		,"","","mv_ch4"	,"C", 06	,0	,1	,"G",""	,"mv_par04"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"SA2"	,"","",""})
AADD(aRegs,{cPerg	,"05","Local de?" 			,"","","mv_ch5"	,"C", 02	,0	,1	,"G",""	,"mv_par05"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"DI"	,"","",""})
AADD(aRegs,{cPerg	,"06","Local Ate?"			,"","","mv_ch6"	,"C", 02	,0	,1	,"G",""	,"mv_par06"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"DI"	,"","",""})
AADD(aRegs,{cPerg	,"07","Localizacao de?"     ,"","","mv_ch7"	,"C", 10	,0	,1	,"G",""	,"mv_par07"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""		,"","",""})
AADD(aRegs,{cPerg	,"08","Localizacao ate?"	,"","","mv_ch8"	,"C", 10	,0	,1	,"G",""	,"mv_par08"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""		,"","",""})
AADD(aRegs,{cPerg	,"09","Tipo de?"			,"","","mv_ch9"	,"C", 02	,0	,1	,"G",""	,"mv_par09"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"02"	,"","",""})
AADD(aRegs,{cPerg	,"10","Tipo ate?"	        ,"","","mv_chA"	,"C", 02	,0	,1	,"G",""	,"mv_par10"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"02"	,"","",""})
AADD(aRegs,{cPerg	,"11","Grupo de?"        	,"","","mv_chB"	,"C", 04	,0	,1	,"G",""	,"mv_par11"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"Z10"	,"","",""})
AADD(aRegs,{cPerg	,"12","Grupo ate?"			,"","","mv_chC"	,"C", 04	,0	,1	,"G",""	,"mv_par12"	,""				,""	,""	,""	,""	,""				,""	,""	,""	,""	,""			,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,""	,"Z10"	,"","",""})
*/

/* 7.10
AADD(aRegs,{cPerg,"01","Enviar Tipos ?   "     ,"Enviar Tipos ?   "     ,"Enviar Tipos ?   "     ,"mv_ch1","C",30,0,0 ,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"02","Nao Enviar Tipos ?   " ,"Nao Enviar Tipos ?   " ,"Nao Enviar Tipos ?   " ,"mv_ch2","C",30,0,0 ,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"03","Enviar Situacoes ?"    ,"Enviar Situacoes ?"    ,"Enviar Situacoes ?"    ,"mv_ch3","C",30,0,0 ,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"04","Nao Enviar Situacoes?" ,"Nao Enviar Situacoes ?","Nao Enviar Situacoes ?","mv_ch4","C",30,0,0 ,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"05","Nr. dias p/Vencidos ?" ,"Nr. dias p/Vencidos ?" ,"Nr. dias p/Vencidos ?" ,"mv_ch5","N",2,0,0  ,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"06","Data Base ?"           ,"øFecha de Hoy ?"       ,"Base Date ?"           ,"mv_ch6","D",8,0,0  ,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"07","Arq. Saida PJ?"        ,"Arq. Saida PJ?"        ,"Arq. Saida PJ ?"       ,"mv_ch7","C",20,0,0 ,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"08","Arq. Saida PF?"        ,"Arq. Saida PF?"        ,"Arq. Saida PF ?"       ,"mv_ch8","C",20,0,0 ,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
*/

/* 8.11
AADD(aRegs,{cPerg,"01","Enviar Tipos ?   "     ,"Enviar Tipos ?   "     ,"Enviar Tipos ?   "     ,"mv_ch1","C",30,0,0 ,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"02","Nao Enviar Tipos ?   " ,"Nao Enviar Tipos ?   " ,"Nao Enviar Tipos ?   " ,"mv_ch2","C",30,0,0 ,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"03","Enviar Situacoes ?"    ,"Enviar Situacoes ?"    ,"Enviar Situacoes ?"    ,"mv_ch3","C",30,0,0 ,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegs,{cPerg,"04","Nao Enviar Situacoes?" ,"Nao Enviar Situacoes ?","Nao Enviar Situacoes ?","mv_ch4","C",30,0,0 ,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
AADD(aRegs,{cPerg,"05","Nr. dias p/Vencidos ?" ,"Nr. dias p/Vencidos ?" ,"Nr. dias p/Vencidos ?" ,"mv_ch5","N",2,0,0  ,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
AADD(aRegs,{cPerg,"06","Data Base ?"           ,"øFecha de Hoy ?"       ,"Base Date ?"           ,"mv_ch6","D",8,0,0  ,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
AADD(aRegs,{cPerg,"07","Arq. Saida PJ?"        ,"Arq. Saida PJ?"        ,"Arq. Saida PJ ?"       ,"mv_ch7","C",20,0,0 ,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
AADD(aRegs,{cPerg,"08","Arq. Saida PF?"        ,"Arq. Saida PF?"        ,"Arq. Saida PF ?"       ,"mv_ch8","C",20,0,0 ,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})
*/

For nI := 1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[nI,2])
		RecLock("SX1",.T.)
		For nJ := 1 to FCount()
			If nJ <= Len(aRegs[nI])
				FieldPut(nJ,aRegs[nI,nJ])
			EndIf
		Next nJ
		MsUnlock()
	Endif
Next nI

RestArea(aAreaAnt)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SRArea    ∫Autor  ≥Vendas Clientes     ∫ Data ≥  09/02/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Template Function SRArea(cOper,aAreas)
Local nX		:= 0 //Controle de loop
Local aAlias
Local lContinua
Local nAreas
CHKTEMPLATE("DCM")

If cOper == "S"
	aAlias    := {}
	lContinua := .T.
	nAreas    := 1
	While lContinua
		If Alias(nAreas) <> ''
			DbSelectArea(Alias(nAreas))
			AAdd(aAlias,{ nAreas, Alias(), IndexOrd(), Recno()})
		Else
			lContinua := .F.
		EndIf
		++nAreas
	End
	Return(aAlias)
ElseIf cOper == "R"
	aSort(aAreas,,,{|x,y|x[1]>y[1]})
	For nX := 1 To Len(aAreas)
		DbSelectArea(aAreas[nX,2])
		DbSetorder(aAreas[nX,3])
		DbGoto(aAreas[nX,4])
	Next nX
EndIf

Return(.T.)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ValPergUsu∫Autor  ≥Vendas Clientes     ∫ Data ≥  08/22/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function ValPergUsu( cPergPad, cPergUsu )
Local _sAlias := Alias()
Local aRegs   := {}
Local nI	  := 0 		//Controle de loop
Local nJ	  := 0 		//Controle de loop
Local _cPerg
CHKTEMPLATE("DCM")

DbSelectArea("SX1")
DbSetorder(1)
_cPerg := PADR(cPergUsu,Len(SX1->X1_GRUPO))

//   Array  Varia Ord  Pergunta               PI PE  Varia   Tp  Ta D P TC  Vld Vr        Df             DI DE Cn Vr Df            DI DE Cn Vr Df        DI DE Cn Vr Df DI DE Cn Vr Df DI DE Cn F3    Py Gr Hp
//                                                                                                              1                         2                     3              4              5
If DbSeek(cPergPad)
	While SX1->(! Eof() ) .AND. SX1->X1_GRUPO == PADR(cPergPad,Len(SX1->X1_GRUPO))
		AADD(aRegs,{	cPergUsu  , X1_ORDEM  , X1_PERGUNT, X1_PERSPA ,;
						X1_PERENG , X1_VARIAVL, X1_TIPO   , X1_TAMANHO,;
						X1_DECIMAL, X1_PRESEL , X1_GSC    , X1_VALID  ,;
						X1_VAR01  , X1_DEF01  , X1_DEFSPA1, X1_DEFENG1,;
						X1_CNT01  , X1_VAR02  , X1_DEF02  , X1_DEFSPA2,;
						X1_DEFENG2, X1_CNT02  , X1_VAR03  , X1_DEF03  ,;
						X1_DEFSPA3, X1_DEFENG3, X1_CNT03  , X1_VAR04  ,;
						X1_DEF04  , X1_DEFSPA4, X1_DEFENG4, X1_CNT04  ,;
						X1_VAR05  , X1_DEF05  , X1_DEFSPA5, X1_DEFENG5,;
						X1_CNT05  , X1_F3     , X1_PYME   , X1_GRPSXG ,;
						X1_HELP})
		DbSkip()
	End
EndIf

For nI := 1 To Len(aRegs)
	If !DbSeek(_cPerg+aRegs[nI,2])
		RecLock("SX1",.T.)
		For nJ := 1 to FCount()
			If nJ <= Len(aRegs[nI])
				FieldPut(nJ,aRegs[nI,nJ])
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

DbSelectArea(_sAlias)

Return
//-----------------> PONTOS DE ENTRADAS UTILIZADOS NO DCM <-----------------//
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ TMKVCA  ≥ Autor ≥ Vendas Clientes        ≥ Data ≥ 01/12/00 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Ponto de Entrada em que trata a Consulta dos Produtos      ≥±±
±±≥          | Bot„o Caracteristicas dos Produto                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/    
Template Function TMKVCA() 
Local _aAreaVCA := GetArea()

CHKTEMPLATE("DCM")

If ExistBlock("DCMTMKC01")
	If Alias() = 'SB1'
		U_DCMTMKC01(SB1->B1_COD)
	ElseIf Alias() = 'LH7'
		U_DCMTMKC01(LH7->LH7_COD)
	ElseIf Alias() = 'TCP'
		U_DCMTMKC01(TCP->T_CODPRO)
	Else
		U_DCMTMKC01(aCols[n,aScan(aHeader,{|e|Trim(e[2])=="UB_PRODUTO"})],aCols[n,aScan(aHeader,{|e|Trim(e[2])=="UB_LOCAL"})])
	EndIf
Else
	If Alias() = 'SB1'
		T_TTMKC01(SB1->B1_COD)
	ElseIf Alias() = 'LH7'
		T_TTMKC01(LH7->LH7_COD)
	ElseIf Alias() = 'TCP'
		T_TTMKC01(TCP->T_CODPRO)
	Else
		T_TTMKC01(aCols[n,aScan(aHeader,{|e|Trim(e[2])=="UB_PRODUTO"})],aCols[n,aScan(aHeader,{|e|Trim(e[2])=="UB_LOCAL"})])
	EndIf
EndIf
RestArea(_aAreaVCA)
 
Return(.T.)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TMKVCP    ∫Autor  ≥Vendas Clientes	 ∫ Data ≥  04/04/01   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ P.E. acionado para gravacao de dados dos dados do          ∫±±
±±∫          ≥ centro de custo do cliente                                 ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function TMKVCP( p1 , p2 , p3 , p4 ,;
						  p5 , p6 , p7 , p8 ,;
						  p9 , p10, p11, p12,;
						  p13, p14, p15, p16,;
						  p17, p18, p19, p20,;
						  p21, p22, p23, p24,;
						  p25, p26, p27, p28,;
						  p29)

CHKTEMPLATE("DCM")

If FindFunction("U_DTMKVCP")
	U_DTMKVCP(p1 , p2 , p3 , p4 ,;
			  p5 , p6 , p7 , p8 ,;
			  p9 , p10, p11, p12,;
			  p13, p14, p15, p16,;
			  p17, p18, p19, p20,;
			  p21, p22, p23, p24,;
			  p25, p26, p27, p28,;
			  p29)
Else
	LH2->(DbSetorder(5))
	IF LH2->(DbSeek(xFilial("LH2")+M->UA_CLIENTE+M->UA_LOJA+M->UA_CODREQ))
		M->UA_ENDENT  := LH2->LH2_ENDENT
		M->UA_BAIRROE := LH2->LH2_BAIRRO
		M->UA_MUNE    := LH2->LH2_CIDADE
		M->UA_CEPE    := LH2->LH2_CEP
		M->UA_ESTE    := LH2->LH2_EST
		
		M->UA_ENDCOB  := LH2->LH2_ENDCOB
		M->UA_BAIRROC := LH2->LH2_BAIRROC
		M->UA_MUNC    := LH2->LH2_CIDADEC
		M->UA_CEPC    := LH2->LH2_CEPC
		M->UA_ESTC    := LH2->LH2_ESTADOC
	Else
		Posicione('SA1',1,xFilial('SA1')+M->UA_CLIENTE+M->UA_LOJA,'')
		M->UA_ENDCOB  := SA1->A1_ENDCOB
		M->UA_BAIRROC := SA1->A1_BAIRROC
		M->UA_MUNC    := SA1->A1_MUNC
		M->UA_CEPC    := SA1->A1_CEPC
		M->UA_ESTC    := SA1->A1_ESTC
		
		M->UA_ENDENT  := SA1->A1_ENDENT
		M->UA_BAIRROE := SA1->A1_BAIRROE
		M->UA_MUNE    := SA1->A1_MUNE
		M->UA_CEPE    := SA1->A1_CEPE
		M->UA_ESTE    := SA1->A1_ESTE
	EndIf
	
	If !Empty(M->UA_CODREQ)
		
		DEFINE MSDIALOG oDlgPagto FROM  000,000 TO 016,063 TITLE (STR0001) //"Confirmar os Dados e Endereco por Requisitante"
		
		@ 004,002 TO 036,248
		@ 010,004 SAY (STR0002) //"CondiáÑo"
		@ 008,045 GET p29 SIZE 30,8 Picture "@!" WHEN .F.
		
		@ 010,084 SAY (STR0003) //"Transportadora"
		@ 008,125 GET p3 Picture "@!" SIZE 120,8 WHEN .F.
		
		@ 022,004 SAY (STR0004) //"Requisitante"
		@ 020,045 GET M->UA_CODREQ SIZE 40,8 Picture "@!" WHEN .F.
		@ 020,085 GET M->UA_NOMEREQ SIZE 60,8 Picture "@!" WHEN .F.
		
		@ 022,156 SAY (STR0005) //"Ped.Cliente"
		@ 020,185 GET M->UA_REQCLI SIZE 60,8 Picture "@!" WHEN .F.
		
		@ 044,002 TO 107,248
		@ 036,002 SAY (STR0006) //"Dados Complementares"
		
		@ 046,004 SAY (STR0007) //"Cobranca"
		@ 046,045 GET M->UA_ENDCOB Picture "@!" SIZE 115,8
		
		@ 046,167 SAY (STR0008) //"Bairro"
		@ 046,185 GET M->UA_BAIRROC Picture "@!" SIZE 60,8
		
		@ 061,004 SAY (STR0009) //"Cidade"
		@ 061,045 GET M->UA_MUNC Picture "@!" SIZE 80,8
		
		@ 061,130 SAY (STR0010) //"CEP"
		@ 061,150 GET M->UA_CEPC Picture "@R 99999-999" SIZE 40,8
		
		@ 061,200 SAY (STR0011) SIZE 20,8 //"Estado"
		@ 061,220 GET M->UA_ESTC Picture "@!" SIZE 12,8
		
		@ 076,004 SAY (STR0012) //"Entrega"
		@ 076,045 GET M->UA_ENDENT Picture "@!" SIZE 115,8
		
		@ 076,167 SAY (STR0008) //"Bairro"
		@ 076,185 GET M->UA_BAIRROE Picture "@!" SIZE 60,8
		
		@ 091,004 SAY (STR0009) //"Cidade"
		@ 091,045 GET M->UA_MUNE Picture "@!"  SIZE 80,8
		
		@ 091,130 SAY (STR0010) //"CEP"
		@ 091,150 GET M->UA_CEPE Picture "@R 99999-999"	SIZE 40,8
		
		@ 091,200 SAY (STR0011) SIZE 20,8 //"Estado"
		@ 091,220 GET M->UA_ESTE  Picture "@!" SIZE 12,8
		
		DEFINE SBUTTON FROM 109,215 TYPE 1 ACTION {||nOpcA:=1,oDlgPagto:End()} ENABLE
		
		ACTIVATE MSDIALOG oDlgPagto CENTERED
	EndIf
EndIf
Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ TKGRPED ≥ Autor ≥ Vendas Clientes        ≥ Data ≥ 29/11/00 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Ponto de Entrada para o tratamento do calculo dos itens    ≥±±
±±≥          | no Televendas                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function TKGRPED()
Local _cProdDp 	:= ""
Local _lGeraPen := .F.
Local _nRecSC9  := 0
Local _nValorPen:= 0   
Local _nI, _nX, _nY
Local _aConfTes := {}

If FindFunction("U_DTKGRPED")
	Return U_DTKGRPED()
Else	
	If aValores[2] > 0
		MsgStop(STR0060 ) //'Campo de Desconto preenchido, favor deixar o Campo Zerado'
		Return(.F.)
	Endif
	
	If !lProspect .And. SA1->(FieldPos("A1_MSBLQL")) > 0 .And. SA1->A1_MSBLQL == '1'
		MsgStop(STR0061) //'Cliente Bloqueado pelo Financeiro!'
		Return(.F.)
	Endif
	
	If SA3->(FieldPos("A3_MSBLQL")) > 0 .And. SA3->A3_MSBLQL == '1'
		MsgStop(STR0062 ) //'Vendedor Bloqueado pelo Comercial!'
		Return(.F.)
	Endif
	
	_aAreaTKGR:= GetArea()
	
	SU7->(DbSetOrder(1))
	
	SC9->(DbSetOrder(1))
	
	SUA->(DbSetOrder(1))
	SUA->(DbSeek(xFilial("SUA") + M->UA_NUM))
	_nPosPro  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_PRODUTO"})
	_nPosPrD  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_DESCRI"})
	_nPosLoc  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_LOCAL"  })
	_nPosQtd  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_QUANT"  })
	_nPosQtA  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_QTDANT" })
	_nPosVU   := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_VRUNIT" })
	_nPosTab  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_PRCTAB" })
	_nPosTES  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_TES"    })
	_nPosCF   := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_CF"     })
	_nPosIte  := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_ITEM"   })
	_nPosPMax := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_VLRMAX" })
	_nPosTotal:= aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_VLRITEM" })
	_nPosPCom := aScan(aHeader,{|x| UPPER(AllTrim(x[2]))=="UB_PERCOM" })
	
	_aCopia  := aClone(aCols)
	
	aSort(_aCopia,,, { |x, y| x[_nPosPro] < y[_nPosPro] })
	TC_VlrPed := 0
	TC_VlrDig := 0
	
	For _nI := 1 to Len(_aCopia)
		If _aCopia[_nI,Len(aHeader)+1] == .F.
			If _aCopia[_nI,_nPosQtd] <= 0
				If Empty(_aCopia[_nI,_nPosPro])
					MsgStop(STR0014 )  //"Verifique se n„o existe algum item em branco"
				Else
					MsgStop(STR0015 + _aCopia[_nI,_nPosPro]+ STR0016 +Str(_aCopia[_nI,_nPosQtd])) //"Produto " - " com Quantidade Invalida -> "
				Endif
				RestArea(_aAreaTKGR)
				Return .F.
			EndIf
		EndIf
		If _cProdDp == _aCopia[_nI,_nPosPro] .And. !Empty(_aCopia[_nI,_nPosPro]) .And. SubStr(M->UA_REQCLI,1,1) <> 'F'
			MsgStop(STR0015 +_aCopia[_nI,_nPosPro]+ STR0017 ) // "Produto "  - " duplicado!"
			RestArea(_aAreaTKGR)
			Return .F.
		EndIf
		_cProdDp := _aCopia[_nI,_nPosPro]
	Next _nI
	
	If M->UA_OPER == "1"
	
		// Preencher o cadastro de habilidades com a descriÁ„o de Representante para liberar acesso externo sem colocacao de pedidos, somente
		// orÁamentos	
		If ("REPRESENTANTE" $ Tabela("A4",SU7->U7_HABIL,.F.) .And. Alltrim(Upper(SU7->U7_NOME)) == Alltrim(Upper(CUSERNAME))) .Or.;
			(Alltrim(Upper(SU7->U7_NOME)) <> Alltrim(Upper(CUSERNAME)) .And. "REPRESENTANTE" $ Tabela("A4",Posicione("SU7",3,xFilial("SU7")+Alltrim(CUSERNAME),"U7_HABIL"),.F.))
			Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO,"")
			MsgStop(STR0063 ) //"Este operador nao pode gravar pedidos, grave como OrÁamento!"
			Return .F.
		Else
			Posicione("SU7",1,xFilial("SU7")+M->UA_OPERADO,"")
		Endif
		
		If Empty(M->UA_TRANSP)
			MsgStop(STR0064)  //"Informe a Transportadora!"
			Return .F.
		Endif
		
		If !Empty(M->UA_TRANSP) .And. Empty(Posicione("SA4",1,xFilial("SA4")+M->UA_TRANSP,"A4_NOME"))
			MsgStop(STR0003 + M->UA_TRANSP+ STR0065  )  //"Transportadora " - " Invalida!"
			Return .F.
		Endif
	
		If !Empty(Posicione("SE4",1,xFilial("SE4")+M->UA_CONDAF,"E4_ACREDCM")) .And. !MsgYesNo(STR0094+RTrim(Str(SE4->E4_ACREDCM,6,4))+"?") //"Confirma que a CondiÁ„o de Pagamento tem Desconto/Acrescimo de "
			Return .F.
		Endif
			
		If !MsgYesNo(STR0066 +If(M->UA_TPFRETE="F","FOB","CIF")+ STR0067 +RTrim(Posicione("SA4",1,xFilial("SA4")+M->UA_TRANSP,"A4_NOME"))+"?")  //"Confirma o Frete " - ", com Transportadora "
			Return .F.
		Endif
		
		If SU7->(DbSeek(xFilial("SU7")+M->UA_OPERADO)) 
			_cItenSem := ''
			_cItemLoc := ''
			_nValorPen:=0
			_nRecSC9 := SC9->(Recno())
			SB2->(DbSetOrder(1))
			For _nX:=1 To Len(aCols)
				If  aCols[_nX,Len(aHeader)+1] == .F.
					If Empty(aCols[_nX,_nPosLoc])
						_cItemLoc += STR0068 +aCols[_nX,_nPosIte]+' '+aCols[_nX,_nPosPro]+' '+aCols[_nX,_nPosPrD]+Chr(13) //'Item sem Local de Estoque Informado: '
					EndIf
					If SB2->(DbSeek(xFilial('SB2')+aCols[_nX,_nPosPro]+aCols[_nX,_nPosLoc]))
						_nMix := 0
						If T_BuscaSalCon(M->UA_CLIENTE,M->UA_LOJA,aCols[_nX,_nPosPro]) = 0
							_nMix := T_BuscaSalCon('','',aCols[_nX,_nPosPro])
						EndIf
						If aCols[_nX,_nPosQtA] > 0 .And. !Empty(M->UA_NUMSC5)
							_nAvalProd := 0
							If SC9->(DbSeek(xFilial("SC9")+M->UA_NUMSC5+aCols[_nX,_nPosIte]))
								While SC9->(!Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == M->UA_NUMSC5 .And. SC9->C9_ITEM == aCols[_nX,_nPosIte]
									If Empty(SC9->C9_BLEST)
										_nAvalProd += SC9->C9_QTDLIB
									EndIf
									SC9->(DbSkip())
								End  
							EndIf
							_nDispo   := (SB2->(SaldoMov()) - _nMix) + _nAvalProd
						Else
							_nDispo   := (SB2->(SaldoMov()) - _nMix)
						EndIf
						If _nDispo < aCols[_nX,_nPosQtd]
							_nValorPen += (aCols[_nX,_nPosVU]*aCols[_nX,_nPosQtd])
							IF SF4->(DbSeek(xFilial("SF4")+aCols[_nX,_nPosTES]))
								if SF4->F4_ESTOQUE = 'S'
									_cItenSem += aCols[_nX,_nPosPro]+' '+SubStr(aCols[_nX,_nPosPrD],1,20)+STR0095+Str(aCols[_nX,_nPosQtd],10,0)+STR0096+Str(_nDispo,10,0)+Chr(13)+Chr(10) //' Pedido: '###' Disp.: '
								EndIf
							Else
								_cItenSem += aCols[_nX,_nPosPro]+' '+SubStr(aCols[_nX,_nPosPrD],1,20)+STR0095+Str(aCols[_nX,_nPosQtd],10,0)+STR0096+Str(_nDispo,10,0)+Chr(13)+Chr(10) //' Pedido: '###' Disp.: '
							EndIf
						EndIf
					EndIf
				EndIf
			Next
			SC9->(DbGoTo(_nRecSC9))
			If !Empty(_cItemLoc)
				MsgBox(_cItemLoc, STR0021 ,STR0069 )  // 'Informacao' - 'STOP'
				RestArea(_aAreaTKGR)
				Return(.F.)
			EndIf
			If !Empty(_cItenSem)
				_aCondPen := Condicao(_nValorPen,M->UA_CONDPG,,ddatabase)
				aParcela   := T_Prazo( AllTrim(M->UA_CONDPG), "," )
				_nTotal    := 0
				For _nX := 1 To Len( aParcela )
					_nTotal += If(_nX>len(aParcela),0,Val(aParcela[_nX]))
				Next
				nMedia  := _nTotal / Len(aParcela)
				nUltDia :=	Val(aParcela[Len(aParcela)])
				
				_cItenSem += Chr(13)+Chr(10)
				_cItenSem += STR0070 +Alltrim(Str(_nValorPen,10,2))+Chr(13)+Chr(10) //"Valor para Faturamento de Pendencia: "
				_cItenSem += Chr(13)+Chr(10)
				_cItenSem += STR0071 + Chr(13)+Chr(10) //"Parcelas Conforme CondiÁ„o: "
				For _nY := 1 To Len(_aCondPen)
					_cItenSem += STR0097+Alltrim(Str(_nY,2))+": "+Alltrim(Str(_aCondPen[_nY,2],10,2))+" - "+DTOC(_aCondPen[_nY,1])+Chr(13)+Chr(10) //"Parcela " //"Parcela "
				Next
				_cItenSem += Chr(13)+Chr(10)
				_cItenSem += STR0098+Alltrim(Str(nMedia,4))+If(nMedia<>nUltDia," - "+STR0099+Alltrim(Str(nUltDia,4)),"") //"MÈdia: "###"Ultimo Dia: "
				_cItenSem += Chr(13)+Chr(10)
				_cItenSem += STR0100+M->UA_POLITIC+Chr(13)+Chr(10) //"Politica: "
				
				_nRes := Aviso(STR0101,_cItenSem,{"Sim","N„o"},3, STR0072 ) //"Estoque Indisponivel, Confirma?" //"InformaÁ„o"
				
				T_EmailPen(_cItenSem, STR0073) //"Pendencias do OrÁamento"
				
				If _nRes = 2
					RestArea(_aAreaTKGR)
					Return(.F.)
				ElseIf _nRes = 3
					MsgInfo(STR0074 ) //"OpÁ„o ainda nao disponivel..."
					RestArea(_aAreaTKGR)
					Return(.F.)
				Else
					_lGeraPen := .T.
				EndIf
			EndIf
		Else
			_lGeraPen := .T.
		EndIf
		
		_cMsg  := ""
		_lDtEntS := .F.
		For _nX := 1 To Len(aCols)
			If aCols[_nX,Len(aHeader)+1] == .F.
				
				_cProduto := aCols[_nX,_nPosPro]
				_nQtde    := aCols[_nX,_nPosQtd]
				_nQtdeA   := aCols[_nX,_nPosQtA]
				cLocal    := aCols[_nX,_nPosLoc]
				_nPerCom  := aCols[_nX,_nPosPCom]
				
				If (!(SubStr(aCols[_nX,_nPosCF],1,1) $ "5/6") .And. SA1->A1_EST <> "XX") .Or.;
					(SubStr(aCols[_nX,_nPosCF],1,1) <> "5" .And. SA1->A1_EST == Alltrim(GetMv("MV_ESTADO"))) .Or.;
					(SubStr(aCols[_nX,_nPosCF],1,1) <> "6" .And. SA1->A1_EST <> Alltrim(GetMv("MV_ESTADO")))
					MsgStop("CFOP "+aCols[_nX,_nPosCF]+ STR0075 +aCols[_nX,_nPosIte]) //" Invalido para o Cliente! Verifique o Item: "
					RestArea(_aAreaTKGR)
					Return(.F.)
				EndIf
				
				If AsCan(_aConfTes,aCols[_nX,_nPosTES]) = 0 .And. Len(_aConfTes) = 0
					AaDd(_aConfTes,aCols[_nX,_nPosTES])
				ElseIf _aConfTes[1] <> aCols[_nX,_nPosTES]
					MsgStop( STR0076 +aCols[_nX,_nPosTES]+ STR0077 +aCols[_nX,_nPosIte])  //"Mais de uma TES no Pedido! TES:" - ", Verifique o Item: " 
					RestArea(_aAreaTKGR)
					Return(.F.)
				EndIf
				
				If !Empty(M->UA_NUMSC5)
					SC9->(DbSetOrder(1))                   
					If SC9->(DbSeek(xFilial("SC9")+M->UA_NUMSC5+StrZero(_nX,2))) .And. !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST <> '10'
						_nQtdeA := 0
					EndIf
				EndIf
				
				SB2->(DbSeek(xFilial('SB2')+_cProduto+cLocal))
				If ((SaldoSB2() + _nQtdeA) - _nQtde) < 0 .And. !_lGeraPen
					If SF4->(DbSeek(xFilial("SF4")+aCols[_nX,_nPosTES]))
						If SF4->F4_ESTOQUE = 'S'
							MsgStop(STR0078 +_cProduto+ STR0079 +cLocal+Chr(13)+ STR0080 +Str(SaldoSB2())) //"Saldo Insuficiente para o Produto " - " no Almoxarifado " - "O saldo para esse produto e de "
							RestArea(_aAreaTKGR)
							Return .F.
						EndIf
					Else
						MsgStop( STR0078 +_cProduto+ STR0079 +cLocal+Chr(13)+ STR0080 +Str(SaldoSB2())) //"Saldo Insuficiente para o Produto " - " no Almoxarifado " - "O saldo para esse produto e de "
						RestArea(_aAreaTKGR)
						Return .F.
					EndIf
				EndIf
				
			EndIf
			_aAreaSUB := SUB->(GetArea())
			SUB->(DbSetOrder(3))
			If (altera .or. (!altera .and. !inclui)) .and. SUB->(DbSeek(xFilial('SUB')+M->UA_NUM))
				While SUB->(! Eof()) .AND. SUB->UB_FILIAL == xFilial('SUB') .AND. SUB->UB_NUM == M->UA_NUM 
					_nPosWhiPro := aScan(aCols,{|x| Alltrim(x[_nPosPro]) == Alltrim(SUB->UB_PRODUTO)})
					If _nPosWhiPro > 0 .And. _nPosWhiPro < 100 .And. SUB->UB_ITEM <> StrZero(_nPosWhiPro,2)
						MsgStop(STR0027+StrZero(_nPosWhiPro,2)+ STR0081 +Chr(13)+;     //'O Item '
						STR0082 + Chr(13)+ STR0083 ) //' j· existia no OrÁamento' -'e a mudanÁa de posiÁ„o pode causar problemas com estoque' - 'Confirme o Item na mesma posiÁ„o que estava anteriormente!'
						RestArea(_aAreaTKGR)
						Return(.F.)
					ElseIf _nPosWhiPro = 0
						MsgStop(STR0031 + Alltrim(SUB->UB_PRODUTO)+STR0032 +Chr(13)+;
						STR0033 + Chr(13)+ 	STR0034 ) //'O Produto ' - ' foi sobreposto por outro item,' - 'Favor manter o item e deletar a linha, e inserir o item novo' - 'na ultima linha, isso pode causar problemas com estoque.'
						RestArea(_aAreaTKGR)
						Return(.F.)
					EndIf
					SUB->(DbSkip())
				End  
			EndIf
			RestArea(_aAreaSUB)
		Next _nX
		If !Empty(M->UA_NUMSC5)
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+M->UA_NUMSC5))
				If Existblock("M410ALOK") .And. !U_M410ALOK()
					RestArea(_aAreaTKGR)
					Return(.F.)					
				EndIf
			EndIf
			
			SC6->(DbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+M->UA_NUMSC5))
				While SC6->(!Eof()) .AND. SC6->C6_FILIAL == xFilial('SC6') .AND. M->UA_NUMSC5 == SC6->C6_NUM
					SC9->(DbSetOrder(1))
					If SC9->(DbSeek(xFilial("SC9")+M->UA_NUMSC5+SC6->C6_ITEM))
						_nPosWhiPro := aScan(aCols,{|x| Alltrim(x[_nPosPro]) == Alltrim(SC9->C9_PRODUTO)})
						// Verifica se os produtos gravados anteriormente estao todos no acols ou se foram deletados
						If _nPosWhiPro == 0
							MsgStop(STR0031 +Alltrim(SC9->C9_PRODUTO)+STR0032 +Chr(13)+;
							STR0033 + Chr(13) + STR0034 ) //'O Produto ' - ' foi sobreposto por outro item,' - 'Favor manter o item e deletar a linha, e inserir o item novo' - 'na ultima linha, isso pode causar problemas com estoque.'
							RestArea(_aAreaTKGR)
							Return(.F.)
						EndIf
						
						Begin Transaction
						A460Estorna() 
						End Transaction
					EndIf
					SC6->(DbSkip())
				End
			EndIf
			SC6->(DbSetOrder(1))
			_aProdAnt := {}
			If SC6->(DbSeek(xFilial("SC6")+M->UA_NUMSC5))
				While SC6->(!Eof()) .AND. SC6->C6_FILIAL == xFilial('SC6') .AND. M->UA_NUMSC5 == SC6->C6_NUM
					SC9->(DbSetOrder(1))
					SC9->(DbSeek(xFilial("SC9")+M->UA_NUMSC5+SC6->C6_ITEM))
					If (aScan(aCols,{|x| Alltrim(x[_nPosPro]) == Alltrim(SC6->C6_PRODUTO)}) == 0 .or.;
						aCols[aScan(aCols,{|x| Alltrim(x[_nPosPro]) == Alltrim(SC6->C6_PRODUTO)}),Len(aHeader)+1] == .T. .Or.;
						SC6->C6_LOCAL <> BUSCACOLS("UB_LOCAL") .Or.;
						!Empty(SC9->C9_BLEST))
						RecLock("SC6",.F.)
						SC6->C6_QTDANT := 0
						SC6->(MsUnLock())
					EndIf
					AaDd(_aProdAnt,SC6->C6_PRODUTO)
					SC6->(dbSkip())
				End
				For _nX := 1 To Len(aCols)
					If aScan(_aProdAnt,aCols[_nX,_nPosPro]) == 0
						aCols[_nX,_nPosQtA] := 0
					Endif
				Next
			EndIf
		EndIf
	EndIf
	
	RestArea(_aAreaTKGR)
EndIf

Return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TMKVFIM   ∫Autor  ≥Vendas Clientes     ∫ Data ≥  11/29/00   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ P.E. acionado apos a gravaÁ„o do C5 e C6 para gravar C9 e  ∫±±
±±∫          ≥ Empenhos                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function TMKVFIM()
Local   nUsado  := 0
Local   _nQuant := 0      
Local   _nX     := 0
Local   i       := 0

Private _aArea
Private _nItem,_lOk,_cNumSc5,_cNumSUA,_nCustoGer,_nCustoTot,_nValTot,_nDivisao,_nPesoL,_nValCon
Private _nPesoB,_aGrupos,_nPosItem, _nPosProd,_nQtdVen,_nDispo,_nQtdLib,_nMix,_nPosDel
Private _cRegras, _cCondBloq, _nValConOk

// Variaveis Para Liberacao Automatica de Pedidos
Private	lTransf	:= .f. 	// .f. = N„o Utiliza Armazem Alternativo Para Liberacao (Soh Usa Armazem Padrao)
Private	lLiber	:= .t.	// .t. = Soh Libera Pedido Qdo Houver Saldo Em Estoque
Private	lSugere	:= .t.	// .t. = Sugere Quantidade a Liberar No Pedido
Private	lContEmb:= .F.	// Controla inclusao e alteracao para o controle de embarques
Private	lContEmbC:= .F.	// Controla cancelamento do controle de embarques
Private aContEmbC:={}
Private cNumSC5 := M->UA_NUMSC5
Private cNumSUA := M->UA_NUM
Private	_nParcelas := 0
Private	_nTotParc  := 0
Private	_nMedia    := 0
Private	_nUltDia   := 0
Private	_aParcela  := {}
Private _cEmailBlq := ""
Private _lLibDtE   := .T.      
Private _lPedNovo  := .F.


If FindFunction("U_DTMKVFIM")
	U_DTMKVFIM()
Else	
	_aArea := T_SRArea('S',Nil)
	
	_nItem    := 1
	_lOk      := .T.
	_cNumSC5  := cNumSC5
	//------------------------------------------
	//--Posiciona para validar regras de negocio
	//------------------------------------------
	DbSelectArea("SUA")
	DbSetOrder(1)
	SUA->(DbSeek(xFilial("SUA")+cNumSUA))
	
	If _cNumSC5 <> SUA->UA_NUMSC5
		_cNumSC5  := SUA->UA_NUMSC5
	EndIf
	_cNumSUA  := cNumSUA
	If _cNumSUA <> SUA->UA_NUM
		_cNumSUA  := SUA->UA_NUM
	EndIf
	_nCustoGer:= 0
	_nCustoTot:= 0
	_nValTot  := 0
	_nValCon  := 0
	_nDivisao := 0
	_nPesoL   := 0
	_nPesoB   := 0
	_aGrupos  := {}
	_nQtdVen  := 0
	_nDispo   := 0
	_nQtdLib  := 0
	_nMix     := 0
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	
	DbSelectArea("SA3")
	DbSetOrder(1)
	
	DbSelectArea("SUA")
	DbSetOrder(1)
	
	DbSelectArea("SUB")
	DbSetorder(1)
	
	DbSelectArea("SB0")
	DbSetOrder(1)
	
	DbSelectarea("SB1")
	DbSetOrder(1)
	
	DbSelectArea('SB2')
	DbSetOrder(1)
	
	DbSelectarea("SF4")
	DbSetOrder(1)
	
	DbSelectarea("SE4")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	DbSelEctArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("SYP")
	DbSetOrder(1)
	
	DbSelectArea("LH7")
	DbSetOrder(1)
	
	DbSelectArea("LH9")
	DbSetOrder(1)
	
	DbSelectArea('SU0')
	DbSetOrder(1)
	If !DbSeek(xFilial('SU0')+SU7->U7_POSTO)
		T_SRArea('R',_aArea)
		MsgStop(STR0035) //'Grupo de Atendimento nao Encontrado!'
		Return(.F.)
	EndIf
	
	_nPosDel := Len(aHeader)+ 1
	
	If Alltrim(M->UA_OPER) == "1"
		
		_nPosItem := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='UB_ITEM'})
		_nPosProd := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='UB_PRODUTO'})
		_nPosTES  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='UB_TES'})
		_cRegras  := ''
		_lLibDtE  := .T.
		            
		SE4->(DbSeek(xFilial("SE4")+M->UA_CONDAF))
		_cTipo := SE4->E4_TIPO
		_cCond := SE4->E4_COND
			
		_aParcela   := T_Prazo( AllTrim(_cCond), "," )
		_nParcelas := Len(_aParcela)
		_nTotParc  := 0
		
		For _nX := 1 To Len( _aParcela )
			_nTotParc += If(_nX>Len(_aParcela),0,Val(_aParcela[_nX]))
		Next
		
		_nMedia  := _nTotParc / _nParcelas
		_nUltDia :=	Val(_aParcela[Len(_aParcela)])
		
		SUB->(DbSeek(xFilial('SUB')+_cNumSUA))
		
		While SUB->(!Eof()) .AND. SUB->UB_FILIAL == xFilial('SUB') .And. SUB->UB_NUM == _cNumSUA
			
			SB1->(DbSeek(xfilial("SB1")+SUB->UB_PRODUTO))
			
			LH7->(DbSeek(xfilial("LH7")+SUB->UB_PRODUTO))
			
			_nValTot   += (SUB->UB_VLRITEM * If(SUA->UA_POLITIC = "2",2,1))
			_nCustoUni := LH7->LH7_PRCL
			_nCustoTot := SUB->UB_QUANT * _nCustoUni
			_nCustoGer += _nCustoTot
			
			If AsCan(_aGrupos,SB1->B1_GRUPO) = 0
				AaDd(_aGrupos,SB1->B1_GRUPO)
			EndIf
			
			_nValConOk := T_BuscaValCon(M->UA_CLIENTE, M->UA_LOJA, SUB->UB_PRODUTO)
			If _nValConOk
				If !((!Empty(LH4->LH4_NUMORC) .And. LH4->LH4_NUMORC = _cNumSUA) .Or. Empty(LH4->LH4_NUMORC))
					_nValConOk := .F.
				EndIf
			EndIf
			
			If _nValConOk
				_nValCon += SUB->UB_VRUNIT
			EndIf
			
			LH9->(DbSeek(xFilial('LH9')+'I'))
			While LH9->(! Eof()) .AND. LH9->LH9_FILIAL == xFilial('LH9') .AND. SubStr(LH9->LH9_CODIGO,1,1)=='I'
				If &(LH9->LH9_REGRA) .And. !(LH9->LH9_CODIGO+';' $ _cRegras)
					_cRegras += LH9->LH9_CODIGO+';'
					If LH9->(FieldPos("LH9_EMAIL")) > 0 
						_cEmailBlq += If(!(Alltrim(LH9->LH9_EMAIL)$_cEmailBlq),Alltrim(LH9->LH9_EMAIL)+";","")
					EndIf
				EndIf
				LH9->(DbSkip())
			End  
			
			DbSelectArea("SUB")
			DbSkip()
		End  
		
		LH9->(DbSeek(xFilial('LH9')+'C'))
		While LH9->(!Eof()) .AND. LH9->LH9_FILIAL == xFilial('LH9') .AND. SubStr(LH9->LH9_CODIGO,1,1)=='C'
			If &(LH9->LH9_REGRA) .And. !(LH9->LH9_CODIGO+';' $ _cRegras)
				_cRegras += LH9->LH9_CODIGO+';'     
				If LH9->(FieldPos("LH9_EMAIL")) > 0 
					_cEmailBlq += IIf(!(Alltrim(LH9->LH9_EMAIL)$_cEmailBlq),Alltrim(LH9->LH9_EMAIL)+";","")
				Endif
			Endif
			LH9->(DbSkip())
		End                         
		
		DbSelEctArea("SC5")
		DbSetOrder(1)
		If SC5->(DbSeek(xfilial("SC5")+_cNumSc5))
			RecLock("SC5",.F.)
			SC5->C5_TIPLIB     := IIF(SUA->UA_FATINT="S","2","1")
			SC5->C5_LIBEROK    := ""
			SC5->C5_TRANSP	   := SUA->UA_TRANSP
			SC5->C5_CODREQ     := SUA->UA_CODREQ
			SC5->C5_REQCLI     := SUA->UA_REQCLI
			SC5->C5_NOMEREQ    := SUA->UA_NOMEREQ
			SC5->C5_ENDENT     := SUA->UA_ENDENT
			SC5->C5_BAIRROE    := SUA->UA_BAIRROE
			SC5->C5_MUNE       := SUA->UA_MUNE
			SC5->C5_ESTE       := SUA->UA_ESTE
			SC5->C5_CEPE       := SUA->UA_CEPE
			SC5->C5_MENNOTA    := SUA->UA_OBSDCM
			SC5->C5_FATINT     := SUA->UA_FATINT
			SC5->C5_AGLUTIN    := SUA->UA_AGLUTIN
			SC5->C5_CONDPAG    := If(!Empty(SUA->UA_CONDPG),SUA->UA_CONDPG,SA1->A1_COND)
			SC5->C5_TPFRETE    := SUA->UA_TPFRETE
			SC5->C5_PESOL      := _nPesoL
			SC5->C5_PBRUTO     := _nPesoB
			SC5->C5_TPCARGA    := "2"                                          
			SC5->C5_ESPECI1    := "CAIXA"
			SC5->C5_TXMOEDA    := 1
			SC5->C5_CLIENT     := SC5->C5_CLIENTE
			SC5->C5_LOJAENT    := SC5->C5_LOJACLI		
			MsUnlock()
			
		Endif
		
		                                          
		_dDtEnt := CTOD('')
		SUB->(DbSeek(xFilial("SUB")+_cNumSUA))
		While SUB->(!Eof()) .AND. SUB->UB_FILIAL == xFilial("SUB") .AND. SUB->UB_NUM == _cNumSUA
			
			SB0->(DbSeek(xFilial("SB0")+SUB->UB_PRODUTO))
			
			SB1->(DbSeek(xfilial("SB1")+SUB->UB_PRODUTO))
			_cGrupo := SB1->B1_GRUPO
			
			SF4->(DbSeek(xfilial("SF4")+SUB->UB_TES))
			
			SC6->(DbSeek(xfilial("SC6")+SUA->UA_NUMSC5+SUB->UB_ITEM+SUB->UB_PRODUTO))
			
			_nDispo  := 0
			
			RecLock("SUB",.F.)
			SUB->UB_QTDANT := SUB->UB_QUANT
			MsUnLock()
			
			DbSelectArea('SC6')
			RecLock("SC6",.F.)
			SC6->C6_OP 		:= "02"
			SC6->C6_TPOP	:= "F"
			SC6->C6_DESCRI  := SB1->B1_DESC
			If SF4->F4_DUPLIC = 'S' 
				SC6->C6_COMISSA	:= SUB->UB_COMISSA
				SC6->C6_PERCOM	:= SUB->UB_PERCOM
			Else
				SC6->C6_COMISSA	:= 0
				SC6->C6_PERCOM	:= 0
			EndIf
			SC6->C6_ITEMCLI := SUB->UB_ITEMCLI
			SC6->C6_SEGUM 	:= SUB->UB_SEGUM
			SC6->C6_UNSVEN	:= SUB->UB_UNSVEN
			SC6->C6_QTDANT	:= SUB->UB_QTDANT      
			SC6->C6_QTDEMP  := 0
			SC6->C6_ENTREG  := SUB->UB_DTENTRE  
			SC6->C6_CF      := If(Empty(SC6->C6_CF),SUB->UB_CF,SC6->C6_CF)
			If _dDtEnt < SUB->UB_DTENTRE
				_dDtEnt := SUB->UB_DTENTRE
			EndIf
			
			If SU0->U0_PEDAUT == 'S'
				SC6->C6_IMPRE := 'R01'
			Endif
			
			DbSelectArea('SC6')
			SC6->(MsUnlock())
			
			_nPesoL    += (SB1->B1_PESO * SUB->UB_QUANT)
			_nPesoB    += (SB1->B1_PESBRU * SUB->UB_QUANT)
			
			DbSelectArea("SUB")
			DbSkip()
		End  
		
		If _lLibDtE
			__aArea  := GetArea()
			__aArA1  := SA1->(GetArea())
			__aArUA  := SUA->(GetArea())
			__aArUB  := SUB->(GetArea())
			__aArC5  := SC5->(GetArea())
			__aArC6  := SC6->(GetArea())
			
			// Cria variaveis De Parametro Caso N„o Exista
			For i := 1 To 20
				_cPar := "MV_PAR" + StrZero(i,2)
				_cParX:= "MV_PARX" + StrZero(i,2)
				&(_cParX) := &(_cPar)
			Next
			
			cAlias := "SC5"
			nReg   := SC5->(Recno())
			nOpc 	 := 1   	// 1= Libera
			lEnd	 := .f.	//
			
			// Ajusta Parametros
			Pergunte(Padr("MTALIB",Len(SX1->X1_GRUPO) ) ,.F.)
			
			MV_PAR01 := 1
			MV_PAR02 := MV_PAR03 := SC5->C5_NUM
			MV_PAR04 := Space(6)
			MV_PAR05 := "ZZZZZZ"
			MV_PAR06 := StoD("20000101")
			MV_PAR07 := StoD(StrZero((Year(dDataBase)+1),4) + "1231")
			MV_PAR08 := 1
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ mv_par01 Ordem Processmento ?  Ped.+Item /Dt.Entrega+Ped.+Item         ≥
			//≥ mv_par02 Pedido de          ?                                          ≥
			//≥ mv_par03 Pedido ate         ?                                          ≥
			//≥ mv_par04 Cliente de         ?                                          ≥
			//≥ mv_par05 Cliente ate        ?                                          ≥
			//≥ mv_par06 Dta Entrega de     ?                                          ≥
			//≥ mv_par07 Dta Entrega ate    ?                                          ≥
			//≥ mv_par08 Liberar            ? Credito/Estoque Credito                  ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			SUA->(DbSetOrder(1))
			SUA->(DbSeek(xFilial("SUA")+cNumSUA))
			
			a440Proces(cAlias,nReg,nOpc,lEnd)
			
			For i := 1 To 20
				_cPar := "MV_PAR" + StrZero(i,2)
				_cParX:= "MV_PARX" + StrZero(i,2)
				&(_cPar) := &(_cParX)
			Next
			
			RestArea(__aArA1)
			RestArea(__aArUA)
			RestArea(__aArUB)
			RestArea(__aArC5)
			RestArea(__aArC6)
			RestArea(__aArea)
		EndIf
		
		_lPedLib := .F.
		If !SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM)) .And. !_lLibDtE
			If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
				DbSelectArea("SC6")
				While SC6->(! Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == SC5->C5_NUM
					If SC6->C6_BLQ <> 'R' .And. SC6->C6_QTDENT = 0
						_nPenden := SC6->C6_QTDVEN
						MaLibDoFat(SC6->(Recno()),_nPenden ,.T.,.F.,.T.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
					EndIf          
					DbSelectArea("SC6")
					DbSkip()
				End                    
				SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM))			
			Endif
		Endif
		_lPedBlCre := .F.
		_nValLib   := 0
		While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SUA->UA_NUMSC5
			RecLock("SC9",.f.)
			SC9->C9_VEND    := SC5->C5_VEND1
			If SU0->U0_PEDAUT == 'S' .And. Empty(SC9->C9_BLEST)
				SC9->C9_BLCONF := 'OK'
			Endif
			SC9->C9_BLINF   := _cRegras
			//--------------------------------------------------------------------------------
			//-- Quando o pedido de venda passar por todos as validacoes lbera automaticamente
			//--------------------------------------------------------------------------------
			If Empty(_cRegras)
				SC9->C9_BLPRE   := 'LIB AUTOMAT EM ' +DTOC(dDataBase) + ' ' + SUBSTR(TIME(),1,5)
			Else
				SC9->C9_BLPRE   := ''
			EndIf
			//-----------------------------------------------------------
			//-- Nao utiliza carga
			//-----------------------------------------------------------
			SC9->C9_TPCARGA := '2'
			
			SB1->(Dbseek(xfilial("SB1")+SC9->C9_PRODUTO))
			//U_GRVDDAD("SC9", {"C9_COLEC","C9_LINHA","C9_CODANT","C9_GRUPO"}, {SB1->B1_COLEC,SB1->B1_LINHA,SB1->B1_CODANT,SB1->B1_GRUPO}, .F.)
			
			SC9->(MsUnlock())
			
			If SC6->(DbSeek(xfilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
				Reclock("SC6",.F.)
				SC6->C6_BLINF   := SC9->C9_BLINF
				SC6->C6_BLPRE   := SC9->C9_BLPRE
				MsUnLock()
				If SC6->C6_QTDVEN > SC9->C9_QTDLIB .And. Empty(SC9->C9_BLEST)
					_nRecSC9 := SC9->(Recno())
					_nPenden := SC6->C6_QTDVEN - SC9->C9_QTDLIB
					MaLibDoFat(SC6->(Recno()),_nPenden ,.T.,.F.,.T.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
					DbSelectArea("SC9")
					DbGoTo(_nRecSC9)
				EndIf
			EndIf      
			                                                              
			If !_lPedLib .And. Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .And. !Empty(SC9->C9_BLPRE)
				_lPedLib := .T.
			EndIf        
			If !Empty(SC9->C9_BLCRED)
				_lPedBlCre := .T.
			EndIf      
			If Empty(SC9->C9_BLEST)
				_nValLib   += SC9->(C9_QTDLIB*C9_PRCVEN)
			EndIf
	
			DbSelectArea("SC9")
			SC9->(DbSkip())
			                   
		End  
		
		RecLock("SUA",.F.)
		SUA->UA_CODREQ := M->UA_CODREQ
		SUA->UA_NOMEREQ:= M->UA_NOMEREQ
		SUA->UA_REQCLI := M->UA_REQCLI
		SUA->UA_STATUS := If(_lLibDtE,'LIB','') // Para possibilitar alteracao no pedido do call center
		MsUnlock()                                                                                         
		
		If Type("_cAtuPros") <> "U"
			U_AtuRelPro(_cAtuPros)
		Endif                       
		
		If !Empty(_cRegras) .And. !Empty(_cEmailBlq)
			_cBody := STR0084 +SC5->C5_CLIENTE+ " / " +SC5->C5_LOJACLI+" - "+Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")+Chr(13)+Chr(10)   //"Cliente: " 
			_cBody += STR0085 +Chr(13)+Chr(10)   //"Pedido com Bloqueio de LiberaÁ„o de Regras de Negocio." 
			T_EnvMail2(STR0086  +SC5->C5_NUM, _cBody, _cEmailBlq, "", "", Nil, Nil)  //"Liberar Pedido com Bloqueio: " 
		EndIf                   
	                                                                          
		// Informar os emails dos usuarios responsaveis pela liberacao de credito no parametro MV_USUFINL
		If _lPedBlCre .And. !Empty(GetNewPar("MV_USUFINL","",xFilial("SUA"))) .And. _nValLib > 0
			_cBody := STR0084 + SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" - "+Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")+Chr(13)+Chr(10) // "Cliente: "
			_cBody += STR0087 +SC5->C5_NUM+Chr(13)+Chr(10) //"Pedido com Bloqueio de CrÈdito.: "
			_cBody += STR0088 +Str(_nValLib*1.10,14,2)+Chr(13)+Chr(10) //"Valor Total dos Itens Liberados (c/IPI): "
			_cBody += STR0089 +SUA->UA_POLITIC+Chr(13)+Chr(10)	//"Politica..: "	
			_cBody += STR0090 +SUA->UA_OPERADO+" - "+Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_NOME")+Chr(13)+Chr(10) //"Operador..: "		
			If SU7->(FieldPos("U7_OPESUP")) > 0
				_cBody += STR0091 + SU7->U7_OPESUP+" - "+Posicione("SU7",1,xFilial("SU7")+SU7->U7_OPESUP,"U7_NOME")+Chr(13)+Chr(10)  //"Supervisor: "		
			EndIf
			_cBody +=  STR0092 + SUA->UA_VEND+" - "+Posicione("SA3",1,xFilial("SA3")+SUA->UA_VEND,"A3_NOME")+Chr(13)+Chr(10)	//"Vendedor..: " 	
			T_EnvMail2(STR0093 + SC5->C5_NUM, _cBody, SuperGetMV("MV_USUFINL"), "", "", Nil, Nil)   //"Liberar CrÈdito do Pedido: "
		EndIf
	Else	
	    If SA1->(Fieldpos("A1_ULTCOT") ) > 0
			RecLock("SA1",.F.)
			SA1->A1_ULTCOT := dDatabase
			MsUnlock()		
		EndIf	
	EndIf	
	T_SRArea('R',_aArea)	
EndIf

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥VerSegUm  ∫Autor  ≥Vendas Clientes     ∫ Data ≥  08/02/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function VerSegUm(_cCodSeg,_cCodPro,_nQtdLib,_nQtdSeg)
CHKTEMPLATE("DCM") 
 
_nQtdRet := _nQtdLib

If !Empty(_cCodSeg)
	_nQtdEmb := If(_cCodSeg=SB1->B1_UM,1,;
	If(_cCodSeg=SB1->B1_SEGUM,SB1->B1_CONV,;
	If(_cCodSeg=SB1->B1_UM3,SB1->B1_UM3FAT,;
	If(_cCodSeg=SB1->B1_UM4,SB1->B1_UM4FAT,1))))
	_nQtdEmb2 := Int(_nQtdLib/_nQtdEmb)
	_nQtdRet := If((_nQtdEmb*_nQtdSeg)<=_nQtdLib,_nQtdEmb*_nQtdSeg,_nQtdEmb2*_nQtdEmb)
EndIf

Return(_nQtdRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TMKCLI    ∫Autor  ≥Vendas Clientes     ∫ Data ≥  08/02/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Ponto de entrada executado apÛs a validaÁ„o do cliente      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function TMKCLI()
Local _aArea
Local _oDlg1
CHKTEMPLATE("DCM")

_aArea := T_SRArea('S',nil)

DbSelectArea("SE1")
DbSetorder(8)
If DbSeek(xFilial("SE1")+M->UA_CLIENTE+M->UA_LOJA+"A")
	While SE1->(! Eof()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. SE1->E1_CLIENTE == M->UA_CLIENTE .AND. SE1->E1_LOJA == M->UA_LOJA .AND. SE1->E1_STATUS == "A"
		If !(RTRIM(SE1->E1_TIPO)=="RA" .OR. Rtrim(SE1->E1_TIPO)=="PR" .OR. Rtrim(SE1->E1_TIPO)=="NCC")
			If dDataBase > SE1->E1_VENCREA .AND. SE1->E1_SALDO > 0
				If MsgYesNo(STR0036+Chr(13)+; //"O cliente possui titulo(s) em aberto vencido(s)"
					STR0037) //"Deseja consultar as informacoes ?"
					TK271SITUAC()
				EndIf
				Exit
			EndIf
		EndIf
		DbSkip()
	End
End

LH2->(DbSetorder(2))
If LH2->(DbSeek(xfilial("LH2")+M->UA_CLIENTE,.F.)) .AND. Empty(M->UA_CODREQ)
	
	@ 010,000 To 130, 350 Dialog _oDlg1 Title STR0038 //"Dados do requisitante"
	@ 010,005 Say STR0039 //'Codigo: '
	@ 010,070 Get M->UA_CODREQ Valid (Empty(M->UA_CODREQ).OR.Existcpo("LH2",M->UA_CODREQ,1)) .AND. PegaNomeReq() F3 "LH2" Size 40,08
	@ 020,005 Say STR0040 //'Nome do requisitante: '
	@ 020,070 Get M->UA_NOMEREQ Size 100,08
	@ 030,005 Say STR0041 //'Ped. Cliente: '
	@ 030,070 Get M->UA_REQCLI  Size 080,08
	@ 045,140 BmpButton Type 1 Action Close(_oDlg1)
	ACTIVATE DIALOG _oDlg1 CENTER
	
	LH2->(DbSetorder(5))
	If LH2->(DbSeek(xFilial("LH2")+M->UA_CLIENTE+M->UA_LOJA+M->UA_CODREQ))
		
		M->UA_ENDENT  := LH2->LH2_ENDENT
		M->UA_BAIRROE := LH2->LH2_BAIRRO
		M->UA_MUNE    := LH2->LH2_CIDADE
		M->UA_CEPE    := LH2->LH2_CEP
		M->UA_ESTE    := LH2->LH2_EST
		
		M->UA_ENDCOB  := LH2->LH2_ENDCOB
		M->UA_BAIRROC := LH2->LH2_BAIRROC
		M->UA_MUNC    := LH2->LH2_CIDADEC
		M->UA_CEPC    := LH2->LH2_CEPC
		M->UA_ESTC    := LH2->LH2_ESTADOC
		
	EndIf
	
EndIf

T_SRArea('R',_aArea)

Return(M->UA_CLIENTE)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PegaNomeReq ∫Autor  ≥Vendas Clientes     ∫ Data ≥  09/02/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                              ∫±±
±±∫          ≥                                                              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PegaNomeReq()

M->UA_NOMEREQ := Posicione('LH2',5,xFilial('LH2')+M->UA_CLIENTE+M->UA_LOJA+M->UA_CODREQ,'LH2_NOMERE')

Return(.T.)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MSD2460   ∫Autor  ≥Vendas Clientes     ∫ Data ≥  04/04/03   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Ponto de entrada apos a gravacao do item da nf de saida	  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function MSD2460()
Local _aAreas := GetArea()
CHKTEMPLATE("DCM")

If FindFunction("U_DMSD2460")
	U_DMSD2460()
Else
	SC6->(DbSetorder(1))
	If SC6->(DbSeek(xfilial("SC6")+SD2->(D2_PEDIDO+D2_ITEMPV+D2_COD),.F.))
		If SD2->(Reclock(alias(),.F.))
			If Empty(SC6->C6_ITEMCLI)
				REPLACE SD2->D2_DPROD WITH SC6->C6_DESCRI
			Else
				REPLACE SD2->D2_DPROD WITH SUBSTR(SC6->C6_DESCRI,1,(34-(LEN(SC6->C6_ITEMCLI)+2)))+"("+SC6->C6_ITEMCLI+")"
			Endif
			If !Empty(SC6->C6_UNSVEN)
				REPLACE SD2->D2_QTSEGUM WITH SC6->C6_UNSVEN
				REPLACE SD2->D2_SEGUM   WITH SC6->C6_SEGUM
			EndIf
			REPLACE SD2->D2_CUSDCM WITH Posicione("LH7",1,xFilial("LH7")+SD2->D2_COD,"LH7_PRC")
			SD2->(MsUnLock())
		EndIf
	EndIf
	
	If T_BuscaSalCon(SD2->D2_CLIENTE,SD2->D2_COD) > 0
		RecLock('LH5',.F.)
		LH5->LH5_QTDSAL -= SD2->D2_QUANT
		If LH5->LH5_QTDSAL < 0
			REPLACE LH5->LH5_QTDSAL WITH 0
		EndIf
		MsUnLock()
	EndIf
	
	RestArea(_aAreas)
EndIf

Return
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MSD2520   ∫Autor  ≥Vendas Clientes     ∫ Data ≥  20.08.01   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Atualiza o orcamento de vendas do modulo Telemarketing na  ∫±±
±±∫          ≥ exclusao da nota fiscal.                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function MSD2520
Local _aAreas  

CHKTEMPLATE("DCM")

If FindFunction("U_DMSD2520")
	U_DMSD2520()
Else
	Public _aSC9Est := If(Type("_aSC9Est")="U",{},IIf(AsCan(_aSC9Est,{|x|x[1]==SD2->D2_PEDIDO.And.x[2]==SD2->D2_ITEMPV})=0,{},_aSC9Est))
	Public _lReLib  := If(Type("_lReLib")<>"U".And.!_lReLib,_lReLib,;
		   If(Type("_lReLib")="U".Or.AsCan(_aSC9Est,{|x|x[1]==SD2->D2_PEDIDO.And.x[2]==SD2->D2_ITEMPV})=0,;
            MsgYesNo(STR0102),_lReLib)) //"Deseja Refazer as LiberaÁıes do Pedido? (SIM) ou Excluir e Retornar a Nota para OrÁamento? (NAO)"
			_aAreas := T_SRArea('S',Nil) 
			
	DbSelectArea("SC9")
	DbSetOrder(1)
	DbSelectArea("SC6")
	DbSetOrder(1)
	If DbSeek(xFilial("SC6")+SD2->D2_PEDIDO)
		While SC6->(! Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == SD2->D2_PEDIDO
			If SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)) .And. SC9->C9_BLEST <> "10"
				If !_lReLib
					DbSelectArea("SC9")
					While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM
						If SC9->C9_BLEST <> "10"
							RecLock('SC9',.F.)
							SC9->C9_BLINF := STR0103+Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h" //"NF EXCLUIDA "
							MsUnlock()
							A460Estorna()
						EndIf
						SC9->(DbSkip())
					End  
				EndIf
			ElseIf SC9->C9_BLEST == "10" .And. SC9->C9_NFISCAL == SD2->D2_DOC .And. SC9->C9_SERIENF == SD2->D2_SERIE
				If _lReLib
					DbSelectArea("SC9")
					While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND.;
					      SC9->C9_ITEM == SC6->C6_ITEM .AND. SC9->C9_NFISCAL == SD2->D2_DOC .AND. SC9->C9_SERIENF == SD2->D2_SERIE
						If SC9->C9_BLEST == "10"
							RecLock('SC9',.F.)
							SC9->C9_BLINF := "REFLIB"+SC6->(C6_NUM+C6_ITEM)+SC9->(C9_SEQUEN+C9_BLPRE)
							MsUnlock()
							AaDd(_aSC9Est,{SC6->C6_NUM,SC6->C6_ITEM,SC9->C9_SEQUEN,SC9->C9_BLPRE})
						EndIf
						SC9->(DbSkip())
					End  
				EndIf
			EndIf
			If !SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
				RecLock("SC6",.F.)
				SC6->C6_QTDEMP := 0
				MsUnLock()
			EndIf
			DbSelectArea("SC6")
			DbSkip()
		End  
	EndIf
	
	If !_lReLib .And. !SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM))
		
		If Empty(SC5->C5_BLQ)
			DbSelectArea("SC5")
			RecLock("SC5",.f.)
			SC5->C5_BLQ     := "1"
			Msunlock()
		EndIf
		DbSelectArea("SUA")
		DbSetOrder(8)
		If DbSeek(xFilial("SUA")+SC5->C5_NUM, .F.)
			RecLock("SUA", .f.)
			SUA->UA_STATUS  := "SUP"
			SUA->UA_DOC     := ""
			SUA->UA_SERIE   := ""
			SUA->UA_EMISNF  := Ctod("  /  /  ")
			SUA->UA_OPER    := "2"
			SUA->UA_NUMSC5  := ""
			SUA->UA_OBSDCM  := STR0042+DTOC(dDatabase)+" - "+Time()+" - "+CUSERNAME //"NOTA FISCAL EXCLUIDA EM: "
			Msunlock()
			MsgInfo(STR0104+SUA->UA_NUM+STR0105) //"Recuperado o OrÁamento "###" no Call Center, Utilize-o para liberar o pedido novamente!"
		EndIf
		DbSelectArea("SC5")
		RecLock("SC5",.f.)
		If !Empty(SUA->UA_NUM)
			SC5->C5_MENNOTA    := STR0106+SUA->UA_NUM //"ORCAMENTO ORIGINAL: "
		EndIf
		Msunlock()
		MsgInfo(STR0107+SC5->C5_NUM+STR0108) //"Favor Excluir o Pedido "###" pelo Modulo Faturamento!"
		
		If SU7->(FieldPos("U7_EMAIL")) > 0 
			_cEmailOpe := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_EMAIL")
			_cEmailSup := IIf(SU7->(FieldPos("U7_OPESUP")) > 0,Posicione("SU7",1,xFilial("SU7")+SU7->U7_OPESUP ,"U7_EMAIL"),"")
			_cBody := STR0109+SC5->C5_NUM+STR0110+SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" - "+Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")+Chr(13)+Chr(10) //" Pedido: "###" Cliente: "
			_cBody += STR0111+SUA->UA_NUM+Chr(13)+Chr(10) //" Numero do OrÁamento Original: "
			_cBody += STR0112+Chr(13)+Chr(10) //" Favor transformar orÁamento em pedido o mais rapido possivel, para manter as reservas."
			If !Empty(_cEmailSup)
				T_EnvMail2(STR0113+SC5->C5_NUM, _cBody, _cEmailSup, "", "", Nil, Nil) //"Exclus„o de Nota Fiscal do Pedido: "
			EndIf
		EndIf
		
	EndIf
	T_SRArea('R',_aAreas)
EndIf	
Return(.T.)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥A100EXC   ∫Autor  ≥Vendas Clientes     ∫ Data ≥ 20/0/09	  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Ponto de Entrada para avaliacao dos itens liberados atraves ∫±±
±±∫          ≥da nota, para o bloqueio dos mesmos caso nao tenha sido     ∫±±
±±∫          ≥faturado                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Template Function A100EXC
Local _aAreas
Local _nX	  := 0		//Controle de loop 
Local _lRet	  := .T.	//Retorno da funcao
CHKTEMPLATE("DCM")

If FindFunction("U_DA100DEL")
	_lRet := U_DA100DEL()
Else
	_aAreas := T_SRArea('S',NIL)
	_lRet := .T.
	For _nX := 1 To 2
		cQueryCad := "SELECT Count(*) AS TOTAL FROM "+RetSqlName("SC9")+"  WHERE "
		cQueryCad += "D_E_L_E_T_ <> '*' AND "
		cQueryCad += "C9_FILIAL = '"+xFilial('SC9')+"' AND "
		cQueryCad += "C9_NFENT = '"+SF1->F1_DOC+"' AND "
		cQueryCad += "C9_SERENT = '"+SF1->F1_SERIE+"' AND "
		cQueryCad += "C9_FORNEC = '"+SF1->F1_FORNECE+"' AND "
		cQueryCad += "C9_LOJAFOR = '"+SF1->F1_LOJA+"' "
		If _nX = 1
			cQueryCad += "AND C9_NFISCAL <> ''"
		EndIf
		
		TCQUERY cQueryCad NEW ALIAS "CAD"
		
		If _nX = 1 .AND. CAD->TOTAL > 0
			MsgStop(STR0043+Chr(13)+; //'Nota nao pode ser excluida !!!'
			STR0044) //'Esta nota liberou itens e os mesmos ja foram faturados...'
			_lRet := .F.
		ElseIf _nX = 2 .AND. CAD->TOTAL > 0 .AND. _lRet
			If MsgYesNo(STR0045+Chr(13)+; //'Nota com itens liberados !!!'
				STR0046+Chr(13)+; //'Os pedidos liberados com esta nota serao bloqueados novamente apos a exclusao,'
				STR0047) //'Confirma a exclus„o ?'
				DbCloseArea()
				cQueryCad := "SELECT * FROM "+RetSqlName("SC9")+"  WHERE "
				cQueryCad += "D_E_L_E_T_ <> '*' AND "
				cQueryCad += "C9_FILIAL = '"+xFilial('SC9')+"' AND "
				cQueryCad += "C9_NFENT = '"+SF1->F1_DOC+"' AND "
				cQueryCad += "C9_SERENT = '"+SF1->F1_SERIE+"' AND "
				cQueryCad += "C9_FORNEC = '"+SF1->F1_FORNECE+"' AND "
				cQueryCad += "C9_LOJAFOR = '"+SF1->F1_LOJA+"'"
				TCQUERY cQueryCad NEW ALIAS "CAD"
				While !Eof()
					DbSelectArea('SC9')
					DbSetorder(1)
					If DbSeek(xFilial('SC9')+CAD->C9_PEDIDO+CAD->C9_ITEM+CAD->C9_SEQUEN)
						RecLock('SC9',.F.)
						REPLACE SC9->C9_BLEST   WITH '02'
						REPLACE SC9->C9_BLCONF  WITH ''
						REPLACE SC9->C9_NFENT   WITH ''
						REPLACE SC9->C9_SERENT  WITH ''
						REPLACE SC9->C9_FORNEC  WITH ''
						REPLACE SC9->C9_LOJAFOR WITH ''
						MsUnLock()
					EndIf
					
					DbSelectArea('SB2')
					DbSetorder(1)
					If DbSeek(xFilial('SB2')+CAD->C9_PRODUTO+CAD->C9_LOCAL) .AND. !Empty(CAD->C9_LOCAL)
						RecLock('SB2',.F.)
						REPLACE SB2->B2_RESERVA WITH (SB2->B2_RESERVA - SC9->C9_QTDLIB)
						REPLACE SB2->B2_QPEDVEN WITH (SB2->B2_QPEDVEN + SC9->C9_QTDLIB)
						MsUnLock()
					Endif
					
										
					DbSelectArea('CAD')
					DbSkip()
				End
				_lRet := .T.
			Else
				_lRet := .F.
			EndIf
		EndIf
		DbCloseArea()
	Next _nX
	T_SRArea('R',_aAreas)
EndIf

Return(_lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MT100AGR  ∫ Autor ≥Vendas Clientes     ∫ Data ≥  22/05/01   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Ponto de Entrada apos a gravacao da nf de entrada          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/ 

Template Function MT100AGR
Local _aArea  := GetArea()
Local _lFaz   := .F.
Local _lFaz2  := .F.
Local _nPosLocal := 0
Local _nPosPedC  := 0
Local _nPosItPC  := 0
Local _aPedCom   := {}
Local _nX        := 0

Private aColsAtu   := {}
Private aHeaderAtu := {}

CHKTEMPLATE("DCM")

If FindFunction("U_DMT100AGR")
	U_DMT100AGR()
Else
	If !INCLUI .And. !ALTERA
		Return(.T.)
	EndIf
EndIf

aColsAtu := aCols
aHeaderAtu := aHeader

DbSelectArea("SC7")
DbSetOrder(1)

_nPosLocal := aScan(aHeaderAtu,{|e|Trim(e[2])=="D1_LOCAL"})
_nPosPedC  := aScan(aHeaderAtu,{|e|Trim(e[2])=="D1_PEDIDO"})
_nPosItPC  := aScan(aHeaderAtu,{|e|Trim(e[2])=="D1_ITEMPC"})
_nPosQuant := aScan(aHeaderAtu,{|e|Trim(e[2])=="D1_QUANT"})
_nPosCod   := aScan(aHeaderAtu,{|e|Trim(e[2])=="D1_COD"})

For _nX := 1 To Len(aColsAtu)
	If aColsAtu[_nX,_nPosLocal] <> AlmoxCQ()
		_lFaz := .T.
	EndIf
Next

If _lFaz
	Processa({||T_LibPedEmb(aHeaderAtu,aColsAtu,'A',{'D1_COD','D1_QUANT','D1_LOCAL'},{'D1_PEDIDO','D1_ITEMPC'},{SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA})},STR0114) //"Processando liberaÁ„o de pedidos..."
EndIf

aCols   := aColsAtu
aHeader := aHeaderAtu

RestArea(_aArea)


Return(.T.) 

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥LibPedEmb ∫ Autor ≥Vendas Clientes     ∫ Data ≥  20/07/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao para liberar os pedidos com controle de embarques   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Template Function LibPedEmb(_aHeader,_aCols,_cLinha,_aCampos,_aCamPed,_aCamposChav)
Local _nItens   := 0
Local _nQuant   := 0
Local cQueryCad := ""
Local _nQtdLib  := 0
Local aPedLib   := {}
Local cPedLib   := ""
Local cNotaEnt  := cSerEnt := cFornec := cLojaFor := ''
Local nUsado    := 0
Local _cProduto := ""
Local _nXLib    := 0
Local _nPoslocal:= 0
Local _nPosProd := 0
Local _nPosQtd  := 0
Local _nPosEstor:= 0
Local _nPosTipo := 0
Local _nAchaOrd := 0
Local _aOrdLib  := {}
Local _aOrdLibDef:= {}
Local _nX

ProcRegua(Len(_aCols))

PRIVATE aHeadGrade:= {}
PRIVATE aColsGrade:= {}

If Len(_aCampos) >= 3
	_nPosProd := aScan(_aHeader,{|e|Trim(e[2])==_aCampos[1]})
	_nPosQtd  := aScan(_aHeader,{|e|Trim(e[2])==_aCampos[2]})
	_nPoslocal:= aScan(_aHeader,{|e|Trim(e[2])==_aCampos[3]})
	If Len(_aCampos) > 3
		_nPosEstor:= aScan(_aHeader,{|e|Trim(e[2])==_aCampos[4]})
		_nPosTipo := aScan(_aHeader,{|e|Trim(e[2])==_aCampos[5]})
	EndIf
	If _aCamPed <> Nil
		If _cLinha = 'A' .And. Len(_aCamPed) = 2
			_nPosPed  := aScan(_aHeader,{|e|Trim(e[2])==_aCamPed[1]})
			_nPosItem := aScan(_aHeader,{|e|Trim(e[2])==_aCamPed[2]})
		ElseIf Len(_aCamPed) <> 2
			Return
		ElseIf _cLinha = 'L' .And. (Empty(_aCamPed[1]) .Or. Empty(_aCamPed[2]))
			Return
		Endif
	EndIf
Else
	Return
EndIf

If Len(_aCamposChav) < 4
	Return
EndIf

aCols   := {}
aHeader := {}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SC6")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SC6" )
	If ( X3Uso(SX3->X3_USADO) .And.;
		!AllTrim(SX3->X3_CAMPO)=="C6_NUM"    .And.;
		!AllTrim(SX3->X3_CAMPO)=="C6_QTDEMP" .And.;
		!AllTrim(SX3->X3_CAMPO)=="C6_QTDENT" .And.;
		cNivel >= SX3->X3_NIVEL ) .Or.;
		AllTrim(SX3->X3_CAMPO)=="C6_SLDALIB"
		nUsado++
		AADD(aHeader,{ AllTrim(X3Titulo()),;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID,;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,;
		SX3->X3_CONTEXT } )
	EndIf
	DbSelectArea("SX3")
	DbSkip()
End                                       
                                                                 
// Informar no parametro MV_SEGCLIE os codigos de atividades que ser„o priorizados na liberacao
_aOrdLib := {}   

AAdd(_aOrdLib,{1," AND A1_EST <> '"+GetMV("MV_ESTADO")+IIf(!Empty(GetNewPar("MV_SEGCLIE","",xFilial("SA1"))),"' AND A1_SATIV1 IN ("+GetMV("MV_SEGCLIE")+") ","'") })
AAdd(_aOrdLib,{2," AND A1_EST =  '"+GetMV("MV_ESTADO")+IIf(!Empty(GetNewPar("MV_SEGCLIE","",xFilial("SA1"))),"' AND A1_SATIV1 IN ("+GetMV("MV_SEGCLIE")+") ","'") })
If !Empty(GetNewPar("MV_SEGCLIE","",xFilial("SA1")))
	AAdd(_aOrdLib,{3," AND A1_EST <> '"+ SuperGetMV("MV_ESTADO")+"' AND A1_SATIV1 NOT IN ("+GetMV("MV_SEGCLIE")+") "})
	AAdd(_aOrdLib,{4," AND A1_EST = '"+ SuperGetMV("MV_ESTADO")+"' AND A1_SATIV1 NOT IN ("+GetMV("MV_SEGCLIE")+") "})
Else
	AAdd(_aOrdLib,{3,""})
	AAdd(_aOrdLib,{4,""})
EndIf

// Informar no parametro MV_DCMORDL a ordem de liberacao desejada conforme sequencia de criacao 1234
_aOrdLibDef := T_Split(GetNewPar("MV_DCMORDL","1,2,3,4",xFilial("SA1")),",")
If Len(_aOrdLibDef) == 4
	For _nX := 1 To Len(_aOrdLib)
	    _aOrdLib[_nX,1] := Val(_aOrdLibDef[_nX])
	Next
EndIf

DbSelectArea('SB1')
DbSetOrder(1)

DbSelectArea('SC5')
DbSetOrder(1)

DbSelectArea('SC6')
DbSetOrder(1)

DbSelectArea("SC9")
DbSetorder(1)

For _nItens := 1 To Len(_aCols)
	
	IncProc()
	
	If _aCols[_nItens,Len(_aHeader)+1]
		Loop
	EndIf
	If _nPosEstor > 0 .And. (_aCols[_nItens,_nPosEstor] = "S" .Or. _aCols[_nItens,_nPosTipo] <> 1)
		Loop
	EndIf
	_nQuant := _aCols[_nItens,_nPosQtd]
	
	aCols := {}
	
	_cProduto := If(_nPosProd = 0 .And. SubStr(_aHeader[1,2],1,2) = 'D7', SD7->D7_PRODUTO, _aCols[_nItens,_nPosProd])
	
	If SB1->(DbSeek(xFilial("SB1")+_cProduto))
		If Alltrim(Funname())="MATA103" .And. SB1->B1_NOTAMIN > 0
			Loop
		ElseIf Alltrim(Funname())="MATA175" .And. SB1->B1_NOTAMIN = 0
			Loop
		EndIf
	EndIf
	
	If _nQuant > 0
		For _nXLib := 1 To 4
			If _nQuant > 0 .And. !Empty(_aOrdLib[_nXLib,2])
				cQueryCad := "SELECT DISTINCT C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO "
				cQueryCad += " FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SC9")+" SC9, "+RetSqlName("SA1")+" SA1 WHERE"
				cQueryCad += " SC5.D_E_L_E_T_ = ' ' AND"
				cQueryCad += " SC6.D_E_L_E_T_ = ' ' AND"
				cQueryCad += " SC9.D_E_L_E_T_ = ' ' AND"
				cQueryCad += " SA1.D_E_L_E_T_ = ' ' AND"
				cQueryCad += " C5_FILIAL  = '"+xFilial('SC5')+"' AND"
				cQueryCad += " C6_FILIAL  = C5_FILIAL AND"
				cQueryCad += " C9_FILIAL  = C6_FILIAL AND"
				cQueryCad += " C6_NUM     = C5_NUM AND "
				cQueryCad += " C9_PEDIDO  = C6_NUM AND "
				cQueryCad += " C6_PRODUTO = '"+_cProduto+"' AND"
				cQueryCad += " C9_PRODUTO = C6_PRODUTO AND"
				cQueryCad += " C9_ITEM    = C6_ITEM AND"
				cQueryCad += " C6_LOCAL   = '"+_aCols[_nItens,_nPoslocal]+"' AND "
				cQueryCad += " C9_LOCAL   = C6_LOCAL AND "
				cQueryCad += " C6_BLQ     <> 'R' AND "
				cQueryCad += " C6_QTDENT  < C6_QTDVEN AND "
				cQueryCad += " C9_BLEST   <> ' ' AND "
				cQueryCad += " C9_BLCRED  =  ' ' AND "
				cQueryCad += " A1_COD  = C5_CLIENTE AND "
				cQueryCad += " A1_LOJA = C5_LOJACLI  "      
				_nAchaOrd := AsCan(_aOrdLib,{|x|x[1]==_nXLib})
				If _nAchaOrd > 0
					cQueryCad += _aOrdLib[_nAchaOrd,2]
				EndIf
				cQueryCad += " ORDER BY C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO  "
				TCQUERY cQueryCad NEW ALIAS "PROLIB"
				
				DbSelectArea("PROLIB")
				While !Eof()
					
					If SC5->(DbSeek(xFilial("SC5")+PROLIB->C6_NUM))
						
						If _nQuant > 0
							
							While PROLIB->(! Eof()) .AND. PROLIB->C6_FILIAL == xFilial("SC5") .AND. PROLIB->C6_NUM == SC5->C5_NUM .AND. _nQuant > 0
								
								If  SC6->(DbSeek(xFilial("SC6")+PROLIB->(C6_NUM+C6_ITEM+C6_PRODUTO))) 
									
									If SC9->(DBSeek(xFilial('SC9')+PROLIB->(C6_NUM+C6_ITEM)))
										DbSelectArea("SC9")
										While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == PROLIB->C6_NUM .AND. SC9->C9_ITEM == PROLIB->C6_ITEM
											If SC9->C9_BLEST <> '10' .And. SC9->C9_BLEST <> '' 
												RecLock('SC9',.F.)
												SC9->C9_BLINF := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
												MsUnlock()
												A460Estorna()
											Endif
											SC9->(DbSkip())
										End  
									EndIf
									
									SC5->(DbSeek(xFilial("SC5")+PROLIB->C6_NUM))
									SC6->(DbSeek(xFilial("SC6")+PROLIB->(C6_NUM+C6_ITEM+C6_PRODUTO)))
									DbSelectArea("SC6")
									
									_nQtdLib := 0
									_nQtdLib := SC6->C6_QTDVEN - SC6->C6_QTDENT
									_nQtdLib := If(_nQtdLib>_nQuant,If(SC5->C5_FATINT="S",0,_nQuant),_nQtdLib)
									_nQuant -= _nQtdLib
									
									MaLibDoFat(SC6->(Recno()),_nQtdLib,.T.,.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
									
								EndIf
								
								DbSelectArea("PROLIB")
								DbSkip()
								
							End  
							
						Else
							
							DbSelectArea("PROLIB")
							DbSkip()
							
						Endif
						
					Else
						
						DbSelectArea("PROLIB")
						DbSkip()
						
					EndIf
				End  
				DbCloseArea()
			EndIf
		Next
	EndIf
Next

For _nItens := 1 To Len(_aCols)
	If _aCols[_nItens,Len(_aHeader)+1]
		Loop
	EndIf
	cQueryCad := "SELECT DISTINCT C9_PEDIDO From "+RetSqlName("SC9")+"  WHERE"
	cQueryCad += " D_E_L_E_T_     = ' ' AND"
	cQueryCad += " C9_FILIAL      = '"+xFilial('SC9')+"' AND"
	cQueryCad += " C9_BLEST       = ' ' AND C9_NFISCAL = ' ' AND "
	cQueryCad += " C9_PRODUTO     = '"+_cProduto+"' AND "
	cQueryCad += " C9_NFENT       = '"+_aCamposChav[1]+"'"
	cQueryCad += " AND C9_SERENT  = '"+_aCamposChav[2]+"'"
	cQueryCad += " AND C9_FORNEC  = '"+_aCamposChav[3]+"'"
	cQueryCad += " AND C9_LOJAFOR = '"+_aCamposChav[4]+"'"
	cQueryCad += " GROUP BY C9_PEDIDO"
	cQueryCad += " ORDER BY C9_PEDIDO"
	TCQUERY cQueryCad NEW ALIAS "PEDLIB"
	DbSelectArea("PEDLIB")
	cPedLib := ""
	While !Eof()
		If AsCan(aPedLib,PEDLIB->C9_PEDIDO) = 0
			AaDd(aPedLib,PEDLIB->C9_PEDIDO)
			cPedLib += PEDLIB->C9_PEDIDO+Chr(13)
		Endif
		DbSkip()
	End  
	DbCloseArea()
Next

If Len(aPedLib) > 0
	cNotaEnt:= _aCamposChav[1]
	cSerEnt := _aCamposChav[2]
	cFornec := _aCamposChav[3]
	cLojaFor:= _aCamposChav[4]
	
	If ExistBlock("DMT100EMAIL")                                      
		// Ponto de Entrada para Enviar email com os Pedidos Liberados no Recebimento
		U_DMT100EMAIL(cPedLib)
	Endif
	
	If SuperGetMv("MV_IMPPENR") = "S"
		If ExistBlock("TFATR01")
			U_TFATR01(1,{},cNotaEnt,cSerEnt,cFornec,cLojaFor)
		Else
			T_TFATR01(1,{},cNotaEnt,cSerEnt,cFornec,cLojaFor)
		EndIf
	Else
		MsgInfo('Foram Liberados Pedidos Pendentes Apartir desta Nota,'+Chr(13)+;
		'Comunique Setor Comercial!')
	EndIf
EndIf

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥SD3240I   ∫ Autor ≥Vendas Clientes     ∫ Data ≥  19/10/01   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Ponto de Entrada para Liberacao de Pedidos na Movimentacao ∫±±
±±∫          ≥ Interna                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Template Function SD3240I()
Local aPedLib := {}

Private _nQuant,_aArea
CHKTEMPLATE("DCM")

If FindFunction("U_DSD3240I")
	U_DSD3240I()
Else
	If SD3->D3_TM <> "001"
		Return
	EndIf
	
	If SuperGetMV("MV_CONTAES") = "S"
		RETURN
	Endif
	
	_aArea := T_SRArea('S',nil)
	
	_nQuant := SD3->D3_QUANT
	
	IF !EMPTY(SD3->D3_NUMPDV+SD3->D3_ITEMPV)
		DbSelectArea('SC6')
		DbSetorder(1)
		If DbSeek(xFilial('SC6')+SD3->D3_NUMPDV+Alltrim(SD3->D3_ITEMPV))
			If SC6->C6_LOCAL = SD3->D3_LOCAL
				DbSelectArea("SC9")
				DbSetorder(1)
				If SC9->(DbSeek(xFilial("SC9")+SD3->D3_NUMPDV+Alltrim(SD3->D3_ITEMPV)))
					WHILE SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SD3->D3_NUMPDV .AND. Alltrim(SC9->C9_ITEM) == Alltrim(SD3->D3_ITEMPV)
						If SC9->C9_BLEST = '10' .OR. !Empty(SC9->C9_NFISCAL)
							SC9->(DbSkip())
							Loop
						Endif
						If EMPTY(SC9->C9_BLEST)
							SC9->(DbSkip())
							Loop
						EndIf
						GRSD3SC9()
						SC9->(DbSkip())
					End
				EndIf
			EndIf
		EndIf
	EndIf
	
	IF !Empty(SD3->D3_NUMPDV+SD3->D3_ITEMPV) .AND. _nQuant > 0
		If !MsgYesNo(STR0052) //,"Libera Pedidos de Venda","YESNO") //"Deseja liberar outros pedidos alem do informado ?"
			_nQuant := 0
		EndIf
	EndIf
	
	If _nQuant > 0
		cQueryCad := "SELECT C9_PEDIDO, C9_GRUPO, C9_PRODUTO, C9_ITEM, C9_SEQUEN, C9_QTDLIB From "+RetSqlName("SC9")+" WHERE"
		cQueryCad += " D_E_L_E_T_ <> '*' AND"
		cQueryCad += " C9_BLEST = '02' AND "
		cQueryCad += " C9_PRODUTO = '"+SD3->D3_COD+"'"
		cQueryCad += " ORDER BY C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO"
		TCQUERY cQueryCad NEW ALIAS "PROLIB"
		DbSelectArea("PROLIB")
		DbGoTop()
		While !Eof() .AND. _nQuant > 0
			DbSelectArea('SC6')
			DbSetorder(1)
			If !DbSeek(xFilial('SC6')+PROLIB->C9_PEDIDO+PROLIB->C9_ITEM)
				MsgStop(STR0055+PROLIB->C9_PEDIDO+'/'+PROLIB->C9_ITEM+STR0056)//'Problema na liberacao do Pedido '######', Verifique !' 
				DbSelectArea("PROLIB")
				DbSkip()
				Loop
			EndIf
			If SC6->C6_LOCAL = SD3->D3_LOCAL
				DbSelectArea("SC9")
				DbSetorder(1)
				If DbSeek(xFilial('SC9')+PROLIB->C9_PEDIDO+PROLIB->C9_ITEM+PROLIB->C9_SEQUEN)
					If GRSD3SC9()
						If AsCan(aPedLib, SC9->C9_PEDIDO) = 0
							AaDd(aPedLib, SC9->C9_PEDIDO)
						EndIf
					EndIf
				EndIf
			EndIf
			DbSelectArea("PROLIB")
			DbSkip()
		End
		DbCloseArea()
	EndIf
	
	If Alltrim(FUNNAME(1)) $ "#TESTA06/MATA240/MATA241"
		If Len(aPedLib) > 0
			If MsgBox(STR0053,STR0054,"YESNO") //"Deseja Emitir o Pedido de Venda ?"###"Pedido p/ Faturar"
				cNotaEnt:= SD3->D3_NUMSEQ
				cSerEnt := "SD3"
				cFornec := " "
				cLojaFor:= " "
				If SuperGetMV("MV_IMPPENR") = "S"
					T_TFATR01(1,aPedLib,cNotaEnt,cSerEnt,cFornec,cLojaFor)
				Else
					MsgBox(STR0057+Chr(13)+;
					STR0058,STR0059,'INFO')
				EndIf
			EndIf
		EndIf
	EndIf
	
	T_SRArea('R',_aArea)
EndIf

Return(Nil)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GRSD3SC9  ∫Autor  ≥Vendas Clientes     ∫ Data ≥  09/02/05   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GRSD3SC9()
Local _lLiber := .F.

_nQtdLib := T_VerSegUm(SC6->C6_SEGUM,SC6->C6_PRODUTO,_nQuant,SC6->C6_UNSVEN)

If SC9->C9_QTDLIB <= _nQtdLib .AND. _nQtdLib > 0
	RecLock("SC9",.F.)
	REPLACE SC9->C9_NFENT   WITH SD3->D3_NUMSEQ
	REPLACE SC9->C9_SERENT  WITH "SD3"
	REPLACE SC9->C9_BLEST   WITH ''
	REPLACE SC9->C9_DATALIB WITH dDataBase
	_nQuant             -= SC9->C9_QTDLIB
	MsUnLock()
	T_fa450Grava(1,.F.,.F.,.F.)
	
	DbSelectArea("SC6")
	
	Reclock("SC6",.F.)
	REPLACE SC6->C6_IMPRE  WITH "   "
	MsUnLock()
	
	DbSelectArea("SC9")
	
	_lLiber := .T.
	
ElseIf _nQtdLib > 0
	_nQtdPen := SC9->C9_QTDLIB-_nQtdLib
	_nSeq    := SC9->C9_SEQUEN
	_cVen    := SC9->C9_VEND
	_nPrcVen := SC9->C9_PRCVEN
	_cPedido := SC9->C9_PEDIDO
	_cItem   := SC9->C9_ITEM
	_cCliente:= SC9->C9_CLIENTE
	_cLoja   := SC9->C9_LOJA
	_cProduto:= SC9->C9_PRODUTO
	_cLocal  := SC9->C9_LOCAL
	_cLiber  := SC9->C9_BLPRE
	_cTpCarga:= SC9->C9_TPCARGA
	
	RecLock("SC9",.F.)
	REPLACE SC9->C9_NFENT   WITH SD3->D3_NUMSEQ
	REPLACE SC9->C9_SERENT  WITH "SD3"
	REPLACE SC9->C9_BLEST   WITH ""
	REPLACE SC9->C9_DATALIB WITH dDataBase
	REPLACE SC9->C9_QTDLIB  WITH _nQtdLib
	_nQuant             -= _nQtdLib
	MsUnLock()
	T_fa450Grava(1,.F.,.F.,.F.)
	
	DbSelectArea("SC9")
	DbSetorder(1)
	If !DbSeek(xFilial('SC9')+SD3->D3_NUMPDV+Alltrim(SD3->D3_ITEMPV)+StrZero(Val(_nSeq)+1,2,0))
		RecLock("SC9",.T.)
		REPLACE SC9->C9_FILIAL 	WITH xFilial("SC9")
		REPLACE SC9->C9_PEDIDO 	WITH _cPedido
		REPLACE SC9->C9_ITEM   	WITH _cItem
		REPLACE SC9->C9_CLIENTE	WITH _cCliente
		REPLACE SC9->C9_LOJA   	WITH _cLoja
		REPLACE SC9->C9_PRODUTO	WITH	 _cProduto
		REPLACE SC9->C9_LOCAL  	WITH _cLocal
		REPLACE SC9->C9_GRUPO 	WITH Posicione('SB1',1,xFilial('SB1')+_cProduto,'B1_GRUPO')
		REPLACE SC9->C9_BLPRE  	WITH _cLiber
		REPLACE SC9->C9_VEND   	WITH _cVen
		REPLACE SC9->C9_PRCVEN	WITH _nPrcVen
		REPLACE SC9->C9_SEQUEN	WITH StrZero(Val(_nSeq)+1,2,0)
		REPLACE SC9->C9_TPCARGA	WITH _cTpCarga
	Else
		RecLock("SC9",.F.)
		_nQtdPen += SC9->C9_QTDLIB
	EndIf
	REPLACE SC9->C9_QTDLIB  WITH _nQtdPen
	REPLACE SC9->C9_DATALIB WITH dDatabase
	REPLACE SC9->C9_BLEST   WITH '02'
	MsUnLock()
	T_fa450Grava(1,.F.,.F.,.T.)
	
	DbSelectArea("SC6")
	
	Reclock("SC6",.F.)
	REPLACE SC6->C6_IMPRE WITH "   "
	MsUnLock()
	
	DbSelectArea("SC9")
	
	_lLiber := .T.
EndIf         

Return(	_lLiber)    


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MD2520RL  ∫Autor  ≥Vendas Clientes     ∫ Data ≥  20/07/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Validacao da chamada para a Rotina para efetuar Reliberacoes∫±±
±±∫		     ≥  de Pedidos Excluidos                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Template Function MD2520RL()
Private cPerg := Padr("RELIEN",Len(SX1->X1_GRUPO))
If !Pergunte(cPerg,.T.)
	Return
EndIf

If Type("_lReLib") <> "U"
	_lReLib := Nil
EndIf

If FindFunction("U_ReLibPed")
	U_ReLibPed(MV_PAR01,Posicione("SUA",8,xFilial("SUA")+MV_PAR01,"UA_NUM"))	
Else
	T_ReLibPed(MV_PAR01,Posicione("SUA",8,xFilial("SUA")+MV_PAR01,"UA_NUM"))
EndIf	

Return    

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ReLibPed  ∫Autor  ≥Vendas Clientes     ∫ Data ≥  20/07/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Rotina para efetuar Reliberacoes de Pedidos Excluidos       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Template Function ReLibPed(_cNumSC5,_cNumSUA)
Local __aArea  := GetArea()
Local __aArA1  := SA1->(GetArea())
Local __aArUA  := SUA->(GetArea())
Local __aArUB  := SUB->(GetArea())
Local __aArC5  := SC5->(GetArea())
Local __aArC6  := SC6->(GetArea())
Local cAlias   := "SC5"
Local nReg     := 0
Local nOpc 	   := 1   	// 1= Libera
Local lEnd	   := .f.	//
Local i

Private	lTransf	:= .f. 	// .f. = N„o Utiliza Armazem Alternativo Para Liberacao (Soh Usa Armazem Padrao)
Private	lLiber	:= .t.	// .t. = Soh Libera Pedido Qdo Houver Saldo Em Estoque
Private	lSugere	:= .t.	// .t. = Sugere Quantidade a Liberar No Pedido

// Cria variaveis De Parametro Caso N„o Exista
For i := 1 To 20
	_cPar := "MV_PAR" + StrZero(i,2)
	_cParX:= "MV_PARX" + StrZero(i,2)
	&(_cParX) := &(_cPar)
Next

SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SC5")+_cNumSC5))
nReg   := SC5->(Recno())

// Ajusta Parametros
Pergunte(Padr("MTALIB",Len(SX1->X1_GRUPO)),.f.)

MV_PAR01 := 1
MV_PAR02 := MV_PAR03 := _cNumSC5
MV_PAR04 := Space(6)
MV_PAR05 := "ZZZZZZ"
MV_PAR06 := StoD("20000101")
MV_PAR07 := StoD(StrZero((Year(dDataBase)+1),4) + "1231")
MV_PAR08 := 1

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ mv_par01 Ordem Processmento ?  Ped.+Item /Dt.Entrega+Ped.+Item         ≥
//≥ mv_par02 Pedido de          ?                                          ≥
//≥ mv_par03 Pedido ate         ?                                          ≥
//≥ mv_par04 Cliente de         ?                                          ≥
//≥ mv_par05 Cliente ate        ?                                          ≥
//≥ mv_par06 Dta Entrega de     ?                                          ≥
//≥ mv_par07 Dta Entrega ate    ?                                          ≥
//≥ mv_par08 Liberar            ? Credito/Estoque Credito                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
SUA->(DbSetOrder(1))
SUA->(DbSeek(xFilial("SUA")+_cNumSUA))

a440Proces(cAlias,nReg,nOpc,lEnd)

For i := 1 To 20
	_cPar := "MV_PAR" + StrZero(i,2)
	_cParX:= "MV_PARX" + StrZero(i,2)
	&(_cPar) := &(_cParX)
Next

SC9->(DbSetOrder(1))
If SC9->(DbSeek(xFilial("SC9")+_cNumSC5))
	While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == _cNumSC5
		If Empty(SC9->C9_BLEST) .And. !Empty(SC9->C9_BLPRE) .And. Empty(SC9->C9_NFENT)
			RecLock("SC9",.F.)
			SC9->C9_BLPRE := STR0116 //"RELIBERACAO POR EXCLUSAO DE NF"
			SC9->C9_BLINF := STR0116 //"RELIBERACAO POR EXCLUSAO DE NF"
			SC9->C9_BLCONF:= "OK"
			SC9->C9_BLCRED:= ""
			MsUnLock()
		Endif
		SC9->(DbSkip())
	End  
EndIf

RestArea(__aArA1)
RestArea(__aArUA)
RestArea(__aArUB)
RestArea(__aArC5)
RestArea(__aArC6)
RestArea(__aArea)

Return 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥EmailPen  ∫Autor  ≥Vendas Clientes     ∫ Data ≥  20/07/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Envio das  de informacoes por e-mail					      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Template Function EmailPen(cTextoPen,cTextoMen)
PRIVATE CORIMAIL := GETMV("MV_EMCONTA")

If MsgBox(STR0118+cTextoMen+STR0119,STR0120,"YESNO") //"Deseja enviar as "###" por e-mail?"###"Envio de Mail"
	T_EnvMail2(cTextoMen+": "+M->UA_NUM, cTextoPen, cOriMail, "", "", NIL, NIL)
EndIf                      

Return (.T.)