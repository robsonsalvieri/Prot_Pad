<?xml version='1.0' encoding='ISO-8859-1' ?>
<xsl:stylesheet version = "2.0" xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
    <xsl:template match = "/">
        <html>
            <body>
                <h1>
                    <font face = "Arial">
                        <u>
                            <center>Solicitação de Shipping Instruction</center>
                        </u>
                    </font>
                </h1>
                <p>
                    <br/>
                    <b>
                        <font face = "Arial">Número de referência exportadores:</font>
                    </b>
                    <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='ExportersReferenceNumber']"/>
                </p>
                <p>
                    <b>
                        <font face = "Arial">Número do Contrato:</font>
                    </b>
                    <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='ContractNumber']"/>
                </p>
                <p>
                    <b>
                        <font face = "Arial">Número de Referência do Processo:</font>
                    </b>
                    <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='PurchaseOrderNumber']"/>
                </p>
                <p>
                    <b>
                        <font face = "Arial">Número do Booking no Armador:</font>
                    </b>
                    <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='ShipperIdentifyingNumber']"/>
                </p>
                <p>
                    <br/>
                </p>
                <table
                    frame = "border"
                    rules = "all"
                    Border = "1">
                    <tr>
                        <th align = "left">
                            <font face = "Arial" color = "black">Função do parceiro</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Nome do Parceiro</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Nome de contato</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Valor de Comunicação</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Informação de parceiros</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Informação de endereço</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageProperties/Parties/PartnerInformation">
                        <tr>
                            <td>
                                <xsl:value-of select = "@PartnerRole"/>
                            </td>
                            <td>
                                <xsl:value-of select = "PartnerIdentifier"/>
                            </td>
                            <td>
                                <xsl:value-of select = "PartnerName"/>
                            </td>
                            <td>
                                <xsl:value-of select = "ContactInformation/ContactName"/>
                            </td>
                            <td>
                                <xsl:value-of select = "ContactInformation/CommunicationValue"/>
                            </td>
                            <td>
                                <xsl:value-of select = "AddressInformation"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p>
                    <br/>
                </p>
                <hr size = "5" color = "black"/>
                <p>
                    <br/>
                    <br/>
                </p>
                <h2>
                    <font face = "arial">
                        <u>Detalhe do transporte</u>
                    </font>                </h2>
                <table
                    frame = "border"
                    rules = "all"
                    Border = "1">
                    <tr>
                        <th align = "left">
                            <font face = "Arial" color = "black">Tipo de localização</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Tipo de código</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Nome localização</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageProperties/TransportationDetails/Location">
                        <tr>
                            <td>
                                <xsl:value-of select = "@LocationType"/>
                            </td>
                            <td>
                                <xsl:value-of select = "LocationCode"/>
                            </td>
                            <td>
                                <xsl:value-of select = "LocationName"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p>
                    <br/>
                    <br/>
                </p>
                <h2>
                    <font face = "Arial">
                        <u>Detalhes de equipamento</u>
                    </font>
                </h2>
                <table
                    frame = "border"
                    rules = "all"
                    Border = "1">
                    <tr>
                        <th align = "left">
                            <font face = "Arial" color = "black">Identificação do equipamento</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Descrição do equipamento</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Código tipo de equipamento</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageDetails/EquipmentDetails">
                        <tr>
                            <td>
                                <xsl:value-of select = "EquipmentIdentifier"/>
                            </td>
                            <td>
                                <xsl:value-of select = "EquipmentType/EquipmentDescription"/>
                            </td>
                            <td>
                                <xsl:value-of select = "EquipmentType/EquipmentTypeCode"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p>
                    <br/>
                    <br/>
                </p>
                <h2>
                    <font face = "Arial">
                        <u>Divisão no Equipamento</u>
                    </font>
                </h2>
                <table
                    frame = "border"
                    rules = "all"
                    Border = "1">
                    <tr>
                        <font face = "Verdana" size = "-1">
                            <th align = "left">
                                <font face = "Arial" color = "black">Identificação do equipamento</font>
                            </th>
                            <th align = "left">
                                <font face = "Arial" color = "black">Divisão de mercadorias na embalagem</font>
                            </th>
                            <th align = "left">
                                <font face = "Arial" color = "black">Volume bruto</font>
                            </th>
                            <th align = "left">
                                <font face = "Arial" color = "black">Peso bruto</font>
                            </th>
                        </font>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageDetails/GoodsDetails/SplitGoodsDetails">
                        <tr>                            <td>
                                <xsl:value-of select = "EquipmentIdentifier"/>
                            </td>
                            <td>
                                <xsl:value-of select = 'format-number(SplitGoodsNumberOfPackages, "#######")'/>
                            </td>
                            <td>
                                <xsl:value-of select = 'format-number(SplitGoodsGrossVolume, "#######")'/>
                            </td>
                            <td>
                                <xsl:value-of select = 'format-number(SplitGoodsGrossWeight, "#######")'/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p>
                    <br/>
                    <br/>
                </p>
                <h2>
                    <font face = "Arial">
                        <u>Detalhes de embalagem</u>
                    </font>
                </h2>
                <table
                    frame = "border"
                    rules = "all"
                    Border = "1">
                    <tr>
                        <th align = "left">
                            <font face = "Arial" color = "black">Detalhe da embalagem</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Volume total da embalagem</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Peso total da embalagem</font>
                        </th>
                        <th align = "left">
                            <font face = "Arial" color = "black">Detalhe da informação de referência</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageDetails/GoodsDetails">
                        <tr>
                            <td>
                                <xsl:value-of select = "PackageDetailComments"/>
                            </td>
                            <td>
                                <xsl:value-of select = 'format-number(PackageDetailGrossVolume, "#######")'/>
                            </td>
                            <td>
                                <xsl:value-of select = 'format-number(PackageDetailGrossWeight, "#######")'/>
                            </td>
                            <td>
                                <xsl:value-of select = "DetailsReferenceInformation"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>