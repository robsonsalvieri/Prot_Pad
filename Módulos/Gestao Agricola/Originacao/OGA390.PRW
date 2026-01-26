#INCLUDE "Protheus.ch"
#INCLUDE "OGA390.CH"
/** {Protheus.doc} OGA390V
Rotina para validação do uso do contrato nos campos referentes ao mesmo

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA390V( cCodigo, lPermiss )
Local lRetorno		:= .t.
Local aAreaAtu		:= GetArea()

If ValType( cCodigo ) == "U"
	cCodigo := &( ReadVar() )
EndIf

If ValType( lPermiss ) == "U" .Or. ValType( lPermiss ) <> "L" 
	lPermiss := .f.
EndIf

dbSelectArea( "NJR" )
dbSetOrder( 1 )
If dbSeek( xFilial( "NJR" ) + cCodigo )

	/** se o pre-contrato estiver previsto, e nao for permitido utiliza-lo */
	If NJR->( NJR_MODELO ) = "1" .And. NJR->( NJR_STATUS ) = "P" .And. .Not. lPermiss
		Help( , , "AJUDA", , "Nao é permitido o uso de -Pre-Contrato", 1, 0 )
		lRetorno := .f.
	EndIf

	/** se o contrato estiver previsto, finalizado ou encerrado nao permite utiliza-lo */
	If NJR->( NJR_MODELO ) = "2" .And. NJR->( NJR_STATUS ) $ "P|E|F"
		Help( , , "AJUDA", , "Status do contrato nao permite movimentacao.", 1, 0 )
		lRetorno := .f.
	EndIf

Else
	Help( , , "AJUDA", , "Contrato nao localizado na base de dados.", 1, 0 )
	lRetorno := .f.
EndIf

RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} OGA390B
Rotina para não permitir dois contratos com a mesma entidade e safra

@param: 	Filial, Entidade, Loja, Safra, Tipo Documento
@author:  Fabiane Schulze
@since: 	10/10/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA390B(cFilialNJR, cCodEnt, cLojEnt, cSafra, cProd, cTipo)
	Local aAreaAtu		:= GetArea()
	Local lRetorno	:= .T.
	Local cAliasNJR	:= GetNextAlias()
	Local lARMA300	:= SuperGetMV( "MV_ARMA300", .f., .f. )
	
	BeginSql Alias cAliasNJR
					
		Select Count(*) as Total
		From %table:NJR% NJR
			Where 
				NJR.NJR_FILIAL = %exp:cFilialNJR% And
		 		NJR.NJR_CODENT = %exp:cCodEnt% And
				NJR.NJR_LOJENT = %exp:cLojEnt% And
		 		NJR.NJR_CODSAF = %exp:cSafra% And
		      	NJR.NJR_CODPRO = %exp:cProd% And
				NJR.NJR_TIPO   = %exp:cTipo% And		 
				(NJR.NJR_STATUS = 'A' OR
				NJR.NJR_STATUS = 'I' ) And	 
				NJR.%NotDel%

	EndSql
	//GETLASTQUERY()[2]
	
	(cAliasNJR)->( dbGoTop() )
	if ((cAliasNJR)->(Total) > 0) .And. lARMA300
		AgrHelp(STR0001, STR0002, STR0003 ) //##Ajuda##J existe Contrato aberto para esta Entidade, Safra e Produto!##Sistema parametrizado(MV_ARMA300) para não permitir mais de um contrato aberto/iniciado para mesma entidade, safra e produto. Ajuste os dados para inclusão.
		lRetorno := .F.	
	EndIf
	
	(cAliasNJR)->( dbCloseArea() )
	
RestArea( aAreaAtu )	
Return( lRetorno )

