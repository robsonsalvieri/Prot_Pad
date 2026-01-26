#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "ArrayfunC.CH"
#INCLUDE "RMIXFUNC.CH"

Static aWsdl        := {}		 // Carrega os objetos TWsdlManager ja utilizados para performance
Static lCfgTrib  := IIf(ExistFunc("LjCfgTrib"), LjCfgTrib(), .F.) // Verifica se pode ou nao utilizar o Configurador de Tributos.
//--------------------------------------------------------
/*/{Protheus.doc} GetImpPrd
Função para retorna conforme parametro usando MATXFIS

@param 		aItens     -> Array com produtos e Filiais a serem consultados (Obrigatorio)
@param 		aCampos    -> Array de campos retorno da MATXFIS exemplo: "IT_VALICM" ou "NF_" (Obrigatorio)
@param 		cCliente   -> Codigo do cliente (opcional)
@param 		cLojaCli   -> Loja do Cliente (opcional)
@author  	Varejo
@version 	1.0
@since      23/07/2020
@return	    aRet    -> Retorna com a informação
/*/
//--------------------------------------------------------
Function GetImpPrd(aItens,aCampos,cCliente,cLojaCli)
Local aArea 	:= GetArea()
Local nInd,nY   := 0
Local nTotItens := 0
Local aRet      := {}
Local nPreco    := 0
Local cTesProd  := ""
Local cFilbkp   := cFilAnt
Local xCampo1   := 0
Local nItem     := 0
Local nQuant    := 1
Local nValDesc  := 0


Default cCliente:= GetMv( "MV_CLIPAD" )		// Cliente padrao 
Default cLojaCli:= GetMv( "MV_LOJAPAD" )   // Loja padrao
Default aItens  := {}
Default aCampos := {}


SB1->(DbSetOrder(1))
nTotItens 	:= Len(aItens)
If Len(aItens) > 0 .AND. Len(aItens[1]) > 1 .AND. Len(aCampos) > 0
    MaFisIni(   cCliente		,;	// 01-Codigo Cliente/Fornecedor
                cLojaCli		,;	// 02-Loja do Cliente/Fornecedor
                "C"				,;	// 03-C:Cliente , F:Fornecedor
                "S"				,;	// 04-Tipo da NF( "N","D","B","C","P","I","S" )
                'F'				,;	// 05-Tipo do Cliente/Fornecedor
                NIL				,;	// 06-Relacao de Impostos que suportados no arquivo
                NIL				,;	// 07-Tipo de complemento
                .F.				,;	// 08-Permite Incluir Impostos no Rodape .T./.F.
                "SB1"			,;	// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                "LOJA701"		,;	// 10-Nome da rotina que esta utilizando a funcao
                "01"			,;	// 11-Tipo de documento
                NIL				,;	// 12-Especie do documento
                NIL				,;	// 13-Codigo e Loja do Prospect
                NIL				,;	// 14-Grupo Cliente
                NIL				,;	// 15-Recolhe ISS
                NIL				,;	// 16-Codigo do cliente de entrega na nota fiscal de saida
                NIL				,;	// 17-Loja do cliente de entrega na nota fiscal de saida
                NIL				,;	// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
                .F.				,;	// 19- No momento o PDV nao emite NF , por isso sempre falso
                .T.				,;	// 20-Define se calcula IPI (SIGALOJA)
                NIL				,;	// 21-Pedido de Venda
                NIL				,;	// 22
                NIL				,;	// 23
                NIL				,;	// 24
                NIL				,;	// 25
                NIL				,;	// 26
                NIL				,;	// 27
                NIL				,;	// 28
                NIL				,;	// 29
                NIL				,;	// 30
                NIL				,;	// 31
                NIL				,;	// 32
                lCfgTrib	)		// 33

    For nInd:=1 To nTotItens
        
        If aItens[nInd][2] != cFilAnt .AND. !Empty(aItens[nInd][2])
            RmiFilInt(aItens[nInd][2],.T.)//Atuliza cfilAnt .T. 
        EndIf
        If Len(aItens[nInd]) > 2 //Quantidade
            nQuant  :=  aItens[nInd][3]   
        EndIf
        If Len(aItens[nInd]) > 3 //Desconto
            nValDesc  :=  aItens[nInd][4]     
        EndIf
        If Len(aItens[nInd]) > 4 //Preço
            nPreco  :=  aItens[nInd][5]     
        EndIf
        If !SB1->(DBSeek(xFilial("SB1")+PadR(aItens[nInd][1],TamSx3("B1_COD")[1])))
            LjGrvLog("GetImpPrd", "GetImpPrd -> Produto não encontrado FILIAL|B1_COD  ", cFilAnt+"|"+aItens[nInd][1])
            Exit
        EndIf
        
        nPreco   := IIf( nPreco == 0 ,STWFormPr( SB1->B1_COD, cCliente, Nil, cLojaCli, 1),nPreco)
        cTesProd := RmiTesProd(SB1->B1_COD,cCliente,cLojaCli)
        
        If Empty(cTesProd)
            LjGrvLog("GetImpPrd", "RetFldProd -> TES do Produto não encontrado e MV_TESSAI esta Vazio FILIAL|B1_COD  ", cFilAnt+"|"+aItens[nInd][1])
            Exit
        EndIf
        If !(nPreco > 0)
            LjGrvLog("GetImpPrd", "STWFormPr -> Preço do Produto não encontrado FILIAL|B1_COD  ", cFilAnt+"|"+aItens[nInd][1])
            Exit
        EndIf
        
        nItem := MaFisAdd(  SB1->B1_COD     , cTesProd      , nQuant        , nPreco        ,;
                            nValDesc        , "" /*cNFOri*/ , "" /*cSEROri*/, /*nRecOri*/   ,;
                            0 /*Frete*/     , 0 /*Despesa*/	, 0 /*Seguro*/	, 0 /*nFretAut*/ ,;
                            nPreco*nQuant   , 0	/*nValEmb*/ )

        For nY := 1 To Len(aCampos)

            //Só processa valores do total da NF se não for o ultimo item
            //Porque assim a matxfis está totalmente carregada
            if substr(aCampos[nY][1],1,2) == "NF" .and. nItem <> nTotItens
                loop
            endIf

            If Substr(aCampos[nY][1],1,2) == "F4"
                xCampo1 := Posicione('SF4',1,xFilial('SF4')+cTesProd,aCampos[nY][1])
            ElseIf Substr(aCampos[nY][1],1,2) == "IT"
                xCampo1 := MaFisRet(nItem,aCampos[nY][1] )
            Else
                xCampo1 := MaFisRet(,aCampos[nY][1])
            EndIf
            Aadd(aRet,{cFilAnt,SB1->B1_COD,aCampos[nY][1],xCampo1,nItem})    
        Next    
       
        
    Next nInd
    MafisEnd()
    If !Empty(cFilbkp)
        RmiFilInt(cFilbkp,.T.)//Atuliza cfilAnt .T. 
    EndIf
    
EndIf

RestArea(aArea)
Return aRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} JsonImp
Função que gera o Json com os campos da tabela passada, 
no registro da SB1 que esta posicionado

@author  Everson S P Junior
@since   07/08/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function JsonImp(cJson, cCliente, cLojaCli, cFilProc)
Local aArea 	:= GetArea()
Local nY        := 0
Local nPreco    := 100
Local cTesProd  := ""
Local cFilbkp   := cFilAnt
Local cSitTrib  := ""
Local xCampo1   := 0
Local nItem     := 0
Local cTesSai   := ""
Local aCampos   := ACLONE( ArrayFis )           //Campos da MatXfis definidos no include ArrayfunC.CH.

Default cCliente    := ""
Default cLojaCli    := ""
Default cJson       := "" 

//Atualiza cFilAnt
If cFilProc != cFilAnt
    RmiFilInt(cFilProc,.T.)
EndIf

if empty(cCliente) .or. empty(cLojaCli)
    cCliente := superGetMv("MV_CLIPAD")
    cLojaCli := superGetMv("MV_LOJAPAD")
endIf

cCliente := padR(cCliente,TamSX3("A1_COD")[1])
cLojaCli := padR(cLojaCli,TamSX3("A1_LOJA")[1])

cJson    := "{"

GeraJson(@cJson,"B1_FILIAL" , cFilProc       )
GeraJson(@cJson,"B1_COD"    , SB1->B1_COD    )
GeraJson(@cJson,"B1_CLASFIS", SB1->B1_CLASFIS)

MaFisIni(   cCliente		,;	// 01-Codigo Cliente/Fornecedor
                cLojaCli		,;	// 02-Loja do Cliente/Fornecedor
                "C"				,;	// 03-C:Cliente , F:Fornecedor
                "S"				,;	// 04-Tipo da NF( "N","D","B","C","P","I","S" )
                'F'				,;	// 05-Tipo do Cliente/Fornecedor
                NIL				,;	// 06-Relacao de Impostos que suportados no arquivo
                NIL				,;	// 07-Tipo de complemento
                .F.				,;	// 08-Permite Incluir Impostos no Rodape .T./.F.
                "SB1"			,;	// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                "LOJA701"		,;	// 10-Nome da rotina que esta utilizando a funcao
                "01"			,;	// 11-Tipo de documento
                NIL				,;	// 12-Especie do documento
                NIL				,;	// 13-Codigo e Loja do Prospect
                NIL				,;	// 14-Grupo Cliente
                NIL				,;	// 15-Recolhe ISS
                NIL				,;	// 16-Codigo do cliente de entrega na nota fiscal de saida
                NIL				,;	// 17-Loja do cliente de entrega na nota fiscal de saida
                NIL				,;	// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
                .F.				,;	// 19- No momento o PDV nao emite NF , por isso sempre falso
                .T.				,;	// 20-Define se calcula IPI (SIGALOJA)
                NIL				,;	// 21-Pedido de Venda
                NIL				,;	// 22
                NIL				,;	// 23
                NIL				,;	// 24
                NIL				,;	// 25
                NIL				,;	// 26
                NIL				,;	// 27
                NIL				,;	// 28
                NIL				,;	// 29
                NIL				,;	// 30
                NIL				,;	// 31
                NIL				,;	// 32
                lCfgTrib	)		// 33 

//nPreco   := STWFormPr( SB1->B1_COD, cCliente, Nil, cLojaCli, 1)
//Busca TES Inteligente.
cTesProd := MaTesInt(2,"01",cCliente, cLojaCli,"C", SB1->B1_COD,NIL)
cTesSai  := SuperGetMV("MV_TESSAI",.F.,"501",cFilAnt)

If Empty(cTesProd) //Procura Tes no Produto se não encontrar pega TES do Param MV_TESSAI
    cTesProd := If( Empty( RetFldProd( SB1->B1_COD,"B1_TS" ) ), cTesSai, RetFldProd( SB1->B1_COD,"B1_TS" ) )
Else
    LjGrvLog("JsonImp", "Cliente Utiliza configuracao Tes inteligente ", cTesProd)
EndIf

If Empty(cTesProd)
    LjGrvLog("JsonImp", "RetFldProd -> TES do Produto não encontrado e MV_TESSAI esta Vazio FILIAL|B1_COD  ", cFilAnt+"|"+SB1->B1_COD)
EndIf

If !(nPreco > 0)
    LjGrvLog("JsonImp", "STWFormPr -> Preço do Produto não encontrado FILIAL|B1_COD  ", cFilAnt+"|"+SB1->B1_COD)
EndIf
    
SF4->( DbSetOrder(1) )  //F4_FILIAL+F4_CODIGO
SF4->( DbSeek(xFilial("SF4") + cTesProd) )

nItem := MaFisAdd(  SB1->B1_COD , cTesProd      , 1                 , nPreco            ,;
                    0           , ""            , ""                , 0		            ,;
                    0 /*Frete*/ , 0 /*Despesa*/	, 0 /*Seguro*/	    , 0                 ,;
                    nPreco	    , 0	 	        , SB1->( Recno() )  , SF4->( Recno() )  )

MaFisRecal("", nItem)                    
    
For nY := 1 To Len(aCampos)
    xCampo1   	:= IIF("IT" $ aCampos[nY] , MaFisRet(nItem,aCampos[nY] ),MaFisRet(,aCampos[nY]))
    GeraJson(@cJson,aCampos[nY], xCampo1)
Next

If Posicione("SA1",1,xFilial("SA1") + cCliente + cLojaCli,"A1_COD") <> ""
    cSitTrib := Lj7Strib(/*cSitTrib*/, /*nAliquota*/, /*nAliqRed*/, /*cTpSolCf*/, nItem)    //Precisa estar com SF4 posicionada
    GeraJson(@cJson,"IT_SITTRIB", cSitTrib)
Else
    LjGrvLog("JsonImp", "Cliente não posicionado ou não encontrado: ", cCliente+"|"+cLojaCli)
EndIf

If SF4->(DbSeek(xFilial("SF4")+cTesProd))
    GeraJson(@cJson,"IT_CSTPIS", SF4->F4_CSTPIS)
    GeraJson(@cJson,"IT_CSTCOF", SF4->F4_CSTCOF)
Else
    LjGrvLog("JsonImp", "IT_CSTPIS -> IT_CSTCOF TES NAO ENCONTRADA  ", cFilAnt+"|"+cTesProd)    
EndIf    

 LjGrvLog("JsonImp", "Situacao Tributaria retornada na Função Lj7Strib ", cSitTrib)

cJson := SubStr(cJson, 1, Len(cJson)-1)
cJson += "}"

MafisEnd()
If !Empty(cFilbkp)
    RmiFilInt(cFilbkp,.T.)//Atuliza cfilAnt .T. 
EndIf

RestArea(aArea)
Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraJson
Função que gera o Json com os campos da MATAXFIS, 
no registro que esta posicionado

@author  Rafael Tenorio da Costa
@since   30/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraJson(cJson,cCampo, xType)
 
    Local cTipo      := ""
    Local xConteudo  := ""
    
    Default cCampo := ""
    Default xType  := ""
    
    LjGrvLog(" GeraJsonImp "," Function GeraJson()")
    
    cTipo     := Valtype(xType)
    xConteudo := xType    
    
    Do Case
        Case cTipo $ "C|M"

            //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
            xConteudo := StrTran(xConteudo,'"','')
            xConteudo := StrTran(xConteudo,"'","")
            
            xConteudo := '"' + AllTrim(xConteudo) + '"'

        Case cTipo == "N"
            xConteudo := cValToChar(xConteudo)

        Case cTipo == "D"
            xConteudo := '"' + DtoS(xConteudo) + '"'

        Case cTipo == "L"
            xConteudo := IIF(xConteudo, "true", "false")
        
        OTherWise
            xConteudo := '"Tipo do campo inválido"'
    End Case
    
    cJson += '"' + AllTrim( cCampo ) + '":' + xConteudo + ","

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} RMITImeStamp
Função que gera o numero para ser enviado para o live na tag Numero

@author  Danilo Rodrigues
@since   04/03/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMITImeStamp(nTamanho)

    Local cTime      := FWTimeStamp(1)
    LoCal cHora      := TimeFull()
    Local cHoraFinal := ""

    Default nTamanho := 16

    cTime := Substr(cTime, 3, 6)
    cHora := StrTran(StrTran(cHora, ":", ""), ".", "")

    //Limita até 16 caracteres para não estourar campo do LIVE
    //O Número do Ticket do Live deverá ser uma string de 16 caracteres, composta pelo primeiro dígito um Zero(0) para ticket de entrada seguido do ano atual (dois dígitos), mês, dia, hora, minuto, segundo e milissegundos atuais.  
    //Exemplo de número para a data de criação igual 2019-12-11 14:05:46.677 = 0191211140546677.
    cHoraFinal := SubStr("0" + cTime + cHora, 1, nTamanho)

Return cHoraFinal

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTributo
Função que gera o bloco de tributo para processo Imposto Prod

@author  Danilo Rodrigues
@since   04/03/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function MontaTributo(cProcesso, oPublica)

Local cTributo  := ""
Local nX        := 0

If Alltrim(cProcesso) == "IMPOSTO PROD"

    If oPublica["IT_ALIQCOF"] > 0
        nX := nX + 1
        cTributo += "<LC_TributoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<NumeroSequencia>" + cValtoChar(nX) + "</NumeroSequencia>" + Chr(10) + Chr(13)
        cTributo +=     "<Ativo>true</Ativo>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoLoja>"+RmiDePaRet('LIVE', 'SM0',oPublica['B1_FILIAL'], .T.)+"</CodigoLoja>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoProduto>"+oPublica['B1_COD']+"</CodigoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<CST>"+ Iif(Empty(oPublica['IT_CSTCOF']),"00",oPublica['IT_CSTCOF']) +"</CST>" + Chr(10) + Chr(13)
        cTributo +=     "<CSTEntrada>0</CSTEntrada>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoConfiguracao>PRODUTO</TipoConfiguracao>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoTributo>COFINS</TipoTributo>" + Chr(10) + Chr(13)
        cTributo +=     "<AliquotaImposto>"+StrTran(Alltrim(Str(IIF(oPublica['IT_CSTCOF'] == '06',0,oPublica['IT_ALIQCOF']))),'.',',')+"</AliquotaImposto>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoNCM/>" + Chr(10) + Chr(13)
        cTributo += "</LC_TributoProduto>" + Chr(10) + Chr(13)
    EndIF
    
    If oPublica["IT_ALIQPIS"] > 0
        nX := nX + 1
        cTributo += "<LC_TributoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<NumeroSequencia>" + cValtoChar(nX) + "</NumeroSequencia>" + Chr(10) + Chr(13)
        cTributo +=     "<Ativo>true</Ativo>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoLoja>"+RmiDePaRet('LIVE', 'SM0',oPublica['B1_FILIAL'], .T.)+"</CodigoLoja>"+ Chr(10) + Chr(13)
        cTributo +=     "<CodigoProduto>"+oPublica['B1_COD']+"</CodigoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<CST>"+ Iif(Empty(oPublica['IT_CSTPIS']),"00",oPublica['IT_CSTPIS']) +"</CST>" + Chr(10) + Chr(13)
        cTributo +=     "<CSTEntrada>0</CSTEntrada>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoConfiguracao>PRODUTO</TipoConfiguracao>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoTributo>PIS</TipoTributo>" + Chr(10) + Chr(13)
        cTributo +=     "<AliquotaImposto>"+StrTran(Alltrim(Str(IIF(oPublica['IT_CSTPIS'] == '06',0,oPublica['IT_ALIQPIS']))),'.',',')+"</AliquotaImposto>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoNCM/>" + Chr(10) + Chr(13)
        cTributo += "</LC_TributoProduto>" + Chr(10) + Chr(13)
    EndIF
     
    If oPublica["IT_ALIQICM"] > 0
        nX := nX + 1
        cTributo += "<LC_TributoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<NumeroSequencia>" + cValtoChar(nX) + "</NumeroSequencia>" + Chr(10) + Chr(13)
        cTributo +=     "<Ativo>true</Ativo>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoLoja>"+RmiDePaRet('LIVE', 'SM0',oPublica['B1_FILIAL'], .T.)+"</CodigoLoja>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoProduto>"+oPublica['B1_COD']+"</CodigoProduto>" + Chr(10) + Chr(13)
        cTributo +=     "<CST>"+ Iif(Empty(oPublica['B1_CLASFIS']),"00",oPublica['B1_CLASFIS']) +"</CST>" + Chr(10) + Chr(13)
        cTributo +=     "<CSTEntrada>0</CSTEntrada>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoConfiguracao>PRODUTO</TipoConfiguracao>" + Chr(10) + Chr(13)
        cTributo +=     "<TipoTributo>ICMS</TipoTributo>" + Chr(10) + Chr(13)
        cTributo +=     "<AliquotaImposto>"+StrTran(Alltrim(Str(oPublica['IT_ALIQICM'])),'.',',')+"</AliquotaImposto>" + Chr(10) + Chr(13)
        cTributo +=     "<CodigoNCM/>" + Chr(10) + Chr(13)
        cTributo += "</LC_TributoProduto>" + Chr(10) + Chr(13)
    EndIF
    
EndIF

Return cTributo
//---------------------------------------------------------------------
/*/{Protheus.doc} RmiRetIBGE
Retorna o codigo da UF segundo o IBGE ou a propria UF
@author  Everso Junior
@since   05/03/2021
@version 12.1.17

@param	 cParam - indica a informacao a ser pesquisada
@param	 cCodMun - XML transformado em objeto atraves da funcao XMLParser
/*/
//---------------------------------------------------------------------
Function RmiRetIBGE(cParam, cCodMun)

Local nPos		:= 0	//posição de um determinado elemento no array
Local aUF		:= {}	//array com os códigos das UF
Local cRet		:= ""

Default cParam	:= ""	//UF ou Codigo IBGE
Default cCodMun := ""	//Codigo do Municipio

Aadd( aUF, {"RO","11"} )
Aadd( aUF, {"AC","12"} )
Aadd( aUF, {"AM","13"} )
Aadd( aUF, {"RR","14"} )
Aadd( aUF, {"PA","15"} )
Aadd( aUF, {"AP","16"} )
Aadd( aUF, {"TO","17"} )
Aadd( aUF, {"MA","21"} )
Aadd( aUF, {"PI","22"} )
Aadd( aUF, {"CE","23"} )
Aadd( aUF, {"RN","24"} )
Aadd( aUF, {"PB","25"} )
Aadd( aUF, {"PE","26"} )
Aadd( aUF, {"AL","27"} )
Aadd( aUF, {"MG","31"} )
Aadd( aUF, {"ES","32"} )
Aadd( aUF, {"RJ","33"} )
Aadd( aUF, {"SP","35"} )
Aadd( aUF, {"PR","41"} )
Aadd( aUF, {"SC","42"} )
Aadd( aUF, {"RS","43"} )
Aadd( aUF, {"MS","50"} )
Aadd( aUF, {"MT","51"} )
Aadd( aUF, {"GO","52"} )
Aadd( aUF, {"DF","53"} )
Aadd( aUF, {"SE","28"} )
Aadd( aUF, {"BA","29"} )
Aadd( aUF, {"EX","99"} )

nPos := aScan( aUF, {|x| x[1] == cParam} )
If nPos > 0
	cRet := aUF[nPos][2]
 	cRet += AllTrim(cCodMun)
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtVendCan
Função que Retorna se existe a venda a ser cancelada
Utilizado no layout

@param cChave      - Chave da MHQ 
@param cOrigem     - Assinante

@return lRet       - Logico existe venda cancelada 

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function ExtVendCan(cChave,cOrigem) 
Local lRet      := .F.
Local cQuery    := ""
Local cWhere    := ""
Local cAlias    := GetNextAlias()
Local cSGBD		:= Upper(AllTrim(TcGetDB()))

Default cChave  := ""
Default cOrigem := ""


If Alltrim(cOrigem) == "LIVE"
    
    If cSGBD $ "DB2*INFORMIX*ORACLE"  .OR. ( cSGBD == "DB2/400" .And. cSGBD == "ISERIES" )
	    cWhere += " AND SUBSTR(MHQ_CHVUNI,17,"+Alltrim(STR(TAMSX3('MHQ_CHVUNI')[1]))+") = '" +  SubStr(cChave, 17, TAMSX3('MHQ_CHVUNI')[1]) + "'"
    Else
	    cWhere += " AND SUBSTRING(MHQ_CHVUNI,17,"+Alltrim(STR(TAMSX3('MHQ_CHVUNI')[1]))+") = '" +  SubStr(cChave, 17, TAMSX3('MHQ_CHVUNI')[1]) + "'"
    EndIf
    
    cQuery := "SELECT MHQ_UUID,MHQ_CHVUNI, MHQ_EVENTO "
    cQuery += " FROM " + RetSqlName("MHQ")
    cQuery += " WHERE D_E_L_E_T_ = '' " 
    cQuery += cWhere
	cQuery += " ORDER BY MHQ_EVENTO "
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
    LjGrvLog("ExtVendCan","Query para verificar se existe a venda a ser cancelada -> ",cQuery)

    If !(cAlias)->( Eof() )
        If (cAlias)->MHQ_EVENTO == '1'
			lRet      := .T.
			LjGrvLog("ExtVendCan","Foi encontrado a venda a ser cancelada  ->",{MHQ_UUID,MHQ_CHVUNI})         
		EndIf	
    EndIf
    (cAlias)->( DbCloseArea() )
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} RMISUBSTR
Retorna cConteudo tratado conforme definido no cProcura substituindo por
cTroca é Utilizado no layout.

@param cConteudo      - Texto completo que será utilizado no tratamento 
@param cProcura       - Caracteres separados por | que serão encontrado no cConteudo
@param cTroca         - Caracteres separados por | que serão Substituidos no cConteudo

@return cConteudo     - Retorna Texto completo tratado conforme parametros

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMISUBSTR(cConteudo,cProcura,cTroca)
Local aSubs         := {}
Local aTrans        := {}
Local nX            := 0

Default cConteudo   := ''
Default cProcura    := ''
Default cTroca      := ''

aTrans  := StrTokArr( cProcura, "|" )
aSubs   := StrTokArr( cTroca  , "|" )

If Len(aSubs) == Len(aTrans)//Varias substituições tem que ter sua correspondecia de tamanho igual exemplo '+|&|@' trocar por ' + |E|a' <- tamanho correspondente
    LjGrvLog("RMISUBSTR","Efetuando trocas no conteudo ",{cProcura,cTroca})
    For nX:= 1 To Len (aTrans)
        cConteudo := StrTran( cConteudo, aTrans[nX], aSubs[nX] )
    next
elseIf Len(aSubs) == 1 // Posso trocar varios caracteres por 1 substituição exemplo '+|&|@' trocar por '' <- espaço em branco
    LjGrvLog("RMISUBSTR","Efetuando trocas no conteudo ",{cProcura,cTroca})
    For nX:= 1 To Len (aTrans)//então caso encontre os caracteres troca por branco.
        cConteudo := StrTran( cConteudo, aTrans[nX], aSubs[1] )
    next    
EndIf

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPagCred
Rotina para geração dos títulos de NCC, CR e compensação.
Utilizada para o processamento de vendas com pagamento L1_CREDITO
USO LjGrvFin - LjGrvBatch

@type   function
@param  aDadosBanc, Array, {"A6_AGENCIA", "A6_NUMCON"}
@param  cErro, Caractere, Retorna a descrição do erro para ser gravada na tabela MHL
@return Lógico, Define se a geração e compensação foi efetuada corretamente

@author  Rafael Tenorio da Costa
@since   21/10/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RmiPagCred(aDadosBanc, cErro)

    Local aTitulo   := {}
    Local lRet      := .T.
    Local cParcela  := LjParcela( 1, SuperGetMv("MV_1DUP") )
    Local cHist     := STR0001  //"Integração - Venda Pagamento Crédito"
    Local cOrigem   := "RMIXFUNC"
    Local nRecnoNCC := 0
    Local nRecnoCR  := 0
    Local lGerMovi  := SuperGetMV("MV_PSHMOV", ,.T.)//Parametro habilita a movimentação NCC

    Private lMsErroAuto := .F.  //Variavel usada para o retorno da EXECAUTO

    //Para vendas com origem do PDVSYNC não deve ser gerado NCC\CR aqui, porque este processo é on-line
    if fwAliasInDic("MHQ") .and. allTrim( posicione("MHQ", 7, xfilial("MHQ") + padR(SL1->L1_UMOV, tamSx3("MHQ_UUID")[1]), "MHQ_ORIGEM") ) == "PDVSYNC"
        lGerMovi := .F.
    endIf
    
    If !lGerMovi
        ljGrvLog(SL1->L1_NUM, "Não serão gerados os títulos de crédito(NCC\CR), porque o parâmetro MV_PSHMOV esta desativado ou a origem da venda de integração é PDVSYNC.", {superGetMv("MV_PSHMOV", ,.T.), SL1->L1_UMOV})
        Return .T.
    EndIf

    LjGrvLog(SL1->L1_NUM, "Iniciando geração de pagamento com crédito.")

    //Inclui titulo NCC
    aAdd(aTitulo, { "E1_PREFIXO"    , SL1->L1_SERIE                                     , Nil} )
    aAdd(aTitulo, { "E1_NUM"        , SL1->L1_DOC 				                        , Nil} )
    aAdd(aTitulo, { "E1_PARCELA"    , cParcela					                        , Nil} )
    aAdd(aTitulo, { "E1_NATUREZ"    , LjMExeParam("MV_NATNCC")	                        , Nil} )
    aAdd(aTitulo, { "E1_TIPO" 	    , "NCC"						                        , Nil} )
    aAdd(aTitulo, { "E1_EMISSAO"    , SL1->L1_EMISSAO 			                        , Nil} )
    aAdd(aTitulo, { "E1_VALOR"	    , SL1->L1_CREDITO			                        , Nil} )
    aAdd(aTitulo, { "E1_VENCTO"     , SL1->L1_DTLIM				                        , Nil} )
    aAdd(aTitulo, { "E1_VENCREA"	, DataValida(SL1->L1_DTLIM, .T.)                    , Nil} )	
    aAdd(aTitulo, { "E1_VENCORI"	, SL1->L1_DTLIM					                    , Nil} )
    aAdd(aTitulo, { "E1_SALDO"	    , SL1->L1_CREDITO								    , Nil} )
    aAdd(aTitulo, { "E1_VLCRUZ"	    , xMoeda(SL1->L1_CREDITO, 1, 1, SL1->L1_EMISSAO)    , Nil} )
    aAdd(aTitulo, { "E1_CLIENTE"	, SL1->L1_CLIENTE							        , Nil} )
    aAdd(aTitulo, { "E1_LOJA"	    , SL1->L1_LOJA	   						            , Nil} )
    aAdd(aTitulo, { "E1_MOEDA"	    , SL1->L1_MOEDA							            , Nil} )
    aAdd(aTitulo, { "E1_ORIGEM"     , cOrigem   						                , Nil} )
    aAdd(aTitulo, { "E1_HIST"	    , cHist	                                            , Nil} )

    LjGrvLog(SL1->L1_NUM, "Gerando titulo NCC. [Fina040]", aTitulo)

    MsExecAuto( { |x, y| Fina040(x, y) }, aTitulo, 3)  

    If lMsErroAuto

        cErro := I18n(STR0002, {"NCC"}) + MostraErro("\")   //"Não foi possível gerar título #1: "

    //Inclui titulo CR
    Else

        nRecnoNCC := SE1->( Recno() )

        aSize(aTitulo, 0)

        aAdd(aTitulo, { "E1_PREFIXO"    , SL1->L1_SERIE                                     , Nil} )
        aAdd(aTitulo, { "E1_NUM"        , SL1->L1_DOC 				                        , Nil} )
        aAdd(aTitulo, { "E1_PARCELA"    , cParcela					                        , Nil} )
        aAdd(aTitulo, { "E1_NATUREZ"    , LjMExeParam("MV_NATCRED")	                        , Nil} )
        aAdd(aTitulo, { "E1_PORTADO"    , SL1->L1_OPERADO	                                , Nil} )
        aAdd(aTitulo, { "E1_AGEDEP" 	, aDadosBanc[1]	                                    , Nil} )
        aAdd(aTitulo, { "E1_CONTA" 		, aDadosBanc[2]	                                    , Nil} )
        aAdd(aTitulo, { "E1_TIPO" 	    , "CR"						                        , Nil} )
        aAdd(aTitulo, { "E1_EMISSAO"    , SL1->L1_EMISSAO 			                        , Nil} )
        aAdd(aTitulo, { "E1_VALOR"	    , SL1->L1_CREDITO			                        , Nil} )
        aAdd(aTitulo, { "E1_VENCTO"     , SL1->L1_DTLIM				                        , Nil} )
        aAdd(aTitulo, { "E1_VENCREA"	, DataValida(SL1->L1_DTLIM, .T.)                    , Nil} )
        aAdd(aTitulo, { "E1_VENCORI"	, SL1->L1_DTLIM					                    , Nil} )
        aAdd(aTitulo, { "E1_SALDO"	    , SL1->L1_CREDITO								    , Nil} )
        aAdd(aTitulo, { "E1_VLCRUZ"	    , xMoeda(SL1->L1_CREDITO, 1, 1, SL1->L1_EMISSAO)    , Nil} )
        aAdd(aTitulo, { "E1_CLIENTE"	, SL1->L1_CLIENTE							        , Nil} )
        aAdd(aTitulo, { "E1_LOJA"	    , SL1->L1_LOJA	   						            , Nil} )
        aAdd(aTitulo, { "E1_MOEDA"	    , SL1->L1_MOEDA							            , Nil} )
        aAdd(aTitulo, { "E1_ORIGEM"     , cOrigem						                    , Nil} )
        aAdd(aTitulo, { "E1_HIST"	    , cHist                     	                    , Nil} )

        LjGrvLog(SL1->L1_NUM, "Gerando titulo CR. [Fina040]", aTitulo)

        MsExecAuto( { |x, y| Fina040(x, y) }, aTitulo, 3) 

        If lMsErroAuto

            cErro := I18n(STR0002, {"CR"}) + MostraErro("\")    //"Não foi possível gerar título #1: "

        //Compensa NCC com CR
        Else

            nRecnoCR := SE1->( Recno() )

            LjGrvLog(SL1->L1_NUM, "Compensando NCC com CR. [MaIntBxCR]", {nRecnoNCC, nRecnoCR})

            If !MaIntBxCR(3, {nRecnoCR}, /*aBaixa*/, {nRecnoNCC}, /*aLiquidacao*/, {.T., .F., .F., .F., .F., .F.})
                lMsErroAuto := .T.            
                cErro       := I18n(STR0003, {"NCC", "CR"})     //"Não foi possível compensar título #1 com #2."
            EndIf
            
        EndIf

    EndIf

    //Grava log de erros
    If lMsErroAuto
        lRet := .F.
        LjxjMsgErr(cErro, /*cSolucao*/, SL1->L1_NUM)
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIRetApur
Função que verifica a configuração do cliente para preencher os impostos 
de Pis e Cofins dos tipos Apuração e Retenção

@param cIdentCliente  - Codigo de Identificação Cliente vindo da integração

@return lRet          - Retorno logico

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIRetApur(cIdentCliente)

Local cCodCli       := ""
Local cCodLoja      := ""
Local lRet          := .T.

DEFAULT cIdentCliente := ""

    if Empty(cIdentCliente)
        cCodCli     := SuperGetMv('MV_CLIPAD', .F., '000001')
        cCodLoja    := SuperGetMv('MV_LOJPAD', .F., '01')       
        LjGrvLog("RMIRetApur", "Não identificado na integração o cliente, será usado o cliente padrão!", {cCodCli, cCodLoja})

        SA1->(DbSetOrder(1))
        If SA1->(DbSeek(xFilial("SA1") + cCodCli + cCodLoja ))

            //Apuração
            If SA1->A1_RECPIS $ " |N" .OR. SA1->A1_RECCOFI $ " |N"
                lRet := .T.
            else
                lRet := .F.
            ENDIF
            LjGrvLog("RMIRetApur", "Identificado cliente e retornado a configuração de PIS/Cofins", lRet)
        ENDIF

    ELSE

        LjGrvLog("RMIRetApur", "Identificado Cliente na integração, busca na SA1 por CPF/CNPJ", cIdentCliente)

        SA1->(DbSetOrder(3))
        If SA1->(DbSeek(xFilial("SA1") + cIdentCliente ))

            //Apuração
            IF SA1->A1_RECPIS $ " |N" .OR. SA1->A1_RECCOFI $ " |N"
                lRet := .T.
            else
                lRet := .F.
            ENDIF
            LjGrvLog("RMIRetApur", "Identificado cliente e retornado a configuração de PIS/Cofins", lRet)
        ENDIF

    ENDIF   

RETURN lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIConWsdl()
Cria o objeto TWsdlManager a partir da Url

@param  cUrl - String -  URL do Wsdl
@param  cErro - String - Variavel de erro, deve ser enviada como referencia
@return  oWsdl - objeto TWsdlManager

@author  Lucas Novais (lNovais@)
@since 	 05/04/22
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIConWsdl(cUrl, cErro)

	//Cria o objeto da classe TWsdlManager
	Local oWsdl := Nil
	Local nWsdl := 0

	//Limpa a variavel de referencia antes de executar
	cErro := ""

	//Valida se o objeto ja esta em cache
	If ( nWsdl := aScan(aWsdl, {|x| x[1] == AllTrim(cUrl)}) ) == 0

		oWsdl                    := TWsdlManager():New()
        oWsdl:nConnectionTimeout := 300
        oWsdl:nTimeout           := 300
		oWsdl:nSoapVersion       := 0
		oWsdl:bNoCheckPeerCert   := .T.

		//Faz o parse de uma URL
		If oWsdl:ParseURL(cUrl)
			cErro := ""
			Aadd(aWsdl, {AllTrim(cUrl), oWsdl})			//Cache do wsdl parseado
		Else
			cErro := IIF( empty(oWsdl:cError), i18n(STR0004, {cUrl}), oWsdl:cError )    //"Url inválida [#1]"
		EndIf
	Else
        If !Empty(aWsdl[nWsdl][2]:cError)
            
            // -- Destroi o objeto para remover a memoria alocada
            FreeObj(aWsdl[nWsdl][2])
            
            // -- Removo a posição do array e reorganizo 
            aDel(aWsdl,nWsdl)
            aSize(aWsdl,Len(aWsdl) - 1 )

            // -- Utilizo a função recursivamente para criar o objeto novamente.
            oWsdl := RMIConWsdl(cUrl, @cErro)
        Else
            oWsdl := aWsdl[nWsdl][2]
        EndIf 
	Endif

Return oWsdl

/*/{Protheus.doc} RmiValInt
    Validar a integração de envio de cadastro, onde houve confirmação de gravação no sistema destino (USO EXCLUSIVO TVFR)
    @type Function
    @author Danilo Rodrigues
    @since 21/12/2022
    @version 1.0
    @param cAlias, cValor
    @return aRet
    /*/
Function RmiValInt(cAlias, cValor)
    Local cDB           := AllTrim( TcGetDB() )
    Local cRetDePara    := ""
    Local aRet          := {}
    Local adadosMHQ     := {}
    Local aSql          := {}
    Local cMhrStatus    := ""
    Local cMhlErro      := ""
    Local cQuant        := "1"
    Local cSelect       := IIF( cDB == "MSSQL"            , " TOP " + cQuant          , "" )
    Local cWhere        := IIF( cDB == "ORACLE"           , " AND ROWNUM <= " + cQuant, "" )
    Local cLimit        := IIF( !(cDB $ "MSSQL|ORACLE")   , " LIMIT " + cQuant        , "" )
    Local cQuery        := ""

    Default cAlias      := ""
    Default cValor      := ""
    
    cValor :=  IIF(!("|" $ cValor), xFilial(cAlias)+"|"+cValor,  cValor )

    cRetDePara := RmiDePaRet("CONFIRMA", cAlias, cValor, .T.)

    If !Empty(cRetDePara)
        AAdd( aRet, .T.)
        AAdd( aRet, "Confirmação de integração encontrada: Tabela: " + cAlias + ", Valor: " + cValor)
    else

        cQuery := " SELECT "
        cQuery += cSelect
        cQuery += " MHQ_UUID,MHQ_CPROCE,MHQ_STATUS "
        cQuery += " FROM "+RetSqlName("MHQ")
        cQuery += " WHERE MHQ_CHVUNI = '"+PadR(cValor,TAMSX3("MHQ_CHVUNI")[1])+"' AND D_E_L_E_T_ = ' ' "
        cQuery += cWhere
        cQuery += " ORDER BY R_E_C_N_O_ DESC "
        cQuery += cLimit

        aSql := RmiXSql(cQuery, "*", /*lCommit*/, /*aReplace*/)

        If Len(aSql) > 0
            adadosMHQ := aSql[1]
        Else 
            aAdd(aRet, .F.)
            aAdd(aRet, "Registro Não foi encontrado na publicação.")
            
            FwFreeArray(aSql)
            FwFreeArray(adadosMHQ)
            Return aRet
        EndIf

        dbSelectArea("MHR")
        cMhrStatus := GetAdvFVal("MHR","MHR_STATUS",xFilial("MHR")+PadR(adadosMHQ[1],TAMSX3("MHR_UIDMHQ")[1]),3,"")

        Do Case

            Case Alltrim(cMhrStatus) == '1'
                aAdd(aRet, .F.)
                aAdd(aRet, I18n("#1 aguardando para ser integrado.", {AllTrim(adadosMHQ[2])} ) )
            
            Case Alltrim(cMhrStatus) == '2'
                AAdd( aRet, .T.    )
                AAdd( aRet, I18n("#1 integrado, #2 de referência #3", {AllTrim(adadosMHQ[2]), "UUID", AllTrim(adadosMHQ[1])} ) )
            
            Case Alltrim(cMhrStatus) == '3'
                dbSelectArea("MHL")
                MHR->(DbSetOrder(3))
                cMhlErro := Posicione("MHL",3,xFilial("MHL")+PadR(adadosMHQ[1],TAMSX3("MHL_UIDORI")[1]), "MHL_ERROR")    
                
                aAdd(aRet, .F.)
                aAdd(aRet, I18n("#1 não integrado, motivo: #2", {AllTrim(adadosMHQ[2]), AllTrim(cMhlErro)}) )

            Case Alltrim(cMhrStatus) == '6'

                aAdd(aRet, .T.)
                aAdd(aRet, I18n("#1 integrado, aguardando retorno de confirmação, #2 de referência #3", {AllTrim(adadosMHQ[2]), "UUID", AllTrim(adadosMHQ[1])}) )

            Case !Empty(adadosMHQ[1]) .AND. Empty(cMhrStatus)
                If adadosMHQ[3] == "3"
                    dbSelectArea("MHL")
                    MHL->(DbSetOrder(3))
                    cMhlErro := Posicione("MHL",3,xFilial("MHL")+PadR(adadosMHQ[1],TAMSX3("MHL_UIDORI")[1]), "MHL_ERROR")   
                
                    aAdd(aRet, .F.)
                    aAdd(aRet, I18n("#1 não integrado, motivo: #2", {AllTrim(adadosMHQ[2]), AllTrim(cMhlErro)}) )
                Elseif adadosMHQ[3] == "1"
                    aAdd(aRet, .F.)
                    aAdd(aRet, I18n("Registro encontrado na fila para processamento de envio, na tabela #1 com status #2.", {"MHQ", AllTrim(adadosMHQ[3])} ) )
                Else 
                    aAdd(aRet, .F.)
                    aAdd(aRet, I18n("Registro publicado, porém sem rastro de envio (MHR). Por favor, verifique! UUID do registro: #1", {AllTrim(adadosMHQ[1])} ) )                                                            
                EndIf

            Otherwise
                aAdd(aRet, .F.)
                aAdd(aRet, I18n("Verifique, registro não encontrado na tabela de integração #1.", {"MHQ"} ) )    
        EndCase
    EndIF
    FwFreeArray(aSql)
    FwFreeArray(adadosMHQ)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} pshDadAut
Retorna array com os dados de autorização da venda, baseado no campo L1_RETSFZ.
L1_RETSFZ = 113230011249412|100|Autorizado o uso da NF-e

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshDadAut(cRetSfz, cUuid)

    Local aDadAut := {}
    Local aAux    := {}

    if !empty(cRetSfz) .and. allTrim(cRetSfz) <> "||"
        aAux := strTokArr(cRetSfz, "|")

        if len(aAux) >= 3
            //113230011249412|100|Autorizado o uso da NF-e
            aDadAut := {aAux[2], aAux[3], "M", aAux[1]}
        endIf
    endIf

    fwFreeArray(aAux)

    LjGrvLog("RMIXFUNC", "Retorno dos dados de autorização da venda, baseado no campo L1_RETSFZ:", {cRetSfz, cUuid, aDadAut})

return aDadAut
