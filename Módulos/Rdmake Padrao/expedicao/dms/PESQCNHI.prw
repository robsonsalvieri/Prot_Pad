#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} PESQCNHI
Geração de planilha de pesquisa de satisfação
@type function
@version 1.0  
@author Rodrigo
@since 01/08/2025
/*/
User Function PESQCNHI()
    Local aArea     := FWGetArea() As Array
    Local aPergs    := {} As Array

    Local dDtIni    := FirstDate(Date()) As Date
    Local dDtFim    := LastDate(Date()) As Date

    Local cArquivo  := Space(50) As Char
    Local cGrpTec   := Space(FWTamSX3('VOS_CODGRU')[1]) As Char
    Local cCodServ  := Space(FWTamSX3('VO6_CODSER')[1]) As Char
    Local cGarPlan  := Space(FWTamSX3('VO4_DEPGAR')[1]) As Char
    Local cGarPoli  := Space(FWTamSX3('VO4_DEPGAR')[1]) As Char
    
    Local nFormato  := 1 As Numeric

    aAdd(aPergs, {1, 'Fechamento De',  dDtIni,  '', '.T.', '', '.T.', 80,  .T.})
    aAdd(aPergs, {1, 'Fechamento Até', dDtFim,  '', '.T.', '', '.T.', 80,  .T.})
    aAdd(aPergs, {1, 'Arquivo:', cArquivo, '', '.T.', '', '.T.', 120, .T.})
    aAdd(aPergs, {2, 'Formato', nFormato, {'','1=Excel XML', '2=Excel XLSX'}, 80, '.T.', .T.})
    aAdd(aPergs, {1, 'Grp. Serv. Entrega Técnica', cGrpTec, '', '.T.', 'VS4', '.T.', 80, .T.})
    aAdd(aPergs, {1, 'Cód. Serv. Entrega Técnica', cCodServ, '', '.T.','V6Q', '.T.', 80, .T.})
    aAdd(aPergs, {1, 'Dep. Gar. Plano de Manutenção', cGarPlan, '', '.T.', 'VF', '.T.', 80, .F.})
    aAdd(aPergs, {1, 'Dep. Gar. Policy', cGarPoli, '', '.T.', 'VF', '.T.', 80, .F.})

    IF ParamBox(aPergs, 'Informe os parâmetros', , , , , , , , , .F., .F.)
        Processa({|| GeraExcel()})
    EndIF

    FWRestArea(aArea)

    aSize(aArea, 0)
    aSize(aPergs, 0)
    
    aArea   := NIL
    aPergs  := NIL
Return

/*/{Protheus.doc} GeraExcel
Consulta dos dados e geração xml
@type function
@version 1.0  
@author Rodrigo
@since 01/08/2025
/*/
Static Function GeraExcel()
    Local oFWMsExcel    := NIL As Object
    Local oExcel        := NIL As Object
    Local oQuery        := NIL As Object

    Local cArquivo  := GetTempPath() + AllTrim(MV_PAR03)+'.xml' As Char
    Local cWorkSheet:= 'Pesquisa_Satisfacao' As Char
    Local cTitulo   := 'Pesquisa de Satisfação' As Char
    Local cQuery    := '' As Char
    Local cAlias    := '' As Char

    Local aBind     := {} As Array

    Local nI        := 0 As Numeric
    Local nAtuReg   := 0 As Numeric
    Local nTotalReg := 0 As Numeric

    cQuery  := " SELECT * " + CRLF
    cQuery  += " FROM " + CRLF
    cQuery  += " (SELECT VO1.VO1_FILIAL, " + CRLF
    cQuery  += "      VO1.VO1_NUMOSV, " + CRLF
    cQuery  += "      VO1.VO1_TPATEN, " + CRLF
    cQuery  += "      VO1.VO1_PROVEI, " + CRLF
    cQuery  += "      VO1.VO1_LOJPRO, " + CRLF
    cQuery  += "      VO1.VO1_DATABE, " + CRLF
    cQuery  += "      VO1.VO1_FUNABE, " + CRLF
    cQuery  += "      A3_NOME, " + CRLF    
    cQuery  += "      A3_DDDTEL, " + CRLF
    cQuery  += "      A3_TEL, " + CRLF
    cQuery  += "      A3_EMAIL, " + CRLF
    cQuery  += "      VAIVO4.VAI_NOMTEC AS NOMTEC, " + CRLF
    cQuery  += "      VAIVO4.VAI_CPF AS CPF, " + CRLF    
    cQuery  += "      VO1.VO1_HORABE, " + CRLF
    cQuery  += "      VO1.VO1_CHASSI, " + CRLF
    cQuery  += "      VO1.R_E_C_N_O_ RECVO1, " + CRLF
    cQuery  += "      COUNT(VO2.VO2_NOSNUM) COUNTVO2, " + CRLF
    cQuery  += "      SA1.A1_NOME, " + CRLF
    cQuery  += "      SA1.A1_TEL, " + CRLF
    cQuery  += "      SA1.A1_END, " + CRLF
    cQuery  += "      SA1.A1_CGC, " + CRLF
    cQuery  += "      SA1.A1_PESSOA, " + CRLF
    cQuery  += "      SA1.R_E_C_N_O_ RECSA1, " + CRLF
    cQuery  += "      VV1.VV1_CODMAR, " + CRLF
    cQuery  += "      VV1.VV1_MODVEI, " + CRLF
    cQuery  += "      VV1.VV1_CHAINT, " + CRLF
    cQuery  += "      VV1.VV1_FABMOD, " + CRLF
    cQuery  += "      VV1.VV1_CHASSI, " + CRLF
    cQuery  += "      VV1.VV1_PROATU, " + CRLF
    cQuery  += "      VV1.VV1_LJPATU, " + CRLF
    cQuery  += "      VV1.R_E_C_N_O_ RECVV1, " + CRLF
    cQuery  += "      VV2.VV2_DESMOD, " + CRLF
    cQuery  += "      VV2.VV2_TIPVEI, " + CRLF
    cQuery  += "      VV2.R_E_C_N_O_ RECVV2, " + CRLF
    cQuery  += "      VO1.VO1_DATSTA, " + CRLF
    cQuery  += "      VO1.VO1_STATUS, " + CRLF
    cQuery  += "      VO4_CODSER, " + CRLF
    cQuery  += "      VO6_DESSER, " + CRLF
    cQuery  += "      VOI_SITTPO, " + CRLF
    cQuery  += "      VO4_DEPGAR, " + CRLF
    cQuery  += "      VO4_DATFEC "+ CRLF
    cQuery  += " FROM ? VO1 " + CRLF
    cQuery  += " LEFT JOIN ? SA1 ON SA1.A1_FILIAL = ? " + CRLF
    cQuery  += " AND SA1.A1_COD = VO1.VO1_PROVEI " + CRLF
    cQuery  += " AND SA1.A1_LOJA = VO1.VO1_LOJPRO " + CRLF
    cQuery  += " AND SA1.D_E_L_E_T_ = ? " + CRLF
    cQuery  += " LEFT JOIN ? VV1 ON VV1.VV1_FILIAL = ? " + CRLF
    cQuery  += " AND VV1.VV1_CHAINT = VO1.VO1_CHAINT " + CRLF
    cQuery  += " AND VV1.D_E_L_E_T_ = ? " + CRLF
    cQuery  += " LEFT JOIN ? VV2 ON VV2.VV2_FILIAL = ? " + CRLF
    cQuery  += " AND VV2.VV2_CODMAR = VV1.VV1_CODMAR " + CRLF
    cQuery  += " AND VV2.VV2_MODVEI = VV1.VV1_MODVEI " + CRLF
    cQuery  += " AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD " + CRLF
    cQuery  += " AND VV2.D_E_L_E_T_ = ? " + CRLF
    cQuery  += " JOIN ? VO2 ON VO2.VO2_FILIAL =  ? " + CRLF
    cQuery  += " AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV " + CRLF
    cQuery  += " AND VO2.D_E_L_E_T_ = ? " + CRLF
    cQuery  += " LEFT JOIN ? VO4 ON VO4.VO4_FILIAL = ? " + CRLF
    cQuery  += " AND VO2.VO2_TIPREQ = ? " + CRLF
    cQuery  += " AND VO4.VO4_NOSNUM = VO2.VO2_NOSNUM " + CRLF
    cQuery  += " AND VO4.D_E_L_E_T_ = ? " + CRLF 
    cQuery  += " LEFT JOIN ? VO6 ON VO6_FILIAL = ? " + CRLF 
    cQuery  += " AND VO6_CODSER = VO4_CODSER " + CRLF 
    cQuery  += " AND VO6.D_E_L_E_T_ = ? " + CRLF 
    cQuery  += " LEFT JOIN ? VAIVO1 ON VAIVO1.VAI_FILIAL = ? " + CRLF 
    cQuery  += " AND VAIVO1.VAI_CODTEC = VO1_FUNABE " + CRLF 
    cQuery  += " AND VAIVO1.D_E_L_E_T_ = ? " + CRLF 
    cQuery  += " LEFT JOIN ? VAIVO4 ON VAIVO4.VAI_FILIAL = ? " + CRLF 
    cQuery  += " AND VAIVO4.VAI_CODTEC = VO4_CODPRO " + CRLF 
    cQuery  += " AND VAIVO4.D_E_L_E_T_ = ? " + CRLF 
    cQuery  += " LEFT JOIN ? SA3VO1 ON SA3VO1.A3_FILIAL = ? " + CRLF 
    cQuery  += " AND SA3VO1.A3_COD = VAIVO1.VAI_CODVEN " + CRLF 
    cQuery  += " AND SA3VO1.D_E_L_E_T_ = ? " + CRLF 
    cQuery  += " LEFT JOIN ? VOI ON VOI_FILIAL = ? " + CRLF 
    cQuery  += " AND VOI_TIPTEM = VO4_TIPTEM " + CRLF 
    cQuery  += " AND VOI.D_E_L_E_T_ = ? " + CRLF 
    cQuery  += " WHERE VO1.VO1_FILIAL = ? " + CRLF 
    cQuery  += " AND VO1.D_E_L_E_T_ = ? " + CRLF 
    cQuery  += " AND (((VO2.VO2_TIPREQ = ? " + CRLF 
    cQuery  += " AND VO4.VO4_DATDIS <> ? " + CRLF 
    cQuery  += " AND VO4.VO4_DATFEC <> ? " + CRLF 
    cQuery  += " AND VO4.VO4_DATCAN = ? " + CRLF 
    cQuery  += " AND VO4.VO4_DATFEC >= ? " + CRLF 
    cQuery  += " AND VO4.VO4_DATFEC <= ? " + CRLF
    cQuery  += " ))) " + CRLF 
    cQuery  += " GROUP BY VO1.VO1_FILIAL, " + CRLF 
    cQuery  += " VO1.VO1_NUMOSV, " + CRLF
    cQuery  += " VO1.VO1_TPATEN, " + CRLF
    cQuery  += " VO1.VO1_PROVEI, " + CRLF
    cQuery  += " VO1.VO1_LOJPRO, " + CRLF
    cQuery  += " VO1.VO1_DATABE, " + CRLF
    cQuery  += " VO1.VO1_FUNABE, " + CRLF
    cQuery  += " A3_NOME, " + CRLF    
    cQuery  += " A3_DDDTEL, " + CRLF
    cQuery  += " A3_TEL, " + CRLF
    cQuery  += " A3_EMAIL, " + CRLF
    cQuery  += " VAIVO4.VAI_NOMTEC, " + CRLF
    cQuery  += " VAIVO4.VAI_CPF, " + CRLF    
    cQuery  += " VO1.VO1_HORABE, " + CRLF
    cQuery  += " VO1.VO1_CHASSI, " + CRLF
    cQuery  += " VO1.R_E_C_N_O_, " + CRLF
    cQuery  += " SA1.A1_NOME, " + CRLF
    cQuery  += " SA1.A1_TEL, " + CRLF
    cQuery  += " SA1.A1_END, " + CRLF
    cQuery  += " SA1.A1_CGC, " + CRLF
    cQuery  += " SA1.A1_PESSOA, " + CRLF
    cQuery  += " SA1.R_E_C_N_O_, " + CRLF
    cQuery  += " VV1.VV1_CODMAR, " + CRLF
    cQuery  += " VV1.VV1_MODVEI, " + CRLF
    cQuery  += " VV1.VV1_CHAINT, " + CRLF
    cQuery  += " VV1.VV1_FABMOD, " + CRLF
    cQuery  += " VV1.VV1_CHASSI, " + CRLF
    cQuery  += " VV1.VV1_PROATU, " + CRLF
    cQuery  += " VV1.VV1_LJPATU, " + CRLF
    cQuery  += " VV1.R_E_C_N_O_, " + CRLF
    cQuery  += " VV2.VV2_DESMOD, " + CRLF
    cQuery  += " VV2.VV2_TIPVEI, " + CRLF
    cQuery  += " VV2.R_E_C_N_O_, " + CRLF
    cQuery  += " VO1.VO1_DATSTA, " + CRLF
    cQuery  += " VO1.VO1_STATUS, " + CRLF
    cQuery  += " VO4_CODSER, " + CRLF
    cQuery  += " VO6_DESSER, " + CRLF
    cQuery  += " VOI_SITTPO, " + CRLF
    cQuery  += " VO4_DEPGAR, " + CRLF
    cQuery  += " VO4_DATFEC) TMP " + CRLF 
    cQuery  += " ORDER BY TMP.VO1_NUMOSV "
    
    oQuery := FWExecStatement():New(ChangeQuery(cQuery))

    aAdd(aBind, {'U', RetSqlName('VO1')})
    aAdd(aBind, {'U', RetSqlName('SA1')})
    aAdd(aBind, {'C', FWxFilial('SA1')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VV1')})
    aAdd(aBind, {'C', FWxFilial('VV1')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VV2')})
    aAdd(aBind, {'C', FWxFilial('VV2')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VO2')})
    aAdd(aBind, {'C', FWxFilial('VO2')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VO4')})
    aAdd(aBind, {'C', FWxFilial('VO4')})
    aAdd(aBind, {'C', 'S'})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VO6')})
    aAdd(aBind, {'C', FWxFilial('VO6')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VAI')})
    aAdd(aBind, {'C', FWxFilial('VAI')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VAI')})
    aAdd(aBind, {'C', FWxFilial('VAI')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('SA3')})
    aAdd(aBind, {'C', FWxFilial('SA3')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'U', RetSqlName('VOI')})
    aAdd(aBind, {'C', FWxFilial('VOI')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'C', FWxFilial('VO1')})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'C', 'S'})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'C', ' '})
    aAdd(aBind, {'C', DTOS(MV_PAR01)})
    aAdd(aBind, {'C', DTOS(MV_PAR02)})    

    For nI := 1 To Len(aBind)
	    IF aBind[nI][1] == 'U'
		    oQuery:SetUnsafe(nI, aBind[nI][2])
		ELSEIF aBind[nI][1] == 'C'
			oQuery:SetString(nI, aBind[nI][2])
		ELSEIF aBind[nI][1] == 'D'
			oQuery:SetDate(nI, aBind[nI][2])
		ELSEIF aBind[nI][1] == 'A'
			oQuery:SetIn( nI, aBind[nI][2])
		EndIF
	Next    

    cQuery := oQuery:GetFixQuery()
    cAlias:= MPSysOpenQuery(cQuery)

    IF cValToChar(MV_PAR04) == '1'
        oFWMsExcel := FWMSExcel():New()
        /*
        utiliza o utilitario printer
        obrigatoriamente precisa estar atualizado no binario appserver/smartclient
        */
    ELSE
        oFWMsExcel := FWMSExcelXLSX():New()
    EndIF

    oFWMsExcel:AddWorkSheet(cWorkSheet)

    oFWMsExcel:AddTable(cWorkSheet, cTitulo)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Entrega Técnica (SIM ou NÃO)', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'CNPJ ou CPF do Proprietário', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Razão Social ou Nome do Proprietário', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Nome do Recebedor', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'DDD1', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Telefone1', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'E-mail', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Nº Chassis (Completo)', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Modelo / Versão', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Produto', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Resumo do Serviço', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Tipo de OS (Garantia, Clientes, Interna, Planos de Manutenção e Policy)', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Aluguel? (SIM ou NÃO)', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Nº da Ordem de Serviço', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'CPF do Técnico Responsável', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Nome do Técnico Responsável', 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, 'Data de Fechamento da OS', 1, 1, .F.)

    COUNT TO nTotalReg
    ProcRegua(nTotalReg)

    While !(cAlias)->(EOF())
        nAtuReg ++
        IncProc('Adicionando registro ' + cValToChar(nAtuReg) + ' de ' + cValToChar(nTotalReg) + '...')

        oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
        IIF(AllTrim((cAlias)->VO4_CODSER)==AllTrim(MV_PAR06),'SIM','NÃO'),;
        AllTrim((cAlias)->A1_CGC),;
        AllTrim(Upper((cAlias)->A1_NOME)),;
        AllTrim((cAlias)->A3_NOME),;
        AllTrim((cAlias)->A3_DDDTEL),;
        AllTrim((cAlias)->A3_TEL),;
        AllTrim((cAlias)->A3_EMAIL),;
        AllTrim((cAlias)->VO1_CHASSI),;
        AllTrim((cAlias)->VV1_MODVEI),;
        AllTrim((cAlias)->VV1_MODVEI),;
        AllTrim((cAlias)->VO6_DESSER),;
        RetGarantia((cAlias)->VOI_SITTPO, (cAlias)->VO4_DEPGAR),;
        'NÃO',;
        AllTrim((cAlias)->VO1_NUMOSV),;
        AllTrim((cAlias)->CPF),;
        AllTrim((cAlias)->NOMTEC),;
        STOD((cAlias)->VO4_DATFEC);
        })
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
     
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cArquivo)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    FWFreeObj(oQuery)
    FWFreeObj(oFWMsExcel)

    aSize(aBind,0)

    aBind := NIL
Return

/*/{Protheus.doc} RetGarantia
Retornar a garantia com base na regra definida pelo layout
@type function
@version 1.0  
@author Rodrigo
@since 01/08/2025
@param cKeyVOI, character, codigo da VOI
@param cKeyVO4, character, codigo da VO4
@return character, garantia
/*/
Static Function RetGarantia(cKeyVOI As Char, cKeyVO4 As Char) As Char
    Local cDescric As Char
    IF cKeyVOI == '1'
        cDescric := 'CLIENTE'
    ELSEIF cKeyVOI == '3'    
        cDescric := 'INTERNA'
    ELSEIF cKeyVOI == '2' .AND. (cKeyVO4 == AllTrim(MV_PAR07))
        cDescric := 'PLANO DE MANUTENÇÃO'
    ELSEIF cKeyVOI == '2' .AND. (cKeyVO4 == AllTrim(MV_PAR08))
        cDescric := 'POLICY'
    ELSEIF cKeyVOI == '2'
        cDescric := 'GARANTIA'
    EndIF
Return cDescric
