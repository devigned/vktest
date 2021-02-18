FROM golang:1.15 as builder
ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go
ENV GO111MODULE on
RUN git clone https://github.com/virtual-kubelet/azure-aci.git && cd azure-aci && make build

FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE 1
RUN apt-get update && \
        apt-get install -y apt-transport-https curl gnupg ca-certificates cloud-init udev vim && \
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
        apt-get update && \
        apt-get install -y kubelet kubeadm kubectl docker-ce docker-ce-cli containerd.io && \
        apt-get clean -y && \
        rm -rf \
           /var/cache/debconf/* \
           /var/lib/apt/lists/* \
           /var/log/* \
           /tmp/* \
           /var/tmp/* \
           /usr/share/doc/* \
           /usr/share/man/* \
           /usr/share/local/*

COPY --from=builder /go/azure-aci/bin/virtual-kubelet /usr/bin/virtual-kubelet
COPY cloud.cfg /etc/cloud/cloud.cfg
COPY 91-datasource.cfg /etc/cloud/cloud.cfg.d/91-datasource.cfg
# COPY bootstrap.yml /var/lib/capi/bootstrap.yml
COPY init.sh /init.sh
RUN chmod +x /init.sh