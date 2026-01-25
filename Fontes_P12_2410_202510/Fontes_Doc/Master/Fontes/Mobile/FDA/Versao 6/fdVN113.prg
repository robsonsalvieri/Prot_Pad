#INCLUDE "FDVN113.ch"
#include "eADVPL.ch"

Function GrvPagto(nOperacao,cCodCli,cLojaCli,aObj,aCbx,nCbx,oBrwForma,aForma,nValRec,cNumCh,cBanco,dDatDep,cCond,nSldTot,aPedido,cNumAg)
Local nLin := GridRow(oBrwForma)
Local nSeq  := 1                    
Local nPos  := At("-", aCbx[nCbx])
Local cTipo := Substr( aCbx[nCbx], 1, nPos-1 )

If !VrfPagto(nOperacao,cTipo,aForma,nValRec,cNumCh,cBanco,dDatDep,cCond,nSldTot,aPedido)
	Return nil
Endif

dbSelectArea("HEL")
dbSetOrder(1)

//Se inclusao
If nOperacao == 1
	dbSeek(cCodCli+cLojaCli,.f.)
	While !Eof() .And. HEL->EL_CLIENTE = cCodCli .And. HEL->EL_LOJA = cLojaCli
		//Busca a prox. sequencia do cliente
		nSeq := Val(HEL->EL_SEQ) + 1
		If nSeq > 999
		   nSeq := 1
		Endif
		HEL->(dbSkip())	                                                                          
	Enddo
Else
	HEL->( dbSeek(cCodCli+cLojaCli+aForma[nLin,4])	)
Endif

If nOperacao == 1
	HEL->(dbAppend())
Endif
HEL->EL_CLIENTE := cCodCli
HEL->EL_LOJA	:= cLojaCli
HEL->EL_SEQ     := IIf(nOperacao=1,StrZero(nSeq,3),HEL->EL_SEQ)
HEL->EL_TIPODOC := cTipo
HEL->EL_PREFIXO := ""
HEL->EL_NUMERO  := ""
HEL->EL_PARCELA := "1"
HEL->EL_VALOR	:= nValRec
HEL->EL_MOEDA   := "1"
HEL->EL_EMISSAO := dDataBase
HEL->EL_DTVCTO	:= dDatDep	//Data deposito
HEL->EL_TPCRED	:= ""
HEL->EL_BANCO	:= ""
HEL->EL_AGENCIA	:= ""
HEL->EL_CONTA   := ""
HEL->EL_BCOCHQ  := cBanco
HEL->EL_AGECHQ	:= ""
HEL->EL_CTACHQ	:= cNumCh
HEL->EL_OBSBCO	:= ""
HEL->EL_ACREBAN	:= ""
HEL->EL_TERCEIR	:= ""
//criar este campo (cond. pagto qdo. for credito)
//HEL->EL_COND	:= IIf(cTipo=="C", cCond, GetParam("MV_SFAVIST","") )
HEL->EL_STATUS  := "N"
HEL->(dbCommit())

If nOperacao == 1
	aadd(aForma,{HEL->EL_EMISSAO,HEL->EL_TIPODOC,HEL->EL_VALOR,HEL->EL_SEQ,"Nao Transmitido"} )
	SetArray(oBrwForma,aForma)
Else
	aForma[nLin,2] := cTipo
	aForma[nLin,3] := nValRec
	SetFocus(oBrwForma)
Endif
	
//If cTipo == "C"
	//Atualizar nos pedidos o campo C5_COND
//	AtuCondPedido(cCond,nValRec,cCodCli,cLojaCli)
//Endif	
CloseDialog()

Return nil


Function LoadPagos(cCodCli,cLojaCli,aForma)
Local cStatus:=""
dbSelectArea("HEL")
dbSetOrder(1)
dbSeek(cCodCli+cLojaCli,.f.)
While !Eof() .And. HEL->EL_CLIENTE = cCodCli .And. HEL->EL_LOJA = cLojaCli
	If HEL->EL_EMISSAO == dDataBase 
		cStatus := IIf( HEL->(IsDirty()), "Nao transmitido", "Transmitido" )
		aadd(aForma,{HEL->EL_EMISSAO,HEL->EL_TIPODOC,HEL->EL_VALOR,HEL->EL_SEQ, cStatus} )
	Endif
	HEL->(dbSkip())	                                                                          
Enddo
Return nil


Function ExcPagto(cCodCli,cLojaCli,nAtend,oBrwForma,aForma)
Local nLin := GridRow(oBrwForma)
Local nRec :=0 

nRec:=GridRow(oBrwForma)  
If Alltrim(aForma[nRec,5])=="Transmitido" 
	msgAlert("Recebimento ja transmitido, nao pode ser excluido" , "Atencao"  )   
	Return
Endif

If Len(aForma) <= 0
	return nil
Endif

HEL->(dbSetOrder(1))
HEL->( dbSeek(cCodCli+cLojaCli+aForma[nLin,4]) )
If HEL->(Found())
	HEL->(dbDelete())
	HEL->(dbSkip())
	HEL->(dbCommit()) 
	aDel(aForma,nLin)
	aSize(aForma, Len(aForma)-1 )
	SetArray(oBrwForma,aForma)
Endif
Return nil
          

Function LoadPagto(cCodCli,cLojaCli,nAtend,nSldTot,oBrwForma,;
aForma,nSaldoReal,nSldAtu,nValRec,cNumCh,cBanco,dDatDep,nCbx,cCond)

Local nLin := GridRow(oBrwForma)

HEL->(dbSetOrder(1))
HEL->( dbSeek(cCodCli+cLojaCli+aForma[nLin,4]) )
If HEL->(Found())
	If aForma[nLin,2] == "CH"
		cNumCh := HEL->EL_CTACHQ
		cBanco := HEL->EL_BCOCHQ
		nCbx := 2
	ElseIf aForma[nLin,2] == "VA"
		nCbx :=	3
	ElseIf aForma[nLin,2] == "EF"
		nCbx :=	1 
	ElseIf aForma[nLin,2] == "TF"
		dDatDep := HEL->EL_DTVCTO
		nCbx := 4
	Endif	                                 
	nValRec := HEL->EL_VALOR
Endif

Return nil


Function VrfPagto(nOperacao,cTipo,aForma,nValRec,cNumCh,cBanco,dDatDep,cCond,nSldTot,aPedido)

If cTipo == "CH"
	If Empty(cNumCh)
		MsgStop(STR0006,STR0002) //"Ingresse el Cheque!"###"Aviso"
		return .f.	
	ElseIf Empty(cBanco)
		MsgStop(STR0007,STR0002)		 //"Ingresse el Banco!"###"Aviso"
		return .f.	
	Endif
ElseIf cTipo = "TF"
	If Empty(dDatDep)
		MsgStop(STR0008,STR0002) //"Ingresse el Data!"###"Aviso"
		return .f.
	Endif
Endif   

//Variavel usada para todos os tipos
If nValRec <= 0
	MsgStop(STR0009,STR0002) //"Ingrese el Pago!"###"Aviso"
	return .f.
Endif     

Return .T.


//Atualiza as cond. de pagto (Plazo) 
//nos pedidos (somente para Credito)
Function AtuCondPedido(cCond,nValRec,cCodCli,cLojaCli)
Local nValCobrar := nValRec

MsgStatus(STR0010) //"Modificando Pedidos..."
dbSelectArea("HC5")
dbSetOrder(2)
dbSeek(cCodCli+cLojaCli,.f.)
While !Eof() .and. HC5->C5_CLI == cCodCli .and. HC5->C5_LOJA == cLojaCli
    If HC5->C5_STATUS = "N" .And. HC5->C5_EMISS = dDataBase .And. HC5->(IsDirty())
   		nValCobrar := nValCobrar - HC5->C5_VALOR
   		HC5->C5_COND := cCond
   		dbCommit()
   		If nValCobrar <= 0
   			exit
   		Endif
    Endif
	HC5->(dbSkip())
Enddo
ClearStatus()
Return nil