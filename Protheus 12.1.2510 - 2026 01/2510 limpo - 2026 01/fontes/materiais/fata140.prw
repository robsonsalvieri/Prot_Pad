#INCLUDE "FATA140.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "dbtree.ch"  
#INCLUDE "FWMVCDEF.CH"

Static oQueryHasCh  := Nil
Static oQueryLookup := Nil
Static oQueryTree   := Nil

PUBLISH MODEL REST NAME FATA140 source FATA140

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MenuDef   ³ Autor ³ Vendas & CRM          ³ Data ³11.04.12  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRotina                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina	:= {}
Local aRet		:= {}
Local nX 		:= 1

aRotina := FwMVCMenu('FATA140')

Aadd(aRotina,{STR0001,"FT140Estru",0 , 4}) 	//"Estrutura"

If IsInCallStack("FATA140")
	aRotina:= CRMXINCROT("ACU",aRotina)
EndIf

If ExistBlock("FT140BRW")
	aRet := ExecBlock("FT140BRW",.F.,.F.)
	If ValType(aRet) == "A"
		For nX := 1 to Len(aRet)
			AAdd(aRotina,aClone(aRet[nX]))
		Next nX
	EndIf
EndIf
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ViewDef   ³ Autor ³ Vendas & CRM          ³ Data ³11.04.12  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao da View                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³oView                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ViewDef()
Local oModel   := FWLoadModel( 'FATA140' )			// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oStruACU := FWFormStruct( 2, 'ACU' )			// Cria as estruturas a serem usadas na View
Local oView											// Interface de visualização construída
Local lView	   := !IsInCallStack('FT140Tree')		// Se estiver na tela de estrutura não permite manipular o campo ACU_CODPAI

oView := FWFormView():New()							// Cria o objeto de View
oView:SetContinuousForm() 							// Seta formulario continuo 
oView:SetModel( oModel )							// Define qual Modelo de dados será utilizado				
oView:AddField( 'VIEW_ACU', oStruACU, 'ACUMASTER') // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oStruACU:SetProperty('ACU_CODPAI', MVC_VIEW_CANCHANGE,lView)

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )			

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_ACU', 'SUPERIOR' )
			
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ModelDef  ³ Autor ³ Vendas & CRM          ³ Data ³11.04.12  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao do Model                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³oModel                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

Local oModel 	:= Nil	
Local oStruACU	:= FWFormStruct( 1, 'ACU' )
Local cCodWhen	:= ""
Local cBlQlWhen	:= ""

cCodWhen := AllTrim( GetSX3Cache('ACU_COD', 'X3_WHEN') )
cBlQlWhen := AllTrim( GetSX3Cache('ACU_MSBLQL', 'X3_WHEN') )

cCodWhen := "!IsInCallStack('FT140Tree')" + IIf(Empty( cCodWhen ), "", " .And. ") + cCodWhen
cBlQlWhen := "!IsInCallStack('FT140Tree')" + IIf(Empty( cBlQlWhen ), "", " .And. ") + cBlQlWhen

oStruACU:SetProperty('ACU_COD'		,MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, cCodWhen ))
oStruACU:SetProperty('ACU_MSBLQL'	,MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, cBlQlWhen ))

oModel := MPFormModel():New( 'FATA140', /*pre*/,{|oMdl|Ft140Cnf(oMdl:GetOperation(), oMdl)},{|oMdl| Ft140Comm(oMdl) })

oModel:AddFields( 'ACUMASTER', /*cOwner*/, oStruACU ,/*bPreValid*/ )

oModel:SetVldActivate({|oMdl| Ft140VlAct(oMdl) })
oModel:SetDescription( STR0002 ) //"Categoria de Produtos"

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FATA140  ³ Autor ³ Eduardo Perusso Riera ³ Data ³06.09.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Categorias de Produtos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FATA140(nOpcAuto,aAuto)

Default nOpcAuto := 0
Default aAuto 	 := {} 

If !Empty(aAuto)
	FWMVCRotAuto(ModelDef(),"ACU",nOpcAuto,{{"ACUMASTER",aAuto}})
Else
	DEFINE FWMBROWSE oMBrowse ALIAS "ACU" DESCRIPTION STR0002 //"Categoria de Produtos"
	oMBrowse:SetAttach(.T.)
	oMBrowse:SetTotalDefault("ACU_COD","COUNT",) // "Total de Registros"
		
	If nModulo <> 73
		oMBrowse:SetOpenChart( .F. )
	EndIf
		
	ACTIVATE FWMBROWSE oMBrowse
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ft140VlAct³ Autor ³ Vendas & CRM          ³ Data ³11.04.12  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao de Ativacao do Model                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Model                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft140VlAct(oMdl)
Local lRet := .T.

If oMdl:GetOperation() == MODEL_OPERATION_DELETE
	lRet := Ft140VlDel()
EndIf

Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ft140Comm ³ Autor ³ Vendas & CRM          ³ Data ³11.04.12  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Commit do Model                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Model                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft140Comm(oMdl)

Local lRet 			:= .T.
Local lECommerce 	:= SuperGetMV("MV_LJECOMM",,.F.)
Local cCodFilho		:= oMdl:GetValue("ACUMASTER", "ACU_COD")
Local cCodPai		:= oMdl:GetValue("ACUMASTER", "ACU_CODPAI")		
Local lIntPOS 		:= (SuperGetMV("MV_LJSYNT",,"0") == "1")
Local lLj904Ft14	:= ExistFunc("Lj904Ft140")

If isInCallStack("FT140Tree") .AND. (oMdl:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdl:GetOperation() == MODEL_OPERATION_UPDATE)
	oMdl:SetValue("ACUMASTER","ACU_CODPAI",cCodigo)
EndIf

If lIntPOS .AND. oMdl:GetOperation() == MODEL_OPERATION_UPDATE .And. ACU->(FieldPos("ACU_POSFLG") > 0) .And. ACU->(FieldPos("ACU_ECDTEX") > 0) .And. (ACU->ACU_POSFLG == "1")
   oMdl:GetModel("ACUMASTER"):SetValue("ACU_ECDTEX","")
Endif  

If lECommerce .AND. oMdl:GetOperation() == MODEL_OPERATION_UPDATE .AND. (ACU->(FieldPos("ACU_ECDTEX")) > 0) 
	   oMdl:GetModel("ACUMASTER"):SetValue("ACU_ECDTEX","")
Endif

If ( oMdl:GetOperation() == MODEL_OPERATION_INSERT .And. cCodFilho == cCodPai )

	cMay := "ACU"+ Alltrim(xFilial("ACU"))
	ACU->(dbSetOrder(1))
	While ( ACU->( DbSeek(xFilial("ACU")+cCodFilho) ) .or. !MayIUseCode(cMay+cCodPai) )
		cCodFilho := Soma1(cCodFilho,Len(cCodFilho))
	EndDo
	oMdl:LoadValue("ACUMASTER", "ACU_COD", cCodFilho)

ElseIf ( oMdl:GetOperation() == MODEL_OPERATION_UPDATE .And. cCodFilho == cCodPai )
	
	Help(" ",1,"Ft140Comm", , STR0025,1,0)  // "Os códigos da Categoria e Cat.Superior não podem ser iguais." 
	Return (.T.)

EndIf

If lRet .AND. lLj904Ft14
	lRet := Lj904Ft140(lECommerce, @oMdl)	
EndIf

lRet := lRet .AND. FwFormCommit(oMdl) 

If lRet .AND. ExistBlock("FT140GRV")
	ExecBlock("FT140GRV",.F.,.F.)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ft140VlAlt³ Autor ³ Antonio C Ferreira    ³ Data ³22.02.13  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Inclusao/Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ft140VlAlt()
                   
//Limpa variavel para exportacao de dados do ecomerce.

If  ACU->( FieldPos("ACU_ECDTEX") > 0 )
	M->ACU_ECDTEX := ""
EndIf

Return .T.	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ft140VlDel³ Autor ³ Eduardo Perusso Riera ³ Data ³06.09.05  ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Exclusao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft140VlDel()
Local aArea    	:= GetArea()
Local aAreaACV 	:= ACV->(GetArea())
Local lExclui 	:= .T.   
Local lFt140Exc	:= ExistBlock("FT140EXC")//Ponto de entrada para Validar a Exclusão
Local cQuery	:= ""
Local nRecno	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a categoria foi utilizada na tabela de Categ.p/Produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACV->(dbSetOrder(1))
If ACV->(MsSeek(xFilial("ACV")+ACU->ACU_COD))
	Help(,,"FT140VLDEL", , STR0026,1,0) //'Categoria de Produto está vinculada à um Grupo de Produto ou Produto'
	lExclui := .F.
EndIf

nRecno := ACU->(Recno())
If lExclui
	ACU->(dbSetOrder(2))
	If ACU->(MsSeek(xFilial("ACU")+ACU->ACU_COD))
		Help(,,"FT140VLDE2", ,STR0027,1,0) //'A Categoria não pode ser excluida pois é superior na hierarquia'
		lExclui := .F.
	EndIf
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³//Reposiciona no registro atual, pois poderá ter sido disposicionado na validação acima(FT140VLDE2)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ACU->(dbSetOrder(1))
ACU->(dbGoTo(nRecno))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a categoria foi utilizada em Metas de Vendas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lExclui
	cQuery := "SELECT COUNT(*) RECSCT FROM "
	cQuery += RetSqlName("SCT") + " SCT "
	cQuery += " WHERE "                                    
	cQuery += "CT_FILIAL = '"+xFilial("SCT")+"' AND "
	cQuery += "CT_CATEGO = '" + ACU->ACU_COD + "' AND "
	cQuery += "SCT.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSCT",.F.,.T.)

	If TRBSCT->RECSCT > 0
		lExclui := .F.  
	   Help(" ",1,STR0021,,STR0022,1,0)
	Endif 
	TRBSCT->(dbCloseArea())							
EndIf     

If lExclui
	cQuery := "SELECT COUNT(*) RECSAY FROM "
	cQuery += RetSqlName("SAY") + " SAY "
	cQuery += " WHERE "                                    
	cQuery += "AY_FILIAL = '"+xFilial("SAY")+"' AND "
	cQuery += "AY_CATEGO = '" + ACU->ACU_COD + "' AND "
	cQuery += "SAY.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSAY",.F.,.T.)

	If TRBSAY->RECSAY > 0
		lExclui := .F.  
		Help(" ",1,STR0021,,STR0023 ,1,0)
	Endif
	TRBSAY->(dbCloseArea())							
EndIf     
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada a ser executado na Exclusão    ³
//³Validação extra para permitir ou não a exclusão ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExclui .and. lFt140Exc             
	RestArea(aArea)  //Restaura Area ACU antes de executar o execblock
	lExclui:=ExecBlock("FT140EXC",.F.,.F.)
EndIf
RestArea(aAreaACV)
RestArea(aArea)
Return(lExclui)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140Estru³ Autor ³Eduardo Riera          ³ Data ³06.09.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estrutura da categoria de produtos.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias do arquivo a ser manipulado                     ³±±
±±³          ³ ExpN1: Registro a ser manipulado                             ³±±
±±³          ³ ExpN2: Opcao                                                 ³±±
±±³          ³ ExpA1: Array com campos manipulados                          ³±±
±±³          ³ ExpL1: Indica se a chamada ocorreu da rotina de previsao     ³±±
±±³          ³ ExpD1: Data inicial para apresentacao das previsoes de venda ³±±
±±³          ³ ExpD2: Data final ara apresentacao das previsoes de venda    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FT140Estru(cAlias,nReg,nOpc,aCpo,lPrevVenda,dDataIni,dDatafim)
Local aArea     	:= GetArea()
Local aSize     	:= MsAdvSize(.T.)
Local aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Local aObjects  	:= {{100,100,.T.,.T.}}
Local aObjects2 	:= {{45,100,.T.,.T.},{55,100,.T.,.T.,.T.}}
Local aPosObj   	:= {}
Local cCadastro 	:= STR0002 //"Categoria de produtos"
Local oTree,oDlg
Local oBotao1,oBotao2,oBotao3,oBotao4
Local oPanel
Local aHelpP		:={"Indica se deve mostrar na estrutura os ","produtos relacionados a cada uma das" ,"categorias."}
Local aHelpS		:={"Indica si debe mostrar en la estructura","los productos relacionados a cada una","de las categorías."}
Local aHelpE		:={"Determine if products in the structure" ,"related to each one of the categories","must be displayed."}                         
LOCAL aButtons		:= {}
LOCAL aTotais		:={}
LOCAL aDados 		:={{""}}
LOCAL aDadosProd	:={}
Local aRetCopy  	:= If(Type("aRotina")=="A",ACLONE(aRotina),{})

PRIVATE cCodVazio   :=CriaVar("ACU_COD",.F.)
PRIVATE cProdVazio  :=CriaVar("ACV_CODPRO",.F.)
PRIVATE lExisteGrupo:=ACV->(FieldPos("ACV_GRUPO")) > 0
PRIVATE cGrupoVazio :=If(lExisteGrupo,Criavar("ACV_GRUPO",.F.),"")
PRIVATE cRecnoVazio :=StrZero(0,10)
PRIVATE nPosIni:=Len(ACU->ACU_COD)+Len(ACV->ACV_CODPRO)+Len(cGrupoVazio)+2

DEFAULT lPrevVenda := .F.
DEFAULT dDataIni   := dDataBase
DEFAULT dDataFim   := dDataBase

If !lPrevVenda
	// Inclui botoes para manipulacao
	AADD(aButtons,{'bmpincluir',{|| FT140Tree(1,oTree)},OemToAnsi(STR0004)})
	AADD(aButtons,{'NOTE',{|| FT140Tree(2,oTree)},OemToAnsi(STR0005)})
	AADD(aButtons,{'EXCLUIR',{|| FT140Tree(3,oTree)},OemToAnsi(STR0006)})                                       
	PutSX1Help("P.FAT14001.",aHelpP,aHelpE,aHelpS)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mostra a pergunta sobre os produtos                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("FAT140",.T.)
Else
	// Inclui botoes 
	// Inclusao de previsoes
	AADD(aButtons,{'NOTE',{|| Ft140IncPV(oTree,dDataIni,dDatafim,aDadosProd)},OemToAnsi(STR0012),OemToAnsi(STR0013)})
	// Refresh no tree
	AADD(aButtons,{'reload',{|| Fat140Trfs(oDlg,oTree,aTotais,aDadosProd,dDataIni,dDataFim) },"Refresh","Refresh"})
	cCadastro+=OemToAnsi(STR0003)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Interface                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPosObj   := MsObjSize( aInfo,If(lPrevVenda,aObjects2,aObjects),.T.,If(lPrevVenda,.T.,NIL))
// Define arotina fixo
aRotina   := { { "" , "        ", 0 , 2}}
// Caso a chamada ocorra da previsao de vendas monta variaveis de memoria
If lPrevVenda
	RegtoMemory("SB1",.F.)
	RegtoMemory("SC4",.F.)
EndIf
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	// Cria o Tree e preenche as informacoes
	oTree := DbTree():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],oDlg,,,.T.)
	FT140MTree(oTree,cCodVazio,NIL,NIL,NIL,If(lPrevVenda,.T.,mv_par01==1),lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)
	// Caso a chamada ocorra da previsao de vendas altera caracteristica da tela apresentando informacoes sobre produtos e previsoes
	If lPrevVenda
		oPanel := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlg,oDlg:oFont,.T.,.T.,,,aPosObj[2,3],aPosObj[2,4],.T.,.T. )
		oTree:bChange := {|| (If(Val(Substr(oTree:GetCargo(),nPosIni,10))>0,If(Substr(oTree:GetCargo(),1,1) == "2",(SB1->(MsGoto(Val(Substr(oTree:GetCargo(),nPosIni,10)))),RegtoMemory("SB1",.F.)),(SC4->(MsGoto(Val(Substr(oTree:GetCargo(),nPosIni,10)))),RegtoMemory("SC4",.F.))),),FT140RTree(@oTree,@oPanel,{0,0,aPosObj[2,4],aPosObj[2,3]},aTotais)) }	
	EndIf
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
Release Object oTree
RestArea(aArea)
// Restaura area original
aRotina:=AClone(aRetCopy)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140Tree ³ Autor ³Eduardo Riera          ³ Data ³06.09.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estrutura das categorias                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1: Opcao selecionada                                     ³±±
±±³          ³        [1] Inclusao                                          ³±±
±±³          ³        [2] Alteracao                                         ³±±
±±³          ³        [3] Exclusao                                          ³±±
±±³          ³ ExpO2: Objeto Tree                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FT140Tree(nOpcao,oTree)
Local aArea  	  := GetArea()
Local nOpcA 	  := 0
Local cCargo      := oTree:GetCargo()
Local cTpTree     := Substr(cCargo,1,1)
Local aRetCopy    := If(Type("aRotina")=="A",Aclone(aRotina),{})
Local cFilialACU  := xFilial("ACU")

PRIVATE cCodigo := Substr(cCargo,2,Len(ACU->ACU_COD))
PRIVATE cOkFunc := Nil
PRIVATE cDelFunc:= Nil
PRIVATE aRotina := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o tree seja de categoria                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTpTree == "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a Operacao selecionada                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case nOpcao == 1			
			nOpcA := FWExecView("",'FATA140', MODEL_OPERATION_INSERT,, { || .T. } )
			If nOpcA == 0
				nOpca := 1
			Else
				nOpca := 2
			EndIf
			If nOpcA == 1
				oTree:TreeSeek("1"+cCodigo+cProdVazio)
				oTree:addItem(ACU->ACU_DESC,"1"+ACU->ACU_COD+cProdVazio+cGrupoVazio+cRecnoVazio,"BPMSEDT3","BPMSEDT3",,,2)
			EndIf
		Case nOpcao == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona no item selecionado                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("ACU")
			dbSetOrder(1)
			If MsSeek(cFilialACU+cCodigo)	
				cCodigo := ACU->ACU_CODPAI
				nOpcA := FWExecView("",'FATA140', MODEL_OPERATION_UPDATE,, { || .T. } )
				If nOpcA == 0
					nOpca := 1
				Else
					nOpca := 2
				EndIf					
				If nOpcA == 1
					oTree:ChangePrompt(ACU->ACU_DESC,cCargo)		
				EndIf
			EndIf
		Case nOpcao == 3
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se este item pode ser deletado                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("ACV")
			dbSetOrder(1)
			dbSelectArea("ACU")
			dbSetOrder(2)
			If !MsSeek(cFilialACU+cCodigo) .And. !(ACV->(MsSeek(xFilial("ACV")+cCodigo)))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona no item selecionado                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("ACU")
				dbSetOrder(1)
				If MsSeek(cFilialACU+cCodigo)
					nOpcA := FWExecView("",'FATA140', MODEL_OPERATION_DELETE,, { || .T. } )
					If nOpcA == 0
						nOpca := 2
					Else
						nOpca := 1
					EndIf
				EndIf			
				If nOpcA == 2
					dbSelectArea("ACU")
					dbSetOrder(1)
					If !MsSeek(cFilialACU+cCodigo)
						oTree:DelItem()
					EndIf
				EndIf
			Else	
				Help(" ",1,"NODELETA", , STR0028,1,0 ) //'Este registro não pode ser excluído pois possui categorias vinculadas'
			EndIf		
	EndCase
Else
	Help(" ",1,"OPERACINVA", , STR0029,1,0) // 'Selecione um nó referente à uma Categoria'
EndIf
RestArea(aArea)    

aRotina:=AClone(aRetCopy)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140When ³ Autor ³Antonio C Ferreira     ³ Data ³28.02.2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite ou nao a edicao do campo                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Editar / .F. Nao editar                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Nome do Campo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FT140When(cCampo)

Local lOk := .T.  //Controla se edita ou nao o campo da Categoria Pai.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para e-Commerce      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lECommerce := SuperGetMV("MV_LJECOMM",,.F.)

Default cCampo := ""

If  lECommerce
	If  (cCampo == "ACU_CODPAI") .And. ALTERA .And. (M->ACU_ECFLAG=="1") .And. !( Empty(M->ACU_CODPAI) )
        lOk := .F. //Para nao editar Categoria Pai ja gravado na alteracao da Categoria do e-commerce.
    EndIf    
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140Grv  ³ Autor ³Eduardo Riera          ³ Data ³06.09.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao complementar da categoria de produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FT140Grv()
ACU->ACU_CODPAI := cCodigo
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140MTree³ Autor ³Rodrigo de A Sartorio  ³ Data ³03.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega informacoes do tree                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto tree                                           ³±±
±±³          ³ ExpC1: Codigo da categoria                                   ³±±
±±³          ³ ExpL1: Flag indicando se registro ja esta posicionado        ³±±
±±³          ³ ExpC2: Texto para inclusao no tree                           ³±±
±±³          ³ ExpC3: Codigo para inclusao no cargo do tree                 ³±±
±±³          ³ ExpL2: Flag indicando se apresenta produtos relacionados     ³±±
±±³          ³ ExpL3: Flag indicando se chamada veio da previsao de vendas  ³±±
±±³          ³ ExpA1: Array com os totais por categoria                     ³±±
±±³          ³ ExpD1: Data inicial para considerar as previsoes de venda    ³±±
±±³          ³ ExpD2: Data final para considerar as previsoes de venda      ³±±
±±³          ³ ExpA2: Array com os dados dos produtos                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FT140MTree(oTree,cCodPai,lSeek1,cTexto,cCodCargo,lExplProd,lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)
Local nRec		 := 0
Local aArea		 := GetArea()
Local aDadosRet	 := {}
Local nx		 := 0
Local lCpBloq	 := (ACU->(FieldPos("ACU_MSBLQL")) > 0)
Local cFilialACU := xFilial("ACU")

DEFAULT cTexto    := Space(130)
DEFAULT cCodCargo := ""
DEFAULT lExplProd := .F.
DEFAULT lSeek1    := .F.

dbSelectArea("ACV")
dbSetOrder(1)

dbSelectArea("ACU")
dbSetOrder(2)

//1 FILIAL+COD
//2 FILIAL+CODPAI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura por uma categoria nao bloqueada (campo MSBLQL)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSeek1

	lSeek1:=MsSeek(cFilialACU+cCodPai) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))

	If !lSeek1 .AND. Found()
		While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == cFilialACU .AND. ACU->ACU_CODPAI == cCodPai
			ACU->(DbSkip())
			lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
		End
	EndIf

EndIf

If lSeek1
	If !Empty(cCodPai) .And. !Empty(cTexto) .And. !Empty(cCodCargo)
		oTree:AddTree(cTexto,.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)			
	Else
		oTree:AddTree(STR0040+Space(Len(ACU->ACU_DESC)+130),.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodVazio+cProdVazio+cGrupoVazio+cRecnoVazio) // "Raiz"
	EndIf
	// Enquanto esta regiao for a regiao pai
	While !Eof() .And. ACU->ACU_FILIAL+ACU->ACU_CODPAI == cFilialACU+cCodPai
		//Salta categorias bloqueadas
		If (lCpBloq  .AND. ACU->ACU_MSBLQL == '1')
			DbSkip()
			Loop
		End
		cCodCargo:=ACU_COD
		nRec:=Recno()
		cTexto:=ACU->ACU_DESC     
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura por uma categoria nao bloqueada (campo MSBLQL)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lSeek1:=MSSeek(cFilialACU+cCodCargo) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))
		
		If !lSeek1 .AND. Found()
			While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == cFilialACU .AND. ACU->ACU_CODPAI == cCodCargo
				ACU->(DbSkip())
				lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
			End
		EndIf
		
		If !lSeek1
			// Inclui todos os produtos relacionados 
			If lExplProd .And. ACV->(MsSeek(xFilial("ACV")+cCodCargo))
				oTree:AddTree(cTexto,.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)						
				aDadosRet:=Fata140Prd(oTree,cCodCargo,lPrevVenda,aTotais,dDataIni,dDataFim)					
				For nx:=1 to Len(aDadosRet)
					AADD(aDadosProd,ACLONE(aDadosRet[nx]))				
				Next nx
				oTree:EndTree()				
			Else
				oTree:AddTreeItem(cTexto,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)
			EndIf
		Else
			FT140MTree(oTree,ACU_CODPAI,lSeek1,cTexto,cCodCargo,lExplProd,lPrevVenda,aTotais,dDataIni,dDataFim,aDadosProd)
		EndIf
		dbGoto(nRec)
		dbSkip()
	End
	// Inclui todos os produtos relacionados 
	If lExplProd
		aDadosRet:=Fata140Prd(oTree,cCodPai,lPrevVenda,aTotais,dDataIni,dDataFim)		
		For nx:=1 to Len(aDadosRet)
			AADD(aDadosProd,ACLONE(aDadosRet[nx]))				
		Next nx
	EndIf
	oTree:EndTree()	
EndIf
// Sorteia array com resultados por grupo
aSort(aDadosProd,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})
RestArea(aArea)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fata140Prd³ Autor ³Rodrigo de A Sartorio  ³ Data ³01.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega informacoes da amarracao produto X categoria         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA2: Array com as informacoes de produto X categoria       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto tree                                           ³±±
±±³          ³ ExpC1: Codigo da categoria                                   ³±±
±±³          ³ ExpL1: Flag indicando se a chamada veio da previsao de venda ³±±
±±³          ³ ExpA1: Array com os totais por previsao de venda             ³±±
±±³          ³ ExpD1: Data inicial para considerar as previsoes de venda    ³±±
±±³          ³ ExpD2: Data final para considerar as previsoes de venda      ³±±
±±³          ³ ExpL2: Flag indicando se mostra somente as informacoes dos   ³±±
±±³          ³        produto associados e nao monta o tree                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fata140Prd(oTree,cCod,lPrevVenda,aTotais,dDataIni,dDataFim,lInfo)
Local aArea       := GetArea()
Local cGrupo      := If(lExisteGrupo,RetTitle("ACV_GRUPO"),"")
Local cProduto    := RetTitle("ACV_CODPRO")
Local cTextoTotal := ""
Local cRecno      := cRecnoVazio
Local aRetorno    := {}
Local i           := 0
Local j           := 0
Local aColsGrd    := {}
Local cFilialSB1  := ''
Local cFilialACV  := xFilial("ACV")
Default lInfo := .F.

dbSelectArea("ACV")
dbSetOrder(1)
If MsSeek(cFilialACV+cCod)
	cFilialSB1  := xFilial("SB1")
	While !Eof() .And. cFilialACV+cCod == ACV->ACV_FILIAL+ACV->ACV_CATEGO
		aColsGrd:={}
		cRecno:=cRecnoVazio
		If lExisteGrupo .And. !Empty(ACV->ACV_GRUPO)
			cTextoTotal:=cGrupo+ACV->ACV_GRUPO
		ElseIf !Empty(ACV->ACV_CODPRO)
			cTextoTotal:=cProduto+ACV->ACV_CODPRO
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(cFilialSB1+ACV->ACV_CODPRO))
				cRecno:=StrZero(SB1->(Recno()),10)
				cTextoTotal:=(Alltrim(cProduto))+" - "+(Alltrim(ACV->ACV_CODPRO))+" - "+SB1->B1_DESC				
			EndIf
		ElseIf !Empty(ACV->ACV_REFGRD)
			aColsGrd:=Ft140Grade(ACV->ACV_REFGRD)
		EndIf
		
		If len(aColsGrd)>0
			If !lInfo
				For i:=1 to len(aColsGrd)  
				cTextoTotal:=cProduto + Acolsgrd[i,1]
					If lPrevVenda .And. Fat140PV(oTree,aColsGrd[I,1],ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACv->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,""),.T.)
						oTree:AddTree(cTextoTotal,.T.,,,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,"")+aColsGrd[I,2])
						// Inclui as previsoes de venda ja cadastradas no periodo selecionado
						Fat140PV(oTree,aColsGrd[I,1],ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACV->ACV_CATEGO+PADR(aColsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,""),.F.)
						oTree:EndTree()
					Else
						oTree:AddTreeItem(cTextoTotal,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+PADR(AcolsGrd[I,1],15)+If(lExisteGrupo,ACV->ACV_GRUPO,"")+aColsGrd[I,2])
					EndIf
				Next
			EndIf
			// Array que retorna informacoes dos produtos associados
			For j:=1 to len(aColsGrd)
				AADD(aRetorno,{ACV->ACV_CATEGO,acolsGrd[J,1],ACV->ACV_GRUPO})
			Next
		Else
			If !lInfo
				If lPrevVenda .And. Fat140PV(oTree,ACV->ACV_CODPRO,ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACv->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,""),.T.)
					oTree:AddTree(cTextoTotal,.T.,,,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,"")+cRecno)
					// Inclui as previsoes de venda ja cadastradas no periodo selecionado
					Fat140PV(oTree,ACV->ACV_CODPRO,ACV->ACV_GRUPO,aTotais,dDataIni,dDataFim,ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,""),.F.)
					oTree:EndTree()
				Else
					oTree:AddTreeItem(cTextoTotal,"BPMSEDT4","BPMSEDT4","2"+ACV->ACV_CATEGO+ACV->ACV_CODPRO+If(lExisteGrupo,ACV->ACV_GRUPO,"")+cRecno)
				EndIf
				
			EndIf
			// Array que retorna informacoes dos produtos associados
			AADD(aRetorno,{ACV->ACV_CATEGO,ACV->ACV_CODPRO,ACV->ACV_GRUPO})
			
		EndIf
		dbSkip()
	End
EndIf
RestArea(aArea)
RETURN aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140RTree³ Autor ³Rodrigo de A Sartorio  ³ Data ³05.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua refresh no painel de acordo com posicao no tree       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto tree                                           ³±±
±±³          ³ ExpO2: Objeto painel                                         ³±±
±±³          ³ ExpA1: Array com posicao                                     ³±±
±±³          ³ ExpA2: Array com totais                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FT140RTree(oTree,oPanel,aPos,aTotais)
Local cCargo     := oTree:GetCargo()
Local aDados     := {}
Local aArea      := GetArea()
Local cGrupo     := Substr(cCargo,2,Len(ACU->ACU_COD))
Local nRec       := Val(Substr(cCargo,Len(ACU->ACU_COD)+Len(ACV->ACV_CODPRO)+Len(cGrupoVazio)+2,10))
Local nAcho      := 0
Local lOneColumn := If(aPos[4]-aPos[2]>312,.F.,.T.)
Local oScroll

If Substr(cCargo,1,1) == "1"
	nAcho:=Ascan(aTotais,{|x| x[2]== cGrupo})
	If nAcho > 0
		AADD(aDados,{aTotais[nAcho,3],""})
		AADD(aDados,{STR0007,Transform(aTotais[nAcho,4],PesqPict("SC4","C4_QUANT",14))})
		AADD(aDados,{STR0008,Transform(aTotais[nAcho,5],PesqPict("SC4","C4_QUANT",14))})
		AADD(aDados,{STR0009,Transform(aTotais[nAcho,6],PesqPict("SC4","C4_VALOR",14))})
	Else
		AADD(aDados,{STR0010})
	EndIf
	C040MatScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
	oScroll:Show()
ElseIf Substr(cCargo,1,1) == "2"
	If nRec == 0
		AADD(aDados,{STR0010})
		C040MatScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
		oScroll:Show()
	Else
		dbSelectArea("SB1")
		MsGoto(nRec)
		RegtoMemory("SB1",.F.)
		oPanel:Hide()
		MsFreeObj(@oPanel, .T.)
		MsMGet():New("SB1",nRec,1,,,,,aPos,,3,,,,oPanel,,.T.,lOneColumn)
		oPanel:Show()
	EndIf
ElseIf Substr(cCargo,1,1) == "3" .And. (nRec > 0)
	dbSelectArea("SC4")
	MsGoto(nRec)
	RegtoMemory("SC4",.F.)
	oPanel:Hide()
	MsFreeObj(@oPanel, .T.)
	MsMGet():New("SC4",nRec,1,,,,,aPos,,3,,,,oPanel,,.T.,lOneColumn)
	oPanel:Show()
EndIf
RestArea(aArea)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fat140PV  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³06.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui informacoes da previsao de venda no tree              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto tree                                           ³±±
±±³          ³ ExpC1: Codigo da categoria                                   ³±±
±±³          ³ ExpA1: Array com os totais da categoria                      ³±±
±±³          ³ ExpD1: Data inicial para filtragem da previsao de vendas     ³±±
±±³          ³ ExpD2: Data final para filtragem da previsao de vendas       ³±±
±±³          ³ ExpC2: Texto para cargo do tree                              ³±±
±±³          ³ ExpL1: Somente checa a existencia de registros               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fat140PV(oTree,cCodPro,cCodGrupo,aTotais,dDataIni,dDataFim,cCargo,lCheca)		
Local aArea     :=GetArea()

Local lPossuiReg:=.F.
Local cRecno    := cRecnoVazio
Local nAcho     := 0

#IFDEF TOP
	Local cAliasTop := ""
	Local cQuery    := ""
#ELSE
	Local cSeek     :=""
	Local cWhile    :=""
#ENDIF

Default cCodPro  :=""
Default cCodGrupo:=""
Default aTotais  :={}
Default dDataIni := dDatabase
Default dDataFim := dDatabase
Default cCargo   :=""
Default lCheca   :=.F.

#IFDEF TOP
	cAliasTop := GetNextAlias()
	cQuery := "SELECT SC4.*,SC4.R_E_C_N_O_ REGC4 FROM "+RetSqlName("SC4")+" SC4, "+RetSqlName("SB1")+" SB1 "
	cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SC4.C4_FILIAL='"+xFilial("SC4")+"' AND "
	If !Empty(cCodPro)
		cQuery+= "SB1.B1_COD   ='"+cCodPro+"' AND "					
	ElseIf !Empty(cCodGrupo)
		cQuery+= "SB1.B1_GRUPO ='"+cCodGrupo+"' AND "	
	EndIf
	cQuery += "	SC4.C4_PRODUTO = SB1.B1_COD AND "					
	cQuery += "SC4.C4_DATA >= '" + DTOS(dDataIni) + "' AND SC4.C4_DATA <= '" + DTOS(dDataFim) + "' AND "
	cQuery += "SB1.D_E_L_E_T_=' ' AND SC4.D_E_L_E_T_=' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	aEval(SC4->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
	dbSelectArea(cAliasTop)
	While !Eof() 
		// So esta checando se possui registros
		If lCheca
			lPossuiReg:=.T.
			Exit		
		EndIf
		nAcho:=Ascan(aTotais,{|x| x[2]== Substr(cCargo,1,Len(ACU->ACU_COD))})
		If nAcho > 0
			aTotais[nAcho,4]+=1
			aTotais[nAcho,5]+=C4_QUANT
			aTotais[nAcho,6]+=C4_VALOR
		Else
			AADD(aTotais,{"SC4",Substr(cCargo,1,Len(ACU->ACU_COD)),STR0011,1,C4_QUANT,C4_VALOR})
		EndIf
		cRecno:= StrZero((cAliasTop)->REGC4,10)
		oTree:AddTreeItem(C4_DOC+" - "+DTOC(C4_DATA),"BPMSEDT1","BPMSEDT1","3"+cCargo+cRecno)	
		dbSkip()
	End
	dbCloseArea()      
#ELSE
	dbSelectArea("SB1")
	If !Empty(cCodPro)
		dbSetOrder(1)
		dbSeek(cSeek:=xFilial()+cCodPro)
		cWhile:="B1_FILIAL+B1_COD"
	ElseIf !Empty(cCodGrupo)
		dbSetOrder(4)
		dbSeek(cSeek:=xFilial()+cCodGrupo)
		cWhile:="B1_FILIAL+B1_GRUPO"
	EndIf
	While !Eof() .And. cSeek == &(cWhile)
		// So esta checando se possui registros
		If lCheca 
			lPossuiReg:=.T.
			Exit		
		EndIf
		cCodPro:=SB1->B1_COD
		dbSelectArea("SC4")
		If Fat140Ind()
			dbSetOrder(2)
			dbSeek(xFilial()+cCodPro+DTOS(dDataIni),.T.)
			While !Eof() .And. C4_FILIAL+C4_PRODUTO == xFilial()+cCodPro .And. DTOS(C4_DATA) <= DTOS(dDataFim)
				// So esta checando se possui registros
				If lCheca
					lPossuiReg:=.T.
					Exit		
				EndIf
				nAcho:=Ascan(aTotais,{|x| x[2]== Substr(cCargo,1,Len(ACU->ACU_COD))})
				If nAcho > 0
					aTotais[nAcho,4]+=1
					aTotais[nAcho,5]+=C4_QUANT
					aTotais[nAcho,6]+=C4_VALOR
				Else
					AADD(aTotais,{"SC4",Substr(cCargo,1,Len(ACU->ACU_COD)),STR0011,1,C4_QUANT,C4_VALOR})
				EndIf
				cRecno:= StrZero(Recno(),10)
				oTree:AddTreeItem(C4_DOC+" - "+DTOC(C4_DATA),"BPMSEDT1","BPMSEDT1","3"+cCargo+cRecno)					
				dbSkip()
			End
		Else
			dbSetOrder(1)
			dbSeek(xFilial()+cCodPro)
			While !Eof() .And. C4_FILIAL+C4_PRODUTO == xFilial()+cCodPro 
				If DTOS(C4_DATA) >= DTOS(dDataIni) .And. DTOS(C4_DATA) <= DTOS(dDataFim)
					// So esta checando se possui registros
					If lCheca
						lPossuiReg:=.T.
						Exit		
					EndIf
					nAcho:=Ascan(aTotais,{|x| x[2]== Substr(cCargo,1,Len(ACU->ACU_COD))})
					If nAcho > 0
						aTotais[nAcho,4]+=1
						aTotais[nAcho,5]+=C4_QUANT
						aTotais[nAcho,6]+=C4_VALOR
					Else
						AADD(aTotais,{"SC4",Substr(cCargo,1,Len(ACU->ACU_COD)),STR0011,1,C4_QUANT,C4_VALOR})
					EndIf
					cRecno:= StrZero(Recno(),10)
					oTree:AddTreeItem(C4_DOC+" - "+DTOC(C4_DATA),"BPMSEDT1","BPMSEDT1","3"+cCargo+cRecno)	
				EndIf
				dbSkip()
			End
		EndIf		
		dbSelectArea("SB1")
		dbSkip()
	End
#ENDIF	
RestArea(aArea)
RETURN lPossuiReg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fat140Ind ³ Autor ³Rodrigo de A Sartorio  ³ Data ³06.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se existe o indice 2 do arquivo SC4                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico, caso .t. indica existencia de indice                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fat140Ind()
Local aAreaSIX  := {}
Local lTemIndice:= .F.
Local cSixChave := ""
Local cAreaOri  :=Alias()
aAreaSIX:=SIX->(GetArea())
dbSelectArea("SIX")
dbSeek("SC4")
While ("SC4" == INDICE) .and. !Eof()
	cSixChave := AllTrim(CHAVE)
	If SIX->ORDEM == "2" .And. cSixChave == "C4_FILIAL+C4_PRODUTO+DTOS(C4_DATA)"
		lTemIndice:=.T.
		Exit
	EndIf
	dbSkip()
End
RestArea(aAreaSIX)
dbSelectarea(cAreaOri)
RETURN lTemIndice

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ft140IncPV³ Autor ³Rodrigo de A Sartorio  ³ Data ³10.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui previsoes de venda                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto tree                                           ³±±
±±³          ³ ExpD1: Data inicial para filtragem da previsao de vendas     ³±±
±±³          ³ ExpD2: Data final para filtragem da previsao de vendas       ³±±
±±³          ³ ExpA1: Array com os dados utilizados para inclusao da Prev.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft140IncPV(oTree,dDataIni,dDatafim,aDadosProd)
Local oDlgGet,oGetD 
Local aRetCopy  	:= If(Type("aRotina")=="A",ACLONE(aRotina),{})
Local cCargo    	:= oTree:GetCargo()
Local cAreaOri 		:= Alias()
Local aAreaSC4  	:= SC4->(GetArea())
Local cCatego   	:= Substr(cCargo,2,Len(ACU->ACU_COD))
LOCAL aObjects  	:= {},aPosObj :={}
LOCAL aSize    		:= MsAdvSize()
LOCAL aInfo     	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local nx        	:= 0
Local nOpca     	:= 0
Local aColsBack 	:= {}
Local nPosProd 		:= 0
Local nPosLocal 	:= 0
Local nPosQuant 	:= 0
Local nPosValor 	:= 0
Local nPosRevis 	:= 0
Local nPosData   	:= 0
Local cFilialSB1	:= ''
Local lPCPREVATU	:= FindFunction('PCPREVATU') 
Private aHeader 	:= {} 
Private aCols   	:= {}
Private lShowOpc	:= .T.
Private n 			:= 1

If Substr(cCargo,1,1) == "1" .And. (nAcho:=Ascan(aDadosProd,{|x| x[1]== cCatego})) > 0
	cFilialSB1	:= xFilial("SB1")
	
	// Define arotina fixo
	aRotina   := { { "" , "        ", 0 , 3}}
	// Cria dados para tela de inclusao - CABECALHO
	aHeader := A610CriaHeader("SC4",,,.T.)
	For nx:=1 to Len(aHeader)
		If "aProdGrade(M->C4_PRODUTO).or." $ aHeader[nx,6]
			aHeader[nx,6] := StrTran(aHeader[nx,6],"aProdGrade(M->C4_PRODUTO).or.","")					
		EndIf 	
	Next nx
	// Ajusta tamanho dos nomes do campo para evitar erro na SeleOpc
	aEval(aHeader,{|x| x[2] := Padr(x[2],10) })
	// Posicao dos itens na getdados
	nPosProd  :=GDFieldPos("C4_PRODUTO")
	nPosLocal :=GDFieldPos("C4_LOCAL")
	nPosQuant :=GDFieldPos("C4_QUANT")
	nPosValor :=GDFieldPos("C4_VALOR")
	nPosRevis :=GDFieldPos("C4_REVISAO")
	nPosData :=GDFieldPos("C4_DATA")
	// Cria dados para tela de inclusao - LINHAS
	aColsBack  := A610CriaCols("SC4",aHeader,xFilial("SC4") + SC4->C4_PRODUTO,&('{||SC4->C4_FILIAL + SC4->C4_PRODUTO==xFilial("SC4") + SC4->C4_PRODUTO}'))[1]  
	For nx:=nAcho to Len(aDadosProd)
		// Checa categoria
		If aDadosProd[nx,1] <> cCatego
			Exit
		EndIf
		// Preenche produto na getdados	
		If !Empty(aDadosProd[nx,2])
    		SB1->(dbSetOrder(1))
			If SB1->(dbSeek(cFilialSB1+aDadosProd[nx,2]))
				AADD(aCols,ACLONE(aColsBack[1]))			
				aCols[Len(aCols),nPosProd]:=aDadosProd[nx,2]
				aCols[Len(aCols),nPosLocal]:=SB1->B1_LOCPAD
				aCols[Len(aCols),nPosRevis]:=IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
				aCols[Len(aCols),nPosQuant]:=0
				aCols[Len(aCols),nPosData]:=dDataBase
			EndIf
		// Preenche grupo de produtos
		ElseIf !Empty(aDadosProd[nx,3])
			SB1->(dbSetOrder(4))
			SB1->(dbSeek(cFilialSB1+aDadosProd[nx,3]))
			While !SB1->(Eof()) .And. SB1->(B1_FILIAL+B1_GRUPO) == cFilialSB1+aDadosProd[nx,3]
				AADD(aCols,ACLONE(aColsBack[1]))			
				aCols[Len(aCols),nPosProd]:=SB1->B1_COD
				aCols[Len(aCols),nPosLocal]:=SB1->B1_LOCPAD
				aCols[Len(aCols),nPosRevis]:=IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
				aCols[Len(aCols),nPosQuant]:=0
				aCols[Len(aCols),nPosData]:=dDataBase
				SB1->(dbSkip())
			End
		EndIf	
	Next nx	
	// Verifica a existencia de informacoes na inclusao
	If Len(aCols) > 0
		nOpca := 0
		AADD(aObjects,{100,100,.T.,.T.,.F.})
		aPosObj:=MsObjSize(aInfo,aObjects)
		DEFINE MSDIALOG oDlgGet TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
			oGetD := MSGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],1,"Fat140LOk","Fat140TOk","",.T.,,,,,"Ft140FldOk")
		ACTIVATE MSDIALOG oDlgGet ON INIT EnchoiceBar(oDlgGet,{|| nOpca := 1,If(oGetD:TudoOk(),oDlgGet:End(), nOpca :=  0 )},{|| nOpca := 2,oDlgGet:End()})
		// Grava previsoes de venda
		If nOpca == 1
			A610GravaCol(aCols,aHeader,{},"SC4")
		EndIf
	EndIf
EndIf

aRotina:=AClone(aRetCopy)
RestArea(aAreaSC4)
If !Empty(cAreaOri)
	dbSelectArea(cAreaOri)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fat140LOk ³ Autor ³Rodrigo de A Sartorio  ³ Data ³10.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida inclusao das previsoes de venda por linha             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto getdados                                       ³±±
±±³          ³ ExpL1: Indica se percorre todas as linhas                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fat140LOk(o,lTodas)
LOCAL lRet		:= .T.
LOCAL nx  		:= 0
LOCAL nPProd 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_PRODUTO"})
LOCAL nPQtde 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_QUANT"})
LOCAL nPData 	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_DATA"})
LOCAL nPOpc  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_OPC"})
LOCAL nPRev  	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C4_REVISAO"})

DEFAULT lTodas 	:= .F.

If !lTodas
	If !GDdeleted(n)
		lRet:=MaCheckCols(aHeader,aCols,n)
	EndIf
	If lRet .And. If(Type("lShowOpc")=="L",lShowOpc,.F.) .And. !Empty(nPOpc)
		lRet := SeleOpc(2,"FATA140",aCols[n,nPProd],,,aCols[n][nPOpc],"M->C4_PRODUTO",,aCols[n,nPQtde],aCols[n,nPData],aCols[n,nPRev])
		If lRet
			lShowOpc := .F.
		EndIf
	EndIF
Else
	For nx:=1 to Len(aCols)
		If !GDdeleted(nx)
			lRet:=MaCheckCols(aHeader,aCols,nx)
		EndIf
		If !lRet
			Exit		
		EndIf
	Next nx
EndIf
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fat140TOk ³ Autor ³Rodrigo de A Sartorio  ³ Data ³10.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida inclusao das previsoes de venda de todas as linhas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto getdados                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fat140TOk(o)
Return Fat140LOk(o,.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fat140Trfs³ Autor ³Rodrigo de A Sartorio  ³ Data ³26.10.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua refresh no tree apos click no botao de refresh        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1: Objeto dialog                                         ³±±
±±³          ³ ExpO2: Objeto tree                                           ³±±
±±³          ³ ExpA1: Array com totais                                      ³±±
±±³          ³ ExpA2: Array com dados para inclusao de previsoes            ³±±
±±³          ³ ExpD1: Data inicial para filtragem da previsao de vendas     ³±±
±±³          ³ ExpD2: Data final para filtragem da previsao de vendas       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fat140Trfs(oDlg,oTree,aTotais,aDadosProd,dDataIni,dDataFim)
Local cCargoOri:=oTree:GetCargo()
// Zera dados dos totalizadores
aTotais:={}
aDadosProd:={}	
// Zera dados do tree
oTree:BeginUpdate()
oTree:Reset()                                            
oTree:EndUpdate()
// Cria o Tree e preenche as informacoes
FT140MTree(oTree,cCodVazio,NIL,NIL,NIL,.T.,.T.,aTotais,dDataIni,dDataFim,aDadosProd)
// Reposiciona o tree na primeira posicao
oTree:TreeSeek("1"+cCodVazio+cProdVazio+cGrupoVazio+cRecnoVazio)
// Atualiza tela com informacoes auxiliares
Eval(oTree:bChange)
// Reposiciona o tree na posicao original
oTree:TreeSeek(cCargoOri)
// Atualiza tela com informacoes auxiliares
Eval(oTree:bChange)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft140GradeºAutor  ³Patricia D. Aguiar  º Data ³  05/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ft140Grade(cProdRef)

Local aAuxiliar 	:= {}
Local aArea     	:= GetArea()
Local cFilialSB1	:= xFilial("SB1")
Default cProdRef	:= ''

DbSelectArea("SB1")
DbSetOrder(1)

If MsSeek(cFilialSB1+cProdRef,.T.)
	While SB1->( !Eof() .And. B1_FILIAL+Left(B1_COD,Len(Alltrim(cProdRef))) == cFilialSB1+Alltrim(cProdRef) )
		Aadd(aAuxiliar,{SB1->B1_COD,StrZero(SB1->(Recno()),10)})
		DbSkip()
	
	EndDo
EndIf

Restarea(aArea)
Return(aAuxiliar)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft140FldOkºAutor  ³Andre Anjos         º Data ³  29/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida campos da GetDados                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FATA140                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ft140FldOk()
Local lRet := .T.

If Type("lShowOpc") == "L"
	lShowOpc := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft140Cnf  ºAutor  ³Vendas CRM          º Data ³  04/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de validacao da tela, utilizada para verificar se os º±±
±±º          ³produtos de uma categoria desativada estarao duplicados ao  º±±
±±º          ³reativar a mesma.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATA140                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft140Cnf(nOpc, oMdl)

Local aArea			:= GetArea()
Local aAreaACU  	:= ACU->(GetArea())
Local aAreaACV		:= ACV->(GetArea())
Local aProdutos		:= {}
Local aGrupos		:= {}  
Local aProdDup		:= {}
Local aGrupDup		:= {}
Local lRet 			:= .T.
Local lCpBloq		:= (ACU->(FieldPos("ACU_MSBLQL")) > 0)
Local nX			:= 0
Local cCategAtu		:= ACU->ACU_COD
Local cFilialACV	:= ''
Local cFilialACU	:= ''
Local cFilialSBM    := ''
Local cFilialSB1	:= ''

Default nOpc		:= 4
Default oMdl		:= Nil 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso a categoria bloqueada tenha sido desbloqueada, valida  ³
//³os produtos que gerarao duplicidade, impedindo o desbloqueio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .AND. lCpBloq .AND. ACU->ACU_MSBLQL == "1" .AND. M->ACU_MSBLQL <> "1"
	cFilialACV	:= xFilial("ACV")
	cFilialACU	:= xFilial("ACU")
	cFilialSBM  := xFilial("SBM")
	cFilialSB1	:= xFilial("SB1")
	
	DbSelectArea("ACV")
	DbSetOrder(1) //ACV_FILIAL+ACV_CATEGO+ACV_GRUPO+ACV_CODPRO
	DbSeek(cFilialACV+cCategAtu)
	
	While !ACV->(Eof()) .AND. ACV->ACV_FILIAL == cFilialACV .AND. ACV->ACV_CATEGO == cCategAtu
		Do Case
			Case !Empty(ACV->ACV_GRUPO)
				AAdd(aGrupos,ACV->ACV_GRUPO)
			Case !Empty(ACV->ACV_CODPRO)
				AAdd(aProdutos,ACV->ACV_CODPRO)
		EndCase
		ACV->(DbSkip())
	End

	ACU->(DbSetOrder(1)) //ACU_FILIAL+ACU_COD
	
	nX := 1        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida existencia de duplicidade entre grupos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACV->(DbSetOrder(2)) //ACV_FILIAL+ACV_GRUPO+ACV_CODPRO+ACV_CATEGO
	
	While nX <= Len(aGrupos)
		
		If ACV->(DbSeek( cFilialACV+aGrupos[nX] ) )
			
			While !ACV->(Eof()) .AND. ACV->ACV_FILIAL == cFilialACV .AND. ACV->ACV_GRUPO == aGrupos[nX]
				If ACV->ACV_CATEGO <> cCategAtu
					If ACU->(DbSeek(cFilialACU+ACV->ACV_CATEGO)).AND. ACU->ACU_MSBLQL <> "1"
						AAdd(aGrupDup,{	ACV->ACV_GRUPO,;
										GetAdvFVal("SBM","BM_DESC",cFilialSBM+ACV->ACV_GRUPO,1,""),;
										ACV->ACV_CATEGO})
						lRet := .F.
					EndIf
				EndIf
				ACV->(DbSkip())
			End
		EndIf
		nX++

	EndDo
	
	nX := 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida existencia de duplicidade entre produtos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACV->(DbSetOrder(5)) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO

	While nX <= Len(aProdutos)
		
		ACV->(DbSeek(cFilialACV+aProdutos[nX]))
	
		While !ACV->(Eof()) .AND. ACV->ACV_FILIAL == cFilialACV .AND. ACV->ACV_CODPRO == aProdutos[nX]
			If ACV->ACV_CATEGO <> cCategAtu
				If ACU->(DbSeek(cFilialACU+ACV->ACV_CATEGO)).AND. ACU->ACU_MSBLQL <> "1"
					AAdd(aProdDup,{	ACV->ACV_CODPRO,;
									GetAdvFVal("SB1","B1_DESC",cFilialSB1+ACV->ACV_CODPRO,1,""),;
									ACV->ACV_CATEGO})
					lRet := .F.
				EndIf
			EndIf
			ACV->(DbSkip())
		End
		
		nX++
		
	End

EndIf

If !lRet
	MsgStop(STR0014) //"O desbloqueio desta categoria não pode ser realizado pois há produtos desta categoria que foram vinculados a outra categoria."
	
	//Exibe grupos duplicados
	If Len(aGrupDup) > 0
		Ft140ExDup(STR0015,aGrupDup,STR0016,STR0017,STR0018) //"Grupos duplicados"###"Grupo"###"Descrição"###"Categoria"
	EndIf
	
	//Exibe produtos duplicados
	If Len(aProdDup) > 0
		Ft140ExDup(STR0019,aProdDup,STR0020,STR0017,STR0018) //"Produtos duplicados"###"Produto"###"Descrição"###"Categoria"
	EndIf

ElseIf (nOpc == 5)
		Ft140VlAlt()	
EndIf

RestArea(aAreaACV)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ft140ExDupºAutor  ³Vendas CRM          º Data ³  09/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe produtos/grupos em duplicidade com outras categorias, º±±
±±º          ³ao tentar desbloquear uma categoria bloqueada com filhos.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FATA140                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ft140ExDup(cTitulo,aLista,cCab1,cCab2,cCab3)

Local oDlg		:= Nil
Local oLbx		:= Nil

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 266,421 PIXEL

@003,002 TO 117,211 LABEL "" PIXEL OF oDlg

@009,004 ListBox oLbx Fields HEADER cCab1,cCab2,cCab3 Size 204,105 Of oDlg Pixel

oLbx:SetArray(aLista)
oLbx:bLine := {||{	aLista[oLbx:nAT][1],;
					aLista[oLbx:nAT][2],;
					aLista[oLbx:nAT][3]}}

DEFINE SBUTTON FROM 119,185 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED 

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao para processamento de mensagem unica.
@author Danilo Dias
@since 02/04/2012
@version 1.0
@param xEnt, caracter/Object, Variavel com conteudo xml/obj para envio/recebimento.
@param nTypeTrans, numeric, Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage, caracter, Tipo de mensagem. (Business Type, WhoIs, etc)
@param cVersion, caracter, Versão da Mensagem Única TOTVS
@param cTransac, caracter, Nome da mensagem iniciada no adapter
@param lEAIObj, Logical Recebe XML ou Objeto EAI
@return ${return}, ${return_description}
/*/
//----------------------------------------------------------------------------
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )

Default xEnt := ""
Default nTypeTrans := ""
Default cTypeMessage := ""
Default cVersion := ""
Default cTransac := ""
Default lEAIObj := .F.

Return FATI140(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )

//------------------------------------------------------------------------------
/*/{Protheus.doc} FT140Cons
Consulta Padrão de Categorias em Árvore
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   07/11/2025
@version P12
@return .T. - Lógico
/*/
//------------------------------------------------------------------------------
Function FT140Cons()
	Local aArea As Array

	aArea := FWGetArea()

	FT140Lookup()
	FA140Close()

	FWRestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140Lookup
Monta a consulta específica das Categorias em Árvore
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   07/11/2025
@version P12
/*/
//-------------------------------------------------------------------
Function FT140Lookup()
	Local oDialog         As Object
	Local oPanelMain      As Object
	Local oPanelBusca     As Object
	Local oGet            As Object
	Local oSayPos         As Object
	Local oBtnProximo     As Object
	Local oBtnAnterior    As Object
	Local oTree           As Object
	Local bVisu           As CodeBlock
	Local bOK             As CodeBlock
	Local bCancel         As CodeBlock
	Local aCodigosBusca   As Array
	Local nIndiceBusca    As Numeric
	Local bResetBusca     As CodeBlock
	Local cChaveBusca     As Character
	Local cCodVazio       As Character
	Local cProdVazio      As Character
	Local lExisteGrupo    As Logical
	Local cGrupoVazio     As Character
	Local cRecnoVazio     As Character
	Local cTexto          As Character
	Local cCodCargo       As Character
	Local cPosAtual       As Character
	Local bAnterior       As CodeBlock
	Local bProximo        As CodeBlock
	Local nMargem         As Numeric
	Local nAltBusca       As Numeric
	Local nLarBusca       As Numeric
	Local nGetLinha       As Numeric
	Local nGetColuna      As Numeric
	Local nGetLargura     As Numeric
	Local nBtnLinha       As Numeric
	Local nBtnColuna      As Numeric
	Local nBtnLargura     As Numeric
	Local nBtnAltura      As Numeric
	Local nBtnProximoCol  As Numeric
	Local nBtnAnteriorCol As Numeric
	Local nSayPosCol      As Numeric
	Local nSayLargura     As Numeric
	Local nSayAltura      As Numeric
	Local nJanAlt         As Numeric
	Local nJanLar         As Numeric
	Local nTreeLinha      As Numeric
	Local nTreeAltura     As Numeric
	Local nTreeLargura    As Numeric
	Local cFilialACU      As Character

	oDialog       := Nil
	oPanelMain    := Nil
	oPanelBusca   := Nil
	oGet          := Nil
	oSayPos       := Nil
	oBtnProximo   := Nil
	oBtnAnterior  := Nil
	oTree         := Nil
	bVisu         := {|| FT140ETree(oTree)}
	bOK           := {|| FT140Ok(oTree, oDialog)}
	bCancel       := {|| oDialog:DeActivate()}
	aCodigosBusca := {} 
	nIndiceBusca  := 0  

	bResetBusca   := {|| FwFreeArray(aCodigosBusca), aCodigosBusca := {}, nIndiceBusca := 0}

	cChaveBusca   := Space(Len(ACU->ACU_DESC)) 
	cCodVazio     := CriaVar("ACU_COD", .F.)
	cProdVazio    := CriaVar("ACV_CODPRO", .F.)
	lExisteGrupo  := ACV->(ColumnPos("ACV_GRUPO")) > 0
	cGrupoVazio   := If(lExisteGrupo, Criavar("ACV_GRUPO",.F.), "")
	cRecnoVazio   := StrZero(0, 10)
	cTexto        := Space(130)
	cCodCargo     := ""
	cPosAtual     := Space(10)
	cFilialACU    := FwxFilial("ACU")

	bProximo      := {|| FT140Prox(oTree, cChaveBusca, @aCodigosBusca, @nIndiceBusca, cProdVazio, cGrupoVazio, cRecnoVazio, @cPosAtual)}
	bAnterior     := {|| FT140Ant(oTree, cChaveBusca, @aCodigosBusca, @nIndiceBusca, cProdVazio, cGrupoVazio, cRecnoVazio, @cPosAtual)}
	
	// Monta o janela de seleção
	oDialog := FWDialogModal():New()
	oDialog:SetBackground(.T.)
	oDialog:SetTitle(STR0030)
	oDialog:SetSize(210, 300)
	oDialog:EnableFormBar(.T.)
	oDialog:SetCloseButton(.F.)
	oDialog:SetEscClose(.F.)
	oDialog:CreateDialog()
	oDialog:CreateFormBar()
	oDialog:AddButton(STR0031, bVisu, STR0031, , .T., .F., .T.,)
	oDialog:addOkButton(bOK, STR0032,)
	oDialog:addCloseButton(Nil, STR0033)
	oDialog:setCloseBlock(bCancel)

	// Recupera o container principal para ancoragem
	oPanelMain := oDialog:GetPanelMain()

	// Definições de Dimensões
	nMargem   := 4 
	nAltBusca := 30 
	nLarBusca := 290 

	// Painel de Busca (TPanel)
	oPanelBusca := TPanel():New(nMargem, nMargem + 6, "", oPanelMain, ;
								Nil, Nil, Nil, Nil, Nil, nLarBusca, nAltBusca)

	// Cria o TPanel
	oPanelBusca:Create()

	// Campo de Pesquisa (TGet)
	nGetLinha   := 0
	nGetColuna  := 0
	nGetLargura := 100

	oGet := TGet():New( nGetLinha, nGetColuna, {|u| cChaveBusca := FT140Param(u, PCount(), cChaveBusca)}, ;
						oPanelBusca, nGetLargura, 12, , , , , Nil, , , .T., , , , , , bResetBusca, , , , , , , , , , , STR0034, 1) 

	// Botão "Próximo" (TButton)
	nBtnLinha   := 6
	nBtnColuna  := nGetColuna + nGetLargura + 10
	nBtnLargura := 60
	nBtnAltura  := 15
	nBtnProximoCol := nGetColuna + nGetLargura + 10

	oBtnProximo := TButton():New(nBtnLinha, nBtnColuna, STR0035, oPanelBusca, bProximo, ;
									nBtnLargura, nBtnAltura, , Nil, , .T.)

	// Botão "Anterior" (TButton)
	nBtnAnteriorCol := nBtnProximoCol + nBtnLargura + 10 
	oBtnAnterior := TButton():New(nBtnLinha, nBtnAnteriorCol, STR0036, oPanelBusca, bAnterior, ;
									nBtnLargura, nBtnAltura, , Nil, , .T.)

	// Texto da Posição (TSay)
	nSayPosCol  := nBtnAnteriorCol + nBtnLargura + 10 
	nSayLargura := 60
	nSayAltura  := 15
	oSayPos := TSay():New(nGetLinha + 9, nSayPosCol, {|| cPosAtual}, oPanelBusca, ;
							Nil, Nil, Nil, Nil, Nil, .T., , , nSayLargura, nSayAltura)

	nJanAlt := 200 
	nJanLar := 300 

	// Posições e Dimensões da DBTree (abaixo do TPanel)
	nTreeLinha := nMargem + nAltBusca + nMargem
	nTreeAltura := nJanAlt - nTreeLinha - nMargem
	nTreeLargura := nJanLar - (2 * nMargem)

	// Monta a DBTree
	oTree := DBTree():New(nTreeLinha, nMargem, nTreeAltura, nTreeLargura, oPanelMain, , , .T.)

	FT140CTree(oTree, @cCodVazio, @cProdVazio, @lExisteGrupo, @cGrupoVazio, @cRecnoVazio, @cTexto, @cCodCargo, cFilialACU)

	// Ativa a janela
	oDialog:Activate()

	// Limpeza dos arrays e objetos
	FwFreeArray(aCodigosBusca)
	FwFreeObj(oDialog)
	FwFreeObj(oPanelMain)
	FwFreeObj(oPanelBusca)
	FwFreeObj(oGet)
	FwFreeObj(oSayPos)
	FwFreeObj(oBtnProximo)
	FwFreeObj(oBtnAnterior)
	FwFreeObj(oTree)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140Ok
Obtém o código selecionado na DBTree, posiciona a tabela ACU e fecha o diálogo
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   12/11/2025
@version P12
@param oTree - Objeto DbTree com o nó selecionado
@param oDialog - Objeto FWDialogModal a ser desativado
@return lRet - Lógico
/*/
//-------------------------------------------------------------------
Function FT140Ok(oTree, oDialog)
	Local cCargoSel   As Character
	Local cCodigoSel  As Character
	Local cFilialACU  As Character
	Local nCodTam     As Numeric
	Local lRet        As Logical

	cFilialACU := FwxFilial("ACU")
	nCodTam    := Len(ACU->ACU_COD)
	lRet       := .T.

	// Obtém o Cargo do nó selecionado
	cCargoSel := oTree:GetCargo()

	// Verifica se um nó válido foi selecionado
	If Substr(cCargoSel, 1, 1) == "1"
		// Extrai o código da categoria
		cCodigoSel := Substr(cCargoSel, 2, nCodTam)

		// Posiciona a tabela ACU no registro correto
		DbSelectArea("ACU")
		ACU->(DbSetOrder(1)) // ACU_FILIAL + ACU_COD
		
		If !ACU->(MsSeek(cFilialACU + cCodigoSel))
			Help(" ", 1, STR0021, , STR0038, 1, 0)

			lRet := .F.
		EndIf
	EndIf

	// Fecha o diálogo e retorna o código
	oDialog:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140Param
Obtém o valor digitado na busca
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   14/11/2025
@version P12
@param cParam - Parâmetro do bloco de código
@param nPCount - Valor função PCount()
@param cChaveBusca - Valor digitado pelo usuário
@return cChaveBusca - Valor digitado pelo usuário
/*/
//-------------------------------------------------------------------
Function FT140Param(cParam, nPCount, cChaveBusca)
	If nPCount > 0
		cChaveBusca := cParam
	EndIf
Return cChaveBusca

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140AtuPos
Atualiza o indicador de posição na tela
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   11/11/2025
@version P12
@param nIndice - Índice atual (posição)
@param aCodigos - Array de códigos com o total de resultados
@param cPosAtual - Variável caracter de referência para o TSay
/*/
//-------------------------------------------------------------------
Function FT140AtuPos(nIndice, aCodigos, cPosAtual)
	If Len(aCodigos) == 0
		cPosAtual := ""
	Else
		cPosAtual := AllTrim(Str(nIndice)) + STR0037 + AllTrim(Str(Len(aCodigos)))
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140Prox
Realiza a busca do próximo nó na DBTree com base na chave de categoria informada
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   11/11/2025
@version P12
@param oTree - Objeto DbTree
@param cChave - Valor (não referência) da chave de busca
@param aCodigosBusca - Código da chave digitada pelo usuário
@param nIndiceBusca - Índice da busca
@param cProdVazio - CriaVar do ACV_CODPRO
@param cGrupoVazio - CriaVar do ACV_GRUPO
@param cRecnoVazio - StrZero
@param cPosicaoAtual - Posição atual do índice
/*/
//-------------------------------------------------------------------
Function FT140Prox(oTree, cChave, aCodigosBusca, nIndiceBusca, cProdVazio, cGrupoVazio, cRecnoVazio, cPosicaoAtual)
	Local aArea         As Array
	Local cCargoBusca   As Character
	Local cBuscaUsuario As Character
	Local cCodBusca     As Character
	Local cCodCategoria As Character
	Local lContinua     As Logical

	aArea             := FwGetArea()
	cCargoBusca       := ""
	cBuscaUsuario     := AllTrim(cChave)
	cCodBusca         := AllTrim(cChave)
	cCodCategoria     := ""
	lContinua         := .T.

	// Se código for vazio exibe mensagem
	If Empty(cCodBusca)
		Help(" ", 1, STR0021, , STR0038, 1, 0) 
		lContinua := .F.
	EndIf

	// Preenche a lista de códigos correspondentes
	If Empty(aCodigosBusca) .And. lContinua
		aCodigosBusca := FT140GetCod(cBuscaUsuario)
		nIndiceBusca  := 0
	EndIf

	// Se a busca não encontrou nada, reseta e sai
	If Empty(aCodigosBusca) .And. lContinua
		Help(" ", 1, STR0021, , STR0039 + "'" + cBuscaUsuario + "'.", 1, 0) 
		FT140AtuPos(0, aCodigosBusca, @cPosicaoAtual) 
		lContinua := .F.
	EndIf

	// Se continua a execução
	If lContinua
		// Incrementa o índice
		nIndiceBusca++

		// Se o índice estourar o limite, volta para o primeiro e informa o usuário
		If nIndiceBusca > Len(aCodigosBusca)
			nIndiceBusca := 1
		EndIf

		// Obtém o código atual da lista
		cCodCategoria := aCodigosBusca[nIndiceBusca]

		FT140AtuPos(nIndiceBusca, aCodigosBusca, @cPosicaoAtual)

		// Monta o Cargo e faz o TreeSeek
		cCodCategoria := PadR(cCodCategoria, Len(ACU->ACU_COD))
		cCargoBusca   := "1" + cCodCategoria + cProdVazio + cGrupoVazio + cRecnoVazio

		oTree:TreeSeek(cCargoBusca)
	EndIf

	FwRestArea(aArea)

	// Limpeza do array
	FwFreeArray(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140Ant
Realiza a busca do nó anterior na DBTree
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   11/11/2025
@version P12
@param oTree - Objeto DbTree
@param cChave - Valor (não referência) da chave de busca
@param aCodigosBusca - Código da chave digitada pelo usuário
@param nIndiceBusca - Índice da busca
@param cProdVazio - CriaVar do ACV_CODPRO
@param cGrupoVazio - CriaVar do ACV_GRUPO
@param cRecnoVazio - StrZero
@param cPosicaoAtual - Posição atual do índice
/*/
//-------------------------------------------------------------------
Function FT140Ant(oTree, cChave, aCodigosBusca, nIndiceBusca, cProdVazio, cGrupoVazio, cRecnoVazio, cPosicaoAtual)
	Local aArea         As Array
	Local cCargoBusca   As Character
	Local cBuscaUsuario As Character
	Local cCodBusca     As Character
	Local cCodCategoria As Character
	Local lContinua     As Logical

	aArea         := FwGetArea()
	cCargoBusca   := ""
	cBuscaUsuario := AllTrim(cChave)
	cCodBusca     := AllTrim(cChave)
	cCodCategoria := ""
	lContinua     := .T.

	// Se a lista de resultados não foi carregada, carrega como se fosse o primeiro clique em Próximo
	If Empty(aCodigosBusca)
		aCodigosBusca := FT140GetCod(cBuscaUsuario)
		nIndiceBusca := 1 
	EndIf

	// Checagem de busca vazia
	If Empty(aCodigosBusca)
		Help(" ", 1, STR0021, , STR0039 + "'" + cBuscaUsuario + "'.", 1, 0) 
		FT140AtuPos(0, aCodigosBusca, @cPosicaoAtual)
		lContinua := .F.
	EndIf

	// Se continua a execução
	If lContinua
		// Decrementa o índice
		nIndiceBusca--

		// Se o índice for zero ou negativo, volta para o último e informa
		If nIndiceBusca <= 0
			nIndiceBusca := Len(aCodigosBusca)
		EndIf

		// Obtém o código, monta o Cargo e faz o TreeSeek
		cCodCategoria := aCodigosBusca[nIndiceBusca]
		cCodCategoria := PadR(cCodCategoria, Len(ACU->ACU_COD))
		cCargoBusca   := "1" + cCodCategoria + cProdVazio + cGrupoVazio + cRecnoVazio

		oTree:TreeSeek(cCargoBusca)

		// Atualiza o indicador de posição
		FT140AtuPos(nIndiceBusca, aCodigosBusca, @cPosicaoAtual)
	EndIf

	FwRestArea(aArea)
	FwFreeArray(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140GetCod
Busca o código de Agrupador na tabela ACU pelo Código ou Descrição
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   07/11/2025
@version P12
@param cBusca - Código ou Descrição da categoria digitada
@return aCodigos - Array com todas as correspondências encontradas
/*/
//-------------------------------------------------------------------
Function FT140GetCod(cBusca)
	Local aArea       As Array
	Local aCodigos    As Array
	Local cBuscaUpper As Character
	Local cCodAtual   As Character
	Local cFilialACU  As Character
	Local cAliasQry   As Character
	Local nParam      As Numeric
	Local cQueryGet   As Character

	aArea       := FwGetArea()
	aCodigos    := {}
	cBuscaUpper := Upper(AllTrim(cBusca))
	cCodAtual   := ""
	cFilialACU  := FwxFilial("ACU")
	cAliasQry   := GetNextAlias()

	If oQueryLookup == Nil
		// Usa a função centralizada para buscar a string da Query
		cQueryGet := FT140SQL("LOOKUP")

		oQueryLookup := FWExecStatement():New(cQueryGet)
	EndIf

	// Binding dos parâmetros
	nParam := 1
	oQueryLookup:SetString(nParam++, cFilialACU)
	oQueryLookup:SetString(nParam++, Space(1))
	oQueryLookup:SetString(nParam++, "1")
	oQueryLookup:SetString(nParam++, cBuscaUpper)
	oQueryLookup:SetString(nParam++, "%" + cBuscaUpper + "%")

	oQueryLookup:OpenAlias(cAliasQry)

	// Varre a query de categorias (resultados já filtrados pelo banco)
	While !(cAliasQry)->(Eof())
		cCodAtual := (cAliasQry)->ACU_COD
		
		// Adiciona ao array se ainda não estiver
		If AScan(aCodigos, cCodAtual) == 0
			AAdd(aCodigos, cCodAtual)
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	FwRestArea(aArea)

	// Limpeza do array e objeto
	FwFreeArray(aArea)
Return aCodigos

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140CTree
Monta a tree com os dados do Cadastro de Categorias (ACU)
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   07/11/2025
@version P12
@param oTree - Objeto da árvore
@param cCodPai - Código pai
@param cProdVazio - CriaVar do ACV_CODPRO
@param lExisteGrupo - ColumnPos do ACV_GRUPO
@param cGrupoVazio - CriaVar do ACV_GRUPO
@param cRecnoVazio - StrZero
@param cTexto - Variável do texto (Texto do nó pai, usado na raiz)
@param cCodCargo - Código do cargo (Código do nó pai, usado na raiz)
@param cFilialACU - Filial (Ajuste Performance)
/*/
//-------------------------------------------------------------------
Function FT140CTree(oTree, cCodPai, cProdVazio, lExisteGrupo, cGrupoVazio, cRecnoVazio, cTexto, cCodCargo, cFilialACU)
	Local aArea       As Array
	Local cAliasQry   As Character
	Local nParam      As Numeric
	Local lHasChild   As Logical
	Local cCodAtual   As Character
	Local cTextoAtual As Character
	Local cQueryTree  As Character

	aArea     := FwGetArea()
	cAliasQry := GetNextAlias()

	If oQueryTree == Nil
		// Usa a função centralizada para buscar a string da Query
		cQueryTree := FT140SQL("TREE")

		oQueryTree := FWExecStatement():New(cQueryTree)
	EndIf

	nParam := 1
	oQueryTree:SetString(nParam++, cFilialACU)
	oQueryTree:SetString(nParam++, Space(1))
	oQueryTree:SetString(nParam++, "1")
	oQueryTree:SetString(nParam++, cCodPai)

	oQueryTree:OpenAlias(cAliasQry)

	// Preparação da Árvore para atualização
	oTree:BeginUpdate()

	// Adiciona o nó "Raiz" se a função não for chamada por recursão
	If Empty(cCodPai)
		oTree:AddTree(STR0040 + Space(130), .T., , , "BPMSEDT3", "BPMSEDT3", "1" + cCodPai + cProdVazio + cGrupoVazio + cRecnoVazio) // "Raiz"
	EndIf

	// Percorre as Categorias
	While !(cAliasQry)->(Eof())
		cCodAtual   := (cAliasQry)->ACU_COD
		cTextoAtual := (cAliasQry)->ACU_DESC

		// Verifica se o item atual possui filhos válidos
		lHasChild := FT140HasCh(cCodAtual, cFilialACU)
		
		// Adiciona o item a árvore e chama recursão
		If lHasChild
			// Adiciona um nó expansível na árvore
			oTree:AddTree(cTextoAtual, .T., , , "BPMSEDT3", "BPMSEDT3", "1" + cCodAtual + cProdVazio + cGrupoVazio + cRecnoVazio)
			
			// Chamada recursiva para montar o próximo nível
			FT140CTree(oTree, cCodAtual, cProdVazio, lExisteGrupo, cGrupoVazio, cRecnoVazio, cTextoAtual, cCodAtual, cFilialACU)
			
			// Fecha o nó que foi aberto para a chamada recursiva
			oTree:EndTree()
		Else
			// Adiciona um item na árvore
			oTree:AddTreeItem(cTextoAtual, "BPMSEDT3", "BPMSEDT3", "1" + cCodAtual + cProdVazio + cGrupoVazio + cRecnoVazio)
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	// Finaliza e fecha a árvore
	oTree:EndUpdate()

	// Encerra a construção total da árvore apenas na raiz
	If Empty(cCodPai)
		oTree:EndTree()
	EndIf

	FwRestArea(aArea)

	// Limpeza do array e objeto
	FwFreeArray(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140HasCh
Verifica se uma categoria tem filhos válidos
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   14/11/2025
@version P12
@type    Function
@param cCodPai - Código da categoria pai a ser verificada
@param cFilialACU - Filial recebida por parametro
@return lHasChild - .T. se tiver filhos, .F. caso contrário
/*/
//-------------------------------------------------------------------
Function FT140HasCh(cCodPai, cFilialACU)
	Local lHasChild   As Logical
	Local cAliasQry   As Character
	Local aArea       As Array
	Local nParam      As Numeric
	Local cQueryHas   As Character

	aArea     := FwGetArea()
	cAliasQry := GetNextAlias()
	lHasChild := .F.

	If oQueryHasCh == Nil
		// Usa a função centralizada para buscar a string da Query
		cQueryHas := FT140SQL("HASCH")

		oQueryHasCh := FWExecStatement():New(cQueryHas)
	EndIf

	// Binding dos parâmetros
	nParam := 1
	oQueryHasCh:SetString(nParam++, cFilialACU)
	oQueryHasCh:SetString(nParam++, Space(1))
	oQueryHasCh:SetString(nParam++, "1")
	oQueryHasCh:SetString(nParam++, cCodPai)

	oQueryHasCh:OpenAlias(cAliasQry)

	lHasChild := !(cAliasQry)->(Eof()) .And. (cAliasQry)->QTD > 0

	(cAliasQry)->(DbCloseArea())
	
	FwRestArea(aArea)

	// Limpeza do array
	FwFreeArray(aArea)
Return lHasChild

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140ETree
Estrutura das categorias
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   07/11/2025
@version P12
@param oTree - Objeto DbTree
/*/
//-------------------------------------------------------------------
Function FT140ETree(oTree)
	Local aArea      As Array
	Local cCargo     As Character
	Local cFilialACU As Character
	Local cCodigo    As Character

	aArea       := FwGetArea()
	cCargo      := oTree:GetCargo()
	cFilialACU  := FwxFilial("ACU")
	cCodigo     := Substr(cCargo, 2, Len(ACU->ACU_COD))

	// Posiciona no item selecionado
	DbSelectArea("ACU")
	ACU->(DbSetOrder(1)) // ACU_FILIAL + ACU_COD
	If ACU->(DbSeek(cFilialACU + cCodigo))
		FwExecView("", "FATA140", MODEL_OPERATION_VIEW, , {|| .T.})
	EndIf

	FwRestArea(aArea)

	// Limpeza do array
	FwFreeArray(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FT140SQL
Centraliza a lógica das queries para aplicar o princípio DRY
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   12/12/2025
@version P12
@param cType - Tipo da Query (LOOKUP, TREE, HASCH)
@return cQuery - String SQL formatada
/*/
//-------------------------------------------------------------------
Function FT140SQL(cType)
	Local cQuery As Character

	cQuery := ""

	// Monta a query
	cQuery := " SELECT "

	If cType == "HASCH"
		cQuery += " COUNT(1) QTD"
	Else
		cQuery += " ACU.ACU_COD "

		If cType == "TREE"
			cQuery += ", ACU.ACU_DESC "
		EndIf
	EndIf

	cQuery +=  " FROM " + RetSqlName("ACU") + " ACU "
	cQuery += " WHERE ACU.ACU_FILIAL = ? "
	cQuery +=   " AND ACU.D_E_L_E_T_ = ? "
	cQuery +=   " AND ACU.ACU_MSBLQL <> ? "

	// Cláusulas específicas
	If cType == "LOOKUP"
		cQuery += " AND (ACU.ACU_COD = ? OR UPPER(ACU.ACU_DESC) LIKE ? )"
		cQuery += " ORDER BY ACU.ACU_FILIAL, ACU.ACU_CODPAI"
	ElseIf cType == "TREE"
		cQuery += " AND ACU.ACU_CODPAI = ? "
		cQuery += " ORDER BY ACU.ACU_FILIAL, ACU.ACU_CODPAI"
	ElseIf cType == "HASCH"
		cQuery += " AND ACU.ACU_CODPAI = ? "
	EndIf

	// Aplica o tratamento de banco
	cQuery := ChangeQuery(cQuery)
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} FA140Close
Fecha as queries e áreas abertas
@type    Function
@author  Paulo Dias Oliveira - Jorge Martins / Squad Retail
@since   15/12/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function FA140Close()
	If oQueryLookup != NIL
		oQueryLookup:Destroy()
		oQueryLookup := NIL
	EndIf

	If oQueryHasCh != NIL
		oQueryHasCh:Destroy()
		oQueryHasCh := NIL
	EndIf

	If oQueryTree != NIL
		oQueryTree:Destroy()
		oQueryTree := NIL
	EndIf
Return Nil
