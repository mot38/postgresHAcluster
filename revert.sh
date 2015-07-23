#!/bin/bash

for SERVER in A B C D ; do
  vagrant snapshot back ${SERVER}
done
