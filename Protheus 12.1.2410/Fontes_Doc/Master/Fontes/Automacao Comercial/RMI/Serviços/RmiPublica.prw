#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "RMIPUBLICA.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static oError       := Nil                      //Objeto que recebe a exceção que ocorreu na execução da query
Static oEnviaObj    := Nil                      //Objeto para execução do metodo SetArrayFil
Static aMINAux      := Array(6)                 //Array auxiliar da Tabela MIN
Static aStStructs   := {}                       //Array com a extrutura das tabelas já autilizadas
Static aStTemSta    := {}                       //Array que define as tabelas que tem o campo S_T_A_M_P_
Static lStBulk      := .F.                      //Indica se o Bulk pode ser utilizado
Static oStBulk      := nil                      //Objeto fwBulk
Static nStTamBulk   := 600                      //Tamanho do commit no Bulk
Static lStCargaIni  := .F.                      //Valida se esta executando modo carga inicial
Static aStDados    := {}                        //Array que recebe os dados da tabela a ser enviada
Static oEnvio       := Nil                      //Objeto que recebe a instancia da classe RmiEnviaObj conforme assinante
Static lGeraMHQ     := .F.                      //Variavel que define se deve ou não gerar a MHQ

Static lStRmixFil   := existFunc("rmixFilial")                  //Verifica se existe a função que vai retornar as filiais
Static cStCmpQrFi   := iif( lStRmixFil, "", ", MHP_FILPRO" )    //Campo de filial utilizado nas querys

//Definições do array aProcesso
#DEFINE MHNCOD              1
#DEFINE MHNTABELA           2
#DEFINE MHSTABSECUNDARIAS   3
#DEFINE MHNFILTRO           4
#DEFINE MHPCASSIN           5
#DEFINE MHNSECOBG           6
#DEFINE MHSTIPO             7
#DEFINE MHNCHAVE            8
#DEFINE MHPFILPRO           9
#DEFINE MHNCODGRP           10

//Definições do array aProcesso posição MHSTABSECUNDARIAS
#DEFINE MHSTABELA           1
#DEFINE MHSCHAVE            2
#DEFINE MHNCHAVE_PRINCIPAL  3
#DEFINE MHSFILTRO           4
#DEFINE MHSCONPUB           5
#DEFINE MHSTIPO             6

//Definições do retorno da função ultPublica
#DEFINE MINCPROCE   1
#DEFINE MINFILPUB   2
#DEFINE MINULTPUB   3

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPublica
Serviços que gera as Publicações

@type    function
@param 	 cEmpImp, Caractere, Empresa de publicação
@param 	 cFilImp, Caractere, Filial de publicação
@param 	 cPubNova, Caractere, Define se o novo controle de publicação (pelo S_T_A_M_P_) esta ativo 0=Não, 1-Sim 
@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIPublica(cEmpImp, cFilImp, cPubNova, cTempoMax, cTipo, cFiltro)
    
    Local lManual       := (cEmpImp == Nil .Or. cFilImp == Nil)
	Local lContinua     := IIF(lManual, .T., .F.)
    Local cSemaforo     := "RMIPUBLICA"
    Local cHoraInicio   := time()

    Default cPubNova    := "0"
    Default cTempoMax   := "00:05:00"
    Default cTipo       := "1"  //1=Processo, 2=Grupo
    Default cFiltro     := ""   //Código do processo ou grupo

    //Limita a 15m para a thread não ficar muito tempo sem desativar e limpar a memoria
    if cTempoMax > "00:15:00"
        cTempoMax := "00:15:00"
    endIf

    If !lManual

        //Alterado para RPCSetType(3) para não consumir licença
        RpcSetType(3) 
        If RpcSetEnv(cEmpImp, cFilImp, , , "LOJA", cSemaforo)
            lContinua := .T.
        EndIf
	EndIf

    //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)
    //Quando o filtro for passado não faz esta verificação porque deve haver mais de 1 job de publicação configurado, um para cada processo ou grupo.
    If empty(cFiltro) .and. existFunc("pshChkJob")
        lContinua := PSHChkJob()
    EndIf

	If lContinua

        LjGrvLog(cSemaforo, "Ambiente iniciado:", {cEmpImp, cFilImp, cPubNova, cTempoMax, cModulo, cTipo, cFiltro}) 

        //Valida a regra de compartilhamento da MIN quando controle de publicação pelo S_T_A_M_P_
        if cPubNova == "1" .and. ( fwModeAccess("MIN", 1) <> "C" .or. fwModeAccess("MIN", 2) <> "C" .or. fwModeAccess("MIN", 3) <> "C" )
            ljxjMsgErr(STR0006)     //"Regra de compartilhamento da tabela MIN incorreta, deve ser totalmente compartilhada."
            rpcClearEnv()
            return Nil
        endIf

    	//Trava a execução para evitar que mais de uma sessão ao mesmo tempo
        cSemaforo := "RMIPUBLICA" +"_"+ cTipo  +"_"+ cFiltro
		If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
            LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
            rpcClearEnv()
            Return Nil
		EndIf

        //Thread é encerrada quando, estiver sendo executada a mais tempo que o tempo maximo
        while elapTime(cHoraInicio, time()) <= cTempoMax

            //Novo controle de publicação pelo S_T_A_M_P_
            If cPubNova == "1"
                SHPPrePub(cTipo, cFiltro)
            Else
                RmiPrePub()
            EndIf

            sleep(5000)
        endDo

        //Libera semaforo de controle
        UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
    EndIf

    fwFreeArray(aStStructs)
    fwFreeArray(aStTemSta)
    fwFreeArray(aStDados)

    rpcClearEnv()

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RmiPrePub
Função responsavel por buscar os processo que devem gerar publicação considerando as filiais cadastradas

@author  Rafael Tenorio da Costa
@since 	 26/09/19
@version P12.1.17
/*/
//-----------------------------------------------------------------------
Function RmiPrePub()
	
    Local aTable := {}   //Array que ira receber a tabela principal (MHN) e os filhos da tabela (MHS)
    Local nX     := 0    //Variavel de loop

    //Retorna os processos que serão publicados
    aTable := RmiProPub()

    For nX := 1 To Len(aTable)
        StartJob("RmiPubSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aTable[nX] )        
        Sleep(5000)
    Next nX

    LjGrvLog(" RmiPrePub ","Fim do Processamento" )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubSel
Seleciona os registros que serão publicados

@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubSel(cEmpPub, cFilPub, aProcesso)

    Local cSemaforo := cEmpPub + cFilPub + aProcesso[1]      
    Local cSelect   := ""
    Local cSelectCab:= ""
    Local cWhereCab := ""
    Local cWhere    := ""
    Local cOrder    := ""
    Local cTabela   := ""
    Local cDB       := ""
    Local cPrefixo  := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
    Local cCmpExp   := cPrefixo + "_MSEXP"
    Local nFil      := 0
    Local cFilter   := ""

    lGeraMHQ := .T. 

    If aProcesso[5] <> "TERCEIROS"
        RpcSetType(3) // Para não consumir licenças na Threads
    EndIF

    RpcSetEnv(cEmpPub, cFilPub, , ,"LOJ" , "RMIPUBSEL")

    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    LjGrvLog("RMIPUBSEL", "Serviço iniciado:", {cEmpPub, cFilPub, aProcesso})  

    cDB := TcGetDB()
    LjGrvLog("RMIPUBSEL", "Conectado com banco de dados:", cDB)
    
    IIF(cDB == "MSSQL",cSelectCab := "SELECT TOP(50) R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "" ,"")
    
    IIF(cDB == "ORACLE",cSelectCab := " SELECT R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "","")
    IIF(cDB == "ORACLE",cWhereCab  := " AND ROWNUM <= 50 " ,"")
    
    IIF(cDB <> "ORACLE" .AND. cDB <> "MSSQL" ,cSelectCab := " SELECT R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "" ,"")
    IIF(cDB <> "ORACLE" .AND. cDB <> "MSSQL" ,cOrder  := " LIMIT 50 " ,"")

    LjGrvLog(" RmiPublica ", "Job RMIPUBSEL iniciado  ")  
    LjGrvLog(" RMIPUBSEL ", "Processo:   ",aProcesso)  
   
    //Valida existencia do campo de controle de exportação
    If (aProcesso[2])->( ColumnPos(cCmpExp) ) == 0
        LjGrvLog(" RMIPUBSEL ",I18n(STR0003, {cCmpExp}))     //"Campo #1 não existe, o serviço de publicação não será executado."
    Else

        //Seleciona os registros que serão publicados inclui tambem os deletados
        cTabela := GetNextAlias()

        MHP->( DbSetOrder(1) )  //MHP_FILIAL + MHP_CASSIN + MHP_CPROCE + MHP_TIPO
        If MHP->( DbSeek( xFilial("MHP") + aProcesso[5] + Padr(aProcesso[1], TamSx3("MHP_CPROCE")[1] ) + "1" ) ) .And. MHP->MHP_ATIVO == "1"

            oEnviaObj := RmiEnviaObj():New(aProcesso[5],aProcesso[1])
            oEnviaObj:SetArrayFil()

            For nFil:=1 To Len(oEnviaObj:aArrayFil)
                cFilbkp   := cFilAnt
                oEnviaObj:nFil := nFil
                RmiFilInt(oEnviaObj:aArrayFil[nFil][2],.T.)//Atuliza cfilAnt para gerar Xfilial correto.
                
                cSelect := cSelectCab
                LjGrvLog(" RMIPUBSEL ","Query Filial: " + oEnviaObj:aArrayFil[nFil][2])
                
                // -- Publicação olha para as tabelas secundárias? 
                RmiPub4Sec(aProcesso)

                TRY EXCEPTION

                    If !Empty(xFilial(aProcesso[2]))
                        cWhere := " AND " + cPrefixo + "_FILIAL =  '" + xFilial(aProcesso[2]) + "' " 
                    EndIf

                    //Tratamento de macro execução
                    cFilter := aProcesso[4]
                    If SubStr(cFilter, 1, 1) == "&"
                        cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
                    EndIf

                    cWhere  += cWhereCab
                    cSelect +=  " WHERE " + cCmpExp + " = '" + Space( TamSx3(cCmpExp)[1] ) + "'" + IIF(!Empty(cFilter), ' AND ' + AllTrim(cFilter), "") + cWhere
                    
                    // -- Deve ser sempre apos o ORDERBY  caso exista (banco Postgres)
                    cSelect += cOrder

                    LjGrvLog(" RMIPUBSEL ","QUERY Seleciona os registros que serão publicados " + cSelect)
                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                    
	                If !Empty(cFilbkp)
	                    RmiFilInt(cFilbkp,.T.)//Atuliza cfilAnt .T. 
	                EndIf
                //Se ocorreu erro
                CATCH EXCEPTION USING oError        
                    LjGrvLog(" RMIPUBSEL ","Erro ao executar a query " + AllTrim(cSelect) + ". O erro pode estar ocorrendo pois o filtro cadastrado para a tabela " + aProcesso[2] + " pode estar errado, por favor, verifique no cadastro de processo se o filtro esta cadastrado corretamente. Filtro -> " +  ' AND ' + AllTrim(cFilter))
                ENDTRY           

                //Se for igual a Nil, eh porque não deu erro na execução da query, segue o processo normal
                If oError == Nil

                    //Considera os registros deletados
                    SET DELETED OFF

                    While !(cTabela)->( Eof() )

                        DbSelectArea(aProcesso[2])
                        (aProcesso[2])->( DbGoTo( (cTabela)->REGISTRO ) )

                        If ValidaPub(aProcesso, cTabela)

                            //Grava publicação
                            RmiPubGrv(aProcesso, (cTabela)->REGISTRO, cCmpExp)
                        EndIf

                        (cTabela)->( DbSkip() )
                    EndDo
                    (cTabela)->( DbCloseArea() )

                    //Desconsidera os registros deletados
                    SET DELETED ON

                Else
                    //Se for diferente de Nil, deu erro na query e neste caso apenas limpo a variavel
                    //Essa variavel oError eh apenas uma variavel de controle
                    oError := Nil
                EndIf
            Next nFil

        EndIf

    EndIf

    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubGrv
Grava a publicação na tabela MHQ - Mensagens Publicadas

@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubGrv(aProcesso, nRegistro, cCmpExp, lAltExp)

    Local aArea      := GetArea()
    Local aAreasSec  := {}
    Local cJson      := ""
    Local cCmpHrExp  := StrTran(cCmpExp, "_MSEXP", "_HREXP")
    Local nX         := 0                                       //Variavel de loop 
    Local cTabTemp   := ""                                      //Variavel que recebera a tabela temporaria 
    Local cJsonFilho := ""                                      //Variavel que recebera o Json das tabelas filhas 
    Local lControle  := .T.                                     //Variavel de controle do Json das tabelas filhas 
    Local aRecTabSec := {}
    Local lSecObg    := .T.
    Local cProcesso  := aProcesso[1]
    Local cTabela    := aProcesso[2]
    Local aTableFil  := aProcesso[3]
    Local cSecObg    := aProcesso[6]
    Local cChave     := StrTran( aProcesso[8], "+", "+ '|' +" )  //Retorna campos que compoem a chave da publicação
    Local cUuid      := ""

    Default cCmpExp := ""
    Default lAltExp := .T.

    LjGrvLog(" RmiPubGrv ","Grava a publicação na tabela MHQ Function RmiPubGrv",{cProcesso, cTabela, nRegistro, cCmpExp, aTableFil})
    
    (cTabela)->( DbGoTo(nRegistro) )

    If !(cTabela)->( Eof() )

        //Executa funções da etapa de Pré publicação
        If ExistFunc("RmiFunExEt")
            LjGrvLog("RmiPubGrv", "Executando funções da etapa de Pré publicação", cProcesso)
            RmiFunExEt(cProcesso, "1", .T.)
        EndIf

        //Gera publicação da tabela principal
        LjGrvLog("RmiPubGrv", "Gerando publicação da tabela principal", cTabela)
        cJson := GeraJson(cTabela, 0)

        //Executa funções da etapa de Publicação
        If ExistFunc("RmiFunExEt")        
            LjGrvLog("RmiPubGrv", "Executando funções da etapa de Publicação", cProcesso)
            cJson := SubStr(cJson, 1, Len(cJson) - 1) + "," + RmiFunExEt(cProcesso, "2", "")
        EndIf

        //Complementa o cJson com as tabelas filhas
        For nX := 1 To Len(aTableFil) 

            //Executa query da tabela secundaria
            cTabTemp := GeraQuery(cTabela, aTableFil[nX])

            //Se for igual a Nil, eh porque não deu erro na execução da query, segue o processo normal
            If oError == Nil

                lControle   := .T.
                cJsonFilho  := ""

                While !(cTabTemp)->( Eof() )

                    (aTableFil[nX][1])->( DbGoTo( (cTabTemp)->REGISTRO_FILHO ) )

                    Aadd(aRecTabSec,{aTableFil[nX][1],(aTableFil[nX][1])->(RECNO())})
                    
                    If !(aTableFil[nX][1])->(deleted())
                        LjGrvLog(" RmiPubGrv ","chamada da funcao GeraJson(",{aTableFil[nX][1],",1,",lControle})
                        If lControle 
                            cJsonFilho := '"' + aTableFil[nX][1] + Iif(Empty(aTableFil[nX][6]),'": [', '_' + Alltrim(aTableFil[nX][6]) + '": [')                            
                        EndIf
                        cJsonFilho  += GeraJson(aTableFil[nX][1], 1, lControle, aTableFil[nX][6]) + ","
                        LjGrvLog(" RmiPubGrv ","Resultado cJsonFilho GeraJson "+cJsonFilho)
                        lControle   := .F.
                    Else
                        LjGrvLog(" RmiPubGrv ","O Registro " + cValToChar((aTableFil[nX][1])->(RECNO())) + " da tabela: " + aTableFil[nX][1] + " está deletado, por esse motivo será ignorado na geração das tabelas secundarias") 
                    EndIf

                    //Se for DA0 (Preco), entao considera apenas um item pois para o preço (DA0/DA1)
                    //as tabelas sao invertidas, o que eh filho (DA1) vira cabeçalho e o que é cabelho
                    //vira item (DA0). Fizemos isso para não estourar o tamanho de 1 MB do Json
                    If aTableFil[nX][1] == 'DA0'
                        Exit
                    EndIf
                    (cTabTemp)->( DbSkip() )
                EndDo

                If !Empty(cJsonFilho)
                    cJson := SubStr(cJson,1,Len(cJson) - 1) + ',' + SubStr(cJsonFilho,1,Len(cJsonFilho) - 1) + CRLF + "],"
                ElseIf cSecObg = "1" .And. Empty(cJsonFilho)
                    LjGrvLog(" RmiPubGrv ","Processo " +cProcesso+ " : O registro "+cValToChar(nRegistro)+" não será publicado, pois não houve registros na tabela " +aTableFil[nX][1]+ " (campo MHN_SECOBG habilitado).")                
                    lSecObg := .F.
                EndIf

                (cTabTemp)->( DbCloseArea() )   

            Else
                //Caso tenha erro, interrompe o loop e não grava a MHQ
                Exit
            EndIf        

        Next nX

        If oError == Nil 

            cJson := SubStr(cJson,1,Len(cJson) - 1) + CRLF + '}' 
            LjGrvLog(" RmiPubGrv ","Resultado Json que será gravado -> "+cJson)
            Begin Transaction
                If lSecObg

                    //Tratamento para TOTVS PDV (carga), tabelas sem chave única
                    if allTrim(cChave) == "R_E_C_N_O_"
                        cChave := cValToChar( (cTabela)->( Recno() ) )
                    else
                        cChave := (cTabela)->&(cChave) + IIF( (cTabela)->( Deleted() ), "|" + cValToChar( (cTabela)->( Recno() ) ), "")
                    endIf

                    cUuid := GravaMHQ(  cProcesso   ,;
                                        cTabela     ,; 
                                        cChave      ,; 
                                        cJson       ,; 
                                        "0"         )

                    //Executa funções da etapa de Pòs publicação
                    If ExistFunc("RmiFunExEt")
                        LjGrvLog("RmiPubGrv", "Executando funções da etapa de Pòs publicação", cProcesso)
                        RmiFunExEt(cProcesso, "3", .T.)
                    EndIf
                EndIf

                //Atualiza campos de _MSEXP e _HREXP (antiga publicação)
                If lAltExp
                    //Atualiza campos de controle de exportação da tabela principal
                    AtuCmpExp(cCmpExp, cCmpHrExp)

                    //-- Atualiza campos de controle de exportação das tabelas secundárias
                    //-- Guardo a Area de todas as tabelas secundárias que serão acessadas 
                    For nX := 1 To Len(aTableFil)
                        Aadd(aAreasSec,(aTableFil[nX][1])->(GetArea()))
                    Next
                    
                    // -- Posiciono e atualizo os campos de controle de publicação em todas as tabelas secundárias
                    For nX := 1 To Len(aRecTabSec)
                        DbSelectArea(aRecTabSec[nX][1])
                        (aRecTabSec[nX][1])->(DBGoTo(aRecTabSec[nX][2]))
                        AtuCmpExp(,,aRecTabSec[nX][1])
                    Next nX

                    // -- Retoro as alias atuais de na ordem decrescente
                    For nX := Len(aAreasSec) To 1 STEP -1
                        RestArea(aAreasSec[nX])
                    Next
                EndIf

                //Libera registro para distribuição
                //Sempre deve ser o ultimo processo antes do fim da transação
                if !lStBulk
                    MHQ->( dbSetOrder(7) )  //MHQ_FILIAL, MHQ_UUID, R_E_C_N_O_, D_E_L_E_T_
                    if !empty(cUuid) .and. MHQ->( dbSeek(xFilial("MHQ") + cUuid) ) .and. MHQ->MHQ_STATUS == "0"
                        recLock("MHQ", .F.)
                            MHQ->MHQ_STATUS := "1"  //0=Em publicação; 1=Liberado para distribuição
                        MHQ->( msUnLock() )
                    endIf
                endIf
                cUuid := ""

            End Transaction
        Else
            //Se for diferente de Nil, deu erro na query e neste caso apenas limpo a variavel
            //Essa variavel oError eh apenas uma variavel de controle
            oError := Nil
        EndIf
    EndIf

    LjGrvLog(" RmiPubGrv ","Fim da Gravação ")
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraJson
Função que gera o Json com os campos da tabela passada, 
no registro que esta posicionado

@author  Rafael Tenorio da Costa
@since   30/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraJson(cTabela, nTypeJson, lControle, cTipReg)

    Local cJson      := ""
    Local oReg      := JsonObject():New()    
    Local cTipo      := ""
    Local cCampo     := ""
    Local xConteudo  := ""
    Local nCont      := 1
    Local aStructExp := {}
    Local nPosStr    := 0
    Local cPrefixo   := ""
    
    Local cDB        := TcGetDB() //Recebe o nome do banco de dados
    Local aCampos    := {}
    Local aReg       := {}
    Local lJsonValid := .F. //Variavel que define se o resultado da query retornou um Json valido
    Local cQuery     := ""  //Variavel que recebe a query
    
    Default nTypeJson := 0 
    Default lControle := .F.
    Default cTipReg   := ""

    LjGrvLog(" GeraJson "," Function GeraJson(",{cTabela, nTypeJson, lControle, cTipReg})

    If nTypeJson > 0 .and. cTabela == "MIL" .and. Empty(cTipReg)
        cJson := ""
        LjGrvLog(" GeraJson "," Não é possivel gerar relacionamento entre as tabela MIL, o campo MHS_TIPO não foi incluido nas tabelas secundarias. Verifique o cadastro de Processo!")
        Return cJson
    EndIf
    
    If cTabela != "MIH"

        If cDb $ "MSSQL|ORACLE"
            lJsonValid := .T.
            cQuery := IIF(cDb == "MSSQL" , "SELECT TRIM(CONVERT(VARCHAR(8000),(SELECT * FROM " + RetSqlName(cTabela) + " WHERE R_E_C_N_O_ = " + cValtochar((cTabela)->(Recno()))+" For JSON Path,Without_Array_Wrapper))) AS RES", cQuery)
            cQuery := IIF(cDb == "ORACLE", "SELECT json_object(* returning clob)  AS Json_doc from " + RetSqlName(cTabela) + " WHERE R_E_C_N_O_ = " + cValtochar((cTabela)->(Recno()))                                           , cQuery)
        EndIf
    EndIf

    If lJsonValid .And. TCSqlToArr(cQuery,aReg) == 0 .And. Len(aReg) > 0

        lJsonValid := .F.

        //Verifica se o resultado da query é um Json valido
        If oReg:fromJson(aReg[1][1]) == nil

            lJsonValid := .T.
            
            aCampos := oReg:GetNames()

            For nCont := 1 To Len(aCampos)
                If Valtype(oReg[aCampos[nCont]]) == "C"
                    oReg[aCampos[nCont]] := Alltrim(oReg[aCampos[nCont]])
                EndIf
            Next nCont 
        EndIf

    Else

        lJsonValid := .F.
    EndIf

    If !lJsonValid
        //Carrega a estrutura da tabela
        if ( nPosStr := aScan(aStStructs, {|x| x[1] == cTabela}) ) == 0 
            aAdd(aStStructs, {cTabela, (cTabela)->( DbStruct() )} )
            nPosStr := len(aStStructs)
        endIf 
        aStructExp := aClone( aStStructs[nPosStr][2] )

        If !Empty(aStructExp)
            cCampo    := AllTrim(aStructExp[1][DBS_NAME] )
            cPrefixo  := SubStr(cCampo, 1, at('_',cCampo)-1)
        EndIf

        LjGrvLog(" GeraJson "," aStructExp estrutura da tabela -> ",aStructExp)
        For nCont:=1 To Len(aStructExp)
            
            cTipo     := AllTrim( aStructExp[nCont][DBS_TYPE] )
            cCampo    := AllTrim( aStructExp[nCont][DBS_NAME] )
            xConteudo := (cTabela)->(FieldGet(nCont))
            
            //Campos em exceção XXX_USERLGA e XXX_USERLGI
            if cCampo $ (cPrefixo+"_USERLGA|" + cPrefixo+"_USERLGI|" + cPrefixo+"_USERGA|" + cPrefixo+"_USERGI|" + cPrefixo+"_MSUIDT|")
                Loop
            EndIf

            //Verifica se eh carga inicial para soh exportar campos preenchidos
            if cargaInicial(cTipo, cCampo, xConteudo)
                loop
            endIf

            If cTipo == "M" .And. Eval({|| xConteudo := AllTrim(xConteudo),SubStr(xConteudo, 1, 1) == "{" .And. SubStr(xConteudo, Len(xConteudo), 1) == "}"})
                CampoJson(xConteudo, cCampo,oReg)         
            Else
                //Trata o conteudo de cada tag
                oReg[cCampo] := Conteudo(cTipo, xConteudo)
            EndIf
        Next nCont
    EndIf

    If nTypeJson > 0 .and. cTabela == "MIL" .and. !Empty(cTipReg)  
        Relacionamento(cTabela,oReg)
    EndIF

    oReg["STAMP"] := Conteudo("C", FwTimeStamp(3)) 

    cJson := oReg:ToJson()

    fwFreeArray(aStructExp)
    fwFreeObj(oReg)
Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraQuery
Gera a query da tabela pai com a(s) tabela(s) filha(s)

@author  Bruno Almeida
@since   31/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraQuery(cTb, aTb)

    Local cQuery        := ""                   //Recebe a query
    Local cCont         := GetNextAlias()       //Recebe o nome do proximo alias
    Local aCab          := Separa(aTb[3],'+')   //Variavel que ira receber a chave do cabecalho
    Local aSec          := Separa(aTb[2],'+')   //Variavel que ira receber a chave das tabelas secundarias
    Local nX            := 0                    //Variavel de loop
    Local cWhereFilha   := ""
    Local cPrefixoSec   := IIF( SubStr( aTb[1], 1, 1) == "S", SubStr( aTb[1], 2), aTb[1] ) 
    Local aAux          := {}
    Local cFilter       := ""

    cQuery := " SELECT DISTINCT B.R_E_C_N_O_ AS REGISTRO_FILHO"
    cQuery += " FROM " + RetSqlName(cTb) + " A"
    cQuery +=       " INNER JOIN " + RetSqlName(aTb[1]) + " B " + " ON " + RetJoin(aTb,,,cTb,aTb[1])
    cQuery += " WHERE "

    For nX := 1 To Len(aSec)
        If aSec[nX] == cPrefixoSec + "_FILIAL" .AND. xFilial(cTb) <> xFilial(aTb[1])
            cQuery += 'B.' + AllTrim(aSec[nX]) + " = '" + xFilial(aTb[1]) + "' AND " 
        Else   
            cQuery += " B." + AllTrim(aSec[nX]) + " = " + RetCont( cTb, AllTrim(aCab[nX]) ) + " AND "
        EndIf 
    Next nX

    //Concatena na query o filtro da tabela filha
    If Len(aTb) >= 4 .AND. !Empty(aTb[4])
        //Tratamento de macro execução
        cFilter := aTb[4]
        If SubStr(cFilter, 1, 1) == "&"
            cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
        EndIf
        cWhereFilha := AllTrim( cFilter) + " AND "
    EndIf

    If "D_E_L_E_T_" $ cWhereFilha
        cWhereFilha := StrTran(cWhereFilha, "D_E_L_E_T_", "B.D_E_L_E_T_")
    Else
        cWhereFilha := cWhereFilha + " B.D_E_L_E_T_ = ' ' AND "
    EndIf

    // -- Tratamento para listar itens deletados das tabelas secundarias caso o campo de controle esteja em branco
    // -- Obs: somente é considerado caso a tabela secundarias seja considerada na publicação (aTb[5] == "1")
    If Len(aTb) >= 5 .AND. aTb[5] == "1"
        aAux := Separa(Alltrim(UPPER(cWhereFilha)), "AND")
        cWhereFilha := ""
        
        For nX := 1 To Len(aAux)
            If "D_E_L_E_T_" $ aAux[nx] .AND. (aTb[1])->(ColumnPos(cPrefixoSec + "_MSEXP")) > 0 
                cWhereFilha += "B.D_E_L_E_T_ = ' ' OR (B.D_E_L_E_T_ = '*' AND B." + cPrefixoSec + "_MSEXP = '" + Space(TamSx3(cPrefixoSec + "_MSEXP")[1]) + "') AND "
            Else
                If !Empty(aAux[nx])
                    cWhereFilha +=  aAux[nX] + " AND "
                EndIf
            EndIf
        Next nX

    EndIf 

    cQuery += cWhereFilha

    cQuery := SubStr(cQuery,1,Len(cQuery) - 4)
    LjGrvLog(" GeraQuery "," aquery da tabela pai com a(s) tabela(s) filha(s) -> ",cQuery)
    
    TRY EXCEPTION
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cCont, .T., .F.)
        
    //Se ocorreu erro
    CATCH EXCEPTION USING oError        
        LjGrvLog(" RMIPUBSEL ","Erro ao executar a query " + AllTrim(cQuery) + ". O erro pode estar ocorrendo pois o filtro cadastrado para a tabela " + aTb[1] + " pode estar errado, por favor, verifique no cadastro de processo se o filtro esta cadastrado corretamente. Filtro -> " +  " AND " + AllTrim(aTb[4]))
    ENDTRY

Return cCont

//-------------------------------------------------------------------
/*/{Protheus.doc} RetJoin
Retorna o relacionamento entre as tabelas

@author  Bruno Almeida
@since   01/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetJoin(aTb,cCab,cSec,cTabCab,cTabSec)

    Local cRet  := ""       //Variavel de retorno
    Local nX    := 0        //Variavel de loop
    Local lNotMatch :=  .F. // -- Indica se as duas tabelas tem o compartilhamento diferente
    Local cPrefixoSec := "" // -- Prefixo da tabela secundarias

    Local aCab  := IIF(Empty(cCab), Separa(aTb[3],'+'), Separa(cCab,'+')) //Variavel que ira receber a chave do cabecalho
    Local aSec  := IIF(Empty(cSec), Separa(aTb[2],'+'), Separa(cSec,'+')) //Variavel que ira receber a chave das tabelas secundarias
    
    Default cTabCab  := ""
    Default cTabSec  := ""

    If !Empty(cTabCab) .AND. !Empty(cTabSec)
        If lNotMatch := xFilial(cTabCab) <> xFilial(cTabSec)
            cPrefixoSec := IIF( SubStr( cTabSec, 1, 1) == "S", SubStr( cTabSec, 2), cTabSec ) 
        EndIf   
    EndIf 

    For nX := 1 To Len(aCab)

        //Tratamento para chave do cabeçalho com mais campos que as tabelas secundarias
        If nX > Len(aSec)
            Exit
        EndIf

        If lNotMatch .AND. aSec[nX] == cPrefixoSec + "_FILIAL"
            cRet += 'B.' + AllTrim(aSec[nX]) + " = '" + xFilial(cTabSec) + "' AND "   
        Else
            cRet += 'B.' + AllTrim(aSec[nX]) + ' = ' + 'A.' + AllTrim(aCab[nX]) + ' AND '
        EndIf 
    Next nX 

    cRet := SubStr(cRet,1,Len(cRet) - 4)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetValor
Retorna o conteudo do campo que é passado como parametro

@author  Bruno Almeida
@since   01/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCont(cTb,cCampo)

    Local cTipo     := TamSx3(cCampo)[3] //Pega o tipo do campo
    Local xConteudo := (cTb)->&( cCampo ) //Pega o conteudo do campo

    Do Case
        Case cTipo $ "C|M|L"
            xConteudo := "'" + xConteudo + "'"

        Case cTipo $ "N"
            xConteudo := cValToChar(xConteudo)

        Case cTipo == "D"
            xConteudo := "'" + DtoS(xConteudo) + "'"
        
    End Case

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiValSf2
Valida se é uma nota de saída de uma venda vinda do Live

@author  Bruno Almeida
@since   14/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RmiValSf2(nRecSf2, aProcesso)

    Local aAreaSF2  := SF2->( GetArea() )
    Local lRet      := .F.  //Variavel de retorno
    Local cQuery    := ""   //Armazena a query
    Local cAlias    := ""   //Armazena o próximo alias
    Local cAliasMhq := ""   //Armazena o próximo alias da MHQ
    Local cOrigem   := PadR("PROTHEUS", TamSx3("MHQ_ORIGEM")[1])
    Local cProcesso := PadR(aProcesso[1], TamSx3("MHQ_CPROCE")[1])
    Local cChaveUni := SF2->&( StrTran( Posicione("MHN", 1, xFilial("MHN") + cProcesso, "MHN_CHAVE"), "+", "+ '|' +" ) )
    Local cStatus   := "2"

    SF2->(DbGoTo(nRecSf2))

    If SF2->(Recno()) == nRecSf2
        cAlias := GetNextAlias()

        cQuery := "SELECT L1_UMOV "
        cQuery += "     , R_E_C_N_O_"
        cQuery += "  FROM " + RetSqlName("SL1")
        cQuery += " WHERE L1_FILIAL = '" + SF2->F2_FILIAL + "'"
        cQuery += "   AND L1_DOC = '" + SF2->F2_DOC + "'"
        cQuery += "   AND L1_SERIE = '" + SF2->F2_SERIE + "'"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
        If !(cAlias)->(Eof()) .AND. !Empty((cAlias)->L1_UMOV)

            cAliasMhq := GetNextAlias()

            cQuery := ""
            cQuery += "SELECT MHQ_ORIGEM"
            cQuery += "     , R_E_C_N_O_"
            cQuery += "  FROM " + RetSqlName("MHQ")
            cQuery += " WHERE MHQ_UUID = '" + (cAlias)->L1_UMOV + "'"

            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMhq, .T., .F.)
            If !(cAlias)->(Eof()) .AND. AllTrim((cAliasMhq)->MHQ_ORIGEM) == "LIVE"
                //Para os Registro de integração sera atualizado o campo _MSEXP
                //Para que não sejam recuperado nas proximas Querys. 
                lRet := .F.
                RecLock("SF2",.F.)
                    SF2->F2_MSEXP := DtoS(dDataBase) 
                SF2->(MsUnLock())
            Else
                lRet := .T.
            EndIf
            (cAliasMhq)->( DbCloseArea())
        Else
            lRet := .T.
        EndIf
        (cAlias)->( DbCloseArea())

    EndIf

    // Valido se a nota já foi integrada e transmitida
    If lRet
        
        MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE + MHQ_CHVUNI + MHQ_EVENTO + DTOS(MHQ_DATGER) + MHQ_HORGER
        
        If MHQ->( DbSeek( xFilial("MHQ") + cOrigem + cProcesso + cChaveUni ) )  

            if Alltrim(MHQ->MHQ_STATUS) == cStatus 
                //Atualiza campos de controle de exportação
                AtuCmpExp("F2_MSEXP", "F2_HREXP")
                lRet  := .F.     
            endif
            LjGrvLog(" RmiValSf2 ","Nota Fiscal de Saida com o a Chave Unica" + cChaveUni + " não foi integrada, pois existe uma mesma nota já integrada no conciliador ")
        EndIf
        
    endif

    RestArea(aAreaSF2)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaPub
Centraliza as validações que definem se a publicação será gerada.

@author  Rafael Tenorio da Costa
@since   05/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaPub(aProcesso, cTabela)

    Local aArea    := GetArea()
    Local lRetorno := .T.

    Do Case

        //Valida se é uma nota de saída de uma venda vinda do Live
        Case aProcesso[1] == "NOTA DE SAIDA" .And. aProcesso[2] == "SF2"

            lRetorno := RmiValSf2( (cTabela)->REGISTRO, aProcesso )

        //Valida se a nota fiscal de saida já foi publicada, para publicar o cancelamento de nota fiscal de saida
        Case aProcesso[1] == "NOTA SAIDA CANC"
            lRetorno := ValNfsPub()

    End Case

    RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ValNfsPub
Valida se a nota fiscal de saida já foi publicada, para publicar o cancelamento da nota fiscal de saida

@author  Rafael Tenorio da Costa
@since   05/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValNfsPub()

    Local lRetorno  := .F.
    Local cOrigem   := PadR("PROTHEUS", TamSx3("MHQ_ORIGEM")[1])
    Local cProcesso := PadR("NOTA DE SAIDA", TamSx3("MHQ_CPROCE")[1])
    Local cChaveUni := SF2->&( StrTran( Posicione("MHN", 1, xFilial("MHN") + cProcesso, "MHN_CHAVE"), "+", "+ '|' +" ) )

    MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE + MHQ_CHVUNI + MHQ_EVENTO + DTOS(MHQ_DATGER) + MHQ_HORGER
    If MHQ->( DbSeek( xFilial("MHQ") + cOrigem + cProcesso + cChaveUni ) )

        lRetorno := .T.
    Else

        //Atualiza campos de controle de exportação
        AtuCmpExp("F2_MSEXP", "F2_HREXP")
        lRetorno  := .F.        
    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCmpExp
Atualiza campos de controle de exportação, onde a tabela já deve estar posicionada.

@author  Rafael Tenorio da Costa
@since   05/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuCmpExp(cCmpExp, cCmpHrExp, cTabela)
    
    Local cPrefixo     := ""

    Default cTabela   := FwTabPref(cCmpExp)
    
    // -- Caso não seja enviado os campos monto com base na tabela
    If Empty(cCmpExp) .Or. Empty(cCmpHrExp)
        cPrefixo  := IIF( SubStr( cTabela, 1, 1) == "S", SubStr( cTabela, 2), cTabela )
        cCmpExp   := cPrefixo + "_MSEXP"
        cCmpHrExp := cPrefixo + "_HREXP"
    EndIf 

    RecLock(cTabela, .F.)
        If (cTabela)->( ColumnPos(cCmpExp) ) > 0
            (cTabela)->&( cCmpExp ) := DtoS( Date() )
        EndIf

        If (cTabela)->( ColumnPos(cCmpHrExp) ) > 0
            (cTabela)->&( cCmpHrExp ) := Time()
        EndIf
    (cTabela)->( MsUnLock() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Função utilizada por rotina colocadas no Schedule

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

    Local aParam  := {}

    aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
                "ParamDef"          ,;  //Pergunte do relatorio, caso nao use passar ParamDef
                /*Alias*/           ,;	
                /*Array de ordens*/ ,;
                /*Titulo*/          }

Return aParam

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RmiPub4Sec
Função responsavel por verificar se houve alteração nas tabelas secundárias e caso houver realiza a limpeza do campo _MSEXP

@type       Static Function
@author     Lucas Novais (lnovais@)
@since      14/07/2021
@version    12.1.33
@param aProcesso, Array, processo representado nas tabelas MHN990 e MHS990

@return Nil,Nulo
/*/
//-------------------------------------------------------------------------------------
Static Function RmiPub4Sec(aProcesso)
    
    Local nTabSec   := 0    // -- Variavel de controle (FOR)
    Local cPrefixoS := ""   // -- Prefixo da tabela secundária
    Local cPrefixoP := ""   // -- Prefixo da tabela primaria
    Local cCmpExpS  := ""   // -- Campo de controle da tabela secundária
    Local cCmpExpP  := ""   // -- Campo de controle da tabela primaria
    Local cTabela   := ""   // -- Alias temporario
    Local cCmpsGrp  := ""   // -- Group By utilizado na query
    Local cSelect   := ""   // -- Query completa
    Local aRecsOK   := {}   // -- Variavel que armazenas os recnos já processados
    local lMSEXP    := .F.  // -- Indica se tem o campo de controle 
    Local cFilter   := ""
   

    For nTabSec := 1 To Len(aProcesso[3])

        If aProcesso[3][nTabSec][5] $ "1|3" // -- Indica que é para considerar a secundárias para a publicação
            
            cPrefixoS := IIF( SubStr( aProcesso[3][nTabSec][1], 1, 1) == "S", SubStr( aProcesso[3][nTabSec][1], 2), aProcesso[3][nTabSec][1] )
            cPrefixoP := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
            
            cCmpExpS  := cPrefixoS + "_MSEXP"
            cCmpExpP  := cPrefixoP + "_MSEXP"

            //Tratamento de macro execução
            cFilter := aProcesso[3][nTabSec][4]
            If SubStr(cFilter, 1, 1) == "&"
                cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
            EndIf

            IF !Empty(cFilter)
                cFilter := " AND " + cFilter
            Endif

            lMSEXP := (aProcesso[3][nTabSec][1])->(ColumnPos(cCmpExpS)) > 0

            If lMSEXP

                TRY EXCEPTION
                    cTabela  := GetNextAlias()
                    cCmpsGrp := "A." + StrTran(aProcesso[3][nTabSec][2],"+",", A.")
                    
                    BeginContent var cSelect
                    
                        SELECT TOP(50) B.R_E_C_N_O_ AS RECNO_PRINCIPAL 
                        FROM %Exp:RetSqlName(aProcesso[3][nTabSec][1])% AS A
                        INNER JOIN %Exp:RetSqlName(aProcesso[2])% AS B
                        ON %Exp:RetJoin(,aProcesso[3][nTabSec][2],aProcesso[3][nTabSec][3],aProcesso[3][nTabSec][1],aProcesso[2])%
                        WHERE A.%Exp:cCmpExpS% = '%Exp:Space(TamSx3(cCmpExpS)[1])%' 
                        AND A.%Exp:cPrefixoS%_FILIAL = '%Exp:xFilial(aProcesso[3][nTabSec][1])%'
                        %Exp:cFilter%
                        GROUP BY %Exp:cCmpsGrp% ,B.R_E_C_N_O_

                    EndContent

                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                    LjGrvLog(" RmiPub4Sec ","QUERY Seleciona os registros secundárias que serão publicados " + cSelect)

                CATCH EXCEPTION USING oError
                    LjGrvLog(" RmiPub4Sec ","Erro ao executar a query " + AllTrim(cSelect))
                    LjGrvLog(" RmiPub4Sec ","ERROR " + AllTrim(oError:Description))
                ENDTRY
            Else
                LjGrvLog(" RmiPub4Sec ","Campo [" + cCmpExpS  + "] não criado na tabela [" + aProcesso[3][nTabSec][1] + "]. Tabela não será considerada na geração da publicação." )
                LjGrvLog(" RmiPub4Sec ","Com isso, caso a tabela [" + aProcesso[3][nTabSec][1] + "] sofra alteração não será gerada publicação por meio dela." )
            EndIf 

            If oError == Nil .And. lMSEXP
                //Considera os registros deletados
                SET DELETED OFF
                While !(cTabela)->( Eof() )
                    
                    If (aScan(aRecsOK,(cTabela)->RECNO_PRINCIPAL)) == 0 

                        DbSelectArea(aProcesso[3][nTabSec][1])
                        (aProcesso[2])->(DBGoTo((cTabela)->RECNO_PRINCIPAL))
                        
                        If !Empty((aProcesso[2])->&(cCmpExpP))

                            RecLock(aProcesso[2], .F.)
                                REPLACE (aProcesso[2])->&(cCmpExpP) WITH ""
                            (aProcesso[2])->(MsUnLock())
                        EndIf 

                        // -- Armazeno o recno processado para evitar duplo processamento 
                        aAdd(aRecsOK,(cTabela)->RECNO_PRINCIPAL)

                    EndIf 
                    (cTabela)->( DbSkip() )
                EndDo
                (cTabela)->( DbCloseArea() )

                //Desconsidera os registros deletados
                SET DELETED ON

            EndIf 
        Else
            LjGrvLog(" RmiPub4Sec "," A Tabela: [" + aProcesso[3][nTabSec][1] + "] Não é considerada para a publicação do processo: [" +  aProcesso[1] + "]")
        EndIf 

    Next nTabSec

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CampoJson
Publica o um campo memo com conteudo em json.

@param   cJson, Caractere, Json em string que será publicado
@return  Caractere, Conteudo Json em string no formuto da publicação  
@author  Rafael Tenorio da Costa
@since   13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CampoJson(cJson, cCampoX3,oReg)

    Local cTag      := ""
    Local xConteudo := Nil
    Local cTipo     := ""
    Local oJson     := JsonObject():New()
    Local nCont     := 0

    //Carrega configurações do tipo do cadastro        
    oJson:FromJson(cJson)

    if oJson:hasProperty("Components")

        For nCont:=1 To Len(oJson["Components"])

            cTag      := oJson["Components"][nCont]["IdComponent"]
            xConteudo := oJson["Components"][nCont]["ComponentContent"]
            cTipo     := AllTrim( Upper( oJson["Components"][nCont]["ContentType"] ) )
            cTipo     := IIF( cTipo == "NUMBER", "N", IIF(cTipo == "LOGICAL", "L", "C") )

            //Trata o conteudo de cada tag
            oReg[cTag] := Conteudo(cTipo, xConteudo)
        Next nCont
    else

        LjxjMsgErr("O conteúdo do campo " + cCampoX3 + " no formato JSON está fora do padrão, pois não possui a tag [Components]. Portanto, não será publicado.", /*cSolucao*/, "RmiPublica", cJson)
    endIf

    FwFreeObj(oJson)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Conteudo
Trata o conteudo de cada tag que será publicado.

@param   cTipo, Caractere, Tipo que o conteudo deve ter para ser publicado
@param   xConteudo, Indefinido, Conteudo da tag que será publicado 
@param   cTag, Caractere, Indentificador da Tag
@return  Caractere, Tag com o Conteudo que será publicado formatada   
@author  Rafael Tenorio da Costa
@since   13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Conteudo(cTipo, xConteudo)

    Local cRetorno := ""

    Do Case

        Case cTipo == "C"

            //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
            xConteudo := StrTran(xConteudo,'"','')
            xConteudo := StrTran(xConteudo,"'","")
            xConteudo := StrTran(xConteudo,"\","\\")
            
            cRetorno := AllTrim(xConteudo)

        Case cTipo == "M"

            xConteudo := AllTrim(xConteudo)
            //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
            xConteudo := StrTran(xConteudo,'"','')
            xConteudo := StrTran(xConteudo,"'","")
            xConteudo := StrTran(xConteudo,"\","\\")
            
            cRetorno := AllTrim(xConteudo)            

        Case cTipo == "N"
            cRetorno := xConteudo            

        Case cTipo == "D"
            cRetorno := DtoS(xConteudo)

        Case cTipo == "L"
            cRetorno := IIF(valType(xConteudo) <> "L" .or. empty(xConteudo) .or. !xConteudo, .F., .T.) //Converte o conteudo para logico, caso não seja logico ou esteja vazio, assume o valor .F.

        OTherWise
            cRetorno :=  STR0004    //"Tipo do campo inválido"            

    End Case

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Relacionameno
Inclui no json de publicação as tags que não fazem parte da tabela MIL

@param   cTabela, Caractere, Tabela do nó publicado
@param   aStructExp, Array, Estrutura da tabela do nó publicado
@param   cJson, Caractere, Json para publicação
@return  cJson, Json com o Conteudo alterado para publicação
@author  Danio Rodrigues
@since   29/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Relacionamento(cTabela,oReg)

    Local oJson         := JsonObject():new()
    Local nItem         := 0
    Local cContSai      := ""
    Local cContTip      := ""
    Local cTipo         := ""
    Local cCampo        := ""
    Local xConteudo     := ""

    Default aStructExp  := {}
    Default cTabela     := ""

    cContTip := oReg["MIL_TIPREL"]
    cContSai := oReg["MIL_SAIDA"]

    DbSelectArea("MIH")
    MIH->(DbSetOrder(01))
    If MIH->(Dbseek(xFilial("MIH") + PadR(cContTip,TamSX3("MIH_TIPCAD")[1]) + cContSai ))
        oJson:fromJson(MIH->MIH_CONFIG)
        For nItem := 1 to Len(oJson["Components"])           

            cTipo     := Valtype(oJson["Components"][nItem]["ComponentContent"])
            cCampo    := oJson["Components"][nItem]["IdComponent"]
            xConteudo := oJson["Components"][nItem]["ComponentContent"]
        
            //Trata o conteudo de cada tag
            oReg[cCampo] := Conteudo(cTipo, xConteudo)

        Next nItem
    Else
        LjGrvLog(" Relacionamento ", "Tipo de cadastro (" + cContTip + "), e tipo de Saida (" + cContSai + ")  não encontrado, favor verificar se o processo de cadastro auxiliar foi realizado!")
    EndIF    

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPPrePub
Função responsavel encontrar os processos habilidados e iniciar a publicação dos registros

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cEmpPub, Caractere, Empresa de publicação
@param 	 cFilPub, Caractere, Filial de publicação

/*/
//-----------------------------------------------------------------------
Function SHPPrePub(cTipo, cFiltro)

    Local nX          	:= 0   				// -- Variavel de controle
    Local nI          	:= 0   				// -- Variavel de controle
    Local aTable      	:= {}
    Local aUltPublica 	:= {}
    Local aFilsPub    	:= {}  				// -- Array com as filiais que irão ser publicadas
    Local aFilProc    	:= {}
    Local cProcessos    := ""
    Local cGrupos       := ""
    Local lGrupo        := .F.
    Local aProcGrupo    := {}
    Local nPos          := 0

    Default cTipo       := "1"  //1=Processo, 2=Grupo
    Default cFiltro     := ""   //Código do processo ou grupo
    
    //Gera carga para novas lojas
    pendenteCarga()

    //Retorna os processos que serão publicados
    IIF(cTipo == "1", cProcessos := cFiltro, cGrupos := cFiltro)
    lGrupo := cTipo == "2" .and. MHN->( columnPos("MHN_CODGRP") ) > 0
    aTable := RmiProPub(cProcessos, cGrupos, lGrupo)

    //Retorna a data\hora da ultima publicação dos processos
    aUltPublica := ultPublica()

    For nX := 1 To Len(aTable)

        aFilProc := aTable[nX][MHPFILPRO]

        //Verifica\Retorna para quais filiais deve ser feita a publicação do processo
        aFilsPub := publica(aTable[nX], aUltPublica, aFilProc)

        For nI := 1 To len(aFilsPub)

            //Carrega processos por grupo
            if lGrupo

                if ( nPos := aScan(aProcGrupo, {|x| x[1] == aTable[nX][MHNCODGRP]}) ) == 0
                    aAdd(aProcGrupo, { aTable[nX][MHNCODGRP], {} })
                    nPos := len(aProcGrupo)
                endIf

                aAdd(aProcGrupo[nPos][2], { aFilsPub[nI], aTable[nX] })

            else

                StartJob("SHPPubSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, aFilsPub[nI], aTable[nX] )
                sleep(1000)
            endIf

        Next nI 

    Next nX

    //Publica por grupo, abre uma thread por grupo
    if lGrupo
        for nPos:=1 to len(aProcGrupo)
            startJob("pshPubGrp", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aProcGrupo[nPos])
            sleep(1000)
        next nPos

        //Grava a ultima execução do JOB RmiPublica
        if findFunction("RmiGrvStSv") .and. !empty(cGrupos)
            RmiGrvStSv("RMIPUBLICA", cEmpAnt, cFilAnt, "", "", cGrupos)
        endIf        
    endIf

    fwFreeArray( aProcGrupo  )
    fwFreeArray( aTable      )
    fwFreeArray( aUltPublica )
    fwFreeArray( aFilsPub    )
    fwFreeArray( aFilProc    )

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} SHPPubSel
Função responsavel por buscar os processo que devem gerar publicação considerando as filiais cadastradas

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cEmpPub, Caractere, Empresa de publicação
@param 	 cFilPub, Caractere, Filial de publicação
@param 	 aProcesso, Array, Array com os dados do processo que será publicadi

/*/
//-------------------------------------------------------------------------
Function SHPPubSel(cEmpPub, cFilPub, aProcesso)

    Local cSemaforo    := ""                                                                                    // -- Controle de execução
    Local cQuery       := ""                                                                                    // -- Variavel utilizada para armazenar Query
    Local cWhere       := ""                                                                                    // -- Variavel utilizada para armazenar where da Query
    Local cTabela      := ""                                                                                    // -- Armazena alias da query que será executada
    Local cTabelaMIN   := ""                                                                                    // -- Armazena alias da query que será executada
    Local cDB          := ""                                                                                    // -- Banco de dados atual
    Local cPrefixo     := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )     // -- Prefixo da tabela 
    Local nMaxbloco    := IIF( lStBulk, nStTamBulk, 100)                                                        // -- Numero maximo de registros na query
    Local cMsgError    := ""                                                                                    // -- Mensagem de erro          
    Local oUltRecno    := JsonObject():New()                                                                    // -- Json com ultimos recnos
    Local aAreaMin     := {}                                                                                    // -- Area da tabela MIN
    Local nUltimoRecno := 0
    Local nRecno       := 0
    Local cFilter      := ""
    Local cCmpExp      := cPrefixo + "_MSEXP"  //Ajuste loop
    Local lContinua    := .T.
    Local nTamQuery    := 12000
    Local nCont        := 0
    Local nI           := 0
    Local cSTAMPChar   := ""
    Local cUltAltera   := ""
    Local nQtdReg      := 0
    Local nX           := 0
    Local aReg         := {} // -- Array que armazena os registros que serão publicados:
    Local nReg         := 0 // -- Contador de registros que serão publicados

    if !empty(cFilPub)

        If aProcesso[5] <> "TERCEIROS"
            RpcSetType(3) // Para não consumir licenças na Threads
        EndIF

        RpcSetEnv(cEmpPub, cFilPub, , , "LOJA", "SHPPubSel")
    endIf

    cSemaforo := "SHPPUBSEL" +"_"+ cEmpPub +"_"+ xFilial(aProcesso[2]) +"_"+ aProcesso[1]
    
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        rpcClearEnv()        
        Return Nil
    EndIf

    cDB := Upper(TcGetDB())
    cSTAMPChar    := Iif(cDB == "MSSQL" , "convert(varchar(23),MAX(S_T_A_M_P_), 21 )", Iif(cDB == "POSTGRES" , "to_char(MAX(S_T_A_M_P_),'YYYY-MM-DD HH:MI:SS.MS')",Iif(cDB == "ORACLE" ,"to_char(MAX(S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.FF')","")))

    //Valida se é carga inical
    lStCargaIni := superGetMv("MV_PSHCAIN", .F., .F.)

    ljxjMsgErr("Publica" + " - " + cSemaforo + " - " + time() + " - " + cValTochar( ThreadId() ), /*cSolucao*/, /*cRotina*/, {cEmpAnt, cFilAnt, aProcesso})


    For nX := 1 To Len(aProcesso[11])

        Do Case
            Case Alltrim(aProcesso[11][nX]) == "SIGAGPC"
                // -- Cria objeto de envio para o SIGAGPC
                oEnvio := RmiEnvSigaGpcObj():New(Alltrim(aProcesso[1]))
                
            Case Alltrim(aProcesso[11][nX]) == "SMARTLINK"
                // -- Cria objeto de envio para o SmartLink (será alterado)
                oEnvio := RmiEnvSmartLinkObj():New(Alltrim(aProcesso[1]))
                Conout("Envio direto habilitado para o assinante "+Alltrim(aProcesso[11][nX])+", processo: " + Alltrim(aProcesso[2]) + " - " + Alltrim(aProcesso[1]) )

            OTherWise
                lGeraMHQ := .T.
        End Case 

    Next nX 


    If oEnvio <> Nil
        // -- Verifica se o objeto de envio possui a propriedade qtdEnvio
        If oEnvio:oConfProce <> Nil .And. oEnvio:oConfProce:hasProperty("qtdEnvio")   
            nMaxbloco := oEnvio:oConfProce["qtdEnvio"]
        EndIf

    EndIf
    
    //Inicia gravação do fwBulk
    iniciaBulk()

    //Verifica se tem mais registros para processar depois de processar a quantidade do nMaxbloco
    while lContinua
        
        // -- Query que retorna data da ultima publicação para o processo
        cTabelaMIN := GetNextAlias()
        cQuery := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("MIN")
        cQuery += " WHERE MIN_CPROCE = '" + aProcesso[1] + "' "
        cQuery += " AND MIN_FILPUB = '" + xFilial(aProcesso[2]) + "' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)

        LjGrvLog(" SHPPubSel ","Query que lista a ultima publicação do proceso/filial atual atual:", cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry ( , , cQuery), cTabelaMIN, .T., .F.)

        // -- Se for  EOF indica que não existe ainda o controle do processo atual para a filial de publicação atual
        // -- e caso não exista preenche o Array aMINAux para que o processo/filial seja criado na tabela de controle  MIN
        If !(cTabelaMIN)->( Eof() )
            LjGrvLog(" SHPPubSel ","Retorno query que lista a ultima publicação do proceso/filial atual atual:", {cQuery, (cTabelaMIN)->RECNO})

            aAreaMin     := MIN->(GetArea())
            
            DbSelectArea("MIN")
            MIN->(DBGoTo((cTabelaMIN)->RECNO))

            oUltRecno:FromJSON(MIN->MIN_ULTREC)
            
            aMINAux[1] := MIN->MIN_FILPUB
            aMINAux[2] := MIN->MIN_CPROCE
            aMINAux[3] := AllTrim(MIN->MIN_ULTPUB)
            aMINAux[4] := oUltRecno 
            aMINAux[5] := IIF(GetUltRec(aProcesso[2]) == 0,.T.,.F.)
            aMINAux[6] := .T.

            RestArea(aAreaMin)
        Else
            aMINAux[1] := xFilial(aProcesso[2])
            aMINAux[2] := aProcesso[1]
            aMINAux[3] := ""
            aMINAux[4] := oUltRecno  
            aMINAux[5] := .T.
            aMINAux[6] := .T.
        EndIf

        (cTabelaMIN)->(DbCloseArea())
            
        cUltPublic := aMINAux[3]                                        // -- Ultima Publicação    
        cUltAltera := IIF(empty(cUltAltera), aMINAux[3], cUltAltera)    // -- S_T_A_M_P_ do último registro processado, inicializa com a data da ultima publicação (MIN_ULTPUB)
        nUltREC    := GetUltRec(aProcesso[2])                           // -- Ultimo recno da tabela principal

        // -- Verifico tabelas secundária
        SHPPub4Sec(aProcesso,cUltPublic,nMaxbloco)

        // -- Query que retorna data da ultima Alteração ja na tabela que será publicada
        cTabela := GetNextAlias()

        If cDB == "MSSQL" 
            cQuery := " SELECT convert(varchar(23),MAX(S_T_A_M_P_), 21 ) UltimaAlteracao FROM " + RetSqlName(aProcesso[2])
        ElseIf cDB == "POSTGRES" 
            cQuery := " SELECT to_char(MAX(S_T_A_M_P_),'YYYY-MM-DD HH:MI:SS.MS') UltimaAlteracao FROM " + RetSqlName(aProcesso[2])
        ElseIf cDB == "ORACLE" 
            cQuery := " SELECT to_char(MAX(S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.FF') UltimaAlteracao FROM " + RetSqlName(aProcesso[2])
        EndIf 
        
        cQuery += " WHERE " + cPrefixo + "_FILIAL =  '" + xFilial(aProcesso[2]) + "' " 

        //Tratamento de macro execução
        cFilter := aProcesso[4]
        If SubStr(cFilter, 1, 1) == "&"
            cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
        EndIf

        cQuery += IIF(!Empty(cFilter), ' AND ' + AllTrim(cFilter), "")

        //Insere filtro de _MSEXP caso exista
        cQuery += whereStamp(aProcesso[MHNTABELA], cUltPublic, cCmpExp, .F.)

        cQuery := ChangeQuery(cQuery)

        LjGrvLog(" SHPPubSel ","Query que lista a ultima ateração do proceso/filial atual:", {cDB, cQuery})
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

        If !(cTabela)->( Eof() ) .AND. !Empty((cTabela)->(UltimaAlteracao))
            LjGrvLog(" SHPPubSel ","Retorno query que lista a ultima ateração do proceso/filial atual:", {cDB, cQuery, (cTabela)->(UltimaAlteracao)})

            If (cTabela)->(UltimaAlteracao) > cUltPublic 
            	(cTabela)->(DbCloseArea())

                // -- Query que retorna a quantidade de registros a ser processados 
                cTabela := GetNextAlias()
                // -- Conto os registros para saber se o processamento terá mais de um bloco de 50 (Definido na variavel nMaxbloco)
                cQuery := " SELECT COUNT(R_E_C_N_O_) QTDREGISTRO FROM " + RetSqlName(aProcesso[2])
                cWhere := " WHERE " + cPrefixo + "_FILIAL =  '" + xFilial(aProcesso[2]) + "' "  
                cWhere += IIF(!Empty(cFilter), ' AND ' + AllTrim(cFilter), "")
                
                //Retorno where do campo S_T_A_M_P_
                cWhere += whereStamp(aProcesso[MHNTABELA], cUltPublic, cCmpExp)

                // -- Se é um processamento maior que 50 e o primeiro bloco já foi processado, inicia do ultimo recno + 1 
                If !aMINAux[5]
                    cWhere += " AND R_E_C_N_O_ > " + cValToChar(nUltREC)
                EndIf 

                cQuery += cWhere

                cQuery := ChangeQuery(cQuery) 

                LjGrvLog(" SHPPubSel ","Query que lista a quantidade de registros a gerar publicação:", cQuery)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)
                
                LjGrvLog(" SHPPubSel ","Quantidade de registros a processar e limite atual de processamento:", {cValToChar((cTabela)->QTDREGISTRO), cValToChar(nMaxbloco)})
                
                // -- Verifico se é o ultimo bloco de 50 registros para a Filial e processo atual 
                If (nQtdReg := (cTabela)->QTDREGISTRO) > nMaxbloco 
                    aMINAux[5] := .F. 
                Else 
                    aMINAux[5] := .T.
                EndIf 

                (cTabela)->(DbCloseArea())

                // -- Query que retorna a lista de registros para publicação
                aReg := {}
                If cDB == "MSSQL" 
                    cQuery := " SELECT TOP(" + cValtochar(nTamQuery) + ") R_E_C_N_O_ REGISTRO, " + cSTAMPChar + " STAMP FROM " + RetSqlName(aProcesso[2])
                Else
                    cQuery := " SELECT R_E_C_N_O_ REGISTRO, " + cSTAMPChar + " STAMP FROM " + RetSqlName(aProcesso[2])
                EndIf 
                
                cQuery += cWhere
                
                If cDB == "ORACLE" 
                    cQuery  += " AND ROWNUM <= " + cValtochar(nTamQuery)  
                EndIf 

                cQuery += " GROUP BY R_E_C_N_O_"
                cQuery += " ORDER BY STAMP, REGISTRO"

                If cDB == "POSTGRES"
                    cQuery  += " LIMIT " + cValtochar(nTamQuery)
                EndIf 

                cQuery := ChangeQuery(cQuery)
                
                LjGrvLog(" RMIPUBSEL ","Query que lista os registros disponiveis para publicação:", cQuery)                

                if TCSqlToArr(cQuery,aReg) == 0 .And. Len(aReg) > 0

                    ljGrvLog(" RMIPUBSEL ", "Processando as publicações")

                    SET DELETED OFF

                    For nReg := 1 To Len(aReg)

                        nCont++
                        nI++

                        DbSelectArea(aProcesso[2])
                        (aProcesso[2])->( DbGoTo( aReg[nReg][1] ) ) //aReg[nReg][1] = RECNO - aReg[nReg][2] = S_T_A_M_P_

                        If aReg[nReg][2] > cUltAltera 
                            cUltAltera := aReg[nReg][2] 
                        EndIf

                        If ValidaPub(aProcesso, cTabela)

                            // -- Grava publicação
                            RmiPubGrv(aProcesso, aReg[nReg][1],"",.F.)
                        EndIf

                        nUltimoRecno := aReg[nReg][1]                        

                        //Quando chegar no tamanho do bloco grava o controle MIN
                        if nCont == nMaxbloco
                            
                            nCont := 0

                            //-- Atualizo ultima publicação com a data da ultima atalização e ultimo recno processado
                            aMINAux[3] := cUltAltera

                            // -- Se o bloco for inferior ao maximo não é necessario guardar o ultimo recno
                            Iif(aMINAux[5] .AND. aMINAux[6] ,nRecno := 0,nRecno := nUltimoRecno )
                            SetUltRec(aProcesso[2],nRecno)

                            SHPSetUltAlt( xFilial(aProcesso[2]), aProcesso[1])

                            If nQtdReg < nTamQuery
                                If (nQtdReg - nI) < nMaxbloco
                                    If (nQtdReg - nI) == 0  //todos os registros foram processados nesse ultimo laço, então não tenho mais registros para processar
                                        aMINAux[5] := .T.                                                                               
                                    EndIf  

                                    Exit
                                EndIf
                            EndIf
                        endIf
                    Next nReg

                    fwFreeArray(aReg)

                    // -- Desconsidera os registros deletados
                    SET DELETED ON

                    //-- Atualizo ultima publicação com a data da ultima atalização e ultimo recno processado
                    aMINAux[3] := cUltAltera

                    // -- Se o bloco for inferior ao maximo não é necessario guardar o ultimo recno
                    Iif(aMINAux[5] .AND. aMINAux[6] ,nRecno := 0,nRecno := nUltimoRecno )
                    SetUltRec(aProcesso[2],nRecno)

                    SHPSetUltAlt( xFilial(aProcesso[2]), aProcesso[1])
                endIf

                //Fecha alias caso esteja aberta
                iif( select(cTabela) > 0, (cTabela)->( DbCloseArea() ), nil )
            Else
                (cTabela)->(DbCloseArea())
                cMsgError := "O Processo:" + aProcesso[1] + " na tabela: " + aProcesso[2] + " Não tem alterações com data superior a: " + cUltPublic
            EndIf
        Else

            cMsgError := " A tabela: " + aProcesso[2] + " Não tem nenhum S_T_A_M_P alimentado."
        EndIf

        //Finaliza o processo após todo o processamento
        if !empty(cMsgError)
            lContinua := .F.
        endIf
    endDo

    //Finaliza gravação do fwBulk
    finalizaBulk()

    FwFreeObj(oEnvio)
    
    LjGrvLog("SHPPubSel", "Job SHPPubSel finalizado, resultado:", {aProcesso, cMsgError})
    
    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
    
    if !empty(cFilPub)
        rpcClearEnv()
    endIf
    
return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPPub4Sec
Função responsavel por buscar se existem registros nas tabelas se secundária com S_T_A_M_P maior que o ultimo publicado, 
se existir deverá atualizar o S_T_A_M_P da tabela  principal 

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 aProcesso, Array, Array com os dados do processo que será publicado
@param 	 cUltPublic, Caractere, Data  S_T_A_M_P da ultima publicação

/*/
//-----------------------------------------------------------------------
Static Function SHPPub4Sec(aProcesso,cUltPublic,nMaxbloco)

    Local nTabSec    := 0           // -- Variavel de controle (FOR)
    Local cPrefixoS  := ""          // -- Prefixo da tabela secundária
    Local cPrefixoP  := ""          // -- Prefixo da tabela primaria
    Local cTabela    := ""          // -- Alias temporario
    Local cCmpsGrp   := ""          // -- Group By utilizado na query
    Local cSelect    := ""          // -- Query completa
    Local cAuxSelect := ""
    Local aRecsOK    := {}          // -- Variavel que armazenas os recnos já processados
    Local cDB        := TcGetDB()   // -- Banco de dados atual
    Local nUltRecnoS := 0           // -- Ultimo recno da tabela secundária
    Local lUltBloco  := .T.
    Local cFilter    := ""

    For nTabSec := 1 To Len(aProcesso[3])

        //Indica que é para considerar as secundárias para a publicação
        //MIL não considera porque é gerada antes da principal (funções do processo de produto)
        If aProcesso[3][nTabSec][5] $ "1|3" .And. aProcesso[3][nTabSec][1] <> "MIL"
            
            cPrefixoP := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
            cPrefixoS := IIF( SubStr( aProcesso[3][nTabSec][1], 1, 1) == "S", SubStr( aProcesso[3][nTabSec][1], 2), aProcesso[3][nTabSec][1] )

            if temStamp( aProcesso[MHSTABSECUNDARIAS][nTabSec][MHSTABELA] )

                // -- Query que retorna a quantidade de registros a ser processados 
                cTabela := GetNextAlias()

                // -- Conto os registros para saber se o processamento terá mais de um bloco de 50 (Definido na variavel nMaxbloco)
                cSelect := " SELECT COUNT(A.R_E_C_N_O_) REGISTROS "
                
                cAuxSelect := " FROM " + RetSqlName(aProcesso[3][nTabSec][1]) + "  A "  
                
                cAuxSelect  += " INNER JOIN " +  RetSqlName(aProcesso[2]) + "  B " 
                
                // -- Controle, caso ja tenha processado um bloco começa aparir dele.
    
                cAuxSelect += " ON " 
                cAuxSelect += RetJoin(,aProcesso[3][nTabSec][2],aProcesso[3][nTabSec][3],aProcesso[3][nTabSec][1],aProcesso[2])
                
                If cDB == "MSSQL" 
                    cAuxSelect += " WHERE convert(varchar(23),A.S_T_A_M_P_, 21 ) > '"
                ElseIf cDB == "POSTGRES" 
                    cAuxSelect += " WHERE to_char(A.S_T_A_M_P_,'YYYY-MM-DD HH:MI:SS.MS') > '"
                ElseIf cDB == "ORACLE" 
                    cAuxSelect += " WHERE to_char(A.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.FF') > '"
                EndIf 

                // -- Não deve pegar os campos S_T_A_M_P_ Nulos, somente os que foram alterados apos a criação dele.
                cAuxSelect += cUltPublic + "' "

                cAuxSelect += " AND A." + cPrefixoS + "_FILIAL = '" + xFilial(aProcesso[3][nTabSec][1]) + "' "

                //Tratamento de macro execução
                cFilter := aProcesso[3][nTabSec][4]
                If SubStr(cFilter, 1, 1) == "&"
                    cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
                EndIf
                // -- Filtro da tabela se
                IF !Empty(cFilter)
                    cAuxSelect += " AND " + cFilter
                Endif
                
                // -- Se o S_T_A_M_P_ da A for menor que o da B indica que a tabela PAI ja estará na fila, não sendo necessario a atualização.
                cAuxSelect += " AND ( A.S_T_A_M_P_ > B.S_T_A_M_P_ OR B.S_T_A_M_P_ IS NULL ) "
                cAuxSelect += " AND B.D_E_L_E_T_ = ' ' "

                cSelect += cAuxSelect

                cSelect := ChangeQuery(cSelect) 

                LjGrvLog(" SHPPub4Sec ","Query que lista a quantidade de registros a processar da tabela secundária: "+ cSelect)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                
                LjGrvLog(" SHPPub4Sec ","Quantidade de registros a processar: " + cValToChar((cTabela)->REGISTROS))
                LjGrvLog(" SHPPub4Sec ","limite atual de processamento: " + cValToChar(nMaxbloco))
                LjGrvLog(" SHPPub4Sec ","Caso o limite seja excedido o processamento ocorrerá em blocos")
                
                // -- Verifico se é o ultimo bloco de 50 registros para a Filial e processo secundária atual 
                lUltBloco := (cTabela)->REGISTROS <= nMaxbloco
                If !lUltBloco .Or. !aMINAux[6] // -- Se em alguma tabela secundária tem mais que o nMaxbloco então indica que não é o ultimo bloco
                    aMINAux[6] := .F. 
                Else 
                    aMINAux[6] := .T.
                EndIf 
                
                (cTabela)->(DbCloseArea())  
                  
                cTabela  := GetNextAlias()
                cCmpsGrp := "A." + StrTran(aProcesso[3][nTabSec][2],"+",", A.")
                
                
                If cDB == "MSSQL" 
                    cSelect := " SELECT TOP(" + cValtochar(nMaxbloco) + ") B.R_E_C_N_O_ RECNO_PRINCIPAL, A.R_E_C_N_O_ RECNO_SECUNDARIA "
                Else
                    cSelect := " SELECT B.R_E_C_N_O_  RECNO_PRINCIPAL, A.R_E_C_N_O_  RECNO_SECUNDARIA "
                EndIf 
                
                cSelect += cAuxSelect
                
                If cDB == "ORACLE" 
                    cSelect  += " AND ROWNUM <= " + cValtochar(nMaxbloco)  
                EndIf 
                
                cSelect += " GROUP BY " +  cCmpsGrp +  ",B.R_E_C_N_O_,A.R_E_C_N_O_  "
                cSelect += " ORDER BY RECNO_PRINCIPAL  "
                
                If cDB == "POSTGRES"
                    cSelect  += " LIMIT " + cValtochar(nMaxbloco)
                EndIf 
                
                LjGrvLog(" SHPPub4Sec ","QUERY que seleciona os registros das tabelas secundárias que serão publicados " + cSelect)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                
                // -- Considera os registros deletados
                SET DELETED OFF
                While !(cTabela)->( Eof() )
                    
                    If (aScan(aRecsOK,(cTabela)->RECNO_PRINCIPAL)) == 0 

                        DbSelectArea(aProcesso[2])
                        (aProcesso[2])->(DBGoTo((cTabela)->RECNO_PRINCIPAL))

                        // -- Deleto e retorno o registro principal para que o campo S_T_A_M_P_ seja atualizado, 
                        // -- assim gerando a publicação de toda a cadeia (principais e secundárias)
                        // -- Protegido por transação, ou seja somente conclui caso consiga "deletar" e "desdeletar" o registro.
                        Begin Transaction
                            RecLock(aProcesso[2], .F.)
                                (aProcesso[2])->(DBDelete())
                            (aProcesso[2])->(MsUnLock())    
                            
                            RecLock(aProcesso[2], .F.)   
                                (aProcesso[2])->(DBRecall())
                            (aProcesso[2])->(MsUnLock())
                        End Transaction        
                        
                        // -- Armazeno o recno processado para evitar duplo processamento 
                        aAdd(aRecsOK,(cTabela)->RECNO_PRINCIPAL)

                    EndIf 
                    nUltRecnoS := (cTabela)->RECNO_SECUNDARIA
                    (cTabela)->( DbSkip() )
                EndDo

                (cTabela)->( DbCloseArea() )

                // -- Desconsidera os registros deletados
                SET DELETED ON

            Else
                LjGrvLog(" SHPPub4Sec ","Campo de controle S_T_A_M_P_ não esta presente na tabela: " + aProcesso[3][nTabSec][1] )
                LjGrvLog(" SHPPub4Sec ","Não será gerada publicação para o processo: " + aProcesso[1] + " considerando a tabela secundária: " + aProcesso[3][nTabSec][1])
            EndIf 

        Else
            LjGrvLog(" SHPPub4Sec "," A Tabela: [" + aProcesso[3][nTabSec][1] + "] Não é considerada para a publicação do processo: [" +  aProcesso[1] + "]")
        EndIf 
    Next nTabSec

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPSetUltAlt
Função responsavel por a alteração da tabela MIN (tabelas responsavel por controlar a ultima publicação para o proceso|filial )

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cFilPub, Caractere, Filial de publicação
@param 	 cProcesso, Caractere, processo publicado

/*/
//-----------------------------------------------------------------------
Function SHPSetUltAlt(cFilPub, cProcesso)

    Local lInclui := Nil // -- Indica se é uma inclusão ou alteração na tabela MIN


    if oEnvio <> Nil 

        If oEnvio:GetSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .T. e vai executar a rotina oEnvio:Processa() ")
            oEnvio:Processa(aStDados,cFilPub) //carrego array dos dados a serem enviados
        EndIf

        If !oEnvio:getSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .F. e Vai recuperar o erro ")
            oEnvio:getRetorno()
            LjGrvLog(" RmiEnvExec ",oEnvio:getRetorno())
        EndIf

        aStDados := {}
	endIf
    //Commita gravação quando estiver utilizando o fwBulk
    gravaBulk()

    DbSelectArea("MIN")
    MIN->(DbSetOrder(1)) // -- MIN_FILIAL+MIN_CPROCE+MIN_FILPUB
    lInclui := !MIN->(Dbseek(xFilial("MIN") + PadR(cProcesso,TamSX3("MIN_CPROCE")[1]) + cFilPub ))

    RecLock("MIN", lInclui)

        If lInclui
            REPLACE MIN->MIN_FILIAL WITH xFilial("MIN")
            REPLACE MIN->MIN_FILPUB WITH cFilPub
            REPLACE MIN->MIN_CPROCE WITH cProcesso
        EndIf         
        
        If aMINAux[5] .AND. aMINAux[6] // -- Se for o ultimo bloco atualizo a data da ultima publicação
            REPLACE MIN->MIN_ULTPUB WITH aMINAux[3]   
        EndIf 

        REPLACE MIN->MIN_ULTREC WITH aMINAux[4]:toJSON()

    MIN->(MsUnLock())
    
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetUltRec
Função responsavel por setar (atualizar) um numero de recno a key (tabela do processo) atual

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cKey, Caractere, Chave (Tabela do processo)
@param 	 nRecno, numerico, recno

/*/
//-----------------------------------------------------------------------

Static Function SetUltRec(cKey,nRecno)
    cKey := Alltrim(cKey)
    aMINAux[4][cKey] := nRecno
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPSetUltAlt
Função responsavel por devolver um numero de recno da key (tabela do processo) atual
@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cKey, Caractere, Chave (Tabela do processo)

/*/
//-----------------------------------------------------------------------

Static Function GetUltRec(cKey)
    Local nRecno := 0

    cKey := Alltrim(cKey)

    If aMINAux[4]:hasProperty(cKey)
        nRecno := aMINAux[4][cKey]
    Else
        aMINAux[4][cKey] := 0
    EndIf 

Return nRecno

//-----------------------------------------------------------------------
/*/{Protheus.doc} RmiProPub
Retorna os processos que serão publicados, com toda a estrutura necessária para a publicação.

@type    Function
@author  Rafael Tenorio da Costa
@since   20/07/22
@version 12.1.33
/*/
//-----------------------------------------------------------------------
Function RmiProPub(cProcessos, cGrupos, lGrupo)
	
    Local cSelect       := "" 
    Local cTabela       := ""
    Local aProcesso     := {}
    Local aTabSec       := {}     
    Local nPos          := 0 
    Local nI            := 0
    Local lFields       := MHN->( ColumnPos("MHN_FILTRO") ) > 0 .AND. MHS->( ColumnPos("MHS_FILTRO") ) > 0
    Local lFieldPub     := MHS->( ColumnPos("MHS_CONPUB") ) > 0
    Local lFldSecOb     := MHN->( ColumnPos("MHN_SECOBG") ) > 0
    Local lFieldTipo    := MHS->( ColumnPos("MHS_TIPO")   ) > 0
    Local cTamTab       := Space( TamSx3("MHN_TABELA")[1] )
    Local aFilPro       := {}
    Local oProcAssi     := JsonObject():New()          //Armazena os assinantes que estão utilizando os processos ativos

    Default cProcessos  := ""
    Default cGrupos     := ""
    Default lGrupo      := .F.

    //Seleciona os processos assinados
    cTabela := GetNextAlias()

    cSelect := " SELECT MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE, MHP_CASSIN"
    cSelect += cStCmpQrFi
    cSelect += IIF(lFldSecOb    , ", MHN_SECOBG"            , "")
    cSelect += IIF(lFields      , ", MHN_FILTRO, MHS_FILTRO", "") 
    cSelect += IIF(lGrupo       , ", MHN_CODGRP"            , "")
    cSelect += IIF(lFieldPub    , ", MHS_CONPUB"            , "") 
    cSelect += IIF(lFieldTipo   , ", MHS_TIPO"              , "")

    cSelect += " FROM " + RetSqlName("MHN") + " MHN INNER JOIN " + RetSqlName("MHP") + " MHP"
    cSelect +=      " ON MHN_FILIAL = MHP_FILIAL AND MHN_COD = MHP_CPROCE AND MHN.D_E_L_E_T_ = MHP.D_E_L_E_T_ AND MHN_TABELA NOT IN ('XXX','YYY','" + cTamTab + "')"
    cSelect += " LEFT JOIN " + RetSqlName("MHS") + " MHS"
    cSelect +=      " ON MHS_FILIAL = MHN_FILIAL AND MHS_CPROCE = MHN_COD AND MHS.D_E_L_E_T_ = ' '"

    cSelect += " WHERE MHN.D_E_L_E_T_ = ' '"
    cSelect += " AND MHP_ATIVO = '1'"           //1=Sim
    cSelect += " AND MHP_TIPO = '1'"            //1=Envia
    cSelect += " AND MHP_CASSIN <> 'PROTHEUS'"  //Não gerar MHQ para Assinante Protheus em caso do tipo ser 1=Envia.

    If !Empty(cProcessos)
        cSelect += " AND MHN_COD IN " + FormatIn(cProcessos, ",")
    EndIf

    if lGrupo .and. !empty(cGrupos)
        cSelect += " AND MHN_CODGRP IN " + FormatIn(cGrupos, ",")
    endIf

    cSelect += " GROUP BY MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE, MHP_CASSIN"
    cSelect += cStCmpQrFi
    cSelect += IIF(lFldSecOb    , ", MHN_SECOBG"            , "")
    cSelect += IIF(lFields      , ", MHN_FILTRO, MHS_FILTRO", "")
    cSelect += IIF(lGrupo       , ", MHN_CODGRP"            , "")
    cSelect += IIF(lFieldPub    , ", MHS_CONPUB"            , "")
    cSelect += IIF(lFieldTipo   , ", MHS_TIPO"              , "")

    cSelect := ChangeQuery(cSelect)

    LjGrvLog("RmiProPub", "Query executada para retornar os processos que serão publicados:", cSelect)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    While !(cTabela)->( Eof() )
        
        //Verifico no array aProcesso se determinada tabela do cabeçalho ja existe no array
        nPos := aScan(aProcesso,{|x| AllTrim(x[1]) == AllTrim( (cTabela)->MHN_COD ) .And. AllTrim(x[5]) == AllTrim( (cTabela)->MHP_CASSIN ) })

        aTabSec := {    AllTrim( (cTabela)->MHS_TABELA  )               ,;
                        AllTrim( (cTabela)->MHS_CHAVE   )               ,;
                        (cTabela)->MHN_CHAVE                            ,;
                        IIF(lFields     , (cTabela)->MHS_FILTRO , "" )  ,;
                        IIF(lFieldPub   , (cTabela)->MHS_CONPUB , "2")  ,;
                        IIF(lFieldTipo  , (cTabela)->MHS_TIPO   , "" )  }

        //Caso a tabela ainda nao existe no array, entao é add no array a tabela principal mais as filhas
        If nPos == 0

            aFilPro := iif( lStRmixFil, rmixFilial((cTabela)->MHP_CASSIN, (cTabela)->MHN_COD), strTokArr( allTrim((cTabela)->MHP_FILPRO), ";") )

            If Valtype(oProcAssi[AllTrim( (cTabela)->MHN_TABELA  )+'-'+AllTrim( (cTabela)->MHN_COD     )]) == "U"
                oProcAssi[AllTrim( (cTabela)->MHN_TABELA  )+'-'+AllTrim( (cTabela)->MHN_COD     )] := {}
            EndIf    

            Aadd(oProcAssi[AllTrim( (cTabela)->MHN_TABELA  )+'-'+AllTrim( (cTabela)->MHN_COD     )],Alltrim((cTabela)->MHP_CASSIN))

            Aadd(aProcesso ,;   
                        {   AllTrim( (cTabela)->MHN_COD     )               ,;
                            AllTrim( (cTabela)->MHN_TABELA  )               ,;
                            {}                                              ,;
                            IIF(lFields     , (cTabela)->MHN_FILTRO, "" )   ,;
                            (cTabela)->MHP_CASSIN                           ,;
                            IIF(lFldSecOb   , (cTabela)->MHN_SECOBG, "2")   ,;
                            IIF(lFieldTipo  , (cTabela)->MHS_TIPO  ,  "")   ,;
                            (cTabela)->MHN_CHAVE                            ,;
                            aClone(aFilPro)                                 ,;
                            IIF(lGrupo      , (cTabela)->MHN_CODGRP,  "")   }   )

            nPos := Len(aProcesso)
        EndIf

        If !Empty( (cTabela)->MHS_TABELA )
            Aadd(aProcesso[nPos][3], aTabSec)
        EndIf

        (cTabela)->( DbSkip() )
    EndDo
       
    (cTabela)->( DbCloseArea() )

    For nI := 1 To Len(aProcesso)
        Aadd(aProcesso[nI],oProcAssi[aProcesso[nI][2]+'-'+aProcesso[nI][1]]) //Adiciona os assinantes que estão utilizando o processo ativo
    Next nI

    fwFreeArray(aFilPro)
    FwFreeObj(oProcAssi)
    LjGrvLog("RmiProPub", "Processos que serão publicados:", aProcesso)

Return aProcesso
//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubMix
Grava a publicação na tabela MHQ - Mensagens Publicadas do Mix de Produto

@author  Everson S P Junior
@since   14/03/23
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubMix(aProcesso, nRegistro)

    Local aArea      := GetArea()
    Local cJson      := ""
    Local lSecObg    := .T.
    Local cProcesso  := aProcesso[1]
    Local cTabela    := aProcesso[2]
    Local cFilPro    := aProcesso[9]
    Local cChave     := aProcesso[8]  //Retorna campos que compoem a chave da publicação

    Default cCmpExp := ""
    Default lAltExp := .T.

    LjGrvLog(" RmiPubGrv ","Grava a publicação na tabela MHQ Function RmiPubGrv",{cProcesso, cTabela, nRegistro})
    
    (cTabela)->( DbGoTo(nRegistro) )

    If !(cTabela)->( Eof() )

        //Gera publicação da tabela principal
        LjGrvLog("RmiPubGrv", "Gerando publicação da tabela principal", cTabela)
        cJson := GeraJson(cTabela, 0)
        cJson := StrTran(cJson,'"B1_FILIAL": "'+Space(Tamsx3('B1_FILIAL')[1])+'"','"B1_FILIAL": "'+cFilPro+'"')//Verifica se vem com espaço 
        cJson := StrTran(cJson,'"B1_FILIAL":"'+Space(Tamsx3('B1_FILIAL')[1])+'"','"B1_FILIAL": "'+cFilPro+'"')//Verifica se vem com espaço 
        cJson := StrTran(cJson,'"B1_FILIAL": ""','"B1_FILIAL":"'+cFilPro+'"')//Verifica se vem sem espaço
        cJson := StrTran(cJson,'"B1_FILIAL":""','"B1_FILIAL":"'+cFilPro+'"')//Verifica se vem sem espaço
        If oError == Nil 

            cJson := SubStr(cJson,1,Len(cJson) - 1) + CRLF + '}' 
            LjGrvLog(" RmiPubGrv ","Resultado Json que será gravado -> "+cJson)
            Begin Transaction
                If lSecObg

                    GravaMHQ(   cProcesso   ,;
                                cTabela     ,; 
                                cFilPro+'|'+(cTabela)->&(cChave) + IIF( (cTabela)->( Deleted() ), "|" + cValToChar( (cTabela)->( Recno() ) ), "")   ,; 
                                cJson       ,; 
                                "1"         )

                EndIf

            End Transaction
        EndIf
    EndIf

    LjGrvLog(" RmiPubGrv ","Fim da Gravação Mix de Produto")
    RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaMHQ
Centraliza a gravação da tabela MHQ

@type    Function
@param 	 cProcesso  , Caractere, Processo da publicação
@param 	 cTabela    , Caractere, Tabela da publicação
@param 	 cChave     , Caractere, Chave unica da publicação
@param 	 cJson      , Caractere, Json da publicação
@param 	 cStatus    , Caractere, Status da publicação
@param 	 cFilReg    , Caractere, Filial do registro publicado
@author  Rafael Tenorio da Costa
@since   19/05/23
@version 12.1.2210
/*/
//-----------------------------------------------------------------------
Static Function GravaMHQ(cProcesso, cTabela, cChave, cJson, cStatus,;
                         cFilReg )

    Local cHora := IIF( TamSx3("MHQ_HORGER")[1] >= 12, TimeFull(), Time() )
    Local cUuid := ""

    Default cFilReg := xFilial(cTabela)

    //Utiliza fwBulk na gravação
    //O array de extrutura (aStStrBulk) deve estar na mesma ordem da inclusão do registro no fwBulk (oStBulk:addData)
    If oEnvio <> Nil 
        aadd(aStDados, { xFilial("MHQ")                                ,;  //MHQ->MHQ_FILIAL
                    "PROTHEUS"                                  ,;  //MHQ->MHQ_ORIGEM
                    cProcesso                                   ,;  //MHQ->MHQ_CPROCE
                    IIF( (cTabela)->( Deleted() ), "2", "1" )   ,;  //MHQ->MHQ_EVENTO
                    cChave                                      ,;  //MHQ->MHQ_CHVUNI
                    cJson                                       ,;  //MHQ->MHQ_MENSAG
                    Date()                                      ,;  //MHQ->MHQ_DATGER
                    cHora                                       ,;  //MHQ->MHQ_HORGER
                    IIF(cStatus == "0", "1", cStatus)           ,;  //MHQ->MHQ_STATUS       //0=Em publicação; 1=Liberado para distribuição; 9=Aguardando confirmação do produto
                    FwUUID("PUBLICA" + AllTrim(cProcesso))      ,;  //MHQ->MHQ_UUID
                    cFilReg                                     })  //MHQ->MHQ_IDEXT    
    EndIf

    If lGeraMHQ //Grava na tabela MHQ 
        If lStBulk
             oStBulk:addData({ xFilial("MHQ")                                ,;  //MHQ->MHQ_FILIAL
                                "PROTHEUS"                                  ,;  //MHQ->MHQ_ORIGEM
                                cProcesso                                   ,;  //MHQ->MHQ_CPROCE
                                IIF( (cTabela)->( Deleted() ), "2", "1" )   ,;  //MHQ->MHQ_EVENTO
                                cChave                                      ,;  //MHQ->MHQ_CHVUNI
                                cJson                                       ,;  //MHQ->MHQ_MENSAG
                                Date()                                      ,;  //MHQ->MHQ_DATGER
                                cHora                                       ,;  //MHQ->MHQ_HORGER
                                IIF(cStatus == "0", "1", cStatus)           ,;  //MHQ->MHQ_STATUS       //0=Em publicação; 1=Liberado para distribuição; 9=Aguardando confirmação do produto
                                FwUUID("PUBLICA" + AllTrim(cProcesso))      ,;  //MHQ->MHQ_UUID
                                cFilReg                                     })  //MHQ->MHQ_IDEXT 
    
        else
    
            RecLock("MHQ", .T.)
                MHQ->MHQ_FILIAL := xFilial("MHQ")
                MHQ->MHQ_ORIGEM := "PROTHEUS"
                MHQ->MHQ_CPROCE := cProcesso
                MHQ->MHQ_EVENTO := IIF( (cTabela)->( Deleted() ), "2", "1" )
                MHQ->MHQ_CHVUNI := cChave
                MHQ->MHQ_MENSAG := cJson
                MHQ->MHQ_DATGER := Date()
                MHQ->MHQ_HORGER := cHora
                MHQ->MHQ_STATUS := cStatus      //0=Em publicação; 1=Liberado para distribuição; 9=Aguardando confirmação do produto
                MHQ->MHQ_UUID   := FwUUID("PUBLICA" + AllTrim(cProcesso))
                MHQ->MHQ_IDEXT  := cFilReg
            MHQ->( MsUnLock() )
    
            cUuid := MHQ->MHQ_UUID
        endIf
    endIf
Return cUuid

//-------------------------------------------------------------------
/*/{Protheus.doc} publica
Verifica se existem registros para publicar,
e retorna as filiais onde deve ser feito o processamento.

@author  Rafael tenorio da Costa 
@since 	 13/06/2024
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function publica(aProcesso, aUltPublica, aFilProc)

    Local aArea         := getArea()
    Local aFilRet       := {}
    Local aTabelas      := {}
    Local nTabela       := 0
    Local cTabela       := ""
    Local nTabSec       := 0
    Local cSql          := ""
    Local nPosUltPub    := 0
    Local cUltPublica   := ""
    Local cPrefixo      := ""
    Local cCmpFil       := ""
    Local cCmpExp       := ""
    Local cFilPub       := ""
    Local aAux          := {}
    Local nFil          := 0

    //Verifica se tem tabela preenchida porque existe processos de gatilhos(MHN_GATILH)
    if !empty( aProcesso[MHNTABELA] )

        aAdd( aTabelas, aProcesso[MHNTABELA] )

        //Carrega tabelas secundarias
        for nTabSec:=1 to len(aProcesso[MHSTABSECUNDARIAS])
            aAdd( aTabelas, aProcesso[MHSTABSECUNDARIAS][nTabSec][MHSTABELA] )
        next nTabSec

        for nTabela:=1 to len(aTabelas)

            cTabela  := aTabelas[nTabela]
            cPrefixo := IIF( subStr( cTabela, 1, 1) == "S", subStr( cTabela, 2), cTabela )
            cCmpFil  := cPrefixo + "_FILIAL"
            cCmpExp  := cPrefixo + "_MSEXP"

            //Verifico se o campo de controle existe
            if !temStamp(cTabela)

                ljxjMsgErr("Campo de controle S_T_A_M_P_ não existe na tabela " + cTabela + ", a integração não será executada.", /*cSolucao*, /*cRotina*/, /*xVar*/)
            else

                for nFil:=1 to len(aFilProc)

                    cUltPublica := ""
                    cFilPub     := xFilial(cTabela, aFilProc[nFil])

                    //Procura o processo e a filial no controle de publicação
                    nPosUltPub  := aScan( aUltPublica, {|x| allTrim(x[MINCPROCE]) == allTrim(aProcesso[MHNCOD]) .and. allTrim(x[MINFILPUB]) == allTrim(cFilPub)} )
                    if nPosUltPub > 0
                        cUltPublica := aUltPublica[nPosUltPub][MINULTPUB]
                    endIf

                    if !empty(cUltPublica)

                        //Consulta a tabela para ver se tem registro para publicar
                        cSql := " SELECT COUNT(1)"
                        cSql += " FROM " + retSqlName(cTabela)
                        cSql += " WHERE " + cCmpFil + " = '" + cFilPub + "'"
                        cSql += whereStamp(cTabela, cUltPublica, cCmpExp)

                        aSql := rmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

                        if len(aSql) > 0 .and. aSql[1][1] > 0

                            //Tratamento para não abrir uma thread para cada filial, dependendo da regra de compartilhamento da tabela
                            if aScan( aAux, {|x| x[2] == cFilPub} ) == 0
                                aAdd(aAux   , {aFilProc[nFil], cFilPub})
                                aAdd(aFilRet, aFilProc[nFil])
                            endIf
                        endIf
                    else

                        //Consulta a tabela para ver se tem algum registro
                        cSql := " SELECT COUNT(1)"
                        cSql += " FROM " + retSqlName(cTabela)
                        cSql += " WHERE " + cCmpFil + " = '" + cFilPub + "'"
                        cSql +=     " AND S_T_A_M_P_ IS NOT NULL"
                        
                        aSql := rmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

                        if len(aSql) > 0 .and. aSql[1][1] > 0

                            //Tratamento para abrir uma thread para cada filial, apenas quando a regra de compartilhamento da tabela for exclusiva
                            if aScan( aAux, {|x| x[2] == cFilPub} ) == 0
                                aAdd(aAux   , {aFilProc[nFil], cFilPub})
                                aAdd(aFilRet, aFilProc[nFil])
                            endIf
                        endIf
                    endIf
                next nFil
            endIf
        next nTabela

    endIf

    fwFreeArray(aTabelas)
    fwFreeArray(aAux)

    restArea(aArea)

Return aFilRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ultPublica
Retorna a data\hora da ultima publicação dos processos

@author  Rafael tenorio da Costa 
@since 	 13/06/2024
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function ultPublica()

    Local aArea := getArea()
    Local cSql  := ""
    Local aSql  := {}

    cSql    := " SELECT MIN_CPROCE, MIN_FILPUB, MIN(MIN_ULTPUB) as MIN_ULTPUB"
    cSql    += " FROM " + RetSqlName("MIN")
    cSql    += " WHERE D_E_L_E_T_ = ' '"
    cSql    +=      " AND MIN_ULTPUB <> '" + space( tamSx3("MIN_ULTPUB")[1] ) + "'""
    cSql    += " GROUP BY MIN_CPROCE, MIN_FILPUB"

    aSql := rmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

    restArea(aArea)

Return aSql

//-------------------------------------------------------------------
/*/{Protheus.doc} whereStamp
Retorna o where do campo S_T_A_M_P_ com base no processo e data da ultima publicação.

@author  Rafael tenorio da Costa 
@since 	 13/06/2024
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function whereStamp(cTabela, cUltPublica, cCmpExp, lStamp)

    Local cWhere    := ""
    Local cDB       := allTrim( upper( TcGetDB() ) )

    Default lStamp := .T.

    if lStamp
        // -- Não deve pegar os campos S_T_A_M_P_ Nulos, somente os que foram alterados apos a criação dele.
        cWhere += IIF( cDB == "MSSQL"   , " AND convert(varchar(23),S_T_A_M_P_, 21 ) >"             , "" )
        cWhere += IIF( cDB == "POSTGRES", " AND to_char(S_T_A_M_P_,'YYYY-MM-DD HH:MI:SS.MS') >"     , "" )
        cWhere += IIF( cDB == "ORACLE"  , " AND to_char(S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.FF') >"   , "" )

        cWhere += + " '" +  cUltPublica + "' "
    endIf

    //Valida existencia do campo de controle de exportação
    If (cTabela)->( ColumnPos(cCmpExp) ) > 0
        cWhere += " AND " + cCmpExp + " <> 'PSH-INTE' " 
    Else
        ljGrvLog("PUBLICAÇÃO", "Campo " + cCmpExp + " não existe, caso seu cadastro de assinante esteja utilizando busca e envio de um mesmo processo, pode ocorrer um loop infiníto. Exemplo: Processo de cliente busca e envia.")
    EndIf

Return cWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} temStamp
Valida a existencia do campo S_T_A_M_P_, direto no banco de dados,
e ja carrega o resultado no array estatico para consultas posteriores.

@author  Rafael tenorio da Costa 
@since 	 13/06/2024
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function temStamp(cTabela)

    if ( nPos := aScan( aStTemSta, {|x| x[1] == cTabela} ) ) == 0

        aAdd( aStTemSta, {cTabela, (aScan( tcStruct( retSqlName(cTabela) ), {|x| x[1] == "S_T_A_M_P_"} ) > 0) } )

        nPos := len(aStTemSta)
    endIf

Return aStTemSta[nPos][2]

//-------------------------------------------------------------------
/*/{Protheus.doc} pshPubGrp
Efetua a publicação dos processos de um determinado grupo

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshPubGrp(cEmpAmb, cFilAmb, aProcGrupo)

    Local cSemaforo     := "pshPubGrp" +"_"+ cEmpAmb +"_"+ aProcGrupo[1]
    Local nCont         := 1
    Local cBkpFilial    := ""
    
    rpcSetType(3)
    rpcSetEnv(cEmpAmb, cFilAmb, /*cEnvUser*/, /*cEnvPass*/, "LOJA", "pshPubGrp")

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        rpcClearEnv()
        Return Nil
    EndIf

    //Verifica se a gravação por bulk esta ativa
    lStBulk := fwBulk():CanBulk()

    cBkpFilial := cFilAnt

    for nCont:=1 to len(aProcGrupo[2])

        cFilAnt := aProcGrupo[2][nCont][1]
        shpPubSel(cEmpAnt, "", aProcGrupo[2][nCont][2])

    next nCont

    cFilAnt := cBkpFilial

    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

    fwFreeArray(aProcGrupo)
    rpcClearEnv()

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} pendenteCarga
Processamento para ativação de nova loja

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function pendenteCarga()

    Local aArea         := getArea()
    Local cSelect       := ""
    Local cTabela       := GetNextAlias()
    Local cSelectMIN    := ""    
    Local cTabelaMIN    := ""
    Local cFilMIH		:= ""
    Local cFilPub       := ""
    Local oLayEnv       := Nil
    Local nTamProce     := tamSx3("MIN_CPROCE")[1]
    Local cCadLoja      := padR("CADASTRO LOJA"   , nTamProce)

	//Query que filtra lojas pendentes de carga
	cSelect := " SELECT R_E_C_N_O_ as REC FROM "+ retSqlName("MIH")
    cSelect += " WHERE D_E_L_E_T_ = ' '"
    cSelect +=      " AND MIH_FILIAL = '" + xFilial("MIH") + "'"
    cSelect +=      " AND MIH_ATIVO = '3'"                       //3=Pendente carga
    cSelect +=      " AND MIH_TIPCAD = '" + padR("CADASTRO DE LOJA", tamSx3("MIH_TIPCAD")[1]) + "'"

    cSelect := ChangeQuery(cSelect) 

    LjGrvLog("RMIPUBLICA", "Query que lista as lojas pendentes de carga:", cSelect)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    if !(cTabela)->( eof() )
        
        cTabelaMIN  := GetNextAlias()

        Begin Transaction

            while !(cTabela)->(Eof())

                MIH->( dbGoTo( (cTabela)->REC ) )

                cFilMIH := LjCAuxRet("IDFilialProtheus")
                
                //Limpar a MIN
                //Query que filtra os processos para publicar nova carga para as lojas pendentes
                cSelectMIN := " SELECT R_E_C_N_O_ as RECMIN FROM " + retSqlName("MIN")
                cSelectMIN += " WHERE D_E_L_E_T_ = ' '"
                cSelectMIN += " AND MIN_FILIAL = '" + xFilial("MIN") + "'"
                cSelectMIN += " AND MIN_CPROCE NOT IN ('" + cCadLoja + "')" //Não retorno CADASTRO LOJA, não existe a necessidade de reenviar estes cadastros

                cSelectMIN := ChangeQuery(cSelectMIN) 

                LjGrvLog("RMIPUBLICA", "Query que lista todos os processos já publicados:", cSelectMIN)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelectMIN), cTabelaMIN, .T., .F.)

                while !(cTabelaMIN)->( Eof() )
                        
                    MIN->( dbGoTo( (cTabelaMIN)->RECMIN ) )

                    cFilPub := allTrim(MIN->MIN_FILPUB)

                    //Avalia se ja publicou algum dado que a nova loja deva receber, para apagar a MIN
                    if empty(cFilPub) .or. cFilPub == subStr(cFilMIH, 1, Len(cFilPub))
                        LjGrvLog("RMIPUBLICA", "Deleta controle de publicação na tabela MIN, MIN_CPROCE\MIN_FILPUB:", {MIN->MIN_CPROCE, MIN->MIN_FILPUB})

                        RecLock("MIN", .F.)
                            MIN->( dbDelete() )
                        MIN->( msUnLock() )
                    endIf
                    
                    (cTabelaMIN)->( dbSkip() )
                endDo
                (cTabelaMIN)->( dbCloseArea() )

                //Ativa loja
                LjGrvLog("RMIPUBLICA", "Ativando processamento de carga loja\filial:", {cFilMIH, MIH->( recno() )})
                RecLock("MIH", .F.)
                    MIH->MIH_ATIVO := "1"
                MIH->( msUnLock() )

                (cTabela)->( dbSkip() )
            endDo

            //Ativa a carga inicial nos processos, para controle de precedencia
            MHP->( dbSetOrder(1) )  //MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO, R_E_C_N_O_, D_E_L_E_T_
            if MHP->( dbSeek( xFilial("MHP") + padR("PDVSYNC", tamSx3("MHP_CASSIN")[1]) ) )

                oLayEnv := JsonObject():new()

                while !MHP->( eof() ) .and. allTrim(MHP->MHP_CASSIN) == "PDVSYNC"

                    //Verifica se é processo de ENVIO e consegue popular o json
                    if MHP->MHP_TIPO == "1" .and. oLayEnv:fromJson(MHP->MHP_LAYENV) == nil

                        LjGrvLog("RMIPUBLICA", "Ativando o controle de cargaInicial para o processo:", {MHP->MHP_CPROCE, MHP->MHP_CASSIN})

                        if oLayEnv:hasProperty("configPSH")
                            oLayEnv["configPSH"]["cargaInicial"] := .T.
                        else
                            oLayEnv["configPSH"] := JsonObject():new()
                            oLayEnv["configPSH"]["Version"]      := "1.0"
                            oLayEnv["configPSH"]["cargaInicial"] := .T.
                        endIf

                        RecLock("MHP", .F.)
                            MHP->MHP_LAYENV := oLayEnv:toJson()
                        MIH->( msUnLock() )
                    endIf
                
                    MHP->( dbSkip() )
                endDo

                fwFreeObj(oLayEnv)
            endIf

        End Transaction

    endIf
    (cTabela)->( dbCloseArea() )

    restArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} iniciaBulk
Inicia a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function iniciaBulk()

    Local aStStrBulk := {}  //Struct MHQ utilizado no fwBulk

    if lStBulk

        //O array de extrutura (aStStrBulk) deve estar na mesma ordem da inclusão do registro no fwBulk (oStBulk:addData)
        aAdd( aStStrBulk, {"MHQ_FILIAL" })
        aAdd( aStStrBulk, {"MHQ_ORIGEM" })
        aAdd( aStStrBulk, {"MHQ_CPROCE" })
        aAdd( aStStrBulk, {"MHQ_EVENTO" })
        aAdd( aStStrBulk, {"MHQ_CHVUNI" })
        aAdd( aStStrBulk, {"MHQ_MENSAG" })
        aAdd( aStStrBulk, {"MHQ_DATGER" })
        aAdd( aStStrBulk, {"MHQ_HORGER" })
        aAdd( aStStrBulk, {"MHQ_STATUS" })
        aAdd( aStStrBulk, {"MHQ_UUID"   })
        aAdd( aStStrBulk, {"MHQ_IDEXT"  })

        oStBulk := fwBulk():New(retSqlName("MHQ"), nStTamBulk)
        oStBulk:setFields(aStStrBulk)

        fwFreeArray(aStStrBulk)

        ljGrvLog("Bulk", "Iniciada inclusão de registros por fwBulk.")
    endIf

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaBulk
Commita a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function gravaBulk()

    Local cErro := ""

    if lStBulk

        oStBulk:flush()

        cErro := oStBulk:getError()
        if !empty(cErro)
            ljxjMsgErr("Erro ao efetuar a publicação utilizando fwBulk: " + cErro, /*cSolucao*/, "gravaBulk", aMINAux)
            LjGrvLog("RMIPUBLICA", "gravaBulk Erro ao efetuar a publicação utilizando fwBulk, cErro e aMINAux: ", {cErro,aMINAux}) // Log centralizado
        endIf
    endIf

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} finalizaBulk
Finaliza a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function finalizaBulk()

    if lStBulk
        oStBulk:close()
        oStBulk:destroy()

        fwFreeObj(oStBulk)
        
        ljGrvLog("Bulk", "Finalizada inclusão de registros por fwBulk.")
    endIf

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} cargaInicial
Valida se é carga inical para só exportar campos preenchidos

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function cargaInicial(cTipo, cCampo, xConteudo)

    Local lRetorno := .F.

    if lStCargaIni
        If !("_FILIAL" $ cCampo) .and. cTipo $ "C|M|D" .and. empty(xConteudo)
            lRetorno := .T.
        endIf
    endIf

return lRetorno
