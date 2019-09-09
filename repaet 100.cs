# repeat a command 100 times
x=100
while [ $x -gt 0 ]
do
    command    x=$(($x-1))
done