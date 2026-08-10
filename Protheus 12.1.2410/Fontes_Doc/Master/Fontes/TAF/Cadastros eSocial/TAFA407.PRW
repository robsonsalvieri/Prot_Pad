#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA407.CH"
#INCLUDE "TOPCONN.CH"


#DEFINE CRLF CHR(13) + CHR(10)

Static __aRubrica  := {}
Static __cPicVlDe  := Nil
Static __cPicVlLi  := Nil
Static __cPicQtdR  := Nil
Static __cPicFatR  := Nil
Static __cPicVlUn  := Nil
Static __cPicVlRu  := Nil
Static __cPicVlPe  := Nil
Static __cPicVlRb  := Nil
Static __lRubPad   := Nil
Static __cPicVlrs  := Nil
Static lLaySimplif := TafLayESoc()
Static lSimplBeta  := TafLayESoc("S_01_01_00",, .T.)
Static lSimpl12    := TafLayESoc("S_01_02_00",, .T.)
Static lSimpl0103  := TafLayESoc("S_01_03_00",, .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA407
Cadastro MVC de Pagamentos de Rendimentos do Trabalho - S-1210

@author Vitor Siqueira
@since 11/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA407()
	
    Private cEvtPosic as Character
	Private cNomEve   as Character
	Private oBrw      as Object

    cEvtPosic := ""
	cNomEve   := "S1210"
	oBrw      := FWmBrowse():New()

	DbSelectArea('T3P')

	If TafAtualizado()
		TafNewBrowse( "S-1210", , , , STR0001, , 2, 2 )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as Array
	Local aRotina as Array
	Local nPosVis as Numeric

    aFuncao := {}
	aRotina := {}
	nPosVis := 0

	If GetSx3Cache("T3P_CPFV","X3_CONTEXT") == "V" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES");
     .And. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF407View('T3P',RECNO())"  OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF407Inc('T3P',RECNO())"   OPERATION 3 ACCESS 0 //'Incluir' 
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('T3P', 0 , 0)"      OPERATION 4 ACCESS 0 //'Alterar'
        ADD OPTION aRotina TITLE ""           ACTION "Exc407()"                   OPERATION 5 ACCESS 0 //'Excluir'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA407"			  OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		Aadd( aFuncao, { "" , "TAF407Xml"                       , "1" } )
		Aadd( aFuncao, { "" , "xFunAltRec( 'T3P' )"             , "10"} )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'T3P', 'TAFA407' )"  , "3" } ) //Chamo a Browse do Histórico
		Aadd( aFuncao, { "" , "StaticCall(TAFA407,PreXmlLote)"  , "5" } )

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title STR0002 Action "VIEWDEF.TAFA407" OPERATION 2 ACCESS 0 //"Visualizar"
            aRotina	:= xMnuExtmp( "TAFA407", "T3P", .F. ) // Menu dos extemporâneos
		Else
			aRotina	:=	xFunMnuTAF( "TAFA407" , , aFuncao)
			nPosVis := aScan( aRotina, { |x| x[4] == 2 })
			aRotina[nPosVis][2] := "Taf407View"
		EndIf

	EndIf

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função que chama a TAFXmlLote e limpa slRubERPPad

@author Marcelo Neumann
@since 01/10/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function PreXmlLote()

	TAFXmlLote('T3P', 'S-1210', 'evtPgtos', 'TAF407Xml')
	slRubERPPad := Nil	//Limpa variável no final do processo em lote

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local aTrigger      as Array
	LocaL nILE3         as Numeric
    Local lLayout12     as Logical
	Local oStruV6M      as Object
    Local oStruV9I      as Object
    Local oStruV9J      as Object
	Local oStruT3P      as Object
	Local oStruT3Q      as Object
	Local oStruT3R      as Object
	Local oStruLE2      as Object
	Local oStruLE3      as Object
	Local oStruLE4      as Object
	Local oStruT5V      as Object
	Local oStruT5U      as Object
	Local oStruT5Y      as Object
	Local oStruT5Z      as Object
	Local oStruT5X      as Object
	Local oStruT6P      as Object
	Local oStruT6Q      as Object
	Local oStruT6R      as Object
    Local oStruV7S      as Object
    Local oStruV7T      as Object
    Local oStruV7U      as Object
    Local oStruV7V      as Object
    Local oStruV7X      as Object
    Local oStruV7W      as Object
    Local oStruV7Y      as Object
    Local oStruV7Z      as Object
    Local oStruV8A      as Object
    Local oStruV8B      as Object
    Local oStruV8C      as Object
    Local oStruV8D      as Object
    Local oStruV8E      as Object
    Local oStruV8F      as Object
    Local oStruV8G      as Object
    Local oStruT8E      as Object
	LocaL oModel        as Object

	aTrigger    := TAF407Trigger()
	nILE3       := 0
    lLayout12   := lSimpl12 
	oStruV6M    := Nil
    oStruV9I    := Nil
    oStruV9J    := Nil
	oStruT3P    := FWFormStruct(1, "T3P")
	oStruT3Q    := FWFormStruct(1, "T3Q")
	oStruT3R    := FWFormStruct(1, "T3R")
	oStruLE2    := FWFormStruct(1, "LE2")
	oStruLE3    := FWFormStruct(1, "LE3")
	oStruLE4    := FWFormStruct(1, "LE4")
	oStruT5V    := FWFormStruct(1, "T5V")
	oStruT5U    := FWFormStruct(1, "T5U")
	oStruT5Y    := FWFormStruct(1, "T5Y")
	oStruT5Z    := FWFormStruct(1, "T5Z")
	oStruT5X    := FWFormStruct(1, "T5X")
	oStruT6P    := FWFormStruct(1, "T6P")
	oStruT6Q    := FWFormStruct(1, "T6Q")
	oStruT6R    := FWFormStruct(1, "T6R")
    oStruV7S    := FWFormStruct(1, "V7S")
    oStruV7T    := FWFormStruct(1, "V7T")
    oStruV7U    := FWFormStruct(1, "V7U")
    oStruV7V    := FWFormStruct(1, "V7V")
    oStruV7X    := FWFormStruct(1, "V7X")
    oStruV7W    := FWFormStruct(1, "V7W")
    oStruV7Y    := FWFormStruct(1, "V7Y")
    oStruV7Z    := FWFormStruct(1, "V7Z")
    oStruV8A    := FWFormStruct(1, "V8A")
    oStruV8B    := FWFormStruct(1, "V8B")
    oStruV8C    := FWFormStruct(1, "V8C")
    oStruV8D    := FWFormStruct(1, "V8D")
    oStruV8E    := FWFormStruct(1, "V8E")
    oStruV8F    := FWFormStruct(1, "V8F")
    oStruV8G    := FWFormStruct(1, "V8G")
    oStruT8E    := FWFormStruct(1, "T8E")
	oModel      := MPFormModel():New("TAFA407",,, {|oModel| SaveModel(oModel)})

	oStruT3P:AddTrigger( aTrigger[1],;
                         aTrigger[2],;
                         aTrigger[3],;
                         aTrigger[4] )

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	//*********************************************************
	//Aba - Identificação do beneficiário de pagamento
	//*********************************************************
	oModel:AddFields("MODEL_T3P",/*cOwner*/,oStruT3P)
	oModel:GetModel("MODEL_T3P"):SetPrimaryKey({"T3P_FILIAL","T3P_ID","T3P_VERSAO"})

	If !lLaySimplif // Tratamento Simplificação do e-Social.

		oModel:AddGrid("MODEL_T3Q", "MODEL_T3P", oStruT3Q)
		oModel:GetModel("MODEL_T3Q"):SetOptional( .T. )
		oModel:GetModel("MODEL_T3Q"):SetUniqueLine( { "T3Q_DTPGTO","T3Q_TPPGTO"} )
		oModel:GetModel('MODEL_T3Q'):SetMaxLine(60)

		//*********************************************************
		//Aba - Detalhamento de Eventos 1200, 1202, 2299 e 2399
		//*********************************************************
		oModel:AddGrid( "MODEL_T3R", "MODEL_T3Q", oStruT3R)
		oModel:GetModel("MODEL_T3R"):SetOptional( .T. )
		oModel:GetModel("MODEL_T3R"):SetUniqueLine({ "T3R_PERREF","T3R_IDEDMD", "T3R_INDPGT"  })
		oModel:GetModel('MODEL_T3R'):SetMaxLine(200)

		//*********************************************************
		//Aba - Retenções de Pagamento Total
		//*********************************************************
		oModel:AddGrid( "MODEL_LE2", "MODEL_T3R", oStruLE2)
		oModel:GetModel("MODEL_LE2"):SetOptional( .T. )
		oModel:GetModel("MODEL_LE2"):SetUniqueLine( { "LE2_IDRUBR", "LE2_SEQUEN", "LE2_RUBRIC"} )
		oModel:GetModel('MODEL_LE2'):SetMaxLine(99)

		oModel:AddGrid(	"MODEL_LE3", "MODEL_LE2", oStruLE3)
		oModel:GetModel("MODEL_LE3"):SetOptional( .T. )
		oModel:GetModel("MODEL_LE3"):SetUniqueLine( {"LE3_CPFBEN"} )
		oModel:GetModel('MODEL_LE3'):SetMaxLine(99)

		//*********************************************************
		//Aba - Informação de Pagamento Parcial
		//*********************************************************
		oModel:AddGrid( "MODEL_LE4", "MODEL_T3R", oStruLE4)
		oModel:GetModel("MODEL_LE4"):SetOptional( .T. )
		oModel:GetModel("MODEL_LE4"):SetUniqueLine( { "LE4_IDRUBR","LE4_RUBRIC","LE4_IDTABR"} )
		oModel:GetModel('MODEL_LE4'):SetMaxLine(99)

		//*********************************************************
		//Aba - Benefiários Previdenciários
		//*********************************************************
		oModel:AddGrid( "MODEL_T6P", "MODEL_T3Q", oStruT6P)
		oModel:GetModel("MODEL_T6P"):SetOptional( .T. )
		oModel:GetModel("MODEL_T6P"):SetUniqueLine({ "T6P_PERREF","T6P_IDEDMD","T6P_INDPGT"})
		oModel:GetModel('MODEL_T6P'):SetMaxLine(200)

		//*********************************************************
		//Aba - Retenções de Pagamento Total
		//*********************************************************
		oModel:AddGrid(	"MODEL_T6Q", "MODEL_T6P", oStruT6Q)
		oModel:GetModel("MODEL_T6Q"):SetOptional( .T. )
		oModel:GetModel("MODEL_T6Q"):SetUniqueLine( { "T6Q_IDRUBR","T6Q_RUBRIC","T6Q_IDTABR" } )
		oModel:GetModel('MODEL_T6Q'):SetMaxLine(99)

		//*********************************************************
		//Aba - Informação de Pagamento Parcial
		//*********************************************************
		oModel:AddGrid(	"MODEL_T6R", "MODEL_T6P", oStruT6R)
		oModel:GetModel("MODEL_T6R"):SetOptional( .T. )
		oModel:GetModel("MODEL_T6R"):SetUniqueLine( { "T6R_IDRUBR","T6R_RUBRIC","T6R_IDTABR"} )
		oModel:GetModel('MODEL_T6R'):SetMaxLine(99)

		//*********************************************************
		//Aba - Pagamentos Efetuados Relativos a Férias
		//*********************************************************
		oModel:AddGrid( "MODEL_T5U", "MODEL_T3Q", oStruT5U)
		oModel:GetModel("MODEL_T5U"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5U"):SetUniqueLine({"T5U_IDCATE", "T5U_DTINIG", "T5U_QTDIAS","T5U_MATRIC"})
		oModel:GetModel('MODEL_T5U'):SetMaxLine(5)

		oModel:AddGrid(	"MODEL_T5Y", "MODEL_T5U", oStruT5Y)
		oModel:GetModel("MODEL_T5Y"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5Y"):SetUniqueLine( {"T5Y_IDRUBR","T5Y_RUBRIC"} )
		oModel:GetModel('MODEL_T5Y'):SetMaxLine(99)

		oModel:AddGrid( "MODEL_T5Z", "MODEL_T5Y", oStruT5Z)
		oModel:GetModel("MODEL_T5Z"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5Z"):SetUniqueLine( { "T5Z_CPFBEN"} )
		oModel:GetModel('MODEL_T5Z'):SetMaxLine(99)

		//*********************************************************
		//Aba - Pagamentos Relativos a Competências Anteriores
		//*********************************************************
		oModel:AddGrid(	"MODEL_T5V", "MODEL_T3Q", oStruT5V)
		oModel:GetModel("MODEL_T5V"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5V"):SetUniqueLine({"T5V_IDCATE"})
		oModel:GetModel('MODEL_T5V'):SetMaxLine(99)

		oModel:AddGrid(	"MODEL_T5X", "MODEL_T5V", oStruT5X)
		oModel:GetModel("MODEL_T5X"):SetOptional( .T. )
		oModel:GetModel("MODEL_T5X"):SetUniqueLine( {"T5X_IDTPIR","T5X_VLRBCI"} )
		oModel:GetModel('MODEL_T5X'):SetMaxLine(99)

		oModel:SetRelation("MODEL_T3Q" ,{ {"T3Q_FILIAL","xFilial('T3Q')"}, {"T3Q_ID","T3P_ID"}, {"T3Q_VERSAO","T3P_VERSAO"} },T3Q->(IndexKey(1)) )

		oModel:SetRelation("MODEL_T3R",{ {"T3R_FILIAL","xFilial('T3R')"}, {"T3R_ID","T3P_ID"}, {"T3R_VERSAO","T3P_VERSAO"}, {"T3R_DTPGTO","T3Q_DTPGTO"}, {"T3R_TPPGTO","T3Q_TPPGTO"}},T3R->(IndexKey(1)) )
		oModel:SetRelation("MODEL_LE2",{ {"LE2_FILIAL","xFilial('LE2')"}, {"LE2_ID","T3P_ID"}, {"LE2_VERSAO","T3P_VERSAO"}, {"LE2_DTPGTO","T3Q_DTPGTO"}, {"LE2_TPPGTO","T3Q_TPPGTO"}, {"LE2_PERREF","T3R_PERREF"}, {"LE2_IDEDMD","T3R_IDEDMD"},{"LE2_INDPGT","T3R_INDPGT"}},LE2->(IndexKey(1)) )

		IIF(FWSIXUtil():ExistIndex( "LE3", "LE3I3", .T.), nILE3 := 3, nILE3 := 1)
		oModel:SetRelation("MODEL_LE3",{ {"LE3_FILIAL","xFilial('LE3')"}, {"LE3_ID","T3P_ID"}, {"LE3_VERSAO","T3P_VERSAO"}, {"LE3_DTPGTO","T3Q_DTPGTO"}, {"LE3_TPPGTO","T3Q_TPPGTO"}, {"LE3_PERREF","T3R_PERREF"}, {"LE3_IDEDMD","T3R_IDEDMD"},{"LE3_INDPGT","T3R_INDPGT"}, {"LE3_IDRUBR","LE2_IDRUBR"}, {"LE3_SEQUEN","LE2_SEQUEN"}, {"LE3_RUBRIC","LE2_RUBRIC"}  },LE3->(IndexKey(nILE3)) )
		oModel:SetRelation("MODEL_LE4",{ {"LE4_FILIAL","xFilial('LE4')"}, {"LE4_ID","T3P_ID"}, {"LE4_VERSAO","T3P_VERSAO"}, {"LE4_DTPGTO","T3Q_DTPGTO"}, {"LE4_TPPGTO","T3Q_TPPGTO"}, {"LE4_PERREF","T3R_PERREF"}, {"LE4_IDEDMD","T3R_IDEDMD"},{"LE4_INDPGT","T3R_INDPGT"}},LE4->(IndexKey(1)) )

		oModel:SetRelation("MODEL_T6P",{ {"T6P_FILIAL","xFilial('T6P')"}, {"T6P_ID","T3P_ID"}, {"T6P_VERSAO","T3P_VERSAO"}, {"T6P_DTPGTO","T3Q_DTPGTO"}, {"T6P_TPPGTO","T3Q_TPPGTO"}},T6P->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T6Q",{ {"T6Q_FILIAL","xFilial('T6Q')"}, {"T6Q_ID","T3P_ID"}, {"T6Q_VERSAO","T3P_VERSAO"}, {"T6Q_DTPGTO","T3Q_DTPGTO"}, {"T6Q_TPPGTO","T3Q_TPPGTO"}, {"T6Q_PERREF","T6P_PERREF"}, {"T6Q_IDEDMD","T6P_IDEDMD"},{"T6Q_INDPGT","T6P_INDPGT"}},T6Q->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T6R",{ {"T6R_FILIAL","xFilial('T6R')"}, {"T6R_ID","T3P_ID"}, {"T6R_VERSAO","T3P_VERSAO"}, {"T6R_DTPGTO","T3Q_DTPGTO"}, {"T6R_TPPGTO","T3Q_TPPGTO"}, {"T6R_PERREF","T6P_PERREF"}, {"T6R_IDEDMD","T6P_IDEDMD"},{"T6R_INDPGT","T6P_INDPGT"}},T6R->(IndexKey(1)) )

		oModel:SetRelation("MODEL_T5U", { {"T5U_FILIAL","xFilial('T5U')"}, {"T5U_ID","T3P_ID"}, {"T5U_VERSAO","T3P_VERSAO"}, {"T5U_DTPGTO","T3Q_DTPGTO"}, {"T5U_TPPGTO","T3Q_TPPGTO"}},T5U->(IndexKey(1)) )

		If TAFColumnPos( "T5Y_MATRIC" )
			oModel:SetRelation("MODEL_T5Y", { {"T5Y_FILIAL","xFilial('T5Y')"}, {"T5Y_ID","T3P_ID"}, {"T5Y_VERSAO","T3P_VERSAO"}, {"T5Y_DTPGTO","T3Q_DTPGTO"}, {"T5Y_TPPGTO","T3Q_TPPGTO"}, {"T5Y_IDCATE","T5U_IDCATE"}, {"T5Y_DTINIG","T5U_DTINIG"},{"T5Y_QTDIAS","T5U_QTDIAS"},{"T5Y_MATRIC","T5U_MATRIC"}},T5Y->(IndexKey(2)) )
			oModel:SetRelation("MODEL_T5Z" ,{ {"T5Z_FILIAL","xFilial('T5Z')"}, {"T5Z_ID","T3P_ID"}, {"T5Z_VERSAO","T3P_VERSAO"}, {"T5Z_DTPGTO","T3Q_DTPGTO"}, {"T5Z_TPPGTO","T3Q_TPPGTO"}, {"T5Z_IDCATE","T5U_IDCATE"}, {"T5Z_DTINIG","T5U_DTINIG"},{"T5Z_QTDIAS","T5U_QTDIAS"},{"T5Z_MATRIC","T5U_MATRIC"},{"T5Z_IDRUBR","T5Y_IDRUBR"}, {"T5Z_RUBRIC","T5Y_RUBRIC"} },T5Z->(IndexKey(1)) )
		Else
			oModel:SetRelation("MODEL_T5Y", { {"T5Y_FILIAL","xFilial('T5Y')"}, {"T5Y_ID","T3P_ID"}, {"T5Y_VERSAO","T3P_VERSAO"}, {"T5Y_DTPGTO","T3Q_DTPGTO"}, {"T5Y_TPPGTO","T3Q_TPPGTO"}, {"T5Y_IDCATE","T5U_IDCATE"}, {"T5Y_DTINIG","T5U_DTINIG"},{"T5Y_QTDIAS","T5U_QTDIAS"}},T5Y->(IndexKey(1)) )
			oModel:SetRelation("MODEL_T5Z" ,{ {"T5Z_FILIAL","xFilial('T5Z')"}, {"T5Z_ID","T3P_ID"}, {"T5Z_VERSAO","T3P_VERSAO"}, {"T5Z_DTPGTO","T3Q_DTPGTO"}, {"T5Z_TPPGTO","T3Q_TPPGTO"}, {"T5Z_IDCATE","T5U_IDCATE"}, {"T5Z_DTINIG","T5U_DTINIG"},{"T5Z_IDRUBR","T5Y_IDRUBR"}},T5Z->(IndexKey(1)) )
		EndIf

		oModel:SetRelation("MODEL_T5V", { {"T5V_FILIAL","xFilial('T5V')"}, {"T5V_ID","T3P_ID"}, {"T5V_VERSAO","T3P_VERSAO"}, {"T5V_DTPGTO","T3Q_DTPGTO"}, {"T5V_TPPGTO","T3Q_TPPGTO"}},T5V->(IndexKey(1)) )
		oModel:SetRelation("MODEL_T5X", { {"T5X_FILIAL","xFilial('T5X')"}, {"T5X_ID","T3P_ID"}, {"T5X_VERSAO","T3P_VERSAO"}, {"T5X_DTPGTO","T3Q_DTPGTO"}, {"T5X_TPPGTO","T3Q_TPPGTO"}, {"T5X_IDCATE","T5V_IDCATE"}},T5X->(IndexKey(1)) )

		oStruLE2:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruLE4:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT5Y:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT6Q:SetProperty( '*', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT6R:SetProperty( 'T6R_IDRUBR', MODEL_FIELD_OBRIGAT , .F.  )
		oStruT5U:SetProperty( 'T5U_MATRIC', MODEL_FIELD_OBRIGAT , .F.  )

	Else

		oStruT3P:SetProperty("T3P_INDAPU", MODEL_FIELD_OBRIGAT, .F.)
		oStruT3P:SetProperty("T3P_INDAPU", MODEL_FIELD_INIT, {|| ""})

		oStruV6M := FWFormStruct(1, "V6M")

        If !lSimplBeta 
            oStruV6M:RemoveField("V6M_PAIEXT")
            oStruV6M:RemoveField("V6M_DPAIEX")
        EndIf       

		oModel:AddGrid("MODEL_V6M", "MODEL_T3P", oStruV6M)
		oModel:GetModel("MODEL_V6M"):SetOptional(.T.)
		oModel:GetModel("MODEL_V6M"):SetUniqueLine({"V6M_TPPGTO", "V6M_PERREF", "V6M_INDDEV"})
		oModel:GetModel("MODEL_V6M"):SetMaxLine(999)

        oModel:SetRelation("MODEL_V6M", {{"V6M_FILIAL", "xFilial('V6M')"}, {"V6M_ID", "T3P_ID"}, {"V6M_VERSAO", "T3P_VERSAO"}}, V6M->(IndexKey(1)))

        If lSimplBeta .and. TAFColumnPos("V6M_PAIEXT") .or. lLayout12

            oStruV9I := FWFormStruct(1, "V9I")
            oStruV9J := FWFormStruct(1, "V9J")

            oModel:AddGrid("MODEL_V9I", "MODEL_V6M", oStruV9I)
            oModel:GetModel("MODEL_V9I"):SetOptional(.T.)
            oModel:GetModel("MODEL_V9I"):SetMaxLine(1)     

            oModel:AddGrid("MODEL_V9J", "MODEL_V9I", oStruV9J)
            oModel:GetModel("MODEL_V9J"):SetOptional(.T.)
            oModel:GetModel("MODEL_V9J"):SetMaxLine(1)

            oModel:SetRelation("MODEL_V9I", {{"V9I_FILIAL", "xFilial('V9I')"}, {"V9I_ID", "T3P_ID"}, {"V9I_VERSAO", "T3P_VERSAO"}, {"V9I_TPPGTO", "V6M_TPPGTO"}, {"V9I_PERREF", "V6M_PERREF"}, {"V9I_INDDEV", "V6M_INDDEV"}}, V9I->(IndexKey(1)))
            oModel:SetRelation("MODEL_V9J", {{"V9J_FILIAL", "xFilial('V9J')"}, {"V9J_ID", "T3P_ID"}, {"V9J_VERSAO", "T3P_VERSAO"}, {"V9J_TPPGTO", "V6M_TPPGTO"}, {"V9J_PERREF", "V6M_PERREF"}, {"V9J_INDDEV", "V6M_INDDEV"}}, V9J->(IndexKey(1)))                
        
        EndIf

        If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC"))

            //infoDep
            oModel:AddGrid("MODEL_V7S", "MODEL_T3P", oStruV7S)
            oModel:GetModel("MODEL_V7S"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7S"):SetUniqueLine({"V7S_CPFDEP"})
            oModel:GetModel("MODEL_V7S"):SetMaxLine(999)

            //infoIRCR
            oModel:AddGrid("MODEL_V7T", "MODEL_T3P", oStruV7T)
            oModel:GetModel("MODEL_V7T"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7T"):SetUniqueLine({"V7T_TPCR"})
            oModel:GetModel("MODEL_V7T"):SetMaxLine(99)

            //dedDepen
            oModel:AddGrid("MODEL_V7U", "MODEL_V7T", oStruV7U)
            oModel:GetModel("MODEL_V7U"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7U"):SetUniqueLine({"V7U_TPREND","V7U_CPFDEP"})
            oModel:GetModel("MODEL_V7U"):SetMaxLine(999)

            //penAlim
            oModel:AddGrid("MODEL_V7V", "MODEL_V7T", oStruV7V)
            oModel:GetModel("MODEL_V7V"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7V"):SetUniqueLine({"V7V_TPREND","V7V_CPFDEP"})
            oModel:GetModel("MODEL_V7V"):SetMaxLine(99)

            //previdCompl
            oModel:AddGrid("MODEL_V7W", "MODEL_V7T", oStruV7W)
            oModel:GetModel("MODEL_V7W"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7W"):SetUniqueLine({"V7W_TPREV","V7W_INSCPL"})
            oModel:GetModel("MODEL_V7W"):SetMaxLine(99)

            //infoProcRet
            oModel:AddGrid("MODEL_V7X", "MODEL_V7T", oStruV7X)
            oModel:GetModel("MODEL_V7X"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7X"):SetUniqueLine({"V7X_TPPROC","V7X_NRPROC", "V7X_CODSUP"})
            oModel:GetModel("MODEL_V7X"):SetMaxLine(50)

            //infoValores
            oModel:AddGrid("MODEL_V7Y", "MODEL_V7X", oStruV7Y)
            oModel:GetModel("MODEL_V7Y"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7Y"):SetUniqueLine({"V7Y_INDAPU"})
            oModel:GetModel("MODEL_V7Y"):SetMaxLine(2)

            //dedSusp
            oModel:AddGrid("MODEL_V7Z", "MODEL_V7Y", oStruV7Z)
            oModel:GetModel("MODEL_V7Z"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7Z"):SetUniqueLine({"V7Z_SEQUEN"})
            oModel:GetModel("MODEL_V7Z"):SetMaxLine(25)

            //benefPen
            oModel:AddGrid("MODEL_V8A", "MODEL_V7Z", oStruV8A)
            oModel:GetModel("MODEL_V8A"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8A"):SetUniqueLine({"V8A_CPFDEP","V8A_SEQUEN"})
            oModel:GetModel("MODEL_V8A"):SetMaxLine(99)

            //planSaude
            oModel:AddGrid("MODEL_V8B", "MODEL_T3P", oStruV8B)
            oModel:GetModel("MODEL_V8B"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8B"):SetUniqueLine({"V8B_CNPJOP"})
            oModel:GetModel("MODEL_V8B"):SetMaxLine(99)

            //infoDepSau
            oModel:AddGrid("MODEL_V8C", "MODEL_V8B", oStruV8C)
            oModel:GetModel("MODEL_V8C"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8C"):SetUniqueLine({"V8C_CPFDEP"})
            oModel:GetModel("MODEL_V8C"):SetMaxLine(99)

            //infoReembMed
            oModel:AddGrid("MODEL_V8D", "MODEL_T3P", oStruV8D)
            oModel:GetModel("MODEL_V8D"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8D"):SetUniqueLine({"V8D_SEQUEN"})
            oModel:GetModel("MODEL_V8D"):SetMaxLine(99)

            //detReembTit
            oModel:AddGrid("MODEL_V8E", "MODEL_V8D", oStruV8E)
            oModel:GetModel("MODEL_V8E"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8E"):SetUniqueLine({"V8E_TPINSC", "V8E_NRINSC", "V8E_SEQUEN"})
            oModel:GetModel("MODEL_V8E"):SetMaxLine(99)

            //infoReembDep
            oModel:AddGrid("MODEL_V8F", "MODEL_V8D", oStruV8F)
            oModel:GetModel("MODEL_V8F"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8F"):SetUniqueLine({"V8F_CPFDEP", "V8F_SEQUEN"})
            oModel:GetModel("MODEL_V8F"):SetMaxLine(99)

            //detReembDep
            oModel:AddGrid("MODEL_V8G", "MODEL_V8F", oStruV8G)
            oModel:GetModel("MODEL_V8G"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8G"):SetUniqueLine({"V8G_TPINSC", "V8G_NRINSC", "V8G_SEQUEN"})
            oModel:GetModel("MODEL_V8G"):SetMaxLine(99)

            oModel:SetRelation("MODEL_V7S", {{"V7S_FILIAL", "xFilial('T3P')"}, {"V7S_ID", "T3P_ID"}, {"V7S_VERSAO", "T3P_VERSAO"}}, V7S->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7T", {{"V7T_FILIAL", "xFilial('T3P')"}, {"V7T_ID", "T3P_ID"}, {"V7T_VERSAO", "T3P_VERSAO"}}, V7T->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7U", {{"V7U_FILIAL", "xFilial('T3P')"}, {"V7U_ID", "T3P_ID"}, {"V7U_VERSAO", "T3P_VERSAO"},{"V7U_TPCR", "V7T_TPCR"}}, V7U->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7V", {{"V7V_FILIAL", "xFilial('T3P')"}, {"V7V_ID", "T3P_ID"}, {"V7V_VERSAO", "T3P_VERSAO"},{"V7V_TPCR", "V7T_TPCR"}}, V7V->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7W", {{"V7W_FILIAL", "xFilial('T3P')"}, {"V7W_ID", "T3P_ID"}, {"V7W_VERSAO", "T3P_VERSAO"},{"V7W_TPCR", "V7T_TPCR"}}, V7W->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7X", {{"V7X_FILIAL", "xFilial('T3P')"}, {"V7X_ID", "T3P_ID"}, {"V7X_VERSAO", "T3P_VERSAO"},{"V7X_TPCR", "V7T_TPCR"}}, V7X->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7Y", {{"V7Y_FILIAL", "xFilial('T3P')"}, {"V7Y_ID", "T3P_ID"}, {"V7Y_VERSAO", "T3P_VERSAO"},{"V7Y_TPCR", "V7T_TPCR"},{"V7Y_TPPROC", "V7X_TPPROC"}, {"V7Y_NRPROC", "V7X_NRPROC"}, {"V7Y_CODSUP", "V7X_CODSUP"}}, V7Y->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7Z", {{"V7Z_FILIAL", "xFilial('T3P')"}, {"V7Z_ID", "T3P_ID"}, {"V7Z_VERSAO", "T3P_VERSAO"},{"V7Z_TPCR", "V7T_TPCR"},{"V7Z_TPPROC", "V7X_TPPROC"}, {"V7Z_NRPROC", "V7X_NRPROC"}, {"V7Z_CODSUP", "V7X_CODSUP"},{"V7Z_INDAPU", "V7Y_INDAPU"}}, V7Z->(IndexKey(1)))
            oModel:SetRelation("MODEL_V8A", {{"V8A_FILIAL", "xFilial('T3P')"}, {"V8A_ID", "T3P_ID"}, {"V8A_VERSAO", "T3P_VERSAO"},{"V8A_TPCR", "V7T_TPCR"},{"V8A_TPPROC", "V7X_TPPROC"}, {"V8A_NRPROC", "V7X_NRPROC"}, {"V8A_CODSUP", "V7X_CODSUP"},{"V8A_INDAPU", "V7Y_INDAPU"}, {"V8A_SEQUEN", "V7Z_SEQUEN"}}, V8A->(IndexKey(2)))
            oModel:SetRelation("MODEL_V8B", {{"V8B_FILIAL", "xFilial('T3P')"}, {"V8B_ID", "T3P_ID"}, {"V8B_VERSAO", "T3P_VERSAO"}}, V8B->(IndexKey(1)))
            oModel:SetRelation("MODEL_V8C", {{"V8C_FILIAL", "xFilial('T3P')"}, {"V8C_ID", "T3P_ID"}, {"V8C_VERSAO", "T3P_VERSAO"},{"V8C_CNPJOP","V8B_CNPJOP"}}, V8C->(IndexKey(1)))
            oModel:SetRelation("MODEL_V8D", {{"V8D_FILIAL", "xFilial('T3P')"}, {"V8D_ID", "T3P_ID"}, {"V8D_VERSAO", "T3P_VERSAO"}}, V8D->(IndexKey(1)))
            oModel:SetRelation("MODEL_V8E", {{"V8E_FILIAL", "xFilial('T3P')"}, {"V8E_ID", "T3P_ID"}, {"V8E_VERSAO", "T3P_VERSAO"}, {"V8E_SEQUEN", "V8D_SEQUEN"}}, V8E->(IndexKey(2)))
            oModel:SetRelation("MODEL_V8F", {{"V8F_FILIAL", "xFilial('T3P')"}, {"V8F_ID", "T3P_ID"}, {"V8F_VERSAO", "T3P_VERSAO"}, {"V8F_SEQUEN", "V8D_SEQUEN"}}, V8F->(IndexKey(2)))
            oModel:SetRelation("MODEL_V8G", {{"V8G_FILIAL", "xFilial('T3P')"}, {"V8G_ID", "T3P_ID"}, {"V8G_VERSAO", "T3P_VERSAO"}, {"V8G_SEQUEN", "V8D_SEQUEN"}, {"V8G_CPFDEP", "V8F_CPFDEP"}}, V8G->(IndexKey(1)))
        
        ElseIf lSimpl0103 .AND. TAFColumnPos("V8F_SEQIRC")


            //infoIrComplem
            If !TYPE("ALTERA") == "U"
                If ALTERA
                    oStruT8E:SetProperty( 'T8E_DTLAUD'	, MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, IIf(!Empty(T3P->T3P_DTLAUD) .AND. Empty(T8E->T8E_DTLAUD),'T3P->T3P_DTLAUD','T8E->T8E_DTLAUD')))
                EndIf
            EndIf

            oModel:AddGrid("MODEL_T8E", "MODEL_T3P", oStruT8E)
            oModel:GetModel("MODEL_T8E"):SetOptional(.T.)
            oModel:GetModel("MODEL_T8E"):SetUniqueLine({"T8E_SEQIRC", "T8E_PERREF"})

            //infoDep
            oModel:AddGrid("MODEL_V7S", "MODEL_T8E", oStruV7S)
            oModel:GetModel("MODEL_V7S"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7S"):SetUniqueLine({"V7S_CPFDEP"})

            //infoIRCR
            oModel:AddGrid("MODEL_V7T", "MODEL_T8E", oStruV7T)
            oModel:GetModel("MODEL_V7T"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7T"):SetUniqueLine({"V7T_TPCR"})

            //dedDepen
            oModel:AddGrid("MODEL_V7U", "MODEL_V7T", oStruV7U)
            oModel:GetModel("MODEL_V7U"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7U"):SetUniqueLine({"V7U_TPREND","V7U_CPFDEP"})

            //penAlim
            oModel:AddGrid("MODEL_V7V", "MODEL_V7T", oStruV7V)
            oModel:GetModel("MODEL_V7V"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7V"):SetUniqueLine({"V7V_TPREND","V7V_CPFDEP"})

            //previdCompl
            oModel:AddGrid("MODEL_V7W", "MODEL_V7T", oStruV7W)
            oModel:GetModel("MODEL_V7W"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7W"):SetUniqueLine({"V7W_TPREV","V7W_INSCPL"})

            //infoProcRet
            oModel:AddGrid("MODEL_V7X", "MODEL_V7T", oStruV7X)
            oModel:GetModel("MODEL_V7X"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7X"):SetUniqueLine({"V7X_TPPROC","V7X_NRPROC", "V7X_CODSUP"})

            //infoValores
            oModel:AddGrid("MODEL_V7Y", "MODEL_V7X", oStruV7Y)
            oModel:GetModel("MODEL_V7Y"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7Y"):SetUniqueLine({"V7Y_INDAPU"})

            //dedSusp
            oModel:AddGrid("MODEL_V7Z", "MODEL_V7Y", oStruV7Z)
            oModel:GetModel("MODEL_V7Z"):SetOptional(.T.)
            oModel:GetModel("MODEL_V7Z"):SetUniqueLine({"V7Z_SEQUEN"})

            //benefPen
            oModel:AddGrid("MODEL_V8A", "MODEL_V7Z", oStruV8A)
            oModel:GetModel("MODEL_V8A"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8A"):SetUniqueLine({"V8A_CPFDEP","V8A_SEQUEN"})

            //planSaude
            oModel:AddGrid("MODEL_V8B", "MODEL_T8E", oStruV8B)
            oModel:GetModel("MODEL_V8B"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8B"):SetUniqueLine({"V8B_CNPJOP", "V8B_REGANS"})

            //infoDepSau
            oModel:AddGrid("MODEL_V8C", "MODEL_V8B", oStruV8C)
            oModel:GetModel("MODEL_V8C"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8C"):SetUniqueLine({"V8C_CPFDEP"})

            //infoReembMed
            oModel:AddGrid("MODEL_V8D", "MODEL_T8E", oStruV8D)
            oModel:GetModel("MODEL_V8D"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8D"):SetUniqueLine({"V8D_SEQUEN", "V8D_REGANS", "V8D_CNPJOP"})

            //detReembTit
            oModel:AddGrid("MODEL_V8E", "MODEL_V8D", oStruV8E)
            oModel:GetModel("MODEL_V8E"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8E"):SetUniqueLine({"V8E_TPINSC", "V8E_NRINSC", "V8E_SEQUEN"})

            //infoReembDep
            oModel:AddGrid("MODEL_V8F", "MODEL_V8D", oStruV8F)
            oModel:GetModel("MODEL_V8F"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8F"):SetUniqueLine({"V8F_CPFDEP", "V8F_SEQUEN"})

            //detReembDep
            oModel:AddGrid("MODEL_V8G", "MODEL_V8F", oStruV8G)
            oModel:GetModel("MODEL_V8G"):SetOptional(.T.)
            oModel:GetModel("MODEL_V8G"):SetUniqueLine({"V8G_TPINSC", "V8G_NRINSC", "V8G_SEQUEN"})

            oModel:SetRelation("MODEL_T8E", {{"T8E_FILIAL", "xFilial('T3P')"}, {"T8E_ID", "T3P_ID"}, {"T8E_VERSAO", "T3P_VERSAO"}}, T8E->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7S", {{"V7S_FILIAL", "xFilial('T3P')"}, {"V7S_ID", "T3P_ID"}, {"V7S_VERSAO", "T3P_VERSAO"}, {"V7S_SEQIRC", "T8E_SEQIRC"}}, V7S->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7T", {{"V7T_FILIAL", "xFilial('T3P')"}, {"V7T_ID", "T3P_ID"}, {"V7T_VERSAO", "T3P_VERSAO"}, {"V7T_SEQIRC", "T8E_SEQIRC"}}, V7T->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7U", {{"V7U_FILIAL", "xFilial('T3P')"}, {"V7U_ID", "T3P_ID"}, {"V7U_VERSAO", "T3P_VERSAO"}, {"V7U_TPCR", "V7T_TPCR"}, {"V7U_SEQIRC", "T8E_SEQIRC"}}, V7U->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7V", {{"V7V_FILIAL", "xFilial('T3P')"}, {"V7V_ID", "T3P_ID"}, {"V7V_VERSAO", "T3P_VERSAO"}, {"V7V_TPCR", "V7T_TPCR"}, {"V7V_SEQIRC", "T8E_SEQIRC"}}, V7V->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7W", {{"V7W_FILIAL", "xFilial('T3P')"}, {"V7W_ID", "T3P_ID"}, {"V7W_VERSAO", "T3P_VERSAO"}, {"V7W_TPCR", "V7T_TPCR"}, {"V7W_SEQIRC", "T8E_SEQIRC"}}, V7W->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7X", {{"V7X_FILIAL", "xFilial('T3P')"}, {"V7X_ID", "T3P_ID"}, {"V7X_VERSAO", "T3P_VERSAO"}, {"V7X_TPCR", "V7T_TPCR"}, {"V7X_SEQIRC", "T8E_SEQIRC"}}, V7X->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7Y", {{"V7Y_FILIAL", "xFilial('T3P')"}, {"V7Y_ID", "T3P_ID"}, {"V7Y_VERSAO", "T3P_VERSAO"}, {"V7Y_TPCR", "V7T_TPCR"}, {"V7Y_TPPROC", "V7X_TPPROC"}, {"V7Y_NRPROC", "V7X_NRPROC"}, {"V7Y_CODSUP", "V7X_CODSUP"}, {"V7Y_SEQIRC", "T8E_SEQIRC"}}, V7Y->(IndexKey(1)))
            oModel:SetRelation("MODEL_V7Z", {{"V7Z_FILIAL", "xFilial('T3P')"}, {"V7Z_ID", "T3P_ID"}, {"V7Z_VERSAO", "T3P_VERSAO"}, {"V7Z_TPCR", "V7T_TPCR"}, {"V7Z_TPPROC", "V7X_TPPROC"}, {"V7Z_NRPROC", "V7X_NRPROC"}, {"V7Z_CODSUP", "V7X_CODSUP"}, {"V7Z_INDAPU", "V7Y_INDAPU"}, {"V7Z_SEQIRC", "T8E_SEQIRC"}}, V7Z->(IndexKey(1)))
            oModel:SetRelation("MODEL_V8A", {{"V8A_FILIAL", "xFilial('T3P')"}, {"V8A_ID", "T3P_ID"}, {"V8A_VERSAO", "T3P_VERSAO"}, {"V8A_TPCR", "V7T_TPCR"}, {"V8A_TPPROC", "V7X_TPPROC"}, {"V8A_NRPROC", "V7X_NRPROC"}, {"V8A_CODSUP", "V7X_CODSUP"}, {"V8A_INDAPU", "V7Y_INDAPU"}, {"V8A_SEQUEN", "V7Z_SEQUEN"},{"V8A_SEQIRC", "T8E_SEQIRC"}}, V8A->(IndexKey(2)))
            oModel:SetRelation("MODEL_V8B", {{"V8B_FILIAL", "xFilial('T3P')"}, {"V8B_ID", "T3P_ID"}, {"V8B_VERSAO", "T3P_VERSAO"}, {"V8B_SEQIRC", "T8E_SEQIRC"}}, V8B->(IndexKey(1)))
            If TafColumnPos("V8B_SEQUEN")
                oModel:SetRelation("MODEL_V8C", {{"V8C_FILIAL", "xFilial('T3P')"}, {"V8C_ID", "T3P_ID"}, {"V8C_VERSAO", "T3P_VERSAO"}, {"V8C_CNPJOP", "V8B_CNPJOP"}, {"V8C_REGANS", "V8B_REGANS"}, {"V8C_SEQIRC", "T8E_SEQIRC"}, {"V8C_SEQUEN", "V8B_SEQUEN"}}, V8C->(IndexKey(2)))
            Else
                oModel:SetRelation("MODEL_V8C", {{"V8C_FILIAL", "xFilial('T3P')"}, {"V8C_ID", "T3P_ID"}, {"V8C_VERSAO", "T3P_VERSAO"}, {"V8C_CNPJOP", "V8B_CNPJOP"}, {"V8C_REGANS", "V8B_REGANS"}, {"V8C_SEQIRC", "T8E_SEQIRC"}}, V8C->(IndexKey(1)))
            EndIf 
            oModel:SetRelation("MODEL_V8D", {{"V8D_FILIAL", "xFilial('T3P')"}, {"V8D_ID", "T3P_ID"}, {"V8D_VERSAO", "T3P_VERSAO"}, {"V8D_SEQIRC", "T8E_SEQIRC"}}, V8D->(IndexKey(1)))
            oModel:SetRelation("MODEL_V8E", {{"V8E_FILIAL", "xFilial('T3P')"}, {"V8E_ID", "T3P_ID"}, {"V8E_VERSAO", "T3P_VERSAO"}, {"V8E_SEQUEN", "V8D_SEQUEN"}, {"V8E_SEQIRC", "T8E_SEQIRC"}}, V8E->(IndexKey(2)))
            oModel:SetRelation("MODEL_V8F", {{"V8F_FILIAL", "xFilial('T3P')"}, {"V8F_ID", "T3P_ID"}, {"V8F_VERSAO", "T3P_VERSAO"}, {"V8F_SEQUEN", "V8D_SEQUEN"}, {"V8F_SEQIRC", "T8E_SEQIRC"}}, V8F->(IndexKey(2)))
            oModel:SetRelation("MODEL_V8G", {{"V8G_FILIAL", "xFilial('T3P')"}, {"V8G_ID", "T3P_ID"}, {"V8G_VERSAO", "T3P_VERSAO"}, {"V8G_SEQUEN", "V8D_SEQUEN"}, {"V8G_CPFDEP", "V8F_CPFDEP"}, {"V8G_SEQIRC", "T8E_SEQIRC"}}, V8G->(IndexKey(1)))

        EndIf
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Siqueira
@since 29/12/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local aCmpGrp    as Array
	Local cGrpBen1   as Character
	Local cGrpBen2	 as Character
	Local cGrpBen3 	 as Character
    Local cGrpBen5   as Character
	Local cFldLE2    as Character
	Local cFldLE4    as Character
	Local cFldT5Y    as Character
	Local cFldT6Q    as Character
	Local cFldT6R    as Character
	Local lIncMV     as Logical
	Local lCallInc	 as Logical
    Local lLayout12  as Logical
    Local lNewView   as Logical
    Local nMv        as Numeric
    Local nView      as Numeric
	Local nI         as Numeric
	Local oStruT3Pa	 as Object
	Local oStruT3Pb  as Object
	Local oStruT3Pc  as Object
	Local oStruT3Pd  as Object
	Local oStruT3Pe  as Object
    Local oStruT3Pf  as Object
	Local oStruT3Q 	 as Object
	Local oStruT3R 	 as Object
	Local oStruLE2 	 as Object
	Local oStruLE3 	 as Object
	Local oStruLE4   as Object
	Local oStruT5U 	 as Object
	Local oStruT5Y 	 as Object
	Local oStruT5Z 	 as Object
	Local oStruT5V 	 as Object
	Local oStruT5X 	 as Object
	Local oStruT6P 	 as Object
	Local oStruT6Q 	 as Object
	Local oStruT6R 	 as Object
	Local oStruV6M   as Object
    Local oStruV9I   as Object
    Local oStruV9J   as Object
    Local oStruT8E   as Object
    LocaL oStruV8D   as Object
	Local oModel 	 as Object
	Local oView 	 as Object
    Local oStruV7S      as Object
    Local oStruV7T      as Object
    Local oStruV7U      as Object
    Local oStruV7V      as Object
    Local oStruV7X      as Object
    Local oStruV7W      as Object
    Local oStruV7Y      as Object
    Local oStruV7Z      as Object
    Local oStruV8A      as Object
    Local oStruV8B      as Object
    Local oStruV8C      as Object
    Local oStruV8E      as Object
    Local oStruV8F      as Object
    Local oStruV8G      as Object
    

	aCmpGrp     := {}
	cGrpBen1	:= ""
	cGrpBen2	:= ""
	cGrpBen3 	:= ""
    cGrpBen5    := ""
	cFldLE2     := ""
	cFldLE4     := ""
	cFldT5Y     := ""
	cFldT6Q     := ""
	cFldT6R     := ""
	lIncMV      := .F.
	lCallInc	:= .T.
    lLayout12   := lSimpl12 
    lNewView    := .F.
	nI          := 0
    nMv         := 0
    nView       := 1
	oStruT3Pa	:= Nil
	oStruT3Pb   := Nil
	oStruT3Pc   := Nil
	oStruT3Pd   := Nil
	oStruT3Pe   := Nil
    oStruT3Pf   := Nil
	oStruT3Q 	:= Nil
	oStruT3R 	:= Nil
	oStruLE2 	:= Nil
	oStruLE3 	:= Nil
	oStruLE4    := Nil
	oStruT5U 	:= Nil
	oStruT5Y 	:= Nil
	oStruT5Z 	:= Nil
	oStruT5V 	:= Nil
	oStruT5X 	:= Nil
	oStruT6P 	:= Nil
	oStruT6Q 	:= Nil
	oStruT6R 	:= Nil
	oStruV6M    := Nil
    oStruV9I    := Nil
    oStruV9J    := Nil
    oStruT8E    := Nil
    oStruV8D    := Nil
    oStruV7S      := nIL
    oStruV7T      := nIL
    oStruV7U      := nIL
    oStruV7V      := nIL
    oStruV7X      := nIL
    oStruV7W      := nIL
    oStruV7Y      := nIL
    oStruV7Z      := nIL
    oStruV8A      := nIL
    oStruV8B      := nIL
    oStruV8C      := nIL
    oStruV8E      := nIL
    oStruV8F      := nIL
    oStruV8G      := nIL
	oModel 	    := FWLoadModel('TAFA407')
	oView 	    := FWFormView():New()

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	If !lLaySimplif

		oStruT3Q    := FWFormStruct( 2, 'T3Q' )
		oStruT3R 	:= FWFormStruct( 2, 'T3R' )
		oStruLE3 	:= FWFormStruct( 2, 'LE3' )
		oStruT5U 	:= FWFormStruct( 2, 'T5U' )
		oStruT5Z 	:= FWFormStruct( 2, 'T5Z' )
		oStruT5V 	:= FWFormStruct( 2, 'T5V' )
		oStruT5X 	:= FWFormStruct( 2, 'T5X' )
		oStruT6P    := FWFormStruct( 2, 'T6P' )

        /*-----------------------------------------------------------------------------------
        Estrutura da View de Apuração
        -------------------------------------------------------------------------------------*/
        cGrpBen1 	:= "T3P_ID|T3P_INDAPU|T3P_PERAPU|"
        cCmpFil   	:= cGrpBen1
        oStruT3Pa	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        /*-----------------------------------------------------------------------------------
         Identificaçao do Beneficiario de Pagamento
        -------------------------------------------------------------------------------------*/
        If FWIsInCallStack( "TAF407Inc" ) .And. !FWIsInCallStack( "TAF407AUTI" )
        
            lCallInc 	:= .F.
            lIncMV 		:= Aviso( "Atenção", "O pagamento de rendimentos do trabalho a ser incluído é de um funcionário com ";
                            + "múltiplos vínculos?", {"Sim", "Não"}, 2 ) == 1

        ElseIf FWIsInCallStack( "TAF407AUTI" )

            lCallInc 	:= .F.

        EndIf

        If ( !lCallInc .And. lIncMV ) .Or. ( lCallInc .And. Empty( T3P->T3P_BENEFI ) )

            cGrpBen2 := "T3P_CPF|T3P_NOMER|"
            cFldLE2 := "LE2_IDRUBR|LE2_DRUBR|"
            cFldLE4 := "LE4_IDRUBR|LE4_DRUBR|LE4_MATRIC"
            cFldT5Y := "T5Y_IDRUBR|T5Y_DRUBR|"
            cFldT6Q := "T6Q_IDRUBR|T6Q_DRUBR|"
            cFldT6R := "T6R_IDRUBR|T6R_DRUBR|"

        Else

            cGrpBen2 := "T3P_BENEFI|T3P_NOME|"
            cFldLE2 := "LE2_RUBRIC|LE2_IDTABR|"
            cFldLE4 := "LE4_RUBRIC|LE4_IDTABR|"
            cFldT5Y := "T5Y_RUBRIC|T5Y_IDTABR|"
            cFldT6Q := "T6Q_RUBRIC|T6Q_IDTABR|"
            cFldT6R := "T6R_RUBRIC|T6R_IDTABR|"

        Endif

        cCmpFil   := cGrpBen2
        oStruT3Pb := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        oStruLE2 := FWFormStruct( 2, 'LE2', { |x| !(AllTrim( x ) + "|" $ cFldLE2) }  )
        oStruLE4 := FWFormStruct( 2, 'LE4', { |x| !(AllTrim( x ) + "|" $ cFldLE4) }  )
        oStruT5Y := FWFormStruct( 2, 'T5Y', { |x| !(AllTrim( x ) + "|" $ cFldT5Y) }  )
        oStruT6Q := FWFormStruct( 2, 'T6Q', { |x| !(AllTrim( x ) + "|" $ cFldT6Q) }  )
        oStruT6R := FWFormStruct( 2, 'T6R', { |x| !(AllTrim( x ) + "|" $ cFldT6R) }  )

        If ( !lCallInc .And. lIncMV ) .Or. ( lCallInc .And. Empty( T3P->T3P_BENEFI ) )

            oStruLE2:SetProperty("LE2_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruLE2:SetProperty("LE2_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruLE4:SetProperty("LE4_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruLE4:SetProperty("LE4_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruT5Y:SetProperty("T5Y_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruT5Y:SetProperty("T5Y_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruT6Q:SetProperty("T6Q_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruT6Q:SetProperty("T6Q_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruT6R:SetProperty("T6R_RUBRIC", MVC_VIEW_ORDEM, "01")
            oStruT6R:SetProperty("T6R_IDTABR", MVC_VIEW_ORDEM, "02")
            oStruLE4:RemoveField("LE4_MATRIC")
            oStruT5U:RemoveField("T5U_MATRIC")

        EndIf

        //-----------------------------------------------------------------------
        // Altera consulta padrão do beneficiário para apenas exibir autonomos
        //-----------------------------------------------------------------------
        If FWIsInCallStack( "TAF407AUTI" )
            oStruT3Pb:SetProperty( "T3P_BENEFI"	, MVC_VIEW_LOOKUP, "C9VAUT" )
        EndIf

        /*-----------------------------------------------------------------------------------
        Informações de dependentes do beneficiário do pagamento
        -------------------------------------------------------------------------------------*/
        cGrpBen4  := "T3P_VLDEDB|"
        cCmpFil   := cGrpBen4
        oStruT3Pd := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        /*-----------------------------------------------------------------------------------
        Protocolo de Transmissao
        -------------------------------------------------------------------------------------*/
        cGrpBen3 := "T3P_PROTUL|"   
        cCmpFil   := cGrpBen3
        oStruT3Pc	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        cCmpFil := "T3P_DINSIS|T3P_DTRANS|T3P_HTRANS|T3P_DTRECP|T3P_HRRECP|"
        oStruT3Pe	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
        
        /*-----------------------------------------------------------------------------------
        Grupo de campos do Beneficiário
        -------------------------------------------------------------------------------------*/
        //Informações do Beneficiario
        oStruT3Pa:AddGroup( "GRP_BENEFICARIO_01", STR0003, "", 1 ) //Informações de Apuração
        oStruT3Pb:AddGroup( "GRP_BENEFICARIO_02", STR0011, "", 1 ) //Beneficiário
        oStruT3Pd:AddGroup( "GRP_BENEFICARIO_03", STR0022, "", 1 ) //Dependentes do Beneficiário do Pagamento

        aCmpGrp := StrToKArr(cGrpBen1,"|")

        For nI := 1 to Len(aCmpGrp)
            oStruT3Pa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_01")
        Next nI

        aCmpGrp := StrToKArr(cGrpBen2,"|")

        For nI := 1 to Len(aCmpGrp)
            oStruT3Pb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_02")
        Next nI

        aCmpGrp := StrToKArr(cGrpBen4,"|")

        For nI := 1 to Len(aCmpGrp)
            oStruT3Pd:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_03")
        Next nI
       
        oStruLE2:SetProperty("LE2_SEQUEN",MVC_VIEW_CANCHANGE,.F.)

        /*-----------------------------------------------------------------------------------
                                    Esrutura da View
        -------------------------------------------------------------------------------------*/
        oView:AddField( "VIEW_T3Pa", oStruT3Pa, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pb", oStruT3Pb, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pd", oStruT3Pd, "MODEL_T3P" )
        oView:AddField( "VIEW_T3Pc", oStruT3Pc, "MODEL_T3P" )

        oView:EnableTitleView('VIEW_T3Pc',TafNmFolder("recibo",1)) // "Recibo da última Transmissão"

        oView:AddField( "VIEW_T3Pe", oStruT3Pe, "MODEL_T3P" )
        oView:EnableTitleView('VIEW_T3Pe',TafNmFolder("recibo",2))
        
        oView:AddGrid( "VIEW_T3Q", oStruT3Q, "MODEL_T3Q" )
        oView:EnableTitleView("VIEW_T3Q",STR0008) //"Informações dos Pagamentos Efetuados"

        //Detalhamento dos pagamentos efetuados, relativos a folha de pagamento e rescisões contratuais, apurados em S-1200, S-1202, S-2299 e S-2399.
        oView:AddGrid( "VIEW_T3R", oStruT3R, "MODEL_T3R" )
        oView:EnableTitleView("VIEW_T3R",STR0024) //Detalhamento dos Pgtos
        oView:AddGrid( "VIEW_LE2", oStruLE2, "MODEL_LE2" )
        oView:EnableTitleView("VIEW_LE2",STR0026) //"Rubricas de Pgto"
        oView:AddGrid( "VIEW_LE3", oStruLE3, "MODEL_LE3" )
        oView:EnableTitleView("VIEW_LE3",STR0017) //Pensão Alimentícia
        oView:AddGrid( "VIEW_LE4", oStruLE4, "MODEL_LE4" )
        oView:EnableTitleView("VIEW_LE4",STR0026) //"Rubricas de Pgto"

        //Detalhamento de Pagamentos Relativos a Benefícios Previdenciários
        oView:AddGrid( "VIEW_T6P", oStruT6P, "MODEL_T6P" )
        oView:EnableTitleView("VIEW_T6P",STR0024) //"Detalhamento dos Pgtos"
        oView:AddGrid( "VIEW_T6Q", oStruT6Q, "MODEL_T6Q" )
        oView:EnableTitleView("VIEW_T6Q",STR0016) //Rubricas de Pgto
        oView:AddGrid( "VIEW_T6R", oStruT6R, "MODEL_T6R" )
        oView:EnableTitleView("VIEW_T6R",STR0018) //Rubricas de Pgto

        //Detalhamento dos pagamentos efetuados relativos a férias
        oView:AddGrid( "VIEW_T5U", oStruT5U, "MODEL_T5U" )
        oView:EnableTitleView("VIEW_T5U",STR0024) //Detalhamento dos Pgtos
        oView:AddGrid( "VIEW_T5Y", oStruT5Y, "MODEL_T5Y" )
        oView:EnableTitleView("VIEW_T5Y",STR0031) //Rubricas do Recibo Antecipado de Férias
        oView:AddGrid( "VIEW_T5Z", oStruT5Z, "MODEL_T5Z" )
        oView:EnableTitleView("VIEW_T5Z",STR0017) //Pensão Alimentícia

        //Pagamento relativo a competências anteriores
        oView:AddGrid( "VIEW_T5V", oStruT5V, "MODEL_T5V" )
        oView:EnableTitleView("VIEW_T5V",STR0032) //Referências

        oView:AddGrid( "VIEW_T5X", oStruT5X, "MODEL_T5X" )
        oView:AddIncrementField( 'VIEW_T5X', 'T5X_SEQUEN' )
        oView:EnableTitleView("VIEW_T5X",STR0024) //Detalhamento dos Pgtos

        //------------------------------------
        // Ordem dos campos na tela para T5X
        //-----------------------------------
        oStruT5X:SetProperty( "T5X_SEQUEN"	, MVC_VIEW_ORDEM	, "08"	)
        oStruT5X:SetProperty( "T5X_IDTPIR"	, MVC_VIEW_ORDEM	, "09"	)
        oStruT5X:SetProperty( "T5X_DTPIRR"	, MVC_VIEW_ORDEM	, "10"	)
        oStruT5X:SetProperty( "T5X_VLRBCI"	, MVC_VIEW_ORDEM	, "11"	)

        TafAjustRecibo(oStruT3Pc,"T3P")
        
        /*---------------------------------------------------------------------------------
                                    Estrutura do Folder
        ---------------------------------------------------------------------------------*/
        oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
        oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

        //Abas
        oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0004 )   //"Informações de Beneficiários"
        oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
    
        //////////////////////////////////////////////////////////////////////////////////
        oView:CreateHorizontalBox("T3Pa"            , 009,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("T3Pb"            , 009,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("T3Pd"            , 009,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("T3Q"             , 015,,, "FOLDER_SUPERIOR", "ABA01")
        oView:CreateHorizontalBox("PAINEL_INFOPGTO" , 058,,, "FOLDER_SUPERIOR", "ABA01")

        oView:CreateFolder( 'FOLDER_INFOPGTO', 'PAINEL_INFOPGTO' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA01", STR0023 ) //Detalhamento dos eventos S-1200, S-1202, S-2299 e S-2399
        oView:CreateHorizontalBox( 'T3R', 025,,, 'FOLDER_INFOPGTO', 'ABA01' )

        oView:CreateHorizontalBox("PAINEL_DETHALFOLHA",075,,,"FOLDER_INFOPGTO","ABA01")
        oView:CreateFolder( 'FOLDER_DETHALFOLHA', 'PAINEL_DETHALFOLHA' )
        oView:AddSheet( "FOLDER_DETHALFOLHA", "ABA01", STR0025 ) //"Retenções do Pgto Total"
        oView:CreateHorizontalBox( 'LE2', 	050,,, 'FOLDER_DETHALFOLHA', 'ABA01' )
        oView:AddIncrementField( 'VIEW_LE2', 'LE2_SEQUEN' ) 
        oView:CreateHorizontalBox( 'LE3', 	050,,, 'FOLDER_DETHALFOLHA', 'ABA01' )
        oView:AddSheet( "FOLDER_DETHALFOLHA", "ABA02", STR0027 ) //Informação de Pgto Parc.
        oView:CreateHorizontalBox( 'LE4', 	100,,, 'FOLDER_DETHALFOLHA', 'ABA02' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA02", STR0028 ) //Benefícios Previdenciários
        oView:CreateHorizontalBox( 'T6P', 	050,,, 'FOLDER_INFOPGTO', 'ABA02' )
        oView:CreateHorizontalBox("PAINEL_BENEFICI",050,,,"FOLDER_INFOPGTO","ABA02")
        oView:CreateFolder( 'FOLDER_BENEFICI', 'PAINEL_BENEFICI' )
        oView:AddSheet( "FOLDER_BENEFICI", "ABA01", STR0025 ) //Retenções do Pgto Total
        oView:CreateHorizontalBox( 'T6Q', 	100,,, 'FOLDER_BENEFICI', 'ABA01' )
        oView:AddSheet( "FOLDER_BENEFICI", "ABA02", STR0027 ) //Informação de Pgto Parc.
        oView:CreateHorizontalBox( 'T6R', 	100,,, 'FOLDER_BENEFICI', 'ABA02' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA03", STR0029 ) //Pgtos Efetuados Relativos a Férias
        oView:CreateHorizontalBox( 'T5U', 	035,,, 'FOLDER_INFOPGTO', 'ABA03' )
        oView:CreateHorizontalBox( 'T5Y', 	035,,, 'FOLDER_INFOPGTO', 'ABA03' )
        oView:CreateHorizontalBox( 'T5Z', 	030,,, 'FOLDER_INFOPGTO', 'ABA03' )

        ///////////////////////////////////////////////////////////////////////////////////
        oView:AddSheet( "FOLDER_INFOPGTO", "ABA04", STR0030 ) //Pgto Relativo a Competências Anteriores
        oView:CreateHorizontalBox( 'T5V', 	050,,, 'FOLDER_INFOPGTO', 'ABA04' )
        oView:CreateHorizontalBox( 'T5X', 	050,,, 'FOLDER_INFOPGTO', 'ABA04' )

        //////////////////////////////////////////////////////////////////////////////////

        oView:CreateHorizontalBox( 'T3Pc',  20,,,'FOLDER_SUPERIOR', 'ABA02' )
        oView:CreateHorizontalBox( 'T3Pe',  80,,,'FOLDER_SUPERIOR', 'ABA02' )
    
        oStruT3Pa:RemoveField('T3P_ID')
        oStruT5Y:RemoveField('T5Y_QTDIAS')
        oStruT5Z:RemoveField('T5Z_QTDIAS')
        
        /*-----------------------------------------------------------------------------------
                                    Amarração para exibição das informações
        -------------------------------------------------------------------------------------*/
        oView:SetOwnerView( "VIEW_T3Pa"  , "T3Pa" )
        oView:SetOwnerView( "VIEW_T3Pb"  , "T3Pb" )
        oView:SetOwnerView( "VIEW_T3Pc"  , "T3Pc" )
        oView:SetOwnerView( "VIEW_T3Pd"  , "T3Pd" )
        oView:SetOwnerView( "VIEW_T3Pe"  , "T3Pe" )
        
        oView:SetOwnerView( "VIEW_T3Q"   , "T3Q"  )
        oView:SetOwnerView( "VIEW_T3R"   , "T3R"  )
        oView:SetOwnerView( "VIEW_LE2"   , "LE2"  )
        oView:SetOwnerView( "VIEW_LE3"   , "LE3"  )
        oView:SetOwnerView( "VIEW_LE4"   , "LE4"  )

        oView:SetOwnerView( "VIEW_T6P"   , "T6P"  )
        oView:SetOwnerView( "VIEW_T6Q"   , "T6Q"  )
        oView:SetOwnerView( "VIEW_T6R"   , "T6R"  )
        oView:SetOwnerView( "VIEW_T5U"   , "T5U"  )
        oView:SetOwnerView( "VIEW_T5Y"   , "T5Y"  )
        oView:SetOwnerView( "VIEW_T5Z"   , "T5Z"  )
        oView:SetOwnerView( "VIEW_T5V"   , "T5V"  )
        oView:SetOwnerView( "VIEW_T5X"   , "T5X"  )

    Else

        oStruV6M := FWFormStruct(2, "V6M")
        
        If !lSimplBeta       
            oStruV6M:RemoveField("V6M_PAIEXT")
            oStruV6M:RemoveField("V6M_DPAIEX")
        EndIf

        cGrpBen1 	:= "T3P_ID|T3P_PERAPU|T3P_TPGUIA|"
        cCmpFil   	:= cGrpBen1

        If lSimpl0103

            If FWIsInCallStack( "TAF407Inc" ) .And. !FWIsInCallStack( "TAF407AUTI" )
                
                TafContnuews( 3 , @nMv, @nView)

                IIf(nMv == 1, lIncMV := .T.,)

                lCallInc 	:= .F.

            ElseIf FWIsInCallStack( "TAF407AUTI" )
                TafContnuews( 4 , @nMv, @nView)
                lCallInc 	:= .F.
            ElseIf FWIsInCallStack( "xTafAlt" ) .OR. FWIsInCallStack( "TAF407View" ) .OR. ( FWIsInCallStack('VIEWDEF') .AND. !FWIsInCallStack( "TAF407Inc" ) )
                TafContnuews( 4, @nMv, @nView)
            EndIf

            IIf(nView == 1, lNewView := .T., lNewView := .F.)

            If lNewView
                oView:SetContinuousForm(.F.)
            Else
                oView:SetContinuousForm(.T.)
            EndIf
            
        Else
            If FWIsInCallStack( "TAF407Inc" ) .And. !FWIsInCallStack( "TAF407AUTI" )
                lCallInc 	:= .F.
                lIncMV 		:= Aviso( "Atenção", "O pagamento de rendimentos do trabalho a ser incluído é de um funcionário com ";
                                + "múltiplos vínculos?", {"Sim", "Não"}, 2 ) == 1
            ElseIf FWIsInCallStack( "TAF407AUTI" )
                lCallInc 	:= .F.
            EndIf
        EndIf

        If !lNewView
			oStruT3Pa	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
		EndIf

        If ( !lCallInc .And. lIncMV ) .Or. ( lCallInc .And. Empty( T3P->T3P_BENEFI ) )
            cGrpBen2 := "T3P_CPF|"
        Else
            cGrpBen2 := "T3P_BENEFI|T3P_NOME|"
        EndIf

        If !lNewView
        
            cCmpFil   := cGrpBen2
            oStruT3Pb := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

            If FWIsInCallStack( "TAF407AUTI" )
                oStruT3Pb:SetProperty( "T3P_BENEFI"	, MVC_VIEW_LOOKUP, "C9VAUT" )
            EndIf

        Else
            cCmpFil   += cGrpBen2
        EndIf

        If lLayout12 

            If lSimpl0103 .AND. TAFColumnPos("T8E_DTLAUD")
                
                If TYPE("INCLUI") == "U" .AND. TYPE("ALTERA") == "U"
                    INCLUI := .F. 
                    ALTERA := .F. 
                EndIf

                If !INCLUI .AND. !ALTERA   
                
                    If !Empty(T3P->T3P_DTLAUD) .AND. Empty(T8E->T8E_DTLAUD)
                        cGrpBen5 := "T3P_DTLAUD|"
						If !lNewView
							cCmpFil  := cGrpBen5
							oStruT3Pf := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
						Else
							cCmpFil  += cGrpBen5
						EndIf
                    EndIf

                EndIf

            Else

                cGrpBen5 := "T3P_DTLAUD|"

                cCmpFil  := cGrpBen5
                oStruT3Pf := FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
    
            EndIf

        EndIf

        If lNewView
            oStruT3Pa	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

            If FWIsInCallStack( "TAF407AUTI" )
                oStruT3Pa:SetProperty( "T3P_BENEFI"	, MVC_VIEW_LOOKUP, "C9VAUT" )
            EndIf
        EndIf

        cGrpBen3 := "T3P_PROTUL|"
        cCmpFil   := cGrpBen3
        oStruT3Pc	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        
        cCmpFil := "T3P_DINSIS|T3P_DTRANS|T3P_HTRANS|T3P_DTRECP|T3P_HRRECP|"
        oStruT3Pe	:= FwFormStruct( 2, "T3P",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

        If !lNewView

            oStruT3Pa:AddGroup( "GRP_BENEFICARIO_01", STR0003, "", 1 )  //Informações de Apuração
            oStruT3Pb:AddGroup( "GRP_BENEFICARIO_02", STR0011, "", 1 )  //Beneficiário

            If lLayout12 

                If lSimpl0103 .AND. TAFColumnPos("T8E_DTLAUD")

                    If !INCLUI .AND. !ALTERA   

                        If !Empty(T3P->T3P_DTLAUD) .AND. Empty(T8E->T8E_DTLAUD) .AND. !lNewView
                            oStruT3Pf:AddGroup( "GRP_BENEFICARIO_03", "Informações relacionadas à retenção na fonte", "", 1 )
                        EndIf

                    EndIf
                Else
                    
                    oStruT3Pf:AddGroup( "GRP_BENEFICARIO_03", "Informações relacionadas à retenção na fonte", "", 1 )
                    
                EndIf

            EndIf

            aCmpGrp := StrToKArr(cGrpBen1,"|")

            For nI := 1 to Len(aCmpGrp)
                oStruT3Pa:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_01")
            Next nI

            aCmpGrp := StrToKArr(cGrpBen2,"|")

            For nI := 1 to Len(aCmpGrp)
                oStruT3Pb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_02")
            Next nI

            If lLayout12 

                If lSimpl0103 .AND. TAFColumnPos("T8E_DTLAUD")
                    
                    If !INCLUI .AND. !ALTERA

                        If !Empty(T3P->T3P_DTLAUD) .AND. Empty(T8E->T8E_DTLAUD) .AND. !lNewView
                            
                            aCmpGrp := StrToKArr(cGrpBen5,"|")

                            For nI := 1 to Len(aCmpGrp)
                                oStruT3Pf:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_03")
                            Next nI

                        EndIf

                    EndIf

                Else
                    
                    aCmpGrp := StrToKArr(cGrpBen5,"|")

                    For nI := 1 to Len(aCmpGrp)
                        oStruT3Pf:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_BENEFICARIO_03")
                    Next nI
                    
                EndIf

            EndIf

        EndIf 

        oView:AddField( "VIEW_T3Pa", oStruT3Pa, "MODEL_T3P" )
        
        If !lNewView
            oView:AddField( "VIEW_T3Pb", oStruT3Pb, "MODEL_T3P" )
        EndIf

        If lLayout12 

            If lSimpl0103 .AND. TAFColumnPos("T8E_DTLAUD")

                If !INCLUI .AND. !ALTERA

                    If !Empty(T3P->T3P_DTLAUD) .AND. Empty(T8E->T8E_DTLAUD) .AND. !lNewView
                        oView:AddField( "VIEW_T3Pf", oStruT3Pf, "MODEL_T3P" )
                    EndIf

                EndIf

            Else    
                
                oView:AddField( "VIEW_T3Pf", oStruT3Pf, "MODEL_T3P" )
                
            EndIf
            
        EndIf

        oView:AddField( "VIEW_T3Pc", oStruT3Pc, "MODEL_T3P" )
        oView:EnableTitleView('VIEW_T3Pc',TafNmFolder("recibo",1)) // "Recibo da última Transmissão"
        
        oView:AddField( "VIEW_T3Pe", oStruT3Pe, "MODEL_T3P" )
        oView:EnableTitleView('VIEW_T3Pe',TafNmFolder("recibo",2))

        oView:AddGrid( "VIEW_V6M", oStruV6M, "MODEL_V6M" )
        oView:EnableTitleView("VIEW_V6M", STR0008)  //"Informações dos Pagamentos Efetuados"

        oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
        oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

        //Abas
        oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0004 )   //"Informações de Beneficiários"

        If lLayout12 .OR. lSimpl0103
            oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0041 )   //"Informações IRRF
            oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', TafNmFolder("recibo") ) //"Numero do Recibo"
        Else
            If FindFunction('TafNmFolder')
                oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") ) //"Numero do Recibo"
            Else
                oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0007 )   //"Protocolo de Transmissão"
            EndIf
        EndIf 

		If !lNewView
			oView:CreateHorizontalBox( 'T3Pa',  004,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'T3Pb',  004,,, 'FOLDER_SUPERIOR', 'ABA01' )
			oView:CreateHorizontalBox( 'T3Pf',  002,,, 'FOLDER_SUPERIOR', 'ABA01' )
		Else
			oView:CreateHorizontalBox( 'T3Pa',  030,,, 'FOLDER_SUPERIOR', 'ABA01' )
		EndIf

		oView:CreateHorizontalBox( 'V6M' , 	030,,, 'FOLDER_SUPERIOR', 'ABA01' )
		
        If lLayout12 .OR. lSimpl0103

            If !lNewView
                oView:CreateHorizontalBox( 'T3Pc',  20,,,'FOLDER_SUPERIOR', 'ABA03' )
                oView:CreateHorizontalBox( 'T3Pe',  80,,,'FOLDER_SUPERIOR', 'ABA03' )
            Else
                oView:CreateHorizontalBox( 'T3Pc',  30,,,'FOLDER_SUPERIOR', 'ABA03' )
                oView:CreateHorizontalBox( 'T3Pe',  70,,,'FOLDER_SUPERIOR', 'ABA03' )
            EndIf
        Else
        
            oView:CreateHorizontalBox( 'T3Pc',  20,,,'FOLDER_SUPERIOR', 'ABA02' )
            oView:CreateHorizontalBox( 'T3Pe',  80,,,'FOLDER_SUPERIOR', 'ABA02' )
        
        EndIf

        oStruT3Pa:RemoveField("T3P_VLDEDB") 
        oStruT3Pa:RemoveField("T3P_INDAPU") 

        oView:SetOwnerView( "VIEW_T3Pa"  , "T3Pa" )
		
        If !lNewView
			oView:SetOwnerView( "VIEW_T3Pb"  , "T3Pb" )

			If lLayout12 .AND. !lSimpl0103
			    oView:SetOwnerView( "VIEW_T3Pf"  , "T3Pf" )
			EndIf 
		EndIf

        oView:SetOwnerView( "VIEW_T3Pc"  , "T3Pc" )
        oView:SetOwnerView( "VIEW_T3Pe"  , "T3Pe" )
        oView:SetOwnerView( "VIEW_V6M"   , "V6M"  )

        If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT") .Or. lLayout12
            oStruV9I := FWFormStruct(2, "V9I")
            oStruV9J := FWFormStruct(2, "V9J")

            oView:AddGrid("VIEW_V9I", oStruV9I, "MODEL_V9I")
            oView:AddGrid("VIEW_V9J", oStruV9J, "MODEL_V9J")

            oView:EnableTitleView("VIEW_V9I", STR0039) // "Informações complementares relativas a pagamentos a residente fiscal no exterior"
            oView:EnableTitleView("VIEW_V9J", STR0040) // "Endereço do beneficiário residente ou domiciliado no exterior"

			If !lNewView
				oView:CreateHorizontalBox("V9I", 030,,, "FOLDER_SUPERIOR", "ABA01")
                oView:CreateHorizontalBox("V9J", 030,,, "FOLDER_SUPERIOR", "ABA01")
			Else
				oView:CreateHorizontalBox("V9I", 020,,, "FOLDER_SUPERIOR", "ABA01")
				oView:CreateHorizontalBox("V9J", 020,,, "FOLDER_SUPERIOR", "ABA01")
			EndIf
            
            oView:SetOwnerView("VIEW_V9I", "V9I")
            oView:SetOwnerView("VIEW_V9J", "V9J")

        EndIf

        If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC"))
        
            oStruV7S := FWFormStruct(2, "V7S") 
            oStruV7T := FWFormStruct(2, "V7T") 

            oStruV7U := FWFormStruct(2, "V7U")
            oStruV7U:RemoveField('V7U_TPCR')

            oStruV7V := FWFormStruct(2, "V7V")
            oStruV7V:RemoveField('V7V_TPCR')
            
            oStruV7W := FWFormStruct(2, "V7W")
            oStruV7W:RemoveField('V7W_TPCR')

            oStruV7X := FWFormStruct(2, "V7X")
            oStruV7X:RemoveField('V7X_TPCR')

            oStruV7Y := FWFormStruct(2, "V7Y")
            oStruV7Y:RemoveField('V7Y_TPCR')
            oStruV7Y:RemoveField('V7Y_TPPROC')
            oStruV7Y:RemoveField('V7Y_NRPROC')
            oStruV7Y:RemoveField('V7Y_CODSUP')

            oStruV7Z := FWFormStruct(2, "V7Z")
            oStruV7Z:RemoveField('V7Z_FILIAL')
            oStruV7Z:RemoveField('V7Z_TPCR')
            oStruV7Z:RemoveField('V7Z_TPPROC')
            oStruV7Z:RemoveField('V7Z_NRPROC')
            oStruV7Z:RemoveField('V7Z_CODSUP')
            oStruV7Z:RemoveField('V7Z_INDAPU')

            oStruV8A := FWFormStruct(2, "V8A")
            oStruV8A:RemoveField('V8A_TPCR')
            oStruV8A:RemoveField('V8A_TPPROC')
            oStruV8A:RemoveField('V8A_NRPROC')
            oStruV8A:RemoveField('V8A_CODSUP')
            oStruV8A:RemoveField('V8A_INDAPU')
            oStruV8A:RemoveField('V8A_TPDEDU')

            oStruV8B := FWFormStruct(2, "V8B") 
            oStruV8C := FWFormStruct(2, "V8C")
            oStruV8C:RemoveField('V8C_CNPJOP')

            oStruV8D := FWFormStruct(2, "V8D") 

            oStruV8E := FWFormStruct(2, "V8E")

            oStruV8F := FWFormStruct(2, "V8F")
            oStruV8F:SetProperty("V8F_SEQUEN",MVC_VIEW_CANCHANGE,.F.)
            oStruV8F:RemoveField('V8F_TPINSC')
            oStruV8F:RemoveField('V8F_NRINSC')

            oStruV8G := FWFormStruct(2, "V8G")
            oStruV8G:RemoveField('V8G_CPFDEP')

            oView:CreateHorizontalBox("PAINEL_INFOIRCOMPLEM",025,,,"FOLDER_SUPERIOR","ABA02")
            oView:CreateFolder( 'FOLDER_INFOIRCOMPLEM', 'PAINEL_INFOIRCOMPLEM' )

            oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA01', STR0042) //"Info. dependentes não cadastrados"
            oView:AddGrid( "VIEW_V7S", oStruV7S, "MODEL_V7S" )
            oView:EnableTitleView("VIEW_V7S", STR0043)  //"Informações de dependentes não cadastrados pelo S-2200/S-2205/S-2300/S-2400/S-2405"
            oView:CreateHorizontalBox( 'V7S', 050,,, 'FOLDER_INFOIRCOMPLEM', 'ABA01' )
            oView:SetOwnerView( "VIEW_V7S", "V7S"  )

            oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA02', STR0044) //"Info. Irrf - Código de Receita"
            oView:AddGrid( "VIEW_V7T", oStruV7T, "MODEL_V7T" )
            oView:EnableTitleView("VIEW_V7T", STR0045)  //"Informações IRRF, por Código de Receita - CR"
            oView:CreateHorizontalBox( 'V7T',050,,, 'FOLDER_INFOIRCOMPLEM', 'ABA02' )
            oView:SetOwnerView( "VIEW_V7T", "V7T"  )

            oView:CreateHorizontalBox("PAINEL_INFOIRCR",025,,,"FOLDER_INFOIRCOMPLEM","ABA02")
            oView:CreateFolder( 'FOLDER_INFOIRCR', 'PAINEL_INFOIRCR' )

            oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA01', STR0046 ) //"Dedução de IRRF"		
            oView:CreateHorizontalBox( 'V7U', 025,,, 'FOLDER_INFOIRCR', 'ABA01' )
            oView:AddGrid( "VIEW_V7U", oStruV7U, "MODEL_V7U" )
            oView:EnableTitleView("VIEW_V7U",STR0047 ) //"Dedução do rendimento tributável relativa a dependentes"
            oView:SetOwnerView( "VIEW_V7U", "V7U"  )

            oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA02', STR0048) //"Info. Pensão Alimentícia"	
            oView:CreateHorizontalBox( 'V7V', 025,,, 'FOLDER_INFOIRCR', 'ABA02' )
            oView:AddGrid( "VIEW_V7V", oStruV7V, "MODEL_V7V" )
            oView:EnableTitleView("VIEW_V7V",STR0049 ) // "Informação dos beneficiários da pensão alimentícia"
            oView:SetOwnerView( "VIEW_V7V", "V7V"  )

            oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA03', STR0050 ) //"Info. Previdência Complementar"	
            oView:CreateHorizontalBox( 'V7W', 025,,, 'FOLDER_INFOIRCR', 'ABA03' )
            oView:AddGrid( "VIEW_V7W", oStruV7W, "MODEL_V7W" )
            oView:EnableTitleView("VIEW_V7W", STR0051 ) //"Informações relativas a planos de previdência complementar."
            oView:SetOwnerView( "VIEW_V7W", "V7W"  )

            oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA04', STR0052 ) //"Info. Proc Judiciais."	
            oView:CreateHorizontalBox( 'V7X', 025,,, 'FOLDER_INFOIRCR', 'ABA04' )
            oView:AddGrid( "VIEW_V7X", oStruV7X, "MODEL_V7X" )
            oView:EnableTitleView("VIEW_V7X",STR0053 ) //"Informações de processos relacionados a não retenção de tributos ou a depósitos judiciais."
            oView:SetOwnerView( "VIEW_V7X", "V7X"  )

            oView:CreateHorizontalBox("PAINEL_INFOPROCRET",025,,,"FOLDER_INFOIRCR","ABA04")
            oView:CreateFolder( 'FOLDER_INFOPROCRET', 'PAINEL_INFOPROCRET' )

            oView:AddSheet( 'FOLDER_INFOPROCRET', 'ABA01', STR0054) //"Info. Valores Proc Judiciais."	
            oView:CreateHorizontalBox( 'V7Y', 025,,, 'FOLDER_INFOPROCRET', 'ABA01' )
            oView:AddGrid( "VIEW_V7Y", oStruV7Y, "MODEL_V7Y" )
            oView:EnableTitleView("VIEW_V7Y", STR0055 ) //"Informações de valores relacionados a não retenção de tributos ou a depósitos judiciais." 
            oView:SetOwnerView( "VIEW_V7Y", "V7Y"  )

            oView:CreateHorizontalBox("PAINEL_DEDSUSP",050,,,"FOLDER_INFOPROCRET","ABA01")
            oView:CreateFolder( 'FOLDER_DEDSUSP', 'PAINEL_DEDSUSP' )

            oView:AddSheet( 'FOLDER_DEDSUSP', 'ABA01', STR0056 ) //"Deduções Exigibilidade Suspensa"
            oView:CreateHorizontalBox( 'V7Z', 025,,, 'FOLDER_DEDSUSP', 'ABA01' )
            oView:AddGrid( "VIEW_V7Z", oStruV7Z, "MODEL_V7Z" )
            oView:AddIncrementField( "VIEW_V7Z", "V7Z_SEQUEN" )
            oView:EnableTitleView("VIEW_V7Z", STR0057 ) //"Detalhamento das deduções com exigibilidade suspensa."
            oView:SetOwnerView( "VIEW_V7Z", "V7Z"  )
            

            oView:CreateHorizontalBox("PAINEL_BENEFPEN",050,,,"FOLDER_DEDSUSP","ABA01")
            oView:CreateFolder( 'FOLDER_BENEFPEN', 'PAINEL_BENEFPEN' )

            oView:AddSheet( 'FOLDER_BENEFPEN', 'ABA01', STR0058 ) //"Deduções Dependentes/Pensão"	
            oView:CreateHorizontalBox( 'V8A', 025,,, 'FOLDER_BENEFPEN', 'ABA01' )
            oView:AddGrid( "VIEW_V8A", oStruV8A, "MODEL_V8A" )
            oView:EnableTitleView("VIEW_V8A",STR0059 ) //"Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia." 
            oView:SetOwnerView( "VIEW_V8A", "V8A"  )

            oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA03', STR0060 ) //"Plano de saúde coletivo."
            oView:AddGrid( "VIEW_V8B", oStruV8B, "MODEL_V8B" )
            oView:EnableTitleView("VIEW_V8B", STR0061)  //"Identificação da(s) operadora(s) de plano privado coletivo empresarial de assistência à saúde."
            oView:CreateHorizontalBox( 'V8B', 025,,, 'FOLDER_INFOIRCOMPLEM', 'ABA03' )
            oView:SetOwnerView( "VIEW_V8B", "V8B"  )

            oView:CreateHorizontalBox("PAINEL_INFODEPSAU",025,,,"FOLDER_INFOIRCOMPLEM","ABA03")
            oView:CreateFolder( 'FOLDER_INFODEPSAU', 'PAINEL_INFODEPSAU' )    

            oView:AddSheet( 'FOLDER_INFODEPSAU', 'ABA01', STR0062 ) //"Info. Dependente Plano de Saúde."			
            oView:CreateHorizontalBox( 'V8C', 025,,, 'FOLDER_INFODEPSAU', 'ABA01' )
            oView:AddGrid( "VIEW_V8C", oStruV8C, "MODEL_V8C" )
            oView:EnableTitleView("VIEW_V8C", STR0063) //"Informações de dependente de plano de saúde coletivo empresarial."
            oView:SetOwnerView( "VIEW_V8C", "V8C"  )    

            oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA04', STR0064 ) //"Info. Reembolso"
            oView:CreateHorizontalBox( 'V8D', 025,,, 'FOLDER_INFOIRCOMPLEM', 'ABA04' )
            oView:AddGrid( "VIEW_V8D", oStruV8D, "MODEL_V8D" )
            oView:AddIncrementField( "VIEW_V8D", "V8D_SEQUEN" )
            oView:EnableTitleView("VIEW_V8D", STR0065 ) // "Informações Reembolso efetuados pelo empregador."
            oView:SetOwnerView( "VIEW_V8D", "V8D"  )

            oView:CreateHorizontalBox("PAINEL_DETREEMB",050,,,"FOLDER_INFOIRCOMPLEM","ABA04")
            oView:CreateFolder( 'FOLDER_DETREEMB', 'PAINEL_DETREEMB' )

            oView:AddSheet( 'FOLDER_DETREEMB', 'ABA01', STR0066 ) //Info. Reembolso Titular.			
            oView:CreateHorizontalBox( 'V8E', 025,,, 'FOLDER_DETREEMB', 'ABA01' )
            oView:AddGrid( "VIEW_V8E", oStruV8E, "MODEL_V8E" )
            oView:EnableTitleView("VIEW_V8E", STR0067) //"Informação de reembolso do titular do plano de saúde coletivo empresarial."
            oView:SetOwnerView( "VIEW_V8E", "V8E"  )

            oView:AddSheet( 'FOLDER_DETREEMB', 'ABA02', STR0068 ) //"Info. Reembolso Dependente."			
            oView:CreateHorizontalBox( 'V8F', 025,,, 'FOLDER_DETREEMB', 'ABA02' )
            oView:AddGrid( "VIEW_V8F", oStruV8F, "MODEL_V8F" )
            oView:EnableTitleView("VIEW_V8F", STR0069) //"Informação de reembolso do dependente do plano de saúde coletivo empresarial.
            oView:SetOwnerView( "VIEW_V8F", "V8F"  )

            oView:CreateHorizontalBox("PAINEL_DETDEP",050,,,"FOLDER_DETREEMB","ABA02")
            oView:CreateFolder( 'FOLDER_DETDEP', 'PAINEL_DETDEP' )

            oView:AddSheet( 'FOLDER_DETDEP', 'ABA02', STR0070 ) //"Info. Reembolso pelo empregador para Dependente."			
            oView:CreateHorizontalBox( 'V8G', 025,,, 'FOLDER_DETDEP', 'ABA02' )
            oView:AddGrid( "VIEW_V8G", oStruV8G, "MODEL_V8G" )
            oView:EnableTitleView("VIEW_V8G", STR0069 ) // Informação de reembolso do dependente do plano de saúde coletivo empresarial."
            oView:SetOwnerView( "VIEW_V8G", "V8G"  )

        ElseIf lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC")

            oStruT8E := FWFormStruct(2, "T8E") 

            cCmpFil  := "T8E_SEQIRC|T8E_PERREF|T8E_NRREC|

            If TYPE("INCLUI") == "U" .AND. TYPE("ALTERA") == "U"
                INCLUI := .F. 
                ALTERA := .F. 
            EndIf
            
            If INCLUI .OR. ALTERA  
                cCmpFil  += "T8E_DTLAUD|"
            Else
                If !Empty(T3P->T3P_DTLAUD) .AND. Empty(T8E->T8E_DTLAUD)
                    cCmpFil  := "T8E_SEQIRC|T8E_PERREF|T8E_NRREC|"
                Else
                    cCmpFil  += "T8E_DTLAUD|"
                EndIf
            EndIf
           
           If lNewView
                TAFview01(@oStruT8E, @oStruV7S, @oStruV7T, @oStruV7U, @oStruV7V, @oStruV7W, @oStruV7X, @oStruV7Y, @oStruV7Z, @oStruV8A,;
                            @oStruV8B, @oStruV8C, @oStruV8D, @oStruV8E, @oStruV8F, @oStruV8G, @oView, cCmpFil )
            Else
                TAFview02(@oStruT8E, @oStruV7S, @oStruV7T, @oStruV7U, @oStruV7V, @oStruV7W, @oStruV7X, @oStruV7Y, @oStruV7Z,;
                          @oStruV8A, @oStruV8B, @oStruV8C, @oStruV8D, @oStruV8E, @oStruV8F, @oStruV8G, @oView, cCmpFil )
            EndIf

        EndIf 

    EndIf

    oStruT3Pa:RemoveField('T3P_ID')

    //Tratamento para que alguns campos de controle interno não sejam exibidos na tela
    lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

    If !lMenuDif
        xFunRmFStr(@oStruT3Pa,"T3P")
    EndIf
    
    If nView == 0
        oView:SetViewCanActivate({|| .F. } )
    EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel as Object)

    Local aGrava     as Array
    Local aGravaLE2  as Array
    Local aGravaLE3  as Array
    Local aGravaLE4  as Array
    Local aGravaT3Q  as Array
    Local aGravaT3R  as Array
    Local aGravaT5U  as Array
    Local aGravaT5V  as Array
    Local aGravaT5X  as Array
    Local aGravaT5Y  as Array
    Local aGravaT5Z  as Array
    Local aGravaT6P  as Array
    Local aGravaT6Q  as Array
    Local aGravaT6R  as Array
    Local aGravaV6M  as Array
    Local aGravaV9I  as Array
    Local aGravaV9J  as Array
    Local aGravaV7S  as Array
    Local aGravaV7T  as Array
    Local aGravaV7U  as Array
    Local aGravaV7V  as Array
    Local aGravaV7W  as Array
    Local aGravaV7X  as Array
    Local aGravaV7Y  as Array
    Local aGravaV7Z  as Array
    Local aGravaV8A  as Array
    Local aGravaV8B  as Array
    Local aGravaV8C  as Array
    Local aGravaV8D  as Array
    Local aGravaV8E  as Array
    Local aGravaV8F  as Array
    Local aGravaV8G  as Array
    Local aGravaT8E  as Array
    Local cBenefi    as Character
    Local cChvRegAnt as Character
    Local cEvento    as Character
    Local cLayEve    as Character
    Local cLogOpe    as Character
    Local cLogOpeAnt as Character
    Local cProtocolo as Character
    Local cVerAnt    as Character
    Local cVersao    as Character
    Local lRetorno   as Logical
    Local lLayout12  as Logical
    Local nI         as Numeric
    Local nLE2       as Numeric
    Local nLE2Add    as Numeric
    Local nLE3       as Numeric
    Local nLE3Add    as Numeric
    Local nLE4       as Numeric
    Local nLE4Add    as Numeric
    Local nOperation as Numeric
    Local nT3Q       as Numeric
    Local nT3R       as Numeric
    Local nT3RAdd    as Numeric
    Local nT5U       as Numeric
    Local nT5UAdd    as Numeric
    Local nT5V       as Numeric
    Local nT5VAdd    as Numeric
    Local nT5X       as Numeric
    Local nT5XAdd    as Numeric
    Local nT5Y       as Numeric
    Local nT5YAdd    as Numeric
    Local nT5Z       as Numeric
    Local nT5ZAdd    as Numeric
    Local nT6P       as Numeric
    Local nT6PAdd    as Numeric
    Local nT6Q       as Numeric
    Local nT6QAdd    as Numeric
    Local nT6R       as Numeric
    Local nT6RAdd    as Numeric
    Local nV6M       as Numeric
    Local nV6MAdd    as Numeric
    Local nV9I       as Numeric
    Local nV9J       as Numeric
    Local nV7S       as Numeric
    Local nV7SAdd    as Numeric
    Local nV7T       as Numeric
    Local nV7TAdd    as Numeric
    Local nV7U       as Numeric
    Local nV7UAdd    as Numeric
    Local nV7V       as Numeric
    Local nV7VAdd    as Numeric
    Local nV7W       as Numeric
    Local nV7WAdd    as Numeric
    Local nV7X       as Numeric
    Local nV7XAdd    as Numeric
    Local nV7Y       as Numeric
    Local nV7YAdd    as Numeric
    Local nV7Z       as Numeric
    Local nV7ZAdd    as Numeric
    Local nV8A       as Numeric
    Local nV8AAdd    as Numeric
    Local nV8B       as Numeric
    Local nV8BAdd    as Numeric
    Local nV8C       as Numeric
    Local nV8CAdd    as Numeric
    Local nV8D       as Numeric
    Local nV8DAdd    as Numeric
    Local nV8E       as Numeric
    Local nV8EAdd    as Numeric
    Local nV8F       as Numeric
    Local nV8FAdd    as Numeric
    Local nV8G       as Numeric
    Local nV8GAdd    as Numeric
    Local oModelLE2  as Object
    Local oModelLE3  as Object
    Local oModelLE4  as Object
    Local oModelT3P  as Object
    Local oModelT3Q  as Object
    Local oModelT3R  as Object
    Local oModelT5U  as Object
    Local oModelT5V  as Object
    Local oModelT5X  as Object
    Local oModelT5Y  as Object
    Local oModelT5Z  as Object
    Local oModelT6P  as Object
    Local oModelT6Q  as Object
    Local oModelV6M  as Object
    Local oModelV9I  as Object
    Local oModelV9J  as Object
    Local oModelV7S  as Object
    Local oModelV7T  as Object
    Local oModelV7U  as Object
    Local oModelV7V  as Object
    Local oModelV7X  as Object
    Local oModelV7W  as Object
    Local oModelV7Y  as Object
    Local oModelV7Z  as Object
    Local oModelV8A  as Object
    Local oModelV8B  as Object
    Local oModelV8C  as Object
    Local oModelV8D  as Object
    Local oModelV8E  as Object
    Local oModelV8F  as Object
    Local oModelV8G  as Object
    

    Default oModel   := Nil 

    aGrava     := {}
    aGravaLE2  := {}
    aGravaLE3  := {}
    aGravaLE4  := {}
    aGravaT3Q  := {}
    aGravaT3R  := {}
    aGravaT5U  := {}
    aGravaT5V  := {}
    aGravaT5X  := {}
    aGravaT5Y  := {}
    aGravaT5Z  := {}
    aGravaT6P  := {}
    aGravaT6Q  := {}
    aGravaT6R  := {}
    aGravaV6M  := {}
    aGravaV9I  := {}
    aGravaV9J  := {}
    aGravaV7S  := {}
    aGravaV7T  := {}
    aGravaV7U  := {}
    aGravaV7V  := {}
    aGravaV7W  := {}
    aGravaV7X  := {}
    aGravaV7Y  := {}
    aGravaV7Z  := {}
    aGravaV8A  := {}
    aGravaV8B  := {}
    aGravaV8C  := {}
    aGravaV8D  := {}
    aGravaV8E  := {}
    aGravaV8F  := {}
    aGravaV8G  := {}
    aGravaT8E  := {} 
    cBenefi    := ""
    cChvRegAnt := ""
    cEvento    := ""
    cLayEve    := Iif( FindFunction('getVerLayout'), getVerLayout(), SuperGetMV("MV_TAFVLES"))
    cLogOpe    := ""
    cLogOpeAnt := ""
    cProtocolo := ""
    cVerAnt    := ""
    cVersao    := ""
    lRetorno   := .T.
    lLayout12  := lSimpl12 
    nI         := 0
    nLE2       := 0
    nLE2Add    := 0
    nLE3       := 0
    nLE3Add    := 0
    nLE4       := 0
    nLE4Add    := 0
    nOperation := 0
    nT3Q       := 0
    nT3R       := 0
    nT3RAdd    := 0
    nT5U       := 0
    nT5UAdd    := 0
    nT5V       := 0
    nT5VAdd    := 0
    nT5X       := 0
    nT5XAdd    := 0
    nT5Y       := 0
    nT5YAdd    := 0
    nT5Z       := 0
    nT5ZAdd    := 0
    nT6P       := 0
    nT6PAdd    := 0
    nT6Q       := 0
    nT6QAdd    := 0
    nT6R       := 0
    nT6RAdd    := 0
    nV6M       := 0
    nV6MAdd    := 0
    nV9I       := 0
    nV9J       := 0
    nV7S       := 0
    nV7SAdd    := 0
    nV7T       := 0
    nV7TAdd    := 0
    nV7U       := 0
    nV7UAdd    := 0
    nV7V       := 0
    nV7VAdd    := 0
    nV7W       := 0
    nV7WAdd    := 0
    nV7X       := 0
    nV7XAdd    := 0
    nV7Y       := 0
    nV7YAdd    := 0
    nV7Z       := 0
    nV7ZAdd    := 0
    nV8A       := 0
    nV8AAdd    := 0
    nV8B       := 0
    nV8BAdd    := 0
    nV8C       := 0
    nV8CAdd    := 0
    nV8D       := 0
    nV8DAdd    := 0
    nV8E       := 0
    nV8EAdd    := 0
    nV8F       := 0
    nV8FAdd    := 0
    nV8G       := 0
    nV8GAdd    := 0
    oModelLE2  := Nil
    oModelLE3  := Nil
    oModelLE4  := Nil
    oModelT3P  := Nil
    oModelT3Q  := Nil
    oModelT3R  := Nil
    oModelT5U  := Nil
    oModelT5V  := Nil
    oModelT5X  := Nil
    oModelT5Y  := Nil
    oModelT5Z  := Nil
    oModelT6P  := Nil
    oModelT6Q  := Nil
    oModelV6M  := Nil
    oModelV9I  := Nil
    oModelV9J  := Nil
    oModelV7S  := Nil
    oModelV7T  := Nil
    oModelV7U  := Nil
    oModelV7V  := Nil
    oModelV7X  := Nil
    oModelV7W  := Nil
    oModelV7Y  := Nil
    oModelV7Z  := Nil
    oModelV8A  := Nil
    oModelV8B  := Nil
    oModelV8C  := Nil
    oModelV8D  := Nil
    oModelV8E  := Nil
    oModelV8F  := Nil
    oModelV8G  := Nil
        
    If oModel != Nil

        nOperation := oModel:GetOperation()
        
        Begin Transaction

            //Inclusao Manual do Evento
            If nOperation == MODEL_OPERATION_INSERT

                TafAjustID( "T3P", oModel)
                oModel:LoadValue( "MODEL_T3P", "T3P_VERSAO", xFunGetVer() )
				oModel:LoadValue( "MODEL_T3P", "T3P_LAYOUT", cLayEve )
                
                TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '2', '' )
                
                FwFormCommit( oModel )

            //Alteração Manual do Evento
            ElseIf nOperation == MODEL_OPERATION_UPDATE

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³Seek para posicionar no registro antes de realizar as validacoes,³
                //³visto que quando nao esta pocisionado nao eh possivel analisar   ³
                //³os campos nao usados como _STATUS                                ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                //Posicionando no registro para que nao ocorra erros durante o processo de validação
                T3P->( DbSetOrder( 4 ) ) //T3P_FILIAL+T3P_ID+T3P_ATIVO
                If T3P->( MsSeek( xFilial( 'T3P' ) + T3P->T3P_ID + '1' ) )

                    If T3P->T3P_STATUS $ ( "4" )

                        oModelT3P  := oModel:GetModel( "MODEL_T3P" )
                        oModelV6M  := oModel:GetModel( "MODEL_V6M" )

                        //Guardo as informações do registro corrente para rastro do registro
                        cVerAnt     := oModelT3P:GetValue( "T3P_VERSAO" )
                        cProtocolo 	:= oModelT3P:GetValue( "T3P_PROTUL" )
                        cEvento	 	:= oModelT3P:GetValue( "T3P_EVENTO" )
                        cLogOpeAnt  := oModelT3P:GetValue( "T3P_LOGOPE" )
				        
                        oModel:LoadValue( "MODEL_T3P", "T3P_LAYOUT", cLayEve )
			            

                        /*---------------------------------------------
                            T3P - Pgto Rendimentos do Trabalho
                        -----------------------------------------------*/
                        For nI := 1 To Len( oModelT3P:aDataModel[ 1 ] )
                            Aadd( aGrava, { oModelT3P:aDataModel[ 1, nI, 1 ], oModelT3P:aDataModel[ 1, nI, 2 ] } )
                        Next nI

                        If !lLaySimplif
                        
                            DBSelectArea("T3Q")
                            DBSetOrder(1)

                            If T3Q->(MsSeek(xFilial("T3Q")+T3P->(T3P_ID + T3P_VERSAO) ) )

                                oModelT3Q  := oModel:GetModel( "MODEL_T3Q" )
                                oModelT3R  := oModel:GetModel( "MODEL_T3R" )
                                oModelLE2  := oModel:GetModel( "MODEL_LE2" )
                                oModelLE3  := oModel:GetModel( "MODEL_LE3" )
                                oModelLE4  := oModel:GetModel( "MODEL_LE4" )
                                oModelT6P  := oModel:GetModel( "MODEL_T6P" )
                                oModelT6Q  := oModel:GetModel( "MODEL_T6Q" )
                                oModelT6R  := oModel:GetModel( "MODEL_T6R" )
                                oModelT5U  := oModel:GetModel( "MODEL_T5U" )
                                oModelT5Y  := oModel:GetModel( "MODEL_T5Y" )
                                oModelT5Z  := oModel:GetModel( "MODEL_T5Z" )
                                oModelT5V  := oModel:GetModel( "MODEL_T5V" )
                                oModelT5X  := oModel:GetModel( "MODEL_T5X" )
                                
                                /*---------------------------------------------
                                T3Q - Informações dos Pagamentos Efetuados
                                ----------------------------------------------*/
                                For nT3Q := 1 To oModel:GetModel( "MODEL_T3Q" ):Length()

                                    oModel:GetModel( "MODEL_T3Q" ):GoLine(nT3Q)

                                    If !oModel:GetModel( "MODEL_T3Q" ):IsDeleted()

                                        aAdd(aGravaT3Q,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_INDRES"),;
                                                        oModelT3Q:GetValue("T3Q_IDPAIS"),;
                                                        oModelT3Q:GetValue("T3Q_INDNIF"),;
                                                        oModelT3Q:GetValue("T3Q_NIFBEN"),;
                                                        oModelT3Q:GetValue("T3Q_DLOUGR"),;
                                                        oModelT3Q:GetValue("T3Q_NUMLOG"),;
                                                        oModelT3Q:GetValue("T3Q_COMPLE"),;
                                                        oModelT3Q:GetValue("T3Q_BAIRRO"),;
                                                        oModelT3Q:GetValue("T3Q_CIDADE"),;
                                                        oModelT3Q:GetValue("T3Q_CEP")})

                                        /*---------------------------------------------
                                            T3R - Detalh. Pgto Folha e Rescisão
                                        ----------------------------------------------*/
                                        For nT3R := 1 to oModel:GetModel( "MODEL_T3R" ):Length()

                                            oModel:GetModel( "MODEL_T3R" ):GoLine(nT3R)

                                            If !oModel:GetModel( "MODEL_T3R" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T3R" ):IsDeleted()

                                                    aAdd (aGravaT3R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                                    oModelT3R:GetValue('T3R_VLRLIQ')})

                                                    /*------------------------------------------
                                                    LE2 - Retenções Pagamento do Vlr Tot
                                                    --------------------------------------------*/
                                                    For nLE2 := 1 To oModel:GetModel( "MODEL_LE2" ):Length()
                                                        
                                                        oModel:GetModel( "MODEL_LE2" ):GoLine(nLE2)

                                                        If !oModel:GetModel( "MODEL_LE2" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_LE2" ):IsDeleted()

                                                                aAdd (aGravaLE2 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                                oModelLE2:GetValue('LE2_QTDRUB'),;
                                                                                oModelLE2:GetValue('LE2_FATRUB'),;
                                                                                oModelLE2:GetValue('LE2_VLRRUB'),;
                                                                                oModelLE2:GetValue('LE2_VLRUNI'),;
                                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                                oModelLE2:GetValue('LE2_IDTABR');
                                                                                })

                                                                /*------------------------------------------
                                                                            LE3 - Pensão Alimentícia
                                                                --------------------------------------------*/
                                                                For nLE3 := 1 to oModel:GetModel( "MODEL_LE3" ):Length()

                                                                oModel:GetModel( "MODEL_LE3" ):GoLine(nLE3)

                                                                    If !oModel:GetModel( "MODEL_LE3" ):IsEmpty()

                                                                        If !oModel:GetModel( "MODEL_LE3" ):IsDeleted()

                                                                            aAdd (aGravaLE3 ,{	oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                                                oModelLE3:GetValue('LE3_CPFBEN'),;
                                                                                                oModelLE3:GetValue('LE3_DTNSBE'),;
                                                                                                oModelLE3:GetValue('LE3_NMBEN'),;
                                                                                                oModelLE3:GetValue('LE3_VLRPEN'),;
                                                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                                            })
                                                                        EndIF
                                                                    EndIF
                                                                Next//LE3

                                                            EndIf
                                                        EndIF
                                                    Next//LE2

                                                    /*------------------------------------------
                                                        LE4 - Inf Comp Relac ao Pgto Efetuad
                                                    --------------------------------------------*/
                                                    For nLE4 := 1 to oModel:GetModel( "MODEL_LE4" ):Length()

                                                        oModel:GetModel( "MODEL_LE4" ):GoLine(nLE4)

                                                        If !oModel:GetModel( "MODEL_LE4" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_LE4" ):IsDeleted()

                                                                aAdd (aGravaLE4 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                    oModelLE4:GetValue('LE4_IDRUBR'),;
                                                                                    oModelLE4:GetValue('LE4_QTDRUB'),;
                                                                                    oModelLE4:GetValue('LE4_FATRUB'),;
                                                                                    oModelLE4:GetValue('LE4_VLRRUB'),;
                                                                                    oModelLE4:GetValue('LE4_VLRUNI'),;
                                                                                    oModelLE4:GetValue('LE4_MATRIC')})
                                                            EndIf
                                                        EndIF
                                                    Next//LE4

                                                EndIf
                                            EndIF
                                        Next//nT3R

                                        /*------------------------------------------
                                        T6P - Detalh. Pgto Folha e Rescisão
                                        --------------------------------------------*/
                                        For nT6P := 1 to oModel:GetModel( "MODEL_T6P" ):Length()

                                            oModel:GetModel( "MODEL_T6P" ):GoLine(nT6P)

                                            If !oModel:GetModel( "MODEL_T6P" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T6P" ):IsDeleted()

                                                    aAdd (aGravaT6P ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                                    oModelT6P:GetValue('T6P_VLRLIQ')})

                                                    /*------------------------------------------
                                                        T6Q - Retenções Pagamento do Vlr Tot
                                                    --------------------------------------------*/
                                                    For nT6Q := 1 to oModel:GetModel( "MODEL_T6Q" ):Length()

                                                        oModel:GetModel( "MODEL_T6Q" ):GoLine(nT6Q)

                                                        If !oModel:GetModel( "MODEL_T6Q" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T6Q" ):IsDeleted()

                                                                aAdd (aGravaT6Q ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                                oModelT6Q:GetValue('T6Q_IDRUBR'),;
                                                                                oModelT6Q:GetValue('T6Q_QTDRUB'),;
                                                                                oModelT6Q:GetValue('T6Q_FATRUB'),;
                                                                                oModelT6Q:GetValue('T6Q_VLRRUB'),;
                                                                                oModelT6Q:GetValue('T6Q_VLRUNI')})

                                                            EndIf
                                                        EndIF
                                                    Next//T6Q

                                                    /*------------------------------------------
                                                        T6R - Inf Comp Relac ao Pgto Efetuad
                                                    --------------------------------------------*/
                                                    For nT6R := 1 To oModel:GetModel( "MODEL_T6R" ):Length()

                                                        oModel:GetModel( "MODEL_T6R" ):GoLine(nT6R)

                                                        If !oModel:GetModel( "MODEL_T6R" ):IsEmpty()
                                                        
                                                            If !oModel:GetModel( "MODEL_T6R" ):IsDeleted()

                                                                aAdd (aGravaT6R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                                oModelT6R:GetValue('T6R_IDRUBR'),;
                                                                                oModelT6R:GetValue('T6R_QTDRUB'),;
                                                                                oModelT6R:GetValue('T6R_FATRUB'),;
                                                                                oModelT6R:GetValue('T6R_VLRRUB'),;
                                                                                oModelT6R:GetValue('T6R_VLRUNI')})
                                                            EndIf
                                                        EndIF
                                                    Next//T6R

                                                EndIf
                                            EndIF
                                        Next//nT6P

                                        /*------------------------------------------
                                        T5U - Detalhamento Rub Recibo Férias
                                        --------------------------------------------*/
                                        For nT5U := 1 to oModel:GetModel( "MODEL_T5U" ):Length()

                                            oModel:GetModel( "MODEL_T5U" ):GoLine(nT5U)

                                            If !oModel:GetModel( "MODEL_T5U" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5U" ):IsDeleted()

                                                    aAdd (aGravaT5U ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                    oModelT5U:GetValue('T5U_QTDIAS'),;
                                                                    oModelT5U:GetValue('T5U_VLRLIQ')})

                                                    /*------------------------------------------
                                                        T5Y - Det Rub Rebibo Ant de Ferias
                                                    --------------------------------------------*/
                                                    For nT5Y := 1 to oModel:GetModel( "MODEL_T5Y" ):Length()

                                                        oModel:GetModel( "MODEL_T5Y" ):GoLine(nT5Y)

                                                        If !oModel:GetModel( "MODEL_T5Y" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T5Y" ):IsDeleted()

                                                                If TAFColumnPos( "T5Y_QTDIAS" )

                                                                    aAdd (aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                    oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRUNI'),;
                                                                                    oModelT5Y:GetValue('T5Y_QTDIAS')})

                                                                Else

                                                                    aAdd (aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                    oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                                    oModelT5Y:GetValue('T5Y_VLRUNI')})

                                                                EndIf

                                                                /*------------------------------------------
                                                                            T5Z - Beneficiários de Pensão Alimen
                                                                --------------------------------------------*/
                                                                For nT5Z := 1 to oModel:GetModel( "MODEL_T5Z" ):Length()

                                                                    oModel:GetModel( "MODEL_T5Z" ):GoLine(nT5Z)

                                                                    If !oModel:GetModel( "MODEL_T5Z" ):IsEmpty()

                                                                        If !oModel:GetModel( "MODEL_T5Z" ):IsDeleted()

                                                                            If TAFColumnPos( "T5Z_QTDIAS" )

                                                                                aAdd (aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                                    oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                                                    oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                                                    oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                                                    oModelT5Z:GetValue('T5Z_VLRPEN'),;
                                                                                                    oModelT5Z:GetValue('T5Z_QTDIAS')})

                                                                            Else

                                                                                aAdd (aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                                oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                                oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                                oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                                oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                                                oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                                                oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                                                oModelT5Z:GetValue('T5Z_VLRPEN')})

                                                                            EndIf
                                                                        EndIf
                                                                    EndIf
                                                                Next//T5Z

                                                            EndIf
                                                        EndIf
                                                    Next//T5Y

                                                EndIf
                                            EndIF
                                        Next//T5U

                                        /*------------------------------------------
                                        T5V - Pgto Relat Compet Anteriores
                                        --------------------------------------------*/
                                        For nT5V := 1 to oModel:GetModel( "MODEL_T5V" ):Length()

                                            oModel:GetModel( "MODEL_T5V" ):GoLine(nT5V)

                                            If !oModel:GetModel( "MODEL_T5V" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5V" ):IsDeleted()

                                                    aAdd (aGravaT5V ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5V:GetValue('T5V_IDCATE')})

                                                    /*------------------------------------------
                                                        T5X - Detalhamento do pagamento
                                                    --------------------------------------------*/
                                                    For nT5X := 1 to oModel:GetModel( "MODEL_T5X" ):Length()

                                                        oModel:GetModel( "MODEL_T5X" ):GoLine(nT5X)

                                                        If !oModel:GetModel( "MODEL_T5X" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T5X" ):IsDeleted()

                                                                aAdd (aGravaT5X ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                oModelT5V:GetValue('T5V_IDCATE'),;
                                                                                oModelT5X:GetValue('T5X_SEQUEN'),;
                                                                                oModelT5X:GetValue('T5X_IDTPIR'),;
                                                                                oModelT5X:GetValue('T5X_VLRBCI')})


                                                            EndIf
                                                        EndIf
                                                    Next//T5X

                                                EndIf
                                            EndIf
                                        Next//nT5V

                                    EndIf
                                Next //nT3Q

                            EndIf

                        Else
                            V6M->(DBSetOrder(1))
                            
                            If V6M->(MsSeek(xFilial("V6M") + T3P->(T3P_ID + T3P_VERSAO)))
                                
                                oModelV6M := oModel:GetModel("MODEL_V6M")
                                oModelV9I := oModel:GetModel("MODEL_V9I")
                                oModelV9J := oModel:GetModel("MODEL_V9J")

                                For nV6M := 1 To oModel:GetModel("MODEL_V6M"):Length()
                                    oModel:GetModel("MODEL_V6M"):GoLine(nV6M)

                                    If !oModel:GetModel("MODEL_V6M"):IsEmpty()
                                        If !oModel:GetModel("MODEL_V6M"):IsDeleted()
                                            If !lSimplBeta
                                                AAdd(aGravaV6M, {   oModelV6M:GetValue("V6M_DTPGTO"),;
                                                                    oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                    oModelV6M:GetValue("V6M_PERREF"),;
                                                                    oModelV6M:GetValue("V6M_INDDEV"),;
                                                                    oModelV6M:GetValue("V6M_VLRLIQ")})
                                            Else             
                                                AAdd(aGravaV6M, {   oModelV6M:GetValue("V6M_DTPGTO"),;
                                                                    oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                    oModelV6M:GetValue("V6M_PERREF"),;
                                                                    oModelV6M:GetValue("V6M_INDDEV"),;
                                                                    oModelV6M:GetValue("V6M_VLRLIQ"),;
                                                                    oModelV6M:GetValue("V6M_PAIEXT")}) 
                                            EndIf                        
                                                                                 

                                            If lSimplBeta 
                                                
                                                For nV9I := 1 To oModel:GetModel("MODEL_V9I"):Length()
                                                    oModel:GetModel("MODEL_V9I"):GoLine(nV9I)

                                                    If !oModel:GetModel("MODEL_V9I"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V9I"):IsDeleted()
                                                            AAdd(aGravaV9I, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                                oModelV6M:GetValue("V6M_PERREF"),;
                                                                                oModelV6M:GetValue("V6M_INDDEV"),;
                                                                                oModelV9I:GetValue("V9I_INDNIF"),;
                                                                                oModelV9I:GetValue("V9I_NIFBEN"),;
                                                                                oModelV9I:GetValue("V9I_FRMTRI")    })
                                                        
                                                            For nV9J := 1 To oModel:GetModel("MODEL_V9J"):Length()
                                                                oModel:GetModel("MODEL_V9J"):GoLine(nV9J)

                                                                If !oModel:GetModel("MODEL_V9J"):IsEmpty()
                                                                    If !oModel:GetModel("MODEL_V9J"):IsDeleted()
                                                                        AAdd(aGravaV9J, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                                            oModelV6M:GetValue("V6M_PERREF"),;
                                                                                            oModelV6M:GetValue("V6M_INDDEV"),;  
                                                                                            oModelV9J:GetValue("V9J_DSCLOG"),;
                                                                                            oModelV9J:GetValue("V9J_NRLOGR"),;
                                                                                            oModelV9J:GetValue("V9J_COMPLE"),;
                                                                                            oModelV9J:GetValue("V9J_BAIRRO"),;
                                                                                            oModelV9J:GetValue("V9J_CIDADE"),;
                                                                                            oModelV9J:GetValue("V9J_ESTADO"),;
                                                                                            oModelV9J:GetValue("V9J_CODPOS"),;
                                                                                            oModelV9J:GetValue("V9J_TELEF" )   })
                                                                    EndIf
                                                                EndIf
                                                            Next
                                                        EndIf
                                                    EndIf
                                                Next
                                            EndIf
                                        EndIf
                                    EndIf
                                Next
                            EndIf

                            If lLayout12 .AND. !(lSimpl0103 .AND. TAFColumnPos("V8F_SEQIRC"))
                                
                                V7S->(DBSetOrder(1))
                                If V7S->(MsSeek(xFilial("V7S") + T3P->(T3P_ID + T3P_VERSAO)))
                                    oModelV7S := oModel:GetModel("MODEL_V7S")

                                    For nV7S := 1 To oModel:GetModel("MODEL_V7S"):Length()
                                        oModel:GetModel("MODEL_V7S"):GoLine(nV7S)

                                        If !oModel:GetModel("MODEL_V7S"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V7S"):IsDeleted()
                                                AAdd(aGravaV7S, {   oModelV7S:GetValue("V7S_CPFDEP"),;
                                                                    oModelV7S:GetValue("V7S_DTNASC"),;
                                                                    oModelV7S:GetValue("V7S_NMDEP" ),;
                                                                    oModelV7S:GetValue("V7S_DPIRRF"),;
                                                                    oModelV7S:GetValue("V7S_TPDEP" ),;
                                                                    oModelV7S:GetValue("V7S_DSCDEP") })

                                            EndIf 
                                        EndIf 

                                    Next
                                    
                                EndIf 

                                V7T->(DBSetOrder(1))
                                If V7T->(MsSeek(xFilial("V7T") + T3P->(T3P_ID + T3P_VERSAO)))
                                    oModelV7T := oModel:GetModel("MODEL_V7T")
                                    oModelV7U := oModel:GetModel("MODEL_V7U")
                                    oModelV7V := oModel:GetModel("MODEL_V7V")
                                    oModelV7W := oModel:GetModel("MODEL_V7W")
                                    oModelV7X := oModel:GetModel("MODEL_V7X")
                                    oModelV7Y := oModel:GetModel("MODEL_V7Y")
                                    oModelV7Z := oModel:GetModel("MODEL_V7Z")
                                    oModelV8A := oModel:GetModel("MODEL_V8A")

                                    For nV7T := 1 To oModel:GetModel("MODEL_V7T"):Length()
                                        oModel:GetModel("MODEL_V7T"):GoLine(nV7T)

                                        If !oModel:GetModel("MODEL_V7T"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V7T"):IsDeleted()
                                                AAdd(aGravaV7T, {   oModelV7T:GetValue("V7T_TPCR") })

                                                For nV7U := 1 To oModel:GetModel("MODEL_V7U"):Length()
                                                    oModel:GetModel("MODEL_V7U"):GoLine(nV7U)

                                                    If !oModel:GetModel("MODEL_V7U"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V7U"):IsDeleted()
                                                            AAdd(aGravaV7U, {   oModelV7T:GetValue("V7T_TPCR"  ),;
                                                                                oModelV7U:GetValue("V7U_TPREND"),;
                                                                                oModelV7U:GetValue("V7U_CPFDEP"),;
                                                                                oModelV7U:GetValue("V7U_VLRDED") })
                                                        EndIf 
                                                    EndIf 
                                                Next

                                                For nV7V := 1 To oModel:GetModel("MODEL_V7V"):Length()
                                                    oModel:GetModel("MODEL_V7V"):GoLine(nV7V)

                                                    If !oModel:GetModel("MODEL_V7V"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V7V"):IsDeleted()
                                                            AAdd(aGravaV7V, {   oModelV7T:GetValue("V7T_TPCR"  ),;
                                                                                oModelV7V:GetValue("V7V_TPREND"),;
                                                                                oModelV7V:GetValue("V7V_CPFDEP"),;
                                                                                oModelV7V:GetValue("V7V_VLPEN" ) })
                                                        EndIf
                                                    EndIf 
                                                Next 

                                                For nV7W := 1 To oModel:GetModel("MODEL_V7W"):Length()
                                                    oModel:GetModel("MODEL_V7W"):GoLine(nV7W)

                                                    If !oModel:GetModel("MODEL_V7W"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V7W"):IsDeleted()
                                                            AAdd(aGravaV7W, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                oModelV7W:GetValue("V7W_TPREV"  ),;
                                                                                oModelV7W:GetValue("V7W_INSCPL" ),;
                                                                                oModelV7W:GetValue("V7W_VLCOMP" ),;
                                                                                oModelV7W:GetValue("V7W_VLPATR" )})
                                                        EndIf
                                                    EndIf 
                                                Next

                                                For nV7X := 1 To oModel:GetModel("MODEL_V7X"):Length()
                                                    oModel:GetModel("MODEL_V7X"):GoLine(nV7X)

                                                    If !oModel:GetModel("MODEL_V7X"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V7X"):IsDeleted()
                                                            AAdd(aGravaV7X, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                oModelV7X:GetValue("V7X_CODSUP" )})

                                                            For nV7Y := 1 To oModel:GetModel("MODEL_V7Y"):Length()
                                                                oModel:GetModel("MODEL_V7Y"):GoLine(nV7Y)
                                                                If !oModel:GetModel("MODEL_V7Y"):IsEmpty()
                                                                    If !oModel:GetModel("MODEL_V7Y"):IsDeleted()
                                                                        AAdd(aGravaV7Y, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                            oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                            oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                            oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                            oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                            oModelV7Y:GetValue("V7Y_VLRRET" ),;
                                                                                            oModelV7Y:GetValue("V7Y_VLRJUD" ),;
                                                                                            oModelV7Y:GetValue("V7Y_VLACAL" ),;
                                                                                            oModelV7Y:GetValue("V7Y_VLAANT" ),;
                                                                                            oModelV7Y:GetValue("V7Y_VLSUSP" )})

                                                                        For nV7Z := 1 To oModel:GetModel("MODEL_V7Z"):Length()
                                                                            oModel:GetModel("MODEL_V7Z"):GoLine(nV7Z)
                                                                            If !oModel:GetModel("MODEL_V7Z"):IsEmpty()
                                                                                If !oModel:GetModel("MODEL_V7Z"):IsDeleted()
                                                                                    AAdd(aGravaV7Z, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                                        oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                                        oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                                        oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                                        oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                                        oModelV7Z:GetValue("V7Z_TPDEDU" ),;
                                                                                                        oModelV7Z:GetValue("V7Z_VLSUSP" ),;
                                                                                                        oModelV7Z:GetValue("V7Z_INSCPL" ),;
                                                                                                        oModelV7Z:GetValue("V7Z_VLFUNP" ),;
                                                                                                        oModelV7Z:GetValue("V7Z_SEQUEN" )})

                                                                                    For nV8A := 1 To oModel:Getmodel("MODEL_V8A"):Length()
                                                                                        oModel:GetModel("MODEL_V8A"):GoLine(nV8A)
                                                                                        If !oModel:GetModel("MODEL_V8A"):IsEmpty()
                                                                                            If !oModel:GetModel("MODEL_V8A"):IsDeleted()
                                                                                                AAdd(aGravaV8A, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                                                    oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                                                    oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                                                    oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                                                    oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                                                    oModelV8A:GetValue("V8A_CPFDEP" ),;
                                                                                                                    oModelV8A:GetValue("V8A_VLSUSP" ),;
                                                                                                                    oModelV7Z:GetValue("V7Z_SEQUEN" )})
                                                                                            EndIf
                                                                                        EndIf
                                                                                    Next
                                                                                EndIf
                                                                            EndIf
                                                                        Next 
                                                                    EndIf
                                                                EndIf
                                                            Next
                                                        EndIf
                                                    EndIf
                                                Next
                                            EndIf 
                                        EndIf
                                    Next 
                                EndIf 

                                V8B->(DBSetOrder(1))
                                If V8B->(MsSeek(xFilial("V8B") + T3P->(T3P_ID + T3P_VERSAO)))
                                    oModelV8B := oModel:GetModel("MODEL_V8B")
                                    oModelV8C := oModel:GetModel("MODEL_V8C")

                                    For nV8B := 1 To oModel:Getmodel("MODEL_V8B"):Length()
                                        oModel:GetModel("MODEL_V8B"):GoLine(nV8B)

                                        If !oModel:GetModel("MODEL_V8B"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V8B"):IsDeleted()
                                                AAdd(aGravaV8B, {   oModelV8B:GetValue("V8B_CNPJOP" ),;
                                                                    oModelV8B:GetValue("V8B_REGANS" ),;
                                                                    oModelV8B:GetValue("V8B_VLRTIT" ) })

                                                For nV8C := 1 To oModel:Getmodel("MODEL_V8C"):Length()
                                                    oModel:GetModel("MODEL_V8C"):GoLine(nV8C)

                                                    If !oModel:GetModel("MODEL_V8C"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V8C"):IsDeleted()
                                                            AAdd(aGravaV8C, {   oModelV8B:GetValue("V8B_CNPJOP" ),;
                                                                                oModelV8C:GetValue("V8C_CPFDEP" ),;
                                                                                oModelV8C:GetValue("V8C_VLRDEP" ) })
                                                        EndIf 
                                                    EndIf 
                                                Next 
                                            EndIf
                                        EndIf 
                                    Next

                                EndIf

                                V8D->(DBSetOrder(1))
                                If V8D->(MsSeek(xFilial("V8D") + T3P->(T3P_ID + T3P_VERSAO)))
                                    oModelV8D := oModel:GetModel("MODEL_V8D")
                                    oModelV8E := oModel:GetModel("MODEL_V8E")
                                    oModelV8F := oModel:GetModel("MODEL_V8F")
                                    oModelV8G := oModel:GetModel("MODEL_V8G")

                                    For nV8D := 1 To oModel:Getmodel("MODEL_V8D"):Length()
                                        oModel:GetModel("MODEL_V8D"):GoLine(nV8D)

                                        If !oModel:GetModel("MODEL_V8D"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V8D"):IsDeleted()
                                                AAdd(aGravaV8D, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                                    oModelV8D:GetValue("V8D_INDREM" ),;
                                                                    oModelV8D:GetValue("V8D_CNPJOP" ),;
                                                                    oModelV8D:GetValue("V8D_REGANS" )})

                                                For nV8F := 1 To oModel:Getmodel("MODEL_V8F"):Length()
                                                    oModel:GetModel("MODEL_V8F"):GoLine(nV8F)

                                                    If !oModel:GetModel("MODEL_V8F"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V8F"):IsDeleted()
                                                            AAdd(aGravaV8F, {   oModelV8F:GetValue("V8F_SEQUEN" ),;
                                                                                oModelV8F:GetValue("V8F_CPFDEP" )   })
                                                                                    

                                                            For nV8G := 1 To oModel:Getmodel("MODEL_V8G"):Length()
                                                                oModel:GetModel("MODEL_V8G"):GoLine(nV8G)

                                                                If !oModel:GetModel("MODEL_V8G"):IsEmpty()
                                                                    If !oModel:GetModel("MODEL_V8G"):IsDeleted()
                                                                        AAdd(aGravaV8G, {   oModelV8G:GetValue("V8G_SEQUEN" ),;
                                                                                            oModelV8G:GetValue("V8G_CPFDEP" ),;
                                                                                            oModelV8G:GetValue("V8G_TPINSC" ),;
                                                                                            oModelV8G:GetValue("V8G_NRINSC" ),;
                                                                                            oModelV8G:GetValue("V8G_VLREMB" ),;
                                                                                            oModelV8G:GetValue("V8G_VLRANT" )   })
                                                                                        
                                                                    EndIf 
                                                                EndIf
                                                            Next
                                                        EndIf 
                                                    EndIf 
                                                Next

                                                For nV8E := 1 To oModel:Getmodel("MODEL_V8E"):Length()
                                                    oModel:GetModel("MODEL_V8E"):GoLine(nV8E)

                                                    If !oModel:GetModel("MODEL_V8E"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V8E"):IsDeleted()
                                                            AAdd(aGravaV8E, {   oModelV8E:GetValue("V8E_SEQUEN" ),;
                                                                                oModelV8E:GetValue("V8E_TPINSC" ),;
                                                                                oModelV8E:GetValue("V8E_NRINSC" ),;
                                                                                oModelV8E:GetValue("V8E_VLREMB" ),;
                                                                                oModelV8E:GetValue("V8E_VLRANT" )})
                                                            
                                                        EndIf 
                                                    EndIf
                                                Next
                                            EndIf 
                                        EndIf
                                    Next 
                                EndIf

                            ElseIf lSimpl0103  

                                T8E->(DBSetOrder(1))
                                If T8E->(MsSeek(xFilial("T8E") + T3P->(T3P_ID + T3P_VERSAO)))

                                    oModelV7S := oModel:GetModel("MODEL_V7S")
                                    oModelV7T := oModel:GetModel("MODEL_V7T")
                                    oModelV7U := oModel:GetModel("MODEL_V7U")
                                    oModelV7V := oModel:GetModel("MODEL_V7V")
                                    oModelV7W := oModel:GetModel("MODEL_V7W")
                                    oModelV7X := oModel:GetModel("MODEL_V7X")
                                    oModelV7Y := oModel:GetModel("MODEL_V7Y")
                                    oModelV7Z := oModel:GetModel("MODEL_V7Z")
                                    oModelV8A := oModel:GetModel("MODEL_V8A")
                                    oModelT8E := oModel:GetModel("MODEL_T8E")

                                    GetAgrava( oModel, oModelV7S, oModelV7T, oModelV7U, oModelV7V, oModelV7W, oModelV7X, oModelV7Y, oModelV7Z, oModelV8A, oModelV8B,;
                                               oModelV8C, oModelV8D, oModelV8E, oModelV8F, oModelV8G, oModelT8E, @aGravaT8E, @aGravaV7T, @aGravaV7U, @aGravaV7V,;
                                               @aGravaV7W, @aGravaV7X, @aGravaV7Y, @aGravaV7Z, @aGravaV8A, @aGravaV8B, @aGravaV8C, @aGravaV8D, @aGravaV8F, @aGravaV8G, @aGravaV8E, @aGravaV7S  )
                                EndIf
                            EndIf
                        EndIf
                        
                        /*----------------------------------------------------------
                        Seto o campo como Inativo e gravo a versao do novo registro
                        no registro anterior

                        ATENCAO -> A alteracao destes campos deve sempre estar
                        abaixo do Loop do For, pois devem substituir as informacoes
                        que foram armazenadas no Loop acima
                        -----------------------------------------------------------*/
                        FAltRegAnt( "T3P", "2" )

                        /*----------------------------------------------------------
                        Apos deixar o registro corrente como inativo eu seto a
                        operação de inclusão para o novo registro
                        -----------------------------------------------------------*/
                        oModel:DeActivate()
                        oModel:SetOperation( 3 )
                        oModel:Activate()

                        /*----------------------------------------------------------
                        Neste momento eu realizo a gravação de um novo registro idêntico
                        ao original, apenas com as alterações nos campos modificados
                        pelo usuário no cadastro
                        -----------------------------------------------------------*/

                        /*------------------------------------------
                            T3P - Pgto Rendimentos do Trabalho
                        --------------------------------------------*/
                        For nI := 1 to Len( aGrava )
                            oModel:LoadValue( "MODEL_T3P", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
                        Next nI

                        //Necessário Abaixo do For Nao Retirar
                        
                        TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '' , cLogOpeAnt )

                        If !lLaySimplif

                            /*------------------------------------------
                            T3Q - Informações dos Pagamentos Efetuados
                            --------------------------------------------*/
                            For nT3Q := 1 to Len( aGravaT3Q )

                                oModel:GetModel( 'MODEL_T3Q' ):LVALID	:= .T.

                                If nT3Q > 1
                                    oModel:GetModel( "MODEL_T3Q" ):AddLine()
                                EndIf
                                
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO",  aGravaT3Q[nT3Q][1] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO",  aGravaT3Q[nT3Q][2] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES",  aGravaT3Q[nT3Q][3] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS",  aGravaT3Q[nT3Q][4] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF",  aGravaT3Q[nT3Q][5] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN",  aGravaT3Q[nT3Q][6] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR",  aGravaT3Q[nT3Q][7] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG",  aGravaT3Q[nT3Q][8] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE",  aGravaT3Q[nT3Q][9] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO",  aGravaT3Q[nT3Q][10] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE",  aGravaT3Q[nT3Q][11] )
                                oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   ,  aGravaT3Q[nT3Q][12] )
                            
                                /*------------------------------------------
                                    T3R - Detalh. Pgto Folha e Rescisão
                                --------------------------------------------*/
                                nT3RAdd := 1
                                For nT3R := 1 to Len( aGravaT3R )

                                    If  DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T3R" ):LVALID := .T.

                                        If nT3RAdd > 1
                                            oModel:GetModel( "MODEL_T3R" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T3R", "T3R_PERREF", aGravaT3R[nT3R][3] )
                                        oModel:LoadValue( "MODEL_T3R", "T3R_IDEDMD", aGravaT3R[nT3R][4] )
                                        oModel:LoadValue( "MODEL_T3R", "T3R_INDPGT", aGravaT3R[nT3R][5] )
                                        oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", aGravaT3R[nT3R][6] )

                                        /*------------------------------------------
                                            LE2 - Retenções Pagamento do Vlr Tot
                                        --------------------------------------------*/
                                        nLE2Add := 1
                                        For nLE2 := 1 to Len( aGravaLE2 )

                                            If  DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5] == ;
                                                DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                                oModel:GetModel( "MODEL_LE2" ):LVALID := .T.

                                                If nLE2Add > 1
                                                    oModel:GetModel( "MODEL_LE2" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDRUBR", aGravaLE2[nLE2][6] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_QTDRUB", aGravaLE2[nLE2][7] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_FATRUB", aGravaLE2[nLE2][8] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRRUB", aGravaLE2[nLE2][9] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRUNI", aGravaLE2[nLE2][10] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_SEQUEN", aGravaLE2[nLE2][11] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_RUBRIC", aGravaLE2[nLE2][12] )
                                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDTABR", aGravaLE2[nLE2][13] )

                                                /*------------------------------------------
                                                    LE3 - Pensão Alimentícia
                                                --------------------------------------------*/
                                                nLE3Add := 1
                                                For nLE3 := 1 to Len( aGravaLE3 )

                                                    If  DTOS(aGravaLE3[nLE3][1])+aGravaLE3[nLE3][2]+aGravaLE3[nLE3][3]+aGravaLE3[nLE3][4]+aGravaLE3[nLE3][5]+aGravaLE3[nLE3][6]+aGravaLE3[nLE3][11]+aGravaLE3[nLE3][12];
                                                    == DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5]+aGravaLE2[nLE2][6]+aGravaLE2[nLE2][11]+aGravaLE2[nLE2][12]
                                                        
                                                        oModel:GetModel( "MODEL_LE3" ):LVALID := .T.

                                                        If nLE3Add > 1
                                                            oModel:GetModel( "MODEL_LE3" ):AddLine()
                                                        EndIf

                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_CPFBEN", aGravaLE3[nLE3][7] )
                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_DTNSBE", aGravaLE3[nLE3][8] )
                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_NMBEN",  aGravaLE3[nLE3][9] )
                                                        oModel:LoadValue( "MODEL_LE3" , "LE3_VLRPEN", aGravaLE3[nLE3][10] )
                                                        nLE3Add++

                                                    EndIf
                                                Next//nLE3

                                                nLE2Add++
                                            EndIf
                                        Next//LE2

                                        /*------------------------------------------
                                            LE4 - Inf Comp Relac ao Pgto Efetuad
                                        --------------------------------------------*/
                                        nLE4Add := 1
                                        For nLE4 := 1 to Len( aGravaLE4 )

                                            If  DTOS(aGravaLE4[nLE4][1])+aGravaLE4[nLE4][2]+aGravaLE4[nLE4][3]+aGravaLE4[nLE4][4]+aGravaLE4[nLE4][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                                oModel:GetModel( "MODEL_LE4" ):LVALID := .T.

                                                If nLE4Add > 1
                                                    oModel:GetModel( "MODEL_LE4" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_LE4" , "LE4_IDRUBR", aGravaLE4[nLE4][6] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_QTDRUB", aGravaLE4[nLE4][7] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_FATRUB", aGravaLE4[nLE4][8] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRUNI", aGravaLE4[nLE4][9] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRRUB", aGravaLE4[nLE4][10] )
                                                oModel:LoadValue( "MODEL_LE4" , "LE4_MATRIC", aGravaLE4[nLE4][11] )

                                                nLE4Add++
                                            EndIf
                                        Next//nLE4

                                        nT3RAdd++
                                    EndIf
                                Next //nT3R

                                /*------------------------------------------
                                    T6P - Detalh. Pgto Folha e Rescisão
                                --------------------------------------------*/
                                nT6PAdd := 1
                                For nT6P := 1 to Len( aGravaT6P )

                                    If  DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T6P" ):LVALID := .T.

                                        If nT6PAdd > 1
                                            oModel:GetModel( "MODEL_T6P" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T6P", "T6P_PERREF", aGravaT6P[nT6P][3] )
                                        oModel:LoadValue( "MODEL_T6P", "T6P_IDEDMD", aGravaT6P[nT6P][4] )
                                        oModel:LoadValue( "MODEL_T6P", "T6P_INDPGT", aGravaT6P[nT6P][5] )
                                        oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", aGravaT6P[nT6P][6] )

                                        /*------------------------------------------
                                            T6Q - Retenções Pagamento do Vlr Tot
                                        --------------------------------------------*/
                                        nT6QAdd := 1
                                        For nT6Q := 1 to Len( aGravaT6Q )

                                            If  DTOS(aGravaT6Q[nT6Q][1])+aGravaT6Q[nT6Q][2]+aGravaT6Q[nT6Q][3]+aGravaT6Q[nT6Q][4]+aGravaT6Q[nT6Q][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                                oModel:GetModel( "MODEL_T6Q" ):LVALID := .T.

                                                If nT6QAdd > 1
                                                    oModel:GetModel( "MODEL_T6Q" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDRUBR", aGravaT6Q[nT6Q][6]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_QTDRUB", aGravaT6Q[nT6Q][7]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_FATRUB", aGravaT6Q[nT6Q][8]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRRUB", aGravaT6Q[nT6Q][9]  )
                                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRUNI", aGravaT6Q[nT6Q][10] )

                                                nT6QAdd++
                                            EndIf

                                        Next//T6Q

                                        /*------------------------------------------
                                            T6R - Inf Comp Relac ao Pgto Efetuad
                                        --------------------------------------------*/
                                        nT6RAdd := 1
                                        For nT6R := 1 to Len( aGravaT6R )
                                        
                                            If  DTOS(aGravaT6R[nT6R][1])+aGravaT6R[nT6R][2]+aGravaT6R[nT6R][3]+aGravaT6R[nT6R][4]+aGravaT6R[nT6R][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                                oModel:GetModel( "MODEL_T6R" ):LVALID := .T.

                                                If nT6RAdd > 1
                                                    oModel:GetModel( "MODEL_T6R" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T6R" , "T6R_IDRUBR", aGravaT6R[nT6R][6] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_QTDRUB", aGravaT6R[nT6R][7] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_FATRUB", aGravaT6R[nT6R][8] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRUNI", aGravaT6R[nT6R][9] )
                                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRRUB", aGravaT6R[nT6R][10] )

                                                nT6RAdd++
                                            EndIf

                                        Next//nT6R

                                        nT6PAdd++
                                    EndIf

                                Next //nT6P

                                /*------------------------------------------
                                    T5U - Detalhamento Rub Recibo Férias
                                --------------------------------------------*/
                                nT5UAdd := 1
                                For nT5U := 1 to Len( aGravaT5U )

                                    If  DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T5U" ):LVALID := .T.

                                        If nT5UAdd > 1
                                            oModel:GetModel( "MODEL_T5U" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", aGravaT5U[nT5U][3] )
                                        oModel:LoadValue( "MODEL_T5U", "T5U_DTINIG", aGravaT5U[nT5U][4] )
                                        oModel:LoadValue( "MODEL_T5U", "T5U_QTDIAS", aGravaT5U[nT5U][5] )
                                        oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", aGravaT5U[nT5U][6] )

                                        /*------------------------------------------
                                            T5Y - Det Rub Rebibo Ant de Ferias
                                        --------------------------------------------*/
                                        nT5YAdd := 1
                                        For nT5Y := 1 to Len( aGravaT5Y )

                                            If  DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+STR(aGravaT5Y[nT5Y][10])== DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2]+aGravaT5U[nT5U][3]+DTOS(aGravaT5U[nT5U][4])+STR(aGravaT5U[nT5U][5])

                                                oModel:GetModel( "MODEL_T5Y" ):LVALID := .T.

                                                If nT5YAdd > 1
                                                    oModel:GetModel( "MODEL_T5Y" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDRUBR", aGravaT5Y[nT5Y][5] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_QTDRUB", aGravaT5Y[nT5Y][6] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_FATRUB", aGravaT5Y[nT5Y][7] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRRUB", aGravaT5Y[nT5Y][8] )
                                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRUNI", aGravaT5Y[nT5Y][9] )

                                                /*------------------------------------------
                                                    T5Z - Beneficiários de Pensão Alimen
                                                --------------------------------------------*/
                                                nT5ZAdd := 1
                                                For nT5Z := 1 to Len( aGravaT5Z )

                                                    If  DTOS(aGravaT5Z[nT5Z][1])+aGravaT5Z[nT5Z][2]+aGravaT5Z[nT5Z][3]+DTOS(aGravaT5Z[nT5Z][4])+aGravaT5Z[nT5Z][5]+STR(aGravaT5Z[nT5Z][10]) == DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+aGravaT5Y[nT5Y][5]+STR(aGravaT5Y[nT5Y][10])

                                                        oModel:GetModel( "MODEL_T5Z" ):LVALID := .T.

                                                        If nT5ZAdd > 1
                                                            oModel:GetModel( "MODEL_T5Z" ):AddLine()
                                                        EndIf

                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_CPFBEN", aGravaT5Z[nT5Z][6] )
                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_DTNSBE", aGravaT5Z[nT5Z][7] )
                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_NMBEN",  aGravaT5Z[nT5Z][8] )
                                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_VLRPEN", aGravaT5Z[nT5Z][9] )
                                                        nT5ZAdd++
                                                    EndIf

                                                Next//T5Z

                                                nT5YAdd++

                                            EndIf

                                        Next//T5Y

                                        nT5UAdd++

                                    EndIf

                                Next //T5U

                                /*------------------------------------------
                                    T5V - Pgto Relat Compet Anteriores
                                --------------------------------------------*/
                                nT5VAdd := 1
                                For nT5V := 1 to Len( aGravaT5V )

                                    If  DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                                        oModel:GetModel( "MODEL_T5V" ):LVALID := .T.

                                        If nT5VAdd > 1
                                            oModel:GetModel( "MODEL_T5V" ):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", aGravaT5V[nT5V][3] )

                                        /*------------------------------------------
                                            T5X - Detalhamento do pagamento
                                        --------------------------------------------*/
                                        nT5XAdd := 1
                                        For nT5X := 1 to Len( aGravaT5X )

                                            If  DTOS(aGravaT5X[nT5X][1])+aGravaT5X[nT5X][2]+aGravaT5X[nT5X][3] == DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2]+aGravaT5V[nT5V][3]

                                                oModel:GetModel( "MODEL_T5X" ):LVALID := .T.

                                                If nT5XAdd > 1
                                                    oModel:GetModel( "MODEL_T5X" ):AddLine()
                                                EndIf

                                                oModel:LoadValue( "MODEL_T5X" , "T5X_SEQUEN", aGravaT5X[nT5X][4] )
                                                oModel:LoadValue( "MODEL_T5X" , "T5X_IDTPIR", aGravaT5X[nT5X][5] )
                                                oModel:LoadValue( "MODEL_T5X" , "T5X_VLRBCI", aGravaT5X[nT5X][6] )

                                                nT5XAdd++

                                            EndIf

                                        Next//T5X

                                        nT5VAdd++

                                    EndIf

                                Next //nT5V

                            Next //nT3Q

                        Else
                            nV6MAdd := 1

                            For nV6M := 1 To Len(aGravaV6M)
                                oModel:GetModel("MODEL_V6M"):lValid := .T.

                                If nV6MAdd > 1
                                    oModel:GetModel("MODEL_V6M"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", aGravaV6M[nV6M][1])
                                oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", aGravaV6M[nV6M][2])
                                oModel:LoadValue("MODEL_V6M", "V6M_PERREF", aGravaV6M[nV6M][3])
                                oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", aGravaV6M[nV6M][4])
                                oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", aGravaV6M[nV6M][5])

                                If lSimplBeta 
                                    oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", aGravaV6M[nV6M][6])

                                    For nV9I := 1 To Len(aGravaV9I)
                                        If aGravaV9I[nV9I][1] + aGravaV9I[nV9I][2] + aGravaV9I[nV9I][3] == aGravaV6M[nV6M][2] +;
                                            aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                                            oModel:GetModel("MODEL_V9I"):lValid := .T.

                                            oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", aGravaV9I[nV9I][4])
                                            oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", aGravaV9I[nV9I][5])
                                            oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", aGravaV9I[nV9I][6])
                                            
                                            For nV9J := 1 To Len(aGravaV9J)
                                                If aGravaV9J[nV9J][1] + aGravaV9J[nV9J][2] + aGravaV9J[nV9J][3] == aGravaV6M[nV6M][2] +;
                                                    aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]
                                                    oModel:GetModel("MODEL_V9J"):lValid := .T.
                                                    
                                                    oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", aGravaV9J[nV9J][4])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", aGravaV9J[nV9J][5])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", aGravaV9J[nV9J][6])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", aGravaV9J[nV9J][7])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", aGravaV9J[nV9J][8])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", aGravaV9J[nV9J][9])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", aGravaV9J[nV9J][10])
                                                    oModel:LoadValue("MODEL_V9J", "V9J_TELEF" , aGravaV9J[nV9J][11])
                                                EndIf
                                            Next
                                        EndIf
                                    Next
                                EndIf

                                nV6MAdd++
                            Next

                            If lLayout12 .AND. !( lSimpl0103 .AND. TAFColumnPos("V8F_SEQIRC"))
                                nV7SAdd := 1

                                For nV7S := 1 To Len(aGravaV7S)
                                    oModel:GetModel("MODEL_V7S"):lValid := .T.

                                    If nV7SAdd > 1
                                        oModel:GetModel("MODEL_V7S"):AddLine()
                                    EndIf

                                    oModel:LoadValue("MODEL_V7S", "V7S_CPFDEP"  , aGravaV7S[nV7S][1])
                                    oModel:LoadValue("MODEL_V7S", "V7S_DTNASC"  , aGravaV7S[nV7S][2])
                                    oModel:LoadValue("MODEL_V7S", "V7S_NMDEP"   , aGravaV7S[nV7S][3])
                                    oModel:LoadValue("MODEL_V7S", "V7S_DPIRRF"  , aGravaV7S[nV7S][4])
                                    oModel:LoadValue("MODEL_V7S", "V7S_TPDEP"   , aGravaV7S[nV7S][5])
                                    oModel:LoadValue("MODEL_V7S", "V7S_DSCDEP"  , aGravaV7S[nV7S][6])

                                    nV7SAdd++
                                Next 

                                nV7TAdd := 1

                                For nV7T := 1 To Len(aGravaV7T)
                                    oModel:GetModel("MODEL_V7T"):lValid := .T.

                                    If nV7TAdd > 1
                                        oModel:GetModel("MODEL_V7T"):AddLine()
                                    EndIf

                                    oModel:LoadValue("MODEL_V7T", "V7T_TPCR"  , aGravaV7T[nV7T][1])

                                    nV7UAdd := 1

                                    For nV7U := 1 To Len(aGravaV7U)
                                        If aGravaV7T[nV7T][1] == aGravaV7U[nV7U][1]

                                            oModel:GetModel("MODEL_V7U"):lValid := .T.

                                            If nV7UAdd > 1
                                                oModel:GetModel("MODEL_V7U"):AddLine()
                                            EndIf

                                            oModel:LoadValue("MODEL_V7U", "V7U_TPCR"    , aGravaV7U[nV7U][1])
                                            oModel:LoadValue("MODEL_V7U", "V7U_TPREND"  , aGravaV7U[nV7U][2])
                                            oModel:LoadValue("MODEL_V7U", "V7U_CPFDEP"  , aGravaV7U[nV7U][3])
                                            oModel:LoadValue("MODEL_V7U", "V7U_VLRDED"  , aGravaV7U[nV7U][4])

                                            nV7UAdd++
                                        EndIf 
                                    Next

                                    nV7VAdd := 1

                                    For nV7V := 1 To Len(aGravaV7V)
                                        If aGravaV7T[nV7T][1] == aGravaV7V[nV7V][1]

                                            oModel:GetModel("MODEL_V7V"):lValid := .T.

                                            If nV7VAdd > 1
                                                oModel:GetModel("MODEL_V7V"):AddLine()
                                            EndIf

                                            oModel:LoadValue("MODEL_V7V", "V7V_TPCR"    , aGravaV7V[nV7V][1])
                                            oModel:LoadValue("MODEL_V7V", "V7V_TPREND"  , aGravaV7V[nV7V][2])
                                            oModel:LoadValue("MODEL_V7V", "V7V_CPFDEP"  , aGravaV7V[nV7V][3])
                                            oModel:LoadValue("MODEL_V7V", "V7V_VLPEN"   , aGravaV7V[nV7V][4])

                                            nV7VAdd++
                                        EndIf 
                                    Next

                                    nV7WAdd := 1

                                    For nV7W := 1 To Len(aGravaV7W)
                                        If aGravaV7T[nV7T][1] == aGravaV7W[nV7W][1]

                                            oModel:GetModel("MODEL_V7W"):lValid := .T.

                                            If nV7WAdd > 1
                                                oModel:GetModel("MODEL_V7W"):AddLine()
                                            EndIf

                                            oModel:LoadValue("MODEL_V7W", "V7W_TPCR"    , aGravaV7W[nV7W][1])
                                            oModel:LoadValue("MODEL_V7W", "V7W_TPREV"   , aGravaV7W[nV7W][2])
                                            oModel:LoadValue("MODEL_V7W", "V7W_INSCPL"  , aGravaV7W[nV7W][3])
                                            oModel:LoadValue("MODEL_V7W", "V7W_VLCOMP"  , aGravaV7W[nV7W][4])
                                            oModel:LoadValue("MODEL_V7W", "V7W_VLPATR"  , aGravaV7W[nV7W][5])

                                            nV7WAdd++
                                        EndIf 
                                    Next

                                    nV7XAdd := 1

                                    For nV7X := 1 To Len(aGravaV7X)
                                        If aGravaV7T[nV7T][1] == aGravaV7X[nV7X][1]

                                            oModel:GetModel("MODEL_V7X"):lValid := .T.

                                            If nV7XAdd > 1
                                                oModel:GetModel("MODEL_V7X"):AddLine()
                                            EndIf

                                            oModel:LoadValue("MODEL_V7X", "V7X_TPCR"    , aGravaV7X[nV7X][1])
                                            oModel:LoadValue("MODEL_V7X", "V7X_TPPROC"  , aGravaV7X[nV7X][2])
                                            oModel:LoadValue("MODEL_V7X", "V7X_NRPROC"  , aGravaV7X[nV7X][3])
                                            oModel:LoadValue("MODEL_V7X", "V7X_CODSUP"  , aGravaV7X[nV7X][4])


                                            nV7YAdd := 1

                                            For nV7Y := 1 To Len(aGravaV7Y)
                                                If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4] == aGravaV7Y[nV7Y][1]+aGravaV7Y[nV7Y][2]+aGravaV7Y[nV7Y][3]+aGravaV7Y[nV7Y][4] 

                                                    oModel:GetModel("MODEL_V7Y"):lValid := .T.

                                                    If nV7YAdd > 1
                                                        oModel:GetModel("MODEL_V7Y"):AddLine()
                                                    EndIf

                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_TPCR"    , aGravaV7Y[nV7Y][1] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_TPPROC"  , aGravaV7Y[nV7Y][2] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_NRPROC"  , aGravaV7Y[nV7Y][3] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_CODSUP"  , aGravaV7Y[nV7Y][4] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_INDAPU"  , aGravaV7Y[nV7Y][5] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLRRET"  , aGravaV7Y[nV7Y][6] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLRJUD"  , aGravaV7Y[nV7Y][7] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLACAL"  , aGravaV7Y[nV7Y][8] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLAANT"  , aGravaV7Y[nV7Y][9] )
                                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLSUSP"  , aGravaV7Y[nV7Y][10])

                                                    nV7ZAdd := 1

                                                    For nV7Z := 1 To Len(aGravaV7Z)
                                                        If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5] == aGravaV7Z[nV7Z][1]+aGravaV7Z[nV7Z][2]+aGravaV7Z[nV7Z][3]+aGravaV7Z[nV7Z][4]+aGravaV7Z[nV7Z][5]

                                                            oModel:GetModel("MODEL_V7Z"):lValid := .T.

                                                            If nV7ZAdd > 1
                                                                oModel:GetModel("MODEL_V7Z"):AddLine()
                                                            EndIf  

                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_TPCR"    , aGravaV7Z[nV7Z][1] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_TPPROC"  , aGravaV7Z[nV7Z][2] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_NRPROC"  , aGravaV7Z[nV7Z][3] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_CODSUP"  , aGravaV7Z[nV7Z][4] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_INDAPU"  , aGravaV7Z[nV7Z][5] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_TPDEDU"  , aGravaV7Z[nV7Z][6] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_VLSUSP"  , aGravaV7Z[nV7Z][7] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_INSCPL"  , aGravaV7Z[nV7Z][8] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_VLFUNP"  , aGravaV7Z[nV7Z][9] )
                                                            oModel:LoadValue("MODEL_V7Z", "V7Z_SEQUEN"  , aGravaV7Z[nV7Z][10] )

                                                            nV8AAdd := 1

                                                            For nV8A := 1 To Len(aGravaV8A)
                                                                If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5]+aGravaV7Z[nV7Z][10] == aGravaV8A[nV8A][1]+aGravaV8A[nV8A][2]+aGravaV8A[nV8A][3]+aGravaV8A[nV8A][4]+aGravaV8A[nV8A][5]+aGravaV8A[nV8A][8]
                                                                    
                                                                    oModel:GetModel("MODEL_V8A"):lValid := .T.
                                                                    
                                                                    If nV8AAdd > 1
                                                                        oModel:GetModel("MODEL_V8A"):AddLine()
                                                                    EndIf
                                                                    
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_TPCR"    , aGravaV8A[nV8A][1] )
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_TPPROC"  , aGravaV8A[nV8A][2] )
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_NRPROC"  , aGravaV8A[nV8A][3] )
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_CODSUP"  , aGravaV8A[nV8A][4] )
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_INDAPU"  , aGravaV8A[nV8A][5] )
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_CPFDEP"  , aGravaV8A[nV8A][6] )
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_VLSUSP"  , aGravaV8A[nV8A][7] )
                                                                    oModel:LoadValue("MODEL_V8A", "V8A_SEQUEN"  , aGravaV8A[nV8A][8] )

                                                                    nV8AAdd++
                                                                EndIf 
                                                            Next 
                                                            nV7ZAdd++
                                                        EndIf 
                                                    Next 
                                                    nV7YAdd++
                                                EndIf
                                            Next
                                            nV7XAdd++
                                        EndIf 
                                    Next
                                    nV7TAdd++
                                Next 

                                nV8BAdd := 1

                                For nV8B := 1 To Len(aGravaV8B)
                                    oModel:GetModel("MODEL_V8B"):lValid := .T.

                                    If nV8BAdd > 1
                                        oModel:GetModel("MODEL_V8B"):AddLine()
                                    EndIf
                                    
                                    oModel:LoadValue("MODEL_V8B", "V8B_CNPJOP"  , aGravaV8B[nV8B][1])
                                    oModel:LoadValue("MODEL_V8B", "V8B_REGANS"  , aGravaV8B[nV8B][2])
                                    oModel:LoadValue("MODEL_V8B", "V8B_VLRTIT"  , aGravaV8B[nV8B][3])

                                    nV8CAdd := 1

                                    For nV8C := 1 To Len(aGravaV8C)
                                        If aGravaV8B[nV8B][1] == aGravaV8C[nV8C][1]
                                            oModel:GetModel("MODEL_V8C"):lValid := .T.
                                            
                                            If nV8CAdd > 1
                                                oModel:GetModel("MODEL_V8C"):AddLine()
                                            EndIf

                                            oModel:LoadValue("MODEL_V8C", "V8C_CNPJOP"  , aGravaV8C[nV8C][1])
                                            oModel:LoadValue("MODEL_V8C", "V8C_CPFDEP"  , aGravaV8C[nV8C][2])
                                            oModel:LoadValue("MODEL_V8C", "V8C_VLRDEP"  , aGravaV8C[nV8C][3])

                                            nV8CAdd++
                                        EndIf
                                    Next 
                                    nV8BAdd++
                                Next 

                                nV8DAdd := 1

                                For nV8D := 1 To Len(aGravaV8D)
                                    
                                    oModel:GetModel("MODEL_V8D"):lValid := .T.

                                    If nV8DAdd > 1
                                        oModel:GetModel("MODEL_V8D"):AddLine()
                                    EndIf

                                    oModel:LoadValue("MODEL_V8D", "V8D_SEQUEN"  , aGravaV8D[nV8D][1])
                                    oModel:LoadValue("MODEL_V8D", "V8D_INDREM"  , aGravaV8D[nV8D][2])
                                    oModel:LoadValue("MODEL_V8D", "V8D_CNPJOP"  , aGravaV8D[nV8D][3])
                                    oModel:LoadValue("MODEL_V8D", "V8D_REGANS"  , aGravaV8D[nV8D][4])

                                    nV8EAdd := 1

                                    For nV8E := 1 To Len(aGravaV8E)
                                        If aGravaV8D[nV8D][1] == aGravaV8E[nV8E][1]
                                            oModel:GetModel("MODEL_V8E"):lValid := .T.

                                            If nV8EAdd > 1
                                                oModel:GetModel("MODEL_V8E"):AddLine()
                                            EndIf

                                            oModel:LoadValue("MODEL_V8E", "V8E_SEQUEN"  , aGravaV8E[nV8E][1])
                                            oModel:LoadValue("MODEL_V8E", "V8E_TPINSC"  , aGravaV8E[nV8E][2])
                                            oModel:LoadValue("MODEL_V8E", "V8E_NRINSC"  , aGravaV8E[nV8E][3])
                                            oModel:LoadValue("MODEL_V8E", "V8E_VLREMB"  , aGravaV8E[nV8E][4])
                                            oModel:LoadValue("MODEL_V8E", "V8E_VLRANT"  , aGravaV8E[nV8E][5])

                                            nV8EAdd++
                                        EndIf 
                                    Next

                                    nV8FAdd := 1
                                    For nV8F := 1 To Len(aGravaV8F)
                                        If aGravaV8D[nV8D][1] == aGravaV8F[nV8F][1]
                                            oModel:GetModel("MODEL_V8F"):lValid := .T.

                                            If nV8FAdd > 1
                                                oModel:GetModel("MODEL_V8F"):AddLine()
                                            EndIf

                                            oModel:LoadValue("MODEL_V8F", "V8F_SEQUEN"  , aGravaV8F[nV8F][1])
                                            oModel:LoadValue("MODEL_V8F", "V8F_CPFDEP"  , aGravaV8F[nV8F][2])

                                            nV8GAdd := 1
                                            For nV8G := 1 To Len(aGravaV8G)
                                                If aGravaV8F[nV8F][1] + aGravaV8F[nV8F][2] == aGravaV8G[nV8G][1] + aGravaV8G[nV8G][2]
                                                    oModel:GetModel("MODEL_V8G"):lValid := .T.

                                                    If nV8GAdd > 1
                                                        oModel:GetModel("MODEL_V8G"):AddLine()
                                                    EndIf

                                                    oModel:LoadValue("MODEL_V8G", "V8G_SEQUEN"  , aGravaV8G[nV8G][1])
                                                    oModel:LoadValue("MODEL_V8G", "V8G_CPFDEP"  , aGravaV8G[nV8G][2])
                                                    oModel:LoadValue("MODEL_V8G", "V8G_TPINSC"  , aGravaV8G[nV8G][3])
                                                    oModel:LoadValue("MODEL_V8G", "V8G_NRINSC"  , aGravaV8G[nV8G][4])
                                                    oModel:LoadValue("MODEL_V8G", "V8G_VLREMB"  , aGravaV8G[nV8G][5])
                                                    oModel:LoadValue("MODEL_V8G", "V8G_VLRANT"  , aGravaV8G[nV8G][6])
                                                
                                                    nV8GAdd++
                                                EndIf 
                                            Next

                                            nV8FAdd++
                                        EndIf
                                    Next
                                    nV8DAdd++
                                Next
                            ElseIf lSimpl0103 
                               
                               TAFRecArray(@oModel, aGravaT8E, aGravaV7T, aGravaV7U, aGravaV7V, aGravaV7W, aGravaV7X, aGravaV7Y, aGravaV7Z, aGravaV8A, aGravaV8B, aGravaV8C, aGravaV8D, aGravaV8F, aGravaV8G, aGravaV8E, aGravaV7S)
                            
                            EndIf 

                        EndIf
                        
                        //Busco a nova versao do registro
                        cVersao := xFunGetVer()

                        /*---------------------------------------------------------
                        ATENCAO -> A alteracao destes campos deve sempre estar
                        abaixo do Loop do For, pois devem substituir as informacoes
                        que foram armazenadas no Loop acima
                        -----------------------------------------------------------*/
                        oModel:LoadValue( "MODEL_T3P", "T3P_VERSAO", cVersao    )
                        oModel:LoadValue( "MODEL_T3P", "T3P_VERANT", cVerAnt    )
                        oModel:LoadValue( "MODEL_T3P", "T3P_PROTPN", cProtocolo )
                        oModel:LoadValue( "MODEL_T3P", "T3P_PROTUL", ""         )
                        oModel:LoadValue( "MODEL_T3P", "T3P_EVENTO", "A"        )

                        // Tratamento para limpar o ID unico do xml
                        cAliasPai := "T3P"

                        oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )

                        FwFormCommit( oModel )
                        TAFAltStat( 'T3P', " " )

                    ElseIf	T3P->T3P_STATUS == "2"

                        TAFMsgVldOp(oModel,"2")//"Registro não pode ser alterado. Aguardando processo da transmissão."
                        lRetorno:= .F.

                    ElseIf T3P->T3P_STATUS == "6"

                        TAFMsgVldOp(oModel,"6")//"Registro não pode ser alterado. Aguardando proc. Transm. evento de Exclusão S-3000"
                        lRetorno:= .F.

                    ElseIf T3P->T3P_STATUS == "7"

                        TAFMsgVldOp(oModel,"7") //"Registro não pode ser alterado, pois o evento já se encontra na base do RET"
                        lRetorno:= .F.

                    Else

                        //alteração sem transmissão
                        cLogOpeAnt := T3P->T3P_LOGOPE
                        
                        TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '' , cLogOpeAnt )
                    
                        FwFormCommit( oModel )
                        TAFAltStat( 'T3P', " " )

                    EndIf

                EndIf

            //Exclusão Manual do Evento
            ElseIf nOperation == MODEL_OPERATION_DELETE

                cChvRegAnt := T3P->(T3P_ID + T3P_VERANT)

                TAFAltStat( 'T3P', " " )
                FwFormCommit( oModel )

                If T3P->T3P_EVENTO == "A" .Or. T3P->T3P_EVENTO == "E"
                    TAFRastro( 'T3P', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
                EndIf

            EndIf

        End Transaction

        If lRetorno .and. FWIsInCallStack( "TAF407AUTI" )

            //Executa atualização dos registros que são elegí­veis para autônomos do S-1210 
            FwMsgRun(, { || AtuRegT3P() }, "Atualizando Registros S-1210 Autônomos...", "Aguarde") 	//"Atualizando Registros S-1210 Autônomos.."

        EndIf

    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Grv
@type			function
@description	Função de gravação para atender o registro S-1210.
@author			Vitor Siqueira
@since			29/12/2015
@version		1.0
@param			cLayout		-	Nome do Layout que está sendo enviado
@param			nOpc		-	Opção a ser realizada ( 3 = Inclusão, 4 = Alteração, 5 = Exclusão )
@param			cFilEv		-	Filial do ERP para onde as informações deverão ser importadas
@param			oXML		-	Objeto com as informações a serem manutenidas ( Outras Integrações )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, único para o XML do eSocial. Utilizado para importação de dados de clientes migrando para o TAF
@return			lRet		-	Variável que indica se a importação foi realizada, ou seja, se as informações foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsistências encontradas durante a importação
/*/
//-------------------------------------------------------------------
Function TAF407Grv(cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character,; 
            cFilTran as Character, cPredeces as Character, nTafRecno as Numeric, cComplem as Character, cGrpTran as Character,;
            cEmpOriGrp as Character, cFilOriGrp as Character, cXmlID as Character, cEvtOri as Character, lMigrador as Logical,;
            lDepGPE as Logical, cKey as Character, cMatrC9V as Character, lLaySmpTot as logical, lExclCMJ as logical,;
            oTransf as object, cXML as character)

	Local aChave     as Array
    Local aChvRetif  as Array
	Local aIncons    as Array
	Local aRulesCad  as Array
    Local cBenef     as Character
	Local cCabec     as Character
	Local cChave     as Character
    Local cChvRetif  as Character
	Local cCmpsNoUpd as Character
	Local cCodEvent  as Character
    Local cCPF       as Character
    Local cEvtNew    as Character
    Local cIdBenef   as Character
	Local cInconMsg  as Character
    Local cIndApur   as Character
	Local cIndRetif  as Character
	Local cLogOpeAnt as Character
	Local cNewOw     as Character
	LocaL cOwExi     as Character
	Local cPeriodo   as Character
	Local cPerRef    as Character
	Local cT3QPath   as Character
	Local cT3RPath   as Character
    Local cTpGuia    as Character
	Local cTpPgto    as Character
    Local cV6MPath   as Character
    Local cV9IPath   as Character
    Local cV9JPath   as Character
    Local cV7SPath   as Character
    Local cV7TPath   as Character
    Local cV7UPath   as Character
    Local cV7VPath   as Character
    Local cV7WPath   as Character
    Local cV7XPath   as Character
    Local cV7YPath   as Character
    Local cV7ZPath   as Character
    Local cV8APath   as Character
    Local cV8BPath   as Character
    Local cV8CPath   as Character
    Local cV8DPath   as Character
    Local cV8EPath   as Character
    Local cV8FPath   as Character
    Local cV8GPath   as Character
    Local cNrInsc    as character
    Local cClone     as character
    LocaL cChT8E     as character
	Local lExistTrab as Logical
	Local lNovCenar  as Logical
	Local lRet       as Logical
    Local lOneOne    as logical
    Local lLayout12  as Logical
	Local nI         as Numeric
	Local nIndexKey  as Numeric
	Local nIndexKey1 as Numeric
	Local nJ         as Numeric
	Local nLE2       as Numeric
	Local nLE3       as Numeric
	Local nLE4       as Numeric
	Local nSeqErrGrv as Numeric
	Local nT3R       as Numeric
	Local nT5U       as Numeric
	Local nT5V       as Numeric
	Local nT5X       as Numeric
	Local nT5Y       as Numeric
	Local nT5Z       as Numeric
	Local nT6P       as Numeric
	Local nT6Q       as Numeric
	Local nT6R       as Numeric
    Local nV6M       as Numeric
    Local nV9I       as Numeric
    Local nV9J       as Numeric
    Local nV7S       as Numeric
    Local nV7T       as Numeric
    Local nV7U       as Numeric
    Local nV7V       as Numeric
    Local nV7W       as Numeric
    Local nV7X       as Numeric
    Local nV7Y       as Numeric
    Local nV7Z       as Numeric
    Local nV8A       as Numeric
    Local nV8B       as Numeric
    Local nV8C       as Numeric
    Local nV8D       as Numeric
    Local nV8E       as Numeric
    Local nV8F       as Numeric
    Local nV8G       as Numeric
	Local oMdlNvCen  as Object
	Local oModel     as Object
	Local xChkDupl   as variant
    

	Private lVldModel   as Logical
	Private oDados      as Object

	Default cComplem    := ""
	Default cGrpTran    := ""
	Default cEmpOriGrp  := ""
	Default cFilOriGrp  := ""
	Default cXmlID      := ""
	Default cKey        := ""
	Default cOwner      := ""
	Default cFilTran    := ""
	Default cPredeces   := ""
    Default cFilEv      := ""
    Default cLayout     := "1210"
	Default nOpc        := 1
	Default nTafRecno   := 0
	Default oXML        := Nil
    Default cXML       	:= ""

	aChave     := {}
    aChvRetif  := {}
	aIncons    := {}
	aRulesCad  := {}
    cBenef     := ""
	cCabec     := "/eSocial/evtPgtos/ideBenef"
	cChave     := ""
    cChvRetif  := ""
	cCmpsNoUpd := "|T3P_FILIAL|T3P_ID|T3P_VERSAO|T3P_VERANT|T3P_PROTUL|T3P_PROTPN|T3P_EVENTO|T3P_STATUS|T3P_ATIVO|"
	cCodEvent  := Posicione("C8E", 2, xFilial("C8E") + "S-" + cLayout, "C8E->C8E_ID")
    cCPF       := ""
    cEvtNew    := ""
	cInconMsg  := ""
    cIndApur   := ""
	cIndRetif  := ""
	cLogOpeAnt := ""
	cNewOw     := ""
	cOwExi     := ""
	cPeriodo   := ""
	cPerRef    := ""
	cT3QPath   := ""
	cT3RPath   := ""
    cTpGuia    := ""
	cTpPgto    := ""
    cV6MPath   := ""
    cV9IPath   := ""
    cV9JPath   := ""
    cV7SPath   := ""
    cV7TPath   := ""
    cV7UPath   := ""
    cV7VPath   := ""
    cV7WPath   := ""
    cV7XPath   := ""
    cV7YPath   := ""
    cV7ZPath   := ""
    cV8APath   := ""
    cV8BPath   := ""
    cV8CPath   := ""
    cV8DPath   := ""
    cV8EPath   := ""
    cV8FPath   := ""
    cV8GPath   := ""
    cNrInsc    := ""
    cClone     := cFilant
    cChT8E     := ""
	lExistTrab := .F.
	lNovCenar  := .F.
	lRet       := .F.
	lVldModel  := .T.
    lOneOne    := SuperGetMV("MV_TAFONE", .F., .F.)
    lLayout12  := lSimpl12 .and. TAFColumnPos("V8G_NRINSC")
	nI         := 0
	nIndexKey  := 0
	nIndexKey1 := 0
	nJ         := 0
	nLE2       := 0
	nLE3       := 0
	nLE4       := 0
	nSeqErrGrv := 0
	nT3R       := 0
	nT5U       := 0
	nT5V       := 0
	nT5X       := 0
	nT5Y       := 0
	nT5Z       := 0
	nT6P       := 0
	nT6Q       := 0
	nT6R       := 0
    nV6M       := 0
    nV9I       := 0
    nV9J       := 0
    nV7S       := 0 
    nV7T       := 0 
    nV7U       := 0 
    nV7V       := 0 
    nV7W       := 0 
    nV7X       := 0 
    nV7Y       := 0 
    nV7Z       := 0 
    nV8A       := 0 
    nV8B       := 0 
    nV8C       := 0 
    nV8D       := 0 
    nV8E       := 0 
    nV8F       := 0 
    nV8G       := 0 
	oDados     := oXML
	oMdlNvCen  := Nil
	oModel     := Nil
	xChkDupl   := Nil

    //Chave do Registro
    cIndRetif	:= FTafGetVal("/eSocial/evtPgtos/ideEvento/indRetif"        , "C", .F., @aIncons, .F.)
    cPeriodo	:= FTafGetVal("/eSocial/evtPgtos/ideEvento/perApur"         , "C", .F., @aIncons, .F.)
    cNrInsc	    := FTafGetVal("/eSocial/evtPgtos/ideEmpregador/nrInsc"      , "C", .F., @aIncons, .F.)
    cCPF        := FTafGetVal( "/eSocial/evtPgtos/ideBenef/cpfBenef", "C", .F., @aIncons, .F. )

    If lOneOne .AND. FindFunction( "OneOne" ) 
        OneOne(cPeriodo, cNrInsc, @cFilEv, cCPF, "T3P")   
    EndIf

    If !lLaySimplif

        cIndApur := FTafGetVal("/eSocial/evtPgtos/ideEvento/indApuracao", "C", .F., @aIncons, .F.) 
        cChave   += Padr(cIndApur, GetSx3Cache('T3P_INDAPU', 'X3_TAMANHO'))

        Aadd(aChave   , {"C", "T3P_INDAPU", cIndApur, .T.})   
        Aadd(aChvRetif, {"C", "T3P_INDAPU", cIndApur, .T.})    

    EndIf

    cChave += Padr(StrTran(cPeriodo, "-", "" ), GetSx3Cache('T3P_PERAPU', 'X3_TAMANHO'))

    Aadd(aChave   , {"C", "T3P_PERAPU", StrTran(cPeriodo, "-", ""), .T.})
    Aadd(aChvRetif, {"C", "T3P_PERAPU", StrTran(cPeriodo, "-", ""), .T.})

    If lLaySimplif

        cTpGuia := FTafGetVal("/eSocial/evtPgtos/ideEvento/indGuia", "C", .F., @aIncons, .F.)    
        cChave  += Padr(cTpGuia, GetSx3Cache('T3P_TPGUIA', 'X3_TAMANHO'))

        Aadd(aChave   , {"C", "T3P_TPGUIA", cTpGuia, .T.})
        Aadd(aChvRetif, {"C", "T3P_TPGUIA", cTpGuia, .T.})

    EndIf
    
    cChvRetif := cChave

    nV6M        := 1
    cV6MPath    := cCabec + "/infoPgto[" + cValToChar(nV6M) + "]"
    While oDados:XPathHasNode(cV6MPath)

        cTpPgto     := FTafGetVal(cV6MPath + "/tpPgto", "C", .F., @aIncons, .F.)

        If lLaySimplif .And. cTpPgto $ "5"

            cBenef := FGetIdInt( "cpfBenef", "","/eSocial/evtPgtos/ideBenef/cpfBenef",,,,@cInconMsg, @nSeqErrGrv,,,,,,,,,"S-1210")

            ("V73")->( DbSetOrder( 4 ) )
            If ("V73")->( MsSeek( xFilial("V73") + cBenef + '1' ) )
                cEvtNew   := V73->V73_NOMEVE
                Exit
            EndIf

        Else

            // Usa o ID do funcionário quando não for Múltiplos Vínculos
            If !AllTrim( Upper( cComplem ) ) == "MV"

                cBenef := TAFGetIdFunc( cCPF, cPeriodo,,,,, cMatrC9V,,,,,,,,,@cInconMsg )

                If !EmptY(cBenef)

                    ("C9V")->( DbSetOrder( 2 ) )
                    If ("C9V")->( MsSeek( xFilial("C9V") + cBenef + '1' ) )
                        cEvtNew   := C9V->C9V_NOMEVE
                        Exit
                    EndIf

                EndIf

            EndIf

        EndIf

        nV6M++
        cV6MPath    := cCabec + "/infoPgto[" + cValToChar(nV6M) + "]"

    EndDo
    
    If Empty( cBenef )

        aAdd( aChave, {"C", "T3P_CPF", cCPF, .T. } )

        cIdBenef := TAFGetIdFunc( cCPF, cPeriodo,,,,, cMatrC9V )
        aAdd( aChvRetif, {"C", "T3P_BENEFI", cIdBenef, .T. } )  

        ("C9V")->( DbSetOrder( 2 ) )
        If ("C9V")->( MsSeek( xFilial("C9V") + cIdBenef + '1' ) )
            cEvtNew   := C9V->C9V_NOMEVE
        EndIf

    Else

        aAdd( aChave, {"C", "T3P_BENEFI", cBenef, .T. } )

        If lLaySimplif
            aAdd( aChave, {"C", "T3P_CPF", cCPF, .T. } ) 
        EndIf

        aAdd( aChvRetif, {"C", "T3P_CPF", cCPF, .T. } ) 

    EndIf

    If !lLaySimplif

        If Empty( cBenef )
            nIndexKey1 	:= 2
            nIndexKey 	:= 6
        Else
            nIndexKey 	:= 2
            nIndexKey1 	:= 6
            lExistTrab 	:= .T.
        EndIf

    Else

        If Empty( cBenef )
            nIndexKey1 	:= 7
            nIndexKey 	:= 8
        Else
            nIndexKey 	:= 7
            nIndexKey1 	:= 8
            lExistTrab 	:= .T.
        EndIf

    EndIf

    cChave    += Padr( aChave[ 3, 3 ], Tamsx3(aChave[ 3, 2 ])[1])

    If !Empty( cBenef ) .And. lLaySimplif
        cChave    += Padr( aChave[ 4, 3 ], Tamsx3(aChave[ 4, 2 ])[1])
    EndIf

    cChvRetif += Padr( aChvRetif[ 3, 3 ], Tamsx3(aChvRetif[ 3, 2 ])[1])

    //Verifica se o evento ja existe na base
    If cIndRetif == '1'
        dbSelectArea('T3P')
        DbSetOrder( nIndexKey ) 
        If ("T3P")->( MsSeek( xFilial("T3P") + cChave + '1' ) )

            If !T3P->T3P_STATUS $ ( "2|6|4" )
                nOpc := 4
            ElseIf T3P->T3P_STATUS == "4" .AND. !Empty(T3P->T3P_PROTUL)
                nOpc := 4
                lNovCenar := .T.
                oMdlNvCen := FWLoadModel( 'TAFA407' )
                oMdlNvCen:Activate()
            EndIf

        EndIf

    ElseIf cIndRetif == '2'

        ("T3P")->( DbSetOrder( nIndexKey ) )
        If ("T3P")->( MsSeek( xFilial("T3P") + cChave + '1' ) )

            If !T3P->T3P_STATUS $ ( "2|6" )
                nOpc := 4
            EndIf

        Else

            ("T3P")->( DbSetOrder( nIndexKey1 ) )
            If ("T3P")->( MsSeek( xFilial("T3P") + cChvRetif + '1' ) )

                If !T3P->T3P_STATUS $ ( "2|6" )
                    nOpc 		:= 4
                    nIndexKey 	:= nIndexKey1
                    aChave		:= aChvRetif
                EndIf

            EndIf

        EndIf

    EndIf

    Begin Transaction

		cLayNmSpac := TafNameEspace(cXML)
	
        //Funcao para validar se a operacao desejada pode ser realizada
        If FTafVldOpe( "T3P", nIndexKey, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA407", cCmpsNoUpd , , , ,  )

            cLogOpeAnt := T3P->T3P_LOGOPE
            
            //Carrego array com os campos De/Para de gravacao das informacoes ( Cadastrais )
            aRulesCad := TAF407Rul( cCabec, cInconMsg, nSeqErrGrv, cCodEvent, cOwner, lExistTrab, cMatrC9V, cBenef )

            //Quando se tratar de uma Exclusao direta apenas preciso realizar
            //o Commit(), nao eh necessaria nenhuma manutencao nas informacoes
            If nOpc <> 5

                oModel:LoadValue( "MODEL_T3P", "T3P_FILIAL", T3P->T3P_FILIAL )
                oModel:LoadValue( "MODEL_T3P", "T3P_ORIEVE", cEvtNew )

                //tratamento para os campos tafckey e owner
                //Pegar valor do owner
                cOwExi := T3P->T3P_OWNER
    
                oModel:LoadValue( "MODEL_T3P", "T3P_TAFKEY ", cKey  )

                If Empty(cOwExi) .AND. !Empty(cOwner)

                    oModel:LoadValue( "MODEL_T3P", "T3P_OWNER ", cOwner  )

                Else

                    If !cOwner $(cOwExi) .AND.!Empty(cOwner)
                        cNewOw := Alltrim(cOwExi) + " | " + cOwner
                        oModel:LoadValue( "MODEL_T3P", "T3P_OWNER ", cNewOw )
                    EndIf

                EndIf

                oModel:LoadValue( "MODEL_T3P", "T3P_XMLID", cXmlID )
				oModel:LoadValue( "MODEL_T3P", "T3P_LAYOUT", SuperGetMV("MV_TAFVLES", .F., cLayNmSpac) )

                //Rodo o aRulesCad para gravar as informacoes
                For nI := 1 to Len( aRulesCad )
                    oModel:LoadValue( "MODEL_T3P", aRulesCad[ nI, 01 ], FTafGetVal( aRulesCad[ nI, 02 ], aRulesCad[nI, 03], aRulesCad[nI, 04], @aIncons, .F. ) )
                Next nI

                If nOpc == 3
                    TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '1', '' )
                ElseIf nOpc == 4
                    TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3P', 'T3P_LOGOPE' , '', cLogOpeAnt )
                EndIf
            
                If lNovCenar 
                    TafCrrMdl(oMdlNvCen, @oModel, T3P->T3P_ID, T3P->T3P_VERSAO )
                EndIf

                If !lLaySimplif
                
                    nT3Q := 1
                    cT3QPath := cCabec + "/infoPgto[" + CVALTOCHAR(nT3Q) + "]"

                    //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                    //Correção efetuada de modo que, o cliente possa escolher se realiza a limpeza da grid ou não.
                    T93->(DbSetOrder(1)) //T93_FILIAL + T93_EVENTO + T93_ATIVO + T93_PADRAO

                    If T93->( MsSeek( xFilial("T93") + cCodEvent + "1" + "1" ) )

                        T94->(DbSetOrder(1))
                        If T94->(MsSeek( xFilial("T94") + cCodEvent + Upper( cCabec + "/infoPgto") ) )

                            If T94->T94_EXCLUI == "1"

                                If nOpc == 4

                                    For nJ := 1 To oModel:GetModel( 'MODEL_T3Q' ):Length()
                                        oModel:GetModel( 'MODEL_T3Q' ):GoLine(nJ)
                                        oModel:GetModel( 'MODEL_T3Q' ):DeleteLine()
                                    Next nJ

                                EndIf

                            EndIf

                        EndIf
                        
                    EndIf

                    //Rodo o XML parseado para gravar as novas informacoes no GRID
                    nT3Q := 1
                    While oDados:XPathHasNode(cT3QPath)

                        oModel:GetModel( 'MODEL_T3Q'):lValid:= .T.

                        If Empty(FTafGetVal( cT3QPath + "/tpPgto","C", .F., @aIncons, .F. ))
                            aAdd( aIncons, "Tag TpPgto Obrigatória.")
                        EndIf

                        If !oModel:GetModel( 'MODEL_T3Q' ):SeekLine( { 	{ "T3Q_DTPGTO", FTafGetVal( cT3QPath + "/dtPgto","D", .F., @aIncons, .F. ) },;
                                                                        { "T3Q_TPPGTO", FTafGetVal( cT3QPath + "/tpPgto","C", .F., @aIncons, .F. ) } } )

                            If !oModel:GetModel( 'MODEL_T3Q' ):IsEmpty()
                                oModel:GetModel( 'MODEL_T3Q' ):AddLine()
                            EndIf

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/dtPgto"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO", FTafGetVal( cT3QPath + "/dtPgto","D", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/tpPgto"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO", FTafGetVal( cT3QPath + "/tpPgto","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/indResBr"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES", xFunTrcSN(FTafGetVal( cT3QPath + "/indResBr","C", .F., @aIncons, .F. ), 2) )
                        EndIf
                        
                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/idePais/codPais"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS", FGetIdInt( "codPais", "", cT3QPath + "/idePgtoExt/idePais/codPais",,,,@cInconMsg, @nSeqErrGrv ))
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/idePais/indNIF"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF", FTafGetVal( cT3QPath + "/idePgtoExt/idePais/indNIF","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/idePais/nifBenef"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN", FTafGetVal( cT3QPath + "/idePgtoExt/idePais/nifBenef","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/dscLograd"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/dscLograd", "C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/nrLograd"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/nrLograd","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/complem"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/complem","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/bairro"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/bairro","C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/nmCid"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE", FTafGetVal( cT3QPath + "/idePgtoExt/endExt/nmCid", "C", .F., @aIncons, .F. ) )
                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/idePgtoExt/endExt/codPostal"  )
                            oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   , FTafGetVal( cT3QPath + "/idePgtoExt/endExt/codPostal", "C", .F., @aIncons, .F. ) )
                        EndIf

                        nT3R := 1
                        If oDados:XPathHasNode( cT3QPath +"/detPgtoFl[" + cValToChar(nT3R) + "]" )

                            cT3RPath := cT3QPath + "/detPgtoFl[" + cValToChar(nT3R) + "]"

                            //Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
                            nT3R := 1
                            While oDados:XPathHasNode(cT3RPath )

                                oModel:GetModel( "MODEL_T3R" ):lValid:= .T.

                                cPerRef := StrTran(FwCutOff( FTafGetVal(cT3RPath + "/perRef","C",.F.,@aIncons,.F.) ), "-", "")

                                If Empty(cPerRef)
                                    cPerRef := " "
                                EndIf

                                If !oModel:GetModel( 'MODEL_T3R' ):SeekLine( { 	{ "T3R_PERREF", cPerRef },;
                                                                                { "T3R_IDEDMD", PadR(FTafGetVal( cT3RPath + "/ideDmDev","C", .F., @aIncons, .F. ), TamSX3("T3R_IDEDMD")[1]) },;
                                                                                { "T3R_INDPGT", FTafGetVal( cT3RPath + "/indPgtoTt","C", .F., @aIncons, .F. ) } } )

                                    If !oModel:GetModel( 'MODEL_T3R' ):IsEmpty()
                                        oModel:GetModel( 'MODEL_T3R' ):AddLine()
                                    EndIf

                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/perRef"  )
                                    oModel:LoadValue( "MODEL_T3R" ,"T3R_PERREF", cPerRef)
                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/ideDmDev"  )
                                    oModel:LoadValue( "MODEL_T3R" , "T3R_IDEDMD", FTafGetVal( cT3RPath + "/ideDmDev",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/indPgtoTt"  )
                                    oModel:LoadValue( "MODEL_T3R" , "T3R_INDPGT", FTafGetVal( cT3RPath + "/indPgtoTt",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT3RPath + "/vrLiq"  )
                                    oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", FTafGetVal( cT3RPath + "/vrLiq"   ,    "N", .F., @aIncons, .F. ) )
                                EndIf
                                
                                If oDados:XPathHasNode( cT3RPath + "/nrRecArq" )
                                    If X3Usado("T3R_NRARQ") 
                                        oModel:LoadValue( "MODEL_T3R", "T3R_NRARQ", FTafGetVal( cT3RPath + "/nrRecArq"   ,   "C", .F., @aIncons, .F. ) )
                                    EndIf
                                EndIf

                                nLE2 := 1
                                cLE2Path := cT3RPath + "/retPgtoTot[" + cValToChar(nLE2) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_LE2"  ):Length()
                                        oModel:GetModel( "MODEL_LE2"  ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_LE2"  ):DeleteLine()
                                    Next nJ

                                EndIf

                                nLE2 := 1
                                While oDados:XPathHasNode(cLE2Path)

                                    oModel:GetModel( "MODEL_LE2" ):lValid:= .T.

                                    If nOpc == 4 .Or. nLE2 > 1
                                        oModel:GetModel( "MODEL_LE2" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_LE2", "LE2_SEQUEN", StrZero( nLE2, TamSX3( "LE2_SEQUEN" )[1] ) )

                                    If oDados:XPathHasNode(	cLE2Path + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cLE2Path + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cLE2Path + "/codRubr", "C", .F., @aIncons, .F. ), cLE2Path, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )
                                    
                                    EndIf
                                    
                                    If oDados:XPathHasNode( cLE2Path + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_LE2", "LE2_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cLE2Path + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_LE2", "LE2_RUBRIC", FTafGetVal( cLE2Path + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_LE2", "LE2_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_QTDRUB", FTafGetVal( cLE2Path + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_FATRUB", FTafGetVal( cLE2Path + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_VLRUNI", FTafGetVal( cLE2Path + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE2Path + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_LE2", "LE2_VLRRUB", FTafGetVal( cLE2Path + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nLE3 := 1
                                    cLE3Path := cLE2Path + "/penAlim[" + cValToChar(nLE3) + "]"

                                    //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                    If nOpc == 4

                                        For nJ := 1 to oModel:GetModel( "MODEL_LE3" ):Length()
                                            oModel:GetModel( "MODEL_LE3" ):GoLine(nJ)
                                            oModel:GetModel( "MODEL_LE3" ):DeleteLine()
                                        Next nJ

                                    EndIf

                                    nLE3 := 1
                                    While oDados:XPathHasNode(cLE3Path)

                                        oModel:GetModel( "MODEL_LE3" ):lValid:= .T.

                                        If nOpc == 4 .or. nLE3 > 1
                                            oModel:GetModel( "MODEL_LE3" ):AddLine()
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/cpfBenef"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_CPFBEN", FTafGetVal( cLE3Path + "/cpfBenef",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/dtNasctoBenef"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_DTNSBE", FTafGetVal( cLE3Path + "/dtNasctoBenef",   "D", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/nmBenefic"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_NMBEN", FTafGetVal( cLE3Path + "/nmBenefic",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cLE3Path + "/vlrPensao"  )
                                            oModel:LoadValue( "MODEL_LE3", "LE3_VLRPEN", FTafGetVal( cLE3Path + "/vlrPensao",   "N", .F., @aIncons, .F. ) )
                                        EndIf

                                        nLE3++
                                        cLE3Path := cLE2Path + "/penAlim[" + cValToChar(nLE3) + "]"

                                    EndDo

                                    nLE2++
                                    cLE2Path := cT3RPath + "/retPgtoTot[" + cValToChar(nLE2) + "]"

                                EndDo

                                nLE4 := 1
                                cLE4Path := cT3RPath + "/infoPgtoParc[" + cValToChar(nLE4) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_LE4" ):Length()
                                        oModel:GetModel( "MODEL_LE4" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_LE4" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nLE4 := 1
                                While oDados:XPathHasNode(cLE4Path)

                                    oModel:GetModel( "MODEL_LE4" ):lValid:= .T.

                                    If nOpc == 4 .Or. nLE4 > 1
                                        oModel:GetModel( "MODEL_LE4" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cLE4Path + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cLE4Path + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cLE4Path + "/codRubr", "C", .F., @aIncons, .F. ), cLE4Path, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_LE4", "LE4_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr",  FTafGetVal( cLE4Path + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_LE4", "LE4_RUBRIC", FTafGetVal( cLE4Path + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_LE4", "LE4_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_QTDRUB", FTafGetVal( cLE4Path + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_FATRUB", FTafGetVal( cLE4Path + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_VLRUNI", FTafGetVal( cLE4Path + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_VLRRUB", FTafGetVal( cLE4Path + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cLE4Path + "/matricula"  )
                                        oModel:LoadValue( "MODEL_LE4", "LE4_MATRIC", FTafGetVal( cLE4Path + "/matricula", "C", .F., @aIncons, .F. ) )
                                    EndIf

                                    nLE4++
                                    cLE4Path := cT3RPath + "/infoPgtoParc[" + cValToChar(nLE4) + "]"

                                EndDo

                                nT3R++
                                cT3RPath := cT3QPath + "/detPgtoFl[" + cValToChar(nT3R) + "]"

                            EndDo

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/detPgtoBenPr[1]"  )

                            nT6P := 1
                            cT6PPath := cT3QPath + "/detPgtoBenPr[" + cValToChar(nT6P) + "]"

                            //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                            If nOpc == 4

                                For nJ := 1 to oModel:GetModel( "MODEL_T6P"  ):Length()
                                    oModel:GetModel( "MODEL_T6P"  ):GoLine(nJ)
                                    oModel:GetModel( "MODEL_T6P"  ):DeleteLine()
                                Next nJ

                            EndIf

                            //Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
                            nT6P := 1
                            While oDados:XPathHasNode(cT6PPath )

                                If nOpc == 4 .Or. nT6P > 1
                                    oModel:GetModel( "MODEL_T6P" ):lValid:= .T.
                                    oModel:GetModel( "MODEL_T6P" ):AddLine()
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/perRef"  )
                                    oModel:LoadValue( "MODEL_T6P" ,"T6P_PERREF", StrTran(FTafGetVal( cT6PPath + "/perRef","C",.F.,@aIncons,.F. ),"-",""))
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/ideDmDev"  )
                                    oModel:LoadValue( "MODEL_T6P" , "T6P_IDEDMD", FTafGetVal( cT6PPath + "/ideDmDev",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/indPgtoTt"  )
                                    oModel:LoadValue( "MODEL_T6P" , "T6P_INDPGT", FTafGetVal( cT6PPath + "/indPgtoTt",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT6PPath + "/vrLiq"  )
                                    oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", FTafGetVal( cT6PPath + "/vrLiq"   ,    "N", .F., @aIncons, .F. ) )
                                EndIf

                                nT6Q := 1
                                cT6QPath := cT6PPath + "/retPgtoTot[" + cValToChar(nT6Q) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4 .and. oDados:XPathHasNode( cT6PPath )

                                    For nJ := 1 to oModel:GetModel( "MODEL_T6Q" ):Length()
                                        oModel:GetModel( "MODEL_T6Q" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T6Q" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT6Q := 1
                                While oDados:XPathHasNode(cT6QPath)

                                    If nOpc == 4 .Or. nT6Q > 1
                                        oModel:GetModel( "MODEL_T6Q" ):lValid:= .T.
                                        oModel:GetModel( "MODEL_T6Q" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cT6QPath + "/ideTabRubr")
                                    
                                        cIdTabR := TAFIdTabRub( FTafGetVal( cT6QPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT6QPath + "/codRubr", "C", .F., @aIncons, .F. ), cT6QPath, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_T6Q", "T6Q_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cT6QPath + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_T6Q", "T6Q_RUBRIC", FTafGetVal( cT6QPath + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_QTDRUB", FTafGetVal( cT6QPath + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_FATRUB", FTafGetVal( cT6QPath + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_VLRUNI", FTafGetVal( cT6QPath + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6QPath + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_T6Q", "T6Q_VLRRUB", FTafGetVal( cT6QPath + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT6Q++
                                    cT6QPath := cT6PPath + "/retPgtoTot[" + cValToChar(nT6Q) + "]"

                                EndDo

                                nT6R := 1
                                cT6RPath := cT6PPath + "/infoPgtoParc[" + cValToChar(nT6R) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4 .and. oDados:XPathHasNode( cT6RPath )
                                
                                    For nJ := 1 to oModel:GetModel( "MODEL_T6R" ):Length()
                                        oModel:GetModel( "MODEL_T6R" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T6R" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT6R := 1
                                While oDados:XPathHasNode(cT6RPath)

                                    oModel:GetModel( "MODEL_T6R" ):lValid:= .T.

                                    If nOpc == 4 .Or. nT6R > 1
                                        oModel:GetModel( "MODEL_T6R" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cT6RPath + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cT6RPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT6RPath + "/codRubr", "C", .F., @aIncons, .F. ), cT6RPath, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/codRubr"  )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_T6R", "T6R_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr",  FTafGetVal( cT6RPath + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_T6R", "T6R_RUBRIC", FTafGetVal( cT6RPath + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_T6R", "T6R_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/qtdRubr"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_QTDRUB", FTafGetVal( cT6RPath + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/fatorRubr"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_FATRUB", FTafGetVal( cT6RPath + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/vrUnit"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_VLRUNI", FTafGetVal( cT6RPath + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT6RPath + "/vrRubr"  )
                                        oModel:LoadValue( "MODEL_T6R", "T6R_VLRRUB", FTafGetVal( cT6RPath + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT6R++
                                    cT6RPath := cT6PPath + "/infoPgtoParc[" + cValToChar(nT6R) + "]"

                                EndDo

                                nT6P++
                                cT6PPath := cT6PPath + "/detPgtoFl[" + cValToChar(nT6P) + "]"

                            EndDo

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/detPgtoFer[1]"  )

                            nT5U := 1
                            cT5UPath := cT3QPath + "/detPgtoFer[" + cValToChar(nT5U) + "]"

                            //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                            If nOpc == 4

                                For nJ := 1 to oModel:GetModel( "MODEL_T5U" ):Length()
                                    oModel:GetModel( "MODEL_T5U" ):GoLine(nJ)
                                    oModel:GetModel( "MODEL_T5U" ):DeleteLine()
                                Next nJ

                            EndIf

                            //Rodo o XML parseado para gravar as novas informacoes no GRID ( Cadastro de Dependentes )
                            nT5U := 1
                            While oDados:XPathHasNode(cT5UPath )

                                oModel:GetModel( "MODEL_T5U"  ):lValid:= .T.

                                If nOpc == 4 .or. nT5U > 1
                                    oModel:GetModel( "MODEL_T5U"  ):AddLine()
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/codCateg" )
                                    oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", FGetIdInt( "codCateg", "", cT5UPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/dtIniGoz" )
                                    oModel:LoadValue( "MODEL_T5U" , "T5U_DTINIG", FTafGetVal( cT5UPath + "/dtIniGoz",    "D", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/qtDias" )
                                    oModel:LoadValue( "MODEL_T5U" , "T5U_QTDIAS", FTafGetVal( cT5UPath + "/qtDias",    "N", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/vrLiq" )
                                    oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", FTafGetVal( cT5UPath + "/vrLiq"   ,    "N", .F., @aIncons, .F. ) )
                                EndIf

                                If oDados:XPathHasNode( cT5UPath + "/matricula" )
                                    oModel:LoadValue( "MODEL_T5U", "T5U_MATRIC", FTafGetVal( cT5UPath + "/matricula",    "C", .F., @aIncons, .F. ) )
                                EndIf

                                nT5Y := 1
                                cT5YPath := cT5UPath + "/detRubrFer[" + cValToChar(nT5Y) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_T5Y" ):Length()
                                        oModel:GetModel( "MODEL_T5Y" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T5Y" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT5Y := 1
                                While oDados:XPathHasNode(cT5YPath)

                                    oModel:GetModel( "MODEL_T5Y" ):lValid:= .T.

                                    If nOpc == 4 .or. nT5Y > 1
                                        oModel:GetModel( "MODEL_T5Y" ):AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(	cT5YPath + "/ideTabRubr")

                                        cIdTabR := TAFIdTabRub( FTafGetVal( cT5YPath + "/ideTabRubr", "C", .F., @aIncons, .F. ), "T3M", FTafGetVal( cT5YPath + "/codRubr", "C", .F., @aIncons, .F. ), cT5YPath, @cInconMsg, @nSeqErrGrv, @aIncons  )

                                    Else

                                        cIdTabR := ""

                                        //Gera mensagem de erro
                                        TAFMsgIncons( @cInconMsg, @nSeqErrGrv,,, .T., 'ideTabRubr', cIdTabR, '', , '', '' )

                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/codRubr" )

                                        If lExistTrab
                                            oModel:LoadValue( "MODEL_T5Y", "T5Y_IDRUBR", FGetIdInt( "codRubr", "ideTabRubr", FTafGetVal( cT5YPath + "/codRubr",   "C", .F., @aIncons, .F. ),cIdTabR,.F.,,@cInconMsg, @nSeqErrGrv,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/,StrTran(cPeriodo,"-","")))
                                        Else
                                            oModel:LoadValue( "MODEL_T5Y", "T5Y_RUBRIC", FTafGetVal( cT5YPath + "/codRubr",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                    EndIf

                                    If !lExistTrab
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_IDTABR", cIdTabR )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/qtdRubr" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_QTDRUB", FTafGetVal( cT5YPath + "/qtdRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/fatorRubr" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_FATRUB", FTafGetVal( cT5YPath + "/fatorRubr",   "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/vrUnit" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_VLRUNI", FTafGetVal( cT5YPath + "/vrUnit",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    If oDados:XPathHasNode( cT5YPath + "/vrRubr" )
                                        oModel:LoadValue( "MODEL_T5Y", "T5Y_VLRRUB", FTafGetVal( cT5YPath + "/vrRubr",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT5Z := 1
                                    cT5ZPath := cT5YPath + "/penAlim[" + cValToChar(nT5Z) + "]"

                                    //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                    If nOpc == 4

                                        For nJ := 1 to oModel:GetModel( "MODEL_T5Z" ):Length()
                                            oModel:GetModel( "MODEL_T5Z" ):GoLine(nT5Z)
                                            oModel:GetModel( "MODEL_T5Z" ):DeleteLine()
                                        Next nJ

                                    EndIf

                                    nT5Z := 1
                                    While oDados:XPathHasNode(cT5ZPath)

                                        oModel:GetModel( "MODEL_T5Z" ):lValid:= .T.

                                        If nOpc == 4 .or. nT5Z > 1
                                            oModel:GetModel( "MODEL_T5Z" ):AddLine()
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/cpfBenef" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_CPFBEN", FTafGetVal( cT5ZPath + "/cpfBenef",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/dtNasctoBenef" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_DTNSBE", FTafGetVal( cT5ZPath + "/dtNasctoBenef",   "D", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/nmBenefic" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_NMBEN ", FTafGetVal( cT5ZPath + "/nmBenefic",   "C", .F., @aIncons, .F. ) )
                                        EndIf

                                        If oDados:XPathHasNode( cT5ZPath + "/vlrPensao" )
                                            oModel:LoadValue( "MODEL_T5Z", "T5Z_VLRPEN", FTafGetVal( cT5ZPath + "/vlrPensao",   "N", .F., @aIncons, .F. ) )
                                        EndIf

                                        nT5Z++
                                        cT5ZPath := cT5YPath + "/penAlim[" + cValToChar(nT5Z) + "]"

                                    EndDo

                                    nT5Y++
                                    cT5YPath := cT5UPath + "/detRubrFer[" + cValToChar(nT5Y) + "]"

                                EndDo

                                nT5U++
                                cT5UPath := cT3QPath + "/detPgtoFer[" + cValToChar(nT5U) + "]"

                            EndDo

                        EndIf

                        If oDados:XPathHasNode( cT3QPath + "/detPgtoAnt[1]" )

                            nT5V := 1
                            cT5VPath := cT3QPath + "/detPgtoAnt[" + cValToChar(nT5V) + "]"

                            //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                            If nOpc == 4

                                For nJ := 1 to oModel:GetModel( "MODEL_T5V"  ):Length()
                                    oModel:GetModel( "MODEL_T5V"  ):GoLine(nJ)
                                    oModel:GetModel( "MODEL_T5V"  ):DeleteLine()
                                Next nJ

                            EndIf

                            nT5V := 1
                            While oDados:XPathHasNode(cT5VPath)

                                oModel:GetModel( "MODEL_T5V" ):lValid:= .T.

                                If nOpc == 4 .or. nT5V > 1
                                    oModel:GetModel( "MODEL_T5V" ):AddLine()
                                EndIf

                                If oDados:XPathHasNode( cT5VPath + "/codCateg" )
                                    oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", FGetIdInt( "codCateg", "", cT5VPath + "/codCateg",,,,@cInconMsg, @nSeqErrGrv))
                                EndIf

                                nT5X := 1
                                cT5XPath := cT5VPath + "/infoPgtoAnt[" + cValToChar(nT5X) + "]"

                                //Quando se trata de uma alteracao, deleto todas as linhas do Grid
                                If nOpc == 4

                                    For nJ := 1 to oModel:GetModel( "MODEL_T5X" ):Length()
                                        oModel:GetModel( "MODEL_T5X" ):GoLine(nJ)
                                        oModel:GetModel( "MODEL_T5X" ):DeleteLine()
                                    Next nJ

                                EndIf

                                nT5X := 1
                                While oDados:XPathHasNode(cT5XPath)

                                    oModel:GetModel( "MODEL_T5X" ):lValid:= .T.

                                    If nOpc == 4 .or. nT5X > 1
                                        oModel:GetModel( "MODEL_T5X" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T5X", "T5X_SEQUEN", StrZero( nT5X, TamSX3( "T5X_SEQUEN" )[1] ) )

                                    If oDados:XPathHasNode( cT5XPath + "/tpBcIRRF" )
                                        oModel:LoadValue( "MODEL_T5X", "T5X_IDTPIR", FGetIdInt( "tpBcIRRF", "", cT5XPath + "/tpBcIRRF",,,,@cInconMsg, @nSeqErrGrv))
                                    EndIf

                                    If oDados:XPathHasNode( cT5XPath + "/vrBcIRRF" )
                                        oModel:LoadValue( "MODEL_T5X", "T5X_VLRBCI", FTafGetVal( cT5XPath + "/vrBcIRRF",    "N", .F., @aIncons, .F. ) )
                                    EndIf

                                    nT5X++
                                    cT5XPath := cT5VPath + "/infoPgtoAnt[" + cValToChar(nT5X) + "]"

                                EndDo

                                nT5V++
                                cT5VPath := cT3QPath + "/detPgtoAnt[" + cValToChar(nT5V) + "]"

                            EndDo

                        EndIf

                        nT3Q++
                        cT3QPath := cCabec + "/infoPgto[" + CVALTOCHAR(nT3Q) + "]"

                    EndDo

                Else
                
                    nTpPagto    := GetSX3Cache("V6M_TPPGTO", "X3_TAMANHO")
                    nPerRef     := GetSX3Cache("V6M_PERREF", "X3_TAMANHO")
                    nIndDev     := GetSX3Cache("V6M_INDDEV", "X3_TAMANHO")
                    cChvFil     := xFilial("T3P")
                    cChvId      := T3P->T3P_ID
                    cChvVer     := T3P->T3P_VERSAO
                    cChvPgt     := Space(nTpPagto)
                    cChvPer     := Space(nPerRef)
                    cChvInd     := Space(nIndDev)

                    oModelV6M := oModel:GetModel("MODEL_V6M")
                    
                    If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                        oModelV9I := oModel:GetModel("MODEL_V9I")
                        oModelV9J := oModel:GetModel("MODEL_V9J")
                    EndIf

                    If nOpc == 4 .And. cIndRetif == "2"

                        For nJ := 1 To oModelV6M:Length()
                            oModelV6M:GoLine(nJ)
                            oModelV6M:DeleteLine()
                        Next

                    EndIf

                    nV6M        := 1
                    cV6MPath    := cCabec + "/infoPgto[" + cValToChar(nV6M) + "]"

                    While oDados:XPathHasNode(cV6MPath)

                        cChvPgt := PadR(FTafGetVal(cV6MPath + "/tpPgto", "C", .F., @aIncons, .F.)                    , nTpPagto)
                        cChvPer := PadR(StrTran(FTafGetVal(cV6MPath + "/perRef", "C", .F., @aIncons, .F.), "-", "")  , nPerRef)
                        cChvInd := PadR(FTafGetVal(cV6MPath + "/ideDmDev", "C", .F., @aIncons, .F.)                  , nIndDev)

                        oModelV6M:lValid := .T.

                        If !oModelV6M:SeekLine({{"V6M_TPPGTO", cChvPgt}, {"V6M_PERREF", cChvPer}, {"V6M_INDDEV", cChvInd}})
                            If !oModelV6M:IsEmpty()
                                oModelV6M:AddLine()
                            EndIf
                        Else
                            oModelV6M:DeleteLine()
                            oModelV6M:AddLine()
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/dtPgto")
                            oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", FTafGetVal(cV6MPath + "/dtPgto", "D", .F., @aIncons, .F.))
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/tpPgto")
                            oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", FTafGetVal(cV6MPath + "/tpPgto", "C", .F., @aIncons, .F.))
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/perRef")
                            oModel:LoadValue("MODEL_V6M", "V6M_PERREF", StrTran(FTafGetVal(cV6MPath + "/perRef", "C", .F., @aIncons, .F.), "-"))
                        EndIf

                        If oDados:XPathHasNode(cV6MPath + "/ideDmDev")
                            oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", FTafGetVal(cV6MPath + "/ideDmDev", "C", .F., @aIncons, .F.))
                        EndIf
                
                        If oDados:XPathHasNode(cV6MPath + "/vrLiq")
                            oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", FTafGetVal(cV6MPath + "/vrLiq", "N", .F., @aIncons, .F.))
                        EndIf

                        If lSimplBeta 

                            If oDados:XPathHasNode(cV6MPath + "/paisResidExt")
                                oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", FGetIdInt("paisResidExt", "", cV6MPath + "/paisResidExt",,,, @cInconMsg, @nSeqErrGrv))
                            EndIf                            

                            nV9I        := 1
                            cV9IPath    := cV6MPath + "/infoPgtoExt[" + cValToChar(nV9I) + "]"

                            While oDados:XPathHasNode(cV9IPath)

                                oModelV9I:lValid := .T.
                                
                                If oDados:XPathHasNode(cV9IPath + "/indNIF")
                                    oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", FTafGetVal(cV9IPath + "/indNIF", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV9IPath + "/nifBenef")
                                    oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", FTafGetVal(cV9IPath + "/nifBenef", "C", .F., @aIncons, .F.))
                                EndIf  

                                If oDados:XPathHasNode(cV9IPath + "/frmTribut")
                                    oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", FGetIdInt("frmTribut", "", cV9IPath + "/frmTribut",,,, @cInconMsg, @nSeqErrGrv))
                                EndIf

                                nV9J        := 1
                                cV9JPath    := cV9IPath + "/endExt[" + cValToChar(nV9J) + "]"

                                While oDados:XPathHasNode(cV9JPath)

                                    oModelV9J:lValid := .T. 

                                    If oDados:XPathHasNode(cV9JPath + "/endDscLograd")
                                        oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", FTafGetVal(cV9JPath + "/endDscLograd", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endNrLograd")
                                        oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", FTafGetVal(cV9JPath + "/endNrLograd", "C", .F., @aIncons, .F.))
                                    EndIf  

                                    If oDados:XPathHasNode(cV9JPath + "/endComplem")
                                        oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", FTafGetVal(cV9JPath + "/endComplem", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endBairro")
                                        oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", FTafGetVal(cV9JPath + "/endBairro", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endCidade")
                                        oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", FTafGetVal(cV9JPath + "/endCidade", "C", .F., @aIncons, .F.))
                                    EndIf   

                                    If oDados:XPathHasNode(cV9JPath + "/endEstado")
                                        oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", FTafGetVal(cV9JPath + "/endEstado", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV9JPath + "/endCodPostal")
                                        oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", FTafGetVal(cV9JPath + "/endCodPostal", "C", .F., @aIncons, .F.))
                                    EndIf  

                                    If oDados:XPathHasNode(cV9JPath + "/telef")
                                        oModel:LoadValue("MODEL_V9J", "V9J_TELEF", FTafGetVal(cV9JPath + "/telef", "C", .F., @aIncons, .F.))
                                    EndIf
                                    
                                    nV9J++
                                    cV9JPath := cV9IPath + "/endExt[" + cValToChar(nV9J) + "]"    

                                EndDo
                                
                                nV9I++
                                cV9IPath := cV6MPath + "/infoPgtoExt[" + cValToChar(nV9I) + "]"     

                            EndDo

                        EndIf

                        nV6M++
                        cV6MPath := cCabec + "/infoPgto[" + cValToChar(nV6M) + "]"

                    EndDo

                    If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC") )
                        
                        oModelV7S := oModel:GetModel( "MODEL_V7S" )

                        If nOpc == 4 .And. cIndRetif == "2"

                            For nJ := 1 To oModelV7S:Length()
                                oModelV7S:GoLine(nJ)
                                oModelV7S:DeleteLine()
                            Next

                        EndIf

                        nV7S        := 1
                        cV7SPath    := cCabec + "/infoIRComplem/infoDep[" + cValToChar(nV7S) + "]"

                        While oDados:XPathHasNode(cV7SPath)
                            oModelV7S:lValid:= .T. 

                            cChvCPF := FTafGetVal(cV7SPath + "/cpfDep", "C", .F., @aIncons, .F.)

                            If !oModelV7S:SeekLine({{"V7S_CPFDEP", cChvCPF}})
                                If !oModelV7S:IsEmpty()
                                    oModelV7S:AddLine()
                                EndIf
                            Else
                                oModelV7S:DeleteLine()
                                oModelV7S:AddLine()
                            EndIf

                            If oDados:XPathHasNode(cV7SPath + "/cpfDep")
                                oModel:LoadValue("MODEL_V7S", "V7S_CPFDEP", FTafGetVal(cV7SPath + "/cpfDep", "C", .F., @aIncons, .F.))
                            EndIf

                            If oDados:XPathHasNode(cV7SPath + "/dtNascto")
                                oModel:LoadValue("MODEL_V7S", "V7S_DTNASC", FTafGetVal(cV7SPath + "/dtNascto", "D", .F., @aIncons, .F.))
                            EndIf

                            If oDados:XPathHasNode(cV7SPath + "/nome")
                                oModel:LoadValue("MODEL_V7S", "V7S_NMDEP", FTafGetVal(cV7SPath + "/nome", "C", .F., @aIncons, .F.))
                            EndIf

                            If oDados:XPathHasNode(cV7SPath + "/depIRRF")
                                oModel:LoadValue("MODEL_V7S", "V7S_DPIRRF", FTafGetVal(cV7SPath + "/depIRRF", "C", .F., @aIncons, .F.))
                            EndIf

                            If oDados:XPathHasNode(cV7SPath + "/tpDep")
                                oModel:LoadValue("MODEL_V7S", "V7S_TPDEP", FGetIdInt( "tpDep", "", cV7SPath + "/tpDep" ,,,,@cInconMsg, @nSeqErrGrv ))
                            EndIf

                            If oDados:XPathHasNode(cV7SPath + "/descrDep")
                                oModel:LoadValue("MODEL_V7S", "V7S_DSCDEP", FTafGetVal(cV7SPath + "/descrDep", "C", .F., @aIncons, .F.))
                            EndIf

                            nV7S++
                            cV7SPath:= cCabec + "/infoIRComplem/infoDep[" + cValToChar(nV7S) + "]"
                        EndDo

                        nV7T        := 1
                        cV7TPath    := cCabec + "/infoIRComplem/infoIRCR[" + cValToChar(nV7T) + "]"

                        oModelV7T := oModel:GetModel( "MODEL_V7T" )

                        If nOpc == 4 .And. cIndRetif == "2"

                            For nJ := 1 To oModelV7T:Length()
                                oModelV7T:GoLine(nJ)
                                oModelV7T:DeleteLine()
                            Next

                        EndIf

                        While oDados:XPathHasNode(cV7TPath)
                            oModelV7T:lValid:= .T.

                            cChavTpCr := FGetIdInt( "tpCR", "", cV7TPath + "/tpCR" ,,,,@cInconMsg, @nSeqErrGrv)

                            If !oModelV7T:SeekLine({{"V7T_TPCR", cChavTpCr}})
                                If !oModelV7T:IsEmpty()
                                    oModelV7T:AddLine()
                                EndIf
                            Else
                                oModelV7T:DeleteLine()
                                oModelV7T:AddLine()
                            EndIf

                            If oDados:XPathHasNode(cV7TPath + "/tpCR")
                                oModel:LoadValue("MODEL_V7T", "V7T_TPCR", FGetIdInt( "tpCR", "", cV7TPath + "/tpCR" ,,,,@cInconMsg, @nSeqErrGrv))
                            EndIf


                            nV7U        := 1
                            cV7UPath    := cV7TPath + "/dedDepen[" + cValToChar(nV7U) + "]"

                            oModelV7U := oModel:GetModel( "MODEL_V7U" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV7U:Length()
                                    oModelV7U:GoLine(nJ)
                                    oModelV7U:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV7UPath)
                                oModelV7U:lValid:= .T.

                                cChavTpRend := FTafGetVal(cV7UPath + "/tpRend", "C", .F., @aIncons, .F.)
                                cChavCPFDep := FTafGetVal(cV7UPath + "/cpfDep", "C", .F., @aIncons, .F.)

                                If !oModelV7U:SeekLine({{"V7U_TPREND", cChavTpRend},{"V7U_CPFDEP",cChavCPFDep}})
                                    If !oModelV7U:IsEmpty()
                                        oModelV7U:AddLine()
                                    EndIf
                                Else
                                    oModelV7U:DeleteLine()
                                    oModelV7U:AddLine()
                                EndIf

                                If oDados:XPathHasNode(cV7UPath + "/tpRend")
                                    oModel:LoadValue("MODEL_V7U", "V7U_TPREND", FTafGetVal(cV7UPath + "/tpRend", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7UPath + "/cpfDep")
                                    oModel:LoadValue("MODEL_V7U", "V7U_CPFDEP", FTafGetVal(cV7UPath + "/cpfDep", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7UPath + "/vlrDedDep")
                                    oModel:LoadValue("MODEL_V7U", "V7U_VLRDED", FTafGetVal(cV7UPath + "/vlrDedDep", "N", .F., @aIncons, .F.))
                                EndIf 

                                nV7U++
                                cV7UPath    := cV7TPath + "/dedDepen[" + cValToChar(nV7U) + "]"
                            EndDo

                            nV7V    := 1
                            cV7VPath := cV7TPath + "/penAlim[" + cValToChar(nV7V) + "]"

                            oModelV7V := oModel:GetModel( "MODEL_V7V" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV7V:Length()
                                    oModelV7V:GoLine(nJ)
                                    oModelV7V:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV7VPath)
                                oModelV7V:lValid:= .T.

                                cChvTpRend := FTafGetVal(cV7VPath + "/tpRend", "C", .F., @aIncons, .F.)
                                cChvCPFDep := FTafGetVal(cV7VPath + "/cpfDep", "C", .F., @aIncons, .F.)

                                If !oModelV7V:SeekLine({{"V7V_TPREND", cChvTpRend},{"V7V_CPFDEP",cChvCPFDep}})
                                    If !oModelV7V:IsEmpty()
                                        oModelV7V:AddLine()
                                    EndIf
                                Else
                                    oModelV7V:DeleteLine()
                                    oModelV7V:AddLine()
                                EndIf

                                If oDados:XPathHasNode(cV7VPath + "/tpRend")
                                    oModel:LoadValue("MODEL_V7V", "V7V_TPREND", FTafGetVal(cV7VPath + "/tpRend", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7VPath + "/cpfDep")
                                    oModel:LoadValue("MODEL_V7V", "V7V_CPFDEP", FTafGetVal(cV7VPath + "/cpfDep", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7VPath + "/vlrDedPenAlim")
                                    oModel:LoadValue("MODEL_V7V", "V7V_VLPEN", FTafGetVal(cV7VPath + "/vlrDedPenAlim", "N", .F., @aIncons, .F.))
                                EndIf 

                                nV7V++
                                cV7VPath    := cV7TPath + "/penAlim[" + cValToChar(nV7V) + "]"
                            EndDo

                            nV7W    := 1
                            cV7WPath := cV7TPath + "/previdCompl[" + cValToChar(nV7W) + "]"

                            oModelV7W := oModel:GetModel( "MODEL_V7W" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV7W:Length()
                                    oModelV7W:GoLine(nJ)
                                    oModelV7W:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV7WPath)
                                oModelV7W:lValid:= .T.

                                cChvTpPrev := FTafGetVal(cV7WPath + "/tpPrev"     , "C", .F., @aIncons, .F.)
                                cChcInsCpl := FTafGetVal(cV7WPath + "/cnpjEntidPC", "C", .F., @aIncons, .F.)

                                If !oModelV7W:SeekLine({{"V7W_TPREV", cChvTpPrev},{"V7W_INSCPL",cChcInsCpl}})
                                    If !oModelV7W:IsEmpty()
                                        oModelV7W:AddLine()
                                    EndIf
                                Else
                                    oModelV7W:DeleteLine()
                                    oModelV7W:AddLine()
                                EndIf

                                If oDados:XPathHasNode(cV7WPath + "/tpPrev")
                                    oModel:LoadValue("MODEL_V7W", "V7W_TPREV", FTafGetVal(cV7WPath + "/tpPrev", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7WPath + "/cnpjEntidPC")
                                    oModel:LoadValue("MODEL_V7W", "V7W_INSCPL", FTafGetVal(cV7WPath + "/cnpjEntidPC", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7WPath + "/vlrDedPC")
                                    oModel:LoadValue("MODEL_V7W", "V7W_VLCOMP", FTafGetVal(cV7WPath + "/vlrDedPC", "N", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7WPath + "/vlrPatrocFunp")
                                    oModel:LoadValue("MODEL_V7W", "V7W_VLPATR", FTafGetVal(cV7WPath + "/vlrPatrocFunp", "N", .F., @aIncons, .F.))
                                EndIf 

                                nV7W++
                                cV7WPath    := cV7TPath + "/previdCompl[" + cValToChar(nV7W) + "]"
                            EndDo

                            nV7X    := 1
                            cV7XPath := cV7TPath + "/infoProcRet[" + cValToChar(nV7X) + "]"

                            oModelV7X := oModel:GetModel( "MODEL_V7X" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV7X:Length()
                                    oModelV7X:GoLine(nJ)
                                    oModelV7X:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV7XPath)
                                oModelV7X:lValid:= .T.

                                cChvTpProc  := FTafGetVal(cV7XPath + "/tpProcRet", "C", .F., @aIncons, .F.)
                                cChcNrProc  := FTafGetVal(cV7XPath + "/nrProcRet", "C", .F., @aIncons, .F.)
                                cChcCodSusp := FTafGetVal(cV7XPath + "/codSusp"  , "C", .F., @aIncons, .F.)

                                If !oModelV7X:SeekLine({{"V7X_TPPROC", cChvTpProc},{"V7X_NRPROC",cChcNrProc},{"V7X_CODSUP",cChcCodSusp}})
                                    If !oModelV7X:IsEmpty()
                                        oModelV7X:AddLine()
                                    EndIf
                                Else
                                    oModelV7X:DeleteLine()
                                    oModelV7X:AddLine()
                                EndIf

                                If oDados:XPathHasNode(cV7XPath + "/tpProcRet")
                                    oModel:LoadValue("MODEL_V7X", "V7X_TPPROC", FTafGetVal(cV7XPath + "/tpProcRet", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7XPath + "/nrProcRet")
                                    oModel:LoadValue("MODEL_V7X", "V7X_NRPROC", FTafGetVal(cV7XPath + "/nrProcRet", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV7XPath + "/codSusp")
                                    oModel:LoadValue("MODEL_V7X", "V7X_CODSUP", FTafGetVal(cV7XPath + "/codSusp", "C", .F., @aIncons, .F.))
                                EndIf

                                nV7Y    := 1
                                cV7YPath := cV7XPath + "/infoValores[" + cValToChar(nV7Y) + "]"

                                oModelV7Y := oModel:GetModel( "MODEL_V7Y" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV7Y:Length()
                                        oModelV7Y:GoLine(nJ)
                                        oModelV7Y:DeleteLine()
                                    Next

                                EndIf

                                While oDados:XPathHasNode(cV7YPath)
                                    oModelV7Y:lValid:= .T.

                                    cChvIndApu  := FTafGetVal(cV7YPath + "/indApuracao", "C", .F., @aIncons, .F.)

                                    If !oModelV7Y:SeekLine({{"V7Y_INDAPU", cChvIndApu}})
                                        If !oModelV7Y:IsEmpty()
                                            oModelV7Y:AddLine()
                                        EndIf
                                    Else
                                        oModelV7Y:DeleteLine()
                                        oModelV7Y:AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(cV7YPath + "/indApuracao")
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_INDAPU", FTafGetVal(cV7YPath + "/indApuracao", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV7YPath + "/vlrNRetido")
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLRRET", FTafGetVal(cV7YPath + "/vlrNRetido", "N", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV7YPath + "/vlrDepJud")
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLRJUD", FTafGetVal(cV7YPath + "/vlrDepJud", "N", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV7YPath + "/vlrCmpAnoCal")
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLACAL", FTafGetVal(cV7YPath + "/vlrCmpAnoCal", "N", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV7YPath + "/vlrCmpAnoAnt")
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLAANT", FTafGetVal(cV7YPath + "/vlrCmpAnoAnt", "N", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV7YPath + "/vlrRendSusp")
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLSUSP", FTafGetVal(cV7YPath + "/vlrRendSusp", "N", .F., @aIncons, .F.))
                                    EndIf

                                    nV7Z     := 1
                                    cV7ZPath := cV7YPath + "/dedSusp[" + cValToChar(nV7Z) + "]"

                                    oModelV7Z := oModel:GetModel( "MODEL_V7Z" )

                                    If nOpc == 4 .And. cIndRetif == "2"

                                        For nJ := 1 To oModelV7Z:Length()
                                            oModelV7Z:GoLine(nJ)
                                            oModelV7Z:DeleteLine()
                                        Next
                                    EndIf

                                    While oDados:XPathHasNode(cV7ZPath)
                                        oModelV7Z:lValid:= .T.

                                        cChvV7ZSequen  := STRZERO(nV7Z,6)

                                        If !oModelV7Z:SeekLine({{"V7Z_SEQUEN", cChvV7ZSequen}})
                                            If !oModelV7Z:IsEmpty()
                                                oModelV7Z:AddLine()
                                            EndIf
                                        Else
                                            oModelV7Z:DeleteLine()
                                            oModelV7Z:AddLine()
                                        EndIf
                                        
                                        oModel:LoadValue( "MODEL_V7Z", "V7Z_SEQUEN", cChvV7ZSequen )

                                        If oDados:XPathHasNode(cV7ZPath + "/indTpDeducao")
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_TPDEDU", FTafGetVal(cV7ZPath + "/indTpDeducao", "C", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7ZPath + "/vlrDedSusp")
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_VLSUSP", FTafGetVal(cV7ZPath + "/vlrDedSusp", "N", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7ZPath + "/cnpjEntidPC")
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_INSCPL", FTafGetVal(cV7ZPath + "/cnpjEntidPC", "C", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7ZPath + "/vlrPatrocFunp")
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_VLFUNP", FTafGetVal(cV7ZPath + "/vlrPatrocFunp", "N", .F., @aIncons, .F.))
                                        EndIf

                                        nV8A     := 1
                                        cV8APath := cV7ZPath + "/benefPen[" + cValToChar(nV8A) + "]"

                                        oModelV8A := oModel:GetModel( "MODEL_V8A" )

                                        If nOpc == 4 .And. cIndRetif == "2"

                                            For nJ := 1 To oModelV8A:Length()
                                                oModelV8A:GoLine(nJ)
                                                oModelV8A:DeleteLine()
                                            Next
                                        EndIf

                                        While oDados:XPathHasNode(cV8APath)
                                            oModelV8A:lValid:= .T.

                                            cChvCPFV8A := FTafGetVal(cV8APath + "/cpfDep", "C", .F., @aIncons, .F.)
                                            cChvV8ASequen := cChvV7ZSequen

                                            If !oModelV8A:SeekLine({{"V8A_CPFDEP",cChvCPFV8A},{"V8A_SEQUEN",cChvV8ASequen}})
                                                If !oModelV8A:IsEmpty()
                                                    oModelV8A:AddLine()
                                                EndIf
                                            Else
                                                oModelV8A:DeleteLine()
                                                oModelV8A:AddLine()
                                            EndIf
    
                                            oModel:LoadValue( "MODEL_V8A", "V8A_SEQUEN", cChvV8ASequen )

                                            If oDados:XPathHasNode(cV8APath + "/cpfDep")
                                                oModel:LoadValue("MODEL_V8A", "V8A_CPFDEP", FTafGetVal(cV8APath + "/cpfDep", "C", .F., @aIncons, .F.))
                                            EndIf

                                            If oDados:XPathHasNode(cV8APath + "/vlrDepenSusp")
                                                oModel:LoadValue("MODEL_V8A", "V8A_VLSUSP", FTafGetVal(cV8APath + "/vlrDepenSusp", "N", .F., @aIncons, .F.))
                                            EndIf

                                            nV8A++
                                            cV8APath := cV7ZPath + "/benefPen[" + cValToChar(nV8A) + "]"
                                        EndDo

                                        nV7Z++
                                        cV7ZPath := cV7YPath + "/dedSusp[" + cValToChar(nV7Z) + "]"
                                    EndDo 

                                    nV7Y++
                                    cV7YPath := cV7XPath + "/infoValores[" + cValToChar(nV7Y) + "]"
                                EndDo 

                                nV7X++
                                cV7XPath    := cV7TPath + "/infoProcRet[" + cValToChar(nV7X) + "]"
                            EndDo

                            nV7T++
                            cV7TPath:= cCabec + "/infoIRComplem/infoIRCR[" + cValToChar(nV7T) + "]"
                        EndDo 

                        nV8B        := 1
                        cV8BPath    := cCabec + "/infoIRComplem/planSaude[" + cValToChar(nV8B) + "]"

                        oModelV8B := oModel:GetModel( "MODEL_V8B" )

                        If nOpc == 4 .And. cIndRetif == "2"

                            For nJ := 1 To oModelV8B:Length()
                                oModelV8B:GoLine(nJ)
                                oModelV8B:DeleteLine()
                            Next

                        EndIf

                        While oDados:XPathHasNode(cV8BPath)
                            oModelV8B:lValid:= .T.

                            cChvCnpjOp := FTafGetVal(cV8BPath + "/cnpjOper", "C", .F., @aIncons, .F.)
  
                            If !oModelV8B:SeekLine({{"V8B_CNPJOP",cChvCnpjOp}})
                                If !oModelV8B:IsEmpty()
                                    oModelV8B:AddLine()
                                EndIf
                            Else
                                oModelV8B:DeleteLine()
                                oModelV8B:AddLine()
                            EndIf

                            If oDados:XPathHasNode(cV8BPath + "/cnpjOper")
                                oModel:LoadValue("MODEL_V8B", "V8B_CNPJOP", FTafGetVal(cV8BPath + "/cnpjOper", "C", .F., @aIncons, .F.))
                            EndIf 

                            If oDados:XPathHasNode(cV8BPath + "/regANS")
                                oModel:LoadValue("MODEL_V8B", "V8B_REGANS", FTafGetVal(cV8BPath + "/regANS", "C", .F., @aIncons, .F.))
                            EndIf 

                            If oDados:XPathHasNode(cV8BPath + "/vlrSaudeTit")
                                oModel:LoadValue("MODEL_V8B", "V8B_VLRTIT", FTafGetVal(cV8BPath + "/vlrSaudeTit", "N", .F., @aIncons, .F.))
                            EndIf 

                            nV8C        := 1
                            cV8CPath    := cV8BPath + "/infoDepSau[" + cValToChar(nV8C) + "]"

                            oModelV8C := oModel:GetModel( "MODEL_V8C" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV8C:Length()
                                    oModelV8C:GoLine(nJ)
                                    oModelV8C:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV8CPath)
                                oModelV8C:lValid:= .T.

                                cChvCPFV8C := FTafGetVal(cV8CPath + "/cpfDep", "C", .F., @aIncons, .F.)

                                If !oModelV8C:SeekLine({{"V8C_CPFDEP",cChvCPFV8C}})
                                    If !oModelV8C:IsEmpty()
                                        oModelV8C:AddLine()
                                    EndIf
                                Else
                                    oModelV8C:DeleteLine()
                                    oModelV8C:AddLine()
                                EndIf
                                
                                If oDados:XPathHasNode(cV8CPath + "/cpfDep")
                                    oModel:LoadValue("MODEL_V8C", "V8C_CPFDEP", FTafGetVal(cV8CPath + "/cpfDep", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV8CPath + "/vlrSaudeDep")
                                    oModel:LoadValue("MODEL_V8C", "V8C_VLRDEP", FTafGetVal(cV8CPath + "/vlrSaudeDep", "N", .F., @aIncons, .F.))
                                EndIf

                                nV8C++
                                cV8CPath    := cV8BPath + "/infoDepSau[" + cValToChar(nV8C) + "]"
                            EndDo

                            nV8B++
                            cV8BPath    := cCabec + "/infoIRComplem/planSaude[" + cValToChar(nV8B) + "]"
                        EndDo

                        nV8D        := 1
                        cV8DPath    := cCabec + "/infoIRComplem/infoReembMed[" + cValToChar(nV8D) + "]"

                        oModelV8D := oModel:GetModel( "MODEL_V8D" )

                        If nOpc == 4 .And. cIndRetif == "2"

                            For nJ := 1 To oModelV8D:Length()
                                oModelV8D:GoLine(nJ)
                                oModelV8D:DeleteLine()
                            Next

                        EndIf

                        While oDados:XPathHasNode(cV8DPath)
                            oModelV8D:lValid:= .T.

                            cChvV8DSequen  := STRZERO(nV8D,6)

                            If !oModelV8D:SeekLine({{"V8D_SEQUEN", cChvV8DSequen}})
                                If !oModelV8D:IsEmpty()
                                    oModelV8D:AddLine()
                                EndIf
                            Else
                                oModelV8D:DeleteLine()
                                oModelV8D:AddLine()
                            EndIf
                            
                            oModel:LoadValue( "MODEL_V8D", "V8D_SEQUEN", cChvV8DSequen )

                            If oDados:XPathHasNode(cV8DPath + "/indOrgReemb")
                                oModel:LoadValue("MODEL_V8D", "V8D_INDREM", FTafGetVal(cV8DPath + "/indOrgReemb", "C", .F., @aIncons, .F.))
                            EndIf

                            If oDados:XPathHasNode(cV8DPath + "/cnpjOper")
                                oModel:LoadValue("MODEL_V8D", "V8D_CNPJOP", FTafGetVal(cV8DPath + "/cnpjOper", "C", .F., @aIncons, .F.))
                            EndIf

                            If oDados:XPathHasNode(cV8DPath + "/regANS")
                                oModel:LoadValue("MODEL_V8D", "V8D_REGANS", FTafGetVal(cV8DPath + "/regANS", "C", .F., @aIncons, .F.))
                            EndIf

                            nV8E        := 1
                            cV8EPath    := cV8DPath + "/detReembTit[" + cValToChar(nV8E) + "]"

                            oModelV8E := oModel:GetModel( "MODEL_V8E" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV8E:Length()
                                    oModelV8E:GoLine(nJ)
                                    oModelV8E:DeleteLine()
                                Next
                            EndIf 

                            While oDados:XPathHasNode(cV8EPath)
                                oModelV8E:lValid:= .T.

                                cChvTpInsc := FTafGetVal(cV8EPath + "/tpInsc", "C", .F., @aIncons, .F.)
                                cChvNrInsc := FTafGetVal(cV8EPath + "/nrInsc", "C", .F., @aIncons, .F.)
                                cChvV8ESequen := cChvV8DSequen

                                If !oModelV8E:SeekLine({{"V8E_TPINSC",cChvTpInsc},{"V8E_NRINSC",cChvNrInsc},{"V8E_SEQUEN",cChvV8ESequen}})
                                    If !oModelV8E:IsEmpty()
                                        oModelV8E:AddLine()
                                    EndIf
                                Else
                                    oModelV8E:DeleteLine()
                                    oModelV8E:AddLine()
                                EndIf
                                
                                oModel:LoadValue( "MODEL_V8E", "V8E_SEQUEN", cChvV8ESequen )

                                If oDados:XPathHasNode(cV8EPath + "/tpInsc")
                                    oModel:LoadValue("MODEL_V8E", "V8E_TPINSC", FTafGetVal(cV8EPath + "/tpInsc", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV8EPath + "/nrInsc")
                                    oModel:LoadValue("MODEL_V8E", "V8E_NRINSC", FTafGetVal(cV8EPath + "/nrInsc", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV8EPath + "/vlrReemb")
                                    oModel:LoadValue("MODEL_V8E", "V8E_VLREMB", FTafGetVal(cV8EPath + "/vlrReemb", "N", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV8EPath + "/vlrReembAnt")
                                    oModel:LoadValue("MODEL_V8E", "V8E_VLRANT", FTafGetVal(cV8EPath + "/vlrReembAnt", "N", .F., @aIncons, .F.))
                                EndIf

                                nV8E++
                                cV8EPath    := cV8DPath + "/detReembTit[" + cValToChar(nV8E) + "]"
                            EndDo 

                            nV8F        := 1
                            cV8FPath    := cV8DPath + "/infoReembDep[" + cValToChar(nV8F) + "]"

                            oModelV8F := oModel:GetModel( "MODEL_V8F" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV8F:Length()
                                    oModelV8F:GoLine(nJ)
                                    oModelV8F:DeleteLine()
                                Next
                            EndIf

                            While oDados:XPathHasNode(cV8FPath)
                                oModelV8F:lValid:= .T.

                                cChvCPFV8F := FTafGetVal(cV8FPath + "/cpfBenef", "C", .F., @aIncons, .F.)
                                cChvV8FSequen := cChvV8DSequen

                                If !oModelV8F:SeekLine({{"V8F_CPFDEP",cChvCPFV8F},{"V8F_SEQUEN",cChvV8FSequen}})
                                    If !oModelV8F:IsEmpty()
                                        oModelV8F:AddLine()
                                    EndIf
                                Else
                                    oModelV8F:DeleteLine()
                                    oModelV8F:AddLine()
                                EndIf
                               
                                oModel:LoadValue( "MODEL_V8F", "V8F_SEQUEN", cChvV8FSequen )
 
                                If oDados:XPathHasNode(cV8FPath + "/cpfBenef")
                                    oModel:LoadValue("MODEL_V8F", "V8F_CPFDEP", FTafGetVal(cV8FPath + "/cpfBenef", "C", .F., @aIncons, .F.))
                                EndIf

                                nV8G        := 1
                                cV8GPath    := cV8FPath + "/detReembDep[" + cValToChar(nV8G) + "]"

                                oModelV8G := oModel:GetModel( "MODEL_V8G" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV8G:Length()
                                        oModelV8G:GoLine(nJ)
                                        oModelV8G:DeleteLine()
                                    Next
                                EndIf

                                While oDados:XPathHasNode(cV8GPath)
                                    oModelV8G:lValid:= .T.

                                    cChvTpEstab := FTafGetVal(cV8GPath + "/tpInsc", "C", .F., @aIncons, .F.)
                                    cChvNrEstab := FTafGetVal(cV8GPath + "/nrInsc", "C", .F., @aIncons, .F.)
                                    cChvV8GSequen := cChvV8DSequen

                                    If !oModelV8G:SeekLine({{"V8G_TPINSC",cChvTpEstab},{"V8G_NRINSC",cChvNrEstab},{"V8G_SEQUEN",cChvV8GSequen}})
                                        If !oModelV8G:IsEmpty()
                                            oModelV8G:AddLine()
                                        EndIf
                                    Else
                                        oModelV8G:DeleteLine()
                                        oModelV8G:AddLine()
                                    EndIf
                                    
                                    oModel:LoadValue( "MODEL_V8G", "V8G_SEQUEN", cChvV8GSequen)

                                    If oDados:XPathHasNode(cV8GPath + "/tpInsc")
                                        oModel:LoadValue("MODEL_V8G", "V8G_TPINSC", FTafGetVal(cV8GPath + "/tpInsc", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV8GPath + "/nrInsc")
                                        oModel:LoadValue("MODEL_V8G", "V8G_NRINSC", FTafGetVal(cV8GPath + "/nrInsc", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV8GPath + "/vlrReemb")
                                        oModel:LoadValue("MODEL_V8G", "V8G_VLREMB", FTafGetVal(cV8GPath + "/vlrReemb", "N", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV8GPath + "/vlrReembAnt")
                                        oModel:LoadValue("MODEL_V8G", "V8G_VLRANT", FTafGetVal(cV8GPath + "/vlrReembAnt", "N", .F., @aIncons, .F.))
                                    EndIf

                                    nV8G++
                                    cV8GPath    := cV8FPath + "/detReembDep[" + cValToChar(nV8G) + "]"
                                EndDo 

                                nV8F++
                                cV8FPath    := cV8DPath + "/infoReembDep[" + cValToChar(nV8F) + "]"
                            EndDo

                            nV8D++
                            cV8DPath    := cCabec + "/infoIRComplem/infoReembMed[" + cValToChar(nV8D) + "]"
                        EndDo 

                    ElseIf lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC")
                    
                        nT8E        := 1
                        cT8EPath    := cCabec + "/infoIRComplem[" + cValToChar(nT8E) + "]"

                        oModelT8E := oModel:GetModel( "MODEL_T8E" )

                        If nOpc == 4 .And. cIndRetif == "2"

                            For nJ := 1 To oModelT8E:Length()
                                oModelT8E:GoLine(nJ)
                                oModelT8E:DeleteLine()
                            Next

                        EndIf

                        While oDados:XPathHasNode(cT8EPath)

                            oModelT8E:lValid:= .T. 

                            cChT8E  := STRZERO(nT8E,2)

                            If !oModelT8E:SeekLine({{"T8E_SEQIRC", cChT8E }})
                                If !oModelT8E:IsEmpty()
                                    oModelT8E:AddLine()
                                EndIf
                            Else
                                oModelT8E:DeleteLine()
                                oModelT8E:AddLine()
                            EndIf


                            If TafXNode(oDados, cCodEvent, cOwner,( cT8EPath + "/dtLaudo"))
                                oModel:LoadValue("MODEL_T8E", "T8E_DTLAUD", FTafGetVal(cT8EPath + "/dtLaudo", "D", .F., @aIncons, .F.))
                            EndIf

                            If TafXNode(oDados, cCodEvent, cOwner,( cT8EPath + "/perAnt/perRefAjuste"))
                                oModel:LoadValue("MODEL_T8E", "T8E_PERREF", StrTran(FTafGetVal(cT8EPath + "/perAnt/perRefAjuste", "C", .F., @aIncons, .F.), "-"))
                            EndIf

                            If TafXNode(oDados, cCodEvent, cOwner,( cT8EPath + "/perAnt/nrRec1210Orig"))
                                
                                T3P->( DbSetOrder( 3 ) )

                                cRecibo := Padr( FTafGetVal( cT8EPath + "/perAnt/nrRec1210Orig", "C", .F., @aIncons, .F. ), TamSx3( "T8E_NRREC" )[1])

                                If FindFunction("FindRecibo") .AND. !T3P->( DBSeek(xFilial("T3P") + cRecibo + "1" ))
                                    cRecibo := FindRecibo(cRecibo, "S-1210")
                                EndIf

                                oModel:LoadValue("MODEL_T8E", "T8E_NRREC", cRecibo )

                            EndIf

                            oModel:LoadValue("MODEL_T8E", "T8E_SEQIRC", cChT8E)
                        
                            oModelV7S := oModel:GetModel( "MODEL_V7S" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV7S:Length()
                                    oModelV7S:GoLine(nJ)
                                    oModelV7S:DeleteLine()
                                Next

                            EndIf

                            nV7S        := 1
                            cV7SPath    := cT8EPath + "/infoDep[" + cValToChar(nV7S) + "]"

                            While oDados:XPathHasNode(cV7SPath)

                                oModelV7S:lValid:= .T. 

                                cChvCPF := FTafGetVal(cV7SPath + "/cpfDep", "C", .F., @aIncons, .F.)

                                If !oModelV7S:SeekLine({{"V7S_CPFDEP", cChvCPF}})
                                    If !oModelV7S:IsEmpty()
                                        oModelV7S:AddLine()
                                    EndIf
                                Else
                                    oModelV7S:DeleteLine()
                                    oModelV7S:AddLine()
                                EndIf

                                If oDados:XPathHasNode(cV7SPath + "/cpfDep")
                                    oModel:LoadValue("MODEL_V7S", "V7S_CPFDEP", FTafGetVal(cV7SPath + "/cpfDep", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV7SPath + "/dtNascto")
                                    oModel:LoadValue("MODEL_V7S", "V7S_DTNASC", FTafGetVal(cV7SPath + "/dtNascto", "D", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV7SPath + "/nome")
                                    oModel:LoadValue("MODEL_V7S", "V7S_NMDEP", FTafGetVal(cV7SPath + "/nome", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV7SPath + "/depIRRF")
                                    oModel:LoadValue("MODEL_V7S", "V7S_DPIRRF", FTafGetVal(cV7SPath + "/depIRRF", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV7SPath + "/tpDep")
                                    oModel:LoadValue("MODEL_V7S", "V7S_TPDEP", FGetIdInt( "tpDep", "", cV7SPath + "/tpDep" ,,,,@cInconMsg, @nSeqErrGrv ))
                                EndIf

                                If oDados:XPathHasNode(cV7SPath + "/descrDep")
                                    oModel:LoadValue("MODEL_V7S", "V7S_DSCDEP", FTafGetVal(cV7SPath + "/descrDep", "C", .F., @aIncons, .F.))
                                EndIf

                                oModel:LoadValue("MODEL_V7S", "V7S_SEQIRC", cChT8E)

                                nV7S++
                                cV7SPath:= cT8EPath + "/infoDep[" + cValToChar(nV7S) + "]"
                            EndDo

                            nV7T        := 1
                            cV7TPath    := cT8EPath + "/infoIRCR[" + cValToChar(nV7T) + "]"

                            oModelV7T := oModel:GetModel( "MODEL_V7T" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV7T:Length()
                                    oModelV7T:GoLine(nJ)
                                    oModelV7T:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV7TPath)

                                oModelV7T:lValid:= .T.

                                cChavTpCr := FGetIdInt( "tpCR", "", cV7TPath + "/tpCR" ,,,,@cInconMsg, @nSeqErrGrv)

                                If !oModelV7T:SeekLine({{"V7T_TPCR", cChavTpCr}})
                                    If !oModelV7T:IsEmpty()
                                        oModelV7T:AddLine()
                                    EndIf
                                Else
                                    oModelV7T:DeleteLine()
                                    oModelV7T:AddLine()
                                EndIf

                                If oDados:XPathHasNode(cV7TPath + "/tpCR")
                                    oModel:LoadValue("MODEL_V7T", "V7T_TPCR", FGetIdInt( "tpCR", "", cV7TPath + "/tpCR" ,,,,@cInconMsg, @nSeqErrGrv))
                                EndIf

                                oModel:LoadValue("MODEL_V7T", "V7T_SEQIRC", cChT8E)

                                nV7U        := 1
                                cV7UPath    := cV7TPath + "/dedDepen[" + cValToChar(nV7U) + "]"

                                oModelV7U := oModel:GetModel( "MODEL_V7U" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV7U:Length()
                                        oModelV7U:GoLine(nJ)
                                        oModelV7U:DeleteLine()
                                    Next

                                EndIf

                                While oDados:XPathHasNode(cV7UPath)
                                    oModelV7U:lValid:= .T.

                                    cChavTpRend := FTafGetVal(cV7UPath + "/tpRend", "C", .F., @aIncons, .F.)
                                    cChavCPFDep := FTafGetVal(cV7UPath + "/cpfDep", "C", .F., @aIncons, .F.)

                                    If !oModelV7U:SeekLine({{"V7U_TPREND", cChavTpRend},{"V7U_CPFDEP",cChavCPFDep}})
                                        If !oModelV7U:IsEmpty()
                                            oModelV7U:AddLine()
                                        EndIf
                                    Else
                                        oModelV7U:DeleteLine()
                                        oModelV7U:AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(cV7UPath + "/tpRend")
                                        oModel:LoadValue("MODEL_V7U", "V7U_TPREND", FTafGetVal(cV7UPath + "/tpRend", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7UPath + "/cpfDep")
                                        oModel:LoadValue("MODEL_V7U", "V7U_CPFDEP", FTafGetVal(cV7UPath + "/cpfDep", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7UPath + "/vlrDedDep")
                                        oModel:LoadValue("MODEL_V7U", "V7U_VLRDED", FTafGetVal(cV7UPath + "/vlrDedDep", "N", .F., @aIncons, .F.))
                                    EndIf 

                                    oModel:LoadValue("MODEL_V7U", "V7U_SEQIRC", cChT8E)

                                    nV7U++
                                    cV7UPath    := cV7TPath + "/dedDepen[" + cValToChar(nV7U) + "]"
                                EndDo

                                nV7V    := 1
                                cV7VPath := cV7TPath + "/penAlim[" + cValToChar(nV7V) + "]"

                                oModelV7V := oModel:GetModel( "MODEL_V7V" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV7V:Length()
                                        oModelV7V:GoLine(nJ)
                                        oModelV7V:DeleteLine()
                                    Next

                                EndIf

                                While oDados:XPathHasNode(cV7VPath)

                                    oModelV7V:lValid:= .T.

                                    cChvTpRend := FTafGetVal(cV7VPath + "/tpRend", "C", .F., @aIncons, .F.)
                                    cChvCPFDep := FTafGetVal(cV7VPath + "/cpfDep", "C", .F., @aIncons, .F.)

                                    If !oModelV7V:SeekLine({{"V7V_TPREND", cChvTpRend},{"V7V_CPFDEP",cChvCPFDep}})
                                        If !oModelV7V:IsEmpty()
                                            oModelV7V:AddLine()
                                        EndIf
                                    Else
                                        oModelV7V:DeleteLine()
                                        oModelV7V:AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(cV7VPath + "/tpRend")
                                        oModel:LoadValue("MODEL_V7V", "V7V_TPREND", FTafGetVal(cV7VPath + "/tpRend", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7VPath + "/cpfDep")
                                        oModel:LoadValue("MODEL_V7V", "V7V_CPFDEP", FTafGetVal(cV7VPath + "/cpfDep", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7VPath + "/vlrDedPenAlim")
                                        oModel:LoadValue("MODEL_V7V", "V7V_VLPEN", FTafGetVal(cV7VPath + "/vlrDedPenAlim", "N", .F., @aIncons, .F.))
                                    EndIf 

                                    oModel:LoadValue("MODEL_V7V", "V7V_SEQIRC", cChT8E)

                                    nV7V++
                                    cV7VPath    := cV7TPath + "/penAlim[" + cValToChar(nV7V) + "]"

                                EndDo

                                nV7W    := 1
                                cV7WPath := cV7TPath + "/previdCompl[" + cValToChar(nV7W) + "]"

                                oModelV7W := oModel:GetModel( "MODEL_V7W" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV7W:Length()
                                        oModelV7W:GoLine(nJ)
                                        oModelV7W:DeleteLine()
                                    Next

                                EndIf

                                While oDados:XPathHasNode(cV7WPath)

                                    oModelV7W:lValid:= .T.

                                    cChvTpPrev := FTafGetVal(cV7WPath + "/tpPrev"     , "C", .F., @aIncons, .F.)
                                    cChcInsCpl := FTafGetVal(cV7WPath + "/cnpjEntidPC", "C", .F., @aIncons, .F.)

                                    If !oModelV7W:SeekLine({{"V7W_TPREV", cChvTpPrev},{"V7W_INSCPL",cChcInsCpl}})
                                        If !oModelV7W:IsEmpty()
                                            oModelV7W:AddLine()
                                        EndIf
                                    Else
                                        oModelV7W:DeleteLine()
                                        oModelV7W:AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(cV7WPath + "/tpPrev")
                                        oModel:LoadValue("MODEL_V7W", "V7W_TPREV", FTafGetVal(cV7WPath + "/tpPrev", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7WPath + "/cnpjEntidPC")
                                        oModel:LoadValue("MODEL_V7W", "V7W_INSCPL", FTafGetVal(cV7WPath + "/cnpjEntidPC", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7WPath + "/vlrDedPC13")
                                        oModel:LoadValue("MODEL_V7W", "V7W_VLDEP1", FTafGetVal(cV7WPath + "/vlrDedPC13", "N", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7WPath + "/vlrDedPC")
                                        oModel:LoadValue("MODEL_V7W", "V7W_VLCOMP", FTafGetVal(cV7WPath + "/vlrDedPC", "N", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7WPath + "/vlrPatrocFunp")
                                        oModel:LoadValue("MODEL_V7W", "V7W_VLPATR", FTafGetVal(cV7WPath + "/vlrPatrocFunp", "N", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7WPath + "/vlrPatrocFunp13")
                                        oModel:LoadValue("MODEL_V7W", "V7W_VLPA13", FTafGetVal(cV7WPath + "/vlrPatrocFunp13", "N", .F., @aIncons, .F.))
                                    EndIf 

                                    oModel:LoadValue("MODEL_V7W", "V7W_SEQIRC", cChT8E)

                                    nV7W++
                                    cV7WPath    := cV7TPath + "/previdCompl[" + cValToChar(nV7W) + "]"

                                EndDo

                                nV7X    := 1
                                cV7XPath := cV7TPath + "/infoProcRet[" + cValToChar(nV7X) + "]"

                                oModelV7X := oModel:GetModel( "MODEL_V7X" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV7X:Length()
                                        oModelV7X:GoLine(nJ)
                                        oModelV7X:DeleteLine()
                                    Next

                                EndIf

                                While oDados:XPathHasNode(cV7XPath)

                                    oModelV7X:lValid:= .T.

                                    cChvTpProc  := FTafGetVal(cV7XPath + "/tpProcRet", "C", .F., @aIncons, .F.)
                                    cChcNrProc  := FTafGetVal(cV7XPath + "/nrProcRet", "C", .F., @aIncons, .F.)
                                    cChcCodSusp := FTafGetVal(cV7XPath + "/codSusp"  , "C", .F., @aIncons, .F.)

                                    If !oModelV7X:SeekLine({{"V7X_TPPROC", cChvTpProc},{"V7X_NRPROC",cChcNrProc},{"V7X_CODSUP",cChcCodSusp}})

                                        If !oModelV7X:IsEmpty()
                                            oModelV7X:AddLine()
                                        EndIf

                                    Else
                                        oModelV7X:DeleteLine()
                                        oModelV7X:AddLine()
                                    EndIf

                                    If oDados:XPathHasNode(cV7XPath + "/tpProcRet")
                                        oModel:LoadValue("MODEL_V7X", "V7X_TPPROC", FTafGetVal(cV7XPath + "/tpProcRet", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7XPath + "/nrProcRet")
                                        oModel:LoadValue("MODEL_V7X", "V7X_NRPROC", FTafGetVal(cV7XPath + "/nrProcRet", "C", .F., @aIncons, .F.))
                                    EndIf 

                                    If oDados:XPathHasNode(cV7XPath + "/codSusp")
                                        oModel:LoadValue("MODEL_V7X", "V7X_CODSUP", FTafGetVal(cV7XPath + "/codSusp", "C", .F., @aIncons, .F.))
                                    EndIf

                                    oModel:LoadValue("MODEL_V7X", "V7X_SEQIRC", cChT8E)

                                    nV7Y    := 1
                                    cV7YPath := cV7XPath + "/infoValores[" + cValToChar(nV7Y) + "]"

                                    oModelV7Y := oModel:GetModel( "MODEL_V7Y" )

                                    If nOpc == 4 .And. cIndRetif == "2"

                                        For nJ := 1 To oModelV7Y:Length()
                                            oModelV7Y:GoLine(nJ)
                                            oModelV7Y:DeleteLine()
                                        Next

                                    EndIf

                                    While oDados:XPathHasNode(cV7YPath)

                                        oModelV7Y:lValid:= .T.

                                        cChvIndApu  := FTafGetVal(cV7YPath + "/indApuracao", "C", .F., @aIncons, .F.)

                                        If !oModelV7Y:SeekLine({{"V7Y_INDAPU", cChvIndApu}})

                                            If !oModelV7Y:IsEmpty()
                                                oModelV7Y:AddLine()
                                            EndIf

                                        Else
                                            oModelV7Y:DeleteLine()
                                            oModelV7Y:AddLine()
                                        EndIf

                                        If oDados:XPathHasNode(cV7YPath + "/indApuracao")
                                            oModel:LoadValue("MODEL_V7Y", "V7Y_INDAPU", FTafGetVal(cV7YPath + "/indApuracao", "C", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7YPath + "/vlrNRetido")
                                            oModel:LoadValue("MODEL_V7Y", "V7Y_VLRRET", FTafGetVal(cV7YPath + "/vlrNRetido", "N", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7YPath + "/vlrDepJud")
                                            oModel:LoadValue("MODEL_V7Y", "V7Y_VLRJUD", FTafGetVal(cV7YPath + "/vlrDepJud", "N", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7YPath + "/vlrCmpAnoCal")
                                            oModel:LoadValue("MODEL_V7Y", "V7Y_VLACAL", FTafGetVal(cV7YPath + "/vlrCmpAnoCal", "N", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7YPath + "/vlrCmpAnoAnt")
                                            oModel:LoadValue("MODEL_V7Y", "V7Y_VLAANT", FTafGetVal(cV7YPath + "/vlrCmpAnoAnt", "N", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV7YPath + "/vlrRendSusp")
                                            oModel:LoadValue("MODEL_V7Y", "V7Y_VLSUSP", FTafGetVal(cV7YPath + "/vlrRendSusp", "N", .F., @aIncons, .F.))
                                        EndIf

                                        oModel:LoadValue("MODEL_V7Y", "V7Y_SEQIRC", cChT8E)

                                        nV7Z     := 1
                                        cV7ZPath := cV7YPath + "/dedSusp[" + cValToChar(nV7Z) + "]"

                                        oModelV7Z := oModel:GetModel( "MODEL_V7Z" )

                                        If nOpc == 4 .And. cIndRetif == "2"

                                            For nJ := 1 To oModelV7Z:Length()
                                                oModelV7Z:GoLine(nJ)
                                                oModelV7Z:DeleteLine()
                                            Next
                                        EndIf

                                        While oDados:XPathHasNode(cV7ZPath)

                                            oModelV7Z:lValid:= .T.

                                            cChvV7ZSequen  := STRZERO(nV7Z,6)

                                            If !oModelV7Z:SeekLine({{"V7Z_SEQUEN", cChvV7ZSequen}})

                                                If !oModelV7Z:IsEmpty()
                                                    oModelV7Z:AddLine()
                                                EndIf

                                            Else
                                                oModelV7Z:DeleteLine()
                                                oModelV7Z:AddLine()
                                            EndIf
                                            
                                            oModel:LoadValue( "MODEL_V7Z", "V7Z_SEQUEN", cChvV7ZSequen )

                                            If oDados:XPathHasNode(cV7ZPath + "/indTpDeducao")
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_TPDEDU", FTafGetVal(cV7ZPath + "/indTpDeducao", "C", .F., @aIncons, .F.))
                                            EndIf

                                            If oDados:XPathHasNode(cV7ZPath + "/vlrDedSusp")
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_VLSUSP", FTafGetVal(cV7ZPath + "/vlrDedSusp", "N", .F., @aIncons, .F.))
                                            EndIf

                                            If oDados:XPathHasNode(cV7ZPath + "/cnpjEntidPC")
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_INSCPL", FTafGetVal(cV7ZPath + "/cnpjEntidPC", "C", .F., @aIncons, .F.))
                                            EndIf

                                            If oDados:XPathHasNode(cV7ZPath + "/vlrPatrocFunp")
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_VLFUNP", FTafGetVal(cV7ZPath + "/vlrPatrocFunp", "N", .F., @aIncons, .F.))
                                            EndIf

                                            oModel:LoadValue("MODEL_V7Z", "V7Z_SEQIRC", cChT8E)

                                            nV8A     := 1
                                            cV8APath := cV7ZPath + "/benefPen[" + cValToChar(nV8A) + "]"

                                            oModelV8A := oModel:GetModel( "MODEL_V8A" )

                                            If nOpc == 4 .And. cIndRetif == "2"

                                                For nJ := 1 To oModelV8A:Length()
                                                    oModelV8A:GoLine(nJ)
                                                    oModelV8A:DeleteLine()
                                                Next
                                            EndIf

                                            While oDados:XPathHasNode(cV8APath)

                                                oModelV8A:lValid:= .T.

                                                cChvCPFV8A := FTafGetVal(cV8APath + "/cpfDep", "C", .F., @aIncons, .F.)
                                                cChvV8ASequen := cChvV7ZSequen

                                                If !oModelV8A:SeekLine({{"V8A_CPFDEP",cChvCPFV8A},{"V8A_SEQUEN",cChvV8ASequen}})
                                                    If !oModelV8A:IsEmpty()
                                                        oModelV8A:AddLine()
                                                    EndIf
                                                Else
                                                    oModelV8A:DeleteLine()
                                                    oModelV8A:AddLine()
                                                EndIf
        
                                                oModel:LoadValue( "MODEL_V8A", "V8A_SEQUEN", cChvV8ASequen )

                                                If oDados:XPathHasNode(cV8APath + "/cpfDep")
                                                    oModel:LoadValue("MODEL_V8A", "V8A_CPFDEP", FTafGetVal(cV8APath + "/cpfDep", "C", .F., @aIncons, .F.))
                                                EndIf

                                                If oDados:XPathHasNode(cV8APath + "/vlrDepenSusp")
                                                    oModel:LoadValue("MODEL_V8A", "V8A_VLSUSP", FTafGetVal(cV8APath + "/vlrDepenSusp", "N", .F., @aIncons, .F.))
                                                EndIf

                                                oModel:LoadValue("MODEL_V8A", "V8A_SEQIRC", cChT8E)

                                                nV8A++
                                                cV8APath := cV7ZPath + "/benefPen[" + cValToChar(nV8A) + "]"

                                            EndDo

                                            nV7Z++
                                            cV7ZPath := cV7YPath + "/dedSusp[" + cValToChar(nV7Z) + "]"

                                        EndDo 

                                        nV7Y++
                                        cV7YPath := cV7XPath + "/infoValores[" + cValToChar(nV7Y) + "]"

                                    EndDo 

                                    nV7X++
                                    cV7XPath    := cV7TPath + "/infoProcRet[" + cValToChar(nV7X) + "]"

                                EndDo

                                nV7T++
                                cV7TPath:= cT8EPath + "/infoIRCR[" + cValToChar(nV7T) + "]"

                            EndDo 

                            nV8B        := 1
                            cV8BPath    := cT8EPath + "/planSaude[" + cValToChar(nV8B) + "]"

                            oModelV8B := oModel:GetModel( "MODEL_V8B" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV8B:Length()
                                    oModelV8B:GoLine(nJ)
                                    oModelV8B:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV8BPath)

                                oModelV8B:lValid:= .T.

                                If TAFColumnPos("V8B_SEQUEN")
                                    cChvV8BSequen  := STRZERO(nV8B,3)

                                    If !oModelV8B:SeekLine({{"V8B_SEQUEN",cChvV8BSequen}})

                                        If !oModelV8B:IsEmpty()
                                            oModelV8B:AddLine()
                                        EndIf

                                    Else
                                        oModelV8B:DeleteLine()
                                        oModelV8B:AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_V8B", "V8B_SEQUEN", cChvV8BSequen )

                                Else

                                    // Mantido pois não da erro quando não cnpjOper diferentes 
                                    cChvCnpjOp := FTafGetVal(cV8BPath + "/cnpjOper", "C", .F., @aIncons, .F.)
        
                                    If !oModelV8B:SeekLine({{"V8B_CNPJOP",cChvCnpjOp}})

                                        If !oModelV8B:IsEmpty()
                                            oModelV8B:AddLine()
                                        EndIf

                                    Else
                                        oModelV8B:DeleteLine()
                                        oModelV8B:AddLine()
                                    EndIf
                                EndIf 

                                If oDados:XPathHasNode(cV8BPath + "/cnpjOper")
                                    oModel:LoadValue("MODEL_V8B", "V8B_CNPJOP", FTafGetVal(cV8BPath + "/cnpjOper", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV8BPath + "/regANS")
                                    oModel:LoadValue("MODEL_V8B", "V8B_REGANS", FTafGetVal(cV8BPath + "/regANS", "C", .F., @aIncons, .F.))
                                EndIf 

                                If oDados:XPathHasNode(cV8BPath + "/vlrSaudeTit")
                                    oModel:LoadValue("MODEL_V8B", "V8B_VLRTIT", FTafGetVal(cV8BPath + "/vlrSaudeTit", "N", .F., @aIncons, .F.))
                                EndIf 

                                oModel:LoadValue("MODEL_V8B", "V8B_SEQIRC", cChT8E)

                                nV8C        := 1
                                cV8CPath    := cV8BPath + "/infoDepSau[" + cValToChar(nV8C) + "]"

                                oModelV8C := oModel:GetModel( "MODEL_V8C" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV8C:Length()
                                        oModelV8C:GoLine(nJ)
                                        oModelV8C:DeleteLine()
                                    Next

                                EndIf

                                While oDados:XPathHasNode(cV8CPath)

                                    oModelV8C:lValid:= .T.

                                    cChvCPFV8C := FTafGetVal(cV8CPath + "/cpfDep", "C", .F., @aIncons, .F.)

                                    If TAFColumnPos("V8B_SEQUEN")

                                        If !oModelV8C:SeekLine({{"V8C_CPFDEP",cChvCPFV8C},{"V8C_SEQUEN",cChvV8BSequen}})

                                            If !oModelV8C:IsEmpty()
                                                oModelV8C:AddLine()
                                            EndIf

                                        Else
                                            oModelV8C:DeleteLine()
                                            oModelV8C:AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_V8C", "V8C_SEQUEN", cChvV8BSequen )

                                    Else 
                                        If !oModelV8C:SeekLine({{"V8C_CPFDEP",cChvCPFV8C}})

                                            If !oModelV8C:IsEmpty()
                                                oModelV8C:AddLine()
                                            EndIf

                                        Else
                                            oModelV8C:DeleteLine()
                                            oModelV8C:AddLine()
                                        EndIf
                                    EndIf 
                                    
                                    If oDados:XPathHasNode(cV8CPath + "/cpfDep")
                                        oModel:LoadValue("MODEL_V8C", "V8C_CPFDEP", FTafGetVal(cV8CPath + "/cpfDep", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV8CPath + "/vlrSaudeDep")
                                        oModel:LoadValue("MODEL_V8C", "V8C_VLRDEP", FTafGetVal(cV8CPath + "/vlrSaudeDep", "N", .F., @aIncons, .F.))
                                    EndIf

                                    oModel:LoadValue("MODEL_V8C", "V8C_SEQIRC", cChT8E)

                                    nV8C++
                                    cV8CPath    := cV8BPath + "/infoDepSau[" + cValToChar(nV8C) + "]"

                                EndDo

                                nV8B++
                                cV8BPath    := cT8EPath + "/planSaude[" + cValToChar(nV8B) + "]"

                            EndDo

                            nV8D        := 1
                            cV8DPath    := cT8EPath + "/infoReembMed[" + cValToChar(nV8D) + "]"

                            oModelV8D := oModel:GetModel( "MODEL_V8D" )

                            If nOpc == 4 .And. cIndRetif == "2"

                                For nJ := 1 To oModelV8D:Length()
                                    oModelV8D:GoLine(nJ)
                                    oModelV8D:DeleteLine()
                                Next

                            EndIf

                            While oDados:XPathHasNode(cV8DPath)

                                oModelV8D:lValid:= .T.

                                cChvV8DSequen  := STRZERO(nV8D,6)

                                If !oModelV8D:SeekLine({{"V8D_SEQUEN", cChvV8DSequen}})
                                    If !oModelV8D:IsEmpty()
                                        oModelV8D:AddLine()
                                    EndIf
                                Else
                                    oModelV8D:DeleteLine()
                                    oModelV8D:AddLine()
                                EndIf
                                
                                oModel:LoadValue( "MODEL_V8D", "V8D_SEQUEN", cChvV8DSequen )

                                If oDados:XPathHasNode(cV8DPath + "/indOrgReemb")
                                    oModel:LoadValue("MODEL_V8D", "V8D_INDREM", FTafGetVal(cV8DPath + "/indOrgReemb", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV8DPath + "/cnpjOper")
                                    oModel:LoadValue("MODEL_V8D", "V8D_CNPJOP", FTafGetVal(cV8DPath + "/cnpjOper", "C", .F., @aIncons, .F.))
                                EndIf

                                If oDados:XPathHasNode(cV8DPath + "/regANS")
                                    oModel:LoadValue("MODEL_V8D", "V8D_REGANS", FTafGetVal(cV8DPath + "/regANS", "C", .F., @aIncons, .F.))
                                EndIf

                                oModel:LoadValue("MODEL_V8D", "V8D_SEQIRC", cChT8E)

                                nV8E        := 1
                                cV8EPath    := cV8DPath + "/detReembTit[" + cValToChar(nV8E) + "]"

                                oModelV8E := oModel:GetModel( "MODEL_V8E" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV8E:Length()
                                        oModelV8E:GoLine(nJ)
                                        oModelV8E:DeleteLine()
                                    Next
                                EndIf 

                                While oDados:XPathHasNode(cV8EPath)

                                    oModelV8E:lValid:= .T.

                                    cChvTpInsc := FTafGetVal(cV8EPath + "/tpInsc", "C", .F., @aIncons, .F.)
                                    cChvNrInsc := FTafGetVal(cV8EPath + "/nrInsc", "C", .F., @aIncons, .F.)
                                    cChvV8ESequen := cChvV8DSequen

                                    If !oModelV8E:SeekLine({{"V8E_TPINSC",cChvTpInsc},{"V8E_NRINSC",cChvNrInsc},{"V8E_SEQUEN",cChvV8ESequen}})

                                        If !oModelV8E:IsEmpty()
                                            oModelV8E:AddLine()
                                        EndIf

                                    Else
                                        oModelV8E:DeleteLine()
                                        oModelV8E:AddLine()
                                    EndIf
                                    
                                    oModel:LoadValue( "MODEL_V8E", "V8E_SEQUEN", cChvV8ESequen )

                                    If oDados:XPathHasNode(cV8EPath + "/tpInsc")
                                        oModel:LoadValue("MODEL_V8E", "V8E_TPINSC", FTafGetVal(cV8EPath + "/tpInsc", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV8EPath + "/nrInsc")
                                        oModel:LoadValue("MODEL_V8E", "V8E_NRINSC", FTafGetVal(cV8EPath + "/nrInsc", "C", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV8EPath + "/vlrReemb")
                                        oModel:LoadValue("MODEL_V8E", "V8E_VLREMB", FTafGetVal(cV8EPath + "/vlrReemb", "N", .F., @aIncons, .F.))
                                    EndIf

                                    If oDados:XPathHasNode(cV8EPath + "/vlrReembAnt")
                                        oModel:LoadValue("MODEL_V8E", "V8E_VLRANT", FTafGetVal(cV8EPath + "/vlrReembAnt", "N", .F., @aIncons, .F.))
                                    EndIf

                                    oModel:LoadValue("MODEL_V8E", "V8E_SEQIRC", cChT8E)

                                    nV8E++
                                    cV8EPath    := cV8DPath + "/detReembTit[" + cValToChar(nV8E) + "]"
                                EndDo 

                                nV8F        := 1
                                cV8FPath    := cV8DPath + "/infoReembDep[" + cValToChar(nV8F) + "]"

                                oModelV8F := oModel:GetModel( "MODEL_V8F" )

                                If nOpc == 4 .And. cIndRetif == "2"

                                    For nJ := 1 To oModelV8F:Length()
                                        oModelV8F:GoLine(nJ)
                                        oModelV8F:DeleteLine()
                                    Next
                                EndIf

                                While oDados:XPathHasNode(cV8FPath)

                                    oModelV8F:lValid:= .T.

                                    cChvCPFV8F := FTafGetVal(cV8FPath + "/cpfBenef", "C", .F., @aIncons, .F.)
                                    cChvV8FSequen := cChvV8DSequen

                                    If !oModelV8F:SeekLine({{"V8F_CPFDEP",cChvCPFV8F},{"V8F_SEQUEN",cChvV8FSequen}})

                                        If !oModelV8F:IsEmpty()
                                            oModelV8F:AddLine()
                                        EndIf

                                    Else
                                        oModelV8F:DeleteLine()
                                        oModelV8F:AddLine()
                                    EndIf
                                
                                    oModel:LoadValue( "MODEL_V8F", "V8F_SEQUEN", cChvV8FSequen )
                                    oModel:LoadValue( "MODEL_V8F", "V8F_SEQIRC", cChT8E)
    
                                    If oDados:XPathHasNode(cV8FPath + "/cpfBenef")
                                        oModel:LoadValue("MODEL_V8F", "V8F_CPFDEP", FTafGetVal(cV8FPath + "/cpfBenef", "C", .F., @aIncons, .F.))
                                    EndIf

                                    nV8G        := 1
                                    cV8GPath    := cV8FPath + "/detReembDep[" + cValToChar(nV8G) + "]"

                                    oModelV8G := oModel:GetModel( "MODEL_V8G" )

                                    If nOpc == 4 .And. cIndRetif == "2"

                                        For nJ := 1 To oModelV8G:Length()
                                            oModelV8G:GoLine(nJ)
                                            oModelV8G:DeleteLine()
                                        Next

                                    EndIf

                                    While oDados:XPathHasNode(cV8GPath)

                                        oModelV8G:lValid:= .T.

                                        cChvTpEstab := FTafGetVal(cV8GPath + "/tpInsc", "C", .F., @aIncons, .F.)
                                        cChvNrEstab := FTafGetVal(cV8GPath + "/nrInsc", "C", .F., @aIncons, .F.)
                                        cChvV8GSequen := cChvV8DSequen

                                        If !oModelV8G:SeekLine({{"V8G_TPINSC",cChvTpEstab},{"V8G_NRINSC",cChvNrEstab},{"V8G_SEQUEN",cChvV8GSequen}})
                                            If !oModelV8G:IsEmpty()
                                                oModelV8G:AddLine()
                                            EndIf
                                        Else
                                            oModelV8G:DeleteLine()
                                            oModelV8G:AddLine()
                                        EndIf
                                        
                                        oModel:LoadValue( "MODEL_V8G", "V8G_SEQUEN", cChvV8GSequen)

                                        If oDados:XPathHasNode(cV8GPath + "/tpInsc")
                                            oModel:LoadValue("MODEL_V8G", "V8G_TPINSC", FTafGetVal(cV8GPath + "/tpInsc", "C", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV8GPath + "/nrInsc")
                                            oModel:LoadValue("MODEL_V8G", "V8G_NRINSC", FTafGetVal(cV8GPath + "/nrInsc", "C", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV8GPath + "/vlrReemb")
                                            oModel:LoadValue("MODEL_V8G", "V8G_VLREMB", FTafGetVal(cV8GPath + "/vlrReemb", "N", .F., @aIncons, .F.))
                                        EndIf

                                        If oDados:XPathHasNode(cV8GPath + "/vlrReembAnt")
                                            oModel:LoadValue("MODEL_V8G", "V8G_VLRANT", FTafGetVal(cV8GPath + "/vlrReembAnt", "N", .F., @aIncons, .F.))
                                        EndIf

                                        oModel:LoadValue( "MODEL_V8G", "V8G_SEQIRC", cChT8E)

                                        nV8G++
                                        cV8GPath    := cV8FPath + "/detReembDep[" + cValToChar(nV8G) + "]"
                                    EndDo 

                                    nV8F++
                                    cV8FPath    := cV8DPath + "/infoReembDep[" + cValToChar(nV8F) + "]"
                                EndDo

                                nV8D++
                                cV8DPath    := cT8EPath + "/infoReembMed[" + cValToChar(nV8D) + "]"
                            EndDo

                            nT8E++
                            cT8EPath    := cCabec + "/infoIRComplem[" + cValToChar(nT8E) + "]"
                            
                        EndDo 

                    EndIf 

                EndIf

            EndIf

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Efetiva a operacao desejada³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                            
            If Empty(cInconMsg) .And. Empty(aIncons)

                xChkDupl := TafFormCommit( oModel, .T. )

                If ValType( xChkDupl ) == "A"

                    If xChkDupl[1]
                        Aadd(aIncons, "ERRO19" + "|" + xChkDupl[2] + "|" + xChkDupl[3])
                    Else
                        lRet := .T.
                    EndIf

                ElseIf ValType( xChkDupl ) == "L"

                    If xChkDupl
                        Aadd(aIncons, "ERRO19" )
                    Else
                        lRet := .T.
                    EndIf
                    
                EndIf

            Else

                Aadd(aIncons, cInconMsg)
                DisarmTransaction()

            EndIf

            oModel:DeActivate()
            TafClearModel(oModel)

        EndIf

    End Transaction

	//Zerando os arrays e os Objetos utilizados no processamento
	aSize( aRulesCad, 0 )
	aRulesCad := Nil

	aSize( aChave, 0 )
	aChave := Nil

    If cFilant != cClone .AND. lOneOne
        cFilant := cClone
    EndIf

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Rul
Regras para gravacao das informacoes do registro S-2365

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF407Rul( cCabec as Character, cInconMsg as Character, nSeqErrGrv as Numeric, cCodEvent as Character, cOwner as Character, lExistTrab as Logical, cMatrC9V as Character, cBenef as Character)

	Local aRull        as Array
	Local cPeriodo     as Character
    Local lLayout12    as Logical

	Default cCabec     := ""
	Default cInconMsg  := ""
	Default nSeqErrGrv := 0
	Default cCodEvent  := ""
	Default cOwner     := ""
	Default cBenef     := ""
	Default lExistTrab := .F.

    aRull    := {}
	cPeriodo := ""
    lLayout12  := lSimpl12 .and. TafColumnPos("V8G_NRINSC")

	//**********************************
	//eSocial/evtPgtos/ideEvento/
	//**********************************
    If !lLaySimplif

        If TafXNode(oDados, cCodEvent, cOwner, "/eSocial/evtPgtos/ideEvento/indApuracao")
            Aadd(aRull, {"T3P_INDAPU", "/eSocial/evtPgtos/ideEvento/indApuracao", "C", .F.})
        EndIf

    EndIf

	If TafXNode(oDados, cCodEvent, cOwner, "/eSocial/evtPgtos/ideEvento/perApur")
		cPeriodo := FTafGetVal("/eSocial/evtPgtos/ideEvento/perApur", "C", .F.,, .F.)
		Aadd(aRull, {"T3P_PERAPU", StrTran(cPeriodo, "-", "") ,"C", .T.})
	EndIf

    If lLaySimplif

        If TafXNode(oDados, cCodEvent, cOwner, "/eSocial/evtPgtos/ideEvento/indGuia")
            Aadd(aRull, {"T3P_TPGUIA", "/eSocial/evtPgtos/ideEvento/indGuia", "C", .F.})
        EndIf

    EndIf

	//**********************************
	//eSocial/evtPgtos/ideBenef/cpfBenef
	//**********************************
	If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtPgtos/ideBenef/cpfBenef" ) )
		//*****************************************************************************************************************************************
		//a tag de referencia para buscar o id do beneficiario neste caso é o cpfTrab, pois o trabalhador é considerado o beneficiario de pagamento
		//*****************************************************************************************************************************************

		If lExistTrab
			Aadd( aRull, {"T3P_BENEFI", cBenef, "C", .T. } )   		//cpfBenef
            If lLaySimplif
                Aadd( aRull, {"T3P_CPF", "/eSocial/evtPgtos/ideBenef/cpfBenef","C",.F.} )
            EndIf
		Else
			Aadd( aRull, {"T3P_CPF", "/eSocial/evtPgtos/ideBenef/cpfBenef","C",.F.} )
		EndIf

	EndIf

    If !lLaySimplif

        If TafXNode( oDados, cCodEvent, cOwner,( "/eSocial/evtPgtos/ideBenef/deps/vrDedDep" ) )
            Aadd( aRull, {"T3P_VLDEDB", "/eSocial/evtPgtos/ideBenef/deps/vrDedDep", "N", .F. } )   		//vrDedDep
        EndIf

    EndIf

    If lLayout12
        If TafXNode(oDados, cCodEvent, cOwner,( "/eSocial/evtPgtos/ideBenef/infoIRComplem/dtLaudo"))
            Aadd( aRull, {"T3P_DTLAUD", "/eSocial/evtPgtos/ideBenef/infoIRComplem/dtLaudo", "D", .F. } )
        EndIf 
    EndIf

Return aRull

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Xml
Retorna o Xml do Registro Posicionado

@author Vitor Siqueira
@since 29/12/2015
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-1210
/*/
//-------------------------------------------------------------------
Function TAF407Xml(cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical)

    Local aMensal       as Array
	Local cPerRef       as Character
	Local cNrRecArq     as Character
    Local cCodRubr      as Character
    Local cTabRubric    as Character
    Local cRubrica      as Character
	Local cXml          as Character
    Local cXmlAux       as Character
	Local cXmlIdePais   as Character
	Local cXmlEndExt    as Character
	Local cC8R_IDTBRU   as Character
	Local cCpfBenefi    as Character
	Local cIdBenefi     as Character
	Local cLayout       as Character
	Local cReg          as Character
	Local cFilBkp       as Character
	Local cMVIDETABR    as Character
    Local cChvSeekV8B   as Character
    Local cChvV8B       as Character
    Local cChvV8C       as Character
	Local lInfo1210     as Logical
	Local lRubERPPad    as Logical
	Local lDicAtu       as Logical
	Local lXmlVLd       as Logical
    Local lLayout12     as Logical
	Local nTamQtdDias   as Numeric
    Local nPosRubric    as Numeric

	Default cAlias      := "T3P"
	Default lJob        := .F.
	Default nRecno      := 1
	Default nOpc        := 1

    aMensal     := {}
	cPerRef     := ""
	cNrRecArq   := ""
    cCodRubr    := ""
    cTabRubric  := ""
    cRubrica    := ""
	cXml        := ""
    cXmlAux     := ""
	cXmlIdePais := ""
	cXmlEndExt  := ""
	cC8R_IDTBRU := ""
	cCpfBenefi  := ""
	cIdBenefi   := ""
    cChvSeekV8B := ""
    cChvV8B     := ""
    cChvV8C     := ""
	cLayout     := "1210"
	cReg        := "Pgtos"
	cFilBkp     := cFilAnt
	cMVIDETABR  := SuperGetMV("MV_IDETABR", .F., "0")
	lInfo1210   := .F.
	lRubERPPad  := .T.
	lDicAtu     := .T.
	lXmlVLd     := IIf(FindFunction("TafXmlVLD"), TafXmlVLD("TAF407XML"), .T.)
	nTamQtdDias := 0
    nPosRubric  := 0
    lLayout12   := lSimpl12 .and. TAFColumnPos("V8G_NRINSC")

	If lXmlVLd

        If !lLaySimplif

            If IsInCallStack("TAFA407") .And. (IsInCalLStack("TAFXmlLote") .Or. IsInCallStack("TAF407Xml"))

                If __lRubPad == Nil

                    lRubERPPad := cMVIDETABR == "1" .Or. (cMVIDETABR == "0" .And. ApMsgYesNo(STR0035 + CRLF + STR0036 + CRLF + STR0037, STR0038)) // "Deseja gerar o conteúdo da tag 'ideTabRubr' com o código padrão deste ERP ou conforme ERP de Origem?" // " - Sim para código padrão (T3M_ID)." // " - Não para conforme ERP de Origem (T3M_CODERP)." // "Conteúdo 'ideTabRubr' padrão?"
                    
                    If IsInCalLStack("TAFXmlLote")
                        __lRubPad := lRubERPPad
                    EndIf

                Else

                    lRubERPPad := __lRubPad

                EndIf

            EndIf

        EndIf

		If IsInCallStack("TafNewBrowse") .And. ( T3P->T3P_FILIAL <> cFilAnt )
			cFilAnt := T3P->T3P_FILIAL
		EndIf
        
		If !lLaySimplif
        
            If T3P->T3P_INDAPU == '1'

                aAdd(aMensal, T3P->T3P_INDAPU)

                If Len(Alltrim(T3P->T3P_PERAPU)) <= 4
                    aAdd(aMensal, T3P->T3P_PERAPU)
                Else
                    aAdd(aMensal, SubStr(T3P->T3P_PERAPU, 1, 4) + '-' + SubStr(T3P->T3P_PERAPU, 5, 2))
                EndIf

            EndIf
        
        Else

			If Len(Alltrim(T3P->T3P_PERAPU)) <= 4
				aAdd(aMensal, T3P->T3P_PERAPU)
			Else
				aAdd(aMensal, SubStr(T3P->T3P_PERAPU, 1, 4) + '-' + SubStr(T3P->T3P_PERAPU, 5, 2))
			EndIf

		EndIf

		If Empty(T3P->T3P_BENEFI)
			lInfo1210 := .T.
		EndIf

		cXml +=	"<ideBenef>"

		If !lInfo1210

            If TafColumnPos("T3P_ORIEVE") .And. T3P->T3P_ORIEVE == 'S2400'
			    cXml += xTafTag( "cpfBenef" , POSICIONE( "V73" , 4 , xFilial( "V73" ) + T3P->T3P_BENEFI , "V73_CPFBEN" ) )
            ElseIf T3P->T3P_ORIEVE $ 'S2200|S2300|TAUTO' .Or. T3P->T3P_TRABEV == 'TAUTO'
                cXml += xTafTag( "cpfBenef" , POSICIONE( "C9V" , 1 , xFilial( "C9V" ) + T3P->T3P_BENEFI , "C9V_CPF" ) )
            Else
                cXml += xTafTag( "cpfBenef" , POSICIONE( "T3A" , 3 , xFilial( "T3A" ) + T3P->T3P_BENEFI , "T3A_CPF" ) )
            EndIf

		Else

			cXml += xTafTag( "cpfBenef" , T3P->T3P_CPF )

		EndIf

        If !lLaySimplif

            If T3P->T3P_VLDEDB > 0

                If __cPicVlDe == Nil
                    __cPicVlDe := PesqPict("T3P", "T3P_VLDEDB")
                EndIf
                
                cXml +=	"<deps>"
                cXml +=	xTafTag("vrDedDep", T3P->T3P_VLDEDB, __cPicVlDe, .F.,, .T.) 
                cXml +=	"</deps>"

            EndIf

            DBSelectArea("T5Y")
            T5Y->(DBSetOrder(2)) //T5Y_FILIAL+T5Y_ID+T5Y_VERSAO+DTOS(T5Y_DTPGTO)+T5Y_TPPGTO+T5Y_IDCATE+DTOS(T5Y_DTINIG)+T5Y->T5Y_QTDIAS+T5Y->T5Y_MATRIC

            // Verifica se o índice 2da tabela T5Y está correto
            // Caso não esteja, é necessário atualizar o dicionário
            If "+T5Y_MATRIC+T5Y_IDRUBR" $ T5Y->(IndexKey( T5Y->(indexOrd()) ))  //T5Y_FILIAL+T5Y_ID+T5Y_VERSAO+DTOS(T5Y_DTPGTO)+T5Y_TPPGTO+T5Y_IDCATE+DTOS(T5Y_DTINIG)+STR(T5Y_QTDIAS)+T5Y_MATRIC+T5Y_IDRUBR

                DBSelectArea("T3Q")
                T3Q->(DBSetOrder(1))

                If T3Q->( MsSeek( xFilial( "T3Q" ) + T3P->T3P_ID + T3P->T3P_VERSAO ) )

                    DBSelectArea("CMD")
                    CMD->(DBSetOrder(2))

                    DBSelectArea("T92")
                    T92->(DBSetOrder(3))

                    DBSelectArea("T3R")
                    T3R->(DBSetOrder(1))  //T3R_FILIAL+T3R_ID+T3R_VERSAO+DTOS(T3R_DTPGTO)+T3R_TPPGTO

                    DBSelectArea("LE2")
                    LE2->(DBSetOrder(1)) //LE2_FILIAL+LE2_ID+LE2_VERSAO+DTOS(LE2_DTPGTO)+LE2_TPPGTO+LE2_PERREF+LE2_IDEDMD+LE2_INDPGT

                    DBSelectArea("LE3")
                    LE3->(DBSetOrder(1)) //LE3_FILIAL+LE3_ID+LE3_VERSAO+DTOS(LE3_DTPGTO)+LE3_TPPGTO+LE3_PERREF+LE3_IDEDMD+LE3_INDPGT+LE3_IDRUBR+LE3_SEQUEN+LE3_CPFBEN

                    DBSelectArea("LE4")
                    LE4->(DBSetOrder(1)) //LE4_FILIAL+LE4_ID+LE4_VERSAO+DTOS(LE4_DTPGTO)+LE4_TPPGTO+LE4_PERREF+LE4_IDEDMD+LE4_INDPGT+LE4_IDRUBR+LE4_IDENPG

                    DBSelectArea("T5U")
                    T5U->(DBSetOrder(1))  //T5U_FILIAL+T5U_ID+T5U_VERSAO+DTOS(T5U_DTPGTO)+T5U_TPPGTO+T5U_IDCATE

                    DBSelectArea("T5Z")
                    T5Z->(DBSetOrder(1)) //T5Z_FILIAL+T5Z_ID+T5Z_VERSAO+DTOS(T5Z_DTPGTO)+T5Z_TPPGTO+T5Z_IDCATE+DTOS(T5Z_DTINIG)+T5Z_IDRUBR+T5Z_CPFBEN

                    DBSelectArea("T5X")
                    T5X->(DBSetOrder(1)) //T5X_FILIAL+T5X_ID+T5X_VERSAO+DTOS(T5X_DTPGTO)+T5X_TPPGTO+T5X_IDCATE+T5X_IDTPIR

                    DBSelectArea("T5V")
                    T5V->(DBSetOrder(1))  //T5V_FILIAL+T5V_ID+T5V_VERSAO+DTOS(T5V_DTPGTO)+T5V_TPPGTO+T5V_IDCATE

                    DBSelectArea("T6P")
                    T6P->(DBSetOrder(1))  //T6P_FILIAL+T6P_ID+T6P_VERSAO+DTOS(T6P_DTPGTO)+T6P_TPPGTO

                    DBSelectArea("T6Q")
                    T6Q->(DBSetOrder(1)) //T6Q_FILIAL+T6Q_ID+T6Q_VERSAO+DTOS(T6Q_DTPGTO)+T6Q_TPPGTO+T6Q_PERREF+T6Q_IDEDMD+T6Q_INDPGT

                    DBSelectArea("T6R")
                    T6R->(DBSetOrder(1)) //T6R_FILIAL+T6R_ID+T6R_VERSAO+DTOS(T6R_DTPGTO)+T6R_TPPGTO+T6R_PERREF+T6R_IDEDMD+T6R_INDPGT+T6R_IDRUBR

                    DBSelectArea("CMD")
                    CMD->(DBSetOrder(5)) //CMD_FILIAL+CMD_FUNC+CMD_ATIVO

                    C08->(DBSetOrder(3)) 
                    
                    While T3Q->(!Eof()) .And. T3Q->( T3Q_FILIAL + T3Q_ID + T3Q_VERSAO) == xFilial( "T3Q" ) + T3P->T3P_ID + T3P->T3P_VERSAO

                        cXml +=		"<infoPgto>"
                        cXml +=			xTafTag( "dtPgto" , T3Q->T3Q_DTPGTO )
                        cXml +=			xTafTag( "tpPgto" , T3Q->T3Q_TPPGTO )
                        cXml +=			xTafTag( "indResBr" , xFunTrcSN( T3Q->T3Q_INDRES , 1 ) )

                        If T3R->( MsSeek( xFilial( "T3R" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO ) )
                            
                            If __cPicVlLi == Nil
                                __cPicVlLi := PesqPict("T3R", "T3R_VLRLIQ")
                            EndIf

                            While T3R->(!Eof()) .And. T3R->( T3R_FILIAL + T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO) == xFilial( "T3Q" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO

                                If Len(Alltrim(T3R->T3R_PERREF)) > 4
                                    cPerRef := substr(T3R->T3R_PERREF, 1, 4) + '-' + substr(T3R->T3R_PERREF, 5, 2)
                                Else
                                    cPerRef := substr(T3R->T3R_PERREF, 1, 4)
                                EndIf

                                If T3Q->T3Q_TPPGTO $ '2|3'

                                    If T3Q->T3Q_TPPGTO == '2'

                                        If Empty(T3P->T3P_CPF)

                                            //Cenário sem multiplos vinculos
                                            //Pego o CPF
                                            cCpfBenefi	:= GetAdvFVal("C9V", "C9V_CPF", xFilial("C9V") + T3P->T3P_BENEFI + "1", 2, Space(TamSX3("C9V_CPF")[1]))
                                            cIdBenefi	:= T3P->T3P_BENEFI
                                            
                                        Else

                                            //Cenário com multiplos vinculos
                                            //Procuro pelo registro do S-2200
                                            cIdBenefi	:= TAFGetIdFunc( T3P->T3P_CPF, T3P->T3P_PERAPU )
                                                            
                                        EndIf
                                    
                                        If !Empty(T3R->T3R_NRARQ) .And. T3R->T3R_NRARQ <> "0"
                                            cNrRecArq := T3R->T3R_NRARQ
                                        Else 
                                            //-> Busca o Protocolo da Ultima Transm.
                                            cNrRecArq := RetPrtUl('2', iIf(Empty(cCpfBenefi),T3P->T3P_CPF,cCpfBenefi), T3R->T3R_IDEDMD)
                                        EndIf

                                        If Empty(cNrRecArq)

                                            If CMD->( MsSeek( xFilial( "CMD" ) + cIdBenefi + "1" ) )
                                                cNrRecArq := CMD->CMD_PROTUL
                                            EndIf

                                        EndIf

                                        cCpfBenefi 	:= ""
                                        cIdBenefi	:= ""

                                    ElseIf T3Q->T3Q_TPPGTO == '3'

                                        If Empty(T3P->T3P_CPF)

                                            //Cenário sem multiplos vinculos
                                            //Pego o CPF
                                            cCpfBenefi	:= GetAdvFVal("C9V", "C9V_CPF", xFilial("C9V") + T3P->T3P_BENEFI + "1", 2, Space(TamSX3("C9V_CPF")[1]))
                                            cIdBenefi	:= T3P->T3P_BENEFI

                                        Else

                                            //Cenário com multiplos vinculos
                                            //Procuro pelo registro do S-2300
                                            cIdBenefi	:= TAFGetIdFunc( T3P->T3P_CPF, T3P->T3P_PERAPU )

                                        EndIf

                                        If !Empty(T3R->T3R_NRARQ) .And. T3R->T3R_NRARQ <> "0"
                                            cNrRecArq := T3R->T3R_NRARQ
                                        Else 
                                            //-> Busca o Protocolo da Ultima Transm.
                                            cNrRecArq := RetPrtUl('3', iIf(Empty(cCpfBenefi),T3P->T3P_CPF,cCpfBenefi), T3R->T3R_IDEDMD)
                                        EndIf

                                        If Empty(cNrRecArq)
                                        
                                            //Posiciono no termino
                                            If T92->( MsSeek( xFilial( "T92" ) + cIdBenefi + "1" ) )
                                                cNrRecArq := T92->T92_PROTUL
                                            EndIf

                                        EndIf

                                        cCpfBenefi 	:= ""
                                        cIdBenefi	:= ""

                                    EndIf
                                    
                                EndIf

                                cXml +=	"<detPgtoFl>"
                                cXml +=	xTafTag("perRef"    , cPerRef		    ,, .T. )
                                cXml +=	xTafTag("ideDmDev"  , T3R->T3R_IDEDMD   ,, .F. )
                                cXml +=	xTafTag("indPgtoTt" , T3R->T3R_INDPGT   ,, .F. )
                                cXml +=	xTafTag("vrLiq"	    , T3R->T3R_VLRLIQ   , __cPicVlLi, .F.,, .T.)
                                cXml +=	xTafTag("nrRecArq"  , cNrRecArq         ,, .T. )

                                //Correção realizada para que o cNrRecArq não gere para os demais registros do S-1210
                                cNrRecArq := ""

                                If LE2->( MsSeek( xFilial( "LE2" ) + T3R->(  T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT) ) )
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("LE2", "LE2_QTDRUB")
                                        __cPicFatR := PesqPict("LE2", "LE2_FATRUB")
                                        __cPicVlUn := PesqPict("LE2", "LE2_VLRUNI")
                                        __cPicVlRu := PesqPict("LE2", "LE2_VLRRUB")
                                    EndIf

                                    While LE2->(!Eof()) .And.  LE2->(LE2_FILIAL + LE2_ID + LE2_VERSAO + DTOS(LE2_DTPGTO) + LE2_TPPGTO + LE2_PERREF + LE2_IDEDMD + LE2_INDPGT) == T3R->(T3R_FILIAL + T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT )

                                        cXml +=	"<retPgtoTot>"

                                        If !lInfo1210

                                            cCodRubr := LE2->LE2_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))
                                                
                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=	xTafTag("codRubr"		, LE2->LE2_RUBRIC)
                                            cXml +=	xTafTag("ideTabRubr"	, LE2->LE2_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	, LE2->LE2_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" , LE2->LE2_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	, LE2->LE2_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	, LE2->LE2_VLRRUB, __cPicVlRu, .F.)

                                        If LE3->( MsSeek( xFilial( "LE3" ) + LE2->(  LE2_ID + LE2_VERSAO + DTOS(LE2_DTPGTO) + LE2_TPPGTO + LE2_PERREF + LE2_IDEDMD + LE2_INDPGT + LE2_IDRUBR + LE2_SEQUEN) ) )
                                           
                                            If __cPicVlPe == Nil
                                                __cPicVlPe := PesqPict("LE3", "LE3_VLRPEN")
                                            EndIf

                                            While LE3->(!Eof()) .And. LE3->(LE3_FILIAL + LE3_ID + LE3_VERSAO + DTOS(LE3_DTPGTO) + LE3_TPPGTO + LE3_PERREF + LE3_IDEDMD + LE3_INDPGT + LE3_IDRUBR + LE3_SEQUEN )  == LE2->(LE2_FILIAL + LE2_ID + LE2_VERSAO + DTOS(LE2_DTPGTO) + LE2_TPPGTO + LE2_PERREF + LE2_IDEDMD + LE2_INDPGT + LE2_IDRUBR + LE2_SEQUEN)

                                                cXml +=	"<penAlim>" 
                                                cXml +=	xTafTag("cpfBenef"      , LE3->LE3_CPFBEN				,,.F.)
                                                cXml +=	xTafTag("dtNasctoBenef" , LE3->LE3_DTNSBE               ,,.T.)
                                                cXml +=	xTafTag("nmBenefic"	    , FwCutOff(LE3->LE3_NMBEN, .T.) ,,.F.)
                                                cXml +=	xTafTag("vlrPensao"	    , LE3->LE3_VLRPEN               , __cPicVlPe, .F.)
                                                cXml +=	"</penAlim>"

                                                LE3->(DBSkip())

                                            EndDo

                                        EndIF

                                        cXml +=	"</retPgtoTot>"
                                        LE2->(DBSkip())

                                    EndDo

                                EndIf

                                If LE4->( MsSeek( xFilial( "LE4" ) + T3R->( T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT) ) )
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("LE4", "LE4_QTDRUB")
                                        __cPicFatR := PesqPict("LE4", "LE4_FATRUB")
                                        __cPicVlUn := PesqPict("LE4", "LE4_VLRUNI")
                                        __cPicVlRu := PesqPict("LE4", "LE4_VLRRUB")
                                    EndIf

                                    C9V->(DbSetOrder(1))

                                    While LE4->(!Eof()) .And. LE4->(LE4_FILIAL + LE4_ID + LE4_VERSAO + DTOS(LE4_DTPGTO) + LE4_TPPGTO + LE4_PERREF + LE4_IDEDMD + LE4_INDPGT) == T3R->(T3R_FILIAL + T3R_ID + T3R_VERSAO + DTOS(T3R_DTPGTO) + T3R_TPPGTO + T3R_PERREF + T3R_IDEDMD + T3R_INDPGT)
                                        
                                        cXml +=	"<infoPgtoParc>"
                                        
                                        If !lInfo1210

                                            C9V->(MsSeek(xFilial("C9V") + T3P->T3P_BENEFI))

                                            cXml +=	xTafTag("matricula", C9V->C9V_MATRIC,, .T.)
                                            
                                            cCodRubr := LE4->LE4_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))
                                                
                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=	    xTafTag("matricula"     ,LE4->LE4_MATRIC ,,.T.)
                                            cXml +=		xTafTag("codRubr"		,LE4->LE4_RUBRIC)
                                            cXml +=		xTafTag("ideTabRubr"	,LE4->LE4_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	,LE4->LE4_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" ,LE4->LE4_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	,LE4->LE4_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	,LE4->LE4_VLRRUB, __cPicVlRu, .F.)

                                        cXml +=	"</infoPgtoParc>"

                                        LE4->( dbSkip() )

                                    EndDo

                                EndIf

                                cXml += "</detPgtoFl>"
                                T3R->(DBSkip())

                            EndDo

                        EndIf

                        If T6P->( MsSeek( xFilial( "T6P" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO ) )

                            If __cPicVlLi == Nil
                                __cPicVlLi := PesqPict("T6P", "T6P_VLRLIQ")
                            EndIf

                            While T6P->(!Eof()) .And. T6P->(T6P_FILIAL + T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO) == T3Q->(T3Q_FILIAL + T3Q_ID + T3Q_VERSAO + DTOS(T3Q_DTPGTO) + T3Q_TPPGTO)

                                cXml +=	"<detPgtoBenPr>"
                                cXml +=	xTafTag("perRef"	, SubStr(T6P->T6P_PERREF, 1, 4) + '-' + SubStr(T6P->T6P_PERREF, 5, 2)   ,,.F.)
                                cXml +=	xTafTag("ideDmDev" 	, T6P->T6P_IDEDMD                                                       ,,.F.)
                                cXml +=	xTafTag("indPgtoTt" , T6P->T6P_INDPGT                                                       ,,.F.)
                                cXml +=	xTafTag("vrLiq"	   	, T6P->T6P_VLRLIQ                                                       , __cPicVlLi, .F.,, .T.)

                                If T6Q->( MsSeek( xFilial( "T6Q" ) + T6P->(  T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT) ) )

                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("T6Q", "T6Q_QTDRUB")
                                        __cPicFatR := PesqPict("T6Q", "T6Q_FATRUB")
                                        __cPicVlUn := PesqPict("T6Q", "T6Q_VLRUNI")
                                        __cPicVlRu := PesqPict("T6Q", "T6Q_VLRRUB") 
                                    EndIf

                                    While T6Q->(!Eof()) .And. T6Q->( T6Q_FILIAL + T6Q_ID + T6Q_VERSAO + DTOS(T6Q_DTPGTO) + T6Q_TPPGTO + T6Q_PERREF + T6Q_IDEDMD + T6Q_INDPGT) == T6P->(T6P_FILIAL + T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT )
                                        
                                        cXml +=	"<retPgtoTot>"

                                        If !lInfo1210

                                            cCodRubr := T6Q->T6Q_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))
                                                
                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=		xTafTag( "codRubr"		, T6Q->T6Q_RUBRIC)
                                            cXml +=		xTafTag( "ideTabRubr"	, T6Q->T6Q_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"   , T6Q->T6Q_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" , T6Q->T6Q_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"    , T6Q->T6Q_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"    , T6Q->T6Q_VLRRUB, __cPicVlRu, .F.)
                                        cXml +=	"</retPgtoTot>"

                                        T6Q->(DBSkip())

                                    EndDo

                                EndIf

                                If T6R->( MsSeek( xFilial( "T6R" ) + T6P->( T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT) ) )
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("T6R", "T6R_QTDRUB")
                                        __cPicFatR := PesqPict("T6R", "T6R_FATRUB")
                                        __cPicVlUn := PesqPict("T6R", "T6R_VLRUNI")
                                        __cPicVlRu := PesqPict("T6R", "T6R_VLRRUB")
                                    EndIf

                                    While T6R->(!Eof()) .And. T6R->( T6R_FILIAL + T6R_ID + T6R_VERSAO + DTOS(T6R_DTPGTO) + T6R_TPPGTO + T6R_PERREF + T6R_IDEDMD + T6R_INDPGT) == T6P->( T6P_FILIAL + T6P_ID + T6P_VERSAO + DTOS(T6P_DTPGTO) + T6P_TPPGTO + T6P_PERREF + T6P_IDEDMD + T6P_INDPGT)
                                       
                                        cXml +=	"<infoPgtoParc>"

                                        If !lInfo1210

                                            cCodRubr := T6R->T6R_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))

                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB

                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))
                                                
                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=		xTafTag( "codRubr"		, T6R->T6R_RUBRIC)
                                            cXml +=		xTafTag( "ideTabRubr"	, T6R->T6R_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	,T6R->T6R_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" ,T6R->T6R_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	,T6R->T6R_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	,T6R->T6R_VLRRUB, __cPicVlRu, .F.)
                                        cXml +=	"</infoPgtoParc>"

                                        T6R->(DBSkip())

                                    EndDo

                                EndIf

                                cXml +=	"</detPgtoBenPr>"
                                T6P->(DBSkip())

                            EndDo
                        EndIf

                        nTamQtdDias := GetSx3Cache("T5Y_QTDIAS","X3_TAMANHO")

                        If T5U->( MsSeek( xFilial( "T5U" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO  ) )

                            If __cPicVlLi == Nil
                                __cPicVlLi := PesqPict("T5U", "T5U_VLRLIQ")
                            EndIf

                            C87->(DbSetOrder(1))
                            C9V->(DbSetOrder(1))

                            While T5U->(!Eof()) .And. T5U->(T5U_FILIAL + T5U_ID + T5U_VERSAO + DTOS(T5U_DTPGTO) + T5U_TPPGTO ) == T3Q->(T3Q_FILIAL + T3Q_ID + T3Q_VERSAO + DTOS(T3Q_DTPGTO) + T3Q_TPPGTO )
                                
                                cXml +=	"<detPgtoFer>"

                                C87->(MsSeek(xFilial("C87") + T5U->T5U_IDCATE))

                                cXml +=	xTafTag("codCateg", C87->C87_CODIGO,, .F.)

                                If TAFColumnPos("T5U_MATRIC") .And. !Empty( T5U->T5U_MATRIC )
                                    cXml +=	xTafTag("matricula",T5U->T5U_MATRIC,,.T.)
                                Else
                                    C9V->(MsSeek(xFilial("C9V") + T3P->T3P_BENEFI))

                                    cXml +=	xTafTag("matricula", C9V->C9V_MATRIC,, .T.)
                                EndIf
                                    
                                cXml +=	xTafTag("dtIniGoz"  , T5U->T5U_DTINIG,,, .F.)
                                cXml +=	xTafTag("qtDias"    , T5U->T5U_QTDIAS,, .F.,, .T.)
                                cXml +=	xTafTag("vrLiq"	    , T5U->T5U_VLRLIQ, __cPicVlLi, .F.,, .T.)

                                If T5Y->( MsSeek(xFilial("T5Y")+T5U->(T5U_ID+T5U_VERSAO+DTOS(T5U_DTPGTO)+T5U_TPPGTO+T5U_IDCATE+DTOS(T5U_DTINIG)) +PADR(cValToChar(T5U->T5U_QTDIAS),nTamQtdDias)+ Iif(TAFColumnPos("T5Y_MATRIC"), AllTrim(T5U->T5U_MATRIC), "")  )) 
                                    
                                    If __cPicQtdR == Nil
                                        __cPicQtdR := PesqPict("T5Y", "T5Y_QTDRUB")
                                        __cPicFatR := PesqPict("T5Y", "T5Y_FATRUB")
                                        __cPicVlUn := PesqPict("T5Y", "T5Y_VLRUNI")
                                        __cPicVlRu := PesqPict("T5Y", "T5Y_VLRRUB")
                                    EndIf

                                    While T5Y->(!Eof()) .And. T5Y->(T5Y_FILIAL + T5Y_ID + T5Y_VERSAO + DTOS(T5Y_DTPGTO) + T5Y_TPPGTO + T5Y_IDCATE + DTOS(T5Y_DTINIG) + PADR(cValToChar(T5Y_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5Y->T5Y_MATRIC, "") ) == T5U->(T5U_FILIAL + T5U_ID + T5U_VERSAO + DTOS(T5U_DTPGTO) + T5U_TPPGTO + T5U_IDCATE + DTOS(T5U_DTINIG) + PADR(cValToChar(T5U_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5U->T5U_MATRIC, "")   )
                                        
                                        cXml +=	"<detRubrFer>"

                                        If !lInfo1210

                                            cCodRubr := T5Y->T5Y_IDRUBR

                                            If !Empty(__aRubrica)
                                                nPosRubric := aScan(__aRubrica, {|x| x[2] == cCodRubr})
                                            EndIf

                                            If nPosRubric > 0

                                                cC8R_IDTBRU	:= __aRubrica[nPosRubric][1]
                                                cCodRubr	:= __aRubrica[nPosRubric][2]
                                                cTabRubric 	:= __aRubrica[nPosRubric][3]
                                                cRubrica	:= __aRubrica[nPosRubric][4]	

                                            Else

                                                C8R->(DbSetOrder(5))
                                                C8R->(MsSeek(xFilial("C8R") + cCodRubr + "1"))

                                                cC8R_IDTBRU := C8R->C8R_IDTBRU
                                                cRubrica    := C8R->C8R_CODRUB
                                                
                                                T3M->(DbSetOrder(1))
                                                T3M->(MsSeek(xFilial("T3M") + cC8R_IDTBRU))

                                                cTabRubric := IIf(lRubERPPad, T3M->T3M_ID, T3M->T3M_CODERP)
                                                
                                                AAdd(__aRubrica, {cC8R_IDTBRU, cCodRubr, cTabRubric, cRubrica})

                                            EndIf

                                            cXml += xTafTag("codRubr"   , cRubrica)
                                            cXml +=	xTafTag("ideTabRubr", cTabRubric)

                                        Else

                                            cXml +=		xTafTag("codRubr"		,T5Y->T5Y_RUBRIC)
                                            cXml +=		xTafTag("ideTabRubr"	,T5Y->T5Y_IDTABR)

                                        EndIf

                                        cXml +=	xTafTag("qtdRubr"	, T5Y->T5Y_QTDRUB, __cPicQtdR, .T.)
                                        cXml +=	xTafTag("fatorRubr" , T5Y->T5Y_FATRUB, __cPicFatR, .T.)
                                        cXml +=	xTafTag("vrUnit"	, T5Y->T5Y_VLRUNI, __cPicVlUn, .T.)
                                        cXml +=	xTafTag("vrRubr"	, T5Y->T5Y_VLRRUB, __cPicVlRu, .F.)

                                        If T5Z->( MsSeek( xFilial( "T5Z" ) + T5Y->(T5Y_ID+T5Y_VERSAO+DTOS(T5Y_DTPGTO)+T5Y_TPPGTO+T5Y_IDCATE+DTOS(T5Y_DTINIG)+ PADR(cValToChar(T5Y_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5Y->T5Y_MATRIC, "") + T5Y_IDRUBR+T5Y_RUBRIC) ) )
                                            
                                            If __cPicVlPe == Nil
                                                __cPicVlPe := PesqPict("T5Z", "T5Z_VLRPEN")
                                            EndIf

                                            While T5Z->(!Eof()) .And. T5Z->( T5Z_FILIAL + T5Z_ID + T5Z_VERSAO + DTOS(T5Z_DTPGTO) + T5Z_TPPGTO + T5Z_IDCATE + DTOS(T5Z_DTINIG) + PADR(cValToChar(T5Z_QTDIAS),nTamQtdDias) +  Iif(TAFColumnPos("T5Y_MATRIC"), T5Z->T5Z_MATRIC, "") +  T5Z->T5Z_IDRUBR + T5Z->T5Z_RUBRIC ) ==  T5Y->(T5Y_FILIAL + T5Y_ID + T5Y_VERSAO + DTOS(T5Y_DTPGTO) + T5Y_TPPGTO + T5Y_IDCATE + DTOS(T5Y_DTINIG) + PADR(cValToChar(T5Y_QTDIAS),nTamQtdDias) + Iif(TAFColumnPos("T5Y_MATRIC"), T5Y->T5Y_MATRIC, "") + T5Y_IDRUBR + T5Y_RUBRIC)
                                                
                                                cXml +=	"<penAlim>"
                                                cXml +=	xTafTag("cpfBenef"		, T5Z->T5Z_CPFBEN				,,.F.)
                                                cXml +=	xTafTag("dtNasctoBenef" , T5Z->T5Z_DTNSBE				,,.T.)
                                                cXml +=	xTafTag("nmBenefic"		, FwCutOff(T5Z->T5Z_NMBEN, .T.)	,,.F.)
                                                cXml +=	xTafTag("vlrPensao"		, T5Z->T5Z_VLRPEN				, __cPicVlPe, .F.)
                                                cXml +=	"</penAlim>"
                                                 
                                                T5Z->(DBSkip())

                                            EndDo

                                        EndIF

                                        cXml += "</detRubrFer>"

                                        T5Y->(DBSkip())

                                    EndDo

                                Else

                                    //Seek retorna .f. -> grupo de tags obrigatorio
                                    xTafTagGroup("detRubrFer"	,{ {"codRubr"		,	''	, , .F. } ;
                                        ,  {"ideTabRubr"	,	''	, , .F. } ;
                                        ,  {"qtdRubr"		,	''	, , .T. } ;
                                        ,  {"fatorRubr"		,	''	, , .T. } ;
                                        ,  {"vrUnit"		,	''	, , .T. } ;
                                        ,  {"vrRubr"		,	''	, , .F. } } ;
                                        ,  @cXml , , .T.)

                                EndIf

                                cXml +=	"</detPgtoFer>"
                                T5U->(DBSkip())

                            EndDo

                        EndIf

                        If T5V->( MsSeek( xFilial( "T5V" ) + T3Q->T3Q_ID + T3Q->T3Q_VERSAO + DTOS(T3Q->T3Q_DTPGTO) + T3Q->T3Q_TPPGTO ) )

                            C87->(DbSetOrder(1))

                            While T5V->(!Eof()) .And. T5V->( T5V_FILIAL + T5V_ID + T5V_VERSAO + DTOS(T5V_DTPGTO) + T5V_TPPGTO ) == T3Q->(T3Q_FILIAL + T3Q_ID + T3Q_VERSAO + DTOS(T3Q_DTPGTO) + T3Q_TPPGTO)
                                
                                If T3Q->T3Q_TPPGTO == "9"

                                    cXml +=	"<detPgtoAnt>"

                                    C87->(MsSeek(xFilial("C87") + T5V->T5V_IDCATE))

                                    cXml +=	xTafTag("codCateg", C87->C87_CODIGO,, .F.,, "T5Z_VLRPEN")

                                    If T5X->( MsSeek( xFilial( "T5X" ) +  T5V->( T5V_ID+T5V_VERSAO+DTOS(T5V_DTPGTO)+T5V_TPPGTO + T5V_IDCATE ) ) )
                                        
                                        If __cPicVlRb == Nil
                                            __cPicVlRb := PesqPict("T5X", "T5X_VLRBCI")
                                        EndIf
                                        
                                        C8U->(DbSetOrder(1))

                                        While T5X->(!Eof()) .And. T5X->( T5X_FILIAL + T5X_ID + T5X_VERSAO + DTOS(T5X_DTPGTO) + T5X_TPPGTO + T5X_IDCATE) == T5V->(T5V_FILIAL + T5V_ID + T5V_VERSAO + DTOS(T5V_DTPGTO) + T5V_TPPGTO + T5V_IDCATE)
                                            
                                            C8U->(MsSeek(xFilial("C8U") + T5X->T5X_IDTPIR))                                    
                                            
                                            cXml +=	"<infoPgtoAnt>"
                                            cXml +=	xTafTag("tpBcIRRF", C8U->C8U_CODIGO,, .F.,, "T5X_IDTPIR")
                                            cXml +=	xTafTag("vrBcIRRF", T5X->T5X_VLRBCI, __cPicVlRb, .F.)
                                            cXml +=	"</infoPgtoAnt>"

                                            T5X->(DBSkip())

                                        EndDo

                                    Else

                                        //Seek retorna .f. -> grupo de tags obrigatorio
                                        xTafTagGroup("infoPgtoAnt"	,{ {"tpBcIRRF"		,	''	, , .F. } ;
                                            ,  {"vrBcIRRF"		,	''	, , .F. } } ;
                                            ,  @cXml , , .T. )

                                    EndIf

                                    cXml +=	"</detPgtoAnt>"

                                Endif

                                T5V->(DBSkip())

                            EndDo

                        EndIf

                        cXmlIdePais := ""
                        cXmlEndExt  := ""

                        C08->(MsSeek(xFilial("C08") + T3Q->T3Q_IDPAIS))

                        //Utilizacao da funcao xTafTagGroup - Encadeamento de grupos de tags (eh funcional quando nao existe um laço na geração dos grupos de tags filhos )
                        xTafTagGroup("idePais"	, { {"codPais"  , C08->C08_PAISSX   ,, .F.};
                                                ,   {"indNIF"	, T3Q->T3Q_INDNIF	,, .F.};
                                                ,   {"nifBenef"	, T3Q->T3Q_NIFBEN	,, .T.} };
                                                , @cXmlIdePais)

                        //Seek retorna .f. -> grupo de tags obrigatorio
                        xTafTagGroup("endExt"	,{ {"dscLograd"		,	FwCutOff(T3Q->T3Q_DLOUGR, .T.)	, , .F. } ;
                            ,  {"nrLograd"		,	T3Q->T3Q_NUMLOG					, , .T. } ;
                            ,  {"complem"		,	FwCutOff(T3Q->T3Q_COMPLE, .T.)	, , .T. } ;
                            ,  {"bairro"		,	FwCutOff(T3Q->T3Q_BAIRRO, .T.)	, , .T. } ;
                            ,  {"nmCid"			,	FwCutOff(T3Q->T3Q_CIDADE, .T.)	, , .F. } ;
                            ,  {"codPostal"		,	AllTrim(T3Q->T3Q_CEP)			, , .T. } } ;
                            ,  @cXmlEndExt)

                        xTafTagGroup( "idePgtoExt" , , @cXml , { { "idePais" , cXmlIdePais , 1 } , { "endExt" , cXmlEndExt , 1 } } ,,.T.)

                        cXml +=	"</infoPgto>"

                        T3Q->(DBSkip())

                    EndDo

                    T3R->(DbCloseArea())
                    LE2->(DbCloseArea())
                    LE3->(DbCloseArea())
                    LE4->(DbCloseArea())
                    T6P->(DbCloseArea())
                    T6Q->(DbCloseArea())
                    T6R->(DbCloseArea())
                    T5U->(DbCloseArea())
                    T5Z->(DbCloseArea()) 
                    T5V->(DbCloseArea())
                    T5X->(DbCloseArea())

                Else

                    //Seek retorna .f. -> grupo de tags obrigatorio
                    xTafTagGroup("infoPgto"	,{ {"dtPgto"		,	''	, , .F. } ;
                        ,  {"tpPgto"			,	''	, , .F. } ;
                        ,  {"indResBr"		,	''	, , .F. } } ;
                        ,  @cXml , , .T. )

                EndIf
                
                T3Q->(DbCloseArea())

            Else

                lDicAtu := .F.
                MsgInfo( STR0033 + ' Alias T5Y ', STR0034 )

            EndIf

            T5Y->(DbCloseArea())

        Else

            V6M->(DBSetOrder(1))

            If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")
                V9I->(DBSetOrder(1)) 
                V9J->(DBSetOrder(1)) 
                C08->(DBSetOrder(3))
                V9H->(DBSetOrder(1))
            EndIf

            If V6M->(MsSeek(xFilial("V6M") + T3P->(T3P_ID + T3P_VERSAO)))

                If __cPicVlLi == Nil
                    __cPicVlLi := PesqPict("V6M", "V6M_VLRLIQ")
                EndIf

                While !V6M->(EOF()) .And. V6M->(V6M_FILIAL + V6M_ID + V6M_VERSAO) == xFilial("T3P") + T3P->(T3P_ID + T3P_VERSAO)
                   
                    If Len(Alltrim(V6M->V6M_PERREF)) > 4
                        cPerRef := substr(V6M->V6M_PERREF, 1, 4) + '-' + substr(V6M->V6M_PERREF, 5, 2)
                    Else
                        cPerRef := substr(V6M->V6M_PERREF, 1, 4)
                    EndIf

                    cXml +=	"<infoPgto>"
                    cXml +=	xTafTag("dtPgto"    , V6M->V6M_DTPGTO)
                    cXml +=	xTafTag("tpPgto"    , V6M->V6M_TPPGTO)
                    cXml +=	xTafTag("perRef"    , cPerRef)
                    cXml +=	xTafTag("ideDmDev"  , V6M->V6M_INDDEV)
                    cXml +=	xTafTag("vrLiq"     , V6M->V6M_VLRLIQ, __cPicVlLi,,, .T.) 

                    If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")

                        C08->(MsSeek(xFilial("C08") + V6M->V6M_PAIEXT))
                        
                        cXml +=	xTafTag("paisResidExt", C08->C08_PAISSX,, .T.)  

                        If V9I->(MsSeek(xFilial("V9I") + V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)))
                           
                            While !V9I->(EOF()) .And. V9I->(V9I_FILIAL + V9I_ID + V9I_VERSAO + V9I_TPPGTO + V9I_PERREF + V9I_INDDEV) == xFilial("V6M") +; 
                                    V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)        
                                
                                cXml +=	"<infoPgtoExt>"
                                cXml +=	xTafTag("indNIF"    , V9I->V9I_INDNIF)
                                cXml +=	xTafTag("nifBenef"  , V9I->V9I_NIFBEN,, .T.)
                                
                                V9H->(MsSeek(xFilial("V9H") + V9I->V9I_FRMTRI))
                                
                                cXml +=	xTafTag("frmTribut", V9H->V9H_CODIGO)
                                
                                If V9J->(MsSeek(xFilial("V9J") + V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)))
                                    
                                    While !V9J->(EOF()) .And. V9J->(V9J_FILIAL + V9J_ID + V9J_VERSAO + V9J_TPPGTO + V9J_PERREF + V9J_INDDEV) == xFilial("V6M") +; 
                                            V6M->(V6M_ID + V6M_VERSAO + V6M_TPPGTO + V6M_PERREF + V6M_INDDEV)        
                                        
                                        cXml +=	"<endExt>"
                                        cXml +=	xTafTag("endDscLograd"  , FwCutOff(V9J->V9J_DSCLOG) ,,.T.)
                                        cXml +=	xTafTag("endNrLograd"   , AllTrim(V9J->V9J_NRLOGR)  ,,.T.)
                                        cXml +=	xTafTag("endComplem"    , FwCutOff(V9J->V9J_COMPLE) ,,.T.)
                                        cXml +=	xTafTag("endBairro"     , FwCutOff(V9J->V9J_BAIRRO) ,,.T.)
                                        cXml +=	xTafTag("endCidade"     , FwCutOff(V9J->V9J_CIDADE) ,,.T.)
                                        cXml +=	xTafTag("endEstado"     , FwCutOff(V9J->V9J_ESTADO) ,,.T.)                                                  
                                        cXml +=	xTafTag("endCodPostal"  , AllTrim(V9J->V9J_CODPOS)  ,,.T.)                    
                                        cXml +=	xTafTag("telef"         , AllTrim(V9J->V9J_TELEF)   ,,.T.)   
                                        cXml +=	"</endExt>"
                                    
                                        V9J->(DbSkip())

                                    EndDo

                                EndIf
                                
                                cXml +=	"</infoPgtoExt>"

                                V9I->(DbSkip())

                            EndDo
                        EndIf
                    EndIf

                    cXml +=	"</infoPgto>"

                    V6M->(DbSkip())

                EndDo

            EndIf

            If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC") )

                V7S->(DBSetOrder(1)) 
                V7T->(DBSetOrder(1)) 
                V7U->(DBSetOrder(1))
                V7V->(DBSetOrder(1))
                V7W->(DBSetOrder(1))
                V7X->(DBSetOrder(1))
                V7Y->(DBSetOrder(1))
                V7Z->(DBSetOrder(1))
                V8A->(DBSetOrder(2))
                V8B->(DBSetOrder(1))
                V8C->(DBSetOrder(1))
                V8D->(DBSetOrder(1))
                V8E->(DBSetOrder(2))
                V8F->(DBSetOrder(2))
                V8G->(DBSetOrder(2))

                If __cPicVlrs == Nil
                    __cPicVlrs := PesqPict("V7Y", "V7Y_VLRRET")
                EndIf

                cXmlAux +=	"<infoIRComplem>"

                    cXmlAux +=	xTafTag("dtLaudo"   , T3P->T3P_DTLAUD ,,.T.)

                    
                    If V7S->(MsSeek(xFilial("T3P") + T3P->(T3P_ID + T3P_VERSAO )))
                        While !V7S->(EOF()) .And. V7S->(V7S_FILIAL + V7S_ID + V7S_VERSAO) == T3P->(T3P_FILIAL + T3P_ID + T3P_VERSAO)
                            cXmlAux +=	"<infoDep>"
                                cXmlAux +=	xTafTag("cpfDep"        , AllTrim(V7S->V7S_CPFDEP)  ,,.F.)
                                cXmlAux +=	xTafTag("dtNascto"      , V7S->V7S_DTNASC           ,,.T.)
                                cXmlAux +=	xTafTag("nome"          , AllTrim(V7S->V7S_NMDEP )  ,,.T.)
                                cXmlAux +=	xTafTag("depIRRF"       , AllTrim(V7S->V7S_DPIRRF)  ,,.T.)
                                cXmlAux +=	xTafTag("tpDep"         , Posicione( "CMI", 1, xFilial( "CMI" ) + V7S->V7S_TPDEP, "CMI_CODIGO" )   ,,.T.)
                                cXmlAux +=	xTafTag("descrDep"      , AllTrim(V7S->V7S_DSCDEP)  ,,.T.)
                            cXmlAux +=	"</infoDep>"

                            V7S->(DbSkip())
                        EndDo
                    EndIf

                    If V7T->(MsSeek(xFilial("T3P") + T3P->(T3P_ID + T3P_VERSAO )))
                        
                        While !V7T->(EOF()) .And. V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO) == T3P->(T3P_FILIAL + T3P_ID + T3P_VERSAO)
                            cXmlAux +=	"<infoIRCR>"
                                cXmlAux +=	xTafTag("tpCR"        , Posicione( "C6R", 3, xFilial( "C6R" ) + V7T->V7T_TPCR, "C6R_CODIGO" )  ,,.F.)

                                If V7U->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR )))
                                    While !V7U->(EOF()) .And. V7U->(V7U_FILIAL + V7U_ID + V7U_VERSAO + V7U_TPCR) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR)
                                        cXmlAux +=	"<dedDepen>"
                                            cXmlAux +=	xTafTag("tpRend"            , AllTrim(V7U->V7U_TPREND)  ,,.F.)
                                            cXmlAux +=	xTafTag("cpfDep"            , AllTrim(V7U->V7U_CPFDEP)  ,,.F.)
                                            cXmlAux +=	xTafTag("vlrDedDep"         , V7U->V7U_VLRDED           ,__cPicVlrs,.F.)
                                        cXmlAux +=	"</dedDepen>"

                                        V7U->(DbSkip())
                                    EndDo
                                EndIf

                                If V7V->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR )))
                                    While !V7V->(EOF()) .And. V7V->(V7V_FILIAL + V7V_ID + V7V_VERSAO + V7V_TPCR) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR)
                                        cXmlAux +=	"<penAlim>"
                                            cXmlAux +=	xTafTag("tpRend"            , AllTrim(V7V->V7V_TPREND)  ,,.F.)
                                            cXmlAux +=	xTafTag("cpfDep"            , AllTrim(V7V->V7V_CPFDEP)  ,,.F.)
                                            cXmlAux +=	xTafTag("vlrDedPenAlim"     , V7V->V7V_VLPEN  ,__cPicVlrs,.F.)
                                        cXmlAux +=	"</penAlim>"

                                        V7V->(DbSkip())
                                    EndDo
                                EndIf

                                If V7W->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR )))
                                    While !V7W->(EOF()) .And. V7W->(V7W_FILIAL + V7W_ID + V7W_VERSAO + V7W_TPCR) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR)
                                        cXmlAux +=	"<previdCompl>"
                                            cXmlAux +=	xTafTag("tpPrev"            , AllTrim(V7W->V7W_TPREV )  ,,.F.)
                                            cXmlAux +=	xTafTag("cnpjEntidPC"       , AllTrim(V7W->V7W_INSCPL)  ,,.F.)
                                            cXmlAux +=	xTafTag("vlrDedPC"          , V7W->V7W_VLCOMP           ,__cPicVlrs,.F.)
                                            cXmlAux +=	xTafTag("vlrPatrocFunp"     , V7W->V7W_VLPATR           ,__cPicVlrs,.T.)
                                        cXmlAux +=	"</previdCompl>"

                                        V7W->(DbSkip())
                                    EndDo
                                EndIf

                                If V7X->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR )))
                                    While !V7X->(EOF()) .And. V7X->(V7X_FILIAL + V7X_ID + V7X_VERSAO + V7X_TPCR) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR)
                                        cXmlAux +=	"<infoProcRet>"
                                            cXmlAux +=	xTafTag("tpProcRet"       , AllTrim(V7X->V7X_TPPROC)  ,,.F.)
                                            cXmlAux +=	xTafTag("nrProcRet"       , AllTrim(V7X->V7X_NRPROC)  ,,.F.)
                                            cXmlAux +=	xTafTag("codSusp"         , AllTrim(V7X->V7X_CODSUP ) ,,.T.)

                                            If V7Y->(MsSeek(xFilial("V7X") + V7X->(V7X_ID + V7X_VERSAO + V7X_TPCR + V7X_TPPROC + V7X_NRPROC + V7X_CODSUP )))
                                                While !V7Y->(EOF()) .And. V7Y->(V7Y_FILIAL + V7Y_ID + V7Y_VERSAO + V7Y_TPCR + V7Y_TPPROC + V7Y_NRPROC + V7Y_CODSUP) == V7X->(V7X_FILIAL + V7X_ID + V7X_VERSAO + V7X_TPCR + V7X_TPPROC + V7X_NRPROC + V7X_CODSUP )
                                                    cXmlAux +=	"<infoValores>"
                                                        cXmlAux +=	xTafTag("indApuracao"   , AllTrim(V7Y->V7Y_INDAPU)  ,,.F.)
                                                        cXmlAux +=	xTafTag("vlrNRetido"    , V7Y->V7Y_VLRRET           ,__cPicVlrs,.T.)
                                                        cXmlAux +=	xTafTag("vlrDepJud"     , V7Y->V7Y_VLRJUD           ,__cPicVlrs,.T.)
                                                        cXmlAux +=	xTafTag("vlrCmpAnoCal"  , V7Y->V7Y_VLACAL           ,__cPicVlrs,.T.)
                                                        cXmlAux +=	xTafTag("vlrCmpAnoAnt"  , V7Y->V7Y_VLAANT           ,__cPicVlrs,.T.)
                                                        cXmlAux +=	xTafTag("vlrRendSusp"   , V7Y->V7Y_VLSUSP           ,__cPicVlrs,.T.)


                                                        If V7Z->(MsSeek(xFilial("V7Y") + V7Y->( V7Y_ID + V7Y_VERSAO + V7Y_TPCR + V7Y_TPPROC + V7Y_NRPROC + V7Y_CODSUP + V7Y_INDAPU )))
                                                            While !V7Z->(EOF()) .And. V7Z->(V7Z_FILIAL + V7Z_ID + V7Z_VERSAO + V7Z_TPCR + V7Z_TPPROC + V7Z_NRPROC + V7Z_CODSUP + V7Z_INDAPU) == V7Y->(V7Y_FILIAL + V7Y_ID + V7Y_VERSAO + V7Y_TPCR + V7Y_TPPROC + V7Y_NRPROC + V7Y_CODSUP + V7Y_INDAPU )
                                                                cXmlAux +=	"<dedSusp>"
                                                                    cXmlAux +=	xTafTag("indTpDeducao"   , V7Z->V7Z_TPDEDU  ,,.F.)
                                                                    cXmlAux +=	xTafTag("vlrDedSusp"     , V7Z->V7Z_VLSUSP  ,__cPicVlrs,.T.)
                                                                    cXmlAux +=	xTafTag("cnpjEntidPC"    , V7Z->V7Z_INSCPL  ,,.T.)
                                                                    cXmlAux +=	xTafTag("vlrPatrocFunp"  , V7Z->V7Z_VLFUNP  ,__cPicVlrs,.T.)

                                                                    If V8A->(MsSeek(xFilial("V7Z") + V7Z->( V7Z_ID + V7Z_VERSAO + V7Z_TPCR + V7Z_TPPROC + V7Z_NRPROC + V7Z_CODSUP + V7Z_INDAPU + V7Z_SEQUEN )))
                                                                        While !V8A->(EOF()) .And. V8A->(V8A_FILIAL + V8A_ID + V8A_VERSAO + V8A_TPCR + V8A_TPPROC + V8A_NRPROC + V8A_CODSUP + V8A_INDAPU + V8A_SEQUEN ) == V7Z->(V7Z_FILIAL + V7Z_ID + V7Z_VERSAO + V7Z_TPCR + V7Z_TPPROC + V7Z_NRPROC + V7Z_CODSUP + V7Z_INDAPU + V7Z_SEQUEN  )
                                                                            cXmlAux +=	"<benefPen>"
                                                                                cXmlAux +=	xTafTag("cpfDep"           , V8A->V8A_CPFDEP  ,,.F.)
                                                                                cXmlAux +=	xTafTag("vlrDepenSusp"     , V8A->V8A_VLSUSP  ,__cPicVlrs,.F.)
                                                                            cXmlAux +=	"</benefPen>"

                                                                            V8A->(DbSkip())
                                                                        EndDo
                                                                    EndIf
                                                                cXmlAux +=	"</dedSusp>"

                                                                V7Z->(DbSkip())
                                                            EndDo
                                                        EndIf
                                                    cXmlAux +=	"</infoValores>"

                                                    V7Y->(DbSkip())
                                                EndDo
                                                
                                            EndIf

                                        cXmlAux +=	"</infoProcRet>"

                                        V7X->(DbSkip())
                                    EndDo

                                EndIf

                            cXmlAux +=	"</infoIRCR>"

                            V7T->(DbSkip())

                        EndDo

                    EndIf

                    If V8B->(MsSeek(xFilial("T3P") + T3P->(T3P_ID + T3P_VERSAO )))
                        
                        While !V8B->(EOF()) .And. V8B->(V8B_FILIAL + V8B_ID + V8B_VERSAO) == T3P->(T3P_FILIAL + T3P_ID + T3P_VERSAO)
                            
                            cXmlAux +=	"<planSaude>"

                                cXmlAux +=	xTafTag("cnpjOper"      , V8B->V8B_CNPJOP  ,,.F.)
                                cXmlAux +=	xTafTag("regANS"        , V8B->V8B_REGANS  ,,.T.)
                                cXmlAux +=	xTafTag("vlrSaudeTit"   , V8B->V8B_VLRTIT  ,__cPicVlrs,.F.,,.T.)

                                If V8C->(MsSeek(xFilial("V8B") + V8B->( V8B_ID + V8B_VERSAO + V8B_CNPJOP )))
                                    
                                    While !V8C->(EOF()) .And. V8C->(V8C_FILIAL + V8C_ID + V8C_VERSAO + V8C_CNPJOP) == V8B->(V8B_FILIAL + V8B_ID + V8B_VERSAO + V8B_CNPJOP)
                                        
                                        cXmlAux +=	"<infoDepSau>"
                                            cXmlAux +=	xTafTag("cpfDep"      , V8C->V8C_CPFDEP  ,,.F.)
                                            cXmlAux +=	xTafTag("vlrSaudeDep" , V8C->V8C_VLRDEP  ,__cPicVlrs,.F.,,.T.)
                                        cXmlAux +=	"</infoDepSau>"

                                        V8C->(DbSkip())

                                    EndDo

                                EndIf

                            cXmlAux +=	"</planSaude>"

                            V8B->(DbSkip())

                        EndDo

                    EndIf

                    If V8D->(MsSeek(xFilial("T3P") + T3P->(T3P_ID + T3P_VERSAO )))

                        While !V8D->(EOF()) .And. V8D->(V8D_FILIAL + V8D_ID + V8D_VERSAO) == T3P->(T3P_FILIAL + T3P_ID + T3P_VERSAO)
                            
                            cXmlAux +=	"<infoReembMed>"
                                cXmlAux +=	xTafTag("indOrgReemb"   , V8D->V8D_INDREM  ,,.F.)
                                cXmlAux +=	xTafTag("cnpjOper"      , V8D->V8D_CNPJOP  ,,.T.)
                                cXmlAux +=	xTafTag("regANS"        , V8D->V8D_REGANS  ,,.T.)

                            If V8E->(MsSeek(xFilial("V8D") + V8D->( V8D_ID + V8D_VERSAO + V8D_SEQUEN )))

                                While !V8E->(EOF()) .And. V8E->(V8E_FILIAL + V8E_ID + V8E_VERSAO + V8E_SEQUEN  ) == V8D->( V8D_FILIAL + V8D_ID + V8D_VERSAO + V8D_SEQUEN  )
                                    
                                    cXmlAux +=	"<detReembTit>"
                                        cXmlAux +=	xTafTag("tpInsc"        , V8E->V8E_TPINSC  ,,.F.)
                                        cXmlAux +=	xTafTag("nrInsc"        , V8E->V8E_NRINSC  ,,.F.)
                                        cXmlAux +=	xTafTag("vlrReemb"      , V8E->V8E_VLREMB  ,__cPicVlrs,.T.)
                                        cXmlAux +=	xTafTag("vlrReembAnt"   , V8E->V8E_VLRANT  ,__cPicVlrs,.T.)

                                    cXmlAux +=	"</detReembTit>"

                                    V8E->(DbSkip())
                                EndDo
                            EndIf

                            If V8F->(MsSeek(xFilial("V8D") + V8D->(V8D_ID + V8D_VERSAO + V8D_SEQUEN )))
                            
                                While !V8F->(EOF()) .And. V8F->(V8F_FILIAL + V8F_ID + V8F_VERSAO + V8F_SEQUEN  ) == V8D->(V8D_FILIAL + V8D_ID + V8D_VERSAO + V8D_SEQUEN  )
                                    
                                    cXmlAux +=	"<infoReembDep>"
                                        
                                        cXmlAux +=	xTafTag("cpfBenef"        , V8F->V8F_CPFDEP  ,,.F.)

                                        If V8G->(MsSeek(xFilial("V8F") + V8F->( V8F_ID + V8F_VERSAO + V8F_CPFDEP + V8F_SEQUEN)))
                                            
                                            While !V8G->(EOF()) .And. V8G->(V8G_FILIAL + V8G_ID + V8G_VERSAO + V8G_CPFDEP + V8G_SEQUEN ) == V8F->( V8F_FILIAL + V8F_ID + V8F_VERSAO + V8F_CPFDEP + V8F_SEQUEN )
                                                
                                                cXmlAux +=	"<detReembDep>"
                                                    cXmlAux +=	xTafTag("tpInsc"        , V8G->V8G_TPINSC  ,,.F.)
                                                    cXmlAux +=	xTafTag("nrInsc"        , V8G->V8G_NRINSC  ,,.F.)
                                                    cXmlAux +=	xTafTag("vlrReemb"      , V8G->V8G_VLREMB  ,__cPicVlrs,.T.)
                                                    cXmlAux +=	xTafTag("vlrReembAnt"   , V8G->V8G_VLRANT  ,__cPicVlrs,.T.)
                                                cXmlAux +=	"</detReembDep>"

                                                V8G->(DbSkip())
                                            EndDo

                                        EndIf

                                    cXmlAux +=	"</infoReembDep>"

                                    V8F->(DbSkip())
                                EndDo

                            EndIf

                            cXmlAux +=	"</infoReembMed>"

                            V8D->(DbSkip())
                        EndDo
                    EndIf

                cXmlAux +=	"</infoIRComplem>"

                If !cXmlAux == "<infoIRComplem></infoIRComplem>"
                    cXml += cXmlAux
                EndIf 

                V7S->(DbCloseArea()) 
                V7T->(DbCloseArea()) 
                V7U->(DbCloseArea())
                V7V->(DbCloseArea())
                V7W->(DbCloseArea())
                V7X->(DbCloseArea())
                V7Y->(DbCloseArea())
                V7Z->(DbCloseArea())
                V8A->(DbCloseArea())
                V8B->(DbCloseArea())
                V8C->(DbCloseArea())
                V8D->(DbCloseArea())
                V8E->(DbCloseArea())
                V8F->(DbCloseArea())
                V8G->(DbCloseArea())
            
            ElseIf lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC")
                    
                V7S->(DBSetOrder(2)) 
                V7T->(DBSetOrder(2)) 
                V7U->(DBSetOrder(2))
                V7V->(DBSetOrder(2))
                V7W->(DBSetOrder(2))
                V7X->(DBSetOrder(2))
                V7Y->(DBSetOrder(2))
                V7Z->(DBSetOrder(2))
                V8A->(DBSetOrder(2))
                If TAFColumnPos("V8B_SEQUEN")
                    V8B->(DBSetOrder(3))
                    V8C->(DBSetOrder(3))
                Else
                    V8B->(DBSetOrder(2))
                    V8C->(DBSetOrder(2))
                EndIf 
                V8D->(DBSetOrder(2))
                V8E->(DBSetOrder(2))
                V8F->(DBSetOrder(2))
                V8G->(DBSetOrder(2))
                T8E->(DBSetOrder(1))

                If __cPicVlrs == Nil
                    __cPicVlrs := PesqPict("V7Y", "V7Y_VLRRET")
                EndIf

                If T8E->(MsSeek(xFilial("T8E") + T3P->(T3P_ID + T3P_VERSAO )))
                    
                    While !T8E->(EOF()) .And. T8E->(T8E_FILIAL + T8E_ID + T8E_VERSAO) == T3P->(T3P_FILIAL + T3P_ID + T3P_VERSAO)

                        cXmlAux +=	"<infoIRComplem>"
                        cXmlAux +=	xTafTag("dtLaudo"       , T8E->T8E_DTLAUD            ,,.T.)

                        If !Empty(T8E->T8E_PERREF) .OR. !Empty(T8E->T8E_NRREC)     

                            If Len(Alltrim(T8E->T8E_PERREF)) > 4
                                cPerRef := substr(T8E->T8E_PERREF, 1, 4) + '-' + substr(T8E->T8E_PERREF, 5, 2)
                            Else
                                cPerRef := substr(T8E->T8E_PERREF, 1, 4)
                            EndIf

                            cXmlAux +=	"<perAnt>"
                                cXmlAux +=	xTafTag("perRefAjuste"        , AllTrim(cPerRef)  ,,.F.)
                                cXmlAux +=	xTafTag("nrRec1210Orig"       , T8E->T8E_NRREC    ,,.F.)
                            cXmlAux +=	"</perAnt>"

                        EndIf

                        If V7S->(MsSeek(xFilial("T8E") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC  )))
                            While !V7S->(EOF()) .And. V7S->(V7S_FILIAL + V7S_ID + V7S_VERSAO + V7S_SEQIRC ) == T8E->(T8E_FILIAL + T8E_ID + T8E_VERSAO + T8E_SEQIRC)

                                cXmlAux +=	"<infoDep>"
                                    cXmlAux +=	xTafTag("cpfDep"        , AllTrim(V7S->V7S_CPFDEP)  ,,.F.)
                                    cXmlAux +=	xTafTag("dtNascto"      , V7S->V7S_DTNASC           ,,.T.)
                                    cXmlAux +=	xTafTag("nome"          , AllTrim(V7S->V7S_NMDEP)  ,,.T.)
                                    cXmlAux +=	xTafTag("depIRRF"       , AllTrim(V7S->V7S_DPIRRF)  ,,.T.)
                                    cXmlAux +=	xTafTag("tpDep"         , Posicione( "CMI", 1, xFilial( "CMI" ) + V7S->V7S_TPDEP, "CMI_CODIGO" )   ,,.T.)
                                    cXmlAux +=	xTafTag("descrDep"      , AllTrim(V7S->V7S_DSCDEP)  ,,.T.)
                                cXmlAux +=	"</infoDep>"

                                V7S->(DbSkip())
                            EndDo
                        EndIf

                        If V7T->(MsSeek(xFilial("T8E") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC )))
                            
                            While !V7T->(EOF()) .And. V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_SEQIRC ) == T8E->(T8E_FILIAL + T8E_ID + T8E_VERSAO + T8E_SEQIRC)

                                cXmlAux +=	"<infoIRCR>"

                                    cXmlAux +=	xTafTag("tpCR"        , Posicione( "C6R", 3, xFilial( "C6R" ) + V7T->V7T_TPCR, "C6R_CODIGO" )  ,,.F.)

                                    If V7U->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC )))

                                        While !V7U->(EOF()) .And. V7U->(V7U_FILIAL + V7U_ID + V7U_VERSAO + V7U_TPCR + V7U_SEQIRC ) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC )

                                            cXmlAux +=	"<dedDepen>"
                                                cXmlAux +=	xTafTag("tpRend"            , AllTrim(V7U->V7U_TPREND)  ,,.F.)
                                                cXmlAux +=	xTafTag("cpfDep"            , AllTrim(V7U->V7U_CPFDEP)  ,,.F.)
                                                cXmlAux +=	xTafTag("vlrDedDep"         , V7U->V7U_VLRDED           ,__cPicVlrs,.F.)
                                            cXmlAux +=	"</dedDepen>"

                                            V7U->(DbSkip())

                                        EndDo

                                    EndIf

                                    If V7V->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC )))

                                        While !V7V->(EOF()) .And. V7V->(V7V_FILIAL + V7V_ID + V7V_VERSAO + V7V_TPCR + V7V_SEQIRC ) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC )

                                            cXmlAux +=	"<penAlim>"
                                                cXmlAux +=	xTafTag("tpRend"            , AllTrim(V7V->V7V_TPREND)  ,,.F.)
                                                cXmlAux +=	xTafTag("cpfDep"            , AllTrim(V7V->V7V_CPFDEP)  ,,.F.)
                                                cXmlAux +=	xTafTag("vlrDedPenAlim"     , V7V->V7V_VLPEN  ,__cPicVlrs,.F.)
                                            cXmlAux +=	"</penAlim>"

                                            V7V->(DbSkip())
                                        EndDo
                                    EndIf

                                    If V7W->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC )))

                                        While !V7W->(EOF()) .And. V7W->( V7W_FILIAL + V7W_ID + V7W_VERSAO + V7W_TPCR + V7W_SEQIRC ) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC )

                                            cXmlAux +=	"<previdCompl>"
                                                cXmlAux +=	xTafTag("tpPrev"            , AllTrim(V7W->V7W_TPREV )  ,,.F.)
                                                cXmlAux +=	xTafTag("cnpjEntidPC"       , AllTrim(V7W->V7W_INSCPL)  ,,.F.)
                                                cXmlAux +=	xTafTag("vlrDedPC"          , V7W->V7W_VLCOMP           ,__cPicVlrs,.T.)
                                                cXmlAux +=	xTafTag("vlrDedPC13"        , V7W->V7W_VLDEP1, __cPicVlrs,.T.)
                                                cXmlAux +=	xTafTag("vlrPatrocFunp"     , V7W->V7W_VLPATR           ,__cPicVlrs,.T.)
                                                cXmlAux +=	xTafTag("vlrPatrocFunp13"   , V7W->V7W_VLPA13, __cPicVlrs,.T.)
                                            cXmlAux +=	"</previdCompl>"

                                            V7W->(DbSkip())
                                        EndDo
                                    EndIf

                                    If V7X->(MsSeek(xFilial("V7T") + V7T->(V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC )))

                                        While !V7X->(EOF()) .And. V7X->(V7X_FILIAL + V7X_ID + V7X_VERSAO + V7X_TPCR + V7X_SEQIRC ) == V7T->(V7T_FILIAL + V7T_ID + V7T_VERSAO + V7T_TPCR + V7T_SEQIRC)

                                            cXmlAux +=	"<infoProcRet>"

                                                cXmlAux +=	xTafTag("tpProcRet"       , AllTrim(V7X->V7X_TPPROC)  ,,.F.)
                                                cXmlAux +=	xTafTag("nrProcRet"       , AllTrim(V7X->V7X_NRPROC)  ,,.F.)
                                                cXmlAux +=	xTafTag("codSusp"         , AllTrim(V7X->V7X_CODSUP ) ,,.T.)

                                                If V7Y->(MsSeek(xFilial("V7X") + V7X->(V7X_ID + V7X_VERSAO + V7X_TPCR + V7X_TPPROC + V7X_NRPROC + V7X_CODSUP + V7X_SEQIRC )))

                                                    While !V7Y->(EOF()) .And. V7Y->(V7Y_FILIAL + V7Y_ID + V7Y_VERSAO + V7Y_TPCR + V7Y_TPPROC + V7Y_NRPROC + V7Y_CODSUP + V7Y_SEQIRC ) == V7X->(V7X_FILIAL + V7X_ID + V7X_VERSAO + V7X_TPCR + V7X_TPPROC + V7X_NRPROC + V7X_CODSUP + V7X_SEQIRC )
                                                        
                                                        cXmlAux +=	"<infoValores>"

                                                            cXmlAux +=	xTafTag("indApuracao"   , AllTrim(V7Y->V7Y_INDAPU)  ,,.F.)
                                                            cXmlAux +=	xTafTag("vlrNRetido"    , V7Y->V7Y_VLRRET           ,__cPicVlrs,.T.)
                                                            cXmlAux +=	xTafTag("vlrDepJud"     , V7Y->V7Y_VLRJUD           ,__cPicVlrs,.T.)
                                                            cXmlAux +=	xTafTag("vlrCmpAnoCal"  , V7Y->V7Y_VLACAL           ,__cPicVlrs,.T.)
                                                            cXmlAux +=	xTafTag("vlrCmpAnoAnt"  , V7Y->V7Y_VLAANT           ,__cPicVlrs,.T.)
                                                            cXmlAux +=	xTafTag("vlrRendSusp"   , V7Y->V7Y_VLSUSP           ,__cPicVlrs,.T.)


                                                            If V7Z->(MsSeek(xFilial("V7Y") + V7Y->( V7Y_ID + V7Y_VERSAO + V7Y_TPCR + V7Y_TPPROC + V7Y_NRPROC + V7Y_CODSUP + V7Y_INDAPU + V7Y_SEQIRC )))

                                                                While !V7Z->(EOF()) .And. V7Z->(V7Z_FILIAL + V7Z_ID + V7Z_VERSAO + V7Z_TPCR + V7Z_TPPROC + V7Z_NRPROC + V7Z_CODSUP + V7Z_INDAPU + V7Z_SEQIRC ) == V7Y->(V7Y_FILIAL + V7Y_ID + V7Y_VERSAO + V7Y_TPCR + V7Y_TPPROC + V7Y_NRPROC + V7Y_CODSUP + V7Y_INDAPU + V7Y_SEQIRC )
                                                                    
                                                                    cXmlAux +=	"<dedSusp>"

                                                                        cXmlAux +=	xTafTag("indTpDeducao"   , V7Z->V7Z_TPDEDU  ,,.F.)
                                                                        cXmlAux +=	xTafTag("vlrDedSusp"     , V7Z->V7Z_VLSUSP  ,__cPicVlrs,.T.)
                                                                        cXmlAux +=	xTafTag("cnpjEntidPC"    , V7Z->V7Z_INSCPL  ,,.T.)
                                                                        cXmlAux +=	xTafTag("vlrPatrocFunp"  , V7Z->V7Z_VLFUNP  ,__cPicVlrs,.T.)

                                                                        If V8A->(MsSeek(xFilial("V7Z") + V7Z->( V7Z_ID + V7Z_VERSAO + V7Z_TPCR + V7Z_TPPROC + V7Z_NRPROC + V7Z_CODSUP + V7Z_INDAPU + V7Z_SEQUEN + V7Z_SEQIRC )))

                                                                            While !V8A->(EOF()) .And. V8A->(V8A_FILIAL + V8A_ID + V8A_VERSAO + V8A_TPCR + V8A_TPPROC + V8A_NRPROC + V8A_CODSUP + V8A_INDAPU + V8A_SEQUEN + V8A_SEQIRC ) == V7Z->(V7Z_FILIAL + V7Z_ID + V7Z_VERSAO + V7Z_TPCR + V7Z_TPPROC + V7Z_NRPROC + V7Z_CODSUP + V7Z_INDAPU + V7Z_SEQUEN + V7Z_SEQIRC )
                                                                                
                                                                                cXmlAux +=	"<benefPen>"
                                                                                    cXmlAux +=	xTafTag("cpfDep"           , V8A->V8A_CPFDEP  ,,.F.)
                                                                                    cXmlAux +=	xTafTag("vlrDepenSusp"     , V8A->V8A_VLSUSP  ,__cPicVlrs,.F.)
                                                                                cXmlAux +=	"</benefPen>"

                                                                                V8A->(DbSkip())
                                                                            EndDo

                                                                        EndIf

                                                                    cXmlAux +=	"</dedSusp>"

                                                                    V7Z->(DbSkip())
                                                                EndDo
                                                            EndIf

                                                        cXmlAux +=	"</infoValores>"

                                                        V7Y->(DbSkip())
                                                    EndDo
                                                    
                                                EndIf

                                            cXmlAux +=	"</infoProcRet>"

                                            V7X->(DbSkip())
                                        EndDo

                                    EndIf

                                cXmlAux +=	"</infoIRCR>"

                                V7T->(DbSkip())

                            EndDo

                        EndIf

                        If V8B->(MsSeek(xFilial("T8E") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC )))
                            
                            While !V8B->(EOF()) .And. V8B->(V8B_FILIAL + V8B_ID + V8B_VERSAO + V8B_SEQIRC) == T8E->(T8E_FILIAL + T8E_ID + T8E_VERSAO + T8E_SEQIRC)
                                
                                cXmlAux +=	"<planSaude>"

                                    cXmlAux +=	xTafTag("cnpjOper"      , V8B->V8B_CNPJOP  ,,.F.)
                                    cXmlAux +=	xTafTag("regANS"        , V8B->V8B_REGANS  ,,.T.)
                                    cXmlAux +=	xTafTag("vlrSaudeTit"   , V8B->V8B_VLRTIT  ,__cPicVlrs,.F.,,.T.)

                                    If TafColumnPos("V8C_SEQUEN")
                                        cChvSeekV8B := V8B->( V8B_ID + V8B_VERSAO + V8B_SEQIRC + V8B_SEQUEN )
                                    Else
                                        cChvSeekV8B := V8B->( V8B_ID + V8B_VERSAO + V8B_CNPJOP )
                                    EndIf 

                                    If V8C->(MsSeek(xFilial("V8B") + cChvSeekV8B))

                                        If TafColumnPos("V8C_SEQUEN")

                                            While !V8C->(EOF()) .And. V8C->(V8C_FILIAL + V8C_ID + V8C_VERSAO + V8C_SEQIRC + V8C_SEQUEN ) == V8B->(V8B_FILIAL + V8B_ID + V8B_VERSAO + V8B_SEQIRC + V8B_SEQUEN)
                                            
                                                cXmlAux +=	"<infoDepSau>"
                                                    cXmlAux +=	xTafTag("cpfDep"      , V8C->V8C_CPFDEP  ,,.F.)
                                                    cXmlAux +=	xTafTag("vlrSaudeDep" , V8C->V8C_VLRDEP  ,__cPicVlrs,.F.,,.T.)
                                                cXmlAux +=	"</infoDepSau>"

                                                V8C->(DbSkip())

                                            EndDo
                                        Else
                                            While !V8C->(EOF()) .And. V8C->(V8C_FILIAL + V8C_ID + V8C_VERSAO + V8C_CNPJOP + V8C_SEQIRC ) == V8B->(V8B_FILIAL + V8B_ID + V8B_VERSAO + V8B_CNPJOP + V8B_SEQIRC )
                                            
                                                cXmlAux +=	"<infoDepSau>"
                                                    cXmlAux +=	xTafTag("cpfDep"      , V8C->V8C_CPFDEP  ,,.F.)
                                                    cXmlAux +=	xTafTag("vlrSaudeDep" , V8C->V8C_VLRDEP  ,__cPicVlrs,.F.,,.T.)
                                                cXmlAux +=	"</infoDepSau>"

                                                V8C->(DbSkip())

                                            EndDo

                                        EndIf 

                                    EndIf

                                cXmlAux +=	"</planSaude>"

                                V8B->(DbSkip())

                            EndDo

                        EndIf

                        If V8D->(MsSeek(xFilial("T8E") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC )))

                            While !V8D->(EOF()) .And. V8D->(V8D_FILIAL + V8D_ID + V8D_VERSAO + V8D_SEQIRC ) == T8E->(T8E_FILIAL + T8E_ID + T8E_VERSAO + T8E_SEQIRC)
                            
                                cXmlAux +=	"<infoReembMed>"
                                    cXmlAux +=	xTafTag("indOrgReemb"   , V8D->V8D_INDREM  ,,.F.)
                                    cXmlAux +=	xTafTag("cnpjOper"      , V8D->V8D_CNPJOP  ,,.T.)
                                    cXmlAux +=	xTafTag("regANS"        , V8D->V8D_REGANS  ,,.T.)

                                If V8E->(MsSeek(xFilial("V8D") + V8D->( V8D_ID + V8D_VERSAO + V8D_SEQUEN + V8D_SEQIRC )))

                                    While !V8E->(EOF()) .And. V8E->(V8E_FILIAL + V8E_ID + V8E_VERSAO + V8E_SEQUEN + V8E_SEQIRC ) == V8D->( V8D_FILIAL + V8D_ID + V8D_VERSAO + V8D_SEQUEN + V8D_SEQIRC )
                                    
                                        cXmlAux +=	"<detReembTit>"
                                            cXmlAux +=	xTafTag("tpInsc"        , V8E->V8E_TPINSC  ,,.F.)
                                            cXmlAux +=	xTafTag("nrInsc"        , V8E->V8E_NRINSC  ,,.F.)
                                            cXmlAux +=	xTafTag("vlrReemb"      , V8E->V8E_VLREMB  ,__cPicVlrs,.T.)
                                            cXmlAux +=	xTafTag("vlrReembAnt"   , V8E->V8E_VLRANT  ,__cPicVlrs,.T.)

                                        cXmlAux +=	"</detReembTit>"

                                        V8E->(DbSkip())
                                    EndDo
                                EndIf

                                If V8F->(MsSeek(xFilial("V8D") + V8D->(V8D_ID + V8D_VERSAO + V8D_SEQUEN + V8D_SEQIRC )))
                                
                                    While !V8F->(EOF()) .And. V8F->(V8F_FILIAL + V8F_ID + V8F_VERSAO + V8F_SEQUEN + V8F_SEQIRC) == V8D->(V8D_FILIAL + V8D_ID + V8D_VERSAO + V8D_SEQUEN + V8D_SEQIRC )
                                        
                                        cXmlAux +=	"<infoReembDep>"
                                            
                                            cXmlAux +=	xTafTag("cpfBenef"        , V8F->V8F_CPFDEP  ,,.F.)

                                            If V8G->(MsSeek(xFilial("V8F") + V8F->( V8F_ID + V8F_VERSAO + V8F_CPFDEP + V8F_SEQUEN + V8F_SEQIRC )))
                                                
                                                While !V8G->(EOF()) .And. V8G->(V8G_FILIAL + V8G_ID + V8G_VERSAO + V8G_CPFDEP + V8G_SEQUEN + V8G_SEQIRC ) == V8F->( V8F_FILIAL + V8F_ID + V8F_VERSAO + V8F_CPFDEP + V8F_SEQUEN + V8F_SEQIRC )
                                                    
                                                    cXmlAux +=	"<detReembDep>"
                                                        cXmlAux +=	xTafTag("tpInsc"        , V8G->V8G_TPINSC  ,,.F.)
                                                        cXmlAux +=	xTafTag("nrInsc"        , V8G->V8G_NRINSC  ,,.F.)
                                                        cXmlAux +=	xTafTag("vlrReemb"      , V8G->V8G_VLREMB  ,__cPicVlrs,.T.)
                                                        cXmlAux +=	xTafTag("vlrReembAnt"   , V8G->V8G_VLRANT  ,__cPicVlrs,.T.)
                                                    cXmlAux +=	"</detReembDep>"

                                                    V8G->(DbSkip())
                                                EndDo

                                            EndIf

                                        cXmlAux +=	"</infoReembDep>"

                                        V8F->(DbSkip())
                                    EndDo

                                EndIf

                                cXmlAux +=	"</infoReembMed>"

                                V8D->(DbSkip())
                            EndDo
                        EndIf

                        cXmlAux +=	"</infoIRComplem>"
                        T8E->(DbSkip())
                    EndDo

                EndIf

                If !cXmlAux == "<infoIRComplem></infoIRComplem>"
                    cXml += cXmlAux
                EndIf 

                V7S->(DbCloseArea()) 
                V7T->(DbCloseArea()) 
                V7U->(DbCloseArea())
                V7V->(DbCloseArea())
                V7W->(DbCloseArea())
                V7X->(DbCloseArea())
                V7Y->(DbCloseArea())
                V7Z->(DbCloseArea())
                V8A->(DbCloseArea())
                V8B->(DbCloseArea())
                V8C->(DbCloseArea())
                V8D->(DbCloseArea())
                V8E->(DbCloseArea())
                V8F->(DbCloseArea())
                V8G->(DbCloseArea())

            EndIf

            
        EndIf

        cXml +=	"</ideBenef>"

        /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³Estrutura do cabecalho  ³
        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
        cXml := xTafCabXml(cXml,"T3P",cLayout,cReg, aMensal)

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Executa gravacao do registro  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lJob .And. lDicAtu
			xTafGerXml(cXml,cLayout)
		EndIf

		cFilAnt := cFilBkp

	EndIf

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function é chamada pelo TafIntegraESocial

@Return .T.

@author Vitor Siqueira
@since 29/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc(oModel as Object, nRecno as Numeric, lRotExc as Logical)

	Local aGrava     as Array
	Local aGravaT3Q  as Array
	Local aGravaT3R  as Array
	Local aGravaLE2  as Array
	Local aGravaLE3  as Array
	Local aGravaLE4  as Array
	Local aGravaT6P  as Array
	Local aGravaT6Q  as Array
	Local aGravaT6R  as Array
	Local aGravaT5U  as Array
	Local aGravaT5Y  as Array
	Local aGravaT5Z  as Array
	Local aGravaT5V  as Array
	Local aGravaT5X  as Array
    Local aGravaV6M  as Array
    Local aGravaV9I  as Array
    Local aGravaV9J  as Array
    Local aGravaV7S  as Array
    Local aGravaV7T  as Array
    Local aGravaV7U  as Array
    Local aGravaV7V  as Array
    Local aGravaV7W  as Array
    Local aGravaV7X  as Array
    Local aGravaV7Y  as Array
    Local aGravaV7Z  as Array
    Local aGravaV8A  as Array
    Local aGravaV8B  as Array
    Local aGravaV8C  as Array
    Local aGravaV8D  as Array
    Local aGravaV8E  as Array
    Local aGravaV8F  as Array
    Local aGravaV8G  as Array
    Local aGravaT8E  as Array
	Local cVerAnt    as Character
	Local cProtocolo as Character
	Local cVersao    as Character
	Local cEvento    as Character
    Local lLayout12  as Logical
	Local nI         as Numeric
	Local nT3Q       as Numeric
	Local nT3R       as Numeric
	Local nT6P       as Numeric
	Local nLE2       as Numeric
	Local nT6Q       as Numeric
	Local nLE3       as Numeric
	Local nLE4       as Numeric
	Local nT6R       as Numeric
	Local nT5U       as Numeric
	Local nT5Y       as Numeric
	Local nT5Z       as Numeric
	Local nT5V       as Numeric
	Local nT5X       as Numeric
    Local nV6M       as Numeric
    Local nV9I       as Numeric
    Local nV9J       as Numeric
    Local nV7S       as Numeric
    Local nV7T       as Numeric
    Local nV7U       as Numeric
    Local nV7V       as Numeric
    Local nV7W       as Numeric
    Local nV7X       as Numeric
    Local nV7Y       as Numeric
    Local nV7Z       as Numeric
    Local nV8A       as Numeric
    Local nV8B       as Numeric
    Local nV8C       as Numeric
    Local nV8D       as Numeric
    Local nV8E       as Numeric
    Local nV8F       as Numeric
    Local nV8G       as Numeric
	Local nT3RAdd    as Numeric
	Local nLE2Add    as Numeric
	Local nLE3Add    as Numeric
	Local nLE4Add    as Numeric
	Local nT6PAdd    as Numeric
	Local nT6QAdd    as Numeric
	Local nT6RAdd    as Numeric
	Local nT5UAdd    as Numeric
	Local nT5XAdd    as Numeric
	Local nT5YAdd    as Numeric
	Local nT5ZAdd    as Numeric
	Local nT5VAdd    as Numeric
    Local nV6MAdd    as Numeric
    Local nV7SAdd    as Numeric
    Local nV7TAdd    as Numeric
    Local nV7UAdd    as Numeric
    Local nV7VAdd    as Numeric
    Local nV7WAdd    as Numeric
    Local nV7XAdd    as Numeric
    Local nV7YAdd    as Numeric
    Local nV7ZAdd    as Numeric
    Local nV8AAdd    as Numeric
    Local nV8BAdd    as Numeric
    Local nV8CAdd    as Numeric
    Local nV8DAdd    as Numeric
    Local nV8EAdd    as Numeric
    Local nV8FAdd    as Numeric
    Local nV8GAdd    as Numeric
	Local oModelT3P  as Object
	Local oModelT3Q  as Object
	Local oModelT3R  as Object
	Local oModelLE2  as Object
	Local oModelLE3  as Object
	Local oModelLE4  as Object
	Local oModelT6P  as Object
	Local oModelT6Q  as Object
	Local oModelT5U  as Object
	Local oModelT5Y  as Object
	Local oModelT5Z  as Object
	Local oModelT5V  as Object
	Local oModelT5X  as Object
    Local oModelV6M  as Object
    Local oModelV9I  as Object
    Local oModelV9J  as Object
    Local oModelV7S  as Object
    Local oModelV7T  as Object
    Local oModelV7U  as Object
    Local oModelV7V  as Object
    Local oModelV7W  as Object
    Local oModelV7X  as Object
    Local oModelV7Y  as Object
    Local oModelV7Z  as Object
    Local oModelV8A  as Object
    Local oModelV8B  as Object
    Local oModelV8C  as Object
    Local oModelV8D  as Object
    Local oModelV8E  as Object
    Local oModelV8F  as Object
    Local oModelV8G  as Object

    Default oModel  := Nil
    Default lRotExc := .F.
    Default nRecno  := 0

	aGrava     := {}
	aGravaT3Q  := {}
	aGravaT3R  := {}
	aGravaLE2  := {}
	aGravaLE3  := {}
	aGravaLE4  := {}
	aGravaT6P  := {}
	aGravaT6Q  := {}
	aGravaT6R  := {}
	aGravaT5U  := {}
	aGravaT5Y  := {}
	aGravaT5Z  := {}
	aGravaT5V  := {}
	aGravaT5X  := {}
    aGravaV6M  := {}
    aGravaV9I  := {}
    aGravaV9J  := {}
    aGravaV7S  := {}
    aGravaV7T  := {}
    aGravaV7U  := {}
    aGravaV7V  := {}
    aGravaV7W  := {}
    aGravaV7X  := {}
    aGravaV7Y  := {}
    aGravaV7Z  := {}
    aGravaV8A  := {}
    aGravaV8B  := {}
    aGravaV8C  := {}
    aGravaV8D  := {}
    aGravaV8E  := {}
    aGravaV8F  := {}
    aGravaV8G  := {}
	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cEvento    := ""
    lLayout12  := lSimpl12 .and. TafColumnPos("V8G_NRINSC")
	nI         := 0
	nT3Q       := 0
	nT3R       := 0
	nT6P       := 0
	nLE2       := 0
	nT6Q       := 0
	nLE3       := 0
	nLE4       := 0
	nT6R       := 0
	nT5U       := 0
	nT5Y       := 0
	nT5Z       := 0
	nT5V       := 0
	nT5X       := 0
    nV6M       := 0
    nV9I       := 0
    nV9J       := 0
    nV7S       := 0
    nV7T       := 0
    nV7U       := 0
    nV7V       := 0
    nV7W       := 0
    nV7X       := 0
    nV7Y       := 0
    nV7Z       := 0
    nV8A       := 0
    nV8B       := 0
    nV8C       := 0
    nV8D       := 0
    nV8E       := 0
    nV8F       := 0
    nV8G       := 0
	nT3RAdd    := 0
	nLE2Add    := 0
	nLE3Add    := 0
	nLE4Add    := 0
	nT6PAdd    := 0
	nT6QAdd    := 0
	nT6RAdd    := 0
	nT5UAdd    := 0
	nT5XAdd    := 0
	nT5YAdd    := 0
	nT5ZAdd    := 0
	nT5VAdd    := 0
    nV6MAdd    := 0
    nV7SAdd    := 0
    nV7TAdd    := 0
    nV7UAdd    := 0
    nV7VAdd    := 0
    nV7WAdd    := 0
    nV7XAdd    := 0
    nV7YAdd    := 0
    nV7ZAdd    := 0
    nV8AAdd    := 0
    nV8BAdd    := 0
    nV8CAdd    := 0
    nV8DAdd    := 0
    nV8EAdd    := 0
    nV8FAdd    := 0
    nV8GAdd    := 0
	oModelT3P  := Nil
	oModelT3Q  := Nil
	oModelT3R  := Nil
	oModelLE2  := Nil
	oModelLE3  := Nil
	oModelLE4  := Nil
	oModelT6P  := Nil
	oModelT6Q  := Nil
	oModelT5U  := Nil
	oModelT5Y  := Nil
	oModelT5Z  := Nil
	oModelT5V  := Nil
	oModelT5X  := Nil
    oModelV6M  := Nil
    oModelV9I  := Nil
    oModelV9J  := Nil
    oModelV7S  := Nil
    oModelV7T  := Nil
    oModelV7U  := Nil
    oModelV7V  := Nil
    oModelV7W  := Nil
    oModelV7X  := Nil
    oModelV7Y  := Nil
    oModelV7Z  := Nil
    oModelV8A  := Nil
    oModelV8B  := Nil
    oModelV8C  := Nil
    oModelV8D  := Nil
    oModelV8E  := Nil
    oModelV8F  := Nil
    oModelV8G  := Nil

    If oModel != Nil

        Begin Transaction
        
            //Posiciona o item
            ("T3P")->( DBGoTo( nRecno ) )

            oModelT3P 	:= oModel:GetModel( "MODEL_T3P" )
            oModelV6M 	:= oModel:GetModel( "MODEL_V6M" )

            //Guardo as informações do registro corrente para rastro do registro
            cVerAnt   	:= oModelT3P:GetValue( "T3P_VERSAO" )
            cProtocolo	:= oModelT3P:GetValue( "T3P_PROTUL" )
            cEvento	:= oModelT3P:GetValue( "T3P_EVENTO" )

            //Armazeno as informações correntes do cadastro( Depois da alteração do Usuário )

            /*------------------------------------------
            T3P - Pgto Rendimentos do Trabalho
            --------------------------------------------*/
            For nI := 1 to Len( oModelT3P:aDataModel[ 1 ] )
                Aadd( aGrava, { oModelT3P:aDataModel[ 1, nI, 1 ], oModelT3P:aDataModel[ 1, nI, 2 ] } )
            Next nI

            If !lLaySimplif

                //Posicionando no registro
                DBSelectArea("T3Q")
                DBSetOrder(1)

                If T3Q->(MsSeek(xFilial("T3Q")+T3P->(T3P_ID + T3P_VERSAO) ) )
                    
                    oModelT3Q 	:= oModel:GetModel( "MODEL_T3Q" )
                    oModelT3R 	:= oModel:GetModel( "MODEL_T3R" )
                    oModelLE2	:= oModel:GetModel( "MODEL_LE2" )
                    oModelLE3 	:= oModel:GetModel( "MODEL_LE3" )
                    oModelLE4 	:= oModel:GetModel( "MODEL_LE4" )
                    oModelT6P 	:= oModel:GetModel( "MODEL_T6P" )
                    oModelT6Q 	:= oModel:GetModel( "MODEL_T6Q" )
                    oModelT6R 	:= oModel:GetModel( "MODEL_T6R" )
                    oModelT5U 	:= oModel:GetModel( "MODEL_T5U" )
                    oModelT5Y 	:= oModel:GetModel( "MODEL_T5Y" )
                    oModelT5Z 	:= oModel:GetModel( "MODEL_T5Z" )
                    oModelT5V 	:= oModel:GetModel( "MODEL_T5V" )
                    oModelT5X 	:= oModel:GetModel( "MODEL_T5X" )

                    /*------------------------------------------
                    T3Q - Informações dos Pagamentos Efetuados
                    --------------------------------------------*/
                    For nT3Q := 1 To oModel:GetModel( "MODEL_T3Q" ):Length()

                        oModel:GetModel( "MODEL_T3Q" ):GoLine(nT3Q)

                        If !oModel:GetModel( "MODEL_T3Q" ):IsDeleted()

                            aAdd(aGravaT3Q,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                            oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                            oModelT3Q:GetValue("T3Q_INDRES"),;
                                            oModelT3Q:GetValue("T3Q_IDPAIS"),;
                                            oModelT3Q:GetValue("T3Q_INDNIF"),;
                                            oModelT3Q:GetValue("T3Q_NIFBEN"),;
                                            oModelT3Q:GetValue("T3Q_DLOUGR"),;
                                            oModelT3Q:GetValue("T3Q_NUMLOG"),;
                                            oModelT3Q:GetValue("T3Q_COMPLE"),;
                                            oModelT3Q:GetValue("T3Q_BAIRRO"),;
                                            oModelT3Q:GetValue("T3Q_CIDADE"),;
                                            oModelT3Q:GetValue("T3Q_CEP")})

                            /*------------------------------------------
                            T3R - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                            Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                            --------------------------------------------*/
                            For nT3R := 1 to oModel:GetModel( "MODEL_T3R" ):Length()

                                oModel:GetModel( "MODEL_T3R" ):GoLine(nT3R)

                                If !oModel:GetModel( "MODEL_T3R" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T3R" ):IsDeleted()

                                        aAdd (aGravaT3R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT3R:GetValue('T3R_PERREF'),;
                                                        oModelT3R:GetValue('T3R_IDEDMD'),;
                                                        oModelT3R:GetValue('T3R_INDPGT'),;
                                                        oModelT3R:GetValue('T3R_VLRLIQ')})

                                    /*------------------------------------------
                                    LE2 - Retenções efetuadas (Rubrica)
                                    --------------------------------------------*/
                                    For nLE2 := 1 to oModel:GetModel( "MODEL_LE2" ):Length()

                                        oModel:GetModel( "MODEL_LE2" ):GoLine(nLE2)

                                        If !oModel:GetModel( "MODEL_LE2" ):IsEmpty()

                                            If !oModel:GetModel( "MODEL_LE2" ):IsDeleted()

                                                aAdd (aGravaLE2 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                oModelLE2:GetValue('LE2_QTDRUB'),;
                                                                oModelLE2:GetValue('LE2_FATRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRUNI'),;
                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                oModelLE2:GetValue('LE2_IDTABR')})

                                                /*------------------------------------------
                                                LE3 - Informações sobre beneficiários de pensão alimentícia
                                                --------------------------------------------*/
                                                For nLE3 := 1 to oModel:GetModel( "MODEL_LE3" ):Length()

                                                    oModel:GetModel( "MODEL_LE3" ):GoLine(nLE3)

                                                        If !oModel:GetModel( "MODEL_LE3" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_LE3" ):IsDeleted()

                                                                aAdd (aGravaLE3 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                                                    oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                                    oModelLE3:GetValue('LE3_CPFBEN'),;
                                                                                    oModelLE3:GetValue('LE3_DTNSBE'),;
                                                                                    oModelLE3:GetValue('LE3_NMBEN'),;
                                                                                    oModelLE3:GetValue('LE3_VLRPEN'),;
                                                                                    oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                                    oModelLE2:GetValue('LE2_RUBRIC');
                                                                                    })
                                                            EndIF

                                                        EndIF

                                                    Next//LE3

                                                EndIf

                                            EndIF

                                        Next//LE2

                                        /*------------------------------------------
                                        LE4 - Composição das bases de cálculo, deduções e isenções do IRRF
                                        --------------------------------------------*/
                                        For nLE4 := 1 to oModel:GetModel( "MODEL_LE4" ):Length()

                                            oModel:GetModel( "MODEL_LE4" ):GoLine(nLE4)

                                            If !oModel:GetModel( "MODEL_LE4" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_LE4" ):IsDeleted()

                                                    aAdd (aGravaLE4 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                        oModelT3R:GetValue('T3R_PERREF'),;
                                                                        oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                        oModelT3R:GetValue('T3R_INDPGT'),;
                                                                        oModelLE4:GetValue('LE4_IDRUBR'),;
                                                                        oModelLE4:GetValue('LE4_QTDRUB'),;
                                                                        oModelLE4:GetValue('LE4_FATRUB'),;
                                                                        oModelLE4:GetValue('LE4_VLRRUB'),;
                                                                        oModelLE4:GetValue('LE4_VLRUNI'),;
                                                                        oModelLE4:GetValue('LE4_RUBRIC'),;
                                                                        oModelLE4:GetValue('LE4_IDTABR'),;
                                                                        oModelLE4:GetValue('LE4_MATRIC')})

                                                EndIf
                                            EndIf
                                        Next//LE4

                                    EndIf
                                EndIf
                            Next//nT3R

                            /*------------------------------------------
                            T6P - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                            Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                            --------------------------------------------*/
                            For nT6P := 1 to oModel:GetModel( "MODEL_T6P" ):Length()

                                oModel:GetModel( "MODEL_T6P" ):GoLine(nT6P)

                                If !oModel:GetModel( "MODEL_T6P" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T6P" ):IsDeleted()

                                        aAdd (aGravaT6P ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT6P:GetValue('T6P_PERREF'),;
                                                        oModelT6P:GetValue('T6P_IDEDMD'),;
                                                        oModelT6P:GetValue('T6P_INDPGT'),;
                                                        oModelT6P:GetValue('T6P_VLRLIQ')})

                                        /*------------------------------------------
                                            T6Q - Retenções efetuadas (Rubrica)
                                        --------------------------------------------*/
                                        For nT6Q := 1 to oModel:GetModel( "MODEL_T6Q" ):Length()

                                            oModel:GetModel( "MODEL_T6Q" ):GoLine(nT6Q)

                                            If !oModel:GetModel( "MODEL_T6Q" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T6Q" ):IsDeleted()

                                                    aAdd (aGravaT6Q ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                                    oModelT6Q:GetValue('T6Q_IDRUBR'),;
                                                                    oModelT6Q:GetValue('T6Q_QTDRUB'),;
                                                                    oModelT6Q:GetValue('T6Q_FATRUB'),;
                                                                    oModelT6Q:GetValue('T6Q_VLRRUB'),;
                                                                    oModelT6Q:GetValue('T6Q_VLRUNI'),;
                                                                    oModelT6Q:GetValue('T6Q_RUBRIC'),;
                                                                    oModelT6Q:GetValue('T6Q_IDTABR')})

                                                EndIf
                                            EndIf
                                        Next//T6Q

                                        /*------------------------------------------
                                            T6R - Composição das bases de cálculo, deduções e isenções do IRRF
                                        --------------------------------------------*/
                                        For nT6R := 1 to oModel:GetModel( "MODEL_T6R" ):Length()

                                            oModel:GetModel( "MODEL_T6R" ):GoLine(nT6R)

                                            If !oModel:GetModel( "MODEL_T6R" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T6R" ):IsDeleted()

                                                    aAdd (aGravaT6R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                                    oModelT6R:GetValue('T6R_IDRUBR'),;
                                                                    oModelT6R:GetValue('T6R_QTDRUB'),;
                                                                    oModelT6R:GetValue('T6R_FATRUB'),;
                                                                    oModelT6R:GetValue('T6R_VLRRUB'),;
                                                                    oModelT6R:GetValue('T6R_VLRUNI'),;
                                                                    oModelT6R:GetValue('T6R_RUBRIC'),;
                                                                    oModelT6R:GetValue('T6R_IDTABR')})

                                                EndIf
                                            EndIf
                                        Next//T6R

                                    EndIf
                                EndIf
                            Next//nT6P

                            /*------------------------------------------
                            T5U - Detalhamento Rub Recibo Férias
                            --------------------------------------------*/
                            For nT5U := 1 to oModel:GetModel( "MODEL_T5U" ):Length()

                                oModel:GetModel( "MODEL_T5U" ):GoLine(nT5U)

                                If !oModel:GetModel( "MODEL_T5U" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T5U" ):IsDeleted()

                                        aAdd (aGravaT5U ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT5U:GetValue('T5U_IDCATE'),;
                                                        oModelT5U:GetValue('T5U_DTINIG'),;
                                                        oModelT5U:GetValue('T5U_QTDIAS'),;
                                                        oModelT5U:GetValue('T5U_VLRLIQ'),;
                                                        oModelT5U:GetValue('T5U_MATRIC')})

                                        /*------------------------------------------
                                        T5Y - Retenções efetuadas (Rubrica)
                                        --------------------------------------------*/
                                        For nT5Y := 1 to oModel:GetModel( "MODEL_T5Y" ):Length()

                                            oModel:GetModel( "MODEL_T5Y" ):GoLine(nT5Y)

                                            If !oModel:GetModel( "MODEL_T5Y" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5Y" ):IsDeleted()

                                                    aAdd (aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                    oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                    oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                    oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                    oModelT5Y:GetValue('T5Y_VLRUNI'),;
                                                                    oModelT5Y:GetValue('T5Y_RUBRIC'),;
                                                                    oModelT5Y:GetValue('T5Y_IDTABR')})

                                                    /*------------------------------------------
                                                    T5Z - Informações sobre beneficiários de pensão alimentícia
                                                    --------------------------------------------*/
                                                    For nT5Z := 1 to oModel:GetModel( "MODEL_T5Z" ):Length()

                                                        oModel:GetModel( "MODEL_T5Z" ):GoLine(nT5Z)

                                                        If !oModel:GetModel( "MODEL_T5Z" ):IsEmpty()

                                                            If !oModel:GetModel( "MODEL_T5Z" ):IsDeleted()

                                                                aAdd (aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                                                    oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                                    oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                                    oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                                    oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                                    oModelT5Z:GetValue('T5Z_VLRPEN')})

                                                            EndIF
                                                        EndIf
                                                    Next//T5Z

                                                EndIf
                                            EndIf
                                        Next//T5Y

                                    EndIf
                                EndIf
                            Next//T5U

                            /*------------------------------------------
                            T5V - Pgto Relat Compet Anteriores
                            --------------------------------------------*/
                            For nT5V := 1 to oModel:GetModel( "MODEL_T5V" ):Length()

                                oModel:GetModel( "MODEL_T5V" ):GoLine(nT5V)

                                If !oModel:GetModel( "MODEL_T5V" ):IsEmpty()

                                    If !oModel:GetModel( "MODEL_T5V" ):IsDeleted()

                                        aAdd (aGravaT5V ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                        oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                        oModelT5V:GetValue('T5V_IDCATE')})

                                        /*------------------------------------------
                                        T5X - Retenções efetuadas (Rubrica)
                                        --------------------------------------------*/
                                        For nT5X := 1 to oModel:GetModel( "MODEL_T5X" ):Length()

                                            oModel:GetModel( "MODEL_T5X" ):GoLine(nT5X)

                                            If !oModel:GetModel( "MODEL_T5X" ):IsEmpty()

                                                If !oModel:GetModel( "MODEL_T5X" ):IsDeleted()

                                                    aAdd (aGravaT5X ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                    oModelT5V:GetValue('T5V_IDCATE'),;
                                                                    oModelT5X:GetValue('T5X_SEQUEN'),;
                                                                    oModelT5X:GetValue('T5X_IDTPIR'),;
                                                                    oModelT5X:GetValue('T5X_VLRBCI')})

                                                EndIf
                                            EndIf
                                        Next//T5X

                                    EndIf
                                EndIf
                            Next//nT5V

                        EndIf
                    Next //nT3Q

                EndIf

            Else

                V6M->(DbSetOrder(1))

                If V6M->(MsSeek(xFilial("V6M") + T3P->(T3P_ID + T3P_VERSAO)))

                    oModelV6M := oModel:GetModel("MODEL_V6M")
                    oModelV9I := oModel:GetModel("MODEL_V9I")
                    oModelV9J := oModel:GetModel("MODEL_V9J")

                    For nV6M := 1 To oModel:GetModel("MODEL_V6M"):Length()

                        oModel:GetModel("MODEL_V6M"):GoLine(nV6M)

                        If !oModel:GetModel("MODEL_V6M"):IsEmpty()

                            If !oModel:GetModel("MODEL_V6M"):IsDeleted()

                                AAdd(aGravaV6M, {   oModelV6M:GetValue("V6M_DTPGTO"),;
                                                    oModelV6M:GetValue("V6M_TPPGTO"),;
                                                    oModelV6M:GetValue("V6M_PERREF"),;
                                                    oModelV6M:GetValue("V6M_INDDEV"),;
                                                    oModelV6M:GetValue("V6M_VLRLIQ")    })

                                If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")

                                    AAdd(aGravaV6M[nV6M], oModelV6M:GetValue("V6M_PAIEXT"))

                                    For nV9I := 1 To oModel:GetModel("MODEL_V9I"):Length()

                                        oModel:GetModel("MODEL_V9I"):GoLine(nV9I)

                                        If !oModel:GetModel("MODEL_V9I"):IsEmpty()

                                            If !oModel:GetModel("MODEL_V9I"):IsDeleted()

                                                AAdd(aGravaV9I, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                    oModelV6M:GetValue("V6M_PERREF"),;
                                                                    oModelV6M:GetValue("V6M_INDDEV"),;
                                                                    oModelV9I:GetValue("V9I_INDNIF"),;
                                                                    oModelV9I:GetValue("V9I_NIFBEN"),;
                                                                    oModelV9I:GetValue("V9I_FRMTRI")    })
                                            
                                                For nV9J := 1 To oModel:GetModel("MODEL_V9J"):Length()

                                                    oModel:GetModel("MODEL_V9J"):GoLine(nV9J)

                                                    If !oModel:GetModel("MODEL_V9J"):IsEmpty()

                                                        If !oModel:GetModel("MODEL_V9J"):IsDeleted()

                                                            AAdd(aGravaV9J, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                                oModelV6M:GetValue("V6M_PERREF"),;
                                                                                oModelV6M:GetValue("V6M_INDDEV"),;   
                                                                                oModelV9J:GetValue("V9J_DSCLOG"),;
                                                                                oModelV9J:GetValue("V9J_NRLOGR"),;
                                                                                oModelV9J:GetValue("V9J_COMPLE"),;
                                                                                oModelV9J:GetValue("V9J_BAIRRO"),;
                                                                                oModelV9J:GetValue("V9J_CIDADE"),;
                                                                                oModelV9J:GetValue("V9J_ESTADO"),;
                                                                                oModelV9J:GetValue("V9J_CODPOS"),;
                                                                                oModelV9J:GetValue("V9J_TELEF" )   })
                                                        
                                                        EndIf
                                                    EndIf
                                                Next
                                            EndIf
                                        EndIf
                                    Next
                                EndIf
                            EndIf
                        EndIf
                    Next
                EndIf 

                If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC") )
                
                    V7S->(DBSetOrder(1))
                    If V7S->(MsSeek(xFilial("V7S") + T3P->(T3P_ID + T3P_VERSAO)))
                        oModelV7S := oModel:GetModel("MODEL_V7S")

                        For nV7S := 1 To oModel:GetModel("MODEL_V7S"):Length()
                            oModel:GetModel("MODEL_V7S"):GoLine(nV7S)

                            If !oModel:GetModel("MODEL_V7S"):IsEmpty()
                                If !oModel:GetModel("MODEL_V7S"):IsDeleted()
                                    AAdd(aGravaV7S, {   oModelV7S:GetValue("V7S_CPFDEP"),;
                                                        oModelV7S:GetValue("V7S_DTNASC"),;
                                                        oModelV7S:GetValue("V7S_NMDEP" ),;
                                                        oModelV7S:GetValue("V7S_DPIRRF"),;
                                                        oModelV7S:GetValue("V7S_TPDEP" ),;
                                                        oModelV7S:GetValue("V7S_DSCDEP") })

                                EndIf 
                            EndIf 

                        Next
                        
                    EndIf 

                    V7T->(DBSetOrder(1))
                    If V7T->(MsSeek(xFilial("V7T") + T3P->(T3P_ID + T3P_VERSAO)))
                        oModelV7T := oModel:GetModel("MODEL_V7T")
                        oModelV7U := oModel:GetModel("MODEL_V7U")
                        oModelV7V := oModel:GetModel("MODEL_V7V")
                        oModelV7W := oModel:GetModel("MODEL_V7W")
                        oModelV7X := oModel:GetModel("MODEL_V7X")
                        oModelV7Y := oModel:GetModel("MODEL_V7Y")
                        oModelV7Z := oModel:GetModel("MODEL_V7Z")
                        oModelV8A := oModel:GetModel("MODEL_V8A")

                        For nV7T := 1 To oModel:GetModel("MODEL_V7T"):Length()
                            oModel:GetModel("MODEL_V7T"):GoLine(nV7T)

                            If !oModel:GetModel("MODEL_V7T"):IsEmpty()
                                If !oModel:GetModel("MODEL_V7T"):IsDeleted()
                                    AAdd(aGravaV7T, {   oModelV7T:GetValue("V7T_TPCR") })

                                    For nV7U := 1 To oModel:GetModel("MODEL_V7U"):Length()
                                        oModel:GetModel("MODEL_V7U"):GoLine(nV7U)

                                        If !oModel:GetModel("MODEL_V7U"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V7U"):IsDeleted()
                                                AAdd(aGravaV7U, {   oModelV7T:GetValue("V7T_TPCR"  ),;
                                                                    oModelV7U:GetValue("V7U_TPREND"),;
                                                                    oModelV7U:GetValue("V7U_CPFDEP"),;
                                                                    oModelV7U:GetValue("V7U_VLRDED") })
                                            EndIf 
                                        EndIf 
                                    Next

                                    For nV7V := 1 To oModel:GetModel("MODEL_V7V"):Length()
                                        oModel:GetModel("MODEL_V7V"):GoLine(nV7V)

                                        If !oModel:GetModel("MODEL_V7V"):IsEmpty()
                                                If !oModel:GetModel("MODEL_V7V"):IsDeleted()
                                                AAdd(aGravaV7V, {   oModelV7T:GetValue("V7T_TPCR"  ),;
                                                                    oModelV7V:GetValue("V7V_TPREND"),;
                                                                    oModelV7V:GetValue("V7V_CPFDEP"),;
                                                                    oModelV7V:GetValue("V7V_VLPEN" ) })
                                            EndIf
                                        EndIf 
                                    Next 

                                    For nV7W := 1 To oModel:GetModel("MODEL_V7W"):Length()
                                        oModel:GetModel("MODEL_V7W"):GoLine(nV7W)

                                        If !oModel:GetModel("MODEL_V7W"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V7W"):IsDeleted()
                                                AAdd(aGravaV7W, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                    oModelV7W:GetValue("V7W_TPREV"  ),;
                                                                    oModelV7W:GetValue("V7W_INSCPL" ),;
                                                                    oModelV7W:GetValue("V7W_VLCOMP" ),;
                                                                    oModelV7W:GetValue("V7W_VLPATR" )})
                                            EndIf
                                        EndIf 
                                    Next

                                    For nV7X := 1 To oModel:GetModel("MODEL_V7X"):Length()
                                        oModel:GetModel("MODEL_V7X"):GoLine(nV7X)

                                        If !oModel:GetModel("MODEL_V7X"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V7X"):IsDeleted()
                                                AAdd(aGravaV7X, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                    oModelV7X:GetValue("V7X_TPPROC"  ),;
                                                                    oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                    oModelV7X:GetValue("V7X_CODSUP" )})

                                                For nV7Y := 1 To oModel:GetModel("MODEL_V7Y"):Length()
                                                    oModel:GetModel("MODEL_V7Y"):GoLine(nV7Y)
                                                    If !oModel:GetModel("MODEL_V7X"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V7X"):IsDeleted()
                                                            AAdd(aGravaV7Y, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                oModelV7X:GetValue("V7X_TPPROC"  ),;
                                                                                oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                oModelV7Y:GetValue("V7Y_VLRRET" ),;
                                                                                oModelV7Y:GetValue("V7Y_VLRJUD" ),;
                                                                                oModelV7Y:GetValue("V7Y_VLACAL" ),;
                                                                                oModelV7Y:GetValue("V7Y_VLAANT" ),;
                                                                                oModelV7Y:GetValue("V7Y_VLSUSP" )})

                                                            For nV7Z := 1 To oModel:GetModel("MODEL_V7Z"):Length()
                                                                oModel:GetModel("MODEL_V7Z"):GoLine(nV7Z)
                                                                If !oModel:GetModel("MODEL_V7Z"):IsEmpty()
                                                                    If !oModel:GetModel("MODEL_V7Z"):IsDeleted()
                                                                        AAdd(aGravaV7Z, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                            oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                            oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                            oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                            oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                            oModelV7Z:GetValue("V7Z_TPDEDU" ),;
                                                                                            oModelV7Z:GetValue("V7Z_VLSUSP" ),;
                                                                                            oModelV7Z:GetValue("V7Z_INSCPL" ),;
                                                                                            oModelV7Z:GetValue("V7Z_VLFUNP" ),;
                                                                                            oModelV7Z:GetValue("V7Z_SEQUEN" )})

                                                                        For nV8A := 1 To oModel:Getmodel("MODEL_V8A"):Length()
                                                                            oModel:GetModel("MODEL_V8A"):GoLine(nV8A)
                                                                            If !oModel:GetModel("MODEL_V8A"):IsEmpty()
                                                                                If !oModel:GetModel("MODEL_V8A"):IsDeleted()
                                                                                    AAdd(aGravaV8A, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                                        oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                                        oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                                        oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                                        oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                                        oModelV8A:GetValue("V8A_CPFDEP" ),;
                                                                                                        oModelV8A:GetValue("V8A_VLSUSP" ),;
                                                                                                        oModelV7Z:GetValue("V7Z_SEQUEN" )})
                                                                                EndIf
                                                                            EndIf
                                                                        Next
                                                                    EndIf
                                                                EndIf
                                                            Next 
                                                        EndIf
                                                    EndIf
                                                Next
                                            EndIf
                                        EndIf
                                    Next
                                EndIf 
                            EndIf
                        Next 
                    EndIf 

                    V8B->(DBSetOrder(1))
                    If V8B->(MsSeek(xFilial("V8B") + T3P->(T3P_ID + T3P_VERSAO)))
                        oModelV8B := oModel:GetModel("MODEL_V8B")
                        oModelV8C := oModel:GetModel("MODEL_V8C")

                        For nV8B := 1 To oModel:Getmodel("MODEL_V8B"):Length()
                            oModel:GetModel("MODEL_V8B"):GoLine(nV8B)

                            If !oModel:GetModel("MODEL_V8B"):IsEmpty()
                                If !oModel:GetModel("MODEL_V8B"):IsDeleted()
                                    AAdd(aGravaV8B, {   oModelV8B:GetValue("V8B_CNPJOP" ),;
                                                        oModelV8B:GetValue("V8B_REGANS" ),;
                                                        oModelV8B:GetValue("V8B_VLRTIT" ) })

                                    For nV8C := 1 To oModel:Getmodel("MODEL_V8C"):Length()
                                        oModel:GetModel("MODEL_V8C"):GoLine(nV8C)

                                        If !oModel:GetModel("MODEL_V8C"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V8C"):IsDeleted()
                                                AAdd(aGravaV8C, {   oModelV8B:GetValue("V8B_CNPJOP" ),;
                                                                    oModelV8C:GetValue("V8C_CPFDEP" ),;
                                                                    oModelV8C:GetValue("V8C_VLRDEP" ) })
                                            EndIf 
                                        EndIf 
                                    Next 
                                EndIf
                            EndIf 
                        Next

                    EndIf

                    V8D->(DBSetOrder(1))
                    If V8D->(MsSeek(xFilial("V8D") + T3P->(T3P_ID + T3P_VERSAO)))
                        oModelV8D := oModel:GetModel("MODEL_V8D")
                        oModelV8E := oModel:GetModel("MODEL_V8E")
                        oModelV8F := oModel:GetModel("MODEL_V8F")
                        oModelV8G := oModel:GetModel("MODEL_V8G")

                        For nV8D := 1 To oModel:Getmodel("MODEL_V8D"):Length()
                            oModel:GetModel("MODEL_V8D"):GoLine(nV8D)
                            If !oModel:GetModel("MODEL_V8D"):IsEmpty()
                                If !oModel:GetModel("MODEL_V8D"):IsDeleted()
                                    AAdd(aGravaV8D, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                        oModelV8D:GetValue("V8D_INDREM" ),;
                                                        oModelV8D:GetValue("V8D_CNPJOP" ),;
                                                        oModelV8D:GetValue("V8D_REGANS" )   })

                                    For nV8F := 1 To oModel:Getmodel("MODEL_V8F"):Length()
                                        oModel:GetModel("MODEL_V8F"):GoLine(nV8F)

                                        If !oModel:GetModel("MODEL_V8F"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V8F"):IsDeleted()
                                                    AAdd(aGravaV8F, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                                        oModelV8F:GetValue("V8F_CPFDEP" )   })
                                                                        
                                                For nV8G := 1 To oModel:Getmodel("MODEL_V8G"):Length()
                                                    oModel:GetModel("MODEL_V8G"):GoLine(nV8G)

                                                    If !oModel:GetModel("MODEL_V8G"):IsEmpty()
                                                        If !oModel:GetModel("MODEL_V8G"):IsDeleted()
                                                            AAdd(aGravaV8G, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                                                oModelV8F:GetValue("V8F_CPFDEP" ),;
                                                                                oModelV8G:GetValue("V8G_TPINSC" ),;
                                                                                oModelV8G:GetValue("V8G_NRINSC" ),;
                                                                                oModelV8G:GetValue("V8G_VLREMB" ),;
                                                                                oModelV8G:GetValue("V8G_VLRANT" )   })
                                                        EndIf 
                                                    EndIf
                                                Next
                                            EndIf 
                                        EndIf 
                                    Next

                                    For nV8E := 1 To oModel:Getmodel("MODEL_V8E"):Length()
                                        oModel:GetModel("MODEL_V8E"):GoLine(nV8E)

                                        If !oModel:GetModel("MODEL_V8E"):IsEmpty()
                                            If !oModel:GetModel("MODEL_V8E"):IsDeleted()
                                                AAdd(aGravaV8E, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                                    oModelV8E:GetValue("V8E_TPINSC" ),;
                                                                    oModelV8E:GetValue("V8E_NRINSC" ),;
                                                                    oModelV8E:GetValue("V8E_VLREMB" ),;
                                                                    oModelV8E:GetValue("V8E_VLRANT" )   })
                                            EndIf 
                                        EndIf
                                    Next
                                EndIf 
                            EndIf
                        Next 
                    EndIf 
                ElseIf lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC")

                    T8E->(DBSetOrder(1))
                    If T8E->(MsSeek(xFilial("T8E") + T3P->(T3P_ID + T3P_VERSAO)))

                        oModelV7S := oModel:GetModel("MODEL_V7S")
                        oModelV7T := oModel:GetModel("MODEL_V7T")
                        oModelV7U := oModel:GetModel("MODEL_V7U")
                        oModelV7V := oModel:GetModel("MODEL_V7V")
                        oModelV7W := oModel:GetModel("MODEL_V7W")
                        oModelV7X := oModel:GetModel("MODEL_V7X")
                        oModelV7Y := oModel:GetModel("MODEL_V7Y")
                        oModelV7Z := oModel:GetModel("MODEL_V7Z")
                        oModelV8A := oModel:GetModel("MODEL_V8A")
                        oModelT8E := oModel:GetModel("MODEL_T8E")

                        GetAgrava( oModel, oModelV7S, oModelV7T, oModelV7U, oModelV7V, oModelV7W, oModelV7X, oModelV7Y, oModelV7Z, oModelV8A, oModelV8B,;
                                   oModelV8C, oModelV8D, oModelV8E, oModelV8F, oModelV8G, oModelT8E, @aGravaT8E, @aGravaV7T, @aGravaV7U, @aGravaV7V,;
                                   @aGravaV7W, @aGravaV7X, @aGravaV7Y, @aGravaV7Z, @aGravaV8A, @aGravaV8B, @aGravaV8C, @aGravaV8D, @aGravaV8F, @aGravaV8G, @aGravaV8E, @aGravaV7S )
                    EndIf

                EndIf 
            EndIf

            /*----------------------------------------------------------
            Seto o campo como Inativo e gravo a versao do novo registro
            no registro anterior

            ATENCAO -> A alteracao destes campos deve sempre estar
            abaixo do Loop do For, pois devem substituir as informacoes
            que foram armazenadas no Loop acima
            -----------------------------------------------------------*/
            FAltRegAnt( "T3P", "2" )

            /*----------------------------------------------------------
            Apos deixar o registro corrente como inativo eu seto a
            operação de inclusão para o novo registro
            -----------------------------------------------------------*/
            oModel:DeActivate()
            oModel:SetOperation( 3 )
            oModel:Activate()

            /*----------------------------------------------------------
            Neste momento eu realizo a gravação de um novo registro idêntico
            ao original, apenas com as alterações nos campos modificados
            pelo usuário no cadastro
            -----------------------------------------------------------*/

            /*------------------------------------------
                T3P - Pgto Rendimentos do Trabalho
            --------------------------------------------*/
            For nI := 1 to Len( aGrava )
                oModel:LoadValue( "MODEL_T3P", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
            Next nI

            If !lLaySimplif

                /*------------------------------------------
                T3Q - Informações dos Pagamentos Efetuados
                --------------------------------------------*/
                For nT3Q := 1 to Len( aGravaT3Q )

                    oModel:GetModel( 'MODEL_T3Q' ):LVALID	:= .T.

                    If nT3Q > 1
                        oModel:GetModel( "MODEL_T3Q" ):AddLine()
                    EndIf

                    oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO" , aGravaT3Q[nT3Q][1] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO" , aGravaT3Q[nT3Q][2] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES",  aGravaT3Q[nT3Q][3] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS",  aGravaT3Q[nT3Q][4] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF",  aGravaT3Q[nT3Q][5] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN",  aGravaT3Q[nT3Q][6] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR",  aGravaT3Q[nT3Q][7] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG",  aGravaT3Q[nT3Q][8] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE",  aGravaT3Q[nT3Q][9] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO",  aGravaT3Q[nT3Q][10] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE",  aGravaT3Q[nT3Q][11] )
                    oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   ,  aGravaT3Q[nT3Q][12] )

                    /*------------------------------------------------------------------------------
                    T3R - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------------------------------------------*/
                    nT3RAdd := 1
                    For nT3R := 1 to Len( aGravaT3R )

                        If  DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                            oModel:GetModel( "MODEL_T3R" ):LVALID := .T.

                            If nT3RAdd > 1
                                oModel:GetModel( "MODEL_T3R" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T3R", "T3R_PERREF", aGravaT3R[nT3R][3] )
                            oModel:LoadValue( "MODEL_T3R", "T3R_IDEDMD", aGravaT3R[nT3R][4] )
                            oModel:LoadValue( "MODEL_T3R", "T3R_INDPGT", aGravaT3R[nT3R][5] )
                            oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", aGravaT3R[nT3R][6] )

                            /*------------------------------------------
                            LE2 - Retenções efetuadas (Rubrica)
                            --------------------------------------------*/
                            nLE2Add := 1
                            For nLE2 := 1 to Len( aGravaLE2 )

                                If  DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]
                                    
                                    oModel:GetModel( "MODEL_LE2" ):LVALID := .T.

                                    If nLE2Add > 1
                                        oModel:GetModel( "MODEL_LE2" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_LE2" , "LE2_IDRUBR", aGravaLE2[nLE2][6] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_QTDRUB", aGravaLE2[nLE2][7] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_FATRUB", aGravaLE2[nLE2][8] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_VLRRUB", aGravaLE2[nLE2][9] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_VLRUNI", aGravaLE2[nLE2][10] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_SEQUEN", aGravaLE2[nLE2][11] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_RUBRIC", aGravaLE2[nLE2][12] )
                                    oModel:LoadValue( "MODEL_LE2" , "LE2_IDTABR", aGravaLE2[nLE2][13] )


                                    /*------------------------------------------------------------
                                    LE3 - Informações sobre beneficiários de pensão alimentícia
                                    --------------------------------------------------------------*/
                                    nLE3Add := 1
                                    For nLE3 := 1 to Len( aGravaLE3 )
                                        
                                        If  DTOS(aGravaLE3[nLE3][1])+aGravaLE3[nLE3][2]+aGravaLE3[nLE3][3]+aGravaLE3[nLE3][4]+aGravaLE3[nLE3][5]+aGravaLE3[nLE3][6] == ;
                                            DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5]+aGravaLE2[nLE2][6]
                                        
                                            oModel:GetModel( "MODEL_LE3" ):LVALID := .T.

                                            If nLE3Add > 1
                                                oModel:GetModel( "MODEL_LE3" ):AddLine()
                                            EndIf

                                            oModel:LoadValue( "MODEL_LE3" , "LE3_CPFBEN", aGravaLE3[nLE3][7] )
                                            oModel:LoadValue( "MODEL_LE3" , "LE3_DTNSBE", aGravaLE3[nLE3][8] )
                                            oModel:LoadValue( "MODEL_LE3" , "LE3_NMBEN",  aGravaLE3[nLE3][9] )
                                            oModel:LoadValue( "MODEL_LE3" , "LE3_VLRPEN", aGravaLE3[nLE3][10] )

                                            nLE3Add++

                                        EndIf

                                    Next//nLE3

                                    nLE2Add++

                                EndIf

                            Next//LE2

                            /*----------------------------------------------------------------------------------
                            LE4 - Composição das bases de cálculo, deduções e isenções do IRRF
                            -----------------------------------------------------------------------------------*/
                            nLE4Add := 1
                            For nLE4 := 1 to Len( aGravaLE4 )

                                If  DTOS(aGravaLE4[nLE4][1])+aGravaLE4[nLE4][2]+aGravaLE4[nLE4][3]+aGravaLE4[nLE4][4]+aGravaLE4[nLE4][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]
                                    
                                    oModel:GetModel( "MODEL_LE4" ):LVALID := .T.

                                    If nLE4Add > 1
                                        oModel:GetModel( "MODEL_LE4" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_LE4" , "LE4_IDRUBR", aGravaLE4[nLE4][6] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_QTDRUB", aGravaLE4[nLE4][7] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_FATRUB", aGravaLE4[nLE4][8] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_VLRUNI", aGravaLE4[nLE4][9] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_VLRRUB", aGravaLE4[nLE4][10] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_RUBRIC", aGravaLE4[nLE4][11] )
                                    oModel:LoadValue( "MODEL_LE4" , "LE4_IDTABR", aGravaLE4[nLE4][12] )

                                    nLE4Add++

                                EndIf

                            Next//nLE4

                            nT3RAdd++

                        EndIf

                    Next //nT3R

                    /*------------------------------------------------------------
                        T6P - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------------------------*/
                    nT6PAdd := 1
                    For nT6P := 1 to Len( aGravaT6P )

                        If  DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                            oModel:GetModel( "MODEL_T6P" ):LVALID := .T.

                            If nT6PAdd > 1
                                oModel:GetModel( "MODEL_T6P" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T6P", "T6P_PERREF", aGravaT6P[nT6P][3] )
                            oModel:LoadValue( "MODEL_T6P", "T6P_IDEDMD", aGravaT6P[nT6P][4] )
                            oModel:LoadValue( "MODEL_T6P", "T6P_INDPGT", aGravaT6P[nT6P][5] )
                            oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", aGravaT6P[nT6P][6] )

                            /*------------------------------------------
                            T6Q - Retenções efetuadas (Rubrica)
                            --------------------------------------------*/
                            nT6QAdd := 1
                            For nT6Q := 1 to Len( aGravaT6Q )

                                If  DTOS(aGravaT6Q[nT6Q][1])+aGravaT6Q[nT6Q][2]+aGravaT6Q[nT6Q][3]+aGravaT6Q[nT6Q][4]+aGravaT6Q[nT6Q][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]
                                    
                                    oModel:GetModel( "MODEL_T6Q" ):LVALID := .T.

                                    If nT6QAdd > 1
                                        oModel:GetModel( "MODEL_T6Q" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDRUBR", aGravaT6Q[nT6Q][6]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_QTDRUB", aGravaT6Q[nT6Q][7]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_FATRUB", aGravaT6Q[nT6Q][8]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRRUB", aGravaT6Q[nT6Q][9]  )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRUNI", aGravaT6Q[nT6Q][10] )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_RUBRIC", aGravaT6Q[nT6Q][11] )
                                    oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDTABR", aGravaT6Q[nT6Q][12] )

                                    nT6QAdd++

                                EndIf

                            Next//T6Q

                            /*------------------------------------------
                            T6R - Composição das bases de cálculo, deduções e isenções do IRRF
                            --------------------------------------------*/
                            nT6RAdd := 1
                            For nT6R := 1 to Len( aGravaT6R )

                                If  DTOS(aGravaT6R[nT6R][1])+aGravaT6R[nT6R][2]+aGravaT6R[nT6R][3]+aGravaT6R[nT6R][4]+aGravaT6R[nT6R][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]
                                    
                                    oModel:GetModel( "MODEL_T6R" ):LVALID := .T.

                                    If nT6RAdd > 1
                                        oModel:GetModel( "MODEL_T6R" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T6R" , "T6R_IDRUBR", aGravaT6R[nT6R][6] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_QTDRUB", aGravaT6R[nT6R][7] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_FATRUB", aGravaT6R[nT6R][8] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_VLRUNI", aGravaT6R[nT6R][9] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_VLRRUB", aGravaT6R[nT6R][10] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_RUBRIC", aGravaT6R[nT6R][11] )
                                    oModel:LoadValue( "MODEL_T6R" , "T6R_IDTABR", aGravaT6R[nT6R][12] )

                                    nT6RAdd++

                                EndIf

                            Next//nT6R

                            nT6PAdd++

                        EndIf
                        
                    Next //nT6P

                    /*------------------------------------------
                    T5U - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------*/
                    nT5UAdd := 1
                    For nT5U := 1 to Len( aGravaT5U )

                        If  DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                            oModel:GetModel( "MODEL_T5U" ):LVALID := .T.

                            If nT5UAdd > 1
                                oModel:GetModel( "MODEL_T5U" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", aGravaT5U[nT5U][3] )
                            oModel:LoadValue( "MODEL_T5U", "T5U_DTINIG", aGravaT5U[nT5U][4] )
                            oModel:LoadValue( "MODEL_T5U", "T5U_QTDIAS", aGravaT5U[nT5U][5] )
                            oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", aGravaT5U[nT5U][6] )

                            /*------------------------------------------
                            T5Y - Retenções efetuadas (Rubrica)
                            --------------------------------------------*/
                            nT5YAdd := 1
                            For nT5Y := 1 to Len( aGravaT5Y )

                                If  DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])== DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2]+aGravaT5U[nT5U][3]+DTOS(aGravaT5U[nT5U][4])
                                    
                                    oModel:GetModel( "MODEL_T5Y" ):LVALID := .T.

                                    If nT5YAdd > 1
                                        oModel:GetModel( "MODEL_T5Y" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDRUBR", aGravaT5Y[nT5Y][5] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_QTDRUB", aGravaT5Y[nT5Y][6] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_FATRUB", aGravaT5Y[nT5Y][7] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRRUB", aGravaT5Y[nT5Y][8] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRUNI", aGravaT5Y[nT5Y][9] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_RUBRIC", aGravaT5Y[nT5Y][10] )
                                    oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDTABR", aGravaT5Y[nT5Y][11] )

                                    /*------------------------------------------
                                    T5Z - Informações sobre beneficiários de pensão alimentícia
                                    --------------------------------------------*/
                                    nT5ZAdd := 1
                                    For nT5Z := 1 to Len( aGravaT5Z )
                                        
                                        If  DTOS(aGravaT5Z[nT5Z][1])+aGravaT5Z[nT5Z][2]+aGravaT5Z[nT5Z][3]+DTOS(aGravaT5Z[nT5Z][4])+aGravaT5Z[nT5Z][5] == DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+aGravaT5Y[nT5Y][5]
                                            
                                            oModel:GetModel( "MODEL_T5Z" ):LVALID := .T.

                                            If nT5ZAdd > 1
                                                oModel:GetModel( "MODEL_T5Z" ):AddLine()
                                            EndIf

                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_CPFBEN", aGravaT5Z[nT5Z][6] )
                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_DTNSBE", aGravaT5Z[nT5Z][7] )
                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_NMBEN",  aGravaT5Z[nT5Z][8] )
                                            oModel:LoadValue( "MODEL_T5Z" , "T5Z_VLRPEN", aGravaT5Z[nT5Z][9] )

                                            nT5ZAdd++

                                        EndIf

                                    Next//T5Z

                                    nT5YAdd++

                                EndIf

                            Next//T5Y

                            nT5UAdd++

                        EndIf

                    Next //T5U

                    /*------------------------------------------
                    T5V - Detalhamento dos pagamentos efetuados, apurados em S-1200 ou S-1202/
                    Detalhamento dos pagamentos efetuados relativos a rescisões contratuais
                    --------------------------------------------*/
                    nT5VAdd := 1
                    For nT5V := 1 to Len( aGravaT5V )

                        If  DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]
                            
                            oModel:GetModel( "MODEL_T5V" ):LVALID := .T.

                            If nT5VAdd > 1
                                oModel:GetModel( "MODEL_T5V" ):AddLine()
                            EndIf

                            oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", aGravaT5V[nT5V][3] )

                            /*------------------------------------------
                            T5X - Composição das bases de cálculo, deduções e isenções do IRRF
                            --------------------------------------------*/
                            nT5XAdd := 1
                            For nT5X := 1 to Len( aGravaT5X )

                                If  DTOS(aGravaT5X[nT5X][1])+aGravaT5X[nT5X][2]+aGravaT5X[nT5X][3] == DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2]+aGravaT5V[nT5V][3]
                                    
                                    oModel:GetModel( "MODEL_T5X" ):LVALID := .T.

                                    If nT5XAdd > 1
                                        oModel:GetModel( "MODEL_T5X" ):AddLine()
                                    EndIf

                                    oModel:LoadValue( "MODEL_T5X" , "T5X_SEQUEN", aGravaT5X[nT5X][4] )
                                    oModel:LoadValue( "MODEL_T5X" , "T5X_IDTPIR", aGravaT5X[nT5X][5] )
                                    oModel:LoadValue( "MODEL_T5X" , "T5X_VLRBCI", aGravaT5X[nT5X][6] )

                                    nT5XAdd++

                                EndIf

                            Next//T5X

                            nT5VAdd++

                        EndIf

                    Next //nT5V

                Next //nT3Q

            Else
                nV6MAdd := 1

                For nV6M := 1 To Len(aGravaV6M)

                    oModel:GetModel("MODEL_V6M"):lValid := .T.

                    If nV6MAdd > 1
                        oModel:GetModel("MODEL_V6M"):AddLine()
                    EndIf

                    oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", aGravaV6M[nV6M][1])
                    oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", aGravaV6M[nV6M][2])
                    oModel:LoadValue("MODEL_V6M", "V6M_PERREF", aGravaV6M[nV6M][3])
                    oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", aGravaV6M[nV6M][4])
                    oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", aGravaV6M[nV6M][5])

                    If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")

                        oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", aGravaV6M[nV6M][6])

                        For nV9I := 1 To Len(aGravaV9I)

                            If aGravaV9I[nV9I][1] + aGravaV9I[nV9I][2] + aGravaV9I[nV9I][3] == aGravaV6M[nV6M][2] +;
                                aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]

                                oModel:GetModel("MODEL_V9I"):lValid := .T.

                                oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", aGravaV9I[nV9I][4])
                                oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", aGravaV9I[nV9I][5])
                                oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", aGravaV9I[nV9I][6])
                                
                                For nV9J := 1 To Len(aGravaV9J)

                                    If aGravaV9J[nV9J][1] + aGravaV9J[nV9J][2] + aGravaV9J[nV9J][3] == aGravaV6M[nV6M][2] +;
                                        aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]

                                        oModel:GetModel("MODEL_V9J"):lValid := .T.
                                       
                                        oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", aGravaV9J[nV9J][4])
                                        oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", aGravaV9J[nV9J][5])
                                        oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", aGravaV9J[nV9J][6])
                                        oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", aGravaV9J[nV9J][7])
                                        oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", aGravaV9J[nV9J][8])
                                        oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", aGravaV9J[nV9J][9])
                                        oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", aGravaV9J[nV9J][10])
                                        oModel:LoadValue("MODEL_V9J", "V9J_TELEF" , aGravaV9J[nV9J][11])

                                    EndIf
                                Next
                            EndIf
                        Next
                    EndIf

                    nV6MAdd++

                Next

                If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC") )

                    nV7SAdd := 1

                    For nV7S := 1 To Len(aGravaV7S)
                        oModel:GetModel("MODEL_V7S"):lValid := .T.

                        If nV7SAdd > 1
                            oModel:GetModel("MODEL_V7S"):AddLine()
                        EndIf

                        oModel:LoadValue("MODEL_V7S", "V7S_CPFDEP"  , aGravaV7S[nV7S][1])
                        oModel:LoadValue("MODEL_V7S", "V7S_DTNASC"  , aGravaV7S[nV7S][2])
                        oModel:LoadValue("MODEL_V7S", "V7S_NMDEP"   , aGravaV7S[nV7S][3])
                        oModel:LoadValue("MODEL_V7S", "V7S_DPIRRF"  , aGravaV7S[nV7S][4])
                        oModel:LoadValue("MODEL_V7S", "V7S_TPDEP"   , aGravaV7S[nV7S][5])
                        oModel:LoadValue("MODEL_V7S", "V7S_DSCDEP"  , aGravaV7S[nV7S][6])

                        nV7SAdd++
                    Next 

                    nV7TAdd := 1

                    For nV7T := 1 To Len(aGravaV7T)
                        oModel:GetModel("MODEL_V7T"):lValid := .T.

                        If nV7TAdd > 1
                            oModel:GetModel("MODEL_V7T"):AddLine()
                        EndIf

                        oModel:LoadValue("MODEL_V7T", "V7T_TPCR"  , aGravaV7T[nV7T][1])

                        nV7UAdd := 1

                        For nV7U := 1 To Len(aGravaV7U)
                            If aGravaV7T[nV7T][1] == aGravaV7U[nV7U][1]

                                oModel:GetModel("MODEL_V7U"):lValid := .T.

                                If nV7UAdd > 1
                                    oModel:GetModel("MODEL_V7U"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V7U", "V7U_TPCR"    , aGravaV7U[nV7U][1])
                                oModel:LoadValue("MODEL_V7U", "V7U_TPREND"  , aGravaV7U[nV7U][2])
                                oModel:LoadValue("MODEL_V7U", "V7U_CPFDEP"  , aGravaV7U[nV7U][3])
                                oModel:LoadValue("MODEL_V7U", "V7U_VLRDED"  , aGravaV7U[nV7U][4])

                                nV7UAdd++
                            EndIf 
                        Next

                        nV7VAdd := 1

                        For nV7V := 1 To Len(aGravaV7V)
                            If aGravaV7T[nV7T][1] == aGravaV7V[nV7V][1]

                                oModel:GetModel("MODEL_V7V"):lValid := .T.

                                If nV7VAdd > 1
                                    oModel:GetModel("MODEL_V7V"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V7V", "V7V_TPCR"    , aGravaV7V[nV7V][1])
                                oModel:LoadValue("MODEL_V7V", "V7V_TPREND"  , aGravaV7V[nV7V][2])
                                oModel:LoadValue("MODEL_V7V", "V7V_CPFDEP"  , aGravaV7V[nV7V][3])
                                oModel:LoadValue("MODEL_V7V", "V7V_VLPEN"   , aGravaV7V[nV7V][4])

                                nV7VAdd++
                            EndIf 
                        Next

                        nV7WAdd := 1

                        For nV7W := 1 To Len(aGravaV7W)
                            If aGravaV7T[nV7T][1] == aGravaV7W[nV7W][1]

                                oModel:GetModel("MODEL_V7W"):lValid := .T.

                                If nV7WAdd > 1
                                    oModel:GetModel("MODEL_V7W"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V7W", "V7W_TPCR"    , aGravaV7W[nV7W][1])
                                oModel:LoadValue("MODEL_V7W", "V7W_TPREV"   , aGravaV7W[nV7W][2])
                                oModel:LoadValue("MODEL_V7W", "V7W_INSCPL"  , aGravaV7W[nV7W][3])
                                oModel:LoadValue("MODEL_V7W", "V7W_VLCOMP"  , aGravaV7W[nV7W][4])
                                oModel:LoadValue("MODEL_V7W", "V7W_VLPATR"  , aGravaV7W[nV7W][5])

                                nV7WAdd++
                            EndIf 
                        Next

                        nV7XAdd := 1

                        For nV7X := 1 To Len(aGravaV7X)
                            If aGravaV7T[nV7T][1] == aGravaV7X[nV7X][1]

                                oModel:GetModel("MODEL_V7X"):lValid := .T.

                                If nV7XAdd > 1
                                    oModel:GetModel("MODEL_V7X"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V7X", "V7X_TPCR"    , aGravaV7X[nV7X][1])
                                oModel:LoadValue("MODEL_V7X", "V7X_TPPROC"  , aGravaV7X[nV7X][2])
                                oModel:LoadValue("MODEL_V7X", "V7X_NRPROC"  , aGravaV7X[nV7X][3])
                                oModel:LoadValue("MODEL_V7X", "V7X_CODSUP"  , aGravaV7X[nV7X][4])

                                nV7YAdd := 1

                                For nV7Y := 1 To Len(aGravaV7Y)
                                    If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4] == aGravaV7Y[nV7Y][1]+aGravaV7Y[nV7Y][2]+aGravaV7Y[nV7Y][3]+aGravaV7Y[nV7Y][4] 

                                        oModel:GetModel("MODEL_V7Y"):lValid := .T.

                                        If nV7YAdd > 1
                                            oModel:GetModel("MODEL_V7Y"):AddLine()
                                        EndIf

                                        oModel:LoadValue("MODEL_V7Y", "V7Y_TPCR"    , aGravaV7Y[nV7Y][1] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_TPPROC"  , aGravaV7Y[nV7Y][2] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_NRPROC"  , aGravaV7Y[nV7Y][3] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_CODSUP"  , aGravaV7Y[nV7Y][4] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_INDAPU"  , aGravaV7Y[nV7Y][5] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLRRET"  , aGravaV7Y[nV7Y][6] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLRJUD"  , aGravaV7Y[nV7Y][7] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLACAL"  , aGravaV7Y[nV7Y][8] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLAANT"  , aGravaV7Y[nV7Y][9] )
                                        oModel:LoadValue("MODEL_V7Y", "V7Y_VLSUSP"  , aGravaV7Y[nV7Y][10])

                                        nV7ZAdd := 1

                                        For nV7Z := 1 To Len(aGravaV7Z)
                                            If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5] == aGravaV7Z[nV7Z][1]+aGravaV7Z[nV7Z][2]+aGravaV7Z[nV7Z][3]+aGravaV7Z[nV7Z][4]+aGravaV7Z[nV7Z][5]

                                                oModel:GetModel("MODEL_V7Z"):lValid := .T.

                                                If nV7ZAdd > 1
                                                    oModel:GetModel("MODEL_V7Z"):AddLine()
                                                EndIf  

                                                oModel:LoadValue("MODEL_V7Z", "V7Z_TPCR"    , aGravaV7Z[nV7Z][1] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_TPPROC"  , aGravaV7Z[nV7Z][2] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_NRPROC"  , aGravaV7Z[nV7Z][3] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_CODSUP"  , aGravaV7Z[nV7Z][4] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_INDAPU"  , aGravaV7Z[nV7Z][5] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_TPDEDU"  , aGravaV7Z[nV7Z][6] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_VLSUSP"  , aGravaV7Z[nV7Z][7] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_INSCPL"  , aGravaV7Z[nV7Z][8] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_VLFUNP"  , aGravaV7Z[nV7Z][9] )
                                                oModel:LoadValue("MODEL_V7Z", "V7Z_SEQUEN"  , aGravaV7Z[nV7Z][10] )

                                                nV8AAdd := 1

                                                For nV8A := 1 To Len(aGravaV8A)
                                                    If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5]+aGravaV7Z[nV7Z][10]  == aGravaV8A[nV8A][1]+aGravaV8A[nV8A][2]+aGravaV8A[nV8A][3]+aGravaV8A[nV8A][4]+aGravaV8A[nV8A][5]+aGravaV8A[nV8A][8] 
                                                        
                                                        oModel:GetModel("MODEL_V8A"):lValid := .T.
                                                        
                                                        If nV8AAdd > 1
                                                            oModel:GetModel("MODEL_V8A"):AddLine()
                                                        EndIf
                                                        
                                                        oModel:LoadValue("MODEL_V8A", "V8A_TPCR"    , aGravaV8A[nV8A][1] )
                                                        oModel:LoadValue("MODEL_V8A", "V8A_TPPROC"  , aGravaV8A[nV8A][2] )
                                                        oModel:LoadValue("MODEL_V8A", "V8A_NRPROC"  , aGravaV8A[nV8A][3] )
                                                        oModel:LoadValue("MODEL_V8A", "V8A_CODSUP"  , aGravaV8A[nV8A][4] )
                                                        oModel:LoadValue("MODEL_V8A", "V8A_INDAPU"  , aGravaV8A[nV8A][5] )
                                                        oModel:LoadValue("MODEL_V8A", "V8A_CPFDEP"  , aGravaV8A[nV8A][6] )
                                                        oModel:LoadValue("MODEL_V8A", "V8A_VLSUSP"  , aGravaV8A[nV8A][7] )
                                                        oModel:LoadValue("MODEL_V8A", "V8A_SEQUEN"  , aGravaV8A[nV8A][8] )

                                                        nV8AAdd++
                                                    EndIf 
                                                Next 
                                                nV7ZAdd++
                                            EndIf 
                                        Next 
                                        nV7YAdd++
                                    EndIf
                                Next
                                nV7XAdd++
                            EndIf 
                        Next
                        nV7TAdd++
                    Next 

                    nV8BAdd := 1

                    For nV8B := 1 To Len(aGravaV8B)
                        oModel:GetModel("MODEL_V8B"):lValid := .T.

                        If nV8BAdd > 1
                            oModel:GetModel("MODEL_V8B"):AddLine()
                        EndIf

                        oModel:LoadValue("MODEL_V8B", "V8B_CNPJOP"  , aGravaV8B[nV8B][1])
                        oModel:LoadValue("MODEL_V8B", "V8B_REGANS"  , aGravaV8B[nV8B][2])
                        oModel:LoadValue("MODEL_V8B", "V8B_VLRTIT"  , aGravaV8B[nV8B][3])

                        nV8CAdd := 1

                        For nV8C := 1 To Len(aGravaV8C)
                            If aGravaV8B[nV8B][1] == aGravaV8C[nV8C][1]
                                oModel:GetModel("MODEL_V8C"):lValid := .T.
                                
                                If nV8CAdd > 1
                                    oModel:GetModel("MODEL_V8C"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V8C", "V8C_CNPJOP"  , aGravaV8C[nV8C][1])
                                oModel:LoadValue("MODEL_V8C", "V8C_CPFDEP"  , aGravaV8C[nV8C][2])
                                oModel:LoadValue("MODEL_V8C", "V8C_VLRDEP"  , aGravaV8C[nV8C][3])

                                nV8CAdd++
                            EndIf
                        Next 
                        nV8BAdd++
                    Next 

                    nV8DAdd := 1

                    For nV8D := 1 To Len(aGravaV8D)
                        
                        oModel:GetModel("MODEL_V8D"):lValid := .T.

                        If nV8DAdd > 1
                            oModel:GetModel("MODEL_V8D"):AddLine()
                        EndIf

                        oModel:LoadValue("MODEL_V8D", "V8D_SEQUEN"  , aGravaV8D[nV8D][1])
                        oModel:LoadValue("MODEL_V8D", "V8D_INDREM"  , aGravaV8D[nV8D][2])
                        oModel:LoadValue("MODEL_V8D", "V8D_CNPJOP"  , aGravaV8D[nV8D][3])
                        oModel:LoadValue("MODEL_V8D", "V8D_REGANS"  , aGravaV8D[nV8D][4])

                        nV8EAdd := 1

                        For nV8E := 1 To Len(aGravaV8E)
                            If aGravaV8D[nV8D][1] == aGravaV8E[nV8E][1]
                                oModel:GetModel("MODEL_V8E"):lValid := .T.

                                If nV8EAdd > 1
                                    oModel:GetModel("MODEL_V8E"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V8E", "V8E_SEQUEN"  , aGravaV8E[nV8E][1])
                                oModel:LoadValue("MODEL_V8E", "V8E_TPINSC"  , aGravaV8E[nV8E][2])
                                oModel:LoadValue("MODEL_V8E", "V8E_NRINSC"  , aGravaV8E[nV8E][3])
                                oModel:LoadValue("MODEL_V8E", "V8E_VLREMB"  , aGravaV8E[nV8E][4])
                                oModel:LoadValue("MODEL_V8E", "V8E_VLRANT"  , aGravaV8E[nV8E][5])

                                nV8EAdd++
                            EndIf 
                        Next

                        nV8FAdd := 1
                        For nV8F := 1 To Len(aGravaV8F)
                            If aGravaV8D[nV8D][1] == aGravaV8F[nV8F][1]
                                oModel:GetModel("MODEL_V8F"):lValid := .T.

                                If nV8FAdd > 1
                                    oModel:GetModel("MODEL_V8F"):AddLine()
                                EndIf

                                oModel:LoadValue("MODEL_V8F", "V8F_SEQUEN"  , aGravaV8F[nV8F][1])
                                oModel:LoadValue("MODEL_V8F", "V8F_CPFDEP"  , aGravaV8F[nV8F][2])

                                nV8GAdd := 1
                                For nV8G := 1 To Len(aGravaV8G)
                                    If aGravaV8F[nV8F][1] + aGravaV8F[nV8F][2] == aGravaV8G[nV8G][1] + aGravaV8G[nV8G][2]
                                        oModel:GetModel("MODEL_V8G"):lValid := .T.

                                        If nV8GAdd > 1
                                            oModel:GetModel("MODEL_V8G"):AddLine()
                                        EndIf

                                        oModel:LoadValue("MODEL_V8G", "V8G_SEQUEN"  , aGravaV8G[nV8G][1])
                                        oModel:LoadValue("MODEL_V8G", "V8G_CPFDEP"  , aGravaV8G[nV8G][2])
                                        oModel:LoadValue("MODEL_V8G", "V8G_TPINSC"  , aGravaV8G[nV8G][3])
                                        oModel:LoadValue("MODEL_V8G", "V8G_NRINSC"  , aGravaV8G[nV8G][4])
                                        oModel:LoadValue("MODEL_V8G", "V8G_VLREMB"  , aGravaV8G[nV8G][5])
                                        oModel:LoadValue("MODEL_V8G", "V8G_VLRANT"  , aGravaV8G[nV8G][6])
                                    
                                        nV8GAdd++
                                    EndIf 
                                Next

                                nV8FAdd++
                            EndIf
                        Next
                        nV8DAdd++
                    Next
                ElseIf lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC")

                    TAFRecArray(@oModel, aGravaT8E, aGravaV7T, aGravaV7U, aGravaV7V, aGravaV7W, aGravaV7X, aGravaV7Y, aGravaV7Z, aGravaV8A, aGravaV8B, aGravaV8C, aGravaV8D, aGravaV8F, aGravaV8G, aGravaV8E, aGravaV7S)
                            
                    
                EndIf 

            EndIf

            //Busco a nova versao do registro
            cVersao := xFunGetVer()

            /*---------------------------------------------------------
            ATENCAO -> A alteracao destes campos deve sempre estar
            abaixo do Loop do For, pois devem substituir as informacoes
            que foram armazenadas no Loop acima
            -----------------------------------------------------------*/
            oModel:LoadValue( "MODEL_T3P", "T3P_VERSAO", cVersao )
            oModel:LoadValue( "MODEL_T3P", "T3P_VERANT", cVerAnt )
            oModel:LoadValue( "MODEL_T3P", "T3P_PROTPN", cProtocolo )
            oModel:LoadValue( "MODEL_T3P", "T3P_PROTUL", "" )

            /*---------------------------------------------------------
            Tratamento para que caso o Evento Anterior fosse de exclusão
            seta-se o novo evento como uma "nova inclusão", caso contrário o
            evento passar a ser uma alteração
            -----------------------------------------------------------*/
            oModel:LoadValue( "MODEL_T3P", "T3P_EVENTO", "E" )
            oModel:LoadValue( "MODEL_T3P", "T3P_ATIVO", "1" )

            FwFormCommit( oModel )
            TAFAltStat( 'T3P',"6" )

        End Transaction

    EndIf

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407View
Monta a View dinâmica
@author  Diego R. Santos
@since   30/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAF407View( cAlias as Character, nRecno as Numeric )

	Local aArea     as Array
	Local oExecView as Object
	Local oNewView  as Object

	aArea     := GetArea()
	oExecView := Nil
    oNewView  := ViewDef()

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 1 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return 1 

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPrtUl
Retorna o protocolo da ultima transmissão do ID Correto 

@author Hermiro Júnior
@since 14/02/2019
@version 1.0

@Param: 
	Mod. Pagamento			-> (2=S2200 | 3= S2300)
	Cpf do Beneficiario 	-> (T3P->T3P_CPF)
	Ident. Demonstrativo	-> (T3R_IDEDMD)	

@Return
	Ult. Protocolo Trans.-> (CMD_PROTUL)	
/*/
//-------------------------------------------------------------------
Static Function RetPrtUl( cModPag as Character, cCpfBen as Character, cIdeDmd as Character )

	Local cAliasQry as Character
	Local cPrtTran  as Character
	Local cQryPrt   as Character
	Local lMv       as Logical

	cAliasQry       := GetNextAlias()
    cPrtTran        := ""
	cQryPrt         := ""
	lMv             := Empty(T3P->T3P_BENEFI)

    // ________________________________________________________________________
    //| Posiciona no Desligamento  - SOLUÇÃO DE ID's Diferentes de Func com o  |
    //| mesmo CPF.                                                             |
    //|________________________________________________________________________|

    If cModPag	== '2'

        cQryPrt	:= " SELECT														"+CRLF
        cQryPrt	+= " T06.T06_ID,  												"+CRLF
        cQryPrt	+= " T06.T06_IDEDMD,  											"+CRLF
        cQryPrt	+= " CMD.CMD_ID,  												"+CRLF
        cQryPrt	+= " CMD.CMD_FUNC,  											"+CRLF
        cQryPrt	+= " CMD.CMD_PROTUL  											"+CRLF
        cQryPrt	+= " FROM "+RetSqlName("T06")+" T06  							"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("CMD")+" CMD  ON 				"+CRLF
        cQryPrt	+= "		CMD.CMD_FILIAL = T06.T06_FILIAL AND 				"+CRLF
        cQryPrt	+= "		CMD.CMD_ID	=  T06.T06_ID AND 						"+CRLF
        cQryPrt	+= "		CMD.CMD_VERSAO = T06.T06_VERSAO AND 				"+CRLF
        cQryPrt	+= "		CMD.CMD_ATIVO  = '1'	AND 			            "+CRLF
        cQryPrt	+= "		CMD.CMD_STATUS = '4'	AND 			            "+CRLF
        cQryPrt	+= "		CMD.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("C9V")+" C9V  ON 				"+CRLF
        cQryPrt	+= "		C9V.C9V_FILIAL = T06.T06_FILIAL AND					"+CRLF
        cQryPrt	+= "		C9V.C9V_ID = CMD.CMD_FUNC AND 						"+CRLF
        cQryPrt	+= "		C9V.C9V_CPF = '"+cCpfBen+"' AND 					"+CRLF
        cQryPrt	+= "		C9V.C9V_NOMEVE = 'S2200' AND 						"+CRLF
        cQryPrt	+= "		C9V.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= " WHERE 														"+CRLF

        If ! lMv
            cQryPrt	+= "	T06.T06_FILIAL = '"+xFilial("T06")+"'  AND 			"+CRLF
        EndIf
        cQryPrt	+= "	T06.T06_IDEDMD = '"+cIdeDmd+"' AND 						"+CRLF
        cQryPrt	+= "	T06.D_E_L_E_T_ = ' ' 										"+CRLF

    ElseIf cModPag	== '3'

        cQryPrt	:= " SELECT																"+CRLF
        cQryPrt	+= " T3I.T3I_ID,  													"+CRLF
        cQryPrt	+= " T3I.T3I_IDEDMD,  												"+CRLF
        cQryPrt	+= " T92.T92_ID,  													"+CRLF
        cQryPrt	+= " T92.T92_TRABAL,  												"+CRLF
        cQryPrt	+= " T92.T92_PROTUL  												"+CRLF
        cQryPrt	+= " FROM "+RetSqlName("T3I")+" T3I 								"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("T92")+" T92  ON 				"+CRLF
        cQryPrt	+= "		T92.T92_FILIAL = T3I.T3I_FILIAL AND 				"+CRLF
        cQryPrt	+= "		T92.T92_ID	=  T3I.T3I_ID AND 						"+CRLF
        cQryPrt	+= "		T92.T92_VERSAO = T3I.T3I_VERSAO AND					"+CRLF
        cQryPrt	+= "		T92.T92_ATIVO   = '1'	AND 			            "+CRLF
        cQryPrt	+= "		T92.T92_STATUS  = '4'	AND 			            "+CRLF
        cQryPrt	+= "		T92.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= "	INNER JOIN "+RetSqlName("C9V")+" C9V  ON 				"+CRLF
        cQryPrt	+= "		C9V.C9V_FILIAL = 	T92.T92_FILIAL AND				"+CRLF
        cQryPrt	+= "		C9V.C9V_ID = T92.T92_TRABAL AND 					"+CRLF
        cQryPrt	+= "		C9V.C9V_CPF = '"+cCpfBen+"' AND 					"+CRLF
        cQryPrt	+= "		C9V.C9V_NOMEVE = 'S2300' AND 						"+CRLF
        cQryPrt	+= "		C9V.D_E_L_E_T_ = ' '								"+CRLF
        cQryPrt	+= "WHERE 														"+CRLF
        If !lMv
            cQryPrt	+= "	T3I.T3I_FILIAL = '"+xFilial("T3I")+"'  AND 			    "+CRLF
        EndIf
        cQryPrt	+= "	T3I.T3I_IDEDMD = '"+cIdeDmd+"' AND					 	"+CRLF
        cQryPrt	+= "	T3I.D_E_L_E_T_ = ' ' 									"+CRLF

    EndIf

    cQryPrt := ChangeQuery(cQryPrt)

    TCQuery cQryPrt New Alias (cAliasQry)

    If !(cAliasQry)->(Eof())

        If cModPag	    == '2'
            cPrtTran := (cAliasQry)->CMD_PROTUL
        ElseIf cModPag	== '3'
            cPrtTran := (cAliasQry)->T92_PROTUL
        EndIf

    EndIf

    (cAliasQry)->(DbCloseArea())

Return cPrtTran

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Inc
Monta a View dinâmica
@author  Eduardo Sukeda
@since   29/05/2019
@version 1
/*/
//-------------------------------------------------------------------
Function TAF407Inc( cAlias as Character, nRecno as Numeric )

	Local aArea     as Array
	Local oExecView as Object
	Local oNewView  as Object

	aArea           := GetArea()
	oExecView       := Nil
    oNewView        := ViewDef()

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return 3

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407AUTI
Monta a View dinâmica
@author  Ricardo Lovrenovic
@since   27/01/2020
@version 1
/*/
//-------------------------------------------------------------------
Function TAF407AUTI( cAlias as Character, nRecno as Numeric )

	Local aArea     as Array
	Local oExecView as Object
	Local oNewView  as Object

	aArea           := GetArea()
	oExecView       := Nil
    oNewView        := ViewDef()

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return 3

//-------------------------------------------------------------------
/*/{Protheus.doc} XT3PValid
Rotina p/ executar os valids presentes no dicionário de dados em virtude
do campo X3_VALID não possuir caracteres suficientes
@author  Alexandre/SILAS
@since   31-08-2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function XT3PValid( cCampo as Character )

	Local lRet as Logical

    lRet := .T.

	If !lLaySimplif

		If AllTrim(cCampo) == "T3P_BENEFI"
			lRet := XFUNVldCmp("C9V",,,, 1,,, .T.) .AND. XFUNVldUni("T3P", 2, FwFldGet("T3P_INDAPU") + FwFldGet("T3P_PERAPU") + M->T3P_BENEFI + '1')
		ElseIf AllTrim(cCampo) == "T3P_CPF"
			lRet := XFUNVldUni("T3P", 6, FwFldGet("T3P_INDAPU")+FwFldGet("T3P_PERAPU")+M->T3P_CPF+'1')
		EndIF
	
    Else

		If AllTrim(cCampo) == "T3P_BENEFI" .And. TafColumnPos("T3P_ORIEVE") .And. T3P->T3P_ORIEVE == 'S2400'
			lRet := XFUNVldUni("T3P", 2, FwFldGet("T3P_INDAPU") + FwFldGet("T3P_PERAPU") + M->T3P_BENEFI + '1')
		ElseIf AllTrim(cCampo) == "T3P_BENEFI"
			lRet := XFUNVldUni("T3P", 7, FwFldGet("T3P_PERAPU") + FwFldGet("T3P_TPGUIA") + M->T3P_BENEFI + '1')
		ElseIf AllTrim(cCampo) == "T3P_CPF"
			lRet := XFUNVldUni("T3P", 8, FwFldGet("T3P_PERAPU") + FwFldGet("T3P_TPGUIA") + M->T3P_CPF + '1')
		EndIF

	EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} TafCrrMdl

Carrega o modelo com os registro para aglutinar no novo cenário

@author Bruno Rosa
@since 28/08/2020
@version 1.0

@param oMdlNvCen, caracter, Modelo que contem os registros
@param oModel   , caracter, Modelo que receberá os dados
@param cIDT3P   , caracter, ID do T3P - Pgto Rendimentos do Trabalho  
@param cVersT3P , caracter, Versão do T3P - Pgto Rendimentos do Trabalho  

/*/
//--------------------------------------------------------------------
Static Function TafCrrMdl( oMdlNvCen as Object, oModel as Object, cIDT3P as Character, cVersT3P as Character )

	Local aGravaLE2 as Array
	Local aGravaLE3 as Array
	Local aGravaLE4 as Array
	Local aGravaT3Q as Array
	Local aGravaT3R as Array
	Local aGravaT5U as Array
	Local aGravaT5V as Array
	Local aGravaT5X as Array
	Local aGravaT5Y as Array
	Local aGravaT5Z as Array
	Local aGravaT6P as Array
	Local aGravaT6Q as Array
	Local aGravaT6R as Array
	Local aGravaV6M as Array
    Local aGravaV9I as Array
    Local aGravaV9J as Array
    Local aGravaV7S  as Array
    Local aGravaV7T  as Array
    Local aGravaV7U  as Array
    Local aGravaV7V  as Array
    Local aGravaV7W  as Array
    Local aGravaV7X  as Array
    Local aGravaV7Y  as Array
    Local aGravaV7Z  as Array
    Local aGravaV8A  as Array
    Local aGravaV8B  as Array
    Local aGravaV8C  as Array
    Local aGravaV8D  as Array
    Local aGravaV8E  as Array
    Local aGravaV8F  as Array
    Local aGravaV8G  as Array
    Local aGravaT8E  as Array
    Local lLayout12  as Logical
	Local nLE2      as Numeric
	Local nLE2Add   as Numeric
	Local nLE3      as Numeric
	Local nLE3Add   as Numeric
	Local nLE4      as Numeric
	Local nLE4Add   as Numeric
	Local nT3Q      as Numeric
	Local nT3R      as Numeric
	Local nT3RAdd   as Numeric
	Local nT5U      as Numeric
	Local nT5UAdd   as Numeric
	Local nT5V      as Numeric
	Local nT5VAdd   as Numeric
	Local nT5X      as Numeric
	Local nT5XAdd   as Numeric
	Local nT5Y      as Numeric
	Local nT5YAdd   as Numeric
	Local nT5Z      as Numeric
	Local nT5ZAdd   as Numeric
	Local nT6P      as Numeric
	Local nT6PAdd   as Numeric
	Local nT6Q      as Numeric
	Local nT6QAdd   as Numeric
	Local nT6R      as Numeric
	Local nT6RAdd   as Numeric
	Local nV6M      as Numeric
    Local nV6MAdd   as Numeric
    Local nV9I      as Numeric
    Local nV9J      as Numeric
    Local nV7S       as Numeric
    Local nV7SAdd    as Numeric
    Local nV7T       as Numeric
    Local nV7TAdd    as Numeric
    Local nV7U       as Numeric
    Local nV7UAdd    as Numeric
    Local nV7V       as Numeric
    Local nV7VAdd    as Numeric
    Local nV7W       as Numeric
    Local nV7WAdd    as Numeric
    Local nV7X       as Numeric
    Local nV7XAdd    as Numeric
    Local nV7Y       as Numeric
    Local nV7YAdd    as Numeric
    Local nV7Z       as Numeric
    Local nV7ZAdd    as Numeric
    Local nV8A       as Numeric
    Local nV8AAdd    as Numeric
    Local nV8B       as Numeric
    Local nV8BAdd    as Numeric
    Local nV8C       as Numeric
    Local nV8CAdd    as Numeric
    Local nV8D       as Numeric
    Local nV8DAdd    as Numeric
    Local nV8E       as Numeric
    Local nV8EAdd    as Numeric
    Local nV8F       as Numeric
    Local nV8FAdd    as Numeric
    Local nV8G       as Numeric
    Local nV8GAdd    as Numeric
    Local oModelLE2 as Object
    Local oModelLE3 as Object
    Local oModelLE4 as Object
    Local oModelT3Q as Object
    Local oModelT3R as Object
    Local oModelT5U as Object
    Local oModelT5V as Object
    Local oModelT5X as Object
    Local oModelT5Y as Object
    Local oModelT5Z as Object
    Local oModelT6P as Object
    Local oModelT6Q as Object
    Local oModelT6R as Object
    Local oModelV6M as Object
    Local oModelV9I as Object
    Local oModelV9J as Object
    Local oModelV7S as Object
    Local oModelV7T as Object
    Local oModelV7U as Object
    Local oModelV7V as Object
    Local oModelV7X as Object
    Local oModelV7W as Object
    Local oModelV7Y as Object
    Local oModelV7Z as Object
    Local oModelV8A as Object
    Local oModelV8B as Object
    Local oModelV8C as Object
    Local oModelV8D as Object
    Local oModelV8E as Object
    Local oModelV8F as Object
    Local oModelV8G as Object

    Default cIDT3P    := ""
    Default cVersT3P  := ""
    Default oMdlNvCen := Nil
    Default oModel    := Nil

	aGravaLE2 := {}
	aGravaLE3 := {}
	aGravaLE4 := {}
	aGravaT3Q := {}
	aGravaT3R := {}
	aGravaT5U := {}
	aGravaT5V := {}
	aGravaT5X := {}
	aGravaT5Y := {}
	aGravaT5Z := {}
	aGravaT6P := {}
	aGravaT6Q := {}
	aGravaT6R := {}
	aGravaV6M := {}
    aGravaV9I := {}
    aGravaV9J := {}
    aGravaT8E := {}
    aGravaV7S := {}
    aGravaV7T := {}
    aGravaV7U := {}
    aGravaV7V := {}
    aGravaV7W := {}
    aGravaV7X := {}
    aGravaV7Y := {}
    aGravaV7Z := {}
    aGravaV8A := {}
    aGravaV8B := {}
    aGravaV8C := {}
    aGravaV8D := {}
    aGravaV8E := {}
    aGravaV8F := {}
    aGravaV8G := {}
	nLE2      := 0
	nLE2Add   := 0
	nLE3      := 0
	nLE3Add   := 0
	nLE4      := 0
	nLE4Add   := 0
	nT3Q      := 0
	nT3R      := 0
	nT3RAdd   := 0
	nT5U      := 0
	nT5UAdd   := 0
	nT5V      := 0
	nT5VAdd   := 0
	nT5X      := 0
	nT5XAdd   := 0
	nT5Y      := 0
	nT5YAdd   := 0
	nT5Z      := 0
	nT5ZAdd   := 0
	nT6P      := 0
	nT6PAdd   := 0
	nT6Q      := 0
	nT6QAdd   := 0
	nT6R      := 0
	nT6RAdd   := 0
	nV6M      := 0
    nV6MAdd   := 0
    nV9I      := 0
    nV9J      := 0
    nV7S      := 0
    nV7SAdd   := 0
    nV7T      := 0
    nV7TAdd   := 0
    nV7U      := 0
    nV7UAdd   := 0
    nV7V      := 0
    nV7VAdd   := 0
    nV7W      := 0
    nV7WAdd   := 0
    nV7X      := 0
    nV7XAdd   := 0
    nV7Y      := 0
    nV7YAdd   := 0
    nV7Z      := 0
    nV7ZAdd   := 0
    nV8A      := 0
    nV8AAdd   := 0
    nV8B      := 0
    nV8BAdd   := 0
    nV8C      := 0
    nV8CAdd   := 0
    nV8D      := 0
    nV8DAdd   := 0
    nV8E      := 0
    nV8EAdd   := 0
    nV8F      := 0
    nV8FAdd   := 0
    nV8G      := 0
    nV8GAdd   := 0
    lLayout12 := lSimpl12 .and. TafColumnPos("V8G_NRINSC")
    oModelLE2 := Nil
    oModelLE3 := Nil
    oModelLE4 := Nil
    oModelT3Q := Nil
    oModelT3R := Nil
    oModelT5U := Nil
    oModelT5V := Nil
    oModelT5X := Nil
    oModelT5Y := Nil
    oModelT5Z := Nil
    oModelT6P := Nil
    oModelT6Q := Nil
    oModelT6R := Nil
    oModelV6M := Nil
    oModelV9I := Nil
    oModelV9J := Nil
    oModelV7S := Nil
    oModelV7T := Nil
    oModelV7U := Nil
    oModelV7V := Nil
    oModelV7X := Nil
    oModelV7W := Nil
    oModelV7Y := Nil
    oModelV7Z := Nil
    oModelV8A := Nil
    oModelV8B := Nil
    oModelV8C := Nil
    oModelV8D := Nil
    oModelV8E := Nil
    oModelV8F := Nil
    oModelV8G := Nil

    If oModel != Nil .And. oMdlNvCen != Nil

        If !lLaySimplif

            oModelLE2 := oMdlNvCen:GetModel( 'MODEL_LE2' )
            oModelLE3 := oMdlNvCen:GetModel( 'MODEL_LE3' )
            oModelLE4 := oMdlNvCen:GetModel( 'MODEL_LE4' )
            oModelT3Q := oMdlNvCen:GetModel( 'MODEL_T3Q' )
            oModelT3R := oMdlNvCen:GetModel( 'MODEL_T3R' )
            oModelT5U := oMdlNvCen:GetModel( 'MODEL_T5U' )
            oModelT5V := oMdlNvCen:GetModel( 'MODEL_T5V' )
            oModelT5X := oMdlNvCen:GetModel( 'MODEL_T5X' )
            oModelT5Y := oMdlNvCen:GetModel( 'MODEL_T5Y' )
            oModelT5Z := oMdlNvCen:GetModel( 'MODEL_T5Z' )
            oModelT6P := oMdlNvCen:GetModel( 'MODEL_T6P' )
            oModelT6Q := oMdlNvCen:GetModel( 'MODEL_T6Q' )
            oModelT6R := oMdlNvCen:GetModel( 'MODEL_T6R' )

            /*T3Q - Informações de Pagamentos Efetuados*/
            For nT3Q := 1 To oModelT3Q:Length()

                oModelT3Q:GoLine(nT3Q)

                If !oModelT3Q:IsDeleted()

                    aAdd(aGravaT3Q, { oModelT3Q:GetValue('T3Q_DTPGTO'),;
                                        oModelT3Q:GetValue('T3Q_TPPGTO'),;
                                        oModelT3Q:GetValue('T3Q_INDRES'),;
                                        oModelT3Q:GetValue('T3Q_IDPAIS'),;
                                        oModelT3Q:GetValue('T3Q_INDNIF'),;
                                        oModelT3Q:GetValue('T3Q_NIFBEN'),;
                                        oModelT3Q:GetValue('T3Q_DLOUGR'),;
                                        oModelT3Q:GetValue('T3Q_NUMLOG'),;
                                        oModelT3Q:GetValue('T3Q_COMPLE'),;
                                        oModelT3Q:GetValue('T3Q_BAIRRO'),;
                                        oModelT3Q:GetValue('T3Q_CIDADE'),;
                                        oModelT3Q:GetValue('T3Q_CEP') })

                    /*T3R - Info. de Pgto Efetuados*/
                    For nT3R := 1 to oModelT3R:Length()

                        oModelT3R:GoLine(nT3R)

                        If !oModelT3R:IsEmpty()

                            If !oModelT3R:IsDeleted()

                                aAdd(aGravaT3R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT3R:GetValue('T3R_PERREF'),;
                                                    oModelT3R:GetValue('T3R_IDEDMD'),;
                                                    oModelT3R:GetValue('T3R_INDPGT'),;
                                                    oModelT3R:GetValue('T3R_VLRLIQ')})

                                /*LE2 - Retenções Pagamento do Vlr Tot*/
                                For nLE2 := 1 to oModelLE2:Length()

                                    oModelLE2:GoLine(nLE2)

                                    If !oModelLE2:IsEmpty()

                                        If !oModelLE2:IsDeleted()

                                            aAdd(aGravaLE2 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                oModelLE2:GetValue('LE2_QTDRUB'),;
                                                                oModelLE2:GetValue('LE2_FATRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRRUB'),;
                                                                oModelLE2:GetValue('LE2_VLRUNI'),;
                                                                oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                oModelLE2:GetValue('LE2_RUBRIC'),;
                                                                oModelLE2:GetValue('LE2_IDTABR')})

                                            /*LE3 - Pensão Alimentícia*/
                                            For nLE3 := 1 to oModelLE3:Length()

                                                oModelLE3:GoLine(nLE3)

                                                If !oModelLE3:IsEmpty()

                                                    If !oModelLE3:IsDeleted()

                                                        aAdd(aGravaLE3 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                            oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                            oModelT3R:GetValue('T3R_PERREF'),;
                                                                            oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                            oModelT3R:GetValue('T3R_INDPGT'),;
                                                                            oModelLE2:GetValue('LE2_IDRUBR'),;
                                                                            oModelLE3:GetValue('LE3_CPFBEN'),;
                                                                            oModelLE3:GetValue('LE3_DTNSBE'),;
                                                                            oModelLE3:GetValue('LE3_NMBEN'),;
                                                                            oModelLE3:GetValue('LE3_VLRPEN'),;
                                                                            oModelLE2:GetValue('LE2_SEQUEN'),;
                                                                            oModelLE2:GetValue('LE2_RUBRIC') })

                                                    EndIf

                                                EndIf

                                            Next nLE3

                                        EndIf

                                    EndIf

                                Next nLE2

                                /*LE4 - Inf Comp Relac ao Pgto Efetuad*/
                                For nLE4 := 1 to oModelLE4:Length()

                                    oModelLE4:GoLine(nLE4)

                                    If !oModelLE4:IsEmpty()

                                        If !oModelLE4:IsDeleted()

                                            aAdd(aGravaLE4 ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT3R:GetValue('T3R_PERREF'),;
                                                                oModelT3R:GetValue('T3R_IDEDMD'),;
                                                                oModelT3R:GetValue('T3R_INDPGT'),;
                                                                oModelLE4:GetValue('LE4_IDRUBR'),;
                                                                oModelLE4:GetValue('LE4_QTDRUB'),;
                                                                oModelLE4:GetValue('LE4_FATRUB'),;
                                                                oModelLE4:GetValue('LE4_VLRRUB'),;
                                                                oModelLE4:GetValue('LE4_VLRUNI'),;
                                                                oModelLE4:GetValue('LE4_RUBRIC'),;
                                                                oModelLE4:GetValue('LE4_IDTABR'),;
                                                                oModelLE4:GetValue('LE4_MATRIC')})
                                        EndIf
                                        
                                    EndIf

                                Next nLE4

                            EndIf

                        EndIf

                    Next nT3R

                    /*T6P - Detalh. Pgto Folha e Rescisão*/
                    For nT6P := 1 to oModelT6P:Length()

                        oModelT6P:GoLine(nT6P)

                        If !oModelT6P:IsEmpty()

                            If !oModelT6P:IsDeleted()

                                aAdd(aGravaT6P ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT6P:GetValue('T6P_PERREF'),;
                                                    oModelT6P:GetValue('T6P_IDEDMD'),;
                                                    oModelT6P:GetValue('T6P_INDPGT'),;
                                                    oModelT6P:GetValue('T6P_VLRLIQ')})

                                /*T6Q - Retenções Pagamento do Vlr Tot*/
                                For nT6Q := 1 to oModelT6Q:Length()

                                    oModelT6Q:GoLine(nT6Q)

                                    If !oModelT6Q:IsEmpty()

                                        If !oModelT6Q:IsDeleted()

                                            aAdd(aGravaT6Q ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                oModelT6Q:GetValue('T6Q_IDRUBR'),;
                                                                oModelT6Q:GetValue('T6Q_QTDRUB'),;
                                                                oModelT6Q:GetValue('T6Q_FATRUB'),;
                                                                oModelT6Q:GetValue('T6Q_VLRRUB'),;
                                                                oModelT6Q:GetValue('T6Q_VLRUNI'),;
                                                                oModelT6Q:GetValue('T6Q_RUBRIC'),;
                                                                oModelT6Q:GetValue('T6Q_IDTABR')})

                                        EndIf

                                    EndIf

                                Next nT6Q

                                /*T6R - Inf Comp Relac ao Pgto Efetuad*/
                                For nT6R := 1 to oModelT6R:Length()

                                    oModelT6R:GoLine(nT6R)

                                    If !oModelT6R:IsEmpty()

                                        If !oModelT6R:IsDeleted()

                                            aAdd(aGravaT6R ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT6P:GetValue('T6P_PERREF'),;
                                                                oModelT6P:GetValue('T6P_IDEDMD'),;
                                                                oModelT6P:GetValue('T6P_INDPGT'),;
                                                                oModelT6R:GetValue('T6R_IDRUBR'),;
                                                                oModelT6R:GetValue('T6R_QTDRUB'),;
                                                                oModelT6R:GetValue('T6R_FATRUB'),;
                                                                oModelT6R:GetValue('T6R_VLRRUB'),;
                                                                oModelT6R:GetValue('T6R_VLRUNI'),;
                                                                oModelT6R:GetValue('T6R_RUBRIC'),;
                                                                oModelT6R:GetValue('T6R_IDTABR')})
                                        EndIf

                                    EndIf

                                Next nT6R

                            EndIf

                        EndIf

                    Next nT6P

                    /*T5U - Detalhamento Rub Recibo Férias*/
                    For nT5U := 1 to oModelT5U:Length()

                        oModelT5U:GoLine(nT5U)

                        If !oModelT5U:IsEmpty()

                            If !oModelT5U:IsDeleted()

                                aAdd(aGravaT5U ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT5U:GetValue('T5U_IDCATE'),;
                                                    oModelT5U:GetValue('T5U_DTINIG'),;
                                                    oModelT5U:GetValue('T5U_QTDIAS'),;
                                                    oModelT5U:GetValue('T5U_VLRLIQ'),;
                                                    oModelT5U:GetValue('T5U_MATRIC')})

                                /*T5Y - Det Rub Rebibo Ant de Ferias*/
                                For nT5Y := 1 to oModelT5Y:Length()

                                    oModelT5Y:GoLine(nT5Y)

                                    If !oModelT5Y:IsEmpty()

                                        If !oModelT5Y:IsDeleted()

                                            aAdd(aGravaT5Y ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT5U:GetValue('T5U_IDCATE'),;
                                                                oModelT5U:GetValue('T5U_DTINIG'),;
                                                                oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                oModelT5Y:GetValue('T5Y_QTDRUB'),;
                                                                oModelT5Y:GetValue('T5Y_FATRUB'),;
                                                                oModelT5Y:GetValue('T5Y_VLRRUB'),;
                                                                oModelT5Y:GetValue('T5Y_VLRUNI'),;
                                                                oModelT5Y:GetValue('T5Y_RUBRIC'),;
                                                                oModelT5Y:GetValue('T5Y_IDTABR')})

                                            /*T5Z - Beneficiários de Pensão Alimen*/
                                            For nT5Z := 1 to oModelT5Z:Length()

                                                oModelT5Z:GoLine(nT5Z)

                                                If !oModelT5Z:IsEmpty()

                                                    If !oModelT5Z:IsDeleted()

                                                        aAdd(aGravaT5Z ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                            oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                            oModelT5U:GetValue('T5U_IDCATE'),;
                                                                            oModelT5U:GetValue('T5U_DTINIG'),;
                                                                            oModelT5Y:GetValue('T5Y_IDRUBR'),;
                                                                            oModelT5Z:GetValue('T5Z_CPFBEN'),;
                                                                            oModelT5Z:GetValue('T5Z_DTNSBE'),;
                                                                            oModelT5Z:GetValue('T5Z_NMBEN'),;
                                                                            oModelT5Z:GetValue('T5Z_VLRPEN')})
                                                    EndIf

                                                EndIf

                                            Next nT5Z

                                        EndIf

                                    EndIf

                                Next nT5Y

                            EndIf

                        EndIf

                    Next nT5U

                    /*T5V - Pgto Relat Compet Anteriores*/
                    For nT5V := 1 to oModelT5V:Length()

                        oModelT5V:GoLine(nT5V)

                        If !oModelT5V:IsEmpty()

                            If !oModelT5V:IsDeleted()

                                aAdd(aGravaT5V ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                    oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                    oModelT5V:GetValue('T5V_IDCATE')})

                                /*T5X - Detalhamento do pagamento*/
                                For nT5X := 1 to oModelT5X:Length()

                                    oModelT5X:GoLine(nT5X)

                                    If !oModelT5X:IsEmpty()

                                        If !oModelT5X:IsDeleted()

                                            aAdd(aGravaT5X ,{oModelT3Q:GetValue("T3Q_DTPGTO"),;
                                                                oModelT3Q:GetValue("T3Q_TPPGTO"),;
                                                                oModelT5V:GetValue('T5V_IDCATE'),;
                                                                oModelT5X:GetValue('T5X_SEQUEN'),;
                                                                oModelT5X:GetValue('T5X_IDTPIR'),;
                                                                oModelT5X:GetValue('T5X_VLRBCI')})

                                        EndIf

                                    EndIf

                                Next nT5X

                            EndIf

                        EndIf

                    Next nT5V

                EndIf

            Next nT3Q

            //Gravação no modelo original para segunda
            /*T3Q - Informações de Pagamentos Efetuados*/
            For nT3Q := 1 to Len(aGravaT3Q)

                oModel:GetModel('MODEL_T3Q'):LVALID := .T.

                If nT3Q > 1
                    oModel:GetModel("MODEL_T3Q"):AddLine()
                EndIf

                oModel:LoadValue( "MODEL_T3Q", "T3Q_DTPGTO" , aGravaT3Q[nT3Q][1] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_TPPGTO" , aGravaT3Q[nT3Q][2] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDRES",  aGravaT3Q[nT3Q][3] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_IDPAIS",  aGravaT3Q[nT3Q][4] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_INDNIF",  aGravaT3Q[nT3Q][5] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_NIFBEN",  aGravaT3Q[nT3Q][6] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_DLOUGR",  aGravaT3Q[nT3Q][7] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_NUMLOG",  aGravaT3Q[nT3Q][8] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_COMPLE",  aGravaT3Q[nT3Q][9] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_BAIRRO",  aGravaT3Q[nT3Q][10] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_CIDADE",  aGravaT3Q[nT3Q][11] )
                oModel:LoadValue( "MODEL_T3Q", "T3Q_CEP"   ,  aGravaT3Q[nT3Q][12] )

                /*T3R - Info. de Pgto Efetuados*/
                nT3RAdd := 1
                For nT3R := 1 to Len(aGravaT3R)

                    If  DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel("MODEL_T3R"):LVALID := .T.

                        If nT3RAdd > 1
                            oModel:GetModel("MODEL_T3R"):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T3R", "T3R_PERREF", aGravaT3R[nT3R][3] )
                        oModel:LoadValue( "MODEL_T3R", "T3R_IDEDMD", aGravaT3R[nT3R][4] )
                        oModel:LoadValue( "MODEL_T3R", "T3R_INDPGT", aGravaT3R[nT3R][5] )
                        oModel:LoadValue( "MODEL_T3R", "T3R_VLRLIQ", aGravaT3R[nT3R][6] )

                        /*LE2 - Retenções Pagamento do Vlr Tot*/
                        nLE2Add := 1
                        For nLE2 := 1 to Len(aGravaLE2)

                            If  DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                oModel:GetModel("MODEL_LE2"):LVALID := .T.

                                If nLE2Add > 1
                                    oModel:GetModel("MODEL_LE2"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDRUBR", aGravaLE2[nLE2][6] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_QTDRUB", aGravaLE2[nLE2][7] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_FATRUB", aGravaLE2[nLE2][8] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRRUB", aGravaLE2[nLE2][9] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_VLRUNI", aGravaLE2[nLE2][10] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_SEQUEN", aGravaLE2[nLE2][11] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_RUBRIC", aGravaLE2[nLE2][12] )
                                oModel:LoadValue( "MODEL_LE2" , "LE2_IDTABR", aGravaLE2[nLE2][13] )

                                /*LE3 -  */
                                nLE3Add := 1
                                For nLE3 := 1 to Len(aGravaLE3)

                                    If  DTOS(aGravaLE3[nLE3][1])+aGravaLE3[nLE3][2]+aGravaLE3[nLE3][3]+aGravaLE3[nLE3][4]+aGravaLE3[nLE3][5]+aGravaLE3[nLE3][6] == DTOS(aGravaLE2[nLE2][1])+aGravaLE2[nLE2][2]+aGravaLE2[nLE2][3]+aGravaLE2[nLE2][4]+aGravaLE2[nLE2][5]+aGravaLE2[nLE2][6]

                                        oModel:GetModel("MODEL_LE3"):LVALID := .T.

                                        If nLE3Add > 1
                                            oModel:GetModel("MODEL_LE3"):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_LE3" , "LE3_CPFBEN", aGravaLE3[nLE3][7] )
                                        oModel:LoadValue( "MODEL_LE3" , "LE3_DTNSBE", aGravaLE3[nLE3][8] )
                                        oModel:LoadValue( "MODEL_LE3" , "LE3_NMBEN",  aGravaLE3[nLE3][9] )
                                        oModel:LoadValue( "MODEL_LE3" , "LE3_VLRPEN", aGravaLE3[nLE3][10] )

                                        nLE3Add++

                                    EndIf

                                Next nLE3

                                nLE2Add++

                            EndIf

                        Next nLE2

                        /*LE4 - */
                        nLE4Add := 1
                        For nLE4 := 1 to Len(aGravaLE4)

                            If  DTOS(aGravaLE4[nLE4][1])+aGravaLE4[nLE4][2]+aGravaLE4[nLE4][3]+aGravaLE4[nLE4][4]+aGravaLE4[nLE4][5] == DTOS(aGravaT3R[nT3R][1])+aGravaT3R[nT3R][2]+aGravaT3R[nT3R][3]+aGravaT3R[nT3R][4]+aGravaT3R[nT3R][5]

                                oModel:GetModel("MODEL_LE4"):LVALID := .T.

                                If nLE4Add > 1
                                    oModel:GetModel("MODEL_LE4"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_LE4" , "LE4_IDRUBR", aGravaLE4[nLE4][6] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_QTDRUB", aGravaLE4[nLE4][7] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_FATRUB", aGravaLE4[nLE4][8] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRUNI", aGravaLE4[nLE4][9] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_VLRRUB", aGravaLE4[nLE4][10] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_RUBRIC", aGravaLE4[nLE4][11] )
                                oModel:LoadValue( "MODEL_LE4" , "LE4_IDTABR", aGravaLE4[nLE4][12] )

                                nLE4Add++

                            EndIf

                        Next nLE4

                        nT3RAdd++

                    EndIf

                Next nT3R

                /*T6P -  */
                nT6PAdd := 1
                For nT6P := 1 to Len(aGravaT6P)

                    If  DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel("MODEL_T6P"):LVALID := .T.

                        If nT6PAdd > 1
                            oModel:GetModel("MODEL_T6P"):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T6P", "T6P_PERREF", aGravaT6P[nT6P][3] )
                        oModel:LoadValue( "MODEL_T6P", "T6P_IDEDMD", aGravaT6P[nT6P][4] )
                        oModel:LoadValue( "MODEL_T6P", "T6P_INDPGT", aGravaT6P[nT6P][5] )
                        oModel:LoadValue( "MODEL_T6P", "T6P_VLRLIQ", aGravaT6P[nT6P][6] )

                        /*T6Q -  */
                        nT6QAdd := 1
                        For nT6Q := 1 to Len(aGravaT6Q)

                            If  DTOS(aGravaT6Q[nT6Q][1])+aGravaT6Q[nT6Q][2]+aGravaT6Q[nT6Q][3]+aGravaT6Q[nT6Q][4]+aGravaT6Q[nT6Q][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                oModel:GetModel("MODEL_T6Q"):LVALID := .T.

                                If nT6QAdd > 1
                                    oModel:GetModel("MODEL_T6Q"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDRUBR", aGravaT6Q[nT6Q][6]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_QTDRUB", aGravaT6Q[nT6Q][7]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_FATRUB", aGravaT6Q[nT6Q][8]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRRUB", aGravaT6Q[nT6Q][9]  )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_VLRUNI", aGravaT6Q[nT6Q][10] )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_RUBRIC", aGravaT6Q[nT6Q][11] )
                                oModel:LoadValue( "MODEL_T6Q" , "T6Q_IDTABR", aGravaT6Q[nT6Q][12] )

                                nT6QAdd++

                            EndIf

                        Next nT6Q

                        /*T6R -  */
                        nT6RAdd := 1
                        For nT6R := 1 to Len(aGravaT6R)

                            If  DTOS(aGravaT6R[nT6R][1])+aGravaT6R[nT6R][2]+aGravaT6R[nT6R][3]+aGravaT6R[nT6R][4]+aGravaT6R[nT6R][5] == DTOS(aGravaT6P[nT6P][1])+aGravaT6P[nT6P][2]+aGravaT6P[nT6P][3]+aGravaT6P[nT6P][4]+aGravaT6P[nT6P][5]

                                oModel:GetModel("MODEL_T6R"):LVALID := .T.

                                If nT6RAdd > 1
                                    oModel:GetModel("MODEL_T6R"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T6R" , "T6R_IDRUBR", aGravaT6R[nT6R][6] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_QTDRUB", aGravaT6R[nT6R][7] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_FATRUB", aGravaT6R[nT6R][8] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRUNI", aGravaT6R[nT6R][9] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_VLRRUB", aGravaT6R[nT6R][10] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_RUBRIC", aGravaT6R[nT6R][11] )
                                oModel:LoadValue( "MODEL_T6R" , "T6R_IDTABR", aGravaT6R[nT6R][12] )

                                nT6RAdd++

                            EndIf

                        Next nT6R

                        nT6PAdd++

                    EndIf

                Next nT6P

                /*T5U -  */
                nT5UAdd := 1
                For nT5U := 1 to Len(aGravaT5U)

                    If  DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel( "MODEL_T5U" ):LVALID := .T.

                        If nT5UAdd > 1
                            oModel:GetModel( "MODEL_T5U" ):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T5U", "T5U_IDCATE", aGravaT5U[nT5U][3] )
                        oModel:LoadValue( "MODEL_T5U", "T5U_DTINIG", aGravaT5U[nT5U][4] )
                        oModel:LoadValue( "MODEL_T5U", "T5U_QTDIAS", aGravaT5U[nT5U][5] )
                        oModel:LoadValue( "MODEL_T5U", "T5U_VLRLIQ", aGravaT5U[nT5U][6] )

                        /*T5Y -  */
                        nT5YAdd := 1
                        For nT5Y := 1 to Len(aGravaT5Y)

                            If  DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])== DTOS(aGravaT5U[nT5U][1])+aGravaT5U[nT5U][2]+aGravaT5U[nT5U][3]+DTOS(aGravaT5U[nT5U][4])

                                oModel:GetModel("MODEL_T5Y"):LVALID := .T.

                                If nT5YAdd > 1
                                    oModel:GetModel("MODEL_T5Y"):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDRUBR", aGravaT5Y[nT5Y][5] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_QTDRUB", aGravaT5Y[nT5Y][6] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_FATRUB", aGravaT5Y[nT5Y][7] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRRUB", aGravaT5Y[nT5Y][8] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_VLRUNI", aGravaT5Y[nT5Y][9] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_RUBRIC", aGravaT5Y[nT5Y][10] )
                                oModel:LoadValue( "MODEL_T5Y" , "T5Y_IDTABR", aGravaT5Y[nT5Y][11] )

                                /*T5Z -  */
                                nT5ZAdd := 1
                                For nT5Z := 1 to Len(aGravaT5Z)

                                    If  DTOS(aGravaT5Z[nT5Z][1])+aGravaT5Z[nT5Z][2]+aGravaT5Z[nT5Z][3]+DTOS(aGravaT5Z[nT5Z][4])+aGravaT5Z[nT5Z][5] == DTOS(aGravaT5Y[nT5Y][1])+aGravaT5Y[nT5Y][2]+aGravaT5Y[nT5Y][3]+DTOS(aGravaT5Y[nT5Y][4])+aGravaT5Y[nT5Y][5]

                                        oModel:GetModel("MODEL_T5Z"):LVALID := .T.

                                        If nT5ZAdd > 1
                                            oModel:GetModel("MODEL_T5Z"):AddLine()
                                        EndIf

                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_CPFBEN", aGravaT5Z[nT5Z][6] )
                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_DTNSBE", aGravaT5Z[nT5Z][7] )
                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_NMBEN",  aGravaT5Z[nT5Z][8] )
                                        oModel:LoadValue( "MODEL_T5Z" , "T5Z_VLRPEN", aGravaT5Z[nT5Z][9] )

                                        nT5ZAdd++

                                    EndIf

                                Next nT5Z

                                nT5YAdd++

                            EndIf

                        Next nT5Y

                        nT5UAdd++

                    EndIf

                Next nT5U

                /*T5V -  */
                nT5VAdd := 1
                For nT5V := 1 to Len(aGravaT5V)

                    If  DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2] == DTOS(aGravaT3Q[nT3Q][1])+aGravaT3Q[nT3Q][2]

                        oModel:GetModel("MODEL_T5V"):LVALID := .T.

                        If nT5VAdd > 1
                            oModel:GetModel( "MODEL_T5V" ):AddLine()
                        EndIf

                        oModel:LoadValue( "MODEL_T5V", "T5V_IDCATE", aGravaT5V[nT5V][3] )

                        /*T5X - */
                        nT5XAdd := 1
                        For nT5X := 1 to Len(aGravaT5X)

                            If  DTOS(aGravaT5X[nT5X][1])+aGravaT5X[nT5X][2]+aGravaT5X[nT5X][3] == DTOS(aGravaT5V[nT5V][1])+aGravaT5V[nT5V][2]+aGravaT5V[nT5V][3]

                                oModel:GetModel( "MODEL_T5X" ):LVALID := .T.

                                If nT5XAdd > 1
                                    oModel:GetModel( "MODEL_T5X" ):AddLine()
                                EndIf

                                oModel:LoadValue( "MODEL_T5X" , "T5X_SEQUEN", aGravaT5X[nT5X][4] )
                                oModel:LoadValue( "MODEL_T5X" , "T5X_IDTPIR", aGravaT5X[nT5X][5] )
                                oModel:LoadValue( "MODEL_T5X" , "T5X_VLRBCI", aGravaT5X[nT5X][6] )

                                nT5XAdd++

                            EndIf

                        Next nT5X

                        nT5VAdd++

                    EndIf

                Next nT5V

            Next nT3Q

        Else

            oModelV6M := oMdlNvCen:GetModel("MODEL_V6M")
            oModelV9I := oMdlNvCen:GetModel("MODEL_V9I")
            oModelV9J := oMdlNvCen:GetModel("MODEL_V9J")

            For nV6M := 1 To oModelV6M:Length()

                oModelV6M:GoLine(nV6M)

                If !oModelV6M:IsEmpty()

                    If !oModelV6M:IsDeleted()

                        aAdd(aGravaV6M, {   oModelV6M:GetValue("V6M_DTPGTO"),;
                                            oModelV6M:GetValue("V6M_TPPGTO"),;
                                            oModelV6M:GetValue("V6M_PERREF"),;
                                            oModelV6M:GetValue("V6M_INDDEV"),;
                                            oModelV6M:GetValue("V6M_VLRLIQ")    })

                        If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")

                            AAdd(aGravaV6M[nV6M], oModelV6M:GetValue("V6M_PAIEXT"))

                            For nV9I := 1 To oModelV9I:Length()

                                oModelV9I:GoLine(nV9I)

                                If !oModelV9I:IsEmpty()

                                    If !oModelV9I:IsDeleted()

                                        AAdd(aGravaV9I, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                            oModelV6M:GetValue("V6M_PERREF"),;
                                                            oModelV6M:GetValue("V6M_INDDEV"),;                                   
                                                            oModelV9I:GetValue("V9I_INDNIF"),;
                                                            oModelV9I:GetValue("V9I_NIFBEN"),;
                                                            oModelV9I:GetValue("V9I_FRMTRI")    })
                                        
                                        For nV9J := 1 To oModelV9J:Length()

                                            oModelV9J:GoLine(nV9J)

                                            If !oModelV9J:IsEmpty()

                                                If !oModelV9J:IsDeleted()

                                                    AAdd(aGravaV9J, {   oModelV6M:GetValue("V6M_TPPGTO"),;
                                                                        oModelV6M:GetValue("V6M_PERREF"),;
                                                                        oModelV6M:GetValue("V6M_INDDEV"),;  
                                                                        oModelV9J:GetValue("V9J_DSCLOG"),;
                                                                        oModelV9J:GetValue("V9J_NRLOGR"),;
                                                                        oModelV9J:GetValue("V9J_COMPLE"),;
                                                                        oModelV9J:GetValue("V9J_BAIRRO"),;
                                                                        oModelV9J:GetValue("V9J_CIDADE"),;
                                                                        oModelV9J:GetValue("V9J_ESTADO"),;
                                                                        oModelV9J:GetValue("V9J_CODPOS"),;
                                                                        oModelV9J:GetValue("V9J_TELEF" )    })
                                                EndIf
                                            EndIf
                                        Next
                                    EndIf
                                EndIf
                            Next
                        EndIf
                    EndIf
                EndIf
            Next

            If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC"))

                V7S->(DBSetOrder(1))
                If V7S->(MsSeek(xFilial("V7S") + T3P->(T3P_ID + T3P_VERSAO)))
                    oModelV7S := oMdlNvCen:GetModel("MODEL_V7S")

                    For nV7S := 1 To oModelV7S:Length()
                        oModelV7S:GoLine(nV7S)

                        If !oModelV7S:IsEmpty()
                            If !oModelV7S:IsDeleted()
                                AAdd(aGravaV7S, {   oModelV7S:GetValue("V7S_CPFDEP"),;
                                                    oModelV7S:GetValue("V7S_DTNASC"),;
                                                    oModelV7S:GetValue("V7S_NMDEP" ),;
                                                    oModelV7S:GetValue("V7S_DPIRRF"),;
                                                    oModelV7S:GetValue("V7S_TPDEP" ),;
                                                    oModelV7S:GetValue("V7S_DSCDEP") })

                            EndIf 
                        EndIf 

                    Next
                    
                EndIf 

                V7T->(DBSetOrder(1))
                If V7T->(MsSeek(xFilial("V7T") + T3P->(T3P_ID + T3P_VERSAO)))
                    oModelV7T := oMdlNvCen:GetModel("MODEL_V7T")
                    oModelV7U := oMdlNvCen:GetModel("MODEL_V7U")
                    oModelV7V := oMdlNvCen:GetModel("MODEL_V7V")
                    oModelV7X := oMdlNvCen:GetModel("MODEL_V7X")
                    oModelV7W := oMdlNvCen:GetModel("MODEL_V7W")
                    oModelV7Y := oMdlNvCen:GetModel("MODEL_V7Y")
                    oModelV7Z := oMdlNvCen:GetModel("MODEL_V7Z")
                    oModelV8A := oMdlNvCen:GetModel("MODEL_V8A")

                    For nV7T := 1 To oModelV7T:Length()
                        oModelV7T:GoLine(nV7T)

                        If !oModelV7T:IsEmpty()
                            If !oModelV7T:IsDeleted()
                                AAdd(aGravaV7T, {   oModelV7T:GetValue("V7T_TPCR") })

                                For nV7U := 1 To oModelV7U:Length()
                                    oModelV7U:GoLine(nV7U)

                                    If !oModelV7U:IsEmpty()
                                        If !oModelV7U:IsDeleted()
                                            AAdd(aGravaV7U, {   oModelV7T:GetValue("V7T_TPCR"  ),;
                                                                oModelV7U:GetValue("V7U_TPREND"),;
                                                                oModelV7U:GetValue("V7U_CPFDEP"),;
                                                                oModelV7U:GetValue("V7U_VLRDED") })
                                        EndIf 
                                    EndIf 
                                Next

                                For nV7V := 1 To oModelV7V:Length()
                                    oModelV7V:GoLine(nV7V)

                                    If !oModelV7V:IsEmpty()
                                            If !oModelV7V:IsDeleted()
                                            AAdd(aGravaV7V, {   oModelV7T:GetValue("V7T_TPCR"  ),;
                                                                oModelV7V:GetValue("V7V_TPREND"),;
                                                                oModelV7V:GetValue("V7V_CPFDEP"),;
                                                                oModelV7V:GetValue("V7V_VLPEN" ) })
                                        EndIf
                                    EndIf 
                                Next 

                                For nV7W := 1 To oModelV7W:Length()
                                    oModelV7W:GoLine(nV7W)

                                    If !oModelV7W:IsEmpty()
                                        If !oModelV7W:IsDeleted()
                                            AAdd(aGravaV7W, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                oModelV7W:GetValue("V7W_TPREV"  ),;
                                                                oModelV7W:GetValue("V7W_INSCPL" ),;
                                                                oModelV7W:GetValue("V7W_VLCOMP" ),;
                                                                oModelV7W:GetValue("V7W_VLPATR" )})
                                        EndIf
                                    EndIf 
                                Next

                                For nV7X := 1 To oModelV7X:Length()
                                    oModelV7X:GoLine(nV7X)

                                    If !oModelV7X:IsEmpty()
                                        If !oModelV7X:IsDeleted()
                                            AAdd(aGravaV7X, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                oModelV7X:GetValue("V7X_TPPROC"  ),;
                                                                oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                oModelV7X:GetValue("V7X_CODSUP" )})

                                            For nV7Y := 1 To oModelV7Y:Length()
                                                oModelV7Y:GoLine(nV7Y)
                                                If !oModelV7Y:IsEmpty()
                                                    If !oModelV7Y:IsDeleted()
                                                        AAdd(aGravaV7Y, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                            oModelV7X:GetValue("V7X_TPPROC"  ),;
                                                                            oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                            oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                            oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                            oModelV7Y:GetValue("V7Y_VLRRET" ),;
                                                                            oModelV7Y:GetValue("V7Y_VLRJUD" ),;
                                                                            oModelV7Y:GetValue("V7Y_VLACAL" ),;
                                                                            oModelV7Y:GetValue("V7Y_VLAANT" ),;
                                                                            oModelV7Y:GetValue("V7Y_VLSUSP" )})

                                                        For nV7Z := 1 To oModelV7Z:Length()
                                                            oModelV7Z:GoLine(nV7Z)
                                                            If !oModelV7Z:IsEmpty()
                                                                If !oModelV7Z:IsDeleted()
                                                                    AAdd(aGravaV7Z, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                        oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                        oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                        oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                        oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                        oModelV7Z:GetValue("V7Z_TPDEDU" ),;
                                                                                        oModelV7Z:GetValue("V7Z_VLSUSP" ),;
                                                                                        oModelV7Z:GetValue("V7Z_INSCPL" ),;
                                                                                        oModelV7Z:GetValue("V7Z_VLFUNP" ),;
                                                                                        oModelV7Z:GetValue("V7Z_SEQUEN" )})

                                                                    For nV8A := 1 To oModelV8A:Length()
                                                                        oModelV8A:GoLine(nV8A)
                                                                        If !oModelV8A:IsEmpty()
                                                                            If !oModelV8A:IsDeleted()
                                                                                AAdd(aGravaV8A, {   oModelV7T:GetValue("V7T_TPCR"   ),;
                                                                                                    oModelV7X:GetValue("V7X_TPPROC" ),;
                                                                                                    oModelV7X:GetValue("V7X_NRPROC" ),;
                                                                                                    oModelV7X:GetValue("V7X_CODSUP" ),;
                                                                                                    oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                                                    oModelV8A:GetValue("V8A_CPFDEP" ),;
                                                                                                    oModelV8A:GetValue("V8A_VLSUSP" ),;
                                                                                                    oModelV8A:GetValue("V8A_SEQUEN" )})
                                                                            EndIf
                                                                        EndIf
                                                                    Next
                                                                EndIf
                                                            EndIf
                                                        Next 
                                                    EndIf
                                                EndIf
                                            Next
                                        EndIf
                                    EndIf
                                Next
                            EndIf 
                        EndIf
                    Next 
                EndIf 

                V8B->(DBSetOrder(1))
                If V8B->(MsSeek(xFilial("V8B") + T3P->(T3P_ID + T3P_VERSAO)))
                    oModelV8B := oMdlNvCen:GetModel("MODEL_V8B")
                    oModelV8C := oMdlNvCen:GetModel("MODEL_V8C")

                    For nV8B := 1 To oModelV8B:Length()
                        oModelV8B:GoLine(nV8B)

                        If !oModelV8B:IsEmpty()
                            If !oModelV8B:IsDeleted()
                                AAdd(aGravaV8B, {   oModelV8B:GetValue("V8B_CNPJOP" ),;
                                                    oModelV8B:GetValue("V8B_REGANS" ),;
                                                    oModelV8B:GetValue("V8B_VLRTIT" ) })

                                For nV8C := 1 To oModelV8C:Length()
                                    oModelV8C:GoLine(nV8C)

                                    If !oModelV8C:IsEmpty()
                                        If !oModelV8C:IsDeleted()
                                            AAdd(aGravaV8C, {   oModelV8B:GetValue("V8B_CNPJOP" ),;
                                                                oModelV8C:GetValue("V8C_CPFDEP" ),;
                                                                oModelV8C:GetValue("V8C_VLRDEP" ) })
                                        EndIf 
                                    EndIf 
                                Next 
                            EndIf
                        EndIf 
                    Next

                EndIf

                V8D->(DBSetOrder(1))
                If V8D->(MsSeek(xFilial("V8D") + T3P->(T3P_ID + T3P_VERSAO)))
                    oModelV8D := oMdlNvCen:GetModel("MODEL_V8D")
                    oModelV8E := oMdlNvCen:GetModel("MODEL_V8E")
                    oModelV8F := oMdlNvCen:GetModel("MODEL_V8F")
                    oModelV8G := oMdlNvCen:GetModel("MODEL_V8G")

                    For nV8D := 1 To oModelV8D:Length()
                        oModelV8D:GoLine(nV8D)
                        If !oModelV8D:IsEmpty()
                            If !oModelV8D:IsDeleted()
                                AAdd(aGravaV8D, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                    oModelV8D:GetValue("V8D_INDREM" ),;
                                                    oModelV8D:GetValue("V8D_CNPJOP" ),;
                                                    oModelV8D:GetValue("V8D_REGANS" )   })

                                For nV8F := 1 To oModelV8F:Length()
                                    oModelV8F:GoLine(nV8F)

                                    If !oModelV8F:IsEmpty()
                                        If !oModelV8F:IsDeleted()
                                                AAdd(aGravaV8F, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                                    oModelV8F:GetValue("V8F_CPFDEP" )   })
                                                                    
                                            For nV8G := 1 To oModelV8G:Length()
                                                oModelV8G:GoLine(nV8G)

                                                If !oModelV8G:IsEmpty()
                                                    If !oModelV8G:IsDeleted()
                                                        AAdd(aGravaV8G, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                                            oModelV8F:GetValue("V8F_CPFDEP" ),;
                                                                            oModelV8G:GetValue("V8G_TPINSC" ),;
                                                                            oModelV8G:GetValue("V8G_NRINSC" ),;
                                                                            oModelV8G:GetValue("V8G_VLREMB" ),;
                                                                            oModelV8G:GetValue("V8G_VLRANT" )   })
                                                    EndIf 
                                                EndIf
                                            Next
                                        EndIf 
                                    EndIf 
                                Next

                                For nV8E := 1 To oModelV8E:Length()
                                    oModelV8E:GoLine(nV8E)

                                    If !oModelV8E:IsEmpty()
                                        If !oModelV8E:IsDeleted()
                                            AAdd(aGravaV8E, {   oModelV8D:GetValue("V8D_SEQUEN" ),;
                                                                oModelV8E:GetValue("V8E_TPINSC" ),;
                                                                oModelV8E:GetValue("V8E_NRINSC" ),;
                                                                oModelV8E:GetValue("V8E_VLREMB" ),;
                                                                oModelV8E:GetValue("V8E_VLRANT" )   })
                                        EndIf 
                                    EndIf
                                Next
                            EndIf 
                        EndIf
                    Next 
                EndIf
            ElseIf lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC") 

                T8E->(DBSetOrder(1))
                If T8E->(MsSeek(xFilial("T8E") + T3P->(T3P_ID + T3P_VERSAO)))

                    oModelV7S := oModel:GetModel("MODEL_V7S")
                    oModelV7T := oModel:GetModel("MODEL_V7T")
                    oModelV7U := oModel:GetModel("MODEL_V7U")
                    oModelV7V := oModel:GetModel("MODEL_V7V")
                    oModelV7W := oModel:GetModel("MODEL_V7W")
                    oModelV7X := oModel:GetModel("MODEL_V7X")
                    oModelV7Y := oModel:GetModel("MODEL_V7Y")
                    oModelV7Z := oModel:GetModel("MODEL_V7Z")
                    oModelV8A := oModel:GetModel("MODEL_V8A")
                    oModelT8E := oModel:GetModel("MODEL_T8E")

                    GetAgrava( oModel, oModelV7S, oModelV7T, oModelV7U, oModelV7V, oModelV7W, oModelV7X, oModelV7Y, oModelV7Z, oModelV8A, oModelV8B,;
                               oModelV8C, oModelV8D, oModelV8E, oModelV8F, oModelV8G, oModelT8E, @aGravaT8E, @aGravaV7T, @aGravaV7U, @aGravaV7V,;
                               @aGravaV7W, @aGravaV7X, @aGravaV7Y, @aGravaV7Z, @aGravaV8A, @aGravaV8B, @aGravaV8C, @aGravaV8D, @aGravaV8F, @aGravaV8G, @aGravaV8E  )
                EndIf

            EndIf

            nV6MAdd := 1

            For nV6M := 1 To Len(aGravaV6M)

                oModel:GetModel("MODEL_V6M"):lValid := .T.

                If nV6MAdd > 1
                    oModel:GetModel("MODEL_V6M"):AddLine()
                EndIf

                oModel:LoadValue("MODEL_V6M", "V6M_DTPGTO", aGravaV6M[nV6M][1])
                oModel:LoadValue("MODEL_V6M", "V6M_TPPGTO", aGravaV6M[nV6M][2])
                oModel:LoadValue("MODEL_V6M", "V6M_PERREF", aGravaV6M[nV6M][3])
                oModel:LoadValue("MODEL_V6M", "V6M_INDDEV", aGravaV6M[nV6M][4])
                oModel:LoadValue("MODEL_V6M", "V6M_VLRLIQ", aGravaV6M[nV6M][5])

                If lSimplBeta .And. TAFColumnPos("V6M_PAIEXT")

                    oModel:LoadValue("MODEL_V6M", "V6M_PAIEXT", aGravaV6M[nV6M][6])
                    
                    For nV9I := 1 To Len(aGravaV9I)

                        If aGravaV9I[nV9I][1] + aGravaV9I[nV9I][2] + aGravaV9I[nV9I][3] == aGravaV6M[nV6M][2] +;
                            aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]

                            oModel:GetModel("MODEL_V9I"):lValid := .T.
                                                      
                            oModel:LoadValue("MODEL_V9I", "V9I_INDNIF", aGravaV9I[nV9I][4])
                            oModel:LoadValue("MODEL_V9I", "V9I_NIFBEN", aGravaV9I[nV9I][5])
                            oModel:LoadValue("MODEL_V9I", "V9I_FRMTRI", aGravaV9I[nV9I][6])

                            For nV9J := 1 To Len(aGravaV9J)

                                If aGravaV9J[nV9J][1] + aGravaV9J[nV9J][2] + aGravaV9J[nV9J][3] == aGravaV6M[nV6M][2] +;
                                    aGravaV6M[nV6M][3] + aGravaV6M[nV6M][4]

                                    oModel:GetModel("MODEL_V9J"):lValid := .T.
                                        
                                    oModel:LoadValue("MODEL_V9J", "V9J_DSCLOG", aGravaV9J[nV9J][4])
                                    oModel:LoadValue("MODEL_V9J", "V9J_NRLOGR", aGravaV9J[nV9J][5])
                                    oModel:LoadValue("MODEL_V9J", "V9J_COMPLE", aGravaV9J[nV9J][6])
                                    oModel:LoadValue("MODEL_V9J", "V9J_BAIRRO", aGravaV9J[nV9J][7])
                                    oModel:LoadValue("MODEL_V9J", "V9J_CIDADE", aGravaV9J[nV9J][8])
                                    oModel:LoadValue("MODEL_V9J", "V9J_ESTADO", aGravaV9J[nV9J][9])
                                    oModel:LoadValue("MODEL_V9J", "V9J_CODPOS", aGravaV9J[nV9J][10])
                                    oModel:LoadValue("MODEL_V9J", "V9J_TELEF" , aGravaV9J[nV9J][11])
                                    
                                EndIf
                            Next
                        EndIf
                    Next
                EndIf

                nV6MAdd++
            Next

            If lLayout12 .AND. !( lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC"))
                nV7SAdd := 1

                For nV7S := 1 To Len(aGravaV7S)
                    oModel:GetModel("MODEL_V7S"):lValid := .T.

                    If nV7SAdd > 1
                        oModel:GetModel("MODEL_V7S"):AddLine()
                    EndIf

                    oModel:LoadValue("MODEL_V7S", "V7S_CPFDEP"  , aGravaV7S[nV7S][1])
                    oModel:LoadValue("MODEL_V7S", "V7S_DTNASC"  , aGravaV7S[nV7S][2])
                    oModel:LoadValue("MODEL_V7S", "V7S_NMDEP"   , aGravaV7S[nV7S][3])
                    oModel:LoadValue("MODEL_V7S", "V7S_DPIRRF"  , aGravaV7S[nV7S][4])
                    oModel:LoadValue("MODEL_V7S", "V7S_TPDEP"   , aGravaV7S[nV7S][5])
                    oModel:LoadValue("MODEL_V7S", "V7S_DSCDEP"  , aGravaV7S[nV7S][6])

                    nV7SAdd++
                Next 

                nV7TAdd := 1

                For nV7T := 1 To Len(aGravaV7T)
                    oModel:GetModel("MODEL_V7T"):lValid := .T.

                    If nV7TAdd > 1
                        oModel:GetModel("MODEL_V7T"):AddLine()
                    EndIf

                    oModel:LoadValue("MODEL_V7T", "V7T_TPCR"  , aGravaV7T[nV7T][1])

                    nV7UAdd := 1

                    For nV7U := 1 To Len(aGravaV7U)
                        If aGravaV7T[nV7T][1] == aGravaV7U[nV7U][1]

                            oModel:GetModel("MODEL_V7U"):lValid := .T.

                            If nV7UAdd > 1
                                oModel:GetModel("MODEL_V7U"):AddLine()
                            EndIf

                            oModel:LoadValue("MODEL_V7U", "V7U_TPCR"    , aGravaV7U[nV7U][1])
                            oModel:LoadValue("MODEL_V7U", "V7U_TPREND"  , aGravaV7U[nV7U][2])
                            oModel:LoadValue("MODEL_V7U", "V7U_CPFDEP"  , aGravaV7U[nV7U][3])
                            oModel:LoadValue("MODEL_V7U", "V7U_VLRDED"  , aGravaV7U[nV7U][4])

                            nV7UAdd++
                        EndIf 
                    Next

                    nV7VAdd := 1

                    For nV7V := 1 To Len(aGravaV7V)
                        If aGravaV7T[nV7T][1] == aGravaV7V[nV7V][1]

                            oModel:GetModel("MODEL_V7V"):lValid := .T.

                            If nV7VAdd > 1
                                oModel:GetModel("MODEL_V7V"):AddLine()
                            EndIf

                            oModel:LoadValue("MODEL_V7V", "V7V_TPCR"    , aGravaV7V[nV7V][1])
                            oModel:LoadValue("MODEL_V7V", "V7V_TPREND"  , aGravaV7V[nV7V][2])
                            oModel:LoadValue("MODEL_V7V", "V7V_CPFDEP"  , aGravaV7V[nV7V][3])
                            oModel:LoadValue("MODEL_V7V", "V7V_VLPEN"   , aGravaV7V[nV7V][4])

                            nV7VAdd++
                        EndIf 
                    Next

                    nV7WAdd := 1

                    For nV7W := 1 To Len(aGravaV7W)
                        If aGravaV7T[nV7T][1] == aGravaV7W[nV7W][1]

                            oModel:GetModel("MODEL_V7W"):lValid := .T.

                            If nV7WAdd > 1
                                oModel:GetModel("MODEL_V7W"):AddLine()
                            EndIf

                            oModel:LoadValue("MODEL_V7W", "V7W_TPCR"    , aGravaV7W[nV7W][1])
                            oModel:LoadValue("MODEL_V7W", "V7W_TPREV"   , aGravaV7W[nV7W][2])
                            oModel:LoadValue("MODEL_V7W", "V7W_INSCPL"  , aGravaV7W[nV7W][3])
                            oModel:LoadValue("MODEL_V7W", "V7W_VLCOMP"  , aGravaV7W[nV7W][4])
                            oModel:LoadValue("MODEL_V7W", "V7W_VLPATR"  , aGravaV7W[nV7W][5])

                            nV7WAdd++
                        EndIf 
                    Next

                    nV7XAdd := 1

                    For nV7X := 1 To Len(aGravaV7X)
                        If aGravaV7T[nV7T][1] == aGravaV7X[nV7X][1]

                            oModel:GetModel("MODEL_V7X"):lValid := .T.

                            If nV7XAdd > 1
                                oModel:GetModel("MODEL_V7X"):AddLine()
                            EndIf

                            oModel:LoadValue("MODEL_V7X", "V7X_TPCR"    , aGravaV7X[nV7X][1])
                            oModel:LoadValue("MODEL_V7X", "V7X_TPPROC"  , aGravaV7X[nV7X][2])
                            oModel:LoadValue("MODEL_V7X", "V7X_NRPROC"  , aGravaV7X[nV7X][3])
                            oModel:LoadValue("MODEL_V7X", "V7X_CODSUP"  , aGravaV7X[nV7X][4])


                            nV7YAdd := 1

                            For nV7Y := 1 To Len(aGravaV7Y)
                                If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4] == aGravaV7Y[nV7Y][1]+aGravaV7Y[nV7Y][2]+aGravaV7Y[nV7Y][3]+aGravaV7Y[nV7Y][4] 

                                    oModel:GetModel("MODEL_V7Y"):lValid := .T.

                                    If nV7YAdd > 1
                                        oModel:GetModel("MODEL_V7Y"):AddLine()
                                    EndIf

                                    oModel:LoadValue("MODEL_V7Y", "V7Y_TPCR"    , aGravaV7Y[nV7Y][1] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_TPPROC"  , aGravaV7Y[nV7Y][2] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_NRPROC"  , aGravaV7Y[nV7Y][3] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_CODSUP"  , aGravaV7Y[nV7Y][4] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_INDAPU"  , aGravaV7Y[nV7Y][5] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLRRET"  , aGravaV7Y[nV7Y][6] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLRJUD"  , aGravaV7Y[nV7Y][7] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLACAL"  , aGravaV7Y[nV7Y][8] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLAANT"  , aGravaV7Y[nV7Y][9] )
                                    oModel:LoadValue("MODEL_V7Y", "V7Y_VLSUSP"  , aGravaV7Y[nV7Y][10])

                                    nV7ZAdd := 1

                                    For nV7Z := 1 To Len(aGravaV7Z)
                                        If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5] == aGravaV7Z[nV7Z][1]+aGravaV7Z[nV7Z][2]+aGravaV7Z[nV7Z][3]+aGravaV7Z[nV7Z][4]+aGravaV7Z[nV7Z][5]

                                            oModel:GetModel("MODEL_V7Z"):lValid := .T.

                                            If nV7ZAdd > 1
                                                oModel:GetModel("MODEL_V7Z"):AddLine()
                                            EndIf  

                                            oModel:LoadValue("MODEL_V7Z", "V7Z_TPCR"    , aGravaV7Z[nV7Z][1] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_TPPROC"  , aGravaV7Z[nV7Z][2] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_NRPROC"  , aGravaV7Z[nV7Z][3] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_CODSUP"  , aGravaV7Z[nV7Z][4] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_INDAPU"  , aGravaV7Z[nV7Z][5] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_TPDEDU"  , aGravaV7Z[nV7Z][6] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_VLSUSP"  , aGravaV7Z[nV7Z][7] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_INSCPL"  , aGravaV7Z[nV7Z][8] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_VLFUNP"  , aGravaV7Z[nV7Z][9] )
                                            oModel:LoadValue("MODEL_V7Z", "V7Z_SEQUEN"  , aGravaV7Z[nV7Z][10] )
                                            
                                            nV8AAdd := 1

                                            For nV8A := 1 To Len(aGravaV8A)
                                                If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5]+aGravaV7Z[nV7Z][10]  == aGravaV8A[nV8A][1]+aGravaV8A[nV8A][2]+aGravaV8A[nV8A][3]+aGravaV8A[nV8A][4]+aGravaV8A[nV8A][5]+aGravaV8A[nV8A][8]
                                                    
                                                    oModel:GetModel("MODEL_V8A"):lValid := .T.
                                                    
                                                    If nV8AAdd > 1
                                                        oModel:GetModel("MODEL_V8A"):AddLine()
                                                    EndIf
                                                    
                                                    oModel:LoadValue("MODEL_V8A", "V8A_TPCR"    , aGravaV8A[nV8A][1] )
                                                    oModel:LoadValue("MODEL_V8A", "V8A_TPPROC"  , aGravaV8A[nV8A][2] )
                                                    oModel:LoadValue("MODEL_V8A", "V8A_NRPROC"  , aGravaV8A[nV8A][3] )
                                                    oModel:LoadValue("MODEL_V8A", "V8A_CODSUP"  , aGravaV8A[nV8A][4] )
                                                    oModel:LoadValue("MODEL_V8A", "V8A_INDAPU"  , aGravaV8A[nV8A][5] )
                                                    oModel:LoadValue("MODEL_V8A", "V8A_CPFDEP"  , aGravaV8A[nV8A][6] )
                                                    oModel:LoadValue("MODEL_V8A", "V8A_VLSUSP"  , aGravaV8A[nV8A][7] )
                                                    oModel:LoadValue("MODEL_V8A", "V8A_SEQUEN"  , aGravaV8A[nV8A][8] )

                                                    nV8AAdd++
                                                EndIf 
                                            Next 

                                            nV7ZAdd++
                                        EndIf 
                                    Next 
                                    nV7YAdd++
                                EndIf
                            Next

                            nV7XAdd++
                        EndIf 
                    Next

                    nV7TAdd++
                Next 

                nV8BAdd := 1

                For nV8B := 1 To Len(aGravaV8B)
                    oModel:GetModel("MODEL_V8B"):lValid := .T.

                    If nV8BAdd > 1
                        oModel:GetModel("MODEL_V8B"):AddLine()
                    EndIf

                    oModel:LoadValue("MODEL_V8B", "V8B_CNPJOP"  , aGravaV8B[nV8B][1])
                    oModel:LoadValue("MODEL_V8B", "V8B_REGANS"  , aGravaV8B[nV8B][2])
                    oModel:LoadValue("MODEL_V8B", "V8B_VLRTIT"  , aGravaV8B[nV8B][3])

                    nV8CAdd := 1

                    For nV8C := 1 To Len(aGravaV8C)
                        If aGravaV8B[nV8B][1] == aGravaV8C[nV8C][1]
                            oModel:GetModel("MODEL_V8C"):lValid := .T.
                            
                            If nV8CAdd > 1
                                oModel:GetModel("MODEL_V8C"):AddLine()
                            EndIf

                            oModel:LoadValue("MODEL_V8C", "V8C_CNPJOP"  , aGravaV8C[nV8C][1])
                            oModel:LoadValue("MODEL_V8C", "V8C_CPFDEP"  , aGravaV8C[nV8C][2])
                            oModel:LoadValue("MODEL_V8C", "V8C_VLRDEP"  , aGravaV8C[nV8C][3])

                            nV8CAdd++
                        EndIf
                    Next 
                    nV8BAdd++
                Next 

                nV8DAdd := 1

                For nV8D := 1 To Len(aGravaV8D)
                    
                    oModel:GetModel("MODEL_V8D"):lValid := .T.

                    If nV8DAdd > 1
                        oModel:GetModel("MODEL_V8D"):AddLine()
                    EndIf

                    oModel:LoadValue("MODEL_V8D", "V8D_SEQUEN"  , aGravaV8D[nV8D][1])
                    oModel:LoadValue("MODEL_V8D", "V8D_INDREM"  , aGravaV8D[nV8D][2])
                    oModel:LoadValue("MODEL_V8D", "V8D_CNPJOP"  , aGravaV8D[nV8D][3])
                    oModel:LoadValue("MODEL_V8D", "V8D_REGANS"  , aGravaV8D[nV8D][4])

                    nV8EAdd := 1

                    For nV8E := 1 To Len(aGravaV8E)
                        If aGravaV8D[nV8D][1] == aGravaV8E[nV8E][1]
                            oModel:GetModel("MODEL_V8E"):lValid := .T.

                            If nV8EAdd > 1
                                oModel:GetModel("MODEL_V8E"):AddLine()
                            EndIf

                            oModel:LoadValue("MODEL_V8E", "V8E_SEQUEN"  , aGravaV8E[nV8E][1])
                            oModel:LoadValue("MODEL_V8E", "V8E_TPINSC"  , aGravaV8E[nV8E][2])
                            oModel:LoadValue("MODEL_V8E", "V8E_NRINSC"  , aGravaV8E[nV8E][3])
                            oModel:LoadValue("MODEL_V8E", "V8E_VLREMB"  , aGravaV8E[nV8E][4])
                            oModel:LoadValue("MODEL_V8E", "V8E_VLRANT"  , aGravaV8E[nV8E][5])

                            nV8EAdd++
                        EndIf 
                    Next

                    nV8FAdd := 1
                    For nV8F := 1 To Len(aGravaV8F)
                        If aGravaV8D[nV8D][1] == aGravaV8F[nV8F][1]
                            oModel:GetModel("MODEL_V8F"):lValid := .T.

                            If nV8FAdd > 1
                                oModel:GetModel("MODEL_V8F"):AddLine()
                            EndIf

                            oModel:LoadValue("MODEL_V8F", "V8F_SEQUEN"  , aGravaV8F[nV8F][1])
                            oModel:LoadValue("MODEL_V8F", "V8F_CPFDEP"  , aGravaV8F[nV8F][2])

                            nV8GAdd := 1
                            For nV8G := 1 To Len(aGravaV8G)
                                If aGravaV8F[nV8F][1] + aGravaV8F[nV8F][2] == aGravaV8G[nV8G][1] + aGravaV8G[nV8G][2]
                                    oModel:GetModel("MODEL_V8G"):lValid := .T.

                                    If nV8GAdd > 1
                                        oModel:GetModel("MODEL_V8G"):AddLine()
                                    EndIf

                                    oModel:LoadValue("MODEL_V8G", "V8G_SEQUEN"  , aGravaV8G[nV8G][1])
                                    oModel:LoadValue("MODEL_V8G", "V8G_CPFDEP"  , aGravaV8G[nV8G][2])
                                    oModel:LoadValue("MODEL_V8G", "V8G_TPINSC"  , aGravaV8G[nV8G][3])
                                    oModel:LoadValue("MODEL_V8G", "V8G_NRINSC"  , aGravaV8G[nV8G][4])
                                    oModel:LoadValue("MODEL_V8G", "V8G_VLREMB"  , aGravaV8G[nV8G][5])
                                    oModel:LoadValue("MODEL_V8G", "V8G_VLRANT"  , aGravaV8G[nV8G][6])
                                
                                    nV8GAdd++
                                EndIf 
                            Next

                            nV8FAdd++
                        EndIf
                    Next
                    nV8DAdd++
                Next
            ElseIf lSimpl0103 .AND. TafColumnPos("T8E_SEQIRC")
                TAFRecArray(@oModel, aGravaT8E, aGravaV7T, aGravaV7U, aGravaV7V, aGravaV7W, aGravaV7X, aGravaV7Y, aGravaV7Z, aGravaV8A, aGravaV8B, aGravaV8C, aGravaV8D, aGravaV8F, aGravaV8G, aGravaV8E)
            EndIf 

        EndIf

    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF407Trigger
Criação da trigger
@author  Rodrigo Nicolino
@since   04/05/2021
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAF407Trigger()

	Local aAux as Array
    
    aAux := FwStruTrigger("T3P_BENEFI",;                                        // Campo Dominio
                          "T3P_CPF",;                                           // Campo de Contradominio
                          "TafGetCPF(T3P->T3P_FILIAL,M->T3P_BENEFI,,'T3P')",; 	// Regra de Preenchimento
                          .F.,;                                                 // Se posicionara ou nao antes da execucao do gatilhos
                          "",;                                                  // Alias da tabela a ser posicionada
                          0 ,;                                                  // Ordem da tabela a ser posicionada
                          "",;                                                  // Chave de busca da tabela a ser posicionada
                          "!Empty(M->T3P_BENEFI)",;                             // Condicao para execucao do gatilho
                          "001" )                                               // Sequencia do gatilho (usado para identificacao no caso de erro)

Return aAux

//--------------------------------------------------------------------
/*/{Protheus.doc} GetAgrava

Pega os valores gravados nos grid's

@author Alexande Lima
@since 08/08/2024
@version 1.0

oModel as object, objeto geral
oModelV7S as object, objeto especifico para buscar os dados da tabela
oModelV7T as Object, objeto especifico para buscar os dados da tabela
oModelV7U as Object, objeto especifico para buscar os dados da tabela
oModelV7V as Object, objeto especifico para buscar os dados da tabela
oModelV7W as Object, objeto especifico para buscar os dados da tabela
oModelV7X as Object, objeto especifico para buscar os dados da tabela
oModelV7Y as Object, objeto especifico para buscar os dados da tabela
oModelV7Z as Object, objeto especifico para buscar os dados da tabela
oModelV8A as Object, objeto especifico para buscar os dados da tabela
oModelV8B as object, objeto especifico para buscar os dados da tabela
oModelV8C as object, objeto especifico para buscar os dados da tabela
oModelV8D as object, objeto especifico para buscar os dados da tabela
oModelV8E as object, objeto especifico para buscar os dados da tabela
oModelV8F as object, objeto especifico para buscar os dados da tabela
oModelV8G as object, objeto especifico para buscar os dados da tabela
oModelT8E as Object, objeto especifico para buscar os dados da tabela
aGravaT8E as array, array especifico para buscar os dados da tabela
aGravaV7U as array, array especifico para buscar os dados da tabela
aGravaV7V as array, array especifico para buscar os dados da tabela
aGravaV7W as array, array especifico para buscar os dados da tabela
aGravaV7X as array, array especifico para buscar os dados da tabela
aGravaV7Y as array, array especifico para buscar os dados da tabela
aGravaV7Z as array, array especifico para buscar os dados da tabela
aGravaV8A as array, array especifico para buscar os dados da tabela
aGravaV8B as array, array especifico para buscar os dados da tabela
aGravaV8C as array, array especifico para buscar os dados da tabela
aGravaV8D as array, array especifico para buscar os dados da tabela
aGravaV8F as array, array especifico para buscar os dados da tabela
aGravaV8G as array, array especifico para buscar os dados da tabela
aGravaV8E  as array array especifico para buscar os dados da tabela

/*/
//--------------------------------------------------------------------

Function GetAgrava( oModel as object, oModelV7S as object, oModelV7T as Object, oModelV7U as Object, oModelV7V as Object, oModelV7W as Object, oModelV7X as Object, oModelV7Y as Object, oModelV7Z as Object, oModelV8A as Object, oModelV8B as object,;
                    oModelV8C as object, oModelV8D as object, oModelV8E as object, oModelV8F as object, oModelV8G as object, oModelT8E as Object, aGravaT8E  as array, aGravaV7T  as array, aGravaV7U  as array, aGravaV7V  as array,;
                    aGravaV7W as array, aGravaV7X  as array, aGravaV7Y  as array, aGravaV7Z  as array, aGravaV8A  as array, aGravaV8B  as array, aGravaV8C  as array, aGravaV8D  as array, aGravaV8F  as array, aGravaV8G  as array, aGravaV8E  as array, aGravaV7S as array)
    
    Local nT8E as numeric
    Local nV7T as numeric
    Local nV7U as numeric
    Local nV7V as numeric
    Local nV7W as numeric
    Local nV7X as numeric
    Local nV7Y as numeric
    Local nV7Z as numeric
    Local nV8A as numeric
    Local nV8B as numeric
    Local nV8C as numeric
    Local nV8D as numeric
    Local nV8F as numeric
    Local nV8G as numeric
    Local nV8E as numeric
    LocaL nV7S as numeric
    Local aCampos as array
    Local lOk as logical
    
    nT8E := 0
    nV7T := 0
    nV7U := 0
    nV7V := 0
    nV7W := 0
    nV7X := 0
    nV7Y := 0
    nV7Z := 0
    nV8A := 0
    nV8B := 0
    nV8C := 0
    nV8D := 0
    nV8F := 0
    nV8G := 0
    nV8E := 0
    nV7S := 0

    lOk := .F.

    aCampos   := {}

    Default oModel    := Nil
    Default oModelV7S := Nil
    Default oModelV7T := Nil 
    Default oModelV7U := Nil 
    Default oModelV7V := Nil 
    Default oModelV7W := Nil 
    Default oModelV7X := Nil
    Default oModelV7Y := Nil 
    Default oModelV7Z := Nil 
    Default oModelV8A := Nil 
    Default oModelV8B := Nil
    Default oModelV8C := Nil 
    Default oModelV8D := Nil 
    Default oModelV8E := Nil 
    Default oModelV8F := Nil 
    Default oModelV8G := Nil 
    Default oModelT8E := Nil

    Default aGravaT8E := {}
    Default aGravaV7T := {}
    Default aGravaV7U := {}
    Default aGravaV7V := {}
    Default aGravaV7W := {}
    Default aGravaV7X := {}
    Default aGravaV7Y := {}
    Default aGravaV7Z := {}
    Default aGravaV8A := {}
    Default aGravaV8B := {}
    Default aGravaV8C := {}
    Default aGravaV8D := {}
    Default aGravaV8F := {}
    Default aGravaV8G := {}
    Default aGravaV8E := {}
    Default aGravaV7S := {}

    For nT8E := 1 To oModel:GetModel("MODEL_T8E"):Length()

        aCampos := { "T8E_PERREF", "T8E_NRREC", "T8E_SEQIRC", "T8E_DTLAUD" } 
        KingLitle( oModelT8E, "MODEL_T8E", oModel, aCampos, nT8E, "T8E",  @lOk, @aGravaT8E ) 

        V7S->(DBSetOrder(2))

        If V7S->(MsSeek(xFilial("V7S") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC )))// CRIAR INDICE

            aCampos := { "V7S_CPFDEP","V7S_DTNASC", "V7S_NMDEP", "V7S_DPIRRF", "V7S_TPDEP", "V7S_DSCDEP", "V7S_SEQIRC" }
            KingLitle(oModelV7S, "MODEL_V7S", oModel, aCampos, nV7S, "V7S",  @lOk, @aGravaV7S)
            
        EndIf 

        V7T->(DBSetOrder(2))
        If V7T->(MsSeek(xFilial("V7T") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC )))// CRIAR INDICE

            For nV7T := 1 To oModel:GetModel("MODEL_V7T"):Length()

                aCampos := { "V7T_TPCR", "V7T_SEQIRC"}
                KingLitle(oModelV7T, "MODEL_V7T", oModel, aCampos, nV7T, "V7T", @lOk, @aGravaV7T)

                If lOk 

                    For nV7U := 1 To oModel:GetModel("MODEL_V7U"):Length()
                        aCampos := { oModelV7T:GetValue("V7T_TPCR"  ), "V7U_TPREND", "V7U_CPFDEP", "V7U_VLRDED", "V7U_SEQIRC" }
                        KingLitle(oModelV7U, "MODEL_V7U", oModel, aCampos, nV7U, "V7U", @lOk, @aGravaV7U )  
                                                                
                    Next

                    For nV7V := 1 To oModel:GetModel("MODEL_V7V"):Length()
                    
                        aCampos := { oModelV7T:GetValue("V7T_TPCR") , "V7V_TPREND", "V7V_CPFDEP", "V7V_VLPEN", "V7V_SEQIRC" }
                        KingLitle(oModelV7V, "MODEL_V7V", oModel, aCampos, nV7V, "V7V", @lOk, @aGravaV7V)
                
                    Next 

                    For nV7W := 1 To oModel:GetModel("MODEL_V7W"):Length()

                        aCampos := { oModelV7T:GetValue("V7T_TPCR") , "V7W_TPREV", "V7W_INSCPL", "V7W_VLCOMP", "V7W_VLPATR","V7W_VLDEP1", "V7W_VLPA13", "V7W_SEQIRC" }
                        KingLitle(oModelV7W, "MODEL_V7W", oModel, aCampos, nV7W, "V7W", @lOk, @aGravaV7W)

                    Next

                    For nV7X := 1 To oModel:GetModel("MODEL_V7X"):Length()

                        aCampos := { oModelV7T:GetValue("V7T_TPCR") , "V7X_TPPROC", "V7X_NRPROC", "V7X_CODSUP", "V7X_SEQIRC"}
                        KingLitle(oModelV7X, "MODEL_V7X", oModel, aCampos, nV7X, "V7X", @lOk, @aGravaV7X)

                        If lOk
                            For nV7Y := 1 To oModel:GetModel("MODEL_V7Y"):Length()

                                aCampos := { oModelV7T:GetValue("V7T_TPCR") , oModelV7X:GetValue("V7X_TPPROC" ), oModelV7X:GetValue("V7X_NRPROC" ), oModelV7X:GetValue("V7X_CODSUP" ),"V7Y_INDAPU","V7Y_VLRRET","V7Y_VLRJUD","V7Y_VLACAL","V7Y_VLAANT","V7Y_VLSUSP", "V7Y_SEQIRC" }
                                KingLitle(oModelV7Y, "MODEL_V7Y", oModel, aCampos, nV7Y, "V7Y", @lOk, @aGravaV7Y)
                                
                                If lOk
                                    For nV7Z := 1 To oModel:GetModel("MODEL_V7Z"):Length()
                                        
                                        aCampos := { oModelV7T:GetValue("V7T_TPCR") , oModelV7X:GetValue("V7X_TPPROC" ), oModelV7X:GetValue("V7X_NRPROC" ), oModelV7X:GetValue("V7X_CODSUP" ),oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                        "V7Z_TPDEDU","V7Z_VLSUSP","V7Z_INSCPL","V7Z_VLFUNP","V7Z_SEQUEN", "V7Z_SEQIRC" }
                                        KingLitle(oModelV7Z, "MODEL_V7Z", oModel, aCampos, nV7Z, "V7Z", @lOk, @aGravaV7Z )
                                        
                                        If lOk

                                            For nV8A := 1 To oModel:Getmodel("MODEL_V8A"):Length()
                                                
                                                aCampos := { oModelV7T:GetValue("V7T_TPCR") , oModelV7X:GetValue("V7X_TPPROC" ), oModelV7X:GetValue("V7X_NRPROC" ), oModelV7X:GetValue("V7X_CODSUP" ),oModelV7Y:GetValue("V7Y_INDAPU" ),;
                                                                "V8A_CPFDEP","V8A_VLSUSP",oModelV7Z:GetValue("V7Z_SEQUEN" ), "V8A_SEQIRC" }
                                                KingLitle(oModelV8A, "MODEL_V8A", oModel, aCampos, nV8A, "V8A", @lOk, @aGravaV8A ) 
                                                
                                            Next
                                        EndIf
                                    Next 
                                EndIf
                            Next
                        EndIf
                    Next
                EndIf
            Next 

        EndIf

        If TafColumnPos("V8B_SEQUEN")
            V8B->(DBSetOrder(3))
        Else
            V8B->(DBSetOrder(2))
        EndIf
        
        If V8B->(MsSeek(xFilial("V8B") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC )))
            
            oModelV8B := oModel:GetModel("MODEL_V8B")
            oModelV8C := oModel:GetModel("MODEL_V8C")

            If TAFColumnPos("V8B_SEQUEN")
                aCamposV8B := { "V8B_CNPJOP","V8B_REGANS","V8B_VLRTIT","V8B_SEQIRC", "V8B_SEQUEN"}
                aCamposV8C := { oModelV8B:GetValue("V8B_CNPJOP" ),"V8C_CPFDEP","V8C_VLRDEP","V8C_SEQIRC", "V8C_SEQUEN"}
            Else
                aCamposV8B := { "V8B_CNPJOP","V8B_REGANS","V8B_VLRTIT","V8B_SEQIRC" }
                aCamposV8C := { oModelV8B:GetValue("V8B_CNPJOP" ),"V8C_CPFDEP","V8C_VLRDEP","V8C_SEQIRC" }
            EndIf 


            For nV8B := 1 To oModel:Getmodel("MODEL_V8B"):Length()
                KingLitle( oModelV8B, "MODEL_V8B", oModel, aCamposV8B, nV8B, "V8B", @lOk, @aGravaV8B)
                
                For nV8C := 1 To oModel:Getmodel("MODEL_V8C"):Length()
                    KingLitle( oModelV8C, "MODEL_V8C", oModel, aCamposV8C, nV8C, "V8C", @lOk, @aGravaV8C)
                Next     
            Next

        EndIf

        V8D->(DBSetOrder(2))
        If V8D->(MsSeek(xFilial("V8D") + T8E->(T8E_ID + T8E_VERSAO + T8E_SEQIRC )))// CRIAR INDICE
        
            oModelV8D := oModel:GetModel("MODEL_V8D")
            oModelV8E := oModel:GetModel("MODEL_V8E")
            oModelV8F := oModel:GetModel("MODEL_V8F")
            oModelV8G := oModel:GetModel("MODEL_V8G")

            For nV8D := 1 To oModel:Getmodel("MODEL_V8D"):Length()

                aCampos := { "V8D_SEQUEN","V8D_INDREM","V8D_CNPJOP", "V8D_REGANS", "V8D_SEQIRC" }
                KingLitle( oModelV8D, "MODEL_V8D", oModel, aCampos, nV8D, "V8D", @lOk, @aGravaV8D )
            
                For nV8F := 1 To oModel:Getmodel("MODEL_V8F"):Length()

                    aCampos := { "V8F_SEQUEN","V8F_CPFDEP", "V8F_SEQIRC" }
                    KingLitle( oModelV8F, "MODEL_V8F", oModel, aCampos, nV8F, "V8F", @lOk, @aGravaV8F )
                                                                                    
                    For nV8G := 1 To oModel:Getmodel("MODEL_V8G"):Length()

                        aCampos := { "V8G_SEQUEN","V8G_CPFDEP", "V8G_TPINSC", "V8G_NRINSC", "V8G_VLREMB", "V8G_VLRANT", "V8G_SEQIRC"}
                        KingLitle( oModelV8G, "MODEL_V8G", oModel, aCampos, nV8G, "V8G", @lOk, @aGravaV8G)
                        
                    Next
                Next

                For nV8E := 1 To oModel:Getmodel("MODEL_V8E"):Length()

                    aCampos := { "V8E_SEQUEN","V8E_TPINSC", "V8E_NRINSC", "V8E_VLREMB", "V8E_VLRANT", "V8E_SEQIRC"}
                    KingLitle( oModelV8E, "MODEL_V8E", oModel, aCampos, nV8E, "V8E", @lOk, @aGravaV8E)
                    
                Next
            Next 
        EndIf 
    Next

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} KingLitle

Pega os valores gravados nos grid's

@author Alexande Lima
@since 08/08/2024
@version 1.0

@param oModel407, objeto, Objeto com o modelo de dados da linha
@param cModel,    caracter, Apelido do model da tabela
@param oModel,    objeto, Objeto com o modelo de dados
@param aCampos,   array, Valores a serem gravados
@param n407,      numerico, Linha a qual será atribuida o valor.
@param cTable,    caracter, Tabela referencia no evento.

/*/
//--------------------------------------------------------------------
Function KingLitle( oModel407 as object, cModel as character, oModel as object, aCampos as array, n407 as numeric , cTable as character, lOk as logical, aGravaTab as array)

    Local  nCount       as numeric
    Local  aGrava407    as Array

    nCount      := 0 
    aGrava407   := {}
    
    Default oModel407 := Nil
    Default cModel    := ""
    Default n407      := 1
    Default cTable    := ""
    Default aGravaTab := {}
    Default lOk       := .F.

    oModel:GetModel(cModel):GoLine(n407)
    
    lOk := .F.
    If !oModel:GetModel(cModel):IsEmpty()
        If !oModel:GetModel(cModel):IsDeleted()
            For nCount := 1 To Len(aCampos)
                AAdd(aGrava407, IIf(cTable $ aCampos[nCount] ,oModel407:GetValue(aCampos[nCount] ), aCampos[nCount] ))
            Next
        EndIf 
    EndIf 

    If !Empty(aGrava407)
        aAdd( aGravaTab, aGrava407)
        lOk := .T.
    EndIf
Return 

//--------------------------------------------------------------------
/*/{Protheus.doc} LoadAgrava

Procura numero do recibo a partir do valor na tag

@author Alexande Rosa
@since 08/08/2024
@version 1.0

@param oModel, caracter, Objeto com o modelo de dados
@param cModel, caracter, Apelido do model da tabela
@param aCampos, caracter, Campos para gravar a informação
@param aLoad, caracter, Valores a serem gravados
@param nAdd, caracter, Linha a qual será atribuida o valor.

/*/
//--------------------------------------------------------------------

Function LoadAgrava(oModel as object, cModel as character, aCampos as array, aLoad as array, nAdd as numeric)

    Local nCount as numeric

    nCount := 0
    oModel:GetModel(cModel):lValid := .T.

    If nAdd > 1
        oModel:GetModel(cModel):AddLine()
    EndIf

    For nCount := 1 to Len(aLoad)
        oModel:LoadValue(cModel, aCampos[nCount] , aLoad[nCount])
    Next 

Return 

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFRecArray

Procura numero do recibo a partir do valor na tag

@author Alexande lima
@since 08/08/2024
@version 1.0

@param oModel, Object, Objeto com o modelo a sergravado.

/*/
//--------------------------------------------------------------------
Function TAFRecArray( oModel as object, aGravaT8E as array, aGravaV7T as array, aGravaV7U as array, aGravaV7V as array, aGravaV7W as array, aGravaV7X as array,aGravaV7Y as array,;
                                        aGravaV7Z as array, aGravaV8A as array, aGravaV8B as array, aGravaV8C as array, aGravaV8D as array, aGravaV8F as array, aGravaV8G as array, aGravaV8E as array, aGravaV7S as array )

    Local nT8EAdd as numeric
    Local nV7SAdd as numeric
    Local nV7VAdd as numeric
    Local nV7UAdd as numeric
    Local nV7WAdd as numeric
    Local nV7XAdd as numeric
    Local nV7YAdd as numeric
    Local nV7ZAdd as numeric
    Local nV8AAdd as numeric
    Local nV8CAdd as numeric
    Local nV8DAdd as numeric
    Local nV8EAdd as numeric
    Local nV8FAdd as numeric
    Local nV8GAdd as numeric
    Local nT8E as numeric
    Local nV7T as numeric
    Local nV7U as numeric
    Local nV7V as numeric
    Local nV7W as numeric
    Local nV7X as numeric
    Local nV7Y as numeric
    Local nV7Z as numeric
    Local nV8A as numeric
    Local nV8B as numeric
    Local nV8C as numeric
    Local nV8D as numeric
    Local nV8F as numeric
    Local nV8G as numeric
    Local nV8E as numeric
    Local nV7S as numeric
    Local aCampos   as array
    
    Default aGravaV7S := {}
    Default aGravaV7T := {}
    Default aGravaV7U := {}
    Default aGravaV7V := {}
    Default aGravaV7W := {}
    Default aGravaV7X := {}
    Default aGravaV7Y := {}
    Default aGravaV7Z := {}
    Default aGravaV8A := {}
    Default aGravaV8B := {}
    Default aGravaV8C := {}
    Default aGravaV8D := {}
    Default aGravaV8F := {}
    Default aGravaV8G := {}
    Default aGravaV8E := {}
    Default aGravaT8E := {}

    nT8E := 0
    nV7T := 0
    nV7U := 0
    nV7V := 0
    nV7W := 0
    nV7X := 0
    nV7Y := 0
    nV7Z := 0
    nV8A := 0
    nV8B := 0
    nV8C := 0
    nV8D := 0
    nV8F := 0
    nV8G := 0
    nV8E := 0
    nV7S = 0

    aCampos   := {}

    nT8EAdd := 1
  
    For nT8E := 1 To Len(aGravaT8E)

        aCampos := { "T8E_PERREF","T8E_NRREC","T8E_SEQIRC", "T8E_DTLAUD" }
        LoadAgrava( @oModel, "MODEL_T8E", aCampos, aGravaT8E[nT8E], nT8EAdd )
       
        nV7SAdd := 1

        For nV7S := 1 To Len(aGravaV7S)
            
            If aGravaT8E[nT8E][3] == aGravaV7S[nV7S][7] // VAI SER POSIÇÃO 4

                aCampos := { "V7S_CPFDEP","V7S_DTNASC","V7S_NMDEP","V7S_DPIRRF", "V7S_TPDEP", "V7S_DSCDEP", "V7S_SEQIRC" }
                LoadAgrava( @oModel, "MODEL_V7S", aCampos, aGravaV7S[nV7S], nV7SAdd )
                nV7SAdd++
            EndIf
            
        Next 

        nV7TAdd := 1

        For nV7T := 1 To Len(aGravaV7T)
        
            If aGravaT8E[nT8E][3] == aGravaV7T[nV7T][2]

                aCampos := { "V7T_TPCR", "V7T_SEQIRC"} //alterado
                LoadAgrava( @oModel, "MODEL_V7T", aCampos, aGravaV7T[nV7T], nV7TAdd )

                nV7UAdd := 1

                For nV7U := 1 To Len(aGravaV7U)

                    If aGravaV7T[nV7T][1] + aGravaV7T[nV7T][2] == aGravaV7U[nV7U][1] + aGravaV7U[nV7U][5]
        
                        aCampos := { "V7U_TPCR","V7U_TPREND","V7U_CPFDEP","V7U_VLRDED", "V7U_SEQIRC" } //alterado
                        LoadAgrava( @oModel, "MODEL_V7U", aCampos, aGravaV7U[nV7U], nV7UAdd )

                        nV7UAdd++

                    EndIf 
                Next

                nV7VAdd := 1

                For nV7V := 1 To Len(aGravaV7V)
                    
                    If aGravaV7T[nV7T][1] + aGravaV7T[nV7T][2] == aGravaV7V[nV7V][1] + aGravaV7V[nV7V][5]

                        aCampos := { "V7V_TPCR","V7V_TPREND","V7V_CPFDEP","V7V_VLPEN", "V7V_SEQIRC" }
                        LoadAgrava( @oModel, "MODEL_V7V", aCampos, aGravaV7V[nV7V], nV7VAdd )

                        nV7VAdd++
                    EndIf 

                Next

                nV7WAdd := 1

                For nV7W := 1 To Len(aGravaV7W)

                    If aGravaV7T[nV7T][1] + aGravaV7T[nV7T][2] == aGravaV7W[nV7W][1] + aGravaV7W[nV7W][8]

                        aCampos := { "V7W_TPCR","V7W_TPREV","V7W_INSCPL","V7W_VLCOMP", "V7W_VLPATR", "V7W_VLDEP1", "V7W_VLPA13", "V7W_SEQIRC" }
                        LoadAgrava( @oModel, "MODEL_V7W", aCampos, aGravaV7W[nV7W], nV7WAdd )

                        nV7WAdd++
                    EndIf 

                Next

                nV7XAdd := 1

                For nV7X := 1 To Len(aGravaV7X)

                    If aGravaV7T[nV7T][1] + aGravaV7T[nV7T][2] == aGravaV7X[nV7X][1] + aGravaV7X[nV7X][5]

                        aCampos := { "V7X_TPCR","V7X_TPPROC","V7X_NRPROC","V7X_CODSUP", "V7X_SEQIRC" }
                        LoadAgrava( @oModel, "MODEL_V7X", aCampos, aGravaV7X[nV7X], nV7XAdd )

                        nV7YAdd := 1

                        For nV7Y := 1 To Len(aGravaV7Y)

                            If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4] + aGravaV7T[nV7T][2] == aGravaV7Y[nV7Y][1]+aGravaV7Y[nV7Y][2]+aGravaV7Y[nV7Y][3]+aGravaV7Y[nV7Y][4]+aGravaV7Y[nV7Y][11] 

                                aCampos := {"V7Y_TPCR", "V7Y_TPPROC", "V7Y_NRPROC", "V7Y_CODSUP", "V7Y_INDAPU",;
                                            "V7Y_VLRRET", "V7Y_VLRJUD", "V7Y_VLACAL", "V7Y_VLAANT", "V7Y_VLSUSP", "V7Y_SEQIRC" }
                                LoadAgrava( @oModel, "MODEL_V7Y", aCampos, aGravaV7Y[nV7Y], nV7YAdd )

                                nV7ZAdd := 1

                                For nV7Z := 1 To Len(aGravaV7Z)

                                    If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5]+aGravaV7T[nV7T][2] == aGravaV7Z[nV7Z][1]+aGravaV7Z[nV7Z][2]+aGravaV7Z[nV7Z][3]+aGravaV7Z[nV7Z][4]+aGravaV7Z[nV7Z][5]+aGravaV7Z[nV7Z][11]

                                        aCampos := {"V7Z_TPCR", "V7Z_TPPROC", "V7Z_NRPROC", "V7Z_CODSUP", "V7Z_INDAPU",;
                                                    "V7Z_TPDEDU", "V7Z_VLSUSP", "V7Z_INSCPL", "V7Z_VLFUNP", "V7Z_SEQUEN", "V7Z_SEQIRC" }
                                        LoadAgrava( @oModel, "MODEL_V7Z", aCampos, aGravaV7Z[nV7Z], nV7ZAdd )

                                        nV8AAdd := 1

                                        For nV8A := 1 To Len(aGravaV8A)
                                            
                                            If aGravaV7T[nV7T][1]+aGravaV7X[nV7X][2]+aGravaV7X[nV7X][3]+aGravaV7X[nV7X][4]+aGravaV7Y[nV7Y][5]+aGravaV7Z[nV7Z][10]+aGravaV7T[nV7T][2] == aGravaV8A[nV8A][1]+aGravaV8A[nV8A][2]+aGravaV8A[nV8A][3]+aGravaV8A[nV8A][4]+aGravaV8A[nV8A][5]+aGravaV8A[nV8A][8]+aGravaV8A[nV8A][9]
                                                
                                                aCampos := { "V8A_TPCR", "V8A_TPPROC", "V8A_NRPROC", "V8A_CODSUP", "V8A_INDAPU",;
                                                            "V8A_CPFDEP", "V8A_VLSUSP", "V8A_SEQUEN", "V8A_SEQIRC" }
                                                LoadAgrava( @oModel, "MODEL_V8A", aCampos, aGravaV8A[nV8A], nV8AAdd )

                                                nV8AAdd++

                                            EndIf 

                                        Next 

                                        nV7ZAdd++

                                    EndIf

                                Next 

                                nV7YAdd++

                            EndIf

                        Next

                        nV7XAdd++

                    EndIf 

                Next

                nV7TAdd++
            EndIf
        Next 

        nV8BAdd := 1

        If TAFColumnPos("V8B_SEQUEN")
            aCamposV8B := { "V8B_CNPJOP", "V8B_REGANS", "V8B_VLRTIT", "V8B_SEQIRC", "V8B_SEQUEN" }
            aCamposV8C := { "V8C_CNPJOP", "V8C_CPFDEP", "V8C_VLRDEP", "V8C_SEQIRC", "V8C_SEQUEN" }
        Else
            aCamposV8B := { "V8B_CNPJOP", "V8B_REGANS", "V8B_VLRTIT", "V8B_SEQIRC" }
            aCamposV8C := { "V8C_CNPJOP", "V8C_CPFDEP", "V8C_VLRDEP", "V8C_SEQIRC" }
        EndIf

        For nV8B := 1 To Len(aGravaV8B)
            If aGravaV8B[nV8B][4] == aGravaT8E[nT8E][3]
                LoadAgrava( @oModel, "MODEL_V8B", aCamposV8B, aGravaV8B[nV8B], nV8BAdd )
                nV8CAdd := 1

                For nV8C := 1 To Len(aGravaV8C)

                    If TAFColumnPos("V8B_SEQUEN")
                        If aGravaV8B[nV8B][1] + aGravaV8B[nV8B][4] + aGravaV8B[nV8B][5]  == aGravaV8C[nV8C][1] + aGravaV8C[nV8C][4] + aGravaV8C[nV8C][5]
                            LoadAgrava( @oModel, "MODEL_V8C", aCamposV8C, aGravaV8C[nV8C], nV8CAdd )
                            nV8CAdd++
                        EndIf
                    Else
                        If aGravaV8B[nV8B][1] + aGravaV8B[nV8B][4] == aGravaV8C[nV8C][1] + aGravaV8C[nV8C][4]
                            LoadAgrava( @oModel, "MODEL_V8C", aCamposV8C, aGravaV8C[nV8C], nV8CAdd )
                            nV8CAdd++
                        EndIf
                    EndIf 
                Next 
                nV8BAdd++
            EndIf
        Next 

        nV8DAdd := 1

        For nV8D := 1 To Len(aGravaV8D)
            
            If aGravaV8D[nV8D][5] == aGravaT8E[nT8E][3]

                aCampos := { "V8D_SEQUEN", "V8D_INDREM", "V8D_CNPJOP", "V8D_REGANS", "V8D_SEQIRC" }
                LoadAgrava( @oModel, "MODEL_V8D", aCampos, aGravaV8D[nV8D], nV8DAdd )

                nV8EAdd := 1

                For nV8E := 1 To Len(aGravaV8E)

                    If aGravaV8D[nV8D][1] + aGravaV8D[nV8D][5] == aGravaV8E[nV8E][1] + aGravaV8E[nV8E][6]

                        aCampos := { "V8E_SEQUEN", "V8E_TPINSC", "V8E_NRINSC", "V8E_VLREMB", "V8E_VLRANT", "V8E_SEQIRC" }
                        LoadAgrava( @oModel, "MODEL_V8E", aCampos, aGravaV8E[nV8E], nV8EAdd )
                        
                        nV8EAdd++

                    EndIf 

                Next

                nV8FAdd := 1
                For nV8F := 1 To Len(aGravaV8F)

                    If aGravaV8D[nV8D][1] + aGravaV8D[nV8D][5] == aGravaV8F[nV8F][1] + aGravaV8F[nV8F][3]

                        aCampos := { "V8F_SEQUEN", "V8F_CPFDEP", "V8F_SEQIRC" }
                        LoadAgrava( @oModel, "MODEL_V8F", aCampos, aGravaV8F[nV8F], nV8FAdd )

                        nV8GAdd := 1
                        For nV8G := 1 To Len(aGravaV8G)

                            If aGravaV8F[nV8F][1] + aGravaV8F[nV8F][2] + aGravaV8F[nV8F][3] == aGravaV8G[nV8G][1] + aGravaV8G[nV8G][2] + aGravaV8G[nV8G][7]

                                aCampos := { "V8G_SEQUEN", "V8G_CPFDEP", "V8G_TPINSC", "V8G_NRINSC", "V8G_VLREMB", "V8G_VLRANT", "V8G_SEQIRC" }
                                LoadAgrava( @oModel, "MODEL_V8G", aCampos, aGravaV8G[nV8G], nV8GAdd )
                            
                                nV8GAdd++

                            EndIf 

                        Next

                        nV8FAdd++

                    EndIf

                Next
            EndIf

            nV8DAdd++

        Next

        nT8EAdd++

    Next

Return oModel
                                                                           
//-------------------------------------------------------------------
/*/{Protheus.doc} Exc407
Função apenas para validar permisão de acesso
@author  Alexandre de Lima Santos
@since   28/01/2025
@version 1
/*/
//-------------------------------------------------------------------
Function Exc407( )

Return( Nil )                                                                           

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFview01
Função para montar view com formulario continno
@author  Alexandre de Lima Santos
oStruT8E as object - objeto de representação do modelo e tabela 
oStruV7S as object - objeto de representação do modelo e tabela. 
oStruV7T as object - objeto de representação do modelo e tabela. 
oStruV7U as object - objeto de representação do modelo e tabela. 
oStruV7V as object - objeto de representação do modelo e tabela. 
oStruV7W as object - objeto de representação do modelo e tabela. 
oStruV7X as object - objeto de representação do modelo e tabela. 
oStruV7Y as object - objeto de representação do modelo e tabela.
oStruV7Z as object - objeto de representação do modelo e tabela. 
oStruV8A as object - objeto de representação do modelo e tabela. 
oStruV8B as object - objeto de representação do modelo e tabela. 
oStruV8C as object - objeto de representação do modelo e tabela. 
oStruV8D as object - objeto de representação do modelo e tabela. 
oStruV8E as object - objeto de representação do modelo e tabela. 
oStruV8F as object - objeto de representação do modelo e tabela. 
oStruV8G as object - objeto de representação do modelo e tabela.
cCmpFil  as character - campos de estrutura caso necessario
@author  Alexandre de Lima Santos
@since   28/02/2025
@version 1
/*/
//-------------------------------------------------------------------
Function TAFview01(oStruT8E as object, oStruV7S as object, oStruV7T, oStruV7U as object, oStruV7V as object, oStruV7W as object, oStruV7X as object, oStruV7Y as object,;
                   oStruV7Z as object, oStruV8A as object, oStruV8B as object, oStruV8C as object, oStruV8D as object, oStruV8E as object, oStruV8F as object, oStruV8G as object,;
                   oView as object, cCmpFil as character)

    Default oStruT8E := Nil
    Default oStruV7S := Nil
    Default oStruV7T := Nil
    Default oStruV7U := Nil
    Default oStruV7V := Nil
    Default oStruV7W := Nil
    Default oStruV7X := Nil
    Default oStruV7Y := Nil
    Default oStruV7Z := Nil
    Default oStruV8A := Nil
    Default oStruV8B := Nil
    Default oStruV8C := Nil
    Default oStruV8D := Nil
    Default oStruV8E := Nil 
    Default oStruV8F := Nil
    Default oStruV8G := Nil 
    Default oView    := Nil
    Default CmpFil   := ""

    oStruT8E := FwFormStruct( 2, "T8E",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
    oStruT8E:SetProperty( "T8E_SEQIRC" , MVC_VIEW_ORDEM, "01" )
    oStruT8E:SetProperty( "T8E_PERREF" , MVC_VIEW_ORDEM, "02" )
    oStruT8E:SetProperty( "T8E_NRREC"  , MVC_VIEW_ORDEM, "03" )

    If "T8E_DTLAUD" $ cCmpFil
        oStruT8E:SetProperty( "T8E_DTLAUD" , MVC_VIEW_ORDEM, "04" )
    EndIf

    oStruT8E:SetProperty( "T8E_SEQIRC" , MVC_VIEW_CANCHANGE, .T. )
    
    oStruV7S := FWFormStruct(2, "V7S") 
    cCmpFil  := "V7S_CPFDEP|V7S_DTNASC|V7S_NMDEP|V7S_DPIRRF|V7S_TPDEP|V7S_DTPDE|V7S_DSCDEP|"
    oStruV7S := FwFormStruct( 2, "V7S",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7T := FWFormStruct(2, "V7T") 
    cCmpFil  := "V7T_TPCR|V7T_DTPCR|"
    oStruV7T := FwFormStruct( 2, "V7T",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7U := FWFormStruct(2, "V7U")
    oStruV7U:RemoveField('V7U_TPCR')
    cCmpFil  := "V7U_TPREND|V7U_CPFDEP|V7U_VLRDED|"
    oStruV7U := FwFormStruct( 2, "V7U",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7V := FWFormStruct(2, "V7V")
    oStruV7V:RemoveField('V7V_TPCR')
    cCmpFil  := "V7V_TPREND|V7V_CPFDEP|V7V_VLPEN|"
    oStruV7V := FwFormStruct( 2, "V7V",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
    
    oStruV7W := FWFormStruct(2, "V7W")
    oStruV7W:RemoveField('V7W_TPCR')
    cCmpFil  := "V7W_TPREV|V7W_INSCPL|V7W_VLCOMP|V7W_VLPATR|V7W_VLDEP1|V7W_VLPA13|"
    oStruV7W := FwFormStruct( 2, "V7W",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7X := FWFormStruct(2, "V7X")
    oStruV7X:RemoveField('V7X_TPCR')
    cCmpFil  := "V7X_TPPROC|V7X_NRPROC|V7X_CODSUP|"
    oStruV7X := FwFormStruct( 2, "V7X",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7Y := FWFormStruct(2, "V7Y")
    oStruV7Y:RemoveField('V7Y_TPCR')
    oStruV7Y:RemoveField('V7Y_TPPROC')
    oStruV7Y:RemoveField('V7Y_NRPROC')
    oStruV7Y:RemoveField('V7Y_CODSUP')
    cCmpFil  := "V7Y_INDAPU|V7Y_VLRRET|V7Y_VLRJUD|V7Y_VLACAL|V7Y_VLAANT|V7Y_VLSUSP|"
    oStruV7Y := FwFormStruct( 2, "V7Y",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7Z := FWFormStruct(2, "V7Z")
    oStruV7Z:RemoveField('V7Z_FILIAL')
    oStruV7Z:RemoveField('V7Z_TPCR')
    oStruV7Z:RemoveField('V7Z_TPPROC')
    oStruV7Z:RemoveField('V7Z_NRPROC')
    oStruV7Z:RemoveField('V7Z_CODSUP')
    oStruV7Z:RemoveField('V7Z_INDAPU')

    cCmpFil  := "V7Z_TPDEDU|V7Z_VLSUSP|V7Z_INSCPL|V7Z_VLFUNP|V7Z_SEQUEN|"
    oStruV7Z := FwFormStruct( 2, "V7Z",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8A := FWFormStruct(2, "V8A")
    oStruV8A:RemoveField('V8A_TPCR')
    oStruV8A:RemoveField('V8A_TPPROC')
    oStruV8A:RemoveField('V8A_NRPROC')
    oStruV8A:RemoveField('V8A_CODSUP')
    oStruV8A:RemoveField('V8A_INDAPU')
    oStruV8A:RemoveField('V8A_TPDEDU')

    cCmpFil  := "V8A_CPFDEP|V8A_VLSUSP|"
    oStruV8A := FwFormStruct( 2, "V8A",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8B := FWFormStruct(2, "V8B") 
    cCmpFil  := "V8B_CNPJOP|V8B_REGANS|V8B_VLRTIT|"
    If TafColumnPos("V8B_SEQUEN")
        oStruV8B:SetProperty("V8B_SEQUEN",MVC_VIEW_CANCHANGE,.T.)
        cCmpFil  += "V8B_SEQUEN|"
    EndIf
    oStruV8B := FwFormStruct( 2, "V8B",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8C := FWFormStruct(2, "V8C")
    oStruV8C:RemoveField('V8C_CNPJOP')
    cCmpFil  := "V8C_CPFDEP|V8C_VLRDEP|"
    oStruV8C := FwFormStruct( 2, "V8C",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8D := FWFormStruct(2, "V8D") 
    cCmpFil  := "V8D_INDREM|V8D_CNPJOP|V8D_REGANS|V8D_SEQUEN|"
    oStruV8D := FwFormStruct( 2, "V8D",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8E := FWFormStruct(2, "V8E")
    cCmpFil  := "V8E_TPINSC|V8E_NRINSC|V8E_VLREMB|V8E_VLRANT|"
    oStruV8E := FwFormStruct( 2, "V8E",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8F := FWFormStruct(2, "V8F")
    oStruV8F:SetProperty("V8F_SEQUEN",MVC_VIEW_CANCHANGE,.F.)
    oStruV8F:RemoveField('V8F_TPINSC')
    oStruV8F:RemoveField('V8F_NRINSC')

    cCmpFil  := "V8F_CPFDEP|"
    oStruV8F := FwFormStruct( 2, "V8F",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8G := FWFormStruct(2, "V8G")
    oStruV8G:RemoveField('V8G_CPFDEP')
    cCmpFil  := "V8G_TPINSC|V8G_NRINSC|V8G_VLREMB|V8G_VLRANT|"
    oStruV8G := FwFormStruct( 2, "V8G",{ |x| AllTrim( x ) + "|" $ cCmpFil } )


    oView:CreateHorizontalBox("PAINEL_PERANT",20,,,"FOLDER_SUPERIOR","ABA02")
    oView:AddGrid( "VIEW_T8E", oStruT8E, "MODEL_T8E" )
    oView:EnableTitleView("VIEW_T8E", "Informações complementares de períodos anteriores") 
    oView:SetOwnerView( "VIEW_T8E", "PAINEL_PERANT"  )

    oView:CreateHorizontalBox("PAINEL_INFOIRCOMPLEM",80,,,"FOLDER_SUPERIOR","ABA02")
    oView:CreateFolder( 'FOLDER_INFOIRCOMPLEM', 'PAINEL_INFOIRCOMPLEM' )

    oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA01', STR0042) //"Info. dependentes não cadastrados"
    oView:AddGrid( "VIEW_V7S", oStruV7S, "MODEL_V7S" )
    oView:CreateHorizontalBox( 'V7S', 100,,, 'FOLDER_INFOIRCOMPLEM', 'ABA01' )
    oView:SetOwnerView( "VIEW_V7S", "V7S"  )

    oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA02', STR0044) //"Info. Irrf - Código de Receita"
    oView:AddGrid( "VIEW_V7T", oStruV7T, "MODEL_V7T" )
    oView:CreateHorizontalBox( 'V7T',040,,, 'FOLDER_INFOIRCOMPLEM', 'ABA02' )
    oView:SetOwnerView( "VIEW_V7T", "V7T"  )

    oView:CreateHorizontalBox("PAINEL_INFOIRCR",060,,,"FOLDER_INFOIRCOMPLEM","ABA02")
    oView:CreateFolder( 'FOLDER_INFOIRCR', 'PAINEL_INFOIRCR' )

    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA01', STR0046 ) //"Dedução de IRRF"		
    oView:CreateHorizontalBox( 'V7U', 100,,, 'FOLDER_INFOIRCR', 'ABA01' )
    oView:AddGrid( "VIEW_V7U", oStruV7U, "MODEL_V7U" )
    oView:EnableTitleView("VIEW_V7U",STR0047 ) //"Dedução do rendimento tributável relativa a dependentes"
    oView:SetOwnerView( "VIEW_V7U", "V7U"  )

    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA02', STR0048) //"Info. Pensão Alimentícia"	
    oView:CreateHorizontalBox( 'V7V', 100,,, 'FOLDER_INFOIRCR', 'ABA02' )
    oView:AddGrid( "VIEW_V7V", oStruV7V, "MODEL_V7V" )
    oView:EnableTitleView("VIEW_V7V",STR0049 ) // "Informação dos beneficiários da pensão alimentícia"
    oView:SetOwnerView( "VIEW_V7V", "V7V"  )

    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA03', STR0050 ) //"Info. Previdência Complementar"	
    oView:CreateHorizontalBox( 'V7W', 100,,, 'FOLDER_INFOIRCR', 'ABA03' )
    oView:AddGrid( "VIEW_V7W", oStruV7W, "MODEL_V7W" )
    oView:EnableTitleView("VIEW_V7W", STR0051 ) //"Informações relativas a planos de previdência complementar."
    oView:SetOwnerView( "VIEW_V7W", "V7W"  )

    /* ABA 04 - Informações IRR -> Info. Irrf - Código de Receita -> Info. Proc Judiciais. */     
    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA04', STR0052 ) //"Info. Proc Judiciais."	
    oView:CreateHorizontalBox("PAINEL_INFOPROCJUD",100,,,"FOLDER_INFOIRCR","ABA04")
    oView:CreateFolder( 'FOLDER_INFOPROCJUD', 'PAINEL_INFOPROCJUD' )

    oView:AddSheet( 'FOLDER_INFOPROCJUD', 'ABA01', 'Identificação do Processo' ) //Criar STR
    oView:CreateHorizontalBox( 'V7X', 100,,, 'FOLDER_INFOPROCJUD', 'ABA01' )
    oView:AddGrid( "VIEW_V7X", oStruV7X, "MODEL_V7X" )
    oView:EnableTitleView("VIEW_V7X",STR0053 ) //"Informações de processos relacionados a não retenção de tributos ou a depósitos judiciais."
    oView:SetOwnerView( "VIEW_V7X", "V7X"  )

    oView:AddSheet( 'FOLDER_INFOPROCJUD', 'ABA02', STR0054) //"Info. Valores Proc Judiciais."	
    oView:CreateHorizontalBox( 'V7Y', 100,,, 'FOLDER_INFOPROCJUD', 'ABA02' )
    oView:AddGrid( "VIEW_V7Y", oStruV7Y, "MODEL_V7Y" )
    oView:EnableTitleView("VIEW_V7Y", STR0055 ) //"Informações de valores relacionados a não retenção de tributos ou a depósitos judiciais." 
    oView:SetOwnerView( "VIEW_V7Y", "V7Y"  )

    oView:AddSheet( 'FOLDER_INFOPROCJUD', 'ABA03', STR0056 ) //"Deduções Exigibilidade Suspensa"
    oView:CreateHorizontalBox( 'V7Z', 100,,, 'FOLDER_INFOPROCJUD', 'ABA03' )
    oView:AddGrid( "VIEW_V7Z", oStruV7Z, "MODEL_V7Z" )
    oView:AddIncrementField( "VIEW_V7Z", "V7Z_SEQUEN" )
    oView:EnableTitleView("VIEW_V7Z", STR0057 ) //"Detalhamento das deduções com exigibilidade suspensa."
    oView:SetOwnerView( "VIEW_V7Z", "V7Z"  )

    oView:AddSheet( 'FOLDER_INFOPROCJUD', 'ABA04', STR0058 ) //"Deduções Dependentes/Pensão"	
    oView:CreateHorizontalBox( 'V8A', 100,,, 'FOLDER_INFOPROCJUD', 'ABA04' )
    oView:AddGrid( "VIEW_V8A", oStruV8A, "MODEL_V8A" )
    oView:EnableTitleView("VIEW_V8A",STR0059 ) //"Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia." 
    oView:SetOwnerView( "VIEW_V8A", "V8A"  )

    oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA03', STR0060 ) //"Plano de saúde coletivo."
    oView:AddGrid( "VIEW_V8B", oStruV8B, "MODEL_V8B" )
    oView:EnableTitleView("VIEW_V8B", STR0061)  //"Identificação da(s) operadora(s) de plano privado coletivo empresarial de assistência à saúde."
    oView:CreateHorizontalBox( 'V8B', 050,,, 'FOLDER_INFOIRCOMPLEM', 'ABA03' )
    oView:SetOwnerView( "VIEW_V8B", "V8B"  )
    If TafColumnPos("V8B_SEQUEN")
        oView:AddIncrementField( "VIEW_V8B", "V8B_SEQUEN" )
    EndIf 

    oView:CreateHorizontalBox("PAINEL_INFODEPSAU",050,,,"FOLDER_INFOIRCOMPLEM","ABA03")
    oView:CreateFolder( 'FOLDER_INFODEPSAU', 'PAINEL_INFODEPSAU' )    

    oView:AddSheet( 'FOLDER_INFODEPSAU', 'ABA01', STR0062 ) //"Info. Dependente Plano de Saúde."			
    oView:CreateHorizontalBox( 'V8C', 100,,, 'FOLDER_INFODEPSAU', 'ABA01' )
    oView:AddGrid( "VIEW_V8C", oStruV8C, "MODEL_V8C" )
    oView:EnableTitleView("VIEW_V8C", STR0063) //"Informações de dependente de plano de saúde coletivo empresarial."
    oView:SetOwnerView( "VIEW_V8C", "V8C"  )   
 
    oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA04', STR0064 ) //"Info. Reembolso"
    oView:CreateHorizontalBox( 'V8D', 050,,, 'FOLDER_INFOIRCOMPLEM', 'ABA04' )
    oView:AddGrid( "VIEW_V8D", oStruV8D, "MODEL_V8D" )
    oView:EnableTitleView("VIEW_V8D", STR0065 ) // "Informações Reembolso efetuados pelo empregador."
    oView:SetOwnerView( "VIEW_V8D", "V8D"  )
    oView:AddIncrementField( "VIEW_V8D", "V8D_SEQUEN" )

    oView:CreateHorizontalBox("PAINEL_DETREEMB",050,,,"FOLDER_INFOIRCOMPLEM","ABA04")

    oView:CreateFolder( 'FOLDER_DETREEMB', 'PAINEL_DETREEMB' )

    oView:AddSheet( 'FOLDER_DETREEMB', 'ABA01', STR0066 ) //Info. Reembolso Titular.			
    oView:CreateHorizontalBox( 'V8E', 100,,, 'FOLDER_DETREEMB', 'ABA01' )
    oView:AddGrid( "VIEW_V8E", oStruV8E, "MODEL_V8E" )
    oView:EnableTitleView("VIEW_V8E", STR0067) //"Informação de reembolso do titular do plano de saúde coletivo empresarial."
    oView:SetOwnerView( "VIEW_V8E", "V8E"  )
    oView:AddIncrementField( "VIEW_T8E", "T8E_SEQIRC" )

    oView:AddSheet( 'FOLDER_DETREEMB', 'ABA02', STR0068 ) //"Info. Reembolso Dependente."			
    oView:CreateHorizontalBox( 'PAINEL_DETREEMBDEP', 100,,, 'FOLDER_DETREEMB', 'ABA02' )
    
    oView:CreateFolder( 'FOLDER_DETREEMBDEP', 'PAINEL_DETREEMBDEP' )
    oView:AddSheet( 'FOLDER_DETREEMBDEP', 'ABA01', STR0069 ) //"Informação de reembolso do dependente do plano de saúde coletivo empresarial.

    oView:CreateHorizontalBox( 'V8F', 100,,, 'FOLDER_DETREEMBDEP', 'ABA01' )
    oView:AddGrid( "VIEW_V8F", oStruV8F, "MODEL_V8F" )
    oView:SetOwnerView( "VIEW_V8F", "V8F"  )

    oView:AddSheet( 'FOLDER_DETREEMBDEP', 'ABA02', STR0070 ) //"Info. Reembolso pelo empregador para Dependente."
    oView:CreateHorizontalBox( 'V8G', 100,,, 'FOLDER_DETREEMBDEP', 'ABA02' )
    oView:AddGrid( "VIEW_V8G", oStruV8G, "MODEL_V8G" )
    oView:SetOwnerView( "VIEW_V8G", "V8G"  )

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFview01
Função para montar view sem fromulario continuo
@author  Alexandre de Lima Santos
oStruT8E as object - objeto de representação do modelo e tabela 
oStruV7S as object - objeto de representação do modelo e tabela. 
oStruV7T as object - objeto de representação do modelo e tabela. 
oStruV7U as object - objeto de representação do modelo e tabela. 
oStruV7V as object - objeto de representação do modelo e tabela. 
oStruV7W as object - objeto de representação do modelo e tabela. 
oStruV7X as object - objeto de representação do modelo e tabela. 
oStruV7Y as object - objeto de representação do modelo e tabela.
oStruV7Z as object - objeto de representação do modelo e tabela. 
oStruV8A as object - objeto de representação do modelo e tabela. 
oStruV8B as object - objeto de representação do modelo e tabela. 
oStruV8C as object - objeto de representação do modelo e tabela. 
oStruV8D as object - objeto de representação do modelo e tabela. 
oStruV8E as object - objeto de representação do modelo e tabela. 
oStruV8F as object - objeto de representação do modelo e tabela. 
oStruV8G as object - objeto de representação do modelo e tabela.
cCmpFil  as character - campos de estrutura caso necessario
@since   28/02/2025
@version 1
/*/
//-------------------------------------------------------------------
Function TAFview02(oStruT8E as object, oStruV7S as object, oStruV7T, oStruV7U as object, oStruV7V as object, oStruV7W as object, oStruV7X as object, oStruV7Y as object,;
                   oStruV7Z as object, oStruV8A as object, oStruV8B as object, oStruV8C as object, oStruV8D as object, oStruV8E as object, oStruV8F as object, oStruV8G as object,;
                   oView as object, cCmpFil as character)

    Default oStruT8E := Nil
    Default oStruV7S := Nil
    Default oStruV7T := Nil
    Default oStruV7U := Nil
    Default oStruV7V := Nil
    Default oStruV7W := Nil
    Default oStruV7X := Nil
    Default oStruV7Y := Nil
    Default oStruV7Z := Nil
    Default oStruV8A := Nil
    Default oStruV8B := Nil
    Default oStruV8C := Nil
    Default oStruV8D := Nil
    Default oStruV8E := Nil 
    Default oStruV8F := Nil
    Default oStruV8G := Nil 
    Default oView    := Nil
    Default CmpFil   := ""
    
    oStruT8E := FwFormStruct( 2, "T8E",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7S := FWFormStruct(2, "V7S") 
    cCmpFil  := "V7S_CPFDEP|V7S_DTNASC|V7S_NMDEP|V7S_DPIRRF|V7S_TPDEP|V7S_DTPDE|V7S_DSCDEP|"
    oStruV7S := FwFormStruct( 2, "V7S",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7T := FWFormStruct(2, "V7T") 
    cCmpFil  := "V7T_TPCR|V7T_DTPCR|"
    oStruV7T := FwFormStruct( 2, "V7T",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7U := FWFormStruct(2, "V7U")
    oStruV7U:RemoveField('V7U_TPCR')
    cCmpFil  := "V7U_TPREND|V7U_CPFDEP|V7U_VLRDED|"
    oStruV7U := FwFormStruct( 2, "V7U",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7V := FWFormStruct(2, "V7V")
    oStruV7V:RemoveField('V7V_TPCR')
    cCmpFil  := "V7V_TPREND|V7V_CPFDEP|V7V_VLPEN|"
    oStruV7V := FwFormStruct( 2, "V7V",{ |x| AllTrim( x ) + "|" $ cCmpFil } )
    
    oStruV7W := FWFormStruct(2, "V7W")
    oStruV7W:RemoveField('V7W_TPCR')
    cCmpFil  := "V7W_TPREV|V7W_INSCPL|V7W_VLCOMP|V7W_VLPATR|V7W_VLDEP1|V7W_VLPA13|"
    oStruV7W := FwFormStruct( 2, "V7W",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7X := FWFormStruct(2, "V7X")
    oStruV7X:RemoveField('V7X_TPCR')
    cCmpFil  := "V7X_TPPROC|V7X_NRPROC|V7X_CODSUP|"
    oStruV7X := FwFormStruct( 2, "V7X",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7Y := FWFormStruct(2, "V7Y")
    oStruV7Y:RemoveField('V7Y_TPCR')
    oStruV7Y:RemoveField('V7Y_TPPROC')
    oStruV7Y:RemoveField('V7Y_NRPROC')
    oStruV7Y:RemoveField('V7Y_CODSUP')
    cCmpFil  := "V7Y_INDAPU|V7Y_VLRRET|V7Y_VLRJUD|V7Y_VLACAL|V7Y_VLAANT|V7Y_VLSUSP|"
    oStruV7Y := FwFormStruct( 2, "V7Y",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV7Z := FWFormStruct(2, "V7Z")
    oStruV7Z:RemoveField('V7Z_FILIAL')
    oStruV7Z:RemoveField('V7Z_TPCR')
    oStruV7Z:RemoveField('V7Z_TPPROC')
    oStruV7Z:RemoveField('V7Z_NRPROC')
    oStruV7Z:RemoveField('V7Z_CODSUP')
    oStruV7Z:RemoveField('V7Z_INDAPU')

    cCmpFil  := "V7Z_TPDEDU|V7Z_VLSUSP|V7Z_INSCPL|V7Z_VLFUNP|V7Z_SEQUEN|"
    oStruV7Z := FwFormStruct( 2, "V7Z",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8A := FWFormStruct(2, "V8A")
    oStruV8A:RemoveField('V8A_TPCR')
    oStruV8A:RemoveField('V8A_TPPROC')
    oStruV8A:RemoveField('V8A_NRPROC')
    oStruV8A:RemoveField('V8A_CODSUP')
    oStruV8A:RemoveField('V8A_INDAPU')
    oStruV8A:RemoveField('V8A_TPDEDU')

    cCmpFil  := "V8A_CPFDEP|V8A_VLSUSP|"
    oStruV8A := FwFormStruct( 2, "V8A",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8B := FWFormStruct(2, "V8B") 
    cCmpFil  := "V8B_CNPJOP|V8B_REGANS|V8B_VLRTIT|"
    If TafColumnPos("V8B_SEQUEN")
        oStruV8B:SetProperty("V8B_SEQUEN",MVC_VIEW_CANCHANGE,.T.)
        cCmpFil += "V8B_SEQUEN|"
    EndIf
    oStruV8B := FwFormStruct( 2, "V8B",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8C := FWFormStruct(2, "V8C")
    oStruV8C:RemoveField('V8C_CNPJOP')
    cCmpFil  := "V8C_CPFDEP|V8C_VLRDEP|"
    oStruV8C := FwFormStruct( 2, "V8C",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8D := FWFormStruct(2, "V8D") 
    cCmpFil  := "V8D_INDREM|V8D_CNPJOP|V8D_REGANS|V8D_SEQUEN|"
    oStruV8D := FwFormStruct( 2, "V8D",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8E := FWFormStruct(2, "V8E")
    cCmpFil  := "V8E_TPINSC|V8E_NRINSC|V8E_VLREMB|V8E_VLRANT|"
    oStruV8E := FwFormStruct( 2, "V8E",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8F := FWFormStruct(2, "V8F")
    oStruV8F:SetProperty("V8F_SEQUEN",MVC_VIEW_CANCHANGE,.F.)
    oStruV8F:RemoveField('V8F_TPINSC')
    oStruV8F:RemoveField('V8F_NRINSC')

    cCmpFil  := "V8F_CPFDEP|"
    oStruV8F := FwFormStruct( 2, "V8F",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oStruV8G := FWFormStruct(2, "V8G")
    oStruV8G:RemoveField('V8G_CPFDEP')
    cCmpFil  := "V8G_TPINSC|V8G_NRINSC|V8G_VLREMB|V8G_VLRANT|"
    oStruV8G := FwFormStruct( 2, "V8G",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

    oView:CreateHorizontalBox("PAINEL_INFOIRCOMPLEM",025,,,"FOLDER_SUPERIOR","ABA02")
    oView:CreateFolder( 'FOLDER_INFOIRCOMPLEM', 'PAINEL_INFOIRCOMPLEM' )

    oView:AddSheet( 'FOLDER_INFOIRCOMPLEM', 'ABA01', "Informações complementares de períodos anteriores") //"Info. dependentes não cadastrados"
    oView:AddGrid( "VIEW_T8E", oStruT8E, "MODEL_T8E" )
    oView:EnableTitleView("VIEW_T8E", "Informações complementares de períodos anteriores")  
    oView:CreateHorizontalBox( 'T8E', 050,,, 'FOLDER_INFOIRCOMPLEM', 'ABA01' )
    oView:AddIncrementField( "VIEW_T8E", "T8E_SEQIRC" )
    oView:SetOwnerView( "VIEW_T8E", "T8E"  )

    oView:CreateHorizontalBox("PAINEL_INFOPERANT",050,,,"FOLDER_INFOIRCOMPLEM","ABA01")
    oView:CreateFolder( 'FOLDER_INFOPERANT', 'PAINEL_INFOPERANT' )

    oView:AddSheet( 'FOLDER_INFOPERANT', 'ABA01', STR0042) //"Info. dependentes não cadastrados"
    oView:AddGrid( "VIEW_V7S", oStruV7S, "MODEL_V7S" )
    oView:EnableTitleView("VIEW_V7S", STR0043)  //"Informações de dependentes não cadastrados pelo S-2200/S-2205/S-2300/S-2400/S-2405"
    oView:CreateHorizontalBox( 'V7S', 050,,, 'FOLDER_INFOPERANT', 'ABA01' )
    oView:SetOwnerView( "VIEW_V7S", "V7S"  )

    oView:AddSheet( 'FOLDER_INFOPERANT', 'ABA02', STR0044) //"Info. Irrf - Código de Receita"
    oView:AddGrid( "VIEW_V7T", oStruV7T, "MODEL_V7T" )
    oView:EnableTitleView("VIEW_V7T", STR0045)  //"Informações IRRF, por Código de Receita - CR"
    oView:CreateHorizontalBox( 'V7T',050,,, 'FOLDER_INFOPERANT', 'ABA02' )
    oView:SetOwnerView( "VIEW_V7T", "V7T"  )

    oView:CreateHorizontalBox("PAINEL_INFOIRCR",025,,,"FOLDER_INFOPERANT","ABA02")
    oView:CreateFolder( 'FOLDER_INFOIRCR', 'PAINEL_INFOIRCR' )

    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA01', STR0046 ) //"Dedução de IRRF"		
    oView:CreateHorizontalBox( 'V7U', 025,,, 'FOLDER_INFOIRCR', 'ABA01' )
    oView:AddGrid( "VIEW_V7U", oStruV7U, "MODEL_V7U" )
    oView:EnableTitleView("VIEW_V7U",STR0047 ) //"Dedução do rendimento tributável relativa a dependentes"
    oView:SetOwnerView( "VIEW_V7U", "V7U"  )

    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA02', STR0048) //"Info. Pensão Alimentícia"	
    oView:CreateHorizontalBox( 'V7V', 025,,, 'FOLDER_INFOIRCR', 'ABA02' )
    oView:AddGrid( "VIEW_V7V", oStruV7V, "MODEL_V7V" )
    oView:EnableTitleView("VIEW_V7V",STR0049 ) // "Informação dos beneficiários da pensão alimentícia"
    oView:SetOwnerView( "VIEW_V7V", "V7V"  )

    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA03', STR0050 ) //"Info. Previdência Complementar"	
    oView:CreateHorizontalBox( 'V7W', 025,,, 'FOLDER_INFOIRCR', 'ABA03' )
    oView:AddGrid( "VIEW_V7W", oStruV7W, "MODEL_V7W" )
    oView:EnableTitleView("VIEW_V7W", STR0051 ) //"Informações relativas a planos de previdência complementar."
    oView:SetOwnerView( "VIEW_V7W", "V7W"  )

    oView:AddSheet( 'FOLDER_INFOIRCR', 'ABA04', STR0052 ) //"Info. Proc Judiciais."	
    oView:CreateHorizontalBox( 'V7X', 025,,, 'FOLDER_INFOIRCR', 'ABA04' )
    oView:AddGrid( "VIEW_V7X", oStruV7X, "MODEL_V7X" )
    oView:EnableTitleView("VIEW_V7X",STR0053 ) //"Informações de processos relacionados a não retenção de tributos ou a depósitos judiciais."
    oView:SetOwnerView( "VIEW_V7X", "V7X"  )

    oView:CreateHorizontalBox("PAINEL_INFOPROCRET",025,,,"FOLDER_INFOIRCR","ABA04")
    oView:CreateFolder( 'FOLDER_INFOPROCRET', 'PAINEL_INFOPROCRET' )

    oView:AddSheet( 'FOLDER_INFOPROCRET', 'ABA01', STR0054) //"Info. Valores Proc Judiciais."	
    oView:CreateHorizontalBox( 'V7Y', 025,,, 'FOLDER_INFOPROCRET', 'ABA01' )
    oView:AddGrid( "VIEW_V7Y", oStruV7Y, "MODEL_V7Y" )
    oView:EnableTitleView("VIEW_V7Y", STR0055 ) //"Informações de valores relacionados a não retenção de tributos ou a depósitos judiciais." 
    oView:SetOwnerView( "VIEW_V7Y", "V7Y"  )

    oView:CreateHorizontalBox("PAINEL_DEDSUSP",050,,,"FOLDER_INFOPROCRET","ABA01")
    oView:CreateFolder( 'FOLDER_DEDSUSP', 'PAINEL_DEDSUSP' )

    oView:AddSheet( 'FOLDER_DEDSUSP', 'ABA01', STR0056 ) //"Deduções Exigibilidade Suspensa"
    oView:CreateHorizontalBox( 'V7Z', 025,,, 'FOLDER_DEDSUSP', 'ABA01' )
    oView:AddGrid( "VIEW_V7Z", oStruV7Z, "MODEL_V7Z" )
    oView:AddIncrementField( "VIEW_V7Z", "V7Z_SEQUEN" )
    oView:EnableTitleView("VIEW_V7Z", STR0057 ) //"Detalhamento das deduções com exigibilidade suspensa."
    oView:SetOwnerView( "VIEW_V7Z", "V7Z"  )
    

    oView:CreateHorizontalBox("PAINEL_BENEFPEN",050,,,"FOLDER_DEDSUSP","ABA01")
    oView:CreateFolder( 'FOLDER_BENEFPEN', 'PAINEL_BENEFPEN' )

    oView:AddSheet( 'FOLDER_BENEFPEN', 'ABA01', STR0058 ) //"Deduções Dependentes/Pensão"	
    oView:CreateHorizontalBox( 'V8A', 025,,, 'FOLDER_BENEFPEN', 'ABA01' )
    oView:AddGrid( "VIEW_V8A", oStruV8A, "MODEL_V8A" )
    oView:EnableTitleView("VIEW_V8A",STR0059 ) //"Informação das deduções suspensas por dependentes e beneficiários da pensão alimentícia." 
    oView:SetOwnerView( "VIEW_V8A", "V8A"  )

    oView:AddSheet( 'FOLDER_INFOPERANT', 'ABA03', STR0060 ) //"Plano de saúde coletivo."
    oView:AddGrid( "VIEW_V8B", oStruV8B, "MODEL_V8B" )
    oView:EnableTitleView("VIEW_V8B", STR0061)  //"Identificação da(s) operadora(s) de plano privado coletivo empresarial de assistência à saúde."
    oView:CreateHorizontalBox( 'V8B', 025,,, 'FOLDER_INFOPERANT', 'ABA03' )
    oView:SetOwnerView( "VIEW_V8B", "V8B"  )
    If TafColumnPos("V8B_SEQUEN")
        oView:AddIncrementField( "VIEW_V8B", "V8B_SEQUEN" )
    EndIf 

    oView:CreateHorizontalBox("PAINEL_INFODEPSAU",025,,,"FOLDER_INFOPERANT","ABA03")
    oView:CreateFolder( 'FOLDER_INFODEPSAU', 'PAINEL_INFODEPSAU' )    

    oView:AddSheet( 'FOLDER_INFODEPSAU', 'ABA01', STR0062 ) //"Info. Dependente Plano de Saúde."			
    oView:CreateHorizontalBox( 'V8C', 025,,, 'FOLDER_INFODEPSAU', 'ABA01' )
    oView:AddGrid( "VIEW_V8C", oStruV8C, "MODEL_V8C" )
    oView:EnableTitleView("VIEW_V8C", STR0063) //"Informações de dependente de plano de saúde coletivo empresarial."
    oView:SetOwnerView( "VIEW_V8C", "V8C"  )    

    oView:AddSheet( 'FOLDER_INFOPERANT', 'ABA04', STR0064 ) //"Info. Reembolso"
    oView:CreateHorizontalBox( 'V8D', 025,,, 'FOLDER_INFOPERANT', 'ABA04' )
    oView:AddGrid( "VIEW_V8D", oStruV8D, "MODEL_V8D" )
    oView:EnableTitleView("VIEW_V8D", STR0065 ) // "Informações Reembolso efetuados pelo empregador."
    oView:SetOwnerView( "VIEW_V8D", "V8D"  )
    oView:AddIncrementField( "VIEW_V8D", "V8D_SEQUEN" )

    oView:CreateHorizontalBox("PAINEL_DETREEMB",050,,,"FOLDER_INFOPERANT","ABA04")
    oView:CreateFolder( 'FOLDER_DETREEMB', 'PAINEL_DETREEMB' )

    oView:AddSheet( 'FOLDER_DETREEMB', 'ABA01', STR0066 ) //Info. Reembolso Titular.			
    oView:CreateHorizontalBox( 'V8E', 025,,, 'FOLDER_DETREEMB', 'ABA01' )
    oView:AddGrid( "VIEW_V8E", oStruV8E, "MODEL_V8E" )
    oView:EnableTitleView("VIEW_V8E", STR0067) //"Informação de reembolso do titular do plano de saúde coletivo empresarial."
    oView:SetOwnerView( "VIEW_V8E", "V8E"  )

    oView:AddSheet( 'FOLDER_DETREEMB', 'ABA02', STR0068 ) //"Info. Reembolso Dependente."			
    oView:CreateHorizontalBox( 'V8F', 025,,, 'FOLDER_DETREEMB', 'ABA02' )
    oView:AddGrid( "VIEW_V8F", oStruV8F, "MODEL_V8F" )
    oView:EnableTitleView("VIEW_V8F", STR0069) //"Informação de reembolso do dependente do plano de saúde coletivo empresarial.
    oView:SetOwnerView( "VIEW_V8F", "V8F"  )

    oView:CreateHorizontalBox("PAINEL_DETDEP",050,,,"FOLDER_DETREEMB","ABA02")
    oView:CreateFolder( 'FOLDER_DETDEP', 'PAINEL_DETDEP' )

    oView:AddSheet( 'FOLDER_DETDEP', 'ABA02', STR0070 ) //"Info. Reembolso pelo empregador para Dependente."			
    oView:CreateHorizontalBox( 'V8G', 025,,, 'FOLDER_DETDEP', 'ABA02' )
    oView:AddGrid( "VIEW_V8G", oStruV8G, "MODEL_V8G" )
    oView:EnableTitleView("VIEW_V8G", STR0069 ) // Informação de reembolso do dependente do plano de saúde coletivo empresarial."
    oView:SetOwnerView( "VIEW_V8G", "V8G"  )

Return nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafContnuews
Rotina para limpeza dos registros inconsistentes na TAFXERP
nOpc  - operação da view ( 3 - incluir , 4 - alterar/visualizar e incluir )  as numeric
nMv   - Atualiza opção de multplos vinculos ( 1- mv 2- Não mv ) as numeric
nView - Atualiza opção para continuos form (1 - sim 2 - não ) as numeric
@author Alexandre de lima santos
@since 03/03/2025
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TafContnuews( nOpc as numeric, nMv as numeric, nView as numeric)

    Local cTitle  as character
    Local oDlg    as object 
    Local oFont1  as object
    Local oFont2  as object
    Local oPanel  as object
    Local oSay1   as object
    Local oRadio  as object
    Local oRadio1 as object
    Local oSay3   as object
    Local oSay4   as object
    Local oButton as object
    Local nAlt1   as numeric 
    Local nAlt2   as numeric
    Local nAlt3   as numeric
    Local nAlt4   as numeric
    Local aItens  as array
    LocaL aItens1 as array

    Default nMv      := 0
    Default nView    := 0
    Default nOpc     := 1

    cTitle  := ""
    oDlg    := Nil
    oFont1  := Nil
    oFont2  := Nil
    oPanel  := Nil
    oSay1   := Nil
    oRadio  := Nil
    oRadio1 := Nil
    oSay3   := Nil
    oSay4   := Nil
    oButton := Nil
    nAlt1   := 1
    nAlt2   := 1
    nAlt3   := 1
    nAlt4   := 1
    aItens  := {}
    aItens1 := {}

    If( nOpc == 4 )
        nAlt1  := 010
        nAlt2  := 25
        nAlt3  := 50
        nAlt4  := 80
        nTam  := 300
        cTitle := "Alteração/Visualização ou exclusão do evento S-1210"
    Else
        nAlt1  := 50
        nAlt2  := 60
        nAlt3  := 85
        nAlt4  := 135
        nTam   := 400
        cTitle := "Inclusão S-1210"
    EndIf

    Define MsDialog oDlg From 0,0 To nTam,550 Pixel Title OemToAnsi(cTitle) STYLE DS_MODALFRAME

        oFont1 := TFont():New("Tahoma",,-12,.T.)
        oFont1:Bold = .T.
        oFont2 := TFont():New("Tahoma",,-12,.T.)
        oFont2:Bold = .T.
        oFont2:Underline := .T.

        oPanel := TPanel():New(000,000,'',oDlg,,.F.,.F.,,CLR_WHITE,000,000,.T.,.T.)
        oPanel:Align := CONTROL_ALIGN_ALLCLIENT

        If nOpc == 3

            oSay1 := TSay():New(010,15,{||'Pagamento de rendimentos do trabalho a ser incluído é de um funcionário com múltiplos vínculos ?'},oPanel,,oFont1,,,,.T.,CLR_RED,CLR_WHITE,250,250)
            
            nMv := 1
            aItens := {'Sim','Não'}
            oRadio := TRadMenu():New (25,15,aItens,,oPanel,,,,,,,,100,12,,,,.T.)
            oRadio:bSetGet := {|u|Iif (PCount()==0,nMv,nMv:=u)}

        EndIf

        oSay2 := TSay():New(nAlt1,15,{||'Apresentação de View sem formulário contínuo ?'},oPanel,,oFont1,,,,.T.,CLR_RED,CLR_WHITE,250,250)

        nView := 1
        aItens1 := {'Sim','Não'}
        oRadio1 := TRadMenu():New (nAlt2,15,aItens1,,oPanel,,,,,,,,100,12,,,,.T.)
        oRadio1:bSetGet := {|u|Iif (PCount()==0,nView,nView:=u)}

        oSay3 := TSay():New(nAlt3,15,{||'A opção da visualização sem o formulário contínuo tem como objetivo diminuir o tempo na abertura da tela do evento S-1210, para mais informações aceese o link abaixo:'},oPanel,,oFont1,,,,.T.,CLR_HRED,CLR_WHITE,250,250)
        oButton := TButton():New( nAlt4, 15, "Clique aqui para acessar a documentação",oPanel,, 110,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
        oButton:bAction := {|| ShellExecute("open", "https://tdn.totvs.com/pages/viewpage.action?pageId=273303392#S1200Remunera%C3%A7%C3%A3odeTrabalhadorvinculadoaoRegimeGeraldePrevid.Social-Conte%C3%BAdosRelacionados", "", "", 1) }

    Activate MsDialog oDlg Centered On Init Enchoicebar (oDlg	,{||,oDlg:End()},{|| nView := 0, oDlg:End() },,,,,.F.,.F.,.F.,.T.,.F.)

Return Nil 
