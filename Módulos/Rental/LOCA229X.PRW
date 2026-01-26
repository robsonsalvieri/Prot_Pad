#INCLUDE "TOTVS.CH"
#INCLUDE "LOCA229X.CH"

//****************************************************************************
// Funções genericas para a Gestao de Expediçao
//****************************************************************************
/*/{Protheus.doc} LOCA229XQ5
Funçao que monta uma pesquisa customizada relacionado FQ5 com FQ7
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/9/2025
@return variant, retorna se a operação foi bem sucedida
/*/
Function LOCA229XQ5()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aTabRecDes := {}

Local cCpoAnt   := &cVar
Local cCodTab   := ""
Local cRadical  := ""

	aTabRecDes := LOCA229XQ1(M->FQU_PROJET, M->FQU_OBRA)
	
	if len(aTabRecDes) > 0

		Define MsDialog oDlgCons Title STR0001 From 000, 000 To 450, 800 PIXEL //"Consulta de A.S.F."

		Define Font oFont Name 'Courier New' Size 0, -12		
		oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0002, STR0003, STR0004, STR0005, STR0006,;
				STR0007, STR0008, STR0009, STR0010 },,;    
									oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	
		oGetCons:Align   := CONTROL_ALIGN_TOP
		oGetCons:SetArray(aTabRecDes)
		oGetCons:bLine := {||{	aTabRecDes[oGetCons:nAt,1],aTabRecDes[oGetCons:nAt,2], aTabRecDes[oGetCons:nAt,3],;
		aTabRecDes[oGetCons:nAt,4],aTabRecDes[oGetCons:nAt,5], aTabRecDes[oGetCons:nAt,6],;
		aTabRecDes[oGetCons:nAt,7],aTabRecDes[oGetCons:nAt,8], aTabRecDes[oGetCons:nAt,9] } }	                            
		oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

		@208,310 BUTTON STR0011 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	
		@208,360 BUTTON STR0012 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	

		Activate MsDialog oDlgCons Centered

		If nOpcA == 1 
			&cVar := aTabRecDes[nAt,1]
			FQ5->( dbGoto(Atail(aTabRecDes[nAt])))
		Else
			//recupera o que estava anteriormente
			&cVar := cCpoAnt
			lRet := .F.
		EndIf
	Else
		Help(Nil,	Nil,"LOCA229XQ5",; 
				Nil, STR0013 ,1,0,Nil,Nil,Nil,Nil,Nil,;
				{ STR0014 } )
		&cVar := cCpoAnt
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA229XQ1
Retorna um array com codigo/descricao de AS e Conjunto transportador
@type function 
@author TOTVS
@since 26/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function LOCA229XQ1(cProjeto, cObra)
Local aArea      := GetArea()
Local cQuery     := ""
Local aRetorno   := {}
Local cAliasTmp  := GetNextAlias()
Local aBindParam := {}

cQuery += " SELECT FQ5_AS, FQ5_OBRA, FQ7_DESCRI, FQ7_LCCORI, FQ7_LCLORI, FQ7_LOCCAR"
cQuery += " ,FQ7_LCCDES, FQ7_LCLDES, FQ7_LOCDES, FQ5.R_E_C_N_O_ RECFQ5"
cQuery += " FROM " + RetSqlName("FQ7")+ " FQ7"
cquery += " INNER JOIN " + RetSqlName("FQ5")+ " FQ5"
cQuery += " ON FQ5_FILIAL = '"+xFilial("FQ5")+"' " 
cQuery += "  AND FQ5_VIAGEM = FQ7_VIAGEM"
cQuery += "  AND FQ5.D_E_L_E_T_ = ' '"
cQuery += " WHERE "
cQuery +=  "  FQ7_FILIAL = '"+xFilial("FQ7")+"' " 
cQuery += "   AND FQ7_PROJET = ? " 
aadd(aBindParam, cProjeto)
if !Empty(cObra)
	cQuery += "   AND FQ7_OBRA  = ? "
	aadd(aBindParam, cObra)
endif
cQuery += "   AND FQ7_TPROMA  = '0' "
cQuery += "   AND FQ7.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY FQ5_AS"


cQuery := ChangeQuery( cQuery )
MPSysOpenQuery( cQuery ,cAliasTmp,,,aBindParam)

While (cAliasTmp)->( ! Eof() )
	aAdd( aRetorno, { (cAliasTmp)->FQ5_AS,(cAliasTmp)->FQ5_OBRA, (cAliasTmp)->FQ7_DESCRI,;
	(cAliasTmp)->FQ7_LCCORI, (cAliasTmp)->FQ7_LCLORI, (cAliasTmp)->FQ7_LOCCAR,;
	(cAliasTmp)->FQ7_LCCDES, (cAliasTmp)->FQ7_LCLDES, (cAliasTmp)->FQ7_LOCDES, (cAliasTmp)->RECFQ5} )
	(cAliasTmp)->( dbSkip() )
EndDo

(cAliasTmp)->( DBCloseArea() )

RestArea(aArea)

Return(aRetorno)

/*/{Protheus.doc} LOCA229XVH
Valida a Hora deve estar no formato 00:00 até 24:00
@type function
@version 15.10 
@author Alexandre Circenis
@since 4/17/2025
@return variant, .T. se a hora for valida
/*/
Function LOCA229XVH()
Local lRet := .T.
Local cTime := &(ReadVar())
Local cHora
Local cMin
Local nAchou := At( ":", cTime )
Local nX

for nX := 1 to Len(cTime)
	if !(SubStr(cTime, nX, 1) $ '1234567890') .and. nX <> nAchou
		lRet := .F.
		exit
	endif 
next nX

if lRet

	cHora := Left(cTime ,2) // Os primeiros 2 caracteres sao hora
	cMin  := Right(cTime,2) // Os ultmos 2 caracteres sao minutos
	if cHora+cMin <> '2400' // Continuar validando pois não é 24 horas

		lRet := cHora >= '00' .and. cHora <= '23' .and. cMin >= '00' .and. cMin <= '59'

	endif

endif

if !lRet

	Help(Nil,	Nil,"LOCA229XVH",; 
				Nil, STR0015 ,1,0,Nil,Nil,Nil,Nil,Nil,;
				{STR0014 } )

endif

Return lRet
