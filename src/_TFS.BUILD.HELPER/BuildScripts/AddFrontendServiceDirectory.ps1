param([Parameter(Position=0,mandatory=$true)][string]$FrontendServiceName, [Parameter(Position=1,mandatory=$true)][string]$WixInputDir)

[xml]$xmlDocDir = Get-Content "$WixInputDir\Directories.wxs"
$nsmDir = New-Object Xml.XmlNamespaceManager($xmlDocDir.NameTable)
$nsmDir.AddNamespace('ns', $xmlDocDir.DocumentElement.NamespaceURI)

$PITWEBAPPROOT_MODULE = $xmlDocDir.SelectSingleNode('//ns:Directory[@Id="DIR_PITWEBAPPROOT_MODULE"]', $nsmDir)
$idName = "DIR_PITWEBAPPROOT_MODULESERVICE_" + $FrontendServiceName
$nodeSelectStringDir = '//ns:Directory[@Id="' + $idName + '"]'

if($xmlDocDir.SelectSingleNode($nodeSelectStringDir, $nsmDir)){}
else
{

$nodeElement = $xmlDocDir.CreateElement('Directory', $xmlDocDir.DocumentElement.NamespaceURI)
$attributeId = $xmlDocDir.CreateAttribute('Id')
$attributeName = $xmlDocDir.CreateAttribute('Name')

$nodeElement.Attributes.Append($attributeId)
$nodeElement.Attributes.Append($attributeName)
$nodeElement.SetAttribute('Id', $idName)
$nodeElement.SetAttribute('Name', $FrontendServiceName)

$PITWEBAPPROOT_MODULE.AppendChild($nodeElement)

$nodeElementWwwroot = $xmlDocDir.CreateElement('Directory', $xmlDocDir.DocumentElement.NamespaceURI)
$attributeIdWwwroot = $xmlDocDir.CreateAttribute('Id')
$attributeNameWwwroot = $xmlDocDir.CreateAttribute('Name')

$nodeElementWwwroot.Attributes.Append($attributeIdWwwroot)
$nodeElementWwwroot.Attributes.Append($attributeNameWwwroot)
$WwwrootIdName = $idName + "_wwwroot"
$nodeElementWwwroot.SetAttribute('Id', $WwwrootIdName)
$nodeElementWwwroot.SetAttribute('Name', "wwwroot")

$nodeElement.AppendChild($nodeElementWwwroot)

$xmlDocDir.Save("$WixInputDir\Directories.wxs")
}