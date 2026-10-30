#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"
#INCLUDE "PLSDATIVIN.CH"

#DEFINE APLCONTR	1	// Número do Contrato
#DEFINE APLBANCO	2	// Número do Banco
#DEFINE APLAGENC	3	// Número da Agência
#DEFINE APLCOTVR	4	// Valor da Cota Contrato
#DEFINE APLSALDO	5	// Saldo do Contrato
#DEFINE APLVCDIA	6	// Valor da Cota em determinada data
#DEFINE APLCONTA	7	// Número da Conta 

#DEFINE POS_VLR_ORIGINAL	    1
#DEFINE POS_AMPLIACAO           2
#DEFINE POS_CORREC_BEM          6
#DEFINE POS_BAIXAS              8
#DEFINE POS_DEPR_FISCAL         3
                               
/*/{Protheus.doc} PLSDATIVIN
Diops Ativos Garantidores
Alteração para contemplar migração para a Central de Obrigações - Roger C - 23/02/18

@author Karine Riquena Limp
@since 24/02/2017
@version 12

/*/
Function PLSDATIVIN()
LOCAL aReg := {} 	

	/*	Parâmetros:
		MV_PAR01: Data de referência
		MV_PAR02: Cod Conf Livro	
		MV_PAR03: Tipo de ativo: 1=Investimento; 2=Imóvel
	*/
	If Pergunte("PLSDATIVIN", .T.)
		
		//Faz busca dos registros
		if MV_PAR03 == 1
			processa({|| aReg := PLSATGARIN(MV_PAR01,.T.,MV_PAR02)}, STR0001/*"Aguarde"*/, STR0002 /*"Gerando dados..."*/, .t.)
		else
			processa({|| aReg := PLSATGARIM(MV_PAR01,.T.,MV_PAR02)}, STR0001/*"Aguarde"*/, STR0002 /*"Gerando dados..."*/, .t.)
		endIf
		
		If aReg[1]
			//Monta esquema CSV
			aReg := AtGToArray(aReg[2], MV_PAR03)
			If Len(aReg) > 0
				PLSCSVATVIN(aReg, MV_PAR03)
			EndIf	
			
		Else
			msgAlert(STR0003)/*"Não foram encontrados registros para gerar o quadro DIOPS de Ativos Garantidores"*/
		EndIf	
			
	EndIf
	
Return

/*/{Protheus.doc} PLSATGARIN
Query Ativos Garantidores - Investimentos
Alteração para contemplar migração para a Central de Obrigações - Roger C - 23/02/18

@author Karine Riquena Limp
@since 24/02/2017
@version 12

/*/
Function PLSATGARIN(dDtRef, lMsg, cCodLivro, lMigPls)

Local aRet := {} 
Local cQuery := "" 
Local cAplCotas   := GetMv("MV_APLCAL4")
Local aAplic := {}
Local aCalculo := {}
Local aInvestimentos := {}
Local nValLiq := 0
Local cTpCust := ""
Local cVincAns := ""
Local nQuotas := 0
Local cATINV	:= GetNextAlias()
Local nRecTr1	:= 0

Default dDtRef	:= dDataBase
Default lMsg	:= .T.
Default cCodLivro	:= ''
Default lMigPls		:= .F.		// Identifica se a migração é do PLS para a Central 

cQuery += " SELECT "
cQuery += " SEH.R_E_C_N_O_ AS SEH_RECNO "
cQuery += " FROM " + RetSqlName("CTN") + " CTN "
cQuery += " INNER JOIN " + RetSqlName("CTS") + " CTS "
cQuery += " ON(CTN_PLAGER = CTS_CODPLA) "
cQuery += " INNER JOIN " + RetSqlName("CT2") + " CT2 "
cQuery += " ON(CT2_DEBITO >= CTS_CT1INI AND CT2_DEBITO <= CTS_CT1FIM) "
cQuery += " INNER JOIN " + RetSqlName("CV3") + " CV3 "
cQuery += " ON(CV3_RECDES = CAST(CT2.R_E_C_N_O_ AS CHAR(17))) "
cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 "
cQuery += " ON(CV3_TABORI = 'SE5' AND CV3_RECORI = CAST(SE5.R_E_C_N_O_ AS CHAR(17))) "
cQuery += " INNER JOIN " + RetSqlName("SEH") + " SEH "
cQuery += " ON(E5_DOCUMEN = (EH_NUMERO || EH_REVISAO)) "
cQuery += " WHERE "
cQuery += " CTN.CTN_FILIAL = '" + xFilial("CTN") + "' "
cQuery += " AND CTN_CODIGO = '" + cCodLivro + "' "
cQuery += " AND CTN.D_E_L_E_T_ = ' ' "
cQuery += " AND CTS.CTS_FILIAL = '" + xFilial("CTS") + "' "
cQuery += " AND CT2.CT2_DATA <= '" + DtoS(dDtRef) + "' "
cQuery += " AND CT2.D_E_L_E_T_ = ' ' "
cQuery += " AND CT2.CT2_FILIAL = '" + xFilial("CT2") + "' "
cQuery += " AND CT2.D_E_L_E_T_ = ' ' "
cQuery += " AND CV3.CV3_FILIAL = '" + xFilial("CV3") + "' "
cQuery += " AND CV3.D_E_L_E_T_ = ' ' "
cQuery += " AND SE5.E5_FILIAL = '" + xFilial("SE5") + "' "
cQuery += " AND SE5.D_E_L_E_T_ =  ' ' "
cQuery += " AND SEH.EH_FILIAL = '" + xFilial("SEH") + "' "
cQuery += " AND SEH.EH_DATA <= '" + DtoS(dDtRef) + "' "
cQuery += " AND SEH.EH_DATVENC >= '" + DtoS(dDtRef) + "' "
cQuery += " AND SEH.EH_STATUS = 'A' "
cQuery += " AND SEH.D_E_L_E_T_ =  ' ' "
 
cQuery += " GROUP BY "
cQuery += " SEH.R_E_C_N_O_ "

//Recebo o Sql e converto para a base correta com ChangeQuery
cQuery := ChangeQuery(cQuery)

If Select(cATINV) > 0    
	(cATINV)->(dbSelectArea(cATINV))
	(cATINV)->(dbCloseArea())
EndIf

cQuery	:= ChangeQuery(cQuery)
nHandle := fCreate('QRYDAGIN.SQL', 0)
fWrite(nHandle, CHR(13)+CHR(10)+cQuery+CHR(13)+CHR(10) )
fClose(nHandle)

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cATINV,.F.,.T.)
// TCQUERY cQuery New Alias cATINV
dbSelectArea(cATINV)
dbGoTop()
If lMsg
	(cATINV)->(dbEval({|| nRecTr1++ }))
	(cATINV)->(dbGotop())
	ProcRegua(nRecTr1)
EndIf
//While percorrendo o resultado da query acima
While (cATINV)->(!EOF())

	If lMsg	
		IncProc(STR0004) /*"Processando registros de investimentos.."*/
	EndIf
   	 
    SEH->(MsGoto((cATINV)->SEH_RECNO))
    
    cTpCust  := ""
    cVincAns := ""
    nQuotas := 0
    
    aCalculo := Fr820Calc(cAplCotas,@aAplic, dDtRef)
    nValLiq := xMoeda(aCalculo[1],1,1) - (xMoeda(aCalculo[2]+aCalculo[3]+aCalculo[4],1,1))
    
    aRetBox := RetSx3Box( X3CBox( Posicione('SX3',2,"EH_TPCUSTD",'X3_CBOX') ),,,1 )
	If (nPos := AsCan( aRetBox , {|x| AllTrim(x[2]) == SEH->EH_TPCUSTD } ))>0
		cTpCust := alltrim(aRetBox[nPos,3])
	EndIf
	
	aRetBox := RetSx3Box( X3CBox( Posicione('SX3',2,"EH_VINCANS",'X3_CBOX') ),,,1 )
	If (nPos := AsCan( aRetBox , {|x| AllTrim(x[2]) == SEH->EH_VINCANS } ))>0
		cVincAns := alltrim(aRetBox[nPos,3])
	EndIf
	
	nQuotas := iif(SEH->EH_QUOTAS > 0, SEH->EH_QUOTAS, 1)

	If lMigPls
	    aADD(aRet, {;
	        cTpCust ,;
	        SEH->EH_NUMERO,;
	        SEH->EH_DATA,;
	        SEH->EH_DATVENC,;
	        alltrim(SEH->EH_TPOUTR),;
	        alltrim(SEH->EH_TPBEM),;
	        ROUND(nQuotas,2),;
	        ROUND(nValLiq/nQuotas,2),;
	        ROUND(nValLiq,2),;
	        alltrim(SEH->EH_NBANCO),;
	        TRANSFORM(Posicione("SA6", 1, xFilial("SA6")+SEH->(EH_BANCO+EH_AGENCIA+EH_CONTA), "A6_CGC"),StrTran(PicCpfCnpj("","J"),"%C","")),;
	        cVincAns } )
	
	Else
	    aADD(aRet, {;
	        cTpCust ,;
	        SEH->EH_NUMERO,;
	        dtoc(SEH->EH_DATA),;
	        dtoc(SEH->EH_DATVENC),;
	        alltrim(SEH->EH_TPOUTR),;
	        alltrim(SEH->EH_TPBEM),;
	        alltrim(TRANSFORM(ROUND(nQuotas,2),"@E 999,999,999.99")),;
	        alltrim(TRANSFORM(ROUND(nValLiq/nQuotas,2),"@E 999,999,999.99")),;
	        alltrim(TRANSFORM(ROUND(nValLiq,2),"@E 999,999,999.99")),;
	        alltrim(SEH->EH_NBANCO),;
	        TRANSFORM(Posicione("SA6", 1, xFilial("SA6")+SEH->(EH_BANCO+EH_AGENCIA+EH_CONTA), "A6_CGC"),StrTran(PicCpfCnpj("","J"),"%C","")),;
	        cVincAns } )
       
	EndIf
	
    (cATINV)->(dbSkip())
     
EndDo
(cATINV)->(dbSelectArea(cATINV))
(cATINV)->(dbCloseArea())
	
Return( { ( Len(aRet)>0), aRet } )

/*/{Protheus.doc} PLSATGARIM
Query Ativos Garantidores - Imóveis
Alteração para contemplar migração para a Central de Obrigações - Roger C - 23/02/18

@author Karine Riquena Limp
@since 24/02/2017
@version 12

/*/
Function PLSATGARIM(dDtRef, lMsg, cCodLivro)
		
Local aRet		:= {} 
Local cQuery	:= "" 
Local cAplCotas	:= GetMv("MV_APLCAL4")
Local aAplic	:= {}
Local aCalculo	:= {}
Local aInvestimentos := {}
Local nValLiq	:= 0
Local cTpCust	:= ""
Local cVincAns	:= ""
Local nQuotas	:= 0
Local nMoeda	:= 0
Local nRecTr1	:= 0
Local cATIMO	:= GetNextAlias() 
Local nOriginal	:= 0
Local nAmpliacao:= 0
Local nCorrecAcm:= 0
Local nVlrBaixas:= 0
Local nDeprecAcm:= 0

Default dDtRef	:= dDataBase
Default lMSg	:= .T.
Default cCodLivro:= ''

cQuery := " SELECT " 
cQuery += " N1_FILIAL,N1_CBASE,N1_GRUPO,N1_ITEM,N1_AQUISIC,N1_DESCRIC,N1_BAIXA,N1_CHAPA,N1_PATRIM, "
cQuery += " N3_TIPO,N3_SEQREAV, " 
cQuery += " N3_CCONTAB CONTA , N3_CUSTBEM CCUSTO , N3_SUBCCON SUBCTA , N3_CLVLCON, "
cQuery += " N3_ATFCPR, N1_REDE, N1_CODRGI, N1_TPCUSTD, N1_DTVENC "

cQuery += " FROM " + RetSqlName("CTN") + " CTN "
cQuery += " INNER JOIN " + RetSqlName("CTS") + " CTS "
cQuery += " ON(CTN_PLAGER = CTS_CODPLA) "
cQuery += " INNER JOIN " + RetSqlName("SN3") + " SN3 "
cQuery += " ON(N3_CCONTAB  BETWEEN CTS_CT1INI AND CTS_CT1INI) " 
cQuery += " INNER JOIN " + RetSqlName("SN1") + " SN1 "
cQuery += " ON(N1_FILIAL = N3_FILIAL AND N1_CBASE = N3_CBASE AND N1_ITEM = N3_ITEM ) "
cQuery += " WHERE "
cQuery += " CTN.CTN_FILIAL = '" + xFilial("CTN") + "' "
cQuery += " AND CTN_CODIGO = '" + cCodLivro + "' "
cQuery += " AND CTN.D_E_L_E_T_ = ' ' "
cQuery += " AND N1_AQUISIC  <= '" + DTOS(dDtRef) + "' AND "
cQuery += " N3_TPSALDO = '1' AND "
cQuery += " ( N3_DTBAIXA > '" + DTOS(dDtRef) + "'  OR N3_DTBAIXA = '') AND "
cQuery += " (N1_BAIXA   > '" + DTOS(dDtRef) + "' OR N1_BAIXA = '')  AND "     
cQuery += " SN1.D_E_L_E_T_ = '' AND "
cQuery += " SN3.D_E_L_E_T_ = '' "

cQuery += " GROUP BY "
cQuery += " N1_FILIAL,N1_CBASE,N1_GRUPO,N1_ITEM,N1_AQUISIC,N1_DESCRIC,N1_BAIXA,N1_CHAPA,N1_PATRIM, "
cQuery += " N3_TIPO,N3_SEQREAV, "
cQuery += " N3_CCONTAB, N3_CUSTBEM, N3_SUBCCON, N3_CLVLCON, "
cQuery += " N3_ATFCPR, N1_REDE, N1_CODRGI, N1_TPCUSTD, N1_DTVENC "	

If Select(cATIMO) > 0    
	(cATIMO)->(dbSelectArea(cATIMO))
	(cATIMO)->(dbCloseArea())
EndIf
		
cQuery	:= ChangeQuery(cQuery)
nHandle := fCreate('QRYDAGIM.SQL', 0)
fWrite(nHandle, CHR(13)+CHR(10)+cQuery+CHR(13)+CHR(10) )
fClose(nHandle)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cATIMO,.T.,.F.)
(cATIMO)->(dbSelectArea(cATIMO))
(cATIMO)->(dbGoTop())
If lMsg
	(cATINV)->(dbEval({|| nRecTr1++ }))
	(cATINV)->(dbGotop())
	ProcRegua(nRecTr1)
EndIf
//While percorrendo o resultado da query acima
While (cATIMO)->(!EOF())
	
	If lMsg
		IncProc(STR0005) /*"Processando registros de imóveis.."*/
	EndIf	
// Function SaldoSN4( cFilBem,cCodBase,cItem,cTipo,cSeq,cSeqReav,aMoeda,dDataSLD,lAgrupa,dDataIni,cSaldo)
	aValor := SaldoSN4( (cATIMO)->N1_FILIAL,(cATIMO)->N1_CBASE,(cATIMO)->N1_ITEM,(cATIMO)->N3_TIPO,"",(cATIMO)->N3_SEQREAV,{"01"},dDtRef,.T.,,'1')

	// Irá considerar somente a Moeda 1	
	/*
	For nMoeda := 1 to Len(aValor)
		nOriginal  := aValor[nMoeda][2][POS_VLR_ORGINIAL]
		nAmpliacao := aValor[nMoeda][2][POS_AMPLIACAO]
		nCorrecAcm := aValor[nMoeda][2][POS_CORREC_BEM]
		nVlrBaixas := aValor[nMoeda][2][POS_BAIXAS]
		nDeprecAcm := aValor[nMoeda][2][POS_DEPR_FISCAL]
	*/
	nOriginal  := aValor[1][2][POS_VLR_ORIGINAL]
	nAmpliacao := aValor[1][2][POS_AMPLIACAO]
	nCorrecAcm := aValor[1][2][POS_CORREC_BEM]
	nVlrBaixas := aValor[1][2][POS_BAIXAS]
	nDeprecAcm := aValor[1][2][POS_DEPR_FISCAL]
	
	If ! ((cATIMO)->N3_TIPO $ '07/08/09')
		nAtualiz	:= nOriginal + nAmpliacao + nCorrecAcm - nVlrBaixas
		nResidual	:= nAtualiz - nDeprecAcm
	Else
		nAtualiz	:= 0
		nResidual	:= 0
	EndIf
		
	//Next nI
	aAdd( aRet, { (cATIMO)->N1_CODRGI, (cATIMO)->N1_REDE, ''/* ASSISTENCIAL AONDE BUSCAR??? */, nResidual } ) 		
	(cATIMO)->(dbSkip())

EndDo 
(cATIMO)->(dbSelectArea(cATIMO))
(cATIMO)->(dbCloseArea())
	
Return( { ( Len(aRet)>0), aRet } )

//-------------------------------------------------------------------
/*/{Protheus.doc} AtGToArray
Converte o arquivo temporário em array de dados para posterior criação do arquivo CSV.

@author	Karine Riquena Limp
@since		24/02/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function AtGToArray(aReg, nTp)

	Local aDados := {} 
	Local nI := 0
	
	if(nTp == 1)
		for nI := 1 to len(aReg)
			aadd(aDados, aReg[nI][1] + ";" + aReg[nI][2] + ";" + aReg[nI][3] + ";" + aReg[nI][4] + ";" + aReg[nI][5] + ";" + aReg[nI][6] + ";" + aReg[nI][7] + ";" + aReg[nI][8] + ";" + aReg[nI][9] + ";" + aReg[nI][10] + ";" + aReg[nI][11] + ";" + aReg[nI][12])
		next nI
	else
		for nI := 1 to len(aReg)
			aadd(aDados, aReg[nI][1] + ";" + aReg[nI][2] + ";" + aReg[nI][3] + ";" + aReg[nI][4])
		next nI
	endIf
	
	
Return aDados    

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCSVATVIN
Monta arquivo CSV com o layout definido a partir da busca dos ativos garantidores

@author	Karine Riquena Limp
@since		24/02/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function PLSCSVATVIN(aReg, nTp)

	Local cDirCsv 	:= ""
	Local nFileCsv 	:= 0
	Local cTitulo 	:= ""
	Local nI 			:= 1
	Local cFileName	:= STR0021 + iif(nTp == 1, STR0022, STR0023) + "_" +  DTOS(MV_PAR01) + ".csv"
	Local cCabec		:= ""
	
	if(nTp == 1)
		cCabec := STR0006+";"+STR0007+";"+STR0008+";"+STR0009+";"+STR0010+";"+STR0011+";"+STR0012+";"+STR0013+";"+STR0014+";"+STR0015+";"+STR0016+";"+STR0017
		//"Custódia" "Código Ativo" "Data Emissão" "Data Vencimento" "Tipo Outros" "Tipo do Bem" "Quantidade" "Preço Unitário" "Valor Contábil" "Nome do Emissor" "CNPJ do Emissor" "Vinculado"
	else
		cCabec := STR0018+";"+STR0019+";"+STR0020+";"+STR0014
		//"RGI" "Rede Própria" "Assistencial" "Valor Contábil"
	endIf
	
	//Gera arquivo CSV
	PLSGerCSV(cFileName, cCabec, aReg)	
	
Return                

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCSVATVIN
Cálculo dos valores - função copiada do fonte do financeiro (FINR820) por ser static

@author	Karine Riquena Limp
@since		24/02/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function Fr820Calc(cAplCotas,aAplic, dDtRef)
Local aRet := {0,0,0,0,0,0,0}
Local nAscan
If ! SEH->EH_TIPO $ cAplCotas
	aRet	:= Fa171Calc(dDtRef,SEH->EH_SALDO,.T.,,SEH->EH_ULTAPR,,,,,,,.T.)
Else
	aRet := {0,0,0,0,0,0,0}
	SE9->(DbSetOrder(1))
	SE9->(MsSeek(xFilial()+SEH->(EH_CONTRAT+EH_BCOCONT+EH_AGECONT+EH_CTACONT)))
	
	
	dbSelectArea("SE0")
	SE0->(dbSetOrder(2))
	If SE0->(dbSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO+Dtos(IIf(!Empty(dDtRef),dDtRef,dDatabase)))))
		Aadd(aAplic,{	SEH->EH_CONTRAT,SEH->EH_BCOCONT,SEH->EH_AGECONT, SE0->E0_VALOR,0,0,SEH->EH_CTACONT})
	ElseIf SE0->(dbSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO)))
		Aadd(aAplic,{	SEH->EH_CONTRAT,SEH->EH_BCOCONT,SEH->EH_AGECONT, SE0->E0_VALOR,0,0,SEH->EH_CTACONT})			
	Endif

	nAscan := Ascan(aAplic, {|e|e[APLCONTR] == SEH->EH_CONTRAT .And.;
									e[APLBANCO] == SEH->EH_BCOCONT .And.;
									e[APLAGENC] == SEH->EH_AGECONT .AND.;
									e[APLCONTA] == SEH->EH_CTACONT})
	If nAscan > 0
		aRet	:=	Fa171Calc(dDtRef,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,aAplic[nAscan][APLCOTVR],(SEH->EH_SLDCOTA * aAplic[nAscan][APLCOTVR]),,,,.T.)
	Endif
EndIf
Return aRet
