#INCLUDE "FINC720.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#include "MSGRAPHI.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINC720  ³ Autor ³ Wagner Mobile         ³ Data ³ 29-07-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta comparativa entre Valores Orcados X Reais Mensal    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Finc720(lAnual As Logical) As Logical
Local lPergunte As Logical
Local aSize		As Array
Local aObjects	As Array
Local aPages	As Array
Local oDlg		As Object
Local aTitles	As Array
Local aRet		As Array
Local aTrees 	As Array
Local cPerg 	As Character
Local lIncTree	As Logical
Local lTree		As Logical
Local aEntradas	As Array
Local aSaidas 	As Array
Local nFolder 	As Numeric
Local nI 		As Numeric
Local nLin 		As Numeric
Local cLoad 	As Character
Local aButtons 	As Array
Local oPanel	As Object
Private oChart	As Object
Private oChart1 As Object
Private oChart2 As Object
Private oChart3 As Object
Private aColuna	As Array

lPergunte 	:= .F.
aSize		:= {}
aObjects	:= {}
aPages		:= {}
aTitles		:= { STR0043, STR0044, STR0045, STR0046 } //"Entradas"###"Saidas"###"Entradas X Saidas"###"Resumo"
aRet		:= {}
aTrees 		:= {}
cPerg 		:= "FIC720"
aEntradas	:= {}
aSaidas 	:= {}
nFolder 	:= 0
nI	 		:= 0
cLoad 		:= ProcName(1)
aButtons 	:= {}

DEFAULT lAnual	:= .F.

Private aRotina 	As Array
Private oResumo		As Object
Private aResumo		As Array
Private oQuebras	As Object
Private aQuebras	As Array
Private cArqTmp 	As Character
Private cIndex1 	As Character
Private cIndex2 	As Character
Private cIndex3 	As Character
Private nDecs		As Numeric
Private aTotais		As Array
Private cCadastro 	As Character
Private aSelFil		As Array

aRotina 	:= {{STR0062, "AxVisual", 0, 2}} // "Visualizar"
cArqTmp 	:= cIndex1 := cIndex2 := cIndex3 := ""
cCadastro 	:= STR0001
aSelFil		:= {}

cCadastro += IIf(lAnual, STR0050, STR0051) //" - Anual"###" - Mes"

cPerg:= IIf( lAnual, "FIC730", "FIC720" ) // Define o Pergunte se Orçamento Mensal ou Anual

If lAnual
	cPerg	 := "FIC730"
Endif

lPergunte := pergunte(cPerg,.T.)

If !lPergunte
	Return .F.
Endif

Do Case
	Case mv_par02 < mv_par01
		HELP (" ",1,"R720NAT")
		Return
	Case mv_par04 < mv_par03
		HELP (" ",1,"R720NAT")
		Return
EndCase	
//Seleciona Filiais
#IFDEF TOP
	If mv_par11 == 1 
		nRegSM0 := SM0->(Recno())
		aSelFil := FwSelectGC()
		SM0->(DbGoTo(nRegSM0))
		nConsFil:= .F.
	Endif
	If Empty(aSelFil)
		Aadd(aSelFil,cFilAnt)
	Endif
#ELSE
	aSelFil := {}
#ENDIF

oMainWnd:ReadClientCoors()

nDecs 	:= MsDecimais(mv_par06)

nTop    := oMainWnd:nTop
nLeft	:= oMainWnd:nLeft
nBottom	:= oMainWnd:nBottom
nRight	:= oMainWnd:nRight

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize		:= MsAdvSize(,.F.,430)
aObjects	:= {{ 100, 157 , .T., .T. }}
aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj		:= MsObjSize( aInfo, aObjects )
oTdTree	 	:= {}

Aadd(aButtons ,{ "SDUPROP", {|| If(Pergunte(cPerg, .T.),Finc720Tmp(lAnual, oDlg), .T.)} , STR0017})

 
DEFINE  MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL ; 
		STYLE nOR(WS_VISIBLE,WS_POPUP)
EnchoiceBar(oDlg,	{|| oDlg:End()},;
														{|| oDlg:End()},,@aButtons )
nLin := 0
oPanel :=  TPanel():New(  0 , 0, /*[ cText]*/,oDlg , /*[ oFont]*/, /*[ lCentered]*/, /*[ uParam7]*/, /*[ nClrText]*/,/**/,200 , 20,.t. , /*[ lRaised]*/ ) 
oPanel:align :=CONTROL_ALIGN_BOTTOM  

oFolder := TFolder():New(	nLin,0,aTitles,aPages,oDlg,,,,.T., .F.,((nRight-nLeft)/2)+5,;
							nBottom-nTop-nLin-100,)
oFolder:align 	 := CONTROL_ALIGN_ALLCLIENT

Finc720Tmp(lAnual, oDlg)

For nFolder := 1 To 2
	oFolder:aDialogs[nFolder]:oFont := oDlg:oFont
	oTree  := DbTree():New( 2, 2,((nBottom-nTop)/2)-50, 150,oFolder:aDialogs[nFolder],,,.T.)
	oTree:lShowHint:= .F. 
	oTree:ALIGN := CONTROL_ALIGN_LEFT
	Aadd(aTrees, oTree)

	oTree:bChange := {|x| FinC720Grap(,,,,,, x:GetCargo(), lAnual) }
	oTree:BeginUpdate()

	cArqTmp->(DbGoTop())
	lTree := .F.

	While ! cArqTmp->(Eof())

		lIncTree := .F.
		If nFolder = 1 .And. (cArqTmp->rEntr > 0 .Or. cArqTmp->aEntr > 0 .Or.;
							 (If(! lAnual, cArqTmp->aEAcm + cArqTmp->rEAcm > 0, .F.)))
            If lAnual
            	If Ascan(aEntradas, cArqTmp->NATUR) == 0
		       		Aadd(aEntradas, cArqTmp->NATUR)
		       		lIncTree := .T.
		      	Endif
	       	Else
				lIncTree := .T.
			Endif
		ElseIf nFolder = 2 .And. (cArqTmp->rSaid > 0 .Or. cArqTmp->aSaid > 0 .Or.;
							 (If(! lAnual, cArqTmp->aSAcm + cArqTmp->rSAcm > 0, .F.)))
            If lAnual
            	If Ascan(aSaidas, cArqTmp->NATUR) == 0
		       		Aadd(aSaidas, cArqTmp->NATUR)
		       		lIncTree := .T.
		      	Endif
	       	Else
				lIncTree := .T.
			Endif
		Endif

		If 	lIncTree
			lTree := .T.
			DBADDITEM oTree PROMPT MascNat(cArqTmp->NATUR) + " - " + cArqTmp->DESCR;
					  		RESOURCE "BMPTRG" CARGO StrZero(cArqTmp->(Recno()),12)
		Endif
		cArqTmp->(dbSkip())
	EndDo

    If lTree
		DBENDTREE oTree
	Endif

	oTree:EndUpdate()
	oTree:Refresh()	
Next

oFolder:bChange := { |x| If(x < 3, FinC720Grap(,,,,,, aTrees[x]:GetCargo(), lAnual), If(x == 3, Finc720Res(,aTotais,lAnual),)) }

ACTIVATE MSDIALOG oDlg ON INIT (FinC720Grap(,,,,,, aTrees[1]:GetCargo(), lAnual),)   

If !Empty(cArqTmp)
	dbSelectarea("cArqTmp")
	cArqTmp->( dbCloseArea() )
	Ferase(cArqTmp+GetDBExtension())
	Ferase(cArqTmp+OrdBagExt())

	#IFDEF TOP
		If TcSrvType() == "AS/400"
			Ferase(cIndex1+OrdBagExt())
			Ferase(cIndex2+OrdBagExt())
		EndIf
	#ELSE
		Ferase(cIndex1+OrdBagExt())
		Ferase(cIndex2+OrdBagExt())
		Ferase(cIndex3+OrdBagExt())
	#ENDIF
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Finc720Grap ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 29.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta grafico de comparacao previsto X Realizado X Orcado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720Grap                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Finc720Grap(oDlg, nTop, nLeft, nBottom, nRight, nGrafico, cRecTmp, lAnual)
Local nPrevisto		:= 0    as Numeric
Local nRealizado	:= 0    as Numeric
Local nOrcado 		:= 0    as Numeric
Local nPrevAcm 		:= 0    as Numeric
Local nRealAcm 		:= 0    as Numeric
Local nOrcAcm       := 0    as Numeric
Local nMeses        := 0    as Numeric
Local nMaxVal1 		:= 0    as Numeric
Local nMaxVal2 		:= 0    as Numeric
Local nDivisor 		:= 1    as Numeric
Local nVezes        := 0    as Numeric
Local aDados        := {}   as Array
Local aPreAnual     := {}   as Array
Local aReaAnual     := {}   as Array
Local aOrcAnual     := {}   as Array
Local aSetAxis      := {}   as Array
Local cDivisor 		:= ""   as Character
Local lAcumul  		:= (!lAnual .And. MV_PAR07 == 1) as Logical


DEFAULT oDlg		:= oFolder:aDialogs[oFolder:nOption]
DEFAULT nTop		:= 1 
DEFAULT nLeft		:= 155
DEFAULT nBottom		:= aPosObj[1][4]-155
DEFAULT nRight 		:= aPosObj[1,3]-35

    cArqTmp->(DbGoto(Val(cRecTmp)))
        
    If lAnual
        nMeses	:= Val(cArqTmp->MES)
        For nMeses := nMeses To 12
            If oFolder:nOption == 1
                nPrevisto	:= cArqTmp->aEntr
                nRealizado	:= cArqTmp->rEntr
            Else
                nPrevisto	:= cArqTmp->aSaid
                nRealizado	:= cArqTmp->rSaid
            Endif
            nMaxVal1 := MAX(nMaxVal1, nPrevisto)
            nMaxVal2 := MAX(nMaxVal2, nRealizado)		
            cArqTmp->(DbSkip())		
        Next
        nMax := MAX( nMaxVal1, nMaxVal2 )
        cArqTmp->(DbGoto(Val(cRecTmp)))
    Else
        If oFolder:nOption == 1
            nPrevisto	:= cArqTmp->aEntr
            nRealizado	:= cArqTmp->rEntr
            nPrevAcm 	:= cArqTmp->aEAcm
            nRealAcm 	:= cArqTmp->rEAcm
        Else
            nPrevisto	:= cArqTmp->aSaid
            nRealizado	:= cArqTmp->rSaid
            nPrevAcm 	:= cArqTmp->aSAcm
            nRealAcm 	:= cArqTmp->rSAcm
        Endif

        nMaxVal1 := MAX(nPrevisto, nRealizado)
        nMaxVal2 := MAX(nPrevAcm, nRealAcm)

        nMax := MAX( nMaxVal1, nMaxVal2 )
    EndIf
        
    If nMax > 999999999999 // Trilhão
        nDivisor := 1000000000000
        cDivisor := "Valores exibidos em Trilhões"
    ElseIf nMax > 999999999 // Bilhão
        nDivisor := 1000000000
        cDivisor := "Valores exibidos em Bilhões"
    ElseIf nMax > 999999 // Milhão
        nDivisor := 1000000
        cDivisor := "Valores exibidos em Milhões"
    EndIf

    If lAnual
        aColuna  	:= {{ STR0054, STR0049, STR0048, STR0047 }} //"Data de Referencia", "Orçado", "Realizado", "Previsto"
		nMeses 	 	:= Val(cArqTmp->MES)

        For nMeses := nMeses To 12
			If oFolder:nOption == 1
				nPrevisto	:= cArqTmp->aEntr / nDivisor
				nRealizado	:= cArqTmp->rEntr / nDivisor
			Else
				nPrevisto	:= cArqTmp->aSaid / nDivisor
				nRealizado	:= cArqTmp->rSaid / nDivisor
			Endif

			SE7->(dbSeek(xFilial("SE7") + cArqTmp->NATUR + Str(Year(MV_PAR07),4)))
			nOrcado	:= GetOrcado(nMeses)

			Aadd(aColuna, { 	"31/" + StrZero(nMeses, 2) + "/" + Str(Year(MV_PAR07), 4),;
								Trans(nOrcado, TM(nOrcado,18,nDecs)),;
								Trans(nRealizado, TM(nRealizado,18,nDecs)),;
								Trans(nPrevisto, TM(nPrevisto,18,nDecs)) } )			
            
            Aadd(aPreAnual,nPrevisto)
            Aadd(aReaAnual,nRealizado)
            Aadd(aOrcAnual,nOrcado)
            
            Aadd(aSetAxis,STR0055 + StrZero(nMeses, 2))

			cArqTmp->(DbSkip())
		next
        Aadd(aDados,{STR0047,aPreAnual})
        Aadd(aDados,{STR0048,aReaAnual})
        Aadd(aDados,{STR0049,aOrcAnual})
    Else
        If oFolder:nOption == 1
            nPrevisto	:= cArqTmp->aEntr / nDivisor
            nRealizado	:= cArqTmp->rEntr / nDivisor
            nPrevAcm 	:= cArqTmp->aEAcm / nDivisor
            nRealAcm 	:= cArqTmp->rEAcm / nDivisor
        Else
            nPrevisto	:= cArqTmp->aSaid / nDivisor
            nRealizado	:= cArqTmp->rSaid / nDivisor
            nPrevAcm 	:= cArqTmp->aSAcm / nDivisor
            nRealAcm 	:= cArqTmp->rSAcm / nDivisor 
        Endif
        
        nOrcado	:= Iif(SE7->(dbSeek(xFilial("SE7") + cArqTmp->NATUR + Str(Year(mv_par08), 4))), GetOrcado(month(mv_par08)), 0)

        //"Data de Referencia", "Previsto", "Realizado", "Orçado"
        aColuna := {{ STR0054, STR0047, STR0048, STR0049},;  
                        { STR0055 + StrZero(Month(mv_par08), 2) + "/" +; //"Mes "
                            Str(Year(mv_par08), 4),;
                            Trans(nPrevisto, TM(nPrevisto,18,nDecs)),; 
                            Trans(nRealizado, TM(nRealizado,18,nDecs)),;
                            Trans(nOrcado, TM(nOrcado,18,nDecs)) }}
        If lAcumul
            For nVezes := 1 To 12
				nOrcAcm += Iif(SE7->(DbSeek(xFilial("SE7") + cArqTmp->NATUR + Str(Year(mv_par08), 4))), GetOrcado(nVezes), 0)
			Next

            Aadd(aDados,{STR0047,{nPrevisto,nPrevAcm}})
            Aadd(aDados,{STR0048,{nRealizado,nRealAcm}})
            Aadd(aDados,{STR0049,{nOrcado,nOrcAcm}})

            Aadd(aSetAxis,STR0055 + StrZero(Month(mv_par08), 2))
			Aadd(aSetAxis,STR0066)
        Else
            Aadd(aDados,{STR0047,nPrevisto})
            Aadd(aDados,{STR0048,nRealizado})
            Aadd(aDados,{STR0049,nOrcado})

            Aadd(aSetAxis,STR0055 + StrZero(Month(mv_par08), 2))
        Endif
    Endif

    F720GRAPH(oDlg,aDados,aSetAxis,lAnual,lAcumul)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Finc720GRes ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 31.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta grafico do resumo das operacoes das naturezas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720GRes                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Finc720Res(oDlg,aTotais,lAnual)
Local nMeses  		:= 0  as Numeric
Local nDireito 		:= 0  as Numeric
Local nRodape  		:= 0  as Numeric
Local aPrevisto		:= {} as Array
Local aRealizado	:= {} as Array
Local aOrcado 		:= {} as Array
Local aDados        := {} as Array
Local aSetAxis      := {} as Array
Local aPreAnual     := {} as Array
Local aReaAnual     := {} as Array
Local aOrcAnual     := {} as Array
Local lAcumul  		:= (!lAnual .And. MV_PAR07 == 1) as Logical

DEFAULT oDlg		:= oFolder:aDialogs[oFolder:nOption]


    If SetMDIChild()
        nDireito := (oDlg:nRight * 10) / 2.1 
        nRodape  := ((oDlg:nBottom * 230) / 2.1) - 110
    Else
        nDireito := (oDlg:nRight) / 2.1 
        nRodape  := ((oDlg:nBottom) / 2.1) - 110	
    EndIf

    If lAnual
        aColuna := { { STR0054, STR0049, STR0048, STR0047 } } //"Data de Referencia"
        For nMeses := 2 To 13
            Aadd(aColuna, { 	"31/" + StrZero(nMeses - 1, 2) + "/" + Str(Year(MV_PAR07), 4),;
                                Trans(aTotais[3][5,nMeses] - aTotais[3][6,nMeses], TM(0,18,nDecs)),;
                                Trans(aTotais[3][2,nMeses] - aTotais[3][4,nMeses], TM(0,18,nDecs)),;
                                Trans(aTotais[3][1,nMeses] - aTotais[3][3,nMeses], TM(0,18,nDecs)) } )

            Aadd(aPreAnual, aTotais[3][1,nMeses] - aTotais[3][3,nMeses])
            Aadd(aReaAnual, aTotais[3][2,nMeses] - aTotais[3][4,nMeses])
            Aadd(aOrcAnual, aTotais[3][5,nMeses] - aTotais[3][6,nMeses])
            
            Aadd(aSetAxis,STR0055 + StrZero(nMeses - 1, 2))
        
        Next
		Aadd(aDados,{STR0047,aPreAnual})
        Aadd(aDados,{STR0048,aReaAnual})
        Aadd(aDados,{STR0049,aOrcAnual})
    Else
        aColuna  := {{ STR0054, STR0047, STR0048, STR0049 },; //"Data de Referencia", "Previsto", "Realizado", "Orçado"
                        { STR0055 + StrZero(Month(mv_par08), 2) + "/" +; //"Mes "
                            Str(Year(mv_par08), 4),;
                            Trans(aTotais[1,1] - aTotais[1,2], TM(0,18,nDecs)),; 
                            Trans(aTotais[1,3] - aTotais[1,4], TM(0,18,nDecs)),;
                            Trans(aTotais[1,5] - aTotais[1,6], TM(0,18,nDecs)) }}

		Aadd(aPrevisto, aTotais[1,1] - aTotais[1,2])
		Aadd(aPrevisto, aTotais[1,7] - aTotais[1,8])

		Aadd(aRealizado, aTotais[1,3] - aTotais[1,4])
		Aadd(aRealizado, aTotais[1,9] - aTotais[1,10])

		Aadd(aOrcado, aTotais[1,5] - aTotais[1,6])
		Aadd(aOrcado, aTotais[1,11] - aTotais[1,12])
        
		If lAcumul
			Aadd(aDados,{STR0047,aPrevisto})
			Aadd(aDados,{STR0048,aRealizado})
			Aadd(aDados,{STR0049,aOrcado})

			Aadd(aSetAxis,STR0055 + StrZero(Month(mv_par08), 2))
			Aadd(aSetAxis,STR0066)
		Else
			Aadd(aDados,{STR0047,aPrevisto[1]})
			Aadd(aDados,{STR0048,aRealizado[1]})
			Aadd(aDados,{STR0049,aOrcado[1]})

			Aadd(aSetAxis,STR0055 + StrZero(Month(mv_par08), 2))
		Endif
    Endif

	F720GRAPH(oDlg,aDados,aSetAxis,lAnual,lAcumul)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Finc720Tmp  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 29.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta temporario para apresentacao dos valores por natureza   ³±±
±±³          ³ E o resumo de entradas e saidas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Finc720Tmp                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Finc720Tmp(lAnual, oDlg)

Local aArray
Local lRefresh
Local nTotais 	:= 0
Local nLaco 	:= 0

nDecs := MsDecimais(mv_par06)

If ! Empty(cArqTmp)
	dbSelectarea("cArqTmp")
	cArqTmp->( dbCloseArea() )
	Ferase(cArqTmp+GetDBExtension())
	Ferase(cArqTmp+OrdBagExt())

	#IFDEF TOP
		If TcSrvType() == "AS/400"
			Ferase(cIndex1+OrdBagExt())
			Ferase(cIndex2+OrdBagExt())
		Endif
	#ELSE
		Ferase(cIndex1+OrdBagExt())
		Ferase(cIndex2+OrdBagExt())
		Ferase(cIndex3+OrdBagExt())
	#ENDIF
Endif

If lAnual
	Finc730Tmp(oDlg)
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ a formata‡„o do c¢digo das naturezas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMascNat := GetMV("MV_MASCNAT")
cMapa    := "123456789"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta matriz informa em que posicoes seao feitas as quebras.   ³
//³ 1-Byte inicial da quebra, 2-Quantidade de caracteres.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNiveis  := {}
    	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta matriz armazena as chaves de quebra e os totalizadores parciais.  ³
//³ 1-Chave, 2-A Realizar, 3-Realizado e 4-Or‡ado                          ³
//³ 5-A Realizar Acum. 6-Realizado Acumulado e 7-Orcado acumulado 		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aQuebras := {}
For nLaco := 1 to len( cMascNat )
	nByte := Val( Substr( cMascNat,nLaco,1 ) )
	If nByte > 0
		AAdd( aNiveis  , { Val(Left(cMapa,1)) , nByte} )
		AAdd( aQuebras , { "", 0, 0, 0 ,0 ,0 ,0} )
		cMapa := Subst(cMapa,nByte+1,Len(cMapa)-nByte)
	Endif
End

Processa( { || aTotais := Fin720Cria(@cArqTmp, @cIndex1, @cIndex2, @cIndex3, .F., aNiveis, aQuebras, , , aSelFil) })

Finc720Res(oDlg,aTotais,lAnual)

aResumo		:= aTotais[3]
aQuebras	:= aTotais[2]

lRefresh := .F.
If !lAnual .And. MV_PAR07 == 1
	If oResumo == Nil
		oResumo	:= TWBrowse():New( 2,2,aPosObj[1,4],080,,{aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6],aResumo[1][7],aResumo[1][8],aResumo[1][9]},{30,38,38,30,38,38,30,65,65},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		oResumo:aHeaders := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6],aResumo[1][7],aResumo[1][8],aResumo[1][9]}
		oResumo:aColumns := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6],aResumo[1][7],aResumo[1][8],aResumo[1][9]}
		oResumo:aColSizes := {30,38,38,30,38,38,30,65,65}
		lRefresh := .T.
	Endif
Else
	If oResumo = Nil
		oResumo	:= TWBrowse():New( 2,2,aPosObj[1,4],080,,{aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6]},{31,85,31,85,31,85},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		oResumo:aHeaders := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6]}
		oResumo:aColumns := {aResumo[1][1],aResumo[1][2],aResumo[1][3],aResumo[1][4],aResumo[1][5],aResumo[1][6]}
		oResumo:aColSizes := {31,85,31,85,31,85}
		lRefresh := .T.
	Endif
Endif
aArray := AClone(aResumo)

aResumo	:= {}
For nTotais := 2 To Len(aArray)
	Aadd(aResumo, aArray[nTotais])
Next

oResumo:SetArray(aResumo)
If !lAnual .And. MV_PAR07 == 1
	oResumo:bLine := { || { 	aResumo[oResumo:nAT][1], aResumo[oResumo:nAT][2],;
								aResumo[oResumo:nAT][3], aResumo[oResumo:nAT][4],;
								aResumo[oResumo:nAT][5], aResumo[oResumo:nAT][6],;
								aResumo[oResumo:nAT][7], aResumo[oResumo:nAT][8],;
								aResumo[oResumo:nAT][9]} }
Else
	oResumo:bLine := { || { 	aResumo[oResumo:nAT][1], Space(15) + aResumo[oResumo:nAT][2],;
								aResumo[oResumo:nAT][3], Space(15) + aResumo[oResumo:nAT][4],;
								aResumo[oResumo:nAT][5], Space(15) + aResumo[oResumo:nAT][6]} }
Endif
oResumo:lColDrag := .T.
oResumo:lMChange := .T.
If lRefresh
	oResumo:Refresh()
Endif

@ 082, 002 	To aPosObj[1,3],aPosObj[1,4] LABEL STR0061 OF oFolder:aDialogs[4]; //"Quebras por Natureza"
			COLOR CLR_HBLUE PIXEL

If Len(aQuebras) = 0
	HELP (" ",1,"SEMDADOS")
	Return
Endif

lRefresh := .F.
If !lAnual .And. MV_PAR07 == 1
	If oQuebras = Nil
		oQuebras := TWBrowse():New( 090,4,aPosObj[1,4] - 8,aPosObj[1,3]-aPosObj[1,1]-130,,;		
		{"",AllTrim(aResumo[1][1]) + STR0065,AllTrim(aResumo[1][1]) + STR0066,;
			AllTrim(aResumo[2][1]) + STR0065,AllTrim(aResumo[2][1]) + STR0066,;
			AllTrim(aResumo[4][1]) + STR0065,AllTrim(aResumo[4][1]) + STR0066},;
			{75,48,55,48,55,48,55},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		oQuebras:aHeaders := {"",	AllTrim(aResumo[1][1]) + STR0065,;
									AllTrim(aResumo[1][1]) + STR0066,;
									AllTrim(aResumo[2][1]) + STR0065,;
									AllTrim(aResumo[2][1]) + STR0066,;
									AllTrim(aResumo[4][1]) + STR0065,;
									AllTrim(aResumo[4][1]) + STR0066}
		oQuebras:aColumns := {"",	AllTrim(aResumo[1][1]) + STR0065,;
									AllTrim(aResumo[1][1]) + STR0066,;
									AllTrim(aResumo[2][1]) + STR0065,;
									AllTrim(aResumo[2][1]) + STR0066,;
									AllTrim(aResumo[4][1]) + STR0065,;
									AllTrim(aResumo[4][1]) + STR0066}
		oQuebras:aColSizes := {75,48,55,48,55,48,55}
		lRefresh := .T.
	Endif
Else	
	If oQuebras = Nil
		oQuebras := TWBrowse():New( 090,4,aPosObj[1,4] - 8,aPosObj[1,3]-aPosObj[1,1]-130,,{"",aResumo[1][1],aResumo[2][1],aResumo[4][1]},{105,85,85,85},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	Else
		lRefresh := .T.
		oQuebras:aHeaders := {"",aResumo[1][1],aResumo[2][1],aResumo[4][1]}
		oQuebras:aColumns := {"",aResumo[1][1],aResumo[2][1],aResumo[4][1]}
		oQuebras:aColSizes := {105,85,85,85}
	Endif
Endif
oQuebras:lColDrag := .T.
oQuebras:lMChange := .T.
oQuebras:SetArray(aQuebras)

If !lAnual .And. MV_PAR07 == 1
	oQuebras:bLine := { || { 	aQuebras[oQuebras:nAT][1],;
								Trans(aQuebras[oQuebras:nAT][2],;
								TM(aQuebras[oQuebras:nAT][2],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][5],;
								TM(aQuebras[oQuebras:nAT][5],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][3],;
								TM(aQuebras[oQuebras:nAT][3],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][6],;
								TM(aQuebras[oQuebras:nAT][6],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][4],;
								TM(aQuebras[oQuebras:nAT][4],18,nDecs)),;
								Trans(aQuebras[oQuebras:nAT][7],;
								TM(aQuebras[oQuebras:nAT][7],18,nDecs)) } }
Else
	oQuebras:bLine := { || { 	aQuebras[oQuebras:nAT][1], Space(15) +;
								Trans(	aQuebras[oQuebras:nAT][2],;
										TM(aQuebras[oQuebras:nAT][2],18,nDecs)),;
								Space(15) + Trans(aQuebras[oQuebras:nAT][3],;
											TM(aQuebras[oQuebras:nAT][3],18,nDecs)),;
								Space(15) + Trans(aQuebras[oQuebras:nAT][4],;
											TM(aQuebras[oQuebras:nAT][4],18,nDecs))} }
Endif										

If lRefresh
	oQuebras:Refresh()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F720GRAPH
	Gera  os gráficos da rotina com o uso da classe FWChartFactory

@author Guilherme de Paula Santos
@since 15/03/2024
@version 1.0
*/
//-------------------------------------------------------------------  
Function F720GRAPH(oDlg,aDados,aSetAxis,lAnual,lAcumul)
Local nCont  as Numeric

Default lAcumul := .F.

	if oFolder:nOption == 1 .and. FWIsInCallStack("FINC720Res")
		return
	endIf

    if oFolder:nOption == 1
        if oChart1 == Nil
            oChart1 := FWChartFactory():New()
            oChart1:SetOwner(oDlg)
        else
            oChart1:DeActivate()
        endIf

        oChart := oChart1    
    elseIf oFolder:nOption == 2
        if oChart2 == Nil
            oChart2 := FWChartFactory():New()
            oChart2:SetOwner(oDlg)
        else
            oChart2:DeActivate()
        endIf

        oChart := oChart2
	else
		if oChart3 == Nil
            oChart3 := FWChartFactory():New()
            oChart3:SetOwner(oDlg)
        else
            oChart3:DeActivate()
        endIf

        oChart := oChart3
    endIf

    For nCont := 1 to Len(aDados)
        oChart:addSerie(aDados[nCont,1], aDados[nCont,2])
    Next

    oChart:SetXAxis( aSetAxis )

    oChart:setPicture("@E 9,999,999,999,999.99")
    oChart:setMask("R$ *@*")    
    oChart:SetLegend(CONTROL_ALIGN_LEFT)    
    oChart:setTitle(STR0001 + If(lAnual, STR0050, STR0051), CONTROL_ALIGN_CENTER) //" - Anual"###" - Mes"        
    oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)    
    oChart:EnableMenu(.T.)
    oChart:SetChartDefault(COLUMNCHART)
        
    If oFolder:nOption == 1
        oChart1 := oChart
        oChart1:Activate()
    elseIf oFolder:nOption == 2
        oChart2 := oChart
        oChart2:Activate()
	else
		oChart3 := oChart
        oChart3:Activate()
    endIf
return
