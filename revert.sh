#!/bin/bash

for SERVER in nodea nodeb nodec bart ; do
  vagrant snapshot back ${SERVER}
done
