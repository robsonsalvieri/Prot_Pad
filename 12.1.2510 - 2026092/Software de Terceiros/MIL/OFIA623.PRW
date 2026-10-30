#Include "FWMVCDEF.CH"
#Include "OFIA623.CH"

/*/{Protheus.doc} OFIA623
    Browse principal que lista as OS´s a serem entregues para o cliente
    @type  Function
    @author user
    @since 25/05/2026
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function OFIA623()
    
    Local aArea     := GetArea()
    Local oBrowse   := Nil 

    If VO1->(FieldPos("VO1_DTENTR")) == 0
        FMX_Help("OA623001", ;
            STR0001, ; // "O campo Data de Entrega do Veículo ao Cliente(VO1_DTENTR) não foi localizado no Dicionário de Dados (SX3)"
            STR0002)   // "Para usar esta rotina, o campo Data de Entrega do Veículo ao Cliente (VO1_DTENTR) deve existir na base dados"
        Return Nil
    Endif

    VAI->(DBSetOrder(4))
    If !VAI->(DBSeek(xFilial("VAI") + __cUserID))
        FMX_Help("OA623002", ;
            STR0010, ; // "Usuário sem cadastro na rotina Equipe Técnica (OFIOA180)."
            STR0011)   // "Para prosseguir com a utilização da rotina, é necessário realizar o cadastro do usuário."
        Return Nil
    Endif

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("VO1")
    oBrowse:SetDescription(STR0003)
    oBrowse:SetFilterDefault(" VO1_FUNABE == '" + VAI->VAI_CODTEC + "' ")
    oBrowse:AddLegend( "!Empty(VO1_DTENTR)" , "GREEN" , STR0008) // Entrega concluída
	oBrowse:AddLegend( "Empty(VO1_DTENTR)"  , "BLUE"  , STR0009) // Veículo não entregue
    oBrowse:Activate()

    RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
    (long_description)
    @type  Static Function
    @author user
    @since 25/05/2026
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()

    Local aRotina as Array

    aRotina := {}
   
    ADD OPTION aRotina Title STR0004 Action 'OA623001K_RegistrarEntregaVeiculo()' OPERATION 6 ACCESS 0 // "Registrar Entrega do Veículo"
    ADD OPTION aRotina Title STR0015 Action 'OA623002K_LiberaManutencaoOS()'      OPERATION 7 ACCESS 0 // "Libera Manutenção da OS"
    ADD OPTION aRotina Title STR0016 Action 'OA623003K_LimpaDataHoraEntregaVeic()'OPERATION 8 ACCESS 0 // "Limpa Entrega do Veículo ao Cliente"

Return aRotina

/*/{Protheus.doc} OA623001K_RegistrarEntregaVeiculo
    Função para registrar a data e hora de entrega do veículo
    ao cliente através de uma ParamBox
    @type  Static Function
    @author Lucas Oliveira
    @since 25/05/2026
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function OA623001K_RegistrarEntregaVeiculo()
    
    Local aParamBox := {}
    Local aRetParam := {}
    Local lDiarioOficina := FindFunction("OA5480062_RegistraEventoDiarioOficina")
    Local dDataEntrega := dDataBase
    Local nHoraEntrega := Time()
    Local aDataHoraUF := {}
    
    If FindFunction("FGX_TimeUF")
        aDataHoraUF := FGX_TimeUF()
        dDataEntrega := aDataHoraUF[1]
        nHoraEntrega := aDataHoraUF[2]
    Endif

    nHoraEntrega := StrTran(Left(nHoraEntrega, 5),":","")

    aAdd(aParamBox, { 1, STR0005, dDataEntrega , ""        , "" , "", ".T." , 50, .T.}) //"Data de entrega do veículo"
	aAdd(aParamBox, { 1, STR0006, nHoraEntrega , "@R 99:99", "" , "", ".T." , 5 , .T.}) //"Hora de entrega do veículo"

	If ParamBox(aParamBox, STR0007, @aRetParam,,,,,,,,.F.) .and. OA623004K_ValidParamBox(aRetParam)// "Informe a Data/Hora de Entrega do Veículo"
        
        dDataEntrega := aRetParam[1]
        nHoraEntrega := Val( aRetParam[2] )
        
		Reclock("VO1", .F.)
            VO1->VO1_DTENTR := dDataEntrega
            VO1->VO1_HRENTR := nHoraEntrega
            VO1->VO1_LIBMAN := "0" // Manutenção da OS bloqueada para requisição de peças e serviços
        MsUnLock()

        If lDiarioOficina
            OA5480062_RegistraEventoDiarioOficina(VO1->VO1_NUMOSV, '021') // 021 - ENTREGA DO VEICULO AO CLIENTE
        EndIf

        FWAlertSuccess(STR0012, "OA623001") // "A entrega do veículo ao cliente foi registrada com sucesso."

	Endif

Return .T.

/*/{Protheus.doc} OA623004K_ValidParamBox
    Função que valida se a data/hora de entrega são posteriores
    a abertura da OS e dentro do atendimento - não futuro.
    @type  Static Function
    @author Lucas Oliveira
    @since 03/06/2026
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function OA623004K_ValidParamBox(aRetParamBox)

    Local lRet := .T.
    Local dDataEntrega  := aRetParamBox[1]
    Local nHoraEntrega  := Val( aRetParamBox[2])

    Local dDataAtual := dDataBase
    Local nHoraAtual := Val( Left( Time(), 2) + Substr( Time(), 4, 2))
    Local aDataHoraUF := {}
    
    If FindFunction("FGX_TimeUF")
        aDataHoraUF := FGX_TimeUF()
        dDataAtual := aDataHoraUF[1]
        nHoraAtual := Val( Left( aDataHoraUF[2], 2) + Substr( aDataHoraUF[2], 4, 2))
    Endif

    If (dDataEntrega < VO1->VO1_DATABE) .or. (dDataEntrega == VO1->VO1_DATABE .and. nHoraEntrega < VO1->VO1_HORABE)
        FMX_HELP("OA623003",; 
        STR0017,; // "A data e hora informadas para a entrega do veículo são anteriores à data e hora de abertura da Ordem de Serviço."
        STR0018) // "Informe uma data e hora de entrega iguais ou posteriores à data e hora de abertura da Ordem de Serviço."
        lRet := .F.
    Endif

    If (dDataEntrega > dDataAtual) .or. (dDataEntrega == dDataAtual .and. nHoraEntrega > nHoraAtual)
        FMX_HELP("OA623004",; 
        STR0019,; // "A data e hora informadas para a entrega do veículo são posteriores à data e hora atuais."
        STR0020) // "Informe uma data e hora de entrega iguais ou anteriores à data e hora atuais."
        lRet := .F.
    Endif

Return lRet

/*/{Protheus.doc} OA623002K_LiberaManutencaoOS
    Realiza a liberação da Ordem de Serviço para execução dos 
    serviços de manutenção e requisição de peças.
    @type  Function
    @author Lucas Oliveira
    @since 03/06/2026
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function OA623002K_LiberaManutencaoOS()

    Local lRet := .T.

    Reclock("VO1", .F.)
        VO1->VO1_LIBMAN := "1" // Manutenção da OS LIBERADA para requisição de peças e serviços
    MsUnLock()

    FWAlertSuccess(STR0013, "OA623002K") // "A Ordem de Serviço foi liberada para execução dos serviços de manutenção e requisição de peças."

Return lRet

/*/{Protheus.doc} OA623003K_LimpaDataHoraEntregaVeic
    Remove o registro de data e hora de entrega do 
    veículo ao cliente na Ordem de Serviço.
    @type  Function
    @author Lucas Oliveira
    @since 03/06/2026
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function OA623003K_LimpaDataHoraEntregaVeic(param_name)

    Local lRet := .T.
    Local lDeletaEvento := .T.
    Local lDiarioOficina := FindFunction("OA5480062_RegistraEventoDiarioOficina")

    Reclock("VO1", .F.)
        VO1->VO1_DTENTR := CToD("  /  /   ")
        VO1->VO1_HRENTR := 0
        VO1->VO1_LIBMAN := "1" // Manutenção da OS LIBERADA para requisição de peças e serviços
    MsUnLock()

    If lDiarioOficina
        OA5480062_RegistraEventoDiarioOficina(VO1->VO1_NUMOSV, '021', lDeletaEvento) // 021 - ENTREGA DO VEICULO AO CLIENTE
    EndIf

    FWAlertSuccess(STR0014, "OA623003K") // "O registro de entrega do veículo foi removido com sucesso."

Return lRet