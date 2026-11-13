# Lab: Supply Chain Security & DevSecOps – Pizza Pronto

> You are the security team of **Pizza Pronto** (see [../company](../company)).
> Luca, the owner's nephew, built the online ordering website on a few weekends.
> In this lab you look at the website the way an attacker – and the way a modern
> development team – would.

**⚠️ Everything here is intentionally vulnerable. Only run it inside the training VM. Never use these techniques against systems you do not own.**

---

## 0. Setup (once)

Everything runs locally in containers inside your Kali VM (Docker or Podman – the script
auto-detects). No accounts, no logins, no cloud.

```bash
cd Introduction-to-IT-Security/labs/pizza-pronto
./lab.sh setup      # needs internet once, downloads/builds ~5 GB
```

When that finishes, start the Supply Chain part:

```bash
./lab.sh start
```

| What | URL |
|------|-----|
| Pizza Pronto shop | http://localhost:3000 |
| Collector ("attacker server") | http://localhost:8000 |
| Internal package registry | http://localhost:4873 |
| Public package registry (simulated npm) | http://localhost:4874 |

Open the **shop** and the **collector** side by side in your browser. The collector
is a tiny server the attacker controls – whenever something sends data "home",
you will see it appear there live.

> `./lab.sh status` shows the URLs again, `./lab.sh stop` stops everything,
> `./lab.sh reset` brings the lab back to the start.

Use the [lab-report.md](../../lab-report.md) to note down your findings and the flags
you capture (they look like `FLAG{...}`).

---

## Part A – Supply Chain Attacks (≈ 45 min)

Modern apps are mostly other people's code. The Pizza Pronto shop has ~200 npm
packages that Luca never looked at. Let's see what that means.

### A1 – What are we even shipping? (SBOM)

An **SBOM** (Software Bill of Materials) is the list of ingredients of your software.

```bash
docker compose exec shop sh -c "npm ls --all 2>/dev/null | head -40"
```

- How many packages does the shop depend on, directly and indirectly?
- Luca wrote maybe 150 lines himself. Who wrote the rest? Do you know them?

### A2 – A typo with consequences (Typosquatting)

Look closely at the dependencies in `app/package.json`. One of them is **not** the
package Luca thinks it is – it's a copy with a name that differs by one letter from
a very popular package.

1. Find the suspicious package name. (Hint: a famous utility library – spell it out loud.)
2. Watch the collector (http://localhost:8000), then reinstall the dependencies:
   ```bash
   ./lab.sh redeploy
   ```
3. What appears on the collector? Where did that data come from, and when did the
   malicious code run – did anyone "use" the package?

> **Lesson:** `npm install` runs other people's code (`postinstall` scripts) on your
> machine, before your app even starts. A single typo can hand over everything in your
> environment.

### A3 – The update that went bad (Compromised dependency)

Legit packages can turn malicious when a maintainer's account is taken over or a
maintainer is tricked (this really happened: *xz-utils* 2024, *chalk/debug* 2025).

In the public registry, the package `tiny-receipt` has two versions: `1.2.0` (clean)
and `1.2.1` (a maintainer "update"). Compare them:

```bash
docker compose --profile tools run --rm attacker sh -c "
  npm pack tiny-receipt@1.2.0 --registry http://registry-public:4873/ >/dev/null 2>&1
  npm pack tiny-receipt@1.2.1 --registry http://registry-public:4873/ >/dev/null 2>&1
  mkdir a b && tar xf tiny-receipt-1.2.0.tgz -C a && tar xf tiny-receipt-1.2.1.tgz -C b
  diff -u a/package/index.js b/package/index.js
"
```

- What was added in `1.2.1`? Why is it written to look harmless ("perf: warm up cache")?
- `app/package.json` asks for `"tiny-receipt": "^1.2.0"`. What does the `^` mean –
  which version gets installed on the next deployment?

### A4 – Code execution through a shopping cart (Insecure dependency)

The shop stores your cart in a cookie using the package `node-serialize`. That package
has a well-known, critical vulnerability.

1. Find out which known vulnerability `node-serialize@0.0.4` has (search for
   "node-serialize CVE"). What does it allow?
2. In `app/server.js`, find where the cart cookie is read. Why is turning attacker-controlled
   data back into an object dangerous here?

> We will *exploit* this one together with the trainer – for now, just understand *why*
> it is exploitable. The fix is one line: never deserialize untrusted data, use `JSON.parse`.

### A5 – Sneaking your own package into the build (Dependency Confusion)

The shop uses an **internal** package `pronto-utils` (Luca wrote it, it only lives in
Pizza Pronto's internal registry). The deployment pulls dependencies from the internal
registry, which *also forwards requests to the public registry*.

Question: what happens if a package with the **same name** but a **higher version**
suddenly appears on the *public* registry?

Try it (you are now the attacker):

```bash
./lab.sh attacker          # opens a shell with node/npm on the lab network
```

Inside that shell, create a package `pronto-utils` with a **higher version number**
than 1.0.0, add a `postinstall` script that pings the collector, log in to the public
registry and publish it. Then leave the shell and trigger a deployment:

```bash
./lab.sh redeploy
```

- Which `pronto-utils` version does the shop install now – the internal one or yours?
- What shows up on the collector?

> **Lesson:** If internal package names are guessable and your registry falls back to
> the public one, an attacker can "shadow" internal packages. Fixes: scoped names
> (`@pizzapronto/utils`), pinned versions + lockfiles, and a registry that never
> forwards internal names.

> Capture the flags hidden in the environment variables / files you manage to exfiltrate.

When you're done, clean up: `./lab.sh reset`.

---

## Part B – DevSecOps: Build a security pipeline (≈ 60 min)

Part A was depressing. Part B is the cure: we add automated security checks so these
problems get caught **before** they ship. We do it on a real (local) Git server with
a real CI pipeline – exactly how a modern team works.

```bash
./lab.sh devsecops
```

This additionally starts **Gitea** (a self-hosted GitHub) at http://localhost:3030
(log in as `luca` / `pizza-pronto-123`). The shop code is in the repo **luca/shop**,
including Luca's embarrassing git history.

Open the repo. There is already a CI pipeline under `.gitea/workflows/ci.yml` that only
checks the syntax. Your job: turn it into a **security pipeline**. We build it step by
step together; after each step you commit and watch the pipeline run under *Actions*.

| Step | Tool | Catches | Which Part-A problem |
|------|------|---------|----------------------|
| 1 | **gitleaks** | secrets in code & git history | the `.env` Luca committed |
| 2 | **semgrep** | dangerous code patterns | command injection, insecure deserialization |
| 3 | **hadolint** + **trivy config** | insecure Dockerfile | runs as root, `ADD`, no pinning |
| 4 | **guarddog** | malicious packages | typosquat (A2), bad update (A3) |
| 5 | **syft** + **trivy** | known-vulnerable deps | node-serialize (A4) |
| 6 | **security gate** | fail the build if anything was found | stop the deployment |

All tools are pre-installed in the `secscan` image and work **offline**. The exact
commands are introduced on the slides / by the trainer; the full reference pipeline
is in the solutions.

### B1 – Secret in the history

Even though Luca "removed" the `.env` file, it is still in the git history forever.
Find it:

```bash
docker compose run --rm -w /src secscan sh -c "git clone -q http://gitea:3000/luca/shop.git . && gitleaks git --no-banner --redact ."
```

- Which secret shows up? In which commit? What does the commit message say? 😅
- Why is "just delete the file and commit" not enough?

### B2 – Build the pipeline

Add the checks to `.gitea/workflows/ci.yml` (edit directly in the Gitea web UI or push
from the VM), commit, and watch the pipeline turn **red** – it now *finds* the problems.

### B3 – Fix until green

Now fix the shop so the pipeline passes:

- remove the typosquatted package, use the correct one
- pin the good `tiny-receipt` version + add a lockfile
- replace `node-serialize` with `JSON.parse`
- fix the command injection (use `execFile` with an argument list)
- move secrets out of the code, harden the Dockerfile (non-root, `COPY`, pin the base image)

Re-run the pipeline after each fix. Goal: **all checks green.** That green checkmark is
"Shift Left" – security moved to the earliest possible moment.

### B4 – Keep dependencies fresh (Renovate)

Outdated dependencies are how most known vulnerabilities get in. **Renovate** watches
your dependencies and opens pull requests when updates exist:

```bash
./lab.sh renovate
```

Look at the new pull request in Gitea (luca/shop → Pull Requests). This is the boring
but most effective supply-chain defense: update small and often, with CI checking every
update.

---

## Part C – Supply chain for AI agents: the Skill Battle (≈ 45 min)

AI coding assistants are extended with **skills** and **MCP servers** – which are just
more dependencies, often from strangers, that run with a lot of access.

In this part you *write* a security-review skill and, at the end, the trainer runs all
teams' skills against the shop and compares who found the most. One of the skills in the
round is a trainer-provided **trap** – a skill that looks helpful but misbehaves. See
[skills/README.md](skills/README.md) for the rules.

---

## Cheat sheet

```bash
./lab.sh setup       # once, with internet
./lab.sh start       # Supply Chain lab
./lab.sh devsecops   # + Gitea + CI
./lab.sh attacker    # attacker shell on the lab network
./lab.sh renovate    # run the update bot
./lab.sh redeploy    # redeploy the shop
./lab.sh status      # containers + URLs
./lab.sh reset       # back to start
./lab.sh stop        # stop everything
```
