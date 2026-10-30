#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TAFA609.CH'
#INCLUDE "TOPCONN.CH"

Static cIdV7C  		as  character
Static cPerV7C 		as  character
Static cSeqV7C 		as  character
Static cNrPocV7C 	as  character
Static __cPicPerRef := Nil 
Static __cPicVrMen  := Nil
Static __cPicVrCP   := Nil
Static __cPicVrRen  := Nil
Static __cPicVrIRF  := Nil
Static __cPicVrRed  := Nil
Static __cPicVrT13  := Nil
Static __cPicVrMGr  := Nil
Static __cPicVrJur  := Nil
Static __cPicVrITr  := Nil
Static __cPicVrPOf  := Nil
Static __cPicVrI65	:= Nil
Static __cPicVrCus  := Nil
Static __cPicVrAdv	:= Nil
Static __cPicVlrAd	:= Nil
Static __cPicVrDed	:= Nil
Static __cPicVlPen	:= Nil
Static __cPicVlNRe  := Nil
Static __cPicVlDJu  := Nil
Static __cPicVlCAC  := Nil
Static __cPicVlCAA 	:= Nil 
Static __cPicVlReS	:= Nil 
Static __cPicVlDSu  := Nil 
Static __cPicVlDep	:= Nil
Static lSimpl0102  	:= TAFLayESoc("S_01_02_00", .T., .T.)
Static lSimpl0103  	:= TAFLayESoc("S_01_03_00", .T., .T.)
Static lDic0103     := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA609
Informações de Contribuições Decorrentes de Processo Trabalhista S-2501

@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFA609()

	Private oBrw  		as Object
	Private cEvtPosic 	as Character

	oBrw  		:= FWmBrowse():New()
	cEvtPosic 	:= ""

	If TAFAtualizado( .T. ,'TAFA609' )
		TafNewBrowse( "S-2501",,,, STR0001, , 2, 2 )
	EndIf
	
	oBrw:SetCacheView( .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina as array

	aRotina := {}

	If !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES") .AND. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF609View('V7C',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF609Inc('V7C',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('V7C', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA609"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA609' OPERATION 2 ACCESS 0
			aRotina	:= xMnuExtmp( "TAFA609", "V7C", .F. ) // Menu dos extemporâneos
		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV7C 	as Object
	Local oStruV7D 	as Object
	Local oStruV7E 	as Object
	Local oStruV7F 	as Object
	Local oStruV7G 	as Object
	Local oStruV8X 	as Object
	Local oStruV8Y 	as Object
	Local oStruV8K 	as Object
	Local oStruV8L 	as Object
	Local oStruV8M 	as Object
	Local oStruV8N 	as Object
	Local oStruV8O 	as Object
	Local oStruV8P 	as Object
	Local oStruV8Q 	as Object
	Local oStruV8S 	as Object
	Local oModel	as Object

	cIdV7C  	:= V7C->V7C_IDPROC
	cPerV7C 	:= V7C->V7C_PERAPU
	cSeqV7C 	:= V7C->V7C_IDESEQ
	

	oStruV7C   := FwFormStruct( 1, "V7C" )
	oStruV7D   := FwFormStruct( 1, "V7D" )
	oStruV7E   := FwFormStruct( 1, "V7E" )
	oStruV7F   := FwFormStruct( 1, "V7F" )
	oStruV7G   := FwFormStruct( 1, "V7G" )

	SetlDic0103()

	If lSimpl0102 .Or. (lSimpl0103 .And. lDic0103)

		oStruV8X   := FwFormStruct( 1, "V8X" )
		oStruV8Y   := FwFormStruct( 1, "V8Y" )
		oStruV8K   := FwFormStruct( 1, "V8K" )
		oStruV8L   := FwFormStruct( 1, "V8L" )
		oStruV8M   := FwFormStruct( 1, "V8M" )
		oStruV8N   := FwFormStruct( 1, "V8N" )
		oStruV8O   := FwFormStruct( 1, "V8O" )
		oStruV8P   := FwFormStruct( 1, "V8P" )
		oStruV8Q   := FwFormStruct( 1, "V8Q" )
		oStruV8S   := FwFormStruct( 1, "V8S" )

	EndIf

	oModel     := MpFormModel():New("TAFA609", , , { |oModel| SaveModel( oModel ) })
	
	oModel:AddFields('MODEL_V7C',, oStruV7C)

	If lSimpl0103 .And. lDic0103
		oModel:GetModel( 'MODEL_V7C' ):SetPrimaryKey( { 'V7C_FILIAL' , 'V7C_IDPROC', 'V7C_PERAPU','V7C_IDESEQ','V7C_ATIVO' } )
	Else
		oModel:GetModel( 'MODEL_V7C' ):SetPrimaryKey( { 'V7C_FILIAL' , 'V7C_IDPROC', 'V7C_PERAPU','V7C_ATIVO' } )  
	EndIf                                                                                                               
	
	// OBRIGATORIEDADE DE CAMPOS 
	oStruV7C:SetProperty( 'V7C_IDPROC', MODEL_FIELD_OBRIGAT , .T. )
	oStruV7D:SetProperty( 'V7D_CPFTRA', MODEL_FIELD_OBRIGAT , .T. )
	
	oModel:AddGrid("MODEL_V7D", "MODEL_V7C", oStruV7D)
	oModel:GetModel( "MODEL_V7D" ):SetOptional( .F. )
	oModel:GetModel( "MODEL_V7D" ):SetUniqueLine({"V7D_CPFTRA"})
	
	oModel:AddGrid("MODEL_V7E", "MODEL_V7D", oStruV7E)
	oModel:GetModel( "MODEL_V7E" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V7E" ):SetUniqueLine({"V7E_PERREF"})
	oModel:GetModel( 'MODEL_V7E' ):SetMaxLine(360)
	
	oModel:AddGrid("MODEL_V7F", "MODEL_V7E", oStruV7F)
	oModel:GetModel( "MODEL_V7F" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V7F" ):SetUniqueLine({"V7F_IDCODR"})
	oModel:GetModel( 'MODEL_V7F' ):SetMaxLine(99)
	
	oModel:AddGrid("MODEL_V7G", "MODEL_V7D", oStruV7G)
	oModel:GetModel( "MODEL_V7G" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V7G" ):SetUniqueLine({"V7G_TPCR"})
	oModel:GetModel( 'MODEL_V7G' ):SetMaxLine(99)

	If lSimpl0102 .Or. (lSimpl0103 .And. lDic0103)

		oModel:AddGrid("MODEL_V8X", "MODEL_V7G", oStruV8X) //INFOIR
		oModel:GetModel( "MODEL_V8X" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8X" ):SetUniqueLine({"V8X_CHAVE"}) 
		oModel:GetModel( 'MODEL_V8X' ):SetMaxLine(1)

		oModel:AddGrid("MODEL_V8Y", "MODEL_V7G", oStruV8Y) //INFORRA E DESPPROCJUD
		oModel:GetModel( "MODEL_V8Y" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8Y" ):SetUniqueLine({"V8Y_CHAVE"})
		oModel:GetModel( 'MODEL_V8Y' ):SetMaxLine(1)

		oModel:AddGrid("MODEL_V8K", "MODEL_V7G", oStruV8K) //IDEADV
		oModel:GetModel( "MODEL_V8K" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8K" ):SetUniqueLine({"V8K_TPINSC","V8K_NRINSC"})
		oModel:GetModel( 'MODEL_V8K' ):SetMaxLine(99)

		oModel:AddGrid("MODEL_V8L", "MODEL_V7G", oStruV8L) //DEDDEPN
		oModel:GetModel( "MODEL_V8L" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8L" ):SetUniqueLine({"V8L_TPREND","V8L_CPFDEP"})
		oModel:GetModel( 'MODEL_V8L' ):SetMaxLine(999)

		oModel:AddGrid("MODEL_V8M", "MODEL_V7G", oStruV8M) //PENALIM
		oModel:GetModel( "MODEL_V8M" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8M" ):SetUniqueLine({"V8M_TPREND","V8M_CPFDEP"})
		oModel:GetModel( 'MODEL_V8M' ):SetMaxLine(99)

		oModel:AddGrid("MODEL_V8N", "MODEL_V7G", oStruV8N)//INFOPROCRET
		oModel:GetModel( "MODEL_V8N" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8N" ):SetUniqueLine({"V8N_TPPRCR","V8N_NRPRCR","V8N_CODSUP"})
		oModel:GetModel( 'MODEL_V8N' ):SetMaxLine(50)

		oModel:AddGrid("MODEL_V8O", "MODEL_V8N", oStruV8O) //INFOVALORES
		oModel:GetModel( "MODEL_V8O" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8O" ):SetUniqueLine({"V8O_INDAPU"})
		oModel:GetModel( 'MODEL_V8O' ):SetMaxLine(3)

		oModel:AddGrid("MODEL_V8P", "MODEL_V8O", oStruV8P) //DEDSUSP
		oModel:GetModel( "MODEL_V8P" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8P" ):SetUniqueLine({"V8P_CHAVE"})
		oModel:GetModel( 'MODEL_V8P' ):SetMaxLine(25)

		oModel:AddGrid("MODEL_V8Q", "MODEL_V8P", oStruV8Q) //BENEFPEN
		oModel:GetModel( "MODEL_V8Q" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8Q" ):SetUniqueLine({"V8Q_CPFDEP"})
		oModel:GetModel( 'MODEL_V8Q' ):SetMaxLine(99)

		oModel:AddGrid("MODEL_V8S", "MODEL_V7D", oStruV8S) //BENEFPEN
		oModel:GetModel( "MODEL_V8S" ):SetOptional( .T. )
		oModel:GetModel( "MODEL_V8S" ):SetUniqueLine({"V8S_CPFDEP"})
		oModel:GetModel( 'MODEL_V8S' ):SetMaxLine(999)

	EndIf

	If lSimpl0103 .And. lDic0103 
		oModel:SetRelation( "MODEL_V7D" , { { "V7D_FILIAL", "xFilial('V7D')" }, { "V7D_ID", "V7C_ID" }, { "V7D_VERSAO", "V7C_VERSAO" }, { "V7D_IDPROC", "V7C_IDPROC" },{ "V7D_PERAPU", "V7C_PERAPU" }, { "V7D_IDESEQ", "V7C_IDESEQ" }  }, V7D->(IndexKey(2) ) ) //V7D_FILIAL+V7D_ID+V7D_VERSAO+V7D_IDPROC+V7D_PERAPU+V7D_CPF+VD7_ATIVO
		oModel:SetRelation( "MODEL_V7E" , { { "V7E_FILIAL", "xFilial('V7E')" }, { "V7E_ID", "V7C_ID" }, { "V7E_VERSAO", "V7C_VERSAO" }, { "V7E_IDPROC", "V7C_IDPROC" },{ "V7E_PERAPU", "V7C_PERAPU" }, { "V7E_CPFTRA", "V7D_CPFTRA" }, { "V7E_IDESEQ", "V7C_IDESEQ" }  }, V7E->(IndexKey(2) ) )
		oModel:SetRelation( "MODEL_V7F" , { { "V7F_FILIAL", "xFilial('V7F')" }, { "V7F_ID", "V7C_ID" }, { "V7F_VERSAO", "V7C_VERSAO" }, { "V7F_IDPROC", "V7C_IDPROC" },{ "V7F_PERAPU", "V7C_PERAPU" }, { "V7F_CPFTRA", "V7D_CPFTRA" }, { "V7F_PERREF", "V7E_PERREF" }, { "V7F_IDESEQ", "V7C_IDESEQ" }}, V7F->(IndexKey(2) ) )
		oModel:SetRelation( "MODEL_V7G" , { { "V7G_FILIAL", "xFilial('V7G')" }, { "V7G_ID", "V7C_ID" }, { "V7G_VERSAO", "V7C_VERSAO" }, { "V7G_IDPROC", "V7C_IDPROC" },{ "V7G_PERAPU", "V7C_PERAPU" }, { "V7G_CPFTRA", "V7D_CPFTRA" }, { "V7G_IDESEQ", "V7C_IDESEQ" } }, V7G->( IndexKey(2) ) )
		
		oModel:SetRelation( "MODEL_V8X" , { { "V8X_FILIAL", "xFilial('V8X')" }, { "V8X_ID", "V7C_ID" }, { "V8X_VERSAO", "V7C_VERSAO" }, { "V8X_IDPROC", "V7C_IDPROC" },{ "V8X_PERAPU", "V7C_PERAPU" }, { "V8X_CPFTRA", "V7D_CPFTRA" }, {"V8X_TPCR", "V7G_TPCR"},{ "V8X_IDESEQ", "V7C_IDESEQ" } }, V8X->( IndexKey(2) ) )
		oModel:SetRelation( "MODEL_V8Y" , { { "V8Y_FILIAL", "xFilial('V8Y')" }, { "V8Y_ID", "V7C_ID" }, { "V8Y_VERSAO", "V7C_VERSAO" }, { "V8Y_IDPROC", "V7C_IDPROC" },{ "V8Y_PERAPU", "V7C_PERAPU" }, { "V8Y_CPFTRA", "V7D_CPFTRA" }, {"V8Y_TPCR", "V7G_TPCR"},{ "V8Y_IDESEQ", "V7C_IDESEQ" } }, V8Y->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8K" , { { "V8K_FILIAL", "xFilial('V8K')" }, { "V8K_ID", "V7C_ID" }, { "V8K_VERSAO", "V7C_VERSAO" }, { "V8K_IDPROC", "V7C_IDPROC" },{ "V8K_PERAPU", "V7C_PERAPU" }, { "V8K_CPFTRA", "V7D_CPFTRA" }, {"V8K_TPCR", "V7G_TPCR"},{ "V8K_IDESEQ", "V7C_IDESEQ" } }, V8K->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8L" , { { "V8L_FILIAL", "xFilial('V8L')" }, { "V8L_ID", "V7C_ID" }, { "V8L_VERSAO", "V7C_VERSAO" }, { "V8L_IDPROC", "V7C_IDPROC" },{ "V8L_PERAPU", "V7C_PERAPU" }, { "V8L_CPFTRA", "V7D_CPFTRA" }, {"V8L_TPCR", "V7G_TPCR"},{ "V8L_IDESEQ", "V7C_IDESEQ" } }, V8L->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8M" , { { "V8M_FILIAL", "xFilial('V8M')" }, { "V8M_ID", "V7C_ID" }, { "V8M_VERSAO", "V7C_VERSAO" }, { "V8M_IDPROC", "V7C_IDPROC" },{ "V8M_PERAPU", "V7C_PERAPU" }, { "V8M_CPFTRA", "V7D_CPFTRA" }, {"V8M_TPCR", "V7G_TPCR"},{ "V8M_IDESEQ", "V7C_IDESEQ" } }, V8M->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8N" , { { "V8N_FILIAL", "xFilial('V8N')" }, { "V8N_ID", "V7C_ID" }, { "V8N_VERSAO", "V7C_VERSAO" }, { "V8N_IDPROC", "V7C_IDPROC" },{ "V8N_PERAPU", "V7C_PERAPU" }, { "V8N_CPFTRA", "V7D_CPFTRA" }, {"V8N_TPCR", "V7G_TPCR"},{ "V8N_IDESEQ", "V7C_IDESEQ" } }, V8N->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8O" , { { "V8O_FILIAL", "xFilial('V8O')" }, { "V8O_ID", "V7C_ID" }, { "V8O_VERSAO", "V7C_VERSAO" }, { "V8O_IDPROC", "V7C_IDPROC" },{ "V8O_PERAPU", "V7C_PERAPU" }, { "V8O_CPFTRA", "V7D_CPFTRA" }, {"V8O_TPCR", "V7G_TPCR"}, {"V8O_TPPRCR","V8N_TPPRCR"},{"V8O_NRPRCR","V8N_NRPRCR"},{"V8O_CODSUP","V8N_CODSUP"},{ "V8O_IDESEQ", "V7C_IDESEQ" }}, V8O->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8P" , { { "V8P_FILIAL", "xFilial('V8P')" }, { "V8P_ID", "V7C_ID" }, { "V8P_VERSAO", "V7C_VERSAO" }, { "V8P_IDPROC", "V7C_IDPROC" },{ "V8P_PERAPU", "V7C_PERAPU" }, { "V8P_CPFTRA", "V7D_CPFTRA" }, {"V8P_TPCR", "V7G_TPCR"}, {"V8P_TPPRCR","V8N_TPPRCR"},{"V8P_NRPRCR","V8N_NRPRCR"},{"V8P_CODSUP","V8N_CODSUP"}, {"V8P_INDAPU","V8O_INDAPU"},{ "V8P_IDESEQ", "V7C_IDESEQ" }}, V8P->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8Q" , { { "V8Q_FILIAL", "xFilial('V8Q')" }, { "V8Q_ID", "V7C_ID" }, { "V8Q_VERSAO", "V7C_VERSAO" }, { "V8Q_IDPROC", "V7C_IDPROC" },{ "V8Q_PERAPU", "V7C_PERAPU" }, { "V8Q_CPFTRA", "V7D_CPFTRA" }, {"V8Q_TPCR", "V7G_TPCR"}, {"V8Q_TPPRCR","V8N_TPPRCR"},{"V8Q_NRPRCR","V8N_NRPRCR"},{"V8Q_CODSUP","V8N_CODSUP"}, {"V8Q_INDAPU","V8O_INDAPU"}, {"V8Q_CHAVE","V8P_CHAVE"},{ "V8Q_IDESEQ", "V7C_IDESEQ" }}, V8Q->( IndexKey(1) ) )
		oModel:SetRelation( "MODEL_V8S" , { { "V8S_FILIAL", "xFilial('V8S')" }, { "V8S_ID", "V7C_ID" }, { "V8S_VERSAO", "V7C_VERSAO" }, { "V8S_IDPROC", "V7C_IDPROC" },{ "V8S_PERAPU", "V7C_PERAPU" }, { "V8S_CPFTRA", "V7D_CPFTRA" }, { "V8S_IDESEQ", "V7C_IDESEQ" } }, V8S->( IndexKey(1) ) )


	Else 
		oModel:SetRelation( "MODEL_V7D" , { { "V7D_FILIAL", "xFilial('V7D')" }, { "V7D_ID", "V7C_ID" }, { "V7D_VERSAO", "V7C_VERSAO" }, { "V7D_IDPROC", "V7C_IDPROC" },{ "V7D_PERAPU", "V7C_PERAPU" } }, V7D->(IndexKey(2) ) ) //V7D_FILIAL+V7D_ID+V7D_VERSAO+V7D_IDPROC+V7D_PERAPU+V7D_CPF+VD7_ATIVO
		oModel:SetRelation( "MODEL_V7E" , { { "V7E_FILIAL", "xFilial('V7E')" }, { "V7E_ID", "V7C_ID" }, { "V7E_VERSAO", "V7C_VERSAO" }, { "V7E_IDPROC", "V7C_IDPROC" },{ "V7E_PERAPU", "V7C_PERAPU" }, { "V7E_CPFTRA", "V7D_CPFTRA" } }, V7E->(IndexKey(2) ) )
		oModel:SetRelation( "MODEL_V7F" , { { "V7F_FILIAL", "xFilial('V7F')" }, { "V7F_ID", "V7C_ID" }, { "V7F_VERSAO", "V7C_VERSAO" }, { "V7F_IDPROC", "V7C_IDPROC" },{ "V7F_PERAPU", "V7C_PERAPU" }, { "V7F_CPFTRA", "V7D_CPFTRA" }, { "V7F_PERREF", "V7E_PERREF" }}, V7F->(IndexKey(2) ) )
		oModel:SetRelation( "MODEL_V7G" , { { "V7G_FILIAL", "xFilial('V7G')" }, { "V7G_ID", "V7C_ID" }, { "V7G_VERSAO", "V7C_VERSAO" }, { "V7G_IDPROC", "V7C_IDPROC" },{ "V7G_PERAPU", "V7C_PERAPU" }, { "V7G_CPFTRA", "V7D_CPFTRA" } }, V7G->( IndexKey(2) ) )
		

		If lSimpl0102 .And. TafColumnPos( "V8X_VLRTRI" )

			oModel:SetRelation( "MODEL_V8X" , { { "V8X_FILIAL", "xFilial('V8X')" }, { "V8X_ID", "V7C_ID" }, { "V8X_VERSAO", "V7C_VERSAO" }, { "V8X_IDPROC", "V7C_IDPROC" },{ "V8X_PERAPU", "V7C_PERAPU" }, { "V8X_CPFTRA", "V7D_CPFTRA" }, {"V8X_TPCR", "V7G_TPCR"} }, V8X->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8Y" , { { "V8Y_FILIAL", "xFilial('V8Y')" }, { "V8Y_ID", "V7C_ID" }, { "V8Y_VERSAO", "V7C_VERSAO" }, { "V8Y_IDPROC", "V7C_IDPROC" },{ "V8Y_PERAPU", "V7C_PERAPU" }, { "V8Y_CPFTRA", "V7D_CPFTRA" }, {"V8Y_TPCR", "V7G_TPCR"} }, V8Y->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8K" , { { "V8K_FILIAL", "xFilial('V8K')" }, { "V8K_ID", "V7C_ID" }, { "V8K_VERSAO", "V7C_VERSAO" }, { "V8K_IDPROC", "V7C_IDPROC" },{ "V8K_PERAPU", "V7C_PERAPU" }, { "V8K_CPFTRA", "V7D_CPFTRA" }, {"V8K_TPCR", "V7G_TPCR"} }, V8K->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8L" , { { "V8L_FILIAL", "xFilial('V8L')" }, { "V8L_ID", "V7C_ID" }, { "V8L_VERSAO", "V7C_VERSAO" }, { "V8L_IDPROC", "V7C_IDPROC" },{ "V8L_PERAPU", "V7C_PERAPU" }, { "V8L_CPFTRA", "V7D_CPFTRA" }, {"V8L_TPCR", "V7G_TPCR"} }, V8L->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8M" , { { "V8M_FILIAL", "xFilial('V8M')" }, { "V8M_ID", "V7C_ID" }, { "V8M_VERSAO", "V7C_VERSAO" }, { "V8M_IDPROC", "V7C_IDPROC" },{ "V8M_PERAPU", "V7C_PERAPU" }, { "V8M_CPFTRA", "V7D_CPFTRA" }, {"V8M_TPCR", "V7G_TPCR"} }, V8M->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8N" , { { "V8N_FILIAL", "xFilial('V8N')" }, { "V8N_ID", "V7C_ID" }, { "V8N_VERSAO", "V7C_VERSAO" }, { "V8N_IDPROC", "V7C_IDPROC" },{ "V8N_PERAPU", "V7C_PERAPU" }, { "V8N_CPFTRA", "V7D_CPFTRA" }, {"V8N_TPCR", "V7G_TPCR"} }, V8N->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8O" , { { "V8O_FILIAL", "xFilial('V8O')" }, { "V8O_ID", "V7C_ID" }, { "V8O_VERSAO", "V7C_VERSAO" }, { "V8O_IDPROC", "V7C_IDPROC" },{ "V8O_PERAPU", "V7C_PERAPU" }, { "V8O_CPFTRA", "V7D_CPFTRA" }, {"V8O_TPCR", "V7G_TPCR"}, {"V8O_TPPRCR","V8N_TPPRCR"},{"V8O_NRPRCR","V8N_NRPRCR"},{"V8O_CODSUP","V8N_CODSUP"}}, V8O->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8P" , { { "V8P_FILIAL", "xFilial('V8P')" }, { "V8P_ID", "V7C_ID" }, { "V8P_VERSAO", "V7C_VERSAO" }, { "V8P_IDPROC", "V7C_IDPROC" },{ "V8P_PERAPU", "V7C_PERAPU" }, { "V8P_CPFTRA", "V7D_CPFTRA" }, {"V8P_TPCR", "V7G_TPCR"}, {"V8P_TPPRCR","V8N_TPPRCR"},{"V8P_NRPRCR","V8N_NRPRCR"},{"V8P_CODSUP","V8N_CODSUP"}, {"V8P_INDAPU","V8O_INDAPU"}}, V8P->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8Q" , { { "V8Q_FILIAL", "xFilial('V8Q')" }, { "V8Q_ID", "V7C_ID" }, { "V8Q_VERSAO", "V7C_VERSAO" }, { "V8Q_IDPROC", "V7C_IDPROC" },{ "V8Q_PERAPU", "V7C_PERAPU" }, { "V8Q_CPFTRA", "V7D_CPFTRA" }, {"V8Q_TPCR", "V7G_TPCR"}, {"V8Q_TPPRCR","V8N_TPPRCR"},{"V8Q_NRPRCR","V8N_NRPRCR"},{"V8Q_CODSUP","V8N_CODSUP"}, {"V8Q_INDAPU","V8O_INDAPU"}, {"V8Q_CHAVE","V8P_CHAVE"}}, V8Q->( IndexKey(1) ) )
			oModel:SetRelation( "MODEL_V8S" , { { "V8S_FILIAL", "xFilial('V8S')" }, { "V8S_ID", "V7C_ID" }, { "V8S_VERSAO", "V7C_VERSAO" }, { "V8S_IDPROC", "V7C_IDPROC" },{ "V8S_PERAPU", "V7C_PERAPU" }, { "V8S_CPFTRA", "V7D_CPFTRA" } }, V8S->( IndexKey(1) ) )

		EndIf
	EndIf 

	//Remoç?o do GetSX8Num quando se tratar da Exclus?o de um Evento Transmitido.
	//Necessário para n?o incrementar ID que n?o será utilizado.
	If Type( "INCLUI" ) <> "U"  .AND. !INCLUI
		oStruV7C:SetProperty( "V7C_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndiF

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local cV7C       as Character
	Local cV7CProtul as Character
	Local cV7D       as Character
	Local cV7E       as Character
	Local cV7F       as Character
	Local cV8K       as Character
	Local cV8L       as Character
	Local cV8M       as Character
	Local cV8N       as Character
	Local cV8O       as Character
	Local cV8P       as Character
	Local cV8Q       as Character
	Local cV8S       as Character
	Local cV8X       as Character
	Local cV8Y       as Character
	Local oModel     as Object
	Local oProtulV7C as Object
	Local oStruV7C   as Object
	Local oStruV7D   as Object
	Local oStruV7E   as Object
	Local oStruV7F   as Object
	Local oStruV7G   as Object
	Local oStruV8K   as Object
	Local oStruV8L   as Object
	Local oStruV8M   as Object
	Local oStruV8N   as Object
	Local oStruV8O   as Object
	Local oStruV8Q   as Object
	Local oStruV8S   as Object
	Local oStruV8X   as Object
	Local oStruV8Y   as Object
	Local oView      as Object

	SetlDic0103()

	If lSimpl0103 .and. lDic0103
		cV7C       := "V7C_IDPROC|V7C_NRPROC|V7C_PERAPU|V7C_IDESEQ|V7C_OBS|"
	Else 
		cV7C       := "V7C_IDPROC|V7C_NRPROC|V7C_PERAPU|V7C_OBS|"
	EndIf 

	cV7D       := "V7D_CPFTRA|V7D_DCPF|"
	cV7E       := "V7E_PERREF|V7E_VRMEN|V7E_VRCP|" 
	cV7E       += Iif(!lSimpl0102, "V7E_VERREN|V7E_VRIRRF|","")
	cV7F       := "V7F_IDCODR|V7F_DCODRE|V7F_VRCR|"
	cV7G       := "V7G_TPCR|V7G_DCODRE|V7G_VRCR|"
	If lSimpl0103 .and. lDic0103
		cV7G += "V7G_VRCR13|"
	EndIf 
	cV7CProtul := "V7C_PROTUL|V7C_DINSIS|V7C_DTRAN|V7C_HTRANS|V7C_DTRECP|V7C_HRRECP|"

	If lSimpl0102 .Or. (lSimpl0103 .and. lDic0103)

		cV8X       := "V8X_CHAVE|V8X_VLRTRI|V8X_VLRT13|V8X_VLRIMG|V8X_VLRI65|V8X_VLJRMO|V8X_VLRINT|V8X_DCRINT|V8X_VLPRVO|"
		cV8Y       := "V8Y_CHAVE|V8Y_DESCRA|V8Y_QTMRRA|V8Y_VLRCUS|V8Y_VLRADV|"
		cV8K       := "V8K_TPINSC|V8K_NRINSC|V8K_VLRADV|"
		cV8L       := "V8L_TPREND|V8L_CPFDEP|V8L_VLRDED|"
		cV8M       := "V8M_TPREND|V8M_CPFDEP|V8M_VLPENS|"
		cV8N       := "V8N_TPPRCR|V8N_NRPRCR|V8N_CODSUP|"
		cV8O       := "V8O_INDAPU|V8O_VLNRET|V8O_VLDEPJ|V8O_VLCPAC|V8O_VLCPAA|V8O_VLRSUS|"
		cV8P       := "V8P_CHAVE|V8P_TPDEDU|V8P_VLSUSP|"
		cV8Q       := "V8Q_CPFDEP|V8Q_VLDEPS|"
		cV8S       := "V8S_DTLAUD|V8S_CPFDEP|V8S_DTNASC|V8S_NOME|V8S_DEPIR|V8S_TPDEP|V8S_DESCDE|"

	EndIf

	If lSimpl0103 .and. lDic0103
		cV8X += "V8X_IMG13|V8X_I65DEC|V8X_MOR13|V8X_PREV13|V8X_VLRDIA|V8X_VLRAJU|V8X_VLRCON|V8X_VLRABN|V8X_VLMORD|"
	EndIf 
	
	oModel := FWLoadModel( 'TAFA609' )
	oView  := FWFormView():New()

	oView:SetModel( oModel )
	oView:SetContinuousForm(.T.)

	oStruV7C	:= FwFormStruct( 2, "V7C",{|x| AllTrim( x ) + "|" $ cV7C } )
	oStruV7D	:= FwFormStruct( 2, "V7D",{|x| AllTrim( x ) + "|" $ cV7D } )
	oStruV7E	:= FwFormStruct( 2, "V7E",{|x| AllTrim( x ) + "|" $ cV7E } )
	oStruV7F	:= FwFormStruct( 2, "V7F",{|x| AllTrim( x ) + "|" $ cV7F } )
	oStruV7G	:= FwFormStruct( 2, "V7G",{|x| AllTrim( x ) + "|" $ cV7G } )
	oProtulV7C 	:= FwFormStruct( 2, "V7C",{|x| AllTrim( x ) + "|" $ cV7CProtul } )

	If lSimpl0102 .OR. (lSimpl0103 .and. lDic0103)

		oStruV8X	:= FwFormStruct( 2, "V8X",{|x| AllTrim( x ) + "|" $ cV8X } )
		oStruV8Y	:= FwFormStruct( 2, "V8Y",{|x| AllTrim( x ) + "|" $ cV8Y } )
		oStruV8K	:= FwFormStruct( 2, "V8K",{|x| AllTrim( x ) + "|" $ cV8K } )
		oStruV8L	:= FwFormStruct( 2, "V8L",{|x| AllTrim( x ) + "|" $ cV8L } )
		oStruV8M	:= FwFormStruct( 2, "V8M",{|x| AllTrim( x ) + "|" $ cV8M } )
		oStruV8N	:= FwFormStruct( 2, "V8N",{|x| AllTrim( x ) + "|" $ cV8N } )
		oStruV8O	:= FwFormStruct( 2, "V8O",{|x| AllTrim( x ) + "|" $ cV8O } )
		oStruV8P	:= FwFormStruct( 2, "V8P",{|x| AllTrim( x ) + "|" $ cV8P } )
		oStruV8Q	:= FwFormStruct( 2, "V8Q",{|x| AllTrim( x ) + "|" $ cV8Q } )
		oStruV8S	:= FwFormStruct( 2, "V8S",{|x| AllTrim( x ) + "|" $ cV8S } )

	EndIf

	oView:AddField( 'VIEW_V7C', oStruV7C, 'MODEL_V7C' )
	oView:AddField( 'VIEW_V7C_PROTUL', oProtulV7C, 'MODEL_V7C' )

	//-------------------------- GRIDS ----------------------------------
	oView:AddGrid("VIEW_V7D", oStruV7D, "MODEL_V7D")
	oView:EnableTitleView("VIEW_V7D",STR0002)

	oView:AddGrid("VIEW_V7E", oStruV7E, "MODEL_V7E")
	oView:EnableTitleView("VIEW_V7E",STR0003) 

	oView:AddGrid("VIEW_V7F", oStruV7F, "MODEL_V7F")
	oView:EnableTitleView("VIEW_V7F",STR0004)

	oView:AddGrid("VIEW_V7G", oStruV7G, "MODEL_V7G")
	oView:EnableTitleView("VIEW_V7G",STR0005)

	If lSimpl0102 .OR. (lSimpl0103 .and. lDic0103)

		oView:AddGrid("VIEW_V8X", oStruV8X, "MODEL_V8X")
		oView:EnableTitleView("VIEW_V8X",STR0016)

		oView:AddGrid("VIEW_V8Y", oStruV8Y, "MODEL_V8Y")
		oView:EnableTitleView("VIEW_V8Y",STR0016)

		oView:AddGrid("VIEW_V8K", oStruV8K, "MODEL_V8K")
		oView:EnableTitleView("VIEW_V8K",STR0017)

		oView:AddGrid("VIEW_V8L", oStruV8L, "MODEL_V8L")
		oView:EnableTitleView("VIEW_V8L",STR0018)

		oView:AddGrid("VIEW_V8M", oStruV8M, "MODEL_V8M")
		oView:EnableTitleView("VIEW_V8M",STR0018)

		oView:AddGrid("VIEW_V8N", oStruV8N, "MODEL_V8N")
		oView:EnableTitleView("VIEW_V8N",STR0019)

		oView:AddGrid("VIEW_V8O", oStruV8O, "MODEL_V8O")
		oView:EnableTitleView("VIEW_V8O",STR0020)

		oView:AddGrid("VIEW_V8P", oStruV8P, "MODEL_V8P")
		oView:EnableTitleView("VIEW_V8P",STR0021)

		oView:AddGrid("VIEW_V8Q", oStruV8Q, "MODEL_V8Q")
		oView:EnableTitleView("VIEW_V8Q",STR0022)

		oView:AddGrid("VIEW_V8S", oStruV8S, "MODEL_V8S")
		oView:EnableTitleView("VIEW_V8S",STR0022)

	EndIf
	//---------------------------------------------------------------------

	//-------------------------- PAINÉIS ----------------------------------
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:CreateFolder( 'FOLDER_SUPERIOR' )
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0006 )//"Identificaç?o do Processo
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0023 )//"Identificaç?o do Trabalhador"
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA03', STR0007 )//"Informaç?o de Protocolo

	oView:CreateHorizontalBox( 'V7C_PAI'	  	 , 100,,, 'FOLDER_SUPERIOR', 'ABA01')
	oView:CreateHorizontalBox( 'V7C_V7D_FILHA'	 , 020,,, 'FOLDER_SUPERIOR', 'ABA02')
	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 080,,, 'FOLDER_SUPERIOR', 'ABA02')
	oView:CreateHorizontalBox( 'V7C_PROTUL'	  	 , 100,,, 'FOLDER_SUPERIOR', 'ABA03')

	//--------- Identificaç?o do Trabalhador ---------
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0008 ) //"Informaç?es da Contribuiç?es Sociais
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0009 ) //"Informaç?es de IRRF"

	oView:CreateHorizontalBox( 'V7C_V7D_V7E_FILHA'		, 050,,, 'FOLDER_PRINCIPAL', 'ABA01')
	oView:CreateHorizontalBox( 'V7C_V7D_V7E_V7F_FILHA'	, 050,,, 'FOLDER_PRINCIPAL', 'ABA01')

	If !lSimpl0102
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_FILHA'		, 100,,, 'FOLDER_PRINCIPAL', 'ABA02')
	EndIf

	If lSimpl0102 .Or. (lSimpl0103 .and. lDic0103)

		oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA03', STR0024 ) //"Informaç?es de IRRF Complementares"

		oView:CreateHorizontalBox( 'V7C_V7D_V7G_FILHA'		, 020,,, 'FOLDER_PRINCIPAL', 'ABA02')
		oView:CreateHorizontalBox( 'PAINEL_INFO_IRRF'	    , 080,,, 'FOLDER_PRINCIPAL', 'ABA02')
		oView:CreateHorizontalBox( 'PAINEL_INFO_RET'	    , 100,,, 'FOLDER_PRINCIPAL', 'ABA03')
		//------------------------------------------------

		//------------ Informaç?es de IRRF  ------------
		oView:CreateFolder( 'FOLDER_INFO_IRRF', 'PAINEL_INFO_IRRF' )
		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA01', STR0025 ) //	Identificaç?o dos advogados
		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA02', STR0026 ) // Informaç?es complementares de RRA
		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA03', STR0027 ) // Deduç?o do rendimento tributável relativa a dependentes
		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA04', STR0028 ) // Informaç?o dos beneficiários da pens?o alimentícia
		oView:AddSheet( 'FOLDER_INFO_IRRF', 'ABA05', STR0029 ) // Informaç?es de processos relacionados a n?o retenç?o de tributos ou a depósitos judiciais

		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8X_FILHA'				, 100,,, 'FOLDER_INFO_IRRF', 'ABA01')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8Y_FILHA'				, 050,,, 'FOLDER_INFO_IRRF', 'ABA02')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8Y_V8K_FILHA'			, 050,,, 'FOLDER_INFO_IRRF', 'ABA02')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8L_FILHA'				, 100,,, 'FOLDER_INFO_IRRF', 'ABA03')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8M_FILHA'				, 100,,, 'FOLDER_INFO_IRRF', 'ABA04')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8N_FILHA'				, 025,,, 'FOLDER_INFO_IRRF', 'ABA05')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8N_V8O_FILHA'			, 025,,, 'FOLDER_INFO_IRRF', 'ABA05')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8N_V8O_V8P_FILHA'		, 025,,, 'FOLDER_INFO_IRRF', 'ABA05')
		oView:CreateHorizontalBox( 'V7C_V7D_V7G_V8N_V8O_V8P_V8Q_FILHA'	, 025,,, 'FOLDER_INFO_IRRF', 'ABA05')
		//------------------------------------------------

		//------ Informaç?es de IRRF Complementares ------
		oView:CreateFolder( 'FOLDER_INFO_RET', 'PAINEL_INFO_RET' )
		oView:AddSheet( 'FOLDER_INFO_RET', 'ABA01', STR0030 )

		oView:CreateHorizontalBox( 'V7C_V7D_V8S_FILHA'					, 100,,, 'FOLDER_INFO_RET' , 'ABA01')
		//------------------------------------------------

	EndIf

	oView:SetOwnerView( 'VIEW_V7C', 'V7C_PAI' 							)
	oView:SetOwnerView( 'VIEW_V7C_PROTUL', 'V7C_PROTUL' 				)
	oView:SetOwnerView( 'VIEW_V7D', 'V7C_V7D_FILHA' 					)
	oView:SetOwnerView( 'VIEW_V7E', 'V7C_V7D_V7E_FILHA' 				)
	oView:SetOwnerView( 'VIEW_V7F', 'V7C_V7D_V7E_V7F_FILHA' 			)
	oView:SetOwnerView( 'VIEW_V7G', 'V7C_V7D_V7G_FILHA' 				)

	If lSimpl0102 .OR. (lSimpl0103 .and. lDic0103)

		oView:SetOwnerView( 'VIEW_V8X', 'V7C_V7D_V7G_V8X_FILHA' 			)
		oView:SetOwnerView( 'VIEW_V8Y', 'V7C_V7D_V7G_V8Y_FILHA' 			)
		oView:SetOwnerView( 'VIEW_V8K', 'V7C_V7D_V7G_V8Y_V8K_FILHA' 		)
		oView:SetOwnerView( 'VIEW_V8L', 'V7C_V7D_V7G_V8L_FILHA' 			)
		oView:SetOwnerView( 'VIEW_V8M', 'V7C_V7D_V7G_V8M_FILHA' 			)
		oView:SetOwnerView( 'VIEW_V8N', 'V7C_V7D_V7G_V8N_FILHA' 			)
		oView:SetOwnerView( 'VIEW_V8O', 'V7C_V7D_V7G_V8N_V8O_FILHA'			)
		oView:SetOwnerView( 'VIEW_V8P', 'V7C_V7D_V7G_V8N_V8O_V8P_FILHA'		)
		oView:SetOwnerView( 'VIEW_V8Q', 'V7C_V7D_V7G_V8N_V8O_V8P_V8Q_FILHA'	)
		oView:SetOwnerView( 'VIEW_V8S', 'V7C_V7D_V8S_FILHA'					)

		oView:AddIncrementField('VIEW_V8X', 'V8X_CHAVE')
		oView:AddIncrementField('VIEW_V8Y', 'V8Y_CHAVE')
		oView:AddIncrementField('VIEW_V8P', 'V8P_CHAVE')

	EndIf
	//-------------------------- PAINÉIS ----------------------------------

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Alexandre de Lima/JR GOMES
@Since 10/10/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local aDataModel as Array
	Local aGravaV7C  as Array
	Local aGravaV7D  as Array
	Local aGravaV7E  as Array
	Local aGravaV7F  as Array
	Local aGravaV7G  as Array
	Local aGravaV8K  as Array
	Local aGravaV8L  as Array
	Local aGravaV8M  as Array
	Local aGravaV8N  as Array
	Local aGravaV8O  as Array
	Local aGravaV8P  as Array
	Local aGravaV8Q  as Array
	Local aGravaV8S  as Array
	Local aGravaV8X  as Array
	Local aGravaV8Y  as Array
	Local cChvRegAnt as character
	Local cEvento    as character
	Local cLayout    as character
	Local cLogOpe    as character
	Local cLogOpeAnt as character
	Local cProtocolo as character
	Local cVerAnt    as character
	Local cVersao    as character
	Local cVerLayout as character
	Local lRetorno   as logical
	Local nI         as numeric
	Local nlI        as Numeric
	Local nlV7D      as Numeric
	Local nOperation as numeric
	Local nV7D       as Numeric
	Local nV7DLine   as Numeric
	Local nV7E       as Numeric
	Local nV7ELine   as Numeric
	Local nV7F       as Numeric
	Local nV7FLine   as Numeric
	Local nV7G       as Numeric
	Local nV7GLine   as Numeric
	Local nV8K       as Numeric
	Local nV8KLine   as Numeric
	Local nV8L       as Numeric
	Local nV8LLine   as Numeric
	Local nV8M       as Numeric
	Local nV8MLine   as Numeric
	Local nV8N       as Numeric
	Local nV8NLine   as Numeric
	Local nV8O       as Numeric
	Local nV8OLine   as Numeric
	Local nV8P       as Numeric
	Local nV8PLine   as Numeric
	Local nV8Q       as Numeric
	Local nV8QLine   as Numeric
	Local nV8S       as Numeric
	Local nV8SLine   as Numeric
	Local nV8X       as Numeric
	Local nV8XLine   as Numeric
	Local nV8Y       as Numeric
	Local nV8YLine   as Numeric
	Local oModelV7C  as Object
	Local oModelV7D  as Object
	Local oModelV7E  as Object
	Local oModelV7F  as Object
	Local oModelV7G  as Object
	Local oModelV8K  as Object
	Local oModelV8L  as Object
	Local oModelV8M  as Object
	Local oModelV8N  as Object
	Local oModelV8O  as Object
	Local oModelV8P  as Object
	Local oModelV8Q  as Object
	Local oModelV8S  as Object
	Local oModelV8X  as Object
	Local oModelV8Y  as Object

	aDataModel := {}
	aGravaV7C  := {}
	aGravaV7D  := {}
	aGravaV7E  := {}
	aGravaV7F  := {}
	aGravaV7G  := {}
	aGravaV8K  := {}
	aGravaV8L  := {}
	aGravaV8M  := {}
	aGravaV8N  := {}
	aGravaV8O  := {}
	aGravaV8P  := {}
	aGravaV8Q  := {}
	aGravaV8S  := {}
	aGravaV8X  := {}
	aGravaV8Y  := {}
	cChvRegAnt := ""
	cEvento    := ""
	cLayout	   := Iif( FindFunction('getVerLayout'), getVerLayout(), SuperGetMV("MV_TAFVLES"))
	cLogOpe    := ""
	cLogOpeAnt := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	cVerLayout := ""
	lRetorno   := .T.
	nI         := 0
	nlI        := 0
	nlV7D      := 0
	nOperation := oModel:GetOperation()
	nV7D       := 0
	nV7DLine   := 0
	nV7E       := 0
	nV7ELine   := 0
	nV7F       := 0
	nV7FLine   := 0
	nV7G       := 0
	nV7GLine   := 0
	nV8K       := 0
	nV8KLine   := 0
	nV8L       := 0
	nV8LLine   := 0
	nV8M       := 0
	nV8MLine   := 0
	nV8N       := 0
	nV8NLine   := 0
	nV8O       := 0
	nV8OLine   := 0
	nV8P       := 0
	nV8PLine   := 0
	nV8Q       := 0
	nV8QLine   := 0
	nV8S       := 0
	nV8SLine   := 0
	nV8X       := 0
	nV8XLine   := 0
	nV8Y       := 0
	nV8YLine   := 0
	oModelV7C  := Nil
	oModelV7D  := Nil
	oModelV7E  := Nil
	oModelV7F  := Nil
	oModelV7G  := Nil
	oModelV8K  := Nil
	oModelV8L  := Nil
	oModelV8M  := Nil
	oModelV8N  := Nil
	oModelV8O  := Nil
	oModelV8P  := Nil
	oModelV8Q  := Nil
	oModelV8S  := Nil
	oModelV8X  := Nil
	oModelV8Y  := Nil

	SetlDic0103()

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
		
			TafAjustID("V7C", oModel)

			oModelV7C := oModel:GetModel( "MODEL_V7C" )

			oModel:LoadValue( "MODEL_V7C", "V7C_VERSAO", xFunGetVer() )

			If lSimpl0103 .and. lDic0103
				oModel:LoadValue( "MODEL_V7C", "V7C_LAYOUT", "S_01_03_00" )
			Else
				oModel:LoadValue( "MODEL_V7C", "V7C_LAYOUT", cLayout )
			EndIf

			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '2', '' )
			
			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V7C->( DbSetOrder( 2 ) )
			If V7C->( MsSeek( xFilial( 'V7C' ) + oModel:GetValue("MODEL_V7C", "V7C_ID") + '1' ) )
			
				If V7C->V7C_STATUS $ ( "4" )
		
					oModelV7C := oModel:GetModel( "MODEL_V7C" )
					oModelV7D := oModel:GetModel( "MODEL_V7D" )
					oModelV7E := oModel:GetModel( 'MODEL_V7E' )
					oModelV7F := oModel:GetModel( 'MODEL_V7F' )
					oModelV7G := oModel:GetModel( 'MODEL_V7G' )
					oModelV8N := oModel:GetModel( 'MODEL_V8N' )
					oModelV8K := oModel:GetModel( 'MODEL_V8K' )
					oModelV8L := oModel:GetModel( 'MODEL_V8L' )
					oModelV8Y := oModel:GetModel( 'MODEL_V8Y' )
					oModelV8X := oModel:GetModel( 'MODEL_V8X' )
					oModelV8S := oModel:GetModel( 'MODEL_V8S' )
					oModelV8M := oModel:GetModel( 'MODEL_V8M' )
					oModelV8O := oModel:GetModel( 'MODEL_V8O' )
					oModelV8P := oModel:GetModel( 'MODEL_V8P' )
					oModelV8Q := oModel:GetModel( 'MODEL_V8Q' )
				    
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//?Busco a versao anterior do registro para gravacao do rastro?
					//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					cVerAnt    := oModelV7C:GetValue( "V7C_VERSAO" )
					cProtocolo := oModelV7C:GetValue( "V7C_PROTUL" )
					cEvento	   := oModelV7C:GetValue( "V7C_EVENTO" )
					cLogOpeAnt := oModelV7C:GetValue( "V7C_LOGOPE" )
					cVerLayout := oModelV7C:GetValue( "V7C_LAYOUT" )

					For nI := 1 to Len( oModelV7C:aDataModel[ 1 ] )
						aAdd( aGravaV7C, { oModelV7C:aDataModel[ 1, nI, 1 ], oModelV7C:aDataModel[ 1, nI, 2 ] } )
					Next nI
					
					V7D->(DBSetOrder( 2 ) )

					If lSimpl0103 .and. lDic0103
						cIndex := V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU + V7C_IDESEQ)
					Else
						cIndex := V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU )
					EndIf 

					If V7D->(MsSeek(xFilial("V7D")+ cIndex ) )
						
						For nV7D := 1 To oModel:GetModel( 'MODEL_V7D' ):Length()
							
							oModel:GetModel( 'MODEL_V7D' ):GoLine(nV7D)

							If !oModel:GetModel( 'MODEL_V7D' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7D' ):IsEmpty() 	
								aAdd (aGravaV7D ,{oModelV7D:GetValue('V7D_CPFTRA')})
							EndIf

								For nV7E := 1 To oModel:GetModel( 'MODEL_V7E' ):Length() 

									oModel:GetModel( 'MODEL_V7E' ):GoLine(nV7E)

									If !oModel:GetModel( 'MODEL_V7E' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7E' ):IsEmpty()

										If !lSimpl0102		

											aAdd (aGravaV7E ,{	oModelV7D:GetValue('V7D_CPFTRA')	,;
																oModelV7E:GetValue('V7E_PERREF')	,;
																oModelV7E:GetValue('V7E_VRMEN')		,;
																oModelV7E:GetValue('V7E_VRCP')		,;
																oModelV7E:GetValue('V7E_VERREN')	,;
																oModelV7E:GetValue('V7E_VRIRRF')	})

										Else

											aAdd (aGravaV7E ,{	oModelV7D:GetValue('V7D_CPFTRA')	,;
																oModelV7E:GetValue('V7E_PERREF')	,;
																oModelV7E:GetValue('V7E_VRMEN')		,;
																oModelV7E:GetValue('V7E_VRCP')		})


										EndIf

									EndIf

									For nV7F := 1 To oModel:GetModel( 'MODEL_V7F' ):Length()

										oModel:GetModel( 'MODEL_V7F' ):GoLine(nV7F)

										If !oModel:GetModel( 'MODEL_V7F' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V7F' ):IsEmpty()	

											aAdd (aGravaV7F ,{	oModelV7D:GetValue('V7D_CPFTRA'),;
																oModelV7E:GetValue('V7E_PERREF'),;
																oModelV7F:GetValue('V7F_IDCODR'),;
																oModelV7F:GetValue('V7F_VRCR') })
										EndIf
									Next
								
								Next
							
								For nV7G := 1 To oModel:GetModel( 'MODEL_V7G' ):Length() 

									oModel:GetModel( 'MODEL_V7G' ):GoLine(nV7G)

									If !oModel:GetModel( 'MODEL_V7G' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7G' ):IsEmpty()	

										If lSimpl0103 .and. lDic0103
											aAdd (aGravaV7G ,{ 	oModelV7D:GetValue('V7D_CPFTRA'),;	
																oModelV7G:GetValue('V7G_TPCR'),;
																oModelV7G:GetValue('V7G_VRCR'),;
																oModelV7G:GetValue('V7G_VRCR13')})
										Else 
											aAdd (aGravaV7G ,{ 	oModelV7D:GetValue('V7D_CPFTRA'),;	
																oModelV7G:GetValue('V7G_TPCR'),;
																oModelV7G:GetValue('V7G_VRCR')})
										EndIf 

									EndIf

									If lSimpl0102 .Or. (lSimpl0103 .and. lDic0103)

										For nV8X := 1 to oModel:GetModel( 'MODEL_V8X' ):Length()

											oModel:GetModel( 'MODEL_V8X' ):GoLine(nV8X)

											If !oModel:GetModel( 'MODEL_V8X' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V8X' ):IsEmpty()

												If lSimpl0103 .and. lDic0103
													aAdd(aGravaV8X, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
																		oModelV8X:GetValue('V8X_VLRTRI'),;
																		oModelV8X:GetValue('V8X_VLRT13'),;
																		oModelV8X:GetValue('V8X_VLRIMG'),;
																		oModelV8X:GetValue('V8X_VLRI65'),;
																		oModelV8X:GetValue('V8X_VLJRMO'),;
																		oModelV8X:GetValue('V8X_VLRINT'),;
																		oModelV8X:GetValue('V8X_DCRINT'),;
																		oModelV8X:GetValue('V8X_VLPRVO'),;
																		oModelV8X:GetValue('V8X_IMG13') ,;
																		oModelV8X:GetValue('V8X_I65DEC'),;
																		oModelV8X:GetValue('V8X_MOR13') ,;
																		oModelV8X:GetValue('V8X_PREV13'),;
																		oModelV8X:GetValue('V8X_VLRDIA'),;
																		oModelV8X:GetValue('V8X_VLRAJU'),;
																		oModelV8X:GetValue('V8X_VLRCON'),;
																		oModelV8X:GetValue('V8X_VLRABN'),;
																		oModelV8X:GetValue('V8X_VLMORD')})

												Else 
													aAdd(aGravaV8X, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
																		oModelV8X:GetValue('V8X_VLRTRI'),;
																		oModelV8X:GetValue('V8X_VLRT13'),;
																		oModelV8X:GetValue('V8X_VLRIMG'),;
																		oModelV8X:GetValue('V8X_VLRI65'),;
																		oModelV8X:GetValue('V8X_VLJRMO'),;
																		oModelV8X:GetValue('V8X_VLRINT'),;
																		oModelV8X:GetValue('V8X_DCRINT'),;
																		oModelV8X:GetValue('V8X_VLPRVO')})

												EndIf 
											EndIf

										Next nV8X

											For nV8Y := 1 to oModel:GetModel( 'MODEL_V8Y' ):Length()

												oModel:GetModel( 'MODEL_V8Y' ):GoLine(nV8Y)

												If !oModel:GetModel( 'MODEL_V8Y' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V8Y' ):IsEmpty()

													aAdd(aGravaV8Y, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
																		oModelV8Y:GetValue('V8Y_DESCRA'),;
																		oModelV8Y:GetValue('V8Y_QTMRRA'),;
																		oModelV8Y:GetValue('V8Y_VLRCUS'),;
																		oModelV8Y:GetValue('V8Y_VLRADV')})
												EndIf

												For nV8K := 1 to oModel:GetModel( 'MODEL_V8K' ):Length()
													oModel:GetModel( 'MODEL_V8K' ):GoLine(nV8K)

													If !oModel:GetModel( 'MODEL_V8K' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8K' ):IsEmpty()

														aAdd(aGravaV8K , { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
																			oModelV8K:GetValue('V8K_TPINSC'),;
																			oModelV8K:GetValue('V8K_NRINSC'),;
																			oModelV8K:GetValue('V8K_VLRADV')})

													EndIf

												Next nV8K

											Next nV8Y

											For nV8L := 1 to oModel:GetModel( 'MODEL_V8L' ):Length()
												oModel:GetModel( 'MODEL_V8L' ):GoLine(nV8L)

												If !oModel:GetModel( 'MODEL_V8L' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8L' ):IsEmpty()

													aAdd(aGravaV8L, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
																		oModelV8L:GetValue('V8L_TPREND'),;
																		oModelV8L:GetValue('V8L_CPFDEP'),;
																		oModelV8L:GetValue('V8L_VLRDED')})

												EndIf

											Next nV8L

											For nV8M := 1 to oModel:GetModel( 'MODEL_V8M' ):Length()
												oModel:GetModel( 'MODEL_V8M' ):GoLine(nV8M)

												If !oModel:GetModel( 'MODEL_V8M' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8M' ):IsEmpty()

													aAdd(aGravaV8M, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
																		oModelV8M:GetValue('V8M_TPREND'),;
																		oModelV8M:GetValue('V8M_CPFDEP'),;
																		oModelV8M:GetValue('V8M_VLPENS')})

												EndIf

											Next nV8M

											For nV8N := 1 to oModel:GetModel( 'MODEL_V8N' ):Length()

												oModel:GetModel( 'MODEL_V8N' ):GoLine(nV8N)

												If !oModel:GetModel( 'MODEL_V8N' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8N' ):IsEmpty()
													aAdd(aGravaV8N, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
																		oModelV8N:GetValue('V8N_TPPRCR'),;
																		oModelV8N:GetValue('V8N_NRPRCR'),;
																		oModelV8N:GetValue('V8N_CODSUP')})
												EndIf

												For nV8O := 1 to oModel:GetModel( 'MODEL_V8O' ):Length()

													oModel:GetModel( 'MODEL_V8O' ):GoLine(nV8O)

													If !oModel:GetModel( 'MODEL_V8O' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8O' ):IsEmpty()

														aAdd(aGravaV8O, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR') + oModelV8N:GetValue('V8N_TPPRCR') + oModelV8N:GetValue('V8N_NRPRCR') + oModelV8N:GetValue('V8N_CODSUP'),;
																			oModelV8O:GetValue('V8O_INDAPU'),;
																			oModelV8O:GetValue('V8O_VLNRET'),;
																			oModelV8O:GetValue('V8O_VLDEPJ'),;
																			oModelV8O:GetValue('V8O_VLDEPJ'),;
																			oModelV8O:GetValue('V8O_VLCPAA'),;
																			oModelV8O:GetValue('V8O_VLRSUS')})

													EndIf

													For nV8P := 1 to oModel:GetModel( 'MODEL_V8P' ):Length()

														oModel:GetModel( 'MODEL_V8P' ):GoLine(nV8P)

														If !oModel:GetModel( 'MODEL_V8P' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8P' ):IsEmpty()

															aAdd(aGravaV8P, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR') + oModelV8N:GetValue('V8N_TPPRCR') + oModelV8N:GetValue('V8N_NRPRCR') + oModelV8N:GetValue('V8N_CODSUP') + oModelV8O:GetValue('V8O_INDAPU'),;
																				oModelV8P:GetValue('V8P_TPDEDU'),;
																				oModelV8P:GetValue('V8P_VLSUSP'),;
																				oModelV8P:GetValue('V8P_CHAVE') })		

														EndIf

														For nV8Q := 1 to oModel:GetModel( 'MODEL_V8Q' ):Length()

															oModel:GetModel( 'MODEL_V8Q' ):GoLine(nV8Q)

															If !oModel:GetModel( 'MODEL_V8Q' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8Q' ):IsEmpty()

																aAdd(aGravaV8Q, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR') + oModelV8N:GetValue('V8N_TPPRCR') + oModelV8N:GetValue('V8N_NRPRCR') + oModelV8N:GetValue('V8N_CODSUP') + oModelV8O:GetValue('V8O_INDAPU') + oModelV8P:GetValue('V8P_CHAVE'),;
																					oModelV8Q:GetValue('V8Q_CPFDEP'),;
																					oModelV8Q:GetValue('V8Q_VLDEPS'),;
																					oModelV8Q:GetValue('V8Q_CHAVE')})	

															EndIf 

														Next nV8Q

													Next nV8P

												Next nV8O

											Next nV8N

									EndIf

								Next nV7G

							If lSimpl0102 .And. TafColumnPos( "V8X_VLRTRI" )

								For nV8S := 1 to oModel:GetModel( 'MODEL_V8S' ):Length()
									oModel:GetModel( 'MODEL_V8S' ):GoLine(nV8S)

									If !oModel:GetModel( 'MODEL_V8S' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8S' ):IsEmpty()

										aAdd(aGravaV8S , { 	oModelV7D:GetValue( 'V7D_CPFTRA'),;
															oModelV8S:GetValue( 'V8S_DTLAUD'),;
															oModelV8S:GetValue( 'V8S_CPFDEP'),;
															oModelV8S:GetValue( 'V8S_DTNASC'),;
															oModelV8S:GetValue( 'V8S_NOME'	),;
															oModelV8S:GetValue( 'V8S_DEPIR'	),;
															oModelV8S:GetValue( 'V8S_TPDEP'	),;
															oModelV8S:GetValue( 'V8S_DESCDE')})

									EndIf

								Next nV8S

							EndIf

						Next

					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//?Seto o campo como Inativo e gravo a versao do novo registro?
					//?no registro anterior                                       ?
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					FAltRegAnt( "V7C", "2" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//?Neste momento eu preciso setar a operacao do model?
					//?como Inclusao                                     ?
					//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//?Neste momento eu realizo a inclusao do novo registro ja?
					//?contemplando as informacoes alteradas pelo usuario     ?
					//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					For nI := 1 to Len( aGravaV7C )
						oModel:LoadValue( "MODEL_V7C", aGravaV7C[ nI, 1 ], aGravaV7C[ nI, 2 ] )
					Next nI

					//Necessário Abaixo do For Nao Retirar
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '' , cLogOpeAnt )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//?Busco a versao que sera gravada?
					//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					oModel:LoadValue( "MODEL_V7C", "V7C_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_V7C", "V7C_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_V7C", "V7C_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_V7C", "V7C_PROTUL", "" )
					oModel:LoadValue( "MODEL_V7C", "V7C_LAYOUT", cVerLayout )
			
					
					// Tratamento para limpar o ID unico do xml
					oModel:LoadValue( 'MODEL_V7C', 'V7C_XMLID', "" )
					
					nV7DLine := 1

					For nV7D := 1 To Len( aGravaV7D )

						oModel:GetModel( 'MODEL_V7D' ):LVALID	:= .T.

						If nV7DLine > 1
							oModel:GetModel( 'MODEL_V7D' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V7D", "V7D_CPFTRA",	aGravaV7D[nV7D][1] )
						
						nV7ELine := 1

						For nV7E := 1 to Len( aGravaV7E )

							If  aGravaV7E[nV7E][1] == aGravaV7D[nV7D][1]

								oModel:GetModel( 'MODEL_V7E' ):LVALID := .T.

								If nV7ELine > 1
									oModel:GetModel( "MODEL_V7E" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V7E", "V7E_PERREF"	, aGravaV7E[nV7E][2] )
								oModel:LoadValue( "MODEL_V7E", "V7E_VRMEN"	, aGravaV7E[nV7E][3] )
								oModel:LoadValue( "MODEL_V7E", "V7E_VRCP"	, aGravaV7E[nV7E][4] )

								If !lSimpl0102

									oModel:LoadValue( "MODEL_V7E", "V7E_VERREN"	, aGravaV7E[nV7E][5] )
									oModel:LoadValue( "MODEL_V7E", "V7E_VRIRRF"	, aGravaV7E[nV7E][6] )

								EndIf

								nV7FLine := 1

								For nV7F := 1 to Len( aGravaV7F )

									If  aGravaV7F[nV7F][1] + aGravaV7F[nV7F][2] == aGravaV7E[nV7E][1] + aGravaV7E[nV7E][2] 

										oModel:GetModel( 'MODEL_V7F' ):LVALID := .T.

										If nV7FLine > 1
											oModel:GetModel( "MODEL_V7F" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V7F", "V7F_IDCODR"	, aGravaV7F[nV7F][3] )
										oModel:LoadValue( "MODEL_V7F", "V7F_VRCR"	, aGravaV7F[nV7F][4] )

										nV7FLine++

									EndIf
								Next

								nV7ELine++

							EndIf
						Next

						nV7GLine := 1

						For nV7G := 1 to Len( aGravaV7G )

							If  aGravaV7G[nV7G][1] == aGravaV7D[nV7D][1]

								oModel:GetModel( 'MODEL_V7G' ):LVALID := .T.

								If nV7GLine > 1
									oModel:GetModel( "MODEL_V7G" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V7G", "V7G_TPCR"	, aGravaV7G[nV7G][2] )
								oModel:LoadValue( "MODEL_V7G", "V7G_VRCR"	, aGravaV7G[nV7G][3] )

								If lSimpl0103 .and. lDic0103
									oModel:LoadValue( "MODEL_V7G", "V7G_VRCR13"	, aGravaV7G[nV7G][4] )
								EndIf 

								If lSimpl0102 .Or. (lSimpl0103 .and. lDic0103)

									nV8XLine := 1

									For nV8X := 1 to Len( aGravaV8X )
										
										If aGravaV8X[nV8X][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

											oModel:GetModel( 'MODEL_V8X' ):LVALID := .T.

											oModel:LoadValue( "MODEL_V8X", "V8X_VLRTRI"	, aGravaV8X[nV8X][2] )
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRT13"	, aGravaV8X[nV8X][3] )
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRIMG"	, aGravaV8X[nV8X][4] )
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRI65"	, aGravaV8X[nV8X][5] )
											oModel:LoadValue( "MODEL_V8X", "V8X_VLJRMO"	, aGravaV8X[nV8X][6] )
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRINT"	, aGravaV8X[nV8X][7] )
											oModel:LoadValue( "MODEL_V8X", "V8X_DCRINT"	, aGravaV8X[nV8X][8] )
											oModel:LoadValue( "MODEL_V8X", "V8X_VLPRVO"	, aGravaV8X[nV8X][9] )

											If lSimpl0103 .and. lDic0103
												oModel:LoadValue( "MODEL_V8X", "V8X_IMG13"	, aGravaV8X[nV8X][10] )
												oModel:LoadValue( "MODEL_V8X", "V8X_I65DEC"	, aGravaV8X[nV8X][11] )
												oModel:LoadValue( "MODEL_V8X", "V8X_MOR13"	, aGravaV8X[nV8X][12] )
												oModel:LoadValue( "MODEL_V8X", "V8X_PREV13"	, aGravaV8X[nV8X][13] )
												oModel:LoadValue( "MODEL_V8X", "V8X_VLRDIA"	, aGravaV8X[nV8X][14] )
												oModel:LoadValue( "MODEL_V8X", "V8X_VLRAJU"	, aGravaV8X[nV8X][15] )
												oModel:LoadValue( "MODEL_V8X", "V8X_VLRCON"	, aGravaV8X[nV8X][16] )
												oModel:LoadValue( "MODEL_V8X", "V8X_VLRABN"	, aGravaV8X[nV8X][17] )
												oModel:LoadValue( "MODEL_V8X", "V8X_VLMORD"	, aGravaV8X[nV8X][18] )
											EndIf 

											nV8XLine++

										EndIf
									Next

									nV8YLine := 1

									For nV8Y := 1 to Len( aGravaV8Y )
										
										If aGravaV8Y[nV8Y][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

											oModel:GetModel( 'MODEL_V8Y' ):LVALID := .T.

											oModel:LoadValue( "MODEL_V8Y", "V8Y_DESCRA"	, aGravaV8Y[nV8Y][2] )
											oModel:LoadValue( "MODEL_V8Y", "V8Y_QTMRRA"	, aGravaV8Y[nV8Y][3] )
											oModel:LoadValue( "MODEL_V8Y", "V8Y_VLRCUS"	, aGravaV8Y[nV8Y][4] )
											oModel:LoadValue( "MODEL_V8Y", "V8Y_VLRADV"	, aGravaV8Y[nV8Y][5] )							

											nV8KLine := 1

											For nV8K := 1 to Len ( aGravaV8K )

												If aGravaV8K[nV8K][1] == aGravaV8Y[nV8Y][1]

													oModel:GetModel( 'MODEL_V8K' ):LVALID := .T.

													If nV8KLine > 1
														oModel:GetModel( "MODEL_V8K" ):AddLine()
													EndIf

													oModel:LoadValue( "MODEL_V8K", "V8K_TPINSC"	, aGravaV8K[nV8K][2] )
													oModel:LoadValue( "MODEL_V8K", "V8K_NRINSC"	, aGravaV8K[nV8K][3] )
													oModel:LoadValue( "MODEL_V8K", "V8K_VLRADV"	, aGravaV8K[nV8K][4] )

													nV8KLine++

												EndIf

											Next											
											nV8YLine++

										EndIf

									Next

									nV8LLine := 1

									For nV8L := 1 to Len ( aGravaV8L )

										If aGravaV8L[nV8L][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

											oModel:GetModel( 'MODEL_V8L' ):LVALID := .T.

											If nV8LLine > 1
												oModel:GetModel( "MODEL_V8L" ):AddLine()
											EndIf

											oModel:LoadValue( "MODEL_V8L", "V8L_TPREND"	, aGravaV8L[nV8L][2] )
											oModel:LoadValue( "MODEL_V8L", "V8L_CPFDEP"	, aGravaV8L[nV8L][3] )
											oModel:LoadValue( "MODEL_V8L", "V8L_VLRDED"	, aGravaV8L[nV8L][4] )

											nV8LLine++

										EndIf

									Next

									nV8MLine := 1

									For nV8M := 1 to Len ( aGravaV8M )

										If aGravaV8M[nV8M][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

											oModel:GetModel( 'MODEL_V8M' ):LVALID := .T.

											If nV8MLine > 1
												oModel:GetModel( "MODEL_V8M" ):AddLine()
											EndIf

											oModel:LoadValue( "MODEL_V8M", "V8M_TPREND"	, aGravaV8M[nV8M][2] )
											oModel:LoadValue( "MODEL_V8M", "V8M_CPFDEP"	, aGravaV8M[nV8M][3] )
											oModel:LoadValue( "MODEL_V8M", "V8M_VLPENS"	, aGravaV8M[nV8M][4] )

											nV8MLine++

										EndIf

									Next

									nV8NLine := 1

									For nV8N := 1 to Len ( aGravaV8N )
									
										If aGravaV8N[nV8N][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]
									
											oModel:GetModel( 'MODEL_V8N' ):LVALID := .T.
									
											If nV8NLine > 1
												oModel:GetModel( "MODEL_V8N" ):AddLine()
											EndIf
									
											oModel:LoadValue( "MODEL_V8N", "V8N_TPPRCR"	, aGravaV8N[nV8N][2] )
											oModel:LoadValue( "MODEL_V8N", "V8N_NRPRCR"	, aGravaV8N[nV8N][3] )
											oModel:LoadValue( "MODEL_V8N", "V8N_CODSUP"	, aGravaV8N[nV8N][4] )
											
											nV8OLine := 1

											For nV8O := 1 to Len ( aGravaV8O )
									
												If aGravaV8O[nV8O][1] == aGravaV8N[nV8N][1] + aGravaV8N[nV8N][2] + aGravaV8N[nV8N][3] + aGravaV8N[nV8N][4]
									
													oModel:GetModel( 'MODEL_V8O' ):LVALID := .T.
									
													If nV8OLine > 1
														oModel:GetModel( "MODEL_V8O" ):AddLine()
													EndIf
									
													oModel:LoadValue( "MODEL_V8O", "V8O_INDAPU"	, aGravaV8O[nV8O][2] )
													oModel:LoadValue( "MODEL_V8O", "V8O_VLNRET"	, aGravaV8O[nV8O][3] )
													oModel:LoadValue( "MODEL_V8O", "V8O_VLDEPJ"	, aGravaV8O[nV8O][4] )
													oModel:LoadValue( "MODEL_V8O", "V8O_VLCPAC"	, aGravaV8O[nV8O][5] )
													oModel:LoadValue( "MODEL_V8O", "V8O_VLCPAA"	, aGravaV8O[nV8O][6] )
													oModel:LoadValue( "MODEL_V8O", "V8O_VLRSUS"	, aGravaV8O[nV8O][7] )
													
													nV8PLine := 1

													For nV8P := 1 to Len ( aGravaV8P )
									
														If aGravaV8P[nV8P][1] == aGravaV8O[nV8O][1] + aGravaV8O[nV8O][2]
									
															oModel:GetModel( 'MODEL_V8P' ):LVALID := .T.
									
															If nV8PLine > 1
																oModel:GetModel( "MODEL_V8P" ):AddLine()
															EndIf
									
															oModel:LoadValue( "MODEL_V8P", "V8P_TPDEDU"	, aGravaV8P[nV8P][2] )
															oModel:LoadValue( "MODEL_V8P", "V8P_VLSUSP"	, aGravaV8P[nV8P][3] )
									                        oModel:LoadValue( "MODEL_V8P", "V8P_CHAVE"	, aGravaV8P[nV8P][4] )

															nV8QLine := 1

															For nV8Q := 1 to Len ( aGravaV8Q )
									
																If aGravaV8Q[nV8Q][1] == aGravaV8P[nV8P][1] + aGravaV8P[nV8P][4]
									
																	oModel:GetModel( 'MODEL_V8Q' ):LVALID := .T.
									
																	If nV8QLine > 1
																		oModel:GetModel( "MODEL_V8Q"):AddLine()
																	EndIf
									
																	oModel:LoadValue( "MODEL_V8Q", "V8Q_CPFDEP"	, aGravaV8Q[nV8Q][2] )
																	oModel:LoadValue( "MODEL_V8Q", "V8Q_VLDEPS"	, aGravaV8Q[nV8Q][3] )
																	oModel:LoadValue( "MODEL_V8Q", "V8Q_CHAVE"	, aGravaV8Q[nV8Q][4] )

																	nV8QLine++

																EndIf
															Next

															nV8PLine++

														EndIf
													Next	

													nV8OLine++

												EndIf
											Next	

											nV8NLine++

										EndIf									
									Next
								EndIf

								nV7GLine++

							EndIf
						Next

						If lSimpl0102 .And. TafColumnPos( "V8X_VLRTRI" )

							nV8SLine := 1
							For nV8S := 1 to Len( aGravaV8S )

								If  aGravaV8S[nV8S][1] == aGravaV7D[nV7D][1]

									oModel:GetModel( 'MODEL_V8S' ):LVALID := .T.

									If nV8SLine > 1
										oModel:GetModel( "MODEL_V8S" ):AddLine()
									EndIf

									oModel:LoadValue( "MODEL_V8S", "V8S_DTLAUD"	, aGravaV8S[nV8S][2] )
									oModel:LoadValue( "MODEL_V8S", "V8S_CPFDEP"	, aGravaV8S[nV8S][3] )
									oModel:LoadValue( "MODEL_V8S", "V8S_DTNASC"	, aGravaV8S[nV8S][4] )
									oModel:LoadValue( "MODEL_V8S", "V8S_NOME"	, aGravaV8S[nV8S][5] )
									oModel:LoadValue( "MODEL_V8S", "V8S_DEPIR"	, aGravaV8S[nV8S][6] )
									oModel:LoadValue( "MODEL_V8S", "V8S_TPDEP"	, aGravaV8S[nV8S][7] )
									oModel:LoadValue( "MODEL_V8S", "V8S_DESCDE"	, aGravaV8S[nV8S][8] )

									nV8SLine++

								EndIf
							Next

						EndIf

						nV7DLine++

					Next					

					oModel:LoadValue( "MODEL_V7C", "V7C_EVENTO", "A" )
					FwFormCommit( oModel )
					TAFAltStat( 'V7C', " " )

				Else

					cLogOpeAnt := V7C->V7C_LOGOPE
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '' , cLogOpeAnt )
					FwFormCommit( oModel )
					TAFAltStat( 'V7C', " " )
				
				EndIf
			EndIf
		
		ElseIf nOperation == MODEL_OPERATION_DELETE
		
			cChvRegAnt := V7C->(V7C_ID + V7C_VERANT)
			TAFAltStat( 'V7C', " " )
			FwFormCommit(oModel)

			If V7C->V7C_EVENTO == "A" .OR. V7C->V7C_EVENTO == "E"
				TAFRastro( 'V7C', 1, cChvRegAnt, .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
		
		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusao do evento

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function chamada pelo TafIntegraESocial

@Return .T.

@Author Alexandre de Lima/JR GOMES
@Since 18/10/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local aDataModel as array
	Local aGrava     as numeric
	Local aGravaV7C  as array
	Local aGravaV7D  as array
	Local aGravaV7E  as array
	Local aGravaV7F  as array
	Local aGravaV7G  as array
	Local aGravaV8K  as array
	Local aGravaV8L  as array
	Local aGravaV8M  as array
	Local aGravaV8N  as array
	Local aGravaV8O  as array
	Local aGravaV8P  as array
	Local aGravaV8Q  as array
	Local aGravaV8S  as array
	Local aGravaV8X  as array
	Local aGravaV8Y  as array
	Local cEvento    as character
	Local cProtocolo as character
	Local cVerAnt    as character
	Local cVersao    as character
	Local cIndex     as character
	Local nI         as numeric
	Local nV7C       as numeric
	Local nV7D       as numeric
	Local nV7DLine   as numeric
	Local nV7E       as numeric
	Local nV7ELine   as numeric
	Local nV7F       as numeric
	Local nV7FLine   as numeric
	Local nV7G       as numeric
	Local nV7GLine   as numeric
	Local nV8K       as numeric
	Local nV8KLine   as numeric
	Local nV8L       as numeric
	Local nV8LLine   as numeric
	Local nV8M       as numeric
	Local nV8MLine   as numeric
	Local nV8N       as numeric
	Local nV8NLine   as numeric
	Local nV8O       as numeric
	Local nV8OLine   as numeric
	Local nV8P       as numeric
	Local nV8PLine   as numeric
	Local nV8Q       as numeric
	Local nV8QLine   as numeric
	Local nV8S       as numeric
	Local nV8SLine   as numeric
	Local nV8X       as numeric
	Local nV8XLine   as numeric
	Local nV8Y       as numeric
	Local nV8YLine   as numeric
	Local oModelV7C  as object
	Local oModelV7D  as object
	Local oModelV7E  as object
	Local oModelV7F  as object
	Local oModelV7G  as object
	Local oModelV8K  as object
	Local oModelV8L  as object
	Local oModelV8M  as object
	Local oModelV8N  as object
	Local oModelV8O  as object
	Local oModelV8P  as object
	Local oModelV8Q  as object
	Local oModelV8S  as object
	Local oModelV8X  as object
	Local oModelV8Y  as object

	aDataModel := {}
	aGrava     := {}
	aGravaV7C  := {}
	aGravaV7D  := {}
	aGravaV7E  := {}
	aGravaV7F  := {}
	aGravaV7G  := {}
	aGravaV8K  := {}
	aGravaV8L  := {}
	aGravaV8M  := {}
	aGravaV8N  := {}
	aGravaV8O  := {}
	aGravaV8P  := {}
	aGravaV8Q  := {}
	aGravaV8S  := {}
	aGravaV8X  := {}
	aGravaV8Y  := {}
	cEvento    := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	cIndex     := ""
	nI         := 0
	nV7C       := 0
	nV7D       := 0
	nV7DLine   := 0
	nV7E       := 0
	nV7ELine   := 0
	nV7F       := 0
	nV7FLine   := 0
	nV7G       := 0
	nV7GLine   := 0
	nV8K       := 0
	nV8KLine   := 0
	nV8L       := 0
	nV8LLine   := 0
	nV8M       := 0
	nV8MLine   := 0
	nV8N       := 0
	nV8NLine   := 0
	nV8O       := 0
	nV8OLine   := 0
	nV8P       := 0
	nV8PLine   := 0
	nV8Q       := 0
	nV8QLine   := 0
	nV8S       := 0
	nV8SLine   := 0
	nV8X       := 0
	nV8XLine   := 0
	nV8Y       := 0
	nV8YLine   := 0
	oModelV7C  := Nil
	oModelV7D  := Nil
	oModelV7E  := Nil
	oModelV7F  := Nil
	oModelV7G  := Nil
	oModelV8K  := Nil
	oModelV8L  := Nil
	oModelV8M  := Nil
	oModelV8N  := Nil
	oModelV8O  := Nil
	oModelV8P  := Nil
	oModelV8Q  := Nil
	oModelV8S  := Nil
	oModelV8X  := Nil
	oModelV8Y  := Nil

	SetlDic0103()

	Begin Transaction

		//Posiciona o item
		("V7C")->( DBGoTo( nRecno ) )

		oModelV7C := oModel:GetModel( 'MODEL_V7C' )
		oModelV7D := oModel:GetModel( 'MODEL_V7D' )
		oModelV7E := oModel:GetModel( 'MODEL_V7E' )
		oModelV7F := oModel:GetModel( 'MODEL_V7F' )
		oModelV7G := oModel:GetModel( 'MODEL_V7G' )

		If lSimpl0102 .Or. (lSimpl0103 .and. lDic0103)

			oModelV8K  := oModel:GetModel( 'MODEL_V8K' )
			oModelV8L  := oModel:GetModel( 'MODEL_V8L' )
			oModelV8M  := oModel:GetModel( 'MODEL_V8M' )
			oModelV8N  := oModel:GetModel( 'MODEL_V8N' )
			oModelV8O  := oModel:GetModel( 'MODEL_V8O' )
			oModelV8P  := oModel:GetModel( 'MODEL_V8P' )
			oModelV8Q  := oModel:GetModel( 'MODEL_V8Q' )
			oModelV8S  := oModel:GetModel( 'MODEL_V8S' )
			oModelV8X  := oModel:GetModel( 'MODEL_V8X' )
			oModelV8Y  := oModel:GetModel( 'MODEL_V8Y' )

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Busco a versao anterior do registro para gravacao do rastro?
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		cVerAnt		:= oModelV7C:GetValue("V7C_VERSAO")
		cProtocolo	:= oModelV7C:GetValue("V7C_PROTUL")
		cEvento		:= oModelV7C:GetValue("V7C_EVENTO")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Neste momento eu gravo as informacoes que foram carregadas       ?
		//?na tela, pois neste momento o usuario ja fez as modificacoes que ?
		//?precisava e as mesmas estao armazenadas em memoria, ou seja,     ?
		//?nao devem ser consideradas neste momento                         ?
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		For nI := 1 to Len( oModelV7C:aDataModel[ 1 ] )
			aAdd( aGravaV7C, { oModelV7C:aDataModel[ 1, nI, 1 ], oModelV7C:aDataModel[ 1, nI, 2 ] } )
		Next nI

		V7D->( DbSetOrder( 2 ) )

		If lSimpl0103 .and. lDic0103
			cIndex := V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU + V7C_IDESEQ)
		Else
			cIndex := V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU )
		EndIf 
		
		If V7D->(MsSeek(xFilial("V7D")+ cIndex ) )
			
			For nV7D := 1 To oModel:GetModel( 'MODEL_V7D' ):Length()

				oModel:GetModel( 'MODEL_V7D' ):GoLine(nV7D)

				If !oModel:GetModel( 'MODEL_V7D' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7D' ):IsEmpty() 	
					aAdd (aGravaV7D ,{oModelV7D:GetValue('V7D_CPFTRA')})
				EndIf
				
				V7E->( DbSetOrder( 2 ) )
				If V7E->(MsSeek(xFilial("V7E")+V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )
			
					For nV7E := 1 To oModel:GetModel( 'MODEL_V7E' ):Length() 

						oModel:GetModel( 'MODEL_V7E' ):GoLine(nV7E)

						If !oModel:GetModel( 'MODEL_V7E' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7E' ):IsEmpty()	

							If !lSimpl0102

								aAdd (aGravaV7E ,{	oModelV7D:GetValue('V7D_CPFTRA')	,;
													oModelV7E:GetValue('V7E_PERREF')	,;
													oModelV7E:GetValue('V7E_VRMEN')		,;
													oModelV7E:GetValue('V7E_VRCP')		,;
													oModelV7E:GetValue('V7E_VERREN')	,;
													oModelV7E:GetValue('V7E_VRIRRF')	})

							Else

								aAdd (aGravaV7E ,{	oModelV7D:GetValue('V7D_CPFTRA')	,;
													oModelV7E:GetValue('V7E_PERREF')	,;
													oModelV7E:GetValue('V7E_VRMEN')		,;
													oModelV7E:GetValue('V7E_VRCP')		})

							EndIf

						EndIf

						V7F->( DbSetOrder( 2 ) )
						If V7F->(MsSeek(xFilial("V7F")+V7E->(V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA + V7E_PERREF) ) )
							
							For nV7F := 1 To oModel:GetModel( 'MODEL_V7F' ):Length()

								oModel:GetModel( 'MODEL_V7F' ):GoLine(nV7F)

								If !oModel:GetModel( 'MODEL_V7F' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V7F' ):IsEmpty()	
									aAdd (aGravaV7F ,{	oModelV7D:GetValue('V7D_CPFTRA'),;
														oModelV7E:GetValue('V7E_PERREF'),;
														oModelV7F:GetValue('V7F_IDCODR'),;
														oModelV7F:GetValue('V7F_VRCR')})

								EndIf
							Next
						EndIf

					Next
				EndIf

				V7G->(DBSetOrder( 2 ) )
				If V7G->(MsSeek(xFilial("V7G")+V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )

					For nV7G := 1 To oModel:GetModel( 'MODEL_V7G' ):Length() 

						oModel:GetModel( 'MODEL_V7G' ):GoLine(nV7G)

						If !oModel:GetModel( 'MODEL_V7G' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7G' ):IsEmpty()	

							If lSimpl0103 .and. lDic0103
									aAdd(aGravaV7G ,{ 	oModelV7D:GetValue('V7D_CPFTRA'),;	
														oModelV7G:GetValue('V7G_TPCR'),;
														oModelV7G:GetValue('V7G_VRCR'),;
														oModelV7G:GetValue('V7G_VRCR13')})
							Else
								aAdd(aGravaV7G ,{ 	oModelV7D:GetValue('V7D_CPFTRA'),;	
													oModelV7G:GetValue('V7G_TPCR'),;
													oModelV7G:GetValue('V7G_VRCR')})
							EndIf 

						EndIf

						If lSimpl0102 .And. TafColumnPos( "V8X_VLRTRI" ) .Or. (lSimpl0103 .and. lDic0103)

							For nV8X := 1 to oModel:GetModel( 'MODEL_V8X' ):Length()

								oModel:GetModel( 'MODEL_V8X' ):GoLine(nV8X)

								If !oModel:GetModel( 'MODEL_V8X' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V8X' ):IsEmpty()

									If lSimpl0103 .and. lDic0103
										aAdd(aGravaV8X, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
														oModelV8X:GetValue('V8X_VLRTRI'),;
														oModelV8X:GetValue('V8X_VLRT13'),;
														oModelV8X:GetValue('V8X_VLRIMG'),;
														oModelV8X:GetValue('V8X_VLRI65'),;
														oModelV8X:GetValue('V8X_VLJRMO'),;
														oModelV8X:GetValue('V8X_VLRINT'),;
														oModelV8X:GetValue('V8X_DCRINT'),;
														oModelV8X:GetValue('V8X_VLPRVO'),;
														oModelV8X:GetValue('V8X_IMG13') ,;
														oModelV8X:GetValue('V8X_I65DEC'),;
														oModelV8X:GetValue('V8X_MOR13') ,;
														oModelV8X:GetValue('V8X_PREV13'),;
														oModelV8X:GetValue('V8X_VLRDIA'),;
														oModelV8X:GetValue('V8X_VLRAJU'),;
														oModelV8X:GetValue('V8X_VLRCON'),;
														oModelV8X:GetValue('V8X_VLRABN'),;
														oModelV8X:GetValue('V8X_VLMORD')})
									Else 
										aAdd(aGravaV8X, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
														oModelV8X:GetValue('V8X_VLRTRI'),;
														oModelV8X:GetValue('V8X_VLRT13'),;
														oModelV8X:GetValue('V8X_VLRIMG'),;
														oModelV8X:GetValue('V8X_VLRI65'),;
														oModelV8X:GetValue('V8X_VLJRMO'),;
														oModelV8X:GetValue('V8X_VLRINT'),;
														oModelV8X:GetValue('V8X_DCRINT'),;
														oModelV8X:GetValue('V8X_VLPRVO')})
									EndIf 

								EndIf
							Next
							
							For nV8Y := 1 to oModel:GetModel( 'MODEL_V8Y' ):Length()

								oModel:GetModel( 'MODEL_V8Y' ):GoLine(nV8Y)

								If !oModel:GetModel( 'MODEL_V8Y' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V8Y' ):IsEmpty()

									aAdd(aGravaV8Y, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
														oModelV8Y:GetValue('V8Y_DESCRA'),;
														oModelV8Y:GetValue('V8Y_QTMRRA'),;
														oModelV8Y:GetValue('V8Y_VLRCUS'),;
														oModelV8Y:GetValue('V8Y_VLRADV')})

								EndIf
																										
								For nV8K := 1 to oModel:GetModel( 'MODEL_V8K' ):Length()

									oModel:GetModel( 'MODEL_V8K' ):GoLine(nV8K)

									If !oModel:GetModel( 'MODEL_V8K' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8K' ):IsEmpty()

										aAdd(aGravaV8K , { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
															oModelV8K:GetValue('V8K_TPINSC'),;
															oModelV8K:GetValue('V8K_NRINSC'),;
															oModelV8K:GetValue('V8K_VLRADV')})

									EndIf						
								Next								
							Next

							For nV8L := 1 to oModel:GetModel( 'MODEL_V8L' ):Length()

								oModel:GetModel( 'MODEL_V8L' ):GoLine(nV8L)

								If !oModel:GetModel( 'MODEL_V8L' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8L' ):IsEmpty()

									aAdd(aGravaV8L, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
														oModelV8L:GetValue('V8L_TPREND'),;
														oModelV8L:GetValue('V8L_CPFDEP'),;
														oModelV8L:GetValue('V8L_VLRDED')})
								EndIf
							Next
							
							For nV8M := 1 to oModel:GetModel( 'MODEL_V8M' ):Length()

								oModel:GetModel( 'MODEL_V8M' ):GoLine(nV8M)

								If !oModel:GetModel( 'MODEL_V8M' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8M' ):IsEmpty()

									aAdd(aGravaV8M, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
														oModelV8M:GetValue('V8M_TPREND'),;
														oModelV8M:GetValue('V8M_CPFDEP'),;
														oModelV8M:GetValue('V8M_VLPENS')})
								EndIf
							Next
							
							For nV8N := 1 to oModel:GetModel( 'MODEL_V8N' ):Length()

								oModel:GetModel( 'MODEL_V8N' ):GoLine(nV8N)

								If !oModel:GetModel( 'MODEL_V8N' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8N' ):IsEmpty()

									aAdd(aGravaV8N, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR'),;
														oModelV8N:GetValue('V8N_TPPRCR'),;
														oModelV8N:GetValue('V8N_NRPRCR'),;
														oModelV8N:GetValue('V8N_CODSUP')})

								EndIf
	
								For nV8O := 1 to oModel:GetModel( 'MODEL_V8O' ):Length()

									oModel:GetModel( 'MODEL_V8O' ):GoLine(nV8O)

									If !oModel:GetModel( 'MODEL_V8O' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8O' ):IsEmpty()

										aAdd(aGravaV8O, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR') + oModelV8N:GetValue('V8N_TPPRCR') + oModelV8N:GetValue('V8N_NRPRCR') + oModelV8N:GetValue('V8N_CODSUP'),;
															oModelV8O:GetValue('V8O_INDAPU'),;
															oModelV8O:GetValue('V8O_VLNRET'),;
															oModelV8O:GetValue('V8O_VLDEPJ'),;
															oModelV8O:GetValue('V8O_VLDEPJ'),;
															oModelV8O:GetValue('V8O_VLCPAA'),;
															oModelV8O:GetValue('V8O_VLRSUS')})

									EndIf

									For nV8P := 1 to oModel:GetModel( 'MODEL_V8P' ):Length()

										oModel:GetModel( 'MODEL_V8P' ):GoLine(nV8P)

										If !oModel:GetModel( 'MODEL_V8P' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8P' ):IsEmpty()

											aAdd(aGravaV8P, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR') + oModelV8N:GetValue('V8N_TPPRCR') + oModelV8N:GetValue('V8N_NRPRCR') + oModelV8N:GetValue('V8N_CODSUP') + oModelV8O:GetValue('V8O_INDAPU'),;
																oModelV8P:GetValue('V8P_TPDEDU'),;
																oModelV8P:GetValue('V8P_VLSUSP'),;
																oModelV8P:GetValue('V8P_CHAVE')})

											
											For nV8Q := 1 to oModel:GetModel( 'MODEL_V8Q' ):Length()

												oModel:GetModel( 'MODEL_V8Q' ):GoLine(nV8Q)

												If !oModel:GetModel( 'MODEL_V8Q' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V8Q' ):IsEmpty()
													aAdd(aGravaV8Q, { 	oModelV7D:GetValue('V7D_CPFTRA') + oModelV7G:GetValue('V7G_TPCR') + oModelV8N:GetValue('V8N_TPPRCR') + oModelV8N:GetValue('V8N_NRPRCR') + oModelV8N:GetValue('V8N_CODSUP') + oModelV8O:GetValue('V8O_INDAPU'),;
																		oModelV8Q:GetValue('V8Q_CPFDEP'),;
																		oModelV8Q:GetValue('V8Q_VLDEPS')})		

												EndIf
												
											Next nV8Q	

										EndIf
						
									Next nV8P
								Next nV8O 
							Next nV8N
						EndIf

					Next nV7G
				EndIf

				If lSimpl0102 .And. TafColumnPos( "V8X_VLRTRI" )

					For nV8S := 1 To oModel:GetModel( 'MODEL_V8S' ):Length() 

						oModel:GetModel( 'MODEL_V8S' ):GoLine(nV8S)

						If !oModel:GetModel( 'MODEL_V8S' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V8S' ):IsEmpty()	

							aAdd(aGravaV8S , { 	oModelV7D:GetValue( 'V7D_CPFTRA'),;
												oModelV8S:GetValue( 'V8S_DTLAUD'),;
												oModelV8S:GetValue( 'V8S_CPFDEP'),;
												oModelV8S:GetValue( 'V8S_DTNASC'),;
												oModelV8S:GetValue( 'V8S_NOME'	),;
												oModelV8S:GetValue( 'V8S_DEPIR'	),;
												oModelV8S:GetValue( 'V8S_TPDEP'	),;
												oModelV8S:GetValue( 'V8S_DESCDE')})

						EndIf
					Next nV8S
					
				EndIf
				
			Next
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Seto o campo como Inativo e gravo a versao do novo registro?
		//?no registro anterior                                       ?
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		
		FAltRegAnt( 'V7C', '2' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Neste momento eu preciso setar a operacao do model?
		//?como Inclusao                                     ?
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Neste momento eu realizo a inclusao do novo registro ja?
		//?contemplando as informacoes alteradas pelo usuario     ?
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		For nI := 1 To Len( aGravaV7C )
			oModel:LoadValue( 'MODEL_V7C', aGravaV7C[ nI, 1 ], aGravaV7C[ nI, 2 ] )
		Next

		nV7DLine := 1

		For nV7D := 1 To Len( aGravaV7D )

			oModel:GetModel( 'MODEL_V7D' ):LVALID	:= .T.

			If nV7DLine > 1
				oModel:GetModel( 'MODEL_V7D' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_V7D", "V7D_CPFTRA",	aGravaV7D[nV7D][1] )
			
			nV7ELine := 1 

			For nV7E := 1 to Len( aGravaV7E )

				If  aGravaV7E[nV7E][1] == aGravaV7D[nV7D][1]

					oModel:GetModel( 'MODEL_V7E' ):LVALID := .T.

					If nV7ELine > 1
						oModel:GetModel( "MODEL_V7E" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_V7E", "V7E_PERREF"	, aGravaV7E[nV7E][2] )
					oModel:LoadValue( "MODEL_V7E", "V7E_VRMEN"	, aGravaV7E[nV7E][3] )
					oModel:LoadValue( "MODEL_V7E", "V7E_VRCP"	, aGravaV7E[nV7E][4] )

					If !lSimpl0102

						oModel:LoadValue( "MODEL_V7E", "V7E_VERREN"	, aGravaV7E[nV7E][5] )
						oModel:LoadValue( "MODEL_V7E", "V7E_VRIRRF"	, aGravaV7E[nV7E][6] )

					EndIf

					nV7FLine := 1

					For nV7F := 1 to Len( aGravaV7F )

						If  aGravaV7F[nV7F][1] + aGravaV7F[nV7F][2] == aGravaV7E[nV7E][1] + aGravaV7E[nV7E][2] 

							oModel:GetModel( 'MODEL_V7F' ):LVALID := .T.

							If nV7FLine > 1
								oModel:GetModel( "MODEL_V7F" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_V7F", "V7F_IDCODR"	, aGravaV7F[nV7F][3] )
							oModel:LoadValue( "MODEL_V7F", "V7F_VRCR"	, aGravaV7F[nV7F][4] )

							nV7FLine++

						EndIf
					Next

					nV7ELine++

				EndIf
			Next

			nV7GLine := 1

			For nV7G := 1 to Len( aGravaV7G )

				If aGravaV7G[nV7G][1] == aGravaV7D[nV7D][1]

					oModel:GetModel( 'MODEL_V7G' ):LVALID := .T.

					If nV7GLine > 1
						oModel:GetModel( "MODEL_V7G" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_V7G", "V7G_TPCR"	, aGravaV7G[nV7G][2] )
					oModel:LoadValue( "MODEL_V7G", "V7G_VRCR"	, aGravaV7G[nV7G][3] )

					If lSimpl0103  .and. lDic0103
						oModel:LoadValue( "MODEL_V7G", "V7G_VRCR13"	, aGravaV7G[nV7G][4] )
					EndIf

					If lSimpl0102 .or. (lSimpl0103 .and. lDic0103)

						nV8XLine := 1

						For nV8X := 1 to Len( aGravaV8X )

							If aGravaV8X[nV8X][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

								oModel:GetModel( 'MODEL_V8X' ):LVALID := .T.

								oModel:LoadValue( "MODEL_V8X", "V8X_VLRTRI"	, aGravaV8X[nV8X][2] )
								oModel:LoadValue( "MODEL_V8X", "V8X_VLRT13"	, aGravaV8X[nV8X][3] )
								oModel:LoadValue( "MODEL_V8X", "V8X_VLRIMG"	, aGravaV8X[nV8X][4] )
								oModel:LoadValue( "MODEL_V8X", "V8X_VLRI65"	, aGravaV8X[nV8X][5] )
								oModel:LoadValue( "MODEL_V8X", "V8X_VLJRMO"	, aGravaV8X[nV8X][6] )
								oModel:LoadValue( "MODEL_V8X", "V8X_VLRINT"	, aGravaV8X[nV8X][7] )
								oModel:LoadValue( "MODEL_V8X", "V8X_DCRINT"	, aGravaV8X[nV8X][8] )
								oModel:LoadValue( "MODEL_V8X", "V8X_VLPRVO"	, aGravaV8X[nV8X][9] )

								If lSimpl0103 .and. lDic0103
									oModel:LoadValue( "MODEL_V8X", "V8X_IMG13"	, aGravaV8X[nV8X][10] )
									oModel:LoadValue( "MODEL_V8X", "V8X_I65DEC"	, aGravaV8X[nV8X][11] )
									oModel:LoadValue( "MODEL_V8X", "V8X_MOR13"	, aGravaV8X[nV8X][12] )
									oModel:LoadValue( "MODEL_V8X", "V8X_PREV13"	, aGravaV8X[nV8X][13] )
									oModel:LoadValue( "MODEL_V8X", "V8X_VLRDIA"	, aGravaV8X[nV8X][14] )
									oModel:LoadValue( "MODEL_V8X", "V8X_VLRAJU"	, aGravaV8X[nV8X][15] )
									oModel:LoadValue( "MODEL_V8X", "V8X_VLRCON"	, aGravaV8X[nV8X][16] )
									oModel:LoadValue( "MODEL_V8X", "V8X_VLRABN"	, aGravaV8X[nV8X][17] )
									oModel:LoadValue( "MODEL_V8X", "V8X_VLMORD"	, aGravaV8X[nV8X][18] )
								EndIf 

								nV8XLine++

							EndIf
						Next

						nV8YLine := 1

						For nV8Y := 1 to Len( aGravaV8Y )

							If aGravaV8Y[nV8Y][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

								oModel:GetModel( 'MODEL_V8Y' ):LVALID := .T.

								oModel:LoadValue( "MODEL_V8Y", "V8Y_DESCRA"	, aGravaV8Y[nV8Y][2] )
								oModel:LoadValue( "MODEL_V8Y", "V8Y_QTMRRA"	, aGravaV8Y[nV8Y][3] )
								oModel:LoadValue( "MODEL_V8Y", "V8Y_VLRCUS"	, aGravaV8Y[nV8Y][4] )
								oModel:LoadValue( "MODEL_V8Y", "V8Y_VLRADV"	, aGravaV8Y[nV8Y][5] )							

								nV8KLine := 1

								For nV8K := 1 to Len ( aGravaV8K )

									If aGravaV8K[nV8K][1] == aGravaV8Y[nV8Y][1]

										oModel:GetModel( 'MODEL_V8K' ):LVALID := .T.

										If nV8KLine > 1
											oModel:GetModel( "MODEL_V8K" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V8K", "V8K_TPINSC"	, aGravaV8K[nV8K][2] )
										oModel:LoadValue( "MODEL_V8K", "V8K_NRINSC"	, aGravaV8K[nV8K][3] )
										oModel:LoadValue( "MODEL_V8K", "V8K_VLRADV"	, aGravaV8K[nV8K][4] )

										nV8KLine++

									EndIf

								Next		

								nV8YLine++

							EndIf
						Next

						nV8LLine := 1

						For nV8L := 1 to Len ( aGravaV8L )

							If aGravaV8L[nV8L][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

								oModel:GetModel( 'MODEL_V8L' ):LVALID := .T.

								If nV8LLine > 1
									oModel:GetModel( "MODEL_V8L" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V8L", "V8L_TPREND"	, aGravaV8L[nV8L][2] )
								oModel:LoadValue( "MODEL_V8L", "V8L_CPFDEP"	, aGravaV8L[nV8L][3] )
								oModel:LoadValue( "MODEL_V8L", "V8L_VLRDED"	, aGravaV8L[nV8L][4] )

								nV8LLine++

							EndIf
						Next

						nV8MLine := 1

						For nV8M := 1 to Len ( aGravaV8M )

							If aGravaV8M[nV8M][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

								oModel:GetModel( 'MODEL_V8M' ):LVALID := .T.

								If nV8MLine > 1
									oModel:GetModel( "MODEL_V8M" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V8M", "V8M_TPREND"	, aGravaV8M[nV8M][2] )
								oModel:LoadValue( "MODEL_V8M", "V8M_CPFDEP"	, aGravaV8M[nV8M][3] )
								oModel:LoadValue( "MODEL_V8M", "V8M_VLPENS"	, aGravaV8M[nV8M][4] )

								nV8MLine++

							EndIf

						Next

						nV8NLine := 1

						For nV8N := 1 to Len ( aGravaV8N )

							If aGravaV8N[nV8N][1] == aGravaV7G[nV7G][1] + aGravaV7G[nV7G][2]

								oModel:GetModel( 'MODEL_V8N' ):LVALID := .T.

								If nV8NLine > 1
									oModel:GetModel( "MODEL_V8N" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V8N", "V8N_TPPRCR"	, aGravaV8N[nV8N][2] )
								oModel:LoadValue( "MODEL_V8N", "V8N_NRPRCR"	, aGravaV8N[nV8N][3] )
								oModel:LoadValue( "MODEL_V8N", "V8N_CODSUP"	, aGravaV8N[nV8N][4] )

								nV8OLine := 1

								For nV8O := 1 to Len ( aGravaV8O )

									If aGravaV8O[nV8O][1] == aGravaV8N[nV8N][1] + aGravaV8N[nV8N][2] + aGravaV8N[nV8N][3] + aGravaV8N[nV8N][4]

										oModel:GetModel( 'MODEL_V8O' ):LVALID := .T.

										If nV8OLine > 1
											oModel:GetModel( "MODEL_V8O" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V8O", "V8O_INDAPU"	, aGravaV8O[nV8O][2] )
										oModel:LoadValue( "MODEL_V8O", "V8O_VLNRET"	, aGravaV8O[nV8O][3] )
										oModel:LoadValue( "MODEL_V8O", "V8O_VLDEPJ"	, aGravaV8O[nV8O][4] )
										oModel:LoadValue( "MODEL_V8O", "V8O_VLCPAC"	, aGravaV8O[nV8O][5] )
										oModel:LoadValue( "MODEL_V8O", "V8O_VLCPAA"	, aGravaV8O[nV8O][6] )
										oModel:LoadValue( "MODEL_V8O", "V8O_VLRSUS"	, aGravaV8O[nV8O][7] )

										nV8PLine := 1

										For nV8P := 1 to Len ( aGravaV8P )

											If aGravaV8P[nV8P][1] == aGravaV8O[nV8O][1] + aGravaV8O[nV8O][2]

												oModel:GetModel( 'MODEL_V8P' ):LVALID := .T.

												If nV8PLine > 1
													oModel:GetModel( "MODEL_V8P" ):AddLine()
												EndIf

												oModel:LoadValue( "MODEL_V8P", "V8P_TPDEDU"	, aGravaV8P[nV8P][2] )
												oModel:LoadValue( "MODEL_V8P", "V8P_VLSUSP"	, aGravaV8P[nV8P][3] )
												oModel:LoadValue( "MODEL_V8P", "V8P_CHAVE"	, aGravaV8P[nV8P][4] )

												nV8QLine := 1

												For nV8Q := 1 to Len ( aGravaV8Q )

													If aGravaV8Q[nV8Q][1] == aGravaV8P[nV8P][1]

														oModel:GetModel( 'MODEL_V8Q' ):LVALID := .T.

														If nV8QLine > 1
															oModel:GetModel( "MODEL_V8Q"):AddLine()
														EndIf

														oModel:LoadValue( "MODEL_V8Q", "V8Q_CPFDEP"	, aGravaV8Q[nV8Q][2] )
														oModel:LoadValue( "MODEL_V8Q", "V8Q_VLDEPS"	, aGravaV8Q[nV8Q][3] )

														nV8QLine++

													EndIf
												Next

												nV8PLine++

											EndIf
										Next	

										nV8OLine++

									EndIf
								Next		

								nV8NLine++

							EndIf									
						Next
					EndIf

					nV7GLine++

				EndIf
			Next

			If lSimpl0102 .And. TafColumnPos( "V8X_VLRTRI" )

				For nV8S := 1 to Len( aGravaV8S )

					If  aGravaV8S[nV8S][1] == aGravaV7D[nV7D][1]

						oModel:GetModel( 'MODEL_V8S' ):LVALID := .T.

						If nV8SLine > 1
							oModel:GetModel( "MODEL_V8S" ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V8S", "V8S_DTLAUD"	, aGravaV8S[nV8S][2] )
						oModel:LoadValue( "MODEL_V8S", "V8S_CPFDEP"	, aGravaV8S[nV8S][3] )
						oModel:LoadValue( "MODEL_V8S", "V8S_DTNASC"	, aGravaV8S[nV8S][4] )
						oModel:LoadValue( "MODEL_V8S", "V8S_NOME"	, aGravaV8S[nV8S][5] )
						oModel:LoadValue( "MODEL_V8S", "V8S_DEPIR"	, aGravaV8S[nV8S][6] )
						oModel:LoadValue( "MODEL_V8S", "V8S_TPDEP"	, aGravaV8S[nV8S][7] )
						oModel:LoadValue( "MODEL_V8S", "V8S_DESCDE"	, aGravaV8S[nV8S][8] )

						nV8SLine++

					EndIf
				Next

			EndIf

			nV7DLine++

		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//?Busco a versao que sera gravada?
		//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V7C", "V7C_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_V7C", "V7C_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_V7C", "V7C_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_V7C", "V7C_PROTUL", "" )
		
		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclus?o
		seta-se o novo evento como uma "nova inclus?o", caso contrário o
		evento passar a ser uma alteraç?o
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V7C", "V7C_EVENTO"	, "E" )
		oModel:LoadValue( "MODEL_V7C", "V7C_ATIVO"	, "1" )	

		FwFormCommit(oModel)		
		TAFAltStat("V7C", "6")

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609View
Monta a View dinâmica
@Param  cAlias  -> Alias da tabela da view
@Param  nRecno  -> Numero do recno
@author  Alexandre de Lima/JR GOMES
@since   18/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function TAF609View( cAlias as character, nRecno as numeric )

	Local oNewView	as Object
	Local oExecView	as Object
	Local aArea 	as Array
	
	oNewView	:= ViewDef()
	aArea 		:= GetArea()
	oExecView	:= Nil

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

Return( 1 )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609Inc
Monta a View dinâmica
@Param  cAlias  -> Alias da tabela da view
@Param  nRecno  -> Numero do recno
@author  Alexandre de Lima/JR GOMES
@since   20/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function TAF609Inc( cAlias as character, nRecno as numeric )

	Local aArea     as Array
	Local oExecView as Object
	Local oNewView  as Object
	
	aArea     := GetArea()
	oExecView := Nil
	oNewView  := ViewDef()

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

Return( 3 )

//-------------------------------------------------------------------
/*/{Protheus.doc} XV7CValid
Valida se a chave do registro está inserida na tabela.
@author  Alexandre de lima santos
@since   27/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function XV7CValid(cCampo as Character)

	Local lRet as Logical

	Default cCampo	:= ""

	cNrPocV7C	:= POSICIONE("V7C", 4 , xFilial( 'V7C' ) + Padr( FWFLDGET("V7C_IDPROC"),TamSx3( "V7C_IDPROC" )[1]) + Padr( FWFLDGET("V7C_PERAPU"), TamSx3( "V7C_PERAPU" )[1] ) + '1', "V7C_NRPROC")

	lRet := .T.

	If AllTrim(cCampo) == "V7C_IDPROC" .AND. !Empty(FWFLDGET("V7C_IDPROC")) .AND. !Empty(FWFLDGET("V7C_PERAPU")) .And. !Empty(FWFLDGET("V7C_IDESEQ"))
		
		If INCLUI

			V7C->( DbSetOrder( 7 ) ) //V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_IDESEQ+V7C_ATIVO                                                                                                           
			If V7C->( MsSeek( xFilial( 'V7C' ) + Padr( cNrPocV7C ,TamSx3( "V7C_NRPROC" )[1]) + Padr( FWFLDGET("V7C_PERAPU"), TamSx3( "V7C_PERAPU" )[1] ) + Padr( FWFLDGET("V7C_IDESEQ"), TamSx3( "V7C_IDESEQ" )[1] ) + '1' ) )
				
				Help( ,,"TAFJAGRAVADO",,, 1, 0 )
				lRet := .F.

			EndIf

		EndIf

		If  ALTERA

			If (Alltrim(FWFLDGET("V7C_IDPROC")) != Alltrim(cIdV7C) .OR. Alltrim(FWFLDGET("V7C_PERAPU")) != Alltrim( cPerV7C ) .Or. Alltrim(FWFLDGET("V7C_IDESEQ")) != Alltrim( cSeqV7C ))

				If Alltrim(FWFLDGET("V7C_STATUS")) == "4" .OR. !Empty(FWFLDGET("V7C_VERANT"))

					lRet := .F.
					MsgAlert( STR0011, STR0012 )

				Else

					V7C->( DbSetOrder( 7 ) ) //V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_IDESEQ+V7C_ATIVO 
					If V7C->( MsSeek( xFilial( 'V7C' ) + Padr( cNrPocV7C ,TamSx3( "V7C_NRPROC" )[1]) + Padr( FWFLDGET("V7C_PERAPU"), TamSx3( "V7C_PERAPU" )[1] ) + Padr( FWFLDGET("V7C_IDESEQ"), TamSx3( "V7C_IDESEQ" )[1] ) + '1' ) )
						
						Help( ,,"TAFJAGRAVADO",,, 1, 0 )
						lRet := .F.

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609Grv

@description Funcao de gravacao para atender o registro S-5001

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

@author Alexandre de L
@since 01/11/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF609Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character, cFilTran as Character, cPredeces as Character,;
                nTAFRecno as Numeric, cComplem as Character, cGrpTran as Character, cEmpEnv as Character, cFilEnv as Character, cXmlID as Character, cEvtOri as Character,;
				lMigrador as Logical, lDepGPE as Logical, cKey as Character, cMatrC9V as Character, lLaySmpTot as Logical, lExclCMJ as Logical, oTransf as Object, cXml as Character)
				
	Local aChave              as Array
	Local aIncons             as Array
	Local cCabec              as Character
	Local cCmpsNoUpd          as Character
	Local cCpfTrb             as Character
	Local cInconMsg           as Character
	Local cLogOpeAnt          as Character
	Local cNrProc             as Character
	Local cPeriodo            as Character
	Local cSeqProc			  as Character
	Local cV7DPath            as Character
	Local cV7EPath            as Character
	Local cV7FPath            as Character
	Local cV8KPath            as Character
	Local cV8LPath            as Character
	Local cV8MPath            as Character
	Local cV8NPath            as Character
	Local cV8OPath            as Character
	Local cV8PPath            as Character
	Local cV8QPath            as Character
	Local cV8SInfoDepPath     as Character
	Local cV8SPath            as Character
	Local cV8XPath            as Character
	Local cV8YDespProcJudPath as Character
	Local cV8YPath            as Character	
	Local lRet                as Logical
	Local nI                  as Numeric
	Local nJ                  as Numeric
	Local nSeqErrGrv          as Numeric
	Local nV7C                as Numeric
	Local nV7D                as Numeric
	Local nV7E                as Numeric
	Local nV7F                as Numeric
	Local nV7G                as Numeric
	Local nV8L                as Numeric
	Local nV8M                as Numeric
	Local nV8N                as Numeric
	Local nV8O                as Numeric
	Local nV8P                as Numeric
	Local nV8Q                as Numeric
	Local nV8S                as Numeric
	Local nV8SInfoDep         as Numeric
	Local nV8X                as Numeric
	Local nV8Y                as Numeric
	Local nV8YDespProcJud     as Numeric
	Local nInd                as Numeric
	Local cLayNmSpac 		  as Character
	Local cSeek				  as Character

	Private lVldModel as Logical
	Private oDados    as Object
	Private oModel    as Object

	Default cComplem   := ""
	Default cEmpEnv    := ""
	Default cEvtOri    := ""
	Default cFilEnv    := ""
	Default cFilEv     := ""
	Default cFilTran   := ""
	Default cGrpTran   := ""
	Default cKey       := ""
	Default cKey       := ""
	Default cLayout    := ""
	Default cMatrC9V   := ""
	Default cMatrC9V   := ""
	Default cOwner     := ""
	Default cPredeces  := ""
	Default cXml       := ""
	Default cXmlID     := ""
	Default lDepGPE    := .F.
	Default lDepGPE    := .F.
	Default lExclCMJ   := .F.
	Default lLaySmpTot := .F.
	Default lMigrador  := .F.
	Default nOpc       := 1
	Default nTAFRecno  := 0
	Default oTransf    := Nil
	Default oXML       := Nil

	aChave              := {}
	aIncons             := {}
	cCabec              := "/eSocial/evtContProc/"
	cCmpsNoUpd          := "|V7C_FILIAL|V7C_ID|V7C_VERSAO|V7C_PROTUL|V7C_EVENTO|V7C_STATUS|V7C_ATIVO|"
	cCpfTrb             := ""
	cInconMsg           := ""
	cLogOpeAnt          := ""
	cNrProc             := ""
	cPeriodo            := ""
	cV7DPath            := ""
	cV7EPath            := ""
	cV7FPath            := ""
	cV7GPath            := ""
	cV8KPath            := ""
	cV8LPath            := ""
	cV8MPath            := ""
	cV8NPath            := ""
	cV8OPath            := ""
	cV8PPath            := ""
	cV8QPath            := ""
	cV8SInfoDepPath     := ""
	cV8SPath            := ""
	cV8XPath            := ""
	cV8YDespProcJudPath := ""
	cV8YPath            := ""
	cSeek				:= ""
	cLayNmSpac 			:= TafNameEspace(cXML)		  	
	lRet                := .F.
	nI                  := 0
	nJ                  := 0
	nSeqErrGrv          := 0
	nV7C                := 0
	nV7D                := 0
	nV7E                := 0
	nV7F                := 0
	nV7G                := 0
	nV8L                := 0
	nV8M                := 0
	nV8N                := 0
	nV8O                := 0
	nV8P                := 0
	nV8Q                := 0
	nV8S                := 0
	nV8SInfoDep         := 0
	oModel              := Nil

	oDados 	  := oXML
	lVldModel := .T.

	SetlDic0103()

	cNrProc   := FTafGetVal(  cCabec + "ideProc/nrProcTrab", "C", .F., @aIncons, .F. )
	cPeriodo  := FTafGetVal(  cCabec + "ideProc/perApurPgto", "C", .F., @aIncons, .F. )
	cSeqProc  := FTafGetVal(  cCabec + "ideProc/ideSeqProc", "C", .F., @aIncons, .F. )

	Aadd( aChave, {"C", "V7C_NRPROC", cNrProc,.T.} )

	If At("-", cPeriodo) > 0
		cPeriodo := StrTran(cPeriodo, "-", "" )
		Aadd( aChave, {"C", "V7C_PERAPU", cPeriodo,.T.} )
	Else
		Aadd( aChave, {"C", "V7C_PERAPU", cPeriodo,.T.} )
	EndIf

	If lSimpl0103 .and. lDic0103
		Aadd( aChave, {"C", "V7C_IDESEQ", cSeqProc,.T.} )
	EndIf 

	V7C->( DbSetOrder( 5 ) )

	If lSimpl0103 .and. lDic0103

		V7C->( DbSetOrder( 7 ) )
		cSeek := Padr( cNrProc, TamSx3("V7C_NRPROC")[1] ) +  Padr( cPeriodo, TamSx3("V7C_PERAPU")[1] ) + Padr(cSeqProc, TamSx3("V7C_IDESEQ")[1] ) + '1' 

		nInd := 7
	Else

		cSeek := Padr( cNrProc, TamSx3("V7C_NRPROC")[1] ) +  Padr( cPeriodo, TamSx3("V7C_PERAPU")[1] ) + '1'

		nInd := 5
	EndIf 
	
	If cOwner $ "GPE" 
		If V7C->( MsSeek( xFilial( 'V7C' ) + cSeek  ) )
			nOpc := 4
		Else
			nOpc := 3
		EndIf
	EndIf

	Begin Transaction	
		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'V7C', nInd , @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA609", cCmpsNoUpd )

			cLogOpeAnt := V7C->V7C_LOGOPE
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				oModel:LoadValue( "MODEL_V7C", "V7C_FILIAL", V7C->V7C_FILIAL )
				oModel:LoadValue( "MODEL_V7C", "V7C_LAYOUT", cLayNmSpac 	 )

				V9U->( DbSetOrder( 7 ) )
				If V9U->( MsSeek( xFilial( 'V9U' ) + Padr( cNrProc, TamSx3("V9U_NRPROC")[1] ) + '1' ) )
					oModel:LoadValue("MODEL_V7C", "V7C_IDPROC", V9U->V9U_ID )
					oModel:LoadValue("MODEL_V7C", "V7C_NRPROC", V9U->V9U_NRPROC )
				Else
					cInconMsg := STR0013
				EndIf

				If !Empty(cSeqProc)
					oModel:LoadValue("MODEL_V7C", "V7C_IDESEQ", cSeqProc )
				EndIf 
				
				If Len(aIncons) == 0 .AND. Empty(cInconMsg)

					oModel:LoadValue("MODEL_V7C", "V7C_PERAPU", StrTran(cPeriodo, "-", "" ) )
						
					If oDados:XPathHasNode(cCabec + "ideProc/obs")
						oModel:LoadValue("MODEL_V7C", "V7C_OBS", FTafGetVal( cCabec + "ideProc/obs"    , "C", .F., @aIncons, .T. ) )
					EndIf
									
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '', cLogOpeAnt )
					EndIf

					nV7D     := 1
					cV7DPath := cCabec + "ideTrab[1]"
					
					If nOpc == 4
						verifyDelModelRows( "MODEL_V7D", nOpc, cV7DPath )
					EndIf
					
					While oDados:XPathHasNode(cV7DPath)

						oModel:GetModel( 'MODEL_V7D' ):LVALID	:= .T.

						If nOpc == 4 .Or. nV7D > 1
							oModel:GetModel( 'MODEL_V7D' ):AddLine()
						EndIf

						cCpfTrb := FTafGetVal( cV7DPath, "C", .F., @aIncons, .T.,,,,,.T., "cpfTrab")

						V9U->( DbSetOrder( 6 ) )	
						
						If V9U->( MsSeek( xFilial( 'V9U' ) + Padr( cNrProc, TamSx3("V9U_NRPROC")[1] ) + cCpfTrb + '1' ) )
							
							oModel:LoadValue("MODEL_V7D", "V7D_CPFTRA", cCpfTrb )
							
							nV7E     := 1
							cV7EPath := cV7DPath + "/calcTrib[1]"
							
							If nOpc == 4
								verifyDelModelRows( "MODEL_V7E", nOpc, cV7EPath )
							EndIf
						
							While oDados:XPathHasNode(cV7EPath)

								oModel:GetModel( 'MODEL_V7E' ):LVALID	:= .T.

								If nOpc == 4 .Or. nV7E > 1
									oModel:GetModel( 'MODEL_V7E' ):AddLine()
								EndIf

								oModel:LoadValue("MODEL_V7E", "V7E_PERREF", StrTran(FTafGetVal( cV7EPath, "C", .F., @aIncons, .T.,,,,,.T., "perRef" ), "-", "" ) )
								oModel:LoadValue("MODEL_V7E", "V7E_VRMEN" , FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrBcCpMensal" )              )
								oModel:LoadValue("MODEL_V7E", "V7E_VRCP"  , FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrBcCp13")                   )

								If !lSimpl0102
									oModel:LoadValue("MODEL_V7E", "V7E_VERREN", FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendIRRF" )   )
									oModel:LoadValue("MODEL_V7E", "V7E_VRIRRF", FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendIRRF13" ) )
								EndIf
								
								// V7F|infoCRContrib
								nV7F     := 1
								cV7FPath := cV7EPath + "/infoCRContrib[1]"
								
								If nOpc == 4
									verifyDelModelRows( "MODEL_V7F", nOpc, cV7FPath )
								EndIf

								While oDados:XPathHasNode(cV7FPath)

									oModel:GetModel( 'MODEL_V7F' ):LVALID	:= .T.

									If nOpc == 4 .Or. nV7F > 1
										oModel:GetModel( 'MODEL_V7F' ):AddLine()
									EndIf
											
									oModel:LoadValue("MODEL_V7F", "V7F_IDCODR"	, POSICIONE("V9T",2,XFILIAL("V9T") + FTafGetVal( cV7FPath, "C", .F., @aIncons, .T.,,,,,.T., "tpCR"),"V9T_ID") )
									oModel:LoadValue("MODEL_V7F", "V7F_VRCR", FTafGetVal( cV7FPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCR") )
									
									nV7F++
									cV7FPath := cV7EPath + "/infoCRContrib[" + CVALTOCHAR(nV7F) + "]"
								EndDo

								nV7E++
								cV7EPath := cV7DPath + "/calcTrib[" + CVALTOCHAR(nV7E) + "]"
							EndDo

							// V7G|infoCRIRRF
							nV7G     := 1
							cV7GPath := cV7DPath + "/infoCRIRRF[1]"
							
							If nOpc == 4
								verifyDelModelRows( "MODEL_V7G", nOpc, cV7GPath )
							EndIf
						
							While oDados:XPathHasNode(cV7GPath)

								oModel:GetModel( 'MODEL_V7G' ):LVALID	:= .T.

								If nOpc == 4 .Or. nV7G > 1
									oModel:GetModel( 'MODEL_V7G' ):AddLine()
								EndIf
										
								oModel:LoadValue("MODEL_V7G", "V7G_TPCR", POSICIONE("V9T",2,XFILIAL("V9T") + FTafGetVal( cV7GPath, "C", .F., @aIncons, .T.,,,,,.T., "tpCR"),"V9T_ID") )
								oModel:LoadValue("MODEL_V7G", "V7G_VRCR", FTafGetVal( cV7GPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCR") )

								If TafColumnPos("V7G_VRCR13")
									oModel:LoadValue("MODEL_V7G", "V7G_VRCR13", FTafGetVal( cV7GPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCR13") )
								EndIf 

								// V8X|infoIR
								nV8X     := 1
								cV8XPath := cV7GPath + "/infoIR[1]"
														
								While oDados:XPathHasNode( cV8XPath )

									oModel:GetModel( "MODEL_V8X" ):lValid	:= .T.

									oModel:LoadValue( "MODEL_V8X", "V8X_CHAVE" , StrZero(nV8X, TAMSX3("V8X_CHAVE")[1])                                      )

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrRendTrib" ))
										oModel:LoadValue( "MODEL_V8X", "V8X_VLRTRI", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendTrib"      ) )
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrRendTrib13" ))	
										oModel:LoadValue( "MODEL_V8X", "V8X_VLRT13", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendTrib13"    ) )
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrRendMoleGrave" ))	
										oModel:LoadValue( "MODEL_V8X", "V8X_VLRIMG", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendMoleGrave" ) )
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrRendIsen65" ))
										oModel:LoadValue( "MODEL_V8X", "V8X_VLRI65", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendIsen65"    ) )
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrJurosMora" ))	
										oModel:LoadValue( "MODEL_V8X", "V8X_VLJRMO", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrJurosMora"     ) )
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrRendIsenNTrib" ))
										oModel:LoadValue( "MODEL_V8X", "V8X_VLRINT", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendIsenNTrib" ) )
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"descIsenNTrib" ))	
										oModel:LoadValue( "MODEL_V8X", "V8X_DCRINT", FTafGetVal( cV8XPath, "C", .F., @aIncons, .T.,,,,,.T., "descIsenNTrib"   ) )
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrPrevOficial" ))	
										oModel:LoadValue( "MODEL_V8X", "V8X_VLPRVO", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrPrevOficial"   ) )
									EndIf

									If lSimpl0103 .and. lDic0103

										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrRendMoleGrave13" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_IMG13", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendMoleGrave13" ) )
										EndIf
										
										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrRendIsen65Dec" ))
											oModel:LoadValue( "MODEL_V8X", "V8X_I65DEC", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendIsen65Dec"    ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrJurosMora13" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_MOR13", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrJurosMora13"     ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vrPrevOficial13" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_PREV13", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vrPrevOficial13"   ) )
										EndIf

										cV8XPath += '/rendIsen0561[1]'
										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vlrDiarias" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRDIA", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrDiarias"   ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vlrAjudaCusto" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRAJU", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrAjudaCusto"   ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vlrIndResContrato" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRCON", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrIndResContrato"   ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vlrAbonoPec" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_VLRABN", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrAbonoPec"   ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8XPath ,"vlrAuxMoradia" ))	
											oModel:LoadValue( "MODEL_V8X", "V8X_VLMORD", FTafGetVal( cV8XPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrAuxMoradia"   ) )
										EndIf

									EndIf 

									nV8X++
									cV8XPath := cV7GPath + "/infoIR[" + cValToChar( nV8X ) + "]"

								EndDo
								
								// V8Y|infoRRA
								nV8Y     := 1
								cV8YPath := cV7GPath + "/infoRRA[1]"
							
								While oDados:XPathHasNode( cV8YPath )

									oModel:GetModel( "MODEL_V8Y" ):lValid	:= .T.
											
									oModel:LoadValue( "MODEL_V8Y", "V8Y_DESCRA", FTafGetVal( cV8YPath, "C", .F., @aIncons, .T.,,,,,.T., "descRRA"      ) )
									oModel:LoadValue( "MODEL_V8Y", "V8Y_QTMRRA", FTafGetVal( cV8YPath, "N", .F., @aIncons, .T.,,,,,.T., "qtdMesesRRA"  ) )

									// V8Y|despProcJud
									nV8YDespProcJud     := 1
									cV8YDespProcJudPath := cV8YPath + "/despProcJud[1]"
								
									While oDados:XPathHasNode( cV8YDespProcJudPath )

										oModel:LoadValue( "MODEL_V8Y", "V8Y_CHAVE" , StrZero(nV8YDespProcJud, TAMSX3("V8Y_CHAVE")[1])                                       )   
										oModel:LoadValue( "MODEL_V8Y", "V8Y_VLRCUS", FTafGetVal( cV8YDespProcJudPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrDespCustas"    ) )
										oModel:LoadValue( "MODEL_V8Y", "V8Y_VLRADV", FTafGetVal( cV8YDespProcJudPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrDespAdvogados" ) )
										
										nV8YDespProcJud++
										cV8YDespProcJudPath := cV8YPath + "/despProcJud[" + cValToChar( nV8YDespProcJud ) + "]"

									EndDo

									// V8K|ideAdv
									nV8KIdeAdv     := 1
									cV8KIdeAdvPath := cV8YPath + "/ideAdv[1]"
									
									If nOpc == 4
										verifyDelModelRows( "MODEL_V8K", nOpc, cV8KIdeAdvPath )
									EndIf
								
									While oDados:XPathHasNode( cV8KIdeAdvPath )

										oModel:GetModel( "MODEL_V8K" ):lValid	:= .T.

										If nOpc == 4 .Or. nV8KIdeAdv > 1
											oModel:GetModel( "MODEL_V8K" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V8K", "V8K_TPINSC", FTafGetVal( cV8KIdeAdvPath, "C", .F., @aIncons, .T.,,,,,.T., "tpInsc" ) )
										oModel:LoadValue( "MODEL_V8K", "V8K_NRINSC", FTafGetVal( cV8KIdeAdvPath, "C", .F., @aIncons, .T.,,,,,.T., "nrInsc" ) )

										If !Empty(oDados:XPathGetAtt( cV8KIdeAdvPath ,"vlrAdv" ))
											oModel:LoadValue( "MODEL_V8K", "V8K_VLRADV", FTafGetVal( cV8KIdeAdvPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrAdv" ) )
										EndIf
										
										nV8KIdeAdv++
										cV8KIdeAdvPath := cV8YPath + "/ideAdv[" + cValToChar( nV8KIdeAdv ) + "]"

									EndDo
									
									nV8Y++
									cV8YPath := cV7GPath + "/infoRRA[" + cValToChar( nV8Y ) + "]"

								EndDo
						
								// V8L|dedDepen
								nV8L     := 1
								cV8LPath := cV7GPath + "/dedDepen[1]"
								
								If nOpc == 4
									verifyDelModelRows( "MODEL_V8L", nOpc, cV8LPath )
								EndIf
							
								While oDados:XPathHasNode( cV8LPath )

									oModel:GetModel( "MODEL_V8L" ):lValid	:= .T.

									If nOpc == 4 .Or. nV8L > 1
										oModel:GetModel( "MODEL_V8L" ):AddLine()
									EndIf
											
									oModel:LoadValue( "MODEL_V8L", "V8L_TPREND", FTafGetVal( cV8LPath, "C", .F., @aIncons, .T.,,,,,.T., "tpRend"     ) )
									oModel:LoadValue( "MODEL_V8L", "V8L_CPFDEP", FTafGetVal( cV8LPath, "C", .F., @aIncons, .T.,,,,,.T., "cpfDep"     ) )
									oModel:LoadValue( "MODEL_V8L", "V8L_VLRDED", FTafGetVal( cV8LPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrDeducao" ) )
									
									nV8L++
									cV8LPath := cV7GPath + "/dedDepen[" + cValToChar( nV8L ) + "]"

								EndDo

								// V8M|penAlim
								nV8M     := 1
								cV8MPath := cV7GPath + "/penAlim[1]"

								If nOpc == 4
									verifyDelModelRows( "MODEL_V8M", nOpc, cV8MPath )
								EndIf
							
								While oDados:XPathHasNode( cV8MPath )

									oModel:GetModel( "MODEL_V8M" ):lValid	:= .T.

									If nOpc == 4 .Or. nV8M > 1
										oModel:GetModel( "MODEL_V8M" ):AddLine()
									EndIf
											
									oModel:LoadValue( "MODEL_V8M", "V8M_TPREND", FTafGetVal( cV8MPath, "C", .F., @aIncons, .T.,,,,,.T., "tpRend"    ) )
									oModel:LoadValue( "MODEL_V8M", "V8M_CPFDEP", FTafGetVal( cV8MPath, "C", .F., @aIncons, .T.,,,,,.T., "cpfDep"    ) )
									oModel:LoadValue( "MODEL_V8M", "V8M_VLPENS", FTafGetVal( cV8MPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrPensao" ) )
									
									nV8M++
									cV8MPath := cV7GPath + "/penAlim[" + cValToChar( nV8M ) + "]"
									
								EndDo

								// V8N|infoProcRet
								nV8N     := 1
								cV8NPath := cV7GPath + "/infoProcRet[1]"

								If nOpc == 4
									verifyDelModelRows( "MODEL_V8N", nOpc, cV8NPath )
								EndIf
							
								While oDados:XPathHasNode( cV8NPath )

									oModel:GetModel( "MODEL_V8N" ):lValid	:= .T.

									If nOpc == 4 .Or. nV8N > 1
										oModel:GetModel( "MODEL_V8N" ):AddLine()
									EndIf
											
									oModel:LoadValue( "MODEL_V8N", "V8N_TPPRCR", FTafGetVal( cV8NPath, "C", .F., @aIncons, .T.,,,,,.T., "tpProcRet" ) )	
									oModel:LoadValue( "MODEL_V8N", "V8N_NRPRCR", FTafGetVal( cV8NPath, "C", .F., @aIncons, .T.,,,,,.T., "nrProcRet" ) )

									If !Empty(oDados:XPathGetAtt( cV8NPath ,"codSusp" ))
										oModel:LoadValue( "MODEL_V8N", "V8N_CODSUP", FTafGetVal( cV8NPath, "C", .F., @aIncons, .T.,,,,,.T., "codSusp"   ) )	
									EndIf

									// V8O|infoValores
									nV8O := 1
									cV8OPath := cV8NPath + "/infoValores[1]"
									
									If nOpc == 4
										verifyDelModelRows( "MODEL_V8O", nOpc, cV8OPath )	
									EndIf
								
									While oDados:XPathHasNode( cV8OPath )

										oModel:GetModel( "MODEL_V8O" ):lValid	:= .T.

										If nOpc == 4 .Or. nV8O > 1
											oModel:GetModel( "MODEL_V8O" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V8O", "V8O_INDAPU", FTafGetVal( cV8OPath, "C", .F., @aIncons, .T.,,,,,.T., "indApuracao"  ) )

										If !Empty(oDados:XPathGetAtt( cV8OPath , "vlrNRetido" ))
											oModel:LoadValue( "MODEL_V8O", "V8O_VLNRET", FTafGetVal( cV8OPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrNRetido"   ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8OPath , "vlrDepJud" ))
											oModel:LoadValue( "MODEL_V8O", "V8O_VLDEPJ", FTafGetVal( cV8OPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrDepJud"    ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8OPath , "vlrCmpAnoCal" ))
											oModel:LoadValue( "MODEL_V8O", "V8O_VLCPAC", FTafGetVal( cV8OPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrCmpAnoCal" ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8OPath , "vlrCmpAnoAnt" ))
											oModel:LoadValue( "MODEL_V8O", "V8O_VLCPAA", FTafGetVal( cV8OPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrCmpAnoAnt" ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8OPath , "vlrRendSusp" ))
											oModel:LoadValue( "MODEL_V8O", "V8O_VLRSUS", FTafGetVal( cV8OPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrRendSusp"  ) )
										EndIf

										// V8P|dedSusp
										nV8P     := 1
										cV8PPath := cV8OPath + "/dedSusp[1]"

										If nOpc == 4
											verifyDelModelRows( "MODEL_V8P", nOpc, cV8PPath )
										EndIf
										
										While oDados:XPathHasNode( cV8PPath )

											oModel:GetModel( "MODEL_V8P" ):lValid	:= .T.

											If nOpc == 4 .Or. nV8P > 1
												oModel:GetModel( "MODEL_V8P" ):AddLine()
											EndIf
													
											oModel:LoadValue( "MODEL_V8P", "V8P_CHAVE" , StrZero(nV8P, TAMSX3("V8P_CHAVE")[1])                                   )		
											oModel:LoadValue( "MODEL_V8P", "V8P_TPDEDU", FTafGetVal( cV8PPath, "C", .F., @aIncons, .T.,,,,,.T., "indTpDeducao" ) )

											If !Empty(oDados:XPathGetAtt( cV8PPath , "vlrDedSusp" ))
												oModel:LoadValue( "MODEL_V8P", "V8P_VLSUSP", FTafGetVal( cV8PPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrDedSusp"   ) )
											EndIf
																				
											// V8Q|benefPen
											nV8Q     := 1
											cV8QPath := cV8PPath + "/benefPen[1]"
											
											If nOpc == 4
												verifyDelModelRows( "MODEL_V8Q", nOpc, cV8QPath )
											EndIf

											While oDados:XPathHasNode( cV8QPath )

												oModel:GetModel( "MODEL_V8Q" ):lValid	:= .T.

												If nOpc == 4 .Or. nV8Q > 1
													oModel:GetModel( "MODEL_V8Q" ):AddLine()
												EndIf
														
												oModel:LoadValue( "MODEL_V8Q", "V8Q_CPFDEP", FTafGetVal( cV8QPath, "C", .F., @aIncons, .T.,,,,,.T., "cpfDep"       ) )
												oModel:LoadValue( "MODEL_V8Q", "V8Q_VLDEPS", FTafGetVal( cV8QPath, "N", .F., @aIncons, .T.,,,,,.T., "vlrDepenSusp" ) )										
												
												nV8Q++
												cV8QPath := cV8PPath + "/benefPen[" + cValToChar( nV8Q ) + "]"

											EndDo										

											nV8P++
											cV8PPath := cV8OPath + "/dedSusp[" + cValToChar( nV8P ) + "]"

										EndDo										
										
										nV8O++
										cV8OPath := cV8NPath + "/infoValores[" + cValToChar( nV8O ) + "]"

									EndDo
									
									nV8N++
									cV8NPath := cV7GPath + "/infoProcRet[" + cValToChar( nV8N ) + "]"

								EndDo
								
								nV7G++
								cV7GPath := cV7DPath + "/infoCRIRRF[" + cValToChar( nV7G ) + "]"

							EndDo

							// V8S|infoIRComplem
							nV8S     := 1
							cV8SPath := cV7DPath + "/infoIRComplem[1]"
							
							If nOpc == 4
								verifyDelModelRows( "MODEL_V8S", nOpc, cV8SPath )
							EndIf
						
							While oDados:XPathHasNode( cV8SPath )

								oModel:GetModel( "MODEL_V8S" ):lValid	:= .T.

								If nOpc == 4 .Or. nV8S > 1
									oModel:GetModel( "MODEL_V8S" ):AddLine()
								EndIf

								If !Empty(oDados:XPathGetAtt( cV8SPath ,"dtLaudo" ))
									oModel:LoadValue( "MODEL_V8S", "V8S_DTLAUD", FTafGetVal( cV8SPath, "D", .F., @aIncons, .T.,,,,,.T., "dtLaudo" ) )	
								EndIf

								// V8S|infoDep
								nV8SInfoDep     := 1
								cV8SInfoDepPath := cV8SPath + "/infoDep[1]"

								If nOpc == 4
									verifyDelModelRows( "MODEL_V8S", nOpc, cV8SInfoDepPath )
								EndIf
							
								While oDados:XPathHasNode( cV8SInfoDepPath )

									If nOpc == 4 .Or. nV8SInfoDep > 1
										oModel:GetModel( "MODEL_V8S" ):AddLine()
									EndIf

									If !Empty(oDados:XPathGetAtt( cV8SInfoDepPath,"cpfDep" ))

										oModel:LoadValue( "MODEL_V8S", "V8S_CPFDEP", FTafGetVal( cV8SInfoDepPath, "C", .F., @aIncons, .T.,,,,,.T., "cpfDep"   ) )	

										If !Empty(oDados:XPathGetAtt( cV8SInfoDepPath,"dtNascto" ))
											oModel:LoadValue( "MODEL_V8S", "V8S_DTNASC", FTafGetVal( cV8SInfoDepPath, "D", .F., @aIncons, .T.,,,,,.T., "dtNascto" ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8SInfoDepPath,"nome" ))
											oModel:LoadValue( "MODEL_V8S", "V8S_NOME"  , FTafGetVal( cV8SInfoDepPath, "C", .F., @aIncons, .T.,,,,,.T., "nome"     ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8SInfoDepPath,"depIRRF" ))
											oModel:LoadValue( "MODEL_V8S", "V8S_DEPIR" , FTafGetVal( cV8SInfoDepPath, "C", .F., @aIncons, .T.,,,,,.T., "depIRRF"  ) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8SInfoDepPath,"tpDep" ))
											oModel:LoadValue( "MODEL_V8S", "V8S_TPDEP", FGetIdInt("tpDep", "", FTafGetVal( cV8SInfoDepPath, "C", .F., @aIncons, .T.,,,,,.T., "tpDep" ),, .F.,, @cInconMsg, @nSeqErrGrv) )
										EndIf

										If !Empty(oDados:XPathGetAtt( cV8SInfoDepPath,"descrDep" ))
											oModel:LoadValue( "MODEL_V8S", "V8S_DESCDE", FTafGetVal( cV8SInfoDepPath, "C", .F., @aIncons, .T.,,,,,.T., "descrDep" ) )
										EndIf

									EndIf

									nV8SInfoDep++
									cV8SInfoDepPath := cV8SPath + "/infoDep[" + cValToChar( nV8SInfoDep ) + "]"

								EndDo										
								
								nV8S++
								cV8SPath := cV7DPath + "/infoIRComplem[" + cValToChar( nV8S ) + "]"

							EndDo										

						Else

							cInconMsg := STR0014 + cCpfTrb + STR0015 + cNrProc + ")"

						EndIf

						nV7D++
						cV7DPath := cCabec + "ideTrab[" + cValToChar( nV7D ) + "]"
						
					EndDo

				EndIf

			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg) .And. Empty(aIncons)

				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf

			Else

				Aadd(aIncons, cInconMsg)
				DisarmTransaction()

			EndIf

			oModel:DeActivate()
			TafClearModel(oModel)

		EndIf
		
	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609Xml

Funcao de geracao do XML para atender o registro S-2500
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias		-	Alias da tabela
nRecno		-	Recno do registro corrente
nOpc		-	Operação a ser realizada
lJob		-	Informa se foi chamado por job
lRemEmp		-	Exclusivo do Evento S-1000
cSeqXml		-	Número sequencial para composição da chave ID do XML
lInfoRPT	-	Indica se a geração de XML deve gerar informações na tabela de relatório

@Return:
cXml - Estrutura do Xml do Layout S-2501

@author Alexandre de Lima/JR GOMES
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF609Xml( cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical,; 
					lRemEmp as Logical, cSeqXml as Character )
					
	Local cXml      as character
    Local cLayout   as character
	Local cReg      as character
	Local cFilBkp   as character
	Local cXml0561	as character
    Local nRecnoSM0 as numeric
	Local lDic0103  as Logical



	Default cALias  := ""
    Default cSeqXml := ""
	Default nRecno  := V7C->(Recno())
	Default nOpc    := 0
	Default lRemEmp := .F.
	Default lJob    := .F.
	
	
	lDic0103  := TafColumnPos( "V7C_IDESEQ" ) 
	cReg   	  := "ContProc"
	cXml      := ""
	cXml0561  := ""
	cLayout   := "2501"
	nRecnoSM0 := SM0->(Recno())
	cFilBkp   := cFilAnt

	("V7C")->( DBGoTo( nRecno ) )

	If IsInCallStack("TafNewBrowse") .And. ( V7C->V7C_FILIAL <> cFilAnt ).AND.!Empty(V7C->V7C_FILIAL)
        cFilAnt := V7C->V7C_FILIAL
    EndIf
	
	
	If __cPicVrMen == Nil
		__cPicPerRef := PesqPict( "V7E", "V7E_PERREF", 7 )
	EndIf

	cXml    := "<ideProc>"
	cXml    +=      xTafTag( "nrProcTrab"   , Posicione( "V9U", 1, xFilial( "V9U" ) + V7C->V7C_IDPROC, "V9U_NRPROC" ),, .F.)
	cXml    +=      xTafTag( "perApurPgto"  , Transform( V7C->V7C_PERAPU, __cPicPerRef) ,, .F.)
	If lSimpl0103  .and. lDic0103
		cXml    +=      xTafTag( "ideSeqProc"  , V7C->V7C_IDESEQ ,, .T.)
	EndIf
	cXml    +=      xTafTag( "obs"          , V7C->V7C_OBS,, .T.)
	cXml    += "</ideProc>"
	
	V7D->( DBSetOrder(2) )
	V7E->( DBSetOrder(2) )
	V7F->( DBSetOrder(2) )
	V7G->( DBSetOrder(2) )
	V8X->( DBSetOrder(1) )
	V8Y->( DBSetOrder(1) )
	V8K->( DBSetOrder(1) )
	V8L->( DBSetOrder(1) )
	V8M->( DBSetOrder(1) )
	V8N->( DBSetOrder(1) )
	V8O->( DBSetOrder(1) )
	V8P->( DBSetOrder(1) )
	V8Q->( DBSetOrder(1) )	
	V8S->( DbSetOrder(1) )

	If V7D->( MsSeek( xFilial("V7D") + V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU) ) )
		While V7D->( !Eof() ) .and. V7D->(V7D_FILIAL + V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU) == xFilial("V7C") + V7C->(V7C_ID + V7C_VERSAO  + V7C->V7C_IDPROC + V7C->V7C_PERAPU)
			
			cXml += '<ideTrab cpfTrab="' + V7D->V7D_CPFTRA + '">'

			If V7E->( MsSeek( xFilial("V7E") + V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )

				If __cPicVrMen == Nil

					__cPicVrMen  := PesqPict( "V7E", "V7E_VRMEN" )
					__cPicVrCP   := PesqPict( "V7E", "V7E_VRCP"  )

					If !lSimpl0102

						__cPicVrRen  := PesqPict( "V7E", "V7E_VERREN")
						__cPicVrIRF  := PesqPict( "V7E", "V7E_VRIRRF")

					EndIf

				EndIf

				While V7E->( !Eof() ) .and. V7E->(V7E_FILIAL + V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA ) == xFilial("V7D") + V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA)

					cXml    += "<calcTrib"
					cXml    +=      xTafTag( "perRef"       , Transform( V7E->V7E_PERREF   , __cPicPerRef ) ,             , .F.,,.F.,.T.)
					cXml    +=      xTafTag( "vrBcCpMensal" , V7E->V7E_VRMEN                                , __cPicVrMen , .F.,,.T.,.T.)
					cXml    +=      xTafTag( "vrBcCp13"     , V7E->V7E_VRCP                                 , __cPicVrCP  , .F.,,.T.,.T.)

					If !lSimpl0102
						cXml    +=      xTafTag( "vrRendIRRF"   , V7E->V7E_VERREN                               , __cPicVrRen , .F.,,.T.,.T.)
						cXml    +=      xTafTag( "vrRendIRRF13" , V7E->V7E_VRIRRF                               , __cPicVrIRF , .F.,,.T.,.T.)
					EndIf	

					cXml    += ">"

					If V7F->( MsSeek( xFilial("V7F") + V7E->( V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA + V7E_PERREF) ) )

						While V7F->( !Eof() ) .and. V7F->(V7F_FILIAL + V7F_ID + V7F_VERSAO + V7F_IDPROC + V7F_PERAPU + V7F_CPFTRA + V7F_PERREF) == xFilial("V7E") + V7E->(V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA + V7E_PERREF)
							cXml    +="<infoCRContrib"
							cXml    +=      xTafTag( "tpCR" , POSICIONE("V9T",1, xFilial("V9T")+V7F->V7F_IDCODR,"V9T_CODIGO"),           , .F.,,   ,.T.)
							If FindFunction('getPicCache')
								cXml    +=      xTafTag( "vrCR" , V7F->V7F_VRCR                                                  , getPicCache('V7F','V7F_VRCR'), .F.,,.T.,.T.)
							EndIf
							cXml    +="/>"

							V7F->( DbSkip())
						EndDo
					EndIf

					cXml    += "</calcTrib>"

					V7E->( DbSkip())

				EndDo
			EndIf
			
			If V7G->( MsSeek( xFilial("V7G") + V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA) ) )
				
				If !lSimpl0102

					While V7G->( !Eof() ) .and. V7G->(V7G_FILIAL + V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA ) == xFilial("V7D") + V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA)
						cXml    +="<infoCRIRRF"
						cXml    +=      xTafTag( "tpCR" , POSICIONE("V9T",1, xFilial("V9T")+V7G->V7G_TPCR,"V9T_CODIGO"),           						, .F.,,   ,.T.)
						If FindFunction('getPicCache')
							cXml    +=      xTafTag( "vrCR" , V7G->V7G_VRCR                                                , getPicCache('V7G','V7G_VRCR')	, .F.,,.T.,.T.)
						EndIf 
						cXml    +="/>"

						V7G->( DbSkip())
					EndDo

				ElseIf lSimpl0102 .OR.(lSimpl0103 .and. lDic0103)

					While V7G->( !Eof() ) .and. V7G->(V7G_FILIAL + V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA ) == xFilial("V7D") + V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA)
						cXml    +="<infoCRIRRF"
						cXml    +=      xTafTag( "tpCR" , POSICIONE("V9T",1, xFilial("V9T")+V7G->V7G_TPCR,"V9T_CODIGO"),           						, .F.,,   ,.T.)
						If FindFunction('getPicCache')
							cXml    +=      xTafTag( "vrCR" , V7G->V7G_VRCR                                                , getPicCache('V7G','V7G_VRCR')	, .F.,,.T.,.T.)

							If lSimpl0103 .and. lDic0103
								cXml    +=      xTafTag( "vrCR13" , V7G->V7G_VRCR13                                                , getPicCache('V7G','V7G_VRCR13')	, .T.,,.F.,.T.)
							EndIf 
						EndIf
						cXml    +=">"

						If V8X->(MsSeek(xFilial("V8X") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR ) ) )                                                                                                                                                                                    
						
							If __cPicVrRed == Nil
								__cPicVrRed  	:= PesqPict( "V8X", "V8X_VLRTRI" )
								__cPicVrT13   	:= PesqPict( "V8X", "V8X_VLRT13" )
								__cPicVrMGr  	:= PesqPict( "V8X", "V8X_VLRIMG" )
								__cPicVrI65  	:= PesqPict( "V8X", "V8X_VLRI65" )
								__cPicVrJur  	:= PesqPict( "V8X", "V8X_VLJRMO" )
								__cPicVrITr   	:= PesqPict( "V8X", "V8X_VLRINT" )
								__cPicVrPOf   	:= PesqPict( "V8X", "V8X_VLPRVO" )
							EndIf

							While V8X->( !Eof() ) .and. V8X->(V8X_FILIAL + V8X_ID + V8X_VERSAO + V8X_IDPROC + V8X_PERAPU + V8X_CPFTRA + V8X_TPCR ) == xFilial("V7G") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR)
								cXml	+=		"<infoIR"
								cXml    +=      xTafTag( "vrRendTrib" 		, 			V8X->V8X_VLRTRI, 	__cPicVrRed, .T.,,   ,.T.)
								cXml    +=      xTafTag( "vrRendTrib13" 	, 			V8X->V8X_VLRT13, 	__cPicVrT13, .T.,,   ,.T.)
								cXml    +=      xTafTag( "vrRendMoleGrave" 	,			V8X->V8X_VLRIMG,		__cPicVrMGr, .T.,,   ,.T.)
								If lSimpl0103 .and. lDic0103
									cXml    +=      xTafTag( "vrRendMoleGrave13" 	,	    V8X->V8X_IMG13,		__cPicVrMGr, .T.,,   ,.T.) //// Alterar campo
								EndIf 
								cXml    +=      xTafTag( "vrRendIsen65" 	,			V8X->V8X_VLRI65,		__cPicVrI65, .T.,,   ,.T.)
								If lSimpl0103 .and. lDic0103
									cXml    +=      xTafTag( "vrRendIsen65Dec" 	,			V8X->V8X_I65DEC,		__cPicVrI65, .T.,,   ,.T.) //// Alterar campo
								EndIf 
								cXml    +=      xTafTag( "vrJurosMora" 		, 			V8X->V8X_VLJRMO,		__cPicVrJur, .T.,,   ,.T.)
								If lSimpl0103 .and. lDic0103
									cXml    +=      xTafTag( "vrJurosMora13" 	, 			V8X->V8X_MOR13,		__cPicVrJur, .T.,,   ,.T.) //// Alterar campo
								EndIf 
								cXml    +=      xTafTag( "vrRendIsenNTrib" 	,			V8X->V8X_VLRINT,		__cPicVrITr, .T.,,   ,.T.)
								cXml    +=      xTafTag( "descIsenNTrib" 	, 			V8X->V8X_DCRINT,  		       , .T.,,   ,.T.)
								cXml    +=      xTafTag( "vrPrevOficial" 	, 			V8X->V8X_VLPRVO,		__cPicVrPOf, .T.,,   ,.T.)
								If lSimpl0103 .and. lDic0103
									cXml    +=      xTafTag( "vrPrevOficial13" 	, 			V8X->V8X_PREV13,		__cPicVrPOf, .T.,,   ,.T.) //// Alterar campo
								EndIf 

								If lSimpl0103 .and. lDic0103
									cXml0561    +=		">"

									cXml0561    +=		"<rendIsen0561"
									cXml0561    +=      xTafTag( "vlrDiarias" 			, 			V8X->V8X_VLRDIA, 	__cPicVrRed, .T.,,   ,.T.)
									cXml0561    +=      xTafTag( "vlrAjudaCusto" 		, 			V8X->V8X_VLRAJU, 	__cPicVrRed, .T.,,   ,.T.)
									cXml0561    +=      xTafTag( "vlrIndResContrato" 	, 			V8X->V8X_VLRCON, 	__cPicVrRed, .T.,,   ,.T.)
									cXml0561    +=      xTafTag( "vlrAbonoPec" 			, 			V8X->V8X_VLRABN, 	__cPicVrRed, .T.,,   ,.T.)
									cXml0561    +=      xTafTag( "vlrAuxMoradia" 		, 			V8X->V8X_VLMORD, 	__cPicVrRed, .T.,,   ,.T.)

									cXml0561    +=		"/>"

									If !cXml0561 == "><rendIsen0561/>"
										cXml+=	cXml0561
										cXml+= "</infoIR>
									Else
										cXml    +=		"/>"
									EndIf 

									cXml0561 := ""
								Else
									cXml    +=		"/>"
								EndIf 

								V8X->( DbSkip())
							EndDo
						EndIf

						If V8Y->(MsSeek(xFilial("V8Y") + V7G->(V7G_ID +  V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR ) ) )
							
							If __cPicVrCus == Nil
								__cPicVrCus  	:= PesqPict( "V8Y", "V8Y_VLRCUS" )
								__cPicVrAdv   	:= PesqPict( "V8Y", "V8Y_VLRADV" )
							EndIf

							cXml +=	"<infoRRA"
							cXml +=		xTafTag("descRRA"					,V8Y->V8Y_DESCRA,				   , .F.,,   ,.T. )
							cXml +=     xTafTag("qtdMesesRRA"				,V8Y->V8Y_QTMRRA, 				   , .F.,,   ,.T. )
							cXml += ">"
							cXml +=		"<despProcJud"
							cXml +=			xTafTag("vlrDespCustas"			,V8Y->V8Y_VLRCUS,		__cPicVrCus, .F.,,.T.,.T.)
							cXml +=			xTafTag("vlrDespAdvogados"		,V8Y->V8Y_VLRADV,		__cPicVrAdv, .F.,,.T.,.T.)
							cXml +=		"/>"

							If V8K->(MsSeek(xFilial("V8K") + V8Y->(V8Y_ID + V8Y_VERSAO + V8Y_IDPROC + V8Y_PERAPU + V8Y_CPFTRA + V8Y_TPCR ) ) )	
								While V8K->( !Eof() ) .and. V8K->(V8K_FILIAL + V8K_ID + V8K_VERSAO + V8K_IDPROC + V8K_PERAPU + V8K_CPFTRA + V8K_TPCR ) == xFilial("V8Y") + V8Y->( V8Y_ID + V8Y_VERSAO + V8Y_IDPROC + V8Y_PERAPU + V8Y_CPFTRA + V8Y_TPCR )

									If __cPicVlrAd == Nil
										__cPicVlrAd  	:= PesqPict( "V8K", "V8K_VLRADV" )
									EndIf

									cXml +=	"<ideAdv"
									cXml +=			xTafTag("tpInsc"		,V8K->V8K_TPINSC,		, .F.,,   ,.T. )
									cXml +=			xTafTag("nrInsc"		,V8K->V8K_NRINSC,		, .F.,,   ,.T. )
									cXml +=			xTafTag("vlrAdv"		,V8K->V8K_VLRADV,		__cPicVlrAd, .T.,,   ,.T.)
									cXml +=	"/>"

									V8K->( DbSkip())
								EndDo
							EndIf
							cXml +=	"</infoRRA>
		
						EndIf

						If V8L->(MsSeek(xFilial("V8L") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR ) ) )

								While V8L->( !Eof() ) .and. V8L->(V8L_FILIAL + V8L_ID + V8L_VERSAO + V8L_IDPROC + V8L_PERAPU + V8L_CPFTRA + V8L_TPCR ) == xFilial("V7G") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR)

									If __cPicVrDed == Nil
										__cPicVrDed  	:= PesqPict( "V8L", "V8L_VLRDED" )
									EndIf

									cXml    +="<dedDepen"
									cXml    +=      xTafTag( "tpRend" , 		V8L->V8L_TPREND,			, .F.,,   ,.T.)
									cXml    +=      xTafTag( "cpfDep" , 		V8L->V8L_CPFDEP,			, .F.,,   ,.T.)
									cXml    +=      xTafTag( "vlrDeducao" , 	V8L->V8L_VLRDED, __cPicVrDed, .F.,,   ,.T.)
									cXml    +="/>"

									V8L->( DbSkip())
								EndDo
													
						EndIf

						If V8M->(MsSeek(xFilial("V8M") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR ) ) )

								While V8M->( !Eof() ) .and. V8M->(V8M_FILIAL + V8M_ID + V8M_VERSAO + V8M_IDPROC + V8M_PERAPU + V8M_CPFTRA + V8M_TPCR ) == xFilial("V7G") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR)

									If __cPicVlPen == Nil
										__cPicVlPen  	:= PesqPict( "V8M", "V8M_VLPENS" )
									EndIf

									cXml    +="<penAlim"
									cXml    +=      xTafTag( "tpRend" , 		V8M->V8M_TPREND, 			, .F.,,   ,.T.)
									cXml    +=      xTafTag( "cpfDep" , 		V8M->V8M_CPFDEP,			, .F.,,   ,.T.)
									cXml    +=      xTafTag( "vlrPensao" , 		V8M->V8M_VLPENS, __cPicVlPen, .F.,,   ,.T.)
									cXml    +="/>"

									V8M->( DbSkip())
								EndDo
													
						EndIf

						If V8N->(MsSeek(xFilial("V8N") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR ) ) )

							While V8N->( !Eof() ) .and. V8N->(V8N_FILIAL + V8N_ID + V8N_VERSAO + V8N_IDPROC + V8N_PERAPU + V8N_CPFTRA + V8N_TPCR ) == xFilial("V7G") + V7G->(V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA + V7G_TPCR)

									cXml    +="<infoProcRet"
									cXml    +=      xTafTag( "tpProcRet" 	, 		V8N->V8N_TPPRCR,		, .F.,,   ,.T.)
									cXml    +=      xTafTag( "nrProcRet" 	, 		V8N->V8N_NRPRCR,		, .F.,,   ,.T.)
									cXml    +=      xTafTag( "codSusp" 		, 		V8N->V8N_CODSUP,		, .T.,,   ,.T.)
									cXml    +=">"

									If V8O->(MsSeek(xFilial("V8O") + V8N->(V8N_ID + V8N_VERSAO + V8N_IDPROC + V8N_PERAPU + V8N_CPFTRA + V8N_TPCR + V8N_TPPRCR + V8N_NRPRCR + V8N_CODSUP) ) )

										While V8O->( !Eof() ) .and. V8O->(V8O_FILIAL + V8O_ID + V8O_VERSAO + V8O_IDPROC + V8O_PERAPU + V8O_CPFTRA + V8O_TPCR + V8O_TPPRCR + V8O_NRPRCR + V8O_CODSUP ) == xFilial("V8N") + V8N->(V8N_ID + V8N_VERSAO + V8N_IDPROC + V8N_PERAPU + V8N_CPFTRA + V8N_TPCR + V8N_TPPRCR + V8N_NRPRCR + V8N_CODSUP)
											If __cPicVlNRe == Nil
												__cPicVlNRe  	:= PesqPict( "V8O", "V8O_VLNRET" )
												__cPicVlDJu  	:= PesqPict( "V8O", "V8O_VLDEPJ" )
												__cPicVlCAC  	:= PesqPict( "V8O", "V8O_VLCPAC" )
												__cPicVlCAA  	:= PesqPict( "V8O", "V8O_VLCPAA" )
												__cPicVlReS  	:= PesqPict( "V8O", "V8O_VLRSUS" )
											EndIf

											cXml    +="<infoValores"
											cXml    +=      xTafTag( "indApuracao" 		, V8O->V8O_INDAPU, 					, .F.,,,.T.)
											cXml    +=      xTafTag( "vlrNRetido" 		, V8O->V8O_VLNRET, 		__cPicVlNRe	, .T.,,,.T.)
											cXml    +=      xTafTag( "vlrDepJud" 		, V8O->V8O_VLDEPJ,		__cPicVlDJu	, .T.,,,.T.)
											cXml    +=      xTafTag( "vlrCmpAnoCal" 	, V8O->V8O_VLCPAC,	 	__cPicVlCAC	, .T.,,,.T.)
											cXml    +=      xTafTag( "vlrCmpAnoAnt" 	, V8O->V8O_VLCPAA,	 	__cPicVlCAA	, .T.,,,.T.)
											cXml    +=      xTafTag( "vlrRendSusp" 		, V8O->V8O_VLRSUS,		__cPicVlReS	, .T.,,,.T.)
											cXml    +=">"
																						
											If V8P->(MsSeek(xFilial("V8P") + V8O->(V8O_ID + V8O_VERSAO + V8O_IDPROC + V8O_PERAPU + V8O_CPFTRA + V8O_TPCR + V8O_TPPRCR + V8O_NRPRCR + V8O_CODSUP + V8O_INDAPU ) ) )

												If __cPicVlDSu == Nil
													__cPicVlDSu  	:= PesqPict( "V8P", "V8P_VLSUSP" )
												EndIf

												While V8P->( !Eof() ) .and. V8P->(V8P_FILIAL + V8P_ID + V8P_VERSAO + V8P_IDPROC + V8P_PERAPU + V8P_CPFTRA + V8P_TPCR + V8P_TPPRCR + V8P_NRPRCR + V8P_CODSUP + V8P_INDAPU ) == xFilial("V8O") + V8O->(V8O_ID + V8O_VERSAO + V8O_IDPROC + V8O_PERAPU + V8O_CPFTRA + V8O_TPCR + V8O_TPPRCR + V8O_NRPRCR + V8O_CODSUP + V8O_INDAPU)
													
													cXml    +="<dedSusp"
													cXml    +=      xTafTag( "indTpDeducao" 	, V8P->V8P_TPDEDU,		      , .F.,,   ,.T.)
													cXml    +=      xTafTag( "vlrDedSusp" 		, V8P->V8P_VLSUSP, __cPicVlDSu, .T.,,.T.,.T.)
													cXml    +=">"
												
													If V8Q->(MsSeek(xFilial("V8Q") + V8P->(V8P_ID + V8P_VERSAO + V8P_IDPROC + V8P_PERAPU + V8P_CPFTRA + V8P_TPCR + V8P_TPPRCR + V8P_NRPRCR + V8P_CODSUP + V8P_INDAPU + V8P_CHAVE) ) )

														If __cPicVlDep == Nil
															__cPicVlDep  	:= PesqPict( "V8P", "V8P_VLSUSP" )
														EndIf

														While V8Q->( !Eof() ) .and. V8Q->(V8Q_FILIAL + V8Q_ID + V8Q_VERSAO + V8Q_IDPROC + V8Q_PERAPU + V8Q_CPFTRA + V8Q_TPCR + V8Q_TPPRCR + V8Q_NRPRCR + V8Q_CODSUP + V8Q_INDAPU + V8Q_CHAVE ) == xFilial("V8P") + V8P->(V8P_ID + V8P_VERSAO + V8P_IDPROC + V8P_PERAPU + V8P_CPFTRA + V8P_TPCR + V8P_TPPRCR + V8P_NRPRCR + V8P_CODSUP + V8P_INDAPU + V8P_CHAVE)

															cXml    +="<benefPen"
															cXml    +=      xTafTag( "cpfDep" 		, V8Q->V8Q_CPFDEP, 			, .F.,,.T.,.T.)
															cXml    +=      xTafTag( "vlrDepenSusp" , V8Q->V8Q_VLDEPS, __cPicVlDep, .F.,,.T.,.T.)
															cXml    +="/>"
															V8Q->( DbSkip())

														EndDo

													EndIf

													cXml    +="</dedSusp>"
													V8P->( DbSkip())
												EndDo
											EndIf	
											cXml    +="</infoValores>"
											V8O->( DbSkip())
										EndDo
									EndIf	
									cXml    +="</infoProcRet>"	
									V8N->( DbSkip())
								EndDo
						EndIf

						cXml    +="</infoCRIRRF>"
						V7G->( DbSkip())
					EndDo
				EndIf
						
			EndIf

				If V8S->( MsSeek( xFilial("V8S") + V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) ) //Ajustar de acordo com o relacionamento e indice
												
					cXml +=	"<infoIRComplem"
					cXml +=		xTafTag("dtLaudo"	,V8S->V8S_DTLAUD ,		, .T.,,   ,.T.)
					cXml +=	">"

					While V8S->( !Eof() ) .and. V8S->(V8S_FILIAL + V8S_ID + V8S_VERSAO + V8S_IDPROC + V8S_PERAPU + V8S_CPFTRA ) == xFilial("V7D") + V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA )
						
						cXml +=	"<infoDep"
						cXml +=		xTafTag("cpfDep"	, V8S->V8S_CPFDEP 														,, .F.,,,.T.)
						cXml +=		xTafTag("dtNascto"	, V8S->V8S_DTNASC 														,, .T.,,,.T.)
						cXml +=		xTafTag("nome"		, V8S->V8S_NOME   														,, .T.,,,.T.)
						cXml +=		xTafTag("depIRRF"	, V8S->V8S_DEPIR  														,, .T.,,,.T.)
						cXml +=		xTafTag("tpDep"		, Posicione( "CMI", 1, xFilial("CMI") + V8S->V8S_TPDEP, "CMI_CODIGO" )  ,, .T.,,,.T.)
						cXml +=		xTafTag("descrDep"	, V8S->V8S_DESCDE 														,, .T.,,,.T.)
						cXml +=	"/>"

						V8S->(DbSkip())

					EndDo

					cXml +=	"</infoIRComplem>"
				EndIf
		
			cXml += "</ideTrab>"

			V7D->( DbSkip())
		EndDo			
	EndIf

    If nRecnoSM0 > 0
        SM0->(dbGoto(nRecnoSM0))
    EndIf

    cXml := xTafCabXml(cXml,"V7C", cLayout,cReg,,cSeqXml)

    If !lJob
        xTafGerXml(cXml,cLayout)
    EndIf

	cFilAnt := cFilBkp
	
Return( cXml )

/*/{Protheus.doc} SetlDic0103
	Iniciaiza variavel estatica validando se o dicionario existe
	@type  Static Function
	@author ucas.passos
	@since 30/08/2024
	@version version
/*/
Static Function SetlDic0103()
	
	If lDic0103 == Nil 
		lDic0103 := TafColumnPos( "V7C_IDESEQ" ) 
	EndIf 
	
Return 
