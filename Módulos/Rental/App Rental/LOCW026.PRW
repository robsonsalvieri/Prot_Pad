#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "locw026.ch"

/*/{Protheus.doc} CheckListIma
Registra as imagens nos itens do checklist
@type function
@version  
@author Frank Zwarg Fuga
@since 6/12/2025
/*/

WSRESTFUL CheckListIma DESCRIPTION STR0001 //"Registra as imagens nos itens do Check-List"

	WSMETHOD POST DESCRIPTION STR0002 WSSYNTAX STR0003 //"<h2>Método responsável por registrar as imagens nos itens do check-list pelo app</h2>"###"/CheckListIma"

END WSRESTFUL

WSMETHOD POST WSSERVICE CheckListIma   

Local aEmp          := {}
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local cRet          := ""
Local cKeyArq       := ""
Local cTemp         := "" // Frank em 28/04/25 ISSUE 6573
Local cCodChe       := ""
Local cCodTop       := ""
Local cCodIte       := ""
Local cObs          := ""
Local cChave        := ""
Local cJason        := ""
Local cTextoAtual   := "" 
Local cTextoNovo    := ""
    
Private oJson		:= Nil
Private cCustoFPA   := ""
Private cNumOs      := ""
Private nAnexos     := 0

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
    
    If FWJsonDeserialize(cBody,@oJson)
        aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
        If at("existente",aEmp[3]) > 0
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            If Empty(cRet)

                // Troca do campo sobre status da FPX
                If FindFunction( "LOCW002A" ) .and. FPX->(FIELDPOS("FPX_OBS")) > 0
                    LOCW002A()
                EndIf

                If Empty(oJson:CodCheck)
                    cRet := STR0004 //"ERRO-Faltou informar o código do check-list."
                Else
                    cCodChe := oJson:CodCheck
                EndIf
                If Empty(oJson:CodTop)
                    cRet := STR0005 //"ERRO-Faltou informar o código do tópico."
                Else
                    cCodTop := oJson:CodTop
                EndIf
                If Empty(oJson:CodIte)
                    cRet := STR0006 //"ERRO-Faltou informar o item."
                Else
                    cCodIte := oJson:CodIte
                EndIf
                If !Empty(oJson:Observa)
                    cObs := oJson:Observa
                EndIf
                If Empty(oJson:ChecklistImg)
                    cRet := STR0007 //"ERRO-Faltou informar o arquivo 64 da imagem."
                EndIf

                If empty(cRet)
                    FPX->(dbSetOrder(1))
                    If FPX->(dbSeek(xFilial("FPX")+cCodChe+cCodTop+cCodIte))
                        cTextoAtual := FPX->FPX_OBS
                        cTemp   := time()
                        cKeyArq := alltrim(cCodChe)+"-"+alltrim(cCodIte)+substr(cTemp,1,2)+substr(cTemp,4,2)+substr(cTemp,7,2)+".jpg"
                        FPX->(dbSetOrder(1))
                        cChave  := FPX->(FPX_FILIAL+FPX_CODCHE+FPX_CODTOP+FPX_CODITE+FPX_STATUS)
                        cRet    := xGAppArq(cKeyArq,oJson:ChecklistImg)
                        If Empty(cRet)
                            cRet := xGAppConhec(cKeyArq, cChave)
                            If empty(cRet)
                                cJason := LOCA091C(cKeyArq, cCodChe, cCodIte, cCodTop, cObs)
                                cTextoNovo := cTextoAtual + cJason
                                If FPX->(FIELDPOS("FPX_OBS")) > 0
                                    FPX->(RecLock("FPX",.F.))
                                    FPX->FPX_OBS := cTextoNovo + CHR(13)+CHR(10) //cJason
                                    FPX->(MsuNLOCK())
                                EndIf
                            EndIf
                        EndIf
                    Else
                        cRet := STR0008+cCodChe+STR0009 //"ERRO-O registro do Check-list: "###" não foi localizado."
                    EndIf
                EndIf
                
            EndIf
        EndIf

	EndIf

	ErrorBlock(bError)
	If !Empty(cEnvLog)
		cRet := STR0010+cEnvLog //"ERRO-"
	EndIf

	If Empty(cRet)
		cRet := "OK"
	EndIf                            
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" ,"CodCheck": "'+oJson:CodCheck+'" }')) )

Return (.T.)



/*/{Protheus.doc} PDFemB64
Transforma o arquivo em base 64
@type function
@version  
@author Frank Zwarg Fuga
@since 6/12/2025
/*/
Static Function PDFemB64(bodyHtml)
Local alHeader      := {}
Local olRest        := Nil
Local nlStatus      := 0
Local clMsg         := ""
Local llRet         := .F.
Local clURL         := "https://54.233.82.163/api/index.php"
    
    //Cabeçalho de requisição
    //aAdd(alHeader,"Accept-Encoding: UTF-8")
    aAdd(alHeader,"Content-Type: base64")

    olRest := FWRest():New(clURL)

    //Endpoint
    olRest:setPath("/index.php")

    olRest:SetPostParams(bodyHtml)

    olRest:SetChkStatus(.F.)

    If olRest:Post(alHeader)
        clMsg       := ""
        nlStatus    := HTTPGetStatus(@clMsg)
        
        //Se teve sucesso
        If nlStatus >= 200 .And. nlStatus <= 299
                llRet := .T.
                clMsg := olRest:getResult()
        endIf
    EndIf
    
Return {llRet,clMsg}

/*/{Protheus.doc} xGAppArq
Gravar local o arquivo da imagem
@type function
@version  
@author Frank Zwarg Fuga
@since 6/12/2025
/*/
Static Function xGAppArq(cNomeArq,cBase64)
Local cRet      := ""
Local nHandle   := 0
Local cComando  := ""
Local cTexto    := ""
Local cdirDoc   := MPDocPath( MsMultDir() )

    If empty(cRet)

        If File(cDirDocs + "\" + cNomeArq)
            FERASE(cDirDocs + "\" + cNomeArq)
        EndIf

        //Cria arquivo na system
        //nHandle := fcreate(cNomeArq)
        cComando := "nHandle := fcreate(cNomeArq)"
        &(cComando)

        cTexto := Encode64(cBase64)
        FWrite(nHandle, Decode64(cBase64))
        fclose(nHandle)
           
        If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
            cDirDoc := cDirDoc + "\"
        EndIf

        cComando := '__CopyFile(cNomeArq, cDirDoc + cNomeArq)'
        &(cComando)
        FERASE(cNomeArq)

        If !file(cDirDoc + cNomeArq) .or. file("\SYSTEM\LW0262.TXT")
            cRet := STR0011+cDirDoc + cNomeArq //"ERRO: O arquivo não foi gerado, verifique o diretório destino. "
        EndIf

    EndIf

Return (cRet)

/*/{Protheus.doc} xGAppConhec
Gerar o registro no banco de conhecimento
@type function
@version  
@author Frank Zwarg Fuga
@since 6/12/2025
/*/
Static Function xGAppConhec(cNomeArq, cChave)
Local cCodObj  := ""
Local lExists  := .F.
Local cRet     := ""
Local cdirDoc  := MPDocPath( MsMultDir() )
      
    If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
        cDirDoc := cDirDoc + "\"
    EndIf
   
    ACB->(DbSetOrder(2))
    
    //Se não tiver o arquivo na ACB, irá incluir
    If ACB->(DbSeek(FWxFilial('ACB') + cNomeArq)) .or. file("\SYSTEM\LW0261.TXT")
        lExists     := .T.
        cCodObj     := ACB->ACB_CODOBJ

    Else
        
        cCodObj := GetSxeNum("ACB","ACB_CODOBJ")
        
        If Reclock("ACB", .T.)
            ACB->ACB_FILIAL := FWxFilial('ACB')
            ACB->ACB_CODOBJ := cCodObj
            ACB->ACB_OBJETO := cNomeArq
            ACB->ACB_DESCRI := cChave
            If MsMultDir() .or. file("\SYSTEM\LW0263.TXT")
		        ACB->ACB_PATH := cDirDocs
	        Endif
            ACB->(MsUnlock())
        EndIf

    EndIf

    //Se não existir na tabela de vinculos, irá criar

    DbSelectArea("AC9")
    AC9->(DbGoTop())
    AC9->(DbSetOrder(1))
    If !AC9->(DbSeek(FWxFilial('AC9') + cCodObj + "FPX" +FWxFilial("FPX")+ cChave))
        If AC9->(Reclock("AC9", .T.))
            AC9->AC9_FILIAL := FWxFilial('AC9')
            AC9->AC9_FILENT	:= FWxFilial('FPX')
            AC9->AC9_ENTIDA := 'FPX'
            AC9->AC9_CODENT := cChave
            AC9->AC9_CODOBJ := cCodObj
            AC9->(MsUnlock())

        EndIf
    EndIf

    If !lExists
        If Empty(cRet)
            ConfirmSx8()
        EndIf
    EndIf
Return ("")

