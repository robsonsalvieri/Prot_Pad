#include "protheus.ch"

Static oQryExec := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM100TIM   บAutor  ณRubens Joao Pante      บ Data ณ  23/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescricao ณExecuta a funcao propria a cada pais para o calculo do Timbre  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณMATA101                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function M100TIM(cCalculo,nItem,aInfo)
Local aItemInfo, aImposto, nDesconto, lXFis,xRet
Local aCfg		:= {}
Local dDtProc	:= Ctod("//")
Local nMoeda	:= 1
Local nTxMoeda	:= 1
Local nX		:= 0

If Type("dDEmissao")=="D"
	dDtProc := dDEmissao
Else
	dDtProc:= dDatabase
Endif

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

If lXFis
	xRet:=M100TIMFIS(cCalculo,nItem,aInfo)
Else
	aItemINFO := ParamIxb[1]
	aImposto  := ParamIxb[2]
	//mesmo tratamento da impgener
	If Substr(cModulo,1,3) $ "FAT|OMS"
		If Type("L468NPED")=="L" .And. !l468NPed
			nMoeda	 := SF2->F2_MOEDA
			nTxMoeda := SF2->F2_TXMOEDA
		Else
			nMoeda   := SC5->C5_MOEDA
			nTxMoeda := SC5->C5_TXMOEDA
		Endif
		If nMoeda > 1 .and. nTxMoeda <= 1
			nTxMoeda := RecMoeda(dDataBase,nMoeda)
		Endif
	Endif
	//Tira os descontos se for pelo liquido .Bruno
	If Subs(aImposto[5],4,1) == "S"  .And. Len(AIMPOSTO) == 18 .And. ValType(aImposto[18])=="N"
		nDesconto	:=	aImposto[18]
	Else
		nDesconto	:=	0
	Endif
	aCfg := M100TimCfg(aImposto[1],,dDtProc,.T.,.F.)
	aImposto[2] := aCfg[1]
		aImposto[3] := (aItemINFO[3] + aItemINFO[4] + aItemINFO[5] - nDesconto)
	
	nMinimo := xMoeda(aImposto[3],nMoeda,1,,,,nTxMoeda)
	
	If nMinimo > aCfg[2]
		aImposto[4] := aImposto[3] * (aImposto[2]/100)
	Else
		aImposto[4] := 0
	Endif
	xRet:=aImposto
Endif
Return xRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM100TIMFISบAutor  ณRubens Joao Pante      บ Data ณ  23/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescricao ณExecuta a funcao propria a cada pais para o calculo do Timbre  ณฑฑ
ฑฑณ          ณAlterado para ser utilizado juntamente a MATXFIS()             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณMATA101                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function M100TIMFIS(cCalculo,nItem,aInfo)
Local nVRet		:= 0
Local nBase		:= 0
Local nAliq		:= 0
Local nMoeda	:= 1
Local nTxMoeda	:= 1
Local nMinimo	:= 0
Local aCfg		:= {}
Local dDtProc	:= Ctod("//")
Local aNfItem	:= {}
Local nX		:= 0
Local nAlqMin	:= 0

If Type("dDEmissao")=="D"
	dDtProc := dDEmissao
Else
	dDtProc:= dDatabase
Endif

If Type("aCols") == "A"
	aNfItem := aClone(aCols)
EndIf

Do Case
	Case cCalculo=="A"
		aCfg := M100TimCfg(aInfo[1],,dDtProc)
		nVRet := aCfg[1]
	Case cCalculo=="B"	
		aCfg := M100TimCfg(aInfo[1],,dDtProc,,.T.)
		nVRet := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If aCfg[4] == "S"
			nVRet -= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Case cCalculo=="V"
		nBase := MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
		If nBase > 0
			aCfg := M100TimCfg(aInfo[1],MaFisRet(nItem,"IT_TES"),dDtProc,.T.,.T.)
			nVRet := 0
			nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			If aCfg[3] == "T"
				nBase := MaRetBsIm(aNfItem, aInfo[2])
			Endif
			nMoeda := MaFisRet(,"NF_MOEDA")
			If nMoeda > 1
				nTxMoeda := MaFisRet(,"NF_TXMOEDA")
				nMinimo := xMoeda(nBase,nMoeda,1,,,nTxMoeda,)
			Else
				nMinimo := nBase
			Endif
			For nX := 1 To Len(aCfg[5])
				If aCfg[5][nX][1] < nMinimo
					nAlqMin := aCfg[5][nX][2]
					Exit
				EndIf
			Next
			
			If nAlqMin <> nAliq .and. nAlqMin > 0
				nAliq := nAlqMin
			EndIf

			If aCfg[3] == "T" //Se forza la actualizaci๓n de todos los items cuando se estแ por total.
				MaAltCpo(aNfItem, "IT_ALIQIV"+aInfo[2], nAliq)
			EndIf

			nVRet := (nBase * nAliq) / 100
		EndIf

EndCaSe
FwFreeArray(aNfItem)
Return(nVRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM100TIMCFGบAutor  ณMarcello            บFecha ณ 05/08/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a configuracao do imposto (aliquota, valor minimo  บฑฑ
ฑฑบ          ณetc).                                                       บฑฑ
ฑฑบ          ณParametros: cImposto - codigo do imposto                    บฑฑ
ฑฑบ          ณ            cTes     - TES                                  บฑฑ
ฑฑบ          ณ            dRefer   - data de referencia para verificacao  บฑฑ
ฑฑบ          ณ            lVal     - indica se verifica a aliquota e      บฑฑ
ฑฑบ          ณ                       minimo                               บฑฑ
ฑฑบ          ณ            lCalc    - indica se verifica se o calculo      บฑฑ
ฑฑบ          ณ                       sera sobre item ou total, liquido ou บฑฑ
ฑฑบ          ณ                       sera sobre item ou total, liquido ou บฑฑ
ฑฑบ          ณ                       bruto                                บฑฑ
ฑฑบ          ณRetorno: array com 4 itens                                  บฑฑ
ฑฑบ          ณ                1 - aliquota                                บฑฑ
ฑฑบ          ณ                2 - valor minimo                            บฑฑ
ฑฑบ          ณ                3 - calculo (I = item ou T = total)         บฑฑ
ฑฑบ          ณ                4 - Liquido (S = liquido N = bruto)         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ M100TIM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function M100TimCfg(cImposto,cTes,dRefer,lVal,lCalc)
Local nAlq		:= 0
Local nMin		:= 0
Local nOrdSFC	:= 0
Local nRegSFC	:= 0
Local cSobre	:= "I"
Local cValor	:= "S"
Local cQuery	:= ""
Local cAliasSFF	:= ""
Local cFilSFF	:= xFilial("SFF")
Local lVerif	:= .F.
Local aRet		:= {}
Local aArea		:= {}
Local nOrd		:= 1
Local aMinSFF	:= {}

Default cImposto	:= ""
Default cTes		:= ""
Default dRefer		:= dDatabase
Default lCalc		:= .F.
Default lVal		:= .T.

aArea := GetArea()
SFB->(dbSetOrder(1))
If lVal
	If SFB->(dbSeek(xFilial("SFB")+cImposto))
		If SFB->FB_FLAG != "1"
			SFB->(RecLock("SFB",.F.))
			SFB->FB_FLAG := "1"
			SFB->(MSUnlock())
		Endif
		nAlq := SFB->FB_ALIQ
		If SFB->FB_TABELA == "S"
			cQuery := ""
			cAliasSFF := ""
			lVerif := .F.
			#IFDEF TOP
				If oQryExec == NIL

					cQuery := " Select "
					cQuery += " SFF.FF_ALIQ, SFF.FF_FXDE "
					cQuery += " From ? SFF "
					cQuery += " Where SFF.FF_FILIAL = ? "
					cQuery += " And SFF.FF_IMPOSTO = ? "
					cQuery += " And SFF.FF_DATAVLD >= ? "
					cQuery += " And SFF.D_E_L_E_T_= ? "
					cQuery += " ORDER BY SFF.FF_FXDE DESC "

					cQuery := ChangeQuery(cQuery)
        			oQryExec := FwExecStatement():New(cQuery)
				EndIf

				oQryExec:SetUnsafe(nOrd++, RetSqlName("SFF")) //Nombre tabla
				oQryExec:SetString(nOrd++, cFilSFF) //Filial
				oQryExec:SetString(nOrd++, cImposto) //Impuesto
				oQryExec:SetString(nOrd++, Dtos(dRefer)) //Data valid
				oQryExec:SetString(nOrd++, ' ') //Delete

				cAliasSFF := oQryExec:OpenAlias()
				
				While (cAliasSFF)->(!Eof())
					aAdd(aMinSFF, {(cAliasSFF)->FF_FXDE, (cAliasSFF)->FF_ALIQ})
					(cAliasSFF)->(dbSkip())
				EndDo

			#ELSE
				SFF->(DbSetOrder(9))
				If SFF->(DbSeek(cFilSFF + cImposto))
					lVerif := .F.
					While !lVerif .And. (SFF->FF_FILIAL == cFilSFF) .And. (FF_IMPOSTO == cImposto)
						If dRefer <= SFF->FF_DATAVLD
							lVerif := .T.
							nAlq := SFF->FF_ALIQ
							nMin := SFF->FF_FXDE
						Endif
						SFF->(DbSkip())
					Enddo
				Endif
			#ENDIF
		Endif
	Endif
Endif
If lCalc
	nOrdSFC := (SFC->(IndexOrd()))
	nRegSFC := (SFC->(Recno()))
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC") + cTES + cImposto)))
		cSobre := SFC->FC_CALCULO
		cValor := SFC->FC_LIQUIDO
	Endif
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))
Endif
aRet := {nAlq, nMin, cSobre, cValor, aClone(aMinSFF)}
RestArea(aArea)
aSize(aMinSFF, 0)
FWFreeArray(aArea)
Return(aClone(aRet))

/*/{Protheus.doc} MaRetBsIm
    Funci๓n utilizada para obtener la base de calculo total del impuesto TIMBRE.
    @type  Function
    @author raul.medina
    @since 20/05/2025
    @version 12.1.2410
    @param
        aNfItem, Array, arreglo con informaci๓n de los items.
        cNumImp, Character, Campo libro para obetener base de impuesto
	@return
		nBase, numeric, Valor de la base de acuerdo a campo libro
    /*/
Static Function MaRetBsIm(aNfItem, cNumImp)
Local nBase		:= 0
Local nX		:= 0

Default aNfItem	:= {}
Default cNumImp	:= ""

	For nX := 1 To Len(aNFItem)
		If !aNfItem[nX][Len(aNfItem[nX])] .and. MaFisFound("IT",nX)
			nBase += MaFisRet(nX,'IT_BASEIV'+cNumImp)
		EndIf
	Next

Return nBase

/*/{Protheus.doc} MaAltCpo
    Funci๓n utilizada para forzar la actualizaci๓n de la alicuota de los demแs items.
    @type  Function
    @author raul.medina
    @since 21/05/2025
    @version 12.1.2410
    @param
        aNfItem, Array, arreglo con informaci๓n de los items.
        cCampo, Character, Campo a ser actualizado.
		nAliq, numeric, alicuota que serแ actualizada en los items
	@return
    /*/
Static Function MaAltCpo(aNfItem, cCampo, nAliq)
Local nX		:= 0

Default aNfItem	:= {}
Default cCampo	:= ""
Default nAliq	:= 0

	For nX := 1 To Len(aNFItem)
		If !aNfItem[nX][Len(aNfItem[nX])]
			If MaFisRet(nX,cCampo) > 0
				MaFisLoad(cCampo,nAliq,nX)
			EndIf
		EndIf
	Next
	
Return

/*/{Protheus.doc} ChkImpTim
    Consulta la tabla SFC para verificar si existe el impuesto TIMBRE (TIM) en la TES.
    @type  Function
    @author raul.medina
    @since 21/05/2025
    @version 12.1.2410
    @param
        cTes, Character, Tes usada por el impuesto
	@return
		lRet, logical, indica si el impuesto fue encontrado en la TES que estแ siendo usada
    /*/
Function ChkImpTim(cTes)
Local lRet	:= .F.
Local aArea	:= {}
Local cImp	:= SuperGetMV("MV_IMPTIMB", .F., "TIM")

Default cTes	:= ""

	If !Empty(cTes ) .and. !Empty(cImp)
		aArea := GetArea()

		SFC->(DbSetOrder(2))
		lRet := (SFC->(MsSeek(xFilial("SFC") + cTes + cImp)))

		RestArea(aArea)
		FWFreeArray(aArea)
	EndIf

Return lRet
