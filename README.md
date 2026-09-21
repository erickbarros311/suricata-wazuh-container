# Suricata IDS & Wazuh Agent Docker Lab Stack

Este projeto implementa um laboratório autônomo de monitoramento de segurança e detecção de intrusão (IDS) utilizando o **Suricata** integrado com o **Wazuh Agent** dentro de um único container baseado em **Ubuntu 24.04**. 

A stack foi projetada para operar diretamente dentro da rede virtual isolada do Docker chamada `single-node_default` (compartilhada com o Wazuh Manager), eliminando a necessidade de expor o tráfego em modo `host`. Para fins de validação e testes, a stack inclui um host secundário (`test-host`) recheado com utilitários de diagnóstico de rede.

## 🚀 Tecnologias e Ferramentas inclusas

### Container Principal (`suricata-wazuh`)
- **Ubuntu 24.04 LTS** como imagem base.
- **Suricata IDS** integrado via PPA estável oficial (OISF).
- **Wazuh Agent 4.x** embarcado e pré-configurado.
- Editor de texto `nano` e ferramentas como `net-tools` (`ifconfig`) e `tcpdump` funcionais via gerenciador `apt`.

### Container de Teste (`test-host`)
- Sistema operacional **Ubuntu 24.04**.
- Utilitários nativos pré-instalados: `curl`, `wget`, `net-tools`, `iputils-ping`, `tcpdump`, `traceroute`, `nmap`, `iperf3`, `netcat-openbsd` e `dnsutils`.

## 📁 Estrutura do Projeto
Certifique-se de manter os seguintes arquivos no mesmo diretório local:
```text
.
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
└── README.md
```

---

## 🛠️ Instruções de Implantação

### 1. Ajustar Variáveis de Ambiente
Verifique no arquivo `docker-compose.yml` se o parâmetro `WAZUH_MANAGER` está apontando para o IP interno correto do seu Wazuh Manager na rede virtual (Padrão: `172.21.0.4`).

### 2. Validar Permissão do Script de Entrada
Antes do deploy, garanta privilégios de execução ao script gerenciador de serviços:
```bash
chmod +x entrypoint.sh
```

### 3. Inicializar os Containers
Execute o comando abaixo para compilar a imagem do Ubuntu personalizada e levantar os serviços em segundo plano:
```bash
docker compose up -d
```

---

## 🔍 Como Testar a Pipeline de Alertas

Como o Suricata está operando de forma isolada dentro da rede virtual bridge do Docker, ele monitorará o tráfego que transita por esta interface (`eth0` interna do container). Para testar o acionamento de assinaturas:

1. **Acesse o terminal do container de testes:**
   ```bash
   docker compose exec -it test-host /bin/bash
   ```

2. **Dispare uma requisição HTTP simulando um User-Agent malicioso ("BlackSun"):**
   ```bash
   curl -A "BlackSun" http://172.21.0.4
   ```

3. **Verifique se o Suricata registrou o alerta no arquivo JSON:**
   Abra um novo terminal no seu host e busque pela assinatura disparada dentro do container do IDS:
   ```bash
   docker compose exec -it suricata-wazuh-container grep "BlackSun" /var/log/suricata/eve.json
   ```

O **Wazuh Agent** lerá esta nova entrada no arquivo `eve.json` instantaneamente e fará o repasse automático para o console do seu Wazuh Manager através do ID de regra nativo `86601`.

