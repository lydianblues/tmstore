<h1>Connection Test</h1>
<h2>
<?php
	if ($c = @oci_connect("store", "har526", "orcl2")) {
  	print "Success<br/>";
  	oci_close($c);
	} else {
		print "Fail<br/>";
		$errorMessage = oci_error();
		print $errorMessage['message'];
		print htmlentities($errorMessage['message'])."<br/>";
	}
?>
</h2>

