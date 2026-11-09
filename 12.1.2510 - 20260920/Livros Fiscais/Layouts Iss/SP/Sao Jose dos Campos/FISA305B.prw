#include "protheus.ch"
#include "fisa305.ch"

Static aParamMd  := &(GetNewPar("MV_CRTMDNT", '{}')) //Parâmetros de configuração da rotina

/*/{Protheus.doc} QuerySJC
    (Função para busca dos registros que irão compôr o arquivo)
    @type  Function
    @author pereira.weslley
    @since 04/12/2020
    @version 1.0
    @param oParamArq, SJCGEN, Objeto com as informações do Pergunte da rotina
    @return cAlias, String, Alias com o retorno da query
    @example
    (Função para busca dos registros que irão compôr o arquivo)
    @see (links_or_references)
    /*/
 function QuerySJC(oParamArq, cAlias)
   Local dDataEmisDe  := oParamArq:GetDtIni()
   Local dDataEmisAte := oParamArq:GetDtFim()
   
   BeginSql Alias cAlias
       COLUMN F3_EMISSAO AS DATE
       COLUMN F3_DTCANC  AS DATE
       COLUMN DTCOMPE    AS DATE

       SELECT  SF3.F3_EMISSAO,
               SF3.F3_NFISCAL,
               SF3.F3_SERIE,
               SF3.F3_ESPECIE,
               SF3.F3_CNAE,
               SF3.F3_VALICM,
               SF3.F3_RECISS,
               SF3.F3_CLIEFOR,
               SF3.F3_TIPO,
               SF3.F3_CFO,
               SF3.F3_ALIQICM,
               SF3.F3_VALCONT,
               SF3.F3_BASEICM,
               SF3.F3_DTCANC,
               SF3.F3_ISENICM,
               SF3.F3_OUTRICM,
               SF3.F3_VALICM,
               SF3.F3_CODISS,

               SF1.F1_DTCPISS DTCOMPE,
               SF1.F1_DESCONT DESCONT,
               SF1.F1_VALPIS VALPIS,
               SF1.F1_VALCOFI VALCOFI,
               SF1.F1_INSS VALINSS,
               SF1.F1_VALIRF VALIRRF,
               SF1.F1_VALCSLL VALCSLL,

               SA2.A2_TIPO TIPO,
               SA2.A2_CGC CGC,
               SA2.A2_PFISICA,
               SA2.A2_NOME NOME,
               SA2.A2_COD_MUN CODMUN,
               SA2.A2_SIMPNAC,
               SA2.A2_TPJ,
               SA2.A2_CEP CEP,
               SA2.A2_END ENDERECO,
               SA2.A2_COMPLEM COMPLEMENTO,
               SA2.A2_BAIRRO BAIRRO,
               SA2.A2_EST ESTADO,
               SA2.A2_PAIS PAIS,
               SA2.A2_MUN MUNICIPIO,
               SA2.A2_COMPLEM,
               SA2.A2_CODPAIS,
               SA2.A2_RECISS,

               SF4.F4_ISSST,
               SF4.F4_RETISS,
               SF4.F4_DESCOND,
               SF4.F4_MTRTBH,
               
               SB1.B1_DESC,

               SD1.D1_DESCICM

       FROM %table:SF3% SF3
       LEFT JOIN %table:SA2% SA2 ON(SA2.A2_FILIAL = %xFilial:SA2% AND SA2.A2_COD = SF3.F3_CLIEFOR AND SA2.A2_LOJA = SF3.F3_LOJA AND SA2.%NotDel%)    
       LEFT JOIN %table:SF1% SF1 ON(SF1.F1_FILIAL = %xFilial:SF1% AND SF1.F1_FORNECE = SF3.F3_CLIEFOR AND SF1.F1_LOJA = SF3.F3_LOJA AND SF1.F1_DOC = SF3.F3_NFISCAL AND SF1.F1_SERIE = SF3.F3_SERIE AND SF1.F1_ESPECIE = SF3.F3_ESPECIE AND SF1.%NotDel%) 
       LEFT JOIN %table:SD1% SD1 ON(SD1.D1_FILIAL = %xFilial:SD1% AND SD1.D1_DOC = SF3.F3_NFISCAL AND SD1.D1_SERIE = SF3.F3_SERIE AND SD1.D1_FORNECE = SF3.F3_CLIEFOR AND SD1.D1_LOJA = SF3.F3_LOJA AND SD1.%NotDel%)
       LEFT JOIN %table:SF4% SF4 ON(SF4.F4_FILIAL = %xFilial:SF4% AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.%NotDel%)
       LEFT JOIN %table:SB1% SB1 ON(SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SD1.D1_COD AND SB1.%NotDel%)

       WHERE SF3.F3_FILIAL = %xFilial:SF3%   
       AND   SF3.F3_CFO < '5' 
       AND   SF3.F3_TIPO NOT IN ('D','B') 
       AND   SF3.F3_RECISS <> ''
       AND   SF3.F3_TIPO = 'S'
       AND   SF3.F3_CODISS <> ''
       AND   SF3.F3_EMISSAO BETWEEN %EXP:dDataEmisDe% AND %EXP:dDataEmisAte%
       AND   SF3.%NotDel%
   EndSql

 Return cAlias

/*/{Protheus.doc} GravaTbSJC
    (Função para gravação da tabela temporária com os registros que irão compôr o arquivo)
    @type  Function
    @author pereira.weslley
    @since 04/12/2020
    @version 1.0
    @param cAliasSJC, String, Alias da tabela temporária com os Registros T
    @param oRegT, REGT, Registro T à ser inserido na tabela temporária
    @return Nil
    @example
    (Função para gravação da tabela temporária com os registros T que irão compôr o arquivo)
    @see (links_or_references)
    /*/
 function GravaTbSJC(cAliasSJC, oRegT)
   If !(Select(cAliasSJC) > 0)
      CriaTbSJC(@cAliasSJC)
   EndIf
   
    //------------------------------
    //Inserção de dados para testes
    //------------------------------
    (cAliasSJC)->(DBAppend())
    (cAliasSJC)->INDENTIFIC := oRegT:GetCmp1()
    (cAliasSJC)->DATAEMISSA := DtoC(oRegT:GetCmp2())
    (cAliasSJC)->DATACOMPET := oRegT:GetCmp3()
    (cAliasSJC)->NOTAFISCAL := oRegT:GetCmp4()
    (cAliasSJC)->SERIENOTA  := oRegT:GetCmp5()
    (cAliasSJC)->MODELONOTA := oRegT:GetCmp6()
    (cAliasSJC)->TIPOFORNEC := oRegT:GetCmp7()
    (cAliasSJC)->CGCFORNEC  := oRegT:GetCmp8()
    (cAliasSJC)->CGCEXFORNE := oRegT:GetCmp9()
    (cAliasSJC)->NOMEFORNEC := oRegT:GetCmp10()
    (cAliasSJC)->CODMUNFORN := oRegT:GetCmp11()
    (cAliasSJC)->FORNSIMNAC := oRegT:GetCmp12()
    (cAliasSJC)->FORNECMEI  := oRegT:GetCmp13()
    (cAliasSJC)->FORNESTMUN := oRegT:GetCmp14()
    (cAliasSJC)->CEPFORNEC  := oRegT:GetCmp15()
    (cAliasSJC)->TPLOGRAFOR := oRegT:GetCmp16()
    (cAliasSJC)->NOMELOGRAF := oRegT:GetCmp17()
    (cAliasSJC)->NUMLOGRAF  := oRegT:GetCmp18()
    (cAliasSJC)->COMPLLOGRF := oRegT:GetCmp19()
    (cAliasSJC)->BAIRROFORN := oRegT:GetCmp20()
    (cAliasSJC)->UFFORNEC   := oRegT:GetCmp21()
    (cAliasSJC)->PAISFORNEC := oRegT:GetCmp22()
    (cAliasSJC)->CIDADEFORN := oRegT:GetCmp23()
    (cAliasSJC)->CODSERV    := oRegT:GetCmp24()
    (cAliasSJC)->CNAE       := oRegT:GetCmp25()
    (cAliasSJC)->CODOBRA    := oRegT:GetCmp26()
    (cAliasSJC)->LOCALPREST := oRegT:GetCmp27()
    (cAliasSJC)->CDMUNLOCPR := oRegT:GetCmp28()
    (cAliasSJC)->UFLOCPREST := oRegT:GetCmp29()
    (cAliasSJC)->MUNEXPREST := oRegT:GetCmp30()
    (cAliasSJC)->UFEXLOCPRE := oRegT:GetCmp31()
    (cAliasSJC)->PAISLOCPRE := oRegT:GetCmp32()
    (cAliasSJC)->LOCRESUPRE := oRegT:GetCmp33()
    (cAliasSJC)->CDMUNRESPR := oRegT:GetCmp34()
    (cAliasSJC)->UFRESULPRE := oRegT:GetCmp35()
    (cAliasSJC)->MUNEXRESPR := oRegT:GetCmp36()
    (cAliasSJC)->ESTEXRESPR := oRegT:GetCmp37()
    (cAliasSJC)->PAISRESPRE := oRegT:GetCmp38()
    (cAliasSJC)->MOTNAORET  := oRegT:GetCmp39()
    (cAliasSJC)->EXIGIISS   := oRegT:GetCmp40()
    (cAliasSJC)->TPRECIMP   := oRegT:GetCmp41()
    (cAliasSJC)->ALIQISS    := oRegT:GetCmp42()
    (cAliasSJC)->VALSERV    := oRegT:GetCmp43()
    (cAliasSJC)->VALDED     := oRegT:GetCmp44()
    (cAliasSJC)->DESCINCOND := oRegT:GetCmp45()
    (cAliasSJC)->DESCCOND   := oRegT:GetCmp46()
    (cAliasSJC)->BASECALC   := oRegT:GetCmp47()
    (cAliasSJC)->VALPIS     := oRegT:GetCmp48()
    (cAliasSJC)->VALCOF     := oRegT:GetCmp49()
    (cAliasSJC)->VALINSS    := oRegT:GetCmp50()
    (cAliasSJC)->VALIR      := oRegT:GetCmp51()
    (cAliasSJC)->VALCSLL    := oRegT:GetCmp52()
    (cAliasSJC)->OUTRASRET  := oRegT:GetCmp53()
    (cAliasSJC)->VALISS     := oRegT:GetCmp54()
    (cAliasSJC)->DESCSERV   := oRegT:GetCmp55()
    (cAliasSJC)->(DBCommit())

 Return 

/*/{Protheus.doc} GeraArqSJC
    (função para gravação do arquivo texto)
    @type  Function
    @author pereira.weslley
    @since 04/12/2020
    @version 1.0
    @param cAliasSJC, String, Alias da tabela temporária com os registros T
    @return Nil
    @example
    (função para gravação do arquivo texto)
    @see (links_or_references)
    /*/
 function GeraArqSJC(cAliasSJC, oParamArq)
    Local cLib     := ""
    Local cDirDest := ""
    Local nRetType := 0
    Local nHandle  := 0
    Local cArquivo := ""
    Local cLinha   := ""
    Local nRet     := 0
    Local lHtml    := .F.
    Local oRegH    := REGH():New()
    Local lAutomato := Iif(IsBlind(), .T., .F.)

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

    cArquivo := cDirDest+oParamArq:GetArcName()
    nHandle := fCreate(cArquivo)

    If nHandle = -1 .And. !lAutomato
        Alert(STR0004 + Str(Ferror())) //'Erro ao criar arquivo:'
    EndIf

    cLinha := oRegH:GetCmp1() +;
              Alltrim(oRegH:GetCmp2()) +;
              Chr(13)         +;
              Chr(10)

    FWrite(nHAndle,cLinha)

    dbSelectArea(cAliasSJC)
    (cAliasSJC)->(dbGoTop())

    While !(cAliasSJC)->(EoF())
        cLinha := (cAliasSJC)->INDENTIFIC +;
                  (cAliasSJC)->DATAEMISSA +;
                  (cAliasSJC)->DATACOMPET +;
                  (cAliasSJC)->NOTAFISCAL +;
                  (cAliasSJC)->SERIENOTA  +;
                  (cAliasSJC)->MODELONOTA +;
                  (cAliasSJC)->TIPOFORNEC +;
                  (cAliasSJC)->CGCFORNEC  +;
                  (cAliasSJC)->CGCEXFORNE +;
                  (cAliasSJC)->NOMEFORNEC +;
                  (cAliasSJC)->CODMUNFORN +;
                  (cAliasSJC)->FORNSIMNAC +;
                  (cAliasSJC)->FORNECMEI  +;
                  (cAliasSJC)->FORNESTMUN +;
                  (cAliasSJC)->CEPFORNEC  +;
                  (cAliasSJC)->TPLOGRAFOR +;
                  (cAliasSJC)->NOMELOGRAF +;
                  (cAliasSJC)->NUMLOGRAF  +;
                  (cAliasSJC)->COMPLLOGRF +;
                  (cAliasSJC)->BAIRROFORN +;
                  (cAliasSJC)->UFFORNEC   +;
                  (cAliasSJC)->PAISFORNEC +;
                  (cAliasSJC)->CIDADEFORN +;
                  (cAliasSJC)->CODSERV    +;
                  (cAliasSJC)->CNAE       +;
                  (cAliasSJC)->CODOBRA    +;
                  (cAliasSJC)->LOCALPREST +;
                  (cAliasSJC)->CDMUNLOCPR +;
                  (cAliasSJC)->UFLOCPREST +;
                  (cAliasSJC)->MUNEXPREST +;
                  (cAliasSJC)->UFEXLOCPRE +;
                  (cAliasSJC)->PAISLOCPRE +;
                  (cAliasSJC)->LOCRESUPRE +;
                  (cAliasSJC)->CDMUNRESPR +;
                  (cAliasSJC)->UFRESULPRE +;
                  (cAliasSJC)->MUNEXRESPR +;
                  (cAliasSJC)->ESTEXRESPR +;
                  (cAliasSJC)->PAISRESPRE +;
                  (cAliasSJC)->MOTNAORET  +;
                  (cAliasSJC)->EXIGIISS   +;
                  (cAliasSJC)->TPRECIMP   +;
                  (cAliasSJC)->ALIQISS    +;
                  (cAliasSJC)->VALSERV    +;
                  (cAliasSJC)->VALDED     +;
                  (cAliasSJC)->DESCINCOND +;
                  (cAliasSJC)->DESCCOND   +;
                  (cAliasSJC)->BASECALC   +;
                  (cAliasSJC)->VALPIS     +;
                  (cAliasSJC)->VALCOF     +;
                  (cAliasSJC)->VALINSS    +;
                  (cAliasSJC)->VALIR      +;
                  (cAliasSJC)->VALCSLL    +;
                  (cAliasSJC)->OUTRASRET  +;
                  (cAliasSJC)->VALISS     +;
                  (cAliasSJC)->DESCSERV   +;
                  Chr(13)                 +;
                  Chr(10)

        FWrite(nHAndle,cLinha)

        (cAliasSJC)->(DBSkip())
    End

    If !lAutomato
        Alert(STR0009) // "Arquivo gerado com sucesso."
    EndIf

    FClose(nHandle)

    If lHtml
        nRet := CPYS2TW(cArquivo,.T.)

        If nRet == 0
            FErase(cArquivo)
        EndIf
    EndIf

 Return

 /*/{Protheus.doc} CriaTbSJC
    (função para criação da tabela temporária)
    @type  Function
    @author pereira.weslley
    @since 04/12/2020
    @version 1.0
    @param cAliasSJC, String, Alias da tabela temporária com os registros T
    @return Nil
    @example
    (função para criação da tabela temporária)
    @see (links_or_references)
    /*/
 function CriaTbSJC(cAliasSJC)
   Static oTbSJC        as object

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
       oTbSJC := FWTemporaryTable():New( cAliasSJC /*, aFields*/)
   
       //----------------------------------------------------
       //O array de campos segue o mesmo padrão do DBCreate:
       //1 - C - Nome do campo
       //2 - C - Tipo do campo
       //3 - N - Tamanho do campo
       //4 - N - Decimal do campo
       //----------------------------------------------------
       aFields := {}
   
       aAdd(aFields, {"INDENTIFIC", "C",    1, 0}) // 1
       aAdd(aFields, {"DATAEMISSA", "C",   10, 0}) // 2
       aAdd(aFields, {"DATACOMPET", "C",    7, 0}) // 3
       aAdd(aFields, {"NOTAFISCAL", "C",   15, 0}) // 4
       aAdd(aFields, {"SERIENOTA" , "C",    5, 0}) // 5
       aAdd(aFields, {"MODELONOTA", "C",    2, 0}) // 6
       aAdd(aFields, {"TIPOFORNEC", "C",    1, 0}) // 7
       aAdd(aFields, {"CGCFORNEC" , "C",   14, 0}) // 8
       aAdd(aFields, {"CGCEXFORNE", "C",   20, 0}) // 9
       aAdd(aFields, {"NOMEFORNEC", "C",  150, 0}) // 10
       aAdd(aFields, {"CODMUNFORN", "C",    7, 0}) // 11
       aAdd(aFields, {"FORNSIMNAC", "C",    1, 0}) // 12
       aAdd(aFields, {"FORNECMEI" , "C",    1, 0}) // 13
       aAdd(aFields, {"FORNESTMUN", "C",    1, 0}) // 14
       aAdd(aFields, {"CEPFORNEC" , "C",    8, 0}) // 15
       aAdd(aFields, {"TPLOGRAFOR", "C",   25, 0}) // 16
       aAdd(aFields, {"NOMELOGRAF", "C",   50, 0}) // 17
       aAdd(aFields, {"NUMLOGRAF" , "C",   10, 0}) // 18
       aAdd(aFields, {"COMPLLOGRF", "C",   60, 0}) // 19
       aAdd(aFields, {"BAIRROFORN", "C",   60, 0}) // 20
       aAdd(aFields, {"UFFORNEC"  , "C",    2, 0}) // 21
       aAdd(aFields, {"PAISFORNEC", "C",    4, 0}) // 22
       aAdd(aFields, {"CIDADEFORN", "C",   50, 0}) // 23
       aAdd(aFields, {"CODSERV"   , "C",    5, 0}) // 24
       aAdd(aFields, {"CNAE"      , "C",    9, 0}) // 25
       aAdd(aFields, {"CODOBRA"   , "C",   15, 0}) // 26
       aAdd(aFields, {"LOCALPREST", "C",    3, 0}) // 27
       aAdd(aFields, {"CDMUNLOCPR", "C",    7, 0}) // 28
       aAdd(aFields, {"UFLOCPREST", "C",    2, 0}) // 29
       aAdd(aFields, {"MUNEXPREST", "C",   50, 0}) // 30
       aAdd(aFields, {"UFEXLOCPRE", "C",   50, 0}) // 31
       aAdd(aFields, {"PAISLOCPRE", "C",    4, 0}) // 32
       aAdd(aFields, {"LOCRESUPRE", "C",    3, 0}) // 33
       aAdd(aFields, {"CDMUNRESPR", "C",    7, 0}) // 34
       aAdd(aFields, {"UFRESULPRE", "C",    2, 0}) // 35
       aAdd(aFields, {"MUNEXRESPR", "C",   50, 0}) // 36
       aAdd(aFields, {"ESTEXRESPR", "C",   50, 0}) // 37
       aAdd(aFields, {"PAISRESPRE", "C",    4, 0}) // 38
       aAdd(aFields, {"MOTNAORET" , "C",    1, 0}) // 39
       aAdd(aFields, {"EXIGIISS"  , "C",    1, 0}) // 40
       aAdd(aFields, {"TPRECIMP"  , "C",    3, 0}) // 41
       aAdd(aFields, {"ALIQISS"   , "C",    5, 0}) // 42
       aAdd(aFields, {"VALSERV"   , "C",   15, 0}) // 43
       aAdd(aFields, {"VALDED"    , "C",   15, 0}) // 44
       aAdd(aFields, {"DESCINCOND", "C",   15, 0}) // 45
       aAdd(aFields, {"DESCCOND"  , "C",   15, 0}) // 46
       aAdd(aFields, {"BASECALC"  , "C",   15, 0}) // 47
       aAdd(aFields, {"VALPIS"    , "C",   15, 0}) // 48
       aAdd(aFields, {"VALCOF"    , "C",   15, 0}) // 49
       aAdd(aFields, {"VALINSS"   , "C",   15, 0}) // 50
       aAdd(aFields, {"VALIR"     , "C",   15, 0}) // 51
       aAdd(aFields, {"VALCSLL"   , "C",   15, 0}) // 52
       aAdd(aFields, {"OUTRASRET" , "C",   15, 0}) // 53
       aAdd(aFields, {"VALISS"    , "C",   15, 0}) // 54
       aAdd(aFields, {"DESCSERV"  , "C", 2000, 0}) // 55
   
       oTbSJC:SetFields(aFields)
   
       //---------------------
       //Criação dos índices
       //---------------------
       oTbSJC:AddIndex("01", {"NOTAFISCAL", "SERIENOTA"} )
   
       //---------------------------------------------------------------
       //Pronto, agora temos a tabela criado no espaço temporário do DB
       //---------------------------------------------------------------
       oTbSJC:Create()

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
 function fBuscSX5UF(cUF)
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
function fTrtEnd(cEnd)
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

 /*/{Protheus.doc} FISA305DIR
    (Função para adicionar a tela de procura de pasta para o campo do pergunte de diretório)
    @type  Function
    @author pereira.weslley
    @since 11/12/2020
    @version 1.0
    @param Nil
    @return .T.
    @example
    (Função para adicionar a tela de procura de pasta para o campo do pergunte de diretório)
    @see (links_or_references)
    /*/
function FISA305DIR()
Local _mvRet  := Alltrim(ReadVar())
Local _cPath  := mv_par03

_oWnd := GetWndDefault()

_cPath:=cGetFile(OemtoAnsi("Arquivos para Pesquisa"),OemToAnsi("Selecione o Diretorio"),0,,.F.,GETF_RETDIRECTORY+GETF_LOCALFLOPPY+GETF_LOCALHARD)

&_mvRet := _cPath

If _oWnd != Nil
	GetdRefresh()
EndIf

Return .T.

 /*/{Protheus.doc} CrtMod
    (Função para definir qual o modelo de documento de acordo com a espécie como solicita o layout)
    @type  Function
    @author pereira.weslley
    @since 15/12/2020
    @version 1.0
    @param cEspecie, String, Contém a espécie do documento.
    @return cReturn, String, Contém o modelo do documento de acordo com o layout
    @example
    (Função para definir qual o modelo de documento de acordo com a espécie como solicita o layout)
    @see (links_or_references)
    /*/
function CrtMod(cEspecie)
Local cReturn  := ''
Local nX := 0

If ValType(aParamMd) == "A"
   If (nX := aScan(aParamMd, {|x| Alltrim(x[1]) == cEspecie})) != 0
    cReturn := aParamMd[nX][2]
   EndIf
EndIf

If Empty(cReturn)
    Do Case
        Case cEspecie == 'NFS'
            cReturn := 'A '
        Case cEspecie $ 'ECF|ESAT'
            cReturn := 'F '
        Case cEspecie == 'RPS'
            cReturn := 'RP'
        Case cEspecie == 'OT'
            cReturn := 'OT'
        Case cEspecie == 'OM'
            cReturn := 'OM'
    EndCase
EndIf

Return cReturn

 /*/{Protheus.doc} LimpOTBSJC
    (Função para efetuar limpeza no objeto da FWTemporary table que contém as informações da tabela com os registros)
    @type  Function
    @author pereira.weslley
    @since 23/12/2020
    @version 1.0
    @param Nil
    @return Nil
    @example
    (Função para efetuar limpeza no objeto da FWTemporary table que contém as informações da tabela com os registros)
    @see (links_or_references)
    /*/
function LimpOTBSJC()
    If Type("OTBSJC") != "U"
        oTbSJC:Delete()
        FreeObj(oTbSJC)
    EndIf
Return
