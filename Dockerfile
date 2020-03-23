
FROM argoproj/argocd:v1.4.2
# Switch to root for the ability to perform install
USER root

# Install tools needed for your repo-server to retrieve & decrypt secrets, render manifests 
# (e.g. curl, awscli, gpg, sops)
RUN apt-get update && \
    apt-get install -y \
        curl \
        awscli \
        sudo -y \
        gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    usermod -aG sudo argocd
ENV HELM_BIN="/usr/local/bin/helm"
ENV HELM_HOME="/home/argocd/.helm"
RUN mkdir -p /home/argocd/.helm/plugins && \
    helm plugin install https://github.com/futuresimple/helm-secrets
RUN mv /usr/local/bin/argocd-repo-server /usr/local/bin/_argocd-repo-server
COPY argocd-server-wrapper /usr/local/bin/argocd-repo-server
# Switch back to non-root user
USER argocd
