#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW031GERNFS
Gera as notas ficais de saída
@type API
@version V1 
@author Frank Zwarg Fuga
@since 09/10/2025
/*/
WSRESTFUL LOCW031GERNFS DESCRIPTION "Geração das notas fiscais de saída"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para geração das notas fiscais de saida</h2>" WSSYNTAX "/LOCW031GERNFS"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW031GERNFS
ITUP BUSINESS - TOTVS RENTAL
Geração das notas ficais de saía
@type API
@version V1 
@author Frank Zwarg Fuga
@since 03/10/2025
/*/
WSMETHOD POST WSSERVICE LOCW031GERNFS
Local bError := {||}
Local cBody	:= DecodeUtf8(::GetContent())
Local cRet := ""
Local cEnvLog := ""
Local aEmp := {}
Local cQuery := ""
Local cResult := ""
Local aBindParam := {}
Local aPedidos := {}
Local aPvlNFS := {}
Local aTabAux := {}
Local nX
Local oTemp
Local cSerie := ""

Private oJson		:= Nil

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
                cRet := xAbreEnv(aEmp[1],aEmp[2])
                If Empty(cRet)

                    aPedidos := oJson:pedidos
                    cSerie := oJson:serie

                    PERGUNTE("MT460A",.F.)

	                aPvlNFS := {}

                    SC5->( DBSETORDER(1) )
                    SC6->( DBSETORDER(1) )
                    SC9->( DBSETORDER(1) )

                    LOCACLOSE("TRBNFS")

                    cQuery := "SELECT C9_PEDIDO PEDIDO, C9_ITEM ITEM, C9_SEQUEN SEQUEN, "
                    cQuery += "C9_QTDLIB QUANT, C9_PRCVEN VALOR, C9_PRODUTO PRODUTO, "
                    cQuery += "SC9.R_E_C_N_O_ SC9RECNO, SC5.R_E_C_N_O_ SC5RECNO, "
                    cQuery += "SC6.R_E_C_N_O_ SC6RECNO, SE4.R_E_C_N_O_ SE4RECNO, "
                    cQuery += "SB1.R_E_C_N_O_ SB1RECNO, SB2.R_E_C_N_O_ SB2RECNO, "
                    cQuery += "SF4.R_E_C_N_O_ SF4RECNO "
                    cQuery += "FROM " + RetSqlName("SC9") + " SC9 "
                    cQuery += "INNER JOIN " + RetSqlName("SC6") + " SC6 ON C6_FILIAL = '"+xFilial("SC6")+"' "
                    cQuery += "AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM "
                    cQuery += "AND C6_PRODUTO = C9_PRODUTO AND C6_BLQ NOT IN ('R','S') "
                    cQuery += "AND SC6.D_E_L_E_T_ = ' ' "
                    cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = '"+xFilial("SC5")+"' "
                    cQuery += "AND C5_NUM = C6_NUM AND SC5.D_E_L_E_T_ = ' ' "
                    cQuery += "INNER JOIN " + RetSqlName("SE4") + " SE4 ON  E4_FILIAL = '"+xFilial("SE4")+"' "
                    cQuery += "AND E4_CODIGO  = C5_CONDPAG AND SE4.D_E_L_E_T_ = ' ' "
                    cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON  B1_FILIAL = '"+xFilial("SB1")+"' "
                    cQuery += "AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
                    cQuery += "INNER JOIN " + RetSqlName("SB2") + " SB2 ON  B2_FILIAL = '"+xFilial("SB2")+"' "
                    cQuery += "AND B2_COD = C6_PRODUTO AND B2_LOCAL = C6_LOCAL "
                    cQuery += "AND SB2.D_E_L_E_T_ = ' ' "
                    cQuery += "INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '"+xFilial("SF4")+"' "
                    cQuery += "AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ = ' ' "
                    cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
                    cQuery += "AND ( "
                    For nX := 1 to len(aPedidos)
                        oTemp := aPedidos[nX]
                        If nX > 1
                            cQuery += " OR "
                        EndIf
                        cQuery += "(C9_PEDIDO = ? AND C9_ITEM = ?)"
                        aadd(aBindParam, oTemp:pedido)
                        aadd(aBindParam, oTemp:item)
                    Next
                    cQuery += ") "
                    cQuery += "AND C9_NFISCAL = ' ' "
                    cQuery += "AND SC9.D_E_L_E_T_ = ' ' "
                    cQuery += "ORDER BY PEDIDO, ITEM, SEQUEN, PRODUTO "
                    cQuery := CHANGEQUERY(cQuery)
                    MPSysOpenQuery(cQuery,"TRBNFS",,,aBindParam)

                    If TRBNFS->(Eof())
                        cRet := "Falha na localização dos pedidos. "
                        cResult += ', "Não foram encontros pedidos válidos para a geração da nota"'
                    EndIf

                    WHILE TRBNFS->(!EOF())
                        aTabAux := {}

                        aadd(aTabAux, TRBNFS->PEDIDO   )
                        aadd(aTabAux, TRBNFS->ITEM     )
                        aadd(aTabAux, TRBNFS->SEQUEN   )
                        aadd(aTabAux, TRBNFS->QUANT    )
                        aadd(aTabAux, TRBNFS->VALOR    )
                        aadd(aTabAux, TRBNFS->PRODUTO  )
                        aadd(aTabAux, .F.              )
                        aadd(aTabAux, TRBNFS->SC9RECNO )
                        aadd(aTabAux, TRBNFS->SC5RECNO )
                        aadd(aTabAux, TRBNFS->SC6RECNO )
                        aadd(aTabAux, TRBNFS->SE4RECNO )
                        aadd(aTabAux, TRBNFS->SB1RECNO )
                        aadd(aTabAux, TRBNFS->SB2RECNO )
                        aadd(aTabAux, TRBNFS->SF4RECNO )

                        aadd( APVLNFS , ACLONE(aTabAux) )

                        TRBNFS->(dbSkip())
                    EndDo

                    LOCACLOSE("TRBNFS")

                    dbSelectArea("SC9")

                    If len(aTabAux) > 0

                        If empty(cSerie)
                            cSerie := supergetmv("MV_LOCX024",,"")
                        EndIF

                        cNota := MAPVLNFS(aPVLNFS, cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.)
                        PUTGLBVALUE("CNF_PAR" , cNota)
                        If !empty(cNota)
                            cResult += ', "nota": {'
                            cResult += ' "nfs": "'+cNota+'",'
                            cResult += ' "serie": "'+cSerie+'"'
                            cResult += ' }'
                        else
                            cRet := "As regras de negócio do faturamento bloquearam a geração desta nota fiscal de saída. "
                        EndIf
                    EndIf
                   
                EndIf
            endif

		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "OK "
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cResult+'}')) )
	
Return .T.

