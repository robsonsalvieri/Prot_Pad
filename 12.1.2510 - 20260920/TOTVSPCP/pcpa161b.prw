#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'PCPA161.CH'

/*/{Protheus.doc} PCPA161B()
Função responsável por processar a opção:
Geral - Em Análise do PCPA161 - Monitor Requisições Pendentes 

@author michele.girardi
@since 09/02/2026
@return lRet - .T. ou .F.
/*/
Function PCPA161B()
    Local nTipo     := 1
    Local lRet      := .T.
        
    If Pergunte("PCPA161B",.T.)
        nTipo := MV_PAR01

        If nTipo == 1
            //Requisição
            a161bProcR()
        Else
            //Apontamento
            a161bProcA()
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} a161bProcR()
Realiza a alteração Em Análise em massa para as Requisições 

@author Michele Girardi
@since 23/02/2026
@return lRet - .T. ou .F.
/*/
Static Function a161bProcR()
    Local aCampos   := {}
    Local aFieldG   := {}
    Local cAlias1   := ""
    Local cDesc     := ""
    Local cQry1     := ""
    Local cRecnoZ0  := ""
    Local cRecnoZ1  := ""
    Local lRet      := .T.
    Local nAcao     := mv_par02 //1-Ativar | 2-Desativar
    Local oExec1    := Nil
    Local oTemp     := Nil

    Private aRotina   := {{STR0031, "A161bAtu"  , 0 , 1},; //"Processar"
                          {STR0025, "A161bLegen", 0 , 1}}  //"Legenda"

    Private cAliasTemp := ""
    Private oMark      := Nil

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
                {"ID Apont."         , "HZ1_IDENT"		,"C", TAMSX3("HZ1_IDENT")[1]  ,TAMSX3("HZ1_IDENT")[2]  }}
    
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

    If nAcao == 1 //Ativar - Buscar os registros que estão HZ1_ANALIS = N - O campo Em Análise será atualizado para S - Sim. 
        cQry1 += "    AND HZ1.HZ1_ANALIS  = 'N' "
    Else
        If nAcao == 2 //Desativar - Buscar os registros que estão HZ1_ANALIS = S - O campo Em Análise será atualizado para N - Não. 
            cQry1 += "    AND HZ1.HZ1_ANALIS  = 'S' "
        EndIf
    EndIf

    cQry1 += "    AND HZ0.D_E_L_E_T_  = ' ' "
	cQry1 += "    AND HZ1.D_E_L_E_T_  = ' ' "    
    cQry1 += "  ORDER BY HZ1.R_E_C_N_O_ "

	oExec1 := FwExecStatement():New(cQry1)
	
    oExec1:setString(1, xFilial('HZ0'))
    oExec1:setString(2, xFilial('HZ1'))
    oExec1:setString(3, MV_PAR05)
    oExec1:setString(4, MV_PAR06)
    oExec1:setString(5, MV_PAR03)
    oExec1:setString(6, MV_PAR04)
    oExec1:setString(7, Dtos(MV_PAR07))
    oExec1:setString(8, Dtos(MV_PAR08))
    oExec1:setString(9, MV_PAR09)
    oExec1:setString(10, MV_PAR10)
    
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
		Help(Nil,Nil,"Help",Nil,STR0032,1,0) //"Não foram encontrados registros para serem processados."
        Return .T.
    EndIf

    If nAcao == 1
        cDesc := STR0064 //"Ativar - Alterar o Indicador Em Análise para Sim"
    Else
        If nAcao == 2
            cDesc := STR0065 //"Desativar - Alterar o Indicador Em Análise para Não"
        EndIf
    EndIf    

    oMark := FWMarkBrowse():New()
	oMark:SetAlias(cAliastemp)
	oMark:SetTemporary(.T.)
	oMark:SetDescription(cDesc)
	oMark:SetFieldMark("HZ1_OK")
	oMark:SetFields(aFieldG)
	oMark:SetAllMark({|| a161bAllMa()})
    oMark:oBrowse:SetMainProc("PCPA161B")
    oMark:AddLegend({ || (cAliastemp)->HZ1_ANALIS == "N" }, "GREEN", OemToAnsi(STR0035))  // "Requisição Ativa"
	oMark:AddLegend({ || (cAliastemp)->HZ1_ANALIS == "S" }, "RED"  , OemToAnsi(STR0036))  // "Requisição Em Análise"
	oMark:Activate()
Return lRet

/*/{Protheus.doc} a161bProcA()
Realiza a alteração Em Análise em massa para os Apontamentos

@author Michele Girardi
@since 23/02/2026
@return lRet - .T. ou .F.
/*/
Static Function a161bProcA()
    Local aCampos   := {}
    Local aFieldG   := {}
    Local cAlias1   := ""
    Local cDesc     := ""
    Local cQry1     := ""
    Local cRecnoZ0  := ""
    Local lRet      := .T.
    Local nAcao     := mv_par02 //1-Ativar | 2-Desativar
    Local oExec1    := Nil
    Local oTemp     := Nil

    Private aRotina   := {{STR0031, "A161bAtu"  , 0 , 1},; //"Processar"
                          {STR0025, "A161bLegen", 0 , 1}}  //"Legenda"

    Private cAliasTemp := ""
    Private oMark      := Nil

    cAliasTemp  := GetNextAlias()
	oTemp 		:= FWTemporaryTable():New(cAliasTemp)

    //Campos da Tabela Temporaria
	aCampos :=  {;
				{"HZ1_OK"	    ,"C", TAMSX3("G1_OK")[1]		,0						    },;
				{"HZ1_FILIAL"   ,"C", TAMSX3("HZ1_FILIAL")[1]	,TAMSX3("HZ1_FILIAL")[2]	},;
                {"HZ1_IDENT"	,"C", TAMSX3("HZ1_IDENT")[1]	,TAMSX3("HZ1_IDENT")[2]	    },;
				{"HZ1_ANALIS"	,"C", TAMSX3("HZ1_ANALIS")[1]	,TAMSX3("HZ1_ANALIS")[2]	},;
				{"HZ1_OP"		,"C", TAMSX3("HZ1_OP")[1]		,TAMSX3("HZ1_OP")[2]	    },;
                {"HZ1_RECZ0"	,"N", 8                 		,0                  	    }}
    
    //Campos que vão aparecer na GRID
    aFieldG :=  {;				
				{"Ordem Produção"    , "HZ1_OP"		    ,"C", TAMSX3("HZ1_OP")[1]	  ,TAMSX3("HZ1_OP")[2]	   },;
                {"Em Análise"        , "HZ1_ANALIS"	    ,"C", TAMSX3("HZ1_ANALIS")[1] ,TAMSX3("HZ1_ANALIS")[2] },;
                {"ID Apont."         , "HZ1_IDENT"		,"C", TAMSX3("HZ1_IDENT")[1]  ,TAMSX3("HZ1_IDENT")[2]  }}
    
    oTemp:SetFields(aCampos)
    oTemp:AddIndex("1", {"HZ1_FILIAL","HZ1_OP"})
    oTemp:AddIndex("2", {"HZ1_FILIAL","HZ1_RECZ0"})
	oTemp:Create()

    //Varrer a tabela de controle para procurar todos apontamentos que possuem requisição em aberto
    cQry1 := " SELECT HZ0.R_E_C_N_O_  RECNOZ0 "
	cQry1 += "   FROM " + RetSqlName('HZ0') + " HZ0 "
	cQry1 += "  WHERE HZ0.HZ0_FILIAL  = ? " 
    cQry1 += "    AND HZ0.HZ0_OP     >= ? "
    cQry1 += "    AND HZ0.HZ0_OP     <= ? "
    cQry1 += "    AND HZ0.HZ0_DTAPON >= ? "
    cQry1 += "    AND HZ0.HZ0_DTAPON <= ? "
    cQry1 += "    AND HZ0.HZ0_IDENT  >= ? "
    cQry1 += "    AND HZ0.HZ0_IDENT  <= ? "    

    If nAcao == 1 //Ativar - Buscar os registros que estão HZ1_ANALIS = N - O campo Em Análise será atualizado para S - Sim. 
        cQry1 += "    AND HZ0.HZ0_ANALIS  = 'N' "
    Else
        If nAcao == 2 //Desativar - Buscar os registros que estão HZ1_ANALIS = S - O campo Em Análise será atualizado para N - Não. 
            cQry1 += "    AND HZ0.HZ0_ANALIS  = 'S' "
        EndIf
    EndIf

    cQry1 += "    AND HZ0.D_E_L_E_T_  = ' ' " 
    cQry1 += "    AND HZ0.HZ0_REQTOT  <> 'E' " //RECTOT = E - Indica que não existe requisição - Foi gerado somente o encerramento -- nunca passar para em analise esses registros
    cQry1 += "  ORDER BY HZ0.R_E_C_N_O_ "

	oExec1 := FwExecStatement():New(cQry1)
	
    oExec1:setString(1, xFilial('HZ0'))
    oExec1:setString(2, MV_PAR03)
    oExec1:setString(3, MV_PAR04)
    oExec1:setString(4, Dtos(MV_PAR07))
    oExec1:setString(5, Dtos(MV_PAR08))
    oExec1:setString(6, MV_PAR09)
    oExec1:setString(7, MV_PAR10)
    
	cAlias1 := oExec1:OpenAlias()

	While (cAlias1)->(!Eof())
        cRecnoZ0 := (cAlias1)->RECNOZ0
        
        dbSelectArea("HZ0")
    	dbGoTo(cRecnoZ0)

        //Inclui na temporária
        RECLOCK(cAliasTemp, .T.)
            REPLACE (cAliasTemp)->HZ1_FILIAL WITH 	HZ0->HZ0_FILIAL
			REPLACE (cAliasTemp)->HZ1_ANALIS WITH 	HZ0->HZ0_ANALIS
			REPLACE (cAliasTemp)->HZ1_OP	 WITH 	HZ0->HZ0_OP
            REPLACE (cAliasTemp)->HZ1_RECZ0  WITH 	cRecnoZ0      
            REPLACE (cAliasTemp)->HZ1_IDENT	 WITH 	HZ0->HZ0_IDENT                   
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
		Help(Nil,Nil,"Help",Nil,STR0032,1,0) //"Não foram encontrados registros para serem processados."
        Return .T.
    EndIf

    If nAcao == 1
        cDesc := STR0064 //"Ativar - Alterar o Indicador Em Análise para Sim"
    Else
        If nAcao == 2
            cDesc := STR0065 //"Desativar - Alterar o Indicador Em Análise para Não"
        EndIf
    EndIf    

    oMark := FWMarkBrowse():New()
	oMark:SetAlias(cAliastemp)
	oMark:SetTemporary(.T.)
	oMark:SetDescription(cDesc)
	oMark:SetFieldMark("HZ1_OK")
	oMark:SetFields(aFieldG)
	oMark:SetAllMark({|| a161bAllMa()})
    oMark:oBrowse:SetMainProc("PCPA161B")
    oMark:AddLegend({ || (cAliastemp)->HZ1_ANALIS == "N" }, "GREEN", OemToAnsi(STR0040))  // "Apontamento Ativo"
	oMark:AddLegend({ || (cAliastemp)->HZ1_ANALIS == "S" }, "RED"  , OemToAnsi(STR0041))  // "Apontamento Em Análise"
	oMark:Activate()
Return lRet

/*/{Protheus.doc} A161bAtu()
Atualiza o indicador Em Análise para as Requisições e Apontamentos

@author Michele Girardi
@since 23/02/2026
@return lRet - .T. ou .F.
/*/
Function A161bAtu()
    Local aAnalise   := {}
    Local cInd       := ""
    Local cMark      := ""
    Local cRec       := ""
    Local lRet       := .T.
    Local nI         := 0
    Local nAcao      := MV_PAR02
    Local nTipo      := MV_PAR01
    Local nRecnoZ0   := 0
    Local nRecnoZ1   := 0

    If nAcao == 1 //Ativar
        cInd := "S"
    Else
        If nAcao == 2 //Desativar
            cInd := "N"
        EndIf
    EndIf    
    
    cMark := oMark:Mark()

    dbSelectArea(cAliastemp)
	(cAliastemp)->(dbgotop())
	
	While (cAliastemp)->(!Eof()) .And. (cAliastemp)->HZ1_FILIAL == xFilial("HZ1")
		// Verifica os registros marcados para alteração do indicador Em Análise
		If (cAliastemp)->HZ1_OK == cMark
            If nTipo == 1 //Requisição
			    AADD(aAnalise,{(cAliastemp)->HZ1_RECZ0, (cAliastemp)->HZ1_RECZ1}) 
            Else
                //Apontamento
                AADD(aAnalise,{(cAliastemp)->HZ1_RECZ0, (cAliastemp)->HZ1_RECZ0}) 
            EndIf
		EndIf
		(cAliastemp)->(dbSkip())
	End

    For nI := 1 To Len(aAnalise)
        If nTipo == 1 //Requisição
            nRecnoZ1 := aAnalise[nI,2]
            dbSelectArea("HZ1")
    	    dbGoTo(nRecnoZ1)        
            RecLock("HZ1",.F.)
                REPLACE HZ1->HZ1_ANALIS WITH cInd      
                REPLACE HZ1->HZ1_QTDPRC WITH 0            
            HZ1->(MSUNLOCK())
        Else
            //Apontamento
            nRecnoZ0 := aAnalise[nI,1]
            dbSelectArea("HZ0")
    	    dbGoTo(nRecnoZ0)
            RecLock("HZ0",.F.)
                REPLACE HZ0->HZ0_ANALIS WITH cInd                    
            HZ0->(MSUNLOCK())
        EndIf

        If nTipo == 1 //Requisição
            cRec := cValtoChar(nRecnoZ1)
        Else
            //Apontamento
            cRec := cValtoChar(nRecnoZ0)
        EndIf

        dbSelectArea(cAliastemp)
        (cAliastemp)->(dbSetOrder(2))
        (cAliastemp)->(dbSeek(xFilial("HZ1")+cRec))

        RecLock(cAliastemp,.F.)
            (cAliasTemp)->(dbDelete())
        (cAliastemp)->(MSUNLOCK())
    Next nI

    oMark:Refresh()

Return lRet

/*/{Protheus.doc} a161bAllMa()
Marca/Desmarca todas requisições/apontamentos pendentes para reprocessamento

@author Michele Girardi
@since 23/02/2026
@return lRet - .T. ou .F.
/*/
Static Function a161bAllMa()
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

/*/{Protheus.doc} A161bLegen()
Monta tela da legenda

@author Michele Girardi
@since 23/02/2026
@return nil
/*/
Function A161bLegen()

	Local aLeg  := {{ "BR_VERDE"   , STR0035 },;  //"Requisição Ativa"
					{ "BR_VERMELHO", STR0036 }}	  //"Requisição Em Análise"

	Local cCadastro := OemToAnsi(STR0007) //"Requisições Pendentes"

	BrwLegenda(cCadastro,STR0025,aLeg) //"Legenda"
Return

