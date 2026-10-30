#include 'mdta007c.ch'
#include 'protheus.ch'
#include 'fwmvcdef.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} mdta007c
Tela reduzida da ficha médica, utilizada quando o registro
posicionado pertence a um dependente (TM0_NUMDEP preenchido).
Exibe somente os campos: TM0_NUMFIC, TM0_FILFUN, TM0_MAT, TM0_NOMFIC,
TM0_DTIMPL, TM0_NUMDEP, TM0_DTNASC, TM0_SEXO, TM0_CPF e o campo
virtual NOMEFUNC (nome do funcionário).

Acessada exclusivamente através do direcionamento feito por
Mdta007Cad(), a partir dos botões Visualizar/Alterar/Excluir da
rotina mdta007.

@author Elisson França
@since 28/07/2026

/*/
//---------------------------------------------------------------------
Function mdta007c()

	Local oBrowse := Nil

	If AMiIn( 35 ) // Somente autorizado para SIGAMDT

		oBrowse := FWMBrowse():New()

		oBrowse:SetAlias( 'TM0' )
		oBrowse:SetMenuDef( 'mdta007c' )
		oBrowse:SetDescription( STR0001 ) // "Ficha médica"

		oBrowse:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author Elisson França
@since 28/07/2026

@return array, menu da rotina
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002, 'ViewDef.mdta007c' , 0, 2, 0 } ) // "Visualizar"
	aAdd( aRotina, { STR0003, 'ViewDef.mdta007c' , 0, 4, 0 } ) // "Alterar"
	aAdd( aRotina, { STR0004, 'ViewDef.mdta007c' , 0, 5, 0 } ) // "Excluir"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Elisson França
@since 28/07/2026

@return objeto, modelo em MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStructTM0 := FWFormStruct( 1, 'TM0' )
	Local oModel     := MPFormModel():New( 'mdta007c', Nil, { | oModel | mdta007Val( oModel ) } )

	// Campo virtual (não gravado na TM0), usado para exibir o nome do funcionário, já que
	// TM0_NOMFIC passa a exibir o nome do dependente quando TM0_NUMDEP está preenchido.
	oStructTM0:AddField( '', '', 'NOMEFUNC', 'C', 40, 0, Nil, { || .F. }, {}, .F., { || '' }, .F., .T., .T. )
	oStructTM0:SetProperty( 'NOMEFUNC', MODEL_FIELD_INIT, { || Posicione( 'SRA', 1, TM0->TM0_FILFUN + TM0->TM0_MAT, 'RA_NOME' ) } )

	// TM0_MAT (matrícula do tutor) bloqueado nesta tela
	oStructTM0:SetProperty( 'TM0_MAT', MODEL_FIELD_WHEN, { || .F. } )

	// TM0_DTNASC não deve vir bloqueado nesta tela, mesmo com TM0_MAT preenchido
	// (o gatilho padrão mdta007X3W bloqueia esse campo quando a matrícula está preenchida)
	oStructTM0:SetProperty( 'TM0_DTNASC', MODEL_FIELD_WHEN, { || .T. } )

	// Mesmos gatilhos do MDTA007: ao alterar o dependente (TM0_NUMDEP), atualiza os
	// dados vindos do cadastro de dependentes (SRB)
	oStructTM0:AddTrigger( 'TM0_NUMDEP', 'TM0_NOMFIC', { || .T. }, { || SubStr( Posicione( 'SRB', 1, FwxFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_NOME' ), 1, FwTamSx3( 'TM0_NOMFIC' )[ 1 ] ) } )
	oStructTM0:AddTrigger( 'TM0_NUMDEP', 'TM0_DTNASC', { || .T. }, { || Posicione( 'SRB', 1, FwxFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_DTNASC' ) } )
	oStructTM0:AddTrigger( 'TM0_NUMDEP', 'TM0_SEXO'  , { || .T. }, { || fSexoDep() } )
	oStructTM0:AddTrigger( 'TM0_NUMDEP', 'TM0_CPF'   , { || .T. }, { || Posicione( 'SRB', 1, FwxFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_CIC' ) } )

	oModel:AddFields( 'TM0MASTER', Nil, oStructTM0 )
	oModel:SetDescription( STR0001 ) // "Ficha médica"
	oModel:GetModel( 'TM0MASTER' ):SetDescription( STR0001 ) // "Ficha médica"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} fSexoDep
Retorna o sexo do dependente convertido para o domínio da TM0 (1-Masculino,
2-Feminino), a partir do cadastro de dependentes (SRB).

@author Elisson França
@since 29/07/2026

@return caractere, retorna o valor do campo TM0_SEXO: '1' ou '2'
/*/
//-------------------------------------------------------------------
Static Function fSexoDep()

	Local cRet := '2'

	If Posicione( 'SRB', 1, FwxFilial( 'SRB' ) + M->TM0_MAT + M->TM0_NUMDEP, 'RB_SEXO' ) == 'M'
		cRet := '1'
	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da view

@author Elisson França
@since 28/07/2026

@return objeto, view em MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     := FWLoadModel( 'mdta007c' )
	Local oStructTM0 := FWFormStruct( 2, 'TM0' )
	Local oView      := FWFormView():New()

	// A ordem deste array define a ordem de exibição em tela: primeiro os campos do
	// tutor (funcionário), depois os campos do dependente
	Local aCposDep := { 'TM0_NUMFIC', 'TM0_FILFUN', 'TM0_MAT', 'NOMEFUNC', 'TM0_DTIMPL',;
	                    'TM0_NUMDEP', 'TM0_NOMFIC', 'TM0_DTNASC', 'TM0_SEXO', 'TM0_CPF' }
	Local aFields  := {}
	Local nPos     := 0
	Local nI       := 0

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_TM0', oStructTM0, 'TM0MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_TM0', 'TELA' )

	// Campo virtual, somente leitura, com o nome do funcionário
	oStructTM0:AddField( 'NOMEFUNC', '999', STR0005, STR0005, { STR0005 }, 'C', , Nil, Nil, .T. )

	// Exibe somente os campos essenciais da ficha médica do dependente
	fSoCposVw( oStructTM0, { 'TM0_NUMFIC', 'TM0_FILFUN', 'TM0_MAT', 'TM0_NOMFIC', 'TM0_DTIMPL', 'TM0_NUMDEP', 'TM0_DTNASC', 'TM0_SEXO', 'TM0_CPF', 'NOMEFUNC' } )

	// Títulos específicos desta tela
	oStructTM0:SetProperty( 'TM0_NUMFIC', MVC_VIEW_TITULO, STR0006 ) // "Ficha médica - Tutor"
	oStructTM0:SetProperty( 'TM0_MAT'   , MVC_VIEW_TITULO, STR0007 ) // "Matrícula - Tutor"
	oStructTM0:SetProperty( 'TM0_NOMFIC', MVC_VIEW_TITULO, STR0008 ) // "Nome do dependente"

	// Coloca todos os campos na pasta 1 (aba "Ficha") e reordena a exibição conforme
	// aCposDep (tutor primeiro, dependente logo abaixo).
	aFields := oStructTM0:GetFields()
	For nI := 1 To Len( aCposDep )
		nPos := AScan( aFields, { | x | AllTrim( x[ 1 ] ) == aCposDep[ nI ] } )
		If nPos > 0
			aFields[ nPos, 11 ] := '1'
			aFields[ nPos, 2 ]  := StrZero( nI, 2 )
		EndIf
	Next nI

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} fSoCposVw
Remove da tela todos os campos da estrutura informada, exceto os
campos relacionados no array aCampos.

@author Elisson França
@since 28/07/2026

@param, oStruct, objeto, estrutura da view (FWFormStruct)
@param, aCampos, array, nomes dos campos que devem permanecer na tela
/*/
//-------------------------------------------------------------------
Static Function fSoCposVw( oStruct, aCampos )

	Local aFields := AClone( oStruct:GetFields() )
	Local cNome   := ''
	Local nX      := 0

	For nX := 1 To Len( aFields )
		cNome := AllTrim( aFields[ nX, 1 ] )
		If AScan( aCampos, cNome ) == 0
			oStruct:RemoveField( cNome )
		EndIf
	Next nX

Return
