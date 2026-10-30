#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'PCPA161.CH'

/*/{Protheus.doc} PCPA161()
Monitor Requisição Pendente

@author michele.girardi
@since 09/02/2026
@return Nil
/*/
Function PCPA161()
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("HZ0")
	oBrowse:SetMenuDef("PCPA161") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) //"Monitor Requisições Pendentes"
    oBrowse:SetFilterDefault("HZ0_DTCONL = ' ' .AND. HZ0_HRCONL = ' ' .AND. HZ0_ESTORN = 'N' .AND. HZ0_REQTOT <> 'E' ")
	oBrowse:Activate()
Return NIL

/*/{Protheus.doc} MenuDef()
Menu de Operações MVC

@author Michele Girardi
@since 09/02/2026
@return aRotina - Array com as opções da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.PCPA161" OPERATION OP_VISUALIZAR ACCESS 0  //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION "a161MAnali()"    OPERATION OP_VISUALIZAR ACCESS 0  //"Em Análise"
    ADD OPTION aRotina TITLE STR0004 ACTION "a161GAnali()"    OPERATION OP_VISUALIZAR ACCESS 0  //"Geral - Em Análise"
    ADD OPTION aRotina TITLE STR0005 ACTION "a161GRepro()"    OPERATION OP_VISUALIZAR ACCESS 0  //"Geral - Reprocessar"
    ADD OPTION aRotina TITLE STR0037 ACTION "a161ParIni()"    OPERATION OP_VISUALIZAR ACCESS 0  //"Parâmetros Iniciais"

Return aRotina

/*/{Protheus.doc} ModelDef()
Funcao generica MVC do model

@author Michele Girardi
@since 09/02/2026
@return oModel - Objeto do Modelo MVC
/*/
Static Function ModelDef()
	Local oStructHZ0 := FWFormStruct(1,"HZ0")
	Local oStructHZ1 := FWFormStruct(1,"HZ1")
	Local oModel := MPFormModel():New("PCPA161")

	oModel:AddFields("HZ0MASTER",,oStructHZ0)
    oModel:GetModel("HZ0MASTER"):SetPrimaryKey({"HZ0_SEQ","HZ0_IDENT","HZ0_OP"})

    oStructHZ1:AddField(STR0066							    ,;	// [01]  C   Titulo do campo  //"Descrição"	
	                    STR0066							    ,;	// [02]  C   ToolTip do campo //"Descrição"	
	                    "CDESC"								,;	// [03]  C   Id do Field
	                    "C"									,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_DESC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                    GetSx3Cache("B1_DESC","X3_DECIMAL")	,;	// [06]  N   Decimal do campo
	                    {||.T.}								,;	// [07]  B   Code-block de validação do campo
	                    NIL									,;	// [08]  B   Code-block de validação When do campo
	                    NIL									,;	// [09]  A   Lista de valores permitido do campo
	                    .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                     {||a161desc()} 					,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual
    
    oStructHZ1:AddField(STR0067						    	,;	// [01]  C   Titulo do campo  //"Unidade"	
	                    STR0068						    	,;	// [02]  C   ToolTip do campo //"Unidade de Medida"	
	                    "CUN"								,;	// [03]  C   Id do Field
	                    "C"									,;	// [04]  C   Tipo do campo
	                    GetSx3Cache("B1_UM","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
	                    GetSx3Cache("B1_UM","X3_DECIMAL")	,;	// [06]  N   Decimal do campo
	                    {||.T.}								,;	// [07]  B   Code-block de validação do campo
	                    NIL									,;	// [08]  B   Code-block de validação When do campo
	                    NIL									,;	// [09]  A   Lista de valores permitido do campo
	                    .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
	                     {||a161unid()} 					,;	// [11]  B   Code-block de inicializacao do campo
	                    NIL									,;	// [12]  L   Indica se trata-se de um campo chave
	                    NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                    .T.										)	// [14]  L   Indica se o campo é virtual
    
	oModel:AddGrid("HZ1DETAIL","HZ0MASTER",oStructHZ1)
    oModel:GetModel("HZ1DETAIL"):SetLoadFilter(Nil,"HZ1_PROCES = 'N'",Nil)

	oModel:SetRelation( 'HZ1DETAIL', {;
     { 'HZ1_FILIAL', 'xFilial("HZ1")'},;
     { 'HZ1_SEQ'   , 'HZ0_SEQ'       },;
     { 'HZ1_IDENT' , 'HZ0_IDENT'     },;
     { 'HZ1_OP'    , 'HZ0_OP'        }} , HZ1->(IndexKey(1)) )
	
	oModel:GetModel("HZ0MASTER"):SetDescription(STR0006) //"Apontamentos"
	oModel:GetModel("HZ1DETAIL"):SetDescription(STR0007) //"Requisições Pendentes"

    oModel:SetVldActivate( { |oModel| a161ValPre( oModel) } )

Return oModel

/*/{Protheus.doc} ViewDef()
Funcao generica MVC do View

@author Michele Girardi
@since 09/02/2026
@return oView - Objeto da View MVC
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("PCPA161")
	Local oStructHZ0 := FWFormStruct(2,"HZ0")
	Local oStructHZ1 := FWFormStruct(2,"HZ1") 
	
	oView := FWFormView():New()
	oView:SetModel( oModel )

    oStructHZ1:AddField("CDESC"						    ,;	// [01]  C   Nome do Campo
	                    '06'	  						,;	// [02]  C   Ordem
	                    STR0066				 		    ,;	// [03]  C   Titulo do campo    //'Descrição'
	                    STR0066						    ,;	// [04]  C   Descricao do campo //'Descrição'
	                    NIL								,;	// [05]  A   Array com Help
	                    "N"								,;	// [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_DESC')	    ,;	// [07]  C   Picture
	                    NIL								,;	// [08]  B   Bloco de Picture Var
	                    NIL								,;	// [09]  C   Consulta F3
	                    .F.								,;	// [10]  L   Indica se o campo é alteravel
	                    NIL								,;	// [11]  C   Pasta do campo
	                    NIL								,;	// [12]  C   Agrupamento do campo
	                    NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL								,;	// [15]  C   Inicializador de Browse
	                    .T.								,;	// [16]  L   Indica se o campo é virtual
	                    NIL								,;	// [17]  C   Picture Variavel
	                    NIL								)	// [18]  L   Indica pulo de linha após o campo
    
    oStructHZ1:AddField("CUN"						    ,;	// [01]  C   Nome do Campo
	                    '07'	  						,;	// [02]  C   Ordem
	                    STR0067  				 		,;	// [03]  C   Titulo do campo    //'Unidade'
	                    STR0068 						,;	// [04]  C   Descricao do campo //'Unidade de Medida'
	                    NIL								,;	// [05]  A   Array com Help
	                    "N"								,;	// [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_UM')	        ,;	// [07]  C   Picture
	                    NIL								,;	// [08]  B   Bloco de Picture Var
	                    NIL								,;	// [09]  C   Consulta F3
	                    .F.								,;	// [10]  L   Indica se o campo é alteravel
	                    NIL								,;	// [11]  C   Pasta do campo
	                    NIL								,;	// [12]  C   Agrupamento do campo
	                    NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
	                    NIL								,;	// [15]  C   Inicializador de Browse
	                    .T.								,;	// [16]  L   Indica se o campo é virtual
	                    NIL								,;	// [17]  C   Picture Variavel
	                    NIL								)	// [18]  L   Indica pulo de linha após o campo

	oView:AddField("VIEW_HZ0",oStructHZ0,"HZ0MASTER")
	oView:AddGrid("VIEW_HZ1",oStructHZ1,"HZ1DETAIL")

	oView:CreateHorizontalBox("SUPERIOR",30)
	oView:CreateHorizontalBox("INFERIOR",70)

	oView:SetOwnerView("VIEW_HZ0","SUPERIOR")
	oView:SetOwnerView("VIEW_HZ1","INFERIOR")

    oView:AddUserButton(STR0008, "", {|oView| a161MsgLog(oModel)       }, , , {MODEL_OPERATION_VIEW},.T.) //"Inconsistências"
    oView:AddUserButton(STR0009, "", {|oView| a161Reproc(oModel,oView) }, , , {MODEL_OPERATION_VIEW},.T.) //"Reprocessar"
    oView:AddUserButton(STR0010, "", {|oView| a161Analis(oModel,oView) }, , ,                       ,.T.) //"Em Análise"
    oView:AddUserButton(STR0069, "", {|oView| a161Cancel(oModel,oView) }, , ,                       ,.T.) //"Cancelar Requisição"

    //Chave
	oStructHZ1:RemoveField("HZ1_SEQ")
    oStructHZ1:RemoveField("HZ1_IDENT")
    oStructHZ1:RemoveField("HZ1_OP")

    //Campos para ocultar na tela
    oStructHZ1:RemoveField("HZ1_LOTE")
    oStructHZ1:RemoveField("HZ1_SUBLOT")
    oStructHZ1:RemoveField("HZ1_DTVALD")
    oStructHZ1:RemoveField("HZ1_ENDERE")
    oStructHZ1:RemoveField("HZ1_SERIE")
    oStructHZ1:RemoveField("HZ1_OPORIG")
    oStructHZ1:RemoveField("HZ1_NUMSEQ")
    oStructHZ1:RemoveField("HZ1_DTCONL")
    oStructHZ1:RemoveField("HZ1_HRCONL")
Return oView

/*/{Protheus.doc} a161ValPre()
Valida se existe requisição pendente
Se não existir apresentar mensagem e alterar o apontamento para concluído

@author Michele Girardi
@since 01/04/2026
@return lRet - .T. ou .F.
/*/
Function a161ValPre(oModel)
    Local cAlias2 := ""
    Local cMsg    := ""
    Local cQry2   := ""
    Local lRet    := .T.
    Local oExec2  := Nil

    //Buscar os componentes pendentes dos apontaentos
    cQry2 := " SELECT HZ1.R_E_C_N_O_  RECNO "    
    cQry2 += "   FROM " + RetSqlName('HZ1') + " HZ1 "
    cQry2 += "  WHERE HZ1.HZ1_FILIAL   = ? "
    cQry2 += "    AND HZ1.HZ1_SEQ      = ? "
    cQry2 += "    AND HZ1.HZ1_IDENT    = ? "
    cQry2 += "    AND HZ1.HZ1_OP       = ? "
    cQry2 += "    AND HZ1.D_E_L_E_T_   = ' ' "
 
    oExec2 := FwExecStatement():New(cQry2)

    oExec2:setString(1, xFilial("HZ1"))
    oExec2:setString(2, HZ0->HZ0_SEQ)
    oExec2:setString(3, HZ0->HZ0_IDENT)
    oExec2:setString(4, HZ0->HZ0_OP)
    
    cAlias2 := oExec2:OpenAlias()

    If !(cAlias2)->(!Eof())
        a161AtuPnd()
        cMsg := STR0075 //"Não existe requisição pendente para este apontamento. A pendência foi atualizada para concluida e não constará mais no Monitor."
        Help(Nil,Nil,"Help",Nil,cMsg,1,0) 
        lRet := .F.
    EndIf

    (cAlias2)->(DbCloseArea())        
    oExec2:Destroy()
    FreeObj(oExec2)

Return lRet

/*/{Protheus.doc} a161AtuPnd()
Atualizar a pendencia na HZ0 para concluido

@author Michele Girardi
@since 01/04/2026
@return nil
/*/
Function a161AtuPnd()
    Local cAlias   := ""
    Local cQry     := ""
    Local nRecnoZ0 := 0
    Local oExec    := Nil

    cQry := a161RecZ0()

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("HZ0"))
    oExec:setString(2, HZ0->HZ0_SEQ)
    oExec:setString(3, HZ0->HZ0_IDENT)
    oExec:setString(4, HZ0->HZ0_OP)

    cAlias := oExec:OpenAlias()

    If (cAlias)->(!Eof())
        nRecnoZ0 := (cAlias)->RECNO
        dbSelectArea("HZ0")
    	dbGoTo(nRecnoZ0)
        
        RecLock("HZ0", .F.)
	        REPLACE HZ0->HZ0_REQTOT WITH "S"

            If HZ0->HZ0_ENCOP == "N"
                REPLACE HZ0->HZ0_DTCONL WITH Date()
                REPLACE HZ0->HZ0_HRCONL WITH Time()
            EndIf
	    HZ0->(MsUnlock())
    EndIf
    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

Return Nil

/*/{Protheus.doc} a161MAnali()
Altera o campo Em Análise HZ0_ANALIS
Se estiver como S - Altera para N
Se estiver como N - Altera pra S

@author Michele Girardi
@since 10/02/2026
@return lRet - .T. ou .F.
/*/
Function a161MAnali()    
    Local cAlias   := ""
    Local cAnalise := HZ0->HZ0_ANALIS
    Local cMsg     := ""
    Local cNew     := ""
    Local cQry     := ""
    Local lRet     := .T.
    Local nRecnoZ0 := 0

    Local oExec    := Nil

    If cAnalise == "S"
        cMsg := STR0011 //"O apontamento está Em Análise. Deseja ativar o apontamento?"
    Else
        cMsg := STR0012 //"O apontamento está ativo. Deseja enviar para Em Análise?"
    EndIf

    If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0010)) //"Em Análise"
        cNew := Iif (cAnalise == "S","N","S")

        //Busca recno para posicionar a HZ1 e alterar o campo HZ1_ANALIS
        cQry := a161RecZ0()

        oExec := FwExecStatement():New(cQry)
	    oExec:setString(1, xFilial("HZ0"))
        oExec:setString(2, HZ0->HZ0_SEQ)
        oExec:setString(3, HZ0->HZ0_IDENT)
        oExec:setString(4, HZ0->HZ0_OP)

        cAlias := oExec:OpenAlias()

        If (cAlias)->(!Eof())
            nRecnoZ0 := (cAlias)->RECNO

            //Alterar o valor da tela
            dbSelectArea("HZ0")
    	    dbGoTo(nRecnoZ0)

            RecLock("HZ0",.F.)
                REPLACE HZ0->HZ0_ANALIS WITH cNew                   
            HZ0->(MSUNLOCK())        

            //oModel:GetModel("HZ1DETAIL"):LoadValue("HZ1_ANALIS", cNew)
            //oView:Refresh()
        EndIf
        (cAlias)->(DbCloseArea())        
        oExec:Destroy()
        FreeObj(oExec)
    EndIf
Return lRet

/*/{Protheus.doc} a161GAnali()
Realiza a alteração do indicador Em Análise em massa

@author Michele Girardi
@since 10/02/2026
@return lRet - .T. ou .F.
/*/
Function a161GAnali()
    Local aBackRot  := MenuDef() //ACLONE(aRotina)
    Local lRet      := .T.

    PCPA161B()

    aRotina := ACLONE(aBackRot)
Return lRet

/*/{Protheus.doc} a161ParIni()
Realiza o cadastro dos Parâmetros Iniciais

@author Michele Girardi
@since 10/02/2026
@return lRet - .T. ou .F.
/*/
Function a161ParIni()
    Local aBackRot  := MenuDef() //ACLONE(aRotina)
    Local lRet      := .T.

    PCPA161C()

    aRotina := ACLONE(aBackRot)
Return lRet

/*/{Protheus.doc} a161GRepro()
Realiza o reprocessamento da Requisição Pendente em massa

@author Michele Girardi
@since 10/02/2026
@return lRet - .T. ou .F.
/*/
Function a161GRepro()
    Local aBackRot  := MenuDef() //ACLONE(aRotina)
    Local lRet      := .T.

    PCPA161A()

    aRotina := ACLONE(aBackRot)
Return lRet

/*/{Protheus.doc} a161Reproc()
Realiza o reprocessamento da requisição pendente selecionada

@author Michele Girardi
@since 10/02/2026
@param 01: oModel - Objeto do Modelo MVC
@param 02: oView  - Objeto da View MVC
@return lRet - .T. ou .F.
/*/
Function a161Reproc(oModel,oView)
    Local cAlias   := ""
    Local cAlias1  := ""
    Local cAlias3  := ""
    Local cQry     := ""    
    Local cQry1    := ""        
    Local cQry3    := ""
    Local lRet     := .T.
    Local nRecnoZ0 := 0
    Local nRecnoZ1 := 0

    Local oExec    := Nil
    Local oExec1   := Nil

    dbSelectArea("HZ4")
    IF !(HZ4->(dbSeek(xFilial("HZ4"))))
        Help(Nil,Nil,"Help",Nil,STR0013,1,0) //"Parâmetros Iniciais não cadastrado no PCPA161."
        Return .T.
    EndIf

    //Busca Recno HZ0
    cQry1 := a161RecZ0()

    oExec1 := FwExecStatement():New(cQry1)
	oExec1:setString(1,  xFilial("HZ0"))
    oExec1:setString(2,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SEQ"))
    oExec1:setString(3,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_IDENT"))
    oExec1:setString(4,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OP"))

	cAlias1 := oExec1:OpenAlias()

    If (cAlias1)->(!Eof())
        nRecnoZ0 := (cAlias1)->RECNO
        dbSelectArea("HZ0")
    	dbGoTo(nRecnoZ0)

        If HZ0->HZ0_ANALIS = 'S'
            If MsgYesNo(OemToAnsi(STR0014),OemToAnsi(STR0010)) //"O apontamento está Em Análise. Para reprocessar a requisição o apontamento será ativado. Deseja continuar?" //"Em Análise"               
                RecLock("HZ0",.F.)
                    REPLACE HZ0->HZ0_ANALIS WITH "N"                    
                HZ0->(MSUNLOCK())
            Else
                (cAlias1)->(DbCloseArea())        
                oExec1:Destroy()
                FreeObj(oExec1)
                Return .T.
            EndIf
        EndIf
    EndIf
    (cAlias1)->(DbCloseArea())        
    oExec1:Destroy()
    FreeObj(oExec1)

    //Busca Recno HZ1
    cQry := a161RecZ1()

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1,  xFilial("HZ1"))
    oExec:setString(2,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SEQ"))
    oExec:setString(3,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_IDENT"))
    oExec:setString(4,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OP"))
    oExec:setString(5,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_COMP"))
    oExec:setString(6,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOCAL"))
    oExec:setString(7,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_TRT"))
    oExec:setString(8,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOTE"))
    oExec:setString(9,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SUBLOT"))
    oExec:setString(10, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_ENDERE"))
    oExec:setString(11, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SERIE"))
    oExec:setString(12, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OPORIG"))

	cAlias := oExec:OpenAlias()

    If (cAlias)->(!Eof())
        nRecnoZ1 := (cAlias)->RECNO
        dbSelectArea("HZ1")
    	dbGoTo(nRecnoZ1)

        If HZ1->HZ1_PROCES = 'S'
            Help(Nil,Nil,"Help",Nil,STR0063,1,0) //"Requisição já processada."
            (cAlias)->(DbCloseArea())        
            oExec:Destroy()
            FreeObj(oExec)
            Return .T.
        EndIf

        If HZ1->HZ1_ANALIS = 'S'
            If MsgYesNo(OemToAnsi(STR0015),OemToAnsi(STR0010)) //"A Requisição está Em Análise. Para reprocessar a requisição a mesma será ativada. Deseja continuar?" //"Em Análise"          
                RecLock("HZ1",.F.)
                    REPLACE HZ1->HZ1_ANALIS WITH "N"        
                    REPLACE HZ1->HZ1_QTDPRC WITH 0            
                HZ1->(MSUNLOCK())
            Else
                (cAlias)->(DbCloseArea())        
                oExec:Destroy()
                FreeObj(oExec)
                Return .T.
            EndIf
        EndIf
    EndIf
    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

    If nRecnoZ0 != 0 .And. nRecnoZ1 != 0
        a160ProcRP(nRecnoZ0, nRecnoZ1, Nil, 0)

        //Verificar se a requisição foi processada
        cQry3 := " SELECT HZ1.HZ1_PROCES PROCESSADO, HZ1.HZ1_QTDPRC QTDPROC"
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
                Help(Nil,Nil,"Help",Nil,STR0016,1,0) //"Requisição efetivada com sucesso."
                 //Alterar o valor da tela

                oModel:GetModel("HZ1DETAIL"):LoadValue("HZ1_ANALIS", "N")
                oModel:GetModel("HZ1DETAIL"):LoadValue("HZ1_PROCES", "S")
                oModel:GetModel("HZ1DETAIL"):LoadValue("HZ1_QTDPRC", (cAlias3)->QTDPROC)
                oView:Refresh()
            Else
                Help(Nil,Nil,"Help",Nil,STR0017,1,0) //"Requisição não efetivada. Consulte as inconsistências da requisição para maiores detalhes."
            EndIf
        EndIf
        (cAlias3)->(DbCloseArea())        
        oExec3:Destroy()
        FreeObj(oExec3)
    EndIf
Return lRet

/*/{Protheus.doc} a161RecZ0()
Retorna a query montada para buscar o RECNO da HZ0

@author Michele Girardi
@since 21/02/2026
@return cQuery - Query montada
/*/
Static Function a161RecZ0()
    Local cQry1 := ""

    cQry1 := " SELECT HZ0.R_E_C_N_O_ RECNO "
	cQry1 +=   " FROM " + RetSqlName('HZ0') + " HZ0 "
	cQry1 += "  WHERE HZ0.HZ0_FILIAL   = ? "
    cQry1 += "    AND HZ0.HZ0_SEQ      = ? " 
    cQry1 += "    AND HZ0.HZ0_IDENT    = ? " 
    cQry1 += "    AND HZ0.HZ0_OP       = ? "  
	cQry1 += "    AND HZ0.D_E_L_E_T_   = ' ' "

Return cQry1

/*/{Protheus.doc} a161RecZ1()
Retorna a query montada para buscar o RECNO da HZ1

@author Michele Girardi
@since 21/02/2026
@return cQuery - Query montada
/*/
Static Function a161RecZ1()
    Local cQry := ""

    cQry := " SELECT HZ1.R_E_C_N_O_ RECNO "
	cQry +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
	cQry += "  WHERE HZ1.HZ1_FILIAL   = ? "
    cQry += "    AND HZ1.HZ1_SEQ      = ? " 
    cQry += "    AND HZ1.HZ1_IDENT    = ? " 
    cQry += "    AND HZ1.HZ1_OP       = ? "  
    cQry += "    AND HZ1.HZ1_COMP     = ? "  
    cQry += "    AND HZ1.HZ1_LOCAL    = ? "  
    cQry += "    AND HZ1.HZ1_TRT      = ? "  
    cQry += "    AND HZ1.HZ1_LOTE     = ? "  
    cQry += "    AND HZ1.HZ1_SUBLOT   = ? "  
    cQry += "    AND HZ1.HZ1_ENDERE   = ? "  
    cQry += "    AND HZ1.HZ1_SERIE    = ? "  
    cQry += "    AND HZ1.HZ1_OPORIG   = ? "  
	cQry += "    AND HZ1.D_E_L_E_T_   = ' ' "

Return cQry

/*/{Protheus.doc} a161Analis()
Altera o campo Em Análise HZ1_ANALIS
Se estiver como S - Altera para N
Se estiver como N - Altera pra S

@author Michele Girardi
@since 10/02/2026
@param 01: oModel   - Objeto do Modelo MVC
@param 02: oView    - Objeto da View MVC
@return lRet - .T. ou .F.
/*/
Function a161Analis(oModel,oView)    
    Local cAlias   := ""
    Local cAnalise := oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_ANALIS")
    Local cMsg     := ""
    Local cNew     := ""
    Local cQry     := ""
    Local lRet     := .T.
    Local nRecnoZ1 := 0

    Local oExec    := Nil

    If cAnalise == "S"
        cMsg := STR0018 //"A requisição está Em Análise. Deseja ativar a requisição?"
    Else
        cMsg := STR0019 //"A requisição está ativa. Deseja enviar para Em Análise?"
    EndIf

    If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0010)) //"Em Análise"
        cNew := Iif (cAnalise == "S","N","S")

        //Busca recno para posicionar a HZ1 e alterar o campo HZ1_ANALIS
        cQry := a161RecZ1()

        oExec := FwExecStatement():New(cQry)
        oExec:setString(1,  xFilial("HZ1"))
        oExec:setString(2,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SEQ"))
        oExec:setString(3,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_IDENT"))
        oExec:setString(4,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OP"))
        oExec:setString(5,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_COMP"))
        oExec:setString(6,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOCAL"))
        oExec:setString(7,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_TRT"))
        oExec:setString(8,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOTE"))
        oExec:setString(9,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SUBLOT"))
        oExec:setString(10, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_ENDERE"))
        oExec:setString(11, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SERIE"))
        oExec:setString(12, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OPORIG"))

        cAlias := oExec:OpenAlias()

        If (cAlias)->(!Eof())
            nRecnoZ1 := (cAlias)->RECNO

            //Alterar o valor da tela
            dbSelectArea("HZ1")
    	    dbGoTo(nRecnoZ1)

            RecLock("HZ1",.F.)
                REPLACE HZ1->HZ1_ANALIS WITH cNew       
                REPLACE HZ1->HZ1_QTDPRC WITH 0            
            HZ1->(MSUNLOCK())        

            oModel:GetModel("HZ1DETAIL"):LoadValue("HZ1_ANALIS", cNew)
            oView:Refresh()
        EndIf

        (cAlias)->(DbCloseArea())        
        oExec:Destroy()
        FreeObj(oExec)
    EndIf
Return lRet

/*/{Protheus.doc} a161MsgLog()
Abre tela para apresentar os logs de inconsistências daquela
requisição pendente

@author Michele Girardi
@since 09/02/2026
@param 01: oModel - Objeto do Modelo MVC
@return lRet - .T. ou .F.
/*/
Function a161MsgLog(oModel)
    Local aLogs    := {}
    Local cAlias   := ""
    Local cQry     := ""
    Local lRet     := .T.

    Local oExec    := Nil

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
    oExec:setString(2,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SEQ"))
    oExec:setString(3,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_IDENT"))
    oExec:setString(4,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OP"))
    oExec:setString(5,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_COMP"))
    oExec:setString(6,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOCAL"))
    oExec:setString(7,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_TRT"))
    oExec:setString(8,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOTE"))
    oExec:setString(9,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SUBLOT"))
    oExec:setString(10, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_ENDERE"))
    oExec:setString(11, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SERIE"))
    oExec:setString(12, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OPORIG"))

	cAlias := oExec:OpenAlias()

    While (cAlias)->(!Eof())

        aAdd(aLogs,{(cAlias)->MSGLOG, STOD((cAlias)->DATALOG), (cAlias)->HORALOG, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_COMP") })
        (cAlias)->(dbSkip())
    End

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

    If Len(aLogs) > 0
        a161GridLg(aLogs)
    Else
        Help(Nil,Nil,"Help",Nil,STR0020,1,0) //"Não existe mensagem de inconsistência para esta requisição pendente."
    EndIf
Return lRet

/*/{Protheus.doc} a161GridLg()
Abre tela para apresentar os logs de inconsistências daquela
requisição pendente

@author Michele Girardi
@since 09/02/2026
@param 01: aLogs - Array com os erros
@return nil
/*/
Static Function a161GridLg(aLogs)
    Local cTitulo  := STR0021 + aLogs[1,4] //"Inconsistências do Processamento da Requisição Pendente - "
    Local oDlgUpd
    Local oList

    DEFINE DIALOG oDlgUpd TITLE cTitulo FROM 0, 0 TO 350,780  PIXEL 

	oList := TWBrowse():New( 01, 01, 390,170,,{STR0022,STR0023,STR0024},,oDlgUpd,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"Data" //"Hora" //"Inconsistência"

	oList:SetArray(aLogs)
	oList:bLine := {|| {aLogs[oList:nAT,2],aLogs[oList:nAT,3],aLogs[oList:nAt,1]}}

	ACTIVATE DIALOG oDlgUpd CENTER
Return Nil

/*/{Protheus.doc} A161TOTPEN()
Função que calcula a qtd total de requisições pendentes

@author Michele Girardi
@since 09/02/2026
@return nQtd - Quantidade de requisições que ainda estão pendentes para o apontamento
/*/
Function A161TOTPEN()
    Local cAlias   := ""
    Local cQry     := ""
    Local nQtd     := 0

    Local oExec    := Nil

    cQry := " SELECT COUNT(*) COUNTZ1 "
	cQry +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
	cQry += "  WHERE HZ1.HZ1_FILIAL   = ? "
    cQry += "    AND HZ1.HZ1_SEQ      = ? " 
    cQry += "    AND HZ1.HZ1_IDENT    = ? " 
    cQry += "    AND HZ1.HZ1_OP       = ? "  
    cQry += "    AND HZ1.HZ1_PROCES   = 'N' " 
	cQry += "    AND HZ1.D_E_L_E_T_   = ' ' "

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("HZ1"))
    oExec:setString(2, HZ0->HZ0_SEQ)
    oExec:setString(3, HZ0->HZ0_IDENT)
    oExec:setString(4, HZ0->HZ0_OP)

	cAlias := oExec:OpenAlias()

	If (cAlias)->COUNTZ1 > 0
        nQtd := (cAlias)->COUNTZ1
    EndIf

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)
Return nQtd

/*/{Protheus.doc} A161TOTREQ()
Função que calcula a qtd total de requisições efetivas

@author Michele Girardi
@since 09/02/2026
@return nQtd - Quantidade de requisições pendentes já efetivadas para o apontamento
/*/
Function A161TOTREQ()
    Local cAlias   := ""
    Local cQry     := ""
    Local nQtd     := 0

    Local oExec    := Nil

    cQry := " SELECT COUNT(*) COUNTZ1 "
	cQry +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
	cQry += "  WHERE HZ1.HZ1_FILIAL   = ? "
    cQry += "    AND HZ1.HZ1_SEQ      = ? " 
    cQry += "    AND HZ1.HZ1_IDENT    = ? " 
    cQry += "    AND HZ1.HZ1_OP       = ? "  
    cQry += "    AND HZ1.HZ1_PROCES   = 'S' "  
	cQry += "    AND HZ1.D_E_L_E_T_   = ' ' "

    oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("HZ1"))
    oExec:setString(2, HZ0->HZ0_SEQ)
    oExec:setString(3, HZ0->HZ0_IDENT)
    oExec:setString(4, HZ0->HZ0_OP)

	cAlias := oExec:OpenAlias()

	If (cAlias)->COUNTZ1 > 0
        nQtd := (cAlias)->COUNTZ1
    EndIf

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)
Return nQtd

/*/{Protheus.doc} a161Cancel()
Cancela a requisição pendente

@author Michele Girardi
@since 10/02/2026
@return lRet - .T. ou .F.
/*/
Function a161Cancel(oModel,oView)   
    Local cAlias     := ""
    Local cAlias1    := ""
    Local cAlias3    := ""
    Local cIdentZ1   := ""
    Local cMsg       := ""    
    Local cOpZ1      := ""
    Local cQry       := ""
    Local cQry1      := ""
    Local cQry3      := ""
    Local cSeqLog    := ""
    Local cSeqZ1     := ""
    Local lAtuD4     := .F.
    Local lRet       := .T.
    Local nQtdAtuB2  := 0
    Local nQtdAtuD4  := 0    
    Local nQtdReq    := 0
    Local nRecD4     := 0    
    Local nRecnoZ0   := 0
    Local nRecnoZ1   := 0

    Local oExec      := Nil
    Local oExec1     := Nil
    Local oExec3     := Nil

    cMsg := STR0070 //"Deseja cancelar a requisição pendente? Após o cancelamento não será mais possível incluir novamente a requisição pendente cancelada." 
    If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0071))  //"Cancelamento"

        cMsg := STR0072 //"Deseja atualizar o saldo do empenho desta requisição que será cancelada?"
        If MsgYesNo(OemToAnsi(cMsg),OemToAnsi(STR0071))  //"Cancelamento"
            lAtuD4 := .T.
        EndIf

        cSeqZ1   := oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SEQ")
        cIdentZ1 := oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_IDENT")
        cOpZ1    := oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OP")

        Begin Transaction
            //Busca Recno HZ1
            cQry := a161RecZ1()

            oExec := FwExecStatement():New(cQry)
	        oExec:setString(1,  xFilial("HZ1"))
            oExec:setString(2,  cSeqZ1)
            oExec:setString(3,  cIdentZ1)
            oExec:setString(4,  cOpZ1)
            oExec:setString(5,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_COMP"))
            oExec:setString(6,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOCAL"))
            oExec:setString(7,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_TRT"))
            oExec:setString(8,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOTE"))
            oExec:setString(9,  oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SUBLOT"))
            oExec:setString(10, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_ENDERE"))
            oExec:setString(11, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_SERIE"))
            oExec:setString(12, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OPORIG"))

	        cAlias := oExec:OpenAlias()

            If (cAlias)->(!Eof())
                nRecnoZ1 := (cAlias)->RECNO
                dbSelectArea("HZ1")
    	        dbGoTo(nRecnoZ1)

                RecLock("HZ1",.F.)
                    REPLACE HZ1->HZ1_PROCES WITH "C"
                HZ1->(MSUNLOCK())

                oModel:GetModel("HZ1DETAIL"):LoadValue("HZ1_PROCES", "S")
                
                //Grava mensagem de log
                cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")                
                cMsg := STR0073 + CUSERNAME + "." //"Requisição pendente cancelada manualmente pelo Monitor - PCPA161, pelo usuário " 
                
                dbselectarea("HZ3")
                RecLock("HZ3",.T.)
                    REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
                    REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
                    REPLACE HZ3->HZ3_SEQ 		WITH cSeqZ1
                    REPLACE HZ3->HZ3_IDENT		WITH cIdentZ1
                    REPLACE HZ3->HZ3_OP		    WITH cOpZ1
                    REPLACE HZ3->HZ3_COMP	    WITH HZ1->HZ1_COMP
                    REPLACE HZ3->HZ3_TRT	    WITH HZ1->HZ1_TRT
                    REPLACE HZ3->HZ3_LOCAL	    WITH HZ1->HZ1_LOCAL
                    REPLACE HZ3->HZ3_LOTE	    WITH HZ1->HZ1_LOTE
                    REPLACE HZ3->HZ3_SUBLOT	    WITH HZ1->HZ1_SUBLOT
                    REPLACE HZ3->HZ3_DTVALD	    WITH HZ1->HZ1_DTVALD
                    REPLACE HZ3->HZ3_ENDERE	    WITH HZ1->HZ1_ENDERE
                    REPLACE HZ3->HZ3_SERIE	    WITH HZ1->HZ1_SERIE 
                    REPLACE HZ3->HZ3_OPORIG	    WITH HZ1->HZ1_OPORIG
                    REPLACE HZ3->HZ3_MSG	    WITH cMsg
                    REPLACE HZ3->HZ3_DTLOG	    WITH Date()
                    REPLACE HZ3->HZ3_HRLOG	    WITH Time()
                HZ3->(MSUNLOCK())
                ConfirmSX8()

                //Verificar se todas foram efetivadas e atualizar o campo HZ0_REQTOT para indicar que foram processadas todas requisições
                cQry1 := " SELECT COUNT(1) COUNTZ1 "
                cQry1 +=   " FROM " + RetSqlName('HZ1') + " HZ1 "
                cQry1 += "  WHERE HZ1.HZ1_FILIAL   = ? "
                cQry1 += "    AND HZ1.HZ1_SEQ      = ? "
                cQry1 += "    AND HZ1.HZ1_IDENT    = ? "
                cQry1 += "    AND HZ1.HZ1_OP       = ? "
                cQry1 += "    AND HZ1.HZ1_PROCES   = 'N' "        
                cQry1 += "    AND HZ1.D_E_L_E_T_   = ' ' "

                oExec1 := FwExecStatement():New(cQry1)
                oExec1:setString(1, xFilial("HZ1"))
                oExec1:setString(2, cSeqZ1)
                oExec1:setString(3, cIdentZ1)
                oExec1:setString(4, cOpZ1)

                cAlias1 := oExec1:OpenAlias()

                If (cAlias1)->COUNTZ1 == 0

                    cQry3 := a161RecZ0()

                    oExec3 := FwExecStatement():New(cQry3)
                    oExec3:setString(1, xFilial("HZ0"))
                    oExec3:setString(2, cSeqZ1)
                    oExec3:setString(3, cIdentZ1)
                    oExec3:setString(4, cOpZ1)

                    cAlias3 := oExec3:OpenAlias()

                    If (cAlias3)->(!Eof())
                        nRecnoZ0 := (cAlias3)->RECNO

                        //Alterar o valor da tela
                        dbSelectArea("HZ0")
                        dbGoTo(nRecnoZ0)
                    
                        RecLock("HZ0", .F.)
                            REPLACE HZ0->HZ0_REQTOT WITH "S"

                            If HZ0->HZ0_ENCOP == "N"
                                REPLACE HZ0->HZ0_DTCONL WITH Date()
                                REPLACE HZ0->HZ0_HRCONL WITH Time()
                            EndIf
                        HZ0->(MsUnlock())
                    EndIf
                    (cAlias3)->(DbCloseArea())        
                    oExec3:Destroy()
                    FreeObj(oExec3)
                EndIf
                (cAlias1)->(DbCloseArea())        
                oExec1:Destroy()
                FreeObj(oExec1)

                If lAtuD4
                    nRecD4 := a161RecD4(oModel)
                    dbSelectArea("SD4")
                    dbGoTo(nRecD4)

                    nQtdReq  := oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_QTD")

                    nQtdAtuD4  := Iif (nQtdReq <= SD4->D4_QUANT, nQtdReq, SD4->D4_QUANT)

                    RecLock("SD4",.F.)
                        Replace D4_QTDEORI With D4_QTDEORI - nQtdAtuD4
                        Replace D4_QUANT   With D4_QUANT   - nQtdAtuD4
                    MsUnLock()

                    If SD4->D4_QTDEORI == 0 .And. SD4->D4_QUANT == 0
                        RecLock("SD4",.F.,.T.)
                            SD4->(dbDelete())
                        SD4->(MsUnLock())
                    EndIf

                    SB2->(dbSelectArea("SB2"))
                    SB2->(dbSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL))

                    nQtdAtuB2  := Iif (SB2->B2_QEMP >= nQtdAtuD4, nQtdAtuD4, SB2->B2_QEMP)

                    RecLock("SB2",.F.)
                        Replace B2_QEMP  With B2_QEMP - nQtdAtuB2
                    MsUnlock()

                    //Grava mensagem de log
                    cSeqLog := GETSXENUM("HZ3","HZ3_SEQLOG")                
                    cMsg := STR0074 + CUSERNAME + "." //"Empenho atualizado ao cancelar a Requisição Pendente pelo usuário " 
                
                    dbselectarea("HZ3")
                    RecLock("HZ3",.T.)
                        REPLACE HZ3->HZ3_FILIAL 	WITH xFilial("HZ3")
                        REPLACE HZ3->HZ3_SEQLOG     WITH cSeqLog
                        REPLACE HZ3->HZ3_SEQ 		WITH cSeqZ1
                        REPLACE HZ3->HZ3_IDENT		WITH cIdentZ1
                        REPLACE HZ3->HZ3_OP		    WITH cOpZ1
                        REPLACE HZ3->HZ3_COMP	    WITH HZ1->HZ1_COMP
                        REPLACE HZ3->HZ3_TRT	    WITH HZ1->HZ1_TRT
                        REPLACE HZ3->HZ3_LOCAL	    WITH HZ1->HZ1_LOCAL
                        REPLACE HZ3->HZ3_LOTE	    WITH HZ1->HZ1_LOTE
                        REPLACE HZ3->HZ3_SUBLOT	    WITH HZ1->HZ1_SUBLOT
                        REPLACE HZ3->HZ3_DTVALD	    WITH HZ1->HZ1_DTVALD
                        REPLACE HZ3->HZ3_ENDERE	    WITH HZ1->HZ1_ENDERE
                        REPLACE HZ3->HZ3_SERIE	    WITH HZ1->HZ1_SERIE 
                        REPLACE HZ3->HZ3_OPORIG	    WITH HZ1->HZ1_OPORIG
                        REPLACE HZ3->HZ3_MSG	    WITH cMsg
                        REPLACE HZ3->HZ3_DTLOG	    WITH Date()
                        REPLACE HZ3->HZ3_HRLOG	    WITH Time()
                    HZ3->(MSUNLOCK())
                    ConfirmSX8()
                EndIf                    
            EndIf
            (cAlias)->(DbCloseArea())        
            oExec:Destroy()
            FreeObj(oExec)

        End Transaction
    EndIf
Return lRet

/*/{Protheus.doc} a161RecD4()
Retorna o recno da SD4 para atualização do saldo para o cancelamento

@author michele.girardi
@since 12/03/2026
@return: nRecD4 - Recno da SD4
/*/
Function a161RecD4(oModel)    
    Local cAlias  := ""
    Local cQry    := ""
    Local nRecD4  := 0
    Local oExec   := Nil

    cQry := " SELECT SD4.R_E_C_N_O_  RECNO"
	cQry +=   " FROM " + RetSqlName('SD4') + " SD4 "
	cQry += "  WHERE SD4.D4_FILIAL  = ? "
    cQry += "    AND SD4.D4_OP      = ? "
    cQry += "    AND SD4.D4_COD     = ? "        
    cQry += "    AND SD4.D4_LOCAL   = ? "        
    cQry += "    AND SD4.D4_TRT     = ? "        
    cQry += "    AND SD4.D4_OPORIG  = ? "        
	cQry += "    AND SD4.D_E_L_E_T_ = ' ' "

	oExec := FwExecStatement():New(cQry)
	oExec:setString(1, xFilial("SD4"))
    oExec:setString(2, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OP"))
    oExec:setString(3, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_COMP"))
    oExec:setString(4, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_LOCAL"))
    oExec:setString(5, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_TRT"))
    oExec:setString(6, oModel:GetModel("HZ1DETAIL"):GetValue("HZ1_OPORIG"))

	cAlias := oExec:OpenAlias()

    If (cAlias)->(!Eof())
        nRecD4 := (cAlias)->RECNO
    EndIf

    (cAlias)->(DbCloseArea())        
    oExec:Destroy()
    FreeObj(oExec)

Return nRecD4

/*/{Protheus.doc} a161desc()
Retorna a descrição do componente

@author michele.girardi
@since 17/03/2026
@return: cDesc - Descrição do componente
/*/
Function a161desc()
    Local cDesc := ""

    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+HZ1->HZ1_COMP))

    cDesc := SB1->B1_DESC

Return cDesc

/*/{Protheus.doc} a161unid()
Retorna a unidade de medida do componente

@author michele.girardi
@since 17/03/2026
@return: cUM - Unidade de medida do componente
/*/
Function a161unid()
    Local cUM := ""

    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+HZ1->HZ1_COMP))

    cUM := SB1->B1_UM

Return cUM

