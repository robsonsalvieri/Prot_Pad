#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "hatActions.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc}) PLHATMap
Retorna o array com os campos/tags correspondentes de cada API do HAT

Retorno:
[01] - Tag do HAT
[02] - Campo PLS
[03] - Indica se a tag pode ser gerada vazia

@author  Renan Sakai 
@version P12
@since    29.10.18
/*/
//-------------------------------------------------------------------
Function PLHATMap(cAlias)
Local aRet := {}

Do Case
    
    /*-----------------------------------------------
    API: beneficiaries
    Acoes:  _beneficiaries_inc              "0001"
            _beneficiaries_alt              "0002"
    -------------------------------------------------*/
    Case cAlias == "BA1"
        Aadd(aRet,{'subscriberId','BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO',.F.})
        //Aadd(aRet,{'familyCode','BA1_MATRIC',.F.}) <-- So' e' necessario para sistemas que nao sejam o PLS, pois o HAT segue o mesmo padrao de familia do PLS.
        Aadd(aRet,{'contractNumber','BA1_CONEMP',.F.})
        Aadd(aRet,{'name','BA1_NOMUSR',.F.})
        Aadd(aRet,{'personId','BA1_MATVID',.F.})         
        Aadd(aRet,{'birthdate','BA1_DATNAS',.F.})
        Aadd(aRet,{'gender','BA1_SEXO',.F.})
        Aadd(aRet,{'ZIPCode','BA1_CEPUSR',.F.})
        Aadd(aRet,{'cityCode','BA1_CODMUN',.F.})
        Aadd(aRet,{'contractVersion','BA1_VERCON',.F.})
        Aadd(aRet,{'holderCPF','BA1_CPFUSR',.F.})
        Aadd(aRet,{'holderRelationship','BA1_TIPUSU',.F.})
        Aadd(aRet,{'effectiveDate','BA1_DATINC',.F.})
        Aadd(aRet,{'waitingPeriodDate','BA1_DATCAR' ,.F.})
        Aadd(aRet,{'cardExpiration','BA1_DTVLCR',.F.})
        Aadd(aRet,{'subcontractNumber','BA1_SUBCON',.F.})
        Aadd(aRet,{'subcontractVersion','BA1_VERSUB',.F.})
        Aadd(aRet,{'blockedDate','BA1_DATBLO',.T.})
        Aadd(aRet,{'tokenSeed','BA1_TKSEED',.T.})
        Aadd(aRet,{'socialName','BA1_NOMSOC',.T.})
        //Aadd(aRet,{"tarjaCartao",'BA1_TARCAR',.F.}) 
        
        //Importante: Plano e Versao sao tratados no fonte de envio os 
        //dados podem variar dos Alias BA1 e BA3
        //Aadd(aRet,{'healthInsuranceCode',"BA1_CODPLA",BA1->BA1_CODPLA ,.F.})
        //Aadd(aRet,{'healthInsuranceVersion',"BA1_VERSAO",BA1->BA1_VERSAO ,.F.})

    Case cAlias == "BFE"
        Aadd(aRet,{'code','BFE_CODGRU',.F.})
        Aadd(aRet,{'waitingPeriodDate','BFE_DATCAR',.F.})

    /*-----------------------------------------------
    API: healthProviders
    Acoes:  _healthProviders_inc            "0003"
            _healthProviders_alt            "0004"
    -------------------------------------------------*/
    Case cAlias == "BAU"
    	Aadd(aRet,{'healthProviderCode','BAU_CODIGO',.F.})
        Aadd(aRet,{'healthProviderDocument','BAU_CPFCGC',.F.})
        Aadd(aRet,{'name','BAU_NOME',.F.})
        Aadd(aRet,{'reducedName','BAU_NREDUZ',.F.})
        Aadd(aRet,{'healthProviderType','BAU_TIPPE',.F.})
        Aadd(aRet,{'healthProviderClass','BAU_TIPPRE',.F.})
        Aadd(aRet,{'email','BAU_EMAIL',.F.})
        Aadd(aRet,{'cnesCode','BAU_CNES',.F.})

    Case cAlias == "BC0"
        Aadd(aRet,{'attendanceLocationCode','BC0_CODLOC',.F.})
		Aadd(aRet,{'specialtyCode','BC0_CODESP',.F.})
		Aadd(aRet,{'procedureTableCode','BC0_CODPAD',.F.})
		Aadd(aRet,{'procedureCode','BC0_CODOPC',.F.})
		Aadd(aRet,{'level','BC0_NIVEL',.F.})
		Aadd(aRet,{'movementType','BC0_TIPO',.F.})
		Aadd(aRet,{'initialTerm','BC0_VIGDE',.F.})
		Aadd(aRet,{'finalTerm','BC0_VIGATE',.F.})
		Aadd(aRet,{'blockDate','BC0_DATBLO',.F.})

    /*-----------------------------------------------
    API: clinicalStaff
    Acoes: _clinicalStaff_BC1_inc      "0005"
           _clinicalStaff_BC1_alt      "0006"
    -------------------------------------------------*/
    Case cAlias == "BC1"
        Aadd(aRet,{'healthProviderCode','BC1_CODIGO',.F.})
        Aadd(aRet,{'idOnHealthInsurer','BC1_CODPRF',.F.})
        Aadd(aRet,{'professionalCouncil','BC1_SIGLCR',.F.})
        Aadd(aRet,{'professionalCouncilNumber','BC1_NUMCR',.F.})
        Aadd(aRet,{'stateAbbreviation','BC1_ESTCR',.F.})
        Aadd(aRet,{'name','BC1_NOMPRF',.F.})
        Aadd(aRet,{'specialtyCode','BC1_CODESP',.F.})
        Aadd(aRet,{'attendanceLocation','BC1_CODLOC',.F.})

    /*-----------------------------------------------
    API: preExistingDiseases
    Acoes: _preExistingDiseases_inc            "0019"
           _preExistingDiseases_alt            "0020"
    -------------------------------------------------*/
    Case cAlias == "BF3"
        Aadd(aRet,{'subscriberId','BF3_CODINT+BF3_CODEMP+BF3_MATRIC+BF3_TIPREG',.F.})
        Aadd(aRet,{'diseaseCode','BF3_CODDOE',.F.})
        Aadd(aRet,{'waitingPeriod','BF3_MESAGR',.F.})
        Aadd(aRet,{'waitingPeriodUnit','BF3_UNAGR',.F.})    
        Aadd(aRet,{'waitingPeriodDate','BF3_DATCPT',.F.})
        Aadd(aRet,{'procedureTableCode','BF3_CODPAD',.F.})
        Aadd(aRet,{'procedureCode','BF3_CODPSA',.F.})

    /*-----------------------------------------------
    API: healthProviders
    Acoes:  _persons_inc                   "0021" 
            _persons_alt                   "0022" 
    -------------------------------------------------*/
    Case cAlias == "BTS"
        Aadd(aRet,{'personId','BTS_MATVID',.F.})
        Aadd(aRet,{'holderCPF','BTS_CPFUSR',.F.})
        Aadd(aRet,{'name','BTS_NOMUSR',.F.})
        Aadd(aRet,{'birthdate','BTS_DATNAS',.F.})
        Aadd(aRet,{'gender','BTS_SEXO',.F.})       
        Aadd(aRet,{'nationalhealthcard','BTS_NRCRNA',.F.})
        Aadd(aRet,{'zipcode','BTS_CEPUSR',.F.})
        Aadd(aRet,{'citycode','BTS_CODMUN',.F.})
        Aadd(aRet,{'socialName','BTS_NOMSOC',.F.})
        Aadd(aRet,{'email','BTS_EMAIL',.F.})

    /*-----------------------------------------------
    API: beneficiaryStatus
    Acoes: _beneficiaryStatus_blo           "0023"
           _beneficiaryStatus_desblo        "0024"
    -------------------------------------------------*/           
    Case cAlias == "BCA"
    	Aadd(aRet,{'subscriberId','BCA_MATRIC+BCA_TIPREG',.F.})
    	Aadd(aRet,{'eventDate','BCA_DATA',.F.})
    	Aadd(aRet,{'reason','BCA_OBS',.F.})
	    Aadd(aRet,{'eventType','BCA_TIPO',.F.})
        Aadd(aRet,{'entry_date','BCA_DATLAN',.F.})
        Aadd(aRet,{'entry_hour','BCA_HORLAN',.F.})
    

    /*-----------------------------------------------
    API: healthProviderStatus
    Acoes: _healthProviderStatus_blo       "0025"
           _healthProviderStatus_desblo    "0026"
    -------------------------------------------------*/
    Case cAlias == "BC4"
        Aadd(aRet,{'healthProviderCode','BC4_CODCRE' ,.F.})
        Aadd(aRet,{'healthProviderDocument','BAU_CPFCGC',.F.})
        Aadd(aRet,{'eventType','BC4_TIPO' ,.F.})
        Aadd(aRet,{'eventDate','BC4_DTBLQ',.F.})

    /*-----------------------------------------------
    API: attendanceLocations
    Acoes: _attendanceLocations_inc        "0027" 
           _attendanceLocations_alt        "0028"
    -------------------------------------------------*/
    Case cAlias == "BB8"
    	Aadd(aRet,{'healthProviderCode','BB8_CODIGO',.F.})
        Aadd(aRet,{'locationCode','BB8_CODLOC',.F.})
        Aadd(aRet,{'locationTypeCode','BB8_LOCAL',.F.})
        Aadd(aRet,{'locationDescription','BB8_DESLOC',.F.})
        Aadd(aRet,{'ZIPCode','BB8_CEP',.F.})
        Aadd(aRet,{'streetType','BB8_TIPLOG',.F.})
        Aadd(aRet,{'address','BB8_END',.F.})
        Aadd(aRet,{'addressNumber','BB8_NR_END',.F.})
        Aadd(aRet,{'addressComplement','BB8_COMEND',.F.})
        Aadd(aRet,{'cityCode','BB8_CODMUN',.F.})
        Aadd(aRet,{'cityName','BB8_MUN',.F.})
        Aadd(aRet,{'stateAbbreviation','BB8_EST',.F.})
        Aadd(aRet,{'district','BB8_BAIRRO',.F.})
        Aadd(aRet,{'phoneAreaCode','BB8_DDD',.F.})
        Aadd(aRet,{'phone','BB8_TEL',.F.})
        Aadd(aRet,{'contactName','BB8_CONTAT',.F.})
        Aadd(aRet,{'cnesCode','BB8_CNES',.F.})
        Aadd(aRet,{'region','BB8_REGMUN',.F.})
        Aadd(aRet,{'blockDate','BB8_DATBLO',.T.})

    /*-----------------------------------------------
    API: healthProviderSpecialties
    Acoes: _healthProviderSpecialties_inc  "0029"
           _healthProviderSpecialties_alt  "0030"
    -------------------------------------------------*/
    Case cAlias == "BAX"
    	Aadd(aRet,{'healthProviderCode','BAX_CODIGO',.F.})
        Aadd(aRet,{'locationCode','BAX_CODLOC',.F.})
        Aadd(aRet,{'specialtyCode','BAX_CODESP',.F.})
        Aadd(aRet,{'subspecialtyCode','BAX_CODSUB',.F.})
        Aadd(aRet,{'considerSpecialty','BAX_CONESP',.F.})
        Aadd(aRet,{'blockDate','BAX_DATBLO',.T.})
        Aadd(aRet,{'searchOrder','BAX_ORDPES',.F.})
        Aadd(aRet,{'allowsMaterial','BAX_LIMATM',.F.})

    /*-----------------------------------------------
    API: /coverages/procedureLevel
    Acoes: _coveragesLevel_BFG_inc  "0031" 
           _coveragesLevel_BFG_alt  "0032" 
    -------------------------------------------------*/
    Case cAlias == "BFG"
        Aadd(aRet,{'active','BFG_BENUTL',.F.})
        Aadd(aRet,{'authorization','BFG_AUTORI',.F.})
        Aadd(aRet,{'waitingPeriod','BFG_CARENC',.F.})
        Aadd(aRet,{'waitingPeriodUnit','BFG_UNCAR',.F.})
        Aadd(aRet,{'waitingPeriodClass','BFG_CLACAR',.F.})
        Aadd(aRet,{'level','BFG_NIVEL',.F.})
        Aadd(aRet,{'validWaitingPeriodLevel','BFG_NIVCAR',.F.})
        Aadd(aRet,{'allowedQuantity','BFG_QTD',.F.})
        Aadd(aRet,{'quantityUnit','BFG_UNCA',.F.})
        Aadd(aRet,{'period','BFG_PERIOD',.F.})
        Aadd(aRet,{'periodUnit','BFG_UNPERI',.F.})
        Aadd(aRet,{'gender','BFG_SEXO',.F.})
        Aadd(aRet,{'minimumAge','BFG_IDAMIN',.F.})
        Aadd(aRet,{'minimumAgeUnit','BFG_UNIMIN',.F.})
        Aadd(aRet,{'maximumAge','BFG_IDAMAX',.F.})
        Aadd(aRet,{'maximumAgeUnit','BFG_UNIMAX',.F.})
        Aadd(aRet,{'procedureCode','BFG_CODPSA',.F.})
        Aadd(aRet,{'procedureTableCode','BFG_CODPAD',.F.})
        Aadd(aRet,{'companyId','BFG_CODEMP',.F.})
        Aadd(aRet,{'waitingPeriodDate','BFG_DATCAR',.F.})
        Aadd(aRet,{'beneficiaryRegistryType','BFG_TIPREG',.F.})
        Aadd(aRet,{'subscriberId','BFG_MATRIC',.F.})
        Aadd(aRet,{'copartTable','BFG_CODTAB',.F.})
        //'subContractNumber','BT8_SUBCON'
        //'contractVersion','BT8_VERCON'
        //'subContractVersion','BT8_VERSUB'
        //'healthProductVersion','BT8_VERPRO || BB2_VERSAO'
        //'healthProductCode','BT8_CODPLA || BB2_CODIGO'
        //'contractNumber','BT8_NUMCON'
        Aadd(aRet,{'levelCode01','BFG_CDNV01',.F.})
        Aadd(aRet,{'levelCode02','BFG_CDNV02',.F.})
        Aadd(aRet,{'levelCode03','BFG_CDNV03',.F.})
        Aadd(aRet,{'levelCode04','BFG_CDNV04',.F.})
        //'periodBySpecialty','BB2_PTRESP'
        //'periodByHealthProvider','BB2_PTRMED'
        //'periodByDisease','BB2_PTRPAT'
        //'quantityBySpecialty','BB2_QTDESP'
        //'quantityByHealthProvider','BB2_QTDMED'
        //'quantityByDisease','BB2_QTDPAT'

    
    /*-----------------------------------------------
    API: coverages/procedureLevel
    Acoes: _coveragesLevel_BFD_inc  "0033" 
           _coveragesLevel_BFD_alt  "0034" 
    -------------------------------------------------*/
    Case cAlias == "BFD"
        Aadd(aRet,{'active','BFD_BENUTL',.F.})
        Aadd(aRet,{'authorization','BFD_AUTORI',.F.})
        Aadd(aRet,{'waitingPeriod','BFD_CARENC',.F.})
        Aadd(aRet,{'waitingPeriodUnit','BFD_UNCAR',.F.})
        Aadd(aRet,{'waitingPeriodClass','BFD_CLACAR',.F.})
        Aadd(aRet,{'level','BFD_NIVEL',.F.})
        Aadd(aRet,{'validWaitingPeriodLevel','BFD_NIVCAR',.F.})
        Aadd(aRet,{'allowedQuantity','BFD_QTD',.F.})
        Aadd(aRet,{'quantityUnit','BFD_UNCA',.F.})
        Aadd(aRet,{'period','BFD_PERIOD',.F.})
        Aadd(aRet,{'periodUnit','BFD_UNPERI',.F.})
        Aadd(aRet,{'gender','BFD_SEXO',.F.})
        Aadd(aRet,{'minimumAge','BFD_IDAMIN',.F.})
        Aadd(aRet,{'minimumAgeUnit','BFD_UNIMIN',.F.})
        Aadd(aRet,{'maximumAge','BFD_IDAMAX',.F.})
        Aadd(aRet,{'maximumAgeUnit','BFD_UNIMAX',.F.})
        Aadd(aRet,{'procedureCode','BFD_CODPSA',.F.})
        Aadd(aRet,{'procedureTableCode','BFD_CODPAD',.F.})
        Aadd(aRet,{'companyId','BFD_CODEMP',.F.})
        //Aadd(aRet,{'waitingPeriodDate','BFD_DATCAR',.F.})
        //Aadd(aRet,{'beneficiaryRegistryType','BFD_TIPREG',.F.})
        Aadd(aRet,{'subscriberId','BFD_MATRIC',.F.})
        Aadd(aRet,{'copartTable','BFD_CODTAB',.F.})
        //'subContractNumber','BT8_SUBCON'
        //'contractVersion','BT8_VERCON'
        //'subContractVersion','BT8_VERSUB'
        //'healthProductVersion','BT8_VERPRO || BB2_VERSAO'
        //'healthProductCode','BT8_CODPLA || BB2_CODIGO'
        //'contractNumber','BT8_NUMCON'
        Aadd(aRet,{'levelCode01','BFD_CDNV01',.F.})
        Aadd(aRet,{'levelCode02','BFD_CDNV02',.F.})
        Aadd(aRet,{'levelCode03','BFD_CDNV03',.F.})
        Aadd(aRet,{'levelCode04','BFD_CDNV04',.F.})
        //'periodBySpecialty','BB2_PTRESP'
        //'periodByHealthProvider','BB2_PTRMED'
        //'periodByDisease','BB2_PTRPAT'
        //'quantityBySpecialty','BB2_QTDESP'
        //'quantityByHealthProvider','BB2_QTDMED'
        //'quantityByDisease','BB2_QTDPAT'

    /*-----------------------------------------------
    API: coverages/groupLevel
    Acoes: _coverageGroupLevel_BFC_inc    "0040"
           _coverageGroupLevel_BFC_alt    "0041"
    -------------------------------------------------*/
    Case cAlias == "BFC"
        Aadd(aRet,{'companyId','BFC_CODEMP',.F.})
        Aadd(aRet,{'coverageGroupCode','BFC_CODGRU',.F.})
        Aadd(aRet,{'subscriberId','BFC_MATRIC',.F.})
        //Aadd(aRet,{'waitingPeriodDateStart',,.F.})
        //Aadd(aRet,{'beneficiaryRegistryType',,.F.})
        //Aadd(aRet,{'healthProductCode',,.F.})
        //Aadd(aRet,{'healthProductVersion',,.F.})
        //Aadd(aRet,{'contractNumber',,.F.})
        //Aadd(aRet,{'contractVersion',,.F.})
        //Aadd(aRet,{'subcontractNumber',,.F.})
        //Aadd(aRet,{'subcontractVersion',,.F.})
        //Aadd(aRet,{'waitingPeriod',,.F.})
        //Aadd(aRet,{'waitingPeriodUnit',,.F.})

    /*-----------------------------------------------
    API: coverages/procedureLevel
    Acoes: _coverageProcedureLevel_BT8_inc     "0042"  
           _coverageProcedureLevel_BT8_alt     "0043"
    -------------------------------------------------*/
    Case cAlias == "BT8"
        Aadd(aRet,{'active','BT8_BENUTL',.F.})
        Aadd(aRet,{'authorization','BT8_AUTORI',.F.})
        Aadd(aRet,{'waitingPeriod','BT8_CARENC',.F.})
        Aadd(aRet,{'waitingPeriodUnit','BT8_UNCAR',.F.})
        Aadd(aRet,{'waitingPeriodClass','BT8_CLACAR',.F.})
        Aadd(aRet,{'level','BT8_NIVEL',.F.})
        Aadd(aRet,{'validWaitingPeriodLevel','BT8_NIVCAR',.F.})
        Aadd(aRet,{'allowedQuantity','BT8_QTD',.F.})
        Aadd(aRet,{'quantityUnit','BT8_UNCA',.F.})
        Aadd(aRet,{'period','BT8_PERIOD',.F.})
        Aadd(aRet,{'periodUnit','BT8_UNPERI',.F.})
        Aadd(aRet,{'gender','BT8_SEXO',.F.})
        Aadd(aRet,{'minimumAge','BT8_IDAMIN',.F.})
        //Aadd(aRet,{'minimumAgeUnit','BT8_UNIMIN',.F.})
        Aadd(aRet,{'maximumAge','BT8_IDAMAX',.F.})
        //Aadd(aRet,{'maximumAgeUnit','BT8_UNIMAX',.F.})
        Aadd(aRet,{'procedureCode','BT8_CODPSA',.F.})
        Aadd(aRet,{'procedureTableCode','BT8_CODPAD',.F.})
        Aadd(aRet,{'companyId','BT8_CODIGO',.F.})
        //Aadd(aRet,{'waitingPeriodDate','BT8_DATCAR',.F.})
        //Aadd(aRet,{'beneficiaryRegistryType','BT8_TIPREG',.F.})
        //Aadd(aRet,{'subscriberId','BT8_MATRIC',.F.})
        //Aadd(aRet,{'copartTable','BT8_CODTAB',.F.})
        Aadd(aRet,{'subContractNumber','BT8_SUBCON',.F.})
        Aadd(aRet,{'contractVersion','BT8_VERCON',.F.})
        Aadd(aRet,{'subContractVersion','BT8_VERSUB',.F.})
        Aadd(aRet,{'healthProductVersion','BT8_VERPRO',.F.})
        Aadd(aRet,{'healthProductCode','BT8_CODPRO',.F.})
        Aadd(aRet,{'contractNumber','BT8_NUMCON',.F.})
        Aadd(aRet,{'levelCode01','BT8_CDNV01',.F.})
        Aadd(aRet,{'levelCode02','BT8_CDNV02',.F.})
        Aadd(aRet,{'levelCode03','BT8_CDNV03',.F.})
        Aadd(aRet,{'levelCode04','BT8_CDNV04',.F.})
        //Aadd(aRet,{'periodBySpecialty','BB2_PTRESP',.F.})
        //Aadd(aRet,{'periodByHealthProvider','BB2_PTRMED',.F.})
        //Aadd(aRet,{'periodByDisease','BB2_PTRPAT',.F.})
        //Aadd(aRet,{'quantityBySpecialty','BB2_QTDESP',.F.})
        //Aadd(aRet,{'quantityByHealthProvider','BB2_QTDMED',.F.})
        //Aadd(aRet,{'quantityByDisease','BB2_QTDPAT',.F.})   

    /*-----------------------------------------------
    API: coverages/groupLevel
    Acoes: _coverageGroupLevel_BT7_inc         "0044" 
           _coverageGroupLevel_BT7_alt         "0045" 
    -------------------------------------------------*/
    Case cAlias == "BT7"
        Aadd(aRet,{'companyId','BT7_CODIGO',.F.})
        Aadd(aRet,{'coverageGroupCode','BT7_CODGRU',.F.})
        //Aadd(aRet,{'subscriberId','BFC_MATRIC ',.F.})
        Aadd(aRet,{'waitingPeriodDateStart','BFE_DATCAR',.F.})
        //Aadd(aRet,{'beneficiaryRegistryType','',.F.})
        Aadd(aRet,{'healthProductCode','BT7_CODPRO',.F.})
        Aadd(aRet,{'healthProductVersion','BT7_VERPRO',.F.})
        Aadd(aRet,{'contractNumber','BT7_NUMCON',.F.})
        Aadd(aRet,{'contractVersion','BT7_VERCON',.F.})
        Aadd(aRet,{'subcontractNumber','BT7_SUBCON',.F.})
        Aadd(aRet,{'subcontractVersion','BT7_VERSUB',.F.})
        Aadd(aRet,{'waitingPeriod','BT7_CARENC',.F.})
        Aadd(aRet,{'waitingPeriodUnit','BT7_UNCAR',.F.})     

    /*-----------------------------------------------
    API: coverages/procedureLevel
    Acoes: _coverageProcedureLevel_BB2_inc     "0046"  
           _coverageProcedureLevel_BB2_alt     "0047"
    -------------------------------------------------*/
    Case cAlias == "BB2"
        Aadd(aRet,{'active','BB2_BENUTL',.F.})
        Aadd(aRet,{'authorization','BB2_AUTORI',.F.})
        Aadd(aRet,{'waitingPeriod','BB2_CARENC',.F.})
        Aadd(aRet,{'waitingPeriodUnit','BB2_UNCAR',.F.})
        Aadd(aRet,{'waitingPeriodClass','BB2_CLACAR',.F.})
        Aadd(aRet,{'level','BB2_NIVEL',.F.})
        Aadd(aRet,{'validWaitingPeriodLevel','BB2_NIVCAR',.F.})
        Aadd(aRet,{'allowedQuantity','BB2_QTD',.F.})
        Aadd(aRet,{'quantityUnit','BB2_UNCA',.F.})
        Aadd(aRet,{'period','BB2_PERIOD',.F.})
        Aadd(aRet,{'periodUnit','BB2_UNPERI',.F.})
        Aadd(aRet,{'gender','BB2_SEXO',.F.})
        Aadd(aRet,{'minimumAge','BB2_IDAMIN',.F.})
        //Aadd(aRet,{'minimumAgeUnit','BB2_UNIMIN',.F.})
        Aadd(aRet,{'maximumAge','BB2_IDAMAX',.F.})
        //Aadd(aRet,{'maximumAgeUnit','BB2_UNIMAX',.F.})
        Aadd(aRet,{'procedureCode','BB2_CODPSA',.F.})
        Aadd(aRet,{'procedureTableCode','BB2_CODPAD',.F.})
        //Aadd(aRet,{'companyId','BB2_CODEMP',.F.})
        //Aadd(aRet,{'waitingPeriodDate','BB2_DATCAR',.F.})
        //Aadd(aRet,{'beneficiaryRegistryType','BB2_TIPREG',.F.})
        //Aadd(aRet,{'subscriberId','BB2_MATRIC',.F.})
        //Aadd(aRet,{'copartTable','BB2_CODTAB',.F.})
        //Aadd(aRet,{'subContractNumber','BB2_SUBCON',.F.})
        //Aadd(aRet,{'contractVersion','BB2_VERCON',.F.})
        //Aadd(aRet,{'subContractVersion','BB2_VERSUB',.F.})
        Aadd(aRet,{'healthProductVersion','BB2_VERSAO',.F.})
        Aadd(aRet,{'healthProductCode','BB2_CODIGO',.F.})
        //Aadd(aRet,{'contractNumber','BB2_NUMCON',.F.})
        Aadd(aRet,{'levelCode01','BB2_CDNV01',.F.})
        Aadd(aRet,{'levelCode02','BB2_CDNV02',.F.})
        Aadd(aRet,{'levelCode03','BB2_CDNV03',.F.})
        Aadd(aRet,{'levelCode04','BB2_CDNV04',.F.})
        Aadd(aRet,{'periodBySpecialty','BB2_PTRESP',.F.})
        Aadd(aRet,{'periodByHealthProvider','BB2_PTRMED',.F.})
        Aadd(aRet,{'periodByDisease','BB2_PTRPAT',.F.})
        Aadd(aRet,{'quantityBySpecialty','BB2_QTDESP',.F.})
        Aadd(aRet,{'quantityByHealthProvider','BB2_QTDMED',.F.})
        Aadd(aRet,{'quantityByDisease','BB2_QTDPAT',.F.})   

    /*-----------------------------------------------
    API: coverages/groupLevel
    Acoes: _coverageGroupLevel_BRV_inc         "0048" 
           _coverageGroupLevel_BRV_alt         "0049" 
    -------------------------------------------------*/
    Case cAlias == "BRV"
        //Aadd(aRet,{'companyId','BRV_CODGRU',.F.})
        Aadd(aRet,{'coverageGroupCode','BRV_CODGRU',.F.})
        //Aadd(aRet,{'subscriberId','BFC_MATRIC',.F.})
        //Aadd(aRet,{'waitingPeriodDateStart','BFE_DATCAR',.F.})
        //Aadd(aRet,{'beneficiaryRegistryType','BFE_TIPREG',.F.})
        Aadd(aRet,{'healthProductCode','BRV_CODPLA',.F.})
        Aadd(aRet,{'healthProductVersion','BRV_VERSAO',.F.})
        //Aadd(aRet,{'contractNumber','BRV_NUMCON',.F.})
        //Aadd(aRet,{'contractVersion','BRV_VERCON',.F.})
        //Aadd(aRet,{'subcontractNumber','BRV_SUBCON',.F.})
        //Aadd(aRet,{'subcontractVersion','BRV_VERSUB',.F.})
        //Aadd(aRet,{'waitingPeriod','BRV_CARENC',.F.})
        //Aadd(aRet,{'waitingPeriodUnit','BRV_UNCAR',.F.})      
    /*-----------------------------------------------
    API: batchesAuthorization/integration
    Acoes: _billing_BCI_alt         "0050" 
    -------------------------------------------------*/
    Case cAlias == "BCI"
         Aadd(aRet,{'batchNumber','BCI_LOTGUI',.F.})
        Aadd(aRet,{'healthProviderId','BCI_CODRDA',.F.})
        Aadd(aRet,{'status','BCI_STTISS',.F.})
        Aadd(aRet,{'value','BCI_VLRGUI',.F.})  
        Aadd(aRet,{'glossedValue','BCI_VLRGLO',.F.})
        Aadd(aRet,{'step','BCI_FASE',.F.})

    /*-----------------------------------------------
    API: coverages/groupLevel
    Acoes: _coverageGroupLevel_BG8_inc         "0051" 
           _coverageGroupLevel_BG8_alt         "0052" 
    -------------------------------------------------*/
    Case cAlias == "BG8"
        Aadd(aRet,{"procedureCode","BG8_CODPSA",.F.})  
        Aadd(aRet,{"active","BG8_BENUTL",.F.})  
        Aadd(aRet,{"authorization","BG8_AUTORI",.F.})  
        Aadd(aRet,{"waitingPeriod","BG8_CARENC",.F.})  
        Aadd(aRet,{"waitingPeriodUnit","BG8_UNCAR",.F.})  
        Aadd(aRet,{"level","BG8_NIVEL",.F.})  
        Aadd(aRet,{"validWaitingPeriodLevel","BG8_NIVCAR",.F.})  
        Aadd(aRet,{"allowedQuantity","BG8_QTD",.F.})  
        Aadd(aRet,{"quantityUnit","BG8_UNCA",.F.})  
        Aadd(aRet,{"period","BG8_PERIOD",.F.})  
        Aadd(aRet,{"periodUnit","BG8_UNPERI",.F.})  
        Aadd(aRet,{"quantityBySpecialty","BG8_QTDESP",.F.})  
        Aadd(aRet,{"gender","BG8_SEXO",.F.})  
        Aadd(aRet,{"quantityByHealthProvider","BG8_QTDMED",.F.})  
        Aadd(aRet,{"minimumAge","BG8_IDAMIN",.F.})  
        Aadd(aRet,{"quantityByDisease","BG8_QTDPAT",.F.})  
        Aadd(aRet,{"maximumAge","BG8_IDAMAX",.F.})  
        Aadd(aRet,{"periodByHealthProvider","BG8_PTRMED",.F.})  
        Aadd(aRet,{"periodBySpecialty","BG8_PTRESP",.F.})  
        Aadd(aRet,{"periodByDisease","BG8_PTRPAT",.F.})  
        Aadd(aRet,{"procedureTableCode","BG8_CODPAD",.F.})  
        Aadd(aRet,{"waitingPeriodClass","BG8_CLACAR",.F.})  

    /*-----------------------------------------------
    API: authorizations
    Acoes: _Cancel_BEA_atu                     "0053" 
    -------------------------------------------------*/
    Case cAlias == "BEA"
        Aadd(aRet,{"motivoCancelamento","BEA_CANEDI",.F.})  
        Aadd(aRet,{"idOnHealthInsurer","BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT",.F.})  
 
EndCase

Return aRet
//