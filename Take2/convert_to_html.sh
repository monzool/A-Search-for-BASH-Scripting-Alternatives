#!/bin/bash

pandoc --wrap=none --no-highlight Take2.md -o Take2.html
sed -i 's+assets/+https://monzool.net/blog/wp-content/uploads/2024/07/+g' Take2.html
sed -i '1,3d;' Take2.html
