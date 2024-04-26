# Elastic - Logstash - Kibana (ELK stack)

## Environment variables
```text
ELK_VERSION=8.12.0
KIBANA_ELASTICSEARCH_URL=es:9200
```

## Get started
1. Pull repository: ```git pull git@github.com:dadadam/elk.git```
2. Go to created folder ```cd elk```
3. Create ```.env``` file: ```touch .env```
4. Insert environment variables to the created ```.env``` file
5. Start stack:
    - Only search stack: ```docker compose --profile search up -d```
    - Full stack: ```docker compose up -d```
6. Open brouser and go to the [http://localhost:5601](http://localhost:5601)


## Work with index (Elastic)

### Create elastic index with settings and mapper
Includes:
- russian stemmer filter (out of the box)
- hunspell dictionary (for russian and kazakh languages)
    - russian dictionary from [LibreOffice](https://extensions.libreoffice.org/en/extensions/show/russian-spellcheck-dictionary.-based-on-works-of-aot-group)
    - kazakh dictionary from [Elastic-Hunspell repo](https://github.com/elastic/hunspell)
- char mapping for special russian and kazakh letters
- phonetic filter for translit (russian and english)
```shell
curl -L -X PUT 'http://localhost:9200/<index-name>' \
-H 'Content-Type: application/json' \
-d '{
    "settings": {
        "analysis": {
            "filter": {
                "russian_stop": {
                    "type": "stop",
                    "stopwords": "_russian_"
                },
                "russian_stemmer": {
                    "type": "stemmer",
                    "language": "russian"
                },
                "ru_hunspell": {
                    "type": "hunspell",
                    "locale": "ru_RU"
                },
                "kk_hanspell": {
                    "type": "hunspell",
                    "locale": "kk_KZ"
                },
                "custom_phonetic_cyrillic": {
                    "type": "phonetic",
                    "encoder": "beider_morse",
                    "rule_type": "approx",
                    "name_type": "generic",
                    "languageset": [
                        "cyrillic"
                    ]
                },
                "custom_phonetic_english": {
                    "type": "phonetic",
                    "encoder": "beider_morse",
                    "rule_type": "approx",
                    "name_type": "generic",
                    "languageset": [
                        "english"
                    ]
                }
            },
            "char_filter": {
                "custom_ru_char_filter": {
                    "type": "mapping",
                    "mappings": ["Ё => Е", "ё => е", "Й => И", "й => и"]
                },
                "custom_kz_char_filter": {
                    "type": "mapping",
                    "mappings": [
                        "ә => a",
                        "ғ => г",
                        "қ => к",
                        "ң => н",
                        "ө => о",
                        "ұ => у",
                        "ү => у",
                        "h => х",
                        "і => и",
                        "Ә => А",
                        "Ғ => Г",
                        "Қ => К",
                        "Ң => Н",
                        "Ө => О",
                        "Ұ => У",
                        "Ү => У",
                        "І => и"
                    ]
                }
            },
            "analyzer": {
                "custom_russian_analyzer": {
                    "tokenizer": "edge_ngram",
                    "filter": [
                        "lowercase",
                        "custom_phonetic_cyrillic",
                        "custom_phonetic_english",
                        "russian_stop",
                        "russian_stemmer",
                        "ru_hunspell",
                        "kk_hanspell"
                    ],
                    "char_filter": [
                        "custom_ru_char_filter",
                        "custom_kz_char_filter"
                    ]
                }
            }
        }
    },
    "mappings": {
        "properties": {
            "title": {
                "type": "text",
                "store": true,
                "analyzer": "custom_russian_analyzer"
            },
            "rank": {
                "type": "float"
            }
        }
    }
}'
```

### Search ([doc](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html))
```shel
curl -L 'http://localhost:9200/product-index/_search' \
-H 'Content-Type: application/json' \
-d '{
  "query": {
    "match": {
      "title": "gasyr"
    }
  }
}'
```

### Add document to index ([doc](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html))
Document structure (by mapper):
```json
{
    "title": "value",
    "rank": 5.0
}
```
request:
```shell
curl -L 'http://localhost:9200/<index-name>/_doc/' \
-H 'Content-Type: application/json' \
-d '{
    "title": "value",
    "rank": 5.0
}'
```

### Remove index
```shell
curl -L -X DELETE 'http://localhost:9200/<index-name>'
```


## Default values

### Elasticsearch
Image: [bitnami/elasticsearch](https://hub.docker.com/r/bitnami/elasticsearch)

Default values:
```
ELASTICSEARCH_HTTP_PORT_NUMBER: 9200
ELASTICSEARCH_USERNAME: elastic
ELASTICSEARCH_PASSWORD: bitnami
```


### Logstash
Image: [bitnami/logstash](https://hub.docker.com/r/bitnami/logstash)

Default values:
```
LOGSTASH_GELF_PORT_NUMBER: 12201
LOGSTASH_HTTP_PORT_NUMBER: 8080
LOGSTASH_API_PORT_NUMBER: 9600
```


### Kibana
Image: [bitnami/kibana](https://hub.docker.com/r/bitnami/kibana)

Default values:
```
KIBANA_PORT_NUMBER: 5601
APACHE_KIBANA_USERNAME: kibana
APACHE_KIBANA_PASSWORD: bitnami
```
