#INCLUDE "PROTHEUS.CH"
#INCLUDE 'tbiconn.ch'
#INCLUDE 'VEIA120.CH'

#DEFINE PulaLinha CHR(13) + CHR(10)

Static nLIniCli := 1500 // Qtde de Clientes por arquivo TXT CARGA INICIAL
Static nLIniVei := 1500 // Qtde de Veiculos por arquivo TXT CARGA INICIAL
Static nLDiaCli := 25   // Qtde de Clientes por arquivo transmissao DIARIO
Static nLDiaVei := 50   // Qtde de Veiculos por arquivo transmissao DIARIO
Static nLErrCli := 1000 // Qtde Limite de Clientes com Problema de DEALER
Static cVEIA120 := 'VEIA120' // Rotina
Static cArqErr  := 'ERRO_WS_' // Arq. error web services
Static cTagData := 'DATA' // tag Data (configurações)
Static cTagHora := 'HORA' // tag Hora (configurações)
Static cTagExec := 'ULTIMA_EXECUCAO' // tag Ultima Execução (configurações)
Static cUsrWS   := 'USUARIO_WS' // usuario de acesso ws
Static cPwdWS   := 'SENHA_WS' // senha de acesso ws
Static cUrlCli  := 'URL_CLIENTES_WS' // url web service clientes
Static cUrlVeic := 'URL_VEICULOS_WS' // url web service veiculos
Static cOFIA541 := 'OFIA541' // rotina OFIA541 para gravação na VRN
Static cVeiaDml := 'SCRM_DLM' // rotina OFIA541 para gravação na VRN Delimita

/*/{Protheus.doc} VEIA120
	Geracao dos Arquivos SCRM Scania ( Clientes / Veiculos )

	@author Andre Luis Almeida
	@since 11/03/2019
/*/
Function VEIA120( aParam )
    Local dDtExec
    Local cHrExec	
    Local cEmpr      := ""
    Local cFil       := ""
    Local lFilSF2    := .f. // Filial especifica da NF
    Local cFilSF2    := ""
    Local cFilSA1    := ""
    Local cFilVO1    := ""
    Local cQAlias    := 'SQLALIAS'
    Local cQuery     := ""
    Local cFilCampo  := ""
    Local aFilDEALER := {}
    Local aEst       := {}
    Local oSCRMParametros := VESCRMParametros():New() // Classe SCRM Parametros
    local oConfig := OfScaniaConfig():new("SCRM", "OFIA541")
    local jConfig := oConfig:getConfig()
    local nReenviado := 0
    local lReturn := .t.
    local cOrigem := STR0010 //STR0010 #MENU
    
    Private nOpcao    := 0 //1=Carga Inicial ; 2=Diario ; 3=Reenvio Diario
    private aPe 	  := {}
    Private lSchedule := FWGetRunSchedule()
    Private aReenvXml := {}
	Private cDirTXT  := '' // Diretorio dos arquivos

    Default aParam   := { cEmpAnt , cFilAnt , 2, {} }

    if lSchedule //DMS_LOGGER //DVARMIL-11602 OFIA538
        aParam   := {MV_PAR01,MV_PAR02,MV_PAR03,{}}
        cOrigem := STR0009 //STR0009 #Schedule
    endif

    cEmpr  := aParam[1]
    cFil   := aParam[2]
    nOpcao := aParam[3]
	if len(aParam) > 3
    	aReenvXml := aClone(aParam[4])
	endif

    dDtExec := dDataBase
    cHrExec := substr(Time(),1,2)+substr(Time(),4,2)
    
    if ExistBlock("VA120PET")
        aPe := ExecBlock("VA120PET",.f.,.f.)
    endif

	If (nOpcao == 2 .or. nOpcao == 3) //2=Diario | 3=Reenvio Diario - Essas opções exigem a configuração para conexão com Web Service e Gatilhos
		if Empty(jConfig["SCRM_INTEGRACAO_ATIVA"]) .or. jConfig["SCRM_INTEGRACAO_ATIVA"] == "2" //Configuração não existe ou a integração foi desativada
			lReturn := .f.

			if lSchedule 
				VA120029F_LogaExecucao(cOrigem, STR0011, VA120030F_ParametrosString(STR0007)+' '+'OFIA541', .t.) //STR0011 #"Erro" //STR0007 #"A configuração SCRM não foi identificada! Analise a rotina"
			else
				VA120029F_LogaExecucao(cOrigem, STR0011, VA120030F_ParametrosString(STR0007)+' '+'OFIA541', .t.) //STR0011 #"Erro" //STR0007 #"A configuração SCRM não foi identificada! Analise a rotina"
				FMX_HELP("VEIA120",STR0007+' '+"OFIA541",STR0002)		
			endif

			Return lReturn
		endif
	Endif

    if jConfig["SCRM_GERA_ARQUIVO"] == "1" .and. (!ExistDir(jConfig["SCRM_FILE_PATH"]))
        makeDir(alltrim(jConfig["SCRM_FILE_PATH"]))
    endif

	cDirTXT := alltrim(jConfig["SCRM_FILE_PATH"])

    //
    // Levanta Filiais VE4 / DEALER ( customizado )
    //
    If ExistBlock("VA120FCP")
        cFilCampo := ExecBlock("VA120FCP",.f.,.f.) // Exemplo de PE:       Return FG_CONVSQL("SUBS")+"(VAM.VAM_RGIATU,3,2)"
        If !Empty(cFilCampo)
            cQuery := "SELECT DISTINCT VE4_FILIAL , VE4_CODCON "
            cQuery += "  FROM " + RetSqlName("VE4")
            cQuery += " WHERE D_E_L_E_T_=' '"
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
            Do While (cQAlias)->(!Eof())
                aAdd(aFilDEALER,{ ( cQAlias )->( VE4_FILIAL ) , Alltrim( str( val( right( ( cQAlias )->( VE4_CODCON ) , TamSX3("VEF_DEALER")[1] ) ) ) ) })
                ( cQAlias )->(dbSkip())
            EndDo
            ( cQAlias )->( dbCloseArea() )
            If ExistBlock("VA120FVT")
                aFilDEALER := ExecBlock("VA120FVT",.f.,.f.,{aFilDEALER}) // Retorno do PE - Vetor das Filiais com os Codigos de DEALER correspondentes
            EndIf
        EndIf
    EndIf
    //
    // Levanta Filiais das NF Vendas
    //
    cFilSF2 := xFilial("SF2")
    cFilSA1 := xFilial("SA1")
    If "["+cFilSF2+"]" == "["+cFilSA1+"]"
        lFilSF2 := .t.
    Else
        cFilSF2 := ""
        cQuery := "SELECT DISTINCT F2_FILIAL "
        cQuery += "  FROM " + RetSqlName("SF2")
        cQuery += " WHERE D_E_L_E_T_=' '"
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
        Do While (cQAlias)->(!Eof())
            cFilSF2 += "'"+( cQAlias )->( F2_FILIAL )+"',"
            ( cQAlias )->(dbSkip())
        EndDo
        ( cQAlias )->( dbCloseArea() )
        If len(cFilSF2) > 0
            cFilSF2 := left(cFilSF2,len(cFilSF2)-1)
        EndIf
    EndIf
    //
    // Levanta Descricao dos UF
    //
    cQuery := "SELECT X5_CHAVE , X5_DESCRI"
    cQuery += "  FROM " + RetSQLName("SX5" )
    cQuery += " WHERE X5_FILIAL='"+xFilial("SX5")+"'"
    cQuery += "   AND X5_TABELA='12'"
    cQuery += "   AND D_E_L_E_T_=' '"
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
    Do While (cQAlias)->(!Eof())
        aAdd(aEst,{ Alltrim(( cQAlias )->( X5_CHAVE )) , Alltrim(( cQAlias )->( X5_DESCRI )) })
        ( cQAlias )->(dbSkip())
    Enddo
    ( cQAlias )->( dbCloseArea() )
    //
    // Levanta Filiais do VO1
    //
    cQuery := "SELECT DISTINCT VO1_FILIAL "
    cQuery += "  FROM " + RetSqlName("VO1")
    cQuery += " WHERE D_E_L_E_T_=' '"
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
    Do While (cQAlias)->(!Eof())
        cFilVO1 += "'"+( cQAlias )->( VO1_FILIAL )+"',"
        ( cQAlias )->(dbSkip())
    Enddo
    ( cQAlias )->( dbCloseArea() )
    If len(cFilVO1) > 0
        cFilVO1 := left(cFilVO1,len(cFilVO1)-1)
    Else
        cFilVO1 := xFilial("VO1")
    EndIf
    //
    // Executar Carga Inicial / Diario
    //
    If nOpcao == 1 // Carga Inicial
        If !VA1200011_Clientes_CargaInicial( dDtExec , cHrExec , lFilSF2 , cFilSF2 , aEst , cFilCampo , aFilDEALER )
            Return .f.
        EndIf
        
		VA1200061_Veiculos_CargaInicial( dDtExec , cHrExec , cFilVO1 )
        
		oSCRMParametros:DelimitaInit( dDtExec , Transform(cHrExec,"@R 99:99")+":00", cVeiaDml, cTagExec, cTagData, cTagHora )
        //
    ElseIf (nOpcao == 2 .or. nOpcao == 3) //2=Diario | 3=Reenvio Diario
        If !VA1200121_Clientes_Diario( dDtExec , cHrExec , lFilSF2 , cFilSF2 , aEst , cFilCampo , aFilDEALER, nOpcao, aReenvXml, @nReenviado )
            Return .f.
        else
            if nOpcao == 3
                if lSchedule //TODO Retirar o schedule
                    VA120029F_LogaExecucao(cOrigem, STR0012, STR0003+" "+STR0004+" "+CValToChar(nReenviado), .t.) //STR0012 #Atenção //STR0003 #"Reenvio concluído com sucesso!" //STR0004 #"O total de clientes reenviados:"
                else
                    VA120029F_LogaExecucao(cOrigem, STR0012, STR0003+" "+STR0004+" "+CValToChar(nReenviado), .t.) //STR0012 #Atenção //STR0003 #"Reenvio concluído com sucesso!" //STR0004 #"O total de clientes reenviados:"
                    FMX_HELP("VEIA120",STR0003,STR0004+" "+CValToChar(nReenviado)) //STR0003 #"Reenvio concluído com sucesso!" //STR0004 #"O total de clientes reenviados:"
                endif
            endif
        EndIf

        If !VA1200171_Veiculos_Diario( dDtExec , cHrExec , cFilVO1 )
            Return .f.
        EndIf
        
        if nOpcao == 2 //3=Reenvio Diario nao deve delimitar
            oSCRMParametros:DelimitaInit( dDtExec , Transform(cHrExec,"@R 99:99")+":00", cVeiaDml, cTagExec, cTagData, cTagHora )
        endif
    EndIf
Return .t.

/*/{Protheus.doc} VA1200011_Clientes_CargaInicial
SQL da Carga Inicial de Clientes
@author Andre Luis Almeida
@since 14/03/2019
@param dDtExec, data, Data da Execucao
@param cHrExec, caracter, Hora da Execucao
@param lFilSF2, logico, Filial Especifica da NF
@param cFilSF2, caracter, Filiais da NF
@param aEst, vetor, Vetor com as Descricoes dos Estados
@param cFilCampo, caracter, Campo de Filial em SQL referente ao cliente
@param aFilDEALER, vetor, Vetor com o DE/PARA de Filiais e Nro.DEALER Scania
@return lOk, logico, Arquivo de Cliente gerado?
@type function
/*/
Static Function VA1200011_Clientes_CargaInicial( dDtExec , cHrExec , lFilSF2 , cFilSF2 , aEst , cFilCampo , aFilDEALER )
	Local cArqCarg 	 := 'Carga_Inicial_Clientes_' // Arquivo carga inicial clientes
	Local cArqPDCI 	 := 'Problema_DEALER_Clientes_Carga_Inicial_' // Arq. log de problemas clientes carga inicial
	Local cQAux      := ""
	Local cQuery     := ""
	Local cQAlias    := 'SQLALIAS'
	Local nContCli   := 0
	Local nPos       := 0
	Local nTXTSeq    := 1
	Local cTXTGeral  := ""
	Local cTXTNome   := cArqCarg+dtos(dDtExec)+"_"+cHrExec 
	Local cErrNome   := cArqPDCI+dtos(dDtExec)+"_"+cHrExec 
	Local cDEALER    := ""
	Local cFilDealer := ""
	Local cErrGeral  := ""
	Local nErrSeq    := 1
	Local nContErr   := 0
	Local lOk        := .f.
	local oConfig := OfScaniaConfig():new("SCRM", "OFIA541")
	local jConfig := oConfig:getConfig()
	local cSufixQuery := ''
	Local lVCF_SCRMED:= ( VCF->(FieldPos("VCF_SCRMED")) > 0 )

	cSufixQuery := "  FROM " + RetSqlName("SA1") + " SA1 "
	cSufixQuery += "  JOIN " + RetSqlName("VCF") + " VCF ON ( VCF.VCF_FILIAL='"+xFilial("VCF")+"' AND VCF.VCF_CODCLI=SA1.A1_COD AND VCF.VCF_LOJCLI=SA1.A1_LOJA  "
	
	if jConfig['SCRM_APENAS_CLIENTES'] == "1"
		cSufixQuery += " AND VCF.VCF_VENVEI<>' ' "
	endif
	if lVCF_SCRMED
		cSufixQuery += " AND VCF.VCF_SCRMED='1'"
	endif

	cSufixQuery += " AND VCF.D_E_L_E_T_=' ' )"
	cSufixQuery += "  LEFT JOIN " + RetSqlName("VAM") + " VAM ON ( VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' ' )"
	cSufixQuery += "  LEFT JOIN " + RetSqlName("VQK") + " VQK ON ( VQK.VQK_FILIAL='"+xFilial("VQK")+"' AND VQK.VQK_CODIGO=VCF.VCF_GRUECN AND VQK.D_E_L_E_T_=' ' )"
	cSufixQuery += " WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"'"
	cSufixQuery += " AND SA1.D_E_L_E_T_=' '"

	cQAux  := "SELECT " + cFilCampo + cSufixQuery
	cQuery += "SELECT " + VA1200161_Campos_Query_Clientes( cFilCampo , "1" ) + cSufixQuery

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
	Do While (cQAlias )->(!Eof())
		//
		If !Empty(cFilCampo)
			If !Empty(( cQAlias )->( VCF_GRUECN )) .and. "["+( cQAlias )->( VQK_CODCLI )+( cQAlias )->( VQK_LOJCLI )+"]" <> "["+( cQAlias )->( A1_COD )+( cQAlias )->( A1_LOJA )+"]"
				cFilDealer := FM_SQL(cQAux)
			Else
				cFilDealer := ( cQAlias )->( FILDEALER )
			EndIf
			nPos := ascan(aFilDEALER,{|x| x[1] == cFilDealer })
			If nPos > 0
				cDEALER := aFilDEALER[nPos,2]
			Else
				cErrGeral += left( ( cQAlias )->( A1_COD )+"-"+( cQAlias )->( A1_LOJA )+" "+( cQAlias )->( A1_NOME )+space(40),40)+" "
				cErrGeral += left( "Grp.Econ.: "+( cQAlias )->( VCF_GRUECN )+" "+( cQAlias )->( VQK_CODCLI )+"-"+( cQAlias )->( VQK_LOJCLI )+space(25),25)+" "
				cErrGeral += "Filial: "+cFilDealer+PulaLinha
				nContErr++
				If nContErr > nLErrCli // Quebrar em varios arquivos
					VA1200111_Gravar_TXT( cErrGeral , cErrNome , nErrSeq , ".TXT",1 ) // Gravar os Problemas de DEALER relacionado ao Cadastro de Clientes
					cErrGeral := ""
					nErrSeq++
					nContErr := 0
				EndIf
				( cQAlias )->(dbSkip())
				Loop
			EndIf
		EndIf
		cTXTGeral += VA1200021_Clientes_Layout_CargaInicial( cQAlias , lFilSF2 , cFilSF2 , aEst , cDEALER ) + PulaLinha
		VA1200031_Clientes_Gravar_VEF_Controle( "1" , dDtExec , cHrExec , ( cQAlias )->( A1_COD ) , ( cQAlias )->( A1_LOJA ) , cDEALER , cTXTNome , nTXTSeq , ".TXT" )
		nContCli++
		If nContCli > nLIniCli // Quebrar em varios arquivos
			VA1200111_Gravar_TXT( cTXTGeral , cTXTNome , nTXTSeq , ".TXT",0 ) // Gravar cTXTGeral
			cTXTGeral := ""
			nTXTSeq++
			nContCli := 0
		EndIf
		lOk := .t. // Arquivo de Cliente gerado!

		( cQAlias )->(dbSkip())
	Enddo
	( cQAlias )->( dbCloseArea() )
	VA1200111_Gravar_TXT( cErrGeral , cErrNome , nErrSeq , ".TXT",1 ) // Gravar os Problemas de DEALER relacionado ao Cadastro de Clientes
	VA1200111_Gravar_TXT( cTXTGeral , cTXTNome , nTXTSeq , ".TXT",0 ) // Gravar cTXTGeral
	dbSelectArea("SA1")
Return lOk

/*/{Protheus.doc} VA1200021_Clientes_Layout_CargaInicial
Layout do TXT referente a Carga Inicial de Clientes
@author Andre Luis Almeida
@since 14/03/2019
@param cQAlias, caracter, Alias do SQL
@param lFilSF2, logico, Filial Especifica da NF
@param cFilSF2, caracter, Filiais da NF
@param aEst, vetor, Vetor com todos os estados para buscar a Descricao
@param cDEALER, caracter, Codigo do Dealer referente a Filial
@return cTXT, caracter, texto total do cliente a ser gerado
@type function
/*/
Static Function VA1200021_Clientes_Layout_CargaInicial( cQAlias , lFilSF2 , cFilSF2 , aEst , cDEALER )
	Local cTXT    := ""
	Local cEnd    := ""
	Local cEst    := Alltrim(IIf(!Empty(( cQAlias )->( VAM_ESTADO )),( cQAlias )->( VAM_ESTADO ),( cQAlias )->( A1_EST )))
	Local cMun    := Alltrim(IIf(!Empty(( cQAlias )->( VAM_DESCID )),( cQAlias )->( VAM_DESCID ),( cQAlias )->( A1_MUN )))
	Local nPosEst := IIf(!Empty(cEst),aScan(aEst, { |x| x[1] == cEst } ),0)
	Local cDesEst := IIf(nPosEst>0,aEst[nPosEst,2],cEst) // descricao do estado
	Local aDatSF2 := {}
	local cCodPais := ''
	local cDescPais := ''
	local cStsCred := ''
	local cSiglaPais := ''
	local aCountry	:= VA120031K_SiglaPaisISOAlpha2()
	Local lA1_MSBLQL := ( SA1->(FieldPos("A1_MSBLQL")) > 0 )
	local cStsBlq := 'Ativo'
	local cA1Pessoa := ''
	local nPosPais := 0

	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_CGC ) )    , .f. ) + "||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_NOME ) )   , .t. ) + "||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_NREDUZ ) ) , .t. ) + "||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_INSCR ) )  , .f. ) + "||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( IIf(!Empty( ( cQAlias )->( A1_TEL ) ),( cQAlias )->( A1_DDD ),"") ) + Alltrim( ( cQAlias )->( A1_TEL ) ) , .f. ) + "||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_EMAIL ) )  , .f. ) + "||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( IIf(!Empty( ( cQAlias )->( A1_FAX ) ),( cQAlias )->( A1_DDD ),"") ) + Alltrim( ( cQAlias )->( A1_FAX ) ) , .f. ) + "||"
	cTXT += "null||"
	
	cEnd += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_END ) ) , .t. ) + "||"

	if !empty( ( cQAlias )->( A1_CODPAIS ) )
		cCodPais := ( cQAlias )->( A1_CODPAIS )
		cDescPais := alltrim(POSICIONE("CCH",1,xFilial("CCH")+cCodPais,"CCH_PAIS"))
	endif
	cEnd += VA1200101_Preencher_TXT( Alltrim( cCodPais ) , .t. ) + "||" 
	cEnd += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_BAIRRO ) ) , .t. ) + "||"
	cEnd += VA1200101_Preencher_TXT( cEst , .f. )                                  + "||"
	cEnd += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_CEP ) )    , .f. ) + "||"
	cEnd += VA1200101_Preencher_TXT( left( Alltrim( ( cQAlias )->( A1_IBGE ) ) , 6 ) , .f. ) + "||"
	cEnd += VA1200101_Preencher_TXT( cMun , .t. )                                  + "||"
	cEnd += VA1200101_Preencher_TXT( cDesEst , .t. )                               + "||"

	cEnd += VA1200101_Preencher_TXT( Alltrim( cDescPais ) , .t. ) + "||" 

	cTXT += cEnd // Endereco 1
	cTXT += cEnd // Endedeco 2 (igual ao 1)

	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"

	cStsCred := X3COMBO("VCF_SCRMSC",( cQAlias )->( VCF_SCRMSC ))
	if empty(cStsCred)
		cStsCred := 'null'
	endif
	cTXT += VA1200101_Preencher_TXT( cStsCred , .t. ) + "||"  // credithold
	cTXT += "null||"
	aDatSF2 := VA1200051_Clientes_Levanta_Datas_Vendas( lFilSF2 , cFilSF2 , ( cQAlias )->( A1_COD ) , ( cQAlias )->( A1_LOJA ) , "null" )
	cTXT += aDatSF2[1]+"||" // data ultima venda para Veiculos
	cTXT += aDatSF2[2]+"||" // data ultima venda para Peças
	cTXT += aDatSF2[3]+"||" // data ultima venda para Oficina
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"

	nPosPais := Ascan( aCountry, { |x| alltrim(upper(x[1])) == alltrim(upper(cDescPais)) } )
	if nPosPais > 0
		cSiglaPais := aCountry[nPosPais][2] // retorna pais com 2 letras
	endif
	
	cTXT += VA1200101_Preencher_TXT( cSiglaPais , .t. ) + "||"  
	cTXT += "1||" // globalaccount

	if lA1_MSBLQL .and. ( cQAlias )->( A1_MSBLQL ) == '1'
		cStsBlq := 'Inativo'
	endif
	cTXT += VA1200101_Preencher_TXT( cStsBlq , .t. ) + "||" 
	cTXT += "null||"
	cTXT += Alltrim(cDEALER)+"||"

	cA1Pessoa  := alltrim(upper(( cQAlias )->( A1_PESSOA )))
	if cA1Pessoa == 'J'
		cA1Pessoa := '1'
	elseif cA1Pessoa == 'F'
		cA1Pessoa := '2'
	else
		cA1Pessoa := 'null'
	endif
	cTXT += VA1200101_Preencher_TXT( cA1Pessoa , .t. ) + "||"
	cTXT += "3||"
	cTXT += "Protheus||" // system
	cTXT += "Nao"

Return cTXT

/*/{Protheus.doc} VA1200031_Clientes_Gravar_VEF_Controle
Gravacao da tabela VEF - Clientes
@author Andre Luis Almeida
@since 14/03/2019
@param cTipo, caracter, Tipo: 1-Carga Inicial / 2-Diario
@param dDtExec, data, Data da Execucao
@param cHrExec, caracater, Hora da Execucao
@param cCodCli, caracter, Codigo do Cliente
@param cLojCli, caracter, Loja do Cliente
@param cDEALER, caracter, Codigo do Dealer referente a Filial
@param cTXTNome, caracter, nome do arquivo a ser gerado
@param nTXTSeq, numerico, sequencial do nome do arquivo a ser gerado
@param cArqExt, caracter, Extensao do Arquivo - exemplo: ".TXT"
@type function
/*/
Static Function VA1200031_Clientes_Gravar_VEF_Controle( cTipo , dDtExec , cHrExec , cCodCli , cLojCli , cDEALER , cTXTNome , nTXTSeq , cArqExt )
	DbSelectArea("VEF")
	DbSetOrder(1)
	RecLock("VEF",.t.)
	VEF->VEF_FILIAL := xFilial("VEF")
	VEF->VEF_CODIGO := GetSXENum("VEF","VEF_CODIGO") // Codigo Interno (sequencial)
	VEF->VEF_TPEXEC := cTipo // 1 - Carga Inicial / 2 - Diario
	VEF->VEF_DTEXEC := dDtExec
	VEF->VEF_HREXEC := cHrExec
	VEF->VEF_CODCLI := cCodCli
	VEF->VEF_LOJCLI := cLojCli
	VEF->VEF_DEALER := cDEALER
	VEF->VEF_STATUS := "1" // 1 - Gerado apenas o Cliente / 2 - Gerado o Cliente e os Veiculos do Cliente
	VEF->VEF_ARQUIV := cTXTNome+"_"+strzero(nTXTSeq,4)+cArqExt
	MsUnLock()
	ConfirmSX8()
Return

/*/{Protheus.doc} VA1200041_Clientes_Atualizar_VEF_Controle
Atualiza Status do VEF - Clientes
@author Andre Luis Almeida
@since 14/03/2019
@param nRecVEF, numerico, RecNo do registro - Tabela VEF - Clientes
@param cStatus, caracter, Status a ser gravado no registro VEF
@type function
/*/
Static Function VA1200041_Clientes_Atualizar_VEF_Controle( nRecVEF , cStatus )
	DbSelectArea("VEF")
	DbGoTo( nRecVEF )
	If VEF->VEF_STATUS <> cStatus
		RecLock("VEF",.f.)
		VEF->VEF_STATUS := cStatus // 1 - Gerado apenas o Cliente / 2 - Gerado o Cliente e os Veiculos do Cliente
		MsUnLock()
	EndIf
Return

/*/{Protheus.doc} VA1200051_Clientes_Levanta_Datas_Vendas
Levanta Datas ultimas de Vendas (Veiculos/Balcao/Oficina) para o Cliente
@author Andre Luis Almeida
@since 14/03/2019
@param lFilSF2, logico, Filial Especifica da NF
@param cFilSF2, caracter, Filiais da NF
@param cCodCli, caracter, Codigo do Cliente
@param cLojCli, caracter, Loja do Cliente
@param cDefault, caracter, conteudo default de retorno
@return aDatSF2, vetor, Vetor das ultimas Vendas de { Veiculos , Balcao , Oficina }
@type function
/*/
Static Function VA1200051_Clientes_Levanta_Datas_Vendas( lFilSF2 , cFilSF2 , cCodCli , cLojCli , cDefault )
	Local cPrefVEI := GetNewPar("MV_PREFVEI","VEI")
	Local cPrefBAL := GetNewPar("MV_PREFBAL","BAL")
	Local cPrefOFI := GetNewPar("MV_PREFOFI","OFI")
	Local aDatSF2 := {cDefault,cDefault,cDefault}
	Local cQuery  := ""
	Local cQAlias := "SQLSF2"
	local oStatement := fwPreparedStatement():new()
	local cFixQuery := ''

	If !lFilSF2 .and. Empty(cFilSF2) // Deve gerar todas as filiais da SF2, mas a tabela SF2 está vazia e o cFIlSF2 está em branco
		Return aDatSF2
	Endif
	cQuery := "SELECT SF2.F2_PREFORI , MAX(SF2.F2_EMISSAO) AS EMISSAO"
	cQuery += "  FROM " + RetSqlName("SF2") + " SF2 "
	cQuery += "  JOIN " + RetSqlName("SD2") + " SD2 ON ( SD2.D2_FILIAL=SF2.F2_FILIAL AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D_E_L_E_T_=' ' )"
	cQuery += "  JOIN " + RetSqlName("SF4") + " SF4 ON ( SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.F4_OPEMOV='05' AND SF4.D_E_L_E_T_=' ' )" // OPEMOV = 05 = VENDA
	If lFilSF2 // Filial Especifica
		cQuery += " WHERE SF2.F2_FILIAL = '"+cFilSF2+"'"
	Else // Todas Filiais
		cQuery += " WHERE SF2.F2_FILIAL IN ("+cFilSF2+")"
	EndIf
	cQuery += "   AND SF2.F2_CLIENTE= ? "
	cQuery +="    AND SF2.F2_LOJA= ? "
	cQuery += "   AND SF2.F2_PREFORI IN ('"+cPrefVEI+"','"+cPrefBAL+"','"+cPrefOFI+"')" // ( 'VEI' , 'BAL' , 'OFI' )
	cQuery += "   AND SF2.D_E_L_E_T_=' '"
	cQuery += " GROUP BY SF2.F2_PREFORI"

	oStatement:setQuery(cQuery)
	oStatement:setString(1, cCodCli)
	oStatement:setString(2, cLojCli)

	cFixQuery := oStatement:GetFixQuery()
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cFixQuery), cQAlias, .T., .T. )
	Do While (cQAlias)->(!Eof())
		Do Case
		Case ( cQAlias )->( F2_PREFORI ) == cPrefVEI // VEI
			aDatSF2[1] := Transform(( cQAlias )->( EMISSAO ),"@R 9999-99-99")
		Case ( cQAlias )->( F2_PREFORI ) == cPrefBAL // BAL
			aDatSF2[2] := Transform(( cQAlias )->( EMISSAO ),"@R 9999-99-99")
		Case ( cQAlias )->( F2_PREFORI ) == cPrefOFI // OFI
			aDatSF2[3] := Transform(( cQAlias )->( EMISSAO ),"@R 9999-99-99")
		EndCase
		( cQAlias )->(dbSkip())
	Enddo
	( cQAlias )->( dbCloseArea() )
Return aDatSF2

/*/{Protheus.doc} VA1200061_Veiculos_CargaInicial
SQL da Carga Inicial de Veiculos
@author Andre Luis Almeida
@since 14/03/2019
@param dDtExec, data, Data da Execucao
@param cHrExec, caracter, Hora da Execucao
@param cFilVO1, caracter, Filiais da Ordem de Servico
@type function
/*/
Static Function VA1200061_Veiculos_CargaInicial( dDtExec , cHrExec , cFilVO1 )
	Local cArqVeic  := 'Carga_Inicial_Veiculos_' // Arq. Carga inicial veiculos
	Local cQuery    := ""
	Local cQAlias   := 'SQLALIAS'
	Local nContVei  := 0
	Local nTXTSeq   := 1
	Local cTXTGeral := ""
	Local cTXTNome  := cArqVeic+dtos(dDtExec)+"_"+cHrExec 

	cQuery := VA1200191_Query_SQL_Veiculos( dDtExec , cHrExec )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
	Do While (cQAlias)->(!Eof())
		cTXTGeral += VA1200071_Veiculos_Layout_CargaInicial( cQAlias , cFilVO1 , ( cQAlias )->( VEF_DEALER ) ) + PulaLinha
		VA1200081_Veiculos_Gravar_VEV_Controle( ( cQAlias )->( VEF_CODIGO ) , dDtExec , cHrExec , ( cQAlias )->( VV1_CHASSI ) , cTXTNome , nTXTSeq , ".TXT" )
		VA1200041_Clientes_Atualizar_VEF_Controle( ( cQAlias )->( RECVEF ) , "2" )
		nContVei++
		If nContVei > nLIniVei // Quebrar em varios arquivos
			VA1200111_Gravar_TXT( cTXTGeral , cTXTNome , nTXTSeq , ".TXT",0 ) // Gravar cTXTGeral
			cTXTGeral := ""
			nTXTSeq++
			nContVei := 0
		EndIf
		( cQAlias )->(dbSkip())
	Enddo
	( cQAlias )->( dbCloseArea() )
	VA1200111_Gravar_TXT( cTXTGeral , cTXTNome , nTXTSeq , ".TXT",1 ) // Gravar cTXTGeral

	dbSelectArea("VV1")
Return .t.

/*/{Protheus.doc} VA1200071_Veiculos_Layout_CargaInicial
Layout do TXT referente a Carga Inicial de Veiculos
@author Andre Luis Almeida
@since 14/03/2019
@param cQAlias, caracter, Alias do SQL
@param cFilVO1, caracter, Filiais da Ordem de Servico
@param cDEALER, caracter, Codigo do Dealer referente a Filial
@return cTXT, caracter, texto total do veiculo a ser gerado
@type function
/*/
Static Function VA1200071_Veiculos_Layout_CargaInicial( cQAlias , cFilVO1 , cDEALER )
	Local cTXT   := ""
	Local aUltOS := VA1200091_Veiculos_Ultima_OS( cFilVO1 , ( cQAlias )->( VV1_CHASSI ) , "null" )
//
	cTXT += "null||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_CGC ) )    , .f. ) + "||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += VA1200101_Preencher_TXT( right(Alltrim( ( cQAlias )->( VV1_CHASSI ) ) , 7 ) , .f. ) + "||"
	cTXT += "null||"
	cTXT += "Sem||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( VV1_NUMMOT ) ) , .f. ) + "||"
	cTXT += "null||"
	cTXT += Alltrim(cDEALER)+"||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += aUltOS[1]+"||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "SCANIA||"
	cTXT += VA1200101_Preencher_TXT( right( Alltrim( ( cQAlias )->( VV1_FABMOD ) ) , 4 ) , .f. ) + "||"
	cTXT += IIf(( cQAlias )->( VV1_ESTVEI )=="0","Novo","Usado")   + "||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += aUltOS[2]+"||"
	cTXT += aUltOS[3]+"||"
	cTXT += "null||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( VV2_DESMOD ) ) , .t. ) + "||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += "null||"
	cTXT += VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( VV1_CHASSI ) ) , .f. ) + "||"
	cTXT += "null||"
	cTXT += "null||" // data EndDate
	cTXT += "null||" // data StartDate
//
Return cTXT

/*/{Protheus.doc} VA1200081_Veiculos_Gravar_VEV_Controle
Gravacao da tabela VEV - Veiculos
@author Andre Luis Almeida
@since 14/03/2019
@param cCodVEF, caracter, Codigo da Tabela pai ( VEF - Clientes )
@param dDtExec, data, Data da Execucao
@param cHrExec, caracater, Hora da Execucao
@param cChassi, caracter, Chassi do Veiculo
@param cTXTNome, caracter, nome do TXT a ser gerado
@param nTXTSeq, numerico, sequencial do nome do TXT a ser gerado
@param cArqExt, caracter, extensao do arquivo a ser gerado
@type function
/*/
Static Function VA1200081_Veiculos_Gravar_VEV_Controle( cCodVEF , dDtExec , cHrExec , cChassi , cTXTNome , nTXTSeq , cArqExt )
	DbSelectArea("VEV")
	DbSetOrder(1)
	RecLock("VEV",.t.)
	VEV->VEV_FILIAL := xFilial("VEV")
	VEV->VEV_CODIGO := GetSXENum("VEV","VEV_CODIGO") // Codigo Interno (sequencial)
	VEV->VEV_CODVEF := cCodVEF
	VEV->VEV_CHASSI := cChassi
	VEV->VEV_ARQUIV := cTXTNome+"_"+strzero(nTXTSeq,4)+cArqExt
	MsUnLock()
	ConfirmSX8()
Return

/*/{Protheus.doc} VA1200091_Veiculos_Ultima_OS
Levanta ultima OS do Veiculo
@author Andre Luis Almeida
@since 14/03/2019
@param cFilVO1, caracter, Filiais da OS
@param cChassi, caracter, Chassi do Veiculo
@param cDefault, caracter, conteudo default do retorno da funcao
@return aRetOS, vetor, Dados da ultima OS do Veiculo
@type function
/*/
Static Function VA1200091_Veiculos_Ultima_OS( cFilVO1 , cChassi , cDefault )
	Local aRetOS  := { cDefault , cDefault , cDefault }
	Local cQuery  := ""
	Local cQAlias := "SQLVO1"
	local oStatement := fwPreparedStatement():new()
	local cFixQuery := ''
	
	cQuery := "SELECT VO1_DATABE , VO1_HORABE , VO1_KILOME "
	cQuery += "  FROM " + RetSqlName("VO1")
	cQuery += " WHERE VO1_FILIAL IN ("+cFilVO1+")"
	cQuery += "   AND VO1_CHASSI = ? "
	cQuery += "   AND D_E_L_E_T_=' '"
	cQuery += " ORDER BY VO1_DATABE DESC , VO1_HORABE DESC"

	oStatement:setQuery(cQuery)
	oStatement:setString(1, cChassi)

	cFixQuery := oStatement:GetFixQuery()

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cFixQuery), cQAlias, .T., .T. )
	If (cQAlias)->(!Eof())
		aRetOS[1] := Transform(( cQAlias )->( VO1_DATABE ),"@R 9999-99-99")+" "+Transform(( cQAlias )->( VO1_HORABE ),"@R 99:99")+":00"
		aRetOS[2] := Alltrim(Transform(( cQAlias )->( VO1_KILOME ),"@E 999999999999999"))
		aRetOS[3] := Transform(( cQAlias )->( VO1_DATABE ),"@R 9999-99-99")
	EndIf
	( cQAlias )->( dbCloseArea() )
Return aRetOS

/*/{Protheus.doc} VA1200101_Preencher_TXT
Preenche o TXT com conteudo ou NULL
@author Andre Luis Almeida
@since 14/03/2019
@param cTexto, caracter, conteudo passado
@return cTexto, caracter, conteudo passado ou retorna "null" quando conteudo esta em branco
@type function
/*/
Static Function VA1200101_Preencher_TXT(cTexto,lNoAccent)
	Local nPos := 1
	Default lNoAccent := .f.
	If lNoAccent // Retira Acentuacao
		cTexto := FwNoAccent(cTexto)
	EndIf
	While nPos > 0
		nPos := at("&",cTexto)
		If nPos > 0
			cTexto := stuff(cTexto,nPos,1,"E")
		Endif
	Enddo
	If !Empty(cTexto)
		Return cTexto
	EndIf
Return "null"

/*/{Protheus.doc} VA1200111_Gravar_TXT
Gravacao do TXT no diretorio
@author Andre Luis Almeida
@since 14/03/2019
@param cTexto, caracter, conteudo do arquivo a ser gerado
@param cTXTNome, caracter, nome do arquivo a ser gerado
@param nTXTSeq, numerico, sequencial do nome do arquivo a ser gerado
@param cArqExt, caracter, extensao do arquivo a ser gerado
@type function
/*/
Static Function VA1200111_Gravar_TXT( cTexto , cTXTNome , nTXTSeq , cArqExt , nTpLog)
	Local nHnd := 0
	local oConfig := OfScaniaConfig():new("SCRM", "OFIA541")
	local jConfig := oConfig:getConfig()
	local cDiretorio := jConfig['SCRM_FILE_PATH']
	local lGravou := .f.
	local cOrigem := IIf(lSchedule, STR0009, STR0010) //STR0009 #Schedule //STR0010 #MENU
	local cMsgLog := '' //STR0011 #"Erro" //STR0012 #"Atenção"
	local cArqGerado := alltrim(cDiretorio) +"/"+ cTXTNome+"_"+strzero(nTXTSeq,4)+cArqExt
	default nTpLog := 0

	cMsgLog := iif(nTpLog > 0,STR0011,STR0012)

	If !Empty(cTexto) .and. jConfig["SCRM_GERA_ARQUIVO"] == "1"
		nHnd := FCREATE( cArqGerado , 0 )
		if fWrite(nHnd,cTexto) > 0
			lGravou := .t.
		endif
		fClose(nHnd)

		VA120029F_LogaExecucao(cOrigem, cMsgLog, STR0014+' : '+cArqGerado, .t.) //STR0014 #"Arquivo gerado em"
	EndIf
Return lGravou

/*/{Protheus.doc} VA1200121_Clientes_Diario 
SQL do Diario de Clientes/Veiculos
@author Andre Luis Almeida
@since 15/03/2019
@param dDtExec, data, Data da Execucao
@param cHrExec, caracter, Hora da Execucao
@param lFilSF2, logico, Filial Especifica da NF
@param cFilSF2, caracter, Filiais da NF
@param aEst, vetor, Vetor com as Descricoes dos Estados
@param cFilCampo, caracter, Campo de Filial em SQL referente ao cliente
@param aFilDEALER, vetor, Vetor com o DE/PARA de Filiais e Nro.DEALER Scania
@return lOk, logico, Arquivo de Cliente gerado?
@type function
/*/
Static Function VA1200121_Clientes_Diario( dDtExec , cHrExec , lFilSF2 , cFilSF2 , aEst , cFilCampo , aFilDEALER, nOpcao, aReenvXml, nReenviado )		
	Local cArqDCli 	 := 'Diario_Clientes_' // Arq. Diario Clientes
	Local cArqPDD  	 := 'Problema_DEALER_Clientes_Diario_'  // Arq. log de problemas clientes diario
	Local cTagLog    := '_TTAT_LOG' // tag banco de dados tab. audit trail
	Local cQAux      := ""
	Local cQuery     := ""
	Local cQyIni     := ""
	Local cQyFin     := ""
	Local cNamVCF    := RetSqlName("VCF")
	Local cNamVV1    := RetSqlName("VV1")
	Local cNamSA1    := RetSqlName("SA1")
	Local cNamVAM    := RetSqlName("VAM")
	Local cNamVQK    := RetSqlName("VQK")
	local cNamVO1	 := RetSqlName('VO1')
	local cNamVs1	 := RetSqlName('VS1')
	local cNamSF2	 := RetSqlName('SF2')
	Local cFilVCF    := xFilial("VCF")
	Local cFilSA1    := xFilial("SA1")
	Local cFilVAM    := xFilial("VAM")
	Local cFilVQK    := xFilial("VQK")
	Local cQAlias    := 'SQLALIAS'
	Local cQATRIG    := "SQLTRIG" // TRIGGER DO BANCO
	Local cDEALER    := ""
	Local cFilDealer := ""
	Local oSCRMParametros := VESCRMParametros():New() // Classe SCRM Parametros
	Local aDataHora  := oSCRMParametros:DataHoraInit(cVeiaDml)
	Local dDtIniRef  := STOD(aDataHora:GetJsonObject(cTagExec)[cTagData]) 
	Local cHrIniRef  := aDataHora:GetJsonObject(cTagExec)[cTagHora] 
	Local dDtFinRef  := dDtExec
	Local cHrFinRef  := Transform(cHrExec,"@R 99:99")+":00"
	Local cTXTEnvio  := ""	
	Local cTXTNome   := cArqDCli+dtos(dDtExec)+"_"+cHrExec 
	Local cErrNome   := cArqPDD+dtos(dDtExec)+"_"+cHrExec 
	Local nContCli   := 0
	Local nPos       := 0
	Local nTXTSeq    := 1
	Local cErrGeral  := ""
	Local nErrSeq    := 1
	Local nContErr   := 0
	Local oSqlHelp   := DMS_SqlHelper():New()
	Local lVCFTrigg  := oSqlHelp:ExistTable(cNamVCF+cTagLog) 
	Local lSA1Trigg  := oSqlHelp:ExistTable(cNamSA1+cTagLog)
	Local lVV1Trigg  := oSqlHelp:ExistTable(cNamVV1+cTagLog)
	local lVO1Trigg  := oSqlHelp:ExistTable(cNamVO1+cTagLog)
	local lVS1Trigg  := oSqlHelp:ExistTable(cNamVs1+cTagLog)
	local lSF2Trigg	 := oSqlHelp:ExistTable(cNamSF2+cTagLog)
	Local lVV1_MSBLQL:= ( VV1->(FieldPos("VV1_MSBLQL")) > 0 )
	Local lVCF_SCRMED:= ( VCF->(FieldPos("VCF_SCRMED")) > 0 )
	Local lOk        := .f.
	Local lOkWS      := .t.
	local oConfig := OfScaniaConfig():new("SCRM", "OFIA541")
	local jConfig := oConfig:getConfig()
	local lClienteCarteiraVinculada := .f.
	Local nI := 0
	Local cInClientes := ""
	local lReenvXml := .f.

	default nOpcao := 0
	default aReenvXml := {}
	default nReenviado := 0

	if jConfig['SCRM_APENAS_CLIENTES'] == "1"
		lClienteCarteiraVinculada := .t.
	endif

	if nOpcao == 3 .and. len(aReenvXml) > 0 //filtrando clientes para reenvio de XML		
		For nI := 1 To Len(aReenvXml)
			cInClientes += "'"+alltrim(aReenvXml[nI][1])+alltrim(aReenvXml[nI][2])+"',"
		Next nI
		If !Empty(cInClientes)
			cInClientes := Left(cInClientes, Len(cInClientes)-1)
			lReenvXml := .t.
		EndIf
	endif

	// Query para posicionar nos dados do Cliente do VCF
	cQyIni := "SELECT " + VA1200161_Campos_Query_Clientes( cFilCampo , "2" )
	cQyIni += "  FROM " + cNamVCF + " VCF"
	cQyIni += "  JOIN " + cNamSA1 + " SA1 ON ( SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_COD=VCF.VCF_CODCLI AND SA1.A1_LOJA=VCF.VCF_LOJCLI"	
	cQyIni += " AND SA1.D_E_L_E_T_=' ' )"
	
	cQyIni += "  LEFT JOIN " + cNamVAM + " VAM ON ( VAM.VAM_FILIAL='"+cFilVAM+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' ' )"
	cQyIni += "  LEFT JOIN " + cNamVQK + " VQK ON ( VQK.VQK_FILIAL='"+cFilVQK+"' AND VQK.VQK_CODIGO=VCF.VCF_GRUECN AND VQK.D_E_L_E_T_=' ' )"
	cQyIni += " WHERE "

	if lClienteCarteiraVinculada
		cQyFin += "   AND VCF.VCF_VENVEI<>' '"
	endif
	if lVCF_SCRMED
		cQyFin += "   AND VCF.VCF_SCRMED='1'"
	endif

	cQyFin += "   AND VCF.D_E_L_E_T_=' '"

	// Query para retornar a Filial do Grupo Economico
	cQAux := "SELECT " + cFilCampo
	cQAux += "  FROM " + cNamSA1 + " SA1 "
	cQAux += "  JOIN " + cNamVCF + " VCF ON ( VCF.VCF_FILIAL='"+cFilVCF+"' AND VCF.VCF_CODCLI=SA1.A1_COD AND VCF.VCF_LOJCLI=SA1.A1_LOJA  "
	
	if lClienteCarteiraVinculada
		cQAux += " AND VCF.VCF_VENVEI<>' '"
	endif
	if lVCF_SCRMED
		cQAux += " AND VCF.VCF_SCRMED='1'"
	endif

	cQAux += " AND VCF.D_E_L_E_T_=' ' ) "
	cQAux += "  LEFT JOIN " + cNamVAM + " VAM ON ( VAM.VAM_FILIAL='"+cFilVAM+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' ' )"
	cQAux += "  LEFT JOIN " + cNamVQK + " VQK ON ( VQK.VQK_FILIAL='"+cFilVQK+"' AND VQK.VQK_CODIGO=VCF.VCF_GRUECN AND VQK.D_E_L_E_T_=' ' )"
	cQAux += " WHERE SA1.A1_FILIAL='"+cFilSA1+"'"

	cQAux += " AND SA1.D_E_L_E_T_=' '"
	
	cQuery := ""

	if lReenvXml 	
	// No reenvio do XML (opcao=3) o sistema nao faz a auditoria
		cQuery := "SELECT DISTINCT VCF.R_E_C_N_O_ AS RECVCF"
		cQuery += "  FROM " + cNamVCF + " VCF"
		cQuery += "  JOIN " + cNamSA1 + " SA1 ON ( SA1.A1_FILIAL='"+cFilSA1+"' AND SA1.A1_COD=VCF.VCF_CODCLI AND SA1.A1_LOJA=VCF.VCF_LOJCLI AND SA1.D_E_L_E_T_=' ' )"
		cQuery += " WHERE VCF.VCF_FILIAL='"+cFilVCF+"'"
		cQuery += "   AND (SA1.A1_COD"+FG_CONVSQL("CONCATENA")+"SA1.A1_LOJA) IN ("+cInClientes+")"
		cQuery += "   AND VCF.D_E_L_E_T_=' '"
	else 
	// Query das TRIGGERs para identificar quais Clientes vao ser enviados
		If lVCFTrigg .and. (jConfig["SCRM_VCF"] == '1') // Possui tabela TRIGGER do VCF ?
			// CLIENTES VCF
			cQuery += "SELECT DISTINCT TRIGC.TTAT_RECNO AS RECVCF"
			cQuery += "  FROM " + cNamVCF + "_TTAT_LOG TRIGC"
			cQuery += " WHERE "
			cQuery += VA1200141_WhereSQL_Diario_DateTime( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , "TRIGC" )
			
			cQuery += VA120026J_ExecPontoDeEntrada("VCF", "TRIGC")
		EndIf

		If lSA1Trigg .and. (jConfig["SCRM_SA1"] == "1")  // Possui tabela TRIGGER do SA1 ?
			If !Empty(cQuery)
				cQuery += " UNION "
			EndIf
			// CLIENTES SA1
			cQuery += "SELECT DISTINCT VCF.R_E_C_N_O_ AS RECVCF"
			cQuery += "  FROM " + cNamSA1 + "_TTAT_LOG TRIGS"
			cQuery += "  JOIN " + cNamSA1 + " SA1 ON ( SA1.R_E_C_N_O_=TRIGS.TTAT_RECNO AND SA1.D_E_L_E_T_=' ' )"
			cQuery += "  JOIN " + cNamVCF + " VCF ON ( VCF.VCF_FILIAL='"+cFilVCF+"' AND VCF.VCF_CODCLI=SA1.A1_COD AND VCF.VCF_LOJCLI=SA1.A1_LOJA AND VCF.D_E_L_E_T_=' ' )"
			cQuery += " WHERE "
			cQuery += VA1200141_WhereSQL_Diario_DateTime( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , "TRIGS" )
	
			cQuery += VA120026J_ExecPontoDeEntrada("SA1", "TRIGS")
		EndIf

		If lVV1Trigg .and. (jConfig["SCRM_VV1"] == "1")  // Possui tabela TRIGGER do VV1 ?
			//
			If !Empty(cQuery)
				cQuery += " UNION "
			EndIf
			//
			// VEICULOS
			cQuery += "SELECT DISTINCT VCF.R_E_C_N_O_ AS RECVCF"
			cQuery += "  FROM " + cNamVV1 + "_TTAT_LOG TRIGV"
			cQuery += "  JOIN " + cNamVV1 + " VV1 ON ( VV1.R_E_C_N_O_=TRIGV.TTAT_RECNO"
			If lVV1_MSBLQL
				cQuery += " AND VV1.VV1_MSBLQL<>'1'"
			EndIf
			cQuery += " AND VV1.D_E_L_E_T_=' ' )"
			cQuery += "  JOIN " + cNamVCF + " VCF ON ( VCF.VCF_FILIAL='"+cFilVCF+"' AND VCF.VCF_CODCLI=VV1.VV1_PROATU AND VCF.VCF_LOJCLI=VV1.VV1_LJPATU AND VCF.D_E_L_E_T_=' ' )"
			cQuery += " WHERE"
			cQuery += VA1200141_WhereSQL_Diario_DateTime( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , "TRIGV" )
	
			cQuery += VA120026J_ExecPontoDeEntrada("VV1", "TRIGV")
		EndIf

		if lVO1Trigg .and. (jConfig["SCRM_VO1"] == "1") 
			if !Empty(cQuery)
				cQuery += " UNION "			
			endif
			//VO1 – Ordem de Serviço
			cQuery += " SELECT DISTINCT VCF.R_E_C_N_O_ AS RECVCF "
			cQuery += "	FROM " +cNamVO1+"_TTAT_LOG TRIG1"
			cQuery += " JOIN "+cNamVO1+" VO1 ON ( VO1.R_E_C_N_O_=TRIG1.TTAT_RECNO AND VO1.D_E_L_E_T_ = ' ' )"
			cQuery += " JOIN "+cNamVCF+" VCF ON ( VCF.VCF_FILIAL='"+cFilVCF+"' AND VCF.VCF_CODCLI = VO1.VO1_PROVEI AND VCF.VCF_LOJCLI = VO1.VO1_LOJPRO AND VCF.D_E_L_E_T_ = ' ' )"
			cQuery += " WHERE "
			cQuery += VA1200141_WhereSQL_Diario_DateTime( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , "TRIG1" )
	
			cQuery += VA120026J_ExecPontoDeEntrada("VO1", "TRIG1")
		endif

		if lVS1Trigg .and. (jConfig["SCRM_VS1"] == "1") 
			if !Empty(cQuery)
				cQuery += " UNION "
			endif
			//VS1 – Orçamento
			cQuery += " SELECT DISTINCT VCF.R_E_C_N_O_ AS RECVCF "
			cQuery += " FROM "+cNamVs1+"_TTAT_LOG TRIGVS1 "
			cQuery += " JOIN "+cNamVs1+" VS1 ON (VS1.R_E_C_N_O_=TRIGVS1.TTAT_RECNO AND VS1.D_E_L_E_T_ = ' ' )"
			cQuery += " JOIN "+cNamVCF+" VCF ON ( VCF.VCF_FILIAL='"+cFilVCF+"' AND VCF.VCF_CODCLI = VS1.VS1_CLIFAT AND VCF.VCF_LOJCLI = VS1.VS1_LOJA AND VCF.D_E_L_E_T_ = ' ' )"
			cQuery += " WHERE "
			cQuery += VA1200141_WhereSQL_Diario_DateTime( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , "TRIGVS1" )
	
			cQuery += VA120026J_ExecPontoDeEntrada("VS1", "TRIGVS1")
		endif

		if lSF2Trigg .and. (jConfig["SCRM_SF2"] == "1") 
			if !Empty(cQuery)
				cQuery += " UNION "
			endif
			//SF2 – Nota Fiscal de Saída
			cQuery += " SELECT DISTINCT VCF.R_E_C_N_O_ AS RECVCF "
			cQuery += " FROM "+cNamSF2+"_TTAT_LOG TRIGSF2 "
			cQuery += " JOIN "+cNamSF2+" SF2 ON (SF2.R_E_C_N_O_=TRIGSF2.TTAT_RECNO AND SF2.D_E_L_E_T_ = ' ' )"
			cQuery += " JOIN "+cNamVCF+" VCF ON ( VCF.VCF_FILIAL = '"+cFilVCF+"' AND VCF.VCF_CODCLI = SF2.F2_CLIENTE AND VCF.VCF_LOJCLI = SF2.F2_LOJA AND VCF.D_E_L_E_T_ = ' ' )" 
			cQuery += " WHERE "
			cQuery += VA1200141_WhereSQL_Diario_DateTime( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , "TRIGSF2" )
		endif

		cQuery += VA120026J_ExecPontoDeEntrada("SF2", "TRIGSF2")
	endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQATRIG, .T., .T. )
	Do While (cQATRIG)->(!Eof())
		//
		cQuery := cQyIni // Inicio da Query
		cQuery += "VCF.R_E_C_N_O_="+Alltrim(str(( cQATRIG )->( RECVCF )))
		cQuery += cQyFin // Final da Query
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
		Do While (cQAlias)->(!Eof())
			If !Empty(cFilCampo)
				If !Empty(( cQAlias )->( VCF_GRUECN )) .and. "["+( cQAlias )->( VQK_CODCLI )+( cQAlias )->( VQK_LOJCLI )+"]" <> "["+( cQAlias )->( A1_COD )+( cQAlias )->( A1_LOJA )+"]"
					cFilDealer := FM_SQL(cQAux)
				Else
					cFilDealer := ( cQAlias )->( FILDEALER )
				EndIf
				nPos := ascan(aFilDEALER,{|x| x[1] == cFilDealer })
				If nPos > 0
					cDEALER := aFilDEALER[nPos,2]
				Else
					cErrGeral += left( ( cQAlias )->( A1_COD )+"-"+( cQAlias )->( A1_LOJA )+" "+( cQAlias )->( A1_NOME )+space(40),40)+" "
					cErrGeral += left( "Grp.Econ.: "+( cQAlias )->( VCF_GRUECN )+" "+( cQAlias )->( VQK_CODCLI )+"-"+( cQAlias )->( VQK_LOJCLI )+space(25),25)+" "
					cErrGeral += "Filial: "+cFilDealer+PulaLinha
					nContErr++
					If nContErr > nLErrCli // Quebrar em varios arquivos
						VA1200111_Gravar_TXT( cErrGeral , cErrNome , nErrSeq , ".TXT" ) // Gravar os Problemas de DEALER relacionado ao Cadastro de Clientes
						cErrGeral := ""
						nErrSeq++
						nContErr := 0
					EndIf
					( cQAlias )->(dbSkip())
					Loop
				EndIf
			EndIf
			//
			If Empty(cTXTEnvio)
				cTXTEnvio += VA1200221_SOAP_Cabecalho("1") // Cabecalho Clientes
			EndIf
			cTXTEnvio += VA1200131_Clientes_Layout_Diario( cQAlias , lFilSF2 , cFilSF2 , aEst , cDEALER )
			VA1200031_Clientes_Gravar_VEF_Controle( "2" , dDtExec , cHrExec , ( cQAlias )->( A1_COD ) , ( cQAlias )->( A1_LOJA ) , cDEALER , cTXTNome , nTXTSeq , ".XML" )
			//
			nContCli++
			If nContCli > nLDiaCli // Quebrar em varios arquivos
				cTXTEnvio += VA1200231_SOAP_Rodape("1") // Rodape Clientes
				If VA1200201_WebService( "1" , cTXTEnvio ) // WEBSERVICE - Cliente
					VA1200111_Gravar_TXT( cTXTEnvio , cTXTNome , nTXTSeq , ".XML",0 ) // Gravar cTXTEnvio
				Else
					VA1200111_Gravar_TXT( cTXTEnvio , cArqErr+cTXTNome , nTXTSeq , ".XML",1 ) 
					lOkWS := .f.
				EndIf
				cTXTEnvio := ""
				nTXTSeq++
				nContCli := 0
			EndIf
			lOk := .t. // Arquivo de Cliente gerado!
			if nOpcao == 3
				nReenviado++
			endif

			( cQAlias )->(dbSkip())
		Enddo
		( cQAlias )->( dbCloseArea() )
		( cQATRIG )->(dbSkip())
	Enddo
	( cQATRIG )->( dbCloseArea() )
	VA1200111_Gravar_TXT( cErrGeral , cErrNome , nErrSeq , ".TXT",1 ) // Gravar os Problemas de DEALER relacionado ao Cadastro de Clientes
	VA120025J_LogVk5({cTXTEnvio, '', jConfig})
	If !Empty(cTXTEnvio)
		cTXTEnvio += VA1200231_SOAP_Rodape("1") // Rodape Clientes
		If VA1200201_WebService( "1" , cTXTEnvio ) // WEBSERVICE - Cliente
			VA1200111_Gravar_TXT( cTXTEnvio , cTXTNome , nTXTSeq , ".XML",0 ) // Gravar cTXTEnvio
		Else
			VA120025J_LogVk5({cTXTEnvio, '', jConfig})
			VA1200111_Gravar_TXT( cTXTEnvio , cArqErr+cTXTNome , nTXTSeq , ".XML",1 ) 
			lOkWS := .f.
		EndIf
	EndIf
	If !lOkWS
		lOk := .f.
	EndIf

	VA120025J_LogVk5({cTXTEnvio, '', jConfig})
	dbSelectArea("SA1")
Return lOk

/*/{Protheus.doc} VA1200131_Clientes_Layout_Diario
Layout referente ao Diario de Clientes
@author Andre Luis Almeida
@since 14/03/2019
@param cQAlias, caracter, Alias do SQL
@param lFilSF2, logico, Filial Especifica da NF
@param cFilSF2, caracter, Filiais da NF
@param aEst, vetor, Vetor com todos os estados para buscar a Descricao
@param cDEALER, caracter, Codigo do Dealer referente a Filial
@return cTXT, caracter, Layout utilizado no WEBSERVICE
@type function
/*/
Static Function VA1200131_Clientes_Layout_Diario( cQAlias , lFilSF2 , cFilSF2 , aEst , cDEALER )
	Local cTXT    := ""
	Local cEst    := Alltrim(IIf(!Empty(( cQAlias )->( VAM_ESTADO )),( cQAlias )->( VAM_ESTADO ),( cQAlias )->( A1_EST )))
	Local cMun    := Alltrim(IIf(!Empty(( cQAlias )->( VAM_DESCID )),( cQAlias )->( VAM_DESCID ),( cQAlias )->( A1_MUN )))
	Local nPosEst := IIf(!Empty(cEst),aScan(aEst, { |x| x[1] == cEst } ),0)
	Local cDesEst := IIf(nPosEst>0,aEst[nPosEst,2],cEst) // descricao do estado
	Local aDatSF2 := {}
	local cCodPais := ''
	local cDescPais := ''
	local cStsCred := ''
	local cSiglaPais := ''
	local aCountry	:= VA120031K_SiglaPaisISOAlpha2()
	Local lA1_MSBLQL := ( SA1->(FieldPos("A1_MSBLQL")) > 0 )
	local cStsBlq := 'Ativo'
	local cA1Pessoa := ''
	local nPosPais := 0

	cTXT += '<v1:Account>'+PulaLinha

	If !Empty(( cQAlias )->( A1_CGC ))
		cTXT += "<v11:accountnumber>"+Alltrim( ( cQAlias )->( A1_CGC ) )+"</v11:accountnumber>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_NOME ))
		cTXT += "<v11:name>"+Alltrim( VA1200101_Preencher_TXT( ( cQAlias )->( A1_NOME ) , .t. ) )+"</v11:name>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_NREDUZ ))
		cTXT += "<v11:global_tradename>"+Alltrim( VA1200101_Preencher_TXT( ( cQAlias )->( A1_NREDUZ ) , .t. ) )+"</v11:global_tradename>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_INSCR ))
		cTXT += "<v11:global_vatnumber>"+Alltrim( ( cQAlias )->( A1_INSCR ) )+"</v11:global_vatnumber>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_TEL ))
		cTXT += "<v11:telephone1>"+Alltrim( ( cQAlias )->( A1_DDD ) ) + Alltrim( ( cQAlias )->( A1_TEL ) )+"</v11:telephone1>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_EMAIL ))
		cTXT += "<v11:emailaddress1>"+Alltrim( ( cQAlias )->( A1_EMAIL ) )+"</v11:emailaddress1>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_FAX ))
		cTXT += "<v11:fax>"+Alltrim( ( cQAlias )->( A1_DDD ) ) + Alltrim( ( cQAlias )->( A1_FAX ) )+"</v11:fax>"+PulaLinha
	EndIf

	If !Empty(( cQAlias )->( A1_END ))
		cTXT += "<v11:address1_line1>"+VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_END ) ), .t. )+"</v11:address1_line1>"+PulaLinha
	EndIf

	if !empty( ( cQAlias )->( A1_CODPAIS ) )
		cCodPais := alltrim(( cQAlias )->( A1_CODPAIS ))
		cTXT += "<v11:global_address1countryid>"+cCodPais+"</v11:global_address1countryid>"+PulaLinha
	endif	
	
	If !Empty(( cQAlias )->( A1_BAIRRO ))
		cTXT += "<v11:address1_line2>"+Alltrim( VA1200101_Preencher_TXT( ( cQAlias )->( A1_BAIRRO ) , .t. ) )+"</v11:address1_line2>"+PulaLinha
	EndIf
	If !Empty(cEst)
		cTXT += "<v11:global_address1countyid>"+cEst+"</v11:global_address1countyid>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_CEP ))
		cTXT += "<v11:address1_postalcode>"+Alltrim( ( cQAlias )->( A1_CEP ) )+"</v11:address1_postalcode>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_IBGE ))
		cTXT += "<v11:global_address1cityid>"+left( Alltrim( ( cQAlias )->( A1_IBGE ) ) , 6 )+"</v11:global_address1cityid>"+PulaLinha
	EndIf
	If !Empty(cMun)
		cTXT += "<v11:address1_city>"+VA1200101_Preencher_TXT( cMun , .t. )+"</v11:address1_city>"+PulaLinha
	EndIf
	If !Empty(cDesEst)
		cTXT += "<v11:address1_county>"+VA1200101_Preencher_TXT( cDesEst , .t. )+"</v11:address1_county>"+PulaLinha
	EndIf

	if !empty(cCodPais)
		cDescPais := alltrim(POSICIONE("CCH",1,xFilial("CCH")+cCodPais,"CCH_PAIS"))
		if !empty(cDescPais)
			cTXT += "<v11:address1_country>"+cDescPais+"</v11:address1_country>"+PulaLinha
		endif	
	endif

	If !Empty(( cQAlias )->( A1_END ))
		cTXT += "<v11:address2_line1>"+VA1200101_Preencher_TXT( Alltrim( ( cQAlias )->( A1_END ) ), .t. )+"</v11:address2_line1>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_BAIRRO ))
		cTXT += "<v11:address2_line2>"+Alltrim( VA1200101_Preencher_TXT( ( cQAlias )->( A1_BAIRRO ) , .t. ) )+"</v11:address2_line2>"+PulaLinha
	EndIf
	If !Empty(cEst)
		cTXT += "<v11:global_address2countyid>"+cEst+"</v11:global_address2countyid>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_CEP ))
		cTXT += "<v11:address2_postalcode>"+Alltrim( ( cQAlias )->( A1_CEP ) )+"</v11:address2_postalcode>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( A1_IBGE ))
		cTXT += "<v11:global_address2cityid>"+left( Alltrim( ( cQAlias )->( A1_IBGE ) ) , 6 )+"</v11:global_address2cityid>"+PulaLinha
	EndIf
	If !Empty(cMun)
		cTXT += "<v11:address2_city>"+VA1200101_Preencher_TXT( cMun , .t. )+"</v11:address2_city>"+PulaLinha
	EndIf
	If !Empty(cDesEst)
		cTXT += "<v11:address2_county>"+VA1200101_Preencher_TXT( cDesEst , .t. )+"</v11:address2_county>"+PulaLinha
	EndIf
	if !empty(cDescPais)
		cTXT += "<v11:address2_country>"+cDescPais+"</v11:address2_country>"+PulaLinha
	endif

	cStsCred := X3COMBO("VCF_SCRMSC",( cQAlias )->( VCF_SCRMSC ))
	if !empty(cStsCred)
		cTXT += "<v11:creditonhold>"+cStsCred+"</v11:creditonhold>"+PulaLinha
	endif	

	aDatSF2 := VA1200051_Clientes_Levanta_Datas_Vendas( lFilSF2 , cFilSF2 , ( cQAlias )->( A1_COD ) , ( cQAlias )->( A1_LOJA ) , "" )
	If !Empty(aDatSF2[1])
		cTXT += "<v11:global_latestpurchasedatevehicles>"+aDatSF2[1]+"</v11:global_latestpurchasedatevehicles>"+PulaLinha
	EndIf
	If !Empty(aDatSF2[2])
		cTXT += "<v11:global_latestpurchasedateparts>"+aDatSF2[2]+"</v11:global_latestpurchasedateparts>"+PulaLinha
	EndIf
	If !Empty(aDatSF2[3])
		cTXT += "<v11:global_latestpurchasedateworkshop>"+aDatSF2[3]+"</v11:global_latestpurchasedateworkshop>"+PulaLinha
	EndIf

	If !Empty( ( cQAlias )->( VCF_SCRMID ) )
		cTXT += "<v11:global_scrmid>"+Alltrim(( cQAlias )->( VCF_SCRMID ))+"</v11:global_scrmid>"+PulaLinha
	EndIf

	nPosPais := Ascan( aCountry, { |x| alltrim(upper(x[1])) == alltrim(upper(cDescPais)) } )
	if nPosPais > 0
		cSiglaPais := aCountry[nPosPais][2] // retorna pais com 2 letras
	endif
	if !empty(cSiglaPais)
		cTXT += "<v11:global_countrycode>"+cSiglaPais+"</v11:global_countrycode>"+PulaLinha
	endif
	
	cTXT += "<v11:global_accounttype>1</v11:global_accounttype>"+PulaLinha

	if lA1_MSBLQL .and. ( cQAlias )->( A1_MSBLQL ) == '1'
		cStsBlq := 'Inativo'
	endif	
	cTXT += "<v11:global_sourcestatus>"+cStsBlq+"</v11:global_sourcestatus>"+PulaLinha

	cTXT += "<v11:dealer>"+Alltrim(cDEALER)+"</v11:dealer>"+PulaLinha
	
	cA1Pessoa  := alltrim(upper(( cQAlias )->( A1_PESSOA )))
	if cA1Pessoa == 'J'
		cA1Pessoa := '1'
	elseif cA1Pessoa == 'F'
		cA1Pessoa := '2'
	else
		cA1Pessoa := ''
	endif
	if !empty(cA1Pessoa)
		cTXT += "<v11:persontype>"+cA1Pessoa+"</v11:persontype>"+PulaLinha
	endif

	cTXT += "<v11:relationtype>3</v11:relationtype>"+PulaLinha
	cTXT += "<v11:originsystem>Protheus</v11:originsystem>"+PulaLinha
	cTXT += "<v11:cws>Nao</v11:cws>"+PulaLinha

	cTXT += '</v1:Account>'+PulaLinha

Return cTXT

/*/{Protheus.doc} VA1200141_WhereSQL_Diario_DateTime
Retorna o WHERE do DATE/TIME - TRIGGER DO BANCO
@author Andre Luis Almeida
@since 18/03/2019
@param dDtIniRef, date, data de referencia para Inicio
@param cHrIniRef, caracter, hora de referencia para Inicio
@param dDtFinRef, date, data de referencia para Final
@param cHrFinRef, caracter, hora de referencia para Final
@param cAlTrig, caracter, alias da TRIGGER
@return cQuery, caracter, WHERE do SQL referente ao filtro de Data/Hora da TRIGGER
/*/
Static Function VA1200141_WhereSQL_Diario_DateTime( dDtIniRef , cHrIniRef , dDtFinRef , cHrFinRef , cAlTrig )
	Local cQuery := ""

	If tcGetDb() == "ORACLE"
		cQuery += " TO_CHAR(" + cAlTrig + ".TTAT_DTIME,'yyyymmdd') || TO_CHAR(" + cAlTrig + ".TTAT_DTIME,'hh24miss') > '" + dtos(dDtIniRef) + cHrIniRef + "' "
		cQuery += " AND TO_CHAR(" + cAlTrig + ".TTAT_DTIME,'yyyymmdd') || TO_CHAR(" + cAlTrig + ".TTAT_DTIME,'hh24miss') <= '" + dtos(dDtFinRef) + cHrFinRef + "' "
	Else // SQL Server e outros
		cQuery += " " + cAlTrig + ".TTAT_DTIME > '" + dtos(dDtIniRef) + " " + cHrIniRef + "' "
		cQuery += " AND " + cAlTrig + ".TTAT_DTIME <= '" + dtos(dDtFinRef) + " " + cHrFinRef + "' "
	EndIf

Return cQuery

/*/{Protheus.doc} VA1200161_Campos_Query_Clientes
Campos retornados na Query de Clientes
@author Andre Luis Almeida
@since 18/03/2019
@param cFilCampo, caracter, Campo de Filial em SQL referente ao cliente
@return cQuery, caracter, Campos do SQL de Clientes
/*/
Static Function VA1200161_Campos_Query_Clientes( cFilCampo , cTpExec )
	Local cQuery := ""
	Local cQuery2 := '' //complemento customizado do endereço
	Local lVA120QRY := ExistBlock("VA120QRY") 
	Local lA1_MSBLQL  := ( SA1->(FieldPos("A1_MSBLQL")) > 0 )
	
	cQuery := "SA1.A1_COD     , "
	cQuery += "SA1.A1_LOJA    , "
	cQuery += "SA1.A1_CGC     , "
	cQuery += "SA1.A1_NOME    , "
	cQuery += "SA1.A1_NREDUZ  , "
	cQuery += "SA1.A1_INSCR   , "
	cQuery += "SA1.A1_DDD     , "
	cQuery += "SA1.A1_TEL     , "
	cQuery += "SA1.A1_EMAIL   , "
	cQuery += "SA1.A1_FAX     , "
	cQuery += "SA1.A1_END     , "
	cQuery += "SA1.A1_BAIRRO  , "
	cQuery += "SA1.A1_CEP     , "
	cQuery += "SA1.A1_IBGE    , "
	cQuery += "SA1.A1_MUN     , "
	cQuery += "SA1.A1_EST     , "
	cQuery += "SA1.A1_CODPAIS , " 
	cQuery += "SA1.A1_PESSOA , " 
	if lA1_MSBLQL
		cQuery += "SA1.A1_MSBLQL , "
	endif
	cQuery += "VAM.VAM_DESCID , "
	cQuery += "VAM.VAM_ESTADO , "
	If cTpExec == "2" // 2 - Diario
		cQuery += "VCF.VCF_SCRMID , "
	EndIf
	cQuery += "VCF.VCF_SCRMSC , "
	cQuery += "VCF.VCF_GRUECN , "
	cQuery += "VQK.VQK_CODCLI , "
	cQuery += "VQK.VQK_LOJCLI   "
	If !Empty(cFilCampo)
		cQuery += ", " + cFilCampo + " AS FILDEALER "
	EndIf

	If lVA120QRY
		cQuery2 := ExecBlock("VA120QRY",.f.,.f.,{cQuery}) // Exemplo de PE:       Return FG_CONVSQL("SUBS")+"(VAM.VAM_RGIATU,3,2)"
	endif

	if !empty(cQuery2)
		cQuery := cQuery2
	endif

Return cQuery

/*/{Protheus.doc} VA1200171_Veiculos_Diario
SQL da Carga Inicial de Veiculos
@author Andre Luis Almeida
@since 18/03/2019
@param dDtExec, data, Data da Execucao
@param cHrExec, caracter, Hora da Execucao
@param cFilVO1, caracter, Filiais da Ordem de Servico
@type function
/*/
Static Function VA1200171_Veiculos_Diario( dDtExec , cHrExec , cFilVO1 )
	Local cArqDVei := 'Diario_Veiculos_' // Arq. Diario Veiculos
	Local cQuery    := ""
	Local cQAlias   := 'SQLALIAS'
	Local nContVei  := 0
	Local nTXTSeq   := 1
	Local cTXTEnvio := ""
	Local cTXTNome  := cArqDVei+dtos(dDtExec)+"_"+cHrExec 
	Local lOk       := .t.	

	cQuery := VA1200191_Query_SQL_Veiculos( dDtExec , cHrExec )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cQAlias, .T., .T. )
	Do While (cQAlias)->(!Eof())
		If Empty(cTXTEnvio)
			cTXTEnvio += VA1200221_SOAP_Cabecalho("2") // Cabecalho Veiculos
		EndIf
		cTXTEnvio += VA1200181_Veiculos_Layout_Diario( cQAlias , cFilVO1 , ( cQAlias )->( VEF_DEALER ) )
		VA1200081_Veiculos_Gravar_VEV_Controle( ( cQAlias )->( VEF_CODIGO ) , dDtExec , cHrExec , ( cQAlias )->( VV1_CHASSI ) , cTXTNome , nTXTSeq , ".XML" )
		VA1200041_Clientes_Atualizar_VEF_Controle( ( cQAlias )->( RECVEF ) , "2" )
		nContVei++
		If nContVei > nLDiaVei // Quebrar em varios arquivos
			cTXTEnvio += VA1200231_SOAP_Rodape("2") // Rodape Veiculos
			If VA1200201_WebService( "2" , cTXTEnvio ) // WEBSERVICE - Veiculos
				VA1200111_Gravar_TXT( cTXTEnvio , cTXTNome , nTXTSeq , ".XML",0 ) // Gravar cTXTEnvio
			Else
				VA1200111_Gravar_TXT( cTXTEnvio , cArqErr+cTXTNome , nTXTSeq , ".XML",1 ) 
				lOk := .f.
			EndIf
			cTXTEnvio := ""
			nTXTSeq++
			nContVei := 0
		EndIf
		( cQAlias )->(dbSkip())
	Enddo
	( cQAlias )->( dbCloseArea() )
	If !Empty(cTXTEnvio)
		cTXTEnvio += VA1200231_SOAP_Rodape("2") // Rodape Veiculos
		If VA1200201_WebService( "2" , cTXTEnvio ) // WEBSERVICE - Veiculos
			VA1200111_Gravar_TXT( cTXTEnvio , cTXTNome , nTXTSeq , ".XML",0 ) // Gravar cTXTEnvio
		Else
			VA1200111_Gravar_TXT( cTXTEnvio , cArqErr+cTXTNome , nTXTSeq , ".XML",1 ) 
			lOk := .f.
		EndIf
	EndIf

	dbSelectArea("VV1")
Return lOk

/*/{Protheus.doc} VA1200181_Veiculos_Layout_Diario
Layout referente ao Diario de Veiculos
@author Andre Luis Almeida
@since 18/03/2019
@param cQAlias, caracter, Alias do SQL
@param cFilVO1, caracter, Filiais da Ordem de Servico
@param cDEALER, caracter, Codigo do Dealer referente a Filial
@return cTXT, caracter, Layout utilizado no WEBSERVICE
@type function
/*/
Static Function VA1200181_Veiculos_Layout_Diario( cQAlias , cFilVO1 , cDEALER )
	Local cTXT   := ""
	Local aUltOS := VA1200091_Veiculos_Ultima_OS( cFilVO1 , ( cQAlias )->( VV1_CHASSI ) , "" )

	cTXT += '<v1:Vehicle>'+PulaLinha

	If !Empty(( cQAlias )->( A1_CGC ))
		cTXT += "<v11:account_externalkey>"+Alltrim( ( cQAlias )->( A1_CGC ) )+"</v11:account_externalkey>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( VV1_CHASSI ))
		cTXT += "<v11:global_chassisnumber>"+right(Alltrim( ( cQAlias )->( VV1_CHASSI ) ) , 7 )+"</v11:global_chassisnumber>"+PulaLinha
	EndIf
	cTXT += "<v11:global_communicator>Sem</v11:global_communicator>"+PulaLinha
	If !Empty(( cQAlias )->( VV1_NUMMOT ))
		cTXT += "<v11:global_enginenumber>"+Alltrim( ( cQAlias )->( VV1_NUMMOT ) )+"</v11:global_enginenumber>"+PulaLinha
	EndIf
	cTXT += "<v11:home_workshop>"+Alltrim(cDEALER)+"</v11:home_workshop>"+PulaLinha
	If !Empty(aUltOS[1])
		cTXT += "<v11:global_lastservicedate>"+aUltOS[1]+"</v11:global_lastservicedate>"+PulaLinha
	EndIf
	cTXT += "<v11:global_make>SCANIA</v11:global_make>"+PulaLinha
	If !Empty(( cQAlias )->( VV1_FABMOD ))
		cTXT += "<v11:global_modelyear>"+right( Alltrim( ( cQAlias )->( VV1_FABMOD ) ) , 4 )+"</v11:global_modelyear>"+PulaLinha
	EndIf
	cTXT += "<v11:global_newused>"+IIf(( cQAlias )->( VV1_ESTVEI )=="0","Novo","Usado")+"</v11:global_newused>"+PulaLinha
	If !Empty(aUltOS[2])
		cTXT += "<v11:global_mileage>"+aUltOS[2]+"</v11:global_mileage>"+PulaLinha
	EndIf
	If !Empty(aUltOS[3])
		cTXT += "<v11:global_totalmileageupdated>"+aUltOS[3]+"</v11:global_totalmileageupdated>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( VV2_DESMOD ))
		cTXT += "<v11:global_vehiclemodel>"+Alltrim( VA1200101_Preencher_TXT( ( cQAlias )->( VV2_DESMOD ) , .t. ) )+"</v11:global_vehiclemodel>"+PulaLinha
	EndIf
	If !Empty(( cQAlias )->( VV1_CHASSI ))
		cTXT += "<v11:global_vinnumber>"+Alltrim( ( cQAlias )->( VV1_CHASSI ) )+"</v11:global_vinnumber>"+PulaLinha
	EndIf

	cTXT += '</v1:Vehicle>'+PulaLinha

Return cTXT

/*/{Protheus.doc} VA1200191_Query_SQL_Veiculos
Retorna a Query de Veiculos
@author Andre Luis Almeida
@since 18/03/2019
@param dDtExec, date, Data de Referencia da Execucao
@param cHrExec, caracter, Hora de Referencia da Execucao
@return cQuery, caracter, Query do SQL de Veiculos
@type function
/*/
Static Function VA1200191_Query_SQL_Veiculos( dDtExec , cHrExec )

	Local lVV1_MSBLQL 	:= ( VV1->(FieldPos("VV1_MSBLQL")) > 0 )
	Local cMarFrota 	:= FMX_RETMAR("SCA") // SCANIA
	Local cQuery      	:= ""
	local oConfig 		:= OfScaniaConfig():new("SCRM", "OFIA541")
	local jConfig 		:= oConfig:getConfig()
	local cAnoFrota 	:= StrZero(Year(dDataBase) - jConfig['SCRM_LEVANTAR_FROTA'], 4) // Frota dos ultimos anos
	Local lVCF_SCRMED	:= ( VCF->(FieldPos("VCF_SCRMED")) > 0 )

	cQuery := "SELECT VEF.R_E_C_N_O_ AS RECVEF ,"
	cQuery += "       VEF.VEF_CODIGO ,"
	cQuery += "       VEF.VEF_DEALER ,"
	cQuery += "       SA1.A1_CGC     ,"
	cQuery += "       VV1.VV1_CHASSI ,"
	cQuery += "       VV1.VV1_NUMMOT ,"
	cQuery += "       VV1.VV1_FABMOD ,"
	cQuery += "       VV1.VV1_ESTVEI ,"
	cQuery += "       VV2.VV2_DESMOD  "
	cQuery += "  FROM " + RetSqlName("VEF") + " VEF "
	cQuery += "  JOIN " + RetSqlName("VV1") + " VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_PROATU=VEF.VEF_CODCLI AND VV1.VV1_LJPATU=VEF.VEF_LOJCLI AND VV1.VV1_CODMAR='"+cMarFrota+"' AND "+FG_CONVSQL("SUBS")+"(VV1.VV1_FABMOD,1,4)>= '"+cAnoFrota+"'"
	If lVV1_MSBLQL
		cQuery += " AND VV1.VV1_MSBLQL<>'1'"
	EndIf
	cQuery += " AND VV1.D_E_L_E_T_=' ' )"
	cQuery += "  LEFT JOIN " + RetSqlName("VV2") + " VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VV1.VV1_CODMAR AND VV2.VV2_MODVEI=VV1.VV1_MODVEI AND VV2.VV2_SEGMOD=VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_=' ' )"
	cQuery += "  JOIN " + RetSqlName("SA1") + " SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VEF.VEF_CODCLI AND SA1.A1_LOJA=VEF.VEF_LOJCLI"
	cQuery += " AND SA1.D_E_L_E_T_=' ' )"
	cQuery += "  JOIN " + RetSqlName("VCF") + " VCF ON ( VCF.VCF_FILIAL='"+xFilial("VCF")+"' AND VCF.VCF_CODCLI=SA1.A1_COD AND VCF.VCF_LOJCLI=SA1.A1_LOJA "
	
	if jConfig['SCRM_APENAS_CLIENTES'] == "1"
		cQuery += " AND VCF.VCF_VENVEI<>' ' "
	endif
	if lVCF_SCRMED
		cQuery += " AND VCF.VCF_SCRMED='1'"
	endif
	
	cQuery += " AND VCF.D_E_L_E_T_=' ' )"
	cQuery += " WHERE VEF.VEF_FILIAL='"+xFilial("VEF")+"'"
	cQuery += "   AND VEF.VEF_DTEXEC='"+dtos(dDtExec)+"'"
	cQuery += "   AND VEF.VEF_HREXEC='"+cHrExec+"'"
	cQuery += "   AND VEF.D_E_L_E_T_=' '"
Return cQuery

/*/{Protheus.doc} VA1200201_WebService
Conecta com o WEBSERVICE e envia os Dados de Clientes/Veiculos
@author Andre Luis Almeida
@since 22/03/2019
@param cTpCliVei, caracter, Tipo: Cliente ou Veiculo
@param cTXTEnvio, caracter, Texto a ser enviado
@type function
/*/
Static Function VA1200201_WebService( cTpCliVei , cTXTEnvio )
    Local oWsdl    := Nil
    Local cWebServ := ""
    Local c_USERWS := ''
    Local c_PASSWS := ''
    Local c_URLCWS := ''
    Local c_URLVWS := ''
    Local cOperation := ""
    Local cRetSend   := ""
    Local cCreds := ''
    Local cAuthHeader := ''
    local oConfig := OfScaniaConfig():new("SCRM", "OFIA541")
    local jConfig := oConfig:getConfig()
    local cErrorWs := ''
    local cOrigem := IIf(lSchedule, STR0009, STR0010) //STR0009 #Schedule //STR0010 #MENU
	local lConfigOff := .f.

    default cTpCliVei := ''
    default cTXTEnvio := ''

    if ValType(jConfig) == "J"
        c_USERWS := alltrim(padr(jConfig['SCRM_USER_WEBSERVICE'], 25))
        c_PASSWS := alltrim(padr(jConfig['SCRM_PSW_WEBSERVICE'], 15))
        c_URLCWS := alltrim(padr(jConfig['SCRM_CLIENTES_URL_WEBSERVICE'], 120))
        c_URLVWS := alltrim(padr(jConfig['SCRM_VEICULOS_URL_WEBSERVICE'], 120))
    else
        if !lSchedule
            VA120029F_LogaExecucao(cOrigem, STR0011, STR0001+' : '+STR0002, .t.) //STR0011 #"Erro" //STR0001 #"VRN sem configuração SCRM cadastrada" //STR0002 #"Entre na rotina de configuração SCRM e faça o cadastro dos dados web."
            FMX_HELP("VA1200201", STR0001, STR0002) //STR0001 #"VRN sem configuração SCRM cadastrada" //STR0002 #"Entre na rotina de configuração SCRM e faça o cadastro dos dados web."
        else
            VA120029F_LogaExecucao(cOrigem, STR0011, STR0001+' : '+STR0002, .t.) //STR0011 #"Erro" //STR0001 #"VRN sem configuração SCRM cadastrada"
        endif
        VA120025J_LogVk5({cTXTEnvio, cRetSend, jConfig})
        Return .f.
    endif

	lConfigOff := Empty(c_USERWS) .or. Empty(c_PASSWS) .or. Empty(c_URLCWS) .or. Empty(c_URLVWS)

    cCreds := c_USERWS + ":" + c_PASSWS // Monta a string usuario:senha
    cAuthHeader := "Basic " + Encode64(cCreds) // Codifica a string em Base64 para o cabeçalho

    If !Empty(cTXTEnvio) .and. !lConfigOff
        If cTpCliVei == "1" // Clientes
            cWebServ := c_URLCWS
            cOperation := "UpdateAccount" //"UpdateAccount"
        Else // Veiculos
            cWebServ := c_URLVWS
            cOperation := "UpdateVehicle" //"UpdateVehicle"
        EndIf

        oWsdl := TWsdlManager():New()
        oWsdl:lSSLInsecure := .T.
        oWsdl:lVerbose := .T.
        lRet := oWsdl:ParseURL(cWebServ)
        If !lRet
            cErrorWs := "ParseURL Tp"+cTpCliVei+" - " + oWsdl:cError
            if !lSchedule
                VA120029F_LogaExecucao(cOrigem, STR0011, cErrorWs, .t.) //STR0011 #"Erro"
                FMX_HELP("VA1200201", cErrorWs, STR0008) //STR0008 #"configuração SCRM"
            else
                VA120029F_LogaExecucao(cOrigem, STR0011, cErrorWs, .t.) //STR0011 #"Erro"
            endif
            Return .f.
        EndIf

        lRet := oWsdl:SetOperation( cOperation ) .or. oWsdl:SetOperation( upper(cOperation) )

        If !lRet
            cErrorWs := "SetOperation Tp"+cTpCliVei+" - " + oWsdl:cError
            if !lSchedule
                VA120029F_LogaExecucao(cOrigem, STR0011, cErrorWs, .t.) //STR0011 #"Erro"
                FMX_HELP("VA1200201", cErrorWs, STR0005) //STR0005 #"Problema com o serviço web:"
            else
                VA120029F_LogaExecucao(cOrigem, STR0011, cErrorWs, .t.) //STR0011 #"Erro"
            endif

            VA120025J_LogVk5({cTXTEnvio, cRetSend, jConfig})
            Return .f.
        EndIf

        oWsdl:AddHttpHeader("Authorization", cAuthHeader) 
        oWsdl:SendSoapMsg( cTXTEnvio )
        cRetSend := oWsdl:GetSoapResponse() 

        VA120025J_LogVk5({cTXTEnvio, cRetSend, jConfig})

        If !(upper("<Status>OK</Status>") $ upper(cRetSend)) // Verifica se deu erro
            cErrorWs := "GetSoapResponse Tp"+cTpCliVei+" - " + cRetSend
            if !lSchedule
                VA120029F_LogaExecucao(cOrigem, STR0011, cErrorWs, .t.) //STR0011 #"Erro"
                FMX_HELP("VA1200201", cErrorWs, STR0005) //STR0005 #"Problema com o serviço web:"
            else
                VA120029F_LogaExecucao(cOrigem, STR0011, cErrorWs, .t.) //STR0011 #"Erro"
            endif						
            Return .f.
        EndIf
    else
		if Empty(cTXTEnvio) 
			VA120029F_LogaExecucao(cOrigem, STR0011, STR0013, .t.) //STR0011 #"Erro" //STR0013 #"Arquivo XML vazio"
		endif
		if lConfigOff
			VA120029F_LogaExecucao(cOrigem, STR0011, STR0002+': '+'OFIA541', .t.) //STR0011 #"Erro" //STR0002 #"Entre na rotina de configuração SCRM e faça o cadastro dos dados web"
		endif
        Return .f.
    EndIf		
Return .t.

/*/{Protheus.doc} VA1200211_Excluir
Excluir os registros referente a uma determinada execucao
@author Andre Luis Almeida
@since 25/03/2019
@param cTpExec, caracter, Tipo de Execucao: 1 - Carga Inicial / 2 - Diario
@param cDtExec, caracter, Data da Execucao ( string - exemplo: 20190322 )
@param cHrExec, caracter, Hora da Execucao ( exemplo: 1537 )
@type function
/*/
Function VA1200211_Excluir( cTpExec , cDtExec , cHrExec )
	Local cQuery    := ""
	Local cQAlias   := 'SQLALIAS'
	Local nRecVEF   := 0
	Local cFileTemp := ""
	local oStatement := fwPreparedStatement():new()
	local cFixQuery := ''
	local cFilVEV := xFilial("VEV")
	local cFilVEF := xFilial("VEF")
	local oConfig := OfScaniaConfig():new("SCRM", "OFIA541")
    local jConfig := oConfig:getConfig()
	local cDirTXT := alltrim(jConfig["SCRM_FILE_PATH"])

	cQuery := "SELECT VEF.R_E_C_N_O_ AS RECVEF , VEV.R_E_C_N_O_ AS RECVEV"
	cQuery += "  FROM " + RetSqlName("VEF") + " VEF"
	cQuery += "  LEFT JOIN " + RetSqlName("VEV") + " VEV ON ( VEV.VEV_FILIAL= ? AND VEV.VEV_CODVEF=VEF.VEF_CODIGO AND VEV.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE VEF.VEF_FILIAL = ? "
	cQuery += "   AND VEF.VEF_TPEXEC = ? "
	cQuery += "   AND VEF.VEF_DTEXEC = ? "
	cQuery += "   AND VEF.VEF_HREXEC = ? "
	cQuery += "   AND VEF.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VEF.R_E_C_N_O_"

	oStatement:setQuery(cQuery)
	oStatement:setString(1, cFilVEV)
	oStatement:setString(2, cFilVEF)
	oStatement:setString(3, cTpExec)
	oStatement:setString(4, cDtExec)
	oStatement:setString(5, cHrExec)

	cFixQuery := oStatement:GetFixQuery()

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cFixQuery), cQAlias, .T., .T. )
	Do While (cQAlias)->(!Eof())
		If nRecVEF <> ( cQAlias )->( RECVEF )
			nRecVEF := ( cQAlias )->( RECVEF )
			DbSelectArea("VEF")
			DbGoTo( nRecVEF )
			// Excluir arquivo
			cFileTemp := cDirTXT+"/"+Alltrim(VEF->VEF_ARQUIV)
			If File(cFileTemp)
				Dele File &(cFileTemp)
			EndIf
			// Deletar registro VEF
			RecLock("VEF",.F.,.T.)
			VEF->(dbDelete())
			MsUnLock()
		EndIf
		If ( cQAlias )->( RECVEV ) > 0
			DbSelectArea("VEV")
			DbGoTo( ( cQAlias )->( RECVEV ) )
			// Excluir arquivo
			cFileTemp := cDirTXT+"/"+Alltrim(VEV->VEV_ARQUIV)
			If File(cFileTemp)
				Dele File &(cFileTemp)
			EndIf
			// Deletar registro VEV
			RecLock("VEV",.F.,.T.)
			VEV->(dbDelete())
			MsUnLock()
		EndIf
		( cQAlias )->(dbSkip())
	Enddo
	( cQAlias )->( dbCloseArea() )

	DbSelectArea("VEF")
Return

/*/{Protheus.doc} VA1200221_SOAP_Cabecalho
Cabecalho do SOAP
@author Andre Luis Almeida
@since 28/03/2019
@param cTpCliVei, caracter, Tipo: 1=Clientes / 2=Veiculos
@return cTXT, caracter, Layout do Cabecalho SOAP
@type function
/*/
Static Function VA1200221_SOAP_Cabecalho(cTpCliVei)
	Local cTXT     := ""
	local oConfig := OfScaniaConfig():new('SCRM', 'OFIA541')
	local jConfig := oConfig:getConfig()

	Local c_USERWS := alltrim(jConfig['SCRM_USER_WEBSERVICE'])
	Local c_PASSWS := alltrim(jConfig['SCRM_PSW_WEBSERVICE'])

	If cTpCliVei == "1" // Clientes
		cTXT += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.scania.com/account/schema/scrmmsgs/v1" xmlns:v11="http://xmlns.scania.com/account/schema/account/v1">'+PulaLinha
		cTXT += '<soapenv:Header>'+PulaLinha
		cTXT += '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+PulaLinha
		cTXT += '<wsse:UsernameToken wsu:Id="UsernameToken-1">'+PulaLinha
		cTXT += '<wsse:Username>'+c_USERWS+'</wsse:Username>'+PulaLinha
		cTXT += '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+c_PASSWS+'</wsse:Password>'+PulaLinha
		cTXT += '</wsse:UsernameToken>'+PulaLinha
		cTXT += '</wsse:Security>'+PulaLinha
		cTXT += '</soapenv:Header>'+PulaLinha
		cTXT += '<soapenv:Body>'+PulaLinha
		cTXT += '<v1:UpdateAccount>'+PulaLinha
	ElseIf cTpCliVei == "2" // Veiculos
		cTXT += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.scania.com/vehicle/schema/scrmmsgs/v1" xmlns:v11="http://xmlns.scania.com/vehicle/schema/vehicle/v1">'+PulaLinha
		cTXT += '<soapenv:Header>'+PulaLinha
		cTXT += '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+PulaLinha
		cTXT += '<wsse:UsernameToken wsu:Id="UsernameToken-1">'+PulaLinha
		cTXT += '<wsse:Username>'+c_USERWS+'</wsse:Username>'+PulaLinha
		cTXT += '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+c_PASSWS+'</wsse:Password>'+PulaLinha
		cTXT += '</wsse:UsernameToken>'+PulaLinha
		cTXT += '</wsse:Security>'+PulaLinha
		cTXT += '</soapenv:Header>'+PulaLinha
		cTXT += '<soapenv:Body>'+PulaLinha
		cTXT += '<v1:UpdateVehicle>'+PulaLinha
	EndIf
Return cTXT

/*/{Protheus.doc} VA1200231_SOAP_Rodape
Rodape do SOAP
@author Andre Luis Almeida
@since 28/03/2019
@param cTpCliVei, caracter, Tipo: 1=Clientes / 2=Veiculos
@return cTXT, caracter, Layout do Rodape SOAP
@type function

@ISSUE DVARMIL-10423
@DATE 26/09/2025
retirado o UpdateAccountRequest, pois no retorno da lista de Operaçoes no WS_Scania = UpdateAccount
/*/
Static Function VA1200231_SOAP_Rodape(cTpCliVei)
	Local cTXT := ""
	If cTpCliVei == "1" // Clientes
		cTXT += '</v1:UpdateAccount>'+PulaLinha
		cTXT += '</soapenv:Body>'+PulaLinha
		cTXT += '</soapenv:Envelope>'+PulaLinha
	ElseIf cTpCliVei == "2" // Veiculos
		cTXT += '</v1:UpdateVehicle>'+PulaLinha
		cTXT += '</soapenv:Body>'+PulaLinha
		cTXT += '</soapenv:Envelope>'+PulaLinha
	EndIf
Return cTXT

/*/{Protheus.doc} VA120025J_LogVk5
	Função de log na VK5
	Vai receber um array para montar os logs lá na VK5 com as configs que foram utilizadas + a resposta do servidor solicitado
	aLog[1] := Conteudo enviado para o serviço
	aLog[2] := Retorno recebido pelo servico
	aLog[3] := Configuração utilizada para o envio (realizada no OFIA541)
	@type  Static Function
	@author Renan Migliaris
	@since 13/11/2025
/*/
Static Function VA120025J_LogVk5(aLog)
	local lOk := .t.
	local oLogger := OFDMSRequest():new() 
	oLogger:set("VK5_ORIKEY", FunName())
	oLogger:set("VK5_REQBOD", aLog[1]) //arquivo enviado para o soap
	oLogger:set("VK5_RESBOD", aLog[2]) //resposta do soap
	oLogger:set("VK5_REQHEA", aLog[3]:toJson()) //configuracoes realizadas no OFIA541

	oLogger:save()
	freeObj(oLogger)
Return lOk

/*/{Protheus.doc} VA120026J_ExecPontoDeEntrada
	Quando chamada vai retornar a condição de busca lá na tabela temporária
	Ou seja, vou passar como argumento o alias da tabela que ele vai estar no momento "olhando"
	se tiver algo ele retornar uma parte da query pra jogar junto.
	Assim o cliente vai conseguir personalizar o monitoramento do SCRM de acordo com a necessidade dele.
	Vou olhar também o array do ponto de entrada aqui nesse método para saber se devo ou não concatenar algo..
	Caso vier vazio, vai retornar uma string vazia e vida que segue. 
	@type  Static Function
	@author Renan Migliaris
	@since 17/11/2025
	/*/
Static Function VA120026J_ExecPontoDeEntrada(cAlias, cTatTrig)
    local cQuery := ""
    local aGroups := {}
    local nX := 0
	local aConds := {}
	
    if ValType(aPe) <> "A" .or. Len(aPe) == 0
        return cQuery
    endif

    for nX := 1 to Len(aPe)
        if AllTrim(Upper(aPe[nX][1])) == AllTrim(Upper(cAlias))

            aConds := {}

            if len(aPe[nX][2][1]) > 0
				aAdd(aConds, cTatTrig + ".TTAT_FIELD " + VA120028J_RetSinalSql(aPe[nX][2][2]) + " '" + aPe[nX][2][1] + "'")
            endif

            if len(aPe[nX][3][1]) > 0
                aAdd(aConds, cTatTrig + ".TTAT_OPERATI " + VA120028J_RetSinalSql(aPe[nX][3][2]) + " '" + aPe[nX][3][1] + "'")
            endif

            if len(aPe[nX][4][1]) > 0
				aAdd(aConds, cTatTrig + ".TTAT_COLD  " + VA120028J_RetSinalSql(aPe[nX][4][2]) + " '" + aPe[nX][4][1] + "'")
            endif

            if len(aPe[nX][5][1]) > 0
                aAdd(aConds, cTatTrig + ".TTAT_CNEW  " + VA120028J_RetSinalSql(aPe[nX][5][2]) + " '" + aPe[nX][5][1] + "'")
            endif

            if len(aPe[nX][6][1]) > 0
                aAdd(aConds, cTatTrig + ".TTAT_PROGRAM  "+ VA120028J_RetSinalSql(aPe[nX][6][2]) + " '" + aPe[nX][6][1] + "'")
            endif

            if Len(aConds) > 0
                aAdd(aGroups, "( " + VA120027J_JoinString(aConds, " AND ") + " )")
            endif
        endif
    next

    if Len(aGroups) > 0
        cQuery += " AND ( " + VA120027J_JoinString(aGroups, " OR ") + " ) "
    endif

Return cQuery

/*/{Protheus.doc} VA120027J_JoinString
	Faz o join da string para concatenar na query
	@type  Static Function
	@author Renan Migliaris
	@since 17/11/2025
	/*/
Static Function VA120027J_JoinString(aList, cSep)
    local cRet := ""
    local nX

    for nX := 1 to Len(aList)
        cRet += aList[nX]
        if nX < Len(aList)
            cRet += cSep
        endif
    next

Return cRet


/*/{Protheus.doc} VA120028J_RetSinalSql
	Retorna o sinal do sql para a condição de acordo com o informado pelo usuário
	@type  Static Function
	@author Renan Migliaris
	@since 18/11/2025
	/*/
Static Function VA120028J_RetSinalSql(lIgual)
	local cSinal := ""

	if lIgual
		cSinal := " = " 
	else
		cSinal := " <> "
	endif
Return cSinal


/*/{Protheus.doc} SchedDef
	(long_description)
	@type  Function
	@author emanuel.furtado
	@since 28/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function SchedDef()
	Local aParam := {;
		"P",;
		cVEIA120,;
		"",;
		"",;
		"" ;
		}
Return aParam


/*/{Protheus.doc} VA120030F_ParametrosString
    Função que vai guardar os parâmetros que foram recebidos pela função para finalidade de log
    Os parâmetros serão guardados no formato json
    @type  Static Function
    @author Renan Migliaris
    @since 22/08/2025
/*/
Static Function VA120030F_ParametrosString(cMsgErro)
    local cParams := ''
    local oParams := JsonObject():new()
    local nX := 0
    local cMVName := ''
    local cMVValue := ''
    
    default cMsgErro := ''

    For nX := 1 To 99
        cMVName := 'MV_PAR' + StrZero(nX, 2)
        cMVValue := &(cMVName)
        
        If Empty(cMVValue) .And. nX > 4
            Exit
        EndIf
        
        oParams[cMVName] := cMVValue
    Next

    If !Empty(cMsgErro)
        oParams["MSG_ERRO"] := cMsgErro
    EndIf

    cParams := oParams:toJson()

    freeObj(oParams)
Return cParams

/*/{Protheus.doc} VA120029F_LogaExecucao()
    Realiza o log da operação. 
    @type  Static Function
    @author Renan Migliaris
    @since 21/08/2025
/*/
Static Function VA120029F_LogaExecucao(cOrigem, cTipo, cMensagem, lHorFin,cRotina)
    local aData := {}
    local oLogger := DMS_Logger():new()
    default lHorFin := .f.
	default cRotina := "VEIA120"

    
    aadd(adata, {"VQL_AGROUP", cRotina})
    aadd(adata, {"VQL_FILORI", cFilAnt})
    aadd(adata, {"VQL_TIPO", cTipo})
    aadd(adata, {"VQL_MSGLOG", cMensagem})
    aadd(adata, {"VQL_DADOS", cOrigem})
    if lHorFin
        aadd(aData, {"VQL_HORAF", VAL(STRTRAN(SUBSTR( TIME() , 1, 5), ":", "" ))})
        aadd(adata, {"VQL_DATAF", dDataBase})
    endif

    oLogger:LogToTable(aData)
Return

/*/{Protheus.doc} VA120031K_SiglaPaisISOAlpha2
	Função responsável por identificar e retornar a sigla do país 
	no padrão ISO Alpha-2 a partir da descrição informada, 
	realizando normalização de texto e desconsiderando variações de escrita e filial.
	@type  Static Function
	@author Lucas Oliveira
	@since 06/01/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function VA120031K_SiglaPaisISOAlpha2()

	Local cQuery 		:= ""
	Local aPaisESigla 	:= {}

	cQuery := " SELECT "
	cQuery += " 	CCH.CCH_PAIS, "
	cQuery += " 		SX5.X5_DESCRI, "
	cQuery += " 		SX5.X5_CHAVE "
	cQuery += " FROM "+RetSQLName("CCH")+" CCH "

	cQuery += " JOIN ( "
	cQuery += " 	SELECT DISTINCT "
	cQuery += " 		X5_CHAVE, "
	cQuery += " 		X5_DESCRI "
	cQuery += " 	FROM "+RetSQLName("SX5") "
	cQuery += " 	WHERE X5_TABELA = 'SW' "
	cQuery += " ) SX5 ON "

	cQuery += " TRIM( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 		UPPER( "
	cQuery += " 			TRANSLATE( "
	cQuery += " 				CCH.CCH_PAIS, "
	cQuery += " 				'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ', "
	cQuery += " 				'AAAAAEEEEIIIIOOOOOUUUUCN' ) ), "
	cQuery += " 	',', ' '), "
	cQuery += " 	'.', ' '), "
	cQuery += " 	'-', ' '), "
	cQuery += " 	'(', ' '), "
	cQuery += " 	')', ' ') "
	cQuery += " ) "
	cQuery += " = "
	cQuery += " TRIM( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 	REPLACE( "
	cQuery += " 		UPPER( "
	cQuery += " 			TRANSLATE( "
	cQuery += "                     SX5.X5_DESCRI, "
	cQuery += " 					'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ', "
	cQuery += "         			'AAAAAEEEEIIIIOOOOOUUUUCN') ), "
	cQuery += " 	',', ' '), "
	cQuery += " 	'.', ' '), "
	cQuery += "		'-', ' '), "
	cQuery += "		'(', ' '), "
	cQuery += "		')', ' ') "
	cQuery += " ) "
	
	If Select("TMPSIGPAIS") > 0
		TMPSIGPAIS->( DBCloseArea() )
	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSIGPAIS", .T., .T. )
	Do While TMPSIGPAIS->(!EOF())
		aAdd(aPaisESigla, { Alltrim(TMPSIGPAIS->CCH_PAIS), Alltrim(TMPSIGPAIS->X5_CHAVE) })
		TMPSIGPAIS->(DBSkip())
	Enddo

	If Select("TMPSIGPAIS") > 0
		TMPSIGPAIS->( DBCloseArea() )
	Endif

Return aPaisESigla