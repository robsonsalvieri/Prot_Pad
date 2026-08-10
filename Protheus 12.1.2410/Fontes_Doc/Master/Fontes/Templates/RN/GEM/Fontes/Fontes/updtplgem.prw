#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAtuSIX ³ Autor ³Fabio Rogerio Pereira  ³ Data ³19/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SIX                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Implantacao PMS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UpdTPLGEM()

cArqEmp := "SigaMat.Emp"
nModulo		:= 05
__cInterNet := Nil
PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
Private __lPyme  := .F.

#IFDEF TOP
	TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top
#ENDIF

Set Dele On

GEMOpenSM0(.T.)
DbGoTop()

lHistorico 	:= MsgYesNo("Atualização das tabelas e campos do template GEM, Confirma?", "Update") 
lEmpenho	:= .F.
lAtuMnu		:= .F.

DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE "Update"
	
ACTIVATE 	WINDOW oMainWnd ICONIZED ;
			ON INIT (If(lHistorico ,Processa({||UpdTables()} ,"Atualização das tabelas") ,.F.), oMainWnd:End())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAtuSIX ³ Autor ³Fabio Rogerio Pereira  ³ Data ³19/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SIX                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Implantacao PMS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEMOpenSM0(lShared)
	Local lOpen := .F.                  
	Local i := 0 
	
	For i := 1 To 20
	
		dbUseArea(.T., , "SIGAMAT.EMP", "SM0", lShared, .F.) 
		
		If !Empty(Select("SM0")) 
			lOpen := .T. 
			dbSetIndex("SIGAMAT.IND") 
			Exit	
		EndIf
		Sleep(500) 
	Next 
	
Return lOpen

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAtuSX3 ³ Autor ³Fabio Rogerio Pereira  ³ Data ³19/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX3                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Implantacao PMS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UpdTables()
Local nRecno   	:= 0   
Local nX       	:=0
Local nItem 		:=0
Local nRecAtu 	:= 0
Local aAreaSM0 	:= {}
Local cItem 		:= "01"
Local cCampo
Local cFiltro  	:= ""
Local cAliasTrb	:= ""
Local nIndex   	:= 0
Local cAliasLIT 	:= GetNextAlias()
Local cQuery 		:= ""    
Local aContratos 	:= {}
Local nReg 			:= 0

While SM0->(!Eof())
    
	nRecAtu := SM0->(Recno())
	aAreaSM0 := SM0->(GetArea())
     
	RpcSetType(3)
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	RestArea(aAreaSM0)
    
	SM0->(dbGoto(nRecAtu))
	RpcClearEnv()
	GEMOpenSM0(.F.)
	
	SM0->(dbGoto(nRecAtu))
	SM0->(dbSkip())

	If SM0->(! Eof())
		nRecno := SM0->(Recno())
		SM0->(DbGoTo(nRecno))
	EndIf	

EndDo

dbSelectArea("SM0")
dbGotop()
		
While SM0->(!Eof())

	nRecAtu := SM0->(Recno())
	aAreaSM0 := SM0->(GetArea())
    
	RpcSetType(3)
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)

	RestArea(aAreaSM0)

	dbSelectArea("SM0")
	dbGoto(nRecAtu)		
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	If HasTemplate("LOT")
		dbGoto(nRecAtu)		
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		If SX3->(dbSeek("LK5_ESTRUT"))
			RecLock("SX3",.F.)
			SX3->X3_RELACAO := "Gem140Desc()"
			MsUnlock()
		EndIf             


		If SX3->(dbSeek("LJN_TPPRIC"))
			RecLock("SX3",.F.)
			SX3->X3_WHEN := "t_VerWhenLJN()"
			MsUnlock()
		EndIf             
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		If SX3->(dbSeek("LJD_NCONTR"))
			RecLock("SX3",.F.)
			SX3->X3_VALID := '(ExistCPO("LIT",M->LJD_NCONTR,2) .AND. T_GMContrStatus( M->LJD_NCONTR )) .OR. (T_GMDistrAprov(M->LJD_NCONTR))'
			MsUnlock()
		EndIf 

		dbSelectArea("SX3")
		dbSetOrder(2)
		If SX3->(dbSeek("LIQ_STATUS"))
			RecLock("SX3",.F.)
			SX3->X3_VALID := 'ExistCpo("SX5","IT"+M->LIQ_STATUS,1) .AND. T_GM010Vld(M->LIQ_STATUS) .AND. T_GM010Chk(M->LIQ_STATUS)'
			MsUnlock()
		EndIf 
	ENDIF	  
	
	UpdAtuLIT()
		
	SM0->(dbGoto(nRecAtu))
	SM0->(dbSkip())

	If SM0->(! Eof())
		nRecno := SM0->(Recno())
		SM0->(DbGoTo(nRecno))
	EndIf	
	
EndDo

Alert("Fim da atualização")

Return(.T.)


//user function para chamada da atualizacao dos campos para 9 posicoes
User Function UpdGEMSINIEF()

cArqEmp := "SigaMat.Emp"
nModulo		:= 05
__cInterNet := Nil
PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
Private __lPyme  := .F.

#IFDEF TOP
	TCInternal(5,'*OFF') //-- Desliga Refresh no Lock do Top
#ENDIF

Set Dele On

GEMOpenSM0(.T.)
DbGoTop()

lHistorico 	:= MsgYesNo("Atualização dos campos do template GEM para o SINIEF, Confirma?", "Update") 
lEmpenho	:= .F.
lAtuMnu		:= .F.

DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE "Update"
	
ACTIVATE 	WINDOW oMainWnd ICONIZED ;
			ON INIT (If(lHistorico ,Processa({||AuxGEMSINIEF()} ,"Atualização das tabelas") ,.F.), oMainWnd:End())

Return
               
//funcao de acerto dos campos para 9 posicoes
Static Function AuxGEMSINIEF()
Local nRecno   := 0
Local nCnt     :=0

Local nRecAtu := 0
Local aAreaSM0 := {}

While SM0->(!Eof())
    
	nRecAtu := SM0->(Recno())
	aAreaSM0 := SM0->(GetArea())
     
	RpcSetType(3)
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	RestArea(aAreaSM0)
    
	SM0->(dbGoto(nRecAtu))
	RpcClearEnv()
	GEMOpenSM0(.F.)
	
	SM0->(dbGoto(nRecAtu))
	SM0->(dbSkip())

	If SM0->(! Eof())
		nRecno := SM0->(Recno())
		SM0->(DbGoTo(nRecno))
	EndIf	

EndDo

dbSelectArea("SM0")
dbGotop()
		
While SM0->(!Eof())

	nRecAtu := SM0->(Recno())
	aAreaSM0 := SM0->(GetArea())
    
	RpcSetType(3)
	RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)

	RestArea(aAreaSM0)

	dbSelectArea("SM0")
	dbGoto(nRecAtu)		
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	If HasTemplate("LOT")
		dbGoto(nRecAtu)		
		
		dbSelectArea("SXG")
		dbSetOrder(1)
		If dbSeek("018") // Grupo do documento de entrada/saida
		
			// tamanho do campo para o grupo 018
			nSize := SXG->XG_SIZE 
			
			aSX2Alias := {}
			
			aSX3Field := {}
			aAdd( aSX3Field ,{"LIT" ,"LIT_DOC" })
			aAdd( aSX3Field ,{"LIU" ,"LIU_DOC" })
			aAdd( aSX3Field ,{"LIT" ,"LIT_DUPL"})
			aAdd( aSX3Field ,{"LIW" ,"LIW_NUM" })
			aAdd( aSX3Field ,{"LIY" ,"LIY_NUM" })
			aAdd( aSX3Field ,{"LJA" ,"LJA_DOC" })
			aAdd( aSX3Field ,{"LJA" ,"LJA_DUPL"})
			aAdd( aSX3Field ,{"LJB" ,"LJB_DOC" })
			aAdd( aSX3Field ,{"LJE" ,"LJE_NUM" })
			aAdd( aSX3Field ,{"LJV" ,"LJV_NUM" })
			aAdd( aSX3Field ,{"LJX" ,"LJX_NUM" })
			aAdd( aSX3Field ,{"LJT" ,"LJT_NUM" })
			aAdd( aSX3Field ,{"LIX" ,"LIX_NUM" })
			aAdd( aSX3Field ,{"LK7" ,"LK7_NUM" })
			
			ProcRegua(Len(aSX3Field))
			
			For nCnt := 1 To Len(aSX3Field)
			
				IncProc("Atualizando o dicionario de campos...")

				dbSelectArea("SX3")
				dbSetOrder(2) // X2_CHAVE	
				If dbSeek(aSX3Field[nCnt ,02])
					If SX3->X3_ARQUIVO == aSX3Field[nCnt ,01]
					
						If aScan(aSX2Alias,{|x| x == SX3->X3_ARQUIVO })==0
							aAdd(aSX2Alias ,SX3->X3_ARQUIVO)
						EndIf
					
						RecLock("SX3",.F.)
							SX3->X3_TAMANHO := nSize
							SX3->X3_GRPSXG  := "018"
						MsUnLock()
						dbCommit()
					EndIf
					
				EndIf
			Next nCnt

       		ProcRegua(Len(aSX2Alias))
			__SetX31Mode(.F.)
			For nCnt := 1 To Len(aSX2Alias)
				IncProc("Atualizando a estrutura da tabela: " +aSX2Alias[nCnt])
				If Select(aSX2Alias[nCnt])>0
					dbSelecTArea(aSX2Alias[nCnt])
					dbCloseArea()
				EndIf
				X31UpdTable(aSX2Alias[nCnt])
				If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Erro!!!", "Falha na atualizacao da tabela: " + aSX2Alias[nCnt] + ". ", {"OK"},2)
				EndIf
			Next nX
			
			If Len(aSX2Alias) >0
				Alert("Atenção!!!" +chr(13)+chr(10) +;
				      "Foram atualizados " + AllTrim(str(Len(aSX2Alias))) + " tabelas referentes ao SINIEF.")
			EndIf
			
		Else
			Alert("Atenção!!!" +chr(13)+chr(10) +;
			      "O grupo de campo 018 - Documento de entrada/saida não existe. " +chr(13)+chr(10) +;
			      "Verifique se o atualizador do SINIEF foi executado anteriormente.")
		EndIf
	EndIf      
	
 
	//////////////// /////////////////////////////////////////////////////////////////////////////////////////

	dbSelectArea("SM0")
	dbGoto(nRecAtu)

	aAreaSM0 := SM0->(GetArea())
	
	RpcClearEnv()
	
	RestArea(aAreaSM0)
		
	GEMOpenSM0(.F.)

	dbSelectArea("SM0")
	dbGoto(nRecAtu)
	SM0->(dbSkip())
	
	If SM0->(! Eof())
		nRecno := SM0->(Recno())
		SM0->(DbGoTo(nRecno))
	EndIf
	
EndDo

Alert("Fim da atualização")

Return(.T.)
// Funcao para atualizar tabela LIT
STATIC Function UpdAtuLIT()
Local nRecno   	:= 0   
Local nX       	:=0
Local nItem 		:=0
Local nRecAtu 	:= 0
Local aAreaSM0 	:= {}
Local cItem 		:= "01"
Local cCampo
Local cFiltro  	:= ""
Local cAliasTrb	:= ""
Local nIndex   	:= 0
Local cAliasLIT 	:= GetNextAlias()
Local cQuery 		:= ""    
Local aContratos 	:= {}
Local nReg 			:= 0
//
// Atualiza o campo LIT_ORIGEM para possibilitar o correto funcionamento 
// de cancelar um contrato na cessao de direito
//
dbSelectArea("LIT")
ProcRegua(LIT->(RecCount()))
dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
dbSeek(xFilial("LIT"))
While !Eof() .and. xFilial("LIT") == LIT->LIT_FILIAL

	IncProc()
	
 	If LIT->(FieldPos("LIT_ORIGEM"))>0
		dbSelectArea("LIT") 
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If LIT->LIT_STATUS == "4"
  			#IFDEF TOP                     
     			cQuery := ""
     			// PESQUISA TODOS OS CONTRATOS QUE POSSUEM MESMO NUMERO DE DOCUMENTO E SERIE
     			cQuery := "Select LIT.LIT_NCONTR AS CONTRATO FROM " + RetSqlName( "LIT" ) + " LIT "
				cQuery += "WHERE LIT.LIT_SERIE = '" +LIT->LIT_SERIE+ "' AND "
				cQuery += "LIT.LIT_DOC = '" +LIT->LIT_DOC+ "' AND "
				cQuery += "LIT.D_E_L_E_T_ = ''"

				cQuery += "ORDER BY CONTRATO"
         	
  				cQuery := ChangeQuery( cQuery ) 
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasLIT, .F., .T. )           
				
				dbSelectArea(cAliasLIT)
				(cAliasLIT)->(dbGoTop())
				
				lContLIT := .F. 
				
				// PESQUISA PARA ENCONTRAR O PROXIMO NUMERO DE CONTRATO COM AS MESMAS
				// CARACTERISTICAS, POIS ESTE SERA O CONTRATO QUE FOI GERADO NA CESSAO
                                   
				// aContratos[1][1] --> Contrato original
				// aContratos[1][2] --> Contrato gerado a partir do original
                  nReg++
				While (cAliasLIT)->(!EOF())
					If !lContLIT
				   		IF (cAliasLIT)->CONTRATO == LIT->LIT_NCONTR
				   			lContLIT:= .T.  
					   		aadd(aContratos, {LIT->LIT_NCONTR, ""})
					   		(cAliasLIT)->(dbSkip())
					   	ELSE
					         (cAliasLIT)->(dbSkip())
					   	ENDIF  
				   	Else
			   			aContratos[nReg][2] := (cAliasLIT)->CONTRATO  
					   	Exit
					EndIf
				   
				EndDo     
				
				//Caso tabela temporaria aberta, fecha-la para re-uso
				If ( Select( cAliasLIT ) <> 0 )
					dbSelectArea ( cAliasLIT )
					dbCloseArea ()
				Endif 
				
			#ELSE
    		
     			cAliasTrb := "TRB"
				ChkFile("LIT",.F.,"TRB")
				cIndex	:= CriaTrab(nil,.f.)
				cFiltro  := "LIT_FILIAL='"+xFilial("LIT")+"' .And. "
				cFiltro  += "LIT_SERIE ='"+LIT->LIT_SERIE+"' .And. "
				cFiltro  += "LIT_DOC ='"+LIT->LIT_DOC+"'"

				IndRegua("TRB",cIndex,IndexKey(),,cFiltro,"Selecionando Registros") //"Selecionando Registros..."
				nIndex := RetIndex("LIT","TRB")
				dbSetIndex(cIndex+OrdBagExt())
				dbSetOrder(nIndex+1)
				DbGotop()
    			lContLIT := .F. 
				
				// PESQUISA PARA ENCONTRAR O PROXIMO NUMERO DE CONTRATO COM AS MESMAS
				// CARACTERISTICAS, POIS ESTE SERA O CONTRATO QUE FOI GERADO NA CESSAO
                                   
				// aContratos[1][1] --> Contrato original
				// aContratos[1][2] --> Contrato gerado a partir do original
                  nReg++
				While ("TRB")->(!EOF())
				   If !lContLIT
				   	IF ("TRB")->LIT_NCONTR == LIT->LIT_NCONTR
				   		lContLIT:= .T.  
				   		aadd(aContratos, {LIT->LIT_NCONTR, ""})
				   		("TRB")->(dbSkip())
				   	ELSE
				         ("TRB")->(dbSkip())
				   	ENDIF  
				   Else
			   		aContratos[nReg][2] := ("TRB")->LIT_NCONTR
				   	Exit
				   EndIf
				   
				EndDo 
				 
				//Caso tabela temporaria aberta, fecha-la para re-uso
				If ( Select( "TRB" ) <> 0 )
					dbSelectArea ( "TRB" )
					dbCloseArea ()
				Endif  
    		
    		#ENDIF
		EndIF
	
	EndIf                   
				
	dbSelectArea("LIT")
	dbSkip()
EndDo

dbSelectArea("LIT")
dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR

For nReg:=1 to Len(aContratos)          
	If DbSeek(xFilial("LIT")+aContratos[nReg][2]) // BUSCA O CONTRATO GERADO PARA GRAVAR NO CAMPO LIT_ORIGEM
	
		Reclock("LIT", .F.)
			LIT->LIT_ORIGEM := aContratos[nReg][1]
		MsUnLock("LIT")   		
		
   EndIF
Next nReg           

Return .T.
