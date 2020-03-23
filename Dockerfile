FROM golang:1.13 as builder

RUN git clone https://github.com/moveaxlab/sops-helm-wrapper.git && \
    cd sops-helm-wrapper && \
    go build && \
    ls -la /go/

FROM argoproj/argocd:v1.4.2

USER root

RUN apt-get update && \
    apt-get install -y \
      gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mv /usr/local/bin/argocd-repo-server /usr/local/bin/_argocd-repo-server && \
    mv /usr/local/bin/helm /usr/local/bin/_helm

# copy sops-helm-wrapper to be used as helm
COPY --from=builder /go/sops-helm-wrapper/sops-helm-wrapper /usr/local/bin/helm
# copy Argo-repo-server wrapper to import GPG private key on run
COPY argocd-server-wrapper /usr/local/bin/argocd-repo-server

# Switch back to ArgoCD user
USER argocd