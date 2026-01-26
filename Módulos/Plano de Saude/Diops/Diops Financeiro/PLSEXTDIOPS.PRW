#include "TOTVS.CH"
#include "APWIZARD.CH"
#include "TBICONN.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"
#define ARQ_LOG_DIOPS "extrator_diops_financeiro.log"

#define TAM_CTA_ANS 9   // tamanho da conta contabil plano ANS
#define CHECKED     1   // marca checkbox
#define CODQUADRO   2   // codigo do quadro
#define DESQUADRO   3   // descricao do quadro
#define TABQUADRO   4   // tabela (alias)
#define FNCQUADRO   5   // funcao de execução do extrator 
#define CENQUADRO   6   // codigo do quadro na central de obrigações
#define CENVALID    7   // validacao automatica .T. ou .F. 

#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status ATIVO
#define LIBERADO    "1" // status LIBERADO
#define CRITICADO   "3" // status na Centra de Obrigações 

#define CODOPE      1   // codigo operadora
#define CODOBR      2   // codigo obrigacao DIOPS 
#define ANOREF      3   // ano de referencia DIOPS
#define CODCOMP     4   // codigo compromisso DIOPS

#DEFINE QDR_BALANC	"1"	 // Balancete Trimestral
#DEFINE QDR_CADAST	"2"	 // Dados Cadatrai
#DEFINE QDR_AGIMOB	"3"	 // Ativos Garantidores - Imobiliario
#DEFINE QDR_FLUXCA	"4"	 // Fluxo de Caixa Trimestral
#DEFINE QDR_IDASPA	"5"	 // Idade de Saldos - Contas a Pagar - Passivo
#DEFINE QDR_LUCPRE	"6"	 // Lucros e Prejuízos
#DEFINE QDR_CONEST	"7"	 // Contratos Estipulados"
#DEFINE QDR_CONREP	"8"	 // Segregação do Montante de Contraprestações a Repassar
#DEFINE QDR_COBASS	"9"	 // Cobertura Assistencial
#DEFINE QDR_EVEIND	"11" // Movimentação de Eventos Indenizáveis
#DEFINE QDR_AGRCON	"12" // Agrupamento de Contratos
#DEFINE QDR_PESL	"13" // Saldo da Provisão de Eventos Sinistros a Liquidar
#DEFINE QDR_CCCOOP	"14" // Conta-Corrente Cooperado
#DEFINE QDR_CTRPAS	"15" // Conta Tributo Passivo
#DEFINE QDR_IDASRE	"16" // Idade de Saldos - Contas a Receber - Ativo
#DEFINE QDR_EVECOR	"18" // Eventos em Corresponsabilidade (2018)
#DEFINE QDR_FUNCOM	"19" // Programas-Fundos Comuns de Despesas Assistenciais (2018)
#DEFINE QDR_EVCCC	"20" // Eventos de Contraprestação de Corresponsabilidade Cedid
#DEFINE QDR_MPC		"21" // Modelo Padrão de Capital
#DEFINE QDR_TAP		"22" // Teste de Adequação do Passivo - TAP
#DEFINE QDR_CONPEC	"23" // Contraprestações Pecuniárias.

Static lMarcaTudo	:= .F.

/*/{Protheus.doc} PLSEXTDIOPS
Extrator DIOPS Financeiro
Rotina para executar o wizard das integrações do SIGAPLS com os Quadros da DIOPS da Central de Obrigações
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTDIOPS()
Local aHeader  		:= {}
Local oWizDIOPS     := Nil
Local oMarcaTudo	:= Nil
Local oBold         := Nil
Local oOk 		    := LoadBitmap( GetResources(), "LBOK")
Local oNo			:= LoadBitmap( GetResources(), "LBNO")
Local oPanel        := Nil
Local nI

Private aParDIOPS   := {}
Private aRetDIOPS   := {}
Private aErroDIOPS  := {}
Private aQuadrosDIOPS := {}
Private oQuadrosDIOPS := Nil
Private oResult     := Nil
Private cResult

    // Define atributos da font bold
    DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

     // Wizard de configuração do extrator DIOPS
    DEFINE WIZARD oWizDIOPS TITLE "Extrator DIOPS Financeiro";
        HEADER "Extrator DIOPS Financeiro";
        MESSAGE "Extração de dados simplificada com o Assistente DIOPS Financeiro." ;
        TEXT "As informações financeiras da operadora de planos de assistência à saúde serão extraídas de acordo com a regulamentação vigente."+CRLF+;
                "Essas informações incluem o Plano de Contas adotado pela ANS e outros dados necessários para o preenchimento dos quadros do DIOPS Financeiro."+CRLF+;
                "Na etapa seguinte, serão definidos o compromisso e os quadros específicos que serão atualizados com as informações extraídas."; 
        NEXT {||.T.} ;
        FINISH {||.T.} ;
        PANEL

    // Monta array com o nome dos quadros do DIOPS Financeiro 
    aHeader := {"","Descrição dos Quadros de Detalhamento"}
    aQuadrosDIOPS := fRetQuadrosDIOPS()

    // Painel 2
    CREATE PANEL oWizDIOPS;
        HEADER "DIOPS Financeiro - Operadora e Período do Compromisso";
        MESSAGE "Selecione a operadora e período do compromisso para realizar a atualização.";
        BACK {||.T.} ;
        NEXT {||fValidaParDIOPS()} ;
        PANEL
 
    // Inicializa o array de retorno com o compromisso atual caso esteja criado na central
    aParDIOPS := fIniParDIOPS()
    aRetDIOPS := Array(Len(aParDIOPS))
    For nI := 1 to Len(aRetDIOPS)
        aRetDIOPS[nI] := aParDIOPS[nI,3]
    Next

    // Exilbe os parametros de seleção do usuário 
    ParamBox(aParDIOPS,"", @aRetDIOPS,/*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, oWizDIOPS:GetPanel(2) /*oDlgWizard*/, /*cLoad*/, .F., .F.)

    // Painel 3
    CREATE PANEL oWizDIOPS;
        HEADER "DIOPS Financeiro - Quadros de Detalhamento";
        MESSAGE "Selecione os quadros que serão atualizados com as informações extraídas.";
        BACK {||.T.} ;
        NEXT {|| (IIf(MsgYesNo("Confirma dados selecionados?","Atenção"),;
                    IIf(fExecutaDIOPS(),.T.,.F.),.F.)) } ;
        PANEL
 
        @ 005,005 CHECKBOX oMarcaTudo VAR lMarcaTudo PROMPT 'Marca/Desmarca Todos' SIZE 168, 08	ON CLICK(fMarcaTudo()) OF oWizDIOPS:GetPanel(3) PIXEL

        oQuadrosDIOPS := TWBrowse():New( 1.1, 0.5 , 295, 120,Nil,aHeader, Nil, oWizDIOPS:GetPanel(3), Nil, Nil, Nil,Nil,Nil)      

        oQuadrosDIOPS:SetArray( aQuadrosDIOPS )
        oQuadrosDIOPS:bLDblClick := {|| fMarca() }  

        oQuadrosDIOPS:bLine := {|| {;
                        If( aQuadrosDIOPS[oQuadrosDIOPS:nAt,CHECKED] , oOk , oNo ),;
                            aQuadrosDIOPS[oQuadrosDIOPS:nAt,DESQUADRO];
                        }}        

    // Painel 4
    CREATE PANEL oWizDIOPS;
        HEADER "DIOPS Financeiro - Processo concluído";
        MESSAGE "Verifique abaixo o resultado do processamento e as informações extraídas.";
        BACK {||.F.} ;
        FINISH {||.T.} ;
        PANEL

    // Cria o objeto para exibir o log com o resultado do processamento
    oPanel := TPanelCss():New(001,010,"",oWizDIOPS:GetPanel(4),,.F.,.F.,,,280,130,.T.,.F.)
	oPanel:setCSS("Q3Frame{ border-style:solid; border-color:#FFFFFF; border-bottom-width:1px; border-top-width:1px; background-color:#D6E4EA }")

    // Cria o campo memo onde serão registrados os eventos do processamento
    @ 001,001 GET oResult VAR cResult SIZE 275,125 OF oPanel MULTILINE HSCROLL PIXEL READONLY
	oResult:bRClicked 	:= {||AllwaysTrue()}
	oResult:oFont		:= TFont():New("Courier New",0,16)     
    oResult:Refresh()

    ACTIVATE WIZARD oWizDIOPS CENTERED 
 
Return

/*/{Protheus.doc} VldParDIOPS
Função de chamada da validação dos campos de parâmetros de usuário
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function VldParDIOPS(cCampo)
Local lRet

    Do Case
        Case cCampo=="B8M_CODOPE"   // Cadastro da Operadora
            dbSelectArea("B8M")
            B8M->(dbSetOrder(1))    //B8M_FILIAL+B8M_CODOPE+B8M_CNPJOP
            lRet := B8M->(dbSeek(xFilial("B8M")+aRetDIOPS[CODOPE]))    
        Case cCampo=="B3A_CODIGO"   // Cadastro da Obrigação DIOPS
            dbSelectArea("B3A")
            B3A->(dbSetOrder(1))    //B3A_FILIAL+B3A_CODOPE+B3A_CODIGO
            lRet := B3A->(dbSeek(xFilial("B3A")+aRetDIOPS[CODOPE]+aRetDIOPS[CODOBR])) .And. B3A->B3A_TIPO==DIOPS .And. B3A->B3A_ATIVO==ATIVO
        Case cCampo=="B3D_ANO"      // Ano de Referencia DIOPS
            dbSelectArea("B3D")
            B3D->(dbSetOrder(1))    //B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR
            lRet := B3D->(dbSeek(xFilial("B3D")+aRetDIOPS[CODOPE]+aRetDIOPS[CODOBR]+aRetDIOPS[ANOREF]))
        Case cCampo=="B3D_CODIGO"   // Cadastro do Compromisso DIOPS
            dbSelectArea("B3D")
            B3D->(dbSetOrder(1))    //B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR
            lRet := B3D->(dbSeek(xFilial("B3D")+aRetDIOPS[CODOPE]+aRetDIOPS[CODOBR]+aRetDIOPS[ANOREF]+aRetDIOPS[CODCOMP])) .And. B3D->B3D_TIPOBR==DIOPS .And. B3D->B3D_STATUS<=CRITICADO
    EndCase

    If !lRet
       MsgAlert("Campo informado é inválido.")
    EndIf    

Return lRet

 /*/{Protheus.doc} RetParDIOPS
Retorna parametros de contas contabeis cadastrados no configurador Diops (tabela BRK)
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function RetParDIOPS(cAlias, cItem)
Local aRet := {}

Default cItem := ""   // Opcional

    // Tabela QUADROS DIOPS FINANCEIRO
    dbSelectArea("B3I")       
    B3I->(dbSetOrder(3))    //B3I_FILIAL+B3I_ALIAS

    // Tabela ITENS DOS QUADROS DIOPS FINANC
    dbSelectArea("B3Y")
    B3Y->(dbSetOrder(1))    //B3Y_FILIAL+B3Y_CODIGO+B3Y_ITEM

    // Tabela CONFIGURACAO DOS QUADROS DIOPS
    dbSelectArea("BRK")  
    BRK->(dbSetOrder(1))    //BRK_FILIAL+BRK_CODIGO+BRK_ITEM+BRK_SEQUEN

    If B3I->(dbSeek(xFilial("B3I")+cAlias))
        If B3Y->(dbSeek(xFilial("B3Y")+B3I->B3I_CODIGO))
            BRK->(dbSeek(xFilial("BRK")+B3Y->B3Y_CODIGO))
            While (BRK->BRK_CODIGO==B3Y->B3Y_CODIGO) .And. BRK->(!Eof())
                If Empty(cItem) .Or. Alltrim(cItem)==Alltrim(BRK->BRK_ITEM)
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ aRet                                               ³
                    //³ [1] Codigo do Item 	                               ³
                    //³ [2] Conta Contabil Inicial		                   ³
                    //³ [3] Conta Contabil Final	                       ³
                    //³ [4] Codigo do Identificador                  	   ³
                    //³ [4] Descricao do Identificador                 	   ³        
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                   
                    aAdd(aRet,{ ;
                        Alltrim(BRK->BRK_ITEM)  ,;
                        Alltrim(BRK->BRK_CONTA) ,;
                        Alltrim(BRK->BRK_CCUSTO),;
                        Alltrim(BRK->BRK_DESCRI)})
                EndIf

                BRK->(dbSkip())
            EndDo
        EndIf 
    Endif

Return(aRet)

/*/{Protheus.doc} RetPerDIOPS
Retorna periodo (datas inicial e final) do compromisso Diops Financeiro 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function RetPerDIOPS(cTrimestre,cAno)
Local aRet := {}

    // Array de retorno com data inicial e final do trimestre
    aAdd(aRet,Ctod("01/"+IIf(Substr(cTrimestre,1,1)=="1","01",IIf(Substr(cTrimestre,1,1)=="2","04",IIf(Substr(cTrimestre,1,1)=="3","07","10")))+"/"+cAno))
    aAdd(aRet,LastDay(Ctod("28/"+IIf(Substr(cTrimestre,1,1)=="1","03",IIf(Substr(cTrimestre,1,1)=="2","06",IIf(Substr(cTrimestre,1,1)=="3","09","12")))+"/"+cAno)))

Return(aRet)

/*/{Protheus.doc} fRetQuadrosDIOPS
Função para retornar os nomes dos quadros DIOPS Financeiro 
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetQuadrosDIOPS()
Local aQuadros  := {}
Local aPLSEXT001:= {}
Local nI

    // tabela de atributos dos quadros DIOPS Financeiro (B3I)
    dbSelectArea("B3I")
    B3I->(dbSetOrder(1))    //B3I_FILIAL+B3I_CODIGO
    B3I->(dbGotop())

    While B3I->(!Eof())
        // Adiciona somente os quadros com status = Ativo na tabela do configurador diops financeiro (B3I )
        If B3I->B3I_STATUS == ATIVO
            aAdd(aQuadros,{.F.,B3I->B3I_CODIGO,Alltrim(B3I->B3I_DESCRI),AllTrim(B3I->B3I_ALIAS),AllTrim(B3I->B3I_ROTINA),B3I->B3I_IDQDR,IIf(B3I_TIPVLD=="1",.T.,.F.)})
        EndIf 

        B3I->(dbSkip())
    EndDo

    // P.E. utilizado para manipular o array de quadros DIOPS Financeiro 
    If ExistBlock("PLSEXT001")
       aPLSEXT001 :=  ExecBlock("PLSEXT001", .F., .F., aQuadros)

       If ValType(aPLSEXT001)=="A" .And. Len(aPLSEXT001)>0
            For nI := 1 to Len(aPLSEXT001)
                aAdd(aQuadros, aPLSEXT001[nI])
            Next 
       EndIf
    EndIf 

    If Empty(aQuadros)
        // Caso ainda não tenha executado o Configurador Diops Financeiro 
        aAdd(aQuadros,{.F.,"","","","","",.F.}) 
    EndIf

Return(aQuadros)

/*/{Protheus.doc} fMarca
Função para marcar um item da listbox selecionado pelo usuário 
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fMarca(nItem, lMarca)
Default nItem   := oQuadrosDIOPS:nAt
Default lMarca  := Nil

    aQuadrosDIOPS[nItem,CHECKED] := Iif(lMarca == Nil,!aQuadrosDIOPS[nItem,CHECKED],lMarca)
    oQuadrosDIOPS:Refresh()

Return

/*/{Protheus.doc} fMarcaTudo
Função para marcar todos os itens da listbox 
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fMarcaTudo()
Local nI 

    CursorWait()

    For nI := 1 to Len(aQuadrosDIOPS)
        fMarca(nI, lMarcaTudo)
    Next

    CursorArrow()
    oQuadrosDIOPS:Refresh()

Return 

/*/{Protheus.doc} fValidaParDIOPS
Função para validar o compromisso DIOPS selecionado pelo usuário 
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fValidaParDIOPS()
Local lRet := .t.

    dbSelectArea("B3D")
    B3D->(dbSetOrder(1))    //B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR
    If !B3D->(dbSeek(xFilial("B3D")+aRetDIOPS[CODOPE]+aRetDIOPS[CODOBR]+aRetDIOPS[ANOREF]+aRetDIOPS[CODCOMP]))
       MsgAlert("Compromisso DIOPS é inválido ou não foi localizado.")
       lRet := .f.
    EndIf    

Return lRet

/*/{Protheus.doc} fIniParDIOPS
Função para inicializar os parametros de usuário que serão utilizados na chamada da ParamBox
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fIniParDIOPS()
Local aPar		:= {}
Local cCodInt   := PLSINTPAD()
Local cCodOpe   := Space(TamSX3("B8M_CODOPE")[1])
Local cCodObr   := Space(TamSX3("B3A_CODIGO")[1])
Local cAnoRef   := AllTrim(Str(Year(dDataBase)))
Local cCodComp  := Space(TamSX3("B3D_CODIGO")[1])

    // Seleciona a operadora padrão 
    dbSelectArea("BA0")
    BA0->(dbSetOrder(1))    //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    If BA0->(dbSeek(xFilial("BA0")+cCodInt))
        dbSelectArea("B8M")
        B8M->(dbSetOrder(1))    //B8M_FILIAL+B8M_CODOPE+B8M_CNPJOP
        If B8M->(dbSeek(xFilial("B8M")+BA0->BA0_SUSEP))
            cCodOpe := B8M->B8M_CODOPE
        EndIf
    EndIf     

    // Seleciona a obrigação DIOPS caso esteja sido criada pelo usuário na central 
    If !Empty(cCodOpe)  // se possui operadora cadastrada
        dbSelectArea("B3A")
        B3A->(dbSetOrder(1))    //B3A_FILIAL+B3A_CODOPE+B3A_CODIGO
        B3A->(dbSeek(xFilial("B3A")+cCodOpe))

        // Localiza a obrigação DIOPS ativa 
        While (B3A->B3A_CODOPE == B8M->B8M_CODOPE) .And. B3A->(!Eof())
            If B3A->B3A_TIPO==DIOPS .And. B3A->B3A_ATIVO==ATIVO // 3=DIOPS 1=ATIVO
                cCodObr := B3A->B3A_CODIGO
                Exit
            EndIf 
            B3A->(dbSkip())
        EndDo 
    EndIf 

    // Seleciona o compromisso do DIOPS para realizar a atualização 
    If !Empty(cCodObr)  // se possui a obrigação cadastrada na central
        dbSelectArea("B3D")
        B3D->(dbSetOrder(1))    //B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR
        B3D->(dbSeek(xFilial("B3D")+cCodOpe+cCodObr+cAnoRef))

        // Localiza o compromisso ativo na central de obrigações 
        While (B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO)==B3A->(B3A_CODOPE+B3A_CODIGO+cAnoRef)) .And. B3D->(!Eof())
            If B3D->B3D_TIPOBR==DIOPS .And. B3D->B3D_STATUS<=CRITICADO // 3=DIOPS 3=CRITICADO
                cCodComp := B3D->B3D_CODIGO
                Exit
            EndIf 
            B3D->(dbSkip())
        EndDo
    EndIf 

    // Monta array de perguntas que serão definidas pelo usuário 
    // Tipo 1 -> MsGet()
    //           [2]-Descricao
    //           [3]-String contendo o inicializador do campo
    //           [4]-String contendo a Picture do campo
    //           [5]-String contendo a validacao
    //           [6]-Consulta F3
    //           [7]-String contendo a validacao When
    //           [8]-Tamanho do MsGet
    //           [9]-Flag .T./.F. Parametro Obrigatorio ?
    aAdd(aPar,{1,"Cód Operadora"        ,cCodOpe  ,"@!","Vazio() .Or. VldParDIOPS('B8M_CODOPE')" ,"B8MCEN",".T.",50,.T.})
    aAdd(aPar,{1,"Cód Obrigação DIOPS"  ,cCodObr  ,"@!","Vazio() .Or. VldParDIOPS('B3A_CODIGO')" ,"B3ACEN",".T.",50,.T.})
    aAdd(aPar,{1,"Ano Referência DIOPS" ,cAnoRef  ,"@!","Vazio() .Or. VldParDIOPS('B3D_ANO')"    ,""      ,".T.",40,.F.})
    aAdd(aPar,{1,"Cód Compromisso DIOPS",cCodComp ,"@!","Vazio() .Or. VldParDIOPS('B3D_CODIGO')" ,"B3DCEN",".T.",50,.T.})

 Return(aPar)

/*/{Protheus.doc} fPosQdrDIOPS
Função de chamada da busca do compromisso DIOPS na tabela B3D da central de obrigações
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fPosQdrDIOPS(cIdComp,cRotina)
Local lRet
    // Tabela de compromissos DIOPS 
    dbSelectArea("B3D")
    B3D->(dbSetOrder(1))    //B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+B3D_TIPOBR

    // Valida se o compromisso DIOPS foi criado e esta com status ativo 
    lRet := B3D->(dbSeek(xFilial("B3D")+cIdComp)) .And. B3D->B3D_TIPOBR==DIOPS .And. B3D->B3D_STATUS<=CRITICADO 

    If !lRet
       PlsLogFil("["+cRotina+"] Compromisso DIOPS inválido ou não encontrato: "+cIdComp,ARQ_LOG_DIOPS)
    EndIf    

Return lRet

/*/{Protheus.doc} fExecutaDIOPS
Função para confirmar a execução da atualização dos quadros DIOPS Financeiro 
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fExecutaDIOPS()
Local oProcess  := Nil
Local nMarcados := 0
Local lRet	

	// Verifica se o usuario selecionou algum quadro para atualização 
    CursorWait()
    aEval(aQuadrosDIOPS, {|x| Iif(x[CHECKED],nMarcados++,Nil)})
    lRet := (nMarcados>0)
	CursorArrow()

	If lRet
        oProcess := MsNewProcess():New({|| fProcessaDIOPS(oProcess)}, "Aguarde...", "Processando...", .T.)
        oProcess:Activate()   
    Else
		MsgAlert("Necessário selecionar os Quadros de Detalhamento que serão atualizados.")
	EndIf 

Return lRet

/*/{Protheus.doc} fProcessaDIOPS
Função de execução da atualização dos quadros DIOPS Financeiro
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fProcessaDIOPS(oProcess)
Local oArqLog   := Nil
Local nRegua 	:= 0
Local nAtual    := 0
Local cRotina   := ""
Local cIdComp   := ""
Local cIdQuadro := ""
Local aRet
Local nI, nX

    // apaga arquivo de log atual
    FErase(DIR_LOG_DIOPS+ARQ_LOG_DIOPS)

    // Inicializa arquivo de log do processamento
	PlsLogFil("",ARQ_LOG_DIOPS)
    PlsLogFil("*** INICIO - PROCESSAMENTO DO EXTRATOR DIOPS FINANCEIRO *** "+DtoC(Date())+" - "+Time(),ARQ_LOG_DIOPS)

	// Quantidade de itens a serem processados
    aEval(aQuadrosDIOPS, {|x| Iif(x[CHECKED],nRegua++,Nil)})
    oProcess:SetRegua1(nRegua)
	
	For nI := 1 to Len(aQuadrosDIOPS)
		// Verifica se o quadro foi selecionado   
		If aQuadrosDIOPS[nI,CHECKED]
            // Mostra o nome do quadro que esta sendo processado e quantidade de itens 
            oProcess:IncRegua1("Executando Extrator DIOPS Financeiro [" + cValToChar(++nAtual) + " de " + cValToChar(nRegua) + "]")

            // atualiza log do processamento
            PlsLogFil("",ARQ_LOG_DIOPS)
            PlsLogFil("["+aQuadrosDIOPS[nI,FNCQUADRO]+"] Executando Quadro -> "+Upper(aQuadrosDIOPS[nI,DESQUADRO]),ARQ_LOG_DIOPS)

            // Zerar a regua de atualização 
            oProcess:SetRegua2(-1)
            oProcess:IncRegua2(aQuadrosDIOPS[nI,DESQUADRO])
            Sleep( 1000 )		//aguarda 1 segundo para nova integração 

            // Nome da rotina que sera executada para atualizar o quadro 
            cRotina := aQuadrosDIOPS[nI,FNCQUADRO]

            // Verifica se a rotina de atualização do quadro foi compilada   
            If !Empty(cRotina) .And. FindFunction(cRotina)

                // Realiza a limpeza das tabelas do quadro e criticas 
                If aQuadrosDIOPS[nI,TABQUADRO]=="B8B" /* Plano de Contas ANS */.Or. ;
                    fDelQuadroDIOPS(aQuadrosDIOPS[nI,TABQUADRO],aRetDIOPS[CODOPE],aRetDIOPS[CODOBR],aRetDIOPS[ANOREF],aRetDIOPS[CODCOMP],cRotina)

                    // Chave utilizada para posicionar a tabela de configuracoes dos quadros B3I
                    cIdQuadro   := aQuadrosDIOPS[nI,CODQUADRO]
                    
                    // Chave utilizada para posicionar a tabela de compromisso DIOPS na user função
                    cIdComp     := aRetDIOPS[CODOPE]+aRetDIOPS[CODOBR]+aRetDIOPS[ANOREF]+aRetDIOPS[CODCOMP]

                    // Posiciona no compromisso DIOPS selecionado pelo usuário 
                    If fPosQdrDIOPS(cIdComp,cRotina)
                        // Chamada da rotina de atualização do quadro passando como parametro o objetvo da regua2
                        aRet := &(cRotina+"(oProcess)")

                        // Valida retornos
                        If ValType(aRet)=="A"
                            nTotal := Iif(ValType(aRet[1])=="N",aRet[1],0)
                            aErros := Iif(ValType(aRet[2])=="A",aClone(aRet[2]),{})

                            If Len(aErros)>0
                                For nX := 1 to Len(aRet[2])
                                    PlsLogFil("["+cRotina+"] "+aRet[2,nX],ARQ_LOG_DIOPS)       
                                Next
                            EndIf 

                            If nTotal>0
                                PlsLogFil("["+cRotina+"] Total de registros incluídos na tabela "+;
                                    aQuadrosDIOPS[nI,TABQUADRO]+": "+AllTrim(Transform(nTotal, "@E 999,999,999,999")),ARQ_LOG_DIOPS)

                                If Len(aErros)==0
                                    // Chamada da função de validação dos Quadros pela Central de Obrigações
                                    If !Empty(aQuadrosDIOPS[nI,CENQUADRO]) .And. aQuadrosDIOPS[nI,CENVALID] // Validação automática = Sim
                                        PlsLogFil("["+cRotina+"] Inicio da Validação - "+Time(),ARQ_LOG_DIOPS)   
                                        
                                        // Chamada da funcao para verificar se um quadro esta liberado para validacao pela Central de Obrigações
                                        fLibQuadroDIOPS(aRetDIOPS[CODOPE],aQuadrosDIOPS[nI,CENQUADRO])

                                        // Chamada da funcao de validacao do quadro pela Central de Obrigacoes
                                        MsAguarde( {||validComQDIOPS( B3D->B3D_CODOPE, B3D->B3D_CODIGO, aQuadrosDIOPS[nI,CENQUADRO], B3D->B3D_CDOBRI, B3D->B3D_ANO )},"Central de Obrigacoes" ,"Validando registros. Aguarde...")
                                        
                                        //CursorWait()
                                        //FWMsgRun(,{|| CenVldQdMn(aQuadrosDIOPS[nI,CENQUADRO],.t.) },;
                                        //    "Executando a Validação DIOPS... Aguarde",aQuadrosDIOPS[nI,DESQUADRO] )
                                        //CursorArrow()

                                        // Chamada da função para consultar se o Quadro possui criticas 
                                        // gravadas na tabela B3F para informar ao usuário 
                                        fLogQdrDIOPS(cRotina,aRetDIOPS[CODOPE],aRetDIOPS[CODOBR],aRetDIOPS[ANOREF],aRetDIOPS[CODCOMP],aQuadrosDIOPS[nI,TABQUADRO])
                                        
                                        PlsLogFil("["+cRotina+"] Término da Validação - "+Time(),ARQ_LOG_DIOPS)  
                                    EndIf

                                    // Atualiza log após a execução do extrator 
                                    PlsLogFil("["+cRotina+"] Concluído com SUCESSO.",ARQ_LOG_DIOPS)   
                                EndIf
                            Else
                                PlsLogFil("["+cRotina+"] Nenhum registro foi incluído na tabela "+;
                                    aQuadrosDIOPS[nI,TABQUADRO],ARQ_LOG_DIOPS)       
                            EndIf
                        EndIf      
                    EndIf 
                EndIf
            Else 
                PlsLogFil("["+cRotina+"] Rotina do Extrator DIOPS não compilada.",ARQ_LOG_DIOPS)
            EndIf 
		Endif
	Next

    // Inicializa arquivo de log do processamento
	PlsLogFil("",ARQ_LOG_DIOPS)
    PlsLogFil("*** TÉRMINO - PROCESSAMENTO DO EXTRATOR DIOPS FINANCEIRO *** "+DtoC(Date())+" - "+Time(),ARQ_LOG_DIOPS)

    // faz a leitura do arquivo de log 
    oArqLog  := FWFileReader():New(DIR_LOG_DIOPS+ARQ_LOG_DIOPS)
    oArqLog:Open()

    // atualiza o Wizard com o painel de resultado do processamento  
    cResult := oArqLog:FullRead()
    oResult:Refresh()
    oArqLog:Close()

Return

/*/{Protheus.doc} fDelQuadroDIOPS
Função criada para excluir os registros do quadro e criticas antes de realizar uma nova integração
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static function fDelQuadroDIOPS(cAlias, cCodOpe, cCodObr, cAnoCmp, cCodComp, cRotina)
Local cQuery
Local nErro
Local cWhrQuadro  := ""
Local cWhrCritica := ""
Local lRet  := .t.

    // Monta where de exclusão do quadro 
    cWhrQuadro	:= cAlias +"_FILIAL='" + xFilial(cAlias) + "' AND "+ cAlias +"_CODOPE='"+cCodOpe+"' AND "+ cAlias +"_CODOBR='"+cCodObr+"' AND "+ cAlias +"_ANOCMP='"+cAnoCmp+"' AND "+ cAlias +"_CDCOMP='"+cCodComp+"' "    

    // Monta where de limpeza das criticas vinculadas ao quadro 
    cWhrCritica := " B3F_FILIAL='"+xFilial("B3F")+"' AND B3F_CODOPE='"+cCodOpe+"' AND B3F_CDOBRI='"+cCodObr+"' AND B3F_ANO='"+cAnoCmp+"' AND B3F_CDCOMP='"+cCodComp+"' AND B3F_ORICRI='"+cAlias+"' "

    If !Empty(cAlias)
        cQuery  := "DELETE FROM "+RetSqlName(AllTrim(cAlias))+" WHERE "+AllTrim(cWhrQuadro)
        nErro   := TCSQLEXEC(cQuery)

        If (nErro < 0 )
            PlsLogFil("["+cRotina+"] Falha ao executar a limpeza da tabela: "+cAlias+" "+Chr(13)+Chr(10)+TCSQLError(),ARQ_LOG_DIOPS)
            lRet := .f.
        Else
            cQuery  := "DELETE FROM "+RetSqlName("BF3")+" WHERE "+AllTrim(cWhrCritica)
            nErro   := TCSQLEXEC(cQuery)
        Endif 
    EndIf 

Return lRet

/*/{Protheus.doc} fLibQuadroDIOPS
Funcao criada para verificar se um quadro esta liberado para validacao pela Central de Obrigações
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fLibQuadroDIOPS(cCodOpe,cQuadro)
Local lRet := .F.

	If fVldQuadroDIOPS(cCodOpe,cQuadro)
		lRet := TRBB8X->B8X_RECEBI == ATIVO .And. TRBB8X->B8X_VALIDA == ATIVO
	Else
		lRet:=fIncQuadroDIOPS(cCodOpe,B3D->B3D_ANO,B3D->B3D_CODIGO,B3D->B3D_CDOBRI,cQuadro)
		If lRet
			fIntQuadroDIOPS(cQuadro, B3D->B3D_CODOPE,B3D->B3D_ANO,B3D->B3D_REFERE)
		EndIf
	EndIf

	TRBB8X->(dbCloseArea())

Return lRet

/*/{Protheus.doc} fVldQuadroDIOPS
Funcao criada para validar um quadro manualmente pela Central de Obrigações
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fVldQuadroDIOPS(cCodOpe,cQuadro)
Local lRet := .F.
Local cSql

Default cCodOpe := ""
Default cQuadro := ""

	cSql := " SELECT "
	cSql += " 	B8X_CODOPE, B8X_CDCOMP, B8X_CODOBR, B8X_ANOCMP, B8X_QUADRO, B8X_RECEBI, B8X_VALIDA "
	cSql += " FROM " + RetSqlName("B8X") + " "
	cSql += " WHERE "
	cSql += " 	B8X_FILIAL = '" + xFilial("B8X") + "' "
	cSql += " 	AND B8X_CODOPE = '" + cCodOpe + "' "
	cSql += " 	AND B8X_CODOBR = '" + B3D->B3D_CDOBRI + "' "
	cSql += " 	AND B8X_ANOCMP = '" + B3D->B3D_ANO + "' "
	cSql += " 	AND B8X_CDCOMP = '" + B3D->B3D_CODIGO + "' "
	cSql += " 	AND B8X_QUADRO = '" + cQuadro + "'  "
	cSql += " 	AND D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B8X_CODOPE,B8X_CODOBR,B8X_ANOCMP,B8X_CDCOMP,B8X_QUADRO "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB8X",.F.,.T.)

	lRet := !TRBB8X->(Eof())

Return lRet

/*/{Protheus.doc} fIncQuadroDIOPS
Funcao criada para criar um quadro manualmente pela na Central de Obrigações 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fIncQuadroDIOPS(cCodOpe,cAnoCmp,cCdComp,cCodObr,cQuadro)
Local aQuadros	:= getQuadrosDiops()    // função da Central de Obrigações
Local lRet  	:= .F.

Default cCodOpe := ""
Default cCodObr := ""
Default cCdComp := ""
Default cAnoCmp := ""
Default cQuadro := ""

	If Len(aQuadros) >= 1 .And. Ascan(aQuadros,{ |x| x[1] == cQuadro})
		lRet := .T.
		fGrvQuadroDIOPS(cCodOpe,cCodObr,cCdComp,cAnoCmp,cQuadro)
	EndIf

Return lRet

/*/{Protheus.doc} fGrvQuadroDIOPS
Funcao criada para gravar dados da tabela B8X pela Central de Obrigações 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fGrvQuadroDIOPS(cCodOpe,cCodObr,cCdComp,cAnoCmp,cQuadro)
Local lRet  := .F.
    
Default cCodOpe	:= ""
Default cCodObr	:= ""
Default cCdComp	:= ""
Default cAnoCmp	:= ""
Default cQuadro := ""

	If !Empty(cCodOpe) .And. !Empty(cCodObr) .And. !EMpty(cQuadro)

		lRet := .T.
        dbSelectArea("B8X")
        B8X->(dbSetOrder(1))    //B8X_FILIAL+B8X_CODOPE+B8X_CODOBR+B8X_ANOCMP+B8X_CDCOMP+B8X_QUADRO

        If !B8X->(dbSeek(xFilial("B8X")+cCodOpe+cCodObr+cAnoCmp+cCdComp+cQuadro))
            RecLock("B8X",.T.)
            B8X->B8X_FILIAL := xFilial("B8X")
            B8X->B8X_CODOPE := cCodOpe
            B8X->B8X_CODOBR := cCodObr
            B8X->B8X_CDCOMP := cCdComp
            B8X->B8X_ANOCMP := cAnoCmp
            B8X->B8X_RECEBI := '1'//1=Sim;2=Nao
            B8X->B8X_VALIDA := '1'//1=Sim;2=Nao
            B8X->B8X_QUADRO := cQuadro
            B8X->(MsUnlock())
        Else
            RecLock("B8X",.F.)
            B8X->B8X_RECEBI := '2'//1=Sim;2=Nao
            B8X->B8X_VALIDA := '2'//1=Sim;2=Nao
            B8X->(MsUnlock())
        EndIf     
	EndIf
	
Return lRet

/*/{Protheus.doc} fIntQuadroDIOPS()
Função criada para liberar para validação quadros sem integração, que são cadasrtrados manualmente
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fIntQuadroDIOPS(cQuadro, cCodOpe, cAno, cRefere)
	Local lRet		:= .F.
	local cRecno 	:= ""

	Default cQuadro	:= ""
	Default cCodOpe	:= ""
	Default cAno	:= ""
	Default cRefere	:= ""

    // Chamada das funções utilizadas pela Central de Obrigacoes 
	If quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere, .F., cRecno )
		lRet := quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
	EndIf

Return lRet

/*/{Protheus.doc} fLogQdrDIOPS()
Verifica se o Quadro possui criticas gravadas pela Central (B3F) para informar ao usuário 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function fLogQdrDIOPS(cRotina, cCodOpe, cCodObr, cAno, cCodComp, cAlias)
Local cAliasTrb := GetNextAlias()

    BeginSQL Alias cAliasTrb
        SELECT DISTINCT B3F_CODCRI, B3F_DESCRI, B3F_SOLUCA
            FROM %Table:B3F% B3F
        WHERE B3F_FILIAL = %xFilial:B3F%
        AND B3F_CODOPE = %Exp:cCodOpe%
        AND B3F_CDOBRI = %Exp:cCodObr%
        AND B3F_ANO    = %Exp:cAno%
        AND B3F_CDCOMP = %Exp:cCodComp%
        AND B3F_ORICRI = %Exp:cAlias%
        AND B3F_STATUS = '1'
        AND B3F_TIPO = '1'
        AND B3F.%NotDel%
        ORDER BY B3F_CODCRI
    EndSQL

    While (cAliasTrb)->(!Eof())
        PlsLogFil("["+cRotina+"] Critica "+(cAliasTrb)->B3F_CODCRI+" - "+;
                        Alltrim(Upper((cAliasTrb)->B3F_DESCRI)),ARQ_LOG_DIOPS)
        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(dbCloseArea())

 Return    
