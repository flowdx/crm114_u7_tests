#!/bin/bash

error_qmail_permission=0
error_mailfilter_permission=0
error_mailfilter_preset=0

printf "Please enter the mailusername that should be tested und press Return: "

read username

printf "\nCheckup for username: $username\n"

if [ -d "$HOME/users/$username/" ]
then
  echo -e "\e[92m[OK]\e[0m   Mailuser exists $HOME/users/$username/"
else
echo -e "\e[31m[NOK]\e[0m  Mailuser doesn't exist $HOME/users/$username/"
fi

if [ -f "$HOME/.qmail-$username" ]
then
  echo -e "\e[92m[OK]\e[0m   .qmail-file exists: $HOME/.qmail-$username"

  filepermission=$(stat -c '%a' $HOME/.qmail-$username)
  if [ $filepermission -eq "644" ]
  then
    echo -e "\e[92m[OK]\e[0m   Permission of file .qmail-$username is 644"
  else
    error_qmail_permission=1
    echo -e "\e[31m[NOK]\e[0m  Wrong permission of file .qmail-$username! IS: $filepermission, SHOULD BE: 644"
  fi

  line=$(head -n 1 $HOME/.qmail-$username)
  if [ "$line" = "|maildrop \$HOME/.mailfilter_$username" ]
  then
    echo -e "\e[92mOK\e[0m  Found \"|maildrop \$HOME/.mailfilter_$username\" in first line of file .qmail-$username"
  else
    echo -e "\e[31m[NOK]\e[0m Unexpected first line in .qmail-$username: $line"
    echo "      Expected: |maildrop \$HOME/.mailfilter_$username"
    echo "      Please manually change it if necessary!"
  fi
else
echo -e "\e[31m[NOK]\e[0m  .qmail-file doesn't exist: $HOME/.qmail-$username"
fi

if [ -f "$HOME/.mailfilter_$username" ]
then
  echo -e "\e[92m[OK]\e[0m   .mailfilter-file exists: $HOME/.mailfilter_$username"

  filepermission=$(stat -c '%a' $HOME/.mailfilter_$username)
  if [ $filepermission -eq "600" ]
  then
    echo -e "\e[92m[OK]\e[0m   Permission of file .mailfilter_$username is 600"
  else
    error_mailfilter_permission=1
    echo -e "\e[31m[NOK]\e[0m Wrong permission of file .mailfilter_$username IS: $filepermission SHOULD BE: 600"
  fi

  line=$(head -n 1 $HOME/.mailfilter_$username)
  if [ "$line" = "MAILUSERNAME=$username" ]
  then
    echo -e "\e[92m[OK]\e[0m   Found \"MAILUSERNAME=$username\" in first line of file .mailfilter_$username"
  else
    if [ "$line" = "MAILUSERNAME=[!USERNAME!]" ]
    then
      error_mailfilter_preset=1
      echo -e "\e[31m[NOK]\e[0m Unexpected first line in .mailfilter_$username: \"$line\""
      echo "      That's the preset!"
    else
      echo -e "\e[31m[NOK]\e[0m Unexpected first line in .mailfilter_$username: \"$line\""
      echo "      Please manually change it!"
   fi
fi
else
echo -e "\e[31m[NOK]\e[0m .mailfilter-file doesn't exist: $HOME/.mailfilter_$username"
fi
printf "End of checkup.\n\n"

if [ $error_qmail_permission = 1 ]
then
  echo "Advised correction:"
  printf "Shall i change the permission of .qmail-$username to 644? [y|n] "

  read change_permission_of_qmail

  if [ "$change_permission_of_qmail" = "y" ]
  then
    chmod 644 ~/.qmail-$username
    echo "Successfully changed permission of .qmail-$username to 644"
  fi

  printf "\n"
fi


if [ $error_mailfilter_permission = 1 ]
then
  echo "Advised correction:"
  printf "Shall i change the permission of .mailfilter_$username to 600? [y|n] "

  read change_permission_of_mailfilter

  if [ "$change_permission_of_mailfilter" = "y" ]
  then
    chmod 600 ~/.mailfilter_$username
    echo "Successfully changed permission of .mailfilter-$username to 600"
  fi

  printf "\n"
fi


if [ $error_mailfilter_preset = 1 ]
then
  echo "Advised correction:"
  printf "Shall i change the first line of .mailfilter_$username from \"MAILUSERNAME=[!USERNAME!]\" to \"MAILUSERNAME=$username\" as intended? [y|n] "

  read change_first_line_if_mailfilter

  if [ "$change_first_line_if_mailfilter" = "y" ]
  then
    sed -i -e 1c"MAILUSERNAME=$username" ~/.mailfilter_$username
    echo "Successfully changed first line of .mailfilter_$username to \"MAILUSERNAME=$username\""
  fi

  printf "\n"
fi


printf "End of script. If you do/did changes, feel free to run it again afterwards.\n"
