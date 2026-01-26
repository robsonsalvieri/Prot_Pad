#INCLUDE "TOTVS.CH"
#INCLUDE "TCFA140.CH"

STATIC oStRS3  := NIL
STATIC oStRWY  := NIL

/*/{Protheus.doc} TCFA140
Gera o arquivo AFD de acordo com a portaria 671/2021
@type  Function
@author Henrique Ferreira
@since 23/08/2022
/*/
Function TCFA140()

Local cSrvVers      := GetSrvVersion()
Local cSrvDefaul    := "20.3.1.1"
Local cTexto        := "999"
Local cCRC16        := ""
Local cExecCRC      := "CRCCalc( 8, cTexto, @cCRC16 )"
Local lCrcFind      := FindFunction("CRCCalc")
Local lCheckSWY     := ChkFile("SWY")	
Local aArea			:= GetArea()
Local cDescricao 	:= STR0001 // "Essa rotina realiza a Geração do Arquivo de Fontes de Dados - AFD, seguindo o leiaute e definições da portaria 671/2021"

Private aLogTitle	:= {}
Private aLogAFD 	:= {{}}
Private nTipo01		:= 0
Private nTipo03		:= 0
Private oTmpAFD
	
If !fExistPerg("TCFA140") .Or. !lCheckSWY
    //"Funcionalidade não disponí­vel para esta versío do sistema."
    Help(,, "Help",, STR0002, 1, 0,,,,,, {STR0003}) // "Para utilizar a rotina de geração do arquivo AFD é necessário atualizar o sistema."
    Return
EndIf

// Valida necessidade de atualização do AppServer.
If !lCrcFind .Or. &cExecCRC == nil 
    //"Funcionalidade não disponível para este binário"
    Help(,, "Help",, STR0009, 1, 0,,,,,, {STR0010}) // "É necessário atualizar o Application Server para a versão 20.3.1.1 ou superior."
    Return
EndIF

Pergunte("TCFA140", .F.)

tNewProcess():New( "TCFA140", STR0004, {|oSelf| TCFA140Proc(oSelf) }, cDescricao, "TCFA140",,,,,,.T.) // "Geração do arquivo AFD"

MsAguarde({|| fMakeLog( aLogAFD, aLogTitle, "TCFA140", , "TCFA140", STR0005 )}, STR0005) // "Ocorrências na Geração do arquivo AFD"

RestArea(aArea)

If oTmpAFD <> Nil
    oTmpAFD:Delete()
    Freeobj(oTmpAFD)
EndIf
	
Return

/*/{Protheus.doc} TCFA140Proc
Busca as informações e gera o arquivo de texto
@type  Static Function
@author Cí­cero Alves
@since 23/08/2022
@param oProcess, Objeto, instí¢ncia da classe tNewProcess
/*/
Static Function TCFA140Proc(oProcess)
	
Local cAcessaSRA	:= fSFiltrSQL(ChkRH("TCFA140", "SRA", "2"))
Local cQrySRA 		:= GetNextAlias()
Local cWhere		:= ""
Local nRegua		:= 0
Local cFilSRARCE    := "%" + FWJoinFilial("SRA", "RCE") + "%"
Local cCodCCT       := AllTrim( MV_PAR01 )

Private lTimeZone   := RS3->(ColumnPos("RS3_TMZ")) > 0
Private dDataIni	:= IIf( !Empty( MV_PAR03 ), MV_PAR03, DaySub( dDataBase , 30 ) )
Private dDataFim	:= IIf( !Empty( MV_PAR04 ), MV_PAR04, dDataBase )
Private cFilCentra  := MV_PAR06
Private aInfo       := {}
	
dbSelectArea("SRA")

MakeSqlExp("TCFA140")

cWhere := "SRA.RA_ADMISSA <= '" + dToS(dDataFim) + "' " 
cWhere += "AND ( SRA.RA_DEMISSA = '        ' OR SRA.RA_DEMISSA > '" + dToS(dDataIni) + "' ) "
cWhere += "AND RCE.RCE_CCT =  '" + cCodCCT + "'"
cWhere += "AND SRA.RA_CIC <> ' '"
cWhere += If(!Empty(MV_PAR02), " AND " + MV_PAR02, "") // Matrículas

// Controle de Acesso
cWhere += If(!Empty(cAcessaSRA) .And. cAcessaSRA != ".T.", " AND " + cAcessaSRA, "")
cWhere := "%" + cWhere + "%"

// Busca as informações do cadastro de empresas
If fInfo(@aInfo, cFilCentra)

    nTipo01++

    // Grava as informações do cabeçalho na tabela temporária
    Tipo01(aInfo)

    // Query para a rí©gua de processamento
    BeginSQL ALIAS cQrySRA
        SELECT COUNT(SRA.RA_MAT) AS FUNCIONARIOS
        FROM %Table:SRA% SRA
        INNER JOIN %Table:RCE% RCE
        ON RCE.RCE_CODIGO = SRA.RA_SINDICA
        AND RCE.%NotDel%
        AND %exp:cFilSRARCE%
        WHERE %Exp:cWhere%
        AND SRA.%NotDel%
    EndSQL
    
    nRegua := (cQrySRA)->FUNCIONARIOS
    (cQrySRA)->(dbCloseArea())
    oProcess:SetRegua1(nRegua)

    BeginSQL ALIAS cQrySRA
        SELECT  SRA.RA_FILIAL, 
                SRA.RA_MAT, 
                SRA.RA_NOME, 
                SRA.RA_NOMECMP, 
                SRA.RA_CIC, 
                SRA.RA_SINDICA, 
                SRA.R_E_C_N_O_ AS RECNO
        FROM %Table:SRA% SRA
        INNER JOIN %Table:RCE% RCE
        ON RCE.RCE_CODIGO = SRA.RA_SINDICA
        AND RCE.%NotDel%
        AND %exp:cFilSRARCE%
        WHERE %Exp:cWhere%
        AND SRA.%NotDel%
        ORDER BY SRA.RA_CIC
    EndSQL

    While (cQrySRA)->(!EoF())

        //Movimenta régua de processamento
		oProcess:IncRegua1("Processando funcionário " + (cQrySRA)->RA_FILIAL + " - " + (cQrySRA)->RA_MAT )
        
        //Posiciona no Funcionário
        SRA->(dbGoTo((cQrySRA)->RECNO))
        
        // Gera as informações sobre marcações. Tipo 03
        If !GeraMarc()
            If(Empty(aLogTitle))
                Aadd(aLogTitle, STR0006) //"Funcionários não enviados"
            EndIf
            Aadd(aLogAFD[1], (cQrySRA)->RA_FILIAL + " - " + (cQrySRA)->RA_MAT + ": " + STR0007) // "Funcionário sem marcações."
            (cQrySRA)->(dbSkip())
            LOOP
        EndIf
        (cQrySRA)->(dbSkip())
    EndDo

    (cQrySRA)->(dbCloseArea())

    // Grava o Trailer do arquivo
    Tipo99()
    
    // Grera o arquivo de texto
    GeraArq()
EndIf
	
Return 

/*/{Protheus.doc} GeraMarc
Gera as informações sobre horários
@type  Static Function
@author Henrique Ferreira
@since 26/08/2022
@return lRet, Lógico, Verdadeiro quando o funcionário possui marcações no período selecionado
/*/
Static Function GeraMarc()
	
Local aMarcacoes	:= {}
Local lRet			:= .F.
	
aMarcacoes := GetRS3()

If ( lRet := Len( aMarcacoes ) > 0 )
    // Marcações
    Tipo03(aMarcacoes)
EndIf    
	
Return lRet

/*/{Protheus.doc} Tipo01
Grava as informações do cabeçalho na tabela temporária
@type  Static Function
@author Cí­cero Alves
@since 24/08/2022
@param aInfo, Array, Informações do cadastro de empesas
/*/
Static Function Tipo01(aInfo)
	
    Local cExecCRC  := ""
    Local cNumConv  := If( Len( aPergunta ) >= 7, AllTrim( aPergunta[7,8] ), Replicate("9",17) )
    Local cFixo     := Replicate("0",9) // Fixo
	Local cTipoReg	:= "1" 
	Local cVersao	:= "003"
	Local cRazaoS	:= ""
	Local cTipoInsc	:= ""
	Local cCPFCNPJ	:= ""
	Local cTexto	:= ""
    Local aDados    := fGetInscr( aInfo )
    Local cTpInsFab := aDados[1,1]
    Local cInscrFab := aDados[1,2]
    Local cModRep   := Space(30)
    Local cCRC16    := ""
	Local cDataIni	:= Transforma(dDataIni)
	Local cDataFim	:= Transforma(dDataFim)
	Local cDataGera	:= FWTimeStamp(5)
	Local cChave	:= CValToChar( StrZero( nTipo01, 6 ) )
	
	// Remove os ultimos : para ficar de acordo com o leiaute do governo
	cDataGera := Left(cDataGera, 22) + Right(cDataGera, 2)
	
	//tratamento para CEI?
	
	// Tipo de inscrião da empresa "1" = CNPJ, "2" = CPF, "3" = CEI
	cTipoInsc := If(aInfo[15] == 1, "3", If(aInfo[15] == 3, "2", "1"))
	
	cCPFCNPJ := AllTrim(aInfo[8])
	
	//TODO buscar CAEPF
	cCAEPF := Space(7)
	
	//TODO buscar CNO
	cCNO := Space(7)
	
	cRazaoS := Padr(FSubst(AllTrim(aInfo[3])),150)
	
	//Monta a linha do Registro do tipo 01 - Cabeçalho
    cTexto := cFixo         // 001-009 Fixo
	cTexto += cTipoReg 		// 010-010 Tipo de registro
	cTexto += cTipoInsc  	// 011-011 Tipo de identificador do empregador
	cTexto += cCPFCNPJ 	 	// 012-025 CNPJ ou CPF do empregador
	cTexto += cCAEPF 	 	// 026-039 CAEPF
	cTexto += cCNO 		 	// 026-039 CNO
	cTexto += cRazaoS 	 	// 040-189 Razío Social ou nome do empregador
    cTexto += cNumConv      // 190-206 Número do processo do último acordo ou convenção coletiva depositado, no caso de REP-A (caso nío haja, informar "99999999999999999");
	cTexto += cDataIni 	 	// 207-216 Data Inicial
	cTexto += cDataFim 	 	// 217-226 Data Final
	cTexto += cDataGera		// 227-250 Data e Hora da Geração
    cTexto += cVersao       // 251-253 Versío
    cTexto += cTpInsFab     // 254-254 Tipo de inscrião do fabricando do REP.
    cTexto += cInscrFab     // 255-268 Inscrião do fabricante.
    cTexto += cModRep       // 269-298 Modelo, no caso de REP-C.

    //Monta CRC16 -- Função da TEC
    cExecCRC := "CRCCalc( 8, cTexto, @cCRC16 )"
    &cExecCRC

	cTexto += cCRC16	// 299-302 Versío do Leiaute
	
	GravaAFD("01", cChave, cTexto)
	
Return

/*/{Protheus.doc} Tipo03
Grava as marcações realizadas pelo funcionário no perí­odo na tabela temporária
@type  Static Function
@author Henrique Ferreira
@since 26/08/2022
@param aMarcacoes, Array, Marcações do funcionário, incluindo as marcações desconsideradas
@return lRet, Lógico, Indica se o funcionário tem alguma marcaão no perí­odo selecionado
/*/
Static Function Tipo03(aMarcacoes)

Local cExecCRC      := ""
Local cTipoReg		:= "3"
Local cChave		:= "3"
Local cNSR	        := "0" // Contador
Local cDHMarc		:= ""
Local cDtMarc       := ""
Local cHoraMarc		:= ""
Local cTmzMarc      := ""
Local cTexto		:= ""
Local cFixo         := Space(1)
Local cCRC16        := ""
Local nI 			:= 0
	
For nI := 1 To Len(aMarcacoes)
    
    nTipo03++
    
    cHoraMarc := StrTran( StrZero( aMarcacoes[nI,4], 5, 2 ), ".", ":" ) + ":00" // Adiciona os segundos como 00
    cDtMarc   := Transforma( StoD( aMarcacoes[nI,3] ) )
    cTmzMarc := iif( lTimeZone, ;
                     cTmzMarc := cValToChar( Min2Hrs( aMarcacoes[nI,5] ) ), ;
                     cTmzMarc := "0" )
    // Se o timezone da marcaão for 0, busca o timezone do servidor.
    If( cTmzMarc == "0" ) 
        cTmzMarc := FWTimeStamp(5, StoD( aMarcacoes[nI,3] ), cHoraMarc)
        cTmzMarc := StrTran( cTmzMarc, ":" )
        cTmzMarc := Right( cTmzMarc, 5 )
    EndIf
    cDHMarc   := cDtMarc + "T" + cHoraMarc + cTmzMarc
    cNSR      := cValToChar( StrZero(nTipo03, 9) )
    
    cTexto := cNSR
    cTexto += cTipoReg
    cTexto += cDHMarc
    cTexto += cFixo
    cTexto += SRA->RA_CIC
    
    //Monta CRC16 -- Função da TEC
    cExecCRC := "CRCCalc( 8, cTexto, @cCRC16 )"	
    &cExecCRC
    cTexto += cCRC16

    cChave := cValToChar( StrZero( nTipo03, 6 ) )

    GravaAFD("03", cChave, cTexto)
    
Next nI
	
Return .T.

/*/{Protheus.doc} Tipo99
Trailer com o resumo do arquivo
@type  Static Function
@author Cí­cero Alves
@since 26/08/2022
/*/
Static Function Tipo99()
	
    Local cChave    := Replicate("9",6)
	Local cFixo	    := Replicate("9",9)
    Local cTipoReg  := "9"
	Local cTexto	:= ""
	Local cQnt02	:= Replicate("0",9)
	Local cQnt03	:= cValToChar(StrZero(nTipo03,9))
    Local cQnt04    := Replicate("0",9)
    Local cQnt05    := Replicate("0",9)
    Local cQnt06    := Replicate("0",9)
    Local cQnt07    := Replicate("0",9)
	
	cTexto := cFixo
	cTexto += cQnt02
	cTexto += cQnt03
    cTexto += cQnt04
    cTexto += cQnt05
    cTexto += cQnt06
    cTexto += cQnt07 
    cTexto += cTipoReg
	
	GravaAFD("09", cChave, cTexto)
	
Return

/*/{Protheus.doc} AfdCria()
Cria a tabela temporária que armazenará os dados antes de gravar no arquivo de texto
@type  Static Function
@author Cí­cero Alves
@since 24/08/2022
/*/
Static Function AfdCria()
	
	Local aStruct	:= {}
	Local aIndices	:= {}
	
	Static cAliasAFD := GetNextAlias()
	
	Aadd(aStruct, {"TIPO"       , "C",   2, 0})
	Aadd(aStruct, {"CODCHAVE"   , "C",   6, 0})
	Aadd(aStruct, {"TEXTO"      , "C", 302, 0})
	
	Aadd(aIndices, {"CODCHAVE", "TIPO"})
	
	oTmpAFD := RhCriaTrab(cAliasAFD, aStruct, aIndices)
	
Return

/*/{Protheus.doc} GravaAFD
Realiza a gravaão das informações na tabela temporária
@type  Static Function
@author Cí­cero Alves
@since 24/08/2022
@param cTipoReg, Caractere, Tipo do registro de acordo com o leiaute. Usado para ordenaão
@param cChave, Caractere, Chave da filial atual. Usado para ordenaão
@param cTexto, Caractere, Texto da linha do arquivo
/*/
Static Function GravaAFD(cTipoReg, cChave, cTexto)
	
	If oTmpAFD == NIL
		AfdCria()
	EndIf
	
	(cAliasAFD)->(RecLock(cAliasAFD, .T. ))
		(cAliasAFD)->TIPO       := cTipoReg
		(cAliasAFD)->CODCHAVE   := cChave
		(cAliasAFD)->TEXTO      := cTexto
	(cAliasAFD)->(MsUnlock())
	
Return

/*/{Protheus.doc} GeraArq
Gera o arquivo de texto com as informações gravadas na tabela temporária
@type  Static Function
@author Cí­cero Alves
@since 24/08/2022
/*/
Static Function GeraArq()
	
	Local cLocFile 	:= Alltrim(MV_PAR05)
	Local cFile		:= ""
	Local cArqtmp	:= GetNextAlias()
	Local nHandle	:= 0
	
	cFile := Upper(GetPvProfString( GetEnvServer(), "StartPath", "", GetAdv97()))
	cFile := AllTrim(cFile + cArqtmp)
	
	nHandle := MsFCreate(cFile)
	
	(cAliasAFD)->(dbGoTop())
	
	While (cAliasAFD)->(!EoF())
		FWrite(nHandle, RTrim((cAliasAFD)->TEXTO) + CRLF)
		(cAliasAFD)->(dbSkip())
	EndDo
	
	fClose(nHandle)
	__CopyFile(cFile, cLocFile)
	fErase(cFile)
	
Return

/*/{Protheus.doc} Transforma
Formata uma data para "AAAA-MM-dd"
@type Static Function
@author Cí­cero Alves
@since 26/08/2022
@param dData, Data, Data que será formatada
@return cRet, Caractere, Data com o formato "AAAA-MM-dd"
/*/
Static Function Transforma(dData)
Return (Right(Str(Year(dData)), 4) + "-" + StrZero(Month(dData), 2) + "-" + StrZero(Day(dData), 2))

/*/{Protheus.doc} GetRS3
Busca as informações da tabela RS3
@type  Static Function
@author Henrique Ferreira
@since 26/08/2022
@return aMarcacoes, Array, Marcações do funcionário no perí­odo
/*/
Static Function GetRS3()

Local aMarcacoes := {}
Local cQryObj    := ""
Local cQryRS3    := GetNextAlias()	
Local cSTR       := Upper("Batida por GeoLocalização")
	
If oStRS3 == Nil
    oStRS3 := FWPreparedStatement():New()
    cQryObj := " SELECT RS3_FILIAL, RS3_MAT, RS3_DATA, RS3_HORA 
    If lTimeZone
        cQryObj += ", RS3_TMZ"
    EndIf
    cQryObj += " FROM " + RetFullName('RS3', cEmpAnt) + " RS3 "
    cQryObj += " WHERE"
    cQryObj += " RS3.RS3_FILIAL = ?"
    cQryObj += " AND RS3.RS3_MAT = ?"
    cQryObj += " AND RS3.RS3_DATA >= ?"
    cQryObj += " AND RS3.RS3_DATA <= ?"
    cQryObj += " AND RTRIM(UPPER(RS3.RS3_JUSTIF)) = '" + cSTR + "'"
    cQryObj += " AND RS3.D_E_L_E_T_ = ' '"

    cQryObj := ChangeQuery(cQryObj)
    oStRS3:SetQuery(cQryObj)
EndIf

//DEFINIí‡íƒO DOS PARí‚METROS.
oStRS3:SetString(1,SRA->RA_FILIAL)
oStRS3:SetString(2,SRA->RA_MAT)
oStRS3:SetDate(3, dDataIni)
oStRS3:SetDate(4, dDataFim)

cQryObj := oStRS3:GetFixQuery()

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQryRS3,.T.,.T.)
oStRS3:doTcSetField(cQryRS3)

If (cQryRS3)->(!eof())
    While (cQryRS3)->(!Eof())
        aAdd( aMarcacoes, ;
             { (cQryRS3)->RS3_FILIAL, ;
               (cQryRS3)->RS3_MAT, ;
               (cQryRS3)->RS3_DATA, ;
               (cQryRS3)->RS3_HORA, ;
               Iif( lTimeZone, (cQryRS3)->RS3_TMZ, 0 ) } )
        (cQryRS3)->(dBSkip())
    EndDo
EndIf
(cQryRS3)->(DbCloseArea())
	
Return aMarcacoes

/*/{Protheus.doc} fExistPerg
Verifica se o grupo de perguntas existe no ambiente
@type static function
@author Cí­cero Alves
@since 26/08/2022
@param cPergunte, Caractere, Código do grupo de perguntas
@return lRet, Lógico, Indica se o grupo de perguntas existe ou nío
/*/
Static Function fExistPerg(cPergunte)
	
	Local lRet	:= .F.
	Local oSX1	:= FWSX1Util():New()
	
	oSX1:AddGroup(cPergunte)
	oSX1:SearchGroup()
	
	If !Empty(oSX1:aGrupo[1, 2])
		lRet:= .T.
	EndIf
	
	FreeObj(oSX1)
	
Return lRet

/*/{Protheus.doc} fGetAFD
Abre a interface para a seleção do diretório de geração doarquivo
@type  Function
@author Cícero Alves
@since 30/08/2022
@return lRet, Lógico, Retorna falso quando o caminho estiver em branco
/*/
Function fGetAFD()
	
Local mvRet := Alltrim(ReadVar())

oWnd := GetWndDefault()

cFile := MV_PAR05

If Empty(cFile)
    cFile := cGetFile(, OemToAnsi(STR0008))  //"Selecione Arquivo"
EndIf

If !( "AFD" $ Upper( cFile )  .And. "REP" $ Upper( cFile ) )
    // Atenção. "O nome do arquivo precisa conter as palavras AFD e REP_A."
    MsgAlert(OEMToAnsi(STR0011), OEMToAnsi(STR0012) )
    Return .F.
EndIf

&mvRet := cFile

If oWnd != Nil
    GetdRefresh()
EndIf
	
Return .T.

/*/{Protheus.doc} fGetInscr
Função para buscar os dados do CNPJ do empregador das tabelas do eSocial
@type  Function
@author Henrique Ferreira
@since 30/08/2022
@return lRet, Lógico, Retorna falso quando o caminho estiver em branco
/*/
Static Function fGetInscr( aInfo )

Local aRet      := {}
Local lMid      := SuperGetMv( "MV_MID",, .F. )

aAdd( aRet, {"1", "53485215000106"} )

If lMid
    fGetRJA( aInfo, @aRet )
else
    fGetCRM( aInfo, @aRet )
EndIf

Return aRet


/*/{Protheus.doc} fGetRJA
Função para buscar os dados da tabela RJA
@type  Function
@author Henrique Ferreira
@since 30/08/2022
@return lRet, Lógico, Retorna falso quando o caminho estiver em branco
/*/
Static Function fGetRJA( aInfo, aRet )

Local aArea   := GetArea()
Local cCodFil := xFilial("RJ9", cFilCentra)

DbSelectArea("RJ9")
DbSetOrder(3)
If DbSeek( cCodFil + aInfo[8] )
    // Posiciona na CRM
    DbSelectArea("RJA")
    DbSetOrder(2)
    If DbSeek( RJ9->RJ9_FILIAL + RJ9->RJ9_TPINSC + RJ9->RJ9_NRINSC )
        aRet[1,1] := RJA->RJA_TPINSC
        aRet[1,2] := RJA->RJA_CNPJ
    EndIf
EndIf

RestArea( aArea )

Return .T.

/*/{Protheus.doc} fGetCRM
Função para buscar os dados da tabela CRM
@type  Function
@author Henrique Ferreira
@since 30/08/2022
@return lRet, Lógico, Retorna falso quando o caminho estiver em branco
/*/
Static Function fGetCRM( aInfo, aRet )

Local aArea   := GetArea()
Local cFilCIE := xFilial("C1E", cFilCentra)

DbSelectArea("C1E")
DbSetOrder(1)
If DbSeek( cFilCIE + cEmpAnt + cFilCentra )
    // Posiciona na CRM
    DbSelectArea("CRM")
    DbSetOrder(1)
    If DbSeek( C1E->C1E_FILIAL + C1E->C1E_ID + C1E->C1E_VERSAO )
        aRet[1,1] := "1"
        aRet[1,2] := CRM->CRM_CNPJ
    EndIf
EndIf

RestArea( aArea )

Return .T.

/*/{Protheus.doc} fGetNumCCT
Retorna o numero da convenção coletiva
@type  Function
@author Henrique Ferreira
@since 25/10/2022
@version 1.0
@return cCodigo
/*/
Function fGetNumCCT()

Local aArea    := GetArea()
Local cCodCCT  := Alltrim(&(ReadVar()))
Local cNumConv := Replicate("9",17)

DbSelectArea("SWY")
DbSetOrder(1)

If SWY->(dbSeek( xFilial("SWY", cFilAnt) + cCodCCT ) )
    cNumConv := If( !Empty( SWY->WY_NCONVEN ), SWY->WY_NCONVEN, cNumConv )
EndIF

SetMVValue("TCFA140","MV_PAR01",cCodCCT)
SetMVValue("TCFA140","MV_PAR07",cNumConv)

//Grava os perguntes
Pergunte("TCFA140",.F.)

RestArea( aArea )

Return .T.
