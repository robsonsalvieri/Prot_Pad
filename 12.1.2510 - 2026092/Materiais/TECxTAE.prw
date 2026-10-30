#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

// Integração entre TAE e FIELD SERVICE - CONSUMO DA CLASSE DE INTEGRAÇÃO
// pdfFile 
Function integraTAE(cNumOS, cDtExp, cError)
   
    // Criar objeto de conexão com o TAE
    Local oTAE      := conTAE()
    Local oFile     := Nil
    Local cFile     := ""
    Local aDataATD  := {}
    Local cNomeFile := ""
    Local lUpload   := .F.
    local oRequest  := Nil
    Local cMsgErr   := ""
    Local cPapel    := SUPERGETMV('MV_TAE01') //Papel padrão para assinatura - ex.: "como arrendante"
    Local aDest     := {}
    Local nIdEnv	:= Nil // Id do envelope
    Local cAssunto  := 'Assinatura digital do documento '
    Local cMsgTAE   := 'Relatório de atendimento para a ordem de serviço '
    Local aObserv   := {}
    Local cResponse := '' // retorno da chamada de uploadFile
    Local aResp     := {} // Responsáveis técnicos

    Default cError := ""
    
    // Obter dados de atendimento da ordem de serviço 
    aDataATD := GetAtdOS(cNumOS)

    If !oTAE:hasError()
        If Len(aDataATD) > 0
            aResp := assinantes(aDataATD[12], cPapel) 
            If len(aResp) > 0
                aDest := aResp[1]
                aObserv := aResp[2]

                If Len(aDest) > 0
                    cNomeFile := cNumOS + aDataATD[8]
                    cAssunto += cNomeFile
                    cMsgTAE += cNumOS

                    // Obter documento que será assinado
                    cFile := genLaudPdf(cNomeFile+".PDF",cNumOS,aDataATD)          
                    If !Empty(cFile) .AND. VALTYPE(cFile) == 'C'
                        oFile := tecFOPEN(cFile) 
                        // Fazer upload do documento, usando o objeto TAE
                        lUpload := oTAE:uploadFile(oFile,cNomeFile+".PDF", ALLTRIM(aDataATD[13])+ALLTRIM(aDataATD[12])+DTOS(DDATABASE), @oRequest, @cMsgErr)

                        If lUpload
                            nIdEnv := oRequest:data
                            cDtExp  := cDtExp //"2024-11-02"
                            oTAE:publicar(nIdEnv,aDest,aObserv,cPapel,cDtExp,cAssunto,cMsgTAE,@cResponse)
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
return .T.

Function conTAE()

    Local cUser     := SUPERGETMV('MV_USRTAE') 
    Local cPsWrd    := SUPERGETMV('MV_PWTAE')
    Local cBaseUrl  := SUPERGETMV('MV_TAEBASE',,"https://totvssign.staging.totvs.app")
    Local oTAE      := TecTAE():New(cBaseUrl) 
    
    oTAE:defUser(cUser)
    oTAE:defPw(cPsWrd)
    oTAE:auth() 

Return oTAE

Static Function assinantes(cCodCli, cPapel)
    Local aDest     := {}
    Local aObserv   := {}
    Local cQry      := ""
    Local cTmpAlias := GetNextAlias()
    
    cQry += "SELECT JNW_CODCLI, JNW_CODIGO, JNW_NOME, JNW_CPF, JNW_EMAIL, JNW_ASSINA, JNW_OBSERV "
    cQry += "FROM " + retSqlName("JNW") + " JNW " 
    cQry += "WHERE JNW_CODCLI = '" + cCodCli + "' AND "
    cQry += "D_E_L_E_T_ = ' '"

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cTmpAlias, .F., .T.)
 
    While (cTmpAlias)->( !Eof())
        If (cTmpAlias)->JNW_ASSINA == "1"
            AADD(aDest, { (cTmpAlias)->JNW_EMAIL, (cTmpAlias)->JNW_NOME, (cTmpAlias)->JNW_CPF })
        EndIf

        If (cTmpAlias)->JNW_OBSERV == "1"
            AADD(aObserv, (cTmpAlias)->JNW_EMAIL)
        EndIf

        (cTmpAlias)->(dbSkip())
    EndDo
Return {aDest,aObserv}

Static Function tecFOPEN(cPath)
    Local cBuffer := ""
    Local cResult := ""
    Local nHandle := 0
    Local nBytes  := 0

	nHandle := FOPEN(cPath) 
	If nHandle > -1
		While (nBytes := FREAD(nHandle, @cBuffer, 524288)) > 0 
			cResult += cBuffer
		EndDo

		FCLOSE(nHandle)
	EndIf
Return cResult


// Obtem dados do atendimento da OS e os retorna em formato de array
Static Function GetAtdOS(cNumOs)
    Local cQry      := ''
    local cTmpAlias := GetNextAlias()
    Local aResult    := {}
    Local ab9Assina := " "

    cQry += "SELECT AB6.AB6_CODCLI, "
    cQry += "AB6.AB6_EMISSA, " 
    cQry += "AB6.AB6_APPDTI, "
    cQry += "AB6.AB6_APPDCH, "          
    cQry += "A1.A1_NOME, "
    cQry += "AA1.AA1_EMAIL, "
    cQry += "AB9.AB9_CODTEC, "
    cQry += "AA1.AA1_NOMTEC, "
    cQry += "AB9.AB9_DTCHEG, "
    cQry += "AB9.AB9_HRCHEG, "
    cQry += "AB9.AB9_DTSAID, " 
    cQry += "AB9.AB9_HRSAID, "
    cQry += "AB9.AB9_DTINI, "
    cQry += "AB9.AB9_HRINI, "
    cQry += "AB9.AB9_DTFIM, "
    cQry += "AB9.AB9_HRFIM, "
    cQry += "AB9.AB9_MEMO1, "
    cQry += "AB7.AB7_MEMO1, "
    cQry += "AB9.R_E_C_N_O_ REC "
    cQry += "FROM " + retSqlName('AB9') + " AB9 "
    
    cQry += "INNER JOIN " + retSqlName('AA1') + " AA1 "
    cQry += " ON AA1.AA1_CODTEC = AB9.AB9_CODTEC AND "
    cQry += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' AND "
    cQry += " AA1.D_E_L_E_T_ = ' ' "
    
    cQry += "INNER JOIN " + retSqlName('AB7') + " AB7 "
    cQry += " ON CONCAT(AB7.AB7_NUMOS,AB7.AB7_ITEM) = AB9.AB9_NUMOS AND "
    cQry += " AB7.AB7_FILIAL = '" + xFilial("AB7") + "' AND "
    cQry += " AB7.D_E_L_E_T_ = ' ' "

    cQry += "INNER JOIN " + retSqlName('AB6') + " AB6 "
    cQry += " ON AB6.AB6_NUMOS = AB7.AB7_NUMOS AND "
    cQry += " AB6.AB6_FILIAL = '" + xFilial("AB6") + "' AND "
    cQry += " AB6.D_E_L_E_T_ = ' ' "

    cQry += "INNER JOIN " + retSqlName("SA1") + " A1 "
    cQry += " ON A1.A1_COD = AB6.AB6_CODCLI AND "
    cQry += " A1.A1_FILIAL = '" + xFilial("SA1")+ "' AND "
    cQry += " A1.D_E_L_E_T_ = ' ' "

    cQry += "WHERE AB9.AB9_NUMOS = '" + cNumOs + "' AND "
    cQry += " AB9.AB9_FILIAL = '" + xFilial("AB9") + "' AND "
    cQry += " AB9.D_E_L_E_T_ = ' ' "

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cTmpAlias, .F., .T.)

    If (cTmpAlias)->( !Eof() )
        (cTmpAlias)->( DBGoTop())

        While (cTmpAlias)->( !Eof() )
            If VALTYPE((cTmpAlias)->REC) == 'N'
                DbSelectArea('AB9')
                AB9->(DbSetOrder(1))
                AB9->(DbGoTo((cTmpAlias)->REC))

                If !Empty(AB9->AB9_APPASS)
                    ab9Assina := AB9->AB9_APPASS
                EndIf
            EndIf

            aResult := {;
                        (cTmpAlias)->AA1_NOMTEC, ; //[1]  Código do atendente
                        (cTmpAlias)->AB9_DTCHEG, ; //[2]  Data de chegada ao local do atendimento da OS
                        (cTmpAlias)->AB9_HRCHEG, ; //[3]  Horário de chegada ao local do atendimento da OS 
                        (cTmpAlias)->AB9_DTSAID, ; //[4]  Data de saída do local de atendimento da OS
                        (cTmpAlias)->AB9_HRSAID, ; //[5]  Horário de saída do local de atendimento da OS
                        (cTmpAlias)->AB9_DTINI, ;  //[6]  Data de início do atendimento
                        (cTmpAlias)->AB9_HRINI, ;  //[7]  Horário de início do atendimento
                        (cTmpAlias)->AB9_DTFIM, ;  //[8]  Data fim do atendimento da OS
                        (cTmpAlias)->AB9_HRFIM, ;  //[9]  Horário de término do atendimento
                        (cTmpAlias)->AB9_MEMO1, ;  //[10] Laudo de atendimento da OS (chave memo da SYP)
                        ab9Assina,;                //[11] Assinatura da OS (campo memo - base64)
                        (cTmpAlias)->AB6_CODCLI,;  //[12] Código do cliente
                        (cTmpAlias)->A1_NOME,;     //[13] Nome do cliente
                        (cTmpAlias)->AB6_EMISSA,;   //[14] Data de criação da OS, formato YYYYMMDD
                        (cTmpAlias)->AB7_MEMO1,;     //[15] Detalhe da ocorrência
                        (cTmpAlias)->AA1_EMAIL;     //[16] Email do técnico
                    }
            (cTmpAlias)->(DBSkip())
        EndDo
    EndIf

Return aResult

Static Function genLaudPdf(cNmFile, cNumOs, aAtdData)

Local cFile             := ""
Local cPathLocal        := GetSrvProfString("StartPath","") //'\system\'
Local lAdjustToLegacy   := .T.    
Local lDisableSetup     := .T.   
Local lViewPDF          := .T.
Local nSizeRow          := 40
Local cLaudo            := ''
Local cOcorr            := ''
Local nTam              := Len(Space(TamSx3("YP_TEXTO")[1]))
Local cLine             := ""

If Len(aAtdData) > 0
    oPrint := FWMSPrinter():New(cNmFile/*cRelNome*/,IMP_PDF,lAdjustToLegacy,cPathLocal,lDisableSetup,,,,,,,lViewPDF)

    cFile := cPathLocal+cNmFile
    File2Printer( cFile, "PDF" )
    oPrint:cPathPDF:= cPathLocal

    oFont8  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
    oFont10 := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
    oFont20 := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)

    oPrint:StartPage()
    nRow1 := 1

    oPrint:Line(nRow1+100,100,nRow1+0100,1400)
    
    oPrint:Say(nRow1+0080,100,"RELATÓRIO DA ORDEM DE SERVIÇO "+cNumOs,oFont20 ) 
    nRow1++
    
    oPrint:Say(0080+(nSizeRow*nRow1),100,"Cliente: "+ALLTRIM(aAtdData[13]),oFont10 )
    nRow1++
    nRow1++
    
    oPrint:Say(0080+(nSizeRow*nRow1),100,"Ocorrência: ",oFont10 )
    If !EMPTY(aAtdData[15])
        If(SYP->(DbSeek(xFilial("SYP") + aAtdData[15], .T.)))
            While SYP->(!Eof()) .And. ( aAtdData[15] == SYP->YP_CHAVE ) .And. ( xFilial("SYP") == SYP->YP_FILIAL )
                cLine := RTrim(Subs(SYP->YP_TEXTO,1,nTam))
                
                if At("\13\10", cLine )  > 0 .OR. At("\14\10", cLine )  > 0
                    cLine := StrTran( cLine, "\13\10", Space(2))
                    cLine := StrTran( cLine, "\14\10", Space(2))
                EndIf
                
                if( At(char(9), cLine ) ) > 0
                    cLine := StrTran( cLine, char(9), Space(5) )
                EndIf
                                
                If( AT('\n', cLine)) > 0
                    cLine := StrTran( cLine, '\n', '' )
                EndIf
                
                nRow1++ 
                
                CaracEsp(cLine,@cOcorr)
                oPrint:Say(0080+(nSizeRow*nRow1),100,cOcorr,oFont10 )
                SYP->(DbSkip())
            End While
        EndIf
    EndIf
    nRow1++
    nRow1++
    
    oPrint:Say(0080+(nSizeRow*nRow1),100,"Técnico: "+aAtdData[1],oFont10 )
    nRow1++
    nRow1++
    
    oPrint:Say(0080+(nSizeRow*nRow1),100,"Data de abertura: "+right(AaTDdATA[14],2) + '/'+ LEFT(right(AaTDdATA[14],4),2)+'/'+LEFT(AaTDdATA[14],4),oFont10 )
    nRow1++
    nRow1++
    
    oPrint:Say(0080+(nSizeRow*nRow1),100,"Data do atendimento: "+right(AaTDdATA[8],2) + '/'+ LEFT(right(AaTDdATA[8],4),2)+'/'+LEFT(AaTDdATA[8],4),oFont10 )
    nRow1++
    nRow1++

    If !EMPTY(aAtdData[10])
        If(SYP->(DbSeek(xFilial("SYP") + aAtdData[10], .T.)))
            While SYP->(!Eof()) .And. ( aAtdData[10] == SYP->YP_CHAVE ) .And. ( xFilial("SYP") == SYP->YP_FILIAL )
                cLine := RTrim(Subs(SYP->YP_TEXTO,1,nTam))
                if( At(char(9), cLine ) ) > 0
                    cLine := StrTran( cLine, char(9), Space(5) )
                EndIf

                If( AT('\n', cLine)) > 0
                    cLine := StrTran( cLine, '\n', '' )
                EndIf
                
                nRow1++ 
                
                CaracEsp(cLine,@cLaudo)
                oPrint:Say(0080+(nSizeRow*nRow1),100,cLaudo,oFont10 )
                SYP->(DbSkip()) 
            End While
        EndIf
    EndIf
    oPrint:Preview()

    cFile := cPathLocal+cNmFile 

EndIf

Return cFile
