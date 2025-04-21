#!/bin/bash
target=$1

REDCOLOR="\e[31m"
GREENCOLOR="\e[32m"

# ── New functions ───────────────────────────────────────────────────

perform_zone_transfer() {
    echo -e "[+] ${GREENCOLOR}Attempting DNS zone transfer for $target..."
    for ns in $(dig +short NS "$target"); do
        dig AXFR "$target" @"$ns" +noall +answer >> zone-transfer.txt 2>/dev/null
    done
}

reverse_ip_enum() {
    echo -e "[+] ${GREENCOLOR}Performing reverse IP and ASN enumeration..."
    ips=$(dig +short "$target")
    for ip in $ips; do
        # Reverse DNS
        dig +noall +answer -x "$ip" >> rev-dns.txt
        # ASN lookup
        whois "$ip" | grep -Ei 'origin|aut-num' >> asn-info.txt
    done
}

wayback_scrape() {
    echo -e "[+] ${GREENCOLOR}Fetching archived URLs via Wayback Machine..."
    echo "$target" | waybackurls | tee wayback-urls.txt
}

full_dns_enum() {
    echo -e "[+] ${GREENCOLOR}Enumerating all DNS record types..."
    for type in A AAAA CNAME MX TXT SRV; do
        dig +noall +answer "$target" -t "$type" >> full-dns.txt
    done
}

robots_sitemap_parse() {
    echo -e "[+] ${GREENCOLOR}Scraping robots.txt and sitemap.xml..."
    if curl --head --fail -s "https://$target/robots.txt" > /dev/null; then
        curl -s "https://$target/robots.txt" -o robots.txt
    else
    echo "[!] No robots.txt found, skipping sitemap parsing."
   return
   fi
    # extract sitemap URLs and fetch them
    sed -n 's/Sitemap: \(.*\)/\1/p' robots.txt \
      | xargs -r  -n1 curl -s > combined-sitemaps.xml
    # parse <loc> entries
     if [[ -s combined-sitemaps.xml ]]; then
     xmlstarlet sel -t -m "//url/loc" -v . -n combined-sitemaps.xml > sitemap-urls.txt
     else
     echo "[!] No sitemap URLs found."
     fi

}

reverse_dns_lookup() {
    echo -e "[+] ${GREENCOLOR}Performing reverse DNS lookups on discovered hosts..."
    grep -v '^[[:space:]]*$' alive.txt | while read host; do
        ip=$(dig +short "$host")
        [[ -n "$ip" ]] && dig +noall +answer -x "$ip" >> host-rev-dns.txt
    done
}

# ── Existing workflow ────────────────────────────────────────────────

if [ ! -d "$target" ]; then
    mkdir "$target"
fi
cd "$target"

echo -e "[+] ${REDCOLOR}Finding subdomains with Sublist3r..."
python3 /home/anu777/ReconAutomation/subwalker/tools/Sublist3r/sublist3r.py -d "$target" -t 25 -o subdomains.txt -e bing,yahoo

echo -e "[+] ${REDCOLOR}Finding subdomains with Assetfinder..."
/home/anu777/ReconAutomation/subwalker/tools/assetfinder/assetfinder  --subs-only "$target" >> subdomains.txt

echo -e "[+] ${REDCOLOR}Filtering subdomains..."
sort -u subdomains.txt > subdomains

echo -e "[+] ${REDCOLOR}Probing live hosts..."
httprobe < subdomains > alive.txt

echo -e "[+] ${REDCOLOR}Extracting JavaScript endpoints..."
subjs < alive.txt > jsfiles

echo -e "[+] ${REDCOLOR}Checking for subdomain takeovers..."
subjack -w subdomains -c /home/anu777/go/pkg/mod/github.com/haccer/subjack@v0.0.0-20201112041112-49c51e57deab/fingerprints.json  -t 25 -ssl -o takeovers.txt

echo -e "[+] ${REDCOLOR}Fuzzing directories with Dirsearch..."
WORDLIST=/home/anu777/ReconAutomation/worldList/common.txt
grep -v '^[[:space:]]*$' alive.txt | while read host; do
    python3 /usr/lib/python3/dist-packages/dirsearch/dirsearch.py -u "$host" -w "$WORDLIST" -o directory_fuzzing.txt -t 50
done

# ── Invoke manual‐technique functions ───────────────────────────────

perform_zone_transfer
reverse_ip_enum
wayback_scrape
full_dns_enum
reverse_dns_lookup
robots_sitemap_parse

echo -e "[+] ${GREENCOLOR}Recon pipeline complete!"
