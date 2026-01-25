#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TAFA422.CH"

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13
#DEFINE ANALITICO_MOTIVO_DESLIGAMENTO	14
#DEFINE ANALITICO_RECIBO				15
#DEFINE ANALITICO_VALOR_DEP				16
#DEFINE ANALITICO_PERIODO_REFERENCIA	17
#DEFINE ANALITICO_PGTO_DEMONSTRATIVO	18
#DEFINE ANALITICO_PGTO_DATA				19
#DEFINE ANALITICO_PGTO_EVENTO			20
#DEFINE ANALITICO_PGTO_CRMEN			21

Static __lGrvRPT   := Nil
Static lLaySimplif := Nil
Static lSimpl12    := Nil
Static lSimpl0103  := Nil
Static lVersao12   := GetVersao(.F.) >= '12'
Static oReport     := Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFA422

Imposto de Renda Retido na Fonte - Evento S-5002

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA422()

	Local oDialog		as Object
	Local oLayer		as Object
	Local oPanel01		as Object
	Local oPanel02		as Object
	Local oBtFil		as Object
	Local nTop			as Numeric
	Local nHeight		as Numeric
	Local nWidth		as Numeric
	Local aSize			as Array
	Local lFreeze		as Logical
	Local bFiltro		as CodeBlock
	Local bExcReg		as CodeBlock
	Local bGerXml		as CodeBlock
	Local bXmlLote		as CodeBlock
	Local bClose		as CodeBlock

	Private oBrw := FwMBrowse():New()

	oDialog  := Nil
	oLayer   := Nil
	oPanel01 := Nil
	oPanel02 := Nil
	oBtFil   := Nil
	nTop     := 0
	nHeight  := 0
	nWidth   := 0
	aSize    := FWGetDialogSize()
	lFreeze  := .T.
	bFiltro  := {|| FilCpfNome(oBrw, "T2G", "S-5002", 1, 'T2G_PERAPU' )}
	bExcReg  := {|| TAFVExcEsocial( 'T2G' )                                              , oBrw:Refresh(.T.)}
	bGerXml  := {|| TAF422Xml()                                                          , oBrw:Refresh(.T.)}
	bXmlLote := {|| TAFXmlLote( 'T2G' , 'S-5002' , 'evtIrrfBenef' , 'TAF422Xml' , ,oBrw ), oBrw:Refresh(.T.)}
	bClose   := {|| oDialog:End() }
	oBrw     := FwMBrowse():New()
	
	If TAFAtualizado( .T. ,'TAFA422')

		If FindFunction("FilCpfNome") .And. GetSx3Cache("T2G_CPFV","X3_CONTEXT") == "V"

			/*----------------------------
			Construção do Painel Principal
			----------------------------*/

			oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Cadastro de Imposto de Renda Retido na Fonte",,,,,,,,, .T.,,,, .F. )

			oLayer := FWLayer():New()

			oLayer:Init( oDialog, .F. )

			oLayer:AddLine( "LINE01", 100 )

			oLayer:AddCollumn( "BOX01",88,, "LINE01" )
			oLayer:AddCollumn( "BOX02",12,, "LINE01" )

			oLayer:AddWindow( "BOX01", "PANEL01", "Cadastro de Imposto de Renda Retido na Fonte", 100, .F.,,, "LINE01" )
			oLayer:AddWindow( "BOX02", "PANEL02", "Outras Ações"            , 100, .F.,,, "LINE01" )

			oPanel01 := oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" )
			oPanel02 := oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE01" )

			/*----------------------------------------------------------------
			Construção do Painel 01 - Browse do Cadastro De Imposto de Renda Retido na Fonte
			----------------------------------------------------------------*/

			// Função que indica se o ambiente é válido para o eSocial 2.4
			If TafAtualizado()
				
				oBrw:SetDescription(STR0019) //"Imposto de Renda Retido na Fonte"
				oBrw:SetAlias("T2G")
				oBrw:SetMenuDef("TAFA422")
				oBrw:SetOwner( oPanel01 )
				oBrw:SetIniWindow(DbSetOrder(2))
				
				If FindFunction('TAFSetFilter')
					oBrw:SetFilterDefault(TAFBrwSetFilter("T2G","TAFA422","S-5002"))
				Else
					oBrw:SetFilterDefault( "T2G_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
				EndIf

				oBrw:AddLegend( "T2G_EVENTO == 'I' ", "GREEN" , STR0020 ) //"Registro Incluído"
				oBrw:AddLegend( "T2G_EVENTO == 'E' ", "RED"   , STR0021 ) //"Registro Excluído"

			EndIf

			/*------------------------------------
			Construção do Painel 02 - Outras Ações
			------------------------------------*/

			nWidth := ( oPanel02:nClientWidth / 2 ) - 3
			nHeight := Int( ( oPanel02:nClientHeight / 2 ) / 10 ) - 5

			nTop := 5
			oBtFil := TButton():New( 005, 002, "Filtro CPF/Nome", oPanel02, bFiltro, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )
			oBtFil:SetCSS(SetCssButton("11","#FFFFFF","#1DA2C3","#1DA2C3"))

			nTop += nHeight + 5
			TButton():New( nTop, 002, "Excluir Registro"    , oPanel02, bExcReg , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

			nTop += nHeight + 5
			TButton():New( nTop, 002, "Gerar Xml e-Social"  , oPanel02, bGerXml , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

			nTop += nHeight + 5
			TButton():New( nTop, 002, "Gerar XML em Lote"   , oPanel02, bXmlLote, nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

			nTop += nHeight + 5
			TButton():New( nTop, 002, "Fechar"              , oPanel02, bClose  , nWidth, nHeight,,,, .T.,,,, { || lFreeze } )

			/*-------------------
			Ativação da Interface
			-------------------*/

			oBrw:Activate()
			oDialog:Activate()

		Else

			oBrw:SetDescription(STR0019) //"Imposto de Renda Retido na Fonte"
			oBrw:SetAlias("T2G")
			oBrw:SetMenuDef("TAFA422")

			If FindFunction('TAFSetFilter')
				oBrw:SetFilterDefault(TAFBrwSetFilter("T2G","TAFA422","S-5002"))
			Else
				oBrw:SetFilterDefault( "T2G_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
			EndIf

			oBrw:AddLegend( "T2G_EVENTO == 'I' ", "GREEN" , STR0020 ) //"Registro Incluído"
			oBrw:AddLegend( "T2G_EVENTO == 'E' ", "RED"   , STR0021 ) //"Registro Excluído"

			oBrw:Activate()

		EndIf

	EndIf 

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	If FindFunction("FilCpfNome") .And. GetSx3Cache("T2G_CPFV","X3_CONTEXT") == "V"

		ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TAFA422' OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION 'VIEWDEF.TAFA422' OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF422Xml" , "1" } )
		Aadd( aFuncao, { "" , "xFunHisAlt( 'T2G' , 'TAFA422' )", "3" } )
		Aadd( aFuncao, { "" , "TAFXmlLote( 'T2G', 'S-5002' , 'evtIrrfBenef' , 'TAF422Xml', , oBrw )" , "5" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'T2G' )" , "10" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif

			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA422' OPERATION 2 ACCESS 0 //"Visualizar"

		Else

			aRotina	:=	xFunMnuTAF( "TAFA422" , , aFuncao)

			nPosDel	:=	aScan( aRotina , { | aX | AllTrim( aX[ 1 ] ) == "Exibir Histórico de Alterações" } )

			If nPosDel > 0
				aDel( aRotina , nPosDel )
				aSize( aRotina , Len( aRotina ) - 1 )
			EndIf

		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel   	as Object
	Local oStruT2G	as Object
	Local oStruT2I	as Object
	Local oStruT2H	as Object
	Local oStruT2J	as Object
	Local oStruV6J	as Object
	Local oStruV7M	as Object
	Local oStruV7N	as Object
	Local oStruV8H	as Object
	Local oStruV8J	as Object
	Local oStruV8T	as Object
	Local oStruV8V	as Object
	Local oStruV60  as Object
	Local oStruV61  as Object
	Local oStruV62  as Object
	Local oStruV64  as Object
	Local oStruV63  as Object
	Local oStruV65  as Object 
	Local oStruV66  as Object 
	Local oStruV67  as Object 
	Local oStruV68  as Object 
	Local oStruV69  as Object
	Local oStruV6A  as Object 
	Local oStruV54  as Object 
	Local oStruV50  as Object
	Local oStruV51  as Object
	Local oStruV52  as Object
	Local oStruV53  as Object
	Local oStruT8G  as Object
	Local oStruT8H  as Object
	Local cCmpFil	as Character
	Local lRelation12 as Logical
	Local nX		as Numeric

	oModel   := MpFormModel():New("TAFA422", , , {|oModel| SaveModel(oModel)}) // Modelo de dados que será construído
	oStruT2G := FwFormStruct(1,"T2G")
	oStruT2I := FwFormStruct(1,"T2I")
	oStruT2H := Nil
	oStruT2J := Nil
	oStruV6J := Nil
	oStruV7M := Nil
	oStruV7N := Nil
	oStruV8H := Nil
	oStruV8J := Nil
	oStruV8T := Nil
	oStruV8V := Nil

	oStruV60 := Nil 
	oStruV61 := Nil 
	oStruV62 := Nil 
	oStruV64 := Nil 
	oStruV63 := Nil 
	oStruV65 := Nil 
	oStruV66 := Nil 
	oStruV67 := Nil 
	oStruV68 := Nil 
	oStruV69 := Nil 
	oStruV6A := Nil 
	oStruV54 := Nil 
	oStruV50 := Nil 
	oStruV51 := Nil 
	oStruV52 := Nil 
	oStruV53 := Nil 
	oStruT8G := Nil 
	oStruT8H := Nil 

	lRelation12 := .T.

	If lLaySimplif == Nil
		lLaySimplif := TafLayESoc()
	EndIf 

	If lSimpl12 == Nil 
		lSimpl12 := TafLayESoc("S_01_02_00",, .T.)
	EndIf 

	If lSimpl0103 == Nil 
		lSimpl0103 := TafLayESoc("S_01_03_00",, .T.)
	EndIf 

	cCmpFil  := ""
	nX       := 0

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oStruT2H := FwFormStruct(1,"T2H")
		oStruT2J := FwFormStruct(1,"T2J")

		// Remove campos da Model	
		cCmpFil := "T2G_INDDEV|T2G_TPPAG|T2G_DTPAG|T2G_CODCAT|T2G_DCODCA|T2G_CPFBEN|T2G_PERREF"
		aCmpFil := StrTokArr2(cCmpFil, "|")
		
		For nX := 1 To Len(aCmpFil)
			oStruT2G:RemoveField(aCmpFil[nX])
		Next

		// Adiciona ao modelo um componente de formulário
		lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

		If lVldModel
			oStruT2G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf

		oModel:AddFields("MODEL_T2G",/*cOwner*/,oStruT2G)
	
		//Informações relativas ao Imposto de Renda Retido na Fonte do Trabalhador e suas bases de cálculo.
		oModel:AddGrid("MODEL_T2H", "MODEL_T2G", oStruT2H)
		oModel:GetModel( "MODEL_T2H" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T2H" ):SetUniqueLine( { "T2H_CODCAT" } )
		oModel:GetModel('MODEL_T2H'):SetUniqueLine({'T2H_SEQUEN', 'T2H_CODCAT', 'T2H_INDRES'})
		oModel:GetModel('MODEL_T2H'):SetMaxLine(9)

		//Bases, deduções, isenções e retenções do IRRF
		oModel:AddGrid("MODEL_T2I", "MODEL_T2H", oStruT2I)
		oModel:GetModel( "MODEL_T2I" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T2I" ):SetUniqueLine( { "T2I_CTPVAL" } )
		oModel:GetModel('MODEL_T2I'):SetMaxLine(99) //Informa quantida maxima de linhas na Grid

		//Informações relativas ao Imposto de Renda Retido na Fonte
		oModel:AddGrid("MODEL_T2J", "MODEL_T2H", oStruT2J)
		oModel:GetModel( "MODEL_T2J" ):SetOptional( .T. )

		If TAFColumnPos("T2J_CODREC")
			oModel:GetModel( "MODEL_T2J" ):SetUniqueLine({"T2J_CODREC", "T2J_CTPCR"})
		Else
			oModel:GetModel( "MODEL_T2J" ):SetUniqueLine({"T2J_CTPCR"})
		EndIf

		oModel:GetModel('MODEL_T2J'):SetMaxLine(20) //Informa quantida maxima de linhas na  ) )

		oModel:SetRelation("MODEL_T2H",{ {"T2H_FILIAL","xFilial('T2H')"}, {"T2H_ID","T2G_ID"}, {"T2H_VERSAO","T2G_VERSAO"} },T2H->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T2I",{ {"T2I_FILIAL","xFilial('T2I')"}, {"T2I_ID","T2G_ID"}, {"T2I_VERSAO","T2G_VERSAO"},	{"T2I_SEQUEN","T2H_SEQUEN"} ,{"T2I_CODCAT","T2H_CODCAT"},{"T2I_INDRES","T2H_INDRES"} },T2I->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T2J",{ {"T2J_FILIAL","xFilial('T2J')"}, {"T2J_ID","T2G_ID"}, {"T2J_VERSAO","T2G_VERSAO"},	{"T2J_SEQUEN","T2H_SEQUEN"} ,{"T2J_CODCAT","T2H_CODCAT"},{"T2J_INDRES","T2H_INDRES"} },T2J->(IndexKey(1)) )

		oModel:GetModel("MODEL_T2G"):SetPrimaryKey({"T2G_PERAPU","T2G_CPFTRA"})

	ElseIf lLaySimplif .Or. lSimpl12 .Or. lSimpl0103

		oStruV6J := FwFormStruct(1,"V6J")
		
		If ( lSimpl12 .Or. lSimpl0103 ).And. TafColumnPos("V8H_NIFBEN")

			oStruV8J := FwFormStruct(1,"V8J")
			oStruV8T := FwFormStruct(1,"V8T")
			oStruV8H := FwFormStruct(1,"V8H")
			oStruV8V := FwFormStruct(1,"V8V")
			
			oStruV60 := FWFormStruct(1,"V60")
			oStruV61 := FWFormStruct(1,"V61")
			oStruV62 := FWFormStruct(1,"V62")
			oStruV64 := FWFormStruct(1,"V64")
			oStruV63 := FWFormStruct(1,"V63")
			oStruV65 := FWFormStruct(1,"V65")
			oStruV66 := FWFormStruct(1,"V66")
			oStruV67 := FWFormStruct(1,"V67")
			oStruV68 := FWFormStruct(1,"V68")
			oStruV69 := FWFormStruct(1,"V69")
			oStruV6A := FWFormStruct(1,"V6A")
			oStruV54 := FWFormStruct(1,"V54")
			oStruV50 := FWFormStruct(1,"V50")
			oStruV51 := FWFormStruct(1,"V51")
			oStruV52 := FWFormStruct(1,"V52")
			oStruV53 := FWFormStruct(1,"V53")

			If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")

				oStruT8G := FWFormStruct(1,"T8G")
				oStruT8H := FWFormStruct(1,"T8H")
			
			EndIf

			SetFieldUsed(oStruV61,"V61_VLRDED",1)
			SetFieldUsed(oStruV65,"V65_VLACAL",1)

		EndIf 
		
		oStruV7M := FwFormStruct(1,"V7M")
		oStruV7N := FwFormStruct(1,"V7N")
	
		// Remove campos da Model	
		cCmpFil := "T2G_VRDEDD|"
		aCmpFil := StrTokArr2(cCmpFil, "|")
		
		For nX := 1 To Len(aCmpFil)
			oStruT2G:RemoveField(aCmpFil[nX])
		Next

		// Adiciona ao modelo um componente de formulário
		lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

		If lVldModel
			oStruT2G:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
		EndIf

		oModel:AddFields("MODEL_T2G",/*cOwner*/,oStruT2G)

		// 	Informações do demonstrativo de valores devidos
		oModel:AddGrid("MODEL_V6J", "MODEL_T2G",oStruV6J)

		//Bases, deduções, isenções e retenções do IRRF
		oModel:AddGrid("MODEL_T2I", "MODEL_V6J", oStruT2I)

		//totApurMen
		oModel:AddGrid("MODEL_V7M", "MODEL_V6J", oStruV7M)
		oModel:GetModel( "MODEL_V7M" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V7M" ):SetUniqueLine( { "V7M_CRMEN" } )
		oModel:GetModel('MODEL_V7M'):SetMaxLine(50)

		//totApurDia
		oModel:AddGrid("MODEL_V7N", "MODEL_V6J", oStruV7N)
		oModel:GetModel( "MODEL_V7N" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V7N" ):SetUniqueLine( { "V7N_PERDIA", "V7N_CRDIA" } )
		oModel:GetModel('MODEL_V7N'):SetMaxLine(350)

		oModel:GetModel("MODEL_T2G"):SetPrimaryKey( { "T2G_PERAPU", "T2G_CPFBEN" } )

		oModel:GetModel( "MODEL_V6J" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V6J" ):SetUniqueLine( { "V6J_SEQUEN", "V6J_PERREF", "V6J_INDDEV", "V6J_TPPAG" } )
		
		oModel:GetModel( "MODEL_T2I" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_T2I" ):SetUniqueLine( { "T2I_CTPVAL" } )
		oModel:GetModel( "MODEL_T2I" ):SetMaxLine(999) //Informa quantida maxima de linhas na Grid
		
		oStruT2I:SetProperty( "T2I_DTPVAL", MODEL_FIELD_INIT, {|| Iif(!Empty(T2I->T2I_CTPVAL), Posicione("C8U", 1, xFilial("C8U")+T2I->T2I_CTPVAL, "AllTrim(C8U_CODIGO) + ' - ' + AllTrim(C8U_DESCRI)"), "")} )

		If lSimpl12 .Or. lSimpl0103

			//Demais rendimentos com exigibilidade suspensa decorrentes de decisão judicial aplicável à rubrica.
			oModel:AddGrid("MODEL_V8J", "MODEL_T2I", oStruV8J)
			oModel:GetModel( "MODEL_V8J" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V8J" ):SetUniqueLine( { "V8J_NRPROC" } )
			oModel:GetModel('MODEL_V8J'):SetMaxLine(999)

			//Informações complementares relativas a Rendimentos Recebidos Acumuladamente - RRA.	
			oModel:AddGrid("MODEL_V8T", "MODEL_V6J", oStruV8T)
			oModel:GetModel( "MODEL_V8T" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V8T" ):SetUniqueLine( { "V8T_SEQRRA" } )
			oModel:GetModel('MODEL_V8T'):SetMaxLine(1)
			
			//Detalhamento das despesas com processo judicial (despProcJud)
			oModel:AddGrid("MODEL_V52", "MODEL_V8T", oStruV52)
			oModel:GetModel( "MODEL_V52" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V52" ):SetUniqueLine( { "V52_SEQDPJ" } )
			oModel:GetModel('MODEL_V52'):SetMaxLine(1)

			//Identificação dos advogados (ideAdv)
			oModel:AddGrid("MODEL_V53", "MODEL_V8T", oStruV53)
			oModel:GetModel( "MODEL_V53" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V53" ):SetUniqueLine( { "V53_TPINSC", "V53_NRINSC"  } )
			oModel:GetModel('MODEL_V53'):SetMaxLine(99)

			//Informações complementares relativas a pagamentos a residente fiscal no exterior. 
			oModel:AddGrid("MODEL_V8H", "MODEL_V6J", oStruV8H)
			oModel:GetModel( "MODEL_V8H" ):SetOptional( .T. )
			oModel:GetModel( "MODEL_V8H" ):SetUniqueLine( { "V8H_NIFBEN" } )
			oModel:GetModel('MODEL_V8H'):SetMaxLine(1)

			If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")

				//totInfoIR/consolidApurMen - Totalização dos rendimentos tributáveis, deduções e isenções com período de apuração mensal.
				oModel:AddGrid("MODEL_T8G", "MODEL_T2G", oStruT8G)
				oModel:GetModel("MODEL_T8G"):SetOptional(.T.)
				oModel:GetModel("MODEL_T8G"):SetUniqueLine({"T8G_CRMEN"})
				oModel:GetModel("MODEL_T8G"):SetMaxLine(50)

				//perAnt - Identificação do evento S-1210 original e perRef cujas informações de infoIRComplem serão alteradas.
				oModel:AddGrid("MODEL_T8H", "MODEL_T2G", oStruT8H)
				oModel:GetModel("MODEL_T8H"):SetOptional(.T.)
				oModel:GetModel("MODEL_T8H"):SetUniqueLine({"T8H_SEQIRC", "T8H_PERREF"})
				oModel:GetModel("MODEL_T8H"):SetMaxLine(13)


			EndIf

			If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")
				//Informações complementares para a DIRF ou para a DAA.
				oModel:AddGrid("MODEL_V8V", "MODEL_T8H", oStruV8V)
				oModel:GetModel( "MODEL_V8V" ):SetOptional( .T. )
				oModel:GetModel( "MODEL_V8V" ):SetUniqueLine( { "V8V_CPFDEP" } )
				oModel:GetModel('MODEL_V8V'):SetMaxLine(999)

				//infoIRCR
				oModel:AddGrid("MODEL_V60", "MODEL_T8H", oStruV60)
				oModel:GetModel("MODEL_V60"):SetOptional(.T.)
				oModel:GetModel("MODEL_V60"):SetUniqueLine({"V60_TPCR"})
				oModel:GetModel("MODEL_V60"):SetMaxLine(99)

				//planSaude
				oModel:AddGrid("MODEL_V68", "MODEL_T8H", oStruV68)
				oModel:GetModel("MODEL_V68"):SetOptional(.T.)
				oModel:GetModel("MODEL_V68"):SetUniqueLine({"V68_CNPJOP"})
				oModel:GetModel("MODEL_V68"):SetMaxLine(99)

				//infoReembMed
				oModel:AddGrid("MODEL_V6A", "MODEL_T8H", oStruV6A)
				oModel:GetModel("MODEL_V6A"):SetOptional(.T.)
				oModel:GetModel("MODEL_V6A"):SetUniqueLine({"V6A_SEQUEN"})
				oModel:GetModel("MODEL_V6A"):SetMaxLine(99)

			Else
				//Informações complementares para a DIRF ou para a DAA.
				oModel:AddGrid("MODEL_V8V", "MODEL_T2G", oStruV8V)
				oModel:GetModel( "MODEL_V8V" ):SetOptional( .T. )
				oModel:GetModel( "MODEL_V8V" ):SetUniqueLine( { "V8V_CPFDEP" } )
				oModel:GetModel('MODEL_V8V'):SetMaxLine(999)

				//infoIRCR
				oModel:AddGrid("MODEL_V60", "MODEL_T2G", oStruV60)
				oModel:GetModel("MODEL_V60"):SetOptional(.T.)
				oModel:GetModel("MODEL_V60"):SetUniqueLine({"V60_TPCR"})
				oModel:GetModel("MODEL_V60"):SetMaxLine(99)

				//planSaude
				oModel:AddGrid("MODEL_V68", "MODEL_T2G", oStruV68)
				oModel:GetModel("MODEL_V68"):SetOptional(.T.)
				oModel:GetModel("MODEL_V68"):SetUniqueLine({"V68_CNPJOP"})
				oModel:GetModel("MODEL_V68"):SetMaxLine(99)

				//infoReembMed
				oModel:AddGrid("MODEL_V6A", "MODEL_T2G", oStruV6A)
				oModel:GetModel("MODEL_V6A"):SetOptional(.T.)
				oModel:GetModel("MODEL_V6A"):SetUniqueLine({"V6A_SEQUEN"})
				oModel:GetModel("MODEL_V6A"):SetMaxLine(99)
			EndIf

			//dedDepen
			oModel:AddGrid("MODEL_V61", "MODEL_V60", oStruV61)
			oModel:GetModel("MODEL_V61"):SetOptional(.T.)
			oModel:GetModel("MODEL_V61"):SetUniqueLine({"V61_TPREND","V61_CPFDEP"})
			oModel:GetModel("MODEL_V61"):SetMaxLine(999)

			//penAlim
			oModel:AddGrid("MODEL_V62", "MODEL_V60", oStruV62)
			oModel:GetModel("MODEL_V62"):SetOptional(.T.)
			oModel:GetModel("MODEL_V62"):SetUniqueLine({"V62_TPREND","V62_CPFDEP"})
			oModel:GetModel("MODEL_V62"):SetMaxLine(99)

			//previdCompl
			oModel:AddGrid("MODEL_V63", "MODEL_V60", oStruV63)
			oModel:GetModel("MODEL_V63"):SetOptional(.T.)
			oModel:GetModel("MODEL_V63"):SetUniqueLine({"V63_TPREV","V63_INSCPL"})
			oModel:GetModel("MODEL_V63"):SetMaxLine(99)

			//infoProcRet
			oModel:AddGrid("MODEL_V64", "MODEL_V60", oStruV64)
			oModel:GetModel("MODEL_V64"):SetOptional(.T.)
			oModel:GetModel("MODEL_V64"):SetUniqueLine({"V64_TPPROC","V64_NRPROC", "V64_CODSUP"})
			oModel:GetModel("MODEL_V64"):SetMaxLine(50)

			//infoValores
			oModel:AddGrid("MODEL_V65", "MODEL_V64", oStruV65)
			oModel:GetModel("MODEL_V65"):SetOptional(.T.)
			oModel:GetModel("MODEL_V65"):SetUniqueLine({"V65_INDAPU"})
			oModel:GetModel("MODEL_V65"):SetMaxLine(2)

			//dedSusp
			oModel:AddGrid("MODEL_V66", "MODEL_V65", oStruV66)
			oModel:GetModel("MODEL_V66"):SetOptional(.T.)
			oModel:GetModel("MODEL_V66"):SetUniqueLine({"V66_SEQUEN"})
			oModel:GetModel("MODEL_V66"):SetMaxLine(25)

			//benefPen
			oModel:AddGrid("MODEL_V67", "MODEL_V66", oStruV67)
			oModel:GetModel("MODEL_V67"):SetOptional(.T.)
			oModel:GetModel("MODEL_V67"):SetUniqueLine({"V67_CPFDEP"})
			oModel:GetModel("MODEL_V67"):SetMaxLine(99)

			//infoDepSau
			oModel:AddGrid("MODEL_V69", "MODEL_V68", oStruV69)
			oModel:GetModel("MODEL_V69"):SetOptional(.T.)
			oModel:GetModel("MODEL_V69"):SetUniqueLine({"V69_CPFDEP"})
			oModel:GetModel("MODEL_V69"):SetMaxLine(99)

			//detReembTit
			oModel:AddGrid("MODEL_V54", "MODEL_V6A", oStruV54)
			oModel:GetModel("MODEL_V54"):SetOptional(.T.)
			oModel:GetModel("MODEL_V54"):SetUniqueLine({"V54_TPINSC", "V54_NRINSC"})
			oModel:GetModel("MODEL_V54"):SetMaxLine(99)

			//infoReembDep
			oModel:AddGrid("MODEL_V50", "MODEL_V54", oStruV50)
			oModel:GetModel("MODEL_V50"):SetOptional(.T.)
			oModel:GetModel("MODEL_V50"):SetUniqueLine({"V50_CPFDEP"})
			oModel:GetModel("MODEL_V50"):SetMaxLine(99)

			//detReembDep
			oModel:AddGrid("MODEL_V51", "MODEL_V50", oStruV51)
			oModel:GetModel("MODEL_V51"):SetOptional(.T.)
			oModel:GetModel("MODEL_V51"):SetUniqueLine({"V51_TPINSC", "V51_NRINSC"})
			oModel:GetModel("MODEL_V51"):SetMaxLine(99)


		EndIf 

		oModel:SetRelation( "MODEL_V6J", { { "V6J_FILIAL", "xFilial('V6J')" }, { "V6J_ID", "T2G_ID" }, { "V6J_VERSAO", "T2G_VERSAO" } }, V6J->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_T2I", { { "T2I_FILIAL", "xFilial('T2I')" }, { "T2I_ID", "T2G_ID" }, { "T2I_VERSAO", "T2G_VERSAO" }, { "T2I_SEQUEN", "V6J_SEQUEN" },;
											{ "T2I_PERREF", "V6J_PERREF" }, { "T2I_INDDEV", "V6J_INDDEV" }, { "T2I_TPPAG", "V6J_TPPAG" }  }, T2I->( IndexKey( 2 ) ) )
		oModel:SetRelation( "MODEL_V7M", { { "V7M_FILIAL", "xFilial('V7M')" }, { "V7M_ID", "T2G_ID" }, { "V7M_VERSAO", "T2G_VERSAO" }, { "V7M_SEQUEN", "V6J_SEQUEN" }, { "V7M_PERREF", "V6J_PERREF" }, { "V7M_INDDEV", "V6J_INDDEV" }, { "V7M_TPPAG", "V6J_TPPAG" } }, V7M->( IndexKey( 1 ) ) )
		oModel:SetRelation( "MODEL_V7N", { { "V7N_FILIAL", "xFilial('V7N')" }, { "V7N_ID", "T2G_ID" }, { "V7N_VERSAO", "T2G_VERSAO" }, { "V7N_SEQUEN", "V6J_SEQUEN" }, { "V7N_PERREF", "V6J_PERREF" }, { "V7N_INDDEV", "V6J_INDDEV" }, { "V7N_TPPAG", "V6J_TPPAG" } }, V7N->( IndexKey( 1 ) ) )

		If lSimpl12 .Or. lSimpl0103

			If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")

				oModel:SetRelation("MODEL_T8H", {{"T8H_FILIAL", "xFilial('T2G')"}, {"T8H_ID", "T2G_ID"}, {"T8H_VERSAO", "T2G_VERSAO"}}, T8H->(IndexKey(1)))
				oModel:SetRelation( "MODEL_V8V",{ { "V8V_FILIAL", "xFilial('V8V')" }, { "V8V_ID", "T2G_ID" }, { "V8V_VERSAO", "T2G_VERSAO" }, { "V8V_PERAPU", "T2G_PERAPU" }, { "V8V_CPFTRA", "T2G_CPFTRA" },{ "V8V_CPFBEN", "T2G_CPFBEN" }, {"V8V_SEQIRC", "T8H_SEQIRC"}  }, V8V->( IndexKey( 2 ) ) )//ALTERADO O INDICE
				oModel:SetRelation("MODEL_T8G", {{"T8G_FILIAL", "xFilial('T2G')"}, {"T8G_ID", "T2G_ID"}, {"T8G_VERSAO", "T2G_VERSAO"}}, T8G->(IndexKey(1)))
				oModel:SetRelation("MODEL_V60", {{"V60_FILIAL", "xFilial('T2G')"}, {"V60_ID", "T2G_ID"}, {"V60_VERSAO", "T2G_VERSAO"}, { "V60_SEQIRC", "T8H_SEQIRC" }}, V60->(IndexKey(2))) //ALTERADO O INDICE
				oModel:SetRelation("MODEL_V61", {{"V61_FILIAL", "xFilial('T2G')"}, {"V61_ID", "T2G_ID"}, {"V61_VERSAO", "T2G_VERSAO"},{"V61_TPCR", "V60_TPCR"}, { "V61_SEQIRC", "T8H_SEQIRC" }}, V61->(IndexKey(2))) //INDICE ALTERADO
				oModel:SetRelation("MODEL_V62", {{"V62_FILIAL", "xFilial('T2G')"}, {"V62_ID", "T2G_ID"}, {"V62_VERSAO", "T2G_VERSAO"},{"V62_TPCR", "V60_TPCR"}, { "V62_SEQIRC", "T8H_SEQIRC" }}, V62->(IndexKey(2))) //INDICE ALTERADO
				oModel:SetRelation("MODEL_V63", {{"V63_FILIAL", "xFilial('T2G')"}, {"V63_ID", "T2G_ID"}, {"V63_VERSAO", "T2G_VERSAO"},{"V63_TPCR", "V60_TPCR"}, { "V63_SEQIRC", "T8H_SEQIRC" }}, V63->(IndexKey(2))) //INDICE ALTERADO
				oModel:SetRelation("MODEL_V64", {{"V64_FILIAL", "xFilial('T2G')"}, {"V64_ID", "T2G_ID"}, {"V64_VERSAO", "T2G_VERSAO"},{"V64_TPCR", "V60_TPCR"}, { "V64_SEQIRC", "T8H_SEQIRC" }}, V64->(IndexKey(2))) //INDICE ALTERADO
				oModel:SetRelation("MODEL_V65", {{"V65_FILIAL", "xFilial('T2G')"}, {"V65_ID", "T2G_ID"}, {"V65_VERSAO", "T2G_VERSAO"},{"V65_TPCR", "V60_TPCR"},{"V65_TPPROC", "V64_TPPROC"}, {"V65_NRPROC", "V64_NRPROC"}, {"V65_CODSUP", "V64_CODSUP"}, { "V65_SEQIRC", "T8H_SEQIRC" }}, V65->(IndexKey(2)))//INDICE ALTERADO
				oModel:SetRelation("MODEL_V66", {{"V66_FILIAL", "xFilial('T2G')"}, {"V66_ID", "T2G_ID"}, {"V66_VERSAO", "T2G_VERSAO"},{"V66_TPCR", "V60_TPCR"},{"V66_TPPROC", "V64_TPPROC"}, {"V66_NRPROC", "V64_NRPROC"}, {"V66_CODSUP", "V64_CODSUP"},{"V66_INDAPU", "V65_INDAPU"},  { "V66_SEQIRC", "T8H_SEQIRC" }}, V66->(IndexKey(2)))//INDICE ALTERADO
				oModel:SetRelation("MODEL_V67", {{"V67_FILIAL", "xFilial('T2G')"}, {"V67_ID", "T2G_ID"}, {"V67_VERSAO", "T2G_VERSAO"},{"V67_TPCR", "V60_TPCR"},{"V67_TPPROC", "V64_TPPROC"}, {"V67_NRPROC", "V64_NRPROC"}, {"V67_CODSUP", "V64_CODSUP"},{"V67_INDAPU", "V65_INDAPU"},{"V67_SEQV66", "V66_SEQUEN"},  { "V67_SEQIRC", "T8H_SEQIRC" }}, V67->(IndexKey(2)))// ALTERADO O INDICE
				oModel:SetRelation("MODEL_V68", {{"V68_FILIAL", "xFilial('T2G')"}, {"V68_ID", "T2G_ID"}, {"V68_VERSAO", "T2G_VERSAO"},{"V68_SEQIRC", "T8H_SEQIRC"}}, V68->(IndexKey(2)))//ALTERADO NOVO INDICE
			    oModel:SetRelation("MODEL_V69", {{"V69_FILIAL", "xFilial('T2G')"}, {"V69_ID", "T2G_ID"}, {"V69_VERSAO", "T2G_VERSAO"},{"V69_CNPJOP","V68_CNPJOP"},{"V69_SEQIRC", "T8H_SEQIRC"}}, V69->(IndexKey(2)))//ALTERADO INDICE

				oModel:SetRelation("MODEL_V6A", {{"V6A_FILIAL", "xFilial('T2G')"}, {"V6A_ID", "T2G_ID"}, {"V6A_VERSAO", "T2G_VERSAO"},{"V6A_SEQIRC", "T8H_SEQIRC"}}, V6A->(IndexKey(2)))//ALTERADO INDICE E X2 ÚNICO
				oModel:SetRelation("MODEL_V54", {{"V54_FILIAL", "xFilial('T2G')"}, {"V54_ID", "T2G_ID"}, {"V54_VERSAO", "T2G_VERSAO"},{"V54_SEQUEN", "V6A_SEQUEN"},{"V54_SEQIRC", "T8H_SEQIRC"}}, V54->(IndexKey(2)))
				oModel:SetRelation("MODEL_V50", {{"V50_FILIAL", "xFilial('T2G')"}, {"V50_ID", "T2G_ID"}, {"V50_VERSAO", "T2G_VERSAO"},{"V50_SEQUEN", "V6A_SEQUEN"},{"V50_SEQIRC", "T8H_SEQIRC"}}, V50->(IndexKey(2)))
				oModel:SetRelation("MODEL_V51", {{"V51_FILIAL", "xFilial('T2G')"}, {"V51_ID", "T2G_ID"}, {"V51_VERSAO", "T2G_VERSAO"},{"V51_SEQUEN", "V6A_SEQUEN"},{"V51_CPFDEP","V50_CPFDEP"},{"V51_SEQIRC", "T8H_SEQIRC"}}, V51->(IndexKey(2)))

				lRelation12 := .F.

			EndIf
			
			
			oModel:SetRelation( "MODEL_V8J", { { "V8J_FILIAL", "xFilial('V8J')" }, { "V8J_ID", "T2G_ID" }, { "V8J_VERSAO", "T2G_VERSAO" }, { "V8J_SEQUEN", "V6J_SEQUEN" }, { "V8J_INDDEV", "V6J_INDDEV" }, { "V8J_TPPAG", "V6J_TPPAG" }, { "V8J_PERREF", "V6J_PERREF" }, { "V8J_CTPVAL", "T2I_CTPVAL" }  }, V8J->( IndexKey( 1 ) ) )
			oModel:SetRelation( "MODEL_V8T", { { "V8T_FILIAL", "xFilial('V8T')" }, { "V8T_ID", "T2G_ID" }, { "V8T_VERSAO", "T2G_VERSAO" }, { "V8T_SEQV6J", "V6J_SEQUEN" }, { "V8T_INDDEV", "V6J_INDDEV" }, { "V8T_TPPAG", "V6J_TPPAG" }, { "V8T_PERREF", "V6J_PERREF" }  }, V8T->( IndexKey( 1 ) ) )
			oModel:SetRelation( "MODEL_V52", { { "V52_FILIAL", "xFilial('V52')" }, { "V52_ID", "T2G_ID" }, { "V52_VERSAO", "T2G_VERSAO" }, { "V52_SEQV6J", "V6J_SEQUEN" }, { "V52_INDDEV", "V6J_INDDEV" }, { "V52_TPPAG", "V6J_TPPAG" }, { "V52_PERREF", "V6J_PERREF" }, { "V52_SEQRRA", "V8T_SEQRRA" } }, V52->( IndexKey( 1 ) ) )
			oModel:SetRelation( "MODEL_V53", { { "V53_FILIAL", "xFilial('V53')" }, { "V53_ID", "T2G_ID" }, { "V53_VERSAO", "T2G_VERSAO" }, { "V53_SEQV6J", "V6J_SEQUEN" }, { "V53_INDDEV", "V6J_INDDEV" }, { "V53_TPPAG", "V6J_TPPAG" }, { "V53_PERREF", "V6J_PERREF" }, { "V53_SEQRRA", "V8T_SEQRRA" } }, V53->( IndexKey( 1 ) ) )
			
			If TafColumnPos("V8H_SEQUEN")
				oModel:SetRelation( "MODEL_V8H", { { "V8H_FILIAL", "xFilial('V8H')" }, { "V8H_ID", "T2G_ID" }, { "V8H_VERSAO", "T2G_VERSAO" }, { "V8H_SEQUEN", "V6J_SEQUEN" } }, V8H->( IndexKey( 1 ) ) )
			Else
				oModel:SetRelation( "MODEL_V8H", { { "V8H_FILIAL", "xFilial('V8H')" }, { "V8H_ID", "T2G_ID" }, { "V8H_VERSAO", "T2G_VERSAO" } }, V8H->( IndexKey( 1 ) ) )
			EndIf
			
			If lRelation12

				oModel:SetRelation( "MODEL_V8V", { { "V8V_FILIAL", "xFilial('V8V')" }, { "V8V_ID", "T2G_ID" }, { "V8V_VERSAO", "T2G_VERSAO" }, { "V8V_PERAPU", "T2G_PERAPU" }, { "V8V_CPFTRA", "T2G_CPFTRA" },{ "V8V_CPFBEN", "T2G_CPFBEN" }  }, V8V->( IndexKey( 1 ) ) )
				oModel:SetRelation("MODEL_V60", {{"V60_FILIAL", "xFilial('T2G')"}, {"V60_ID", "T2G_ID"}, {"V60_VERSAO", "T2G_VERSAO"}}, V60->(IndexKey(1)))
				oModel:SetRelation("MODEL_V61", {{"V61_FILIAL", "xFilial('T2G')"}, {"V61_ID", "T2G_ID"}, {"V61_VERSAO", "T2G_VERSAO"},{"V61_TPCR", "V60_TPCR"}}, V61->(IndexKey(1)))
				oModel:SetRelation("MODEL_V62", {{"V62_FILIAL", "xFilial('T2G')"}, {"V62_ID", "T2G_ID"}, {"V62_VERSAO", "T2G_VERSAO"},{"V62_TPCR", "V60_TPCR"}}, V62->(IndexKey(1)))
				oModel:SetRelation("MODEL_V63", {{"V63_FILIAL", "xFilial('T2G')"}, {"V63_ID", "T2G_ID"}, {"V63_VERSAO", "T2G_VERSAO"},{"V63_TPCR", "V60_TPCR"}}, V63->(IndexKey(1)))
				oModel:SetRelation("MODEL_V64", {{"V64_FILIAL", "xFilial('T2G')"}, {"V64_ID", "T2G_ID"}, {"V64_VERSAO", "T2G_VERSAO"},{"V64_TPCR", "V60_TPCR"}}, V64->(IndexKey(1)))
				oModel:SetRelation("MODEL_V65", {{"V65_FILIAL", "xFilial('T2G')"}, {"V65_ID", "T2G_ID"}, {"V65_VERSAO", "T2G_VERSAO"},{"V65_TPCR", "V60_TPCR"},{"V65_TPPROC", "V64_TPPROC"}, {"V65_NRPROC", "V64_NRPROC"}, {"V65_CODSUP", "V64_CODSUP"}}, V65->(IndexKey(1)))
				oModel:SetRelation("MODEL_V66", {{"V66_FILIAL", "xFilial('T2G')"}, {"V66_ID", "T2G_ID"}, {"V66_VERSAO", "T2G_VERSAO"},{"V66_TPCR", "V60_TPCR"},{"V66_TPPROC", "V64_TPPROC"}, {"V66_NRPROC", "V64_NRPROC"}, {"V66_CODSUP", "V64_CODSUP"},{"V66_INDAPU", "V65_INDAPU"}}, V66->(IndexKey(1)))
				oModel:SetRelation("MODEL_V67", {{"V67_FILIAL", "xFilial('T2G')"}, {"V67_ID", "T2G_ID"}, {"V67_VERSAO", "T2G_VERSAO"},{"V67_TPCR", "V60_TPCR"},{"V67_TPPROC", "V64_TPPROC"}, {"V67_NRPROC", "V64_NRPROC"}, {"V67_CODSUP", "V64_CODSUP"},{"V67_INDAPU", "V65_INDAPU"},{"V67_SEQV66", "V66_SEQUEN"}}, V67->(IndexKey(1)))
				oModel:SetRelation("MODEL_V68", {{"V68_FILIAL", "xFilial('T2G')"}, {"V68_ID", "T2G_ID"}, {"V68_VERSAO", "T2G_VERSAO"}}, V68->(IndexKey(1)))
				oModel:SetRelation("MODEL_V69", {{"V69_FILIAL", "xFilial('T2G')"}, {"V69_ID", "T2G_ID"}, {"V69_VERSAO", "T2G_VERSAO"},{"V69_CNPJOP","V68_CNPJOP"}}, V69->(IndexKey(1)))

				oModel:SetRelation("MODEL_V6A", {{"V6A_FILIAL", "xFilial('T2G')"}, {"V6A_ID", "T2G_ID"}, {"V6A_VERSAO", "T2G_VERSAO"}}, V6A->(IndexKey(1)))
				oModel:SetRelation("MODEL_V54", {{"V54_FILIAL", "xFilial('T2G')"}, {"V54_ID", "T2G_ID"}, {"V54_VERSAO", "T2G_VERSAO"},{"V54_SEQUEN", "V6A_SEQUEN"}}, V54->(IndexKey(1)))
				oModel:SetRelation("MODEL_V50", {{"V50_FILIAL", "xFilial('T2G')"}, {"V50_ID", "T2G_ID"}, {"V50_VERSAO", "T2G_VERSAO"},{"V50_SEQUEN", "V6A_SEQUEN"}}, V50->(IndexKey(1)))
				oModel:SetRelation("MODEL_V51", {{"V51_FILIAL", "xFilial('T2G')"}, {"V51_ID", "T2G_ID"}, {"V51_VERSAO", "T2G_VERSAO"},{"V51_SEQUEN", "V6A_SEQUEN"},{"V51_CPFDEP","V50_CPFDEP"}}, V51->(IndexKey(1)))

			EndIf

		EndIf
	
	EndIf

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	as Object
	Local oView		as Object
	Local oStruT2I 	as Object
	Local oStruT2H 	as Object
	Local oStruT2J 	as Object
	Local oStruT2Ga	as Object
	Local oStruT2Gb	as Object
	Local oStruT2Gc	as Object
	Local oStruT2Gd	as Object
	Local oStruT2Ge	as Object
	Local oStruV6J	as Object
	Local oStruV7M	as Object
	Local oStruV7N	as Object
	Local oStruV8H	as Object
	Local oStruV8J	as Object
	Local oStruV8T	as Object
	Local oStruV8V	as Object
	Local oStruV60  as Object 
	Local oStruV61  as Object 
	Local oStruV62  as Object 
	Local oStruV63  as Object 
	Local oStruV64  as Object 
	Local oStruV65  as Object 
	Local oStruV66  as Object 
	Local oStruV67  as Object 
	Local oStruV68  as Object 
	Local oStruV69  as Object 
	Local oStruV6A  as Object 
	Local oStruV54  as Object
	Local oStruV50  as Object 
	Local oStruV51  as Object 
	Local oStruV52  as Object 
	Local oStruV53  as Object 
	Local oStruT8G  as Object
	Local oStruT8H  as Object
	Local cCmpFil	as Character

	oModel    := FWLoadModel( 'TAFA422' )
	oView     := FWFormView():New()
	oStruT2I  := FWFormStruct(2, 'T2I' )
	oStruT2H  := Nil
	oStruT2J  := Nil
	oStruT2Ga := Nil
	oStruT2Gb := Nil
	oStruT2Gc := Nil
	oStruT2Gd := Nil
	oStruT2Ge := Nil
	oStruV6J  := Nil
	oStruV7M  := Nil
	oStruV7N  := Nil
	oStruV8H  := Nil
	oStruV8J  := Nil
	oStruV8T  := Nil
	oStruV8V  := Nil
	oStruV60  := Nil 
	oStruV61  := Nil 
	oStruV62  := Nil 
	oStruV63  := Nil 
	oStruV64  := Nil 
	oStruV65  := Nil 
	oStruV66  := Nil 
	oStruV67  := Nil 
	oStruV68  := Nil 
	oStruV69  := Nil 
	oStruV6A  := Nil 
	oStruV54  := Nil
	oStruV50  := Nil 
	oStruV51  := Nil 
	oStruV52  := Nil 
	oStruV53  := Nil 
	oStruT8G  := Nil 
	oStruT8H  := Nil 

	cCmpFil   := ""

	oView:SetModel(oModel)
	oView:SetContinuousForm(.T.)

	// Tratamento para simplificação do e-Social
	If !lLaySimplif

		oStruT2I 	:= FWFormStruct(2,'T2I' )
		oStruT2H 	:= FWFormStruct(2,'T2H' )
		oStruT2J 	:= FWFormStruct(2,'T2J' )

		//Campos do folder Identificação do evento de retorno
		cCmpFil	:= "T2G_ID|T2G_VERSAO|T2G_RECBAS|T2G_PERAPU|"
		oStruT2Ga	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		//Campos do folder Identificação do trabalhador
		cCmpFil 	:= "T2G_CPFTRA|"
		oStruT2Gb	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		//Campos do folder Identificação do trabalhador
		cCmpFil 	:= "T2G_VRDEDD|"
		oStruT2Gc	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		// Campos do folder do número do ultimo protocolo
		cCmpFil	:= "T2G_PROTUL|"
		oStruT2Gd	:= FwFormStruct( 2, 'T2G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

		If FindFunction("TafAjustRecibo")
			TafAjustRecibo(oStruT2Gd,"T2G")
		EndIf
		
		/*--------------------------------------------------------------------------------------------
											Esrutura da View
		---------------------------------------------------------------------------------------------*/
		oView:AddField( 'VIEW_T2Ga' , oStruT2Ga, 'MODEL_T2G' )
		oView:EnableTitleView("VIEW_T2Ga",STR0004) //Id. do Evento de Retorno

		oView:AddField( 'VIEW_T2Gb' , oStruT2Gb, 'MODEL_T2G' )
		oView:EnableTitleView("VIEW_T2Gb",STR0005) //Id. do Trabalhador

		oView:AddField( 'VIEW_T2Gc', oStruT2Gc, 'MODEL_T2G' )
		oView:EnableTitleView( 'VIEW_T2Gc', STR0022 ) // "Inf. Dependentes do Beneficiário do Pagamento."

		oView:AddField( 'VIEW_T2Gd', oStruT2Gd, 'MODEL_T2G' )
		oView:EnableTitleView( 'VIEW_T2Gd', TafNmFolder("recibo",1) ) // "Recibo da última Transmissão"

		oView:AddGrid ( 'VIEW_T2H' , oStruT2H, 'MODEL_T2H' )
		oView:EnableTitleView( 'VIEW_T2H', STR0023 ) // "Inf. IRRF do Trabalhador e Complementares do Benef. Resid. Ext."
		oView:AddIncrementField( 'VIEW_T2H', 'T2H_SEQUEN' )

		oView:AddGrid ( 'VIEW_T2I' , oStruT2I, 'MODEL_T2I' )
		oView:EnableTitleView( 'VIEW_T2I', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"

		oView:AddGrid ( 'VIEW_T2J' , oStruT2J, 'MODEL_T2J' )
		oView:EnableTitleView( 'VIEW_T2J', STR0015 ) // "Inf. Relativas ao Imposto de Renda Retido na Fonte"

		/*-----------------------------------------------------------------------------------
										Estrutura do Folder
		-------------------------------------------------------------------------------------*/
		oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )

		oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0024 ) //"Imp. de Renda Retido do Benef. do Rendimento"

		oView:CreateHorizontalBox( 'T2Ga', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'T2Gb', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'T2Gc', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )

		oView:CreateHorizontalBox("PAINEL_INFERIOR",064,,,"FOLDER_SUPERIOR","ABA01")
		oView:CreateFolder( 'FOLDER_IRRF', 'PAINEL_INFERIOR' )

		oView:AddSheet( 'FOLDER_IRRF', 'ABA01', STR0025) //"Inf. do IRRF"

		oView:CreateHorizontalBox( 'T2H', 50,,, 'FOLDER_IRRF', 'ABA01' )

		oView:CreateHorizontalBox  ( 'PAINEL_INFO_IRRF', 50,,, 'FOLDER_IRRF', 'ABA01' )
		oView:CreateFolder( 'FOLDER_INFO_IRRF', 'PAINEL_INFO_IRRF' )

		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA01', STR0026) //"Bases do IRRF"
		oView:CreateHorizontalBox( 'T2I', 100,,, 'FOLDER_INFO_IRRF', 'ABA01' )

		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA02', STR0027) //"IRRF"
		oView:CreateHorizontalBox( 'T2J', 100,,, 'FOLDER_INFO_IRRF', 'ABA02' )

		oView:AddSheet('FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
		
		oView:CreateHorizontalBox( 'T2Gd', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )

		oView:SetOwnerView( 'VIEW_T2Ga' , 'T2Ga')
		oView:SetOwnerView( 'VIEW_T2Gb' , 'T2Gb')
		oView:SetOwnerView( 'VIEW_T2Gc' , 'T2Gc')
		oView:SetOwnerView( 'VIEW_T2Gd' , 'T2Gd')
		oView:SetOwnerView( 'VIEW_T2H'  , 'T2H' )
		oView:SetOwnerView( 'VIEW_T2I'  , 'T2I' )
		oView:SetOwnerView( 'VIEW_T2J'  , 'T2J' )

		///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If !lMenuDif

			xFunRmFStr(@oStruT2Ga,"T2G")
			xFunRmFStr(@oStruT2Gb,"T2G")
			xFunRmFStr(@oStruT2Gc,"T2G")
			xFunRmFStr(@oStruT2Gd,"T2G")
			xFunRmFStr(@oStruT2H,"T2H")
			xFunRmFStr(@oStruT2I,"T2I")
			xFunRmFStr(@oStruT2J,"T2J")

			oStruT2H:RemoveField('T2H_ID')
			oStruT2I:RemoveField('T2I_ID')
			oStruT2J:RemoveField('T2J_ID')

			oStruT2I:RemoveField("T2I_CODCAT")
			oStruT2J:RemoveField("T2J_CODCAT")

			If TAFColumnPos("T2J_CODREC")

				//Ordem dos campos na tela
				oStruT2J:SetProperty("T2J_CODREC"	, MVC_VIEW_ORDEM, "01"	)
				oStruT2J:SetProperty("T2J_CTPCR"	, MVC_VIEW_ORDEM, "02"	)
				oStruT2J:SetProperty("T2J_DTPCR"	, MVC_VIEW_ORDEM, "03"	)

			EndIf

		EndIf

	ElseIf (lLaySimplif .Or. lSimpl12) .And. ( !lSimpl0103 .OR. !TafColumnPos("V7N_FRMTRI") )

		// Campos do folder Identificação do evento de retorno
		cCmpFil		:= "T2G_ID|T2G_VERSAO|T2G_RECBAS|T2G_PERAPU|"
		oStruT2Ga	:= FwFormStruct( 2, "T2G", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		//Campos do folder Identificação do trabalhador
		cCmpFil 	:= "T2G_CPFBEN|"
		oStruT2Gb	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		cCmpFil 	:= "V6J_PERREF|V6J_INDDEV|V6J_TPPAG|V6J_DTPAG|V6J_CODCAT|V6J_DCODCA|"
		oStruV6J	:= FwFormStruct( 2, "V6J", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil 	:= "V7M_CRMEN|V7M_VLMEN|"
		cCmpFil 	+= IIf(lSimpl12,"","V7M_VLSUSP|")
		oStruV7M	:= FwFormStruct( 2, "V7M", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		cCmpFil 	:= "V7N_PERDIA|V7N_CRDIA|V7N_VLCRD|V7N_VLCRD|"
		cCmpFil 	+= IIf(lSimpl12,"","V7N_VLSUS|")
		oStruV7N	:= FwFormStruct( 2, "V7N", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		If lSimpl12 
		
			cCmpFil 	:= 'T2G_DTLAUD|' 
			oStruT2Ge 	:= FwFormStruct( 2, 'T2G', {|x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V8J_NRPROC|V8J_UFVARA|V8J_CODMUN|V8J_IDVARA|"
			oStruV8J	:= FwFormStruct( 2, "V8J", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V8T_SEQRRA|V8T_TPPROC|V8T_NRPRRA|V8T_DESCRA|V8T_QTMRRA|"
			oStruV8T	:= FwFormStruct( 2, "V8T", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V52_SEQDPJ|V52_VLDEPC|V52_VLDADV|"
			oStruV52	:= FwFormStruct( 2, "V52", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V53_TPINSC|V53_NRINSC|V53_VLRADV|"
			oStruV53	:= FwFormStruct( 2, "V53", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V8H_PAISEX|V8H_INDNIF|V8H_NIFBEN|V8H_FRMTRI|V8H_ENDLOG|V8H_ENDNUM|V8H_ENDCOM|V8H_ENDBAI|V8H_ENDCID|V8H_ENDEST|V8H_CODPOS|V8H_ENDTEL|"
			oStruV8H	:= FwFormStruct( 2, "V8H", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V8V_CPFDEP|V8V_DEPIRR|V8V_DTNASC|V8V_NOME|V8V_TPDEP|V8V_DESCDE|"
			oStruV8V	:= FwFormStruct( 2, "V8V", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V60_TPCR|V60_DTPCR|"
			oStruV60	:= FwFormStruct( 2, "V60", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V61_TPREND|V61_CPFDEP|V61_VLRDED|"
			oStruV61	:= FwFormStruct( 2, "V61", { |x| AllTrim( x ) + "|" $ cCmpFil } )
			SetFieldUsed(oStruV61,"V61_VLRDED",2)

			cCmpFil 	:= "V62_TPREND|V62_CPFDEP|V62_VLPEN|"
			oStruV62	:= FwFormStruct( 2, "V62", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V63_TPREV|V63_INSCPL|V63_VLCOMP|V63_VLPATR|"
			oStruV63	:= FwFormStruct( 2, "V63", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V64_TPPROC|V64_NRPROC|V64_CODSUP|"
			oStruV64	:= FwFormStruct( 2, "V64", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V65_INDAPU|V65_VLRRET|V65_VLRJUD|V65_VLACAL|V65_VLAANT|V65_VLSUSP|"
			oStruV65	:= FwFormStruct( 2, "V65", { |x| AllTrim( x ) + "|" $ cCmpFil } )
			SetFieldUsed(oStruV65,"V65_VLACAL",2)
			
			cCmpFil 	:= "V66_SEQUEN|V66_TPDEDU|V66_VLSUSP|V66_INSCPL|V66_VLFUNP|"
			oStruV66	:= FwFormStruct( 2, "V66", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V67_CPFDEP|V67_VLSUSP|"
			oStruV67	:= FwFormStruct( 2, "V67", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V68_CNPJOP|V68_REGANS|V68_VLRTIT|"
			oStruV68	:= FwFormStruct( 2, "V68", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V69_CPFDEP|V69_VLRDEP|"
			oStruV69	:= FwFormStruct( 2, "V69", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V6A_SEQUEN|V6A_INDREM|V6A_CNPJOP|V6A_REGANS|"
			oStruV6A	:= FwFormStruct( 2, "V6A", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V54_TPINSC|V54_NRINSC|V54_VLREMB|V54_VLRANT|"
			oStruV54	:= FwFormStruct( 2, "V54", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V50_CPFDEP|"
			oStruV50	:= FwFormStruct( 2, "V50", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V51_TPINSC|V51_NRINSC|V51_VLREMB|V51_VLRANT|"
			oStruV51	:= FwFormStruct( 2, "V51", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			oView:AddField( 'VIEW_T2Ge', oStruT2Ge, 'MODEL_T2G' )
			oView:EnableTitleView("VIEW_T2Ge", STR0037 ) // "Data da moléstia grave atribuída pelo laudo"

		EndIf

		oView:AddField( 'VIEW_T2Ga', oStruT2Ga, 'MODEL_T2G' )
		oView:EnableTitleView( "VIEW_T2Ga", STR0004 ) // "Id. do Evento de Retorno"

		oView:AddField( 'VIEW_T2Gb', oStruT2Gb, 'MODEL_T2G' )
		oView:EnableTitleView("VIEW_T2Gb", STR0005) // "Id. do Trabalhador"

		oView:AddGrid( 'VIEW_V6J' , oStruV6J, 'MODEL_V6J' )
		oView:EnableTitleView( 'VIEW_V6J', STR0028 ) // "Informações do demonstrativo de valores devidos"

		oView:AddGrid( 'VIEW_V7M' , oStruV7M, 'MODEL_V7M' )
		oView:EnableTitleView( 'VIEW_V7M', STR0028 ) // "Informações do demonstrativo de valores devidos"

		oView:AddGrid( 'VIEW_V7N' , oStruV7N, 'MODEL_V7N' )
		oView:EnableTitleView( 'VIEW_V7N', STR0028 ) // "Informações do demonstrativo de valores devidos"*/

		oView:AddGrid( 'VIEW_T2I' , oStruT2I, 'MODEL_T2I' )
		oView:EnableTitleView( 'VIEW_T2I', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"
						
		If lSimpl12

			oView:AddGrid( 'VIEW_V8J' , oStruV8J, 'MODEL_V8J' )
			oView:EnableTitleView( 'VIEW_V8J', STR0042 ) // "Demais rendimentos com exigibilidade suspensa decorrentes de decisão judicial aplicável à rubrica"
			oView:AddGrid( 'VIEW_V8T' , oStruV8T, 'MODEL_V8T' )
			oView:AddGrid( 'VIEW_V52' , oStruV52, 'MODEL_V52' )
			oView:AddGrid( 'VIEW_V53' , oStruV53, 'MODEL_V53' )
			oView:AddGrid( 'VIEW_V8H' , oStruV8H, 'MODEL_V8H' )
			oView:EnableTitleView( 'VIEW_V8H', STR0041 ) // "Pagamentos a Residente Fiscal no Exterior"
			oView:AddGrid( 'VIEW_V8V' , oStruV8V, 'MODEL_V8V' )
			oView:AddGrid( 'VIEW_V60' , oStruV60, 'MODEL_V60' )
			oView:AddGrid( 'VIEW_V61' , oStruV61, 'MODEL_V61' )
			oView:AddGrid( 'VIEW_V62' , oStruV62, 'MODEL_V62' )
			oView:AddGrid( 'VIEW_V63' , oStruV63, 'MODEL_V63' )
			oView:AddGrid( 'VIEW_V64' , oStruV64, 'MODEL_V64' )
			oView:AddGrid( 'VIEW_V65' , oStruV65, 'MODEL_V65' )
			oView:EnableTitleView( 'VIEW_V65', STR0045) //Informações de valores relacionados a não retenção de tributos ou a depósitos judiciais
			oView:AddGrid( 'VIEW_V66' , oStruV66, 'MODEL_V66' )
			oView:EnableTitleView( 'VIEW_V66', STR0046) //Detalhamento das deduções com exigibilidade suspensa
			oView:AddGrid( 'VIEW_V67' , oStruV67, 'MODEL_V67' )
			oView:EnableTitleView( 'VIEW_V67', STR0047) //Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia
			oView:AddGrid( 'VIEW_V68' , oStruV68, 'MODEL_V68' )
			oView:AddGrid( 'VIEW_V69' , oStruV69, 'MODEL_V69' )
			oView:EnableTitleView( 'VIEW_V69', ) //Informações de dependente de plano de saúde coletivo empresarial
			oView:AddGrid( 'VIEW_V6A' , oStruV6A, 'MODEL_V6A' )
			oView:AddGrid( 'VIEW_V54' , oStruV54, 'MODEL_V54' )
			oView:AddGrid( 'VIEW_V50' , oStruV50, 'MODEL_V50' )
			oView:AddGrid( 'VIEW_V51' , oStruV51, 'MODEL_V51' )
			oView:EnableTitleView( 'VIEW_V51', STR0048) //Informação de reembolso do titular do plano de saúde coletivo empresarial

		EndIf 
						
		oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
		oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0024 ) // "Imp. de Renda Retido do Benef. do Rendimento"
		
		If lLaySimplif .And. !lSimpl12 //somente <= que v1.1  
			
			oView:CreateHorizontalBox( 'T2Ga', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'T2Gb', 012,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'V6J',  038,,, 'FOLDER_SUPERIOR', 'ABA01' )

		ElseIf  lSimpl12
			
			oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0038 ) // "Demonstrativo de Valores Devidos" 
			oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', STR0039 ) // "Informações complementares"

			oView:CreateHorizontalBox( 'T2Ga', 050,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'T2Gb', 050,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'V6J',  050,,, 'FOLDER_SUPERIOR', 'ABA02' )
			oView:CreateHorizontalBox( 'T2Ge', 030,,, 'FOLDER_SUPERIOR', 'ABA03' )
		
			oView:CreateHorizontalBox( 'IFOCOMPLEM', 060,,, 'FOLDER_SUPERIOR', 'ABA03' )
			oView:CreateFolder( 'FOLDER_IFOCOMPLEM', 'IFOCOMPLEM' )
			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA01', STR0044 ) //"Identificação dos Dependentes"
			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA02', STR0049 ) //"Info. IR por Código de Receita"
			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA03', STR0050 ) //Plano de saúde coletivo
			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA04', STR0051 ) //"Informações relativas a reembolsos efetuados no período de apuração"
			
			oView:CreateHorizontalBox( 'V8V',  100,,, 'FOLDER_IFOCOMPLEM', 'ABA01' )
			oView:CreateHorizontalBox( 'V60',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA02' )

			//grupo infoIRComplem/infoIrCr
			oView:CreateHorizontalBox( 'BOX_INFOIRCR',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA02' )
			oView:CreateFolder( 'FOLDER_INFOIRCR', 'BOX_INFOIRCR'  )
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA01', STR0052 ) //Dedução do rendimento tributável relativa a dependentes
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA02', STR0053 ) //Beneficiários da pensão alimentícia
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA03', STR0054 ) //Planos de previdência complementar
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA04', STR0055 ) //Processos relacionados a não retenção de tributos'

			oView:CreateHorizontalBox( 'V61',  100,,, 'FOLDER_INFOIRCR', 'ABA01' )
			oView:CreateHorizontalBox( 'V62',  100,,, 'FOLDER_INFOIRCR', 'ABA02' )
			oView:CreateHorizontalBox( 'V63',  100,,, 'FOLDER_INFOIRCR', 'ABA03' )
			
			//grupo infoIRComplem/infoIrCr/infoProcRet
			oView:CreateHorizontalBox( 'V64',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )
			oView:CreateHorizontalBox( 'V65',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )
			oView:CreateHorizontalBox( 'V66',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )
			oView:CreateHorizontalBox( 'V67',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )

			//infoIRComplem/planSaude
			oView:CreateHorizontalBox( 'V68',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA03' )
			//infoIRComplem/planSaude/infoDepSau
			oView:CreateHorizontalBox( 'V69',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA03' )

			//infoIRComplem/infoReembMed
			oView:CreateHorizontalBox( 'V6A', 050,,, 'FOLDER_IFOCOMPLEM', 'ABA04' )
			oView:CreateHorizontalBox( 'BOX_INFOREEMBMED',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA04' )
			oView:CreateFolder('FOLDER_INFOREEMBMED', 'BOX_INFOREEMBMED')
			oView:AddSheet( 'FOLDER_INFOREEMBMED', 'ABA01', STR0056 ) 
			oView:AddSheet( 'FOLDER_INFOREEMBMED', 'ABA02', STR0057 )

			oView:CreateHorizontalBox( 'V54', 100,,, 'FOLDER_INFOREEMBMED', 'ABA01' )

			//infoIRComplem/infoReembMed/detReembTit
			oView:CreateHorizontalBox( 'V50', 050,,, 'FOLDER_INFOREEMBMED', 'ABA02' )
			oView:CreateHorizontalBox( 'V51', 050,,, 'FOLDER_INFOREEMBMED', 'ABA02' )

		EndIf 
		
		oView:CreateHorizontalBox( "PAINEL_INFERIOR" ,IIf(lSimpl12,050,038),,, "FOLDER_SUPERIOR", IIf(lSimpl12,"ABA02","ABA01") )
		oView:CreateFolder( 'FOLDER_INFERIOR', 'PAINEL_INFERIOR' )

		oView:AddSheet( 'FOLDER_INFERIOR', 'ABA01', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"
		oView:AddSheet( 'FOLDER_INFERIOR', 'ABA02', STR0035)
		oView:AddSheet( 'FOLDER_INFERIOR', 'ABA03', STR0036) 
		
		If lSimpl12 

			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA04', STR0040 ) //Rendimentos Recebidos Acumuladamente - RRA
			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA05', STR0041 ) //Pagamentos a Residente Fiscal no Exterior

		EndIf 

		oView:CreateHorizontalBox( 'T2I',  IIf(lSimpl12,020,033),,, 'FOLDER_INFERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'V7M',  IIf(lSimpl12,020,033),,, 'FOLDER_INFERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'V7N',  IIf(lSimpl12,020,033),,, 'FOLDER_INFERIOR', 'ABA03' )
			
		If lSimpl12 
		
			oView:CreateHorizontalBox( 'V8T',  050,,, 'FOLDER_INFERIOR', 'ABA04' )
			oView:CreateHorizontalBox( 'BOX_INFORRA',  050,,, 'FOLDER_INFERIOR', 'ABA04' )
			oView:CreateFolder('FOLDER_INFORRA', 'BOX_INFORRA')
			oView:AddSheet( 'FOLDER_INFORRA', 'ABA01', STR0058 ) //Detalhamento das despesas com processo judicial.
			oView:AddSheet( 'FOLDER_INFORRA', 'ABA02', STR0059 ) //Identificação dos advogados.
			oView:CreateHorizontalBox( 'V52',100,,,'FOLDER_INFORRA','ABA01' )
			oView:CreateHorizontalBox( 'V53',100,,,'FOLDER_INFORRA','ABA02' )
			
			oView:CreateHorizontalBox( 'V8H',020,,,'FOLDER_INFERIOR','ABA05' )
			oView:CreateHorizontalBox( 'V8J',019,,,'FOLDER_INFERIOR','ABA01' )

		EndIf 

		oView:SetOwnerView( 'VIEW_T2Ga' , 'T2Ga')
		oView:SetOwnerView( 'VIEW_T2Gb' , 'T2Gb')
		oView:SetOwnerView( 'VIEW_V6J'  , 'V6J' )
		oView:SetOwnerView( 'VIEW_V7M'  , 'V7M' )
		oView:SetOwnerView( 'VIEW_V7N'  , 'V7N' )
		oView:SetOwnerView( 'VIEW_T2I'  , 'T2I' )

		If lSimpl12 

			oView:SetOwnerView( 'VIEW_T2Ge' , 'T2Ge')
			oView:SetOwnerView( 'VIEW_V8H'  , 'V8H' )
			oView:SetOwnerView( 'VIEW_V8J'  , 'V8J' )
			oView:SetOwnerView( 'VIEW_V8T'  , 'V8T' )
			oView:SetOwnerView( 'VIEW_V52'  , 'V52' )
			oView:SetOwnerView( 'VIEW_V53'  , 'V53' )
			oView:SetOwnerView( 'VIEW_V8V'  , 'V8V' )
			oView:SetOwnerView( 'VIEW_V60'  , 'V60' )
			oView:SetOwnerView( 'VIEW_V61'  , 'V61' )
			oView:SetOwnerView( 'VIEW_V62'  , 'V62' )
			oView:SetOwnerView( 'VIEW_V63'  , 'V63' )
			oView:SetOwnerView( 'VIEW_V64'  , 'V64' )
			oView:SetOwnerView( 'VIEW_V65'  , 'V65' )
			oView:SetOwnerView( 'VIEW_V66'  , 'V66' )
			oView:SetOwnerView( 'VIEW_V67'  , 'V67' )
			oView:SetOwnerView( 'VIEW_V68'  , 'V68' )
			oView:SetOwnerView( 'VIEW_V69'  , 'V69' )
			oView:SetOwnerView( 'VIEW_V6A'  , 'V6A' )
			oView:SetOwnerView( 'VIEW_V54'  , 'V54' )
			oView:SetOwnerView( 'VIEW_V50'  , 'V50' )
			oView:SetOwnerView( 'VIEW_V51'  , 'V51' )

		EndIf 
		
		oStruT2I:SetProperty( "T2I_CTPVAL", MVC_VIEW_LOOKUP, "C8U" )

		///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If !lMenuDif

			xFunRmFStr(@oStruT2Ga, "T2G")
			xFunRmFStr(@oStruT2Gb, "T2G")
			xFunRmFStr(@oStruV6J,  "V6J")

			If TafColumnPos("V7M_FILIAL")
				xFunRmFStr(@oStruV7M,  "V7M")
				xFunRmFStr(@oStruV7N,  "V7N")
			EndIf

			xFunRmFStr(@oStruT2I,  "T2I")

			oStruV6J:RemoveField( "V6J_ID" 		)
			oStruT2I:RemoveField( "T2I_ID" 		)
			oStruT2I:RemoveField( "T2I_CODCAT" 	)	
			oStruT2I:RemoveField( "T2I_PERREF" 	)	
			oStruT2I:RemoveField( "T2I_INDDEV" 	)	
			oStruT2I:RemoveField( "T2I_TPPAG" 	)	

			If !lSimpl0103 .And. TafColumnPos("T2I_DESCRE")
				oStruT2I:RemoveField( "T2I_DESCRE" 	)
			EndIf	

		EndIf

	ElseIf lSimpl0103 .And. TafColumnPos("V7N_FRMTRI")

		// Campos do folder Identificação do evento de retorno
		cCmpFil		:= "T2G_ID|T2G_VERSAO|T2G_RECBAS|T2G_PERAPU|"
		oStruT2Ga	:= FwFormStruct( 2, "T2G", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		//Campos do folder Identificação do trabalhador
		cCmpFil 	:= "T2G_CPFBEN|"
		oStruT2Gb	:= FwFormStruct(2,"T2G",{|x| AllTrim(x) + "|" $ cCmpFil })

		cCmpFil 	:= "V6J_PERREF|V6J_INDDEV|V6J_TPPAG|V6J_DTPAG|V6J_CODCAT|V6J_DCODCA|"
		oStruV6J	:= FwFormStruct( 2, "V6J", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		If lSimpl0103 .And. TafColumnPos("V7M_RENDTR")
			cCmpFil 	:= "V7M_CRMEN|V7M_RENDTR|V7M_REND13|V7M_PREVOF|V7M_PREV13|V7M_VLMEN|V7M_VMEN13|"
			cCmpFil 	+= "V7M_PARI65|V7M_I65DEC|V7M_VLRDIA|V7M_VLRAJU|V7M_VLRCON|V7M_VLRABN|V7M_VLRIMG|"
			cCmpFil		+= "V7M_IMG13|V7M_VLMORD|V7M_BOLMED|V7M_BOLM13|V7M_JURMOR|V7M_ISEOUT|V7M_DESCRE|"
		Else
			cCmpFil 	:= "V7M_CRMEN|V7M_VLMEN|"
		EndIf	

		cCmpFil 	+= IIf(lSimpl0103 ,"","V7M_VLSUSP|")
		oStruV7M	:= FwFormStruct( 2, "V7M", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		If lSimpl0103 
			cCmpFil 	:= "V7N_PERDIA|V7N_CRDIA|V7N_FRMTRI|V7N_PAISEX|V7N_PAGDIA|V7N_VLCRD|"
		Else
			cCmpFil 	:= "V7N_PERDIA|V7N_CRDIA|V7N_VLCRD|V7N_VLCRD|"
		EndIf	

		cCmpFil 	+= IIf(lSimpl0103,"","V7N_VLSUS|")
		oStruV7N	:= FwFormStruct( 2, "V7N", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		If lSimpl0103 .And. TafColumnPos("V8J_NRPROC")

			cCmpFil 	:= "V8J_NRPROC|V8J_UFVARA|V8J_CODMUN|V8J_IDVARA|"
			oStruV8J	:= FwFormStruct( 2, "V8J", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V8T_SEQRRA|V8T_TPPROC|V8T_NRPRRA|V8T_DESCRA|V8T_QTMRRA|"
			oStruV8T	:= FwFormStruct( 2, "V8T", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V52_SEQDPJ|V52_VLDEPC|V52_VLDADV|"
			oStruV52	:= FwFormStruct( 2, "V52", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V53_TPINSC|V53_NRINSC|V53_VLRADV|"
			oStruV53	:= FwFormStruct( 2, "V53", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V8H_PAISEX|V8H_INDNIF|V8H_NIFBEN|V8H_FRMTRI|V8H_ENDLOG|V8H_ENDNUM|V8H_ENDCOM|V8H_ENDBAI|V8H_ENDCID|V8H_ENDEST|V8H_CODPOS|V8H_ENDTEL|"
			oStruV8H	:= FwFormStruct( 2, "V8H", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V8V_CPFDEP|V8V_DEPIRR|V8V_DTNASC|V8V_NOME|V8V_TPDEP|V8V_DESCDE|"
			oStruV8V	:= FwFormStruct( 2, "V8V", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V60_TPCR|V60_DTPCR|"
			oStruV60	:= FwFormStruct( 2, "V60", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V61_TPREND|V61_CPFDEP|V61_VLRDED|"
			oStruV61	:= FwFormStruct( 2, "V61", { |x| AllTrim( x ) + "|" $ cCmpFil } )
			SetFieldUsed(oStruV61,"V61_VLRDED",2)

			cCmpFil 	:= "V62_TPREND|V62_CPFDEP|V62_VLPEN|"
			oStruV62	:= FwFormStruct( 2, "V62", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			If lSimpl0103 .And. TafColumnPos("V63_VLCO13")
				cCmpFil 	:= "V63_TPREV|V63_INSCPL|V63_VLCOMP|V63_VLCO13|V63_VLPATR|V63_VLPA13|"
			Else
				cCmpFil 	:= "V63_TPREV|V63_INSCPL|V63_VLCOMP|V63_VLPATR|"
			EndIf	
			oStruV63	:= FwFormStruct( 2, "V63", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V64_TPPROC|V64_NRPROC|V64_CODSUP|"
			oStruV64	:= FwFormStruct( 2, "V64", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V65_INDAPU|V65_VLRRET|V65_VLRJUD|V65_VLACAL|V65_VLAANT|V65_VLSUSP|"
			oStruV65	:= FwFormStruct( 2, "V65", { |x| AllTrim( x ) + "|" $ cCmpFil } )
			SetFieldUsed(oStruV65,"V65_VLACAL",2)
			
			cCmpFil 	:= "V66_SEQUEN|V66_TPDEDU|V66_VLSUSP|V66_INSCPL|V66_VLFUNP|"
			oStruV66	:= FwFormStruct( 2, "V66", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V67_CPFDEP|V67_VLSUSP|"
			oStruV67	:= FwFormStruct( 2, "V67", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V68_CNPJOP|V68_REGANS|V68_VLRTIT|"
			oStruV68	:= FwFormStruct( 2, "V68", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V69_CPFDEP|V69_VLRDEP|"
			oStruV69	:= FwFormStruct( 2, "V69", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V6A_SEQUEN|V6A_INDREM|V6A_CNPJOP|V6A_REGANS|"
			oStruV6A	:= FwFormStruct( 2, "V6A", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V54_TPINSC|V54_NRINSC|V54_VLREMB|V54_VLRANT|"
			oStruV54	:= FwFormStruct( 2, "V54", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V50_CPFDEP|"
			oStruV50	:= FwFormStruct( 2, "V50", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "V51_TPINSC|V51_NRINSC|V51_VLREMB|V51_VLRANT|"
			oStruV51	:= FwFormStruct( 2, "V51", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		EndIf

		If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")	

			cCmpFil 	:= "T8G_CRMEN|T8G_RENDTR|T8G_RENT13|T8G_PREVOF|T8G_PROF13|T8G_VCRMEN|T8G_CR13ME|T8G_PAIS65|T8G_PIS65D|"
			cCmpFil 	+= "T8G_VLDIAR|T8G_VLAJUC|T8G_VINRES|T8G_ABONPE|T8G_VLRIMG|T8G_IMG13|T8G_VLMORD|T8G_BOLMED|T8G_BOLM13|T8G_JURMOR|T8G_ISEOUT|T8G_DESCRE|"
			oStruT8G	:= FwFormStruct( 2, "T8G", { |x| AllTrim( x ) + "|" $ cCmpFil } )

			cCmpFil 	:= "T8H_PERREF|T8H_NR1210|T8H_DTLAUD|"
			oStruT8H	:= FwFormStruct( 2, "T8H", { |x| AllTrim( x ) + "|" $ cCmpFil } )

		EndIf
		
		oView:AddField( 'VIEW_T2Ga', oStruT2Ga, 'MODEL_T2G' )
		oView:EnableTitleView( "VIEW_T2Ga", STR0004 ) // "Id. do Evento de Retorno"

		oView:AddField( 'VIEW_T2Gb', oStruT2Gb, 'MODEL_T2G' )
		oView:EnableTitleView("VIEW_T2Gb", STR0005) // "Id. do Trabalhador"

		oView:AddGrid( 'VIEW_V6J' , oStruV6J, 'MODEL_V6J' )
		oView:EnableTitleView( 'VIEW_V6J', STR0028 ) // "Informações do demonstrativo de valores devidos"

		oView:AddGrid( 'VIEW_V7M' , oStruV7M, 'MODEL_V7M' )
		oView:EnableTitleView( 'VIEW_V7M', STR0063 ) // "Totalizador dos rendimentos tributáveis, deduções, isenções e retenção de tributos com período de apuração mensal"

		oView:AddGrid( 'VIEW_V7N' , oStruV7N, 'MODEL_V7N' )
		oView:EnableTitleView( 'VIEW_V7N', STR0064 ) // "Totalizador de rendimentos tributáveis e tributos com período de apuração diário"*/

		oView:AddGrid( 'VIEW_T2I' , oStruT2I, 'MODEL_T2I' )
		oView:EnableTitleView( 'VIEW_T2I', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"
						
		If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")

			oView:AddGrid( 'VIEW_V8J' , oStruV8J, 'MODEL_V8J' )
			oView:EnableTitleView( 'VIEW_V8J', STR0042 ) // "Demais rendimentos com exigibilidade suspensa decorrentes de decisão judicial aplicável à rubrica"
			oView:AddGrid( 'VIEW_V8T' , oStruV8T, 'MODEL_V8T' )
			oView:AddGrid( 'VIEW_V52' , oStruV52, 'MODEL_V52' )
			oView:AddGrid( 'VIEW_V53' , oStruV53, 'MODEL_V53' )
			oView:AddGrid( 'VIEW_V8H' , oStruV8H, 'MODEL_V8H' )
			oView:EnableTitleView( 'VIEW_V8H', STR0041 ) // "Pagamentos a Residente Fiscal no Exterior"
			oView:AddGrid( 'VIEW_V8V' , oStruV8V, 'MODEL_V8V' )
			oView:AddGrid( 'VIEW_V60' , oStruV60, 'MODEL_V60' )
			oView:AddGrid( 'VIEW_V61' , oStruV61, 'MODEL_V61' )
			oView:AddGrid( 'VIEW_V62' , oStruV62, 'MODEL_V62' )
			oView:AddGrid( 'VIEW_V63' , oStruV63, 'MODEL_V63' )
			oView:AddGrid( 'VIEW_V64' , oStruV64, 'MODEL_V64' )
			oView:AddGrid( 'VIEW_V65' , oStruV65, 'MODEL_V65' )
			oView:EnableTitleView( 'VIEW_V65', STR0045) //Informações de valores relacionados a não retenção de tributos ou a depósitos judiciais
			oView:AddGrid( 'VIEW_V66' , oStruV66, 'MODEL_V66' )
			oView:EnableTitleView( 'VIEW_V66', STR0046) //Detalhamento das deduções com exigibilidade suspensa
			oView:AddGrid( 'VIEW_V67' , oStruV67, 'MODEL_V67' )
			oView:EnableTitleView( 'VIEW_V67', STR0047) //Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia
			oView:AddGrid( 'VIEW_V68' , oStruV68, 'MODEL_V68' )
			oView:AddGrid( 'VIEW_V69' , oStruV69, 'MODEL_V69' )
			oView:EnableTitleView( 'VIEW_V69', ) //Informações de dependente de plano de saúde coletivo empresarial
			oView:AddGrid( 'VIEW_V6A' , oStruV6A, 'MODEL_V6A' )
			oView:AddGrid( 'VIEW_V54' , oStruV54, 'MODEL_V54' )
			oView:AddGrid( 'VIEW_V50' , oStruV50, 'MODEL_V50' )
			oView:AddGrid( 'VIEW_V51' , oStruV51, 'MODEL_V51' )
			oView:EnableTitleView( 'VIEW_V51', STR0048) //Informação de reembolso do titular do plano de saúde coletivo empresarial

			If lSimpl0103 .And. TafColumnPos("T8G_CRMEN") 

				oView:AddGrid( 'VIEW_T8H' , oStruT8H, 'MODEL_T8H' )
				oView:EnableTitleView( 'VIEW_T8H', STR0061 ) // "Identificação do evento S-1210 original"

				oView:AddGrid( 'VIEW_T8G' , oStruT8G, 'MODEL_T8G' )
				oView:EnableTitleView( 'VIEW_T8G', STR0062 ) // "Totalização dos rendimentos tributáveis, deduções e isenções com período de apuração mensal"
			EndIf
		EndIf 
						
		oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
		oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0024 ) // "Imp. de Renda Retido do Benef. do Rendimento"
		
		If  lSimpl0103 .And. TafColumnPos("T8G_CRMEN")
			
			oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0038 ) // "Demonstrativo de Valores Devidos" 
			oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', STR0062 ) // "Totalização dos rendimentos tributáveis, deduções e isenções com período de apuração mensal" 
			oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA04', STR0039 ) // "Informações complementares" 3

			oView:CreateHorizontalBox( 'T2Ga', 050,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'T2Gb', 050,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'V6J',  050,,, 'FOLDER_SUPERIOR', 'ABA02' )
			
			If TafColumnPos("T8G_RENDTR")
				oView:CreateHorizontalBox( 'T8G',  050,,, 'FOLDER_SUPERIOR', 'ABA03' )
			EndIf	
			
			oView:CreateHorizontalBox( 'T8H', 030,,, 'FOLDER_SUPERIOR', 'ABA04' ) //3
		
			oView:CreateHorizontalBox( 'IFOCOMPLEM', 060,,, 'FOLDER_SUPERIOR', 'ABA04' ) //3
			oView:CreateFolder( 'FOLDER_IFOCOMPLEM', 'IFOCOMPLEM' )

			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA02', STR0044 ) //"Identificação dos Dependentes"
			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA03', STR0049 ) //"Info. IR por Código de Receita"
			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA04', STR0050 ) //Plano de saúde coletivo
			oView:AddSheet( 'FOLDER_IFOCOMPLEM', 'ABA05', STR0051 ) //"Informações relativas a reembolsos efetuados no período de apuração"
			
			oView:CreateHorizontalBox( 'V8V',  100,,, 'FOLDER_IFOCOMPLEM', 'ABA02' ) 
			oView:CreateHorizontalBox( 'V60',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA03' )

			//grupo infoIRComplem/infoIrCr
			oView:CreateHorizontalBox( 'BOX_INFOIRCR',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA03' ) 
			oView:CreateFolder( 'FOLDER_INFOIRCR', 'BOX_INFOIRCR'  )
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA01', STR0052 ) //Dedução do rendimento tributável relativa a dependentes
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA02', STR0053 ) //Beneficiários da pensão alimentícia
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA03', STR0054 ) //Planos de previdência complementar
			oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA04', STR0055 ) //Processos relacionados a não retenção de tributos'

			oView:CreateHorizontalBox( 'V61',  100,,, 'FOLDER_INFOIRCR', 'ABA01' )
			oView:CreateHorizontalBox( 'V62',  100,,, 'FOLDER_INFOIRCR', 'ABA02' )
			oView:CreateHorizontalBox( 'V63',  100,,, 'FOLDER_INFOIRCR', 'ABA03' )
			
			//grupo infoIRComplem/infoIrCr/infoProcRet
			oView:CreateHorizontalBox( 'V64',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )
			oView:CreateHorizontalBox( 'V65',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )
			oView:CreateHorizontalBox( 'V66',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )
			oView:CreateHorizontalBox( 'V67',  025,,, 'FOLDER_INFOIRCR', 'ABA04' )

			//infoIRComplem/planSaude
			oView:CreateHorizontalBox( 'V68',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA04' ) 
			//infoIRComplem/planSaude/infoDepSau
			oView:CreateHorizontalBox( 'V69',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA04' ) 

			//infoIRComplem/infoReembMed
			oView:CreateHorizontalBox( 'V6A', 050,,, 'FOLDER_IFOCOMPLEM', 'ABA05' ) 
			oView:CreateHorizontalBox( 'BOX_INFOREEMBMED',  050,,, 'FOLDER_IFOCOMPLEM', 'ABA05' ) 
			oView:CreateFolder('FOLDER_INFOREEMBMED', 'BOX_INFOREEMBMED')
			oView:AddSheet( 'FOLDER_INFOREEMBMED', 'ABA01', STR0056 ) 
			oView:AddSheet( 'FOLDER_INFOREEMBMED', 'ABA02', STR0057 )

			oView:CreateHorizontalBox( 'V54', 100,,, 'FOLDER_INFOREEMBMED', 'ABA01' )

			//infoIRComplem/infoReembMed/detReembTit
			oView:CreateHorizontalBox( 'V50', 050,,, 'FOLDER_INFOREEMBMED', 'ABA02' )
			oView:CreateHorizontalBox( 'V51', 050,,, 'FOLDER_INFOREEMBMED', 'ABA02' )

		EndIf 
		
		oView:CreateHorizontalBox( "PAINEL_INFERIOR" ,IIf(lSimpl0103,050,038),,, "FOLDER_SUPERIOR", IIf(lSimpl0103,"ABA02","ABA01") )
		oView:CreateFolder( 'FOLDER_INFERIOR', 'PAINEL_INFERIOR' )

		oView:AddSheet( 'FOLDER_INFERIOR', 'ABA01', STR0017 ) // "Bases, deduções, isenções e retenções do IRRF"
		oView:AddSheet( 'FOLDER_INFERIOR', 'ABA02', STR0035)
		oView:AddSheet( 'FOLDER_INFERIOR', 'ABA03', STR0036) 
		
		If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")

			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA04', STR0040 ) //Rendimentos Recebidos Acumuladamente - RRA
			oView:AddSheet( 'FOLDER_INFERIOR', 'ABA05', STR0041 ) //Pagamentos a Residente Fiscal no Exterior
			
		EndIf 

		oView:CreateHorizontalBox( 'T2I',  IIf(lSimpl0103,020,033),,, 'FOLDER_INFERIOR', 'ABA01' )
		oView:CreateHorizontalBox( 'V7M',  IIf(lSimpl0103,020,033),,, 'FOLDER_INFERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'V7N',  IIf(lSimpl0103,020,033),,, 'FOLDER_INFERIOR', 'ABA03' )
			
		If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")
		
			oView:CreateHorizontalBox( 'V8T',  050,,, 'FOLDER_INFERIOR', 'ABA04' )
			oView:CreateHorizontalBox( 'BOX_INFORRA',  050,,, 'FOLDER_INFERIOR', 'ABA04' )
			oView:CreateFolder('FOLDER_INFORRA', 'BOX_INFORRA')
			oView:AddSheet( 'FOLDER_INFORRA', 'ABA01', STR0058 ) //Detalhamento das despesas com processo judicial.
			oView:AddSheet( 'FOLDER_INFORRA', 'ABA02', STR0059 ) //Identificação dos advogados.
			oView:CreateHorizontalBox( 'V52',100,,,'FOLDER_INFORRA','ABA01' )
			oView:CreateHorizontalBox( 'V53',100,,,'FOLDER_INFORRA','ABA02' )
			
			oView:CreateHorizontalBox( 'V8H',020,,,'FOLDER_INFERIOR','ABA05' )
			oView:CreateHorizontalBox( 'V8J',019,,,'FOLDER_INFERIOR','ABA01' )	

		EndIf 

		//oView:SetOwnerView( 'VIEW_V51'  , 'V51' )
		oView:SetOwnerView( 'VIEW_T2Ga' , 'T2Ga')
		oView:SetOwnerView( 'VIEW_T2Gb' , 'T2Gb')
		oView:SetOwnerView( 'VIEW_V6J'  , 'V6J' )
		oView:SetOwnerView( 'VIEW_V7M'  , 'V7M' )
		oView:SetOwnerView( 'VIEW_V7N'  , 'V7N' )
		oView:SetOwnerView( 'VIEW_T2I'  , 'T2I' )
		

		If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")

			oView:SetOwnerView( 'VIEW_V8H'  , 'V8H' )
			oView:SetOwnerView( 'VIEW_V8J'  , 'V8J' )
			oView:SetOwnerView( 'VIEW_V8T'  , 'V8T' )
			oView:SetOwnerView( 'VIEW_V52'  , 'V52' )
			oView:SetOwnerView( 'VIEW_V53'  , 'V53' )
			oView:SetOwnerView( 'VIEW_V8V'  , 'V8V' )
			oView:SetOwnerView( 'VIEW_V60'  , 'V60' )
			oView:SetOwnerView( 'VIEW_V61'  , 'V61' )
			oView:SetOwnerView( 'VIEW_V62'  , 'V62' )
			oView:SetOwnerView( 'VIEW_V63'  , 'V63' )
			oView:SetOwnerView( 'VIEW_V64'  , 'V64' )
			oView:SetOwnerView( 'VIEW_V65'  , 'V65' )
			oView:SetOwnerView( 'VIEW_V66'  , 'V66' )
			oView:SetOwnerView( 'VIEW_V67'  , 'V67' )
			oView:SetOwnerView( 'VIEW_V68'  , 'V68' )
			oView:SetOwnerView( 'VIEW_V69'  , 'V69' )
			oView:SetOwnerView( 'VIEW_V6A'  , 'V6A' )
			oView:SetOwnerView( 'VIEW_V54'  , 'V54' )
			oView:SetOwnerView( 'VIEW_V50'  , 'V50' )
			oView:SetOwnerView( 'VIEW_V51'  , 'V51' )

			If lSimpl0103 .And. TafColumnPos("T8G_CRMEN") 
				oView:SetOwnerView( 'VIEW_T8H'  , 'T8H' )
				oView:SetOwnerView( 'VIEW_T8G'  , 'T8G' )
			EndIf

		EndIf 
		
		oStruT2I:SetProperty( "T2I_CTPVAL", MVC_VIEW_LOOKUP, "C8U" )

		///Tratamento para que alguns campos de controle interno não sejam exibidos na tela
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If !lMenuDif

			xFunRmFStr(@oStruT2Ga, "T2G")
			xFunRmFStr(@oStruT2Gb, "T2G")
			xFunRmFStr(@oStruV6J,  "V6J")

			If TafColumnPos("V7M_FILIAL")
				xFunRmFStr(@oStruV7M,  "V7M")
				xFunRmFStr(@oStruV7N,  "V7N")
			EndIf

			If TafColumnPos("T8G_CRMEN")
				xFunRmFStr(@oStruT8H,  "T8H")
				xFunRmFStr(@oStruT8G,  "T8G")
			EndIf

			xFunRmFStr(@oStruT2I,  "T2I")

			oStruV6J:RemoveField( "V6J_ID" 		)
			oStruT2I:RemoveField( "T2I_ID" 		)
			oStruT2I:RemoveField( "T2I_CODCAT" 	)	
			oStruT2I:RemoveField( "T2I_PERREF" 	)	
			oStruT2I:RemoveField( "T2I_INDDEV" 	)	
			oStruT2I:RemoveField( "T2I_TPPAG" 	)

			If 	!lSimpl0103
				oStruT2I:RemoveField( "T2I_DESCRE" 		)
				oStruV7M:RemoveField( "V7M_RENDTR" 		)
				oStruV7M:RemoveField( "V7M_REND13" 		)
				oStruV7M:RemoveField( "V7M_PREVOF" 		)
				oStruV7M:RemoveField( "V7M_PREV13" 		)
				oStruV7M:RemoveField( "V7M_VMEN13" 		)
				oStruV7M:RemoveField( "V7M_PARI65" 		)
				oStruV7M:RemoveField( "V7M_I65DEC" 		)
				oStruV7M:RemoveField( "V7M_VLRDIA" 		)
				oStruV7M:RemoveField( "V7M_VLRAJU" 		)
				oStruV7M:RemoveField( "V7M_VLRCON" 		)
				oStruV7M:RemoveField( "V7M_VLRABN" 		)
				oStruV7M:RemoveField( "V7M_VLRIMG" 		)
				oStruV7M:RemoveField( "V7M_IMG13" 		)
				oStruV7M:RemoveField( "V7M_VLMORD" 		)
				oStruV7M:RemoveField( "V7M_BOLMED" 		)
				oStruV7M:RemoveField( "V7M_BOLM13" 		)
				oStruV7M:RemoveField( "V7M_JURMOR" 		)
				oStruV7M:RemoveField( "V7M_ISEOUT" 		)
				oStruV7M:RemoveField( "V7M_DESCRE" 		)
			EndIf

		EndIf
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@author Daniel Schmidt
@since 29/05/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel as Object ) as Logical

	Local lRetorno   as Logical
	Local nOperation as Numeric
	//Relatório de Conferência de Valores
	Local lInfoRPT   as Logical
	Local oInfoRPT   as Object

	lRetorno   := .T.
	lInfoRPT   := .F.
	oInfoRPT   := Nil
	nOperation := oModel:GetOperation()

	Begin Transaction

		If nOperation == MODEL_OPERATION_DELETE

			If __lGrvRPT == Nil
				TAF422Rpt() //Inicializa a variável static __lGrvRPT
			EndIf

			lInfoRPT := __lGrvRPT

			//Realiza a exclusão do registro da tabela do relatório
			If lInfoRPT

				If oReport == Nil
					oReport := TAFSocialReport():New()
				EndIf

				oInfoRPT := oReport:oVOReport
				oInfoRPT:SetIndApu( "1" )
				oInfoRPT:SetPeriodo( AllTrim( T2G->T2G_PERAPU ) )
				oInfoRPT:SetCPF( AllTrim( T2G->T2G_CPFBEN ) )

				oReport:UpSert("S-1210", "4", xFilial( "T2G" ), oInfoRPT, .T.)

			EndIf

			oModel:DeActivate()
			oModel:SetOperation( 5 )
			oModel:Activate()

		EndIf

		FwFormCommit( oModel )

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF422Grv

Funcao de gravacao para atender o registro S-5002

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Daniel Schmidt
@since 29/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF422Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character,;
					cFilTran as Character, cPredeces as Character, nTAFRecno as Numeric, cComplem as Character,;
					cGrpTran as Character, cEmpEnv as Character, cFilEnv as Character, cXmlID as Character,;
					cEvtOri as Character, lMigrador as Logical, lDepGPE as Logical, cKey as Character,;
					cMatrC9V as Character, lLaySmpTot as Logical, lExclCMJ as Logical, oTransf as Object,;
					cXml as Character, cAliEvtOri as Character, nRecEvtOri as Numeric ) as Array

	Local aChave        as Array
	Local aIncons       as Array
	Local aRules        as Array
	Local cCabec        as Character
	Local cChvV8TSequen as Character
	Local cCmpsNoUpd    as Character
	Local cDescTp       as Character
	Local cIdeDmDev     as Character
	Local cIdTpValor    as Character
	Local cInconMsg     as Character
	Local cLogOpeAnt    as Character
	Local cPeriodo      as Character
	Local cPerRef       as Character
	Local cRecibo       as Character
	Local cT2IPath      as Character
	Local cT8HPath      as Character
	Local cTpValor      as Character
	Local cV50Path      as Character
	Local cV51Path      as Character
	Local cV52Path      as Character
	Local cV53Path      as Character
	Local cV54Path      as Character
	Local cV60Path      as Character
	Local cV61Path      as Character
	Local cV62Path      as Character
	Local cV63Path      as Character
	Local cV64Path      as Character
	Local cV65Path      as Character
	Local cV66Path      as Character
	Local cV67Path      as Character
	Local cV68Path      as Character
	Local cV69Path      as Character
	Local cV6APath      as Character
	Local cV6JPath      as Character
	Local cV7MPath      as Character
	Local cV7NPath      as Character
	Local cV8HPath      as Character
	Local cV8IPath      as Character
	Local cV8JPath      as Character
	Local cV8TPath      as Character
	Local cV8UPath      as Character
	Local cV8VPath      as Character
	Local dDataPgto     as Date
	Local lRet          as Logical
	Local nI            as Numeric
	Local nIndChv       as Numeric
	Local nSeqErrGrv    as Numeric
	Local nT2H          as Numeric
	Local nT2I          as Numeric
	Local nT8H          as Numeric
	Local nV50          as Numeric
	Local nV51          as Numeric
	Local nV53          as Numeric
	Local nV54          as Numeric
	Local nV60          as Numeric
	Local nV61          as Numeric
	Local nV62          as Numeric
	Local nV63          as Numeric
	Local nV64          as Numeric
	Local nV65          as Numeric
	Local nV66          as Numeric
	Local nV67          as Numeric
	Local nV68          as Numeric
	Local nV69          as Numeric
	Local nV6A          as Numeric
	Local nV6J          as Numeric
	Local nV7M          as Numeric
	Local nV7N          as Numeric
	Local nV8H          as Numeric
	Local nV8I          as Numeric
	Local nV8J          as Numeric
	Local nV8T          as Numeric
	Local nV8U          as Numeric
	Local nV8V          as Numeric
	Local oModel        as Object

	//Relatório de Conferência de Valores
	Local aAnalitico  as Array
	Local cCPF        as Character
	Local cTpPgto     as Character
	Local lInfoRPT    as Logical
	Local nPosValores as Numeric
	Local oInfoRPT    as Object

	Private lVldModel as Logical //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	Private oDados    as Object

	Default cEvtOri := "S-1200"
	Default cFilEv  := ""
	Default cLayout := ""
	Default nOpc    := 1
	Default oXML    := Nil

	aAnalitico    := {}
	aChave        := {}
	aIncons       := {}
	aRules        := {}
	cCabec        := "/eSocial/evtIrrfBenef/"
	cChvV8TSequen := ""
	cCmpsNoUpd    := "|T2G_FILIAL|T2G_ID|T2G_VERSAO|T2G_VERANT|T2G_PROTUL|T2G_PROTPN|T2G_EVENTO|T2G_STATUS|T2G_ATIVO|"
	cCPF          := ""
	cDescTp       := ""
	cIdeDmDev     := ""
	cIdTpValor    := ""
	cInconMsg     := ""
	cLogOpeAnt    := ""
	cPeriodo      := ""
	cPerRef       := ""
	cRecibo       := ""
	cT2IPath      := ""
	cT8HPath      := ""
	cTpPgto       := ""
	cTpValor      := ""
	cV50Path      := ""
	cV51Path      := ""
	cV52Path      := ""
	cV53Path      := ""
	cV54Path      := ""
	cV60Path      := ""
	cV61Path      := ""
	cV62Path      := ""
	cV63Path      := ""
	cV64Path      := ""
	cV65Path      := ""
	cV66Path      := ""
	cV67Path      := ""
	cV68Path      := ""
	cV69Path      := ""
	cV6APath      := ""
	cV6JPath      := ""
	cV7MPath      := ""
	cV7NPath      := ""
	cV8HPath      := ""
	cV8IPath      := ""
	cV8JPath      := ""
	cV8TPath      := ""
	cV8UPath      := ""
	cV8VPath      := ""
	dDataPgto     := CtoD("//")
	lInfoRPT      := .F.
	lRet          := .F.
	lVldModel     := .T.
	nI            := 0
	nIndChv       := 2
	nPosValores   := 0
	nSeqErrGrv    := 0
	nT2H          := 0
	nT2I          := 0
	nT8H          := 0
	nV50          := 0
	nV51          := 0
	nV53          := 0
	nV54          := 0
	nV60          := 0
	nV61          := 0
	nV62          := 0
	nV63          := 0
	nV64          := 0
	nV65          := 0
	nV66          := 0
	nV67          := 0
	nV68          := 0
	nV69          := 0
	nV6A          := 0
	nV6J          := 0
	nV7M          := 0
	nV7N          := 0
	nV8H          := 0
	nV8I          := 0
	nV8J          := 0
	nV8T          := 0
	nV8U          := 0
	nV8V          := 0
	oDados        := oXML
	oInfoRPT      := Nil
	oModel        := Nil

	If IsInCallStack("TafPrepInt")

		lLaySimplif := lLaySmpTot

	Else 

		If lLaySimplif == Nil
			lLaySimplif := TafLayESoc("S_01_00_00")
		EndIf 

	EndIf	

	If lSimpl12 == Nil 
		lSimpl12 := TafLayESoc("S_01_02_00",, .T.)
	EndIf	

	If lSimpl0103 == Nil 
		lSimpl0103 := TafLayESoc("S_01_03_00",, .T.)
	EndIf 

	If __lGrvRPT == Nil
		TAF422Rpt() //Inicializa a variável static __lGrvRPT
	EndIf

	lInfoRPT := __lGrvRPT

	If lInfoRPT

		If oReport == Nil
			oReport := TAFSocialReport():New()
		EndIf

	EndIf

	cPeriodo := FTafGetVal( cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. )
	cRecibo  := FTafGetVal( cCabec + "ideEvento/nrRecArqBase", "C", .F., @aIncons, .F. )

	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "T2G_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
	Else
		Aadd( aChave, {"C", "T2G_PERAPU", cPeriodo  , .T.} )
	EndIf

	If !lLaySimplif
		Aadd( aChave, { "C", "T2G_CPFTRA", FTafGetVal( cCabec + "ideTrabalhador/cpfTrab" , "C", .F., @aIncons, .F. ), .T. } )
	Else
		Aadd( aChave, { "C", "T2G_CPFBEN", FTafGetVal( cCabec + "ideTrabalhador/cpfBenef" , "C", .F., @aIncons, .F. ), .T. } )
		nIndChv := 3
	EndIf
	
	Begin Transaction

		If FTafVldOpe( 'T2G', nIndChv, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA422', cCmpsNoUpd )

			cLogOpeAnt := T2G->T2G_LOGOPE
			aRules := TAF422Rul()

			oModel:LoadValue( "MODEL_T2G", "T2G_FILIAL", T2G->T2G_FILIAL )
			oModel:LoadValue( "MODEL_T2G", "T2G_DTLAUD", FTafGetVal( cCabec + "ideTrabalhador/infoIRComplem/dtLaudo" , "D", .F., @aIncons, .F. ) )

			For nI := 1 to Len( aRules )
				oModel:LoadValue( "MODEL_T2G", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
			Next nI

			TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T2G', 'T2G_LOGOPE' , '1', '' )
	
			If !lLaySimplif .and. !lSimpl12

				nT2H := 1
				cT2HPath := cCabec + "infoIrrf[" + AllTrim(Str(nT2H)) + "]"

				While oDados:XPathHasNode(cT2HPath)

					oModel:GetModel( "MODEL_T2H" ):lValid:= .T.

					If nT2H > 1
						oModel:GetModel( "MODEL_T2H" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_T2H", "T2H_SEQUEN", STRZERO(nT2H,3) )
					oModel:LoadValue( "MODEL_T2H", "T2H_CODCAT", FGetIdInt( "codCateg", "", cT2HPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
					oModel:LoadValue( "MODEL_T2H", "T2H_INDRES", FTafGetVal( cT2HPath + "/indResBr" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_IDPAIS", FGetIdInt( "codPais", "",  cT2HPath + "/idePgtoExt/idePais/codPais" ,,,,@cInconMsg, @nSeqErrGrv))
					oModel:LoadValue( "MODEL_T2H", "T2H_INDNIF", FTafGetVal( cT2HPath + "/idePgtoExt/idePais/indNIF" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_NIFBEN", FTafGetVal( cT2HPath + "/idePgtoExt/idePais/nifBenef" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_DLOUGR", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/dscLograd" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_NUMLOG", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/nrLograd" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_COMPLE", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/complem" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_BAIRRO", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/bairro" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_CIDADE", FTafGetVal( cT2HPath + "/idePgtoExt/endExt/nmCid" , "C", .F., @aIncons, .F. ) )
					oModel:LoadValue( "MODEL_T2H", "T2H_CEP",    FTafGetVal( cT2HPath + "/idePgtoExt/endExt/codPostal" , "C", .F., @aIncons, .F. ) )
					
					nT2I := 1
					cT2IPath := cT2HPath + "/basesIrrf[" + AllTrim(Str(nT2I)) + "]"

					While oDados:XPathHasNode(cT2IPath)

						oModel:GetModel( "MODEL_T2I" ):lValid:= .T.

						If nT2I > 1
							oModel:GetModel( "MODEL_T2I" ):AddLine()
						EndIf

						cTpValor  := FTafGetVal(cT2IPath + "/tpValor", "C", .F.,, .F. )

						If Len(cTpValor) < 2
							cTpValor := '0' + cTpValor
						EndIf

						cIdTpValor :=	Posicione("C8U", 2, xFilial("C8U") + cTpValor ,"C8U_ID")

						oModel:LoadValue( "MODEL_T2I", "T2I_CTPVAL", cIdTpValor)
						oModel:LoadValue( "MODEL_T2I", "T2I_VLIRRF", FTafGetVal( cT2IPath + "/valor" , "N", .F., @aIncons, .F. ) )

						nT2I++
						cT2IPath := cT2HPath + "/basesIrrf[" + AllTrim(Str(nT2I)) + "]"

					EndDo

					nT2J := 1
					cT2JPath := cT2HPath + "/irrf[" + AllTrim(Str(nT2J)) + "]"

					While oDados:XPathHasNode(cT2JPath)

						oModel:GetModel( "MODEL_T2J" ):lValid:= .T.

						If nT2J > 1
							oModel:GetModel( "MODEL_T2J" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_T2J", "T2J_CTPCR", "999999" )
						oModel:LoadValue( "MODEL_T2J", "T2J_CODREC", FTafGetVal( cT2JPath + "/tpCR", "C", .F., @aIncons , .F. ) )
						oModel:LoadValue( "MODEL_T2J", "T2J_VLDESC", FTafGetVal( cT2JPath + "/vrIrrfDesc" , "N", .F., @aIncons, .F. ) )

						nT2J++
						cT2JPath := cT2HPath + "/irrf[" + AllTrim(Str(nT2J)) + "]"

					EndDo

					nT2H++
					cT2HPath := cCabec + "infoIrrf[" + AllTrim(Str(nT2H)) + "]"

				EndDo

			Else

				nV6J 		:= 1
				cV6JPath 	:= cCabec + "ideTrabalhador/dmDev[1]"
				
				While oDados:XPathHasNode( cV6JPath )

					oModel:GetModel( "MODEL_V6J" ):lValid := .T.

					If nV6J > 1; oModel:GetModel( "MODEL_V6J" ):AddLine(); EndIf
					
					oModel:LoadValue( "MODEL_V6J", "V6J_SEQUEN", STRZERO( nV6J, 3 ) )

					dDataPgto := FTafGetVal( cV6JPath + "/dtPgto" 			, "D", .F., @aIncons, .F. 	)
					cIdeDmDev := AllTrim( FTafGetVal( cV6JPath + "/ideDmDev", "C", .F., @aIncons, .F. )	)
					cPerRef   := FTafGetVal( cV6JPath + "/perRef"			, "C", .F.,			, .F. 	)
					cTpPgto   := FTafGetVal( cV6JPath + "/tpPgto"			, "C", .F., @aIncons, .F.	)

					If At( "-", cPerRef ) > 0; cPerRef := StrTran( cPerRef, "-", "" ); EndIf
					
					oModel:LoadValue( "MODEL_V6J", "V6J_PERREF", cPerRef, "-", "" )					
					oModel:LoadValue( "MODEL_V6J", "V6J_INDDEV", cIdeDmDev )
					oModel:LoadValue( "MODEL_V6J", "V6J_TPPAG" , cTpPgto )
					oModel:LoadValue( "MODEL_V6J", "V6J_DTPAG" , dDataPgto )
					oModel:LoadValue( "MODEL_V6J", "V6J_CODCAT", FGetIdInt( "codCateg", "", cV6JPath + "/codCateg",,,, @cInconMsg, @nSeqErrGrv ) )

					nT2I 		:= 1
					cT2IPath	:= cV6JPath + "/infoIR[1]"

					While oDados:XPathHasNode( cT2IPath )

						oModel:GetModel( "MODEL_T2I" ):lValid := .T.

						If nT2I > 1; oModel:GetModel( "MODEL_T2I" ):AddLine(); EndIf

						cTpValor  := FTafGetVal( cT2IPath + "/tpInfoIR", "C", .F.,, .F. )

						If Len( cTpValor ) < 2
							cTpValor := '0' + cTpValor
						EndIf

						cIdTpValor :=	Posicione( "C8U", 2, xFilial("C8U") + cTpValor ,"C8U_ID" )

						oModel:LoadValue( "MODEL_T2I", "T2I_CTPVAL", cIdTpValor )
						oModel:LoadValue( "MODEL_T2I", "T2I_VLIRRF", FTafGetVal( cT2IPath + "/valor", "N", .F., @aIncons, .F. ) )
						
						If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")
							oModel:LoadValue( "MODEL_T2I", "T2I_DESCRE", IIF(cTpValor == "79",Posicione( "C8U", 2, xFilial("C8U") + cTpValor ,"C8U_DESCRI" ),FTafGetVal( cT2IPath + "/descRendimento", "C", .F., @aIncons, .F. )) )
						EndIf
						
						If lInfoRPT
							
							tafDefAAnalitco(@aAnalitico)
							nPosValores := Len( aAnalitico )

							aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= ""
							aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim( FTAFGetVal( cV6JPath + "/codCateg", "C", .F.,, .F. ) )
							aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= ""
							aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= ""
							aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= ""
							aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= ""
							aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= ""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= ""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= ""
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= ""
							aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
							aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= AllTrim( cTpValor )
							aAnalitico[nPosValores][ANALITICO_VALOR]				:= FTafGetVal( cT2IPath + "/valor", "N", .F., @aIncons, .F. )
							aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:= IIf( MethIsMemberOf( oReport, "GetMotDes" ), oReport:GetMotDes( cAliEvtOri, nRecEvtOri ), "" )
							aAnalitico[nPosValores][ANALITICO_RECIBO]               := ""
							aAnalitico[nPosValores][ANALITICO_VALOR_DEP]            := 0
							aAnalitico[nPosValores][ANALITICO_PERIODO_REFERENCIA]	:= cPerRef
							aAnalitico[nPosValores][ANALITICO_PGTO_DEMONSTRATIVO]	:= cIdeDmDev
							aAnalitico[nPosValores][ANALITICO_PGTO_DATA]			:= dDataPgto
							aAnalitico[nPosValores][ANALITICO_PGTO_EVENTO]			:= GetEvtByTpPgto( Val( cTpPgto ) )
							aAnalitico[nPosValores][ANALITICO_PGTO_CRMEN]           := ""

						EndIf

						nV8J 		:= 1
						cV8JPath	:= cT2IPath + "/infoProcJudRub[1]"

						If oDados:XPathHasNode( cT2IPath + "/infoProcJudRub[" + CValToChar( nV8J ) + "]"  ) .And. TafColumnPos( "V8J_NRPROC" )

							While oDados:XPathHasNode( cV8JPath )

								oModel:GetModel( "MODEL_V8J" ):lValid := .T.
								
								If nV8J > 1; oModel:GetModel( "MODEL_V8J" ):AddLine(); EndIf

								oModel:LoadValue( "MODEL_V8J", "V8J_NRPROC", FTafGetVal( cV8JPath + "/nrProc" 	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V8J", "V8J_UFVARA", FTafGetVal( cV8JPath + "/ufVara" 	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V8J", "V8J_CODMUN", FTafGetVal( cV8JPath + "/codMunic" , "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V8J", "V8J_IDVARA", FTafGetVal( cV8JPath + "/idVara" 	, "C", .F., @aIncons, .F. ) )

								nV8J++
								cV8JPath := cT2IPath + "/infoProcJudRub[" + CValToChar( nV8J ) + "]"

							EndDo

						EndIf

						nT2I++
						cT2IPath := cV6JPath + "/infoIR[" + CValToChar( nT2I ) + "]"

					EndDo
					
					nV7M 		:= 1
					cV7MPath	:= cV6JPath + "/totApurMen[1]"

					If TafColumnPos( "V7M_CRMEN" ) 

						While oDados:XPathHasNode( cV7MPath )

							oModel:GetModel( "MODEL_V7M" ):lValid := .T.

							If nV7M > 1; oModel:GetModel( "MODEL_V7M" ):AddLine(); EndIf

							If lInfoRPT
								
								tafDefAAnalitco(@aAnalitico)
								nPosValores := Len( aAnalitico )

								aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= ""
								aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim( FTAFGetVal( cV6JPath + "/codCateg", "C", .F.,, .F. ) )
								aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= ""
								aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= ""
								aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= ""
								aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= ""
								aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= ""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= ""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= ""
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= ""
								aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
								aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
								aAnalitico[nPosValores][ANALITICO_VALOR]				:= 0
								aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:= IIf( MethIsMemberOf( oReport, "GetMotDes" ), oReport:GetMotDes( cAliEvtOri, nRecEvtOri ), "" )
								aAnalitico[nPosValores][ANALITICO_RECIBO]               := ""
								aAnalitico[nPosValores][ANALITICO_VALOR_DEP]            := 0
								aAnalitico[nPosValores][ANALITICO_PERIODO_REFERENCIA]	:= cPerRef
								aAnalitico[nPosValores][ANALITICO_PGTO_DEMONSTRATIVO]	:= cIdeDmDev
								aAnalitico[nPosValores][ANALITICO_PGTO_DATA]			:= dDataPgto
								aAnalitico[nPosValores][ANALITICO_PGTO_EVENTO]			:= GetEvtByTpPgto( Val( cTpPgto ) )
								aAnalitico[nPosValores][ANALITICO_PGTO_CRMEN]           := FTafGetVal( cV7MPath + "/CRMen" , "C", .F., @aIncons, .F. )

							EndIf

							oModel:LoadValue( "MODEL_V7M", "V7M_CRMEN",  FTafGetVal( cV7MPath + "/CRMen" , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7M", "V7M_VLMEN",  FTafGetVal( cV7MPath + "/vlrCRMen" , "N", .F., @aIncons, .F. ) )

							If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")
								oModel:LoadValue( "MODEL_V7M", "V7M_RENDTR",  FTafGetVal( cV7MPath + "/vlrRendTrib" 		, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_REND13",  FTafGetVal( cV7MPath + "/vlrRendTrib13" 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_PREVOF",  FTafGetVal( cV7MPath + "/vlrPrevOficial" 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_PREV13",  FTafGetVal( cV7MPath + "/vlrPrevOficial13" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_VMEN13",  FTafGetVal( cV7MPath + "/vlrCR13Men" 		, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_PARI65",  FTafGetVal( cV7MPath + "/vlrParcIsenta65" 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_I65DEC",  FTafGetVal( cV7MPath + "/vlrParcIsenta65Dec" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_VLRDIA",  FTafGetVal( cV7MPath + "/vlrDiarias" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_VLRAJU",  FTafGetVal( cV7MPath + "/vlrAjudaCusto" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_VLRCON",  FTafGetVal( cV7MPath + "/vlrIndResContrato" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_VLRABN",  FTafGetVal( cV7MPath + "/vlrAbonoPec" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_VLRIMG",  FTafGetVal( cV7MPath + "/vlrRendMoleGrave" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_IMG13",   FTafGetVal( cV7MPath + "/vlrRendMoleGrave13" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_VLMORD",  FTafGetVal( cV7MPath + "/vlrAuxMoradia" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_BOLMED",  FTafGetVal( cV7MPath + "/vlrBolsaMedico" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_BOLM13",  FTafGetVal( cV7MPath + "/vlrBolsaMedico13" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_JURMOR",  FTafGetVal( cV7MPath + "/vlrJurosMora" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_ISEOUT",  FTafGetVal( cV7MPath + "/vlrIsenOutros" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7M", "V7M_DESCRE",  IIF(cTpValor == "79",Posicione( "C8U", 2, xFilial("C8U") + cTpValor ,"C8U_DESCRI" ),FTafGetVal( cV7MPath + "/descRendimento" , "C", .F., @aIncons, .F. )) )
							EndIf
							
							nV7M++
							cV7MPath := cV6JPath + "/totApurMen[" + CValToChar( nV7M ) + "]"

						EndDo

						nV7N 		:= 1
						cV7NPath	:= cV6JPath + "/totApurDia[1]"

						While oDados:XPathHasNode( cV7NPath )

							oModel:GetModel( "MODEL_V7N" ):lValid := .T.

							If nV7N > 1; oModel:GetModel( "MODEL_V7N" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V7N", "V7N_PERDIA", FTafGetVal( cV7NPath + "/perApurDia"	, "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7N", "V7N_CRDIA", FTafGetVal( cV7NPath + "/CRDia"			, "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V7N", "V7N_VLCRD", FTafGetVal( cV7NPath + "/vlrCRDia"		, "N", .F., @aIncons, .F. ) )

							If lSimpl0103 .And. TafColumnPos("T8G_CRMEN")
								oModel:LoadValue( "MODEL_V7N", "V7N_FRMTRI", FTafGetVal( cV7NPath + "/frmTribut"	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7N", "V7N_PAGDIA", FTafGetVal( cV7NPath + "/vlrPagoDia"	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V7N", "V7N_PAISEX", FTafGetVal( cV7NPath + "/paisResidExt"	, "C", .F., @aIncons, .F. ) )
							EndIf
							
							nV7N++
							cV7NPath := cV6JPath + "/totApurDia[" + CValToChar( nV7N ) + "]"

						EndDo

						//InfoRRA
						cV8TPath	:= cV6JPath + "/infoRRA"

						If oDados:XPathHasNode( cV8TPath )							

							cChvV8TSequen  := STRZERO( 1, 3 )
							
							oModelV8T := oModel:GetModel( "MODEL_V8T" )
							oModelV8T:lValid := .T.

							oModel:LoadValue( "MODEL_V8T", "V8T_SEQRRA", cChvV8TSequen )
							oModel:LoadValue( "MODEL_V8T", "V8T_TPPROC", FTafGetVal( cV8TPath + "/tpProcRRA" ,  "C", .F., @aIncons, .F. ) )

							If oDados:XPathHasNode( cV8TPath + "/nrProcRRA" )
								oModel:LoadValue( "MODEL_V8T", "V8T_NRPRRA", FTafGetVal( cV8TPath + "/nrProcRRA" ,  "C", .F., @aIncons, .F. ) )
							EndIf

							oModel:LoadValue( "MODEL_V8T", "V8T_DESCRA", FTafGetVal( cV8TPath + "/descRRA" , 	"C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V8T", "V8T_QTMRRA", FTafGetVal( cV8TPath + "/qtdMesesRRA" ,"N", .F., @aIncons, .F. ) )

							// despProcJud
							cV52Path	:= cV8TPath + "/despProcJud"

							If oDados:XPathHasNode( cV52Path )

								oModel:GetModel( "MODEL_V52" ):lValid := .T.
								oModel:LoadValue( "MODEL_V52", "V52_VLDEPC", FTafGetVal( cV52Path + "/vlrDespCustas" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V52", "V52_VLDADV", FTafGetVal( cV52Path + "/vlrDespAdvogados" , "N", .F., @aIncons, .F. ) )
								
							EndIf

							// ideAdv
							nV53		:= 1
							cV53Path	:= cV8TPath + "/ideAdv[1]"

							While oDados:XPathHasNode( cV53Path )	

								If oDados:XPathHasNode( cV53Path )

									oModel:GetModel( "MODEL_V53" ):lValid := .T.

									If nV53 > 1; oModel:GetModel( "MODEL_V53" ):AddLine(); EndIf

									oModel:LoadValue( "MODEL_V53", "V53_TPINSC", FTafGetVal( cV53Path + "/tpInsc" , "C", .F., @aIncons, .F. ) )
									oModel:LoadValue( "MODEL_V53", "V53_NRINSC", FTafGetVal( cV53Path + "/nrInsc" , "C", .F., @aIncons, .F. ) )

									If oDados:XPathHasNode( cV53Path + "/vlrAdv" )
										oModel:LoadValue( "MODEL_V53", "V53_VLRADV", FTafGetVal( cV53Path + "/vlrAdv" , "N", .F., @aIncons, .F. ) )
									EndIf

									nV53++
									cV53Path	:= cV8TPath + "/ideAdv[" + CValToChar( nV53 ) + "]"
								
								EndIf 

							EndDo

						EndIf

						//infopagexterior
						cV8HPath	:= cV6JPath + "/infoPgtoExt"

						If oDados:XPathHasNode( cV8HPath )

							oModel:GetModel( "MODEL_V8H" ):lValid := .T.
							oModel:LoadValue( "MODEL_V8H", "V8H_PAISEX", FTafGetVal( cV8HPath + "/paisResidExt" ,	 "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V8H", "V8H_INDNIF", FTafGetVal( cV8HPath + "/indNIF" 		, 	 "C", .F., @aIncons, .F. ) )

							If oDados:XPathHasNode( cV8HPath + "/nifBenef" )
								oModel:LoadValue( "MODEL_V8H", "V8H_NIFBEN", FTafGetVal( cV8HPath + "/nifBenef" , "C", .F., @aIncons, .F. ) )
							EndIf

							oModel:LoadValue( "MODEL_V8H", "V8H_FRMTRI", FTafGetVal( cV8HPath + "/frmTribut" 	,	 "C", .F., @aIncons, .F. ) )

							If oDados:XPathHasNode( cV8HPath + "/endExt" )

								If oDados:XPathHasNode( cV8HPath + "/endExt/endDscLograd" )
									oModel:LoadValue( "MODEL_V8H", "V8H_ENDLOG", FTafGetVal( cV8HPath + "/endExt/endDscLograd", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV8HPath + "/endExt/endNrLograd" )
									oModel:LoadValue( "MODEL_V8H", "V8H_ENDNUM", FTafGetVal( cV8HPath + "/endExt/endNrLograd", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV8HPath + "/endExt/endComplem" )
									oModel:LoadValue( "MODEL_V8H", "V8H_ENDCOM", FTafGetVal( cV8HPath + "/endExt/endComplem", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV8HPath + "/endExt/endBairro" )
									oModel:LoadValue( "MODEL_V8H", "V8H_ENDBAI", FTafGetVal( cV8HPath + "/endExt/endBairro", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV8HPath + "/endExt/endCidade" )
									oModel:LoadValue( "MODEL_V8H", "V8H_ENDCID", FTafGetVal( cV8HPath + "/endExt/endCidade", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV8HPath + "/endExt/endEstado" )
									oModel:LoadValue( "MODEL_V8H", "V8H_ENDEST", FTafGetVal( cV8HPath + "/endExt/endEstado", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV8HPath + "/endExt/endCodPostal" )
									oModel:LoadValue( "MODEL_V8H", "V8H_CODPOS", FTafGetVal( cV8HPath + "/endExt/endCodPostal", "C", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV8HPath + "/endExt/telef" )
									oModel:LoadValue( "MODEL_V8H", "V8H_ENDTEL", FTafGetVal( cV8HPath + "/endExt/telef", "C", .F., @aIncons, .F. ) )
								EndIf

							EndIf

						EndIf

					EndIf

					nV6J++
					cV6JPath 	:= cCabec + "ideTrabalhador/dmDev[" + CValToChar( nV6J ) + "]" 

				EndDo

				If lSimpl12 .AND. (!lSimpl0103 .OR. !TafColumnPos("V68_SEQIRC"))
					// ideDep
					nV8V 		:= 1
					cV8VPath	:= cCabec + "ideTrabalhador/infoIRComplem/ideDep[1]"

					While oDados:XPathHasNode( cV8VPath )

						oModel:GetModel( "MODEL_V8V" ):lValid := .T.

						If nV8V > 1; oModel:GetModel( "MODEL_V8V" ):AddLine(); EndIf

						oModel:LoadValue( "MODEL_V8V", "V8V_CPFDEP", FTafGetVal( cV8VPath + "/cpfDep", "C", .F., @aIncons, .F. ) )

						If oDados:XPathHasNode( cV8VPath + "/depIRRF" )
							oModel:LoadValue( "MODEL_V8V", "V8V_DEPIRR", FTafGetVal( cV8VPath + "/depIRRF", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cV8VPath + "/dtNascto" )
							oModel:LoadValue( "MODEL_V8V", "V8V_DTNASC", FTafGetVal( cV8VPath + "/dtNascto", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cV8VPath + "/nome" )
							oModel:LoadValue( "MODEL_V8V", "V8V_NOME", FTafGetVal( cV8VPath + "/nome", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cV8VPath + "/tpDep" )
							oModel:LoadValue( "MODEL_V8V", "V8V_TPDEP", FTafGetVal( cV8VPath + "/tpDep", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cV8VPath + "/descrDep" )
							oModel:LoadValue( "MODEL_V8V", "V8V_DESCDE", FTafGetVal( cV8VPath + "/descrDep", "C", .F., @aIncons, .F. ) )
						EndIf

						nV8V++
						cV8VPath	:= cCabec + "ideTrabalhador/infoIRComplem/ideDep[" + CValToChar( nV8V ) + "]"

					EndDo

					// infoIRCR
					nV60 		:= 1
					cV60Path	:= cCabec + "ideTrabalhador/infoIRComplem/infoIRCR[1]"

					While oDados:XPathHasNode( cV60Path )

						oModel:GetModel( "MODEL_V60" ):lValid := .T.

						If nV60 > 1; oModel:GetModel( "MODEL_V60" ):AddLine(); EndIf

						oModel:LoadValue( "MODEL_V60", "V60_TPCR", FTafGetVal( cV60Path + "/tpCR", "C", .F., @aIncons, .F. ) )

						// dedDepen
						nV61 		:= 1
						cV61Path	:= cV60Path + "/dedDepen[1]"

						While oDados:XPathHasNode( cV61Path )

							oModel:GetModel( "MODEL_V61" ):lValid := .T.

							If nV61 > 1; oModel:GetModel( "MODEL_V61" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V61", "V61_TPREND", FTafGetVal( cV61Path + "/tpRend" 	, "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V61", "V61_CPFDEP", FTafGetVal( cV61Path + "/cpfDep" 	, "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V61", "V61_VLRDED", FTafGetVal( cV61Path + "/vlrDedDep", "N", .F., @aIncons, .F. ) )

							nV61++
							cV61Path	:= cV60Path  + "/dedDepen[" + CValToChar( nV61 ) + "]"

						EndDo

						// penAlim
						nV62 		:= 1
						cV62Path	:= cV60Path + "/penAlim[1]"

						While oDados:XPathHasNode( cV62Path )

							oModel:GetModel( "MODEL_V62" ):lValid := .T.

							If nV62 > 1; oModel:GetModel( "MODEL_V62" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V62", "V62_TPREND", FTafGetVal( cV62Path + "/tpRend" 		 , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V62", "V62_CPFDEP", FTafGetVal( cV62Path + "/cpfDep" 		 , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V62", "V62_VLPEN ", FTafGetVal( cV62Path + "/vlrDedPenAlim" , "N", .F., @aIncons, .F. ) )

							nV62++
							cV62Path := cV60Path + "/penAlim[" + CValToChar( nV62 ) + "]"

						EndDo

						// previdCompl
						nV63 		:= 1
						cV63Path	:= cV60Path + "/previdCompl[1]"

						While oDados:XPathHasNode( cV63Path )

							oModel:GetModel( "MODEL_V63" ):lValid := .T.

							If nV63 > 1; oModel:GetModel( "MODEL_V63" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V63", "V63_TPREV", FTafGetVal( cV63Path + "/tpPrev" 		 , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V63", "V63_INSCPL", FTafGetVal( cV63Path + "/cnpjEntidPC" 	 , "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V63", "V63_VLCOMP", FTafGetVal( cV63Path + "/vlrDedPC" 	 , "N", .F., @aIncons, .F. ) )

							If oDados:XPathHasNode( cV63Path + "/vlrPatrocFunp" )
								oModel:LoadValue( "MODEL_V63", "V63_VLPATR", FTafGetVal( cV63Path + "/vlrPatrocFunp", "N", .F., @aIncons, .F. ) )
							EndIf

							nV63++
							cV63Path	:= cV60Path + "/previdCompl[" + CValToChar( nV63 ) + "]"

						EndDo

						// infoProcRet
						nV64 		:= 1
						cV64Path	:= cV60Path + "/infoProcRet[1]"

						While oDados:XPathHasNode( cV64Path )

							oModel:GetModel( "MODEL_V64" ):lValid := .T.

							If nV64 > 1; oModel:GetModel( "MODEL_V64" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V64", "V64_TPPROC", FTafGetVal( cV64Path + "/tpProcRet" 	, "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V64", "V64_NRPROC", FTafGetVal( cV64Path + "/nrProcRet" 	, "C", .F., @aIncons, .F. ) )

							If oDados:XPathHasNode( cV64Path + "/codSusp" )
								oModel:LoadValue( "MODEL_V64", "V64_CODSUP", FTafGetVal( cV64Path + "/codSusp", "C", .F., @aIncons, .F. ) )
							EndIF

							// infoValores
							nV65 		:= 1
							cV65Path	:= cV64Path + "/infoValores[1]"

							While oDados:XPathHasNode( cV65Path )

								oModel:GetModel( "MODEL_V65" ):lValid := .T.

								If nV65 > 1; oModel:GetModel( "MODEL_V65" ):AddLine(); EndIf

								oModel:LoadValue( "MODEL_V65", "V65_INDAPU", FTafGetVal( cV65Path + "/indApuracao", "C", .F., @aIncons, .F. ) )
								
								If oDados:XPathHasNode( cV65Path + "/vlrNRetido" )
									oModel:LoadValue( "MODEL_V65", "V65_VLRRET", FTafGetVal( cV65Path + "/vlrNRetido", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV65Path + "/vlrDepJud" )
									oModel:LoadValue( "MODEL_V65", "V65_VLRJUD", FTafGetVal( cV65Path + "/vlrDepJud", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV65Path + "/vlrCmpAnoCal" )
									oModel:LoadValue( "MODEL_V65", "V65_VLACAL", FTafGetVal( cV65Path + "/vlrCmpAnoCal", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV65Path + "/vlrCmpAnoAnt" )
									oModel:LoadValue( "MODEL_V65", "V65_VLAANT", FTafGetVal( cV65Path + "/vlrCmpAnoAnt", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV65Path + "/vlrRendSusp" )
									oModel:LoadValue( "MODEL_V65", "V65_VLSUSP", FTafGetVal( cV65Path + "/vlrRendSusp", "N", .F., @aIncons, .F. ) )
								EndIf

								// dedSusp
								nV66		:= 1
								cV66Path	:= cV65Path + "/dedSusp[1]"

								While oDados:XPathHasNode( cV66Path )

									oModel:GetModel( "MODEL_V66" ):lValid := .T.	

									If nV66 > 1; oModel:GetModel( "MODEL_V66" ):AddLine(); EndIf

									oModel:LoadValue( "MODEL_V66", "V66_SEQUEN", StrZero(nV66, TamSX3("V66_SEQUEN")[1]) )

									oModel:LoadValue( "MODEL_V66", "V66_TPDEDU", FTafGetVal( cV66Path + "/indTpDeducao", "C", .F., @aIncons, .F. ) )
									
									If oDados:XPathHasNode( cV66Path + "/vlrDedSusp" )
										oModel:LoadValue( "MODEL_V66", "V66_VLSUSP", FTafGetVal( cV66Path + "/vlrDedSusp", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cV66Path + "/cnpjEntidPC" )
										oModel:LoadValue( "MODEL_V66", "V66_INSCPL", FTafGetVal( cV66Path + "/cnpjEntidPC", "C", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cV66Path + "/vlrPatrocFunp" )
										oModel:LoadValue( "MODEL_V66", "V66_VLFUNP", FTafGetVal( cV66Path + "/vlrPatrocFunp", "N", .F., @aIncons, .F. ) )
									EndIf

									// benefPen
									nV67		:= 1
									cV67Path	:= cV66Path + "/benefPen[1]"

									While oDados:XPathHasNode( cV67Path )

										oModel:GetModel( "MODEL_V67" ):lValid := .T.

										If nV67 > 1; oModel:GetModel( "MODEL_V67" ):AddLine(); EndIf

										oModel:LoadValue( "MODEL_V67", "V67_CPFDEP", FTafGetVal( cV67Path + "/cpfDep" 		, "C", .F., @aIncons, .F. ) )
										oModel:LoadValue( "MODEL_V67", "V67_VLSUSP", FTafGetVal( cV67Path + "/vlrDepenSusp" , "N", .F., @aIncons, .F. ) )

										nV67++
										cV67Path	:= cV66Path + "/benefPen[" + CValToChar( nV67 ) + "]"

									EndDo

									nV66++
									cV66Path	:= cV65Path + "/dedSusp[" + CValToChar( nV66 ) + "]"

								EndDo

								nV65++
								cV65Path	:= cV65Path + "/infoValores[" + CValToChar( nV65 ) + "]"

							EndDo

							nV64++
							cV64Path	:= cCabec + cV60Path + "/infoProcRet[" + CValToChar( nV64 ) + "]"

						EndDo

						nV60++
						cV60Path	:= cCabec + "ideTrabalhador/infoIRComplem/infoIRCR[" + CValToChar( nV60 ) + "]"

					EndDo

					// planSaude
					nV68 		:= 1
					cV68Path	:= cCabec + "ideTrabalhador/infoIRComplem/planSaude[1]"

					While oDados:XPathHasNode( cV68Path )

						oModel:GetModel( "MODEL_V68" ):lValid := .T.

						If nV68 > 1
							oModel:GetModel( "MODEL_V68" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V68", "V68_CNPJOP", FTafGetVal( cV68Path + "/cnpjOper", "C", .F., @aIncons, .F. ) )

						If oDados:XPathHasNode( cV68Path + "/regANS" )
							oModel:LoadValue( "MODEL_V68", "V68_REGANS", FTafGetVal( cV68Path + "/regANS", "C", .F., @aIncons, .F. ) )
						EndIf

						oModel:LoadValue( "MODEL_V68", "V68_VLRTIT", FTafGetVal( cV68Path + "/vlrSaudeTit", "N", .F., @aIncons, .F. ) )

						// infoDepSau
						nV69 		:= 1
						cV69Path	:= cV68Path + "/infoDepSau[1]"

						While oDados:XPathHasNode( cV69Path ) 

							oModel:GetModel( "MODEL_V69" ):lValid := .T.

							If nV69 > 1
								oModel:GetModel( "MODEL_V69" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_V69", "V69_CPFDEP", FTafGetVal( cV69Path + "/cpfDep" 		, "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V69", "V69_VLRDEP", FTafGetVal( cV69Path + "/vlrSaudeDep" 	, "N", .F., @aIncons, .F. ) )

							nV69++
							cV69Path	:= cV68Path + "/infoDepSau[" + CValToChar( nV69 ) + "]"

						EndDo

						nV68++
						cV68Path	:= cCabec + "ideTrabalhador/infoIRComplem/planSaude[" + CValToChar( nV68 ) + "]"
						
					EndDo

					// infoReembMed
					nV6A 		:= 1
					cV6APath	:= cCabec + "ideTrabalhador/infoIRComplem/infoReembMed[1]"

					While oDados:XPathHasNode( cV6APath )

						oModel:GetModel( "MODEL_V6A" ):lValid := .T.

						If nV6A > 1; oModel:GetModel( "MODEL_V6A" ):AddLine(); EndIf

						oModel:LoadValue( "MODEL_V6A", "V6A_INDREM", FTafGetVal( cV6APath + "/indOrgReemb", "C", .F., @aIncons, .F. ) )
						
						If oDados:XPathHasNode( cV6APath + "/cnpjOper" )
							oModel:LoadValue( "MODEL_V6A", "V6A_CNPJOP", FTafGetVal( cV6APath + "/cnpjOper", "C", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cV6APath + "/regANS" )
							oModel:LoadValue( "MODEL_V6A", "V6A_REGANS", FTafGetVal( cV6APath + "/regANS", "C", .F., @aIncons, .F. ) )
						EndIf

						// detReembTit
						nV54 		:= 1
						cV54Path	:= cV6APath + "/detReembTit[1]"

						While oDados:XPathHasNode( cV54Path )

							oModel:GetModel( "MODEL_V54" ):lValid := .T.

							If nV54 > 1; oModel:GetModel( "MODEL_V54" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V54", "V54_TPINSC", FTafGetVal( cV54Path + "/tpInsc", "C", .F., @aIncons, .F. ) )
							oModel:LoadValue( "MODEL_V54", "V54_NRINSC", FTafGetVal( cV54Path + "/nrInsc", "C", .F., @aIncons, .F. ) )
								
							If oDados:XPathHasNode( cV54Path + "/vlrReemb" )
								oModel:LoadValue( "MODEL_V54", "V54_VLREMB", FTafGetVal( cV54Path + "/vlrReemb", "N", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cV54Path + "/vlrReembAnt" )
								oModel:LoadValue( "MODEL_V54", "V54_VLRANT", FTafGetVal( cV54Path + "/vlrReembAnt", "N", .F., @aIncons, .F. ) )
							EndIf

							nV54++
							cV54Path	:= cV6APath + "/detReembTit[" + CValToChar( nV54 ) + "]"

						EndDo

						// infoReembDep
						nV50 		:= 1
						cV50Path	:= cCabec + "ideTrabalhador/infoIRComplem/infoReembMed/infoReembDep[1]"

						While oDados:XPathHasNode( cV50Path )

							oModel:GetModel( "MODEL_V50" ):lValid := .T.

							If nV50 > 1 
								oModel:GetModel( "MODEL_V50" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_V50", "V50_CPFDEP", FTafGetVal( cV50Path + "/cpfBenef", "C", .F., @aIncons, .F. ) )

							// detReembDep
							nV51 		:= 1
							cV51Path	:= cV50Path + "/detReembDep[1]"

							While oDados:XPathHasNode( cV51Path )

								oModel:GetModel( "MODEL_V51" ):lValid := .T.

								If nV51 > 1
									oModel:GetModel( "MODEL_V51" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V51", "V51_TPINSC", FTafGetVal( cV51Path + "/tpInsc", "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V51", "V51_NRINSC", FTafGetVal( cV51Path + "/nrInsc", "C", .F., @aIncons, .F. ) )
								
								If oDados:XPathHasNode( cV51Path + "/vlrReemb" )
									oModel:LoadValue( "MODEL_V51", "V51_VLREMB", FTafGetVal( cV51Path + "/vlrReemb", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV51Path + "/vlrReembAnt" )
									oModel:LoadValue( "MODEL_V51", "V51_VLRANT", FTafGetVal( cV51Path + "/vlrReembAnt", "N", .F., @aIncons, .F. ) )
								EndIf

								nV51++
								cV51Path	:= cV50Path + "/detReembDep[" + CValToChar( nV51 ) + "]"

							EndDo

							nV50++
							cV50Path	:= cCabec + "ideTrabalhador/infoIRComplem/infoReembMed/infoReembDep[" + CValToChar( nV50 ) + "]"

						EndDo

						nV6A++
						cV6APath	:= cCabec + "ideTrabalhador/infoIRComplem/infoReembMed[" + CValToChar( nV6A ) + "]"

					EndDo

				ElseIf lSimpl0103 .And. TafColumnPos("T8G_CRMEN")

					nT8G 		:= 1
					cT8GPath 	:= cCabec + "ideTrabalhador/totInfoIR[1]/consolidApurMen[" + CValToChar( nT8G ) + "]"

					While oDados:XPathHasNode( cT8GPath )

						oModel:GetModel( "MODEL_T8G" ):lValid := .T.

						If nT8G > 1; oModel:GetModel( "MODEL_T8G" ):AddLine(); EndIf
						
						oModel:LoadValue( "MODEL_T8G", "T8G_CRMEN",  FTafGetVal( cT8GPath + "/CRMen", 			"C", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_RENDTR", FTafGetVal( cT8GPath + "/vlrRendTrib", 	"N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_RENT13", FTafGetVal( cT8GPath + "/vlrRendTrib13", 	"N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_PREVOF", FTafGetVal( cT8GPath + "/vlrPrevOficial", 	"N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_PROF13", FTafGetVal( cT8GPath + "/vlrPrevOficial13","N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_VCRMEN", FTafGetVal( cT8GPath + "/vlrCRMen", 		"N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_CR13ME", FTafGetVal( cT8GPath + "/vlrCR13Men", 		"N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_PAIS65", FTafGetVal( cT8GPath + "/vlrParcIsenta65", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_PIS65D", FTafGetVal( cT8GPath + "/vlrParcIsenta65Dec", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_VLDIAR", FTafGetVal( cT8GPath + "/vlrDiarias", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_VLAJUC", FTafGetVal( cT8GPath + "/vlrAjudaCusto", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_VINRES", FTafGetVal( cT8GPath + "/vlrIndResContrato", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_ABONPE", FTafGetVal( cT8GPath + "/vlrAbonoPec", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_VLRIMG", FTafGetVal( cT8GPath + "/vlrRendMoleGrave", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_IMG13",  FTafGetVal( cT8GPath + "/vlrRendMoleGrave13", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_VLMORD", FTafGetVal( cT8GPath + "/vlrAuxMoradia", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_BOLMED", FTafGetVal( cT8GPath + "/vlrBolsaMedico", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_BOLM13", FTafGetVal( cT8GPath + "/vlrBolsaMedico13", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_JURMOR", FTafGetVal( cT8GPath + "/vlrJurosMora", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_ISEOUT", FTafGetVal( cT8GPath + "/vlrIsenOutros", "N", .F., @aIncons, .F. ) )
						oModel:LoadValue( "MODEL_T8G", "T8G_DESCRE", IIF(cTpValor == "79",Posicione( "C8U", 2, xFilial("C8U") + cTpValor ,"C8U_DESCRI" ),FTafGetVal( cT8GPath + "/descRendimento", "C", .F., @aIncons, .F. )) )
						oModel:LoadValue( "MODEL_T8G", "T8G_SEQUEN", CValToChar( nT8G ) )

						nT8G++
						cT8GPath 	:= cCabec + "ideTrabalhador/totInfoIR[1]/consolidApurMen[" + CValToChar( nT8G ) + "]"

					EndDo

					// infoIRComplem
					nT8H 		:= 1
					cT8HPath	:= cCabec + "ideTrabalhador/infoIRComplem[" + CValToChar( nT8H ) + "]"
				
					While oDados:XPathHasNode( cT8HPath )

						oModel:GetModel( "MODEL_T8H" ):lValid := .T.

						If nT8H > 1; oModel:GetModel( "MODEL_T8H" ):AddLine(); EndIf

						If oDados:XPathHasNode( cT8HPath + "/dtLaudo" )
							oModel:LoadValue( "MODEL_T8H", "T8H_DTLAUD", FTafGetVal( cT8HPath + "/dtLaudo", "D", .F., @aIncons, .F. ) )
						EndIf

						If oDados:XPathHasNode( cT8HPath + "/perAnt[1]/perRefAjuste" )
							oModel:LoadValue( "MODEL_T8H", "T8H_PERREF", FTafGetVal( cT8HPath + "/perAnt[1]/perRefAjuste" , "C", .F., @aIncons, .F. ) )
						EndIf
						
						If oDados:XPathHasNode( cT8HPath + "/perAnt[1]/nrRec1210Orig" )
							oModel:LoadValue( "MODEL_T8H", "T8H_NR1210", FTafGetVal( cT8HPath + "/perAnt[1]/nrRec1210Orig" , "C", .F., @aIncons, .F. ) )
						EndIf
						
						oModel:LoadValue( "MODEL_T8H", "T8H_SEQIRC  ", CValToChar( nT8H ) )
						
						// ideDep
						nV8V 		:= 1
						cV8VPath	:= cT8HPath + "/ideDep[1]"

						While oDados:XPathHasNode( cV8VPath )

							oModel:GetModel( "MODEL_V8V" ):lValid := .T.

							If nV8V > 1; oModel:GetModel( "MODEL_V8V" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V8V", "V8V_CPFDEP", FTafGetVal( cV8VPath + "/cpfDep", "C", .F., @aIncons, .F. ) )

							If oDados:XPathHasNode( cV8VPath + "/depIRRF" )
								oModel:LoadValue( "MODEL_V8V", "V8V_DEPIRR", FTafGetVal( cV8VPath + "/depIRRF", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cV8VPath + "/dtNascto" )
								oModel:LoadValue( "MODEL_V8V", "V8V_DTNASC", FTafGetVal( cV8VPath + "/dtNascto", "D", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cV8VPath + "/nome" )
								oModel:LoadValue( "MODEL_V8V", "V8V_NOME", FTafGetVal( cV8VPath + "/nome", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cV8VPath + "/tpDep" )
								oModel:LoadValue( "MODEL_V8V", "V8V_TPDEP", FTafGetVal( cV8VPath + "/tpDep", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cV8VPath + "/descrDep" )
								oModel:LoadValue( "MODEL_V8V", "V8V_DESCDE", FTafGetVal( cV8VPath + "/descrDep", "C", .F., @aIncons, .F. ) )
							EndIf

							nV8V++
							cV8VPath	:= cT8HPath + "/ideDep[" + CValToChar( nV8V ) + "]"

						EndDo

						// infoIRCR
						nV60 		:= 1
						cV60Path	:= cT8HPath + "/infoIRCR[1]"

						While oDados:XPathHasNode( cV60Path )

							oModel:GetModel( "MODEL_V60" ):lValid := .T.

							If nV60 > 1; oModel:GetModel( "MODEL_V60" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V60", "V60_TPCR", FTafGetVal( cV60Path + "/tpCR", "C", .F., @aIncons, .F. ) )

							// dedDepen
							nV61 		:= 1
							cV61Path	:= cV60Path + "/dedDepen[1]"

							While oDados:XPathHasNode( cV61Path )

								oModel:GetModel( "MODEL_V61" ):lValid := .T.

								If nV61 > 1; oModel:GetModel( "MODEL_V61" ):AddLine(); EndIf

								oModel:LoadValue( "MODEL_V61", "V61_TPREND", FTafGetVal( cV61Path + "/tpRend" 	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V61", "V61_CPFDEP", FTafGetVal( cV61Path + "/cpfDep" 	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V61", "V61_VLRDED", FTafGetVal( cV61Path + "/vlrDedDep", "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V8V", "V8V_SEQIRC  ", nT8H )

								nV61++
								cV61Path	:= cV60Path  + "/dedDepen[" + CValToChar( nV61 ) + "]"

							EndDo

							// penAlim
							nV62 		:= 1
							cV62Path	:= cV60Path + "/penAlim[1]"

							While oDados:XPathHasNode( cV62Path )

								oModel:GetModel( "MODEL_V62" ):lValid := .T.

								If nV62 > 1; oModel:GetModel( "MODEL_V62" ):AddLine(); EndIf

								oModel:LoadValue( "MODEL_V62", "V62_TPREND", FTafGetVal( cV62Path + "/tpRend" 		 , "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V62", "V62_CPFDEP", FTafGetVal( cV62Path + "/cpfDep" 		 , "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V62", "V62_VLPEN ", FTafGetVal( cV62Path + "/vlrDedPenAlim" , "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V8V", "V8V_SEQIRC  ", nT8H )

								nV62++
								cV62Path := cV60Path + "/penAlim[" + CValToChar( nV62 ) + "]"

							EndDo

							// previdCompl
							nV63 		:= 1
							cV63Path	:= cV60Path + "/previdCompl[1]"

							While oDados:XPathHasNode( cV63Path )

								oModel:GetModel( "MODEL_V63" ):lValid := .T.

								If nV63 > 1; oModel:GetModel( "MODEL_V63" ):AddLine(); EndIf

								oModel:LoadValue( "MODEL_V63", "V63_TPREV ", FTafGetVal( cV63Path + "/tpPrev" 		 	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V63", "V63_INSCPL", FTafGetVal( cV63Path + "/cnpjEntidPC" 	 	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V63", "V63_VLCOMP", FTafGetVal( cV63Path + "/vlrDedPC" 	 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V63", "V63_VLCO13", FTafGetVal( cV63Path + "/vlrDedPC13" 	 	, "N", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V63", "V63_VLPA13", FTafGetVal( cV63Path + "/vlrPatrocFunp13" 	, "N", .F., @aIncons, .F. ) )

								If oDados:XPathHasNode( cV63Path + "/vlrPatrocFunp" )
									oModel:LoadValue( "MODEL_V63", "V63_VLPATR", FTafGetVal( cV63Path + "/vlrPatrocFunp", "N", .F., @aIncons, .F. ) )
								EndIf

								nV63++
								cV63Path	:= cV60Path + "/previdCompl[" + CValToChar( nV63 ) + "]"

							EndDo

							// infoProcRet
							nV64 		:= 1
							cV64Path	:= cV60Path + "/infoProcRet[1]"

							While oDados:XPathHasNode( cV64Path )

								oModel:GetModel( "MODEL_V64" ):lValid := .T.

								If nV64 > 1; oModel:GetModel( "MODEL_V64" ):AddLine(); EndIf

								oModel:LoadValue( "MODEL_V64", "V64_TPPROC", FTafGetVal( cV64Path + "/tpProcRet" 	, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V64", "V64_NRPROC", FTafGetVal( cV64Path + "/nrProcRet" 	, "C", .F., @aIncons, .F. ) )

								If oDados:XPathHasNode( cV64Path + "/codSusp" )
									oModel:LoadValue( "MODEL_V64", "V64_CODSUP", FTafGetVal( cV64Path + "/codSusp", "C", .F., @aIncons, .F. ) )
								EndIF

								// infoValores
								nV65 		:= 1
								cV65Path	:= cV64Path + "/infoValores[1]"

								While oDados:XPathHasNode( cV65Path )

									oModel:GetModel( "MODEL_V65" ):lValid := .T.

									If nV65 > 1; oModel:GetModel( "MODEL_V65" ):AddLine(); EndIf

									oModel:LoadValue( "MODEL_V65", "V65_INDAPU", FTafGetVal( cV65Path + "/indApuracao", "C", .F., @aIncons, .F. ) )
									
									If oDados:XPathHasNode( cV65Path + "/vlrNRetido" )
										oModel:LoadValue( "MODEL_V65", "V65_VLRRET", FTafGetVal( cV65Path + "/vlrNRetido", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cV65Path + "/vlrDepJud" )
										oModel:LoadValue( "MODEL_V65", "V65_VLRJUD", FTafGetVal( cV65Path + "/vlrDepJud", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cV65Path + "/vlrCmpAnoCal" )
										oModel:LoadValue( "MODEL_V65", "V65_VLACAL", FTafGetVal( cV65Path + "/vlrCmpAnoCal", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cV65Path + "/vlrCmpAnoAnt" )
										oModel:LoadValue( "MODEL_V65", "V65_VLAANT", FTafGetVal( cV65Path + "/vlrCmpAnoAnt", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cV65Path + "/vlrRendSusp" )
										oModel:LoadValue( "MODEL_V65", "V65_VLSUSP", FTafGetVal( cV65Path + "/vlrRendSusp", "N", .F., @aIncons, .F. ) )
									EndIf

									// dedSusp
									nV66		:= 1
									cV66Path	:= cV65Path + "/dedSusp[1]"

									While oDados:XPathHasNode( cV66Path )

										oModel:GetModel( "MODEL_V66" ):lValid := .T.	

										If nV66 > 1; oModel:GetModel( "MODEL_V66" ):AddLine(); EndIf

										oModel:LoadValue( "MODEL_V66", "V66_SEQUEN", StrZero(nV66, TamSX3("V66_SEQUEN")[1]) )

										oModel:LoadValue( "MODEL_V66", "V66_TPDEDU", FTafGetVal( cV66Path + "/indTpDeducao", "C", .F., @aIncons, .F. ) )
										
										If oDados:XPathHasNode( cV66Path + "/vlrDedSusp" )
											oModel:LoadValue( "MODEL_V66", "V66_VLSUSP", FTafGetVal( cV66Path + "/vlrDedSusp", "N", .F., @aIncons, .F. ) )
										EndIf

										If oDados:XPathHasNode( cV66Path + "/cnpjEntidPC" )
											oModel:LoadValue( "MODEL_V66", "V66_INSCPL", FTafGetVal( cV66Path + "/cnpjEntidPC", "C", .F., @aIncons, .F. ) )
										EndIf

										If oDados:XPathHasNode( cV66Path + "/vlrPatrocFunp" )
											oModel:LoadValue( "MODEL_V66", "V66_VLFUNP", FTafGetVal( cV66Path + "/vlrPatrocFunp", "N", .F., @aIncons, .F. ) )
										EndIf

										// benefPen
										nV67		:= 1
										cV67Path	:= cV66Path + "/benefPen[1]"

										While oDados:XPathHasNode( cV67Path )

											oModel:GetModel( "MODEL_V67" ):lValid := .T.

											If nV67 > 1; oModel:GetModel( "MODEL_V67" ):AddLine(); EndIf

											oModel:LoadValue( "MODEL_V67", "V67_CPFDEP", FTafGetVal( cV67Path + "/cpfDep" 		, "C", .F., @aIncons, .F. ) )
											oModel:LoadValue( "MODEL_V67", "V67_VLSUSP", FTafGetVal( cV67Path + "/vlrDepenSusp" , "N", .F., @aIncons, .F. ) )

											nV67++
											cV67Path	:= cV66Path + "/benefPen[" + CValToChar( nV67 ) + "]"

										EndDo

										nV66++
										cV66Path	:= cV65Path + "/dedSusp[" + CValToChar( nV66 ) + "]"

									EndDo

									nV65++
									cV65Path	:= cV65Path + "/infoValores[" + CValToChar( nV65 ) + "]"

								EndDo

								nV64++
								cV64Path	:= cCabec + cV60Path + "/infoProcRet[" + CValToChar( nV64 ) + "]"

							EndDo

							nV60++
							cV60Path	:= cT8HPath + "/infoIRCR[" + CValToChar( nV60 ) + "]"

						EndDo

						// planSaude
						nV68 		:= 1
						cV68Path	:= cT8HPath + "/planSaude[1]"

						While oDados:XPathHasNode( cV68Path )

							oModel:GetModel( "MODEL_V68" ):lValid := .T.

							If nV68 > 1
								oModel:GetModel( "MODEL_V68" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_V68", "V68_CNPJOP", FTafGetVal( cV68Path + "/cnpjOper", "C", .F., @aIncons, .F. ) )

							If oDados:XPathHasNode( cV68Path + "/regANS" )
								oModel:LoadValue( "MODEL_V68", "V68_REGANS", FTafGetVal( cV68Path + "/regANS", "C", .F., @aIncons, .F. ) )
							EndIf

							oModel:LoadValue( "MODEL_V68", "V68_VLRTIT", FTafGetVal( cV68Path + "/vlrSaudeTit", "N", .F., @aIncons, .F. ) )

							// infoDepSau
							nV69 		:= 1
							cV69Path	:= cV68Path + "/infoDepSau[1]"

							While oDados:XPathHasNode( cV69Path ) 

								oModel:GetModel( "MODEL_V69" ):lValid := .T.

								If nV69 > 1
									oModel:GetModel( "MODEL_V69" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V69", "V69_CPFDEP", FTafGetVal( cV69Path + "/cpfDep" 		, "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V69", "V69_VLRDEP", FTafGetVal( cV69Path + "/vlrSaudeDep" 	, "N", .F., @aIncons, .F. ) )

								nV69++
								cV69Path	:= cV68Path + "/infoDepSau[" + CValToChar( nV69 ) + "]"

							EndDo

							nV68++
							cV68Path	:= cT8HPath + "/planSaude[" + CValToChar( nV68 ) + "]"
							
						EndDo

						// infoReembMed
						nV6A 		:= 1
						cV6APath	:= cT8HPath + "/infoReembMed[1]"

						While oDados:XPathHasNode( cV6APath )

							oModel:GetModel( "MODEL_V6A" ):lValid := .T.

							If nV6A > 1; oModel:GetModel( "MODEL_V6A" ):AddLine(); EndIf

							oModel:LoadValue( "MODEL_V6A", "V6A_INDREM", FTafGetVal( cV6APath + "/indOrgReemb", "C", .F., @aIncons, .F. ) )
							
							If oDados:XPathHasNode( cV6APath + "/cnpjOper" )
								oModel:LoadValue( "MODEL_V6A", "V6A_CNPJOP", FTafGetVal( cV6APath + "/cnpjOper", "C", .F., @aIncons, .F. ) )
							EndIf

							If oDados:XPathHasNode( cV6APath + "/regANS" )
								oModel:LoadValue( "MODEL_V6A", "V6A_REGANS", FTafGetVal( cV6APath + "/regANS", "C", .F., @aIncons, .F. ) )
							EndIf

							// detReembTit
							nV54 		:= 1
							cV54Path	:= cV6APath + "/detReembTit[1]"

							While oDados:XPathHasNode( cV54Path )

								oModel:GetModel( "MODEL_V54" ):lValid := .T.

								If nV54 > 1; oModel:GetModel( "MODEL_V54" ):AddLine(); EndIf

								oModel:LoadValue( "MODEL_V54", "V54_TPINSC", FTafGetVal( cV54Path + "/tpInsc", "C", .F., @aIncons, .F. ) )
								oModel:LoadValue( "MODEL_V54", "V54_NRINSC", FTafGetVal( cV54Path + "/nrInsc", "C", .F., @aIncons, .F. ) )
									
								If oDados:XPathHasNode( cV54Path + "/vlrReemb" )
									oModel:LoadValue( "MODEL_V54", "V54_VLREMB", FTafGetVal( cV54Path + "/vlrReemb", "N", .F., @aIncons, .F. ) )
								EndIf

								If oDados:XPathHasNode( cV54Path + "/vlrReembAnt" )
									oModel:LoadValue( "MODEL_V54", "V54_VLRANT", FTafGetVal( cV54Path + "/vlrReembAnt", "N", .F., @aIncons, .F. ) )
								EndIf

								nV54++
								cV54Path	:= cV6APath + "/detReembTit[" + CValToChar( nV54 ) + "]"

							EndDo

							// infoReembDep
							nV50 		:= 1
							cV50Path	:= cV6APath + "/infoReembDep[1]"

							While oDados:XPathHasNode( cV50Path )

								oModel:GetModel( "MODEL_V50" ):lValid := .T.

								If nV50 > 1 
									oModel:GetModel( "MODEL_V50" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V50", "V50_CPFDEP", FTafGetVal( cV50Path + "/cpfBenef", "C", .F., @aIncons, .F. ) )
			
								// detReembDep
								nV51 		:= 1
								cV51Path	:= cV50Path + "/detReembDep[1]"

								While oDados:XPathHasNode( cV51Path )

									oModel:GetModel( "MODEL_V51" ):lValid := .T.

									If nV51 > 1
										oModel:GetModel( "MODEL_V51" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_V51", "V51_TPINSC", FTafGetVal( cV51Path + "/tpInsc", "C", .F., @aIncons, .F. ) )
									oModel:LoadValue( "MODEL_V51", "V51_NRINSC", FTafGetVal( cV51Path + "/nrInsc", "C", .F., @aIncons, .F. ) )
									
									If oDados:XPathHasNode( cV51Path + "/vlrReemb" )
										oModel:LoadValue( "MODEL_V51", "V51_VLREMB", FTafGetVal( cV51Path + "/vlrReemb", "N", .F., @aIncons, .F. ) )
									EndIf

									If oDados:XPathHasNode( cV51Path + "/vlrReembAnt" )
										oModel:LoadValue( "MODEL_V51", "V51_VLRANT", FTafGetVal( cV51Path + "/vlrReembAnt", "N", .F., @aIncons, .F. ) )
									EndIf

									nV51++
									cV51Path	:= cV50Path + "/detReembDep[" + CValToChar( nV51 ) + "]"

								EndDo

								nV50++
								cV50Path	:= cV6APath + "/infoReembDep[" + CValToChar( nV50 ) + "]"

							EndDo

							nV6A++
							cV6APath	:= cT8HPath + "/infoReembMed[" + CValToChar( nV6A ) + "]"

						EndDo
						
						nT8H++
						cT8HPath	:= cCabec + "ideTrabalhador/infoIRComplem[" + CValToChar( nT8H ) + "]"

					EndDo

				EndIf

			EndIf

			If Empty(cInconMsg)

				If TafFormCommit( oModel )

					Aadd(aIncons, "ERRO19")

				Else

					lRet := .T.

					If lInfoRPT

						cCPF 	:= FTAFGetVal(cCabec + "ideTrabalhador/cpfBenef", "C", .F.,, .F.)
						cNome	:= TAFGetNT1U(cCPF)

						If Empty(cNome)

							C9V->(DbSetOrder(3))

							If C9V->(MsSeek(xFilial("C9V") + cCPF + "1"))
								cNome := C9V->C9V_NOME
							Else
								cNome := TAFGetNT3A(cCPF)
							EndIf

						EndIf

						oInfoRPT := oReport:oVOReport
						
						oInfoRPT:SetIndApu(IIf(Len(StrTran(cPeriodo, "-", "")) <= 4, "2", "1"))
						oInfoRPT:SetPeriodo(AllTrim(StrTran(cPeriodo, "-", "")))
						oInfoRPT:SetCPF(AllTrim(cCPF))
						oInfoRPT:SetNome(AllTrim(cNome))
						oInfoRPT:SetRecibo(AllTrim(cRecibo))
						oInfoRPT:SetAnalitico(aAnalitico)

						oReport:UpSert("S-1210", "4", xFilial("T2G"), oInfoRPT)

					EndIf

				EndIf

			Else

				Aadd(aIncons, cInconMsg)

			EndIf

			oModel:DeActivate()

		Endif

	End Transaction

	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

	oModel := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF422Rul

Regras para gravacao dos Imposto de Renda Retido na Fonte S-5002 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF422Rul()

	Local aRull		:= {}
	Local cCabec	:= "/eSocial/evtIrrfBenef/"
	Local cPeriodo	:= FTafGetVal(  cCabec + "ideEvento/perApur", "C", .F.,, .F. )

	aAdd( aRull, {"T2G_RECBAS", FTafGetVal(cCabec + "ideEvento/nrRecArqBase"	, "C", .F.,, .F. ) 		, "C", .T.} )

	If At("-", cPeriodo) > 0
		aAdd( aRull, {"T2G_PERAPU",  StrTran(cPeriodo, "-", "" ), "C", .T.} )
	Else
		aAdd( aRull, {"T2G_PERAPU",  cPeriodo						, "C", .T.} )
	EndIf

	If !lLaySimplif

		aAdd( aRull, {"T2G_CPFTRA",  FTafGetVal(cCabec + "ideTrabalhador/cpfTrab"			, "C", .F.,, .F. ), "C", .T. } )
		aAdd( aRull, {"T2G_VRDEDD",  FTafGetVal(cCabec + "infoDep/vrDedDep"					, "N", .F.,, .F. ), "N", .T. } )

	Else

		aAdd( aRull, {"T2G_CPFBEN",  FTafGetVal(cCabec + "ideTrabalhador/cpfBenef"			, "C", .F.,, .F. ), "C", .T. } )

	EndIf

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF422Xml
Funcao de geracao do XML para atender o registro S-5002
Quando a rotina for chamada o registro deve estar posicionado

@Param:

@Return:
cXml - Estrutura do Xml do Layout S-5002

@author Daniel Schmidt
@since 29/05/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF422Xml(cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical) as Character

	Local lXmlVLd     as Logical
	Local cXml        as Character
	Local cXmlAux     as Character
	Local cLayout     as Character
	Local cReg        as Character
	Local cPerRef     as Character
	Local cXmlendExt  as Character
	Local cXmlidePais as Character
	Local cXmlidePgE  as Character
	Local cFilBkp     as Character
	Local cTipoTr	  as Character
	Local cDescRe	  as Character
	Local aMensal     as Array
	
	Default cAlias    := "T2G"

	lTroca      := .F.
	lXmlVLd     := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF422XML' ),.T.)
	cXml        := ""
	cXmlAux     := ""
	cLayout     := "5002"
	cReg        := "IrrfBenef"
	cPerRef     := ""
	cXmlendExt  := ""
	cXmlidePais := ""
	cXmlidePgE  := ""
	cFilBkp     := cFilAnt
	aMensal     := {}

	If lSimpl12 == Nil 
		lSimpl12 := TafLayESoc("S_01_02_00",, .T.)
	EndIf

	If lSimpl0103 == Nil 
		lSimpl0103 := TafLayESoc("S_01_03_00",, .T.)
	EndIf 

	cFilAnt     := T2G->T2G_FILIAL

	If lXmlVLd
		
		AADD(aMensal,T2G->T2G_RECBAS)

		If Len(Alltrim(T2G->T2G_PERAPU)) <= 4
			AADD(aMensal,T2G->T2G_PERAPU)
		Else
			AADD(aMensal,substr(T2G->T2G_PERAPU, 1, 4) + '-' + substr(T2G->T2G_PERAPU, 5, 2) )
		EndIf

		cXml +=	"<ideTrabalhador>"

		If !lLaySimplif .And. !lSimpl12

			cXml +=		xTafTag("cpfTrab",T2G->T2G_CPFTRA)

		Else
			
			V6J->( DbSetOrder( 1 ) )
			T2I->( DbSetOrder( 2 ) )

			If lSimpl12 .And. TafColumnPos("V8J_NRPROC")
				V8J->( DbSetOrder( 1 ) )
			EndIf	

			cXml += xTafTag("cpfBenef",T2G->T2G_CPFBEN)

			If V6J->( MsSeek( xFilial("V6J")+T2G->(T2G_ID+T2G_VERSAO) ) )

				While !V6J->(Eof()) .AND. AllTrim(V6J->(V6J_ID+V6J_VERSAO)) == AllTrim(T2G->(T2G_ID+T2G_VERSAO))

					cXml +=	"<dmDev>"

					If Len(Alltrim(V6J->V6J_PERREF)) <= 4
						cPerRef := V6J->V6J_PERREF
					Else
						cPerRef := SubStr(V6J->V6J_PERREF, 1, 4) + '-' + SubStr(V6J->V6J_PERREF, 5, 2)
					EndIf
					
					cXml +=		xTafTag("perRef"	,cPerRef)
					cXml +=		xTafTag("ideDmDev"	,V6J->V6J_INDDEV)
					cXml +=		xTafTag("tpPgto"	,V6J->V6J_TPPAG	)
					cXml +=		xTafTag("dtPgto"	,V6J->V6J_DTPAG	)
					cXml +=	    xTafTag("codCateg"  ,POSICIONE("C87",1, xFilial("C87")+V6J->V6J_CODCAT,"C87_CODIGO"),, .T.)
			
					If T2I->( MsSeek( xFilial("T2I")+V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG) ) )
						
						While !T2I->(Eof()) .And. AllTrim(T2I->(T2I_ID+T2I_VERSAO+T2I_SEQUEN+T2I_PERREF+T2I_INDDEV+T2I_TPPAG)) == AllTrim(V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG))

							cTipoTr :=  POSICIONE("C8U",1, xFilial("C8U")+T2I->T2I_CTPVAL,"C8U_CODIGO")							
							cXml +=	"<infoIR>"
							cXml +=		xTafTag("tpInfoIR",cTipoTr)
							cXml +=		xTafTag("valor",T2I->T2I_VLIRRF,PesqPict("T2I","T2I_VLIRRF"),,, .T.)

							If lSimpl0103 .AND. TafColumnPos("T2I_DESCRE") 
								cDescRe :=   IIf( cTipoTr <> '79', T2I->T2I_DESCRE, POSICIONE("C8U",1, xFilial("C8U")+T2I->T2I_CTPVAL,"C8U_DESCRI"))
								cXml +=		xTafTag("descRendimento",cDescRe,,,, .T.)
							EndIf

							If lSimpl12 .And. TafColumnPos("V8J_NRPROC")

								If V8J->( MsSeek( xFilial("V8J")+T2I->(T2I_ID+T2I_VERSAO+T2I_SEQUEN+T2I_INDDEV+T2I_TPPAG+T2I_PERREF+T2I_CTPVAL) ) )

									While !V8J->(Eof()) .And. AllTrim(V8J->(V8J_ID+V8J_VERSAO+V8J_SEQUEN+V8J_INDDEV+V8J_TPPAG+V8J_PERREF+V8J_CTPVAL)) == AllTrim(T2I->(T2I_ID+T2I_VERSAO+T2I_SEQUEN+T2I_INDDEV+T2I_TPPAG+T2I_PERREF+T2I_CTPVAL))

										cXml +=	"<infoProcJudRub>"
										cXml +=		xTafTag("nrProc" 	,V8J->V8J_NRPROC,,.F. )
										cXml +=		xTafTag("ufVara" 	,V8J->V8J_UFVARA,,.F. )
										cXml +=		xTafTag("codMunic"	,V8J->V8J_CODMUN,,.F. )
										cXml +=		xTafTag("idVara"	,V8J->V8J_IDVARA,,.F. )
										cXml +=	"</infoProcJudRub>"

										V8J->(DbSkip())

									EndDo

								EndIf	

							EndIf

							cXml +=	"</infoIR>"

							cDescRe := ""

							T2I->(DbSkip())

						EndDo

					EndIf

					V7M->( DbSetOrder( 1 ) )

					If V7M->( MsSeek( xFilial("V7M")+V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG) ) )
						
						While !V7M->(Eof()) .And. AllTrim(V7M->(V7M_ID+V7M_VERSAO+V7M_SEQUEN+V7M_PERREF+V7M_INDDEV+V7M_TPPAG)) == AllTrim(V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG))

							cXml +=	"<totApurMen>"
							cXml +=		xTafTag("CRMen"	,V7M->V7M_CRMEN )
							cXml +=		xTafTag("vlrCRMen" ,V7M->V7M_VLMEN,PesqPict("V7M","V7M_VLMEN") )

							If lSimpl0103 .AND. TafColumnPos("V7M_RENDTR")

								cDescRe :=   IIf( cTipoTr <> '79', V7M->V7M_DESCRE, POSICIONE("C8U",1, xFilial("C8U")+"000037","C8U_DESCRI"))

								cXml +=		xTafTag("vlrRendTrib" ,V7M->V7M_RENDTR,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrRendTrib13" ,V7M->V7M_REND13,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrPrevOficial" ,V7M->V7M_PREVOF,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrPrevOficial13" ,V7M->V7M_PREV13,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrCR13Men" ,V7M->V7M_VMEN13,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrParcIsenta65" ,V7M->V7M_PARI65,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrParcIsenta65Dec" ,V7M->V7M_I65DEC,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrDiarias" ,V7M->V7M_VLRDIA,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrAjudaCusto" ,V7M->V7M_VLRAJU,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrIndResContrato" ,V7M->V7M_VLRCON,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrAbonoPec" ,V7M->V7M_VLRABN,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrRendMoleGrave" ,V7M->V7M_VLRIMG,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrRendMoleGrave13" ,V7M->V7M_IMG13,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrAuxMoradia" ,V7M->V7M_VLMORD,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrBolsaMedico" ,V7M->V7M_BOLMED,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrBolsaMedico13" ,V7M->V7M_BOLM13,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrJurosMora" ,V7M->V7M_JURMOR,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("vlrIsenOutros" ,V7M->V7M_ISEOUT,PesqPict("V7M","V7M_VLMEN") )
								cXml +=		xTafTag("descRendimento" ,cDescRe, )

							EndIf

							If !lSimpl12
								cXml +=		xTafTag("vlrCRMenSusp"	,V7M->V7M_VLSUSP,PesqPict("V7M","V7M_VLSUSP") )
							EndIf	

							cXml +=	"</totApurMen>"

							cDescRe := ""

							V7M->(DbSkip())

						EndDo

					EndIf

					V7N->( DbSetOrder( 1 ) )

					If V7N->( MsSeek( xFilial("V7N")+V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG) ) )
						
						While !V7N->(Eof()) .And. AllTrim(V7N->(V7N_ID+V7N_VERSAO+V7N_SEQUEN+V7N_PERREF+V7N_INDDEV+V7N_TPPAG)) == AllTrim(V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_PERREF+V6J_INDDEV+V6J_TPPAG))

							cXml +=	"<totApurDia>"
							cXml +=		xTafTag("perApurDia"	,V7N->V7N_PERDIA )
							cXml +=		xTafTag("CRDia" ,V7N->V7N_CRDIA )
							cXml +=		xTafTag("vlrCRDia"	,V7N->V7N_VLCRD,PesqPict("V7N","V7N_VLCRD") )

							If !lSimpl12
								cXml +=     xTafTag("vlrCRDiaSusp"	,V7N->V7N_VLSUS,PesqPict("V7N","V7N_VLSUS") )
							EndIf	

							If lSimpl0103 .AND. TAFColumnPos("V7N_FRMTRI")
								cXml +=		xTafTag("frmTribut" ,V7N->V7N_FRMTRI )
								cXml +=		xTafTag("paisResidExt",V7N->V7N_PAISEX )
								cXml +=		xTafTag("vlrPagoDia" ,V7N->V7N_PAGDIA, PesqPict("V7N","V7N_VLCRD") )
							EndIf

							cXml +=	"</totApurDia>"

							V7N->(DbSkip())

						EndDo

					EndIf
					
					If lSimpl12 .And. TafColumnPos("V8J_NRPROC")

						V8T->( DbSetOrder( 1 ) )
						V52->( DbSetOrder( 1 ) )
						V53->( DbSetOrder( 1 ) )
						V8H->( DbSetOrder( 1 ) )

						If V8T->( MsSeek( xFilial("V8T")+V6J->(V6J_ID+V6J_VERSAO+V6J_SEQUEN+V6J_INDDEV+V6J_TPPAG+V6J_PERREF) ) )
							
							cXml +=	"<infoRRA>"
							cXml +=		xTafTag("tpProcRRA"		,V8T->V8T_TPPROC,,.F. )
							cXml +=		xTafTag("nrProcRRA" 	,V8T->V8T_NRPRRA,,.T. )
							cXml +=		xTafTag("descRRA"		,V8T->V8T_DESCRA,,.F. )
							cXml +=     xTafTag("qtdMesesRRA"	,V8T->V8T_QTMRRA,,.F. )

								If V52->( MsSeek( xFilial("V52")+V8T->(V8T_ID+V8T_VERSAO+V8T_SEQV6J+V8T_INDDEV+V8T_TPPAG+V8T_PERREF+V8T_SEQRRA) ) )
									
									cXml +=	"<despProcJud>"
									cXml +=		xTafTag("vlrDespCustas"		,V52->V52_VLDEPC,PesqPict("V52","V52_VLDEPC"),.F. )
									cXml +=		xTafTag("vlrDespAdvogados" 	,V52->V52_VLDADV,PesqPict("V52","V52_VLDADV"),.F. )
									cXml +=	"</despProcJud>"	

								EndIf

								If V53->( MsSeek( xFilial("V53")+V8T->(V8T_ID+V8T_VERSAO+V8T_SEQV6J+V8T_INDDEV+V8T_TPPAG+V8T_PERREF+V8T_SEQRRA) ) )
									
									While !V53->(Eof()) .And. AllTrim(V53->(V53_ID+V53_VERSAO+V53_SEQV6J+V53_INDDEV+V53_TPPAG+V53_PERREF+V53_SEQRRA)) == AllTrim(V8T->(V8T_ID+V8T_VERSAO+V8T_SEQV6J+V8T_INDDEV+V8T_TPPAG+V8T_PERREF+V8T_SEQRRA))

										cXml +=	"<ideAdv>"
										cXml +=		xTafTag("tpInsc"		,V53->V53_TPINSC,,.F. )
										cXml +=		xTafTag("nrInsc" 		,V53->V53_NRINSC,,.F. )
										cXml +=		xTafTag("vlrAdv" 		,V53->V53_VLRADV,PesqPict("V53","V53_VLRADV"),.T. )
										cXml +=	"</ideAdv>"
										
										V53->(DbSkip())

									EndDo	

								EndIf

							cXml +=	"</infoRRA>"

						EndIf

						If V8H->( MsSeek( xFilial("V8H")+T2G->(T2G_ID+T2G_VERSAO) ) )
							
							cXml +=	"<infoPgtoExt>"
							cXml +=		xTafTag("paisResidExt"		,V8H->V8H_PAISEX,,.F. )
							cXml +=		xTafTag("indNIF"			,V8H->V8H_INDNIF,,.F. )
							cXml +=		xTafTag("nifBenef"			,V8H->V8H_NIFBEN,,.T. )
							cXml +=		xTafTag("frmTribut"			,V8H->V8H_FRMTRI,,.F. )
							cXml +=		"<endExt>"
							cXml +=			xTafTag("endDscLograd"		,V8H->V8H_ENDLOG,,.T. )
							cXml +=			xTafTag("endNrLograd"		,V8H->V8H_ENDNUM,,.T. )
							cXml +=			xTafTag("endComplem"		,V8H->V8H_ENDCOM,,.T. )
							cXml +=			xTafTag("endBairro"			,V8H->V8H_ENDBAI,,.T. )
							cXml +=			xTafTag("endCidade"			,V8H->V8H_ENDCID,,.T. )
							cXml +=			xTafTag("endEstado"			,V8H->V8H_ENDEST,,.T. )
							cXml +=			xTafTag("endCodPostal"		,V8H->V8H_CODPOS,,.T. )
							cXml +=			xTafTag("telef"				,V8H->V8H_ENDTEL,,.T. )
							cXml +=		"</endExt>"
							cXml +=	"</infoPgtoExt>"

						EndIf

					EndIf	

					cXml +=	"</dmDev>"

					V6J->(DbSkip())

				EndDo

			EndIf

			
			If lSimpl0103 .AND. TafColumnPos("T8G_CRMEN")

				T8G->( DbSetOrder( 1 ) )
				If T8G->( MsSeek( xFilial("T8G")+T2G->(T2G_ID+T2G_VERSAO) ) )

					cXml +=	"<totInfoIR>"

					While !T8G->(Eof()) .AND. AllTrim(T8G->(T8G_ID+T8G_VERSAO)) == AllTrim(T2G->(T2G_ID+T2G_VERSAO))
						
						cDescRe :=   IIf( cTipoTr <> '79', T8G->T8G_DESCRE, POSICIONE("C8U",1, xFilial("C8U")+"000037","C8U_DESCRI"))

						cXml +=	"<consolidApurMen>"
							cXml +=			xTafTag("CRMen"				,T8G->T8G_CRMEN ,,.T. )
							cXml +=			xTafTag("vlrRendTrib"		,T8G->T8G_RENDTR,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrRendTrib13"		,T8G->T8G_RENT13,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrPrevOficial"	,T8G->T8G_PREVOF,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrPrevOficial13"	,T8G->T8G_PROF13,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrCRMen"		    ,T8G->T8G_VCRMEN,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrCR13Men"		,T8G->T8G_CR13ME,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrParcIsenta65"	,T8G->T8G_PAIS65,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrParcIsenta65Dec",T8G->T8G_PIS65D,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrDiarias"		,T8G->T8G_VLDIAR,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrAjudaCusto"		,T8G->T8G_VLAJUC,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrIndResContrato"	,T8G->T8G_VINRES,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrAbonoPec"		,T8G->T8G_ABONPE,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrRendMoleGrave"	,T8G->T8G_VLRIMG,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrRendMoleGrave13",T8G->T8G_IMG13 ,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrAuxMoradia"		,T8G->T8G_VLMORD,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrBolsaMedico"	,T8G->T8G_BOLMED,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrBolsaMedico13"	,T8G->T8G_BOLM13,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrJurosMora"		,T8G->T8G_JURMOR,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("vlrIsenOutros"		,T8G->T8G_ISEOUT,PesqPict("V62","V62_VLPEN"),.T. )
							cXml +=			xTafTag("descRendimento"	,cDescRe,,.T. )
						cXml +=	"</consolidApurMen>"

						cDescRe := ""
						T8G->(DbSkip())
					
					EndDo

					cXml +=	"</totInfoIR>"

					T8G->(DbCloseArea())
				EndIf

			EndIf

			If lSimpl12 .And. ( !lSimpl0103 .OR. !TafColumnPos("T8H_DTLAUD") )

				V8V->( DbSetOrder( 1 ) )
				V60->( DbSetOrder( 1 ) )
				V61->( DbSetOrder( 1 ) )
				V62->( DbSetOrder( 1 ) )
				V63->( DbSetOrder( 1 ) )
				V64->( DbSetOrder( 1 ) )
				V65->( DbSetOrder( 1 ) )
				V66->( DbSetOrder( 1 ) )
				V67->( DbSetOrder( 1 ) )
				V68->( DbSetOrder( 1 ) )
				V69->( DbSetOrder( 1 ) )
				V6A->( DbSetOrder( 1 ) )
				V54->( DbSetOrder( 1 ) )
				V50->( DbSetOrder( 1 ) )
				V51->( DbSetOrder( 1 ) )

				cXmlAux +=	"<infoIRComplem>"
				cXmlAux +=		xTafTag("dtLaudo"		,T2G->T2G_DTLAUD,,.T.)					

				If V8V->(MsSeek(xFilial("V8V") + T2G->(T2G_ID + T2G_VERSAO + T2G_PERAPU + T2G_CPFTRA + T2G_CPFBEN) ) )
						
					While !V8V->(Eof()) .And. V8V->(V8V_FILIAL + V8V_ID + V8V_VERSAO + V8V_PERAPU + V8V_CPFTRA + V8V_CPFBEN) == xFilial("T2G") + T2G->(T2G_ID + T2G_VERSAO + T2G_PERAPU + T2G_CPFTRA + T2G_CPFBEN)

						cXmlAux +=		"<ideDep>"
						cXmlAux +=			xTafTag("cpfDep"		,V8V->V8V_CPFDEP,,.F. )
						cXmlAux +=			xTafTag("depIRRF"		,V8V->V8V_DEPIRR,,.T. )
						cXmlAux +=			xTafTag("dtNascto"		,V8V->V8V_DTNASC,,.T. )
						cXmlAux +=			xTafTag("nome"			,V8V->V8V_NOME  ,,.T. )
						cXmlAux +=			xTafTag("tpDep"			,V8V->V8V_TPDEP ,,.T. )
						cXmlAux +=			xTafTag("descrDep"		,V8V->V8V_DESCDE,,.T. )
						cXmlAux +=		"</ideDep>"

						V8V->(DbSkip())

					EndDo	

				EndIf

				If V60->(MsSeek(xFilial("V60") + T2G->(T2G_ID + T2G_VERSAO) ) )
						
					While !V60->(Eof()) .And. V60->(V60_FILIAL + V60_ID + V60_VERSAO) == xFilial("T2G") + T2G->(T2G_ID + T2G_VERSAO)

						cXmlAux +=		"<infoIRCR>"
						cXmlAux +=			xTafTag("tpCR"		,V60->V60_TPCR  ,,.F. )

						If V61->(MsSeek(xFilial("V61") + V60->(V60_ID + V60_VERSAO + V60_TPCR) ) )

							While !V61->(Eof()) .And. V61->(V61_FILIAL + V61_ID + V61_VERSAO + V61_TPCR) == xFilial("V60") + V60->(V60_ID + V60_VERSAO + V60_TPCR)
									
								cXmlAux +=		"<dedDepen>"
								cXmlAux +=			xTafTag("tpRend"		,V61->V61_TPREND,,.F. )
								cXmlAux +=			xTafTag("cpfDep"		,V61->V61_CPFDEP,,.F. )
								cXmlAux +=			xTafTag("vlrDedDep"		,V61->V61_VLRDED,PesqPict("V61","V61_VLRDED"),.F. )
								cXmlAux +=		"</dedDepen>"

								V61->(DbSkip())

							EndDo

						EndIf	

						If V62->(MsSeek(xFilial("V62") + V60->(V60_ID + V60_VERSAO + V60_TPCR) ) )

							While !V62->(Eof()) .And.  V62->(V62_FILIAL + V62_ID + V62_VERSAO + V62_TPCR) == xFilial("V60") + V60->(V60_ID + V60_VERSAO + V60_TPCR)
									
								cXmlAux +=		"<penAlim>"
								cXmlAux +=			xTafTag("tpRend"			,V62->V62_TPREND,,.F. )
								cXmlAux +=			xTafTag("cpfDep"			,V62->V62_CPFDEP,,.F. )
								cXmlAux +=			xTafTag("vlrDedPenAlim"		,V62->V62_VLPEN ,PesqPict("V62","V62_VLPEN"),.F. )
								cXmlAux +=		"</penAlim>"

								V62->(DbSkip())

							EndDo

						EndIf	

						If V63->(MsSeek(xFilial("V63") + V60->(V60_ID + V60_VERSAO + V60_TPCR) ) )

							While !V63->(Eof()) .And. V63->(V63_FILIAL + V63_ID + V63_VERSAO + V63_TPCR) == xFilial("V60") + V60->(V60_ID + V60_VERSAO + V60_TPCR)
									
								cXmlAux +=		"<previdCompl>"
								cXmlAux +=			xTafTag("tpPrev"			,V63->V63_TPREV ,,.F. )
								cXmlAux +=			xTafTag("cnpjEntidPC"		,V63->V63_INSCPL,,.F. )
								cXmlAux +=			xTafTag("vlrDedPC"			,V63->V63_VLCOMP,PesqPict("V63","V63_VLCOMP"),.F. )
								cXmlAux +=			xTafTag("vlrPatrocFunp"		,V63->V63_VLPATR,PesqPict("V63","V63_VLPATR"),.T. )
								cXmlAux +=		"</previdCompl>"

								V63->(DbSkip())

							EndDo
								
						EndIf

						If V64->(MsSeek(xFilial("V64") + V60->(V60_ID + V60_VERSAO + V60_TPCR) ) )

							While !V64->(Eof()) .And. V64->(V64_FILIAL + V64_ID + V64_VERSAO + V64_TPCR) == xFilial("V60") + V60->(V60_ID + V60_VERSAO + V60_TPCR)
									
								cXmlAux +=		"<infoProcRet>"
								cXmlAux +=			xTafTag("tpProcRet"			,V64->V64_TPPROC ,,.F. )
								cXmlAux +=			xTafTag("nrProcRet"			,V64->V64_NRPROC,,.F. )
								cXmlAux +=			xTafTag("codSusp"			,V64->V64_CODSUP,,.T. )

								If V65->(MsSeek(xFilial("V65") + V64->(V64_ID + V64_VERSAO + V64_TPCR + V64_TPPROC + V64_NRPROC + V64_CODSUP) ) )

									While !V65->(Eof()) .And. V65->(V65_FILIAL + V65_ID + V65_VERSAO + V65_TPCR + V65_TPPROC + V65_NRPROC + V65_CODSUP) == xFilial("V64") +V64->(V64_ID + V64_VERSAO + V64_TPCR + V64_TPPROC + V64_NRPROC + V64_CODSUP)
											
										cXmlAux +=		"<infoValores>"
										cXmlAux +=			xTafTag("indApuracao"		,V65->V65_INDAPU,,.F. )
										cXmlAux +=			xTafTag("vlrNRetido"		,V65->V65_VLRRET,PesqPict("V65","V65_VLRRET"),.T. )
										cXmlAux +=			xTafTag("vlrDepJud"			,V65->V65_VLRJUD,PesqPict("V65","V65_VLRJUD"),.T. )
										cXmlAux +=			xTafTag("vlrCmpAnoCal"		,V65->V65_VLACAL,PesqPict("V65","V65_VLACAL"),.T. )
										cXmlAux +=			xTafTag("vlrCmpAnoAnt"		,V65->V65_VLAANT,PesqPict("V65","V65_VLAANT"),.T. )
										cXmlAux +=			xTafTag("vlrRendSusp"		,V65->V65_VLSUSP,PesqPict("V65","V65_VLSUSP"),.T. )
											
										If V66->(MsSeek(xFilial("V66") + V65->(V65_ID + V65_VERSAO + V65_TPCR + V65_TPPROC + V65_NRPROC + V65_CODSUP + V65_INDAPU) ) )

											While !V66->(Eof()) .And. V66->(V66_FILIAL + V66_ID + V66_VERSAO + V66_TPCR + V66_TPPROC + V66_NRPROC + V66_CODSUP + V66_INDAPU) == xFilial("V65") + V65->(V65_ID + V65_VERSAO + V65_TPCR + V65_TPPROC + V65_NRPROC + V65_CODSUP + V65_INDAPU)
												
												cXmlAux +=		"<dedSusp>"
												cXmlAux +=			xTafTag("indTpDeducao"		,V66->V66_TPDEDU,,.F. )
												cXmlAux +=			xTafTag("vlrDedSusp"		,V66->V66_VLSUSP,PesqPict("V66","V66_VLSUSP"),.T. )
												cXmlAux +=			xTafTag("cnpjEntidPC"		,V66->V66_INSCPL,,.T. )
												cXmlAux +=			xTafTag("vlrPatrocFunp"		,V66->V66_VLFUNP,PesqPict("V66","V66_VLFUNP"),.T. )

												If V67->(MsSeek(xFilial("V67") + V66->(V66_ID + V66_VERSAO + V66_TPCR + V66_TPPROC + V66_NRPROC + V66_CODSUP + V66_INDAPU + V66_SEQUEN) ) )
														
													While !V67->(Eof()) .And. V67->(V67_FILIAL + V67_ID + V67_VERSAO + V67_TPCR + V67_TPPROC + V67_NRPROC + V67_CODSUP + V67_INDAPU + V67_SEQV66) == xFilial("V66") + V66->(V66_ID + V66_VERSAO + V66_TPCR + V66_TPPROC + V66_NRPROC + V66_CODSUP + V66_INDAPU + V66_SEQUEN)
														
														cXmlAux +=		"<benefPen>"
														cXmlAux +=			xTafTag("cpfDep"			,V67->V67_CPFDEP,,.F. )
														cXmlAux +=			xTafTag("vlrDepenSusp"		,V67->V67_VLSUSP,PesqPict("V67","V67_VLSUSP"),.F. )
														cXmlAux +=		"</benefPen>"

														V67->(DbSkip())
													EndDo

												EndIf

												cXmlAux +=		"</dedSusp>"
												V66->(DbSkip())

											EndDo

										EndIf

										cXmlAux +=		"</infoValores>"

										V65->(DbSkip())

									EndDo

								EndIf

								cXmlAux +=		"</infoProcRet>"
								V64->(DbSkip())

							EndDo
								
						EndIf

						cXmlAux +=		"</infoIRCR>"

						V60->(DbSkip())

					EndDo	

				EndIf

				If V68->(MsSeek(xFilial("V68") + T2G->(T2G_ID + T2G_VERSAO) ) )

					While !V68->(Eof()) .And. V68->(V68_FILIAL + V68_ID + V68_VERSAO) == xFilial("T2G") + T2G->(T2G_ID + T2G_VERSAO)

						cXmlAux +=		"<planSaude>"
						cXmlAux +=			xTafTag("cnpjOper"			,V68->V68_CNPJOP,,.F. )
						cXmlAux +=			xTafTag("regANS"			,V68->V68_REGANS,,.T. )
						cXmlAux +=			xTafTag("vlrSaudeTit"		,V68->V68_VLRTIT,PesqPict("V68","V68_VLRTIT"),.F. )

						If V69->(MsSeek(xFilial("V69")  +V68->(V68_ID + V68_VERSAO + V68_CNPJOP) ) )
								
							While !V69->(Eof()) .And. V69->(V69_FILIAL + V69_ID + V69_VERSAO + V69_CNPJOP) == xFilial("V68") + V68->(V68_ID + V68_VERSAO + V68_CNPJOP)

								cXmlAux +=		"<infoDepSau>"
								cXmlAux +=			xTafTag("cpfDep"			,V69->V69_CPFDEP,,.F. )
								cXmlAux +=			xTafTag("vlrSaudeDep"		,V69->V69_VLRDEP,PesqPict("V69","V69_VLRDEP"),.F. )
								cXmlAux +=		"</infoDepSau>"

								V69->(DbSkip())

							EndDo

						EndIf 

						cXmlAux +=		"</planSaude>"

						V68->(DbSkip())

					EndDo

				EndIf 

				If V6A->(MsSeek(xFilial("V6A") + T2G->(T2G_ID + T2G_VERSAO) ) )

					While !V6A->(Eof()) .And. V6A->(V6A_FILIAL + V6A_ID + V6A_VERSAO) == xFilial("T2G") + T2G->(T2G_ID + T2G_VERSAO)

						cXmlAux +=		"<infoReembMed>"
						cXmlAux +=			xTafTag("indOrgReemb"		,V6A->V6A_INDREM,,.F. )
						cXmlAux +=			xTafTag("cnpjOper"			,V6A->V6A_CNPJOP,,.T. )
						cXmlAux +=			xTafTag("regANS"			,V6A->V6A_REGANS,,.T. )

						If V54->(MsSeek(xFilial("V54") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN) ) )

							While !V54->(Eof()) .And. V54->(V54_FILIAL + V54_ID + V54_VERSAO + V54_SEQUEN) == xFilial("V6A") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN)

								cXmlAux +=		"<detReembTit>"
								cXmlAux +=			xTafTag("tpInsc"			,V54->V54_TPINSC,,.F. )
								cXmlAux +=			xTafTag("nrInsc"			,V54->V54_NRINSC,,.F. )
								cXmlAux +=			xTafTag("vlrReemb"			,V54->V54_VLREMB,PesqPict("V54","V54_VLREMB"),.T. )
								cXmlAux +=			xTafTag("vlrReembAnt"		,V54->V54_VLRANT,PesqPict("V54","V54_VLRANT"),.T. )
								cXmlAux +=		"</detReembTit>"

								V54->(DbSkip())

							EndDo

						EndIf

						If V50->(MsSeek(xFilial("V50") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN) ) )

							While !V50->(Eof()) .And. V50->(V50_FILIAL + V50_ID + V50_VERSAO + V50_SEQUEN) == xFilial("V6A") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN)

								cXmlAux +=		"<infoReembDep>"
								cXmlAux +=			xTafTag("cpfBenef"			,V50->V50_CPFDEP,,.F. )

								If V51->(MsSeek(xFilial("V51") + V50->(V50_ID + V50_VERSAO + V50_SEQUEN + V50_CPFDEP) ) )
									
									While !V51->(Eof()) .And. V51->(V51_FILIAL + V51_ID + V51_VERSAO + V51_SEQUEN + V51_CPFDEP) == xFilial("V50") + V50->(V50_ID + V50_VERSAO + V50_SEQUEN + V50_CPFDEP)

										cXmlAux +=		"<detReembDep>"	
										cXmlAux +=			xTafTag("tpInsc"			,V51->V51_TPINSC,,.F. )
										cXmlAux +=			xTafTag("nrInsc"			,V51->V51_NRINSC,,.F. )
										cXmlAux +=			xTafTag("vlrReemb"			,V51->V51_VLREMB,PesqPict("V51","V51_VLREMB"),.T. )
										cXmlAux +=			xTafTag("vlrReembAnt"		,V51->V51_VLRANT,PesqPict("V51","V51_VLRANT"),.T. )
										cXmlAux +=		"</detReembDep>"

										V51->(DbSkip())
									EndDo

								EndIf

								cXmlAux +=		"</infoReembDep>"

								V50->(DbSkip())

							EndDo

						EndIf
							
						cXmlAux +=		"</infoReembMed>"

						V6A->(DbSkip())

					EndDo

				EndIf

				cXmlAux +=	"</infoIRComplem>"

			ElseIf lSimpl0103
				
				T8H->( DbSetOrder( 1 ) )
				T8G->( DbSetOrder( 1 ) )
				V8V->( DbSetOrder( 2 ) )
				V60->( DbSetOrder( 2 ) )
				V61->( DbSetOrder( 2 ) )
				V62->( DbSetOrder( 2 ) )
				V63->( DbSetOrder( 2 ) )
				V64->( DbSetOrder( 2 ) )
				V65->( DbSetOrder( 2 ) )
				V66->( DbSetOrder( 2 ) )
				V67->( DbSetOrder( 2 ) )
				V68->( DbSetOrder( 2 ) )
				V69->( DbSetOrder( 2 ) )
				V6A->( DbSetOrder( 2 ) )
				V54->( DbSetOrder( 2 ) )
				V50->( DbSetOrder( 2 ) )
				V51->( DbSetOrder( 2 ) )

				If T8H->(MsSeek(xFilial("T8H") + T2G->( T2G_ID + T2G_VERSAO ) ) )

					While !T8H->(Eof()) .And. T8H->(T8H_FILIAL + T8H_ID + T8H_VERSAO  ) == xFilial("T2G") + T2G->(T2G_ID + T2G_VERSAO )

						cXmlAux +=	"<infoIRComplem>"
						cXmlAux +=		xTafTag("dtLaudo"		,T8H->T8H_DTLAUD,,.T.)

						If !Empty(T8H->T8H_PERREF) .OR. !Empty(T8H->T8H_NR1210)
							cXmlAux +=		"<perAnt>"
								cXmlAux +=			xTafTag("perRefAjuste"			,T8H->T8H_PERREF ,,.T. )
								cXmlAux +=			xTafTag("nrRec1210Orig"		    ,T8H->T8H_NR1210 ,,.T. )
							cXmlAux +=		"</perAnt>"		
						EndIf			

						If V8V->(MsSeek(xFilial("V8V") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC ) ) ) //AJUSTAR INDICE
								
							While !V8V->(Eof()) .And. V8V->(V8V_FILIAL + V8V_ID + V8V_VERSAO + V8V_SEQIRC ) == xFilial("T8H") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC)

								cXmlAux +=		"<ideDep>"
								cXmlAux +=			xTafTag("cpfDep"		,V8V->V8V_CPFDEP,,.F. )
								cXmlAux +=			xTafTag("depIRRF"		,V8V->V8V_DEPIRR,,.T. )
								cXmlAux +=			xTafTag("dtNascto"		,V8V->V8V_DTNASC,,.T. )
								cXmlAux +=			xTafTag("nome"			,V8V->V8V_NOME  ,,.T. )
								cXmlAux +=			xTafTag("tpDep"			,V8V->V8V_TPDEP ,,.T. )
								cXmlAux +=			xTafTag("descrDep"		,V8V->V8V_DESCDE,,.T. )
								cXmlAux +=		"</ideDep>"

								V8V->(DbSkip())

							EndDo	

						EndIf

						If V60->(MsSeek(xFilial("V60") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC ) ))
								
							While !V60->(Eof()) .And. V60->(V60_FILIAL + V60_ID + V60_VERSAO + V60_SEQIRC ) == xFilial("T8H") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC)

								cXmlAux +=		"<infoIRCR>"
								cXmlAux +=			xTafTag("tpCR"		,V60->V60_TPCR  ,,.F. )

								If V61->(MsSeek(xFilial("V61") + V60->(V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC) ) )

									While !V61->(Eof()) .And. V61->( V61_FILIAL + V61_ID + V61_VERSAO + V61_TPCR + V61_SEQIRC ) == xFilial("V60") + V60->( V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC )
											
										cXmlAux +=		"<dedDepen>"
										cXmlAux +=			xTafTag("tpRend"		,V61->V61_TPREND,,.F. )
										cXmlAux +=			xTafTag("cpfDep"		,V61->V61_CPFDEP,,.F. )
										cXmlAux +=			xTafTag("vlrDedDep"		,V61->V61_VLRDED,PesqPict("V61","V61_VLRDED"),.F. )
										cXmlAux +=		"</dedDepen>"

										V61->(DbSkip())

									EndDo

								EndIf	

								If V62->(MsSeek(xFilial("V62") + V60->(V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC) ) )

									While !V62->(Eof()) .And.  V62->(V62_FILIAL + V62_ID + V62_VERSAO + V62_TPCR + V62_SEQIRC) == xFilial("V60") + V60->(V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC)
											
										cXmlAux +=		"<penAlim>"
										cXmlAux +=			xTafTag("tpRend"			,V62->V62_TPREND,,.F. )
										cXmlAux +=			xTafTag("cpfDep"			,V62->V62_CPFDEP,,.F. )
										cXmlAux +=			xTafTag("vlrDedPenAlim"		,V62->V62_VLPEN ,PesqPict("V62","V62_VLPEN"),.F. )
										cXmlAux +=		"</penAlim>"

										V62->(DbSkip())

									EndDo

								EndIf	

								If V63->(MsSeek(xFilial("V63") + V60->(V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC ) ) )

									While !V63->(Eof()) .And. V63->(V63_FILIAL + V63_ID + V63_VERSAO + V63_TPCR + V63_SEQIRC ) == xFilial("V60") + V60->(V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC)
											
										cXmlAux +=		"<previdCompl>"
										cXmlAux +=			xTafTag("tpPrev"			,V63->V63_TPREV ,,.F. )
										cXmlAux +=			xTafTag("cnpjEntidPC"		,V63->V63_INSCPL,,.F. )
										cXmlAux +=			xTafTag("vlrDedPC"			,V63->V63_VLCOMP,PesqPict("V63","V63_VLCOMP"),.F. )
										cXmlAux +=			xTafTag("vlrPatrocFunp"		,V63->V63_VLPATR,PesqPict("V63","V63_VLPATR"),.T. )

										If TafColumnPos("V63_VLCO13")
											cXmlAux +=			xTafTag("vlrDedPC13"		,V63->V63_VLCO13,PesqPict("V63","V63_VLPATR"),.T. )
											cXmlAux +=			xTafTag("vlrPatrocFunp13"	,V63->V63_VLPA13,PesqPict("V63","V63_VLPATR"),.T. )
										EndIf

										cXmlAux +=		"</previdCompl>"

										V63->(DbSkip())

									EndDo
										
								EndIf

								If V64->(MsSeek(xFilial("V64") + V60->(V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC ) ) )

									While !V64->(Eof()) .And. V64->(V64_FILIAL + V64_ID + V64_VERSAO + V64_TPCR + V64_SEQIRC ) == xFilial("V60") + V60->(V60_ID + V60_VERSAO + V60_TPCR + V60_SEQIRC )
											
										cXmlAux +=		"<infoProcRet>"
										cXmlAux +=			xTafTag("tpProcRet"			,V64->V64_TPPROC ,,.F. )
										cXmlAux +=			xTafTag("nrProcRet"			,V64->V64_NRPROC,,.F. )
										cXmlAux +=			xTafTag("codSusp"			,V64->V64_CODSUP,,.T. )

										If V65->(MsSeek(xFilial("V65") + V64->(V64_ID + V64_VERSAO + V64_TPCR + V64_TPPROC + V64_NRPROC + V64_CODSUP + V64_SEQIRC ) ) )

											While !V65->(Eof()) .And. V65->(V65_FILIAL + V65_ID + V65_VERSAO + V65_TPCR + V65_TPPROC + V65_NRPROC + V65_CODSUP + V65_SEQIRC ) == xFilial("V64") +V64->(V64_ID + V64_VERSAO + V64_TPCR + V64_TPPROC + V64_NRPROC + V64_CODSUP + V64_SEQIRC )
													
												cXmlAux +=		"<infoValores>"
												cXmlAux +=			xTafTag("indApuracao"		,V65->V65_INDAPU,,.F. )
												cXmlAux +=			xTafTag("vlrNRetido"		,V65->V65_VLRRET,PesqPict("V65","V65_VLRRET"),.T. )
												cXmlAux +=			xTafTag("vlrDepJud"			,V65->V65_VLRJUD,PesqPict("V65","V65_VLRJUD"),.T. )
												cXmlAux +=			xTafTag("vlrCmpAnoCal"		,V65->V65_VLACAL,PesqPict("V65","V65_VLACAL"),.T. )
												cXmlAux +=			xTafTag("vlrCmpAnoAnt"		,V65->V65_VLAANT,PesqPict("V65","V65_VLAANT"),.T. )
												cXmlAux +=			xTafTag("vlrRendSusp"		,V65->V65_VLSUSP,PesqPict("V65","V65_VLSUSP"),.T. )
													
												If V66->(MsSeek(xFilial("V66") + V65->(V65_ID + V65_VERSAO + V65_TPCR + V65_TPPROC + V65_NRPROC + V65_CODSUP + V65_INDAPU + V65_SEQIRC ) ) )

													While !V66->(Eof()) .And. V66->(V66_FILIAL + V66_ID + V66_VERSAO + V66_TPCR + V66_TPPROC + V66_NRPROC + V66_CODSUP + V66_INDAPU + V66_SEQIRC ) == xFilial("V65") + V65->(V65_ID + V65_VERSAO + V65_TPCR + V65_TPPROC + V65_NRPROC + V65_CODSUP + V65_INDAPU + V65_SEQIRC )
														
														cXmlAux +=		"<dedSusp>"
														cXmlAux +=			xTafTag("indTpDeducao"		,V66->V66_TPDEDU,,.F. )
														cXmlAux +=			xTafTag("vlrDedSusp"		,V66->V66_VLSUSP,PesqPict("V66","V66_VLSUSP"),.T. )
														cXmlAux +=			xTafTag("cnpjEntidPC"		,V66->V66_INSCPL,,.T. )
														cXmlAux +=			xTafTag("vlrPatrocFunp"		,V66->V66_VLFUNP,PesqPict("V66","V66_VLFUNP"),.T. )

														If V67->(MsSeek(xFilial("V67") + V66->(V66_ID + V66_VERSAO + V66_TPCR + V66_TPPROC + V66_NRPROC + V66_CODSUP + V66_INDAPU + V66_SEQUEN + V66_SEQIRC ) ) )
																
															While !V67->(Eof()) .And. V67->(V67_FILIAL + V67_ID + V67_VERSAO + V67_TPCR + V67_TPPROC + V67_NRPROC + V67_CODSUP + V67_INDAPU + V67_SEQV66 + V67_SEQIRC) == xFilial("V66") + V66->(V66_ID + V66_VERSAO + V66_TPCR + V66_TPPROC + V66_NRPROC + V66_CODSUP + V66_INDAPU + V66_SEQUEN + V66_SEQIRC )
																
																cXmlAux +=		"<benefPen>"
																cXmlAux +=			xTafTag("cpfDep"			,V67->V67_CPFDEP,,.F. )
																cXmlAux +=			xTafTag("vlrDepenSusp"		,V67->V67_VLSUSP,PesqPict("V67","V67_VLSUSP"),.F. )
																cXmlAux +=		"</benefPen>"

																V67->(DbSkip())
															EndDo

														EndIf

														cXmlAux +=		"</dedSusp>"
														V66->(DbSkip())

													EndDo

												EndIf

												cXmlAux +=		"</infoValores>"

												V65->(DbSkip())

											EndDo

										EndIf

										cXmlAux +=		"</infoProcRet>"
										V64->(DbSkip())

									EndDo
										
								EndIf

								cXmlAux +=		"</infoIRCR>"

								V60->(DbSkip())

							EndDo	

						EndIf

						If V68->(MsSeek(xFilial("V68") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC ) ))

							While !V68->(Eof()) .And. V68->(V68_FILIAL + V68_ID + V68_VERSAO + V68_SEQIRC ) == xFilial("T8H") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC)

								cXmlAux +=		"<planSaude>"
								cXmlAux +=			xTafTag("cnpjOper"			,V68->V68_CNPJOP,,.F. )
								cXmlAux +=			xTafTag("regANS"			,V68->V68_REGANS,,.T. )
								cXmlAux +=			xTafTag("vlrSaudeTit"		,V68->V68_VLRTIT,PesqPict("V68","V68_VLRTIT"),.F. )

								If V69->(MsSeek(xFilial("V69")  +V68->(V68_ID + V68_VERSAO + V68_CNPJOP + V68_SEQIRC ) ) )
										
									While !V69->(Eof()) .And. V69->(V69_FILIAL + V69_ID + V69_VERSAO + V69_CNPJOP + V69_SEQIRC) == xFilial("V68") + V68->(V68_ID + V68_VERSAO + V68_CNPJOP + V68_SEQIRC)

										cXmlAux +=		"<infoDepSau>"
										cXmlAux +=			xTafTag("cpfDep"			,V69->V69_CPFDEP,,.F. )
										cXmlAux +=			xTafTag("vlrSaudeDep"		,V69->V69_VLRDEP,PesqPict("V69","V69_VLRDEP"),.F. )
										cXmlAux +=		"</infoDepSau>"

										V69->(DbSkip())

									EndDo

								EndIf 

								cXmlAux +=		"</planSaude>"

								V68->(DbSkip())

							EndDo

						EndIf 

						If V6A->(MsSeek(xFilial("V6A") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC ) ))

							While !V6A->(Eof()) .And. V6A->(V6A_FILIAL + V6A_ID + V6A_VERSAO + V6A_SEQIRC ) == xFilial("T8H") + T8H->(T8H_ID + T8H_VERSAO + T8H_SEQIRC)

								cXmlAux +=		"<infoReembMed>"
								cXmlAux +=			xTafTag("indOrgReemb"		,V6A->V6A_INDREM,,.F. )
								cXmlAux +=			xTafTag("cnpjOper"			,V6A->V6A_CNPJOP,,.T. )
								cXmlAux +=			xTafTag("regANS"			,V6A->V6A_REGANS,,.T. )

								If V54->(MsSeek(xFilial("V54") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN + V6A_SEQIRC ) ) )

									While !V54->(Eof()) .And. V54->(V54_FILIAL + V54_ID + V54_VERSAO + V54_SEQUEN + V54_SEQIRC ) == xFilial("V6A") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN + V6A_SEQIRC )

										cXmlAux +=		"<detReembTit>"
										cXmlAux +=			xTafTag("tpInsc"			,V54->V54_TPINSC,,.F. )
										cXmlAux +=			xTafTag("nrInsc"			,V54->V54_NRINSC,,.F. )
										cXmlAux +=			xTafTag("vlrReemb"			,V54->V54_VLREMB,PesqPict("V54","V54_VLREMB"),.T. )
										cXmlAux +=			xTafTag("vlrReembAnt"		,V54->V54_VLRANT,PesqPict("V54","V54_VLRANT"),.T. )
										cXmlAux +=		"</detReembTit>"

										V54->(DbSkip())

									EndDo

								EndIf

								If V50->(MsSeek(xFilial("V50") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN + V6A_SEQIRC ) ) )

									While !V50->(Eof()) .And. V50->(V50_FILIAL + V50_ID + V50_VERSAO + V50_SEQUEN + V50_SEQIRC ) == xFilial("V6A") + V6A->(V6A_ID + V6A_VERSAO + V6A_SEQUEN + V6A_SEQIRC )

										cXmlAux +=		"<infoReembDep>"
										cXmlAux +=			xTafTag("cpfBenef"			,V50->V50_CPFDEP,,.F. )

										If V51->(MsSeek(xFilial("V51") + V50->(V50_ID + V50_VERSAO + V50_SEQUEN + V50_CPFDEP + V50_SEQIRC ) ) )
											
											While !V51->(Eof()) .And. V51->(V51_FILIAL + V51_ID + V51_VERSAO + V51_SEQUEN + V51_CPFDEP + V51_SEQIRC) == xFilial("V50") + V50->(V50_ID + V50_VERSAO + V50_SEQUEN + V50_CPFDEP + V50_SEQIRC )

												cXmlAux +=		"<detReembDep>"	
												cXmlAux +=			xTafTag("tpInsc"			,V51->V51_TPINSC,,.F. )
												cXmlAux +=			xTafTag("nrInsc"			,V51->V51_NRINSC,,.F. )
												cXmlAux +=			xTafTag("vlrReemb"			,V51->V51_VLREMB,PesqPict("V51","V51_VLREMB"),.T. )
												cXmlAux +=			xTafTag("vlrReembAnt"		,V51->V51_VLRANT,PesqPict("V51","V51_VLRANT"),.T. )
												cXmlAux +=		"</detReembDep>"

												V51->(DbSkip())
											EndDo

										EndIf

										cXmlAux +=		"</infoReembDep>"

										V50->(DbSkip())

									EndDo

								EndIf
									
								cXmlAux +=		"</infoReembMed>"

								V6A->(DbSkip())

							EndDo

						EndIf

						cXmlAux +=	"</infoIRComplem>"

						T8H->(DbSkip())
					EndDo
					
					T8H->(DbCloseArea())

				EndIf

			EndIf

			If !cXmlAux == "<infoIRComplem></infoIRComplem>"
                 cXml += cXmlAux
            EndIf
			
			V6J->(DbCloseArea())
			T2I->(DbCloseArea())
			V8J->(DbCloseArea())
			V8T->(DbCloseArea())
			V52->(DbCloseArea())
			V53->(DbCloseArea())
			V8H->(DbCloseArea())
			V8V->(DbCloseArea())
			V60->(DbCloseArea())
			V61->(DbCloseArea())
			V62->(DbCloseArea())
			V63->(DbCloseArea())
			V64->(DbCloseArea())
			V65->(DbCloseArea())
			V66->(DbCloseArea())
			V67->(DbCloseArea())
			V68->(DbCloseArea())
			V69->(DbCloseArea())
			V6A->(DbCloseArea())
			V54->(DbCloseArea())
			V50->(DbCloseArea())
			V51->(DbCloseArea())

		EndIf

		cXml +=	"</ideTrabalhador>"

		// Tratamento para simplificação do e-Social

			DBSelectArea("T2H")
			T2H->(DbSetOrder(1))

			DBSelectArea("T2I")
			T2I->( DbSetOrder( 1 ) )

			DBSelectArea("T2J")
			T2J->( DbSetOrder( 1 ) )

			xTafTagGroup("infoDep"	,{	{ "vrDedDep", T2G->T2G_VRDEDD,,.F.} };
										,	@cXml)
		
			If T2H->( MsSeek( xFilial("T2H")+T2G->(T2G_ID+T2G_VERSAO) ) )

				While !T2H->(Eof()) .And. AllTrim(T2H->(T2H_ID+T2H_VERSAO)) == AllTrim(T2G->(T2G_ID+T2G_VERSAO))

					cXml +=	"<infoIrrf>"
					cXml += 		xTafTag("codCateg",POSICIONE("C87",1, xFilial("C87")+T2H->T2H_CODCAT,"C87_CODIGO"),, .T.)
					cXml +=		xTafTag("indResBr",T2H->T2H_INDRES)

					If T2I->( MsSeek( xFilial("T2I")+T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES) ) )

						While !T2I->(Eof()) .And. AllTrim(T2I->(T2I_ID+T2I_VERSAO+T2I_SEQUEN+T2I_CODCAT+T2I_INDRES)) == AllTrim(T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES))

							cXml +=	"<basesIrrf>"
							cXml +=		xTafTag("tpValor",POSICIONE("C8U",1, xFilial("C8U")+T2I->T2I_CTPVAL,"C8U_CODIGO"))
							cXml +=		xTafTag("valor",T2I->T2I_VLIRRF,PesqPict("T2I","T2I_VLIRRF"))
							cXml +=	"</basesIrrf>"

							T2I->(DbSkip())

						EndDo

					EndIf

					If T2J->( MsSeek( xFilial("T2J")+T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES) ) )

						While !T2J->(Eof()) .And. AllTrim(T2J->(T2J_ID+T2J_VERSAO+T2J_SEQUEN+T2J_CODCAT+T2J_INDRES)) == AllTrim(T2H->(T2H_ID+T2H_VERSAO+T2H_SEQUEN+T2H_CODCAT+T2H_INDRES))

							cXml += "<irrf>"

							If TAFColumnPos("T2J_CODREC")
								cXml += xTafTag("tpCR", T2J->T2J_CODREC)
							Else
								cXml += xTafTag("tpCR",POSICIONE("C6R",3, xFilial("C6R")+T2J->T2J_CTPCR ,"C6R_CODIGO"))
							EndIf

							cXml += xTafTag("vrIrrfDesc",T2J->T2J_VLDESC, PesqPict("T2J","T2J_VLDESC"))
							cXml += "</irrf>"

							T2J->(DbSkip())

						EndDo

					EndIf

					xTafTagGroup("endExt"	,{	{ "dscLograd", T2H->T2H_DLOUGR,,.F.};
												, 	{ "nrLograd",	 T2H->T2H_NUMLOG,,.T.};
												, 	{ "complem",	 T2H->T2H_COMPLE,,.T.};
												, 	{ "bairro", 	 T2H->T2H_BAIRRO,,.T.};
												, 	{ "nmCid", 	 T2H->T2H_CIDADE,,.F.};
												, 	{ "codPostal", T2H->T2H_CEP   ,,.T.}};
												,	@cXmlendExt )

					xTafTagGroup("idePais"	,{	{ "codPais", 	 Posicione("C08",3,xFilial("C08")+T2H->T2H_IDPAIS,"C08_PAISSX"),,.F.};
												,	{ "indNIF", 	 T2H->T2H_INDNIF,,.F.};
												,	{ "nifBenef",	 T2H->T2H_NIFBEN,,.T.}};
													,	@cXmlidePais )

					cXmlidePgE := cXmlidePais + cXmlendExt

						If !Empty(cXmlidePais)

							cXml += "<idePgtoExt>"
							cXml += cXmlidePgE
							cXml += "</idePgtoExt>"

						EndIf

						cXmlidePgE		:= ""
						cXmlendExt		:= ""
						cXmlidePais	:= ""

					cXml +=	"</infoIrrf>"

					T2H->(DbSkip())

				EndDo

			EndIf

			T2J->(DbCloseArea())
			T2I->(DbCloseArea())
			T2H->(DbCloseArea())

		EndIf
		
		cXml := xTafCabXml(cXml,"T2G",cLayout,cReg,aMensal,,,lLaySimplif)

		If !lJob
			xTafGerXml(cXml,cLayout)
		EndIf

	If !( Empty( cFilBkp ) )
		cFilAnt := cFilBkp
	EndIf

Return(cXml) 

//--------------------------------------------------------------------
/*/{Protheus.doc} SetCssButton

Cria objeto TButton utilizando CSS

@author Eduardo Sukeda
@since 09/04/2019
@version 1.0

@param cTamFonte - Tamanho da Fonte
@param cFontColor - Cor da Fonte
@param cBackColor - Cor de Fundo do Botão
@param cBorderColor - Cor da Borda

@return cCss
/*/
//--------------------------------------------------------------------
Static Function SetCssButton(cTamFonte,cFontColor,cBackColor,cBorderColor)

	Local cCSS := ""

	cCSS := "QPushButton{ background-color: " + cBackColor + "; "
	cCSS += "border: none; "
	cCSS += "font: bold; "
	cCSS += "color: " + cFontColor + ";" 
	cCSS += "padding: 2px 5px;" 
	cCSS += "text-align: center; "
	cCSS += "text-decoration: none; "
	cCSS += "display: inline-block; "
	cCSS += "font-size: " + cTamFonte + "px; "
	cCSS += "border: 1px solid " + cBorderColor + "; "
	cCSS += "border-radius: 3px "
	cCSS += "}"

Return cCSS

//---------------------------------------------------------------------
/*/{Protheus.doc} PreXmlLote
Função que chama a TAFXmlLote e limpa slRubERPPad

@author brunno.costa
@since 01/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function PreXmlLote()

    TAFXmlLote( 'T2G', 'S-5002' , 'evtIrrfBenef' , 'TAF422Xml', ,oBrw )
    slRubERPPad := Nil  //Limpa variável no final do processo em lote

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF422Rpt
@type			static function
@description	Inicializa a variável static __lGrvRPT
@author			Fabio Mendonça
@since			25/07/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function TAF422Rpt()

	__lGrvRPT := TAFAlsInDic("V3N")

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetEvtByTpPgto
@type			static function
@description	Obtém o Evento que originou o Tipo de Pagamento dmDev/tpPgto do S-5002
@author			Fabio Mendonça
@since			25/07/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function GetEvtByTpPgto(nTpPgto as Numeric) as Character

	Local aEvtsOrig1210 as Array

	aEvtsOrig1210 := {"S-1200", "S-2299", "S-2399", "S-1202", "S-1207"}

Return aEvtsOrig1210[nTpPgto]

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFieldUsed
Inclui um campo não usado no Modelo e na View possibiliando o uso
do mesmo.

@Param:
oStru  - Modelo do Campo
cField - Campo a ser incluido
nStru  - Indica se o Struct corresponde a view ou modelo (1 - Modelo, 2 View)
cType  - Tipo do campo (Valores válidos: GET, COMBO) (Uso na View)

@Return:
Nil 

@author Evandro dos Santos Oliveira
@since 10/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetFieldUsed(oStru,cField,nStru,cType)

	Default cField := ""
	Default cType  := "GET"
	Default oStru  := Nil 
	Default nStru  := 1

	If nStru == 1 
	
		aAdd(oStru:aTable[2],cField)
		aAdd(oStru:aFields	,{	 GetSX3Cache(cField, "X3_TITULO");
								,GetSX3Cache(cField, "X3_DESCRIC");
								,GetSX3Cache(cField, "X3_CAMPO");
								,GetSX3Cache(cField, "X3_TIPO");
								,GetSX3Cache(cField, "X3_TAMANHO");
								,GetSX3Cache(cField, "X3_DECIMAL"); 
								,{||.T.}/*validacao*/;
								,Nil;
								,AllTrim(GetSX3Cache(cField, "X3_CBOX"));
								,.F.;
								,Nil;
								,.F.;
								,.F.;
								,.F.;
								,AllTrim(GetSX3Cache(cField, "X3_VALID"))})
	ElseIf nStru == 2

		aAdd(oStru:aFields	,{cField;
								,GetSX3Cache(cField, "X3_ORDEM");
								,GetSX3Cache(cField, "X3_TITULO");
								,GetSX3Cache(cField, "X3_DESCRIC");
								,Nil;
								,cType;
								,GetSX3Cache(cField, "X3_PICTURE");
								,Nil;
								,"";
								,.T.;
								,"";
								,"";
								,{};
								,0;
								,"";
								,.F.;
								,"";
								,.F.;
								,0;
								,.F.;
								,"";
								,.F.})
	EndIf 
		  
Return Nil
