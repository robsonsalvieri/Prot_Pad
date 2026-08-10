#include "protheus.ch" 
#DEFINE TAMMAXXML 400000  //- Tamanho maximo do XML em bytes
Static __nDias := iif ( Empty (GetNewPar("MV_AUTOEMI",30)),30,GetNewPar("MV_AUTOEMI",30)) //-- Dias retroativos para Auto-emissão
Static __nLote := iif ( Empty (GetNewPar("MV_MAXLOTE",30)),30,GetNewPar("MV_MAXLOTE",30)) //-- Número maximo por lote MV_MAXLOTE    
//----------------------------------------------------------------------
/*/{Protheus.doc} aNJTRetQuery
Retorna a query para o job de transmissão do auto NFS-e.

@param		cSerie	Serie a ser processada pelo job.

@author		Marcos Taranta
@since		27/11/2012
@version	12
/*/
//------------------------------------------------------------------- 
function aNJTRetQuery( cSerie,cTipo)
	Local nTranExt 	:= __nDias //-- Dias retroativos para emissão
	local dDatabase	:= Date()
	local dDataTran	:= SToD ("  /  /  ")   
	local	cRetorno	:= ""
	
	default	cSerie	:= ""
	default	cTipo	:= "1"


		
	dDataTran := dDataBase-nTranExt //Regua data limite
	
	cRetorno += " SELECT F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_CODNFE,F3_CODISS"
	cRetorno += " FROM "+RetSqlName("SF3")+" SF3 "
	cRetorno += " WHERE SF3.F3_DTCANC = '' AND "
	cRetorno += " F3_FILIAL = '" + xFilial( "SF3" ) + "' "
	cRetorno += " AND SF3.F3_ENTRADA >= '" + Dtos(dDataTran) + "' "
	cRetorno += " AND SF3.F3_CODRSEF <> 'T' "
	cRetorno += " AND SF3.F3_CODRET =  '        '"
	cRetorno += " AND SF3.F3_CODISS <> ' ' "
	cRetorno += " AND SF3.F3_CLIEFOR <> ' ' "
	cRetorno += " AND SF3.D_E_L_E_T_ = ' ' "
		
	if cTipo == "1"
	
		cRetorno += " AND SF3.F3_CFO >= '5' "
	
	else
	
		cRetorno += " AND SF3.F3_CFO < '5' "
	
	endif	

	cRetorno	+= " AND SF3.F3_SERIE = '" + cSerie + "' "
	
	cRetorno += " ORDER BY F3_NFISCAL "
	
return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} aNJMRetQuery
Retorna a query para o job de monitoramento do auto NFS-e.

@param		cSerie	Serie a ser processada pelo job.

@author		Sergio S. Fuzinaka
@since		29/11/2012
@version	12
/*/
//-------------------------------------------------------------------
Function aNJMRetQuery( cSerie )

Local cRetorno	:= ""
Local nMonExt 	:= __nDias //-- Dias retroativos para monitoramento
local dDatabase	:= Date()
local dDataMon	:= SToD ("  /  /  ")

Default cSerie	:= ""                                 
dDataMon := dDataBase-nMonExt //Regua data limite

cRetorno := "SELECT F3_NFISCAL "
cRetorno += " FROM "+RetSqlName("SF3")+" "
cRetorno += " WHERE "
cRetorno += " F3_FILIAL = '" + xFilial( "SF3" ) + "' "

cRetorno += " AND "

cRetorno += " SUBSTRING( F3_CFO, 1, 1 ) >= '5' "

cRetorno += " AND "

cRetorno += " F3_SERIE = '" + cSerie + "' "

cRetorno += " AND ( ( "

	cRetorno += " ( F3_CODRSEF = 'T' OR F3_CODRET = 'T' ) "
	cRetorno += " AND F3_ENTRADA >= '" + Dtos(dDataMon) + "' )"
	cRetorno += " OR (("
	cRetorno += " ( F3_CODRSEF <> ' ' AND F3_CODRET = 'T' ) "
	cRetorno += " OR "
	cRetorno += " ( F3_CODRSEF = 'C' AND F3_CODNFE <> '' )) "
	cRetorno += " AND F3_CODRET <> '333' AND F3_DTCANC >= '" + Dtos(dDataMon)  + "' ))"

cRetorno += " AND "

cRetorno += " D_E_L_E_T_ = ' ' "

cRetorno += " ORDER BY F3_NFISCAL "

Return( cRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} aNJCRetQuery
Retorna a query para o job de cancelamento do auto NFS-e.

@param		cSerie	Serie a ser processada pelo job.

@author		Sergio S. Fuzinaka
@since		29/11/2012
@version	12
/*/
//-------------------------------------------------------------------
Function aNJCRetQuery( cSerie, cTipo )

	Local cRetorno	:= ""
	Local nCancExt 	:= __nDias //-- Dias retroativos para cancelamento
	local dDatabase	:= Date()
	local dDataCanc	:= SToD ("  /  /  ")

	dDataCanc := dDataBase-nCancExt //Regua data limite			
	
	default cSerie	:= ""                                 
	default cTipo		:= "1"
	
	cRetorno := " SELECT F3_FILIAL,F3_ENTRADA,F3_NFeLETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_CODRSEF"
	cRetorno += " FROM "+retSqlname("SF3")+" SF3 "
	cRetorno += " WHERE "
	cRetorno += " SF3.F3_FILIAL		=  '" +xFilial("SF3")+ "' AND "
	cRetorno += " SF3.F3_SERIE		=  '" +cSerie        + "' AND "
	cRetorno += " SF3.F3_DTCANC		<> '" +space(8)      + "' AND "
	cRetorno += " SF3.F3_DTCANC		>= '" + Dtos(dDataCanc)  + "' AND "
	cRetorno += " SF3.D_E_L_E_T_	= ''"

	if cTipo == "1"
	
		cRetorno += " AND SUBSTRING(F3_CFO,1,1) >= '5' "
	
	else
	
		cRetorno += " AND( SUBSTRING(F3_CFO,1,1) < '5' "
	
	endif

	if SF3->(FieldPos("F3_CODRET")) > 0 .And. SF3->(FieldPos("F3_DESCRET")) > 0   
	
		cRetorno += " AND F3_CODRSEF = 'S' AND F3_CODRET = '111' "
	
	else
		cRetorno := ""
	endif	

Return( cRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} aNMRetDoc
Retorna array de documentos para monitoramento

@param		cAlias		Alias da query a ser processada

@author		Sergio S. Fuzinaka
@since		30/11/2012
@version	12
/*/
//-------------------------------------------------------------------
Function aNMRetDoc( cAlias )

Local aRetorno := {}

aRetorno := { (cAlias)->F3_NFISCAL }

Return( aRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} aNMExecProc
Executa o processo de monitoramento

@param		cAlias		Alias da query a ser processada

@author		Sergio S. Fuzinaka
@since		03.12.2012
@version	12
/*/
//-------------------------------------------------------------------
Function aNMExecProc( cIdEnt, cSerie, aProcessa ,dDataIni ,dDataFim , lUsaColab , nMaxLote)

Local nX				:= 0
Local nLote			:= 0
Local aLote			:= {}
Local lProcessou		:= .F.
Local cMod004			:= Fisa022Cod("004")
Private cEntSai		:= "1"			// NFS-e Saida
Private cVerTSS		:= "2.19"
default dDataIni     := Date()
default dDataFim 		:= dDataBase - __nDias  //-- Dias retroativos para Auto-emissão    
//-------------------------------------------------------------------
default lUsaColab	 	:= UsaColaboracao("3")
default nMaxLote		:= 20	// Valor limite de processamento dos documentos

If !Empty(__nLote) 
	nMaxLote := iif( valtype(__nLote) == "C", Val(__nLote), __nLote)	
	autoNfseMsg( "MAXLOTE ( Lote: " + allTrim(str(nMaxLote))  + " ).	Thread ["+cValToChar(ThreadID())+"] ")
EndIf

If !Empty( cIdEnt ) .And. !Empty( cSerie ) .And. Len( aProcessa ) > 0

	If FindFunction( "MonitorNFSE" )

		For nX := 1 To Len( aProcessa )
			
			nLote++
				
			AADD( aLote, aProcessa[ nX, 1 ] )
			
		  	If nLote == nMaxLote
			
				lProcessou	:= .T.

				autoNfseMsg( "[Monitoramento] Transmitindo Lote: " + aLote[1] + " - " + aLote[Len(aLote)]  + " .Thread ["+cValToChar(ThreadID())+"] ", .F. )
				
				MonitorNFSE( cIdEnt, cSerie, aLote, /*cCNPJIni*/, /*cCNPJFim*/, cMod004 , dDataIni, dDataFim ,lUsaColab)
								
				lProcessou	:= .F.
				nLote 		:= 0
				aLote 		:= {}
				
			Endif

		Next
			
		If !lProcessou .And. Len( aLote ) > 0			

			lProcessou	:= .T.
			
			autoNfseMsg( "[Monitoramento] Transmitindo Lote: " + aLote[1] + " - " + aLote[Len(aLote)]  + " .Thread ["+cValToChar(ThreadID())+"] ", .F. )
					
			MonitorNFSE( cIdEnt, cSerie, aLote, /*cCNPJIni*/, /*cCNPJFim*/, cMod004 , dDataIni, dDataFim ,lUsaColab)

			nLote 		:= 0
			aLote 		:= {}
			
		Endif
			
	Else
		
		autoNfseMsg( "Aplicar o patch atualizado do FISA022"  + " .Thread ["+cValToChar(ThreadID())+"] ")
			
	Endif
	
Endif

	delClassIntF()

Return lProcessou

//-------------------------------------------------------------------
/*/{Protheus.doc} montaRemessaNFSe
Funcao que retorna os dados da nota na tabela SF3

@param cAlias			Alias da SF3 
@param cRdMakeNFSe	modelo do rdMake a ser executado na montagem do XML
@param lCanc			indica se e remessa de cancelamento
@param cMotCancela	motivo do cancelamento	

@return aRemessa	dados da nota fiscal:
					aNotas[1]	serie da nota fiscal
					aNotas[2]	Numero da nota fiscal
					aNotas[3]	codigo cliente/fornecedor
					aNotas[4]	loja do cliente/fornecedor
					aNotas[5]	Data de Emissao
					aNotas[6]	Id da NFSe no TSS
					aNotas[7]	XML da NFSe 											
					
@author  Renato Nagib
@since   11/12/2012
@version 11.8
/*/
//-------------------------------------------------------------------
function montaRemessaNFSE(cAlias,cRdMakeNFSe,lCanc,cCodCanc,cMotCancela,cIdent,lMontaXML,cCodTit,cAviso,aTitIssRet,lUsaColab)
		
	Local aXml		:= {"",""}
	Local aRemessa	:= {}
	Local aAIDF		:= {}
	Local cCnpj		:= ""
	Local cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	Local cIdFIn		:= ""
	Local cAmbiente 	:= SubStr(GetAmbNfse( cIdEnt, .F. ),1,1)
	Private cTipo		:= ""
				
	default cMotCancela	:= ""		
	default cRdMakeNFSe	:= ""
	default lCanc			:= .F.
	default lMontaXml	:= .T. 
	default cCodTit		:= ""
	default cAviso			:= ""			
	default aTitIssRet	:= {}
	default lUsaColab		:= .F.
	default cCodCanc		:= NIL 

	if (cAlias)->(FieldPos("E2_EMISSAO")) > 0
		cTipo := "3"		
	else
		cTipo := if((cAlias)->F3_CFO<"5","0","1")
	endif 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totvs Colaboração 2.0 - Cancelamento automatico  Inicialização de variaveis 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	lUsaColab		:= iif (cTipo =="0",.F.,UsaColaboracao("3"))
	cMotCancela	:= iif (lCanc,(iif(Empty(cMotCancela),"Cancelamento de nota automatico",cMotCancela)),"")			
	cCodCanc	:= iif (lCanc,(iif(Empty(cCodCanc),"2",cCodCanc)),NIL)				
	//---------------------------------------------------------------------------------------------------
	
	if !lCanc .and. UsaAidfRps(cCodmun)
		aAIDF := getAidfRps(cCodmun, (cAlias)->F3_SERIE, (cAlias)->F3_NFISCAL,@cAviso)
	endif
	if validRemessa(cTipo,cAlias,cCodTit) .and. empty(cAviso)
	
		if lMontaXML
		    
			if cTipo == "3"
				aXml := NfseXml(cCodMun, cTipo, (cAlias)->E2_EMISSAO, (cAlias)->E2_PREFIXO, (cAlias)->E2_NUM, (cAlias)->E2_FORNECE, (cAlias)->E2_LOJA,cMotCancela,cRdMakeNFSe,aAIDF,aTitIssRet)
			else
				IF lUsaColab //TC2.0
					IF !Empty ((cAlias)->F3_NFELETR) // F3_NFELETR preenchido indica que a nota foi autoriza e possui retorno da prefeitura autorizado 111
						aXml := NfseXml(cCodMun, cTipo, (cAlias)->F3_ENTRADA, (cAlias)->F3_SERIE, (cAlias)->F3_NFELETR, (cAlias)->F3_CLIEFOR, (cAlias)->F3_LOJA,cMotCancela,cRdMakeNFSe,aAIDF,aTitIssRet,cCodCanc)
					ELSE
						aXml := NfseXml(cCodMun, cTipo, (cAlias)->F3_ENTRADA, (cAlias)->F3_SERIE, (cAlias)->F3_NFISCAL, (cAlias)->F3_CLIEFOR, (cAlias)->F3_LOJA,cMotCancela,cRdMakeNFSe,aAIDF,aTitIssRet,cCodCanc)
					ENDIF
				ELSE // WS TSS
					aXml := NfseXml(cCodMun, cTipo, (cAlias)->F3_ENTRADA, (cAlias)->F3_SERIE, (cAlias)->F3_NFISCAL, (cAlias)->F3_CLIEFOR, (cAlias)->F3_LOJA,cMotCancela,cRdMakeNFSe,aAIDF,aTitIssRet,cCodCanc, cAmbiente)
				Endif
			endif

		endif
		
		if cTipo $ "0|3" //Entradas|Contas a Pagar
								
			if cTipo == "3"    
				cCnpj := Posicione("SA2",1,xFilial("SA2")+(cAlias)->E2_FORNECE+(cAlias)->E2_LOJA,"SA2->A2_CGC")	
				cIdFIn := "FIN"
			else
				cCnpj := alltrim(Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"SA2->A2_CGC"))
			endif
					
		endIf			
		
		if (valType(aXml) == "A" .and. !empty(aXml[1])) .And. cTipo == "3"
			
			aadd(aRemessa, (cAlias)->E2_PREFIXO)
			aadd(aRemessa, (cAlias)->E2_NUM)
			aadd(aRemessa, (cAlias)->E2_FORNECE)
			aadd(aRemessa, (cAlias)->E2_LOJA)
			aadd(aRemessa, (cAlias)->E2_EMISSAO)				
			aadd(aRemessa, (cAlias)->E2_PREFIXO + (cAlias)->E2_NUM + cCnpj + cIdFIn )
			aadd(aRemessa, aXml[1])   				
			aadd(aRemessa, "")   
			aadd(aRemessa, "")     				
						
		elseif (valType(aXml) == "A" .and. !empty(aXml[1])) .or. lCanc 

			aadd(aRemessa, (cAlias)->F3_SERIE)
			aadd(aRemessa, (cAlias)->F3_NFISCAL)
			aadd(aRemessa, (cAlias)->F3_CLIEFOR)
			aadd(aRemessa, (cAlias)->F3_LOJA)
			aadd(aRemessa, (cAlias)->F3_ENTRADA)				
			aadd(aRemessa, (cAlias)->F3_SERIE + (cAlias)->F3_NFISCAL + cCnpj)
			aadd(aRemessa, aXml[1])		
			aadd(aRemessa, cMotCancela)	
			aadd(aRemessa, cCodCanc)	

			if lCanc 
				autoNfseMsg( "Remessa para cancelamento - Nota Fiscal: " + (cAlias)->F3_SERIE + alltrim((cAlias)->F3_NFISCAL) + " .Thread ["+cValToChar(ThreadID())+"] ",.F.)
			else
				autoNfseMsg( "Remessa para transmissao - Nota Fiscal: " + (cAlias)->F3_SERIE + alltrim((cAlias)->F3_NFISCAL) + " .Thread ["+cValToChar(ThreadID())+"] ",.F.)
			endif			
		endif

	endif

return aRemessa


//-------------------------------------------------------------------
/*/{Protheus.doc} envRemessaNFSe
Funcao que retorna os dados da SF3

@param	cIdEnt		código da empresa cadastrada no TSS 
@param cUrl		URL para envio da remessa
@param aRemessa	informações da remessa
					aRemessa[1]	Serie da nota fiscal
					aRemessa[2]	Numero da nota fiscal
					aRemessa[3] 	Codigo do cliente/fornecedor
					aRemessa[4]	loja do cliente/fornecedor
					aRemessa[5]	data de emissao da NF(F3_ENTRADA)
					aRemessa[6]	id da NFSe no TSS
					aRemessa[7]	XML da NFSe
					 												
@param lReproc	indica se a remessa deve ser reprocessada
@param cTipo		tipo da nota (entrada = "0" ; saida= "1")		
@param cNotasOk	String com os IDs transmitidos
@param lCanc		remessa de cancelamento
@param cCodCanc	Codigo do cancelamento

@Return lOk			Resultado do processamento	

@author  Renato Nagib
@since   11/12/2012
@version 11.8
/*/
//-------------------------------------------------------------------
Function envRemessaNFSe(cIdEnt,cUrl,aRemessa,lReproc,cTipo,cNotasOk,lCanc,cCodCanc,cCodMun,lRecibo,cErro,cMotCancela)
		
	Local aUpdate		:= {}
	Local aRetCol		:= {}
	Local lOk			:= .F.
	Local lStop   	:= .F.

	Local nx 			:= 0
	Local nTamXml		:= 0
	
	Local lUsaColab	:= iif (cTipo =="0",.F.,UsaColaboracao("3",cTipo))
	Local cGrupo		:= FWGrpCompany()		//-- Retorna o grupo
	Local cFil			:= FWCodFil()			//-- Retorna o código da filial
	Local lErro		:= .F.
	Local lProc		:= .F.
	Local nNFtrans	:= 0
	Local nXmlSize	:= 0
	Local dDataIni	:= Date()
	Local cHoraIni	:= Time()
	Local cCodigoC	:= GETNEWPAR("MV_CCANNFS", "2") 
	Local cMtCanSc	:= ""
	Local aCdMtCan	:= {} 
	Local lBlind 	:= IsBlind()
	default cNotasOk	:= ""
	default cCodCanc	:= ""
	default cCodMun	:= ""
	default lCanc		:= .F.
	default lRecibo	:= .F. 
	default cErro 	:= ""
	default cMotCancela := ""

	Private aRemessa1 := aRemessa
	
	
	IF lBlind .and. !Empty(cCodigoC) //Validacao para Campinas Via Schedule.
		aCdMtCan := StrTokArr2 (cCodigoC, ";", .T.)
		cCodigoC := aCdMtCan[1]
		cMtCanSc := IIF(Len(aCdMtCan) >= 2, aCdMtCan[2],"")
	EndIF

	If ( Empty(cCodMun) )
		cCodMun := if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	EndIf
	
	If Len(aRemessa) > 0
		
		If !lUsaColab
			oWS := WsNFSE001():New()
			oWS:cUSERTOKEN       := "TOTVS"
			oWS:cID_ENT          := cIdEnt
			oWS:cCodMun          := cCodMun
			oWS:_URL             := AllTrim(cURL)+"/NFSE001.apw"
			oWs:LREPROC          := lReproc
			oWs:OWSNFSE:oWSNOTAS := NFSe001_ARRAYOFNFSES1():New()
		EndIf
				
		For nX := 1 To Len(aRemessa)

			nTamXml += Len(aRemessa[nX][7])
						
			If nTamXml <= TAMMAXXML
				If lUsaColab
							//   ID ERP(Serie+NF+Emp+Fil)                 Erro     XML		          Entr/Saida   Serie          NF               Cliente            Loja             Retorno da Transmissao
					lOk := XMLRemCol( aRemessa[nX][1]+aRemessa[nX][2]+cGrupo+cFil , @cErro , aRemessa[nX][7] , cTipo  , aRemessa[nX][1] , aRemessa[nX][2] , aRemessa[nX][3] , aRemessa[nX][4] , @nXmlSize , nX , @aRetCol ,  ,@lStop)
			 		     //XMLRemCol( cIdErp                                      , cErro  , cXml            , cEntSai, cSerie          , cNF             , cCliente        , cLoja           , nXmlSize  , nY , aRetCol , cXmlRet )
					if lStop
					  EXIT
					Endif
				Else
					aAdd(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1,NFSE001_NFSES1():New())
					aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):CCODMUN        := cCodMun
					aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):cID            := aRemessa[nX][6]
					aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):cXML           := aRemessa[nX][7]
					aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):CNFSECANCELADA := " "
					aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):LREPROC        := lReproc
					//No método de Cancelamento, o campo código do cancelamento é validado somente em sua estrutura do XML.- IssNetonline -- Duque de Caxias
					cCodCanc := iif( lBlind .and. !Empty(cCodigoC) ,cCodigoC, IIF(Type("aRemessa1["+alltrim(str(nX))+"][9]") <> "U" .and. !Empty(aRemessa1[nX][9]) , aRemessa1[nX][9] , "2"))
					
					If !Empty(cCodCanc)
						aTail(oWs:OWSNFSE:OWSNOTAS:OWSNFSES1):CCODCANC	:= cCodCanc
					EndIf
					cMotCancela:=aRemessa[nX][8]
					
					IF lBlind .and. Len(aCdMtCan) >= 2 .and. !Empty(aCdMtCan[2])// Validacao para Campinas Via Schedule.
						
						cMotCancela := aCdMtCan[2]
					EndIF
					
					
					If !Empty(cMotCancela)
						aTail(oWs:OWSNFSE:OWSNOTAS:OWSNFSES1):CMOTCANC	:= cMotCancela					
					EndIf
				
					aAdd(aUpdate, aRemessa[nX])
				EndIf
			Else
																
				If lCanc
					
					autoNfseMsg( "Cancelamento - Lote: "+ alltrim(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1[1]:cID) + "-" +;
					                aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):cID  + " .Thread ["+cValToChar(ThreadID())+"] " , .F. )
				
					lOk := ExecWSRet( oWS, "CancelaNFSE001" )
					
					If lOk
				
						oRetorno := oWS:OWSCancelaNFSE001RESULT:OWSID:CSTRING
				
					EndIf
				
				Else
				
					autoNfseMsg( "Transmissao -  Lote: "+ alltrim(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1[1]:cID) + "-" +;
					                aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):cID  + " .Thread ["+cValToChar(ThreadID())+"] " , .F. )
					
				
					lOk := ExecWSRet( oWS, "RemessaNFSE001" )
					
					If lOk
				
						oRetorno := oWS:OWSREMESSANFSE001RESULT:OWSID:CSTRING
				
					EndIf
				EndIf
		       
				If lOk
																				
					updStatusNFSe(aUpdate,cTipo,oRetorno,lCanc,lRecibo)
					
					cNotasOk += getRetRemessa(oRetorno)
				
				Else
				
					autoNfseMsg( (IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))	 )				
    			
				EndIf
    			
				oWs:OWSNFSE:oWSNOTAS	:= NFSe001_ARRAYOFNFSES1():New()
				oWS:OWSNFSE:OWSNOTAS:OWSNFSES1 := {}

				nTamXml := 0
				aUpDate := {}
				nX --
	
			EndIf
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Totvs Colaboração 2.0                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lUsaColab
			If Len(aRetCol) > 0
				For nX := 1 to Len(aRetCol)
					If aRetCol[nX][1] == .F.
						cErro +=	"NFSe:   " + aRetCol[nX][3] + CRLF +;
									"Serie:  " + aRetCol[nX][2] + CRLF +;
									"Motivo: " + aRetCol[nX][6] + CRLF + CRLF
						lErro := .T.
					Else
						lProc := .T.
						nNFtrans ++
					EndIf
				Next nX
				If lProc
					cNotasOk := "Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."+CRLF
					cNotasOk += "Verifique se os arquivos foram processados e autorizados via TOTVS Colaboração, utilizando a rotina 'Monitor'."+CRLF+CRLF
					cNotasOk += "Foram transmitidas "+AllTrim(Str(nNFtrans,18))+" nota(s) em "+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF
					//-- Erro na geracao
				ElseIf lErro
				        cNotasOk += "--------------------------------------------------------------------------------" + CRLF
					if IsBlind()
						cNotasOk += "Houve um erro durante a geracao do arquivo para transmissao via TOTVS Colaboracao."+CRLF+CRLF
					else
						cNotasOk += "Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."+CRLF+CRLF
					EndIf
					cNotasOk += "As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."+CRLF+CRLF
					cNotasOk += cErro
				EndIf
			EndIf
		ElseIf Len(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1) > 0
			If lCanc
					autoNfseMsg( "Cancelamento - Lote: "+ alltrim(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1[1]:cID) + "-" +;
					                aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):cID  + " .Thread ["+cValToChar(ThreadID())+"] " , .F. )
				
				lOk := ExecWSRet( oWS, "CancelaNFSE001" )
				
				If lOk
				
					oRetorno := oWS:OWSCancelaNFSE001RESULT:OWSID:CSTRING
				
				EndIf
			
			Else
				
					autoNfseMsg( "Transmissao - Lote: "+ alltrim(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1[1]:cID) + "-" +;
					                aTail(oWS:OWSNFSE:OWSNOTAS:OWSNFSES1):cID  + " .Thread ["+cValToChar(ThreadID())+"] " , .F. )
			
				lOk := ExecWSRet( oWS, "RemessaNFSE001" )
				
				If lOk
			
					oRetorno := oWS:OWSREMESSANFSE001RESULT:OWSID:CSTRING
			
				EndIf
			
			EndIf

			If lOk
			
				updStatusNFSe(aUpdate,cTipo,oRetorno,lCanc,lRecibo)
			
				cNotasOk += getRetRemessa(oRetorno)
    		
			Else
				autoNfseMsg( (IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))) )
			EndIf
		EndIf
	EndIf	
	
	delClassIntF()

Return lOk


//-------------------------------------------------------------------
/*/{Protheus.doc} updStatusNFSe
Funcao que atualiza o Status de transmissão da NFSe

@param aRemessa	informações da remessa
					aRemessa[1]	Serie da nota fiscal
					aRemessa[2]	Numero da nota fiscal
					aRemessa[3] 	Codigo do cliente/fornecedor
					aRemessa[4]	loja do cliente/fornecedor
					aRemessa[5]	data de emissao da NF(F3_ENTRADA)
					aRemessa[6]	id da NFSe no TSS
					aRemessa[7]	XML da NFSe		

@param cTipo		tipo da nota (entrada = "0" ; saida= "1")
@param aRetorno	retorno do método
@param lCanc		remessa de cancelamento

@aReturn	nil

@author  Renato Nagib
@since   11/12/2012
@version 11.8
/*/
//-------------------------------------------------------------------
static function updStatusNFSe(aRemessa,cTipo,aRetorno,lCanc,lRecibo)
	
	local nY		:= 0
	
	default cTipo	:= "1"
	default lRecibo	:= .F.
	
		For nY := 1 to Len(aRemessa)

			if !lCanc
	
				if lRecibo
					
					SE2->(DbSetOrder(6))
		
					If SE2->(DbSeek(xFilial("SE2")+aRemessa[nY][3]+aRemessa[nY][4]+aRemessa[nY][1]+aRemessa[nY][2]))
		
						If SE2->E2_FIMP $ "N, "
							
							RecLock("SE2")
						    
						    SE2->E2_FIMP := IIF(aScan(aRetorno,aRemessa[nY][1]+AllTrim(aRemessa[nY][2]))==0,"N","T")
						    
						    MsUnlock()
						 Endif				    	    
					
					EndIf	
						
					
									
				elseif cTipo == "1"				
					
					SF2->(DbSetOrder(1))	
		
					If SF2->(DbSeek(xFilial("SF2")+aRemessa[nY][2]+aRemessa[nY][1]+aRemessa[nY][3]+aRemessa[nY][4]))
		
						If SF2->F2_FIMP $ "N, "
							RecLock("SF2")
						    SF2->F2_FIMP := IIF(aScan(aRetorno,aRemessa[nY][1]+AllTrim(aRemessa[nY][2]))==0,"T","T")
						    MsUnlock()
						 Endif				    	    
					
					EndIf
		
				else 			
					SF1->(DbSetOrder(1))	
					
					If SF1->(DbSeek(xFilial("SF1")+aRemessa[nY][2]+aRemessa[nY][1]+aRemessa[nY][3]+aRemessa[nY][4]))
					
						If SF1->F1_FIMP $ "N, "
							
							RecLock("SF1")
						    
						    SF1->F1_FIMP := IIF(aScan(aRetorno,aRemessa[nY][1]+AllTrim(aRemessa[nY][2]))==0,"N","T")
						   
						    MsUnlock()
						 
						 Endif
					
					EndIf		
				
				endIF
			endif
			
			SF3->(dbSetOrder(5))				
			
			If SF3->(DbSeek(xFilial("SF3")+aRemessa[nY][1]+aRemessa[nY][2]+aRemessa[nY][3]+aRemessa[nY][4]))
			
				If SF3->(FieldPos("F3_CODRSEF")) > 0 
					
					RecLock("SF3")									
					
					if !lcanc
						
						autoNfseMsg( "Atualizando transmissao - Nota Fiscal: " + aRemessa[nY][1]+AllTrim(aRemessa[nY][2] ) + " .Thread ["+cValToChar(ThreadID())+"] ", .F.)
						
						SF3->F3_CODRSEF := IIF(aScan(aRetorno,aRemessa[nY][1]+AllTrim(aRemessa[nY][2]))==0,"N","T")
						SF3->F3_CODRET  := "T"
					
					else

						autoNfseMsg( "Atualizando cancelamento - Nota Fiscal: " + aRemessa[nY][1]+AllTrim(aRemessa[nY][2] ) + " .Thread ["+cValToChar(ThreadID())+"] ", .F.)
						
						SF3->F3_CODRSEF := "C"					
						SF3->F3_CODRET  := "T"					
					
					endif
					
			
					SF3->(MsUnlock())
			
				EndIf                           
				//Libera o registro da tabela de AIDF
				if  aliasIndic("C0P") 
					 
					C0P->(dbSetOrder(1))

					if C0P->(dbSeek(xFilial() + padr(cValToChar(val(SF3->F3_NFISCAL)), tamSX3("C0P_RPS")[1] ) ) )
						reclock("C0P")
						if SF3->F3_CODRSEF == "N"
							C0P->C0P_AUT		:= "N"
						else
							C0P->C0P_AUT		:= "T"
						endif	
						C0P->(msunlock())
					endif
				endif			
			
			EndIf					
		
		Next
		
return	nil


//-----------------------------------------------------------------------
/*/{Protheus.doc} validRemessa
verifica  de deve ser montada remessa para a nota fiscal

@author Renato Nagib
@since 12.03.2012
@version 1.0 

@param cTipo		tipo da nota (entrada = "0" ; saida= "1")

@return lRet		retorno da validação
/*/
//-----------------------------------------------------------------------
static function validRemessa(cTipo,cAlias,cCodTit)

	local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )   
	
	local lRet 		:= .F.
	local lContinua := .F.
	
	local aMVTitNFT	:= &(GetNewPar("MV_TITNFTS","{}"))
	
	default cCodTit	:= ""
	
	
	if cTipo == "0"

		cCodEstPr := Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"SA2->A2_EST")

		cCodEstPr := aUF[aScan(aUF,{|x| x[1] == AllTrim(cCodEstPr)})][02]

		cCodMunPr := cCodEstPr + AllTrim( Posicione("SA2",1,xFilial("SA2")+(cAlias)->F3_CLIEFOR+(cAlias)->F3_LOJA,"SA2->A2_COD_MUN") )
		
		If cCodMun $ Fisa022Cod("201")
			
			lRet := .T.
					
		ElseIf !Empty(cCodMunPr) .And.;
				(!( cCodMunPr  $ cCodMun ) .Or. ( cCodMunPr  $ cCodMun ) )			

			If Empty((cAlias)->F3_NFELETR) .And. Empty((cAlias)->F3_CODNFE) .Or. Empty((cAlias)->F3_CODRSEF) 
				If cCodMun $ "3303906-3550308-3525300" .And. cCodMun == cCodMunPr 
				//Quando o municipio da NFTS de entrada for São Paulo ou Rio e o Tomador for destes municipios não se faz necessária a geração do arquivo e envio a prefeitura.
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			endif
		endif
	
	//Registtros do contas a pagar.
	elseif cTipo == "3" .and. ( cCodMun $ GetMunNFT() ) 
		cCodEstPr := Posicione("SA2",1,xFilial("SA2")+(cAlias)->E2_FORNECE+(cAlias)->E2_LOJA,"SA2->A2_EST")
		
		cCodEstPr := aUF[aScan(aUF,{|x| x[1] == AllTrim(cCodEstPr)})][02]
        
		cCodMunPr := cCodEstPr + AllTrim( Posicione("SA2",1,xFilial("SA2")+(cAlias)->E2_FORNECE+(cAlias)->E2_LOJA,"SA2->A2_COD_MUN") )
	    
		//Quando o E2_TIPO estiver na primeira posicao do aMVTitNFT, somente sera considerado se o prestador
		//for de fora do municipio(01 - Dispensado de emissao de documento fiscal).

		if aScan(aMVTitNFT,{|x| x[1] == (cAlias)->E2_TIPO}) == 1
			lContinua :=  !( cCodMunPr  $ GetMunNFT() )			
		else
			lContinua := .T.				
		endif
	
		If AllTrim((cAlias)->E2_TIPO) $ ( cCodTit ) .And. (cAlias)->E2_ISS > 0 .And. lContinua	
			
			If 	Empty((cAlias)->E2_NFELETR)

				lRet := .T.

			endif

		endif
				
	else

		lRet := .T.

	endif

return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} getRetRemessa
Funcao que retorna string com os retorno das notas enviadas pelo metodo de Remessa

@author Renato Nagib
@since 12.03.2012
@version 1.0 

@param		oRetorno	objeto de retorno do metodo

@return		Nil
/*/
//-----------------------------------------------------------------------
static function getRetRemessa(aRetorno)

	local cNotasOk:= ""
	
	local nW		:= 0
	
	if len(aRetorno) > 0 
		
		for nW := 1 to len(aRetorno)

			cNotasOk += aRetorno[nW] + CRLF

		next nW
		
	else
		
		cNotasOk := "Uma ou mais notas nao puderam ser transmitidas:"+CRLF
		cNotasOk += "Verifique as notas processadas."
	
	endIf    

return	cNotasOk


//-----------------------------------------------------------------------
/*/{Protheus.doc} getRDMakeNFSe
retorna nome do rdmake a ser utilizado pelo municipio

@author Renato Nagib
@since 12.03.2012
@version 1.0 

@param		cCodMun	código do Município
@param cTipo		tipo da nota (entrada = "0" ; saida= "1") 

@return		Nil
/*/
//-----------------------------------------------------------------------
function getRDMakeNFSe(cCodMun,cTipo, lNfsenac)

	Local cFuncExec	:= ""
	Local lUsaColab	:= iif (cTipo =="0",.F.,UsaColaboracao("3",cTipo))
	default cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	default ctipo		:= ""
	default lNfsenac	:= .F. 


	if lUsaColab
		cFuncExec:= "nfseXMLUni"
	elseif lNfsenac .And. !( ( cTipo == "0" .or. cTipo == "3" ) .And. cCodMun $ GetMunNFT() )
		cFuncExec:= "nfseXmlNac" // Layout NFS-e Nacional
	elseif isTSSModeloUnico() .And. !( ( cTipo == "0" .or. cTipo == "3" ) .And. cCodMun $ GetMunNFT() )
		cFuncExec:= "nfseXMLEnv"
	else

		Do Case
		Case ( cCodMun $ Fisa022Cod("001") ) .And. !( ( cTipo == "0" .or. cTipo == "3") .And. cCodMun $ GetMunNFT() )
			cFuncExec:= "NfseM001"

		Case ( cCodMun $ Fisa022Cod("002") .Or. cCodMun $ "2408102" .Or. cCodMun $ Fisa022Cod("006") .Or. cCodMun $ Fisa022Cod("007") .Or. cCodMun $ Fisa022Cod("008") ) .And. !( ( cTipo == "0" .or. cTipo == "3") .And. cCodMun $ GetMunNFT() )//Natal, no TSS é do modelo 102(xml)
			cFuncExec:= "NfseM002"

		Case cCodMun $ Fisa022Cod("101") .Or. cCodMun $ Fisa022Cod("009") .Or. ( ( cTipo == "0" .or. cTipo == "3" ) .And. cCodMun $ GetMunNFT() )
			cFuncExec:= "NfseM102"

		Case ( cCodMun $ Fisa022Cod("102") .And. cCodMun <> "2408102" ) .And. !( ( cTipo == "0" .or. cTipo == "3" ) .And. cCodMun $ GetMunNFT() )//Natal
			cFuncExec:= "NfseM102"

		Case cCodMun $ Fisa022Cod("003")
			cFuncExec:= "NfseM003"

		Case cCodMun $ Fisa022Cod("004")
			cFuncExec:= "NfseM002"

		EndCase

	EndIf
		
return cFuncExec

//-----------------------------------------------------------------------
/*/{Protheus.doc} lMontaXml
Função que verifica se o tipo do documento monta XML ou arquivo TXT

@author Cleiton Genuino
@since 30/08/2016
@version 1.0

@param		cCodMun	código do Município
@param 		cTipo		código de Serviço exercido pelo Município

@return lMontaXML Se verdadeiro irá montar o XML
/*/
//-----------------------------------------------------------------------
function lMontaXml(cCodMun,cTipo)
			
	local lMontaXML	:= .F.
	local lUsaColab 	:= UsaColaboracao("3",cTipo)
 	
 	default cIdEnt	:= ""
 	default cCodmun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
 	default cTipo		:= ""
 	
 	If ( (cCodMun $ Fisa022Cod("101") .And. !cCodMun $ "3201308") .or. (cCodMun $ Fisa022Cod("102") .And. !cCodMun $ "4205407")  .Or. ( cCodMun $ GetMunNFT() .And. cTipo == "0" .or. cTipo == "3" ) ) .Or. (cCodMun $ "4208203-4204202") .Or. lUsaColab
 		lMontaXML := .T.
	endif

return lMontaXML

//-----------------------------------------------------------------------
/*/{Protheus.doc} UsaColaboracao
Função local para verificação do uso do TOTVS Colaboração 2.0

@author Cleiton Genuino
@since 30/08/2016
@version 1.0

@param		cModelo, string, Código do modelo: 0 - todos<br>1-NFE<br>2-CTE<br>3-NFS<br>4-MDe<br>5-MDfe<br>6-Recebimento<br>7-EDI
@param 		cTipo		tipo da nota (entrada = "0" ; saida= "1")

@return lUsa Se verdadeiro usa Totvs Colaboração 2.0
/*/
//-----------------------------------------------------------------------
static function UsaColaboracao(cModelo,cTipo)
Local lUsa := .F.
Default cTipo:= "1"

If cTipo $ '1'
If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
	endif
endif
return (lUsa)
//--------------------------------------------------------
