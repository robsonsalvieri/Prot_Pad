#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU015D.CH'

/*/{Protheus.doc} GTPU015D()
(long_description)
@type  Static Function
@author flavio.martins
@since 21/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPU015D(cCodCaixa)
Local lRet      := .T.
Local oModel    := Nil

Private lMsErroAuto := .F.

dbSelectArea('H7P')
H7P->(dbSetOrder(1))

If H7P->(dbSeek(xFilial('H7P')+cCodCaixa))

    oModel := FwLoadModel('GTPU015')
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    oModel:GetModel('H7PMASTER'):SetValue('H7P_STATUS', '4')

     If oModel:GetModel('H7QRECEITA'):Length() > 0
         lRet := EstTitRec(oModel)
     Endif

     If lRet .And. oModel:GetModel('H7QDESPESA'):Length() > 0 
         lRet := EstTitDes(oModel)
     Endif

     If lRet .And. oModel:VldData()
         FwFormCommit(oModel)
     Endif

     oModel:DeActivate()
     oModel:Destroy()

Endif

Return lRet

/*/{Protheus.doc} EstTitRec(oModel)
Função que gera os títulos das receitas do caixa do urbano
@type Static Function
@author flavio.martins
@since 21/06/2024
@version 1.0
/*/
Static Function EstTitRec(oModel)
Local lRet 		:= .T.
Local aTitSE1   := {}
Local cChaveSE1 := ''
Local nX        := 0

SE1->(dbSetOrder(1))

For nX := 1 To oModel:GetModel('H7QRECEITA'):Length()

    oModel:GetModel('H7QRECEITA'):GoLine(nX)

    If !Empty(oModel:GetValue('H7QRECEITA', 'H7Q_NUMTIT'))

        cChaveSE1 := oModel:GetValue('H7QRECEITA', 'H7Q_FILTIT')+;
                     oModel:GetValue('H7QRECEITA', 'H7Q_PRETIT')+;
                     oModel:GetValue('H7QRECEITA', 'H7Q_NUMTIT')+;
                     oModel:GetValue('H7QRECEITA', 'H7Q_PARTIT')+ 'TF '

        If SE1->(dbSeek(cChaveSE1))

            If !Empty(SE1->E1_BAIXA)

                cFilAnt := 	SE1->E1_FILORIG
                aTitSE1	:= {;
                {"E1_FILIAL"	, SE1->E1_FILIAL 		,Nil},;
                {"E1_PREFIXO"	, SE1->E1_PREFIXO 		,Nil},;
                {"E1_NUM"		, SE1->E1_NUM       	,Nil},;
                {"E1_PARCELA"	, SE1->E1_PARCELA  		,Nil},;
                {"E1_TIPO"	    , SE1->E1_TIPO     		,Nil},;
                {"E1_CLIENTE"   , SE1->E1_CLIENTE      	,Nil},;
                {"E1_LOJA"		, SE1->E1_LOJA			,Nil},;
                {"AUTHIST"	    , STR0001 ,Nil}} // "Reabertura de Caixa"
                    
                MsExecAuto({|x,y| Fina070(x,y)}, aTitSE1, 6) // Exclui a baixa do título
                                                    
                If lMsErroAuto
                    lRet := .F.
                    MostraErro()
                    Exit
                Endif

                MsExecAuto( { |x,y| FINA040(x,y)} , aTitSE1, 5)  // Exclui o título
                
                If lMsErroAuto
                    lRet := .F.
                    MostraErro()
                    Exit
                Else

                    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_FILTIT')
                    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_PRETIT')
                    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_NUMTIT')
                    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_PARTIT')
                    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_TIPTIT')
                    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_CLIFOR')
                    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_LOJTIT')

                Endif

            Endif

        Endif

    Endif

Next

Return lRet

/*/{Protheus.doc} EstTitDes(oModel)
Função que gera os títulos das despesas do caixa do urbano
@type Static Function
@author flavio.martins
@since 21/06/2024
@version 1.0
/*/
Static Function EstTitDes(oModel)
Local lRet 		:= .T.
Local aTitSE2   := {}
Local cChaveSE2 := ''
Local nX        := 0

SE2->(dbSetOrder(1))

For nX := 1 To oModel:GetModel('H7QDESPESA'):Length()

    oModel:GetModel('H7QDESPESA'):GoLine(nX)

    If !Empty(oModel:GetValue('H7QDESPESA', 'H7Q_NUMTIT'))

        cChaveSE2 := oModel:GetValue('H7QDESPESA', 'H7Q_FILTIT')+;
                     oModel:GetValue('H7QDESPESA', 'H7Q_PRETIT')+;
                     oModel:GetValue('H7QDESPESA', 'H7Q_NUMTIT')+;
                     oModel:GetValue('H7QDESPESA', 'H7Q_PARTIT')+ 'TF '

        If SE2->(dbSeek(cChaveSE2))

            If !Empty(SE2->E2_BAIXA)

             //   cFilAnt := 	SE2->E2_FILORIG
                aTitSE2	:= {;
                {"E2_FILIAL"	, SE2->E2_FILIAL 		,Nil},;
                {"E2_PREFIXO"	, SE2->E2_PREFIXO 		,Nil},;
                {"E2_NUM"		, SE2->E2_NUM       	,Nil},;
                {"E2_PARCELA"	, SE2->E2_PARCELA  		,Nil},;
                {"E2_TIPO"	    , SE2->E2_TIPO     		,Nil},;
                {"E2_FORNECE"   , SE2->E2_FORNECE      	,Nil},;
                {"E2_LOJA"		, SE2->E2_LOJA			,Nil}} 
                    
                MsExecAuto({|x,y| Fina080(x,y)}, aTitSE2, 6) // Exclui a baixa do título
			                                                    
                If lMsErroAuto
                    lRet := .F.
                    MostraErro()
                    Exit
                Endif

               	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTitSE2,, 5) // Exclui o título
                
                If lMsErroAuto
                    lRet := .F.
                    MostraErro()
                    Exit
                Else

                    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_FILTIT')
                    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_PRETIT')
                    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_NUMTIT')
                    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_PARTIT')
                    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_TIPTIT')
                    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_CLIFOR')
                    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_LOJTIT')

                Endif

            Endif

        Endif

    Endif

Next

Return lRet
