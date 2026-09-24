#!/bin/bash
# Lab 02 - Rotate Ghost IP - Defensa Activa Perimetral
# Autor: Iván Ajenjo Morales
# Descripción: Cuando se detecta un ataque, la IP fantasma salta para despistar al atacante
# y validar reglas Risk-Based en Wazuh SIEM

GHOST_NET="ghost_net"
GHOST_CONTAINER="ghost-attacker"
LOG_FILE="/var/log/nginx/access.log"

echo "[*] Laboratorio Perimetral Rojo + Atacante Fantasma - Protección Activa"
echo "[*] Monitorizando ataques en $LOG_FILE..."
echo "[*] IP fantasma actual: 10.10.20.99 -> saltará a nueva IP aleatoria al detectar ataque"

# Función para rotar IP fantasma
rotar_ip() {
    NEW_IP="10.10.20.$((RANDOM % 150 + 10))"
    echo "[!] Ataque detectado! Rotando IP fantasma a $NEW_IP..."
    
    docker network disconnect $GHOST_NET $GHOST_CONTAINER 2>/dev/null
    sleep 1
    docker network connect --ip $NEW_IP $GHOST_NET $GHOST_CONTAINER --alias ghost-attacker-2
    
    # Notifica a Wazuh SIEM para que genere alerta Risk-Based
    logger -t wazuh "Ghost IP rotada de 10.10.20.99 a $NEW_IP por ataque detectado - MITRE T1110.001"
    echo "[+] Nueva IP fantasma: $NEW_IP (alias ghost-attacker-2)"
    echo "[+] Wazuh debe registrar 2 ofensas mismo hostname, IP distinta -> valida regla Risk-Based Priority"
}

# Modo 1: Detección automática por logs (si existe log)
if [ -f "$LOG_FILE" ]; then
    tail -F $LOG_FILE 2>/dev/null | while read line; do
        if echo $line | grep -E -q " 401 | 403 |/admin|/wp-login"; then
            rotar_ip
            sleep 5 # Cooldown para no rotar sin parar
        fi
    done
else
    # Modo 2: Demo / Laboratorio - rota cada 30s y al presionar Enter
    echo "[*] Modo LAB: No se encontró $LOG_FILE, modo demo cada 30s + Enter para forzar salto"
    while true; do
        echo ""
        read -t 30 -p "Presiona Enter para simular ataque y hacer saltar la IP (auto cada 30s)..."
        rotar_ip
    done
fi
