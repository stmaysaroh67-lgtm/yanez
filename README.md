# Yanez Mining SN54 — Codespace (API offload + localtonet)

Miner ringan: terima tugas dari validator → request API generate → upload S3 → balas axon.  
Tidak pakai GPU lokal. Public IP lewat tunnel TCP localtonet yang sudah dibuat di dashboard.

## Struktur

```
Yanez Mining Codespace/
├── .devcontainer/
│   ├── devcontainer.json   # postCreate → setup.sh | postStart → start-miner.sh
│   ├── setup.sh            # clone MIID, inject custom, venv, localtonet
│   ├── start-miner.sh      # gate + launch localtonet + miner (detached)
│   ├── bootstrap.sh        # fallback one-shot
│   ├── run-localtonet.sh
│   └── run-miner.sh
├── custom/                 # stack proven dari PC (inject utuh — jangan partial)
│   ├── protocol.py         # WAJIB versi PC (ScreenReplayUAV + daily_seed_*)
│   ├── miner.py
│   ├── image_generator.py  # API offload Vercel
│   ├── s3_upload.py
│   ├── base_miner.py
│   └── drand_encrypt.py
├── wallets/wallet_mainnet/ # di-inject ke ~/.bittensor/wallets/
├── .env.example
├── .gitignore
└── README.md
```

Setelah setup, muncul juga: `MIID-subnet/`, `bin/localtonet`, `logs/`.

## Persiapan sebelum Create Codespace

1. Copy `.env.example` → `.env`
2. Isi minimal:
   - `LOCALTONET_AUTHTOKEN` (My Tokens di localtonet)
   - `AXON_EXTERNAL_IP` + `AXON_EXTERNAL_PORT` (host:port public tunnel TCP kamu)
   - `AXON_PORT` (port lokal di Codespace, default 1080 — samakan dengan target tunnel localtonet `127.0.0.1:PORT`)
   - `WALLET_NAME` / `WALLET_HOTKEY` jika bukan default
3. Pastikan di dashboard localtonet:
   - Tunnel **TCP** sudah dibuat
   - Local IP/Port = `127.0.0.1` + nilai `AXON_PORT`
   - Device akan connect otomatis setelah client di Codespace auth dengan token yang sama

## Alur otomatis

| Hook | Script | Fungsi |
|------|--------|--------|
| postCreate | `setup.sh` | apt, clone MIID-subnet, inject 3 file + wallet, venv+pip, install localtonet, marker |
| postStart | `start-miner.sh` | gate lengkap → start localtonet detached → start miner detached |

## Monitoring (log)

```bash
# Proses
tail -f logs/localtonet.log
tail -f logs/miner.log

# Monitor API job (dari image_generator)
tail -f MIID-subnet/monitor_tambang.txt

# Pid
cat logs/localtonet.pid logs/miner.pid
```

Restart manual:

```bash
bash .devcontainer/start-miner.sh
```

Setup ulang:

```bash
bash .devcontainer/setup.sh
```

## Catatan

- Satu Codespace = satu wallet = satu tunnel localtonet = satu set `.env`
- `GENERATE_API_URL` default Vercel; bisa diganti per instance di `.env`
- Upstash tidak dipakai di build ini
- Wallet key ada di repo project (hati-hati permission/akses repo)
