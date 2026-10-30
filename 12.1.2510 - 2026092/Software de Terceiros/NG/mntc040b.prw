#INCLUDE 'MNTC040.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC040B
Monta um browse das manutenções da OS

@author Cauê Girardi Petri
@since 26/03/26
@return Nil
/*/
//--------------------------------------------------
Function MNTC040B()
	
    Local cFuncBkp    := FunName()
    Local aMenu       := MenuDef()
    Private cCadastro := OemtoAnsi(STR0009) //"Manutencao do Servico"

    SetFunName( 'MNTC040B' )

    If IsInCallStack("MNTA040") .And. INCLUI
    	MsgInfo(STR0016,STR0015)  //"Serviço não cadastrado." ## "ATENÇÃO"
    	Return .F.
    EndIf
    
    M->T4_SERVICO := ST4->T4_SERVICO
    
    DbSelectArea("STF")
    DbSetOrder(03)
    
    cKey := M->T4_SERVICO
    
    bWHILE := {|| !Eof() .And. STF->TF_SERVICO == M->T4_SERVICO }
    bFOR   := {|| TF_FILIAL  == xFilial("STF") }
    
    NGCONSULTA("TRBF", cKEY, bWHILE, bFOR, aMenu,{})
    
    DbSelectArea("STF")
    DbSetOrder(01)

    SetFunName( cFuncBkp )

    FwFreeArray( aMenu )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Cauê Girardi Petri
@since 26/03/26
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := {{STR0002 ,"AXPesqui" , 0 , 1     },;  //"Pesquisar"
                      {STR0010 ,"AxVisual" , 0 , 2 },;      //"Visualizar"
                      {STR0011 ,"MNTCTARE" , 0 , 3 , 0},;   //"Tarefas"
                      {STR0012 ,"OSHISTORI", 0 , 4 , 0}}    //"Historico"

Return aReturn
