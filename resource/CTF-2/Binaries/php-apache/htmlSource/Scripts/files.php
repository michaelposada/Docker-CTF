<?php

if(isset($_POST['filename'])){
		$filename = $_POST['filename'];
		$flag1 = true;
	} else {
		echo "filename not set! <br>";
		$flag1 = false;
	}
		
	if($flag1){
		//Connect to DB
		session_start();
		$dsn="pgsql:host=postgres-test;dbname=testdb";
        $user="admin";
        $passwd="pass";
		try {
			$dbh = new PDO($dsn, $user, $passwd);
		} catch (PDOException $e) {
			print "Error: ".$e->getMessage()."<br/>";
			die();
		}

		$st = $dbh->prepare("SELECT * FROM files WHERE name='" . $filename ."'" );
		//$st->bindParam(1, $filename);
		$st->execute();
		$result = $st->fetch();
		print($result[2]);
		}


?>
