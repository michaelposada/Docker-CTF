<?php
	if(isset($_POST['username'])){
		$username = $_POST['username'];
		$flag1 = true;
	} else {
		echo "username not set! <br>";
		$flag1 = false;
	}
	//Check User ID
	if(isset($_POST['password'])){
		$password = $_POST['password'];
		$flag2 = true;
	} else {
		echo "password not set! <br>";
		$flag2 = false;
	}
		
	if($flag1&&$flag2){
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
		$st = $dbh->prepare("SELECT user_id FROM users WHERE username='" . $username . "' AND password='" . $password . "' LIMIT 1");
		#$st->bindParam(1, $username);
		#$st->bindParam(2, $password);
		$st->execute();
		$result = $st->fetch();
		
		if($result[0] == null){
			$succ = false;
			header('Location: ../index.html');
		}else{
			$succ = true;
		}
		if($succ){
			session_start();
			$_SESSION['userID'] = $result[0];
			header('Location: ../View/Home.html');
		}
	}      
?>
