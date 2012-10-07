#!/bin/sh

JAVA_OPTS="-Xmx1024M" vertx run app.coffee -cp "lib/ehcache-core-2.6.0.jar:lib/slf4j-api-1.7.0.jar:lib/slf4j-simple-1.7.0.jar:lib/handlebars-0.5.3.jar:lib/commons-lang3-3.1.jar:lib/parboiled-java-1.0.2.jar:lib/parboiled-core-1.0.2.jar:lib/asm-3.3.1.jar"

