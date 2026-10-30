#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA812.CH"
#INCLUDE "HEADERGD.CH"
#Include "fwmbrowse.ch"

#define Confirma 1
#define Redigita 2
#define Abandona 3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA812  ³ Autor ³ Luis Samaniego                  ³ Data ³ 09/05/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicion de Catalogos                                     			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA812()                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico ( DOS e Windows )                                 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³               ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS           ³         Motivo da Alteracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³MCamargo    ³04/09/17³ DMINA-176      ³Replica 12.1.17 Mod. func MontaColsF3I     ³±±
±±³    (MEX)   ³(12.117)³                ³para mostrar todos los registros de F3I,   ³±±
±±³            ³        ³                ³se uso tabla temp. en ValidF3I, se envia   ³±±
±±³            ³        ³                ³msj si no existe reg.  y se agrega msj de  ³±±
±±³            ³        ³                ³proceso al cargar registros de consulta.   ³±±
±±³  Marco A.  ³19/02/18³    DMINA-556   ³Se replican para V12.1.17, los issues:     ³±±
±±³            ³        ³                ³ DMINA-385, DMINA-602,  DMINA-723,         ³±±
±±³            ³        ³                ³ DMINA-814, DMINA-1171, DMINA-1223,        ³±±
±±³            ³        ³                ³ DMINA-1255, DMINA-1166 y DMINA-1093;      ³±±
±±³            ³        ³                ³ para Complemento de Pago - CFDI 3.3       ³±±
±±³  Marco A.  ³06/03/18³    DMINA-726   ³Se replican para V12.1.17, los issues:     ³±±
±±³            ³        ³                ³ DMINA-64, DMINA-445, DMINA-871, DMINA-817,³±±
±±³            ³        ³                ³ DMINA-1082 y DMINA-1337; para Esquema CFDI³±±
±±³            ³        ³                ³ 3.3 (MEX)                                 ³±±
±±³ Marco A.   ³25/04/18³   DMINA-1521   ³Replica de DMINA-1215, que consiste en so- ³±±
±±³            ³        ³                ³lucionar suma de doble descuento al generar³±±
±±³            ³        ³                ³factura a partir de un pedido de venta. MEX³±±
±±³M.Camargo   ³06/04/18³ DMINA-3465     ³En Func F812SXB se valida que la variable N³±±
±±³            ³        ³                ³__cLineOk y __nOpcx esten activas y se asig³±±
±±³            ³        ³                ³nan a las Varibles nResN, nRescLinOk y     ³±±
±±³            ³        ³                ³nResnOpcx . (MEX).                         ³±±
±±³Oscar Garcia³03/09/18³ DMINA-3912     ³En funcion ValidF3I se evita la eliminación³±±
±±³            ³        ³                ³de la tabla temporal TRBF3I, ya que al rea-³±±
±±³            ³        ³                ³lizar esto provocaba un errorlog.          ³±±
±±³LuisEnriquez³12/11/19³ DMINA-7694     ³En funcion ValidF3I se corrige el error.log³±±
±±³            ³        ³                ³presentado por execauto desde ws (MEX)     ³±±
±±³ARodriguez  ³19/08/21³DMINA-12690     ³Permite mantenimiento de Sxxx si es usuario³±±
±±³            ³        ³                ³del grupo administradores. (MEX)           ³±±
±±³            ³        ³                ³Filtro variable en consultas. (MEX)        ³±±
±±³            ³        ³                ³MontaColsF3I()->F812Tmp()->F812Filtro()    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA812()
	Local aArea     := GetArea()
	Local aAreaF3H  := F3H->(GetArea())
	Local oBrowse As Object
	Local nIndex As Numeric
	Local lOrderAsc As Logical

	Private cFiltraF3H   := ""	//Variavel para filtro
	Private aIndexF3H    := {}	//Variavel Para Filtro
	Private bFiltraBrw   := {|| Nil}	//Variavel para Filtro
	Private lF812Copy    := .F.
	Private lManutence   := (cPaisLoc$"MEX|COL|PAR" .And. FwIsAdmin())
	Private aRotina      := MenuDef()
	Private cCadastro    := OemToAnsi(STR0001) + IIf(lManutence,STR0066,"") //"DEFINICAO DE TABELAS"##" - ADMINISTRADOR"

	If F812ModComp("F3H")

		FISA814()

		dbSelectArea("F3H")
		F3H->(dbSetOrder(1)) // indice 1: F3H_FILIAL+F3H_CODIGO
		dbGotop()
		cFiltraF3H	:=	'F3H_ORDEM == "01"'

		If hasSmartX()
			nIndex := 1 //F3H_FILIAL+F3H_CODIGO
			lOrderAsc := .T.
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias("F3H")
			oBrowse:SetDescription(cCadastro)
			oBrowse:SetFilterDefault( "@F3H_ORDEM = '01'" )
			oBrowse:AddLegend("LEFT(F3H_CODIGO,1) <> 'S'"	,"read1",STR0009,,,"color-10"	) // Catalogo definido por el usuario
			oBrowse:AddLegend("LEFT(F3H_CODIGO,1) =  'S'"	,"read1",STR0008,,,"color-03"	) // Catalogo definido por Microsiga
			oBrowse:setSmartX(nIndex, lOrderAsc)
			oBrowse:Activate()
			oBrowse:Destroy()
			oBrowse := Nil
		Else
			bFiltraBrw 	:= {|| FilBrowse("F3H",@aIndexF3H,@cFiltraF3H) }
			Eval(bFiltraBrw)

			mBrowse(06,01,22,75,'F3H', , , , , , fUseCor(), , , ,)

			EndFilBrw("F3H",aIndexF3H)
		Endif
	Endif

	RestArea( aArea )
	RestArea( aAreaF3H)

Return Nil

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ F812Alt  ³ Autor ³ R.H - Natie           ³ Data ³ 13/06/02 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Alteracao da Estrutura do Parametro                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ ExpN1 := AxAltera(ExpC1,ExpN2,ExpN3,ExpA1,ExpA2)           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ ExpN1 = Opcao devolvida pela funcao                        ³±±
	±±³          ³ ExpC1 = Alias do arquivo                                   ³±±
	±±³          ³ ExpN2 = Numero do registro                                 ³±±
	±±³          ³ ExpN3 = Numero da opcao selecionada                        ³±±
	±±³          ³ ExpA1 = Array contendo campos a serem mostrados            ³±±
	±±³          ³ ExpA2 = Array limitando campos a serem aceitos com Get     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function F812Alt(cAlias, nReg, nOpcx, aAcho, aCpos, nColMens, cMensagem, cTudoOk, lEnable)
//-- Variaveis dimensoes do objeto tela
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aArea			:= GetArea()
	Local aAreaF3H		:= F3H->( GetArea() )
	Local a310nField	:= {}
	Local aColsRec		:= {}
	Local aSvCols		:= {}
	Local aKeys			:= GetKeys()
	Local cProxNum		:= GetMV('MV_F3HNUM')
	Local cCond			:= "", cChave:= ""
	Local cCodCpy		:= ""
	Local nOpca			:= 0
	Local oFont
	Local oDlgMain
	Local bSet15		:= { || NIL }
	Local bSet24		:= { || NIL }
	Local aButtons		:= {}
	Local nRecDel		:= 0
	Local cFilF3I		:= xFilial("F3I")

	Private cFilF3H		:= CriaVar("F3H_FILIAL")
	Private cCodigo		:= CriaVar("F3H_CODIGO")
	Private cDescF3H	:= CriaVar("F3H_DESC")
	Private nOpcao		:= nOpcx
	Private nCnt		:= 0
	Private lCancel		:= .F.
	Private oGeT
	Private oCodigo, oDescri
	Private oGroup1, oGroup2
	Private aColsBkp	:= {}
	Private nBkp		:= 0

	DEFAULT lEnable		:= .T.

	cFilF3H   := F3H->F3H_FILIAL
	cCodigo   := If( nOpcx = 3, cCodigo , F3H->F3H_CODIGO )
	cDescF3H  := If( nOpcx = 3, cDescF3H, F3H->F3H_DESC   )

	EndFilBrw("F3H",aIndexF3H,.T.)
	aIndexF3H	:= {}

	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 026 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

	Do while .T.

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Campos Nao editaveis                                              	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		a310nField	:= {"F3H_CODIGO","F3H_DESC"}

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica existencia de registro qdo for alteracao                     ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		dbSelectArea("F3H")
		dbSetOrder(1)
		dbSeek( cFilF3H+cCodigo )
		If !eof()
			cCodCpy := F3H->F3H_CODIGO
		EndIf
		While !eof() .and. cFilF3H + cCodigo = F3H->F3H_FILIAL+F3H->F3H_CODIGO
			nCnt++
			dbSkip()
		Enddo
	    If nCnt > 0  .And. nOpcx = 3 //--Quando Inclusao e existir Registro
			Help(" ",1,"A310REG")
			Exit
		ElseIf nCnt = 0 .And. nOpcx # 3 //--Quando Nao for Inclusao e nao existir Registro
			Help(" ",1,"A310NREG")
			Exit
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica origem Parametro. Nao permite alt. origem Sistema   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If ( nOpcx = 4 .or. nOpcx = 5 ) .and. !f812ChkUsr() .and. ( !lManutence ) .and. ( !lF812Copy )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Se for uma Parametro Definido Pela Microsiga Altera a Opcao  ³
			³ para Visualizacao											       ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			MsgInfo( OemToAnsi(STR0015) , OemToAnsi(STR0014) )
			nOpcx	:= 2
		ElseIf lF812Copy
			nOpcx := 3
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica se as variavel esta sendo utilizada no F3I                    ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !lManutence .And. !fUsePar(@nOpcx)
			Exit
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Proximo Numero sequencial do Codigo qdo inclusao                  	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If nOpcx == 3
			//-- Pegar e gravar o pr¢ximo numero
			If cProxNum  # Nil
				cProxNum1 := Soma1(cProxNum)
			Else
				Break
			EndIf
			IF !( lManutence )
				cCodigo	:=  cProxNum1
			EndIF
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Monta a entrada de dados do arquivo                          ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cCond	:= "F3H_FILIAL+F3H_CODIGO"
		If lF812Copy
			nOpcX := 4
			cChave := xFilial("F3H") + cCodCpy
		Else
			cChave	:= xFilial("F3H") + cCodigo
		EndIf

		aHeader	:= F812aHead(a310nField,cAlias) // Array contendo header
		aCols	:= F812aCols(a310nField, cAlias, cCond, cChave, nOpcx, @aColsRec) // Array contendo aCols
		aSvCols := aClone( aCols )

		If lF812Copy
			nOpcX := 3
		EndIf

		DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD

		SetaPilha()
		DEFINE MSDIALOG oDlgMain TITLE OemToAnsi( cCadastro ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

			@ aObjSize[1,1], aObjSize[1,2] GROUP oGroup1 TO aObjSize[1,3], (aObjSize[1,4]*0,69) LABEL OemToAnsi(STR0011) OF oDlgMain PIXEL //-"Cod.Tabela"
			oGroup1:oFont:= oFont
			@ aObjSize[1,1], ((aObjSize[1,2])*0,70) GROUP oGroup2 TO aObjSize[1,3], aObjSize[1,4] LABEL OemToAnsi(STR0012) OF oDlgMain PIXEL //-"Descriçäo"
			oGroup2:oFont:= oFont

			If ( lManutence ) .and. nOpcx == 3
				@ aObjSize[1,1]+10, aObjSize[1,2]+10 MSGET cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont PICTURE "@! S999" VALID If( !lCancel, F812Codigo( cCodigo ), .T. )
			Else
				@ aObjSize[1,1]+12, aObjSize[1,2]+10 SAY cCodigo SIZE 050,10 OF oDlgMain PIXEL FONT oFont
			EndIf
			If nOpcx == 3 .OR. nOpcx == 4 //Se inclusao ou alteração
				@ aObjSize[1,1]+10, aObjSize[1,2]+76	MSGET cDescF3H SIZE 120,09 OF oDlgMain PIXEL FONT oFont PICT "@!"
			Else
			 	@ aObjSize[1,1]+12, aObjSize[1,2]+76 SAY cDescF3H  SIZE 120,10 OF oDlgMain PIXEL FONT oFont
			EndIf

			oGet := MSGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpcX,"F812LinOk","F812TudOk","+F3H_ORDEM",If(nOpcx=2.Or.nOpcx=5,Nil,.T.),,,,,"F812CpoOk")
			bSet15 := { || nOpca := 1, If(oGet:TudoOk() .and. fVLdDesc(cDescF3H), oDlgMain:End(),nOpca:=0)}
			bSet24 := { || oDlgMain:End() }

		ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar(oDlgMain, bSet15 , bSet24 , Nil , aButtons ) CENTERED
		SetaPilha()

		IF nOpcA == Redigita
			Exit
		ElseIf nOpcA == Confirma
			If ( nOpcx == 3 .or. nOpcx == 4)
				Begin Transaction
					//--Gravacao
					F812Grava(cAlias, nOpcx, aColsRec, aSvCols)
					//--Processa Gatilhos
					EvalTrigger()
				End Transaction
				//-- Armazena ultimo numero  no SX6
				If nopcx == 3 .and. !( lManutence )
					PutMV('MV_F3HNUM',"U"+Substr(cCodigo,2))
				EndIf
			ElseIf nOpcx == 5
				If lManutence .And. !MsgYesNo(OemToAnsi(STR0067 + CRLF + CRLF + STR0068), OemToAnsi(STR0006))
					Exit
				EndIf

				Begin Transaction
					dbSelectArea( cAlias )
					dbGoto(nReg)
					nRecDel := 0
					While !Eof() .And. &cCond == cChave
						RecLock(cAlias,.F.,.T.)
						dbDelete()
						MsUnlock()
						nRecDel++
						DbSkip()
					EndDo
					If nRecDel > 0
						WRITESX2(cAlias,nRecDel)
					EndIf

					If lManutence
						dbSelectArea( "F3I" )
						dbSetOrder(1)
						nRecDel := 0
						If dbSeek( cFilF3I + cCodigo )
							While !Eof() .And. F3I->(F3I_FILIAL + F3I_CODIGO) == cFilF3I + cCodigo
								RecLock("F3I",.F.,.T.)
								dbDelete()
								MsUnlock()
								nRecDel++
								DbSkip()
							EndDo
							If nRecDel > 0
								WRITESX2("F3I",nRecDel)
							EndIf
						EndIf
					EndIf
				End Transaction
			Endif
		Endif
		Exit
	Enddo

	//--Restaura o Filtro de Browse
	Eval(bFiltraBrw)
	dbGoTo(nReg)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Restaura Area e Ordem de Entrada                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	lF812Copy	:= .F.
	RestArea( aArea )
	RestArea( aAreaF3H )
	RestKeys( aKeys,.T. )

Return(Nil)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812Codigo  ³ Autor ³ Mauricio T. Takakura³ Data ³ 31/01/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo Codigo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ F812Codigo                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function F812Codigo( cCodigo )
Local lRet := .T.

	lRet := NaoVazio() .and. ExistChav("F3H", cCodigo, 1) .and. FreeForUse( "F3H", cCodigo )

Return( lRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812Grava ³ Autor ³ Natie                 ³ Data ³ 27/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Parametros                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ F812Grava                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function F812Grava(cAlias,nOpcx,aColsRec, aSvCols)
Local ny        := 0
Local nX        := 0
Local nMaxArray := Len(aHeader)
Local aCampo    := {"F3H_CAMPOS"}
Local nOrdem    := 0
Local nTamVersao:= TamSx3("F3H_VERSAO")[1]

	nUsado := Len(aHeader)
	dbselectArea(cAlias)

	// Se alteração atualiza a descrição da tabela
	If nOpcx == 4
		For nX:=1 TO Len(aColsRec)
			F3H->( dbGoto(aColsRec[nX]) )
			F3H->( RecLock(cAlias,.F.,.T.) )
			F3H->F3H_DESC   := Upper(Alltrim(cDescF3H))
			F3H->( MsUnlock() )
		Next nX
	EndIf

	// Verifica se há necessidade de gravar os itens
	If fCompArray(aCols, aSvCols) .AND. !lF812Copy
		Return
	EndIf

	For nX:=1 TO Len(aCols)
		If nX <= Len(aColsRec) .and. nOpcx # 3
			//--Verifica se esta acols esta deletado
			F3H->( dbGoto(aColsRec[nX]) )
			F3H->( RecLock(cAlias,.F.,.T.) )
			If aCols[nX,nUsado+1]  # .F.
		        F3H->( DbDelete() )
		        Loop
			Endif
		Else
			If aCols[nX,nUsado+1]  = .F.
				F3H->( RecLock(cAlias,.T.,.T.) )
				F3H->F3H_FILIAL := xFilial(cAlias)
				F3H->F3H_CODIGO := cCodigo
				F3H->F3H_DESC   := Upper(Alltrim(cDescF3H))
			Else
				Loop
			Endif
		Endif
		nOrdem  ++
		For ny := 1 To nMaxArray
			cCampo    := Trim(aHeader[ny][2])
			If cCampo == "F3H_ORDEM"
				xConteudo	:= Strzero(nOrdem ,2) //-- Faz o Reordenacao da ordem  dos campos nos casos em  que haja delecao de algum  regitro na GetDados
			Else
				xConteudo := aCols[nX,ny]
			Endif
			If ( ASCAN(aCampo,{|x| x == cCampo }) ) > 0
				xConteudo := StrTran( aCols[nX,ny]," ","" ) //-- Nao permite gravar nome  campo com  espacos
			Endif

			If ( (ValType(&cCampo) == 'N') .AND. (ValType(aCols[nX,ny]) == 'C') )
				xConteudo	:= Val( aCols[nX,ny] )
			ElseIf ( (ValType(&cCampo) == 'C') .AND. (ValType(aCols[nX,ny]) == 'N') )
				xConteudo	:= AllTrim(Str(aCols[nX,ny]))
			EndIf
			&cCampo 	:= xConteudo
		Next ny

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Alterar a Versao da Tabela - Apenas em Manutencao Gpea300M    ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( lManutence )
			F3H->F3H_VERSAO := StrZero(Val(F3H->F3H_VERSAO)+1, nTamVersao)
		EndIF
		F3H->( MsUnlock() )
	Next nx

Return

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³F812Copy  ³ Autor ³Mauricio T. Takakura   ³ Data ³03/12/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Menu para copiar uma Tabela                                ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³F812Copy( cAlias , nReg , nOpc )                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³cAlias = Alias do arquivo                                   ³
³          ³nReg   = Numero do registro                                 ³
³          ³nOpc   = Numero da opcao selecionada                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA310()                                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function F812Copy( cAlias , nReg , nOpc )

	lF812Copy := .T.

Return( F812Alt( cAlias , nReg , 4 ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F812aHead ºAutor  ³Natie               º Data ³  17/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao F812aHead() - Monta o array de header - SRB         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F812aHead(aFields,cAlias)
	Local aExclui  := { 'F3H_CODIGO','F3H_DESC'} 	// Array de exclusao de campos

	Private aTELA[0][0],aGETS[0],aHeader[0],nUsado:=0

	aHeader := GdMontaHeader( NIL ,; //01 -> Por Referencia contera o numero de campos em Uso
	NIL ,; //02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
	NIL ,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
	"F3H" ,; //04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
	aExclui ,; //05 -> Opcional, Campos que nao Deverao constar no aHeader
	NIL ,; //06 -> Opcional, Carregar Todos os Campos
	.T. ,; //07 -> Nao Carrega os Campos Virtuais
	NIL ,; //08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
	NIL ,; //09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
	.T. ,; //10 -> Verifica se Deve Checar se o campo eh usado
	.T. ,; //11 -> Verifica se Deve Checar o nivel do usuario
	NIL ,; //12 -> Utiliza Numeracao na GhostCol
	.T. ) //13 -> Carrega os Campos de Usuario

	DbSelectArea( cAlias )
Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812aCols ³ Autor ³ Natie                 ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criar os Arrays do aCols dos arquivos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Gpea310                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F812aCols(aFields, cAlias, cCond, cChave, nOpcx, aColsRec)
Local nCntFor := 0
Local nAcols  := 0

Local aSX3      :={}
Local _i        := 0
Local cX3_NIVEL 
Local cX3_USADO
Local cX3_TIPO
Local cX3_TAMANHO
Local nUsado  := Len(aHeader)

	//--Quando for Inclusao criar com 1 elemento
	Private aCols
	If nOpcx = 3 //Inclusao
		nCnt := 1
		aCols := Array( nCnt , nUsado+1 )
	Else //Visualiza Altera
		aCols := {}
	Endif

	dbSelectArea(cAlias)

	If dbSeek(cCHAVE) .and. nOpcx # 3
		While !Eof() .And. &cCond == cChave
			aadd(aCols,Array(nUsado+If(nOpcx#1,1,0)))
			nAcols := Len(aCols)
			For nCntFor := 1 To Len(aHeader)
				If ( aHeader[nCntFor][10] != "V")
					aCols[nAcols][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					aCols[nAcols][nCntFor] := CriaVar(aHeader[nCntFor][2],.T.)
				EndIf
			Next nCntFor
			If nOpcx # 1
				aCols[nAcols][nUsado+1] := .F.
			EndIf
			dbSelectArea(cAlias)
			Aadd(aColsRec,Recno())
			dbSkip()
		EndDo
	Else
		nUsado:=0
		aSX3 := FWSX3Util():GetAllFields(cAlias , .T.)
		for _i := 1 to len(aSX3)
			If ASCAN(aFields,{ |x| x == Trim(aSX3[_i]) } ) == 0
				cX3_NIVEL := GetSx3Cache(aSX3[_i], "X3_NIVEL")
				cX3_USADO := GetSx3Cache(aSX3[_i], "X3_USADO")
				if cNivel >= cX3_NIVEL .And. X3Uso(cX3_USADO)
					cX3_TIPO := GetSx3Cache(aSX3[_i], "X3_TIPO")
					cX3_TAMANHO := GetSx3Cache(aSX3[_i], "X3_TAMANHO")
					nUsado ++
					IF cX3_TIPO == "C"
						aCOLS[1][nUsado] := SPACE(cX3_TAMANHO)
					ELSEIF cX3_TIPO == "N"
						aCOLS[1][nUsado] := 0
					ELSEIF cX3_TIPO == "D"
						aCOLS[1][nUsado] := CTOD("  /  /  ")
					ELSE
						aCOLS[1][nUsado] := .F.
					Endif
				EndIf
			EndIf
		next _i 
        aCOLS[1][nUsado+1] := .F.
	Endif

	aCols[1][GdFieldPos("F3H_ORDEM")] := '01' //-- Inicia Ordem com 1
	aColsBkp := Aclone(aCols)
	nBkp     := Len(aColsBkp)
Return aCols

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812CpoOk ³ Autor ³ Natie                 ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica cpo digitado                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function F812CpoOk(o)
Local lCpoOk     := .T.
Local cVar       := Alltrim(ReadVar())
Local aNaoValido := {"<",">","%",",","(","/","$","."} //Array caracteres nao validos para composicao do nome do campo
Local nY

	If cVar ="M->F3H_CAMPOS"
		For  nY:= 1 to Len(aNaoValido)
			If 	aNaovalido[nY] $  &cVar
				MsgAlert( OemToAnsi( STR0033 ) , OemToAnsi( STR0014 ) ) // caracter invalido na composicao no nome  do campo
				lCpoOk	:= .F.
			Endif
		Next
	Endif

Return lCpoOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812LinOk ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function F812LinOk(o)
Local nPosTam  := GdFieldPos("F3H_TAMAN")
Local nPosCpo  := GdFieldPos("F3H_CAMPOS")
Local nPosDesc := GdFieldPos("F3H_DESCPO")
Local nUsado   := Len(aHeader)
Local lLinOk   := .T.
Local nTeste   := aScan(aCols,{|X| X[nPosDesc] == aCols[n][nPosDesc]})

	If  !( aCols[n,nUsado+1] )
		If ValType( aCols[n][nPosCpo] ) == 'N'
			aCols[n][nPosCpo]	:=	AllTrim(Str(aCols[n][nPosCpo]))
		EndIf
		If (IIF(Valtype(aCols[n][nPosCpo]) == "C", Empty(aCols[n][nPosCpo]), aCols[n][nPosCpo] == 0);
			 .or. IIF(ValType(aCols[n][nPosTam]) == "N", aCols[n][nPosTam] == 0 , Empty(aCols[n][nPosTam])) )
			If ( Empty(aCols[n][nPosCpo]) )
				MsgAlert( oEmtoAnsi(STR0031),oEmToAnsi(STR0014) ) //--"Nome,tipo e tamanho do campo devem ser informados"
				lLinOk	:= .F.
			Else
				MsgAlert( oEmtoAnsi(STR0016),oEmToAnsi(STR0014) ) //-- "O campo Tamanho deve ter valor maior que zero"
				lLinOk	:= .F.
			EndIf
		Else
			If nTeste <> n
				MsgAlert( oEmtoAnsi(STR0054),oEmToAnsi(STR0014) ) //--"A descrição do campo não pode ser repetida."
				lLinOk	:= .F.
			Endif
		EndIf
		fAtualizaBkp1()
	Else
		DbSelectArea("F3I")
		DbSetOrder(1)
		DbSeek( xFilial("F3H") + cCodigo, .F.)
		If ( F3I->( !Eof() ) ) .and. ( n <= nCnt)
			Help(" ",1,"A310DEL") // "Existem Registros desta Tabela sendo utilizados." ## "Exclua todos os registros na Manutenção Tabela"
			If !lManutence
				lLinOK := .F.
			EndIf
		EndIf
		fAtualizaBkp1()
	Endif
	oGet:oBrowse:nAt := n
	oGet:oBrowse:Refresh(.T.)

Return lLinOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812TudOk ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linhas digitadas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function F812TudOk(o)
Local aString     := {}
Local bBlock      := ErrorBlock(),bErro := ErrorBlock( { |e| ChecErro(e) } )
Local cTipoVar
Local cString
Local cForm
Local lTudoOk     := .T.
Local nLin
Local nX          := 0
Local nTam        := 0
Local nUsado      := Len(AHEADER)
Local nPosCpo     := GdFieldPos("F3H_CAMPOS")
Local nPosPesq    := GdFieldPos("F3H_PESQ")
Local nPosValid
Local nPosTipo
Local nPosTam
Local nPosFun     := 0
Local uValor
Local lTpBusca    := .F.

	Begin  Sequence

		For nLin := 1 To Len(aCols)
			If aCols[nLin,nUsado+1]  = .T.
				Loop
			Endif
			cString := ""
			cString += cCodigo+aCols[nLin,nPosCpo]
			If Len(cString) > 0
				Aadd( aString,cString )
			Endif
			If nPosPesq > 0 .And. aCols[nLin,nPosPesq] == "1"
				lTpBusca := .T.
			Endif
		Next
	    If nPosPesq > 0 .And. !lTpBusca
			lTudoOk := .F.
			Alert(STR0056) //-"Deve existir pelo menos um campo 'Usado Pesq ?' preenchido como 'Sim' !!!"
			Break
		Endif

		ASORT(aString)
		cString := ""
		//-- verifica se ha chave duplicada
		For nLin := 1 To Len(aString)
			If cString = aString[nLin]
				lTudoOk := .F.
				Help(" ",1,"A310CHADUP") //-- Chave duplicada
				Break
			Endif
			cString := aString[nLin]
		Next

		//-- Valida o conteudo do Campo F3H_VALIDA - Validacao
		nPosValid := GdFieldPos( "F3H_VALID" )
		nPosTipo  := GdFieldPos( "F3H_TIPO" )
		nPosTam   := GdFieldPos( "F3H_TAMAN" )

		For nLin := 1 To Len(aCols)
			If nPosValid > 0
				cForm 	  := AllTrim(aCols[nLin, nPosValid])
			EndIf
			nPosForm := 0

			//-- Verifica se existe fc valida no repositorio
			If  !Empty( cForm )
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Declarar a variavel do campo, para validacoes do Campo Valid  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				cTipoVar := AllTrim(aCols[nLin, nPosTipo])
				If cTipoVar == "C"
					uValor := "A"
				ElseIf cTipoVar == "N"
					uValor := 1
				ElseIf cTipoVar == "D"
					uValor := CTOD("01/01/2000")
				ElseIf cTipoVar == "L"
					uValor := .T.
				EndIf

				// Atribui o primeiro valor do conjunto para a função PERTENCE()
				If "PERTENCE(" $ cForm
					nPosFun :=	At("PERTENCE(", cForm) + 10
					uValor := Substr(cForm,nPosFun,1)
	                // Inclui campo como segundo parâmetro
					For nX := nPosFun To Len(cForm)
						If Substr(cForm, nX,1) == ")"
							// Quantidade de caracteres a serem eliminados.
							nTam := Len(AllTrim(aCols[nLin, nPosCpo])) + 6 // Os 6 a mais são ", " , "M->" e ")"
							// Substitui conteúdo
							cForm := STUFF(cForm, nX, nTam ,", " + "M->" + AllTrim(aCols[nLin, nPosCpo]) + ")"  )
							Exit
						EndIf
					Next nX
				EndIf
			    If "NAOVAZIO" $ cForm
			    	cForm := STRTRAN(cForm, "NAOVAZIO()", "NAOVAZIO(" + "M->" + AllTrim(aCols[nLin, nPosCpo]) + ")"  )
			    EndIf

				&("M->" + AllTrim(aCols[nLin, nPosCpo])) := uValor
				lTudoOk := CheckExecForm( cForm, .T. )

				If !lTudoOk
					Break
				EndIf
			EndIF
	    Next nLin

	End Sequence

Return lTudoOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fUseCor   ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda de cores                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fUsecor()
Local aMarks := {}

	aMarks	:=	{{ "Substr(F3H->F3H_CODIGO,1,1)=='U'" , "BR_VERDE"	} ,;
				 { "Substr(F3H->F3H_CODIGO,1,1)=='S'" , "BR_AZUL"	} }

Return( aClone( aMarks ) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812Leg   ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda de Cores                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function F812Leg()
Local aLegenda	:= {}

	aLegenda := { { "BR_AZUL"  , OemToAnsi( STR0008 ) } ,; //"Formula Definida Pela Microsiga"
	              { "BR_VERDE" , OemToAnsi( STR0009 ) } }  ; //"Formula Definida Pelo Usuario"

	BrwLegenda(	cCadastro ,	oEmToAnsi(STR0010) , aLegenda ) //Legenda do Cadastro de Paramentros

Return( NIL )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³f812ChkUsr³ Autor ³ R.H. -  Natie         ³ Data ³ 23/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega as variaveis p/cadastro de Parametros              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ f812ChkUsr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function f812ChkUsr()
	Local lUsuario := If(Substr(cCodigo,1,1) = "U",.T.,.F.)
Return lUsuario

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812ChkTaman ³ Autor ³ Natie              ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nao permite que tamanho F3H_CONTEU ultrapase tamanho de 250 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function F812ChkTaman(nCampo)
Local nx
Local nMaxField	:= 250
Local nTamField	:= 0
Local nUsado 		:= Len(aHeader)
Local nPosTam		:= GdFieldPos("F3H_TAMAN")
Local nPosTipo	:= GdFieldPos("F3H_TIPO")
Local nPosDec 	:= GdFieldPos("F3H_DECIMA")

	//-- Valida tipo e tamanho do campo data
	If !( ValType(nCampo) == 'N' )
		nCampo	:= Val(nCampo)
	EndIf
	If aCols[n][nPosTipo]="D" .and. ;
		nCampo  # 8
		MsgInfo( oEmToAnsi(STR0028) , oEmToAnsi(STR0014) )
		aCols[n][nPostam]	:= 8
		aCols[n][nPosdec]	:= 0
		Return .F.
	Endif

	//-- Valida tamanho dos campos que serao armazenados no F3I_CONTEU
	nAcols:= If( Len(Acols)= 1 ,1, len(aCols)-1 )
	For nx:= 1 to naCols
		If aCols[nx][nUsado+1]=.F. .and. (aCols[nx] # aCols[n])
			nTamField 	+=  aCols[nx][nPosTam]
		Endif
	Next nx
	nTamField	+= nCampo //-- Somatoria do tamanho dos campos
	If  nTamField > nMaxField
		//--"Tamanho m ximo de 250 excedido"
		MsgAlert( oEmToAnsi(STR0018),oEmToAnsi(STR0014) )
		Return .F.
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f812ChkDec³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica Campo Decimal                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function f812ChkDec(nDecimal)
Local nPosTipo	:= GdFieldPos("F3H_TIPO")
Local lCpoOk	:= .T.

	If	aCols[n][nPosTipo]	$"DC" .and.  nDecimal > 0 //-- Tipo data e caracter nao devem possuir casa decimal
		MsgAlert( oEmToAnsi(STR0017),oEmToAnsi(STR0014) )
		lCpoOk	:= .F.
	Endif

Return lCpoOK

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f812ChkTipo Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function  f812ChkTipo(cTipo)
Local nPosTam	:= GdFieldPos("F3H_TAMAN")
Local nPosDec 	:= GdFieldPos("F3H_DECIMA")

	If 	cTipo == "D"
		aCols[n][nPostam]	:= 8
		aCols[n][nPosdec]	:= 0
	ElseIf cTipo == "C"
		aCols[n][nPosdec]	:= 0
	EndIf

RETURN .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fUsePar   ³ Autor ³ Natie                 ³ Data ³ 01/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia de tabela utilizando o parametro     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static function fUsePar(nOpcx)
Local aArea     := GetArea()
Local aAreaF3H  := F3H->( GetArea() )
Local lRet      := .T.	//#Variavel de retorno

	DbSelectArea("F3I")
	dbSetOrder(1)
	DbSeek(xFilial("F3I")+ cCodigo)
	If !eof() .and. nOpcx = 5
		//# "Exclusão negada. existe um ou mais lançamentos fixos para esta tabela."
		MsgAlert(oEmToAnsi(STR0048),oEmToAnsi(STR0014))
		lRet := .F.
	Endif
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Restaura Area e Ordem de Entrada                              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RestArea( aArea )
	RestArea( aAreaF3H)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f812VerChav| Autor ³                      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar campo chave                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function  f812VerChav(cAlias,cAuxChave)
Local nPosCpo    := GdFieldPos("F3H_CAMPOS")
Local aString    := {}
Local nLin       := 0
Local cString    := ""
Local nUsado     := Len(aheader)
Local lChaveOk   := .T.

	For nLin := 1 To Len(aCols)
		If aCols[nLin,nUsado+1]  = .T.
			Loop
		Endif
		cString += cCodigo + aCols[nLin,nPosCpo]
		If Len(cString) > 0 //-- compara o campo digitado com  o armazenado no aCols
			Aadd(aString,cString)
		Endif
		cString := ""
	Next

	If Len(aString) > 0 .and.  ;
	   ( Ascan(aString,{|x|cCodigo + cAuxChave == x } ) )  > 0
		Help(" ",1,"A310CHADUP")
		lChaveOk	:= .F.
	Endif

Return lChaveOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F812ModComp  | Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar campo chave                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gpea310                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function F812ModComp(cAlias)
Local lComp := (FWModeAccess(cAlias, 3) == "C")

	IF !lComp
		//"O Modo de Acesso ser COMPARTILHADO."
		MsgInfo( oEmToAnsi( STR0029 ) + CRLF + oEmToAnsi( STR0030 ) )
	EndIF

Return( lComp )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³f812ConsPad³Autor ³ Natie                 ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Seleciona alias na Consulta Padrao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function f812ConsPad( )

	Help(,,"812ConsPad", ,STR0069, 1, 0)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fVLdDesc  ³ Autor ³ Natie                 ³ Data ³ 17/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Campo Descricao da Tabela                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function  fVLdDesc(cDescF3H)

	If Empty(cDescF3H)
		MsgAlert( oemToAnsi(STR0034) ) //"Digite o nome da tabela"
		Return(.F.)
	Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			F U N C O E S    U T I L I Z A D A S    P O R    S X 3
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function F812Valid()
Local cCampo 	:= Substr(ReadVar(),4)
Local lRet		:= .T.

	If (cCampo == "F3H_TIPO") .Or. (cCampo == "F3H_TAMAN") .Or. (cCampo == "F3H_DECIMA")
		DbSelectArea("F3I")
		DbSetOrder(1)
		DbSeek( xFilial("F3H") + cCodigo, .F.)
		If ( F3I->( !Eof() ) ) .and. ( n <= nCnt)
			Help(" ",1,"A310DEL") // "Existem Registros desta Tabela sendo utilizados." ## "Exclua todos os registros na Manutenção Tabela"
			If lManutence
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fAtualizaBkp1  ³ Autor: Kelly Soares     ³ Data ³ 30.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza a array de bkp dp aCols.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fAtualizaBkp1()
Local nX

	If nBkp < Len(aCols)
		aAdd(aColsBkp , Array(len(aCols[n])))
		For nX := 1 to len(aCols[n])
			aColsBkp[n,nX] := aCols[n,nX]
		Next nX
		nBkp ++
	Endif
Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³07/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA310                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

	Local aRotina := { { STR0002   , 'PesqBrw'   , 0 , 1,,.F.},; //'Pesquisar'
	                   { STR0003   , 'F812Alt'   , 0 , 2},; //'Visualizar'
	                   { STR0004   , 'F812Alt'   , 0 , 3},; //'Incluir'
	                   { STR0005   , 'F812Alt'   , 0 , 4},; //'Alterar'
	                   { STR0006   , 'F812Alt'   , 0 , 5},; //'Excluir'
	                   { STR0035   , 'F812Copy'  , 0 , 6},; //'Copiar'
	                   { STR0007   , 'F812Leg'   , 0 , 7, ,.F.} } //'Legenda'

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F812SXB  º Autor ³ Ademar Fernandes   º Data ³  29/10/08             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe Tela de Pesquisa de tabelas do F3I                             º±±
±±º          ³                                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta Padrao Especifica - SXB                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F812SXB( cTabela, cCpoRet, cFiltro )
	Local aArea			:= GetArea()
	Local nOpca			:= 0, i,lAllOk
	Local oDlg, cCampo, nX, nY, cCaption, cPict, cValid, cF3, cWhen, nLargSay, oSay, oGet
	Local cBlkGet,cBlkWhen,cBlkVld, oSaveGetdad := Nil, aSvRot := Nil
	Local oTop
	Local aObject		:= {}
	Local aSize			:= {}
	Local nObject
	Local aCordW		:= {125,0,400,635}
	Local cSvField		:= IIF("M->"$ReadVar(),&(ReadVar()),"")
	Local nCount		:= 0
	Local cMyCpo		:= ""	// Al compilar indica como no usada... no quitar!
	Local cLineOk		:= "AllwaysTrue()"
	Local cAllOk		:= "AllwaysTrue()"
	Local nOpcx			:= 7
	Local aCGD			:= {}
	Local lExist		:= .F.
	Local nCpoRet		:= 0
	Local cPesq			:= Space(30)
	Local nCntCmb		:= 0
	Local nMaxCmb		:= 5 //# Nr.Maximo de opcoes no Combo
	Local nPos			:= At("+", cCpoRet )
	Local cCpoAux		:= ""
	Local cF3HCampo		:= ""
	Local cF3HDescr		:= ""
	Local nResN			:= IIF(IsMemVar('N'), N, 0)
	Local nRescLinOk	:= IIF(IsMemVar("__cLineOk"), __cLineOk, 0)
	Local nResnOpcx		:= IIF(IsMemVar('__nOpcx'), __nOpcx, 0)
	Local nCmbLin       := 0
	Local nPosCpo       := 0

	Private cCombo		:= ""
	Private aCombo		:= {}
	Private aMyCombo	:= {}
	Private aSXBCols	:= {}
	Private aSXBHeader	:= {}
	Private nUsado		:= 0
	Private cFilF3H		:= ""
	Private cFilF3I		:= ""
	Private cDescF3I	:= ""
	Private lPesqComp	:= .F. //Variavel que indica se a pesquisa esta sendo feita com mais de um campo
	Private cReadVar	:= Alltrim(ReadVar()) // Se usa en la función F812ChkCampo() ya que se pierde al ejecutar MontaColsF3I() por CodeBlock
	Default cFiltro		:= ""

	If cTabela == NIL .Or. cCpoRet == NIL
		MsgAlert(OemToAnsi(STR0049),OemToAnsi(STR0014)) // "Não é possível continuar pois faltam parametros nesta função !!!"##"Atenção !"
		N := nResN
		__cLineOk := nRescLinOk
		__nOpcx := nResnOpcx
		Return(.F.)
	EndIf

	If nPos > 0
		lPesqComp := .T.
	EndIf

	//# Posiciona no F3H
	dbSelectArea("F3H")
	dbSetOrder(1)
	If !dbSeek(xFilial("F3H")+cTabela,.F.)
		MsgAlert(OemToAnsi(STR0050),OemToAnsi(STR0014)) // "A Tabela informada não existe !!!"##"Atenção !"
		N := nResN
		__cLineOk := nRescLinOk
		__nOpcx := nResnOpcx
		Return(.F.)
	EndIf

	cFilF3H  := xFilial("F3H")
	cDescF3I := Alltrim(F3H_DESC)
	//# Posiciona no F3I
	dbSelectArea("F3I")
	dbSetOrder(1)
	If !ExistR812Tab(cTabela) //!dbSeek(xFilial("F3I")+cTabela,.F.)
		MsgAlert(OemToAnsi(STR0051),OemToAnsi(STR0014)) // "Não existe informações cadastradas para Tabela !!!"##"Atenção !"
		N := nResN
		__cLineOk := nRescLinOk
		__nOpcx := nResnOpcx
		Return(.F.)
	EndIf

	cFilF3I := xFilial("F3I")
	fMontHeadF3I( cTabela, cCpoRet )
	Processa( {|| MontaColsF3I( cTabela, cCpoRet, , cFiltro )}, STR0014, STR0062, .F. )//"Cargando catálogo de Prod/Serv SAT.."	"¡Atención!"

	//# Variaveis inicializadas no teste
	Private cTitulo := cTabela+" - "+cDescF3I //#"U014 - Teste"
	Private nMax := Len(aSXBCols)
	Private aC := {}
	Private aColsBkp := aClone(aSXBCols)

	//# Variaveis inicializadas no teste
	aAdd(aC,{"cMyCpo", {15,001},"",,,,.F.,})

	nCount++
	__cLineOk := cLineOK
	__nOpcx   := nOpcx
	If nCount > 1
		oSaveGetdad := oGetDad812
		oSaveGetdad:oBrowse:lDisablePaint := .t.
	EndIf

	oGets := {}
	If Type("aRotina") == "A"
		aSvRot := aClone(aRotina)
	EndIf

	aRotina := {}
	For nX := 1 to nOpcX
		AADD(aRotina,{"","",0,nOpcx})
	Next

	aCGD:=Iif(Len(aCGD)==0,{34,5,128,315},aCGD)

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd

	If Len(aC) > 0
		//# Monta o Combo a partir do Titulo do F3H
		dbSelectArea("F3H")
		dbSeek(xFilial("F3H")+cTabela,.F.)
		While !Eof() .And. F3H->(F3H_FILIAL+F3H_CODIGO) == (cFilF3H+cTabela)
			//# Verifica se o campo ja existe
			If !lExist .And. ValType("F3H->F3H_PESQ")<>"U"
				lExist := .T.
			EndIf
			//# Monta o aCombo e aMyCombo
			If !lExist .Or. (lExist .And. F3H->F3H_PESQ=="1")
				nCntCmb += 1
				If nCntCmb == 1
					cCombo := Alltrim(Capital(F3H_DESCPO))
				EndIf
				aAdd( aCombo, Alltrim(Capital(F3H_DESCPO)) )
				aAdd( aMyCombo, {Alltrim(Capital(F3H_DESCPO)),Alltrim(F3H_CAMPOS)} )
				If lPesqComp .And. At(Alltrim(F3H_CAMPOS), cCpoRet) > 0
					cF3HDescr += Alltrim(Substr(Capital(F3H_DESCPO),1,9)) + '+'
					cF3HCampo += Alltrim(F3H_CAMPOS) + '+'
				Endif
				If nCntCmb >= nMaxCmb
					Exit
				EndIf
			EndIf
			dbSkip()
		EndDo

		If lPesqComp
			cF3HDescr := Substr(cF3HDescr, 1, Len(cF3HDescr)-1)
			cF3HCampo := Substr(cF3HCampo, 1, Len(cF3HCampo)-1)
			nCntCmb += 1
			aAdd( aCombo, Alltrim(cF3HDescr) )
			aAdd( aMyCombo, {Alltrim(cF3HDescr),Alltrim(cF3HCampo)} )
		Endif

		//Ordena por primer opción de filtrado
		If !Empty(cCombo)
			nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )
			nPosCpo := GdFieldPos(aMyCombo[nCmbLin,02],aSXBHEADER)
			If nPosCpo > 0
				CursorWait()
				ASort(@aSXBCols,,,{|x,y| x[nPosCpo] < y[nPosCpo]})
				CursorArrow()
			EndIf
		EndIf

		dbSelectArea("F3I")

		@ 000,000 SCROLLBOX oTop
		Aadd(aSize,aCGD[1]+13)
		Aadd(aObject,oTop)
		nObject := 2

		Private oCombo, oPesq, oBtn1, oCheckBox, lCheck

		@ 005,005 SAY OemToAnsi(STR0052) SIZE 35,07 OF oTop PIXEL // "Pesquisar por: "
		@ 005,045 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 080,013 OF oTop PIXEL
		oCombo:bChange := {||F812Ord()}
		@ 005,130 MSGET oPesq VAR cPesq PICTURE "@!" VALID Iif(!Empty(cCombo),Pesq812Dad(cPesq),f812ValPesq()) SIZE 80,10 OF oTop PIXEL
		@ 013,420 BTNBMP oBtn1 RESOURCE "btpesq" SIZE 025,025 OF oTop PIXEL ACTION ( Pesq812Dad(cPesq) )

		For i:=1 to Len(aC)
			cCampo:=aC[i,1]
			nX:=aC[i,2,1]-13
			nY:=aC[i,2,2]
			cCaption:=Iif(Empty(aC[i,3])," ",aC[i,3])
			cPict:=Iif(Empty(aC[i,4]),Nil,aC[i,4])
			cValid:=Iif(Empty(aC[i,5]),".t.",aC[i,5])
			cF3:=Iif(Empty(aC[i,6]),NIL,aC[i,6])
			cWhen    := Iif(aC[i,7]==NIL,".t.",Iif(aC[i,7],".t.",".f."))
			cWhen    := Iif(!(Str(nOpcx,1,0)$"346"),".f.",cWhen)
			cBlKSay  := "{|| OemToAnsi('"+cCaption+"')}"
			oSay     := TSay():New( nX+1, nY, &cBlkSay,oTop,,, .F., .F., .F., .T.,,,,, .F., .F., .F., .F., .F. )
			nLargSay := GetTextWidth(0,cCaption) / 1.8// estava 2.2
			cCaption := oSay:cCaption
			cBlkGet  := "{ | u | If( PCount() == 0, "+cCampo+","+cCampo+":= u ) }"
			cBlKVld  := "{|| "+cValid+"}"
			cBlKWhen := "{|| "+cWhen+"}"
			oGet := TGet():New( nX, nY+nLargSay,&cBlKGet,oTop,,,cPict, &(cBlkVld),,,, .F.,, .T.,, .F., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,(cCampo))
			AADD(oGets,oGet)
		Next
	EndIf

	oGetDad812 := MsNewGetDados():New(aCGD[1],;// nTop
	aCGD[2],; // nLelft
	aCGD[3],; // nBottom
	aCGD[4],; // nRright
	nOPCX,; // controle do que podera ser realizado na GetDado - nstyle
	"SXB812M2LOk()",; // funcao para validar a edicao da linha - ulinhaOK
	"AllwaysTrue()",; // funcao para validar todas os registros da GetDados - uTudoOK
	NIL,; // cIniCPOS
	NIL,; // aAlter
	0,; // nfreeze
	nMax,; // nMax
	NIL,; // cFieldOK
	NIL,; // usuperdel
	.F.,; // udelOK
	@oDlg,; // objeto de dialogo - oWnd
	@aSXBHeader,; // Vetor com Colunas - AparHeader
	@aSXBCols) // Vetor com Header - AparCols

	Aadd(aObject,oGetDad812:oBrowse)
	Aadd(aSize,NIL)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,lAllOk:=__812M2Ok(cAllOk),Iif(lAllOk,oDlg:End(),nOpca:=0)},{||oDlg:End()},,),;
		AlignObject(oDlg,aObject,1,nObject,aSize),oGetDad812:oBrowse:Refresh())

	nCount--
	If nCount > 0
		oGetDad812 := oSaveGetDad
		oGetDad812:oBrowse:lDisablePaint := .f.
	EndIf
	If ValType(aSvRot) == "A"
		aRotina := aClone(aSvRot)
	EndIf

	If nOpca == 1 .and. Len(aSXBCols)>0
		If !lPesqComp
			nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
			VAR_IXB  := aSXBCols[oGetDad812:nAt,nCpoRet]
		Else
			VAR_IXB := ""
			While lPesqComp
				cCpoAux := Substr(cCpoRet, 1, nPos - 1)
				cCpoRet := Substr(cCpoRet, nPos +1)
				nCpoRet := GdFieldPos(cCpoAux, aSXBHeader)
				VAR_IXB += aSXBCols[oGetDad812:nAt,nCpoRet]
				nPos := At("+", cCpoRet )
				lPesqComp := If (nPos > 0, .T., .F.)
				If nPos == 0
					nCpoRet := GdFieldPos(cCpoRet, aSXBHeader)
					VAR_IXB += aSXBCols[oGetDad812:nAt,nCpoRet]
				Endif
			EndDo
		Endif
	Else
		VAR_IXB := cSvField
		RestArea(aArea)
		N := nResN
		__cLineOk := nRescLinOk
		__nOpcx := nResnOpcx
		Return .T.
	EndIf

	RestArea( aArea )
	N := nResN
	__cLineOk := nRescLinOk
	__nOpcx := nResnOpcx

Return(nOpca == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  31/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ordena o aCols de acordo com o ComboBox escolhido pelo usu-º±±
±±º          ³ ario, isso se o CheckBos for marcado                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ F812SXB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F812Ord()
	Local nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )
	Local nPosCpo := 0
	Local lCheck  := .T.
	CursorWait()
	nPosCpo := GdFieldPos(aMyCombo[nCmbLin,02],aSXBHEADER)
	If lCheck
		ASort(@aSXBCols,,,{|x,y| x[nPosCpo] < y[nPosCpo]})
		oGetDad812:aCols := aClone(aSXBCols)
	Else
		aSXBCols := aClone(aColsBkp)
	EndIf
	CursorArrow()
	oGetDad812:oBrowse:Refresh()

Return


Function SXB812M2LOk()
	Local lRet:=.t. , ni

	If Str(__nOpcx,1,0)$"346"
		lRet := &__cLineOK
		For ni:= 1 to Len(oGets)
			oGets[ni]:Refresh()
		Next
	EndIf

Return lRet


Function __812M2Ok(cAllOK)
	Local lRet

	lRet := SXB812M2LOk()
	If lRet
		lRet := &cAllOk
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  30/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta o aHeader da Tela de Pesquisa de tabelas do F3I      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ F812SXB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fMontHeadF3I(cTabela, cPesqComp)
	Local aArea   := GetArea()
	Local nQtdCol := 99
	Local nTamAux := 0

	Default cPesqComp := ""

	dbSelectArea("F3H")
	nUsado:=0
	aSXBHeader:={}

	//# Cria campo F3I_SEQUEN
	nUsado += 1
	aAdd(aSXBHeader,{ "Seq", ; //# 01
	"F3I_SEQUEN", ; //# 02
	"@!", ; //# 03
	3, ; //# 04
	0, ; //# 05
	NIL, ; //# 06
	NIL, ; //# 07
	"C", ; //# 08
	NIL,  ; //# 09
	"R" } ) //# 10 Real ou Virtual

	While !Eof() .And. F3H->(F3H_FILIAL+F3H_CODIGO) == (cFilF3H+cTabela)
		//Alltrim(F3H_VALID), ; //# 06
		If nUsado > nQtdCol
			Exit
		Else
			nUsado += 1
			aAdd(aSXBHeader,{Alltrim(Capital(F3H_DESCPO)), ; //# 01
			Alltrim(F3H_CAMPOS), ; //# 02
			Alltrim(F3H_PICTUR), ; //# 03
			F3H_TAMAN, ; //# 04
			F3H_DECIMA, ; //# 05
			NIL, ; //# 06
			NIL, ; //# 07
			F3H_TIPO, ; //# 08
			NIL, ; //# 09
			"R", ; //# 10 Real ou Virtual
			NIL, ; //# 11 cbox
			NIL, ; //# 12 relacao
			NIL, ; //# 13 when
			"V" } ) //# 14 visual ou altera
			If lPesqComp .And. At(Alltrim(F3H_CAMPOS), cPesqComp) > 0
				nTamAux += F3H_TAMAN
			Endif
		Endif
		dbSkip()
	EndDo

	If lPesqComp
		nUsado += 1
		aAdd(aSXBHeader,{Alltrim(Capital(F3H_DESCPO)), ; //# 01
		Alltrim(cPesqComp), ; //# 02
		"!@", 				; //# 03
		nTamAux, ; //# 04
		NIL, ; //# 05
		NIL, ; //# 06
		NIL, ; //# 07
		NIL, ; //# 08
		NIL, ; //# 09
		"V", ; //# 10 Real ou Virtual
		NIL, ; //# 11 cbox
		NIL, ; //# 12 relacao
		NIL, ; //# 13 when
		"V" } ) //# 14 visual ou altera
	Endif

	RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  30/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta o aCols da Tela de Pesquisa de tabelas do F3I        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ F812SXB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontaColsF3I( cTabela, cCpoPesq, cCpoFiltro, cFiltro )
	Local aArea			:= GetArea()
	Local nCnt			:= 0
	Local nQtdLin		:= 0
	Local uValor
	Local nCpoAux1		:= 1
	Local nCpoAux2		:= 0
	Local cTrb			:= ""
	Local lTrb			:= .F.

	Default cCpoPesq	:= ""
	Default cCpoFiltro	:= ""
	Default cFiltro		:= ""

	aSize(aSXBCols, 0)
	nCont := 0
	nCpo1 := 1
	nCpo2 := 0

	If !Empty( cCpoFiltro ) .And. !Empty( cFiltro )
		For nCnt := 1 to Len(aSXBHeader)
			If Alltrim(aSXBHeader[nCnt,02]) != "F3I_SEQUEN"
				nCpoAux2 := (aSXBHeader[nCnt,04] )
				If Alltrim(aSXBHeader[nCnt,02]) == cCpoFiltro
					Exit
				Else
					nCpoAux1 += nCpoAux2
				Endif
			Endif
		Next nCnt
	Endif

	If cPaisLoc == "MEX" .And. cTabela $ "S004|S013|S015|S023|S024" .And. !Empty(F812ChkCampo())
		cTrb := F812Tmp(cTabela)	// "S004" Código postal, "S015" Colonia, "S023" Localidad, "S024" Municipio
		lTrb := .T.
		dbSelectArea( cTrb )
		Count To nQtdLin
		dbGotop()

	Else
		nQtdLin := F812ConF3I(cTabela)
		dbSelectArea( "F3I" )
		F3I->(dbSetOrder(1))
		F3I->( dbSeek( xFilial( "F3I" ) + cTabela ) )
		cTrb := "F3I"

	EndIf

	ProcRegua(nQtdLin)

	While ! Eof() .And. F3I_FILIAL+F3I_CODIGO == ( cFilF3I + cTabela )
		If Empty( cFiltro ) .Or. Eval( cFiltro )
			AADD(aSXBCols,Array(Len(aSXBHeader)+1))
			For nCnt := 1 To Len(aSXBHeader)
				cCampo := Alltrim(aSXBHeader[nCnt,02])
				If aSXBHeader[nCnt,10] == "R" .And. cCampo == "F3I_SEQUEN"
					aSXBCols[Len(aSXBCols)][nCnt] := FieldGet(FieldPos(cCampo))
				ElseIf lPesqComp .And. At("+", cCampo) > 0
					aSXBCols[Len(aSXBCols)][nCnt] := cCpoPesq //cCpoAux
				Else
					nCpo2 := (aSXBHeader[nCnt,04] )
					If aSXBHeader[nCnt,08] == "N"
						uValor := Val( SubStr(F3I_CONTEU,nCpo1,nCpo2) )
					ElseIf aSXBHeader[nCnt,08] == "D"
						uValor := Ctod( SubStr(F3I_CONTEU,nCpo1,nCpo2) )
					Else
						uValor := SubStr(F3I_CONTEU,nCpo1,nCpo2)
					EndIf
					aSXBCols[Len(aSXBCols)][nCnt] := uValor
					nCpo1 += nCpo2
				EndIf
			Next nCnt
			aSXBCols[Len(aSXBCols)][nUsado+1] := .F.
			nCont += 1
			IncProc(STR0062 + alltrim(str(nCont)) + STR0063 + alltrim(str(nQtdLin))) //"Cargando catálogo de Prod/Serv SAT.." "de"
			If nCont > nQtdLin
				Exit
			EndIf
			nCpo1 := 1
		Endif
		dbSkip()
	EndDo

	If lTrb
		(cTrb)->(dbCloseArea())
	EndIf

	RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          º Autor ³ Ademar Fernandes   º Data ³  31/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Localiza a informacao digitada pelo usuario na Tela de Pes-º±±
±±º          ³ quisa de tabelas do F3I                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ F812SXB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pesq812Dad(cPesq)
	Local nPosLin := 0
	Local nPosCpo := 0
	Local nLenCmb := Len(Alltrim(cPesq))
	Local nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )

	nPosCpo := GdFieldPos(aMyCombo[nCmbLin,02],aSXBHeader)

	IF nPosCpo > 0
		nPosLin := aScan( aSXBCols, { |x| SubStr(Alltrim(UPPER(x[nPosCpo])),1,nLenCmb) == Alltrim(cPesq)} )
	endif
	If nPosLin >= 1
		oGetDad812:oBrowse:nAt := nPosLin
		n:= nPosLin
	EndIf
	oGetDad812:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f812ValPesqºAutor  ³ IP-RH Inovacao     º Data ³  21/10/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apresenta mensagem de alerta quando nao existir campo pra  º±±
±±º          ³ pesquisa na tabela auxiliar.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function f812ValPesq()

	Alert(STR0055) //-"O campo de pesquisa 'Busca por:' não pode ser vazio !!!"

Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ExistReg ºAutor  ³ Adrianne Furtado   º Data ³ 17/11/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existem registros validos na consulta para essaº±±
±±º          ³ filial                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ExistR812Tab(cCodTab)
	Local lRet     := .F.
	Local cFOrigem := ""

	If __READVAR == "M->CODFOR" //CONSULTA F3 A PARTIR DE UMA TABELA SNNN
		cFOrigem := aCols[n][1]
	Else
		cFOrigem := xFilial("F3H")
	EndIf

	F3I->(dbSetOrder(1))
	If F3I->(dbSeek(xFilial("F3I")+cCodTab))
		lRet := .T.
	EndIf
	F3I->(DbGoTop())
	F3I->(dbSeek(xFilial("F3I")+cCodTab))

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidF3I  ºAutor  ³Silvia Taguti       º Data ³  17/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica codigo no Cadastro de Tabelas                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValidF3I(cCodigo,cConteudo,nPos1,nPos2)
	Local aArea		:= GetArea()
	Local cTrb		:= GetNextAlias()
	Local lGetDB	:= AllTrim(Upper(TCGetDB())) == "ORACLE"
	Local cQry		:= ""
	Local lRet		:= .F.

	Default nPos1	:= 1
	Default nPos2	:= Len(cConteudo)

	If cCodigo <> Nil .And. cConteudo <> Nil
		cQry := " SELECT F3I_CODIGO,F3I_SEQUEN,F3I_CONTEU "
		cQry += " FROM " + RetsqlName("F3I") + " F3I "
		cQry += " WHERE F3I_FILIAL = '" + xFilial("F3I") + "' "
		cQry += " AND F3I_CODIGO = '" + cCodigo + "' "
		If  lGetDB //Es Oracle
			cQry += " AND TRIM(TO_CHAR(SUBSTR(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + "))) = '" + Alltrim(cConteudo) + "'"
		Else
			cQry += " AND SUBSTRING(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ") = '" + Alltrim(cConteudo) + "'"
		EndIf
		cQry += " AND F3I.D_E_L_E_T_='' "

		cQry := ChangeQuery(cQry)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQry ), cTrb, .T., .F.)

		dbSelectArea(cTrb)
		(cTrb)->(dbGoTop())

		While (cTrb)->(!Eof())
			If Alltrim(Substr((cTrb)->F3I_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
				lRet := .T.
				Exit
			EndIf
			(cTrb)->(dBSkip())
		EndDo

		(cTrb)->(dbCloseArea())

		If !lRet
			If AllTrim(substr(ReadVar(), 4, len(ReadVar()))) $ "F1_RELSAT|F2_RELSAT" .AND. Empty(cConteudo)
				lRet := .T.
			Else
				MsgAlert( OemToAnsi(STR0064) + Alltrim(cCodigo),OemToAnsi(STR0014) ) //"El valor no existe en catálogo: " "¡Atención!"
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return (lRet)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ F812ConF3I ³ Autor ³ Luis Enriquez         ³ Data ³ 08.08.17 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Obtiene cantidad de resgistros existentes de acuerdo a codigo³±±
	±±³          ³ de tabla (MEXICO)                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ F812ConF3I(cCodigo)                                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ cCodigo .- Código de tabla                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ nTotReg .- Cant. de regitros existentes para codigo de tabla ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ FISA812                                                      ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F812ConF3I(cCodigo)
	Local cTRB := ""
	Local cQry := ""
	Local nTotReg := 0

	cQry := " SELECT COUNT(F3I_CODIGO) REGS "
	cQry += " FROM " + RetsqlName("F3I") + " F3I "
	cQry += " WHERE F3I_FILIAL = '" + xFilial("F3I") + "' "
	cQry += " AND F3I_CODIGO = '" + cCodigo + "' "
	cQry += " AND F3I.D_E_L_E_T_='' "
	cQry += " GROUP BY F3I_CODIGO "

	cTRB := ChangeQuery(cQry)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRB ) ,"TRBF3IC", .T., .F.)

	DbSelectArea("TRBF3IC")
	TRBF3IC->(dbGoTop())

	While TRBF3IC->(!Eof())
		nTotReg := TRBF3IC->REGS
		TRBF3IC->(dBSkip())
	EndDo

	TRBF3IC->(dbCloseArea())
Return nTotReg

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ ObtColSAT  ³ Autor ³ Luis Enriquez         ³ Data ³ 27.10.17 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Obtiene valor de mantenimiento de tablas del SAT de acuerdo  ³±±
	±±³          ³ a posición de busqueda y de valor a buscar. (MEXICO)         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ ObtColSAT(cCodigo,cConteudo,nPos1,nPos2,nPos1Ret,nPos2Ret)   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ cCodigo .- Código de tabla                                   ³±±
	±±³          ³ cConteudo .- Valor de busqueda                               ³±±
	±±³          ³ nPos1 .- Posición inicial de valor a buscar                  ³±±
	±±³          ³ nPos2 .- Posición final de valor a buscar                    ³±±
	±±³          ³ nPos1Ret .- Posición inicial de valor a retornar             ³±±
	±±³          ³ nPos2Ret .- Posición inicial de valor a retornar             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ cValor .- Valor texto de acuerdo a valor de busqueda         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ FATSMEX.INI, FATEMEX.INI                                     ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ObtColSAT(cCodigo,cConteudo,nPos1,nPos2,nPos1Ret,nPos2Ret)
	Local aArea		:= GetArea()
	Local cTrb		:= GetNextAlias()
	Local lGetDB	:= AllTrim(Upper(TCGetDB())) == "ORACLE"  //.T. - Oracle, .F. - Otros manejadores
	Local cQry		:= ""
	Local cValor	:= ""

	Default nPos1	:= 1
	Default nPos2	:= Len(cConteudo)

	If cCodigo <> Nil .And. cConteudo <> Nil
		cQry := " SELECT F3I_CODIGO,F3I_SEQUEN,F3I_CONTEU "
		cQry += " FROM " + RetsqlName("F3I") + " F3I "
		cQry += " WHERE F3I_FILIAL = '" + xFilial("F3I") + "' "
		cQry += " AND F3I_CODIGO = '" + cCodigo + "' "
		If  lGetDB //Es Oracle
			cQry += " AND TRIM(TO_CHAR(SUBSTR(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + "))) = '" + Alltrim(cConteudo) + "'"
		Else
			cQry += " AND SUBSTRING(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ") = '" + Alltrim(cConteudo) + "'"
		EndIf
		cQry += " AND F3I.D_E_L_E_T_='' "

		cQry := ChangeQuery(cQry)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQry ) ,cTrb, .T., .F.)

		dbSelectArea( cTrb )
		(cTrb)->(dbGoTop())

		While (cTrb)->(!Eof())
			If Alltrim(Substr((cTrb)->F3I_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
				cValor := Alltrim(Substr((cTrb)->F3I_CONTEU,nPos1Ret,nPos2Ret))
				Exit
			EndIf
			(cTrb)->(dBSkip())
		EndDo

		(cTrb)->(dbCloseArea())
	EndIf

	RestArea( aArea )

Return (cValor)

/*/{Protheus.doc} F812ChkCampo
Informa el campo a usar para filtro de consulta a catálogos del SAT - México
Funciona para las tablas DA4, SA4, A1Y, A1Z y AE0
@type function
@version 1.0
@author arodriguez
@since 20/8/2021
@param nResp, numeric, Indica que campo regresar; 1-Estado (default) o 2-C.P.
@return cRet, variant, Valor del campo
/*/
Static Function F812ChkCampo(nResp)
	Local cCampo	:= cReadVar
	Local cKey1		:= ""
	Local cKey2		:= ""
	Local cRet		:= ""
	Local oModel    := Nil
	Local oModelDet := Nil
	Local lMVC      := .F.
	Local cLlave    := ""

	Default nResp	:= 1

	If cCampo $ "M->DA4_CEP|M->DA4_CODBAI|M->DA4_LOCAL|M->DA4_CODMUN"
		cKey1 := "M->DA4_EST"
		cKey2 := IIf(cCampo == "M->DA4_CODBAI", "M->DA4_CEP", "")
	ElseIf cCampo $ "M->A4_CEP|M->A4_CBAIRRO|M->A4_CLOCALI|M->A4_COD_MUN"
		cKey1 := "M->A4_EST"
		cKey2 := IIf(cCampo == "M->A4_CBAIRRO", "M->A4_CEP", "")
	ElseIf cCampo $ "M->A1Y_CPORI|M->A1Y_COLORI|M->A1Y_LOCORI|M->A1Y_MUNORI"
		cKey1 := "A1Y_EDOORI"
		cKey2 := IIf(cCampo == "M->A1Y_COLORI", "A1Y_CPORI", "")
		oModel := FWModelActivate()
		oModelDet := oModel:GetModel('A1YDETAIL')
		lMVC := .T.
	ElseIf cCampo $ "M->A1Y_CPDES|M->A1Y_COLDES|M->A1Y_LOCDES|M->A1Y_MUNDES"
		cKey1 := "A1Y_EDODES"
		cKey2 := IIf(cCampo == "M->A1Y_COLDES", "A1Y_CPDES", "")
		oModel := FWModelActivate()
		oModelDet := oModel:GetModel('A1YDETAIL')
		lMVC := .T.
	ElseIf cCampo $ "M->A1Z_CP|M->A1Z_COLON|M->A1Z_LOCAL|M->A1Z_MUNIC"
		cKey1 := "M->A1Z_ESTADO"
		cKey2 := IIf(cCampo == "M->A1Z_COLON", "M->A1Z_CP", "")
	ElseIf cCampo $ "M->AE0_CP|M->AE0_COLON|M->AE0_LOCAL|M->AE0_MUNIC"
		cKey1 := "M->AE0_ESTADO"
		cKey2 := IIf(cCampo == "M->AE0_COLON", "M->AE0_CP", "")
	ElseIf cCampo $ "M->F2_USOCFDI|M->F1_USOCFDI"
		cKey1 := "AI0->AI0_REGFIS"
		cLlave := IIf(cCampo == "M->F1_USOCFDI",M->F1_FORNECE + M->F1_LOJA,M->F2_CLIENTE + M->F2_LOJA)
		dbSelectArea("AI0")
		AI0->(dbSetOrder(1)) //AI0_FILIAL+AI0_CODCLI+AI0_LOJA
		AI0->(MsSeek(xFilial("AI0") + cLlave))
	EndIf

	If nResp == 1

		If !Empty(cKey1) .And. Valtype(cKey1) == "C"
			If lMVC
				cRet := oModelDet:GetValue(cKey1)
			Else
				cRet := &(cKey1)
			EndIf
		EndIf
	Else
		If !Empty(cKey2) .And. Valtype(cKey2) == "C"
			If lMVC
				cRet := oModelDet:GetValue(cKey2)
			Else
				cRet := &(cKey2)
			EndIf
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} F812Tmp
Crea Query con filtro especial por Estado o C.P. para catálogos del SAT - México
@type function
@version 1.0
@author arodriguez
@since 20/8/2021
@param cTabela, character, Código de catálogo a consultar
@return cTrb, variant, Nombre de tabla temporal con query a F3I
/*/
Static Function F812Tmp(cTabela)
	Local cTrb		:= GetNextAlias()
	Local cKey		:= F812ChkCampo(IIf(cTabela=="S015",2,1))
	Local cFiltro	:= ""

	If cTabela == "S015" // Colonia
		If !Empty(cKey)
			// Filtra colonias del C.P. definido
			cFiltro := F812Filtro(cTabela, "CP", cKey)
		Else
			//Filtro de C.P. del Rango 00000 al 99999
			cFiltro := F812Filtro(cTabela, "CP", "00000", "99999")
		EndIf
	ElseIf cTabela == "S013" // Uso CFDI
		cFiltro := F812Filtro(cTabela, "Regimen", cKey,"",.T.)
	Else // "S004" Código postal, "S023" Localidad, "S024" Municipio
		cFiltro := F812Filtro(cTabela, "Estado", cKey)

	EndIf

	BeginSql alias cTrb
		SELECT *
		FROM %table:F3I% F3I
		WHERE F3I.F3I_FILIAL = %xFilial:F3I% AND F3I.F3I_CODIGO = %exp:cTabela% AND %exp:cFiltro% AND F3I.%notDel%
		ORDER BY F3I.F3I_SEQUEN
	EndSql

Return cTrb

/*/{Protheus.doc} F812Filtro
Crea expresión para Query a catálogos de SAT - México
@type function
@version 1.0
@author arodriguez
@since 20/8/2021
@param cTabela, character, Código de catálogo
@param cCampo, character, Campo para el filtro
@param cKey1, character, Valor inicial o único de filtro
@param cKey2, character, Valor final de filtro
@param cFiltro, variant, expresión para complementar WHERE
/*/
Static Function F812Filtro(cTabela, cCampo, cKey1, cKey2, llike)
	Local nPosTab	:= 0
	Local nPos1		:= 1
	Local nPos2		:= 0
	Local nFor		:= 0
	Local cFiltro	:= ""
	Local cFilF3H	:= xFilial("F3H")
	Local lGetDB	:= AllTrim(Upper(TCGetDB())) == "ORACLE"
	Local cCond     := ""

	Static aTabF3H	:= {}

	Default cKey2	:= ""
	Default llike   := .F.

	nPosTab := aScan( aTabF3H , { |x| x[1] == cTabela } )

	If nPosTab == 0
		aAdd( aTabF3H, { cTabela , {} } )
		nPosTab := Len(aTabF3H)

		F3H->( dbSeek( cFilF3H + cTabela, .T.) )
		While F3H->( !Eof() .And. F3H_FILIAL + F3H_CODIGO == cFilF3H + cTabela )
			F3H->( aAdd( aTabF3H[nPosTab,2], { Upper(Trim(F3H_CAMPOS)), F3H_TIPO, F3H_TAMAN, F3H_DECIMA } ) )
			F3H->( dbSkip() )
		End While
	EndIf

	cCampo := Upper(cCampo)

	For nFor := 1 to Len(aTabF3H[nPosTab,2])
		If aTabF3H[nPosTab,2,nFor,1] == cCampo
			nPos2 := aTabF3H[nPosTab,2,nFor,3]
			Exit
		Else
			nPos1 += aTabF3H[nPosTab,2,nFor,3]
		EndIf
	Next

	If nPos2 > 0
		If Empty(cKey2)
			If llike
				cCond := IIf(lGetDB,"TRIM(TO_CHAR(SUBSTR(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ")))","SUBSTRING(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ")")
				cFiltro := "%" + cCond + " LIKE '%" + Alltrim(Substr(cKey1,1,nPos2)) + "%' %"
			Else
				IF lGetDB
					cFiltro := "%" + "TRIM(TO_CHAR(SUBSTR(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + "))) = '" + Alltrim(Substr(cKey1,1,nPos2)) + "' %"
				ELSE
					cFiltro := "%" + "SUBSTRING(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ") = '" + Alltrim(Substr(cKey1,1,nPos2)) + "' %"
				ENDIF
			EndIf
		Else
			IF lGetDB
				cFiltro := "%" + "TRIM(TO_CHAR(SUBSTR(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + "))) BETWEEN '" + Alltrim(Substr(cKey1,1,nPos2)) + "' AND '" + Alltrim(cKey2) +"' %"
			ELSE
				cFiltro := "%" + "SUBSTRING(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ") BETWEEN '" + Alltrim(Substr(cKey1,1,nPos2)) + "' AND '" + Alltrim(cKey2) +"' %"
			ENDIF
		EndIf
	Else
		cFiltro := "% 1=1 %"
	EndIf

Return cFiltro
