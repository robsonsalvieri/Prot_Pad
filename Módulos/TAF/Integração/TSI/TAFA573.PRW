#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TSI
	Funcao utilizada para inserir no menu e debugar na filial logada do sistema, 
	devido a dificuldade de debugar a thread vinda do schudule.
	@author Denis Souza
	@since 22/03/2023
	@return Nil, nulo, não tem retorno. 
/*/
Function ExecTSI()
    MSGINFO( "O TSI será processado via Menu", "TSI - Menu" )
    TSI({cEmpAnt,cFilAnt})
Return Nil

/*/{Protheus.doc} TSI
	Mecanismo responsável por executar o processo do TSI para o ERP
	@author Henrique Pereira

    @param aParam - Parametros do Schedule 
    [1]Grupo de Empresa
    [2]Filial
    @param nIntTimeLS - Intervalo de tempo para registros de uso no LS
    Este parâmetro não é configurado no schedule, a sua finalidade é 
    auxiliar a criação de testes automatizados para a função regTSILS
   
	@since 08/09/2020
	@return Nil, nulo, não tem retorno. 
/*/

Function TSI(aParam)

Local cSource    as character
Local nGetNames  as numeric
Local nX         as numeric
Local aFuncs     as array
Local aObjJson   as array
Local aREGxV80   as array
Local oEntidad   as object
Local oTSIERPOBJ as object
Local oBjJson    as object 
Local cMsg       as character
Local cLink      as character    
Local cUltStmp   as character
Local lCompTabs  as logical
Local cRefStamp  as character
Local cTable     as character
Local lV80OK     as logical
Local lTafIsc    as logical
Local xTAFIsch

cMsg       := ''
cLink      := ''
cUltStmp   := ''
aREGxV80   := {}
lCompTabs  := .F.
cRefStamp  := ''
lV80OK     := .f. 
lTafIsc    := .f.
cTable     := ''

if len(aParam) > 0
    if isBlind()
        RpcSetType(3)
        RpcSetEnv(aParam[1],aParam[2],,,"TAF","TAFA573",,,,.T.,)
    endif
    lV80OK    := FWAliasInDic('V80')

    xTAFIsch := GetMV( "MV_TAFISCH",, "0" )

    Do Case
        Case ValType( xTAFIsch ) == "C"
            lTafIsc := IIf( xTAFIsch == "1", .T., .F. )
        Case ValType( xTAFIsch ) == "L"
            lTafIsc := xTAFIsch
    EndCase

    if ExistStamp(@cMsg, @cLink) //Verifico se os stamps estão criados
        if !lV80OK //Verifico se V80 está criada e se tem as funções do TSIXFUN
            TAFConOut( "Nao existe o alias V80 na sua base de dados. Favor atualize o TAF com o ultimo pacote disponivel no portal do cliente." ,2,.T.,"TSI")
        ElseIf !Findfunction("TsiUltStamp") .or. !FindFunction("TsiFmtDate") .Or. !FindFunction("TafSetPrepare")
            TAFConOut( "TSILOG000032 Repositorio desatualizado. Favor atualize o TAF com o ultimo pacote disponivel no portal do cliente." ,2,.T.,"TSI")
        else
            TAFConOut("TSILOG000001 - Inicio - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt),2,.T.,"TSI")
            /*Todo o processamento desta thread será baseada nesse stamp e será passada para as classes
            que precisarem usar o stamp na C20, assim garantiremos essa unica data de corte, não se importando 
            mais com o tempo de processamento do TAFA558 e processamentos*/
            if !lTafIsc //Desvio para quando o parametro MV_TAFISCH estiver setado como .T.
                cRefStamp  := TsiUltStamp("C20",.f.)

                if Empty(cRefStamp)
                    cRefStamp := TsiFmtDate(SUBSTR(FWTimeStamp(3),1,10)) + " 00:00:00.000"
                endif

                cSource   := aParam[1]+aParam[2]
                /*---------------------------------------------------------------------------------------------|
                | Efetua a alteracao FAKE dos cadastros que constam na movimentacao para serem considerados    |
                | na extracao do json e integracao com o TAF, conforme laco abaixo.                            |
                ----------------------------------------------------------------------------------------------*/
                TAFConOut("Inicio Alteracao Fake - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")
                TSIFATNFIS():New(cSource,cRefStamp) //Alteração Fake
                TAFConOut("Fim Alteracao Fake - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")

                oTSIERPOBJ := TSINFISCAL():new( cSource,cRefStamp ) //Classe que contém query com preparedstatament de Nota Fiscal para posterior integração
                cTable := oTSIERPOBJ:oTabTemp:GetRealName()
                /*---------------------------------------------------------------------------------------------|
                | Quando temos mais de uma THREAD no schedule (XX0_THREAD) e selecionamos mais de uma filial   |
                | para executar a função TSI(XX2), podem ocorrer paralelismo. E duas ou mais thread's tentarão |
                | gravar o mesmo registro na tabela de destino do TAF.                                         |
                | Isso ocorre pelo fato das thread's executarem exatamente ao mesmo tempo a função TSI         | 
                | fazendo com que o mesmo registro seja extraido pela classe de cadastro e dentro do motor     | 
                | TAFA565, o seek falha em ambas as thread e o modelo é commitado como inclusão mais de uma vez|
                | ****Esse comportamento só acontece com tabelas totalmente compartilhadas                     |
                | Para evitar esse tipo de problema, utilizamos o sleep para atrasar as threads e gerar uma    |
                | dessincronização proposital, desta forma, não iremos ter mais o paralelismo entre as threads |
                ----------------------------------------------------------------------------------------------*/
                
                /*---------------------------------------------------------------------------------------------|
                | Coloca a thread para dormir entre 0,5 segundo e 10 segundos, a primeira que sair será        |
                | responsável por iniciar a inclusão dos cadastros                                             |
                ----------------------------------------------------------------------------------------------*/
                sleepTSI(500,10000)

                /*---------------------------------------------------------------------------------------------|
                | Coloca o código da filial em variável Global para que seja a unica a não passar por sleep    |
                ----------------------------------------------------------------------------------------------*/
                If Empty(GetGlbValue('cTsiFilPref'))
                    PutGlbValue( 'cTsiFilPref', AllTrim(aParam[2]) )
                ENDIF

                /*---------------------------------------------------------------------------------------------|
                | Se a filial não estiver na variável global, significa que a execução dela não é prioritária  |
                | e a thread ficara em speep novamente, desta vez de 0,5 segundos até 5 segundos               |
                ----------------------------------------------------------------------------------------------*/
                IF AllTrim(aParam[2]) <> GetGlbValue('cTsiFilPref')
                    sleepTSI(500,5000)
                ENDIF

                TAFTSILS()

                If !Empty(cTable) .and. oTSIERPOBJ:nQtFTF3 > 0
                    /*---------------------------------------------------------------------------------------------|
                    | Extração e integracão dos CADASTROS que possuem stamp preenchido.                            |
                    ----------------------------------------------------------------------------------------------*/
                    nX := nGetNames := 0
                    aFuncs := GetFuncs()

                    /*---------------------------------------------------------------------------------------------|
                    | Mudo a ordem de execução dos cadastros de acordo com a filial que tem preferência de execução| 
                    | Com essa mudança, iremos fazer com que as threads não trabalhem na mesma ordem, e alem de    |
                    | evitar os paralelismos, iremos ganhar agilidade, uma vez que a thread preferêncial começará  |
                    | pela classe TSIPROREF(), as outras threads iniciarão pela TSIADDINFO()                       | 
                    ----------------------------------------------------------------------------------------------*/

                    if AllTrim(aParam[2]) <> GetGlbValue('cTsiFilPref')
                        Asort(aFuncs,,,{|x,y|x[1]<y[1]})    
                    endif

                    TAFConOut("Inicio Predecessores - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")

                    for nX := 1 to len(aFuncs)

                        cUltStmp := ''
                        /*---------------------------------------------------------------------------------------------|
                        | As classe TSINCM e TSIPARTIC foram as que mais apresentaram problemas de integração, por isso| 
                        | forçamos um novo sleep para dessincronizar totalmente a execução das threads                 |
                        ----------------------------------------------------------------------------------------------*/
                        IF AllTrim(aParam[2]) <> GetGlbValue('cTsiFilPref') .and. ("TSINCM" $ aFuncs[nX][1] .or. "TSIPARTIC" $ aFuncs[nX][1])
                            sleepTSI(500,2500)
                        ENDIF

                        TAFConOut("TSILOG00003 Função executada: " + aFuncs[nX][1] + " - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")

                        //Se classe de extração estiver trabalhando com limite de array, executo método CommitRegs para fazer a gravação
                        if aFuncs[nX][4]
                            oEntidad := &(aFuncs[nX][1]) //macro executa o construtor, instancia o objeto
                            If TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
                                // Caso existam a tabela V80 e a função TSIAtuStamp, necessário também
                                // a atualização dos fontes de extração dos cadastros
                                aSize(aREGxV80,0); aREGxV80 := {}                        
                                lCompTabs := aFuncs[nX][5] $ 'C1H|C1L'
                                if lCompTabs
                                    If aFuncs[nX][5] == 'C1H'
                                        aAdd(aREGxV80,{"C1H|SA1",''})
                                        aAdd(aREGxV80,{"C1H|SA2",''}) //AliasTAF|AliasERP,UltStmp
                                    Elseif aFuncs[nX][5] == 'C1L'
                                        aAdd(aREGxV80,{"C1L|SB1",''})
                                    Endif
                                endif
                                oEntidad:CommitRegs(&(aFuncs[nX][2]), @cUltStmp, @aREGxV80)
                                If !Empty(cUltStmp) .Or. (lCompTabs .And. (!Empty(aREGxV80[1][2]) .Or. (Len(aREGxV80) > 1 .And. !Empty(aREGxV80[2][2]))))
                                    TSIAtuStamp(aFuncs[nX][5], cUltStmp, @aREGxV80)
                                Endif
                            Else
                                oEntidad:CommitRegs(&(aFuncs[nX][2]))
                            Endif
                            FreeObj(oEntidad)
                        else
                            oEntidad := &(aFuncs[nX][1])
                            oBjJson := oEntidad:GetJsn()
                            for nGetNames := 1 to len( oBjJson:GetNames() )
                                TAFConOut("TSILOG00004 GetNames ok: " + cvaltochar(len( oBjJson:GetNames() )))
                                aObjJson := oBjJson:GetJsonObject( oBjJson:GetNames()[nGetNames] )
                                //Utilizara novo motor pai e filho TAFA585, ex: processo referenciado e suspensao
                                if aFuncs[nX][3]
                                    If TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
                                        WsTSIProc( oBjJson, .T., &(aFuncs[nX][2]), @cUltStmp )
                                        If !Empty(cUltStmp)
                                            TSIAtuStamp(aFuncs[nX][5], cUltStmp)
                                        Endif
                                    Else
                                        WsTSIProc( oBjJson, .T., &(aFuncs[nX][2]) )
                                    Endif
                                else //demais cadastros mantem motor padrao
                                    aSize(aREGxV80,0); aREGxV80 := {}
                                    lCompTabs := aFuncs[nX][5] $ 'C1J|C1N|C0A'
                                    if lCompTabs
                                        If aFuncs[nX][5] == 'C1J'
                                            aAdd(aREGxV80,{"C1J|SAH",''})
                                        Elseif aFuncs[nX][5] == 'C1N'
                                            aAdd(aREGxV80,{"C1N|SF4",''})
                                        Elseif aFuncs[nX][5] == 'C0A'
                                            aAdd(aREGxV80,{"C0A|SYD",''})
                                        Endif
                                    Endif
                                    If TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
                                        // Caso existam a tabela V80 e a função TSIAtuStamp, necessário também
                                        // a atualização dos fontes de extração dos cadastros
                                        TAFA565( &(aFuncs[nX][2]), aObjJson, , , , @cUltStmp, @aREGxV80 )
                                        If !Empty(cUltStmp) .Or. lCompTabs .And. (!Empty(aREGxV80[1][2]))
                                            TSIAtuStamp(aFuncs[nX][5], cUltStmp, aREGxV80 )
                                        Endif
                                    Else
                                        TAFA565( &(aFuncs[nX][2]), aObjJson )
                                    Endif
                                endif
                            next nGetNames
                            FreeObj(oEntidad)
                            FreeObj(oBjJson)
                        endif
                    next nX
                    TAFConOut("Fim Predecessores - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")

                    /*--------------------------------------------------------------------------------------------|
                    | Apos a gravacao de todos os cadastros é realizado a integração da NOTA FISCAL               |
                    ----------------------------------------------------------------------------------------------*/
                    TAFConOut("Inicio Processamento Notas: " + time() + " - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")
                    oTSIERPOBJ:TempTable() //Classe que contém query com preparedstatament de Nota Fiscal para posterior integração
                    //Importante: O stamp será atualizado dentro da função ExtrJsonProc a cada 500 registros ou quando finalizar o último lote.
				    //Caso o serviço caia ou seja reiniciado no meio do processamento, não irá mais iniciar do mesmo stamp anterior e sim do último gravado a cada 500 registros.
                    //Se fez necessário devido à grande quantidade de registros extraídos, processados que iria atualizar a V80 somente no final do processamento das notas, depois de muitas horas.
                    TAFConOut("Fim Processamento Notas: " + time() + " - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")
                EndIf
            endIf        
            /*---------------------------------------------------------
            Gravação de Layouts de MVC com filho,neto
            -----------------------------------------------------------*/
            TAFConOut("Inicio Apuracoes: " + time() + " - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")
            aFuncs := GetModels()
            for nX := 1 to len(aFuncs)
                cUltStmp := ''
                TAFConOut("TSILOG000013 Função MVC executada: " + aFuncs[nX][1])
                oTSIERPOBJ := &(aFuncs[nX][1])
                oBjJson := oTSIERPOBJ:GetJsn()        
                oHashPai := &(aFuncs[nX][2])
                If TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
                    WsTSIProc( oBjJson, .T., oHashPai, @cUltStmp ) //Processamento de importação do model
                    If !Empty(cUltStmp)
                        TSIAtuStamp(aFuncs[nX][3], cUltStmp)
                    Endif
                Else
                    WsTSIProc( oBjJson, .T., oHashPai ) //Processamento de importação do model
                Endif
            next nX
            TAFConOut("Fim Apuracoes: " + time() + " - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")
            /*-------------------------------------------------------------------------------------------------------------------------------|
            |Efetua a alteracao FAKE na SFT, com base no V5R_REGKEY para V5R_ALIAS = 'C20', ira considerar todos stamps inferiores a database|
            |e serao colocados na fila de reprocessamento, na proxima execucao, os stamps da V5R serao atualizados com a data de hoje e nao  |
            |serao mais inferiores ate a proxima execucao do dia seguinte.                                                                   |
            |Importante: Esse controle devera ser a ultima instrucao no processamento do TSI, pois caso ocorra gravação da V5R para a C20,   |
            |apos a chamada da Ws034Proc, na primeira execucao do job, ja havera execucao do updatefake para a C20.                          |
            --------------------------------------------------------------------------------------------------------------------------------*/
            //Desabilitado para evitar possíveis travamentos até que os indices solicitados para o time fiscal sejam criados.
            //https://jiraproducao.totvs.com.br/browse/DSERFISE-2878
            //Indice na SFT: CREATE NONCLUSTERED INDEX SFTT10G ON SFTT10(FT_FILIAL, [FT_NFISCAL] ,[FT_SERIE], [FT_CLIEFOR], [FT_LOJA],[FT_IDENTF3], [FT_ENTRADA],[FT_ESPECIE], R_E_C_N_O_, D_E_L_E_T_)
            //Indice na SF3: CREATE NONCLUSTERED INDEX SF3T10D ON SF3T10(F3_FILIAL, [F3_NFISCAL] ,[F3_SERIE], [F3_CLIEFOR], [F3_LOJA],[F3_IDENTFT], [F3_ENTRADA],[F3_ESPECIE], R_E_C_N_O_, D_E_L_E_T_)
            If !lTafIsc //Desvio para quando o parametro MV_TAFISCH estiver setado como .T.
                If FindClass("TSIV5RC20")
                    TAFConOut("Inicio Alteracao Fake Log: " + time() + " - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")
                    TSIV5RC20():New(cSource, .F. ) //TAFA600.PRW Alteração Fake C20
                    TAFConOut("Fim Alteracao Fake Log: " + time() + " - Taf Service Integration - " + alltrim(cEmpAnt+"|"+cFilAnt), 2, .T., "TSI")
                EndIf
            EndIf
        EndIf
    else
        TAFConOut( "Erro de estrutura de base: " + cMsg + " Help: " + cLink ,2,.T.,"TSI")
    endif
    if isBlind()
        RpcClearEnv( )
    endif
endif

TAFConOut("TSILOG000030 - Fim - Taf Service Integration - "+alltrim(cEmpAnt+"|"+cFilAnt),2,.T.,"TSI")

Return Nil

/*/{Protheus.doc} GetFuncs
	Retorna as propriedade para cada macro execução de cadastro
	@author Henrique Pereira
	@since 08/09/2020
	@return Nil, nulo, não tem retorno. 
/*/

static function GetFuncs( )

Local lChild   as Logical
Local aRet     as Array
Local lLimited as Logical

lChild   := .T.
lLimited := .T.
aRet     := {}

aRet := {{'TSIPROREF():NEW(cSource)' /*TAFA572*/, 'HashProcRef()'/*WSTAF032*/, lChild , !lLimited,'C1G'},; //T001AB-Processos Referenciados
        {'TSIADDINFO():NEW(cSource)'/*TAFA575*/, 'HashAddInf()' /*WSTAF035*/, !lChild, !lLimited, 'C3Q'},; //T001AK-Informações Complementares
        {'TSIUM():NEW(cSource)'     /*TAFA557*/, 'HashUM()'     /*WSTAF030*/, !lChild, !lLimited, 'C1J'},; //T005  -unidade de medida
        {'TSINCM():NEW(cSource)'    /*TAFA561*/, 'HashNCM()'    /*WSTAF036*/, !lChild, !lLimited, 'C0A'},; //new   -NCM
        {'TSIITEM():NEW(cSource, cTable)'   /*TAFA559*/, 'HashITEM()'   /*WSTAF026*/, !lChild, lLimited,  'C1L'},; //T007  -Produto
        {'TSIPARTIC():NEW(cSource, cTable)' /*TAFA556*/, 'HashPARTIC()' /*WSTAF027*/, !lChild, lLimited,  'C1H'},; //T003  -Participante cliente ou fornecedor
        {'TSINATOPE():NEW(cSource, cTable)' /*TAFA560*/, 'HashNature()' /*WSTAF025*/, !lChild, !lLimited, 'C1N'},; //T009  -Natureza da operação
        {'TSICNO():NEW(cSource)'               , 'HashCNO()'    /*WSTAF042*/, !lChild, !lLimited, 'T9C'}}  //T157  -Cadastro Nacional de Obras
/*
    Na primeira fase do TSI não iremos integrar Centro de Custo, esse layout ( T011 ) era utilizado para a obrigação PIS/COFINS.
    Também é utilizado para os registros ECF, porem a extração e integração com o TAF é feito pelo fonte CTBS001.prw
*/

//{'TSICC():NEW(cSource)'     , 'HashCC()', !lChild, !lLimited, 'C1P'} } //T011   - Centro de custo 

// A extração do Cadastro Nacional de Obras será liberado na próxima fase dos testes com pilotos.
//{'TSICNO():NEW(cSource)'    , 'HashCNO()'    /*WSTAF042*/, !lChild, !lLimited, 'T9C'}  //T157  -Cadastro Nacional de Obras

return aRet

/*/{Protheus.doc} GetModels
	Retorna as propriedade para cada macro execução de mvc com filho, neto, não relacionado a NF
	@author Karen Honda
	@since 19/07/2021
	@return Nil, nulo, não tem retorno. 
/*/

static function GetModels( )

Local aRet := { {'TSIAPURICMS():NEW(cSource)', 'HashC2S()', 'C2S' },; //T020 - Apuração ICMS
                {'TSICMSST():NEW(cSource)', 'HashC3J()', 'C3J' },;     //T021 - Apuração ICMS ST
                {'TSICPRB():NEW(cSource)', 'HashC5M()', 'C5M' }}      //T082 - CPRB


return aRet

/*/{Protheus.doc} sleepTSI
    (coloca a thread em um sleep randomico)
    @type  Static Function
    @author Wesley Matos/Renan Gomes
    @since 18/11/2021
	@return Nil, nulo, não tem retorno. 
/*/
Static Function sleepTSI(nMinMlSec,nMaxMlSec)
Local nSleep := 0

Default nMinMlSec := 500
Default nMaxMlSec := 10000

nSleep := Randomize(nMinMlSec,nMaxMlSec)
sleep(nSleep)
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTSILS
@type			function
@description	Registra o Uso da Rotina no License Server

@param nIntervalTime 
Define o tempo (em segundos) que o sistema deve aguardar 
para executar a requisição de registro de uso da Rotina para o LS
@return (Array)         
[1] boolean - .T. quando a requisição ao LS foi realizada
[2] numeric - TimeStamp da Data/Hora ATUAL (da execução) 
[3] numeric - TimeStamp da Data/Hora da última requisição
realizada ao LS (Cache)

@author			Evandro dos Santos Oliveira
@since			18/03/2022
@param			Nil 
@return			Nil 
/*/
//---------------------------------------------------------------------
Function TAFTSILS(nIntervalTime)

	Local cCode		 as character 
	Local cUser		 as character
	Local cModule	 as character
	Local cRoutine   as character
    
    Local cUUID      as character
    Local cKeyLsTSI  as character
    Local nTimeCache as numeric
    Local nTimeNow   as numeric
    Local lLogLS     as logical 
    Local cMsgErr    as character

	cCode		:= ""
	cUser		:= ""
	cModule     := ""
	cRoutine    := "" 
    cUUID       := "uuid_ls"
    cKeyLsTSI   := "keytsi_ls"
    nTimeCache  := 0
    nTimeNow    := 0
    lLogLS      := .F. 
    cMsgErr     := ""

    Default nIntervalTime := 86400 //24 horas

    If VarSetUID(cUUID,.T.) 

        nTimeNow := Val(FWTimeStamp(1))

        //Se a variável já existir (escopo Global) o sistema irá verificar se ainda NÃO se passaram
        //24 horas, se positivo o sistema returna Nil e não faz nada. 
        If VarGetXD(cUUID,cKeyLsTSI,@nTimeCache)

            //Enquanto estiver dentro do intervalo o sistema não executa a requisição
            If (nTimeNow - nTimeCache) < nIntervalTime
                Return {.F.,nTimeNow,nTimeCache} 
            EndIf 
        EndIf 

        If VarSetXD(cUUID,cKeyLsTSI,nTimeNow)
            lLogLS := .T. 
            nTimeCache := nTimeNow
        EndIf 
        Iif(!lLogLS, TafConOut('Nao foi possivel atribuir um valor para a chave ' + cKeyLsTSI + '.'), nil) 

        //Ps. Não é necessário tratar concorrência nesta situação por este motivo utilizei
        //a atribuição e acesso das variáveis no modo Dirty para diminuir as chances de erro.
    EndIf 

	If lLogLS 

		cCode 		:= "LS006"
		cModule		:= "84"
		cRoutine  	:= ProcName(1)
		cUser := RetCodUsr()
	
		//Função para gravar o uso de rotinas e enviar ao LS (License Server)
		Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)
	EndIf

Return {lLogLS,nTimeNow,nTimeCache}
