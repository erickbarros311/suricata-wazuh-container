#!/bin/bash

# Define o IP do Wazuh Manager se a variável WAZUH_MANAGER estiver presente
if [ -n "$WAZUH_MANAGER" ]; then
    /var/ossec/bin/agent-auth -m "$WAZUH_MANAGER" -A "Suricata-Docker-Agent"
    sed -i "s/<address>172.21.0.4<\/address>/<address>${WAZUH_MANAGER}<\/address>/g" /var/ossec/etc/ossec.conf
fi

# Inicia o serviço do Wazuh Agent
echo "Iniciando Wazuh Agent..."
/var/ossec/bin/wazuh-control start

# Executa o Suricata (passando os argumentos do CMD do Docker)
echo "Iniciando Suricata..."
exec "$@"

