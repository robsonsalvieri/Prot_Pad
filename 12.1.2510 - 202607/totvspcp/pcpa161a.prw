#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'PCPA161.CH'

/*/{Protheus.doc} PCPA161A()
Função responsável por processar a opção:
Geral - Reprocessar do PCPA161 - Monitor Requisições Pendentes 

@author michele.girardi
@since 09/02/2026
@return lRet - .T. ou .F.
/*/
Function PCPA161A()
    Local aCampos   := {}
    Local aFieldG   := {}
    Local cAlias1   := ""
    Local cQry1     := ""
    Local cRecnoZ0  := ""
    Local cRecnoZ1  := ""
    Local lRet      := .T.
    Local oExec1    := Nil
    Local oTemp     := Nil

    Private aRotina   := {{STR0009, "A161aProcR", 0 , 1},; //"Reprocessar"
                          {STR0008, "A161aIncRe", 0 , 1},; //"Inconsistências"
                          {STR0025, "A161aLegen", 0 , 1}}  //"Legenda"

    Private cAliasTemp := ""
    Private oMark      := Nil
    
    If !Pergunte("PCPA161A",.T.)
        Return .T.
    EndIf

    cAliasTemp  := GetNextAlias()
	oTemp 		:= FWTemporaryTable():New(cAliasTemp)

    //Campos da Tabela Temporaria
	aCampos :=  {;
				{"HZ1_OK"	    ,"C", TAMSX3("G1_OK")[1]		,0						    },;
                {"HZ1_STATUS"   ,"C", 1	                    	,0						    },;
				{"HZ1_FILIAL"   ,"C", TAMSX3("HZ1_FILIAL")[1]	,TAMSX3("HZ1_FILIAL")[2]	},;
                {"HZ1_IDENT"	,"C", TAMSX3("HZ1_IDENT")[1]	,TAMSX3("HZ1_IDENT")[2]	    },;
				{"HZ1_COMP"		,"C", TAMSX3("HZ1_COMP")[1]		,TAMSX3("HZ1_COMP")[2]	    },;
				{"HZ1_DESC"		,"C", TAMSX3("G1_DESC")[1]		,TAMSX3("G1_DESC")[2]	    },;
				{"HZ1_LOCAL"	,"C", TAMSX3("HZ1_LOCAL")[1]	,TAMSX3("HZ1_LOCAL")[2]	    },;
				{"HZ1_QTD"		,"N", TAMSX3("HZ1_QTD")[1]		,TAMSX3("HZ1_QTD")[2]	    },;
				{"HZ1_ANALIS"	,"C", TAMSX3("HZ1_ANALIS")[1]	,TAMSX3("HZ1_ANALIS")[2]	},;
				{"HZ1_OP"		,"C", TAMSX3("HZ1_OP")[1]		,TAMSX3("HZ1_OP")[2]	    },;
                {"HZ1_MSG"		,"C", 100                		,0                  	    },;
                {"HZ1_RECZ0"	,"N", 8                 		,0                  	    },;
				{"HZ1_RECZ1"	,"N", 8							,0						    }}
    
    //Campos que vão aparecer na GRID
    aFieldG :=  {;				
				{"Componente"        , "HZ1_COMP"		,"C", TAMSX3("HZ1_COMP")[1]	  ,TAMSX3("HZ1_COMP")[2]   },;
				{"Descrição"         , "HZ1_DESC"		,"C", TAMSX3("G1_DESC")[1]	  ,TAMSX3("G1_DESC")[2]	   },;
				{"Local"             , "HZ1_LOCAL"	    ,"C", TAMSX3("HZ1_LOCAL")[1]  ,TAMSX3("HZ1_LOCAL")[2]  },;
				{"Quantidade"        , "HZ1_QTD"		,"N", TAMSX3("HZ1_QTD")[1]	  ,TAMSX3("HZ1_QTD")[2]	   },;
				{"Em Análise"        , "HZ1_ANALIS"	    ,"C", TAMSX3("HZ1_ANALIS")[1] ,TAMSX3("HZ1_ANALIS")[2] },;
				{"Ordem Produção"    , "HZ1_OP"		    ,"C", TAMSX3("HZ1_OP")[1]	  ,TAMSX3("HZ1_OP")[2]	   },;
                {"ID Apont."         , "HZ1_IDENT"		,"C", TAMSX3("HZ1_IDENT")[1]  ,TAMSX3("HZ1_IDENT")[2]  },;
                {"Msg Processamento" , "HZ1_MSG"		,"C", 100                	  ,0                  	   }}     
    
    oTemp:SetFields(aCampos)
    oTemp:AddIndex("1", {"HZ1_FILIAL","HZ1_COMP","HZ1_OP"})
    oTemp:AddIndex("2", {"HZ1_FILIAL","HZ1_RECZ1"})
	oTemp:Create()

    //Varrer a tabela de controle para procurar todos apontamentos que possuem requisição em aberto
    cQry1 := " SELECT HZ1.R_E_C_N_O_  RECNOZ1,  HZ0.R_E_C_N_O_  RECNOZ0 "
	cQry1 += "   FROM " + RetSqlName('HZ0') + " HZ0, "
    cQry1 += "        " + RetSqlName('HZ1') + " HZ1 "
	cQry1 += "  WHERE HZ0.HZ0_FILIAL  = ? " 
    cQry1 += "    AND HZ1.HZ1_FILIAL  = ? " 
    cQry1 += "    AND HZ0.HZ0_SEQ     = HZ1.HZ1_SEQ " 
    cQry1 += "    AND HZ0.HZ0_IDENT   = HZ1.HZ1_IDENT " 
    cQry1 += "    AND HZ0.HZ0_OP      = HZ1.HZ1_OP " 
    cQry1 += "    AND HZ1.HZ1_COMP   >= ? "
    cQry1 += "    AND HZ1.HZ1_COMP   <= ? "
    cQry1 += "    AND HZ1.HZ1_OP     >= ? "
    cQry1 += "    AND HZ1.HZ1_OP     <= ? "
    cQry1 += "    AND HZ0.HZ0_DTAPON >= ? "
    cQry1 += "    AND HZ0.HZ0_DTAPON <= ? "
    cQry1 += "    AND HZ1.HZ1_IDENT  >= ? "
    cQry1 += "    AND HZ1.HZ1_IDENT  <= ? "    
    cQry1 += "    AND HZ1.HZ1_PROCES  = 'N' "
    cQry1 += "    AND HZ1.HZ1_ESTORN  = 'N' "
    cQry1 += "    AND HZ0.D_E_L_E_T_  = ' ' "
	cQry1 += "    AND HZ1.D_E_L_E_T_  = ' ' "    
    cQry1 += "  ORDER BY HZ1.R_E_C_N_O_ "

	oExec1 := FwExecStatement():New(cQry1)
	
    oExec1:setString(1, xFilial('HZ0'))
    oExec1:setString(2, xFilial('HZ1'))
    oExec1:setString(3, MV_PAR03)
    oExec1:setString(4, MV_PAR04)
    oExec1:setString(5, MV_PAR01)
    oExec1:setString(6, MV_PAR02)
    oExec1:setString(7, Dtos(MV_PAR05))
    oExec1:setString(8, Dtos(MV_PAR06))
    oExec1:setString(9, MV_PAR07)
    oExec1:setString(10, MV_PAR08)
    
	cAlias1 := oExec1:OpenAlias()

	While (cAlias1)->(!Eof())
        cRecnoZ0 := (cAlias1)->RECNOZ0
        cRecnoZ1 := (cAlias1)->RECNOZ1
        
        dbSelectArea("HZ1")
    	dbGoTo(cRecnoZ1)

        //Inclui na temporária
        RECLOCK(cAliasTemp, .T.)
			REPLACE (cAliasTemp)->HZ1_STATUS WITH 	'0'
            REPLACE (cAliasTemp)->HZ1_FILIAL WITH 	HZ1->HZ1_FILIAL
			REPLACE (cAliasTemp)->HZ1_COMP	 WITH 	HZ1->HZ1_COMP
			REPLACE (cAliasTemp)->HZ1_DESC	 WITH 	POSICIONE('SB1',1,XFILIAL('SB1')+HZ1->HZ1_COMP,'B1_DESC')
			REPLACE (cAliasTemp)->HZ1_LOCAL	 WITH 	HZ1->HZ1_LOCAL
			REPLACE (cAliasTemp)->HZ1_QTD	 WITH 	HZ1->HZ1_QTD
			REPLACE (cAliasTemp)->HZ1_ANALIS WITH 	HZ1->HZ1_ANALIS
			REPLACE (cAliasTemp)->HZ1_OP	 WITH 	HZ1->HZ1_OP
			REPLACE (cAliasTemp)->HZ1_RECZ1  WITH 	cRecnoZ1
            REPLACE (cAliasTemp)->HZ1_RECZ0  WITH 	cRecnoZ0      
            REPLACE (cAliasTemp)->HZ1_MSG    WITH 	" "     
            REPLACE (cAliasTemp)->HZ1_IDENT	 WITH 	HZ1->HZ1_IDENT                   
		(cAliasTemp)->(MSUNLOCK())
        
        (cAlias1)->(dbSkip())
    End
    (cAlias1)->(DbCloseArea())        
    oExec1:Destroy()
    FreeObj(oExec1)

    dbSelectArea(cAliastemp)
	dbSetOrder(1)
	dbGoTop()

	If (cAliastemp)->(Eof())
		Help(Nil,Nil,"Help",Nil,STR0026,1,0) //"Não foram encontrados registros para serem reprocessados."        
        Return .T.
    EndIf

    oMark := FWMarkBrowse():New()
	oMark:SetAlias(cAliastemp)
	oMark:SetTemporary(.T.)
	oMark:SetDescription(STR0027)
	oMark:SetFieldMark("HZ1_OK")
	oMark:SetFields(aFieldG)
	oMark:SetAllMark({|| a161aAllMa()})
    oMark:oBrowse:SetMainProc("PCPA161A")
    oMark:AddLegend({ || (cAliastemp)->HZ1_STATUS == "0" }, "BLUE" , OemToAnsi(STR0028))  //"Não reprocessada"
    oMark:AddLegend({ || (cAliastemp)->HZ1_STATUS == "1" }, "GREEN", OemToAnsi(STR0029))  //"Reprocessada com sucesso"
	oMark:AddLegend({ || (cAliastemp)->HZ1_STATUS == "2" }, "RED"  , OemToAnsi(STR0030))  //"Reprocessada com inconsistência"
	oMark:Activate()
Return lRet

/*/{Protheus.doc} A161ProcRe()
Realiza o reprocessamento da requisição pendente selecionada

@author Michele Girardi
@since 10/02/2026
@return lRet - .T. ou .F.
/*/
Function A161aProcR()
    Local aReproces  := {}
    Local cAlias3    := ""
    Local cMark      := ""
    Local cMsg       := ""
    Local cMsg1      := ""
    Local cQry3      := ""
    Local cRec       := ""
    Local lRet       := .T.
    Local nI         := 0
    Local nRecnoZ0   := 0
    Local nRecnoZ1   := 0

    Local oExec3     := Nil

    cMark := oMark:Mark()

    dbSelectArea(cAliastemp)
	(cAliastemp)->(dbgotop())
	
	While (cAliastemp)->(!Eof()) .And. (cAliastemp)->HZ1_FILIAL == xFilial("HZ1")
		// Verifica os registros marcados para reprocessamento
		If (cAliastemp)->HZ1_OK == cMark
			AADD(aReproces,{(cAliastemp)->HZ1_RECZ0, (cAliastemp)->HZ1_RECZ1}) 
		EndIf
		(cAliastemp)->(dbSkip())
	End

    If Len(aReproces) > 0
        dbSelectArea("HZ4")
        IF !(HZ4->(dbSeek(xFilial("HZ4"))))
            Help(Nil,Nil,"Help",Nil,STR0013,1,0) //"Parâmetros Iniciais não cadastrado no PCPA161."
            Return .T.
        EndIf
    EndIf

    For nI := 1 To Len(aReproces)
        nRecnoZ0 := aReproces[nI,1]
        nRecnoZ1 := aReproces[nI,2]
        
        dbSelectArea("HZ0")
    	dbGoTo(nRecnoZ0)

        dbSelectArea("HZ1")
    	dbGoTo(nRecnoZ1)

        If HZ0->HZ0_ANALIS = 'S'
            RecLock("HZ0",.F.)
                REPLACE HZ0->HZ0_ANALIS WITH "N"                    
            HZ0->(MSUNLOCK())
        EndIf

        If HZ1->HZ1_ANALIS = 'S'            
            RecLock("HZ1",.F.)
                REPLACE HZ1->HZ1_ANALIS WITH "N"        
                REPLACE HZ1->HZ1_QTDPRC WITH 0            
            HZ1->(MSUNLOCK())
        EndIf

        If nRecnoZ0 != 0 .And. nRecnoZ1 != 0
            cMsg := " "
            a160ProcRP(nRecnoZ0, nRecnoZ1, @cMsg, 0)

            cRec := cValtoChar(nRecnoZ1)
            dbSelectArea(cAliastemp)
            (cAliastemp)->(dbSetOrder(2))
            (cAliastemp)->(dbSeek(xFilial("HZ1")+cRec))
           
            //Verificar se a requisição foi processada
            cQry3 := " SELECT HZ1.HZ1_PROCES PROCESSADO,  HZ1.HZ1_ANALIS ANALISE"
            cQry3 +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
            cQry3 += "  WHERE HZ1.HZ1_FILIAL   = ? "
            cQry3 += "    AND HZ1.R_E_C_N_O_   = ? "          
            cQry3 += "    AND HZ1.D_E_L_E_T_   = ' ' "

            oExec3 := FwExecStatement():New(cQry3)
            oExec3:setString(1, xFilial("HZ1"))
            oExec3:SetNumeric(2, nRecnoZ1)        

            cAlias3 := oExec3:OpenAlias()

            If (cAlias3)->(!Eof())
                If (cAlias3)->PROCESSADO = 'S'
                    cMsg1 := STR0016 //"Requisição efetivada com sucesso."

                    RecLock(cAliastemp,.F.)
                        REPLACE (cAliasTemp)->HZ1_STATUS WITH 	'1'
                        REPLACE (cAliasTemp)->HZ1_ANALIS WITH 	(cAlias3)->ANALISE
                        REPLACE (cAliasTemp)->HZ1_MSG    WITH 	cMsg1   
                    (cAliastemp)->(MSUNLOCK())
                Else
                    cMsg1 := cMsg
                    RecLock(cAliastemp,.F.)
                        REPLACE (cAliasTemp)->HZ1_STATUS WITH 	'2'
                        REPLACE (cAliasTemp)->HZ1_ANALIS WITH 	(cAlias3)->ANALISE
                        REPLACE (cAliasTemp)->HZ1_MSG    WITH 	cMsg1   
                    (cAliastemp)->(MSUNLOCK())
                EndIf
            EndIf
            (cAlias3)->(DbCloseArea())        
            oExec3:Destroy()
            FreeObj(oExec3)
        EndIf
    Next nI

    dbSelectArea(cAliastemp)
	dbSetOrder(1)
	dbGoTop()

    oMark:Refresh()
Return lRet

/*/{Protheus.doc} A161aLegen()
Monta tela da legenda

@author Michele Girardi
@since 23/02/2026
@return nil
/*/
Function A161aLegen()

	Local aLeg  := {{ "BR_AZUL"    , STR0028 },;  //"Não reprocessada"
                    { "BR_VERDE"   , STR0029 },;  //"Reprocessada com sucesso"
					{ "BR_VERMELHO", STR0030 }}	  //"Reprocessada com inconsistência"

	Local cCadastro := OemToAnsi(STR0007) //"Requisições Pendentes"

	BrwLegenda(cCadastro,STR0025,aLeg) //"Legenda"
Return

/*/{Protheus.doc} A161aIncRe()
Carrega os logs de inconsistências da requisição 
pendente selecionada

@author Michele Girardi
@since 09/02/2026
@return lRet - .T. ou .F.
/*/
Function A161aIncRe()
    Local aLogs    := {}
    Local cAlias   := ""
    Local cQry     := ""
    Local lRet     := .T.
    Local nRecnoZ1 := 0

    Local oExec    := Nil

    nRecnoZ1 := (cAliastemp)->HZ1_RECZ1
    dbSelectArea("HZ1")
    dbGoTo(nRecnoZ1)

    cQry := " SELECT HZ3.HZ3_MSG MSGLOG, HZ3.HZ3_DTLOG DATALOG, HZ3.HZ3_HRLOG HORALOG"
	cQry +=   " FROM " + RetSqlName('HZ3') + " HZ3 "
	cQry += "  WHERE HZ3.HZ3_FILIAL   = ? "
    cQry += "    AND HZ3.HZ3_SEQ      = ? " 
    cQry += "    AND HZ3.HZ3_IDENT    = ? " 
    cQry += "    AND HZ3.HZ3_OP       = ? "  
    cQry += "    AND HZ3.HZ3_COMP     = ? "  
    cQry += "    AND HZ3.HZ3_LOCAL    = ? "  
    cQry += "    AND HZ3.HZ3_TRT      = ? "  
    cQry += "    AND HZ3.HZ3_LOTE     = ? "  
    cQry += "    AND HZ3.HZ3_SUBLOT   = ? "  
    cQry += "    AND HZ3.HZ3_ENDERE   = ? "  
    cQry += "    AND HZ3.HZ3_SERIE    = ? "  
    cQry += "    AND HZ3.HZ3_OPORIG   = ? "  
	cQry += "    AND HZ3.D_E_L_E_T_   = ' ' "
    cQry += "  ORDER BY HZ3.HZ3_DTLOG DESC, HZ3.HZ3_HRLOG DESC"    

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1,  xFilial("HZ3"))
    oExec:setString(2,  HZ1->HZ1_SEQ)
    oExec:setString(3,  HZ1->HZ1_IDENT)
    oExec:setString(4,  HZ1->HZ1_OP)
    oExec:setString(5,  HZ1->HZ1_COMP)
    oExec:setString(6,  HZ1->HZ1_LOCAL)
    oExec:setString(7,  HZ1->HZ1_TRT)
    oExec:setString(8,  HZ1->HZ1_LOTE)
    oExec:setString(9,  HZ1->HZ1_SUBLOT)
    oExec:setString(10, HZ1->HZ1_ENDERE)
    oExec:setString(11, HZ1->HZ1_SERIE)
    oExec:setString(12, HZ1->HZ1_OPORIG)

	cAlias := oExec:OpenAlias()

    While (cAlias)->(!Eof())

        aAdd(aLogs,{(cAlias)->MSGLOG, STOD((cAlias)->DATALOG), (cAlias)->HORALOG, HZ1->HZ1_COMP})
        (cAlias)->(dbSkip())
    End

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

    If Len(aLogs) > 0
        a161aGrdLg(aLogs)
    Else
        Help(Nil,Nil,"Help",Nil,STR0020,1,0) //"Não existe mensagem de inconsistência para esta requisição pendente."
    EndIf
Return lRet

/*/{Protheus.doc} a161aGrdLg()
Abre tela para apresentar os logs de inconsistências da requisição 
pendente selecionada

@author Michele Girardi
@since 09/02/2026
@param 01: aLogs - Array com as mensagens de inconsistências da requisição pendente
@return Nil
/*/
 Static Function a161aGrdLg(aLogs)
    Local cTitulo  := STR0021 + aLogs[1,4] //"Inconsistências do Processamento da Requisição Pendente - "
    Local oDlgUpd
    Local oList

    DEFINE DIALOG oDlgUpd TITLE cTitulo FROM 0, 0 TO 350,780  PIXEL 

	oList := TWBrowse():New( 01, 01, 390,170,,{STR0022,STR0023,STR0024},,oDlgUpd,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"Data" //"Hora" //"Inconsistência"

	oList:SetArray(aLogs)
	oList:bLine := {|| {aLogs[oList:nAT,2],aLogs[oList:nAT,3],aLogs[oList:nAt,1]}}

	ACTIVATE DIALOG oDlgUpd CENTER

 Return Nil

/*/{Protheus.doc} a161aAllMa()
Marca/Desmarca todas requisições pendentes para reprocessamento

@author Michele Girardi
@since 23/02/2026
@return lRet - .T. ou .F.
/*/
Static Function a161aAllMa()
    Local aArea := GetArea()
    Local lRet := .T.
    
	dbSelectArea(cAliastemp)
	dbGoTop()

	While (cAliastemp)->(!Eof())
		If ((cAliastemp)->HZ1_OK <> omark:Mark())
			RecLock(cAliastemp, .F.)
				(cAliastemp)->HZ1_OK := omark:Mark()
			MSUnlock()
		ElseIf ((cAliastemp)->HZ1_OK == omark:Mark())
			RecLock(cAliastemp , .F.)
				(cAliastemp)->HZ1_OK := "  "
			MSUnlock()
		EndIf
		(cAliastemp)->(dbSkip())
	EndDo

	RestArea(aArea)

	oMark:Refresh()
	oMark:GoTop()
Return lRet
