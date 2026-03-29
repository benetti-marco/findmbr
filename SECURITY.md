# Security Policy

## Supported Versions
Security fixes are provided for the **latest version** on the default branch.

## Reporting a Vulnerability
If you believe you have found a security vulnerability, please **do not open a public issue**.

Instead, report it privately:

- Preferred: Use GitHub **Private vulnerability reporting** (if enabled for this repository).
- Alternative: Contact the maintainer directly (TODO: add an email address or other private contact method).

Please include:
- A clear description of the vulnerability
- Steps to reproduce (proof of concept if possible)
- Potential impact
- Any relevant environment details (IBM i version, shell, configuration)

## Response Timeline
We aim to:
- Acknowledge receipt within **7 days**
- Provide a status update within **14 days**
- Release a fix as soon as practical, depending on complexity and impact

## Disclosure
Please coordinate disclosure with the maintainer. We may request a reasonable embargo period to allow users to update.

## Security Hardening Notes (for contributors)
- Do not commit secrets (tokens, passwords, private endpoints).
- Prefer safer defaults; validate inputs where applicable.
- Be careful with shell escaping / command execution.
