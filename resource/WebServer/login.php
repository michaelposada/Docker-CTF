<?php
	if(isset($_POST['user']) and !preg_match('/[\'^£$%&*()}{@#~?><>,|=_+¬-]/', $_POST['user'])){
		$username = $_POST['user'];
		
		$flag1 = true;
	} else {
		echo "username not set or has invalid characters! <br>";
		$flag1 = false;
	}
	//Check User ID
	if(isset($_POST['pass']) and !preg_match('/[\'^£$%&*()}{@#~?><>,|=_+¬-]/', $_POST['pass'])){
		//$password = hash('sha256', $_POST['pass']);
		$password = $_POST['pass'];
		$flag2 = true;
	} else {
		echo "password not set or has invalid characters! <br>";
		$flag2 = false;
	}
	if($flag1 && $flag2)
	{
		//Connect to DB
		session_start();
		try {
			$dbh = new PDO('pgsql:dbname=ctf');
		} catch (PDOException $e) {
			print "Error with Database: ".$e->getMessage()."<br/>";
			die();
		}//WILL HAVE TO EDIT THE QUERY
		$st = $dbh->prepare("
	SELECT username
	FROM login
	WHERE username=?
	AND password=?
	LIMIT 1");
		$st->bindParam(1, $username);
		$st->bindParam(2, $password);
		$st->execute();
		$result = $st->fetch();
		$succ = false;
		if($result[0] == null)
	{
			
			$succ = false;
			echo "<pre> There was an error with your login, please try again! </pre>";
			//header('Location: ./index.html');
			//figure out where we want to go
		}else{
			$succ = true;
			//in case result fails but isnt null (shouldnt occur but i will leave this here as a reminder until we can do some testing
		}
		if($succ){
/* 			session_start();
			// WE MIGHT HAVE TO STORE THIS OR SALT OR  BOTH DEPENDS ON LEUNE ANSWER
			$_SESSION['userID'] = $result[0];
			function createSalt()
			{
				$string = md5(uniqid(rand(), true));
				return substr($string, 0, 3);
			}
			$salt = createSalt();
			$_SESSION['userID'] = hash('sha256', $_SESSION['userID']);
			$hashid = hash('sha256', $salt . $_SESSION['userID']);

			$st = $dbh->prepare("
	UPDATE userpass SET hashid=?
	WHERE username=?
	AND password=?
	");
		$st->bindParam(1, $hashid);
		$st->bindParam(2, $username);
		$st->bindParam(3, $password);
		$st->execute();
		$result = $st->fetch();
		print(result[0]);
		$_SESSION['userID']= $hashid;
            //header('Location: http://35.190.175.135:8080?id='.$_SESSION['userID']);//figure out where we want to go */
	    $_SESSION['username'] = $username;
	    header('Location: http://192.168.42.11/main.php');
        }
    }
?>
