#INCLUDE "TOTVS.CH"

#DEFINE DIOPS	 	"3"
#DEFINE MONIT	 	"5"

/*/{Protheus.doc} CenCmdRzT

    @type  Class
    @author david.juan
    @since 20201209
/*/
Class CenCmdRzT From CenCommand

    Data oExecutor      As Object
    Data oContDiops     As Object
    Data oCampMonit     As Object
    Data oCampDiops     As Object
    Data nNumerador     As Numeric
    Data nDenominador   As Numeric
    Data nParcialRes    As Numeric
    Data nRazaoTISS     As Numeric
    Data cOper          As String
    Data cAnoRef        As String

    Method New(oExecutor) Constructor
    Method execute()
    Method Destroy()
    Method camposMonit()
    Method camposDiops()
    Method contasDiops()
    Method setOper(cOper)
    Method setAno(cAnoRef)
    Method gravaResult()
    Method geraTotais()

EndClass

Method New(oExecutor) Class CenCmdRzT
    self:oExecutor      := oExecutor
    self:oContDiops     := tHashMap():New()
    self:oCampMonit     := tHashMap():New()
    self:oCampDiops     := tHashMap():New()
    self:nNumerador     := 0
    self:nDenominador   := 0
    self:nRazaoTISS     := 0
    self:nParcialRes    := 0
Return self

Method execute() Class CenCmdRzT
    self:oExecutor:setValue("healthInsurerCode", self:cOper)
    self:oExecutor:setValue("referenceYear", self:cAnoRef)
    self:camposMonit()
    self:camposDiops()
    self:contasDiops()
    self:geraTotais()
    self:gravaResult()
Return

Method setOper(cOper) Class CenCmdRzT
    Default cOper := ''
    self:cOper := cOper
Return

Method setAno(cAnoRef) Class CenCmdRzT
    Default cAnoRef := cValToChar(Year(Date()))
    self:cAnoRef := cAnoRef
Return

Method gravaResult() Class CenCmdRzT
    self:nParcialRes := self:nNumerador / self:nDenominador

    Do Case
        Case self:nParcialRes < 0.5 .OR. self:nParcialRes > 1.1
            self:nRazaoTISS := 0
        Case self:nParcialRes >= 0.5 .AND. self:nParcialRes < 0.9
            self:nRazaoTISS := self:nParcialRes
        Case self:nParcialRes >= 0.9 .AND. self:nParcialRes <= 1.1
            self:nRazaoTISS := 1
    EndCase

    self:oExecutor:setValue("numeratorTissRatio", self:nNumerador)
    self:oExecutor:setValue("denominatorTissRatio", self:nDenominador)
    self:oExecutor:setValue("partialTissRatio", self:nParcialRes)
    self:oExecutor:setValue("totalTissRatio", self:nRazaoTISS)
    If self:oExecutor:bscChaPrim()
        self:oExecutor:update()
    Else
        self:oExecutor:insert()
    EndIf
Return

Method geraTotais() Class CenCmdRzT
    Local cCampoRet     := ''
    Local nCampo        := 1
    Local cTipoObrig

    cTipoObrig     := MONIT
    While self:oCampMonit:Get(nCampo, @cCampoRet)
        Self:oExecutor:cAliasAux := SubStr(cCampoRet,1,3)
        Self:nNumerador += self:oExecutor:getVlrRzTISS(cCampoRet, cTipoObrig)
        nCampo++
    EndDo

    nCampo := 1
    cTipoObrig     := DIOPS
    While self:oCampDiops:Get(nCampo, @cCampoRet)
        Self:oExecutor:cAliasAux := SubStr(cCampoRet,1,3)
        Self:nDenominador += self:oExecutor:getVlrRzTISS(cCampoRet, cTipoObrig, self:oContDiops)
        nCampo++
    EndDo
Return

Method camposMonit() Class CenCmdRzT

    self:oCampMonit:Set(1,"BKR_VLTINF") // campo 050 Valor informado da guia"
    self:oCampMonit:Set(2,"B9T_VLRPRE") // campo 094 Valor da cobertura contratada na competência"
    self:oCampMonit:Set(3,"BVQ_VLTGUI") // campo 103 Valor total dos itens fornecidos"
    self:oCampMonit:Set(4,"BVZ_VLTINF") // campo 116 Valor total informado enviados pela operadora e incorporados ao banco de dados da ANS"

Return self:oCampMonit

Method camposDiops() Class CenCmdRzT

    self:oCampDiops:Set(1,"B8A_SALFIN") // https://tdn.totvs.com/display/PROT/Tabela+B8A-Balancete+Trimestral

Return self:oCampDiops

Method contasDiops() Class CenCmdRzT

    self:oContDiops:Set(1   ,"311711011")    // "Cobertura Assistencial com Preço Preestabelecido"
    self:oContDiops:Set(2   ,"311711013")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(3   ,"311711021")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(4   ,"311711023")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(5   ,"311711031")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(6   ,"311711033")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(7   ,"311711041")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(8   ,"311711043")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(9   ,"311711051")    // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(10  ,"311711053")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(11  ,"311711061")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(12  ,"311711063")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(13  ,"311712011")   // "Cobertura Assistencial com Preço Pós-estabelecido"
    self:oContDiops:Set(14  ,"311712031")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(15  ,"311712033")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(16  ,"311712041")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(17  ,"311712043")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(18  ,"311712051")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(19  ,"311712053")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(20  ,"311712061")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(21  ,"311712063")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(22  ,"311721011")   // "Cobertura Assistencial com Preço Preestabelecido"
    self:oContDiops:Set(23  ,"311721013")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(24  ,"311721021")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(25  ,"311721023")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(26  ,"311721031")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(27  ,"311721033")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(28  ,"311721041")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(29  ,"311721043")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(30  ,"311721051")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(31  ,"311721053")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(32  ,"311721061")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(33  ,"311721063")   // "Cobertura Assistencial com Preço Preestabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(34  ,"311722011")   // "Cobertura Assistencial com Preço Pós-estabelecido"
    self:oContDiops:Set(35  ,"311722031")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(36  ,"311722033")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(37  ,"311722041")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(38  ,"311722043")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(39  ,"311722051")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(40  ,"311722052")   // "Recuperação por co-participação na cobertura com preço pós-estabelecido com corresponssabilidade cedida em preço preestabelecido"
    self:oContDiops:Set(41  ,"311722053")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(42  ,"311722061")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Preestabelecido"
    self:oContDiops:Set(43  ,"311722063")   // "Cobertura Assistencial com Preço Pós-estabelecido com Corresponsabilidade Cedida em Preço Pós-estabelecido"
    self:oContDiops:Set(44  ,"411111011")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(45  ,"411111017")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(46  ,"411111021")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(47  ,"411111027")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(48  ,"411111031")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(49  ,"411111037")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(50  ,"411111041")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(51  ,"411111047")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(52  ,"411111051")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(53  ,"411111057")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(54  ,"411111061")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(55  ,"411111067")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(56  ,"411112031")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(57  ,"411112037")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(58  ,"411112041")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(59  ,"411112047")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(60  ,"411112051")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(61  ,"411112057")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(62  ,"411112061")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(63  ,"411112067")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(64  ,"411121011")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(65  ,"411121017")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(66  ,"411121021")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(67  ,"411121027")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(68  ,"411121031")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(69  ,"411121037")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(70  ,"411121041")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(71  ,"411121047")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(72  ,"411121051")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(73  ,"411121057")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(74  ,"411121061")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(75  ,"411121067")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(76  ,"411122031")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(77  ,"411122037")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(78  ,"411122041")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(79  ,"411122047")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(80  ,"411122051")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(81  ,"411122057")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(82  ,"411122061")   // "Despesas com Eventos / Sinistros na modalidade de pagamento por procedimento"
    self:oContDiops:Set(83  ,"411122067")   // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(84  ,"411211011")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(85  ,"411211021")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(86  ,"411211031")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(87  ,"411211041")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(88  ,"411211051")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(89  ,"411211061")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(90  ,"411212031")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(91  ,"411212041")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(92  ,"411212051")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(93  ,"411212061")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(94  ,"411221011")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(95  ,"411221021")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(96  ,"411221031")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(97  ,"411221041")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(98  ,"411221051")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(99  ,"411221061")   // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(100 ,"411222031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(101 ,"411222041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(102 ,"411222051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(103 ,"411222061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(104 ,"411311011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(105 ,"411311021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(106 ,"411311031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(107 ,"411311041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(108 ,"411311051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(109 ,"411311061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(110 ,"411312031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(111 ,"411312041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(112 ,"411312051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(113 ,"411312061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(114 ,"411321011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(115 ,"411321021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(116 ,"411321031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(117 ,"411321041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(118 ,"411321051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(119 ,"411321061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(120 ,"411322031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(121 ,"411322041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(122 ,"411322051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(123 ,"411322061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(124 ,"411411011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(125 ,"411411017")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(126 ,"411411021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(127 ,"411411027")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(128 ,"411411031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(129 ,"411411037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(130 ,"411411041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(131 ,"411411047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(132 ,"411411051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(133 ,"411411057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(134 ,"411411061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(135 ,"411411067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(136 ,"411412031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(137 ,"411412037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(138 ,"411412041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(139 ,"411412047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(140 ,"411412051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(141 ,"411412057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(142 ,"411412061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(143 ,"411412067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(144 ,"411421011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(145 ,"411421017")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(146 ,"411421021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(147 ,"411421027")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(148 ,"411421031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(149 ,"411421037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(150 ,"411421041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(151 ,"411421047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(152 ,"411421051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(153 ,"411421057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(154 ,"411421061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(155 ,"411421067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(156 ,"411422031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(157 ,"411422037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(158 ,"411422041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(159 ,"411422047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(160 ,"411422051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(161 ,"411422057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(162 ,"411422061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(163 ,"411422067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(164 ,"411511011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(165 ,"411511021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(166 ,"411511031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(167 ,"411511041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(168 ,"411511051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(169 ,"411511061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(170 ,"411512031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(171 ,"411512041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(172 ,"411512051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(173 ,"411512061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(174 ,"411521011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(175 ,"411521021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(176 ,"411521031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(177 ,"411521041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(178 ,"411521051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(179 ,"411521061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(180 ,"411522031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(181 ,"411522041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(182 ,"411522051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(183 ,"411522061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(184 ,"411711011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(185 ,"411711017")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(186 ,"411711021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(187 ,"411711027")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(188 ,"411711031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(189 ,"411711037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(190 ,"411711041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(191 ,"411711047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(192 ,"411711051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(193 ,"411711057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(194 ,"411711061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(195 ,"411711067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(196 ,"411712031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(197 ,"411712037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(198 ,"411712041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(199 ,"411712047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(200 ,"411712051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(201 ,"411712057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(202 ,"411712061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(203 ,"411712067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(204 ,"411721011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(205 ,"411721017")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(206 ,"411721021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(207 ,"411721027")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(208 ,"411721031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(209 ,"411721037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(210 ,"411721041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(211 ,"411721047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(212 ,"411721051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(213 ,"411721057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(214 ,"411721061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(215 ,"411721067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(216 ,"411722031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(217 ,"411722037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(218 ,"411722041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(219 ,"411722047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(220 ,"411722051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(221 ,"411722057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(222 ,"411722061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(223 ,"411722067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(224 ,"411911011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(225 ,"411911017")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(226 ,"411911021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(227 ,"411911027")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(228 ,"411911031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(229 ,"411911037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(230 ,"411911041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(231 ,"411911047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(232 ,"411911051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(233 ,"411911057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(234 ,"411911061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(235 ,"411911067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(236 ,"411912031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(237 ,"411912037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(238 ,"411912041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(239 ,"411912047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(240 ,"411912051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(241 ,"411912057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(242 ,"411912061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(243 ,"411912067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(244 ,"411921011")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(245 ,"411921017")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(246 ,"411921021")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(247 ,"411921027")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(248 ,"411921031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(249 ,"411921037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(250 ,"411921041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(251 ,"411921047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(252 ,"411921051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(253 ,"411921057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(254 ,"411921061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(255 ,"411921067")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(256 ,"411922031")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(257 ,"411922037")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(258 ,"411922041")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(259 ,"411922047")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(260 ,"411922051")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(261 ,"411922057")  // "Despesas com Eventos/Sinistros - Judicial"
    self:oContDiops:Set(262 ,"411922061")  // "Despesas com Eventos / Sinistros"
    self:oContDiops:Set(263 ,"411922067")  // "Despesas com Eventos/Sinistros - Judicial"

Return self:oContDiops

Method Destroy() Class CenCmdRzT
    if self:oContDiops != nil
        FreeObj(self:oContDiops)
        self:oContDiops:= nil
    EndIf
    if self:oCampMonit != nil
        FreeObj(self:oCampMonit)
        self:oCampMonit:= nil
    EndIf
    if self:oCampDiops != nil
        FreeObj(self:oCampDiops)
        self:oCampDiops:= nil
    EndIf
Return