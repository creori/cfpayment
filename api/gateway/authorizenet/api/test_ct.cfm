<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Test &lt;cf_authorizenet&gt;</title>
</head>

<body>

<cf_authorizenet_customtag
	mode="TEST"
	login="62weFnt8Squs"
	transKey="6ay34R37ftsRGF24"
	method="CC"
	type="AUTH_CAPTURE"
	amount="2.00"
	cardNum="4111111111111111"
	cardExp="0110"
	
	invoiceNum="12334"
	description="Test"
	custNum="1"
>

<cfdump var="#res#" label="res" />

<cfdump var="#results#" label="results" />

</body>
</html>
