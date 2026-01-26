#Include 'Protheus.ch'

Function TAFGRSCO(aWizard as array, aFilial as Array, cCabecalho as Char)

Local nHandle   as Numeric
Local oError	as Object
Local cTxtSys  	as Char
Local cStrTxt 	as Char

Local cREG 		as Char


//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
nHandle   	:= MsFCreate( cTxtSys )
cREG 		:= "XDC"
cStrTxt 	:= ""

//Leitura para buscar os campos relacionados a tabelas C1E
DbSelectArea("C1E")
DbSetOrder(3)
If DbSeek(xFilial("C1E")+aFilial[1]+"1")
	cCpfCnt		:= C1E_CPFCNT
	cNomeC1E	:= C1E_NOMCNT
	cDddC1E		:= C1E_DDDFON
	cFoneC1E	:= C1E_FONCNT
Endif

Begin Sequence

	cStrTxt += cCabecalho
	cStrTxt += StrZero(++nSeqGiaRS,4)										//Sequencia
	cStrTxt += PADR(Alltrim(cREG),4,"")									//FIXO - XDC
	cStrTxt += PADL(Alltrim(aFilial[9]),14,"0")							//CGC
	cStrTxt += PADR(aFilial[2],50)										//Razão Social

	//Busca Telefone
	aTel := GetTel(aFilial[8])
	cStrTxt += StrZero(aTel[2],3)										//DDD do Contribuinte 	- (SIGAMAT)
	cStrTxt += PADR(AllTrim(cValtoChar(aTel[3])),8,"0")					//Fone do Contribuinte	- (SIGAMAT)

	cStrTxt += Iif(aWizard[1,6] == "0 - Não", "N", "S")					//Selecionado para entrega
	cStrTxt += SPACE(06)												//Código de Entrega GIA - Opcional - Alfanumerico(6)

	WrtStrTxt( nHandle, cStrTxt )

	GerTxtGRS( nHandle, cTxtSys, aFilial[01] + "_" + cReg )

	Recover

	lFound := .F.

End Sequence

Return