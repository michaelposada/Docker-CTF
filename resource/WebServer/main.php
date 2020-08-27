<!DOCTYPE html>
<html lang="en">
    <title>CTF-Restart</title>
        <head>
            <link rel="stylesheet" type="text/css" href="/stylesheet.css">
            <link href="https://fonts.googleapis.com/css?family=Biryani:800" rel="stylesheet">


        </head>
                <body>
		
		<h1 align="left" style="font-size:22px">
                        <?php session_start(); echo "Welcome, Team ".$_SESSION['username']."!";
                        $username = $_SESSION['username'];
                        $_SESSION['username'] = $username;
                        ?>
		</h1>		
		<center>
		<form action="./reset.php" method="post">
		</center>
		<p align="left" style="font-size:18px">This page is meant to be used to reset the CTF exersices to their original condition, if there was an issue.</p>
                <p align="left" style="font-size:18px">This should only be used by the team that needs it. Do not use it to mess with other team members. Click the button when ready.</p>

			<center><h1 class="title"></h1>
                    <input type="submit" value="Reset Pods">
                        <br><br><br>
                    </center>
                </form>
		</body>
</html>

