#INCLUDE "WSMAT_RM.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSMAT_RM  ³ Autor ³Alexandre Silva        ³ Data ³12.02.2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service responsavel pelos documentos de entrada/saida    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Definicao do Web Service                                                ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
WSSERVICE MtCustomerRemission     DESCRIPTION STR0001 //"Servico de consulta dos documentos de entrada e saida. ( <b>Restricao de cliente<b> )"
WSDATA HeaderType               As String
WSDATA Header                   As Array Of BrwHeader
WSDATA RemissionHeader         	As Array Of RemissionHeaderView
WSDATA UserCode                 As String
WSDATA CustomerOrSupplier       As Integer
WSDATA CustomerOrSupplierID     As String
WSDATA RegisterDateFrom         As Date OPTIONAL
WSDATA RegisterDateTo           As Date OPTIONAL
WSDATA DeliveryDateFrom         As Date OPTIONAL
WSDATA DeliveryDateTo           As Date OPTIONAL
WSDATA CustomerOrSupplierType   As String
WSDATA QueryAddWhereRme         As String OPTIONAL
WSDATA QueryAddWhereRms         As String OPTIONAL
WSDATA IndexKeyRme              As String OPTIONAL
WSDATA IndexKeyRms              As String OPTIONAL
WSDATA PurchaseNumber           As String OPTIONAL
WSDATA SerialNumber    	        As String
WSDATA RemissionNumber          As String
WSDATA RemissionType            As String
WSDATA Remission                As RemissionView
WSDATA WsNull                   As String

WSMETHOD GetHeader           DESCRIPTION STR0002 //"Metodo que descreve as estruturas de retorno do servico."
WSMETHOD BrwRemission        DESCRIPTION STR0003 //"Metodo de listagem dos documentos de entrada ou saida."
WSMETHOD GetRemission        DESCRIPTION STR0004 //"Metodo de consulta as informacoes do documento de entrada ou saida."
ENDWSSERVICE

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetHeader ³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao do header                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Estrutura                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o header de uma estrutura                ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GetHeader WSRECEIVE HeaderType WSSEND Header WSSERVICE MtCustomerRemission

::Header := MtHeader(::HeaderType)
If Empty(::Header)
	::Header := FinHeader(::HeaderType)
EndIf

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BrwPurchas³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao dos documentos de entrada e saida      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Fornecedor                                            ³±±
±±³          ³ExpD3: Data Inicial                                          ³±±
±±³          ³ExpD4: Data Final                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve as cotacaoes em aberto do fornecedor     ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD BrwRemission WSRECEIVE UserCode,CustomerOrSupplier,CustomerOrSupplierID,RegisterDateFrom,RegisterDateTo,DeliveryDateFrom,DeliveryDateTo,QueryAddWhereRme,QueryAddWhereRms,IndexKeyRme,IndexKeyRms,PurchaseNumber WSSEND RemissionHeader WSSERVICE MtCustomerRemission

Local aArea    := GetArea()

Local lRetorno := .T.
Local lQuery   := .F.
Local lValido  := .F.
Local nX       := 0
Local cArquivo := ""
Local cQuery   := ""
Local cAliasSF1:= "SF1"
Local cAliasSF2:= "SF2"
Local cFornece := SubStr(::CustomerOrSupplierID,1,Len(SA2->A2_COD))
Local cLojaFor := SubStr(::CustomerOrSupplierID,Len(SA2->A2_COD)+1)
Local cCliente := SubStr(::CustomerOrSupplierID,1,Len(SA1->A1_COD))
Local cLojaCli := SubStr(::CustomerOrSupplierID,Len(SA1->A1_COD)+1)
Local dEntrini := ::DeliveryDateFrom
Local dEntrFim := ::DeliveryDateTo
Local dEmisini := ::RegisterDateFrom
Local dEmisFim := ::RegisterDateTo
Local cAlias   := IIf(::CustomerOrSupplier==1,"SA1","SA2")
#IFDEF TOP
Local aCampos  := {}
Local aStruSF1 := {}
Local aStruSF2 := {}
Local cVolume  := ""
Local nY       := 0
#ENDIF

DEFAULT dEntrIni := dDataBase-30
DEFAULT dEntrFim := dDataBase
DEFAULT dEmisIni := dDataBase-30
DEFAULT dEmisFim := dDataBase

If PrtChkUser(::UserCode,"MtCustomerRemission","BrwRemission",cAlias,::CustomerOrSupplierID)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pesquisa os documentos de entrada                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	dbSetOrder(2)
	#IFDEF TOP
		lQuery := .T.
		cAliasSF1 := "BRWRemission"
		aStruSF1  := SF1->(dbStruct())

		cQuery := "SELECT F1_FILIAL,F1_TIPO,F1_FORNECE,F1_LOJA,F1_DOC,F1_SERIE,F1_FORMUL, "
		cQuery += "F1_DTDIGIT,F1_EMISSAO,F1_VALBRUT,F1_DESPESA,F1_SEGURO,F1_FRETE, "
		aCampos := MaFisRefLd("SF1","NF")
		For nY := 1 To Len(aCampos)
			If !Empty(aCampos[nY][2])
				cQuery += aCampos[nY][2]+","
			EndIf
			If !Empty(aCampos[nY][3])
				cQuery += aCampos[nY][3]+","
			EndIf
			If !Empty(aCampos[nY][4])
				cQuery += aCampos[nY][4]+","
			EndIf
		Next nY
		cQuery += "F1_PREFIXO,F1_DUPL "
		cQuery += GetUserField("SF1")
		cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
		If !Empty(::PurchaseNumber)
			cQuery += ","+RetSqlName("SD1")+" SD1 "
		EndIf
		cQuery += "WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND "
		If ::CustomerOrSupplier==1
			cQuery += "SF1.F1_FORNECE='"+cCliente+"' AND "
			cQuery += "SF1.F1_LOJA='"+cLojaCli+"' AND "
			cQuery += "SF1.F1_TIPO IN('D','B') AND "
		Else
			cQuery += "SF1.F1_FORNECE='"+cFornece+"' AND "
			cQuery += "SF1.F1_LOJA='"+cLojaFor+"' AND "
			cQuery += "SF1.F1_TIPO NOT IN('D','B') AND "			
		EndIf
		cQuery += "SF1.F1_EMISSAO >= '"+Dtos(dEmisIni)+"' AND "
		cQuery += "SF1.F1_EMISSAO <= '"+Dtos(dEmisFim)+"' AND "
		cQuery += "SF1.F1_DTDIGIT >= '"+Dtos(dEntrIni)+"' AND "
		cQuery += "SF1.F1_DTDIGIT <= '"+Dtos(dEntrFim)+"' AND "
		cQuery += "SF1.F1_TIPODOC >  '49' AND " 
		cQuery += "SF1.D_E_L_E_T_=' ' "
		If !Empty(::PurchaseNumber)
			cQuery += " AND "
			cQuery += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery += "SD1.D1_DOC = SF1.F1_DOC AND "
			cQuery += "SD1.D1_SERIE = SF1.F1_SERIE AND "
			cQuery += "SD1.D1_FORNECE = SF1.F1_FORNECE AND "
			cQuery += "SD1.D1_LOJA = SF1.F1_LOJA AND "
			cQuery += "SD1.D1_TIPO = SF1.F1_TIPO AND "
			cQuery += "SD1.D1_PEDIDO = '"+::PurchaseNumber+"' AND "
			cQuery += "SD1.D_E_L_E_T_=' ' "
		EndIf
		cQuery := WsQueryAdd(cQuery,::QueryAddWhereRme)
		cQuery += "ORDER BY "+WsSqlOrder(IIf(Empty(::IndexKeyRme),SF1->(IndexKey()),::IndexKeyRme))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1)

		For nY := 1 To Len(aStruSF1)
			If aStruSF1[nY][2] <> "C" .And. aStruSF1[nY][2] <> "M"
				TcSetField(cAliasSF1,aStruSF1[nY][1],aStruSF1[nY][2],aStruSF1[nY][3],aStruSF1[nY][4])
			EndIf		
		Next nY

	#ELSE
		cArquivo := CriaTrab(,.F.)
		cQuery := "F1_FILIAL='"+xFilial("SF1")+"' .AND. "
		cQuery += "F1_FORNECE = '"+cFornece+"' .AND. "
		cQuery += "F1_LOJA = '"+cLojaFor+"' .AND. "	
    	cQuery += "F1_TIPODOC > '49' .AND."
		cQuery += "DToS(F1_EMISSAO) >= '"+Dtos(dEmisIni)+"' .AND. "
		cQuery += "DToS(F1_EMISSAO) <= '"+Dtos(dEmisFim)+"' .AND. "
		cQuery += "DToS(F1_DTDIGIT) >= '"+Dtos(dEntrIni)+"' .AND. "
		cQuery += "DToS(F1_DTDIGIT) <= '"+Dtos(dEntrFim)+"' "	

		IndRegua("SF1",cArquivo,IIf(Empty(::IndexKeyRme),SF1->(IndexKey()),::IndexKeyRme),,cQuery)
		dbGotop()

	#ENDIF
	nX := 0
	DEFAULT ::RemissionHeader := {}
	While !Eof() .And. xFilial("SF1") == (cAliasSF1)->F1_FILIAL .And.;
			cFornece+cLojaFor == (cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA

		If IIf(::CustomerOrSupplier==1,(cAliasSF1)->F1_TIPO $ 'DB',!(cAliasSF1)->F1_TIPO $ 'DB') .And.;
				(cAliasSF1)->F1_EMISSAO >= dEmisIni .And.;
				(cAliasSF1)->F1_EMISSAO <= dEmisFim .And.;
				(cAliasSF1)->F1_DTDIGIT >= dEntrIni .And.;
				(cAliasSF1)->F1_DTDIGIT <= dEntrFim	
			
			If lQuery
				lValido := .T.
			Else		
				If Empty(::PurchaseNumber)
					lValido := .T.
				Else
					lValido := .F.
					dbSelectArea("SD1")
					dbSetOrder(1)
					MsSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
					While !Eof() .And.;
						xFilial("SD1") == SD1->D1_FILIAL .And.;
						(cAliasSF1)->F1_DOC == SD1->D1_DOC .And.;
						(cAliasSF1)->F1_SERIE == SD1->D1_SERIE .And.;
						(cAliasSF1)->F1_FORNECE == SD1->D1_FORNECE .And.;
						(cAliasSF1)->F1_LOJA == SD1->D1_LOJA

						If SD1->D1_TIPO == (cAliasSF1)->F1_TIPO .And.;
							SD1->D1_FORMUL == (cAliasSF1)->F1_FORMUL .And.;
							SD1->D1_PEDIDO == ::PurchaseNumber
							
							lValido := .T.
				 			Exit			
						EndIf
						
						dbSelectArea("SD1")
						dbSkip()
						
					EndDo
				EndIf
			EndIf
			If lValido
				aadd(::RemissionHeader,WsClassNew("RemissionHeaderView"))
				nX++
				GetRmEHead(@::RemissionHeader[nX],cAliasSF1)
			EndIf
		EndIf
		dbSelectArea(cAliasSF1)		
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSF1)		
		dbCloseArea()	
		dbSelectArea("SF1")
	Else
		dbSelectArea("SF1")
		RetIndex("SF1")
		FErase(cArquivo+OrdBagExt())
	EndIf
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Pesquisa os documentos de saida                                         ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SF2")
	dbSetOrder(2)
	#IFDEF TOP
		lQuery := .T.
		cAliasSF2 := "BRWRemission"
		aStruSF2  := SF2->(dbStruct())

		cQuery := "SELECT F2_FILIAL,F2_TIPO,F2_CLIENTE,F2_LOJA,F2_DOC,F2_SERIE, "
		cQuery += "F2_EMISSAO,F2_VALBRUT,F2_DESPESA,F2_SEGURO,F2_FRETE,F2_TRANSP, "
		aCampos := MaFisRefLd("SF2","NF")
		For nY := 1 To Len(aCampos)
			If !Empty(aCampos[nY][2])
				cQuery += aCampos[nY][2]+","
			EndIf
			If !Empty(aCampos[nY][3])
				cQuery += aCampos[nY][3]+","
			EndIf
			If !Empty(aCampos[nY][4])
				cQuery += aCampos[nY][4]+","
			EndIf
		Next nY
		cVolume := "1"
		While SF2->(FieldPos("F2_ESPECI"+cVolume))<>0 .And. !Empty(SF2->(FieldGet(FieldPos("F2_ESPECI"+cVolume))))
			cQuery += "F2_ESPECI"+cVolume+","+"F2_ESPECI"+cVolume+","
		 	cVolume := Soma1( cVolume )
		EndDo
		cQuery += "F2_PREFIXO,F2_DUPL "
		cQuery += GetUserField("SF2")
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		If !Empty(::PurchaseNumber)
			cQuery += ","+RetSqlName("SD2")+" SD2 "
		EndIf
		cQuery += "WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
		If ::CustomerOrSupplier==1
			cQuery += "SF2.F2_CLIENTE='"+cCliente+"' AND "
			cQuery += "SF2.F2_LOJA='"+cLojaCli+"' AND "
			cQuery += "SF2.F2_TIPO NOT IN('D','B') AND "
		Else
			cQuery += "SF2.F2_CLIENTE='"+cFornece+"' AND "
			cQuery += "SF2.F2_LOJA='"+cLojaFor+"' AND "
			cQuery += "SF2.F2_TIPO IN('D','B') AND "			
		EndIf
		cQuery += "SF2.F2_EMISSAO >= '"+Dtos(dEmisIni)+"' AND "
		cQuery += "SF2.F2_EMISSAO <= '"+Dtos(dEmisFim)+"' AND "
		cQuery += "SF2.F2_EMISSAO >= '"+Dtos(dEntrIni)+"' AND "
		cQuery += "SF2.F2_EMISSAO <= '"+Dtos(dEntrFim)+"' AND "
		cQuery += "SF2.F2_TIPODOC > '49' AND "
		cQuery += "SF2.D_E_L_E_T_=' ' "
		If !Empty(::PurchaseNumber)
			cQuery += " AND "
			cQuery += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
			cQuery += "SD2.D2_DOC = SF2.F2_DOC AND "
			cQuery += "SD2.D2_SERIE = SF2.F2_SERIE AND "
			cQuery += "SD2.D2_CLIENTE = SF2.F2_CLIENTE AND "
			cQuery += "SD2.D2_LOJA = SF2.F2_LOJA AND "
			cQuery += "SD2.D2_PEDIDO = '"+::PurchaseNumber+"' AND "
			cQuery += "SD2.D_E_L_E_T_=' ' "
		EndIf		
		cQuery := WsQueryAdd(cQuery,::QueryAddWhereRms)
		cQuery += "ORDER BY "+WsSqlOrder(IIf(Empty(::IndexKeyRms),SF2->(IndexKey()),::IndexKeyRms))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2)

		For nY := 1 To Len(aStruSF2)
			If aStruSF2[nY][2] <> "C" .And. aStruSF2[nY][2] <> "M"
				TcSetField(cAliasSF2,aStruSF2[nY][1],aStruSF2[nY][2],aStruSF2[nY][3],aStruSF2[nY][4])
			EndIf		
		Next nY

	#ELSE
		cArquivo := CriaTrab(,.F.)
		cQuery := "F2_FILIAL='"+xFilial("SF2")+"' .AND. "
		cQuery += "F2_CLIENTE = '"+cCliente+"' .AND. "
		cQuery += "F2_LOJA = '"+cLojaCli+"' .AND. "
		cQuery += "F2_TIPODOC > '49' .AND. "
		cQuery += "DToS(F2_EMISSAO) >= '"+Dtos(dEmisIni)+"' .AND. "
		cQuery += "DToS(F2_EMISSAO) <= '"+Dtos(dEmisFim)+"' .AND. "
		cQuery += "DToS(F2_EMISSAO) >= '"+Dtos(dEntrIni)+"' .AND. "
		cQuery += "DToS(F2_EMISSAO) <= '"+Dtos(dEntrFim)+"' "	

		IndRegua("SF2",cArquivo,IIf(Empty(::IndexKeyRms),SF2->(IndexKey()),::IndexKeyRms),,cQuery)
		dbGotop()
	#ENDIF
	DEFAULT ::RemissionHeader := {}	
	While !Eof() .And. xFilial("SF2") == (cAliasSF2)->F2_FILIAL .And.;
			cCliente+cLojaCli == (cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA

		If IIf(::CustomerOrSupplier==1,!(cAliasSF2)->F2_TIPO $ 'DB',(cAliasSF2)->F2_TIPO $ 'DB') .And.;
				(cAliasSF2)->F2_EMISSAO >= dEmisIni .And.;
				(cAliasSF2)->F2_EMISSAO <= dEmisFim .And.;
				(cAliasSF2)->F2_EMISSAO >= dEntrIni .And.;
				(cAliasSF2)->F2_EMISSAO <= dEntrFim
			If lQuery
				lValido := .T.
			Else
				If Empty(::PurchaseNumber)
					lValido := .T.
				Else
					dbSelectArea("SD2")
					dbSetOrder(1)
					MsSeek(xFilial("SD2")+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
					While !Eof() .And.;
						xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
						(cAliasSF2)->F2_DOC == (cAliasSD2)->D2_DOC .And.;
						(cAliasSF2)->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
						(cAliasSF2)->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And.;
						(cAliasSF2)->F2_LOJA == (cAliasSD2)->D2_LOJA
				
						If (cAliasSD2)->D2_PEDIDO == ::PurchaseNumber
							lValido := .T.
							Exit
						EndIf
						dbSelectArea(cAliasSD2)
						dbSkip()			
					EndDo
				EndIf
			EndIf
			If lValido
				aadd(::RemissionHeader,WsClassNew("RemissionHeaderView"))
				nX++
				GetRmSHead(@::RemissionHeader[nX],cAliasSF2)
			EndIf
		EndIf		
		dbSelectArea(cAliasSF2)		
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSF2)		
		dbCloseArea()	
		dbSelectArea("SF2")
	Else
		dbSelectArea("SF2")
		RetIndex("SF2")
		FErase(cArquivo+OrdBagExt())	
	EndIf
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ  ÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRemission³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄ  ÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao dos documento de entrada / saida         ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                       ³±±
±±³          ³ExpC2: Tipo do documento de entrada/saida                      ³±±
±±³          ³ExpC3: Numero de Serie                                         ³±±
±±³          ³ExpC4: Numero do documento                                     ³±±
±±³          ³ExpC5: Formulario Proprio?                                     ³±±
±±³          ³ExpN6: 1-Cliente ou 2-Fornecedor                               ³±±
±±³          ³ExpC6: Codigo do cliente ou fornecedor                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso            ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve os documentos de entrad ou saida           ³±±
±±³          ³                                                               ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GetRemission WSRECEIVE UserCode,RemissionType,SerialNumber,RemissionNumber,CustomerOrSupplier,CustomerOrSupplierID,QueryAddWhereRme,QueryAddWhereRms WSSEND Remission WSSERVICE MtCustomerRemission

Local aArea    := GetArea()
Local cAlias   := IIf(::CustomerOrSupplier==1,"SA1","SA2")
Local cES      := SubStr(::RemissionType,1,1)
Local cFornece := SubStr(::CustomerOrSupplierID,1,Len(SA2->A2_COD))
Local cLojaFor := SubStr(::CustomerOrSupplierID,Len(SA2->A2_COD)+1)
Local cCliente := SubStr(::CustomerOrSupplierID,1,Len(SA1->A1_COD))
Local cLojaCli := SubStr(::CustomerOrSupplierID,Len(SA1->A1_COD)+1)
Local cSerie   := SubStr(::SerialNumber,1,Len(SD1->D1_SERIE))
Local cDoc     := SubStr(::RemissionNumber,1,Len(SD1->D1_DOC))
Local cTipo    := AllTrim(SubStr(::RemissionType,3))
Local cAliasSD1:= "SD1"
Local cAliasSD2:= "SD2"
Local nX       := 0
Local lQuery   := .F.
Local lRetorno := .F.
#IFDEF TOP
Local aStruSD1 := {}
Local aStruSD2 := {}
Local cQuery   := ""
Local nY       := 0
#ENDIF

If PrtChkUser(::UserCode,"MtCustomerRemission","GetRemission",cAlias,::CustomerOrSupplierID)
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Verifica se qual o tipo de documento                                    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If cES == "E"
		dbSelectArea("SF1")
		dbSetOrder(1)
		MsSeek(xFilial("SF1")+cDoc+cSerie+cFornece+cLojaFor+cTipo)
		While !Eof() .And. xFilial("SF1") == SF1->F1_FILIAL .And.;
			cDoc == SF1->F1_DOC .And.;
			cSerie == SF1->F1_SERIE .And.;
			cFornece == SF1->F1_FORNECE .And.;
			cLojaFor == SF1->F1_LOJA .And.;
			cTipo == SF1->F1_TIPO 
				lRetorno := .T.			
				Exit
			dbSelectArea("SF1")
			dbSkip()
		EndDo
		If lRetorno
			::Remission:RemissionHeader := WsClassNew("RemissionHeaderView")
			GetRmEHead(@::Remission:RemissionHeader,"SF1")
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Pesquisa os Itens do documento de entrada                               ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			::REMISSION:RemissionITEM:= {}
			dbSelectArea("SD1")
			dbSetOrder(1)
			#IFDEF TOP
				aStruSD1 := SD1->(dbStruct())
				lQuery   := .T.
				cAliasSD1:= "GETRemission"
				
				cQuery := "SELECT * "
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
				cQuery += "SD1.D1_DOC='"+cDoc+"' AND "
				cQuery += "SD1.D1_SERIE='"+cSerie+"' AND "
				cQuery += "SD1.D1_FORNECE='"+cFornece+"' AND "
				cQuery += "SD1.D1_LOJA='"+cLojaFor+"' AND "	
				cQuery += "SD1.D1_TIPO='"+cTipo+"' AND "
				cQuery += "SD1.D_E_L_E_T_=' ' "
				cQuery := WsQueryAdd(cQuery,::QueryAddWhereRme)
				cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
				
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1)
				
				For nY := 1 To Len(aStruSD1)
					If aStruSD1[nY][2] <> "C" .And. aStruSD1[nY][2] <> "M"
						TcSetField(cAliasSD1,aStruSD1[nY][1],aStruSD1[nY][2],aStruSD1[nY][3],aStruSD1[nY][4])
					EndIf
				Next nY
						
			#ELSE
				MsSeek(xFilial("SD1")+cDoc+cSerie+cFornece+cLojaFor)
			#ENDIF
			nX := 0
			While !Eof() .And.;
				xFilial("SD1") == (cAliasSD1)->D1_FILIAL .And.;
				cDoc == (cAliasSD1)->D1_DOC .And.;
				cSerie == (cAliasSD1)->D1_SERIE .And.;
				cFornece == (cAliasSD1)->D1_FORNECE .And.;
				cLojaFor == (cAliasSD1)->D1_LOJA
				
				If (cAliasSD1)->D1_TIPO == cTipo 
					If nX == 0
	    				::REMISSION:RemissionITEM:= {}
					EndIf
					aadd(::REMISSION:RemissionITEM,WsClassNew("RemissionItemView"))
					nX++
					GetRmEItem(@::REMISSION:RemissionITEM[nX],cAliasSD1)
				EndIf
				dbSelectArea(cAliasSD1)
				dbSkip()			
			EndDo
			If lQuery
				dbSelectArea(cAliasSD1)
				dbCloseArea()
				dbSelectArea("SD1")
			EndIf
		EndIf
	Else
		dbSelectArea("SF2")
		dbSetOrder(1)
		If MsSeek(xFilial("SF2")+cDoc+cSerie+cCliente+cLojaCli)
			lRetorno := .T.
			::Remission:RemissionHeader := WsClassNew("RemissionHeaderView")
			GetRmSHead(@::Remission:RemissionHeader,"SF2")		
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Pesquisa os Itens do documento de saida                                 ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			::REMISSION:RemissionITEM:= {}
			dbSelectArea("SD2")
			dbSetOrder(3)
			#IFDEF TOP
				aStruSD2 := SD2->(dbStruct())
				lQuery   := .T.
				cAliasSD2:= "GETRemission"
				
				cQuery := "SELECT * "
				cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
				cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
				cQuery += "SD2.D2_DOC='"+cDoc+"' AND "
				cQuery += "SD2.D2_SERIE='"+cSerie+"' AND "
				cQuery += "SD2.D2_CLIENTE='"+cCliente+"' AND "
				cQuery += "SD2.D2_LOJA='"+cLojaCli+"' AND "	
				cQuery += "SD2.D2_TIPO='"+cTipo+"' AND "
				cQuery += "SD2.D_E_L_E_T_=' ' "
				cQuery := WsQueryAdd(cQuery,::QueryAddWhereRms)
				cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
				
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2)
				
				For nY := 1 To Len(aStruSD2)
					If aStruSD2[nY][2] <> "C" .And. aStruSD2[nY][2] <> "M"
						TcSetField(cAliasSD2,aStruSD2[nY][1],aStruSD2[nY][2],aStruSD2[nY][3],aStruSD2[nY][4])
					EndIf
				Next nY
						
			#ELSE
				MsSeek(xFilial("SD2")+cDoc+cSerie+cCliente+cLojaCli)
			#ENDIF
			nX := 0
			While !Eof() .And.;
				xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
				cDoc == (cAliasSD2)->D2_DOC .And.;
				cSerie == (cAliasSD2)->D2_SERIE .And.;
				cFornece == (cAliasSD2)->D2_CLIENTE .And.;
				cLojaFor == (cAliasSD2)->D2_LOJA
				
				If (cAliasSD2)->D2_TIPO == cTipo 
					If nX == 0
	    				::REMISSION:RemissionITEM:= {}
					EndIf
					aadd(::REMISSION:RemissionITEM,WsClassNew("RemissionItemView"))
					nX++
					GetRmSItem(@::REMISSION:RemissionITEM[nX],cAliasSD2)
				EndIf
				dbSelectArea(cAliasSD2)
				dbSkip()			
			EndDo
			If lQuery
				dbSelectArea(cAliasSD2)
				dbCloseArea()
				dbSelectArea("SD2")
			EndIf
		EndIf
	EndIf
	If !lRetorno
		SetSoapFault("GETRemission",STR0005) //"Documento nao encontrado"
	EndIf
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRmEHead³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de preenchimento do cabecalho do documento de entrada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto do cabecalho                                   ³±±
±±³          ³ExpC2: Alias do SF1                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o objeto passado por parametro com os    ³±±
±±³          ³dados do sf1 posicionado                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetRmEHead(oObjeto,cAliasSF1)

Local aArea     := GetArea()
Local cAlias   	:= IIf((cAliasSF1)->F1_TIPO$'DB',"SA1","SA2")

oObjeto:SerialNumber  	:= (cAliasSF1)->F1_SERIE
oObjeto:RemissionNumber := (cAliasSF1)->F1_DOC
oObjeto:RemissionType   := "E/"+(cAliasSF1)->F1_TIPO
oObjeto:RegisterDate  	:= (cAliasSF1)->F1_EMISSAO
oObjeto:RemissionDate   := (cAliasSF1)->F1_DTDIGIT
oObjeto:DeliveryDate  	:= (cAliasSF1)->F1_DTDIGIT
oObjeto:TotalValue    	:= (cAliasSF1)->F1_VALBRUT
oObjeto:ExpensesValue 	:= (cAliasSF1)->F1_DESPESA
oObjeto:InsuranceValue	:= (cAliasSF1)->F1_SEGURO
oObjeto:FreightValue  	:= (cAliasSF1)->F1_FRETE

oObjeto:FromRole 				:= WsClassNew("GenericStruct")		
oObjeto:FromRole:Code        	:= (cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA
oObjeto:FromRole:Description 	:= Posicione(cAlias,1,xFilial(cAlias)+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA,IIF(cAlias=="SA1","A1_NOME","A2_NOME"))
oObjeto:ToRole   				:= WsClassNew("GenericStruct")
oObjeto:ToRole:Code          	:= cEmpAnt+cFilAnt
oObjeto:ToRole:Description 		:= SM0->M0_NOME

UserFields("SF1",@oObjeto:UserFields,cAliasSF1)

RestArea(aArea)

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRmEItem³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de preenchimento do item do documento de entrada      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto do cabecalho                                   ³±±
±±³          ³ExpC2: Alias do SD1                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o objeto passado por parametro com os    ³±±
±±³          ³dados do sd1 posicionado                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetRmEItem(oObjeto,cAliasSD1)

Local aArea     := GetArea()

oObjeto:SequentialID       := (cAliasSD1)->D1_ITEM
oObjeto:ProductCode        := (cAliasSD1)->D1_COD
oObjeto:DescriptionProduct := Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_DESC")
oObjeto:MeasureUnit        := (cAliasSD1)->D1_UM
oObjeto:Quantity           := (cAliasSD1)->D1_QUANT
oObjeto:UnitPrice          := (cAliasSD1)->D1_VUNIT
oObjeto:TotalValue         := (cAliasSD1)->D1_TOTAL
oObjeto:DiscountPercent    := (cAliasSD1)->D1_DESC
oObjeto:DiscountValue      := (cAliasSD1)->D1_VALDESC
oObjeto:ExpensesValue      := (cAliasSD1)->D1_DESPESA
oObjeto:InsuranceValue     := (cAliasSD1)->D1_SEGURO
oObjeto:FreightValue       := (cAliasSD1)->D1_VALFRE

UserFields("SD1",@oObjeto:UserFields,cAliasSD1)

RestArea(aArea)

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRmSHead³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de preenchimento do cabecalho do documento de saida   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto do cabecalho                                   ³±±
±±³          ³ExpC2: Alias do SF2                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o objeto passado por parametro com os    ³±±
±±³          ³dados do SF2 posicionado                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetRmSHead(oObjeto,cAliasSF2)

Local aArea     := GetArea()
Local cAlias    := IIf((cAliasSF2)->F2_TIPO$'DB',"SA2","SA1")
Local cVolume   := ""
Local oTemp

oObjeto:SerialNumber  	:= (cAliasSF2)->F2_SERIE
oObjeto:RemissionNumber	:= (cAliasSF2)->F2_DOC
oObjeto:RemissionType  	:= "S/"+(cAliasSF2)->F2_TIPO
oObjeto:RegisterDate  	:= (cAliasSF2)->F2_EMISSAO
oObjeto:RemissionDate  	:= (cAliasSF2)->F2_EMISSAO
oObjeto:DeliveryDate 	:= (cAliasSF2)->F2_EMISSAO
oObjeto:TotalValue 		:= (cAliasSF2)->F2_VALBRUT
oObjeto:ExpensesValue 	:= (cAliasSF2)->F2_DESPESA
oObjeto:InsuranceValue	:= (cAliasSF2)->F2_SEGURO
oObjeto:FreightValue  	:= (cAliasSF2)->F2_FRETE

oObjeto:FromRole 				:= WsClassNew("GenericStruct")
oObjeto:FromRole:Code        	:= (cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA
oObjeto:FromRole:Description 	:= Posicione(cAlias,1,xFilial(cAlias)+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA,IIF(cAlias=="SA1","A1_NOME","A2_NOME"))
oObjeto:ToRole 					:= WsClassNew("GenericStruct")
oObjeto:ToRole:Code          	:= cEmpAnt+cFilAnt
oObjeto:ToRole:Description 		:= SM0->M0_NOME
			
If !Empty((cAliasSF2)->F2_TRANSP)
	oObjeto:Carrier 			:= WsClassNew("GenericStruct")
	oObjeto:Carrier:Code        := (cAliasSF2)->F2_TRANSP
	oObjeto:Carrier:Description := Posicione("SA4",1,xFilial("SA4")+(cAliasSF2)->F2_TRANSP,"A4_NOME")
EndIf
			
cVolume := "1"            
oObjeto:PackagesVolumes := {}
While (cAliasSF2)->(FieldPos("F2_ESPECI"+cVolume))<>0 .And. !Empty((cAliasSF2)->(FieldGet(FieldPos("F2_ESPECI"+cVolume))))
	oTemp             := WsClassNew("GenericStruct")
	oTemp:Code        := cVolume
	oTemp:Description := (cAliasSF2)->(FieldGet(FieldPos("F2_ESPECI"+cVolume)))
	oTemp:Value       := (cAliasSF2)->(FieldGet(FieldPos("F2_VOLUME"+cVolume)))
	aadd( oObjeto:PackagesVolumes, oTemp )
 	cVolume := Soma1( cVolume )
EndDo

UserFields("SF2",@oObjeto:UserFields,cAliasSF2)

RestArea(aArea)

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRmSItem³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de preenchimento do item do documento de Saida        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto do cabecalho                                   ³±±
±±³          ³ExpC2: Alias do SD2                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o objeto passado por parametro com os    ³±±
±±³          ³dados do SD2 posicionado                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetRmSItem(oObjeto,cAliasSD2)

Local aArea     := GetArea()

oObjeto:SequentialID       := (cAliasSD2)->D2_ITEM
oObjeto:ProductCode        := (cAliasSD2)->D2_COD
oObjeto:DescriptionProduct := Posicione("SB1",1,xFilial("SB1")+(cAliasSD2)->D2_COD,"B1_DESC")
oObjeto:MeasureUnit        := (cAliasSD2)->D2_UM
oObjeto:Quantity           := (cAliasSD2)->D2_QUANT
oObjeto:UnitPrice          := (cAliasSD2)->D2_PRCVEN
oObjeto:TotalValue         := (cAliasSD2)->D2_TOTAL
oObjeto:DiscountPercent    := (cAliasSD2)->D2_DESC
oObjeto:DiscountValue      := (cAliasSD2)->D2_DESCON
oObjeto:ExpensesValue      := (cAliasSD2)->D2_DESPESA
oObjeto:InsuranceValue     := (cAliasSD2)->D2_SEGURO
oObjeto:FreightValue       := (cAliasSD2)->D2_VALFRE

If !Empty((cAliasSD2)->D2_PEDIDO) 
	dbSelectArea("SC5")
	dbSetOrder(1)
	MsSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO)
	dbSelectArea("SC6")
	dbSetOrder(1)
	MsSeek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD)
	oObjeto:SalesOrder:=WsClassNew("SALESORDERITEMVIEW")
	GetPVItem(oObjeto:SalesOrder,"SC6","SC5")
	oObjeto:SalesOrder:QuantityDelivered := (cAliasSD2)->D2_QUANT
EndIf

If !Empty((cAliasSD2)->D2_LOTECTL) .Or. !Empty((cAliasSD2)->D2_NUMLOTE)
	oObjeto:LotIdentifier:LotNumber    := (cAliasSD2)->D2_LOTECTL+(cAliasSD2)->D2_NUMLOTE
	oObjeto:LotIdentifier:PotencyLot   := (cAliasSD2)->D2_POTENCI 
	oObjeto:LotIdentifier:ValidityDate := (cAliasSD2)->D2_DTVALID
EndIf

UserFields("SD2",@oObjeto:UserFields,cAliasSD2)
RestArea(aArea)

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSMAT_RM  ³ Autor ³Alexandre Silva        ³ Data ³12.02.2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service responsavel pelos documentos de entrada/saida    ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Definicao do Web Service                                                ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
WSSERVICE MtSupplierRemission     DESCRIPTION STR0006 //"Servico de consulta e atualizacao dos documentos de entrada e saida ( <b>Restricao de fornecedor<b> )"
WSDATA HeaderType               As String
WSDATA Header                   As Array Of BrwHeader
WSDATA UserCode                 As String
WSDATA RegisterDateFrom         As Date 	OPTIONAL
WSDATA RegisterDateTo           As Date 	OPTIONAL
WSDATA DeliveryDateFrom         As Date 	OPTIONAL
WSDATA DeliveryDateTo           As Date 	OPTIONAL
WSDATA PurchaseNumber           As String 	OPTIONAL
WSDATA CustomerOrSupplier       As Integer
WSDATA CustomerOrSupplierID     As String
WSDATA CustomerOrSupplierType   As String
WSDATA SerialNumber             As String
WSDATA RemissionNumber          As String
WSDATA RemissionType            As String
WSDATA RemissionHeader          As Array Of RemissionHeaderView
WSDATA Remission                As RemissionView
WSDATA WsNull                   As String
WSDATA QueryAddWhereRme         As String OPTIONAL
WSDATA QueryAddWhereRms         As String OPTIONAL
WSDATA IndexKeyRme              As String OPTIONAL
WSDATA IndexKeyRms              As String OPTIONAL

WSMETHOD GetHeader           	DESCRIPTION STR0002//"Método que descreve as estruturas de retorno do serviço"
WSMETHOD BrwRemission          	DESCRIPTION STR0003//"Método de listagem dos documentos de entrada ou saida"
WSMETHOD GetRemission          	DESCRIPTION STR0004//"Método de consulta as informações do documento de entrada ou saida"

ENDWSSERVICE

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetHeader ³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao do header                              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Estrutura                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve o header de uma estrutura                ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GetHeader WSRECEIVE HeaderType WSSEND Header WSSERVICE MtSupplierRemission

::Header := MtHeader(::HeaderType)
If Empty(::Header)
	::Header := FinHeader(::HeaderType)
EndIf

Return(.T.)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BrwPurchas³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao dos documentos de entrada e saida      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Fornecedor                                            ³±±
±±³          ³ExpD3: Data Inicial                                          ³±±
±±³          ³ExpD4: Data Final                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve as cotacaoes em aberto do fornecedor     ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD BrwRemission WSRECEIVE UserCode,CustomerOrSupplier,CustomerOrSupplierID,RegisterDateFrom,RegisterDateTo,DeliveryDateFrom,DeliveryDateTo,QueryAddWhereRme,QueryAddWhereRms,IndexKeyRme,IndexKeyRms,PurchaseNumber WSSEND RemissionHeader WSSERVICE MtSupplierRemission

Local aArea    := GetArea()
Local lRetorno := .T.
Local lQuery   := .F.
Local lValido  := .F.
Local nX       := 0
Local cArquivo := ""
Local cQuery   := ""
Local cAliasSF1:= "SF1"
Local cAliasSF2:= "SF2"
Local cFornece := SubStr(::CustomerOrSupplierID,1,Len(SA2->A2_COD))
Local cLojaFor := SubStr(::CustomerOrSupplierID,Len(SA2->A2_COD)+1)
Local cCliente := SubStr(::CustomerOrSupplierID,1,Len(SA1->A1_COD))
Local cLojaCli := SubStr(::CustomerOrSupplierID,Len(SA1->A1_COD)+1)
Local dEntrini := ::DeliveryDateFrom
Local dEntrFim := ::DeliveryDateTo
Local dEmisini := ::RegisterDateFrom
Local dEmisFim := ::RegisterDateTo
Local cAlias   := IIf(::CustomerOrSupplier==1,"SA1","SA2")
#IFDEF TOP
Local aCampos  := {}
Local aStruSF1 := {}
Local aStruSF2 := {}
Local cVolume  := ""
Local nY       := 0
#ENDIF
DEFAULT dEntrIni := dDataBase-30
DEFAULT dEntrFim := dDataBase
DEFAULT dEmisIni := dDataBase-30
DEFAULT dEmisFim := dDataBase

If PrtChkUser(::UserCode,"MtSupplierRemission","BrwRemission",cAlias,::CustomerOrSupplierID)
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Pesquisa os documentos de entrada                                       ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SF1")
	dbSetOrder(2)
	#IFDEF TOP
		lQuery := .T.
		cAliasSF1 := "BRWRemission"
		aStruSF1  := SF1->(dbStruct())

		cQuery := "SELECT F1_FILIAL,F1_TIPO,F1_FORNECE,F1_LOJA,F1_DOC,F1_SERIE,F1_FORMUL, "
		cQuery += "F1_DTDIGIT,F1_EMISSAO,F1_VALBRUT,F1_DESPESA,F1_SEGURO,F1_FRETE, "
		aCampos := MaFisRefLd("SF1","NF")
		For nY := 1 To Len(aCampos)
			If !Empty(aCampos[nY][2])
				cQuery += aCampos[nY][2]+","
			EndIf
			If !Empty(aCampos[nY][3])
				cQuery += aCampos[nY][3]+","
			EndIf
			If !Empty(aCampos[nY][4])
				cQuery += aCampos[nY][4]+","
			EndIf
		Next nY
		cQuery += "F1_PREFIXO,F1_DUPL "
		cQuery += GetUserField("SF1")
		cQuery += "FROM "+RetSqlName("SF1")+" SF1 "
		If !Empty(::PurchaseNumber)
			cQuery += ","+RetSqlName("SD1")+" SD1 "
		EndIf
		cQuery += "WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND "
		If ::CustomerOrSupplier==1
			cQuery += "SF1.F1_FORNECE='"+cCliente+"' AND "
			cQuery += "SF1.F1_LOJA='"+cLojaCli+"' AND "
			cQuery += "SF1.F1_TIPO IN('D','B') AND "
		Else
			cQuery += "SF1.F1_FORNECE='"+cFornece+"' AND "
			cQuery += "SF1.F1_LOJA='"+cLojaFor+"' AND "
			cQuery += "SF1.F1_TIPO NOT IN('D','B') AND "			
		EndIf
		cQuery += "SF1.F1_EMISSAO >= '"+Dtos(dEmisIni)+"' AND "
		cQuery += "SF1.F1_EMISSAO <= '"+Dtos(dEmisFim)+"' AND "
		cQuery += "SF1.F1_DTDIGIT >= '"+Dtos(dEntrIni)+"' AND "
		cQuery += "SF1.F1_DTDIGIT <= '"+Dtos(dEntrFim)+"' AND "
		cQuery += "SF1.F1_TIPODOC > '49' AND "
		cQuery += "SF1.D_E_L_E_T_=' ' "
		If !Empty(::PurchaseNumber)
			cQuery += " AND "
			cQuery += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery += "SD1.D1_DOC = SF1.F1_DOC AND "
			cQuery += "SD1.D1_SERIE = SF1.F1_SERIE AND "
			cQuery += "SD1.D1_FORNECE = SF1.F1_FORNECE AND "
			cQuery += "SD1.D1_LOJA = SF1.F1_LOJA AND "
			cQuery += "SD1.D1_TIPO = SF1.F1_TIPO AND "
			cQuery += "SD1.D1_PEDIDO = '"+::PurchaseNumber+"' AND "
			cQuery += "SD1.D_E_L_E_T_=' ' "
		EndIf
		cQuery := WsQueryAdd(cQuery,::QueryAddWhereRme)
		cQuery += "ORDER BY "+WsSqlOrder(IIf(Empty(::IndexKeyRme),SF1->(IndexKey()),::IndexKeyRme))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF1)

		For nY := 1 To Len(aStruSF1)
			If aStruSF1[nY][2] <> "C" .And. aStruSF1[nY][2] <> "M"
				TcSetField(cAliasSF1,aStruSF1[nY][1],aStruSF1[nY][2],aStruSF1[nY][3],aStruSF1[nY][4])
			EndIf		
		Next nY

	#ELSE
		cArquivo := CriaTrab(,.F.)
		cQuery := "F1_FILIAL='"+xFilial("SF1")+"' .AND. "
		cQuery += "F1_FORNECE = '"+cFornece+"' .AND. "
		cQuery += "F1_LOJA = '"+cLojaFor+"' .AND. "		
		cQuery += "F1_TIPODOC > '49' .AND. "		
		cQuery += "DToS(F1_EMISSAO) >= '"+Dtos(dEmisIni)+"' .AND. "
		cQuery += "DToS(F1_EMISSAO) <= '"+Dtos(dEmisFim)+"' .AND. "
		cQuery += "DToS(F1_DTDIGIT) >= '"+Dtos(dEntrIni)+"' .AND. "
		cQuery += "DToS(F1_DTDIGIT) <= '"+Dtos(dEntrFim)+"' "	

		IndRegua("SF1",cArquivo,IIf(Empty(::IndexKeyRme),SF1->(IndexKey()),::IndexKeyRme),,cQuery)
		dbGotop()

	#ENDIF
	nX := 0
	DEFAULT ::RemissionHeader := {}
	While !Eof() .And. xFilial("SF1") == (cAliasSF1)->F1_FILIAL .And.;
			cFornece+cLojaFor == (cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA

		If IIf(::CustomerOrSupplier==1,(cAliasSF1)->F1_TIPO $ 'DB',!(cAliasSF1)->F1_TIPO $ 'DB') .And.;
				(cAliasSF1)->F1_EMISSAO >= dEmisIni .And.;
				(cAliasSF1)->F1_EMISSAO <= dEmisFim .And.;
				(cAliasSF1)->F1_DTDIGIT >= dEntrIni .And.;
				(cAliasSF1)->F1_DTDIGIT <= dEntrFim	
			
			If lQuery
				lValido := .T.
			Else		
				If Empty(::PurchaseNumber)
					lValido := .T.
				Else
					lValido := .F.
					dbSelectArea("SD1")
					dbSetOrder(1)
					MsSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
					While !Eof() .And.;
						xFilial("SD1") == SD1->D1_FILIAL .And.;
						(cAliasSF1)->F1_DOC == SD1->D1_DOC .And.;
						(cAliasSF1)->F1_SERIE == SD1->D1_SERIE .And.;
						(cAliasSF1)->F1_FORNECE == SD1->D1_FORNECE .And.;
						(cAliasSF1)->F1_LOJA == SD1->D1_LOJA

						If SD1->D1_TIPO == (cAliasSF1)->F1_TIPO .And.;
							SD1->D1_FORMUL == (cAliasSF1)->F1_FORMUL .And.;
							SD1->D1_PEDIDO == ::PurchaseNumber
							
							lValido := .T.
				 			Exit			
						EndIf
						
						dbSelectArea("SD1")
						dbSkip()
						
					EndDo
				EndIf
			EndIf
			If lValido
				aadd(::RemissionHeader,WsClassNew("RemissionHeaderView"))
				nX++
				GetRmEHead(@::RemissionHeader[nX],cAliasSF1)
			EndIf
		EndIf
		dbSelectArea(cAliasSF1)		
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSF1)		
		dbCloseArea()	
		dbSelectArea("SF1")
	Else
		dbSelectArea("SF1")
		RetIndex("SF1")
		FErase(cArquivo+OrdBagExt())
	EndIf
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Pesquisa os documentos de saida                                         ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SF2")
	dbSetOrder(2)
	#IFDEF TOP
		lQuery := .T.
		cAliasSF2 := "BRWRemission"
		aStruSF2  := SF2->(dbStruct())

		cQuery := "SELECT F2_FILIAL,F2_TIPO,F2_CLIENTE,F2_LOJA,F2_DOC,F2_SERIE, "
		cQuery += "F2_EMISSAO,F2_VALBRUT,F2_DESPESA,F2_SEGURO,F2_FRETE,F2_TRANSP, "
		aCampos := MaFisRefLd("SF2","NF")
		For nY := 1 To Len(aCampos)
			If !Empty(aCampos[nY][2])
				cQuery += aCampos[nY][2]+","
			EndIf
			If !Empty(aCampos[nY][3])
				cQuery += aCampos[nY][3]+","
			EndIf
			If !Empty(aCampos[nY][4])
				cQuery += aCampos[nY][4]+","
			EndIf
		Next nY
		cVolume := "1"
		While SF2->(FieldPos("F2_ESPECI"+cVolume))<>0 .And. !Empty(SF2->(FieldGet(FieldPos("F2_ESPECI"+cVolume))))
			cQuery += "F2_ESPECI"+cVolume+","+"F2_ESPECI"+cVolume+","
		 	cVolume := Soma1( cVolume )
		EndDo
		cQuery += "F2_PREFIXO,F2_DUPL "
		cQuery += GetUserField("SF2")
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		If !Empty(::PurchaseNumber)
			cQuery += ","+RetSqlName("SD2")+" SD2 "
		EndIf
		cQuery += "WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
		If ::CustomerOrSupplier==1
			cQuery += "SF2.F2_CLIENTE='"+cCliente+"' AND "
			cQuery += "SF2.F2_LOJA='"+cLojaCli+"' AND "
			cQuery += "SF2.F2_TIPO NOT IN('D','B') AND "
		Else
			cQuery += "SF2.F2_CLIENTE='"+cFornece+"' AND "
			cQuery += "SF2.F2_LOJA='"+cLojaFor+"' AND "
			cQuery += "SF2.F2_TIPO IN('D','B') AND "			
		EndIf
		cQuery += "SF2.F2_TIPODOC > '49' AND "
		cQuery += "SF2.F2_EMISSAO >= '"+Dtos(dEmisIni)+"' AND "
		cQuery += "SF2.F2_EMISSAO <= '"+Dtos(dEmisFim)+"' AND "
		cQuery += "SF2.F2_EMISSAO >= '"+Dtos(dEntrIni)+"' AND "
		cQuery += "SF2.F2_EMISSAO <= '"+Dtos(dEntrFim)+"' AND "
		cQuery += "SF2.D_E_L_E_T_=' ' "
		If !Empty(::PurchaseNumber)
			cQuery += " AND "
			cQuery += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
			cQuery += "SD2.D2_DOC = SF2.F2_DOC AND "
			cQuery += "SD2.D2_SERIE = SF2.F2_SERIE AND "
			cQuery += "SD2.D2_CLIENTE = SF2.F2_CLIENTE AND "
			cQuery += "SD2.D2_LOJA = SF2.F2_LOJA AND "
			cQuery += "SD2.D2_PEDIDO = '"+::PurchaseNumber+"' AND "
			cQuery += "SD2.D_E_L_E_T_=' ' "
		EndIf		
		cQuery := WsQueryAdd(cQuery,::QueryAddWhereRms)
		cQuery += "ORDER BY "+WsSqlOrder(IIf(Empty(::IndexKeyRms),SF2->(IndexKey()),::IndexKeyRms))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2)

		For nY := 1 To Len(aStruSF2)
			If aStruSF2[nY][2] <> "C" .And. aStruSF2[nY][2] <> "M"
				TcSetField(cAliasSF2,aStruSF2[nY][1],aStruSF2[nY][2],aStruSF2[nY][3],aStruSF2[nY][4])
			EndIf		
		Next nY

	#ELSE
		cArquivo := CriaTrab(,.F.)
		cQuery := "F2_FILIAL='"+xFilial("SF2")+"' .AND. "
		cQuery += "F2_CLIENTE = '"+cCliente+"' .AND. "
		cQuery += "F2_LOJA = '"+cLojaCli+"' .AND. "
		cQuery += "F2_TIPODOC > '49' .AND. "
		cQuery += "DToS(F2_EMISSAO) >= '"+Dtos(dEmisIni)+"' .AND. "
		cQuery += "DToS(F2_EMISSAO) <= '"+Dtos(dEmisFim)+"' .AND. "
		cQuery += "DToS(F2_EMISSAO) >= '"+Dtos(dEntrIni)+"' .AND. "
		cQuery += "DToS(F2_EMISSAO) <= '"+Dtos(dEntrFim)+"' "	

		IndRegua("SF2",cArquivo,IIf(Empty(::IndexKeyRms),SF2->(IndexKey()),::IndexKeyRms),,cQuery)
		dbGotop()
	#ENDIF
	DEFAULT ::RemissionHeader := {}	
	While !Eof() .And. xFilial("SF2") == (cAliasSF2)->F2_FILIAL .And.;
			cCliente+cLojaCli == (cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA

		If IIf(::CustomerOrSupplier==1,!(cAliasSF2)->F2_TIPO $ 'DB',(cAliasSF2)->F2_TIPO $ 'DB') .And.;
				(cAliasSF2)->F2_EMISSAO >= dEmisIni .And.;
				(cAliasSF2)->F2_EMISSAO <= dEmisFim .And.;
				(cAliasSF2)->F2_EMISSAO >= dEntrIni .And.;
				(cAliasSF2)->F2_EMISSAO <= dEntrFim
			If lQuery
				lValido := .T.
			Else
				If Empty(::PurchaseNumber)
					lValido := .T.
				Else
					dbSelectArea("SD2")
					dbSetOrder(1)
					MsSeek(xFilial("SD2")+(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
					While !Eof() .And.;
						xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
						(cAliasSF2)->F2_DOC == (cAliasSD2)->D2_DOC .And.;
						(cAliasSF2)->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
						(cAliasSF2)->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And.;
						(cAliasSF2)->F2_LOJA == (cAliasSD2)->D2_LOJA
				
						If (cAliasSD2)->D2_PEDIDO == ::PurchaseNumber
							lValido := .T.
							Exit
						EndIf
						dbSelectArea(cAliasSD2)
						dbSkip()			
					EndDo
				EndIf
			EndIf
			If lValido
				aadd(::RemissionHeader,WsClassNew("RemissionHeaderView"))
				nX++
				GetRmSHead(@::RemissionHeader[nX],cAliasSF2)
			EndIf
		EndIf		
		dbSelectArea(cAliasSF2)		
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSF2)		
		dbCloseArea()	
		dbSelectArea("SF2")
	Else
		dbSelectArea("SF2")
		RetIndex("SF2")
		FErase(cArquivo+OrdBagExt())	
	EndIf
Else
	lRetorno := .F.
EndIf

RestArea(aArea)

Return(lRetorno)

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetRemission³Autor  ³ Alexandre Silva       ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao dos documento de entrada / saida         ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                       ³±±
±±³          ³ExpC2: Tipo do documento de entrada/saida                      ³±±
±±³          ³ExpC3: Numero de Serie                                         ³±±
±±³          ³ExpC4: Numero do documento                                     ³±±
±±³          ³ExpC5: Formulario Proprio?                                     ³±±
±±³          ³ExpN6: 1-Cliente ou 2-Fornecedor                               ³±±
±±³          ³ExpC6: Codigo do cliente ou fornecedor                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o metodo foi avaliado com sucesso            ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este metodo devolve os documentos de entrad ou saida           ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GetRemission WSRECEIVE UserCode,RemissionType,SerialNumber,RemissionNumber,CustomerOrSupplier,CustomerOrSupplierID,QueryAddWhereRme,QueryAddWhereRms WSSEND Remission WSSERVICE MtSupplierRemission

Local aArea    := GetArea()

Local cAlias   := IIf(::CustomerOrSupplier==1,"SA1","SA2")
Local cES      := SubStr(::RemissionType,1,1)
Local cFornece := SubStr(::CustomerOrSupplierID,1,Len(SA2->A2_COD))
Local cLojaFor := SubStr(::CustomerOrSupplierID,Len(SA2->A2_COD)+1)
Local cCliente := SubStr(::CustomerOrSupplierID,1,Len(SA1->A1_COD))
Local cLojaCli := SubStr(::CustomerOrSupplierID,Len(SA1->A1_COD)+1)
Local cSerie   := SubStr(::SerialNumber,1,Len(SD1->D1_SERIE))
Local cDoc     := SubStr(::RemissionNumber,1,Len(SD1->D1_DOC))
Local cTipo    := AllTrim(SubStr(::RemissionType,3))
Local cAliasSD1:= "SD1"
Local cAliasSD2:= "SD2"
Local nX       := 0
Local lQuery   := .F.
Local lRetorno := .F.
#IFDEF TOP
Local aStruSD1 := {}
Local aStruSD2 := {}
Local cQuery   := ""
Local nY       := 0
#ENDIF

If PrtChkUser(::UserCode,"MtSupplierRemission","GetRemission",cAlias,::CustomerOrSupplierID)
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Verifica se qual o tipo de documento                                    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If cES == "E"
		dbSelectArea("SF1")
		dbSetOrder(1)
		MsSeek(xFilial("SF1")+cDoc+cSerie+cFornece+cLojaFor+cTipo)
		While !Eof() .And. xFilial("SF1") == SF1->F1_FILIAL .And.;
			cDoc == SF1->F1_DOC .And.;
			cSerie == SF1->F1_SERIE .And.;
			cFornece == SF1->F1_FORNECE .And.;
			cLojaFor == SF1->F1_LOJA .And.;
			cTipo == SF1->F1_TIPO 
				lRetorno := .T.			
				Exit
			dbSelectArea("SF1")
			dbSkip()
		EndDo
		If lRetorno
			::Remission:RemissionHeader := WsClassNew("RemissionHeaderView")
			GetRmEHead(@::Remission:RemissionHeader,"SF1")
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Pesquisa os Itens do documento de entrada                               ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			::Remission:RemissionItem:= {}
			dbSelectArea("SD1")
			dbSetOrder(1)
			#IFDEF TOP
				aStruSD1 := SD1->(dbStruct())
				lQuery   := .T.
				cAliasSD1:= "GETRemission"
				
				cQuery := "SELECT * "
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
				cQuery += "SD1.D1_DOC='"+cDoc+"' AND "
				cQuery += "SD1.D1_SERIE='"+cSerie+"' AND "
				cQuery += "SD1.D1_FORNECE='"+cFornece+"' AND "
				cQuery += "SD1.D1_LOJA='"+cLojaFor+"' AND "	
				cQuery += "SD1.D1_TIPO='"+cTipo+"' AND "
				cQuery += "SD1.D_E_L_E_T_=' ' "
				cQuery := WsQueryAdd(cQuery,::QueryAddWhereRme)
				cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
				
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1)
				
				For nY := 1 To Len(aStruSD1)
					If aStruSD1[nY][2] <> "C" .And. aStruSD1[nY][2] <> "M"
						TcSetField(cAliasSD1,aStruSD1[nY][1],aStruSD1[nY][2],aStruSD1[nY][3],aStruSD1[nY][4])
					EndIf
				Next nY
						
			#ELSE
				MsSeek(xFilial("SD1")+cDoc+cSerie+cFornece+cLojaFor)
			#ENDIF
			nX := 0
			While !Eof() .And.;
				xFilial("SD1") == (cAliasSD1)->D1_FILIAL .And.;
				cDoc == (cAliasSD1)->D1_DOC .And.;
				cSerie == (cAliasSD1)->D1_SERIE .And.;
				cFornece == (cAliasSD1)->D1_FORNECE .And.;
				cLojaFor == (cAliasSD1)->D1_LOJA
				
				If (cAliasSD1)->D1_TIPO == cTipo 
					If nX == 0
	    				::Remission:RemissionItem:= {}
					EndIf
					aadd(::Remission:RemissionItem,WsClassNew("RemissionItemView"))
					nX++
					GetRmEItem(@::Remission:RemissionItem[nX],cAliasSD1)
				EndIf
				dbSelectArea(cAliasSD1)
				dbSkip()			
			EndDo
			If lQuery
				dbSelectArea(cAliasSD1)
				dbCloseArea()
				dbSelectArea("SD1")
			EndIf
		EndIf
	Else
		dbSelectArea("SF2")
		dbSetOrder(1)
		If MsSeek(xFilial("SF2")+cDoc+cSerie+cCliente+cLojaCli)
			lRetorno := .T.
			::Remission:RemissionHeader := WsClassNew("RemissionHeaderView")
			GetRmSHead(@::Remission:RemissionHeader,"SF2")		
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Pesquisa os Itens do documento de saida                                 ³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			::Remission:RemissionItem:= {}
			dbSelectArea("SD2")
			dbSetOrder(3)
			#IFDEF TOP
				aStruSD2 := SD2->(dbStruct())
				lQuery   := .T.
				cAliasSD2:= "GETRemission"
				
				cQuery := "SELECT * "
				cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
				cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
				cQuery += "SD2.D2_DOC='"+cDoc+"' AND "
				cQuery += "SD2.D2_SERIE='"+cSerie+"' AND "
				cQuery += "SD2.D2_CLIENTE='"+cCliente+"' AND "
				cQuery += "SD2.D2_LOJA='"+cLojaCli+"' AND "	
				cQuery += "SD2.D2_TIPO='"+cTipo+"' AND "
				cQuery += "SD2.D_E_L_E_T_=' ' "
				cQuery := WsQueryAdd(cQuery,::QueryAddWhereRms)
				cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))
				
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2)
				
				For nY := 1 To Len(aStruSD2)
					If aStruSD2[nY][2] <> "C" .And. aStruSD2[nY][2] <> "M"
						TcSetField(cAliasSD2,aStruSD2[nY][1],aStruSD2[nY][2],aStruSD2[nY][3],aStruSD2[nY][4])
					EndIf
				Next nY
						
			#ELSE
				MsSeek(xFilial("SD2")+cDoc+cSerie+cCliente+cLojaCli)
			#ENDIF
			nX := 0
			While !Eof() .And.;
				xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
				cDoc == (cAliasSD2)->D2_DOC .And.;
				cSerie == (cAliasSD2)->D2_SERIE .And.;
				cFornece == (cAliasSD2)->D2_CLIENTE .And.;
				cLojaFor == (cAliasSD2)->D2_LOJA
				
				If (cAliasSD2)->D2_TIPO == cTipo 
					If nX == 0
	    				::Remission:RemissionItem:= {}
					EndIf
					aadd(::Remission:RemissionItem,WsClassNew("RemissionItemView"))
					nX++
					GetRmSItem(@::Remission:RemissionItem[nX],cAliasSD2)
				EndIf
				dbSelectArea(cAliasSD2)
				dbSkip()			
			EndDo
			If lQuery
				dbSelectArea(cAliasSD2)
				dbCloseArea()
				dbSelectArea("SD2")
			EndIf
		EndIf
	EndIf
	If !lRetorno
		SetSoapFault("GETRemission",STR0005)
	EndIf
Else
	lRetorno := .F.
EndIf

RestArea(aArea)

Return(lRetorno)
