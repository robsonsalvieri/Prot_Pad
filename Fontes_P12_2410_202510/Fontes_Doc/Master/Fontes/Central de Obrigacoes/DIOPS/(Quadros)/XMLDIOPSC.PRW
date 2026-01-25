#INCLUDE 'Protheus.ch'
#INCLUDE 'Fileio.ch'

#DEFINE F_BLOCK 		512
#DEFINE PDTE_VALID		"1" // Pendente Validação
#DEFINE VALIDO			"2" // Valido
#DEFINE INVALIDO		"3" // Inválido
#DEFINE APTRANS			"Microsiga Protheus"
#DEFINE HASHDIOPS		"hashdiops.tmp"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PXMLDIOPSC

Gera o arquivo XML para o DIOPS Cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Function PXMLDIOPSC(lAuto)
    Local cTexto		:= ""
    Local cDirDIOPS    	:= ""
    Local lOk			:= .T.

    Private nArqHash	:= 0
    Private cArqLog := "PLSDIOPS_" + Dtos(dDataBase) + "_" + Replace(Time(),":","") + ".LOG" // Nome do arquivo de log da execucao

    Default lAuto 		:= .F.

    If Pergunte("PDIOPSXMLC",.T.)

        //Valido se os XSDs estão na pasta do DIOPS
        if !existDir("\diops")
            nRet := makeDir( "\diops" )
            if nRet != 0
                lOk := .F.
                cTexto := "Não foi possível criar o diretório " + GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()) + "\diops" + " "
                cTexto += Replicate("-",30) + Chr(13)
                cTexto += Replicate("-",30) + Chr(13)
            EndIf
        EndIf

        If lOk
            //Organiza o XML para envio.
            If lAuto
                Processa( {||MontaXml(lAuto) } , "Processando" , "Aguarde geração do XML DIOPS" , .F. )
            Else
                Processa( {||MontaXml() } , "Processando" , "Aguarde geração do XML DIOPS" , .F. )
            EndIf
        Else
            If !lAuto
                LogGerArq(cTexto)
            EndIf
        EndIf
    EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaXml

Monta as mensagens do DIOPS XML Cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaXml(lAuto)

    Local cMsg		:= ""   // Mensagem a ser apresentada no log e ao termino do processamento
    Local nRegua	:= 0    // Tamanho da regua
    Local lCriaLog  := .F.  // Gerar aquivo lo
    Private cDir    := ""   // Diretorio
    Default lAuto	:= .F.

    cDir     	:= AllTrim(mv_par01)

    If lAuto
        lCriaLog := .T.
    Else
        lCriaLog 	:= If(mv_par02 == 1,.T.,.F.)
    EndIf

    If lCriaLog // Cabecalho do log
        cMsg := "Geração do arquivo do DIOPS - Início: " + Dtos(dDatabase) + " " + Time() + CRLF
        cMsg += "Parâmetros informados para processamento: " + CRLF

        cMsg += "Diretório: " + cDir + CRLF
        cMsg += "Gera arquivo log: " + If(lCrialog,"Sim","Não") + CRLF
        PlsLogFil(cMsg,cArqLog)
    EndIf

    If CriaArqTmp()

        nRegua := 4 //Nº de incproc que tem no fonte
        ProcRegua(nRegua)

        IncProc("Gerando cabeçalho cadastral...")
        PrintCab()

        IncProc("Gerando dados do arquivo cadastral...")
        lContinua := Modalidade(.T.)//Abre modalidade

        If lContinua

            IncProc("Gerando enquadramento da operadora ...")
            Enquadramento()

            // Removido na versão 2018 de acordo com o link abaixo
            // http://www.ans.gov.br/atualizacoes/cadastral/4657-2018-diops-xml-cadastral-alteracao-no-envio-de-informacoes-cadastrais

            If B8M->B8M_MODALI == "ADMIN" .And. B8M->B8M_NATJUR == "SOCIA" .And. B8M->B8M_SEGMEN == "ADMPL"
                IncProc("Gerando dados básico ...")
                DadosBasicos()
            EndIf

            //IncProc("Gerando dados dos representantes ...")
            //Representantes(.F.)

            //IncProc("Gerando dados dos representantes RN 117 ...")
            //Representantes(.T.)

            IncProc("Gerando dados dos acionistas / quotistas ...")
            Acionistas()

            IncProc("Gerando dados das controladas / coligadas ...")
            controlColigadas()

            IncProc("Gerando dados das dependencias ...")
            Dependencias()

            Modalidade(.F.)//Fecha modalidade

            IncProc("Gravando arquivo cadastral a ser enviado ...")
            EscreveArq()

            MsgInfo("Geração do XML Cadastral concluída","Informativo")

        EndIf

    EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaArqTmp
Monta o cabeçalho do XML

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaArqTmp()

    Local cXmlTempFile	:= Alltrim(cDir)+"diopsbuffer.xml"
    Local nArqTmp := FCreate(cXmlTempFile,0,,.F.) // criacao do arquivo

    FClose(nArqTmp)
Return nArqTmp > 0

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaTag
Monta a Tag
@param nSpc     espaco para identar o arquivo
@param cTag     nome da tab
@param cVal     valor da tag
@param lIni     abertura de tag
@param lFin     fechamento de tag
@param lPerNul  permitido nulo na tag
@param lRetPto  retira caracteres especiais

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaTag(nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag)

    Local cRetTag := "" // Tag a ser gravada no arquivo texto
    Default lRetPto := .T.
    Default lEnvTag := .T.

    If !Empty(cVal) .Or. lPerNul

        If lIni // Inicializa a tag ?
            cRetTag += '<' + cTag + '>'
            cRetTag += AllTrim(cVal)
        EndIf

        If lFin // Finaliza a tag ?
            cRetTag += '</' + cTag + '>'
        EndIf

        cRetTag := Space(nSpc) + cRetTag + CRLF // Identa o arquivo

        If nArqHash > 0
            FWrite(nArqHash,AllTrim(cVal))
        EndIf

    EndIf

Return Iif(lEnvTag,cRetTag,"")

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintCab
Monta o cabeçalho do XML Cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrintCab()

    Local cCabXml	:= ''
    Local cData     := SubStr(DTos(DdataBase),1,4)+"-"+SubStr(DTos(DdataBase),5,2)+"-"+SubStr(DTos(DdataBase),7,2)

    nArqHash := FCreate(HASHDIOPS,0,,.F.)

    cCabXml := '<?xml version="1.0" encoding="UTF-8" ?>' + CRLF
    cCabXml += '<ans:diopsCadastral xmlns:ans="http://www.ans.gov.br/padroes/diops/schemas"'
    cCabXml += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ans.gov.br/padroes/diops/schemas/diopsComplexTypes.xsd">' + CRLF
    InsInXMLTemp(cCabXml)
    InsInXMLTemp(MontaTag(3,'ans:identificador','',.T.,.F.,.T.) )
    InsInXMLTemp(MontaTag(6,'ans:registroANS',mv_par03,.T.,.T.,.F.,.F.) )
    InsInXMLTemp(MontaTag(6,'ans:razaoSocial',RetPonto(AllTrim(B8M->B8M_RAZSOC)),.T.,.T.,.F.,.F.) )
    InsInXMLTemp(MontaTag(6,'ans:CNPJ',B8M->B8M_CNPJOP,.T.,.T.,.F.) )
    InsInXMLTemp(MontaTag(6,'ans:periodo',cData,.T.,.T.,.F.) )
    InsInXMLTemp(MontaTag(6,'ans:transacao','ENVIO_DIOPS_CADASTRAL',.T.,.T.,.F.) )
    InsInXMLTemp(MontaTag(6,'ans:hashPwd',AllTrim(Lower(MD5(AllTrim(DIOPSGetPwd()),2))),.T.,.T.,.F.) )
    InsInXMLTemp(MontaTag(6,'ans:apTrans',APTRANS,.T.,.T.,.F.) )
    InsInXMLTemp(MontaTag(3,'ans:identificador','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Modalidade

Funcao criada para escrever os dados de modalidade no XML cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function Modalidade(lInicio)
    Local lContinua	:= .T.
    Default lInicio	:= .T.//.T. - Inicio; .F. - Termino

    B8M->(dbSetOrder(1))
    If B8M->(dbSeek(xFilial("B8M")+mv_par03))

        cTag := B8MTagXML('M',B8M->B8M_MODALI)

    Else
        lContinua := .F.
    EndIf

    If lContinua .And. !Empty(cTag)

        InsInXMLTemp( MontaTag(3,"ans:" + cTag,'',lInicio,!lInicio,.T.) )

        If !lInicio
            PrintFooter()
        EndIf

    Else
        lContinua := .F.
    EndIf

    If !lContinua
        Help( ,, 'HELP',,"Cadastro de operadora não encontrado! Faça o cadastro para o registro " + B3A->B3A_CODOPE, 1, 0)
    EndIf

Return lContinua

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintFooter
Monta o fim do XML Cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrintFooter()

    Epilogo()

    InsInXMLTemp(MontaTag(0,'ans:diopsCadastral','',.F.,.T.,.T.) )
    // Removido para ficar de acordo com a ANS e PLS
    // InsInXMLTemp(MontaTag(0,'mensagemDiops','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsInXMLTemp
Monta o fim do XML

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function InsInXMLTemp(cXMLText)

    Local nFile			:=	0
    Local cBuffer 		:= Space(F_BLOCK)
    Local cDir 			:= IIf(alltrim(MV_PAR01)=="","C:\",alltrim(MV_PAR01))
    Local cXmlTempFile	:= Alltrim(cDir)+"diopsbuffer.xml"

    nFile := FOpen(cXmlTempFile,FO_READWRITE + FO_SHARED)
    If nFile > 0
        FSeek(nFile, 0, FS_END) //Posiciona no fim do arquivo
        FWrite(nFile,cXmlText )
    EndIf
    FClose(nFile)

Return cXmlTempFile

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Epilogo

Funcao criada para escrever o epilogo do arquivo xml

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function Epilogo()

    InsInXMLTemp( MontaTag(3,'ans:epilogo','',.T.,.F.,.T.) )
    InsInXMLTemp( MontaTag(6,'ans:hash',RetornaHash(),.T.,.T.,.T.) )
    InsInXMLTemp( MontaTag(3,'ans:epilogo','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaHash

Funcao criada para retornar o hash do arquivo

@author vinicius.nicolau
@since 12/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaHash()
    Local cHash	:= ""

    If nArqHash > 0

        FClose(nArqHash)
        cHash := MD5File(HASHDIOPS)
        FErase(HASHDIOPS)
        nArqHash := 0

    EndIf

Return cHash

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Enquadramento

Funcao criada para escrever os dados de enquadramento no xml cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function Enquadramento()
    Local nUF	:= 0
    Local nMun	:= 0
    Local aUF	:= CarregaEstados()
    Local cSeg	:= Segmentacao()

    InsInXMLTemp( MontaTag(6,'ans:enquadramento','',.T.,.F.,.T.) )

    InsInXMLTemp( MontaTag(9,'ans:segmentacao',cSeg,.T.,.T.,.T.) )

    If Alltrim(B8M->B8M_SEGMEN)<>'AUTRH'
        //Estados e municipios - inicio
        For nUF := 2 TO Len(aUF)
            InsInXMLTemp( MontaTag(9,'ans:UF','',.T.,.F.,.T.) )

            InsInXMLTemp( MontaTag(12,'ans:siglaUF',aUF[nUF,1],.T.,.T.,.T.) )

            If Len(aUF[nUF]) < 3

                InsInXMLTemp( MontaTag(12,'ans:todosMunicipios','S',.T.,.T.,.T.) )

            Else

                If !Empty(aUF[nUF,3])

                    InsInXMLTemp( MontaTag(12,'ans:listaMunicipios','',.T.,.F.,.T.) )

                    For nMun := nUF TO Len(aUF)
                        InsInXMLTemp( MontaTag(15,'ans:municipioIBGE',SubStr(aUF[nMun,3],1,6),.T.,.T.,.T.) )
                        nUF++
                    Next nMun

                    InsInXMLTemp( MontaTag(12,'ans:listaMunicipios','',.F.,.T.,.T.) )

                EndIf

            EndIf
            InsInXMLTemp( MontaTag(9,'ans:UF','',.F.,.T.,.T.) )
        Next nUF
    EndIf
    // InsInXMLTemp( MontaTag(2,'UF','',.F.,.T.,.T.) )
    InsInXMLTemp( MontaTag(6,'ans:enquadramento','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Segmentacao

Funcao criada para retornar o valor da tag segmentacao

@author vinicius,nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function Segmentacao()
    Local cSeg	:= ''

    cSeg := B8M->B8M_SEGMEN

Return cSeg

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaEstados

Funcao criada para retornar os estados de atendidos pela operadora

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaEstados()
    Local aUF := {.F.}

    B8W->(dbSetOrder(1))
    If B8W->(dbSeek(xFilial("B8W")+mv_par03))

        aUF[1] := .T.

        While !B8W->(Eof()) .And. B8W->B8W_CODOPE = mv_par03

            aAdd(aUF,{B8W->B8W_SIGLUF,"",SubStr(B8W->B8W_CDIBGE,1,6)})
            B8W->(dbSkip())

        EndDo

    Else
        aUF := GetTabUF()
    EndIf

Return aUF
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Acionistas

Funcao criada para escrever os dados dos ancionista no XML cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function Acionistas()
    Local cAcion	:= "ODGRP,MEGRP,FILAN,ADMIN,AUTOG"
    Local cTotPul	:= ""

    B8M->(dbSetOrder(1))
    If B8M->(dbSeek(xFilial("B8M")+mv_par03)) .And. B8M->B8M_MODALI $ cAcion

        B8S->(dbSetOrder(1))
        If B8S->(dbSeek(xFilial("B8S")+mv_par03))

            InsInXMLTemp( MontaTag(6,'ans:acionQuotistas','',.T.,.F.,.T.) )

            cTotPul := TTPulveriz(mv_par03)
            InsInXMLTemp( MontaTag(9,'ans:totalmentePulverizado',cTotPul,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(9,'ans:totalAcoesQuotas',TTAcoes(mv_par03)+".0",.T.,.T.,.T.) )

            If cTotPul == "N"

                B8S->(DbGoTop())
                While !B8S->(Eof()) .And. B8S->B8S_CODOPE = mv_par03

                    cTagTpAcio  := GetTagAcionista(B8S->B8S_TPACIO,'1')
                    cNmRazao    := GetTagAcionista(B8S->B8S_TPACIO,'2')
                    cCPFCNPJ    := GetTagAcionista(B8S->B8S_TPACIO,'3')
                    InsInXMLTemp( MontaTag(9,'ans:acionistaQuotista','',.T.,.F.,.T.) )
                    InsInXMLTemp( MontaTag(12,cTagTpAcio,'',.T.,.F.,.T.) )
                    InsInXMLTemp( MontaTag(15,cNmRazao,B8S->B8S_NOMRAZ,.T.,.T.,.T.) )
                    InsInXMLTemp( MontaTag(15,cCPFCNPJ,B8S->B8S_CPFCNP,.T.,.T.,.T.) )
                    InsInXMLTemp( MontaTag(15,'ans:qtdAcoesQuotas',AllTrim(Str(Int(B8S->B8S_QTDQUO)))+".0",.T.,.T.,.T.) )
                    InsInXMLTemp( MontaTag(12,cTagTpAcio,'',.F.,.T.,.T.) )
                    InsInXMLTemp( MontaTag(9,'ans:acionistaQuotista','',.F.,.T.,.T.) )

                    B8S->(dbSkip())

                EndDo

            EndIf

            InsInXMLTemp( MontaTag(6,'ans:acionQuotistas','',.F.,.T.,.T.) )

        EndIf

    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TTPulveriz

Funcao criada para retornar se a acoes da operadora sao totalmente pulverizadas ou nao

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Function TTPulveriz(cCodOpe)

    Local cTotPul		:= "S"  //Totalmente pulverizado S=Sim, N=Nao
    Local nTTAcoes		:= 0    //Total de acoes da operadora
    Local nTPerc		:= 0    //Percentual de acoes do acionista

    Default cCodOpe	    := ""

    nTTAcoes := Val(TTAcoes(cCodOpe))

    B8S->(dbSetOrder(1))
    If B8S->(dbSeek(xFilial("B8S")+cCodOpe))

        While !B8S->(Eof()) .And. B8S->B8S_CODOPE = cCodOpe

            nTPerc := (B8S->B8S_QTDQUO / nTTAcoes) * 100//Acho o percentual do acionista
            If nTPerc > 5//Se pelo menos um tem mais de 5% nao e totalmente pulverizado
                cTotPul := "N"
            EndIf
            B8S->(dbSkip())

        EndDo

    EndIf

Return cTotPul

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TTAcoes

Funcao criada para retornar a quantidade total de acoes

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Function TTAcoes(cCodOpe)
    Local cTTAcoes		:= ""
    Local cSql			:= ""
    Local cNAlias		:= GetNextAlias()

    Default cCodOpe	    := ""

    cSql := "SELECT SUM(B8S_QTDQUO) B8S_QTDQUO FROM " + RetSqlName("B8S") + " WHERE B8S_FILIAL = '" + xFilial("B8S") + "' AND B8S_CODOPE = '" + cCodOpe + "' AND D_E_L_E_T_ = ' '"
    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

    If !(cNAlias)->(Eof())
        cTTAcoes := AllTrim( Str(Int((cNAlias)->B8S_QTDQUO)) )
    EndIf

    (cNAlias)->(dbCloseArea())

Return cTTAcoes

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTagAcionista

Funcao criada para escrever a tag de acionista e acordo com o tipo cadastrado

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetTagAcionista(cTpAcio,cOpc)
    Local cTag			:= ""

    Default cTpAcio	    := "1"
    Default cOpc		:= "1"//1-Tipo de Acionista, 2-Nome/Razo, 3-CPF/CNPJ

    If cOpc == "1"

        If cTpAcio == "1"
            cTag	:= "ans:acionistaPF"
        Else
            cTag	:= "ans:acionistaPJ"
        EndIf

    ElseIf cOpc == "2"

        If cTpAcio == "1"
            cTag	:= "ans:nome"
        Else
            cTag	:= "ans:razaoSocial"
        EndIf

    Else

        If cTpAcio == "1"
            cTag	:= "ans:CPF"
        Else
            cTag	:= "ans:CNPJ"
        EndIf

    EndIf

Return cTag

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} controlColigadas

Funcao criada para escrever os dados de controladas / coligadas do xml cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function controlColigadas()

    B8T->(dbSetOrder(1))
    If B8T->(dbSeek(xFilial("B8T")+mv_par03))

        InsInXMLTemp( MontaTag(6,'ans:controlColigadas','',.T.,.F.,.T.) )

        While !B8T->(Eof()) .And. B8T->B8T_CODOPE = mv_par03

            InsInXMLTemp( MontaTag(9,'ans:empresa','',.T.,.F.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:CNPJ',B8T->B8T_CNPJ,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:razaoSocial',B8T->B8T_RAZSOC,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:tipoVinculo',B8T->B8T_TPPART,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:classificacaoEmpresa',B8T->B8T_CLAEMP,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:qtdeAcoesQuotas',AllTrim(Str(Int(B8T->B8T_QTDACO))),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:totalAcoesQuotas',AllTrim(Str(Int(B8T->B8T_TOTACO))),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(9,'ans:empresa','',.F.,.T.,.T.) )

            B8T->(dbSkip())

        EndDo

        InsInXMLTemp( MontaTag(6,'ans:controlColigadas','',.F.,.T.,.T.) )

    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Dependencias

Funcao criada para escrever os dados de dependencia do xml cadastral

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function Dependencias()
    Local cTipOde := ""

    InsInXMLTemp( MontaTag(6,'ans:dependencias','',.T.,.F.,.T.) )

    B8Z->(dbSetOrder(1))
    If B8Z->(dbSeek(xFilial("B8Z")+mv_par03))


        While !B8Z->(Eof()) .And. B8Z->B8Z_CODOPE = mv_par03

            If B8Z->B8Z_TIPODE == "F"
                cTipOde := "Filial"
            ElseIf B8Z->B8Z_TIPODE == "S"
                cTipOde := "Sucursal"
            Else
                cTipOde := "Outra"
            EndIf

            InsInXMLTemp( MontaTag(9,'ans:empresaDependente','',.T.,.F.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:tipo',cTipOde,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:razaoSocial',RetPonto(B8Z->B8Z_NOMRAZ),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:CNPJ',B8Z->B8Z_CNPJ,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:enderecoDependente','',.T.,.F.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:logradouro',RetPonto(B8Z->B8Z_NMLOGR),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:numLogradouro',B8Z->B8Z_NUMLOG,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:complemento',RetPonto(B8Z->B8Z_COMDEP),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:bairro',RetPonto(B8Z->B8Z_BAIRRO),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:municipioIBGE',SubStr(B8Z->B8Z_CDIBGE,1,6),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:siglaUF',B8Z->B8Z_SIGLUF,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:cep',B8Z->B8Z_CODCEP,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:enderecoDependente','',.F.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:telefone','',.T.,.F.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:codigoDDI',B8Z->B8Z_CODDDI,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:codigoDDD',B8Z->B8Z_CODDDD,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:numeroTel',B8Z->B8Z_TELEFO,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(15,'ans:ramal',B8Z->B8Z_RAMAL,.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:telefone','',.F.,.T.,.T.) )
            InsInXMLTemp( MontaTag(12,'ans:eMail',AllTrim(B8Z->B8Z_EMAIL),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(9,'ans:empresaDependente','',.F.,.T.,.T.) )

            B8Z->(dbSkip())

        EndDo


    EndIf
    InsInXMLTemp( MontaTag(6,'ans:dependencias','',.F.,.T.,.T.) )

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetPonto
Remove acentos e caracteres inválidos no XML

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetPonto(cExp)
    Default cExp := ''

    cExp := StrTran(cExp,"-"," ")
    cExp := StrTran(cExp,"."," ")
    cExp := StrTran(cExp,"´"," ")
    cExp := StrTran(cExp,","," ")
    cExp := StrTran(cExp,"("," ")
    cExp := StrTran(cExp,")"," ")
    cExp := StrTran(cExp,"/"," ")
    cExp := StrTran(cExp,"\"," ")
    cExp := StrTran(cExp,":"," ")
    cExp := StrTran(cExp,"^"," ")
    cExp := StrTran(cExp,"*"," ")
    cExp := StrTran(cExp,"$"," ")
    cExp := StrTran(cExp,"#"," ")
    cExp := StrTran(cExp,"!"," ")
    cExp := StrTran(cExp,"["," ")
    cExp := StrTran(cExp,"]"," ")
    cExp := StrTran(cExp,"?"," ")
    cExp := StrTran(cExp,";"," ")
    cExp := StrTran(cExp,"ç","c")
    cExp := StrTran(cExp,"`"," ")
    cExp := StrTran(cExp,Chr(166)," ")
    cExp := StrTran(cExp,Chr(167)," ")
    cExp := StrTran(cExp,"á","a")
    cExp := StrTran(cExp,"ã","a")
    cExp := StrTran(cExp,"à","a")
    cExp := StrTran(cExp,"â","a")
    cExp := StrTran(cExp,"é","e")
    cExp := StrTran(cExp,"è","e")
    cExp := StrTran(cExp,"ê","e")
    cExp := StrTran(cExp,"í","i")
    cExp := StrTran(cExp,"ì","i")
    cExp := StrTran(cExp,"ó","o")
    cExp := StrTran(cExp,"ò","o")
    cExp := StrTran(cExp,"õ","o")
    cExp := StrTran(cExp,"ô","o")
    cExp := StrTran(cExp,"ú","u")
    cExp := StrTran(cExp,"ù","u")
    cExp := StrTran(cExp,"Á","A")
    cExp := StrTran(cExp,"À","A")
    cExp := StrTran(cExp,"Â","A")
    cExp := StrTran(cExp,"Ã","A")
    cExp := StrTran(cExp,"É","E")
    cExp := StrTran(cExp,"È","E")
    cExp := StrTran(cExp,"Ê","E")
    cExp := StrTran(cExp,"Í","I")
    cExp := StrTran(cExp,"Ì","I")
    cExp := StrTran(cExp,"Ó","O")
    cExp := StrTran(cExp,"Ò","O")
    cExp := StrTran(cExp,"Õ","O")
    cExp := StrTran(cExp,"Ô","O")
    cExp := StrTran(cExp,"Ú","U")
    cExp := StrTran(cExp,"Ç","C")
    cExp := StrTran(cExp,"@"," ")
    cExp := StrTran(cExp,"%"," ")
    cExp := StrTran(cExp,"~"," ")
    cExp := StrTran(cExp,"¨"," ")
    cExp := StrTran(cExp,"{"," ")
    cExp := StrTran(cExp,"}"," ")
    cExp := StrTran(cExp,"+"," ")
    cExp := StrTran(cExp,"-"," ")
    cExp := StrTran(cExp,"="," ")
    cExp := StrTran(cExp,"_"," ")
    cExp := StrTran(cExp,"<"," ")
    cExp := StrTran(cExp,">"," ")
    cExp := StrTran(cExp,"&"," ")
    cExp := StrTran(cExp,"|"," ")

Return(cExp)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EscreveArq
Monta o fim do XML

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function EscreveArq()

    Local cDir 			:= IIf(alltrim(MV_PAR01)=="","C:\",alltrim(MV_PAR01))
    Local cNamArq 		:= cDir + mv_par03 + Dtos(dDataBase) + Replace(Time(),":","") + ".XML" // Nome do arquivo de envio do DIOPS a ser gerado
    Local cBuffer 		:= Space(F_BLOCK)
    Local cXmlVld 		:= ""
    Local cError 		:= ""
    Local cWarning 		:= ""
    Local cXmlTempFile	:= Alltrim(cDir)+"diopsbuffer.xml"
    local cXSD			:= "\diops\diopsComplexTypes.xsd"
    Local nArqDiops     := FCreate(cNamArq,0,,.F.) // Criacao do arquivo

    If nArqDiops >= 0

        lFinal := .F. // Vou apendar o arquivo temporario no arquivo SBX
        nTmpXml := FOpen(cXmlTempFile,FO_READWRITE + FO_SHARED)
        If nTmpXml > 0
            Do While !lFinal
                nBytes := FRead(nTmpXml, @cBuffer, F_BLOCK)
                cXmlVld += cBuffer
                If FWrite(nArqDiops,cBuffer,nBytes) < nBytes
                    lFinal := .T.
                Else
                    lFinal := (nBytes == 0)
                EndIf
            EndDo
            FClose(nTmpXml)
            FErase(cXmlTempFile)
        EndIf

        FClose(nArqDiops)

        If !XmlSVldSch(cXmlVld,cXSD, @cError, @cWarning )

            cTexto := "Log da validação com o Schema da ANS "+CHR(13)+CHR(10)
            cTexto += "Erros: "+CHR(13)+CHR(10) + cError +CHR(13)+CHR(10)
            cTexto += "Avisos: "+CHR(13)+CHR(10) + cWarning

            // Chamada para exibir a tela com os possiveis erros e avisos
            // Comentado por motivos de inconsistencias com o validador indicado no site da ANS.
            // LogGerArq(cTexto)

        EndIf

    Else
        MsgInfo("Não foi possível criar o arquivo " + cNamArq)
    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogGerArq

Monta tela para exibir o log da geração

@param cTexto Texto do Log

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Static Function LogGerArq(cTexto)

    Local oDlg
    Local cFile	:= ""
    Local cMask	:= "Arquivos Texto (*.TXT) |*.txt|"

    //__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

    DEFINE FONT oFont NAME "Mono AS" SIZE 8,18

    DEFINE MSDIALOG oDlg TITLE "XML DIOPS." From 3,0 to 340,417 PIXEL

    @ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL

    oMemo:bRClicked := {||AllwaysTrue() }

    oMemo:oFont:=oFont

    DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga

    DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."

    ACTIVATE MSDIALOG oDlg CENTER

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DIOPSGetPwd

Funcao criada para que o usuario possa informar a senha da ANS a ser enviada criptografada no XML

@author vinicius.nicolau
@since 11/01/2021
/*/
//--------------------------------------------------------------------------------------------------
Function DIOPSGetPwd()
    Local oDlgSenha	:= Nil
    Local cSenha		:= Space(15)

    If !isBlind()
        DEFINE DIALOG oDlgSenha Of GetWndDefault() TITLE "Informe a senha ANS" FROM 12, 30 TO 18,55
        @ .5,1 SAY "Senha: "
        @ .5,3.5 MSGET cSenha SIZE 035,006 OF oDlgSenha PASSWORD
        DEFINE SBUTTON FROM 32,65 TYPE 1 ACTION oDlgSenha:End() ENABLE OF oDlgSenha
        ACTIVATE MSDIALOG oDlgSenha CENTERED
    EndIf

Return PADR( cSenha,15 )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DadosBasicos

Funcao criada para escrever os dados basicos dos responsaveis no xml cadastral

@author timoteo.bega
@since 19/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function DadosBasicos()
    Local cTagResp		:= ""
    Local cTagIdent	:= ""

    B8Y->(dbSetOrder(1))
    If B8Y->(dbSeek(xFilial("B8Y")+mv_par03))

        InsInXMLTemp( MontaTag(6,"ans:dadosBasicos",'',.T.,.F.,.T.) )

        While !B8Y->(Eof()) .And. B8Y->B8Y_CODOPE = mv_par03

            If B8Y->B8Y_TPRESP == "1"
                cTagResp := "ans:respContabilidade"
            Else
                cTagResp := "ans:respAuditoria"
            EndIf

            InsInXMLTemp( MontaTag(4,cTagResp,'',.T.,.F.,.T.) )
            InsInXMLTemp( MontaTag(6,"ans:identifResp",'',.T.,.F.,.T.) )"

            If Len(AllTrim(B8Y->B8Y_CPFCNP)) == 11
                cTagIdent := "ans:CPF"
            Else
                cTagIdent := "ans:CNPJ"
            EndIf

            InsInXMLTemp( MontaTag(8,cTagIdent,AllTrim(B8Y->B8Y_CPFCNP),.T.,.T.,.T.) )

            InsInXMLTemp( MontaTag(6,"ans:identifResp",'',.F.,.T.,.T.) )
            InsInXMLTemp( MontaTag(6,"ans:nome",RetPonto(AllTrim(B8Y->B8Y_NOMRAZ)),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(6,"ans:numRegistro",AllTrim(B8Y->B8Y_NUMREG),.T.,.T.,.T.) )
            InsInXMLTemp( MontaTag(4,cTagResp,'',.F.,.T.,.T.) )

            B8Y->(dbSkip())

        EndDo

        InsInXMLTemp( MontaTag(6,"ans:dadosBasicos",'',.F.,.T.,.T.) )

    EndIf

Return
