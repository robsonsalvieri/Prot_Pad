#INCLUDE "TOTVS.CH"
#include 'Fileio.CH'
#INCLUDE "QLTQueryManager.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

#DEFINE BIND_DADOS 1
#DEFINE BIND_TIPO  2

Static oCacheDados := Nil
Static slIndAvQEL  := Nil
Static slIndAvQER  := Nil
/*/{Protheus.doc} QLTQCmpFil

Retorna Query de Comparação das Filiais para Utilização em Query SQL

*** CUIDADO - UTILIZE APENAS EM CONDIÇÃO ESPECÍFICA ONDE EXISTEM RELACIONAMENTOS LEGADO QUE IMPEDEM A UTILIZAÇÃO DE OUTRA FORMA - CUIDADO ***
*** CUIDADO -                                                         E                                                         - CUIDADO ***
*** CUIDADO - EM LOCAL ONDE JÁ POSSUA O MENOR NÚMERO DE REGISTROS POSSÍVEIS POR FILTRAGEM PARA REDUZIR O IMPACTO DE PERFORMANCE - CUIDADO ***

*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO

EXEMPLO:
    cQuery += " SELECT ALIAS_A.*, ALIAS_B.* "
    cQuery += " FROM  "
    cQuery +=      "(SELECT CAMPO_A, CAMPO_B "
    cQuery +=     " FROM TABELA_A "
    cQuery +=     " WHERE   D_E_L_E_T_ = ' ' "
    cQuery +=         " AND CONDICAO1 "
    cQuery +=         " AND CONDICAO2 "
    cQuery +=         " AND TABELA_A_FILIAL = '" + xFilial("TABELA_A") + "') AS ALIAS_A, "
    cQuery +=      "(SELECT CAMPO_C, CAMPO_D "
    cQuery +=     " FROM TABELA_B "
    cQuery +=     " WHERE   D_E_L_E_T_=' ' "
    cQuery +=         " AND CONDICAO3 "
    cQuery +=         " AND CONDICAO4) AS ALIAS_B "
    cQuery += " WHERE " + QLTQCmpFil("TABELA_A", "TABELA_B", "ALIAS_A", "ALIAS_B")

@type  Function
@author brunno.costa
@since 15/09/2021
@version P12.1.33

@param 01 - cAliasA  , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cAliasB  , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 03 - cPrefAliA, caracter, primeiro prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@param 04 - cPrefAliB, caracter, SEGUNDO  prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@param 05 - cBanco, caracter, retorna o banco para consideração na utilização do processo
@return cWhere, caracter, string contendo a compararação para filtro das filiais
/*/
Function QLTQCmpFil(cAliasA, cAliasB, cPrefAliA, cPrefAliB, cBanco)
    Local oManager := QLTQueryManager():New(cBanco)
Return oManager:MontaQueryComparacaoFiliais(cAliasA, cAliasB, cPrefAliA, cPrefAliB)

/*/{Protheus.doc} QLTQCmpFiE

Retorna Query de Comparação das Filiais para Utilização em Query SQL

*** CUIDADO - UTILIZE APENAS EM CONDIÇÃO ESPECÍFICA ONDE EXISTEM RELACIONAMENTOS LEGADO QUE IMPEDEM A UTILIZAÇÃO DE OUTRA FORMA - CUIDADO ***
*** CUIDADO -                                                         E                                                         - CUIDADO ***
*** CUIDADO - EM LOCAL ONDE JÁ POSSUA O MENOR NÚMERO DE REGISTROS POSSÍVEIS POR FILTRAGEM PARA REDUZIR O IMPACTO DE PERFORMANCE - CUIDADO ***

*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO
*** A MÁ UTILIZAÇÃO DESTE MÉTODO EM QUERY'S NÃO OTIMIZADAS OU EM TABELAS COM MUITOS REGISTROS PODERÃO OCASIONAR LENTIDÃO

*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***

EXEMPLO:
    cQuery += " SELECT ALIAS_A.*, ALIAS_B.* "
    cQuery += " FROM  "
    cQuery +=      "(SELECT CAMPO_A, CAMPO_B "
    cQuery +=     " FROM TABELA_A "
    cQuery +=     " WHERE   D_E_L_E_T_ = ' ' "
    cQuery +=         " AND CONDICAO1 "
    cQuery +=         " AND CONDICAO2 "
    cQuery +=         " AND TABELA_A_FILIAL = '" + xFilial("TABELA_A") + "') AS ALIAS_A, "
    cQuery +=      "(SELECT CAMPO_C, CAMPO_D "
    cQuery +=     " FROM TABELA_B "
    cQuery +=     " WHERE   D_E_L_E_T_=' ' "
    cQuery +=         " AND CONDICAO3 "
    cQuery +=         " AND CONDICAO4) AS ALIAS_B "
    cQuery += " WHERE " + QLTQCmpFiE("TABELA_A", "TABELA_B", "ALIAS_A.CAMPO_A", "ALIAS_B.CAMPO_C")

@type  Function
@author brunno.costa
@since 15/09/2021
@version P12.1.33

@param 01 - cAliasA, caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cCampoA, caracter, primeiro campo para comparação (já com prefixo de alias)
@param 03 - cAliasB, caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cCampoB, caracter, segundo  campo para comparação (já com prefixo de alias)
@param 05 - cBanco, caracter, retorna o banco para consideração na utilização do processo
@return cWhere, caracter, string contendo a compararação para filtro das filiais
/*/
Function QLTQCmpFiE(cAliasA, cCampoA, cAliasB, cCampoB, cBanco)
    Local oManager := QLTQueryManager():New(cBanco)
Return oManager:MontaQueryComparacaoFiliaisComCamposEspecificos(cAliasA, cCampoA, cAliasB, cCampoB)

Main Function QLTQueryMa()
Return MIL

/*/{Protheus.doc} QLTQueryManager
@type  Classe
@author brunno.costa
@since 22/02/2022
@version P12.1.37
/*/
CLASS QLTQueryManager FROM LongNameClass

    DATA aMsgErro as Array
    DATA cBanco   as String
    
    METHOD new(cBanco) Constructor

    METHOD acertaConcatenacaoComConcat(cPrefixo, cCampos)
    METHOD ajustaCamposNotaParaArray(aCampos, cAlias)
    Method ajustaCamposNotaParaComparacaoEmQuery(cAlias, cPonteiro, cPrefixo, cPontCmpar)
    METHOD autoCobertura()
    METHOD buscaRoteiroDaOP(cFilQPR, cOP)
    METHOD buscaRoteiroDaOPPorQPK(nRecnoQPK)
    METHOD changeQuery(cWhere)
    METHOD checaModoDeAcesso(cAlias)
    METHOD comparacaoFiliais(cAliasA, cFilialA, cAliasB, cFilialB)
    METHOD confirmaNecessidadeDeExecucaoMensalViaSemaforo(cVersao, cModulo)
    METHOD executeQuery(cQuery, lFwExecSta)
    METHOD gravaCamposNISERI()
    METHOD montaFiltroRastroCampo(cRastro, cConcatenado, cCampoNA, cCampoNB, cCampoLote, cCampoSubLote, lAddAnd)
    METHOD montaFiltroRastroValor(cRastro, cValorLote, cCampoNA, cCampoNB, cCampoLote, cCampoSubLote, lAddAnd)
    METHOD montaInnerJoinSC2ComDesvioRoteiroConhecido(cCampoRoteiro, cCampoOP, cRoteiro, aBindParam)
    METHOD montaQueryComparacaoFiliais(cAliasA, cAliasB, cPrefAliA, cPrefAliB)
    METHOD montaQueryComparacaoFiliaisComCamposEspecificos(cAliasA, cCampoA, cAliasB, cCampoB)
    METHOD montaQueryComparacaoFiliaisComValorReferencia(cAliasA, cCampoA, cAliasB, cFilialB)
    METHOD montaRelacaoCamposNotaCampoACampo(cPrefA, cCamposA, cPrefB, cCamposB)
    METHOD montaRelacaoCamposNotaDerivado(cPrefA, cCamposA, cPrefB, cCamposB)
    METHOD montaRelationArraysCampos(cAliasA, aCamposA, cAliasB, aCamposB)
    METHOD montaRelationC2OP(cCampo)
    METHOD montaRelationCampoConcatenado(cConcatenado, cCampoLote, cCampoSubLote, lSomenteLote)
    METHOD montaRelationQEKNISERI(cPrefi, cCpoNF, cCpoSer, cCpoItem, cConcatenado)
    METHOD montaRelationQEKNISERIArray(cPrefi, cCampos, cConcatenado)
    METHOD montaRelationValorLote(cLote, cCampoLote, cCampoSubLote, lSomenteLote)
    METHOD retornaCampoChaveNotaParaArray(cAlias)
    METHOD retornaCampoFilial(cAlias)
    METHOD retornaCamposDaNotaFiscalParaChaveDePesquisa(cAlias, lPonteiro, cPonteiro)
    METHOD retornaCamposNotaParaSelect(cAlias, cPrefixo)
    METHOD retornaCoalesceNota(cAlias, aPrefixo, cDefault, cAliasNm)
    METHOD retornaFiltroLikeNota(cAlias, cPrefixo, cValor)
    METHOD retornaTamanhoDosCamposDaNotaFiscal(cAlias)
    METHOD retornaTamanhosLayout(nTamEmp, nTamUnid, nTamFil)
    METHOD retornaValorChaveNotaDeRegistro(oReg, cAlias)
    METHOD retornaValorConcatenadoNota(cAlias)
    METHOD retornaVerificacaoNullNota(cAlias, cPrefixo)
    METHOD validaComparacaoCamposNotaQELComQEK()
    METHOD validaCompartilhamentoEspecifico(cTabela, cModoEmp, cModoUnid, cModoFil, lExibeHelp)
    METHOD validaDadosDaFilial(cAliasRef, cAliasCpo, cCampo, lExibeHelp, aRecnos)
    METHOD validaIndiceNotaAvulsoDoAlias(cAlias)
    METHOD validaIndiceNotaAvulsoNaQEL()
    METHOD validaIndiceNotaAvulsoNaQER()
    METHOD validaMesmosCompartilhamentos(aTabelas, cModelo, lExibeHelp)
    METHOD validaTamanhoCamposChaveNF(cAliasA, cAliasB, cCmpNISERI, cAliasOLD)

    Static METHOD bindSQLParameters(oExec, aBindParam)
    Static Method dbSeek(cAlias, cMSUID, cCampoFil, cCampoUID)
    Static METHOD defaultChangeQueryWithCache(cQuery)
    Static METHOD executeQueryWithBind(cQuery, aBindParam, lChangeQuery)

    
ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@since 22/02/2022
@version P12.1.37
@param 01 - cBanco, caracter, retorna o banco para consideração na utilização do processo
@return Self, objeto, instancia da Classe QLTQueryManager
/*/
METHOD new(cBanco) CLASS QLTQueryManager
   Default cBanco := TCGetDB()
   Self:cBanco                       := cBanco
   Self:aMsgErro                     := {}
   oCacheDados                       := Iif(oCacheDados           == Nil            , JsonObject():New(), oCacheDados                      )
   oCacheDados['tabela']             := Iif(oCacheDados['tabela'] == Nil            , JsonObject():New(), oCacheDados['tabela']            )
   oCacheDados['defaultChangeQuery'] := Iif(oCacheDados['defaultChangeQuery'] == Nil, JsonObject():New(), oCacheDados['defaultChangeQuery'])
Return Self

/*/{Protheus.doc} bindSQLParameters
Realiza BIND de parâmetros SQL
@since 01/10/2024
@version P12.1.2410
@param 01 - oExec     , objeto, instancia da classe FwExecStatement
@param 02 - aBindParam, array , array com os dados dos parâmetros para BIND:
                      {{oDados, cTipo}, {}, ...}
                      Sendo cTipo:
                      N -> Número, para uso com FwExecStatement():setNumeric()
                      S -> String, para uso com FwExecStatement():setString()
                      A -> Array , para uso com FwExecStatement():setInArray()
                      U -> Número, para uso com FwExecStatement():setUnsafe()
@return Self, objeto, instancia da Classe QLTQueryManager
/*/
Static METHOD bindSQLParameters(oExec, aBindParam) CLASS QLTQueryManager
    Local nItem       := 0   
    Local nParametros := Len(aBindParam)

    For nItem := 1 to nParametros
        Do Case
            Case aBindParam[nItem, BIND_TIPO] == "S"
                oExec:setString(nItem, aBindParam[nItem, BIND_DADOS])

            Case aBindParam[nItem, BIND_TIPO] == "A"
                oExec:setIn(nItem, aBindParam[nItem, BIND_DADOS])

            Case aBindParam[nItem, BIND_TIPO] == "N"
                oExec:setNumeric(nItem, aBindParam[nItem, BIND_DADOS])
            
            Case aBindParam[nItem, BIND_TIPO] == "U"
                oExec:setUnsafe(nItem, aBindParam[nItem, BIND_DADOS])
        EndCase
    Next

Return 

/*/{Protheus.doc} ChecaModoDeAcesso
Construtor da Classe
@since 07/07/2023
@author brunno.costa/rafael.hesse
@version P12.1.2230
@param 01 - cAlias, caracter, alias para identificação do modo de acesso
@param 02 - nModo, numerico, indica qual o modo de compartilhamento sendo:
            1=Empresa 
            2=Unidade de Negócio 
            3=Filial
@return Self, objeto, instancia da Classe QLTQueryManager
/*/
METHOD checaModoDeAcesso(cAlias, nModo) CLASS QLTQueryManager
   oCacheDados['tabela'][cAlias + Str(nModo)] := Iif(oCacheDados['tabela'][cAlias + Str(nModo)] == Nil, FWModeAccess(cAlias, nModo), oCacheDados['tabela'][cAlias + Str(nModo)])
Return oCacheDados['tabela'][cAlias + Str(nModo)]

/*/{Protheus.doc} AutoCobertura
Função de Auto Cobertura da Classe - Necessário fazer alterações no modo de compartilhamento das tabelas para os desvios padrões
@since 22/02/2022
@version P12.1.37

Dicas:
- Corrompa a filial de um registro no campo QDH_FILIAL com base no padrão de compartilhamento da QDH;
- Corrompa a filial de um registro no campo QDH_FILMAT com base no padrão de compartilhamento da QAA;
- Deixe o modo de compartilhamento da QD0 diferente da QDH;
- Deixe o modo de compartilhamento da QAB diferente de EEE;
/*/
METHOD autoCobertura() CLASS QLTQueryManager

    Local oCobertura := QLTQueryManager():New()
    Local oMSSQL     := QLTQueryManager():New("MSSQL")
    Local oOracle    := QLTQueryManager():New("ORACLE")
    Local oPostgres  := QLTQueryManager():New("POSTGRES")

    oMSSQL:ChangeQuery("")
	oOracle:ChangeQuery("")
	oPostgres:ChangeQuery("")

	oCobertura:ValidaMesmosCompartilhamentos({'QDH','QD0','QD1','QD2','QD4','QD5','QD6','QD7','QD8','QD9','QDA','QDB','QDD','QDE','QDF','QDG','QDJ','QDL','QDM','QDN','QDP','QDR','QDS','QDU','QDZ','QAG','QAH','QAI'}, "QDH", .T.)
    oCobertura:MontaQueryComparacaoFiliaisComCamposEspecificos("QAA", "QAA_FILIAL", "QAA", "QDH_FILMAT")
    oCobertura:ValidaDadosDaFilial("QAA", "QDH", "QDH_FILMAT", .T.)
    oCobertura:ValidaDadosDaFilial("QAA")
    oCobertura:ValidaDadosDaFilial("SB1")
    QLTQCmpFil("QAA", "QDH", "", "", "MSSQL")
    QLTQCmpFiE("QAA", "QAA_FILIAL", "QAA", "QDH_FILMAT", "MSSQL")
	
    //Msg de Help
    oCobertura:ValidaMesmosCompartilhamentos({'QDH','QAA','QAB'}, "QDH", .T.)
    oCobertura:ValidaCompartilhamentoEspecifico("QAB", "C", "C", "C", .T.)
    oCobertura:ValidaDadosDaFilial("SA1", "SA1", "A1_NOME", .T.)

    oCobertura:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "teste")
    oCobertura:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "teste")
    oCobertura:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "teste", oCobertura:aMsgErro)

Return

/*/{Protheus.doc} montaQueryComparacaoFiliais
Retorna Query de Comparação das Filiais para Utilização em Query SQL
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasA  , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cAliasB  , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 03 - cPrefAliA, caracter, primeiro prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@param 04 - cPrefAliB, caracter, SEGUNDO  prefixo de alias para análise do campo filial, por exemplo 'SB1' para considera SB1.B1_FILIAL
@return cWhere, caracter, string contendo a compararação para filtro das filiais
/*/
METHOD montaQueryComparacaoFiliais(cAliasA, cAliasB, cPrefAliA, cPrefAliB) CLASS QLTQueryManager

    Local cCompEmpA := ""
    Local cCompEmpB := ""
    Local cCompFilA := ""
    Local cCompFilB := ""
    Local cCompUniA := ""
    Local cCompUniB := ""
    Local cCpoFilA  := ""
    Local cCpoFilB  := ""
    Local cModFullC := ""
    Local cModoA    := ""
    Local cModoB    := ""
    Local cWhere    := ""
    Local nLeft     := 0
    Local nTamEmp   := 0
    Local nTamFil   := 0
    Local nTamUnid  := 0

    Default cPrefAliA := ""
    Default cPrefAliB := ""

    If !Empty(cAliasA) .AND. !Empty(cAliasB)
        cCompEmpA := AllTrim(Self:ChecaModoDeAcesso(cAliasA, 1))
        cCompEmpB := AllTrim(Self:ChecaModoDeAcesso(cAliasB, 1))
        cCompUniA := AllTrim(Self:ChecaModoDeAcesso(cAliasA, 2))
        cCompUniB := AllTrim(Self:ChecaModoDeAcesso(cAliasB, 2))
        cCompFilA := AllTrim(Self:ChecaModoDeAcesso(cAliasA, 3))
        cCompFilB := AllTrim(Self:ChecaModoDeAcesso(cAliasB, 3))

        cModoA := cCompEmpA + cCompUniA + cCompFilA
        cModoB := cCompEmpB + cCompUniB + cCompFilB

        If cModoA == "CCC" .OR. cModoB == "CCC"
            cWhere := " 1 = 1 " //Quando uma das tabelas está totalmente compartilhada, não há necessidade do RELATION

        ElseIf cModoA == cModoB
            cCpoFilA := Iif(!Empty(cPrefAliA), cPrefAliA + ".", "") + Self:RetornaCampoFilial(cAliasA)
            cCpoFilB := Iif(!Empty(cPrefAliB), cPrefAliB + ".", "") + Self:RetornaCampoFilial(cAliasB)

            cWhere := cCpoFilA + " = " + cCpoFilB

        Else
            
            Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)

            cModFullC := ""
            cModoA    := ""
            cModoB    := ""

            If nTamEmp  != 0 
                cModFullC += "C"
                cModoA    += cCompEmpA
                cModoB    += cCompEmpB
                If cCompEmpA == "E" .AND. cCompEmpB == "E"
                    nLeft += nTamEmp //Trunca comparação sempre pela menor exclusividade
                EndIf
            EndIf

            If nTamUnid != 0 
                cModFullC += "C"
                cModoA    += cCompUniA
                cModoB    += cCompUniB
                If cCompUniA == "E" .AND. cCompUniB == "E"
                    nLeft += nTamUnid //Trunca comparação sempre pela menor exclusividade
                EndIf
            EndIf
            
            If nTamFil  != 0 
                cModFullC += "C"
                cModoA    += cCompFilA
                cModoB    += cCompFilB
                If cCompFilA == "E" .AND. cCompFilB == "E"
                    nLeft += nTamFil //Trunca comparação sempre pela menor exclusividade
                EndIf
            EndIf

            If cModoA == cModFullC .OR. cModoB == cModFullC
                cWhere := " 1 = 1 " //Quando uma das tabelas está totalmente compartilhada, não há necessidade do RELATION

            Else
                cCpoFilA := Iif(!Empty(cPrefAliA), cPrefAliA + ".", "") + Self:RetornaCampoFilial(cAliasA)
                cCpoFilB := Iif(!Empty(cPrefAliB), cPrefAliB + ".", "") + Self:RetornaCampoFilial(cAliasB)

                cWhere   :=    "RTRIM(SUBSTRING("+ cCpoFilA + ", 1, " + cValToChar(nLeft) + " )) "
                cWhere   += " = RTRIM(SUBSTRING("+ cCpoFilB + ", 1, " + cValToChar(nLeft) + " )) "

            EndIf
        EndIf
    EndIf

    cWhere := Self:ChangeQuery(cWhere)

Return cWhere

/*/{Protheus.doc} retornaCampoFilial
Retorna o Campo de Filial Padrão Correspondente ao Alias
@since 22/02/2022
@version P12.1.37
@param 01 - cAlias, caracter, alias para análise
@return cCpoFilial, caracter, nome do campo de filial padrão do registro no cAlias
/*/
METHOD retornaCampoFilial(cAlias) CLASS QLTQueryManager
    Local cCpoFilial := ""
    If Left(cAlias, 1) == "S"
        cCpoFilial := Right(cAlias, 2) + "_FILIAL"
    Else
        cCpoFilial := cAlias + "_FILIAL"
    EndIf
Return cCpoFilial

/*/{Protheus.doc} retornaTamanhosLayout
Retorna por Referência o Tamanho das Entidades do Layout da Filial
@since 22/02/2022
@version P12.1.37
@param 01 - nTamEmp , número, retorna por referência o tamanho da Empresa no Layout do Grupo de Empresas 
@param 02 - nTamUnid, número, retorna por referência o tamanho da Unidade de Negócios no Layout do Grupo de Empresas 
@param 03 - nTamFil , número, retorna por referência o tamanho da Filial no Layout do Grupo de Empresas
/*/
METHOD retornaTamanhosLayout(nTamEmp, nTamUnid, nTamFil) CLASS QLTQueryManager
    Local cLayout := Nil
    Local nCont   := 0
    Local nTotal  := Nil

    If oCacheDados['tamanhoFilial'] == Nil
        cLayout := FWSM0Layout()
        nTotal  := Len(cLayout)
        For nCont := 1 To nTotal
            If     SubStr(cLayout, nCont, 1) == "E"
                nTamEmp++
            ElseIf SubStr(cLayout, nCont, 1) == "U"
                nTamUnid++
            ElseIf SubStr(cLayout, nCont, 1) == "F"
                nTamFil++
            EndIf
        Next nCont
        oCacheDados['tamanhoFilial'] := {nTamEmp, nTamUnid, nTamFil}
    Else
        nTamEmp  := oCacheDados['tamanhoFilial'][1]
        nTamUnid := oCacheDados['tamanhoFilial'][2]
        nTamFil  := oCacheDados['tamanhoFilial'][3]
    EndIf
Return

/*/{Protheus.doc} changeQuery
Realiza Adequações na Query para Os Bancos Oracle e Postgres
@since 22/02/2022
@version P12.1.37
@param 01 - cQuery, caracter, string com a query SQL para ajuste
@param 02 - cBanco, caracter, indica o banco a ser considerado
@return cQuery, caracter, string com a query SQL ajustada para o banco
/*/
METHOD changeQuery(cQuery, cBanco) CLASS QLTQueryManager

    Default cBanco := Self:cBanco

	//Realiza ajustes da Query para cada banco
	If "POSTGRES" $ cBanco

		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Corrige Falhas internas de Binário - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

		cQuery := StrTran(cQuery,"ISNULL","COALESCE")
		cQuery := StrTran(cQuery,"VarChar(8000)","VarChar(4000)")
        cQuery := StrTran(cQuery, "LEN(" , "LENGTH(" )

	ElseIf  "ORACLE" $ cBanco
		cQuery := StrTran(cQuery,"VarChar(8000)","VarChar(4000)")
		cQuery := StrTran(cQuery,"ISNULL","COALESCE")
        cQuery := StrTran(cQuery, "SUBSTRING", "SUBSTR")
        cQuery := StrTran(cQuery, "LEN(" , "LENGTH(" )
	Else
		//Substitui a função Trim
		cQuery := StrTran(cQuery, "Trim(", "RTrim(")
        cQuery := StrTran(cQuery, "LENGTH(" , "LEN(" )
	EndIf

Return cQuery

/*/{Protheus.doc} defaultChangeQueryWithCache
Executa Change Query Default de FRAME e trata cache de execução conforme instrução de Nilton Rodrigues (Spike DMANQUALI-9085)
@since 08/10/2024
@version P12.1.2410
@param 01 - cQuery, caracter, string com a query SQL para ajuste
@return cQuery, caracter, string com a query SQL ajustada para o banco
/*/
Static METHOD defaultChangeQueryWithCache(cQuery) CLASS QLTQueryManager

    //Gera a chave da consulta para pesquisa unica em memória
    Local cChaveMD5 := MD5(cQuery)

    oCacheDados                       := Iif(oCacheDados           == Nil            , JsonObject():New(), oCacheDados                      )
    oCacheDados['defaultChangeQuery'] := Iif(oCacheDados['defaultChangeQuery'] == Nil, JsonObject():New(), oCacheDados['defaultChangeQuery'])

    If oCacheDados['defaultChangeQuery' , cChaveMD5] == Nil
        cQuery                                       := ChangeQuery(cQuery)
        oCacheDados['defaultChangeQuery', cChaveMD5] := cQuery
    Else
        cQuery                                       := oCacheDados['defaultChangeQuery', cChaveMD5]
    EndIf

Return cQuery

/*/{Protheus.doc} montaQueryComparacaoFiliaisComCamposEspecificos
Retorna Query de Comparação das Filiais Com Campos Específicos para Utilização em Query SQL
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasA, caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cCampoA, caracter, primeiro campo para comparação (já com prefixo de alias)
@param 03 - cAliasB, caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cCampoB, caracter, segundo  campo para comparação (já com prefixo de alias)
@return cQuery, caracter, string contendo a compararação para filtro das filiais

*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***

/*/
METHOD montaQueryComparacaoFiliaisComCamposEspecificos(cAliasA, cCampoA, cAliasB, cCampoB) CLASS QLTQueryManager
    Local cCpoDefA := Self:RetornaCampoFilial(cAliasA)
    Local cCpoDefB := Self:RetornaCampoFilial(cAliasB)
    Local cQuery   := Self:MontaQueryComparacaoFiliais(cAliasA, cAliasB, "A", "B")

    cQuery := StrTran(cQuery, "A." + cCpoDefA, cCampoA)
    cQuery := StrTran(cQuery, "B." + cCpoDefB, cCampoB)
Return cQuery

/*/{Protheus.doc} montaQueryComparacaoFiliaisComValorReferencia
Retorna Query de Comparação das Filiais Campo Específico x Valor para Utilização em Query SQL
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasA , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cCampoA , caracter, primeiro campo para comparação (já com prefixo de alias)
@param 03 - cAliasB , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cFilialB, caracter, valor da filial no alias B para filtro
@return cQuery, caracter, string contendo a compararação para filtro das filiais

*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***

/*/
METHOD montaQueryComparacaoFiliaisComValorReferencia(cAliasA, cCampoA, cAliasB, cFilialB) CLASS QLTQueryManager
    Local cCpoDefA := Self:RetornaCampoFilial(cAliasA)
    Local cCpoDefB := Self:RetornaCampoFilial(cAliasB)
    Local cQuery   := Self:MontaQueryComparacaoFiliais(cAliasA, cAliasB, "A", "B")
    Local nPosComp := 0
    Local cLeft    := ""
    Local cRight   := ""

    cQuery   := StrTran(cQuery, "A." + cCpoDefA, cCampoA)
    nPosComp := At("=", cQuery)
    cLeft    := Left(cQuery, nPosComp)
    cRight   := Substring(cQuery, nPosComp + 1, Len(cQuery))
    cRight   := StrTran(cRight, "B." + cCpoDefB, "'" + cFilialB + "'")
    cQuery   := cLeft + cRight

Return cQuery

/*/{Protheus.doc} comparacaoFiliais
Compara Filiais de valores específicos
@since 07/07/2023
@version P12.1.2210
@autor brunno.costa / rafael.hesse
@param 01 - cAliasA , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cFilialA, caracter, valor da filial no alias A para comparação
@param 03 - cAliasB , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cFilialB, caracter, valor da filial no alias B para comparação
@return lMesmaFilial, lógico, indica se as filiais são compatíveis

*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***
*** CUIDADO - TENHA CERTEZA DE COMPARAR CAMPOS DE FILIAIS COM RELACIONAMENTO VIÁVEL - CUIDADO ***

/*/
METHOD comparacaoFiliais(cAliasA, cFilialA, cAliasB, cFilialB) CLASS QLTQueryManager

    Local cCpoDefA     := Self:RetornaCampoFilial(cAliasA)
    Local cCpoDefB     := Self:RetornaCampoFilial(cAliasB)
    Local cComparacao  := Self:MontaQueryComparacaoFiliais(cAliasA, cAliasB, "A", "B")
    Local nPosComp     := 0
    Local cLeft        := ""
    Local cRight       := ""
    Local lMesmaFilial := .F.

    cComparacao  := StrTran(cComparacao, "A." + cCpoDefA, "'" + cFilialA + "'")
    nPosComp     := At("=", cComparacao)
    cLeft        := Left(cComparacao, nPosComp)
    cRight       := Substring(cComparacao, nPosComp + 1, Len(cComparacao))
    cRight       := StrTran(cRight, "B." + cCpoDefB, "'" + cFilialB + "'")
    cComparacao  := cLeft + cRight
    cComparacao  := StrTran(cComparacao, "=", "==")
    lMesmaFilial := &(cComparacao)

Return lMesmaFilial

/*/{Protheus.doc} validaDadosDaFilial
Valida Dados da Filial em Campos Específicos
@since 22/02/2022
@version P12.1.37
@param 01 - cAliasRef , caracter, alias referência para verificação do modo de compartilhamento da tabela
@param 02 - cAliasCpo , caracter, alias do campo que será validado - referência de chave estrangeira em outra tabela
@param 03 - cCampo    , caracter, nome do campo que contém a filial que será validado - referência de chave estrangeira em outra tabela
@param 04 - lExibeHelp, lógico  , indica se deve exibir o help de falha
@param 05 - aRecnos   , array   , retorna por referência a relação de arrays com problema
@return lReturn, lógico, indica que os dados da tabela estão íntegros
/*/
METHOD validaDadosDaFilial(cAliasRef, cAliasCpo, cCampo, lExibeHelp, aRecnos) CLASS QLTQueryManager

    Local aBindParam   := {}
    Local cCompEmp     := AllTrim(Self:ChecaModoDeAcesso(cAliasRef, 1))
    Local cCompFil     := AllTrim(Self:ChecaModoDeAcesso(cAliasRef, 3))
    Local cCompUni     := AllTrim(Self:ChecaModoDeAcesso(cAliasRef, 2))
    Local cFilAux      := ""
    Local cFilDef      := ""
    Local cQuery       := ""
    Local cRECNOs      := ""
    Local lChangeQuery := .F.
    Local nTamEmp      := 0
    Local nTamFil      := 0
    Local nTamFilial   := 0
    Local nTamUnid     := 0

    Default aRecnos    := {}
    Default cAliasCpo  := cAliasRef
    Default cCampo     := Self:RetornaCampoFilial(cAliasRef)
    Default lExibeHelp := .T.

    cFilDef    := xFilial(cAliasCpo)

    DbSelectArea(cAliasRef)
    DBSelectArea(cAliasCpo)
    If Select(cAliasRef)>0
        (cAliasRef)->(DbCloseArea())
    EndIf
    If Select(cAliasCpo)>0
        (cAliasCpo)->(DbCloseArea())
    EndIf

    Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)

    If nTamEmp  != 0 .AND. cCompEmp == "E"
        nTamFilial += nTamEmp
    EndIf

    If nTamUnid != 0 .AND. cCompUni == "E"
        nTamFilial += nTamUnid
    EndIf
    
    If nTamFil  != 0 .AND. cCompFil == "E"
        nTamFilial += nTamFil
    EndIf

    cQuery += " SELECT " + cCampo + ", R_E_C_N_O_ "
    cQuery += " FROM " + RetSQLName(cAliasCpo)
    cQuery += " WHERE "

    aAdd(aBindParam, {" ", "S"})
    cQuery += " D_E_L_E_T_ = ? AND "

    If nTamFilial > 0
        aAdd(aBindParam, {cCampo    , "U"})
        aAdd(aBindParam, {nTamFilial, "N"})
        cQuery += " LEN(RTRIM(?)) <> ? "
    Else
        aAdd(aBindParam, {cCampo    , "U"})
        aAdd(aBindParam, {" "     , "S"})
        cQuery += " ? <> ? "
    EndIf

    cQuery += " ORDER BY R_E_C_N_O_ "

    cQuery := Self:ChangeQuery(cQuery)

    cAliasQry := QLTQueryManager():executeQueryWithBind(cQuery, aBindParam, lChangeQuery)

    (cAliasQry)->(DBGotop())
	While (cAliasQry)->(!EOF())
        cFilAux := (cAliasQry)->&(cCampo)
        If     (Len(Rtrim(cFilAux)) > nTamFilial);
          .OR. (!Empty(AllTrim(cFilAux)) .AND. AllTrim(xFilial(cAliasRef, cFilAux)) != AllTrim(cFilAux));
          .OR. ( Empty(AllTrim(cFilAux)) .AND. AllTrim(cFilDef)                     != AllTrim(cFilAux))

            If Empty(cRECNOs)
                cRECNOs += cValToChar((cAliasQry)->(R_E_C_N_O_))
            Else
                cRECNOs += ", " + cValToChar((cAliasQry)->(R_E_C_N_O_))
            EndIf
            aAdd(aRecnos, (cAliasQry)->(R_E_C_N_O_))
        EndIf
         (cAliasQry)->(DbSkip())
    EndDo
    (cAliasQry)->(DbCloseArea())

    If lExibeHelp .AND. !Empty(cRECNOs)
        //#STR0001 - "Atenção"
        //#STR0002 - "O sistema identificou falhas nos dados de filial no campo"
        //#STR0003 - "que proporcionarão mal comportamento de algumas rotinas do módulo."
        //#STR0004 - "Entre em contato com o departamento de TI e solicite a compatibilização dos dados de RECNO a seguir conforme modo de compartilhamento da tabela"
        Help(NIL, NIL, STR0001, NIL, STR0002 + " '" + cCampo + "' " + STR0003, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0004 + " '" + cAliasRef + "': " + cRECNOs})
        aAdd(Self:aMsgErro, {STR0002 + " '" + cCampo + "' " + STR0003, STR0004 + " '" + cAliasRef + "': " + cRECNOs} )
    EndIf
    
Return Empty(cRECNOs)

/*/{Protheus.doc} validaMesmosCompartilhamentos
Valida se As Tabelas Possuem os Mesmos Compartilhamentos
@since 22/02/2022
@version P12.1.37
@param 01 - aTabelas  , array   , array com as tabelas que devem possuir os mesmos compartilhamentos
@param 02 - cModelo   , caracter, chave da tabela de modelo referência para os compartilhamentos
@param 03 - lExibeHelp, lógico  , indica se deve exibir o help de falha
@return lReturn, lógico, indica se todas as tabelas possuem os mesmos compartilhamentos
/*/
METHOD validaMesmosCompartilhamentos(aTabelas, cModelo, lExibeHelp) CLASS QLTQueryManager

    Local cModE    := ""
    Local cModF    := ""
    Local cModos   := ""
    Local cModU    := ""
    Local cTabE    := ""
    Local cTabelas := ""
    Local cTabF    := ""
    Local cTabU    := ""
    Local lReturn  := .T.
    Local lTabOk   := .T.
    Local nInd     := 0
    Local nTamEmp  := 0
    Local nTamFil  := 0
    Local nTamUnid := 0
	Local nTotal   := 0

    Default aTabelas   := {}
    Default lExibeHelp := .T.

    If aScan(aTabelas, {|x| x == cModelo}) <= 0
        aAdd(aTabelas, cModelo)
    EndIf

    Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)
    If nTamEmp  != 0
        cModE := AllTrim(Self:ChecaModoDeAcesso(cModelo, 1))    // Empresas
        cModos += "-> " + STR0007 + " (" + Iif(cModE == "C", STR0008, STR0009) + ")" + _CRLF //Empresa - "Compartilhado" - "Exclusivo"
    EndIf
    If nTamUnid != 0
        cModU := AllTrim(Self:ChecaModoDeAcesso(cModelo, 2))    // Unidades
        cModos += "-> " + STR0010 + " (" + Iif(cModU == "C", STR0008, STR0009) + ")" + _CRLF //Unidade de Negócio - "Compartilhado" - "Exclusivo"
    EndIf
    If nTamFil  != 0
        cModF := AllTrim(Self:ChecaModoDeAcesso(cModelo, 3))    // Filiais
        cModos += "-> " + STR0011 + " (" + Iif(cModF == "C", STR0008, STR0009) + ")" + _CRLF //Filial - "Compartilhado" - "Exclusivo"
    EndIf

    nTotal := Len(aTabelas)
    For nInd := 1 to nTotal
    
        If !Empty(aTabelas[nInd])
   
            lTabOk := .T.
            If nTamEmp != 0
                cTabE := AllTrim(Self:ChecaModoDeAcesso(aTabelas[nInd], 1))    // Empresas
                If cTabE <> cModE
                    lReturn := .F.
					lTabOk := .F.
                EndIf 
            EndIf 
            If nTamUnid != 0 .and. lTabOk
                cTabU := AllTrim(Self:ChecaModoDeAcesso(aTabelas[nInd], 2))    // Unidade
                If cTabU <> cModU
                    lReturn := .F.
					lTabOk := .F.
                EndIf 
            EndIf 
            If nTamFil != 0 .and. lTabOk
                cTabF := AllTrim(Self:ChecaModoDeAcesso(aTabelas[nInd], 3))    // Filial
                If cTabF <> cModF
                    lReturn := .F.
					lTabOk  := .F.
                EndIf 
            EndIf 
            If !lReturn                
                If!Empty(cTabelas)
                    cTabelas += ","
                EndIf
                cTabelas += "'" + aTabelas[nInd] + "' "
            EndIf 

        EndIf 
            
    Next 
    
    If !lReturn .and. lExibeHelp
        //STR0001 - "Atenção"
        //STR0005 - "O sistema identificou falha no compartilhamento das tabelas"
        //STR0006 - "Solicite apoio do departamento de TI e ajuste a configuração para que todas as tabelas possuam o mesmo modo de compartilhamento da tabela"
        cTabelas := StrTran(cTabelas, "'", "")
        Help(NIL, NIL, STR0001, NIL, STR0005 + ": " + cTabelas + ".", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006 + " '" + cModelo + "':" + _CRLF + cModos})
        aAdd(Self:aMsgErro, {STR0005 + ": " + cTabelas + ".", STR0006 + " '" + cModelo + "':" + _CRLF + cModos} )
    EndIf 

Return lReturn

/*/{Protheus.doc} validaCompartilhamentoEspecifico
Valida Se a Tabela Possui um Compartilhamento Específico
@since 22/02/2022
@version P12.1.37
@param 01 - cTabela   , caracter, chave da tabela para análise 
@param 02 - cModoEmp  , caracter, modo de compartilhamento por empresa desejado
@param 03 - cModoUnid , caracter, modo de compartilhamento por unidade desejado
@param 04 - cModoFil  , caracter, modo de compartilhamento por filial desejado
@param 05 - lExibeHelp, lógico  , indica se deve exibir o help de falha
@return lReturn, lógico, indica se a tabela está atendendo o modo de compartilhamento específico
/*/
METHOD validaCompartilhamentoEspecifico(cTabela, cModoEmp, cModoUnid, cModoFil, lExibeHelp) CLASS QLTQueryManager

    Local cCompEmp  := ""
    Local cCompFil  := ""
    Local cCompUni  := ""
    Local cModosNOK := ""
    Local cModosOK  := ""
    Local lReturn   := .T.
    Local nTamEmp   := 0
    Local nTamFil   := 0
    Local nTamUnid  := 0

    Default aTabelas   := {}
    Default lExibeHelp := .T.

    Self:RetornaTamanhosLayout(@nTamEmp, @nTamUnid, @nTamFil)

    If nTamEmp  != 0
        cCompEmp := AllTrim(Self:ChecaModoDeAcesso(cTabela, 1))
        If cModoEmp != cCompEmp
            lReturn := .F.
            cModosOk  += "-> " + STR0007 + " (" + Iif(cModoEmp == "C", STR0008, STR0009) + ")" + _CRLF //Empresa - Compartilhado - Exclusivo
            cModosNOK += "-> " + STR0007 + " (" + Iif(cCompEmp == "C", STR0008, STR0009) + ")" + _CRLF //Empresa - Compartilhado - Exclusivo
        EndIf
    EndIf

    If nTamUnid != 0
        cCompUni := AllTrim(Self:ChecaModoDeAcesso(cTabela, 2))
        If cModoUnid != cCompUni
            lReturn := .F.
            cModosOk  += "-> " + STR0010 + " (" + Iif(cModoUnid == "C", STR0008, STR0009) + ")" + _CRLF //Unidade de Negócio - Compartilhado - Exclusivo
            cModosNOK += "-> " + STR0010 + " (" + Iif(cCompUni  == "C", STR0008, STR0009) + ")" + _CRLF //Unidade de Negócio - Compartilhado - Exclusivo
        EndIf
    EndIf
    
    If nTamFil  != 0
        cCompFil := AllTrim(Self:ChecaModoDeAcesso(cTabela, 3))
        If cModoFil != cCompFil
            lReturn := .F.
            cModosOk  += "-> " + STR0011 + " (" + Iif(cModoFil == "C", STR0008, STR0009) + ")" + _CRLF //Filial - Compartilhado - Exclusivo
            cModosNOK += "-> " + STR0011 + " (" + Iif(cCompFil == "C", STR0008, STR0009) + ")" + _CRLF //Filial - Compartilhado - Exclusivo
        EndIf
    EndIf

    If lExibeHelp .AND. !lReturn
        //STR0001 - Atenção
        //STR0012 - "O sistema identificou falha no compartilhamento da tabela"
        //STR0013 - "Solicite apoio do departamento de TI e ajuste a configuração de compartilhamento da tabela"
        Help(NIL, NIL, STR0001, NIL, STR0012 + " '" + cTabela + "': " + _CRLF + cModosNOK, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013 + ": " + _CRLF + cModosOk})
        aAdd(Self:aMsgErro, {STR0012 + " '" + cTabela + "': " + _CRLF + cModosNOK, STR0013 + ": " + _CRLF + cModosOk} )
    EndIf
    
Return lReturn

/*/{Protheus.doc} confirmaNecessidadeDeExecucaoMensalViaSemaforo
Confirma a Necessidade de Execução Mensal Via Semaforo
@since 22/02/2022
@version P12.1.37
@param 01 - cVersao   , caracter, controla a versão de controle de execucao
@param 02 - cModulo   , caracter, controla a chave de controle de execução por módulo
@param 03 - aMsgErro  , array   , array com as mensagens de erro para arquivamento no log
@param 04 - nMeses    , numérico, quantidade de meses para checagem de re-execução
@param 04 - lPorFilial, lógico  , indica o controle de execução por filial (.T.) ou por grupo de empresas (.F.)
@return lReturn, lógico, indica se deve executar
/*/
METHOD confirmaNecessidadeDeExecucaoMensalViaSemaforo(cVersao, cModulo, aMsgErro, nMeses, lPorFilial) CLASS QLTQueryManager
    Local bErrorBlock  := Nil
    Local cChvEmpresa  := ""
	Local cFileName    := ""
    Local lExecutar    := .F.
    Local lLock        := .F.
	Local lReturn      := .F.
	Local nHandle      := Nil
    Local oMensagem    := JsonObject():New()

    Default aMsgErro   := {}
    Default cModulo    := "QLT"
	Default cVersao    := '001'
    Default lPorFilial := .F.
    Default nMeses     := 1

    If lPorFilial
        cChvEmpresa := FWGrpCompany() + "_" + FWCodFil()
    Else
        cChvEmpresa := FWGrpCompany()
    EndIf

	cFileName := Lower(GetPathSemaforo() + "Quality_" + cChvEmpresa + "_" + AllTrim(cVersao) + "_" + AllTrim(cModulo))

	If (lLock := LockByName(cFileName, .F., .F., .T.)) .OR. !Empty(aMsgErro) //Conseguiu bloquear
		If File(cFileName + ".vldlog", 0 ,.T.)
            bErrorBlock := ErrorBlock({|| lExecutar := .T. })
            oMensagem:fromJson(MemoRead( cFileName + ".vldlog"))
            If oMensagem == Nil .OR. Len(aMsgErro) > 0 .OR. (oMensagem[ 'data' ] != Nil .AND. StoD(oMensagem[ 'data' ]) < MonthSub( Date() , nMeses ))
                lExecutar := fErase(cFileName + ".vldlog") <> -1
                // - Help
				//STR0018 - Falha na exclusão do arquivo '\RootPath\Semaforo\
				//STR0017 - Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'
                Iif(!lExecutar, FWLogMsg('ERROR',, 'SIGAQIP', funName(), '', '01', STR0018 + cFileName + ".vldlog': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ") - " + STR0017 , 0, 0, {}), Nil)
            EndIf
            ErrorBlock(bErrorBlock)
        Else
            lExecutar := .T.
		EndIf

        If lExecutar
            nHandle := fCreate(cFileName + ".vldlog", FC_NORMAL)

			If nHandle != -1
                oMensagem[ 'usuarioProtheus' ]           := RetCodUsr()
                oMensagem[ 'nomeUsuarioProtheus' ]       := UsrRetName(RetCodUsr())
                oMensagem[ 'usuarioSistemaOperacional' ] := LogUserName()
                oMensagem[ 'nomeComputador' ]            := GetComputerName()
                oMensagem[ 'rotinaProtheus' ]            := FunName()
                oMensagem[ 'ipServerProtheus' ]          := GetServerIP()
                oMensagem[ 'portaServerProtheus' ]       := GetPvProfString( "tcp", "port", "1234", "appserver.ini")
                oMensagem[ 'data' ]                      := DtoS(Date())
                oMensagem[ 'hora' ]                      := Time()
                oMensagem[ 'mensagemErro' ]              := aMsgErro

				fWrite(nHandle, oMensagem:toJson())
				If fError() == 0
                    lReturn := .T.
				EndIf
			EndIf
			fClose(nHandle)

			If !lReturn
				// - Help
				//STR0016 - Falha na criação do arquivo '\RootPath\Semaforo\
				//STR0017 - Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'
				Help( ,  , STR0001, ,  STR0016 + cFileName + ".vldlog': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0017})
			EndIf
        EndIf
        If lLock
            UnLockByName(cFileName, .F., .F., .T.)
        EndIf
	EndIf

    If Len(aMsgErro) > 0
        lReturn := .F.
    EndIf

Return lReturn

/*/{Protheus.doc} executeQuery
Executa Querys Básicas com proteção de método do frame no RPO
@since 01/03/2022
@version P12.1.37
@param 01 - cQuery    , caracter, query para abertura de alias
@param 02 - lFwExecSta, caracter, indica se deve tentar utilizar a FwExecStatement
@return cAlias, caracter, alias aberto
/*/
METHOD executeQuery(cQuery, lFwExecSta) CLASS QLTQueryManager
    Local cAlias := ""
    Local oExec  := Nil
    Default lFwExecSta := FindClass( Upper("FwExecStatement") )
    If !lFwExecSta
        cAlias    := GetNextAlias()
        dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
    Else
        oExec := FwExecStatement():New(cQuery)
        cAlias := oExec:OpenAlias()
        oExec:Destroy()
        oExec := nil 
    EndIf
Return cAlias

/*/{Protheus.doc} executeQueryWithBind
Executa Query com BIND no Banco de Dados
@since 01/10/2024
@version P12.1.2410
@param 01 - cQuery    , caracter, query para abertura de alias
@param 02 - aBindParam, array   , array com os dados dos parâmetros para BIND:
                      {{oDados, cTipo}, {}, ...}
                      Sendo cTipo:
                      N -> Número, para uso com FwExecStatement():setNumeric()
                      S -> String, para uso com FwExecStatement():setString()
                      A -> Array , para uso com FwExecStatement():setInArray()
@param 03 - lChangeQuery, lógico, indica se executa changeQuery padrão do framework
@return cAlias, caracter, alias aberto
/*/
Static METHOD executeQueryWithBind(cQuery, aBindParam, lChangeQuery) CLASS QLTQueryManager

    Local cAlias         := ""
    Local oExec          := Nil

    Default aBindParam   := {}
    Default lChangeQuery := .T.

    If lChangeQuery
        cQuery := QLTQueryManager():defaultChangeQueryWithCache(cQuery)
    EndIf

    oExec := FwExecStatement():New(cQuery)
    QLTQueryManager():bindSQLParameters(@oExec, aBindParam)
    cAlias := oExec:OpenAlias()
    oExec:Destroy()
    oExec := nil 
    
Return cAlias

/*/{Protheus.doc} montaRelationC2OP
Monta Relacionamento de Campo específico com a concatenação de campos que compõe o C2_OP = C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD
@since 06/10/2023
@version P12.1.2310
@author brunno.costa
@param 01 - cCampo, caracter, nome do alias do campo para comparação com equivalência de C2_OP 
Nota: Campo C2_OP não é gravado sempre, então faz-se necessário comparar C2_NUM + C2_ITEM + C2_SEQUEN = cCampo, 
      porém, por questões de performance não podemos concatenar na comparação quando a origem da seleção provem de filtro no alias de cCampo
@return cQuery, caracter, query de comparação entre C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD = cCampo
/*/

METHOD montaRelationC2OP(cCampo) CLASS QLTQueryManager

    Local cQuery     := ""
    Local nTamItem   := GetSx3Cache("C2_ITEM"   ,"X3_TAMANHO")
    Local nTamITGRD  := GetSx3Cache("C2_ITEMGRD","X3_TAMANHO")
	Local nTamNum    := GetSx3Cache("C2_NUM"    ,"X3_TAMANHO")
	Local nTamSequen := GetSx3Cache("C2_SEQUEN" ,"X3_TAMANHO")

    cQuery +=     " C2_NUM     = SUBSTRING(" + cCampo + ", " + "1" +                                      ", " + Str(nTamNum)    + ") "
    cQuery += " AND C2_ITEM    = SUBSTRING(" + cCampo + ", " + Str(nTamNum + 1) +                         ", " + Str(nTamItem)   + ") "
    cQuery += " AND C2_SEQUEN  = SUBSTRING(" + cCampo + ", " + Str(nTamNum + nTamItem + 1) +              ", " + Str(nTamSequen) + ") "
    cQuery += " AND C2_ITEMGRD = SUBSTRING(" + cCampo + ", " + Str(nTamNum + nTamItem + nTamSequen + 1) + ", " + Str(nTamITGRD)  + ") "

Return cQuery


/*/{Protheus.doc} montaRelationValorLote
Monta condição para comparar valor concatenado de lote (cLote) com campos de lote e sublote, sem usar CONCAT
@since 25/09/2025
@version P12.1.2410
@author brunno.costa
@param 01 - cLote         , caracter, valor concatenado equivalente a QPK_LOTE (pode ser somente lote ou lote+sublote)
@param 02 - cCampoLote    , caracter, nome do campo de Lote na tabela (ex.: "H6_LOTECTL")
@param 03 - cCampoSubLote , caracter, nome do campo de Sublote na tabela (ex.: "H6_NUMLOTE")
@param 04 - lSomenteLote  , lógico , quando .T. compara apenas o campo de Lote (primeira parte)
@return cQuery, caracter, trecho de WHERE/ON pronto para uso
/*/
METHOD montaRelationValorLote(cLote, cCampoLote, cCampoSubLote, lSomenteLote) CLASS QLTQueryManager

    Local cQuery     := ""
    Local nTamLote   := GetSx3Cache(cCampoLote   , "X3_TAMANHO")
    Local nTamSub    := GetSx3Cache(cCampoSubLote, "X3_TAMANHO")
    Local cParteLot  := PadR(Left(cLote, nTamLote), nTamLote)
    Local cParteSub  := PadR(SubStr(cLote, nTamLote + 1, nTamSub), nTamSub)

    Default lSomenteLote := .F.

    // Rotinas do PCP permitem apontamento com sublote mesmo quando o produto controla apenas lote; por isso, quando lSomenteLote = .T., a comparação considera somente o lote se a subparte do valor/campo concatenado estiver vazia
    If lSomenteLote .And. Empty(cParteSub)
        cQuery += " (" + cCampoLote + " = '" + cParteLot + "' )"
    Else
        cQuery += " (" + cCampoLote + " = '" + cParteLot + "' AND " + cCampoSubLote + " = '" + cParteSub + "') "
    EndIf

Return cQuery

/*/{Protheus.doc} montaRelationCampoConcatenado
Monta condição para comparar campos de lote/sublote com um campo concatenado (ex.: "QPK_LOTE"), usando SUBSTRING
@since 25/09/2025
@version P12.1.2410
@author brunno.costa
@param 01 - cConcatenado  , caracter, nome do campo concatenado (ex.: "QPK_LOTE" )
@param 02 - cCampoLote    , caracter, nome do campo de Lote na tabela (ex.: "H6_LOTECTL")
@param 03 - cCampoSubLote , caracter, nome do campo de Sublote na tabela (ex.: "H6_NUMLOTE")
@param 04 - lSomenteLote  , lógico  , quando .T. compara apenas a primeira parte (Lote)
@return cQuery, caracter, trecho de WHERE/ON pronto para uso
/*/
METHOD montaRelationCampoConcatenado(cConcatenado, cCampoLote, cCampoSubLote, lSomenteLote) CLASS QLTQueryManager

    Local cQuery        := ""
    Local nTamLote      := GetSx3Cache(cCampoLote   , "X3_TAMANHO")
    Local nTamSub       := GetSx3Cache(cCampoSubLote, "X3_TAMANHO")
    Local cParteLoteSQL := "SUBSTRING(" + cConcatenado + ", 1, " + Str(nTamLote) + ")"
    Local cParteSubSQL  := "SUBSTRING(" + cConcatenado + ", " + Str(nTamLote + 1) + ", " + Str(nTamSub) + ")"
    Local cParteSubTrim := "RTRIM(LTRIM(" + cParteSubSQL + "))"

    Default lSomenteLote := .F.

    cQuery += " (" + cCampoLote + " = " + cParteLoteSQL

    If lSomenteLote
        // Sem OR: ignora sublote quando a subparte vier vazia
        // Rotinas do PCP permitem apontamento com sublote mesmo quando o produto controla apenas lote; por isso, quando lSomenteLote = .T., a comparação considera somente o lote se a subparte do valor/campo concatenado estiver vazia
        cQuery += " AND " + cCampoSubLote + " = COALESCE(NULLIF(" + cParteSubTrim + ", ''), " + cCampoSubLote + ")"
    Else
        // Exige sublote quando rastreia sublote
        cQuery += " AND " + cCampoSubLote + " = " + cParteSubSQL
    EndIf

    cQuery += ") "

Return cQuery


/*/{Protheus.doc} montaFiltroRastroValor
Monta filtro de rastreabilidade (valor literal) para Lote/SubLote.
@since 25/09/2025
@version P12.1.2410
@author brunno.costa
@param 01 - cRastro        , caracter, 'N' (não controla) | 'L' (lote) | 'S' (sublote)
@param 02 - cValorLote     , caracter, valor concatenado (ex.: valor de QPK_LOTE)
@param 03 - cCampoNA       , caracter, campo para cenário 'N' (parte 1). Se vazio, usa apenas cCampoNA como campo único.
@param 04 - cCampoNB       , caracter, campo para cenário 'N' (parte 2). Se vazio, usa apenas cCampoNA como campo único.
@param 05 - cCampoLote     , caracter, campo de lote para L/S
@param 06 - cCampoSubLote  , caracter, campo de sublote para L/S
@param 07 - lAddAnd        , lógico , quando .T. prefixa " AND "
@return cQuery, caracter, trecho pronto (eventualmente vazio)
/*/
METHOD montaFiltroRastroValor(cRastro, cValorLote, cCampoNA, cCampoNB, cCampoLote, cCampoSubLote, lAddAnd) CLASS QLTQueryManager

    Local cQuery := ""

    Default lAddAnd := .T.

    If Empty(cRastro) .OR. cRastro == "N"
        If Empty(AllTrim(cValorLote)) .And. Empty(AllTrim(cCampoNB)) .And. "D3_" $ cCampoNA
            cQuery += " D3_PARCTOT = 'T' "
        ElseIf !Empty(AllTrim(cValorLote))
            If Empty(AllTrim(cCampoNB))
                cQuery += " " + cCampoNA + " = '" + PadR(cValorLote, GetSx3Cache(cCampoNA, "X3_TAMANHO")) + "'"
            Else
                cQuery += Self:montaRelationValorLote(cValorLote, cCampoNA, cCampoNB, .F.)
            EndIf
        EndIf
    ElseIf cRastro == "L"
        cQuery += Self:montaRelationValorLote(cValorLote, cCampoLote, cCampoSubLote, .T.)
    ElseIf cRastro == "S"
        cQuery += Self:montaRelationValorLote(cValorLote, cCampoLote, cCampoSubLote, .F.)
    EndIf

    If !Empty(AllTrim(cQuery)) .AND. lAddAnd
        cQuery := " AND " + cQuery
    EndIf

Return cQuery

/*/{Protheus.doc} montaFiltroRastroCampo
Monta filtro de rastreabilidade (campo concatenado) para Lote/SubLote.
@since 25/09/2025
@version P12.1.2410
@author brunno.costa
@param 01 - cRastro        , caracter, 'N' (não controla) | 'L' (lote) | 'S' (sublote)
@param 02 - cConcatenado   , caracter, campo concatenado (ex.: QPK.QPK_LOTE)
@param 03 - cCampoNA       , caracter, campo para cenário 'N' (parte 1). Se vazio, usa apenas cCampoNA como campo único.
@param 04 - cCampoNB       , caracter, campo para cenário 'N' (parte 2). Se vazio, usa apenas cCampoNA como campo único.
@param 05 - cCampoLote     , caracter, campo de lote para L/S
@param 06 - cCampoSubLote  , caracter, campo de sublote para L/S
@param 07 - lAddAnd        , lógico , quando .T. prefixa " AND "
@return cQuery, caracter, trecho pronto (eventualmente vazio)
/*/
METHOD montaFiltroRastroCampo(cRastro, cConcatenado, cCampoNA, cCampoNB, cCampoLote, cCampoSubLote, lAddAnd) CLASS QLTQueryManager

    Local cIsEmptyConcat := ""
    Local cQuery         := ""

    Default lAddAnd := .T.

    // Checagem segura de vazio para o campo concatenado (compatível entre bancos)
    cIsEmptyConcat := "COALESCE(NULLIF(RTRIM(LTRIM(" + cConcatenado + ")), ''), ' ') = ' '"

    If Empty(cRastro) .OR. cRastro == "N"
        // POR QUE USAMOS OR COM cIsEmptyConcat?
        // Quando o rastreio é 'N' (não controla) a origem pode não gravar o campo
        // concatenado (ex.: lote/sublote) — ele pode vir vazio ou somente com espaços.
        // Nesses casos, não devemos forçar a comparação entre o campo original e o
        // concatenado, pois isso eliminaria linhas válidas por falta de valor.
        // A expressão fica:  (cIsEmptyConcat OR comparação)
        // - Se cConcatenado estiver vazio => cIsEmptyConcat é TRUE e todo o predicado é TRUE.
        // - Se houver conteúdo            => cIsEmptyConcat é FALSE e aplicamos a comparação.
        // Assim evitamos falsos negativos quando o campo concatenado não está preenchido,
        // mantendo a comparação apenas quando faz sentido.
        // Só comparamos quando houver conteúdo em cConcatenado.

        If Empty(AllTrim(cCampoNB))
            // Campo único
            cQuery += " (" + cIsEmptyConcat + " OR " + cCampoNA + " = " + cConcatenado + ")"
        Else
            // Duas partes (equivalente a CONCAT(cCampoNA,cCampoNB))
            cQuery += " (" + cIsEmptyConcat + " OR " + AllTrim(Self:montaRelationCampoConcatenado(cConcatenado, cCampoNA, cCampoNB, .F.)) + ")"
        EndIf

    ElseIf cRastro == "L"
        cQuery += Self:montaRelationCampoConcatenado(cConcatenado, cCampoLote, cCampoSubLote, .T.)

    ElseIf cRastro == "S"
        cQuery += Self:montaRelationCampoConcatenado(cConcatenado, cCampoLote, cCampoSubLote, .F.)
        
    EndIf

    If !Empty(AllTrim(cQuery)) .AND. lAddAnd
        cQuery := " AND " + cQuery
    EndIf

Return cQuery

/*/{Protheus.doc} montaRelationQEKNISERI
Monta Relacionamento de Campo específico com a concatenação de campos que compõe o QEK.QEK_NTFISC + QEK.QEK_SERINF + QEK.QEK_ITEMNF = QEL.QEL_NISERI 
@since 20/03/2025
@version P12.1.2410
@author brunno.costa
@param 01 - cPrefi    , caracter, prefixo do alias do campo para comparação com equivalência de QEK.QEK_NTFISC, QEK.QEK_SERINF, QEK.QEK_ITEMNF
@param 02 - cCpoNF   , caracter, nome do alias do campo para comparação com equivalência de QEK.QEK_NTFISC
@param 03 - cCpoSer  , caracter, nome do alias do campo para comparação com equivalência de QEK.QEK_SERINF
@param 04 - cCpoItem , caracter, nome do alias do campo para comparação com equivalência de QEK.QEK_ITEMNF
@param 05 - cConcatenado, caracter, nome do alias do campo para comparação com equivalência de QEL.QEL_NISERI
@return cQuery, caracter, query de comparação entre QEK.QEK_NTFISC + QEK.QEK_SERINF + QEK.QEK_ITEMNF = QEL.QEL_NISERI 
/*/

METHOD montaRelationQEKNISERI(cPrefi, cCpoNF, cCpoSer, cCpoItem, cConcatenado) CLASS QLTQueryManager

    Local cQuery     := ""
	Local nCpoNF     := GetSx3Cache(cCpoNF  , "X3_TAMANHO")
    Local nCpoSer    := GetSx3Cache(cCpoSer , "X3_TAMANHO")
    Local nCpoItem   := GetSx3Cache(cCpoItem, "X3_TAMANHO")

    cQuery +=     " COALESCE( RTRIM(LTRIM(" + cPrefi + cCpoNF   + ")) ,'#NULL#') = COALESCE( RTRIM(LTRIM(SUBSTRING(" + cConcatenado + ", " + "1"  +                       ", " + Str(nCpoNF)     + "))) ,'#NULL#') "
    
    If  "ORACLE" $ Self:cBanco
        cQuery += " AND COALESCE( SUBSTRING(CAST(COALESCE(" + cPrefi + cCpoSer + ", '') AS CHAR(" + Str(nCpoSer) + ")), 1, " + Str(nCpoSer) + ") , '#NULL#') = COALESCE( SUBSTRING(CAST(COALESCE(SUBSTRING(" + cConcatenado + ", " + Str(nCpoNF + 1) + ", " + Str(nCpoSer) + "), '') AS CHAR(" + Str(nCpoSer) + ")), 1, " + Str(nCpoSer) + ") , '#NULL#') "
    Else
        cQuery += " AND COALESCE( RTRIM(LTRIM(" + cPrefi + cCpoSer  + ")) , '#NULL#') = COALESCE( RTRIM(LTRIM(SUBSTRING(" + cConcatenado + ", " + Str(nCpoNF   + 1)          + ", " + Str(nCpoSer)    + "))) , '#NULL#') "
    EndIf

    cQuery += " AND COALESCE( RTRIM(LTRIM(" + cPrefi + cCpoItem + ")) , '#NULL#') = COALESCE( RTRIM(LTRIM(SUBSTRING(" + cConcatenado + ", " + Str(nCpoNF + nCpoSer  + 1) + ", " + Str(nCpoItem)   + "))) , '#NULL#') "

Return cQuery

/*/{Protheus.doc} montaRelationQEKNISERIArray
Monta Relacionamento de Campo específico com a concatenação de campos que compõe o QEK.QEK_NTFISC + QEK.QEK_SERINF + QEK.QEK_ITEMNF = QEL.QEL_NISERI 
@since 20/03/2025
@version P12.1.2410
@author brunno.costa
@param 01 - cPrefi      , caracter, prefixo do alias do campo para comparação com equivalência de QEK.QEK_NTFISC, QEK.QEK_SERINF, QEK.QEK_ITEMNF
@param 02 - cCampos     , caracter, string com os nomes dos campos para comparação com equivalência de QEK.QEK_NTFISC, QEK.QEK_SERINF, QEK.QEK_ITEMNF
@param 03 - cConcatenado, caracter, nome do alias do campo para comparação com equivalência de QEL.QEL_NISERI
@return cQuery, caracter, query de comparação entre QEK.QEK_NTFISC + QEK.QEK_SERINF + QEK.QEK_ITEMNF = QEL.QEL_NISERI 
/*/

METHOD montaRelationQEKNISERIArray(cPrefi, cCampos, cConcatenado) CLASS QLTQueryManager

    Local aCampos  := Strtokarr2( cCampos, "+", .F.)

Return Self:montaRelationQEKNISERI(cPrefi, aCampos[1], aCampos[2], aCampos[3], cConcatenado)

/*/{Protheus.doc} montaRelationArraysCampos
Monta Relacionamento de Campos de Alias Distintos com base em Array
@since 06/10/2023
@version P12.1.2310
@author brunno.costa
@param 01 - cCampo, caracter, nome do alias do campo para comparação com equivalência de C2_OP 
@return cQuery, caracter, query de comparação entre vários campos de alias distintos
/*/

METHOD montaRelationArraysCampos(cAliasA, aCamposA, cAliasB, aCamposB) CLASS QLTQueryManager

    Local cPrefA  := Iif(Empty(cAliasA), "", cAliasA + ".")
    Local cPrefB  := Iif(Empty(cAliasB), "", cAliasB + ".")
    Local cQuery  := ""
    Local nCampo  := 1
    Local nCampos := Len(aCamposA)

    For nCampo := 1 to nCampos
        cQuery += Iif(nCampo > 1, " AND ", "")
        
        If ("_NTFISC" $ aCamposA[nCampo] .And. "+" $ aCamposA[nCampo]) .And. ;
           ("_NTFISC" $ aCamposB[nCampo] .And. "+" $ aCamposB[nCampo])
            //Regra nova: ambos os lados possuem campos avulsos - compara campo a campo (sem concatenar)
            cQuery += " ( " + Self:montaRelacaoCamposNotaCampoACampo(cPrefA, aCamposA[nCampo], cPrefB, aCamposB[nCampo]) + " ) "

        ElseIf (("_NISERI" $ aCamposA[nCampo])                              .OR. ("_NISERI" $ aCamposB[nCampo] ))  .And. ;
               (("_NTFISC" $ aCamposA[nCampo] .And. "+" $ aCamposA[nCampo]) .OR. ("_NTFISC" $ aCamposB[nCampo] .And. "+" $ aCamposB[nCampo]))
            //Regra legada: um lado possui _NISERI - mantida para retrocompatibilidade
            If (Self:validaIndiceNotaAvulsoNaQEL() .and. ("QEL_" $ aCamposA[nCampo] .Or. "QEL_" $ aCamposB[nCampo])) .OR. ;
               (Self:validaIndiceNotaAvulsoNaQER() .and. ("QER_" $ aCamposA[nCampo] .Or. "QER_" $ aCamposB[nCampo]))
                cQuery += Iif("_NISERI" $ aCamposA[nCampo], " ( " + Self:montaRelationQEKNISERIArray(cPrefB, aCamposB[nCampo], cPrefA + aCamposA[nCampo]) + " ) ", ;
                                                            " ( " + Self:montaRelationQEKNISERIArray(cPrefA, aCamposA[nCampo], cPrefB + aCamposB[nCampo]) + " ) ")
            Else
                cQuery += " ( " + Self:montaRelacaoCamposNotaDerivado(cPrefA, aCamposA[nCampo], cPrefB, aCamposB[nCampo]) + " ) "
            EndIf

        Else
        
            cQuery += " ( " + Self:acertaConcatenacaoComConcat(cPrefA, aCamposA[nCampo]) + " = " + Self:acertaConcatenacaoComConcat(cPrefB, aCamposB[nCampo]) + " ) "

        EndIf
    Next

Return cQuery

/*/{Protheus.doc} acertaConcatenacaoComConcat
Acerta concatenação de campos no banco de dados com CONCAT
@since 11/11/2024
@version P12.1.2310
@author brunno.costa
@param 01 - cPrefixo, caracter, nome do alias do campo para comparação com equivalência de C2_OP 
@param 02 - cCampos , caracter, relação de campos concatenados com +
@return cRetorno, caracter, relação de campos concatenados com CONCAT()
/*/

METHOD acertaConcatenacaoComConcat(cPrefixo, cCampos) CLASS QLTQueryManager

    Local aCampos  := Strtokarr2( cCampos, "+", .F.)
    Local cRetorno := ""
    Local cTamCpo  := ""
    Local nCampo   := 1
    Local nCampos  := Len(aCampos)

    cRetorno := cPrefixo + aCampos[1]

    If nCampos > 1
        cTamCpo  := cValToChar(GetSx3Cache(aCampos[nCampo], "X3_TAMANHO"))
        cRetorno := "SUBSTRING(CAST(COALESCE(" + cPrefixo + aCampos[1] + ", '') AS CHAR(" + cTamCpo + ")), 1, " + cTamCpo + ")"
        
        For nCampo := 2 to nCampos
            cTamCpo  := cValToChar(GetSx3Cache(aCampos[nCampo], "X3_TAMANHO"))
            cRetorno := " CONCAT( " + cRetorno + ", SUBSTRING(CAST(COALESCE(" + cPrefixo + aCampos[nCampo] + ", '') AS CHAR(" + cTamCpo + ")), 1, " + cTamCpo + ") ) "
        Next
    EndIf

Return cRetorno

/*/{Protheus.doc} QAXCompFil
Compara Filiais de valores específicos
@type function
@author rafael.hesse
@since 20/07/2023
@param 01 - cAliasA , caracter, primeiro Alias para formação da comparação do campo de FILIAL 
@param 02 - cFilialA, caracter, valor da filial no alias A para comparação
@param 03 - cAliasB , caracter, segundo  Alias para formação da comparação do campo de FILIAL 
@param 04 - cFilialB, caracter, valor da filial no alias B para comparação
@return lógico, indica se as filiais são compatíveis
/*/
Function QAXCompFil(cAliasA, cFilialA, cAliasB, cFilialB)
    Local oManager := QLTQueryManager():New()
Return oManager:ComparacaoFiliais(cAliasA, cFilialA, cAliasB, cFilialB)

/*/{Protheus.doc} gravaCamposNISERI
Indica se os campos QER_NISERI e QEL_NISERI devem ser gravados
Método criado para facilitar descontinuação futura
@type	Method
@author brunno.costa
@since 11/02/2026
@return lGrava, lógico, .T. - indica se deve gravar os campos
/*/
METHOD gravaCamposNISERI() CLASS QLTQueryManager
Return .T.

/*/{Protheus.doc} validaIndiceNotaAvulsoNaQEL
Valida se o índice QEL_NISERI está presente na tabela QEL
@type	Method
@author willian.ramalho
@since 05/08/2025
@return lIndAvulso, lógico, .T. - indica se o índice está presente na tabela QEL
/*/
METHOD validaIndiceNotaAvulsoNaQEL() CLASS QLTQueryManager

    Local aIndexes   := Nil
    Local lIndAvulso := Nil
    Local nRelease   := GetRPORelease()

    If slIndAvQEL == Nil .Or. nRelease > "12.1.2510"
        aIndexes    := FWSIXUtil():GetAliasIndexes("QEL")
        lIndAvulso  := "QEL_NISERI" $ AllTrim(aIndexes[3][5])
        slIndAvQEL := lIndAvulso
    Else
         lIndAvulso := slIndAvQEL
    EndIf

Return lIndAvulso

/*/{Protheus.doc} validaIndiceNotaAvulsoNaQER
Valida se o índice QER_NISERI está presente na tabela QER
@type	Method
@author willian.ramalho / brunno.costa
@since 05/03/2026
@return lIndAvulso, lógico, .T. - indica se o índice está presente na tabela QER
/*/
METHOD validaIndiceNotaAvulsoNaQER() CLASS QLTQueryManager

    Local aIndexes   := Nil
    Local lIndAvulso := Nil
    Local nRelease   := GetRPORelease()

    If slIndAvQER == Nil .Or. nRelease > "12.1.2510"
        aIndexes    := FWSIXUtil():GetAliasIndexes("QER")
        lIndAvulso  := "QER_NISERI" $ AllTrim(aIndexes[5][6])
        slIndAvQER := lIndAvulso
    Else
         lIndAvulso := slIndAvQER
    EndIf

Return lIndAvulso

/*/{Protheus.doc} validaIndiceNotaAvulsoDoAlias
Valida se o índice _NISERI está presente na tabela informada (QEL ou QER).
Encapsula a lógica de delegação para validaIndiceNotaAvulsoNaQEL ou validaIndiceNotaAvulsoNaQER.
@type	Method
@author brunno.costa
@since 09/03/2026
@param 01 - cAlias, caracter, alias da tabela (ex: "QEL", "QER")
@return lIndAvulso, lógico, .T. - indica se o índice está presente na tabela informada
/*/
METHOD validaIndiceNotaAvulsoDoAlias(cAlias) CLASS QLTQueryManager
Return (cAlias == "QEL" .And. Self:validaIndiceNotaAvulsoNaQEL()) .Or. ;
       (cAlias == "QER" .And. Self:validaIndiceNotaAvulsoNaQER())

/*/{Protheus.doc} validaTamanhoCamposChaveNF
Valida Tamanho dos Campos nas tabelas QER e/ou QEL
@type	Method
@author willian.ramalho
@since 05/08/2025
@param 01 - cAliasA, caracter, nome do alias da tabela A para validação (SD1 ou QEK)
@param 02 - cAliasB, caracter, nome do alias da tabela B para valida (QEL ou QER)
@param 03 - cCmpNISERI, caracter, campo _NSERI para validação com concatenação de campos
@param 04 - cAliasOLD, caracter, nome do alias antigo para validação
@return lValido, lógico, .T. - indica se os tamanhos dos campos são do mesmo tamanho das tabelas QER e QEL
/*/
Method validaTamanhoCamposChaveNF(cAliasA, cAliasB, cCmpNISERI, cAliasOLD) CLASS QLTQueryManager

    Local aCampos    :={"_NTFISC", "_SERINF", "_ITEMNF"}
    Local aCamposSD1 :={"_DOC"   , "_SERIE" , "_ITEM"}
    Local cCpsErros  := ""
    Local lValido    := .T.
    Local nIndice    := 0
    Local nTamCampos := GetSX3Cache(cAliasOLD + Iif("D1" $ cAliasOLD, aCamposSD1[1], aCampos[1]), "X3_TAMANHO") +;
                        GetSX3Cache(cAliasOLD + Iif("D1" $ cAliasOLD, aCamposSD1[2], aCampos[2]), "X3_TAMANHO") +;
                        GetSX3Cache(cAliasOLD + Iif("D1" $ cAliasOLD, aCamposSD1[3], aCampos[3]), "X3_TAMANHO")


    If (cAliasB == "QEL" .And. Self:validaIndiceNotaAvulsoNaQEL()) .Or. (cAliasB == "QER" .And. Self:validaIndiceNotaAvulsoNaQER())

        If GetSX3Cache(cCmpNISERI, "X3_TAMANHO") != nTamCampos 
            Help(" ",1,"QIENISERI")
            lValido := .F.
        EndIf

    Else

        For nIndice := 1 to Len(aCampos) -1

            If GetSX3Cache(cAliasA + Iif("D1" $ cAliasA, aCamposSD1[nIndice], aCampos[nIndice]), "X3_TAMANHO") != GetSX3Cache(cAliasB + Iif("D1" $ cAliasB, aCamposSD1[nIndice], aCampos[nIndice]), "X3_TAMANHO")
                cCpsErros += Iif(Empty(cCpsErros), "", ", ") + cAliasA + Iif("D1" $ cAliasA, aCamposSD1[nIndice], aCampos[nIndice]) + "/" +;
                                                               cAliasB + Iif("D1" $ cAliasB, aCamposSD1[nIndice], aCampos[nIndice])
            EndIf

        Next nIndice

        If  !Empty(cCpsErros)
             // STR0019 - Os campos: 
             // STR0020 - Estão com tamanhos incompatíveis.
             // STR0021 - Ajuste o tamanho dos campos _NTFISC, _SERINF e _ITEMNF nos alias QER, QEL, QEK e SD1.
             Help(NIL, NIL, "QIENISERI1", NIL, STR0019 + " '" + cCpsErros + "' " + STR0020, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0021})
            lValido := .F.
        EndIf

    EndIf

Return lValido

/*/{Protheus.doc} retornaCamposDaNotaFiscalParaChaveDePesquisa
Method responsável por retornar a chave de pesquisa da Nota Fiscal.
@type	Method
@author willian.ramalho
@since 05/08/2025
@param 01 -       cAlias   , caracter, nome da tabela.
@param 02 -       lPonteiro, lógico  , indica se deverá utilizar o ponteiro no retorno da chave.
@param 03 -       cPonteiro, caracter, tipo de ponteiro para retorno da chave, por padrão "->".
@Return cRetorno, Caracter , retorna se sera utilizado o campo _NISERI ou a concatenação dos campos _NTFISC, _SERINF e _ITEMNF para chave de pesquisa da Nota Fiscal, dependendo da validação do índice de nota avulso na QEL.
/*/
Method retornaCamposDaNotaFiscalParaChaveDePesquisa(cAlias, lPonteiro, cPonteiro) CLASS QLTQueryManager
 
    Local aCampos     :={"_NTFISC + ", "_SERINF + ", "_ITEMNF ", "_NISERI"}
    Local cRetorno    := ""
    Local cUsaPont    := ""

    Default cPonteiro := "->"
    cUsaPont := Iif(lPonteiro, cAlias + cPonteiro + cAlias, cAlias)

    If (cAlias == "QEL" .And. Self:validaIndiceNotaAvulsoNaQEL()) .Or. (cAlias == "QER" .And. Self:validaIndiceNotaAvulsoNaQER())
        cRetorno := cUsaPont + aCampos[4]
    Else
        cRetorno := cUsaPont + aCampos[1] + cUsaPont + aCampos[2] + cUsaPont + aCampos[3]
    EndIf

Return cRetorno

/*/{Protheus.doc} dbSeek
Faz posicionamento em registro
@type	Method
@author brunno.costa
@since 24/10/2025
@param 01 - cAlias     , caracter, nome do alias onde será feito o seek
@param 02 - cMSUID     , caracter, valor do campo MSUID para seek
@param 03 - aWhereExtra, array, array com condições extras para filtro no seek (opcional)
          {
            cQryWhere , caracter, condição extra em sintaxe SQL
            aBinds    , array   , array com os dados dos parâmetros para BIND:
                          {{oDados, cTipo}, {}, ...}
                          Sendo cTipo:
                          N -> Número, para uso com FwExecStatement():setNumeric()
                          S -> String, para uso com FwExecStatement():setString()
                          A -> Array , para uso com FwExecStatement():setInArray()
                          U -> Unsafe, para uso com FwExecStatement():setUnsafe()
          }
@return lSeek, lógico, indica se o seek foi bem sucedido
/*/
Static Method dbSeek(cAlias, cMSUID, aWhereExtra) CLASS QLTQueryManager
 
    Local aBindParam   := {}
    Local cAliasQry    := ""
    Local cCampoFil    := Iif(Substring(cAlias,1,1) == "S", Substring(cAlias,2,2), cAlias) + "_FILIAL"
    Local cCampoUID    := Iif(Substring(cAlias,1,1) == "S", Substring(cAlias,2,2), cAlias) + "_MSUID"
    Local cQuery       := ""
    Local lChangeQuery := .T.
    Local lSeek        := .F.
    Local nBind        := 0
    Local nWhere       := 0

    Default aWhereExtra := {}

    DbSelectArea(cAlias)

    cQuery += " SELECT R_E_C_N_O_ "
    cQuery += " FROM " + RetSQLName(cAlias)
    cQuery += " WHERE "

    aAdd(aBindParam, {cCampoFil       , "U"})
    aAdd(aBindParam, {xFilial(cAlias) , "S"})
    cQuery += " ? = ? AND "

    If !Empty(cMSUID)
        aAdd(aBindParam, {cCampoUID       , "U"})
        aAdd(aBindParam, {cMSUID          , "S"})
        cQuery += " ? = ? AND "  
    EndIf

    //Atribui Bindings e condições extras
    For nWhere := 1 to Len(aWhereExtra)
        cQuery += aWhereExtra[nWhere][1] + " AND "  

        For nBind := 1 to Len(aWhereExtra[nWhere][2])
            aAdd(aBindParam, aWhereExtra[nWhere][2][nBind])
        Next nBind

    Next nWhere

    aAdd(aBindParam, {" "             , "S"})
    cQuery += " D_E_L_E_T_ = ? "

    cQuery += " ORDER BY " + SqlOrder( &( cAlias + "->(IndexKey())" ) )

    cAliasQry := QLTQueryManager():executeQueryWithBind(cQuery, aBindParam, lChangeQuery)

    (cAliasQry)->(DBGotop())
	If (cAliasQry)->(!EOF())
        (cAlias)->(DbGoTo((cAliasQry)->R_E_C_N_O_))        
        lSeek := !(cAlias)->(Eof())
    EndIf
    (cAliasQry)->(DbCloseArea())

Return lSeek


/*/{Protheus.doc} retornaTamanhoDosCamposDaNotaFiscal
@type	Method
@author willian.ramalho
@since 19/02/2026
@param 01 - cAlias   , caracter, nome da tabela.
@return nTamCampos, numerico , retorna o tamanho total dos campos que compõe a chave de pesquisa da Nota Fiscal, dependendo da validação do índice de nota avulso na QEL.
*/
Method retornaTamanhoDosCamposDaNotaFiscal(cAlias) CLASS QLTQueryManager
 
    Local aCampos    :={"_NTFISC + ", "_SERINF + ", "_ITEMNF ", "_NISERI"}
    Local nTamCampos := 0

    If (cAlias == "QEL" .And. Self:validaIndiceNotaAvulsoNaQEL()) .Or. (cAlias == "QER" .And. Self:validaIndiceNotaAvulsoNaQER())
        nTamCampos := GetSX3Cache(cAlias + aCampos[4], "X3_TAMANHO")
    Else
        nTamCampos := GetSX3Cache(cAlias + aCampos[1], "X3_TAMANHO") 
        nTamCampos += GetSX3Cache(cAlias + aCampos[2], "X3_TAMANHO") 
        nTamCampos += GetSX3Cache(cAlias + aCampos[3], "X3_TAMANHO") 
    EndIf

Return nTamCampos

/*/{Protheus.doc} ajustaCamposNotaParaArray
Ajusta Array com base no Indice da QEL para campos de Nota Avulsa.
@type	Method
@author willian.ramalho
@since 03/03/2026
@param 01 - aGetCampos   , array   , array de campos para ser tratado com base no Indice da QEL.
@param 02 - cAlias       , caracter, nome da tabela.
@return   - aGetCampos   , array   , array de campos ajustado com base no Indice da QEL.
*/
Method ajustaCamposNotaParaArray(aGetCampos, cAlias) CLASS QLTQueryManager
 
    Local aCampos     := {cAlias+"_NTFISC", cAlias+"_SERINF", cAlias+"_ITEMNF", cAlias+"_NISERI"}
    
    If (cAlias == "QEL" .And. Self:validaIndiceNotaAvulsoNaQEL()) .Or. (cAlias == "QER" .And. Self:validaIndiceNotaAvulsoNaQER())
        aAdd(aGetCampos, aCampos[4])
    Else
        aAdd(aGetCampos, aCampos[1])
        aAdd(aGetCampos, aCampos[2])
        aAdd(aGetCampos, aCampos[3])
    EndIf

Return aGetCampos

/*/{Protheus.doc} ajustaCamposNotaParaComparacaoEmQuery
Ajusta campos de Nota Avulsa para comparação em query com base no índice da QEL.
@type	Method
@author willian.ramalho
@since 03/03/2026
@param 01 - cAlias      , caracter, nome da tabela.
@param 02 - cPonteiro   , caracter, tipo de ponteiro para retorno da chave, por padrão "->".
@param 03 - cPrefixo    , caracter, prefixo do alias do campo para comparação
@param 04 - cPontCmpar  , caracter, Ponteiro da concatenação
Return    - cQuery      , caracter, query de comparação entre os campos de Nota Avulsa com base no índice da QEL para ser utilizado em cláusula WHERE ou ON de query.
*/
Method ajustaCamposNotaParaComparacaoEmQuery(cAlias, cPonteiro, cPrefixo, cPontCmpar) CLASS QLTQueryManager
 
    Local aCampos := {"_NTFISC", "_SERINF", "_ITEMNF", "_NISERI"}
    Local cQuery  := ""

    Default cPonteiro := "->"
    
    If (cAlias == "QEL" .And. Self:validaIndiceNotaAvulsoNaQEL()) .Or. (cAlias == "QER" .And. Self:validaIndiceNotaAvulsoNaQER())
        cQuery :=         cPonteiro+cAlias+aCampos[4] +"= " + self:acertaConcatenacaoComConcat(cPrefixo, "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF")
    Else
        cQuery :=         cPonteiro+cAlias+aCampos[1]+" = "+cPrefixo+cPontCmpar+aCampos[1]
        cQuery += " AND "+cPonteiro+cAlias+aCampos[2]+" = "+cPrefixo+cPontCmpar+aCampos[2]
        cQuery += " AND "+cPonteiro+cAlias+aCampos[3]+" = "+cPrefixo+cPontCmpar+aCampos[3]
    EndIf

Return cQuery

/*/{Protheus.doc} montaRelacaoCamposNotaCampoACampo
Monta relacionamento campo a campo para campos de Nota Avulsa (_NTFISC, _SERINF, _ITEMNF).
Utilizado quando ambos os lados possuem campos separados - compara campo a campo sem concatenar.
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cPrefA  , caracter, prefixo do alias A (ex: "QEK.")
@param 02 - cCamposA, caracter, campos do alias A concatenados com "+" (ex: "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF")
@param 03 - cPrefB  , caracter, prefixo do alias B (ex: "QEL.")
@param 04 - cCamposB, caracter, campos do alias B concatenados com "+" (ex: "QEL_NTFISC+QEL_SERINF+QEL_ITEMNF")
@return cQuery, caracter, query de comparação campo a campo
/*/
METHOD montaRelacaoCamposNotaCampoACampo(cPrefA, cCamposA, cPrefB, cCamposB) CLASS QLTQueryManager

    Local aCmpsA  := Strtokarr2(cCamposA, "+", .F.)
    Local aCmpsB  := Strtokarr2(cCamposB, "+", .F.)
    Local cQuery  := ""
    Local nPrefixo    := 0

    For nPrefixo := 1 to Len(aCmpsA)
        cQuery += Iif(nPrefixo > 1, " AND ", "")
        cQuery += " COALESCE(RTRIM(LTRIM(" + cPrefA + aCmpsA[nPrefixo] + ")), '#NULL#') = "
        cQuery += "COALESCE(RTRIM(LTRIM(" + cPrefB + aCmpsB[nPrefixo] + ")), '#NULL#') "
    Next

Return cQuery

/*/{Protheus.doc} montaRelacaoCamposNotaDerivado
Monta relacionamento campo a campo para Nota Avulsa em cenários mistos de retrocompatibilidade.

Utilizado quando um dos lados ainda utiliza o campo consolidado _NISERI (fontes não migrados)
e o outro já utiliza os campos avulsos separados (_NTFISC, _SERINF, _ITEMNF).

O método identifica automaticamente qual lado usa campos avulsos (contém "+") e qual usa
_NISERI, e deriva os campos individuais a partir do alias do lado _NISERI para que a
comparação final seja sempre campo a campo — sem concatenação — via
montaRelacaoCamposNotaCampoACampo.

Exemplos de entrada:
  Lado A (avulso) : cCamposA = "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF"
  Lado B (NISERI) : cCamposB = "QEL_NISERI"   -> derivado para "QEL_NTFISC+QEL_SERINF+QEL_ITEMNF"

@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cPrefA  , caracter, prefixo do alias A com ponto (ex: "QEK.", "LABOR.", "")
@param 02 - cCamposA, caracter, campos do alias A: avulsos separados por "+" (ex: "QEK_NTFISC+QEK_SERINF+QEK_ITEMNF")
                                 ou campo _NISERI consolidado (ex: "QEL_NISERI")
@param 03 - cPrefB  , caracter, prefixo do alias B com ponto (ex: "QEL.", "")
@param 04 - cCamposB, caracter, campos do alias B: avulsos separados por "+" ou campo _NISERI
@return cQuery, caracter, cláusula SQL de comparação campo a campo
                           (ex: "COALESCE(RTRIM(LTRIM(QEK.QEK_NTFISC)), '#NULL#') = COALESCE(RTRIM(LTRIM(QEL.QEL_NTFISC)), '#NULL#') AND ...")
/*/
METHOD montaRelacaoCamposNotaDerivado(cPrefA, cCamposA, cPrefB, cCamposB) CLASS QLTQueryManager

    Local cAlsNis  := ""
    Local cCmpsAvl := ""
    Local cCmpsDrv := ""
    Local cPrefAvl := ""
    Local cPrefDrv := ""

    //Identifica qual lado tem "+" (campos avulsos) e qual tem _NISERI
    If "+" $ cCamposA
        cPrefAvl := cPrefA
        cCmpsAvl := cCamposA
        cPrefDrv := cPrefB
        cAlsNis  := Left(cCamposB, 3) // "QEL" ou "QER"
    Else
        cPrefAvl := cPrefB
        cCmpsAvl := cCamposB
        cPrefDrv := cPrefA
        cAlsNis  := Left(cCamposA, 3)
    EndIf

    //Deriva campos avulsos do alias _NISERI (ex: QEL_NISERI -> QEL_NTFISC+QEL_SERINF+QEL_ITEMNF)
    cCmpsDrv := cAlsNis + "_NTFISC+" + cAlsNis + "_SERINF+" + cAlsNis + "_ITEMNF"

Return Self:montaRelacaoCamposNotaCampoACampo(cPrefAvl, cCmpsAvl, cPrefDrv, cCmpsDrv)

/*/{Protheus.doc} retornaCamposNotaParaSelect
Retorna string de campos de Nota Avulsa para cláusula SELECT.
Sempre inclui campos avulsos (_NTFISC, _SERINF, _ITEMNF); inclui _NISERI apenas se índice existir.
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cAlias  , caracter, prefixo do alias da tabela (ex: "QEL", "QER")
@param 02 - cPrefixo, caracter, prefixo completo com ponto (ex: "QEL.", "LABOR.", "")
@return cCampos, caracter, string com campos para SELECT
/*/
METHOD retornaCamposNotaParaSelect(cAlias, cPrefixo) CLASS QLTQueryManager

    Local cCampos := ""
    Local cPref   := Iif(Empty(cPrefixo), "", cPrefixo)

    If Self:validaIndiceNotaAvulsoDoAlias(cAlias)
        cCampos += cPref + cAlias + "_NISERI "
    Else
        cCampos += cPref + cAlias + "_NTFISC, "
        cCampos += cPref + cAlias + "_SERINF, "
        cCampos += cPref + cAlias + "_ITEMNF"
    EndIf

Return cCampos

/*/{Protheus.doc} retornaFiltroLikeNota
Retorna filtro LIKE para busca textual em campos de Nota Avulsa.
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cAlias  , caracter, prefixo do alias da tabela (ex: "QEL", "QER")
@param 02 - cPrefixo, caracter, prefixo completo com ponto (ex: "QEL.", "LABOR.", "")
@param 03 - cValor  , caracter, valor para filtro LIKE (já entre aspas/parâmetros)
@return cFiltro, caracter, expressão de filtro LIKE
/*/
METHOD retornaFiltroLikeNota(cAlias, cPrefixo, cValor) CLASS QLTQueryManager

    Local cFiltro := ""
    Local cPref   := Iif(Empty(cPrefixo), "", cPrefixo)

    If Self:validaIndiceNotaAvulsoDoAlias(cAlias)
        cFiltro := " (UPPER(" + cPref + cAlias + "_NISERI) LIKE UPPER(" + cValor + ") ) "
    Else
        cFiltro := " (UPPER(" + cPref + cAlias + "_NTFISC) LIKE UPPER(" + cValor + ") "
        cFiltro += " OR UPPER(" + cPref + cAlias + "_SERINF) LIKE UPPER(" + cValor + ") "
        cFiltro += " OR UPPER(" + cPref + cAlias + "_ITEMNF) LIKE UPPER(" + cValor + ") ) "
    EndIf

Return cFiltro

/*/{Protheus.doc} retornaVerificacaoNullNota
Retorna expressão IS NULL para verificação de existência de registros em LEFT JOINs.
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cAlias  , caracter, prefixo do alias da tabela (ex: "QEL")
@param 02 - cPrefixo, caracter, prefixo completo com ponto (ex: "LAUDOS.", "INCOMPLETOS.")
@return caracter, expressão IS NULL
/*/
METHOD retornaVerificacaoNullNota(cAlias, cPrefixo) CLASS QLTQueryManager

    Local cPref := Iif(Empty(cPrefixo), "", cPrefixo)

    If Self:validaIndiceNotaAvulsoDoAlias(cAlias)
        Return cPref + cAlias + "_NISERI IS NULL"
    EndIf

Return cPref + cAlias + "_NTFISC IS NULL"

/*/{Protheus.doc} retornaCoalesceNota
Gera expressão COALESCE SQL para campos de chave de NF.
Cada elemento de aPrefixo segue o formato 'ALIAS_TABELA.ALIAS_CAMPO' (ex: 'AMOSTRAS.QER').
O alias após '.' é verificado individualmente: se a tabela usa índice com campo único
(_NISERI), gera 1 coluna; se usa 3 campos separados, gera 3 colunas (_NTFISC/_SERINF/_ITEMNF).
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cAlias  , caracter, alias de fallback quando aPrefixo não contiver alias após '.'
@param 02 - aPrefixo, array   , prefixos no formato 'ALIAS_TABELA.ALIAS_CAMPO' (ex: {"AMOSTRAS.QER", "LAUDO.QEL"})
@param 03 - cDefault, caracter, valor default do COALESCE; vazio para omitir
@param 04 - cAliasNm, caracter, alias de saída; no modo 3 colunas recebe sufixo _NTFISC/_SERINF/_ITEMNF
@return cQuery, caracter, expressão COALESCE pronta para compor um SELECT
/*/
METHOD retornaCoalesceNota(cAlias, aPrefixo, cDefault, cAliasNm) CLASS QLTQueryManager

    Local aCampos    := {"_NTFISC", "_SERINF", "_ITEMNF"}
    Local aHasNiseri := {}
    Local cCurAlias  := ""
    Local cQuery     := ""
    Local lAllNiseri := .T.
    Local nCampo     := 0
    Local nPrefixo   := 0

    //Pre-passo: valida NISERI individualmente para cada alias de aPrefixo
    For nPrefixo := 1 to Len(aPrefixo)
        cCurAlias := SubStr(aPrefixo[nPrefixo], At(".", aPrefixo[nPrefixo]) + 1)
        cCurAlias := Iif(Empty(cCurAlias), cAlias, cCurAlias)
        aAdd(aHasNiseri, Self:validaIndiceNotaAvulsoDoAlias(cCurAlias))
        If !aHasNiseri[nPrefixo]
            lAllNiseri := .F.
        EndIf
    Next

    If lAllNiseri
        cQuery := " COALESCE("
        For nPrefixo := 1 to Len(aPrefixo)
            cQuery += Iif(nPrefixo > 1, ", ", "") + aPrefixo[nPrefixo] + "_NISERI"
        Next
        cQuery += Iif(!Empty(cDefault), ", " + cDefault, "") + ") " + cAliasNm + "_NISERI"
    Else
        //Gera COALESCE para cada campo separado individualmente
        For nCampo := 1 to Len(aCampos)
            cQuery += Iif(nCampo > 1, ", ", "") + " COALESCE("
            For nPrefixo := 1 to Len(aPrefixo)
                cQuery += Iif(nPrefixo > 1, ", ", "") + aPrefixo[nPrefixo] + Iif(aHasNiseri[nPrefixo], "_NISERI", aCampos[nCampo])
            Next
            cQuery += Iif(!Empty(cDefault), ", " + cDefault, "") + ") " + cAliasNm + aCampos[nCampo]
        Next
    EndIf

Return cQuery

/*/{Protheus.doc} retornaValorConcatenadoNota
Retorna valor concatenado dos campos de Nota Avulsa a partir de um alias posicionado (AdvPL puro).
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cAlias, caracter, alias posicionado (ex: "QER")
@return caracter, valor concatenado
/*/
METHOD retornaValorConcatenadoNota(cAlias) CLASS QLTQueryManager

    If Self:validaIndiceNotaAvulsoDoAlias(cAlias)
        Return (cAlias)->&(cAlias + "_NISERI")
    EndIf

Return (cAlias)->&(cAlias + "_NTFISC") + (cAlias)->&(cAlias + "_SERINF") + (cAlias)->&(cAlias + "_ITEMNF")

/*/{Protheus.doc} retornaValorChaveNotaDeRegistro
Retorna valor concatenado dos campos de Nota Avulsa a partir de um objeto/hash de registro (AdvPL puro).
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - oReg  , objeto  , objeto ou hash com dados do registro
@param 02 - cAlias, caracter, prefixo do alias (ex: "QER")
@return caracter, valor concatenado
/*/
METHOD retornaValorChaveNotaDeRegistro(oReg, cAlias) CLASS QLTQueryManager

    If Self:validaIndiceNotaAvulsoDoAlias(cAlias)
        Return oReg[cAlias + "_NISERI"]
    EndIf

Return oReg[cAlias + "_NTFISC"] + oReg[cAlias + "_SERINF"] + oReg[cAlias + "_ITEMNF"]

/*/{Protheus.doc} retornaCampoChaveNotaParaArray
Retorna string com nome do campo de chave de Nota Avulsa para uso em arrays de MontaRelationArraysCampos.
Quando índice _NISERI existe, retorna _NISERI. Quando não, retorna campos avulsos concatenados com "+".
@type	Method
@author brunno.costa
@since 04/03/2026
@param 01 - cAlias, caracter, prefixo do alias (ex: "QEL", "QER")
@return caracter, nome do campo ou campos concatenados com "+"
/*/
METHOD retornaCampoChaveNotaParaArray(cAlias) CLASS QLTQueryManager

    If Self:validaIndiceNotaAvulsoDoAlias(cAlias)
        Return cAlias + "_NISERI"
    EndIf

Return cAlias + "_NTFISC+" + cAlias + "_SERINF+" + cAlias + "_ITEMNF"

/*/{Protheus.doc} validaComparacaoCamposNotaQELComQEK
Valida comparacao entre campos QEL e QEK, utilizando _NISERI quando disponivel ou os 3 campos separados.
Encapsula a logica de decidir qual campo usar (NISERI ou campos avulsos).
@type	Method
@author brunno.costa
@since 09/03/2026
@return logico, resultado da comparacao
/*/
METHOD validaComparacaoCamposNotaQELComQEK() CLASS QLTQueryManager

    If Self:validaIndiceNotaAvulsoNaQEL()
        Return (QEL->QEL_NISERI == QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF)
    EndIf

Return (QEL->QEL_NTFISC == QEK->QEK_NTFISC .AND. QEL->QEL_SERINF == QEK->QEK_SERINF .AND. QEL->QEL_ITEMNF == QEK->QEK_ITEMNF)

/*/{Protheus.doc} buscaRoteiroDaOP
Faz DbSeek na tabela QPR pelo indice 1 (filial + ordem de producao) e retorna o campo QPR_ROTEIR.
@type	Method
@author brunno.costa
@since 15/05/2026
@param 01 - cFilQPR, caracter, filial para busca na QPR
@param 02 - cOP    , caracter, ordem de producao para busca na QPR
@return caracter, valor do campo QPR_ROTEIR, ou vazio se nao encontrado
/*/
METHOD buscaRoteiroDaOP(cFilQPR, cOP) CLASS QLTQueryManager

    Local aArea    := GetArea()
    Local cRoteiro := ""

    DbSelectArea("QPR")
    QPR->(DbSetOrder(1))
    If QPR->(DbSeek(cFilQPR + cOP))
        cRoteiro := QPR->QPR_ROTEIR
    EndIf
    QPR->(DbCloseArea())

    RestArea(aArea)

Return cRoteiro


/*/{Protheus.doc} buscaRoteiroDaOPPorQPK
Faz DbSeek na tabela QPR pelo indice 1 e retorna o campo QPR_ROTEIR.
@type	Method
@author brunno.costa
@since 15/05/2026
@param 01 - nRecnoQPK, numerico, recno do registro na tabela QPK que possui os campos FILIAL e ORDEM para busca na QPR
@return caracter, valor do campo QPR_ROTEIR, ou vazio se nao encontrado
/*/
METHOD buscaRoteiroDaOPPorQPK(nRecnoQPK) CLASS QLTQueryManager

    Local aArea    := GetArea()
    Local cRoteiro := ""

    Default nRecnoQPK := -1

    nRecnoQPK := Iif(ValType(nRecnoQPK) == "C", Val(nRecnoQPK), nRecnoQPK)

    DbSelectArea("QPK")
    QPK->(DbGoTo(nRecnoQPK))
    If QPK->(!Eof())
        cRoteiro := Self:buscaRoteiroDaOP(QPK->QPK_FILIAL, QPK->QPK_OP)
    EndIf
    QPK->(DbCloseArea())

    RestArea(aArea)

Return cRoteiro


/*/{Protheus.doc} montaInnerJoinSC2ComDesvioRoteiroConhecido
Monta o trecho INNER JOIN SC2 para queries de inspecao de processos, com
desvio quando cRoteiro ja eh conhecido via buscaRoteiroDaOPPorQPK().

Quando cRoteiro esta vazio: gera INNER JOIN completo com a SC2.
Quando cRoteiro esta preenchido: gera apenas o filtro AND direto, sem JOIN.

@type    Method
@author  brunno.costa
@since   15/05/2026
@param 01 - cCampoRoteiro, caracter, campo roteiro da tabela principal (ex: "QPR_ROTEIR", "QP7_CODREC")
@param 02 - cCampoOP     , caracter, campo OP para MontaRelationC2OP   (ex: "QPR_OP", "QPK_OP")
@param 03 - cRoteiro     , caracter, roteiro obtido via buscaRoteiroDaOPPorQPK(); vazio = desconhecido
@param 04 - aBindParam   , array   , array de bind por referencia (@aBindParam); NIL quando nao usa bind
@return caracter, trecho SQL pronto para concatenar em cQuery
/*/
METHOD montaInnerJoinSC2ComDesvioRoteiroConhecido(cCampoRoteiro, cCampoOP, cRoteiro, aBindParam) CLASS QLTQueryManager

    Local cTrecho  := ""
    Local lUsaBind := ValType(aBindParam) == "A"

    Default cRoteiro := ""

    If Empty(cRoteiro)
        cTrecho += " INNER JOIN "
        cTrecho += " (SELECT C2_NUM, C2_ITEM, C2_ITEMGRD, C2_SEQUEN, C2_ROTEIRO "
        cTrecho += " FROM " + RetSQLName("SC2") + " "
        cTrecho += " WHERE " + Self:montaQueryComparacaoFiliaisComValorReferencia("SC2", "C2_FILIAL", "QPK", xFilial("QPK"))
        If lUsaBind
            cTrecho += " AND D_E_L_E_T_ = ?) SC2 "
            aAdd(aBindParam, {" ", "S"})
        Else
            cTrecho += " AND D_E_L_E_T_=' ') SC2 "
        EndIf
        cTrecho += " ON " + Self:montaRelationC2OP(cCampoOP)
        cTrecho += Iif(SuperGetMV("MV_QIPOPEP") == "3", ;
            " AND (" + cCampoRoteiro + " = C2_ROTEIRO OR " + cCampoRoteiro + " = '" + QIPRotGene(cCampoRoteiro) + "') ", ;
            " AND " + cCampoRoteiro + " = C2_ROTEIRO ")
    Else
        cTrecho += Iif(SuperGetMV("MV_QIPOPEP") == "3", ;
            " AND (" + cCampoRoteiro + " = '" + cRoteiro + "' OR " + cCampoRoteiro + " = '" + QIPRotGene(cCampoRoteiro) + "') ", ;
            " AND " + cCampoRoteiro + " = '" + cRoteiro + "' ")
    EndIf

Return cTrecho
