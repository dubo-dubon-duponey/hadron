# Unifi backup explode

https://www.incredigeek.com/home/extract-unifi-unf-backup-file/

In a shell:

```bash
./decrypt.sh backup.unf backup.zip
unzip backup.zip -d destination
```

Install bsondump

```bash
brew tap mongodb/brew
brew install mongodb-database-tools
```

Dump it

```bash
gunzip db.gz
bsondump --bsonFile=db --outFile=db.json
```
