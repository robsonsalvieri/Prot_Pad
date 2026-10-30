#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBts - Lives
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBts from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBts
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBts

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"lifeRegistration",self:getValue("BTS_MATVID")) 
    oJsonControl:setProp(oJson,"name",self:getValue("BTS_NOMUSR")) 
    oJsonControl:setProp(oJson,"nickname",self:getValue("BTS_SOBRN")) 
    oJsonControl:setProp(oJson,"nameForBadge",self:getValue("BTS_NOMCAR")) 
    oJsonControl:setProp(oJson,"dateOfBirth",self:getValue("BTS_DATNAS")) 
    oJsonControl:setProp(oJson,"sex",self:getValue("BTS_SEXO")) 
    oJsonControl:setProp(oJson,"maritalStatus",self:getValue("BTS_ESTCIV")) 
    oJsonControl:setProp(oJson,"cpfCnpj",self:getValue("BTS_CPFUSR")) 
    oJsonControl:setProp(oJson,"pisPasedNumber",self:getValue("BTS_PISPAS")) 
    oJsonControl:setProp(oJson,"userRg",self:getValue("BTS_DRGUSR")) 
    oJsonControl:setProp(oJson,"issuedBy",self:getValue("BTS_ORGEM")) 
    oJsonControl:setProp(oJson,"stateIssuingDoc",self:getValue("BTS_RGEST")) 
    oJsonControl:setProp(oJson,"healthNationalCardNbr",self:getValue("BTS_NRCRNA")) 
    oJsonControl:setProp(oJson,"originOfAddress",self:getValue("BTS_ORIEND")) 
    oJsonControl:setProp(oJson,"relationWithOperator",self:getValue("BTS_RELAOP")) 
    oJsonControl:setProp(oJson,"userZipCode",self:getValue("BTS_CEPUSR")) 
    oJsonControl:setProp(oJson,"userAddress",self:getValue("BTS_ENDERE")) 
    oJsonControl:setProp(oJson,"addressNumber",self:getValue("BTS_NR_END")) 
    oJsonControl:setProp(oJson,"addressComplement",self:getValue("BTS_COMEND")) 
    oJsonControl:setProp(oJson,"userDistrict",self:getValue("BTS_BAIRRO")) 
    oJsonControl:setProp(oJson,"cityCode",self:getValue("BTS_CODMUN")) 
    oJsonControl:setProp(oJson,"userSCity",self:getValue("BTS_MUNICI")) 
    oJsonControl:setProp(oJson,"userState",self:getValue("BTS_ESTADO")) 
    oJsonControl:setProp(oJson,"cityCode",self:getValue("BTS_DDD")) 
    oJsonControl:setProp(oJson,"telephone",self:getValue("BTS_TELEFO")) 
    oJsonControl:setProp(oJson,"univStudAndUser",self:getValue("BTS_UNIVER")) 
    oJsonControl:setProp(oJson,"confinedPatient",self:getValue("BTS_INTERD")) 
    oJsonControl:setProp(oJson,"skinColor",self:getValue("BTS_CORNAT")) 
    oJsonControl:setProp(oJson,"bloodType",self:getValue("BTS_SANGUE")) 
    oJsonControl:setProp(oJson,"photo",self:getValue("BTS_BITMAP")) 
    oJsonControl:setProp(oJson,"functionCode",self:getValue("BTS_CODFUN")) 
    oJsonControl:setProp(oJson,"unhealthy",self:getValue("BTS_INSALU")) 
    oJsonControl:setProp(oJson,"section",self:getValue("BTS_CODSET")) 
    oJsonControl:setProp(oJson,"weightGr",self:getValue("BTS_PESO")) 
    oJsonControl:setProp(oJson,"heightCm",self:getValue("BTS_ALTURA")) 
    oJsonControl:setProp(oJson,"obesity",self:getValue("BTS_OBESO")) 
    oJsonControl:setProp(oJson,"eMail",self:getValue("BTS_EMAIL")) 
    oJsonControl:setProp(oJson,"religionCode",self:getValue("BTS_CODREL")) 
    oJsonControl:setProp(oJson,"ward",self:getValue("BTS_TUTELA")) 
    oJsonControl:setProp(oJson,"physicallyDisabled",self:getValue("BTS_DEFFIS")) 
    oJsonControl:setProp(oJson,"invalid",self:getValue("BTS_INVALI")) 
    oJsonControl:setProp(oJson,"dateOfDeath",self:getValue("BTS_DATOBI")) 
    oJsonControl:setProp(oJson,"motherBirthdate",self:getValue("BTS_DATMAE")) 
    oJsonControl:setProp(oJson,"nameOfMother",self:getValue("BTS_MAE")) 
    oJsonControl:setProp(oJson,"motherCpf",self:getValue("BTS_CPFMAE")) 
    oJsonControl:setProp(oJson,"fatherName",self:getValue("BTS_PAI")) 
    oJsonControl:setProp(oJson,"fatherBirthdate",self:getValue("BTS_DATPAI")) 
    oJsonControl:setProp(oJson,"fatherCpf",self:getValue("BTS_CPFPAI")) 
    oJsonControl:setProp(oJson,"employeeName",self:getValue("BTS_NOMPRE")) 
    oJsonControl:setProp(oJson,"cptDate",self:getValue("BTS_DATCPT")) 
    oJsonControl:setProp(oJson,"employeeCpf",self:getValue("BTS_CPFPRE")) 
    oJsonControl:setProp(oJson,"donor",self:getValue("BTS_DOADOR")) 
    oJsonControl:setProp(oJson,"employeeSNationality",self:getValue("BTS_NACION")) 
    oJsonControl:setProp(oJson,"ediIdentityCode",self:getValue("BTS_CDIDEN")) 
    oJsonControl:setProp(oJson,"cdOfEdiIssuerCountry",self:getValue("BTS_CDPAIS")) 
    oJsonControl:setProp(oJson,"nameEdiIssuerCountry",self:getValue("BTS_NMPAIS")) 
    oJsonControl:setProp(oJson,"ediIssuerAgency",self:getValue("BTS_ORGEMI")) 
    oJsonControl:setProp(oJson,"reducedName",self:getValue("BTS_NOMRED")) 
    oJsonControl:setProp(oJson,"statementOfLiveBirth",self:getValue("BTS_DENAVI")) 
    oJsonControl:setProp(oJson,"typeOfPerson",self:getValue("BTS_TIPPES")) 
    oJsonControl:setProp(oJson,"tradeName",self:getValue("BTS_NOMFAN")) 
    oJsonControl:setProp(oJson,"stateRegistration",self:getValue("BTS_INSCES")) 
    oJsonControl:setProp(oJson,"faxNumber",self:getValue("BTS_NUMFAX")) 
    oJsonControl:setProp(oJson,"isertionDate",self:getValue("BTS_DTINC")) 
    oJsonControl:setProp(oJson,"cityRegistration",self:getValue("BTS_INSCMU")) 
    oJsonControl:setProp(oJson,"webPage",self:getValue("BTS_PAGWEB")) 
    oJsonControl:setProp(oJson,"cnes",self:getValue("BTS_CNESPE")) 
    oJsonControl:setProp(oJson,"stateBoardAcronym",self:getValue("BTS_SIGLCR")) 
    oJsonControl:setProp(oJson,"acronymOfSecStBoard",self:getValue("BTS_SIGCR2")) 
    oJsonControl:setProp(oJson,"stateBoardLocation",self:getValue("BTS_ESTACR")) 
    oJsonControl:setProp(oJson,"stateOfSecStBoard",self:getValue("BTS_ESTCR2")) 
    oJsonControl:setProp(oJson,"stateBoardNumber",self:getValue("BTS_NUMECR")) 
    oJsonControl:setProp(oJson,"stateBoardRegDate",self:getValue("BTS_DTINSC")) 
    oJsonControl:setProp(oJson,"numberOfSecStBoard",self:getValue("BTS_NUMCR2")) 
    oJsonControl:setProp(oJson,"dateOfSecStBoardReg",self:getValue("BTS_DTINS2")) 
    oJsonControl:setProp(oJson,"civilIdRegistration",self:getValue("BTS_RGIDCV")) 
    oJsonControl:setProp(oJson,"voterId",self:getValue("BTS_TITELE")) 
    oJsonControl:setProp(oJson,"communicationPreference",self:getValue("BTS_COMUNI")) 
    oJsonControl:setProp(oJson,"birthCityCode",self:getValue("BTS_CDMNAS")) 
    oJsonControl:setProp(oJson,"birthCity",self:getValue("BTS_MUNNAS")) 
    oJsonControl:setProp(oJson,"birthState",self:getValue("BTS_ESTNAS")) 
    oJsonControl:setProp(oJson,"bankCode",self:getValue("BTS_BANCO")) 
    oJsonControl:setProp(oJson,"addressType",self:getValue("BTS_TIPEND")) 
    oJsonControl:setProp(oJson,"residenceCiyCode",self:getValue("BTS_MUNRES")) 
    oJsonControl:setProp(oJson,"branch",self:getValue("BTS_AGENC")) 
    oJsonControl:setProp(oJson,"livesAbroad",self:getValue("BTS_RESEXT")) 
    oJsonControl:setProp(oJson,"accountNumber",self:getValue("BTS_CONTA")) 
    oJsonControl:setProp(oJson,"adoptionDate",self:getValue("BTS_DATADT")) 
    oJsonControl:setProp(oJson,"dateOfSocialName",self:getValue("BTS_DATSOC")) 
    oJsonControl:setProp(oJson,"socialName",self:getValue("BTS_NOMSOC")) 
    oJsonControl:setProp(oJson,"useOfSocialName",self:getValue("BTS_USASOC")) 
    oJsonControl:setProp(oJson,"phoneType",self:getValue("BTS_TIPTEL")) 
    oJsonControl:setProp(oJson,"genderOfBeneficiary",self:getValue("BTS_GENSOC")) 

Return oJson

Method destroy() Class PLSBts
	_Super:destroy()
	DelClassIntF()
return