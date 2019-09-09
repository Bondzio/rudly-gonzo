${x:-$(ls)}

${parameter:=word}
unset X
echo ${X:=abc}
abc
${parameter:?word}
unset posix
echo ${posix:?}
sh: posix: parameter null or not set
${parameter:+word}
set a b c
echo ${3:+posix}
posix
${#parameter}
HOME=/usr/posix
echo ${#HOME}
10
${parameter%word}
x=file.c
echo ${x%.c}.o
file.o
${parameter%%word}
x=posix/src/std
echo ${x%%/*}
posix
${parameter#word}
x=$HOME/src/cmd
echo ${x#$HOME}
/src/cmd
${parameter##word}
x=/one/two/three
echo ${x##*/}
three
The double-quoting of patterns is different depending on where the double-quotes are placed:
"${x#*}"
The <asterisk> is a pattern character.
${x#"*"}
The literal <asterisk> is quoted and not special.