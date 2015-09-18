#!/bin/bash

for SERVER in nodea nodeb nodec bart ; do
  vagrant snapshot take ${SERVER} snapshot${SERVER}
done
