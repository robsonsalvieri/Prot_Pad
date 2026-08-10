#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE VDP_POS_FILIAL       1
#DEFINE VDP_POS_PRODUTO      2
#DEFINE VDP_POS_DATA_INICIO  3
#DEFINE VDP_POS_DATA_FIM     4
#DEFINE VDP_POS_QTDE_INICIO  5
#DEFINE VDP_POS_QTDE_FIM     6
#DEFINE VDP_POS_REVISAO      7
#DEFINE VDP_POS_ROTEIRO      8
#DEFINE VDP_POS_LOCAL        9
#DEFINE VDP_POS_CODIGO       10
#DEFINE VDP_POS_TAMANHO      10

#DEFINE aVersao_POS_REVISAO  1
#DEFINE aVersao_POS_ROTEIRO  2
#DEFINE aVersao_POS_LOCAL    3
#DEFINE aVersao_POS_CODIGO   4

/*/{Protheus.doc} MrpDominio_VersaoDaProducao
Regras de negócio MRP - Versão da Produção

@author    brunno.costa
@since     19/09/2019
@version   1
/*/
CLASS MrpDominio_VersaoDaProducao FROM LongClassName

	DATA oDados   AS Object //instância da camada de dados
	DATA aVersoes AS Array  //Array com as Versões da Produção do último Produto

	METHOD new(oDominio) CONSTRUCTOR
	METHOD identifica(cProduto, nQtde, dData, lMantem)
	METHOD limpaMemoria()
	METHOD possui(cProduto)
	METHOD getPosicao(cCampo, cArray)

ENDCLASS

/*/{Protheus.doc} new
Método construtor

@author    brunno.costa
@since     19/09/2019
@version   1
@param 01 - oDominio, Object, objeto da camada de domínio
@param 02 - oDados  , Object, objeto da camada de dados
/*/
METHOD new(oDominio) CLASS MrpDominio_VersaoDaProducao
	::oDados   := oDominio:oDados
Return Self

/*/{Protheus.doc} getPosicao
Retorna a posição do campo na tabela de versão da produção
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - cCampo, caracter, string com o nome do campo relacionado aos dados de rastreabilidade
@param 02 - cArray, caracter, string com o nome do array referencia
@Return nReturn, número, posição padrão do registro no array de dados
/*/
METHOD getPosicao(cCampo, cArray) CLASS MrpDominio_VersaoDaProducao

	Local   nReturn := 0
	Default cArray := ""

	If Empty(cArray)
		Do Case
			Case cCampo == "FILIAL"
				nReturn := VDP_POS_FILIAL
			Case cCampo == "PRODUTO"
				nReturn := VDP_POS_PRODUTO
			Case cCampo == "DATA_INICIO"
				nReturn := VDP_POS_DATA_INICIO
			Case cCampo == "DATA_FIM"
				nReturn := VDP_POS_DATA_FIM
			Case cCampo == "QTDE_INICIO"
				nReturn := VDP_POS_QTDE_INICIO
			Case cCampo == "QTDE_FIM"
				nReturn := VDP_POS_QTDE_FIM
			Case cCampo == "REVISAO"
				nReturn := VDP_POS_REVISAO
			Case cCampo == "ROTEIRO"
				nReturn := VDP_POS_ROTEIRO
			Case cCampo == "LOCAL"
				nReturn := VDP_POS_LOCAL
			Case cCampo == "CODIGO"
				nReturn := VDP_POS_CODIGO
			OtherWise
				nReturn := VDP_POS_TAMANHO
		EndCase

	ElseIf cArray == "aVersao"

		Do Case
			Case cCampo == "REVISAO"
				nReturn := aVersao_POS_REVISAO
			Case cCampo == "ROTEIRO"
				nReturn := aVersao_POS_ROTEIRO
			Case cCampo == "LOCAL"
				nReturn := aVersao_POS_LOCAL
			Case cCampo == "CODIGO"
				nReturn := aVersao_POS_CODIGO
			OtherWise
				nReturn := aVersao_POS_REVISAO
		EndCase
	EndIf

Return nReturn

/*/{Protheus.doc} identifica
Identifica o array de versão da produção deste produto, quantidade e data

@author    brunno.costa
@since     19/09/2019
@version   1
@param 01 - cProduto, Caracter, código do produto Pai da Estrutura
@param 02 - nQtde   , Caracter, quantidade para explosão do Produto Pai
@param 03 - dData   , Numérico, data da da necessidade de fabricação
@param 04 - lMantem , Lógico  , informa se mantém o aVersao em memória após o término
@return aVersao     , array   , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Revisão da Estrutura            ,;
								     2 - Roteiro de Produção             ,;
								     3 - Local Padrão - Versão da Produção} ,...}
/*/
METHOD identifica(cProduto, nQtde, dData, lMantem) CLASS MrpDominio_VersaoDaProducao
	Local aVersao    := {}
	Local cbOrder
	Local cbScan
	Local cGlobalKey := ::oDados:oVersaoDaProducao:cGlobalKey
  	Local lRet
	Local nTotal
	Local nInd         := 0
	Local nVDP_QNTDE   := VDP_POS_QTDE_INICIO
	Local nVDP_QNTATE  := VDP_POS_QTDE_FIM
	Local nVDP_DTINI   := VDP_POS_DATA_INICIO
	Local nVDP_DTFIN   := VDP_POS_DATA_FIM
	Local nVDP_REV     := VDP_POS_REVISAO
	Local nVDP_ROTEIRO := VDP_POS_ROTEIRO
	Local nVDP_LOCAL   := VDP_POS_LOCAL
	Local nVDP_CODIGO  := VDP_POS_CODIGO

	Default lMantem := .F.

	If Self:oDados:oParametros["lRastreia"]
		If ::aVersoes == Nil
			::aVersoes   := {}
			cbOrder    := {|x,y| (Iif(x[2][nVDP_QNTDE] <= nQtde .AND. nQtde <= x[2][nVDP_QNTATE], .T., .F.) .AND. ;
	                              Iif((Empty(x[2][nVDP_DTINI]) .AND. Empty(x[2][nVDP_DTFIN])) .OR. (x[2][nVDP_DTINI] <= dData .AND. dData <= x[2][nVDP_DTFIN]) , .T., .F.)) .OR.  ;
								 x[2][nVDP_QNTDE] < y[2][nVDP_QNTDE] .AND. ;
			                     x[2][nVDP_DTINI] < y[2][nVDP_DTINI] }
			lRet         := VarGetAA(cGlobalKey+cProduto, @::aVersoes, cbOrder)
			nTotal       := Len(::aVersoes)

		EndIf
		cbScan       := {|x| x[2][nVDP_QNTDE] <= nQtde .AND. nQtde <= x[2][nVDP_QNTATE] .AND. ;
	                         ((x[2][nVDP_DTINI] <= dData .AND. dData <= x[2][nVDP_DTFIN]) .OR.;
							  (Empty(x[2][nVDP_DTINI]) .AND. Empty(x[2][nVDP_DTFIN])))        }
		nInd         := aScan(::aVersoes, cbScan )
	EndIf

	If nTotal > 0 .AND. nInd > 0
		If ::aVersoes[nInd][2][nVDP_QNTDE] <= nQtde .AND. nQtde <= ::aVersoes[nInd][2][nVDP_QNTATE] .AND.;
		   ((::aVersoes[nInd][2][nVDP_DTINI] <= dData .AND. dData <= ::aVersoes[nInd][2][nVDP_DTFIN]);
		    .OR. (Empty(::aVersoes[nInd][2][nVDP_DTINI]) .AND. Empty(::aVersoes[nInd][2][nVDP_DTFIN])))
			aVersao := {::aVersoes[nInd][2][nVDP_REV],;
			            ::aVersoes[nInd][2][nVDP_ROTEIRO],;
						::aVersoes[nInd][2][nVDP_LOCAL],;
						::aVersoes[nInd][2][nVDP_CODIGO]}
		EndIf
	EndIf

	If !lMantem
		::limpaMemoria()
	EndIf

Return aVersao

/*/{Protheus.doc} possui
verifica se o produto possui versão da produção

@author    brunno.costa
@since     19/09/2019
@version   1
@param 01 - cProduto, Caracter, código do produto Pai da Estrutura
@return lReturn     , lógico  , indica se possui controle de versão da produção
/*/
METHOD possui(cProduto) CLASS MrpDominio_VersaoDaProducao

	Local cGlobalKey := ::oDados:oVersaoDaProducao:cGlobalKey

Return VarIsUID(cGlobalKey+cProduto)

/*/{Protheus.doc} limpaMemoria
Limpa array ::aVersoes da Memória

@author    brunno.costa
@since     19/09/2019
@version   1
/*/
METHOD limpaMemoria() CLASS MrpDominio_VersaoDaProducao

	Local nInd
	Local aVersoes := ::aVersoes
	Local nTotal   := Iif(aVersoes == Nil, 0, Len(aVersoes))

	For nInd := 1 to nTotal
		aSize(::aVersoes[nInd], 0)
		::aVersoes[nInd] := Nil
	Next
	::aVersoes := Nil

Return Nil
