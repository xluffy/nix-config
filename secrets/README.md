# AgeNix

Create secrets (go to secrets store, add new secret via EDITOR)

```bash
> agenix -e my-secret.age
```

Decrypt

```bash
> agenix -d my-secret.age -i ~/.ssh/id_ed25519
```

Rekey

```bash
> agenix --rekey
```

Ref:

- https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview
