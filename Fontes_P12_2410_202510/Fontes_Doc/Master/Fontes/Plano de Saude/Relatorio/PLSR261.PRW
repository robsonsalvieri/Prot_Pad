#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#define _nLin  25


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PLSR261 ³ Autor ³ Paulo Carnelossi        ³ Data ³ 26/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ficha de Matricula e Controle do Capital Social             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR261()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSR261(cCdOper, cCdRdaDe, cCdRdaAte, dDatRef)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel
LOCAL tamanho	:= "M"
LOCAL titulo	:= FunDesc() //"Ficha de Matrícula de Capital Social"
LOCAL cDesc1	:= "Impressao da Ficha de Matricula e Controle do "
LOCAL cDesc2	:= "Capital Social"
LOCAL cDesc3	:= " "

Local lPrinter	:= .T.

Local aArea		:= GetArea()
Local lOk		:= .F.
Local aSays     := {}, aButtons := {}, nOpca := 0

PRIVATE nomeprog	:="PLSR261"
PRIVATE nLastKey := 0
PRIVATE cPerg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Objetos utilizados na impressao grafica                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont06n, oFont06 , oFont08n, oFont08 ,oFont10, oFont10n, oFont12,oFont12n
Private oFont15,oFont15n, oFont18n
Private oCourier08, oCourier08n, oCourier12, oCourier12n

Private oPrint
Private cCodRDA, cCodOpe
Private nRegBAU := BAU->(Recno())

cString  := "BZ4"
wnrel:="PLSR261"
cPerg:="PLR261"
M->BE4_OPERDA := PLSINTPAD()   // PARA XB FUNCIONAR (BQW)

//--Altera o Set Epch para 1910
nEpoca := SET( 5,1910)

oFont06n	:= TFont():New("Tahoma",06,06,,.T.,,,,.T.,.F.)		//negrito
oFont06 	:= TFont():New("Tahoma",06,06,,.F.,,,,.T.,.F.)	
oFont08n	:= TFont():New("Tahoma",08,08,,.T.,,,,.T.,.F.)		//negrito
oFont08 	:= TFont():New("Tahoma",08,08,,.F.,,,,.T.,.F.)	
oFont10 	:= TFont():New("Tahoma",10,10,,.F.,,,,.T.,.F.)		//Font padrao utilizado para impressao de detalhe
oFont10n	:= TFont():New("Tahoma",10,10,,.T.,,,,.T.,.F.)		//negrito 
oFont12		:= TFont():New("Tahoma",12,12,,.F.,,,,.T.,.F.)		//Normal s/negrito
oFont12n	:= TFont():New("Tahoma",12,12,,.T.,,,,.T.,.F.)		//Negrito
oFont15 	:= TFont():New("Tahoma",15,15,,.F.,,,,.T.,.F.)		
oFont15n	:= TFont():New("Tahoma",15,15,,.T.,,,,.T.,.F.)		//Negrito
oFont18n	:= TFont():New("Tahoma",18,18,,.T.,,,,.T.,.F.)		//Negrito

oCourier08 	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)		//Font padrao utilizado para impressao de detalhe
oCourier08n	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)		//negrito 

oCourier12 	:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)		//Font padrao utilizado para impressao de detalhe
oCourier12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)		//negrito 

If 	cCdOper != Nil .And. cCdRdaDe != Nil .And. ;
	cCdRdaAte != Nil .And. dDatRef != Nil 
	mv_par01 := cCdOper
	mv_par02 := cCdRdaDe
	mv_par03 := cCdRdaAte
	mv_par04 := dDatRef
Else
	Pergunte(cPerg,.f.)
	
	AADD(aSays,"Impressao de Fichas de Matricula e Controle do Capital Social")
	
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	FormBatch( Titulo, aSays, aButtons,, 160 )
	
	If nOpca == 0
	   Return
	EndIf   

EndIf

//-- Objeto para impressao grafica
oPrint 	:=TMSPrinter():New("FICHA DE MATRICULA E CONTROLE DO CAPITAL SOCIAL ")
oPrint  :SetPortrait()										//--Modo retrato

RptStatus({|lEnd| R261Imp(@lEnd,wnRel,cString)},Titulo)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Area e Ordem de Entrada                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//--Retornar Set Epoch Padrao
SET(5,nEpoca)
BAU->(dbGoto(nRegBAU))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R261IMP  ³ Autor ³ Paulo Carnelossi      ³ Data ³ 26/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR261                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R261Imp(lEnd,wnRel,cString)
Local lImpr := .F.

dbSelectArea("BAU")
dbSeek(xFilial("BAU")+mv_par02,.t.)

While BAU->(!Eof() .And. BAU_FILIAL = xFilial("BAU") .And. BAU_CODIGO <= mv_par03)
	cCodOpe := mv_par01
	cCodRDA := BAU->BAU_CODIGO
	R261Det(lEnd,wnRel,cString)
	lImpr := .T.
	BAU->(dbSkip())
End	

If lImpr
	oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R261Det  ³ Autor ³ Paulo Carnelossi      ³ Data ³ 26/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSR261                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R261Det(lEnd,wnRel,cString)

//Local cDet 			:= ""
Local nPag          := 0

Private nLinMax		:= 3050				//-- Numero maximo de Linhas
Private nColMax		:= 2350				//-- Numero maximo de Colunas
Private nColIni		:= 50               //-- Coluna Lateral (inicial) Esquerda
Private nColIniDet	:= 60               //-- Coluna Lateral (inicial) Esquerda
Private li 			:= 30 				//-- Contador de Linhas
Private nLin
Private nIncrLin      := 060
Private cPicMoeda     := "@E 99,999,999.99"
       

DbSelectArea("BAU")
If ! dbSeek(xFilial("BAU")+cCodRDA)
	Return
EndIf	

DbSelectArea("BZ4")
If !dbSeek(xFilial("BZ4")+cCodRDA)
	Return
EndIf
	
R261Pag(@nPag)

dbSelectArea("BZ5")
dbSeek(xFilial("BZ5")+cCodRDA+BZ4->BZ4_FICMAT)
While BZ5->(!Eof() .And. BZ5_FILIAL+BZ5_CODIGO+BZ5_FICMAT == ; 
		xFilial("BZ5")+cCodRDA+BZ4->BZ4_FICMAT)
		
	If nLin > (nLinMax - 150)
		oPrint:Line(nLin,0050,nLin,nColMax-50)
		oPrint:say(nLin, 0050,"Continuacao na Proxima Pagina ---->  ", oCourier12n)
		nLin += nIncrLin 
		oPrint:EndPage() 		// Finaliza a pagina
		R261Pag(@nPag)
		oPrint:say(nLin, 0050,"----> Transporte da Pagina Anterior ", oCourier12n)
		oPrint:say(nLin, 1850,Transform(BZ5->BZ5_SALDO-BZ5->BZ5_VLRLCT, cPicMoeda), oCourier12n)
		oPrint:say(nLin, 2250,If((BZ5->BZ5_SALDO-BZ5->BZ5_VLRLCT)<0,"D","C"), oCourier12n)
		nLin += nIncrLin 

	EndIf
	
	If BZ5->BZ5_DATLCT <= mv_par04
	
		oPrint:say(nLin, 0050,DTOC(BZ5->BZ5_DATLCT), oCourier12n)
		oPrint:say(nLin, 0300,Alltrim(BZ5->BZ5_CODLCT+"-"+Posicione("BZ7",1,xFilial("BZ7")+BZ5->BZ5_CODLCT,"BZ7_DESLCT")), oFont08n)
		oPrint:say(nLin, If(BZ5->BZ5_TIPLCT=="1",1100,1450),Transform(BZ5->BZ5_VLRLCT, cPicMoeda), oCourier12n)
		oPrint:say(nLin, 1850,Transform(BZ5->BZ5_SALDO, cPicMoeda), oCourier12n)
		oPrint:say(nLin, 2250,If(BZ5->BZ5_SALDO<0,"D","C"), oCourier12n)
		
		nLin += nIncrLin 
	EndIf

	BZ5->(dbSkip())

End

oPrint:EndPage() 		// Finaliza a pagina

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fLogoEmp  ºAutor  ³RH - Natie          º Data ³  02/18/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLogoEmp( cLogo,cTipo)
Local  cStartPath	:= GetSrvProfString("Startpath","")
Default cLogo := ""
cTipo 	:= If(cTipo == NIL, "1", cTipo)

//-- Logotipo da Empresa
If cTipo =="1"
	cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" 	// Empresa+Filial
	If !File( cLogo )
		cLogo := cStartPath + "LGRL"+SM0->M0_CODIGO+".BMP" 				// Empresa
	endif
Endif


Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fDrawBox    ºAutor  ³Microsiga           º Data ³  03/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desenha Box                                                   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
    
Static Function  fDrawBox(nLIn,nCol)

oPrint:Box(nLin, nCol,nLin+40,nCol+40)

Return(nlin)
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR261   ºAutor  ³Microsiga           º Data ³  03/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R261Pag(nPag)
Local cFileLogo		:= ""
//Local cStartPath 	:= GetSrvProfString("Startpath","")
Local nVlrCota		:= SuperGetMv("MV_PLSCOTA", .F., 1)
Local nX, nLimite
Local cMemoAdm, cMemoDem, aCpoMem := {{},{}}
Local nLinObs1 		:= 0
Local nLinObs2 		:= 0

oPrint	:StartPage()
nPag++ 										//--Inicia uma nova pagina
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Box Principal                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Box( 030,030,nLinMax, nColMax )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega e Imprime Logotipo da Empresa                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fLogoEmp(@cFileLogo)
oPrint:Line(30,50,30,nColMax)
If File(cFilelogo)
	oPrint:SayBitmap(080,050, cFileLogo,242,194) 		//-- Tem que estar abaixo do RootPath
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome da Operadora 										     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA0->(DbSetOrder(1))
BA0->(DbSeek(xFilial("BA0")+cCodOpe))
oPrint:say(040,350, PadR(BA0->BA0_NOMINT,50) , oFont15n)

oPrint:say(150, 350,"FICHA DE MATRICULA No. ", oFont15n)

oPrint:Box(140,1150,240, 1400 )
oPrint:say(150, 1175,BZ4->BZ4_FICMAT, oFont15n)

oPrint:say(150, 1800,"Folha No. ", oFont15n)
oPrint:say(150, 2100,StrZero(nPag, 3), oFont15n)

nLin := 300

oPrint:say(nLin, 0050,"IDENTIFICACAO", oFont12n)
oPrint:say(nLin, 1400,"DOCUMENTACAO", oFont12n)

nLin += nIncrLin

oPrint:say(nLin, 0050,"Nome: ", oFont10)             
oPrint:say(nLin, 0250,BAU->BAU_NOME, oFont10n)             
oPrint:say(nLin, 1400,"CRM No.: ", oFont10)             
oPrint:say(nLin, 1700,BAU->BAU_CONREG, oFont10n)             
nLin += nIncrLin

oPrint:say(nLin, 0050,"Nacionalidade: ", oFont10)             
oPrint:say(nLin, 0350,BAU->BAU_NACION, oFont10n)             
oPrint:say(nLin, 1400,"RG No.: ", oFont10)             
oPrint:say(nLin, 1700,BAU->BAU_RG, oFont10n)             
nLin += nIncrLin

oPrint:say(nLin, 0050,"Data Nascimento: ", oFont10)
oPrint:say(nLin, 0600,DTOC(BAU->BAU_NASFUN), oFont10n)             
oPrint:say(nLin, 1400,"CPF/CGC No.: ", oFont10)
oPrint:say(nLin, 1700,BAU->BAU_CPFCGC, oFont10n)             
nLin += nIncrLin

BAW->(DbSetorder(1))
BAW->(DbSeek(xFilial("BAW")+BAU->BAU_CODIGO))

oPrint:say(nLin, 0050,"Estado Civil: ", oFont10)
oPrint:say(nLin, 0500,BAU->BAU_ESTCIV+" - "+Tabela("33",BAU->BAU_ESTCIV,.F.), oFont10n)             
oPrint:say(nLin, 1400,"Codigo UNIMED: ", oFont10)
oPrint:say(nLin, 1700,BAU->BAU_CODIGO+" - "+BAW->BAW_CODANT, oFont10n)             
nLin += nIncrLin

oPrint:say(nLin, 0050,"Residencia: ", oFont10)
oPrint:say(nLin, 0300,BAU->BAU_END, oFont10n)             
nLin += nIncrLin
oPrint:say(nLin, 0300,Alltrim(BAU->BAU_BAIRRO)+Space(1)+Alltrim(Posicione("BID",1,xFilial("BID")+BAU->BAU_MUN,"BID_DESCRI"))+Space(1)+BAU->BAU_EST, oFont10n)             
nLin += nIncrLin

nLin += 50
oPrint:say(nLin, 0050,"IDENTIDADE PROFISSIONAL", oFont12n)
nLin += nIncrLin

oPrint:say(nLin, 0050,"Profissao: ", oFont10)
If ! Empty(BAU->BAU_CBO)
	oPrint:say(nLin, 0300,BAU->BAU_CBO+"-"+Alltrim(Posicione("SRJ",2,xFilial("SRJ")+BAU->BAU_CBO,"RJ_DESC")), oFont10n)
Else	
	oPrint:say(nLin, 0300,"Prestador", oFont10n)
EndIf	
nLin += nIncrLin

oPrint:say(nLin, 0050,"Especialidade: ", oFont10)
BBF->(DbSetOrder(1))
If BBF->(!DbSeek(xFilial("BBF")+BAU->BAU_CODIGO))
	nLin += nIncrLin
EndIf
While BBF->(BBF_FILIAL+BBF_CODIGO) == xFilial("BBF")+BAU->BAU_CODIGO
	oPrint:say(nLin, 0300,BBF->BBF_CODESP+"-"+Posicione("BAQ",1,xFilial("BAQ")+BBF->BBF_CODESP,"BAQ_DESCRI"), oFont10n)             
	BBF->(dbSkip())
	nLin += nIncrLin
End

nLin += 50
oPrint:say(nLin, 0050,"ADMISSAO", oFont12n)
oPrint:say(nLin, 1400,"TERMO DE DEMISSAO", oFont12n)
nLin += nIncrLin

oPrint:say(nLin, 0050,"Admissao em: ", oFont10)
oPrint:say(nLin, 0600,DTOC(BZ4->BZ4_ADMISS), oFont10n)
oPrint:say(nLin, 1400,"Data da Demissao: ", oFont10)
nLin += nIncrLin

oPrint:say(nLin, 0050,"Observacao: ", oFont10)
oPrint:say(nLin, 1400,"Observacao: ", oFont10)

cMemoAdm := MSMM(BZ4->BZ4_CDMEM1)
cMemoDem := MSMM(BZ4->BZ4_CDMEM2)
If Empty(cMemoAdm+cMemoDem)
	nLin += nIncrLin
Else
   	For nX := 1 TO MLCOUNT(cMemoAdm,40)
       	aAdd(aCpoMem[1], MEMOLINE(cMemoAdm, 40, nX))
   	Next
   	For nX := 1 TO MLCOUNT(cMemoDem)
    	aAdd(aCpoMem[2], MEMOLINE(cMemoDem, 40, nX))
   	Next           
   
   	nLinObs1 := nLin
   	nLinObs2 := nLin
   
   	nLimite := Len(aCpoMem[1])
   
	For nX :=1 TO nLimite
       	If Len(aCpoMem[1]) > 0 .And. Len(aCpoMem[1])<= nLimite .And. aCpoMem[1][nX] != NIL
			oPrint:say(nLinObs1, 0300,aCpoMem[1][nX], oFont08)
	   	EndIf 
	   	nLinObs1 += 30		
   	Next
   

   
   	nLimite := Len(aCpoMem[2])
   
   	For nX :=1 TO nLimite   
       	If Len(aCpoMem[2]) > 0 .And. Len(aCpoMem[2])<= nLimite .And. aCpoMem[2][nX] != NIL
		   	oPrint:say(nLinObs2, 1650,aCpoMem[2][nX], oFont08)
	   	EndIf
	   	nLinObs2 += 30
   	Next  
   
   	If nLinObs1 > nLinObs2
	   	nLin := nLinObs1
   	Else
       	nLin := nLinObs2
   	EndIf
   
EndIf


nLin += 120
oPrint:Line(nLin,0050,nLin,0550)
oPrint:Line(nLin,0600,nLin,1200)
oPrint:Line(nLin,1400,nLin,1850)
oPrint:Line(nLin,1900,nLin,nColMax-1)
nLin += 10

oPrint:say(nLin, 0150,"Ass.do Cooperado" , oFont10)
oPrint:say(nLin, 0750,"Ass.do Presidente", oFont10)
oPrint:say(nLin, 1500,"Ass.do Cooperado" , oFont10)
oPrint:say(nLin, 2000,"Ass.do Presidente", oFont10)
nLin += nIncrLin

nLin += 50
oPrint:say(nLin, 0200,"Conta Corrente de Capital" , oFont15n)
oPrint:say(nLin, 1300,"Valor da Quota Parte: R$ "+Transform(nVlrCota, "@E 999.99"), oFont15n)
nLin += nIncrLin

nLin+=60
oPrint:say(nLin, 0050,"DATA" , oFont12n)
oPrint:say(nLin, 0300,"DESCRICAO", oFont12n)
oPrint:say(nLin, 1250,"CREDITOS", oFont12n)
oPrint:say(nLin, 1570,"DEBITOS", oFont12n)
oPrint:say(nLin, 2030,"SALDO", oFont12n)
oPrint:say(nLin, 2230,"D/C", oFont12n)
nLin += nIncrLin

Return	

