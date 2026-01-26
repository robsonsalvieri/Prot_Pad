#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA092.CH"
                                
PUBLISH MODEL REST NAME FISA092 SOURCE FISA092

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA092
Cadastro MVC da Tabela IBPT para uso no projeto Olho no Imposto - 
Apresentado por ente Tributário

@author Simone Oliveira
@since 26/11/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA092()
Local	oBrw := FWmBrowse():New()

IF  AliasIndic("CLK") 
	oBrw := FWMBrowse():New()
	oBrw:SetAlias("CLK")
	oBrw:SetMenuDef('FISA092')
	oBrw:SetDescription(STR0001) //Cadastro da Tabela IBPT
	oBrw:Activate()
Else
	Help("",1,"Help","Help",STR0002,1,0) // Tabela CLK não cadastrada no sistema!
EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Simone Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.FISA092'	 OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Incluir' 	ACTION 'VIEWDEF.FISA092'	 OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE 'Alterar' 	ACTION 'VIEWDEF.FISA092'	 OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE 'Excluir' 	ACTION 'VIEWDEF.FISA092'	 OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE 'Importar' 	ACTION 'ImpIBPT()'	   	 OPERATION 3 ACCESS 0 
	
Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Simone Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStru	:=	FWFormStruct(1, 'CLK')
Local oModel 	:=	MPFormModel():New('FISA092')


	oModel	:=	MPFormModel():New('FISA092MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA092MOD' ,, oStru )	   
	
	oModel:SetPrimaryKey({"CLK_FILIAL"},{"CLK_CODNCM"},{"CLK_EX"},{"CLK_CODNBS"},{"CLK_UF"})
	
	oModel:SetDescription("Tabela IBPT") 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Simone Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local	oModel	:=	FWLoadModel('FISA092')
Local	oStru		:=	FWFormStruct(2, 'CLK')
Local	oView 	:=	FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW', oStru, 'FISA092MOD')

oView:EnableTitleView('VIEW', STR0001) //Cadastro da Tabela IBPT
oView:CreateHorizontalBox('FIELDS', 100)
oView:SetOwnerView('VIEW', 'FIELDS')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validacao das informacoes digitadas no form.

@author Simone dos Santos de Oliveira
@since 27.11.2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet		:=	.T.
	Local cNcm		:=	oModel:GetValue ('FISA092MOD','CLK_CODNCM')
	Local cNbs		:=	oModel:GetValue ('FISA092MOD','CLK_CODNBS')
	Local cEx		:=	oModel:GetValue ('FISA092MOD','CLK_EX')
	Local cUfOrig	:=	oModel:GetValue ('FISA092MOD','CLK_UF')
	Local dDtIniV	:=	oModel:GetValue ('FISA092MOD','CLK_DTINIV')
	Local dDtFimV	:=	oModel:GetValue ('FISA092MOD','CLK_DTFIMV')
	Local nOperation 	:=	oModel:GetOperation()
		
	If nOperation == 3  //Inclusão de informações ou alterações.
	
		cNcm	+= Space(TamSX3("CLK_CODNCM")[1]-Len(cNcm))
		cNbs	+= Space(TamSX3("CLK_CODNBS")[1]-Len(cNbs))
		cEx		+= Space(TamSX3("CLK_EX")[1]-Len(cEx))
		
		If dDtFimV < dDtIniV
			lRet := .F.			
			Help("",1,"Help","Help",STR0007,1,0) //"Estrutura inválida! Data Final de Vigência menor que a Data Inicial de Vigência." 
		ElseIf !Empty(cNcm) .And. !Empty(cNbs)
			lRet := .F.			
			Help("",1,"Help","Help",STR0005,1,0)//"Estrutura inválida! Verifique se o código incluso trata-se de um produto (NCM) ou Serviço(NBS)." 
		ElseIf Empty(cNcm) .And. Empty(cNbs)
			lRet := .F.			
			Help("",1,"Help","Help",STR0006,1,0) //"Estrutura inválida! Necessário inclusão de código NCM ou Código NBS."
		ElseIf !Empty(cNcm)
			If ExistReg(cNcm, cNbs, cEx, cUfOrig, dDtIniV, dDtFimV)			
				lRet := .F.			
				Help("",1,"Help","Help",STR0003,1,0) //"Código de NCM / Exceção / UF Origem já cadastrados! Se necessário, realize uma alteração."
			EndIf
		ElseIf !Empty(cNbs)
			If ExistReg(cNcm, cNbs, cEx, cUfOrig, dDtIniV, dDtFimV)
				lRet := .F.			
				Help("",1,"Help","Help",STR0004,1,0) //"Código de NBS / Exceção / UF Origem já cadastrados! Se necessário, realize uma alteração."
			EndIf
		EndIf
	EndIF

Return lRet
                                             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImpIBPT  ³       ³Fiscal                 ³ Data ³26.11.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³IMPORTACAO DA TABELA IBPT POR ENTE TRIBUTAÇÃO               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ImpIBPT()

Local oDlg
Local nOpcf		:= 0
Local cFile		:= ""


DEFINE MSDIALOG oDlg FROM  94,1 TO 223,293 TITLE OemToAnsi("Importacao da Tabela IBPT - Ente Tributário") PIXEL 

@ 07,07 TO 38, 139 OF oDlg  PIXEL

@ 14,17 Say OemToAnsi("Carga Tributária para uso em Cupons") SIZE 150,7 OF oDlg PIXEL  // "Carga Tributária para uso em Cupons"
@ 22,17 Say OemToAnsi("e Notas Fiscais - Lei 12.741/2012.") SIZE 100,7 OF oDlg PIXEL  // "e Notas Fiscais - Lei 12.741/2012."

DEFINE SBUTTON FROM 45, 080 TYPE 1 ENABLE OF oDlg ACTION(ChangeFile(.T.,@cFile) , nOpcf := 1, oDlg:End()) 
DEFINE SBUTTON FROM 45, 113 TYPE 2 ENABLE OF oDlg ACTION(oDlg:End())  

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcf == 1  
	Processa({|| AtuCLK(cFile)},'Processando....')  
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AtuCLK    ³ Rev.  ³FISCAL                 ³ Data ³26.11.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Importacao da Tabela IBPT por ente tributário - tabela CLK  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ CFile - Nome do arquivo a ser importado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Lógico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function  AtuCLK(cFile)

Local aCSVFile 	:= {} 
Local bOldError	:= ErrorBlock( {|x| VerErro(x) } ) // muda code-block de erro
Local cNcm			:= "" 
Local cNBS			:= ""
Local cEx			:= "" 
Local cUF			:= ""
Local cNomencl	:= UPPER("TabelaIBPTax")
Local cFONTE		:= "IBPT"
Local cDrive	:= "" 	// Resultado: "c:"
Local cDir		:= ""  // Resultado: "\path\"
Local cNomeArq:= ""  // Resultado: "arquivo"
Local cExt		:= ""  // Resultado: ".ext"
Local dDtIniV		:= CTOD("  /  /    ")
Local dDtIniF		:= CTOD("  /  /    ")
Local nRegs		:= 0 
Local nX 			:= 0
Local lRet := .T.

//Verifica se a tabela CLK existe     
SX3->(dbSetOrder(1)) 
If !SX3->(dbSeek("CLK")) 
	MSGStop('Tabela do IBPT (CLK) ainda não foi criada, rodar o update UPDFIS' , ' Atualização Tabela IBPT')
	Return .F.
EndIf	

//Grava o arquivo CSV em array
aCSVFile	:= CFG57Csv(cFile)
nRegs		:= Len(aCSVFile)
If nRegs == 0
	MSGStop('Arquivo com dados IBPT não encontrado!' , ' Atualização Tabela IBPT')
	Return .F.
EndIf

If Len(aCSVFile[1]) <> 13
	MSGStop('Estrutura do Arquivo IBPT Incorreta!' , ' Atualização Tabela IBPT')
	Return .F.
Endif

//Tratamento para pegar o nome do arquivo e definir UF

SplitPath( cFile, @cDrive, @cDir, @cNomeArq, @cExt )

If (Len(cNomeArq)> 13) .And. (Alltrim(UPPER(SubStr(cNomeArq,1,12)))$ cNomencl)
	cUF:= UPPER(SubStr(cNomeArq,13,2))
Else
	MSGStop('Verifique Nomenclatura da Tabela!' , ' Atualização Tabela IBPT')
	Return .F.
EndIf

//Fazer tratamento para pegar o estado do nome do arquivo e pra importar por nbs ou ncm

ProcRegua(nRegs)                

//Processa arquivo 
Begin Transaction
	Begin Sequence    
      	cCodTab := Alltrim(aCSVFile[2][12]) //Codigo da tabela
		dDtIniV:= CTOD(aCSVFile[2][9])
		dDtIniF:= CTOD(aCSVFile[2][10])
		
		For nX := 2 to  Len(aCSVFile)     // comeca em 2 porque 1a linha eh cabecalho					
			IncProc("Processando Registro : "+  alltrim(str(nX)) + ' do arquivo '  + cFile)		
			If Val(aCSVFile[nX][3]) == 0
				cNcm	:= Alltrim(aCSVFile[nX][1])
				cNcm	+= Space(TamSX3("CLK_CODNCM")[1]-Len(cNcm))
				cEx		:= IIf(Val(aCSVFile[nX][2])>0, Alltrim(Str(Val(aCSVFile[nX][2]))), '')
				cEx		+= Space(TamSX3("CLK_EX")[1]-Len(cEx))
				
				//Posiciono nas tabela conforme o item NBS ou NCM			
				CLK->(DbSetOrder(2))
				If !CLK->(dbSeek(xFilial("CLK") + cNcm + cEx + cUF + DTOS(dDtIniV) + DTOS(dDtIniF)))
					RecLock('CLK',.T.)                             
					CLK->CLK_FILIAL	:= xFilial("CLK")
					CLK->CLK_CODNCM	:= cNcm
					CLK->CLK_EX		:= cEx
					CLK->CLK_DESCR	:= aCSVFile[nX][4]		
					CLK->CLK_ALQNAC	:= Val(aCSVFile[nX][5])
					CLK->CLK_ALQIMP	:= Val(aCSVFile[nX][6])
					CLK->CLK_ALQEST	:= Val(aCSVFile[nX][7])
					CLK->CLK_ALQMUN	:= Val(aCSVFile[nX][8])
					CLK->CLK_UF		:= cUF
					CLK->CLK_VERSAO	:= cCodTab
					CLK->CLK_FONTE	:= cFONTE
					CLK->CLK_DTINIV	:= dDtIniV
					CLK->CLK_DTFIMV	:= dDtIniF
					CLK->(MsUnlock())	
				Else	
					If CLK->(dbSeek(xFilial("CLK") + cNcm + cEx + cUF + DTOS(dDtIniV) + DTOS(dDtIniF)))
						RecLock('CLK',.F.)
						CLK->CLK_VERSAO	:= cCodTab
						CLK->CLK_ALQNAC	:= Val(aCSVFile[nX][5])
						CLK->CLK_ALQIMP	:= Val(aCSVFile[nX][6])
						CLK->CLK_ALQEST	:= Val(aCSVFile[nX][7])
						CLK->CLK_ALQMUN	:= Val(aCSVFile[nX][8])
						CLK->(MsUnlock())
					Endif
				Endif	
			ElseIf Val(aCSVFile[nX][3]) == 1 .Or. Val(aCSVFile[nX][3]) == 2
				cNBS	:= Alltrim(aCSVFile[nX][1])
				cNBS	+= Space(TamSX3("CLK_CODNBS")[1]-Len(cNBS))
				cEx		:= IIf(Val(aCSVFile[nX][2])>0, Alltrim(Str(Val(aCSVFile[nX][2]))), '')
				cEx		+= Space(TamSX3("CLK_EX")[1]-Len(cEx))
								
				CLK->(DbSetOrder(1))
				If !CLK->(dbSeek(xFilial("CLK") + cNBS + cEx + cUF + DTOS(dDtIniV) + DTOS(dDtIniF)))
					RecLock('CLK',.T.)                             
					CLK->CLK_FILIAL	:= xFilial("CLK")
					CLK->CLK_CODNBS	:= cNBS
					CLK->CLK_EX		:= cEx
					CLK->CLK_DESCR	:= aCSVFile[nX][4]		
					CLK->CLK_ALQNAC	:= Val(aCSVFile[nX][5])
					CLK->CLK_ALQIMP	:= Val(aCSVFile[nX][6])
					CLK->CLK_ALQEST	:= Val(aCSVFile[nX][7])
					CLK->CLK_ALQMUN	:= Val(aCSVFile[nX][8])
					CLK->CLK_UF		:= cUF
					CLK->CLK_VERSAO	:= cCodTab
					CLK->CLK_FONTE	:= cFONTE
					CLK->CLK_DTINIV	:= dDtIniV
					CLK->CLK_DTFIMV	:= dDtIniF
					CLK->(MsUnlock())	
				Else	
					If CLK->(dbSeek(xFilial("CLK") + cNBS + cEx + cUF + DTOS(dDtIniV) + DTOS(dDtIniF)))
						RecLock('CLK',.F.)
						CLK->CLK_VERSAO	:= cCodTab
						CLK->CLK_ALQNAC	:= Val(aCSVFile[nX][5])
						CLK->CLK_ALQIMP	:= Val(aCSVFile[nX][6])
						CLK->CLK_ALQEST	:= Val(aCSVFile[nX][6])
						CLK->CLK_ALQMUN	:= Val(aCSVFile[nX][6])
						CLK->(MsUnlock())
					Endif
				Endif	
			Endif					
		Next
		MSGINFO('Importação da Tabela concluída!' , ' Atualização IBPT' )
		Recover		
		DisarmTransaction() //Caso tenha ocorrido erro a transaçao sera desfeita
		MSGStop('Ocorreu erro na transação de importação.' , ' Atualização IBPT')
		lRet := .F.
	End Sequence
	ErrorBlock(bOldError)
End Transaction
// limpando Array
aCSVFile := aSize(aCSVFile,0)
aCSVFile := Nil

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VerErro     ³ Autor ³ Fiscal                ³ Data ³ 09/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina analizadora do erro                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VerErro(e)
Local cDescErro := ""

IF e:gencode > 0  
	cDescErro := "DESCRIPTION: " + e:DESCRIPTION + Chr(10)+Chr(13)
  	cDescErro += "ERRORSTACK:"	+ Chr(10)+Chr(13)  
  	cDescErro += e:ERRORSTACK
	Alert(Alltrim(cDescErro))
  	Return .F.
EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChangeFile³ Autor ³ Fiscal                ³ Data ³ 09.08.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe arquivo                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ChangeFile(lOpen,cFile)
Local cFileChg       

DEFAULT lOpen := .T.

cType    := OemToAnsi("CSV|")+'*.CSV'
cFileChg	:= cGetFile(cType, OemToAnsi("Atualização IBPT"), 1,, lOpen, 1+16+32, .T.) 

If  Empty(cFileChg)
	cFile := ""
	Return 
Endif

If "."$cFileChg
	cFileChg := Substr(cFileChg,1,rat(".", cFileChg)-1)
Endif

cFileChg    := alltrim(cFileChg)
cFile       := Alltrim(cFileChg+Right(cType,4))

Return

/*/{Protheus.doc} ExistReg
  Função que valida se um registro já existe na data de vigencia informada
  @type Static Function
  @author luiz.foliveira
  @since 18/02/2025
  @version version
  @param cNcm - Código NCM
  @param cNbs - Código NBS
  @param cEx - Exceção
  @param cUfOrig - UF Origem
  @param dDtIniV - Data Inicial Vigência
  @param dDtFimV - Data Final Vigência
  @return lRet - Resultado para verificar se encontrou um registro existente
  @see (links_or_references)
/*/
Static Function ExistReg(cNcm, cNbs, cEx, cUfOrig, dDtIniV, dDtFimV)

    Local cQuery := ""
    Local oExec  := Nil
    Local lRet   := .F.
    Local nCount := 0

    // Montando a query
    cQuery := "SELECT COUNT(CLK.CLK_DTINIV) CNT "
    cQuery += "FROM " + RetSqlName("CLK") + " CLK "
    cQuery += "WHERE CLK.CLK_FILIAL = ? "
    If !Empty(cNcm)
        cQuery += "AND CLK.CLK_CODNCM = ? "
    Else
        cQuery += "AND CLK.CLK_CODNBS = ? "
    EndIf
    cQuery += "AND CLK_EX = ? " 
	cQuery += "AND CLK_UF = ? "
	cQuery += "AND ((CLK_DTINIV BETWEEN ? AND ? "
	cQuery += "OR CLK_DTFIMV BETWEEN ? AND ?) "
	cQuery += "OR (CLK_DTINIV <= ? AND CLK_DTFIMV >= ?)) "
	cQuery += "AND D_E_L_E_T_ = ?"

    // Executando a query
    oExec := FwExecStatement():New(cQuery)

    // Setando os parâmetros
    oExec:SetString(1, xFilial("CLK"))
	If !Empty(cNcm)
		oExec:SetString(2, cNcm)
	Else
		oExec:SetString(2, cNbs)
	EndIf
	oExec:SetString(3, cEx)
	oExec:SetString(4, cUfOrig)
	oExec:SetDate(5, dDtIniV)
	oExec:SetDate(6, dDtFimV)
	oExec:SetDate(7, dDtIniV)
	oExec:SetDate(8, dDtFimV)
	oExec:SetDate(9, dDtFimV)
	oExec:SetDate(10, dDtIniV)
	oExec:SetString(11, ' ')

    nCount := oExec:ExecScalar('CNT')

    // Se encontrou algum registro
    If nCount > 0
        lRet := .T.
    EndIf

	oExec:Destroy()
	oExec := nil

Return lRet
