#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCOA122.CH"
#Define GRID_STEP 10000

Static __lBlind		:= IsBlind()
Static _lAtuCubo     := .T.
Static _jTamAK2

Function PcoA122(nRecAK1)

Local nX
Local lRet 		:= .F.
Local cAliasTmp
Local cQuery 	:= ""
Local aRecGrid 	:= {}
Local nThread:= SuperGetMv("MV_PCOTHRD",.T.,10)
Default nRecAK1 := AK1->( Recno() )

Pergunte("PCO120",.F.)
_lAtuCubo     := ( mv_par01 == 1 ) .and. !Intransact()

cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para obter recnos da tabela AK2 ou AK33 da nova versao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT MIN(R_E_C_N_O_) MINRECNOAK, MAX(R_E_C_N_O_) MAXRECNOAK FROM " + RetSqlName( "AK2" )
cQuery += " WHERE "
cQuery += "	           AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
cQuery += "        AND D_E_L_E_T_= ' ' " 

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

TcSetField( cAliasTmp, "MINRECNOAK", "N", 12, 0 )
TcSetField( cAliasTmp, "MAXRECNOAK", "N", 12, 0 )

If (cAliasTmp)->(!Eof())

	//DISTRIBUIR EM GRID
	aRecGrid := {}
	For nX := (cAliasTmp)->MINRECNOAK TO (cAliasTmp)->MAXRECNOAK STEP GRID_STEP
		If nX + GRID_STEP > (cAliasTmp)->MAXRECNOAK
			aAdd(aRecGrid, {nx, (cAliasTmp)->MAXRECNOAK } )  //ultimo elemento do array
		Else
			aAdd(aRecGrid, {nx, nX+GRID_STEP-1} )
		EndIf
	Next

	nThread := Min( Len(aRecGrid), nThread ) //Configura a quantidade de threads pelo menor parametro ou len(arecgrid)

	oGrid := FWIPCWait():New("AK1X"+cEmpAnt+StrZero(nRecAK1,9,0),10000)
	oGrid:SetThreads(nThread)
	oGrid:SetEnvironment(cEmpAnt,cFilAnt)
	oGrid:Start("PCOAREVPRC")

	If !MSFile("PCOTMP", ,__CRDD )
		P301CriTmp()				
	EndIf	
	
	If Select("PCOTMP")==0
		dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
	EndIf		
	
	lRet := A122RevPre(oGrid,aRecGrid,nThread)

EndIf

If _lAtuCubo
	P122AtuCubo(cPlanRev, cNewVers, "02"/*cItemProc*/,"+"/*cSinal*/)
EndIf

ConoutR("[END]->PCOA122: "+TIME(), .T., "PCOA122")

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Popula_AK2 ³ Autor ³                         ³ Data ³15.05.13³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama as funções q fazem a criação e instalação de procedures ±±
±±³        que geram osníveis superiores p as entidades                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Popula_AK2 (cCodigoAK1, cVerAtu, cNextVer, cArq, aProc  )    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1=cCodigoAK1 - Codigo da Planilha                       ³±±
±±             ExpC2=cVerAtu    - Versao Atual da Planilha                 ³±±
±±             ExpC3=cNextVer   - Proxima Versão da Planilha               ³±±
±±             ExpC4=cArq       - Nome da procedure Sem a empresa          ³±±
±±             ExpA1=aProc      - Array com as procedures criadas          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Popula_AK2(cCodigoAK1 as Character, cVerAtu as Character, cNextVer as Character )
Local aSaveArea  := GetArea() as Array
Local aCposAK2   := AK2->(DbStruct()) as Array
Local aCposAK3   := AK3->(DbStruct()) as Array
Local cQuery     := "" as Character
Local cCpoSelect := "" as Character
Local iX 		 as Numeric
Local lRet 		 := .T. as Logical
local oBulkAK2   as object
local oBulkAK3   as object
local oQueryAK2  as object
Local cCampos    := '' as character
Local cAliasAKX  := '' as character
Local nqry       := 0  as Numeric
Local bExc
Local aValues 	 := {}
Local nLenAk2 	 as Numeric
Local nLenAk3 	 as Numeric

oBulkAK2 := FwBulk():New(RetSQLName("AK2"))
oBulkAK2:setFields(aCposAK2)

// Adiciona campos no Select 
nLenAk2:= Len( aCposAK2)
For iX := 1 to nLenAk2
	cCpoSelect += aCposAK2[Ix][1]
	If iX < nLenAk2
		cCpoSelect += ", "
	EndIf
Next
cCpoSelect := StrTran(cCpoSelect,'AK2_VERSAO', "'"+ cNextVer + "' as AK2_VERSAO")
cQuery +="   Select "
cQuery+= cCpoSelect+CRLF
cQuery +="     From "+RetSqlName("AK2")+CRLF
cQuery +="    Where AK2_FILIAL = ? "+CRLF //@cAK2_FILIAL
cQuery +="      and AK2_ORCAME = ? "+CRLF // @IN_ORCAME
cQuery +="      and AK2_VERSAO = ? "+CRLF //@IN_VERATU
cQuery +="      and D_E_L_E_T_ = ? "+CRLF
cQuery +="   Order By  AK2_FILIAL, AK2_ORCAME, AK2_VERSAO, AK2_CO"+CRLF  // verificar necessidade

nQry := 1
oQueryAK2 := FWPreparedStatement():New(cQuery)
oQueryAK2:SetString(nQry++, xFilial('AK2'))
oQueryAK2:SetString(nQry++, cCodigoAK1)
oQueryAK2:SetString(nQry++, cVerAtu)
oQueryAK2:SetString(nQry++, ' ')

cAliasAKX := GetNextAlias()
MPSYSOpenQuery(oQueryAK2:GetFixQuery(), cAliasAKX)

aEval(aCposAK2,{|x| cCampos += Alltrim( x[1] )+", "  })
cCampos := substr(cCampos,1,len(cCampos)-2)

If !(cAliasAKX)->(Eof())
	bExc	:= &("{|| iif((cAliasAKX)->(!oBulkAK2:AddData({"+cCampos+"})),UserException(oBulkAK2:GetError()),nil) }")
	(cAliasAKX)->(DbEval(bExc,,))
Endif

(cAliasAKX)->(dbclosearea())

If !oBulkAK2:Close()
	//- quebra a execução com erro, pois não atualizou o registro
	UserException(oBulkAK2:GetError())
	lRet:= .F.
Else
	//--------------------------------------------------------- AK3--------------------------------------------------------
	oBulkAK3 := FwBulk():New(RetSQLName("AK3"))
	oBulkAK3:setFields(aCposAK3)

	dbSelectArea("AK3")
	dbSetOrder(1)
	nLenAk3:= Len( aCposAK3)
	If dbSeek(xFilial('AK3')+cCodigoAK1+cVerAtu)

		While !AK3->(Eof()) .and. AK3->AK3_ORCAME == cCodigoAK1 .and. AK3->AK3_VERSAO == cVerAtu
			aValues := {}
			For iX := 1 to nLenAk3
				If aCposAK3[iX][1] == 'AK3_VERSAO'
					aAdd(aValues,cNextVer)
				Else
					aAdd(aValues, AK3->&(aCposAK3[iX][1]))
				EndIf
			NEXT
			oBulkAK3:AddData(aValues)
			AK3->(DbSkip())
		Enddo
		If !oBulkAK3:Close()
			//- quebra a execução com erro, pois não atualizou o registro
			UserException(oBulkAK3:GetError())
			lRet:= .F.
		EndIf
	EndIf
EndIf

oBulkAK2:destroy()
FreeObj(oBulkAK2)
oBulkAK3:destroy()
FreeObj(oBulkAK3)

RestArea(aSaveArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³PcoProcRev ³ Autor ³                       ³ Data ³16.05.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chama as funções q fazem a criação e instalação de procedures ±±
±±³        que geram osníveis superiores p as entidades                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PcoProcRev(cCodigoAK1, cVerAtu, cNextVer, aAliasCpy, aRecAK3,³±± 
±±³			             aRecNew,   lSimulac,lRevisao,  lPCOCOP )          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = cCodigoAK1 - Codigo da Planilha                     ³±±
±±             ExpC2 = cVerAtu    - Versao Atual da Planilha               ³±±
±±             ExpC3 = cNextVer   - Próxima versão da Planilha             ³±±
±±             ExpA1 = aAliasCpy  -                                        ³±±
±±             ExpA2 = aRecAK3    - Recnos do AK3 da versao atual          ³±±
±±             ExpA3 = aRecNew    - Recnos do AK3 da nova versao           ³±±
±±             ExpL1 = lSimulac   - Se .T., simulação                      ³±±
±±             ExpL2 = lRevisao   - Se .T., revisao                        ³±±
±±             ExpL3 = lPCOCOP    -                                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PcoProcRev(cCodigoAK1, cVerAtu, cNextVer, aAliasCpy, aRecAK3, aRecNew, lSimulac, lRevisao, lPCOCOP )
Local aAreaAK2:= GetArea("AK2") as Array
Local aAreaAK3:= GetArea("AK3") as Array
Local lRet    := .T. as Logical
Local cAliasTmp as Character
Local nRecNew := 0 as Numeric
Local nThread:= SuperGetMv("MV_PCOTHRD",.T.,10) as Numeric

Private cPlanRev    := AK1->AK1_CODIGO
Private cNewVers 	:= cNextVer   //variaveis para multi-thread
Private lSimu_ 		:= lSimulac 
Private lRevi_      := lRevisao

Private oGrid
Private lAuto

If nThread < 2 .Or. nThread > 30
	Help(" ",1,"PCOA120IRV",,STR0006,1,0)  //"Quantidade de Thread não permitida."
	Return(.F.)
EndIf 

If !LockByName("PCOA120"+cEmpAnt+xFilial("AKE")+cCodigoAK1+cVerAtu+cNextVer,.F.,.F.)
	Help(" ",1,"PCOA120US",,STR0007,1,0) //"Outro usuario está usando a rotina "
	Return(.F.)
EndIf

lRet := Popula_AK2(cCodigoAK1, cVerAtu, cNextVer )

TcRefresh(RetSqlName("AK2"))
TcRefresh(RetSqlName("AK3"))

// Faz chamada da DETLAN 
If lRet
	//select ak3 da versao atual para gravar os recnos no array aRecAK3 
	IncProc() //Incrementa valor na regua de progressao
	cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK3" )
	cQuery += " WHERE "
	cQuery += "	           AK3_FILIAL ='" + xFilial( "AK3" ) + "' " 
	cQuery += "        AND AK3_ORCAME ='" + AK1->AK1_CODIGO          + "' "
	cQuery += "        AND AK3_VERSAO = '"+cVerAtu+"' "
	cQuery += "        AND D_E_L_E_T_= ' ' " 
	cQuery += " ORDER BY R_E_C_N_O_"
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )
	
	TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
	                                          
	While (cAliasTmp)->(!Eof())
		nRecNew := (cAliasTmp)->(RECNOAK)
		aAdd(aRecAK3, nRecNew)	//Armazena o recno da versao atual
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea() )

	//select ak3 da versao atual para gravar os recnos no array aRecNew
	IncProc() //Incrementa valor na regua de progressao
	cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK3" )
	cQuery += " WHERE "
	cQuery += "	           AK3_FILIAL ='" + xFilial( "AK3" ) + "' " 
	cQuery += "        AND AK3_ORCAME ='" + AK1->AK1_CODIGO          + "' "
	cQuery += "        AND AK3_VERSAO = '"+cNextVer+"' "
	cQuery += "        AND D_E_L_E_T_= ' ' " 
	cQuery += " ORDER BY R_E_C_N_O_"
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )
	
	TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
	                                          
	While (cAliasTmp)->(!Eof())
		nRecNew := (cAliasTmp)->(RECNOAK)
		aAdd(aRecNew, nRecNew)	//Armazena o recno da nova versao
		(cAliasTmp)->(dbSkip())
	EndDo
	(cAliasTmp)->(dbCloseArea() )

	IncProc() //Incrementa valor na regua de progressao

	PcoA122( AK1->(Recno()) ) //distribui os registros copiados para gerar akd pelo pcodetlan/pcofinlan
	
EndIf

UnLockByName("PCOA120"+cEmpAnt+xFilial("AKE")+cCodigoAK1+cVerAtu+cNextVer,.F.,.F.)

RestArea( aAreaAK2 )       
RestArea( aAreaAK3 )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A122RevPre ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Prepara a execução da rotina em MultiThreads                º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A122RevPre(oGrid,aRecGrid,nThread)
Local nRecIni
Local nRecFim

Local cFilAKE 	:= xFilial("AKE")
Local lExit 	:= .F.
Local nKilled
Local nHdl
Local cMsgComp	:= ""
Local nX
Local nZ
Local cArquivo := ""

cArquivo := CriaTrab(,.F.)

For nX := 1 To Len(aRecGrid)
	nRecIni := aRecGrid[nX,1]
	nRecFim := aRecGrid[nX,2]
	lRet := oGrid:Go(STR0011,{nRecIni, nRecFim, lSimu_, lRevi_, cPlanRev, cNewVers, nX},cArquivo)  //"Chamando escrituracao..."
	If !lRet
		Exit
	EndIf

	Sleep(5000)//Aguarda 5 seg para abertura da thread para não concorrer na criação das procedures.

Next

Sleep(2500*nThread)//Aguarda todas as threads abrirem para tentar fechar
    
While !lExit
	nKilled := P301ChkThd("PCOA122",cArquivo)

	If nKilled == Len(aRecGrid)
		Exit
	EndIf
	
	Sleep(3000) //Verifica a cada 3 segundos se as threads finalizaram
	
EndDo

cMsgComp := P301MsgCom("PCOA122",cArquivo)
	
P301DelTmp("PCOA122",cArquivo)

PcoAvisoTm(IIf(lRet,STR0012, STR0016),cMsgComp, {"Ok"},,,,,5000) //"Processo finalizado com sucesso."###"Problema no processamento."

// Fechamento das Threads
oGrid:Stop()        //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

oGrid:RemoveThread(.T.)

FreeObj(oGrid)
oGrid := nil

Return lRet	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOAREVPRC ºAutor  ³Microsiga           º Data ³  14/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina executado em MultiThread para chamara a funcao que  º±±
±±º          ³  ira executar PcoDetLan                                     º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOAREVPRC(cParm,aParam,cArquivo)
Local nRecIni 	:= aParam[1]
Local nRecFim 	:= aParam[2]
Local lSimulac 	:= aParam[3]
Local lRevisa 	:= aParam[4]
Local cPlanRev  := aParam[5]
Local cNewVers  := aParam[6]
Local nZ		:= aParam[7]
Local cFilAKE 	:= xFilial("AKE")
Local nRecPCO   := 0

Local nHdl 
Local cStart	:= ""
Local cEnd      := ""
DEFAULT cArquivo:= ""

If Select("PCOTMP")==0
	dbUseArea(.T.,__CRDD,"PCOTMP","PCOTMP", .T., .F. )
EndIf


If LockByName("PCOA120_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0),.T.,.T.)
	cStart := DTOC(Date())+" "+Time()		
	ConoutR( "PCOA120 -> "+AllTrim(Str(ThreadID()))+" STARTED ["+cStart+"] " ) 
	PCOTMP->(RecLock("PCOTMP",.T.))
		PCOTMP->CPOLOG := "  [DETLAN] STARTED ["+cStart+"]" 
    	PCOTMP->ORIGEM := "PCOA122"  
    	PCOTMP->ARQUIVO:= cArquivo
    	PCOTMP->STATUS := "0"	  
    PCOTMP->(MsUnLock())

    nRecPCO := PCOTMP->(RECNO())
    //PROCESSAMENTO
	lRet := Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisa, cPlanRev, cNewVers)
	
	cEnd := DTOC(Date())+" "+Time()
	
    PCOTMP->(dbGoTo(nRecPCO))
	PCOTMP->(RecLock("PCOTMP",.F.))
    	
    	If lRet	
    		ConoutR("PCOA120 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  OK")
			PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+ "  END ["+cEnd+"] - OK"
		Else
			ConoutR("PCOA120 -> "+AllTrim(Str(ThreadID()))+" END   ["+cEnd+"]  FAILED")
			PCOTMP->CPOLOG := AllTrim(PCOTMP->CPOLOG)+ "  END ["+cEnd+"] - FAILED"
	    EndIf	 
	    PCOTMP->STATUS := "1"
    PCOTMP->(MsUnLock())
    
	UnLockByName("PCOA301_"+cFilAKE+cPlanRev+cNewVers+StrZero(nZ,10,0),.T.,.T.)

EndIf
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Aux_Det_Lan ºAutor  ³Microsiga         º Data ³  06/14/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chama a PcoDetLan para escriturar movimento gerado por      º±±
±±º          ³Iniciar Revisao (distribuido)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Aux_Det_Lan(nRecIni, nRecFim, lSimulac, lRevisao, cPlanRev, cNewVers)
Local lRet := .F.
Local cQuery := " "
Local nCtdAK2 := 0

//select ak2 da versao nova
cAliasTmp := GetNextAlias() //Obtem o alias para a tabela temporaria
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query para obter recnos da tabela AK2 ou AK3 da nova versao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT R_E_C_N_O_ RECNOAK FROM " + RetSqlName( "AK2" )
cQuery += " WHERE "
cQuery += "	           AK2_FILIAL ='" + xFilial( "AK2" ) + "' " 
cQuery += "        AND AK2_ORCAME ='" + cPlanRev + "' "
cQuery += "        AND AK2_VERSAO = '"+ cNewVers +"' "
cQuery += "        AND R_E_C_N_O_ BETWEEN  "+ Str(nRecIni,12,0) + " AND "+ Str(nRecFim,12,0)
cQuery += "        AND D_E_L_E_T_ = ' ' " 
cQuery += " ORDER BY R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", Tcgenqry( , , cQuery ), cAliasTmp, .F., .T. )

TcSetField( cAliasTmp, "RECNOAK", "N", 12, 0 )
ConoutR(STR0013+Str(nRecIni,12,0)+STR0014+Str(nRecFim,12,0)+time()) // "inicio Recnos de:"###" Ate: "
PcoIniLan("000252")

While (cAliasTmp)->(!Eof())
	nRecNew := (cAliasTmp)->(RECNOAK)
	AK2->(dbGoto(nRecNew))
	nCtdAK2++	
	If lSimulac
		PcoDetLan("000252","03","PCOA100",/*lDeleta*/, /*cProcDel*/, "1")
	ElseIf lRevisao
		PcoDetLan("000252","02","PCOA100",/*lDeleta*/, /*cProcDel*/, "1")
	EndIf
	(cAliasTmp)->(dbSkip())
EndDo

PcoFinLan("000252",/*lForceVis*/,/*lProc*/,/*lDelBlq*/,.F./*lAtuSld*/)

(cAliasTmp)->(dbCloseArea() )

ConoutR(STR0015+Str(nRecIni,12,0)+STR0014+Str(nRecFim,12,0)+time())  //"Final Recnos de: "###" Ate: "

lRet := ( (nRecFim-nRecIni+1) == nCtdAK2 )

Return(lRet)


/*-----------------------------------------------------------------------------------------*/
//atualizacao dos cubos                                                                    //
/*-----------------------------------------------------------------------------------------*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P122AtuCubo ºAutor  ³Microsiga         º Data ³  21/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamador procedure para atualizar saldo na revisao da       º±±
±±º          ³planilha orcamentaria                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function P122AtuCubo(cPlanRev, cVersPlan, cItemProc, cSinal)
Local aTmpDim := {}
Local aNivel := {}
Local cProcSup := ""
Local cExecDrop := ""
Local nRetDrop := 0
Local nX
Local aTdaNiveis := {}
Local nZ

If _lAtuCubo
    
	aTmpDim := {}
	dbSelectArea("AL1")
	dbSeek(xFilial("AL1"))   //posiciona na filial
	While AL1->( ! Eof() .And. AL1_FILIAL = xFilial("AL1") )  //enquanto for da mesma filial
	
		aNivel := PcoGeraSup(AL1->AL1_CONFIG,aTmpDim)
		
		If Len(aNivel) > 0
			aAdd( aTdaNiveis, aClone(aNivel) )
		EndIf
			
		//Verifica se a estrutura do cubo existe	
		dbSelectArea("AKW") 
		AKW->(dbSetOrder(1))
		If AKW->(dbSeek(xFilial("AKW")+AL1->AL1_CONFIG))
		    //Verifica se o cubo está liberado
			While .T.
				If AL1->(dbRLock())							
					PcoCubeStatus("2")	//Bloquear o cubo com RecLock() para ninguem atualiza-lo durante o processamento			
					
					lRet := P300CallProc(aNivel, /*dDataIni*/, /*dDataFim*/, /*cTpSld*/,AL1->AL1_CONFIG /*cCubo*/,;
					 {cItemProc,cPlanRev, cVersPlan,cSinal}/*a122Params*/)
					
					If lRet
						TcRefresh(RetSqlName("AKT"))
					EndIf
					
					dbSelectArea("AL1")
					//libera o lock do registro referente ao cubo gerencial
			   		PcoCubeStatus("1")		
					AL1->(dbRUnlock())
					Exit
				Else
					If PcoAvisoTm(STR0017,STR0018+AL1->AL1_CONFIG+CRLF+;  //"Atencao"###"Atualizacao de Saldos do Cubo : "
											STR0019+CRLF+;  //"Cubo em Uso. Tente novamente!"
											STR0020, {STR0021,STR0022},3,,,,5000)  == 2 //"Caso Abandone os cubos deverao ser reprocessados."###"Ok"###"Abandonar"
						ConoutR(STR0023) //"Atualizacão de saldos do cubo foi abandonada na revisao da planilha e deve ser reprocessado apos finalizacao"
						P122lAtuCb( .F. ) //seta _lAtuCubo := .F.
						Exit
					EndIf
				EndIf
			EndDo
		EndIf
		
		AL1->( dbSkip() )
	
	EndDo

		
	For nZ := 1 TO Len(aTdaNiveis)
		aNivel := aTdaNiveis[nZ] 		
		
		//deletar a procedure de nivel superior correspondente ao cubo
		If Len(aNivel) > 0
			For nX := 1 TO Len(aNivel)
				If Len(aNivel[nX]) > 0
					If !Empty(aNivel[nX,2])  //apagar arquivo temporario que era utilizado pela procedure
						MsErase(aNivel[nX,2])
					EndIf					
				EndIf
			Next nX
		EndIf
			
	Next nZ
	
EndIf

Return

//-----------------------------------------------------------------------------------------------//
//exclusao dos movimentos orcamentarios na revisao da planilha
//-----------------------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P122CDELL   ºAutor  ³Microsiga           º Data ³  24/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcão responsavel pela chamada das procedures.               º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA122                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P122CDELL(cPlanRev, cPlanVers, cItemProc)
	Local lRet		:= .T.

	lRet   := PCOA122_Del( cItemProc ,cPlanRev,cPlanVers)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³PCOA122_Del³ Autor ³                        ³ Data ³21.06.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria procedure de exclusao do AKD                             ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PCOA122_Del( cItemProc as character ,cPlanRev as character,cPlanVers as character)
Local cQuery := "" as character
Local lRet 	 := .T. as logical

cQuery :="    SELECT AKD.R_E_C_N_O_"+CRLF
cQuery +="      FROM "+RetSqlName("AKD")+" AKD, "+RetSqlName("AK2")+ " AK2 "+CRLF
cQuery +="     WHERE AKD_FILIAL  = '"+xFilial("AKD")+"'"+CRLF
cQuery +="       and AKD_PROCES  = '000252'"+CRLF
cQuery +="       and AKD_ITEM    = '"+cItemProc+"'"+CRLF
cQuery +="       and AKD_CHAVE   = 'AK2' "

If AllTrim(TcGetDb()) == 'POSTGRES'
	cQuery += "||RPAD(AK2_FILIAL,"+GetTamAK2("AK2_FILIAL")+",' ')"
	cQuery += "||RPAD(AK2_ORCAME,"+GetTamAK2("AK2_ORCAME")+",' ')"
	cQuery += "||RPAD(AK2_VERSAO,"+GetTamAK2("AK2_VERSAO")+",' ')"
	cQuery += "||RPAD(AK2_CO,"+GetTamAK2("AK2_CO")+",' ')"
	cQuery += "||RPAD(AK2_PERIOD,"+GetTamAK2("AK2_PERIOD")+",' ')"
	cQuery += "||RPAD(AK2_ID,"+GetTamAK2("AK2_ID")+",' ')"+CRLF   //-- PRIMEIRO INDICE DO AK2
Else
	cQuery +="||AK2_FILIAL||AK2_ORCAME||AK2_VERSAO||AK2_CO||AK2_PERIOD||AK2_ID"+CRLF   //-- PRIMEIRO INDICE DO AK2
EndIf

cQuery +="       and AKD_TIPO    IN ('1' , '2' )"+CRLF
cQuery +="       and AKD.D_E_L_E_T_  = ' '"+CRLF
cQuery +="       and AK2_FILIAL  = '"+xFilial("AK2")+"'"+CRLF
cQuery +="       and AK2_ORCAME  = '"+cPlanRev+"'"+CRLF
cQuery +="       and AK2_VERSAO  = '"+cPlanVers+"'"+CRLF
cQuery +="       and AK2.D_E_L_E_T_  = ' '"+CRLF


cQuery:= ChangeQuery(cQuery)

cQuery :=" DELETE FROM "+RetSqlName("AKD")+" WHERE R_E_C_N_O_ IN ( " +  cQuery + " ) "


lRet := TcSqlExec(cQuery) >= 0

TcRefresh(RetSqlName("AKD"))

If !lRet
	MsgAlert(tcsqlerror(),STR0038)  //"Erro na Revisao - Exclusão de Lancamentos por procedure! "
EndIf

Return(lRet)

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}P122lAtuCb(lAtualiza)
Função responsavel por controlar a atualização do cubo, setando a variavel local _lAtuCubo

@author TOTVS
@since  14/07/2022
@version 12
*/
//-----------------------------------------------------------------------------------------
Function P122lAtuCb(lAtualiza)
Default lAtualiza := .T.

_lAtuCubo     := lAtualiza

Return

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}GetTamAK2(cCampo)
Função responsavel por retornar o tamanho do campo AK2

@author TOTVS
@since  23/03/2026
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function GetTamAK2(cCampo as character)
DEFAULT cCampo :=  ""

If _jTamAK2 == Nil
	_jTamAK2 := JsonObject():New()
EndIf

If _jTamAK2[cCampo] == Nil
	_jTamAK2[cCampo] := cValToChar(TamSX3(cCampo)[1])
EndIf

Return _jTamAK2[cCampo]
