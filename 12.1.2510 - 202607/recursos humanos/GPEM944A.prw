#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM944A.CH"

Static lDicAtual

//---------------------------------------------------------------------
/*/{Protheus.doc} GPEM944A
@type			function
@description	Cadastro MVC para apresentar os registros da tabela RUO
@author			martins.marcio
@since			11/07/2025
/*/
//---------------------------------------------------------------------
Function GPEM944A()

    Local cFiltraRh := ""
    Local oBrowse
    
    DEFAULT lDicAtual := RUO->(ColumnPos("RUO_ORIGEM")) > 0

    If lDicAtual
        GP944Compat()
    EndIf

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription( OemToAnsi(STR0001) ) //"Histórico de Importações do Crédito do Trabalhador"
    oBrowse:SetAlias( "RUO" )

    //Inicializa o filtro
	oBrowse:SetFilterDefault( cFiltraRh )
    fRUOLeg(@oBrowse)

	oBrowse:ExecuteFilter(.T.)

    oBrowse:Activate()

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			martins.marcio
@since			11/07/2025
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina :=  {}

    ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION 'PesqBrw'           OPERATION 1 ACCESS 0       //"Pesquisar"
    ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION 'VIEWDEF.GPEM944A'  OPERATION 2 ACCESS 0       //"Visualizar"
    ADD OPTION aRotina TITLE OemToAnsi(STR0006) ACTION 'VIEWDEF.GPEM944A'  OPERATION 3 ACCESS 0       //"Incluir"
    ADD OPTION aRotina TITLE OemToAnsi(STR0007) ACTION 'VIEWDEF.GPEM944A'  OPERATION 4 ACCESS 0       //"Alterar"
    ADD OPTION aRotina TITLE OemToAnsi(STR0021) ACTION 'VIEWDEF.GPEM944A'  OPERATION 5 ACCESS 0       //"Excluir"

Return( aRotina )


//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			martins.marcio
@since			11/07/2025
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel   := MPFormModel():New( "GPEM944A", /*bPreValid*/, {|oModel| GP944Ok(oModel)} )
    Local oStruRUO := FWFormStruct( 1, 'RUO')
    Local bWhenAll := {|| INCLUI .OR. (ALTERA .AND. lDicAtual .AND. M->RUO_ORIGEM == '2' )}
    Local bWhenPD  := {|| (INCLUI .OR. (ALTERA .AND. lDicAtual .AND. M->RUO_ORIGEM == '2' )) .AND. !Empty(M->RUO_MAT) .AND. !Empty(M->RUO_NRCONT) .AND. !Empty(M->RUO_COMPET)}

    DEFAULT lDicAtual := RUO->(ColumnPos("RUO_ORIGEM")) > 0

    oStruRUO:SetProperty('*'          , MODEL_FIELD_WHEN, bWhenAll )
    oStruRUO:SetProperty('RUO_MAT'    , MODEL_FIELD_WHEN, {|| INCLUI})
    oStruRUO:SetProperty('RUO_NRCONT' , MODEL_FIELD_WHEN, {|| INCLUI .AND. !Empty(M->RUO_MAT)})
    oStruRUO:SetProperty('RUO_OBSERV' , MODEL_FIELD_WHEN, {|| .T.})
    oStruRUO:SetProperty('RUO_INTEGR' , MODEL_FIELD_WHEN, {|| .F.})
    If lDicAtual
        oStruRUO:SetProperty('RUO_PD'       , MODEL_FIELD_WHEN, bWhenPD)
        oStruRUO:SetProperty('RUO_ORIGEM'   , MODEL_FIELD_WHEN, {|| .F.})
        oStruRUO:SetProperty('RUO_NRCONT'   , MODEL_FIELD_VALID, {|| Gp944VldCtr()} )
    EndIf

    oModel:AddFields( "GPEM944A_RUO", /*cOwner*/, oStruRUO )

    oModel:SetVldActivate( { |oModel| GP944Vld(oModel) } )

    //Definição de chave primária do modelo
    oModel:SetPrimaryKey({'RUO_FILIAL', 'RUO_MAT', 'RUO_NRCONT', 'RUO_COMPET', 'RUO_PD', 'RUO_BCOCON'})

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			martins.marcio
@since			11/07/2025
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel	:=	FWLoadModel( "GPEM944A" )
    Local oView		:=	FWFormView():New()
    Local oStruRUO	:=	FWFormStruct( 2, "RUO" )

	oView:SetModel(oModel)
    oView:AddField( "VIEW_RUO", oStruRUO, "GPEM944A_RUO" )
	oView:CreateHorizontalBox( 'FIELDSRUO' , 100 )
    oView:SetOwnerView( "VIEW_RUO", "FIELDSRUO" )

Return( oView )


//---------------------------------------------------------------------
/*/{Protheus.doc} fRUOLeg
Legenda do browse
@author  martins.marcio
@type    function
@since   11/07/2025
/*/
//---------------------------------------------------------------------
Function fRUOLeg(oBrowse)

    oBrowse:AddLegend( "RUO->RUO_INTEGR=='1' "		, 'GREEN'	, OemToAnsi(STR0004), , .T. )	//"Integrado"
    oBrowse:AddLegend( "RUO->RUO_INTEGR=='2' "		, 'BLUE'	, OemToAnsi(STR0005), , .T. )	//"Não Integrado"

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} GP944Compat
Atualiza registros legados da RUO com RUO_ORIGEM em branco para "1".
Executa o saneamento antes da abertura do browse.
@type       function
@author     martins.marcio
@since      12/06/2026
@version    1.0
@return     logical, .T. quando processado
/*/
//---------------------------------------------------------------------
Function GP944Compat()

    Local cQry    := ""

    cQry += " UPDATE " + RetSqlName("RUO") + " "
    cQry += " SET RUO_ORIGEM = '1' "
    cQry += " WHERE RUO_ORIGEM = '' "
    cQry += "   AND D_E_L_E_T_ = ' ' "

    TcSqlExec(cQry)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} GP944Vld
Valida ativação do modelo, incluindo regras de negócio de operação.
Permite excluir somente quando RUO_ORIGEM = "2" e a coluna existir no dicionário.
@type       function
@author     martins.marcio
@since      12/06/2026
@version    1.0
@param      oModel, object, Modelo MVC ativo
@return     logical, .T. quando permitido | .F. quando bloqueado
/*/
//---------------------------------------------------------------------
Static Function GP944Vld(oModel)

    Local lRet    := .T.
    Local cOrigem := ""

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        If !lDicAtual
            Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0024), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0023)} ) //"Atenção"#"Operação não permitida"#"Para Inclusão ou Alteração atualize o ambiente com o dicionário de dados da expedição contínua do RH."
            lRet := .F.
        EndIf
    ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
        If lDicAtual
            cOrigem := RUO->RUO_ORIGEM
        EndIf

        If !(lDicAtual .And. cOrigem == "2")
            Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0024), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0022)} ) //"Atenção"#"Operação não permitida"#"Exclusão permitida somente para registros de origem '2-Importação'."
            lRet := .F.
        EndIf
    EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GP944Ok
Validação executada no confirmar (TudoOk) do modelo.
Executa a validação da verba (RUO_PD) nas operações de inclusão e alteração.
@type       function
@author     martins.marcio
@since      15/06/2026
@version    1.0
@param      oModel, object, Modelo MVC ativo
@return     logical, .T. quando permitido | .F. quando bloqueado
/*/
//---------------------------------------------------------------------
Static Function GP944Ok(oModel)

    Local lRet := .T.

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        lRet := Gp944Pd()
    EndIf

Return lRet

/*/{Protheus.doc} fCompetRUO
Função para obter a próxima competência a ser utilizada na tabela RUO
Considera a competencia em aberto + 1 mês 
@author martins.marcio
@since 11/06/2026
@version 1.0
/*/
Function fCompetRUO()
    Local cCompRet := ""
    Local aArea    := GetArea()
    Local cFilTrab := xFilial("RUO")
    Local cMatTrab := &(ReadVar())

    DbSelectArea("SRA")
    DbSetOrder(1)
    If !Empty(cMatTrab) .And. DbSeek(cFilTrab + cMatTrab)
        cCompRet := fGetFolmes(xFilial( "RCH", cFilTrab))
        If !Empty(cCompRet) .And. Len(cCompRet) == 6
            cCompRet := fAdd1Mes(cCompRet)
            cCompRet := Substr(cCompRet, 5, 2) + Substr(cCompRet, 1, 4) //Transforma em MMAAAA
            SetMemVar( "RUO_COMPET" , cCompRet )
        EndIf
    EndIf

    RestArea(aArea)

Return cCompRet

/*/{Protheus.doc} fAdd1Mes
Incrementa em 1 mês a data(AAAAMM) recebida como parâmetro, considerando o ano e a mudança de mês.
@author martins.marcio
@since 11/06/2026
@version 1.0
/*/
Static Function fAdd1Mes(cDataOri)
	Local cRet := ""

	DEFAULT cDataOri := ""

	If !Empty(cDataOri) .And. Len(cDataOri) == 6
		cRet := SUBSTR(DTOS(LASTDAY(STOD(cDataOri + "01")) + 1) ,1,6)
	EndIf

Return cRet

/*/{Protheus.doc} GP944SitEm
Retorna opções (X3_CBOX) do campo Sit.Emp. (RUO_SITEMP)
@type      	Function
@author   	martins.marcio
@since		12/06/2026
@version	1.0
/*/
Function GP944SitEm()
    Local cOpcBox := ""

    cOpcBox += ( "0="  + oEmToAnsi(STR0008)  + ";" )  //0-Ativo
    cOpcBox += ( "2="  + oEmToAnsi(STR0009)  + ";" )  //2-Excluído
    cOpcBox += ( "3="  + oEmToAnsi(STR0010) + ";" )   //3-Encerrado
    cOpcBox += ( "8="  + oEmToAnsi(STR0011) + ";" )   //8-Suspenso banco
    cOpcBox += ( "15=" + oEmToAnsi(STR0012) + ";" )   //15-Encerrado por término do vínculo
    cOpcBox += ( "16=" + oEmToAnsi(STR0013)         ) //16-Encerrado com renegociação

Return cOpcBox

/*/{Protheus.doc} GP944Comp
Valida formato de Competência (RUO_COMPET) e Competência Inicial e Final (RUP_INIDES e RUO_FIMDES)
@type      	Function
@author   	raquel.andrade
@since		12/06/2026
@version	1.0
/*/
Function GP944Comp()
    Local cCompet	:= &(ReadVar())
    Local nAno		:= 0
    Local nMes		:= 0
    Local lCompetOk	:= .T.

	// Forca o periodo no formato MM/AAAA
	If !Empty(cCompet)
		nAno := Val(SubStr(cCompet, 3, 4))
		nMes := Val(SubStr(cCompet, 0, 2))
		If (nAno < 1900 .Or. nAno > 3000 ) .Or. (nMes < 1 .Or. nMes > 12 )
			lCompetOk:= .F.
		EndIf
	EndIf

	If !lCompetOk
		//"Atenção"#"Competência não está no formato correto."###!Verifique o formato (MM/AAAA)"
        Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0014), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0025)} )
	Endif

Return lCompetOk

/*/{Protheus.doc} GP944SitVld()
Valida Situação de Empréstimo - X3_VALID RUO_SITEMP
@type      	Function
@author   	raquel.andrade
@since		12/06/2026
@version	1.0
/*/
Function GP944SitVld()
    Local cOpc	:= &(ReadVar())
    Local lRet	:= .F.

	lRet    := AllTrim(cOpc) $ '0|2|3|8|15|16'

Return lRet

/*/{Protheus.doc} Gp944PdFilt()
Expressão de filtro do F3 RUOSRV - X3_F3 campo RUO_PD
@type      	Function
@author   	raquel.andrade
@since		12/06/2026
@version	1.0
/*/
Function Gp944PdFilt()
    Local cFilt		:= "@#.T.@#"  
    
    cFilt:= "@#SRV->RV_TIPOCOD == '2' .AND. SRV->RV_NATUREZ == '9253' .AND. SRV->RV_INCFGTS == '31'@#"

Return( cFilt )

//---------------------------------------------------------------------
/*/{Protheus.doc} Gp944Pd
Valida a verba (PD) para empréstimos do Crédito do Trabalhador.
Verifica critérios na tabela SRV (tipo, natureza, FGTS) e duplicidade em SRK/RUO.
Deve ser posicionado na tabela RUO antes de chamar esta função.
@author martins.marcio
@since 12/06/2026
@version 1.0
@return logical .T. = Verba OK | .F. = Verba inválida
/*/
//---------------------------------------------------------------------
Function Gp944Pd()
    Local lRet      := .T.
    Local aAreaRUO  := RUO->(GetArea())
    Local cChvSRV   := ""
    Local cChvSRK   := ""
    Local cChvRUO   := ""
    Local cMsgErr   := ""
    Local cFilReg   := If(Empty(M->RUO_FILIAL), xFilial("SRA"), M->RUO_FILIAL)
    Local cNRContr  := M->RUO_NRCONT
    Local cVerba    := M->RUO_PD
    Local cMat      := M->RUO_MAT
    Local cCompet   := M->RUO_COMPET
    Local cFilAux   := M->RUO_FILIAL
    Local oModel    := NIL
    Local oModelRUO := NIL

    oModel    := FWModelActive()
    If ValType(oModel) == "O"
        oModelRUO := oModel:GetModel("GPEM944A_RUO")
        If ValType(oModelRUO) == "O"
            cNRContr := oModelRUO:GetValue("RUO_NRCONT")
            cVerba   := oModelRUO:GetValue("RUO_PD")
            cMat     := oModelRUO:GetValue("RUO_MAT")
            cCompet  := oModelRUO:GetValue("RUO_COMPET")
            cFilAux  := oModelRUO:GetValue("RUO_FILIAL")
        EndIf
    EndIf

    cFilAux := If(Empty(cFilAux), xFilial("RUO"), cFilAux)

    If INCLUI .And. !Empty(cNRContr) .And. !Empty(cMat) .And. !Empty(cCompet)
        // Valida se matricula/contrato/competencia já não existe na tabela RUO
        DbSelectArea("RUO")
        DbSetOrder(1) //RUO_FILIAL+RUO_MAT+RUO_NRCONT+RUO_COMPET+RUO_PD+RUO_BCOCON
        cChvRUO := xFilial("RUO", cFilAux) + cMat + cNRContr + cCompet
        If RUO->(DbSeek(cChvRUO))
            Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0027), 1, 0) //"Atenção"#"Contrato já existe para esta matrícula e competência."
            lRet := .F.
        EndIf
    EndIf

    If lRet .And. !Empty(cNRContr) .And. !Empty(cVerba)
        //Validação 1: Verba deve existir e ter os atributos corretos na SRV
        If !Empty(cVerba)
            cChvSRV := xFilial("SRV", cFilReg) + cVerba
            DbSelectArea("SRV")
            SRV->(DbSetOrder(1)) //RV_FILIAL+RV_COD

            If SRV->(DbSeek(cChvSRV))
                If SRV->RV_TIPOCOD <> "2" .Or. SRV->RV_NATUREZ <> "9253" .Or. SRV->RV_INCFGTS <> "31"
                    cMsgErr := OemToAnsi(STR0016) //"Verba inválida. A verba deve possuir tipo igual a '2-Desconto', natureza '9253' e incidência FGTS '31'."
                    lRet := .F.
                    Help( ,, OemToAnsi(STR0015),, OemToAnsi(cMsgErr), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0030)} ) //"Atenção"#"Verba inválida. A verba deve possuir tipo igual a '2-Desconto', natureza '9253' e incidência FGTS '31'."#"Verifique o cadastro da verba e tente novamente."
                EndIf
            Else
                cMsgErr := OemToAnsi(STR0017) //"Informe um código de verba válido."
                lRet := .F.
                Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0028), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(cMsgErr)} ) //"Atenção"#Código de verba inválido.#"Informe um código de verba válido."
            EndIf

            // A verba não pode ser usada em outro contrato do mesmo funcionário, considerando a tabela SRK e RUO. 
            If !Empty(M->RUO_MAT) .And. !Empty(cNRContr)

                //Valida se pode utilizar a verba considerando a tabela SRK
                If lRet
                    cChvSRK := xFilial("SRK", cFilReg) + M->RUO_MAT + cVerba

                    DbSelectArea("SRK")
                    SRK->(DbSetOrder(4)) //RK_FILIAL+RK_MAT+RK_PD+RK_PERINI+RK_NUMPAGO
                    If SRK->(DbSeek(cChvSRK))
                        While !SRK->(Eof()) .And. SRK->RK_FILIAL + SRK->RK_MAT + SRK->RK_PD == AllTrim(cChvSRK)
                            If UPPER(AllTrim(SRK->RK_NRCONTR)) <> UPPER(AllTrim(cNRContr)) .And. !(AllTrim(SRK->RK_STATUS) $ "3|5")
                                cMsgErr := OemToAnsi(STR0018) + cVerba + OemToAnsi(STR0019) + SRK->RK_NRCONTR + ". [SRK]" //"Verba '" + cVerba + "' já está sendo utilizada para o contrato "+ SRK->RK_NRCONTR + ". [SRK]"
                                lRet := .F.
                                Help( ,, OemToAnsi(STR0015),, OemToAnsi(cMsgErr), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0029)} ) //"Atenção"#"Verba '" + cVerba + "' já está sendo utilizada para o contrato "+ SRK->RK_NRCONTR + ".#Escolha um código de verba diferente."
                                Exit
                            EndIf
                            SRK->(DbSkip())
                        EndDo
                    EndIf
                EndIf

                // Verifica se pode usar a verba considerando a tabela RUO
                If lRet .And. !Empty(M->RUO_COMPET)
                    cChvRUO := xFilial("RUO", cFilReg) + M->RUO_MAT + M->RUO_PD

                    DbSelectArea("RUO")
                    RUO->(DbSetOrder(4)) //RUO_FILIAL+RUO_MAT+RUO_PD
                    If RUO->(DbSeek(cChvRUO))
                        While !RUO->(Eof()) .And. RUO->RUO_FILIAL + RUO->RUO_MAT + RUO->RUO_PD == AllTrim(cChvRUO)
                            If RUO->RUO_COMPET == M->RUO_COMPET .And. UPPER(AllTrim(RUO->RUO_NRCONT)) <> UPPER(AllTrim(cNRContr))
                                cMsgErr := OemToAnsi(STR0018) + cVerba + OemToAnsi(STR0019) + RUO->RUO_NRCONT + OemToAnsi(STR0020) + M->RUO_COMPET + ". [RUO]" //"Verba '" + cVerba + "' já está sendo utilizada para o contrato "+ RUO->RUO_NRCONT + " na competência " + M->RUO_COMPET + ". [RUO]"
                                lRet := .F.
                                Help( ,, OemToAnsi(STR0015),, OemToAnsi(cMsgErr), 1, 0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0029)} ) //"Atenção"#"Verba '" + cVerba + "' já está sendo utilizada para o contrato "+ RUO->RUO_NRCONT + " na competência " + M->RUO_COMPET + "."#"Escolha um código de verba diferente."
                                Exit
                            EndIf
                            RUO->(DbSkip())
                        EndDo
                    EndIf
                EndIf

            EndIf

        EndIf
    
    EndIf

    If IsInCallStack("RUNTRIGGER")
        lRet := .T.
    EndIf
    RestArea(aAreaRUO)

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} Gp944CtrPd
Obtém a verba de eConsignado para o contexto do registro em edição na RUO.
Utiliza a função getPdEcons() do fonte GPEM944.PRW.
@author martins.marcio
@since 12/06/2026
@version 1.0
@return character Código da verba encontrada ou vazio quando não localizar
/*/
//---------------------------------------------------------------------
Function Gp944CtrPd()

    Local aArea      := GetArea()
    Local cVerbaRet  := ""
    Local cObserv    := ""
    Local aPdEConsig := {}
    Local cRAFilial  := If(Empty(M->RUO_FILIAL), xFilial("SRA"), M->RUO_FILIAL)
    Local cRAMat     := AllTrim(M->RUO_MAT)
    Local cContrato  := AllTrim(M->RUO_NRCONT)
    Local cCompetRUO := M->RUO_COMPET
    Local lPosSRA    := .F.
    Local oModel    := NIL
    Local oModelRUO := NIL

    oModel    := FWModelActive()
    If ValType(oModel) == "O"
        oModelRUO := oModel:GetModel("GPEM944A_RUO")
        If ValType(oModelRUO) == "O"
            cRAMat     := oModelRUO:GetValue("RUO_MAT")
            cContrato  := oModelRUO:GetValue("RUO_NRCONT")
            cCompetRUO := oModelRUO:GetValue("RUO_COMPET")
        EndIf
    EndIf

    If !Empty(cContrato) .And. !Empty(cRAMat) .And. !Empty(cCompetRUO)
        DbSelectArea("SRA")
        SRA->(DbSetOrder(1)) //RA_FILIAL+RA_MAT
        lPosSRA := SRA->(DbSeek(xFilial("SRA", cRAFilial) + cRAMat))

        If lPosSRA
            cVerbaRet := getPdEcons(cRAFilial, cRAMat, cContrato, @aPdEConsig, @cObserv, cCompetRUO)
        EndIf
    EndIf

    RestArea(aArea)

Return cVerbaRet

//---------------------------------------------------------------------
/*/{Protheus.doc} Gp944VldCtr
Validação do campo NR do Contrato
@author martins.marcio
@since 15/06/2026
@version 1.0
@return logical .T. = validação concluída (Help exibido se necessário)
/*/ 
Function Gp944VldCtr()
    Local lRet      := .T.
    Local aArea    := GetArea()
    Local cChvRUO   := ""
    Local cMat      := M->RUO_MAT
    Local cNrCont   := M->RUO_NRCONT
    Local cCompet   := M->RUO_COMPET
    Local cFilAux   := M->RUO_FILIAL
    Local oModel    := NIL
    Local oModelRUO := NIL

    oModel := FWModelActive()
    If ValType(oModel) == "O"
        oModelRUO := oModel:GetModel("GPEM944A_RUO")
        If ValType(oModelRUO) == "O"
            cMat    := oModelRUO:GetValue("RUO_MAT")
            cNrCont := oModelRUO:GetValue("RUO_NRCONT")
            cCompet := oModelRUO:GetValue("RUO_COMPET")
            cFilAux := oModelRUO:GetValue("RUO_FILIAL")
        EndIf        
    EndIf

    cFilAux := If(Empty(cFilAux), xFilial("RUO"), cFilAux )

    If INCLUI .And. !Empty(cNrCont)
        // Valida se matricula/contrato/competencia já não existe na tabela RUO
        DbSelectArea("RUO")
        DbSetOrder(1) //RUO_FILIAL+RUO_MAT+RUO_NRCONT+RUO_COMPET+RUO_PD+RUO_BCOCON
        cChvRUO := xFilial("RUO", cFilAux) + cMat + cNrCont + cCompet
        If RUO->(DbSeek(cChvRUO))
            Help( ,, OemToAnsi(STR0015),, OemToAnsi(STR0027), 1, 0) //"Atenção"#"Contrato já existe para esta matrícula e competência."
            lRet := .F.
        EndIf
    EndIf

    RestArea(aArea)

Return lRet
