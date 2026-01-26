#include "protheus.ch"
#include "topconn.ch"

Static lautoST := .F.

// PROGRAMA QUE REUNE OS CADASTROS PARA AMARRACOES CONTABEIS NO PLANO DE SAUDE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLCADBAV  บAutor  ณRoger Cangianeli    บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Amarracoes Contabeis para Comissoes            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADBAV()

LOCAL _aArea	:= GetArea()
Private aRotina	:= {}
Private cCadastro	:= ''

dbSelectARea("BAV")
dbSetOrder(1)

aRotina   := Menudef("BAV")

cCadastro := OemToAnsi("Contabilizacao PLS - Comissoes")

If !lautoST
	mBrowse(06,01,22,75,'BAV',,)
endif
RestArea(_aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLCADBAZ  บAutor  ณRoger Cangianeli    บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Amarracoes Contabeis para Faturamento          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADBAZ()

LOCAL _aArea	:= GetArea()
Private aRotina	:= {}
Private cCadastro	:= ''

dbSelectARea("BAZ")
dbSetOrder(1)

aRotina   := Menudef("BAZ")

cCadastro := OemToAnsi("Contabilizacao PLS - Faturamento")

If !lautoST
	mBrowse(06,01,22,75,'BAZ',,)
endif

RestArea(_aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLCADBB5  บAutor  ณRoger Cangianeli    บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Amarracoes Contabeis para Lctos Deb/Crd        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADBB5()

LOCAL _aArea	:= GetArea()
Private aRotina	:= {}
Private cCadastro	:= ''

dbSelectARea("BB5")
dbSetOrder(1)

aRotina   := Menudef("BB5")

cCadastro := OemToAnsi("Contabilizacao PLS - Lan็amentos Deb/Crd")

If !lautoST
	mBrowse(06,01,22,75,'BB5',,)
endif

RestArea(_aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLCADB0H  บAutor  ณRoger Cangianeli    บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Amarracoes Contabeis para Crd Custos           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADB0H()

LOCAL _aArea	:= GetArea()
Private aRotina	:= {}
Private cCadastro	:= ''

dbSelectARea("B0H")
dbSetOrder(1)

aRotina   := Menudef("B0H")

cCadastro := OemToAnsi("Contabilizacao PLS - Crd Custos ")

If !lautoST
	mBrowse(06,01,22,75,'B0H',,)
endif

RestArea(_aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLCADBBH  บAutor  ณRoger Cangianeli    บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Amarracoes Contabeis para Deb Custos           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADBBH()

LOCAL _aArea	:= GetArea()
Private cCadastro	:= ''
Private aRotina	:= {}

dbSelectARea("BBH")
dbSetOrder(1)

aRotina   := Menudef("BBH")

cCadastro := OemToAnsi("Contabilizacao PLS - Deb Custos ")

If !lautoST
	mBrowse(06,01,22,75,'BBH',,)
endif

RestArea(_aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLCADBB1  บAutor  ณRoger Cangianeli    บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Log dos registros incorretos da contabilizacao do PLS.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADBB1()

LOCAL _aArea	:= GetArea()
Private aRotina	:= {}
Private cCadastro	:= ''

dbSelectARea("BB1")
dbSetOrder(1)

aRotina   := {	{"Pesquisar" ,"AxPesqui",0,1} ,;
{"Visualizar","AxVisual",0,2} ,;
{"Limpar","PLEXCLOG('BB1')",0,5} ,;
{"Exportar"  ,"PLEXPLOG('BB1')",0,5} }

cCadastro := OemToAnsi("Log Contabiliza็ใo Incorreta do PLS")

If !lautoST
	mBrowse(06,01,22,75,'BB1',,)
endif

RestArea(_aArea)

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLCADBAD  บAutor  ณRoger Cangianeli    บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Log dos registros corretos da contabilizacao do PLS.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLCADBAD()

LOCAL _aArea	:= GetArea()
Private aRotina	:= {}
Private cCadastro	:= ''

dbSelectARea("BAD")
dbSetOrder(1)

aRotina   := {	{"Pesquisar" ,"AxPesqui",0,1} ,;
{"Visualizar","AxVisual",0,2} ,;
{"Limpar","PLEXCLOG('BAD')",0,5} ,;
{"Exportar"  ,"PLEXPLOG('BAD')",0,5} }

cCadastro := OemToAnsi("Log Contabiliza็ใo Correta do PLS")

If !lautoST
	mBrowse(06,01,22,75,'BAD',,)
endif

RestArea(_aArea)

Return


// FUNCAO PARA LIMPEZA DO ARQUIVO DE LOG
Function PLEXCLOG(cArq)
Local cFile
Default cArq	:= 'BAD'
If Aviso('Exclusใo de Log','Confirma a exclusใo de todos os registros de log desta tabela?',{"Prosseguir","Cancelar"},1,"Escolha") == 2
	Return
EndIf
MsAguarde({|| fRunExc(cArq) }, "Limpando arquivo...", "", .T.)
Return


Static Function fRunExc(cArq)
Local cQuery		:= ''
Default cArq		:= 'BAD'

cQuery := "delete from " + RetSqlName(cArq)
If (TCSQLExec(cQuery) < 0)
	Return MsgStop("TCSQLError() " + TCSQLError())
EndIf
Aviso('Fim de processamento','Registros removidos com sucesso.'+CHR(13),{"Ok"},2,"")

Return





// FUNCAO PARA ESCOLHA DO ARQUIVO TEXTO DE GERACAO DE LOG
Function PLEXPLOG(cArq)
Local cFile
Default cArq	:= 'BAD'
If Aviso('Exporta็ใo de Log','Confirma exporta็ใo de log para arquivo?',{"Prosseguir","Cancelar"},1,"Escolha") == 2
	Return
EndIf

cFile := cGetFile("Arquivos Texto|*.TXT",OemToAnsi("Salvar Arquivo Como..."))

If !Empty(cFile)
	MsAguarde({|| fRunExp(cFile,cArq) }, "Exportando arquivo...", "", .T.)
EndIf

Return



Static Function fRunExp(cFile,cArq)
Local aDatas	:= {}
LOCAL _lErroArq	:= .F.
Default cArq	:= 'BAD'

aDatas	:= fPergData()
If aDatas[1] == Ctod('01/01/1980') .and. aDatas[2]== Ctod('01/01/1980') .and. aDatas[5] == 'RETURN'
	Aviso('Aviso','Rotina cancelada pelo usuแrio.',{"Ok"},2,"")
	Return
EndIf

If !File(cFile)
	nHand	:= fCreate(cFile, 1)
Else
	nHand	:= fOpen(cFile, 2)
EndIf

// Posiciona no final do arquivo para fazer a gravacao
fSeek(nHand, 0, 2)


If cArq == 'BAD'
	// Executa query para filtrar dados a exportar
	cQuery	:= "SELECT BAD_DATA, BAD_HORA, BAD_LOG, BAD_LOG1 FROM "+RetSqlName("BAD")+" "
	cQuery	+= "WHERE BAD_FILIAL = '"+xFilial('BAD')+"' AND D_E_L_E_T_ = '' "
	cQuery	+= "AND BAD_DATA >= '"+DtoS(aDatas[1])+"' AND BAD_DATA <= '"+DtoS(aDatas[2])+"' "
	cQuery	+= "AND BAD_HORA >= '"+Subs(aDatas[3],1,2)+":"+Subs(aDatas[3],3,2)+":"+Subs(aDatas[3],5,2)+"' "
	cQuery	+= "AND BAD_HORA <= '"+Subs(aDatas[4],1,2)+":"+Subs(aDatas[4],3,2)+":"+Subs(aDatas[4],5,2)+"' "
	If !Empty(aDatas[5])
		cQuery	+= "AND BAD_LOG||BAD_LOG1 LIKE '%"+  AllTrim(aDatas[5]) +"%' "
	EndIf
	cQuery	+= "ORDER BY BAD_FILIAL, BAD_DATA, BAD_HORA "
Else
	cQuery	:= "SELECT BB1_DATA, BB1_HORA, BB1_LOG, BB1_LOG1 FROM "+RetSqlName("BB1")+" "
	cQuery	+= "WHERE BB1_FILIAL = '"+xFilial('BB1')+"' AND D_E_L_E_T_ = '' "
	cQuery	+= "AND BB1_DATA >= '"+DtoS(aDatas[1])+"' AND BB1_DATA <= '"+DtoS(aDatas[2])+"' "
	cQuery	+= "AND BB1_HORA >= '"+Subs(aDatas[3],1,2)+":"+Subs(aDatas[3],3,2)+":"+Subs(aDatas[3],5,2)+"' "
	cQuery	+= "AND BB1_HORA <= '"+Subs(aDatas[4],1,2)+":"+Subs(aDatas[4],3,2)+":"+Subs(aDatas[4],5,2)+"' "
	If !Empty(aDatas[5])
		cQuery	+= "AND BB1_LOG||BB1_LOG1 LIKE '%"+  AllTrim(aDatas[5]) +"%' "
	EndIf
	cQuery	+= "ORDER BY BB1_FILIAL, BB1_DATA, BB1_HORA "
EndIf

cQuery	:= ChangeQuery(cQuery)
PlsQuery(cQuery,'TRB')

dbSelectArea('TRB')
ProcRegua(RecCount())
dbGoTop()
If Eof()
	_lErroArq	:= .T.
Else
	While !Eof()
		IncProc()
		// Efetua gravacao do arquivo
		fWrite(nHand, CHR(10)+Dtoc(TRB->BAD_DATA)+'|'+TRB->BAD_HORA+'|'+TRB->BAD_LOG+TRB->BAD_LOG1)
		dbSkip()
	End
EndIf

dbCloseArea()

// Fecha arquivo
If !fClose(nHand)
	Aviso('Aten็ใo','Erro ao fechar o arquivo.',{"Ok"},2,"")
Else
	If !_lErroArq
		Aviso('Fim de processamento','Arquivo gerado com sucesso.'+CHR(13)+cFile,{"Ok"},2,"")
	Else
		Aviso('Aten็ใo','Nใo foram encontrados dados para gera็ใo do arquivo.'+CHR(13)+cFile,{"Ok"},2,"")
	EndIf
EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPergData บAutor  ณRoger/Clarice       บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirma data para exportacao do arquivo de log            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       | Protheus  - original de 09/06/06                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fPergData()
Local _dDataDe  := Date()
Local _dDataAte := Date()
Local _cHoraDe  := "000000"
Local _cHoraAte := "235959"
Local _cExp		:= Space(20)
Local bCanc    	:= {|| _oDlg:End(), _dDataDe:=CtoD('01/01/1980'), _dDataAte:=CtoD('01/01/1980'), _cHoraDe:="000000", _cHoraAte:="235959",_cExp:='RETURN'}

DEFINE MSDIALOG _oDlg TITLE OemtoAnsi("Exporta็ใo de Log") FROM C(100),C(100) TO C(300),C(300) PIXEL


// Cria Componentes Padroes do Sistema
@ C(006),C(012) Say "Digite o perํodo que deseja exportar" Size C(133),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(015),C(012) Say "Data de:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(015),C(040) MsGet oEdit1 Var _dDataDe 	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@D" Valid .T.
@ C(028),C(012) Say "Data At้:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(028),C(040) MsGet oEdit2 Var _dDataAte	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@D" Valid .T.
@ C(041),C(012) Say "Hora de:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(041),C(040) MsGet oEdit1 Var _cHoraDe 	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@R 99:99:99" Valid .T.
@ C(054),C(012) Say "Hora At้:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(054),C(040) MsGet oEdit2 Var _cHoraAte	Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Picture "@R 99:99:99" Valid .T.
@ C(067),C(012) Say "Expressao:" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(067),C(040) MsGet oEdit2 Var _cExp	Size C(042),C(009) COLOR CLR_BLACK PIXEL OF _oDlg Valid .T.

DEFINE SBUTTON FROM C(084),C(053) TYPE 1 ENABLE OF _oDlg ACTION (_oDlg:End())
DEFINE SBUTTON FROM C(084),C(075) TYPE 2 ENABLE OF _oDlg ACTION ( Eval(bCanc) )

ACTIVATE MSDIALOG _oDlg CENTERED

Return({_dDataDe,_dDataAte,_cHoraDe,_cHoraAte,AllTrim(_cExp)})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()      ณ Autor ณ Norbert Waage Junior  ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolu็ใo horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor
Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
EndCase
If "MP8" $ oApp:cVersion
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento para tema "Flat"ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Darcio R. Sporl       ณ Data ณ27/12/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ    1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef(cAlias)     

Local 	aRotina := {}
aaDD(aRotina,{"Pesquisa"		,"AxPesqui"		,0	,1	, 0, .F.})
aaDD(aRotina,{"Visualiza"	,"AxVisual"		,0	,2	, 0, .F.})     
If cAlias=="BBH"
	aaDD(aRotina,{"Incluir"		,'AxInclui("BBH",0,3,,,,"PLSTUDOK()")',0	,3	, 0, .F.})
Elseif cAlias =="BAV"
	aaDD(aRotina,{"Incluir"		,'AxInclui("BAV",0,3,,,,"PLSTUDOK()")',0	,3	, 0, .F.})
Elseif 	cAlias =="BB5"
	aaDD(aRotina,{"Incluir"		,'AxInclui("BB5",0,3,,,,"PLSTUDOK()")',0	,3	, 0, .F.})
Elseif cAlias =="BAZ"
	aaDD(aRotina,{"Incluir"		,'AxInclui("BAZ",0,3,,,,"PLSTUDOK()")',0	,3	, 0, .F.})
Else
	aaDD(aRotina,{"Incluir"		,'AxInclui("B0H",0,3,,,,"PLSTUDOK()")',0	,3	, 0, .F.})
Endif

if cAlias == "BBH"
	aaDD(aRotina,{"Alterar"		,'AxAltera("BBH",BBH->(recno()),4,,,,,"PLSBBHAltV()")'		,0	,4 	, 0, .F.})
elseif cAlias == "B0H"
	aaDD(aRotina,{"Alterar"		,'AxAltera("B0H",B0H->(recno()),4,,,,,"PLSB0HAltV()")'		,0	,4 	, 0, .F.})
else
	aaDD(aRotina,{"Alterar"		,"AxAltera"		,0	,4 	, 0, .F.})
endif
aaDD(aRotina,{"Excluir"		,"AxDeleta"		,0	,5 	, 0, .F.})


Return(aRotina)

                                          
Function PLSTUDOK()

Local lRet:= .T.
Local cAlias:= GetArea()
Local cChave := ""

If cAlias[1]="BBH"
	lRet:= ExistChav('BBH',M->BBH_TPBENE+M->BBH_TPUNIM+M->BBH_TPPRES+M->BBH_MODCOB+M->BBH_TPATO+M->BBH_REGPLN+M->BBH_TPPLN+M->BBH_PATROC+M->BBH_SEGMEN+M->BBH_CODPRO+M->BBH_GRUOPE+M->BBH_TPPAG)
Elseif cAlias[1]="B0H"
	cChave := M->B0H_TPBENE+M->B0H_TIPPRE+M->B0H_TPPRES+M->B0H_CODPRO
	if empty(M->B0H_GRUOPE)
		M->B0H_GRUOPE := '  '
	endif
	cchave += M->B0H_GRUOPE + M->B0H_TPPAG
	lRet:= ExistChav('B0H', cchave)
Elseif   cAlias[1]="BB5" 
	 lRet:= ExistChav('BB5',M->BB5_CODLAN+M->BB5_TIPPRE+M->BB5_COPCRE+M->BB5_CONREG ) 
	//BB5_FILIAL+BB5_CODLAN+BB5_TIPPRE+BB5_COPCRE+BB5_CONREG                                                                                                          
Elseif   cAlias[1]="BAZ" 
	 lRet:= ExistChav('BAZ',M->BAZ_TPBENE+M->BAZ_TPFATU+M->BAZ_TPUNIM+M->BAZ_TPATO+M->BAZ_REGPLN+M->BAZ_TPPLN+M->BAZ_PATROC+M->BAZ_SEGMEN+M->BAZ_CODPLA+M->BAZ_GRUOPE)                             
    //BAZ_FILIAL+BAZ_TPBENE+BAZ_TPFATU+BAZ_TPUNIM+BAZ_TPATO+BAZ_REGPLN+BAZ_TPPLN+BAZ_PATROC+BAZ_SEGMEN+BAZ_CODPLA+BAZ_GRUOPE   
Elseif cAlias[1]="BAV"
	 lRet:= ExistChav('BAV',M->BAV_TPBENE+M->BAV_MODCOB+M->BAV_REGPLN+M->BAV_TPPLN+M->BAV_PATROC+M->BAV_SEGMEN)                                     
    //BAV_FILIAL+BAV_TPBENE+BAV_MODCOB+BAV_REGPLN+BAV_TPPLN+BAV_PATROC+BAV_SEGMEN                                                                                                                            
Endif
Return(lRet)    

function PLcadctSt(lValor)
lautoST := lValor
return

function PLSBBHAltV()
Local lRet := .T.
Local nRecAtu := BBH->(Recno())
Local aArea := BBH->(getArea())

BBH->(dbsetOrder(1))
if BBH->(MsSeek(xFilial("BBH") + M->BBH_TPBENE+M->BBH_TPUNIM+M->BBH_TPPRES+M->BBH_MODCOB+M->BBH_TPATO+M->BBH_REGPLN+M->BBH_TPPLN+M->BBH_PATROC+M->BBH_SEGMEN+M->BBH_CODPRO+M->BBH_GRUOPE+M->BBH_TPPAG ))
	lRet := nRecAtu == BBH->(recno())
endif

if !lRet
	MsgAlert("Registro jแ cadastrado!")
endif
restarea(aArea)
return lRet

function PLSB0HAltV()
Local lRet := .T.
Local nRecAtu := B0H->(Recno())
Local aArea := B0H->(getArea())

B0H->(dbsetOrder(1))
if B0H->(MsSeek(xFilial("B0H") + M->B0H_TPBENE+M->B0H_TIPPRE+M->B0H_TPPRES+M->B0H_CODPRO + M->B0H_GRUOPE + M->B0H_TPPAG ))
	lRet := nRecAtu == B0H->(recno())
endif

if !lRet
	MsgAlert("Registro jแ cadastrado!")
endif
restarea(aArea)
return lRet
