sudo -s
addgroup proxy; adduser --disabled-password --gecos "" --ingroup "proxy" proxy
addgroup squid; adduser --disabled-password --gecos "" --ingroup "squid" squid
usermod -aG sudo squid
apt-get update -y && apt-get -y upgrade
apt-get install squid -y
cp /etc/squid/squid.conf /etc/squid/squid.conf.back
echo "http_access allow localhost" >> /etc/squid/squid.conf
echo "http_access allow all" >> /etc/squid/squid.conf
echo "http_port 80" >> /etc/squid/squid.conf
systemctl restart squid

apt install -y apache2-utils

echo """
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
""" >> /etc/squid/squid.conf

touch /etc/squid/passwd
echo "****" | htpasswd -c -i /etc/squid/passwd squid
export CFLAGS=" -Dbind=SOCKSbind "
export CXXFLAGS=" -Dbind=SOCKSbind "
export LDADD=" -lsocks "
export CFLAGS=" -Dbind=SOCKSbind -Dconnect=SOCKSconnect "
export CXXFLAGS=" -Dbind=SOCKSbind -Dconnect=SOCKSconnect "
systemctl restart squid



docker run -d --name socks5 -p 80:1080 -e PROXY_USER=phinees -e PROXY_PASSWORD=MonSquidPwd06 serjs/go-socks5-proxy


# install docker
 sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


# give rights to serviceAccount
# gcloud artifacts repositories add-iam-policy-binding "proxy" \
#     --project=kela-presta-325511 \
#     --location=europe-west1 \
#     --member=serviceAccount:787766483595-compute@developer.gserviceaccount.com \
#     --role=roles/artifactregistry.reader

# gcloud projects add-iam-policy-binding kela-presta-325511 \
#     --member=serviceAccount:787766483595-compute@developer.gserviceaccount.com \
#     --role=roles/artifactregistry.reader

gsutil iam ch serviceAccount:787766483595-compute@developer.gserviceaccount.com:objectViewer gs://artifacts.kela-presta-325511.appspot.com
gcloud auth print-access-token | sudo docker login -u oauth2accesstoken     --password-stdin https://gcr.io

sudo docker run -d -p 80:8080 --name proxy gcr.io/kela-presta-325511/proxy:1.0.0

https://binx.io/2019/03/29/how-to-grant-access-to-the-google-container-registry/