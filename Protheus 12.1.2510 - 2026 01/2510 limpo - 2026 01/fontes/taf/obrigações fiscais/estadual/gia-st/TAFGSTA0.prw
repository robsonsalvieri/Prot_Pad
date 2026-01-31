#include 'protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGSTA0
Gera o Anexo Principal da GIA-ST (Anexo 0).

@Param aWizard	->	Array com as informacoes da Wizard
	   aFilial	->	Array com as informacoes da filial corrente

@author Rafael Völtz
@since  06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFGSTA0 (aWizard as array, aFilial as array, cJobAux as char)

Local nHandle      as Numeric
Local oError	   as Object
Local cTxtSys  	   as Char
Local cStrTxt 	   as Char
Local cREG 		   as Char
Local lFound       as logical

Local cIE          as Char
Local cUFFavorec   as Char
Local nValProd     as Numeric
Local nValIpi      as Numeric
Local nDespAcess   as Numeric
Local nBcIcms      as Numeric
Local nVIcms       as Numeric
Local nBcIcmsSt    as Numeric
Local nVIcmsSt     as Numeric
Local nVdevMerc    as Numeric
Local nVRessar     as Numeric
Local nCredPedAnt  as Numeric
Local nPGAnt       as Numeric
Local nIcmsStDev   as Numeric
Local nRpIcmsRet   as Numeric
Local nCrePerSeg   as Numeric
Local nTotSTRec    as Numeric
Local nRepassRet   as Numeric
Local aVenICMSST   as array
Local aICMSComb    as array
Local cInfoCompl   as char
Local aInfoCompl   as Array
Local aContrib     as array
Local nQtdAnxI     as numeric
Local nQtdAnxII    as numeric
Local nQtdAnxIII   as numeric
Local nCont        as numeric
Local nDifalDest   as numeric
Local nDevAnulac   as numeric
Local nPgtAntDIF   as numeric
Local nTotDvDest   as numeric
Local nTtICMSFCP   as numeric
Local aTributos    as array
Local aVenFCP      as array
Local aApurDifal   as array
Local dDatIni      as date
Local dDatFim      as date
Local aApurST      as array
Local aPgtoAnt     as array
Local nX           as numeric
Local nY           as numeric

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
oError	    := ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )
cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
nHandle   	:= MsFCreate( cTxtSys )
cREG 		:= "A0"
cStrTxt 	:= ""
lFound      := .T.
cIE         := ''
nCont       := 0
nX          := 0
nY          := 0
nPGAnt      := 0
nPgtAntDif  := 0
nTotDvDest  := 0
nTtICMSFCP  := 0
aApurDifal  := {0,0}

Begin Sequence

	dDatIni :=  CToD("01/" + SubStr(aWizard[1,3],1,2) + "/"+ cValToChar(aWizard[1,4]))
	dDatFim :=  Lastday(dDatIni)

	cIE 	   := TAFRemCharEsp(TAFGetIE(aWizard, aFilial))
	aInfoCompl := {"","",""}
	aICMSComb  := {0,0}
	aVenICMSST := {}
	aVenFCP    := {}
	aPgtoAnt   := {}	
	aContrib   := TAFContrib(aWizard, aFilial)
	aTributos  := TAFTotTrib(aWizard, aFilial, dDatIni, dDatFim)
	aApurST    := TAFApurST(aWizard,  aFilial, dDatIni, dDatFim)
	aGuiasST   := TAFGuiaST(aWizard,  aFilial, dDatIni, dDatFim)
	
	For nX := 1 To Len(aGuiasST)
		For nY := 1 To Len(aGuiasST[nX])
			IIF(nX == 1, aAdd(aVenICMSST, aGuiasST[nX,nY]), nil) 
			IIF(nX == 2, aAdd(aPgtoAnt,   aGuiasST[nX,nY]), nil)
			IIF(nX == 3, aAdd(aVenFCP,    aGuiasST[nX,nY]), nil)
		Next nY
	Next nX
	
	For nX := 1 To Len(aPgtoAnt)
		nPGAnt += aPgtoAnt[nX,2]
	Next nX
	
	If "1" $ aWizard[2,2]      // Operação com EC - DIFAL
		aApurDifal := TAFApurDif(aWizard, aFilial, dDatIni, dDatFim)
		aGuiaDifal := TAFGuiaDif(aWizard, aFilial, dDatIni, dDatFim)
	
		For nX := 1 To Len(aGuiaDifal)
			For nY := 1 To Len(aGuiaDifal[nX])
				IIF(nX == 1, nTotDvDest += aGuiaDifal[nX,nY,2], nil) 
				IIF(nX == 2, nPgtAntDIF += aGuiaDifal[nX,nY,2], nil)
				IIF(nX == 3, nTtICMSFCP += aGuiaDifal[nX,nY,2], nil)
			Next nY
		Next nX
	EndIf
	
	If "1" $ aWizard[2,3]      // Distribuidor de Combustíveis ou TRR
		aICMSComb := TAFCombust(aWizard, aFilial, dDatIni, dDatFim)
	EndIf
	
	cInfoCompl := aWizard[2,6]

	While Len(Alltrim(cInfoCompl)) != 0	.Or. nCont == 3
		If Len(Alltrim(cInfoCompl)) > 60
			nCont++
			If Len(Alltrim(cInfoCompl)) > 65 .And. nCont == 1
				aInfoCompl[nCont] := substr(cInfoCompl,1,65)
			    cInfoCompl 		  := substr(cInfoCompl,66,len(alltrim(cInfoCompl)))
			Else
				aInfoCompl[nCont] := substr(cInfoCompl,1,Len(Alltrim(cInfoCompl)))
			    cInfoCompl := substr(cInfoCompl,61,len(alltrim(cInfoCompl)))
			EndIf
		Else
		 	nCont++
			aInfoCompl[nCont] := Alltrim(cInfoCompl)
			exit
		EndIf
	EndDo

	nValProd 	:= aTributos[1]
	nValIpi     := aTributos[2]
	nDespAcess  := aTributos[3]
	nBcIcms     := aTributos[4]
	nVIcms      := aTributos[5]
	nBcIcmsSt   := aTributos[6]
	nVIcmsSt    := aTributos[7]
	nVdevMerc   := aApurST[1]
	nVRessar    := aApurST[2]
	nCredPedAnt := aApurST[3]	
	nIcmsStDev  := aApurST[4]
	nRpIcmsRet  := aICMSComb[1]
	nCrePerSeg 	:= aApurST[5]
	nTotSTRec  	:= aApurST[6]
	nRepassRet  := aICMSComb[2]
	nQtdAnxI    := val(GetGlbValue( "nQtdAnxI_"+aFilial[1]))
	nQtdAnxII   := val(GetGlbValue( "nQtdAnxII_"+aFilial[1]))
	nQtdAnxIII  := val(GetGlbValue( "nQtdAnxIII_"+aFilial[1]))
	nDifalDest  := aApurDifal[1]
	nDevAnulac  := aApurDifal[2] - nPgtAntDIF		

	cStrTxt := cREG                  																		//A0 fixo
    cStrTxt += "GST"                 									                                 	//GST fixo
    cStrTxt +=  PADL(Alltrim(aWizard[1,5]),2,"0") 					 	                                 	//Versão do Arquivo
    cStrTxt +=  substr(aWizard[1,3],1,2) + strzero(aWizard[1,4],4) 		                                 	//05 - Mês e Ano de referência
    cStrTxt +=  PADL(cIE,14)											                                 	//06 - Inscrição Estadual - Alinhamento a Esquerda
    cStrTxt +=  IIF("1" $ aWizard[2,1], "S", "N")                   	                                	//01 - Gia sem movimento?
    cStrTxt +=  IIF("1" $ aWizard[1,6], "S", "N")                   	                                 	//02 - Gia substituição?
    cStrTxt +=  IIF(Len(aVenICMSST)>0, aVenICMSST[1,1], Replicate("0",8))								 	//03 - Data 1º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>0, StrTran(StrZero(aVenICMSST[1,2], 16, 2),".",""), Replicate("0",15))  //03 - Valor 1º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>1, aVenICMSST[2,1], Replicate("0",8))								 	//03 - Data 2º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>1, StrTran(StrZero(aVenICMSST[2,2], 16, 2),".",""), Replicate("0",15))  //03 - Valor 2º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>2, aVenICMSST[3,1], Replicate("0",8))								 	//03 - Data 3º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>2, StrTran(StrZero(aVenICMSST[3,2], 16, 2),".",""), Replicate("0",15))  //03 - Valor 3º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>3, aVenICMSST[4,1], Replicate("0",8))								 	//03 - Data 4º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>3, StrTran(StrZero(aVenICMSST[4,2], 16, 2),".",""), Replicate("0",15))  //03 - Valor 4º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>4, aVenICMSST[5,1], Replicate("0",8))								 	//03 - Data 5º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>4, StrTran(StrZero(aVenICMSST[5,2], 16, 2),".",""), Replicate("0",15))  //03 - Valor 5º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>5, aVenICMSST[6,1], Replicate("0",8))								 	//03 - Data 6º Vencimento do ICMS-ST
    cStrTxt +=  IIF(Len(aVenICMSST)>5, StrTran(StrZero(aVenICMSST[6,2], 16, 2),".",""), Replicate("0",15))  //03 - Valor 6º Vencimento do ICMS-ST
    cStrTxt +=  substr(aWizard[1,7],1,2) 								//04 - UF Favorecida
    cStrTxt +=  StrTran(StrZero(nValProd, 16, 2),".","")	    		//07 - Valor dos produtos
    cStrTxt +=  StrTran(StrZero(nValIpi, 16, 2),".","")	    			//08 - Valor do IPI
    cStrTxt +=  StrTran(StrZero(nDespAcess, 16, 2),".","")	    		//09 - Valor da Despesa Acessória
    cStrTxt +=  StrTran(StrZero(nBcIcms, 16, 2),".","")	    			//10 - Base de Cálculo ICMS próprio
    cStrTxt +=  StrTran(StrZero(nVIcms, 16, 2),".","")	    			//11 - ICMS Próprio
    cStrTxt +=  StrTran(StrZero(nBcIcmsSt, 16, 2),".","")	  			//12 - Base de Cálculo ICMS-ST
    cStrTxt +=  StrTran(StrZero(nVIcmsSt, 16, 2),".","")	  			//13 - ICMS Retido por ST
    cStrTxt +=  StrTran(StrZero(nVdevMerc, 16, 2),".","")	  			//14 - ICMS de Devolução de Mercadoria
    cStrTxt +=  StrTran(StrZero(nVRessar, 16, 2),".","")	  			//15 - ICMS de Ressarcimento
    cStrTxt +=  StrTran(StrZero(nCredPedAnt, 16, 2),".","")	  			//16 - Crédito do período anterior
    cStrTxt +=  StrTran(StrZero(nPGAnt, 16, 2),".","")	  				//17 - Pagamento Antecipado
    cStrTxt +=  StrTran(StrZero(nIcmsStDev, 16, 2),".","")	  			//18 - ICMS ST devido
    cStrTxt +=  StrTran(StrZero(nRpIcmsRet, 16, 2),".","")	  			//19 - Repasse - ICMS Retido por Refinarias/Complementos
    cStrTxt +=  StrTran(StrZero(nCrePerSeg, 16, 2),".","")	  			//20 - Crédito para período seguinte
    cStrTxt +=  StrTran(StrZero(nTotSTRec, 16, 2),".","")	  			//21 - Total ICMS ST a Recolher
    cStrTxt +=  PADR(aContrib[1],14)									//28 - CNPJ
    cStrTxt +=  PADR(aContrib[2],46)									//29 - Nome do Declarante
    cStrTxt +=  PADR(aContrib[3],11)									//30 - CPF Declarante
    cStrTxt +=  PADR(aContrib[4],30)									//31 - Cargo do Declarante na Empresa
    cStrTxt +=  Strzero(aContrib[5],04)									//32 - Telefone DDD
    cStrTxt +=  Strzero(aContrib[6],09)									//32 - Telefone Número
    cStrTxt +=  Strzero(aContrib[7],04)									//33 - Telefone DDD
    cStrTxt +=  Strzero(aContrib[8],09)									//33 - Telefone Número
    cStrTxt +=  PADR(aContrib[9],80)									//34 - E-mail do declarante
    cStrTxt +=  PADR(aWizard[3,2],30)									//35 - Local
    cStrTxt +=  Dtos(dDataBase)   										//35 - Data
    cStrTxt +=  PADR(aInfoCompl[1],65)									//36 - Informações Complementares - 1ª Linha
    cStrTxt +=  PADR(aInfoCompl[2],60)									//36 - Informações Complementares - 2ª Linha
    cStrTxt +=  PADR(aInfoCompl[3],60)									//36 - Informações Complementares - 3ª Linha
    cStrTxt +=  IIF("1" $ aWizard[2,3], "S", "N")                   	//37 - Distribuidor de Combustível ou TRR?
    cStrTxt +=  IIF("1" $ aWizard[2,4], "S", "N")                   	//38 - Efetou Transferência para UF favorecida?
    cStrTxt +=  Space(06)  						                 		//Código Entrega Gia - Reservado para uso futuro
    cStrTxt +=  StrZero(nQtdAnxI,06) 				                 	//Qtd total linhas anexo I
    cStrTxt +=  StrZero(nQtdAnxII,06) 				                 	//Qtd total linhas anexo II
    cStrTxt +=  StrZero(nQtdAnxIII,06) 				                	//Qtd total linhas anexo III
    cStrTxt +=  StrTran(StrZero(nRepassRet, 16, 2),".","")	  			//39 - Repasse - ICMS Retido por Outros Contribuintes

    cStrTxt +=  IIF("1" $ aWizard[2,2], "S", "N")                   											//EC N° 87/15 com Movimento (Sim/Não)
    cStrTxt +=  IIF(Len(aVenFCP)>0, StrTran(StrZero(aVenFCP[1,2], 16, 2),".",""), Replicate("0",15))     		//Valor do ICMS-ST FCP Referente ao 1º Vencimento
    cStrTxt +=  IIF(Len(aVenFCP)>1, StrTran(StrZero(aVenFCP[2,2], 16, 2),".",""), Replicate("0",15))	   	 	//Valor do ICMS-ST FCP Referente ao 2º Vencimento
    cStrTxt +=  IIF(Len(aVenFCP)>2, StrTran(StrZero(aVenFCP[3,2], 16, 2),".",""), Replicate("0",15))	    	//Valor do ICMS-ST FCP Referente ao 3º Vencimento
    cStrTxt +=  IIF(Len(aVenFCP)>3, StrTran(StrZero(aVenFCP[4,2], 16, 2),".",""), Replicate("0",15))	    	//Valor do ICMS-ST FCP Referente ao 4º Vencimento
    cStrTxt +=  IIF(Len(aVenFCP)>4, StrTran(StrZero(aVenFCP[5,2], 16, 2),".",""), Replicate("0",15))	    	//Valor do ICMS-ST FCP Referente ao 5º Vencimento
    cStrTxt +=  IIF(Len(aVenFCP)>5, StrTran(StrZero(aVenFCP[6,2], 16, 2),".",""), Replicate("0",15))	    	//Valor do ICMS-ST FCP Referente ao 6º Vencimento
    cStrTxt +=  StrTran(StrZero(nDifalDest, 16, 2),".","")	    												//Valor do ICMS Devido à UF de Destino
    cStrTxt +=  StrTran(StrZero(nDevAnulac, 16, 2),".","")	    												//Devoluções ou Anulações
    cStrTxt +=  StrTran(StrZero(nPgtAntDIF, 16, 2),".","")	    												//Pagamentos Antecipados
    cStrTxt +=  StrTran(StrZero(nTotDvDest, 16, 2),".","")	    												//Total do ICMS Devido à UF de Destino
    cStrTxt +=  StrTran(StrZero(nTtICMSFCP, 16, 2),".","")	    												//Total ICMS FCP

	WrtStrTxt( nHandle, cStrTxt )

	GerTxtGST( nHandle, cTxtSys, aFilial[01] + "_" + cReg )

Recover

	lFound := .F.

End Sequence

//Tratamento para ocorrência de erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

Else
	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetIE
Busca a inscrição estadual da UF de substituição tributária
@Param 	aWizard	->	Array com as informacoes da Wizard
		aFilial	->	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
@Return cIe		-> Inscrição estadual da UF substituta (T001AA)
@author Daniel Maniglia A. Silva
@since  06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFGetIE(aWizard as array, aFilial as array)

Local cIe		as Char
Local cSelect	as Char
Local cFrom		as Char
Local cWhere	as Char
Local cAliasIe	as Char

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cIe 		:= ""
cSelect		:= ""
cFrom		:= ""
cWhere		:= ""
cAliasIe	:= GetNextAlias()

//*****************************
// *** Busca IE ***
//*****************************

	cSelect      := "  C1F.C1F_iest "
	cFrom        := RetSqlName("C1F") + " C1F, "
	cFrom        += RetSqlName("C1E") + " C1E, "
	cFrom        += RetSqlName("C09") + " C09 "
	cWhere       := " 		C1E.C1E_FILIAL = '" + xFilial("C1E") + "' "
	cWhere       += " AND   C1E.C1E_ID     = C1F.C1F_ID "
	cWhere       += " AND 	C1F.C1F_FILIAL = '" + xFilial("C1F") + "' "
	cWhere       += " AND 	C09.C09_FILIAL = '" + xFilial("C09") + "' "
	cWhere       += " AND 	C09.C09_ID     = C1F.C1F_UFST "
	cWhere       += " AND 	C09.C09_UF     = '" + Substr(aWizard[1][7],1,2) + "' "
	cWhere       += " AND 	C1E.D_E_L_E_T_ = '' "
	cWhere       += " AND   C1F.D_E_L_E_T_ = '' "
	cWhere       += " AND	C09.D_E_L_E_T_ = '' "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"

	BeginSql Alias cAliasIE

	       SELECT
	             %Exp:cSelect%
	       FROM
	             %Exp:cFrom%
	       WHERE
	             %Exp:cWhere%
	EndSql

	DbSelectArea(cAliasIE)
	(cAliasIE)->(DbGoTop())


	While (cAliasIE)->(!EOF())
		cIe	:= 	(cAliasIE)->C1F_IEST
		EXIT
	EndDo
	(cAliasIE)->(DbCloseArea())

Return(cIe)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFContrib
Busca os dados do contribuinte para geração do Anexo 0 da GIA-ST
@Param 	aWizard	->	Array com as informacoes da Wizard
		aFilial	->	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
@Return aContrib -> Array com as informações do contribuinte
@author Daniel Maniglia A. Silva
@since  06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFContrib(aWizard as array, aFilial as array)

local aContrib  as array
Local cSelect	as Char
Local cFrom		as Char
Local cWhere	as Char
Local cAliasC	as Char


//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************

cSelect		:= ""
cFrom		:= ""
cWhere		:= ""
cAliasC		:= GetNextAlias()
aContrib	:= {}

//*********************************
// *** Busca dados contribuinte ***
//*********************************

	cSelect      := "  C2J.C2J_Nome, C2J.C2J_CPF, C2J.C2J_DDD, C2J.C2J_FONE, C2J.C2J_DDDFAX, C2J.C2J_FAX, C2J.C2J_EMAIL, C2J.C2J_IDCODQ "
	cFrom        := RetSqlName("C2J") + " C2J "	
	cWhere       += "     C2J.C2J_ID	 = '" + aWizard[3][1] + "' "
	cWhere       += " AND C2J.D_E_L_E_T_ = '' "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"

	BeginSql Alias cAliasC

	       SELECT
	             %Exp:cSelect%
	       FROM
	             %Exp:cFrom%
	       WHERE
	             %Exp:cWhere%
	EndSql

	DbSelectArea(cAliasC)
	(cAliasC)->(DbGoTop())

	While (cAliasC)->(!EOF())
		aAdd(aContrib,aFilial[9])
		aAdd(aContrib,TAFRemCharEsp((cAliasC)->C2J_NOME))						//29 - Nome do Declarante
	    aAdd(aContrib,TAFRemCharEsp((cAliasC)->C2J_CPF))						//30 - CPF Declarante
	    aAdd(aContrib,TAFBuscaCargo((cAliasC)->C2J_IDCODQ))	   					//31 - Cargo do Declarante na Empresa
	    aAdd(aContrib,val(TAFRemCharEsp((cAliasC)->C2J_DDD)))					//32 - Telefone DDD
	    aAdd(aContrib,val(TAFRemCharEsp((cAliasC)->C2J_FONE)))					//32 - Telefone Número
	    aAdd(aContrib,val(TAFRemCharEsp((cAliasC)->C2J_DDDFAX)))				//33 - FAX DDD
	    aAdd(aContrib,val(TAFRemCharEsp((cAliasC)->C2J_FAX)))					//33 - FAX Número
	    aAdd(aContrib,(cAliasC)->C2J_EMAIL)										//34 - E-mail do declarante
		EXIT
	EndDo
	(cAliasC)->(DbCloseArea())

	If Len(aContrib) == 0
		aAdd(aContrib,"")
		aAdd(aContrib,"")						//29 - Nome do Declarante
	    aAdd(aContrib,"")						//30 - CPF Declarante
	    aAdd(aContrib,"")	    				//31 - Cargo do Declarante na Empresa
	    aAdd(aContrib,0)						//32 - Telefone DDD
	    aAdd(aContrib,0)						//32 - Telefone Número
	    aAdd(aContrib,0)						//33 - FAX DDD
	    aAdd(aContrib,0)						//33 - FAX Número
	    aAdd(aContrib,"")						//34 - E-mail do declarante
	EndIf

Return(aContrib)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFBuscaCargo
Busca os dados do contribuinte para geração do Anexo 0 da GIA-ST
@Param 	cIdCargo ->	ID do cargo do comtabilista
@Return cCargo   -> Descrição do cargo do contabilista
@author Daniel Maniglia A. Silva
@since  06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFBuscaCargo(cIdCargo as char)

Local cCargo	as Char


//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************

cCargo		:= ""

dbSelectArea("CW4")
CW4->(dbSetOrder(1))
If dbSeek(xFilial("CW4") + cIdCargo)
	cCargo:= CW4->CW4_DESCRI
Endif

Return(cCargo)

//------------------------------------------------------------
/*/{Protheus.doc} TAFTotTrib
 Buscar informações de ICMS, ICMS ST e dos itens dos documentos
 que tiveram a incidência do ICMS ST

@Param 	aFilial >	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
		dIni    > 	Data inicial do período de processamento
		dFim    > 	Data inicial do período de processamento
@Return aRet    > 	Array com as informações totais de ICMS, ICMS ST
					valor do produto e despesa acessória do período
@author Rafael Völtz
@since  08/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Static Function TAFTotTrib(aWizard as array, aFilial as array, dIni as date, dFim as date)

Local cAliasST   as char
Local cAliasTrib as char
Local cSelect	 as Char
Local cFrom		 as Char
Local cWhere	 as Char
Local cAliasC	 as Char
Local nTotProd   as numeric
Local nDespAcess as numeric
Local nBaseICMS  as numeric
Local nVlICMS    as numeric
Local nBaseST    as numeric
Local nVlST      as numeric
Local nVlIPI     as numeric
Local aRet       as array
Local nAliqZFM   as numeric

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************

	cSelect		:= ""
	cFrom		:= ""
	cWhere		:= ""
	cAliasST    := GetNextAlias()
	cAliasTrib  := GetNextAlias()
	nTotProd    := 0
	nBaseICMS   := 0
	nVlICMS     := 0
	nBaseST     := 0
	nVlST       := 0
	nVlIPI      := 0
	nDespAcess  := 0
	nAliqZFM    := 0.07
	aRet        := {}
	
	cSelect      := " C35.C35_CHVNF  C35_CHVNF,  "
	cSelect      += " C35.C35_NUMITE C35_NUMITE, "
	cSelect      += " C35.C35_CODITE C35_CODITE, "
	cSelect      += " C30.C30_TOTAL  C30_TOTAL,  "
	cSelect      += " C30.C30_VLRDA  C30_VLRDA, "
	cSelect      += " C1H.C1H_SUFRAM C1H_SUFRAM  "	
	cFrom        := RetSqlName("C20") + " C20 "
	cFrom        += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_FILIAL =  '" + xFilial("C1H") + "' AND C20.C20_CODPAR = C1H.C1H_ID  "
	cFrom        += " INNER JOIN " + RetSqlName("C30") + " C30 ON C20.C20_FILIAL = C30.C30_FILIAL AND C20.C20_CHVNF = C30.C30_CHVNF  "
	cFrom        += " INNER JOIN " + RetSqlName("C35") + " C35 ON C20.C20_FILIAL = C35.C35_FILIAL AND C20.C20_CHVNF = C35.C35_CHVNF AND C30.C30_NUMITE = C35.C35_NUMITE "
	cFrom        += " INNER JOIN " + RetSqlName("C02") + " C02 ON C02.C02_FILIAL =  '" + xFilial("C02") + "' AND C20.C20_CODSIT = C02.C02_ID  "
	cFrom        += " INNER JOIN " + RetSqlName("C3S") + " C3S ON C3S.C3S_FILIAL =  '" + xFilial("C3S") + "' AND C35.C35_CODTRI = C3S.C3S_ID   "
	cFrom        += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL =  '" + xFilial("C09") + "' AND C1H.C1H_UF =  C09.C09_ID  "
	cWhere       := " 	  C20.C20_FILIAL = '" + xFilial("C20") + "' "
	cWhere       += " AND C20.C20_DTDOC  BETWEEN '" + DToS(dIni) + "' AND '" + DToS(dFim) + "'"
	cWhere       += " AND C20.C20_INDOPE = '1' "
	cWhere       += " AND C02.C02_CODIGO NOT IN ('02', '03', '04','05') "
	cWhere       += " AND C3S.C3S_CODIGO = '04' " //ICMS ST
	cWhere       += " AND C09.C09_UF = '" + Substr(aWizard[1][7],1,2) + "' "
	cWhere       += " AND C20.D_E_L_E_T_ = '' "
	cWhere       += " AND C1H.D_E_L_E_T_ = '' "
	cWhere       += " AND C30.D_E_L_E_T_ = '' "
	cWhere       += " AND C35.D_E_L_E_T_ = '' "
	cWhere       += " AND C02.D_E_L_E_T_ = '' "
	cWhere       += " AND C3S.D_E_L_E_T_ = '' "
	cWhere       += " AND C09.D_E_L_E_T_ = '' "

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"

	BeginSql Alias cAliasST

	       SELECT
	             %Exp:cSelect%
	       FROM
	             %Exp:cFrom%
	       WHERE
	             %Exp:cWhere%
	EndSql

	DbSelectArea(cAliasST)
	(cAliasST)->(DbGoTop())

	While (cAliasST)->(!EOF())	   	   		
	   		
	   BeginSql Alias cAliasTrib
	       SELECT SUM(CASE WHEN C3S.C3S_CODIGO = '02' THEN C35.C35_BASE END) BASE_ICMS ,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '02' THEN C35.C35_VALOR END) VALOR_ICMS,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '04' THEN C35.C35_BASE END) BASE_ST ,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '04' THEN C35.C35_VALOR END) VALOR_ST,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '05' THEN C35.C35_VALOR END) VALOR_IPI
	       FROM %table:C35% C35
	            INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID
	       WHERE C35.C35_FILIAL = %Exp:aFilial[1]%
	         AND C35.C35_CHVNF  = %Exp:(cAliasST)->C35_CHVNF%
	         AND C35.C35_NUMITE = %Exp:(cAliasST)->C35_NUMITE%
	         AND C35.C35_CODITE = %Exp:(cAliasST)->C35_CODITE%
	         AND C35.C35_VALOR  > 0
	         AND C3S.C3S_CODIGO IN (%Exp:'02'%,%Exp:'04'%,%Exp:'05'%)
	         AND C35.%notDel%
	         AND C3S.%notDel% 
	   EndSql	       

	   //Quando Zona Franca de Manaus adotar regra (AJUSTE SINIEF 04/93):
	   //VII - campo 7 - Valor dos Produtos: informar o valor total dos produtos sujeitos à substituição tributária. 
	   //				 Quando destinados à Zona Franca de Manaus e Áreas de Livre Comércio, informar como se devido fosse o ICMS;
	   //X   - campo 10- Base de Cálculo do ICMS Próprio: informar o valor que serviu de base para o cálculo do ICMS próprio. 
	   //				 Quando destinados à Zona Franca de Manaus e Áreas de Livre Comércio, informar o valor da base de cálculo do crédito presumido;
	   //XI  - campo 11- ICMS próprio: informar o valor total do ICMS próprio. 
	   //				 Quando destinados à Zona Franca de Manaus e Áreas de Livre Comércio, informar o valor do crédito presumido;
	   If(Substr(aWizard[1][7],1,2) == "AM" .And. !Empty(Alltrim((cAliasST)->C1H_SUFRAM))) 	   
	   	   nTotProd   += (cAliasST)->C30_TOTAL 
		   nDespAcess += (cAliasST)->C30_VLRDA
		   nBaseICMS  += nTotProd
		   nVlICMS    += nTotProd * nAliqZFM    			 
		   nBaseST    += (cAliasTrib)->BASE_ST
		   nVlST      += (cAliasTrib)->VALOR_ST
		   nVlIPI     += (cAliasTrib)->VALOR_IPI
	   Else
		   nTotProd   += (cAliasST)->C30_TOTAL
		   nDespAcess += (cAliasST)->C30_VLRDA
		   nBaseICMS  += (cAliasTrib)->BASE_ICMS
		   nVlICMS    += (cAliasTrib)->VALOR_ICMS
		   nBaseST    += (cAliasTrib)->BASE_ST
		   nVlST      += (cAliasTrib)->VALOR_ST
		   nVlIPI     += (cAliasTrib)->VALOR_IPI
	   EndIf

	   (cAliasTrib)->(DbCloseArea())
	   (cAliasST)->(DbSkip())

	EndDo
	(cAliasST)->(DbCloseArea())
	
	aAdd(aRet,nTotProd)
	aAdd(aRet,nVlIPI)
	aAdd(aRet,nDespAcess)
	aAdd(aRet,nBaseICMS)
	aAdd(aRet,nVlICMS)
	aAdd(aRet,nBaseST)
	aAdd(aRet,nVlST)		

Return aRet


//------------------------------------------------------------
/*/{Protheus.doc} TAFApurST
 Buscar informações da apuração de ICMS ST

@Param 	aWizard->	Informações da Tela - Wizard
		aFilial >	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
		dIni    > 	Data inicial do período de processamento
		dFim    > 	Data inicial do período de processamento
@Return aRet    > 	Array com as informações da apuração do ICMS ST
@author Rafael Völtz
@since  12/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Static Function TAFApurST(aWizard as array, aFilial as array, dIni as date, dFim as date)

 Local cAliasA    as char
 Local aRet       as array
 Local nCreAnt    as numeric
 Local nVlrDev    as numeric
 Local nVlrRes    as numeric
 Local nSldDev    as numeric
 Local nVlrRec    as numeric
 Local nCrdTra    as numeric
 Local cUFFavorec as char

 cAliasA := GetNextAlias()
 cUFFavorec := Substr(aWizard[1][7],1,2) 
 aRet    := {}
 nCreAnt := 0
 nVlrDev := 0
 nVlrRes := 0
 nSldDev := 0
 nVlrRec := 0
 nCrdTra := 0

 BeginSql Alias cAliasA

   SELECT C3J.C3J_CREANT C3J_CREANT,
          C3J.C3J_VLRDEV C3J_VLRDEV,
          C3J.C3J_VLRRES C3J_VLRRES,
          C3J.C3J_SDODEV C3J_SDODEV,
          C3J.C3J_VLRREC C3J_VLRREC,
          C3J.C3J_CRDTRA C3J_CRDTRA
     FROM %table:C3J% C3J
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09% AND C3J.C3J_UF = C09.C09_ID
     WHERE C3J.C3J_FILIAL = %Exp:aFilial[1]%
       AND C3J.C3J_DTINI  >= %Exp:DTOS(dIni)%
       AND C3J.C3J_DTFIN  <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND C3J.%NotDel%
       AND C09.%NotDel%

 EndSql

 While !(cAliasA)->(Eof())
 	 nVlrDev += (cAliasA)->C3J_VLRDEV
     nVlrRes += (cAliasA)->C3J_VLRRES
     nCreAnt += (cAliasA)->C3J_CREANT
 	 nSldDev += (cAliasA)->C3J_SDODEV
     nCrdTra += (cAliasA)->C3J_CRDTRA
     nVlrRec += (cAliasA)->C3J_VLRREC

     (cAliasA)->(DbSkip())
 EndDo

 (cAliasA)->(DbCloseArea())

 aAdd(aRet,nVlrDev)
 aAdd(aRet,nVlrRes)
 aAdd(aRet,nCreAnt)
 aAdd(aRet,nSldDev)
 aAdd(aRet,nCrdTra)
 aAdd(aRet,nVlrRec)

Return aRet


//------------------------------------------------------------
/*/{Protheus.doc} TAFApurDif
 Buscar informações da apuração do ICMS Difal

@Param 	aWizard->	Informações da Tela - Wizard
		aFilial >	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
		dIni    > 	Data inicial do período de processamento
		dFim    > 	Data inicial do período de processamento
@Return aRet    > 	Array com as informações da apuração do ICMS ST
@author Rafael Völtz
@since  12/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Static Function TAFApurDif(aWizard as array, aFilial as array, dIni as date, dFim as date)

 Local cAliasD    as char
 Local aRet       as array
 Local nTotDebDif as numeric
 Local nTotCreDif as numeric 
 Local cUFFavorec as char

 cAliasD 	:= GetNextAlias()
 cUFFavorec := Substr(aWizard[1][7],1,2)
 aRet    	:= {}
 nTotDebDif := 0
 nTotCreDif := 0
 
 BeginSql Alias cAliasD

   SELECT LEF_TOTDEB,
          LEF_TOTCDI
     FROM %table:LEF% LEF              
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09% AND LEF.LEF_UF = C09.C09_ID
     WHERE LEF.LEF_FILIAL = %Exp:aFilial[1]%
       AND LEF.LEF_DTINI  >= %Exp:DTOS(dIni)%
       AND LEF.LEF_DTFIN  <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND LEF.%NotDel%
       AND C09.%NotDel%

 EndSql

 While !(cAliasD)->(Eof())
 	 nTotDebDif += (cAliasD)->LEF_TOTDEB
     nTotCreDif += (cAliasD)->LEF_TOTCDI
     
     (cAliasD)->(DbSkip())
 EndDo

 (cAliasD)->(DbCloseArea())

 aAdd(aRet,nTotDebDif)
 aAdd(aRet,nTotCreDif) 

Return aRet

//------------------------------------------------------------
/*/{Protheus.doc} TAFGuiaDif
 Buscar informações das Guias referente ao DIFAL e FCP

@Param 	aWizard->	Informações da Tela - Wizard
		aFilial >	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
		dIni    > 	Data inicial do período de processamento
		dFim    > 	Data inicial do período de processamento
@Return aRet    > 	Array com as informações da apuração do ICMS ST
@author Rafael Völtz
@since  27/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Function TAFGuiaDif(aWizard as array, aFilial as array, dIni as date, dFim as date)

 Local cAliasG    as char
 Local aRet       as array
 Local aApuraDIF  as array
 Local aAntecDIF  as array
 Local aFCP		  as array 
 Local cUFFavorec as char

 cAliasG 	:= GetNextAlias()
 cUFFavorec := Substr(aWizard[1][7],1,2)
 aRet    	:= {} 
 aApuraDIF	:= {}
 aAntecDIF  := {}
 aFCP		:= {}
 
 BeginSql Alias cAliasG

   SELECT "Apuracao DIFAL" TIPO_GUIA,
   		  C0R_DTVCT, 
   		  C0R_VLDA          
     FROM %table:LEF% LEF 
       INNER JOIN %table:LEI% LEI ON LEI.LEI_FILIAL = LEF.LEF_FILIAL AND LEI.LEI_ID = LEF.LEF_ID
       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = LEI.LEI_FILIAL AND C0R.C0R_ID = LEI.LEI_DOCARR
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND LEF.LEF_UF = C09.C09_ID
     WHERE LEF.LEF_FILIAL = %Exp:aFilial[1]%
       AND LEF.LEF_DTINI >= %Exp:DTOS(dIni)%
       AND LEF.LEF_DTFIN <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND C0R.C0R_TPIMPO = %Exp:"05"%  //DIFAL
       AND C0R.C0R_TPREC  = %Exp:"1"%  //Apuração       
       AND LEF.%NotDel%
       AND LEI.%NotDel%
       AND C0R.%NotDel%
   
   UNION
   
   SELECT "Antecipado DIFAL" TIPO_GUIA,
   		  C0R_DTVCT, 
   		  C0R_VLDA          
     FROM %table:LEF% LEF 
       INNER JOIN %table:LEI% LEI ON LEI.LEI_FILIAL = LEF.LEF_FILIAL AND LEI.LEI_ID = LEF.LEF_ID
       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = LEI.LEI_FILIAL AND C0R.C0R_ID = LEI.LEI_DOCARR
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND LEF.LEF_UF = C09.C09_ID
     WHERE LEF.LEF_FILIAL = %Exp:aFilial[1]%
       AND LEF.LEF_DTINI >= %Exp:DTOS(dIni)%
       AND LEF.LEF_DTFIN <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND C0R.C0R_TPIMPO = %Exp:"05"%  //DIFAL
       AND C0R.C0R_TPREC  = %Exp:"3"%  //Antecipado       
       AND LEF.%NotDel%
       AND LEI.%NotDel%
       AND C0R.%NotDel%
     
   UNION
   
   SELECT "ICMS FCP" TIPO_GUIA,
   		  C0R_DTVCT, 
   		  C0R_VLDA          
     FROM %table:LEF% LEF 
       INNER JOIN %table:LEI% LEI ON LEI.LEI_FILIAL = LEF.LEF_FILIAL AND LEI.LEI_ID = LEF.LEF_ID
       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = LEI.LEI_FILIAL AND C0R.C0R_ID = LEI.LEI_DOCARR
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND LEF.LEF_UF = C09.C09_ID
     WHERE LEF.LEF_FILIAL = %Exp:aFilial[1]%
       AND LEF.LEF_DTINI >= %Exp:DTOS(dIni)%
       AND LEF.LEF_DTFIN <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND C0R.C0R_TPIMPO = %Exp:"03"%  //FCP
       AND C0R.C0R_TPREC  = %Exp:"1"%  //Apuração       
       AND LEF.%NotDel%
       AND LEI.%NotDel%
       AND C0R.%NotDel%
       ORDER BY 2
 EndSql

 While !(cAliasG)->(Eof())
     
     IF Alltrim((cAliasG)->TIPO_GUIA) == "Apuracao DIFAL"
	    aAdd(aApuraDIF, {(cAliasG)->C0R_DTVCT, (cAliasG)->C0R_VLDA})
	 ElseIf Alltrim((cAliasG)->TIPO_GUIA) == "Antecipado DIFAL"
	 	aAdd(aAntecDIF, {(cAliasG)->C0R_DTVCT, (cAliasG)->C0R_VLDA})
	 ElseIf Alltrim((cAliasG)->TIPO_GUIA) == "ICMS FCP"
	 	aAdd(aFCP, {(cAliasG)->C0R_DTVCT, (cAliasG)->C0R_VLDA})
	 EndIf
     (cAliasG)->(DbSkip())
     
 EndDo

 (cAliasG)->(DbCloseArea())
 
  aAdd(aRet, aApuraDIF)
  aAdd(aRet, aAntecDIF)
  aAdd(aRet, aFCP)

Return aRet


//------------------------------------------------------------
/*/{Protheus.doc} TAFGuiaST
 Buscar informações das Guias de ICMS-ST

@Param 	aWizard->	Informações da Tela - Wizard
		aFilial >	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
		dIni    > 	Data inicial do período de processamento
		dFim    > 	Data inicial do período de processamento
@Return aRet    > 	Array com as informações da apuração do ICMS ST
@author Rafael Völtz
@since  12/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Static Function TAFGuiaST(aWizard as array, aFilial as array, dIni as date, dFim as date)

 Local cAliasG    as char
 Local aRet       as array
 Local aApura     as array
 Local aAntecip   as array
 Local aSTFCP     as array 
 Local cUFFavorec as char

 cAliasG 	:= GetNextAlias()
 cUFFavorec := Substr(aWizard[1][7],1,2)
 aRet    	:= {} 
 aApura    	:= {}
 aAntecip   := {}
 aSTFCP		:= {}
 
 BeginSql Alias cAliasG

   SELECT "Apuracao" TIPO_GUIA,
   		  C0R_DTVCT, 
   		  C0R_VLDA          
     FROM %table:C3J% C3J 
       INNER JOIN %table:C3N% C3N ON C3N.C3N_FILIAL = C3J.C3J_FILIAL AND C3N.C3N_ID = C3J.C3J_ID
       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C3N.C3N_FILIAL AND C0R.C0R_ID = C3N.C3N_DOCARR
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C3J.C3J_UF = C09.C09_ID
     WHERE C3J.C3J_FILIAL = %Exp:aFilial[1]%
       AND C3J.C3J_DTINI >= %Exp:DTOS(dIni)%
       AND C3J.C3J_DTFIN <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND C0R.C0R_TPIMPO = %Exp:"02"%  //ICMS - ST
       AND C0R.C0R_TPREC  = %Exp:"1"%  //Apuração       
       AND C3J.%NotDel%
       AND C3N.%NotDel%
       AND C0R.%NotDel%
   
   UNION
   
   SELECT "Antecipado" TIPO_GUIA,
   		  C0R_DTVCT, 
   		  C0R_VLDA          
     FROM %table:C3J% C3J 
       INNER JOIN %table:C3N% C3N ON C3N.C3N_FILIAL = C3J.C3J_FILIAL AND C3N.C3N_ID = C3J.C3J_ID
       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C3N.C3N_FILIAL AND C0R.C0R_ID = C3N.C3N_DOCARR
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C3J.C3J_UF = C09.C09_ID
     WHERE C3J.C3J_FILIAL = %Exp:aFilial[1]%
       AND C3J.C3J_DTINI >= %Exp:DTOS(dIni)%
       AND C3J.C3J_DTFIN <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND C0R.C0R_TPIMPO = %Exp:"02"%  //ICMS - ST
       AND C0R.C0R_TPREC  = %Exp:"3"%  //Antecipado
       AND C3J.%NotDel%
       AND C3N.%NotDel%
       AND C0R.%NotDel%
     
   UNION
   
   SELECT "ICMS-ST FCP" TIPO_GUIA,
   		  C0R_DTVCT, 
   		  C0R_VLDA          
     FROM %table:C3J% C3J 
       INNER JOIN %table:C3N% C3N ON C3N.C3N_FILIAL = C3J.C3J_FILIAL AND C3N.C3N_ID = C3J.C3J_ID
       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C3N.C3N_FILIAL AND C0R.C0R_ID = C3N.C3N_DOCARR
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C3J.C3J_UF = C09.C09_ID
     WHERE C3J.C3J_FILIAL = %Exp:aFilial[1]%
       AND C3J.C3J_DTINI >= %Exp:DTOS(dIni)%
       AND C3J.C3J_DTFIN <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%   
       AND C0R.C0R_TPIMPO = %Exp:"04"%  //ICMS - ST FCP
       AND C0R.C0R_TPREC  = %Exp:"1"%  //Antecipado       
       AND C3J.%NotDel%
       AND C3N.%NotDel%
       AND C0R.%NotDel%       
     ORDER BY 2   

 EndSql

 While !(cAliasG)->(Eof())
     
     IF Alltrim((cAliasG)->TIPO_GUIA) == "Apuracao"
	    aAdd(aApura, {(cAliasG)->C0R_DTVCT, (cAliasG)->C0R_VLDA})
	 ElseIf Alltrim((cAliasG)->TIPO_GUIA) == "Antecipado"
	 	aAdd(aAntecip, {(cAliasG)->C0R_DTVCT, (cAliasG)->C0R_VLDA})
	 ElseIf Alltrim((cAliasG)->TIPO_GUIA) == "ICMS-ST FCP"
	 	aAdd(aSTFCP, {(cAliasG)->C0R_DTVCT, (cAliasG)->C0R_VLDA})
	 EndIf
     (cAliasG)->(DbSkip())
     
 EndDo

 (cAliasG)->(DbCloseArea())
 
  aAdd(aRet, aApura)
  aAdd(aRet, aAntecip)
  aAdd(aRet, aSTFCP)

Return aRet
//------------------------------------------------------------
/*/{Protheus.doc} TAFCombust
 Buscar informações das Guias referente ao DIFAL e FCP

@Param 	aWizard->	Informações da Tela - Wizard
		aFilial >	Array com as informacoes das filiais escolhidas
		            na tela da wizard da obrigação
		dIni    > 	Data inicial do período de processamento
		dFim    > 	Data inicial do período de processamento
@Return aRet    > 	Array com as informações da apuração do ICMS ST
@author Rafael Völtz
@since  27/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Function TAFCombust(aWizard as array, aFilial as array, dIni as date, dFim as date)

 Local cAliasC    as char
 Local aRet       as array
 Local cUFFavorec as char
 Local nICMSrefin as numeric
 Local nICMSoutr  as numeric

 cAliasC 	:= GetNextAlias()
 cUFFavorec := Substr(aWizard[1][7],1,2)
 aRet    	:= {}
 nICMSrefin := 0
 nICMSoutr 	:= 0
 
 BeginSql Alias cAliasC

   SELECT T54_CHAVE,
          T57_VLCHAV        
     FROM %table:T56% T56 
       INNER JOIN %table:T57% T57 ON T57.T57_FILIAL = T56.T56_FILIAL AND T57.T57_ID = T56.T56_ID
       INNER JOIN %table:T54% T54 ON T54.T54_FILIAL = %xfilial:T54%  AND T54.T54_ID = T57.T57_IDCHAV
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID = T56.T56_IDUF
     WHERE T56.T56_FILIAL = %Exp:aFilial[1]%
       AND T56.T56_DTINI >= %Exp:DTOS(dIni)%
       AND T56.T56_DTFIN <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:cUFFavorec%
       AND T54.T54_CHAVE IN ( %Exp:"VLR_REPASSE_ICMS_COMB"%,  %Exp:"VLR_REPASSE_ICMS_COMB_OUTROS"%)
       AND T56.%NotDel%
       AND T57.%NotDel%
       AND C09.%NotDel%  
 
 EndSql

 While !(cAliasC)->(Eof())
     
     IF Alltrim((cAliasC)->T54_CHAVE) == "VLR_REPASSE_ICMS_COMB"     	
     	nICMSrefin += Val((cAliasC)->T57_VLCHAV)	    
	 Else
	 	nICMSoutr  += Val((cAliasC)->T57_VLCHAV)
	 EndIf
     (cAliasC)->(DbSkip())     
 EndDo
 

 (cAliasC)->(DbCloseArea())
 
  aAdd(aRet, nICMSrefin)
  aAdd(aRet, nICMSoutr)  

Return aRet
