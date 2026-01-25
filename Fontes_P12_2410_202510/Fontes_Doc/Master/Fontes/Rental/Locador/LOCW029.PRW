#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} CheckListIma
Registra anexos na FH1 - OS
@type function
@version  
@author Dennis Calabrez
@since 30/06/2025
/*/

WSRESTFUL DelInsu DESCRIPTION "Deleta insumos das O.S do APP"

	WSMETHOD POST DESCRIPTION "<h2>Método responsável por deletar os insumos das O.S pelo app</h2>" WSSYNTAX "/DelInsu"

END WSRESTFUL

WSMETHOD POST WSSERVICE DelInsu   

Local aEmp          := {}
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local cRet          := ""
local nY            := 0
Local cQuery        := ""    
Local aBindParam    := {}     
Local aBindPara     := {}
Private oJson		:= Nil
Private cCustoFPA   := ""
Private cNumOs      := ""
Private nAnexos     := 0

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
    If FWJsonDeserialize(cBody,@oJson)
        aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
        If (aEmp[3] == "Empresa já existente.")
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            If Empty(cRet)
                For nY := 1 To Len(oJson:Itens)
                    //Deleta Itens da FH1
                    cQuery := "SELECT FH1.R_E_C_N_O_ RECNO FROM "+RetSqlName("FH1")+" FH1 "
                    cQuery += "WHERE FH1.D_E_L_E_T_ = ' ' AND FH1.FH1_ORDEM = ? AND FH1_CODIGO = ? AND FH1_SEQTAR = ? "

                    aadd(aBindParam,oJson:ordem)
                    aadd(aBindParam,oJson:Itens[nY]:produto)
                    aadd(aBindParam,oJson:Itens[nY]:seq)
                    MPSysOpenQuery(cQuery,"TRBFH1",,,aBindParam)
                 

                    cQuery := CHANGEQUERY(cQuery)

                    If ! TRBFH1->(EoF())
                        FH1->(DbGoTo(TRBFH1->RECNO))
                        If RecLock("FH1",.F.)
                            FH1->(DbDelete())
                            FH1->(MsUnLocK())
                        EndIf   
                    EndIf
                      
                    TRBFH1->(DbCloseArea())
                    //Deleta Itens da STL
                    cQuery := "SELECT STL.R_E_C_N_O_ RECNO FROM "+RetSqlName("STL")+" STL "
                    cQuery += "WHERE STL.D_E_L_E_T_ = ' ' AND STL.TL_ORDEM = ? AND TL_CODIGO = ? AND TL_SEQTARE = ? "

                    aadd(aBindPara,oJson:ordem)
                    aadd(aBindPara,oJson:Itens[nY]:produto)
                    aadd(aBindPara,oJson:Itens[nY]:seq)
                    MPSysOpenQuery(cQuery,"TRBSTL",,,aBindPara)
                    

                    cQuery := CHANGEQUERY(cQuery)

                    If ! TRBSTL->(EoF())
                        STL->(DbGoTo(TRBSTL->RECNO))
                        If RecLock("STL",.F.)
                            STL->(DbDelete())
                            STL->(MsUnLocK())
                        EndIf   
                    EndIf  
                    aBindParam    := {}  
                    aBindPara     := {}                                   
                Next
            EndIf
        EndIf
	EndIf

	ErrorBlock(bError)

	If Empty(cRet)
		cRet := "OK"
	EndIf                            

	//::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" ,"Insumos Exluidos": "'+oJson:ordem+'" }')) )   
    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"}')) )

Return (.T.)
