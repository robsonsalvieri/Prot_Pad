#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "QIPA020.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"

// Constantes do aviso
#Define QIPA020_PROG    "QIPA020"       // Chave do programa no FWProfile
#Define QIPA020_TASK    "AVSNOVA020"    // Chave da task (max 10 chars!)
#Define QIPA020_DIAS    7               // Dias para suprimir o aviso

/*/{Protheus.doc} QIPA020AuxClass
Classe agrupadora de métodos auxiliares do QIPA020
@author rafael.kleestadt
@since 13/05/2026
@version P12
/*/
CLASS QIPA020AuxClass FROM LongNameClass

    METHOD new() Constructor

	METHOD verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx()
	METHOD exibeAvisoSubstituicaoPorSmartx()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author rafael.kleestadt
@since 13/05/2026
@version P12
/*/
METHOD new() CLASS QIPA020AuxClass
Return Self


/*/{Protheus.doc} QIPA020
Programa de atualização de Ensaios 
@type  Function
@author Cleber Souza
@since 25/05/2004
@version P12
@return true, logical, indica sucesso da operação
/*/
Function QIPA020()

    Local oQIPA020Aux := Nil

	Private aRotina   := MenuDef()          // Array contendo as Rotinas a executar do programa
    Private cCadastro := OemtoAnsi(STR0006) // "Ensaios"
    Private lDuplDoc  := .T.                // Variavel para controle de documento duplicado
    
    If GetRPORelease() < '12.1.2710'

        oQIPA020Aux := QIPA020AuxClass():New()
        oQIPA020Aux:verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx()

    EndIf

    //Endereça a função de BROWSE
    mBrowse( 6, 1,22,75,"QP1")


Return .T.

/*/{Protheus.doc} MenuDef
Define Array contendo as Rotinas a executar do programa
@type  Static Function
@author Cleber Souza
@since 25/05/2004
@version P12
/*/
Static Function MenuDef()

// ----------- Elementos contidos por dimensao ------------	 
// 1. Nome a aparecer no cabecalho
// 2. Nome da Rotina associada
// 3. Usado pela rotina
// 4. Tipo de Transa‡„o a ser efetuada
//	 1 - Pesquisa e Posiciona em um Banco de Dados
//	 2 - Simplesmente Mostra os Campos
//	 3 - Inclui registros no Bancos de Dados
//	 4 - Altera o registro corrente
//	 5 - Remove o registro corrente do Banco de Dados
Local aRotina := {{OemToAnsi(STR0001),"AxPesqui",    0, 1,,.F.},; //"Pesquisar"         
                  {OemToAnsi(STR0002),"QP020ENSAIO", 0, 2},;      //"Visualizar"         
                  {OemToAnsi(STR0003),"QP020ENSAIO", 0, 3},;      //"Incluir"       
                  {OemToAnsi(STR0004),"QP020ENSAIO", 0, 4},;      //"Alterar" 
                  {OemToAnsi(STR0005),"QP020ENSAIO", 0, 5 , 3}}   //"Excluir"
                        
Return aRotina

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP020ENSAIO³ Autor ³ Cleber Souza         ³ Data ³ 25/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Ensaios - Delecao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qip020Dens(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP020ENSAIO(cAlias,nReg,nOpc) 

Local oDlg
Local oEnsaio
Local oFont1
Local oFont2 
Local oGroup1
Local oGroup2 
Local oTexto         
Local oPanel1   := NIL
Local oSize

Local aHeadAux   := {}
Local aColsAux   := {} 
Local aAltera    := {}  
Local lcont      := .F.

Private oGetNC

Private nPosNC   := 0
Private nPosCla  := 0
Private nPosDNC  := 0
Private nPosDCl  := 0  
Private nOpcA    := 0
Private cTexto   := ""
Private lDuplDoc := .T.

Private aGets    := {}
Private aTela    := {}   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa se existem lançamentos para o ensaio antes da exclusão.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5 .and. QP020Alt() 
    HELP(" ",1,"A020DENSPR",,QP7->QP7_PRODUT+' - '+QP7->QP7_REVI,3,1)
    Return 
EndIF  

// Validar se pode alterar ou excluir ensaio
If nOpc==4 
    If ExistBlock("QP020AENS") 
        lcont := Execblock("QP020AENS",.F.,.F.) // PE para Permitir a alteração do Ensaio mesmo existindo medições
    Endif
    if !lCont
        DbSelectArea("QPR")
        QPR->(dbSetOrder(2))
        If QPR->(dbSeek(xFilial("QPR")+QP1->QP1_ENSAIO))
            Help(" ",1,"A020ENSMED")   // "Ensaio apresenta medicoes cadastradas"
            Return
        EndIf
    EndIf
Endif

RegToMemory(cAlias,If(nOpc==3,.T.,.F.),.F.)            

QP020LOADNC(@aHeadAux,@aColsAux,nOpc,@aAltera)  

If !Empty(QP1->QP1_CHAVE) .and. nOpc<>3
    cTexto := QA_RecTxt( QP1->QP1_CHAVE, "QIPA020 " )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE" ,  100, 150, .T., .F., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "MULTIGET" ,  100, 20, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro ;  //"Cadastro Ensaios"
                        FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
                        
DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panel Primario                                         ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                  
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,oSize:aWindSize[4],oSize:aWindSize[3])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a Enchoice                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnsaio:=MsMGet():New( cAlias, nReg, nOpc,,,,,;
     {oSize:GetDimension("ENCHOICE","LININI"),;
     oSize:GetDimension("ENCHOICE","COLINI"),;
     oSize:GetDimension("ENCHOICE","LINEND"),;
     oSize:GetDimension("ENCHOICE","COLEND")};
    ,aAltera,,,,,oPanel1,,.T.,,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta TGroup                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGroup1:= TGroup():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
                        oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND"),STR0007,oPanel1,,,.T.)
oGroup1:oFont:= oFont1

oGroup2:= TGroup():New(oSize:GetDimension("MULTIGET","LININI"),oSize:GetDimension("MULTIGET","COLINI"),;
                        oSize:GetDimension("MULTIGET","LINEND"),oSize:GetDimension("MULTIGET","COLEND"),STR0008,oPanel1,,,.T.)
oGroup2:oFont:= oFont1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetNC:= MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI")+7,oSize:GetDimension("GETDADOS","COLINI")+3 ,oSize:GetDimension("GETDADOS","LINEND")-3,oSize:GetDimension("GETDADOS","COLEND")-3,;
                                Iif(nOpc==3 .Or. nOpc==4, GD_INSERT+GD_DELETE+GD_UPDATE, 0),"QP020LOk","QP020TOk","",,,,,,,oGroup1,aHeadAux,aColsAux)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta MultiGet                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTexto := TMultiGet():New(oSize:GetDimension("MULTIGET","LININI")+7,oSize:GetDimension("MULTIGET","COLINI")+3,{|u| if(Pcount()>0,cTexto:=u,cTexto)} ,oGroup2,;
                          oSize:GetDimension("MULTIGET","XSIZE")-6,oSize:GetDimension("MULTIGET","YSIZE")-11,,,,,,.T.,,,,,,IIf( nOpc==4 .Or. nOpc==3,.F.,.T.),,,,,.T.) 

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela).AND. QP020TOK(nOpc),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| nOpcA:=0,oDlg:End()}) CENTERED

If nOpcA==1 .and. nOpc<>2
    QP020GrvAll(nOpc)
EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP020LOADNC ºAutor  ³Cleber Souza      º Data ³  25/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que carrega o aHeader e aCols da GetDados.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIPA020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP020LOADNC(aHeadAux,aColsAux,nOpc,aAltera)

Local nIteCol := 0   
Local cCampos := "QP1_TPCART,QP1_CARTA,QP1_TIPO"
Local aStruAlias := FWFormStruct(3, "QP1")[3]
Local nX
//Verifica se campo nao podem ser alterados
For nX := 1 To Len(aStruAlias)
	If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") 
		 If QP020Alt() .and. nOpc == 4
            If !(Alltrim(aStruAlias[nX,1] ) $(cCampos))
                AADD(aAltera,aStruAlias[nX,1] )
            EndIF
        Else
            AADD(aAltera,aStruAlias[nX,1] )
        EndIF
	EndIf
Next nX
         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeadAux a ser utilizado na getdados             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadAux := APBuildHeader("QP2")

// Inclui coluna de registro atraves de funcao generica
ADHeadRec("QP2",aHeadAux)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a posicao dos campos no aHeadAux p/ posterior consistencia  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosNC  := Ascan(aHeadAux,{|x| x[2] == "QP2_NAOCON"})
nPosCla := Ascan(aHeadAux,{|x| x[2] == "QP2_CLASSE"})
nPosDNC := Ascan(aHeadAux,{|x| x[2] == "QP2_DESNCO"})
nPosDCl := Ascan(aHeadAux,{|x| x[2] == "QP2_DESCLA"})
nPosAli := Ascan(aHeadAux,{|x| x[2] == "QP2_ALI_WT"})
nPosRec := Ascan(aHeadAux,{|x| x[2] == "QP2_REC_WT"})

If nOpc <> 3
    dbSelectArea("QP2")
    dbSeek( xFilial("QP2")+QP1->QP1_ENSAIO )
    While !EOF() .And. QP2_FILIAL+QP2_ENSAIO == xFilial("QP2")+QP1->QP1_ENSAIO
        Aadd(aColsAux,Array(Len(aHeadAux)+1))
        For nIteCol:=1 to Len(aHeadAux)
            If aHeadAux[nIteCol,10] # "V"
                aColsAux[Len(aColsAux),nIteCol] := &("QP2->"+aHeadAux[nIteCol,2])
            Else
                If !(aHeadAux[nIteCol,2] $ "QP2_ALI_WT | QP2_REC_WT")
                    If aHeadAux[nIteCol,2] == "QP2_DESNCO"
                        aColsAux[Len(aColsAux),nIteCol] := QipxDNCo(QP2->QP2_NAOCON)
                    ElseIf aHeadAux[nIteCol,2] == "QP2_DESCLA"
                        aColsAux[Len(aColsAux),nIteCol] := A010DCla(QP2->QP2_CLASSE)
                    Else
                        aColsAux[Len(aColsAux),nIteCol] := CriaVar(AllTrim(aHeadAux[nIteCol,2]))
                    EndIf
                EndIf
            Endif
        Next nIteCol
        If nPosAli > 0 .and. nPosRec > 0
            aColsAux[Len(aColsAux),nPosAli] := Alias()
            If IsHeadRec(aHeadAux[nPosRec,2])
                aColsAux[Len(aColsAux),nPosRec] := QP2->(RecNo())
            EndIf
        Endif
        aColsAux[Len(aColsAux),Len(aHeadAux)+1] := .F. 
        dbSelectArea("QP2")
        dbSkip()
    Enddo
EndIf
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta vetor aColsAux com um elemento em branco p/ inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aColsAux) == 0
    Aadd(aColsAux,Array(Len(aHeadAux)+1))
    For nIteCol = 1 To Len(aHeadAux)
        If aHeadAux[nIteCol,8] == "C"
            aColsAux[1,nIteCol] := Space(aHeadAux[nIteCol,4])
        ElseIf aHeadAux[nIteCol,8] == "N"
            aColsAux[1,nIteCol] := 0
        ElseIf aHeadAuxr[nIteCol,8] == "D"
            aColsAux[1,nIteCol] := dDataBase
        ElseIf aHeadAux[nIteCol,8] == "M"
            aColsAux[1,nIteCol] := ""
        EndIf
    Next nIteCol
    aColsAux[1,Len(aHeadAux)+1] := .F.
EndIf

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP020LOk  ³ Autor ³ Cleber Souza          ³ Data ³ 25/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta' Ok                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP020LOk(nOpc)

Local lRet     := .T.
Local nAchou   := 0
Local aCols    := oGetNC:aCols 
Local n        := oGetNC:nAT
Local cProcura := aCols[n,nPosNC]
Local nDel     := Len(oGetNC:aHeader)+1

                      
If !(aCols[n,nDel])
    IF !EMPTY(acols[n,nPosNc]) .or. !EMPTY(acols[n,nposcla])
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Verifica se campo NC esta' preenchido                       ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If Empty(aCols[n,nPosNC])
            Help(" ",1,"QA_CPOOBR")
            lRet:=.F.   
        EndIf
    
        If lRet
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Verifica se a NC ja' existe                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            nAchou := Ascan(aCols,{|x| x[nPosNC] == cProcura .And. !(x[Len(aCols[n])])})
            If nAchou > 0 .And. nAchou # n
                Help(" ",1,"A020EXINCE")
                lRet:=.F.
            EndIf
        EndIf
    
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Verifica se a NC esta' cadastrada               ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lRet
            If ! ExistCpo("SAG",aCols[n,nPosNC])
                aCols[n,nPosNC] := Space(TamSX3("QP9_NAOCON")[1])
                lRet := .f.
            EndIf
        EndIf
    
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Verifica se a Classe da NC esta' cadastrada     ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If lRet
            If ! ExistCpo("QEE",aCols[n,nPosCla])
                lRet := .f.
            EndIf
        EndIf
    Endif
    
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP020TOk  ³ Autor ³ Cleber Souza          ³ Data ³ 25/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se toda a getdados esta' Ok                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP020TOk(nOpc)
Local nI, lRet := .t.    
Local aCols    := oGetNC:aCols
Local lRetok   := .T.

For nI := 1 to Len(aCols)
    If ! QP020LOk(nOpc)
        lRet := .f.
        Exit
    EndIf
Next     
If lRet .AND. EMPTY(M->QP1_CARTA)
    messagedlg(STR0009,,3)//"o campo carta deverá ser preenchido"
    lRet:=.f.   
Endif
If lRet .AND. M->QP1_TPCART == "D" .AND. M->QP1_CARTA == "TXT"
    MessageDlg(STR0010,,3)//"Não é possivel escolher para Ensaios dimensionais cartas do Tipo Texto."
    lRet:=.f.   
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada TUDO OK para validação        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
    If ExistBlock("QP020TDOK")
       lRetok := ExecBlock("QP020TDOK", .F., .F. ,{nOpc})
       If ValType(lRetok) == "L"
             lRet := lRetok
       EndIf
    EndIf    
EndIf 

Return(lRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QP020GrvAll ºAutor  ³Cleber Souza      º Data ³  25/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de gravação dos Ensaios, Não Conformidade e Metodo. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QIPA020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QP020GrvAll(nOpc)       

Local nX      := 0 
Local nY      := 0
Local cVar    := ""
Local nDel    := Len(oGetNC:aHeader)+1
Local aCols   := oGetNC:aCols
Local aHeader := oGetNC:aHeader  
Local cChave  := "" 
Local aTexto  := {}
Local aStruAlias := FWFormStruct(3, "QP1")[3]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os dados referentes ao Ensaio                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("QP1",If(nOpc==3,.T.,.F.))

If (nOpc == 3 .Or. nOpc == 4) //Inclusao ou Alteracao
	For nX := 1 To Len(aStruAlias)
		If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") <> "V"
			FieldPut(FieldPos(AllTrim(aStruAlias[nX,1])),&("M->"+aStruAlias[nX,1]))	
		EndIf
	Next nX
EndIf

If (nOpc == 3) //Inclusao
    QP1->QP1_FILIAL := xFilial("QP1")
    QP1->QP1_CADR   := cUserName
    QP1->QP1_DTCAD  := dDataBase
EndIf

MsUnLock() 
FKCOMMIT()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Nao Conformidades Relacionadas ao Ensaio               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo QP2        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(oGetNC:aCols)
    If !Empty(aCols[nX,nPosNC]) // Cod. NC nao vazio
        If !Acols[nX,nDel] .and. (nOpc==3 .or. nOpc==4)// Nao esta deletado 
            dbSelectArea("QP2")
            dbSetOrder(1)
            If dbSeek(xFilial("QP2") + QP1->QP1_ENSAIO + aCols[nX,nPosNC])         
                RecLock("QP2",.F.)   // Lock
            Else
                RecLock("QP2",.T.)   // Append
                QP2->QP2_FILIAL := xFilial("QP2")
                QP2->QP2_ENSAIO := QP1->QP1_ENSAIO
            Endif
            For nY := 1 to Len(aHeader)
                If aHeader[ny,10] # "V"
                    cVar := Trim(aHeader[ny,2])
                    Replace &cVar. With aCols[nx,ny]
                Endif
            Next nY
        Else
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Cancela a NC no QP2                   ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            dbSelectArea("QP2")
            dbSetOrder(1)
            If dbSeek(xFilial("QP2") + QP1->QP1_ENSAIO + aCols[nX,nPosNC])         
                RecLock("QP2",.F.)
                dbDelete()
            EndIf
        EndIf
        MsUnlock()
        FKCOMMIT()
    EndIf
Next nX        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Metodo Informado.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpc==3 .or. nOpc==4
    AADD(aTexto,{1,cTexto})
    If !Empty(cTexto)
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Gera/Obtem a chave ligacao com o Texto do Ensaio ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If Empty(QP1->QP1_CHAVE)
            cChave := QA_CvKey(xFilial("QP1")+QP1_ENSAIO,"QP1",2)
            // Grava a chave gerada
            RecLock("QP1",.F.)
            QP1->QP1_CHAVE := cChave
            MsUnLock()
        Else
            cChave := QP1->QP1_CHAVE
        Endif
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Grava Texto do Ensaio no QA2                             ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        QA_GrvTxt(cChave,"QIPA020 ",1,aTexto)   // QAXFUN
    Else
        If !Empty(QP1->QP1_CHAVE)
            QA_GrvTxt(QP1->QP1_CHAVE,"QIPA020 ",1,aTexto)   // QAXFUN
        EndIF
    EndIF
EndIf 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Na Rotina de exlusão, Ensaio tem de ser excluido por ultimo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == 5)      
    RecLock("QP1",.F.)
    QP1->(dbDelete())
    MsUnLock() 
    FKCOMMIT()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QP020Alt  ³ Autor ³ Cleber Souza           ³ Data ³ 25/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existe especificacao cadastrada cadastrada     ³±±
±±³          ³ Caso exista nao deixa alterar campo.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QP020Alt()  
Local lAltera   := .F.
Local aArea     := GetArea()
Local aFiliais := {}
Local nY       := 0
Local cFilQP1  := xFilial("QP1") 

If (FWModeAccess("QP6") == "E") //!Empty(xFilial("QP6"))
    aFiliais := QA_RetFilEmp(SM0->M0_CODIGO) //Retorna as Filiais associadas a Empresa Atual
Else 
    AADD(aFiliais,{Space(FWSIZEFILIAL()),Space(FWSIZEFILIAL()),Space(FWSIZEFILIAL()),Space(FWSIZEFILIAL())})
EndIF                                                     

For nY:=1 to Len(aFiliais)  
    If aFiliais[nY,2]==cFilQP1 .or. (FWModeAccess("QP1") == "C")//Empty(cFilQP1)
        dbSelectArea("QP7")
        dbSetOrder(3)
        If dbSeek(aFiliais[nY,2]+QP1->QP1_ENSAIO)
            lAltera := .T.
        Else
            dbSelectArea("QP8")
            dbSetOrder(3)
            If dbSeek(aFiliais[nY,2]+QP1->QP1_ENSAIO)
                lAltera := .T.
            EndIf   
        EndIf
    EndIf
    If lAltera
        Exit
    EndIf   
Next nY 

QP7->(dbSetOrder(1))
QP8->(dbSetOrder(1))
RestArea(aArea)

Return(lAltera) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A020VQTD ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o campo Qtde na entrada de dados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_VALID do campo QP1_QTDE                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020VQtd(cCarta,nQtde)
Local lRetu := .t.

If cCarta $ 'HIS.XBR.XBS.XMR.IND'
    If nQtde < 2  
        lRetu := .f.
        Help(" ",1,"A020CARTAX")
    ElseIf nQtde > 10
        lRetu := .f.
        Help(" ",1,"A020CARTAX")
    Endif
ElseIf cCarta $ 'NP .C  '
    If nQtde == 0
        lRetu := .f.
        Help(" ",1,"A020CARTAC")
        M->QP1_QTDE := 1
    EndIf
Else
    If nQtde <> 0
        lRetu := .f.
        Help(" ",1,"A020CARTAP")
        M->QP1_QTDE := 0
    EndIf
EndIf
Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A020VlNC ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Nao Conformidade                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A020VlNC(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Nao Conformidade                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico - E' chamada no X3_VALID do cpo. QP?_NAOCON - SX3 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020VlNC(cNC)
    Local cVar  := &(readvar()) //Conteúdo da variável do campo NC
    Local lRetu := .t.
    Local nCont := 0

    If !hasSmartX()
        //Verifica se mudou a NC (Alterou o campo já digitado)
        If !Empty(oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC]) .and. !Empty(cVar) .and. oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC] <> cVar
            Help(" ",1,"A010ALTCHA")//Campo não pode ser alterado
            lRetu := .f.
        EndIf

        If lRetu
            //Verifica se a NC está cadastrada
            oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC] := cNc
            
            SAG->(dbSetOrder(1))
            If SAG->(dbSeek(xFilial("SAG")+cNc))
                oGetNC:aCols[oGetNC:oBrowse:nAt][nPosCla] := SAG->AG_CLASSE
            Else
                oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC] := Space(TamSX3("QP9_NAOCON")[1])
                lRetu := .f.
            EndIf
            
        EndIf

        //Verifica se a NC já existe
        If lRetu
            For nCont := 1 To Len(oGetNC:aCols)
                If cVar == oGetNC:acols[nCont][nPosNC] .and. nCont <> oGetNC:oBrowse:nAt // Se já existir este cod. NC
                    Help(" ",1,"A020EXINCE")
                    lRetu := .f.
                    EXIT
                EndIf
            Next nCont
        EndIf

        If lRetu
            //Preenche a Descrição da NC
            oGetNC:aCols[oGetNC:oBrowse:nAt][nPosDNC] := QipxDNCo(oGetNC:aCols[oGetNC:oBrowse:nAt][nPosNC])
            
            //Preenche a Descrição da Classe
            oGetNC:aCols[oGetNC:oBrowse:nAt][nPosDCl] := A010DCla(oGetNC:aCols[oGetNC:oBrowse:nAt][nPosCla])
        EndIf
    EndIf

Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A020VlCl ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Classe da Nao Conformidade                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A020VlNC(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Classe da Nao Conformidade                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico - E' chamada no X3_VALID do cpo. QP?_CLASSE - SX3 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020VlCl(cClasse)
	Local lRetu := ExistCpo("QEE", cClasse)

				   //Verifica se a origem da pilha de chamadas até a chamada dessa função, originou-se da execução de uma rotina SmartX.
	If lRetu .And. Findfunction( "totvs.framework.smartx.context.amIIn",.T. ) .And. !totvs.framework.smartx.context.amIIn()
        aCols[n][nPosCla] := cClasse
        aCols[n][nPosDCl] := A010DCla(aCols[n][nPosCla])
    EndIf

Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A020WheQt ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Determina X3_WHEN do campo QTDE de acordo com a Carta      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA020 - Chamada pelo cpo. QP1_QTDE - X3_WHEN             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020WheQt()
Local lRetu := .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Carta permite entrada da Qtde      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ReadVar() == "M->QP1_QTDE"
    If M->QP1_CARTA $ 'P  .U  ' .Or. M->QP1_TPCART =="X"
        lRetu := .f.
    EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Se houver medicoes p/ o ensaio, nao altera a Qtde.             ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lRetu
        QPR->(dbSetOrder(2))
        If QPR->(dbSeek(xFilial("QPR")+M->QP1_ENSAIO))
            Help(" ",1,"A020ENSMED")   // "Ensaio apresenta medicoes cadastradas"
            lRetu := .f.
        EndIf
        QPR->(dbSetOrder(1))
    EndIf
EndIf

Return(lRetu)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A020WhTp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Determina X3_WHEN do campo CARTA de acordo com o Tipo.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA020 - Chamada pelo cpo. QP1_CARTA- X3_WHEN             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020WhTp()
Local lRetu := .t.

If ReadVar() == "M->QP1_CARTA"
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se a Tipo de Carta.                    ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If M->QP1_TPCART $"X.T"
        If M->QP1_TPCART =="X"
            M->QP1_CARTA := "TXT"
        EndIf
        lRetu := .f.
    EndIf
EndIf
Return lRetu
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A020IQtd ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa o campo Qtde na entrada de dados (X3_RELACAO)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gatilho do campo QP1_QTDE, a partir do QP1_CARTA           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020IQtd(cCarta)

Local nQtde := nRetu := M->QP1_QTDE

If Empty(nQtde)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Se campo Qtde vazio, sugere as Qtdes defaults                ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cCarta == 'IND'
        nRetu := 2
    ElseIf cCarta $ 'HIS.XBR.XBS.XMR'
        nRetu := 5
    ElseIf cCarta $ 'NP .C  '
        nRetu := 1
    Endif
Else
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Consiste o campo Qtde, porque pode ter alterado a Carta    ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cCarta $ 'IND.HIS.XBR.XBS.XMR.NP .C  '
        If cCarta == 'IND'
            nRetu := 2
        ElseIf cCarta $ 'HIS.XBR.XBS.XMR'
            nRetu := 5
        Endif
    Else
        nRetu := 0
    Endif
Endif

Return(nRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A020DCar ³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher a descricao da Carta do Ensaio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A020DCar(ExpC1,ExpL1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Carta                                    ³±±
±±³          ³ ExpL1 = Indica se e' gatilho                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico-Cham. no X3_RELACAO,X3_INIBRW e gat. (QP1_CARTA)  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020DCar(cCodCa,lGatilho)
    Local aSx5Q4 := FWGetSX5( "Q4", cCodCa )
    Local cDescri := Space(Len(X5Descri()))

    lGatilho := Iif(lGatilho == NIL,.t.,lGatilho)
    Inclui := Iif(Inclui == NIL,.f.,Inclui)

    IF !Inclui .or. lGatilho .And. (ValType(aSx5Q4) == "A" .And. Len(aSx5Q4) > 0)
        cDescri := aSx5Q4[1,4]
    Endif

Return cDescri

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A020Valid³ Autor ³ Marcelo Pimentel      ³ Data ³ 09/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o campo Carta ‚ obrigatorio.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A020Valid()

Local lRet := .T.

If M->QP1_TPCART == "D"     //Tipo de carta "DIMENSIONAL"
    If Empty(M->QP1_CARTA)
        Help(" ",1,"QA_CPOOBR")
        lRet := .F.
    EndIf
EndIf       

//Valida a carta Texto
If lRet .And. M->QP1_TPCART <> "X" .And. M->QP1_CARTA == "TXT"
    Help(" ",1,"QA_TPCARTX") //"A carta 'TXT' somente podera ser utilizada" ### "para o tipo de carta 'X' - (Texto)"
    lRet := .F.
EndIf

//Ensaio do Tipo Calculado somente para carta Individual
If lRet .And. M->QP1_TIPO == "C" .And. !(M->QP1_CARTA $ "IND,XBR,XBS,HIS,XMR")
    Help(" ",1,"QP20TPCALC") //"O Ensaio Calculado somente podera ser" ### "utilizado para cartas 'IND,XMR,XBR,XBS e HIS'"
    lRet := .F.
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  A020EnsC³ Autor ³ Cleber Souza          ³ Data ³22/03/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ habilita o campo somente para as cartas Individuais        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A020EnsC()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X3_WHEN do QP1_TIPO                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020EnsC()
Local lRetorno := .F.

If M->QP1_CARTA $ "XBR/XBS/XMR/IND/HIS"  
        lRetorno := .T.
Else
    M->QP1_TIPO :=  'D'
EndIf 

Return(lRetorno)   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPA020   ºAutor  ³Renata Cavalcante   º Data ³  09/20/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para inclusão de ensaio via consulta padrão         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Função para inclusão de ensaio via consulta padrão         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q020INCENS

AxInclui("QP1",,,,,,"Q020TUDOK()")

Return()                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPA020   ºAutor  ³Renata Cavalcante   º Data ³  09/20/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para validação do cadastro via consulta padrão      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Função para validação do cadastro via consulta padrão      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q020Tudok  
Local lRet:=.T.
    If EMPTY(M->QP1_CARTA)
        messagedlg(STR0009,,3)//"o campo carta deverá ser preenchido"
        lRet:=.f.   
    Endif
Return(lRet)

/*/{Protheus.doc} verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx
Verifica e exibe o aviso de substituicao da rotina QIPA020 pela QIPA020SX.
A preferencia de supressao e persistida por usuario via FWProfile.
Deve ser chamada no inicio da rotina QIPA020, antes de qualquer processamento.
@author rafael.kleestadt
@since 13/05/2026
@version P12
/*/
Method verificaNecessidadeEChamaExibicaoAvisoSubstituicaoPorSmartx() Class QIPA020AuxClass

    Local cDataGrava := ""
    Local dDataExp   := CToD("")
    Local lExibir    := .F.
    Local oProfile   := FWProfile():New()

    // Carrega o profile do usuario atual
    oProfile:SetUser(RetCodUsr())
    oProfile:SetProgram(QIPA020_PROG)
    oProfile:SetTask(QIPA020_TASK)
    oProfile:Load()

    cDataGrava := AllTrim(oProfile:GetStringProfile())

    If Empty(cDataGrava)
        // Nunca suprimiu: exibe o aviso
        lExibir := .T.
    Else
        // Verifica se o periodo de supressao ja expirou
        dDataExp := SToD(cDataGrava)
        lExibir  := (dDataBase >= dDataExp)
    EndIf

    If lExibir
        // Retorna .T. se o usuario clicou em "Lembrar mais tarde"
        If Self:exibeAvisoSubstituicaoPorSmartx()
            // Grava a data de expiracao: hoje + 7 dias
            oProfile:SetStringProfile(DToS(Date() + QIPA020_DIAS))
            oProfile:Save()
        EndIf
    EndIf

    FreeObj(oProfile)
	oProfile := NIL

Return

/*/{Protheus.doc} methodName
Monta e exibe o dialogo modal de aviso de substituicao da QIPA020.
Dois botoes: "OK" (fecha sem suprimir) e "Lembrar mais tarde (7 dias)" (suprime).
@author rafael.kleestadt
@since 13/05/2026
@version P12
@return lLembrar, logico, .T. se o usuario clicou em "Lembrar mais tarde"
/*/
Method exibeAvisoSubstituicaoPorSmartx() Class QIPA020AuxClass

    Local aButtons   := {}
    Local lLembrar   := .F.   // .T. = clicou em "Lembrar mais tarde"
    Local oContainer := NIL
	Local oFont      := NIL   // objeto de fonte para o texto da mensagem
    Local oModal     := NIL

    // --- Cria a fonte: Arial, 14px, sem negrito ---
    // nAltura negativo = tamanho exato em pixels
    oFont := TFont():New('Arial', /*nLargura*/, -14, /*lBold*/ .F.)

    oModal := FWDialogModal():New()
    oModal:SetTitle(OemToAnsi(STR0011)) //"Atenção!"
    oModal:SetEscClose(.F.)         // Nao fecha com ESC (forcando escolha consciente)
    oModal:SetCloseButton(.F.)      // Remove o X do canto superior direito
    oModal:setSize(100, 300)        // Altura x Largura em pixels
    oModal:createDialog()

    // --- Botao "Lembrar mais tarde (7 dias)" ---
    // Fica a esquerda, e a acao menos urgente
    AAdd(aButtons, { ;
        "",                                        ; // [1] Compatibilidade (descontinuado no P12)
        OemToAnsi(STR0012),                        ; // [2] Titulo do botao STR0012 - "Lembrar mais tarde (7 dias)"
        {|| lLembrar := .T., oModal:DeActivate()}, ; // [3] Bloco de codigo
        OemToAnsi(STR0013),                        ; // [4] Tooltip STR0013 - "Suprimir este aviso pelos próximos 7 dias"
        0,                                         ; // [5] ShortCut
        .T.,                                       ; // [6] Visivel na barra
        .F.                                        ; // [7] Visivel na configuracao
    })

    oModal:AddButtons(aButtons)

    // --- Botao "OK" ---
    // Fica a direita (padrao), e o botao principal/focal
    oModal:addOkButton({|| lLembrar := .F., oModal:DeActivate()}, "OK")

    // --- Conteudo do dialogo ---
    oContainer := TPanel():New(,,, oModal:getPanelMain())
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	TSay():New(15, 10, ;
        {|| OemToAnsi(STR0014)}, ; // "A partir da versão 12.1.2710 esta rotina deve ser substituída pela nova QIPA020SX que já está disponível para uso a partir da versão 12.1.2610."
        oContainer, /*cPicture*/, oFont, , , , .T., , , 285, 20, , , , , , .T.)

    oModal:Activate()

Return lLembrar
