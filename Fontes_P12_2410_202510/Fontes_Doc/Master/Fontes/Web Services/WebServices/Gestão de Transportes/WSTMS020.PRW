#INCLUDE "WSTMS020.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"                         
#INCLUDE "AP5MAIL.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSTMS020  ³ Autor ³Gustavo Almeida        ³ Data ³10.01.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service das funcionalidades do Portal TMS - Gestão de    ³±±
±±³          ³ Transportes.                                                 ³±±
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
WSSTRUCT RequestorView
	WSDATA ReDDD        AS String 
	WSDATA ReTel        AS String
	WSDATA ReCodSol     AS String 			  //-- Codigo Solicitante
	WSDATA ReName       AS String Optional    //-- Nome
	WSDATA ReTradeName  AS String Optional    //-- Nome Reduzido
	WSDATA ReAdressSeq  AS String Optional    //-- Sequencia de Endereco
	WSDATA ReAdress     AS String Optional    //-- Endereco
	WSDATA ReCity       AS String Optional    //-- Municipio
	WSDATA ReState      AS String Optional    //-- Estado
	WSDATA ReDistrict   AS String Optional    //-- Bairro
	WSDATA ReZip        AS String Optional    //-- CEP
	WSDATA ReAreaCode   AS String Optional    //-- Codigo Regiao Solicitante
	WSDATA ReAreaReq    AS String Optional    //-- Descricao da regiao do solicitante
ENDWSSTRUCT

WSSTRUCT PickupOrderView
	WSDATA PoHeader     AS PoHeaderView
	WSDATA PoItem       AS ARRAY OF PoItemView
ENDWSSTRUCT

WSSTRUCT PoHeaderView
	WSDATA PoDate       AS Date               //-- Data Solicitacao de Coleta
	WSDATA PoTime       AS String             //-- Hora Solicitacao de Coleta
	WSDATA PoDDD        AS String             //-- DDD Solicitante
	WSDATA PoTel        AS String             //-- Telefone Solicitante
	WSDATA PoCodSol     AS String Optional    //-- Codigo Solicitante
	WSDATA PoName       AS String Optional    //-- Nome
	WSDATA PoTradeName  AS String Optional    //-- Nome Reduzido
	WSDATA PoAdressSeq  AS String Optional    //-- Sequencia de Endereco
	WSDATA PoAdress     AS String Optional    //-- Endereco
	WSDATA PoCity       AS String Optional    //-- Municipio
	WSDATA PoState      AS String Optional    //-- Estado
	WSDATA PoDistrict   AS String Optional    //-- Bairro
	WSDATA PoZip        AS String Optional    //-- CEP
	WSDATA PoTransType  AS String             //-- Tipo de Transporte
	WSDATA PoAreaCode   AS String Optional    //-- Codigo Regiao de Origem
	WSDATA PoObs        AS String Optional    //-- Observacao
	WSDATA PoStatus     AS String Optional    //-- Status da Solicitação (Visualização)
ENDWSSTRUCT

WSSTRUCT PoItemView   
	WSDATA PoItem       AS String             //-- Item
	WSDATA PoProduct    AS String             //-- Codigo do Produto
	WSDATA PoPacking    AS String             //-- Codigo da Embalagem
	WSDATA PoVolQty     AS Float  Optional    //-- Qtde. de volume
	WSDATA PoWeight     AS Float  Optional    //-- Peso
	WSDATA PoWeight3    AS Float  Optional    //-- Peso Cubado
	WSDATA PoValGoods   AS Float  Optional    //-- Valor Mercadoria
ENDWSSTRUCT

WSSTRUCT PoBrowserView
	WSDATA PoBrwStatus  AS String             //-- Status da Solicitação   
	WSDATA PoBrwPoNumb  AS String             //-- Numero da Solicitação
	WSDATA PoBrwDate    AS Date               //-- Data Solicitacao de Coleta
	WSDATA PoBrwTime    AS String             //-- Hora Solicitacao de Coleta
ENDWSSTRUCT

WSSERVICE TMSPICKUPORDER DESCRIPTION STR0001 //"Serviço de Solicitação de Coleta"
	
	WSDATA PickupOrder AS PickupOrderView
	WSDATA Requestor   AS ARRAY OF RequestorView
	WSDATA Msg         AS String
	WSDATA UserCode    AS String
	WSDATA PoNumber    AS String
   WSDATA PoDateFrom  AS String Optional
	WSDATA PoDateTo    AS String
	WSDATA PoBrowser   AS ARRAY OF PoBrowserView
	 
	WSMETHOD GetRequestorView
	WSMETHOD PutPickupOrder
	WSMETHOD GetPickupOrder
	WSMETHOD BrwPickupOrder
	 
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetRequestorView ³ Autor ³Gustavo Almeida ³ Data ³04.02.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método que retorna os valores do cadastro de solicitante     ³±±
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
WSMETHOD GetRequestorView WSRECEIVE UserCode WSSEND Requestor WSSERVICE TMSPICKUPORDER

Local aAreaDUE := DUE->(GetArea())
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     := .T.

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet

	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFilial('DUE')+::UserCode))
		//-- Valores para cabeçalho
		aAdd(::Requestor,WSClassNew("RequestorView")) 
		::Requestor[1]:ReDDD       := DUE->DUE_DDD     
		::Requestor[1]:ReTel       := DUE->DUE_TEL     
		::Requestor[1]:ReCodSol    := DUE->DUE_CODSOL    
		::Requestor[1]:ReName      := DUE->DUE_NOME    
		::Requestor[1]:ReTradeName := DUE->DUE_NREDUZ  
		::Requestor[1]:ReAdress    := DUE->DUE_END     
		::Requestor[1]:ReCity      := DUE->DUE_MUN     
		::Requestor[1]:ReState     := DUE->DUE_EST     
		::Requestor[1]:ReDistrict  := DUE->DUE_BAIRRO  
		::Requestor[1]:ReZip       := DUE->DUE_CEP     
		::Requestor[1]:ReAreaCode  := DUE->DUE_CDRSOL  
		::Requestor[1]:ReAreaReq   := Posicione('DUY',1,xFilial('DUY')+DUE->DUE_CDRSOL,'DUY_DESCRI')
	EndIf   
	
EndIf

RestArea(aAreaDUE)
		 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ PutPickupOrder ³ Autor ³Gustavo Almeida  ³ Data ³03.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de Inclusão de dados de solicitação de coletas.       ³±±
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
WSMETHOD PutPickupOrder WSRECEIVE PickupOrder WSSEND Msg WSSERVICE TMSPICKUPORDER

Local aArea    := GetArea()
Local nI       := 0 
Local aCabec   := {}
Local aItens   := {}
Local aLinha   := {}
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     := .T.

Private lMsErroAuto := .F. 

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet

	Aadd(aCabec,{"DT5_DATSOL",::PickupOrder:PoHeader:PoDate,Nil})
	Aadd(aCabec,{"DT5_HORSOL",::PickupOrder:PoHeader:PoTime,Nil})	
	Aadd(aCabec,{"DT5_CODSOL"  ,::PickupOrder:PoHeader:PoCodSol,Nil})
	
	If !Empty(::PickupOrder:PoHeader:PoAdressSeq)
		Aadd(aCabec,{"DT5_SEQEND",::PickupOrder:PoHeader:PoAdressSeq,Nil})
	EndIf		
	
	Aadd(aCabec,{"DT5_CDRORI",::PickupOrder:PoHeader:PoAreaCode ,Nil})
	Aadd(aCabec,{"DT5_TIPTRA",::PickupOrder:PoHeader:PoTransType,Nil})
	Aadd(aCabec,{"DT5_OBS"   ,::PickupOrder:PoHeader:PoObs      ,Nil})
	Aadd(aCabec,{"DT5_CADPOR","1"                               ,Nil}) //-- Inclusão Efetuada via Portal 
	
	For nI := 1 To Len(::PickupOrder:PoItem)
		Aadd(aLinha,{"DUM_ITEM"  ,::PickupOrder:PoItem[nI]:PoItem    ,Nil})
		Aadd(aLinha,{"DUM_CODPRO",::PickupOrder:PoItem[nI]:PoProduct ,Nil})
		Aadd(aLinha,{"DUM_CODEMB",::PickupOrder:PoItem[nI]:PoPacking ,Nil})
		Aadd(aLinha,{"DUM_QTDVOL",::PickupOrder:PoItem[nI]:PoVolQty  ,Nil})
		Aadd(aLinha,{"DUM_PESO  ",::PickupOrder:PoItem[nI]:PoWeight  ,Nil})
		Aadd(aLinha,{"DUM_PESOM3",::PickupOrder:PoItem[nI]:PoWeight3 ,Nil})
		Aadd(aLinha,{"DUM_VALMER",::PickupOrder:PoItem[nI]:PoValGoods,Nil})
		Aadd(aItens,aLinha)
		aLinha := {}	
	Next 
	  
	Ferase(NomeAutoLog()) 
	
	MSExecAuto({|x,y,k,w,z| TMSA460(x,y,k,w,z)},aCabec,aItens,,,3)
	
	If lMsErroAuto
	   ::Msg := "<pre>"+MemoRead(NomeAutoLog())+"</pre>"
	   Ferase(NomeAutoLog())
	Else
		::Msg := STR0002+DT5->DT5_NUMSOL+STR0003  //"Solicitação de coleta No."###" inserida com sucesso!"
	EndIf
	
	RestArea(aArea)

EndIf

Return .T.
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ GetPickupOrder ³ Autor ³Gustavo Almeida  ³ Data ³21.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Método de Visualização da solicitação.                       ³±±
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
  
WSMETHOD GetPickupOrder WSRECEIVE UserCode, PoNumber WSSEND PickupOrder WSSERVICE TMSPICKUPORDER

Local aArea     := GetArea()
Local nX        := 0
Local cFilOri   := ""
Local cAliasQry := GetNextAlias()
Local cQuery    := "" 
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     := .T.
 
Private Inclui	:= .F.    

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet
	//-- Cabecalho        
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		cFilOri := Posicione('DUY',1,xFilial('DUY')+DUE->DUE_CDRSOL,'DUY_FILDES')
		DT5->(dbSetOrder(1))
		If DT5->(dbSeek(xFilial('DT5')+cFilOri+::PoNumber)) .And. (DT5->(DT5->DT5_CODSOL) == DUE->(DUE->DUE_CODSOL))
			::PickupOrder:PoHeader:PoDate         := DT5->DT5_DATSOL
			::PickupOrder:PoHeader:PoTime         := DT5->DT5_HORSOL
			::PickupOrder:PoHeader:PoCodSol       := DT5->DT5_CODSOL
			//-- Dados Cadastrais
			::PickupOrder:PoHeader:PoDDD          := DUE->DUE_DDD
			::PickupOrder:PoHeader:PoTel          := DUE->DUE_TEL 
			::PickupOrder:PoHeader:PoName         := DUE->DUE_NOME  
			::PickupOrder:PoHeader:PoTradeName    := DUE->DUE_NREDUZ  
			//-- Sequencia de Endereço
			If !Empty(DT5->DT5_SEQEND)
				::PickupOrder:PoHeader:PoAdressSeq := DT5->DT5_SEQEND
				::PickupOrder:PoHeader:PoAdress    := Posicione('DUL',3,xFilial('DUL')+DT5->DT5_CODSOL+DT5->DT5_SEQEND,'DUL_END')
				::PickupOrder:PoHeader:PoCity      := Posicione('DUL',3,xFilial('DUL')+DT5->DT5_CODSOL+DT5->DT5_SEQEND,'DUL_MUN')
				::PickupOrder:PoHeader:PoState     := Posicione('DUL',3,xFilial('DUL')+DT5->DT5_CODSOL+DT5->DT5_SEQEND,'DUL_EST')
				::PickupOrder:PoHeader:PoDistrict  := Posicione('DUL',3,xFilial('DUL')+DT5->DT5_CODSOL+DT5->DT5_SEQEND,'DUL_BAIRRO')
				::PickupOrder:PoHeader:PoZip       := Posicione('DUL',3,xFilial('DUL')+DT5->DT5_CODSOL+DT5->DT5_SEQEND,'DUL_CEP')
			Else
				::PickupOrder:PoHeader:PoAdress    := DUE->DUE_END
				::PickupOrder:PoHeader:PoCity      := DUE->DUE_MUN
				::PickupOrder:PoHeader:PoState     := DUE->DUE_EST
				::PickupOrder:PoHeader:PoDistrict  := DUE->DUE_BAIRRO
				::PickupOrder:PoHeader:PoZip       := DUE->DUE_CEP
			EndIf
			::PickupOrder:PoHeader:PoTransType    := DT5->DT5_TIPTRA
			::PickupOrder:PoHeader:PoAreaCode     := DT5->DT5_CDRORI
			::PickupOrder:PoHeader:PoStatus       := DT5->DT5_STATUS
			::PickupOrder:PoHeader:PoObs          := E_MSMM(DT5->DT5_CODOBS,80)
			
			//-- Itens
			cQuery := "SELECT DUM_ITEM, DUM_CODPRO, DUM_CODEMB, DUM_QTDVOL, DUM_PESO, DUM_PESOM3, DUM_VALMER"
			cQuery += " FROM  "
			cQuery += RetSqlName("DUM")
			cQuery += " WHERE DUM_FILIAL = '"+xFilial("DUM")+"'"
			cQuery += "   AND DUM_NUMSOL = '"+::PoNumber+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			
			While (cAliasQry)->(!Eof())
				aAdd(::PickupOrder:PoItem,WSClassNew("PoItemView"))
				nX++
				::PickupOrder:PoItem[nX]:PoItem     := (cAliasQry)->DUM_ITEM
				::PickupOrder:PoItem[nX]:PoProduct  := (cAliasQry)->DUM_CODPRO
				::PickupOrder:PoItem[nX]:PoPacking  := (cAliasQry)->DUM_CODEMB
				::PickupOrder:PoItem[nX]:PoVolQty   := (cAliasQry)->DUM_QTDVOL
				::PickupOrder:PoItem[nX]:PoWeight   := (cAliasQry)->DUM_PESO
				::PickupOrder:PoItem[nX]:PoWeight3  := (cAliasQry)->DUM_PESOM3
				::PickupOrder:PoItem[nX]:PoValGoods := (cAliasQry)->DUM_VALMER
				
				(cAliasQry)->(dbSkip())
					
			EndDo
			
			(cAliasQry)->(dbCloseArea())
			
		EndIf
	EndIf		
			
	RestArea(aArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Método    ³ BrwPickupOrder ³ Autor ³Gustavo Almeida  ³ Data ³22.02.2011  ³±±
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
WSMETHOD BrwPickupOrder WSRECEIVE UserCode, PoDateFrom, PoDateTo WSSEND PoBrowser WSSERVICE TMSPICKUPORDER

Local aArea     := GetArea()
Local nX        := 0
Local cAliasQry := GetNextAlias()
Local cQuery    := "" 
Local cUserDDD  := ""
Local cUserTel  := ""
Local lR5      := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao  := VAL(GetVersao(.F.))     // Indica a versao do Protheus  
Local lRet     := .T.
Local cUserCdSol := ""

If nVersao < 11 .OR. (nVersao == 11 .And. !lR5)
	lRet:= .F.
EndIf

If lRet

	//Usuario      
	DUE->(dbSetOrder(4))
	If DUE->(dbSeek(xFiliaL('DUE')+::UserCode))
		cUserDDD := DUE->DUE_DDD
		cUserTel := DUE->DUE_TEL
		cUserCdSol:= DUE->DUE_CODSOL
	EndIf
	
	//Solicitações Feita pelo Usuário
	cQuery := " SELECT DT5_STATUS, DT5_NUMSOL, DT5_DATSOL, DT5_HORSOL "
	cQuery += "   FROM "
	cQuery += RetSqlName("DT5")
	cQuery += "  WHERE DT5_FILIAL = '"+xFilial("DT5")+"' "
	cQuery += "    AND DT5_CODSOL = '"+cUserCdSol+"' " 
	cQuery += "    AND DT5_DATSOL BETWEEN '" + ::PoDateFrom + "' AND '" + ::PoDateTo + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cQuery += "  ORDER BY DT5_NUMSOL DESC "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	While (cAliasQry)->(!Eof())
	
		aAdd(::PoBrowser,WSClassNew("PoBrowserView"))
		nX++  
		
		::PoBrowser[nX]:PoBrwStatus:= (cAliasQry)->DT5_STATUS
		::PoBrowser[nX]:PoBrwPoNumb:= (cAliasQry)->DT5_NUMSOL
		::PoBrowser[nX]:PoBrwDate  := Stod((cAliasQry)->DT5_DATSOL)
		::PoBrowser[nX]:PoBrwTime  := (cAliasQry)->DT5_HORSOL
			
		(cAliasQry)->(dbSkip())
			
	EndDo
	
	(cAliasQry)->(dbCloseArea())
			
	RestArea(aArea)
EndIf

Return .T.
