#include 'protheus.ch'
#include 'TOPCONN.ch'
#include "OFIXX001.CH"

Class VEMapasAvaliacao from LongNameClass
	public data aStru

	method new() constructor
	method getMapOpt(cOrigem)
	method getMapa(cMapa, cCodMap)
	method getAStru() 
	method setAStru(aStru)
EndClass

method new() class VEMapasAvaliacao
return self


method getAStru() class VEMapasAvaliacao
return ::aStru

method setAStru(aStru) class VEMapasAvaliacao
	::aStru := aStru
return self


/*/{Protheus.doc} getMapOpt
	Método que irá retornar para api as opções de mapa disponíveis ao usuário. 
	@param cOrigem, determina quais serão os maps de acordo com o campo VS5.TIPAVA
	@author Renan Migliaris
	@since 26/03/2025
/*/
method getMapOpt(cOrigem) class VEMapasAvaliacao
	local cQuery := ''
	Local cFinalQuery := ''
	local aItems := {}
	local oJAux := nil
	local oResp := JsonObject():new()
	Local oStatement := FWPreparedStatement():New()

	cQuery := " SELECT VS5_CODMAP, VS5_DESMAP, VS5_TIPAVA FROM " +RetSqlName("VS5")+ " VS5 "
	cQuery += " WHERE VS5.VS5_TIPAVA = ?"
	cQuery += " AND VS5.D_E_L_E_T_ = ' '"
	cQuery += " AND VS5.VS5_FILIAL = '"+xFilial("VS5")+"'"

	//Define a consulta e os parâmetros
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1,cOrigem)
	cFinalQuery := oStatement:GetFixQuery()

	TCQUERY cFinalQuery NEW ALIAS "TMPVS5"
	while !TMPVS5->(Eof())
		oJAux := JsonObject():new()
		oJAux["VS5_TIPAVA"] := TMPVS5->VS5_TIPAVA
		oJAux["label"] := AllTrim(TMPVS5->VS5_CODMAP) + " - " + AllTrim(TMPVS5->VS5_DESMAP)
		oJAux["value"] := TMPVS5->VS5_CODMAP
		aadd(aItems, oJAux)
		FreeObj(oJAux)
		TMPVS5->(DbSkip())
	endDo

	TMPVS5->(DbCloseArea())
	
	oResp["items"] := aItems

return encodeUTF8(oResp:toJson()) 

/*/{Protheus.doc} getMapa
	Método que irá retornar para api o resultado do mapa de avaliação solicitado.
	O método consiste basicamente na adaptação do já existente na OFIXX001 (FS_AVRES2())
	Ele foi transcrito para que fossem realizados os posicionamentos necessários (similar ao que acontece na ofixx001)
	A chamada desse método até o momento da sua criação acontece dentro da OX001AVARES aonde se ele for chamado com o parametro de WEBSERVICE
	o metodo que sera invocado sera esse
	@param cMapa, determina qual mapa esta sendo solicitado
	@author Renan Migliaris
	@since /03/2025
/*/
method getMapa(cNumOrc, cCodMap) class VEMapasAvaliacao
	local jPecas := nil
	local aPecas := {}
	local nx := 0
	local n
	local ii := 0
	local nPosTotVda := 0
	local nTotStru := 0
	local cQuery := ''
	local cFinalQuery := ''
	local cOpeMov2 := ''
	local cLocalP := ''
	local cCodVen := VS1->VS1_CODVEN 
	local lVECVALIRR := VEC->(FieldPos("VEC_VALIRR")) > 0 
	local lVECVALCSL := VEC->(FieldPos("VEC_VALCSL")) > 0
	local nValPis := 0
	local nValCof := 0
	local nValICM := 0
	local nValIPI := 0
	local nValCmp := 0
	local nDifal := 0
	local aLivroVEC := {}
	local aValCom := {}
	local aVetVal := {}
	local aStru := {}
	local nBaseIcm := 0
	local nValIRR := 0
	local nValCSL := 0
	local cCpoDiv := ''
	local cAlias := ''
	local aFVec := FWSX3Util():GetAllFields("VEC") //campos da VEC (substitui acesso direto ao dicionário)
	// local lCalcTot := .t.
	local oTempTable := nil
	Local oStatement := FWPreparedStatement():New()
	local lHasBlockOX001VEC := ExistBlock("OX001VEC")
	
	default cCodMap := '004'

	for n := 1 to len(aFVec)

		aadd(aVetVal,;
			{;
				getSx3Cache(aFVec[n], "X3_CAMPO"),;
				getSx3Cache(aFVec[n], "X3_TIPO"),;
				getSx3Cache(aFVec[n], "X3_TAMANHO"),;
				getSx3Cache(aFVec[n], "X3_DECIMAL");
			})
		
	next

	DbSelectArea("VEC")
	oTempTable := OFDMSTempTable():new()
	cAlias := oTempTable:GetAlias()
	oTempTable:aVetCampos := aVetVal
	oTempTable:AddIndex(, {"VEC_FILIAL","VEC_NUMOSV"} )
	oTempTable:CreateTable()

	cQuery := " SELECT "
	cQuery += "		VS3.VS3_GRUITE,	"
	cQuery += "		VS3.VS3_CODITE,	" 
	cQuery += "		VS3.VS3_LOCAL, 	" 
	cQuery += "		VS3.VS3_CODTES, "
	cQuery += "		VS3.VS3_VALTOT,	"
	cQuery += "		VS3.VS3_VALDES,	"
	cQuery += "		VS3.VS3_QTDITE,	"
	cQuery += "		VS3.VS3_VALPIS, "
	cQuery += "		VS3.VS3_VALCOF, "
	cQuery += "		VS3.VS3_ICMCAL,	"
	// cQuery += "		VS3.VS3_VALIPI,	" // nao encontrei esse campo no dicionario (SX3) verificar como foi usado no fonte original ofixx001 
	cQuery += "		VS3.VS3_VALCMP, "
	cQuery += "		VS3.VS3_DIFAL   "            
	cQuery += " FROM " + RetSqlName("VS3") + " VS3 " 
	cQuery += " WHERE "
	cQuery += "   VS3.VS3_NUMORC = ?"
	cQuery += "   AND VS3.D_E_L_E_T_ = ' '"
	cQuery += "   AND VS3.VS3_FILIAL = '"+xFiliaL("VS3")+"'"
	cQuery += "   AND VS3.VS3_CODITE <> ' '"

	//Define a consulta e os parâmetros
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1,cNumOrc)
	cFinalQuery := oStatement:GetFixQuery()

	TCQUERY cFinalQuery NEW ALIAS "TMPORC"	
	while !TMPORC->(eof())
		jPecas := JsonObject():new()
		jPecas["VS3_GRUITE"	] := TMPORC->VS3_GRUITE
		jPecas["VS3_CODITE"	] := TMPORC->VS3_CODITE
		jPecas["VS3_LOCAL"	] := TMPORC->VS3_LOCAL
		jPecas["VS3_CODTES"	] := TMPORC->VS3_CODTES
		jPecas["VS3_VALTOT"	] := TMPORC->VS3_VALTOT
		jPecas["VS3_VALDES"	] := TMPORC->VS3_VALDES
		jPecas["VS3_QTDITE"	] := TMPORC->VS3_QTDITE
		jPecas["VS3_VALPIS"	] := TMPORC->VS3_VALPIS
		jPecas["VS3_VALCOF"	] := TMPORC->VS3_VALCOF
		jPecas["VS3_ICMCAL"	] := TMPORC->VS3_ICMCAL
		jPecas["VS3_VALCMP"	] := TMPORC->VS3_VALCMP
		jPecas["VS3_DIFAL"	] := TMPORC->VS3_DIFAL

		aadd(aPecas, jPecas)
		freeobj(jPecas)
		TMPORC->(dbSkip())
	endDo

	TMPORC->(DbCloseArea())
	
	for nx := 1 to len(aPecas)
		cOpeMov2 := VS1->VS1_NOROUT // ponto de atenção

		// TODO ponto de atenção entender o que motiva a saída do loop na rotina original 
		// if oGetPecas:aCols[oGetPecas:nAt,Len(oGetPecas:aCols[oGetPecas:nAt])]
		// 	Loop
		// Endif

		dbSelectArea("SB1")
		dbSetOrder(7)
		dBSeek(xFilial("SB1")+aPecas[nx]["VS3_GRUITE"]+aPecas[nx]["VS3_CODITE"])

		cLocalP := iif(!Empty(aPecas[nx]["VS3_LOCAL"]), aPecas[nx]["VS3_LOCAL"], OX0010105_ArmazemOrigem()) //verificar funcao do armazem
		dbSelectArea("SB2")
		dbSeek(xFilial("SB2")+SB1->B1_COD+cLocalP)

		dbSelectArea("SF4")
		SF4->(dbseek(xFiliaL("SF4")+aPecas[nx]["VS3_CODTES"]))

		If MaFisFound("NF")
			OX001PecFis()
			nValPis := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
			nValCof := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
			nValICM := MaFisRet(n,"IT_VALICM")
			// nValIPI := MaFisRet(n,"IT_VALIPI")
			nValCmp := MaFisRet(n,"IT_VALCMP")
			nDifal  := MaFisRet(n,"IT_DIFAL")
			aLivroVEC := MaFisRet(n,"IT_LIVRO")
			nValICM := aLivroVEC[5]
			nBaseIcm := MaFisRet(n,"IT_BASEICM")
			nValIRR  := MaFisRet(n,"IT_VALIRR")
			nValCSL  := MaFisRet(n,"IT_VALCSL")
			OX001FisPec()
		Else
			nValPis  := aPecas[nx]["VS3_VALPIS"]
			nValCof  := aPecas[nx]["VS3_VALCOF"]
			nValICM  := aPecas[nx]["VS3_ICMCAL"]
			nValCmp  := aPecas[nx]["VS3_VALCMP"]
			nDifal   := aPecas[nx]["VS3_DIFAL"]
			//VS3_VALIPI não encontrei na SX3
			// nValIPI  := IIf(FG_POSVAR("VS3_VALIPI","aHeaderP") > 0,oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_VALIPI","aHeaderP")],0)
			nBaseIcm := 0
			nValIRR  := 0
			nValCSL  := 0
		EndIf

		cNumREL := GetSXENum("VEC","VEC_NUMREL")
		ConfirmSx8()
		cNumIDE := GetSXENum("VEC","VEC_NUMIDE")
		ConfirmSx8()

		//a area selecionada logo abaixo se trata da area temporaria de trabalho
		//o cAlias guarda o nome do alias que esta instanciado na classe 
		dbSelectArea(cAlias)

		RecLock(cAlias,.t.)

		VEC_FILIAL := xFilial("VEC")
		VEC_NUMORC := VS1->VS1_NUMORC
		VEC_NUMREL := cNumREL
		VEC_NUMIDE := cNumIDE
		VEC_GRUITE := aPecas[nx]["VS3_GRUITE"]
		VEC_CODITE := aPecas[nx]["VS3_CODITE"]
		VEC_VALVDA := aPecas[nx]["VS3_VALTOT"]
		VEC_VALDES := aPecas[nx]["VS3_VALDES"]
		VEC_QTDITE := aPecas[nx]["VS3_QTDITE"]
		VEC_VALICM := nValICM
		VEC_VALCOF := nValCof
		VEC_VALPIS := nValPis
		VEC_VALIPI := nValIPI
		VEC_TOTIMP := VEC_VALICM + VEC_VALCOF + VEC_VALPIS + VEC_DIFAL + VEC_VALCMP + VEC_VALIPI
		VEC_CUSMED := SB2->B2_CM1 * aPecas[nx]["VS3_QTDITE"]
		VEC_JUREST := 0
		VEC_CUSTOT := VEC_CUSMED + VEC_JUREST
		VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSMED
		VEC_DATVEN := dDataBase
		VEC_PECINT := SB1->B1_COD
		VEC_VALCMP := nValCmp
		VEC_DIFAL  := nDifal
		if lVECVALIRR
			VEC_VALIRR := nValIRR
			VEC_VMFIRR := FG_CALCMF( { {dDataBase,VEC_VALIRR} })
		Endif
		if lVECVALCSL
			VEC_VALCSL := nValCSL
			VEC_VMFCSL := FG_CALCMF( { {dDataBase,VEC_VALCSL} })
		Endif
		//Comissao
		if cOpeMov2 <> "2"
			aValCom    := FG_COMISS("P",cCodVen,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"T",VEC_NUMIDE)
			VEC_COMVEN := aValCom[1]
			VEC_COMGER := aValCom[2]
		Else
			VEC_COMVEN := 0
			VEC_COMGER := 0
		Endif

		VEC_DESVAR := VEC_COMVEN + VEC_COMGER
		VEC_LUCLIQ := VEC_LUCBRU - VEC_JUREST - VEC_DESVAR - VEC_DESDEP - VEC_DESADM - VEC_DESFIX
		VEC_DESFIX := 0
		VEC_CUSFIX := 0
		VEC_DESDEP := 0
		VEC_DESADM := 0
		VEC_RESFIN := 0
		VEC_BALOFI := "B" //Balcao
		VEC_DEPVEN := ""
		VEC_TIPTEM := ""  //Gravar qdo Ordem de Servico
		VEC_NUMOSV := ""  //Gravar qdo Ordem de Servico
		VEC_RESFIN := VEC_LUCLIQ - VEC_CUSFIX
		VEC_NUMNFI := ""

		VEC_VALBRU := VEC_VALVDA + VEC_VALDES
		VEC_VMFBRU := FG_CALCMF( { {dDataBase,VEC_VALBRU} })
		VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{dDataBase,VEC_VALDES}} )
		VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VEC_VALICM} })
		VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_VALPIS} })
		VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
		VEC_VMFIPI := 0 //FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
		VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS
		VEC_CMFMED := FG_CALCMF( { {dDataBase,VEC_CUSMED} })
		VEC_JMFEST := FG_CALCMF( { {dDataBase,VEC_JUREST} })
		VEC_CMFTOT := VEC_CMFMED + VEC_JMFEST
		VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT

		VEC_CMFVEN := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_COMVEN} })
		VEC_CMFGER := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_COMGER} })

		VEC_DMFVAR := VEC_CMFVEN + VEC_CMFGER
		VEC_LMFLIQ := VEC_LMFBRU - VEC_DMFVAR
		VEC_DMFFIX := 0
		VEC_CMFFIX := 0
		VEC_CMFDEP := 0
		VEC_DMFADM := 0
		VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM

		dbSelectArea(cAlias)
		MsUnlock()
		
		If lHasBlockOX001VEC // Ponto de Entrada para Atualizacao dos campos referentes ao ST (VEC_ICMSST + VEC_DCLBST + VEC_COPIST)
			ExecBlock("OX001VEC",.f.,.f.,{SB1->B1_COD,VEC_DATVEN,aPecas[nx]["VS3_CODTES"],nBaseIcm,VEC_QTDITE,cAlias})
		EndIf

			
		dbSelectArea("VS5")
		dbsetOrder(1)
		dbSeek(xFiliaL("VS5")+cCodMap)
			
		dbSelectArea("VOQ")
		dbSetOrder(1)
		dbSeek(xfilial("VOQ")+cCodMap)

		while !eof() .and. VOQ->VOQ_FILIAL == xFiliaL("VOQ")
			if VOQ_INDATI # "1" && Sim
				dbSkip()
				Loop
			Endif

			if VOQ_CODMAP # cCodMap
				Exit
			Endif

			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

			aadd(aStru,{ VS1->VS1_NUMORC,,SB1->B1_COD,VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,;
			VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,;
			VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,0,0,VOQ_CTATOT})

			dbSkip()
		endDo

		dbSelectArea(cAlias)
		//aqui nessa função ele retorna o aStru brabo
		FG_CalcVlrs(aStru,SB1->B1_COD,/*cCpoDivP*/,/*lSM2*/,/*aFormul*/,/*lMapVei*/,/*cAuxNumOsv*/,cCodMap)
		cCpoDiv := cCpoDiv + "#" + str(len(aStru)+1,5)
	next

	dbSelectArea("VS5")
	dbsetOrder(1)
	dbSeek(xFiliaL("VS5")+cCodMap)

	dbSelectArea("VOQ")
	dbSetOrder(1)
	dbSeek(xfilial("VOQ")+cCodMap)
	
	while !Eof() .and. VOQ->VOQ_FILIAL == xFiliaL("VOQ")
		
		if VOQ_INDATI # "1" && Sim
			dbSkip()
			Loop
		Endif

		if VOQ_CODMAP # cCodMap
			exit

		Endif

		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

		aadd(aStru,{ VS1->VS1_NUMORC,,STR0192,VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,;
		SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,;
		0,0,VOQ_CTATOT})

	dbSkip()

	endDo
	// Totaliza Mapa de Resultados quando mais de um Item
	If Type("aStru") == "A"

		if Len(aStru) > 0
			cPriCta    := aStru[1,4]
			nQtdEMap   := aScan(aStru,{|x| x[4] == cPriCta},2) - 1  // Qtd de Elementos por Item no Mapa
			nTotStru   := (Len(aStru)-nQtdEMap) // Total de elementos no Vetor, exceto os elementos do Total da Venda
			nPosTotVda := nTotStru // Posicao ultimo elemento do vetor, anterior ao primeiro elemento do Total da Venda

			// Limpeza dos elementos do Total da Venda
			for ii := nPosTotVda+1 To Len(aStru)
				aStru[ii,09] := 0
				aStru[ii,12] := 0
			Next

			// Gravacao dos elementos do Total da Venda
			nSoma := nQtdEMap
			for ii := 1 To nTotStru
				nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
				if nPosVet > Len(aStru)
					nQtdEMap += nSoma
					nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
				Endif
				aStru[nPosVet,09] += aStru[ii,09]
				aStru[nPosVet,12] += aStru[ii,12]
			Next
			nTotItem := nTotStru + 1
			for ii := nTotItem To Len(aStru)
				aStru[ii,10] += ( aStru[ii,9]/aStru[nTotItem+1,9] ) * 100
			Next
		Endif
	Endif
	::setAStru(aStru)
return .t.


/*/{Protheus.doc} OX0010105_ArmazemOrigem
	Retorna o Valor Padrao do Servico, adaptacao da OX0010105_ArmazemOrigem presente na OFIXX001
	@type static function
	@author Renan Migliaris
	@since /03/2025
/*/
Static Function OX0010105_ArmazemOrigem()
	local lFOM020ArmazemOri := FindFunction("OM0200065_ArmazemOrigem")
	Local cArmazem := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")

	If VS1->VS1_TIPORC == "2" .and. lFOM020ArmazemOri
		cArmazem := OM0200065_ArmazemOrigem( VS1->VS1_TIPTEM, cArmazem )
	EndIf

Return cArmazem
