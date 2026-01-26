#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static a754Inputs := {}

/*/{Protheus.doc} GTPA754
H6I	Movimentações da bagagem
H6J	Itens Movimento
@type  Function
@author user
@since 03/10/2022
@version version
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA754()

    Local cMsgErro   := ""

    If ( GTPxVldDic("H6I",/*aFieldsH6I*/,.T.,.T.,@cMsgErro) )
        A754View()        
    EndIf

    If !(EMPTY(cMsgErro))
        FwAlertWarning(cMsgErro)
    EndIf
    
    ResetStatics()
    
Return()

Static Function ResetStatics()

    a754Inputs := {}

Return()    

Static Function ModelDef()

    Local oModel    := Nil
    Local oStrHead  := Nil
    Local oStrMov   := Nil
   
    Local bCommit   := {|oModel| Commit(oModel)}
    Local bLoad     := {|oSub| LoadData(oSub)}

    ModelStruct(@oStrHead,@oStrMov)

    oModel := MPFormModel():New('GTPA754', /*bPreValidacao*/, /*bPosValid*/, bCommit, /*bCancel*/ )

    oModel:AddFields('HEADER',/*cOwner*/,oStrHead,,,bLoad)
    oModel:AddGrid('MOVEMENT','HEADER',oStrMov,/*bPreLine*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,bLoad)

    oModel:SetRelation('MOVEMENT',{{ 'H6I_FILIAL','xFilial("H6I")'},{'H6I_AGEDES','AGENCIA' }},"H6I_FILIAL+H6I_AGEDES")

    oModel:GetModel('MOVEMENT'):SetNoInsertLine(.T.)// Não permite inclusao no grid
    oModel:GetModel('MOVEMENT'):SetNoDeleteLine(.T.)// Não permite exclusao no grid

    oModel:SetDescription("Recebimento de Bagagens")
    oModel:GetModel("HEADER"):SetDescription("Seleção de Agência")
    oModel:GetModel("MOVEMENT"):SetDescription("Lista das movimentações")

    oModel:SetPrimaryKey({})

Return(oModel)

Static Function ModelStruct(oStrHead,oStrMov)

    Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue|;
                        FieldValid(oMdl,cField,uNewValue,uOldValue) }
    Local bInit     := {|oSub| Posicione("GI6",1,xFilial("GI6")+oSub:GetValue("AGENCIA"),"GI6_DESCRI") }                        
    // Local bInitMovement := {|oSub,cField| InitMove(oSub,cField)}

    oStrHead    := FwFormModelStruct():New()
    oStrMov     := FwFormStruct(1,"H6I")   //oModel:GetModel("H6IMASTER"):GetStruct()
    
    oStrHead:AddField(	"Agência",;	                // 	[01]  C   Titulo do campo   // "Monitor"
				 		"Agência",;	                // 	[02]  C   ToolTip do campo  // "Monitor"
				 		"AGENCIA",;	                // 	[03]  C   Id do Field
				 		"C",;		                // 	[04]  C   Tipo do campo
				 		TamSx3("GI6_CODIGO")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			                // 	[06]  N   Decimal do campo
				 		bFldVld,;		            // 	[07]  B   Code-block de validação do campo
				 		Nil,;		                // 	[08]  B   Code-block de validação When do campo
				 		Nil,;		                //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                //	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		                //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		                // 	[14]  L   Indica se o campo é virtual  
    
    oStrHead:AddField(  "Nome Agência",;            // 	[01]  C   Titulo do campo   // "Monitor"  
                        "Nome da Agência",;         // 	[02]  C   ToolTip do campo  // "Monitor"
                        "DESCAGENCI",;              // 	[03]  C   Id do Field
                        "C",;                       // 	[04]  C   Tipo do campo
                        TamSx3('GI6_DESCRI')[1],;   // 	[05]  N   Tamanho do campo
                        0,;                         // 	[06]  N   Decimal do campo
                        {|| .T.},;                  // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;                  // 	[08]  B   Code-block de validação When do campo
                        {},;                        //	[09]  A   Lista de valores permitido do campo
                        .F.,;                       //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        bInit,;                     //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                       //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                       //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                        // 	[14]  L   Indica se o campo é virtual

    oStrHead:AddField(  "Data De",;             // 	[01]  C   Titulo do campo   // "Monitor"
                        "Data De",;             // 	[02]  C   ToolTip do campo  // "Monitor"
                        "DATAINI",;             // 	[03]  C   Id do Field
                        "D",;                   // 	[04]  C   Tipo do campo
                        8,;                     // 	[05]  N   Tamanho do campo
                        0,;                     // 	[06]  N   Decimal do campo
                        bFldVld,;               // 	[07]  B   Code-block de validação do campo
                        Nil,;                   // 	[08]  B   Code-block de validação When do campo
                        {},;                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                   //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.) 			        // 	[14]  L   Indica se o campo é virtual
	
    oStrHead:AddField(  "Data Até",;            // 	[01]  C   Titulo do campo   // "Monitor"
                        "Data Até",;            // 	[02]  C   ToolTip do campo  // "Monitor"
                        "DATAFIM",;             // 	[03]  C   Id do Field
                        "D",;                   // 	[04]  C   Tipo do campo
                        8,;                     // 	[05]  N   Tamanho do campo
                        0,;                     // 	[06]  N   Decimal do campo
                        bFldVld,;               // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;              // 	[08]  B   Code-block de validação When do campo
                        {},;                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                   //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                    // 	[14]  L   Indica se o campo é virtual
    
    oStrMov:AddField(   "Marcar",;            // 	[01]  C   Titulo do campo 
                        "Marcar",;            // 	[02]  C   ToolTip do campo
                        "MARCAR",;             // 	[03]  C   Id do Field
                        "L",;                   // 	[04]  C   Tipo do campo
                        1,;                     // 	[05]  N   Tamanho do campo
                        0,;                     // 	[06]  N   Decimal do campo
                        bFldVld,;               // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;              // 	[08]  B   Code-block de validação When do campo
                        {},;                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                   //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                    // 	[14]  L   Indica se o campo é virtual
    
    oStrMov:AddField(   "Nome Usr.Rec.",;       // 	[01]  C   Titulo do campo 
                        "Nome Usuário Receb.",; // 	[02]  C   ToolTip do campo
                        "H6IUSNMREC",;          // 	[03]  C   Id do Field
                        "C",;                   // 	[04]  C   Tipo do campo
                        50,;                    // 	[05]  N   Tamanho do campo
                        0,;                     // 	[06]  N   Decimal do campo
                        {|| .F.},;              // 	[07]  B   Code-block de validação do campo
                        {|| .T.},;              // 	[08]  B   Code-block de validação When do campo
                        {},;                    //	[09]  A   Lista de valores permitido do campo
                        .F.,;                   //	[10]  L   Indica se o campo tem preenchimento obrigatório
                        NIL,;                   //	[11]  B   Code-block de inicializacao do campo
                        .F.,;                   //	[12]  L   Indica se trata-se de um campo chave
                        .F.,;                   //	[13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.)                    // 	[14]  L   Indica se o campo é virtual

    // oStrMov:SetProperty("H6I_DTRETI",MODEL_FIELD_INIT,bInitMovement)
    // oStrMov:SetProperty("H6I_HRRETI",MODEL_FIELD_INIT,bInitMovement)
    // oStrMov:SetProperty("H6I_USRETI",MODEL_FIELD_INIT,bInitMovement)                        
                            

Return()

Static Function ViewDef()

    Local oModel        := ModelDef()
    Local oView         := FwFormView():New()
    Local oStrHead      := Nil
    Local oStrMov       := Nil

    Local bAction       := {|oView| CursorWait(), RunFilter(oView), CursorArrow() }
    Local bActMark      := {|oView| SetMark(oView) }
    Local bActInvert    := {|oView| InvertMark(oView) }

    ViewStruct(@oStrHead,@oStrMov)
    
    oView:SetModel(oModel)

    oView:AddField('VIEW_HEADER',   oStrHead,   'HEADER')
    oView:AddGrid('VIEW_MOVEMENT',  oStrMov,    'MOVEMENT')

    oView:CreateHorizontalBox('UPPER'   , 25)
    oView:CreateHorizontalBox('BOTTOM'  , 75)

    oView:SetOwnerView('VIEW_HEADER','UPPER')
    oView:SetOwnerView('VIEW_MOVEMENT','BOTTOM')
    
    oView:SetDescription("Recebimento de Bagagens")
    oView:GetModel("HEADER"):SetDescription("Seleção de Agência")
    oView:GetModel("MOVEMENT"):SetDescription("Lista das movimentações")

    oView:AddUserButton("Filtrar Movimentos <F5>", "", bAction ,,VK_F5)
    oView:AddUserButton("Marcar/Desmarcar Todos <F6>", "", bActMark ,,VK_F6)
    oView:AddUserButton("Inverter seleção <F7>", "", bActInvert ,,VK_F7)

    oView:SetAfterViewActivate({|oView| ConfigHeader(oView)})

Return(oView)

Static Function ViewStruct(oStrHead,oStrMov)
  
    oStrHead := FWFormViewStruct():New()
    oStrMov  := FwFormStruct(2,"H6I")

    //Ajusta a estrutura de oStrHead (Cabeçalho)
    oStrHead:AddField(  "AGENCIA",;                                     // [01] C Nome do Campo                                       
                        "01",;   	                                    // [02] C Ordem
                        "Agência",;                                     // [03] C Titulo do campo //"Cód.ECF"
                        "Agência",;                                     // [04] C Descrição do campo //"Cód.ECF"
                        {   "Digite o código da agência de destino",;
                            "que possui movimentações",;
                            "de bagagens extraviadas" }, ;              // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	                                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                                    // [07] C Picture
                        NIL,;   	                                    // [08] B Bloco de Picture Var
                        "GI6",;	                                        // [09] C Consulta F3
                        .T.,;    	                                    // [10] L Indica se o campo é editável
                        NIL,;                                           // [11] C Pasta do campo
                        NIL,;    	                                    // [12] C Agrupamento do campo
                        Nil,;  	                                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                                    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	                                    // [15] C Inicializador de Browse
                        .F.)    	                                    // [16] L Indica se o campo é virtual

    oStrHead:AddField(  "DESCAGENCI",;                  // [01] C Nome do Campo                                       
                        "02",;   	                    // [02] C Ordem
                        "Nome Agência",;                // [03] C Titulo do campo //"Cód.ECF"
                        "Nome Agência",;                // [04] C Descrição do campo //"Cód.ECF"
                        {"Nome da Agência Destino"}, ;  // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo é editável
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo é virtual

    oStrHead:AddField(  "DATAINI",;    // [01] C Nome do Campo                                       
                        "03",;   	     // [02] C Ordem
                        "Data de",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Data de",;     // [04] C Descrição do campo //"Cód.ECF"
                        {"Data incial de movimentações"}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
    
    oStrHead:AddField(  "DATAFIM",;    // [01] C Nome do Campo                                       
                        "04",;   	     // [02] C Ordem
                        "Data até",;     // [03] C Titulo do campo //"Cód.ECF"
                        "Data até",;     // [04] C Descrição do campo //"Cód.ECF"
                        {"Data final de movimentções"}, ;         // [05] A Array com Help //"Cód.ECF"
                        "GET",;  	    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	    // [07] C Picture
                        NIL,;   	    // [08] B Bloco de Picture Var
                        "",;	        // [09] C Consulta F3
                        .T.,;    	    // [10] L Indica se o campo é editável
                        NIL,;           // [11] C Pasta do campo
                        NIL,;    	    // [12] C Agrupamento do campo
                        Nil,;  	        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	    // [14] N Tamanho Maximo da maior opção do combo
                        NIL,;    	    // [15] C Inicializador de Browse
                        .F.)    	    // [16] L Indica se o campo é virtual
    
    //Ajusta a estrutura de oStrMov (itens)
     
    oStrMov:AddField(   'H6IUSNMREC', ;                 // cIdField
				        CValToChar(Len(oStrMov:GetFields())), ;                         // cOrdem
				        "Nome Usr.Rec.", ;              // cTitulo
				        "Nome Usuário Receb.", ;        // cDescric
				        {"Nome Usuário Recebimento"},;  // aHelp
				        'GET', ;                        // cType
				        '@!', ;                         // cPicture
				        Nil, ;                          // nPictVar
				        Nil, ;                          // Consulta F3
				        .T., ;                          // lCanChange
				        '' , ;                          // cFolder
				        Nil, ;                          // cGroup
				        Nil, ;                          // aComboValues
				        Nil, ;                          // nMaxLenCombo
				        Nil, ;                          // cIniBrow
				        .T., ;                          // lVirtual
				        Nil )                           // cPictVar
    
    
    oStrMov:AddField(   'MARCAR', ;                     // cIdField
				        '99', ;                         // cOrdem
				        '   ', ;                        // cTitulo // 'Mark'
				        "Marcar", ;                     // cDescric // 'Mark' //#"Marque o(s) Trecho(s) " 
				        {   "Marque quais bagagens",;
                            "extraviadas a agência",;
                            "de destino recebeu"}, ;     // aHelp : 'Marque os itens que deseja aplicar'  ' ### 'a configuração.'    
				        'CHECK', ;                      // cType
				        '@!', ;                         // cPicture
				        Nil, ;                          // nPictVar
				        Nil, ;                          // Consulta F3
				        .T., ;                          // lCanChange
				        '' , ;                          // cFolder
				        Nil, ;                          // cGroup
				        Nil, ;                          // aComboValues
				        Nil, ;                          // nMaxLenCombo
				        Nil, ;                          // cIniBrow
				        .T., ;                          // lVirtual
				        Nil )                           // cPictVar


    GTPOrdStruct(oStrMov,"01","MARCAR")    

    oStrMov:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
    oStrMov:SetProperty("MARCAR",MVC_VIEW_CANCHANGE,.T.)
    oStrMov:RemoveField("H6I_DTRETI")
    oStrMov:RemoveField("H6I_HRRETI")
    oStrMov:RemoveField("H6I_USRETI")
        
Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldValid
Função responsável pela validação dos campos do cabeçalho do modelo de dados

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
    
    Local lRet		:= .T.
    
    Local oModel	:= oMdl:GetModel()
    
    Local cMdlId	:= oMdl:GetId()
    Local cMsgErro	:= ""
    Local cMsgSol	:= ""

    Do Case
    	Case ( Empty(uNewValue) )
    		lRet := .T.
        Case ( cField == "AGENCIA" )

            If ( Empty(GI6->(GetAdvFVal("GI6","GI6_CODIGO",xFilial("GI6")+uNewValue,1,""))) ) 
                
                lRet        := .F.

                cMsgErro    := "Agência digitada não cadastrada."
                cMsgSol     := "Verifique se a agência deve ser cadastrada ou "
                cMsgSol     += "se o código inserido está errado."

            EndIf

        Case ( cField == "DATAFIM" )

            If ( uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI') )
                
                lRet     := .F.

                cMsgErro := "Data final não pode ser menor que a data inicial"
                cMsgSol  := "Altere a data final"

            Endif

    EndCase

    If ( !lRet .and. !Empty(cMsgErro) )
    	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
    Endif

Return lRet

Static Function LoadData(oSub)

    Local aRet  := {}

    If ( oSub:GetId() == "HEADER" )
        aRet := LoadHeader(oSub)
    Else
        aRet := LoadMovement(oSub,oSub:GetStruct())//aRet := LoadMovement(cFields,oSub,oSub:GetStruct(),aFldConv)
    EndIf

Return(aRet)

Static Function RunFilter(oView)

    Local oHead     := oView:GetModel("HEADER")
    Local oModel    := oView:GetModel()
    
    Local aFields   := oHead:GetStruct():GetFields()

    Local nI        := 0
    Local nPos      := 0

    For nI := 1 to Len(aFields)

        nPos := aScan(a754Inputs,{|z| Upper(Alltrim(z[1])) == aFields[nI,3] })

        If ( nPos > 0 )
            a754Inputs[nPos,2] := oHead:GetValue(aFields[nI,3])
        EndIf

    Next nI

    If ( oModel:IsActive() )

        oModel:DeActivate()
        oModel:Activate()
    
        oView:Refresh()
    
    EndIf

Return()

Static Function LoadHeader(oSub)

    Local nI    := 0

    Local aRet      := {}
    Local aFields   := {}
    Local aStrAux   := aClone(oSub:GetStruct():GetFields())
  
    For nI	:= 1 To Len(aStrAux)
        aAdd(aFields, A754InputValue(aStrAux[nI,3]) )
    Next nI
    
    Aadd(aRet,aClone(aFields))
    Aadd(aRet,0)

Return(aRet)

Static Function LoadMovement(oSub,oStruct)//Static Function LoadMovement(oSub,oStruct,aStrAux)
    
    Local cQry      := ""
    Local cAliasTab := ""
    Local cAgencia  := ""
    Local cDataIni  := ""
    Local cDataFim  := ""
    Local cFields   := "" 

    Local aRet      := {}
    Local aIndex    := {}
    Local aFields   := {}
    Local aFldConv  := {}

    Local nI        := 0
    Local nP        := 0
    Local cUsrFullName  := UsrFullName(H6I->H6I_USRECE)
    Local oTable    := Nil
    
    cAgencia := A754InputValue("AGENCIA")

    If ( !Empty(cAgencia) )
        
        cDataIni := A754InputValue("DATAINI")
        cDataIni := Iif( Valtype(cDataIni) == "U", SToD(""),cDataIni)
        cDataIni := DToS(cDataIni)
        
        cDataFim := A754InputValue("DATAFIM")
        cDataFim := Iif( Valtype(cDataFim) == "U", SToD(""),cDataFim)
        cDataFim := DToS(cDataFim)
    
        cFields := "( CASE WHEN H6I_STATUS = '2' THEN 'F' ELSE 'T' END ) MARCAR, "  // cFields := "' ' MARCAR, " 
        cFields += GTPFld2Str(oStruct,.t.,aFldConv) + ", " //,lReset,lSetDefault,lQuebra,cTabAlias)    
        cFields += "' ' H6IUSNMREC"
                
        cQry := "SELECT "
        cQry += "   " + cFields
        cQry += " FROM "
        cQry += "    " + RetSQLName("H6I") + " H6I "
        cQry += "WHERE "
        cQry += "    H6I_FILIAL = '" + XFilial("H6I") + "' "
        cQry += "    AND H6I.D_E_L_E_T_ = ' ' "
        cQry += "    AND H6I.H6I_STATUS in ('2','3') "
        cQry += "    AND H6I_AGEDES = '" + cAgencia + "' "
        
        If ( !Empty(cDataIni) .And. !Empty(cDataFim) )
            cQry += "    AND H6I_DTPROC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
        EndIf

        cQry += "ORDER BY "
        cQry += "    H6I_DTPROC "

        GTPNewTempTable(cQry,,aIndex,aFldConv,@oTable,.t.)
            
        cAliasTab   := oTable:GetAlias()        
        
        (cAliasTab)->(DbGoTop())

        While ( (cAliasTab)->(!Eof()) )
                    
            For nI := 1 to Len(aFldConv)
               
                If ( aFldConv[nI,1] == "H6I_DESORI" )
                    aAdd(aFields,Posicione("GI6",1,xFilial("GI6")+(cAliasTab)->H6I_AGEORI,"GI6_DESCRI"))
                ElseIf ( aFldConv[nI,1] == "H6I_DESDES" )
                    aAdd(aFields,Posicione("GI6",1,xFilial("GI6")+(cAliasTab)->H6I_AGEDES,"GI6_DESCRI"))
                ElseIf ( aFldConv[nI,1] == "H6I_NMPASS" )
                    aAdd(aFields,Posicione("H6F",1,xFilial("H6F")+(cAliasTab)->H6I_CODH6F,"H6F_NOMEPS"))
                ElseIf ( aFldConv[nI,1] == "H6IUSNMREC" )    
                    nP := aScan(aFldConv,{|x| Alltrim(x[1]) == "H6I_USRECE"}) 
                    aAdd(aFields,Iif(nP > 0, cUsrFullName,""))
                Else//If ( (cAliasTab)->(FieldPos(aFldConv[nI,1])) > 0 )
                    aAdd(aFields,(cAliasTab)->&(aFldConv[nI,1]))
                // Else
                //     aAdd(aFields,GTPCastType(,aFldConv[nI,2]))
                EndIf

            Next nI
            
            aAdd(aRet,{(cAliasTab)->(Recno()),aClone(aFields)})
            aFields := {}   
            
            (cAliasTab)->(DbSkip())
            
        EndDo
    
    EndIf

Return(aRet)

Static Function A754InputValue(cCampo)

    Local nPos := 0
    
    Local xRet  := Nil
    
    nPos := aScan(a754Inputs,{|z| Upper(Alltrim(z[1])) == Upper(Alltrim(cCampo)) })

    If ( nPos > 0 )
        xRet := a754Inputs[nPos,2]
    EndIf

Return(xRet)

Static Function Commit(oModel)

    Local oMdl753   := FwLoadModel("GTPA753")
    Local oGrid     := oModel:GetModel("MOVEMENT")
    Local cCodUsu   := RetCodUsr()
    Local nI        := 0
    
    Local aAreaH6I  := H6I->(GetArea())

    oMdl753:SetOperation(MODEL_OPERATION_UPDATE)
    H6I->(DbSetOrder(1))

    For nI := 1 to oGrid:Length()

        If ( H6I->(DbSeek(xFilial("H6I") + oGrid:GetValue("H6I_CODIGO",nI))) )

            oMdl753:Activate()

            //Se a linha foi marcada e o movimento está com status "Em Trânsito", 
            //altera para "Recebido"
            If ( oGrid:GetValue("MARCAR",nI) .and. oMdl753:GetModel("H6IMASTER"):GetValue("H6I_STATUS") == "2" )   
                oMdl753:GetModel("H6IMASTER"):SetValue("H6I_STATUS","3")
                oMdl753:GetModel("H6IMASTER"):LoadValue("H6I_DTRECE",dDataBase)
                oMdl753:GetModel("H6IMASTER"):LoadValue("H6I_HRRECE",StrTran(Time(),":",""))
                oMdl753:GetModel("H6IMASTER"):LoadValue("H6I_USRECE",cCodUsu)
            //Se a linha foi (ou esta) desmarcada e o movimento está com status "Recebido", 
            //altera para "Em Trânsito"
            ElseIf ( !oGrid:GetValue("MARCAR",nI) .And. oMdl753:GetModel("H6IMASTER"):GetValue("H6I_STATUS") == "3" )
                oMdl753:GetModel("H6IMASTER"):SetValue("H6I_STATUS","2")    //Em Trânsito
                oMdl753:GetModel("H6IMASTER"):LoadValue("H6I_DTRECE",SToD("")) 
                oMdl753:GetModel("H6IMASTER"):LoadValue("H6I_HRRECE","")
                oMdl753:GetModel("H6IMASTER"):LoadValue("H6I_USRECE","")
            EndIf

            If ( oMdl753:VldData() )
                oMdl753:CommitData()
            EndIf    
            
            oMdl753:DeActivate()
            
        EndIf

    Next nI

    RestArea(aAreaH6I)

Return(.t.)

Static Function SetMark(oView) 

    Local oGrid := oView:GetModel("MOVEMENT")

    Local nI    := 0
    Local nAt   := oGrid:GetLine()

    Local lDesmark := oGrid:SeekLine({{"MARCAR",.T.}})

    If ( oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE )

        For nI := 1 to oGrid:Length()
            
            oGrid:GoLine(nI)          
            
            oGrid:SetValue("MARCAR",!lDesmark)

        Next nI

        oView:Refresh("VIEW_MOVEMENT")
        oView:GoLine("MOVEMENT",nAt)   //GOLINE	CIDSUBMODEL,NLINE,LEVALCHANGES

    EndIf

Return()

Static Function InvertMark(oView)

    Local oGrid := oView:GetModel("MOVEMENT")

    Local nI    := 0
    Local nAt   := oGrid:GetLine()

    If ( oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE )
    
        For nI := 1 to oGrid:Length()
            
            oGrid:GoLine(nI)
            
            oGrid:SetValue("MARCAR",!(oGrid:GetValue("MARCAR")))
            
        Next nI

        oView:Refresh("VIEW_MOVEMENT")
        oView:GoLine("MOVEMENT",nAt)   //GOLINE	CIDSUBMODEL,NLINE,LEVALCHANGES

    EndIf

Return()

Static Function ConfigHeader(oView)

    Local bHeaderClick := {|| SetMark(oView) }

    If ( Valtype(oView) == "O" )
        oView:GetViewObj("VIEW_MOVEMENT")[3]:oBrowse:GetColumn(1):bHeaderClick := bHeaderClick //{|| SELF:TGRIDORDERCOLUMN()}
    EndIf

Return(.t.)

/*/{Protheus.doc} A754View(2)
   nOpcdescription)
    @type  Function
    @author user
    @since 18/10/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function A754View(nOpc)
    
    Local aEnableButtons    :=  {   {.F.,Nil},;
                                    {.F.,Nil},;
                                    {.F.,Nil},;
                                    {.T.,Nil},;
                                    {.T.,Nil},;
                                    {.T.,Nil},;
                                    {.T.,"Confirmar"},;
                                    {.T.,"Cancelar"},;
                                    {.T.,Nil},;
                                    {.T.,Nil},;
                                    {.T.,Nil},;
                                    {.T.,Nil},;
                                    {.T.,Nil},;
                                    {.T.,Nil}}

    Local nRet              := 0
    
    nRet := FWExecView("Recebimento de Bagagens", "VIEWDEF.GTPA754",MODEL_OPERATION_UPDATE, /*[ oDlg*/,{|| .T.},{|| .T.},/*nPercReducao*/,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModelAct*/)

Return(nRet)

Function GA754SetInput(aInput)

    Local cAgencia  := ""
    Local cDescAge  := ""

    Local dDtIni    := stod("")
    Local dDtFim    := stod("")
    
    cAgencia    := aInput[1]
    cDescAge    := GI6->(GetAdvFVal("GI6","GI6_DESCRI",xFilial("GI6")+aInput[1],1,""))
    dDtIni      := aInput[2]
    dDtFim      := aInput[3]

    aAdd(a754Inputs,{"AGENCIA",cAgencia})
    aAdd(a754Inputs,{"DESCAGENCI",cDescAge})
    aAdd(a754Inputs,{"DATAINI",dDtIni})
    aAdd(a754Inputs,{"DATAFIM",dDtFim})

Return()
