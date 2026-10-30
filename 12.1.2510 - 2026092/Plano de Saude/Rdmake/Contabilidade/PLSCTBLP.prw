#INCLUDE 'PROTHEUS.CH'

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04" 
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"
#DEFINE TP_RDA_OPE "OPE"
 
//***************** DESPESAS *******************/

/*/{Protheus.doc} PLCTB9CN
Configuração LP de Despesa-9CN

Utilizar na CT5 PLCTB9CN('001') (Informe a Sequencia)

Para diferenciar por tipo de guia basta usar as variaveis abaixo
G_CONSULTA  "01"
G_SADT_ODON "02"
G_SOL_INTER "03"
G_REEMBOLSO "04" 
G_RES_INTER "05"
G_HONORARIO "06"
G_ANEX_QUIM "07"
G_ANEX_RADI "08"
G_ANEX_OPME "09"
G_REC_GLOSA "10"
G_PROR_INTE "11"

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9CN(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
				
		if BD7->BD7_VLRAPR > 0
			xRet := BD7->BD7_VLRAPR
		elseIf BD7->BD7_VLRMAN > 0	
			xRet := BD7->BD7_VLRMAN
		else
			xRet := 0
		endIf	
			
	//Credito
	case cSeq == '002'

		if BD7->BD7_VLRAPR > 0
			xRet := BD7->BD7_VLRAPR
		elseIf BD7->BD7_VLRMAN > 0	
			xRet := BD7->BD7_VLRMAN
		else
			xRet := 0
		endIf	
	
endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9CT
Configuração LP de Despesa-9CT

Utilizar na CT5 PLCTB9CT('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9CT(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
				
		if BD7->BD7_VLRGLO > 0
			xRet := BD7->BD7_VLRGLO
		else
			xRet := 0
		endIf	
			
	//Credito
	case cSeq == '002'

		if BD7->BD7_VLRGLO > 0
			xRet := BD7->BD7_VLRGLO
		else
			xRet := 0
		endIf	

	//Debito
	case cSeq == '003'
				
		if BD7->BD7_VLRTPF > 0
			xRet := BD7->BD7_VLRTPF
		else
			xRet := 0
		endIf	
			
	//Credito
	case cSeq == '004'

		if BD7->BD7_VLRTPF > 0
			xRet := BD7->BD7_VLRTPF
		else
			xRet := 0
		endIf	


endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9AG
Configuração LP de Despesa-9AG

Utilizar na CT5 PLCTB9AG('001') (Informe a Sequencia)
Para diferenciar por impostos informe o imposto 
"E2_IRRF"

Atençao verificar se o imposto e na competencia ou caixa (na Baixa)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9AG(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
		
		xRet := 0	          
		if ! BGQ->(eof())
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9AGPAG")
		endIf

	//Credito
	case cSeq == '002'

		xRet := 0	          
		if ! BGQ->(eof())
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9AGPAG")
		endIf

	//Debito
	case cSeq == '003'
		
		xRet := 0	          
		if SE2->E2_IRRF > 0

			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9AGIR", 'E2_IRRF')
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9AGIR", 'E2_IRRF')
			endIf

		endIf

	//Credito
	case cSeq == '004'

		xRet := 0	          
		if SE2->E2_IRRF > 0	
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9AGIR", 'E2_IRRF')
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9AGIR", 'E2_IRRF')
			endIf

		endIf
	
	//Debito
	case cSeq == '005'

		xRet := 0
		if SE2->E2_INSS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9AGINSS", "E2_INSS")
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9AGINSS", "E2_INSS")
			endIf

		endIf
		    
	//Credito
	case cSeq == '006'

		xRet := 0
		if SE2->E2_INSS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9AGINSS", "E2_INSS")
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9AGINSS", "E2_INSS")
			endIf

		endIf

endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9BD
Configuração LP de Despesa-9BD-(Baixa)

Utilizar na CT5 PLCTB9BD('001') (Informe a Sequencia)

Para diferenciar por tipo de guia basta usar as variaveis abaixo
G_CONSULTA  "01"
G_SADT_ODON "02"
G_SOL_INTER "03"
G_REEMBOLSO "04" 
G_RES_INTER "05"
G_HONORARIO "06"
G_ANEX_QUIM "07"
G_ANEX_RADI "08"
G_ANEX_OPME "09"
G_REC_GLOSA "10"
G_PROR_INTE "11"

Use para retornar valores sem rateio
xRet := PLIMPFUL("9BD503","FK2",FK2->FK2_VALOR)

Atençao verificar se o imposto e na competencia ou caixa (na Baixa)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9BD(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
		
		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDPAG",,,.t.)
		endIf

	//Credito
	case cSeq == '002'

		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDPAG",,,.t.)
		endIf

	//Debito
	case cSeq == '003'

		xRet := 0
		if SE2->E2_VRETISS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '004'
		
		xRet := 0
		if SE2->E2_VRETISS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Debito
	case cSeq == '005'
		
		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '006'

		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf

	//Debito
	case cSeq == '007'

		xRet := 0
		if SE2->E2_VRETINS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDINSS", "E2_VRETINS",,.t.)
			endIf

		endIf
		    
	//Credito
	case cSeq == '008'

		xRet := 0
		if SE2->E2_VRETINS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BDINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BDINSS", "E2_VRETINS",,.t.)
			endIf

		endIf

	//Credito-MTJR
	case cSeq == '009'
		
		xRet := PLIMPFK6('9BDMTJRC', 'FK2', 'MT|JR')

	//Debito-DC
	case cSeq == '010'
	
		xRet := PLIMPFK6('9BDDCD', 'FK2', 'DC')

endCase		

return(xRet)

/*/{Protheus.doc} PLCTB9BL
Configuração LP de Despesa-9BL

Utilizar na CT5 PLCTB9BL('001') (Informe a Sequencia)

Para diferenciar por tipo de guia basta usar as variaveis abaixo
G_CONSULTA  "01"
G_SADT_ODON "02"
G_SOL_INTER "03"
G_REEMBOLSO "04" 
G_RES_INTER "05"
G_HONORARIO "06"
G_ANEX_QUIM "07"
G_ANEX_RADI "08"
G_ANEX_OPME "09"
G_REC_GLOSA "10"
G_PROR_INTE "11"
 
@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9BL(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
		
		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLPAG",,,.t.)
		endIf

	//Credito
	case cSeq == '002'

		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLPAG",,,.t.)
		endIf

	//Debito
	case cSeq == '003'

		xRet := 0
		if SE2->E2_VRETISS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '004'
		
		xRet := 0
		if SE2->E2_VRETISS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Debito
	case cSeq == '005'
		
		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '006'

		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf

	//Debito
	case cSeq == '007'

		xRet := 0
		if SE2->E2_VRETINS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLINSS", "E2_VRETINS",,.t.)
			endIf

		endIf
		    
	//Credito
	case cSeq == '008'

		xRet := 0
		if SE2->E2_VRETINS > 0
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9BLINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9BLINSS", "E2_VRETINS",,.t.)
			endIf

		endIf
	
	//Credito-MTJR
	case cSeq == '009'
		
		xRet := PLIMPFK6('9BLMTJRC', 'FK2', 'MT|JR')

	//Debito-DC
	case cSeq == '010'
	
		xRet := PLIMPFK6('9BLDCD', 'FK2', 'DC')


endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9NB
Configuração LP de Despesa-9NB-(Baixa)-Nao movimenta banco

Utilizar na CT5 PLCTB9NB('001') (Informe a Sequencia)

Para diferenciar por tipo de guia basta usar as variaveis abaixo
G_CONSULTA  "01"
G_SADT_ODON "02"
G_SOL_INTER "03"
G_REEMBOLSO "04" 
G_RES_INTER "05"
G_HONORARIO "06"
G_ANEX_QUIM "07"
G_ANEX_RADI "08"
G_ANEX_OPME "09"
G_REC_GLOSA "10"
G_PROR_INTE "11"

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9NB(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
		
		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBPAG",,,.t.)
		endIf

	//Credito
	case cSeq == '002'

		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBPAG",,,.t.)
		endIf

	//Debito
	case cSeq == '003'

		xRet := 0
		if SE2->E2_VRETISS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '004'
		
		xRet := 0
		if SE2->E2_VRETISS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Debito
	case cSeq == '005'
		
		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '006'

		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf
	
	//Debito
	case cSeq == '007'

		xRet := 0
		if SE2->E2_VRETINS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBINSS", "E2_VRETINS",,.t.)
			endIf

		endIf
		    
	//Credito
	case cSeq == '008'

		xRet := 0
		if SE2->E2_VRETINS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBINSS", "E2_VRETINS",,.t.)
			endIf

		endIf

	//Credito-MTJR
	case cSeq == '009'
		
		xRet := PLIMPFK6('9NBMTJRC', 'FK2', 'MT|JR')

	//Debito-DC
	case cSeq == '010'
	
		xRet := PLIMPFK6('9NBDCD', 'FK2', 'DC')

endCase

return(xRet)

/*/{Protheus.doc} PLCTB9NC
Configuração LP de Despesa-9NC-Nao movimenta banco

Utilizar na CT5 PLCTB9NC('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9NC(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
		
		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NCPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NCPAG",,,.t.)
		endIf

	//Credito
	case cSeq == '002'

		xRet := 0
		if ! BD7->(eof())
			xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NCPAG",,,.t.)
		elseIf ! BGQ->(eof())	
			xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NCPAG",,,.t.)
		endIf

	//Debito
	case cSeq == '003'

		xRet := 0
		if SE2->E2_VRETISS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NCISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NCISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '004'
		
		xRet := 0
		if SE2->E2_VRETISS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NCISS", "E2_VRETISS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NCISS", "E2_VRETISS",,.t.)
			endIf

		endIf

	//Debito
	case cSeq == '005'
		
		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NCPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NCPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf

	//Credito
	case cSeq == '006'

		xRet := 0
		if SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL) > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NCPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NCPCC", "E2_VRETPIS+E2_VRETCOF+E2_VRETCSL",,.t.)
			endIf

		endIf

	//Debito
	case cSeq == '007'

		xRet := 0
		if SE2->E2_VRETINS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBINSS", "E2_VRETINS",,.t.)
			endIf

		endIf
		    
	//Credito
	case cSeq == '008'

		xRet := 0
		if SE2->E2_VRETINS > 0 .and. FK2->FK2_TPDOC != 'BA'
			
			if ! BD7->(eof())
				xRet := PLSRATT('SE2', BD7->BD7_VLRPAG, "9NBINSS", "E2_VRETINS",,.t.)
			elseIf ! BGQ->(eof())
				xRet := PLSRATT('SE2', BGQ->BGQ_VALOR, "9NBINSS", "E2_VRETINS",,.t.)
			endIf

		endIf

	//Credito-MTJR
	case cSeq == '009'
		
		xRet := PLIMPFK6('9NCMTJRC', 'FK2', 'MT|JR')

	//Debito-DC
	case cSeq == '010'
	
		xRet := PLIMPFK6('9NCDCD', 'FK2', 'DC')

endCase

return(xRet)

/*/{Protheus.doc} PLCTB9LA
Configuração LP de Despesa-9LA-(Provisao-lote aviso)

Utilizar na CT5 PLCTB9LA('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9LA(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
				
		xRet := B6T->B6T_VLRPRO 
			
	//Credito
	case cSeq == '002'

		xRet := B6T->B6T_VLRPRO 
			
endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9LB
Configuração LP de Despesa-9LB-(Cobrado-lote aviso)

Utilizar na CT5 PLCTB9LB('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9LB(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
				
		xRet := B6T->B6T_VLR500
			
	//Credito
	case cSeq == '002'

		xRet := B6T->B6T_VLR500 
			
endCase	

return(xRet)

//***************** RECEITA *******************/

/*/{Protheus.doc} PLCTB9A1 
Configuração LP de Receita-9A1

Utilizar na CT5 PLCTB9A1('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9A1(cSeq)
local xRet := 0

do case
	//Debito
	case cSeq == '001'

		xRet := 0
		if BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1PAG1")
		endIf
			
	//Credito
	case cSeq == '002'

		xRet := 0
		if BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1PAG1")
		endIf

	//Debito
	case cSeq == '003'

		xRet := 0
		if BM1->BM1_TIPO == '2'
			//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1PAG2")
			xRet := PLIMPFUL("9A1PAG003", "BM1", BM1->BM1_VALOR)
		endIf
			
	//Credito
	case cSeq == '004'

		xRet := 0
		if BM1->BM1_TIPO == '2'
			//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1PAG2")
			xRet := PLIMPFUL("9A1PAG004", "BM1", BM1->BM1_VALOR)
		endIf

	//Debito-irrf 
	case cSeq == '005'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_IRRF > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1IR", 'E1_IRRF')
		endIf
			
	//Credito-irrf 
	case cSeq == '006'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_IRRF > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1IR", 'E1_IRRF')
		endIf
		
	//Debito-cofins
	case cSeq == '007'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_COFINS > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1COFINS", 'E1_COFINS')
		endIf
			
	//Credito-cofins
	case cSeq == '008'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_COFINS > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1COFINS", 'E1_COFINS')
		endIf

	//Debito-pis
	case cSeq == '009'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_PIS > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1PIS", 'E1_PIS')
		endIf
			
	//Credito-pis
	case cSeq == '010'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_PIS > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1PIS", 'E1_PIS')
		endIf

	//Debito-csll
	case cSeq == '011'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_CSLL > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1CSLL", 'E1_CSLL')
		endIf
			
	//Credito-csll 
	case cSeq == '012'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_CSLL > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A1CSLL", 'E1_CSLL')
		endIf

endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9A2 
Configuração LP de Receita-9A2

Utilizar na CT5 PLCTB9A2('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9A2(cSeq)
local xRet := 0

do case
	//Debito
	case cSeq == '001'

		xRet := 0
		if BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A2PAG1")
		endIf
			
	//Credito
	case cSeq == '002'

		xRet := 0
		if BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A2PAG1")
		endIf

	//Debito
	case cSeq == '003'

		xRet := 0
		if BM1->BM1_TIPO == '2'
			//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A2PAG2")
			xRet := PLIMPFUL("9A2PAG003", "BM1", BM1->BM1_VALOR)
		endIf
			
	//Credito
	case cSeq == '004'

		xRet := 0
		if BM1->BM1_TIPO == '2'
			//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A2PAG2")
			xRet := PLIMPFUL("9A2PAG004", "BM1", BM1->BM1_VALOR)
		endIf

	//Debito-irrf 
	case cSeq == '005'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_IRRF > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A2IR", 'E1_IRRF')
		endIf
			
	//Credito-irrf 
	case cSeq == '006'

		xRet := 0

		if BM1->BM1_TIPO == '1' .and. SE1->E1_IRRF > 0
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9A2IR", 'E1_IRRF')
		endIf

endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9AX
Configuração LP de Receita-9AX

Utilizar na CT5 PLCTB9AX('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9AX(cSeq)
local xRet 	 := 0
local nFator := 0

do case
	//Debito-pagamento
	case cSeq == '001' 
		
		if BM1->BM1_TIPO == '1' 

			xRet := PLIMPFUL("9AXPAGF", "FK1", FK1->FK1_VALOR)
		 	//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXPAG",,,.t.)
		
		elseIf SE1->E1_TIPO == 'NCC'
			 
			 xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXPAG",,,.t.)			 

		elseIf BM1->BM1_TIPO == '2'
			 xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXPAGFDD2",,, .t., nil, .t.)
		endIf

	//Credito-pagamento
	case cSeq == '002'
	
		if BM1->BM1_TIPO == '1'
			 
			//xRet := PLIMPFUL("9AXPAGF", "FK1", FK1->FK1_VALOR)
			//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXPAG",,,.t.)
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXPAGFDD1",,, .t., nil, .t.)

		/*elseIf SE1->E1_TIPO == 'NCC' 
			 
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXPAG",,,.t.)

		elseIf BM1->BM1_TIPO == '2'
			 
			nFator 	:= ( FK1->FK1_VALOR / SE1->E1_VALOR )
			xRet 	:= ( BM1->BM1_VALOR * nFator )
		*/
		endIf

	//Debito-iss
	case cSeq == '003'

		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXISS", 'E1_VRETISS',,.t.)
		endIf
			
	//Credito-iss
	case cSeq == '004'

		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9AXISS", 'E1_VRETISS',,.t.)
		endIf

	//Credito-MTJR
	case cSeq == '005'
		
		xRet := PLIMPFK6('9AXMTJRC', 'FK1', 'MT|JR')

	//Debito-DC
	case cSeq == '006'
	
		xRet := PLIMPFK6('9AXDCD', 'FK1', 'DC')


endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9B6
Configuração LP de Receita-9B6-nao movimenta banco

Utilizar na CT5 PLCTB9B6('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9B6(cSeq)
local xRet   := 0
local nFator := 0

do case

	//Debito-Debitos
	case cSeq == '001' 

		if BM1->BM1_TIPO == '1' 

			xRet := PLIMPFUL("9B6PAGF", "FK1", Fk1->FK1_VALOR)
		 	//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9B6PAG",,,.t.)
		
		elseIf SE1->E1_TIPO == 'NCC'
			 
			 xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9B6PAG",,,.t.)			 

		else

			nFator 	:= ( FK1->FK1_VALOR / SE1->E1_VALOR )
			xRet 	:= ( BM1->BM1_VALOR * nFator )

		endIf

	//Credito-Debitos
	case cSeq == '002'

		if BM1->BM1_TIPO == '1' .or. SE1->E1_TIPO == 'NCC'
			 xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9B6PAG",,,.t.)
		endIf	

	//Debito-iss
	case cSeq == '003'

		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9B6ISS", 'E1_VRETISS',,.t.)
		endIf
			
	//Credito-iss
	case cSeq == '004'
		
		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9B6ISS", 'E1_VRETISS',,.t.)
		endIf

	//Credito-MT
	case cSeq == '005'
		
		xRet := PLIMPFK6('9B6MTJRC', 'FK1', 'MT|JR')

	//Debito-DC
	case cSeq == '006'
	
		xRet := PLIMPFK6('9B6DCD', 'FK1', 'DC')


endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9NX
Configuração LP de Receita-9NX-nao movimenta banco

Utilizar na CT5 PLCTB9NX('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9NX(cSeq)
local xRet 	 := 0
local nFator := 0
do case

	//Debito-Debitos
	case cSeq == '001' 
		
		if BM1->BM1_TIPO == '1' 

			xRet := PLIMPFUL("9NXPAGF", 'FK1', Fk1->FK1_VALOR)
		 	//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9NXPAG",,,.t.)
		
		elseIf SE1->E1_TIPO == 'NCC'
			 
			//xRet := PLIMPFUL("9NXNCC001", 'FK1', BM1->BM1_VALOR)
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9NXNCC001",,,.t.)

		else

			nFator 	:= ( FK1->FK1_VALOR / SE1->E1_VALOR )
			xRet 	:= ( BM1->BM1_VALOR * nFator ) 

		endIf

	//Credito-Debitos
	case cSeq == '002'
		
		if BM1->BM1_TIPO == '1'

			 xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9NXPAG",,,.t.)

		elseIf SE1->E1_TIPO == 'NCC'
			 
			//xRet := PLIMPFUL("9NXNCC002", 'FK1', BM1->BM1_VALOR)
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9NXNCC002",,,.t.)
		 
		endIf

	//Debito-iss
	case cSeq == '003'

		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9NXISS", 'E1_VRETISS',,.t.)
		endIf
			
	//Credito-iss
	case cSeq == '004'
		
		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9NXISS", 'E1_VRETISS',,.t.)
		endIf

	//Credito-MTJR
	case cSeq == '005'
		
		xRet := PLIMPFK6('9NXMTJRC', 'FK1', 'MT|JR')

	//Debito-DC
	case cSeq == '006'
	
		xRet := PLIMPFK6('9NXDCD', 'FK1', 'DC')

endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9N6
Configuração LP de Receita-9N6

Utilizar na CT5 PLCTB9N6('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9N6(cSeq)
local xRet 	 := 0
local nFator := 0

do case

	//Debito-Debitos
	case cSeq == '001' 
		
		if BM1->BM1_TIPO == '1' 

			xRet := PLIMPFUL("9N6PAGF", 'FK1', Fk1->FK1_VALOR)
		 	//xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9N6PAG",,,.t.)
		
		elseIf SE1->E1_TIPO == 'NCC'
			 
			 xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9N6PAG",,,.t.)			 

		else

			nFator 	:= ( FK1->FK1_VALOR / SE1->E1_VALOR )
			xRet 	:= ( BM1->BM1_VALOR * nFator )

		endIf

	//Credito-Debitos
	case cSeq == '002'

		if BM1->BM1_TIPO == '1' .or. SE1->E1_TIPO == 'NCC'
			 xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9N6PAG",,,.t.)
		endIf

	//Debito-iss
	case cSeq == '003'

		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9N6ISS", 'E1_VRETISS',,.t.)
		endIf
			
	//Credito-iss
	case cSeq == '004'
		
		xRet := 0

		if SE1->E1_VRETISS > 0 .and. BM1->BM1_TIPO == '1'
			xRet := PLSRATT('SE1', BM1->BM1_VALOR, "9N6ISS", 'E1_VRETISS',,.t.)
		endIf
	
	//Credito-MTJR
	case cSeq == '005'
		
		xRet := PLIMPFK6('9N6MTJRC', 'FK1', 'MT|JR')

	//Debito-DC
	case cSeq == '006'
	
		xRet := PLIMPFK6('9N6DCD', 'FK1', 'DC')

endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9LC
Configuração LP de Despesa-9LC-(Provisao-lote aviso)

Utilizar na CT5 PLCTB9LC('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9LC(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
				
		xRet := B6S->B6S_VLRPRO 
			
	//Credito
	case cSeq == '002'

		xRet := B6S->B6S_VLRPRO 
			
endCase	

return(xRet)

/*/{Protheus.doc} PLCTB9LD
Configuração LP de Despesa-9LD-(Provisao-lote aviso)

Utilizar na CT5 PLCTB9LD('001') (Informe a Sequencia)

@author  PLS Contabil
@version P12
@since   07.07.17
/*/
user function PLCTB9LD(cSeq)
local xRet := 0

do case

	//Debito
	case cSeq == '001'
				
		xRet := B6S->B6S_V500PF 
			
	//Credito
	case cSeq == '002'

		xRet := B6S->B6S_V500PF 
			
endCase	

return(xRet)

/*/{Protheus.doc} PCTBCT5
Lancamentos do financeiro FINA370
@author  Contabilidade
@version P12
@since   07.07.17
/*/
user function PCTBCT5(cSeq)
local xRet := 0

do case

	case cSeq == '510001'
		xRet := iIf(allTrim(SE2->E2_ORIGEM) == "FINA050" .and. allTrim(SE2->E2_PREFIXO) <> "RMB/CRB/RMD" .and. allTrim(SE2->E2_TIPO) <> "RC" .and. allTrim(SE2->E2_MULTNAT) <> "1",SE2->(E2_VALOR+E2_VRETISS+E2_IRRF+E2_INSS),0)
	case cSeq == '510002A'
		xRet := iIf(allTrim(SE2->E2_NATUREZ) == "291001","2111190340001",iIf(allTrim(SE2->E2_NATUREZ) == "291002","2131190110001",iIf(allTrim(SE2->E2_NATUREZ) == "291003","2138190810001",iIf(allTrim(SE2->E2_NATUREZ)=="291004","1241290110002",SA2->A2_CONTA))))
	case cSeq == '510002B'
		xRet := iIf(allTrim(SE2->E2_ORIGEM) == "FINA050" .and. allTrim(SE2->E2_PREFIXO) <> "RMB/RMD/CRB" .and. allTrim(SE2->E2_TIPO)<>"RC" .and. allTrim(SE2->E2_MULTNAT) <> "1",SE2->(E2_VALOR+E2_VRETISS+E2_IRRF+E2_INSS),0)		
	case cSeq = '510004'
		xRet := iIf(allTrim(SE2->E2_NATUREZ) == "291001","2111190340001",iIf(allTrim(SE2->E2_NATUREZ) == "291002","2131190110001",iIf(allTrim(SE2->E2_NATUREZ)=="291003","2138190810001",iIf(allTrim(SE2->E2_NATUREZ)=="291004","1241290110002",SA2->A2_CONTA))))
	case cSeq == '515002'
		xRet := iIf(allTrim(SE2->E2_NATUREZ) == "291001","2111190340001",iIf(allTrim(SE2->E2_NATUREZ) == "291002","2131190110001",iIf(allTrim(SE2->E2_NATUREZ)=="291003","2138190810001",iIf(allTrim(SE2->E2_NATUREZ)=="291004","1241290110002",SA2->A2_CONTA))))
	case cSeq =='515004'
		xRet := iIf(allTrim(SE2->E2_NATUREZ) == "291001","2111190340001",iIf(allTrim(SE2->E2_NATUREZ) == "291002","2131190110001",iIf(allTrim(SE2->E2_NATUREZ)=="291003","2138190810001",iIf(allTrim(SE2->E2_NATUREZ)=="291004","1241290110002",SA2->A2_CONTA))))
	case cSeq == '530001'
		xRet := iIf(!allTrim(SE5->E5_PREFIXO) $ "PLS/PSP/ADV/RMB/RMD/CRB" .and. SE5->E5_TIPO <> "PA" .and. empty(SE5->E5_AGLIMP) .and. !(allTrim(SE5->E5_MOTBX) $ "DAC/CMP/LIQ/PCC/IRF/FAT/DEV"),SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '530002'
		xRet := iIf(!allTrim(SE5->E5_PREFIXO) $ "PLS/PSP/ADV/RMB/RMD/CRB" .and. SE5->E5_TIPO <> "PA" .and. empty(SE5->E5_AGLIMP) .and. !(allTrim(SE5->E5_MOTBX) $ "DAC/CMP/LIQ/PCC/IRF/FAT/DEV"),SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '531001'
		xRet := iIf(!allTrim(SE5->E5_PREFIXO) $ "PLS/PSP/ADV/RMB/RMD/CRB" .and. SE5->E5_TIPO <> "PA" .and. empty(SE5->E5_AGLIMP) .and. !(allTrim(SE5->E5_MOTBX) $ "DAC/CMP/LIQ/PCC/IRF/FAT/DEV"),SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '531002'
		xRet := iIf(!allTrim(SE5->E5_PREFIXO) $ "PLS/PSP/ADV/RMB/RMD/CRB" .and. SE5->E5_TIPO <> "PA" .and. empty(SE5->E5_AGLIMP) .and. !(allTrim(SE5->E5_MOTBX) $ "DAC/CMP/LIQ/PCC/IRF/FAT/DEV"),SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '531015'
		xRet := iIf(allTrim(SE2->E2_ORIGEM) == "FINA050" .and. allTrim(SE5->E5_RECPAG) $ "P",SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '531016'
		xRet := iIf(allTrim(SE2->E2_ORIGEM) == "FINA050" .and. allTrim(SE5->E5_RECPAG) $ "P",SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '532001'
		xRet := iIf(!allTrim(SE5->E5_PREFIXO) $ "PLS/PSP/ADV/RMB/RMD/CRB" .and. SE5->E5_TIPO <> "PA".and. empty(SE5->E5_AGLIMP) .and. !(allTrim(SE5->E5_MOTBX)$"DAC/CMP/LIQ/PCC/IRF/FAT/DEV"),SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '532002'
		xRet := iIf(!allTrim(SE5->E5_PREFIXO) $ "PLS/PSP/ADV/RMB/RMD/CRB" .and. SE5->E5_TIPO<>"PA".and. empty(SE5->E5_AGLIMP) .and. !(allTrim(SE5->E5_MOTBX)$"DAC/CMP/LIQ/PCC/IRF/FAT/DEV"),SE5->(E5_VALOR+E5_VLDESCO-E5_VLMULTA-E5_VLJUROS),0)
	case cSeq == '660002'
		xRet := iIf(RIGHT(allTrim(SD1->D1_CF),3) $ ("933/949") .and. allTrim(SB1->B1_ZPLS) <> "S" .and. POSICIONE("SED",1,xFilial("SED")+POSICIONE("SE2",6,XFILIAL("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC,"E2_NATUREZ"),"ED_CALCISS")=="S",SE2->E2_VRETISS,0)
	case cSeq == '665002'
		xRet := iIf(RIGHT(allTrim(SD1->D1_CF),3) $ ("933/949") .and. allTrim(SB1->B1_ZPLS) <> "S" .and. POSICIONE("SED",1,xFilial("SED")+POSICIONE("SE2",6,XFILIAL("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC,"E2_NATUREZ"),"ED_CALCISS")=="S",SE2->E2_VRETISS,0)					
	endCase
	
return(xRet)

/*/{Protheus.doc} PLCTBORH
Retorna Origem, Historico e Aglutinado
@author  Contabilidade
@version P12
@since   07.07.17
/*/
user function PLCTBORH(cLp, cSeq, cTp)
local cRet  := ''
local cText := ''
local cInd  := ''

do case

	case cLp == '9CN'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-ASSIST'
		elseIf cSeq == '002'
			cText := 'CRE-ASSIST-'
			cInd  := '-ASSIST'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-BD7.: " + BD7->( BD7_CODPEG + '-' + BD7_NUMERO ) + "-" + BD7->BD7_CODRDA
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-BD7.: " + BD7->( BD7_CODPEG + '-' + BD7_NUMERO ) + "-" + BD7->BD7_CODRDA
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-BD7-RECNO: " + cValToChar(BD7->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9CT'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-GLOSA'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-GLOSA'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-COPART'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-COPART'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-BD7.: " + BD7->( BD7_CODPEG + '-' + BD7_NUMERO ) + "-" + BD7->BD7_CODRDA
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-BD7.: " + BD7->( BD7_CODPEG + '-' + BD7_NUMERO ) + "-" + BD7->BD7_CODRDA
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-BD7-RECNO: " + cValToChar(BD7->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9AG'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-PAG'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-PAG'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-IRRF'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-IRRF'
		elseIf cSeq == '005'
			cText := 'DEB-'
			cInd  := '-INSS'
		elseIf cSeq == '006'
			cText := 'CRE-'
			cInd  := '-INSS'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-SE2-RECNO: " + cValToChar(SE2->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9BD'
		
		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-PAG'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-PAG'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'DEB-'
			cInd  := '-PCC'
		elseIf cSeq == '006'
			cText := 'CRE-'
			cInd  := '-PCC'
		elseIf cSeq == '007'
			cText := 'DEB-'
			cInd  := '-INS'
		elseIf cSeq == '008'
			cText := 'CRE-'
			cInd  := '-INS'
		elseIf cSeq == '009'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '010'
			cText := 'DEB-'
			cInd  := '-DC'

		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-BAIXA-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-BAIXA-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK2-RECNO: " + cValToChar(FK2->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9BL'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-PAG'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-PAG'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'DEB-'
			cInd  := '-PCC'
		elseIf cSeq == '006'
			cText := 'CRE-'
			cInd  := '-PCC'
		elseIf cSeq == '007'
			cText := 'DEB-'
			cInd  := '-INS'
		elseIf cSeq == '008'
			cText := 'CRE-'
			cInd  := '-INS'
		elseIf cSeq == '009'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '010'
			cText := 'DEB-'
			cInd  := '-DC'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-CANCEL B-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-CANCEL B-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK2-RECNO: " + cValToChar(FK2->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9NB'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-PAG'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-PAG'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'DEB-'
			cInd  := '-PCC'
		elseIf cSeq == '006'
			cText := 'CRE-'
			cInd  := '-PCC'
		elseIf cSeq == '007'
			cText := 'DEB-'
			cInd  := '-INS'
		elseIf cSeq == '008'
			cText := 'CRE-'
			cInd  := '-INS'
		elseIf cSeq == '009'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '010'
			cText := 'DEB-'
			cInd  := '-DC'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-BAIXA-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-BAIXA-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK2-RECNO: " + cValToChar(FK2->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9NC'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-PAG'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-PAG'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'DEB-'
			cInd  := '-PCC'
		elseIf cSeq == '006'
			cText := 'CRE-'
			cInd  := '-PCC'
		elseIf cSeq == '007'
			cText := 'DEB-'
			cInd  := '-INS'
		elseIf cSeq == '008'
			cText := 'CRE-'
			cInd  := '-INS'
		elseIf cSeq == '009'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '010'
			cText := 'DEB-'
			cInd  := '-DC'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-CANCEL B-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-CANCEL B-SE2.: " + SE2->( E2_PREFIXO + '-' + E2_NUM + '-' + E2_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK2-RECNO: " + cValToChar(FK2->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9LA'
		
		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-APROP'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-APROP'
		endIf	

		if cTp == 'H'
			cRet := cLp + cInd + "-B6T.: " + B6T->( B6T_SEQLOT + '-' + B6T_SEQGUI )
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-B6T.: " + B6T->( B6T_SEQLOT + '-' + B6T_SEQGUI )
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-B6T-RECNO: " + cValToChar(B6T->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9LB'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-COBRAD'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-COBRAD'
		endIf	

		if cTp == 'H'
			cRet := cLp + cInd + "-B6T.: " + B6T->( B6T_SEQLOT + '-' + B6T_SEQGUI )
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-B6T.: " + B6T->( B6T_SEQLOT + '-' + B6T_SEQGUI )
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-B6T-RECNO: " + cValToChar(B6T->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9A1'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-PROV'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-PROV'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-BSQ-AJUS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-BSQ-AJUS-'
		elseIf cSeq == '005'
			cText := 'DEB-'
			cInd  := '-IRRF'
		elseIf cSeq == '006'
			cText := 'CRE-'
			cInd  := '-IRRF'
		elseIf cSeq == '007'
			cText := 'DEB-'
			cInd  := '-COFINS'
		elseIf cSeq == '008'
			cText := 'CRE-'
			cInd  := '-COFINS'
		elseIf cSeq == '009'
			cText := 'DEB-'
			cInd  := '-PIS'
		elseIf cSeq == '010'
			cText := 'CRE-'
			cInd  := '-PIS'
		elseIf cSeq == '011'
			cText := 'DEB-'
			cInd  := '-CSLL'
		elseIf cSeq == '012'
			cText := 'CRE-'
			cInd  := '-CSLL'
		endIf	

		if cTp == 'H'
			cRet := cLp + cInd + "-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-SE1-RECNO: " + cValToChar(SE1->(recno()))
			cRet := left(cRet, 100) 
		endIf
		
	case cLp == '9A2'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-PROV'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-PROV'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-BSQ-AJUS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-BSQ-AJUS-'
		elseIf cSeq == '005'
			cText := 'DEB-'
			cInd  := '-IRRF'
		elseIf cSeq == '006'
			cText := 'CRE-'
			cInd  := '-IRRF'
		endIf	

		if cTp == 'H'
			cRet := cLp + cInd + "-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-SE1-RECNO: " + cValToChar(SE1->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9AX'

		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-REC'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-REC'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '006'
			cText := 'DEB-'
			cInd  := '-DC'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-BAIXA-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-BAIXA-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK1-RECNO: " + cValToChar(FK1->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9B6'
		
		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-REC'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-REC'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '006'
			cText := 'DEB-'
			cInd  := '-DC'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-CANCEL B-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-CANCEL B-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK1-RECNO: " + cValToChar(FK1->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9NX'
		
		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-REC'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-REC'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '006'
			cText := 'DEB-'
			cInd  := '-DC'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-BAIXA-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-BAIXA-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK1-RECNO: " + cValToChar(FK1->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9N6'
		
		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-REC'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-REC'
		elseIf cSeq == '003'
			cText := 'DEB-'
			cInd  := '-ISS'
		elseIf cSeq == '004'
			cText := 'CRE-'
			cInd  := '-ISS'
		elseIf cSeq == '005'
			cText := 'CRE-'
			cInd  := '-MTJR'
		elseIf cSeq == '006'
			cText := 'DEB-'
			cInd  := '-DC'
		endIf

		if cTp == 'H'
			cRet := cLp + cInd + "-CANCEL B-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-CANCEL B-SE1.: " + SE1->( E1_PREFIXO + '-' + E1_NUM + '-' + E1_TIPO)
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-FK1-RECNO: " + cValToChar(FK1->(recno()))
			cRet := left(cRet, 100) 
		endIf

	case cLp == '9LC'
		
		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-APRO'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-APRO'
		endIf	
		if cTp == 'H'
			cRet := cLp + cInd + "-B6S.: " + B6S->( allTrim(B6S_NUMLOT) + '-' + B6S_CODPEG )
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-B6S.: " + B6S->( allTrim(B6S_NUMLOT) + '-' + B6S_CODPEG )
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-B6S-RECNO: " + cValToChar(B6S->(recno()))
			cRet := left(cRet, 100) 
		endIf
		
case cLp == '9LD'
		
		if cSeq == '001'
			cText := 'DEB-'
			cInd  := '-APRO'
		elseIf cSeq == '002'
			cText := 'CRE-'
			cInd  := '-APRO'
		endIf	
		if cTp == 'H'
			cRet := cLp + cInd + "-B6S.: " + B6S->( allTrim(B6S_NUMLOT) + '-' + B6S_CODPEG )
			cRet := left(cRet, 40) 
		elseIf cTp == 'A'
			cRet := cLp + cInd + "-B6S.: " + B6S->( allTrim(B6S_NUMLOT) + '-' + B6S_CODPEG )
			cRet := left(cRet, 40) 
		elseIf cTp == 'O'
			cRet := cText + cLp + "-" + cSeq + "-B6S-RECNO: " + cValToChar(B6S->(recno()))
			cRet := left(cRet, 100) 
		endIf

	endCase

return( cRet )
