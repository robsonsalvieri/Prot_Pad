#INCLUDE "TOTVS.CH"
#INCLUDE "RMICADAUXILIARESOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} pshExCaImp
Rotina para chamar a geração dos impostos em mult threads

Parametros recebidos pelo schedule
aParams[1] – Empresa associada ao agendamento da rotina;
aParams[2] – Filial associada ao agendamento da rotina;
aParams[3] – Usuário associado ao agendamento;
aParams[4] – Id do agendamento

Exemplo de parâmetros recebidos
aParams[1]:"T1"
aParams[2]:"D MG 01 "
aParams[3]:"000000"
aParams[4]:"000004000001"

@author  Rafael Tenorio da Costa
@since   08/12/2025
@type    function
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Function pshExCaImp(aParams)

    if existFunc("totvs.protheus.retail.rmi.servicos.carga.impostos.controle")
        totvs.protheus.retail.rmi.servicos.carga.impostos.controle(aParams)
    endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiCadAuxiliaresObj
Classe responsável pela manipulação dos Cadastros Auxiliares MIH

@type    method
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Class RmiCadAuxiliaresObj

    //Propridades referente a MIH
    Data cTipoCadastro  as Character
    Data cId            as Character
    Data cDescricao     as Character
    Data cAtivo         as Character
    Data jConfig        as Object

    //Layouts de Cadstros Auxiliares MIG
	Data aLayout        as Array

    //Armazena as filiais do cadastro auxiliar 
    Data aFiliais       as Array

    //Propridades referente a classe de relacionamento
    Data oRelaciona     as Object
    Data cFil           as Character
    Data cEntrada       as Character
    Data cTabEntradas   as Character    //Armazena o alias que contem os códigos de entradas(MIL_ENTRAD) que serão salvos na tabela de relacionamento MIL

    Data oHashMIG       as Object       //HashMap com os campos do cadastro auxiliare MIG Components
    Data oHashMIH       as Object       //HashMap com os cadastros auxiliares MIH já gerados para agilizar localização
    Data nTamTipCad     as Numeric
    Data nTamDesc       as Numeric

    Data oImpostos      as Object

    Data oMessageError  as Object

    Method New()
    Method Grava()
    Method Limpa()
    Method finaliza()                   //Metodo com os procedimentos para finalizar o objeto RmiCadAuxiliaresObj

    Method GetFiliais()
    Method SetFiliais(cFil)
    Method atualizaFilial(cFil)         //Atualiza a filial para processamento
    
    Method Carga()

    Method Impostos()
    Method ImpPorProd(cProduto)
    Method processaImpostos()           //Centraliza a geração dos impostos do produto corrente
    Method GeraImp()
    Method GetJson()

    Method getCampos()                  //Retorna os IdComponent do cadastros auxiliar

    Method Marcas()
    
    Method setDescricao()
    Method getDescricao()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@type    method
@return  RmiCadAuxiliaresObj, Retorna o proprio objeto
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method New(aFiliais) Class RmiCadAuxiliaresObj

    Default aFiliais    := {}

    self:cTipoCadastro  := ""
    self:cId            := ""
    self:cDescricao     := ""
    self:cAtivo         := "1"
    self:jConfig        := JsonObject():New()

    self:oRelaciona     := RmiRelacionaObj():New()
    self:cFil           := ""
    self:cEntrada       := ""
    self:cTabEntradas   := ""

    self:oHashMIG       := tHashMap():new()
    self:oHashMIH       := tHashMap():new()
    self:nTamTipCad     := tamSx3("MIH_TIPCAD")[1]
    self:nTamDesc       := tamSx3("MIH_DESC")[1]

    self:oImpostos      := Nil

    self:oMessageError  := LjMessageError():New()

    if len(aFiliais) > 0
        Self:aFiliais   := aClone(aFiliais)
    else
        Self:aFiliais   := Self:GetFiliais()
    endIf

    //Carrega o layout dos cadastros auxiliares MIG
    Self:aLayout        := LjLayAuxCg(.F.)

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Efetua a atualização do cadastro auxiliar MIH

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiCadAuxiliaresObj

    Local aArea     := GetArea()
    Local cTipCad   := PadR(self:cTipoCadastro, self:nTamTipCad) 
    Local cDescric  := PadR(self:getDescricao(), self:nTamDesc) 
    Local cChaveMIH := xFilial("MIH") + cTipCad + cDescric
    Local cIdMIH    := ""

    //Pega da memoria o ID do cadastro auxiliar MIH caso exista
    if !self:oHashMIH:get(cChaveMIH, @cIdMIH)

        //Semaforo para evitar concorrência na gravação do cadastro auxiliar MIH quando esta sendo processado em mult threads
        cSemaforo := "GRAVA_MIH_" + cChaveMIH
        while !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
            sleep(100)
        EndDo

        MIH->( DbSetOrder(4) )  //MIH_FILIAL, MIH_TIPCAD, MIH_DESC, R_E_C_N_O_, D_E_L_E_T_
        if MIH->( DbSeek( cChaveMIH ) )

            cIdMIH := MIH->MIH_ID
        else

            cIdMIH := criaVar("MIH_ID", .T.)

            ljGrvLog(/*cNumControl*/, "Novo cadastro auxiliar gerado na MIH:", {self:cTipoCadastro, cIdMIH, cDescric, self:jConfig})

            RecLock("MIH", .T.)

                MIH->MIH_FILIAL := xFilial("MIH")
                MIH->MIH_TIPCAD := self:cTipoCadastro
                MIH->MIH_ID     := cIdMIH
                MIH->MIH_DESC   := cDescric
                MIH->MIH_ATIVO  := self:cAtivo
                MIH->MIH_DATINC := CriaVar("MIH_DATINC", .T.)
                MIH->MIH_DATALT := CriaVar("MIH_DATALT", .T.)
                MIH->MIH_CONFIG := self:jConfig:ToJson()

            MIH->( MsUnLock() )

            confirmSx8()
        endIf

        //Seta na memoria o ID do cadastro auxiliar MIH
        if !self:oHashMIH:get(cChaveMIH, @cIdMIH)
            self:oHashMIH:set(cChaveMIH, cIdMIH)
        endIf

        UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
    endIf

    //Inclui o relacionamentos MIL
    //Replica relacionamento para tabela de entradas
    if !empty(self:cTabEntradas)

        (self:cTabEntradas)->( dbGoTop() )
        while !(self:cTabEntradas)->( eof() )

            self:oRelaciona:Inclui(self:cFil, (self:cTabEntradas)->ENTRADA, cIdMIH)
            
            (self:cTabEntradas)->( dbSkip() )
        endDo

    //Gera relacionamento para cada entrada
    else

        self:oRelaciona:Inclui(self:cFil, self:cEntrada, cIdMIH)
    endIf

    //Limpa o objeto de relacionamento e mensagens de erro        
    self:Limpa()

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Limpa
Prepara objeto para o proximo processamento.

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Limpa() Class RmiCadAuxiliaresObj

    self:cDescricao := ""

    self:oMessageError:ClearError()
    self:oRelaciona:Limpa()
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Carga
Centraliza as cargas de dados do cadastro auxiliar

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Carga() Class RmiCadAuxiliaresObj

    self:Impostos()
    Self:Marcas()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
Retorna as filiais com base no cadastro de lojas

@type    method   
@author  Bruno Almeida
@since   25/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GetFiliais() Class RmiCadAuxiliaresObj

    Local cTipoCad  := Padr("CADASTRO DE LOJA", self:nTamTipCad)
    Local aRet      := {} //Guarda as filiais
    Local cCodFil   := ""
    Local aArea     := GetArea()
    Local cSql      := ""
    Local aSql      := {}
    Local nI        := 0
    
    //Carrega as filiais
    cSql := "SELECT R_E_C_N_O_ REC FROM "+RetSqlName("MIH")+" WHERE D_E_L_E_T_ = ' ' AND MIH_TIPCAD = '" + cTipoCad + "' AND MIH_ATIVO IN ('1','3')"
    aSql := rmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

    If len(aSql) > 0

        For nI := 1 To Len(aSql)
            MIH->(DbGoTo( aSql[nI][1] ))
            //Retorna o conteúdo da TAG no campo MIH_CONFIG
            cCodFil := LjCAuxRet("IDFilialProtheus")

            If !Empty(cCodFil) .And. aScan( aRet, {|x| x == cCodFil} ) == 0
                Aadd(aRet, cCodFil)
            EndIf
                
        Next nI

    EndIf

    fwFreeArray(aSql)

    RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Impostos
Centraliza o processamento dos impostos

@type    method   
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Impostos(cFiltroImp, lImpGrupo) Class RmiCadAuxiliaresObj

    Local cBkpFilAnt    := cFilAnt
    Local nCont         := 0
    Local cAlias        := ""
    Local cQuery        := ""
    Local cFiltro       := ""

    Default cFiltroImp  := ""
    Default lImpGrupo   := .F.

    If Len(Self:aFiliais) == 0

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {"CADASTRO DE LOJA", STR0002}) )   //"Carga de impostos não será executada. As filiais não foram encontradas, verifique o #1 na rotina #2."    //"Cadastros Auxiliares"
    Else

        //Pega filtro do processo de produtos
        cFiltro := allTrim( posicione("MHN", 1, xFilial("MHN") + padR("PRODUTO", tamSx3("MHN_COD")[1]), "MHN_FILTRO") )

        //Processa as filiais
        For nCont:=1 To Len(Self:aFiliais)

            //Atualiza filial para processamento
            self:atualizaFilial(self:aFiliais[nCont])

            self:oImpostos := RmiImpostosObj():New()

            //Processa todos os produtos conforme filtro do processo MHN
            cQuery := " SELECT B1_COD AS ENTRADA"
            cQuery += " FROM " + retSqlName("SB1")
            cQuery += " WHERE D_E_L_E_T_ = ' '"
            cQuery +=   " AND  B1_FILIAL = '" + xFilial("SB1") + "'"

            //Insere filtro do processo de produtos
            If !Empty(cFiltro)
                cQuery += " AND " + cFiltro
            EndIf

            //Inclui filtro de impostos caso exista
            if !empty(cFiltroImp)
                cQuery += cFiltroImp
            endIf

            cQuery := ChangeQuery(cQuery)
            
            ljGrvLog(/*cNumControl*/, "Consulta que retorna produtos agrupados para geração de impostos:", cQuery)
            cAlias := mpSysOpenQuery(cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)

            //Calcula os impostos por grupo e replica o imposto para todos os produtos do grupo
            if lImpGrupo

                if !(cAlias)->( eof() )

                    if self:oImpostos:setProduto( (cAlias)->ENTRADA )

                        self:cEntrada     := ""
                        self:cTabEntradas := cAlias
                                    
                        self:oImpostos:Calcula()

                        self:processaImpostos()
                    endIf

                    self:oImpostos:Limpa()
                    self:Limpa()
                endIf            
    
            //Calcula os impostos por produto enviando cada produto para a matxFis
            else

                while !(cAlias)->( eof() )

                    if self:oImpostos:setProduto( (cAlias)->ENTRADA )

                        self:cEntrada     := (cAlias)->ENTRADA
                        self:cTabEntradas := ""
                                    
                        self:oImpostos:Calcula()

                        self:processaImpostos()
                    endIf

                    self:oImpostos:Limpa()
                    self:Limpa()

                    (cAlias)->( dbSkip() )
                EndDo

            endIf

            (cAlias)->( DbCloseArea() )

            self:oImpostos:Finaliza()
            fwFreeObj(self:oImpostos)
        Next nCont

    EndIf

    //Volta filial após processamento
    self:atualizaFilial(cBkpFilAnt)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraImp
Gera o impostos com base no tipo e campos recebidos

@type    method
@param   cTipoCad, Caractere, Tipo do imposto a ser gerado
@oaram   aCampos, Array, Campos da Matxfis que serão retornados pelo objeto RmiImpostosObj
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method GeraImp(cTipoCad, aCampos, cTipoImposto) Class RmiCadAuxiliaresObj

    Local aMatxFis  := {}
    Local jImposto  := nil
    Local aImposto  := {}    
    Local nCont     := 0
    Local nPos      := 0
    Local cCampo    := ""

    Default cTipoImposto := ""

    //Seta o tipo do cadastro auxiliar
    self:cTipoCadastro  := cTipoCad
    self:oRelaciona:setTipo(self:cTipoCadastro + cTipoImposto)

    //Carrega o layout com base no cTipoCadastro
    self:jConfig:FromJson( self:GetJson() )
    
    aMatxFis := IIF(aCampos == nil, self:getCampos(), aCampos)

    jImposto := self:oImpostos:getImposto( aMatxFis, strTran(cTipoImposto, "_", "") )
    aImposto := jImposto:GetNames()

    If Len(aImposto) > 0
        //Carrega o dados
        For nCont:=1 To Len(aImposto)

            cCampo  := aImposto[nCont]
            nPos    := aScan( self:jConfig["Components"], {|x| x["IdComponent"] == cCampo} )

            If nPos > 0
                self:jConfig["Components"][nPos]["ComponentContent"] := jImposto[cCampo]

                //Carrega a descrição\chave MIH_DESC
                self:setDescricao( self:jConfig["Components"][nPos]["ComponentContent"] )
            EndIf

        Next nCont

        //Gera MIH
        self:Grava()
    EndIf
    FwFreeArray(aMatxFis)
    FwFreeArray(aImposto)

    fwFreeObj(jImposto)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetJson
Metodo responsavel por devolver o layout do cadastro acessado

@type    method   
@return  String, Layout com cadastro acessado
@author  Lucas Novais (lnovais@)
@since   18/11/2021
@version 12.1.37
/*/
//-------------------------------------------------------------------
Method GetJson() Class RmiCadAuxiliaresObj
Return Self:aLayout[aScan(Self:aLayout, {|X| x[1] == self:cTipoCadastro})][2]

//-------------------------------------------------------------------
/*/{Protheus.doc} setDescricao
Atualiza propriedade cDescricao utilizada como chave (MIH_DESC)

@type    method
@param   xDescricao, Variavel, Conteudo das TAGs que compoem o campo MIH_CONFIG
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setDescricao(xDescricao) Class RmiCadAuxiliaresObj
    self:cDescricao += AllTrim( cValToChar(xDescricao) ) + "|"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDescricao
Retorna a propriedade cDescricao (MIH_DESC)

@type    method
@return  Caractere, Definição que salva no campo MIH_DESC
@author  Rafael Tenorio da Costa
@since   03/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method getDescricao() Class RmiCadAuxiliaresObj

    While SubStr(self:cDescricao, Len(self:cDescricao), 1) == "|" 
        self:cDescricao := SubStr(self:cDescricao, 1, Len(self:cDescricao) - 1)
    Enddo
    
Return self:cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} Marcas
Metodo para geração e gravação das marcas com base na tabela SB5

@type    method   
@author  Bruno Almeida
@since   25/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method Marcas(cMarca) Class RmiCadAuxiliaresObj

    Local aMarcas   := {} //Recebe as marcas que foram consultadas na tabela SB5 (B5_MARCA)
    Local nI        := 0 //Variavel de loop
    Local nX        := 0 //Variavel de loop

    Default cMarca := ""

    LjGrvLog(GetClassName(Self), "Inicio da geração das marcas no cadastro auxiliar")

    Self:cTipoCadastro := "MARCAS"
    self:oRelaciona:setTipo(self:cTipoCadastro)     //Seta o tipo do cadastro auxiliar no objeto de relacionamento MIL

    If Empty(cMarca)
        For nI := 1 To Len(Self:aFiliais)

            Self:cFil   := Self:aFiliais[nI]
            aMarcas     := GetMarcas(Self:aFiliais[nI])        

            For nX := 1 To Len(aMarcas)

                Self:cEntrada := aMarcas[nX]

                //Json do Cad Auxiliar de Marcas
                Self:jConfig:FromJson( Self:GetJson() )

                //Alimenta o unico campo de Marcas no Json
                Self:jConfig["Components"][1]["ComponentContent"] := aMarcas[nX]

                //Carrega a descrição\chave MIH_DESC
                Self:setDescricao( self:jConfig["Components"][1]["ComponentContent"] )

                //Grando o cadastro de marcas
                Self:Grava()


            Next nX
        Next nI
    Else
        Self:cFil := cFilAnt
        Self:cEntrada := cMarca
        
        //Json do Cad Auxiliar de Marcas
        Self:jConfig:FromJson( Self:GetJson() )

        //Alimenta o unico campo de Marcas no Json
        Self:jConfig["Components"][1]["ComponentContent"] := cMarca

        //Carrega a descrição\chave MIH_DESC
        Self:setDescricao( self:jConfig["Components"][1]["ComponentContent"] )

        //Grando o cadastro de marcas
        Self:Grava()
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Impostos
Centraliza o processamento dos impostos de um unico produto

@type    method   
@author  Lucas Novais 
@since   23/05/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method ImpPorProd(cProduto) Class RmiCadAuxiliaresObj

    Local cBkpFilAnt:= cFilAnt
    Local nCont     := 0

    ljGrvLog(/*cNumControl*/, "Gerando impostos por produto:", {cProduto, self:aFiliais})

    If Len(Self:aFiliais) == 0

        self:oMessageError:SetError( GetClassName(self), I18n(STR0001, {"CADASTRO DE LOJA", STR0002}) )   //"Carga de impostos não será executada. As filiais não foram encontradas, verifique o #1 na rotina #2."    //"Cadastros Auxiliares"
    Else

        //Processa as filiais
        For nCont:=1 To Len(Self:aFiliais)

            //Atualiza filial para processamento
            self:atualizaFilial(Self:aFiliais[nCont])

            self:oImpostos := RmiImpostosObj():New()

            If self:oImpostos:setProduto(cProduto)

                self:cEntrada := SB1->B1_COD

                self:oImpostos:Calcula()

                self:processaImpostos()             
            EndIf

            Self:oImpostos:Limpa()
            Self:Limpa()

            self:oImpostos:Finaliza()

            FwFreeObj(self:oImpostos)
            self:oImpostos := Nil
        Next nCont

    EndIf

    //Volta filial após processamento
    self:atualizaFilial(cBkpFilAnt)
 
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getCampos
Retorna os IdComponent do cadastros auxiliar

@type    method
@return  Array, com os IdComponent do cadastro auxiliar
@author  Rafael Tenorio da Costa
@since   20/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method getCampos() Class RmiCadAuxiliaresObj

    Local aCampos := {}
    Local nCont   := 0

    //Pega da memoria o layout do do cadastro auxiliar
    if !self:oHashMIG:get(self:cTipoCadastro, @aCampos)

        for nCont:=1 to len(self:jConfig["Components"])
            aAdd(aCampos, self:jConfig["Components"][nCont]["IdComponent"])
        next nCont

        self:oHashMIG:set(self:cTipoCadastro, aCampos)
    endIf

Return aClone( aCampos )


//-------------------------------------------------------------------
/*/{Protheus.doc} SetFiliais
Atualiza a propriedade aFiliais com base na filial recebida.

@type    method
@return  Nil
@author  Evandro Pattaro
@since   13/07/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Method SetFiliais(cFil) Class RmiCadAuxiliaresObj

    Local aFilAux := {}
    Local nI := 0

    Default cFil := ""

    cFil := AllTrim(cFil)

    If !Empty(cFil)
        For nI := 1 To Len(Self:aFiliais)
            If cFil == Substr(Self:aFiliais[nI], 1, Len(cFil))
                AAdd(aFilAux, cFil)
            EndIf
        Next nI
        FwFreeArray(Self:aFiliais)
        Self:aFiliais := aClone(aFilAux)
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} finaliza
Metodo com os procedimentos para finalizar o objeto RmiCadAuxiliaresObj

@type    method
@author  Rafael Tenorio da Costa
@since   20/08/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Method finaliza(lDestroy) Class RmiCadAuxiliaresObj

    self:oRelaciona:finaliza(lDestroy)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} atualizaFilial
Metodo com os procedimentos para atualizar a filial para processamento

@type    method
@author  Rafael Tenorio da Costa
@since   20/08/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Method atualizaFilial(cFil) Class RmiCadAuxiliaresObj

    self:cFil   := cFil
    cFilAnt     := cFil
    fwSM0Util():setSM0PositionBycFilAnt() 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} processaImpostos
Centraliza a geração dos impostos do produto corrente.

@type    method
@return  Nil, Nulo
@author  Rafael Tenorio da Costa
@since   31/08/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Method processaImpostos() Class RmiCadAuxiliaresObj

    //Gera FECP na MIH
    self:GeraImp("FECP"      , /*aCampos*/, /*cTipoImposto*/)

    //Gera PISCOFINS na MIH
    self:GeraImp("PIS/COFINS", /*aCampos*/, /*cTipoImposto*/)

    //Gera ICMS na MIH
    self:GeraImp("ICMS"      , /*aCampos*/, /*cTipoImposto*/)

    //Gera IMPOSTO na MIH - IBSUF
    self:GeraImp("IMPOSTO"   , /*aCampos*/, "_IBSUF"        )

    //Gera IMPOSTO na MIH - IBSM
    self:GeraImp("IMPOSTO"   , /*aCampos*/, "_IBSM"         )

    //Gera IMPOSTO na MIH - CBS
    self:GeraImp("IMPOSTO"   , /*aCampos*/, "_CBS"          )

    //Gera IMPOSTO na MIH - IS
    self:GeraImp("IMPOSTO"   , /*aCampos*/, "_IS"           )

Return Nil
