#include "totvs.ch"
#include "ofia624.ch"

static cPerg := "OFIA624"
static aNovosCampos := {;
                        { "VOG", "VOG_COMPAR" },;
                        { "VOG", "VOG_EMAIL"  },;
                        { "VO1", "VO1_TIPOOS" },;
                        { "VOI", "VOI_TIPOOS" },;
                        { "VAM", "VAM_EMPATE" },;
                        { "VAM", "VAM_FILATE" } }

static aMemoria := {}

/*/{Protheus.doc} OFIA620
Rotina de exportação de dados relacionados a motoristas, OS, veículos, cliente e consultores em formato .CSV
@author Cristiam Rossi
@since 02/06/2026
@version 1.0
@type function
/*/
function OFIA624()
    local   dDatRef
    local   cPasta
    local   nTipoLev
    local   nTipoCli
    local   nI
    local   cMsgErro := ""
    local   lOk      := .F.
    local   lSchedule := FWGetRunSchedule()

    for nI := 1 to len( aNovosCampos )      // caso não tenha os novos campos, abortar a execução
        if ( aNovosCampos[nI,1] )->( FieldPos( aNovosCampos[nI,2] ) ) == 0
            cMsgErro += STR0001 + aNovosCampos[nI,2] + CRLF          // "Falta campo "
        endif
    next
    if ! empty( cMsgErro )
        cMsgErro += STR0002         // "Impossível continuar."
        FMX_HELP( "OFIA624001", cMsgErro )
        return nil
    endif

    if !lSchedule
        while ! lOk .and. pergunte( cPerg, .T. )
            lOk := .T.
            for nI := 1 to 3
                if ! OA624004C_ValidPerg( nI, nI == 3 )
                    lOk := .F.
                    exit
                endif
            next
        endDo
        if ! lOk
            return nil
        endif
    endif

    dbSelectArea( "VX5" )
    dbSetOrder(1)

    dDatRef   := MV_PAR02
    cPasta    := OA624006M_GetDir()
    nTipoLev  := iif( empty( MV_PAR04 ), 2, MV_PAR04 )  // 1=Filial Corrente;2=Todas Filiais
    nTipoCli  := iif( empty( MV_PAR05 ), 1, MV_PAR05 )  // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
    if MV_PAR01 == 2    // Database
        dDatRef := dDatabase
    endif

    If lSchedule
        lOk := OA624001C_gerarArquivo( dDatRef, cPasta, nTipoCli, nTipoLev )
    Else
        FwMsgRun( Nil, {|| lOk := OA624001C_gerarArquivo( dDatRef, cPasta, nTipoCli, nTipoLev )}, STR0009, STR0010) // "Processando" / "Driver Feedback - Levantando dados para o arquivo..." 
    Endif

    If !lSchedule
        If lOk
            FWAlertSuccess(STR0006 + cPasta, "OFIA624004") //"Arquivo gerado com sucesso! O arquivo foi salvo na pasta: "
        else
            FMX_HELP("OFIA624005",;
            STR0007,; // "Nenhum registro foi encontrado para a geração do arquivo."
            STR0008) // "Revise os filtros informados e certifique-se de que existem registros que atendam aos critérios da consulta. Em seguida, execute a geração do arquivo novamente."
        EndIf
    EndIf
return nil


/*/{Protheus.doc} OA624001C_gerarArquivo
Parametrização para rotina via Schedule
@type function
@version  
@author Cristiam Rossi
@since 02/06/2026
/*/
static function OA624001C_gerarArquivo( dDatRef, cPasta, nTipoCli, nTipoLev )
    local oStatement
    local oFile
    local cFile
    local cQuery
    local cAlias     := getNextAlias()
    local cLinha
    local aBind      := {}
    local nI
    local nA
    Local lRet := .F.
    Local cCodCon := GetNewPar( "MV_MIL0005", "", cFilAnt )
    Local lFilialCorrente := nTipoLev == 1
    Local cNomFilial := ""
    Local cNomConcessionaria := ""
    Local oHelperFil  := DMS_FilialHelper():New()
    Local aFiliais := {}
    Local cBkpFilAnt := ""

    If lFilialCorrente
        aFiliais := oHelperFil:GetAllFilEmpresa( .f. )
    Else
        aFiliais := oHelperFil:GetAllFil( .t. ) // .t. = Retorna todas as Filiais mesmo que o usuario nao tem acesso
    EndIf

    cFile := "Brazil_" + cCodCon + DtoS( dDatabase ) + ".csv"

    oFile := FWFileWriter():new( cPasta + cFile, .T. )
    oFile:create()

    cBkpFilAnt := cFilAnt

    For nA := 1 to Len(aFiliais)

        cFilAnt := aFiliais[nA]
        cCodCon := GetNewPar( "MV_MIL0005", "", cFilAnt )   // Código da concessionária da filial em processamento
        aBind   := {}

        cQuery := "select VO1.VO1_FILIAL, VO1.VO1_NUMOSV, VOG_COMPAR, VOG_FONMOT, VOG_EMAIL, VOG_NOMMOT, VOG_NUMDOC,"
        cQuery += "A1_DDD, A1_TEL, A1_EMAIL, A1_NOME, A1_CGC,"
        cQuery += "VV2_DESMOD, VV8_DESCRI, VV1_PLAVEI, VOO.F2_EMISSAO, VAI_CPF, VAI_NOMTEC,"
        cQuery += "VO1_TIPOOS, VOI_TIPOOS, VAM_EMPATE, VAM_FILATE"

        cQuery += " from "+retSqlName("VO1")+" VO1 "

        cQuery += " Inner Join ( "
        cQuery += "               Select VOO.VOO_FILIAL, VOO.VOO_NUMOSV, "
        cQuery += "                      Min( SF2.F2_EMISSAO ) As F2_EMISSAO, Min(VOO.VOO_TIPTEM) as VOO_TIPTEM  "
        cQuery += "               From " + RetSqlName("VOO") + " VOO "
        cQuery += "               Inner Join " + RetSqlName("SF2") + " SF2 "
        cQuery += "               On( SF2.F2_FILIAL = VOO.VOO_FILIAL And SF2.F2_DOC = VOO.VOO_NUMNFI And SF2.F2_SERIE = VOO.VOO_SERNFI and SF2.F2_CLIENTE = VOO.VOO_FATPAR and SF2.F2_LOJA = VOO.VOO_LOJA And SF2.D_E_L_E_T_ = ' ' ) "
        cQuery += "               Where VOO.D_E_L_E_T_ = ' ' "
        cQuery += "               Group by VOO.VOO_FILIAL, VOO.VOO_NUMOSV "
        cQuery += " ) VOO "

        cQuery += " On ( VOO.VOO_FILIAL = VO1.VO1_FILIAL And VOO.VOO_NUMOSV = VO1.VO1_NUMOSV ) "
        
        cQuery += " left join "+retSqlName("VOG")+" VOG "
        cQuery += "     on  VOG_FILIAL= ? "   ; aAdd( aBind, { "C", xFilial("VOG") } )    
        cQuery += "     and VOG_CODMOT = VO1_CODMOT"
        cQuery += "     and VOG.D_E_L_E_T_= ' ' "

        cQuery += " left join "+retSqlName("SA1")+" SA1 "
        cQuery += "     on  A1_FILIAL= ? "      ; aAdd( aBind, { "C", xFilial("SA1") } )
        cQuery += "     and A1_COD = VO1_PROVEI"
        cQuery += "     and A1_LOJA = VO1_LOJPRO"
        cQuery += "     and SA1.D_E_L_E_T_= ' ' "

        cQuery += " join "+retSqlName("VV1")+" VV1 "
        cQuery += "     on  VV1_FILIAL= ? "     ; aAdd( aBind, { "C", xFilial("VV1") } )
        cQuery += "     and VV1_CHAINT = VO1_CHAINT"
        cQuery += "     and VV1.D_E_L_E_T_= ' ' "

        cQuery += " join "+retSqlName("VV2")+" VV2 "
        cQuery += "     on  VV2_FILIAL= ? "   ; aAdd( aBind, { "C", xFilial("VV2") } )
        cQuery += "     and VV2_CODMAR = VV1_CODMAR"
        cQuery += "     and VV2_MODVEI = VV1_MODVEI"
        cQuery += "     and VV2_SEGMOD = VV1_SEGMOD"
        cQuery += "     and VV2.D_E_L_E_T_= ' ' "

        cQuery += " join "+retSqlName("VV8")+" VV8 "
        cQuery += "     on  VV8.VV8_FILIAL= ? " ; aAdd( aBind, { "C", xFilial("VV8") } )
        cQuery += "     and VV8.VV8_TIPVEI = VV2.VV2_TIPVEI "
        cQuery += "     and VV8.D_E_L_E_T_ = ' ' "

        cQuery += " join "+retSqlName("VOI")+" VOI "
        cQuery += "     on  VOI_FILIAL= ? "   ; aAdd( aBind, { "C", xFilial("VOI") } )
        cQuery += "     and VOI_TIPTEM = VOO_TIPTEM"
        cQuery += "     and VOI.D_E_L_E_T_= ' ' "

        cQuery += " left join "+retSqlName("VAM")+" VAM "
        cQuery += "     on  VAM_FILIAL= ? "   ; aAdd( aBind, { "C", xFilial("VAM") } )
        cQuery += "     and VAM_IBGE = A1_IBGE"
        cQuery += "     and VAM.D_E_L_E_T_= ' ' "

        cQuery += " join "+retSqlName("VAI")+" VAI "
        cQuery += "     on  VAI_FILIAL= ? "   ; aAdd( aBind, { "C", xFilial("VAI") } )
        cQuery += "     and VAI_CODTEC = VO1_FUNABE"
        cQuery += "     and VAI.D_E_L_E_T_= ' ' "

        cQuery += " where "
        cQuery += " VO1.D_E_L_E_T_= ' ' "
        cQuery += " And VOG_COMPAR = '1' "
        cQuery += " And ( VO1.VO1_CODMOT <> ' ' Or SA1.A1_PESSOA = 'F' ) "

        cQuery += " and VO1.VO1_FILIAL= ? "   ; aAdd( aBind, { "C", xFilial("VO1") } )

        cQuery += " and VOO.F2_EMISSAO= ?"    ; aAdd( aBind, { "C", DtoS( dDatRef ) } )

        //------------------- Tipo de Cliente
        if nTipoCli == 2    // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
            cQuery += " and   VOO.VOO_FILIAL = VAM_FILATE" 
        endif
        if nTipoCli == 3    // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
            cQuery += " and   VAM.VAM_EMPATE=? "  ; aAdd( aBind, { "C", cEmpAnt } )
        endif
        if nTipoCli == 4    // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
            cQuery += " and   VAM.VAM_EMPATE = ? "   ; aAdd( aBind, { "C", " " } )
        endif

        cQuery += " order by VO1_FILIAL, F2_EMISSAO"

        oStatement := FwExecStatement():new( cQuery )

        for nI := 1 to len( aBind )
            if aBind[nI,1] == "C"
                oStatement:setString( nI, aBind[nI,2] )
            endif		
        next

        cQuery := oStatement:getFixQuery()
        cAlias := MpSysOpenQuery( cQuery )

        while ! (cAlias)->( eof() )

            lRet := .t.

            cLinha := "BR" + ";"                                                                // 01-País fixo BR
            cLinha += cCodCon + ";"                                                             // 02-Código Concessionária

            if empty( (cAlias)->VOG_FONMOT )
                cLinha += "55" + alltrim( (cAlias)->A1_DDD ) + alltrim( (cAlias)->A1_TEL ) + ";"        // 03-Telefone motorista (empresa)
            else
                cLinha += "55" + alltrim( (cAlias)->VOG_FONMOT ) + ";"                                  // 03-Telefone motorista
            endif

            if empty( (cAlias)->VOG_EMAIL )
                cLinha += alltrim( ( (cAlias)->A1_EMAIL ) ) + ";"                                       // 04-Email motorista (empresa)
            else
                cLinha += alltrim( ( (cAlias)->VOG_EMAIL ) ) + ";"                                      // 04-Email motorista
            endif

            if empty( (cAlias)->VOG_NOMMOT )
                cLinha += alltrim( ( (cAlias)->A1_NOME ) ) + ";"                                        // 05-Nome motorista (empresa)
            else
                cLinha += alltrim( ( (cAlias)->VOG_NOMMOT ) ) + ";"                                     // 05-Nome motorista
            endif

            cLinha += alltrim( (cAlias)->A1_CGC ) + ";"                                                 // 06-CNPJ/CPF empresa
            cLinha += alltrim( (cAlias)->A1_NOME ) + ";"                                                // 07-Nome empresa
            cLinha += alltrim( (cAlias)->VV2_DESMOD ) + ";"                                             // 08-Modelo veículo
            cLinha += alltrim( (cAlias)->VV1_PLAVEI ) + ";"                                             // 09-Placa veículo
            cLinha += alltrim( (cAlias)->F2_EMISSAO ) + ";"                                             // 10-Data faturamento
            cLinha += "PT-BR" + ";"                                                                     // 11-Idioma fixo PT-BR

            OA624002C_retornaNomeConcessionaria((cAlias)->VO1_FILIAL, @cNomFilial, @cNomConcessionaria)
            cLinha += alltrim( cNomFilial ) + ";"                                                       // 12-Filial do faturamento
            cLinha += alltrim( cNomConcessionaria ) + ";"                                               // 13-Nome da concessionária

            if Empty( (cAlias)->VOG_NUMDOC )
                cLinha += alltrim( ( (cAlias)->A1_CGC ) ) + ";"                                         // 14-CPF motorista (empresa)
            else
                cLinha += alltrim( ( (cAlias)->VOG_NUMDOC ) ) + ";"                                     // 14-CPF motorista
            endif

            cLinha += alltrim( (cAlias)->F2_EMISSAO ) + ";"                                             // 15-Data faturamento

            if empty( (cAlias)->VAM_FILATE )
                cLinha += "PASSAGEM" + ";"                                                              // 16-Tipo do cliente - Passagem
            elseif (cAlias)->VO1_FILIAL == (cAlias)->VAM_FILATE
                cLinha += "LOCAL" + ";"                                                                 // 16-Tipo do cliente - Local
            else
                cLinha += "LOCAL - GRUPO" + ";"                                                         // 16-Tipo do cliente - Local - Grupo
            endif

            cLinha += OA624003C_retornaTipoOs( (cAlias)->VO1_TIPOOS, (cAlias)->VOI_TIPOOS ) + ";"       // 17-Tipo de OS

            cLinha += Alltrim( (cAlias)->VV8_DESCRI ) + ";"                                             // 18-Tipo do veículo
            cLinha += alltrim( (cAlias)->VAI_CPF ) + ";"                                                // 19-CPF do consultor
            cLinha += alltrim( (cAlias)->VAI_NOMTEC ) + ";"                                             // 20-Nome do consultor
            cLinha += alltrim( (cAlias)->VO1_NUMOSV ) + ";"                                             // 21-Número da ordem de serviço

            oFile:write( cLinha + CRLF )

            (cAlias)->( dbSkip() )

        endDo

        (cAlias)->( dbCloseArea() )

    Next

    cFilAnt := cBkpFilAnt

    oFile:close()
    FWFreeObj( oFile )
    FWFreeObj( oStatement )

return lRet


/*/{Protheus.doc} OA624002C_retornaFiliais
Retorna as Filiais a serem processadas
@type function
@version  
@author Cristiam Rossi
@since 03/06/2026
/*/
static function OA624002C_retornaNomeConcessionaria(cFilVO1, cNomFilial, cNomConcessionaria)
    
    Local aAux  := {}

    Default cFilVO1   := ""
    Default cNomFilial := ""
    Default cNomConcessionaria := ""

    aAux := FWSM0Util():GetSM0Data( , cFilVO1, { "M0_FILIAL","M0_NOMECOM" } )
    cNomFilial := alltrim( aAux[1,2])
    cNomConcessionaria := alltrim( aAux[2,2] )

return aAux


/*/{Protheus.doc} OA624003C_retornaTipoOs
Retorna descrição do tipo da OS
@type function
@version  
@author Cristiam Rossi
@since 05/06/2026
/*/
static function OA624003C_retornaTipoOs( cTpOSVO1, cTpOSVOI )
    local  cRet     := ""
    local  cKey     := iif( empty( cTpOSVO1 ), cTpOSVOI, cTpOSVO1 )
    local  nPos

    if ! empty( cKey )
        if ( nPos := aScan( aMemoria, {|it| it[1] == cKey } ) ) == 0
            VX5->( dbSeek( xFilial("VX5") + "109" + cKey ) )
            aAdd( aMemoria, { cKey, alltrim(VX5->VX5_DESCRI) } )
            nPos := len( aMemoria )
        endif
        cRet := aMemoria[nPos,2]
    endif
return cRet


/*/{Protheus.doc} OA624006M_GetDir
Retorna o diretório informado na pergunta (MV_PAR03) garantindo a barra final,
evitando que o nome da pasta seja concatenado ao nome do arquivo.
@type function
@version 1.0
@author Diogo Barros
@since 25/08/2026
@return character, diretório com barra final
/*/
static function OA624006M_GetDir()

    Local cRet := AllTrim(MV_PAR03)     

    If Right(cRet, 1) <> "\"
        cRet += "\"
    EndIf

Return cRet


/*/{Protheus.doc} SchedDef
Parametrização para rotina via Schedule
@type function
@version  
@author Cristiam Rossi
@since 02/06/2026
@return array, parâmetros p/ schedule
/*/
static function SchedDef() 
local aParam   := {}

	aadd( aParam, "P" )             // 1-Tipo: P=Processo;R=Relatório
	aadd( aParam, cPerg )           // 2-Grupo de perguntas
	aadd( aParam, "" )              // 3-Alias (apenas Relatório)
	aadd( aParam, {} )              // 4-Array de ordem (apenas Relatório)
	aadd( aParam, "" )              // 5-Título (apenas Relatório)
	aadd( aParam, "" )              // 6-Layout de impressão (apenas Relatório)
	aadd( aParam, .F. )             // 7-Permite agendamento sempre ativo
	aadd( aParam, .T. )             // 8-Permite agendamento por filiais
return aParam


/*/{Protheus.doc} OA624004C_ValidPerg
Validação das perguntas
@type function
@version  
@author Cristiam Rossi
@since 19/06/2026
@return logical, 
/*/
function OA624004C_ValidPerg( nPerg, lDirVazio )
default nPerg := 0
default lDirVazio := .F.

    do case
        case nPerg == 1
            if MV_PAR01 == 2            // 1=Informada; 2=Database
                MV_PAR02 := CtoD(" ")
            endif
        case nPerg == 2
            if MV_PAR01 == 2            // 1=Informada; 2=Database
                MV_PAR02 := CtoD(" ")
            elseif empty( MV_PAR02 )
                FMX_HELP( "OFIA624002", STR0003 ) //"Informe uma data válida"
                return .F.
            endif
        case nPerg == 3
            if empty( MV_PAR03 ) .and. lDirVazio
                FMX_HELP( "OFIA624003", STR0011 ) //"Selecione o diretório"
                return .F.
            endif
            if !empty( MV_PAR03 ) .and. ! ExistDir( MV_PAR03 )
                FMX_HELP( "OFIA624003", STR0004 ) //"Diretório selecionado não existe"
                MV_PAR03 := ""
                return .F.
            endif            
    endcase
return .T.
