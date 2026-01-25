#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI89.CH"

/*{Protheus.doc} TMSAI89()
Funcao de Job Envio Status Fatura Vencida
Para o Portal Logistico
@author     Rafael Souza
@since      22/06/2022
*/
Function TMSAI89()
    FWMsgrun(,{|| TMSAI89AUX()}, STR0003, STR0004 )
RETURN

/*{Protheus.doc} TMSAI89AUX()
Funcao auxiliar do Job Envio Status Fatura Vencida
@author     Rafael Souza
@since      02/01/2023
*/
Function TMSAI89AUX()
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cIdExtFat := ""
Local cAlias    := ""
Local oColEnt As Object

   
    //Portal Logistico
    If AliasInDic("DND")
        cAlias := "DND"
    EndIf

    If LockByName("TM89JbLoop",.T.,.T.)
        If !Empty(cAlias)  
            oColEnt := TMSBCACOLENT():New(cAlias)
            If oColEnt:DbGetToken() 
                (oColEnt:Alias_Config)->(DbGoTo(oColEnt:config_recno))
               
                cQuery := "SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCREA, SE1.E1_STATUS "
                cQuery += "FROM "+RetSQLName("SE1") + " SE1 "
                cQuery += "WHERE "
                cQuery += "SE1.E1_FILIAL   = '"+xFilial("SE1")+"'  AND "
                cQuery += "SE1.E1_VENCREA < '"+Dtos(dDatabase)+"' AND "
                cQuery += "SE1.E1_STATUS = 'A' AND "
                cQuery += "SE1.E1_ORIGEM IN ( 'TMSA491', 'TMSA850') AND "
                cQuery += "SE1.D_E_L_E_T_ = '' "

                cQuery := ChangeQuery(cQuery)
                DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

                Do While !(cAliasQry)->(Eof())
                                       
                    cIdExtFat := TmsIdExFat((cAliasQry)->E1_FILIAL, (cAliasQry)->E1_PREFIXO, (cAliasQry)->E1_NUM, (cAliasQry)->E1_PARCELA, (cAliasQry)->E1_TIPO)
                    If !Empty(cIdExtFat)
                        TMC30FtVen(cIdExtFat)  
                    EndIf 

                    (cAliasQry)->(DbSkip())
                EndDo
                (cAliasQry)->(DbCloseArea())
            EndIf
            FWFreeObj(oColEnt)
        EndIf 
        UnLockByName("TM89JbLoop")
    EndIf
    FWFreeObj(oColEnt)
Return

/*{Protheus.doc} Scheddef()
@Função Função de parâmetros do Scheduler
@author Carlos Alberto Gomes Junior
@since 25/07/2022
*/
Static Function SchedDef()
Local aParam := { "P",;       //Tipo R para relatorio P para processo
                  "",;        //Pergunte do relatorio, caso nao use passar ParamDef
                  "DN5",;     //Alias
                  ,;          //Array de ordens
                  STR0001 }   //Descrição do Schedule - "Envio Status Vencimento Fatura"
Return aParam

