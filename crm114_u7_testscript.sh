#!/bin/bash

echo Please enter the mailusername that should be tested:

read username

echo Checkup for username $username

if [ -d "$HOME/users/$username/" ]
then
  echo -e "\e[92mOK\e[0m... Mailuser exists $HOME/users/$username/"
else
echo -e "\e[31m[NOK]\e[0m... Mailuser doesn't exist $HOME/users/$username/"
fi

if [ -f "$HOME/.qmail-$username" ]
then
  echo -e "\e[92mOK\e[0m... File exists $HOME/.qmail-$username"

  filepermission=$(stat -c '%a' $HOME/.qmail-$username)
  if [ $filepermission -eq "644" ]
  then
    echo -e "\e[92mOK\e[0m... Permission of file $HOME/.qmail-$username is 644"
  else
    echo -e "\e[31m[NOK]\e[0m... Wrong permission of file $HOME/.qmail-$username IS: $filepermission SHOULD BE: 644"
  fi

  line=$(head -n 1 $HOME/.qmail-$username)
  if [ "$line" = "|maildrop \$HOME/.mailfilter_$username" ]
  then
    echo -e "\e[92mOK\e[0m... Found \"|maildrop \$HOME/.mailfilter_$username\" in first line of file .qmail-$username"
  else
    echo -e "\e[31m[NOK]\e[0m... Wrong first line in .qmail-$username: \"$line\""
  fi


else
echo -e "\e[31m[NOK]\e[0m... File doesn't exist $HOME/.qmail-$username"
fi

if [ -f "$HOME/.mailfilter_$username" ]
then
  echo -e "\e[92mOK\e[0m... File exists $HOME/.mailfilter_$username"

  filepermission=$(stat -c '%a' $HOME/.mailfilter_$username)
  if [ $filepermission -eq "600" ]
  then
    echo -e "\e[92mOK\e[0m... Permission of file $HOME/.mailfilter_$username is 600"
  else
    echo -e "\e[31m[NOK]\e[0m... Wrong permission of file $HOME/.mailfilter_$username IS: $filepermission SHOULD BE: 600"
  fi

  line=$(head -n 1 $HOME/.mailfilter_$username)
  if [ "$line" = "MAILUSERNAME=$username" ]
  then
    echo -e "\e[92mOK\e[0m... Found \"MAILUSERNAME=$username\" in first line of file .mailfilter_$username"
  else
    echo -e "\e[31m[NOK]\e[0m... Wrong first line in .mailfilter_$username: \"$line\""
  fi

else
echo -e "\e[31m[NOK]\e[0m... File doesn't exist $HOME/.mailfilter_$username"
fi

