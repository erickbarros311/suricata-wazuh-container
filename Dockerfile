FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instala dependências básicas essenciais primeiro
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    nano \
    net-tools \
    iputils-ping \
    tcpdump \
    gnupg \
    apt-transport-https \
    && add-apt-repository -y ppa:oisf/suricata-stable

# 2. CORREÇÃO: Baixa e desarma a chave GPG do Wazuh no diretório correto
RUN curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg

# 3. Adiciona o repositório correto referenciando a chave (.gpg) limpa
RUN echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list

# 4. Atualiza os repositórios (agora válidos) e instala o Suricata e o Wazuh Agent
RUN apt-get update && apt-get install -y \
    suricata \
    wazuh-agent \
    && rm -rf /var/lib/apt/lists/*

# 5. Configura o Wazuh Agent interno para ler o arquivo do Suricata (eve.json)
RUN sed -i '/<\/ossec_config>/i \
  <localfile>\n\
    <log_format>json<\/log_format>\n\
    <location>\/var\/log\/suricata\/eve.json<\/location>\n\
  <\/localfile>' /var/ossec/etc/ossec.conf

# Atualiza as regras do Suricata
RUN suricata-update

# Copia e dá permissão ao script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/var/log/suricata"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["suricata", "-c", "/etc/suricata/suricata.yaml", "-i", "eth0"]

