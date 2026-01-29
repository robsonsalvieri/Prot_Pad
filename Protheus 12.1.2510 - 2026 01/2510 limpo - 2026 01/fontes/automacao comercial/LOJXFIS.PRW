#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "LOJXFIS.CH"

#DEFINE TG_RET_SIGLA  01
#DEFINE TG_RET_BASE   02
#DEFINE TG_RET_VALOR  03
#DEFINE TG_RET_CODREG 04
#DEFINE TG_RET_PRIPAR 05
#DEFINE TG_RET_SALDO  06
#DEFINE TG_RET_CODBAS 07
#DEFINE TG_RET_IDREGR 08
#DEFINE TG_RET_CODURF 09
#DEFINE TG_RET_PERURF 10
#DEFINE TG_NF_IDTRIB  11

#DEFINE TG_NF_ID_REGRA   05

Static lCfgTribOk := Nil //Variável para controlar se o sistema/ambiente está atualizado/apto para usar o Configurador de Tributos

/*/{Protheus.doc} LjCfgTrib
Verifica se o sistema/ambiente está atualizado/preparado para usar o Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@return lógico, Ambiente preparado para Configurador de Tributos
/*/

Function LjCfgTrib()

Local nX as numeric
Local aFontes as array
Local aFonteInfo as array
Local lFontesOK as logical

nX 		   := 0
aFontes    := {}
aFonteInfo := {}
lFontesOK  := .T.

If lCfgTribOk == Nil
	lCfgTribOk := .F.

    If FindClass("totvs.protheus.backoffice.fiscal.tciclass.TCIProcessing")
        //Fontes a serem verificadas suas datas se estão atualizados
        aAdd(aFontes, {"LOJA601.PRW"             , "22/04/2025"})
        aAdd(aFontes, {"LOJA701.PRW"             , "25/04/2025"})
        aAdd(aFontes, {"LOJA701A.PRW"            , "24/04/2025"})
        aAdd(aFontes, {"LOJA701B.PRW"            , "21/04/2025"})
        aAdd(aFontes, {"LOJA701C.PRW"            , "25/04/2025"})
        aAdd(aFontes, {"LOJA701D.PRW"            , "25/04/2025"})        
        aAdd(aFontes, {"LOJA720.PRW"             , "20/04/2025"})
        aAdd(aFontes, {"LOJA950.PRW"             , "25/04/2025"})        
        aAdd(aFontes, {"lojxfunb.prw"            , "25/04/2025"})
        aAdd(aFontes, {"LOJXFUNC.PRW"            , "21/04/2025"})
        aAdd(aFontes, {"LOJXFUNK.PRW"            , "20/04/2025"})
        aAdd(aFontes, {"LOJXPED.PRW"             , "22/04/2025"})        
        aAdd(aFontes, {"LOJSAT.prw"              , "25/04/2025"})
        aAdd(aFontes, {"LOJNFCE.PRW"             , "20/04/2025"})
        aAdd(aFontes, {"LOJR130.PRX"             , "25/04/2025"})
        aAdd(aFontes, {"LOJXDESC.PRW"            , "13/08/2025"})
        aAdd(aFontes, {"STBCalculateTax.prw"     , "23/04/2025"})
        aAdd(aFontes, {"STBDiscountTotalSale.PRW", "21/04/2025"})
        aAdd(aFontes, {"STBFISCALMENU.PRW"       , "20/04/2025"})
        aAdd(aFontes, {"STBItemRegistry.prw"     , "19/08/2025"})

        For nX := 1 To Len(aFontes)
            aFonteInfo := GetAPOInfo(aFontes[nX][1])
            If Len(aFonteInfo) > 0
                If aFonteInfo[4] < CToD(aFontes[nX][2])
                    lFontesOK := .F.
                    Exit
                EndIf
            EndIf
        Next nX

        If lFontesOK
            //Verificacao se pode ou nao utilizar tributos genericos (Configurador de Tributos)
            lCfgTribOk := cPaisLoc == "BRA" .And. FindFunction("ChkTrbGen") .And. ChkTrbGen("SD2", "D2_IDTRIB") .And. ChkTrbGen("SD1", "D1_IDTRIB")
        Else
			Help( " ", 1, "CONFTRIB", , STR0001,1,0,,,,,,{STR0002, STR0003}) //"O sistema não está atualizado para utilizar o novo Configurador Tributário."#"Atualize com o ultimo acumulado do Varejo disponível no portal."#"Entre em contato com o Administrador do Sistema."
            LjGrvLog("LOJXFIS", "Sistema desatualizado para o novo configurador de tributos")
        EndIf           
    EndIf

    LjGrvLog("LOJXFIS", "Configurador de Tributos habilitado?", lCfgTribOk)
EndIf

Return lCfgTribOk

/*/{Protheus.doc} LjCfgTaxById
Verifica tributos no Configurador de Tributos de acordo com o Id do Tributo

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param cIdTax, caracter, Id do tributo
@param nItem, numérico, Item a ser consultado
@param nVlrTax, numérico, taxa do tributo a calcular
@param lAgreg, lógico, Tributo agrega no total

@return lógico, Tributo encontrado
/*/

Function LjCfgTaxById(cIdTax as character, nItem as numeric, nVlrTax as numeric, lAgreg as logical) as logical

Local lResponse as logical

Default nItem := 0
Default nVlrTax := 0
Default lAgreg := .F.

lResponse := .F.

If lCfgTribOk
    If cIdTax == "000018" //IRRF
        lResponse := LjGetIRRF(@nVlrTax)
    ElseIf cIdTax == "000019" //INSS
        lResponse := LjGetINSS()
    ElseIf cIdTax == "000020" //ISS
        lResponse := LjGetISS(nItem)
    ElseIf cIdTax == "000021" //ICMS
        lResponse := LjGetICMS(nItem)
    ElseIf cIdTax == "000022" //IPI
        lResponse := LjGetIPI(nItem, lAgreg)
    ElseIf cIdTax == "000050" //ICMS Desonerado
        lResponse := LjGetICMDES(nItem)
    ElseIf cIdTax == "000056" //ICMS-ST
        lResponse := LjGetICM_ST(lAgreg)
    ElseIf cIdTax $ "000015|000016" //PIS e COFINS
        lResponse := LjGetPISCOF()
    ElseIf cIdTax $ "000044|000046" //PIS-ST e COFINS-ST
        lResponse := LjGetPCOFST()
    ElseIf cIdTax $ "000045|000043|000026" //PCC Retenção
        lResponse := LjGetPCCRet(cIdTax, @nVlrTax)    
    EndIf
EndIf

Return lResponse

/*/{Protheus.doc} LjGetIRRF
Verifica se possui o tributo IRRF no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param nItem, numérico, Item a ser consultado

@return lógico, Tributo encontrado
/*/
Static Function LjGetIRRF(nValorIr as numeric) as logical

Local jTaxesConfig as json
Local jCfgTaxRet as json
Local lAbateTot as logical
Local lResponse as logical

jTaxesConfig := LjCfgTaxes("000018",,, .T.) //Código do tributo IRRF no Configurador de Tributos: 000018
lAbateTot := LjCfgAgreg("000018", 2)

If (lResponse := Len(jTaxesConfig) > 0) 
    If lAbateTot //Abate no total da NF ou Abate Total da NF e Duplicata
        jCfgTaxRet := LjCfgTaxRet()        
        nValorIr := If(jCfgTaxRet:hasproperty("000018"), jCfgTaxRet["000018"]["valor_tributo"], 0)        
    EndIf
EndIf

LjGrvLog("LOJXFIS", "Possui IRRF pelo Configurador de Tributos?", lResponse)

Return lResponse

/*/{Protheus.doc} LjGetINSS
Verifica se possui o tributo INSS no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@return lógico, tributo encontrado
/*/
Static Function LjGetINSS() as logical

Local jCfgTaxRet as json
Local lResponse as logical

//Código do tributo INSS no Configurador de Tributos: 000019
jCfgTaxRet := LjCfgTaxRet()
lResponse := If(jCfgTaxRet:hasproperty("000019") .And. jCfgTaxRet["000019"]["valor_tributo"] > 0, .T., .F.)

LjGrvLog("LOJXFIS", "Possui INSS pelo Configurador de Tributos?", lResponse)
    
Return lResponse

/*/{Protheus.doc} LjGetISS
Verifica se possui o tributo ISS no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param nItem, numérico, Item a ser consultado

@return lógico, Tributo encontrado
/*/
Static Function LjGetISS(nItem as numeric) as logical

Local jTaxesConfig as json
Local lResponse as logical

jTaxesConfig := LjCfgTaxes("000020", nItem) //Código do tributo ISS no Configurador de Tributos: 000020
lResponse := Len(jTaxesConfig) > 0
    
LjGrvLog("LOJXFIS", "Possui ISS pelo Configurador de Tributos?", lResponse)
    
Return lResponse

/*/{Protheus.doc} LjGetICMS
Verifica se possui o tributo ICMS no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param nItem, numérico, Item a ser consultado

@return lógico, Tributo encontrado
/*/
Static Function LjGetICMS(nItem as numeric) as logical

Local jTaxesConfig as json
Local lResponse as logical

jTaxesConfig := LjCfgTaxes("000021", nItem) //Código do tributo ICMS no Configurador de Tributos: 000021
lResponse := Len(jTaxesConfig) > 0    
    
LjGrvLog("LOJXFIS", "Possui ICMS pelo Configurador de Tributos?", lResponse)
    
Return lResponse

/*/{Protheus.doc} LjGetIPI
Verifica se possui o tributo IPI no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param nItem, numérico, Item a ser consultado
@param lSomaTot, lógico, Soma no total

@return lógico, Tributo encontrado
/*/
Static Function LjGetIPI(nItem as numeric, lSomaTot as logical) as logical

Local jTaxesConfig as json
Local lResponse as logical

Default lSomaTot := .F.

lResponse := .F.

jTaxesConfig := LjCfgTaxes("000022", nItem) //Código do tributo IPI no Configurador de Tributos: 000022

If Len(jTaxesConfig) > 0
    If lSomaTot //Soma no total da NF ou Soma Total da NF e Duplicata
        lResponse := LjCfgAgreg("000022", 1)
    Else
        lResponse := .T.
    EndIf
EndIf

LjGrvLog("LOJXFIS", "Possui IPI pelo Configurador de Tributos?", lResponse)

Return lResponse

/*/{Protheus.doc} LjGetICMDES
Verifica se possui o tributo ICMS Desonerado no Configurador de Tributos

@type function
@author Alessandro Santos
@since 23/05/2025
@version P12

@param nItem, numérico, Item a ser consultado

@return lógico, Tributo encontrado
/*/
Static Function LjGetICMDES(nItem as numeric) as logical

Local jTaxesConfig as json
Local lResponse as logical

jTaxesConfig := LjCfgTaxes("000050", nItem) //Código do tributo ICMS Desonerado no Configurador de Tributos: 000050
lResponse := Len(jTaxesConfig) > 0

LjGrvLog("LOJXFIS", "Possui ICMS Desonerado pelo Configurador de Tributos?", lResponse)
    
Return lResponse

/*/{Protheus.doc} LjGetICM_ST
Verifica se possui o tributo ICMS-ST no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param lAbateTot, lógico, Subtrai no total

@return lógico, Tributo encontrado
/*/
Static Function LjGetICM_ST(lAbateTot as logical) as logical

Local jTaxesConfig as json
Local lResponse as logical

Default lAbateTot := .F.

lResponse := .F.

//Abate no total da NF ou Abate Total da NF e Duplicata
If lAbateTot
    lResponse := LjCfgAgreg("000056", 2) //Código do tributo ICMS-ST no Configurador de Tributos: 000056
Else
    jTaxesConfig := LjCfgTaxes("000056") //Código do tributo ICMS-ST no Configurador de Tributos: 000056
    lResponse := Len(jTaxesConfig) > 0
EndIf

LjGrvLog("LOJXFIS", "Possui ICMS-ST pelo Configurador de Tributos?", lResponse)
    
Return lResponse

/*/{Protheus.doc} LjGetPISCOF
Verifica se possui o tributo PIS e COFINS no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@return lógico, Tributo encontrado
/*/
Static Function LjGetPISCOF() as logical

Local jTaxesConfig as json
Local lResponse as logical

lResponse := .F.

jTaxesConfig := LjCfgTaxes("000015") //Código do tributo PIS no Configurador de Tributos: 000015
lResponse := Len(jTaxesConfig) > 0

If !lResponse
    jTaxesConfig := LjCfgTaxes("000016") //Código do tributo COFINS no Configurador de Tributos: 000016
    lResponse := Len(jTaxesConfig) > 0
EndIf

LjGrvLog("LOJXFIS", "Possui PIS ou COFINS pelo Configurador de Tributos?", lResponse)

Return lResponse

/*/{Protheus.doc} LjGetPCOFST
Verifica se possui o tributo PIS-ST e COFINS-ST no Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@return lógico, tributo encontrado
/*/
Static Function LjGetPCOFST() as logical

Local jTaxesConfig as json
Local lResponse as logical

lResponse := .F.

jTaxesConfig := LjCfgTaxes("000046") //Código do tributo PIS-ST no Configurador de Tributos: 000046
lResponse := Len(jTaxesConfig) > 0

If !lResponse
    jTaxesConfig := LjCfgTaxes("000044") //Código do tributo COFINS-ST no Configurador de Tributos: 000044
    lResponse := Len(jTaxesConfig) > 0
EndIf

LjGrvLog("LOJXFIS", "Possui PIS-ST ou COFINS-ST pelo Configurador de Tributos?", lResponse)

Return lResponse

/*/{Protheus.doc} LjGetPCCRet
Verifica se retem os tributos PIS/COFINS/CSLL

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param cIdTax, caracter, Id do tributo
@param nVlrTax, numérico, Valor do tributo calculado

@return lógico, Tributo encontrado
/*/
Static Function LjGetPCCRet(cIdTax as character, nVlrTax as numeric) as logical

Local jCfgTaxRet as json
Local lAbateTot as logical
Local nI as numeric
Local aTaxes as array
Local lResponse as logical

jCfgTaxRet := LjCfgTaxRet()
aTaxes := {}
lResponse := .F.

aEval(StrToKArr(cIdTax, "|"), {|x| aAdd(aTaxes, x)})

//Códigos dos tributos: 000045 = PIS; 000043 = COFINS; 000026 = CSLL
For nI := 1 To Len(aTaxes)
    lAbateTot := LjCfgAgreg(aTaxes[nI], 2)
            
    //Abate no total da NF ou Abate Total da NF e Duplicata
    If lAbateTot
        nVlrTax += If(jCfgTaxRet:hasproperty(aTaxes[nI]), jCfgTaxRet[aTaxes[nI]]["valor_tributo"], 0)
        lResponse := .T.
    EndIf
Next nI

LjGrvLog("LOJXFIS", "Possui retenções para PIS ou COFINS ou CSLL pelo Configurador de Tributos?", lResponse)

Return lResponse

/*/{Protheus.doc} LjCfgAgreg
Verifica se tributo soma ou subtrai no total da venda

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param cIdTax, caracter, Id do tributo
@param nTpVerif, numérico, Soma ou subtrai no total

@return lógico, Acao realizada no total
/*/
Function LjCfgAgreg(cIdTributo as character, nTpVerif as numeric) as logical

Local jTaxesConfig as json
Local lResponse as logical

jTaxesConfig := LjCfgTaxes(cIdTributo,,, .T.)
lResponse := .F.

//Abate no total da NF ou Abate Total da NF e Duplicata
If lCfgTribOk .And. Len(jTaxesConfig) > 0
    If nTpVerif == 1 //Soma
        lResponse := jTaxesConfig[1]:hasproperty("acao_tot_nf") .And. jTaxesConfig[1]["acao_tot_nf"] $ "5|6"                     
    Else //Subtrai
        lResponse := jTaxesConfig[1]:hasproperty("acao_tot_nf") .And. jTaxesConfig[1]["acao_tot_nf"] $ "2|3" 
    EndIf
EndIf

LjGrvLog("LOJXFIS", "Possui "+If(nTpVerif == 1, "soma", "subtracao")+" no total da venda pelo Configurador de Tributos? - Id Tributo: "+cIdTributo, lResponse)

Return lResponse

/*/{Protheus.doc} LjCfgSitTrb
Verifica a situacao tributaria dos itens de venda, substitui as funcoes Lj7Strib e LjSitTrib com 
tratamento para o Configurador de Tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param nItem, numérico, Item da venda
@param lRetailSale, lógico, Chamada durante a Venda Varejo Lj7Strib()
@param cSitTrib, caracter, Situação Tributária enviada pela rotina chamadora
@paramn nAliquota, numérico, Alíquota enviada pela rotina chamadora
@paramn nAliqRed, numérico, Alíquota Reduzida enviada pela rotina chamadora

@return caracter, Situação Tributária do item
/*/
Function LjCfgSitTrb(nItem as numeric, lRetailSale as logical, cSitTrib as character, nAliquota as numeric,; 
    nAliqRed as numeric) as character

Local jTaxesConfig as json
Local cResponse as string
Local lFound as logical

Default nItem := 1
Default lRetailSale := .F.
Default cSitTrib := ""
Default nAliquota := 0
Default nAliqRed := 0

jTaxesConfig := JsonObject():New()
cResponse := If(!Empty(cSitTrib), cSitTrib, "")
lFound := .F.

//Tratamento de tributos no Configurador de Tributos
If lCfgTribOk
    //Tratamento ISS
    jTaxesConfig := LjCfgTaxes("000020", nItem, {"regras_escrituracao", "detalhe_livro"}) //Código do tributo ISS no Configurador de Tributos: 000020
        
    If Len(jTaxesConfig) > 0
        lFound := .T. //Encontrou tributo para o item

        If nAliquota > 0 .Or.; 
            jTaxesConfig[1]["regras_escrituracao"]["incidencia"] == "1" .Or.;
            (jTaxesConfig[1]["regras_escrituracao"]["incidencia"] $ "4|5|7" .And. jTaxesConfig[1]["detalhe_livro"]["valor_tributado"] > 0) //Tributado

            nAliquota := If(nAliquota == 0, jTaxesConfig[1]["aliq_trib"], nAliquota) //Se aliquota envida da origem, mantem, senao, busca no Configurador de Tributos             
            cResponse := If(lRetailSale, "S"+AllTrim(Str(nAliquota, 5, 2)), "S")
        ElseIf jTaxesConfig[1]["regras_escrituracao"]["incidencia"] == "3" .Or.;
            jTaxesConfig[1]["regras_escrituracao"]["incidencia"] $ "4|6|7" .And. (jTaxesConfig[1]["detalhe_livro"]["valor_nao_tribut"] > 0 .Or.;                                    
            jTaxesConfig[1]["detalhe_livro"]["valor_outros"] > 0) //Nao tributado ou Outros
            
            cResponse := If(lRetailSale, "NS1", "NS")
        Else //Isento
            cResponse := If(lRetailSale, "IS1", "IS")
        EndIf            
    EndIf

    If !lFound
        //Tratamento ICMS-ST (Icms Solidario)
        jTaxesConfig := LjCfgTaxes("000056", nItem) //Código do tributo ICMS-ST no Configurador de Tributos: 000056
        
        If Len(jTaxesConfig) > 0
            lFound := .T. //Encontrou tributo para o item
                        
            If MaFisFound("IT", nItem) .And. MaFisRet(nItem, "IT_VALSOL") > 0 //Possui ICMS Solidario
                cResponse := "F"
            Else //Nao sujeito a ICMS
                cResponse := "N"
            EndIf
        EndIf
    EndIf
    
    If !lFound
        //Tratamento ICMS
        jTaxesConfig := LjCfgTaxes("000021", nItem, {"regras_base", "regras_escrituracao", "detalhe_livro"}) //Código do tributo ICMS no Configurador de Tributos: 000021
        
        If Len(jTaxesConfig) > 0                                   
            If nAliquota > 0 .Or.; 
                jTaxesConfig[1]["regras_escrituracao"]["incidencia"] == "1" .Or.;
                (jTaxesConfig[1]["regras_escrituracao"]["incidencia"] $ "4|5|7" .And. jTaxesConfig[1]["detalhe_livro"]["valor_tributado"] > 0) //Tributado
                
                If lRetailSale                                       
                    If nAliqRed > 0 .Or. jTaxesConfig[1]["regras_base"]["perc_reducao"] > 0
                        //Se aliquota reduzida envida da origem, mantem, senao, busca no Configurador de Tributos
                        nAliqRed := If(nAliqRed == 0, jTaxesConfig[1]["regras_base"]["perc_reducao"], nAliqRed)                                                                                                                            			                                                    
                        cResponse := "T"+PadL(StrTran(AllTrim(Str(nAliqRed, 5, 2)), ".", ""), 4, "0") //Com redução de Icms na Base de Cálculo do Tributo
                    Else                        				                        
                        nAliquota := If(nAliquota == 0, jTaxesConfig[1]["aliq_trib"], nAliquota) //Se aliquota envida da origem, mantem, senao, busca no Configurador de Tributos                                                
                        cResponse := "T"+PadL(StrTran(AllTrim(Str(nAliquota, 5, 2)), ".", ""), 4, "0")                        
                    EndIf
                Else                                                
                    cResponse := "T"
                EndIf                                
            ElseIf jTaxesConfig[1]["regras_escrituracao"]["incidencia"] == "2" .Or.;
                (jTaxesConfig[1]["regras_escrituracao"]["incidencia"] $ "4|6|7" .And. jTaxesConfig[1]["detalhe_livro"]["valor_isento"] > 0) //Isento                
                
                cResponse := "I"            
            ElseIf jTaxesConfig[1]["regras_escrituracao"]["incidencia"] == "3" .Or.;
                (jTaxesConfig[1]["regras_escrituracao"]["incidencia"] $ "5|6|7" .And. jTaxesConfig[1]["detalhe_livro"]["valor_outros"] > 0) //Outros
            
                cResponse := "O"
            Else //Nao tributado                                    
                cResponse := "N"                   
            EndIf
        EndIf
    EndIf    
EndIf

LjGrvLog("LOJXFIS", "Possui situação tributária pelo Configurador de Tributos? - SitTrib: "+cResponse, !Empty(cResponse))

FwFreeObj(jTaxesConfig)
jTaxesConfig := Nil

Return cResponse

/*/{Protheus.doc} LjCfgTaxes
Retorna os tributos que estao em processamento na venda pelo Configurador de Tributos, esses tributos
ainda nao foram gravados na F2B, estao em memoria

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param cIdTrib, caracter, Id do tributo
@param nItem, numérico, Item a ser consultado
@param aSetItem, array, propriedade a ser verificada do tributo
@param lAgregType, lógico, Informacoes de agregacao do tributo

@return json, Tributos em memoria do processamento
/*/
Function LjCfgTaxes(cIdTrib as character, nItem as numeric, aSetItem as array, lAgregType as logical) as json

Local oTaxesConfig as object
Local jResponse as json
Local aArea as array

Default cIdTrib := ""
Default nItem := 0
Default aSetItem := {}
Default lAgregType := .F.

aArea := GetArea()
jResponse := JsonObject():New()

If lCfgTribOk .And. MaFisFound()
    // Verifica se a classe do Configurador de Tributos existe no repositório
    If lCfgTribOk
        oTaxesConfig := totvs.protheus.backoffice.fiscal.tciclass.TCIProcessing():New()
        jResponse := LjCfgFilt(oTaxesConfig, cIdTrib, nItem, aSetItem, lAgregType)
    EndIf

    FwFreeObj(oTaxesConfig)
    oTaxesConfig := Nil
EndIf

LjGrvLog("LOJXFIS", "Possui informações de tributos pelo Configurador de Tributos? - Id Tributo: "+cIdTrib, Len(jResponse) > 0)

RestArea(aArea)

Return jResponse

/*/{Protheus.doc} LjCfgFilt
Filtra os tributos e retorna as informacoes encontradas

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@param oTaxesConfig, objeto, Instância da classe TCIProcessing
@param cIdTrib, caracter, Id do tributo
@param nItem, numérico, Item a ser consultado
@param aSetItem, array, propriedade a ser verificada do tributo

@return array, Informações dos Tributos em memoria
/*/
Static Function LjCfgFilt(oTaxesConfig as object, cIdTrib as character, nItem as numeric, aSetItem as array,;
    lAgregType as logical) as array

Local cTaxesConfig as character
Local cCfgTax as character
Local cPropTrib as character
Local cItem as character
Local nI as numeric
Local nX as numeric
Local aFiltered as array
Local aItens as array
Local aTaxes as array
Local jTaxesConfig as json

cCfgTax := ""
aFiltered := {}
aItens := {}
aTaxes := {}
jTaxesConfig := JsonObject():New()

If lAgregType
    If MethIsMemberOf(oTaxesConfig, "getAgregTypeByTax")
        oTaxesConfig:setDataItems({"regras_escrituracao"})
        cTaxesConfig := oTaxesConfig:getAgregTypeByTax()
        jTaxesConfig:FromJson(cTaxesConfig)
        cCfgTax := "data"
        cPropTrib := "id_totvs"
    EndIf
Else
    If Len(aSetItem) > 0 //Se enviado regra                   
       oTaxesConfig:setDataItems(aSetItem)
    EndIf

    cTaxesConfig := oTaxesConfig:GetDataItems()
    jTaxesConfig:FromJson(cTaxesConfig)
    cCfgTax := "dados_itens"
    cPropTrib := "ident_trib"
EndIf

If !jTaxesConfig:hasproperty("erro") .And. !Empty(cCfgTax)
    If jTaxesConfig:hasproperty(cCfgTax)
        aItens := jTaxesConfig[cCfgTax]:GetNames()
    EndIf

    For nI := 1 To Len(aItens)
        cItem := aItens[nI]
        
        If jTaxesConfig[cCfgTax]:hasproperty(cItem)
            aTaxes := jTaxesConfig[cCfgTax][cItem]:GetNames()
        EndIf
            
        For nX := 1 To Len(aTaxes)
            If !jTaxesConfig[cCfgTax][cItem]:hasproperty("Aviso")
                If (Empty(cIdTrib) .And. nItem == 0) //Todos os tributos e todos os itens
                    aAdd(aFiltered, jTaxesConfig[cCfgTax][cItem][aTaxes[nX]])
                    aFiltered[Len(aFiltered)]["item"] := nI                                
                ElseIf (Empty(cIdTrib) .And. nI == nItem) //Todos os tributos e item informado
                    aAdd(aFiltered, jTaxesConfig[cCfgTax][cItem][aTaxes[nX]])
                    aFiltered[Len(aFiltered)]["item"] := nI
                ElseIf (!Empty(cIdTrib) .And. nItem == 0) .And.; 
                    jTaxesConfig[cCfgTax][cItem][aTaxes[nX]][cPropTrib] == cIdTrib //Tributo informado e todos os itens                
                    
                    aAdd(aFiltered, jTaxesConfig[cCfgTax][cItem][aTaxes[nX]])
                    aFiltered[Len(aFiltered)]["item"] := nI                
                ElseIf (!Empty(cIdTrib) .And. nI == nItem) .And.;
                    jTaxesConfig[cCfgTax][cItem][aTaxes[nX]][cPropTrib] == cIdTrib //Tributo informado e item informado
                    
                    aAdd(aFiltered, jTaxesConfig[cCfgTax][cItem][aTaxes[nX]])
                    aFiltered[Len(aFiltered)]["item"] := nI
                EndIf
            EndIf
        Next nX
    Next nI
EndIf

aSize(aItens, 0)
FwFreeArray(aItens)

aSize(aTaxes, 0)
FwFreeArray(aTaxes)

FwFreeObj(jTaxesConfig)
jTaxesConfig := Nil

Return aFiltered

/*/{Protheus.doc} LjCfgTaxRet
Retorna informacoes dos tributos com retencoes utilizados no Configurador de tributos

@type function
@author Alessandro Santos
@since 19/04/2025
@version P12

@return array, Informacoes dos tributos de retencoes configurados
/*/
Function LjCfgTaxRet() as json

Local aArea as array
Local aTGCalc as array
Local aTGRet as array
Local aTGCalcRet as array
Local aTGCalcRec as array
Local cIdTrib as character
Local nI as numeric
Local nPos as numeric
Local jTGCalcRet as json
Local jCfgTaxRet as json

aArea := GetArea()
aTGCalc := {}
aTGRet := {}
aTGCalcRet := {}
aTGCalcRec := {}
nI := 0
jCfgTaxRet := JsonObject():New()

If lCfgTribOk
    //Busca tributos de retencoes no Configurador de Tributos
    FisRetGen(aTGCalc, aTGRet, .T., aTGCalcRet, aTGCalcRec, dDataBase)
    
    For nI := 1 to Len(aTGCalcRet)
        jTGCalcRet := JsonObject():New()
        jTGCalcRet["sigla_tributo"] := AllTrim(aTGCalcRet[nI][TG_RET_SIGLA])
        jTGCalcRet["base_tributo"] := aTGCalcRet[nI][TG_RET_BASE]
        jTGCalcRet["valor_tributo"] := aTGCalcRet[nI][TG_RET_VALOR]
        jTGCalcRet["codigo_regra"] := AllTrim(aTGCalcRet[nI][TG_RET_CODREG])
        jTGCalcRet["retem_integr_prim_parcela"] := aTGCalcRet[nI][TG_RET_PRIPAR]
        jTGCalcRet["saldo_valor_tributo"] := aTGCalcRet[nI][TG_RET_SALDO]
        jTGCalcRet["codigo_base_tributos"] := aTGCalcRet[nI][TG_RET_CODBAS]
        jTGCalcRet["id_regra"] := aTGCalcRet[nI][TG_RET_IDREGR]
        jTGCalcRet["codigo_urf"] := AllTrim(aTGCalcRet[nI][TG_RET_CODURF])
        jTGCalcRet["percentual_urf"] := aTGCalcRet[nI][TG_RET_PERURF]
       
        If Len(aTGCalc) > 0
            nPos := aScan(aTGCalc, {|x| x[TG_NF_ID_REGRA] == jTGCalcRet["id_regra"]})

            If nPos > 0
                cIdTrib := aTGCalc[nPos][TG_NF_IDTRIB] 
            EndIf        
        EndIf

        jCfgTaxRet[cIdTrib] := jTGCalcRet
    Next nI
        
    aSize(aTGCalc, 0)
    FwFreeArray(aTGCalc)

    aSize(aTGRet, 0)
    FwFreeArray(aTGRet)

    aSize(aTGCalcRet, 0)
    FwFreeArray(aTGCalcRet)

    aSize(aTGCalcRec, 0)
    FwFreeArray(aTGCalcRec)

    FreeObj(jTGCalcRet)
    jTGCalcRet := Nil    
EndIf

LjGrvLog("LOJXFIS", "Possui informações de retenções pelo Configurador de Tributos?", Len(jCfgTaxRet)> 0)

RestArea(aArea)

Return jCfgTaxRet

/*/{Protheus.doc} LjCfgISSST
Retorna De-Para da Natureza de Operacao do imposto ISS-ST

@type function
@author Alessandro Santos
@since 09/05/2025
@version P12

@return caracter, Codigo da natureza de Operacao do ISS-ST
/*/
Function LjCfgISSST(cSitTrib as character) as character

Local cResponse as character

Default cSitTrib := ""

cResponse := SF4->F4_ISSST

//Tratamento De-Para do campo F4_ISSST em análise pelo time fiscal, permanecerá usando o campo da TES
//até ajuste da área responsável, na única chamada pela LOJNFCE está posicionado na TES correta do produto

/*
If AllTrim(cSitTrib) == "00"
    cResponse := "1"
ElseIf AllTrim(cSitTrib) == "06"
    cResponse := "3"
ElseIf Empty(cSitTrib) .Or. AllTrim(cSitTrib) == "07"
    cResponse := "2"
ElseIf AllTrim(cSitTrib) == "08"
    cResponse := "5"
ElseIf AllTrim(cSitTrib) == "09"
    cResponse := "6"
EndIf
*/

Return cResponse

/*/{Protheus.doc} LjCfgSetTot
Alimenta valores de soma ou subtracao dos impostos novos e genericos

@type function
@author Alessandro Santos
@since 15/07/2025
@version P12

@param cIdTrib, caracter, Id do tributo
@param nItem, numérico, Item a ser consultado

@return array, Array com valor de soma e subtracao no total
/*/
Function LjCfgSetTot(cIdTrib as character, nItem as numeric) as array

Local jTaxesConfig as json
Local nTrbSoma as numeric
Local nTrbSub as numeric
Local nI as numeric

Default cIdTrib := ""

jTaxesConfig := LjCfgTaxes(cIdTrib, nItem, {"regras_escrituracao"})
nTrbSoma := 0
nTrbSub := 0

For nI := 1 To Len(jTaxesConfig)    
    If jTaxesConfig[nI]:hasproperty("regras_escrituracao") .And. jTaxesConfig[nI]["regras_escrituracao"]:hasproperty("acao_tot_nf")            
        If jTaxesConfig[nI]["regras_escrituracao"]["acao_tot_nf"] $ "5|6"
            nTrbSoma += If(jTaxesConfig[nI]:hasproperty("val_trib"), jTaxesConfig[nI]["val_trib"], 0)
        ElseIf jTaxesConfig[nI]["regras_escrituracao"]["acao_tot_nf"] $ "2|3" 
            nTrbSub += If(jTaxesConfig[nI]:hasproperty("val_trib"), jTaxesConfig[nI]["val_trib"], 0)
        EndIf
    EndIf
Next nI

FwFreeObj(jTaxesConfig)
jTaxesConfig := Nil

Return {nTrbSoma, nTrbSub}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjJsonDKM
Gera o objeto JSON com os dados de tributação provenientes da tabela DKM, para vendas de integração.

@type       Function
@author     Evandro Pattaro
@since      02/12/2025
@version    12

@return jTribGen (JsonObject) - Objeto JSON com os dados de tributação gerados a partir da tabela DKM.
/*/
//-------------------------------------------------------------------------------------
Function LjJsonDKM()
Local jTribGen	:= Nil
Local cQuery	:= ""
Local oQuery 	:= Nil  
Local cIdTrib	:= ""
Local cAliasDKM := ""
Local cPosItem	:= ""
Local aOrigem	:= {'PSH'}  

	cQuery := " SELECT * FROM "+ RetSQLName("DKM")
	cQuery += " WHERE DKM_FILIAL = ? "
	cQuery += "   AND DKM_DOC = ? "
	cQuery += "   AND DKM_SERIE = ? "
	cQuery += "   AND DKM_ITEM = ? "
	cQuery += "   AND DKM_ORIGEM IN (?) "
	cQuery += "   AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	oQuery := FwExecStatement():New(cQuery)
	oQuery:SetString(1, xFilial("DKM")  )   // #1
	oQuery:SetString(2, SL2->L2_DOC )   	// #2
	oQuery:SetString(3, SL2->L2_SERIE )  	// #3
	oQuery:SetString(4, SL2->L2_ITEM )   	// #4
	oQuery:SetIn(5,aOrigem)				 	// #5

	cAliasDKM := oQuery:OpenAlias()

	If (cAliasDKM)->(!Eof())
		jTribGen := JsonObject():New()
		cPosItem := ALLTRIM(str(VAL((cAliasDKM)->DKM_ITEM)))
		jTribGen[cPosItem] := JsonObject():New()

		While (cAliasDKM)->(!eof())	
			cIdTrib := Alltrim((cAliasDKM)->DKM_IDTRIB)

			jTribGen[cPosItem][cIdTrib] := JsonObject():New()
			jTribGen[cPosItem][cIdTrib]["base_valor"] := (cAliasDKM)->DKM_BASE
			jTribGen[cPosItem][cIdTrib]["aliquota"] := (cAliasDKM)->DKM_ALIQ
			jTribGen[cPosItem][cIdTrib]["valor"] := (cAliasDKM)->DKM_VALOR
			jTribGen[cPosItem][cIdTrib]["base_quantidade"] := (cAliasDKM)->DKM_BASE			
			jTribGen[cPosItem][cIdTrib]["base_um"] := ""
 			jTribGen[cPosItem][cIdTrib]["esc_CST"] := (cAliasDKM)->DKM_CST
			jTribGen[cPosItem][cIdTrib]["esc_CCT"] := (cAliasDKM)->DKM_CLASTR
			jTribGen[cPosItem][cIdTrib]["esc_vl_tributado"] := (cAliasDKM)->DKM_VALOR
			jTribGen[cPosItem][cIdTrib]["esc_vl_isento"] := 0
			jTribGen[cPosItem][cIdTrib]["esc_vl_outros"] := 0
			jTribGen[cPosItem][cIdTrib]["esc_vl_diferido"] := (cAliasDKM)->DKM_VDIF
			jTribGen[cPosItem][cIdTrib]["esc_pc_diferido"] := (cAliasDKM)->DKM_PDIF
			jTribGen[cPosItem][cIdTrib]["esc_pc_reducao_base"] := 0
			jTribGen[cPosItem][cIdTrib]["esc_base_original"] := (cAliasDKM)->DKM_XMLBAS
			jTribGen[cPosItem][cIdTrib]["esc_pc_reducao_aliq"] := (cAliasDKM)->DKM_PREDAL
			jTribGen[cPosItem][cIdTrib]["esc_aliquota_original"] := (cAliasDKM)->DKM_ALQEFE

			(cAliasDKM)->( DBSkip() )
		EndDo

	EndIf

    (cAliasDKM)->(DBCloseArea())
    oQuery:Destroy()
    FwFreeObj(oQuery)	

Return jTribGen
