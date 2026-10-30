#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_LOJA.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_LOJA 
Função para compatibilização do release incremental. 
Esta função é relativa ao módulo Controle de Lojas (SIGALOJA). 

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA  

@Author Edilson Cruz
@since 19/10/2015
@version P12
*/
//-------------------------------------------------------------------
Function RUP_LOJA(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

    Local lRetorno := .T.

    if cMode == "1"

        //Retirada de gatilhos da SL2 para integração
        lRetorno := loj1_4114()

        //Ajuste no modo de compartilhamento da tabela MIN para totalmente compartilhado
        lRetorno := loj1_10872()
    endIf

Return lRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} loj1_4114 
Função necessária para a issue DVARLOJ1-4114.
Retirada de gatilhos da SL2.

@since  04/11/2019
*/
//-------------------------------------------------------------------
Static Function loj1_4114()

    Local aArea 	:= {}
    Local aAreaSX3  := {}
    Local aAreaSX7  := {}
    Local cTabela   := "SL2"
    Local cCampo    := ""

    aArea    := GetArea()
    aAreaSX3 := SX3->( GetArea() )
    aAreaSX7 := SX7->( GetArea() )

    SX3->( DbSetOrder(1) )
    SX3->( DbSeek(cTabela) )
    While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cTabela

        If SX3->X3_TRIGGER == "S"

            Begin Transaction

                cCampo := SX3->X3_CAMPO

                SX7->( DbSetOrder(1) )
                SX7->( DbSeek(cCampo) )
                While !SX7->( Eof() ) .And. SX7->( DbSeek(cCampo) )
                    RecLock("SX7", .F.)
                        SX7->( DbDelete() )
                    SX7->( MsUnlock() )

                    SX7->( DbSkip() )
                EndDo
                
                RecLock("SX3", .F.)
                    SX3->X3_TRIGGER := ""
                SX3->( MsUnlock() )

            End Transaction

        EndIf

        SX3->( DbSkip() )
    EndDo

    RestArea(aAreaSX7)
    RestArea(aAreaSX3)
    RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} loj1_10872
Função responsável por ajustar o modo de compartilhamento da tabela MIN, para totalmente compartilhado.
https://jiraproducao.totvs.com.br/browse/DVARLOJ1-10872

@since 	 05/06/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function loj1_10872()

    Local lRetorno  := .T.
    Local aArea     := getArea()
    Local aAreaSX2  := SX2->( getArea() )
    Local cTabela   := "MIN"
    Local cAlias    := ""
    Local cSql      := ""

    if fwAliasInDic(cTabela)

        SX2->( dbSetOrder(1) )      //X2_CHAVE
        if SX2->( dbSeek(cTabela) ) .and. ( SX2->X2_MODO == "E" .or. SX2->X2_MODOUN == "E" .or. SX2->X2_MODOEMP == "E" )

            recLock("SX2", .F.)
                SX2->X2_MODO    := "C"
                SX2->X2_MODOUN	:= "C"
                SX2->X2_MODOEMP := "C"
            SX2->( msUnLock() )
        endIf

        //Verifica se tem processos duplicados
        cAlias  := GetNextAlias()
        cSql := " SELECT COUNT(1), MIN_CPROCE, MIN_FILPUB"
        cSql += " FROM " + retSqlName(cTabela)
        cSql += " WHERE D_E_L_E_T_ = ' '"
        cSql += " GROUP BY MIN_CPROCE, MIN_FILPUB"
        cSql += " HAVING COUNT(1) > 1"

        dbUseArea(.T., "TOPCONN", TcGenQry( , , cSql), cAlias, .T., .F.)

        //Deleta processos duplicados
        while !(cAlias)->( Eof() )

            cSql := "DELETE FROM " + retSqlName(cTabela) + " WHERE D_E_L_E_T_ = ' ' AND MIN_CPROCE = '" + (cAlias)->MIN_CPROCE + "' AND MIN_FILPUB = '" + (cAlias)->MIN_FILPUB + "'"

            lRetorno := tcSqlExec(cSql) >= 0
            IIF( lRetorno, Nil, ljxjMsgErr("Não foi possível executar DELETE: " + tcSqlError(), /*cSolucao*/, /*cRotina*/, /*xVar*/) )

            (cAlias)->( dbSkip() )
        endDo
        (cAlias)->( dbCloseArea() )

        //Atualiza filial dos registros para compartilhada
        if lRetorno
            cSql := "UPDATE " + retSqlName(cTabela) + " SET MIN_FILIAL = '" + space( tamSX3("MIN_FILIAL")[1] ) + "' WHERE D_E_L_E_T_ = ' '"

            lRetorno := tcSqlExec(cSql) >= 0
            IIF( lRetorno, Nil, ljxjMsgErr("Não foi possível executar UPDATE: " + tcSqlError(), /*cSolucao*, /*cRotina*/, /*xVar*/) )
        endIf
    endIf

    restArea(aAreaSX2)
    restArea(aArea)

Return lRetorno