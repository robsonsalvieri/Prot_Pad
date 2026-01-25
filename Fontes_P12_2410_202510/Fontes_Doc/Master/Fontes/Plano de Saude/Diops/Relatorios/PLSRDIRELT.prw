#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PLSRDIRELT.CH"
#INCLUDE "FWPrintSetup.ch"

#Define Moeda "@E 999,999,999.99"

STATIC oFnt10C 		:= TFont():New("Arial",10,10,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",10,10,,.T., , , , .t., .f.)
STATIC oFnt11N 		:= TFont():New("Arial",11,11,,.T., , , , .t., .f.)
STATIC oFnt09C 		:= TFont():New("Arial",9,9,,.f., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRDIRELT

Relatório de Idade de Saldos a Receber
@author Renan Martins
@since 01/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSRDIRELT(aDadosG,aDadosPDD)
Local oReport		:= nil
Local oImpres		:= nil
Local cFileName	:= "idade_saldos_receber"+CriaTrab(NIL,.F.)
Local cDirPath	:= lower(getMV("MV_RELT"))
Local lWeb			:= .F.
DEFAULT aDadosG	:= {}

oReport := FWMSPrinter():New(cFileName,IMP_PDF,.f.,nil,.T.,nil,oReport,nil,nil,.f.,.f.,.t.)

oReport:lInJob  	:= lWeb
oReport:lServer 	:= lWeb
oReport:cPathPDF	:= cDirPath

oReport:setDevice(IMP_PDF)
oReport:setResolution(72)
oReport:SetLandscape()
oReport:SetPaperSize(9)
oReport:setMargin(10,10,10,10)

oReport:Setup()

If (oReport:nModalResult == 1 )  //PD_OK - Pressionado OK na janela
	lRet := PLSDIDIDA(oReport,aDadosG,aDadosPDD)
	
	if lRet
		aRet := {cFileName+".pdf",""}
	else
		aRet := {"",""}
	endif
	
	IF (lRet)
		oReport:EndPage()
		oReport:Print()
	ENDIF	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Checa se o arquivo PDF esta ponto para visualizacao na web 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lWeb
	PLSCHKRP(cDirPath, cFileName+".pdf")
endIf



Return(aRet)


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSDIDIDA

Preenchimento das colunas do relatório
@author Renan Martins
@since 02/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSDIDIDA(oReport,aDadosG,aDadPDD)
LOCAL cMsg			:= ""
LOCAL lRet			:= .T.
Local nI			:= 0
Local nJ			:= 0
Local nSom			:= 0
Local nLinha		:= 0
Local nTotLin		:= 0
Local nSubTotlin	:= 0
Local nTotPDD		:= 0
Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro

oReport:StartPage()

//Logotipo ANS
cBMP	:= "lgdiopsidr.bmp"

If File("lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp")
	cBMP :=  "lgdiopsidr" + FWGrpCompany() + FWCodFil() + ".bmp" 
ElseIf File("lgdiopsidr" + FWGrpCompany() + ".bmp")
	cBMP :=  "lgdiopsidr" + FWGrpCompany() + ".bmp" 
EndIf

oReport:box(30, 20, 365, 805 )  //Box principal
oReport:box(30, 20, 100, 805)	//Box Titulo
oReport:Say(75, 300, STR0001, oFnt14N)  //"DISTRIBUIÇÃO DOS SALDOS DE CONTAS A RECEBER"

oReport:SayBitmap(40, 25, cBMP, , 50,150)

oReport:box(100, 20, 200, 135) //Box Vencimento Financeiro
oReport:Say(160, 60, STR0034, oFnt11N)  //"Vencimento"
oReport:Say(175, 60, STR0035, oFnt11N)	 //"Financeiro"

oReport:Line(120, 725, 120, 135)	
oReport:Say(115, 300, STR0002, oFnt10c) //"Créditos de Operações com Planos de Saúde - (Subgrupo 123)"

oReport:Line(135, 500, 135, 135)	
oReport:Say(130, 160, STR0003, oFnt10c)  //"Contraprestação Pecuniária/Prêmios a Receber"	

oReport:Say(145, 160, STR0004, oFnt10c)  //"Mensalidades/Faturas/Seguros a Receber"	

oReport:box(150, 135, 175 , 275)   //144
oReport:Say(160, 140, STR0005, oFnt10c)	//"Planos Individuais/Familiares"
oReport:Say(170, 140, STR0006, oFnt10c)	//"Mensalidades (Pess. Física)"


oReport:box(150, 275, 175, 415) 
oReport:Say(160, 280, STR0007, oFnt10c) //"Planos Coletivos"	
oReport:Say(170, 280, STR0008, oFnt10c)  //"Faturas (Pessoa Jurídica)"		

                      
oReport:box(175, 135, 200, 205) 
oReport:Say(185, 136, STR0009, oFnt10c)  //"Preço"
oReport:Say(195, 136, STR0010, oFnt10c)  //"Pré-Estabelecido"	


oReport:box(175, 205, 200, 275)
oReport:Say(185, 206, STR0009, oFnt10c)	//"Preço" 
oReport:Say(195, 206, STR0011, oFnt10c)	//"Pós-Estabelecido"


oReport:box(175, 275, 200, 345) 
oReport:Say(185, 276, STR0009, oFnt10c)  //"Preço"
oReport:Say(195, 276, STR0010, oFnt10c)  //"Pré-Estabelecido"	


oReport:box(175, 345, 200, 415) 
oReport:Say(185, 346, STR0009, oFnt10c)  //"Preço"
oReport:Say(195, 346, STR0011, oFnt10c)  //"Pós-Estabelecido"


//Box Linha dos vencimentos
oReport:box(200, 20, 215, 805)
oReport:Fillrect( {201, 21, 216, 804 }, oBrush1)		

nSom := 0
cStr := ""
For nI := 1 To 6 //Seis linhas de vencimentos e subtotal
	oReport:box(215 + nSom, 20, 240 + nSom, 805)
	nSom += 25
Next
oReport:Say(230, 23, STR0026, oFnt10N) //"A vencer"
oReport:Say(255, 23, STR0027, oFnt10N) //"Vencidos de 1 a 30 dias"	
oReport:Say(280, 23, STR0028, oFnt10N) //"Vencidos de 31 a 60 dias"
oReport:Say(305, 23, STR0029, oFnt10N)  //"Vencidos de 61 a 90 dias"
oReport:Say(330, 23, STR0030, oFnt10N)	 //"Vencidos a mais de 90 dias"
oReport:Say(355, 90, STR0031, oFnt10N)  //SubTotal


//Box Créditos a Receber de Administradoras de Benefícios
oReport:box(120, 415, 200, 480)   
oReport:Say(135, 416, STR0012, oFnt10c)	//"Créditos Receber"
oReport:Say(145, 416, STR0013, oFnt10c)	//"Administradoras"
oReport:Say(155, 416, STR0014, oFnt10c)     //"de Benefícios" 	


//Box Participação dos Beneficiários em Eventos/ Sinistros
oReport:box(120, 480, 200, 545)   
oReport:Say(135, 481, STR0015, oFnt10c)	  //"Participação"
oReport:Say(145, 481, STR0016, oFnt10c)	//"dos Beneficiários"	
oReport:Say(155, 481, STR0017, oFnt10c)	//"Eventos/ Sinistros"


//Box Créditos de Operadoras
oReport:box(120, 545, 200, 610)   
oReport:Say(135, 546, STR0018, oFnt10c)		//"Créditos de"
oReport:Say(145, 546, STR0019, oFnt10c)		//"Operadoras"	


//Box Outros Créditos de Operações com Planos
oReport:box(120, 610, 200, 675)   
oReport:Say(135, 611, STR0020, oFnt10c)	//"Outros Créditos"
oReport:Say(145, 611, STR0021, oFnt10c)	//"de Operações"
oReport:Say(155, 611, STR0022, oFnt10c)	//"com Planos"


//Box Total
oReport:box(120, 675, 200, 740)  
oReport:Say(165, 690, STR0023, oFnt11N)	//TOTAL


//Box Outros Créditos Não Relacionados com Planos  (Subgrupo 124)
oReport:box(120, 740, 200, 805)   
oReport:Say(135, 741, STR0020, oFnt10c)	//"Outros Créditos"		
oReport:Say(145, 741, STR0024, oFnt10c)	//"Não Relacionados"
oReport:Say(155, 741, STR0022, oFnt10c)	//"com Planos"
oReport:Say(165, 741, STR0036, oFnt10c)	//"com Planos"


//Box PPSC
oReport:box(380, 20, 405, 805 )  //Box principal
oReport:Say(393, 30, STR0032, oFnt11N)	//PPSC
	
oReport:box(405, 20, 415, 805)	
oReport:Fillrect( {406, 21, 414, 804 }, oBrush1)	

oReport:box(415, 20, 440, 805)		
oReport:Say(433, 90, STR0033, oFnt11N)  //"SALDO"


//Line das colunas
nSom := 0
For nI := 1 to 5
	oReport:Line(200, 135 + nSom, 365, 135 + nSom)
	oReport:Line(380, 135 + nSom, 440, 135 + nSom) //BOX PPSC
	nSom += 70
Next

nLinha := (135 + nSom - 5) //Diferença de 70 para 65
nSom := 0

For nI := 1 To 5
	oReport:Line(200, nLinha + nSom, 365, nLinha + nSom)
	oReport:Line(380, nLinha + nSom, 440, nLinha + nSom)
	nSom += 65
Next


//****************************
//Impressão dos Valores
//****************************
//***********COLUNAS de 1 a 8 e 10	
nTamLi := 0
For nI := 1 To 9  //8 colunas
	nSom 	:= 0
	nTamLi	+= Iif ((nI <= 5), 70, Iif((nI < 9), 65, 130)) //130 pois pulamos a total, 
	nIniL	:= 203
	For nJ := 1 To 6  //6 linhas para preenchimento
		oReport:Say(230 + nSom, 66 + nTamLi, Alltrim(Transform(aDadosG[nJ, nI], Moeda)), oFnt10N)  
		nSom += 25
	Next
Next		


//**** 9ª Coluna TOTAL ******
nSom 		:= 0
For nI := 1 To 5 //Temos apenas 8 arrays para ser considerados na somatório, excluindo a coluna Outros Créditos Não Relacionados com Planos  (Subgrupo 124)
	nTotLin	:= 0
	For nJ := 1 to 8 //8 colunas que precisam ser somadas individualmente
		nTotLin += aDadosG[nI, nJ]  //"SALDO"
	Next
	oReport:Say(230 + nSom, 676, Alltrim(Transform(nTotLin, Moeda)), oFnt10N)  
	nSom += 25
	nSubTotlin += nTotLin
Next
oReport:Say(230 + nSom, 676, Alltrim(Transform(nSubTotlin, Moeda)), oFnt10N)


//Preenchimento do PPSC
nTamLi := 0
For nI := 1 To 9
	nTamLi	+= Iif ((nI <= 5), 70, Iif((nI < 9), 65, 130)) //130 pois pulamos a coluna Total, 
	oReport:Say(393, 66 + nTamLi, Alltrim(Transform(aDadPDD[1, nI], Moeda)), oFnt10N)  
	
	//Imprimir Linha do Saldo
	nSaldo := (aDadosG[6, nI] - aDadPDD[1, nI])
	oReport:Say(433, 66 + nTamLi, Alltrim(Transform(nSaldo, Moeda)), oFnt10N)  

	nTotPDD += Iif((nI<9), aDadPDD[1, nI], 0)
	Iif ((nI == 9), oReport:Say(393, 66 + (nTamLi -65), Alltrim(Transform(nTotPDD, Moeda)), oFnt10N), '')  //Tiro 65, pois está com valor de 130 e a impressão é na 9ª coluna
	
	Iif ((nI == 9), oReport:Say(433, 66 + (nTamLi -65), Alltrim(Transform((nSubTotlin - nTotPDD), Moeda)), oFnt10N), '')  //Tiro 65, pois está com valor de 130 e a impressão é na 9ª coluna
Next	


Return lRet

