#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU015A.CH'

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel   := Nil
Local oStruH7P := FwFormStruct(1,'H7P')
Local bFieldTrig := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bPosValid  := {|oModel| GU015PosVld(oModel)}
Local bCommit    := {|oModel| GU015ACommit(oModel)}

oStruH7P:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oStruH7P:AddTrigger("H7P_CODH7M" ,"H7P_CODH7M" ,{||.T.}, bFieldTrig)

oModel := MPFormModel():New('GTPU015', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)

oModel:AddFields('H7PMASTER',/*cOwner*/,oStruH7P)

oModel:SetDescription(STR0002) // "Fechamento de Caixa"
oModel:GetModel('H7PMASTER'):SetDescription(STR0002) // "Fechamento de Caixa"

oModel:GetModel( 'H7PMASTER'):SetOnlyQuery(.T.)

oModel:SetCommit(bCommit)
		
Return oModel

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel	:= FWLoadModel('GTPU015A')
    Local oView		:= FwFormView():New()
    Local oStruH7PH	:= FwFormStruct(2, 'H7P',{|x| AllTrim(x) $ 'H7P_DTFECH|H7P_CODH7M|H7P_DSCH7M|'})

    oView:SetModel(oModel)

    oView:SetDescription(STR0002) // "Fechamento de Caixa"

    oView:AddField('VIEW_HEADER', oStruH7PH, 'H7PMASTER')

    oView:showInsertMsg(.F.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}FieldTrigger()
 
@type static function
@version 12.1.2310
@author flavio.martins
@since 03/06/2024
@return oView, return_type, return_description
@param oModel, object
/*/
//-------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

    Default oMdl    := Nil
    Default cField  := ""
    Default uVal    := ""

    If cField == 'H7P_CODH7M'
        oMdl:SetValue("H7P_DSCH7M", Posicione('H7M',1,xFilial('H7M')+uVal,'H7M_DESC'))
    Endif

Return uVal

//-------------------------------------------------------------------
/*/{Protheus.doc} GU015PosVld(oModel)
 
@type static function
@version 12.1.2310
@author flavio.martins
@since 03/06/2024
@return oView, return_type, return_description
@param oModel, object
/*/
//-------------------------------------------------------------------
Static Function GU015PosVld(oModel)
    Local lRet := .T.


    H7P->(dbSetOrder(2))

    If H7P->(dbSeek(xFilial('H7P')+oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M')+;
                        DtoS(oModel:GetModel('H7PMASTER'):GetValue('H7P_DTFECH'))))
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"PosValid", STR0003,, STR0004) //"Já existe um caixa com os parâmetros informados", "Verifique os parâmetros informados"
    Endif

    If H7P->(dbSeek(xFilial('H7P')+oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M'))) .And. ;
            !H7P->(dbSeek(xFilial('H7P')+oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M')+;
            DtoS(oModel:GetModel('H7PMASTER'):GetValue('H7P_DTFECH')-1)))
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"PosValid", STR0009,, STR0004) //"Não localizado caixa na data anterior", "Verifique os parâmetros informados"
    Endif    

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GU015ACommit(oModel)
 
@type static function
@version 12.1.2310
@author flavio.martins
@since 03/06/2024
@return oView, return_type, return_description
@param oModel, object
/*/
//-------------------------------------------------------------------
Static Function GU015ACommit(oModel)
    Local oMdlH7P   := Nil
    Local cCodLocal := oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M')
    Local dDataFech := oModel:GetModel('H7PMASTER'):GetValue('H7P_DTFECH')    
    Local aRecDesp := RetRecDes(DtoS(dDataFech), cCodLocal)   
    Local nX        := 0
    Local lLoad     := (ValType(aRecDesp) == "A" .And. len(aRecDesp)>0) 
    Local nTotalRec := 0
    Local nTotalDes := 0

    If GTPUVldAut(cCodLocal, 'GTPU015')

        oMdlH7P := FwLoadModel('GTPU015')
        oMdlH7P:SetOperation(MODEL_OPERATION_INSERT)
        oMdlH7P:Activate();

        oMdlH7P:SetValue('H7PMASTER','H7P_CODH7M', cCodLocal)
        oMdlH7P:SetValue('H7PMASTER','H7P_DTFECH', dDataFech)
        oMdlH7P:SetValue('H7PMASTER','H7P_STATUS', '1')
        oMdlH7P:SetValue('H7PMASTER','H7P_SLDANT', GU15RetSld(cCodLocal, DtoS(dDataFech)))
        oMdlH7P:SetValue("H7QDESPESA","H7Q_VALOR"  , 0)

        If lLoad // Só faz o Load se popular as receitas e despesas, o que garante que a prestação foi totalizada.
            For nX := 1 To Len(aRecDesp)

                If aRecDesp[nX][4] == '1'
                    If !Empty( oMdlH7P:GetModel('H7QRECEITA'):GetValue('H7Q_CODH7O'))
                        oMdlH7P:GetModel('H7QRECEITA'):AddLine()
                    EndIf
                    oMdlH7P:LoadValue("H7QRECEITA","H7Q_CODIGO"  , GetSXENum("H7Q","H7Q_CODIGO"))
                    oMdlH7P:LoadValue("H7QRECEITA","H7Q_CODH7O"  , aRecDesp[nX][1])
                    oMdlH7P:LoadValue("H7QRECEITA","H7Q_DSCH7O"  , aRecDesp[nX][2])
                    oMdlH7P:LoadValue("H7QRECEITA","H7Q_VALOR"   , aRecDesp[nX][3])
                    oMdlH7P:LoadValue("H7QRECEITA","H7Q_TIPO"    , aRecDesp[nX][4])
                    If H7Q->(FieldPos("H7Q_TPLINH")) > 0
                        oMdlH7P:SetValue("H7QRECEITA","H7Q_TPLINH"   , aRecDesp[nX][5]) 
                    Endif
                    nTotalRec += aRecDesp[nX][3]

                Else

                    If !Empty( oMdlH7P:GetModel('H7QDESPESA'):GetValue('H7Q_CODH7O'))
                        oMdlH7P:GetModel('H7QDESPESA'):AddLine()
                    EndIf        
                    oMdlH7P:LoadValue("H7QDESPESA","H7Q_CODIGO"  , GetSXENum("H7Q","H7Q_CODIGO"))
                    oMdlH7P:LoadValue("H7QDESPESA","H7Q_CODH7O"  , ALLTRIM(aRecDesp[nX][1]))
                    oMdlH7P:LoadValue("H7QDESPESA","H7Q_DSCH7O"  , ALLTRIM(aRecDesp[nX][2]))
                    oMdlH7P:LoadValue("H7QDESPESA","H7Q_VALOR"   , aRecDesp[nX][3])
                    oMdlH7P:LoadValue("H7QDESPESA","H7Q_TIPO"    , aRecDesp[nX][4])
                    If H7Q->(FieldPos("H7Q_TPLINH")) > 0
                        oMdlH7P:SetValue("H7QDESPESA","H7Q_TPLINH"   , aRecDesp[nX][5])
                    Endif
                    nTotalDes += aRecDesp[nX][3]

                EndIf

            Next       
            oMdlH7P:GetModel():GetModel('H7PMASTER'):LoadValue('H7P_TOTREC', nTotalRec)
            oMdlH7P:GetModel():GetModel('H7PMASTER'):LoadValue('H7P_TOTDES', nTotalDes)

            oMdlH7P:GetModel('H7QRECEITA'):GoLine(1)
            oMdlH7P:GetModel('H7QDESPESA'):GoLine(1)
        
        EndIf

        FwExecView(STR0002, "VIEWDEF.GTPU015", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oMdlH7P) // "Fechamento do Caixa",

    Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RetRecDes
 
@type static function
@version 12.1.2310
@author Yuri Porto
@since 6/24/2024
@param oModel, object
/*/
//-------------------------------------------------------------------
Static Function RetRecDes(cdata, cLocal)
    Local aRet       := {}
    Local aPedagio   := {}
    Local cAliasProd := GetNextAlias() 
    Local cAliasRec  := GetNextAlias()
    Local cQryH7L    := ""  
    Local cQryRec    := ""
    Local cTipo      := ""  
    Local nPos       := 0
    Local nPosPed    := 0
    Local nTotal     := 0
    Local nX         := 0

    Default cdata  := ""
    Default cLocal := ""
   
    cQryH7L	:= " SELECT H7O.H7O_CODIGO COD ,    "
    cQryH7L	+=        " H7O.H7O_DESCRI DESCRI , "
    cQryH7L	+=        " SUM(H7L_VLRTOT) TOTAL,  "
    cQryH7L	+=        " SUM(H7L_PEDAGI) PEDAGIO,"
    cQryH7L	+=        " H7O.H7O_TIPO TIPO,      "
    cQryH7L	+=        " H7O.H7O_AGLUTI AGLUTI,  "
	cQryH7L	+=        " H7O.H7O_CODRD  CODRD,   "
    cQryH7L	+=        " H6R.H6R_TIPO   TPH6R,   "
    cQryH7L	+=        " H6V.H6V_TPLINH TPLIN    "
    cQryH7L	+= " FROM " + RetSqlName("H7L") + " H7L "
    cQryH7L	+= " INNER JOIN " + RetSqlName("H7I") + " H7I "
    cQryH7L	+=     " ON H7L_FILIAL = H7I_FILIAL "
    cQryH7L	+=        " AND H7L_CODIGO = H7I_CODIGO "
    cQryH7L	+=        " AND H7I.H7I_DATREF = '" + cdata + "'" 
    cQryH7L	+=        " AND H7I.H7I_LOCARR = '" + cLocal + "'"
    cQryH7L	+=        " AND H7I_STATUS = '2' " // Concluido - Prestação conferida
    cQryH7L	+=        " AND H7I.D_E_L_E_T_ = ' ' "

    cQryH7L += " INNER JOIN " + RetSqlName("H7J") + " H7J "
    cQryH7L +=     " ON H7J.H7J_FILIAL = H7L.H7L_FILIAL "
    cQryH7L +=      " AND H7J.H7J_CODIGO = H7L.H7L_CODIGO "
    cQryH7L +=      " AND H7J.H7J_SERVIC = H7L.H7L_SERVIC "
    cQryH7L +=      " AND H7J.D_E_L_E_T_ = ' ' "
    cQryH7L += " INNER JOIN " + RetSqlName("H6V") + " H6V "
    cQryH7L +=      " ON H6V.H6V_FILIAL = '" + xFilial("H6V") + "' "
    cQryH7L +=      " AND H6V.H6V_CODIGO = H7J.H7J_CODH6V "
    cQryH7L +=      " AND H6V.D_E_L_E_T_ = ' ' "

    cQryH7L	+= " LEFT JOIN " + RetSqlName("H6R") + " H6R "
    cQryH7L	+=     " ON H6R_FILIAL = '" + xFilial("H6R") + "'"
    cQryH7L	+=        " AND H6R_CODIGO = H7L_TPAGAM "
    cQryH7L	+=        " AND H6R.D_E_L_E_T_ = ' ' "
    cQryH7L	+= " LEFT JOIN " + RetSqlName("H7O") + " H7O "
    cQryH7L	+=     " ON H7O_FILIAL =  '" + xFilial("H7O") + "'"   
    cQryH7L	+=        " AND H7O_CODIGO = H6R_CODH7O "
    cQryH7L	+=        " AND H7O.D_E_L_E_T_ = ' ' "
    cQryH7L	+= " WHERE H7L.H7L_FILIAL = '" + xFilial("H7L") + "'"       
    cQryH7L	+=   " AND H7L.D_E_L_E_T_ = ' '"
    cQryH7L	+= " GROUP BY H7O_CODIGO, H7O_DESCRI, H7O_TIPO, H7O_AGLUTI, H7O_CODRD, H6R.H6R_TIPO, H6V.H6V_TPLINH "
   
    cQryH7L := ChangeQuery(cQryH7L)  

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryH7L), cAliasProd, .F., .T.)

    While (cAliasProd)->(!EOF())

        If (cAliasProd)->TOTAL > 0 .And. !Empty((cAliasProd)->COD) 

            If (cAliasProd)->PEDAGIO > 0
                
                nPosPed := aScan(aPedagio, {|x| x[2] == (cAliasProd)->TPLIN})
                If nPosPed > 0
                    aPedagio[nPosPed][1] += (cAliasProd)->PEDAGIO 
                Else
                    AAdd(aPedagio,{(cAliasProd)->PEDAGIO, (cAliasProd)->TPLIN})
                EndIf                                
                
            EndIf
           
            If (cAliasProd)->AGLUTI = 'T' 

                nPos := aScan(aRet, {|x| x[1] == (cAliasProd)->CODRD})
                If nPos > 0
                    nTotal := IIf ((cAliasProd)->H7O_TIPO == '1', ((cAliasProd)->TOTAL - (cAliasProd)->PEDAGIO) , (cAliasProd)->TOTAL )
                    aRet[nPos][3] += nTotal 
                Else
                    H7O->( DbSetOrder(1) )
                    If H7O->( DbSeek(xFilial("H7O") + (cAliasProd)->CODRD))
                        nTotal := IIf (H7O->H7O_TIPO == '1', ((cAliasProd)->TOTAL - (cAliasProd)->PEDAGIO) , (cAliasProd)->TOTAL )                        
                        AAdd(aRet, { H7O->H7O_CODIGO,  H7O->H7O_DESCRI , nTotal, H7O->H7O_TIPO, (cAliasProd)->TPLIN})
                    EndIf
                EndIf

                If (cAliasProd)->TIPO == '3' .And. !Empty((cAliasProd)->TPH6R)     
                    nTotal := IIf ( (cAliasProd)->TPH6R == '1', ((cAliasProd)->TOTAL - (cAliasProd)->PEDAGIO) , (cAliasProd)->TOTAL )               
                    AAdd(aRet, {(cAliasProd)->COD,  (cAliasProd)->DESCRI, nTotal, (cAliasProd)->TPH6R, (cAliasProd)->TPLIN})
                EndIf

            ElseIf (cAliasProd)->AGLUTI = 'F'

                cTipo  := Iif(!Empty((cAliasProd)->TPH6R), (cAliasProd)->TPH6R , (cAliasProd)->TIPO)
                nTotal := IIf ( cTipo == '1', ((cAliasProd)->TOTAL - (cAliasProd)->PEDAGIO) , (cAliasProd)->TOTAL ) 
                AAdd(aRet, {(cAliasProd)->COD,  (cAliasProd)->DESCRI, nTotal, cTipo, (cAliasProd)->TPLIN})

            EndIf 

        EndIf

        (cAliasProd)->(dbSkip())    

    EndDo

    If len(aPedagio) > 0

        cQryRec := " SELECT H7O_CODIGO, H7O_DESCRI, H7O_TIPO "
        cQryRec += " FROM " + RetSqlName("H7O") + " H7O "
        cQryRec += " WHERE H7O_FILIAL = '" + xFilial("H7O") + "'"
        cQryRec +=       " AND H7O_DESCRI = 'PEDAGIO' " 
        cQryRec +=       " AND H7O.D_E_L_E_T_ = '' "

        dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryRec), cAliasRec, .T., .T.)
        
        If !(cAliasRec)->(Eof())        
       
            For nX := 1 To Len(aPedagio)
                AAdd(aRet, {(cAliasRec)->H7O_CODIGO, (cAliasRec)->H7O_DESCRI, aPedagio[nX][1], (cAliasRec)->H7O_TIPO, aPedagio[nX][2]})
            Next

        EndIf

        (cAliasRec)->(dbClosearea())

    EndIf

    (cAliasProd)->(dbClosearea())

Return aRet
