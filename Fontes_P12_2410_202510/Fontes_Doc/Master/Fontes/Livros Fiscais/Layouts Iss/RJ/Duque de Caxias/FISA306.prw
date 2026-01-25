#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA306
Função para geração do arquivo para a prefeitura de Duque de Caxias de serviços tomados.

@type  Function
@author leandro.faggyas
@since 01/03/2021
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function FISA306() 
Local lLGPD  	  := FindFunction("Verpesssen") .And. Verpesssen()
Local lAutomato   := IiF(IsBlind(),.T.,.F.)

If !lAutomato .And. lLGPD
    If Pergunte('FISA306',.T.,"Parâmetros de geração do arquivo" )  //"Parâmetros de geração do arquivo"
        FwMsgRun(,{|oSay| ProcArq(oSay,lAutomato) },"Processando do arquivo","")	  //"Processando do arquivo"
    EndIf
Else
    ProcArq()
EndIf
Return
/*/{Protheus.doc} ProcArq
Realiza o processamento e impressão do arquivo de Duque de Caxias.
@type  Function
@author leandro.faggyas
@since 01/03/2021
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function ProcArq( oSay, lAutomato )
Local nHandle       := 0 
Local cAliasQry     := ""

Local cMesApur      := MV_PAR01
Local cAnoApur      := MV_PAR02
Local cNFiscalDe    := MV_PAR03
Local cNFiscaAte    := MV_PAR04
Local cSerieDe      := MV_PAR05
Local cSerieAte     := MV_PAR06
Local cCodSer       := MV_PAR07
Local cCodSerAte    := MV_PAR08
Local cDiretorio    := AllTrim(MV_PAR09)
Local cNomeArq      := AllTrim(MV_PAR10)
Local cInsMun       := AllTrim(SuperGetMv("MV_NFEINSC"))
Local cMV2DupRef    := AllTrim(SuperGetMv("MV_2DUPREF"))
Local cPrefixo      := ""
Local nTamPref      := TamSX3("E2_PREFIXO")[1]

Local cNomeEmp      := AllTrim(SM0->M0_NOMECOM)
Local cCodISS       := ""
Local cCodISSAux    := ""

Local cStartPath    := GetSrvProfString("StartPath","")

If Empty(cInsMun)
    cInsMun := AllTrim(SM0->M0_INSCM)
EndIf

If lAutomato
    AtualizaMsg( oSay, "Gerando arquivo texto" )  //"Gerando arquivo texto"
EndIf

DbSelectArea("SF1")
SF1->(DbSetOrder(1)) //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO

DbSelectArea("SD1")
SD1->(DbSetOrder(1)) //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM

DbSelectArea("SF4")
SF4->(DbSetOrder(1)) //F4_FILIAL, F4_CODIGO

DbSelectArea("SE2")
SE2->(DbSetOrder(6)) //E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO

//Monto a query que será utilizada como base para impressão dos registros
cAliasQry := QryDqCx( cMesApur, cAnoApur, cNFiscalDe, cNFiscaAte, cSerieDe, cSerieAte, cCodSer, cCodSerAte  )
(cAliasQry)->(DbGoTop())

cCodISS  := AllTrim((cAliasQry)->F3_CODISS)
cCodISS  := StrTran(cCodISS, ".", "")
cNomeArq := StrTran(cNomeArq, ".txt", "")
cNomeArq := StrTran(cNomeArq, ".", "")
cNomeArq := cNomeArq + "_" + StrTran(cCodISS, ".", "") + ".txt" 

//Crio um novo arquivo de ISS
nHandle  := CriaArqISS( cStartPath, cDiretorio, cNomeArq, lAutomato, cNomeEmp, cInsMun, cMesApur, cAnoApur, cCodISS)

While !(cAliasQry)->(Eof())

    cCodISSAux := StrTran(AllTrim((cAliasQry)->F3_CODISS), ".", "")

    If cCodISS <> cCodISSAux

        If nHandle > 0
            FClose(nHandle)
        EndIf

        cNomeArq := StrTran( cNomeArq, "_" + cCodISS + ".txt", "_" + cCodISSAux + ".txt", 1, 1 )
        cCodISS := cCodISSAux

        nHandle := CriaArqISS( cStartPath, cDiretorio, cNomeArq, lAutomato, cNomeEmp, cInsMun, cMesApur, cAnoApur, cCodISS)
    EndIf
    
    SF1->(DbGoTo( (cAliasQry)->SF1RECNO) ) //Necessario realizar esse DbGoTo por conta do conteudo do parametro MV_2DUPREF.
    SD1->(MsSeek(xFilial("SD1")+(cAliasQry)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
    SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))

    cPrefixo := Padr(&(cMV2DupRef), nTamPref)
    SE2->( MsSeek( xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + cPrefixo + SF1->F1_DOC )) // Posiciono na SE2 para buscar a data de pagamento do serviço
    
    GeraLinha( cAliasQry, nHAndle )   
    (cAliasQry)->(dbSkip())
EndDo

If nHandle > 0
    FClose(nHandle)
EndIf
(cAliasQry)->(dbCloseArea())

If !lAutomato
    AtualizaMsg( oSay, "Processamento Concluído" )  //"Processamento Concluído"
    MsgInfo("Processamento Concluído", "Atenção") //"Processamento Concluído"
EndIf

Return		


/*/{Protheus.doc} QryDqCx
    Monta a query principal para a geração da instrução normativa de Duque de Caxias.
    @type  Function
    @author leandro.faggyas
    @since 01/03/2021
    @version 1.0
    @return cAlias
    /*/
Static Function QryDqCx( cMesApur, cAnoApur, cNFiscalDe, cNFiscaAte, cSerieDe, cSerieAte, cCodSer, cCodSerAte )
Local cAlias  := GetNextAlias()
Local dDtIni  := CtoD("01/" + cMesApur + "/" + cAnoApur)
Local dDtFim  := LastDay(dDtIni)

BeginSql Alias cAlias
    COLUMN F3_EMISSAO AS DATE
    COLUMN F3_DTCANC  AS DATE

    SELECT  SF3.F3_ESPECIE,
            SF3.F3_NFISCAL,
            SF3.F3_EMISSAO,
            SF3.F3_VALCONT,
            SF3.F3_DTCANC,
            SF3.F3_CODISS,
            SF3.F3_ISSSUB,
            SF3.F3_ISSMAT,
            SF3.F3_NFELETR,
            SF3.F3_RECISS,
            SF3.F3_ENTRADA,
            SF3.F3_SERIE,
            SF3.F3_CLIEFOR,
            SF3.F3_LOJA,
            SF3.F3_TIPO,
            SF3.F3_CNAE,
            SF3.F3_CFO,
            SF3.F3_ALIQICM,
            SF3.F3_ISENICM,
            SF3.F3_OUTRICM,

            SF1.F1_VALCOFI, 
            SF1.F1_VALIRF, 
            SF1.F1_VALCSLL,
            SF1.F1_INSS,
            SF1.F1_VALPIS,
            SF1.F1_DESCONT,      
            SF1.F1_RECBMTO,  
            SF1.R_E_C_N_O_ AS SF1RECNO, 
            
            SA2.A2_CGC,
            SA2.A2_NOME,
            SA2.A2_INSCRM,
            SA2.A2_CEP,
            SA2.A2_END,
            SA2.A2_NR_END,
            SA2.A2_BAIRRO,
            SA2.A2_MUN,
            SA2.A2_COD_MUN,
            SA2.A2_EST,
            SA2.A2_DDD,
            SA2.A2_RECISS

    FROM 	%TABLE:SF3% SF3
    LEFT JOIN %TABLE:SF1% SF1 ON(SF1.F1_FILIAL  = %xFilial:SF1% AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA  AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_ESPECIE = SF3.F3_ESPECIE AND SF1.%NOTDEL%) 
    LEFT JOIN %TABLE:SA2% SA2 ON(SA2.A2_FILIAL  = %xFilial:SA2% AND SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA     = SF3.F3_LOJA  AND SA2.%NOTDEL%)

    WHERE   SF3.F3_FILIAL   = %XFILIAL:SF3%     
    AND     SF3.F3_ENTRADA >= %EXP:dDtIni% 
    AND     SF3.F3_ENTRADA <= %EXP:dDtFim%   
    AND     SF3.F3_NFISCAL >= %EXP:cNFiscalDe% 
    AND     SF3.F3_NFISCAL <= %EXP:cNFiscaAte%
    AND     SF3.F3_SERIE   >= %EXP:cSerieDe% 
    AND     SF3.F3_SERIE   <= %EXP:cSerieAte%
    AND     SF3.F3_CODISS  <> ''
    AND     (SF3.F3_CODISS  >= %Exp:cCodSer%
    AND     SF3.F3_CODISS  <= %Exp:cCodSerAte%)
    AND     SF3.F3_CFO      < '5'
    AND     SF3.F3_TIPO     = 'S' 
    AND     SF3.%NOTDEL%    

    ORDER BY SF3.F3_FILIAL, SF3.F3_CODISS, SF3.F3_EMISSAO
EndSql

Return cAlias

//-------------------------------------------------------------------
Static Function AtualizaMsg(oSay,cMsg)
    oSay:cCaption := (cMsg)
    ProcessMessages()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraLinha
Rotina para gerar as linhas do arquivo texto.

@type  Function
@author leandro.faggyas
@since 01/03/2021
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function GeraLinha(cAliasQry, nHandle)

Local cModelo    := AllTrim(AModNot((cAliasQry)->F3_ESPECIE))
Local cNumDoc    := (cAliasQry)->F3_SERIE + (cAliasQry)->F3_NFISCAL
Local cValTrib   := AllTrim(Str((cAliasQry)->F3_VALCONT - (cAliasQry)->F3_ISENICM - (cAliasQry)->F3_OUTRICM ,10,2))
Local cValDoc    := AllTrim(Str((cAliasQry)->F3_VALCONT,10,2))
Local cAlqIss    := AllTrim(Str((cAliasQry)->F3_ALIQICM,3,1))
Local cDataEmis  := StrTran(DtoC((cAliasQry)->F3_EMISSAO),"/","")
Local dDtBaixa   := IIF(!Empty(SE2->E2_BAIXA),SE2->E2_BAIXA,SE2->E2_VENCTO)
Local cDtPagto   := AllTrim(StrTran(DtoC(dDtBaixa),"/",""))
Local cCNPJPres  := AllTrim((cAliasQry)->A2_CGC)
Local cRazSocial := SubStr(AllTrim(EnCodeUtf8(NoAcento(Upper((cAliasQry)->A2_NOME)))),1,150)
Local cInscrMun  := SubStr(AllTrim((cAliasQry)->A2_INSCRM),1,15)
Local cImpRet    := IIf(SF4->F4_RETISS == "S","1","0") //Indica se houve retenção de imposto, sendo 1=Sim e 0=Não.
Local cCEP       := AllTrim((cAliasQry)->A2_CEP)
Local cEndereco  := SubStr(AllTrim(EnCodeUtf8(NoAcento((cAliasQry)->A2_END))),1,200)
Local cEndNum    := AllTrim((cAliasQry)->A2_NR_END)
Local cBairro    := AllTrim(EnCodeUtf8(NoAcento(Upper((cAliasQry)->A2_BAIRRO))))
Local cMunicipio := AllTrim(EnCodeUtf8(NoAcento(Upper((cAliasQry)->A2_MUN))))
Local cEstado    := AllTrim((cAliasQry)->A2_EST)
Local cDDD       := AllTrim((cAliasQry)->A2_DDD)

Local cLinha     := ""
Local cTribMun   := ""
Local cPstServ   := ""

cEndereco  := StrTran( cEndereco  ,";","" )
cBairro    := StrTran( cBairro    ,";","" )
cMunicipio := StrTran( cMunicipio ,";","" )

If (cAliasQry)->A2_RECISS == "N" .And. SF4->F4_ISSST == "1"
    cTribMun := "1"
Else
    cPstServ := NFePstServ(cMunicipio,cEstado,"DUQUE DE CAXIAS","RJ",(cAliasQry)->F3_DTCANC,SF4->F4_ISSST,(cAliasQry)->F3_ISENICM + (cAliasQry)->F3_OUTRICM)
    If cPstServ == "01"
        cTribMun := "1"
    Else
        cTribMun := "0"
    EndIf
Endif

cLinha :=   cModelo    + ";" +;
            cNumDoc    + ";" +;
            cValTrib   + ";" +;
            cValDoc    + ";" +;
            cAlqIss    + ";" +;
            cDataEmis  + ";" +;
            cDtPagto   + ";" +;
            cCNPJPres  + ";" +;
            cRazSocial + ";" +;
            cInscrMun  + ";" +;
            cImpRet    + ";" +;
            cCEP       + ";" +;
            cEndereco  + ";" +;
            cEndNum    + ";" +;
            cBairro    + ";" +;
            cMunicipio + ";" +;
            cEstado    + ";" +;
            cDDD       + ";" +;
            cTribMun   + ";" + CRLF

//Realizo a impressão da linha processada
FWrite(nHandle, cLinha)
       
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} CriaArq
Realiza a criaçao do arquivo texto para impressão da instrução normativa.

@type  Function
@author leandro.faggyas
@since 01/03/2021
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function CriaArqISS( cStartPath, cDiretorio, cNomeArq, lAutomato, cNomeEmp, cInsMun, cMesApur, cAnoApur, cCodISS )
Local nHandle  := 0
Local nRetCpy  := 0
Local nRetType := GetRemoteType()

Local cTrab	   := ""
Local cCabec   := ""
Local cMsg     := ""

If nRetType == 5 // HTML
    cTrab	:= CriaTrab(,.F.)+".TXT"
    nHandle := FCreate(cTrab,0)
EndIf

If nRetType <> 5 .Or. ( Ferror() == 0 .And. RetType == 5 )

    If nRetType == 5 // HTML
        
        cMsg := "Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador." //FISMSG("HTML")
        MsgAlert(cMsg)
        If File(cStartPath+cTrab)
            FRename(cStartPath+cTrab,cNomeArq)
        EndIf

        nRetCpy := CPYS2TW(cStartPath+cNomeArq)
        If nRetCpy == 0
            FErase(cNomeArq)
        EndIf

        cDiretorio := cStartPath

    ElseIf nRetType == 2 // REMOTE_LINUX
        If Substr(cDiretorio,Len(cDiretorio)-1, 1) <> "/"
            cDiretorio += "/"
        EndIf
    Else
        If Substr(cDiretorio,Len(cDiretorio)-1, 1) <> "\"
            cDiretorio += "\"
        EndIf
    EndIf

    nHandle := fCreate(cDiretorio+cNomeArq)
    If nHandle = -1 .And. !lAutomato
        Alert('Erro ao criar arquivo:' + Str(Ferror()))
    EndIf

    If nHandle > 0

        cCabec :=   cInsMun            + ";" +;
                    cMesApur           + ";" +;
                    cAnoApur           + ";" +;
                    Time() + " " + DtoC(dDataBase) + cNomeEmp + ";" +;
                    cCodISS            + ";" +;
                    "EXPORTACAO DECLARACAO ELETRONICA-ONLINE-NOTA CONTROL" + CRLF


        FWrite(nHAndle,cCabec)
    EndIf
EndIf

Return nHandle
