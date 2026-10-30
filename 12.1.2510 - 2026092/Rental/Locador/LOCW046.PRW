#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW046.PRW
ITUP BUSINESS - TOTVS RENTAL
Relatorio via API - Emissão Pedido de Compras
@TYPE FUNCTION
@AUTHOR DENNIS CALABREZ
@SINCE 29/12/2025
/*/

WSRESTFUL LOCW046 DESCRIPTION "Metodo para gerar o relatorio de Pedido de Compas - Rental"
	
	WSMETHOD POST DESCRIPTION "<h2>Metodo para gerar o relatorio de Pedido de Compas - Rental.</h2>" WSSYNTAX "/LOCW046"

END WSRESTFUL


/*/{PROTHEUS.DOC} LOCW046
ITUP BUSINESS - TOTVS RENTAL
Relatorio via API
@TYPE FUNCTION
@AUTHOR DENNIS CALABREZ
@SINCE 29/12/2025
/*/

WSMETHOD POST WSSERVICE LOCW046
Local bError := {||}
Local cEnvLog := ""
Local cRet := ""
Local cBody := DecodeUtf8(::GetContent())
Local aEmp := {}
Local cPedido
local lExist := EXISTBLOCK("LOCW046R") //Ponto de entrada para chamr relatórios customizados

Private oJson := Nil
Private cBase64 := ""

	::SetContentType("application/json; charset=iso-8859-1")

	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv1(aEmp[1],aEmp[2])

			Else
				cRet := "ERRO - nao foi possivel identificar a empresa"
			Endif
		EndIf
	End Sequence

	If Empty(cRet)

        cPedido := alltrim(oJson:pedido)
		cDireto := "\spool\"

        SC7->(dbSetOrder(1))
        If SC7->(dbSeek(xFilial("SC7")+cPedido))
            If lExist
                EXECBLOCK("LOCW046R" , .T., .T.,{cPedido} )
                cRet := LOCW046A(cDireto,cPedido)
            Else  
                cRet := "Funcao nao encontrada."  
            EndIf                
        else
            cRet := "Pedido de Compras nao existe ou invalido."
        EndIf            

		If empty(cRet)
			cRet := "OK - Relatorio gerado com sucesso."
		EndIf
		
		If file(cDireto+cPedido+".pdf") 
			fErase(cDireto+cPedido+".pdf")
		EndIf
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "impressao":"'+cBase64+'"}')))
	
	
Return .T.

/*/{Protheus.doc} LOCW046A
Rotina para converter em base64
@type function
@author DENNIS CALABREZ
@since 16/12/2025
/*/
Function LOCW046A(cCaminho,cArquivo)
Local cConteudo := ""
Local nHandle   := 0
Local nTamArq   := 0
Local cRet      := ""
Local cComando  :=  ""
    
    // Abre o arquivo para leitura
    cComando := "nHandle := FOpen(cCaminho+cArquivo+'.pdf', 0)" // 0 = Somente leitura
    &(cComando)

    If nHandle == -1 .or. file("\SYSTEM\LOCW048E2.TXT")
        cRet := "Erro ao abrir o arquivo"
    EndIf

	If empty(cRet)
    
		// Obtém o tamanho do arquivo
		nTamArq := FSeek(nHandle, 0, 2) // Move para o final
		FSeek(nHandle, 0, 0)            // Volta para o início
		
		// Lê o conteúdo do arquivo
		FRead(nHandle, @cConteudo, nTamArq)
		
		// Fecha o arquivo
		FClose(nHandle)
		
		// Converte para Base64
		If !Empty(cConteudo)
			cBase64 := Encode64(cConteudo)
		EndIf

	EndIf
    
Return cRet


 
