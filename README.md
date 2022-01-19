# Docker Jmeter

Jmeter Docker for `x86` and `s390x`

## Usage

1. Pull Docker image
    ```bash
    $ docker pull ghcr.io/cage1016/nginx-website-gz:0.1.0
    $ docker pull ghcr.io/cage1016/nginx-website:0.1.0
    $ docker pull ghcr.io/cage1016/jmeter:5.4.1
    ```

2. Dowonload `jmeter.sh` and test jmx `ap.jmx`

    ```bash
    $ wget https://raw.githubusercontent.com/cage1016/docker-jmeter/master/jmeter.sh && chmod +x jmeter.sh
    $ wget https://raw.githubusercontent.com/cage1016/docker-jmeter/master/ap.jmx
    ```

3. Start Nginx
    ```bash
    $ docker run --rm -d -p 8080:80 ghcr.io/cage1016/nginx-website-gz:0.1.0
    
    #or
    
    $ podman run --rm -d -p 8080:80 ghcr.io/cage1016/nginx-website-gz:0.1.0
    ```

4. Run Jmeter with Docker
    ```sh
    $ ./jmeter.sh -h
    Error: Please specify JMX using -f.
    Usage: jmeter.sh [-d <deamon>] [-i <jmeter_docker_image>] [-f <jmx_file>] [-t <test_folder>] [-z <enable_tar_html>]     [-l <jmeterVariablesList>]
     -d : Deamon, docker/podman (default: docker)
     -t : Test directory (default: ./tmp)
     -i : Jmeter docker image
     -f : Specify JMX file
     -l : Specify env list of Jmeter in following format: prop01=XXX,bbb=YYY,ccc=ZZZ
     -z : Enable tar html report (default: false)

      Example1: jmeter.sh -f ap.jmx
      Example2: jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx
      Example3: jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx -l prop01=XXX,prop02=YYY
    ```
5. Run test `ap.jmx`
    ```bash
    $ ./jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx -t ap -z true -l TARGET_HOST=localhost,TARGET_PORT=8080,THREADS=1,RAMD_UP=1,DURATION=10
    
    docker run --rm --name jmeter --network host -i -v ${PWD}:${PWD} -w ${PWD} ghcr.io/cage1016/jmeter:5.4.1 ap.jmx -l ap/jmeter.jtl -j ap/jmeter.log   -JTARGET_HOST=localhost -JTARGET_PORT=8080 -JTHREADS=1 -JRAMD_UP=1 -JDURATION=10 -o ap/report -e
    
    Creating summariser <summary>
    Created the tree successfully using ap.jmx
    Starting standalone test @ Wed Dec 29 08:39:40 GMT 2021 (1640767180391)
    Waiting for possible Shutdown/StopTestNow/HeapDump/ThreadDump message on port 4445
    Warning: Nashorn engine is planned to be removed from a future JDK release
    summary =   8157 in 00:00:10 =  812.8/s Avg:     1 Min:     0 Max:    36 Err:     0 (0.00%)
    Tidying up ...    @ Wed Dec 29 08:39:50 GMT 2021 (1640767190744)
    ... end of run
    
    ==== jmeter.log ====
    See jmeter log in ap/jmeter.log
    ==== Raw Test Report ====
    See Raw test report in ap/ap.jmx.jtl
    ==== HTML Test Report ====
    See HTML test report in ap/report/index.html
    ==== Tar report ====
    See Tar file in ap/1640767193.tar.gz
    ```