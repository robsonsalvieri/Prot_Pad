#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDropVF

Funcao para remover os campos virtuais criados no banco de dados 
pela execucao da rotina TAFCrteTab antes de junho de 2022.
Com a lib de novembro de 2024 passando a validar esse contexto, 
eh necessario executar essa rotina para o saneamento das tabelas

Posteriormente (release 12.1.2510) essa rotina pode ser excluida.

@Author	Evandro Oliviera
@Since		30/01/2025
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TafDropVF() 

    Local aTables           as Array
    Local cTableAC          as Character 
    Local nX                as Numeric 

    TafConout('Rotina ' + ProcName() + ' Iniciada.')

    If GetRpoRelease() < '12.1.2210'
        TafConout("Release de dicionario nao homologado para execucao da rotina" + ProcName())
        Return Nil 
    EndIf

    aTables := getTablesAC()

    For nX := 1 to Len(aTables)

        cTableAC := aTables[nX][1]
        alterTable(cTableAC,aTables[nX][2]) 
    Next nX 

    aSize(aTables,0)
    aTables := Nil 

    TafConout('Rotina ' + ProcName() + ' Finalizada. ')

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} alterTable

Realiza um ALTER TABLE no banco de dados utilizando a função TCALTER.

@param cTableAC - Codigo da Tabela
@param aFieldsV - Array de Campos Virtuais vinculados a tabela

@return Nil

@Author	Evandro Oliviera
@Since		01/02/2025
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function alterTable(cTableAC,aFieldsV) 

    Local aStruct  as Array
    Local aNewStru as Array
    Local nTopErr  as Numeric
    Local nX       as Numeric 
    Local nPos     as Numeric  
    Local lDrop    as Logical
    Local cMessage as Character

    nTopErr := 0

    dbSelectArea(cTableAC)
    aStruct := DBStruct()
    (cTableAC)->(dbCloseArea())

    aNewStru := aClone(aStruct)

    For nX := 1 to Len(aFieldsV)

        nPos := aScan( aNewStru, {|f| f[1] == AllTrim(aFieldsV[nX]) }) 
    	
        If nPos > 0
            aDel(aNewStru,nPos)
            aSize(aNewStru,Len(aNewStru)-1)
        EndIf 
    Next nX

    lDrop := TCAlter(RetSqlName(cTableAC),aStruct,aNewStru, @nTopErr)

    cMessage := IIf(lDrop,cTableAC + " Alterada com sucesso! ","Erro ao alterar a tabela " + cTableAC + " - " + TCSQLError())
    TafConout(cMessage)

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTablesAC

Retorna uma lista de tabelas autocontidas que possuem campos virtuais.
Na mesma lista, em um nivel hierarquico inferior, sao inclui­dos os 
respectivos campos virtuais de cada tabela.

@return aTables - Array de tabelas e campos
aTables[x][1] - Tabela 
aTables[x][2][x] - Campos Virtuais 

@Author	Evandro Oliviera
@Since		30/01/2025
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function getTablesAC()

    Local cSql      as Character
    Local cAuxTable as Character 
    Local cAlias    as Character 
    Local oSX3      as Object
    Local aFields   as Array
    Local aTables   as Array


    cSql := "SELECT X3_CAMPO, X3_ARQUIVO "
    cSql += " FROM " + MPSysSqlName("SX3") 
    cSql += " WHERE X3_ARQUIVO IN " 
    cSql += "("
    cSql += " SELECT T2U_CODIGO FROM " 
    cSql += RetSqlName("T2U") 
    cSql += " WHERE T2U_FILIAL = ? "
    cSql += " AND D_E_L_E_T_ = ? "
    cSql += ")"
    cSql += " AND X3_CONTEXT = ? "
    cSql += " AND D_E_L_E_T_ = ? "

    cSql := ChangeQuery(cSql)
    oSX3 := FwExecStatement():New(cSql)

    oSX3:SetString(1, xFilial("T2U"))
    oSX3:SetString(2, ' ')
    oSX3:SetString(3, 'V')
    oSX3:SetString(4, ' ')

    cAlias      := oSx3:OpenAlias()
    aFields     := {}
    aTables     := {}
    cAuxTable   := ""

    cAuxTable := AllTrim((cAlias)->X3_ARQUIVO)

    While (cAlias)->(!Eof())

        If !(AllTrim((cAlias)->X3_ARQUIVO) == cAuxTable) 
            If Len(aFields) > 0
                aAdd(aTables,{cAuxTable,AClone(aFields)})
                aSize(aFields,0)
            EndIf 
        EndIf 

        cAuxTable := AllTrim((cAlias)->X3_ARQUIVO) 
        aAdd(aFields,AllTrim((cAlias)->X3_CAMPO) )   
        (cAlias)->(dbSkip())
    EndDo

    If Len(aFields) > 0
        aAdd(aTables,{cAuxTable,AClone(aFields)})
        aSize(aFields,0)
    EndIf 

    (cAlias)->(dbCloseArea())

    oSX3:Destroy()
    oSX3    := Nil 
    aFields := Nil 

Return aTables
