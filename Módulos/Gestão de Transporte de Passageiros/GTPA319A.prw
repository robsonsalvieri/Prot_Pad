#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA319A.CH'

/*/{Protheus.doc} GTPA319A
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA319A(oModel)
Private oMdlG6R  := oModel:GetModel('GRID')
Private dDtIda   := oMdlG6R:GetValue('G6R_DTIDA')
Private cLocOri  := oMdlG6R:GetValue('G6R_LOCORI')   

FwExecView(STR0001, "VIEWDEF.GTPA319A", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, 5,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) // "Recursos Disponíveis"

Return

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruCol	:= FwFormModelStruct():New() 
Local oStruVei	:= FwFormModelStruct():New() 
Local bLoad		:= {|oModel| G319ABLoad(oModel)}

oModel := MPFormModel():New("GTPA319A",/*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStru(oStruCab, oStruCol, oStruVei)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRIDCOL", "HEADER", oStruCol,,,,, bLoad)
oModel:AddGrid("GRIDVEI", "HEADER", oStruVei,,,,, bLoad)

oModel:SetDescription(STR0001) // "Recursos Disponíveis")
oModel:GetModel("HEADER"):SetDescription("Header")
oModel:GetModel("GRIDCOL"):SetDescription(STR0002) // "Colaboradores"
oModel:GetModel("GRIDVEI"):SetDescription(STR0003) // "Veículos"
oModel:SetPrimaryKey({})

oModel:GetModel("GRIDCOL"):SetMaxLine(99999)	
oModel:GetModel("GRIDVEI"):SetMaxLine(99999)	

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel("GTPA319A")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruCol 	:= FwFormViewStruct():New()
Local oStruVei 	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FwFormView():New()

SetViewStru(oStruCab, oStruCol, oStruVei)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0001) //"Recursos Disponíveis"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddGrid('VIEW_GRIDCOL', oStruCol, 'GRIDCOL')
oView:AddGrid('VIEW_GRIDVEI', oStruVei, 'GRIDVEI')

oView:CreateHorizontalBox('HEADER', 35)
oView:CreateHorizontalBox('GRIDS' , 65)

oView:CreateVerticalBox('GRIDCOL',49,'GRIDS')
oView:CreateVerticalBox('BOXSEP' ,02,'GRIDS')
oView:CreateVerticalBox('GRIDVEI',49,'GRIDS')

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRIDCOL','GRIDCOL')
oView:SetOwnerView('VIEW_GRIDVEI','GRIDVEI')

oView:EnableTitleView("VIEW_HEADER" , STR0004)  // "Dados do Contrato"
oView:EnableTitleView("VIEW_GRIDCOL", STR0002)  // "Colaboradores"	
oView:EnableTitleView("VIEW_GRIDVEI", STR0003)  // "Veículos"

oView:GetViewObj("VIEW_GRIDCOL")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRIDCOL")[3]:SetFilter(.T.)
oView:GetViewObj("VIEW_GRIDVEI")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRIDVEI")[3]:SetFilter(.T.)

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruCab, oStruCol, oStruVei)

oStruCab:AddTable("   ",{" "}," ")
oStruCab:AddField(STR0005, STR0005, "G6R_CODIGO" ,"C", TamSx3('G6R_CODIGO')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Código"
oStruCab:AddField(STR0006, STR0006, "G6R_NROPOR" ,"C", TamSx3('G6R_NROPOR')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Oportunidade"
oStruCab:AddField(STR0007, STR0007, "G6R_SA3COD" ,"C", TamSx3('G6R_SA3COD')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Cód. Vendedor"
oStruCab:AddField(STR0008, STR0008, "G6R_SA3DES" ,"C", TamSx3('G6R_SA3DES')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Des. Vendedor"
oStruCab:AddField(STR0009, STR0009, "G6R_LOCORI" ,"C", TamSx3('G6R_LOCORI')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Cód. Origem"
oStruCab:AddField(STR0010, STR0010, "G6R_DESORI" ,"C", TamSx3('G6R_DESORI')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Desc. Origem"
oStruCab:AddField(STR0011, STR0011, "G6R_DTIDA"  ,"D", TamSx3('G6R_DTIDA')[1]  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Data Ida"
oStruCab:AddField(STR0012, STR0012, "G6R_HRIDA"  ,"C", TamSx3('G6R_HRIDA')[1]  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Hora Ida"
oStruCab:AddField(STR0013, STR0013, "G6R_QUANT"  ,"C", TamSx3('G6R_QUANT')[1]  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)     // "Qtd. Veiculo" 

oStruCol:AddField(STR0005, STR0005, "GYG_CODIGO" ,"C", TamSx3('GYG_CODIGO')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Código"
oStruCol:AddField(STR0014, STR0014, "GYG_FUNCIO" ,"C", TamSx3('GYG_FUNCIO')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Matricula"
oStruCol:AddField(STR0015, STR0015, "GYG_NOME"	 ,"C", TamSx3('GYG_NOME')[1]   ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		// "Nome"
oStruCol:AddField(STR0016, STR0016, "GYK_CODIGO" ,"C", TamSx3('GYK_CODIGO')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	    // "Cód. Tp. Rec."
oStruCol:AddField(STR0017, STR0017, "GYK_DESCRI" ,"C", TamSx3('GYK_DESCRI')[1] ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)	    // "Tipo Recurso" 

oStruVei:AddField(STR0005, STR0005, "T9_CODBEM"	 ,"C", TamSx3('T9_CODBEM')[1]  ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Código"
oStruVei:AddField(STR0015, STR0015, "T9_NOME"	 ,"C", TamSx3('T9_NOME')[1]    ,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)   	// "Nome"

Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruCol, oStruVei)

oStruCab:AddField("G6R_CODIGO","01",STR0005, STR0005,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Código"
oStruCab:AddField("G6R_NROPOR","02",STR0006, STR0006,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Oportunidade"
oStruCab:AddField("G6R_SA3COD","03",STR0007, STR0007,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Cód. Vendedor"
oStruCab:AddField("G6R_SA3DES","04",STR0008, STR0008,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Des. Vendedor"
oStruCab:AddField("G6R_LOCORI","05",STR0009, STR0009,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Cód. Origem"
oStruCab:AddField("G6R_DESORI","06",STR0010, STR0010,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Des. Origem"
oStruCab:AddField("G6R_DTIDA" ,"07",STR0011, STR0011,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Data Ida"
oStruCab:AddField("G6R_HRIDA" ,"08",STR0012, STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Hora Ida"
oStruCab:AddField("G6R_QUANT" ,"09",STR0013, STR0013,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Qtd. Veiculo"

oStruCol:AddField("GYG_CODIGO","01",STR0005, STR0005,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		// "Código"
oStruCol:AddField("GYG_FUNCIO","02",STR0014, STR0014,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    // "Matricula"
oStruCol:AddField("GYG_NOME"  ,"03",STR0015, STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Nome"
oStruCol:AddField("GYK_CODIGO","04",STR0016, STR0016,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    // "Cód. Tp. Rec."
oStruCol:AddField("GYK_DESCRI","05",STR0017, STR0017,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)     // "Tipo Recurso"

oStruVei:AddField("T9_CODBEM" ,"01",STR0005, STR0005,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    // "Código"
oStruVei:AddField("T9_NOME"	  ,"02",STR0015, STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	    // "Nome"

Return

/*/{Protheus.doc} G319ABLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G319ABLoad(oModel)
Local aLoad 	:= {}
Local aDados    := {}
Local aStruMdl  := {}
Local nX        := 0        

Local cAliasTmp := GetNextAlias()

If oModel:GetId() == 'HEADER'

    If oMdlG6R != Nil
        aStruMdl := oModel:GetStruct():GetFields()

        For nX := 1 To Len(aStruMdl)

            aAdd(aDados, oMdlG6R:GetValue(aStruMdl[nX][3]))

        Next

        aAdd(aLoad, aDados)
        aAdd(aLoad, 0) 

    Endif


ElseIf oModel:GetId() == 'GRIDCOL'

    BeginSql Alias cAliasTmp

        SELECT GYG.GYG_FILIAL,
            GYG.GYG_CODIGO,
            GYG.GYG_FUNCIO,
            GYG.GYG_FILSRA,
            GYG.GYG_NOME,
            GYK.GYK_CODIGO,
            GYK.GYK_DESCRI
        FROM %Table:GYG% GYG
        LEFT JOIN %Table:GYK% GYK ON GYK.GYK_FILIAL = %xFilial:GYK%
        AND GYK.GYK_CODIGO = GYG.GYG_RECCOD
        AND GYK.%NotDel%
        LEFT JOIN %Table:GQE% GQE ON GQE.GQE_FILIAL = %xFilial:GQE%
        AND GQE.GQE_TRECUR = '1'
        AND GQE.GQE_RECURS = GYG.GYG_CODIGO
        AND GQE.GQE_DTREF <> %Exp:dDtIda%
        AND GQE.%NotDel%
        LEFT JOIN %Table:GY2% GY2 ON GY2.GY2_FILIAL = %xFilial:GY2%
        AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
        AND GY2.%NotDel%
        LEFT JOIN %Table:GY1% GY1 ON GY1.GY1_FILIAL = %xFilial:GY1%
        AND GY1.GY1_SETOR = GY2.GY2_SETOR
        AND GY1.%NotDel%
        LEFT JOIN %Table:GQK% GQK ON GQK.GQK_FILIAL = %xFilial:GQK%
        AND GQK.GQK_RECURS = GYG.GYG_CODIGO
        AND GQK.%NotDel%
        WHERE GYG_FILIAL = %xFilial:GYG%
        AND (GY1.GY1_LOCAL = %Exp:cLocOri%
            OR GY1.GY1_LOCAL IS NULL)
        AND (GQK.GQK_DTREF <> %Exp:dDtIda%
            OR GQK.GQK_DTREF IS NULL)
        AND GYG.%NotDel%
        GROUP BY GYG.GYG_FILIAL,
                GYG.GYG_CODIGO,
                GYG.GYG_FUNCIO,
                GYG.GYG_FILSRA,
                GYG.GYG_NOME,
                GYK.GYK_CODIGO,
                GYK.GYK_DESCRI                

    EndSql

    While (cAliasTmp)->(!Eof())

        If Ga409xColD((cAliasTmp)->GYG_CODIGO, .F.) .And.;
            !(Ga409xColFer((cAliasTmp)->GYG_FILSRA,(cAliasTmp)->GYG_FUNCIO, dDtIda)) .And.;
            !(GtpVldAfastmt((cAliasTmp)->GYG_FILSRA,(cAliasTmp)->GYG_FUNCIO, dDtIda))

            aAdd(aLoad,{0,{(cAliasTmp)->GYG_CODIGO, (cAliasTmp)->GYG_FUNCIO,;
                           (cAliasTmp)->GYG_NOME, (cAliasTmp)->GYK_CODIGO,;
                           (cAliasTmp)->GYK_DESCRI}})

        Endif

        (cAliasTmp)->(dbSkip())

    EndDo

    (cAliasTmp)->(dbCloseArea())

ElseIf oModel:GetId() == 'GRIDVEI'

    BeginSql Alias cAliasTmp

        SELECT ST9.T9_CODBEM,
               ST9.T9_NOME
        FROM %Table:ST9% ST9
        LEFT JOIN %Table:GQE% GQE ON GQE.GQE_FILIAL = %xFilial:GQE%
        AND GQE.GQE_TRECUR = '2'
        AND GQE.GQE_RECURS = ST9.T9_CODBEM
        AND GQE.GQE_DTREF <> %Exp:dDtIda%
        AND GQE.%NotDel%
        LEFT JOIN %Table:GYU% GYU ON GYU.GYU_FILIAL = %xFilial:GYU%
        AND GYU.GYU_CODVEI = ST9.T9_CODBEM
        AND GYU.%NotDel%
        LEFT JOIN %Table:GY1% GY1 ON GY1.GY1_FILIAL = %xFilial:GY1%
        AND GY1.GY1_SETOR = GYU.GYU_CODSET
        AND GY1.%NotDel%
        WHERE ST9.T9_FILIAL = %xFilial:ST9%
          AND ST9.T9_CATBEM IN('2','4')
          AND (GY1.GY1_LOCAL = %Exp:cLocOri%
               OR GY1.GY1_LOCAL IS NULL)
          AND ST9.%NotDel%
        GROUP BY ST9.T9_CODBEM,
                 ST9.T9_NOME    

    EndSql
        
    While (cAliasTmp)->(!Eof())

        aAdd(aLoad,{0,{(cAliasTmp)->T9_CODBEM, (cAliasTmp)->T9_NOME}})

        (cAliasTmp)->(dbSkip())

    EndDo

    (cAliasTmp)->(dbCloseArea())

Endif

Return aLoad
