#include "Protheus.ch"
#include "OFIXI001.ch"
#include "FWMVCDEF.CH"
STATIC ControleImpressao := FindFunction("OX001REGIMP")

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXI001   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Fases do Orcamento                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXI001(cNumOrc,_lSeparado,lChkFase)
Local nCntFor, nCntFor2
Local lCtrlLote   := GetNewPar("MV_RASTRO","N") == "S"    
Local lTransf     := .f.
Local lReser      := .f.
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao


Local cNroConf    := ""
Local cVS1_STATUS := ""
Local lExecPE     := .f.

Local nPDescUsu   := 0
Local nVS1PERREM  := 0
Local cVS1CONPRO  := "2"
Local dDatRefPD   := dDataBase

Local nTpProb     := 1 //Problema de margem de desconto
Local lNewRes     := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
Local nMoedaC     := 0		

Private nDesPer := 0
Private lSeparado
Private lMultMoeda := FGX_MULTMOEDA()

Default _lSeparado := .f.
Default lChkFase   := .t.

//Private oXI001TempoProc


lSeparado := _lSeparado

DBSelectArea("VS1")
DBSetOrder(1)
if !DBSeek(xFilial("VS1")+cNumOrc)
	return {STR0001+cNumOrc,.f.,.f.,.f.} // Orçamento por Fases
endif
//
if VS1->VS1_TIPORC == '3'    
	OI001ATU(cNumOrc,cFaseConfer)
	RecLock("VS1",.f.)
	VS1->VS1_STATUS := cFaseConfer
	MsUnlock()
	If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
		OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , cNumOrc ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
	EndIf
	return {"" ,.f.,.f.,.f.}
EndIf

if VS1->VS1_TIPORC = '2'  // SERVICO NÃO TEM FASE
	MsgInfo(STR0020,STR0019)
	OI001ATU(cNumOrc,"F")
	return {"" ,.f.,.f.,.f.}
endif

If VS1->VS1_STATUS == "0" .and. Empty(VS1->VS1_PEDREF) // Orçamento Digitado e não iniciou por Pedido
	// Valida e utiliza Saldos das Promoções
	If !OX0010241_SaldoPromocao( .t. , STR0030 ) // Orçamento Digitado - Avanço de Fase
		return {"" ,.f.,.f.,.f.}
	EndIf
EndIf

//
cVS1_STATUS := IIf(VS1->VS1_STATUS=="G","F",VS1->VS1_STATUS) // Status G não tem tratamento especifico, é para trabalhar como se fosse a Fase F - Liberado para Faturamento
//
// Inicio da Validacao das Fases do Orcamento
cFaseOrc := OI001GETFASE(cNumOrc)
cFaseAtu := cVS1_STATUS
cFaseIni := cVS1_STATUS
cTipPag  := VS1->VS1_FORPAG
nPos := At(cVS1_STATUS,cFaseOrc)
if nPos < 1
	nPos := 1
Else
	If nPos <> 1
		cFaseIni := subs(cFaseorc,At(cVS1_STATUS,cFaseOrc)-1,1)
	Endif
endif
if Len(cFaseOrc) == 0
	cFaseAtu := "F"
endif
for nCntFor := nPos to Len(cFaseOrc)
	cFaseAtu := Subs(cFaseOrc,nCntFor,1)
	//#########################################################################################
	if cFaseAtu == "X" // ORCAMENTO FECHADO
		//#########################################################################################
		OI001ATU(cNumOrc,cFaseAtu)
		return {STR0002,.f.,.f.,.f.}
		//#########################################################################################
	elseif cFaseAtu == "C" // ORCAMENTO CANCELADO
		//#########################################################################################
		OI001ATU(cNumOrc,cFaseAtu)
		return {STR0003,.f.,.f.,.f.}
		//#########################################################################################
	elseif cFaseAtu == "2" // MARGEM DE LUCRO
		//#########################################################################################
		if VS1->VS1_TIPORC # "3"

			VAI->(DBSetOrder(4))
			If VAI->(DBSeek(xFilial("VAI")+__cUserID))
				If VAI->(FieldPos("VAI_DESPEC")) > 0  // Tem % de Desconto Default para o Vendedor
					nPDescUsu := VAI->VAI_DESPEC
				EndIf
				If VAI->(FieldPos("VAI_DTCDES")) > 0 // Data para validar a Politica de Desconto
					If VAI->VAI_DTCDES == "1" // Utilizar 1=Data de Inclusão do Orçamento para validar a Politica de Desconto
						dDatRefPD := VS1->VS1_DATORC
					EndIf
				EndIf
			EndIf

			if !Empty(VS1->VS1_NUMLIB)
				If FM_SQL("SELECT COUNT(VS6.R_E_C_N_O_) RECVS6 FROM "+RetSQLName("VS6")+" VS6 WHERE VS6.VS6_FILIAL='"+xFilial("VS6")+"' AND VS6.VS6_DATAUT='        '  AND VS6.D_E_L_E_T_ = ' ' AND VS6.VS6_NUMORC='"+cNumOrc+"'") > 0
					OI001ATU(cNumOrc,cFaseAtu)
					return { STR0004,.f.,.f.,.f.}
				Else
					MsgInfo(STR0005,STR0006)
				EndIf
			else
				If VS1->(FieldPos("VS1_PERREM")) > 0
					nVS1PERREM := VS1->VS1_PERREM
					cVS1CONPRO := VS1->VS1_CONPRO
				EndIf
				DBSelectArea("VS3")
				DBSetOrder(1)
				DBSeek(xFilial("VS3")+cNumOrc)
				aIDescont := {}
				lProbDes := .f.
				lMostraHlp := .t.
				lFazPergunta := .t.
				// #########################################################
				// # PONTO DE ENTRADA PARA CUSTOMIZACAO DA MARGEM DE LUCRO #
				// #########################################################
				if ExistBlock("OXA012LP")
					aIDescont :=  ExecBlock("OXA012LP",.f.,.f.,{cNumOrc})
					for nCntFor2 := 1 to Len(aIDescont)
						if !aIDescont[nCntFor2]
							lProbDes := .t.
						endif
					next
				else
					SF4->(DBSetOrder(1))
					SB1->(DBSetOrder(7))
					SBM->(DBSetOrder(1))
					SB2->(dbSetOrder(1))
					while !eof() .and. xFilial("VS3") == VS3->VS3_FILIAL .AND. VS1->VS1_NUMORC == VS3->VS3_NUMORC
						SF4->(msSeek(xFilial("SF4")+VS3->VS3_CODTES))
						SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
						SBM->(msSeek(xFilial("SBM")+SB1->B1_GRUPO))
						SB2->(dbSeek(xFilial("SB2")+ SB1->B1_COD + VS3->VS3_LOCAL))
						
						RegToMemory("VS3",.F.,.F.)

						if SF4->F4_OPEMOV != "05"
							lRetDes := .t.
						else



							lMostraHlp := .f.


							lRetDes := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,lMostraHlp,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VS1->VS1_TIPVEN,VS3->VS3_VALTOT/VS3->VS3_QTDITE,,VS1->VS1_FORPAG,,,,cVS1CONPRO,dDatRefPD,nVS1PERREM,@nTpProb)
						endif
						If !lRetDes .and. nTpProb == 1 // Se teve problema de Desconto utilizando a Politica de Desconto
							If nPDescUsu >= VS3->VS3_PERDES+nVS1PERREM // Verifica se o % de desconto default do Vendedor é maior ou igual ao da Peça
								lRetDes := .t. // Deixa passar devido ao % minimo permitido para o Vendedor.
							EndIf
						EndIf
						aAdd(aIDescont,lRetDes)

						if !lRetDes // .and. VS3->VS3_VALDES != 0
							lProbDes := .t.
						endif
						if ExistBlock("OI001RDE")
							ExecBlock("OI001RDE",.f.,.f.)
						endif
						DBSelectArea("VS3")
						DBSkip()
					enddo
				endif













				if lProbDes
					if ! OI001001C_ProblemaMargemDesconto( cNumOrc )
						OI001ATU(cNumOrc,cFaseAtu)
						return {STR0010,.t.,.t.,.f.}
					endif






























































								


						

								






































































					OI001ATU(cNumOrc,cFaseAtu)
					//
					If lExecPE .and. ExistBlock("OXVS7DGT")
						ExecBlock("OXVS7DGT",.f.,.f.) // Ponto de Entrada Depois da Gravacao Total do VS7
					EndIf
					//
					return {STR0013,.f.,.f.,.f.}
				endif
			endif
			OI001ATU(cNumOrc,cFaseAtu)

		else
			OI001ATU(cNumOrc,cFaseAtu)

		endif
		//#########################################################################################
	elseif cFaseAtu == "3" // LIMITE DE CREDITO
		//#########################################################################################
		if VS1->VS1_TIPORC # "3"
			if Empty(GetNewPar("MV_CPNCLC","")) .or. !alltrim(cTipPag) $ GetMv("MV_CPNCLC") .or. Empty(cTipPag)
				If "B" $ GetMv("MV_CHKCRE")
					DBSelectArea("SA1")
					DBSetOrder(1)
					if GetMv("MV_CREDCLI") == "C"
						DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT)
					else
						DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)
					endif
					//
					nMoedaC := IIF(lMultMoeda ,Max(VS1->VS1_MOEDA,1), nil )
					If !FGX_AVALCRED(SA1->A1_COD,SA1->A1_LOJA,IIf(VS1->VS1_STATUS=="0",VS1->VS1_VTOTNF,0),.t.,,,nMoedaC)
						OI001ATU(cNumOrc,cFaseAtu)  
						if VS1->(FieldPos("VS1_DTHRPL")) > 0
					  		dbSelectArea("VS1")
							RecLock("VS1",.f.)
							VS1->VS1_DTHRPL :=  Dtoc(dDataBase)+"-"+Substr(Time(),1,2)+":"+Substr(Time(),4,2)
							MsUnlock()  
						Endif	
						Return {STR0014,.t.,.f.,.f.}
					EndIf
				EndIf
			Endif
		endif

		//#########################################################################################
	elseif cFaseAtu == cFaseConfer // SEPARACAO E CONFERENCIA
		//#########################################################################################
		If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
			OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , cNumOrc ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
		EndIf
		If ExistFunc("OX0020071_ExisteConferencia")
			cNroConf := OX0020071_ExisteConferencia( cNumOrc , .t. )
			If !Empty(cNroConf)
				VAI->(dbSetOrder(4))
				VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
				VM5->( DbSetOrder(1) )
				VM5->( DbSeek( xFilial("VM5") + cNroConf ) )
				If 	( VM5->VM5_STATUS == "4" ) .or. ; // Conferencia esta Aprovada ou
					( VM5->VM5_STATUS == "3" .and. VM5->VM5_DIVERG == "0" ) .or. ; // Conferencia Finalizada nao possuindo divergencias ou
					( VM5->VM5_STATUS == "3" .and. VM5->VM5_DIVERG == "1" .and. VAI->VAI_APRCON $ "1/2" ) // Conferencia Finalizada com Divergencia e Usuario é Aprovador
					lSeparado := .t.
				EndIf
			EndIf
		Else // Versao Antiga - Tem furo se existir um unico item e o mesmo nao tem estoque.
			DBSelectArea("VS3")
			DBSetOrder(1)
			DBSeek(xFilial("VS3")+cNumOrc)
			while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
				if VS3->VS3_QTDCON != 0
					lSeparado := .t.
				endif
				DBSkip()
			enddo            
		EndIf
		// Ponto de entrada para tratativa de conferência. Pode-se manupular os valores do VS3
		// ou a variável lSeparado para pular a fase sem a necessidade de retirar do MV_FASEORC
		If ExistBlock("OI001SCO")
			ExecBlock("OI001SCO",.f.,.f.)
		EndIf
		//
		if !lSeparado
			OI001ATU(cNumOrc,cFaseAtu)
			return {STR0015,.f.,.f.,.f.}
		endif
		//#########################################################################################
	elseif cFaseAtu == "5" // LIBERACAO DE DIVERGENCIA
		//#########################################################################################

		lDivergente := .f.

		If lNewRes

			If lChkFase

				cQuery := "SELECT VM5.R_E_C_N_O_ "
				cQuery += "FROM " + RetSQLName("VM5") + " VM5 "
				cQuery += "WHERE VM5.VM5_FILIAL = '" + xFilial("VM5") + "' "
				cQuery += 	"AND VM5.VM5_NUMORC = '" + VS1->VS1_NUMORC + "' "
				cQuery += 	"AND VM5.VM5_DIVERG = '1' "
				cQuery += 	"AND VM5.D_E_L_E_T_ = ' '"
				cQuery += "ORDER BY 1 DESC "

				nRecVM5 := FM_SQL(cQuery)

				If nRecVM5 > 0

					If GetNewPar("MV_MIL0037","S") == "N" // Movimenta para armazém de divergência?

						DbSelectArea("VM5")
						DbGoTo(nRecVM5)

						cQuery := "SELECT VS3.VS3_GRUITE, VS3.VS3_CODITE, SUM(VS3.VS3_QTDITE), SUM(VS3.VS3_QTDCON)"
						cQuery += "FROM " + RetSQLName("VS3") + " VS3 "
						cQuery += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" +xFilial("SB1")+ "' AND SB1.B1_CODITE = VS3.VS3_CODITE AND SB1.B1_GRUPO = VS3.VS3_GRUITE AND SB1.D_E_L_E_T_ = ' '"
						cQuery += " JOIN " + RetSQLName("VM6") + " VM6 ON VM6.VM6_FILIAL = '" +xFilial("VM6")+ "' AND VM6.VM6_CODVM5 = '" + VM5->VM5_CODIGO + "' AND VM6.VM6_COD = SB1.B1_COD AND VM6.D_E_L_E_T_ = ' '"
						cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
						cQuery += 	"AND VS3.VS3_NUMORC = '" + VM5->VM5_NUMORC +"' "
						cQuery += 	"AND VS3.D_E_L_E_T_ = ' ' "
						cQuery += "GROUP BY VS3.VS3_GRUITE, VS3.VS3_CODITE "
						cQuery += "HAVING SUM(VS3.VS3_QTDITE) > SUM(VS3.VS3_QTDCON) "

						cGruIte := FM_SQL(cQuery)

						If !Empty(cGruIte)
							lDivergente := .t.
						EndIf

					Else
						lDivergente := .t.
					EndIf

				EndIf

			EndIf

		Else
			cExpressao := "VS3->VS3_QTDCON != VS3->VS3_QTDITE"
			if ExistBlock("OXI01DIV") // retorno da Expressão para determinar Divergência na confereencia de peças
				cExpressao := ExecBlock("OXI01DIV",.f.,.f.,)
			Endif
			
			DBSelectArea("VS3")
			DBSetOrder(1)
			DBSeek(xFilial("VS3")+cNumOrc)
			while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+ VS3->VS3_NUMORC
				if &(cExpressao)
					lDivergente := .t.
					Exit
				endif
				DBSkip()
			enddo
		EndIf

		if lDivergente
			OI001ATU(cNumOrc,cFaseAtu)
			return {STR0016,.f.,.f.,.f.}
		endif

		//#########################################################################################
	Elseif cFaseAtu == "E" // ORCAMENTO ENVIO DE EMAIL
		//#########################################################################################
		if ExistBlock("OXIEMAIL")
			ExecBlock("OXIEMAIL",.f.,.f.,)
		Endif

		//#########################################################################################
	elseif cFaseAtu == "F" // LIBERADO PARA FATURAMENTO
		//#########################################################################################
		OI001ATU(cNumOrc,cFaseAtu)
		return {"",.f.,.f.,.f.}
		//#########################################################################################
	elseif cFaseAtu == "R" // RESERVA O ITEM
		//#########################################################################################
		// Verifica se devemos reservar a peca
		lAguardando := .f.
		lReservado := .f.
		IF VS3->(FieldPos("VS3_QTDAGU")) > 0
			DBSelectArea("VS3")
			DBSetOrder(1)
			DBSeek(xFilial("VS3")+cNumOrc)
			while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
				if VS3->VS3_QTDRES > 0 .and. !lNewRes
					if At("T",cFaseOrc) > 0 
						DbSelectArea("VDD")
						DBSetOrder(4)
						if DBSeek(xFilial("VDD")+VS3->VS3_FILIAL+VS3->VS3_NUMORC+VS3->VS3_GRUITE+VS3->VS3_CODITE)
							lReservado := .t.
						Endif	
					Else
						lReservado := .t.
					Endif	
				endif
				if VS3->VS3_QTDAGU > 0 
					lAguardando := .t.
				endif  
				DBSelectArea("VS3")
				DBSkip()
			enddo
			if lAguardando
				OI001ATU(cNumOrc,"A") //Aguardando peças
			endif
		endif
        if !lReservado
			Begin Transaction
				If ( lNewRes ) // Chama reserva de todos os itens do orçamento
					cDocto := OA4820015_ProcessaReservaItem("OR",VS1->(RecNo()),"A","R",,"02")
				Else
					cDocto := OX001RESITE(cNumOrc,.t.)
				EndIf
			End Transaction
			if cDocto == ""
				//
				If FindFunction("FM_GerLog")
					//grava log das alteracoes das fases do orcamento
					FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cFaseIni)
				EndIF
				//
				If lCtrlLote .and. Funname() <> "OFIXA011"
					return {STR0025,.f.,.f.,.f.} 
				Else
					If Funname() == "OFIXA011"
						return {STR0017 ,.f.,.f.,.f.} // Erro ao reservar o(s) item(s). 
					Else
						return {STR0017 + CRLF + STR0027,.f.,.f.,.f.} // Erro ao reservar o(s) item(s). // Para prosseguir com o faturamento do orçamento, utilize a opção Faturar diretamente pela rotina Orc. por Fases (OFIXA011) ou pela rotina Painel Orçamento (OFIXA018)
					EndIf
				EndIF
				//
			endif
		endif
		if lAguardando
			return {STR0023,.f.,.f.,.f.}
		endif

		//#########################################################################################
	elseif cFaseAtu == "O" // IMPRIME ORDEM DE BUSCA
		//#########################################################################################
		if ExistBlock("ORDBUSCB")
			ExecBlock("ORDBUSCB",.f.,.f.,{"O","AVANCA"})
		Endif
		If ControleImpressao
			OX001REGIMP()
		EndIf

		//#########################################################################################
	elseif cFaseAtu == "B" // GRAVAÇÃO DO VQH (BACKORDER)
		//#########################################################################################
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+cNumOrc)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
			SB1->(DbSetOrder(7))
			SB1->(DbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
			DBSelectArea("VQH")
			DBSetOrder(1)
			if DBSeek(xFilial("VQH")+VS1->VS1_NUMORC+SB1->B1_COD)
				reclock("VQH",.f.)
				VQH->VQH_QUANT  := VS3->VS3_QTDITE
				msunlock()
			else
				reclock("VQH",.t.)
				VQH->VQH_FILIAL := xFilial("VQH")
				VQH->VQH_NUMORC  := VS3->VS3_NUMORC
				VQH->VQH_PRODUT  := SB1->B1_COD
				VQH->VQH_QUANT  := VS3->VS3_QTDITE
				msunlock()
			endif
			DBSelectArea("VS3")
			DBSkip()
		enddo
		SB1->(DbSetOrder(1))

		//#########################################################################################
	elseif cFaseAtu == "T" // RESERVA O ITEM
		//#########################################################################################
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+cNumOrc)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
			if VS3->VS3_QTDTRA > 0
				DbSelectArea("VDD")
				DBSetOrder(4)
				if DBSeek(xFilial("VDD")+VS3->VS3_FILIAL+VS3->VS3_NUMORC+VS3->VS3_GRUITE+VS3->VS3_CODITE)
					while !eof() .and. (xFilial("VDD")+VS3->VS3_FILIAL+VS3->VS3_NUMORC+VS3->VS3_GRUITE+VS3->VS3_CODITE == VDD->VDD_FILIAL + VDD->VDD_FILORC + VDD->VDD_NUMORC + VDD->VDD_GRUPO + VDD->VDD_CODITE)
						lTransf := .t.
						If !Empty(VS3->VS3_DOCSDB) .or. VS3->VS3_QTDRES > 0
							lReser := .t.
						EndIf
						if VDD->VDD_STATUS == "R"

						elseif VDD->VDD_STATUS == "C" 
							if lCtrlLote
							   if Empty(VS3->VS3_LOTECT)
									DBSelectArea("VS3")
									reclock("VS3",.f.)
									VS3->VS3_QTDTRA := VS3->VS3_QTDTRA - VDD->VDD_QUANT
									VS3->VS3_QTDRES := VS3->VS3_QTDRES + VDD->VDD_QUANT
									msunlock()
								Endif	
							Else			
								DBSelectArea("VS3")
								reclock("VS3",.f.)
								VS3->VS3_QTDTRA := VS3->VS3_QTDTRA - VDD->VDD_QUANT
								VS3->VS3_QTDRES := VS3->VS3_QTDRES + VDD->VDD_QUANT
								msunlock()
							Endif	
						endif
						DbSelectArea("VDD")

						DBSkip()
					enddo
				endif
			endif
			DBSelectArea("VS3")
			DBSkip()
		enddo
		if lTransf .and. !lReser
			Begin Transaction
				If ( lNewRes ) // Chama reserva de todos os itens do orçamento
					cDocto := OA4820015_ProcessaReservaItem("OR",VS1->(RecNo()),"A","R",,"03")
				Else
					cDocto := OX001RESITE(cNumOrc,.t.,,.f.)
				EndIf
			End Transaction
		EndIf
		if lTransf
			OI001ATU(cNumOrc,"A") //Aguardando peças
			return {STR0020,.f.,.f.,.f.}
		Endif	
	else
		// CHAMA PTO ENTRADA
		if ExistBlock("OI001FNV")
			aRet := ExecBlock("OI001FNV",.f.,.f.,{cFaseAtu})
			if aRet[1] == .f.
				return aRet[2]
			endif
		Endif
		//
	endif
next
//
return {"",.f.,.f.,.f.}
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXI001REVF | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Reverte fases do Orcamento                                   |##
##+----------+--------------------------------------------------------------+##
##|Parametros| Numero do Orçamento e Fase a ser alcançada (reverte até a    |##
##|          | fase especificada)                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXI001REVF(cNumOrc, cFaseIni)

Local lResTrf := .f.
Local lNewRes     := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?

DBSelectArea("VS1")
DBSetOrder(1)
if DBSeek(xFilial("VS1")+cNumOrc)
	// verifica se precisa desreservar os itens
	cFaseOrc := OI001GETFASE(cNumOrc)					// Fases do orcamento
	//
	nPosI := At(cFaseIni,cFaseOrc)
	nPosR := At("R",cFaseOrc)
	if Type("aResDel") == "A" .and. Len(aResDel) > 0 
		nPosR := 0
	Endif
	nPosT := At("T",cFaseOrc)
	nPos2 := At("2",cFaseOrc)
	nPosB := At("B",cFaseOrc)
	nPosA := At(VS1->VS1_STATUS,cFaseOrc)
	cDocto := "X"
	if nPosI < nPosT .and. nPosT <= nPosA
		DBSelectArea("VDD")
		DBSetOrder(4)
		DBSeek(xFilial("VDD") + VS1->VS1_FILIAL + VS1->VS1_NUMORC)  
		lResTrf := .f.
		while xFilial("VDD") + VS1->VS1_FILIAL + VS1->VS1_NUMORC == VDD->VDD_FILIAL + VDD->VDD_FILORC + VDD->VDD_NUMORC
			if VDD->VDD_STATUS == "S"
				reclock("VDD",.f.,.t.)
				dbdelete()
				msunlock()
			endif    
			lResTrf := .t.
			DBSkip()
		enddo
	endif
	if nPosI < nPosB .and. nPosB <= nPosA 
		If TCCanOpen(RetSqlName("VQH"))
			cString := "DELETE FROM "+RetSqlName("VQH")+ " WHERE VQH_FILIAL = '"+ xFilial("VQH")+"' AND VQH_NUMORC= '"+VS1->VS1_NUMORC+"'"
			TCSqlExec(cString)
		endif
	endif


	if (nPosI < nPosR .and. nPosR <= nPosA) .or. lResTrf // o .or. é para Desreservar quando houve cancelamento da Transferencia
		Begin Transaction
			If ( lNewRes ) // Chama desreserva de todos os itens do orçamento
				cDocto := OA4820015_ProcessaReservaItem("OR",VS1->(RecNo()),"A","D",,"03")
			Else
				cDocto := OX001RESITE(VS1->VS1_NUMORC,.f.)
			EndIf
		End Transaction
	endif
	if cDocto == ""
		MsgInfo(STR0018,STR0019)
		return .f.
	endif
	// verifica se precisa cancelar pedido de liberacao
	if nPosI <= nPos2 .and. nPos2 <= nPosA
		if !Empty(VS1->VS1_NUMLIB)
			If TCCanOpen(RetSqlName("VS7"))
				cString := "DELETE FROM "+RetSqlName("VS7")+ " WHERE VS7_FILIAL = '"+ xFilial("VS7")+"' AND VS7_NUMIDE= '"+VS1->VS1_NUMLIB+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			If TCCanOpen(RetSqlName("VS6"))
				cString := "DELETE FROM "+RetSqlName("VS6")+ " WHERE VS6_FILIAL = '"+ xFilial("VS6")+"' AND VS6_NUMIDE= '"+VS1->VS1_NUMLIB+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			DBSelectArea("VS1")
			reclock("VS1",.f.)
			VS1->VS1_NUMLIB := ""
			msunlock()
		endif
		if ( VS1->(FieldPos("VS1_NUMLIS")) > 0 .and. !Empty(VS1->VS1_NUMLIS))
			If TCCanOpen(RetSqlName("VS7"))
				cString := "DELETE FROM "+RetSqlName("VS7")+ " WHERE VS7_FILIAL = '"+ xFilial("VS7")+"' AND VS7_NUMIDE= '"+VS1->VS1_NUMLIS+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			If TCCanOpen(RetSqlName("VS6"))
				cString := "DELETE FROM "+RetSqlName("VS6")+ " WHERE VS6_FILIAL = '"+ xFilial("VS6")+"' AND VS6_NUMIDE= '"+VS1->VS1_NUMLIS+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			DBSelectArea("VS1")
			reclock("VS1",.f.)
			VS1->VS1_NUMLIS := ""
			msunlock()
		endif
	endif
	DBSelectArea("VS1")
	OI001ATU(VS1->VS1_NUMORC,cFaseIni)
endif
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OI001ATU   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza Status no VS1                                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OI001ATU(cNumOrc,cFaseAtu,cVS1Status)
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cNumOrc)
//
reclock("VS1",.f.)
cVS1StAnt := VS1->VS1_STATUS
VS1->VS1_STATUS := cFaseAtu
cVS1Status := VS1->VS1_STATUS
msunlock()
If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
	OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0029,STR0028) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
EndIf
If FindFunction("FM_GerLog")
	//grava log das alteracoes das fases do orcamento
	FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
EndIF
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |OI001GETFASE| Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Retorna as fases do orçamento com base no VAI+parâmetros     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OI001GETFASE(cNumPar,nTipo)
Local cFases := GetNewPar("MV_FASEORC","0FX")
Default nTipo := 1
//
if nTipo == 1
	if VS1->(FieldPos("VS1_MVFASE")) > 0
		if !Empty(VS1->VS1_MVFASE)
			cFases := GetNewPar("MV_FASEOR"+VS1->VS1_MVFASE,"0FX")
		endif
	endif
else
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI") + cNumPar)
	if found()
		if VAI->(FieldPos("VAI_MVFASE")) > 0
			if !Empty(VAI_MVFASE)
				cFases := GetNewPar("MV_FASEOR"+VAI_MVFASE,"0FX")
			endif
		endif
	endif
endif

return cFases



//Static Function TempoProc(nTipo, cCodigo, cDescricao)
//	If lDebug
//		do Case
//		case ntipo == 1
//			oXI001TempoProc:IniProc(cCodigo, cDescricao)
//		case ntipo == 2
//			oXI001TempoProc:FimProc(cCodigo)
//		case nTipo == 3
//			oXI001TempoProc := tkTempoProc():New()
//		case nTipo == 4
//			//ConOut( " ")
//			//oXI001TempoProc:Conout()
//			//ConOut( " ")
//			oXI001TempoProc:Visualizar()
//			oXI001TempoProc:Clear()
//		endcase
//	EndIf
//
//Return

//Static Function NomeFase(cAuxFase)
//
//	Do Case
//		Case cAuxFase == "2" ; Return "MARGEM DE LUCRO"
//		Case cAuxFase == "3" ; Return "LIMITE DE CREDITO"
//		Case cAuxFase == "4" ; Return "SEPARACAO E CONFERENCIA"
//		Case cAuxFase == "5" ; Return "LIBERACAO DE DIVERGENCIA"
//		Case cAuxFase == "E" ; Return "ORCAMENTO ENVIO DE EMAIL"
//		Case cAuxFase == "R" ; Return "RESERVA O ITEM"
//		Case cAuxFase == "O" ; Return "IMPRIME ORDEM DE BUSCA"
//		Case cAuxFase == "B" ; Return "GRAVAÇÃO DO VQH (BACKORDER)"
//		Case cAuxFase == "T" ; Return "RESERVA O ITEM"
//		Case cAuxFase == "X" ; Return "ORCAMENTO FECHADO"
//		Case cAuxFase == "C" ; Return "ORCAMENTO CANCELADO"
//		Otherwise ; Return ""
//	End Case
//
//Return ""


/*/{Protheus.doc} OI001001C_ProblemaMargemDesconto
	Nova tela unificada p/ demonstrar problema de Margem/Desconto e solicitar a Liberação
	@author Cristiam Rossi
	@since 15/08/2025
	@type function
	@param cNumOrc, character, número do orçamento
	@return logical, Gerou solicitação ou cancelou
/*/
static function OI001001C_ProblemaMargemDesconto( cNumOrc )
local   aArea   := getArea()
local   lGerou  := .F.
local   oSize   := FwDefSize():New(.F.)
local   nPercRoda := 100 * 28 / oSize:aWindSize[3]
local   oExecView
local   oStrVS6 := FWFormStruct(2, "VS6", {|cpo| alltrim(cpo) $ "VS6_DESOCO,VS6_OBSERV" })	// campos visíveis
local   oStrVS7 := FWFormStruct(2, "VS7", {|cpo| alltrim(cpo) $ "VS7_GRUITE,VS7_CODITE,VS7_DESDES,VS7_VALORI,VS7_VALDES,VS7_MARLUC,VS7_QTDITE,VS7_DESITE" })	// campos visíveis
private oModel  := FWLoadModel("OFIXA015")
private oView   := FWFormView():New()

	oView:SetModel(oModel)
	oModel:SetPost({|oModel| validaDados(oModel)})

	oView:AddField('VIEW_VS6', oStrVS6, 'VS6MASTER')
	oView:AddGrid('VIEW_VS7' , oStrVS7, 'VS7DETAIL')

	oStrVS7:AddField("LEGENDA","01","","",{},"C","@BMP",,,.F.,,,,,,.T.)

	oStrVS7:SetProperty( 'LEGENDA'    , MVC_VIEW_ORDEM, '01')
	oStrVS7:SetProperty( 'VS7_GRUITE' , MVC_VIEW_ORDEM, '02')
	oStrVS7:SetProperty( 'VS7_CODITE' , MVC_VIEW_ORDEM, '03')
	oStrVS7:SetProperty( 'VS7_DESITE' , MVC_VIEW_ORDEM, '04')
	oStrVS7:SetProperty( 'VS7_QTDITE' , MVC_VIEW_ORDEM, '05')
	oStrVS7:SetProperty( 'VS7_VALORI' , MVC_VIEW_ORDEM, '06')
	oStrVS7:SetProperty( 'VS7_DESDES' , MVC_VIEW_ORDEM, '07')
	oStrVS7:SetProperty( 'VS7_VALDES' , MVC_VIEW_ORDEM, '08')
	oStrVS7:SetProperty( 'VS7_MARLUC' , MVC_VIEW_ORDEM, '09')

	oView:CreateHorizontalBox('VS6',40)
	oView:CreateHorizontalBox('VS7', 60 - nPercRoda)
	oView:CreateHorizontalBox('RODA', nPercRoda)

	oView:AddOtherObject("RODAPE", {|oPanel| OA015001C_Rodape(oPanel)})

	oView:SetOwnerView('VIEW_VS6','VS6')
	oView:SetOwnerView('VIEW_VS7','VS7')
	oView:SetOwnerView('RODAPE'  ,'RODA')

	oModel:setOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	if preencheDados( oModel, cNumOrc ) > 0
		oExecView := FWViewExec():New()
		oExecView:setTitle( STR0031 )	// "Problema de Margem e Desconto"
		oExecView:setModel(oModel)
		oExecView:setView(oView)
		oExecView:setOperation(MODEL_OPERATION_INSERT)
		oExecView:setCloseOnOK({||.T.})
		oExecView:openView(.T.)

		if VS6->VS6_NUMORC == cNumOrc
			lGerou := .T.
			recLock("VS1", .F.)
			VS1->VS1_NUMLIB := VS6->VS6_NUMIDE
			msUnlock()
		endif
	endif
	oModel:DeActivate()
	freeObj(oStrVS6)
	freeObj(oStrVS7)
	freeObj(oModel)
	freeObj(oView)
	freeObj(oExecView)

	restArea( aArea )
return lGerou


/*/{Protheus.doc} preencheDados
	rotina que preenche os dados no MVC p/ mostrar ao usuário
	@author Cristiam Rossi
	@since 15/08/2025
	@type function
	@param oModel, object, Model MVC
	@param cNumOrc, character, número do orçamento
	@return numeric, número de produtos com problema
/*/
static function preencheDados( oModel, cNumOrc )
local   oModelVS6   := oModel:GetModel('VS6MASTER')
local   oModelVS7   := oModel:GetModel('VS7DETAIL')
local   nPDescUsu   := 0
local   cVS1CONPRO  := "2"
local   nVS1PERREM  := 0
local   dDatRefPD   := dDatabase
local   nItVS7      := 0
local   lVS7SemProb := AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto
local   nItens      := 0
private nDesPer     := 0

	VAI->(DBSetOrder(4))
	If VAI->(DBSeek(xFilial("VAI")+__cUserID))
		nPDescUsu := VAI->VAI_DESPEC
		If VAI->VAI_DTCDES == "1" // Utilizar 1=Data de Inclusão do Orçamento para validar a Politica de Desconto
			dDatRefPD := VS1->VS1_DATORC
		EndIf
	EndIf

	SB1->( DBSetOrder(7))
	SB2->( dbSetOrder(1))
	SBM->( dbSetOrder(1) )

	VS1->( dbSetOrder(1) )
	VS1->( dbSeek( xFilial("VS1") + cNumOrc ) )
	cVS1CONPRO := VS1->VS1_CONPRO
	nVS1PERREM := VS1->VS1_PERREM

	VS3->( dbSetOrder(1) )
	VS3->( dbSeek( xFilial("VS3") + VS1->VS1_NUMORC ) )

	oModelVS6:setValue("VS6_FILIAL" , xFilial("VS6") )
	oModelVS6:setValue("VS6_NUMIDE" , GetSxENum("VS6","VS6_NUMIDE") )
	oModelVS6:setValue("VS6_TIPAUT" , "1" )
	oModelVS6:setValue("VS6_CODCLI" , VS1->VS1_CLIFAT )
	oModelVS6:setValue("VS6_LOJA"   , VS1->VS1_LOJA )
	oModelVS6:setValue("VS6_DATOCO" , dDataBase )
	oModelVS6:setValue("VS6_HOROCO" , val(substr(time(),1,2)+substr(time(),4,2)) )
	oModelVS6:setValue("VS6_NUMORC" , VS1->VS1_NUMORC )
	oModelVS6:setValue("VS6_TIPOCO" , "000008" )
	oModelVS6:setValue("VS6_DESOCO" , STR0012 )
	oModelVS6:setValue("VS6_USUARI" , substr(cUsuario,7,15) )
	oModelVS6:setValue("VS6_FORPAG" , VS1->VS1_FORPAG )
	oModelVS6:setValue("VS6_PERREM" , VS1->VS1_PERREM )
	oModelVS6:setValue("VS6_DESPER" , VAI->VAI_DESPEC )

	while VS3->( VS3_FILIAL + VS3_NUMORC ) == VS1->( VS1_FILIAL + VS1_NUMORC )
		nItVS7++
		SBM->( dbSeek( xFilial("SBM") + VS3->VS3_GRUITE ) )
		SB1->( DBSeek( xFilial("SB1") + VS3->VS3_GRUITE + VS3->VS3_CODITE ) )
		SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + VS3->VS3_LOCAL ) )

		aRetDes := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,.t.,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VS1->VS1_TIPVEN,VS3->VS3_VALTOT/VS3->VS3_QTDITE,3,VS1->VS1_FORPAG,,,,cVS1CONPRO,dDatRefPD,nVS1PERREM)
		
		nPercMin := aRetDes[3]
		nValPerc = FG_FORMULA(GetNewPar("MV_FORMALI","")) // valor minimo de venda considerando a margem de lucro minima
		nValDesc = (1- aRetDes[2]/100) * VS3->VS3_VALPEC // valor minimo de venda da peca considerando desconto maximo
		if nValPerc > nValDesc
			nValPerm := nValPerc
		else
			nValPerm := nValDesc
		endif
		if aRetDes[1] != 0
			nValPerm := aRetDes[1]
		endif

		if ! aIDescont[nItVS7] .or. lVS7SemProb
			if ++nItens > 1
				oModelVS7:AddLine()
			endif

			oModelVS7:setValue("VS7_FILIAL", xFilial("VS7") )
			oModelVS7:setValue("VS7_NUMIDE", oModelVS6:getValue("VS6_NUMIDE") )
			oModelVS7:setValue("VS7_SEQUEN", strZero( oModelVS7:Length(), 4) )
			oModelVS7:setValue("VS7_TIPAUT", "1" )
			oModelVS7:setValue("VS7_GRUITE", VS3->VS3_GRUITE )
			oModelVS7:setValue("VS7_CODITE", VS3->VS3_CODITE )
			oModelVS7:setValue("VS7_DESITE", posicione("SB1",7,xFilial("SB1")+VS3->(VS3_GRUITE+VS3_CODITE),"B1_DESC") )
			oModelVS7:setValue("VS7_DESPER", aRetDes[2] )
			oModelVS7:setValue("VS7_DESDES", VS3->VS3_PERDES )
			oModelVS7:setValue("VS7_VALORI", VS3->VS3_VALPEC )
			oModelVS7:setValue("VS7_VALPER", nValPerm )
			oModelVS7:setValue("VS7_VALDES", VS3->VS3_VALPEC - (VS3->VS3_VALDES/VS3->VS3_QTDITE) )
			oModelVS7:setValue("VS7_MARPER", aRetDes[3] )
			oModelVS7:setValue("VS7_MARLUC", VS3->VS3_MARLUC )
			oModelVS7:setValue("VS7_QTDITE", VS3->VS3_QTDITE )
			oModelVS7:setValue("VS7_DIVERG", iif(aIDescont[nItVS7],"0","1") )
			oModelVS7:loadValue("LEGENDA"  , iif(aIDescont[nItVS7],"BR_VERDE","BR_VERMELHO") )
		endif
		VS3->( dbSkip() )
	endDo
	oModelVS7:GoLine(1)

	oModel:GetModel('VS7DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('VS7DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('VS7DETAIL'):SetNoUpdateLine(.T.)
return aScan( aIDescont, .F. )


/*/{Protheus.doc} validaDados
	rotina validação preenchimento dos campos
	@author Cristiam Rossi
	@since 15/08/2025
	@type function
	@param oModel, object, Model MVC
	@return logical, validação preenchimento dos campos
/*/
static function validaDados(oModel)
local lRet      := .T.
local oModelVS6 := oModel:GetModel('VS6MASTER')

	oModel:GetModel('VS7DETAIL'):SetNoUpdateLine(.T.)

	if oModel:GetOperation() == MODEL_OPERATION_INSERT
		if empty( oModelVS6:getValue("VS6_OBSERV") )
			FMX_HELP("OFIXI001",STR0032,STR0033)	// "Observação para liberação em branco"  "Favor preencher o campo"
			lRet := .F.
		endif
	endif
return lRet
