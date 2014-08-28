#! /bin/bash

txtReset=$(tput sgr0)		# Reset

txtUnd=$(tput sgr 0 1)		# Underline
txtBold=$(tput bold)		# Bold
	
txtRed=$(tput setaf 1)		# Red
txtGreen=$(tput setaf 2)	# Green
txtYellow=$(tput setaf 3)	# Yellow
txtBlue=$(tput setaf 4)		# Blue
txtPurple=$(tput setaf 5)	# Purple
txtCyan=$(tput setaf 6)		# Cyan
txtWhite=$(tput setaf 7)	# White

# echo "hello world - regular"
# echo "hello world - ${txtUnd}underline${txtReset}"
# echo "hello world - ${txtBold}bold${txtReset}"
# 
# echo "hello world - ${txtRed}Red${txtReset}"
# echo "hello world - ${txtGreen}Green${txtReset}"
# echo "hello world - ${txtYellow}Yellow${txtReset}"
# echo "hello world - ${txtBlue}Blue${txtReset}"
# echo "hello world - ${txtPurple}Purple${txtReset}"
# echo "hello world - ${txtCyan}Cyan${txtReset}"
# echo "hello world - ${txtWhite}White${txtReset}"
