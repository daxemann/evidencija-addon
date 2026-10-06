ARG BUILD_FROM
FROM tailscale/tailscale:stable AS ts

FROM mcr.microsoft.com/dotnet/aspnet:9.0
ARG BUILD_ARCH=aarch64

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ts /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=ts /usr/local/bin/tailscale /usr/local/bin/tailscale

COPY app/${BUILD_ARCH}/ /app/
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENV ASPNETCORE_URLS=http://0.0.0.0:5080 \
    ASPNETCORE_FORWARDEDHEADERS_ENABLED=true \
    Podaci__Mapa=/data/Podaci \
    DOTNET_gcServer=0 \
    DOTNET_GCHeapHardLimit=0x18000000 \
    TZ=Europe/Zagreb

WORKDIR /app
CMD ["/run.sh"]
