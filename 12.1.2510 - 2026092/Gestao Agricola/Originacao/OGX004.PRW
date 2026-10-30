#INCLUDE "OGX004.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGX004DESC

@param: 	cTabela - Codigo da Tabela de Desconto
@param: 	cPsSubt - Peso Subtotal para Base de Calculo
@param: 	aItens[ x, 1 ] - Codigo do Desconto da Tabela
@param: 	aItens[ x, 2 ] - Percentual de avaliação para o Desconto

@return:	aRetorno[ x, 1 ] - Codigo do Desconto
@return:	aRetorno[ x, 2 ] - Peso base para o Calculo
@return:	aRetorno[ x, 3 ] - Percentual de Avaliação
@return:	aRetorno[ x, 4 ] - Percentual de Desconto
@return:	aRetorno[ x, 5 ] - Quantidade a ser Descontada/Retida
@return:	aRetorno[ x, 6 ] - Nova Espécie
@return:	aRetorno[ x, 7 ] - Tabela alternativa

@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA250 - Romaneio
@type function
*/
Function OGX004DESC( cTabela, nPsSubt, aItens, lRecursivo )
    Local aRetorno	:= {}
    Local aMatriz	:= { { "", "" }, { "", "" }, { "", "" } }

    Local lLinhaOK	:= .f.
    Local lColOK	:= .f.
    
    Local cCodDes	:= ""

    Local nX		:= 0
    Local nPerDes	:= 0
    Local nReaDes	:= 0
    Local nPsLiqu	:= nPsSubt
    Local aCopyRet  := {}
    Local aFilhos   := {}
    Local cFormula  := ""
    Local nY        := 0
	Local nL        := 0
    
	Local nDecPeso  := SuperGetMV("MV_OGDECPS",,0)
    Local aRetPe    := {}

    Local cFilNNJ   := FWxFilial("NNJ")
    Local cFilNNK   := FWxFilial("NNK")
    Local cFilNJZ   := FWxFilial("NJZ")

    Local oHashItens   := HMNew()  // chave: AllTrim(codigo) -> indice em aItens
    Local oHashRet     := HMNew()  // chave: AllTrim(codigo) -> indice em aRetorno

    Default lRecursivo := .F.

    If ValType( cTabela ) <> "C" .Or. ValType( nPsSubt ) <> "N" .Or. ValType( aItens ) <> "A"
        Return( {} )
    Else
        If Empty( cTabela ) .Or. Empty( nPsSubt ) .Or. Empty( aItens )
            Return( {} )
        EndIf
    EndIf

    If !lRecursivo
        For nX := 1 to Len( aItens )
            aAdd( aRetorno, { aItens[ nX, 1 ], 0, aItens[ nX, 2 ], 0, 0, "", "", "","","" } )
        Next nX
    Else
        aRetorno := aItens
    EndIf

    For nX := 1 To Len(aItens)
        HMSet( oHashItens, AllTrim(aItens[nX, 1]), nX )
    Next nX

    For nX := 1 To Len(aRetorno)
        HMSet( oHashRet, AllTrim(aRetorno[nX, 1]), nX )
    Next nX

    NNJ->( dbSetOrder( 1 ) )
    NNK->( dbSetOrder( 1 ) )

    For nX := 1 to Len( aRetorno )
        
        If lRecursivo .and. aRetorno[nX, 8] != '1'
            loop
        EndIf

        cCodDes := aRetorno[ nX, 1 ]
        nPerDes := aRetorno[ nX, 3 ]
        nReaDes := 0
                
		NNJ->( dbSeek( cFilNNJ + cTabela + cCodDes ) ) 

        
		NNK->( dbSeek( cFilNNK + cTabela + cCodDes ) )         
		While .Not. NNK->( Eof() ) .And. NNK->NNK_FILIAL == cFilNNK .And. NNK->NNK_CODTAB == cTabela .And. NNK->NNK_CODDES == cCodDes
            nReaDes := 0
            If NNJ->NNJ_MATRIZ = "3" .And. lLinhaOK .And. lColOK
                NJZ->( dbSetORder( 1 ) )
                If NJZ->( dbSeek( cFilNJZ + cTabela + aMatriz[ 1, 1 ] + aMatriz[ 1, 2 ] + aMatriz[ 2, 1 ] + aMatriz[ 2, 2 ] ) )
					nPerDes := NJZ->( NJZ_VALOR  )
                    aRetorno[ nX, 3 ] := nPerDes
                Else
                    nPerDes := 0
                    aRetorno[ nX, 3 ] := 0
                EndIf
            Else
                If NNJ->NNJ_MATRIZ = "3"
                    nPerDes := 0
                    aRetorno[ nX, 3 ] := 0
                EndIf
            EndIf
            
            If NNJ->NNJ_MATRIZ = "3"
                if empty(aMatriz[ 1, 1 ]) .or. empty(aMatriz[ 2, 1 ])
                    Exit
                EndIf
                HMGet( oHashItens, AllTrim(aMatriz[ 1, 1 ]), nY )
                If nY == 0 .Or. empty(aItens[ nY, 2 ])
                   Exit
                EndIf
                
                HMGet( oHashItens, AllTrim(aMatriz[ 2, 1 ]), nY )
                If nY == 0 .Or. empty(aItens[ nY, 2 ])
                   Exit
                EndIf                
            EndIf
            
            If NNK->NNK_PERPRO = "S"
                If NNJ->NNJ_MATRIZ = "1"; aMatriz[ 1, 1 ] := NNJ->NNJ_CODDES; aMatriz[ 1, 2 ] := NNK->NNK_SEQ; lLinhaOK := .t.; EndIf
                If NNJ->NNJ_MATRIZ = "2"; aMatriz[ 2, 1 ] := NNJ->NNJ_CODDES; aMatriz[ 2, 2 ] := NNK->NNK_SEQ; lColOK := .t.; EndIf
                
                If NNK->NNK_PERINI = NNK->NNK_PERFIM .AND. nPerDes >= NNK->NNK_PERFIM
                    nReaDes := nPerDes - NNK->NNK_PERFIM
                    Exit
                ElseIf nPerDes >= NNK->NNK_PERINI .And. nPerDes <= NNK->NNK_PERFIM

                    aRetorno[ nX, 3 ] := nPerDes
                    nReaDes := nPerDes
                    aRetorno[ nX, 7 ] := NNK->( NNK_TABALT ) //Tabela Alternativa
				Exit
                ElseIf nPerDes >= NNK->NNK_PERFIM
                    nReaDes := nPerDes - NNK->NNK_PERFIM
                    Exit
                EndIf
				
            Else
                If nPerDes >= NNK->NNK_PERINI .And. nPerDes <= NNK->NNK_PERFIM
                    nReaDes := NNK->NNK_PERDES
                    aRetorno[ nX, 7 ] := NNK->NNK_TABALT
                    
                    If NNJ->NNJ_MATRIZ = "1"; aMatriz[ 1, 1 ] := NNJ->NNJ_CODDES; aMatriz[ 1, 2 ] := NNK->NNK_SEQ; lLinhaOK := .t.; EndIf
                    If NNJ->NNJ_MATRIZ = "2"; aMatriz[ 2, 1 ] := NNJ->NNJ_CODDES; aMatriz[ 2, 2 ] := NNK->NNK_SEQ; lColOK := .t.; EndIf
                    Exit
                EndIf
            EndIf
            NNK->( dbSkip() )

        EndDo

        aRetorno[ nX, 4 ] := nReaDes

    Next nX

    NNJ->( dbSetOrder( 2 ) )
    NNJ->( dbSeek( xFilial( "NNJ" ) + cTabela ) )

    While .Not. NNJ->( Eof() ) .And. NNJ->NNJ_FILIAL = cFilNNJ .And. NNJ->NNJ_CODTAB = cTabela  
		If lRecursivo .and. NNJ->NNJ_GRUPO != '1'
			NNJ->( dbSkip() )
			Loop
		EndIf

        IF HMGet( oHashRet, AllTrim(NNJ->NNJ_CODDES), nL )

            If NNJ->NNJ_INCIDE = "A"
                aRetorno[ nL, 2 ] := nPsSubt
            ElseIf NNJ->NNJ_INCIDE = "B"
                aRetorno[ nL, 2 ] := nPsLiqu
            EndIf
            
            aRetorno[ nL, 5 ] := Round( ( aRetorno[ nL, 2 ] * aRetorno[ nL, 4 ] / 100 ), nDecPeso )
            
			aRetorno[ nL, 8 ]  := NNJ->NNJ_GRUPO
			aRetorno[ nL, 9 ]  := NNJ->NNJ_DESREL
			aRetorno[ nL, 10 ] := NNJ->NNJ_FORMUL
            
            nPsLiqu -= aRetorno[ nL, 5 ]
        EndIf

        NNJ->( dbSkip() )
    EndDo
    NNJ->( dbSetOrder( 1 ) )


	If !lRecursivo
		aCopyRet := aClone(aRetorno)
		
		// executa a primeira vez para os subgrupos

		For nX := 1 To Len(aRetorno)
			If aRetorno[ nX, 8 ] == "2" //SubGrupo		
				aFilhos := {}

				//coletar filhos em passagem única
				For nY := 1 To Len(aCopyRet)
					If AllTrim(aCopyRet[nY, 9]) == AllTrim(aRetorno[nX, 1])
						aAdd(aFilhos, aCopyRet[nY])
					EndIf
				Next nY
				
				cFormula := aRetorno[ nX, 10 ]
				For nY := 1 To Len(aFilhos)
					cFormula := StrTran( cFormula, AllTrim(aFilhos[nY,1])+"D", str(aFilhos[nY, 4])) //desconto
					cFormula := StrTran( cFormula, AllTrim(aFilhos[nY,1])+"R", str(aFilhos[nY, 3])) //resultado
				Next nY
				
				aRetorno[nX, 3] := fExecForm(cFormula)

				If aRetorno[nX, 3] < 0
					aRetorno[nX, 3]  := 0
				EndIf
			EndIf
		Next nX

		//executa a segunda vez para os grupos
		aCopyRet := aClone(aRetorno) //chama novamente para recarregar os valores

		cFormula := ""
		For nX := 1 To Len(aRetorno)
			If aRetorno[ nX, 8 ] == "1"
				aFilhos := {}
				// Coletar filhos em passagem única
				For nY := 1 To Len(aCopyRet)
					If AllTrim(aCopyRet[nY, 9]) == AllTrim(aRetorno[nX, 1])
						aAdd(aFilhos, aCopyRet[nY])
					EndIf
				Next nY
				
				cFormula := aRetorno[ nX, 10 ]
				For nY := 1 To Len(aFilhos)
					cFormula := StrTran( cFormula, AllTrim(aFilhos[nY,1])+"D", str(aFilhos[nY, 4])) //desconto
					cFormula := StrTran( cFormula, AllTrim(aFilhos[nY,1])+"R", str(aFilhos[nY, 3])) //resultado
				Next nY
				
				aRetorno[nX, 3] := fExecForm(cFormula)

				If aRetorno[nX, 3] < 0
					aRetorno[nX, 3]  := 0
				EndIf
			EndIf
		Next nX

		aRetorno := OGX004DESC( cTabela, nPsSubt, aRetorno, .T. )
	EndIf

	//PE que permite usuario efetuar ajustes na classificação.
    If EXISTBLOCK("OGX00401")
        aRetPe := ExecBlock("OGX00401",.F.,.F.,{aRetorno, cTabela, nPsSubt, aItens, lRecursivo })
        If ValType(aRetPe) == 'A'
            aRetorno := aClone( aRetPe )
        EndIf
    EndIf

Return( aRetorno )


/** {Protheus.doc} OGX004VTAB
Valida se o usuario corrente no sistema obtido da variavel
__cUserID tem permissão para utilizar a tabela

@param: 	cTabela - Codigo da Tabela de Desconto

@return:	lRetorno - Verdadeiro ou Falso

@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA250 - Romaneio
*/
Function OGX004VTAB( cTabela )
Local lRetorno	:= .t.
Local aAreaAtu	:= GetArea()
Local aAreaDXX	:= DXX->( GetArea() )

Default cTabela	:= ""

If Empty( cTabela )
	Return( .f. )
EndIf

dbSelectArea( "DXX" )
dbSetOrder( 2 ) 
If .Not. dbSeek( FWxFilial( "DXX" ) + cTabela + __cUserID )
	Help(, , STR0001, , STR0002, 1, 0 ) //"Ajuda"###"Usuario sem permissao para uso desta tabela!"
	lRetorno := .f.
EndIf

RestArea( aAreaDXX )
RestArea( aAreaAtu )
Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} fExecForm
Validação da função
@author  rafael.voltz
@since   20/07/2018
@version version
/*/
//-------------------------------------------------------------------
Function fExecForm(cFormula)
	Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
	Local xTeste     := nil
	
	If !Empty(cFormula)
		Begin Sequence			
			xTeste := Eval({|| &cFormula})			
		Recover
			ErrorBlock(oLastError)						
		End Sequence
	EndIf	

	If ValType( xTeste) == "N"
		Return xTeste
	Else
		Alert(STR0003) //Houve um erro ao executar a fórmula do desconto.
	EndIf

Return 0
