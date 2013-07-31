x=0

logFile="/var/log/deploy.log"
touch $logFile
while [ $x -le 10 ]
do
  echo "Inside the while loop of JBoss' deploy.sh" >> $logFile
  sleep 60
  x=`expr $x + 1`
done