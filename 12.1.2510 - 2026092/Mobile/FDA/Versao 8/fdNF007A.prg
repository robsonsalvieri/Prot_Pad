#INCLUDE "FDNF007A.ch"
Function NFFldImp(aCabNot,aIteNot,lConfirmNot) 

Local oDlgImp,oBtnConfNot,oBtnVltNot 
Local oCol,oGetTNF,oTxtSIte
//Local nTotalNF:=0
Local nTotalNF:=aCabNot[35,1]
Local oBrwImp,oBrwCab
Local aFdaNfCab:={},aFdaNfItem:={},aCabImp:={}
Local nSIte := Len(aIteNot)

//Carrega Variaveis 
FdaCgVar()

IniCalc(oBrwImp,oBrwCab,aCabImp,aFdaNfCab,aFdaNfItem,aCabNot,aIteNot)

DEFINE DIALOG oDlgImp TITLE STR0001                                                //"Confirmação da NF"

@ 18,2 BROWSE oBrwImp    SIZE 155,50 OF oDlgImp
SET BROWSE oBrwImp ARRAY aFdaNfItem
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 1  HEADER STR0002  WIDTH 50 //"Produto"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 2  HEADER STR0003 WIDTH 50  //"Grp.Trib"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 3  HEADER STR0004   WIDTH 50 //"PrcVen"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 4  HEADER STR0005   WIDTH 50  //"QtdVen"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 5  HEADER STR0006   WIDTH 50 //"Descto"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 6  HEADER STR0007  WIDTH 50  //"ValMerc"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 7  HEADER STR0008    WIDTH 50 //"Frete"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 8  HEADER STR0009  WIDTH 50  //"Despesa"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 9  HEADER STR0010   WIDTH 50 //"Seguro"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 10 HEADER STR0011      WIDTH 50  //"Tes"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 11 HEADER STR0012     WIDTH 50 //"Base Icm"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 12 HEADER STR0013     WIDTH 50  //"Aliq Icm"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 13 HEADER STR0014   WIDTH 50  //"Vl imp Icm"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 14 HEADER STR0015    WIDTH 50 //"Base IPI"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 15 HEADER STR0016    WIDTH 50  //"Aliq IPI"
ADD COLUMN oCol TO oBrwImp ARRAY ELEMENT 16 HEADER STR0017   WIDTH 50  //"Vlimp IPI"

@ 68,02 SAY STR0018 of oDlgImp //"Item(ns): "
@ 68,45 GET oTxtSIte VAR nSIte READONLY SIZE 40,12 of oDlgImp

@ 81,2 BROWSE oBrwCab SIZE 155,51 OF oDlgImp
SET BROWSE oBrwCab ARRAY aCabImp
ADD COLUMN oCol TO oBrwCab ARRAY ELEMENT 1  HEADER STR0019 WIDTH 80 //"Descricao"
ADD COLUMN oCol TO oBrwCab ARRAY ELEMENT 2  HEADER STR0020 WIDTH 70  //"Valor    "

@ 134,2  SAY STR0021 OF oDlgImp //"Total NF:"
@ 134,47 GET oGetTNF VAR nTotalNF PICTURE "@E 9,999,999.99" READONLY SIZE 60,12 of oDlgImp

@ 148,10 BUTTON oBtnConfNot CAPTION STR0022 ACTION NFFecConfT(lConfirmNot) SIZE 60,10 OF oDlgImp //"Confirmar"
@ 148,89 BUTTON oBtnVltNot  CAPTION STR0023  ACTION NFFecConfF(lConfirmNot,aIteNot)SIZE 60,10 OF oDlgImp //"Cancelar"

ACTIVATE DIALOG oDlgImp

Return Nil


Function IniCalc(oBrwImp,oBrwCab,aCabImp,aFdaNfCab,aFdaNfItem,aCabNot,aIteNot)
Local cCodCliFor:="",cLoja:="", cTipoNf:="S", cEspecie   := "NF " 
Local cProduto:="",cTes:="501"
Local nQtdVen:=0,nPrcVen:=0, nDesconto:=0, nSeguro:=0, nFrete:=0, nDespesa:=0, nValMerc:=0
Local nCont:=0, nOpt:=15

If Len(aIteNot) == 0
	MsgAlert(STR0024,STR0025) //"Não existem itens na NF para calcular!"###"Aviso"
	return nil
Endif         

//zera os arrays antes de iniciar os calculos
aSize(aFdaNfCab, 0)
aSize(aFdaNfItem, 0)
aSize(aCabImp, 0)

//Inicializa o Array para os valores de impostos 
aadd( aCabImp,{ STR0026 , 0 } ) //"Base do ICMS"
aadd( aCabImp,{ STR0027, 0 } ) //"Valor do ICMS"
aadd( aCabImp,{ STR0028, 0 } ) //"Base ICMS Subst"
aadd( aCabImp,{ STR0029, 0 } ) //"Valor ICMS Subst"
aadd( aCabImp,{ STR0030, 0 } ) //"Valor do Frete"
aadd( aCabImp,{ STR0031, 0 } ) //"Valor do Seguro"
aadd( aCabImp,{ STR0032, 0 } ) //"Outras Desp.Acessorias"
aadd( aCabImp,{ STR0033, 0} ) //"Base do IPI"
aadd( aCabImp,{ STR0034, 0 }  ) //"Valor do IPI"

//Monta Array para calculo da Nota
//FdaCgRef(aFdaCab,aFdaItem)
//Faz a carga das variaveis
//FdaCgVar() 

// Calcula os impostos 
NFCalcImP(oBrwImp,oBrwCab,aFdaNfItem,aFdaNfCab,aCabNot,aIteNot,aCabImp)   

Return nil


Function NFCalcImP(oBrwImp,oBrwCab,aFdaNfItem,aFdaNfCab,aCabNot,aIteNot,aCabImp)
Local cCodCliFor,cLoja, cTipoNf:="S", cEspecie 
Local cProduto:="",cTes:=GetMV("MV_FDATES","501")  
Local nQtdVen:=0,nPrcVen:=0, nDesconto:=0, nSeguro:=0, nFrete:=0, nDespesa:=0, nValMerc:=0
Local nCont:=1  
Local nItensNF:=Len(aIteNot)

MsgStatus(STR0035 ) //"Aguarde, calculando..."

cEspecie   := "NF "               
cTipoNF    := "S"
cCodCliFor := aCabNot[4,1]
cLoja      := aCabNot[5,1]

// Inicializa as variaveis para calcular os impostos 
FdaFisIni(cCodCliFor,cLoja,cTipoNF,cEspecie,aFdaNfCab,aFdaNfItem)

For nCont:=1 to nItensNF // Sera os itens da nota.... 

    cProduto  := aIteNot[nCont,3]    //aIteNot[3,1]    
    cTes      := aIteNot[nCont,11]   //aIteNot[11,11]    
    nQtdVen   := aIteNot[nCont,6]    //aIteNot[6,1]    
	nPrcVen   := aIteNot[nCont,23]   //aIteNot[7,1]    
	nDesconto := aIteNot[nCont,13]   //aIteNot[13,1]    
	nSeguro   := 0
	nFrete    := 0
	nDespesa  := 0
	nValMerc  := aIteNot[nCont,8]    //aIteNot[8,1]    
	
    FdaFisAdd(cProduto,cTes, nQtdVen, nPrcVen, nDesconto, nSeguro, nFrete, nDespesa, nValMerc, aFdaNfCab, aFdaNfItem)
    
Next                                                           

//Atualiza array com os valores do cabec. da NF
aCabImp[1,2] := aFdaNfCab[12]
aCabImp[2,2] := aFdaNfCab[13]
aCabImp[8,2] := aFdaNfCab[14]
aCabImp[9,2] := aFdaNfCab[15]

ClearStatus() 

Return                                                                                            
