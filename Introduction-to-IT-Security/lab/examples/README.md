# Attack examples

Ready-to-use packages for the lab. Publish one to the (simulated) public registry with:

```bash
./lab.sh publish examples/evil-pronto-utils
```

- `evil-pronto-utils/` – dependency-confusion attack (Part A, task A5). Same name as the
  shop's internal `pronto-utils`, but version `9.9.9`. Its `postinstall` script sends the
  shop's environment variables to the collector. Change the version or the script and
  publish again to experiment.
