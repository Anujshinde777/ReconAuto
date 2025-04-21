## Overview

`ReconAuto1.sh` is a Bash script that automates a comprehensive reconnaissance workflow against a given target domain. It combines passive and active intelligence‑gathering techniques—subdomain discovery, DNS enumeration, web archive scraping, HTTP probing, JavaScript endpoint extraction, directory fuzzing, and more—into a single, easy‑to‑use pipeline. All outputs are neatly organized under a directory named after your target.

---

## Repository Contents

```
.
├── ReconAuto1.sh        # Main reconnaissance script
└── README.md            # This file
```

---

## Prerequisites

Make sure the following tools are installed and available in your `$PATH`:

- **Bash** (≥ 4.0)  
- **dig**, **whois**, **curl**, **xmlstarlet**  
- **Python 3**  
- **waybackurls**  
- **Sublist3r**  
- **assetfinder**  
- **httprobe**  
- **subjs**  
- **subjack**  
- **dirsearch**  
- **xmlstarlet**

You may install many of these via your package manager (e.g., `apt`, `yum`, `brew`) or via `go get` / `pip install` where appropriate.

---

## Installation

1. **Clone** this repository:
   ```bash
   git clone https://github.com/yourusername/ReconAuto1.git
   cd ReconAuto1
   ```
2. **Make** the script executable:
   ```bash
   chmod +x ReconAuto1.sh
   ```

---

## Video
 
## Usage

```bash
./ReconAuto1.sh <target-domain>
```

- **`<target-domain>`**  
  The domain you wish to enumerate (e.g., `example.com`).

### What Happens

1. **Directory Setup**  
   Creates a folder named after your target and `cd`’s into it.
2. **Subdomain Enumeration**  
   - Runs **Sublist3r** and **assetfinder**  
   - Deduplicates into `subdomains`
3. **Live Host Probing**  
   - Pipes to **httprobe** → `alive.txt`
4. **JavaScript Extraction**  
   - Uses **subjs** on live hosts → `jsfiles`
5. **Subdomain Takeover Check**  
   - Executes **subjack** → `takeovers.txt`
6. **Directory Fuzzing**  
   - Iterates **dirsearch** against each live host → `directory_fuzzing.txt`
7. **Advanced Functions**  
   - **DNS Zone Transfer** → `zone-transfer.txt`  
   - **Reverse IP & ASN Lookup** → `rev-dns.txt`, `asn-info.txt`  
   - **Wayback Machine Scraping** → `wayback-urls.txt`  
   - **Full DNS Record Enumeration** → `full-dns.txt`  
   - **Reverse DNS on Discovered Hosts** → `host-rev-dns.txt`  
   - **robots.txt & sitemap.xml Parsing** → `robots.txt`, `sitemap-urls.txt`

---

## Features & Advantages

- **All‑In‑One Pipeline**  
  Automates both passive OSINT (Wayback, Assetfinder) and active enumeration (Dirsearch, subjack).  
- **Modular Functions**  
  Each specialized task is wrapped in its own function—easy to extend or disable.  
- **Color‑Coded Progress**  
  Green/red ANSI output flags successes vs. warnings/errors.  
- **Structured Output**  
  All findings save to per‑task text files, organized under the target folder.  
- **No External Dependencies on Frameworks**  
  Pure Bash and CLI tools—allows maximum transparency and control.  
- **Easy to Customize**  
  Hard‑coded paths and wordlists can be parameterized or replaced to suit your environment.

---

## Output Files

| File                    | Description                                           |
|-------------------------|-------------------------------------------------------|
| `subdomains`            | Unique subdomains discovered                         |
| `alive.txt`             | Hosts responding on HTTP/S                            |
| `jsfiles`               | JavaScript endpoint URLs                              |
| `takeovers.txt`         | Potential subdomain takeover candidates               |
| `directory_fuzzing.txt` | Discovered directories & files via Dirsearch          |
| `zone-transfer.txt`     | Results of DNS zone transfer attempts                 |
| `rev-dns.txt`           | Reverse DNS lookups for each resolved IP              |
| `asn-info.txt`          | ASN and origin data from whois                        |
| `wayback-urls.txt`      | Archived URLs from Wayback Machine                    |
| `full-dns.txt`          | All DNS record types (A, AAAA, CNAME, MX, TXT, SRV)   |
| `host-rev-dns.txt`      | Reverse DNS for each live host                        |
| `robots.txt`            | Fetched robots.txt                                    |
| `sitemap-urls.txt`      | Extracted URLs from sitemap.xml                       |

---

## Customization

- **Wordlist**: Change `WORDLIST` variable in the Dirsearch section.  
- **Tool Paths**: Update hard‑coded paths (`/home/anu777/...`) to your own installs.  
- **Parallelism**: Convert loops to GNU parallel or background jobs to speed up large targets.

---

## Contributing

1. Fork the repository  
2. Create your feature branch: `git checkout -b feature/my-enhancement`  
3. Commit your changes: `git commit -m "Add awesome feature"`  
4. Push to the branch: `git push origin feature/my-enhancement`  
5. Open a Pull Request  

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
