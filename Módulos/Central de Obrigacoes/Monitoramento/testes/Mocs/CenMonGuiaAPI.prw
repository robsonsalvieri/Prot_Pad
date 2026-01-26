#INCLUDE "PROTHEUS.CH"
#define CodOpePad "417505"

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonGuiaAPI
Classes para geracao de registros de guia BRA para casos de teste

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS CenMonGuiaAPI

	Data BRA_FILIAL as String
    Data BRA_CODOPE as String
    Data BRA_SEQGUI as String
    Data BRA_PROCES as String
	Data BRA_VTISPR as String
	Data BRA_FORENV as String //1- Portal    2-Upload de Arquivo   3-WebService    4-Papel
    Data BRA_CNES   as String
    Data BRA_IDEEXC as String
    Data BRA_CPFCNP as String
    Data BRA_CDMNEX as String
    Data BRA_RGOPIN as String
    Data BRA_MATRIC as String
    Data BRA_TPEVAT as String
    Data BRA_OREVAT as String
    Data BRA_NMGPRE as String
    Data BRA_NMGOPE as String
    Data BRA_IDEREE as String
    Data BRA_IDVLRP as String
    Data BRA_SOLINT as String
    Data BRA_DATSOL as String
    Data BRA_NMGPRI as String
    Data BRA_DATAUT as Date
    Data BRA_DATREA as Date
    Data BRA_DTINFT as Date
    Data BRA_DTFIFT as Date
    Data BRA_DTPROT as Date
    Data BRA_DTPAGT as Date
    Data BRA_DTPRGU as Date
    Data BRA_TIPCON as String
    Data BRA_CBOS   as String
    Data BRA_INAVIV as String
    Data BRA_INDACI as String
    Data BRA_TIPADM as String
    Data BRA_TIPINT as String
    Data BRA_REGINT as String
    Data BRA_TIPATE as String
    Data BRA_TIPFAT as String
    Data BRA_DIAACP as String
    Data BRA_DIAUTI as String
    Data BRA_MOTSAI as String
    Data BRA_CDCID1 as String
    Data BRA_CDCID2 as String
    Data BRA_CDCID3 as String
    Data BRA_CDCID4 as String
	Data BRA_DATINC as Date
	Data BRA_HORINC as String
	Data BRA_EXCLU  as String
    Data Eventos    as Array
	Data CertNasObt as Array

	Method New() CONSTRUCTOR
    Method Commit(lInclui)
	Method setEvento(oEvento)
	Method setCertif(oCertif1)
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonGuiaAPI
Construtor CenMonGuiaAPI

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD NEW() CLASS CenMonGuiaAPI

	self:BRA_FILIAL := xFilial("BRA")
    self:BRA_CODOPE := CodOpePad
    self:BRA_SEQGUI := ''
	self:BRA_VTISPR := '3.03.03'
    self:BRA_PROCES := '0'
	self:BRA_FORENV := ''
    self:BRA_CNES   := ''
    self:BRA_IDEEXC := ''
    self:BRA_CPFCNP := ''
    self:BRA_CDMNEX := ''
    self:BRA_RGOPIN := ''
    self:BRA_MATRIC := ''
    self:BRA_TPEVAT := ''
    self:BRA_OREVAT := ''
    self:BRA_NMGPRE := ''
    self:BRA_NMGOPE := ''
    self:BRA_IDEREE := ''
    self:BRA_IDVLRP := Replicate('0',20)
    self:BRA_SOLINT := ''
    self:BRA_DATSOL := Stod('')
    self:BRA_NMGPRI := ''
    self:BRA_DATAUT := Stod('')
    self:BRA_DATREA := Stod('')
    self:BRA_DTINFT := Stod('')
    self:BRA_DTFIFT := Stod('')
    self:BRA_DTPROT := Stod('')
    self:BRA_DTPAGT := Stod('')
    self:BRA_DTPRGU := Stod('')
    self:BRA_TIPCON := '1'
    self:BRA_CBOS   := ''
    self:BRA_INAVIV := 'N'//S=Sim;N=Nao;  
    self:BRA_INDACI := '9' //0=Relacionado ao trabalho;1=Acidente de Transito;2=Outros Acidente;9=Nao Acidente;
    self:BRA_TIPADM := '1' //Código do caráter do atendimento conforme tabela de domínio vigente na versão que a guia foi enviada.
    self:BRA_TIPINT := ''
    self:BRA_REGINT := ''
    self:BRA_TIPATE := '11' //Código do tipo de atendimento conforme tabela de domínio na versão que a guia foi enviada.
    self:BRA_TIPFAT := ''
    self:BRA_DIAACP := ''
    self:BRA_DIAUTI := ''
    self:BRA_MOTSAI := '12' //Código do motivo de encerramento do atendimento, conforme tabela de domínio nº 39.
    self:BRA_CDCID1 := ''
    self:BRA_CDCID2 := ''
    self:BRA_CDCID3 := ''
    self:BRA_CDCID4 := ''
	self:BRA_DATINC := dDataBase
	self:BRA_HORINC := Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)
	self:BRA_EXCLU  := '0'
    self:Eventos    := {}
	self:CertNasObt := {}

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Commit
Commit CenMonEventosAPI

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method setEvento(oEvento) Class CenMonGuiaAPI
	aadd(self:Eventos,oEvento)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Commit
Commit CenMonEventosAPI

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method setCertif(oCertif1) Class CenMonGuiaAPI
	aadd(self:CertNasObt,oCertif1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Commit
Commit CenMonEventosAPI

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method Commit(lInclui) Class CenMonGuiaAPI
	Local nX := 0
	Local nY := 0
    Default lInclui := .F.

	if BRA->(RecLock("BRA",lInclui))
		BRA->BRA_FILIAL := xFilial("BRA")
		if lInclui
			BRA->BRA_CODOPE	:= self:BRA_CODOPE
			BRA->BRA_SEQGUI	:= self:BRA_SEQGUI
		endIf
		BRA->BRA_PROCES	:= self:BRA_PROCES
		BRA->BRA_FORENV	:= self:BRA_FORENV
		BRA->BRA_CNES 	:= self:BRA_CNES 
		BRA->BRA_IDEEXC	:= self:BRA_IDEEXC
		BRA->BRA_CPFCNP	:= self:BRA_CPFCNP
		BRA->BRA_CDMNEX	:= self:BRA_CDMNEX
		BRA->BRA_RGOPIN	:= self:BRA_RGOPIN
		BRA->BRA_MATRIC	:= self:BRA_MATRIC
		BRA->BRA_TPEVAT	:= self:BRA_TPEVAT
		BRA->BRA_OREVAT	:= self:BRA_OREVAT
		BRA->BRA_NMGPRE	:= self:BRA_NMGPRE
		BRA->BRA_NMGOPE	:= self:BRA_NMGOPE
		BRA->BRA_IDEREE	:= self:BRA_IDEREE
		BRA->BRA_IDVLRP	:= self:BRA_IDVLRP
		BRA->BRA_SOLINT	:= self:BRA_SOLINT
		BRA->BRA_DATSOL	:= self:BRA_DATSOL
		BRA->BRA_NMGPRI	:= self:BRA_NMGPRI
		BRA->BRA_DATAUT	:= self:BRA_DATAUT
		BRA->BRA_DATREA	:= self:BRA_DATREA
		BRA->BRA_DTINFT	:= self:BRA_DTINFT
		BRA->BRA_DTFIFT	:= self:BRA_DTFIFT
		BRA->BRA_DTPROT	:= self:BRA_DTPROT
		BRA->BRA_DTPAGT	:= self:BRA_DTPAGT
		BRA->BRA_DTPRGU	:= self:BRA_DTPRGU
		BRA->BRA_TIPCON	:= self:BRA_TIPCON
		BRA->BRA_CBOS 	:= self:BRA_CBOS 
		BRA->BRA_INAVIV	:= self:BRA_INAVIV
		BRA->BRA_INDACI	:= self:BRA_INDACI
		BRA->BRA_TIPADM	:= self:BRA_TIPADM
		BRA->BRA_TIPINT	:= self:BRA_TIPINT
		BRA->BRA_REGINT	:= self:BRA_REGINT
		BRA->BRA_TIPATE	:= self:BRA_TIPATE
		BRA->BRA_TIPFAT	:= self:BRA_TIPFAT
		BRA->BRA_DIAACP	:= self:BRA_DIAACP
		BRA->BRA_DIAUTI	:= self:BRA_DIAUTI
		BRA->BRA_MOTSAI	:= self:BRA_MOTSAI
		BRA->BRA_CDCID1	:= self:BRA_CDCID1
		BRA->BRA_CDCID2	:= self:BRA_CDCID2
		BRA->BRA_CDCID3	:= self:BRA_CDCID3
		BRA->BRA_CDCID4	:= self:BRA_CDCID4
		BRA->BRA_DATINC := self:BRA_DATINC
		BRA->BRA_HORINC := self:BRA_HORINC
		BRA->BRA_EXCLU  := self:BRA_EXCLU 
		BRA->BRA_VTISPR := self:BRA_VTISPR

        BRA->(MsUnlock())
       
    endIf
	
	//Adiciona certiticados
	for nX := 1 to len(self:CertNasObt)
		if BNW->(RecLock("BNW",lInclui))	
			BNW->BNW_FILIAL := xFilial("BNW")
			if lInclui
				BNW->BNW_CODOPE := self:CertNasObt[nX]:BNW_CODOPE
				BNW->BNW_SEQGUI := self:CertNasObt[nX]:BNW_SEQGUI
			endIf	
			BNW->BNW_TIPO   := self:CertNasObt[nX]:BNW_TIPO
			BNW->BNW_DECNUM := self:CertNasObt[nX]:BNW_DECNUM
			
			BNW->(MsUnlock())
		endIf
	next

	//Adiciona Eventos
	for nX := 1 to len(self:Eventos)
		if BRB->(RecLock("BRB",lInclui))	
			BRB->BRB_FILIAL := xFilial("BRB")
			if lInclui
				BRB->BRB_CODOPE := self:Eventos[nX]:BRB_CODOPE
				BRB->BRB_SEQGUI := self:Eventos[nX]:BRB_SEQGUI
				BRB->BRB_SEQITE := self:Eventos[nX]:BRB_SEQITE
			endIf
			BRB->BRB_CODTAB := self:Eventos[nX]:BRB_CODTAB
			BRB->BRB_CODGRU := self:Eventos[nX]:BRB_CODGRU
			BRB->BRB_CODPRO := self:Eventos[nX]:BRB_CODPRO
			BRB->BRB_CDDENT := self:Eventos[nX]:BRB_CDDENT
			BRB->BRB_CDREGI := self:Eventos[nX]:BRB_CDREGI
			BRB->BRB_CDFACE := self:Eventos[nX]:BRB_CDFACE
			BRB->BRB_QTDINF := self:Eventos[nX]:BRB_QTDINF
			BRB->BRB_VLRINF := self:Eventos[nX]:BRB_VLRINF
			BRB->BRB_QTDPAG := self:Eventos[nX]:BRB_QTDPAG
			BRB->BRB_VLPGPR := self:Eventos[nX]:BRB_VLPGPR
			BRB->BRB_VLRPGF := self:Eventos[nX]:BRB_VLRPGF
			BRB->BRB_CNPJFR := self:Eventos[nX]:BRB_CNPJFR
			BRB->BRB_VLRCOP := self:Eventos[nX]:BRB_VLRCOP
			BRB->BRB_VLRGLO := self:Eventos[nX]:BRB_VLRGLO
			BRB->BRB_PACOTE := self:Eventos[nX]:BRB_PACOTE

			BRB->(MsUnlock())
		endIf

		for nY := 1 to len(self:Eventos[nX]:Pacotes)
			if BRC->(RecLock("BRC",lInclui))	
				BRC->BRC_FILIAL := xFilial("BRC")
				if lInclui
					BRC->BRC_FILIAL := self:Eventos[nX]:Pacotes[nY]:BRC_FILIAL 
					BRC->BRC_CODOPE := self:Eventos[nX]:Pacotes[nY]:BRC_CODOPE
					BRC->BRC_SEQGUI := self:Eventos[nX]:Pacotes[nY]:BRC_SEQGUI
					BRC->BRC_SEQITE := self:Eventos[nX]:Pacotes[nY]:BRC_SEQITE
				endIf	
				BRC->BRC_CDTBIT := self:Eventos[nX]:Pacotes[nY]:BRC_CDTBIT
				BRC->BRC_CDPRIT := self:Eventos[nX]:Pacotes[nY]:BRC_CDPRIT
				BRC->BRC_QTPRPC := self:Eventos[nX]:Pacotes[nY]:BRC_QTPRPC

				BRC->(MsUnlock())
			endIf
		next
	next
Return