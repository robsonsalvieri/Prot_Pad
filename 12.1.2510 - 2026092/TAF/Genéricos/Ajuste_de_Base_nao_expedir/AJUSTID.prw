#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------------------------
/*/{Protheus.doc} Execucao

    Executa a Função de Ajuste.
    
    @type  Function
    @Author Silas Gomes
    @Since 12/03/2020
    @Version 1.0 
    /*/
//----------------------------------------------------------------------------    
 Function Execucao()
    
    Local oDlg      := Nil 
    Local oFont1    := Nil 
    Local oFont2    := Nil 
    Local oPanel    := Nil
    Local oTSay1    := Nil 
    Local oCheck    := Nil 
    Local lAceito   := .F. 
    Local cMsg      := ""
    Local cLinkTaf  := ""
    Local oLinkTaf  := Nil 

    cMsg    := "Esta rotina tem o objetivo de ajustar os ID's do evento S-1200 
    cMsg    += "para casos de funcionários que possuem 2 vínculos na mesma filial com matriculas diferentes 
    cMsg    += "e com evento de desligamento (S-2299), em alguns dos vínculos."  + CRLF + CRLF

    cMsg    += "É necessário que seja realizado o backup das tabelas envolvidas no processo (C91, CMD e  
    cMsg    += "C9V), quando executado em base de produção. Realizar a validação do processo 
    cMsg    += "na base de homologação. " + CRLF + CRLF

    cMsg    += "Mais Informações no link abaixo: "    

    cLinkTaf := "https://tdn.totvs.com/x/muxeI"

    Define MsDialog oDlg Title "Ajuste de ID's" From 5,10 To 300,550  Pixel 

    oPanel := TPanel():New(000,000,'',oDlg,,.F.,.F.,,CLR_WHITE,000,000,.F.,.F.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oFont1 := TFont():New("Tahoma",,-12,.T.)
    oFont2 := TFont():New("Tahoma",,-11,.T.)
    oFont2:Bold  

    oTSay1 	 := TSay():New(12,12,{||cMsg},oPanel,,oFont1,,,,.T.,,,250,250,,,,,,.T.)
        
    oLinkTaf := TSay():New(085,12,{||cLinkTaf},oPanel,,oFont2,,,,.T.,CLR_BLUE,,200,200,,,,,,.T.)


    oCheck := TCheckBox():New(100,12,"Li e entendi que devo realizar o backup das tabelas e validar a rotina em base de homologação.",,oPanel,400,150,,,,,,,,.T.,,,) 
    oCheck:bSetGet 	:= {|| lAceito } 
    oCheck:bLClicked 	:= {|| lAceito := !lAceito} 
    oCheck:bWhen 		:= {||.T.} 


    oLinkTaf:bLClicked := {|| MsgAlert("Atenção, você precisa estar logado no portal do cliente da TOTVS em seu navegador padrão para que o link seja aberto corretamente !"),  ShellExecute("open",cLinkTaf,"","",1) }


    Activate MsDialog oDlg Centered On Init Enchoicebar (oDlg	,{||IIf(ValCheck(lAceito),(oDlg:End()),.F.)};
                                                                        ,{||oDlg:End()};
                                                                        ,,,,,.F.,.F.,.F.,.T.,.F.)  

Return Nil 

//----------------------------------------------------------------------------
/*/{Protheus.doc} ValCheck
/*/
//----------------------------------------------------------------------------
Static Function ValCheck(lAceito)

    Local lValido := .T.

    If !lAceito
            MsgAlert("Você deve aceitar os Termos para execução desta rotina.")
        lValido := .F.
    Else
        MsgRun("Executando rotina...", "Aguarde", {||AjustID()} )
        //MsAguarde({|| AjustID()}, "Executando rotina...", "Aguarde")
        //MsgInfo("Executando rotina...", "Aguarde")

    EndIf 

Return lValido

//----------------------------------------------------------------------------
/*/{Protheus.doc} AjustID

    Função de ajuste de Id's dos eventos S-1200 e S-1210 para os funcionarios 
    que possuem 2 vinculos na mesma filial com matriculas diferentes e com envento de desligamento
    em 1 dos vinculos.

    @type  Function
    @Author Silas Gomes
    @Since 05/03/2020
    @Version 1.0    
    /*/
//----------------------------------------------------------------------------
Static Function AjustID()

    Local oTemp      := Nil
    Local cAliasTemp := ""
    Local cNewAlias  := GetNextAlias()
    Local aFields    := {}

    //Criando Campos para tabela temporária.
    aAdd(aFields, {'C9V_FILIAL',	'C', 	GetSx3Cache('C9V_FILIAL'    ,   'X3_TAMANHO'),  0})
    aAdd(aFields, {'C9V_CPF',		'C', 	GetSx3Cache('C9V_CPF'       ,   'X3_TAMANHO'),  0})
    aAdd(aFields, {'C9V_ID',		'C', 	GetSx3Cache('C9V_ID'        ,   'X3_TAMANHO'),  0})
    aAdd(aFields, {'C9V_MATRIC',	'C', 	GetSx3Cache('C9V_MATRIC'    ,   'X3_TAMANHO'),  0})
    aAdd(aFields, {'CMD_DTDESL',	'D', 	GetSx3Cache('CMD_DTDESL'    ,   'X3_TAMANHO'),  0})

    //Criando índice da tabela temporária.
    oTemp := FwTemporaryTable():New(cNewAlias,aFields)
    oTemp:AddIndex("1",{"C9V_FILIAL","C9V_CPF","C9V_ID","C9V_MATRIC","CMD_DTDESL"})
    oTemp:Create()

    cAliasTemp :=oTemp:GetRealName()

    PrechTable(cAliasTemp)
    UpdateCMD(oTemp)

    If ExecutaAjuste(cAliasTemp)
        MsgInfo("Processo Finalizado","Finalizado")
    Else
        MsgInfo("Não há registros a serem processados")
    EndIf

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} PrechTable()

    Função para executar a inserção das infomações na tabela temporaria. 

    @Type  Function
    @Author Silas Gomes
    @Since 05/03/2020
    @Version 1.0    
    /*/
//----------------------------------------------------------------------------
 Static Function PrechTable(cAliasTemp)

    Local cQuery   := ""

    //Insert de registro da C9V na tabela temporária.
    cQuery := " INSERT INTO " + cAliasTemp + "(C9V_FILIAL, C9V_CPF, C9V_ID, C9V_MATRIC)"
    cQuery += " SELECT A.C9V_FILIAL, A.C9V_CPF, A.C9V_ID, A.C9V_MATRIC "
    cQuery += " FROM " + RetSqlName("C9V") + " A "
    cQuery += " WHERE A.C9V_FILIAL = '" + cFilAnt + "'"
    cQuery += " AND A.C9V_CPF IN ( SELECT B.C9V_CPF "
    cQuery += " FROM " + RetSqlName("C9V") + " B "
    cQuery += " WHERE B.C9V_FILIAL = '" + cFilAnt + "'"
    cQuery += " AND B.C9V_CPF = A.C9V_CPF "
    cQuery += " AND B.C9V_MATRIC <> A.C9V_MATRIC "
    cQuery += " AND B.C9V_NOMEVE = A.C9V_NOMEVE "
    cQuery += " AND B.C9V_ATIVO = '1' "
    cQuery += " AND B.D_E_L_E_T_ = ' ' ) " 
    cQuery += " AND A.C9V_NOMEVE = 'S2200' "
    cQuery += " AND A.C9V_ATIVO = '1' "
    cQuery += " AND A.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY A.C9V_CPF "        

	If TCSQLExec(cQuery) < 0    
		MsgInfo(TCSQLError(),"Warning")
	EndIf    

Return 

//----------------------------------------------------------------------------
/*/{Protheus.doc} UpdateCMD

    Realiza ReckLock no campo CMD_DTDESL da alias temporária.

    @type  Function
    @param param
    @Author Silas Gomes
    @Since 05/03/2020
    @Version 1.0
    /*/
//----------------------------------------------------------------------------
Static Function UpdateCMD(oTemp)

	Local cAlias	    :=	oTemp:GetAlias()
    Local cIdTrab		:=	""

    dbSelectArea("CMD")
    CMD->(dbSetOrder( 5 ))    

    (cAlias)->(dbGotop())

    While (cAlias)->(!Eof())
        cIdTrab := (cAlias)->C9V_ID

        If CMD->(MsSeek(xFilial("CMD") + cIdTrab + "1"))
            RecLock("CMD", .F.)
            (cAlias)->CMD_DTDESL   := CMD->CMD_DTDESL
            CMD->(MsUnlock())
        EndIf

        ( cAlias )->(dbSkip())

    Enddo

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} ExecutAjuste
	(long_description)

	@Type  Function
    @Param cAliasTemp // Alias Temporário
	@Author Silas Gomes
	@Since 06/03/2020
	@Version 1.0
	/*/
//----------------------------------------------------------------------------    
 Static Function ExecutaAjuste(cAliasTemp)

	Local cQuery	    := ''
	Local cQuery2	    := ''
    Local cIdVinculo    := ''
    Local cIdVincFolha  := ''
    Local cIdAtivo      := ''
    Local oModel        := FWLoadModel( "TAFA250" )
    Local lRet          := .F.

    dbSelectArea('C91')
    dbSetOrder(4)

    //Consultando os registros na tabela temporaria que estão desligados
    cQuery :="SELECT C9V_ID, CMD_DTDESL,  "
    cQuery +="	(SELECT C9V_ID 
    cQuery +="FROM "  + cAliasTemp + " B " 
    cQuery +="WHERE CMD_DTDESL = '' 
    cQuery +="AND A.C9V_CPF = B.C9V_CPF "
    cQuery +="AND D_E_L_E_T_ = '') AS NAODESLIGADO "
    cQuery +="FROM "  + cAliasTemp + " A "
    cQuery +="WHERE CMD_DTDESL <> '' AND D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery New Alias 'aliasC9V'

	While aliasC9V->(!Eof())
        cIdVinculo := aliasC9V->C9V_ID

        //Consultando registros na tabela de folha que possuem periodos superiores a data de 
        //desligamento do vínculo do funcionario
		cQuery2	:= "SELECT R_E_C_N_O_ C91_RECNO, C91_TRABAL FROM " + RetSqlName('C91') 
        cQuery2 += " WHERE C91_TRABAL = '" + aliasC9V->C9V_ID 
        cQuery2 += "' AND C91_PERAPU > '"+ SubStr(aliasC9V->CMD_DTDESL,1,6) 
        cQuery2 += "' AND D_E_L_E_T_ = '' AND C91_FILIAL = '" + cFilAnt + "'"

		cQuery2 := ChangeQuery(cQuery2)
		TCQuery cQuery2 New Alias 'aliasC91'
        
		While aliasC91->(!Eof())		
            cIdVincFolha := aliasC91->C91_TRABAL
            cIdAtivo    := aliasC9V->NAODESLIGADO

            If !Empty(cIdAtivo) .AND. !Empty(cIdVinculo) .AND. !Empty(cIdVincFolha)
                If cIdVinculo == cIdVincFolha
                    C91->( DBGoTo( aliasC91->C91_RECNO ) )
                    oModel:SetOperation( MODEL_OPERATION_UPDATE )
                    oModel:Activate()
                    oModel:LoadValue("MODEL_C91", "C91_TRABAL",cIdAtivo)

                    If oModel:VldData()
                        FWFormCommit( oModel )
                    Else
                        VarInfo('modelo',oModel)
                    EndIf
                    oModel:DeActivate()

                EndIf

            EndIf

			aliasC91->(dbSkip())

            If !Empty(cIdAtivo)
                lRet          := .T.
            EndIf

		Enddo

		aliasC9V->(dbSkip())
		aliasC91->(DBCloseArea())

	Enddo
	
	aliasC9V->(DBCloseArea())

    oModel:Destroy()

Return lRet


