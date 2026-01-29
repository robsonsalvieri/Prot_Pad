#include 'protheus.ch'
#include 'totvs.ch'
#include 'tbiconn.ch'

#DEFINE SOLICITACAO_RECEITA_SERVICE agd.solicitacaoReceitaService.agdSolicitacaoReceitaService

/*/{Protheus.doc} AGDJ010
Schedule para envio automático de solicitações de receita
Processa solicitações com status "Aguardando Envio" criadas há mais de 5 minutos
@type function
@version 12
@author beatriz.dantas
@since 11/12/2025
@return logical, .T. sempre
/*/
Function AGDJ010()
    Local cAlias       := GetNextAlias()
    Local cQuery       := ""
    Local dDataLimite  := Date()
    Local cHoraLimite  := ""
    Local oStmt        As Object
    
    Local nTotalMin := (Val(SubStr(Time(),1,2)) * 60) + Val(SubStr(Time(),4,2))

    nTotalMin -= 5 

    If nTotalMin < 0
        nTotalMin += (24 * 60)
        dDataLimite := DaySub(dDataLimite, 1)
    EndIf

    cHoraLimite := StrZero(Int(nTotalMin / 60), 2) + ":" + ;
                StrZero(nTotalMin % 60, 2) + ":" + ;
                SubStr(Time(), 7, 2) // Mantém os segundos atuais
    
    cQuery := " SELECT NET_CODIGO, NET_FILIAL, NET_DTEMIS, NET_HREMIS "
    cQuery += " FROM " + RetSqlName("NET") + " NET "
    cQuery += " WHERE NET.NET_FILIAL = ? "
    cQuery += "   AND NET.D_E_L_E_T_ = ' ' "
    cQuery += "   AND NET.NET_STSSOL = ? " 
    cQuery += "   AND ( "
    cQuery += "       ( NET.NET_DTEMIS < ? ) "
    cQuery += "       OR "
    cQuery += "       ( NET.NET_DTEMIS = ? AND NET.NET_HREMIS <= ? ) "
    cQuery += "   ) "
    cQuery += " ORDER BY NET.NET_DTEMIS, NET.NET_HREMIS "
    
    cQuery := ChangeQuery(cQuery)

    oStmt := FWPreparedStatement():New()
    oStmt:SetQuery(cQuery)
    oStmt:SetString(1,FWxFilial('NET'))
	oStmt:SetString(2, '3') // Status "Aguardando Envio"'
    oStmt:SetDate(3, dDataLimite)
    oStmt:SetDate(4, dDataLimite)
    oStmt:SetString(5, cHoraLimite)
    cQuery := oStmt:GetFixQuery()
    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
    
    If (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
        Return Nil
    EndIf
        
    oSolicitacaoReceitaService := SOLICITACAO_RECEITA_SERVICE():New()
    
    While (cAlias)->(!Eof())
   
        oSolicitacaoReceitaService:confirmarSolicitacao(AllTrim((cAlias)->NET_CODIGO))

        (cAlias)->(DbSkip())
    EndDo
    
    (cAlias)->(DbCloseArea())

    FwFreeObj(oSolicitacaoReceitaService)    
    
Return Nil

/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.
@author Totvs S/A
@return aReturn			Array com os parametros
/*/
Static Function SchedDef()

    Local aOrd   := {}
    Local aParam := {}

    aParam := { "P",        ;       //Tipo R para relatorio P para processo
                "ParamDef", ;       //Nome do pergunte do relatorio, caso nao use passar ParamDef
                "",         ;       // Alias
                aOrd,       ;       //Array de ordens
            }                       //Titulo

Return aParam
