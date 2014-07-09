<!---
GOBatch.cfm Custom Tag for Cold Fusion
Copyright 2000 Go Software, Inc.
								
GOCharge is a Custom TAG that allows merchants to inquire about and
settle open batches from Cold Fusion code.  Use 30 as value for Action
to perform a batch inquiry.  Use 31 for Action to perform a batch
settlement.  Batch inquiries do not change the state of an open batch.
An inquiry simply returns the stats of the batch.  A batch settlement
settles all transactions in an open batch, clearing the current batch.
The input and output parameters are the same for  both inquiry, and 
settlement.
	  
Requirements:
This TAG works in conjunction with PCCharge Pro or Payment Server and
requires that PCCharge be installed and configured with either a test
merchant number or live merchant number.
		
Installation:
The relevant files installed during setup include:
GOBatch.cfm  --- The GOBatch custom TAG
	  
Input parameters to GOBatch are:
Path  		--- Path to the PCCharge executable (Pccw.exe or Active-Charge.exe)
Processor   	--- Processing Company abbreviation
MerchantNumber  --- Merchant Number for transaction to be processed on
User		--- A user name that is unique for each simultaneous transaction
Action		--- Use 30 for inquiry and 31 for settlement

Output parameters to GOBatch are:
Error		--- Contains error description if there was an error
Count		--- Number of transactions in the current batch
Batches         --- Batch Number
Balance         --- Amount of the batch
Status          --- Status of the batch, such as open
--->

<!--- optional attributes Path and Action, and their DEFAULT values.  Action 
defaults to settlement. --->
<CFPARAM name="Attributes.Path" default="C:\Program Files\Active-charge\">
<CFPARAM name="Attributes.Action" default="31">

<!--- required attributes --->
<CFLOOP index="Attribute" list="Processor,MerchantNumber,User">
	<CFIF not IsDefined( 'Attributes.' & Attribute )>
		<HR>
		<H4>Missing Attribute</H4>

		You need to specify a value for the '<B><CFOUTPUT>#Attribute#</CFOUTPUT></B>' attribute. This attribute is required for the <B>GOBatch</B> tag.
		<HR>
		<CFABORT>
	</CFIF>
</CFLOOP>

<!--- First, create the object --->
<CFOBJECT ACTION="Create"   
	NAME="Batch1"
	CLASS="PSCharge.Batch">
<!--- Then, use the form variables from the user entry form to populate 
a number of properties necessary to create and send the transaction. --->
<CFSET Batch1.Path 		= #Attributes.Path#>
<CFSET Batch1.Processor 	= #Attributes.Processor#>
<CFSET Batch1.MerchantNumber 	= #Attributes.MerchantNumber#>
<CFSET Batch1.User 		= #Trim(Right(Attributes.User,8))#>
<CFSET Batch1.Action 		= #Attributes.Action#>
<CFSET Batch1.XMLtrans = true>
<CFSET Batch1.Send>

<!--- Check the results --->
<CFSET #Caller.Error# 	= #Batch1.GetErrorDesc()#>
<CFSET #Caller.Count# 	= #Batch1.GetItemCount()#>
<CFSET #Caller.Batches# = #Batch1.GetBatches()#>
<CFSET #Caller.Balance# = #Batch1.GetBalance()#>
<CFSET #Caller.Status# 	= #Batch1.GetStatus()#>

<!--- Some Cleanup --->
<CFSET Batch1.DeleteUserFiles()>