### Step 1 — Installing Nginx

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install nginx -y
```

After the installation is complete, you can check the status of the Nginx service:

```bash
sudo systemctl status nginx
```

### Step 2 — Setting Up a Basic Configuration

```bash
sudo nano /etc/nginx/sites-available/[site-name]
```

Inside this file, start with a basic configuration like so:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name bartoszbak.org www.bartoszbak.org;

    root /var/www/[your site files root folder];
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

I recommend keeping the website files in their own folders in the /var/www/ directory. This way, you can easily manage multiple websites on the same server.

After you've created the file, you need to create a symbolic link to the sites-enabled directory:

```bash
sudo ln -s /etc/nginx/sites-available/[site-name] /etc/nginx/sites-enabled/
```

Now, you can test the configuration and restart the Nginx service:

```bash
sudo nginx -t
```

If the test is successful, restart the Nginx service:

```bash
sudo systemctl restart nginx
```

### Step 3 — Setting Up SSL (with Certbot)

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
