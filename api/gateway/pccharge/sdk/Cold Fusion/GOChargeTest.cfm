
<!---If you have a live merchant account set up in PCCharge, you should change the hard-coded
processor code (NOVA) and merchant number below to your own.  Otherwise,
you can use the given values with test merchant info that is included in the DevKit.  See the
DevKit readme.txt for instructions on setting up test merchant info in PCCharge.--->

<HTML>
<HEAD><TITLE>Transaction Results</TITLE></HEAD>
<BODY>

<!--- Create and Initialize return variables --->
	<CFSET Result 	   = "">
	<CFSET AuthCode    = "">
	<CFSET Reference   = "">
	<CFSET AVS 	   = "">
        <CFSET CVV2        = "">
	<CFSET ChargeError = "">
	
<!--- Call to the GOCharge TAG.  Notice that Path and Action are not set
here.  You should determine if you need to set Path and Action here to
some other values,  or use the defaults. --->	

	<CF_GOCharge
		Processor 	= "NOVA"
		MerchantNumber 	= "99988836"
		User 		= "User1"
		Card 		= #form.card#
		ExpDate 	= #form.expir#
		Amount 		= #form.amount#
		Street 		= #form.street#
		Zip 		= #form.zip#
	        Member 		= #form.member#
		Ticket 		= #form.ticket#
                CVV2            = #form.CVV2#
	>
	

	<H4>Results returned from Cold Fusion Tag:</H4>
	<CFIF #ChargeError# is "">
		<CFOUTPUT>
			Result: #Result# <BR>
			AuthCode: #AuthCode# <BR>
			Reference: #Reference# <BR>
			AVS: #AVS# <BR>
			CVV2: #CVV2# <BR>
		</CFOUTPUT>
	<CFELSE>
		<CFOUTPUT>
			#ChargeError#
		</CFOUTPUT>
	</CFIF>
			
</BODY>
</HTML>

