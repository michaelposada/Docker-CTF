CTF Depolyment

Requirments:
Needs to have pre installed Kuberentes, MiniKube, and Docker

To run the script do the following command: "sudo ./setUp.sh <username> "

Wanting to check out how the Pods are set up? Check out ./resources/*
It contians the name for the Exercises and Tools-Pod. The Webserver folder has the html and php that sets up the webserver that is used locally. 
We also saved all the Dockerfiles binaries in their respectful locations. 

Contact: Michael Posada @ michaelposada@mail.adelphi.edu
	 Jason Massimino @ jasonmassimino@mail.adelphi.ed
If you have any questions!

Spoilers for how to solve the first two CTFs:
Flag 1 is found with ls -al
Flag 2 is found using cat to gain access to the restricted folder
Flag 3 is found using grep -ri flag garbage/
Flag 4 is base64 encoded within .passwords/bob.txt
Flag 5 is found by brute forcing .passwords/alice.txt
Flag 6 is found by using the key in .keys to decrypt AdminDave's passwords
#Flag 7 is found by emailing AdminDave -- No Longer In Use
Flag 8 is found in the SQL table
Flag 9 is found with AdminDave's TODO, along with the link to the next exercise
Flag 10 is found by viewing VISUDO


2Flag 1 is found in register account, by clicking "register Account"
2Flag 2 is found in the comments of Forgot Password
2Flag 3 is found by getting DB to print users from files
2Flag 4 is found by getting past the login
2Flag 5 is found by finding flag.txt in the htmlsource folder
2Flag 6 is found by navigating to settings.html
2Flag 7 is found in the flag file query
