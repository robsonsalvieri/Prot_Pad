#include 'protheus.ch'
#include 'OGI250B.CH'

/*/{Protheus.doc} OGI250B
Função de Integração do status do fardo e NF dos fardos com o Totvs Agro Beneficiamento
@type function
@version P12
@author claudineia.reinert
@since 15/04/2024
/*/
Function OGI250B()
    
    If .not. TableInDic('ND7')  //proteção fonte
        conout("-------------------------------------------------")
        conout("[SIGAAGR] - API OGI250B : ")
        conout(STR0001) //###"É necessário a atualização do sistema para a expedição mais recente!"
        conout("-------------------------------------------------")
		Return 
	EndIf

    If !isBlind()
        MsgRun(STR0002 + ' - ' + STR0003, STR0004 , {|| fProc() } ) //## "Integrando NF ## Protheus -> Beneficiamento Externo" ## "Processando..."
        
    Else
        fProc()
    EndIf

Return

/*/{Protheus.doc} SchedDef
Definição de função padrão para o Schedule
@type function
@version P12
@author claudineia.reinert
@since 15/04/2024
/*/
Static Function SchedDef()
	Local aOrd := {}
	Local aParam := {}

	aParam := {	"P"     ,;   // P= Processo, R= Relatório
				""      ,;   //PERGUNTE OU PARAMDEF
				""      ,;   //ALIAS p/ relatorio
				aOrd    ,;   //Array de Ordenacao p/ relatorio
				""      ;	 //Titulo para Relatório
			}
Return aParam

/*/{Protheus.doc} fProc
Função responsavel por chamar a geração do token de integração e processar as integraçãos se o token for gerado
@type function
@version P12
@author claudineia.reinert
@since 15/04/2024
/*/
Static Function fProc()
    Local oToken    := Nil
    Local lTokenOK    := .F.

    lTokenOK := fTokenBen(@oToken)

    If lTokenOK
        If fFrdNFCancel(oToken) //se não tiver dados ou ocorrer a integração, retornará .T. e segue condições abaixo
            If fFrdReserCanc(oToken) //se não tiver dados ou ocorrer a integração, retornará .T. e segue condições abaixo
                If fFrdReservado(oToken) //se não tiver dados ou ocorrer a integração, retornará .T. e segue condições abaixo
                    fFrdNFEntreg(oToken)
                EndIf
            EndIf
        EndIf
    Else
        If !isBlind()
            AGRHelp(STR0002, STR0005 + oToken:access_error, STR0006) //##"Integração NF" ##"Erro na geração do token para a integração!" ##"Verifique as configurações de integração."
        EndIf
        conout("-------------------------------------------------")
        conout("[SIGAAGR] - API OGI250B : ")
        conout(STR0002 + ' - ' + STR0005 + ' - ' + oToken:access_error, STR0006) //#"Integrando NF"#"Erro na geração do token para a integração!"#"Verifique as configurações de integração."
        conout("-------------------------------------------------")

    EndIf

Return 

/*/{Protheus.doc} fFrdReservado
Função responsavel por gerar os dados e enviar a integração dos Fardos com Status RESERVADO
@type function
@version P12
@author claudineia.reinert
@since 19/04/2024
@param oToken, object, Objeto com os dados do token para integração
@return Logical, retorna .F. se ocorreu algum erro com desvio, senão retorna .T. 
/*/
Static Function fFrdReservado(oToken)
    Local lRet      := .T.
    Local oJsonEnv  := nil
    Local cQry      := ""
    Local cAliasQry := GetNextAlias()
    Local cEndPoint := "/v1/blocagens/reservar"
    
    //Busca os fardos que estão vinculados a uma reserva aprovada para um contrato
    cQry := " SELECT N9D.N9D_DATA N9D_DATA, "
    cQry +=     " N9D.N9D_CODRES RESERVA, "
    cQry +=     " N9D.N9D_SAFRA SAFRA,"
    cQry +=     " DXI_ETIQ ETIQUETA, " 
    cQry +=     " DXI_STATUS, "
    cQry +=     " DXI_BLOCO, "
    cQry +=     " N9D.R_E_C_N_O_ AS N9D_RECNO  "
    cQry += " FROM " + RetSqlName("DXI") + " DXI "
    cQry += " INNER JOIN " + RetSqlName("DXQ") + " DXQ ON DXQ.D_E_L_E_T_ = '' "
    cQry +=     " AND DXQ.DXQ_FILIAL = '"+FWxFilial("DXQ")+"' "
    cQry +=     " AND DXQ.DXQ_FILORG = DXI.DXI_FILIAL "
    cQry +=     " AND DXQ.DXQ_CODRES = DXI.DXI_CODRES "
    cQry +=     " AND DXQ.DXQ_ITEM = DXI.DXI_ITERES "
    cQry +=     " AND DXQ.DXQ_BLOCO = DXI.DXI_BLOCO "
    cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D ON N9D.D_E_L_E_T_ = '' "
    cQry +=     " AND N9D.N9D_FILIAL = DXI.DXI_FILIAL "
    cQry +=     " AND N9D.N9D_SAFRA = DXI.DXI_SAFRA "
    cQry +=     " AND N9D_FARDO = DXI_ETIQ "
    cQry +=     " AND N9D.N9D_CODRES = DXI.DXI_CODRES "
    cQry +=     " AND N9D.N9D_TIPMOV = '02' "
    cQry +=     " AND (N9D.N9D_INTEGR = '' OR N9D.N9D_INTEGR = '1') "
    cQry +=     " AND N9D.N9D_STATUS <> '3' "
    cQry += " WHERE DXI.D_E_L_E_T_ = '' "
    cQry +=     " AND DXI.DXI_FILIAL = '"+FWxFilial("DXI")+"' "
    cQry +=     " AND DXI_CODRES <> '' "
    cQry += " ORDER BY N9D.N9D_DATA, N9D.N9D_CODRES, N9D.N9D_FARDO "
    cQry := ChangeQuery( cQry ) 
    dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
    
    While (cAliasQRY)->( !EoF() )
        oJsonEnv := JsonObject():New()
		oJsonEnv['safraERP']    := AllTrim( (cAliasQRY)->SAFRA )
		oJsonEnv['etiqueta']    := AllTrim( (cAliasQRY)->ETIQUETA )
		oJsonEnv['numeroNF']    := ""
		oJsonEnv['serie']       := ""
		oJsonEnv['dataEmissao'] := FWTimeStamp(3,STOD(AllTrim( (cAliasQRY)->N9D_DATA )) )
		oJsonEnv['cnpjEmissao'] := ""

        If !(fProcEnvInt(oJsonEnv, oToken, cEndPoint, cAliasQRY))
            lRet := .F.
            Exit //ocorreu erro de exceção, parar/finalizar execução
        EndIF   
        		
        (cAliasQRY)->( dbSkip() )
    EndDo
    (cAliasQry)->( dbCloseArea() )
    
Return lRet

/*/{Protheus.doc} fFrdResCanc
Função responsavel por gerar os dados dos fardos que tiveram a reserva cancelada e não estão mais reservados, e enviar a integração destes fardos com o status EMBLOCADO
@type function
@version P12
@author claudineia.reinert
@since 22/04/2024
@param oToken, object, Objeto com os dados do token para integração
@return Logical, retorna .F. se ocorreu algum erro com desvio, senão retorna .T. 
/*/
Static Function fFrdReserCanc(oToken)
    Local lRet      := .T.
    Local oJsonEnv  := nil
    Local cQry      := ""
    Local cAliasQry := GetNextAlias()
    Local cEndPoint := "/v1/blocagens/reserva/cancelar"
    
    //Busca os fardos que foram retirados de uma reserva(N9D_TIPMOV='02' E N9D_STATUS='3') 
    //// e não estão vinculados a neNhuma outra reserva aprovada(DXI_STATUS < 70)
    //OBS: atualmente, somente quando take-up é aprovado é gerado a N9D, com a N9D_TIPMOV=2(reservado) 
    //// e o status da DXI é alterado para DXI_STATUS=70
    cQry := " SELECT N9D.N9D_DATA N9D_DATA, "
    cQry +=     " N9D.N9D_CODRES RESERVA, "
    cQry +=     " N9D.N9D_SAFRA SAFRA, "
    cQry +=     " N9D.N9D_FARDO ETIQUETA, "
    cQry +=     " DXI_STATUS, "
    cQry +=     " DXI_BLOCO, "
	cQry +=     " DXI_CODRES, "
    cQry +=     " N9D.R_E_C_N_O_ AS N9D_RECNO "
    cQry += " FROM " + RetSqlName("DXI") + " DXI "
    cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D ON N9D.D_E_L_E_T_ = ' ' "
    cQry +=     " AND N9D.N9D_FILIAL = DXI.DXI_FILIAL "
    cQry +=     " AND N9D.N9D_SAFRA = DXI.DXI_SAFRA "
    cQry +=     " AND N9D_FARDO = DXI_ETIQ "
    cQry +=     " AND N9D.N9D_CODRES <> '' "
    cQry +=     " AND N9D.N9D_TIPMOV = '02' "
    cQry +=     " AND (N9D.N9D_INTEGR = ' ' OR N9D.N9D_INTEGR = '1') "
    cQry +=     " AND N9D.N9D_STATUS = '3' "
    cQry += " WHERE DXI.D_E_L_E_T_ = ' '  "
    cQry +=     " AND DXI.DXI_FILIAL = '"+FWxFilial("DXI")+"'  "
    cQry +=     " AND (DXI_CODRES = '' OR DXI_STATUS IN ('30','40','50','60'))  " 
    cQry += " ORDER BY N9D.N9D_DATA, N9D.N9D_CODRES, N9D.N9D_FARDO "
    cQry := ChangeQuery( cQry ) 
    dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
    
    While (cAliasQRY)->( !EoF() )
        oJsonEnv := JsonObject():New()
		oJsonEnv['safraERP']    := AllTrim( (cAliasQRY)->SAFRA )
		oJsonEnv['etiqueta']    := AllTrim( (cAliasQRY)->ETIQUETA )
		oJsonEnv['numeroNF']    := ""
		oJsonEnv['serie']       := ""
		oJsonEnv['dataEmissao'] := FWTimeStamp(3,STOD(AllTrim( (cAliasQRY)->N9D_DATA )) )
		oJsonEnv['cnpjEmissao'] := ""

        If !(fProcEnvInt(oJsonEnv, oToken, cEndPoint, cAliasQRY))
            lRet := .F.
            Exit //ocorreu erro de exceção, parar/finalizar execução
        EndIF   
        		
        (cAliasQRY)->( dbSkip() )
    EndDo
    (cAliasQry)->( dbCloseArea() )
    
Return lRet

/*/{Protheus.doc} fFrdNFCancel
Função responsavel por gerar os dados dos fardos que tiveram a NF cancelada e não estão mais faturados, e enviar a integração destes fardos com o status RESERVADO 
@type function
@version P12
@author claudineia.reinert
@since 22/04/2024
@param oToken, object, objeto com os dados do token de integração
@return Logical, retorna .F. se ocorreu algum erro com desvio, senão retorna .T. 
/*/
Static Function fFrdNFCancel(oToken)
    Local lRet      := .T.
    Local oJsonEnv  := nil
    Local cQry      := ""
    Local cAliasQry := GetNextAlias()
    Local cEndPoint := "/v1/blocagens/notaFiscal/cancelar"
    
    cQry := " SELECT N9D.N9D_DATA, "
    cQry += " N9D.N9D_CODRES RESERVA, "
    cQry += " N9D.N9D_SAFRA SAFRA, "
    cQry += " DXI_ETIQ ETIQUETA, "
    cQry += " DXI_STATUS, "
    cQry += " DXI_BLOCO, "
    cQry += " DXI_CODRES, "
    cQry += " N9D.R_E_C_N_O_ AS N9D_RECNO "
    cQry += " FROM " + RetSqlName("DXI") + " DXI "
    cQry += " INNER JOIN " + RetSqlName("N9D") + " N9D ON N9D.D_E_L_E_T_ = ' ' "
    cQry += " AND N9D.N9D_FILIAL = DXI.DXI_FILIAL "
    cQry += " AND N9D.N9D_SAFRA = DXI.DXI_SAFRA "
    cQry += " AND N9D_FARDO = DXI_ETIQ "
    cQry += " AND N9D.N9D_CODRES = DXI_CODRES "
    cQry += " AND N9D.N9D_TIPMOV = '07' "
    cQry += " AND (N9D.N9D_INTEGR = ' ' OR N9D.N9D_INTEGR = '1') "
    cQry += " AND N9D.N9D_STATUS = '3' "
    cQry += " WHERE DXI.D_E_L_E_T_ = ' ' "
    cQry += " AND DXI.DXI_FILIAL = '"+FWxFilial("DXI")+"' "
    cQry += " AND DXI_STATUS  NOT IN ('170','180') "
    cQry += " ORDER BY N9D.N9D_DATA, "
    cQry += " N9D.N9D_CODRES, "
    cQry += " N9D.N9D_FARDO "
    cQry := ChangeQuery( cQry ) 
    dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
    
    While (cAliasQRY)->( !EoF() )
        oJsonEnv := JsonObject():New()
		oJsonEnv['safraERP']    := AllTrim( (cAliasQRY)->SAFRA )
		oJsonEnv['etiqueta']    := AllTrim( (cAliasQRY)->ETIQUETA )
		oJsonEnv['numeroNF']    := ""
		oJsonEnv['serie']       := ""
		oJsonEnv['dataEmissao'] := FWTimeStamp(3,STOD(AllTrim( (cAliasQRY)->N9D_DATA )) )
		oJsonEnv['cnpjEmissao'] := ""

        If !(fProcEnvInt(oJsonEnv, oToken, cEndPoint, cAliasQRY))
            lRet := .F.
            Exit //ocorreu erro de exceção, parar/finalizar execução
        EndIF       
        	
        (cAliasQRY)->( dbSkip() )
    EndDo
    (cAliasQry)->( dbCloseArea() )
    
Return lRet

/*/{Protheus.doc} fFrdNFEntreg
Função que busca os dados de NF para integração, chama a função responsavel para envio da integração e grava o retorno da integração na tabela N9D.
@type function
@version P12
@author claudineia.reinert
@since 15/04/2024
@param oToken, object, objeto com os dados do token de integração
@return Logical, retorna .F. se ocorreu algum erro com desvio, senão retorna .T. 
/*/
Static Function fFrdNFEntreg(oToken)
    Local lRet      := .T.
    Local oJsonEnv  := nil
    Local cQry      := ""
    Local cAliasQry := GetNextAlias()
    Local cEndPoint := "/v1/blocagens/notaFiscal"
    
    cQry := " SELECT DXI_ETIQ ETIQUETA, "
    cQry += " DXI_SAFRA SAFRA, "
    cQry += " SF2.F2_DOC NF_NUM, "
    cQry += " SF2.F2_SERIE NF_SERIE, "
    cQry += " SF2.F2_EMISSAO NF_EMISSAO, "
    cQry += " SF2.F2_HORA NF_HORAEMISSAO, "
    cQry += " SA1.A1_CGC NF_CNPJ, "
    cQry += " N9D.R_E_C_N_O_ AS N9D_RECNO "
    cQry += " FROM " + RetSqlName("N9D") + " N9D "
    cQry += " INNER JOIN " + RetSqlName("DXI") + " DXI ON DXI.D_E_L_E_T_ = '' "    
    cQry +=     " AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
    cQry +=     " AND DXI.DXI_SAFRA = N9D_SAFRA "
    cQry +=     " AND DXI.DXI_ETIQ = N9D_FARDO "
    cQry +=     " AND DXI.DXI_STATUS='170' "
    cQry += " INNER JOIN " + RetSqlName("NJM") + " NJM ON NJM.D_E_L_E_T_ = '' "
    cQry +=     " AND NJM.NJM_FILIAL = N9D.N9D_FILORG "
    cQry +=     " AND NJM.NJM_CODROM = N9D.N9D_CODROM "
    cQry +=     " AND NJM.NJM_CODSAF = N9D.N9D_SAFRA "
    cQry +=     " AND NJM.NJM_CODCTR = N9D.N9D_CODCTR "
    cQry +=     " AND NJM.NJM_ITEM = N9D.N9D_ITEETG "
    cQry +=     " AND NJM.NJM_SEQPRI = N9D.N9D_ITEREF "
    cQry += " INNER JOIN " + RetSqlName("NJJ") + " NJJ ON NJJ.D_E_L_E_T_ = '' "
    cQry +=     " AND NJJ.NJJ_FILIAL = NJM.NJM_FILIAL "
    cQry +=     " AND NJJ.NJJ_CODROM = NJM.NJM_CODROM "
    cQry +=     " AND NJJ.NJJ_CODSAF = NJM.NJM_CODSAF "
    cQry +=     " AND NJJ.NJJ_TIPO   = '4' " //VENDA
    cQry += " INNER JOIN " + RetSqlName("N9A") + " N9A ON N9A.D_E_L_E_T_ = '' "
    cQry +=     " AND N9A.N9A_FILIAL = NJM.NJM_FILORG "
    cQry +=     " AND N9A.N9A_CODCTR = NJM.NJM_CODCTR "
    cQry +=     " AND N9A.N9A_ITEM = NJM.NJM_ITEM "
    cQry +=     " AND N9A.N9A_SEQPRI = NJM.NJM_SEQPRI "
    cQry +=     " AND N9A.N9A_FILORG = NJM.NJM_FILIAL "
    cQry +=     " AND N9A.N9A_TAKEUP = N9D.N9D_CODRES "
    cQry += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D_E_L_E_T_ = '' "
    cQry +=     " AND SD2.D2_FILIAL = NJM.NJM_FILIAL "
    cQry +=     " AND SD2.D2_DOC = NJM.NJM_DOCNUM "
    cQry +=     " AND SD2.D2_SERIE = NJM.NJM_DOCSER "
    cQry +=     " AND SD2.D2_COD = NJM.NJM_CODPRO "
    cQry +=     " AND SD2.D2_LOCAL = NJM.NJM_LOCAL "
    cQry +=     " AND SD2.D2_LOTECTL = DXI.DXI_LOTE "
    cQry += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON SF2.D_E_L_E_T_ = '' "
    cQry +=     " AND SF2.F2_FILIAL = SD2.D2_FILIAL "
    cQry +=     " AND SF2.F2_DOC = SD2.D2_DOC "
    cQry +=     " AND SF2.F2_SERIE = SD2.D2_SERIE "
    cQry +=     " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
    cQry +=     " AND SF2.F2_LOJA = SD2.D2_LOJA "
    cQry +=     " AND SF2.F2_EMISSAO = SD2.D2_EMISSAO "
    cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = '' "
    cQry +=     " AND SA1.A1_FILIAL = '"+FWxFilial("SA1",cFilAnt)+"' "
    cQry +=     " AND SA1.A1_COD = SD2.D2_CLIENTE "
    cQry +=     " AND SA1.A1_LOJA = SD2.D2_LOJA "
    cQry += " WHERE N9D.D_E_L_E_T_ = '' "
    cQry +=     " AND N9D.N9D_FILIAL = '"+FWxFilial("N9D")+"' "
    cQry +=     " AND N9D_TIPMOV = '07' "
    cQry +=     " AND N9D_STATUS='2' "
    cQry +=     " AND N9D_INTEGR <> '2' "
    cQry += " GROUP BY DXI_ETIQ, DXI.DXI_SAFRA, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_HORA, SA1.A1_CGC, N9D.R_E_C_N_O_,N9D_INTEGR,N9D_INTERR  "
    cQry += " ORDER BY SF2.F2_EMISSAO, SF2.F2_HORA, SF2.F2_DOC, SF2.F2_SERIE, DXI.DXI_ETIQ "
    cQry := ChangeQuery( cQry ) 
    dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
    
    While (cAliasQRY)->( !EoF() )
        oJsonEnv := JsonObject():New()
		oJsonEnv['safraERP']    := AllTrim( (cAliasQRY)->SAFRA )
		oJsonEnv['etiqueta']    := AllTrim( (cAliasQRY)->ETIQUETA )
		oJsonEnv['numeroNF']    := AllTrim( (cAliasQRY)->NF_NUM )
		oJsonEnv['serie']       := AllTrim( (cAliasQRY)->NF_SERIE )
		oJsonEnv['dataEmissao'] := FWTimeStamp(3,STOD(AllTrim( (cAliasQRY)->NF_EMISSAO )),AllTrim( (cAliasQRY)->NF_HORAEMISSAO ) )
		oJsonEnv['cnpjEmissao'] := AllTrim( (cAliasQRY)->NF_CNPJ )  

        If !(fProcEnvInt(oJsonEnv, oToken, cEndPoint, cAliasQRY))
            lRet := .F.
            Exit //ocorreu erro de exceção, parar/finalizar execução
        EndIF       
        	
        (cAliasQRY)->( dbSkip() )
    EndDo
    (cAliasQry)->( dbCloseArea() )
    
Return lRet


/*/{Protheus.doc} fProcEnvInt
Função responsavel por chamar o envio da integração e gravar os dados de integração na tabela N9D.
@type function
@version P12
@author claudineia.reinert
@since 15/04/2024
@param oToken, object, objeto com os dados do token de integração
@return Logical, retorna .F. se ocorreu algum erro com desvio, senão retorna .T. 
/*/
Static Function fProcEnvInt(oJsonEnv, oToken, cEndPoint, cAliasQRY)
    Local lRet      := .T.
    Local lEnvia := .T.
    Local cErrInt   := ""
    Local nContErro := 0
    
    While lEnvia
        cErrInt := ""
        fEnvIntBen(oJsonEnv, oToken, cEndPoint, @cErrInt)
        
        Begin Transaction
            N9D->(dbGoTo((cAliasQRY)->(N9D_RECNO))) //posiciona no registro pelo recno
            RecLock("N9D", .F.)
            N9D->N9D_INTEGR := If(Empty(cErrInt),"2","1") //1=NAO;2=SIM
            N9D->N9D_INTERR := cErrInt
            N9D->N9D_INTDAT := dDataBase
            N9D->N9D_INTHOR := cValToChar(Time())
            N9D->(MsUnlock())
        End Transaction
        
        IF "invalid_token" $ cErrInt    //caso token invalido, pode ter expirado, tenta maximo 3 vezes          
            nContErro := nContErro + 1  
            If !(fTokenBen(@oToken)) .or. nContErro > 3 
                lRet := .F.
                exit //sai while, token não esta valido, precisa ajustar cadastro integração, erro de exceção para parar execução do processo
            EndIf
            loop //refaz o envio 
        Else
            lEnvia := .F. //sai while, integrou
        EndIf
    EndDo	
    
Return lRet

/*/{Protheus.doc} fTokenBen
Função responsavel por fazer a chamada da geração do token para a integração
@type function
@version P12
@author claudineia.reinert
@since 15/04/2024
@param oToken, object, objeto de passagem de parametro por referencia para receber os dados do token de integração
@return Logical, retorn .T. se o token foi gerado e .F. se houve algum erro
/*/
Static Function fTokenBen(oToken)
    Local lRet      := .F.
    Local cResult   := ""

    oToken := AGRAIntegrAgro():New("1") //gera token 1=BENEFICIAMENTO
    cResult := oToken:GetTokenApiBen() 
    If !Empty(oToken:access_token)
        lRet := .T.
    EndIf
    
Return lRet

/*/{Protheus.doc} fEnvIntBen
Função responsavel por realizar o envio dos dados para a API de integração Totvs Agro Beneficimaento
@type function
@version P12
@author claudineia.reinert
@since 15/04/2024
@param oJsonNF, object, Json com os dados a serem enviados na integração
@param oToken, object, objeto com os dados do token para a integração
@param cErrInt, character, variavel de passagem de parametro por referencia para receber erros se houver na integração
@return Logical, retorna .F. se ocorreu algum erro, senão retorna .T. 
/*/
Static Function fEnvIntBen( oJsonNF, oToken, cEndPoint, cErrInt ) //AGR82TKBEN
    Local lRet := .F. 
    Local oClient 	:= Nil
    Local oResult 	:= JsonObject():New()
    Local cParam    := ""
    Local aHeader    := {}

    oClient := FwRest():New(oToken:url_integr)

    AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )
    aAdd( aHeader, "Content-Type: application/json" )
    aAdd( aHeader, "charset: UTF-8" )
    aAdd( aHeader, "Authorization: " + oToken:access_token )
   
    oClient:SetPath(cEndPoint)
    cParam := "["+ oJsonNF:toJson() + "]"

    If oClient:Put(aHeader,cParam)
        oResult:fromJson( oClient:GetResult() )
        If !Empty(oResult['qtdSucesso']) .and. oResult['qtdSucesso'] > 0
            lRet := .T.
	    Else
            lRet := .F.
            cErrInt := oClient:GetResult()
        EndIf
    Else
        lRet := .F.
        cErrInt := oClient:GetResult()
    EndIf

Return lRet
