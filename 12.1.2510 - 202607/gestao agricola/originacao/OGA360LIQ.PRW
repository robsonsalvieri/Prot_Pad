#Include "FINA565.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"


/*/{Protheus.doc} OGA360LIQ
Rotina de geração de liquidação de titulos no financeiro para a ordem de pagamento do contrato de compra

@author: Equipe Agroindustria
@since:  24/04/2025
@Uso:    SIGAAGR - Originação de Grãos
@type function
/*/
Function OGA360LIQ(cCtrato, cItFix, cCPagto, cTpo, cNaturez, cPrefix, nMoeda, nVroPag, dDtVencto, cForDe, cLjaDe, cForPara, cLjaPara, cBco, cAg, cConta, cQry, oGridNKK,nAcrescLq,ndecresLq )
    Local nX			:= 1
    Local lRet          := .T.
    Local nVrLqdAux	    := 0
    Local aSaveLines     := {}
    Local dDataDe       := NIL
    Local dDataPara     := NIL
    Local cNumDe        := ''
    Local cNumAte       := '' 
    Local nAtuMod       := nModulo
    Local cNumE2        := ''
    Local cPrefDe       := ''
    Local cPrefPara     := ''
    Local aTela1        := {}
    Local aTela2        := {}
    Local aEdtVlr       := {}
    Local aCols         := {}
    Local aItens        := {}
    Local nRotina       := 2 // Liquidar
    Local cFilSQL 	    := ""
    //Manter para que não ocorra erro até pedir alteração para o Financeiro "__cLojaAGR".
    __cLojaAGR          := cLjaPara
  
    // Variaveis utilizadas para o controle de erro da rotina automatica.
    Private lMsErroAuto := .F.
    Private lAutoErrNoFile := .F.

    aSaveLines := FWSaveRows()
    aEdtVlr := {}
    AAdd( aEdtVlr, {'Editar', .T. } ) //- Se necessario Editar Valores
    For nX:=1 To oGridNKK:Length()
        
        oGridNKK:GoLine(nX)

        IF oGridNKK:IsDeleted()
            Loop
        EndIF

        nVrLqdAux := oGridNKK:GetValue('NKK_VRLQDF') + oGridNKK:GetValue('NKK_FRELQD') + oGridNKK:GetValue('NKK_SEGLQD') + oGridNKK:GetValue('NKK_DSPLQD')
        nVrLqdAux += oGridNKK:GetValue('NKK_DECRES') - oGridNKK:GetValue('NKK_ACRESC')

        nRecnoTIT := 0
        nRecnoTIT := OG360RgTIT(oGridNKK:GetValue('NKK_TABLQD'), oGridNKK:GetValue('NKK_CPOTIT'), oGridNKK:GetValue('NKK_CHVTIT'))

        SE2->( DbGoto( nRecnoTit ) )
        
        aAdd( aEdtVlr,   {    {'chave',SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)},;
                                {'nCotMoed', 1},;
                                {'nValJur', 0},;
                                {'nValDes', 0},;
                                {'nValLiq', nVrLqdAux},; 
                        } )
        
        IF dDataDe = NIL .or. dDataDe > SE2->E2_EMISSAO
            dDataDe := SE2->E2_EMISSAO
        ENDIF
        IF dDataPara = NIL .or. dDataPara < SE2->E2_EMISSAO
            dDataPara := SE2->E2_EMISSAO
        ENDIF

        IF EMPTY( cNumDe )  .or. cNumDe > SE2->E2_NUM
            cNumDe := SE2->E2_NUM
        ENDIF
        IF EMPTY( cNumAte ) .or. cNumAte < SE2->E2_NUM
            cNumAte := SE2->E2_NUM
        ENDIF

        IF EMPTY( cPrefDe )  .or. cPrefDe > SE2->E2_PREFIXO
            cPrefDe := SE2->E2_PREFIXO
        ENDIF
        IF EMPTY( cPrefPara )  .or. cPrefPara < SE2->E2_PREFIXO
            cPrefPara := SE2->E2_PREFIXO
        ENDIF

        If lRet    // Se titulo foi encontrado e o Vr. é suficiente para Baixar defino o filtro das NF para liquidar
			If nX > 1
				cFilSQL += " OR "
			EndIf
			cFilSQL += " ( "
			cFilSQL += " E2_FILIAL  = '" + SE2->E2_FILIAL + "' AND "
			cFilSQL += " E2_PREFIXO = '" + SE2->E2_PREFIXO + "' AND E2_NUM  = '" + SE2->E2_NUM + "' AND "
			cFilSQL += " E2_PARCELA = '" + SE2->E2_PARCELA + "' AND E2_TIPO = '" + SE2->E2_TIPO + "' AND "
			cFilSQL += " E2_FORNECE = '" + SE2->E2_FORNECE + "' AND E2_LOJA = '" + SE2->E2_LOJA + "' )"      
		EndIF

        SE2->( DbCloseArea() )
    NEXT nX
    FWRestRows( aSaveLines ) //Restaura a posição anterior dos Grids


    If lRet
        Pergunte("FIN565",.F.)
        
        aAdd(aTela1, {'cFornDe',    cForDe}) //- Fornecedor De:
        aAdd(aTela1, {'cLojaDe',    cLjaDe }) //- Loja De:
        aAdd(aTela1, {'cFornAte',   cForDe}) //- Fornecedor Até:
        aAdd(aTela1, {'cLojaAte',   cLjaDe }) //- Loja Até:
        aAdd(aTela1, {'cForn565',   cForPara}) //- Gerar p/:
        aAdd(aTela1, {'cLoja',      cLjaPara}) //- Loja:
        aAdd(aTela1, {'cMoeda565',  CVALTOCHAR( nMoeda )}) //- Moeda:
        aAdd(aTela1, {'dData565I',  CTOD(CVALTOCHAR(dDataDe))}) //- Data De:
        aAdd(aTela1, {'dData565F',  CTOD(CVALTOCHAR(dDataPara))}) //- Data Até:
        aAdd(aTela1, {'cPrefDe',    ''}) //- Prefx De:
        aAdd(aTela1, {'cPrefAte',   PadR("Z",TamSX3("E2_PREFIXO")[1],"Z")}) //- Prefx Até:
        aAdd(aTela1, {'cNumDe',     cNumDe}) //- Titulo De:
        aAdd(aTela1, {'cNumAte',    cNumAte}) //- Titulo Até: 

        aAdd(aTela2, {'cCondicao',  cCPagto }) //- Condicao (opcional)
        aAdd(aTela2, {'cTipo',      cTpo }) //- Tipo
        aAdd(aTela2, {'cNatureza',  cNaturez }) //- Natureza
        aAdd(aTela2, {'cFornece',   cForPara }) //- Fornecedor
        aAdd(aTela2, {'cLoja',      cLjaPara }) //- Loja 
                
        // -- Encontrando o Nr. da Liquidacao q será gerado 		--- //
        cNumE2	:= Soma1(GetMv("MV_NUMLIQP"),6)
        While !MayIUseCode( "E2_NUMLIQP"+cNumE2 )	//--- Verifica se esta na memoria, sendo usado 	---//
            cNumE2 := Soma1(cNumE2)			 		//--- Busca o proximo numero disponivel 			---//
        EndDo

        aItens := {}
        AADD(aItens, {'E2_PREFIXO', cPrefix}) //- Prefixo
        AADD(aItens, {'E2_BCOCHQ' , cBco}) //- Banco
        AADD(aItens, {'E2_AGECHQ' , cAg}) //- Agencia
        AADD(aItens, {'E2_CTACHQ' , cConta}) //- Conta
        AADD(aItens, {'E2_NUM' ,    cNumE2}) //- Num Cheque
		If EMPTY( cCPagto )
			AADD(aItens, {'E2_VENCTO' , dDtVencto}) //- Dt Vencimento
			AADD(aItens, {'E2_VLCRUZ' , nVroPag}) //- Valor
			AADD(aItens, {'E2_ACRESC' , nAcrescLq}) //- Acrescimo
			AADD(aItens, {'E2_DECRESC', ndecresLq}) //- Decrescimo
			AADD(aItens, {'E2_VALOR' , nVroPag}) //- Valor Total
		EndIf
        AADD(aCols, ACLONE(aItens))
        
        nModulo := 6
        MSEXECAUTO( { |a, b, c, d, e, f, g, h| FINA565( a, b, c, d, e, f, g, h )}, nRotina, aTela1, Nil, aTela2, aCols, aEdtVlr, .T., cFilSQL)
        nModulo := nAtuMod
        
        If lMsErroAuto
            lRet := .F.
            MostraErro()
        Else
            //procura pelo titulo e se achar mantem posicionado
            SE2->(DbSetOrder(6)) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO   
            SE2->(DbSeek(xFilial("SE2")+PadR(cForPara,TamSX3("E2_FORNECE")[1])+PadR(cLjaPara,TamSX3( "E2_LOJA")[1])+PadR(cPrefix,TamSX3( "E2_PREFIXO" )[1])+PadR(cNumE2,TamSX3("E2_NUM")[1]) ))            
        EndIf
    EndIf

return(lRet)

/*/{Protheus.doc} OGA360LIQC
Cancelamento da liquidação da ordem de pagamento gerado para o contrato de compra
Ao chamar esta função necessario estar com a SE2 que será cancelada posicionada

@author: Equipe Agroindustria
@since:  24/04/2025
@Uso:    SIGAAGR - Originação de Grãos
@type function
/*/
Function OGA360LIQC( )
    Local nRotina   := 4
    Local aTela1    := {}
    Local cNumLiq   := SE2->E2_NUMLIQ
    Local lRet := .T.

    Private lMsErroAuto := .F.
    Private lAutoErrNoFile := .T.
 
    AADD(aTela1,{"CLIQCAN",cNumLiq}) 

    If Select("TRBCAN") > 0
        TRBCAN->(dbCloseArea())
    EndIf
      
    MSEXECAUTO( { |a, b, c, d, e, f, g, h| FINA565( a, b, c, d, e, f, g, h)}, nRotina, aTela1, Nil, Nil, Nil, Nil, .T., Nil )
  
    If lMsErroAuto
        lRet := .F.
        MostraErro()        
    Else
        MSGINFO("Liquidação cancelada com sucesso!")
    EndIf

return lRet


/*/{Protheus.doc} OG360DARQ
Função chamada pelo FINA565 para validar se exclui arquivo de tabela temporaria para recriar nova
@type function
@version P12.1.2410  
@author claudineia.reinert
@since 02/01/2025
@return Logical, .T. ou .F.
/*/
Function OG360DARQ()
	Local lRet := .F.

	If FindFunction("OGXUTOG") .and. OGXUTOG() //Encontra a função
		If IsInCallStack("OGA360LIQ")
			lRet := .T.
		Endif
	Endif
Return lRet
