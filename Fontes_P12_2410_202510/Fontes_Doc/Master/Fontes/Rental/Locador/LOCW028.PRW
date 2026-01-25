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

WSRESTFUL AnxOs DESCRIPTION "Registra os anexos nas O.S do APP"

	WSMETHOD POST DESCRIPTION "<h2>Método responsável por registrar anexos do nas O.S pelo app</h2>" WSSYNTAX "/AnxOs"

END WSRESTFUL

WSMETHOD POST WSSERVICE AnxOs   

Local aEmp          := {}
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local cRet          := ""
Local cKeyArq       := ""
Local cTemp         := "" 
local nY            := 0
Local aArq          := ""
Local cTipoArq      := ""
Local lRet          := .T.   
Local cQuery        := "" 
Local aBindParam    := {}
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
                For nY := 1 To Len(oJson:Anexos)
                    aArq        := STRTOKARR(oJson:Anexos[nY]:name,".")
                    cTipoArq    := Lower(aArq[Len(aArq)])                
                    //FH1->(dbSetOrder(1))
                    //If FH1->(dbSeek(xFilial("FH1")+oJson:ordem+oJson:plano+oJson:tarefa+oJson:tip_re+oJson:produto+oJson:seq_rel+oJson:seq_tar))
                    cQuery := "SELECT * FROM "+RetSqlName("FH1")+" FH1 "
                    cQuery += "WHERE FH1.D_E_L_E_T_ = '' AND FH1.FH1_ORDEM = ? AND FH1.FH1_CODIGO = ? AND FH1.FH1_SEQTAR = ? "
                    cQuery += " AND FH1.FH1_FILIAL = '"+xFilial("FH1")+"' "

                    aadd(aBindParam,oJson:ordem)
                    aadd(aBindParam,oJson:produto)
                    aadd(aBindParam,oJson:seq_tar)
                    //cQuery := CHANGEQUERY(cQuery) 
                    MPSysOpenQuery(cQuery,"TRBFH1",,,aBindParam)
                    cQuery := CHANGEQUERY(cQuery) 
                    If !TRBFH1->(EoF())                 
                        cTemp   := time()  
                        //cKeyArq := alltrim(oJson:pedido)+"-"+alltrim(oJson:itpc)+substr(cTemp,1,2)+substr(cTemp,4,2)+substr(cTemp,7,2)+".jpg"
                        cKeyArq := alltrim(oJson:ordem)+"0001"+substr(cTemp,1,2)+substr(cTemp,4,2)+substr(cTemp,7,2)+"."+cTipoArq
                        //FH1->(dbSetOrder(1))
                        //cChave  := TRBFH1->FH1_FILIAL+TRBFH1->FH1_ORDEM+TRBFH1->FH1_PLANO+TRBFH1->FH1_TAREFA+TRBFH1->FH1_TIPORE+TRBFH1->FH1_CODIGO+TRBFH1->FH1_SEQREL+TRBFH1->FH1_SEQTAR
                        cChave  := TRBFH1->FH1_FILIAL+TRBFH1->FH1_ORDEM+TRBFH1->FH1_PLANO+TRBFH1->FH1_TAREFA+TRBFH1->FH1_TIPORE+TRBFH1->FH1_SEQREL+TRBFH1->FH1_SEQTAR
                        cRet    := xGAppArq(cKeyArq,oJson:Anexos[nY]:Img)
                        If Empty(cRet)
                            cRet := xGAppConhec(cKeyArq, cChave)
                        EndIf
                    Else
                        lret := .F.
                        cRet    := "Ordem de Servico inexistente"
                    EndIf
                Next
            EndIf
        EndIf
	EndIf

	ErrorBlock(bError)

	If Empty(cRet)
		cRet := "OK"
	EndIf                            
    If lRet
	    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" ,"Ordem de Servico": "'+oJson:ordem+'" }')) )
    Else    
        ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" ,"Ordem de Serviço": "rever numero de O.S." }')) )
    EndIf    
Return (.T.)

/*/{Protheus.doc} xGAppArq
Gravar local o arquivo dos anexos
@type function
@version  
@author Dennis Calabrez
@since 26/06/2025
/*/
Static Function xGAppArq(cNomeArq,cBase64)
Local cRet      := ""
Local nHandle   := 0
Local cComando  := ""
Local cTexto    := ""
Local cdirDoc   := MPDocPath( MsMultDir() )

    If empty(cRet)

        If File(cDirDoc + "\" + cNomeArq)
            FERASE(cDirDoc + "\" + cNomeArq)
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

    EndIf

Return (cRet)

/*/{Protheus.doc} xGAppConhec
Gerar o registro no banco de conhecimento
@type function
@version  
@author Dennis Calabrez
@since 26/06/2025
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
    If ACB->(DbSeek(FWxFilial('ACB') + cNomeArq))
        lExists     := .T.
        cCodObj     := ACB->ACB_CODOBJ

    Else
        
        cCodObj := GetSxeNum("ACB","ACB_CODOBJ")
        
        If Reclock("ACB", .T.)
            ACB->ACB_FILIAL := FWxFilial('ACB')
            ACB->ACB_CODOBJ := cCodObj
            ACB->ACB_OBJETO := cNomeArq
            ACB->ACB_DESCRI := cChave
            //If MsMultDir()
		    //    ACB->ACB_PATH := cDirDocs
	        //Endif
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
            AC9->AC9_ENTIDA := 'FH1'
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

