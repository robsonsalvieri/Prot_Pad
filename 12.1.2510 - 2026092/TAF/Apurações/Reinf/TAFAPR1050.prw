#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR1050
Função que efetua chamada da rotina de copia/apuração do evento R-1050

@return Nil

@author Carlos Eduardo Boy
@since  19/08/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFAPR1050( cEvento, cPeriodo , cIdLog, lSucesso, cCnpj )
Local lRet := .t.

TAFR1050COP(cEvento, cPeriodo , cIdLog, @lSucesso, cCnpj)

return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR1050COP


@return Nil

@author Carlos Eduardo Boy
@since  19/08/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFR1050COP(cEvento, cPeriodo , cIdLog, lSucesso, cCnpj)
Local lRet      := .t.
Local lDelete   := .f.
Local lInsert   := .t.
Local lFoundV3X := .f.
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local cTpEvento := 'I'
Local cKeyLog   := ''
Local cVerAnt   := ''
Local cProtAnt  := ''
Local cErroVld  := ''
Local oModel    := nil
Local cAmbReinf := Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
Default lSucesso := .f.

cQuery := " SELECT "
cQuery += " 	V3X.V3X_ID,     "
cQuery += " 	V3X.V3X_CNPJ,   "
cQuery += " 	V3X.V3X_INIPER, "
cQuery += " 	V3X.V3X_FINPER, "
cQuery += " 	V3X.V3X_TPENTL,  "
cQuery += " 	V3X.R_E_C_N_O_ RECNO_V3X  "
cQuery += " FROM " + RetSqlName('V3X') + " V3X "
cQuery += " WHERE V3X.D_E_L_E_T_ = ' ' "
cQuery += "     AND V3X.V3X_FILIAL = '" + xFilial('V3X') + "' "
cQuery += " 	AND V3X.V3X_ATIVO IN (' ','1') "
cQuery += "     AND V3X.V3X_PROCID = ' ' " 
cQuery += "     AND V3X.V3X_CNPJ = '" + cCnpj + "' "
dbUseArea( .t.,'TOPCONN',TcGenQry(,,cQuery ),cAliasQry,.f.,.t.)

if (cAliasQry)->(!eof())

    //Posiciona na tabela espelho
    V82->(DbSelectArea('V82'))
    V82->(DbSetOrder(2))//V82_FILIAL+V82_CNPJ+V82_ATIVO

    //Instancia o Model
    oModel := FWLoadModel('TAFA601')

    While (cAliasQry)->(!eof())

        cTpEvento := 'I'
        lDelete   := .f.
        lInsert   := .t.
        cVerAnt   := ''
        cProtAnt  := '' 	        
        lFoundV3X := V82->(DbSeek(xFilial('V82')+(cAliasQry)->V3X_CNPJ+'1')) 
        
        oModel:DeActivate()

        cKeyLog := "Id.............: "+(cAliasQry)->V3X_ID   + CRLF
        cKeyLog += "CNPJ...........: "+(cAliasQry)->V3X_CNPJ + CRLF
                
        if lFoundV3X

            //Aguardando retorno de trasmissao ou exclusão.
            if V82->V82_STATUS $ ('26')
                lInsert := .f.
            else    
                //Se o espelho for uma inclusão e o status for 0-Registro valido ou 0-Registro invalido ou 3-Rejeitado
                if V82->V82_EVENTO == 'I' .and. V82->V82_STATUS $ (' 013') 
                    cTpEvento   := 'I'
                    lDelete     := .t.
                //Sobrepor alteração não transmitida
                elseif V82->V82_EVENTO == 'A' .and. empty(V82->V82_STATUS)
                    cVerAnt	 	:= V82->V82_VERANT 	
                    cProtAnt 	:= V82->V82_PROTPN 	
                    cTpEvento 	:= 'A'
                    lDelete 	:= .t.
                //Nova inclusão após efetivação da exclusão, é considerado como inclusão
                elseif V82->V82_EVENTO == 'E' .and. V82->V82_STATUS == '7'
                    cVerAnt	 	:= ''
                    cProtAnt 	:= ''
                    FAltRegAnt('V82','2', .f. )	//inativo anterior
                    cTpEvento	:= 'I'
                    lDelete 	:= .f.
                //Nova inclusão após exclusão sem transmissão, é considerado como alteracao
                elseif V82->V82_EVENTO == 'E' .and. empty( V82->V82_STATUS )
                    cVerAnt	 	:= V82->V82_VERANT 	
                    cProtAnt 	:= V82->V82_PROTPN 	
                    FAltRegAnt('V82','2', .f. )	//inativo anterior
                    cTpEvento	:= 'A'
                    lDelete 	:= .f.
                //Alteracao após transmissão
                elseif V82->V82_STATUS == '4' .and. ( V82->V82_EVENTO == 'I' .or. V82->V82_EVENTO == 'A' )
                    cVerAnt		:= V82->V82_VERSAO 	
                    cProtAnt 	:= V82->V82_PROTUL 	
                    FAltRegAnt('V82','2', .f. )	//inativo anterior
                    cTpEvento 	:= 'A'
                    lDelete 	:= .f.
                endif    

                if lDelete
                    oModel:SetOperation(MODEL_OPERATION_DELETE)
                    oModel:Activate()
                    FwFormCommit( oModel )
                    oModel:DeActivate()
                endif    
            endif
        endif

        if lInsert

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate()

            oModel:LoadValue('MODEL_V82', 'V82_ID'    , (cAliasQry)->V3X_ID)
            oModel:LoadValue('MODEL_V82', 'V82_TPAMB' , cAmbReinf)
            oModel:LoadValue('MODEL_V82', 'V82_CNPJ'  , (cAliasQry)->V3X_CNPJ  )
            oModel:LoadValue('MODEL_V82', 'V82_TPENTL', (cAliasQry)->V3X_TPENTL)
            oModel:LoadValue('MODEL_V82', 'V82_INIPER', (cAliasQry)->V3X_INIPER)
            oModel:LoadValue('MODEL_V82', 'V82_FINPER', (cAliasQry)->V3X_FINPER)
            oModel:LoadValue('MODEL_V82', 'V82_EVENTO', cTpEvento)
            oModel:LoadValue('MODEL_V82', 'V82_VERANT', cVerAnt)
            oModel:LoadValue('MODEL_V82', 'V82_PROTPN', cProtAnt)

            //Valida o model
            if !oModel:VldData()
                cErroVld := TafRetEMsg( oModel )
                TafXLog( cIdLog, cEvento,'ERRO', 'Mensagem do erro: ' + CRLF + cErroVld , cPeriodo)
            else
                if ( lSucesso := FwFormCommit(oModel) )
                    //Grava Log de sucesso
                    TafXLog( cIdLog, cEvento,'MSG', 'Registro Gravado com sucesso. CNPJ: ' + CRLF + V82->V82_CNPJ  ,cPeriodo)
                    
                    //Grava os campos não usados.
                    TafEndGRV( 'V82','V82_PROCID', cIdLog, V82->(Recno()) )
                    TafEndGRV( 'V3X','V3X_PROCID', cIdLog, (cAliasQry)->RECNO_V3X )
                endif    
            endif
        else
            TafXLog( cIdLog, cEvento, 'ALERTA', 'Evento transmitido e aguardando retorno:'+CRLF+ 'Chave: '+ CRLF + cKeyLog , cPeriodo)
            lInsert := .t.
        endif        

        (cAliasQry)->(DbSkip())
    enddo
endif    

(cAliasQry)->(DbCloseArea())

return lRet

