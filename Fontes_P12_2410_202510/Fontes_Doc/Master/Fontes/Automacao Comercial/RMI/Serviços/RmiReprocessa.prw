#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static lReprocessa  := .F.
Static dDtFis       := ""
Static oJson        := Nil 
Static nRecMhp      := 0

//--------------------------------------------------------
/*/{Protheus.doc} RmiReprocessa
Função principal que executa o reprocessamento

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      22/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Function RmiReprocessa(cAssinante)

Local oError    := Nil
Local cHorario  := SubStr(Time(), 1, 5)

Private lRegraChef:= .F.
Private cHorarioIni:= "00:00"
Private cHorarioFim:= "05:55"

Default cAssinante := ""

TRY EXCEPTION

    RmiSetRepc(.T.)
    dDtFis := RmiGetDt(cAssinante)
    
    If !Empty(dDtFis) .AND. Date() > dDtFis

        If IIF(lRegraChef,cHorario >= cHorarioIni .And. cHorario <= cHorarioFim,.T.)
        
            CoNout("Iniciando o reprocessamento do dia " + DToS(dDtFis))
            LjGrvLog(" RmiReprocessa ", "Iniciando o reprocessamento do dia " + DToS(dDtFis))    

            //Inicia o reprocessamento
            RmiBusExec(cEmpAnt, cFilAnt, cAssinante, "REPROCESSA")   

            //Soma mais um na data para reprocessar o próximo dia
            dDtFis := dDtFis + 1

            //Atualiza o objeto que contém o Json de envio
            oJson["UltimodiaReprocessado"] := SubStr(FWTimeStamp(1,dDtFis),1,8)
            LjGrvLog(" RmiReprocessa ", "Objeto UltimodiaReprocessado atualizado para " + oJson["UltimodiaReprocessado"])    
        
            //Atualiza o objeto para data de hoje para controle do UltimodiaReprocessado
            oJson["DataReprocessamento"] := DtoS(Date())

            LjGrvLog(" RmiReprocessa ", "Objeto DataReprocessamento atualizado para " + oJson["DataReprocessamento"])    

            //Atualiza o registro da MHQ com a atualização do Json
            RmiAtlzMhp(oJson:ToJson(), nRecMhp)

            CoNout("Fim do reprocessamento!")
            LjGrvLog(" RmiReprocessa ", "Fim do reprocessamento")
        Else

            LjxjMsgErr("Reprocessamento da integração com o FOOD não executado, pois está fora do horário permitido: 00:00 as 06:00", /*cSolucao*/, /*cRotina*/)
        EndIf
    EndIf

    RmiSetRepc(.F.)
    FwFreeObj(oJson)

//Se ocorreu erro
CATCH EXCEPTION USING oError
    
    //Seta o reprocessamento para .F.
    RmiSetRepc(.F.)

    CoNout("Ocorreu um erro no reprocessamento - " + oError:DESCRIPTION)
    LjGrvLog(" RmiReprocessa ", "Ocorreu um erro no reprocessamento - " + oError:DESCRIPTION)

ENDTRY

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} RmiGetDt
Função que sera executada antes de chamar a função de reprocessamento,
essa função tem como objetivo retornar a data inicial do reprocessamento.

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      22/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Static Function RmiGetDt(cAssinante)

Local cQuery    := "" //Armazena a query
Local cAlias    := GetNextAlias() //Alias temporario
Local dRet      := StoD("  /  /  ") //Variavel de retorno
Local dDatFis   := SuperGetMv("MV_DATAFIS",,"")

Default cAssinante := ""

cQuery := "SELECT MHP.R_E_C_N_O_ RECMHP "
cQuery += "  FROM " + RetSqlName("MHO") + " MHO "
cQuery += "       INNER JOIN " + RetSqlName("MHP") + " MHP ON MHO_FILIAL = MHP_FILIAL "
cQuery += "	                        AND MHO_COD = MHP_CASSIN "
cQuery += "							AND MHP_ATIVO = '1' "
cQuery += "							AND MHP.D_E_L_E_T_ = ' ' "
cQuery += " WHERE MHO_FILIAL = '" + xFilial("MHO") + "'"
cQuery += "   AND MHO.D_E_L_E_T_ = ' ' "
cQuery += "   AND MHP_TIPO = '2' "
cQuery += "   AND MHO_COD = '" + cAssinante + "'"
cQuery += "   AND MHP_CPROCE = 'VENDA'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

If !(cAlias)->( Eof() )

    //Cria o objeto Json para receber o Json de envio
    oJson   := JsonObject():New()
    nRecMhp := (cAlias)->RECMHP 
    MHP->(dbGoto(nRecMhp))

    If !Empty(MHP->MHP_LAYENV)
        oJson:FromJson( AllTrim(MHP->MHP_LAYENV) )
        
        If oJson:hasProperty("DataReprocessamento") .and. Date() > StoD(oJson["DataReprocessamento"])

            If oJson["UltimodiaReprocessado"] == NIL
                oJson["UltimodiaReprocessado"] := DtoS(Date())
                LjGrvLog(" RmiGetDt ", "A propriedade UltimodiaReprocessado foi criada com a data de hoje " + oJson["UltimodiaReprocessado"])   
            EndIF
            //Caso o reprocessamento nao tenha terminado não pode retroceder ainda mais.
            If StoD(oJson["UltimodiaReprocessado"]) >= (Date() -1 )
                If oJson:hasProperty("DiasRetroceder") 
                    dRet := StoD(oJson["UltimodiaReprocessado"]) - oJson["DiasRetroceder"]
                Else
                    LjGrvLog(" RmiGetDt ", "A propriedade DiasTroceder não existe o default será 60 dias!")
                    dRet := StoD(oJson["UltimodiaReprocessado"]) - 60
                EndIF                    
            Else
                dRet := StoD(oJson["UltimodiaReprocessado"])
            EndIf
            //Se a data da tag for maior que a datafis eu reprocesso a partir do parametro
            If !Empty(dRet) 
                If dRet < dDatFis
                    dRet := dDatFis         
                    LjGrvLog(" RmiGetDt ", "A propriedade DataReprocessamento é maior que a data do parametro MV_DATAFIS, começaremos apartir do parametro: " + DtoS(dDatFis))   
                EndIf             
            EndIf
        else
            dRet := StoD(oJson["UltimodiaReprocessado"])
        EndIf

    EndIf
    If !Empty(MHP->MHP_CONFIG)
        oJsonCONFIG   := JsonObject():New()
        oJsonCONFIG:FromJson( AllTrim(MHP->MHP_CONFIG) )
        If oJsonCONFIG:hasProperty("regraChef") .AND. oJsonCONFIG:hasProperty("horaReproceInicio") .AND. oJsonCONFIG:hasProperty("horaReproceFinal") 
            lRegraChef  := oJsonCONFIG["regraChef"]
            cHorarioIni := oJsonCONFIG["horaReproceInicio"]
            cHorarioFim := oJsonCONFIG["horaReproceFinal"]
            LjGrvLog(" RmiReprocessa ", "Horario definido para reprocessamento hora Inicio " + cHorarioIni + " Hora Fim "+ cHorarioFim)
        Else
            oJsonCONFIG["regraChef"] := .T.
            oJsonCONFIG["horaReproceInicio"] := "00:00"
            oJsonCONFIG["horaReproceFinal"]  := "05:55"
            oJsonCONFIG["tempBuscaVenda"]    := "00:30:00"
            lRegraChef := .T.
            RmiAtuCfg(oJsonCONFIG:ToJson())
            LjGrvLog(" RmiReprocessa ","Criando as Tags: regraChef, horaReproceInicio, horaReproceFinal, tempBuscaVenda")
        EndIf
    EndIf    
EndIf

(cAlias)->( DbCloseArea() )
LjGrvLog(" RmiReprocessa ","Reprocessando a data - "+ DtoC(dRet))
Return dRet

//--------------------------------------------------------
/*/{Protheus.doc} RmiAtlzMhp
A cada reprocessamento, entra nessa função para atualizar o Json
de envio com a nova data de reprocessamento que é gravada no layout
de envia através da TAG DataReprocessamento

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      22/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Function RmiAtlzMhp(cJson, nRecno)

Local aArea := GetArea() //Guarda a area

Default cJson := ""

MHP->(dbGoto(nRecno))

If RecLock("MHP",.F.)
    MHP->MHP_LAYENV := cJson
    MHP->(MsUnlock())
EndIf

RestArea(aArea)

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} RmiGetRepc
Função para retornar o valor da variavel lReprocessa

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      10/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Function RmiGetRepc()
Return lReprocessa

//--------------------------------------------------------
/*/{Protheus.doc} RmiSetRepc
Função para setar valor a variavel lReprocessa

@param 		lReproc -> Conteúdo a ser atribuido a variavel lReprocessa
@author  	Varejo
@version 	1.0
@since      10/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Function RmiSetRepc(lReproc)

Default lReproc := .F.

lReprocessa := lReproc

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} RmiGetDt
Função para retornar a data a ser reprocessada

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      10/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Function RmiGetDate()
Return dDtFis


//--------------------------------------------------------
/*/{Protheus.doc} RmiMarkSale
Função responsavel em pesquisar a venda, distribuição ou
publicação, caso alguma dessas etapas esteja com erro,
então é marcado automaticamente pare realizar o reprocessamento

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      30/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Function RmiMarkSale(cUuid)

Local cQuery := "" //Armazena a query
Local cAlias := "" //Guarda o proximo alias

Default cUuid := ""

If AllTrim(MHQ->MHQ_CPROCE) == "VENDA" .AND. AllTrim(MHQ->MHQ_ORIGEM) == "CHEF"
    If AllTrim(MHQ->MHQ_STATUS) == "3"
        LjGrvLog(" RmiReprocessa ", "Encontrado erro na publicação, vai atualizar a MHQ - UUID " + cUuid)
        RmiUpdMhq()
    Else

        //Pesquisando a venda
        cAlias := GetNextAlias()

        cQuery := "SELECT R_E_C_N_O_ REC "
        cQuery += "  FROM " + RetSqlName("SL1")
        cQuery += " WHERE L1_UMOV = '" + cUuid + "'"
        cQuery += "   AND L1_SITUA IN ('IR','ER')"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

        If !(cAlias)->( Eof() )
            LjGrvLog(" RmiReprocessa ", "Encontrado erro na venda, vai atualizar a MHQ - UUID " + cUuid)
            RmiUpdMhq()
            (cAlias)->( DbCloseArea() )
            Return Nil
        Else        
            (cAlias)->( DbCloseArea() )
            cQuery := ""
        EndIf    

        //Pesquisando a distribuição
        cAlias := GetNextAlias()

        cQuery := "SELECT R_E_C_N_O_ REC "
        cQuery += "  FROM " + RetSqlName("MHR")
        cQuery += " WHERE MHR_UIDMHQ = '" + cUuid + "'"
        cQuery += "   AND MHR_STATUS = '3'"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

        If !(cAlias)->( Eof() )
            LjGrvLog(" RmiReprocessa ", "Encontrado erro na distribuição, vai atualizar a MHQ - UUID " + cUuid)
            RmiUpdMhq()
        EndIf

        (cAlias)->( DbCloseArea() )
    EndIf
EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} RmiUpdMhq
Função responsavel em atualizar o status da MHQ para 4
para realizar o reprocessamento

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      30/09/2020
@return	    Não ha
/*/
//--------------------------------------------------------
Function RmiUpdMhq()
Local aArea     := GetArea() 
Local aAreaMHQ  := MHQ->(GetArea())

If RecLock("MHQ",.F.)
    LjGrvLog(" RmiReprocessa ", "Vai atualizar a MHQ para status 4 para reprocessar - UUID " + MHQ->MHQ_UUID)
    MHQ->MHQ_STATUS := "4"
    MHQ->(MsUnlock())
EndIf
//Verifico se Origem é cancelamento existe Cancelamento troco para Status 4 a linha que foi gerado automaticamente pelo Grava()
If MHQ->MHQ_EVENTO = '2' .AND. MHQ->( DbSeek(MHQ->MHQ_FILIAL + MHQ->MHQ_ORIGEM + MHQ->MHQ_CPROCE +MHQ->MHQ_CHVUNI + '1') )
    If RecLock("MHQ",.F.)
        LjGrvLog(" RmiReprocessa ", "Vai atualizar a MHQ para status 4 para reprocessar - UUID " + MHQ->MHQ_UUID)
        MHQ->MHQ_STATUS := "4"
        MHQ->(MsUnlock())
    EndIf
EndIf

RestArea(aAreaMHQ)
RestArea(aArea)
Return Nil
