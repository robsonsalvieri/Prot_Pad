#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Retintera   ³ Autor ³ Dennis Calabrez    ³ Data ³05.02.2025³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo que retorna as Interações de usuarios               ³±±
±±³Descricao ³ para o aplicativo     								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL Retintera DESCRIPTION "Retorna que retorna as Interações de usuarios para o aplicativo"

	WSMETHOD GET DESCRIPTION "<h2> Metodo que retorna as Interações de usuarios para o aplicativo.</h2>" WSSYNTAX "/Retintera/{param1}/{param2}"

END WSRESTFUL



WSMETHOD GET WSSERVICE Retintera
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cDados		:= ""
Local nContForm     := 0
Local nContFam      := 0
Local nContSeq      := 0
Local cRet          := ""
Local cParam1       := ""
Local cParam2       := ""
Local aPar          := {}
Local cCodMul       := ""
Local lPrim         := .T.
Local lSegu         := .T.
Local lTerc         := .T.
Local lQuar         := .T.
Local cMsg          := ""
Local nI            := 0
Local aParam        := {}
Local cAut          := ""
Local cQuery
Local aBindParam    := {}

	//conout("INICIO-Consumido o WebService RetFrotasApp - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	aPar :=  GetUrlParams2(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
    cParam2 := aPar[2]

	cCodMul := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o Código da Multa
    cAut    := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
        aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
        If (aEmp[3] == "Empresa já existente.")
            cRet := xAbreEnv1(aEmp[1],aEmp[2])
            //cRet := ""
            If Empty(cRet)
                cQuery := "SELECT "
                cQuery += "TRX_MULTA AS MULTA, "
                cQuery += "COALESCE( "
                cQuery += "CONVERT(VARCHAR(8000), ( "
                cQuery += " SELECT RTRIM(SYP.YP_TEXTO) "
                cQuery += " FROM "+RetSqlName("SYP")+" SYP "
                cQuery += " WHERE SYP.YP_CHAVE = TRX.TRX_MMCOND AND SYP.YP_CAMPO = 'TRX_MMCOND' AND SYP.D_E_L_E_T_ = ' ' "
                cQuery += " ORDER BY YP_SEQ "
                cQuery += " FOR XML PATH ('') "
                cQuery += ")), "
                cQuery += " '') AS ATIVIDADE "
                cQuery += " FROM "+RetSqlName("TRX")+" TRX "
                cQuery += "WHERE TRX_MULTA = ? "
                aadd(aBindParam,cCodMul)
                cQuery += "AND TRX.D_E_L_E_T_ = ''"

                //TcQuery cQuery New Alias "TRBSPY"
                //cQuery := CHANGEQUERY(cQuery)
				MPSysOpenQuery(cQuery,"TRBSPY",,,aBindParam)

                cMsg := TRBSPY->ATIVIDADE              
                cDados += ', "interacaoes": ['			

                If TRBSPY->(!EoF()) 
                        
                    nContFam := 0
                
                    If !Empty(cMsg)
                        // Quebra os parâmetros pelo ';'
                        aParam := StrTokArr(cMsg, ";")
                    EndIf

                    For nI :=1 to len(aParam)     
                        If nContForm > 0
                            cDados += ','
                        EndIf   
                        nContForm := 0                            
                        IF lPrim
                            cDados += ' { '
                            cDados += '"mensagem no dia" : "'+STRTRAN(AllTrim(SubStr(aParam[nI], At(":", aParam[nI]) + 1)),"\13\10","")+'",'
                            lPrim := .F.
                            Loop
                        EndIf    
                        If lSegu
                            cDados += '"mensagem" : "'+STRTRAN(AllTrim(SubStr(aParam[nI], At(":", aParam[nI]) + 1)),"\13\10","")+'",'
                            lSegu := .F.
                            Loop
                        EndIf
                        If lTerc                         
                            //cDados += '"usuario": "'+AllTrim(SubStr(aParam[nI], At(":", aParam[nI]) + 1))+'"'
                            cDados += '"usuario": "'+STRTRAN(AllTrim(SubStr(aParam[nI], At(":", aParam[nI]) + 1)),"\13\10","")+'",'
                            lTerc := .F.
                            Loop
                            //cDados += ' } '
                        EndIf    
                        If lQuar                         
                            //cDados += '"usuario": "'+AllTrim(SubStr(aParam[nI], At(":", aParam[nI]) + 1))+'"'
                            cDados += '"tipo": "'+STRTRAN(AllTrim(SubStr(aParam[nI], At(":", aParam[nI]) + 1)),"\13\10","")+'"'
                            lQuar := .F.
                            cDados += ' } '
                        EndIf  
                            
                        lPrim := .T.
                        lSegu := .T.
                        lTerc := .T.
                        lQuar := .T.

                        nContForm++
                    Next
                EndIf

                cDados += "]"
            EndIf
        EndIf    
	End Sequence

	ErrorBlock(bError)
	If Empty(cRet)
		cRet 	:= "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cDados+'}')) )
	
	//conout("TERMINO-Consumido o WebService RetFormsApp - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parâmetros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 20/01/2025
/*/
Static Function GetUrlParams2(cUrl)
Local cQry  := ""
Local aParams := {}

    // Captura apenas a parte dos parâmetros após o '?'
    If At("?", cUrl) > 0
        cQry := AllTrim(SubStr(cUrl, At("?", cUrl) + 1))
    Else
        cQry := ""
    EndIf

    // Verifica se existem parâmetros
    If !Empty(cQry)
        // Quebra os parâmetros pelo '&'
        aParams := StrTokArr(cQry, "&")
    Else
        //ConOut("Nenhum parâmetro encontrado na URL.")
    EndIf

Return (aParams)
