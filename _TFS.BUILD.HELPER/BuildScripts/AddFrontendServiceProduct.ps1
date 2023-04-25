param([Parameter(Position=0,mandatory=$true)][string]$SetupInputFrontendComponentGroupName, [Parameter(Position=1,mandatory=$true)][string]$WixInputDir)

[xml]$xmlDocProduct = Get-Content $WixInputDir\Product.wxs
$nsmProduct = New-Object Xml.XmlNamespaceManager($xmlDocProduct.NameTable)
$nsmProduct.AddNamespace('ns', $xmlDocProduct.DocumentElement.NamespaceURI)

$ProductFeature = $xmlDocProduct.SelectSingleNode('//ns:Feature[@Id="F_BASEINSTALLROOT"]', $nsmProduct)
if($ProductFeature){}
else{
    Write-Error "Could not find the Feature with the Id F_BASEINSTALLROOT in the Product.wsx File"
    return
}

$noteSelectStringProduct = '//ns:ComponentGroupRef[@Id="' + $SetupInputFrontendComponentGroupName + '"]'
if($xmlDocProduct.SelectSingleNode($noteSelectStringProduct, $nsmProduct)){}
else
{
$nodeElementProduct = $xmlDocProduct.CreateElement('ComponentGroupRef', $xmlDocProduct.DocumentElement.NamespaceURI)

$attributeIdProduct = $xmlDocProduct.CreateAttribute('Id')


$nodeElementProduct.Attributes.Append($attributeIdProduct)

$nodeElementProduct.SetAttribute('Id', $SetupInputFrontendComponentGroupName)


$ProductFeature.AppendChild($nodeElementProduct)
$xmlDocProduct.Save("$WixInputDir\Product.wxs")


}