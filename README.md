# Lab 02 - Red Perimetral + Ghost Attacker 🛡️

![Arquitectura Perimetral Moderna](diagrama-perimetral-moderno.png)

> Laboratorio SOC L1 - Red perimetral Docker con IP fantasma rotativa para validar reglas Risk-Based Priority.

## Arquitectura
- **perimetral**: Open Collector + victima
- **soc_interno (internal)**: Wazuh SIEM
- **ghost_net**: Ghost Attacker

Flujo: WEB + BBDD -> DOCKER BRIDGE -> REGLAS IPTABLES DNAT/FILTER -> eth0 Host -> RED EXTERNA

## Despliegue
```bash
docker-compose up -d
docker network connect --alias ghost-attacker-2 perimetral ghost-attacker
