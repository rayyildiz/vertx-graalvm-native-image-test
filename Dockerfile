FROM    rayyildiz/graalvm as builder

WORKDIR /src
COPY    . /src

RUN     apt-get update && apt-get -y install gcc libz-dev
RUN     ./mvnw compile package -e

RUN     native-image  \
          --no-server \
          -Dio.netty.noUnsafe=true  \
          -H:ReflectionConfigurationFiles=./reflectconfigs/netty.json \
          -H:+ReportUnsupportedElementsAtRuntime \
          -Dfile.encoding=UTF-8 \
          -jar target/vertx-graalvm-native-image-test-0.0.1-SNAPSHOT.jar

RUN     ldd vertx-graalvm-native-image-test-0.0.1-SNAPSHOT

FROM      ubuntu:slim
WORKDIR   /app
COPY      --from=builder /src/vertx-graalvm-native-image-test-0.0.1-SNAPSHOT /app/vertx

EXPOSE    8080
CMD       ["/app/vertx"]
