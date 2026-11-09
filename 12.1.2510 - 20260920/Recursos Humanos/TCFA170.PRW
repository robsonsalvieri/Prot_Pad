#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA170.CH"

PUBLISH MODEL REST NAME TCFA170  

Function TCFA170()

    Local oMBrowse      := NIL
    Local aOfusca       := ChkOfusca()
    Local aFldRel       := {"RA_FILIAL", "RA_MAT", "RA_NOME", "RA_CIC"}
    Local lBlqAcesso    := ( aOfusca [2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) ) )
    Local lTables       := ChkFile("RUY") .And. ChkFile("RUZ")

    //Tratamento de acesso a Dados Sensíveis
    If lBlqAcesso
        //"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
        Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
        Return
    EndIf

    IF !lTables
        Help(" ",1,STR0002,NIL, STR0003,1,0) // Atenção! - Tabela RUY ou RUZ não encontradas. Atualize o seu ambiente.
        Return
    EndIf

    If !fExistPerg("TCFA170")
        //"Funcionalidade não disponí­vel para esta versío do sistema."
        Help(,, "Help",, STR0002, 1, 0,,,,,, {STR0004}) // "Não foi encontrado o grupo de perguntas do TCFA160."
        Return
    EndIf

    oMBrowse := FWMBrowse():New()
    oMBrowse:SetAlias("SRA")
    oMBrowse:SetDescription(OemToAnsi(STR0001)) //Cadastro de Tokens
    oMBrowse:SetMenuDef("TCFA170")

    //Ativa a tela.
    oMBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef
Regras de modelagem da gravação.
@author Henrique Ferreira
@since 17/01/2024
@version 12.1.2410

@return nulo
/*/
Static Function ModelDef()

    Local oModel
    Local oStructSRA
    Local oStructRUY
    Local oStructRUZ

    // Criação do Objeto de Modelagem de dados da tabela RUY
    oModel := MPFormModel():New("TCFA170")
    oModel:SetDescription( OemToAnsi(STR0001) ) //'Controle de Espelho de Ponto'

    // Estrutura de campos do Model //
	oStructSRA := FWFormStruct(1, "SRA", {|x| TcfSRAStru(x)})
	oStructRUY := FWFormStruct(1, "RUY")
    oStructRUZ := FWFormStruct(1, "RUZ")

    oModel:AddFields("SRAMASTER",, oStructSRA )
	oModel:GetModel("SRAMASTER"):SetOnlyView( .T. )
	oModel:GetModel("SRAMASTER"):SetOnlyQuery( .T. )

    oModel:AddGrid("RUYDETAIL", "SRAMASTER", oStructRUY)
	oModel:GetModel('RUYDETAIL'):SetOptional(.F.)

    oModel:AddGrid("RUZDETAIL", "SRAMASTER", oStructRUZ)
	oModel:GetModel('RUZDETAIL'):SetOptional(.F.)

    // Não Permite Incluir linhas na formgrid
	oModel:GetModel( "RUYDETAIL" ):SetNoInsertLine()
	oModel:GetModel( "RUZDETAIL" ):SetNoInsertLine()
    // Seta unico
    oModel:GetModel("RUYDETAIL"):SetUniqueLine( { "RUY_FILIAL", "RUY_MAT", "RUY_TOKEN" } )
	oModel:SetRelation("RUYDETAIL", {{"RUY_FILIAL", "RA_FILIAL"}, {"RUY_MAT", "RA_MAT"}}, RUY->(IndexKey()))
    oModel:GetModel("RUZDETAIL"):SetUniqueLine( { "RUZ_FILIAL", "RUZ_MAT", "RUZ_CODIGO" } )
	oModel:SetRelation("RUZDETAIL", {{"RUZ_FILIAL", "RA_FILIAL"}, {"RUZ_MAT", "RA_MAT"}}, RUZ->(IndexKey()))
Return oModel

/*/{Protheus.doc} ViewDef
Regras de interface do usuário.
@author Henrique Ferreira
@since 17/01/2024
@version 12.1.2410
@return nulo
/*/
Static Function ViewDef()

	Local oView
	Local oModel
	Local oStructSRA
	Local oStructRUY
    Local oStructRUZ

    // Criacao da Interface
	oView := FWFormView():New()
	
	// Vincular o View ao Model
	oModel := FWLoadModel("TCFA170")
	oView:SetModel(oModel)
	
	oStructSRA := FWFormStruct(2, "SRA", {|x| TcfSRAStru(x)})
	oStructSRA:SetNoFolder()
	
    oView:AddField( "SRAMASTER", oStructSRA )
	
	oStructRUY := FWFormStruct(2, "RUY")
    oView:AddGrid( "RUYDETAIL", oStructRUY )
    oStructRUZ := FWFormStruct(2, "RUZ")
    oView:AddGrid( "RUZDETAIL", oStructRUZ )

    oView:SetViewProperty("SRAMASTER", "OnlyView") // Somente visualização. Não permite edição dos campos do cabeçalho (SRA)

    oView:createHorizontalBox("SUPERIOR", 50)
	oView:createHorizontalBox("INFERIOR", 50)

    // Criando pastas.
    oView:CreateFolder("PASTA_FILHOS", "INFERIOR")
    oView:AddSheet("PASTA_FILHOS", "ABA_FILHOS01", "Tokens")
    oView:AddSheet("PASTA_FILHOS", "ABA_FILHOS02", "Notificações")

    // Criando vinculo com as pastas.
    oView:createHorizontalBox("ITENS_FILHO01", 100, NIL, NIL, "PASTA_FILHOS", "ABA_FILHOS01")
	oView:createHorizontalBox("ITENS_FILHO02", 100, NIL, NIL, "PASTA_FILHOS", "ABA_FILHOS02")

	oView:SetOwnerView( "SRAMASTER", "SUPERIOR")
    oView:SetOwnerView( "RUYDETAIL", "ITENS_FILHO01")
    oView:SetOwnerView( "RUZDETAIL", "ITENS_FILHO02")

    oView:EnableControlBar(.T.)
    oView:SetCloseOnOk({|| .T.}) // remove o botão salvar e criar novo.

Return oView

/*/{Protheus.doc} MenuDef
Criação do menu do browse.
@author Leandro Drumond
@since 17/01/2024
@version 12.1.2410
@return Array
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TCFA170" 	OPERATION 2 ACCESS 0 	    	//'Visualizar'
    ADD OPTION aRotina TITLE STR0006  ACTION "Tc170Lote()"	    OPERATION 4 ACCESS 0			//'Excluir'
	
Return aRotina

Static Function TcfSRAStru( cCampo )
	Local lRet := .F.
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_FILIAL*RA_MAT*RA_NOME*RA_CIC' 
		lRet := .T.
	EndIf
Return lRet

/*/{Protheus.doc} Tc170Lote
Abre o pop up para dar excluir os tokens conforme filtro.
@author Henrique Ferreira
@since 36/04/2024
@version 12.1.2310
@return nulo
/*/
Function Tc170Lote()
    Local aArea		:= GetArea()
    Local bProcesso	:= {|oSelf| Tcf170Exclui(oSelf)}
    Local cPerg     := "TCFA170"
    Local cDesc1	:= OemToAnsi(STR0011)	//"Excluir em Lote"
    Local cDesc2	:= OemToAnsi(STR0012)	//"Este programa excluirá os tokens e as notificações dos funcionários."

    Private aLog		:= {{}}
    Private aTitle		:= {}

    Pergunte(cPerg,.F.)

    tNewProcess():New( "TCFA170", cDesc1, bProcesso, cDesc2, cPerg, , , , , .T., .T.  )
    MsAguarde({|| fMakeLog( aLog, aTitle, "TCFA170", NIL , "TCFA170", STR0014 )}, STR0014) // "Ocorrências no envio das notificações."

    RestArea(aArea)

Return Nil

Static Function Tcf170Exclui(oProcess)
    
    Local cFilDe    := MV_PAR01
    Local cFilAte   := MV_PAR02
    Local cMatDe    := MV_PAR03
    Local cMatAte   := MV_PAR04
    Local cCCDe     := MV_PAR05
    Local cCCAte    := MV_PAR06
    Local cDeptoDe  := MV_PAR07
    Local cDeptoAte := MV_PAR08
    Local cInicio   := "SRA->RA_FILIAL + SRA->RA_MAT"
    Local cFim      := cFilAte + cMatAte

    Local aArea     := GetArea()
    Local aAreaSRA  := SRA->(GetArea())
        
    Private cCodFil     := ""
    Private cCodMat     := ""
    Private cNome       := ""
    Private dDataDe     := If( !Empty(MV_PAR09), MV_PAR09, ctod("01/01/2020")) 
    Private dDataAte    := If( !Empty(MV_PAR10), MV_PAR10, ctod("31/12/2060"))
    Private nTipoExc    := MV_PAR11

    DbSelectArea("SRA")
    dbSetOrder(1)
    DbGoTop()

    oProcess:SetRegua1(SRA->(RecCount()))

    While SRA->(!EOF()) .And. &cInicio <= cFim
        // Processa Filtros, desprezando demitidos e transferidos.
        IF  ( SRA->RA_FILIAL < cFilDe )  .OR. ( SRA->RA_FILIAL > cFilAte )    .OR. ;
            ( SRA->RA_MAT < cMatDe )   .Or. ( SRA->RA_MAT > cMatAte ) .Or. ;
		    ( SRA->RA_CC < cCcDe )     .Or. ( SRA->RA_CC > cCcAte )   .Or. ;
		    ( SRA->RA_DEPTO < cDeptoDe ) .Or. ( SRA->RA_DEPTO > cDeptoAte )
		    SRA->(dbSkip())
		    Loop
	    EndIf

        cCodFil := SRA->RA_FILIAL
        cCodMat := SRA->RA_MAT
        cNome   := SRA->RA_NOME

        oProcess:IncRegua1(STR0013 + " " + cCodFil + " - " + cCodMat + " - " + cNome ) // Processando funcionário:

        //Deleta Tokens e Notificações
        If nTipoExc == 2
            // Somente deleta as notificações caso consiga deletar os tokens
            If fDelRUY()
                // Deleta as notificações.
                fDelRUZ()
                fGeraLog(STR0015)
            Else
                fGeraLog(STR0016)
            EndIf
        Else
            // Deleta as notificações
            If fDelRUZ()
                fGeraLog(STR0017)
            Else
                fGeraLog(STR0018)
            EndIf
        EndIf
        SRA->(DbSkip())
    EndDo
    
    RestArea(aArea)
    RestArea(aAreaSRA)
Return

Static Function fDelRUY()

    Local lRet      := .F.
    Local aAreaRUY  := RUY->(GetArea())

    DbSelectArea("RUY")
    dbSetOrder(1)
    DbGoTop()

    If RUY->(DbSeek( cCodFil+cCodMat ) )
        IF  ( RUY->RUY_DTCRIA >= dDataDe )  .And. ( RUY->RUY_DTCRIA <= dDataAte )
            Begin Transaction
                Reclock("RUY",.F.)
                RUY->(dbDelete())
                RUY->(MsUnlock())
            End Transaction
            lRet := .T.
        EndIf
    EndIf

    RestArea(aAreaRUY)

Return lRet

Static Function fDelRUZ()

    Local aAreaRUZ  := RUZ->(GetArea())
    Local lFiltra   := ( nTipoExc == 1 )
    Local lRet      := .F.

    // Posiciona na RUZ
    DbSelectArea("RUZ")
    dbSetOrder(1)
    DbGoTop()

    If RUZ->(DbSeek( cCodFil + cCodMat ) )
        If lFiltra
            While  RUZ->RUZ_FILIAL == cCodFil .And. RUZ->RUZ_MAT == cCodMat
                If RUZ->RUZ_DTENVI >= dDataDe .And. RUZ->RUZ_DTENVI <= dDataAte
                    Begin Transaction
                        Reclock("RUZ",.F.)
                        RUZ->(dbDelete())
                        RUZ->(MsUnlock())
                    End Transaction
                    lRet := .T.
                EndIf
                RUZ->(DbSkip())
            EndDo
        Else
            lRet := .T.
            While  RUZ->RUZ_FILIAL == cCodFil .And. RUZ->RUZ_MAT == cCodMat
                Begin Transaction
                    Reclock("RUZ",.F.)
                    RUZ->(dbDelete())
                    RUZ->(MsUnlock())
                End Transaction
                RUZ->(DbSkip())
            EndDo
        EndIf
    EndIf

    RestArea(aAreaRUZ)

Return lRet


/*/{Protheus.doc} fGeraLog
Log de processamento.
@type  Static Function
@author Henrique Ferreira
@since 01/04/2024
@param cMsg - Mensagem que será utilizada para gerar o log.
/*/
Static Function fGeraLog(cMsg)

    If Empty(aTitle)
        Aadd(aTitle, STR0008) //"Funcionários processados."
    EndIf
    Aadd(aLog[1], cCodFil + " - " + cCodMat + " - " + cNome + ": " + cMsg ) // Filial, Matrícula e descrição da mensagem.

Return .T.
