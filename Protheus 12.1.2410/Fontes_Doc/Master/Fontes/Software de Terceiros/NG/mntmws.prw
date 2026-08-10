#Include 'Totvs.ch'

Static cQuerySE4

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTMWS
Schedule responsável pela integração com a Brobot.
Pega multas recebidas pela brobot e insere no protheus.

@type   Function

@author Eduardo Mussi
@since  01/02/2024

/*/
//-------------------------------------------------------------------
Function MNTMWS()

    Local aBroBotFi  := StrTokArr( SuperGetMV( 'MV_NGBROFI', .F., '' ), ';' )
    Local cBroBot    := SuperGetMV( 'MV_NGBROBO', .F., '')
    Local aHeadStr   := { 'token: ' + cBroBot, 'Content-Type: application/json; charset=UTF-8' }
    Local cBranchTRX := FwxFilial( 'TRX' )
    Local cURL       := 'https://api.platform.brobot.com.br/cm-frotas/multas?per_page=999' // Requisição Brobot + definição da quantidade maxima de multas na requisição(999)
    Local cError     := ''
    Local cHour      := ''
    Local cModel     := '' // Model que será executado MNTA765 ou MNTA766
    Local cFilialST9    := ''
    Local lNgIntFi   := SuperGetMV( 'MV_NGMNTFI', .F., 'N' ) == 'S'
    Local nStatus    := 0
    Local nTickets   := 0
    Local nOP        := 0    // Operação realizada na multa 1 - Criar Multa, 2 - Criar Notificação, 3 - Gerar Multa a partir de Notificação
    Local oParser

    // Utilizado na rotina MNTA765
    Private nOpcao   := 3

    If !FWSIXUtil():ExistIndex( 'TRX', '9' )
        
        fSaveLog( 'Tabela TRX não possui o indice necessário para o correto funcionamento deste Schedule.' )

    ElseIf lNgIntFi .And. Len( aBroBotFi ) < 4
        
        fSaveLog( 'O parâmetro MV_NGBROFI não foi configurado corretamente!' )

    ElseIf Empty( cBroBot )
        
        fSaveLog( 'O parâmetro MV_NGBROBO está vazio!' )

    Else
    
        MNTA765VAR()
        SetInclui()
        // Caso cliente insira os campos De/Até 
        If !Empty( MV_PAR01 ) .And. !Empty( MV_PAR02 )
            cURL += '&q[period_type]=ocurred_at&q[start_date]='
            cURL += FWTimeStamp( 6, MV_PAR01, '00:00:00' )
            cURL += '&q[end_date]='
            cURL += FWTimeStamp( 6, MV_PAR02, '23:59:59' )
        EndIf
        
        // Caso o parametro MV_PAR03 seja definido como 2 pelo usuário, 
        // define que será criado um órgão autuador genérico
        If MV_PAR03 == 2
            // O código 000000 foi definido devido ao campo ser de auto incremento, começando sempre em 000001, 
            // assim criando o código de 000000 não trará nenhuma diferença em um ambiente com dados já existentes em base
            dbSelectArea( 'TRZ' )
            dbSetOrder( 1 )
            If !MsSeek( FwxFilial( 'TRZ' ) + '000000' )
                RecLock( 'TRZ', .T. )
                TRZ->TRZ_FILIAL := FwxFilial( 'TRZ' )
                TRZ->TRZ_CODOR  := '000000'
                TRZ->TRZ_NOMOR  := 'Uso exclusivo Integração Brobot'
                If lNgIntFi
                    TRZ->TRZ_FORNEC := MV_PAR04
                    TRZ->TRZ_LOJA   := MV_PAR05
                    TRZ->TRZ_CONPAG := MV_PAR06
                EndIf
                TRZ->( MsUnLock() )
            EndIf
        EndIf

        cResponse := HTTPGet( cURL, /*cGetParms*/, /*nTimeOut*/, aHeadStr )

        // Verificar e tratar o retorno para quando existir erros de processos.
        nStatus    := HTTPGetStatus( cError )

        If nStatus == 200

            If FWJsonDeserialize( cResponse, @oParser ) .And. AttIsMemberOf( oParser, 'data' )
                
                For nTickets := 1 To  Len( oParser:Data )

                    // Somente incluir multas que ainda não foram pagas e multas que já passaram data de pagamento
                    If oParser:Data[ nTickets ]:status == 'opened' .Or. oParser:Data[ nTickets ]:status == 'expired'

                        aInfo := FwDateTimeToLocal( oParser:Data[ nTickets ]:created_at )
                        cHour := SubStr( aInfo[ 2 ], 1, 5 )

                        cFilialST9 := Posicione( 'ST9', 14, oParser:Data[ nTickets ]:plate, 'T9_FILIAL' )

                        If Empty( cFilialST9 )

                            cFilialST9 := FWxFilial( 'TRX' )

                        EndIf

                        dbSelectArea( 'TRX' )
                        dbSetOrder( 4 ) // TRX_FILIAL + TRX_NUMAIT
                        If !msSeek( cFilialST9 + AllTrim( oParser:Data[ nTickets ]:ait ) ) .Or. ( msSeek( cFilialST9 + AllTrim( oParser:Data[ nTickets ]:ait ) );
                         .And. Empty( TRX->TRX_DTVECI ) .And. ValType( oParser:Data[ nTickets ]:expired_at ) != 'U' )

                            dbSelectArea( 'TRX' )
                            dbSetOrder( 4 ) // TRX_FILIAL + TRX_NUMAIT

                            DO CASE
                                
                                CASE ValType( oParser:Data[ nTickets ]:expired_at ) != 'U' .And.;
                                    msSeek( cFilialST9 + AllTrim( oParser:Data[ nTickets ]:ait ) ) .And. Empty( TRX->TRX_DTVECI )

                                    nOP := 3
                                    cModel := 'MNTA766'
                                    nOpcao := 4

                                CASE ValType( oParser:Data[ nTickets ]:expired_at ) != 'U'
                                    
                                    nOP := 1
                                    cModel := 'MNTA765'
                                    nOpcao := 3

                                OTHERWISE

                                    nOP := 2
                                    cModel := 'MNTA766'
                                    nOpcao := 3
 
                            ENDCASE

                            oModel := FwLoadModel( cModel )

                            oModel:SetOperation( nOpcao )
                            oModel:Activate()

                            oModel:SetValue( 'MULTAS', 'TRX_FILIAL', cFilialST9 )

                            oModel:SetValue( 'MULTAS', 'TRX_MULTA' , fValSXE( cBranchTRX ) )
                            oModel:SetValue( 'MULTAS', 'TRX_DTINFR', aInfo[ 1 ] )
                            oModel:SetValue( 'MULTAS', 'TRX_RHINFR', cHour )
                            
                            If ValType( oParser:Data[ nTickets ]:ait ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_NUMAIT', oParser:Data[ nTickets ]:ait )
                            EndIf
                            
                            oModel:SetValue( 'MULTAS', 'TRX_CODINF', cValToChar( oParser:Data[ nTickets ]:code ) )
                            
                            If ValType( oParser:Data[ nTickets ]:local ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_LOCAL' , oParser:Data[ nTickets ]:local )
                            EndIf

                            If ValType( oParser:Data[ nTickets ]:uf ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_UFINF' , oParser:Data[ nTickets ]:uf )
                            EndIf
                            
                            // Tratamento realizado para que ao receber uma multa onde não esteja preenchido o órgão autuador,
                            // adiciona um órgão genérico para conseguir realizar a importação
                            If ValType( oParser:Data[ nTickets ]:issuing_authority ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_CODOR' , oParser:Data[ nTickets ]:issuing_authority )
                            Else
                                oModel:SetValue( 'MULTAS', 'TRX_CODOR' , '000000' )
                            EndIf

                            If ValType( oParser:Data[ nTickets ]:plate ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_PLACA' , oParser:Data[ nTickets ]:plate )
                            EndIf

                            If lNgIntFi .And. ValType( oParser:Data[ nTickets ]:barcode_digits ) == 'C' .And. ( nOP == 1 .Or. nOP == 3 )
                            
                                oModel:SetValue( 'MULTAS', 'E2_LINDIG' , StrTran( StrTran( oParser:Data[ nTickets ]:barcode_digits, ' ', '' ), '-', '' ) )
                            
                            EndIf

                            oModel:SetValue( 'MULTAS', 'TRX_ORIGEM', '1' )
                            
                            //Existem cenários onde o retorno da Brobot vem como Nulo.
                            If ValType( oParser:Data[ nTickets ]:value_cents ) == 'N' .And. nOP != 2
                                oModel:SetValue( 'MULTAS', 'TRX_VALOR' , oParser:Data[ nTickets ]:value_cents / 100 )
                            EndIf
                            
                            If nOP != 2
                                oModel:SetValue( 'MULTAS', 'TRX_DTEMIS', aInfo[ 1 ] )
                                oModel:SetValue( 'MULTAS', 'TRX_TPMULT', 'TRANSITO' )
                            Else
                                oModel:SetValue( 'MULTAS', 'TRX_TPMULT', 'NOTIFICACAO' )
                            EndIf

                            // O campo referente a data de vencimento poderá não ser carregado em alguns cenários.
                            If ValType( oParser:Data[ nTickets ]:expired_at ) == 'C'
                                oModel:SetValue( 'MULTAS', 'TRX_DTVECI', StoD( StrTran(oParser:Data[ nTickets ]:expired_at, '-', '') ) )
                            EndIf

                            If lNgIntFi .And. nOP != 2

                                oModel:SetValue( 'MULTAS', 'TRX_PREFIX', aBroBotFi[ 1 ] )
                                oModel:SetValue( 'MULTAS', 'TRX_TIPO'  , aBroBotFi[ 2 ] )
                                oModel:SetValue( 'MULTAS', 'TRX_NATURE', aBroBotFi[ 3 ] )
                                oModel:SetValue( 'MULTAS', 'TRX_CONPAG', fConPag( aInfo[ 1 ], StoD( StrTran( oParser:Data[ nTickets ]:expired_at, '-', '' ) ), aBroBotFi[ 4 ] ) )
                                
                            EndIf

                            If oModel:VldData()
                                oModel:CommitData()
                            Else
                                VarInfo( ' -----------   Erro ao Incluir Multa  ------------' + CRLF +;
                                         ' [ Multa ' + cValToChar( oParser:Data[ nTickets ]:code ) + ' / AIT   ' + cValToChar( oParser:Data[ nTickets ]:ait ) + ' / Placa ' + cValToChar( oParser:Data[ nTickets ]:plate ) + ' ] ',  )
                                VarInfo( ' Erro  '                                              , oModel:GetErrorMessage() )
                                RollBackSXE( 'TRX', 'TRX_MULTA' )
                            EndIf

                            oModel:DeActivate()
                            oModel:Destroy()
                            oModel := NIL
                            MNTA765VAR()
                        
                        EndIf

                    EndIf

                Next nTickets

            EndIf

        ElseIf nStatus == 403
            
            fSaveLog( 'Token informado no parâmetro MV_NGBROBO está incorreto!' )

        EndIf

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fValSXE
Valida numero do campo TRX_MULTA

@type   Function

@author Eduardo Mussi
@since  02/02/2024
@param  cBranchTRX, caracter, Filial TRX

@return cTicket, Retorna o numero disponivel pelo SXE.
/*/
//-------------------------------------------------------------------
Static Function fValSXE( cBranchTRX )

    Local aArea   := FwGetArea()
    Local cTicket := GetSxeNum( 'TRX', 'TRX_MULTA' )
    Local lFound  := .T.

    dbSelectArea( 'TRX' )
    dbSetOrder( 1 )

    While lFound
        
        If dbSeek( cBranchTRX + cTicket )
            
            cTicket := GetSxeNum( 'TRX', 'TRX_MULTA' )

        Else
            
            lFound := .F.

        EndIf

    EndDo

    FwRestArea( aArea )

Return cTicket

//-------------------------------------------------------------------
/*/{Protheus.doc} fSaveLog
Salva possiveis problemas encontrados ao rodar o schedule.

@type   Function

@author Eduardo Mussi
@since  14/02/2024
@param  cMsg, Caracter, Mensagem de inconsistência

/*/
//-------------------------------------------------------------------
Static Function fSaveLog(cMsg)

    Local cFileName :='\MNTMWS' + dToS( Date() ) + StrTran( Time(), ':' ) + '.txt'
    Local cText     := ''
 
    // Montando a mensagem
    cText += 'Usuário  - ' + cUserName         + CRLF
    cText += 'Data     - ' + dToC( dDataBase ) + CRLF
    cText += 'Hora     - ' + Time()            + CRLF
    cText += 'Mensagem - ' + cMsg

    MemoWrite( cFileName, cText )
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@type    function
@author  Eduardo Mussi
@since   02/02/2024
@sample  SchedDef()

@return  aParam, Array, Contém as definições de parâmetros
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

    Local cPerg := 'PARAMDEF'

    If !Empty( Posicione( 'SX1', 1, 'MNTMWS', 'X1_ORDEM' ) )
        
        If SuperGetMV( 'MV_NGMNTFI', .F., 'N' ) == 'S'
            cPerg := 'MNTMWSF'
        Else
            cPerg := 'MNTMWS'
        EndIf

    EndIf

Return { 'P', cPerg, '', {}, 'Caça Multas - Brobot' }

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTMWSVLD
Validação de parâmetros

@param nSelect, numérico, parâmetro
@author Tainã Alberto Cardoso
@since 15/01/2025
@return boolean
/*/
//---------------------------------------------------------------------
Function MNTMWSVLD(nSelect)

    Local lRet := .T.

    DO CASE
        CASE nSelect == 1 // Fornecedor
            lRet:= MV_PAR03 == 1 .Or. ( MV_PAR03 == 2 .And. NaoVazio() .And. ExistCpo( 'SA2', MV_PAR04 ) )
        CASE nSelect == 2 // Loja
            lRet := MV_PAR03 == 1 .Or. ( MV_PAR03 == 2 .And. NaoVazio() .And. ExistCpo( 'SA2', MV_PAR04 + MV_PAR05 ) )
        CASE nSelect == 3 // Cond. Pagamento?
            lRet := MV_PAR03 == 1 .Or. ( MV_PAR03 == 2 .And. NaoVazio() .And. ExistCpo( 'SE4', MV_PAR06 ) )
    ENDCASE

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fConPag
Responsável por retornar a condição de pagamento da Multa
Busca uma condição de pagamento a vista com o intervalo de dias entre
a emissão e o pagamento igual ao intervalo da multa

@author João Ricardo Santini Zandoná
@since 22/07/2025
@param dDtEmis, data, data de emissão da multa
@param dDtVeci, data, data de vencimento da multa
@param cConPag, caractere, condição de pagamento padrão

@return caractere, retorna a condição de pagamneto que deve ser usada
/*/
//---------------------------------------------------------------------
Static Function fConPag( dDtEmis, dDtVeci, cConPag )

    Local cReturn := cConPag
    Local nNumDias := dDtVeci - dDtEmis
    Local cAliasQry := GetNextAlias()

    If Empty( cQuerySE4 )

        cQuerySE4 := 'SELECT '
        cQuerySE4 += 'SE4.E4_CODIGO AS CODIGO '
        cQuerySE4 += 'FROM ' + RetSqlName( 'SE4' ) + ' SE4 '
        cQuerySE4 += 'WHERE '
        cQuerySE4 += 	'SE4.E4_FILIAL = ? '
        cQuerySE4 += 	'AND SE4.E4_TIPO = ? '
        cQuerySE4 += 	'AND SE4.E4_COND = ? '
        cQuerySE4 += 	"AND SE4.D_E_L_E_T_ = ? "

        cQuerySE4 := ChangeQuery( cQuerySE4 )

    EndIf

    aBind := {}
    aAdd( aBind, FWxFilial( 'SE4' ) )
    aAdd( aBind, '1' )
    aAdd( aBind, cValToChar( nNumDias ) )
    aAdd( aBind, ' ' )

    cAliasQry := GetNextAlias()
    dbUseArea( .T., 'TOPCONN', TcGenQry2( , , cQuerySE4, aBind ), cAliasQry, .T., .T. )

    If (cAliasQry)->( !Eof() )

        cReturn := (cAliasQry)->CODIGO

    EndIf
    
    (cAliasQry)->( dbCloseArea() )

Return cReturn
