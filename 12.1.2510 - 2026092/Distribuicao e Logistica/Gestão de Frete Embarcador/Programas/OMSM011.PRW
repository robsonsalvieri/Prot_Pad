#INCLUDE "PROTHEUS.CH" 
#INCLUDE "OMSM010.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} OMSM011
	(Programa apenas para redirecionamento das funções para o programa GFEM011)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011()
Return GFEM011()

/*/{Protheus.doc} OsM011Leg
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OsM011Leg()
Return GFEM011Leg()

/*/{Protheus.doc} OsM011Mrk
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OsM011Mrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)
Return GFEM011Mrk(aListBox,nItem,lRefresh,lUmItem,lRetMark)

/*/{Protheus.doc} OsM011All
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OsM011All(aListBox)
Return GFEM011All(aListBox)

/*/{Protheus.doc} OsM011Proc
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OsM011Proc(aListBox)
Return GFEM011Proc(aListBox)

/*/{Protheus.doc} OsM011Rot
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OsM011Rot(aListBox)
Return GFEM011Rot(aListBox)

/*/{Protheus.doc} OsM011Fil
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OsM011Fil(aListBox)
Return GFEM011Fil(aListBox)

/*/{Protheus.doc} OMSM011IPG
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011IPG(cProTable,ArqvLog)
Return GFEM011IPG(cProTable,ArqvLog)

/*/{Protheus.doc} OMSM011DAK
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011DAK(cTipoInter,aDados,aDadosItens,cProTable,cRotiProt,ArqvLog,lCommit)
Return GFEM011DAK(cTipoInter,aDados,aDadosItens,cProTable,cRotiProt,ArqvLog,lCommit)

/*/{Protheus.doc} OMSM011NFS
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011NFS(cTipoInter,cNumNFS,cSerieNFS,cProTable,cRotiProt,ArqvLog)
Return GFEM011NFS(cTipoInter,cNumNFS,cSerieNFS,cProTable,cRotiProt,ArqvLog)

/*/{Protheus.doc} OMSM011NFE
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011NFE(cTipoInter,aDados,aDadosItens,cProTable,cRotiProt,ArqvLog,lCommit)
Return GFEM011NFE(cTipoInter,aDados,aDadosItens,cProTable,cRotiProt,ArqvLog,lCommit)

/*/{Protheus.doc} OMSM011GW0
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011GW0()
Return GFEM011GW0()

/*/{Protheus.doc} OMSM011COD
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011COD(cCod,cLoja,nForCli,lFilial,cFil)
Return GFEM011COD(cCod,cLoja,nForCli,lFilial,cFil)

/*/{Protheus.doc} OMSM011TRP
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011TRP(cA2_CGC, cA2_INSCR)
Return GFEM011TRP(cA2_CGC, cA2_INSCR)

/*/{Protheus.doc} OMSM011RED
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011RED(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc,cFilOri,cViagem,cFilRed)
Return GFEM011RED(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc,cFilOri,cViagem,cFilRed)

/*/{Protheus.doc} OMSM011DFT
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011DFT(nOperation,cChvGFE,cCdtpop,cCdclfr,cUfOri,cCdMunO,cUfDes,cCdMunD,nReqDTQ,cCepOri,cCepDes,aCalcRom, lCalcAut)
Return GFEM011DFT(nOperation,cChvGFE,cCdtpop,cCdclfr,cUfOri,cCdMunO,cUfDes,cCdMunD,nReqDTQ,cCepOri,cCepDes,aCalcRom, lCalcAut)

/*/{Protheus.doc} OMSM011DFV
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011DFV(nRecnoDFV, ArqvLog, lViagem, nRecnoDUD)
Return GFEM011DFV(nRecnoDFV, ArqvLog, lViagem, nRecnoDUD)

/*/{Protheus.doc} OMSM011TRE
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011TRE(nOpc,oModelNFS,oModelTrechos,cCdTpDc,cEmisDc,cUfDes,cCdMunDes,cNumNFC,cSerNFC,cTransp,nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,cA1_CEPDes,cCodFor,cLojFor)
Return GFEM011TRE(nOpc,oModelNFS,oModelTrechos,cCdTpDc,cEmisDc,cUfDes,cCdMunDes,cNumNFC,cSerNFC,cTransp,nTrecho,cA1_EstDes,cA1_CdMuDes,cTipVei,lViagem,cA1_CEPDes,cCodFor,cLojFor)

/*/{Protheus.doc} OMSM011TMS
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011TMS(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc)
Return GFEM011TMS(cTipoInter,cNumRed,cCodFor,cLojFor,cProTable,cRotiProt,ArqvLog,nOpc)

/*/{Protheus.doc} OMSM011VGE
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011VGE(cFilOri, cViagem, nOpc, ArqvLog)
Return GFEM011VGE(cFilOri, cViagem, nOpc, ArqvLog)

/*/{Protheus.doc} OMS11TRRDA
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMS11TRRDA(nOpc,oModelNFS,oModelTrechos,nTrecho,cSeq,lNumProp,cA1_CEPDes,cCdTpDc,lViagem)
Return GFEM11TRRDA(nOpc,oModelNFS,oModelTrechos,nTrecho,cSeq,lNumProp,cA1_CEPDes,cCdTpDc,lViagem)

/*/{Protheus.doc} OMSM011GWE
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011GWE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cNumRed)
Return GFEM011GWE(cFilDoc,cDoc,cSerie,cFilOri,cViagem,cNumRed)

/*/{Protheus.doc} OMSM011SOL
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011SOL(cFilOri,cNumSol,oMdGridGXP)
Return GFEM011SOL(cFilOri,cNumSol,oMdGridGXP)

/*/{Protheus.doc} OMSM011GXP
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSM011GXP(oMdGridGXP,cNfeId,cFilOri,cEmisDTC,cSerNfc,cNumNfc,oMdGridGXP)
Return GFEM011GXP(oMdGridGXP,cNfeId,cFilOri,cEmisDTC,cSerNfc,cNumNfc,oMdGridGXP)

/*/{Protheus.doc} OMSEMITMP
	(long_description)
	@type  Function
	@author SIGAGFE
	@since 16/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OMSEMITMP()
Return GFEEMITMP()
