#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA193.CH"
#INCLUDE "fwschedule.ch"

#DEFINE DEF_DB_ORACLE               "ORACLE"
#DEFINE DEF_DB_MSSQL                "MSSQL"
#DEFINE DEF_DB_POSTGRES             "POSTGRES"
#DEFINE DEF_DB_DB2                  "DB2"
#DEFINE DEF_DB_INFORMIX             "INFORMIX"
#DEFINE DEF_DB_MYSQL                "MYSQL"
#DEFINE DEF_DB_CTREESQL             "CTREESQL"
#DEFINE DEF_DB_OPENEDGE             "OPENEDGE"
#DEFINE DEF_DB_SYBASE               "SYBASE"

Static __lCTB193 		:= Nil
Static __lCusto		:= .F.
Static __lItem		:= .F.
Static __lCLVL		:= .F.
Static __cCTB193	:= ""
Static __nQtdEntid	:= Nil
Static __cMvSoma    := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA193
Processamento de saldo em Fila


@author  Alvaro Camillo Neto
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Function CTBA193() 

Local cThread		:= cValToChar(ThreadID())

Local aArea		:= GetArea()
Local aResult 	:= {}

dbSelectArea("CT2")
dbSelectArea("CQA")
 
If __lCTB193 == Nil
	__cCTB193		:= GetSPName("CTB193","23")
	__lCTB193		:= ExistProc(__cCTB193,EngSPS23Signature())
	__lCusto		:= CtbMovSaldo("CTT")
	__lItem		:= CtbMovSaldo("CTD")
	__lCLVL		:= CtbMovSaldo("CTH")
EndIf

If __cMvSoma == Nil
	__cMvSoma := IIf(SuperGetMV("MV_SOMA", .F., "1") == 1, '1','2')
EndIf

If AliasInDic("QLG") .and. FindFunction("C190IsActiv")
	//Verifico se alguÈm est· rodando o CTBA190
	//Enquanto exisitir registro de execuÁ„o da CTBA190, a fila ficar· pausada	
	If C190IsActiv("CTBA190")
		//Pauso a fila e deleto o registro do CTBA193  da tabela QLG
		C190DelQLG(nil,.T.)
		Sleep(1000)
		
		Return
	EndIf

	C190GrvQLG("CTBA193")
Else
	If LockByName("C190PAUSA",.T.,.F.)		
		UnLockByName("C190PAUSA")
	Else		
		Return
	EndIf
EndIF


If LockByName("CTBA193",.T.,.F.)  	
	If __lCTB193
		//Procedure
		aResult := TCSPEXEC( xProcedures(__cCTB193),;
		    cFilAnt ,;
		 	Iif(__lCusto,'1','0'),;
			Iif(__lItem,'1','0'),;
			Iif(__lCLVL,'1','0'),;
			CTBInTrans(),;
			__cMvSoma) 

		If Empty(aResult) .or. aResult[1] = "0"
			Conout("------ " + STR0001 +"--------")//"Erro na chamada da procedure - Saldos Cont·beis em Fila" 
		EndIf
	Else
		//Processamento ADVPL
		CT93ADV()
	EndIf
	UnLockByName("CTBA193",.T.,.F.)
EndIf

RestArea(aArea)

//Limpeza de Array
aSize(aArea,0)
aSize(aResult,0)

aArea 	:= Nil
aResult	:= Nil

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} CT93ADV
Processamento de saldo em Fila via ADVPL - Sem Procedure


@author  Alvaro Camillo Neto
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------

Static Function CT93ADV()
Local cQuery		:= ""
Local cTabTmp		:= GetNextAlias()
Local nRecCQA		:= 0
Local cContaDeb	:= ""
Local cContaCrd	:= ""
Local cCustoDeb	:= ""
Local cCustoCrd	:= ""
Local cItemDeb	:= ""
Local cItemCrd	:= ""
Local cClassDeb	:= ""
Local cClassCrd	:= ""
Local cTipo		:= ""
Local dData		:= CTOD("")
Local cMoeda		:= ""
Local nValor		:= 0
Local cTpSald		:= 0
Local dDataLP		:= CTOD("")		
Local cFilMov		:= ""
Local lCtbIsCube  := CtbIsCube()
Local aEntid		:= {}
Local nEntid		:= 0

dbSelectArea("CT2")
dbSelectArea("CQA")

If __nQtdEntid == NIL
	__nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf	

cQuery += " SELECT R_E_C_N_O_ RECCQA, CQA_FILCT2,CQA_DATA,CQA_LOTE,CQA_SBLOTE,CQA_DOC,CQA_LINHA,CQA_EMPORI,CQA_FILORI,CQA_MOEDLC,CQA_TPSALD " +CRLF 
cQuery += " FROM  " +CRLF 
cQuery += " 	"+RetSQLName("CQA")+" CQA " +CRLF 
cQuery += " WHERE " +CRLF 
cQuery += " 	CQA_FILIAL = '"+xFilial("CQA")+"' AND " +CRLF 
cQuery += " 	CQA_FILCT2 = '"+xFilial("CT2")+"' AND " +CRLF 
cQuery += " 	D_E_L_E_T_ = '' " +CRLF 
cQuery += " 	ORDER BY  CQA_DATA,CQA_LOTE,CQA_SBLOTE,CQA_DOC,CQA_LINHA " +CRLF 

cQuery := ChangeQuery(cQuery)

If ( Select ( cTabTmp) <> 0 )
	dbSelectArea ( cTabTmp )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTmp,.T.,.F.)
TCSetField(cTabTmp,"CQA_DATA","D",08,0)
TCSetField(cTabTmp,"RECCQA","N",10,0)

CT2->(DbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC 

While (cTabTmp)->(!EOF())
	nRecCQA := (cTabTmp)->RECCQA

	cFilCT2 	:= (cTabTmp)->CQA_FILCT2
	dData	 	:= (cTabTmp)->CQA_DATA
	cLote 		:= (cTabTmp)->CQA_LOTE
	cSubLote	:= (cTabTmp)->CQA_SBLOTE
	cDoc		:= (cTabTmp)->CQA_DOC
	cLinha		:= (cTabTmp)->CQA_LINHA
	cEmpOri	:= (cTabTmp)->CQA_EMPORI
	cFilOri	:= (cTabTmp)->CQA_FILORI
	cMoeda		:= (cTabTmp)->CQA_MOEDLC
	cTpSald	:= (cTabTmp)->CQA_TPSALD	
	
	If CT2->(dbSeek( cFilCT2 + DTOS(dData) + cLote + cSubLote + cDoc + cLinha + cTpSald + cEmpOri + cFilOri + cMoeda ))
		cTipo		:= CT2->CT2_DC	
		cContaDeb	:= CT2->CT2_DEBITO	
		cContaCrd	:= CT2->CT2_CREDIT	
		nValor		:= CT2->CT2_VALOR	
		cCustoDeb	:= CT2->CT2_CCD	
		cCustoCrd	:= CT2->CT2_CCC	
		cItemDeb	:= CT2->CT2_ITEMD	
		cItemCrd	:= CT2->CT2_ITEMC	
		cClassDeb	:= CT2->CT2_CLVLDB	
		cClassCrd	:= CT2->CT2_CLVLCR		
		dDataLP	:= CT2->CT2_DTLP
		cFilMov	:= CT2->CT2_FILORI
		
		GRAVACQ("CT1",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		
		If !Empty(cCustoDeb) .Or. !Empty(cCustoCrd)
			GRAVACQ("CTT",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		EndIf 
	
		If !Empty(cItemDeb) .Or. !Empty(cItemCrd)
			GRAVACQ("CTD",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		EndIf 
		
		If !Empty(cClassDeb) .Or. !Empty(cClassCrd)
			GRAVACQ("CTH",3,cContaDeb,cContaCrd,cCustoDeb,cCustoCrd,cItemDeb,cItemCrd,cClassDeb,cClassCrd,/*cIdent*/,cTipo,dData,cMoeda,nValor,cTpSald,/*lReproc*/,/*lAtSldBase*/,/*lZera*/,dDataLP,/*lTrbProc*/,/*cOperacao*/,cFilMov)
		EndIf
		
		If __nQtdEntid > 4
			For nEntid := 1 TO ( __nQtdEntid - 4 ) // quatro entidades sai padrao Conta/Centro Custo/Item Contabil/Classe de Valor
				cCampoDeb 		:= "CT2_EC"+StrZero(nEntid+4,2)+"DB"
				cCampoCred		:= "CT2_EC"+StrZero(nEntid+4,2)+"CR"
				If CT2->(FieldPos(cCampoDeb)) > 0 .And. CT2->(FieldPos(cCampoCred)) > 0
					aAdd(aEntid, { CT2->&(cCampoDeb), CT2->&(cCampoCred)} )
				EndIf
			Next
		EndIf
		
		If lCtbIsCube .And. Len(aEntid) > 0
			CtbGravCub( nValor, cTipo, cTpSald, cMoeda, dData, cContaDeb, cContaCrd, cCustoDeb, cCustoCrd, cItemDeb, cItemCrd, cClassDeb, cClassCrd, aEntid)
		EndIf

		CQA->(dbGoTo(nRecCQA))
		RecLock("CQA",.F.)
			CQA->(dbDelete())	
		MsUnLock() 
	EndIf
	
	(cTabTmp)->(dbSkip())
EndDo

dbSelectArea ( cTabTmp )
dbCloseArea ()

aSize( aEntid , 0 )
aEntid := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  Alvaro Camillo Neto
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            ,;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam

//-------------------------------------------------------------------
/*{Protheus.doc} VerIDProc

###### IMPORTANTE ######

CONFORME ORIENTADO PELA ENGENHARIA, N√O DEVEMOS EXCLUIR ESSA FUN«√O

A REMO«√O DESSA FUN«√O PODE CAUSAR PROBLEMAS EM CLIENTES QUE AINDA 
UTILIZAM O ISNTALADOR ANTIGO */
//-------------------------------------------------------------------  
Static Function VerIDProc()
Return '015'

//-------------------------------------------------------------------
/*{Protheus.doc} EngSPS23Signature
Identifica a seqUencia de controle do fonte ADVPL com a     
stored procedure, qualquer alteracao que envolva diretamente
a stored procedure a variavel sera incrementada.            
Procedure CTB001                                            

Caso seja alterado a numeraÁ„o deve alterar tambÈm a mesma numeracao das funcoes legado VerIdProcX

@author Marcelo Pimentel 
                   
@version P12
@since   24.07.2007
@return  IdProc
@obs	 
*/
//-------------------------------------------------------------------   
// Processo 23 - PROCESSAMENTO DE SALDO CONTABIL EM FILA
Function EngSPS23Signature(cProcess as character)
Local cAssinatura as character

cAssinatura := '015'

Return cAssinatura

// Processo 23 - ATUALIZA√á√ÉO DE SALDOS ONLINE (MV_CTBSALD = '2')
Function EngOn23Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character)
Local cNomeTab := "0_SP"

	// Faz a troca das tags "###" nos nomes de tabelas espec√≠ficas do processo
	cBuffer := StrTran( cBuffer, "TRW###", "TRW"+cEmpresa+cNomeTab )

Return .T.

// Processo 23 - ATUALIZA√á√ÉO DE SALDOS ONLINE (MV_CTBSALD = '2')
Function EngSPS23Delete(cProcesso as character, cEmpresa as character, cError as character)
Local cNomeTab   as character
Local cCTB185    := IIf(FindFunction("GetSPName"), GetSPName("CTB185","06"), "CTB185")

	cNomeTab   := "0_SP"

	//Verifica se Procedure CTB185 est· instalada, n„o deve excluÌr tabela TRW
	If ! ExistProc(cCTB185)
		If TcCanOpen("TRW"+cEmpresa+cNomeTab)
			TcDelFile("TRW"+cEmpresa+cNomeTab)
		EndIf
	EndIf
Return .T.

// Processo 23 - ATUALIZA√á√ÉO DE SALDOS ONLINE (MV_CTBSALD = '2')
Function EngPre23Compile(cProcesso as character, cEmpresa as character, cError as character)
Local cNomeTab := "0_SP"

	If TcCanOpen("TRW"+cEmpresa+cNomeTab)
		TcDelFile("TRW"+cEmpresa+cNomeTab)
	EndIf

	EngSPSWorkTable("CT2","TRW"+cEmpresa+cNomeTab,{},.F.)

Return .T.

// Processo 23 - PROCESSAMENTO DE SALDO CONT√ùBIL EM FILA
Function EngPos23Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)

	Local cNomeTab := "0_SP"

	If TcCanOpen("TRW"+cEmpresa+cNomeTab)
		TcDelFile("TRW"+cEmpresa+cNomeTab)
	EndIf

	EngSPSWorkTable("CT2","TRW"+cEmpresa+cNomeTab,{},.F.)

	Do Case

		Case cLocalDB == DEF_DB_INFORMIX

			If cProcName $ "CTB300/CTB310"
				cBuffer := StrTran(cBuffer, "GROUP BY CT2_FILIAL , SUBSTR ( CT2_DATA , 1 , 6 )", "GROUP BY CT2_FILIAL , 2")
			EndIf

		Case cLocalDB == DEF_DB_POSTGRES

			If cProcName $ "CTB300/CTB310"
				cBuffer := StrTran(cBuffer, "GROUP BY CT2_FILIAL , SUBSTR ( CT2_DATA , 1 , 6 )", "GROUP BY CT2_FILIAL , 2")
			EndIf

	EndCase

Return  .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} CTBInTrans
Indica se est· ou n„o em transaÁ„o, esta funÁ„o È para simplicaÁ„o
para retorna:
0 - Indica N√O ESTAR em transaÁ„o 
1 - Indica ESTAR em transaÁ„o

@author Nilton Rodrigues - Eng. Protheus - Performance
@since 02/06/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function CTBInTrans
Return if(InTransAct(),'1','0')
