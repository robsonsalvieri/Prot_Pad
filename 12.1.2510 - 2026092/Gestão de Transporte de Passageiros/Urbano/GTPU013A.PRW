#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPU013A.CH"
 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU013
Prestação de Contas

@type function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/21/2024
/*/
//-------------------------------------------------------------------
Function GTPU013A(oModel)

    Local aColumns      := {}
    Local aCampos       := { "H7G_CODH6V","H6V_CODLIN", "H6V_PREFIX", "H6V_DESCRI", "H7G_HRINIC", "H7G_HRFINA", 'H7F_CODH76', 'H76_DESCRI', 'H7G_CODH70'}    
    Local cAliasH7J     := GetNextAlias()
    Local cQryH7F       := ""
    Local cTitulo       := "Carrega Serviços" //"Serviços"    
    Local nSuperior     := 0
    Local nEsquerda     := 0
	Local nInferior     := GetScreenRes()[2] * 0.6
	Local nDireita      := GetScreenRes()[1] * 0.65
    Local oMdl          := oModel:GetModel()
    Local oModelH7I     := oMdl:GetModel("H7IMASTER") 
    Local oDlgEscTela   := Nil
    Local oMrkBrowse       := Nil
    

	    
    cQryH7F := GTPQryServ(oModelH7I)
	
    DEFINE MSDIALOG oDlgEscTela TITLE cTitulo FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Carrega Serviços"

	oMrkBrowse := FWMarkBrowse():New()
	oMrkBrowse:SetOwner(oDlgEscTela)
	oMrkBrowse:SetDataQuery(.T.)
	oMrkBrowse:SetAlias(cAliasH7J)
	oMrkBrowse:SetQuery(cQryH7F)
	oMrkBrowse:SetDescription(cTitulo) //"Carrega Serviços"
    oMrkBrowse:SetFieldMark( 'H7I_LOADOP' )
    
	oMrkBrowse:SetMenuDef("")
    oMrkBrowse:DisableDetails()
    aColumns := GTPColsF3(aCampos, @oMrkBrowse)
	oMrkBrowse:SetColumns(aColumns)

	oMrkBrowse:AddButton( OemTOAnsi("Confirmar"), {|| cRetF3  :=  GTP013ALoad(oMrkBrowse, oModel), lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
	oMrkBrowse:AddButton( OemTOAnsi("Cancelar"),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"	
	oMrkBrowse:DisableDetails()

	oMrkBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED
   
    
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPQryServ
Query com os serviços do motorista

@type function
@version 12.1.2310
@author Karyna Martins
@since 13/12/2024
/*/
//-------------------------------------------------------------------
Static Function GTPQryServ(oModelH7I)    

    Local cQryH7F   := "" 
    Local cMotori   := oModelH7I:GetValue("H7I_MOTORI")     

    cQryH7F	:= " SELECT H7I_LOADOP, "
    cQryH7F	+=        " H7G_CODH6V, "
	cQryH7F	+=        " H6V_CODLIN, "
	cQryH7F	+=        " H6V_PREFIX, "
	cQryH7F	+=        " H6V_DESCRI, "
    cQryH7F	+=        " MIN(H7G_HRINIC) H7G_HRINIC,"
    cQryH7F	+=        " MAX(H7G_HRFINA) H7G_HRFINA,"
    cQryH7F	+=        " H7F_CODH76, "
	cQryH7F	+=        " H76_DESCRI, "      
	cQryH7F	+=        " H7G_CODH70  "  
    cQryH7F	+= " FROM " + RetSqlName("H7F") + " H7F "
    cQryH7F +=        " LEFT JOIN " + RetSqlName("H7I") + " H7I "
	cQryH7F +=                " ON (H7I.H7I_FILIAL = '" + xFilial("H7I") + "'"
	cQryH7F +=                     " AND H7I.H7I_MOTORI = '" + cMotori + "'"
	cQryH7F +=                     " AND H7I.H7I_DTSERV = '" + DTOS(oModelH7I:GetValue("H7I_DTSERV")) + "'"  
    cQryH7F +=                     " AND H7I.D_E_L_E_T_ = ' ' ) "
    cQryH7F +=        " INNER JOIN " + RetSqlName("H7G") + " H7G "
    cQryH7F +=                " ON ( H7G.H7G_FILIAL = H7F.H7F_FILIAL "
    cQryH7F +=                     " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO "
    cQryH7F +=                     " AND H7G.H7G_CODGYG = '" + cMotori + "'"
    cQryH7F +=                     " AND H7G_CODH76 NOT IN (SELECT H7J_ESCALA "
    cQryH7F +=                                             "FROM " + RetSqlName("H7J") + " H7J "
    cQryH7F +=                                              " INNER JOIN " + RetSqlName("H7I") + " H7I "
	cQryH7F +=                                                      " ON (H7I.H7I_FILIAL = '" + xFilial("H7I") + "'"
	cQryH7F +=                                                          " AND H7I.H7I_MOTORI = '" + cMotori + "'"
	cQryH7F +=                                                          " AND H7I.H7I_DTSERV = '" + DTOS(oModelH7I:GetValue("H7I_DTSERV")) + "'"  
    cQryH7F +=                                                          " AND H7I.D_E_L_E_T_ = ' ' ) "
    cQryH7F +=                                              "WHERE H7J.H7J_FILIAL = H7I.H7I_FILIAL "
    cQryH7F +=                                                   " AND H7J.H7J_CODIGO = H7I.H7I_CODIGO "
	cQryH7F +=                                                   " AND H7J.H7J_CODH6V = H7G.H7G_CODH6V "
	cQryH7F +=                                                   " AND H7J.H7J_ESCALA = H7F.H7F_CODH76 "
	cQryH7F +=                                                   " AND H7J.D_E_L_E_T_ = ' ') "
    cQryH7F +=                     " AND H7G_TIPO  = '7'"
    cQryH7F +=                     " AND H7G.D_E_L_E_T_ = ' ')"
    cQryH7F +=        " INNER JOIN " + RetSqlName("H76") + " H76 "
	cQryH7F +=                " ON ( H76.H76_FILIAL = '" + xFilial("H76") + "'"
	cQryH7F +=                     " AND H76.H76_CODIGO = H7F_CODH76
	cQryH7F +=                     " AND H76.D_E_L_E_T_ = ' ')
    cQryH7F +=        " INNER JOIN " + RetSqlName("H6V") + " H6V ""
    cQryH7F +=                " ON ( H6V.H6V_FILIAL = '" + xFilial("H6V") + "'"
    cQryH7F +=                     " AND H6V.H6V_CODIGO = H7G_CODH6V "
    cQryH7F +=                     " AND H6V.D_E_L_E_T_ = ' ') "
    cQryH7F	+= " WHERE  H7F.H7F_FILIAL = '" + xFilial("H7F") + "'"
    cQryH7F	+=        " AND H7F.H7F_DATA = '" + DTOS(oModelH7I:GetValue("H7I_DTSERV")) + "'"    
    cQryH7F	+=        " AND H7F.D_E_L_E_T_ = ' ' "
    cQryH7F	+= " GROUP BY H7I_LOADOP, "
    cQryH7F	+=          " H7G_CODH6V, "
	cQryH7F	+=          " H6V_CODLIN, "
	cQryH7F	+=          " H6V_PREFIX, "
	cQryH7F	+=          " H6V_DESCRI, "
    cQryH7F	+=          " H7F_CODH76, "
	cQryH7F	+=          " H76_DESCRI, "        
	cQryH7F	+=          " H7G_CODH70 "
    cQryH7F	+=          " ORDER BY H7G_HRINIC, "
    cQryH7F	+=          " H7G_HRFINA "

    cQryH7F := ChangeQuery(cQryH7F)   

Return cQryH7F

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecColsF3

@description Tratamento dos campos que serão exibidos na tela
@param aFields, Array, Campos da consulta
@param oBrowse, Objeto, Browse pesquisa
@return aColumns, Array, Colunas da tela de consulta
@author Flavio Vicco
@since  04/07/2022
/*/
//--------------------------------------------------------------------------------
Static Function GTPColsF3(aFields, oBrowse)

    Local aColumns := {}
    Local aFwTam   := {}
    Local cField   := ""
    Local nLinha   := 0
    Local nZ       := 0

    For nZ := 1 To Len(aFields)
        cField := aFields[nZ]
        aFwTam := FWTamSX3(cField)    
        AAdd(aColumns,FWBrwColumn():New())
        nLinha := Len(aColumns)
          
        aColumns[nLinha]:SetType(aFwTam[3])
        aColumns[nLinha]:SetTitle(TecTituDes(cField,.T.))
        aColumns[nLinha]:SetSize(aFwTam[1])
        aColumns[nLinha]:SetDecimal(aFwTam[2])
        aColumns[nLinha]:SetPicture("@!")        
    
        aColumns[nLinha]:SetData(&("{||" + cField + "}"))

    Next nZ

Return(aColumns)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecColsF3

@description Tratamento dos campos que serão exibidos na tela
@param aFields, Array, Campos da consulta
@param oBrowse, Objeto, Browse pesquisa
@return aColumns, Array, Colunas da tela de consulta
@author Flavio Vicco
@since  04/07/2022
/*/
//--------------------------------------------------------------------------------
Static Function GTP013ALoad(oMrkBrowse, oModel)

    Local oMdl      := oModel:GetModel()
    Local oModelH7I := oMdl:GetModel("H7IMASTER")
    Local oModelH7J := oMdl:GetModel("H7JDETAIL")
    //Local oModelH7L := oMdl:GetModel("H7LDETAIL")
    Local cAliasH7F := oMrkBrowse:Alias()
    Local cMarca    := oMrkBrowse:Mark()
    Local cRet      := ""

    If !oModelH7J:IsEmpty()
        GTPxClearData(oModelH7J)        
    EndIf   

    (cAliasH7F)->(DbGoTop())
    While !(cAliasH7F)->(EoF())
        If oMrkBrowse:IsMark(cMarca)
            oModelH7I:SetValue("H7I_LOADOP", .T.)            

            If !Empty( oModelH7J:GetValue('H7J_SERVIC')) 
                oModelH7J:AddLine()
            EndIf

            oModelH7J:SetValue("H7J_SERVIC", GetSxEnum("H7J", "H7J_SERVIC") )  
            oModelH7J:LoadValue("H7J_CODH6V", (cAliasH7F)->H7G_CODH6V)  
            oModelH7J:LoadValue("H7J_PREFLI", POSICIONE("H6V", 1, xFilial("H6V") + (cAliasH7F)->H7G_CODH6V, "H6V_PREFIX"))
            oModelH7J:LoadValue("H7J_DESCLI", POSICIONE("H6V", 1, xFilial("H6V") + (cAliasH7F)->H7G_CODH6V, "H6V_DESCRI"))
            oModelH7J:SetValue("H7J_DATAIS", oModelH7I:GetValue("H7I_DTSERV"))
            oModelH7J:SetValue("H7J_DATATS", oModelH7I:GetValue("H7I_DTSERV"))
            oModelH7J:SetValue("H7J_HRINIS", PADR(StrTran((cAliasH7F)->H7G_HRINIC,":",""), TamSx3("H7J_HRINIS")[1],"0"))
            oModelH7J:SetValue("H7J_HRTERS", PADR(StrTran((cAliasH7F)->H7G_HRFINA ,":",""), TamSx3("H7J_HRTERS")[1],"0"))    
            oModelH7J:SetValue("H7J_VEICUL", (cAliasH7F)->H7G_CODH70)      
            oModelH7J:SetValue("H7J_ESCALA", (cAliasH7F)->H7F_CODH76 )      

        EndIf
        (cAliasH7F)->(DbSkip())
    EndDo

Return cRet
