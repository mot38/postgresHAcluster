#!/bin/bash

for SERVER in A B C D ; do
  vagrant snapshot take ${SERVER} snapshot${SERVER}
done
