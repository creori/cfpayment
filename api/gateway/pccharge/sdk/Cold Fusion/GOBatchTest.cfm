<!--- This is a sample page that you can load in your browser to test the
GOBatch tag.

If you have a live merchant account set up in PCCharge, you should change the hard-coded
processor code (NOVA) and merchant number below to your own.  Otherwise,
you can use the given values with test merchant info that is included in the DevKit.  See the
DevKit readme.txt for instructions on setting up test merchant info in PCCharge.--->

<HTML>
<HEAD><TITLE>Test Batch Settlement</TITLE></HEAD>
<BODY>
<CENTER>
<H4> Test Settlement for Custom TAG GOBatch</H4>
</CENTER>

<!--- Create and Initialize return variables --->
	<CFSET Error = "">
	<CFSET Count = "">
	<CFSET Batches = "">
	<CFSET Balance = "">
	<CFSET Status = "">


<!--- Call to the GOBatch TAG.  Notice that Path and Action are not set
here.  You should determine if you need to set Path and Action here to
some other values,  or use the defaults. --->

	<CF_GOBatch
		Processor = "NOVA"
		MerchantNumber = "99988836"
		User = "User1"

	>

	<CENTER>
	<H4> Results returned from TAG </H4>


		<CFOUTPUT>
			Result: #Error# <BR>
			Count: #Count# <BR>
			Batches: #Batches# <BR>
			Balance: #Balance# <BR>
			Status: #Status#
		</CFOUTPUT>
	</CENTER>

</BODY>
</HTML>