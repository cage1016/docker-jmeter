#!/usr/bin/env bash

scriptName=$(basename $0)

### check whether string is "option" (stats with "-")
checkOption(){
	# result: 0=false, other=true          
	var=$1

	if [[ "${var}" = "-" ]]; then
		result=1
	elif [[ $(expr "${var}" : "\-") -ne 0 ]] ; then
		result=1
	else
		result=0
	fi
	echo ${result}
}

createSubCommand2(){
	# arg1: property list delimitted by comma (ex. parm1=xxx,parm2=yyy,parm3=zzz)
	propertyList=$1

	arrayPropertyList=(${propertyList//,/ })

	commandString=""
	idx=0
	while [[ ${idx} -lt ${#arrayPropertyList[@]} ]]
	do
        keyValue=(${arrayPropertyList[${idx}]//=/ })
		propertyName=${keyValue[0]}
		propertyValue=${keyValue[1]}
		commandString="${commandString} -J${propertyName}=${propertyValue}"
		idx=$((idx+1))
	done
	
	echo ${commandString}
}

showHelp(){
	echo "Usage: ${scriptName} [-d <daemon>] [-i <jmeter_docker_image>] [-f <jmx_file>] [-t <test_folder>] [-z <enable_tar_html>] [-l <jmeterVariablesList>]"
	echo " -d : Daemon, docker/podman (default: docker)"
	echo " -t : Test directory (default: ./tmp)"
	echo " -i : Jmeter docker image (default: ghcr.io/cage1016/jmeter:5.4.1)"
	echo " -f : Specify JMX file"
	echo " -l : Specify env list of Jmeter in following format: prop01=XXX,bbb=YYY,ccc=ZZZ"
	echo " -z : Enable tar html report (default: false)"
	echo " "
	echo "  Example1: ${scriptName} -f ap.jmx"
	echo "  Example2: ${scriptName} -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx"
	echo "  Example3: ${scriptName} -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx -l prop01=XXX,prop02=YYY"
	echo "  Example4: ${scriptName} -d podman -f ap.jmx -z true -l prop01=XXX,prop02=YYY"
	echo ""
	exit 1
}

#######################################
# Main Logic
#######################################
arg_f=
flag_f=0
arg_i=
flag_i=0
arg_l=
flag_l=0
arg_d=
flag_d=0
arg_t=
flag_t=0
arg_z=
flag_z=0

for option in "$@"
do
	case "$option" in
		'-h')
			showHelp
			exit 0
			;;
		'-d')
			flag_d=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -i"
				showHelp
				exit 1
			elif [[ "$2" != "docker" ]] && [[ "$2" != "podman" ]]; then
				echo "Error: Daemon must be \"docker\" or \"podman\""
				showHelp
				exit 1
			else
				arg_d="$2"
				shift 2
			fi
			;;
		'-i')
			flag_i=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -i"
				showHelp
				exit 1
			else
				arg_i="$2"
				shift 2
			fi
			;;
		'-f')
			flag_f=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -f"
				showHelp
				exit 1
			else
				arg_f="$2"
				shift 2
			fi
			;;      
		'-l')
			flag_l=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -l"
				showHelp
				exit 1
			else
				arg_l=$2
				shift 2
			fi
			;;
		'-t')
			flag_t=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -t"
				showHelp
				exit 1
			else
				arg_t=$2
				shift 2
			fi
			;;
		'-z')
			flag_z=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -z, (true or false)"
				showHelp
				exit 1
			elif [[ "$2" != "true" ]] && [[ "$2" != "false" ]]; then
				echo "Error: Daemon must be \"true\" or \"false\""
				showHelp
				exit 1
			else
				arg_z=$2
				shift 2
			fi
			;;
		-*)
			echo "Error: Unsupported option: $1"
			showHelp
			exit 1
			;;
		*)
			if [[ ! -z "$1" ]] && [[ $(checkOption "$1") -eq 0 ]]; then
				shift 1
			fi
			;;
	esac
done


# echo flag_i: ${flag_i}
# echo arg_i: ${arg_i}
# echo flag_f: ${flag_f}
# echo arg_f: ${arg_f}
# echo flag_l: ${flag_l}
# echo arg_l: ${arg_l}

# jmx
if [[ ${flag_f} -ne 0 ]]; then
	jmxName=${arg_f}
else
	echo "Error: Please specify JMX using -f."
	showHelp
	exit 0
fi

# docker image
jmeterDocker="ghcr.io/cage1016/jmeter:5.4.1"
if [[ ${flag_i} -ne 0 ]]; then
	jmeterDocker=${arg_i}
fi

# daemon
daemon="docker"
if [[ ${flag_d} -ne 0 ]]; then
	daemon=${arg_d}
fi

# tar.gz
enbaleTargz=false
if [[ ${flag_z} -ne 0 ]]; then
	enbaleTargz=${arg_z}
fi

# test folder
testFolder="./tmp"
if [[ ${flag_t} -ne 0 ]]; then
	testFolder=${arg_t}
fi
rDir=${testFolder}/report
rm -rf ${rDir} ${testFolder}/*.jtl ${testFolder}/*.log > /dev/null 2>&1
mkdir -p ${rDir}

subCommand=""
if [[ ${flag_l} -ne 0 ]]; then
	subCommand=$(createSubCommand2 ${arg_l})	
fi

echo ""
echo ${daemon} run --rm --name jmeter --network host -i -v $\{PWD\}:$\{PWD\} -w $\{PWD\} ${jmeterDocker} \
	${jmxName} -l ${testFolder}/jmeter.jtl -j ${testFolder}/jmeter.log ${subCommand} -o ${rDir} -e
echo ""

eval ${daemon} run --rm --name jmeter --network host -i -v ${PWD}:${PWD} -w ${PWD} ${jmeterDocker} ${jmxName} -l ${testFolder}/jmeter.jtl -j ${testFolder}/jmeter.log ${subCommand} -o ${rDir} -e

echo ""
echo "==== jmeter.log ===="
echo "See jmeter log in ${testFolder}/jmeter.log"

echo "==== Raw Test Report ===="
echo "See Raw test report in ${testFolder}/${jmxName}.jtl"

echo "==== HTML Test Report ===="
echo "See HTML test report in ${rDir}/index.html"

if [[ ${enbaleTargz} == "true" ]]; then
	echo "==== Tar report ===="
	tar czf ${testFolder}/$(date +%s).tar.gz ${testFolder}/*.log ${testFolder}/*.jtl ${rDir}
	echo "See Tar file in ${testFolder}/$(date +%s).tar.gz"
fi
