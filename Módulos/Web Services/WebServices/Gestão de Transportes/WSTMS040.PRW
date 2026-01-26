#INCLUDE "WSTMS040.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"                         
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TMSCOTAG.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSTMS040  ³ Autor ³Gustavo Almeida        ³ Data ³08.03.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service das funcionalidades de cotação de frete do Portal³±±
±±³          ³ TMS - Gestão de Transportes.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSSTRUCT FreightQuotationView
	WSDATA FqHeader     AS FqHeaderView
	WSDATA FqItem       AS ARRAY OF FqItemView
	WSDATA FqCalc       AS FqCalculationView    Optional    //-- Valor De Frete
ENDWSSTRUCT

WSSTRUCT FqHeaderView
	WSDATA FqDate       AS Date               //-- Data Cotação de frete
	WSDATA FqTime       AS String             //-- Hora Cotação de frete
	WSDATA FqDDD        AS String             //-- DDD Solicitante
	WSDATA FqTel        AS String             //-- Telefone Solicitante
   WSDATA FqSrceRegCod AS String             //-- Cód. Região de Origem
   WSDATA FqTrgtRegCod AS String             //-- Cód. Região de Destino
   WSDATA FqTransServ  AS String             //-- Serviço de Transporte
   WSDATA FqTransType  AS String             //-- Tipo de Transporte
   WSDATA FqFreightTyp AS String             //-- Tipo de Frete
   WSDATA FqValidTerm  AS Date               //-- Prazo de Validade
	WSDATA FqObs        AS String Optional    //-- Observacao
	WSDATA FqStatus     AS String Optional    //-- Status da Cotação
	WSDATA FqCodSol     AS String             //-- Codigo Solicitante
ENDWSSTRUCT

WSSTRUCT FqItemView   
	WSDATA FqItem       AS String             //-- Item
	WSDATA FqProduct    AS String             //-- Codigo do Produto
	WSDATA FqPacking    AS String             //-- Codigo da Embalagem
	WSDATA FqVolQty     AS Float  Optional    //-- Qtde. de volume
	WSDATA FqWeight     AS Float  Optional    //-- Peso
	WSDATA FqWeight3    AS Float  Optional    //-- Peso Cubado
	WSDATA FqValGoods   AS Float  Optional    //-- Valor Mercadoria
ENDWSSTRUCT

WSSTRUCT FqBrowserView
	WSDATA FqBrwStatus  AS String             //-- Status da Cotação   
	WSDATA FqBrwFqNumb  AS String             //-- Numero da Cotação de Frete
	WSDATA FqBrwDate    AS Date               //-- Data da Cotação de Frete
	WSDATA FqBrwTime    AS String             //-- Hora da Cotação de Frete
ENDWSSTRUCT

WSSTRUCT FqCalculationView
	WSDATA FqCalFreight     AS Float          //-- Valor de Frete Calculado
	WSDATA FqCalTax         AS Float          //-- Valor de Imposto Calculado
	WSDATA FqCalFreightTax  AS Float          //-- Valor de Frete + Imposto Calculado
ENDWSSTRUCT

//-- Web Service estrutura
WSSERVICE TMSFREIGHTQUOTATION DESCRIPTION STR0001 //"Serviço de Cotação de Frete"

	WSDATA FreightQuotation AS FreightQuotationView
	WSDATA FqCalculation    AS FqCalculationView
	WSDATA Msg              AS String
	WSDATA UserCode    		AS String
	WSDATA FqNumber    		AS String
   WSDATA FqDateFrom  		AS String Optional
	WSDATA FqDateTo    		AS String
	WSDATA FqBrowser   		AS ARRAY OF FqBrowserView
	
	WSMETHOD PutFreightQuotation
	WSMETHOD GetFreightQuotation
	WSMETHOD BrwFreightQuotation
	WSMETHOD ClcFreightQuotation
	 
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³PutFreightQuotation³ Autor ³Gustavo Almeida ³ Data ³14.03.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de inclusão de dados de cotação de frete.             ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/

WSMETHOD PutFreightQuotation WSRECEIVE UserCode, FreightQuotation WSSEND Msg WSSERVICE TMSFREIGHTQUOTATION

Local aArea      := GetArea()
Local aCotacao   := { {}, {}, {}, {}, {}, {} }
Local aColsAux   := {} 
Local aDados     := {}
Local aProdutos  := {} 
Local nCnt       := 0 
Local lPortTMS   := .T.
Local lMostra    := .F.
Local aItContrat := {}
Local aProdRep   := {}
Local lProdRep   := .F.
Local cFilOriDT4 := ""
Local cContriDT4 := ""  
Local cMemoDT4OBS:= ""
Local lR5        := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao    := VAL(GetVersao(.F.))     // Indica a versao do Protheus
Local lRet       := .T.

/* Novos para compatibilizar */
Private aRotina  := {}
Private Inclui	  := .F. 
Private aHeader  := {}
Private aCols    := {}
Private cCliDev  := ""
Private cLojDev  := ""
Private cCadastro:= ""

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf
                     
If lRet
	aRotina := {{},{},{"&Incluir","TMSA40Mnt",0,3,0,NIL}}
	
	//-- Cliente Genérico
	Ferase(NomeAutoLog())
	
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		M->DT4_CLIDEV := ""
		M->DT4_LOJDEV := ""
		M->DT4_CODSOL := DUE->DUE_CODSOL
		TMSA040Cli(@cCliDev,@cLojDev)
	
		If Empty(cCliDev) .Or. Empty(cLojDev)
			lRet := .F.
			::Msg := "<pre>"+MemoRead(NomeAutoLog())+"</pre>"
		EndIf
		
		//-- Serviço
		If lRet
		
			TMSPesqServ(,cCliDev,cLojDev,::FreightQuotation:FqHeader:FqTransServ,::FreightQuotation:FqHeader:FqTransType,@aItContrat,lMostra,::FreightQuotation:FqHeader:FqFreightTyp,,,,,,,,,,lPortTMS)
			
			If Len(aItContrat) == 0
				lRet := .F.
				::Msg := STR0004 //###"Erro ao localizar contrato para uso do portal"
			Else
				//-- Filial de Origem e Inscrição                                                                 
				DUE->(dbSetOrder(4))
				If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
					cFilOriDT4 := Posicione('DUY',1,xFilial('DUY')+DUE->DUE_CDRSOL,'DUY_FILDES')
					If Empty(DUE->DUE_INSCR) .Or. ("ISENT" $ UPPER(DUE->DUE_INSCR))
				   	cContriDT4 := "2" //-- Não Contribui
				   Else
				   	cContriDT4 := "1" //-- Contribui
				   EndIf 
				EndIf                                                                
				
				//-- Campo de Observação
				cMemoDT4OBS := MSMM(DT4->DT4_CODOBS,,,::FreightQuotation:FqHeader:FqObs,1,,,"DT4","DT4_CODOBS")                                                                 
				
				//-- Cabecalho da Cotacao
				aAdd( aDados, cFilOriDT4                                ) // Filial Origem
				aAdd( aDados, ::FreightQuotation:FqHeader:FqCodSol      ) // Cod.Solicitante
				aAdd( aDados, ::FreightQuotation:FqHeader:FqFreightTyp  ) // Tipo Frete
				aAdd( aDados, "1"                                       ) // Seleciona Regiao
				aAdd( aDados, ::FreightQuotation:FqHeader:FqSrceRegCod  ) // Regiao Origem
				aAdd( aDados, ::FreightQuotation:FqHeader:FqTrgtRegCod  ) // Regiao Destino
				aAdd( aDados, ::FreightQuotation:FqHeader:FqTransServ   ) // Entrega
				aAdd( aDados, ::FreightQuotation:FqHeader:FqTransType   ) // Tipo Transporte
				aAdd( aDados, aItContrat[1][3]                          ) // Servico
				aAdd( aDados, ""                                        ) // Remetente
				aAdd( aDados, ""                                        ) // Loja Remetente
				aAdd( aDados, ""                                        ) // Destinatario
				aAdd( aDados, ""                                        ) // Loja Destinatario
				aAdd( aDados, ""                                        ) // Devedor
				aAdd( aDados, ""                                        ) // Loja Devedor
				aAdd( aDados, ""                                        ) // Solicitacao 
				aAdd( aDados,  0                                        ) // Total da Distancia 
				aAdd( aDados, "2"                                       ) // Distancia Ida/Volta 
				aAdd( aDados, cContriDT4                                ) // Contribuinte
				aAdd( aDados, cMemoDT4OBS                               ) // Observações
				
				aCotacao[DADOSCOT] := AClone(aDados) //-- Dados do cabecalho da cotacao
				
				For nCnt := 1 To Len(::FreightQuotation:FqItem)
				
					cCodProd := ::FreightQuotation:FqItem[nCnt]:FqProduct
					
					If Ascan(aProdRep, {|x| x == cCodProd }) > 0 .And. lProdRep == .F.
						lProdRep := .T.
					Else
					   aAdd(aProdRep,cCodProd)
					EndIf
					
					cCodEmb  := ::FreightQuotation:FqItem[nCnt]:FqPacking
					
					If (nPos := Ascan(aColsAux,{ | e | e[1] == cCodProd })) == 0
						aAdd(aColsAux,Array(8))
						nPos := Len(aColsAux)
						Afill(aColsAux[nPos],0)
						aColsAux[nPos,1] := cCodProd
						aColsAux[nPos,2] := cCodEmb
					EndIf	
					
					
					aColsAux[nPos,3] += ::FreightQuotation:FqItem[nCnt]:FqVolQty
					aColsAux[nPos,4] += 0 
					aColsAux[nPos,5] += ::FreightQuotation:FqItem[nCnt]:FqWeight
					aColsAux[nPos,6] += ::FreightQuotation:FqItem[nCnt]:FqWeight3
					aColsAux[nPos,7] += 0
					aColsAux[nPos,8] += ::FreightQuotation:FqItem[nCnt]:FqValGoods
					 
				Next nCnt
							
				// Soma produtos e valores (volume, unitizadores, peso real, peso cubado, vlr mercadoria)
				For nCnt := 1 To Len(aColsAux)
					aDados := {}
					AAdd(aDados,StrZero(nCnt,2))                            // Item da cotacao
					AAdd(aDados,::FreightQuotation:FqItem[nCnt]:FqProduct)  // Codigo Produto
					AAdd(aDados,::FreightQuotation:FqItem[nCnt]:FqPacking)  // Cod.Embalagem
					AAdd(aDados,::FreightQuotation:FqItem[nCnt]:FqVolQty)   // Volumes
					AAdd(aDados,0)                                          // Unitizadores
					AAdd(aDados,::FreightQuotation:FqItem[nCnt]:FqWeight)   // Peso Real
					AAdd(aDados,::FreightQuotation:FqItem[nCnt]:FqWeight3)  // Peso Cubado
					AAdd(aDados,0)                                          // Metro Cubico
					AAdd(aDados,::FreightQuotation:FqItem[nCnt]:FqValGoods) // Valor da Mercadoria
					AAdd(aDados,.F.)                                        // Item deletado ou nao
					AAdd(aProdutos, AClone(aDados) )
				Next nCnt
				
				aCotacao[PRODCOT]   := AClone(aProdutos) //-- Produtos da cotacao 
				
				l040Auto := .T.
				Ferase(NomeAutoLog())
				
				If !lProdRep	          
					If (TMSA040Mnt( "DT4", 0, 3, , aCotacao, , CriaVar("DT4_NUMCOT",.F.), .F.)) == 0 
					
						::Msg := "<pre>"+MemoRead(NomeAutoLog())+"</pre>"
						Ferase(NomeAutoLog())
						
					Else 
						//-- Via Portal
						RecLock("DT4",.F.)
						DT4->DT4_CADPOR := "1"
					 	MsUnLock()
						
						::Msg := STR0002+DT4->DT4_NUMCOT+STR0003  //"Cotação de Frete No."###" inserida com sucesso!"
						
					EndIf
				Else 
					::Msg := STR0005 //###"Há produtos repetidos na cotação digitada, verifique!"
				EndIf		
					
				l040Auto := .F.
				
				RestArea(aArea)
			EndIf
		EndIf
	EndIf
EndIf

Return .T.
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³GetFreightQuotation³ Autor ³Gustavo Almeida ³ Data ³14.03.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de Visualização da Cotação de Frete.                  ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/

WSMETHOD GetFreightQuotation WSRECEIVE UserCode, FqNumber WSSEND FreightQuotation WSSERVICE TMSFREIGHTQUOTATION

Local aArea     := GetArea()
Local nX        := 0
Local cFilOri   := ""
Local cAliasQry := GetNextAlias()
Local cQuery    := "" 
Local nTValPas  := 0
Local nTValImp  := 0                                             
Local nTValTot  := 0 
Local lR5       := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet      := .T.

Private Inclui  := .F.
Private aFrete  := {}

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet

	//-- Cabecalho        
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		cFilOri := Posicione('DUY',1,xFilial('DUY')+DUE->DUE_CDRSOL,'DUY_FILDES')
		DT4->(dbSetOrder(1))
		If DT4->(dbSeek(xFilial('DT4')+cFilOri+::FqNumber)) .And. (DT4->DT4_CODSOL == DUE->DUE_CODSOL)
		    //-- Variavel de Liberação para itens
			::FreightQuotation:FqHeader:FqDate      := DT4->DT4_DATCOT
			::FreightQuotation:FqHeader:FqTime      := DT4->DT4_HORCOT
			::FreightQuotation:FqHeader:FqDDD       := DUE->DUE_DDD
			::FreightQuotation:FqHeader:FqTel       := DUE->DUE_TEL
			::FreightQuotation:FqHeader:FqSrceRegCod:= DT4->DT4_CDRORI
			::FreightQuotation:FqHeader:FqTrgtRegCod:= DT4->DT4_CDRDES
	      ::FreightQuotation:FqHeader:FqTransType := DT4->DT4_TIPTRA
	      ::FreightQuotation:FqHeader:FqTransServ := DT4->DT4_SERTMS
	      ::FreightQuotation:FqHeader:FqFreightTyp:= DT4->DT4_TIPFRE   
			::FreightQuotation:FqHeader:FqValidTerm := DT4->DT4_PRZVAL
			::FreightQuotation:FqHeader:FqObs       := E_MSMM(DT4->DT4_CODOBS,80)
			::FreightQuotation:FqHeader:FqStatus    := DT4->DT4_STATUS
			::FreightQuotation:FqHeader:FqCodSol    := DT4->DT4_CODSOL
			
			cQuery := "SELECT DVF_ITEM, DVF_CODPRO, DVF_CODEMB, DVF_QTDVOL, DVF_PESO, DVF_PESOM3, DVF_VALMER"
			cQuery += " FROM  "
			cQuery += RetSqlName("DVF")
			cQuery += " WHERE DVF_FILIAL = '"+xFilial("DVF")+"'"
			cQuery += "   AND DVF_NUMCOT = '"+::FqNumber+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
			While (cAliasQry)->(!Eof())
				aAdd(::FreightQuotation:FqItem,WSClassNew("FqItemView"))
				nX++
				::FreightQuotation:FqItem[nX]:FqItem    := (cAliasQry)->DVF_ITEM
				::FreightQuotation:FqItem[nX]:FqProduct := (cAliasQry)->DVF_CODPRO
				::FreightQuotation:FqItem[nX]:FqPacking := (cAliasQry)->DVF_CODEMB
				::FreightQuotation:FqItem[nX]:FqVolQty  := (cAliasQry)->DVF_QTDVOL
				::FreightQuotation:FqItem[nX]:FqWeight  := (cAliasQry)->DVF_PESO
				::FreightQuotation:FqItem[nX]:FqWeight3 := (cAliasQry)->DVF_PESOM3
				::FreightQuotation:FqItem[nX]:FqValGoods:= (cAliasQry)->DVF_VALMER
			
				(cAliasQry)->(dbSkip())
			
			EndDo
	
		(cAliasQry)->(dbCloseArea())
	
		//-- Obtem o total do frete da cotacao
		TmsViewFrt('2',cFilOri,::FqNumber, , , , , ,@nTValPas,@nTValImp,@nTValTot)
	
		::FreightQuotation:FqCalc:FqCalFreight    := nTValPas //-- Valor de Frete Calculado
		::FreightQuotation:FqCalc:FqCalTax        := nTValImp //-- Valor de Imposto Calculado
		::FreightQuotation:FqCalc:FqCalFreightTax := nTValTot //-- Valor de Frete + Imposto Calculado	
		EndIf
	EndIf		
	
	RestArea(aArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³BrwFreightQuotation³ Autor ³Gustavo Almeida ³ Data ³14.03.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de Listagem para consulta de todas as solicitações em ³±±
±±³          ³ aberto.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/ 
WSMETHOD BrwFreightQuotation WSRECEIVE UserCode, FqDateFrom, FqDateTo WSSEND FqBrowser WSSERVICE TMSFREIGHTQUOTATION

Local aArea     := GetArea()
Local nX        := 0
Local cAliasQry := GetNextAlias()
Local cQuery    := "" 
Local cUserDDD  := ""
Local cUserTel  := ""
Local lR5       := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet      := .T.
Local cCodSol   := ""

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet

	//Usuario      
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		cUserDDD := DUE->DUE_DDD
		cUserTel := DUE->DUE_TEL
		cCodSol  := DUE->DUE_CODSOL
	EndIf
	
	//Cotações feita pelo Usuário
	cQuery := "SELECT DT4_STATUS, DT4_NUMCOT, DT4_DATCOT, DT4_HORCOT"
	cQuery += " FROM  "
	cQuery += RetSqlName("DT4")
	cQuery += " WHERE DT4_FILIAL = '"+xFilial("DT4")+"'"
	cQuery += "   AND DT4_CODSOL = '"+cCodSol+"'" 
	cQuery += "   AND DT4_DATCOT BETWEEN '" + ::FqDateFrom + "' AND '" + ::FqDateTo + "' "
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DT4_NUMCOT DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	While (cAliasQry)->(!Eof())
	
		aAdd(::FqBrowser,WSClassNew("FqBrowserView"))
		nX++
		
		::FqBrowser[nX]:FqBrwStatus:= (cAliasQry)->DT4_STATUS
		::FqBrowser[nX]:FqBrwFqNumb:= (cAliasQry)->DT4_NUMCOT
		::FqBrowser[nX]:FqBrwDate  := Stod((cAliasQry)->DT4_DATCOT)
		::FqBrowser[nX]:FqBrwTime  := (cAliasQry)->DT4_HORCOT
			
		(cAliasQry)->(dbSkip())
			
	EndDo
	
	(cAliasQry)->(dbCloseArea())
			
	RestArea(aArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ClcFreightQuotation³ Autor ³Gustavo Almeida ³ Data ³14.03.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de calculo de frete para cotação.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Portal TMS                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
WSMETHOD ClcFreightQuotation WSRECEIVE UserCode, FreightQuotation WSSEND FqCalculation WSSERVICE TMSFREIGHTQUOTATION

Local aItContrat := {}
Local lMostra    := .F.
Local lRotAuto   := .T.
Local lPortTMS   := .T.
Local nOpcx      := 3
Local nX         := 0
Local lR5        := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao    := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet       := .T.

//-- Variaveis para TMSA040Atz()
Private lAprova   := .F.
Private Inclui    := .T.
Private aSetKey   := {}
Private aFrete    := {}
Private aHeader   := {}
Private aHeaderDVT:= {}
Private aCols     := {}
Private aColsDVT  := {}
Private aValInf   := {}
Private aCubagem  := {}
Private nTValPas  := 0
Private nTValImp  := 0
Private nTValTot  := 0
Private lCligen   := .T.
Private n         := 1
Private cCadastro := ""
Private cCliDev   := ""
Private cLojDev   := ""
Private oTValPas
Private aColsback 

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet

	RegToMemory("DT4",.T.)
	
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		M->DT4_DDD    := DUE->DUE_DDD
		M->DT4_TEL    := DUE->DUE_TEL
		M->DT4_CODSOL := DUE->DUE_CODSOL
		M->DT4_PESSOA := IIF(Len(DUE->DUE_CGC) > 11,"2","1")
		M->DT4_FILORI := Posicione('DUY',1,xFilial('DUY')+DUE->DUE_CDRSOL,'DUY_FILDES')
		M->DT4_SERTMS := ::FreightQuotation:FqHeader:FqTransServ
		M->DT4_TIPTRA := ::FreightQuotation:FqHeader:FqTransType
		M->DT4_CDRORI := ::FreightQuotation:FqHeader:FqSrceRegCod
		M->DT4_CDRDES := ::FreightQuotation:FqHeader:FqTrgtRegCod
		M->DT4_TIPFRE := ::FreightQuotation:FqHeader:FqFreightTyp
		If Empty(DUE->DUE_INSCR) .Or. ("ISENT" $ UPPER(DUE->DUE_INSCR))
	   	M->DT4_CONTRI := "2" //-- Não Contribui
	   Else
	   	M->DT4_CONTRI := "1" //-- Contribui
	   EndIf
	   
		TMSA040Cli(@cCliDev,@cLojDev)
	   
		If TMSPesqServ(,cCliDev,cLojDev,M->DT4_SERTMS,M->DT4_TIPTRA,@aItContrat,lMostra,M->DT4_TIPFRE,lRotAuto,,,,,,,,,lPortTMS)
	
			If  Len(aItContrat)>0
			   M->DT4_SERVIC := aItContrat[1][3]
		            
			   TMSFillGetDados( nOpcx, 'DVF', 1, xFilial('DVF') + 'z', { || DVF->DVF_FILIAL + DVF->DVF_FILORI } )
			          
			   For nX := 1 To Len(::FreightQuotation:FqItem)
			      
				GDFieldPut('DVF_ITEM',StrZero(nX,Len(DVF->DVF_ITEM)))
				GDFieldPut('DVF_CODPRO',::FreightQuotation:FqItem[nX]:FqProduct)
				GDFieldPut('DVF_CODEMB',::FreightQuotation:FqItem[nX]:FqPacking)
				GDFieldPut('DVF_QTDVOL',::FreightQuotation:FqItem[nX]:FqVolQty)
				GDFieldPut('DVF_PESO'  ,::FreightQuotation:FqItem[nX]:FqWeight)
				GDFieldPut('DVF_PESOM3',::FreightQuotation:FqItem[nX]:FqWeight3)
				GDFieldPut('DVF_VALMER',::FreightQuotation:FqItem[nX]:FqValGoods)
		         
		      	If !TMSA040Atz()
					::FqCalculation:FqCalFreight    := 0
					::FqCalculation:FqCalTax        := 0
				   	::FqCalculation:FqCalFreightTax := 0
			   	Else
					If nX > 1
					   	::FqCalculation:FqCalFreight    := ::FqCalculation:FqCalFreight + nTValPas
					   	::FqCalculation:FqCalTax        := ::FqCalculation:FqCalTax + nTValImp
					   	::FqCalculation:FqCalFreightTax := ::FqCalculation:FqCalFreightTax + nTValTot
					Else 
						::FqCalculation:FqCalFreight    := nTValPas
						::FqCalculation:FqCalTax        := nTValImp
						::FqCalculation:FqCalFreightTax := nTValTot
					EndIf
			   	EndIf
		      
			   Next nX                                           
	        Else 
        		::FqCalculation:FqCalFreight    := 0
			   	::FqCalculation:FqCalTax        := 0
			   	::FqCalculation:FqCalFreightTax := 0
			   	lRet:= .F.
	        EndIf          
		EndIf     
	EndIf                                          
EndIf

Return lRet
