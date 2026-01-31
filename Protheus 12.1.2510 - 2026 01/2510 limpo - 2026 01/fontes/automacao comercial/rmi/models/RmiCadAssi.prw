#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RMIASSINANTE.CH"

Static cBkpLayFil   := ""
Static lWizard      := .F.

Static lStRmixFil   := existFunc("rmixFilial")                      //Verifica se existe a função que vai retornar as filiais
Static cStCmpFil    := iif(lStRmixFil, "MHP_LAYFIL", "MHP_FILPRO")  //Campo com as filiais utilizadas para processamento
Static lStCmpFil    := .T. //Verifica se o campo de filiais é obrigatório

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCadAssi
Cadastro de Assinantes

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCadAssi()

	Local oBrowse := Nil

    If AmIIn(12)// Acesso apenas para modulo e licença do Varejo
        oBrowse := FWMBrowse():New()
        oBrowse:SetDescription(STR0001)    //"Assinantes"
        oBrowse:SetAlias("MHO")
        oBrowse:SetLocate()
        oBrowse:Activate()
    else
        MSGALERT(STR0011)// "Esta rotina deve ser executada somente pelo módulo 12 (Controle de Lojas)"
        LjGrvLog("RMICADASSI",STR0011)
    EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd(aRotina, { STR0002, "PesqBrw"             , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd(aRotina, { STR0003, "VIEWDEF.RMICADASSI", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd(aRotina, { STR0004, "VIEWDEF.RMICADASSI", 0, 3, 0, NIL } ) //"Incluir"
	aAdd(aRotina, { STR0005, "VIEWDEF.RMICADASSI", 0, 4, 0, NIL } ) //"Alterar"
	aAdd(aRotina, { STR0006, "VIEWDEF.RMICADASSI", 0, 5, 0, NIL } ) //"Excluir"
	aAdd(aRotina, { STR0007, "VIEWDEF.RMICADASSI", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := Nil
	Local oModel     := FWLoadModel("RMICADASSI")
	Local oStructMHO := FWFormStruct(2, "MHO")
    Local oStructMHP := FWFormStruct(2, "MHP")

    oStructMHP:RemoveField("MHP_CASSIN")

    if lStRmixFil
        oStructMHP:RemoveField("MHP_FILPRO")

        oStructMHP:SetProperty("MHP_LAYFIL", MVC_VIEW_TITULO, "Filiais")
        oStructMHP:SetProperty("MHP_LAYFIL", MVC_VIEW_ORDEM , "06"     )
        //oStructMHP:SetProperty("MHP_LAYFIL", MVC_VIEW_LOOKUP, "RMISM0")
    else

        oStructMHP:RemoveField("MHP_LAYFIL")
    endIf
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription(STR0001)    //"Assinantes"

    oView:AddUserButton( 'Atualizar Senha' + IIF(Alltrim(MHO->MHO_COD) == "PDVSYNC",' RAC',''), 'CLIPS', { |oView| AltSenha()},,,{MODEL_OPERATION_UPDATE} )
	oView:AddField("RMICADASSI_FIELD_MHO", oStructMHO, "MHOMASTER")
	oView:AddGrid("RMICADASSI_GRID_MHP"  , oStructMHP, "MHPDETAIL")

	oView:CreateHorizontalBox("FORMFIELD", 40)
    oView:CreateHorizontalBox("FORMGRID" , 60)

	oView:SetOwnerView("RMICADASSI_FIELD_MHO", "FORMFIELD")
    oView:SetOwnerView("RMICADASSI_GRID_MHP" , "FORMGRID" )

    oView:EnableTitleView("RMICADASSI_FIELD_MHO", STR0001)    //"Assinantes"
    oView:EnableTitleView("RMICADASSI_GRID_MHP" , STR0008)    //"Assinantes x Processos"

	oView:EnableControlBar(.T.)

    if lStRmixFil
        oView:AddUserButton(STR0025, "BUDGET", { |oView| btnFiliais(.F.) }, /*cToolTip*/, /*nShortCut*/, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}, .T.)   //"Selecionar Filiais"
    endIf        

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0

@obs MHOMASTER - Assinantes
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := Nil
	Local oStructMHO := FWFormStruct(1, "MHO")
    Local oStructMHP := FWFormStruct(1, "MHP")

	//----------------------------------------- 
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New("RMICADASSI", /*Pre-Validacao*/,{|oModel|LjLayVld(oModel)} /*Pos-Validacao*/, { |oModel| RmiCommit(oModel)}, { || RmiCancMdl()})
    oModel:SetDescription(STR0009)  //"Modelo de dados dos Assinantes"

    oStructMHO:SetProperty("MHO_COD",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "ExistChav('MHO', M->MHO_COD, 1) .AND. SHPLayouts(M->MHO_COD)"  ) ) //Definindo Valid do assinante para carga dos layouts via Github
    oStructMHO:SetProperty("MHO_CONFIG",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "PSHVldCpt()") ) //Definindo validaçao do campo para alteração de senha criptografada.

	oModel:AddFields("MHOMASTER", Nil, oStructMHO, /*Pre-Validacao*/, /*Pos-Validacao*/)
    oModel:GetModel("MHOMASTER"):SetDescription(STR0001) 	//"Assinantes"

    oModel:AddGrid("MHPDETAIL", "MHOMASTER", oStructMHP, /*bLinePre*/, {|oModelMHP, nLinha| ValLinMHP(oModelMHP, nLinha)}, /*bPre*/, /*bPost*/)
	oModel:GetModel("MHPDETAIL"):SetDescription(STR0008)    //"Assinantes x Processos"
	oModel:SetRelation("MHPDETAIL", { { "MHP_FILIAL", "MHO_FILIAL" }, { "MHP_CASSIN", "MHO_COD" } }, MHP->( IndexKey(1) ))    //MHP_FILIAL+MHP_CASSIN+MHP_CPROCE
	oModel:GetModel("MHPDETAIL"):SetUniqueLine( {"MHP_CPROCE","MHP_TIPO"} )
    
    If lStRmixFil .and. !fwIsInCallStack("pshWizCfg")
        //Executar função ao clicar duas vezes no campo MHP_LAYFIL
        oStructMHP:SetProperty( 'MHP_LAYFIL' , MODEL_FIELD_WHEN, {|oModel| btnFiliais(.T.) })
    EndIf    

    oModel:SetActivate( {|oModel| Carga(oModel),FilLoad(oModel)} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Carga
Rotina que ira efetuar a carga dos processos padrões na inclusão de um 
novo Assinante.

@author  Rafael Tenorio da Costa
@since   29/10/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Carga(oModel)

    Local aArea      := GetArea()
    Local aProcessos := {}
    Local nProc      := 1
    Local lRetorno   := .T.
    Local cQuery     := ""
    Local cSQL       := ""

    If oModel:GetOperation() == MODEL_OPERATION_INSERT

        oModelMHP  := oModel:GetModel("MHPDETAIL")

        cQuery := "FROM " + RetSqlName("MHN") + " WHERE MHN_FILIAL = '" + xFilial("MHN") + "' AND D_E_L_E_T_ = ' ' "

        cSQL := "SELECT MHN_COD , '1' AS TIPO " + cQuery
        cSQL += "UNION SELECT MHN_COD , '2' AS TIPO "+cQuery+" ORDER BY MHN_COD"
        LjGrvLog("RMICADASSI","Antes de RmiXSql",cSQL)
        aProcessos := RmiXSql(cSQL, "*", /*lCommit*/, /*aReplace*/)
        LjGrvLog("RMICADASSI","Depois de RmiXSql",aProcessos)

        For nProc:=1 To Len(aProcessos)

            If nProc > 1
                lRetorno := oModelMHP:AddLine() >= nProc
            EndIf
            
            If lRetorno
                oModelMHP:LoadValue("MHP_CPROCE", aProcessos[nProc][1])
                oModelMHP:LoadValue("MHP_TIPO", aProcessos[nProc][2])
                oModelMHP:LoadValue("MHP_ATIVO" , "2")                      //1=Sim,2=Não
            Else
                Exit
            EndIf
        Next nProc

        aSize(aProcessos, 0)
    EndIf

    RestArea(aArea)

Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} ValLinMHP
Valida linha do grid MHP - Assinantes x Processos

@author Rafael Tenorio da Costa
@since  09/06/2016
/*/
//-------------------------------------------------------------------
Static Function ValLinMHP(oModelMHP, nLinha)
	
    Local oModel    := FwModelActive()
	Local lRetorno  := .T.
    Local cFilPro   := ""
    Local aFilPro   := {}
    Local nCont     := 0
    Local cJLayout  := Nil
    Local oJson     := JsonObject():New()
    Local cGetJson  := ""

    //Valida se a linha não esta deletada
    If !oModelMHP:IsDeleted(nLinha) .and. oModelMHP:getValue("MHP_ATIVO", nLinha) == "1"

        cFilPro := allTrim( strTran( oModelMHP:GetValue(cStCmpFil, nLinha), CRLF, "") )

        if empty(cFilPro) .and. !fwIsInCallStack("pshWizCfg") .AND. lStCmpFil
            lRetorno := .F.

            oModel:SetErrorMessage("MHPDETAIL", cStCmpFil, "MHPDETAIL", cStCmpFil, AllTrim( GetSX3Cache(cStCmpFil, "X3_TITULO") ), STR0026, "")     //"Não foi selecionada nenhuma filial."
        else

            If SubStr(cFilPro, Len(cFilPro)) <> ";"
                cFilPro := cFilPro + ";"
            EndIf            

            aFilPro := StrToKarr(cFilPro, ";")

            For nCont:=1 To Len(aFilPro)

                If !FwFilExist(/*cGrpCompany*/, aFilPro[nCont])
                    lRetorno := .F.
                    oModel:SetErrorMessage("MHPDETAIL", cStCmpFil, "MHPDETAIL", cStCmpFil, AllTrim( GetSX3Cache(cStCmpFil, "X3_TITULO") ), I18n(STR0010, {aFilPro[nCont]}), "")    //"Filial (#1) inválida, verifique."
                    LjGrvLog("RMICADASSI", STR0010, aFilPro[nCont])
                EndIf

            Next nCont
        endIf

        If lRetorno .And. Len(aFilPro) > 0
            oModelMHP:LoadValue(cStCmpFil, cFilPro)
        EndIf
        
        If lRetorno
            cGetJson := oModelMHP:GetValue("MHP_CONFIG", nLinha)
            cJLayout := oJson:FromJson(cGetJson)
            
            If cJLayout != Nil .AND. !Empty(cGetJson) .AND. SubStr(cGetJson,1,1) == "{"
                lRetorno := .F.
                oModel:SetErrorMessage("MHPDETAIL", "MHP_CONFIG", "MHOMASTER", "MHP_CONFIG", AllTrim( GetSX3Cache("MHP_CONFIG", "X3_TITULO") ),I18n("Json inválido verifique a estrutura do campo (#1)", {"MHP_CONFIG"}))
            EndIf
            
            cJLayout := Nil
            cGetJson := oModelMHP:GetValue("MHP_LAYENV", nLinha)
            cJLayout := oJson:FromJson(cGetJson)
            
            If lRetorno
                If cJLayout != Nil .AND. !Empty(cGetJson) .AND. SubStr(cGetJson,1,1) == "{"
                    lRetorno := .F.
                    oModel:SetErrorMessage("MHPDETAIL", "MHP_LAYENV", "MHOMASTER", "MHP_LAYENV", AllTrim( GetSX3Cache("MHP_LAYENV", "X3_TITULO") ),I18n("Json inválido verifique a estrutura do campo (#1)", {"MHP_LAYENV"}))
                EndIf    
            EndIf
            
            cJLayout := Nil 
            cGetJson := oModelMHP:GetValue("MHP_LAYPUB", nLinha)
            cJLayout := oJson:FromJson(cGetJson)
            
            If lRetorno
                If cJLayout != Nil .AND. !Empty(cGetJson) .AND. SubStr(cGetJson,1,1) == "{"
                    lRetorno := .F.
                    oModel:SetErrorMessage("MHPDETAIL", "MHP_LAYPUB", "MHOMASTER", "MHP_LAYPUB", AllTrim( GetSX3Cache("MHP_LAYPUB", "X3_TITULO") ),I18n("Json inválido verifique a estrutura do campo (#1)", {"MHP_LAYPUB"}))
                EndIf    
            EndIf
        EndIf
    EndIf        
	
Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} GatMHP
Gatilho do objeto MHP

@author Danilo Rodrigues 
@since  27/04/2020
/*/
//-------------------------------------------------------------------
Function GatMHP(cFilVenda, cAssinante, cProcesso, lGatilho)

Local aFilPro   := {} //Guarda todas as filiais
Local cCRLF    	:= Chr(13) + Chr(10) //Pula linha 
Local cLayFil   := "" //Monta o Json
Local nCont     := 0 //Variavel de loop
Local oModel    := Nil //Recebe o model da tela
Local oJsonFil  := Nil //Json com as filiais
Local nI        := 0 //Variavel de loop
Local nPos      := 0 //Posicao da filial no Json

Default cAssinante := ""
Default cProcesso  := "" 
Default lGatilho   := .F.

If lGatilho
    oModel := FwModelActive()
    cFilVenda := oModel:GetValue('MHPDETAIL','MHP_FILPRO')
    cAssinante := AllTrim(oModel:GetValue('MHPDETAIL','MHP_CASSIN'))
    cProcesso := AllTrim(oModel:GetValue('MHPDETAIL','MHP_CPROCE'))
    If Empty(cBkpLayFil)
        cBkpLayFil := oModel:GetValue('MHPDETAIL','MHP_LAYFIL')
    EndIf

    LjGrvLog("RMICADASSI","Entrou em lGatilho", {cFilVenda,cAssinante,cProcesso,cBkpLayFil})
EndIf

If SubStr(Alltrim(cFilVenda), Len(Alltrim(cFilVenda))) == ";"
    cFilVenda := SubStr(Alltrim(cFilVenda), 1,Len(Alltrim(cFilVenda))-1)
EndIf
    
aFilPro := StrTokArr2(cFilVenda, ";")
LjGrvLog("RMICADASSI","Conteudo de aFilPro",aFilPro)

If !Empty(cFilVenda) .AND. cAssinante == "CHEF" .AND. cProcesso == "VENDA"
    
    If Len(aFilPro) > 0
        cLayFil := '{"Filiais":['  + cCRLF 
    EndIf

    If !lGatilho

        For nCont := 1 To Len(aFilPro)

            cLayFil += '{'
            cLayFil += '"Filial":' + '"' + aFilPro[nCont] + '",' + cCRLF
            cLayFil += '"Data":' + ' " ",' + cCRLF
            cLayFil += '"Hora":' + ' " "' + cCRLF

            If nCont < Len(aFilPro) 
                cLayFil += '},' + cCRLF
            Else    
                cLayFil += '}' + cCRLF
            EndIf

        Next nCont

    Else

        oJsonFil := JsonObject():New()
        oJsonFil:FromJson(cBkpLayFil)

        For nCont := 1 To Len(aFilPro) 

            nPos := 0

            For nI := 1 To Len( oJsonFil["Filiais"] )
                If oJsonFil["Filiais"][nI]["Filial"] == aFilPro[nCont]
                    nPos := nI
                    Exit
                EndIF
            Next nI
            
            cLayFil += '{'
            cLayFil += '"Filial":' + '"' + aFilPro[nCont] + '",' + cCRLF
            cLayFil += '"Data":' + ' "' + IIF(nPos > 0, oJsonFil["Filiais"][nPos]["Data"]," ") + '",' + cCRLF
            cLayFil += '"Hora":' + ' "' + IIF(nPos > 0, oJsonFil["Filiais"][nPos]["Hora"]," ") + '"' + cCRLF

            If nCont < Len(aFilPro) 
                cLayFil += '},' + cCRLF
            Else    
                cLayFil += '}' + cCRLF
            EndIf

        Next nCont
        
    EndIf
    
    If Len(aFilPro) > 0
        cLayFil += ']}'
    EndIf

EndIf

Return cLayFil

//------------------------------------------------------------------
/*/{Protheus.doc} RmiCommit
Função para Commit do modelo

@author Bruno Almeida
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Static Function RmiCommit(oModel)

    Begin Transaction

        If FWFormCommit( oModel )
            cBkpLayFil := ""
        
            //Carrega processos de envio para o assinante Protheus, a partir dos processos de busca dos outros assinantes.
            If AllTrim( oModel:GetValue("MHOMASTER", "MHO_COD") ) <> "PROTHEUS"
                carProtheus()
            EndIf
        EndIf

    End Transaction

Return .T.


//------------------------------------------------------------------
/*/{Protheus.doc} RmiCancMdl
Função para cancel do modelo

@author Bruno Almeida
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Static Function RmiCancMdl()

cBkpLayFil := ""

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} SHPLayouts
Função para setar a régua de processamento do get dos Layouts

@author Evandro Pattaro
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function SHPLayouts(cAssin)
Local oProcess		:= Nil	//objeto da classe MsNewProcess
Local lRet          := .T.
oProcess := MsNewProcess():New( { ||  lRet := SHPGetLay(cAssin,oProcess)} ,STR0013, STR0014+"..." , .T. ) //#"Baixando Layouts" #"Aguarde"
oProcess:Activate()        

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} SHPGetLay
Função para carregar os layouts de forma automática

@author Evandro Pattaro
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function SHPGetLay(cAssin,oRegua)
    
    Local oGetLay   := Nil
    Local aArea     := GetArea()
    Local aAreaSM0  := SM0->(GetArea())
    Local aLoad     := {{"configuracao_assinante","MHO_CONFIG"},{"configuracao","MHP_CONFIG"},{"envio","MHP_LAYENV"},{"publicacao","MHP_LAYPUB"}}
    Local aTipo     := {"envia_","busca_"}
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0
    Local oModel    := FwModelActive()
    Local oModelMHO := oModel:GetModel("MHOMASTER")
    Local oModelMHP := oModel:GetModel("MHPDETAIL")
    Local lDados    := .F.
    Local lRet      := .T.
    Local cF3       := ""
	Local cPath		:= ""
    Local cGitPast  := SuperGetMv('MV_PSHGIT',.F.,"")   //Adicione o nome da pasta de QA do GitHub exemplo do pdvsync: pdvsync-qa

    If AllTrim(cAssin) $ "VENDA DIGITAL|NAPP" .AND. !IsBlind()
        If "-" $ cAssin
             MsgAlert(STR0021)// O caractere digitado é Inválido '-'.
            Return .F.
        EndIf
        
        If !ConPad1( , , ,'SM0',,,.F.)
            MsgAlert(STR0020)// Filial obrigatoria selecione.
            Return .F.
        else
            cF3 := Alltrim(SM0->M0_CODFIL) //Posicionou no CondPad1
            If !ExistChav('MHO',PadR(Alltrim(cAssin) +"-"+cF3,TAMSX3("MHO_COD")[1]), 1)
                Return .F.    
            EndIf
            oModelMHO:LoadValue("MHO_COD",Alltrim(cAssin) +"-"+cF3)
            M->MHO_COD:= oModelMHO:GetValue("MHO_COD")
        EndIf
    EndIf 
    
    // Tratamento de espaço na URL
    cAssin   := allTrim(Lower(cAssin))
    cGitPast := allTrim(Lower(cGitPast))
    if cAssin $ cGitPast
        cPath := cGitPast
     Else        
        cPath := cAssin
    ENDiF
    
    oGetLay := RmiGetLayObj():New("https://api.github.com/repos/totvs/protheus-smart-hub-layouts/contents/" + (cPath) )

    For nX := 1 to Len(aLoad)            
        oGetLay:GetArq(aLoad[nX,1])
        If oGetLay:lSucesso
            Aadd(aLoad[nX], JsonObject():New())
            aLoad[nX][3]:FromJson(oGetLay:cList)
        Else
            LjGrvLog(" SHPGetLay ",STR0015+" : "+oGetLay:cRetorno) //"Falha na carga da lista dos arquivos de Layout"
            If oGetLay:ogit:oresponseh:cStatuscode == "403"
                IIF(lWizard,Help( ,, 'HELP',, STR0018, 1, 0),MSGALERT(STR0018,""))//"Limite de solicitações excedido. Tente novamente dentro de 1 hora"
            Else
                IIF(lWizard,Help( ,, 'HELP',, STR0015+" "+STR0019, 1, 0),MSGALERT(STR0015+" "+STR0019,""))//"Falha na carga da lista dos arquivos de Layout" "Verifique se o Assinante digitado está correto ou na lista de inclusao automatica no TDN"         
            EndIf    
            Return IIF(lWizard,.F.,.T.)        
        EndIf
        lStCmpFil := .F. //desativa validaçao de filiais para campo novo quando for layoutautomatico
    Next nX

    oModelMHO:SetValue(aLoad[1][2],DecodeUtf8(HttpGet(aLoad[1][3][1]['download_url']))) //JSON de configuração do assinante

    oRegua:SetRegua1(oModelMHP:Length())

    For nX := 1 to oModelMHP:Length()

        oRegua:IncRegua1(STR0016 + oModelMHP:GetValue("MHP_CPROCE"))  //"Analisando processo :"   

        oModelMHP:GoLine(nX)
        lDados := .F.
        If !oModelMHP:IsDeleted()
            oRegua:SetRegua2(Len(aLoad))    
            For nY := 2 To Len(aLoad) //Carga dos arquivos GitHub

                oRegua:IncRegua2(STR0017 + aLoad[nY][1])  //"Carga dos arquivos :"

                For nZ := 1 To Len(aLoad[nY][3]) //Layouts de processos
                    If aTipo[Val(oModelMHP:GetValue("MHP_TIPO"))]+Replace(Replace(Lower(Alltrim(oModelMHP:GetValue("MHP_CPROCE")))," ","_"),"/","_") == Substr(aLoad[nY][3][nZ]['name'],1,At( ".json" , aLoad[nY][3][nZ]['name'] ) - 1)                             
                        lDados := .T.       
                        oModelMHP:SetValue(aLoad[nY][2],DecodeUtf8(HttpGet(aLoad[nY][3][nZ]['download_url'])))
                        oModelMHP:SetValue("MHP_ATIVO",'1')//ativo
                        oModelMHP:SetValue(cStCmpFil, cF3)
                    EndIf                            
                Next nZ
            Next nY
            If !lDados
                oModelMHP:DeleteLine()
            EndIf
        EndIf

    Next nX
RestArea(aAreaSM0)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} carProtheus
Carrega processos de envio para o assinante Protheus, a partir dos processos de busca dos outros assinantes.

@type    Function
@author  Rafael Tenorio da Costa
@since   16/08/23
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static function carProtheus()

    Local aArea     := GetArea()
    Local aAreaMHO  := MHO->( GetArea() )
    Local aAreaMHP  := MHP->( GetArea() )
    Local cProtheus := Padr("PROTHEUS", TamSx3("MHO_COD")[1])
    Local cQuery    := ""
    Local aProcessos:= {}
    Local nCont     := 1

    //Retornar processos de busca ativos
    cQuery := " SELECT MHP_CPROCE"
    cQuery += " FROM " + RetSqlName("MHP")
    cQuery += " WHERE D_E_L_E_T_ = ' '"
    cQuery += " AND MHP_FILIAL = '" + xFilial("MHP") + "'"
    cQuery += " AND MHP_CASSIN <> '" + cProtheus + "'"
    cQuery += " AND MHP_TIPO = '2'"
    cQuery += " AND MHP_ATIVO = '1'"
    cQuery += " GROUP BY MHP_CPROCE"

    aProcessos := RmiXSql(cQuery, "*", /*lCommit*/, /*aReplace*/)

    If Len(aProcessos) > 0

        MHO->( DbSetOrder(1) )  //MHO_FILIAL, MHO_COD, R_E_C_N_O_, D_E_L_E_T_
        If !MHO->( DbSeek( xFilial("MHO") + cProtheus) )

            RecLock("MHO", .T.)
                MHO->MHO_FILIAL := xFilial("MHO")
                MHO->MHO_COD    := cProtheus
            MHO->( MsUnLock() )
        EndIf

        //Deleta processos de envios no Protheus
        MHP->( DbSetOrder(1) )  //MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO, R_E_C_N_O_, D_E_L_E_T_
        While MHP->( DbSeek( xFilial("MHP") + cProtheus ) )
            RecLock("MHP", .F.)
                MHP->( DbDelete() )
            MHP->( MsUnLock() )
        EndDo

        //Cria processos de envios no Protheus, para buscas de outros assinantes
        For nCont:=1 To Len(aProcessos)

            RecLock("MHP", .T.)
                MHP->MHP_FILIAL := xFilial("MHP")
                MHP->MHP_CASSIN := cProtheus
                MHP->MHP_CPROCE := aProcessos[nCont][1]
                MHP->&(cStCmpFil) := cFilAnt + ";"
                MHP->MHP_TIPO   := "1"
                MHP->MHP_ATIVO  := "1"
            MHP->( MsUnLock() )

        Next nCont
    EndIf

    FwFreeArray(aProcessos)

    RestArea(aAreaMHP)
    RestArea(aAreaMHO)
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetWizard
Atualizada Variavel para configuração via Wizard

@type    Function
@since   16/09/23
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function SetWizard(lParam)
lWizard := lParam
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjLayVld
Valida a estrutura do Layout que vai ser gravado nos campos Json

@return  Logico,
@author  Everson S P Junior
@since   02/04/24
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function LjLayVld(oModel)
Local oCab          := oModel:GetModel('MHOMASTER') //Model do cabecalho
Local oJson         := JsonObject():New()
Local lRet          := .T. 
Local cJLayout      := Nil   
Local cConfig       := ""

cConfig  := oCab:GetValue('MHO_CONFIG')
cJLayout := oJson:FromJson(cConfig)

If cJLayout != Nil .AND. !Empty(Alltrim(cConfig)) .AND.  SubStr(Alltrim(cConfig),1,1) == "{"
    lRet := .F.
    oModel:SetErrorMessage("MHOMASTER", "MHO_CONFIG", "MHOMASTER", "MHO_CONFIG", AllTrim( GetSX3Cache("MHO_CONFIG", "X3_TITULO") ),I18n("Json inválido verifique a estrutura do campo (#1)", {"MHO_CONFIG"}))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} btnFiliais
Botão que apresenta tela com as filiais e atualiza campo MHP_LAYFIL

@type    Function
@author  Rafael Tenorio da Costa
@since   14/03/2025
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static function btnFiliais(lWhen)

    Local oModel        := FwModelActive()
    Local oModelMHP     := oModel:GetModel("MHPDETAIL")
    Local nLinhaAtu     := oModelMHP:getLine()
    Local lNotVldSet    := !IsInCallStack("VALIDFIELD")//When é disparado pela VALID do Botão OK do Memo..
    Local cFiliais      := ''
    Local nCont         := 0

    Default lWhen       := .F. //Se for chamado pelo botão do grid, lWhen = .F. se for chamado pelo gatilho do campo MHP_LAYFIL, lWhen = .T.
    
    If !lWhen
        If MSGYESNO(STR0027 + CHR(10) + CHR(13),STR0028) //"Aplicar as filiais selecionadas para todos os processos deste assinante? Isso vai atualizar todas as filiais." "Deseja continuar?"
            cFiliais    := rmixSelFil()
            for nCont := 1 to oModelMHP:length()
                oModelMHP:goLine(nCont)

                oModelMHP:LoadValue("MHP_LAYFIL", IIF(Empty(cFiliais), oModelMHP:getValue("MHP_LAYFIL"),cFiliais))
            next nCont
        EndIf
    ElseIf lNotVldSet 
        If MSGYESNO("Deseja adicionar ou alterar as filiais do processo atual?"+CHR(10)+CHR(13), STR0028) //"Deseja adicionar ou alterar as filiais do processo atual?" "Deseja continuar?
            cFiliais := rmixSelFil() // Quando for VALID não aparecer a tela de seleção de filiais, pois já foi selecionada pelo gatilho do when MHP_LAYFIL
            oModelMHP:LoadValue("MHP_LAYFIL", IIF(Empty(cFiliais), oModelMHP:getValue("MHP_LAYFIL"),cFiliais)) //"Aplicar as filiais selecionadas para linha atual do processo."
        EndIf
    EndIf
    oModelMHP:goLine(nLinhaAtu)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AltSenha
Função para alterar senha do RAC Assinante PdvSync
using namespace totvs.protheus.retail.rmi.wizard.configuracao.VendaDigital
using namespace totvs.protheus.retail.rmi.wizard.configuracao.PdvSync
using namespace totvs.protheus.retail.rmi.wizard.configuracao.IntegTotvsPdv
@type    Function
@author  Everson S P Junior
@since   05/06/23
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function AltSenha()
    
    Local oObjPergunte  := Nil as Object
    Local oNewPag       := Nil as Object	//Objeto que adiciona nova pagina no wizard    
    Local aCoords       := {} as Array

    If alltrim(MHO->MHO_COD) == "PDVSYNC" 
        aCoords := FWGetDialogSize()
        oObjPergunte := FWWizardControl():New( , {aCoords[3] , aCoords[4] * 1.0} )// Define o tamanho do wizard  ex: {600,800}
        oObjPergunte:ActiveUISteps()
        oPdvSync := totvs.protheus.retail.rmi.wizard.configuracao.PdvSync.PdvSync():New("TOTVS Pdv OmniShop")
        
        // 01 ------------------------------Configuração de Solução  
        
        oNewPag := oObjPergunte:AddStep("1")//Adiciona a primeira tela do wizard
        oNewPag:SetStepDescription(STR0001) //Altera a descrição do step    //"Configuração de Solução"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
        oNewPag:SetConstruction({|oPanel|oPdvSync:telaCredenciais(oPanel)}) //Define o bloco de construção
        oNewPag:SetNextAction({||validaCredenciais(oPdvSync:oConfigWiz)})//Define o bloco ao clicar no botão Próximo
        oNewPag:SetCancelAction({|| .T. })//Valida acao cancelar
        oNewPag:SetPrevAction({|| .T. })  //Define o bloco de código que deverá executar ao pressionar o botão Voltar
        
        //Ativa Wizard
        oObjPergunte:Activate()

        //Desativa Wizard
        oObjPergunte:Destroy()
    ElseIf "NAPP" $ Alltrim(MHO->MHO_COD)
        aCoords := FWGetDialogSize()
        oObjPergunte := FWWizardControl():New( , {aCoords[3] , aCoords[4] * 1.0} )
        oObjPergunte:ActiveUISteps()
        oNapp := totvs.protheus.retail.rmi.wizard.configuracao.Napp.Napp():New("TOTVS Venda Digital by Ninegrid", AllTrim(MHO->MHO_COD))

        oNewPag := oObjPergunte:AddStep("1")//Adiciona a primeira tela do wizard
        oNewPag:SetStepDescription(STR0001) //Altera a descrição do step    //"Configuração de Solução"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
        oNewPag:SetConstruction({|oPanel|oNapp:TelaCredenciais(oPanel)}) //Define o bloco de construção
        oNewPag:SetNextAction({||ValidaCredenciais(oNapp:oConfigWiz)})//Define o bloco ao clicar no botão Próximo
        oNewPag:SetCancelAction({|| .T. })//Valida acao cancelar
        oNewPag:SetPrevAction({|| .T. })  //Define o bloco de código que deverá executar ao pressionar o botão Voltar
        
        //Ativa Wizard
        oObjPergunte:Activate()

        //Desativa Wizard
        oObjPergunte:Destroy()
    EndIf    

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} validaCredenciais
    Função de validação da tela de Credenciais do RAC
@author  Everson S P Junior
@version 1.0    
/*/
//-------------------------------------------------------------------
Static function validaCredenciais(oConfigWiz)
Local lRet      := .T.
Local oJson     := JsonObject():New()
Local oModel    := FwModelActive()
Local oModelMHO := oModel:GetModel("MHOMASTER")
Local oRac      := Nil

oJson:FromJson(oModelMHO:GetValue("MHO_CONFIG"))

If oJson:HasProperty("configPSH") .AND. oJson["configPSH"]:HasProperty("criptografado");
 .AND. oJson["configPSH"]['criptografado']  == "S" .AND. Alltrim(oConfigWiz['cPassword']) != Alltrim(oJson["autenticacao"]['password'])


    oRac := totvs.protheus.retail.rmi.classes.pdvsync.PdvSync():New(Alltrim(oConfigWiz['cTenant']), Alltrim(oConfigWiz['cUser']),;
    Alltrim(oConfigWiz['cPassword']), Alltrim(oConfigWiz['cClientId']),   rc4crypt(Alltrim(oConfigWiz['cClientSecret']), SM0->M0_CGC, .F.) , Val(Alltrim(oConfigWiz['cEnvironment'])))       

    If (aMensagem := oRac:Token())[1]
        oJson["autenticacao"]['tenent']      := Alltrim(oConfigWiz['cTenant'])
        oJson["autenticacao"]['user']        := Alltrim(oConfigWiz['cUser'])
        oJson["autenticacao"]['password']    := rc4crypt(Alltrim(oConfigWiz['cPassword']), SM0->M0_CGC, .F.) 
        oJson["autenticacao"]['clientId']    := Alltrim(oConfigWiz['cClientId'])
        oJson["autenticacao"]['clientSecret']:= Alltrim(oConfigWiz['cClientSecret'])
        oJson["autenticacao"]['environment'] := Val(Alltrim(oConfigWiz['cEnvironment']))
        oJson["autenticacao"]["mensagem"] := ""
        oModelMHO:SetValue("MHO_CONFIG",oJson:ToJson()) //JSON de configuração do assinante
        MsgInfo("Senha Atualizada com sucesso!")
    else
        lRet := aMensagem[1]
        oConfigWiz["mensagem"] := aMensagem[2]
        MsgInfo(aMensagem[2])
    EndIf
    
ElseIf oJson:HasProperty("configNAPP")

    oJson["configNAPP"]["usuario"] := Alltrim(oConfigWiz['cUser'])
    oJson["configNAPP"]["senha"]   := Alltrim(oConfigWiz['cPassword'])
    oModelMHO:SetValue("MHO_CONFIG", oJson:ToJson()) //JSON de configuração do assinante
    MsgInfo("Senha Atualizada com sucesso!")

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PSHVldCpt
    Função de validação da tela de Credenciais do RAC

@author  Everson S P Junior
@version 1.0
@since   26/02/25
@version 1.0
/*/
//-------------------------------------------------------------------
Function PSHVldCpt()
Local lRet      := .T.
Local oJson     := Nil
Local oJsonGRV  := Nil
Local oModel    := FwModelActive()
Local oModelMHO := oModel:GetModel("MHOMASTER")
Local cMemoConfig:= oModelMHO:GetValue("MHO_CONFIG")


If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. Alltrim(MHO->MHO_COD) == "PDVSYNC" .AND. !Empty(cMemoConfig) .AND. !Empty(MHO->MHO_CONFIG)
    oJson     := JsonObject():New()
    oJsonGRV  := JsonObject():New() 
    oJson:FromJson(cMemoConfig)
    oJsonGRV:FromJson(MHO->MHO_CONFIG)

    If oJson:HasProperty("configPSH") .AND. oJson["configPSH"]:HasProperty("criptografado") .AND. oJson["autenticacao"]['password'] != oJsonGRV["autenticacao"]['password']
        lRet := .F.
        Help( ,"", 'HELP',,STR0022, 1, 0,,,,,,{STR0023,STR0024})//"Não é permitido alterar a senha do RAC diretamente no Layout" "Acesse o canto superior direito da tela e vá em: Outras Ações -> Atualizar Senha do RAC." "Pressione Ctrl + Z para desfazer a alteração e sair do campo."
    EndIf        
EndIf

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Carga
Rotina que ira efetuar a carga dos processos padrões na inclusão de um 
novo Assinante.

@author  Rafael Tenorio da Costa
@since   29/10/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FilLoad(oModel)

    Local aArea      := GetArea()
    
    Local nProc      := 1
    Local lRetorno   := .T.
  

    If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. lStRmixFil
        oModelMHP  := oModel:GetModel("MHPDETAIL")
        For nProc:=1 To oModelMHP:length()
            oModelMHP:GoLine(nProc)
            If !Empty(oModelMHP:GetValue('MHP_FILPRO'))
                oModelMHP:LoadValue("MHP_LAYFIL", oModelMHP:GetValue('MHP_FILPRO'))
                oModelMHP:LoadValue("MHP_FILPRO", '') //Limpa o campo de filiais
            EndIf    
        Next nProc
    EndIf

    RestArea(aArea)

Return lRetorno
