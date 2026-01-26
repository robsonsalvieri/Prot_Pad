#INCLUDE "TOTVS.CH"
#INCLUDE "RMIIMPOSTOSOBJ.CH"
#INCLUDE "MATXDEF.CH"

//TENORIO
#DEFINE TRIB_ID_IBS_ESTADUAL  "000060"
#DEFINE TRIB_ID_IBS_MUNICIPAL "000061"
#DEFINE TRIB_ID_CBS_FEDERAL   "000062"
#DEFINE TRIB_ID_IS            "000063"
//TENORIO

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiImpostosObj
Classe responsável pelo calculo de impostos

@type    class
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class RmiImpostosObj

    Data nItem          as Numeric

    Data cCodCliente    as Character
    Data cLojCliente    as Character
    Data cProduto       as Character   
    Data cTes           as Character
    Data nValorUnit     as Numeric
    
    Data jImposto       as Object
    Data aImpostos      as Array
    Data cSitTrib       as Character
    Data lCfgTrib       as Character

    Data oMessageError  as Object

    Method New(cCodCli, cLojaCli, cProduto)
    Method Finaliza()
    Method Limpa()

    Method setProduto(cProduto)
    Method setTes(cTes)
    Method getImposto(aCampos)

    Method Calcula()

    Method Exception()

    Method configuradorTributario()
    Method imposto(cTributo, cTipo)


EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@type    method
@param   cCodCli, Caractere, Código do cliente
@param   cLojaCli, Caractere, Loja do cliente
@return  RmiImpostosObj, Retorna o proprio objeto
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New(cCodCli, cLojaCli) Class RmiImpostosObj

    Default cCodCli  := SuperGetMv("MV_CLIPAD" , , "")
    Default cLojaCli := SuperGetMv("MV_LOJAPAD", , "")

    self:nItem          := 1   
    self:cCodCliente    := PadR(cCodCli , TamSx3("A1_COD")[1] )
    self:cLojCliente    := PadR(cLojaCli, TamSx3("A1_LOJA")[1])
    self:cProduto       := ""
    self:cTes           := ""
    self:nValorUnit     := 100

    self:jImposto       := Nil
    self:cSitTrib       := ""
    Self:lCfgTrib       := IIf(ExistFunc("LjCfgTrib"), LjCfgTrib(), .F.) // Verifica se pode ou nao utilizar o Configurador de Tributos.    //TENORIO
    self:aImpostos      := {}

    self:oMessageError  := LjMessageError():New()

    SA1->( DbSetOrder(1) )  //A1_FILIAL+A1_COD+A1_LOJA
    SA1->( DbSeek(xFilial("SA1") + self:cCodCliente + self:cLojCliente ) )

    MaFisIni(	self:cCodCliente,;	// 01-Codigo Cliente/Fornecedor
                self:cLojCliente,;	// 02-Loja do Cliente/Fornecedor
                "C"				,;	// 03-C:Cliente , F:Fornecedor
                "S"				,;	// 04-Tipo da NF( "N","D","B","C","P","I","S" )
                "F"				,;	// 05-Tipo do Cliente/Fornecedor
                /*aRelImp*/		,;	// 06-Relacao de Impostos que suportados no arquivo
                /*cTpComp*/		,;	// 07-Tipo de complemento
                .F.				,;	// 08-Permite Incluir Impostos no Rodape .T./.F.
                "SB1"			,;	// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                "LOJA701"		,;	// 10-Nome da rotina que esta utilizando a funcao
                "01"			,;	// 11-Tipo de documento
                /*cEspecie*/	,;	// 12-Especie do documento
                /*cCodProsp*/	,;	// 13-Codigo e Loja do Prospect
                /*cGrpCliFor*/	,;	// 14-Grupo Cliente
                /*cRecolheISS*/	,;	// 15-Recolhe ISS
                /*cCliEnt*/		,;	// 16-Codigo do cliente de entrega na nota fiscal de saida
                /*cLojEnt*/		,;	// 17-Loja do cliente de entrega na nota fiscal de saida
                /*aTransp*/		,;	// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
                .F.				,;	// 19- No momento o PDV nao emite NF , por isso sempre falso
                .T.				,;	// 20-Define se calcula IPI (SIGALOJA)
                Nil             ,;	// 21-Pedido de Venda
                Nil             ,;	// 22
                Nil             ,;	// 23
                Nil             ,;	// 24
                Nil             ,;	// 25
                Nil             ,;	// 26
                Nil             ,;	// 27
                Nil             ,;	// 28
                Nil             ,;	// 29
                Nil             ,;	// 30
                Nil             ,;	// 31
                Nil             ,;	// 32
                Self:lCfgTrib)			// 33

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setProduto
Atualiza a propridade cProduto.

@type    method
@param   cProduto, Caractere, Código do produto
@return  Lógico, Define se foi possível efetuar a atualização
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setProduto(cProduto) Class RmiImpostosObj

    Default cProduto := ""

    SB1->( DbSetOrder(1) )  //B1_FILIAL+B1_COD
    If Empty(cProduto) .Or. !SB1->( DbSeek(xFilial("SB1") + cProduto) )

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {STR0002, cProduto}) )       //"#2 não localizado(a) (#2), verifique!"   //"Produto"
    Else
   
        self:cProduto := cProduto

        self:setTes()
    EndIf

Return self:oMessageError:GetStatus()

//-------------------------------------------------------------------
/*/{Protheus.doc} setTes
Atualiza a propridade cTes.

@type    method
@param   cTes, Caractere, Código da tes
@return  Lógico, Define se foi possível efetuar a atualização
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setTes() Class RmiImpostosObj

    Local cTes := ""

    cTes := RmiTesProd(self:cProduto,self:cCodCliente,self:cLojCliente)

    SF4->( DbSetOrder(1) )  //F4_FILIAL+F4_CODIGO
    If Empty(cTes) .Or. !SF4->( DbSeek(xFilial("SF4") + cTes) )

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {"TES", cTes}) )     //"#2 não localizado(a) (#2), verifique!"
    Else

        self:cTes := cTes
    EndIf
    LjGrvLog( GetClassName(self), "TES indicada para o produto (Retorno da MaTesInt)", {self:cTes,self:cProduto} )  
Return self:oMessageError:GetStatus()

//-------------------------------------------------------------------
/*/{Protheus.doc} Calcula
Efetua os calculos dos impostos utilizando a MATXFIS.

@type    method
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Calcula() Class RmiImpostosObj

    If MaFisFound("IT", self:nItem)
        //Limpa os itens da NF e zera as variaveis do cabecalho.
        MaFisClear()
    EndIf

    SB1->( DbSetOrder(1) )  //B1_FILIAL+B1_COD
    SB1->( DbSeek(xFilial("SB1") + self:cProduto) )

    SF4->( DbSetOrder(1) )  //F4_FILIAL+F4_CODIGO
    SF4->( DbSeek(xFilial("SF4") + self:cTes) )

    MaFisAdd(   self:cProduto   ,;  // 1 -Codigo do Produto ( Obrigatorio )
                self:cTes,;         // 2 -Codigo do TES ( Opcional ) devido o CFOP ser informado 
                1               ,;  // 3 -Quantidade ( Obrigatorio )
                self:nValorUnit ,;  // 4 -Preco Unitario ( Obrigatorio )
                0               ,;  // 5 -Valor do Desconto ( Opcional )
                ""	 		    ,;  // 6 -Numero da NF Original ( Devolucao/Benef )
                ""    		    ,;  // 7 -Serie da NF Original ( Devolucao/Benef )
                0               ,;  // 8 -RecNo da NF Original no arq SD1/SD2
                0               ,;  // 9 -Valor do Frete do Item ( Opcional )
                0               ,;  // 10-Valor da Despesa do item ( Opcional )
                0           	,;  // 11-Valor do Seguro do item ( Opcional )
                0               ,;  // 12-Valor do Frete Autonomo ( Opcional )
                self:nValorUnit ,;  // 13-Valor da Mercadoria ( Obrigatorio )
                0	 	        ,;  // 14-Valor da Embalagem ( Opiconal )
                SB1->( Recno() ),;  // 15-RecNo do SB1
                SF4->( Recno() ) )  // 16-RecNo do SF4

    MaFisRecal("", self:nItem)

    //Verifica a situacao tributaria do item - LOJA701D
    self:cSitTrib := Lj7Strib(Nil, IIF(Self:lCfgTrib,MaFisRet(1, "IT_ALIQICM"),Nil), Nil, Nil, self:nItem)

    self:configuradorTributario()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getImposto


@type    method
@param   aCampos, Array, Campos que deseja o retorno da MATXFIS, utilizando o MATXDEF.ch como referência.
@return  JsonObject, Com os campos do parâmetro aCampos e seus conteudos retornados pela MATXFIS.
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getImposto(aCampos, cTipoImposto) Class RmiImpostosObj

    Local nCont      := 1
    Local aException := {}
    Local nPos       := 0

    If MaFisFound("IT", self:nItem)

        FwFreeObj(self:jImposto) 
        self:jImposto := Nil
        self:jImposto := JsonObject():New()

        For nCont:=1 To Len(aCampos)

            If (aException := Self:Exception(aCampos[nCont]))[1]
                self:jImposto[ aCampos[nCont] ] := aException[2]
            ElseIf subStr(aCampos[nCont], 1, 3) $ "NF_|IT_|LF_"
                self:jImposto[ aCampos[nCont] ] := MaFisRet( self:nItem, aCampos[nCont] )
            ElseIf Len(self:aImpostos) > 0 .and. ( nPos := aScan(self:aImpostos, {|x| x[1] == cTipoImposto }) ) > 0
                self:jImposto[ aCampos[nCont] ] := self:aImpostos[nPos][2][ aCampos[nCont] ]
            EndIf

        Next nCont
    EndIf

Return self:jImposto

//-------------------------------------------------------------------
/*/{Protheus.doc} Finaliza
Encerra o calculo de impostos

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Finaliza() Class RmiImpostosObj
    MaFisEnd()
    FwFreeArray(self:aImpostos)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Limpa
Prepara propriedade para o proximo processamento

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Limpa() Class RmiImpostosObj
    self:oMessageError:ClearError()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Exception
Metodo responsavel por tratar exceções no get de valores de impostos 

@type    method   
@param  String, Campo a sertratado
@return  Array, {.F.,""} -- Indica se tem exceção e se tiver envia o dado
@author  Lucas Novais (lnovias@)
@since   18/11/2021
@version 12.1.37
/*/
//-------------------------------------------------------------------
Method Exception(cCampo) Class RmiImpostosObj

    Local aRet := {.F., ""}		//Indica se tem tratamento de exceção no campo.
    Local aAux := {}
    Local nAux := 0
    
    Do Case
    
        Case cCampo == "IT_CODDECL"
        
            aRet := {.T.,""}
            
            //F3K_CODAJU - Codigo do Valor Declaratorio - Mesmo retorno do LOJNFCE função LjCodBenef
            aAux :=  MaFisRet( self:nItem, cCampo )
            
            If Len(aAux) > 0 .AND. Len(aAux[1]) > 0
                aRet :=  {.T.,aAux[1][1]}
            EndIf

		Case cCampo == "Modalidade"
		
			aRet[1] := .T.
			aRet[2] := self:cSitTrib

		Case cCampo == "Simbolo"
		
			aRet[1] := .T.
			aRet[2] := self:cSitTrib

            Do Case
                Case SubStr(self:cSitTrib, 1, 1) == "F"
                    aRet[2] := "FF"
                Case SubStr(self:cSitTrib, 1, 1) == "N"
                    aRet[2] := "NN"
                Case SubStr(self:cSitTrib, 1, 1) == "I"
                    aRet[2] := "II"
            End Case

        Case cCampo == "descontaDesoneracaoNf"

            aRet[1] := .T.
			aRet[2] := IIf(MaFisRet( 1,"IT_ICMDESONE" ) > 0,.F.,.T.)

        Case cCampo == "IT_ALIQICM"    //Alíquota de ICMS - Verifica se tem majoração de FECP
            
            If (nAux := MaFisRet( self:nItem, "IT_ALIQFECP" )) > 0 
                aRet[1] := .T.            
                If (aRet[2] := MaFisRet( self:nItem, "IT_ALIQICM" ) - nAux ) < 0 
                    aRet[2] := 0     
                EndIf
            EndIf

        Case cCampo == "IT_CF"

            aRet[1] := .T.
			aRet[2] := Alltrim(MaFisRet( self:nItem, "IT_CF" ))

        Case cCampo == "CSTCSOSN"
            //MV_CODREG = -Simples Nacional \ 2-Simples Nacional- Excesso de sub-limite de receita bruta \ 3- Regime Nacional
            aRet[1] := .T.
			aRet[2] := allTrim( IIF( allTrim(superGetMV("MV_CODREG", , "1")) == "3", subStr(maFisRet(self:nItem, "IT_CLASFIS"), 2, 2), maFisRet(self:nItem, "IT_CSOSN") ) )

    EndCase

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} configuradorTributario
Metodo que retorna os impostos com base no configurador de tributos

@type    method
@return  nil
@author  Everson S P Junior
@since   26/03/2025
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Method configuradorTributario() Class RmiImpostosObj

    Local nCSLL     := .F.
    Local nCOF      := .F.
    Local nPIS      := .F.
    Local aTGCalc   := {} 

    If Self:lCfgTrib .AND. !Empty(aTGCalc := MaFisRet(,"NF_TRIBGEN"))
            
        nCSLL   := aScan(aTGCalc, {|x| x[TG_NF_IDTRIB] = TRIB_ID_CSLL }) 
        nCOF    := aScan(aTGCalc, {|x| x[TG_NF_IDTRIB] = TRIB_ID_COF })
        nPIS    := aScan(aTGCalc, {|x| x[TG_NF_IDTRIB] = TRIB_ID_PIS })
        
        If nCSLL > 0 
            MaFisLoad("IT_ALIQCSL", aTGCalc[nCSLL][TG_NF_VALOR] , self:nItem)
        EndIf
        If nCOF > 0 
            MaFisLoad("IT_ALIQCOF", aTGCalc[nCOF][TG_NF_VALOR]  , self:nItem)
        EndIf
        If nPIS > 0 
            MaFisLoad("IT_ALIQPIS", aTGCalc[nPIS][TG_NF_VALOR]  , self:nItem)
        EndIf

        if aScan(aTGCalc, {|x| x[TG_NF_IDTRIB] = TRIB_ID_IBS_ESTADUAL}) > 0
            self:imposto(TRIB_ID_IBS_ESTADUAL, "IBSUF")
        endIf

        if aScan(aTGCalc, {|x| x[TG_NF_IDTRIB] = TRIB_ID_IBS_MUNICIPAL}) > 0
            self:imposto(TRIB_ID_IBS_MUNICIPAL, "IBSM")
        endIf

        if aScan(aTGCalc, {|x| x[TG_NF_IDTRIB] = TRIB_ID_CBS_FEDERAL}) > 0
            self:imposto(TRIB_ID_CBS_FEDERAL, "CBS")
        endIf

        if aScan(aTGCalc, {|x| x[TG_NF_IDTRIB] = TRIB_ID_IS}) > 0
            self:imposto(TRIB_ID_IS, "IS")
        endIf

    EndIf

    FwFreeArray(aTGCalc)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} imposto
Retorna os impostos calculados em formato JsonObject

@type    method
@return  JsonObject, Objeto contendo os impostos calculados
@author  Rafael Tenorio da Costa
@since   03/07/2024
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method imposto(cTributo, cTipo) Class RmiImpostosObj

    Local jImposto     := JsonObject():New()
    Local jTaxesConfig := LjCfgTaxes(cTributo, frtPegaIt(self:nItem), {"regras_aliquota", "detalhe_livro","regras_escrituracao"})[1]
    Local aRegTribut   := getADVFVal("F2B", {"F2B_VIGINI", "F2B_VIGFIM"}, xFilial("F2B") + jTaxesConfig["cod_regra"], 1, "")    //F2B_FILIAL, F2B_REGRA, F2B_VIGINI, F2B_VIGFIM, F2B_ALTERA

    jImposto["tipoImposto"]                                 := cTipo
    jImposto["cst"]                                         := jTaxesConfig["detalhe_livro"]["cst"]
    //jImposto["descricaoCst"]                                := FAZER DIRETO NO LAYOUT DE ENVIO - retirar do layout de auxiliar
    jImposto["cClassTrib"]                                  := jTaxesConfig["detalhe_livro"]["cclasstrib"]
    jImposto["dataInicioVigencia"]                          := dtos(aRegTribut[1])
    jImposto["dataFimVigencia"]                             := dtos(aRegTribut[2])
    jImposto["percentualAliquota"]                          := jTaxesConfig["regras_aliquota"]["aliquota"]
    jImposto["percentualReducaoAliquota"]                   := jTaxesConfig["regras_aliquota"]["perc_red_aliquota"]
    jImposto["percentualAliquotaEspecificaUnidadeMedida"]   := 0
    jImposto["localConsumo"]                                := maFisRet(, "NF_CODMUN")
    //jImposto["padrao"] := FAZER DIRETO NO LAYOUT DE ENVIO - retirar do layout de auxiliar - enviar sempre False

    aadd(self:aImpostos, {cTipo, Eval({|| x := JsonObject():New(), x:FromJson(jImposto:ToJson()), x})})
    
    fwFreeObj(jImposto)
    fwFreeObj(jTaxesConfig)
    fwFreeArray(aRegTribut)

Return nil
