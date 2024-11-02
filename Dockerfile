FROM telegraf:1.28

USER root

# Install tshark and its dependencies
RUN apt-get update &&     DEBIAN_FRONTEND=noninteractive apt-get install -y     tshark     libcap2-bin &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*

# Set capabilities for tshark/dumpcap
RUN setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap

# Switch back to telegraf user but keep needed capabilities
USER telegraf
