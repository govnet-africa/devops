FROM golang:1.21.5-alpine3.18 as builder
ARG GIT_USER="ugonline"
ARG GIT_PASS="ghp_pat_xxxxx"
ARG GO_DEV_PROXY="https://proxy.golang.org,direct"
RUN echo "machine github.com login ${GIT_USER} password ${GIT_PASS}" > ~/.netrc
RUN apk add ca-certificates git tzdata
WORKDIR /src
COPY go.mod .
COPY go.sum .
# resolve dependencies
ENV GO111MODULE=on 
ENV GOPRIVATE=github.com/govnet-mofa 
ENV GOPROXY=${GO_DEV_PROXY}
RUN go mod download
# build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -installsuffix 'static' -o ugonline-svc .
# package slimmer container
FROM scratch
ARG SERVICE="ugonline-svc"
ARG VERSION="0.0.1"
WORKDIR /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /src/ugonline-svc .
ENV APP_HTTP_PORT=80
ENV APP_VERSION="${SERVICE}-ver${VERSION}"
EXPOSE 80
CMD ["/ugonline-svc"]