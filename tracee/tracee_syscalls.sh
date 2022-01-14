#!/bin/bash
echo "Tracing Events"
sudo docker run --name tracee --rm --privileged --pid=host \
-v /lib/modules/:/lib/modules/:ro -v /usr/src:/usr/src:ro \
-v /tmp/tracee:/tmp/tracee aquasec/tracee:0.4.0 --trace pid=new

#To capture suspicious behavior
echo "Tracing Suspicious Behavior"
sudo docker run --name tracee --rm --privileged --pid=host \
-v /lib/modules/:/lib/modules/:ro -v /usr/src:/usr/src:ro \
-v /tmp/tracee:/tmp/tracee aquasec/tracee:0.4.0 --trace comm=ls

