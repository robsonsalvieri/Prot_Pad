#include 'protheus.ch'

Function OFCNH0020();Return

/*/{Protheus.doc} OFCNHPrimWsFile
	Classe para guardar dados de arquivos do webservice
	
	@type function
	@author Vinicius Gati
	@since 16/03/2018
/*/ 
Class OFCNHPrimWsFile
	Data cMarket
	Data cCustomer
	Data cFileId
	Data cFileName
	Data cDescFile
	Data cFileStatus
	Data cSize
	Data cCreate
	Data cExtension
	Data cMd5Checksum
	Data cControlledPath
	Data cWorkingMode
	Data cAcquire
	Data cError
	Data cDescError
	Data cRecPhysical
	Data cRecLogical
	Data cErrLine
	Data cErrColumn
	Data cFieldName
	Data cDownload
	Data cCompress
	Data cEncoding

	Data cFullFilePath

	Method New() CONSTRUCTOR
	Method SetAttr()
	Method ToString()
	Method RealFileName()
EndClass

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Vinicius Gati
	@since 16/03/2018
/*/
Method New() Class OFCNHPrimWsFile
Return SELF

/*/{Protheus.doc} SetAttr
	Seta o atributo no lugar correto dependendo da tag

	@type function
	@author Vinicius Gati
	@since 17/03/2018
/*/
Method SetAttr(cAttr, cVal) Class OFCNHPrimWsFile
	do case
		case cAttr == 'c_market'
			self:cMarket := cVal
		case cAttr == 'c_customer'
			self:cCustomer := cVal
		case cAttr == 'c_file_id'
			self:cFileId := cVal
		case cAttr == 'c_file_name'
			self:cFileName := cVal
		case cAttr == 'desc_file'
			self:cDescFile := cVal
		case cAttr == 'c_file_status'
			self:cFileStatus := cVal
		case cAttr == 'n_size'
			self:cSize := cVal
		case cAttr == 'd_create'
			self:cCreate := cVal
		case cAttr == 'c_extension'
			self:cExtension := cVal
		case cAttr == 'c_md5_checksum'
			self:cMd5Checksum := cVal
		case cAttr == 'c_controlled_path'
			self:cControlledPath := cVal
		case cAttr == 'c_working_mode'
			self:cWorkingMode := cVal
		case cAttr == 'd_acquire'
			self:cAcquire := cVal
		case cAttr == 'c_error'
			self:cError := cVal
		case cAttr == 'desc_error'
			self:cDescError := cVal
		case cAttr == 'n_rec_physical'
			self:cRecPhysical := cVal
		case cAttr == 'n_rec_logical'
			self:cRecLogical := cVal
		case cAttr == 'n_err_line'
			self:cErrLine := cVal
		case cAttr == 'n_err_column'
			self:cErrColumn := cVal
		case cAttr == 'c_field_name'
			self:cFieldName := cVal
		case cAttr == 'n_download'
			self:cDownload := cVal
		case cAttr == 'c_compress'
			self:cCompress := cVal
		case cAttr == 'c_encoding'
			self:cEncoding := cVal
	end do
Return

/*/{Protheus.doc} ToString
	Representação em string do arquivo

	@type function
	@author Vinicius Gati
	@since 23/03/2018
/*/
Method ToString() Class OFCNHPrimWsFile
	local cRep := ''
	cRep += self:cFileId + " = " + self:cFileName + " [" + self:cFileStatus + "][" + self:cCreate + "] "
Return cRep

/*/{Protheus.doc} RealFileName
	Retorna o nome do arquivo interno do zipado, ele tem um padrão e será utilizada para o upload
	
	@type function
	@author Vinicius Gati
	@since 09/04/2018
/*/
Method RealFileName() Class OFCNHPrimWsFile
local oConfig := OFCNHPrimConfig():New( .T. )

	do case
	case 'prim01' $ lower(self:cFileName)
		return oConfig:cMarket + "_prim_prim01_" + self:cFileId
	end do
Return oConfig:cMarket + "_" + oConfig:cDealerCode + '_' + self:cFileName + '_' + self:cFileId
