#include "protheus.ch"
#include "ARPrinter.ch"
#include "layfat01.ch"

#define MAXLIN 	15
#define TAMDESC	41

#DEFINE	NVALIMP(CPO)	IIF(FieldPos(CPO) > 0, &(CPO), 0)

#define CVALIB 			(NVALIMP("CVALIBP")+;
						NVALIMP("CVALIB2")+;
						NVALIMP("CVALIB3")+;
						NVALIMP("CVALIB4")+;
						NVALIMP("CVALIB5")+;
						NVALIMP("CVALIB6")+;
						NVALIMP("CVALIB7")+;
						NVALIMP("CVALIB8")+;
						NVALIMP("CVALIBA")+;
						NVALIMP("CVALIBB")+;
						NVALIMP("CVALIBC")+;
						NVALIMP("CVALIBD")+;
						NVALIMP("CVALIBE")+;
						NVALIMP("CVALIBF")+;
						NVALIMP("CVALIBG")+;
						NVALIMP("CVALIBH")+;
						NVALIMP("CVALIBI")+;
						NVALIMP("CVALIBJ")+;
						NVALIMP("CVALIBK")+;
						NVALIMP("CVALIBL")+;
						NVALIMP("CVALIBM")+;
						NVALIMP("CVALIBN")+;
						NVALIMP("CVALIBO")+;
						NVALIMP("CVALIBS"))
		
#define CVALIVAS (NVALIMP("CVALIV1")+NVALIMP("CVALIVA")+NVALIMP("CVALIV7"))
		
#define DALQITEM (NVALIMP("DALQIV1")+NVALIMP("DALQIVA")+NVALIMP("DALQIV7"))
#define DVALITEM (NVALIMP("DVALIV1")+NVALIMP("DVALIVA")+NVALIMP("DVALIV7"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLAYFAT01  บAutor  ณAndres Demarziani   บFecha ณ  09/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Layout de factura de ventas segun el formato que           บฑฑ
ฑฑบ          ณ brinda las impresoras fiscales HASAR                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LAYFAT01(lAutomato)

Local cPerg		:= "LAYFAT01"
Local aArea		:= GetArea()
Local cDirPDF	:= AllTrim( GetNewPar("MV_XPATH"  ,"") )
Local lQRAFIP	:= GetNewPar("MV_FATQRCO",.T.)//Habilita QR en layout de ventas, en caso contrario aparece codigo de barras
Local lQRJAVA	:= GetNewPar("MV_FATQRJA",.T.)//hbilita framework java
Local lesJob	:= .F.
Local oObJson	:= JsonObject():New()

Default lAutomato	:= .F.

MakeDir(cDirPDF)

If Pergunte(cPerg,.T.)

	dbSelectArea("SC5")
	dbSetOrder(1)
		
	dbSelectArea("SF2")
	dbSetOrder(1)
		
	Do Case
		Case mv_par01 == 1
			cEspecie := "NF"
		Case mv_par01 == 2
			cEspecie := "NDC"
		Case mv_par01 == 3
			cEspecie := "NCC"
	EndCase
	
	oObJson['TipoDoc'] := mv_par01
	oObJson['DeDoc'] := mv_par02
	oObJson['ADoc'] := mv_par03
	oObJson['DeSerie'] := mv_par04
	oObJson['ASerie'] := mv_par05
	oObJson['DeFecha'] := mv_par06
	oObJson['AFecha'] := mv_par07
	oObJson['DeCli'] := mv_par08
	oObJson['DeLoja'] := mv_par09
	oObJson['ACli'] := mv_par10
	oObJson['ALoja'] := mv_par11
	oObJson['Cop'] := Val(mv_par12)
	oObJson['GeraPDF'] := mv_par13 == 2
	oObJson['DirPDF'] := AllTrim(mv_par14)

	If oObJson['GeraPDF'] .And. !ExistDir(oObJson['DirPDF'])
		If lAutomato
			MakeDir(oObJson['DirPDF'], , .F.)
		Else
			If MsgYesNo(STR0001)
				If MakeDir(oObJson['DirPDF'],,.F.) <> 0
					MsgStop(STR0002)
					oObJson['GeraPDF'] := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	If !lAutomato
		Processa({|lFin| SelectComp(@oObJson, lesJob, lQRAFIP, lQRJAVA, cEspecie) },STR0058,,.T.)
	Else
		SelectComp(@oObJson, lesJob, lQRAFIP, lQRJAVA, cEspecie)
	EndIf
	
EndIf

FreeObj(oObJson)
oObJson := Nil

RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSelectCompบAutor  ณAndres Demarziani   บFecha ณ  31/10/17   บฑฑ
ฑฑศออออออออออฯออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function SelectComp(oAjParams, lesJob, lQRAFIP, lQRJAVA, cEspecie)

Local cClave	:= ""
Local cItem		:= ""
Local cNomArc	:= ""
Local nLin		:= 1
Local nPag		:= 1
Local nX		:= 1
Local aPosIt		:= {2.5, 6.84, 17.97, 22.8, 22.31, 28.38, 30.82, 36.04, 37.5}
Local aRecuad		:= {2,15,20,58,65}
Local aRecPedSC5	:= {}
Local aRecRemSF2	:= {}
Local cDbfTmp		:= ""
Local cNtxTmp		:= ""
Local oPrn		:= Nil
Local cAliasQry := GetNextAlias()
Local nRec := 0

Default oAjParams := Nil
Default lesJob := .F.
Default lQRAFIP := .F.
Default lQRJAVA := .F.
Default cEspecie := ''

If oAjParams['Cop'] > 5
	MsgStop(STR0003)
	Return
EndIf

fArmaDatos(@oAjParams, cEspecie, cNtxTmp, cDbfTmp, @cAliasQry)

dbSelectArea(cAliasQry)
dbGoTop()

If !Eof()
	If !lesJob
		ProcRegua((cAliasQry)->(RecCount())*oAjParams['Cop'])
	EndIf
	oPrn := ARPrinter():New(oAjParams['GeraPDF'])

	While !(cAliasQry)->(Eof())		
		If cEspecie $ "NF/NDC"
			cClave 	:= (cAliasQry)->(F2_SERIE+F2_DOC+A1_COD+A1_LOJA+F2_ESPECIE)
			cItem	:= (cAliasQry)->(D2_ITEM)
			cNomArc	:= Alltrim((cAliasQry)->(F2_SERIE))+"_"+Alltrim((cAliasQry)->(F2_DOC))+"_"+AllTrim((cAliasQry)->(A1_COD))+"_"+AllTrim((cAliasQry)->(A1_LOJA))+"_"+AllTrim((cAliasQry)->(cEspecie))
		else
			cClave 	:= (cAliasQry)->(F1_SERIE+F1_DOC+A1_COD+A1_LOJA+F1_ESPECIE)
			cItem	:= (cAliasQry)->(D1_ITEM)
			cNomArc	:= Alltrim((cAliasQry)->(F1_SERIE))+"_"+Alltrim((cAliasQry)->(F1_DOC))+"_"+AllTrim((cAliasQry)->(A1_COD))+"_"+AllTrim((cAliasQry)->(A1_LOJA))+"_"+AllTrim((cAliasQry)->(cEspecie))
		Endif

		// Solo funciona si el objeto se creo como "PDF"
		oPrn:setPDF(cNomArc, oAjParams['DirPDF'])
		
		For nX := 1 To oAjParams['Cop']
			If nX > 1
				(cAliasQry)->(MsSeek(cClave+cItem))
			EndIf
			
			nLin	:= 1
			nPag	:= 1
			
			PrintHead(nX, nPag, oAjParams['TipoDoc'], aPosIt, aRecuad, oPrn, cAliasQry, cEspecie)
					
			While !(cAliasQry)->(Eof()) .And. cClave == Iif(cEspecie $ "NF/NDC",(cAliasQry)->(F2_SERIE+F2_DOC+A1_COD+A1_LOJA+F2_ESPECIE), (cAliasQry)->(F1_SERIE+F1_DOC+A1_COD+A1_LOJA+F1_ESPECIE))
				IncProc()

				nRec := (cAliasQry)->(Recno())
				
				PrintItem(nX, @nLin, @nPag, aPosIt, aRecuad, aRecPedSC5, aRecRemSF2, oPrn, cAliasQry, cEspecie, oAjParams['TipoDoc'])
				nLin++
				(cAliasQry)->(dbSkip())
			EndDo
			
			(cAliasQry)->(dbGotop())
			IF nRec != 1
				(cAliasQry)->(dbSkip(nRec-1))
			Endif
			PrintFoot(nX, @nPag, lQRAFIP, lQRJAVA, aRecuad, aRecPedSC5, oPrn, cEspecie, cAliasQry)
			(cAliasQry)->(dbSkip())
		Next
		
		// Solo funciona si el objeto se creo como "PDF"
		oPrn:imprimePDF()
		
	EndDo

	// Solo funciona si el objeto no se creo como "PDF"
	If !lesJob
		oPrn:visualiza()
	EndIf

Else
	MsgStop(STR0004)
EndIf

If Select(cAliasQry) > 0
	(cAliasQry)->(dbCloseArea())
	FErase(cDbfTmp)
	
	dbClearIndex()
	FErase(cNtxTmp)
EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintHead บAutor  ณAndres Demarziani   บFecha ณ  31/10/17   บฑฑ
ฑฑศออออออออออฯออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PrintHead(nNroCop, nPag, nTipoDoc, aPosIt, aRecuad, oPrn, cAliasQry, cEspecie)

Local aCopias	:= {"ORIGINAL","DUPLICADO","TRIPLICADO","CUADRUPLICADO","QUINTUPLICADO"}
Local aEncab	:= {}
Local nTamPDV	:= TamSX3("CFH_CODIGO")[1]
Local nAjHead	:= 0
Local nCodComp	:= Iif(cEspecie $ "NF/NDC",Val((cAliasQry)->F2_RG1415 ), Val((cAliasQry)->F1_RG1415 ))
Local dVcto		:= Iif(cEspecie $ "NF/NDC",Posicione("SE1",2,xFilial("SE1")+(cAliasQry)->A1_COD+(cAliasQry)->A1_LOJA+(cAliasQry)->F2_SERIE+(cAliasQry)->F2_DOC ,"E1_VENCREA"),Posicione("SE1",2,xFilial("SE1")+(cAliasQry)->A1_COD+(cAliasQry)->A1_LOJA+(cAliasQry)->F1_SERIE+(cAliasQry)->F1_DOC ,"E1_VENCREA"))
Local nX
Local cTipoDoc := AllTrim((cAliasQry)->TIPODOC)

Default nNroCop := 0
Default nPag:= 0
Default nTipoDoc = 0
Default aPosIt := {}
Default aRecuad := {}
Default oPrn := Nil
Default cAliasQry := ''
Default cEspecie := ''


If nCodComp >= 201
	aAdd(aEncab, "MiPyMEs (FCE)")

	If nTipoDoc == 1
		aAdd(aEncab, STR0005)
	ElseIf nTipoDoc == 2
		aAdd(aEncab, STR0006)		
	Else
		aAdd(aEncab, STR0007)
	EndIf
Else
	If nTipoDoc == 1 
		aAdd(aEncab, STR0008)
	ElseIf nTipoDoc == 2 
		aAdd(aEncab, STR0009)
	Else
		aAdd(aEncab, STR0010)
	EndIf
EndIf

oPrn:StartPage()

//--------------
// 1er recuadro
//--------------
oPrn:Box(aRecuad[1]+nAjHead, 2, aRecuad[2]+nAjHead, 47)

//------
// Logo
//------
If File(GetNewPar("MV_FATLOG","logo\logo.bmp"))
	oPrn:SayBitmap(3.1+nAjHead, 5, GetNewPar("MV_FATLOG","logo\logo.bmp"), 550, 250 )
Else
	oPrn:Say(4+nAjHead, 4, STR0011, ARIAL_15B)
	oPrn:Say(5+nAjHead, 4, STR0012, ARIAL_15B)
	oPrn:Say(6+nAjHead, 4, STR0013, ARIAL_15B)	
EndIf

//----------------
// Recuadro Serie
//----------------
If cEspecie $ "NF/NDC"
	oPrn:Box(03.2+nAjHead, 24, 06, 26)

	oPrn:Say(03+nAjHead, 38, aCopias[nNroCop], ARIAL_18B)
			
	oPrn:Say(05+nAjHead, 24.6, (cAliasQry)->F2_SERIE, ARIAL_20B)
	oPrn:Say(07+nAjHead, 24, STR0014, ARIAL_12)	
	oPrn:Say(08+nAjHead, 24.25, STR0015+(cAliasQry)->F2_RG1415, ARIAL_12)	

	For nX := 1 To Len(aEncab)
		oPrn:Say(IIf(nX==1, 6, 5)+nAjHead, 30, aEncab[nX], ARIAL_16B)
	Next nX 

	oPrn:Say(07+nAjHead, 30, STR0015 + Left((cAliasQry)->F2_DOC,nTamPDV)+"-"+Right((cAliasQry)->F2_DOC,8), ARIAL_16B)	

	oPrn:Say(09+nAjHead, 04, MemoLine(SM0->M0_NOMECOM,40,1), ARIAL_15)
	oPrn:Say(10+nAjHead, 04, MemoLine(SM0->M0_NOMECOM,40,2), ARIAL_15)
	oPrn:Say(11+nAjHead, 04, IIf(Empty(SM0->M0_ENDENT), STR0016, AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_CIDENT)), ARIAL_15)
	oPrn:Say(12+nAjHead, 04, STR0017+GetNewPar("MV_FATCEP",SM0->M0_CEPENT)+", "+SM0->M0_BAIRENT, ARIAL_15)
	oPrn:Say(13+nAjHead, 04, STR0018+GetNewPar("MV_FATTEL",SM0->M0_TEL), ARIAL_15)
	oPrn:Say(14+nAjHead, 04, GetNewPar("MV_FATTIP",STR0019), ARIAL_15)

	oPrn:Say(09+nAjHead, 31, STR0020 + DToC((cAliasQry)->F2_EMISSAO), ARIAL_15)		
	oPrn:Say(10+nAjHead, 31, STR0021 + SM0->M0_CGC, ARIAL_15)
	oPrn:Say(11+nAjHead, 31, STR0022 + SM0->M0_INSC, ARIAL_15)
	oPrn:Say(12+nAjHead, 31, GetNewPar("MV_FATINI",STR0023), ARIAL_15)
	oPrn:Say(13+nAjHead, 31, STR0024+cValToChar(nPag), ARIAL_15)
ElseIf cEspecie == "NCC"
	oPrn:Box(03.2+nAjHead, 24, 06, 26)

	oPrn:Say(03+nAjHead, 38, aCopias[nNroCop], ARIAL_18B)
			
	oPrn:Say(05+nAjHead, 24.6, (cAliasQry)->F1_SERIE, ARIAL_20B)
	oPrn:Say(07+nAjHead, 24, STR0014, ARIAL_12)	
	oPrn:Say(08+nAjHead, 24.25, STR0015+(cAliasQry)->F1_RG1415, ARIAL_12)	

	For nX := 1 To Len(aEncab)
		oPrn:Say(IIf(nX==1, 6, 5)+nAjHead, 30, aEncab[nX], ARIAL_16B)
	Next nX 

	oPrn:Say(07+nAjHead, 30, STR0015 + Left((cAliasQry)->F1_DOC,nTamPDV)+"-"+Right((cAliasQry)->F1_DOC,8), ARIAL_16B)	

	oPrn:Say(09+nAjHead, 04, MemoLine(SM0->M0_NOMECOM,40,1), ARIAL_15)
	oPrn:Say(10+nAjHead, 04, MemoLine(SM0->M0_NOMECOM,40,2), ARIAL_15)
	oPrn:Say(11+nAjHead, 04, IIf(Empty(SM0->M0_ENDENT), STR0016, AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_CIDENT)), ARIAL_15)
	oPrn:Say(12+nAjHead, 04, STR0017+GetNewPar("MV_FATCEP",SM0->M0_CEPENT)+", "+SM0->M0_BAIRENT, ARIAL_15)
	oPrn:Say(13+nAjHead, 04, STR0018+GetNewPar("MV_FATTEL",SM0->M0_TEL), ARIAL_15)
	oPrn:Say(14+nAjHead, 04, GetNewPar("MV_FATTIP",STR0019), ARIAL_15)

	oPrn:Say(09+nAjHead, 31, STR0020 + DToC((cAliasQry)->F1_EMISSAO), ARIAL_15)		
	oPrn:Say(10+nAjHead, 31, STR0021 + SM0->M0_CGC, ARIAL_15)
	oPrn:Say(11+nAjHead, 31, STR0022 + SM0->M0_INSC, ARIAL_15)
	oPrn:Say(12+nAjHead, 31, GetNewPar("MV_FATINI",STR0023), ARIAL_15)
	oPrn:Say(13+nAjHead, 31, STR0024+cValToChar(nPag), ARIAL_15)
Endif
//--------------
// 2do recuadro
//--------------
cTipoDoc := Substr(cTipoDoc, At("|", cTipoDoc)+1, Len(cTipoDoc)) 
oPrn:Box(aRecuad[2]+nAjHead, 02, aRecuad[3]+nAjHead, 47)

oPrn:Say(16+nAjHead, 04, STR0025 + LAYXTXT((cAliasQry)->A1_NOME) + ' (' + LAYXTXT((cAliasQry)->A1_COD) + ') ', ARIAL_15)
oPrn:Say(16+nAjHead, 31, cTipoDoc + ": "+ (cAliasQry)->A1_CGC , ARIAL_15)

oPrn:Say(17+nAjHead, 04, STR0026 + LAYXTXT((cAliasQry)->DESTIPO), ARIAL_15)
oPrn:Say(17+nAjHead, 31, STR0027 + LAYXTXT((cAliasQry)->E4_CODIGO) ,ARIAL_15)

oPrn:Say(18+nAjHead, 04, STR0028 + LAYXTXT((cAliasQry)->A1_END) + " - " + LAYXTXT((cAliasQry)->A1_MUN), ARIAL_15)
oPrn:Say(18+nAjHead, 31, STR0029+DToC(dVcto), ARIAL_15)

If cEspecie $ "NF/NDC"
	If !Empty((cAliasQry)->F2_FECDSE) .And. !Empty((cAliasQry)->F2_FECHSE)
		oPrn:Say(19+nAjHead, 04, STR0030+DToC((cAliasQry)->F2_FECDSE)+STR0031+DToC((cAliasQry)->F2_FECHSE)+" ", ARIAL_15)
	EndIf
ElseIf cEspecie == "NCC"
	If !Empty((cAliasQry)->F1_FECDSE) .And. !Empty((cAliasQry)->F1_FECHSE)
		oPrn:Say(19+nAjHead, 04, STR0030+DToC((cAliasQry)->F1_FECDSE)+STR0031+DToC((cAliasQry)->F1_FECHSE)+" ", ARIAL_15)
	EndIf
Endif
oPrn:Say(21+nAjHead, aPosIt[1], LAYFALIN(STR0032,"I",16)				, COURIER_11B)	// DESCRPCION
oPrn:Say(21+nAjHead, aPosIt[2], LAYFALIN(STR0033,"I", TAMDESC)	, COURIER_11B)	// DESCRPCION
oPrn:Say(21+nAjHead, aPosIt[3], LAYFALIN(STR0034,"D",12)				, COURIER_11B)	// CANTIDAD
oPrn:Say(21+nAjHead, aPosIt[4], LAYFALIN(STR0035,"I",4)					, COURIER_11B)	// UM
If Iif(cEspecie $ "NF/NDC",(cAliasQry)->F2_SERIE, (cAliasQry)->F1_SERIE) <> "B"
	oPrn:Say(21+nAjHead, aPosIt[5], LAYFALIN(STR0036,"D",15)		, COURIER_11B)	// PRECIO UNITARIO
	oPrn:Say(21+nAjHead, aPosIt[6], LAYFALIN(STR0037,"D",09)		, COURIER_11B)	// PRECIO UNITARIO
	oPrn:Say(21+nAjHead, aPosIt[7], LAYFALIN(STR0038,"D",15)		, COURIER_11B)	// PRECIO UNITARIO
	oPrn:Say(21+nAjHead, aPosIt[8], LAYFALIN(STR0039,"D",10)		, COURIER_11B)	// ALIQ
Else
	oPrn:Say(21+nAjHead, aPosIt[5], LAYFALIN(STR0036,"D",12)		, COURIER_11B)	// PRECIO UNITARIO
EndIf
oPrn:Say(21+nAjHead, aPosIt[9], LAYFALIN(STR0040,"D",22)			, COURIER_11B)	// TOTAL

oPrn:Line(22, 02, 22, 47)

Return Nil
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintItem บAutor  ณAndres Demarziani   บFecha ณ  31/10/17   บฑฑ
ฑฑศออออออออออฯออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PrintItem(nNroCop, nLin, nPag, aPosIt, aRecuad, aRecPedSC5, aRecRemSF2, oPrn, cAliasQry, cEspecie, nTipoDoc)

Local nFila 	:= 0
Local nAjItem	:= 0
Local cDescrip	:= AllTrim((cAliasQry)->B1_DESC)
Local nLenMemo
Local nL

Default nNroCop := 0
Default nLin := 0
Default nPag := 0
Default aPosIt := {}
Default aRecuad := {}
Default aRecPedSC5 := {}
Default aRecRemSF2 := {}
Default oPrn := Nil
Default cAliasQry := ''
Default cEspecie := ''
Default nTipoDoc := 0



If nLin > MAXLIN
	nLin := 1
	nPag++
	oPrn:EndPage()
	PrintHead(nNroCop, nPag, nTipoDoc, aPosIt, aRecuad, oPrn, cAliasQry, cEspecie)
EndIf

nFila 		:= nLin+22
nLenMemo 	:= MLCount(cDescrip, TAMDESC)

If cEspecie $ "NF/NDC"
	For nL := 1 To nLenMemo
		If nL == 1
			oPrn:Say(nFila+nAjItem, aPosIt[1], LAYFALIN((cAliasQry)->D2_COD,"I",16)									, COURIER_11)	// CODIGO
			oPrn:Say(nFila+nAjItem, aPosIt[2], LAYFALIN(MemoLine(cDescrip, TAMDESC, nL),"I",TAMDESC)	, COURIER_11)	// DESCRPCION
			oPrn:Say(nFila+nAjItem, aPosIt[3], LAYFALIN((cAliasQry)->D2_QUANT,"D",12) 								, COURIER_11)	// CANTIDAD
			oPrn:Say(nFila+nAjItem, aPosIt[4], LAYFALIN((cAliasQry)->D2_UM,"I",4) 									, COURIER_11)	// UNIDAD DE MEDIDA
			If (cAliasQry)->F2_SERIE <> "B"
				oPrn:Say(nFila+nAjItem, aPosIt[5], LAYFALIN((cAliasQry)->D2_PRCVEN,"D",15)							, COURIER_11)	// PRECIO UNITARIO
				oPrn:Say(nFila+nAjItem, aPosIt[6], LAYFALIN((cAliasQry)->D2_DESC,"D",9)							, COURIER_11)	// BONIF
				oPrn:Say(nFila+nAjItem, aPosIt[7], LAYFALIN((cAliasQry)->D2_TOTAL,"D",15)								, COURIER_11)	// SUBTOTAL
				oPrn:Say(nFila+nAjItem, aPosIt[8], LAYFALIN((cAliasQry)->DALQITEM,"D",10)							, COURIER_11)	// ALQ
			Else
				oPrn:Say(nFila+nAjItem, aPosIt[5], LAYFALIN((cAliasQry)->D2_PRCVEN+(DVALITEM/(cAliasQry)->D2_QUANT),"D",15)			, COURIER_11)	// PRECIO UNITARIO
				oPrn:Say(nFila+nAjItem, aPosIt[6], LAYFALIN((cAliasQry)->D2_DESC,"D",9)							, COURIER_11)	// BONIF
			EndIf

			oPrn:Say(nFila+nAjItem, aPosIt[9], LAYFALIN((cAliasQry)->D2_TOTAL+DVALITEM,"D",22)						, COURIER_11)	// TOTAL.
		EndIf
	Next nL
ElseIf cEspecie == "NCC"
	For nL := 1 To nLenMemo
		If nL == 1
			oPrn:Say(nFila+nAjItem, aPosIt[1], LAYFALIN((cAliasQry)->D1_COD,"I",16)									, COURIER_11)	// CODIGO
			oPrn:Say(nFila+nAjItem, aPosIt[2], LAYFALIN(MemoLine(cDescrip, TAMDESC, nL),"I",TAMDESC)	, COURIER_11)	// DESCRPCION
			oPrn:Say(nFila+nAjItem, aPosIt[3], LAYFALIN((cAliasQry)->D1_QUANT,"D",12) 								, COURIER_11)	// CANTIDAD
			oPrn:Say(nFila+nAjItem, aPosIt[4], LAYFALIN((cAliasQry)->D1_UM,"I",4) 									, COURIER_11)	// UNIDAD DE MEDIDA
			If (cAliasQry)->F1_SERIE <> "B"
				oPrn:Say(nFila+nAjItem, aPosIt[5], LAYFALIN((cAliasQry)->D1_VUNIT,"D",15)							, COURIER_11)	// PRECIO UNITARIO
				oPrn:Say(nFila+nAjItem, aPosIt[6], LAYFALIN((cAliasQry)->D1_DESC,"D",9)							, COURIER_11)	// BONIF
				oPrn:Say(nFila+nAjItem, aPosIt[7], LAYFALIN((cAliasQry)->D1_TOTAL,"D",15)								, COURIER_11)	// SUBTOTAL
				oPrn:Say(nFila+nAjItem, aPosIt[8], LAYFALIN((cAliasQry)->DALQITEM,"D",10)							, COURIER_11)	// ALQ
			Else
				oPrn:Say(nFila+nAjItem, aPosIt[5], LAYFALIN((cAliasQry)->D1_VUNIT+(DVALITEM/(cAliasQry)->D1_QUANT),"D",15)			, COURIER_11)	// PRECIO UNITARIO
				oPrn:Say(nFila+nAjItem, aPosIt[6], LAYFALIN((cAliasQry)->D1_DESC,"D",9)							, COURIER_11)	// BONIF
			EndIf

			oPrn:Say(nFila+nAjItem, aPosIt[9], LAYFALIN((cAliasQry)->D1_TOTAL+DVALITEM,"D",22)						, COURIER_11)	// TOTAL.
		EndIf
	Next nL
Endif

fCargaRec(aRecPedSC5, aRecRemSF2, cAliasQry, cEspecie)

Return Nil
	
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintFoot บAutor  ณAndres Demarziani   บFecha ณ  31/10/17   บฑฑ
ฑฑศออออออออออฯออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PrintFoot(nNroCop, nPag, lQRAFIP, lQRJAVA, aRecuad, aRecPedSC5, oPrn, cEspecie, cAliasQry)

Local cCodBar 		:= ""
Local cSimbPes		:= GetMv("MV_SIMB1")
Local cSimbFact		:= GetMv("MV_SIMB"+cValToChar(IIF(cEspecie $ "NF/NDC", (cAliasQry)->F2_MOEDA, (cAliasQry)->F1_MOEDA)))
Local cOCCli		:= ""
Local nTotPed		:= Len(aRecPedSC5)
Local nIniObs		:= 38
Local aObsPed		:= {}
Local nWidth		:= 500
Local aImpIzq		:= {}
Local aImpDer		:= {}
Local nAjFoot		:= -1
Local nX
Local nMax
Local ccampo := ''
Local totIB := 0
Local cValImp := ''
Local aArea := GetArea()

Default nNroCop := 0
Default nPag := 0
Default lQRAFIP := .F.
Default lQRJAVA := .F.
Default aRecuad := {}
Default aRecPedSC5 := {}
Default oPrn := Nil
Default cEspecie := ''
Default cAliasQry := ''

//--------------
// 4to recuadro
//--------------
// Footer
//--------------
oPrn:Line(aRecuad[4]+nAjFoot, 02, aRecuad[4]+nAjFoot, 47 )

If IIF(cEspecie $ "NF/NDC", (cAliasQry)->F2_RG1415, (cAliasQry)->F1_RG1415) > "200"
	aAdd(aObsPed, STR0041+GetNewPar("MV_CCBUCFE",STR0043))
	aAdd(aObsPed, STR0042+GetNewPar("MV_CBUALI",STR0044))
	aAdd(aObsPed, "")
EndIf

If !Empty(nTotPed)
	For nX := 1 To nTotPed
		SC5->(dbGoTo(aRecPedSC5[nX]))
		If SC5->(FieldPos("C5_XOCCLI")) > 0
			cOCCli += IIf(Empty(cOCCli),"","/")+AllTrim(SC5->C5_XOCCLI)
		EndIf
		If !Empty(SC5->C5_MENNOTA)
			aAdd(aObsPed, "Obs. PV "+SC5->C5_NUM+": "+AllTrim(SC5->C5_MENNOTA))
		EndIf
	Next nX
EndIf

If !Empty(cOCCli)
	aAdd(aObsPed, STR0045+cOCCli)
EndIf

For nX := 1 To Len(aObsPed)
	oPrn:Say(nIniObs+nAjFoot, 04, aObsPed[nX], COURIER_12)
	nIniObs++
Next nX

aSFB := BuscaSFB()
cValImp := IIF(cEspecie $ "NF/NDC", '(cAliasQry)->F2_VALIMP','(cAliasQry)->F1_VALIMP')

If AllTrim(IIF(cEspecie $ "NF/NDC",SubStr((cAliasQry)->F2_SERIE,1,1), SubStr((cAliasQry)->F1_SERIE,1,1))) == "A"
	//------------
	// Izquierda
	//------------
	If aSFB[1][1][1][2] == 'PGA'
		ccampo := cValImp+aSFB[1][1][1][4]
		aAdd(aImpIzq, {STR0046, &ccampo, ARIAL_15})	
	EndIf

	If aSFB[1][2][1][2] == 'IVP'
		ccampo := cValImp+aSFB[1][2][1][4]
		aAdd(aImpIzq, {STR0047, &ccampo, ARIAL_15})	
	EndIf

	for nX := 1 to len(aSFB[1][4])
		ccampo := cValImp+aSFB[1][4][nX][4]
		if !Empty(&ccampo)
			totIB += &ccampo
		Endif
	Next nX
	aAdd(aImpIzq, {STR0048, totIB, ARIAL_15})
	
	//------------
	// Derecha
	//------------	
	aAdd(aImpDer, {STR0049, IIF(cEspecie $ "NF/NDC", (cAliasQry)->F2_VALMERC, (cAliasQry)->F1_VALMERC), ARIAL_15})

	DbSelectArea("SFC")
	SFC->(DbSeek(xFilial("SFC")+ IIF(cEspecie $ "NF/NDC",(cAliasQry)->D2_TES,(cAliasQry)->D1_TES)))
	nX := 1
	while SFC->FC_TES == IIF(cEspecie $ "NF/NDC",(cAliasQry)->D2_TES,(cAliasQry)->D1_TES) .and. !SFC->(EOF())
		if SubStr(SFC->FC_IMPOSTO,1,2) == 'IV'
			if aSFB[1][3][nX][2] == SFC->FC_IMPOSTO
				ccampo := cValImp+aSFB[1][3][nX][4]
				aAdd(aImpDer, {aSFB[1][3][nX][1], &ccampo, ARIAL_15})
			endif
		endif
		SFC->(DbSkip())
		nX += 1
	EndDo

	SFC->(DBCloseArea())

	aAdd(aImpDer, {Nil, Nil, Nil})
Else
	aAdd(aImpDer, {STR0049, IIF(cEspecie $ "NF/NDC", (cAliasQry)->F2_VALMERC, (cAliasQry)->F1_VALMERC), ARIAL_15})
	for nX := 1 to len(aSFB[1][4])
		ccampo := cValImp+aSFB[1][4][nX][4]
		if !Empty(&ccampo)
			totIB += &ccampo
		Endif
	Next nX
	aAdd(aImpIzq, {STR0048, totIB, ARIAL_15})
EndIf

aAdd(aImpDer, {STR0053, IIF(cEspecie $ "NF/NDC",(cAliasQry)->F2_VALBRUT, (cAliasQry)->F1_VALBRUT), ARIAL_15B})

//----------------------------------------
// Imprimo Textos alineados a la izquierda
// que corresponden percepciones
//----------------------------------------
nMax := 51

For nX := Len(aImpIzq) To 1 Step -1
	If aImpIzq[nX][1] != Nil
		oPrn:SayAlign(nMax+nAjFoot, 04.0, aImpIzq[nX][1], aImpIzq[nX][3], nWidth, 0)
		oPrn:SayAlign(nMax+nAjFoot, 10.5, cSimbFact+" "+LAYFALIN(aImpIzq[nX][2],"D",aImpIzq[nX][3]), aImpIzq[nX][3], nWidth, 1)
	EndIf

	nMax--
Next nX

//----------------------------------------
// Imprimo Textos alineados a la derecha
// que corresponden a subtotales e IVA
//----------------------------------------
nMax := 53

For nX := Len(aImpDer) To 1 Step -1
	If aImpDer[nX][1] != Nil
		oPrn:SayAlign(nMax+nAjFoot, 30.0, aImpDer[nX][1], aImpDer[nX][3], nWidth, 0)
		oPrn:SayAlign(nMax+nAjFoot, 36.5, cSimbFact+" "+LAYFALIN(aImpDer[nX][2],"D",aImpDer[nX][3]), aImpDer[nX][3], nWidth, 1)
	EndIf

	nMax--
Next nX

If cEspecie $ "NF/NDC"
	If (cAliasQry)->F2_MOEDA > 1
		oPrn:Say(55+nAjFoot, 04, STR0054+cSimbPes+LAYFALIN((cAliasQry)->F2_TXMOEDA,"D",20), COURIER_12)
	EndIf
	oPrn:Say(56+nAjFoot, 04, STR0055, COURIER_12)
	oPrn:Say(57+nAjFoot, 04, UPPER(Extenso((cAliasQry)->F2_VALBRUT,,(cAliasQry)->F2_MOEDA)), COURIER_12)

	oPrn:Say(59+nAjFoot, 30, STR0056+(cAliasQry)->F2_CAEE, ARIAL_15)
	oPrn:Say(60+nAjFoot, 30, STR0057+DToC((cAliasQry)->F2_EMCAEE), ARIAL_15)

	If lQRAFIP
		//Crea objeto ArQrAFIP
		oQRCode:= ArQrAFIP():New()
		
		//Obtiene string requerido por AFIP en formato JSON (url fija y datos comprobante codificados en base 64)
		cCodQR:= oQRCode:LayCodeQR((cAliasQry)->A1_COD,,(cAliasQry)->A1_CGC,cEspecie,(cAliasQry)->F2_RG1415, (cAliasQry)->F2_EMISSAO,(cAliasQry)->F2_DOC, (cAliasQry)->F2_CAEE, (cAliasQry)->F2_EMCAEE, (cAliasQry)->F2_MOEDA, (cAliasQry)->F2_TXMOEDA, (cAliasQry)->F2_VALBRUT)
		
		//Genera imagen QR con texto , si la clase es FwMsPrinter o ARPrinter
		oPrn:QRCode(64.8+nAjFoot, 05, cCodQR, 85)
		
		//QRJAVA
		If lQRJAVA
			//Si es TmsPrinter o tiene desactualizado Protheus, generamos imagen con clase JAVA
			oQRJava:=ArQrJava():New()
			cClaveQr:= xFilial("SF2")+"-"+cEspecie+"-"+(cAliasQry)->A1_COD+"-"+(cAliasQry)->F2_DOC
			//Genera archivo de texto Local en carpeta de framewok JAVA y luego lo copia al server Protheus
			lRet := oQRJava:setTxt(cClaveQr,cCodQR)
			//Genera imagen QR en formato bmp Local y la copia al server de Protheus
			lRet := oQRJava:setBmp()
			//Imprime imagen tomandola desde el server, previamente ya se copio al server en Protheus Data
			oPrn:SayBitmap(57+nAjFoot, 05, oQRJava:cBmp, 350, 350 )
		EndIf
	Else
		cCodBar := LAYCBAR((cAliasQry)->F2_RG1415, (cAliasQry)->F2_DOC, (cAliasQry)->F2_EMCAEE, cAliasQry, cEspecie) //Codigo de barra tradicional
		oPrn:CodBar(cCodBar, 69+nAjFoot, 4)
		oPrn:Say(64.8+nAjFoot, 05, cCodBar, COURIER_12)
	EndIf
ElseIf cEspecie == "NCC"
	If (cAliasQry)->F1_MOEDA > 1
		oPrn:Say(55+nAjFoot, 04, "Tipo de cambio: "+cSimbPes+LAYFALIN((cAliasQry)->F1_TXMOEDA,"D",20), COURIER_12)
	EndIf
	oPrn:Say(56+nAjFoot, 04, "Son: ", COURIER_12)
	oPrn:Say(57+nAjFoot, 04, UPPER(Extenso((cAliasQry)->F1_VALBRUT,,(cAliasQry)->F1_MOEDA)), COURIER_12)

	oPrn:Say(59+nAjFoot, 30, "CAE: "+(cAliasQry)->F1_CAEE, ARIAL_15)
	oPrn:Say(60+nAjFoot, 30, "Vencimiento CAE: "+DToC((cAliasQry)->F1_EMCAEE), ARIAL_15)

	If lQRAFIP
		//Crea objeto ArQrAFIP
		oQRCode:= ArQrAFIP():New()
		
		//Obtiene string requerido por AFIP en formato JSON (url fija y datos comprobante codificados en base 64)
		cCodQR:= oQRCode:LayCodeQR((cAliasQry)->A1_COD,,(cAliasQry)->A1_CGC,cEspecie,(cAliasQry)->F1_RG1415, (cAliasQry)->F1_EMISSAO,(cAliasQry)->F1_DOC, (cAliasQry)->F1_CAEE, (cAliasQry)->F1_EMCAEE, (cAliasQry)->F1_MOEDA, (cAliasQry)->F1_TXMOEDA, (cAliasQry)->F1_VALBRUT)
		
		//Genera imagen QR con texto , si la clase es FwMsPrinter o ARPrinter
		oPrn:QRCode(64.8+nAjFoot, 05, cCodQR, 85)
		
		//QRJAVA
		If lQRJAVA
			//Si es TmsPrinter o tiene desactualizado Protheus, generamos imagen con clase JAVA
			oQRJava:=ArQrJava():New()
			cClaveQr:= xFilial("SF1")+"-"+cEspecie+"-"+(cAliasQry)->A1_COD+"-"+(cAliasQry)->F1_DOC
			//Genera archivo de texto Local en carpeta de framewok JAVA y luego lo copia al server Protheus
			lRet := oQRJava:setTxt(cClaveQr,cCodQR)
			//Genera imagen QR en formato bmp Local y la copia al server de Protheus
			lRet := oQRJava:setBmp()
			//Imprime imagen tomandola desde el server, previamente ya se copio al server en Protheus Data
			oPrn:SayBitmap(57+nAjFoot, 05, oQRJava:cBmp, 350, 350 )
		EndIf
	Else
		cCodBar := LAYCBAR((cAliasQry)->F1_RG1415, (cAliasQry)->F1_DOC, (cAliasQry)->F1_EMCAEE, cAliasQry, cEspecie) //Codigo de barra tradicional
		oPrn:CodBar(cCodBar, 69+nAjFoot, 4)
		oPrn:Say(64.8+nAjFoot, 05, cCodBar, COURIER_12)
	EndIf
Endif

oPrn:EndPage()

RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfArmaDatosบAutor  ณAndres Demarziani   บFecha ณ  31/10/17   บฑฑ
ฑฑศออออออออออฯออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fArmaDatos(oObQuery, cEspecie, cNtxTmp, cDbfTmp, cAliasQry)

Local aImps		:= {}
Local nX		:= 1
Local cDeSerie := oObQuery['DeSerie']
Local cASerie := oObQuery['ASerie']
Local dDeFecha := oObQuery['DeFecha']
Local dAFecha := oObQuery['AFecha']
Local cDeDoc := oObQuery['DeDoc']
Local cADoc := oObQuery['ADoc']
Local cDeCli := oObQuery['DeCli']
Local cACli := oObQuery['ACli']
Local cDeLoja := oObQuery['DeLoja']
Local cALoja := oObQuery['ALoja']
Local cImps := ''

Default oObQuery := Nil
Default cEspecie := ''
Default cNtxTmp := ''
Default cDbfTmp := ''
Default cAliasQry := ''

dbSelectArea("SFB")
dbSetOrder(1)
dbGoTop()
While !Eof()
	If !Empty(FB_CPOLVRO) .And. aScan(aImps, {|x| x[2] == AllTrim(FB_CPOLVRO)}) == 0
		aAdd(aImps, {AllTrim(FB_CODIGO), AllTrim(FB_CPOLVRO)})
	EndIf
	dbSkip()
EndDo

If cEspecie $ "NF/NDC"

	cImps := "%"
	For nX := 1 To Len(aImps)	
		cImps += "F2_BASIMP"+aImps[nX][2]+", "
		cImps += "F2_VALIMP"+aImps[nX][2]+", "
		cImps += "D2_ALQIMP"+aImps[nX][2]+", "
		cImps += "D2_VALIMP"+aImps[nX][2]+", "	
	Next nX
	cImps += "%"

	BeginSql alias cAliasQry

		SELECT SF2.F2_DOC, 
		SF2.F2_SERIE, 
		SF2.F2_ESPECIE, 
		SF2.F2_RG1415, 
		SA1.A1_COD, 
		SA1.A1_LOJA, 
		SA1.A1_NOME, 
		SA1.A1_END, 
		SA1.A1_MUN,  
		TPDOC.X5_DESCSPA AS TIPODOC,
		SA1.A1_CGC, 
		SA1.A1_EST, 
		PROVENT.X5_DESCSPA, 
		SA1.A1_TIPO, 
		TPCLI.X5_DESCSPA AS DESTIPO, 
		SE4.E4_CODIGO, 
		SE4.E4_DESCRI, 
		SF2.F2_EMISSAO, 
		SF2.F2_PROVENT, 
		PROVENT.X5_DESCSPA,
		SF2.F2_TXMOEDA, 
		SF2.F2_MOEDA, 
		SF2.F2_CAEE, 
		SF2.F2_EMCAEE, 
		SF2.F2_VALBRUT,
		SF2.F2_VALMERC, 
		SF2.F2_DESCONT, 
		SF2.F2_DESPESA, 
		SF2.F2_FECDSE, 
		SF2.F2_FECHSE,
		SD2.D2_ITEM, 
		SD2.D2_COD, 
		SB1.B1_DESC, 
		SD2.D2_UM, 
		SD2.D2_TES,
		SD2.D2_CF, 
		SD2.D2_QUANT, 
		SD2.D2_PRCVEN, 
		SD2.D2_PRUNIT, 
		SD2.D2_DESC, 
		SD2.D2_DESCON,
		SD2.D2_TOTAL, 
		%exp:cImps% 
		SD2.D2_PEDIDO, 
		SD2.D2_ITEMPV, 
		SD2.D2_SERIREM, 
		SD2.D2_REMITO, 
		SD2.D2_ITEMREM;
		FROM %table:SF2% SF2 
			INNER JOIN %table:SD2% SD2
				ON SD2.D2_FILIAL = SF2.F2_FILIAL
					AND SD2.D2_DOC = SF2.F2_DOC
					AND SD2.D2_SERIE  = SF2.F2_SERIE  
					AND SD2.D2_CLIENTE = SF2.F2_CLIENTE  
					AND SD2.D2_LOJA = SF2.F2_LOJA  
					AND SD2.D2_COD > ''  
					AND SD2.D2_ITEM > ''  
					AND SD2.D2_ESPECIE = SF2.F2_ESPECIE
					AND SD2.%notdel% 
			INNER JOIN %table:SB1% SB1
				ON SB1.B1_FILIAL = %Exp:(xFilial("SB1"))%
					AND SB1.B1_COD = SD2.D2_COD  
					AND SB1.%notdel%
			INNER JOIN %table:SA1% SA1
				ON SA1.A1_FILIAL = %Exp:(xFilial("SA1"))%
					AND SA1.A1_COD = SF2.F2_CLIENTE 
					AND SA1.A1_LOJA = SF2.F2_LOJA   
					AND SA1.%notdel% 
			INNER JOIN %table:SE4% SE4
				ON SE4.E4_FILIAL = %Exp:(xFilial("SE4"))%
					AND SE4.E4_CODIGO = SF2.F2_COND 
					AND SE4.%notdel%
			INNER JOIN %table:SX5% TPCLI
				ON TPCLI.X5_FILIAL = %Exp:(xFilial("SX5"))%
					AND TPCLI.X5_TABELA = 'SF'
					AND TPCLI.X5_CHAVE = SA1.A1_TIPO 
					AND TPCLI.%notdel%
			INNER JOIN %table:SX5% TPDOC
				ON TPDOC.X5_FILIAL = %Exp:(xFilial("SX5"))%
					AND TPDOC.X5_TABELA = 'OC' 
					AND TPDOC.X5_CHAVE = SA1.A1_AFIP 
					AND TPDOC.%notdel%
			INNER JOIN %table:SX5% PROVENT
				ON PROVENT.X5_FILIAL = %Exp:(xFilial("SX5"))%
					AND PROVENT.X5_TABELA = '12' 
					AND PROVENT.X5_CHAVE = SF2.F2_PROVENT 
					AND PROVENT.%notdel%
		WHERE SF2.F2_FILIAL = %Exp:(xFilial("SF2"))%
			AND SF2.F2_SERIE BETWEEN %exp:cDeSerie% AND %exp:cASerie% 
			AND SF2.F2_EMISSAO BETWEEN %exp:dDeFecha% AND %exp:dAFecha%
			AND SF2.F2_DOC BETWEEN %exp:cDeDoc% AND %exp:cADoc%
			AND SF2.F2_CLIENTE BETWEEN %exp:cDeCli% AND %exp:cACli% 
			AND SF2.F2_LOJA BETWEEN %exp:cDeLoja% AND %exp:cALoja%
			AND SF2.%notdel%
			AND SF2.F2_ESPECIE = %exp:cEspecie%
			ORDER BY SF2.F2_SERIE,SF2.F2_DOC,SA1.A1_COD,SF2.F2_ESPECIE,SD2.D2_ITEM
	Endsql
ElseIf cEspecie == "NCC"

	cImps := "%"
	For nX := 1 To Len(aImps)	
		cImps += "F1_BASIMP"+aImps[nX][2]+", "
		cImps += "F1_VALIMP"+aImps[nX][2]+", "
		cImps += "D1_ALQIMP"+aImps[nX][2]+", "
		cImps += "D1_VALIMP"+aImps[nX][2]+", "	
	Next nX
	cImps += "%"

	BeginSql Alias cAliasQry
		SELECT SF1.F1_DOC,
		SF1.F1_SERIE,
		SF1.F1_SERIE,
		SF1.F1_RG1415,
		SF1.F1_ESPECIE,
		SA1.A1_COD ,
		SA1.A1_LOJA,
		SA1.A1_NOME ,
		SA1.A1_END,
		SA1.A1_MUN,
		TPDOC.X5_DESCSPA AS TIPODOC, 
		SA1.A1_CGC,
		SA1.A1_EST,
		PROVCLI.X5_DESCSPA,
		SA1.A1_TIPO,
		TPCLI.X5_DESCSPA AS DESTIPO ,
		SE4.E4_CODIGO,
		SE4.E4_DESCRI ,
		SF1.F1_EMISSAO,
		SF1.F1_PROVENT ,
		PROVENT.X5_DESCSPA,
		SF1.F1_TXMOEDA,
		SF1.F1_MOEDA ,
		SF1.F1_CAEE ,
		SF1.F1_EMCAEE ,
		SF1.F1_VALBRUT ,
		SF1.F1_VALMERC ,
		SF1.F1_DESCONT ,
		SF1.F1_DESPESA ,
		SF1.F1_FECDSE ,
		SF1.F1_FECHSE,
		SD1.D1_ITEM,
		SD1.D1_COD,
		SB1.B1_DESC ,
		SD1.D1_UM ,
		SD1.D1_TES,
		SD1.D1_CF ,
		SD1.D1_QUANT ,
		SD1.D1_VUNIT,
		SD1.D1_VUNIT ,
		SD1.D1_DESC ,
		SD1.D1_VALDESC ,
		%exp:cImps%
		SD1.D1_TOTAL ,
		SD1.D1_PEDIDO,
		SD1.D1_REMITO,
		SD1.D1_SERIREM
		FROM %table:SF1% SF1 
			INNER JOIN %table:SD1% SD1 
				ON SD1.D1_FILIAL = SF1.F1_FILIAL   
					AND SD1.D1_DOC = SF1.F1_DOC
					AND SD1.D1_SERIE = SF1.F1_SERIE 
					AND SD1.D1_FORNECE = SF1.F1_FORNECE 
					AND SD1.D1_LOJA = SF1.F1_LOJA 
					AND SD1.D1_COD > ''  
					AND SD1.D1_ITEM > ''  
					AND SD1.%notdel%
					AND SD1.D1_ESPECIE = SF1.F1_ESPECIE  
			INNER JOIN %table:SB1% SB1
				ON SB1.B1_FILIAL = %Exp:(xFilial("SB1"))% 
					AND SB1.B1_COD = SD1.D1_COD  
					AND SB1.%notdel% 
			INNER JOIN %table:SA1% SA1  
				ON SA1.A1_FILIAL = %Exp:(xFilial("SA1"))% 
					AND SA1.A1_COD = SF1.F1_FORNECE 
					AND SA1.A1_LOJA = SF1.F1_LOJA  
					AND SA1.%notdel%
			INNER JOIN %table:SE4% SE4 
				ON SE4.E4_FILIAL = %Exp:(xFilial("SE4"))%
					AND SE4.E4_CODIGO = SF1.F1_COND  
					AND SE4.%notdel% 
			LEFT JOIN %table:SX5% TPCLI
				ON TPCLI.X5_FILIAL = %Exp:(xFilial("SX5"))%
					AND TPCLI.X5_TABELA = 'SF' 
					AND TPCLI.X5_CHAVE = A1_TIPO 
					AND TPCLI.%notdel% 
			LEFT JOIN %table:SX5% TPDOC 
				ON TPDOC.X5_FILIAL = %Exp:(xFilial("SX5"))%
					AND TPDOC.X5_TABELA = 'OC' 
					AND TPDOC.X5_CHAVE = A1_AFIP 
					AND TPDOC.%notdel%		
			LEFT JOIN %table:SX5% PROVCLI
				ON PROVCLI.X5_FILIAL = %Exp:(xFilial("SX5"))%
					AND PROVCLI.X5_TABELA = '12' 
					AND PROVCLI.X5_CHAVE = A1_EST 
					AND PROVCLI.%notdel%
			LEFT JOIN %table:SX5% PROVENT
				ON PROVENT.X5_FILIAL = %Exp:(xFilial("SX5"))%
					AND PROVENT.X5_TABELA = '12' 
					AND PROVENT.X5_CHAVE = F1_PROVENT
					AND PROVENT.%notdel% 
			WHERE SF1.F1_FILIAL = %Exp:(xFilial("SF2"))%
				AND SF1.F1_ESPECIE = %exp:cEspecie%
				AND SF1.F1_DOC BETWEEN %exp:cDeDoc% AND %exp:cADoc%
				AND SF1.F1_SERIE BETWEEN %exp:cDeSerie% AND %exp:cASerie%
				AND SF1.F1_EMISSAO BETWEEN %exp:dDeFecha% AND %exp:dAFecha%
				AND SF1.F1_FORNECE BETWEEN %exp:cDeCli% AND %exp:cACli% 
				AND SF1.F1_LOJA BETWEEN %exp:cDeLoja% AND %exp:cALoja%
				AND SF1.%notdel%
	EndSql	
Endif

aCampos := (cAliasQry)->(dbStruct())
For nX := 1 To Len(aCampos)
	If !(aCampos[nX,1] $ "TIPODOC|DESTIPO")
		aCampos[nX,2] := GetSX3Cache(aCampos[nX,1],"X3_TIPO")
		aCampos[nX,3] := GetSX3Cache(aCampos[nX,1],"X3_TAMANHO")
		aCampos[nX,4] := GetSX3Cache(aCampos[nX,1],"X3_DECIMAL")
		TCSetField(cAliasQry, aCampos[nX,1], aCampos[nX,2], aCampos[nX,3], aCampos[nX,4])
	EndIf
Next

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfCargaRec บAutor  ณAndres Demarziani   บFecha ณ  31/10/17   บฑฑ
ฑฑศออออออออออฯออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fCargaRec(aRecPedSC5, aRecRemSF2, cAliasQry, cEspecie)

Default aRecPedSC5 := {}
Default aRecRemSF2 := {}
Default cAliasQry := ''
Default cEspecie := ''


If !Empty(Iif(cEspecie $ "NF/NDC",(cAliasQry)->D2_PEDIDO, (cAliasQry)->D1_PEDIDO))
	If SC5->(MsSeek(xFilial("SC5")+Iif(cEspecie $ "NF/NDC",(cAliasQry)->D2_PEDIDO, (cAliasQry)->D1_PEDIDO)))
		If aScan(aRecPedSC5, {|x| x == SC5->(Recno())}) == 0
			aAdd(aRecPedSC5, SC5->(Recno()))
		EndIf
	EndIf
EndIf

If !Empty(Iif(cEspecie $ "NF/NDC",(cAliasQry)->D2_REMITO, (cAliasQry)->D1_REMITO))
	If cEspecie $ "NF/NDC"
		If SF2->(MsSeek(xFilial("SF2")+(cAliasQry)->(D2_REMITO+D2_SERIREM+A1_COD+A1_LOJA)))
			If aScan(aRecRemSF2, {|x| x == SF2->(Recno())}) == 0
				aAdd(aRecRemSF2, SF2->(Recno()))
			EndIf
		EndIf
	ElseIf cEspecie == "NCC"
		If SF1->(MsSeek(xFilial("SF1")+(cAliasQry)->(D1_REMITO+D1_SERIREM+A1_COD+A1_LOJA)))
			If aScan(aRecRemSF2, {|x| x == SF1->(Recno())}) == 0
				aAdd(aRecRemSF2, SF1->(Recno()))
			EndIf
		EndIf
	Endif
EndIf

Return Nil
