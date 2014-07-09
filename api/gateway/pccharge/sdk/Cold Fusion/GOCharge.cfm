<!---
GOCharge.cfm Custom Tag for Cold Fusion
Copyright 2000 Go Software, Inc.

This is a cfm tag that creates the DLL object, sets some
required properties, and sends the credit card transactions to
PCCharge to be processed.  The Cold Fusion tags MUST reside on the same
computer as PCCharge.

Requirements:
This TAG works in conjunction with PCCharge Pro or Payment Server
and requires that PCCharge be installed and configured with either
a test merchant number or live merchant number.

Installation:
The relevant files installed during setup include:
GOCharge.cfm  		--- The GOCharge custom TAG
GOChargeTest.cfm  	--- A page to test the GOCharge custom TAG

Input parameters to the GOCharge TAG are:
Path  		--- Path to the PCCharge executable (Pccw.exe or Active-Charge.exe)
Processor   	--- Processing Company abbreviation
MerchantNumber  --- Merchant Number for transaction to be processed on
User		--- A user name that is unique for each simultaneous transaction
Card		--- Credit Card Number
ExpDate		--- Expiration Date in the form mmyy
Amount		--- The amount of the transaction in the form dd.cc
Member		--- Card Holder's name
Street		--- Street address of credit card holder - used for AVS
Zip		--- Zip code of credit card holder
Ticket		--- 9 Character field provided for merchant
CVV2            --- 4 character "card verification value"

The Path and Action inputs are not required, but if left blank,
the user should confirm that the default values of these two
inputs are the values desired.  These two default values are
below.  All other inputs are required.

Output parameters from the GOCharge TAG are:

If no error occurred during processing,
Caller.Result     --- Description of transaction results; will indicate good and bad transactions
Caller.AuthCode   --- Authorization Code if transaction was successful, or reason if not successful
Caller.Reference  --- Reference Number if transaction was successful
Caller.AVS	  --- Address Verification Response
Caller.CVV2       --- CVV2 Response

If an error occurred during processing,
Caller.ChargeError  --- Description of the error that was encountered during processing

If a transaction returns without and error, that doesn't mean that
it was successful.  The user must evaluate the response of each
transaction to determine whether a charge was successful (captured),
or not.

See the DevKit documentation for different types of responses returned
for successful and unsuccessful transactions.
--->

<!--- optional attributes Path and Action, and their DEFAULT values --->
<CFPARAM name="Attributes.Path" default="C:\Program Files\Active-Charge\">
<CFPARAM name="Attributes.Action" default="1">

<!--- required attributes --->
<CFLOOP index="Attribute" list="Processor,MerchantNumber,User,Card,ExpDate,Amount,Member,Street,Zip,Ticket">
	<CFIF not IsDefined( 'Attributes.' & Attribute )>
		<HR>
		<H4>Missing Attribute</H4>

		You need to specify a value for the '<B><CFOUTPUT>#Attribute#</CFOUTPUT></B>' attribute. This attribute is required for the <B>GOCharge</B> tag.
		<HR>
		<CFABORT>
	</CFIF>
</CFLOOP>

<!--- First, create the object --->
<CFOBJECT ACTION="Create"
	NAME="Charge1"
	CLASS="PSCharge.Charge">
<!--- Then, use the form variables from the user entry form to populate a number of properties necessary to create and send the transaction.
--->
<CFSET Charge1.Path 		= #Attributes.Path#>
<CFSET Charge1.Processor 	= #Attributes.Processor#>
<CFSET Charge1.MerchantNumber 	= #Attributes.MerchantNumber#>
<CFSET Charge1.User 		= #Trim(Right(Attributes.User,8))#>
<CFSET Charge1.Card    		= #Attributes.Card#>

<!---<CFSET Charge1.Card 	= #REReplace(Attributes.Card,"","","ALL")#> uncomment if you are using CF 4.0 or earlier and will allow "forced" transactions --->
<!---<CFSET Charge1.Card 	= #REReplace(Attributes.Card,"[^0-9]","","ALL")#> uncomment if you are using CF 4.0 or earlier and will not allow "forced" transactions --->

<CFSET Charge1.ExpDate 		= #REReplace(Attributes.ExpDate,"[^0-9]","","ALL")#>
<CFSET Charge1.Amount 		= #Attributes.Amount#>
<CFSET Charge1.Member 		= #Attributes.Member#>
<CFSET Charge1.Street 		= #Attributes.Street#>
<CFSET Charge1.Zip 		= #Attributes.Zip#>
<CFSET Charge1.Ticket 		= #Attributes.Ticket#>
<CFSET Charge1.CVV2             = #Attributes.CVV2#>
<CFSET Charge1.Action 		= #Attributes.Action#>   <!--- 1=Sale, 2=Credit, 3=Void, etc. See DevKit Constants section of Chapter 2 in the DevKit Manual --->
<CFSET Charge1.XMLTrans = True>
<CFSET Charge1.Send>

<!--- Check the Results --->

<!--- If no error, then return the results. --->
<CFIF #Charge1.GetErrorCode()# is 0>
	<CFSET #Caller.Result# 		= #Charge1.GetResult()#>
	<CFSET #Caller.AuthCode# 	= #Charge1.GetAuth()#>
	<CFSET #Caller.Reference# 	= #Charge1.GetRefNumber()#>
	<CFSET #Caller.AVS# 		= #Charge1.GetAVS()#>
	<CFSET #Caller.CVV2# 		= #Charge1.GetCVV2()#>
<CFELSE> <!--- Return the Error --->
	<CFSET #Caller.ChargeError# = #Charge1.GetErrorDesc()#>
</CFIF>
<!--- Perform some cleanup --->
<CFSET Charge1.DeleteUserFiles()>
