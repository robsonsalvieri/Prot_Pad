#Include 'Protheus.ch' 
#Include 'STBINCCUSTOMER.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} STBVldCGC
Validacao do campo A1_CGC. Qd Pessoa="J" nao permitir entrada de CPF.

@param
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno .T. se nao houver registro com a mesma chave unica na base.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBVldCGC(cCodCliente,cLojCliente,cTipPes,cCNPJ)
Local aArea       := GetArea()
Local aAreaSA1    := SA1->(GetArea())
Local lRetorno    := .T.
Local cCNPJBase   := ""
Local cMv_ValCNPJ := GetNewPar("MV_VALCNPJ","1")
Local cMv_ValCPF  := GetNewPar("MV_VALCPF","1")
Local lAchou      := .F.
Local lEleMesmo   := .F.

DEFAULT cCNPJ     := &(ReadVar())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o tipo de pessoa                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipPes == "F" .AND. !(Len(AllTrim(cCNPJ))==11)
	STFMessage("STBVldCGC","STOP",STR0001) //"Dígito verificador incorreto, entre com um código válido." 
	STFShowMessage("STBVldCGC")
	lRetorno := .F.
ElseIf cTipPes == "J" .AND. !(Len(AllTrim(cCNPJ))==14)  
	STFMessage("STBVldCGC","STOP",STR0001) //"Dígito verificador incorreto, entre com um código válido." 
	STFShowMessage("STBVldCGC")    
	lRetorno := .F.
EndIf     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a duplicidade do CGC                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .AND. Pcount() > 1 
	If cTipPes == "J" .Or. Empty(cTipPes)
		DbSelectArea("SA1")
		DbSetOrder(3)
		lAchou := DbSeek(xFilial("SA1")+cCNPJ)
		If lAchou
			lEleMesmo := cCodCliente+cLojCliente == SA1->A1_COD+SA1->A1_LOJA
		EndIf
		If lAchou .AND. !lEleMesmo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O parametro MV_VALCNPJ verifica se a validacao do CNPJ deve ser feita:                            ³
			//³1 = informando ao usuario que ja existe o CNPJ na base e verificando se deseja incluir mesmo assim³
			//³2 = nao permitindo que o usuario insira o mesmo CNPJ                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMv_ValCNPJ == "1" 
				If !_SetAutoMode()
					STFMessage("STBVldCGC","YESNO",STR0002+" "+ AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + STR0003) //"O CNPJ informado já foi utilizado no cliente" ..". Confirma o cadastro?"
					If !STFShowMessage("STBVldCGC")	
						STFMessage("STBVldCGC","STOP",STR0004) //"O CNPJ informado já foi utilizado, favor alterar."
						STFShowMessage("STBVldCGC")
						lRetorno   := .F.
					EndIf
				EndIf
			Else
				STFMessage("STBVldCGC","STOP",STR0002+" "+ AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + ".") //"O CNPJ informado já foi utilizado no cliente
				STFShowMessage("STBVldCGC")
				lRetorno := .F.
			Endif
		ElseIf lRetorno			
			cCNPJBase := SubStr(cCNPJ,1,8)
			DbSelectArea("SA1")
			DbSetOrder(3)
		  	If DbSeek(xFilial("SA1")+cCNPJBase) .And. cCodCliente <> SA1->A1_COD .And. SA1->A1_PESSOA == "J"
				If !_SetAutoMode()
					STFMessage("STBVldCGC","YESNO",STR0002+" "+ AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + STR0003) //"O CNPJ informado já foi utilizado no cliente" ..". Confirma o cadastro?"
					If !STFShowMessage("STBVldCGC")
						STFMessage("STBVldCGC","STOP",STR0004) //"O CNPJ informado já foi utilizado, favor alterar."
						STFShowMessage("STBVldCGC")
						lRetorno   := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek(xFilial("SA1")+cCNPJ) .And. cCodCliente+cLojCliente <> SA1->A1_COD+SA1->A1_LOJA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O parametro MV_VALCPF verifica se a validacao do CPF deve ser feita:                              ³
			//³1 = informando ao usuario que ja existe o CPF na base e verificando se deseja incluir mesmo assim ³
			//³2 = nao permitindo que o usuario insira o mesmo CPF                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMv_ValCPF == "1"
				If !_SetAutoMode()
					STFMessage("STBVldCGC","YESNO",STR0005+" "+ AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + STR0003) //"O CPF informado já foi utilizado no cliente" .. ". Confirma o cadastro?"
					If !STFShowMessage("STBVldCGC")
						STFMessage("STBVldCGC","STOP",STR0006) // "O CPF informado já foi utilizado, favor alterar."
						STFShowMessage("STBVldCGC")
						lRetorno := .F.						
					EndIf
				EndIf
			Else
				STFMessage("STBVldCGC","STOP",STR0005+" "+ AllTrim(SA1->A1_COD) + "/" + AllTrim(SA1->A1_LOJA) + " - " + AllTrim(SA1->A1_NOME) + ".") //"O CPF informado já foi utilizado no cliente"
				STFShowMessage("STBVldCGC")
				lRetorno := .F.
			Endif
		EndIf
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida a existencia do CNPJ/CPF nos cadastros de suspect³
//³e prospect                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lRetorno .AND. (nModulo == 5 .or. nModulo == 13) .And. !lEleMesmo
	If (cTipPes == "F" .And. cMv_ValCPF <> "1") .Or. ((cTipPes == "J" .Or. Empty(cTipPes)) .And. cMv_ValCNPJ <> "1")
		If !Empty(cCNPJ)
			lRetorno := TmkVeEnt(cCNPJ,"SA1")
		EndIf
	EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aArea)
Return lRetorno  

//-------------------------------------------------------------------
/*{Protheus.doc} STBVldRETCli
Valida se o cliente existe na retaguarda.

@param
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno .T. se nao houver registro com a mesma chave unica na base.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBVldRETCli(cChave)
Local lRet := .F.

If SA1->(DbSeek(xFilial()+cChave))
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STBCGCDigVerificador
Processa o criterio de validacao dos campos, verificando se o dígito verificador do CPF/CNPJ e valido.

@param		cCGC - Numero do CGC;
			cVar - Variavel de Memoria a ser retornada;
			lAviso - Valor Logico de Retorno (.T. ou .F.) 
			
@author  	Varejo
@version 	P11.8
@since   	23/07/2012
@return  	lRet			Retorno .T. se nao houver registro com a mesma chave unica na base.
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBCGCDigVerificador(cCGC, cVar, lAviso)
LOCAL nCnt,i,j,cDVC,nSum,nDIG,cDIG:="",cSavAlias,nSavRec,nSavOrd
Local cFormAnt := cCGC

DEFAULT lAviso := .T.  

STFMessage("STBCGCDigVerificador","STOP",STR0001) //"Dígito verificador incorreto, entre com um código válido."    

cCGC := strtran(cCGC, ".", "")
cCGC := strtran(cCGC, "-", "")
cCGC := strtran(cCGC, "/", "")
 
cCGC := IIF(cCgc  == Nil,&(ReadVar()),cCGC)
cVar := If(ValType(cVar) = "U", ReadVar(), cVar)

If cCgc == "00000000000000"
	Return .T.
Endif

nTamanho:=Len(AllTrim(cCGC))

cDVC:=SubStr(cCGC,13,2)
cCGC:=SubStr(cCGC,1,12)

FOR j := 12 TO 13
	nCnt := 1
	nSum := 0
	FOR i := j TO 1 Step -1
		nCnt++
		IF nCnt>9;nCnt:=2;EndIf
		nSum += (Val(SubStr(cCGC,i,1))*nCnt)
	Next i
	nDIG := IIF((nSum%11)<2,0,11-(nSum%11))
	cCGC := cCGC+STR(nDIG,1)
	cDIG := cDIG+STR(nDIG,1)
Next j
lRet:=IIF(cDIG==cDVC,.T.,.F.)

IF !lRet
	IF nTamanho < 14
		cDVC:=SubStr(cCGC,10,2)
		cCPF:=SubStr(cCGC,1,9)
		cDIG:=""

		FOR j := 10 TO 11
			nCnt := j
			nSum := 0
			For i:= 1 To Len(Trim(cCPF))
				nSum += (Val(SubStr(cCPF,i,1))*nCnt)
				nCnt--
			Next i
			nDIG:=IIF((nSum%11)<2,0,11-(nSum%11))
			cCPF:=cCPF+STR(nDIG,1)
			cDIG:=cDIG+STR(nDIG,1)
		Next j

		IF cDIG != cDVC .And. lAviso 
			STFShowMessage("STBCGCDigVerificador")
		Endif

		lRet:=IIF(cDIG==cDVC,.T.,.F.)
		IF lRet;&cVar:=cCPF+Space(3);EndIF
	Else
		If lAviso 	
			STFShowMessage("STBCGCDigVerificador")
	    EndIf
	EndIF
EndIF      

&(ReadVar()) := cFormAnt

Return lRet


