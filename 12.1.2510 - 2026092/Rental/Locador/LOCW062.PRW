#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} CheckListIma
Banco de Conhecimento da OS O.S(STJ)
@type function
@version  
@author Dennis Calabrez
@since 30/06/2025
/*/

WSRESTFUL LOCW062 DESCRIPTION "Banco de Conhecimento da OS O.S(STJ) - Rental"

	WSMETHOD POST DESCRIPTION "<h2>Método responsável por registrar Banco de Conhecimento da OS O.S(STJ) - Rental</h2>" WSSYNTAX "/LOCW062"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW061
ITUP BUSINESS - TOTVS RENTAL
Método para Banco de Conhecimento da OS O.S(STJ)
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSMETHOD POST WSSERVICE LOCW062   
Local aEmp          := {}
Local cBody			:= DecodeUtf8(::GetContent())
Local cRet          := ""
Local cMsg          := ""
Local cKeyArq       := ""
Local cTemp         := "" 
local nY            := 0
Local aArq          := ""
Local cTipoArq      := ""
Local cQuery        := "" 
Local aBindParam    := {}
Local cAut          := ""
Local cFonte        := "LOCW062.PRW"
Local aInfo         := GetAPOInfo(cFonte)
Private oJson		:= Nil

	::SetContentType("application/json; charset=iso-8859-1")
    
    If FWJsonDeserialize(cBody,@oJson)
        aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
        If (aEmp[3] == "Empresa já existente.")
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            If Empty(cRet)
                For nY := 1 To Len(oJson:Anexos)
                    aArq        := STRTOKARR(oJson:Anexos[nY]:name,".")
                    cTipoArq    := Lower(aArq[Len(aArq)])                

                    cQuery := "SELECT * FROM "+RetSqlName("STJ")+" STJ "
                    cQuery += "WHERE STJ.D_E_L_E_T_ = '' AND STJ.TJ_ORDEM = ? "
                    cQuery += " AND STJ.TJ_FILIAL = '"+xFilial("STJ")+"' "

                    aadd(aBindParam,oJson:ordem)

                    MPSysOpenQuery(cQuery,"TRBSTJ",,,aBindParam)
                    cQuery := CHANGEQUERY(cQuery) 
                    If !TRBSTJ->(EoF())                 
                        cTemp   := time()  
                        cKeyArq := alltrim(oJson:ordem)+"0001"+substr(cTemp,1,2)+substr(cTemp,4,2)+substr(cTemp,7,2)+"."+cTipoArq
                        cChave  := TRBSTJ->TJ_ORDEM
                        cRet    := LOCW062A(cKeyArq,oJson:Anexos[nY]:Img)
                        If Empty(cRet)
                            cRet := LOCW062B(cKeyArq, cChave)
                        EndIf
                    Else
                        cRet := "400 - "
                        cMsg := "Ordem de Servico inexistente"                        
                    EndIf
                Next
            EndIf
        EndIf
	EndIf

	If Empty(cRet)
        cRet := "200 - "
        cMsg := "Anexos registrados na Ordem de Servico "
	EndIf                            

    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+""+',"compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )

Return (.T.)

/*/{Protheus.doc} LOCW062A
Gravar local o arquivo dos anexos
@type function
@version  
@author Dennis Calabrez
@since 26/06/2025
/*/
Static Function LOCW062A(cNomeArq,cBase64)
Local cRet      := ""
Local nHandle   := 0
Local cComando  := ""
Local cTexto    := ""
Local cdirDoc   := MPDocPath( MsMultDir() )

    If empty(cRet)
    
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

/*/{Protheus.doc} LOCW062B
Gerar o registro no banco de conhecimento
@type function
@version  
@author Dennis Calabrez
@since 26/06/2025
/*/
Static Function LOCW062B(cNomeArq, cChave)
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
            AC9->AC9_ENTIDA := 'STJ'
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

