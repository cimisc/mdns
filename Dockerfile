FROM debian:bookworm AS builder

RUN apt update && apt install -y build-essential libcap-dev cmake libcap2-bin

COPY mdns-reflector /usr/local/src/mdns-reflector
WORKDIR /usr/local/src/mdns-reflector

RUN mkdir -p build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=release .. \
    && make VERBOSE=1 \
    && make install DESTDIR=install

RUN setcap cap_net_raw+ep build/install/usr/local/bin/mdns-reflector

FROM debian:bookworm

COPY --from=builder /usr/local/src/mdns-reflector/build/install/ /

EXPOSE 5353/udp
USER 999

CMD ["/usr/local/bin/mdns-reflector", "-h"]
