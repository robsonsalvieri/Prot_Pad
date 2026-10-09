#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW045.PRW
ITUP BUSINESS - TOTVS RENTAL
Relatorio LOCR003 via API
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 12/12/2025
/*/

WSRESTFUL LOCW045 DESCRIPTION "Metodo para gerar o relatorio demonstrativo de faturamento - Rental"
	
	WSMETHOD POST DESCRIPTION "<h2>Metodo para gerar o relatorio demonstrativo de faturamento - Rental.</h2>" WSSYNTAX "/locw045"

END WSRESTFUL


/*/{PROTHEUS.DOC} LOCW045r
ITUP BUSINESS - TOTVS RENTAL
Relatorio LOCR003 via API
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 12/12/2025
/*/

WSMETHOD POST WSSERVICE LOCW045
Local bError := {||}
Local cEnvLog := ""
Local cRet := ""
Local cBody := DecodeUtf8(::GetContent())
Local aEmp := {}
Local cLocal 
Local cNota
Local cSerie
Local cFil
Local cArquivo

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

        cNota    := alltrim(oJson:nota)
        cSerie   := alltrim(oJson:serie)
        cFil     := xFilial("SF2")
        cArquivo := alltrim(oJson:arquivo)+".pdf"
		cDireto  := "\relato\"

        LOCR003(.T., cNota, cSerie, cFil, cArquivo, cDireto)
        
        If file(cDireto+cArquivo) .and. !file("\SYSTEM\LOCW048E1.TXT")

			cRet := LOCW045A(cDireto,cArquivo)

		    If empty(cRet)
				cRet := "OK - Relatorio gerado com sucesso."
			EndIf
		
			fErase(cLocal+cArquivo)
        
		Else
            cRet := "ERRO - nao foi possivel gerar o relatorio."
        EndIf

	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "impressao":"'+cBase64+'"}')))
	
	
Return .T.

/*/{Protheus.doc} LOCW045A
Rotina para converter em base64
@type function
@author Frank Zwarg Fuga
@since 16/12/2025
/*/
Function LOCW045A(cCaminho,cArquivo)
Local cConteudo := ""
Local nHandle := 0
Local nTamArq := 0
Local cRet := ""
    
    // Abre o arquivo para leitura
    nHandle := FOpen(cCaminho+cArquivo, 0) // 0 = Somente leitura
    
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


 
