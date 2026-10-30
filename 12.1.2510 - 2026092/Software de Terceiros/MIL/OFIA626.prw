#include "totvs.ch"
#include "OFIA626.CH"
static cPerg := "OFIA626"
static aMemoria := {}

/*/{Protheus.doc} OFIA626
Rotina de exportação de dados relacionados a gestores de frotas, OS, veículos, cliente e consultores em formato .CSV
@author Cristiam Rossi
@since 11/06/2026
@version 1.0
@type function
/*/
function OFIA626()
local   dInicio
local   dTermino
local   cPasta    := ""
local   cConcess
local   nTipoLev  := 2
local   nTipoCli  := 1
local   nI
local   lSchedule := FWGetRunSchedule()

local   lOk       := .F.

    if !lSchedule
        while ! lOk .and. pergunte( cPerg, .T. )
            lOk := .T.
            for nI := 1 to 7
                if ! OA626004C_ValidPerg( nI, nI == 4 )
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

    dbSelectArea( "VOO" )
    dbSetOrder(1)

    if MV_PAR01 == 1        // Período informado
        dInicio   := MV_PAR02
        dTermino  := MV_PAR03
    else                    // Última semana
        dInicio   := dDatabase-7
        dTermino  := dDatabase
    endif

    if ! empty( MV_PAR04 ) .and. ExistDir( MV_PAR04 )
        cPasta := OA626006M_GetDir()
    endif
    cConcess  := MV_PAR05
    if ! empty( MV_PAR06 )
        nTipoLev  := MV_PAR06  // 1=Filial Corrente;2=Todas Filiais
    endif
    if ! empty( MV_PAR07 )
        nTipoCli  := MV_PAR07  // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
    endif

    If lSchedule
        lOk := OA626001C_gerarArquivo( dInicio, dTermino, cPasta, cConcess, nTipoCli, nTipoLev )
    Else
        FwMsgRun( Nil, {|| lOk := OA626001C_gerarArquivo( dInicio, dTermino, cPasta, cConcess, nTipoCli, nTipoLev )}, STR0005, STR0006) // "Processando" / ""Owner Feedback - Levantando dados para o arquivo..."" 
    Endif

    If lOk
       FWAlertSuccess(STR0004, "OFIA626") //"Arquivo gerado corretamente!"
    EndIf

return nil


/*/{Protheus.doc} OA626001C_gerarArquivo
Parametrização para rotina via Schedule
@type function
@version  
@author Cristiam Rossi
@since 02/06/2026
/*/
static function OA626001C_gerarArquivo( dInicio, dTermino, cPasta, cConcess, nTipoCli, nTipoLev )

    local oStatement
    local oFile
    local cFile
    local cQuery
    local cAlias
    local cLinha
    local aBind      := {}
    local nI := 0
    local nj := 0
    Local lRet := .T.
    Local lFilialCorrente := nTipoLev == 1
    Local oHelperFil  := DMS_FilialHelper():New()
    Local aFiliais := {}
    Local cCodCon := GetNewPar( "MV_MIL0005", "", cFilAnt )
    Local cBkpFilAnt := cFilAnt

    If lFilialCorrente
        aFiliais := oHelperFil:GetAllFilEmpresa( .f. )
    Else
        aFiliais := oHelperFil:GetAllFil( .t. ) // .t. = Retorna todas as Filiais mesmo que o usuario nao tem acesso
    EndIf

    cFile := "YourRoute_Brazil_" + alltrim(cCodCon) + DtoS( dDatabase ) + ".csv"

    oFile := FWFileWriter():new( cPasta + cFile, .F. )
    oFile:SetCaseSensitive(.T.)
    oFile:create()

    cLinha := "CNPJ/CPF"                       + ";"
    cLinha += "Razão Social"                   + ";"
    cLinha += "Contato para Oficina"           + ";"
    cLinha += "Celular do Contato"             + ";"
    cLinha += "E-mail do Contato"              + ";"
    cLinha += "Número da OS"                   + ";"
    cLinha += "Data do Serviço"                + ";"
    cLinha += "Data do fechamento da OS"       + ";"
    cLinha += "Data da emissão da NF"          + ";"
    cLinha += "Placa do veículo"               + ";"
    cLinha += "Chassi do Veículo"              + ";"
    cLinha += "Tipo de OS"                     + ";"
    cLinha += "Tipo de Veiculo"                + ";"
    cLinha += "Modelo do Veículo"              + ";"
    cLinha += "Tipo de Cliente(Local/Passagem)"+ ";"
    cLinha += "Código da concessionária"       + ";"
    cLinha += "Filial(Concessionária)"         + ";"
    cLinha += "Grupo(Concessionária)"          + ";"
    cLinha += "Nome do Consultor"              + ";"
    cLinha += "CPF do Consultor"               + ";"

    oFile:write( cLinha + CRLF )

    For nI := 1 to Len(aFiliais)

        cFilAnt := aFiliais[nI]
        cCodCon := GetNewPar( "MV_MIL0005", "", cFilAnt )   // Reposiciona o cod. da concessionária p/ a filial corrente do loop
        aBind   := {}

        cQuery := "select VWB_DDD, VWB_FONE, VWB_EMAIL, VWB_NOMGES,"
        cQuery += "A1_DDD, A1_TEL, A1_EMAIL, A1_NOME, A1_CGC,"
        cQuery += "VE1_DESMAR, VV2_DESMOD, VV8_DESCRI, VV1_PLAVEI, VV1_CHASSI, F2_EMISSAO, VAI_CPF, VAI_NOMTEC,"
        cQuery += "VO1_NUMOSV, VO1_TIPOOS, VOI_TIPOOS, DT_INI, VAM_EMPATE, VAM_FILATE, LIBFAT.F2_FILIAL" 

        cQuery += " from "+retSqlName("VO1")+" VO1 " 

        cQuery += " left join "+retSqlName("VWB")+" VWB " 
        cQuery += "     on  VWB_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VWB") } )    
        cQuery += "     and VWB.VWB_CODGES = VO1.VO1_CODGES "
        cQuery += "     and VWB.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += " left join "+retSqlName("SA1")+" SA1 " 
        cQuery += "     on  A1_FILIAL=?"                              ; aAdd( aBind, { "C", xFilial("SA1") } )
        cQuery += "     and A1_COD = VO1_PROVEI" 
        cQuery += "     and A1_LOJA = VO1_LOJPRO" 
        cQuery += "     and SA1.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += " join (" 
        cQuery += "         select SF2.F2_FILIAL F2_FILIAL, VOO_FILIAL, VOO_NUMOSV, VOI_TIPOOS, min(F2_EMISSAO) F2_EMISSAO," 
		cQuery += "         CASE
		cQuery += "         	WHEN COALESCE(MIN(VO3_DATDIS), MIN(VO4_DATINI)) < MIN(VO4_DATINI)
		cQuery += "         		THEN COALESCE(MIN(VO3_DATDIS), MIN(VO4_DATINI))
		cQuery += "         	ELSE MIN(VO4_DATINI)
		cQuery += "         END AS DT_INI

        cQuery += "         from "+retSqlName("VOO")+" VOO " 
        cQuery += "         join "+retSqlName("SF2")+" SF2 " 
        cQuery += "             on  F2_FILIAL=?"                              ; aAdd( aBind, { "C", xFilial("SF2") } )
        cQuery += "             and F2_DOC   = VOO_NUMNFI" 
        cQuery += "             and F2_SERIE = VOO_SERNFI" 
        cQuery += "             and F2_CLIENTE = VOO_FATPAR" 
        cQuery += "             and F2_LOJA = VOO_LOJA" 
        cQuery += "             and SF2.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += "         join "+retSqlName("VOI")+" VOI " 
        cQuery += "             on  VOI_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VOI") } )
        cQuery += "             and VOI_TIPTEM = VOO_TIPTEM" 
        cQuery += "             and VOI.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += "         left join "+retSqlName("VO3")+" VO3 " 
        cQuery += "             on  VO3_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VO3") } )
        cQuery += "             and VO3_NUMOSV = VOO_NUMOSV" 
        cQuery += "             and VO3_DATDIS <> ?"                          ; aAdd( aBind, { "C", " " } )
        cQuery += "             and VO3.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += "         left join "+retSqlName("VO4")+" VO4 " 
        cQuery += "             on  VO4_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VO4") } )
        cQuery += "             and VO4_NUMOSV = VOO_NUMOSV" 
        cQuery += "             and VO4_DATINI <> ?"                          ; aAdd( aBind, { "C", " " } )
        cQuery += "             and VO4.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += "         where VOO_FILIAL=?"                               ; aAdd( aBind, { "C", xFilial("VOO") } )
        cQuery += "         and   VOO_NUMNFI <> ?"                            ; aAdd( aBind, { "C", " " } )
        cQuery += "         and   VOO.D_E_L_E_T_=?"                           ; aAdd( aBind, { "C", " " } )

        cQuery += "         group by VOO_FILIAL, VOO_NUMOSV, VOI_TIPOOS, SF2.F2_FILIAL" 
        cQuery += "     ) LIBFAT on VOO_FILIAL = VO1_FILIAL and VOO_NUMOSV = VO1_NUMOSV" 

        cQuery += " join "+retSqlName("VV1")+" VV1 " 
        cQuery += "     on  VV1_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VV1") } )
        cQuery += "     and VV1_CHAINT = VO1_CHAINT" 
        cQuery += "     and VV1.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += " join "+retSqlName("VV2")+" VV2 " 
        cQuery += "     on  VV2_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VV2") } )
        cQuery += "     and VV2_CODMAR = VV1_CODMAR" 
        cQuery += "     and VV2_MODVEI = VV1_MODVEI" 
        cQuery += "     and VV2_SEGMOD = VV1_SEGMOD" 
        cQuery += "     and VV2.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += " left join "+retSqlName("VE1")+" VE1 "     // Marca do veículo
        cQuery += "     on  VE1_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VE1") } )
        cQuery += "     and VE1_CODMAR = VV1_CODMAR"
        cQuery += "     and VE1.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += " join "+retSqlName("VV8")+" VV8 "
        cQuery += "     on  VV8.VV8_FILIAL= ? "                       ; aAdd( aBind, { "C", xFilial("VV8") } )
        cQuery += "     and VV8.VV8_TIPVEI = VV2.VV2_TIPVEI "
        cQuery += "     and VV8.D_E_L_E_T_ = ' ' "

        cQuery += " left join "+retSqlName("VAM")+" VAM " 
        cQuery += "     on  VAM_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VAM") } )
        cQuery += "     and VAM_IBGE = A1_IBGE" 
        cQuery += "     and VAM.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += " join "+retSqlName("VAI")+" VAI " 
        cQuery += "     on  VAI_FILIAL=?"                             ; aAdd( aBind, { "C", xFilial("VAI") } )
        cQuery += "     and VAI_CODTEC = VO1_FUNABE" 
        cQuery += "     and VAI.D_E_L_E_T_=?"                         ; aAdd( aBind, { "C", " " } )

        cQuery += " where VO1_FILIAL=?"                               ; aAdd( aBind, { "C", xFilial("VO1") } )
        cQuery += " and   F2_EMISSAO between ? and ?"                 ; aAdd( aBind, { "C", DtoS( dInicio ) } )       ; aAdd( aBind, { "C", DtoS( dTermino ) } )
        cQuery += " and   VWB.VWB_COMPAR = ? "                        ; aAdd( aBind, { "C", '1' } )

        //------------------- Tipo de Cliente
        if nTipoCli == 2    // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
            cQuery += " and   F2_FILIAL = VAM_FILATE" 
        endif
        if nTipoCli == 3    // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
            cQuery += " and   VAM_EMPATE=? "                          ; aAdd( aBind, { "C", cEmpAnt } )
        endif
        if nTipoCli == 4    // 1=Todos;2=Local;3=Local-Grupo;4=Passagem
            cQuery += " and   VAM_EMPATE=? "                          ; aAdd( aBind, { "C", " " } )
        endif

        cQuery += " and  VO1.D_E_L_E_T_=?"                            ; aAdd( aBind, { "C", " " } )
        cQuery += " order by VO1_FILIAL, F2_EMISSAO"

        oStatement := FwExecStatement():new( cQuery )

        for nj := 1 to len( aBind )
            if aBind[nj,1] == "C"
                oStatement:setString( nj, aBind[nj,2] )
            endif		
        next

        cQuery := oStatement:getFixQuery()
        cAlias := MpSysOpenQuery( cQuery )

        while ! (cAlias)->( eof() )

            cLinha := alltrim( (cAlias)->A1_CGC ) + ";"                                                 // 01-CNPJ
            cLinha += alltrim( (cAlias)->A1_NOME ) + ";"                                                // 02-Razão Digital
            
            if empty( (cAlias)->VWB_NOMGES )  
                cLinha += alltrim( (cAlias)->A1_NOME ) + ";"                                            // 03-Contato p/ oficina - Empresa
            else
                cLinha += alltrim( (cAlias)->VWB_NOMGES ) + ";"                                  // 03-Contato p/ oficina - Gestor
            endif

            if empty( (cAlias)->VWB_FONE )
                cLinha += "55" + alltrim( (cAlias)->A1_DDD ) + alltrim( (cAlias)->A1_TEL ) + ";"        // 03-Telefone Empresa
            else
                cLinha += "55" + alltrim( (cAlias)->VWB_DDD ) + alltrim( (cAlias)->VWB_FONE ) + ";"                                    // 03-Telefone Gestor
            endif

            if empty( (cAlias)->VWB_EMAIL )
                cLinha += alltrim( ( (cAlias)->A1_EMAIL ) ) + ";"                                       // 04-Email Empresa
            else
                cLinha += alltrim( ( (cAlias)->VWB_EMAIL ) ) + ";"                                      // 04-Email Gestor
            endif

            cLinha += alltrim( (cAlias)->VO1_NUMOSV ) +";"                                              // 05-Número da OS
            cLinha += DtoC( StoD( (cAlias)->DT_INI )) + ";"                                             // 06-Data do 1º serviço/venda
            cLinha += DtoC( StoD( (cAlias)->F2_EMISSAO )) + ";"                                         // 07-Data Fechamento da OS
            cLinha += DtoC( StoD( (cAlias)->F2_EMISSAO )) + ";"                                         // 08-Data faturamento
            cLinha += alltrim( (cAlias)->VV1_PLAVEI ) + ";"                                             // 09-Placa veículo
            cLinha += right( alltrim( (cAlias)->VV1_CHASSI ), 7 ) + ";"                                 // 10-Chassi veículo (resumido - 7 últimos dígitos)
            cLinha += OA626003C_retornaTipoOs( (cAlias)->VO1_TIPOOS, (cAlias)->VOI_TIPOOS ) + ";"       // 11-Tipo de OS
            cLinha += Alltrim( (cAlias)->VV8_DESCRI ) + ";"                                           // 12-Tipo do veículo
            cLinha += alltrim( (cAlias)->VE1_DESMAR ) + "||" + alltrim( (cAlias)->VV2_DESMOD ) + ";"    // 13-Modelo veículo (Marca||Modelo)

            if empty( (cAlias)->VAM_FILATE )
                cLinha += "PASSAGEM" + ";"                                                              // 14-Tipo do cliente - Passagem
            elseif (cAlias)->F2_FILIAL == (cAlias)->VAM_FILATE
                cLinha += "LOCAL" + ";"                                                                 // 14-Tipo do cliente - Local
            else
                cLinha += "LOCAL - GRUPO" + ";"                                                         // 14-Tipo do cliente - Local - Grupo
            endif

            cLinha += alltrim( cCodCon ) + ";"                                                          // 15-Codigo Concessionária (igual coluna Q)
            cLinha += alltrim( cCodCon ) + ";"                                                          // 16-Filial Concessionária
            cLinha += alltrim( cConcess ) + ";"                                                         // 17-Grupo Concessionária
            cLinha += alltrim( (cAlias)->VAI_NOMTEC ) + ";"                                             // 18-Nome do consultor
            cLinha += alltrim( (cAlias)->VAI_CPF ) + ";"                                                // 19-CPF do consultor

            oFile:write( cLinha + CRLF )

            (cAlias)->( dbSkip() )

        endDo

        (cAlias)->( dbCloseArea() )

        FWFreeObj( oStatement )   // libera a instância desta filial; recriada na próxima iteração

    Next

    cFilAnt := cBkpFilAnt   // restaura a filial da sessão do usuário

    oFile:close()

    FWFreeObj( oFile )

return lRet

/*/{Protheus.doc} OA626003C_retornaTipoOs
Retorna descrição do tipo da OS
@type function
@version  
@author Cristiam Rossi
@since 05/06/2026
/*/
static function OA626003C_retornaTipoOs( cTpOSVO1, cTpOSVOI )

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


/*/{Protheus.doc} OA626006M_GetDir
Retorna o diretório informado na pergunta (MV_PAR04) garantindo a barra final,
evitando que o nome da pasta seja concatenado ao nome do arquivo.
@type function
@version 1.0
@author Diogo Barros
@since 25/08/2026
@return character, diretório com barra final
/*/
static function OA626006M_GetDir()

    Local cRet := AllTrim(MV_PAR04)

    If Right(cRet, 1) <> "\"
        cRet += "\"
    EndIf

Return cRet

/*/{Protheus.doc} OA626004C_ValidPerg
Validação das perguntas
@type function
@version  
@author Cristiam Rossi
@since 18/06/2026
@return logical, 
/*/
function OA626004C_ValidPerg( nPerg, lDirVazio )

    default nPerg := 0
    default lDirVazio := .F.

    do case
        case nPerg == 1
            if MV_PAR01 == 2            // 1=Informar períodos; 2=Última semana
                MV_PAR02 := CtoD(" ")
                MV_PAR03 := CtoD(" ")
            endif
        case nPerg == 2
            if MV_PAR01 == 2            // 1=Informar períodos; 2=Última semana
                MV_PAR02 := CtoD(" ")
                MV_PAR03 := CtoD(" ")
            elseif empty( MV_PAR02 )
                MV_PAR02 := CtoD(" ")
                MV_PAR03 := CtoD(" ")
                FMX_HELP( "OFIA626", STR0001 ) //"Informe uma data válida"
                return .F.
            endif
        case nPerg == 3
            if MV_PAR01 == 2            // 1=Informar períodos; 2=Última semana
                MV_PAR02 := CtoD(" ")
                MV_PAR03 := CtoD(" ")
            elseif empty( MV_PAR03 )
                MV_PAR02 := CtoD(" ")
                MV_PAR03 := CtoD(" ")
                FMX_HELP( "OFIA626", STR0001 ) //"Informe uma data válida"
                return .F.
            endif
        case nPerg == 4
            if empty( MV_PAR04 ) .and. lDirVazio
                FMX_HELP( "OFIA626", STR0007 ) //"Selecione o diretório."                
                return .F.
            endif
            if !empty( MV_PAR04 ) .and. !ExistDir( MV_PAR04 )
                FMX_HELP( "OFIA626", STR0002 ) //"Diretório selecionado não existe"
                MV_PAR04 := ""
                return .F.
            endif

        case nPerg == 5
            If Empty(MV_PAR05)
                FMX_HELP( "OFIA626", STR0003 ) //"Informe um cod. concessionário válido"
                Return .F.
            EndIf
    endcase
return .T.
