#Include 'protheus.ch'
#Include 'fwmvcdef.ch'
#Include 'mdta120b.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA120B
Classe interna implementando o FWModelEvent

@author Gabriel Sokacheski
@since 18/06/2024

/*/
//-------------------------------------------------------------------
Class MDTA120B From FWModelEvent

	Method ModelPosVld()
	Method BeforeTTS()
    Method New() Constructor

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA120B
Construtor da classe

@author Gabriel Sokacheski
@since 18/06/2024

/*/
//-------------------------------------------------------------------
Method New() Class MDTA120B
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método para validar o envio do evento S-2221 ao eSocial

@author Gabriel Sokacheski
@since 18/06/2024

/*/
//-------------------------------------------------------------------
Method ModelPosVld( oModel ) Class MDTA120B

	Local aAreaTM5	:= TM5->( GetArea() )
	Local aRetifica	:= {}

	Local lRet		:= .T.

	Local nOperacao := oModel:GetOperation()

	If FindFunction( 'MDTIntEsoc' ) .And. Mdta120Tox()

		If nOperacao != 4 .Or. ( aRetifica := fRetifica( oModel ) )[ 1 ]

			lRet := MDTIntEsoc(;
				'S-2221', nOperacao, oModel:GetValue( 'TM5MASTER', 'TM5_NUMFIC' ), Nil,;
				.F., Nil, Nil, Nil, Nil, oModel;
			)

		Else

			lRet := aRetifica[ 2 ] // Caso não tenha gerado evento, verifica se deve impedir cadastro

		EndIf

	EndIf

	RestArea( aAreaTM5 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
Método para enviar o evento S-2221 ao eSocial

@author Gabriel Sokacheski
@since 18/06/2024

/*/
//-------------------------------------------------------------------
Method BeforeTTS( oModel ) Class MDTA120B

	Local aAreaTM5	:= TM5->( GetArea() )

	Local nOperacao := oModel:GetOperation()

	If FindFunction( 'MDTIntEsoc' ) .And. Mdta120Tox()
		If nOperacao != 4 .Or. fRetifica( oModel )[ 1 ]
			MDTIntEsoc(;
				'S-2221', nOperacao, oModel:GetValue( 'TM5MASTER', 'TM5_NUMFIC' ), Nil,;
				.T., Nil, Nil, Nil, Nil, oModel;
			)
		EndIf
	EndIf

	RestArea( aAreaTM5 )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Mdta120Tox
Valida se o registro deve gerar o evento toxicológico S-2221

@author Gabriel Sokacheski
@since 18/06/2024

@return lRetorno, indica se deve gerar o evento
/*/
//---------------------------------------------------------------------
Function Mdta120Tox()

	Local cMatricula 	:= Posicione( 'TM0', 1, FwxFilial( 'TM0' ) + M->TM5_NUMFIC, 'TM0_MAT' )

	Local dResultado	:= M->TM5_DTRESU

	Local lRetorno		:= .T.

	Do Case
		Case Empty( M->TM5_CODDET )
			lRetorno := .F.
		Case Empty( dResultado )
			lRetorno := .F.
		Case dResultado < CtoD( '01/08/2024' ) .Or. dResultado > dDataBase
			lRetorno := .F.
		Case SubStr( Posicione( 'SRA', 1, FwxFilial( 'SRA' ) + cMatricula, 'RA_CATEFD' ), 1, 1 ) != '1'
			lRetorno := .F.
	EndCase

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fRetifica
Valida se deve retificar evento

@author Gabriel Sokacheski
@since 19/06/2024

@param oModel, modelo da rotina

@return lRet, indica se deve retificar o evento
/*/
//---------------------------------------------------------------------
Static Function fRetifica( oModel )

	Local lRetRot	:= .T. // Caso falso impede cadastro da rotina
	Local lRetEve	:= .F. // Caso falso não gera evento S-2221

	If !Empty( TM5->TM5_DTRESU ) .And. M->TM5_DTRESU != TM5->TM5_DTRESU

		lRetRot := .F.

		//----------------------------------------------------------------------------------------------------------------
		// Mensagens:
		// "Atenção"
		// "Não será possível alterar a data do resultado pois este campo está sendo utilizado como chave deste registro"
		// "Caso necessário o registro deve ser deletado e incluído novamente"
		//----------------------------------------------------------------------------------------------------------------
		Help( Nil, Nil, STR0001, Nil, STR0002 + '.', 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0003 + '.' } )

	ElseIf M->TM5_CODDET != TM5->TM5_CODDET .Or. M->TM5_USUARI != TM5->TM5_USUARI;
	.Or. M->TM5_FORNEC != TM5->TM5_FORNEC .Or. M->TM5_DTRESU != TM5->TM5_DTRESU

		lRetEve := .T.

	EndIf

Return { lRetEve, lRetRot }
