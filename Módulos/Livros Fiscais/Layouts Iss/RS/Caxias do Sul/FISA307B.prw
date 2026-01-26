#include "protheus.ch"
#include "fisa307.ch"

//------------------------------------------------------------------
/*/{Protheus.doc} QueryDMS
    
Função que monta a consulta no banco de dados.

/*/
//------------------------------------------------------------------
 function QueryDMS(oParamArq, cAlias)
   Local dDataEmisDe  := oParamArq:GetDtIni()
   Local dDataEmisAte := oParamArq:GetDtFim()
   
   BeginSql Alias cAlias
       COLUMN F3_EMISSAO AS DATE
       COLUMN F3_DTCANC  AS DATE

       SELECT  SF3.F3_EMISSAO,
               SF3.F3_NFISCAL,
               SF3.F3_SERIE,
               SF3.F3_ESPECIE,
               SF3.F3_RECISS,
               SF3.F3_TIPO,
               SF3.F3_ALIQICM,
               SF3.F3_VALCONT,
               SF3.F3_BASEICM,
               SF3.F3_VALICM,
               SF3.F3_CODISS,

               SA2.A2_TIPO TIPO,
               SA2.A2_CGC CGC,
               SA2.A2_NOME NOME,
               SA2.A2_CEP CEP,
               SA2.A2_END ENDERECO,
               SA2.A2_COMPLEM COMPLEMENTO,
               SA2.A2_BAIRRO BAIRRO,
               SA2.A2_EST ESTADO,
               SA2.A2_CODPAIS,
               SA2.A2_PAIS PAIS,
               SA2.A2_COD_MUN CODMUN,
               SA2.A2_MUN MUNICIPIO,
               SA2.A2_RECISS,
               SA2.A2_INSCR IE,
               SA2.A2_INSCRM,
               SA2.A2_DDD,
               SA2.A2_TEL
     

       FROM %table:SF3% SF3
       LEFT JOIN %table:SA2% SA2 ON(SA2.A2_FILIAL = %xFilial:SA2% AND SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.%NotDel%)  
       WHERE SF3.F3_FILIAL = %xFilial:SF3%   
       AND   SF3.F3_CFO < '5' 
       AND   SF3.F3_TIPO = 'S'
       AND   SF3.F3_CODISS <> ''
       AND   SF3.F3_EMISSAO BETWEEN %EXP:dDataEmisDe% AND %EXP:dDataEmisAte%
       AND   SF3.%NotDel%

       ORDER BY F3_EMISSAO , F3_NFISCAL
   EndSql

 Return cAlias

//------------------------------------------------------------------
/*/{Protheus.doc} GravaTbDMS

    Função para gravação da tabela temporária com os registros que irão compôr o arquivo

/*/
//------------------------------------------------------------------
 function GravaTbDMS(cAliasDMS, oRegDms)
   If !(Select(cAliasDMS) > 0)
      CriaTbDMS(@cAliasDMS)
   EndIf
   
    //------------------------------
    //Inserção de dados para testes
    //------------------------------
    (cAliasDMS)->(DBAppend())
    (cAliasDMS)->EMISSAO    := DtoC(oRegDms:GetCmp1())
    (cAliasDMS)->NF         := oRegDms:GetCmp2()
    (cAliasDMS)->SERIE      := oRegDms:GetCmp3()
    (cAliasDMS)->ESPECIE    := oRegDms:GetCmp4()
    (cAliasDMS)->TPRECIMP   := oRegDms:GetCmp5()
    (cAliasDMS)->TPNF       := oRegDms:GetCmp6()
    (cAliasDMS)->ALIQISS    := oRegDms:GetCmp7()
    (cAliasDMS)->VALNF      := oRegDms:GetCmp8()
    (cAliasDMS)->BASECALC   := oRegDms:GetCmp9()
    (cAliasDMS)->VALORISS   := oRegDms:GetCmp10()
    (cAliasDMS)->CODSERV    := oRegDms:GetCmp11()
    (cAliasDMS)->TPFORN     := oRegDms:GetCmp12()
    (cAliasDMS)->CGCFORN    := oRegDms:GetCmp13()
    (cAliasDMS)->NOMEFORN   := oRegDms:GetCmp14()
    (cAliasDMS)->CEP        := oRegDms:GetCmp15()
    (cAliasDMS)->TPLOGRA    := oRegDms:GetCmp16()
    (cAliasDMS)->NOMELOGRA  := oRegDms:GetCmp17()
    (cAliasDMS)->NUMLOGRA   := oRegDms:GetCmp18()
    (cAliasDMS)->COMPLLOGR  := oRegDms:GetCmp19()
    (cAliasDMS)->BAIRRO     := oRegDms:GetCmp20()
    (cAliasDMS)->UFFORN     := oRegDms:GetCmp21()
    (cAliasDMS)->PAISFORN   := oRegDms:GetCmp22()
    (cAliasDMS)->CIDADE     := oRegDms:GetCmp23()
    (cAliasDMS)->RECISS     := oRegDms:GetCmp24()
    (cAliasDMS)->IEFORN     := oRegDms:GetCmp25()
    (cAliasDMS)->INSCRM     := oRegDms:GetCmp26()
    (cAliasDMS)->DDDFORN    := oRegDms:GetCmp27()
    (cAliasDMS)->TELFORN    := oRegDms:GetCmp28()
    (cAliasDMS)->CODMUNFORN := oRegDms:GetCmp29()
    (cAliasDMS)->(DBCommit())

 Return 

//------------------------------------------------------------------
/*/{Protheus.doc} GeraArqDMS
    (função para gravação do arquivo XML)

/*/
//------------------------------------------------------------------
 function GeraArqDMS(cAliasDMS, oParamArq)
    Local cLib     := ""
    Local cDirDest := ""
    Local nRetType := 0
    Local cArquivo := ""
    Local cXml     := ""
    Local lHtml    := .F.
    Local lAutomato := Iif(IsBlind(), .T., .F.)
    Local cDtComp := DTOS(oParamArq:GetDtIni())
    Local cDttrans := Substr(cDtComp,1,4)+'-'+Substr(cDtComp,5,2)+'-'+Substr(cDtComp,7,2)
    Local cTime := Time()
    Local nVlDedIss := 0
    Local oArquivo 


    nRetType := GetRemoteType(@cLib)
    
    If nRetType == 5 //"HTML" $ cLib
        lHtml := .T.
    EndIf

    If Substr(Alltrim(oParamArq:GetPath()), Len(Alltrim(oParamArq:GetPath())), 1) != "\"
	    oParamArq:SetPath(oParamArq:GetPath() + "\")
    EndIf

    If lHtml
        cDirDest := GetSrvProfString("startpath","")
    Else
        cDirDest := Alltrim(oParamArq:GetPath())
    EndIf

    cArquivo := cDirDest+oParamArq:GetArqName()
    oArquivo:= FWFILEWRITER():New(cArquivo)

    If  oArquivo:Exists()
        oArquivo:Erase()
    Endif

    If oArquivo:Create()
 
    //Cabeçalho do XML
    cXml := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
    cXml += '<declaracoes>' + CRLF
    cXml += '<lote versao="1.0">' + CRLF
    cXml += '<numeroLote>1</numeroLote>' + CRLF 
    cXml += '<dhTrans>'+cDttrans+' '+cTime+'</dhTrans>' + CRLF 
    cXml += '<imRemetente>'+Alltrim(SM0->M0_INSCM)+'</imRemetente>' + CRLF   
    cXml += '<imTomador>'+Alltrim(SM0->M0_INSCM)+'</imTomador>'  + CRLF     
    cXml += '<competencia>'+Substr(cDtcomp,1,6)+'</competencia>' + CRLF 
    cXml += '<servicosTomados>' + CRLF // TAG PAI que vai agrupar as notas de Serviços

    dbSelectArea(cAliasDMS)
    (cAliasDMS)->(dbGoTop())

    //Notas de Tomador
    While !(cAliasDMS)->(EoF())

    cXml += '<servicoTomado>' + CRLF

        cXml += '<prestador>' + CRLF

            If Alltrim((cAliasDMS)->UFFORN) == 'EX'

                cXml += '<nome>'+ALLTRIM((cAliasDMS)->NOMEFORN)+'</nome>' + CRLF

                If !Alltrim((cAliasDMS)->PAISFORN)== ""
                    cXml += '<pais>'+POSICIONE("CCH",1,xFilial("CCH")+(cAliasDMS)->PAISFORN,"CCH_PAIS")+'</pais>'+ CRLF
                Else
                    cXml += '<pais>EXTERIOR</pais>'+ CRLF
                Endif

            Else

                cXml += '<nome>'+ALLTRIM((cAliasDMS)->NOMEFORN)+'</nome>' + CRLF
                cXml += '<cpfCnpj>'+Alltrim((cAliasDMS)->CGCFORN)+'</cpfCnpj>' + CRLF
                cXml += '<codigoMunicipio>'+(cAliasDMS)->CODMUNFORN+'</codigoMunicipio>' + CRLF  
                cXml += '<nomeMunicipio>'+Alltrim((cAliasDMS)->CIDADE)+'</nomeMunicipio>' + CRLF
                cXml += '<uf>'+(cAliasDMS)->UFFORN+'</uf>' + CRLF
                cXml += '<pais>Brasil</pais>'+ CRLF

                //CAMPOS OPCIONAIS
                If !Alltrim((cAliasDMS)->IEFORN) == ""
                    cXml += '<inscricaoEstadual>'+Alltrim((cAliasDMS)->IEFORN)+'</inscricaoEstadual>' + CRLF
                Endif
                
                If !Alltrim((cAliasDMS)->INSCRM) == ""
                    cXml += '<inscricaoMunicipal>'+Alltrim((cAliasDMS)->INSCRM)+'</inscricaoMunicipal>' + CRLF
                Endif

                cXml += '<logradouro>'+Alltrim((cAliasDMS)->TPLOGRA)+' '+Alltrim(NoAcento((cAliasDMS)->NOMELOGRA))+'</logradouro>'+ CRLF
                
                If  !Alltrim((cAliasDMS)->NUMLOGRA)== ""
                    cXml += '<numeroLogradouro>'+Alltrim((cAliasDMS)->NUMLOGRA)+'</numeroLogradouro>' + CRLF
                Endif

                If !Alltrim((cAliasDMS)->COMPLLOGR) == ""
                    cXml += '<complementoLogradouro>'+Alltrim((cAliasDMS)->COMPLLOGR)+'</complementoLogradouro>' + CRLF
                EndIf
                
                If !Alltrim((cAliasDMS)->BAIRRO) == ""
                    cXml += '<bairro>'+Alltrim((cAliasDMS)->BAIRRO)+'</bairro>' + CRLF
                Endif

                If !Alltrim((cAliasDMS)->CEP) == ""
                cXml += '<cep>'+Alltrim((cAliasDMS)->CEP)+'</cep>' + CRLF
                Endif

                If !Alltrim((cAliasDMS)->DDDFORN) == ""
                    cXml += '<ddd>'+Alltrim((cAliasDMS)->DDDFORN)+'</ddd>' + CRLF
                Endif
                
                If !Alltrim((cAliasDMS)->TELFORN) == ""
                    cXml += '<fone>'+Alltrim((cAliasDMS)->TELFORN)+'</fone>' + CRLF
                Endif

            Endif


    cXml += '</prestador>' + CRLF

        cXml += '<documento>' + CRLF


            //----------------------------------------------------------------------------------------------------------
            /*/ 12/01/2023 - A tag serie só foi tratada quando a NFS for de origem da cidade de Caxias do SUL.
                Analisando o leaiute o cliente é responsavel por informar a serie correta no momento da inclusão da NF.
            /*/
            //----------------------------------------------------------------------------------------------------------
            If Alltrim((cAliasDMS)->ESPECIE) == "NFS" .and. (cAliasDMS)->CODMUNFORN == "4305108"
                cXml += '<especie>NFSE</especie>' + CRLF  
                cXml += '<serie>S</serie>' + CRLF
            Elseif Alltrim((cAliasDMS)->ESPECIE) == "NFS" 
                cXml += '<especie>NFE</especie>' + CRLF
                cXml += '<serie>'+Alltrim((cAliasDMS)->SERIE)+'</serie>' + CRLF
            Else
                cXml += '<especie>'+Alltrim((cAliasDMS)->ESPECIE)+'</especie>' + CRLF
                cXml += '<serie>'+Alltrim((cAliasDMS)->SERIE)+'</serie>' + CRLF  
            EndIf

            cXml += '<numero>'+(cAliasDMS)->NF+'</numero>' + CRLF
            cXml += '<dataEmissao>'+Substr((cAliasDMS)->EMISSAO,7,4)+'-'+Substr((cAliasDMS)->EMISSAO,4,2)+'-'+Substr((cAliasDMS)->EMISSAO,1,2)+'</dataEmissao>' + CRLF

            //--------------------------------------------------------------------------
            /*/ Para notas de tomador não tenho condições de trazer notas Canceladas,
                portanto o Status sempre será "N" de notas normais 
            /*/
            //--------------------------------------------------------------------------
            cXml += '<status>N</status>' + CRLF   

            cXml += '<codigoMunicipioTributacao>'+(cAliasDMS)->CODMUNFORN+'</codigoMunicipioTributacao>' + CRLF 

            //--------------------------------------------------------------------------
            /*/ De Acordo com o Manual:
                F= Fora Municipio
                M= Retido
                N= Não retido
            /*/
            //-------------------------------------------------------------------------
            If (cAliasDMS)->CODMUNFORN == "4305108" .and. (cAliasDMS)->VALORISS <> "0.00"
                cXml += '<tipoISS>M</tipoISS>' + CRLF 
            Elseif (cAliasDMS)->CODMUNFORN == "4305108" .and. (cAliasDMS)->VALORISS = "0.00" 
                cXml += '<tipoISS>N</tipoISS>' + CRLF 
            Else
                cXml += '<tipoISS>F</tipoISS>' + CRLF 
            Endif

        cXml += '</documento>' + CRLF

        cXml += '<totais>' + CRLF
            cXml += '<valorTotal>'+AllTrim((cAliasDMS)->VALNF)+'</valorTotal>' + CRLF

            If (cAliasDMS)->BASECALC <> "0.00" 
                nVlDedIss := Val((cAliasDMS)->VALNF) - Val((cAliasDMS)->BASECALC)
            Endif

            If nVlDedIss = 0
                cXml += '<valorDeducao>0.00</valorDeducao>'+ CRLF 
            else
                cXml += '<valorDeducao>'+AllTrim(StrTran(Transform(nVlDedIss,  "@E 999999999999.99"), ",", "."))+'</valorDeducao>' + CRLF 
            Endif

            //Caso o ISS seja não tributado, segundo validação da prefeitura preciso informar a base de calculo igual ao valor total da NF
            If (cAliasDMS)->BASECALC <> "0.00" 
                cXml += '<baseCalculo>'+Alltrim((cAliasDMS)->BASECALC)+'</baseCalculo>'+ CRLF
            else
                cXml += '<baseCalculo>'+AllTrim((cAliasDMS)->VALNF)+'</baseCalculo>'+ CRLF
            Endif

            cXml += '<aliquota>'+Alltrim((cAliasDMS)->ALIQISS)+'</aliquota>'+ CRLF
            cXml += '<valorISS>'+Alltrim((cAliasDMS)->VALORISS)+'</valorISS>'+ CRLF
        cXml += '</totais>' + CRLF

    cXml += '</servicoTomado>' + CRLF

    nVlDedIss := 0

    (cAliasDMS)->(DBSkip())
    End

    cXml += '</servicosTomados>' + CRLF 
    cXml += '</lote>' + CRLF
    cXml += '</declaracoes>'   + CRLF 

    oArquivo:Write( cXml )

    oArquivo:Close()

        If oArquivo:Exists()
            lOk := .T.
        Endif

    Else
        MsgInfo(oArquivo:Error():Message)
    Endif

    FreeObj( oArquivo )
    
    If !lAutomato
        MsgInfo(STR0009) // "Arquivo gerado com sucesso."
    EndIf


 Return

//------------------------------------------------------------------
/*/{Protheus.doc} GeraArqSMV
    função para gravação do arquivo XML sem Movimento

/*/
//------------------------------------------------------------------
Function GeraArqSMV(oParamArq)

    Local cLib     := ""
    Local cDirDest := ""
    Local nRetType := 0
    Local cArquivo := ""
    Local cXml     := ""
    Local lHtml    := .F.
    Local lAutomato := Iif(IsBlind(), .T., .F.)
    Local cDtComp := DTOS(oParamArq:GetDtIni())
    Local cDttrans := Substr(cDtComp,1,4)+'-'+Substr(cDtComp,5,2)+'-'+Substr(cDtComp,7,2)
    Local cTime := Time()
    Local oArquivo 
   


    nRetType := GetRemoteType(@cLib)
    
    If nRetType == 5 //"HTML" $ cLib
        lHtml := .T.
    EndIf

    If Substr(Alltrim(oParamArq:GetPath()), Len(Alltrim(oParamArq:GetPath())), 1) != "\"
	    oParamArq:SetPath(oParamArq:GetPath() + "\")
    EndIf

    If lHtml
        cDirDest := GetSrvProfString("startpath","")
    Else
        cDirDest := Alltrim(oParamArq:GetPath())
    EndIf

    cArquivo := cDirDest+oParamArq:GetArqName()

    oArquivo:= FWFILEWRITER():New(cArquivo)

    If  oArquivo:Exists()
        oArquivo:Erase()
    Endif

    If oArquivo:Create()
    cXml := '<?xml version="1.0" encoding="utf-8"?>' + CRLF
    cXml += '<declaracoes>' + CRLF
    cXml += '<lote versao="1.0">' + CRLF
    cXml += '<numeroLote>1</numeroLote>' + CRLF
    cXml += '<dhTrans>'+cDttrans+' '+cTime+'</dhTrans>' + CRLF
    cXml += '<imRemetente>'+Alltrim(SM0->M0_INSCM)+'</imRemetente>' + CRLF
    cXml += '<imTomador>'+Alltrim(SM0->M0_INSCM)+'</imTomador>' + CRLF
    cXml += '<competencia>'+Substr(cDtcomp,1,6)+'</competencia>' + CRLF
    cXml += '<servicosTomados>' + CRLF
    cXml += '<dmsSemMovimento/>' + CRLF
    cXml += '</servicosTomados>' + CRLF
    cXml += '</lote>' + CRLF
    cXml += '</declaracoes>' + CRLF

    oArquivo:Write( cXml )

    oArquivo:Close()

        If oArquivo:Exists()
            lOk := .T.
        Endif

    Else
        MsgInfo(oArquivo:Error():Message)
    Endif

    FreeObj( oArquivo )
        
    If !lAutomato
        MsgInfo("Arquivo gerado com sucesso.") 
    EndIf

Return

//------------------------------------------------------------------
 /*/{Protheus.doc} CriaTbDMS
    (função para criação da tabela temporária)

/*/
//------------------------------------------------------------------
 function CriaTbDMS(cAliasDMS)
   Static oTbDms        as object

   local  aFields       as array
   local  nConnect      as numeric
   local  lCloseConnect as logical
   
   //--------------------------------------------------------------------------
   //Esse bloco efetua a conexão com o DBAccess caso a mesma ainda não exista
   //--------------------------------------------------------------------------
   If TCIsConnected()
       nConnect := TCGetConn()
       lCloseConnect := .F.
   Else
       nConnect := TCLink()
       lCloseConnect := .T.
   Endif
   
   //-------------------------------------------------------------------------------------------
   //Só podemos continuar com a geração da tabela temporária caso exista conexão com o DBAccess
   //-------------------------------------------------------------------------------------------
   If nConnect >= 0
       //--------------------------------------------------------------------
       //O primeiro parâmetro de alias, possui valor default
       //O segundo parâmetro de campos, pode ser atribuido após o construtor
       //--------------------------------------------------------------------
       oTbDms:= FWTemporaryTable():New( cAliasDMS /*, aFields*/)
   
       //----------------------------------------------------
       //O array de campos segue o mesmo padrão do DBCreate:
       //1 - C - Nome do campo
       //2 - C - Tipo do campo
       //3 - N - Tamanho do campo
       //4 - N - Decimal do campo
       //----------------------------------------------------
       aFields := {}
   
       aAdd(aFields, {"EMISSAO"     , "C",   10, 0}) // 1
       aAdd(aFields, {"NF"          , "C",    9, 0}) // 2
       aAdd(aFields, {"SERIE"       , "C",    5, 0}) // 3
       aAdd(aFields, {"ESPECIE"     , "C",    5, 0}) // 4
       aAdd(aFields, {"TPRECIMP"    , "C",    1, 0}) // 5
       aAdd(aFields, {"TPNF"        , "C",    1, 0}) // 6
       aAdd(aFields, {"ALIQISS"     , "C",   15, 0}) // 7
       aAdd(aFields, {"VALNF"       , "C",   15, 0}) // 8
       aAdd(aFields, {"BASECALC"    , "C",   15, 0}) // 9
       aAdd(aFields, {"VALORISS"    , "C",   15, 0}) // 10
       aAdd(aFields, {"CODSERV"     , "C",    7, 0}) // 11
       aAdd(aFields, {"TPFORN"      , "C",    1, 0}) // 12
       aAdd(aFields, {"CGCFORN"     , "C",   14, 0}) // 13
       aAdd(aFields, {"NOMEFORN"    , "C",  150, 0}) // 14
       aAdd(aFields, {"CEP"         , "C",    8, 0}) // 15
       aAdd(aFields, {"TPLOGRA"     , "C",   25, 0}) // 16
       aAdd(aFields, {"NOMELOGRA"   , "C",   50, 0}) // 17
       aAdd(aFields, {"NUMLOGRA"    , "C",   10, 0}) // 18
       aAdd(aFields, {"COMPLLOGR"   , "C",   60, 0}) // 19
       aAdd(aFields, {"BAIRRO"      , "C",   60, 0}) // 20
       aAdd(aFields, {"UFFORN"      , "C",    2, 0}) // 21
       aAdd(aFields, {"PAISFORN"    , "C",    5, 0}) // 22
       aAdd(aFields, {"CIDADE"      , "C",   50, 0}) // 23
       aAdd(aFields, {"RECISS"      , "C",    5, 0}) // 24
       aAdd(aFields, {"IEFORN"      , "C",   15, 0}) // 25
       aAdd(aFields, {"INSCRM"      , "C",   15, 0}) // 26
       aAdd(aFields, {"DDDFORN"     , "C",    5, 0}) // 27
       aAdd(aFields, {"TELFORN"     , "C",   10, 0}) // 28
       aAdd(aFields, {"CODMUNFORN"  , "C",    7, 0}) // 29
       
   
       oTbDms:SetFields(aFields)
   
       //---------------------
       //Criação dos índices
       //---------------------
       oTbDms:AddIndex("01", {"NF", "SERIE"} )
   
       //---------------------------------------------------------------
       //Pronto, agora temos a tabela criado no espaço temporário do DB
       //---------------------------------------------------------------
       oTbDms:Create()

   Endif

 Return

 /*/{Protheus.doc} fBuscSX5UF
    (função para retornar o nome da UF de acordo com a sigla passada)
    @type  Function
    @author eduardo.vicente
    @since 09/12/2020
    @version 1.0
    @param cUF, String, Sigla da UF
    @return cEstado, String, Nome da UF
    @example
    (função para retornar o nome da UF de acordo com a sigla passada)
    @see (links_or_references)
    /*/
static function fBuscSX5UF(cUF)
   Local cEstado := ""
   Local cChave  := xFilial('SX5')+'12'

   Default cUF   := ""
   
   If !Empty(cUF)
       If SX5->(Dbseek(cChave+cUF))
           cEstado := X5DESCRI()
       EndIf
   EndIf
 Return cEstado

 /*/{Protheus.doc} fTrtEnd
    (Trata o endereço separando tipo de logradouro,logradouro, número e se houver complemento separar também.)
    @type  Function
    @author eduardo.vicente
    @since 10/12/2020
    @version 1.0
    @param cEnd, String, Endereço completo com logradouro e número
    @return aResult, Array, Contém o tipo do logradouro, nome do logradouro, número e complemento do endereço separados.
    @example
    (Trata o endereço separando tipo de logradouro,logradouro, número e se houver complemento separar também.)
    @see (links_or_references)
    /*/
Static function fTrtEnd(cEnd)
    Local aResult	  := {"","","",""}//TIPO DE LOGRADOURO,LOGRADOURO,NUMERO E COMPLEMENTO
    Local cWord     := ""
    Local cTxt      := ""
    Local cPoint    := ",|:|;|=|-|/|\"
    Local nLastWord := 1
    Local nStepWord := 1
    Local lEnd      := .F.
    Local lNum      := .F.
    Local lTplog    := .F.
    Local lLogr     := .F.
    Local lCompl    := .F.
    
    Default cEnd    := ""
    
    cEnd    := IIF(!Empty(cEnd),Upper(ALLTRIM(cEnd)),"") //CONVERT PRA CAIXA ALTA
    
    While !lEnd .And. !KillApp() .And. !Empty(cEnd)
        cWord   := Substr(cEnd,nLastWord,nStepWord)
        
        If nLastWord > Len(cEnd)
            lEnd    := .T.
        EndIf 
        
        If !Empty(cWord) .And. !(cWord $ cPoint) .And. !lEnd
            cTxt    += cWord
        Else
            If !(cTxt $ cPoint) .And. nLastWord-1 <= Len(cEnd)
                fTrfValArray(@lNum,@lTpLog,@llogr,@lCompl,cTxt,IsDigit(cTxt),IsAlpha(cTxt),@aResult)
            EndIf
            cTxt:= ""
        EndIf
        nLastWord++
       
    EndDo

Return aResult

 /*/{Protheus.doc} fTrfValArray
    (Controle para inclusão de valores separados dentro da variável de controle, onde serão armazenados os números separados.)
    @type  Function
    @author eduardo.vicente
    @since 10/12/2020
    @version 1.0
    @param cEnd, String, Endereço completo com logradouro e número
    @return lRet, Boolean, Contém o tipo do logradouro, nome do logradouro, número e complemento do endereço separados.
    @example
    (Controle para inclusão de valores separados dentro da variável de controle, onde serão armazenados os números separados.)
    @see (links_or_references)
    /*/
Static function fTrfValArray(lNum,lTpLog,llogr,lCompl,cTxt,lNumeric,lText,aResult)

  Local lRet       := .T.
 
  Default lNum     := .F.
  Default lTpLog   := .F.
  Default llogr    := .F.
  Default lCompl   := .F.
  Default lNumeric := .F.
  Default lText    := .F.
  Default cTxt     := ""
  Default aResult  := {"","","",""}//TIPO DE LOGRADOURO,LOGRADOURO,NUMERO E COMPLEMENTO

  If lNumeric
      aResult[3]  := cTxt
      lNum        := .T.
  EndIf

  If lText
      If lTpLog .And.!lNum 
         aResult[2] += cTxt + " " 
      Endif

      If !lTpLog 
         aResult[1] := cTxt
         lTpLog:= .T.
      Endif

      If lTpLog .And. lNum
          aResult[4] += cTxt + " " 
      EndIf
  EndIf

Return lRet

//------------------------------------------------------------------
 /*/{Protheus.doc} FISA307DIR
    
        Função para adicionar a tela de procura de pasta para o campo do pergunte de diretório

 /*/
//------------------------------------------------------------------
function FISA307DIR()
Local _mvRet  := Alltrim(ReadVar())
Local _cPath  := mv_par03
Local tmp := getTempPath()

_oWnd := GetWndDefault()

_cPath:= tFileDialog( "All files (*.*) | All Text files (*.txt) ",'Selecao de Arquivos',, tmp, .F., GETF_RETDIRECTORY )

&_mvRet := _cPath

If _oWnd != Nil
	GetdRefresh()
EndIf

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} LimpOTbDms
    
    Função para efetuar limpeza no objeto da FWTemporary table que contém as informações da tabela com os registros.

/*/
//------------------------------------------------------------------
function LimpOTbDms()
    If Type("oTbDms") != "U"
        oTbDms:Delete()
        FreeObj(oTbDms)
    EndIf
Return
