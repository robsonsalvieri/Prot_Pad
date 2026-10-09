#INCLUDE "PROTHEUS.CH"
#INCLUDE "GEMA141.CH"

#define  _TamCodEm_  TamSX3("LIQ_COD")[1]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEMA141  ³ Autor ³ Cristiano Denardi     ³ Data ³ 26.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de empreendimentos LK3									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
TEMPLATE Function GEMA141()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	AxCadastro("LK3",STR0001) //"Empreendimentos"

Return( .T. )
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEMA141  ³ Autor ³ Cristiano Denardi     ³ Data ³ 26.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao para Cpos de Mascara e Codigo				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function Gem140Vld( cCpo )

Local   aArea  := {}
Local   lRet	:= .T.
Local   aMasc	:= {}
Local   nTam	:= 0
Local   cMasc	:= ""
Default cCpo	:= ""

If Empty(cCpo)
	lRet := .T.
Else
	//////////////////////////
	// Validacoes das mascaras
	Do Case
		Case cCpo == "LK3_MASCAR"
			////////////
			// nao vazio
			If Empty(M->LK3_MASCAR)
				lRet := .F.
				MsgAlert( STR0002, STR0003 ) //"Campo Mascara deve ser preenchido."###"Atencao!"
			Endif
			/////////////
			// valida LK2
			If lRet .And. !ExistCpo("LK2",M->LK3_MASCAR)
				lRet := .F.
			Endif       
			/////////////////////////////////////////
			// Valida se Mascara e' maior que tamanho 
			// do Cpo do Codigo de Empreendimentos
			If lRet
				cMasc := T_GEMmascCnf( M->LK3_MASCAR )[1][1]
				If Len( cMasc ) > _TamCodEm_
					lRet := .F.
					MsgAlert( STR0004, STR0003 ) //"Mascara invalida, pois seu tamanho e maior que suportado pelo campo de codigo."###"Atencao!"
				Endif
			Endif
			
		Case cCpo == "LK3_CODEMP"
			////////////////////
			// nao vazio mascara
			If Empty(M->LK3_MASCAR)
				lRet := .F.
				MsgAlert( STR0005+STR0006+STR0007, STR0003 ) //"Campo "###"Mascara"###" deve ser preenchido."###"Atencao!"
			Endif
			////////////
			// nao vazio
			If lRet .And. Empty(M->LK3_CODEMP)
				lRet := .F.
				MsgAlert( STR0005+STR0008+STR0007, STR0003 ) //"Campo "###"Codigo"###" deve ser preenchido."###"Atencao!"
			Endif
			////////////////////////////////////
			// Valida se respeita tam da mascara
			If lRet
				aMasc := T_GEMmascCnf( M->LK3_MASCAR )
				nTam  := aMasc[2][1][2]
				If Len( Alltrim(M->LK3_CODEMP) ) <> nTam
					lRet := .F.
					MsgAlert(	STR0013 +; //"Conforme Mascara escolhida, o Codigo do Empreendimento sera valido quando possuir exatamente"
									" "+Alltrim(Str(nTam,0))+" "+If(nTam>1,STR0014,STR0015)+"," +; //"digitos"###"digito"
									STR0011, STR0003 ) //" favor corrigir."###"Atencao!"
				Endif
			Endif
			///////////////////////
			// Verifica duplicidade
			If lRet
				aArea := GetArea()
					dbSelectArea("LK3")
					dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
					If MsSeek( xFilial("LK3")+M->LK3_CODEMP )
						lRet := .F.
						MsgAlert( STR0012, STR0003 ) //"Ja existe cadastrado este Codigo do Empreendimento."###"Atencao!"
					Endif
				RestArea( aArea )
			Endif
			
		OtherWise
			lRet := .T.
	EndCase
Endif

Return( lRet )