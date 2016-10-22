#!/bin/bash

arry=(limingming@iie.ac.cn lvhonglei@iie.ac.cn liuwei@iie.ac.cn daijiao@iie.ac.cn)
path=/home/v-wxb-chai/workspace/webserver/.mingShell/

function monitor {
   jhss_pid=$(netstat -anop | grep "0.0.0.0:$1" | awk '{print $7}' | awk -F '/' '{print $1}')
   echo $[$jhss_pid]
}

function record_1 {
   num=`sed -n '1p' $path.importfile`
   echo $num
   if [ -z "$num" ]
   then 
      num=0
   fi
   echo $num
   tag=`echo $num/$1%10 | bc`
   echo $tag
   if (( "$tag" == "0" ))
   then
      flag=0
   else
      flag=1
      modify=`echo $num -$1 | bc`
   fi
   echo $[$flag] $[$modify]
}
function record {
   num=`sed -n '1p' $path.importfile`
   echo $num
   if [ "$modify" == "" ]
   then 
      modify=0
   fi
   tag=`echo $num/$1%10 | bc`
   echo $tag
   if (( $tag == 0 ))
   then
      flag=0
      modify=`echo $num +$1 | bc `
   else
      flag=1
      modify=`echo $num -$1 | bc`
   fi
   echo $[$flag] $[$modify]
}
function sendMail {
  s=`date +%Y-%m-%d-%H:%M`
  text= $2
  pid=`monitor $1`
  flag=0
  modify=0
  case $1 in 
     7000) 
        a=(`record 1000 `) 
        echo ming ${#a[*]} ${a[*]}
        flag=${a[2]}
        modify=${a[3]}
     ;;
     9999)   
        a=(`record 100 `) 
        echo ming ${#a[*]} ${a[*]}
        flag=${a[2]}
        modify=${a[3]}
     ;;
     10101)
        a=(`record 10 `) 
        echo ming ${#a[*]} ${a[*]}
        flag=${a[2]}
        modify=${a[3]}
     ;;
     10117)
        a=(`record 1 `) 
        echo ming ${#a[*]} ${a[*]}
        flag=${a[2]}
        modify=${a[3]}
     ;;
  esac 
  
  users=(`echo "$@"`)
  cc=${#users[@]}
  echo  $cc,$3,$2,$1
  echo  ${users[*]:(($cc-$4)):$cc-1}

  if (( $pid <=0 ))
  then 
     text="$text and  restart failed!"
     if (( $flag ==0 ))
     then 
        status=`echo $modify >$path.importfile` 
        echo $s: $text | mail -s $3 ${users[*]:(($cc-$4)):$cc-1}
     fi
     echo  $3  $s:$text >> $path.seweb_log
  else
     text="$text and restart successfully!"
     status=`echo $modify >$path.importfile` 
     #echo $s: $text | mail -s $3 ${users[*]:(($cc-$4)):$cc-1}
     echo  $3  $s:$text >> $path.seweb_log
  fi
}
function myfunc {
   #echo ${arry[*]}
   #echo ${arry[@]:1:2}
   jhss_pid=`monitor $1`
   text="SEWeb port=$1  stop services"
   echo $jhss_pid   
   #if [ -z "$jhss_pid" ]
   if (( $jhss_pid <=0 ))
   then
      case $1 in
         10101)   
             userlist=(${arry[0]} ${arry[1]} ${arry[3]})
             echo $1
             ss=` /home/v-wxb-chai/workspace/webserver/kvmSEMain/./jhss_restart.sh `
             sleep 5
             sendMail $1 "$text" "SEWeb_port=$1" ${#userlist[@]} ${userlist[*]}
          ;;
         9999)
             userlist=(${arry[0]} ${arry[2]} ${arry[3]})
             ss=` /home/v-wxb-chai/workspace/webserver/SEMain/./jhss_retart.sh `
             sleep 5
             sendMail $1 "$text" "SEWeb_port=$1" ${#userlist[@]} ${userlist[*]}
         ;;
         7000) 
             userlist=(${arry[0]} ${arry[2]} ${arry[3]})
             ss=` /home/v-wxb-chai/workspace/webserver/SETest/./jhss_restart.sh `
             sleep 5
             sendMail $1 "$text" "SEWeb_port=$1" ${#userlist[@]} ${userlist[*]}
         ;;
         10117)      
             userlist=(${arry[0]} ${arry[1]} ${arry[3]})
             ss=` /home/v-wxb-chai/workspace/webserver/ZhiBo/./jhss_retart.sh `
             sleep 5
             sendMail $1 "$text" "SEWeb_port=$1" ${#userlist[@]} ${userlist[*]}
         ;;
      esac
   else
      modify=`sed -n 1p $path.importfile`
      if [ "$modify" == "" ]
      then 
         modify=0
      fi
      case $1 in
        7000)
           a=(`record_1 1000 `) 
           modify=${a[3]}
        ;;
       9999)
           a=(`record_1 100 `) 
           modify=${a[3]}
       ;;
       10101)
           a=(`record_1 10 `) 
           modify=${a[3]}
       ;;
       10117)
           a=(`record_1 1 `) 
           modify=${a[3]}
       ;;
     esac
     status=`echo $modify >$path.importfile` 
   fi
}

myfunc 7000
myfunc 9999
myfunc 10101
myfunc 10117

