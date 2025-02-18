### Step 1 - Basic configuration

Create a new file in `/etc/nginx/sites-available/`:

```bash
sudo nvim /etc/nginx/sites-available/[subdomain].bartoszbak.org
```

Add this to the file:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name [subdomain].bartoszbak.org;
    location / {
        proxy_pass http://localhost:[port of service];
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Create a symbolic link to the sites-enabled directory:

```bash
sudo ln -s /etc/nginx/sites-available/[subdomain].bartoszbak.org /etc/nginx/sites-enabled/
```

Test the configuration and restart the Nginx service:

```bash
sudo nginx -t
```

```bash
sudo systemctl restart nginx
```

### Step 2 - SSL setup (with Certbot)

Make sure to turn off Cloudflare's proxying for your domain before proceeding with the SSL setup. This is necessary for the SSL verification process to work correctly.

First, install Certbot:

```bash
sudo apt update && sudo apt install python3 python3-venv libaugeas0
```

```bash
sudo python3 -m venv /opt/certbot/ && sudo /opt/certbot/bin/pip install --upgrade pip
```

```bash
sudo /opt/certbot/bin/pip install certbot certbot-nginx
```

```bash
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
```

Set up the actual SSL certificate:

```bash
sudo certbot --nginx
```

Now the configuarion file should be changed to include the SSL cert, and you can enable Cloudflare's proxying again.

Restart the Nginx service:

```bash
sudo systemctl restart nginx
```
