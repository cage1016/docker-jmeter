#!/bin/bash

TARGET_HOST=${TARGET_HOST:-"localhost"}
TARGET_PORT=${TARGET_PORT:-"8080"}
DAEMON=${DAEMON:-"docker"}

NAME="jmeter"
JMETER=${JMETER:-"ghcr.io/cage1016/jmeter"}
JMETER_VERSION=${JMETER_VERSION:-"5.4.1"}
IMAGE="${JMETER}:${JMETER_VERSION}"
JMX=${JMX:-"ap.jmx"}
JMX_NAME=$(cut -d'.' -f1 <<< ${JMX})

T_DIR=${T_DIR:-"./ap"}

# Reporting dir: start fresh
R_DIR=${T_DIR}/report
rm -rf ${R_DIR} > /dev/null 2>&1
mkdir -p ${R_DIR}

/bin/rm -rf ${T_DIR}/report ${T_DIR}/${JMX_NAME}.jtl ${T_DIR}/${JMX_NAME}-jmeter.log > /dev/null 2>&1

${DAEMON} run --rm --name ${NAME} --network host -i -v ${PWD}:${PWD} -w ${PWD} ${IMAGE} \
	${JMX} -l ${T_DIR}/${JMX_NAME}.jtl -j ${T_DIR}/${JMX_NAME}-jmeter.log \
	-JTARGET_HOST=${TARGET_HOST} \
	-JTARGET_PORT=${TARGET_PORT} \
	-JTHREADS=${THREADS} \
	-JRAMD_UP=${RAMD_UP} \
	-JDURATION=${DURATION} \
	-JSETUP_DELAY=${SETUP_DELAY} \
	-o ${R_DIR} -e

echo "==== ${JMX_NAME}-jmeter.log ===="
echo "See jmeter log in ${T_DIR}/${JMX_NAME}-jmeter.log"

echo "==== Raw Test Report ===="
echo "See Raw test report in ${T_DIR}/${JMX_NAME}.jtl"

echo "==== HTML Test Report ===="
echo "See HTML test report in ${R_DIR}/index.html"

echo "==== Tar report ===="
tar czf ${T_DIR}/$(date +%s).tar.gz ${T_DIR}/${JMX_NAME}-jmeter.log ${T_DIR}/${JMX_NAME}.jtl ${R_DIR}
echo "See Tar file in ${T_DIR}/$(date +%s).tar.gz"