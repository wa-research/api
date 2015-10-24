def call_api(url, op, payload):
    import requests
    import hashlib
    from datetime import datetime
    from urlparse import urlparse, urljoin
    
    key = ""
    pwd = ""
    t = datetime.utcnow().isoformat()[0:19]
    path = urlparse(url).path

    payload.update({
        "site-id": key,
        "request-time": t,
        "signature": hashlib.sha1(op + key + pwd + t).hexdigest(),
        "scope": path
    })

    apiv1suffix = urljoin("/__api/v1/", op)

    return requests.post(url=urljoin(url,apiv1suffix), data=payload)
    
payload = {
    "email": "f@wisint.org"
}

community_url = "https://dgroups.org/community"

response = call_api(community_url, "echo", payload)

print response.text
print response.headers
