#Include "PROTHEUS.CH"
#Include "CTBA351.CH"

#DEFINE D_PRELAN	"9"

STATIC __lBlind  := IsBlind()
STATIC __nThread := Nil
STATIC _oQryCtb350  := Nil

STATIC cSayCusto := Nil
STATIC cSayItem	 := Nil
STATIC cSayClVL	 := Nil
STATIC lAtSldBase
STATIC lCusto
STATIC lItem
STATIC lClVl
STATIC lCtb350Ef
STATIC lEfeLanc
STATIC lCT350TSL
Static lPE351Qry 	:= ExistBlock("CT351QRY")

/*-------------------------------------------------------------------------
Funcao		  : CTB351PROC
Autor         : Renato Campos / Alexandre TOSTA
Data          : 12/09/2016
Uso           : Efetua a validação dos dados do lançamento
-------------------------------------------------------------------------*/

Function CTB351PROC(lEnd, aMv_Par, cTbTmpShar, lImprRel)
Local cAliasTrb1:=  ""
Local lSimula   := .F. //(mv_par12==2)
Local cCTB240	:= IIF(FindFunction("GetSPName"), GetSPName("CTB240","07"), "CTB240")
Local nX
Local cQueryInc := ""
Local cAliasInc := GetNextAlias()
Local aItensProc:= {}
Local aRegMin   := {}
Local aRegMax   := {}
Local nRegua    := 0
Local lEfLote   := .F.

Private aProcFilDt := {}

Default lEnd	:= .F.
Default aMv_Par	:= {}
Default cTbTmpShar := ""
Default lImprRel := .T.
Default lErro := .F.

If Empty(aMv_Par)
	Pergunte( "CTB350" , .F. )
Else
	For nX := 1 TO Len(aMv_Par)
		&( "MV_PAR"+StrZero(nX, 2) ) := aMv_Par[nX]
	Next
EndIf

lSimula := (mv_par12==2)
lEfLote := (mv_par05==1)

//-- Verifica a quantidade de threads para o processamento.
__nThread   := GetNewPar( "MV_CT350TH", 1 )

lAtSldBase	:= ( GetMv("MV_ATUSAL") == "S" )
lCusto		:= CtbMovSaldo("CTT")
lItem 		:= CtbMovSaldo("CTD")
lClVl		:= CtbMovSaldo("CTH")
lCtb350Ef	:= ExistBlock("CTB350EF")
lEfeLanc 	:= ExistBlock("EFELANC")
lCT350TSL	:= GetNewPar( "MV_CT350SL", .T.)			///PARAMETRO NÃO PUBLICADO NA CRIAÇÃO (15/03/07-BOPS120975)

//----------------------------------------------------------------------------------------------
// Nao processsa caso o parametro MV_CT350SL seja .T. e a procedure CTB240 nao esteja instalada
//----------------------------------------------------------------------------------------------
If lCT350TSL .And. !ExistProc(cCTB240,VerIDProc())
	Help(" ",1,"CTB351PROC",,STR0013,1,0) //"Para o processo de efetivação multithread (MV_CT350TH) com atualização de saldo (MV_CT350L), é necessária a instalação da Stored Procedure CTB240.SQL, presente no pacote p12_07.sps."
	Return(.F.)
EndIf

cAliasTrb1 := Ctb351Qry(aMv_Par, @nRegua) // envia agrupado por lote

If !(cAliasTrb1)->(Eof())
	nCount  := 0
	cFilOld := ""
	dDatOld := StoD("")
	cLotOld := ""

	ProcRegua(nRegua)

	While !(cAliasTrb1)->(Eof())		
		// chama o processo de validação
		IncProc(STR0002) //"Iniciando validação dos dados via multi-thread."

		aRegMin := {(cAliasTrb1)->CT2_FILIAL, (cAliasTrb1)->CT2_DATA, (cAliasTrb1)->CT2_LOTE, (cAliasTrb1)->CT2_SBLOTE, (cAliasTrb1)->CT2_DOC}
		aRegMax := {(cAliasTrb1)->CT2_FILIAL, (cAliasTrb1)->CT2_DATA, (cAliasTrb1)->CT2_LOTE, (cAliasTrb1)->CT2_SBLOTE, (cAliasTrb1)->CT2_DOC}		
		aAdd(aItensProc, {aRegMin, aRegMax})
		
		(cAliasTrb1)->(dbSkip())
	EndDo
	
	C351MLTTHR(aItensProc, aMv_Par, cTbTmpShar, lEfLote)		
	
	If cTbTmpShar <> NIL .And. !Empty(cTbTmpShar)

		/* Retirado, pois não conseguimos cobrir no issue x cobertura
		// Vou deixar comentado, caso futuramente ocorra algum erro nesse trecho ou descobrirmos o cenário para reproduzir
		If Select("TRB350REL") <= 0
			dbUseArea( .T., "TOPCONN", cTbTmpShar, "TRB350REL", .F., .F. )
			TcRefresh("TRB350REL")
		Endif
		*/

		DbSelectArea("TRB350REL")
		DbGoTop()

		//query para ver se ocorreu alguma inconsistencia na xFilial("CT2") que foi processada
		cQueryInc := " SELECT CXFILCT2, DOC FROM "+cTbTmpShar
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryInc),cAliasInc,.T.,.F.)

		If (cAliasInc)->( !Eof() )
			//------------------------------------
			// Imprime relatorio de consistencias
			//------------------------------------
			lErro := .T.
		ElseIf lSimula 
			lErro := .F.
			CT350GrInc(,,,,,,STR0004) //"Não foram encontrados erros."
		Endif
		//fecha alias da query e retorna para TRB350REL
		(cAliasInc)->( dbCloseArea() )
		DbSelectArea("TRB350REL")
		
		If lImprRel  
			If lSimula .OR. lErro
				If lSimula
					titulo+=" - " +STR0005 //"Modo Simulação."
				EndIf
					
				C350ImpRel()
		
			EndIf
		EndIf
	EndIf
EndIf

If Select(cAliasTrb1) > 0
	(cAliasTrb1)->(dbCloseArea())
	_oQryCtb350:Destroy()
Endif

Return

/*-------------------------------------------------------------------------
Funcao		  : Ctb351Qry
Data          : 12/09/2016
Uso           : Monta e executa a criação do temporario de processamento.
-------------------------------------------------------------------------*/
Static Function Ctb351Qry(aMv_Par, nRegua)
Local cQuery 	:= ""
Local cQryUser  := ""
Local nX        := 0
Local nQry      := 0

DEFAULT aMv_Par := {}
DEFAULT nRegua  := 0

If Empty(aMv_Par)
	Pergunte( "CTB350" , .F. )
Else
	For nX := 1 TO Len(aMv_Par)
		&( "MV_PAR"+StrZero(nX, 2) ) := aMv_Par[nX]
	Next
EndIf

If _oQryCtb350 == Nil
	cQuery := " SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "	
	cQuery += "  FROM " + RetSqlName("CT2") + " CT2"
	cQuery += "  WHERE  "
	cQuery += "  	CT2_FILIAL BETWEEN ? AND ? AND "
	cQuery += "  	CT2_DATA   BETWEEN ? AND ? AND "
	cQuery += "  	CT2_LOTE   BETWEEN ? AND ? AND "
	cQuery += "  	CT2_SBLOTE BETWEEN ? AND ? AND "
	cQuery += "  	CT2_DOC    BETWEEN ? AND ? AND "
	cQuery += "  	CT2_TPSALD = ? AND "
	cQuery += "  	D_E_L_E_T_ = ? "
	cQuery += " GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "
	cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC "

	If lPE351Qry
		cQryUser := ExecBlock("CT351QRY",.F.,.F.,{cQuery})
		If !Empty(cQryUser) //se ponto de entrada retornou string query preenchida			
			cQryUser := C350ClearSQL(cQryUser)
			cQuery := cQryUser	
		EndIf 				
	EndIf

	_oQryCtb350 := FWExecStatement():New(cQuery)
EndIf

nQry := 1
_oQryCtb350:SetString(nQry++,mv_par15)
_oQryCtb350:SetString(nQry++,mv_par16)
_oQryCtb350:setDate(nQry++,mv_par03)
_oQryCtb350:setDate(nQry++,mv_par04)
_oQryCtb350:SetString(nQry++,mv_par01)
_oQryCtb350:SetString(nQry++,mv_par02)
_oQryCtb350:SetString(nQry++,mv_par09)
_oQryCtb350:SetString(nQry++,mv_par10)
_oQryCtb350:SetString(nQry++,mv_par13)
_oQryCtb350:SetString(nQry++,mv_par14)
_oQryCtb350:SetString(nQry++,D_PRELAN)
_oQryCtb350:SetString(nQry++,Space(1))

cAliasQry := GetNextALias()
_oQryCtb350:OpenAlias(cAliasQry)
TcSetField(cAliasQry,"CT2_DATA","D",8,0)

dbSelectArea(cAliasQry)
Count to nRegua
(cAliasQry)->(dbGoTop())

Return cAliasQry

/*-------------------------------------------------------------------------
Funcao		  : Ct351Valid
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Efetua a validação das linhas dos lançamentos via multithread
-------------------------------------------------------------------------*/
Function CT351VALID( aRegMin, aRegMax, aMv_Par, cTblTmpRel )

Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local lEnd := .F.
Local aErroTexto 	:= {}
Local aErro:= {}
Local cTpSldAtu 	:= ""
Local lEfLote		:= .F.
Local lEfDoc		:= .F.
Local lMostraLct	:= .F.
Local lSimula		:= .F.
Local nX
Local lCTBA351
Local nMVPar17      := 1 // Padrão é 1 = Sim.
Local aPergunte     := Ct351VPerg("CTB350")

//variaveis utilizada no CTBA350
Private cFilCT2 := xFilial("CT2")
Private OPCAO	:= 3

Default aRegMin = {}
Default aRegMax = {}
Default cTblTmpRel := ""

If Len(aRegMin) > 0 .And. Len(aRegMax) > 0
	
	cFilAnt := aRegMin[1]

	If Select("TRB350REL") <= 0
		dbUseArea( .T., "TOPCONN", cTblTmpRel, "TRB350REL", .T., .F. )
	Endif

	If Empty(aMv_Par)
		Pergunte( "CTB350" , .F. )
	Else
		For nX := 1 TO Len(aMv_Par)
			&( "MV_PAR"+StrZero(nX, 2) ) := aMv_Par[nX]
		Next
	EndIf

	cTpSldAtu 	:= mv_par07
	lEfLote		:= Iif(mv_par05 == 1,.T.,.F.)//.T. ->Efetiva sem bater Lote / .F. ->Nao efetiva sem bater Lote
	lEfDoc		:= Iif(mv_par06 == 1,.T.,.F.)//.T. ->Efetiva sem bater Doc / .F. ->Nao efetiva sem bater Doc
	lMostraLct	:= ( mv_par11 == 1 )
	lSimula		:= ( mv_par12 == 2 )

	If Len(aPergunte[2]) > 16
		nMVPar17 := MV_PAR17 // Efetivar Parcialmente? 1 = Sim; 2 = Não.
	EndIf

	If cSayCusto == Nil 
		cSayCusto := CtbSayApro("CTT")
	Endif

	If cSayItem == Nil
		cSayItem	:= CtbSayApro("CTD")
	Endif

	IF cSayClVL == Nil
		cSayClVL	:= CtbSayApro("CTH")
	Endif

	aErroTexto := ct350aerro()


	lCTBA351 := .T.
	ct350roda( aRegMin[1], @lEnd,aErro,aErroTexto,cTpSldAtu,lEfLote,lEfDoc,lMostraLct,lSimula, .T., aRegMin, aRegMax, nMVPar17, cTblTmpRel)

	lRet := lEnd

EndIF

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea:= nil

Return lRet

/*-------------------------------------------------------------------------
Funcao		  : CtbSqlExec
Autor         : Renato Campos
Data          : 12/09/2016
Uso           : Executa a instrução de banco via TCSQLExec
-------------------------------------------------------------------------*/
Static Function CtbSqlExec( cStatement )
Local bBlock	:= ErrorBlock( { |e| ChecErro(e) } )
Local lRetorno := .T.

BEGIN SEQUENCE
	IF TcSqlExec(cStatement) <> 0
		UserException( STR0011 + CRLF + TCSqlError()  + CRLF + ProcName(1) + CRLF + cStatement ) //"Erro na instrução de execução do SQL"
		lRetorno := .F.
	Endif
RECOVER
	lRetorno := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRetorno

//--------------------------------------------------
/*/{Protheus.doc} VerIDProc
Controle de versao da procedure CTB240.

@author Totvs
@since 27/12/2017
@version P12.1.17

@return caracter, versao da procedure CTB240
/*/
//--------------------------------------------------
Static Function VerIDProc()
Return "011"

/*/{Protheus.doc} Ct351VPerg
Retorna o grupo de pergunta utilizado pela rotina.
@type function
@author Totvs
@since 13/09/2023
@version P12.1.2210
@param character, cPerg, grupo de perguntas
@return array, perguntas
/*/
Static Function Ct351VPerg(cPerg)
//Verifica se a nova pergunta realmente foi criada, para não dar error log no cliente
Local oPerg	:= FWSX1Util():New()
Local aPergunte
oPerg:AddGroup(cPerg)
oPerg:SearchGroup()
aPergunte := oPerg:GetGroup(cPerg)

Return(aPergunte)

/*/{Protheus.doc} C351MLTTHR
Faz a distribuição das threas para efetivação

@type function
@author Totvs
@since 14/03/2025
@version P12.1.2410
/*/
Static Function C351MLTTHR(aItensProc, aMvPar, cTbTmpShar, lEfLote)
Local nI 	 := 0		
Local cError := ""
Local oGrid	 := Nil
Local nItens := 0
Local lVldLote := .T.
Local cChaveLt := ""
Local cChaveOld  := ""
Local cFilCT2  := ""
Local cData	 := ""
Local cLote	 := ""
Local cSubLote := ""

DEFAULT aItensProc := {}
DEFAULT aMvPar     := {}
DEFAULT cTbTmpShar := ""
DEFAULT lEfLote    := .F.

If Len(aItensProc) < __nThread
	__nThread := Len(aItensProc)
EndIf	

If __nThread == 1	

	If !lEfLote
		//Caso não efetive com lote divergente, valido o lote antes de distribuir nas threads 
		//Preciso fazer a validação antes para ter certeza que nenhuma thread está alterando a CT2 desse lote (Filial + Data + Lote)
		cFilCT2  := aItensProc[1,1][1]
		cData	 := DtoS(aItensProc[1,1][2])
		cLote	 := aItensProc[1,1][3] 
		cSubLote := aItensProc[1,1][4] 
		
		lVldLote := ct351VldLt(cFilCT2, cData, cLote, cSubLote)	
		
	EndIf

	If lVldLote
		CT351VALID(aItensProc[1,1], aItensProc[1,2], aMvPar, cTbTmpShar)
	EndIf

Else

	//Objeto do Controlador de Threads (Instancia para Execução das Threads)
	oGrid := FWIPCWait():New("CTBA350"+cEmpAnt,20000)

	//Inicia as Threads
	oGrid:SetThreads(__nThread)

	//Informa o Ambiente Para Execução da Thread
	oGrid:SetEnvironment( cEmpAnt, cFilAnt )

	//Função para ser executada na Thread
	oGrid:Start("CT351VALID")

	nItens := Len(aItensProc)

	ProcRegua(nItens)

	For nI := 1 to nItens	
		IncProc(STR0003+' ('+cValToChar(nI)+"/"+cValToChar(nItens)+')') //"Iniciando efetivação dos dados via multi-thread."		
		
		If !lEfLote
			//Caso não efetive com lote divergente, valido o lote antes de distribuir nas threads 
			//Preciso fazer a validação antes para ter certeza que nenhuma thread está alterando a CT2 desse lote (Filial + Data + Lote)
			cFilCT2  := aItensProc[nI,1][1]
			cData	 := DtoS(aItensProc[nI,1][2])
			cLote	 := aItensProc[nI,1][3] 
			cSubLote := aItensProc[nI,1][4] 
			
			cChaveLt := cFilCT2+cData+cLote+cSubLote

			If cChaveOld <> cChaveLt
				lVldLote := ct351VldLt(cFilCT2, cData, cLote, cSubLote)	
				cChaveOld := cChaveLt
			EndIf
			If !lVldLote
				loop
			EndIf
		EndIf

		oGrid:Go( aItensProc[nI,1], aItensProc[nI,2], aMvPar, cTbTmpShar)

	Next nI
		
	//Fechamento das Threads Iniciadas (O método aguarda o encerramentos de todas as Threads antes de retornar ao controle.
	oGrid:Stop()

	cError := oGrid:GetError()
	FreeObj(oGrid)
	oGrid := Nil

	If !Empty(cError)
		Help(,,"Error",,cError,1,0)
		lErro := .T.
	Endif
EndIf
		
Return 

/*/{Protheus.doc} C350ClearSQL
Prevenção na query retornada pelo ponto de entrada
retirando possível código indevido

@type function
@author Totvs
@since 14/03/2025
@version P12.1.2.2410
/*/
Static Function C350ClearSQL(cQryIN)
Local cQryOUT := ""
DEFAULT cQryIN := ""

cQryOUT := Upper(cQryIN)
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'DROP TABLE',''))
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'TRUNCATE ',''))
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'UPDATE ',''))
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'INSERT ',''))
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'DELETE ',''))
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'MERGE ',''))
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'CREATE ',''))
cQryOUT := IIf(Empty(cQryOUT),'',StrTran(cQryOUT,'ALTER ',''))

//Se não encontrou nada de errado, retorno a query original 
//para respeitar os caracteres minúsculos
If Upper(cQryIN) == cQryOUT
	cQryOUT := cQryIN
EndIf

Return cQryOUT

Static Function ct351VldLt(cFilCT2,cData,cLote,cSubLote)
Local lRet := .T.
Local aSaldo := {}
Local nCT6DEB := 0
Local nCT6CRD := 0
Local cDescInc := ""

//----------------------------------------------------
// Verifico se o lote esta batendo	em todas as moedas
// Nao informa o documento para conferir todo o lote
//----------------------------------------------------

	
CT2->(dbSetOrder(1)) //CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC
CT2->(dbSeek(cFilCT2 + cData + cLote + cSubLote ))

aSaldo := CTBA350Sld(cFilCT2, CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,/*CT2->CT2_DOC*/,CT2->CT2_TPSALD,CT2->CT2_MOEDLC)

If aSaldo[2] <> 0 .OR. aSaldo[3] <> 0	
	nCT6DEB := Round(aSaldo[2],2)
	nCT6CRD := Round(aSaldo[3],2)
	
	If nCT6DEB != nCT6CRD //Se debito e credito nao baterem
		lRet := .F.
		cDescInc := OemToAnsi(STR0012)
		CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,,CT2->CT2_MOEDLC,nCT6DEB,nCT6CRD,cDescInc) //Grava TMP com as inconsistencias 
	EndIf
Else	
	lRet := .F.
	//Gravo no arquivo temporario as inconsistencias
	cDescInc := OemToAnsi(STR0015)
	CT350GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,,CT2->CT2_MOEDLC,0,0,cDescInc)
Endif

Return lRet
