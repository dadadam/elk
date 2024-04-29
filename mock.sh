#!/bin/bash


jq -c '.[]' mock_data.json | while read i; do
    curl -L 'http://localhost:9200/product-index/_doc/' \
    -H 'Content-Type: application/json' \
    -d "$i"
done
