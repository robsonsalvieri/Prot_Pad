#include "protheus.ch"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHEXPSM0 ³ Autor ³ Fabio Garbin          ³ Data ³ 19/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho de Empresa.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XEXPSM0()
Local cIntr := "I"
Local cId   :=  ""
Local cMCSIP := GetMV("MV_MCSIP",,"")
Local cMCSPRT := GetMV("MV_MCSPRT",,0)
Local cMCSTO := GetMV("MV_MCSTO",,0)

dbSelectArea("SM0")
dbSetOrder(1)
If dbSeek(AllTrim((PGALIAS)->HHG_EMPFIL))
	cId := HHCheckID("HM0")
	dbSelectArea("HM0")
	dbSetOrder(1)
	If !dbSeek(cId + SM0->M0_CODIGO + SM0->M0_CODFIL)
		RecLock("HM0", .T.)
	Else
		RecLock("HM0", .F.)
	EndIf
	HM0->HM0_ID      := cId
	HM0->HM0_FILIAL  := SM0->M0_CODFIL
	HM0->HM0_COD     := SM0->M0_CODIGO
	HM0->HM0_NOME    := SM0->M0_NOME
	HM0->HM0_NOMCOM  := SM0->M0_NOMECOM
	HM0->HM0_ENDCOB  := SM0->M0_ENDCOB
	HM0->HM0_BAICOB  := SM0->M0_BAIRCOB
	HM0->HM0_CIDCOB  := SM0->M0_CIDCOB
	HM0->HM0_ESTCOB  := SM0->M0_ESTCOB
	HM0->HM0_CEPCOB  := SM0->M0_CEPCOB
	HM0->HM0_CGC     := SM0->M0_CGC
	HM0->HM0_INSC    := SM0->M0_INSC
	HM0->HM0_TEL     := SM0->M0_TEL
	HM0->HM0_INTR    := cIntr
	HM0->HM0_VER     := 1
	HM0->HM0_MCSIP   := cMCSIP
	HM0->HM0_MCSPRT  := cMCSPRT
	HM0->HM0_MCSTO   := cMCSTO
	HM0->HM0_MCSSER  := HGU->HGU_SERIE
	HM0->HM0_SUFIXO  := (PGALIAS)->HHG_SUFIXO
	HM0->HM0_EMP     := SM0->M0_CODIGO
	HM0->(MsUnlock())
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHEXPSA3 Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho do Vendedor.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³Geracao das bases para versao em Advpl           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XEXPSA3()
Local cVendedor   := HGU->HGU_CODBAS
Local cIntr := "I"
Local cId := ""
Local cTime := ""
Local dDtRef := CtoD(GetMv("MV_SFAREF",,"01/01/2000"))
Local cProxPed := ""

dbSelectArea("SA3")
dbSetOrder(1)
If dbSeek(xFilial("SA3")+cVendedor)
	cId := HHCheckID("HA3", "SA3")
	dbSelectArea("HA3")
	dbSetOrder(1)
	If !dbSeek(xFilial("SA3") + cId + cVendedor)
		RecLock("HA3", .T.)
	Else
		RecLock("HA3", .F.)
	EndIf	
	HA3->HA3_FILIAL     := xFilial("SA3")
	HA3->HA3_ID     := cId
	HA3->HA3_COD    := SA3->A3_COD
	HA3->HA3_NREDUZ := SA3->A3_NREDUZ
	HA3->HA3_COMISS  := SA3->A3_COMIS
	HA3->HA3_SENHA  := SA3->A3_SENHA
//	HA3->HA3_MSGVEN := SA3->A3_MENS1
//	HA3->HA3_MSGEMP := SA3->A3_MENS2
	HA3->HA3_PEDINI := If(Empty(SA3->A3_PEDINI), "000000", SA3->A3_PEDINI)
	HA3->HA3_PEDFIM := If(Empty(SA3->A3_PEDFIM), "999999", SA3->A3_PEDFIM)
	HA3->HA3_CLIINI := If(Empty(SA3->A3_CLIINI), "000000", SA3->A3_CLIINI)
	HA3->HA3_CLIFIM := If(Empty(SA3->A3_CLIFIM), "999999", SA3->A3_CLIFIM)

	cTime := Time()
	cProxPed := ((Date() - dDtRef) * 24) + (Val(Subs(cTime,1,2))*60) + Val(Subs(cTime,4,2))
	
	HA3->HA3_PROPED := StrZero(cProxPed,6)
	HA3->HA3_PROCLI := SA3->A3_PROXCLI
	HA3->HA3_VER     := 1
	HA3->HA3_INTR   := cIntr
	HA3->(MsUnlock())
EndIf
/*
// Grava as metas       
dbSelectArea("SCT")
dbSetOrder(1)
If SCT->( !Eof() )
	RecLock("HMT", .T.)
	cAno1 := Str(Year( SCT->CT_DATA ),4 ) 
	cMes1 := StrZero(Month(SCT->CT_DATA),2) 
	HMT->MT_DATA     := cMes1 + cAno1 
	HMT->MT_GRUPO    := SCT->CT_GRUPO
	HMT->MT_PROD     := SCT->CT_PRODUTO
	HMT->MT_QTD      := SCT->CT_QUANT
	HMT->MT_QTDR     := 0
	HMT->MT_VALOR    := SCT->CT_VALOR
	HMT->MT_VALORR   := 0
	
	HMT->(MsUnlock())
	
	SCT->( dbSkip() )
EndIf
*/
//HHCloseAlias()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHExpAD7    ³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Rotas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³Geracao das bases para versao Eadvpl             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XEXPAD7()
Local aDow       := {"Dom","Seg","Ter","Qua","Qui","Sex","Sab"}
Local dDataAnt   := Date()
Local nVisAtu    := 0
Local cRota      := ""
Local cVendedor  := HGU->HGU_CODBAS
Local cIntr := "I"
Local cId := ""

// Grava Arquivos Temporarios
dbSelectArea("AD7")
dbSetOrder(1)
dbSeek(xFilial("AD7")+cVendedor)
dDataAnt := AD7->AD7_DATA
nRotaAtu := 1
nVisAtu  := 1
cId := HHCheckID("HRT", "AD7")
While !AD7->(Eof()) .and. AD7->AD7_FILIAL= xFilial("AD7") .and. AD7->AD7_VEND = cVendedor
	If AD7->AD7_DATA <> dDataAnt
		cRota := StrZero(nRotaAtu, 6)
		dbSelectArea("HRT")
		RecLock("HRT",.T.)
		HRT->HRT_FILIAL := xFilial("AD7")
		HRT->HRT_ID := cId
		HRT->HRT_PERCUR := cRota
		HRT->HRT_ROTA   := cRota
		HRT->HRT_DESCR  :=  Dtoc(dDataAnt) + " - " +  aDow[Dow(dDataAnt)]
		HRT->HRT_VER     := 1
		HRT->HRT_INTR  := cIntr
		HRT->(MsUnlock())
		nRotaAtu += 1
		nVisAtu  := 1
		dDataAnt := AD7->AD7_DATA
		
	EndIf
	
	dbSelectArea("SA1")
	dbSeek(xFilial("SA1")+AD7->AD7_CODCLI+AD7->AD7_LOJA)
	dbSelectArea("HD7")

	// Grava Roteiro
	RecLock("HD7",.T.)
	HD7->HD7_FILIAL := xFilial("AD7")
	HD7->HD7_ID := cId
	HD7->HD7_ROTA    := StrZero(nRotaAtu,6)
	HD7->HD7_PERCUR  := StrZero(nRotaAtu,6)
	HD7->HD7_DESPER  := ""
	HD7->HD7_ORDEM   := StrZero(nVisAtu,4)
	HD7->HD7_CLI     := AD7->AD7_CODCLI 
	HD7->HD7_LOJA    := AD7->AD7_LOJA
	HD7->HD7_DATA    := AD7->AD7_DATA
	//HD7->AD7_FLGVIS  := ""
	HD7->HD7_OCO     := Space(6)
	HD7->HD7_DT      := CtoD("  /  /  ")
	HD7->HD7_VER     := 1
	HD7->HD7_INTR      := cIntr
	nVisAtu += 1
	HD7->(MsUnlock())

	dbSelectArea("AD7")
	dbSkip()
	If Eof() .Or. AD7->AD7_FILIAL <> xFilial("AD7") .Or. AD7->AD7_VEND <> cVendedor
		cRota := StrZero(nRotaAtu, 6)
		dbSelectArea("HRT")
		RecLock("HRT",.T.)
		HRT->HRT_FILIAL := xFilial("AD7")
		HRT->HRT_ID := cId
		HRT->HRT_PERCUR:= cRota
		HRT->HRT_ROTA  := cRota
		HRT->HRT_DESCR := Dtoc(dDataAnt) + " - " +  aDow[Dow(dDataAnt)]
		HRT->HRT_VER     := 1
		HRT->HRT_INTR  := cIntr
		HRT->(MsUnlock())
		nRotaAtu += 1
		nVisAtu  := 1
		dDataAnt := AD7->AD7_DATA
		
	EndIf
EndDo
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHExpSA1 ³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Clientes.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³ Geracao de bases da versao Eadvpl               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XEXPSA1()
Local i          := 0
Local nX         := 1
Local cVendedor  := HGU->HGU_CODBAS
Local cIntr := "I"
Local cId := ""
Local cGeraCons  := GetMV("MV_HHCONS",,"T")

Private cAliasSA1  := "SA1"
Private cAliasSE1  := "SE1"
Private cAliasSB1  := "SB1"

dbSelectArea("SA1")
dbSetOrder(1)

#IFDEF TOP
	lQuery := .T.

	aStruSA1  := SA1->(dbStruct())
	aStruSE1  := SE1->(dbStruct())
	cAliasSA1 := "CLIENTE"
	cAliasSE1 := "FINANC"
	
	// Query para o Arquivo de Cliente
	cQuerySA1 := "SELECT * "
	cQuerySA1 += "FROM "+RetSqlName("SA1")+" SA1 "
	cQuerySA1 += "WHERE SA1.A1_FILIAL='" + xFilial("SA1") + "' AND "
	cQuerySA1 += "SA1.A1_VEND = '" + cVendedor + "' AND "
	cQuerySA1 += "SA1.D_E_L_E_T_ = ' ' "
	// Ponto de Entrada deve retornar complemento da Query
	If ((ExistBlock("PLMCLI01")))
		cQuerySA1 += ExecBlock("PLMCLI01",.F.,.F.)
	EndIf
	cQuerySA1 += "ORDER BY " + SqlOrder(SA1->(IndexKey()))
	
	cQuerySA1 := ChangeQuery(cQuerySA1)

	Memowrite("HHCliente.txt", cQuerySA1)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySA1),cAliasSA1,.T.,.T.)
	cId := HHCheckID("HA1", cAliasSA1)

	// Seleciona TODOS os Titulos de TODOS os Clientes 
 	dbSelectArea("SE1")
	dbSetOrder(2)    
	cQuerySE1 := "SELECT '" + xFilial("SE1") + "' HE1_FILIAL, '" + cId + "' HE1_ID, E1_CLIENTE HE1_CLI, E1_LOJA HE1_LOJA, E1_TIPO HE1_TIPO, E1_EMISSAO HE1_EMISS, E1_VENCTO HE1_VENCTO, E1_SALDO HE1_SALDO"
	cQuerySE1 += 	", E1_NUM HE1_NUM, E1_PARCELA HE1_PARCEL, 1 HE1_VER, 'I' HE1_INTR "
	cQuerySE1 += "FROM " + RetSqlName("SE1") + " SE1," + RetSqlName("SA1") + " SA1 "
	cQuerySE1 += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND " 
	cQuerySE1 += "SA1.A1_VEND = '" + cVendedor + "' AND "
	cQuerySE1 += "SE1.E1_CLIENTE = SA1.A1_COD AND "
	cQuerySE1 += "SE1.E1_LOJA = SA1.A1_LOJA AND "
	cQuerySE1 += "SE1.E1_SALDO > 0 AND "
	cQuerySE1 += "SE1.D_E_L_E_T_ <> '*' "
	// Ponto de Entrada deve retornar complemento da Query
	If ((ExistBlock("PLMFIN01")))
		cQuerySE1 += ExecBlock("PLMFIN01",.F.,.F.)
	EndIf

	cQuerySE1 += "ORDER BY " + SqlOrder(SE1->(IndexKey()))

	cQuerySE1 := ChangeQuery(cQuerySE1)
	
	Memowrite("HHDupli.txt", cQuerySE1)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySE1),cAliasSE1,.T.,.T.)

	For nX := 1 To Len(aStruSA1)
		If aStruSA1[nX][2]<>"C" .And. (cAliasSA1)->(FieldPos(aStruSA1[nX][1])>0)
			TcSetField(cAliasSA1,aStruSA1[nX][1],aStruSA1[nX][2],aStruSA1[nX][3],aStruSA1[nX][4])
	    EndIf
	Next nX

	For nX := 1 To Len(aStruSE1)
		If aStruSE1[nX][2]<>"C" .And. (cAliasSE1)->(FieldPos(aStruSE1[nX][1])>0)
			TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
	    EndIf
	Next nX
	// Grava o arquivo HE1 (Titulos Abertos) de Todos os Clientes do Vendedor
	dbSelectArea("HE1")
	Append From (cAliasSE1)	

	aCons := {}
	// Calcula os Consumos
	If cGeraCons = "T"
		U_XExpSF2(@aCons,,)
	
		// Grava o Arquivo de Consumo
		For i := 1 To Len(aCons)
			dbSelectArea("HCN")
			RecLock("HCN",.T.)
			HCN->HCN_FILIAL := xFilial("SF2")
			HCN->HCN_ID     := cId
			HCN->HCN_CLIENT := aCons[i,2]
			HCN->HCN_LOJA   := aCons[i,3]
			HCN->HCN_GRUPO  := aCons[i,4]
			HCN->HCN_PROD   := aCons[i,5]
			HCN->HCN_ANOANT := aCons[i,6]
			HCN->HCN_MESANT := aCons[i,7]
			HCN->HCN_MESATU := aCons[i,8]		
			HCN->HCN_INTR     := cIntr
			HCN->HCN_VER     := 1		
			HCN->(MsUnlock())	
		Next
	EndIf

#ELSE  // Quando Nao TOP utiliza-se Filtro
	dbSelectArea(cAliasSA1)
	cFiltro := "A1_VEND = '" + cVendedor + "'"
	// Ponto de Entrada deve retornar complemento do Filtro
	If ((ExistBlock("PLMCLI01")))
		cFiltro += ExecBlock("PLMCLI01",.F.,.F.)
	EndIf
	Set Filter to &cFiltro
	dbSeek(xFilial("SA1"))
	cId := HHCheckID("HA1", cAliasSA1)
#ENDIF
While !(cAliasSA1)->(Eof()) .And. (cAliasSA1)->A1_FILIAL == xFilial("SA1")

	dbSelectArea("HA1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SA1") + cId + (cAliasSA1)->A1_COD + (cAliasSA1)->A1_LOJA)
		RecLock("HA1", .T.)
	Else
		RecLock("HA1", .F.)
	EndIf

	// *** Grava Arquivo de Cliente
	HA1->HA1_FILIAL := xFilial("SA1")
	HA1->HA1_ID := cId
	HA1->HA1_COD    := (cAliasSA1)->A1_COD
	HA1->HA1_LOJA   := (cAliasSA1)->A1_LOJA
	HA1->HA1_CGC    := (cAliasSA1)->A1_CGC
	HA1->HA1_NOME   := (cAliasSA1)->A1_NOME
	HA1->HA1_NREDUZ := (cAliasSA1)->A1_NREDUZ
	HA1->HA1_TIPO   := (cAliasSA1)->A1_TIPO
	HA1->HA1_END    := (cAliasSA1)->A1_END
	HA1->HA1_MUN    := (cAliasSA1)->A1_MUN
	HA1->HA1_EST    := (cAliasSA1)->A1_EST
	HA1->HA1_BAIRRO := (cAliasSA1)->A1_BAIRRO
	HA1->HA1_CEP    := (cAliasSA1)->A1_CEP
	HA1->HA1_TEL    := (cAliasSA1)->A1_TEL
	HA1->HA1_FAX    := (cAliasSA1)->A1_FAX
	HA1->HA1_INSCR  := (cAliasSA1)->A1_INSCR
	HA1->HA1_INSCRM := (cAliasSA1)->A1_INSCRM
	HA1->HA1_VEND   := (cAliasSA1)->A1_VEND
	HA1->HA1_REGIAO := (cAliasSA1)->A1_REGIAO
	HA1->HA1_TRANSP := (cAliasSA1)->A1_TRANSP
	HA1->HA1_TPFRET := (cAliasSA1)->A1_TPFRET
	HA1->HA1_COND   := (cAliasSA1)->A1_COND
	HA1->HA1_RISCO  := (cAliasSA1)->A1_RISCO
	HA1->HA1_LC     := (cAliasSA1)->A1_LC
	HA1->HA1_VENCLC := (cAliasSA1)->A1_VENCLC
	HA1->HA1_MCOMPR := (cAliasSA1)->A1_MCOMPRA
	HA1->HA1_METR   := (cAliasSA1)->A1_METR
	HA1->HA1_MSALDO := (cAliasSA1)->A1_MSALDO
	HA1->HA1_NROCOM := (cAliasSA1)->A1_NROCOM
	HA1->HA1_PRICOM := (cAliasSA1)->A1_PRICOM
	HA1->HA1_ULTCOM := (cAliasSA1)->A1_ULTCOM
	HA1->HA1_ULTVIS := (cAliasSA1)->A1_ULTVIS
	HA1->HA1_NROPAG := (cAliasSA1)->A1_NROPAG
	HA1->HA1_SALDUP := (cAliasSA1)->A1_SALDUP
	HA1->HA1_SALPDL := (cAliasSA1)->A1_SALPEDL
	HA1->HA1_ATR    := (cAliasSA1)->A1_ATR
	HA1->HA1_VACUM  := (cAliasSA1)->A1_VACUM
	HA1->HA1_SALPED := (cAliasSA1)->A1_SALPED
	HA1->HA1_TITPRO := (cAliasSA1)->A1_TITPROT
	HA1->HA1_DTULTI := (cAliasSA1)->A1_DTULTIT
	HA1->HA1_CHQDEV := (cAliasSA1)->A1_CHQDEVO
	HA1->HA1_DTULCH := (cAliasSA1)->A1_DTULCHQ
	HA1->HA1_MATR   := (cAliasSA1)->A1_MATR
	HA1->HA1_MAIDUP := (cAliasSA1)->A1_MAIDUPL
	HA1->HA1_TABELA := (cAliasSA1)->A1_TABELA
	HA1->HA1_PAGATR := (cAliasSA1)->A1_PAGATR
	HA1->HA1_RG     := (cAliasSA1)->A1_RG
	HA1->HA1_DTNASC := (cAliasSA1)->A1_DTNASC
	HA1->HA1_EMAIL  := (cAliasSA1)->A1_EMAIL
	If HA1->(FieldPos("HA1_GRPVEN")) > 0 .And. (cAliasSA1)->(FieldPos("A1_GRPVEN")) > 0
		HA1->HA1_GRPVEN := (cAliasSA1)->A1_GRPVEN
	EndIf
	HA1->HA1_STATUS := "P"
	HA1->HA1_FLGVIS := "0"
	HA1->HA1_OCO    := ""
	HA1->HA1_CNDFIX := If(FieldPos("A1_CNDFIX") >0, (cAliasSA1)->A1_CNDFIX, 2)
	HA1->HA1_FORPAG := If(FieldPos("A1_FORPAG")>0, (cAliasSA1)->A1_FORPAG, "")
	HA1->HA1_VER     := 1
	HA1->HA1_INTR   := cIntr
	HA1->(MsUnlock())

	cCliLoj := (cAliasSA1)->A1_COD + (cAliasSA1)->A1_LOJA
	//  *** Grava Arquivo de Contatos Utilizando AC8/SU5 ***
	dbSelectArea("AC8")
	dbSetOrder(2)
	dbSeek(xFilial("AC8")+"SA1"+xFilial("SA1")+cCliLoj)
	While AC8->(Eof()) .And. xFilial("AC8") = AC8->AC8_FILIAL .And. xFilial("SA1") = AC8->AC8_FILENT .And. AC8_CODENT = cCliLoj
		dbSelectArea("SU5")
		dbSetOrder(1)
		If !dbSeek(xFilial("SU5")+AC8->AC8_CODCON)
			dbSelectArea("AC8")
			dbSkip()
			Loop
		EndIf
		If SU5->U5_ATIVO == "1" 
 			dbSelectArea("HU5")
 			dbSetOrder(1)
			If !dbSeek(xFilial("SU5") + cId + (cAliasSA1)->A1_COD + (cAliasSA1)->A1_LOJA + SU5->U5_CODCONT)
				RecLock("HU5", .T.)
			Else
				RecLock("HU5", .F.)
			EndIf
			HU5->HU5_FILIAL := xFilial("SU5")
			HU5->HU5_ID     := cId
			HU5->HU5_CLIENT := (cAliasSA1)->A1_COD
			HU5->HU5_LOJA   := (cAliasSA1)->A1_LOJA
			HU5->HU5_CODCON := SU5->U5_CODCONT
			HU5->HU5_CONTAT := SU5->U5_CONTAT
			HU5->HU5_CPF    := SU5->U5_CPF
			HU5->HU5_FUNCAO := SU5->U5_FUNCAO
			HU5->HU5_FONE   := SU5->U5_FONE
			HU5->HU5_CEL    := SU5->U5_CELULAR
			HU5->HU5_EMAIL  := SU5->U5_EMAIL
			HU5->HU5_DTNASC := CtoD("  /  /  ")
			HU5->HU5_RG     := ""
			HU5->HU5_STATUS := "P"
			HU5->HU5_VER     := 1
			HU5->HU5_INTR   := cIntr
			HU5->(MsUnlock())
		EndIf
		dbSelectArea("AC8")
		dbSkip()
	EndDo

	dbSelectArea(cAliasSA1)
	dbSkip()
EndDo
	
If lQuery
	(cAliasSA1)->(dbCloseArea())
	(cAliasSE1)->(dbCloseArea())
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHExpSF2   ³ Autor ³ Fabio Garbin        ³ Data ³ 21/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula o consumo do Mes no ano anterior, do mes anterior  ³±±
±±³          | no ano corrente e do mes atual, para cada cliente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PCliente                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XEXPSF2(aCons, cCodCli, cCodLoja)

Local dData      := dDatabase
Local cMes       := StrZero(Month(dData),2,0)
Local cMesAnt    := If(Val(cMes)=1, "12", StrZero(Val(cMes) - 1,2,0))
Local cAno       := Str(Year(dData),4,0)
Local cAnoAnt    := Str(Val(cAno) - 1,4,0)
Local cGrpProd   := "" 
Local nPos       := 0
Local nInt       := 0
Local lQuery     := .F.
Local cVendedor  := HGU->HGU_CODBAS
Local cQueryAtu  := ""
Local cQueryAnt  := ""
Local cQueryAno  := ""
Local cQueryUlt  := ""
Local cAliasSF2  := "SF2"
Local cAliasSD2  := "SD2"
Local cGetDb     := ""
Local aCpoCons   := {}
Local cCpoUser   := ""
Local nX         := 0
Local nI         := 0
Local nTam       := 0
Local nTam2      := 0

DEFAULT cCodCli  := ""
DEFAULT cCodLoja := ""

#IFDEF TOP
	cGetDb   := Upper(TcGetDb())
	lQuery := .T.
    
	aStruSD2 := SD2->(dbStruct())
	
	cAliasATU := "CONS"

	//Verifica se o Indice existe
	If !TcCanOpen(RetSqlName("SD2"), "HHSD2")
		TcSqlExec("CREATE INDEX HHSD2 ON " +  RetSqlName("SD2") + "(D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_EMISSAO, R_E_C_N_O_)")
	EndIf		
	
	If "MSSQL" $ cGetDb
		cQueryAtu := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substring(SD2.D2_EMISSAO, 1, 6) EMISSAO, SUM(SD2.D2_QUANT) QTD "
	    // P.E. Utilizado para complementar dados na tabela de consumo 
		IF ExistBlock("PLMHCN01")
       	   aCpoCons := ExecBlock("PLMHCN01",.F.,.F.)
           For nX := 1 to len(aCpoCons)
  	           cQueryAtu += "," + aCpoCons[nX][2] + Space(1) + aCpoCons[nX][1] 
	       Next
  		Endif
        cQueryAtu += "FROM " + RetSqlName("SD2") + " SD2 (INDEX=HHSD2), " + RetSqlName("SA1") + " SA1 "
		cQueryAtu += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		If !Empty(cCodCli) .And. !Empty(cCodLoja)
			cQueryAtu += "SA1.A1_COD = '" + cCodCli + "' AND SA1.A1_LOJA = '" + cCodLoja + "' AND "
		EndIf
		cQueryAtu += "SA1.A1_VEND = '" + cVendedor + "' AND "
		cQueryAtu += "SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND "
		cQueryAtu += "(SD2.D2_EMISSAO BETWEEN '"  + cAno    + cMes    + "01' AND '" + cAno    + cMes    + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAno    + cMesAnt + "01' AND '" + cAno    + cMesAnt + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAnoAnt + cMes    + "01' AND '" + cAnoAnt + cMes    + "31') AND "
		cQueryAtu += "SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
		cQueryAtu += "GROUP BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substring(SD2.D2_EMISSAO, 1, 6) "
		cQueryAtu += "ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substring(SD2.D2_EMISSAO, 1, 6)"
	ElseIf "ORACLE" $ cGetDb
		cQueryAtu := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substr(SD2.D2_EMISSAO, 1, 6) EMISSAO, SUM(SD2.D2_QUANT) QTD "
		IF ExistBlock("PLMHCN01")
       	   aCpoCons := ExecBlock("PLMHCN01",.F.,.F.)
           For nX := 1 to len(aCpoCons)
  	           cQueryAtu += "," + aCpoCons[nX][2] + Space(1) + aCpoCons[nX][1] 
	       Next
  		Endif
		cQueryAtu += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SA1") + " SA1 "
		cQueryAtu += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQueryAtu += "SA1.A1_VEND = '" + cVendedor + "' AND "
		If !Empty(cCodCli) .And. !Empty(cCodLoja)
			cQueryAtu += "SA1.A1_COD = '" + cCodCli + "' AND SA1.A1_LOJA = '" + cCodLoja + "' AND "
		EndIf
		cQueryAtu += "SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND "
		cQueryAtu += "(SD2.D2_EMISSAO BETWEEN '"  + cAno    + cMes    + "01' AND '" + cAno    + cMes    + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAno    + cMesAnt + "01' AND '" + cAno    + cMesAnt + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAnoAnt + cMes    + "01' AND '" + cAnoAnt + cMes    + "31') AND "
		cQueryAtu += "SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
		cQueryAtu += "GROUP BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substr(SD2.D2_EMISSAO, 1, 6) "
		cQueryAtu += "ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, Substr(SD2.D2_EMISSAO, 1, 6)"	
	Else	
		cQueryAtu := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO EMISSAO, SUM(SD2.D2_QUANT) QTD "
		IF ExistBlock("PLMHCN01")
      	   aCpoCons := ExecBlock("PLMHCN01",.F.,.F.)
           For nX := 1 to len(aCpoCons)
  	           cQueryAtu += "," + aCpoCons[nX][2] + Space(1) + aCpoCons[nX][1] 
	       Next
  		Endif
		cQueryAtu += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SA1") + " SA1 "
		cQueryAtu += "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
		cQueryAtu += "SA1.A1_VEND = '" + cVendedor + "' AND "
		If !Empty(cCodCli) .And. !Empty(cCodLoja)
			cQueryAtu += "SA1.A1_COD = '" + cCodCli + "' AND SA1.A1_LOJA = '" + cCodLoja + "' AND "
		EndIf
		cQueryAtu += "SD2.D2_CLIENTE = SA1.A1_COD AND SD2.D2_LOJA = SA1.A1_LOJA AND "
		cQueryAtu += "(SD2.D2_EMISSAO BETWEEN '"  + cAno    + cMes    + "01' AND '" + cAno    + cMes    + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAno    + cMesAnt + "01' AND '" + cAno    + cMesAnt + "31' OR "
		cQueryAtu += "SD2.D2_EMISSAO BETWEEN '"   + cAnoAnt + cMes    + "01' AND '" + cAnoAnt + cMes    + "31') AND "
		cQueryAtu += "SD2.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
		cQueryAtu += "GROUP BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO "
		cQueryAtu += "ORDER BY SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_EMISSAO"
	EndIf

	// Consumo do Mes Atual	
	cQueryAtu := ChangeQuery(cQueryAtu)

	Memowrite("HHConsumo.txt", cQueryAtu)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryAtu),cAliasAtu,.T.,.T.)
	// Atualiza o Array aCons com os Dados do Consumo do Mes Corrente
	dbSelectArea(cAliasATU)
	While !(cAliasAtu)->(Eof())
        SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + (cAliasATU)->D2_COD))
		cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
		cCliLoj  := (cAliasATU)->D2_CLIENTE + (cAliasATU)->D2_LOJA
		cKey     := cCliLoj + cGrpProd
		If (cAno + cMes) $ (cAliasATU)->EMISSAO //(cAliasATU)->D2_EMISSAO
			nPosData := 7
		ElseIf (cAno + cMesAnt) $ (cAliasATU)->EMISSAO //(cAliasATU)->D2_EMISSAO
			nPosData := 6
		ElseIf (cAnoAnt + cMes) $ (cAliasATU)->EMISSAO //(cAliasATU)->D2_EMISSAO
			nPosData := 5
		EndIf
		nPos := aScan(aCons, { |x| x[1] == cKey })		
		If nPos = 0
		   If nPosData = 5
		 	  aadd(aCons,{cKey, (cAliasATU)->D2_CLIENTE, (cAliasATU)->D2_LOJA, SB1->B1_GRUPO, (cAliasATU)->D2_COD, (cAliasATU)->QTD, 0, 0})
		   ElseIf nPosData = 6
		      aadd(aCons,{cKey, (cAliasATU)->D2_CLIENTE, (cAliasATU)->D2_LOJA, SB1->B1_GRUPO, (cAliasATU)->D2_COD, 0, (cAliasATU)->QTD, 0})
		   ElseIf nPosData = 7
			  aadd(aCons,{cKey, (cAliasATU)->D2_CLIENTE, (cAliasATU)->D2_LOJA, SB1->B1_GRUPO, (cAliasATU)->D2_COD, 0, 0, (cAliasATU)->QTD})
		   EndIf
		   nTam2 := Len(aCons[Len(aCons)])
		   If !Empty(aCpoCons) 
			  nTam  := Len(aCons)
			  For nX := 1 to Len(aCpoCons[1])
			      nTam2 += 1
				  For nI := 1 to nTam
					  aSize(aCons[nTam],nTam2) 
					  cCpoUser :="(cAliasATU)-> "+(aCpoCons[nX][1])
					  aCons[nTam,nTam2] := &cCpoUser
				  Next
 			  Next	 
           EndIf
		Else			
			If ValType(aCons[nPos, nPosData]) != "N"
				aCons[nPos, nPosData] := 0
			EndIf
			aCons[nPos, nPosData] += (cAliasATU)->QTD
		EndIf
		dbSelectArea(cAliasATU)
		dbSkip()
	EndDo
#ELSE
	dbSelectArea("SF2")
	dbSetOrder(2)
	dbSeek(xFilial("SF2") + cCodCli + cCodLoja)
	While !Eof() .And. SF2->F2_CLIENTE = cCodCli .And. SF2->F2_LOJA = cCodLoja
		If DtoS(SF2->F2_EMISSAO) >= cAnoAnt + cMesAnt + "01" .And.;  // Mes do Ano Anterior
		   DtoS(SF2->F2_EMISSAO) <= cAnoAnt + cMesAnt + "31"
		   nInt := 2
		EndIf
		If DtoS(SF2->F2_EMISSAO) >= cAno + cMesAnt + "01" .And.;  // Mes Anterior
		   DtoS(SF2->F2_EMISSAO) <= cAno + cMesAnt + "31"
		   nInt := 3
		EndIf
		If DtoS(SF2->F2_EMISSAO) >= cAno + cMes + "01" .And.;  // Mes Atual
		   DtoS(SF2->F2_EMISSAO) <= DtoS(dData)
		   nInt := 4
		EndIf
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE)
		While !SD2->(Eof()) .And. SD2->D2_DOC == SF2->F2_DOC .And. nInt <> 0
	        SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
			cCliLoj  := cCodCli + cCodLoja
			cGrpProd := SB1->B1_GRUPO + SB1->B1_COD
			nPos := aScan(aCons, { |x| x[1] == cGrpProd })
			If nPos = 0
				aadd(aCons,{cGrpProd, 0, 0, 0, SD2->D2_QUANT, SD2->D2_EMISSAO, SD2->D2_TOTAL, cCliLoj})
				nPos := aScan(aCons, { |x| x[1] == cGrpProd })
			EndIf
			aCons[nPos,nInt] += SD2->D2_QUANT
			// Verifica a Ultima Compra deste Produto
			If SD2->D2_EMISSAO > aCons[nPos,6]
				aCons[nPos,5] := SD2->D2_QUANT
				aCons[nPos,6] := SD2->D2_EMISSAO
				aCons[nPos,7] := SD2->D2_TOTAL
			EndIf
			dbSelectArea("SD2")	
			dbSkip()
		EndDo
		nInt := 0
		dbSelectArea("SF2")	
		dbSkip()
	EndDo

#ENDIF

If lQuery
	(cAliasATU)->(dbCloseArea())
//	(cAliasANT)->(dbCloseArea())	
//	(cAliasANO)->(dbCloseArea())	
EndIf

//Return aCons
Return


User Function XEXPSB1()
Local aDa0        := {}
Local nX          := 1
Local nPos        := 0
Local nSaldo      := 0  // Estoque do Produto em todos os Almoxarifados
Local lOkPrd      := .T. // Retorno do Ponto de Entrada
Local lQuery      := .F.
Local cTipProd    := GetMv("MV_PLMTPPR",,"PA")
Local cLocalEst   := GetMv("MV_PLLCEST",,"T")   // T = Todos os Almoxarifados, P = Local Padrao
Local cGeraTab    := GetMv("MV_PLPRECO",,"T")
Local cId         := ""
Local cIntr       := "I"
Private cAliasSB1 := "SB1"

#IFDEF TOP
	lQuery     := .T.

	aStruSB1   := SB1->(dbStruct())
	cAliasSB1  := "PROD"

	cTpProduto := cTipProd
	
	cLista     := "'"
	cTpProduto := AllTrim(cTipProd) + ","
	nPos       := At(",", cTpProduto)
	While nPos > 0
		cLista   += Substr(cTpProduto, 1, nPos - 1) + "','"
		cTpProduto := Substr(cTpProduto, nPos + 1, Len(cTpProduto))
		nPos := At(",", cTpProduto)
	End
    cLista := Subs(cLista, 1, Len(cLista)-2)
    
	// Query para o Arquivo de Produtos
	cQuerySB1 := "SELECT * "
	cQuerySB1 += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuerySB1 += "WHERE SB1.B1_FILIAL='" + xFilial("SB1") + "' AND "
	cQuerySB1 += "SB1.B1_TIPO IN (" + cLista + ") AND "

	If SB1->(FieldPos("B1_MSBLQL")) > 0
		cQuerySB1 += "SB1.B1_MSBLQL <> '1' AND "
	EndIf
	
	cQuerySB1 += "SB1.D_E_L_E_T_ = ' ' "

	// Ponto de Entrada deve retornar um complemento para a Query
	If ((ExistBlock("PLMPRD01")))
		cQuerySB1 += ExecBlock("PLMPRD01",.F.,.F.)
	EndIf

	cQuerySB1 += "ORDER BY " + SqlOrder(SB1->(IndexKey()))
	
	cQuerySB1 := ChangeQuery(cQuerySB1)

	Memowrite("HHProd.txt", cQuerySB1)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySB1),cAliasSB1,.T.,.T.)
	cId := HHCheckID("HB1")

	For nX := 1 To Len(aStruSB1)
		If aStruSB1[nX][2]<>"C" .And. (cAliasSB1)->(FieldPos(aStruSB1[nX][1])>0)
			TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
	    EndIf
	Next nX

	// Grupo
	cAliasGrp := "HHGRP"

	cQuery := "SELECT DISTINCT '" + xFilial("SBM") + "' HBM_FILIAL, '" + cId + "'  HBM_ID, SBM.BM_GRUPO HBM_GRUPO, SBM.BM_DESC HBM_DESC, 'I' HBM_INTR, 1 HBM_VER "
	cQuery += "FROM " + RetSqlName("SB1") + " SB1 , " + RetSqlName("SBM") + " SBM "
	cQuery += "WHERE SB1.B1_FILIAL='" + xFilial("SB1") + "' AND "
	cQuery += "SB1.B1_GRUPO = SBM.BM_GRUPO AND "
	cQuery += "SB1.B1_TIPO IN (" + cLista + ") AND "
	cQuery += "SB1.D_E_L_E_T_ = ' ' AND SBM.D_E_L_E_T_ = ' ' "
	
	If ((ExistBlock("PLMPRD01")))
		cQuery += ExecBlock("PLMPRD01",.F.,.F.)
	EndIf
	
	cQuery += "ORDER BY SBM.BM_GRUPO"

	Memowrite("HHGrupo.txt", cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGrp,.T.,.T.)
	                      
	aStru  := (cAliasGrp)->(dbStruct())
	
	For nX := 1 To Len(aStru)
		If aStru[nX,2]<>"C" .And. (cAliasGrp)->(FieldPos(aStru[nX,1])>0)
			TcSetField(cAliasGrp,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
	    EndIf
	Next nX

	dbSelectArea(cAliasGrp)
	dbGoTop()
	While !(cAliasGrp)->(Eof())
		dbSelectArea("HBM")
		dbSetOrder(1)		
		If !dbSeek((cAliasGrp)->HBM_FILIAL + (cAliasGrp)->HBM_ID + (cAliasGrp)->HBM_GRUPO)
			RecLock("HBM", .T.)
		Else
			RecLock("HBM", .F.)
		Endif
		HBM->HBM_FILIAL := (cAliasGrp)->HBM_FILIAL
		HBM->HBM_ID := (cAliasGrp)->HBM_ID
		HBM->HBM_GRUPO := (cAliasGrp)->HBM_GRUPO
		HBM->HBM_DESC := (cAliasGrp)->HBM_DESC
		HBM->HBM_INTR := (cAliasGrp)->HBM_INTR
		HBM->HBM_VER := (cAliasGrp)->HBM_VER
		(cAliasGrp)->(dbSkip())
	EndDo
	//Append From (cAliasGrp)	
	(cAliasGrp)->(dbCloseArea())
#ELSE
	// Grava Arquivo Temporario
	dbSelectArea(cAliasSB1)
	cFiltro := "B1_TIPO $ '" + cTipProd + "'"
	// Ponto de Entrada deve retornar um complemento para o Filtro
	If ((ExistBlock("PLMPRD01")))
		cFiltro += ExecBlock("PLMPRD01",.F.,.F.)
	EndIf

	Set Filter to &cFiltro
	dbSeek(xFilial("SB1"))
	cId := HHCheckID("HB1")
#ENDIF

While !(cAliasSB1)->(Eof()) .And. (cAliasSB1)->B1_FILIAL == xFilial("SB1")
	// Ponto de Entrada PLMPRD02 - Indica se um Produto sera exportado, retorno deve ser .T. ou .F.
	If ((ExistBlock("PLMPRD02")))
		lOkPrd := ExecBlock("PLMPRD02",.F.,.F.)
		If !lOkPrd
			dbSelectArea(cAliasSB1)
		    dbSkip()
		    Loop
		 EndIf
	EndIf
	If Alltrim((cAliasSB1)->B1_TIPO) $ Alltrim(cTipProd)
		// Verifica se o Saldo sera do Local Padrao ou de Todos os os Locais
		nSaldo := 0
		dbSelectArea("SB2")
		dbSetOrder(1)
		If cLocalEst = "T"
			dbSeek(xFilial("SB2")+(cAliasSB1)->B1_COD)
			While SB2->B2_COD = (cAliasSB1)->B1_COD
				nSaldo += SaldoSB2()
				dbSkip()
			EndDo
		Else
			If dbSeek(xFilial("SB2")+(cAliasSB1)->B1_COD+(cAliasSB1)->B1_LOCPAD)
				nSaldo := SaldoSB2()
			EndIf
		EndIf			
		/*	
		// Verifica se grava o Valor do estoque
		If cValEst = "T"
			cEst := AllTrim(Str(nSaldo,14,2) + " em " + DtoC(dDatabase))
		Else
			If nSaldo > 0
				cEst := "Disponivel"
			Else
				cEst := "Sem Estoque"
			EndIf
		EndIf 
		*/
		dbSelectArea("HB1")
		dbSetOrder(1)
		If !dbSeek(xFilial("SB1") + cId + (cAliasSB1)->B1_COD)
			RecLock("HB1", .T.)
		Else
			RecLock("HB1", .F.)
		EndIf
		HB1->HB1_FILIAL := xFilial("SB1")
		HB1->HB1_ID := cId
		HB1->HB1_GRUPO  := (cAliasSB1)->B1_GRUPO
		HB1->HB1_COD    := (cAliasSB1)->B1_COD
		HB1->HB1_DESC   := (cAliasSB1)->B1_DESC
		HB1->HB1_UM     := (cAliasSB1)->B1_UM
		HB1->HB1_PICM   := (cAliasSB1)->B1_PICM
		HB1->HB1_IPI    := (cAliasSB1)->B1_IPI
		HB1->HB1_ALQISS := (cAliasSB1)->B1_ALIQISS
		HB1->HB1_QE     := (cAliasSB1)->B1_QE
		HB1->HB1_COMIS  := (cAliasSB1)->B1_COMIS
		HB1->HB1_CODBAR := (cAliasSB1)->B1_CODBAR
		HB1->HB1_LOCPAD := (cAliasSB1)->B1_LOCPAD
		//HB1->HB1_EST    := cEst
		HB1->HB1_TS     := (cAliasSB1)->B1_TS
		HB1->HB1_PRV1   := (cAliasSB1)->B1_PRV1
		HB1->HB1_DESMAX := If((cAliasSB1)->(FieldPos("B1_DESCMAX")) > 0, (cAliasSB1)->B1_DESCMAX, 0)
		HB1->HB1_SEGUM := (cAliasSB1)->B1_SEGUM
		HB1->HB1_PBRUTO := (cAliasSB1)->B1_PESBRU
		HB1->HB1_TIPCON := (cAliasSB1)->B1_TIPCONV
		HB1->HB1_CONV := (cAliasSB1)->B1_CONV
		HB1->HB1_INTR   := cIntr
		HB1->HB1_VER    := 1
		HB1->(MsUnlock())

		dbSelectArea("HB2")
		dbSetOrder(1)
		If !dbSeek(xFilial("SB2") + cId + (cAliasSB1)->B1_COD)
			RecLock("HB2", .T.)
		Else
			RecLock("HB2", .F.)
		EndIf
		HB2->HB2_FILIAL := xFilial("SB2")
		HB2->HB2_ID := cId
		HB2->HB2_COD :=  (cAliasSB1)->B1_COD
		HB2->HB2_LOCAL := If(cLocalEst = "T", "",  (cAliasSB1)->B1_LOCPAD)
		HB2->HB2_DATA := Date()
		HB2->HB2_QTD := nSaldo
		HB2->HB2_VER := 1
		HB2->HB2_INTR := cIntr
		HB2->(MsUnlock())
	EndIf
	(cAliasSB1)->(dbSkip())
EndDo                

// Gera Tabela de Preco (TOP)
If  cGeraTab = "T"
	U_XExpDA0(cAliasSB1, @aDa0)
EndIf

If lQuery
	(cAliasSB1)->(dbCloseArea())
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HHExpDA0  º Autor ³ Fabio Garbin       º Data ³  10/04/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao o arquivo de tabelas de precos                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PProduto                                                   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ M.Vieira   ³11.11.01³ Substituicao de macros pela funcao FieldPut()   ³±±
±±|            |        | FieldGet() para ficar mais rapida gravacao      ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XEXPDA0(cSB1Alias, aDa0)
#IFDEF TOP    
	Local nX        := 1
	Local cColunas  := 0
	Local cDA0Alias := ""
	Local cTabAlias := ""
	Local cQuery    := ""
	Local cLista    := ""
	Local cID       := ""
	Local cGetDb    := ""
	Local cTipProd  := GetMv("MV_PLMTPPR",,"PA")
	Local lOkTab    := .T.
	cGetDb    := Upper(TcGetDb())
	cTabAlias := "HHTABPRC"

	cLista   := "'"
	cTipProd := AllTrim(cTipProd) + ","
	nPos     := At(",", cTipProd)
	While nPos > 0
		cLista   += Substr(cTipProd, 1, nPos - 1) + "','"
		cTipProd := Substr(cTipProd, nPos + 1, Len(cTipProd))
		nPos := At(",", cTipProd)
	End
    cLista := Subs(cLista, 1, Len(cLista)-2)

	cID := HHCheckID("HPR")

	cColunas := "'" + xFilial("DA1") + "' HPR_FILIAL, '" + cID + "' HPR_ID ,SB1.B1_GRUPO HPR_GRUPO, DA1.DA1_CODPRO HPR_PROD, DA1.DA1_CODTAB HPR_TAB, DA1.DA1_PRCVEN HPR_UNI"

	If DA1->(FieldPos("DA1_DESMAX")) > 0
		cColunas += ", DA1.DA1_DESMAX HPR_DESMAX "
	EndIf
	
	cColunas += ", 'I' HPR_INTR, 1 HPR_VER "

	cQuery := "SELECT " + cColunas
	cQuery += "FROM " + RetSqlName("DA0") + " DA0, " + RetSqlName("DA1") + " DA1, " + RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE DA1_CODPRO = SB1.B1_COD "
	cQuery += "AND DA0.DA0_CODTAB = DA1.DA1_CODTAB "
	cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_TIPO IN(" + cLista + ") "

	If SB1->(FieldPos("B1_MSBLQL")) > 0
		cQuery += "AND SB1.B1_MSBLQL <> '1' "
	EndIf

	cQuery += "AND DA0.DA0_FILIAL = '" + xFilial("DA0") + "' "	
	cQuery += "AND (DA0.DA0_DATATE = '' OR DA0.DA0_DATATE > '" + DtoS(dDataBase) + "') "
	cQuery += "AND DA0.DA0_ATIVO = '1' "
	cQuery += "AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "
	cQuery += "AND DA1.DA1_ATIVO = '1' "
	cQuery += "AND DA0.D_E_L_E_T_ <> '*' " 
	cQuery += "AND DA1.D_E_L_E_T_ <> '*' "
	cQuery += "AND SB1.D_E_L_E_T_ <> '*' "
           
	If ((ExistBlock("HANHPR01")))
		cQuery += ExecBlock("HANHPR01",.F.,.F.)
	EndIf

	cQuery := ChangeQuery(cQuery)

	Memowrite("HHTabPrc.txt", cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabAlias,.T.,.T.)

	cID := HHCheckID("HTC")

	aStru  := (cTabAlias)->(dbStruct())
	
	For nX := 1 To Len(aStru)
		If aStru[nX,2]<>"C" .And. (cTabAlias)->(FieldPos(aStru[nX,1])>0)
			TcSetField(cTabAlias,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
	    EndIf
	Next nX

	dbSelectArea(cTabAlias)
	dbGoTop()
	While !(cTabAlias)->(Eof())
		If ((ExistBlock("HANHPR02")))
			lOkTab := ExecBlock("HANHPR02",.F.,.F.)
			If !lOkTab
				dbSelectArea(cTabAlias)
			    dbSkip()
			    Loop
			 EndIf
		EndIf

		dbSelectArea("HPR")
		dbSetOrder(1)
		If !dbSeek((cTabAlias)->HPR_FILIAL + (cTabAlias)->HPR_ID + (cTabAlias)->HPR_PROD + (cTabAlias)->HPR_TAB)
			RecLock("HPR", .T.)
		Else
			RecLock("HPR", .F.)
		EndIf
		HPR->HPR_FILIAL := (cTabAlias)->HPR_FILIAL
		HPR->HPR_ID := (cTabAlias)->HPR_ID
		HPR->HPR_GRUPO := (cTabAlias)->HPR_GRUPO
		HPR->HPR_PROD := (cTabAlias)->HPR_PROD
		HPR->HPR_TAB := (cTabAlias)->HPR_TAB
		HPR->HPR_UNI := (cTabAlias)->HPR_UNI

		If DA1->(FieldPos("DA1_DESMAX")) > 0
			HPR->HPR_DESMAX := (cTabAlias)->HPR_DESMAX
		EndIf
	
		HPR->HPR_INTR := (cTabAlias)->HPR_INTR
		HPR->HPR_VER := (cTabAlias)->HPR_VER
		HPR->(MsUnlock())
		(cTabAlias)->(dbSkip())
	EndDo

	
	//Append From (cTabAlias)
	(cTabAlias)->(DbCloseArea())

	// Cabecao da Tabela de Preco  
	cDA0Alias := "HHTABC"
	cQueryDA0 := "SELECT '" + xFilial("DA0") + "' HTC_FILIAL, '" + cID + "' HTC_ID , DA0.DA0_CODTAB HTC_TAB, DA0.DA0_DESCRI HTC_DESCRI, DA0.DA0_CONDPG HTC_COND, 'I' HTC_INTR, 1 HTC_VER "
	cQueryDA0 += "FROM " +  RetSqlName("DA0") + " DA0 "
	cQueryDA0 += "WHERE DA0.DA0_FILIAL = '" + xFilial("DA0") + "' "	
	cQueryDA0 += "AND (DA0.DA0_DATATE = '' OR DA0.DA0_DATATE > '" + DtoS(dDataBase) + "') "
	cQueryDA0 += "AND DA0.DA0_ATIVO = '1' "
	cQueryDA0 += "AND DA0.D_E_L_E_T_ <> '*' "	

	If ((ExistBlock("HANHTC01")))
		cQueryDA0 += ExecBlock("HANHTC01",.F.,.F.)
	EndIf
	
	cQueryDA0 := ChangeQuery(cQueryDA0)
	
	Memowrite("HHTab.txt", cQueryDA0)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDA0),cDA0Alias, .T., .T.)

	dbSelectArea(cDA0Alias)
	dbGoTop()
	While !(cDA0Alias)->(Eof())
		dbSelectArea("HTC")
		dbSetOrder(1)
		If !dbSeek((cDA0Alias)->HTC_FILIAL + (cDA0Alias)->HTC_ID + (cDA0Alias)->HTC_TAB)
			RecLock("HTC", .T.)
		Else
			RecLock("HTC", .F.)
		EndIf
		HTC->HTC_FILIAL := (cDA0Alias)->HTC_FILIAL
		HTC->HTC_ID := (cDA0Alias)->HTC_ID
		HTC->HTC_TAB := (cDA0Alias)->HTC_TAB
		HTC->HTC_DESCRI := (cDA0Alias)->HTC_DESCRI
		HTC->HTC_COND := (cDA0Alias)->HTC_COND
		HTC->HTC_INTR := (cDA0Alias)->HTC_INTR
		HTC->HTC_VER := (cDA0Alias)->HTC_VER
		HTC->(MsUnlock())
		(cDA0Alias)->(dbSkip())
	EndDo
	//Append From (cDA0Alias)
	(cDA0Alias)->(DbCloseArea())
/*	
#ELSE
	dbSelectArea("DA1")
	dbSetOrder(2)
	If dbSeek(xFilial("DA1")+(cSB1Alias)->B1_COD)
		While !DA1->(Eof()) .And. DA1->DA1_CODPRO = (cSB1Alias)->B1_COD
			If DA1->DA1_ATIVO != "1"
				DA1->(dbSkip())
				Loop
			EndIf
			dbSelectArea("DA0")
			dbSetOrder(1)
			If dbSeek(xFilial("DA0")+DA1->DA1_CODTAB)
				If DA0->DA0_ATIVO != "1" .Or. (!Empty(DA0->DA0_DATATE) .And. DA0->DA0_DATATE < dDatabase)
					DA1->(dbSkip())
					Loop
				EndIf
			EndIf
			
			nDa0 := aScan( aDa0, {|x| x[1]==DA0->DA0_CODTAB} ) 
			If nDa0 == 0
				Aadd( aDA0, { DA0->DA0_CODTAB, DA0->DA0_DESCRI, DA0->DA0_CONDPG  } )
			EndIf
			If !dbSeek()
				RecLock("HPR", .T.)
			Else
				RecLock("HPR", .F.)
			EndIf
			HPR->HPR_GRUPO := (cSB1Alias)->B1_GRUPO
			HPR->HPR_PROD  := AllTrim(DA1->DA1_CODPRO)
			HPR->HPR_TAB   := DA1->DA1_CODTAB
			HPR->HPR_UNI   := DA1->DA1_PRCVEN
			HPR->HPR_INTR := cIntr
			HPR->HPR_VER := 1
			HPR->(MsUnlock())		
			dbSelectArea("DA1")
			dbSkip()
		EndDo
	EndIf*/
#ENDIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  HHExpSE4 º Autor ³Fabio Garbin        º Data ³  30/11/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao o arquivo de condicoes de pagamento/TES/Tipo de    º±±
±±º          ³ Movimentacao.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao Palm                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XEXPSE4()
Local cTabela     := ""
Local lOkCnd      := .T. // Retorno do Ponto de Entrada - PLMCND01
Local lOkTes      := .T. // Retorno do Ponto de Entrada - PLMTES01
Local cIntr := "I"
Local cId := ""
// Grava Arquivo Temporario de Condi‡oes
dbSelectArea("SE4")
dbSetOrder(1)
dbSeek(xFilial("SE4"))
cId := HHCheckID("HE4")
While !SE4->(Eof()) .and. SE4->E4_FILIAL == xFilial("SE4")

	// Ponto de Entrada PLMCND01 - Indica se um Condicao sera exportado, retorno deve ser .T. ou .F.
	If ((ExistBlock("PLMCND01")))
		lOkCnd := ExecBlock("PLMCND01",.F.,.F.)
		If !lOkCnd
			dbSelectArea("SE4")
		    dbSkip()
		    Loop
		 EndIf
	EndIf

	dbSelectArea("HE4")
	dbSetOrder(1)
	If !dbSeek(xFilial("SE4") + cId + SE4->E4_CODIGO)
		RecLock("HE4", .T.)
	Else
		RecLock("HE4", .F.)
	EndIf
	HE4->HE4_FILIAL := xFilial("SE4")
	HE4->HE4_ID := cId
	HE4->HE4_CODIGO := SE4->E4_CODIGO
	HE4->HE4_DESCRI := SE4->E4_DESCRI
	HE4->HE4_INTR   := cIntr
	HE4->HE4_VER    := 1
	HE4->(MsUnlock())
	SE4->(dbSkip())
EndDo

// Grava arquivo Temporario de TES
cId := HHCheckID("HF4")
dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial()+"501",.T.) // Apenas TES de Saida
While SF4->(!Eof()) .and. SF4->F4_FILIAL == xFilial("SF4") .and. SF4->F4_TIPO="S"

	// Ponto de Entrada PLMCND01 - Indica se um Condicao sera exportado, retorno deve ser .T. ou .F.
	If ((ExistBlock("PLMTES01")))
		lOkTes := ExecBlock("PLMTES01",.F.,.F.)
		If !lOkTes
			dbSelectArea("SF4")
		    dbSkip()
		    Loop
		 EndIf
	EndIf
	
	dbSelectArea("HF4")
	dbSetOrder(1)
	If !dbSeek(xFilial("SF4") + cId + SF4->F4_CODIGO)
		RecLock("HF4", .T.)
	Else
		RecLock("HF4", .F.)
	EndIf
	HF4->HF4_FILIAL := xFilial("SF4")
	HF4->HF4_ID := cId
	HF4->HF4_CODIGO := SF4->F4_CODIGO
	HF4->HF4_TEXTO  := SF4->F4_TEXTO
  	HF4->HF4_INTR   := cIntr
	HF4->HF4_VER    := 1
	HF4->(MsUnlock())
  	SF4->(dbSkip())
EndDo

cId := HHCheckID("HTP")
cTabela := "24"  // Tabela Formas de Pagamento
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5") + cTabela)
While SX5->(!Eof()) .And. SX5->X5_FILIAL = xFilial() .And. SX5->X5_TABELA = cTabela
  	dbSelectArea("HTP")
	dbSetOrder(1)
	If !dbSeek(xFilial("SX5") + cId + SX5->X5_CHAVE)
		RecLock("HTP", .T.)
	Else
		RecLock("HTP", .F.)
	EndIf  	
	HTP->HTP_FILIAL := xFilial("SX5")
	HTP->HTP_ID := cId
	HTP->HTP_CHAVE  := SX5->X5_CHAVE
	HTP->HTP_DESCRI := SX5->X5_DESCRI
	HTP->HTP_INTR   := cIntr
	HTP->HTP_VER    := 1
	HTP->(MsUnlock())
	dbSelectArea("SX5")
	dbSkip()
EndDo

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | HHExpSC5 º Autor ³Fabio Garbin        º Data ³  30/11/2000 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao o arquivo de pedidos                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao Palm                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XEXPSC5()
Local aPedidoC    := {} // Contem os dados do arquivo de PEDIDOS (cabe‡alho)
Local aPedidoI    := {} // Contem os dados do arquivo de PEDIDOS (itens)
Local aClienteP   := {} // Contem os dados do arquivo de CLIENTEP (cliente X pedido)
Local aStatus     := {}
Local aNpos       := {}
Local aInd        := {}
Local aStrus      := {}
Local cCodCli     := ""
Local cCodPed     := ""
Local j           := 1
Local ni          := 1
Local i          := 1
Local nX := 1
Local cMvcpolvr   := GetMv("MV_CPOLVR")
Local cVendedor   := HGU->HGU_CODBAS
Local aQtdPed     := {}
Local nQtdPed     := GetMv("MV_QTPEDPM",,1)  // Quantidade de Pedidos a serem enviados para o Palm
Local nValPed     := 0
Local nValFat     := 0
Local cStatus     := ""
Local cAliasPed   := ""
Local cQuery      := ""
Local cId := ""
Local cGetDb      := ""
Local cIntr := "I"

// Identifica Ultimos Pedidos do Cliente
dbSelectArea("SA1")
cFiltro := "SA1->A1_VEND = '" + cVendedor + "'"
Set Filter to &cFiltro
dbSeek(xFilial(), .T.)
cId := HHCheckID("HA1", "SA1")
While !SA1->(Eof()) .And. SA1->A1_FILIAL == xFilial() .And. nQtdPed > 0
	cCodCli  := SA1->A1_COD
	cCodLoja := SA1->A1_LOJA

	#IFDEF TOP
		cGetDb   := Upper(TcGetDb())

		cAliasPed := "HHSC5"	

		If cGetDb $ "MSSQL"
			cQuery := "SELECT TOP " + Str(nQtdPed,2,0) + " SC5.C5_NUM "
		Else
			cQuery := "SELECT SC5.C5_NUM "
	    EndIf

		cQuery += "FROM " + RetSqlName("SC5") + " SC5 WHERE "

		If cGetDb $ "ORACLE"
			cQuery += "Rownum <=" + Str(nQtdPed,2,0) + " AND "
		EndIf

		cQuery += "SC5.C5_FILIAL ='" + xFilial("SC5") + "' AND "
		cQuery += "SC5.C5_CLIENTE ='" + cCodCli +  "' AND "
		cQuery += "SC5.C5_LOJACLI ='" + cCodLoja + "' AND "
		cQuery += "SC5.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_EMISSAO DESC"

		Memowrite("HHPed.txt", cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPed,.T.,.T.)

		aStru  := (cAliasPed)->(dbStruct())
		
		For nX := 1 To Len(aStru)
			If aStru[nX,2]<>"C" .And. (cAliasPed)->(FieldPos(aStru[nX,1])>0)
				TcSetField(cAliasPed,aStru[nX,1],aStru[nX,2],aStru[nX,3],aStru[nX,4])
		    EndIf
		Next nX

		ni := 1
		dbSelectArea(cAliasPed)
		dbGoTop()
		While !(cAliasPed)->(Eof()) .And. ni <= nQtdPed
			aadd(aQtdPed,(cAliasPed)->C5_NUM)	 
			(cAliasPed)->(dbSkip())
			ni += 1
		EndDo
		(cAliasPed)->(dbCloseArea())
	#ELSE
		// Busca os Ultimos pedidos do cliente
		dbSelectArea("SC5")
		dbSetOrder(3)
	    If dbSeek(xFilial("SC5") + cCodCli)
			// Necessario para buscar pedidos de outras lojas, pois o indice nao contem o campo LOJA
			While !SC5->(Eof()) .And. SC5->C5_LOJACLI <> cCodLoja .and. SC5->C5_VEND1 <> cVendedor 
				SC5->(dbSkip())
			EndDo
			// Separa todos os ultimos pedidos do cliente
			While !SC5->(Eof()) .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_CLIENTE = cCodCli
				If SC5->C5_LOJACLI = cCodLoja
					If Len(aQtdPed) >= nQtdPed
						aDel(aQtdPed,1)
						aSize(aQtdPed,Len(aQtdPed)-1)
					EndIf		
					aadd(aQtdPed,SC5->C5_NUM)
				EndIf
				dbSelectArea("SC5")		
				dbSkip()
			EndDo
	    EndIf
	#ENDIF

	// Grava os Ultimos Pedidos    
	dbSelectArea("SC5")
	dbGoTop()
	While !SC5->(Eof()) .And. j <= Len(aQtdPed)
		dbSelectArea("SC5")
		dbSetOrder(1)	
		If dbSeek(xFilial("SC5") + aQtdPed[j])
			
			// Verifica Status do Pedido e valor total //
			nQtdItem := 0
			nValPed := 0
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+SC5->C5_NUM)
			While !SC6->(Eof()) .AND. SC6->C6_NUM = SC5->C5_NUM
				If SC6->C6_QTDENT = SC6->C6_QTDVEN
					nPos := aScan(aStatus,{|x| x[1] = "E"})
					If(nPos = 0, aadd(aStatus, {"E", 1}), aStatus[nPos,2] += 1)
				ElseIf SC6->C6_QTDENT != 0 .And. SC6->C6_QTDENT < SC6->C6_QTDVEN
					nPos := aScan(aStatus,{|x| x[1] = "PE"})
					If(nPos = 0, aadd(aStatus, {"PE", 1}), aStatus[nPos,2] += 1)
				Else
			   		dbSelectArea("SC9")
				   	dbSetOrder(1)
			   		If dbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM)
							If Empty(C9_BLCRED) .And. Empty(C9_BLEST) //Item Liberado
								nPos := aScan(aStatus,{|x| x[1] = "L"})
								If(nPos = 0, aadd(aStatus, {"L", 1}), aStatus[nPos,2] += 1)					
							ElseIf(!Empty(C9_BLCRED) .And. C9_BLCRED != "10") .And. (!Empty(C9_BLEST) .And. C9_BLEST != "10") //Bloqueado por Estoque e Credito
								nPos := aScan(aStatus,{|x| x[1] = "B"})
								If(nPos = 0, aadd(aStatus, {"B", 1}), aStatus[nPos,2] += 1)
							ElseIf !Empty(C9_BLCRED) .And. C9_BLCRED != "10"  //Bloqueado por Credito
								nPos := aScan(aStatus,{|x| x[1] = "BC"})
								If(nPos = 0, aadd(aStatus, {"BC", 1}), aStatus[nPos,2] += 1)
							ElseIf !Empty(C9_BLEST) .And. C9_BLEST != "10"    //Bloqueado por Estoque
								nPos := aScan(aStatus,{|x| x[1] = "BE"})
								If(nPos = 0, aadd(aStatus, {"BE", 1}), aStatus[nPos,2] += 1)
							EndIf
						Else
			   			If SC6->C6_BLQ = "R"
								nPos := aScan(aStatus,{|x| x[1] = "R"})
								If(nPos = 0, aadd(aStatus, {"R", 1}), aStatus[nPos,2] += 1)
			   			Else
								nPos := aScan(aStatus,{|x| x[1] = "A"})
								If(nPos = 0, aadd(aStatus, {"A", 1}), aStatus[nPos,2] += 1)
			   			EndIf
						Endif
			   	EndIf
					nValPed += SC6->C6_VALOR
					nQtdItem++
			   	dbSelectArea("SC6")
			   	dbSkip()
			EndDo

			// Ordena Array de Status pela quantidade
			aStatus := aSort(aStatus,,,{|x, y| x[2] > y[2]})          	
			            	         	
			If Len(aStatus) > 0
				If Len(aStatus) = 1
					cStatus := aStatus[1,1]
				Else
					If Left(aStatus[1,1],1) != "P"
						cStatus := "P" + aStatus[1,1]
					Else
						cStatus := aStatus[1,1]
					EndIf
				EndIf            	
			EndIf

			// Posiciona NF caso exista
			If !Empty(SC5->C5_NOTA)
				dbSelectArea("SF2")
				dbSetOrder(1)
				dbSeek(xFilial("SF2")+SC5->C5_NOTA)
			
				// Calcula Valor Faturado do Pedido
				nValFat := 0
				dbSelectArea("SD2")
				dbSetOrder(8)
				dbSeek(xFilial("SD2")+SC5->C5_NUM)
				While !Eof() .And. xFilial() = xFilial("SD2") .And. SD2->D2_PEDIDO = SC5->C5_NUM
					nValFat += SD2->D2_TOTAL
					SD2->(dbSkip())
				EndDo
			EndIf

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)

			// Gravação do Registro //
		  	dbSelectArea("HC5")
			dbSetOrder(1)
			If !dbSeek(xFilial("SC5") + cId + SC5->C5_NUM)
				RecLock("HC5", .T.)
			Else
				RecLock("HC5", .F.)
			EndIf
			HC5->HC5_FILIAL := xFilial("SC5")
			HC5->HC5_ID := cId
			HC5->HC5_COTAC  := If(!Empty(SC5->C5_COTACAO),SC5->C5_COTACAO,SC5->C5_NUM)
			HC5->HC5_CLI    := SC5->C5_CLIENTE
			HC5->HC5_LOJA   := SC5->C5_LOJACLI
			HC5->HC5_TRANSP := SC5->C5_TRANSP
			HC5->HC5_TIPO   := SC5->C5_TIPO
			HC5->HC5_COND   := SC5->C5_CONDPAG
			HC5->HC5_VEND1  := SC5->C5_VEND1
			HC5->HC5_MENOTA := SC5->C5_MENNOTA
			HC5->HC5_EMISS  := SC5->C5_EMISSAO
			HC5->HC5_TAB    := SC5->C5_TABELA
			HC5->HC5_STATUS := cStatus
			HC5->HC5_TIPOCL := SC5->C5_TIPOCLI
			HC5->HC5_ASSINA := ""
			HC5->HC5_TPPAG  := ""
			HC5->HC5_TPFRET := SC5->C5_TPFRETE
			HC5->HC5_NOTA   := SC5->C5_NOTA
			HC5->HC5_SERIE  := SC5->C5_SERIE
			HC5->HC5_NUM    := SC5->C5_NUM
			HC5->HC5_DUPLI  := SF2->F2_DUPL
			HC5->HC5_VALOR  := nValPed
			HC5->HC5_FAT    := nValFat
			HC5->HC5_DTPED  := SF2->F2_EMISSAO
			HC5->HC5_QTDITE := nQtdItem
			HC5->HC5_DESCON := 0
			HC5->HC5_FORMPG := If(SC5->(FieldPos("C5_FORMAPG")) <> 0, SC5->C5_FORMAPG, "")
			HC5->HC5_VER   := 1
			HC5->HC5_INTR   := cIntr
			HC5->(MsUnlock())

   		// Busca os Itens do pedido
			cCodPed := SC5->C5_NUM
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6") + cCodPed , .T.)
			While !Eof() .and. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cCodPed
				dbSelectArea("HC6")
				dbSetOrder(1)

				// Verifica Status do Item
				If SC6->C6_QTDENT = 0
					dbSelectArea("SC9")
					dbSetOrder(1)
					If dbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM, .F.)
						If Empty(C9_BLCRED) .And. Empty(C9_BLEST) //Liberado
							cStatus := "L"
						ElseIf (!Empty(C9_BLCRED) .And. C9_BLCRED <> "10") .And. (!Empty(C9_BLEST) .And. C9_BLEST <> "10") //Bloqueado por Estoque e Credito
					   	cStatus := "B"
					  	ElseIf !Empty(C9_BLCRED) .And. C9_BLCRED <> "10"  //Bloqueado por Credito
					  		cStatus := "BC"
					  	ElseIf !Empty(C9_BLEST) .And. C9_BLEST <> "10" //Bloqueado por Estoque
					  		cStatus := "BE"
				   	EndIf
					Else
						If SC6->C6_BLQ = "R"
							cStatus := "R"
				   	Else
				   		cStatus := "A"
				   	EndIf
				   EndIf		            	
				ElseIf SC6->C6_QTDENT < SC6->C6_QTDVEN
					cStatus := "PE"
				ElseIf SC6->C6_QTDENT = SC6->C6_QTDVEN
					cStatus := "E"
				EndIf

			  	dbSelectArea("HC6")
				dbSetOrder(1)
				If !dbSeek(xFilial("SC6") + cId + SC6->C6_NUM + SC6->C6_ITEM)
					RecLock("HC6", .T.)
				Else
					RecLock("HC6", .F.)
				EndIf
				HC6->HC6_FILIAL := xFilial("SC6")
				HC6->HC6_ID := cId
				HC6->HC6_COTAC := If(!Empty(SC5->C5_COTACAO),SC5->C5_COTACAO,SC5->C5_NUM)
				HC6->HC6_NUM := SC6->C6_NUM
				HC6->HC6_ITEM := SC6->C6_ITEM
				HC6->HC6_PROD := SC6->C6_PRODUTO
				HC6->HC6_GRUPO := SB1->B1_GRUPO
				HC6->HC6_QTDVEN := SC6->C6_QTDVEN
				HC6->HC6_PRCVEN := SC6->C6_PRCVEN
				HC6->HC6_VALOR := SC6->C6_VALOR
				HC6->HC6_QTDLIB := SC6->C6_QTDLIB
				HC6->HC6_ENTREG := SC6->C6_ENTREG
				HC6->HC6_UM := SC6->C6_UM
				HC6->HC6_TES := SC6->C6_TES
				HC6->HC6_LOCAL := SC6->C6_LOCAL
				HC6->HC6_QTDENT := SC6->C6_QTDENT
				HC6->HC6_DESC := SC6->C6_DESCONT
				HC6->HC6_ICMS := 0
				HC6->HC6_IPI := SC6->C6_IPIDEV
				HC6->HC6_TABELA := SC5->C5_TABELA
				HC6->HC6_STATUS := cStatus
				HC6->HC6_BONIF := 0
				HC6->HC6_VER   := 1
				HC6->HC6_INTR := cIntr
				HC6->(MsUnlock())
	  	     	dbSelectArea("SC6")
	     	 	dbSkip()
		    EndDo
			j := j + 1
		EndIf
	EndDo
	aQtdPed := {}
	j := 1
	dbSelectArea("SA1")
	SA1->(dbSkip())
EndDo
dbSelectArea("SA1")
SET FILTER TO

//HHCloseAlias()
//HC5->(dbCloseArea())
//HC6->(dbCloseArea())
//HD5->(dbCloseArea())
//IND->(dbCloseArea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHExpSA4  ³ Autor ³ Cleber Martinez       ³ Data ³ 22/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho de Transportadoras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XEXPSA4()
Local cIntr := "I"              
Local cId := ""
//Transportadoras
dbSelectArea("SA4")
dbSeek(xFilial("SA4"))
cId := HHCheckID("HA4")
While !SA4->(Eof()) .and. SA4->A4_FILIAL == xFilial("SA4")
	dbSelectArea("HA4")
	dbSetOrder(1)
	If !dbSeek(xFilial("SA4") + cId + SA4->A4_COD)
		RecLock("HA4",.T.)
	Else
		RecLock("HA4",.F.)
	EndIf
	HA4->HA4_FILIAL := xFilial("SA4")
	HA4->HA4_ID := cId
	HA4->HA4_COD    := SA4->A4_COD
	HA4->HA4_NOME := SA4->A4_NOME
	HA4->HA4_INTR   := cIntr
	HA4->HA4_VER    := 1
	HA4->(MsUnlock())
	dbSelectArea("SA4")
	SA4->(dbSkip())
EndDo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHExpACQ Autor ³ Marcelo Vieira        ³ Data ³ 04/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia Tabelas Cenario de vendas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function XEXPACQ()
Local cIntr     := "I"
Local cId       := HHCheckID("HCO", "ACO")
dbSelectArea("ACO")
dbGotop()
While ACO->(!Eof()) 
	dbSelectArea("HCO")
	dbSetOrder(1)
	If !dbSeek(xFilial("ACO") + cId + ACO->ACO_CODREG)
		RecLock("HCO",.T.)
	Else
		RecLock("HCO",.F.)
	EndIf	
	HCO->HCO_FILIAL := xFilial("ACO")
	HCO->HCO_ID := cId
	HCO->HCO_CODREG := ACO->ACO_CODREG
	HCO->HCO_DESCRI := ACO->ACO_DESCRI
	HCO->HCO_CODCLI := ACO->ACO_CODCLI
	HCO->HCO_LOJA   := ACO->ACO_LOJA
	HCO->HCO_CODTAB := ACO->ACO_CODTAB
	HCO->HCO_CONDPG := ACO->ACO_CONDPG
	HCO->HCO_FORMPG := ACO->ACO_FORMPG
	HCO->HCO_FAIXA  := ACO->ACO_FAIXA
	HCO->HCO_MOEDA  := ACO->ACO_MOEDA
	HCO->HCO_PERDES := ACO->ACO_PERDES
	HCO->HCO_CFAIXA := ACO->ACO_CFAIXA
	HCO->HCO_INTR   := cIntr
	HCO->HCO_VER    := 1
	HCO->( MsUnlock())  
	ACO->( dbSkip())
EndDo
cId := HHCheckID("HCP", "ACP")
dbSelectArea("ACP")
ACP->(dbGotop())
While ACP->(!Eof()) 
	dbSelectArea("HCP")
	dbSetOrder(1)
	If !dbSeek(xFilial("ACP") + cId + ACP->ACP_CODREG + ACP->ACP_ITEM)
		RecLock("HCP",.T.)
	Else
		RecLock("HCP",.F.)
	EndIf	
	HCP->HCP_FILIAL := xFilial("ACP")
	HCP->HCP_ID := cId
	HCP->HCP_CODREG := ACP->ACP_CODREG
	HCP->HCP_ITEM := ACP->ACP_ITEM
	HCP->HCP_CODPRO := ACP->ACP_CODPRO
	HCP->HCP_GRUPO := ACP->ACP_GRUPO
	HCP->HCP_PERDES := ACP->ACP_PERDES
	HCP->HCP_FAIXA := ACP->ACP_FAIXA
	HCP->HCP_CFAIXA := ACP->ACP_CFAIXA
	HCP->HCP_INTR := cIntr
	HCP->HCP_VER  := 1
	HCP->( MsUnlock() )
	  
	ACP->( dbSkip())
EndDo    
cId := HHCheckID("HCQ", "ACQ")
// Gera Regra de Bonificacao 
dbSelectArea("ACQ")
ACQ->(dbGotop())
While ACQ->(!Eof()) 
	dbSelectArea("HCQ")
	dbSetOrder(1)
	If !dbSeek(xFilial("ACQ") + cId + ACQ->ACQ_CODREG)
		RecLock("HCQ",.T.)
	Else
		RecLock("HCQ",.F.)
	EndIf	
	HCQ->HCQ_FILIAL := xFilial("ACQ")
	HCQ->HCQ_ID := cId
	HCQ->HCQ_CODREG := ACQ->ACQ_CODREG
	HCQ->HCQ_DESCRI := ACQ->ACQ_DESCRI
	HCQ->HCQ_CODCLI := ACQ->ACQ_CODCLI
	HCQ->HCQ_LOJA   := ACQ->ACQ_LOJA
	HCQ->HCQ_CODTAB := ACQ->ACQ_CODTAB
	HCQ->HCQ_CONDPG := ACQ->ACQ_CONDPG
	HCQ->HCQ_FORMPG := ACQ->ACQ_FORMPG
	HCQ->HCQ_CODPRO := ACQ->ACQ_CODPRO
	HCQ->HCQ_QUANT  := ACQ->ACQ_QUANT
	HCQ->HCQ_TPRGBN := ACQ->ACQ_TPRGBN
	HCQ->HCQ_INTR   := cIntr
	HCQ->HCQ_VER    := 1
	HCQ->( MsUnlock() )
	ACQ->( dbSkip())
EndDo
cId := HHCheckID("HCR", "ACR")
// Gera Regra de Bonificacao Itens 
dbSelectArea("ACR")
ACR->(dbGotop())
While ACR->(!Eof()) 
	dbSelectArea("HCR")
	dbSetOrder(1)
	If !dbSeek(xFilial("ACR") + cId + ACR->ACR_CODREG + ACR->ACR_ITEM)
		RecLock("HCR",.T.)
	Else
		RecLock("HCR",.F.)
	EndIf	
	HCR->HCR_FILIAL := xFilial("ACR")
	HCR->HCR_ID := cId
	HCR->HCR_CODREG := ACR->ACR_CODREG
	HCR->HCR_ITEM   := ACR->ACR_ITEM
	HCR->HCR_CODPRO := ACR->ACR_CODPRO
	HCR->HCR_GRUPO  := ACR->ACR_GRUPO
	HCR->HCR_LOTE   := ACR->ACR_LOTE
	HCR->HCR_INTR   := cIntr
	HCR->HCR_VER    := 1
	HCR->( MsUnlock() ) 
	ACR->( dbSkip())
EndDo
cId := HHCheckID("HCS", "ACS")
// Gera Regra de Negocios
dbSelectArea("ACS")
ACS->(dbGotop())
While ACS->(!Eof()) 
	dbSelectArea("HCS")
	dbSetOrder(1)
	If !dbSeek(xFilial("ACS") + cId + ACS->ACS_CODREG)
		RecLock("HCS",.T.)
	Else
		RecLock("HCS",.F.)
	EndIf	
	HCS->HCS_FILIAL := xFilial("ACS")
	HCS->HCS_ID := cId
	HCS->HCS_CODREG := ACS->ACS_CODREG
	HCS->HCS_DESCRI := ACS->ACS_DESCRI
	HCS->HCS_CODCLI := ACS->ACS_CODCLI
	HCS->HCS_LOJA   := ACS->ACS_LOJA
	If HCS->(FieldPos("HCS_GRPVEN")) > 0 .And. ACS->(FieldPos("ACS_GRPVEN")) > 0
		HCS->HCS_GRPVEN := ACS->ACS_GRPVEN
	EndIf
	HCS->HCS_INTR   := cIntr
	HCS->HCS_VER    := 1
	HCS->(MsUnlock())
	ACS->(dbSkip())
EndDo    
cId := HHCheckID("HCT", "ACT")
// Gera Itens da Regra de Negocio
dbSelectArea("ACT")
ACT->(dbGotop())
While ACT->(!Eof()) 
	dbSelectArea("HCT")
	dbSetOrder(1)
	If !dbSeek(xFilial("ACT") + cId + ACT->ACT_CODREG + ACT->ACT_ITEM)
		RecLock("HCT",.T.)
	Else
		RecLock("HCT",.F.)
	EndIf	
	HCT->HCT_FILIAL := xFilial("ACT")
	HCT->HCT_ID := cId
	HCT_CODREG := ACT->ACT_CODREG
	HCT_ITEM   := ACT->ACT_ITEM
	HCT_CODTAB := ACT->ACT_CODTAB
	HCT_CONDPG := ACT->ACT_CONDPG
	HCT_FORMPG := ACT->ACT_FORMPG
	HCT_TPRGNG := ACT->ACT_TPRGNG
	HCT_INTR   := cIntr
	HCT_VER    := 1
	HCT->( MsUnlock() )
	ACT->( dbSkip())
EndDo

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HHExpDA5 ³ Autor ³ Fabio Garbin          ³ Data ³ 23/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Rotas.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm - Exclusivo para modulo SIGAOMS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ M.Vieira   ³11.11.01³ Substituicao de macros pela funcao FieldPut()   ³±±
±±|            |        | FieldGet()                                      ³±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XEXPDA5()  
Local aRoteiro   := {} // Contem os dados do arquivo do Roteiro de Visitas
Local aRota      := {} //Contem os dados do arquivo de Rotas
Local aStrus     := {}
//Local dDataAnt   := Date()
//Local nRotAtu    := 0
//Local nVisAtu    := 0
//Local i          := 0
//Local j          := 0
Local cPercurso  := ""
Local cVendedor  := HGU->HGU_CODBAS
Local cId := HHCheckID("HRT", "DA5")
//Local cFileRotas := "HRT"  + cEmpAnt + "0" 
//Local cFileRoteiro:="HD7"  + cEmpAnt + "0" 

// Preenche o array com os campos a serem enviados tabela Rotas
aadd(aRota,{"RT_PERCUR", "C",  6, 0}) // Codigo do Percurso
aadd(aRota,{"RT_ROTA"  , "C",  6, 0}) // Codigo da Rota (Palm)
aadd(aRota,{"RT_DESCR" , "C", 14, 0}) // Descricao da Rota

// Preenche o array com os campos a serem enviados tabela Roteiro

aadd(aRoteiro,{"AD7_PERCUR" , "C", 06, 0}) // Codigo do Percurso
aadd(aRoteiro,{"AD7_ROTA"   , "C", 06, 0}) // Codigo da Rota
aadd(aRoteiro,{"AD7_DESPER" , "C", 40, 0}) // Descricao do Percurso
aadd(aRoteiro,{"AD7_ORDEM"  , "C", 06, 0}) // Codigo da Visita
aadd(aRoteiro,{"AD7_CLI"    , "C", 06, 0}) // Codigo do cliente
aadd(aRoteiro,{"AD7_LOJA"   , "C", 02, 0}) // Loja do cliente
aadd(aRoteiro,{"AD7_DATA"   , "D", 08, 0}) // Data 
aadd(aRoteiro,{"AD7_FLGVIS" , "C", 01, 0}) // Flag de Atendimento
aadd(aRoteiro,{"AD7_OCO"    , "C", 06, 0}) // Ocorrencia
aadd(aRoteiro,{"AD7_DT"     , "D", 08, 0}) // Data da Ocorrencia 

//PAcertaSx3(@aRoteiro)

	//ConOut("PALMJOB: Criando arquivo de Rota para " + Trim(HCADHH->HH_NOMUSR))

//PalmCreate(<estrutura>,<arquivo>,<alias>)
//PalmCreate(aRota,cFileRotas,"HRT")
//PalmCreate(aRoteiro,cFileRoteiro,"HD7")
aAdd(aStrus, aRota)
aAdd(aStrus, aRoteiro)
//HHCreate(aStrus)

// Grava Arquivos Temporarios
dbSelectArea("DA5")
dbSetOrder(2)
dbSeek(xFilial("DA5")+cVendedor, .t.)
While !DA5->(Eof()) .and. DA5->DA5_FILIAL= xFilial("DA5") .and. DA5->DA5_VENDED = cVendedor
	cPercurso := DA5->DA5_COD
	dbSelectArea("DA6")
	dbSetOrder(1)
	If dbSeek(xFilial("DA6")+cPercurso)
		While !DA6->(Eof()) .And. DA6->DA6_FILIAL = xFilial("DA6") .and. DA6->DA6_PERCUR = cPercurso
			cRota := DA6->DA6_ROTA
			dbSelectArea("DA7")
			dbSetOrder(1)
			If dbSeek(xFilial("DA7")+cPercurso+cRota)
				While !DA7->(Eof()) .and. DA7->DA7_FILIAL= xFilial("DA7") .And. DA7->DA7_ROTA = cRota .And. DA7->DA7_PERCUR = cPercurso
					dbSelectArea("SA1")
					dbSetOrder(1)
					dbSeek(xFilial("SA1")+DA7->DA7_CLIENT+DA7->DA7_LOJA)
					dbSelectArea("HD7")
					RecLock("HD7",.T.)
					HD7->AD7_FILIAL := xFilial("DA7")
					HD7->AD7_ID := cId
					HD7->AD7_ROTA    := DA7->DA7_ROTA
					HD7->AD7_PERCUR  := DA7->DA7_PERCUR
					HD7->AD7_DESPER  := DA6->DA6_REF
					HD7->AD7_ORDEM   := DA7->DA7_SEQUEN
					HD7->AD7_CLI     := DA7->DA7_CLIENTE
					HD7->AD7_LOJA    := DA7->DA7_LOJA
					HD7->AD7_DATA    := CtoD("")
					HD7->AD7_FLGVIS  := ""
					HD7->AD7_OCO     := Space(6)
					HD7->AD7_DT      := CTOD('')
					HD7->(MsUnlock())					                
					dbSelectArea("DA7")
					DA7->(dbSkip())
					
					If DA7->DA7_ROTA <> cRota //.Or. DA7->DA7_PERCUR <> cPercurso
						dbSelectArea("HRT")
						RecLock("HRT",.T.)
						HRT->HRT_FILIAL := xFilial("DA6")
						HRT->HRT_ID := cId
						HRT->HRT_PERCUR:= cPercurso
						HRT->HRT_ROTA  := cRota
						HRT->HRT_DESCR := DA6->DA6_REF //DA5->DA5_DESC
						HRT->(MsUnlock())
					EndIf
				EndDo
			EndIf
			dbSelectArea("DA6")
			DA6->(dbSkip())
		EndDo
	EndIf
	dbSelectArea("DA5")
	dbSkip()
EndDo

//HHCloseAlias()
//HRT->(dbCloseArea())
//HD7->(dbCloseArea())

Return
       
//FUNCAO DE TESTE
Main Function HHTeste_USFA()
RpcSetType ( 3 )
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT"
U_XEXPHMV()
Return


