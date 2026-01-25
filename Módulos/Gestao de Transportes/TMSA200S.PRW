#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSA200S    ³ Autor ³ Felipe Barbiere    ³ Data ³19/07/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Schedule de Cálculo do Frete								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA200S()
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local cCalTpLt  := GetMV("MV_CALTPLT",,"2")	//-- Indica o Tipo de lote no cálculo automático 1=Normal, 2=Eletrônico, 3=Todos
Local nDias 	:= 7
Local lTM200SQRY:= ExistBlock("TM200SQRY")

If Empty(cCalTpLt)
	cCalTplt := "2"	//-- Eletrônico
EndIf
SetMVValue("TMB200","mv_par10", 2)    //-- Exibe Preview do Frete ? 

cQuery := "SELECT R_E_C_N_O_  DTPRECNO "
cQuery += "FROM " + RetSqlName("DTP")
cQuery += " WHERE DTP_FILIAL = '" + xFilial("DTP") + "'"
cQuery += " AND DTP_DATLOT >= '" + DToS(DaySub(dDataBase, nDias))  + "'"
cQuery += " AND DTP_STATUS = '2' "
If cCalTpLt == "1"	//-- Normal
	cQuery += " AND DTP_TIPLOT = '1' "
ElseIf cCalTpLt == "2"	//-- Eletrônico
	cQuery += " AND DTP_TIPLOT IN ('3','4') "
EndIf
cQuery += " AND DTP_FILORI = '" + cFilAnt + "' "
cQuery += " AND D_E_L_E_T_ = '' "

If lTM200SQRY
	cQuery	:= ExecBlock("TM200SQRY",.F.,.F., {cQuery})
EndIf

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

While (cAliasQry)->(!Eof())
	DTP->(dbGoTo((cAliasQry)->DTPRECNO))	
	If DTP->DTP_STATUS == '2' .And. LockByName("SIGATMS_DTP_" + AllTrim(Str((cAliasQry)->DTPRECNO)), .T.,.F.)   
		lRet := TMSA200MNT("DTP", DTP->(RecNo()), 2, , .F.)
		UnLockByName("SIGATMS_DTP_" + AllTrim(Str((cAliasQry)->DTPRECNO)), .T.,.F.)  
	EndIf	
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Scheddef    ³ Autor ³ Felipe Barbiere    ³ Data ³19/07/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função Schedule  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SchedDef()
Local aParam

aParam := {"P",;  	//Tipo R para relatorio P para processo   
		   "TMB200",;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DTP",;  // Alias            
		   ,;   	//Array de ordens   
		   'Schedule - Cálculo do Frete'} //--> Schedule - Repom   

Return aParam 

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA200SJob
Permite a execucao da rotina via Job
@author Rafael Souza
@since 02/10/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Function TMA200SJob(aParam)

Local lCont		:= .F.
Local cPrepare	:= ""

Default aParam 	:= {} 

cPrepare := GetJobProfString("PREPAREIN" , "(UNDEFINED)" )

If cPrepare != '' .And. Len(aParam) == 0
	aParam := StrTokArr(cPrepare, ",") 
EndIf

RpcSetType(3)
If	lCont := RpcSetEnv(aParam[1],aParam[2],,,"TMS","TMSA200S")
	TMSA200S()
EndIf
RpcClearEnv()

Return
