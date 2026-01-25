#INCLUDE "protheus.ch" 
#INCLUDE "gemr120.ch"

#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GEMR120   ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 08/10/2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao das Correcoes dos Contratos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMR120()
Local oReport

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

Ajusta()

If FindFunction("TRepInUse") .And. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	Return GEMR120R3() // Executa versão anterior do fonte
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Daniel Tadashi Batoriº Data ³  12/09/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡…o ³Correcoes Monetarias                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oDtCorrecao
Local oContrato
Local oAnalit
Local cPerg := "GER120"
Local nTam  := TamSX3("LIW_PREFIX")[1] + TamSX3("LIW_NUM")[1] + TamSX3("LIW_PARCEL")[1] + 2
Local cPict := PesqPict("LIW","LIW_BASAMO")

oReport := TReport():New("GEMR120",STR0002,cPerg,;
				{|oReport| ReportPrint(oReport)},STR0001)
//STR0002 "Correções Monetárias por Contratos"
//STR0001 "Este relatório lista os valores das correções monetárias por contratos"

pergunte("GER120",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Correção monetária de                                       ³
//³ MV_PAR02 : Correção monetária até                                      ³
//³ MV_PAR03 : Contrato de                                                 ³
//³ MV_PAR04 : Contrato ate                                                ³
//³ MV_PAR05 : Cliente de                                                  ³
//³ MV_PAR06 : Cliente ate                                                 ³
//³ MV_PAR07 : Modo ? (Sintetico/Analitico)                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDtCorrecao := TRSection():New(oReport, STR0003, {"LIX"}, , .F., .F.) //"Data da CM"
TRCell():New(oDtCorrecao, "LIW_DTREF","LIW",STR0007/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,) //"Mes/Ano CM"
oDtCorrecao:SetLinesBefore(2)

oContrato := TRSection():New(oDtCorrecao, STR0004, {}, , .F., .F.) //"Correções dos Contratos"
TRCell():New(oContrato, "LIX_NCONTR" ,"LIX",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oContrato, "A1_COD"     ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oContrato, "A1_LOJA"    ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oContrato, "A1_NOME"    ,"SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oContrato, "LIW_TAXA"   ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")
TRCell():New(oContrato, "LIW_INDICE" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oContrato, "LIW_BASAMO" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oContrato, "LIW_VLRAMO" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oContrato, "VALOR_ATUAL","LIW",STR0006/*Titulo*/,cPict/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) //"Valor corrigido"
TRFunction():New(oContrato:Cell("LIW_BASAMO") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("LIW_VLRAMO") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oContrato:Cell("VALOR_ATUAL"),,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
oContrato:SetLeftMargin(5)
oContrato:SetTotalInLine(.F.)

oAnalit := TRSection():New(oContrato, STR0012, {}, , .F., .F.) //"Correções das Parcelas"
TRCell():New(oAnalit, "TITULO"     ,     ,STR0013/*Titulo*/,/*Picture*/,nTam/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT") //"Pref./Tít./Parc."
TRCell():New(oAnalit, "LIX_DTVENC" ,"LIX",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAnalit, "LJO_TPDESC" ,"LJO",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,,,"RIGHT")
TRCell():New(oAnalit, "LIW_BASAMO" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAnalit, "LIW_VLRAMO" ,"LIW",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oAnalit, "VALOR_ATUAL","LIW",STR0006/*Titulo*/,cPict/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) //"Valor corrigido"
oAnalit:SetLeftMargin(10)

oReport:SetTotalInLine(.F.)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Daniel Batori          ³ Data ³12/09/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)
Local oDtCorrecao := oReport:Section(1)
Local oContrato   := oReport:Section(1):Section(1)
Local oAnalit     := oReport:Section(1):Section(1):Section(1)
Local cFiltro := ""
Local cFilLIW := xFilial("LIW")
Local cFilLJO := xFilial("LJO")
Local cFilLIX := xFilial("LIX")
Local cFilSA1 := xFilial("SA1")
Local cFilSE1 := xFilial("SE1")
Local cFilLIT := xFilial("LIT")
Local nX      := 0
Local nPos    := 0
Local cAnoMesDe  := SubStr(Mv_Par01,4,4)+SubStr(Mv_Par01,1,2)
Local cAnoMesAte := SubStr(Mv_Par02,4,4)+SubStr(Mv_Par02,1,2)
Local aSintet    := {}
Local aAnalit    := {}
Local nTam    := TamSX3("LIW_PREFIX")[1] + TamSX3("LIW_NUM")[1] + TamSX3("LIW_PARCEL")[1] + 2
Local cDtAnt  := ""
#IFDEF TOP
	Local cAliasQry := GetNextAlias()
#ENDIF

//Valida perguntas
If !Valida()
	Return
EndIf

#IFDEF TOP

   If !Empty(Mv_Par03)
   	cFiltro += " AND LIX_NCONTR >= '" + Mv_Par03 + "' "
   EndIf
	If !(Upper(Mv_Par04)==Replicate("Z",Len(Mv_Par04)))
		cFiltro += " AND LIX_NCONTR <= '" + Mv_Par04 + "' "
	EndIf
   If !Empty(Mv_Par05)
   	cFiltro += " AND LIT_CLIENT >= '" + Mv_Par05 + "' "
   EndIf
	If !(Upper(Mv_Par06)==Replicate("Z",Len(Mv_Par06)))
		cFiltro += " AND LIT_CLIENT <= '" + Mv_Par06 + "' "
	EndIf

	cFiltro := "% " + cFiltro + " %"

	BeginSql Alias cAliasQry
		SELECT LIX_DTVENC, LIX_NCONTR, LIX_PREFIX, LIX_NUM, LIX_PARCEL, LIX_TIPO, LIX_ITCND, LIT_CLIENT, LIT_LOJA
		FROM %table:LIX% LIX
				JOIN %table:LIT% LIT	ON LIX_NCONTR = LIT_NCONTR
		WHERE LIX_FILIAL = %xFilial:LIX% AND
				LIT_FILIAL = %xFilial:LIT% AND
				LIT_STATUS = '1' AND
				LIX.%NotDel% AND
				LIT.%NotDel%
				%Exp:cFiltro%
		ORDER BY LIX_DTVENC, LIX_NUM, LIX_PARCEL
	EndSQL

	(cAliasQry)->(DbGotop())
	LIW->(DbSetOrder(1)) //LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	LJO->(DbSetOrder(1)) //LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO	
	
	While !(cAliasQry)->(Eof())
      
		If SE1->(DbSeek(cFilSE1+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))) .And. ;
			!(SE1->E1_SALDO==0)

			LIW->(DbSeek(cFilLIW+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL)))
	
			While cFilLIW+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL) == LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL)
				
				If LIW->LIW_DTREF >= cAnoMesDe .And. LIW->LIW_DTREF <= cAnoMesAte
			
					SA1->(DbSeek(cFilSA1 + (cAliasQry)->(LIT_CLIENT+LIT_LOJA) ))
			
					nPos := aScan(aSintet,{|x| x[1]+x[2]==LIW->LIW_DTREF+(cAliasQry)->LIX_NCONTR})
					If nPos==0
						aAdd(aSintet,{LIW->LIW_DTREF,;
									(cAliasQry)->LIX_NCONTR,;
									SA1->A1_COD,;
									SA1->A1_LOJA,;
									LIW->LIW_TAXA,;
									LIW->LIW_INDICE,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
									})
					Else
						aSintet[nPos,7] += LIW->(LIW_BASAMO+LIW_BASJUR)
						aSintet[nPos,8] += LIW->(LIW_VLRAMO+LIW_VLRJUR)
						aSintet[nPos,9] += LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR)
					EndIf
	
					LJO->(DbSeek(cFilLJO + (cAliasQry)->(LIX_NCONTR+LIX_ITCND) ))						
					aAdd(aAnalit,{LIW->LIW_DTREF,;
									(cAliasQry)->LIX_NCONTR,;
									Padl( LIW->(AllTrim(LIW_PREFIX)+'/'+LIW_NUM+'/'+LIW_PARCEL), nTam),;
									DtoC(SE1->E1_VENCTO),;
									LJO->LJO_TPDESC,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
								})
				EndIf
				LIW->(DbSkip())
			EndDo
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	
#ELSE

	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	LIT->(DbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
	LIW->(DbSetOrder(1)) //LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	LJO->(DbSetOrder(1)) //LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	LIX->(DbSetOrder(3)) //LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	LIX->(DbSeek(cFilLIX+Mv_Par03,.T.))

	While !(LIX->(Eof())) .And. LIX->(LIX_FILIAL+LIX_NCONTR) <= cFilLIX+Mv_Par04

		If LIT->(DbSeek(cFilLIT+LIX->LIX_NCONTR)) .And.;
			LIT->LIT_CLIENT >= Mv_Par05 .And. LIT->LIT_CLIENT <= Mv_Par06 .And. ;
			LIT->LIT_STATUS == "1"
				
			If SE1->(DbSeek(cFilSE1+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))) .And. ;
				!(SE1->E1_SALDO==0)

				If LIW->(DbSeek(cFilLIW+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL)))

					While cFilLIW+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL) == LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL)
				
						If LIW->LIW_DTREF >= cAnoMesDe .And. LIW->LIW_DTREF <= cAnoMesAte
				
							LJO->(DbSeek(cFilLJO + LIX->(LIX_NCONTR+LIX_ITCND)))

							nPos := aScan(aSintet,{|x| x[1]+x[2]==LIW->LIW_DTREF+LIX->LIX_NCONTR})
							If nPos==0
								nPos++
								aAdd(aSintet,{LIW->LIW_DTREF,;
									LIX->LIX_NCONTR,;
									LIT->LIT_CLIENT,;
									LIT->LIT_LOJA,;
									LIW->LIW_TAXA,;
									LIW->LIW_INDICE,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
									})
							Else
								aSintet[nPos,7] += LIW->(LIW_BASAMO+LIW_BASJUR)
								aSintet[nPos,8] += LIW->(LIW_VLRAMO+LIW_VLRJUR)
								aSintet[nPos,9] += LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR)
							EndIf
							
							aAdd(aAnalit,{LIW->LIW_DTREF,;
									LIX->LIX_NCONTR,;
									Padl( LIW->(AllTrim(LIW_PREFIX)+'/'+LIW_NUM+'/'+LIW_PARCEL), nTam),;
									DtoC(SE1->E1_VENCTO),;
									LJO->LJO_TPDESC,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
								})
							
						EndIf
						LIW->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		
		LIX->(DbSkip())
	EndDo

#ENDIF

oDtCorrecao:Cell("LIW_DTREF"):SetBlock({|| SubStr(aSintet[nX,1],5,2)+"/"+SubStr(aSintet[nX,1],1,4) })

oContrato:Cell("LIX_NCONTR"):SetBlock({|| aSintet[nX,2] })
oContrato:Cell("A1_COD")    :SetBlock({|| SA1->A1_COD })
oContrato:Cell("A1_LOJA")   :SetBlock({|| SA1->A1_LOJA })
oContrato:Cell("A1_NOME")   :SetBlock({|| PadL(SA1->A1_NOME,25) })
oContrato:Cell("LIW_TAXA")  :SetBlock({|| aSintet[nX,5] })
oContrato:Cell("LIW_INDICE"):SetBlock({|| aSintet[nX,6] })
oContrato:Cell("LIW_BASAMO"):SetBlock({|| aSintet[nX,7] })
oContrato:Cell("LIW_VLRAMO"):SetBlock({|| aSintet[nX,8] })
oContrato:Cell("VALOR_ATUAL"):SetBlock({|| aSintet[nX,9] })

TRPosition():New(oContrato,"SA1",1, {|| xFilial("SA1")+aSintet[nX,3]+aSintet[nX,4] })

oAnalit:Cell("TITULO")     :SetBlock({|| aAnalit[nPos,3] })
oAnalit:Cell("LIX_DTVENC") :SetBlock({|| aAnalit[nPos,4] })
oAnalit:Cell("LJO_TPDESC") :SetBlock({|| aAnalit[nPos,5] })
oAnalit:Cell("LIW_BASAMO") :SetBlock({|| aAnalit[nPos,6] })
oAnalit:Cell("LIW_VLRAMO") :SetBlock({|| aAnalit[nPos,7] })
oAnalit:Cell("VALOR_ATUAL"):SetBlock({|| aAnalit[nPos,8] })

aSort(aSintet,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
aSort(aAnalit,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })

oDtCorrecao:Init()
oContrato:Init()
For nX := 1 to Len(aSintet)

	If !(aSintet[nX,1]==cDtAnt)
		oContrato:Finish()
		oDtCorrecao:Finish()
		oDtCorrecao:Init()
		oDtCorrecao:PrintLine()
		cDtAnt := aSintet[nX,1]
		oContrato:Init()
	EndIf

	oContrato:PrintLine()
	
	If MV_PAR07 == 2 //analitico
		oAnalit:Init()
		nPos := aScan(aAnalit,{|x| x[1]+x[2]==aSintet[nX,1]+aSintet[nX,2]})
		While nPos <= Len(aAnalit) .And. ;
			(aAnalit[nPos,1]+aAnalit[nPos,2]==aSintet[nX,1]+aSintet[nX,2])
			oAnalit:PrintLine()
			nPos++
		EndDo
		oAnalit:Finish()
		oReport:SkipLine()
	EndIf

Next nX

oContrato:Finish()
oDtCorrecao:Finish()
	
Return (.T.)






//----------------------------RELEASE 3-------------------------------------//




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GEMR120R3³ Autor ³ Daniel Tadashi Batori ³ Data ³ 08.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao das Correcoes dos Contratos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GEMR120R3()
Local cDesc1   := STR0001 //"Este relatório lista os valores das correções monetárias por contratos"
Local cDesc2   := "" 
Local cDesc3   := ""
Local cString  := "LIX"
Local lDic     := .F.
Local lComp    := .T.
Local lFiltro  := .F.
Local wnrel    := "gemr120"

Private NomeProg:= "gemr120"
Private Titulo  := STR0002 //"Correções Monetárias por Contratos"
Private Tamanho := "M"     // P/M/G
Private Cabec1  := STR0005 //"Contrato        Lj Codigo Nome                       Taxa      Indice       Vlr.Base  CM.Amort.  Vlr.Corrigido"
//STR0011
Private Cabec2  := ""
Private Limite  := 132   // 80/132/220
Private nLi     := 100   // Contador de Linhas
Private cPerg   := "GER120"  // Pergunta do Relatorio
Private aReturn := { STR0009, 1, STR0010, 1, 2, 1, ,1 } //"Zebrado"###"Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N§ de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas                                                                                             	
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Correção monetária de                                       ³
//³ MV_PAR02 : Correção monetária até                                      ³
//³ MV_PAR03 : Contrato de                                                 ³
//³ MV_PAR04 : Contrato ate                                                ³
//³ MV_PAR05 : Cliente de                                                  ³
//³ MV_PAR06 : Cliente ate                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,"",lComp,Tamanho,lFiltro)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter() //Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

RptStatus( {|lEnd| gemr120Proc(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Set Device To Screen

If ( aReturn[5] = 1 )
	dbCommitAll()
	Set Printer To
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gemr120Proc³ Autor ³ Daniel Tadashi Batori        ³ Data ³08.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa o processamento do relatorio.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function gemr120Proc(lEnd,wnRel,cString,nomeprog,Titulo)
Local aArea   := GetArea()
Local cFilLIW := xFilial("LIW")
Local cFilLJO := xFilial("LJO")
Local cFilSA1 := xFilial("SA1")
Local cFilSE1 := xFilial("SE1")
Local nTam    := TamSX3("LIW_PREFIX")[1] + TamSX3("LIW_NUM")[1] + TamSX3("LIW_PARCEL")[1] + 2
Local nX      := 0
Local cDtAnt  := ""
Local nSubBas := 0
Local nSubAmo := 0
Local nTotBas := 0
Local nTotAmo := 0
Local nLinMax := 58
Local cTit2   :=  STR0011 //"Pref/Tit/Parc   Dt.Vencto.  Desc.Parc.       Vlr.Base      CM.Amort.   Vlr.Corrigido"
Local cAnoMesDe  := SubStr(Mv_Par01,4,4)+SubStr(Mv_Par01,1,2)
Local cAnoMesAte := SubStr(Mv_Par02,4,4)+SubStr(Mv_Par02,1,2)
Local cContrAnt  := ""
Local nPos       := 0
Local aSintet     := {}
Local aAnalit    := {}
Local cData      := ""
Local lPrintTot  := .F.
Local nSTotBase  := 0
Local nSTotCM    := 0
Local nTotBase   := 0
Local nTotCM     := 0
#IFDEF TOP
	Local cFiltro   := ""
	Local cAliasQry := GetNextAlias()
#ELSE
	Local cFilLIX := xFilial("LIX")
	Local cFilLIT := xFilial("LIT")
#ENDIF

//Valida perguntas
If !Valida()
	Return
EndIf

#IFDEF TOP

   If !Empty(Mv_Par03)
   	cFiltro += " AND LIX_NCONTR >= '" + Mv_Par03 + "' "
   EndIf
	If !(Upper(Mv_Par04)==Replicate("Z",Len(Mv_Par04)))
		cFiltro += " AND LIX_NCONTR <= '" + Mv_Par04 + "' "
	EndIf
   If !Empty(Mv_Par05)
   	cFiltro += " AND LIT_CLIENT >= '" + Mv_Par05 + "' "
   EndIf
	If !(Upper(Mv_Par06)==Replicate("Z",Len(Mv_Par06)))
		cFiltro += " AND LIT_CLIENT <= '" + Mv_Par06 + "' "
	EndIf

	cFiltro := "% " + cFiltro + " %"

	BeginSql Alias cAliasQry
		SELECT LIX_DTVENC, LIX_NCONTR, LIX_PREFIX, LIX_NUM, LIX_PARCEL, LIX_TIPO, LIX_ITCND, LIT_CLIENT, LIT_LOJA
		FROM %table:LIX% LIX
				JOIN %table:LIT% LIT	ON LIX_NCONTR = LIT_NCONTR
		WHERE LIX_FILIAL = %xFilial:LIX% AND
				LIT_FILIAL = %xFilial:LIT% AND
				LIT_STATUS = '1' AND
				LIX.%NotDel% AND
				LIT.%NotDel%
				%Exp:cFiltro%
		ORDER BY LIX_DTVENC, LIX_NUM, LIX_PARCEL
	EndSQL

	(cAliasQry)->(DbGotop())
	LIW->(DbSetOrder(1)) //LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	LJO->(DbSetOrder(1)) //LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO	
	
	While !(cAliasQry)->(Eof())
      
		If SE1->(DbSeek(cFilSE1+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))) .And. ;
			!(SE1->E1_SALDO==0)

			LIW->(DbSeek(cFilLIW+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL)))
	
			While cFilLIW+(cAliasQry)->(LIX_PREFIX+LIX_NUM+LIX_PARCEL) == LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL)
				
				If LIW->LIW_DTREF >= cAnoMesDe .And. LIW->LIW_DTREF <= cAnoMesAte
			
					SA1->(DbSeek(cFilSA1 + (cAliasQry)->(LIT_CLIENT+LIT_LOJA) ))
			
					nPos := aScan(aSintet,{|x| x[1]+x[2]==LIW->LIW_DTREF+(cAliasQry)->LIX_NCONTR})
					If nPos==0
						aAdd(aSintet,{LIW->LIW_DTREF,;
									(cAliasQry)->LIX_NCONTR,;
									SA1->A1_LOJA,;
									SA1->A1_COD,;
									SA1->A1_NOME,;
									LIW->LIW_TAXA,;
									LIW->LIW_INDICE,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
									})
					Else
						aSintet[nPos,8] += LIW->(LIW_BASAMO+LIW_BASJUR)
						aSintet[nPos,9] += LIW->(LIW_VLRAMO+LIW_VLRJUR)
						aSintet[nPos,10] += LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR)
					EndIf
	
					LJO->(DbSeek(cFilLJO + (cAliasQry)->(LIX_NCONTR+LIX_ITCND) ))						
					aAdd(aAnalit,{LIW->LIW_DTREF,;
									(cAliasQry)->LIX_NCONTR,;
									Padl( LIW->(AllTrim(LIW_PREFIX)+'/'+LIW_NUM+'/'+LIW_PARCEL), nTam),;
									DtoC(SE1->E1_VENCTO),;
									LJO->LJO_TPDESC,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
								})
				EndIf
				LIW->(DbSkip())
			EndDo
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

#ELSE

	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	LIT->(DbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
	LIW->(DbSetOrder(1)) //LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	LJO->(DbSetOrder(1)) //LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	LIX->(DbSetOrder(3)) //LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	LIX->(DbSeek(cFilLIX+Mv_Par03,.T.))

	While !(LIX->(Eof())) .And. LIX->(LIX_FILIAL+LIX_NCONTR) <= cFilLIX+Mv_Par04

		If LIT->(DbSeek(cFilLIT+LIX->LIX_NCONTR)) .And.;
			LIT->LIT_CLIENT >= Mv_Par05 .And. LIT->LIT_CLIENT <= Mv_Par06 .And. ;
			LIT->LIT_STATUS == "1"
				
			If SE1->(DbSeek(cFilSE1+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))) .And. ;
				!(SE1->E1_SALDO==0)

				If LIW->(DbSeek(cFilLIW+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL)))

					While cFilLIW+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL) == LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL)
				
						If LIW->LIW_DTREF >= cAnoMesDe .And. LIW->LIW_DTREF <= cAnoMesAte
				
							SA1->(DbSeek(cFilSA1 + LIT->(LIT_CLIENT+LIT_LOJA) ))
							LJO->(DbSeek(cFilLJO + LIX->(LIX_NCONTR+LIX_ITCND)))

							nPos := aScan(aSintet,{|x| x[1]+x[2]==LIW->LIW_DTREF+LIX->LIX_NCONTR})
							If nPos==0
								nPos++
								aAdd(aSintet,{LIW->LIW_DTREF,;
									LIX->LIX_NCONTR,;
									SA1->A1_LOJA,;
									SA1->A1_COD,;
									SA1->A1_NOME,;
									LIW->LIW_TAXA,;
									LIW->LIW_INDICE,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
									})
							Else
								aSintet[nPos,8]  += LIW->(LIW_BASAMO+LIW_BASJUR)
								aSintet[nPos,9]  += LIW->(LIW_VLRAMO+LIW_VLRJUR)
								aSintet[nPos,10] += LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR)
							EndIf
							
							aAdd(aAnalit,{LIW->LIW_DTREF,;
									LIX->LIX_NCONTR,;
									Padl( LIW->(AllTrim(LIW_PREFIX)+'/'+LIW_NUM+'/'+LIW_PARCEL), nTam),;
									DtoC(SE1->E1_VENCTO),;
									LJO->LJO_TPDESC,;
									LIW->(LIW_BASAMO+LIW_BASJUR),;
									LIW->(LIW_VLRAMO+LIW_VLRJUR),;
									LIW->(LIW_BASAMO+LIW_VLRAMO+LIW_BASJUR+LIW_VLRJUR);
								})
							
						EndIf
						LIW->(DbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		
		LIX->(DbSkip())
	EndDo
	
#ENDIF

aSort(aSintet,,,{|x,y| x[1]+x[2] < y[1]+y[2] })
aSort(aAnalit,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })

For nX := 1 to Len(aSintet)
	QuebrPag(aSintet[nX,1],cDtAnt,nLinMax)
	
	If !(aSintet[nX,1]==cDtAnt)
		//se for o primeiro contrato entao nao imprime o total
		If !(cDtAnt=="")
			@ nLi, 000 PSAY __PrtThinLine()
			nLi++
			@ nLi, 045 PSay STR0014 + SubStr(aSintet[nX-1,1],5,2)+"/"+SubStr(aSintet[nX-1,1],1,4) //"SubTotal de "
			@ nLi, 071 PSay Transform( nSTotBase, "@E 99,999,999.99")       //valor base a ser aplicada a CM
			@ nLi, 086 PSay Transform( nSTotCM,   "@E 99,999.99")           //valor da CM (amortizacao)
			@ nLi, 097 PSay Transform( nSTotBase+nSTotCM,"@E 99,999,999.99")//valor do titulo com a CM
			nSTotBase := 0
			nSTotCM   := 0
			nLi++
		EndIf
		nLi++
		cData := SubStr(aSintet[nX,1],5,2)+"/"+SubStr(aSintet[nX,1],1,4)
		@ nLi, 000 PSay STR0007 + " : " + cData //"Mes/Ano CM"
		nLi++
		nLi++
		cDtAnt := aSintet[nX,1]
		QuebrPag(aSintet[nX,1],cDtAnt,nLinMax)
	EndIf

	@ nLi, 000 PSay aSintet[nX,2]         //contrato
	@ nLi, 016 PSay aSintet[nX,3]         //loja do cliente
	@ nLi, 019 PSay aSintet[nX,4]         //codigo do cliente
	@ nLi, 026 PSay PadL(aSintet[nX,5],25)//nome do cliente(25)
	@ nLi, 053 PSay aSintet[nX,6]         //cod da taxa(6)
	@ nLi, 061 PSay Transform( aSintet[nX,7], "@E 999.9999")      //indice da taxa aplicada na CM
	@ nLi, 071 PSay Transform( aSintet[nX,8], "@E 99,999,999.99") //valor base a ser aplicada a CM
	@ nLi, 086 PSay Transform( aSintet[nX,9], "@E 99,999.99")     //valor da CM (amortizacao)
	@ nLi, 097 PSay Transform( aSintet[nX,10],"@E 99,999,999.99") //valor do titulo com a CM
	nLi++

	nSTotBase += aSintet[nX,8]
	nSTotCM   += aSintet[nX,9]
	nTotBase  += aSintet[nX,8]
	nTotCM    += aSintet[nX,9]

	If MV_PAR07 == 2 //analitico
		nLi++
		@ nLi, 005 PSay cTit2
		nLi++
		@ nLi, 000 PSAY __PrtThinLine()
		nLi++
		nPos := aScan(aAnalit,{|x| x[1]+x[2]==aSintet[nX,1]+aSintet[nX,2]})
		While nPos <= Len(aAnalit) .And. ;
			(aAnalit[nPos,1]+aAnalit[nPos,2]==aSintet[nX,1]+aSintet[nX,2])
	
			If nLi >= nLinMax
				QuebrPag(aSintet[nX,1],cDtAnt,nLinMax)
				@ nLi, 005 PSay cTit2
				nLi++
				@ nLi, 000 PSAY __PrtThinLine()
				nLi++
			EndIf
		
			@ nLi, 005 PSay aAnalit[nPos,3]         //prefix/numero/parc do titulo(14)
			@ nLi, 021 PSay aAnalit[nPos,4]         //data de vencto do titulo
			@ nLi, 033 PSay aAnalit[nPos,5]         //descricao do tipo de parcela(10)
			@ nLi, 045 PSay Transform( aAnalit[nPos,6], "@E 99,999,999.99") //valor base a ser aplicada a CM(13)
			@ nLi, 064 PSay Transform( aAnalit[nPos,7], "@E 99,999.99")     //valor da CM (amortizacao)(9)
			@ nLi, 076 PSay Transform( aAnalit[nPos,8], "@E 99,999,999.99") //valor do titulo com a CM(13)
			nLi++
			nPos++
		EndDo
		nLi++
	EndIf

Next nX

QuebrPag(cDtAnt,cDtAnt,nLinMax)
nLi++
@ nLi, 000 PSAY __PrtThinLine()
nLi++
@ nLi, 045 PSay STR0014 + SubStr(aSintet[nX-1,1],5,2)+"/"+SubStr(aSintet[nX-1,1],1,4) //"SubTotal de "
@ nLi, 071 PSay Transform( nSTotBase, "@E 99,999,999.99")       //valor base a ser aplicada a CM
@ nLi, 086 PSay Transform( nSTotCM,   "@E 99,999.99")           //valor da CM (amortizacao)
@ nLi, 097 PSay Transform( nSTotBase+nSTotCM,"@E 99,999,999.99")//valor do titulo com a CM

QuebrPag(cDtAnt,cDtAnt,nLinMax)
nLi++
nLi++
@ nLi, 000 PSAY __PrtThinLine()
nLi++
@ nLi, 045 PSay STR0015 //"Total"
@ nLi, 071 PSay Transform( nTotBase, "@E 99,999,999.99")      //valor base a ser aplicada a CM
@ nLi, 086 PSay Transform( nTotCM,   "@E 99,999.99")          //valor da CM (amortizacao)
@ nLi, 097 PSay Transform( nTotBase+nTotCM,"@E 99,999,999.99")//valor do titulo com a CM



Roda(0,"",Tamanho)
RestArea(aArea)				
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QuebrPag ºAutor  ³Daniel Tadashi Batori º Data ³08/10/2007   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a quebra de pagina                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gemr120                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QuebrPag(cDtAtu,cDtAnt,nLinMax)
If nLi >= nLinMax
	nLi := 0
	nLi := Cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,CHRCOMP)
	If cDtAtu==cDtAnt
		nLi++
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Valida    ºAutor  ³Daniel Tadashi Batori º Data ³12/09/2007   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as perguntas do usuario                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gemr120                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Valida()
Local lOk := .T.
Local cAuxMv1 := SubStr(Mv_Par01,4,4) + SubStr(Mv_Par01,1,2)
Local cAuxMv2 := SubStr(Mv_Par02,4,4) + SubStr(Mv_Par02,1,2)

If cAuxMv1  > cAuxMv2  .Or.;
	Mv_Par03 > Mv_Par04 .Or.;
	Mv_Par05 > Mv_Par06
	lOk := .F.
	Alert(STR0008) //"Verifique os parâmetros do relatório!"
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ajusta    ºAutor  ³Daniel Tadashi Batori º Data ³12/09/2007   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Insere novas perguntas ao sx1                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gemr120                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ajusta()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aPergs   := {}

Aadd( aHelpPor, 'Range do período a ser exibido no       ' )
Aadd( aHelpPor, 'relatório (MM/AAAA).                    ' )
Aadd( aHelpSpa, 'Range do período a ser exibido no       ' )
Aadd( aHelpSpa, 'relatório (MM/AAAA).                    ' )
Aadd( aHelpEng, 'Range do período a ser exibido no       ' )
Aadd( aHelpEng, 'relatório (MM/AAAA).                    ' )
Aadd(aPergs,{"Correção monetária de ?","Correção monetária de ?","Correção monetária de ?","mv_ch1","C",7,0,0,"G","NaoVazio()","mv_par01","","",;
				"","","","","","","","","","","","","","","","","","","","","","","","","S","","@E 99/9999",aHelpPor,aHelpEng,aHelpSpa})
Aadd(aPergs,{"Correção monetária até ?","Correção monetária até ?","Correção monetária até ?","mv_ch2","C",7,0,0,"G","NaoVazio()","mv_par02","","",;
				"","","","","","","","","","","","","","","","","","","","","","","","","S","","@E 99/9999",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, 'Range do contrato a ser exibido no      ' )
Aadd( aHelpPor, 'relatório.                              ' )
Aadd( aHelpSpa, 'Range do contrato a ser exibido no      ' )
Aadd( aHelpSpa, 'relatório.                              ' )
Aadd( aHelpEng, 'Range do contrato a ser exibido no      ' )
Aadd( aHelpEng, 'relatório.                              ' )
Aadd(aPergs,{"Contrato de ?","Contrato de ?","Contrato de ?","mv_ch3","C",15,0,0,"G","","mv_par03","","",;
				"","","","","","","","","","","","","","","","","","","","","","","LIT","","S","","",aHelpPor,aHelpEng,aHelpSpa})
Aadd(aPergs,{"Contrato até ?","Contrato até ?","Contrato até ?","mv_ch4","C",15,0,0,"G","NaoVazio()","mv_par04","","",;
				"","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","LIT","","S","","",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, 'Range do cliente a ser exibido no       ' )
Aadd( aHelpPor, 'relatório.                              ' )
Aadd( aHelpSpa, 'Range do cliente a ser exibido no       ' )
Aadd( aHelpSpa, 'relatório.                              ' )
Aadd( aHelpEng, 'Range do cliente a ser exibido no       ' )
Aadd( aHelpEng, 'relatório.                              ' )
Aadd(aPergs,{"Cliente de ?","Cliente de ?","Cliente de ?","mv_ch5","C",6,0,0,"G","","mv_par05","","",;
				"","","","","","","","","","","","","","","","","","","","","","","SA1","","S","","",aHelpPor,aHelpEng,aHelpSpa})
Aadd(aPergs,{"Cliente até ?","Cliente até ?","Cliente até ?","mv_ch6","C",6,0,0,"G","NaoVazio()","mv_par06","","",;
				"","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","S","","",aHelpPor,aHelpEng,aHelpSpa})

aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, 'Sintético para mostrar apenas as        ' )
Aadd( aHelpPor, 'correções dos contratos ou analítico    ' )
Aadd( aHelpPor, 'para mostrar os títulos de cada contrato' )
Aadd( aHelpPor, 'ao relatório.                           ' )
Aadd( aHelpSpa, 'Sintético para mostrar apenas as        ' )
Aadd( aHelpSpa, 'correções dos contratos ou analítico    ' )
Aadd( aHelpSpa, 'para mostrar os títulos de cada contrato' )
Aadd( aHelpSpa, 'ao relatório.                           ' )
Aadd( aHelpEng, 'Sintético para mostrar apenas as        ' )
Aadd( aHelpEng, 'correções dos contratos ou analítico    ' )
Aadd( aHelpEng, 'para mostrar os títulos de cada contrato' )
Aadd( aHelpEng, 'ao relatório.                           ' )
Aadd(aPergs,{"Modo ?","Modo ?","Modo ?","mv_ch07","N",1,0,0,"C","","mv_par07","Sintético","",;
				"","","","Analítico","","","","","","","","","","","","","","","","","","","","","S","","",aHelpPor,aHelpEng,aHelpSpa})

AjustaSX1("GER120",aPergs)

Return
