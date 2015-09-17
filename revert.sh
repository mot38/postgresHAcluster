#!/bin/bash

for SERVER in nodea nodeb nodec ; do
  vagrant snapshot back ${SERVER}
done
