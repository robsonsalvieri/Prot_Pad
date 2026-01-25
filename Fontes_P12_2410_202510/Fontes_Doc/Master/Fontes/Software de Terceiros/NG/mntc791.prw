#include "mntc790.ch" 
#include "PROTHEUS.CH"
#include 'FWMVCDEF.ch'

Static aFields := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTC791
Consulta de Ordens de Serviço
@type function

@author Alexandre Santos
@since  30/11/2023

@param 
@return
/*/
//-------------------------------------------------------------------
Function MNTC791()

	Local aAreaSTJ    := STJ->( FWGetArea() )
	Local aCores      := {}
	Local aFldFilt    := {}
	Local aIndTemp    := {}
	Local cFuncBkp    := FunName()

	Private aRotina   := MenuDef()
	Private cAls790   := GetNextAlias()
	Private cCadastro := OemtoAnsi( STR0001 ) // Ordem de Servico
	Private oTemp790

	SetFunName( 'MNTC791' )

	If ExistBlock( 'MNTC7902' )

		aCores := ExecBlock( 'MNTC7902', .F., .F. )

	EndIf

    If Pergunte( 'MNC790', .T. )

        /*----------------------------------------+
        | Cria estrutura da na tabela temporária. |
        +----------------------------------------*/
        If Empty( aFields )
        
            fLoadFlds()
        
        EndIf

        /*----------------------------------------+
        | Cria estrutura da na tabela temporária. |
        +----------------------------------------*/
        fCriaTemp( @aFldFilt, @aIndTemp )

        /*-------------------------------------------+
        | Faz a carga de dados na tabela temporária. |
        +-------------------------------------------*/
        fLoadTemp()

        /*-------------------------------------------------+
        | Cria browse conforme dados da tabela temporária. |
        +-------------------------------------------------*/
        fCriaBrow( aCores, aFldFilt, aIndTemp )

        /*-------------------------+
        | Deleta objeto do browse. |
        +-------------------------*/
        oTemp790:Delete()

    EndIf
	
	SetFunName( cFuncBkp )

	FWRestArea( aAreaSTJ )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC791Per
Apresenta o pergunte MNC790 e faz o reload da consulta.
@type function

@author Alexandre Santos
@since 30/11/2023

@param
@return
/*/
//---------------------------------------------------------------------
Function MNTC791Per()

	If Pergunte( 'MNC790', .T. )
	
		dbSelectArea( cAls790 )
		Zap

		/*-------------------------------------------+
		| Faz a carga de dados na tabela temporária. |
		+-------------------------------------------*/
		fLoadTemp()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTC791Men
Chama rotinas do menu relacional.
@type function

@author Alexandre Santos
@since 30/11/2023

@param cOption, string, Indica a rotina que deve ser chamada.
@return
/*/
//---------------------------------------------------------------------
Function MNTC791Men( cOption )

	dbSelectArea( 'STJ' )
	msGoTo( (cAls790)->RECSTJ )

	Do Case

		Case cOption == '01'

			MNTC600C()

		Case cOption == '02'

			MNTC600D()

		Case cOption == '03'

			MNTC550A()

		Case cOption == '04'

			MNTC040A()

		Case cOption == '05'

			MNTC550B()

		Case cOption == '06'

			If SuperGetMV( 'MV_NGMNTES', .F., 'N' ) == 'S'

				MNTC290( STJ->TJ_ORDEM )

			EndIf
		
		Case cOption == '07'

			NGCAD01( 'STJ', RecNo(), 2 )

	End Case
    
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina
@type function

@author Alexandre Santos
@since 30/11/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0011 ACTION "MNTC791Per()"       OPERATION 3 ACCESS 0 // Nova Consulta
	ADD OPTION aRotina TITLE STR0003 ACTION "MNTC791Men( '07' )" OPERATION 2 ACCESS 0 // Visual.
	ADD OPTION aRotina TITLE STR0004 ACTION "MNTC791Men( '01' )" OPERATION 6 ACCESS 0 // Detalhes
    ADD OPTION aRotina TITLE STR0005 ACTION "MNTC791Men( '02' )" OPERATION 6 ACCESS 0 // Ocorren.
	ADD OPTION aRotina TITLE STR0006 ACTION "MNTC791Men( '03' )" OPERATION 6 ACCESS 0 // Problemas
    ADD OPTION aRotina TITLE STR0007 ACTION "MNTC791Men( '04' )" OPERATION 6 ACCESS 0 // Motivo Atraso
	ADD OPTION aRotina TITLE STR0008 ACTION "MNTC791Men( '05' )" OPERATION 6 ACCESS 0 // Etapas
	ADD OPTION aRotina TITLE STR0010 ACTION "MNT791DOC()"        OPERATION 6 ACCESS 0 // Conhecimento
	ADD OPTION aRotina TITLE STR0009 ACTION "MNTC791Men( '06' )" OPERATION 6 ACCESS 0 // Sol. Compra

	If ExistBlock( 'MNTC7901' )
		
		aRotina := ExecBlock( 'MNTC7901', .F., .F., { aRotina } )
	
	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadFlds
Cria a estrutura da tabela temporária.
@type function

@author Alexandre Santos
@since 30/11/2023

@param 
@return
/*/
//---------------------------------------------------------------------
Static Function fLoadFlds()

	Local nInd1   := 0
	Local aHdSTJ  := NGHeader( 'STJ', , .F. )
	Local aFldDef := { 'TJ_ORDEM', 'TJ_PLANO' }
	
	If FWModeAccess( 'STJ', 3 ) == 'E'

		aAdd( aFields, { 'TJ_FILIAL', FWX3Titulo( 'TJ_FILIAL' ), 'C', FWSizeFilial(), '@!' } )

	EndIf

	For nInd1 := 1 To Len( aHdSTJ )

		cCampo  := AllTrim( aHdSTJ[nInd1,2] )

		If Posicione( 'SX3', 2, cCampo, 'X3_BROWSE' ) == 'S' .Or. ( aScan( aFldDef, { | x | x == cCampo } ) > 0 )

			// Tratativa para o campo Memo
			If cCampo == 'TJ_OBSERVA'

				aAdd( aFields, { cCampo, aHdSTJ[nInd1,1], 'C', 200, aHdSTJ[nInd1,3] } )
			
			Else

				aAdd( aFields, { cCampo, aHdSTJ[nInd1,1], aHdSTJ[nInd1,8], aHdSTJ[nInd1,4], aHdSTJ[nInd1,3] } )
				
			EndIf

		EndIf

	Next nInd1
    
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaTemp
Cria a estrutura da tabela temporária.
@type function

@author Alexandre Santos
@since 30/11/2023

@param aFldFilt, array, Lista com os campos disponíveis para o filtro.
@param aIndTemp, array, Lista com os indices da tabela.
@return
/*/
//---------------------------------------------------------------------
Static Function fCriaTemp( aFldFilt, aIndTemp )

	Local aFldTemp := {}
	Local nInd1    := 0

	For nInd1 := 1 To Len( aFields )

		aAdd( aFldTemp, { aFields[nInd1,1], aFields[nInd1,3], aFields[nInd1,4], 0 } )

		aAdd( aFldFilt, { aFields[nInd1,1], aFields[nInd1,2], aFields[nInd1,3], aFields[nInd1,4], 0, '' } )

	Next nIndex

	aAdd( aFldTemp, { 'RECSTJ'    , 'N', 18, 00 } )

	oTemp790 := FWTemporaryTable():New( cAls790, aFldTemp )

	/*----------------------------------------+
	| Inclui os indices na tabela temporária. |
	+----------------------------------------*/
	fAddIndex( aFldTemp, @aIndTemp )

	oTemp790:Create()
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAddIndex
Adiciona indices ao objeto da tabela temporária.
@type   function

@author Alexandre Santos
@since  30/04/2024

@param aFields , array, Lista com os campos disponíveis no browse.
@param aIndTemp, array, Lista com os indices do Browse

@return
/*/
//---------------------------------------------------------------------
Static Function fAddIndex( aFields, aIndTemp )

	Local aIndAux := {}
	Local aValInd := {}
	Local aIndSTJ := fMontInd( 'STJ' )
	Local aIndSIX := FWSIXUtil():GetAliasIndexes( 'STJ' )
	Local nInd1   := 0

	/*-----------------------------------------------------+
	| Valida todos os indices disponiveis para tabela STJ. |
	+-----------------------------------------------------*/
	For nInd1 := 1 To Len( aIndSIX )

		If !Empty( aIndAux := fIndTRB( aFields, aIndSIX[nInd1] ) )

			/*-------------------------------------------------------------------+
			| Realiza a validação dos indices antes de inclui-los na temporária. |
			+-------------------------------------------------------------------*/
			fValInd( aIndAux, @aValInd )

		EndIf

	Next nInd1

	/*--------------------------------------------------+
	| Inclui os indices validados na tabela temporária. |
	+--------------------------------------------------*/
	For nInd1 := 1 To Len( aValInd )

		If !Empty( aValInd[nInd1] )

			oTemp790:AddIndex( cValToChar( nInd1 ), aClone( aValInd[nInd1] ) )

			aAdd( aIndTemp, { aIndSTJ[nInd1], { { '', 'C', 255, 0, '', '@!' } }, 2 } )

		EndIf

	Next nInd1

	FWFreeArray( aIndAux )
	FWFreeArray( aValInd )
	FWFreeArray( aIndSIX )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fIndTRB
Cria indices para o browse
@type Function

@author Alexandre Santos
@since  30/04/2025

@param  aFields, array, Lista com os campos utilizados no TRB.
@param  aIndSTJ, array, Lista com os indices da tabela STJ.

@return array  , Retorna lista de indices para adição no TRB.
/*/
//-------------------------------------------------------------------
Static Function fIndTRB( aFields, aIndSTJ )

	Local aIndTRB := {}
	Local cField  := ''
	Local nInd1   := 0

	For nInd1 := 1 To Len( aIndSTJ )

		If 'DTOS' $ Upper( aIndSTJ[nInd1] )

			cField := StrTran( SubStr( aIndSTJ[nInd1], 6, Len( aIndSTJ[nInd1] ) ), ')', '' )

		Else

			cField := aIndSTJ[nInd1]

		EndIf

		If ( nPosFld := aScan( aFields, { | x | x[ 1 ] == cField } ) ) > 0

			aAdd( aIndTRB, cField )

		EndIf

	Next nInd1

Return aIndTRB

//-------------------------------------------------------------------
/*/{Protheus.doc} fValInd
Realiza validação do indice a ser adicionado
@type Function

@author Alexandre Santos
@since  30/05/2025

@param aIndAdd, array, Indice que será adicionado ao TRB.
@param aIndOld, array, Lista com os indices já adicionados no TRB.

@return 
/*/
//-------------------------------------------------------------------
Static Function fValInd( aIndAdd, aIndOld )

	Local nInd     := 0
	Local nInd2    := 0
	Local lReturn  := .T.
	Local nSizInd1 := Len( aIndAdd ) // Tamanho do novo indice

	/*------------------------------------------------------------+
	| Percorre todos os índices já inclusos no array de controle. |
	+------------------------------------------------------------*/
	For nInd := 1 To Len( aIndOld )

		nSizInd2 := Len( aIndOld[ nInd ] ) // Tamanho do indice atual

		If nSizInd2 == 0

			Loop

		EndIf

		lReturn := .F.

		/*----------------------------------------------------------------------------------+
		| Percorre todos os campos do índice posiciona que já incluso no array de controle. |
		+----------------------------------------------------------------------------------*/
		For nInd2 := 1 To nSizInd2

			/*-------------------------------------------------------------------------------+
			| Se o tamanho do indice incluso é menor que o índice posiciona, encerra o loop. |
			+-------------------------------------------------------------------------------*/
			If nInd2 > nSizInd1

				Exit

			EndIf

			/*--------------------------------------------------------------------------------------------+
			| Se existirem campos diferentes entre o indice incluso e o índice posiciona, encerra o loop. |
			+--------------------------------------------------------------------------------------------*/
			If aIndOld[ nInd, nInd2 ] != aIndAdd[ nInd2 ]

				lReturn := .T.

				Exit

			EndIf

		Next nInd2

		If !lReturn

			/*-----------------------------------------------------------------------------------------------+
			| Se o indice incluso sobrepõe um indice no array de controle, sobrescreve o array de controle. |
			+-----------------------------------------------------------------------------------------------*/
			If nSizInd1 > nSizInd2

				/*----------------------------------------------------------+
				| Zera o índice na posição sobreposta do array de controle. |
				+----------------------------------------------------------*/
				aIndOld[nInd] := {}

				lReturn := .T.

			EndIf

			Exit

		EndIf

	Next nInd

	If lReturn

		/*----------------------------------------+
		| Adiciona o índice no array de controle. |
		+----------------------------------------*/
		aAdd( aIndOld, aIndAdd )

	Else

		/*-----------------------------------------------------------------------------------------------+
		| Adiciona o posição vazia no array de controle. Para manter a ordem dos indices dentro do array |
		+-----------------------------------------------------------------------------------------------*/
		aAdd( aIndOld, {} )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fMontInd
Monta array com o titulo dos indices.
@type function

@author Alexandre Santos
@since 30/04/2024

@param cAlsInd, string, Tabela que será carregado os indices.
@return array , Lista com a descrição dos indices.
/*/
//---------------------------------------------------------------------
Static Function fMontInd( cAlsInd )

	Local aRet := { }

	dbSelectArea( 'SIX' )
	dbSetOrder( 1 )
	msSeek( cAlsInd )

	While SIX->( !EoF() ) .And. SIX->INDICE == cAlsInd

		aAdd( aRet, AllTrim( SIX->DESCRICAO ) )
		
		SIX->( dbSkip() )

	End

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadTemp
Carga inicial da tabela temporária.
@type function

@author Alexandre Santos
@since 30/11/2023

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fLoadTemp()

	Local aVrtFlds   := {}
	Local cQryTmpSTJ := ''
	Local cAlsTmpSTJ := GetNextAlias()
	Local cFldTemp   := ''
	Local cCast      := ''
	Local cBanco     := Upper( TCGetDB() )
	Local cIsNull    := ''
	Local nInd1      := 0
	Local nPosFld    := 0

	Inclui := .F.

	If cBanco == 'ORACLE'
		cIsNull := 'NVL'
	ElseIf cBanco == 'POSTGRES'
		cIsNull := 'COALESCE'
	Else
		cIsNull := 'ISNULL'
	EndIf

	cQryTmpSTJ += "SELECT "
	cQryTmpSTJ +=	   'CASE '
	cQryTmpSTJ +=	   		"WHEN STJ.TJ_TIPOOS = 'B' "
	cQryTmpSTJ +=			'THEN ST9.T9_NOME '
	cQryTmpSTJ +=	   		"WHEN STJ.TJ_TIPOOS = 'L' "
	cQryTmpSTJ +=			'THEN TAF.TAF_NOMNIV '
	cQryTmpSTJ +=		'END AS T9_NOME, '
	cQryTmpSTJ +=      "ST4.T4_NOME   , "
	cQryTmpSTJ +=      "STJ.TJ_FILIAL , "
	cQryTmpSTJ += 	   "STJ.TJ_DTPRINI, "
	cQryTmpSTJ +=      "STJ.R_E_C_N_O_  "

	For nInd1 := 1 To Len( aFields )

		If !( aFields[nInd1,1] == 'RECSTJ' )

			If Posicione( 'SX3', 2, aFields[nInd1,1], 'X3_CONTEXT' ) == 'V'

				// Monta estrutura de inicialização padrão dos campos apresentados em tela
				If ExistIni( aFields[nInd1,1] )

					aAdd( aVrtFlds, { aFields[nInd1,1], Posicione( 'SX3', 2, aFields[nInd1,1], 'X3_RELACAO' ) } )

				Else

					aAdd( aVrtFlds, { aFields[nInd1,1], Space( FWTamSX3( aFields[nInd1,1] )[ 1 ] ) } )

				EndIf

			Else

				cFldTemp +=  ', STJ.' + aFields[nInd1,1]

			EndIf
		
		EndIf

	Next nInd1

	cCast := ", STJ.TJ_OBSERVA " // INFORMIX

	Do Case

		Case cBanco == 'ORACLE'

			cCast := ", UTL_RAW.CAST_TO_VARCHAR2( dbms_lob.substr( STJ.TJ_OBSERVA, 2000, 1 ) ) AS TJ_OBSERVA "

		Case cBanco == 'POSTGRES'

			cCast := ", COALESCE( CAST( ENCODE( STJ.TJ_OBSERVA, 'ESCAPE' ) AS VARCHAR( 8000 ) ), '' ) AS TJ_OBSERVA "

		Case 'MSSQL' $ cBanco

			cCast := ", ISNULL( CAST( CAST( STJ.TJ_OBSERVA AS VARBINARY( 8000 ) ) AS VARCHAR( 8000 ) ),'') AS TJ_OBSERVA "

	End Case

	cQryTmpSTJ +=      cFldTemp + cCast
	cQryTmpSTJ += "FROM "
	cQryTmpSTJ +=    RetSQLName( 'STJ' ) + " STJ "
	cQryTmpSTJ += "INNER JOIN "
	cQryTmpSTJ +=    RetSQLName( 'ST4' ) + " ST4 ON "
	cQryTmpSTJ +=        NGModComp( 'ST4', 'STJ' ) + ' '
	cQryTmpSTJ +=        "AND ST4.T4_SERVICO = STJ.TJ_SERVICO "
	cQryTmpSTJ +=        "AND ST4.D_E_L_E_T_ = ' ' "
	cQryTmpSTJ += "LEFT JOIN "
	cQryTmpSTJ +=    RetSQLName( 'ST9' ) + " ST9 ON "
	cQryTmpSTJ +=        NGModComp( 'ST9', 'STJ' ) + ' '
	cQryTmpSTJ +=        "AND ST9.T9_CODBEM  = STJ.TJ_CODBEM "
	cQryTmpSTJ +=        "AND ST9.T9_CODFAMI BETWEEN " + ValToSQL( MV_PAR05 ) + " AND " + ValToSQL( MV_PAR06 ) + " "
	cQryTmpSTJ +=        "AND ST9.T9_TIPMOD  BETWEEN " + ValToSQL( MV_PAR07 ) + " AND " + ValToSQL( MV_PAR08 ) + " "
	cQryTmpSTJ +=        "AND ST9.D_E_L_E_T_ = ' ' "
	cQryTmpSTJ += "LEFT JOIN "
	cQryTmpSTJ +=    RetSQLName( 'TAF' ) + " TAF ON "
	cQryTmpSTJ +=    	NGModComp( 'TAF', 'STJ' ) + ' '
	cQryTmpSTJ +=   	'AND TAF.TAF_CODNIV = STJ.TJ_CODBEM '
    cQryTmpSTJ +=   	"AND TAF.D_E_L_E_T_ = ' ' "
	cQryTmpSTJ += " WHERE "
	cQryTmpSTJ +=    "STJ.TJ_FILIAL   BETWEEN " + ValToSQL( MV_PAR01 ) + " AND " + ValToSQL( MV_PAR02 ) + " AND "
	cQryTmpSTJ +=    "STJ.TJ_ORDEM    BETWEEN " + ValToSQL( MV_PAR13 ) + " AND " + ValToSQL( MV_PAR14 ) + " AND "
	cQryTmpSTJ +=    "STJ.TJ_SERVICO  BETWEEN " + ValToSQL( MV_PAR15 ) + " AND " + ValToSQL( MV_PAR16 ) + " AND "
	cQryTmpSTJ +=    "STJ.TJ_CODBEM   BETWEEN " + ValToSQL( MV_PAR03 ) + " AND " + ValToSQL( MV_PAR04 ) + " AND "
	cQryTmpSTJ +=    "STJ.TJ_DTMPINI  BETWEEN " + ValToSQL( MV_PAR17 ) + " AND " + ValToSQL( MV_PAR18 ) + " AND "
	cQryTmpSTJ +=    "STJ.TJ_CCUSTO   BETWEEN " + ValToSQL( MV_PAR09 ) + " AND " + ValToSQL( MV_PAR10 ) + " AND "
	cQryTmpSTJ +=    "STJ.TJ_CENTRAB  BETWEEN " + ValToSQL( MV_PAR11 ) + " AND " + ValToSQL( MV_PAR12 ) + " AND "

	If MV_PAR19 == 4

		cQryTmpSTJ += " STJ.TJ_TERMINO = 'S' AND "

	ElseIf MV_PAR19 != 5

		cQryTmpSTJ += " STJ.TJ_TERMINO = 'N' AND "

		Do Case

			Case MV_PAR19 == 1

				cQryTmpSTJ += " STJ.TJ_SITUACA IN ( 'P', 'L' ) AND "

			Case MV_PAR19 == 2

				cQryTmpSTJ += " STJ.TJ_SITUACA = 'P' AND "

			Case MV_PAR19 == 3

				cQryTmpSTJ += " STJ.TJ_SITUACA = 'C' AND "

		End Case

	EndIf

	cQryTmpSTJ += "STJ.D_E_L_E_T_ = ' ' "
	
	dbUseArea( .T., 'TOPCONN', TcGenQry( , , ChangeQuery( cQryTmpSTJ ) ), cAlsTmpSTJ, .F., .T. )

	While (cAlsTmpSTJ)->( !EoF() )

		STJ->( dbGoTo( (cAlsTmpSTJ)->R_E_C_N_O_ ) )

		RecLock( cAls790, .T. )

			// Adiciona na query os campos que serão apresentados em tela
			For nInd1 := 1 To Len( aFields )

				If aFields[nInd1,1] == 'TJ_NOMBEM'

					(cAls790)->TJ_NOMBEM := (cAlsTmpSTJ)->T9_NOME

				ElseIf aFields[nInd1,1] == 'TJ_NOMSERV'

					(cAls790)->TJ_NOMSERV := (cAlsTmpSTJ)->T4_NOME

				ElseIf ( nPosFld := aScan( aVrtFlds, { | x | x[1] == aFields[nInd1,1] } ) ) == 0

					If aFields[nInd1,3] == 'D'

						&( cAls790 + '->' + aFields[nInd1,1] ) := SToD( &( cAlsTmpSTJ + '->' + aFields[nInd1,1] ) )

					Else

						&( cAls790 + '->' + aFields[nInd1,1] ) := &( cAlsTmpSTJ + '->' + aFields[nInd1,1] )

					EndIf

				Else

					&( cAls790 + '->' + aFields [nInd1,1] ) := &( aVrtFlds[nPosFld,2] )

				EndIf

			Next nInd1

			(cAls790)->RECSTJ     := (cAlsTmpSTJ)->R_E_C_N_O_

		(cAls790)->( MsUnlock() )

		(cAlsTmpSTJ)->( dbSkip() )

	End

	(cAlsTmpSTJ)->( dbCloseArea() )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaBrow
Cria o browse principal da consulta.
@type function

@author Alexandre Santos
@since 30/11/2023

@param  aLegend, array, Legenda utilizada no browse principal.
@return
/*/
//---------------------------------------------------------------------
Static Function fCriaBrow( aLegend, aFiltBrw, aIndTemp )
	
	Local aFldBrow := {}
	Local nInd1    := 0

	For nInd1 := 1 To Len( aFields )

		aAdd( aFldBrow, fCreateCol( '{ | | (cAls790)->' + aFields[nInd1,1] + ' }', aFields[nInd1] ) )

	Next nInd1

	oBrw790:= FWMBrowse():New()
	oBrw790:SetDescription( STR0001 ) // Consulta de Manutenções Multíplas
	oBrw790:SetTemporary( .T. )
	oBrw790:SetAlias( cAls790 )
	oBrw790:SetColumns( aFldBrow )
	oBrw790:SetFieldFilter( aFiltBrw )
	oBrw790:SetMenuDef( 'MNTC791' )
	oBrw790:SetSeek( .T., aIndTemp )

	For nInd1 := 1 To Len( aLegend )
		
		oBrw790:AddLegend( aLegend[nInd1,1], aLegend[nInd1,2] )

	Next nInd1

	oBrw790:Activate()

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} fCreateCol
Criação das Colunas do Browse.
@type function

@author Alexandre Santos
@since 30/04/2025

@param  cDadosCol, string, Valor que será apresentado no campo.
@param	aFieldSTJ, array , Estrutura do campo
							[ 1 ] - Campo
							[ 2 ] - Titulo
							[ 3 ] - Tipo
							[ 4 ] - Tamanho
							[ 5 ] - Picture

@return object   , Objeto da FWBrwColumn
/*/
//---------------------------------------------------------------------
Static Function fCreateCol( cDadosCol, aFieldSTJ )

	Local oColumn := FWBrwColumn():New()

	oColumn:SetData( &( cDadosCol ) ) 
	oColumn:SetEdit( .F. )	      	  
	oColumn:SetTitle( aFieldSTJ[2] )  
	oColumn:SetType( aFieldSTJ[3] )   
	oColumn:SetSize( aFieldSTJ[4] )	  
	oColumn:SetPicture( aFieldSTJ[5] )
	oColumn:SetReadVar( aFieldSTJ[1] )

Return oColumn

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT791DOC
Funcao responsável por carregar o banco de conhecimento

@author  João Ricardo Santini Zandoná
@since   28/03/2025
@return  Nil
/*/
//-------------------------------------------------------------------
Function MNT791DOC()

	Local aArea := GetArea()

    dbSelectArea( 'STJ' )
    dbSetOrder( 1 ) // TJ_FILIAL + TJ_ORDEM + TJ_PLANO + TJ_TIPOOS + TJ_CODBEM + TJ_SERVICO + TJ_SEQRELA
    msSeek( FWxFilial( 'STJ' ) + (cAls790)->TJ_ORDEM + (cAls790)->TJ_PLANO )

	MsDocument( 'STJ', STJ->( Recno() ), 2 )

	RestArea( aArea )

Return Nil
